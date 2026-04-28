# Issues & Tracking Document

This document tracks known issues, bugs, improvements, and tasks related to the Flask Portfolio App.

## Table of Contents
- [Critical Issues](#critical-issues)
- [High Priority](#high-priority)
- [Medium Priority](#medium-priority)
- [Low Priority](#low-priority)
- [Completed Tasks](#completed-tasks)
- [Ideas & Future Enhancements](#ideas--future-enhancements)

---

## Critical Issues

### CI-001: GitHub Actions Workflow Configuration
**Status:** ✅ Fixed  
**Date:** 2026-04-28  
**Description:** Workflow was using incorrect resource group name `rg-flask-portfolio` which doesn't exist in Azure.  
**Solution:** Updated to use `rg-zen-ecommerce` which is the actual resource group.  
**File:** `.github/workflows/deploy.yml`

### CI-002: Node.js Deprecation Warnings
**Status:** ✅ Fixed  
**Date:** 2026-04-28  
**Description:** GitHub Actions showing deprecation warnings for Node.js 20 actions.  
**Solution:** Added `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true` environment variable.  
**File:** `.github/workflows/deploy.yml`

### CI-003: Replace Deprecated azure/docker-login Action
**Status:** ✅ Fixed  
**Date:** 2026-04-28  
**Description:** The `azure/docker-login@v1` action is deprecated and generates warnings.  
**Solution:** Replaced with official `docker/login-action@v3` and updated parameter from `login-server` to `registry`.  
**File:** `.github/workflows/deploy.yml`

---

## High Priority

### SEC-001: Hardcoded Secret Key
**Status:** ⚠️ Open  
**Priority:** High  
**Description:** Flask SECRET_KEY has a fallback hardcoded value which is a security risk.  
**Location:** `app.py` line 17  
**Current Code:**
```python
app.config["SECRET_KEY"] = os.environ.get("SECRET_KEY", "change-this-secret-key")
```
**Recommendation:** Remove the fallback value and require the environment variable to be set.

### SEC-002: Missing Input Validation
**Status:** ⚠️ Open  
**Priority:** High  
**Description:** Username and password fields lack proper validation (min length, special characters, etc.).  
**Location:** `app.py` - `register()` function  
**Recommendation:** Add validation rules for username (min 3 chars, alphanumeric) and password (min 8 chars, complexity requirements).

### DEP-001: Container App Not Verified
**Status:** ✅ Fixed  
**Date:** 2026-04-28  
**Description:** Container App `flask-app-portfolio` did not exist in `rg-zen-ecommerce` resource group, causing deployment failures.  
**Solution:** Created the Container App using Azure CLI with the existing `zen-ecommerce-env` environment.  
**URL:** https://flask-app-portfolio.bravehill-d5a050aa.southeastasia.azurecontainerapps.io/

---

## Medium Priority

### FEAT-001: Add Health Check Endpoint
**Status:** 📋 Planned  
**Priority:** Medium  
**Description:** No health check endpoint for monitoring and load balancer checks.  
**Recommendation:** Add `/health` endpoint that returns HTTP 200 with status info.

### FEAT-002: Database Migration Support
**Status:** 📋 Planned  
**Priority:** Medium  
**Description:** No database migration system in place. Schema changes require manual intervention.  
**Recommendation:** Integrate Flask-Migrate (Alembic) for database migrations.

### FEAT-003: Add Logging Configuration
**Status:** 📋 Planned  
**Priority:** Medium  
**Description:** Application uses default logging. Need structured logging for production.  
**Recommendation:** Configure Python logging with rotating file handlers and proper log levels.

### FEAT-004: Environment-Specific Configuration
**Status:** 📋 Planned  
**Priority:** Medium  
**Description:** No separation between development and production configurations.  
**Recommendation:** Create `config.py` with different config classes for dev/staging/prod.

---

## Low Priority

### UI-001: Responsive Design Improvements
**Status:** 📋 Planned  
**Priority:** Low  
**Description:** CSS could be improved for better mobile responsiveness.  
**File:** `static/style.css`

### UI-002: Add Flash Message Styling
**Status:** 📋 Planned  
**Priority:** Low  
**Description:** Flash messages currently use default browser styling.  
**Recommendation:** Add CSS classes for success, error, warning flash messages.

### DOC-001: API Documentation
**Status:** 📋 Planned  
**Priority:** Low  
**Description:** No API documentation for the application endpoints.  
**Recommendation:** Add docstrings to all routes or integrate Swagger/OpenAPI.

### TEST-001: Unit Tests Missing
**Status:** 📋 Planned  
**Priority:** Low  
**Description:** No test suite exists for the application.  
**Recommendation:** Create `tests/` directory with pytest and add test coverage for routes and models.

---

## Completed Tasks

| ID | Description | Date Completed |
|----|-------------|----------------|
| SETUP-001 | Migrated repository from Azure DevOps to GitHub | 2026-04-28 |
| SETUP-002 | Created comprehensive README.md | 2026-04-28 |
| SETUP-003 | Generated Azure service principal credentials | 2026-04-28 |
| SETUP-004 | Retrieved ACR credentials | 2026-04-28 |
| CI-001 | Fixed resource group in GitHub Actions workflow | 2026-04-28 |
| CI-002 | Fixed Node.js deprecation warnings | 2026-04-28 |
| CI-003 | Replaced deprecated azure/docker-login with docker/login-action@v3 | 2026-04-28 |
| DEP-002 | Built and pushed Docker image to ACR | 2026-04-28 |

---

## Ideas & Future Enhancements

### Potential Features

1. **User Profile Management**
   - Allow users to update their profile information
   - Add profile picture upload

2. **Comment Moderation**
   - Admin dashboard to moderate guestbook comments
   - Report/flag inappropriate comments

3. **Email Notifications**
   - Send welcome email on registration
   - Notify users of new comments

4. **Rate Limiting**
   - Implement rate limiting on login attempts
   - Prevent brute force attacks

5. **Analytics Dashboard**
   - Track page views
   - Monitor user activity

6. **HTTPS/SSL Configuration**
   - Ensure SSL is properly configured in production
   - Redirect HTTP to HTTPS

7. **Backup Automation**
   - Schedule automated database backups
   - Store backups in Azure Blob Storage

8. **Monitoring & Alerting**
   - Integrate Azure Application Insights
   - Set up alerts for application errors

---

## How to Use This Document

### Adding a New Issue
1. Assign a unique ID (e.g., FEAT-005, BUG-001)
2. Fill in all relevant fields
3. Set appropriate priority level
4. Move to completed section when resolved

### Issue Status Legend
- ✅ **Fixed** - Issue has been resolved
- ⚠️ **Open** - Issue needs attention
- 📋 **Planned** - Issue is planned for future work
- 🔄 **In Progress** - Issue is currently being worked on

---

## Last Updated
**Date:** 2026-04-28  
**Updated By:** GitHub Copilot  
**Changes:** Added CI-003 - Replaced deprecated azure/docker-login action
