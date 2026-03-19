import logging
import os
import json
import re
from typing import Any, Dict, List, Optional

import httpx
from httpx_sse import aconnect_sse

from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from google.cloud import modelarmor_v1
from google.genai import types as genai_types
from opentelemetry import trace
from opentelemetry.exporter.cloud_trace import CloudTraceSpanExporter
from opentelemetry.sdk.trace import TracerProvider, export
from pydantic import BaseModel
from authenticated_httpx import create_authenticated_client
from safety_util import parse_model_armor_response

class Feedback(BaseModel):
    score: float
    text: str | None = None
    run_id: str | None = None
    user_id: str | None = None

MODEL_ARMOR_TEMPLATE = os.getenv("TEMPLATE_NAME")
model_armor_client = modelarmor_v1.ModelArmorClient(
    client_options={"api_endpoint": "modelarmor.us-central1.rep.googleapis.com"}
)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

provider = TracerProvider()
processor = export.BatchSpanProcessor(CloudTraceSpanExporter())
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

agent_name = os.getenv("AGENT_NAME", None)
agent_server_url = os.getenv("AGENT_SERVER_URL")
if not agent_server_url:
    raise ValueError("AGENT_SERVER_URL environment variable not set")
else:
    agent_server_url = agent_server_url.rstrip("/")

clients: Dict[str, httpx.AsyncClient] = {}


async def get_client(agent_server_origin: str) -> httpx.AsyncClient:
    global clients
    if agent_server_origin not in clients:
        clients[agent_server_origin] = create_authenticated_client(agent_server_origin)
    return clients[agent_server_origin]


async def create_session(agent_server_origin: str, agent_name: str, user_id: str) -> Dict[str, Any]:
    httpx_client = await get_client(agent_server_origin)
    session_request_url = f"{agent_server_origin}/apps/{agent_name}/users/{user_id}/sessions"
    session_response = await httpx_client.post(
        session_request_url,
        headers=[("Content-Type", "application/json")],
    )
    session_response.raise_for_status()
    return session_response.json()


async def get_session(
    agent_server_origin: str,
    agent_name: str,
    user_id: str,
    session_id: str,
) -> Optional[Dict[str, Any]]:
    httpx_client = await get_client(agent_server_origin)
    session_request_url = f"{agent_server_origin}/apps/{agent_name}/users/{user_id}/sessions/{session_id}"
    session_response = await httpx_client.get(
        session_request_url,
        headers=[("Content-Type", "application/json")],
    )
    if session_response.status_code == 404:
        return None
    session_response.raise_for_status()
    return session_response.json()


async def list_agents(agent_server_origin: str) -> List[str]:
    httpx_client = await get_client(agent_server_origin)
    list_url = f"{agent_server_origin}/list-apps"
    list_response = await httpx_client.get(
        list_url,
        headers=[("Content-Type", "application/json")],
    )
    list_response.raise_for_status()
    agent_list = list_response.json()
    return agent_list if agent_list else ["agent"]


async def query_adk_sever(
    agent_server_origin: str,
    agent_name: str,
    user_id: str,
    message: str,
    session_id: str,
):
    httpx_client = await get_client(agent_server_origin)
    request = {
        "appName": agent_name,
        "userId": user_id,
        "sessionId": session_id,
        "newMessage": {"role": "user", "parts": [{"text": message}]},
        "streaming": False,
    }
    async with aconnect_sse(
        httpx_client,
        "POST",
        f"{agent_server_origin}/run_sse",
        json=request,
    ) as event_source:
        if event_source.response.is_error:
            yield {
                "author": agent_name,
                "content": {"parts": [{"text": f"Error {event_source.response.text}"}]},
            }
        else:
            async for server_event in event_source.aiter_sse():
                yield server_event.json()


def sanitize_prompt_or_block(text: str) -> tuple[Optional[str], List[str]]:
    """
    Returns (sanitized_text_or_none, detected_filters).
    If filters are detected, caller should block.
    """
    if not MODEL_ARMOR_TEMPLATE:
        logger.warning("TEMPLATE_NAME not set; skipping Model Armor prompt check.")
        return text, []

    user_prompt_data = modelarmor_v1.DataItem(text=text)
    ma_request = modelarmor_v1.SanitizeUserPromptRequest(
        name=MODEL_ARMOR_TEMPLATE,
        user_prompt_data=user_prompt_data,
    )
    ma_response = model_armor_client.sanitize_user_prompt(request=ma_request)
    detected_filters = parse_model_armor_response(ma_response)

    if detected_filters:
        return None, detected_filters

    sanitized_text = text
    if (
        hasattr(ma_response, "sanitized_user_prompt_data")
        and ma_response.sanitized_user_prompt_data
        and getattr(ma_response.sanitized_user_prompt_data, "text", None)
    ):
        sanitized_text = ma_response.sanitized_user_prompt_data.text

    return sanitized_text, []


def sanitize_model_output(text: str) -> tuple[str, List[str]]:
    """
    Sanitizes model output via Model Armor before returning it to the user.
    Returns (sanitized_text, detected_filters).
    """
    if not MODEL_ARMOR_TEMPLATE:
        logger.warning("TEMPLATE_NAME not set; skipping Model Armor output sanitization.")
        return text, []

    model_response_data = modelarmor_v1.DataItem(text=text)
    ma_request = modelarmor_v1.SanitizeModelResponseRequest(
        name=MODEL_ARMOR_TEMPLATE,
        model_response_data=model_response_data,
    )
    ma_response = model_armor_client.sanitize_model_response(request=ma_request)
    detected_filters = parse_model_armor_response(ma_response)

    sanitized_text = text
    if (
        hasattr(ma_response, "sanitized_model_response_data")
        and ma_response.sanitized_model_response_data
        and getattr(ma_response.sanitized_model_response_data, "text", None)
    ):
        sanitized_text = ma_response.sanitized_model_response_data.text

    return sanitized_text, detected_filters


def deterministic_redact_sensitive_data(text: str) -> str:
    """
    Final fallback redaction layer to guarantee masking before output.
    This protects against leaks even if the model paraphrases or Model Armor
    does not fully de-identify the returned text.
    """
    # Credit cards: keep last 4 digits when possible
    text = re.sub(
        r'\b(?:\d{4}[- ]?){3}\d{4}\b',
        lambda m: f"####-####-####-{re.sub(r'[^0-9]', '', m.group(0))[-4:]}",
        text,
    )

    # SSN
    text = re.sub(r'\b\d{3}-\d{2}-\d{4}\b', '[redacted-ssn]', text)

    # Email
    text = re.sub(
        r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b',
        '[redacted-email]',
        text,
    )

    # Simple API key patterns
    text = re.sub(r'\bAIza[0-9A-Za-z\-_]{20,}\b', '[redacted-api-key]', text)
    text = re.sub(r'\bsk-[A-Za-z0-9]{16,}\b', '[redacted-api-key]', text)

    return text


class SimpleChatRequest(BaseModel):
    message: str
    user_id: str = "test_user"
    session_id: Optional[str] = None


@app.post("/api/chat_stream")
async def chat_stream(request: SimpleChatRequest):
    async def event_generator():
        try:
            sanitized_prompt, detected_filters = sanitize_prompt_or_block(request.message)
            if detected_filters:
                yield json.dumps(
                    {
                        "type": "result",
                        "text": f"⚠️ Safety Block: Content flagged for: {detected_filters}",
                    }
                ) + "\n"
                return
        except Exception as e:
            logger.error(f"Model Armor prompt check failed: {e}")
            sanitized_prompt = request.message

        global agent_name, agent_server_url
        if not agent_name:
            agent_name = (await list_agents(agent_server_url))[0]

        session = await create_session(agent_server_url, agent_name, request.user_id)
        events = query_adk_sever(
            agent_server_url,
            agent_name,
            request.user_id,
            sanitized_prompt,
            session["id"],
        )

        final_text = ""
        async for event in events:
            if event["author"] == "researcher":
                yield json.dumps(
                    {"type": "progress", "text": "🔍 Researcher is gathering information..."}
                ) + "\n"
            elif event["author"] == "judge":
                yield json.dumps(
                    {"type": "progress", "text": "⚖️ Judge is evaluating findings..."}
                ) + "\n"
            elif event["author"] == "content_builder":
                yield json.dumps(
                    {"type": "progress", "text": "✍️ Content Builder is writing..."}
                ) + "\n"

            if "content" in event and event["content"]:
                content = genai_types.Content.model_validate(event["content"])
                for part in content.parts:
                    if part.text:
                        final_text += part.text

        cleaned_text = final_text.strip()

        try:
            cleaned_text, detected_output_filters = sanitize_model_output(cleaned_text)

            if detected_output_filters:
                logger.warning(f"Output flagged by Model Armor: {detected_output_filters}")
        except Exception as e:
            logger.error(f"Model Armor output sanitization failed: {e}")

        # Deterministic fallback redaction
        cleaned_text = deterministic_redact_sensitive_data(cleaned_text)

        yield json.dumps({"type": "result", "text": cleaned_text}) + "\n"

    return StreamingResponse(event_generator(), media_type="application/x-ndjson")


frontend_path = os.path.join(os.path.dirname(__file__), "frontend")
if os.path.exists(frontend_path):
    app.mount("/", StaticFiles(directory=frontend_path, html=True), name="frontend")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("PORT", 8000)))
