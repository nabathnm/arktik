-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.profiles (
  id uuid NOT NULL,
  email text NOT NULL,
  name text,
  avatar_url text,
  role text NOT NULL DEFAULT 'user'::text CHECK (role = ANY (ARRAY['admin'::text, 'user'::text])),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.destinations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL,
  location text NOT NULL,
  type text NOT NULL CHECK (type = ANY (ARRAY['tourism'::text, 'culinary'::text])),
  image_url text NOT NULL,
  created_by uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT destinations_pkey PRIMARY KEY (id),
  CONSTRAINT destinations_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);
CREATE TABLE public.trips (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  destination_id uuid,
  start_date date,
  end_date date,
  type text NOT NULL CHECK (type = ANY (ARRAY['solo'::text, 'group'::text, 'family'::text])),
  created_by uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  selected_date date,
  status character varying DEFAULT 'draft'::character varying,
  checklist_status jsonb DEFAULT '[false, false, false, false, false, false]'::jsonb,
  CONSTRAINT trips_pkey PRIMARY KEY (id),
  CONSTRAINT trips_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id),
  CONSTRAINT trips_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);
CREATE TABLE public.trip_members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trip_id uuid NOT NULL,
  user_id uuid NOT NULL,
  role text NOT NULL DEFAULT 'member'::text CHECK (role = ANY (ARRAY['owner'::text, 'member'::text])),
  status text NOT NULL DEFAULT 'active'::text CHECK (status = ANY (ARRAY['active'::text, 'left'::text])),
  joined_at timestamp with time zone DEFAULT now(),
  CONSTRAINT trip_members_pkey PRIMARY KEY (id),
  CONSTRAINT trip_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT trip_members_user_id_profiles_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT trip_members_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trips(id)
);
CREATE TABLE public.invitations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trip_id uuid NOT NULL UNIQUE,
  code text NOT NULL UNIQUE,
  status text NOT NULL DEFAULT 'active'::text CHECK (status = ANY (ARRAY['active'::text, 'expired'::text, 'closed'::text])),
  max_members integer NOT NULL,
  expires_at timestamp with time zone NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT invitations_pkey PRIMARY KEY (id),
  CONSTRAINT invitations_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trips(id)
);
CREATE TABLE public.trip_schedule_candidates (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  trip_id uuid,
  candidate_date date NOT NULL,
  available_members_count integer NOT NULL,
  total_members_count integer NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT trip_schedule_candidates_pkey PRIMARY KEY (id),
  CONSTRAINT trip_schedule_candidates_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trips(id)
);
CREATE TABLE public.trip_itineraries (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trip_id uuid NOT NULL,
  destination_id uuid NOT NULL,
  visit_date date NOT NULL,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  start_time time without time zone,
  end_time time without time zone,
  CONSTRAINT trip_itineraries_pkey PRIMARY KEY (id),
  CONSTRAINT trip_itineraries_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trips(id),
  CONSTRAINT trip_itineraries_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id)
);
CREATE TABLE public.user_availabilities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  start_time timestamp with time zone NOT NULL,
  end_time timestamp with time zone NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_availabilities_pkey PRIMARY KEY (id),
  CONSTRAINT user_availabilities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);