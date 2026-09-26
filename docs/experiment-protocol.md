# Experiment Protocol

Status: Phase 1 scaffold. Finalize before collecting thesis results.

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
