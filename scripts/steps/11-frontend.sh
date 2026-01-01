#!/bin/bash
set -euo pipefail
: "${WORKSPACE_DIR:?WORKSPACE_DIR not set}"


# Clone frontend
cd $WORKSPACE_DIR/
if [ -d "open-drone-frontend" ]; then
    echo "Directory open-drone-frontend already exists, skipping clone."
else
    git clone https://github.com/robotics-88/open-drone-frontend.git
fi
cd open-drone-frontend
git pull
python3 -m venv .env
source .env/bin/activate
pip install -r requirements.txt
deactivate

echo "11 Frontend setup completed. ✅ Success"