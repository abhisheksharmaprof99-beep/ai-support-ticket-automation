# AI Support Ticket Triage

An automated customer support workflow that classifies incoming tickets using Google Gemini, logs them to Supabase, and routes them intelligently — routine questions get an instant AI-drafted reply, urgent/complex issues get escalated straight to a human agent.

## Problem

Growing businesses often get flooded with support requests. Manually reading, categorizing, and replying to every ticket wastes agent time on routine questions (order status, shipping delays, FAQs) while urgent issues risk getting buried in the queue.

## How it works

```
Customer submits ticket (webhook)
        ↓
Google Gemini classifies category + urgency
        ↓
Ticket logged to Supabase (audit trail)
        ↓
   ┌────┴────┐
   ↓         ↓
Urgent    Routine
   ↓         ↓
Alert     Auto-reply
agent     to customer
```

1. **Webhook** receives a new ticket (`customer_email`, `subject`, `body`).
2. **Gemini (gemini-3.6-flash)** reads the message and returns a category (e.g. shipping, billing) and urgency level (low/medium/high).
3. The result is parsed and merged with the original ticket data.
4. The combined record is inserted into a **Supabase** `ticket` table for tracking.
5. An **IF** node checks urgency:
   - **High** → sends an internal alert email to the support team with the full ticket details.
   - **Medium/Low** → sends an automatic acknowledgment reply to the customer.

## Tech stack

- **n8n** — workflow orchestration
- **Google Gemini API** (`gemini-3.6-flash`) — ticket classification
- **Supabase** — Postgres database for ticket storage
- **Gmail (OAuth2)** — sending replies/alerts

## Repo contents

- `schema.sql` — Supabase table structure for the `ticket` table
- `workflow.json` — importable n8n workflow (credentials removed — see setup below)

## Setup

1. **Supabase**: create a project, run `schema.sql` in the SQL Editor to create the `ticket` table.
2. **Gemini**: get an API key from [Google AI Studio](https://aistudio.google.com/app/apikey).
3. **n8n**: import `workflow.json`, then:
   - Open the **HTTP Request** node → replace the `x-goog-api-key` header value with your own Gemini key (ideally stored as a credential, not typed directly into the node).
   - Open the **Supabase** node → connect your own Supabase credential.
   - Open both **Gmail** nodes → connect your own Gmail OAuth2 credential, and set the internal alert email to your own address.
4. Activate the workflow and send a test POST request to the webhook URL:
   ```json
   {
     "customer_email": "test@customer.com",
     "subject": "Order delay",
     "body": "My order has not arrived yet"
   }
   ```

## Status

Working prototype / practice build. Not yet hardened for production — see notes below before using with real customer data.

## Before using with real clients

- Currently running on free tiers (n8n, Supabase, Gemini) — fine for a demo/pilot, but rate limits and inactivity pauses mean a paid tier is needed for live use.
- No Row Level Security (RLS) policies configured yet on the Supabase table.
- No retry/error-handling branch yet for failed Gemini calls or malformed responses.
