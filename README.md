# Repertory

Repertory is a watchlist for one person. You stash movies and series into a foyer queue, light exactly one of them when a watch starts, and dismiss it with a grade when the credits roll. The home surface is that lit slot and the dated spine of what you actually finished.

It is for film and series fans who already search or scan titles into a queue, and who want one now-showing slot plus an honest finish order. It is not a couple's overlap bill, a forced next-up carousel, a last-in burn board, or a streaming store.

## Architecture

The domain is a marquee fold with two resting phases, Dark and Lit. A single `RepertoryRoot` holds the foyer, the marquee, and the append-only rep chronicle. `RepertoryHouse` is the only seam the screens will call. The file on disk and one `UserDefaults` key are projections of that memory, written atomically and debounced after each mark.

This fits the product because the thing you persist is not "I added a title." The thing you persist is "I dismissed the title I had explicitly lit." Stash cannot sneak a finish onto the chronicle, and a second light cannot replace a showing title. Refused steps return `EmptyMark`, `DoubleMark`, or `Hush` and leave the root alone. The grade sheet is transient: dismiss already folded Lit back to Dark, and the open grade id lives only until the grade is confirmed.

## Why someone would pick this

The usual watchlist is search, then queue, then a reorderable seen shelf, then a rating. Repertory's verb is light-then-dismiss.

- Stash appends a pass to the foyer and does not touch the marquee.
- Light moves the tapped pass onto a dark marquee and folds Dark to Lit.
- Dismiss writes a `RepMark` with a `daykey` (YYYYMMDD from the start of the day), opens the grade, clears the marquee, and folds Lit to Dark.
- Dismiss on a dark marquee returns `EmptyMark` and does not add a finish.
- Light while a title is already lit returns `DoubleMark` and changes nothing.
- Peel drops only the latest finish and puts that pass at the head of the foyer without relighting the marquee.
- An empty marquee over an empty foyer reports `Hush`.

On the Simulator the `rep.demo.v1` seed starts Lit, with one pass showing, two foyer passes, and two earlier finishes, so Dismiss is live on the first frame.

## How this differs from the rest of the batch

Same family as a watchlist, different persisted verb. The finish is dismiss-the-marquee after an explicit light, not a couple overlap reel, an enforced programme head, a LIFO gate, or a seated stamp thread. There is no tab bar. Discover, the queue, and Profile arrive as sheets over a home slot that never leaves.

## Art

Style: oil painting chiaroscuro, typographic, with dithered grain. Assets are filled by a later step. Image set names: `rep_Onboarding1`, `rep_Onboarding2`, `rep_Onboarding3`, `rep_EmptyHome`, `rep_TwistHero`, `rep_Splash`, `rep_EmptyFoyerArt`.

Base prompt:

```
Oil painting chiaroscuro with a strong single key light raking across a staged subject, deep shadow falloff, visible brush impasto, and a typographic counterpoint where bold condensed lettering is painted into the composition. Dithered grain over the whole plate for a nostalgic high-contrast print feel. Cutout subjects with true alpha, solid in the center, transparent corners. No specific colors; the palette is fixed.
```

`rep_Onboarding1` (1024x1536): base prompt, plus "a person or object that is this product in one glance", plus the hard cutout instruction (isolated solid subject, real PNG alpha, transparent corners, no plate, no glass, no wire frame).

`rep_Onboarding2` (1024x1536): base prompt, plus "the primary action of this product, mid-gesture", plus the same hard cutout instruction.

`rep_Onboarding3` (1024x1536): base prompt, plus "a later moment when the product has accumulated meaning", plus the same hard cutout instruction.

`rep_EmptyHome` (1024x1024): base prompt, plus "a solid closed bowl, crate or folded cloth waiting to be used, ceramic, wood or fabric, fully opaque, not glass", plus the same hard cutout instruction.

`rep_TwistHero` (1024x1024): base prompt, plus "an emblem representing this app's signature feature", plus the same hard cutout instruction.

`rep_Splash` (1024x1024): "An empty repertory house with one raking spotlight on a bare marquee, oil painting chiaroscuro, typographic title painted into the gloom, dithered texture, full-bleed."

`rep_EmptyFoyerArt` (1024x1024): "A dim empty foyer with hanging velvet and a single pool of light on the floor, oil chiaroscuro, dithered grain, a quiet painted caption area, transparent cutout subject centered." plus the hard cutout instruction.

## Build

```bash
cd apps/Repertory
xcodegen generate
xcodebuild build-for-testing -scheme Repertory -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
```

Signing flags stay on the command line. The project uses Swift 6.2 with strict concurrency complete, GameKit, and the existing Alamofire package. Contact: https://repertory-marquee.space/contact-us

## Game Center release

Six nonrepeatable achievements (210 points total) are defined in
`metadata/game_center.json`. Each has English and Malay descriptions and an
original 512×512 PNG badge. Rebuild the artwork with the factory Python runtime:
`python scripts/game_center_art.py` (Pillow required). The app and factory must
use the same achievement identifiers; do not rename identifiers after release.

`GameCenterService` authenticates on native launch and opens Apple's dashboard
from Profile. Only successfully saved, graded finishes count. Pending progress
is persisted per Game Center player, merged with the server, and retried on
foreground or Retry sync. Undo and Reset all data preserve achievement progress.
The title history stays local. Simulator demo history and automated review
captures never report achievements.

The factory reads the manifest automatically. Before `build.run`, it enables
`GAME_CENTER` on the developer bundle ID so Bitrise can generate a matching
provisioning profile. `storeconfig.apply` configures achievement versions,
localizations and images using Apple's v2 API and waits for image processing.
Before `review.submit`, the factory enables Game Center on the editable iOS
version and prepares a single draft containing the app version and all six
unreleased achievement versions. Its existing developer browser session sends
that draft. Configuration and upload failures block review preparation.

Resume the existing Sloglide factory card after resolving its stopped
`appstore.create` step. It remains on operator hold; this change does not start
an archive or submit a build. The existing supplied App Store screenshot pack
is preserved. Redeploy `site.deploy` to publish the updated Game Center privacy
paragraph before submitting. The shipping factory process must load the updated
Python code before resuming.

Validation: simulator build and 25 XCTest cases pass; Release build for a generic
iOS device passes with signing disabled. Profile was inspected on disposable
iPhone and iPad simulators. A signed physical-device test is still required for
the real sign-in, banner, dashboard, offline retry and account-switch flows.
The live Apple preflight currently fails through the configured account proxy
with a TLS connection error, so no remote Game Center setup is claimed complete.
