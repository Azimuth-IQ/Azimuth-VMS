# Pre-Delegation Checklist for Cloud Agent

**Complete ALL items before delegating theme implementation to cloud agent**

---

## ✅ 1. Download & Add Font Files

### Download Fonts from Google Fonts

Visit each URL and download TTF files:

**Inter (Admin Theme):**
- URL: https://fonts.google.com/specimen/Inter
- Download weights: Regular (400), Medium (500), SemiBold (600), Bold (700)
- Files needed:
  - `Inter-Regular.ttf`
  - `Inter-Medium.ttf`
  - `Inter-SemiBold.ttf`
  - `Inter-Bold.ttf`

**Lexend (Volunteer Theme):**
- URL: https://fonts.google.com/specimen/Lexend
- Download weights: Regular (400), Medium (500), SemiBold (600), Bold (700)
- Files needed:
  - `Lexend-Regular.ttf`
  - `Lexend-Medium.ttf`
  - `Lexend-SemiBold.ttf`
  - `Lexend-Bold.ttf`

**Noto Serif (Team Leader Theme - Headings):**
- URL: https://fonts.google.com/specimen/Noto+Serif
- Download weights: Regular (400), Bold (700), ExtraBold (900)
- Files needed:
  - `NotoSerif-Regular.ttf`
  - `NotoSerif-Bold.ttf`
  - `NotoSerif-ExtraBold.ttf`

**Noto Sans (Team Leader Theme - Body):**
- URL: https://fonts.google.com/specimen/Noto+Sans
- Download weights: Regular (400), Medium (500), Bold (700)
- Files needed:
  - `NotoSans-Regular.ttf`
  - `NotoSans-Medium.ttf`
  - `NotoSans-Bold.ttf`

### Add Fonts to Project

```bash
# Create fonts directory
mkdir -p assets/fonts

# Copy downloaded TTF files to assets/fonts/
# Place all 15 font files in assets/fonts/
```

**Verify fonts are in place:**
```bash
ls -la assets/fonts/

# Should show:
# Inter-Regular.ttf
# Inter-Medium.ttf
# Inter-SemiBold.ttf
# Inter-Bold.ttf
# Lexend-Regular.ttf
# Lexend-Medium.ttf
# Lexend-SemiBold.ttf
# Lexend-Bold.ttf
# NotoSerif-Regular.ttf
# NotoSerif-Bold.ttf
# NotoSerif-ExtraBold.ttf
# NotoSans-Regular.ttf
# NotoSans-Medium.ttf
# NotoSans-Bold.ttf
```

---

## ✅ 2. Verify App Runs Without Errors

```bash
# Test current app state
flutter clean
flutter pub get
flutter run -d chrome

# Verify:
# - App launches successfully
# - No console errors
# - Basic navigation works
# - Can log in
```

---

## ✅ 3. Create Git Checkpoint

```bash
# Make sure you're on main branch
git checkout main

# Stage all current changes
git add .

# Check what will be committed
git status

# Create checkpoint commit
git commit -m "Pre-theme checkpoint: Current working state before redesign"

# Create a tag for easy rollback
git tag pre-theme-implementation

# Push to GitHub
git push origin main --tags
```

**Verify checkpoint created:**
```bash
git tag
# Should show: pre-theme-implementation

git log --oneline -5
# Should show your checkpoint commit at the top
```

---

## ✅ 4. Create Feature Branch

```bash
# Create new branch from main
git checkout -b feature/theme-system-implementation

# Verify you're on the new branch
git branch
# Should show: * feature/theme-system-implementation

# Push branch to GitHub
git push -u origin feature/theme-system-implementation
```

---

## ✅ 5. Add Material Symbols Icons Package

```bash
# Add package
flutter pub add material_symbols_icons

# Verify it was added
flutter pub get

# Commit this change
git add pubspec.yaml pubspec.lock
git commit -m "Add material_symbols_icons package for theme system"
git push origin feature/theme-system-implementation
```

---

## ✅ 6. Add Font Files to Git

```bash
# Add fonts directory
git add assets/fonts/

# Commit fonts
git commit -m "Add font files (Inter, Lexend, Noto Serif, Noto Sans) for theme system"

# Push to GitHub
git push origin feature/theme-system-implementation
```

**CRITICAL: Fonts MUST be pushed before agent starts work!**

---

## ✅ 7. Create GitHub Pull Request

1. Go to your GitHub repository: https://github.com/Azimuth-IQ/Azimuth-VMS

2. Click "Pull Requests" tab

3. Click "New Pull Request"

4. Set:
   - Base: `main`
   - Compare: `feature/theme-system-implementation`

5. Title: **"Implement 3-theme role-based design system"**

6. Description:
   ```markdown
   ## Overview
   Implements a 3-theme design system based on user roles:
   - Theme 1 (Red/Dark): Admin users
   - Theme 2 (Green/Light): Volunteer users
   - Theme 3 (Gold/Dark): Team Leader users
   
   ## Implementation Plan
   - Phase 1: Theme infrastructure
   - Phase 2: Base components
   - Phase 3: Navigation system
   - Phase 4: Screen updates
   - Phase 5: Testing & documentation
   
   ## Reference
   - Design spec: REDESIGN.md
   - Implementation guide: THEME_IMPLEMENTATION_GUIDE.md
   - Agent prompt: CLOUD_AGENT_PROMPT.md
   
   @copilot-workspace Please implement according to CLOUD_AGENT_PROMPT.md
   ```

7. **Mark as Draft** (toggle "Draft Pull Request" option)

8. Click "Create Pull Request"

9. Copy the PR number (e.g., #2)

---

## ✅ 8. Verify Branch Setup

```bash
# Verify current branch
git branch
# Should show: * feature/theme-system-implementation

# Verify remote tracking
git branch -vv
# Should show: feature/theme-system-implementation tracking origin/feature/theme-system-implementation

# Verify fonts are committed and pushed
git log --oneline -5
# Should show commits for fonts and material_symbols_icons

# Verify fonts exist remotely
git ls-tree -r HEAD --name-only | grep "assets/fonts"
# Should list all 15 font files
```

---

## ✅ 9. Prepare Agent Prompt

1. Open `CLOUD_AGENT_PROMPT.md`

2. Copy the ENTIRE contents

3. Ready to paste into PR comment

---

## ✅ 10. Final Verification Checklist

Before delegating to agent, verify:

- [ ] ✅ All 15 font files in `assets/fonts/` directory
- [ ] ✅ Fonts committed and pushed to GitHub
- [ ] ✅ `material_symbols_icons` package added
- [ ] ✅ Checkpoint created with tag `pre-theme-implementation`
- [ ] ✅ Feature branch `feature/theme-system-implementation` created
- [ ] ✅ Feature branch pushed to GitHub
- [ ] ✅ Pull Request created and marked as Draft
- [ ] ✅ Current working app runs without errors
- [ ] ✅ You're on `feature/theme-system-implementation` branch locally
- [ ] ✅ `REDESIGN.md` exists and is up to date
- [ ] ✅ `THEME_IMPLEMENTATION_GUIDE.md` exists
- [ ] ✅ `CLOUD_AGENT_PROMPT.md` copied and ready to paste

---

## 🚀 Ready to Delegate!

Once all items are checked:

1. Go to your GitHub Pull Request

2. Add a new comment

3. Paste the contents of `CLOUD_AGENT_PROMPT.md`

4. Tag the agent: `@copilot-workspace` (or whatever your agent service uses)

5. Submit the comment

6. Monitor the PR for agent activity

---

## 📊 Monitoring Agent Progress

**What to watch for:**

- Agent should confirm it's on the correct branch
- Agent should commit after each phase
- Agent should report progress in PR comments
- Expect 5 commits (one per phase)

**Timeline Expectations:**

- Phase 1: 4-6 hours
- Phase 2: 6-8 hours
- Phase 3: 4-5 hours
- Phase 4: 8-12 hours
- Phase 5: 2-3 hours
- **Total: 24-34 hours (3-4 working days)**

**You can safely:**
- Close your laptop
- Go offline
- Let agent work overnight

**Check back:**
- Every 8-12 hours for progress updates
- Review each phase completion before allowing agent to continue
- Provide feedback in PR comments

---

## 🔙 Rollback Plan (If Needed)

If something goes wrong:

```bash
# Switch to feature branch
git checkout feature/theme-system-implementation

# Reset to checkpoint
git reset --hard pre-theme-implementation

# Force push to update remote
git push -f origin feature/theme-system-implementation

# Or delete branch entirely
git checkout main
git branch -D feature/theme-system-implementation
git push origin --delete feature/theme-system-implementation
# Then close the PR on GitHub
```

---

## 📝 Post-Implementation

After agent completes all phases:

1. Pull latest changes:
   ```bash
   git checkout feature/theme-system-implementation
   git pull origin feature/theme-system-implementation
   ```

2. Test thoroughly:
   ```bash
   flutter clean
   flutter pub get
   flutter run -d chrome
   ```

3. Review code changes in GitHub PR

4. If satisfied:
   - Mark PR as ready for review
   - Merge to main
   - Delete feature branch

5. If issues found:
   - Comment on PR with specific issues
   - Let agent fix them
   - Or fix locally and push

---

**Last Updated:** December 28, 2025

**Ready to start?** Complete this checklist, then follow the delegation steps above!
