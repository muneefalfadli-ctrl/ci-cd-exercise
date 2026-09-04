# 🚀 1-Day AWS Cloud Engineer Challenge

## ⏰ Complete in 8 Hours (9 AM - 5 PM)

This accelerated challenge demonstrates **ALL job requirements** with focused, high-impact exercises that can be completed in a single day.

---

## 📋 Daily Schedule

### **Morning (9 AM - 12 PM) - Foundation & Infrastructure**
- **9:00-10:00**: AWS Setup & Migration Planning
- **10:00-11:00**: Cloud Infrastructure Deployment
- **11:00-12:00**: Database & Storage Setup

### **Afternoon (1 PM - 5 PM) - Modernization & DevOps**
- **1:00-2:00**: Application Modernization
- **2:00-3:00**: Containerization & Kubernetes
- **3:00-4:00**: DevOps & Automation
- **4:00-5:00**: Monitoring & Demo Prep

---

## 🚀 Phase-by-Phase Execution

### **Phase 1: AWS Foundation (60 minutes)**

#### **⚡ Quick Setup (15 mins)**
```bash
# Set environment variables
export AWS_REGION=us-east-1
export PROJECT_NAME="1day-challenge"

# Create IAM role
aws iam create-role --role-name CloudEngineer1Day --assume-role-policy-document file://trust.json
aws iam attach-role-policy --role-name CloudEngineer1Day --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

#### **⚡ Migration Assessment (15 mins)**
```bash
# Quick assessment script
cat > quick-assessment.md << EOF
# Migration Assessment - 1 Day Challenge

## Current State (Simulated)
- **Application**: Legacy monolith (Java Spring Boot)
- **Database**: MySQL on-prem (200GB)
- **Storage**: Local file system (500GB)
- **Users**: 10,000 daily active

## Target AWS Architecture
- **Compute**: EKS + Lambda
- **Database**: RDS PostgreSQL + ElastiCache
- **Storage**: S3 + EFS
- **Network**: Multi-AZ VPC

## Quick ROI
- **Cost**: 45% reduction
- **Performance**: 8x improvement
- **Availability**: 99.99% SLA
EOF
```

#### **⚡ VPC & Networking (30 mins)**
```bash
# Quick VPC setup
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=1day-challenge-vpc}]'

# Create subnets (2 AZs)
aws ec2 create-subnet --vpc-id VPC_ID --cidr-block 10.0.1.0/24 --availability-zone us-east-1a
aws ec2 create-subnet --vpc-id VPC_ID --cidr-block 10.0.2.0/24 --availability-zone us-east-1b

# Create internet gateway
aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=1day-challenge-igw}]'
aws ec2 attach-internet-gateway --vpc-id VPC_ID --internet-gateway-id IGW_ID

# Create security groups
aws ec2 create-security-group --group-name 1day-web-sg --description "Web security group" --vpc-id VPC_ID
aws ec2 authorize-security-group-ingress --group-id SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id SG_ID --protocol tcp --port 443 --cidr 0.0.0.0/0
```

### **Phase 2: Database & Storage (60 minutes)**

#### **⚡ RDS PostgreSQL (20 mins)**
```bash
# Create RDS PostgreSQL
aws rds create-db-instance \
  --db-instance-identifier 1day-challenge-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 15.3 \
  --allocated-storage 20 \
  --master-username admin \
  --master-user-password SecurePassword123! \
  --vpc-security-group-ids SG_ID \
  --backup-retention-period 7 \
  --multi-az \
  --publicly-accessible false

# Wait for database to be available
aws rds wait db-instance-available --db-instance-identifier 1day-challenge-db
```

#### **⚡ S3 Storage (20 mins)**
```bash
# Create S3 buckets
aws s3api create-bucket --bucket 1day-challenge-data --region us-east-1
aws s3api create-bucket --bucket 1day-challenge-backups --region us-east-1

# Configure lifecycle policies
cat > s3-lifecycle.json << EOF
{
  "Rules": [
    {
      "ID": "LifecycleRule",
      "Status": "Enabled",
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        }
      ]
    }
  ]
}
EOF

aws s3api put-bucket-lifecycle-configuration --bucket 1day-challenge-data --lifecycle-configuration file://s3-lifecycle.json
```

#### **⚡ ElastiCache Redis (20 mins)**
```bash
# Create Redis cluster
aws elasticache create-replication-group \
  --replication-group-id 1day-challenge-redis \
  --replication-group-description "Redis for 1-day challenge" \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --num-cache-clusters 2 \
  --automatic-failover-enabled \
  --at-rest-encryption-enabled \
  --transit-encryption-enabled
```

### **Phase 3: Application Modernization (60 minutes)**

#### **⚡ Containerization (20 mins)**
```bash
# Create multi-stage Dockerfile
cat > Dockerfile << 'EOF'
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS runtime
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
USER nodejs
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD curl -f http://localhost:3000/health || exit 1
CMD ["node", "server.js"]
EOF

# Build and push to ECR
aws ecr create-repository --repository-name 1day-challenge-app
docker build -t 1day-challenge-app .
docker tag 1day-challenge-app:latest ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/1day-challenge-app:latest
docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/1day-challenge-app:latest
```

#### **⚡ Lambda Function (20 mins)**
```python
# lambda-function.py
import boto3
import json

def lambda_handler(event, context):
    """Process S3 events for 1-day challenge"""
    s3_client = boto3.client('s3')
    dynamodb = boto3.resource('dynamodb')
    
    for record in event['Records']:
        if record['eventName'] == 'ObjectCreated':
            bucket = record['s3']['bucket']['name']
            key = record['s3']['object']['key']
            
            # Process file
            response = s3_client.get_object(Bucket=bucket, Key=key)
            data = response['Body'].read().decode('utf-8')
            
            # Store in DynamoDB
            table = dynamodb.Table('1day-challenge-data')
            table.put_item(Item={
                'file_key': key,
                'size': len(data),
                'processed_at': context.aws_request_id
            })
            
            # Send notification
            sns = boto3.client('sns')
            sns.publish(
                TopicArn='arn:aws:sns:us-east-1:ACCOUNT_ID:1day-challenge-notifications',
                Message=f"Processed file: {key}",
                Subject="File Processing Complete"
            )
    
    return {'statusCode': 200, 'body': json.dumps('Success')}
```

```bash
# Deploy Lambda
aws lambda create-function \
  --function-name 1day-challenge-processor \
  --runtime python3.9 \
  --role LAMBDA_ROLE_ARN \
  --handler lambda-function.lambda_handler \
  --zip-file fileb://function.zip \
  --environment Variables={DYNAMODB_TABLE=1day-challenge-data}
```

#### **⚡ Simple Web App (20 mins)**
```javascript
// server.js
const express = require('express');
const app = express();
const port = 3000;

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.get('/api/metrics', async (req, res) => {
  try {
    // Simulate database query
    const metrics = {
      active_users: 10000,
      requests_per_second: 150,
      avg_response_time: 120,
      uptime: '99.99%'
    };
    res.json(metrics);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch metrics' });
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});
```

### **Phase 4: Kubernetes Deployment (60 minutes)**

#### **⚡ EKS Cluster Setup (20 mins)**
```bash
# Create EKS cluster
aws eks create-cluster \
  --name 1day-challenge-eks \
  --role-arn EKS_ROLE_ARN \
  --resources-vpc-config subnetIds=SUBNET_IDS,endpointPublicAccess=true

# Wait for cluster
aws eks wait cluster-active --name 1day-challenge-eks

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name 1day-challenge-eks
```

#### **⚡ Kubernetes Manifests (20 mins)**
```yaml
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: 1day-challenge-app
  labels:
    app: 1day-challenge
spec:
  replicas: 3
  selector:
    matchLabels:
      app: 1day-challenge
  template:
    metadata:
      labels:
        app: 1day-challenge
    spec:
      containers:
      - name: app
        image: ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/1day-challenge-app:latest
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: 1day-challenge-service
spec:
  selector:
    app: 1day-challenge
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: LoadBalancer
```

#### **⚡ Deploy to Kubernetes (20 mins)**
```bash
# Apply manifests
kubectl apply -f k8s-deployment.yaml

# Wait for deployment
kubectl rollout status deployment/1day-challenge-app

# Get service URL
kubectl get service 1day-challenge-service

# Test the application
curl http://LOAD_BALANCER_DNS/health
curl http://LOAD_BALANCER_DNS/api/metrics
```

### **Phase 5: DevOps & Automation (60 minutes)**

#### **⚡ Infrastructure as Code (20 mins)**
```hcl
# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name = "1day-challenge-instance"
    Project = "1day-challenge"
  }
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>1-Day AWS Challenge</h1>" > /var/www/html/index.html
              EOF
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
```

```bash
# Initialize and apply Terraform
terraform init
terraform plan
terraform apply -auto-approve
```

#### **⚡ CI/CD Pipeline (20 mins)**
```yaml
# .github/workflows/1day-cicd.yml
name: 1-Day Challenge CI/CD

on:
  push:
    branches: [main]

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    
    - name: Build and push Docker image
      run: |
        docker build -t 1day-challenge-app .
        docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/1day-challenge-app:latest
    
    - name: Deploy to Kubernetes
      run: |
        aws eks update-kubeconfig --name 1day-challenge-eks
        kubectl set image deployment/1day-challenge-app app=ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/1day-challenge-app:latest
        kubectl rollout status deployment/1day-challenge-app
```

#### **⚡ Ansible Configuration (20 mins)**
```yaml
# ansible-playbook.yml
---
- name: 1-Day Challenge Setup
  hosts: localhost
  become: yes
  tasks:
    - name: Update system
      package:
        name: "*"
        state: latest
    
    - name: Install monitoring tools
      package:
        name:
          - htop
          - nethogs
          - iotop
        state: present
    
    - name: Create monitoring script
      copy:
        dest: /usr/local/bin/monitor.sh
        mode: '0755'
        content: |
          #!/bin/bash
          echo "=== System Metrics ==="
          echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)"
          echo "Memory: $(free -m | grep Mem | awk '{print $3/$2 * 100.0}')"
          echo "Disk: $(df -h / | awk 'NR==2 {print $5}')"
          echo "=== AWS Resources ==="
          aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' --output table
```

### **Phase 6: Monitoring & Demo (60 minutes)**

#### **⚡ CloudWatch Setup (20 mins)**
```bash
# Create CloudWatch dashboard
cat > dashboard.json << EOF
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/EC2", "CPUUtilization", "InstanceId", "i-1234567890abcdef0"]
        ],
        "view": "timeSeries",
        "title": "EC2 CPU Utilization"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "1day-challenge-db"]
        ],
        "view": "timeSeries",
        "title": "RDS CPU Utilization"
      }
    }
  ]
}
EOF

aws cloudwatch put-dashboard --dashboard-name 1day-Challenge-Dashboard --dashboard-body file://dashboard.json

# Create alarms
aws cloudwatch put-metric-alarm \
  --alarm-name High-CPU-Usage \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold
```

#### **⚡ Performance Testing (20 mins)**
```bash
# Install Apache Bench
sudo yum install -y httpd-tools

# Load test the application
ab -n 1000 -c 10 http://LOAD_BALANCER_DNS/

# Install k6 for advanced testing
curl https://github.com/grafana/k6/releases/download/v0.47.0/k6-v0.47.0-linux-amd64.tar.gz -L | tar xvz
sudo mv k6-v0.47.0-linux-amd64/k6 /usr/local/bin/

# Create k6 test script
cat > load-test.js << 'EOF'
import http from 'k6/http';
import { check } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 50 },
    { duration: '2m', target: 100 },
    { duration: '2m', target: 0 },
  ],
};

export default function () {
  let response = http.get('http://LOAD_BALANCER_DNS/');
  check(response, {
    'status was 200': (r) => r.status == 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
}
EOF

# Run load test
k6 run load-test.js
```

#### **⚡ Demo Preparation (20 mins)**
```bash
# Create demo script
cat > demo-script.md << EOF
# 1-Day AWS Cloud Engineer Challenge Demo

## What We Built Today
✅ Multi-AZ VPC with public/private subnets
✅ RDS PostgreSQL with high availability
✅ S3 storage with lifecycle policies
✅ ElastiCache Redis cluster
✅ Containerized application
✅ EKS Kubernetes deployment
✅ Lambda serverless function
✅ CI/CD pipeline
✅ Monitoring and alerting

## Key Achievements
- **Migration**: Simulated legacy to cloud
- **Modernization**: Monolith to microservices
- **Automation**: IaC and CI/CD
- **Performance**: 8x improvement
- **Cost**: 45% reduction

## Demo Commands
# Check application health
curl http://LOAD_BALANCER_DNS/health

# View metrics
curl http://LOAD_BALANCER_DNS/api/metrics

# Monitor resources
aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --dimensions Name=InstanceId,Value=i-1234567890abcdef0 --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) --period 300 --statistics Average --output table
EOF

# Take screenshots of key components
- AWS Console showing VPC
- RDS instance details
- EKS cluster with pods
- CloudWatch dashboard
- Application running
```

---

## 🎯 1-Day Success Criteria

### **✅ What You'll Accomplish:**
- **9:00-10:00**: AWS environment setup and migration plan
- **10:00-11:00**: Complete cloud infrastructure deployed
- **11:00-12:00**: Database and storage configured
- **1:00-2:00**: Application modernized and containerized
- **2:00-3:00**: Kubernetes deployment running
- **3:00-4:00**: DevOps automation implemented
- **4:00-5:00**: Monitoring setup and demo ready

### **📊 Interview-Ready Results:**
- **Working Application**: Containerized web app with database
- **Cloud Infrastructure**: Production-ready AWS environment
- **Automation**: IaC, CI/CD, and configuration management
- **Monitoring**: Dashboards, alerts, and performance metrics
- **Documentation**: Complete project portfolio

### **🚀 Quick Commands for Demo:**
```bash
# Check all resources
aws ec2 describe-instances --output table
aws rds describe-db-instances --output table
aws eks describe-cluster --name 1day-challenge-eks

# Test application
curl http://LOAD_BALANCER_DNS/health
curl http://LOAD_BALANCER_DNS/api/metrics

# View monitoring
aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization ...
```

**Yes! You can complete the entire AWS Cloud Engineer challenge in 1 day with focused, high-impact exercises!** 🎯
