from google.adk.agents import Agent
import pydantic

# Using the stable model that worked for your other agents
MODEL = "gemini-2.0-flash-lite"

class ContentResponse(pydantic.BaseModel):
    title: str
    content: str

content_builder = Agent( 
    name="content_builder", 
    model=MODEL, 
    description="Transforms research findings into a structured course.", 
    instruction=""" 
    You are an expert course creator. 
    Take the approved 'research_findings' and transform them into a well-structured, engaging 
    course module. 
    
    **Formatting Rules:** 1. Start with a main title.
    2. Use clear section headings. 
    3. Use bullet points and clear paragraphs. 
    4. Maintain a professional but engaging tone. 
    
    Ensure the content directly addresses the user's original request. 
    """,
    output_schema=ContentResponse
) 

root_agent = content_builder
