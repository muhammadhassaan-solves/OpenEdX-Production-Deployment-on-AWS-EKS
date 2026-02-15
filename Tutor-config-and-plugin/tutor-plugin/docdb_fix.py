from tutor import hooks

# Patch for both LMS and CMS production settings
DOCDB_PATCH = """
# ============================================
# DocumentDB Fix - Disable Retryable Writes
# ============================================
import pymongo.mongo_client
_original_init = pymongo.mongo_client.MongoClient.__init__
def _patched_init(self, *args, **kwargs):
    kwargs['retryWrites'] = False
    _original_init(self, *args, **kwargs)
pymongo.mongo_client.MongoClient.__init__ = _patched_init
"""

hooks.Filters.ENV_PATCHES.add_item(
    ("openedx-cms-production-settings", DOCDB_PATCH)
)
hooks.Filters.ENV_PATCHES.add_item(
    ("openedx-lms-production-settings", DOCDB_PATCH)
)
