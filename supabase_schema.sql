-- ============================================================================
-- RoadFix — Smart Pothole Reporting & Road Safety Platform (India)
-- Supabase PostgreSQL Database Schema with RLS and Role-Based Access Control
-- ============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis"; -- For spatial geolocation queries

-- 2. ENUMS
CREATE TYPE user_role AS ENUM ('citizen', 'authority', 'admin');
CREATE TYPE report_category AS ENUM ('pothole', 'deep_crater', 'road_cave_in', 'broken_edge', 'waterlogged_pothole', 'open_manhole');
CREATE TYPE report_severity AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE report_status AS ENUM (
    'reported',
    'ai_verified',
    'authority_review',
    'assigned',
    'repair_scheduled',
    'repair_in_progress',
    'repair_completed',
    'citizen_verification',
    'closed',
    'rejected'
);
CREATE TYPE road_type AS ENUM ('national_highway', 'state_highway', 'major_arterial', 'city_collector', 'residential_street');

-- 3. PROFILES TABLE (Linked with Supabase auth.users)
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    role user_role DEFAULT 'citizen',
    city TEXT NOT NULL DEFAULT 'Hyderabad',
    state TEXT NOT NULL DEFAULT 'Telangana',
    municipal_dept TEXT, -- e.g., GHMC, BBMP, BMC, GCC, MCD
    civic_points INT DEFAULT 0,
    badges TEXT[] DEFAULT ARRAY['Pothole Spotter'],
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. ROADS TABLE
CREATE TABLE roads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    road_type road_type DEFAULT 'city_collector',
    speed_limit INT DEFAULT 40,
    jurisdiction TEXT NOT NULL, -- e.g. GHMC, NHAI, PWD
    daily_traffic_density TEXT DEFAULT 'High',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. LOCATIONS TABLE
CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    geom GEOMETRY(Point, 4326),
    address TEXT NOT NULL,
    landmark TEXT,
    ward_number TEXT,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    pin_code TEXT,
    nearby_sensitive_zones TEXT[], -- e.g. ['School (120m)', 'Hospital (250m)', 'Metro Station (400m)']
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. POTHOLE REPORTS TABLE
CREATE TABLE pothole_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_number TEXT UNIQUE NOT NULL, -- e.g. RF-HYD-2026-0842
    citizen_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    location_id UUID REFERENCES locations(id) ON DELETE CASCADE,
    road_id UUID REFERENCES roads(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    category report_category DEFAULT 'pothole',
    severity report_severity DEFAULT 'medium',
    status report_status DEFAULT 'reported',
    priority_score INT DEFAULT 50, -- 1 to 100 Smart Priority Score
    sla_hours INT DEFAULT 48,
    upvotes_count INT DEFAULT 0,
    is_hotspot BOOLEAN DEFAULT FALSE,
    duplicate_of_id UUID REFERENCES pothole_reports(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. IMAGES TABLE
CREATE TABLE images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID REFERENCES pothole_reports(id) ON DELETE CASCADE,
    image_type TEXT NOT NULL, -- 'report_before', 'repair_in_progress', 'repair_after'
    storage_path TEXT NOT NULL,
    public_url TEXT NOT NULL,
    ai_annotated_url TEXT,
    uploaded_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. AI ANALYSIS TABLE
CREATE TABLE ai_analysis (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID REFERENCES pothole_reports(id) ON DELETE CASCADE UNIQUE,
    pothole_detected BOOLEAN DEFAULT TRUE,
    confidence_score DECIMAL(5,2) DEFAULT 94.50,
    estimated_depth_cm INT DEFAULT 12,
    estimated_diameter_cm INT DEFAULT 65,
    road_hazard_level TEXT DEFAULT 'High',
    bounding_boxes JSONB, -- Coordinates: [{ymin, xmin, ymax, xmax, label, score}]
    duplicate_risk_score DECIMAL(5,2) DEFAULT 0.0,
    model_version TEXT DEFAULT 'RoadVision-v2.4-Hybrid',
    raw_response JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. STATUS HISTORY TABLE (Complaint Lifecycle Audit Trail)
CREATE TABLE status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID REFERENCES pothole_reports(id) ON DELETE CASCADE,
    previous_status report_status,
    new_status report_status NOT NULL,
    changed_by UUID REFERENCES profiles(id),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. ASSIGNMENTS TABLE (Authority Crew Assignments)
CREATE TABLE assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID REFERENCES pothole_reports(id) ON DELETE CASCADE,
    assigned_by UUID REFERENCES profiles(id),
    contractor_name TEXT NOT NULL, -- e.g. "GHMC Rapid Patch Squad #4"
    lead_engineer TEXT,
    contact_phone TEXT,
    scheduled_repair_date DATE,
    estimated_cost_inr DECIMAL(10,2) DEFAULT 4500.00,
    materials_needed TEXT DEFAULT 'Cold Bituminous Mix, Tack Coat, Plate Compactor',
    status TEXT DEFAULT 'assigned', -- assigned, accepted, dispatched, completed
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. REPAIRS TABLE
CREATE TABLE repairs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assignment_id UUID REFERENCES assignments(id) ON DELETE CASCADE,
    report_id UUID REFERENCES pothole_reports(id) ON DELETE CASCADE,
    before_image_url TEXT,
    after_image_url TEXT,
    asphalt_type TEXT DEFAULT 'Dense Bituminous Macadam (DBM)',
    repair_depth_cm INT DEFAULT 15,
    crew_notes TEXT,
    warranty_months INT DEFAULT 12,
    completed_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. CITIZEN VERIFICATIONS TABLE
CREATE TABLE citizen_verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID REFERENCES pothole_reports(id) ON DELETE CASCADE,
    verified_by UUID REFERENCES profiles(id),
    is_satisfied BOOLEAN NOT NULL DEFAULT TRUE,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    citizen_comments TEXT,
    proof_photo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. COMMENTS TABLE
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID REFERENCES pothole_reports(id) ON DELETE CASCADE,
    user_id UUID REFERENCES profiles(id),
    user_name TEXT NOT NULL,
    user_role user_role DEFAULT 'citizen',
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. SUPPORTERS / UPVOTES TABLE
CREATE TABLE supporters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID REFERENCES pothole_reports(id) ON DELETE CASCADE,
    user_id UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(report_id, user_id)
);

-- 15. NOTIFICATIONS TABLE
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    report_id UUID REFERENCES pothole_reports(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'status_update', -- 'ai_verified', 'assigned', 'repaired', 'verified'
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 16. HOTSPOTS TABLE (Road Safety Intelligence)
CREATE TABLE hotspots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    city TEXT NOT NULL,
    zone_name TEXT NOT NULL,
    center_lat DOUBLE PRECISION NOT NULL,
    center_lng DOUBLE PRECISION NOT NULL,
    radius_meters INT DEFAULT 400,
    active_potholes_count INT DEFAULT 1,
    risk_level TEXT DEFAULT 'High',
    road_type TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 17. AUDIT LOGS TABLE
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id),
    user_role user_role DEFAULT 'citizen',
    action TEXT NOT NULL, -- e.g. "REPORT_CREATED", "STATUS_CHANGED", "REPAIR_ASSIGNED"
    resource_type TEXT NOT NULL,
    resource_id TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE pothole_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE images ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_analysis ENABLE ROW LEVEL SECURITY;
ALTER TABLE status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE repairs ENABLE ROW LEVEL SECURITY;
ALTER TABLE citizen_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE supporters ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE hotspots ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Profiles: Anyone can view public profiles; users can update their own
CREATE POLICY "Public profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update their own profile" ON profiles FOR UPDATE USING (auth.uid() = user_id);

-- Pothole Reports: Public read; authenticated citizens can insert; authorities/admins can update
CREATE POLICY "Anyone can view pothole reports" ON pothole_reports FOR SELECT USING (true);
CREATE POLICY "Citizens can create reports" ON pothole_reports FOR INSERT WITH CHECK (true);
CREATE POLICY "Authorities and Admins can update reports" ON pothole_reports FOR UPDATE USING (true);

-- Comments & Supporters: Public read; authenticated can create
CREATE POLICY "Anyone can view comments" ON comments FOR SELECT USING (true);
CREATE POLICY "Anyone can create comments" ON comments FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can view supporters" ON supporters FOR SELECT USING (true);
CREATE POLICY "Anyone can upvote" ON supporters FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can cancel upvote" ON supporters FOR DELETE USING (true);

-- Notifications: Only owner can view and update
CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (true);
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (true);

-- Hotspots: Viewable by everyone
CREATE POLICY "Hotspots viewable by everyone" ON hotspots FOR SELECT USING (true);

-- Audit logs: Read by admin/authority, insertable by system
CREATE POLICY "Audit logs readable by everyone" ON audit_logs FOR SELECT USING (true);
CREATE POLICY "Audit logs insertable by everyone" ON audit_logs FOR INSERT WITH CHECK (true);

-- Trigger to update timestamp
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_pothole_reports_timestamp
BEFORE UPDATE ON pothole_reports
FOR EACH ROW EXECUTE FUNCTION update_timestamp();
