# 🖼️ Docker Documentation — Images How-To

> Complete guide: screenshots lena, save karna, markdown mein add karna, aur GitHub par push karna.

---

## 📚 Table of Contents

1. [Why Images Matter](#why-images-matter)
2. [Folder Structure](#folder-structure)
3. [Taking Screenshots](#taking-screenshots)
4. [Saving Screenshots](#saving-screenshots)
5. [Naming Convention](#naming-convention)
6. [Markdown Syntax](#markdown-syntax)
7. [Complete Example](#complete-example)
8. [Git Workflow](#git-workflow)
9. [Optimization](#optimization)
10. [Troubleshooting](#troubleshooting)

---

## Why Images Matter

Documentation mein images **bohat zaroori** hain kyunke:

- ✅ **Visual proof** — kaam ka evidence
- ✅ **Quick reference** — commands yaad rahengi
- ✅ **Better understanding** — text se zyada clear
- ✅ **Portfolio** — GitHub par professional dikhta
- ✅ **Future reference** — jab bhool jayein, image dekhein

**Rule:** Har **major step** ka screenshot lein.

---

## Folder Structure

### Recommended Structure

```
devops-practice/
├── 08-docker-containers/
│   ├── docker-cli.md
│   ├── docker-images-how-to.md
│   ├── setup.md
│   ├── wsl-integration-how-to.md
│   │
│   └── images/                    ← Screenshots folder
│       ├── docker-version.png
│       ├── docker-info.png
│       ├── docker-desktop.png
│       ├── wsl-integration.png
│       ├── containers-list.png
│       ├── nginx-browser.png
│       └── docker-context.png
```

### Folder Banao

Run in WSL:

```bash
cd /mnt/c/Users/anpk/Desktop/ashfaqnasir-dev/devops-practice/08-docker-containers

mkdir -p images

ls
# Output: docker-cli.md  images  setup.md  wsl-integration-how-to.md
```

---

## Taking Screenshots

### Method 1: Snipping Tool (Windows)

**Shortcut:**

```
Win + Shift + S
```

**Steps:**

1. Shortcut dabayein
2. Screen **dim** ho jayegi
3. Mouse se **area select** karein
4. Screenshot **clipboard** mein aa jayega
5. Notification par click karein
6. **Save** dialog → images folder

### Method 2: Print Screen

**Full screen:**

```
Win + PrtScn
```

Screenshot automatically `Pictures/Screenshots/` mein save hoga.

### Method 3: Snip & Sketch

**Start menu** → **Snip & Sketch** → **New** → Area select

### Method 4: Third-Party Tools

| Tool | Platform | URL |
|---|---|---|
| **ShareX** | Windows | getsharex.com |
| **Greenshot** | Windows | getgreenshot.org |
| **Flameshot** | Linux | flameshot.org |

---

## Saving Screenshots

### Step 1: Screenshot Lein

`Win + Shift + S` dabayein, area select karein.

### Step 2: Save Location

**Windows path:**

```
C:\Users\anpk\Desktop\ashfaqnasir-dev\devops-practice\08-docker-containers\images\
```

**WSL path:**

```
/mnt/c/Users/anpk/Desktop/ashfaqnasir-dev/devops-practice/08-docker-containers/images/
```

### Step 3: File Format

| Format | Use | Size |
|---|---|---|
| **PNG** | ✅ Screenshots (best) | Medium |
| **JPG** | Photos | Small |
| **GIF** | Animations | Large |
| **WebP** | Modern, small | Smallest |

**Recommendation:** **PNG** for screenshots.

### Step 4: Save Karein

**File name:** `docker-version.png`

---

## Naming Convention

### Rules

| Rule | Good | Bad |
|---|---|---|
| **Lowercase** | `docker-version.png` | `Docker-Version.png` |
| **Hyphens** | `docker-version.png` | `docker_version.png` |
| **No spaces** | `docker-version.png` | `docker version.png` |
| **Descriptive** | `nginx-browser.png` | `image1.png` |
| **Extension** | `.png` | `.PNG` |

### Examples

| Screenshot | File Name |
|---|---|
| Docker version | `docker-version.png` |
| Docker info | `docker-info.png` |
| Docker Desktop GUI | `docker-desktop.png` |
| WSL Integration settings | `wsl-integration.png` |
| Container list | `containers-list.png` |
| nginx browser | `nginx-browser.png` |
| Docker context | `docker-context.png` |
| Terminal output | `terminal-output.png` |

---

## Markdown Syntax

### Basic Syntax

```markdown
![Alt Text](./images/filename.png)
```

### Parts Explained

| Part | Purpose |
|---|---|
| `!` | Image indicator |
| `[Alt Text]` | Text if image fails to load |
| `(./images/file.png)` | Path to image |
| `./` | Current directory |
| `images/` | Images folder |
| `file.png` | Image filename |

### Advanced: Image with Title

```markdown
![Docker Version](./images/docker-version.png "Docker --version output")
```

Title shows when hover.

### Advanced: Image Link

```markdown
[![Docker Version](./images/docker-version.png)](https://docker.com)
```

Clickable image.

### Advanced: Resize (HTML)

```markdown
<img src="./images/docker-version.png" alt="Docker Version" width="600">
```

Width in pixels.

---

## Complete Example

### File: `docker-cli.md`

```markdown
# Docker CLI — Complete Guide

> Docker CLI = Terminal se Docker control karne ka tool.

## Version Check

Verify Docker installed:

```bash
docker --version
```

![Docker Version](./images/docker-version.png)

## Docker Info

System information:

```bash
docker info
```

![Docker Info](./images/docker-info.png)

## Docker Desktop

Windows GUI:

![Docker Desktop](./images/docker-desktop.png)

## WSL Integration

Enable Ubuntu integration:

1. Settings → Resources → WSL Integration
2. Ubuntu toggle ON

![WSL Integration](./images/wsl-integration.png)

## Containers List

Running containers:

```bash
docker ps
```

![Containers List](./images/containers-list.png)

## nginx Test

Browser access:

```
http://localhost:9090
```

![nginx Browser](./images/nginx-browser.png)
```

---

## Git Workflow

### Step 1: Screenshots Save Karein

Save all PNG files to `08-docker-containers/images/`.

### Step 2: Verify Files

```bash
cd /mnt/c/Users/anpk/Desktop/ashfaqnasir-dev/devops-practice/08-docker-containers

ls -la images/
```

Expected output:

```
docker-version.png
docker-info.png
docker-desktop.png
wsl-integration.png
containers-list.png
nginx-browser.png
```

### Step 3: Markdown Update

Update `docker-cli.md` with image references.

### Step 4: Git Add

```bash
cd /mnt/c/Users/anpk/Desktop/ashfaqnasir-dev/devops-practice

git add 08-docker-containers/
```

### Step 5: Git Commit

```bash
git commit -m "Add Docker CLI guide with screenshots"
```

### Step 6: Git Push

```bash
git push origin main
```

Expected output:

```
To github.com:ashfaqnasir-dev/devops-practice.git
   abc1234..def5678  main -> main
```

### Step 7: Verify on GitHub

URL:

```
https://github.com/ashfaqnasir-dev/devops-practice/tree/main/08-docker-containers
```

Images automatically render.

---

## Optimization

### Image Size Guidelines

| Size | Status |
|---|---|
| 100-500 KB | ✅ Perfect |
| 500 KB - 1 MB | ⚠️ Acceptable |
| 1-5 MB | ⚠️ Compress |
| 5+ MB | ❌ Too large |

### Compression Tools

| Tool | URL | Type |
|---|---|---|
| **TinyPNG** | tinypng.com | Online |
| **Squoosh** | squoosh.app | Online |
| **ImageOptim** | imageoptim.com | Mac |
| **PNGGauntlet** | pnggauntlet.com | Windows |

### Resize Images

**Paint (Windows):**

1. Image kholein
2. **Resize** click
3. Percentage (50%)
4. Save

**Command line:**

```bash
# ImageMagick install
sudo apt install imagemagick

# Resize
convert input.png -resize 50% output.png
```

---

## Troubleshooting

### Issue 1: Image Not Showing on GitHub

**Check:**

1. File exists in `images/` folder
2. Path correct: `./images/file.png`
3. Case sensitive: `Docker-Version.png` vs `docker-version.png`
4. Committed to git

**Fix:**

```bash
git add images/
git commit -m "Add images"
git push
```

### Issue 2: Image Too Large

**Fix:** Compress with TinyPNG.

### Issue 3: Wrong Path

**Check:**

```markdown
❌ ![Image](images/file.png)         # Missing ./
❌ ![Image](/images/file.png)        # Absolute path
❌ ![Image](./Images/file.png)       # Wrong case
✅ ![Image](./images/file.png)       # Correct
```

### Issue 4: Broken Image Link

**Debug:**

1. Open markdown file on GitHub
2. Right-click broken image
3. "Open image in new tab"
4. Check URL: `github.com/.../images/file.png`
5. Agar 404 → File missing

---

## Best Practices

### Do's

- ✅ PNG for screenshots
- ✅ Descriptive names
- ✅ Lowercase + hyphens
- ✅ Compress before commit
- ✅ Add alt text
- ✅ Organize in `images/` folder

### Don'ts

- ❌ Large files (5+ MB)
- ❌ Spaces in names
- ❌ Random names (image1.png)
- ❌ Absolute paths
- ❌ Missing alt text
- ❌ Duplicate images

---

## Quick Reference

### Screenshot Shortcut

```
Win + Shift + S
```

### Folder Command

```bash
mkdir -p images
```

### Markdown Syntax

```markdown
![Alt Text](./images/file.png)
```

### Git Commands

```bash
git add .
git commit -m "Add screenshots"
git push origin main
```

### Verify

```
https://github.com/ashfaqnasir-dev/devops-practice/tree/main/08-docker-containers/images
```

---

## Checklist

- [ ] `images/` folder created
- [ ] Screenshots taken
- [ ] Files saved as PNG
- [ ] Lowercase names
- [ ] Markdown updated
- [ ] Images compressed
- [ ] Git added
- [ ] Git committed
- [ ] Git pushed
- [ ] GitHub renders correctly

---

**Status:** ✅ Complete
**Last Updated:** 2026-10-14
**Author:** Ashfaq Nasir
