/* Testing tables */
CREATE TABLE cached_objects ("id" SERIAL PRIMARY KEY, "name" TEXT, "goal" TEXT);
CREATE TABLE custom_classes ("id" SERIAL PRIMARY KEY, "name" TEXT, "goal" TEXT);
CREATE TABLE another_classes ("id" SERIAL PRIMARY KEY, number INTEGER, "custom_class_id" INTEGER REFERENCES custom_classes("id"));
CREATE TABLE mailboxes ("id" SERIAL PRIMARY KEY, "name" TEXT);
CREATE TABLE messages ("id" SERIAL PRIMARY KEY, "subject" TEXT, "from" TEXT, "mailbox_id" INTEGER REFERENCES mailboxes("id"));

/* Real tables */
CREATE TABLE providers ("id" SERIAL PRIMARY KEY, "name" TEXT, "imap_host" TEXT, "imap_port" INTEGER, "imap_secure" BOOLEAN, "smtp_host" TEXT, "smtp_port" INTEGER, "smtp_secure" BOOLEAN);
CREATE TABLE domains ("id" SERIAL PRIMARY KEY, "name" TEXT, "provider_id" INTEGER REFERENCES providers("id"));