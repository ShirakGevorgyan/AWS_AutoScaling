AWS Auto Scaling Project 🚀
This project demonstrates the creation and configuration of a scalable AWS Auto Scaling infrastructure using Terraform and Bash scripting. The system dynamically adjusts the number of instances based on CPU load and sends email notifications when instances are launched or terminated. Additionally, it uses stress testing to simulate high CPU load, showcasing the Auto Scaling mechanism in action.

🌟 Key Features
Infrastructure as Code (IaC):
All AWS resources, including EC2, Auto Scaling Groups, and SNS, are created and managed using Terraform.
Dynamic Scaling:
Automatically adjusts the number of EC2 instances based on CloudWatch metrics (CPU utilization).
Email Notifications:
Leverages AWS SNS to send notifications for instance launch and termination events.
Stress Testing:
Utilizes the stress tool to simulate high CPU load, triggering the Auto Scaling mechanism.
Automation:
A Bash script automates the deployment, execution, and cleanup processes.
🛠️ Technologies Used
Terraform: To define and provision AWS resources.
AWS Services:
EC2: Elastic Compute Cloud for scalable compute capacity.
Auto Scaling Groups: To handle instance scaling dynamically.
SNS (Simple Notification Service): To send email notifications.
CloudWatch: To monitor metrics and trigger scaling.
Bash Scripting: Automates instance configuration and stress testing.
📂 Project Structure
AWS_AutoScaling/
├── terraform/
│ ├── main.tf # Main Terraform configuration for AWS resources
│ ├── variables.tf # Input variables for Terraform
│ ├── outputs.tf # Outputs from Terraform configuration
│ ├── provider.tf # AWS provider configuration
│ ├── data.tf # Data sources used in Terraform
│ ├── hashicorp_version.tf # Required Terraform version
│ ├── setup_script.sh # Bash script for instance configuration and stress testing
├── .gitignore # Ignored files for Git
├── install_and_run.sh # Script to automate Terraform execution
└── README.md # Project documentation

Terraform Automation Script 🛠️
This Bash script automates the initialization, application, and optional destruction of Terraform configurations for provisioning AWS infrastructure. It simplifies the deployment process and provides a seamless way to manage resources.

📋 Features of the Script
Terraform Installation Check:
Ensures Terraform is installed on the system before proceeding. If Terraform is not installed, the script exits with an error message.
Terraform Initialization:
Initializes the Terraform working directory to download provider plugins and prepare the configuration files for execution.
Terraform Apply:
Applies the Terraform configuration to create or update the AWS infrastructure.
Optional Resource Cleanup:
Prompts the user to decide whether to destroy the Terraform-managed resources after execution.
How It Works ⚙️
This section explains the core functionality and configuration of the AWS Auto Scaling Project, detailing how Terraform is used, stress testing is performed, and notifications are managed.

1. Terraform Configuration
The infrastructure is defined using the following Terraform files:

main.tf:
Configures the Auto Scaling Group, Launch Template, CloudWatch Alarms, and SNS notifications.
variables.tf:
Stores variable definitions to allow flexibility in resource configuration.
outputs.tf:
Defines outputs such as instance IDs and SNS topic ARNs to provide essential details after deployment.
provider.tf:
Sets up the AWS provider required for managing AWS resources with Terraform.
data.tf:
Fetches AWS-specific data, such as available regions, to ensure compatibility with the deployment.
2. Stress Testing
The setup_script.sh is automatically executed on every EC2 instance during launch. It performs the following steps:
Installs the stress tool on the instance.
Waits for 1 minute to ensure the instance is fully initialized.
Simulates high CPU load for 10 minutes, causing the CPU utilization to exceed the threshold, which triggers the Auto Scaling mechanism.
3. Auto Scaling
The Auto Scaling Group is configured to handle resource scaling dynamically:

Scale up:
Launches additional instances when CPU utilization exceeds 80%.
Scale down:
Terminates instances when CPU utilization drops below 20%.
4. Email Notifications
AWS SNS is integrated to notify users about scaling events. The notifications include:
Launch events: Sent whenever a new instance is created.
Termination events: Sent whenever an existing instance is terminated.
This section provides a clear overview of how the project operates, ensuring scalability, reliability, and real-time monitoring of the infrastructure.

Deployment Instructions 🧑‍💻
This section provides step-by-step instructions for deploying and testing the AWS Auto Scaling Project. Follow these steps to ensure the infrastructure is set up correctly and functions as expected.

1. Prerequisites
Before you begin, ensure the following are ready:

AWS Account:

Ensure you have access to the following AWS services:
EC2
Auto Scaling
SNS
CloudWatch
AWS CLI:

Install and configure the AWS CLI:
aws configure
Terraform:

Install Terraform on your local system:
sudo apt install terraform
Clone the Repository
git clone git@github.com:ShirakGevorgyan/AWS_AutoScaling.git
cd AWS_AutoScaling

Deploy the Infrastructure
Run the provided Bash script to initialize and apply the Terraform configuration:

bash install_and_run.sh
This script will:

Initialize Terraform.
Apply the Terraform configuration.
Prompt you to destroy the infrastructure after testing.

⚙️ Workflow and Testing
Terraform Configuration
Provisions Auto Scaling Groups, Launch Templates, CloudWatch Alarms, and SNS topics.

Stress Testing
The setup_script.sh is executed on each EC2 instance:
1. Installs the stress tool.
2. Simulates high CPU load for 10 minutes.
3. Triggers scaling events (scale up/down) based on CPU utilization.

Auto Scaling Events
Scaling Up: Launches new instances when CPU utilization exceeds 50%.
Scaling Down: Terminates instances when CPU utilization drops below 20%.

Notifications
AWS SNS Integration: Sends email alerts for:
Launch Events: When a new instance is created.
Termination Events: When an instance is terminated.

📧 Email Notifications
Example Notifications
Launch Event:
Subject: EC2 Instance Launched
Body: A new EC2 instance has been launched with ID: i-12345678.
CPU utilization: 55%.
Timestamp: 2025-01-21 14:00:00 UTC.
Termination Event:
Subject: EC2 Instance Terminated
Body: An EC2 instance has been terminated with ID: i-87654321.
Reason: CPU utilization below threshold (20%).
Timestamp: 2025-01-21 15:30:00 UTC.

🔍 Testing the Auto Scaling and Notifications
Simulating High CPU Load
Once an instance is launched, the setup_script.sh:
Installs and starts the stress tool.
Generates CPU load for 10 minutes, which triggers scaling.
Receiving Notifications
Email notifications are sent whenever:
A new instance is launched.
An existing instance is terminated.
Verifying Scaling
Use the AWS Management Console to verify:
Instances being launched or terminated.
Notifications sent via SNS.

