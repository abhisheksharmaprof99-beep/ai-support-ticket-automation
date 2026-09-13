create table public.ticket (
  id uuid not null default gen_random_uuid (),
  customer_email text null,
  subject text null,
  body text null,
  category text null default 'other'::text,
  urgency text null default 'medium'::text,
  status text null default 'new'::text,
  draft_respone text null default ''::text,
  created_at timestamp without time zone null,
  constraint ticket_pkey primary key (id)
) TABLESPACE pg_default;
