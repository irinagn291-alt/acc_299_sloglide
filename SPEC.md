# Repertory — Build Specification

> Portfolio app 384, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Queue movies and series, then log and rate what you finish watching.

| Field | Value |
| --- | --- |
| Product name | Repertory |
| Bundle identifier | `com.repertory.marquee` |
| Domain | https://repertory-marquee.space |
| Contact URL | https://repertory-marquee.space/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone (portrait, landscape left, landscape right) and iPad (all orientations) |
| Interface style | Dark |
| Asset prefix | `rep_` |
| User-Agent | `Repertory/1.0 (iOS; +https://repertory-marquee.space)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Repertory -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A solo viewer lights one stashed pass on the home marquee when a watch starts and dismisses it with a grade when the credits roll so the rep log records honest finish order, not a reorderable seen shelf or a streaming app.

### 2.1 User flow

1. Cold launch lands on the lit marquee; tap Dismiss to file today's RepMark and rate the pass you just finished.
2. Open Foyer sheet and tap Light on a queued pass to move it onto the marquee before you press play elsewhere.
3. From Discover sheet, search TMDB and stash a new pass into Foyer without lighting the marquee.
4. Scan a DVD or Blu-ray barcode on Discover; resolve the title and stash it to Foyer.
5. Open Profile sheet to read taste rollups from RepMarks and Peel the last dismiss if you logged the wrong title.
6. Reorder passes in Foyer; lighting always picks the tapped pass, not automatic queue head.

### 2.2 Essential behaviour

- Paginated TMDB movie and TV search with local poster and metadata cache
- Foyer queue sheet with manual ordering and stash from search
- AVCaptureMetadataOutput barcode capture resolving to TMDB find
- Marquee home with Light-then-dismiss fold and fused grade sheet
- Append-only Rep chronicle keyed by daykey with 1–5 grades
- Profile taste charts derived only from RepMarks
- Peel undo for the latest RepMark or Light state rollback rules
- UserDefaults+Codable single-root store with debounced save after each mark
- Simulator seed: one Pass Lit on the marquee plus two Foyer passes and two prior RepMarks so Dismiss is the first live verb

---

## 3. Uniqueness assignment for Repertory

| Axis | Assigned value |
| --- | --- |
| Architecture | **Marquee ADT fold (Dark | Lit); the rep house is a fold over the live Marquee; Stash writes a Pass into Foyer only; Light samples one Foyer Pass onto the Marquee and folds Dark to Lit; Dismiss writes RepMark with daykey, opens grade, clears Marquee, and folds Lit to Dark; Dismiss on Dark writes EmptyMark; Light while Lit writes DoubleMark; Peel drops the last RepMark; empty Marquee with empty Foyer writes Hush** |
| UI approach | **SwiftUI WKWebView representable · 738a2814e8** |
| Naming convention | **Repertory / marquee-foyer lexicon (Foyer, Pass, Marquee, LightMark, RepMark, DoubleMark, EmptyMark, PeelMark, GradeRollup, Hush)** |
| File organization | **By repertory role (Foyer, Pass, Marquee, LightMark, RepMark, DoubleMark, EmptyMark, PeelMark, GradeRollup)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **dithered · offset-overlap · soft** |
| Typography | **Avenir Next** |
| Navigation pattern | **Foyer-locked chrome (the lit marquee and rep ribbon never leave; Discover, Foyer and Profile arrive as sheets; light and dismiss fuse on Marquee; no tab bar)** |
| AI art style | **Oil painting chiaroscuro · typographic** |
| Functional twist | **Light-then-dismiss (Stash fills Foyer only; Light folds Dark to Lit; Dismiss writes RepMark and folds Lit to Dark; Dismiss on Dark writes EmptyMark; Light while Lit writes DoubleMark; Peel drops last RepMark; seed Lit one Pass so Dismiss is live)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — watchlist

**Core** — A solo viewer lights one stashed pass on the home marquee when a watch starts and dismisses it with a grade when the credits roll so the rep log records honest finish order, not a reorderable seen shelf or a streaming app.

**Audience** — Film and series fans who search or scan titles into a foyer queue but want one lit now-showing slot and a dated rep spine of what they actually finished—not a couple's overlap bill, a forced next-up carousel, a LIFO burn board, or a chronological stamp thread.

**User flow**

1. Cold launch lands on the lit marquee; tap Dismiss to file today's RepMark and rate the pass you just finished.
2. Open Foyer sheet and tap Light on a queued pass to move it onto the marquee before you press play elsewhere.
3. From Discover sheet, search TMDB and stash a new pass into Foyer without lighting the marquee.
4. Scan a DVD or Blu-ray barcode on Discover; resolve the title and stash it to Foyer.
5. Open Profile sheet to read taste rollups from RepMarks and Peel the last dismiss if you logged the wrong title.
6. Reorder passes in Foyer; lighting always picks the tapped pass, not automatic queue head.

**Essential features**

- Paginated TMDB movie and TV search with local poster and metadata cache
- Foyer queue sheet with manual ordering and stash from search
- AVCaptureMetadataOutput barcode capture resolving to TMDB find
- Marquee home with Light-then-dismiss fold and fused grade sheet
- Append-only Rep chronicle keyed by daykey with 1–5 grades
- Profile taste charts derived only from RepMarks
- Peel undo for the latest RepMark or Light state rollback rules
- UserDefaults+Codable single-root store with debounced save after each mark
- Simulator seed: one Pass Lit on the marquee plus two Foyer passes and two prior RepMarks so Dismiss is the first live verb

**Twist** — Light-then-dismiss fold (Dark | Lit | Graded). Phases

**Why this is not a repeat** — Same watchlist family as search-stash-rate, but the persisted verb is dismiss-the-marquee after a explicit Light commitment—not couple overlap reel (Bioscope), enforced programme head admit (Usher), LIFO gate burn (Splicer), or seated stamp thread (Matinee). Axis bundle matches the free watchlist graph slot (AnyLayout·watchlist, dithered offset-overlap soft, geometric mixed-media) without colliding taken Rep-house, Marquee playbill, programme, or celluloid naming.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Only if the job changes: tonight-for-two, kanban pile, or dated timeline.
- Invariant: Vanilla search→queue→seen→rate is a 10-app clone. Pick one rare verb and persist it on home.
- Never: Not a streaming store.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

The domain core is a Marquee ADT fold with two resting phases, Dark and Lit, and a transient Graded phase that lives only while the grade sheet is up. A single RepertoryStore owns one Repertory root holding foyer, marquee, and rep, and exposes pure reducers: Stash appends a Pass to Foyer and leaves the Marquee alone; Light pulls one tapped Foyer Pass onto the Marquee and folds Dark to Lit; Dismiss writes a RepMark with a daykey, opens grade, clears the Marquee, and folds Lit to Dark. Refused transitions return typed outcomes instead of mutating state: Dismiss on a Dark Marquee returns EmptyMark, Light while already Lit returns DoubleMark, and an empty Marquee over an empty Foyer reports Hush so home can show its empty page. Peel drops the last RepMark and returns that Pass to the head of Foyer without relighting the Marquee on its own. The home verb is dismiss-the-marquee, and it is live on the first frame because the rep.demo.v1 Simulator seed writes the Lit phase with one Pass on the Marquee, two Foyer passes, and two prior RepMarks. Unit tests assert that Dismiss on Dark returns EmptyMark and leaves the rep count unchanged.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

Native SwiftUI throughout, no WKWebView or web content in the binary. The live metric is the finished count on the rep ribbon, rendered as Text(count, format: .number) with .contentTransition(.numericText()); it ticks up on Dismiss and down on Peel. The one commit that fires a haptic is the grade confirm after Dismiss via .sensoryFeedback(.success, trigger: repCount); Light, Stash, and sheet navigation stay silent. The one gesture with live feedback is a horizontal drag across the five grade pips in the fused grade sheet: the dithered fill tracks the finger and snaps to whole grades one through five, with a matching VoiceOver adjustable action.

### 3.3 Naming contract

Convention: Repertory / marquee-foyer lexicon (Foyer, Pass, Marquee, LightMark, RepMark, DoubleMark, EmptyMark, PeelMark, GradeRollup, Hush).

Examples to follow: ['Pass: a stashed title with tmdbID, mediaKind, title, year, posterPath, stashedAt', 'RepMark: an append-only finish record keyed by daykey with a one-to-five grade', 'LightMark / DoubleMark / EmptyMark: the reducer outcomes for Light, refused Light, and refused Dismiss', 'GradeRollup: taste counts folded from RepMarks for the Profile sheet']

### 3.4 Dependency contract

Zero external dependencies: no SPM entries, no CocoaPods, no vendored source. The app uses SwiftUI, Foundation, Core Graphics for the dithered rendering, and URLSession for TMDB search and poster fetch only. No AVFoundation or Vision is imported, since there is no camera capture in this build.

### 3.5 Navigation contract

Foyer-locked chrome with no TabView. The lit Marquee card and the rep ribbon never leave the root; the fused Light and Dismiss strip lives on the Marquee itself. Discover, Foyer, and Profile each arrive as a sheet that dismisses with Close on its own stack. This maps the family Discover, Queue, Seen, Profile with Rep standing in as the Seen home, and the root carries no back button and no product name in a navigation title.

### 3.6 Screen composition contract

Marquee-root fused rep (Marquee holds the live Pass, rep ribbon, and fused light and dismiss; Discover, Foyer and Profile arrive as sheets; maps family Discover|Queue|Seen|Profile with Rep as Seen; no TabView)

Marquee root (home): the live Pass card, the rep ribbon with the finished count, and the fused Light/Dismiss strip; Dark shows the full-page empty state. Discover sheet: paginated TMDB search of movies and series with cached posters and a Stash action. Foyer sheet: the manually ordered queue of stashed passes, each with Light and reorder. Profile sheet: taste rollups charted only from RepMarks, Peel for the last dismiss, and the Contact link. Grade sheet: the momentary one-to-five rate surface shown after Dismiss.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By repertory role (Foyer, Pass, Marquee, LightMark, RepMark, DoubleMark, EmptyMark, PeelMark, GradeRollup)**

```
Repertory/
  Repertory/
  App/RepertoryApp.swift, AppDelegate.swift
  Domain/Repertory.swift, Pass.swift, Marquee.swift, RepMark.swift, MarkOutcome.swift (LightMark|RepMark|DoubleMark|EmptyMark|PeelMark|Hush), GradeRollup.swift, DayKey.swift
  Store/RepertoryStore.swift, Persistence.swift, Seed.swift
  Search/TMDBClient.swift, PosterCache.swift
  Views/MarqueeRootView.swift, MarqueeCard.swift, RepRibbon.swift, LightDismissStrip.swift, GradeSheet.swift, FoyerSheet.swift, DiscoverSheet.swift, ProfileSheet.swift, EmptyMarquee.swift
  Design/Tokens.swift, Dither.swift, ButtonStyles.swift
  Resources/Assets.xcassets
  Tests/RepertoryFoldTests.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Discover
A first-class screen for **Discover**. Must render empty, populated and error states.

### 5.3 Queue
A first-class screen for **Queue**. Must render empty, populated and error states.

### 5.4 Seen
A first-class screen for **Seen**. Must render empty, populated and error states.

### 5.5 Profile
A first-class screen for **Profile**. Must render empty, populated and error states.

### 5.6 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.7 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Title** — named per this app's convention.
- **QueueItem** — named per this app's convention.
- **Rating** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **dithered · offset-overlap · soft**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#1E151C` | Screen background |
| `surface` | `#2A1E28` | Cards, rows, sheets |
| `ink` | `#F2EDF1` | Primary text and icons |
| `accent` | `#D666C4` | Primary action, key figure, progress fill |
| `muted` | `#A993A5` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Repertory/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Avenir Next**

Avenir Next carries the whole app. Display headlines use Avenir Next Bold, short and wide at one to two lines, with tight UI tracking (roughly -0.3) on the marquee title and the finished count. Body sits at Avenir Next Regular around 17pt; the rep ribbon labels use Avenir Next Medium small caps feel through tracking, not a second face. Numerals on the count and grade use the font's proportional figures through a FormatStyle, and custom sizes scale with @ScaledMetric so headlines do not clip at AX5.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **16pt** for cards, sheets and primary surfaces; **10pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **shadow** — a single soft drop-shadow token, reused everywhere a surface sits above another.

Primary control: **soft card** — primary actions live inside a rounded card using the radius below, not a flat row with no fill.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI WKWebView representable · 738a2814e8**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI WKWebView representable · 738a2814e8** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **agency** (High-end agency: huge type, air, one accent, hairline depth.)

Reference system: **dithered** — steal rhythm and restraint, not their colours or logos.

Mood: **Dot-pattern rendering technique that simulates shades with a limited palette for nostalgic, retro, high-contrast visuals.**.

Home rhythm (`offset-overlap`, comfortable): One element breaks the grid edge. The rest stays aligned.

High-end agency: huge type, air, one accent, hairline depth. Layout `offset-overlap`, density comfortable. Kit 16/10, shadow, soft card. Palette recipe `soft`. One spring on the commit (response ~0.4, damping ~0.8). Everything else is ease-out. Reduce Motion: fade, no spring. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Tight UI tracking, bright ink, no display serif. Reference type feel: agency.

Motion (`spring`): One spring on the commit (response ~0.4, damping ~0.8). Everything else is ease-out. Reduce Motion: fade, no spring.

Voice (`dry`): Short verbs. No warmth padding. 'Saved.' not 'Your changes were saved successfully.'

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- iPhone allows portrait, landscape left, and landscape right. iPad allows all
  four orientations. Keep both lists in the Info settings, and let a rotated
  screen scroll instead of clipping.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Every headline, amount, and button title is fully visible. Do not give display
  type a fixed height shorter than the font, and do not let a sibling with
  `maxHeight: .infinity` compress it. When the column is taller than the screen,
  scroll it. `.clipped()` frames an image cell; it never wraps text.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Spacing uses a base of 4: 4, 8, 12, 16, 20, 24, 32, 40, 48, in one `Spacing`
  enum next to `DesignTokens`. No other values.

**Keyboard**

- Decimal fields use `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with a `FormatStyle`, never `NumberFormatter` or
  `String(format:)`. Example:
  `Text(value, format: .number.precision(.fractionLength(0...1)))`.
  Group separators and decimal separators follow the locale.
- Whole units show no decimals. Measured values show at most one decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown values render as a dash or the word "unknown", never as 0.
- A changing metric uses `.contentTransition(.numericText(value:))` with the
  shared spring, on the same value the text shows.
- A custom drag, magnification, or rotation shows its in-flight value through
  `@GestureState` and `.updating`. The committed value changes in `.onEnded`.
- Loading rows use `.redacted(reason: .placeholder)` at the size they will have
  when the data arrives.
- A form with more than one field chains focus with an `@FocusState` enum.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- State changes use one shared spring token. A `PhaseAnimator` or
  `KeyframeAnimator` is only the single signature moment on a view, triggered
  by a value, never a loop on appear.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- The root screen has no back button. `.navigationTitle` is a screen name, never
  the product name. A back control titled with the app name is a defect: it
  reads as a button that returns to this same app.
- A sheet dismisses with Close and owns its stack. Do not push it onto a stack
  whose title is the product name.
- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- A ring or a gauge uses the same `lineWidth` for the track and the fill.
- Display type does not use `.minimumScaleFactor`. Adapt with `ViewThatFits`
  or `dynamicTypeSize.isAccessibilitySize`, and scroll the column.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.
- An actor method re-checks its state after every `await`. Do not force-unwrap
  a lookup that happened before the await. The value may be gone.
- Filter `CancellationError` out before showing error UI or retrying.
  Cancellation is a normal end, not a failure.
- Build streams with `AsyncStream.makeStream(of:)` or the throwing variant.
  Pass a bounded `bufferingPolicy`, and set `onTermination` so the producer
  stops when the consumer does.
- CPU work uses `@concurrent`. Do not run it on `@MainActor`. The scaffold does
  not turn on default main-actor isolation, so UI types still need an explicit
  `@MainActor`.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark**

UserDefaults plus Codable: one Repertory root record (foyer passes, the Marquee state, and the append-only rep chronicle) is encoded under a single versioned key. Every mark triggers a debounced save so Light, Dismiss, Stash, and Peel each land within a short coalescing window rather than on every keystroke. Day edges for the daykey use Calendar.current.startOfDay, and the daykey is stored as an Int in YYYYMMDD form.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Repertory/1.0 (iOS; +https://repertory-marquee.space)` on every request. Never reuse another app's string.
Use the **cgi search pl** search endpoint for this app.


---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- iPhone: portrait, landscape left, landscape right. iPad: all four orientations (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.entertainment`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.entertainment
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Light-then-dismiss (Stash fills Foyer only; Light folds Dark to Lit; Dismiss writes RepMark and folds Lit to Dark; Dismiss on Dark writes EmptyMark; Light while Lit writes DoubleMark; Peel drops last RepMark; seed Lit one Pass so Dismiss is live)

The twist is a Light-then-dismiss fold, so stashing a title never advances the mechanic. Stash fills Foyer only; Light samples one tapped Pass onto the Marquee and folds Dark to Lit; Dismiss writes a RepMark and folds Lit back to Dark, leaving the title to live only on Rep. The fold refuses nonsense: Dismiss on Dark writes EmptyMark and Light while Lit writes DoubleMark, both rejected by unit tests. Peel drops the last RepMark and may return that Pass to the head of Foyer. Because the seed already lit one Pass and filed two prior RepMarks, the opening home verb is Dismiss rather than stash-a-queue, which is exactly what separates this from a reorderable seen shelf.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Oil painting chiaroscuro · typographic**


Base prompt, reused and extended for every asset:

```
Oil painting chiaroscuro with a strong single key light raking across a staged subject, deep shadow falloff, visible brush impasto, and a typographic counterpoint where bold condensed lettering is painted into the composition. Dithered grain over the whole plate for a nostalgic high-contrast print feel. Cutout subjects with true alpha, solid in the center, transparent corners. No specific colors; the palette is fixed.
```

All 7 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `rep_` prefix.

### 13.1 App icon

Do not generate an app icon. Do not create an AppIcon image set and do not
paint icon artwork. The factory installs the icon later. Leave the empty
AppIcon.appiconset from the scaffold untouched.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `rep_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 2 | `rep_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 3 | `rep_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 4 | `rep_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 5 | `rep_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Light-then-dismiss (Stash fills Foyer only; Light folds Dark to Lit; Dismiss writes RepMark and folds Lit to Dark; Dismiss on Dark writes EmptyMark; Light while Lit writes DoubleMark; Peel drops last RepMark; seed Lit one Pass so Dismiss is live)' feature screen. |
| 6 | `rep_Splash` | 1024x1024 | fill | An empty repertory house with one raking spotlight on a bare marquee, oil painting chiaroscuro, typographic title painted into the gloom, dithered texture, full-bleed. |
| 7 | `rep_EmptyFoyerArt` | 1024x1024 | **required cutout** | A dim empty foyer with hanging velvet and a single pool of light on the floor, oil chiaroscuro, dithered grain, a quiet painted caption area, transparent cutout subject centered. |

### Prompt per asset

**`rep_Onboarding1`** — 1024x1536

```
Oil painting chiaroscuro with a strong single key light raking across a staged subject, deep shadow falloff, visible brush impasto, and a typographic counterpoint where bold condensed lettering is painted into the composition. Dithered grain over the whole plate for a nostalgic high-contrast print feel. Cutout subjects with true alpha, solid in the center, transparent corners. No specific colors; the palette is fixed., a person or object that is this product in one glance

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rep_Onboarding2`** — 1024x1536

```
Oil painting chiaroscuro with a strong single key light raking across a staged subject, deep shadow falloff, visible brush impasto, and a typographic counterpoint where bold condensed lettering is painted into the composition. Dithered grain over the whole plate for a nostalgic high-contrast print feel. Cutout subjects with true alpha, solid in the center, transparent corners. No specific colors; the palette is fixed., the primary action of this product, mid-gesture

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rep_Onboarding3`** — 1024x1536

```
Oil painting chiaroscuro with a strong single key light raking across a staged subject, deep shadow falloff, visible brush impasto, and a typographic counterpoint where bold condensed lettering is painted into the composition. Dithered grain over the whole plate for a nostalgic high-contrast print feel. Cutout subjects with true alpha, solid in the center, transparent corners. No specific colors; the palette is fixed., a later moment when the product has accumulated meaning

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rep_EmptyHome`** — 1024x1024

```
Oil painting chiaroscuro with a strong single key light raking across a staged subject, deep shadow falloff, visible brush impasto, and a typographic counterpoint where bold condensed lettering is painted into the composition. Dithered grain over the whole plate for a nostalgic high-contrast print feel. Cutout subjects with true alpha, solid in the center, transparent corners. No specific colors; the palette is fixed., a solid closed bowl, crate or folded cloth waiting to be used — ceramic, wood or fabric, fully opaque, not glass

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rep_TwistHero`** — 1024x1024

```
Oil painting chiaroscuro with a strong single key light raking across a staged subject, deep shadow falloff, visible brush impasto, and a typographic counterpoint where bold condensed lettering is painted into the composition. Dithered grain over the whole plate for a nostalgic high-contrast print feel. Cutout subjects with true alpha, solid in the center, transparent corners. No specific colors; the palette is fixed., an emblem representing this app's signature feature

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rep_Splash`** — 1024x1024

```
An empty repertory house with one raking spotlight on a bare marquee, oil painting chiaroscuro, typographic title painted into the gloom, dithered texture, full-bleed.
```

**`rep_EmptyFoyerArt`** — 1024x1024

```
A dim empty foyer with hanging velvet and a single pool of light on the floor, oil chiaroscuro, dithered grain, a quiet painted caption area, transparent cutout subject centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`rep.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.
- `AnyView`, or a `View.if` helper that applies modifiers conditionally.
- `Binding(get:set:)` built inline inside `body`.
- `GeometryReader` inside a lazy stack or a lazy grid.
- `@AppStorage` on an `@Observable` class. `@Query` outside a `View`.
- `MagnificationGesture` or `RotationGesture`. Use `MagnifyGesture` and
  `RotateGesture`.
- `String(format:)` or `NumberFormatter` for a number the UI shows. Use a
  `FormatStyle` on `Text`.


---

## 17. Tests

Add a unit test target `RepertoryTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Repertory/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Repertory -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.
- [ ] Do not add a watchOS app target. Apple Watch store images are fitted from the iPhone screenshots.

**Uniqueness**
- [ ] Architecture matches **Marquee ADT fold (Dark | Lit); the rep house is a fold over the live Marquee; Stash writes a Pass into Foyer only; Light samples one Foyer Pass onto the Marquee and folds Dark to Lit; Dismiss writes RepMark with daykey, opens grade, clears Marquee, and folds Lit to Dark; Dismiss on Dark writes EmptyMark; Light while Lit writes DoubleMark; Peel drops the last RepMark; empty Marquee with empty Foyer writes Hush** with no leakage across layers.
- [ ] UI approach matches **SwiftUI WKWebView representable · 738a2814e8**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Foyer-locked chrome (the lit marquee and rep ribbon never leave; Discover, Foyer and Profile arrive as sheets; light and dismiss fuse on Marquee; no tab bar)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Avenir Next** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Repertory
xcodegen generate
xcodebuild build-for-testing -scheme Repertory -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling_factory/.artifacts/genesis/com.repertory.marquee/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Repertory -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling_factory/.artifacts/genesis/com.repertory.marquee/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Repertory -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling_factory/.artifacts/genesis/com.repertory.marquee/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
