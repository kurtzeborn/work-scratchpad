# Hotfix Releases Report

**Repository:** [Azure/azure-sdk-for-net](https://github.com/Azure/azure-sdk-for-net)
**Date Range:** 2025-03-27 to 2026-03-27
**Total Releases in Period:** 323
**Release Branch PRs Found:** 21
**Hotfix Releases Identified:** 16

## Method

A release is classified as a **hotfix** if it was published through a PR from a `release/` branch.
This indicates the release was prepared on a branch rather than directly on `main`.

## Hotfix Release List

| # | Package/Tag | Published | Release Branch | PR |
|---|-------------|-----------|----------------|-----|
| 1 | [Azure.ResourceManager.Confluent_1.3.0-beta.1](https://github.com/Azure/azure-sdk-for-net/releases/tag/Azure.ResourceManager.Confluent_1.3.0-beta.1) | 2026-03-19 | `release/confluent-1.3.0-beta.1` | [#57210](https://github.com/Azure/azure-sdk-for-net/pull/57210) |
| 2 | [Azure.Provisioning.PrivateDns_1.0.0](https://github.com/Azure/azure-sdk-for-net/releases/tag/Azure.Provisioning.PrivateDns_1.0.0) | 2026-03-19 | `release/Azure.Provisioning.PrivateDns_1.0.0` | [#57208](https://github.com/Azure/azure-sdk-for-net/pull/57208) |
| 3 | [System.ClientModel_1.10.0](https://github.com/Azure/azure-sdk-for-net/releases/tag/System.ClientModel_1.10.0) | 2026-03-17 | `release/System.ClientModel_1.10.0` | [#57142](https://github.com/Azure/azure-sdk-for-net/pull/57142) |
| 4 | [Azure.Provisioning_1.6.0-beta.1](https://github.com/Azure/azure-sdk-for-net/releases/tag/Azure.Provisioning_1.6.0-beta.1) | 2026-03-11 | `release/azure-provisioning` | [#56928](https://github.com/Azure/azure-sdk-for-net/pull/56928) |
| 5 | [Azure.Provisioning_1.5.0](https://github.com/Azure/azure-sdk-for-net/releases/tag/Azure.Provisioning_1.5.0) | 2026-03-05 | `release/azure-provisioning` | [#56928](https://github.com/Azure/azure-sdk-for-net/pull/56928) |
| 6 | [Azure.Provisioning.PostgreSql_1.2.0-beta.2](https://github.com/Azure/azure-sdk-for-net/releases/tag/Azure.Provisioning.PostgreSql_1.2.0-beta.2) | 2026-03-02 | `release/Azure.Provisioning.PostgreSql_1.2.0-beta.1` | [#56546](https://github.com/Azure/azure-sdk-for-net/pull/56546) |
| 7 | [Azure.Data.AppConfiguration_1.9.0](https://github.com/Azure/azure-sdk-for-net/releases/tag/Azure.Data.AppConfiguration_1.9.0) | 2026-02-27 | `release/Azure.Data.AppConfiguration_1.9.0` | [#56550](https://github.com/Azure/azure-sdk-for-net/pull/56550) |
| 8 | [Azure.Provisioning.ApplicationInsights_1.2.0-beta.1](https://github.com/Azure/azure-sdk-for-net/releases/tag/Azure.Provisioning.ApplicationInsights_1.2.0-beta.1) | 2026-02-27 | `release/Azure.Provisioning.ApplicationInsights_1.2.0-beta.1` | [#56554](https://github.com/Azure/azure-sdk-for-net/pull/56554) |
| 9 | [Azure.Provisioning.PostgreSql_1.2.0-beta.1](https://github.com/Azure/azure-sdk-for-net/releases/tag/Azure.Provisioning.PostgreSql_1.2.0-beta.1) | 2026-02-27 | `release/Azure.Provisioning.PostgreSql_1.2.0-beta.1` | [#56546](https://github.com/Azure/azure-sdk-for-net/pull/56546) |
| 10 | [Azure.Provisioning.AppConfiguration_1.2.0-beta.1](https://github.com/Azure/azure-sdk-for-net/releases/tag/Azure.Provisioning.AppConfiguration_1.2.0-beta.1) | 2026-02-27 | `release/Azure.Provisioning.AppConfiguration_1.2.0-beta.1` | [#56552](https://github.com/Azure/azure-sdk-for-net/pull/56552) |
| 11 | [Azure.ResourceManager_1.14.0](https://github.com/Azure/azure-sdk-for-net/releases/tag/Azure.ResourceManager_1.14.0) | 2026-02-27 | `release/Azure.ResourceManager-1.14.0` | [#56501](https://github.com/Azure/azure-sdk-for-net/pull/56501) |
| 12 | [Azure.Identity.Broker_1.4.0](https://github.com/Azure/azure-sdk-for-net/releases/tag/Azure.Identity.Broker_1.4.0) | 2026-02-27 | `release/Azure.Identity.Broker_1.4.0` | [#56533](https://github.com/Azure/azure-sdk-for-net/pull/56533) |
| 13 | [Azure.Identity_1.18.0](https://github.com/Azure/azure-sdk-for-net/releases/tag/Azure.Identity_1.18.0) | 2026-02-26 | `release/Azure.Identity_1.18.0` | [#56484](https://github.com/Azure/azure-sdk-for-net/pull/56484) |
| 14 | [Azure.Identity_1.18.0-beta.3](https://github.com/Azure/azure-sdk-for-net/releases/tag/Azure.Identity_1.18.0-beta.3) | 2026-02-20 | `release/Azure.Identity_1.18.0` | [#56484](https://github.com/Azure/azure-sdk-for-net/pull/56484) |
| 15 | [Azure.Data.AppConfiguration_1.8.0](https://github.com/Azure/azure-sdk-for-net/releases/tag/Azure.Data.AppConfiguration_1.8.0) | 2026-01-29 | `release/Azure.Data.AppConfiguration_1.9.0` | [#56550](https://github.com/Azure/azure-sdk-for-net/pull/56550) |
| 16 | [Azure.ResourceManager.DataFactory_1.11.0](https://github.com/Azure/azure-sdk-for-net/releases/tag/Azure.ResourceManager.DataFactory_1.11.0) | 2025-12-04 | `release/202511_fix` | [#54199](https://github.com/Azure/azure-sdk-for-net/pull/54199) |

## Unmatched Release Branch PRs

These PRs merged from release branches but no corresponding release was found within the expected time window.
They may require manual review:

| PR | Branch | Title | Merged |
|-----|--------|-------|--------|
| [#49132](https://github.com/Azure/azure-sdk-for-net/pull/49132) | `release/azure-communication-common/1.4.0-beta.1` | Creating 1.4.0-beta.1 version release | 2025-04-01 |
| [#49669](https://github.com/Azure/azure-sdk-for-net/pull/49669) | `release/202504` | New release of Azure data factory SDK: Version 1.8.0 | 2025-05-07 |
| [#50169](https://github.com/Azure/azure-sdk-for-net/pull/50169) | `release/azure-communication-phone-numbers-1.3.1-beta.1` | Phonenumbers/reservations api (#49637) | 2025-05-20 |
| [#50312](https://github.com/Azure/azure-sdk-for-net/pull/50312) | `release/azure-communication-phone-numbers-1.4.0` | Release/azure communication phone numbers 1.4.0 | 2025-06-03 |
| [#50343](https://github.com/Azure/azure-sdk-for-net/pull/50343) | `release/azure-communication-common/1.4.0` | Creating stable release Communication.Common version 1.4.0 | 2025-06-03 |
| [#50415](https://github.com/Azure/azure-sdk-for-net/pull/50415) | `release/202506` | New release of Azure data factory SDK: Version 1.9.0 | 2025-06-19 |
| [#51808](https://github.com/Azure/azure-sdk-for-net/pull/51808) | `release/azure-communication-phone-numbers_1.5.0` | Release/azure communication phone numbers 1.5.0 | 2025-08-26 |
| [#52927](https://github.com/Azure/azure-sdk-for-net/pull/52927) | `release/storage/stg99` | [Storage] Cherry-pick in Content Validation Zero length blob fix into release/storage/stg99 | 2025-09-29 |
| [#53052](https://github.com/Azure/azure-sdk-for-net/pull/53052) | `release/Azure.AI.Projects-1.0.0` | Increment package version after release of Azure.AI.Projects (#52964) | 2025-10-07 |

---
*Generated on 2026-03-27 10:19:49 UTC*
