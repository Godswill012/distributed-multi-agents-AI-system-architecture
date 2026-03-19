# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import asyncio
import json
import os

from vertexai import types # type: ignore

from dotenv import load_dotenv

from shared.evaluation.evaluate import (
    evaluate_agent,
    get_custom_function_metric
)
from shared.evaluation.tool_metrics import (
    trajectory_precision_func, trajectory_recall_func
)

load_dotenv()

METRIC_THRESHOLD = 0.75
RESEARCHER_URL = os.environ["RESEARCHER_URL"]
ORCHESTRATOR_URL = os.environ["ORCHESTRATOR_URL"]
GOOGLE_CLOUD_PROJECT = os.environ["GOOGLE_CLOUD_PROJECT"]
GOOGLE_CLOUD_REGION = os.getenv("GOOGLE_CLOUD_REGION", "us-central1")

if __name__ == "__main__":
    # TODO: implement evaluation
    # 1. Setup paths and metrics for the Researcher
    eval_data_researcher = os.path.dirname(__file__) + "/eval_data_researcher.json" 
    
    metrics = [ 
        # Compares the agent's output against a "Golden Answer" 
        types.RubricMetric.FINAL_RESPONSE_MATCH, 
        # Did the agent use the tools effectively? 
        types.RubricMetric.TOOL_USE_QUALITY, 
        # Custom metrics for tools trajectory analysis (Code-based)
        get_custom_function_metric("trajectory_precision", trajectory_precision_func), 
        get_custom_function_metric("trajectory_recall", trajectory_recall_func) 
    ] 

    print("🚀 Running Researcher Evaluation...") 
    
    # 2. Execute the evaluation against the Researcher Agent
    eval_results = asyncio.run( 
        evaluate_agent( 
            agent_api_server=RESEARCHER_URL, # The Cloud Run URL for the shadow revision
            agent_name="agent", 
            evaluation_data_file=eval_data_researcher, 
            # Storage for evaluation results
            evaluation_storage_uri=f"gs://{GOOGLE_CLOUD_PROJECT}-agents/evaluation", 
            metrics=metrics, 
            project_id=GOOGLE_CLOUD_PROJECT, 
            location=GOOGLE_CLOUD_REGION 
        ) 
    ) 

    print(f"\n📊 Researcher Evaluation results:\n{eval_results}") 
    print(f"Evaluation Run ID: {eval_results.run_id}")

    # 3. Success Criteria (Gating Step)
    # Fail the build if any metric mean falls below the threshold
    researcher_eval_failed = False 
    for metric_name, metric_values in eval_results.metrics.items(): 
        if metric_values["mean"] < METRIC_THRESHOLD: 
            print(f"❌ Researcher Evaluation failed with metric `{metric_name}`: "
                  f"{metric_values['mean']:.2f} (Threshold: {METRIC_THRESHOLD})") 
            researcher_eval_failed = True 

    if researcher_eval_failed: 
        exit(1)
