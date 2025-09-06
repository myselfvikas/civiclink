-- Location: supabase/migrations/20250906124615_civic_platform_complete.sql
-- Schema Analysis: Fresh project - no existing schema
-- Integration Type: Complete civic platform with authentication
-- Dependencies: None - fresh start

-- 1. Custom Types
CREATE TYPE public.user_role AS ENUM ('citizen', 'admin', 'inspector', 'government_official');
CREATE TYPE public.issue_status AS ENUM ('pending', 'in_progress', 'resolved', 'rejected');
CREATE TYPE public.issue_priority AS ENUM ('low', 'medium', 'high', 'urgent');
CREATE TYPE public.issue_category AS ENUM ('lighting', 'road_damage', 'garbage', 'water', 'noise', 'parks', 'transportation', 'other');

-- 2. Core Tables
-- User profiles table (critical intermediary for PostgREST compatibility)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'citizen'::public.user_role,
    phone TEXT,
    address TEXT,
    government_id TEXT UNIQUE,
    is_active BOOLEAN DEFAULT true,
    profile_image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Issues table
CREATE TABLE public.civic_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category public.issue_category NOT NULL,
    priority public.issue_priority DEFAULT 'medium'::public.issue_priority,
    status public.issue_status DEFAULT 'pending'::public.issue_status,
    location_address TEXT NOT NULL,
    location_coordinates POINT,
    image_urls TEXT[],
    is_anonymous BOOLEAN DEFAULT false,
    allow_public_view BOOLEAN DEFAULT true,
    assigned_to UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    department TEXT,
    votes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Issue comments table
CREATE TABLE public.issue_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID REFERENCES public.civic_issues(id) ON DELETE CASCADE,
    commenter_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_official BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Issue votes/support table
CREATE TABLE public.issue_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID REFERENCES public.civic_issues(id) ON DELETE CASCADE,
    voter_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(issue_id, voter_id)
);

-- Issue status updates table (for tracking progress)
CREATE TABLE public.issue_status_updates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID REFERENCES public.civic_issues(id) ON DELETE CASCADE,
    updated_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    old_status public.issue_status,
    new_status public.issue_status NOT NULL,
    update_message TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_civic_issues_reporter ON public.civic_issues(reporter_id);
CREATE INDEX idx_civic_issues_status ON public.civic_issues(status);
CREATE INDEX idx_civic_issues_category ON public.civic_issues(category);
CREATE INDEX idx_civic_issues_priority ON public.civic_issues(priority);
CREATE INDEX idx_civic_issues_created_at ON public.civic_issues(created_at);
CREATE INDEX idx_civic_issues_location_gist ON public.civic_issues USING GIST (location_coordinates);
CREATE INDEX idx_issue_comments_issue ON public.issue_comments(issue_id);
CREATE INDEX idx_issue_votes_issue ON public.issue_votes(issue_id);
CREATE INDEX idx_issue_status_updates_issue ON public.issue_status_updates(issue_id);

-- 4. Storage Buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('issue-images', 'issue-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']),
    ('profile-images', 'profile-images', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']);

-- 5. Helper Functions (MUST BE BEFORE RLS POLICIES)
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Function to update issue votes count
CREATE OR REPLACE FUNCTION public.update_issue_votes_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.civic_issues 
        SET votes_count = votes_count + 1 
        WHERE id = NEW.issue_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.civic_issues 
        SET votes_count = votes_count - 1 
        WHERE id = OLD.issue_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;

-- Function to update issue comments count
CREATE OR REPLACE FUNCTION public.update_issue_comments_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.civic_issues 
        SET comments_count = comments_count + 1 
        WHERE id = NEW.issue_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.civic_issues 
        SET comments_count = comments_count - 1 
        WHERE id = OLD.issue_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;

-- Function for automatic user profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, role)
    VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'citizen'::public.user_role)
    );
    RETURN NEW;
END;
$$;

-- Function to check if user is admin or government official
CREATE OR REPLACE FUNCTION public.is_admin_or_official()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'admin' 
         OR au.raw_user_meta_data->>'role' = 'inspector'
         OR au.raw_user_meta_data->>'role' = 'government_official')
)
$$;

-- 6. Enable RLS on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.civic_issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.issue_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.issue_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.issue_status_updates ENABLE ROW LEVEL SECURITY;

-- 7. RLS Policies
-- User profiles policies (Pattern 1: Core user table)
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Public can view active user profiles for transparency
CREATE POLICY "public_can_view_active_profiles"
ON public.user_profiles
FOR SELECT
TO public
USING (is_active = true);

-- Civic issues policies
-- Citizens can view public issues
CREATE POLICY "public_can_view_public_issues"
ON public.civic_issues
FOR SELECT
TO public
USING (allow_public_view = true);

-- Users can create issues
CREATE POLICY "users_can_create_issues"
ON public.civic_issues
FOR INSERT
TO authenticated
WITH CHECK (reporter_id = auth.uid());

-- Users can update their own issues
CREATE POLICY "users_can_update_own_issues"
ON public.civic_issues
FOR UPDATE
TO authenticated
USING (reporter_id = auth.uid())
WITH CHECK (reporter_id = auth.uid());

-- Admins/Officials can update any issue
CREATE POLICY "officials_can_manage_issues"
ON public.civic_issues
FOR ALL
TO authenticated
USING (public.is_admin_or_official())
WITH CHECK (public.is_admin_or_official());

-- Issue comments policies
-- Public can view comments on public issues
CREATE POLICY "public_can_view_issue_comments"
ON public.issue_comments
FOR SELECT
TO public
USING (
    EXISTS (
        SELECT 1 FROM public.civic_issues ci 
        WHERE ci.id = issue_id AND ci.allow_public_view = true
    )
);

-- Users can create comments
CREATE POLICY "users_can_create_comments"
ON public.issue_comments
FOR INSERT
TO authenticated
WITH CHECK (commenter_id = auth.uid());

-- Users can update their own comments
CREATE POLICY "users_can_update_own_comments"
ON public.issue_comments
FOR UPDATE
TO authenticated
USING (commenter_id = auth.uid())
WITH CHECK (commenter_id = auth.uid());

-- Issue votes policies
-- Users can vote on public issues
CREATE POLICY "users_can_vote_on_issues"
ON public.issue_votes
FOR INSERT
TO authenticated
WITH CHECK (
    voter_id = auth.uid() 
    AND EXISTS (
        SELECT 1 FROM public.civic_issues ci 
        WHERE ci.id = issue_id AND ci.allow_public_view = true
    )
);

-- Users can remove their own votes
CREATE POLICY "users_can_remove_own_votes"
ON public.issue_votes
FOR DELETE
TO authenticated
USING (voter_id = auth.uid());

-- Users can view votes on public issues
CREATE POLICY "public_can_view_votes_on_public_issues"
ON public.issue_votes
FOR SELECT
TO public
USING (
    EXISTS (
        SELECT 1 FROM public.civic_issues ci 
        WHERE ci.id = issue_id AND ci.allow_public_view = true
    )
);

-- Issue status updates policies
-- Public can view status updates on public issues
CREATE POLICY "public_can_view_status_updates"
ON public.issue_status_updates
FOR SELECT
TO public
USING (
    EXISTS (
        SELECT 1 FROM public.civic_issues ci 
        WHERE ci.id = issue_id AND ci.allow_public_view = true
    )
);

-- Only officials can create status updates
CREATE POLICY "officials_can_create_status_updates"
ON public.issue_status_updates
FOR INSERT
TO authenticated
WITH CHECK (updated_by = auth.uid() AND public.is_admin_or_official());

-- 8. Storage RLS Policies
-- Issue images - public read, authenticated upload
CREATE POLICY "public_can_view_issue_images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'issue-images');

CREATE POLICY "authenticated_users_upload_issue_images"
ON storage.objects  
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'issue-images' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "users_manage_own_issue_images"
ON storage.objects
FOR UPDATE, DELETE
TO authenticated
USING (bucket_id = 'issue-images' AND owner = auth.uid());

-- Profile images - users manage their own
CREATE POLICY "users_view_profile_images"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'profile-images');

CREATE POLICY "users_upload_own_profile_images" 
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'profile-images' 
    AND owner = auth.uid()
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "users_manage_own_profile_images"
ON storage.objects
FOR UPDATE, DELETE
TO authenticated
USING (bucket_id = 'profile-images' AND owner = auth.uid());

-- 9. Triggers
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_civic_issues_updated_at
    BEFORE UPDATE ON public.civic_issues
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_issue_votes_count_trigger
    AFTER INSERT OR DELETE ON public.issue_votes
    FOR EACH ROW EXECUTE FUNCTION public.update_issue_votes_count();

CREATE TRIGGER update_issue_comments_count_trigger
    AFTER INSERT OR DELETE ON public.issue_comments
    FOR EACH ROW EXECUTE FUNCTION public.update_issue_comments_count();

-- 10. Mock Data for Testing
DO $$
DECLARE
    citizen_uuid UUID := gen_random_uuid();
    admin_uuid UUID := gen_random_uuid();
    inspector_uuid UUID := gen_random_uuid();
    issue1_uuid UUID := gen_random_uuid();
    issue2_uuid UUID := gen_random_uuid();
    issue3_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with complete field structure
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (citizen_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'citizen@civiclink.gov', crypt('citizen123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Citizen", "role": "citizen"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@civiclink.gov', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Sarah Admin", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (inspector_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'inspector@civiclink.gov', crypt('inspector123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Mike Inspector", "role": "inspector"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create sample civic issues
    INSERT INTO public.civic_issues (id, reporter_id, title, description, category, priority, status, location_address, department, allow_public_view) VALUES
        (issue1_uuid, citizen_uuid, 'Broken streetlight on Main Street', 'The streetlight has been flickering for days and now completely dark. Creating safety concerns for pedestrians at night.', 'lighting'::public.issue_category, 'high'::public.issue_priority, 'pending'::public.issue_status, 'Main Street & 5th Avenue, Downtown', 'Public Works', true),
        (issue2_uuid, citizen_uuid, 'Pothole causing traffic issues', 'Large pothole is causing vehicles to swerve dangerously. Getting worse with recent rain.', 'road_damage'::public.issue_category, 'medium'::public.issue_priority, 'in_progress'::public.issue_status, 'Oak Street near City Hall', 'Transportation', true),
        (issue3_uuid, admin_uuid, 'Overflowing garbage bins in Central Park', 'Multiple garbage bins are overflowing, attracting pests and creating unsanitary conditions.', 'garbage'::public.issue_category, 'medium'::public.issue_priority, 'resolved'::public.issue_status, 'Central Park - East Entrance', 'Sanitation', true);

    -- Add issue comments
    INSERT INTO public.issue_comments (issue_id, commenter_id, content, is_official) VALUES
        (issue1_uuid, admin_uuid, 'We have received your report and will dispatch a crew to investigate within 24 hours.', true),
        (issue2_uuid, inspector_uuid, 'Inspection completed. Work order has been created for road repair crew.', true),
        (issue2_uuid, citizen_uuid, 'Thank you for the quick response! Looking forward to the repair.', false);

    -- Add some votes
    INSERT INTO public.issue_votes (issue_id, voter_id) VALUES
        (issue1_uuid, citizen_uuid),
        (issue1_uuid, admin_uuid),
        (issue2_uuid, citizen_uuid),
        (issue2_uuid, inspector_uuid);

    -- Add status updates
    INSERT INTO public.issue_status_updates (issue_id, updated_by, old_status, new_status, update_message) VALUES
        (issue2_uuid, inspector_uuid, 'pending'::public.issue_status, 'in_progress'::public.issue_status, 'Issue has been assigned to road maintenance crew'),
        (issue3_uuid, admin_uuid, 'in_progress'::public.issue_status, 'resolved'::public.issue_status, 'Garbage collection schedule has been adjusted and additional bins installed');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;