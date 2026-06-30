# ci-cd-project / Terraform

Your infrastructure-as-code files for the CI/CD project. These files tell AWS exactly what servers, firewalls, and users to create.

## 📁 What each file does

| File | What it creates | For beginners: think of it as... |
|------|----------------|----------------------------------|
| `providers.tf` | Connects to AWS, sets region | Your passport — tells AWS who you are and where to build |
| `variables.tf` | Settings you can change | The control knobs — tweak without touching the engine |
| `iam.tf` | A dedicated IAM user with limited permissions | A limited employee badge — can do the job, can't delete the whole office |
| `security_groups.tf` | Firewall rules (what ports are open) | A bouncer at the door — only lets in who you want |
| `ec2.tf` | The virtual server (EC2 instance) | The actual computer running in AWS's data centre |
| `outputs.tf` | Useful info printed after every apply | The receipt — IP address, SSH command, etc. |
| `README.md` | This file | You're reading it! |

## 🔑 Before you start — generate your SSH key

Run this once on your machine (not in Terraform):

```bash
ssh-keygen -t ed25519 -f ~/.ssh/ci-cd-project-key -C "ci-cd-project-ec2"
```

This creates:
- `~/.ssh/ci-cd-project-key` → your **private** key (never share this!)
- `~/.ssh/ci-cd-project-key.pub` → your **public** key (Terraform uploads this to AWS)

## 🚀 One-time bootstrap (7 steps)

Terraform needs AWS credentials to run, but it also CREATES its own credentials — chicken-and-egg problem. Here's how to break the loop:

### Step 1 — Create a temporary admin user (in your browser)

Go to https://console.aws.amazon.com/ → IAM → Users → **Create user**
- Name: `terraform-bootstrap`
- Check ✅ **Provide user access to the AWS Management Console** → NO
- Check ✅ **Access key - Programmatic access**
- Attach policy: **AdministratorAccess**
- Create → Download the `.csv` file with the keys

> ⚠️ This user has FULL ACCESS — that's why we're creating a limited one in Step 3. Delete this user in Step 6.

### Step 2 — Configure your local machine with the temp keys

```bash
aws configure --profile terraform-bootstrap
# AWS Access Key ID:     [paste from Step 1's .csv]
# AWS Secret Access Key: [paste from Step 1's .csv]
# Default region:        eu-west-1
# Default output:        json

# Verify it works
aws sts get-caller-identity --profile terraform-bootstrap
# Should show: "Arn": "arn:aws:iam::123456789012:user/terraform-bootstrap"
```

### Step 3 — Apply Terraform (creates the real user)

```bash
cd ci_cd_project/terraform
terraform init
AWS_PROFILE=terraform-bootstrap terraform apply
```

Terraform creates:
- ✅ The `terraform_access` IAM user
- ✅ A limited permission policy (can only manage EC2, VPCs, etc.)
- ✅ An access key for the new user

### Step 4 — Save the secret key (do this NOW)

```bash
terraform output terraform_access_secret_key
```

Copy the secret key and save it somewhere safe (password manager, Bitwarden, etc.). **This is the only time you'll see it.**

### Step 5 — Switch to the new limited user

```bash
aws configure --profile terraform-access
# AWS Access Key ID:     [from: terraform output terraform_access_key_id]
# AWS Secret Access Key: [from Step 4]
# Default region:        eu-west-1
# Default output:        json

# Verify it works
AWS_PROFILE=terraform-access terraform plan
# Should show no changes (you already applied in Step 3)
```

### Step 6 — Delete the temp admin user

Back in the AWS Console → IAM → Users → find `terraform-bootstrap`
- Check the box next to it → **Delete**
- Confirm deletion

Now your AWS account has NO full-admin users with access keys. Safer!

### Step 7 — Done! Set your daily-use profile

```bash
export AWS_PROFILE=terraform-access
```

Or add that line to your `~/.bashrc` so it's always on.

## 💻 Daily commands

Once bootstrap is done, these are the commands you'll actually use:

```bash
# See what Terraform WOULD change (safe — doesn't actually do anything)
cd ci_cd_project/terraform
terraform plan

# Apply changes (this actually creates/updates stuff in AWS)
terraform apply

# Destroy everything (runs up a bill if you forget!)
terraform destroy

# Get your server's IP address
terraform output public_ip
```

## ❓ Troubleshooting

| Problem | Likely cause | Fix |
|---------|-------------|-----|
| `No valid credential sources found` | AWS not configured | Run `aws configure --profile terraform-access` |
| `Error creating IAM user: EntityAlreadyExists` | Ran bootstrap twice | The user already exists — run Step 5 instead |
| `ssh: connect to host ... Connection refused` | Server still booting | Wait 60 seconds, try again |
| `terraform apply` wants to recreate everything | State file lost | You deleted `.tfstate`. Run `terraform init` first. |
| Billing surprise | Forgot to `terraform destroy` | Set up a $5 billing alert in AWS Console |

## 🧹 Cleanup when done

When the project is over, destroy everything:

```bash
cd ci_cd_project/terraform
terraform destroy
```

This deletes EC2, security groups, the VPC, and the IAM user. Your AWS account goes back to empty.
