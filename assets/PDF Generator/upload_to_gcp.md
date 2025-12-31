# 🚀 Deploy to Google Cloud Run - Complete Tutorial

---

## 📋 Project Information

| Field            | Value                 |
| ---------------- | --------------------- |
| **Project ID**   | `azimuth-menu`        |
| **Region**       | `europe-west1`        |
| **Service Name** | `volunteer-register`  |
| **Registry**     | `gcr.io/azimuth-menu` |

---

## 🔐 Default Login Credentials

| Field        | Value         |
| ------------ | ------------- |
| **Phone**    | `07705371953` |
| **Password** | `root`        |

> ⚠️ **Important**: Change the password after first login!

---

## 📦 Prerequisites

### 1. Install Google Cloud SDK

Download and install [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)

### 2. Install Docker Desktop

Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop/)

---

## 🛠️ Deployment Steps

### Step 1: Open Terminal and Login to Google Cloud

```powershell
# Login to Google Cloud
gcloud auth login

# Set the project
gcloud config set project azimuth-menu
```

### Step 2: Configure Docker for Google Container Registry

```powershell
# Configure Docker to use gcloud as credential helper
gcloud auth configure-docker
```

### Step 3: Navigate to Project Directory

```powershell
cd "c:\Users\spn\Desktop\VoulnteersMgmgt\Dev\PDF Generator"
```

### Step 4: Build the Docker Image

```powershell
# Build the Docker image with the GCR tag
docker build -t gcr.io/azimuth-menu/volunteer-register:latest .
```

### Step 5: Push Image to Google Container Registry

```powershell
# Push the image to GCR
docker push gcr.io/azimuth-menu/volunteer-register:latest
```

After this step, your image will appear in the Artifact Registry under `gcr.io/azimuth-menu/volunteer-register`.

---

## 🌐 Step 6: Create Cloud Run Service via Web UI

### 6.1 Open Cloud Run Console

Go to: https://console.cloud.google.com/run?project=azimuth-menu

### 6.2 Click "Create Service"

### 6.3 Configure the Service

#### Container Image

1. Click **"Select"** next to "Container image URL"
2. Navigate to: `gcr.io` → `azimuth-menu` → `volunteer-register`
3. Select the `latest` tag
4. Click **"Select"**

#### Service Settings

| Setting          | Value                    |
| ---------------- | ------------------------ |
| **Service name** | `volunteer-register`     |
| **Region**       | `europe-west1 (Belgium)` |

#### CPU allocation and pricing

- Select: **"CPU is only allocated during request processing"** (cheaper)

#### Autoscaling

| Setting               | Value |
| --------------------- | ----- |
| **Minimum instances** | `0`   |
| **Maximum instances** | `3`   |

#### Authentication

- Select: **"Allow unauthenticated invocations"** ✅
  - This makes the service publicly accessible

### 6.4 Container Settings (Click "Container, Networking, Security")

#### Container Tab

| Setting            | Value     |
| ------------------ | --------- |
| **Container port** | `8080`    |
| **Memory**         | `512 MiB` |
| **CPU**            | `1`       |

#### Environment Variables (Optional)

Click **"Add Variable"** if you need to set any:
| Name | Value |
|------|-------|
| `DATA_DIR` | `/data` |

### 6.5 Click "Create"

Wait for the deployment to complete (usually 1-2 minutes).

---

## ✅ Step 7: Access Your Application

After deployment, you'll see your service URL in the format:

```
https://volunteer-register-XXXXXXXXXX-ew.a.run.app
```

Click the URL to access your application!

---

## 🔄 Updating the Application

When you make code changes, follow these steps to update:

### Quick Update Commands

```powershell
# 1. Navigate to project folder
cd "c:\Users\spn\Desktop\VoulnteersMgmgt\Dev\PDF Generator"

# 2. Rebuild the Docker image
docker build -t gcr.io/azimuth-menu/volunteer-register:latest .

# 3. Push the updated image
docker push gcr.io/azimuth-menu/volunteer-register:latest

# 4. Deploy the new version to Cloud Run
gcloud run deploy volunteer-register `
    --image=gcr.io/azimuth-menu/volunteer-register:latest `
    --region=europe-west1
```

Or update via Web UI:

1. Go to https://console.cloud.google.com/run?project=azimuth-menu
2. Click on `volunteer-register` service
3. Click **"Edit & Deploy New Revision"**
4. Select the new image version
5. Click **"Deploy"**

---

## 📊 Monitoring & Logs

### View Logs via Terminal

```powershell
# View recent logs
gcloud run services logs read volunteer-register --region=europe-west1

# Stream logs in real-time
gcloud run services logs tail volunteer-register --region=europe-west1
```

### View Logs via Web UI

1. Go to: https://console.cloud.google.com/run?project=azimuth-menu
2. Click on `volunteer-register`
3. Click the **"Logs"** tab

---

## 🔗 Get Service URL

```powershell
gcloud run services describe volunteer-register --region=europe-west1 --format="value(status.url)"
```

---

## ⚠️ Important Notes

### About SQLite Database Persistence

Cloud Run containers are **stateless**. This means:

- The SQLite database will be **reset** when the container restarts
- For production use, you need to set up persistent storage

---

## 💾 Step 8: Set Up Persistent Storage (Required for Data Persistence)

To keep your SQLite database and uploaded files persistent across container restarts and deployments, you need to create a Cloud Storage bucket and mount it as a volume.

### 8.1 Create a Cloud Storage Bucket via Web UI

1. Go to: https://console.cloud.google.com/storage/browser?project=azimuth-menu
2. Click **"Create"** button at the top
3. Configure the bucket:

| Setting            | Value                     |
| ------------------ | ------------------------- |
| **Name**           | `volunteer-register-data` |
| **Location type**  | `Region`                  |
| **Location**       | `europe-west1 (Belgium)`  |
| **Storage class**  | `Standard`                |
| **Access control** | `Uniform` (recommended)   |

4. Click **"Create"**
5. If prompted about public access prevention, click **"Confirm"**

### 8.2 Grant Permissions to Cloud Run Service Account

1. After the bucket is created, click on the bucket name `volunteer-register-data`
2. Go to the **"Permissions"** tab
3. Click **"Grant Access"**
4. In **"New principals"**, enter:
   ```
   PROJECT_NUMBER-compute@developer.gserviceaccount.com
   ```
   > 💡 To find your PROJECT_NUMBER: Go to https://console.cloud.google.com/home/dashboard?project=azimuth-menu and look for "Project number" on the dashboard
5. In **"Role"**, select: `Cloud Storage` → **"Storage Object Admin"**
6. Click **"Save"**

### 8.3 Update Cloud Run Service with Volume Mount

1. Go to: https://console.cloud.google.com/run?project=azimuth-menu
2. Click on `volunteer-register` service
3. Click **"Edit & Deploy New Revision"**

#### Configure Execution Environment

4. Scroll down to find **"Execution environment"**
5. Select: **"Second generation"** ⚠️ (Required for volume mounts!)

#### Add Volume

6. Expand **"Container(s), Volumes, Networking, Security"**
7. Click the **"Volumes"** tab
8. Click **"Add Volume"**
9. Configure:

| Setting         | Value                     |
| --------------- | ------------------------- |
| **Volume type** | `Cloud Storage bucket`    |
| **Volume name** | `data-volume`             |
| **Bucket**      | `volunteer-register-data` |
| **Read-only**   | ❌ Leave unchecked        |

10. Click **"Done"**

#### Mount the Volume to Container

11. Click the **"Container"** tab (first tab)
12. Scroll down to **"Volume Mounts"**
13. Click **"Mount volume"**
14. Configure:

| Setting         | Value         |
| --------------- | ------------- |
| **Volume name** | `data-volume` |
| **Mount path**  | `/data`       |

15. Click **"Done"**

#### Add Environment Variable

16. Scroll to **"Environment variables"** section
17. Click **"Add Variable"**
18. Add:

| Name       | Value   |
| ---------- | ------- |
| `DATA_DIR` | `/data` |

#### Deploy

19. Click **"Deploy"** at the bottom
20. Wait for deployment to complete (1-2 minutes)

### 8.4 Verify Persistence

After deployment:

1. Login to your app and create some test data (add a volunteer)
2. Go back to Cloud Run and click **"Edit & Deploy New Revision"** → **"Deploy"** (this restarts the container)
3. Check if your data is still there ✅

Your SQLite database is now stored at `/data/volunteers_v2.db` inside the Cloud Storage bucket!

---

## 📁 Managing Persistent Data via Web UI

### View Files in the Bucket

1. Go to: https://console.cloud.google.com/storage/browser/volunteer-register-data?project=azimuth-menu
2. You'll see `volunteers_v2.db` and `uploads/` folder

### Download Database Backup

1. Go to the bucket in Cloud Storage
2. Click on `volunteers_v2.db`
3. Click **"Download"**

### Upload Database (Restore)

1. Go to the bucket in Cloud Storage
2. Click **"Upload Files"**
3. Select your backup `volunteers_v2.db` file
4. Confirm overwrite if prompted

---

## 🗑️ Delete Service (If Needed) via Web UI

### Delete Cloud Run Service

1. Go to: https://console.cloud.google.com/run?project=azimuth-menu
2. Select `volunteer-register`
3. Click **"Delete"** at the top

### Delete Container Image

1. Go to: https://console.cloud.google.com/gcr/images/azimuth-menu?project=azimuth-menu
2. Click on `volunteer-register`
3. Select the image(s) you want to delete
4. Click **"Delete"** at the top

### Delete Storage Bucket (if no longer needed)

1. Go to: https://console.cloud.google.com/storage/browser?project=azimuth-menu
2. Select `volunteer-register-data`
3. Click **"Delete"** at the top
4. Type the bucket name to confirm

---

## 📝 Quick Reference Commands (for Terminal)

```powershell
# === Initial Setup (One Time) ===
gcloud auth login
gcloud config set project azimuth-menu
gcloud auth configure-docker

# === Build & Deploy ===
cd "c:\Users\spn\Desktop\VoulnteersMgmgt\Dev\PDF Generator"
docker build -t gcr.io/azimuth-menu/volunteer-register:latest .
docker push gcr.io/azimuth-menu/volunteer-register:latest
```

---

## ✅ Success!

Your application should now be live at:

```
https://volunteer-register-XXXXXXXXXX-ew.a.run.app
```

**Login with:**

- 📱 Phone: `07705371953`
- 🔑 Password: `root`

---

## ❓ Troubleshooting

### Docker build fails

- Make sure Docker Desktop is running
- Check that you're in the correct directory

### Push to GCR fails

```powershell
# Re-authenticate Docker
gcloud auth configure-docker
```

### Service won't start

1. Go to Cloud Run → Click on service → **"Logs"** tab
2. Look for error messages
3. Common fixes:
   - Verify container port is set to `8080`
   - Increase memory to `1 GiB`
   - Make sure **"Second generation"** execution environment is selected (required for volume mounts)

### Volume mount not working

- Ensure **"Execution environment"** is set to **"Second generation"**
- Check bucket permissions include the compute service account
- Verify `DATA_DIR` environment variable is set to `/data`

### Authentication issues with GCloud

```powershell
# Re-login
gcloud auth login
gcloud auth application-default login
```
