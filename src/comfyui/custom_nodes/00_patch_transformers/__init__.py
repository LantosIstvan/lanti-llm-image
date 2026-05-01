# Patch for transformers>=5.5.0 bug: 'flash_attn' missing from PACKAGE_DISTRIBUTION_MAPPING
try:
    from transformers.utils.import_utils import PACKAGE_DISTRIBUTION_MAPPING
    if "flash_attn" not in PACKAGE_DISTRIBUTION_MAPPING:
        PACKAGE_DISTRIBUTION_MAPPING["flash_attn"] = ["flash_attn", "flash-attn"]
except Exception:
    pass

NODE_CLASS_MAPPINGS = {}
