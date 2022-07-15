#!/usr/bin/env python3

import os
import sys
import subprocess

jobid = sys.argv[1]

try:
    # We get the full report here
    res = subprocess.run("qstat -f -x {}".format(jobid), check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
    res = [line.strip() for line in res.stdout.decode().split(os.linesep)]
    job_state = [line for line in res if line.startswith("job_state")][0].split()[-1]
#            'C': QueueStatus.DONE,
#            'R': QueueStatus.RUNNING,
#            'Q': QueueStatus.PENDING,
#            'H': QueueStatus.HOLD,
#            'S': QueueStatus.HOLD
    if job_state == "R":
        print("running")
    elif job_state == "F":
        for line in res:
            if line.strip().startswith("Exit_status"):
                exit_status = line.split()[-1]
                if exit_status == '0':
                    print("success")
        #exit_status = [line for line in res if line.strip().startswith("Exit_status")][0].split()[-1]
    else:
        print("failed")

except (subprocess.CalledProcessError, IndexError, KeyboardInterrupt) as e:
    print("failed")
