ALTER TABLE users
    ADD COLUMN username TEXT UNIQUE,
    ADD COLUMN display_name TEXT,
    ADD COLUMN avatar_url TEXT,
    ADD COLUMN about TEXT,
    ADD COLUMN last_seen TIMESTAMP WITH TIME ZONE,
    ADD COLUMN online_status TEXT CHECK (online_status IN ('online', 'offline', 'recent', 'hidden')) DEFAULT 'offline',
    ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT now();

ALTER TABLE chats
    ADD COLUMN title TEXT,
    ADD COLUMN avatar_url TEXT,
    ADD COLUMN description TEXT,
    ADD COLUMN last_message_id UUID REFERENCES messages(id) ON DELETE SET NULL,
    ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    ADD COLUMN created_by UUID REFERENCES users(id);

ALTER TABLE chat_participants
    ADD COLUMN role TEXT CHECK (role IN ('member', 'admin', 'owner')) DEFAULT 'member',
    ADD COLUMN joined_at TIMESTAMP WITH TIME ZONE DEFAULT now();

ALTER TABLE messages
    ADD COLUMN type TEXT CHECK (type IN ('text', 'image', 'file', 'system')) DEFAULT 'text',
    ADD COLUMN status TEXT CHECK (status IN ('sent', 'delivered', 'read')) DEFAULT 'sent',
    ADD COLUMN edited_at TIMESTAMP WITH TIME ZONE,
    ADD COLUMN reply_to_message_id UUID REFERENCES messages(id) ON DELETE SET NULL,
    ADD COLUMN attachment_url TEXT,
    ADD COLUMN local_temp_id TEXT;