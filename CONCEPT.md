# Vectra — Vector Graphics & Animation Tool
### Product Concept Document · v0.2

---

## Overview

Vectra is a focused vector graphics editor with a built-in frame-based animation timeline. It is designed for UI designers, motion designers, and illustrators who need to create and animate vector artwork in a single environment — drawing from the best of Adobe Illustrator's illustration toolset and Macromedia/Adobe Flash's timeline animation model, without the overhead of either.

The core bet: **draw it and animate it in the same tool, the same way Flash let you, but as a modern, cross-platform native app built with Flutter.**

---

## Problem Statement

Today's options force a painful choice:

- **Adobe Illustrator** — full-featured vector drawing but no native animation. Requires exporting to After Effects for motion.
- **Figma** — excellent for UI, weak on illustration, no real animation timeline.
- **After Effects** — powerful animation but not a drawing tool; requires pre-built assets from elsewhere.
- **Rive / LottieFiles** — good for interactive animation but limited vector editing, steep learning curve.
- **Flash (legacy)** — had the right idea (draw + animate in one place) but is dead, plugin-based, and produced binary SWF.

There is no modern, cross-platform native tool that lets a designer draw a vector illustration and animate it fluently, in one environment, using the timeline metaphor that Flash pioneered.

---

## Target Users

| Segment | Use Case |
|---|---|
| UI/product designers | Animate icons, loaders, illustrations for apps and web |
| Motion designers | Create lightweight animated graphics for social, web, video |
| Illustrators | Draw with professional vector tools and optionally add motion |
| Frontend developers | Prototype animated SVG components, export Lottie |
| Animators | Frame-by-frame and tween-based character/UI animation |

---

## Core Principles

1. **Start fast.** Open a blank canvas in under two seconds. No project setup, no templates to dismiss.
2. **Flash timeline, Illustrator tools.** The animation mental model is Flash (frames, tweens, symbols). The drawing mental model is Illustrator (pen, pathfinder, appearance).
3. **Symbols are first-class.** Every reusable piece of artwork is a symbol with its own optional nested timeline — exactly as Flash MovieClips worked.
4. **Export anywhere.** SVG, animated SVG, Lottie JSON, MP4. One click per format.
5. **No clutter.** Features cut unless used by the majority of users in user research.

---

## Feature Scope

### Drawing Tools

#### Select tool (`V`)
- Click to select, drag to box-select multiple objects.
- Hold `Shift` to add/remove from selection.
- Double-click a group or symbol to enter **isolation mode** (Illustrator-style: rest of canvas dims, edits are scoped).
- Press `Esc` to exit isolation mode.
- Arrow keys for 1px nudge, `Shift+Arrow` for 10px.
- **Transform pivot:** a small crosshair shows the transform origin. By default it is placed at the shape's **center of mass** (area centroid for filled paths, arc-length centroid for open strokes). Drag it anywhere on canvas — or snap to corners, bounding-box center, CoM, or a custom point — before rotating/scaling. The CoM position is shown as read-only coordinates in the Properties panel.

#### Free Transform tool (`Q`)
- Unified tool for scale, rotate, and skew on a single bounding box.
- Drag corner handles to scale. Drag outside corners to rotate. Drag edge handles to skew.
- Pivot defaults to the shape's **center of mass**; drag to reposition. Press `Cmd/Ctrl+Shift+M` to snap it back to CoM at any time.
- Hold `Alt` to transform from bounding-box center. Hold `Shift` to constrain proportions or angle.
- When multiple objects are selected, the pivot defaults to the **composite CoM** — the area-weighted centroid across all selected shapes — so a group of irregular shapes still rotates around their natural balance point.

#### Pen tool (`P`) — Illustrator-style
- Click for corner points, click-drag for smooth Bézier handles.
- `Alt`-click a smooth point to convert it to a corner (break handle symmetry).
- `Alt`-drag a handle on an existing point to break symmetry mid-draw.
- Double-click an existing path segment to add a node at that position.
- Hover over the first anchor to close the path (cursor shows a small circle).
- `Backspace` deletes the last placed point while still drawing.
- Smart angle snapping: 0°, 45°, 90°, 135° while holding `Shift`.
- **Auto-smooth mode toggle** (preference): behave like Figma's pen (smooth by default) or Illustrator's pen (corner-first). Default: Illustrator-style.

#### Width tool (`W`) — from Illustrator
- Drag any point along a stroke to pull out a variable-width profile.
- Width handles appear as diamond nodes along the stroke.
- Double-click a width handle to enter precise numeric values for left/right width at that point.
- Width profiles are saved as named presets and reapplied to any stroke.
- Exported as SVG `<marker>` shapes or flattened paths depending on export format.
- *This is the single biggest drawing feature missing from every lightweight vector tool. Illustrators use it constantly for calligraphic lines, tapered strokes, and organic illustration.*

#### Pencil / Blob Brush tool (`B`)
- Freehand drawing mode. Strokes are smoothed on mouse-up using the Ramer–Douglas–Peucker algorithm.
- Smoothing slider: 0% (raw input) → 100% (very smooth).
- **Blob Brush variant:** draws filled shapes instead of open strokes. Adjacent same-color blobs merge automatically (Illustrator blob brush behavior).

#### Rectangle tool (`R`)
- Click-drag to draw. Hold `Shift` for square, `Alt` to draw from center.
- **Live corners:** drag the circular in-canvas handle on any corner to round it. Each corner can be individually rounded by holding `Alt` while dragging. (Illustrator CC live corners, not just rectangles — all shapes support this.)
- Corner style selector: round, inverted round, chamfer.

#### Ellipse tool (`E`)
- Click-drag to draw. Hold `Shift` for circle, `Alt` to draw from center.
- Drag the in-canvas arc handle to create pie/donut segments. Separate inner-radius handle for donuts.

#### Polygon / Star tool (`Y`)
- Click-drag for regular polygons. Scroll while dragging to change side count.
- Hold a second modifier to switch to star mode; drag inner handle to set star depth.

#### Text tool (`T`)
- Click for point text, click-drag for area text.
- Inline font controls: family, size, weight, tracking, leading, alignment.
- Text on a path: select text + path, then Object > Text on Path.
- Text is kept as live text until export requires flattening.

#### Node editor — Illustrator direct-select model
- Activated by pressing `A` (Direct Select) while a path is selected, or by double-clicking in Select mode.
- Nodes: white squares (unselected), blue squares (selected). Handles: circles.
- Click a segment between nodes to select it; drag to reshape the curve (Bézier tangent drag).
- Drag a segment to add a node at that position.
- `Cmd/Ctrl+A` selects all nodes. `Delete` removes selected nodes with auto-smooth join.
- **Node types:** smooth (linked handles), corner (broken handles), symmetric. Toggle with `Shift+C`.
- **Simplify path:** Object > Path > Simplify — reduces node count while preserving shape within a tolerance.

---

### Pathfinder — from Illustrator

The Pathfinder panel is Illustrator's most powerful production feature. Vectra ships a full implementation.

| Operation | Description |
|---|---|
| **Unite** | Merge selected shapes into one compound outline. |
| **Minus Front** | Subtract the topmost shape from shapes beneath it. |
| **Intersect** | Keep only the overlapping area of all selected shapes. |
| **Exclude** | Remove overlapping areas, keep the rest (XOR). |
| **Divide** | Slice all shapes at every intersection edge, producing separate pieces. |
| **Trim** | Remove hidden parts of lower shapes without merging. |
| **Outline** | Convert fills to stroked outlines along all edges. |

- Operations are **live** by default: the result is a compound shape that remembers its inputs. Expand to flatten.
- All operations are also available as keyboard-accessible commands.

---

### Appearance Panel — from Illustrator

Each object can have **multiple fills and multiple strokes**, stacked in order.

- Add fill / Add stroke buttons at the bottom of the panel.
- Each fill/stroke entry shows: color swatch, blend mode, opacity slider.
- Drag rows to reorder (top row renders on top).
- A stroke can sit above or below the fill.
- Effects per entry: currently none in v1, planned for v1.2.
- **Why this matters:** lets illustrators build complex line-art (e.g., a colored stroke on top of a wider black stroke for outlined characters) without duplicating objects.

---

### Align & Distribute Panel — from Illustrator

Select two or more objects and align or space them precisely.

- Align: left edge, center horizontal, right edge, top edge, center vertical, bottom edge.
- Distribute: equal horizontal spacing, equal vertical spacing, distribute centers.
- **Align to:** selection bounding box (default), key object (click an object in the selection to make it the fixed reference — Illustrator's "align to key object"), or canvas.
- Distribute by exact pixel spacing: enter a gap value and click Distribute.

---

### Clipping Masks — from Illustrator

- Select a mask shape (topmost) and the objects to clip beneath it, then `Cmd/Ctrl+7` or Object > Make Clipping Mask.
- The mask shape loses its fill/stroke and clips everything in the group.
- Double-click the clipping group to enter isolation mode and reposition the mask or content independently.
- `Cmd/Ctrl+Alt+7` to release.

---

### Properties Panel

The right panel shows contextual properties for the selected object.

**Fill** (per Appearance entry)
- Solid color (hex, RGB, HSL input)
- None
- *(Gradients in v1.2)*

**Stroke** (per Appearance entry)
- Color, width (supports variable-width via Width tool)
- Dash pattern: solid / dashed / dotted, with offset control
- Cap: butt, round, square
- Join: miter, round, bevel
- Align stroke: inside / center / outside the path

**Transform**
- X, Y, W, H with aspect-lock toggle
- Rotation in degrees
- Flip horizontal / vertical
- Blend mode, Opacity
- **Pivot point** — current pivot coordinates (editable by typing; also draggable on canvas)
- **Center of mass** — computed CoM coordinates (read-only). A small dot is rendered on the canvas at this position whenever the shape is selected. Click the crosshair icon next to Pivot to snap the pivot back to CoM.

**Animation**
- Easing type: linear, ease-in, ease-out, ease-in-out, spring, custom curve
- Duration and delay (ms)
- Add keyframe button per property

---

### Layer Panel

The left panel lists all objects in the document as a layer stack with optional nesting.

- Drag to reorder.
- Click the visibility eye to show/hide. `Alt`-click to solo that layer.
- Click the lock icon to lock. Locked layers block selection but render.
- Each layer has a color dot for quick identification (click to change).
- Layers can be grouped (`Cmd/Ctrl+G`). Groups are collapsible.
- **Symbol layers** show a symbol icon. Double-click to enter the symbol's own timeline.
- Rename by double-clicking the layer name.
- `Cmd/Ctrl+L` creates a new layer above the current.
- **Guide layers:** designate any layer as a guide layer (non-printing reference, like Illustrator guide layers and Flash guide/motion-path layers).

---

### Symbol System — from Flash MovieClips

Flash's MovieClip concept was the single most powerful feature in its animation toolset. Vectra adopts it fully.

#### What is a Symbol?
A symbol is a reusable piece of artwork stored once in the **Symbol Library** and placed on the canvas as lightweight instances. Every instance can have independent transform, color tint, opacity, and loop settings — but shares the same source artwork.

#### Symbol types
| Type | Description |
|---|---|
| **Graphic** | Static or animated artwork. Animation plays relative to parent timeline — no independent playback control. Same as Flash Graphic symbol. |
| **MovieClip** | Has its own independent timeline. Plays regardless of where the parent playhead is. Can be nested inside other MovieClips. |
| **Button** | Three-state symbol: Normal / Hover / Pressed. Exported as interactive SVG or Lottie with interactive states. |

#### Creating a symbol
- Select objects → `F8` (or Object > Convert to Symbol).
- Name the symbol, choose type, set registration point (pivot origin).
- The original objects are replaced by an instance of the new symbol.

#### Symbol Library panel
- Lists all symbols in the document with a thumbnail preview.
- Drag a symbol from the library onto the canvas to place a new instance.
- Double-click to edit in place (enters isolation mode; all instances update).
- Duplicate symbol: creates a copy of the symbol for variation without breaking the original.

#### Swapping symbols
- Select an instance → Properties panel → **Swap Symbol** → pick a replacement from the library. The new symbol inherits the same transform and keyframe data as the old one. Identical to Flash's swap symbol workflow, essential for character animation rigs.

#### Color tint and alpha per instance
Each instance can be tinted (blend its artwork toward a solid color by a percentage) or have its alpha overridden independently of the source symbol — Flash's Color Effect panel, which Figma and Rive still lack.

---

### Animation Timeline — Flash-inspired

The timeline lives at the bottom of the workspace and is always visible.

#### Frame model
- Time is represented as **frames** at a user-set FPS (default 24fps, options: 12, 24, 30, 60).
- **Frames**, **keyframes**, and **blank keyframes** are the three cell types — identical to Flash:
  - **Frame** (grey): continuation of the preceding keyframe's state.
  - **Keyframe** (filled circle): a point where properties can change.
  - **Blank keyframe** (empty circle): layer is empty/invisible at this frame.
- Click any frame cell to set the playhead. Right-click → Insert Keyframe / Insert Blank Keyframe / Clear Keyframe.

#### Tween types
| Type | Description |
|---|---|
| **Motion tween** | Interpolates position, scale, rotation, opacity, color tint between keyframes. The tween span is a single object on the timeline. Click the span to select all tweened properties. |
| **Shape tween** | Morphs the path nodes of two different shapes between keyframes. Supports shape hints (see below). |
| **Classic tween** | (advanced) Frame-by-frame control with per-frame easing overrides. |

Apply a tween: right-click between two keyframes on a layer → **Create Motion Tween** or **Create Shape Tween**.

#### Shape hints — from Flash
When two shapes have the same number of nodes, shape tweens interpolate automatically. For shapes with different topology:
- Object > Add Shape Hints (`Cmd/Ctrl+Shift+H`)
- Labeled markers (a, b, c…) appear on the start shape; place matching markers on the end shape.
- Hints guide the interpolation to produce clean morphs rather than tangled crossovers.
- Remove all hints: Object > Remove All Hints.

#### Onion skinning — from Flash
Show semi-transparent ghost frames before and/or after the current frame so you can see motion arcs and overlap during animation.

- Toggle: the onion-skin button in the timeline toolbar (or `Alt+O`).
- Onion range: drag the onion-skin start/end markers on the frame ruler.
- Before frames: dimmed in blue. After frames: dimmed in green.
- **Onion outlines mode:** shows only stroked outlines for the ghost frames, reducing visual noise.
- Onion skinning works in both the main timeline and inside symbols.

#### Motion path — from Flash guide layers
Instead of interpolating position linearly between two keyframes, an object can follow a drawn path.

- Draw any open path on a **guide layer**.
- Right-click the layer directly above the guide layer → **Attach to Motion Path**.
- The attached layer's position now follows the guide path over the tween duration.
- Orient to path toggle: the object rotates to match the path tangent as it moves.
- Ease along path: applies the tween easing to the distance along the path (not X/Y independently).

#### Per-property easing curves — from Flash Motion Editor
Each tweened property has its own easing curve, editable in the **Motion Editor** panel (expand from the timeline footer).

- Rows: X position, Y position, Scale X, Scale Y, Rotation, Opacity, Tint.
- Each row shows a Bézier curve editor spanning the tween duration.
- Click a curve point to drag its handles. `Alt`-click to add a new control point.
- Preset curves: linear, ease-in, ease-out, ease-in-out, bounce, elastic, spring.
- Curves can be copied between property rows.
- *This is the feature that separates professional motion work from mechanical tweens.*

#### Playback controls
- Play / Pause (`Space`).
- Step forward / back one frame (`< >`).
- Scrub by dragging the playhead.
- Set in / out points by dragging the work area bar ends.
- Loop toggle: loop / play once / ping-pong.
- Playback speed: 0.25×, 0.5×, 1×, 2×.
- FPS display shows actual render FPS in real time.

#### Stagger
Select multiple layers → Timeline > Stagger. Enter an offset in frames. Identical animations cascade across objects automatically, offset by the specified amount.

#### Named frame markers — from Flash frame labels
Right-click any keyframe → **Add Frame Label**. Labels appear as small flags above the frame.
- Used as named states for the interactive state machine (v2.0).
- Exported into Lottie JSON as named markers, readable by the Lottie runtime's `goToAndPlay('idle')` API on any target platform.

#### Scene panel — from Flash
For longer productions, the animation can be divided into **Scenes** (discrete timeline segments).
- Each scene has its own timeline and layer stack.
- Scenes play back sequentially in export.
- Switch scenes via the Scene panel or the scene selector dropdown above the timeline.
- Useful for multi-state Lottie animations (idle → loading → success).

#### Duration
- Default: 3 seconds at 24fps = 72 frames.
- Drag the end of the work area bar or type a frame/second duration.
- Maximum: 1800 frames (60 seconds at 30fps) in v1.

---

### Frame-by-Frame Animation — from Flash

For character animation and hand-crafted motion:

- Insert a **blank keyframe** on each frame and draw a new shape in each one.
- Onion skinning shows the preceding and following frames as guides.
- **Light table mode:** onion frames rendered at higher opacity, for traditional animation tracing workflow.
- Frame-by-frame layers can be mixed freely with tween layers in the same document.

---

### Canvas

- Infinite canvas with pan (`Space`+drag or middle-click drag) and zoom (`Cmd/Ctrl+scroll`, `Cmd/Ctrl++/-`).
- **Stage** (the defined document rectangle, Flash terminology) is shown as a white rectangle with a soft drop shadow. Objects outside the stage render on canvas but are cropped in export.
- Grid and ruler toggles. Snapping to grid, objects, pixel grid, and guide lines.
- Guides: drag from ruler to place. `Cmd/Ctrl+;` to show/hide. Double-click a guide to enter precise position. `Cmd/Ctrl+Alt+;` to lock guides.
- Pixel grid mode: snaps to integer coordinates for crisp raster exports.
- Background color selector. Transparent background for SVG export.
- **Multiple artboards** (v1.1): multiple stage rectangles in one document, each with independent export settings.

---

### Export

| Format | Notes |
|---|---|
| SVG | Static. Inline or external file. Optional minification. |
| Animated SVG | Uses CSS animations. Self-contained. |
| Lottie JSON | For use on iOS, Android, Web (lottie-web), React Native, Flutter. Named markers preserved. |
| MP4 | Frame-rendered at 60fps via an embedded Flutter isolate renderer. Up to 1920×1080. |
| PNG / PNG sequence | Static or per-frame export. |
| GIF | Palette-quantized, up to 30fps. Suitable for social and messaging. |
| SWF | No. Never. |

Export dialog shows a live preview at actual size before downloading.
**Per-artboard export** (v1.1): export all artboards as a ZIP of individual files in one click.

---

## What Is Intentionally Cut (v1)

The following are excluded from v1 to maintain focus. Candidates for future versions based on usage data.

- Gradients (linear, radial, mesh) — v1.2
- Pattern fills
- Blend objects (Illustrator Object > Blend)
- 3D perspective
- Multiple artboards — v1.1
- CMYK and print color modes
- Plugins and scripting
- Variable fonts
- Pressure-sensitive drawing
- Graph tool
- Expression-based / code-driven animation
- Inverse kinematics / bone tool — considered for v2.0
- Particle effects

---

## Technical Architecture

### Stack

| Layer | Technology |
|---|---|
| Platform | Flutter (macOS, Windows, Linux, iOS, Android, Web) |
| Renderer | Flutter `CustomPainter` on a `Canvas` with `dart:ui` path primitives |
| Vector math | Pure Dart Bézier library (no FFI required) |
| State management | Riverpod + immutable document model via `freezed` |
| Animation engine | Custom frame-based keyframe interpolator in Dart; per-property Bézier easing curves |
| Symbol runtime | Nested timeline evaluator; instances resolved at paint time |
| File format | `.vct` — JSON-based, versioned, human-readable |
| Export (Lottie/SVG/GIF) | On-device Dart codegen — no server round-trip |
| Export (MP4) | Off-screen Flutter `RenderRepaintBoundary` frame capture → FFmpeg via platform channel |

### Center of Mass Computation

Every shape stores a cached `centerOfMass` point that is recomputed whenever the path geometry changes. The pivot defaults to this point and all transform operations (rotate, scale, skew) use it unless the user overrides it.

| Shape type | CoM algorithm |
|---|---|
| Filled closed path | Area centroid via the shoelace formula applied to the flattened polygon (cubic Béziers subdivided to tolerance). |
| Open stroke path | Arc-length centroid — the midpoint along the total path length, weighted by segment length. |
| Compound path (holes) | Signed-area shoelace across all sub-paths; counter-clockwise sub-paths (holes) subtract their area from the sum. |
| Group / symbol instance | Area-weighted average of all children's CoM points. |
| Text (live) | Bounding-box center (text layout centroid is deferred until path conversion). |

The CoM is stored in the shape's local coordinate space and transformed with the object. It is serialized into the `.vct` file so it does not need to be recomputed on load.

### File Format (`.vct`)

JSON document model with four top-level sections:
- `meta`: version, fps, stage dimensions, background color
- `symbols`: symbol library; each symbol contains its own layer/timeline tree
- `scenes`: array of scenes; each scene contains a layer stack referencing symbol instances and raw paths
- `assets`: embedded or referenced image/font assets

### Performance Targets

- Canvas renders at 60fps for documents with up to 500 paths and 20 nested symbol instances.
- Playback at 60fps for animations up to 1800 frames.
- Export to SVG/Lottie in under 500ms for typical documents.
- Cold start (blank canvas visible) in under 1.5 seconds.

---

## Keyboard Shortcuts

| Action | Mac | Windows/Linux |
|---|---|---|
| Select tool | `V` | `V` |
| Direct Select (node edit) | `A` | `A` |
| Free Transform | `Q` | `Q` |
| Pen tool | `P` | `P` |
| Width tool | `W` | `W` |
| Pencil / Blob Brush | `B` | `B` |
| Rectangle | `R` | `R` |
| Ellipse | `E` | `E` |
| Polygon / Star | `Y` | `Y` |
| Text | `T` | `T` |
| Play / pause | `Space` | `Space` |
| Step forward 1 frame | `.` | `.` |
| Step back 1 frame | `,` | `,` |
| Insert keyframe | `F6` | `F6` |
| Insert blank keyframe | `F7` | `F7` |
| Clear keyframe | `Shift+F6` | `Shift+F6` |
| Add shape hint | `Cmd+Shift+H` | `Ctrl+Shift+H` |
| Convert to symbol | `F8` | `F8` |
| Enter symbol (isolation) | double-click | double-click |
| Exit isolation / Esc | `Esc` | `Esc` |
| Toggle onion skin | `Alt+O` | `Alt+O` |
| Snap pivot to CoM | `Cmd+Shift+M` | `Ctrl+Shift+M` |
| Make clipping mask | `Cmd+7` | `Ctrl+7` |
| Release clipping mask | `Cmd+Alt+7` | `Ctrl+Alt+7` |
| Unite (Pathfinder) | `Cmd+Shift+U` | `Ctrl+Shift+U` |
| Minus Front (Pathfinder) | `Cmd+Shift+M` | `Ctrl+Shift+M` |
| Group | `Cmd+G` | `Ctrl+G` |
| Ungroup | `Cmd+Shift+G` | `Ctrl+Shift+G` |
| Transform again | `Cmd+D` | `Ctrl+D` |
| Undo | `Cmd+Z` | `Ctrl+Z` |
| Redo | `Cmd+Shift+Z` | `Ctrl+Shift+Z` |
| Zoom in | `Cmd++` | `Ctrl++` |
| Zoom out | `Cmd+-` | `Ctrl+-` |
| Fit stage to window | `Cmd+0` | `Ctrl+0` |
| Fit all to window | `Cmd+Shift+0` | `Ctrl+Shift+0` |
| Export | `Cmd+Shift+E` | `Ctrl+Shift+E` |

---

## Roadmap

### v1.0 — Core
Five drawing tools + width tool, pathfinder, appearance panel, align panel, clipping masks, symbol library (MovieClip + Graphic), flat layer panel, Flash-style frame timeline with motion tweens + shape tweens + shape hints, onion skinning, motion path, per-property easing curves, named frame markers, SVG + Lottie export, `.vct` file format, local autosave.

### v1.1 — Collaboration & Artboards
Multiple artboards, cloud sync, share-by-link (view only), comments on layers, version history, per-artboard export.

### v1.2 — Gradients & Effects
Linear/radial gradients in the Appearance panel, drop shadow, Gaussian blur (static export only). Button symbols with interactive SVG hover/click states.

### v1.3 — Components & Scenes
Scene panel for multi-section animations. Reusable component overrides. Component instances share a master animation. Lottie marker-driven scene transitions.

### v2.0 — Interactive Animation & IK
State machine for interactive SVG (hover, click, scroll-triggered states), driven by named frame markers. Inverse kinematics / bone tool for character rigs. Expression-based animation properties.

---

## Competitive Positioning

| | Vectra | Illustrator | Figma | Rive | Flash (legacy) |
|---|---|---|---|---|---|
| Vector drawing | ✓ | ✓✓ | ✓ | ✓ | ✓ |
| Pathfinder / boolean ops | ✓ | ✓✓ | ✗ | ✗ | ✗ |
| Variable width stroke | ✓ | ✓✓ | ✗ | ✗ | ✗ |
| Appearance / multi-fill | ✓ | ✓✓ | ✗ | ✗ | ✗ |
| Frame-based timeline | ✓ | — | ✗ | ✗ | ✓✓ |
| Symbol / MovieClip system | ✓ | ✗ | ✗ (components only) | ✓ | ✓✓ |
| Shape tweens + hints | ✓ | — | ✗ | partial | ✓✓ |
| Onion skinning | ✓ | — | ✗ | ✗ | ✓✓ |
| Motion path | ✓ | — | ✗ | ✗ | ✓✓ |
| Per-property easing curves | ✓ | — | ✗ | ✓ | ✓ |
| Cross-platform native | ✓ (Flutter) | ✗ (desktop only) | ✓ (web + desktop) | ✓ (web + desktop) | ✗ (desktop only) |
| Lottie export | ✓ | plugin | plugin | ✓ | ✗ |
| Learning curve | Medium | High | Medium | Medium | Medium |
| Focus | Draw + animate | Draw only | UI/prototype | Interactive | Draw + animate |

---

## Open Questions

1. **Pen default behavior:** auto-smooth (Figma-style) or corner-first (Illustrator-style)? Default to Illustrator for illustrator-segment users; consider a preference toggle.
2. **Monetization:** subscription (like Adobe), one-time (like Sketch), or freemium with export limits?
3. **Renderer ceiling:** at what document complexity does `CustomPainter` need to hand off to a Flutter GPU fragment shader (`FragmentProgram`) for the renderer?
5. **Shape morphing without matching node counts:** auto-subdivide paths to match count before applying a shape tween, or require manual shape hints?
6. **FPS options:** should the timeline default to frames or seconds? Flash defaulted to frames; most modern tools use seconds. Offer both with a toggle.
7. **Symbol nesting depth:** unlimited nesting (like Flash) risks accidental infinite loops. Cap at 8 levels deep in v1?
8. **GIF export quality:** palette quantization is lossy. Position GIF as legacy/sharing only; push animated SVG as the modern alternative.

---

*Vectra concept · March 2026 · v0.2*
