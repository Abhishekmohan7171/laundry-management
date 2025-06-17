-- Database initialization script for laundry platform
-- This script runs when PostgreSQL container starts for the first time

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Create custom types
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('customer', 'shop_owner', 'delivery_person', 'admin');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended', 'pending_verification');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE shop_status AS ENUM ('active', 'inactive', 'suspended', 'pending_approval');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE subscription_plan AS ENUM ('basic', 'premium', 'enterprise');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'picked_up', 'in_process', 'ready', 'out_for_delivery', 'delivered', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE laundry_db TO laundry_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO laundry_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO laundry_user;

-- Create sequence for order numbers
CREATE SEQUENCE IF NOT EXISTS order_number_seq START 1;

-- Function to generate order numbers
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
BEGIN
    RETURN 'LD-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || 
           LPAD(nextval('order_number_seq')::TEXT, 6, '0');
END;
$$ LANGUAGE plpgsql;

-- Function to find nearby shops
CREATE OR REPLACE FUNCTION find_nearby_shops(
    user_lat DECIMAL,
    user_lng DECIMAL,
    radius_km INTEGER DEFAULT 3
)
RETURNS TABLE (
    id UUID,
    name VARCHAR,
    distance_km DECIMAL,
    rating DECIMAL,
    total_reviews INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.name,
        ST_Distance(
            ST_MakePoint(s.longitude, s.latitude)::geography,
            ST_MakePoint(user_lng, user_lat)::geography
        ) / 1000 AS distance_km,
        s.rating,
        s.total_reviews
    FROM shops s
    WHERE s.status = 'active'
    AND ST_DWithin(
        ST_MakePoint(s.longitude, s.latitude)::geography,
        ST_MakePoint(user_lng, user_lat)::geography,
        radius_km * 1000
    )
    ORDER BY distance_km ASC, s.rating DESC;
END;
$$ LANGUAGE plpgsql;

-- Insert default admin user (password: Admin123!)
-- Note: In production, this should be changed immediately
INSERT INTO users (
    id, 
    email, 
    phone, 
    password, 
    first_name, 
    last_name, 
    role, 
    email_verified, 
    phone_verified
) VALUES (
    uuid_generate_v4(),
    'admin@laundryplatform.qa',
    '+97412345678',
    '$2b$10$7d5K8QIQZn9Xo7a7f2lBqOYGHJKLMNOPQRSTUVWXYZ', -- bcrypt hash of 'Admin123!'
    'Platform',
    'Administrator',
    'admin',
    true,
    true
) ON CONFLICT (email) DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Log initialization completion
INSERT INTO pg_stat_statements_info (dealloc) VALUES (0) ON CONFLICT DO NOTHING;