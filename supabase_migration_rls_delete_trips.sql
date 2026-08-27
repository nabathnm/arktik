-- Kebijakan DELETE untuk tabel trips (Hanya pembuat trip yang bisa menghapus)
DROP POLICY IF EXISTS "Enable delete for trip creators" ON public.trips;
CREATE POLICY "Enable delete for trip creators" 
ON public.trips 
FOR DELETE 
USING (auth.uid() = created_by);

-- Kebijakan DELETE untuk trip_members (Pembuat trip bisa menghapus semua member, ATAU member bisa menghapus dirinya sendiri)
DROP POLICY IF EXISTS "Enable delete for trip creators or self" ON public.trip_members;
CREATE POLICY "Enable delete for trip creators or self" 
ON public.trip_members 
FOR DELETE 
USING (
  auth.uid() = user_id OR 
  auth.uid() IN (SELECT created_by FROM public.trips WHERE id = trip_members.trip_id)
);

-- Kebijakan DELETE untuk invitations (Hanya pembuat trip yang bisa menghapus)
DROP POLICY IF EXISTS "Enable delete for trip creators" ON public.invitations;
CREATE POLICY "Enable delete for trip creators" 
ON public.invitations 
FOR DELETE 
USING (
  auth.uid() IN (SELECT created_by FROM public.trips WHERE id = invitations.trip_id)
);

-- Kebijakan DELETE untuk trip_schedule_candidates (Hanya pembuat trip yang bisa menghapus)
DROP POLICY IF EXISTS "Enable delete for trip creators" ON public.trip_schedule_candidates;
CREATE POLICY "Enable delete for trip creators" 
ON public.trip_schedule_candidates 
FOR DELETE 
USING (
  auth.uid() IN (SELECT created_by FROM public.trips WHERE id = trip_schedule_candidates.trip_id)
);

-- Kebijakan DELETE untuk trip_itineraries (Hanya pembuat trip yang bisa menghapus)
DROP POLICY IF EXISTS "Enable delete for trip creators" ON public.trip_itineraries;
CREATE POLICY "Enable delete for trip creators" 
ON public.trip_itineraries 
FOR DELETE 
USING (
  auth.uid() IN (SELECT created_by FROM public.trips WHERE id = trip_itineraries.trip_id)
);
