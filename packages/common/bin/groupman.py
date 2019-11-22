#!/usr/bin/env python3
import os
import logging
import argparse
# from pprint import pprint

import requests

base_url = "https://gitlab.com"
api_suffix = "/api/v4"
url = base_url + api_suffix

if True:
    link_type = "ssh_url_to_repo"
else:
    link_type = "http_url_to_repo"

token_prefix = "private_token="
with open(os.path.expanduser("~/.gitlab")) as token_file:
    token_key = token_file.read().strip()
token = token_prefix + token_key


def get_resource(query):
    logging.info("Getting a resource")

    if '?' in query:
        full_uri = url + '/' + query + '&' + token
    else:
        full_uri = url + '/' + query + '?' + token

    logging.info(f"Full URI { full_uri.replace(token_key, '<TOKEN>') }")

    response = requests.get(full_uri)

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
    subgroups = []
    subgroups.extend(get_resource("groups/" + str(group_id) + "/subgroups"))
    subgroups.extend(get_resource("groups/" + str(group_id) + "/subgroups?all_available=true"))
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


class FSTree:
    def __init__(self, name='root', fstype='dir', children=None):
        self.name = name
        self.fstype = fstype
        self.children = []
        if children is not None:
            for child in children:
                self.add_child(child)

    def __repr__(self):
        return f"FSTree(name='{self.name}', fstype='{self.fstype}, children='{self.children}')"

    def __str__(self, level=0):
        ret = '  ' * level + self.name + ('/' if self.fstype == 'dir' else '')
        for child in self.children:
            ret += '\n' + child.__str__(level + 1)
        return ret

    def __eq__(self, other):
        if isinstance(other, FSTree):
            return self.name == other.name
        return False

    def __contains__(self, item):
        return len(list(filter(lambda child: child == item))) > 0

    def sort(self):
        for child in self.children:
            child.sort()
        self.children.sort(key=lambda n: n.name)

    def add_child(self, node):
        assert isinstance(node, FSTree)

        if node in self.children:
            return list(filter(lambda child: child == node, self.children))[0]
        else:
            self.children.append(node)
            return self.children[-1]


def construct_project_tree(projects):
    tree = FSTree()
    for project in projects:
        pathname = project.split(sep=":")[1]
        if pathname.endswith('.git'):
            pathname = pathname[:-4]
        path_hierarchy = pathname.split('/')

        dir_path, project_name = path_hierarchy[:-1], path_hierarchy[-1]
        logging.info(f"Handling project {project_name}")

        cur_root = tree
        for dir_name in dir_path:
            node = FSTree(dir_name)
            cur_root = cur_root.add_child(node)

        cur_root.add_child(FSTree(project_name, fstype='file'))

    tree.sort()
    return tree


def main(args):
    if args.debug:
        logging.basicConfig(level=logging.DEBUG)
    elif args.info:
        logging.basicConfig(level=logging.INFO)
    else:
        logging.basicConfig(level=logging.WARNING)

    group_basename = args.group.split('/')[-1]

    all_groups = []
    all_groups.extend(get_resource('groups?all_available=true&search=' + group_basename))
    if '/' in args.group:
        all_groups.extend(get_resource('groups?search=' + group_basename))

    retrieved_groups = list(filter(lambda e: e['full_path'] == args.group, all_groups))
    if not retrieved_groups:
        logging.error("No groups found")
        exit(1)

    if len(retrieved_groups) > 1:
        logging.error("Multiple groups found matching name")
        logging.error(retrieved_groups)
        exit(1)

    root_group = retrieved_groups[0]['id']
    logging.info(f"Checking group with id {root_group}")
    projects = get_projects(root_group)

    print(*projects, sep="\n")
    tree = construct_project_tree(projects)
    print(str(tree))


if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(
        description='Manage Multiple Repositories under Gitlab Groups')
    PARSER.add_argument(
        'group',
        nargs='?',
        help='full group path (e.g. literal "gitlab-org/ci-cd"')
    log_level = PARSER.add_mutually_exclusive_group()
    log_level.add_argument(
        '--debug',
        action='store_true',
        help='enable all logs')
    log_level.add_argument(
        '--info',
        action='store_true',
        help='enable info and above logs')
    ARGS = PARSER.parse_args()

    main(ARGS)
