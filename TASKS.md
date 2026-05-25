# Vectra — Task History & Roadmap

---

## Completed Work (Phases 1–5) ✅

| Phase | Summary |
|-------|---------|
| 1 — Critical fixes | Save-As fallback, symbol edit layers panel, FFmpegKit wired, Lottie animated fills/strokes |
| 2 — Animation system | Timeline keyframe CRUD + context menu, animated SVG SMIL colors, easing editor wired, onion skin controls, motion-path bezier handle dragging |
| 3 — Editing tools | Inline text editing, align/distribute panel, corner-radius handles, knife compound/group support, pathfinder compound support, effects SVG filter export |
| 4 — UX polish | Autosave/crash recovery, `PanelSlider` extracted to common widgets, undo-depth indicator in status bar, zoom-to-fit selection, RepaintBoundary canvas perf, flip H/V shortcuts |
| 5 — Platform & distribution | iCloud/external-path recent projects, `PrivacyInfo.xcprivacy`, review trigger on save, FFmpegKit platform guard, templates library confirmed |

---

## Phase 6 — Broken or Incomplete Features ✅

All Phase 6 tasks completed.

| # | Task | Status |
|---|------|--------|
| 6.1 | Compile error: `_FrameGridState` extra brace | ✅ Was already clean |
| 6.2 | Compile error: `_OnionSkinToggleState.build` wrong signature | ✅ Was already clean |
| 6.3 | Width tool: no canvas behavior | ✅ Implemented (prior session) |
| 6.4 | SVG export: gradient fills silently export as flat color | ✅ Fixed — `<linearGradient>/<radialGradient>` defs in `<defs>`, `fill="url(#lgN)"` |
| 6.5 | SVG export: image shapes have no `href` data | ✅ Fixed — `href="data:mime;base64,..."` embedded from `doc.assets` |
| 6.6 | Lottie export: symbol instances & image shapes silently dropped | ✅ Fixed — symbol instances inlined as grouped shape layers; images emit `ty:2` layer + asset entry |
| 6.7 | SVG export: pattern fills silently dropped | ✅ Fixed — SVG `<pattern>` defs (dots/stripes/crosshatch/checkerboard) |
| 6.8 | Graph editor: value-curve dragging not committed | ✅ Fixed — `updateKeyframeForShapeNoHistory` during drag, `commitCurrentState()` on pan-end |
| 6.9 | Width tool: `VecWidthProfile` never set via UI | ✅ Fixed — `WidthProfileSection` with sparkline preview + Clear button |
| 6.10 | SVG export: compound shapes output empty `<g>` comment | ✅ Fixed — `PathfinderOps.expand()` → sampled `VecPathShape` → real SVG `<path d="...">` |

---

## Phase 7 — Future (no code defined yet)

| # | Task | Notes |
|---|------|-------|
| 7.1 | **Collaboration / cloud sync** | CRDT (Yjs/Automerge) recommended for concurrent edits. Requires backend definition first. |
| 7.2 | **Windows / Linux: FFmpegKit replacement** | FFmpegKit is macOS/iOS/Android only. For Windows/Linux MP4 export, investigate `ffmpeg_cli` (spawns system ffmpeg) or `video_player` + native channel. |
| 7.3 | **App Store screenshots & metadata** | Generate device frames for App Store listing; fill in App Privacy details in App Store Connect to match `PrivacyInfo.xcprivacy`. |
