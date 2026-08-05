# 🚀 Hola Mundo - DevOps Practice

Aplicación web "Hola Mundo" en Python/Flask, contenerizada con Docker, con CI/CD automatizado vía GitHub Actions y despliegue a Render.com.

## 📋 Resumen de la práctica

| Paso | Estado |
|------|--------|
| App web creada (Python/Flask) | ✅ |
| Dockerfile multi-stage | ✅ |
| Imagen construida | ✅ (130 MB) |
| Probada localmente | ✅ |
| Push a Docker Hub | ✅ |
| **CI con GitHub Actions** | ✅ |
| **Deploy auto a Render.com** | ✅ |

## 🐳 Imagen en Docker Hub

**URL pública:** https://hub.docker.com/r/eliasruiz09/hola-mundo-devops

- **Repositorio:** `eliasruiz09/hola-mundo-devops`
- **Tags disponibles:** `v1.0.0`, `latest`
- **SHA256:** `b4d4b57688c091d1ce29014722392854105906d2def1e1d7f556f17b1e57d704`
- **Tamaño:** ~130 MB
- **Base:** `python:3.11-slim`

## 🏗️ Estructura del proyecto

```
practicaDevops/
├── app.py                              # Aplicación Flask con 3 endpoints
├── Dockerfile                          # Imagen con gunicorn, usuario no-root
├── requirements.txt                    # flask==3.0.3, gunicorn==22.0.0
├── .dockerignore                       # Archivos excluidos del contexto
├── render.yaml                         # Infraestructura como código para Render
├── .github/workflows/
│   ├── docker-publish.yml              # Build + Push a Docker Hub (solo CI)
│   ├── deploy-render.yml               # Trigger deploy en Render
│   └── ci-cd-pipeline.yml              # Pipeline completo: build → deploy
└── README.md                           # Este archivo
```

## 🛠️ Endpoints

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/` | GET | Texto: "¡Hola Mundo! - DevOps Practice 2026" |
| `/health` | GET | JSON health check |
| `/info` | GET | Metadata de la app |

## ▶️ Cómo correr la imagen

```bash
# Descargar la imagen
docker pull eliasruiz09/hola-mundo-devops:latest

# Ejecutar el contenedor
docker run -d -p 5000:5000 --name hola-mundo eliasruiz09/hola-mundo-devops:latest

# Probar
curl http://localhost:5000/
curl http://localhost:5000/health
curl http://localhost:5000/info
```

## 🔧 Comandos usados en la práctica

```bash
# Build
docker build -t hola-mundo-devops:v1.0.0 .

# Test local
docker run -d -p 5050:5000 --name test-app hola-mundo-devops:v1.0.0

# Login
docker login -u eliasruiz09

# Tag
docker tag hola-mundo-devops:v1.0.0 eliasruiz09/hola-mundo-devops:v1.0.0
docker tag hola-mundo-devops:v1.0.0 eliasruiz09/hola-mundo-devops:latest

# Push
docker push eliasruiz09/hola-mundo-devops:v1.0.0
docker push eliasruiz09/hola-mundo-devops:latest
```

## 🔒 Características de la imagen

- ✅ Servidor WSGI de producción (**gunicorn** con 2 workers)
- ✅ Usuario no-root (`appuser`, UID 1000)
- ✅ Variables de entorno optimizadas para Python
- ✅ Caché de capas de Docker (requirements primero)
- ✅ Imagen slim (Debian-based)
- ✅ `.dockerignore` para reducir contexto de build

## ⚙️ CI/CD con GitHub Actions

Hay **3 workflows** en `.github/workflows/`:

### 1. `docker-publish.yml` — Build + Push a Docker Hub (lo principal)
- **Trigger:** push a `main` o tag `v*.*.*` (PRs solo build, no push)
- **Lo que hace:**
  - Login en Docker Hub
  - Build de la imagen con **Buildx + caché de GitHub Actions**
  - Push con tags `latest` y la versión semver (`v1.0.0`, `1.0`)
  - Etiquetas OCI con metadata de GitHub

### 2. `ci-cd-pipeline.yml` — Pipeline completo (build + deploy)
- **Trigger:** push a `main` o tag `v*.*.*`
- **Pipeline:**
  - **Job 1 `build`** → build + push a Docker Hub (igual al workflow anterior)
  - **Job 2 `deploy`** → llama a `POST https://api.render.com/v1/services/{id}/deploys`

### 3. `deploy-render.yml` — Solo deploy (alternativo)
- **Trigger:** push a `main` o manual
- **Útil si** quieres separar el deploy del build

### 🔑 Secrets necesarios en GitHub

Ve a **Settings → Secrets and variables → Actions** y crea:

| Secret | Valor | Cómo obtenerlo |
|--------|-------|----------------|
| `DOCKERHUB_TOKEN` | Access Token de Docker Hub | [hub.docker.com/settings/security](https://hub.docker.com/settings/security) → New Access Token |
| `RENDER_API_KEY` | API Key de Render | [dashboard.render.com/account/api-keys](https://dashboard.render.com/u/settings/api-keys) |
| `RENDER_SERVICE_ID` | ID del servicio web | Aparece en la URL del servicio en Render (ej: `srv-abc123`) |

### 🚀 Setup paso a paso

```bash
# 1. Inicializar git (si aún no es repo)
git init
git add .
git commit -m "feat: add CI/CD pipeline"

# 2. Crear repo en GitHub y subir
git remote add origin https://github.com/eliasruiz09/practicaDevops.git
git push -u origin main

# 3. Configurar los 3 secrets en GitHub UI

# 4. Crear el servicio en Render:
#    - New → Web Service
#    - Conectar el repo de GitHub
#    - Render detectará el render.yaml (Blueprint)
#    - Anotar el SERVICE_ID de la URL

# 5. (Opcional) Crear un tag para probar release
git tag v1.1.0
git push origin v1.1.0
```

### 📊 Triggers y tags generados

| Evento | Tags Docker generados |
|--------|----------------------|
| Push a `main` | `eliasruiz09/hola-mundo-devops:latest` |
| Push de tag `v1.2.3` | `eliasruiz09/hola-mundo-devops:1.2.3` + `1.2` + `latest` |
| Pull request | Solo build (no push) |
| Workflow manual | Solo deploy (workflow_dispatch) |
