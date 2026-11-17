--
-- PostgreSQL database dump
--

\restrict XKbnhJhLyRnWlT4CD3c5jrAvI5d9P0heEMJwpenh5W12eDb5W5KahWE0PPKTrTs

-- Dumped from database version 18.7 (Debian 18.7-1.pgdg13+2)
-- Dumped by pg_dump version 18.7 (Debian 18.7-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.accounts (id, role, name, email_address, password_hash) FROM stdin;
01a1e7b8-66c6-7a20-98b8-9ecdc7acc937	student	Alice	test@example.com	\\x24326224313024646e546b78763779473838616c2f4459617172367465326c736b7249533459715148564970634d456765593469386b6c596649382e
\.


--
-- Data for Name: accounts_recovery_codes; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.accounts_recovery_codes (code_hash, account_id, used_at) FROM stdin;
\.


--
-- Data for Name: accounts_totp; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.accounts_totp (account_id, name, secret_enc, last_used_step, failed_attempts, locked_until, confirmed) FROM stdin;
\.


--
-- Data for Name: accounts_totp_attempts; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.accounts_totp_attempts (id, account_id, expires_at) FROM stdin;
\.


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.courses (id, title, description, keywords, started_at, ended_at) FROM stdin;
\.


--
-- Data for Name: courses_managers; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.courses_managers (account_id, course_id, main_manager) FROM stdin;
\.


--
-- Data for Name: courses_participants; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.courses_participants (account_id, course_id, confirmed) FROM stdin;
\.


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.devices (id, account_id, last_online_at, session_token_hash, session_expires_at) FROM stdin;
\.


--
-- Data for Name: files_attachments; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.files_attachments (id, location, size, hash, attached_to, attachment_id) FROM stdin;
\.


--
-- Data for Name: forum_private_messages; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.forum_private_messages (id, sender_id, receiver_id, content, pinned, file_added, created_at, modified_at) FROM stdin;
\.


--
-- Data for Name: forum_threads; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.forum_threads (id, title, creator_id, course_id, pinned, created_at) FROM stdin;
\.


--
-- Data for Name: forum_threads_messages; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.forum_threads_messages (id, sender_id, thread_id, content, pinned, file_added, created_at, modified_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.notifications (id, receiver_id, type, content, source_id, created_at, read_at) FROM stdin;
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.tasks (id, title, type, visible, started_at, ended_at, max_session_time) FROM stdin;
\.


--
-- Data for Name: tasks_questions; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.tasks_questions (id, task_id, "position", content, file_added, correct_answer, max_score) FROM stdin;
\.


--
-- Data for Name: tasks_answers; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.tasks_answers (id, question_id, account_id, content, file_added, confimred_at) FROM stdin;
\.


--
-- Data for Name: tasks_sessions; Type: TABLE DATA; Schema: public; Owner: test-db-user
--

COPY public.tasks_sessions (id, task_id, account_id, started_at, ended_at) FROM stdin;
\.


--
-- PostgreSQL database dump complete
--

\unrestrict XKbnhJhLyRnWlT4CD3c5jrAvI5d9P0heEMJwpenh5W12eDb5W5KahWE0PPKTrTs

