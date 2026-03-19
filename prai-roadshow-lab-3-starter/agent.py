from google.adk.agents import Agent
from google.adk.tools.google_search_tool import google_search

MODEL = "gemini-2.5-flash"


def needs_search(user_query: str) -> bool:
    q = user_query.lower()
    keywords = [
        "latest", "current", "today", "recent", "news",
        "source", "sources", "verify", "verification",
        "trend", "trends", "update", "updates", "2025", "2026"
    ]
    return any(word in q for word in keywords)


fast_agent = Agent(
    name="fast_agent",
    model=MODEL,
    description="Gives quick answers without unnecessary search.",
    instruction="""
You are a fast assistant.

Answer the user's question clearly, directly, and concisely.
Give a short answer first.
Keep the default response brief unless the user explicitly asks for more detail.
Do not use search for general knowledge questions.
Prefer a short paragraph or 4-6 bullet points maximum.
""",
)

research_agent = Agent(
    name="research_agent",
    model=MODEL,
    description="Performs deeper research only when needed.",
    instruction="""
You are a fast research assistant.

Answer the user's question clearly and concisely.
Use the `google_search` tool only when the user asks for:
- latest or current information
- recent events or updates
- verification
- sources or citations

Do not over-research.
Give a brief direct answer first, then add only the most relevant supporting details.
Keep the response concise unless the user explicitly asks for a deep explanation.
Prefer a short paragraph or 4-6 bullet points maximum.
""",
    tools=[google_search],
)


class RoutedResearchAgent:
    def __init__(self, fast_agent, research_agent):
        self.fast_agent = fast_agent
        self.research_agent = research_agent
        self.name = "researcher"

    def run(self, user_query: str):
        selected_agent = research_agent if needs_search(user_query) else fast_agent
        return selected_agent.run(user_query)


root_agent = RoutedResearchAgent(fast_agent, research_agent)
