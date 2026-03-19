#!/bin/bash

echo "Stopping any existing processes on ports 8000-8004..."
for port in 8000 8001 8002 8003 8004; do
  fuser -k ${port}/tcp 2>/dev/null || true
done

export GOOGLE_CLOUD_PROJECT=$(gcloud config get-value project)
export GOOGLE_CLOUD_LOCATION="global"
export GOOGLE_GENAI_USE_VERTEXAI="True"
export GOOGLE_API_KEY=""
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/application_default_credentials.json"

echo "Starting Researcher Agent on port 8001..."
pushd agents/researcher >/dev/null
uv run python -m uvicorn adk_app:app --host 0.0.0.0 --port 8001 > /tmp/researcher.log 2>&1 &
RESEARCHER_PID=$!
popd >/dev/null

echo "Starting Judge Agent on port 8002..."
pushd agents/judge >/dev/null
uv run adk_app.py --host 0.0.0.0 --port 8002 --publish_agent_info --a2a . > /tmp/judge.log 2>&1 &
JUDGE_PID=$!
popd >/dev/null

echo "Starting Content Builder Agent on port 8003..."
pushd agents/content_builder >/dev/null
uv run adk_app.py --host 0.0.0.0 --port 8003 --publish_agent_info --a2a . > /tmp/content_builder.log 2>&1 &
CONTENT_BUILDER_PID=$!
popd >/dev/null

export RESEARCHER_AGENT_CARD_URL=http://localhost:8001/a2a/researcher/.well-known/agent-card.json
export JUDGE_AGENT_CARD_URL=http://localhost:8002/a2a/agent/.well-known/agent-card.json
export CONTENT_BUILDER_AGENT_CARD_URL=http://localhost:8003/a2a/agent/.well-known/agent-card.json

echo "Starting Orchestrator Agent on port 8004..."
pushd agents >/dev/null
uv run orchestrator/adk_app.py --host 0.0.0.0 --port 8004 --publish_agent_info --a2a . > /tmp/orchestrator.log 2>&1 &
ORCHESTRATOR_PID=$!
popd >/dev/null

sleep 8

echo "Starting App Server on port 8000..."
pushd app >/dev/null
export AGENT_SERVER_URL=http://localhost:8004
uv run python -m uvicorn main:app --host 0.0.0.0 --port 8000 > /tmp/app.log 2>&1 &
APP_PID=$!
popd >/dev/null

echo "All agents started!"
echo "Researcher: http://localhost:8001"
echo "Judge: http://localhost:8002"
echo "Content Builder: http://localhost:8003"
echo "Orchestrator: http://localhost:8004"
echo "App Server (Frontend): http://localhost:8000"
echo ""
echo "Logs:"
echo "  /tmp/researcher.log"
echo "  /tmp/judge.log"
echo "  /tmp/content_builder.log"
echo "  /tmp/orchestrator.log"
echo "  /tmp/app.log"
echo ""
echo "Press Ctrl+C to stop all agents."

trap "kill $RESEARCHER_PID $JUDGE_PID $CONTENT_BUILDER_PID $ORCHESTRATOR_PID $APP_PID 2>/dev/null; exit" INT
wait
