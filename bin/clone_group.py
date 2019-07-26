#!/usr/bin/env python3
import os
import logging
# from pprint import pprint

import requests

logging.basicConfig(level=logging.WARNING)

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
    logging.info("Getting a resource")
    response = requests.get(url + '/' + query + token)
    if response.status_code != 200:
        print(response.text)
        exit(1)
    return response.json()


def get_group(group_id):
    logging.info(f"Get group { group_id }")
    data = get_resource("groups/" + str(group_id))
    logging.info(f"Retrieved { data['full_path'] }")
    return data


def get_subgroups_ids(group_id):
    logging.info("Get subgroups ids")
    subgroups = get_resource("groups/" + str(group_id) + "/subgroups")
    return [subgroup["id"] for subgroup in subgroups]


def get_subgroups(group_id):
    logging.info("Get subgroups")
    subgroups = [get_group(subgroup_id)
                 for subgroup_id in get_subgroups_ids(group_id)]
    logging.info("Got subgroups: "
                 f"{ [ subgroup['full_path'] for subgroup in subgroups ] }")
    return subgroups


def retrieve_projects(group):
    logging.info("Retrieve project")
    retrieved_projects = [project[link_type] for project in group["projects"]]
    logging.info(f"Retrieved projects:\n{ retrieved_projects }")
    return retrieved_projects


def get_projects_recursive(group_id):
    logging.info("Getting projects recursive call")
    projects = []
    for subgroup in get_subgroups(group_id):
        logging.info(f"Checking subgroup { subgroup['full_path'] }")
        projects.extend(retrieve_projects(subgroup))
        projects.extend(get_projects_recursive(subgroup['id']))
    return projects


def get_projects(group_id):
    logging.info("Getting projects")
    projects = retrieve_projects(get_group(group_id))
    new_projects = get_projects_recursive(group_id)
    if new_projects:
        projects.extend(new_projects)
    return projects


root_group = list(groups.values())[0]
logging.info(f"Checking group with id {root_group}")
projects = get_projects(root_group)

print(*projects, sep="\n")
