import wikipedia
from google.adk.agents import Agent

MODEL = "gemini-2.5-flash"

def wikipedia_search(query: str) -> str:
    """Searches Wikipedia for a given query and returns a summary."""
    try:
        return wikipedia.summary(query, sentences=2)
    except Exception:
        return f"Information not found for {query}."

researcher = Agent(
    name="agent",
    model=MODEL,
    instruction="You are a professional researcher. Use the Wikipedia tool to provide factual answers.",
    tools=[wikipedia_search]
)
