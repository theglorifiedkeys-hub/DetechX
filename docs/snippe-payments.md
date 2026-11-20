# Snippe integration plan

This branch runs a **local simulated checkout only**. It never sends a payment request, collects a mobile-money PIN or marks a real invoice as settled. The `PaymentGateway` contract gives the Flutter screen a boundary for a future adapter that calls the DetechX backend, not Snippe directly.

## When merchant onboarding is ready

1. Complete the [Snippe merchant KYC](https://dashboard.snippe.sh/dashboard/account/kyc?nav=settings) privately. Confirm the enabled payment methods, supported test environment, API version, webhook verification mechanism and reconciliation endpoints with Snippe. [Snippe](https://snippe.sh/) advertises M-Pesa, Airtel Money and bank payments; what DetechX can offer depends on the approved account.
2. Save jobs and invoices on the backend. Enforce ownership, authorized technician milestones and customer confirmation. Generate the final invoice in TZS server-side after the job is complete. The app must not be able to set the charge amount or mark a job paid.
3. Create or reuse one active payment attempt per invoice with a server-side idempotency key. Keep Snippe credentials in server-side secret storage. Return a hosted checkout action (or a mobile-money request status, depending on approved methods), not credentials. Use an opaque invoice/attempt ID when polling.
4. Treat mobile redirects and client confirmations as UX signals only. Verify the authenticated provider callback or check provider status from the backend; reconcile invoice identity, currency, amount and reference before issuing a receipt. Handle duplicate or out-of-order events and reconcile pending attempts before retrying. Keep checkout pending on ambiguous failures rather than creating a second charge.
5. Validate the real flow with test credentials before enabling payments: success, declined, expired, duplicate callback, network timeout and app restart. Confirm fundi payouts and refunds separately; they are not part of this checkout.
