# Ansible Playbooks — CI/CD Project

## Prerequisites

Install required Ansible collections on the **control node**:

```bash
ansible-galaxy collection install community.docker
```

The `amazon.aws` collection is already installed (used by the EC2 inventory plugin).

## Playbooks

### `playbook_web_server.yml`
Targets **AWS EC2 instances** (inventory: `aws_ec2` plugin). Deploys a Dockerised nginx web application:

1. Updates/upgrades system packages
2. Installs Docker, Git, and the Docker Python SDK
3. Clones the `ci_cd_project` repository from GitHub
4. Builds a Docker image (`dbs_web_app`) from the repo's Dockerfile
5. Runs a container on port 80
6. Verifies the web server responds with HTTP 200

Run:
```bash
ansible-playbook -i inventory/aws_ec2.yml playbook_web_server.yml
```

### `docker_webapp.yml`
Targets **localhost**. Generates a Dockerfile for the web application (alternative workflow, no EC2 needed).

Run:
```bash
ansible-playbook docker_webapp.yml
```
