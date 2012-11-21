CREATE TABLE providers ("id" SERIAL PRIMARY KEY, "name" TEXT, "imap_host" TEXT, "imap_port" INTEGER, "imap_secure" BOOLEAN, "smtp_host" TEXT, "smtp_port" INTEGER, "smtp_secure" BOOLEAN);
CREATE TABLE domains ("id" SERIAL PRIMARY KEY, "name" TEXT, "provider_id" INTEGER REFERENCES providers("id"));
CREATE TABLE accounts ("id" SERIAL PRIMARY KEY, "email_address" TEXT, "provider_id" INTEGER REFERENCES providers("id"));
CREATE TABLE mailboxes ("id" SERIAL PRIMARY KEY, "name" TEXT, "selectable" BOOLEAN, "uid_validity" INTEGER, "account_id" INTEGER REFERENCES accounts("id"), "mailbox_id" INTEGER REFERENCES mailboxes("id"));
CREATE TABLE messages ("id" SERIAL PRIMARY KEY, "uid" INTEGER, "seqno" INTEGER, "json" JSON, "mailbox_id" INTEGER REFERENCES mailboxes("id"));