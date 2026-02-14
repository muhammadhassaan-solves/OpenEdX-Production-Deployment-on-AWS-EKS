#!/bin/bash
set -e

echo "=========================================="
echo "Open edX Databases Configuration Script"
echo "=========================================="

# ============================================
# 1. Disable Internal Databases
# ============================================
echo ""
echo "Disabling internal databases..."

tutor config save \
  --set RUN_MYSQL=false \
  --set RUN_MONGODB=false \
  --set RUN_REDIS=false \
  --set RUN_MEILISEARCH=false

echo "Internal databases disabled"

# ============================================
# 2. Amazon RDS MySQL
# ============================================
echo ""
echo "Configuring Amazon RDS MySQL..."

tutor config save \
  --set MYSQL_HOST=openedx.czeggmy8a2oc.us-east-2.rds.amazonaws.com \
  --set MYSQL_ROOT_USERNAME=<HIDDEN> \
  --set MYSQL_ROOT_PASSWORD='<HIDDEN>' \
  --set OPENEDX_MYSQL_DATABASE=openedx \
  --set OPENEDX_MYSQL_USERNAME=<HIDDEN> \
  --set OPENEDX_MYSQL_PASSWORD='<HIDDEN>'

echo "RDS MySQL configured"

# ============================================
# 3. Amazon DocumentDB
# ============================================
echo ""
echo "Configuring Amazon DocumentDB..."

tutor config save \
  --set MONGODB_HOST=openedx-mongo.cluster-czeggmy8a2oc.us-east-2.docdb.amazonaws.com \
  --set MONGODB_PORT=27017 \
  --set MONGODB_USERNAME=<HIDDEN> \
  --set MONGODB_PASSWORD='<HIDDEN>'

echo "DocumentDB configured"

# ============================================
# 4. Amazon ElastiCache Redis
# ============================================
echo ""
echo "Configuring Amazon ElastiCache Redis..."

tutor config save \
  --set REDIS_HOST=openedx-redis.mqtg7r.ng.0001.use2.cache.amazonaws.com \
  --set REDIS_PORT=6379

echo "ElastiCache Redis configured"

# ============================================
# 5. Domain Configuration
# ============================================
echo ""
echo "Configuring Domains..."

tutor config save \
  --set LMS_HOST=lms.alrafi.org \
  --set CMS_HOST=studio.alrafi.org \
  --set PLATFORM_NAME='Al-Rafi' \
  --set CONTACT_EMAIL=<HIDDEN> \
  --set ENABLE_HTTPS=true \
  --set ENABLE_WEB_PROXY=false

echo "Domains configured"

# ============================================
# 6. SMTP
# ============================================
echo ""
echo "Configuring SMTP..."

tutor config save \
  --set SMTP_HOST=smtp.gmail.com \
  --set SMTP_PORT=587 \
  --set SMTP_USERNAME=<HIDDEN> \
  --set SMTP_PASSWORD='<HIDDEN>' \
  --set SMTP_USE_TLS=true \
  --set SMTP_USE_SSL=false

echo "Gmail SMTP configured"

# ============================================
# 7. Save Final Config
# ============================================
echo ""
echo "Saving final configuration..."

tutor config save

echo ""
echo "=========================================="
echo "Configuration complete!"
echo "=========================================="
