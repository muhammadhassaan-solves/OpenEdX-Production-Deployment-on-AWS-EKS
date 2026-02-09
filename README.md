<h1>OpenEdX Deployment on Kubernetes (AWS EKS) </h1>
<h2>Description</h2>
This repository contains the implementation and deployment artifacts for running Open edX in a production-grade AWS EKS environment. The deployment is done using Tutor (latest stable), while meeting enterprise requirements around security, scalability, observability, externalized data services, and operational discipline.

<h2>Architecture diagram</h2>
<img src="https://i.postimg.cc/15NtHq2m/image.png"/>

<h2>AWS VPC Architecture & Network Flow Diagram</h2>
<img src="https://i.postimg.cc/9fN0bYm0/image.png"/>
<h2>Proof of Implementation & Step-by-step deployment guide</h2>

<p align="center">
1. Launch Amazon EKS Cluster with Infrastructure as Code (Terraform)<br />
<img src="https://i.postimg.cc/vHHmJK47/image.png"/>
<br />
<br />
2. Prepare Python Environment (Tutor Installation)  <br/>
<img src="https://i.postimg.cc/T11Z9nP5/image.png" />
<br />
<br />
3. Initialize Tutor Configuration and Disable Internal Databases (Use AWS Managed Services)<br/>
<img src="https://i.postimg.cc/0rgcwSML/image.png"/>
<br />
<br />
4. Launch External AWS RDS, AWS DocumentDB, AWS ElastiCache, and AWS OpenSearch <br/>
<img src="https://i.postimg.cc/NMq6btfk/Screenshot-2026-02-09-015158.png" />
<img src="https://i.postimg.cc/sXjX3HTN/image.png" />
<img src="https://i.postimg.cc/85X1NpJJ/image.png" />
<img src="https://i.postimg.cc/c18H03hx/image.png" />
<br />
<br />
5. Configure External AWS RDS, AWS DocumentDB, AWS ElastiCache, and AWS OpenSearch <br/>
<img src="https://i.postimg.cc/bJrZQF1N/configre.png" />
<br />
<br />
6. Configure LMS and CMS Domain Names and launch Open edX on Kubernetes (EKS) <br/>
<img src="https://i.postimg.cc/bJPhPGNC/image.png" />
<br />
<br />
7. Expose Open edX Publicly (/ Nginx Ingress / Cert Manager for TLS Termination at Nginx Level / Application Load Balancer ) <br/>
<img src="https://i.postimg.cc/25K0dMPN/image.png" />
<br />
<br />
8. DNS Mapping using Route 53 and Certificate from Certifcate Manager <br/>
<img src="https://i.postimg.cc/DfjwrgzG/image.png" />
<img src="https://i.postimg.cc/zf2qCDzY/image.png" />
<br />
<br />
9. Configure AWS Cloudfront (CDN) with AWS WAF Integration (Including Rate Limiting and DDoS protection) <br/>
<img src="https://i.postimg.cc/ryQN5vW9/cloud.png" />
<br />
<br />
10. Add more required managed rules on AWS WAF (Web Application Firewall)
<img src="https://i.postimg.cc/d10LFS1T/image.png" />
<br />
<br />
11. Configure and Load test Horizontal Pod Autoscaler (HPA) for LMS and CMS 
<img src="https://i.postimg.cc/TPHFSPH8/image.png" />
<br />
<br /> 
12. Configure Persistent Volumes (PV/PVC) using Amazon EFS for uploads and media
<img src="https://i.postimg.cc/VkdwYQBy/image.png" />
<br />
<br />
13. Deploy Prometheus + Grafana Monitoring Stack (kube-prometheus-stack) for Observability & Alerting
<img src="https://i.postimg.cc/wBwDDNRz/image.png" />
<br />
<br />

Live Deployment URLs
- LMS (Student Portal): https://lms.alrafi.org  
- CMS / Studio (Course Authoring): https://studio.alrafi.org
