-- Create user_availabilities table to store busy schedules
CREATE TABLE IF NOT EXISTS public.user_availabilities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  start_time timestamp with time zone NOT NULL,
  end_time timestamp with time zone NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_availabilities_pkey PRIMARY KEY (id),
  CONSTRAINT user_availabilities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE public.user_availabilities ENABLE ROW LEVEL SECURITY;

-- Grant permissions
GRANT ALL ON TABLE public.user_availabilities TO authenticated;
GRANT ALL ON TABLE public.user_availabilities TO anon;

-- Policies (Permissive for development to avoid RLS issues)
DROP POLICY IF EXISTS "Enable all actions for authenticated users" ON public.user_availabilities;
CREATE POLICY "Enable all actions for authenticated users" 
ON public.user_availabilities 
FOR ALL 
TO authenticated 
USING (true) 
WITH CHECK (true);

DROP POLICY IF EXISTS "Enable all actions for anon users" ON public.user_availabilities;
CREATE POLICY "Enable all actions for anon users" 
ON public.user_availabilities 
FOR ALL 
TO anon 
USING (true) 
WITH CHECK (true);

-- Reload schema cache
NOTIFY pgrst, 'reload schema';
