# Terraform & Ansible Error Logs — CI/CD Project

> Raw error output captured from local reproduction, for reference in the report.
> Each entry shows whether it is already present in the CA1 report doc or new.

---

## 1. S3 Backend — No Valid Credential Sources

**Status:** ✅ Already in report (Section 3.6.1, lines 74-81)

This error occurs when Terraform cannot find AWS credentials during backend initialisation. It manifested in CI when credentials were defined at the step level instead of the job level.

```
╷
│ Error: No valid credential sources found
│
│ Please see https://developer.hashicorp.com/terraform/language/backend/s3
│ for more information about providing credentials.
│
│ Error: failed to refresh cached credentials, no EC2 IMDS role found,
│ operation error ec2imds: GetMetadata, request canceled, context deadline
│ exceeded
╵
```

---

## 2. Provider Version Lock Conflict

**Status:** ✨ New — not in the CA1 report. Could be added as a new subsection (e.g. 3.6.5).

Occurs when the Terraform lock file (.terraform.lock.hcl) pins a provider version that does not satisfy the version constraint in main.tf. This happened after the lock file was generated with provider ~> 5.0 and the constraint was later changed to ~> 6.0 (or vice versa) without running init -upgrade.

```
╷
│ Error: Failed to query available provider packages
│
│ Could not retrieve the list of available versions for provider
│ hashicorp/aws: locked provider registry.terraform.io/hashicorp/aws 6.52.0
│ does not match configured version constraint ~> 4.0; must use terraform
│ init -upgrade to allow selection of new versions
│
│ To see which modules are currently depending on hashicorp/aws and what
│ versions are specified, run the following command:
│     terraform providers
╵
```

---

## 3. Ansible — No Hosts Matched (Inventory Group Mismatch)

**Status:** ✨ New — not in the CA1 report. Could be added as a new subsection (e.g. 3.6.4 or 3.6.8).

The playbook targeted the group `aws_ec2` but the inventory file defined hosts under a different group name (or vice versa), causing Ansible to skip all plays.

```
[WARNING]: Could not match supplied host pattern, ignoring: aws_ec2

PLAY [Build and deploy Dockerised nginx web app on EC2] ************************
skipping: no hosts matched

PLAY RECAP *********************************************************************
```

---

## 4. Missing Required Terraform Variable

**Status:** ✨ New — not in the CA1 report. Could be added under 3.6.2 (credential/variable issues).

Occurs when a variable with no default value is not supplied via `-var`, `-var-file`, or environment variable. In CI this manifested when `TF_VAR_ssh_public_key` was not set before running terraform plan.

```
var.ssh_public_key
  SSH public key content for EC2 access

  Enter a value:
Error: No value for required variable

  on main.tf line 40:
  40: variable "ssh_public_key" {

The root module input variable "ssh_public_key" is not set, and has no
default value. Use a -var or -var-file command line argument to provide a
value for this variable.
```

---

## 5. Invalid AWS Profile

**Status:** ✨ New — not in the CA1 report. Could be added under 3.6.2.

Occurs when the AWS profile specified in the Terraform provider config (or the `AWS_PROFILE` environment variable) does not exist in the runner's credentials file.

```
Error: failed to get shared config profile, nonexistent
```

---

## 6. Terraform State Drift — Duplicate Resources on Apply

**Status:** ✅ Described in report (Section 3.6.1) but only in prose. The raw error text was not included.

Indicates Terraform tried to create resources that already exist in AWS because the CI runner had no knowledge of the locally-provisioned state. This is what the actual AWS API returns:

```
An error occurred (InvalidKeyPair.Duplicate) when calling the
ImportKeyPair operation: The key pair 'ansible-user' already exists

An error occurred (InvalidGroup.Duplicate) when calling the
CreateSecurityGroup operation: The security group 'webserver_access'
already exists
```

The inverse case (state claims resources exist but they have been destroyed) produces these errors, captured from the live account:

```
An error occurred (InvalidKeyPair.NotFound) when calling the
DescribeKeyPairs operation: The key pair 'ansible-user' does not exist

An error occurred (InvalidGroup.NotFound) when calling the
DescribeSecurityGroups operation: The security group 'webserver_access'
does not exist in default VPC 'vpc-02d00fa1370719c62'
```
