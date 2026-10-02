# DevOps Portfolio: Flask + Multi-stage Docker + AWS ECR

**Author:** Nasir Mehmood, Junior DevOps Engineer (Open to Work)

## 1. Project ka maqsad
Ek simple Python website banana jo:
1. Flask se chalti ho aur frontend page par poora project mention kare.
2. Multi-stage Dockerfile se build ho.
3. Docker image AWS ECR (Elastic Container Registry) mein push ho.

## 2. Folder structure
```
devops-portfolio/
├── app.py               # Flask app (/ aur /health)
├── templates/index.html # Frontend page
├── requirements.txt     # Python dependencies
├── Dockerfile           # Multi-stage build
├── .dockerignore
├── push-to-ecr.sh       # ECR push automation
└── DOCUMENTATION.md
```

## 3. App ka code (app.py)
- `/` route `index.html` render karta hai, jis mein naam, role aur "Open to Work" badge hai.
- `/health` route `{"status":"ok"}` deta hai (load balancer / health check ke liye).
- Naam, role aur status `PROFILE` dictionary mein hain. Wahan se badal sakte hain.

## 4. Multi-stage Docker kya hota hai?
Ek Dockerfile mein ek se zyada `FROM` hote hain. Pehle stage mein build ka kaam hota hai, aur final image mein sirf wo cheezein jaati hain jo run ke liye chahiye.

| Stage | Kaam |
|---|---|
| `builder` | venv banata hai, `pip install` karta hai |
| `runtime` | builder se sirf `/opt/venv` copy karta hai, app code add karta hai, non-root user se gunicorn chalata hai |

**Fayde:** chhoti image, kam attack surface, build tools production image mein nahi, non-root user se zyada safety.

## 5. Local par chalana
```bash
docker build -t devops-portfolio .
docker run -p 5000:5000 devops-portfolio
```
Browser mein kholein: http://localhost:5000

Image ka size dekhne ke liye: `docker images devops-portfolio`

## 6. AWS ECR par push karna

### Pehle se zaroori
- AWS account aur IAM user/role jis ke paas ECR permissions hon (jaise `AmazonEC2ContainerRegistryPowerUser`)
- AWS CLI install ho aur `aws configure` ho chuka ho
- Docker install aur running ho

### Option A: script se (asaan)
```bash
export AWS_REGION=ap-south-1     # apna region
export REPO_NAME=devops-portfolio
./push-to-ecr.sh v1
```
Script ye karta hai: account ID nikalta hai, repo na ho to banata hai, ECR login, build, tag aur push.

### Option B: manual commands
```bash
aws ecr create-repository --repository-name devops-portfolio --region REGION
aws ecr get-login-password --region REGION | \
  docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com
docker build -t devops-portfolio .
docker tag devops-portfolio:latest ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/devops-portfolio:latest
docker push ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/devops-portfolio:latest
```
`REGION` aur `ACCOUNT_ID` apni values se badlein.

### Verify
```bash
aws ecr describe-images --repository-name devops-portfolio --region REGION
```
Ya AWS Console mein ECR > Repositories > devops-portfolio mein image dekhein.

## 7. ECR se image pull karke chalana
```bash
aws ecr get-login-password --region REGION | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com
docker run -p 5000:5000 ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/devops-portfolio:latest
```

## 8. Aam masail
| Masla | Hal |
|---|---|
| `no basic auth credentials` | ECR login command dobara chalayein (token 12 ghante mein expire hota hai) |
| `AccessDenied` | IAM user ko ECR permissions dein |
| `repository does not exist` | Pehle `create-repository` chalayein |
| Port 5000 busy | `-p 8080:5000` use karein |

## 9. Aage ke steps (optional)
- GitHub Actions se automatic build aur ECR push
- ECS Fargate ya EKS par deploy
- Terraform se ECR repo banana
- Image tag mein git commit SHA use karna

## 10. Interview talking points
- Multi-stage build kyun: image chhoti aur secure.
- Non-root user kyun: container breakout ka risk kam.
- `.dockerignore` kyun: build context chhota, secrets leak nahi.
- ECR `scanOnPush`: push par vulnerabilities scan hoti hain.
