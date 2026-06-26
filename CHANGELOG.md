# Changelog


## v4.0.0 - June 27th, 2026

Major release with a redesigned public API and open-source VerifyUI. Contains breaking changes.

- For integration guides and quick starts, see [`README.md`](./README.md).
- For a full list of API changes and upgrade steps, see [`MIGRATION.md`](./MIGRATION.md).
- For a complete public API reference, see [`Class Reference.md`](./Class%20Reference.md).

## v3.3.0 - April 28th, 2026

### Added

- Enforced a hard stop in the collection flow when users deny required location permissions.

## v3.2.2 - April 17th, 2026

### Fixed

- Fix to remove nested bundles from PingOneVerify.xcframework

## v3.2.1 - April 14th, 2026,

### Hotfix

- License updated to restore selfie capture functionality.

## v3.2.0 - March 23rd, 2026

### Added

- BlinkID Version Updated to v7.7.0
- IDRND Version updated to v2.5.0

### Fixed

- SDK Resource leak fixes
- Dynamic Retry code fixes


## v3.1.3 - February 24th, 2026

### Fixed

- PingOne Verify Live Feedback is not consistent between Web and SDK experience

## v3.1.2 - January 30th, 2026

### Added

- BlinkId Inconsistent data fixes

### Fixed

- UI Defects


## v3.1.1 - January 15th, 2026

### Added

- BlinkID License Issue Fix

### Fixed

- Defects related to verification flows

## v3.1.0 - December 19th, 2025

### Added

- BlinkID Version Updated to 7.6.2

## v3.0.0 - December 15th, 2025

### Added

- Selfie Payload Size made configurable.
- Voice verification support has been removed. This feature is no longer supported and has been discontinued in this release.

### Fixed

- Retry Screen: Clicking Cancel triggers Document Submission Error
- UI Improvements
- Support for the legacy selfieCaptureSettings has been discontinued. 

## v2.3.6 - November 26th, 2025

### Fixed

- Minor changes to improve UI/UX
- Defects related to verification flows


## v2.3.5 - October 31st, 2025

### Added

- IDRND Version updated to v2.4.3
- Expose callback for user-initiated exit from Verify flow.

### Fixed

- Updated S3 Upload app events
- Defects related to verification flows


## v2.3.4 - October 24th, 2025

### Fixed

- Fixes for Translation of Chinese & Portuguese works partially on Verify.


## v2.3.3 - October 13th, 2025

### Fixed

- Navigation back button color fixes.


## v2.3.2 - October 7th, 2025

### Fixed

- Missing label trailing and leading constraint added for attributed string support.


## v2.3.1 - October 3rd, 2025

### Added

- Rich text support added for better content formatting.


## v2.3.0 - August 25th, 2025

### Added

- Localization support through PingOne
- Strengthened security for document uploads
- Support for Aadhaar Verification
- Improvements to support backend driven flows
- Support for selfie authentication mode

### Fixed

- Minor changes to improve UI/UX
- Defects related to verification flows
