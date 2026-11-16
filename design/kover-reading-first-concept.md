# Kover — Reading First

## Goal

Make the app feel like a quiet personal library: covers lead, resuming a book is effortless, and the interface disappears while reading.

## Research signals

- Kavita 0.9.0–0.9.1 moved toward richer cover-led detail pages, stronger reading-list information, explicit activity, and clearer cover-management states.
- Apple Books makes resuming and reading progress the home-screen priority.
- Kobo's rebuilt iOS app puts reading first, supports a recent/new toggle, restores a cover grid, and offers continuous vertical reading.
- Panels treats the reader as a set of content-specific presets and keeps the library cover-forward.
- YACReader exposes comic modes and image tuning without making those controls permanent chrome.
- Readwise Reader distinguishes the furthest reading progress from the last viewed position, which is useful for accidental navigation and previews.

## Direction

- Warm charcoal library surfaces, warm paper reader, eucalyptus accent, and cover artwork as the primary color.
- One dominant continuation action; secondary actions remain compact.
- Titles and progress live outside cover artwork. No repeated `Read` pills over every cover.
- Compact native bottom navigation that reserves content space instead of covering it.
- Reader controls appear on tap as slim overlays and auto-hide.

## Screen concepts

1. **Home:** one prominent `Reading now` card, then compact `On deck` and `Recently added` shelves.
2. **Library:** integrated search, visible filter state, cover grid, title below cover, and a thin progress line.
3. **Detail:** cover-derived colorscape, title/author first, one `Continue reading` action, compact metadata, then chapters.
4. **Reader:** generous typography and margins with a lightweight progress scrubber, contents, appearance, brightness, and bookmark controls.

## Final image-generation prompt

```text
Use case: ui-mockup
Asset type: high-fidelity visual concept board for the Kover Flutter iPhone reading app
Input images: Images 1–5 are current Kover screens. Use them only as product/IA references for Home, Library, Series Detail, EPUB Reader, and reader controls. Redesign rather than tracing.

Primary request: Create one polished landscape presentation board containing four separate, full-height iPhone screen mockups for a cohesive "Reading First" redesign. The four screens are: Home, Library, Book Detail, and Reader. This must look like a realistic shippable mobile product UI, not concept art.

Visual direction: quiet editorial library; warm charcoal and near-black chrome; warm paper reading surface; restrained eucalyptus/teal accent; subtle amber for small status cues; vivid book covers provide most color; elegant but practical iOS-native spacing; compact SF-style sans serif for interface; readable book serif only inside the Reader; soft 16–20 px corner radii; subtle depth, no glass overload.

Screen 1 — Home:
- small top line "KOVER"
- large title "Reading now"
- a prominent horizontal continue-reading card with one book cover, title "11/22/63", author "Stephen King", progress "38%", and primary action "Continue"
- below, compact cover rows labeled "On deck" and "Recently added"
- covers remain unobscured; no large repeated Read buttons
- compact bottom tab bar: Home, Library, Search, More

Screen 2 — Library:
- title "Library"
- integrated search field with placeholder "Search your library"
- compact filter chips "All", "Unread", "Downloaded"
- two-column cover grid with titles below the covers, thin progress bars at the bottom edge, subtle format/offline status icons, and an unobtrusive sort button
- covers remain the visual focus; no CTA overlay

Screen 3 — Book Detail:
- blurred/soft colorscape header derived from the cover
- large cover, title "11/22/63", author "Stephen King"
- metadata line "226K words · 8–22 hours · 2011"
- one strong button "Continue reading" with progress "38%"
- compact secondary icons for Want to Read, Download, More
- below, a clean "Chapters" list and restrained genre pills
- clear hierarchy, not a wall of metadata

Screen 4 — Reader:
- distraction-free warm paper book page
- serif reading text with chapter heading "CHAPTER 7"
- controls visible as a temporary overlay: slim translucent top bar with back, title "11/22/63", bookmark; slim bottom bar with "118 of 522", a progress scrubber, "Aa", contents, and brightness
- generous reading margins, excellent line height, no large opaque control panels
- show that controls can auto-hide

Composition/framing: 16:10 landscape design board, four equal portrait phone frames in one row, consistent screen size, generous margins, neutral dark presentation background. Include a small board title "Kover — Reading First" above the phones and tiny screen labels Home, Library, Detail, Reader below them.
Text: Render only the exact interface text specified above. Keep it crisp and correctly spelled. Avoid extra marketing copy.
Constraints: preserve practical iPhone safe areas and touch targets; retain current Kover/Kavita content model; original visual design; no external brand logos; no watermarks; no floating controls obscuring content; no huge pill buttons over covers; no illegible microtext; no extra phones or duplicate screens.
Avoid: generic SaaS dashboard styling, neon colors, excessive gradients, heavy glassmorphism, clutter, oversized navigation, skeuomorphic bookshelves, copying Apple Books, Kobo, Panels, or Kavita pixel-for-pixel.
```

Generated with the built-in image-generation tool using the current Kover screenshots as product references.
