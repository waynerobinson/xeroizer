# Integration tests

These run the gem against the Xero API. They write data into Xero, so they
need a **Demo Company**: the run aborts on any other org. They also need
credentials, so CI doesn't run them, and without credentials every test is
skipped.

## Setup (once)

1. Create a free Xero account and open its Demo Company.
2. At <https://developer.xero.com>, add a **New app**:
   - Integration type: **Web app**.
   - Company or application URL: any URL.
   - OAuth 2.0 redirect URI: `http://localhost:8749/callback`.
3. On the app's **Configuration** page, copy the client id and generate a
   secret. Put both in `.xero.env` in the repo root (gitignored):

       XERO_CLIENT_ID=...
       XERO_CLIENT_SECRET=...

4. Log in and approve the Demo Company:

       bundle exec rake xero:login

   This saves `XERO_ACCESS_TOKEN`, `XERO_REFRESH_TOKEN` and `XERO_TENANT_ID` to
   `.xero.env`.

If port 8749 is taken, add another redirect URI on the Configuration page and
set it as `XERO_REDIRECT_URI` in `.xero.env`. The two must match exactly.

## Run

    bundle exec rake xero:token test:integration

`xero:token` reuses the access token, refreshes it (it lasts 30 minutes), or
opens the browser login when the refresh token is gone. It also updates
`XERO_TENANT_ID` after the Demo Company is reset. Set `XERO_ENV_FILE` to keep
the file elsewhere.

Variables set in the environment win over the file. The exception is
`xero:token`: it reads the access and refresh tokens only from the file,
because it saves the new ones there. In `rake xero:token test:integration`,
the tests use those tokens. If you export the tokens yourself, run
`test:integration` without `xero:token`.

A refresh token works only with the app that issued it. So `xero:token` stops
if `XERO_CLIENT_ID` in the environment differs from the one in the file.

## Data each test needs

- `online_invoice`: at least one `ACCREC` and one `ACCPAY` invoice, the
  `ACCREC` one approved so Xero issues an online-invoice URL.
- `bank_transfer`: at least **two** `ACTIVE` bank accounts (it transfers between
  `.first` and `.last`).
- `creating_*`, `fetching_*`: at least one `ACTIVE` `REVENUE` and
  one `ACTIVE` `BANK` account; the fetching test creates its own bank transaction.
- `fetching_bank_transactions` asserts the **exact** attribute keys Xero
  returns, so it fails when Xero adds or drops one.
