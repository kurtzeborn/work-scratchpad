# Azure SDK "Uber Repo" Size Estimate

**Date:** March 26, 2026

## Repos Under Consideration
- Azure/azure-sdk-for-net
- Azure/azure-sdk-for-java
- Azure/azure-sdk-for-js
- Azure/azure-sdk-for-python
- Azure/azure-sdk-for-go
- Azure/azure-sdk-for-rust
- Azure/azure-rest-api-specs

## GitHub API `size` Field (includes git history — upper bound)

| Repo | API Size (KB) | Size (MB) | Size (GB) |
|------|--------------|-----------|-----------|
| azure-sdk-for-net | 4,404,959 | 4,301.7 | 4.20 |
| azure-sdk-for-java | 3,318,221 | 3,240.5 | 3.16 |
| azure-sdk-for-js | 626,231 | 611.6 | 0.60 |
| azure-sdk-for-python | 849,405 | 829.5 | 0.81 |
| azure-sdk-for-go | 401,125 | 391.7 | 0.38 |
| azure-sdk-for-rust | 318,137 | 310.7 | 0.30 |
| azure-rest-api-specs | 458,327 | 447.6 | 0.44 |
| **Total** | **10,376,405** | **10,133.3** | **9.90** |

## Trees API — Working Tree Partial Sizes (lower bound, truncated for 5/7 repos)

| Repo | Files (counted) | Size (bytes) | Size (MB) | Truncated? |
|------|----------------|-------------|-----------|------------|
| azure-sdk-for-net | 42,571 | 482,783,242 | 460 | YES |
| azure-sdk-for-java | 34,610 | 289,433,299 | 276 | YES |
| azure-sdk-for-js | 47,552 | 288,388,256 | 275 | YES |
| azure-sdk-for-python | 42,961 | 626,205,834 | 597 | YES |
| azure-sdk-for-go | 18,258 | 261,572,051 | 249 | No |
| azure-sdk-for-rust | 1,095 | 8,790,041 | 8 | No |
| azure-rest-api-specs | 36,242 | 191,836,048 | 183 | YES |
| **Partial Total** | **223,289** | **2,149,008,771** | **~2,049** | |

## Tarball Download — Accurate Working Tree Sizes (no history)

**Date:** March 27, 2026

| Repo | Compressed (MB) | Uncompressed (GB) |
|------|-----------------|-------------------|
| azure-sdk-for-net | 173.2 | 1.21 |
| azure-sdk-for-java | 218.0 | 0.88 |
| azure-sdk-for-js | 72.8 | 0.39 |
| azure-sdk-for-python | 127.4 | 0.69 |
| azure-sdk-for-go | 24.3 | 0.24 |
| azure-sdk-for-rust | 1.5 | 0.01 |
| azure-rest-api-specs | 174.2 | 1.49 |
| **Total** | **791.4** | **4.91** |

## Summary

The combined working tree size (current files, no git history) for all 7 repos is approximately **4.91 GB**.
This represents the approximate disk size of a shallow checkout of the proposed "uber" repo.
