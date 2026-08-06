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

Solo 2 secrets. Ve a **Settings → Secrets and variables → Actions** y creá:

| Secret | Valor | Cómo obtenerlo |
|--------|-------|----------------|
| `DOCKERHUB_TOKEN` | Access Token de Docker Hub | [hub.docker.com/settings/security](https://hub.docker.com/settings/security) → New Access Token (permiso Read/Write/Delete) |
| `RENDER_DEPLOY_HOOK_URL` | URL secreta del Deploy Hook | Render Dashboard → tu servicio web → **Settings** → **Deploy Hook** → copiá la URL (empieza con `https://api.render.com/deploy/srv-…?key=…`) |

**Tip de seguridad:** esa URL es una credencial — cualquiera que la tenga puede redeploy. El secreto está hasheado en los logs y solo se imprime si lo necesitás para debug.

### 🚀 Setup paso a paso

```bash
# 1. (Ya hecho) Repo creado y pusheado
#    https://github.com/Eliasgtr/practicaDevops

# 2. Crear cuenta en Render (gratis, sin tarjeta)
#    https://dashboard.render.com/register

# 3. Crear el servicio web:
#    - New + → Web Service
#    - Conectar repo Eliasgtr/practicaDevops
#    - Render detecta render.yaml automáticamente
#    - Apply → esperar primer deploy

# 4. Obtener el Deploy Hook URL:
#    - Una vez creado el servicio, abrirlo
#    - Settings → Deploy Hook
#    - Copiar la URL (NO la compartas)

# 5. Crear el Access Token de Docker Hub:
#    - https://hub.docker.com/settings/security
#    - New Access Token (Read/Write/Delete)
#    - Copiar el token

# 6. Configurar los 2 secrets en GitHub:
#    https://github.com/Eliasgtr/practicaDevops/settings/secrets/actions
#    - New repository secret → DOCKERHUB_TOKEN → pegar token
#    - New repository secret → RENDER_DEPLOY_HOOK_URL → pegar URL

# 7. Probar (¡dispará el primer deploy!):
git commit --allow-empty -m "ci: trigger first pipeline run"
git push origin main
```

### 🔄 Flujo del pipeline (lo que pasa cuando hacés push a `main`)

```
push a main
    │
    ▼
Job 1: build  ─────────────────────────► docker-push
    │                                          │
    │                                          ▼
    │                              eliasruiz09/hola-mundo-devops:latest
    │                              eliasruiz09/hola-mundo-devops:1.0.0 (si tag)
    ▼
Job 2: deploy ─────────────────────────► POST Deploy Hook URL
                                               │
                                               ▼
                                      Render hace rebuild
                                      (reusa la imagen cacheada)
```

### 📊 Triggers y tags generados

| Evento | Tags Docker generados |
|--------|----------------------|
| Push a `main` | `eliasruiz09/hola-mundo-devops:latest` |
| Push de tag `v1.2.3` | `eliasruiz09/hola-mundo-devops:1.2.3` + `1.2` + `latest` |
| Pull request | Solo build (no push) |
| Workflow manual | Solo deploy (workflow_dispatch) |
