-- =============================================================
-- GPG GLOBAL — ROW LEVEL SECURITY POLICIES
-- Run this in: Supabase Dashboard → SQL Editor → New Query
--
-- Strategy:
--   • All tables: RLS ON (blocks direct PostgREST anon/auth access)
--   • Backend uses service_role key → bypasses RLS → unaffected
--   • Public reference tables: authenticated users can SELECT
--   • User-owned tables: authenticated users can CRUD own rows
--   • Admin/internal tables: NO policies → deny all (service_role only)
-- =============================================================

-- -------------------------------------------------------------
-- STEP 1: Enable RLS on every table
-- -------------------------------------------------------------
alter table "public"."AuthOtp"                   enable row level security;
alter table "public"."ModeratorInviteCode"        enable row level security;
alter table "public"."FieldVisibility"            enable row level security;
alter table "public"."PrivacyGrant"               enable row level security;
alter table "public"."MissionAlumni"              enable row level security;
alter table "public"."PaymentEvent"               enable row level security;
alter table "public"."MeritOverride"              enable row level security;
alter table "public"."Post"                       enable row level security;
alter table "public"."PostComment"                enable row level security;
alter table "public"."PostReshare"                enable row level security;
alter table "public"."PostReaction"               enable row level security;
alter table "public"."BannedIdentity"             enable row level security;
alter table "public"."ModerationFlag"             enable row level security;
alter table "public"."UserDisciplineState"        enable row level security;
alter table "public"."MarketplaceApproval"        enable row level security;
alter table "public"."TalentFeature"              enable row level security;
alter table "public"."AdModerationReview"         enable row level security;
alter table "public"."MuteRelation"               enable row level security;
alter table "public"."UserReport"                 enable row level security;
alter table "public"."SafetyMetadataFlag"         enable row level security;
alter table "public"."HighBlockAlert"             enable row level security;
alter table "public"."BreakGlassReportBundle"     enable row level security;
alter table "public"."BreakGlassEvidenceMessage"  enable row level security;
alter table "public"."GatheringPlace"             enable row level security;
alter table "public"."AdminActionLog"             enable row level security;
alter table "public"."BlockRelation"              enable row level security;
alter table "public"."GatheringGroup"             enable row level security;
alter table "public"."GatheringGroupMembership"   enable row level security;
alter table "public"."GatheringCheckIn"           enable row level security;
alter table "public"."GroupMessageReadReceipt"    enable row level security;
alter table "public"."Mission"                    enable row level security;
alter table "public"."User"                       enable row level security;
alter table "public"."ChatMessage"                enable row level security;

-- -------------------------------------------------------------
-- STEP 2: Drop existing policies (safe to run multiple times)
-- -------------------------------------------------------------
do $$ declare
  r record;
begin
  for r in
    select policyname, tablename
    from pg_policies
    where schemaname = 'public'
  loop
    execute format('drop policy if exists %I on "public".%I', r.policyname, r.tablename);
  end loop;
end $$;

-- =============================================================
-- STEP 3: ADD POLICIES
-- Tables with NO policies below = service_role only (admin/internal)
-- =============================================================

-- -------------------------------------------------------------
-- Mission  (public reference — authenticated can read)
-- -------------------------------------------------------------
create policy "mission_authenticated_read"
  on "public"."Mission" for select
  to authenticated
  using (true);

-- -------------------------------------------------------------
-- GatheringPlace  (community directory — authenticated can read)
-- -------------------------------------------------------------
create policy "gathering_place_authenticated_read"
  on "public"."GatheringPlace" for select
  to authenticated
  using (true);

-- -------------------------------------------------------------
-- GatheringGroup  (authenticated can read all groups)
-- -------------------------------------------------------------
create policy "gathering_group_authenticated_read"
  on "public"."GatheringGroup" for select
  to authenticated
  using (true);

-- -------------------------------------------------------------
-- User  (users can read all profiles; write only own row)
-- -------------------------------------------------------------
create policy "user_authenticated_read"
  on "public"."User" for select
  to authenticated
  using (true);

-- Users may not directly write their own row via PostgREST;
-- all writes go through the backend (service_role). No INSERT/UPDATE policy.

-- -------------------------------------------------------------
-- Post  (authenticated can read non-hidden posts; no direct write)
-- -------------------------------------------------------------
create policy "post_authenticated_read"
  on "public"."Post" for select
  to authenticated
  using ("isHiddenPendingReview" = false and "copyrightBlocked" = false);

-- -------------------------------------------------------------
-- PostComment  (authenticated can read)
-- -------------------------------------------------------------
create policy "post_comment_authenticated_read"
  on "public"."PostComment" for select
  to authenticated
  using (true);

-- -------------------------------------------------------------
-- PostReaction  (authenticated can read)
-- -------------------------------------------------------------
create policy "post_reaction_authenticated_read"
  on "public"."PostReaction" for select
  to authenticated
  using (true);

-- -------------------------------------------------------------
-- PostReshare  (authenticated can read)
-- -------------------------------------------------------------
create policy "post_reshare_authenticated_read"
  on "public"."PostReshare" for select
  to authenticated
  using (true);

-- -------------------------------------------------------------
-- FieldVisibility  (user can read own visibility settings)
-- -------------------------------------------------------------
create policy "field_visibility_own_read"
  on "public"."FieldVisibility" for select
  to authenticated
  using ("userId" = auth.uid()::text);

-- -------------------------------------------------------------
-- PrivacyGrant  (user can read grants they own or received)
-- -------------------------------------------------------------
create policy "privacy_grant_own_read"
  on "public"."PrivacyGrant" for select
  to authenticated
  using ("ownerUserId" = auth.uid()::text or "viewerUserId" = auth.uid()::text);

-- -------------------------------------------------------------
-- MissionAlumni  (user can read own record)
-- -------------------------------------------------------------
create policy "mission_alumni_own_read"
  on "public"."MissionAlumni" for select
  to authenticated
  using ("userId" = auth.uid()::text);

-- -------------------------------------------------------------
-- BlockRelation  (user can read own block relations)
-- -------------------------------------------------------------
create policy "block_relation_own_read"
  on "public"."BlockRelation" for select
  to authenticated
  using ("blockerId" = auth.uid()::text or "blockedId" = auth.uid()::text);

-- -------------------------------------------------------------
-- MuteRelation  (user can read own mute relations)
-- -------------------------------------------------------------
create policy "mute_relation_own_read"
  on "public"."MuteRelation" for select
  to authenticated
  using ("muterId" = auth.uid()::text);

-- -------------------------------------------------------------
-- GatheringGroupMembership  (authenticated can read memberships)
-- -------------------------------------------------------------
create policy "group_membership_authenticated_read"
  on "public"."GatheringGroupMembership" for select
  to authenticated
  using (true);

-- -------------------------------------------------------------
-- GatheringCheckIn  (user can read own check-ins)
-- -------------------------------------------------------------
create policy "check_in_own_read"
  on "public"."GatheringCheckIn" for select
  to authenticated
  using ("userId" = auth.uid()::text);

-- -------------------------------------------------------------
-- ChatMessage  (user can read messages from rooms they are in)
-- Membership check done via GatheringGroupMembership.
-- -------------------------------------------------------------
create policy "chat_message_member_read"
  on "public"."ChatMessage" for select
  to authenticated
  using (
    exists (
      select 1
      from "public"."GatheringGroupMembership" m
      where m."userId" = auth.uid()::text
        and m."groupId" = "ChatMessage"."roomId"
    )
  );

-- -------------------------------------------------------------
-- GroupMessageReadReceipt  (user can read own receipts)
-- -------------------------------------------------------------
create policy "read_receipt_own_read"
  on "public"."GroupMessageReadReceipt" for select
  to authenticated
  using ("userId" = auth.uid()::text);

-- =============================================================
-- STEP 4: EXPLICIT DENY POLICIES — Admin/Internal tables
-- These tables are backend-only. RLS ON + using(false) ensures
-- no authenticated or anon user can access them via PostgREST.
-- The backend service_role key bypasses RLS entirely.
-- =============================================================

create policy "authotp_deny_all"
  on "public"."AuthOtp" as restrictive for all
  to authenticated, anon
  using (false);

create policy "moderator_invite_code_deny_all"
  on "public"."ModeratorInviteCode" as restrictive for all
  to authenticated, anon
  using (false);

create policy "payment_event_deny_all"
  on "public"."PaymentEvent" as restrictive for all
  to authenticated, anon
  using (false);

create policy "merit_override_deny_all"
  on "public"."MeritOverride" as restrictive for all
  to authenticated, anon
  using (false);

create policy "banned_identity_deny_all"
  on "public"."BannedIdentity" as restrictive for all
  to authenticated, anon
  using (false);

create policy "moderation_flag_deny_all"
  on "public"."ModerationFlag" as restrictive for all
  to authenticated, anon
  using (false);

create policy "user_discipline_state_deny_all"
  on "public"."UserDisciplineState" as restrictive for all
  to authenticated, anon
  using (false);

create policy "marketplace_approval_deny_all"
  on "public"."MarketplaceApproval" as restrictive for all
  to authenticated, anon
  using (false);

create policy "talent_feature_deny_all"
  on "public"."TalentFeature" as restrictive for all
  to authenticated, anon
  using (false);

create policy "ad_moderation_review_deny_all"
  on "public"."AdModerationReview" as restrictive for all
  to authenticated, anon
  using (false);

create policy "user_report_deny_all"
  on "public"."UserReport" as restrictive for all
  to authenticated, anon
  using (false);

create policy "safety_metadata_flag_deny_all"
  on "public"."SafetyMetadataFlag" as restrictive for all
  to authenticated, anon
  using (false);

create policy "high_block_alert_deny_all"
  on "public"."HighBlockAlert" as restrictive for all
  to authenticated, anon
  using (false);

create policy "break_glass_report_bundle_deny_all"
  on "public"."BreakGlassReportBundle" as restrictive for all
  to authenticated, anon
  using (false);

create policy "break_glass_evidence_message_deny_all"
  on "public"."BreakGlassEvidenceMessage" as restrictive for all
  to authenticated, anon
  using (false);

create policy "admin_action_log_deny_all"
  on "public"."AdminActionLog" as restrictive for all
  to authenticated, anon
  using (false);
