Key Open edX Production Issues and Resolutions


-----> DocumentDB Retryable Writes Issue

Problem:
Open edX deployments on Kubernetes using Amazon DocumentDB were failing all MongoDB write operations. The errors appeared as:
pymongo.errors.OperationFailure: Retryable writes are not supported

Analysis:
PyMongo 4.x enables retryWrites=True by default.
Amazon DocumentDB does not support retryable writes.
All LMS and CMS write operations (course creation, publishing, etc.) were failing due to this mismatch.

Solution:

Implemented a global monkey patch in LMS and CMS production settings to force retryWrites=False for all MongoClient connections.
Created a custom Tutor plugin to persist this fix across deployments, ensuring the setting is applied every time the environment is deployed or updated.

Outcome:

All write operations started succeeding.
Course creation and publishing functionality was restored.
The production environment became stable for LMS and CMS operations.



-----> CloudFront and WAF Blocking MFE File Uploads

Problem:
File uploads in Open edX Micro-Frontend (MFE) were failing with CORS errors and 403 Forbidden responses.

Analysis:
Amazon CloudFront was not forwarding required headers (e.g., cookies, CSRF tokens).
AWS WAF incorrectly flagged legitimate upload requests as potential threats, blocking them.

Solution:

Updated CloudFront configuration to forward all necessary headers for file uploads.
Allowed the use-jwt-cookie header in the CORS policy to ensure proper authentication.
Adjusted WAF rules to prevent blocking legitimate upload requests while maintaining security protections.

Outcome:

File uploads now work reliably in production.
Security protections remain active with WAF and CloudFront.
User experience for content creators was restored without compromising system security.
