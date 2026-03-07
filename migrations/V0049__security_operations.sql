-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 04. security - operations to be tracked

-- a. Compliance - Meeting regulatory requirements
-- b. Security - Detecting unauthorized access or changes
-- c. Debugging - Troubleshooting issues
-- d. Analytics - Understanding user behavior
-- e. Forensics - Investigating incidents
-- f. Recovery - Restoring from mistakes
-- g. Billing - Usage-based billing events

-- Each operation code follows a consistent pattern:
-- 3-letter prefix indicating the domain (PST=Posts, CAT=Categories, etc.)
-- 1-letter suffix indicating the specific action (C=Create, U=Update, D=Delete, etc.)
-- =====================================================

create table if not exists secu_01_operations(
   id int2 generated always as identity primary key,
   code varchar(4) not null unique,
   description text 
);

-- Insert all blog operations that should be audited
insert into secu_01_operations (code, description) values
-- =====================================================
-- POST OPERATIONS (PST-)
-- =====================================================
('PSTC', 'Post Created - When a new blog post is created (draft or published)'),
('PSTU', 'Post Updated - When post content, title, excerpt, or metadata is modified'),
('PSTD', 'Post Deleted - When post is moved to trash or permanently deleted'),
('PSTR', 'Post Restored - When post is restored from trash'),
('PSTP', 'Post Published - When post status changes to published'),
('PSTH', 'Post Unpublished - When published post is reverted to draft'),
('PSTS', 'Post Scheduled - When post is scheduled for future publication'),
('PSTF', 'Post Featured - When post is marked/unmarked as featured'),
('PSTK', 'Post Sticky - When post is marked/unmarked as sticky'),
('PSTV', 'Post Visibility Changed - When visibility changes (public/private/password)'),

-- =====================================================
-- CATEGORY OPERATIONS (CAT-)
-- =====================================================
('CATC', 'Category Created - When new category is added'),
('CATU', 'Category Updated - When category name, slug, or description changes'),
('CATD', 'Category Deleted - When category is removed'),
('CATM', 'Category Merged - When categories are merged together'),
('CATP', 'Category Parent Changed - When category hierarchy is modified'),
('CATO', 'Category Order Changed - When category display order is updated'),

-- =====================================================
-- TAG OPERATIONS (TAG-)
-- =====================================================
('TAGC', 'Tag Created - When new tag is added'),
('TAGU', 'Tag Updated - When tag name, slug changes'),
('TAGD', 'Tag Deleted - When tag is removed'),
('TAGM', 'Tag Merged - When tags are merged together'),

-- =====================================================
-- COMMENT OPERATIONS (COM-)
-- =====================================================
('COMC', 'Comment Created - When new comment is posted'),
('COMU', 'Comment Updated - When comment content is edited'),
('COMD', 'Comment Deleted - When comment is removed'),
('COMA', 'Comment Approved - When pending comment is approved'),
('COMN', 'Comment Not Approved - When approved comment is reverted to pending'),
('COMS', 'Comment Marked as Spam - When comment is flagged as spam'),
('COMH', 'Comment Unmarked Spam - When comment is removed from spam'),
('COMR', 'Comment Reported - When user reports a comment'),
('COME', 'Comment Replied - When reply to comment is added'),

-- =====================================================
-- MEDIA OPERATIONS (MED-)
-- =====================================================
('MEDC', 'Media Uploaded - When new file is uploaded to media library'),
('MEDU', 'Media Updated - When media metadata (alt, caption, etc.) is modified'),
('MEDD', 'Media Deleted - When media file is removed'),
('MEDR', 'Media Replaced - When file is replaced with new version'),
('MEDA', 'Media Attached - When media is attached to a post'),
('MEDT', 'Media Detached - When media is removed from a post'),

-- =====================================================
-- USER/AUTHOR OPERATIONS (USR-)
-- =====================================================
('USRC', 'User Created - When new user account is registered'),
('USRU', 'User Updated - When user profile information changes'),
('USRD', 'User Deleted - When user account is removed'),
('USRL', 'User Logged In - When user successfully logs in'),
('USRO', 'User Logged Out - When user logs out'),
('USRF', 'User Failed Login - When login attempt fails'),
('USRP', 'User Password Changed - When password is updated'),
('USRR', 'User Role Changed - When user role/permissions change'),
('USRS', 'User Status Changed - When account is suspended/activated'),
('USRV', 'User Verified - When email is verified'),
('USRE', 'User Profile Viewed - When profile is accessed (privacy audit)'),

-- =====================================================
-- AUTHOR FOLLOW OPERATIONS (FOL-)
-- =====================================================
('FOLA', 'Author Followed - When user follows an author'),
('FOLU', 'Author Unfollowed - When user unfollows an author'),

-- =====================================================
-- SETTINGS OPERATIONS (SET-)
-- =====================================================
('SETU', 'Settings Updated - When blog configuration changes'),
('SETB', 'Settings Bulk Updated - When multiple settings changed at once'),
('SETR', 'Settings Reset - When settings restored to defaults'),

-- =====================================================
-- API OPERATIONS (API-)
-- =====================================================
('APIC', 'API Key Created - When new API key is generated'),
('APIU', 'API Key Updated - When API key permissions or name change'),
('APID', 'API Key Deleted - When API key is revoked'),
('APIR', 'API Key Regenerated - When existing key is regenerated'),

-- =====================================================
-- BULK OPERATIONS (BLK-)
-- =====================================================
('BLKP', 'Bulk Posts Update - When multiple posts are modified at once'),
('BLKC', 'Bulk Comments Update - When multiple comments are moderated'),
('BLKM', 'Bulk Media Update - When multiple media files are modified'),

-- =====================================================
-- EXPORT/IMPORT OPERATIONS (EXP-)
-- =====================================================
('EXPP', 'Posts Exported - When posts are exported'),
('EXPC', 'Comments Exported - When comments are exported'),
('EXPM', 'Media Exported - When media library is exported'),
('IMPP', 'Posts Imported - When posts are imported'),
('IMPC', 'Comments Imported - When comments are imported'),

-- =====================================================
-- NEWSLETTER OPERATIONS (NEW-)
-- =====================================================
('NEWS', 'Newsletter Subscribed - When user subscribes to newsletter'),
('NEWU', 'Newsletter Unsubscribed - When user unsubscribes'),
('NEWC', 'Newsletter Campaign Created - When campaign is created'),
('NEWP', 'Newsletter Campaign Sent - When campaign is sent'),

-- =====================================================
-- MAINTENANCE OPERATIONS (MNT-)
-- =====================================================
('MNTC', 'Cache Cleared - When cache is manually cleared'),
('MNTS', 'Search Index Rebuilt - When search index is regenerated'),
('MNTD', 'Database Optimized - When database maintenance runs'),
('MNTB', 'Backup Created - When backup is generated'),
('MNTR', 'Backup Restored - When backup is restored'),

-- =====================================================
-- SECURITY OPERATIONS (SEC-)
-- =====================================================
('SEC2', '2FA Enabled/Disabled - When two-factor authentication setting changes'),
('SECW', 'IP Whitelist Updated - When IP whitelist is modified'),
('SECP', 'Password Policy Updated - When password requirements change'),
('SECS', 'Session Revoked - When user session is terminated'),

-- =====================================================
-- CUSTOM OPERATIONS (CST-)
-- =====================================================
('CST1', 'Custom Operation 1 - Reserved for extensions'),
('CST2', 'Custom Operation 2 - Reserved for extensions'),
('CST3', 'Custom Operation 3 - Reserved for extensions'),
('CST4', 'Custom Operation 4 - Reserved for extensions'),
('CST5', 'Custom Operation 5 - Reserved for extensions');
