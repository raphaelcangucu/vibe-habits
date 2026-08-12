---
name: app-publishing
description: Guides mobile app submission to Google Play and Apple App Store, including signing, assets, review compliance, release tracks, TestFlight, and version management. Use for publishing, store submission, signing, provisioning, listings, privacy declarations, phased releases, or rejection remediation. Do not use for app coding, UI/UX design, market research, revenue tracking, or analytics.
license: Apache-2.0
metadata:
  owner: codex
  domain: app-publishing
  maturity: draft
  risk: low
  tags: mobile, app-store, google-play, ios, android, publishing, release
---

# App Publishing

## Purpose

Produce platform-specific submission checklists, asset manifests, and readiness reports for publishing mobile applications to Google Play Store and Apple App Store. Every checklist item must reference the platform requirement it satisfies. Do not submit until all blocking items are resolved.

## Source freshness rule

Store rules, prices, limits, device sizes, SDK requirements, and review timelines change frequently. Before acting, verify all current requirements against official Apple or Google documentation. Treat numeric values in this guide as checklist hints, not timeless authority. If the current official requirement differs, the official requirement wins and the readiness report must record the difference.

## When to use this skill

- Preparing a first submission to Google Play or Apple App Store.
- Sending an update through store review.
- Generating or validating listing assets.
- Setting up or rotating signing keys, certificates, or provisioning profiles.
- Diagnosing a store rejection.
- Auditing or documenting a repository's app-publishing CI/CD pipeline.
- Working with release tracks, phased rollouts, TestFlight, or beta distribution.

## Do not use this skill when

- Writing app code, fixing bugs, or implementing features.
- Creating UI/UX mockups or design assets from scratch.
- Performing market research for an app idea.
- Tracking app revenue or financial metrics.
- Analyzing app analytics data.

## Operating procedure

### Step 1 — Identify target platform and release type

Determine:

| Dimension | Options |
| --- | --- |
| Platform | Google Play, Apple App Store, or both |
| Release type | New app or update |
| Distribution | Production, beta, or internal testing |
| Urgency | Standard review or expedited Apple review when legitimately eligible |

### Step 2 — Google Play Console checklist

#### Signing and build

- Enroll in Google Play App Signing when appropriate. Upload and securely back up the upload key.
- Submit Android App Bundle (`.aab`) format when required for the app type.
- Ensure `versionCode` is an integer strictly higher than every prior upload and is never reused.
- Keep `versionName` as the user-facing semantic version.

#### Store listing

- App title: verify the current maximum length; historically 30 characters.
- Short description: verify the current maximum; historically 80 characters.
- Full description: verify the current maximum; historically 4,000 characters.
- Phone screenshots: verify current count, aspect ratio, dimensions, formats, and device requirements. Historical guidance was 2–8 screenshots, 16:9 or 9:16, 320–3840 px, PNG or JPEG.
- Tablet screenshots: provide 7-inch and 10-inch sets when required or recommended.
- Feature graphic: verify current requirement; historical size is 1024 × 500 px PNG/JPEG.
- App icon: verify current requirement; historical size is 512 × 512 px PNG.

#### Compliance

- Complete the IARC content-rating questionnaire accurately.
- Complete Data Safety declarations based on actual app and SDK behavior.
- Declare target audience and child-directed content accurately; apply COPPA/Families requirements where relevant.
- Provide a public privacy-policy URL and an in-app link whenever required.
- Declare ads, including ads delivered by third-party SDKs.

#### Release tracks

- Internal testing: use for rapid private validation.
- Closed testing: invite-only alpha/beta and required account-specific testing where applicable.
- Open testing: public beta when appropriate.
- Production: publish only after an appropriate beta stage and all policy requirements are satisfied.

Do not rely on a fixed review timeline. Record the current estimate from Play Console and allow additional time for new accounts, first submissions, and policy review.

### Step 3 — Apple App Store Connect checklist

#### Certificates and signing

- Confirm active Apple Developer Program membership and current agreements.
- Use a valid Apple Distribution certificate and track its expiration.
- Use an App Store provisioning profile linking the certificate, App ID, bundle ID, and entitlements.
- Ensure the registered Bundle ID exactly matches `PRODUCT_BUNDLE_IDENTIFIER`; it cannot be changed for the existing app record.
- Verify current certificate limits in the Apple Developer portal instead of relying on a fixed number.

#### Store listing

- App name: verify current maximum length; historically 30 characters.
- Subtitle: verify current maximum length; historically 30 characters.
- Description: explain the actual value and features of the submitted build.
- Keywords: verify current limit; historically 100 comma-separated characters.
- Screenshots: use the submitted build's real UI. Verify the currently required display classes, resolutions, count, and format directly in App Store Connect. Historical device sizes include 6.7-inch and 6.5-inch iPhone displays and 12.9-inch iPad displays.
- App previews: when used, verify current duration, resolution, device, audio, and format rules.
- App icon: verify current requirements; historically 1024 × 1024 PNG without alpha or pre-rounded corners.

#### Compliance and review

- Review the current App Review Guidelines, especially performance, accurate metadata, purchases, design, privacy, data use, and tracking.
- Test for crashes and blocking bugs on current physical devices where possible.
- Ensure screenshots and descriptions match the submitted build.
- Use Apple in-app purchase where current rules require it for digital goods or services.
- Ensure the app provides meaningful native value.
- Provide a complete public privacy policy and an in-app link.
- Show App Tracking Transparency authorization before any activity Apple classifies as tracking.
- Complete App Privacy declarations based on actual code, SDKs, and server behavior.
- Complete the current age-rating questionnaire.
- Answer export-compliance questions accurately. Record `ITSAppUsesNonExemptEncryption` where appropriate.

#### TestFlight

- Internal testing: use App Store Connect team members for the first validation stage.
- External testing: use email invitations or a public link after Beta App Review where required.
- Verify current tester limits and build-expiration rules; historically external testing supported up to 10,000 testers and builds expired after 90 days.

#### Release options

- Manual release: preferred for a first production release so the owner controls launch timing.
- Automatic release: use only when immediate publication after approval is intended.
- Phased release: consider for updates to limit exposure while monitoring issues. Verify the current rollout schedule and controls in App Store Connect.

Do not promise a fixed review timeline. Record the current estimate and whether expedited review is legitimately available.

### Step 4 — Store asset manifest

Always verify current official specifications before accepting an asset.

| Asset | Google Play hint | Apple App Store hint |
| --- | --- | --- |
| App icon | Historically 512 × 512 PNG | Historically 1024 × 1024 PNG, no alpha or rounded corners |
| Feature graphic | Historically 1024 × 500 PNG/JPEG | Not applicable |
| Phone screenshots | Platform-defined aspect ratio and bounds | Current App Store Connect display classes and resolutions |
| Tablet screenshots | Device-class dependent | Required if the app supports iPad and App Store Connect requests them |
| Video preview | YouTube listing video where supported | Device-matched App Preview subject to current duration and format rules |

### Step 5 — Version management

Follow semantic versioning where it reflects the product:

- `MAJOR`: breaking change or major product redesign.
- `MINOR`: backward-compatible feature addition.
- `PATCH`: bug fix or small improvement.

Platform rules:

- Android `versionCode`: monotonically increasing integer; never reuse.
- Android `versionName`: user-facing version.
- iOS `CFBundleVersion`: unique build number for each uploaded train and increased as Apple requires.
- iOS `CFBundleShortVersionString`: user-facing version associated with the App Store version.

Use CI or build settings as the single source of truth. Do not hardcode versions independently in multiple files.

### Step 6 — Common rejection prevention

| Rejection risk | Platform | Prevention |
| --- | --- | --- |
| Crashes or blocking bugs | Both | Test supported devices and OS versions, including physical hardware when possible |
| Misleading metadata or screenshots | Both | Use only actual UI and features present in the submitted build |
| Missing or incomplete privacy policy | Both | Publish an accurate policy and link it from the listing and app |
| Incorrect privacy or Data Safety declarations | Both | Audit first-party code, APIs, SDKs, and data sharing |
| Purchase-policy bypass | iOS | Follow current Apple payment rules and applicable entitlements |
| Insufficient native value | iOS | Provide meaningful app functionality beyond a thin web wrapper |
| Missing ATT authorization | iOS | Request authorization before tracking when required |
| Incorrect content rating | Both | Revisit the questionnaire whenever content changes |
| Missing key or expired certificate | Both | Keep encrypted backups and renewal ownership documented |
| Unsupported Android target API | Android | Verify the current Play target API deadline before release |

## Decision rules

- Prefer beta validation before production. For this project, use internal TestFlight before App Store submission.
- Verify signing credentials before the planned upload date.
- Screenshots must represent the submitted build. Retake them after relevant UI changes.
- Privacy declarations must be accurate. Do not guess, deliberately over-declare, or under-declare; inspect actual behavior and seek legal advice when needed.
- Prefer phased rollout for production updates unless product risk or urgency supports another option.
- Build numbers and platform version codes must increase according to platform rules.
- Treat child-directed content and COPPA/GDPR-K questions as legal-compliance blockers when applicable.

## Output formats

### Platform checklist

```markdown
## [Platform] Submission Checklist: [App Name] v[Version]
- Release type: New / Update
- Distribution: Internal / Closed Beta / Open Beta / Production
- Target date: YYYY-MM-DD

### Signing & Build
- [ ] [Item] — Status: ✅ Done / ⚠️ In progress / ❌ Blocked ([reason])

### Store Listing
- [ ] [Item] — Status

### Compliance
- [ ] [Item] — Status

### Testing
- [ ] [Item] — Status

### Blocking issues: [count]
- [Blocking item and resolution]
```

### Asset manifest

```markdown
## Store Asset Manifest: [App Name] v[Version]

| Asset | Required spec | File | Status |
| --- | --- | --- | --- |
| App icon | [verified current spec] | [path] | ✅ / ⚠️ / ❌ |
| Phone screenshots | [verified current spec] | [paths] | ✅ / ⚠️ / ❌ |

### Missing assets: [count]
### Action items: [assets to create or fix]
```

### Submission readiness report

```markdown
## Submission Readiness: [App Name] v[Version] → [Platform]
- Assessment date: YYYY-MM-DD
- Overall status: READY / NOT READY

### Readiness summary
| Category | Items | Complete | Blocking |
| --- | ---: | ---: | ---: |
| Signing | X | X | X |
| Store listing | X | X | X |
| Compliance | X | X | X |
| Testing | X | X | X |
| Assets | X | X | X |

### Blocking items
1. [Item] — [what is needed] — [estimated resolution time]

### Risks
- [Risk] — [mitigation]

### Recommended submission date: YYYY-MM-DD
### Review estimate: [current platform estimate and source]
```

## Anti-patterns

- Skipping an appropriate beta stage and treating store review as QA.
- Publishing a generic policy that does not describe actual data practices.
- Ignoring accessibility, VoiceOver/TalkBack, scalable text, and contrast.
- Hardcoding version numbers in multiple independent places.
- Discovering certificate or key problems on submission day.
- Resubmitting after rejection without addressing the root cause and reviewer note.
- Using mockups, unreleased UI, generated fake screens, or another app's screenshots.

## Failure handling

- Lost or compromised signing credentials: document platform recovery, revoke or reset as appropriate, regenerate dependent profiles, and record schedule impact.
- Store rejection: map the cited guideline or policy to a concrete remediation plan and reviewer response.
- Changed asset requirements: re-audit every asset against current official specifications.
- Unclear legal requirements: mark the submission blocked on legal review instead of guessing.

## Related skills

- Image creation or promotional design skills for marketing assets, never fake in-app screenshots.
- Market-research and competitor-analysis skills for positioning, outside the submission workflow.
