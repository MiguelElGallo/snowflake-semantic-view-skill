--------------------------------------------------------------------------------
-- Snowflake PAT (Programmatic Access Token) Setup Script
-- This script creates the necessary policies and configurations for PAT usage
--------------------------------------------------------------------------------

-- Use ACCOUNTADMIN role for creating policies
USE ROLE ACCOUNTADMIN;

--------------------------------------------------------------------------------
-- A) Create Authentication Policy
--    Allows: PASSWORD, KEYPAIR, and PROGRAMMATIC_ACCESS_TOKEN
--------------------------------------------------------------------------------

CREATE OR REPLACE AUTHENTICATION POLICY pat_auth_policy
    AUTHENTICATION_METHODS = ('PASSWORD', 'KEYPAIR', 'PROGRAMMATIC_ACCESS_TOKEN')
    PAT_POLICY = (
        NETWORK_POLICY_EVALUATION = ENFORCED_REQUIRED,  -- Enforce network policy for PAT
        DEFAULT_EXPIRY_IN_DAYS = 15,                    -- Default PAT expiration
        MAX_EXPIRY_IN_DAYS = 365                        -- Maximum PAT expiration
    )
    COMMENT = 'Authentication policy allowing password, RSA key pair, and PAT authentication';

--------------------------------------------------------------------------------
-- B) Create Network Policy
--    Allows connections from 0.0.0.0/0 (all IP addresses)
--    WARNING: This is permissive and should be restricted in production!
--------------------------------------------------------------------------------

-- First, create a network rule that allows all IPs
CREATE OR REPLACE NETWORK RULE allow_all_ips_rule
    MODE = INGRESS
    TYPE = IPV4
    VALUE_LIST = ('0.0.0.0/0')
    COMMENT = 'Network rule allowing all IPv4 addresses';

-- Create the network policy using the network rule
CREATE OR REPLACE NETWORK POLICY allow_all_network_policy
    ALLOWED_NETWORK_RULE_LIST = (allow_all_ips_rule)
    COMMENT = 'Network policy allowing connections from all IP addresses (0.0.0.0/0)';

--------------------------------------------------------------------------------
-- C) Apply policies to user xxxxxxx
--------------------------------------------------------------------------------

-- Apply the network policy to the user
ALTER USER xxxxxxx SET NETWORK_POLICY = allow_all_network_policy;

-- Apply the authentication policy to the user
ALTER USER xxxxxxx SET AUTHENTICATION POLICY pat_auth_policy;

--------------------------------------------------------------------------------
-- D) Generate a Programmatic Access Token (PAT) for user xxxxxxx
--    Note: The token secret will only be shown ONCE upon creation!
--------------------------------------------------------------------------------

-- Generate PAT with default expiration (15 days based on policy)
-- Replace 'MY_PAT_TOKEN' with your desired token name
-- Optionally specify a role restriction for additional security
ALTER USER xxxxxxx ADD PROGRAMMATIC ACCESS TOKEN MY_PAT_TOKEN
    COMMENT = 'Programmatic access token for API authentication';

-- Alternative: Generate PAT with specific role restriction (recommended for security)
-- ALTER USER xxxxxxx ADD PROGRAMMATIC ACCESS TOKEN MY_PAT_TOKEN
--     ROLE_RESTRICTION = <role_name>
--     COMMENT = 'Programmatic access token restricted to specific role';

-- Alternative: Generate PAT with custom expiration time
-- ALTER USER xxxxxxx ADD PROGRAMMATIC ACCESS TOKEN MY_PAT_TOKEN
--     EXPIRES_IN_DAYS = 30
--     COMMENT = 'Programmatic access token with 30-day expiration';

--------------------------------------------------------------------------------
-- Verification and Management Commands
--------------------------------------------------------------------------------

-- Show all PATs for the user
SHOW USER PROGRAMMATIC ACCESS TOKENS FOR USER xxxxxxx;

-- Verify the authentication policy applied to the user
DESCRIBE USER xxxxxxx;

-- Show network policy details
SHOW NETWORK POLICIES LIKE 'allow_all_network_policy';

-- Show authentication policy details
SHOW AUTHENTICATION POLICIES LIKE 'pat_auth_policy';

--------------------------------------------------------------------------------
-- Usage Examples (After PAT Creation)
--------------------------------------------------------------------------------

-- Example: Using PAT with Python Snowflake Connector
-- conn = snowflake.connector.connect(
--     user='xxxxxxx',
--     password='<YOUR_PAT_TOKEN_SECRET>',  -- Use PAT as password
--     account='<YOUR_ACCOUNT>',
--     warehouse='<YOUR_WAREHOUSE>',
--     database='<YOUR_DATABASE>',
--     schema='<YOUR_SCHEMA>'
-- )

-- Example: Using PAT with cURL for REST API
-- curl --location "https://<org>-<account>.snowflakecomputing.com/api/v2/databases" \
--   --header "Authorization: Bearer <YOUR_PAT_TOKEN_SECRET>"

--------------------------------------------------------------------------------
-- Cleanup Commands (if needed)
--------------------------------------------------------------------------------

-- Remove PAT from user
-- ALTER USER xxxxxxx REMOVE PROGRAMMATIC ACCESS TOKEN MY_PAT_TOKEN;

-- Remove network policy from user
-- ALTER USER xxxxxxx UNSET NETWORK_POLICY;

-- Remove authentication policy from user
-- ALTER USER xxxxxxx UNSET AUTHENTICATION POLICY;

-- Drop policies (if no longer needed)
-- DROP AUTHENTICATION POLICY IF EXISTS pat_auth_policy;
-- DROP NETWORK POLICY IF EXISTS allow_all_network_policy;
-- DROP NETWORK RULE IF EXISTS allow_all_ips_rule;
