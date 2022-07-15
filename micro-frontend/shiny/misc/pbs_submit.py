#!/usr/bin/env python3


import sys, os
from subprocess import Popen, PIPE
import yaml

from snakemake.logging import logger

def eprint(text):
    #print(*args, file=sys.stderr, **kwargs)
    logger.info(f'CLUSTER: {text}')


# let snakemake read job_properties
from snakemake.utils import read_job_properties

jobscript = sys.argv[1]
job_properties = read_job_properties(jobscript)

# There is no formal definition on how to use resources or job, which mean that thing like this are legit
# (jobid: 1, external: {'type': 'single', 'rule': 'startabc', 'local': False, 'input': [], 'output': ['abc'], 'wildcards': {}, 'params': {}, 'log': [], 'threads': 1, 'resources': {'mem': 1200, 'something': 'noting', 'ppn': 2}, 'jobid': 1, 'cluster': {'nodes': 1, 'threads': 3, 'mem': 16, 'time': 15, 'jobs': 100, 'garbage': 'yes'}}

#default paramters defined in cluster_spec (accessed via snakemake read_job_properties)
resources_param = job_properties["resources"]
cluster_param= job_properties["cluster"]

if job_properties["type"]=='single':
    cluster_param['name'] = job_properties['rule']
elif job_properties["type"]=='group':
    cluster_param['name'] = job_properties['groupid']
else:
    raise NotImplementedError(f"Don't know what to do with job_properties['type']=={job_properties['type']}")

# Start with threads, then cluster_param
if ('threads' in job_properties) and ('threads' not in cluster_param):
    cluster_param["threads"] = job_properties["threads"]
# use resource if cluster_param is not available
for res in ['time','mem']:
    if (res in job_properties["resources"]) and (res not in cluster_param):
        cluster_param[res] = job_properties["resources"][res]

# check which system you are on and load command command_options
#key_mapping_file=os.path.join(os.path.dirname(__file__),"key_mapping.yaml")
#command_options=yaml.load(open(key_mapping_file),
                          #Loader=yaml.BaseLoader)
#system= command_options['system']

command= "qsub"
key_mapping= {
    "name": "-N {}",
    "account": "-A {}",
    "queue": "-q {}",
    "threads": "-l nodes=1:ppn={}", # always use 1 node
    "mem": "-l mem={}gb",
    "time": "-l walltime={}", # using fulle xx:xx:xx
    "output": "-o {}",
    "error": "-e {}",
}

# construct command:
for key in key_mapping:
    if key in cluster_param:
        command+=" "
        command+=key_mapping[key].format(cluster_param[key])

command+=' {}'.format(jobscript)

eprint("submit command: "+command)

p = Popen(command.split(), stdout=PIPE, stderr=PIPE)
output, error = p.communicate()
if p.returncode != 0:
    raise Exception("Job can't be submitted\n"+output.decode("utf-8")+error.decode("utf-8"))
else:
    res= output.decode("utf-8")
    jobid= res.strip().split('.')[0]

    print(jobid)

# TODO qalter to redirect log, I dunno how this works
# https://stackoverflow.com/questions/26479277
#os.makedirs('cluster_logs', exist_ok=True)
#output, error = p2.communicate()
