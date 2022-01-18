import json
import boto3

def resume_autoscaling_groups():
    
    as_client = boto3.client('autoscaling')
    client = boto3.client('autoscaling')
    paginator = client.get_paginator('describe_auto_scaling_groups')
    
    page_iterator = paginator.paginate(
        PaginationConfig={'PageSize': 100}
    )

    filtered_asgs = page_iterator.search(
        'AutoScalingGroups[] | [?contains(Tags[?Key==`{}`].Value, `{}`)]'.format(
            'Owner', 'dkolegaev')
    )

    for asg in filtered_asgs:
        print asg['AutoScalingGroupName']
        as_client.resume_processes(AutoScalingGroupName=asg['AutoScalingGroupName'])
        print('Autoscaling group {0} processes will be resumed'.format(asg['AutoScalingGroupName']))


def start_my_instances():

    ec2 = boto3.resource('ec2')
    
    filters = [
             {
            'Name': 'tag:Owner',
            'Values': ['dkolegaev']
        },
        {
            'Name': 'instance-state-name',
            'Values': ['stopped']
        }
    ]
    
    ec2.instances.filter(Filters=filters).start()
    
    resume_autoscaling_groups()


def lambda_handler(event, context):
    
    start_my_instances()
    
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
