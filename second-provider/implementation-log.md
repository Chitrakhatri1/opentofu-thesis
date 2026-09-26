# Azure extension implementation log

Use this file during the implementation and deployment phase. It is evidence
for the extensibility research question, not the final thesis chapter.

## Scope

- Provider: Microsoft Azure
- Slice: resource group, virtual network, subnet, and secure storage account
- Execution tools: Terraform and OpenTofu
- AWS baseline commit used for comparison: `8494e27`

## Predeclared measurements

Record these values before interpreting the result:

| Measure | Value |
|---|---|
| Implementation start time | TODO |
| Implementation end time | TODO |
| Active implementation minutes | TODO |
| New Azure `.tf` lines | 282 before the implementation commit |
| Reused AWS `.tf` lines | 0; resources remain provider-specific |
| Shared conventions | module layout, naming input, tags, typed variables, outputs, CI sequence |
| Terraform validation | Passed locally with Terraform 1.5.7 |
| OpenTofu validation | Passed locally with OpenTofu 1.10.7 |
| Deployment result | TODO |
| Idempotence exit code | TODO |
| Destroy result | TODO |
| Cleanup result | TODO |

## Issues and decisions

| Time | Tool | Category | Observation | Resolution | Active minutes |
|---|---|---|---|---|---:|
| TODO | Both | Design | Azure resources cannot reuse AWS provider resource blocks. | Use provider-specific modules with standardized interfaces and workflow. | TODO |
| 2026-09-26 | Both | Naming | The initial storage-name expression truncated the uniqueness suffix because Azure permits at most 24 characters. | Truncate only the normalized prefix and always retain the suffix. | TODO |
| 2026-09-26 | OpenTofu | Provider signing | OpenTofu warned that the AzureRM provider signing key is expired and may fail in future OpenTofu versions. | Record the warning and monitor provider/OpenTofu updates; validation succeeded with AzureRM 4.81.0. | 0 |

## Completion evidence

Add the following after the test:

- Git commit tested;
- Terraform and OpenTofu versions;
- AzureRM provider version;
- selected subscription recorded only as an anonymized identifier;
- Azure region;
- plan resource count;
- output of the deployment checks;
- post-apply plan exit code;
- destroy summary;
- `az group exists` cleanup result.
