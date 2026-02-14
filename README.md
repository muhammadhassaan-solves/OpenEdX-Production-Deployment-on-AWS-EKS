<h1>OpenEdX Deployment on Kubernetes (AWS EKS) </h1>
<h2>Description</h2>
This repository contains the implementation and deployment artifacts for running Open edX in a production-grade AWS EKS environment. The deployment is done using Tutor (latest stable), while meeting enterprise requirements around security, scalability, observability, externalized data services, and operational discipline.

<h2>Architecture diagram</h2>
<img src="https://i.postimg.cc/15NtHq2m/image.png"/>

<h2>AWS VPC Architecture & Network Flow Diagram</h2>
<img src="https://i.postimg.cc/9fN0bYm0/image.png"/>
<h2>Proof of Implementation & Step-by-step deployment guide</h2>

<p align="center">
1. Launch Amazon EKS Cluster with remote backend enabled Infrastructure as Code (Terraform) <br />
<img src="https://i.postimg.cc/vHHmJK47/image.png"/>
<br />
<br />
2. Launch External AWS RDS, AWS DocumentDB, and AWS ElastiCache <br/>
<img src="https://i.postimg.cc/NMq6btfk/Screenshot-2026-02-09-015158.png" />
<img src="https://i.postimg.cc/sXjX3HTN/image.png" />
<img src="https://i.postimg.cc/85X1NpJJ/image.png" />
<br />
<br />
3. Disable Internal DBs and Implement External Databases (AWS Managed)<br/>
<img src="https://i.postimg.cc/qBb7W7S8/image.png"/>
<br />
<br />
4. Launch Open edX on Kubernetes (EKS) using Tutor <br/>
<img src="https://i.postimg.cc/bJPhPGNC/image.png" />
<br />
<br />
5. Expose Open edX Publicly (/ Nginx Ingress / Cert Manager for TLS Termination at Nginx Level / Application Load Balancer ) <br/>
<img src="https://i.postimg.cc/25K0dMPN/image.png" />
<br />
<br />
6. DNS Mapping using Route 53 and Certificate from Certifcate Manager <br/>
<img src="https://i.postimg.cc/DfjwrgzG/image.png" />
<img src="https://i.postimg.cc/zf2qCDzY/image.png" />
<br />
<br />
7. Configure AWS Cloudfront (CDN) with AWS WAF Integration (Including Rate Limiting and DDoS protection) <br/>
<img src="https://i.postimg.cc/ryQN5vW9/cloud.png" />
<br />
<br />
8. Configure and Load test Horizontal Pod Autoscaler (HPA) for LMS and CMS 
<img src="https://i.postimg.cc/TPHFSPH8/image.png" />
<br />
<br /> 
9. Configure and verify Persistent Volumes (PV/PVC) using Amazon EBS for uploads and media 
<img src="https://i.postimg.cc/zBPVwXrr/pvc-requirement.png" />
<br />
<br />
10. Deploy Prometheus + Grafana Monitoring Stack (kube-prometheus-stack) for Observability & Alerting
<img src="https://i.postimg.cc/ZnbCp7nD/image.png" />
<br />
<br />
11. LMS with Launched Courses for Students 
<img src="https://i.postimg.cc/g2SrRHbM/image.png" />
<br />
<br />
12. Studio for Course Creators
<img src="https://i.postimg.cc/qqSjz3Mh/image.png" />
<br />
<br />
13. Perform load testing with Locust
<img src="https://i.postimg.cc/BvJ9qdVk/Screenshot-2026-02-15-022703.png" />
<br />
<br />

Live Deployment URLs
- LMS (Student Portal): https://lms.alrafi.org  
- CMS / Studio (Course Authoring): https://studio.alrafi.org
