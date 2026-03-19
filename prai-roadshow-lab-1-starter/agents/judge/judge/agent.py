from typing import Literal
from google.adk.agents import Agent
from pydantic import BaseModel, Field

# 1. Define the Schema
class JudgeFeedback(BaseModel):
    status: Literal["pass", "fail"] = Field(description="The grade")
    feedback: str = Field(description="The reason")

# 2. Define the Agent - NAME MUST MATCH ADK_AGENT_ID
judge = Agent(
    name="judge",
    model="gemini-2.0-flash-lite",
    instruction="Evaluate the findings.",
    output_schema=JudgeFeedback
)

# 3. Explicitly set root_agent
root_agent = judge
