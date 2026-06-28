#!/bin/sh

# Commit and push any local changes before running the job.
if [ -n "$(git status --porcelain)" ]; then
        git add -A
        git commit -m "Auto-commit before running nebius job"
fi
git push

job_output=$(nebius ai job create \
        --name smoke-test-ariel-bachar \
        --image cr.eu-north1.nebius.cloud/e00v1er5fasm8gmdwy/apex-ex-1 \
        --container-command bash \
        --args '-c "git clone https://github.com/relrelb/architects-ex-1.git && cd architects-ex-1 && python train_gpt2.py"' \
        --platform gpu-l40s-d \
        --preset 1gpu-16vcpu-96gb \
        --timeout 15m \
        --volume computefilesystem-e00hnnpfn5rr5aavma:/mnt/data)
echo "$job_output"

# Extract the job ID from the create output and stream its logs.
job_id=$(echo "$job_output" | grep -o 'aijob-[a-z0-9]*' | head -n 1)
echo "Streaming logs for job $job_id"
nebius ai job logs "$job_id" --follow
