SET check_function_bodies = false;
CREATE TABLE public.chats (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    type text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    title text,
    avatar_url text,
    description text,
    last_message_id uuid,
    updated_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    CONSTRAINT chats_type_check CHECK ((type = ANY (ARRAY['private'::text, 'group'::text])))
);
CREATE FUNCTION public.create_private_chat(user_a uuid, user_b uuid) RETURNS public.chats
    LANGUAGE plpgsql
    AS $$
DECLARE
  existing_chat chats;
  new_chat chats;
BEGIN
  SELECT c.*
  INTO existing_chat
  FROM chats c
  JOIN chat_participants p1 ON p1.chat_id = c.id
  JOIN chat_participants p2 ON p2.chat_id = c.id
  WHERE p1.user_id = user_a
    AND p2.user_id = user_b
  LIMIT 1;
  IF FOUND THEN
    RETURN existing_chat;
  END IF;
  INSERT INTO chats(type)
  VALUES ('private')
  RETURNING * INTO new_chat;
  INSERT INTO chat_participants(chat_id, user_id)
  VALUES
    (new_chat.id, user_a),
    (new_chat.id, user_b);
  RETURN new_chat;
END;
$$;
CREATE TABLE public.chat_participants (
    chat_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role text DEFAULT 'member'::text,
    joined_at timestamp with time zone DEFAULT now(),
    CONSTRAINT chat_participants_role_check CHECK ((role = ANY (ARRAY['member'::text, 'admin'::text, 'owner'::text])))
);
CREATE TABLE public.messages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    chat_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    type text DEFAULT 'text'::text,
    status text DEFAULT 'sent'::text,
    edited_at timestamp with time zone,
    reply_to_message_id uuid,
    attachment_url text,
    local_temp_id text,
    CONSTRAINT messages_status_check CHECK ((status = ANY (ARRAY['sent'::text, 'delivered'::text, 'read'::text]))),
    CONSTRAINT messages_type_check CHECK ((type = ANY (ARRAY['text'::text, 'image'::text, 'file'::text, 'system'::text])))
);
CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    username text,
    display_name text,
    avatar_url text,
    about text,
    last_seen timestamp with time zone,
    online_status text DEFAULT 'offline'::text,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT users_online_status_check CHECK ((online_status = ANY (ARRAY['online'::text, 'offline'::text, 'recent'::text, 'hidden'::text])))
);
ALTER TABLE ONLY public.chat_participants
    ADD CONSTRAINT chat_participants_pkey PRIMARY KEY (chat_id, user_id);
ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);
ALTER TABLE ONLY public.chat_participants
    ADD CONSTRAINT chat_participants_chat_id_fkey FOREIGN KEY (chat_id) REFERENCES public.chats(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.chat_participants
    ADD CONSTRAINT chat_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);
ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_last_message_id_fkey FOREIGN KEY (last_message_id) REFERENCES public.messages(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_chat_id_fkey FOREIGN KEY (chat_id) REFERENCES public.chats(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_reply_to_message_id_fkey FOREIGN KEY (reply_to_message_id) REFERENCES public.messages(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;
