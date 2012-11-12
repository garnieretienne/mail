/* Testing tables */
CREATE TABLE cached_objects ("id" SERIAL PRIMARY KEY, "name" TEXT, "goal" TEXT);
CREATE TABLE custom_classes ("id" SERIAL PRIMARY KEY, "name" TEXT, "goal" TEXT);
CREATE TABLE another_classes ("id" SERIAL PRIMARY KEY, number INTEGER, "custom_class_id" INTEGER REFERENCES custom_classes("id"));
CREATE TABLE mailboxes ("id" SERIAL PRIMARY KEY, "name" TEXT);
CREATE TABLE messages ("id" SERIAL PRIMARY KEY, "subject" TEXT, "from" TEXT, "mailbox_id" INTEGER REFERENCES mailboxes("id"));