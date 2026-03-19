# Copyright 2026 Google LLC
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

import os
import uvicorn
import logging
import warnings

warnings.filterwarnings("ignore")

try:
    from google.adk.python import fast_api
except ImportError:
    from google.adk.cli import fast_api

def start_server():
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)
    port = int(os.environ.get("PORT", 8080))

    logger.info(f"🚀 Starting ADK Judge server on port {port}...")

    # We look for the agent in the current directory (agents_dir=".")
    app = fast_api.get_fast_api_app(
        agents_dir=".",
        web=True
    )

    uvicorn.run(app, host="0.0.0.0", port=port)

if __name__ == "__main__":
    start_server()
