#!/bin/zsh

# Get the value of n from the environment or use a default value of 2
n=${N:-2}

# Array to store the PIDs
pids=()

# Function to start sidekiq process and capture the PID
start_sidekiq() {
    bundle exec sidekiq -c 4 -r ./sidekiq_queue/jobs/aggregator_job.rb -r ./sidekiq_queue/jobs/producer_job.rb -r ./sidekiq_queue/jobs/stats_cruncher_job.rb > /dev/null 2>&1 &
    pid=$!
    pids+=($pid)
    echo "Started sidekiq process with PID: $pid"
}

# Loop to start n sidekiq processes
for ((i=1; i<=n; i++)); do
    start_sidekiq
done

echo "Started $n sidekiq processes with PIDs: ${pids[@]}"

