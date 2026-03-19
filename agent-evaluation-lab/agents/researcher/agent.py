from google.adk.agents import Agent
from google.adk.models import Gemini

model = Gemini(
    model_name="gemini-2.5-flash",
    location="global",
)

root_agent = Agent(
    name="researcher",
    instruction="""
You are a research assistant.

Produce a compact research brief only.

Return exactly these sections:
1. Key Concepts
2. Historical Background
3. Major Debates
4. Key Actors
5. Important Events
6. Strategic Questions

Rules:
- Keep the response short and compact.
- No long paragraphs.
- No repeated headings.
- No course outline.
- No extra sections.
- No deep expansion; later agents will do that.
""",
    model=model,
)
