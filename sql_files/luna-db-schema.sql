--
-- PostgreSQL database dump
--

\restrict t8a5O8l3KIVxP1rmAnxVoj93zhthH4vJFzm9OO3pMf0sAAmaneZrBHo4iZoxIux

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
-- Name: account_role; Type: TYPE; Schema: public; Owner: test-db-user
--

CREATE TYPE public.account_role AS ENUM (
    'student',
    'course_manager',
    'moderator',
    'administrator'
);


ALTER TYPE public.account_role OWNER TO "test-db-user";

--
-- Name: attachment_type; Type: TYPE; Schema: public; Owner: test-db-user
--

CREATE TYPE public.attachment_type AS ENUM (
    'task_question',
    'task_answer',
    'forum_thread_message',
    'forum_private_message'
);


ALTER TYPE public.attachment_type OWNER TO "test-db-user";

--
-- Name: notification_type; Type: TYPE; Schema: public; Owner: test-db-user
--

CREATE TYPE public.notification_type AS ENUM (
    'announcement',
    'course_invitation',
    'course_start',
    'task_started',
    'task_reviewed',
    'task_due_soon',
    'task_due',
    'forum_private_message'
);


ALTER TYPE public.notification_type OWNER TO "test-db-user";

--
-- Name: task_type; Type: TYPE; Schema: public; Owner: test-db-user
--

CREATE TYPE public.task_type AS ENUM (
    'non_interactive',
    'single_qa',
    'test_qa_free',
    'test_qa_predefined'
);


ALTER TYPE public.task_type OWNER TO "test-db-user";

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.accounts (
    id uuid DEFAULT uuidv7() NOT NULL,
    role public.account_role NOT NULL,
    name text NOT NULL,
    email_address text NOT NULL,
    password_hash bytea NOT NULL
);


ALTER TABLE public.accounts OWNER TO "test-db-user";

--
-- Name: accounts_recovery_codes; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.accounts_recovery_codes (
    code_hash bytea CONSTRAINT account_recovery_codes_code_hash_not_null NOT NULL,
    account_id uuid CONSTRAINT account_recovery_codes_account_id_not_null NOT NULL,
    used_at timestamp with time zone
);


ALTER TABLE public.accounts_recovery_codes OWNER TO "test-db-user";

--
-- Name: accounts_totp; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.accounts_totp (
    account_id uuid CONSTRAINT account_totp_account_id_not_null NOT NULL,
    name text CONSTRAINT account_totp_name_not_null NOT NULL,
    secret_enc bytea CONSTRAINT account_totp_secret_enc_not_null NOT NULL,
    last_used_step text,
    failed_attempts integer,
    locked_until timestamp with time zone,
    confirmed boolean DEFAULT false CONSTRAINT account_totp_confirmed_not_null NOT NULL
);


ALTER TABLE public.accounts_totp OWNER TO "test-db-user";

--
-- Name: accounts_totp_attempts; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.accounts_totp_attempts (
    id uuid DEFAULT uuidv7() CONSTRAINT account_totp_attempts_totp_attempt_id_not_null NOT NULL,
    account_id uuid CONSTRAINT account_totp_attempts_account_id_not_null NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:05:00'::interval) NOT NULL
);


ALTER TABLE public.accounts_totp_attempts OWNER TO "test-db-user";

--
-- Name: courses; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.courses (
    id uuid DEFAULT uuidv7() NOT NULL,
    title text NOT NULL,
    description text,
    keywords text[],
    started_at timestamp with time zone NOT NULL,
    ended_at timestamp with time zone,
    CONSTRAINT courses_check CHECK ((started_at < ended_at))
);


ALTER TABLE public.courses OWNER TO "test-db-user";

--
-- Name: courses_managers; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.courses_managers (
    account_id uuid NOT NULL,
    course_id uuid NOT NULL,
    main_manager boolean NOT NULL
);


ALTER TABLE public.courses_managers OWNER TO "test-db-user";

--
-- Name: courses_participants; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.courses_participants (
    account_id uuid NOT NULL,
    course_id uuid NOT NULL,
    confirmed boolean DEFAULT false NOT NULL
);


ALTER TABLE public.courses_participants OWNER TO "test-db-user";

--
-- Name: devices; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.devices (
    id uuid DEFAULT uuidv7() NOT NULL,
    account_id uuid NOT NULL,
    last_online_at timestamp with time zone DEFAULT now() NOT NULL,
    session_token_hash bytea NOT NULL,
    session_expires_at timestamp with time zone DEFAULT (now() + '00:05:00'::interval) NOT NULL
);


ALTER TABLE public.devices OWNER TO "test-db-user";

--
-- Name: files_attachments; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.files_attachments (
    id uuid DEFAULT uuidv7() NOT NULL,
    location text NOT NULL,
    size bigint NOT NULL,
    hash bytea NOT NULL,
    attached_to public.attachment_type NOT NULL,
    attachment_id uuid NOT NULL,
    CONSTRAINT files_attachments_size_check CHECK ((size > 0))
);


ALTER TABLE public.files_attachments OWNER TO "test-db-user";

--
-- Name: forum_private_messages; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.forum_private_messages (
    id uuid DEFAULT uuidv7() NOT NULL,
    sender_id uuid NOT NULL,
    receiver_id uuid NOT NULL,
    content jsonb,
    pinned boolean DEFAULT false NOT NULL,
    file_added boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone,
    CONSTRAINT forum_private_messages_check CHECK ((receiver_id <> sender_id)),
    CONSTRAINT forum_private_messages_check1 CHECK ((modified_at > created_at))
);


ALTER TABLE public.forum_private_messages OWNER TO "test-db-user";

--
-- Name: forum_threads; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.forum_threads (
    id uuid DEFAULT uuidv7() NOT NULL,
    title text NOT NULL,
    creator_id uuid NOT NULL,
    course_id uuid NOT NULL,
    pinned boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.forum_threads OWNER TO "test-db-user";

--
-- Name: forum_threads_messages; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.forum_threads_messages (
    id uuid DEFAULT uuidv7() NOT NULL,
    sender_id uuid NOT NULL,
    thread_id uuid NOT NULL,
    content jsonb,
    pinned boolean DEFAULT false NOT NULL,
    file_added boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone,
    CONSTRAINT forum_threads_messages_check CHECK ((modified_at > created_at))
);


ALTER TABLE public.forum_threads_messages OWNER TO "test-db-user";

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.notifications (
    id uuid DEFAULT uuidv7() NOT NULL,
    receiver_id uuid,
    type public.notification_type NOT NULL,
    content jsonb,
    source_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    read_at timestamp with time zone,
    CONSTRAINT notifications_check CHECK ((read_at > created_at))
);


ALTER TABLE public.notifications OWNER TO "test-db-user";

--
-- Name: tasks; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.tasks (
    id uuid DEFAULT uuidv7() NOT NULL,
    title text NOT NULL,
    type public.task_type NOT NULL,
    visible boolean DEFAULT false NOT NULL,
    started_at timestamp with time zone NOT NULL,
    ended_at timestamp with time zone,
    max_session_time integer,
    CONSTRAINT tasks_check CHECK ((started_at < ended_at))
);


ALTER TABLE public.tasks OWNER TO "test-db-user";

--
-- Name: tasks_answers; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.tasks_answers (
    id uuid DEFAULT uuidv7() NOT NULL,
    question_id uuid NOT NULL,
    account_id uuid NOT NULL,
    content jsonb,
    file_added boolean DEFAULT false NOT NULL,
    confimred_at timestamp with time zone NOT NULL
);


ALTER TABLE public.tasks_answers OWNER TO "test-db-user";

--
-- Name: tasks_questions; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.tasks_questions (
    id uuid DEFAULT uuidv7() NOT NULL,
    task_id uuid NOT NULL,
    "position" integer NOT NULL,
    content jsonb,
    file_added boolean DEFAULT false NOT NULL,
    correct_answer text,
    max_score integer,
    CONSTRAINT tasks_questions_max_score_check CHECK ((max_score > '-1'::integer)),
    CONSTRAINT tasks_questions_position_check CHECK (("position" > '-1'::integer))
);


ALTER TABLE public.tasks_questions OWNER TO "test-db-user";

--
-- Name: tasks_sessions; Type: TABLE; Schema: public; Owner: test-db-user
--

CREATE TABLE public.tasks_sessions (
    id uuid DEFAULT uuidv7() NOT NULL,
    task_id uuid NOT NULL,
    account_id uuid NOT NULL,
    started_at timestamp with time zone NOT NULL,
    ended_at timestamp with time zone,
    CONSTRAINT tasks_sessions_check CHECK ((started_at < ended_at))
);


ALTER TABLE public.tasks_sessions OWNER TO "test-db-user";

--
-- Name: accounts_recovery_codes account_recovery_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.accounts_recovery_codes
    ADD CONSTRAINT account_recovery_codes_pkey PRIMARY KEY (code_hash, account_id);


--
-- Name: accounts_totp account_totp_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.accounts_totp
    ADD CONSTRAINT account_totp_pkey PRIMARY KEY (account_id);


--
-- Name: accounts_totp account_totp_secret_enc_key; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.accounts_totp
    ADD CONSTRAINT account_totp_secret_enc_key UNIQUE (secret_enc);


--
-- Name: accounts accounts_email_address_key; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_email_address_key UNIQUE (email_address);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: courses_managers courses_managers_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.courses_managers
    ADD CONSTRAINT courses_managers_pkey PRIMARY KEY (account_id, course_id);


--
-- Name: courses_participants courses_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.courses_participants
    ADD CONSTRAINT courses_participants_pkey PRIMARY KEY (account_id, course_id);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: devices devices_session_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_session_token_hash_key UNIQUE (session_token_hash);


--
-- Name: files_attachments files_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.files_attachments
    ADD CONSTRAINT files_attachments_pkey PRIMARY KEY (id);


--
-- Name: forum_private_messages forum_private_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.forum_private_messages
    ADD CONSTRAINT forum_private_messages_pkey PRIMARY KEY (id);


--
-- Name: forum_threads_messages forum_threads_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.forum_threads_messages
    ADD CONSTRAINT forum_threads_messages_pkey PRIMARY KEY (id);


--
-- Name: forum_threads forum_threads_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.forum_threads
    ADD CONSTRAINT forum_threads_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: tasks_answers tasks_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.tasks_answers
    ADD CONSTRAINT tasks_answers_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: tasks_questions tasks_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.tasks_questions
    ADD CONSTRAINT tasks_questions_pkey PRIMARY KEY (id);


--
-- Name: tasks_sessions tasks_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.tasks_sessions
    ADD CONSTRAINT tasks_sessions_pkey PRIMARY KEY (id);


--
-- Name: accounts_recovery_codes account_recovery_codes_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.accounts_recovery_codes
    ADD CONSTRAINT account_recovery_codes_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: accounts_totp account_totp_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.accounts_totp
    ADD CONSTRAINT account_totp_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: accounts_totp_attempts account_totp_attempts_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.accounts_totp_attempts
    ADD CONSTRAINT account_totp_attempts_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: courses_managers courses_managers_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.courses_managers
    ADD CONSTRAINT courses_managers_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: courses_managers courses_managers_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.courses_managers
    ADD CONSTRAINT courses_managers_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id);


--
-- Name: courses_participants courses_participants_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.courses_participants
    ADD CONSTRAINT courses_participants_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: courses_participants courses_participants_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.courses_participants
    ADD CONSTRAINT courses_participants_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id);


--
-- Name: devices devices_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: forum_private_messages forum_private_messages_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.forum_private_messages
    ADD CONSTRAINT forum_private_messages_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.accounts(id);


--
-- Name: forum_private_messages forum_private_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.forum_private_messages
    ADD CONSTRAINT forum_private_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.accounts(id);


--
-- Name: forum_threads forum_threads_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.forum_threads
    ADD CONSTRAINT forum_threads_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id);


--
-- Name: forum_threads forum_threads_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.forum_threads
    ADD CONSTRAINT forum_threads_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.accounts(id);


--
-- Name: forum_threads_messages forum_threads_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.forum_threads_messages
    ADD CONSTRAINT forum_threads_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.accounts(id);


--
-- Name: forum_threads_messages forum_threads_messages_thread_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.forum_threads_messages
    ADD CONSTRAINT forum_threads_messages_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.forum_threads(id);


--
-- Name: notifications notifications_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.accounts(id);


--
-- Name: tasks_answers tasks_answers_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.tasks_answers
    ADD CONSTRAINT tasks_answers_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: tasks_answers tasks_answers_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.tasks_answers
    ADD CONSTRAINT tasks_answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.tasks_questions(id);


--
-- Name: tasks_questions tasks_questions_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.tasks_questions
    ADD CONSTRAINT tasks_questions_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: tasks_sessions tasks_sessions_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.tasks_sessions
    ADD CONSTRAINT tasks_sessions_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: tasks_sessions tasks_sessions_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: test-db-user
--

ALTER TABLE ONLY public.tasks_sessions
    ADD CONSTRAINT tasks_sessions_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- PostgreSQL database dump complete
--

\unrestrict t8a5O8l3KIVxP1rmAnxVoj93zhthH4vJFzm9OO3pMf0sAAmaneZrBHo4iZoxIux

