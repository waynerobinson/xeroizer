# Integration tests

These exercise the gem against real Xero API responses recorded as VCR
"cassettes" (YAML under `test/fixtures/vcr_cassettes/`). They replay those
recordings, so the suite runs in CI with **no credentials**.

```
Run (replay; the default and what CI runs):
    bundle exec rake test:integration

Add new tests' cassettes (records only the missing ones; existing untouched):
    VCR_MODE=record bundle exec rake test:integration

Refresh a cassette (when you suspect Xero changed that response):
    # VCR_MODE=record will NOT overwrite a cassette that already exists —
    # delete it first, then re-record. Filenames are auto-derived; list them:
    ls test/fixtures/vcr_cassettes/<TestClass>/
    rm test/fixtures/vcr_cassettes/<TestClass>/<cassette>.yml   # or rm -r the class dir
    VCR_MODE=record bundle exec rake test:integration

Refresh ALL cassettes:
    VCR_MODE=all bundle exec rake test:integration
```

Recording needs live credentials in the environment — `XERO_CLIENT_ID`,
`XERO_CLIENT_SECRET`, `XERO_ACCESS_TOKEN`, `XERO_TENANT_ID`; replay needs none.
The mutating tests (`about_creating_*`, bulk operations) write real data when
recorded, so always record against a Xero **Demo Company** org, not production.

Each test gets one cassette named after it; renaming a test orphans its cassette
(delete the stale file). Cassettes replay requests in recorded order, so don't
reorder a test's API calls without re-recording.

## Before recording

The org you record against must already contain the data each test reads:

- `about_online_invoice` — at least one `ACCREC` and one `ACCPAY` invoice, the
  `ACCREC` one approved so Xero issues an online-invoice URL.
- `bank_transfer` — at least **two** distinct `ACTIVE` bank accounts (it transfers
  between `.first` and `.last`).
- `about_creating_*` / `about_fetching_*` — at least one `ACTIVE` `REVENUE` and one
  `ACTIVE` `BANK` account; the fetching test seeds its own bank transaction.
- `about_fetching_bank_transactions` asserts the **exact** attribute-key set Xero
  returns. If a first recording fails there, Xero's shape has drifted since the
  test was written — update the expected keys to match (that drift is the point).

## Secrets

The configured credentials and the `Authorization` header are auto-filtered, and
the `connections` response (org names/IDs) is redacted. Everything else in a
response body — record IDs, contact names, amounts — is **not**. Record against a
Demo Company and **review the full cassette diff before committing**; a changed
field in that diff is also your signal that Xero's response shape drifted.
