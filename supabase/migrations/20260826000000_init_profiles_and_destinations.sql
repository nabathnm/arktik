-- 1. Create UserRole Enum
CREATE TYPE public.user_role AS ENUM ('admin', 'user');

-- 2. Create Profiles Table
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL PRIMARY KEY,
  email TEXT NOT NULL,
  name TEXT,
  avatar_url TEXT,
  role TEXT NOT NULL CHECK (role IN ('admin', 'user')) DEFAULT 'user',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Set up Row Level Security (RLS) for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Profile Policies
CREATE POLICY "Users can view their own profile" 
ON public.profiles FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" 
ON public.profiles FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
  )
);

CREATE POLICY "Users can insert their own profile" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);


-- 3. Create Destinations Table
CREATE TABLE public.destinations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  location TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('tourism', 'culinary')),
  image_url TEXT NOT NULL,
  rating NUMERIC DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES auth.users NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Set up Row Level Security (RLS) for destinations
ALTER TABLE public.destinations ENABLE ROW LEVEL SECURITY;

-- Destination Policies
CREATE POLICY "Anyone can view active destinations" 
ON public.destinations FOR SELECT 
USING (is_active = true);

CREATE POLICY "Admins can view all destinations" 
ON public.destinations FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
  )
);

CREATE POLICY "Admins can insert destinations" 
ON public.destinations FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
  )
);

CREATE POLICY "Admins can update destinations" 
ON public.destinations FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
  )
);

-- 4. Create Storage Bucket for Destinations (Requires Superuser or Dashboard access usually, 
-- but represented here for completeness)
INSERT INTO storage.buckets (id, name, public) 
VALUES ('destinations', 'destinations', true)
ON CONFLICT (id) DO NOTHING;

-- Storage Policies for Destinations Bucket
CREATE POLICY "Public can view destination images" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'destinations');

CREATE POLICY "Admins can insert destination images" 
ON storage.objects FOR INSERT 
WITH CHECK (
  bucket_id = 'destinations' AND 
  EXISTS (
    SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
  )
);
