# ###########################################
# ###   No buckets active in dev yet.     ###
# ###########################################
#
# When these are ready, add their suffixes to module.storage's
# `bucket_suffixes` list in main.tf instead of declaring plain resources
# here - e.g.:
#
#   bucket_suffixes = [
#     "vx-app-001",
#     "vxai-bs",
#     "vxai-sales-app-001",
#     "vector-search",
#   ]
#
# The module already wires each bucket to the app-bucket KMS key
# (module.storage's enable_kms) using the same encryption/versioning/
# uniform-bucket-level-access shape as the old plain resources below.
