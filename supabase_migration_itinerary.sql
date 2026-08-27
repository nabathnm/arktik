-- Migration for Trip Itineraries

CREATE TABLE IF NOT EXISTS public.trip_itineraries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    destination_id UUID NOT NULL REFERENCES public.destinations(id) ON DELETE CASCADE,
    visit_date DATE NOT NULL,
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Constraint to ensure we can order destinations sequentially within a date for a trip
-- Not strictly unique because they might reorder, but good practice if needed.
-- But wait, let's keep it simple without unique constraint for now.

-- Enable Row Level Security (RLS) if needed
-- ALTER TABLE public.trip_itineraries ENABLE ROW LEVEL SECURITY;

-- Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';
