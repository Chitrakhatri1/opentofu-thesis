# Experiment Protocol

Status: Protocol implemented by `experiments/scripts/run-trial.sh` for controlled AWS baseline trials.

Each trial must record:

- trial ID;
- Git commit;
- tool and provider versions;
- AWS account alias or anonymized identifier;
- region;
- cache condition;
- initial state condition;
- command start/end timestamps;
- exit code and duration;
- post-apply no-change plan result;
- cleanup confirmation;
- unexpected events.

Never use the same mutable state concurrently from Terraform and OpenTofu. Back up state before a controlled state-portability test.

Use separate local plugin-data directories (`.tofu-data` and `.terraform-data`) so that cache conditions can be controlled independently. Keep the configuration and selected provider version identical.

## Formal trial sequence

1. Confirm a clean Git working tree and record the commit.
2. Verify that the selected workspace and live AWS environment are empty.
3. Initialize using the committed dependency lock file.
4. Validate the configuration.
5. Create and save a plan.
6. Apply the saved plan after explicit confirmation.
7. Verify state count, ALB target health, HTTP response, S3 public-access blocking, encryption, and versioning.
8. Run a post-apply plan with detailed exit codes; `0` is the required idempotence result.
9. Destroy after explicit confirmation.
10. Verify empty local state and absence of live tagged AWS resources.
11. Store private raw logs locally and append a sanitized summary row.

Use a consistent cache-condition label across the comparison dataset. Run at least three successful trials per tool, never concurrently.
