-- Migration to support schedule matching and nullable dates

-- 1. Make start_date and end_date nullable
ALTER TABLE trips ALTER COLUMN start_date DROP NOT NULL;
ALTER TABLE trips ALTER COLUMN end_date DROP NOT NULL;

-- 2. Add selected_date column
ALTER TABLE trips ADD COLUMN IF NOT EXISTS selected_date DATE;

-- 3. Add status column to trips table
ALTER TABLE trips ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'draft';

-- Optional: Create trip_schedule_candidates table if we want to cache matching results
CREATE TABLE IF NOT EXISTS trip_schedule_candidates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID REFERENCES trips(id) ON DELETE CASCADE,
    candidate_date DATE NOT NULL,
    available_members_count INT NOT NULL,
    total_members_count INT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_trip_candidate_date UNIQUE (trip_id, candidate_date)
);

-- Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';
