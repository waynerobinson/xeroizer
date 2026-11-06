# Integration tests

These run the gem against the Xero API. They write data into Xero, so they
need a **Demo Company**: the run aborts on any other org. They also need
credentials, so CI doesn't run them, and without credentials every test is
skipped.

## Run

Set `XERO_CLIENT_ID`, `XERO_CLIENT_SECRET`, `XERO_ACCESS_TOKEN` and
`XERO_TENANT_ID` for a Demo Company in the environment, then:

    bundle exec rake test:integration

## Data each test needs

- `online_invoice`: at least one `ACCREC` and one `ACCPAY` invoice, the
  `ACCREC` one approved so Xero issues an online-invoice URL.
- `bank_transfer`: at least **two** `ACTIVE` bank accounts (it transfers between
  `.first` and `.last`).
- `creating_*`, `fetching_*`: at least one `ACTIVE` `REVENUE` and
  one `ACTIVE` `BANK` account; the fetching test creates its own bank transaction.
- `fetching_bank_transactions` asserts the **exact** attribute keys Xero
  returns, so it fails when Xero adds or drops one.
