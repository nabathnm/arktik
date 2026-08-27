-- Update Trip Itineraries to support specific time and fix RLS

-- Add start_time and end_time
ALTER TABLE public.trip_itineraries ADD COLUMN IF NOT EXISTS start_time TIME;
ALTER TABLE public.trip_itineraries ADD COLUMN IF NOT EXISTS end_time TIME;

-- Enable RLS
ALTER TABLE public.trip_itineraries ENABLE ROW LEVEL SECURITY;

-- Grant access to authenticated and anon users
GRANT ALL ON TABLE public.trip_itineraries TO authenticated;
GRANT ALL ON TABLE public.trip_itineraries TO anon;

-- Create permissive policies for development
DROP POLICY IF EXISTS "Enable all actions for authenticated users" ON public.trip_itineraries;
CREATE POLICY "Enable all actions for authenticated users" 
ON public.trip_itineraries 
FOR ALL 
TO authenticated 
USING (true) 
WITH CHECK (true);

DROP POLICY IF EXISTS "Enable all actions for anon users" ON public.trip_itineraries;
CREATE POLICY "Enable all actions for anon users" 
ON public.trip_itineraries 
FOR ALL 
TO anon 
USING (true) 
WITH CHECK (true);

-- Reload schema cache
NOTIFY pgrst, 'reload schema';
