import os
import urllib

import requests

base_url = "https://gitlab.com"
api_suffix = "/api/v4"
url = base_url + api_suffix

if True:
    link_type = "ssh_url_to_repo"
else:
    link_type = "http_url_to_repo"

groups = {
    "test": "11111"
}

token_prefix = "?private_token="
with open(os.path.expanduser("~/.gitlab")) as token_file:
    token_key = token_file.read().strip()
token = token_prefix + token_key

def get_resource(query):
    response = requests.get(url + '/' + query + token)
    if response.status_code != 200:
        return None
    return response.json()

def get_group(group_id):
    return get_resource("groups/" + str(group_id))

def get_subgroups_ids(group_id):
    subgroups = get_resource("groups/" + str(group_id) + "/subgroups")
    return [ subgroup["id"] for subgroup in subgroups ]

def get_subgroups(group_id):
    return [ get_group(subgroup_id)
            for subgroup_id in get_subgroups_ids(group_id) ]

def retrieve_projects(group):
    return [ project[link_type] for project in group["projects"] ]

def get_projects_recursive(group_id):
    projects = []
    for subgroup in get_subgroups(group_id):
        projects.append(retrieve_projects(subgroup))
        projects.append(get_projects_recursive(group_id))
    return projects

def get_projects(group_id):
    projects = retrieve_projects(get_group(group_id))
    projects.append(get_projects_recursive(group_id))

get_projects(groups["test"])
