<!-- tradingview-pine-id: PUB;b74c60bcf67b45ac86446dbea2462763 -->
<!-- tradingviewscripts-format: 1 -->
# Elliott Impulse Engine [WillyAlgoTrader]

Source: https://www.tradingview.com/script/eQPdoeM6-Elliott-Impulse-Engine-WillyAlgoTrader/

## Description

📊 Elliott Impulse Engine (EIE) is an overlay indicator that counts a full Elliott cycle — impulse 0-1-2-3-4-5 plus correction A-B-C — completely automatically, using a Change-of-Character (CHoCH) trigger to start each count, a strict state machine to accept every wave point, Fibonacci target boxes to show where the next point is expected, a dashed "ghost" projection of the entire remaining path, and a trailing red invalidation line that tells you the exact price where the current count dies.

The core insight: most Elliott Wave tools either repaint their labels endlessly or force you to draw everything by hand. EIE does neither. It treats every count as a hypothesis: a CHoCH break seeds it, each confirmed pivot advances it one wave at a time, and a single hard price level can kill it. When the hypothesis dies, the chart is wiped clean and the engine waits for the next CHoCH — no stale labels, no silent redrawing of history. You always know three things at a glance: what wave the market is in, where price should go next, and where the idea is wrong.

Works on any symbol and any timeframe. Free and open for everyone.

🧩 WHY THESE COMPONENTS WORK TOGETHER

A ZigZag alone gives you swings but no wave logic. A Fibonacci tool alone gives you levels but no structure. A CHoCH detector alone tells you the trend flipped but not what comes next. And a manual Elliott count gives you structure but demands hours of drawing and constant re-labeling.

EIE chains all of these into one pipeline:

Swing structure engine → CHoCH detection → count seeding (point 0 + point 1) → fib grid on leg 0-1 → target boxes for points 2/3/4 → pivot-based point acceptance with soft-marking → ghost projection of the remaining path → trailing invalidation level → reset with a stated reason

The swing engine finds structural highs and lows. A confirmed close through a swing level against the previous trend is a CHoCH — the only event allowed to start a new count, so counts always begin at genuine structure shifts, not random noise. The moment leg 0-1 is confirmed, the engine builds a Fibonacci grid on that leg and projects the whole expected structure forward as a dashed ghost path. Each subsequent wave point is accepted from a separate, faster pivot stream, checked against its expected fib range, and either labeled clean ("2") or soft-marked ("2~") if it landed outside the range. At every state the engine maintains exactly one critical price — the trailing invalidation level — and if price breaks it, the count is declared dead with an explicit reason (BELOW_0, BELOW_W2, W3_SHORTEST, and so on), the markup is wiped, and the engine returns to scanning.

No single public tool does this loop. The combination turns Elliott counting from a subjective drawing exercise into a rule-driven process you can watch unfold bar by bar.

🔍 WHAT MAKES IT ORIGINAL

1️⃣ CHoCH-seeded counting — every count starts at a real structure break.

The engine tracks swing highs and lows using symmetric pivots (default 10 bars left / 10 bars right). A break is registered only on a confirmed bar close through the swing level. If that break goes against the current internal trend, it is a CHoCH — and only then does the engine arm a new count: point 0 is set to the extreme of the run that preceded the break, and the engine waits for a with-trend pivot beyond the CHoCH level to lock point 1.

Anti-noise guards built into the seeding:
 — a warm-up gate (no CHoCH before max(3 × swing length, 50) bars of history),
 — an optional cooldown (N bars after any count ends before a new CHoCH may seed),
 — a level lock: after an invalidation, the same CHoCH level cannot immediately re-seed a new count (compared with half-a-tick tolerance, so floating-point equality can never leak a duplicate seed).

Why this matters: counts started from random pivots produce random labels. Counts started from structure breaks start where trend logic actually changed.

2️⃣ Non-blocking Fibonacci ranges with soft-marking — geometry informs, price decides.

Each wave point has an expected fib range measured on the 0→1 grid (retracement for 2, negative extension beyond point 1 for 3, 5 and B; point 4 uses its own 2→3 grid; C uses 0→1 again):

 — Point 2: 0.5 – 0.705 (retracement of 0→1)
 — Point 3: −0.5 – −0.618 (extension beyond point 1)
 — Point 4: 0.5 – 0.705 (retracement of leg 2→3)
 — Point 5: −0.618 – −1.0
 — Point B: −0.5 – −0.618
 — Point C: 0.0 – 0.236

The fib level of any price p on the 0→1 grid is computed as L = (p1 − p) / (p1 − p0); on the 2→3 grid as F = (p3 − p) / (p3 − p2). A pivot inside its range is labeled clean ("3"); a pivot outside it is still accepted but soft-marked ("3~") — because in real markets a valid wave frequently overshoots textbook levels. Only the hard invalidation rules can reject a point. Every range is a user input (min/max per point), so you can tighten or widen the geometry to your market.

Why this matters: strict-range engines discard perfectly good structure; free-form engines accept garbage. Soft-marking keeps the count honest while telling you visually which points are textbook and which are stretched.

3️⃣ Ghost projection — the whole remaining path drawn before it happens.

As soon as leg 0-1 is confirmed, EIE draws a dashed projection of every remaining point: 2? 3? 4? 5? A? B? C?. Each ghost point is placed inside its fib range at a position you choose (Middle of the range, Near edge, or Far edge), and spaced horizontally at step = round((b1 − b0) × coefficient) bars — i.e., the time geometry of the projection scales with the actual duration of leg 0-1. Ghost point 5? sits at extension −1.0 plus a configurable offset.

The projection is re-anchored from every newly accepted real point: once point 2 locks, the ghost path redraws starting from the real 2; once point 3 locks, from the real 3, and so on. Point 4's ghost is computed on the 2→3 grid using the best available references (real points when confirmed, ghost estimates before that).

Why this matters: you see the expected shape of the entire move — including the A-B-C correction after the impulse — while the impulse is still in wave 2.

4️⃣ Trailing invalidation level — one red line that answers "where am I wrong?".

At every state the engine maintains exactly one critical level, drawn as a dashed red line with an "INVALID + price" label:

 — waiting for 1 / wave 2 in progress: point 0
 — wave 3 before point 1 is broken: point 0; after the break: point 2
 — wave 4: point 2
 — wave 5 before point 3 is broken: point 2; after the break: point 4
 — correction A/B/C: point 2

A break of this level resets the hypothesis with a named reason. The check runs every bar, before pivot processing, so a violent bar cannot both break the invalidation level and sneak a new wave point into the count on the same bar. Wick-driven pivots that slip past a close-based check are caught by a second, pivot-level guard (a pivot beyond point 2 / point 4 in the protected phases also triggers the reset). Classic Elliott rules are enforced on top: wave 2 may never retrace below point 0, wave 4 may never enter below point 2, and if wave 3 turns out shortest among 1, 3 and 5 at the moment point 5 is proposed, the count is rejected with reason W3_SHORTEST.

Why this matters: an Elliott count without a falsification level is a story, not a hypothesis. EIE makes the falsification price explicit on every bar.

5️⃣ Two-speed pivot system — stable structure, fast confirmation.

Structure and CHoCH run on the main swing length (default 10/10). Wave points 1-5 and A-C are accepted from a separate, shorter pivot stream (default 5/5, always ≤ swing length — validated at load). This decouples two jobs that a single pivot length cannot do well simultaneously: the long pivots keep the structural skeleton stable, the short pivots confirm wave points with roughly half the lag.

A dedicated backfill scan (up to ~480 bars) closes the pivot-lag gap for point 2: when point 1 locks or repositions, the engine re-scans all bars since point 1 for the true retracement extreme, so the best low/high inside the confirmation window is never missed. If price breaks point 1 before any counter-trend pivot confirmed point 2, the tracked extreme itself is accepted as point 2 and wave 3 is activated immediately.

Why this matters: one pivot length forces a trade-off between stability and speed. Two lengths plus a backfill scan give you both.

6️⃣ Repositioning logic — labels refine forward, never silently rewrite history.

Until the next wave locks, the engine allows controlled repositioning: a higher high repositions point 1 (rebuilding the grid and the point-2 box on the new geometry), a deeper pullback repositions point 2 (only until point 1 is broken — after the break, a deeper pivot is an invalidation, not a reposition), point 3 extends while wave 4 forms, point 4 deepens until point 3 is broken, point 5 extends during the correction, A deepens until B appears, B rises until C appears. Every reposition deletes and redraws only the affected segment and label, and the associated target box and its center line are rebuilt on the fresh grid — no stale geometry is left behind.

Why this matters: this is the honest middle ground between "repaints everything" and "freezes wrong labels forever". The rules for what may move, and until when, are fixed and stated.

7️⃣ OTE target boxes for points 2, 3 and 4 — the next objective is always a zone, not a guess.

When point 1 locks, a yellow box covering the point-2 fib range appears with a dashed center line at the range midpoint. When point 2 locks, the point-3 target box (on the extension side) appears. When point 3 locks, the point-4 box appears on the 2→3 grid. Each box extends forward a configurable number of bars (default 20) and its right edge snaps to the bar where the point actually forms. Box fill transparency adapts to the theme (65 dark / 55 light); the border and center line stay fully opaque.

Why this matters: "wave 4 should come" is vague. "Wave 4 is expected inside this drawn box, centered here" is actionable.

8️⃣ Explicit reset reasons + persistent CHoCH history — the chart tells you why.

Every count ends with a machine reason: FALSE_CHOCH (price broke back through point 0 before point 1 formed), BELOW_0, BELOW_W2, BELOW_W4, W3_SHORTEST, DEEP_C (correction retraced beyond point 2), TIMEOUT (optional: state lasted longer than k × leg 0-1 duration), B_ABOVE_5 (the "correction" broke above point 5 — the impulse is closed as done), or DONE (point C accepted, full cycle complete). On invalidation a ✖ marker with the reason in its tooltip is placed on the bar, and the dashboard keeps showing the last reason.

The active markup is wiped on reset — but CHoCH lines and labels live on a separate persistent layer (FIFO history, up to 100, default 50). When price later closes back through a CHoCH level, that line is clipped to the mitigation bar and turns dotted. So your chart accumulates a clean structural map of every trend change while dead counts disappear.

A special same-bar case is handled explicitly: if a reset and a fresh opposite CHoCH land on the same bar (with cooldown off), the engine wipes first, then seeds the new count on that same bar — the new hypothesis is never lost to ordering.

Why this matters: most auto-counters just vanish or redraw without explanation. EIE always states its reason, and the CHoCH map survives as context.

9️⃣ Anti-repaint discipline — confirmed pivots, close-confirmed breaks, honest Wick mode.

Three independent mechanisms:
 — All pivot values are consumed only on confirmed bars: a forming real-time bar can make a pivot flicker, so transient pivot values are masked out and can never trigger an irreversible state transition. Historical bars are unaffected (they are all confirmed).
 — In the default Close confirmation mode, invalidation breaks and wave-top breaks are evaluated only on the confirmed bar close — an intrabar excursion of the close cannot fire a reset that "un-happens" seconds later.
 — The optional Wick mode reacts to any intrabar touch — faster, and by design irreversible within the bar. This is stated openly so you can choose speed vs. strictness.

Zone-entry events (price entering the point-2 OTE zone, the point-4 box, or tagging the −1.0 target) intentionally use wick extremes — a touch is a touch — and are one-way flags.

🔟 Theme-adaptive visual system with auto-contrast labels.

Theme is Auto-detected from the chart background (or forced Dark/Light). By default, long counts use a theme-adaptive green (dark green on light charts, bright green on dark charts) and short counts use red. If you enable custom colors, label text color is derived from the luminance of your chosen background — luma = 0.299R + 0.587G + 0.114B, threshold 140 — so digits stay readable on any shade you pick. The fib grid uses role-based color inputs (red 0.236, teal 0.705 OTE, blue retracement levels, gray round levels), all editable. Label font size is selectable from Tiny to Huge.

⚡ HOW IT WORKS — CALCULATION FLOW

Step 1 — Structure scan: Symmetric pivots (default 10/10) maintain the latest swing high and swing low; the engine also tracks the running extreme since the last swing (the future point 0).

Step 2 — CHoCH: A confirmed close through a swing level against the internal trend flips the trend and — if the engine is idle, cooled down, and the level is not locked — seeds a count: direction, CHoCH level, point 0.

Step 3 — Point 1: The first fast pivot beyond the CHoCH level becomes point 1. The 0→1 fib grid, the point-2 target box, and the full ghost projection are drawn.

Step 4 — Impulse counting: Fast counter-trend pivots propose points 2 and 4; fast with-trend pivots propose 3 and 5. Each is checked against its fib range (clean or "~"), each unlocks the next state, target boxes appear for the next objective, and the ghost path re-anchors from every real point.

Step 5 — Hard rules per bar: Before any pivot is processed, the trailing invalidation level is checked (Close or Wick mode). Wave 2 below point 0, wave 4 below point 2, a broken point 4 in late wave 5, or a shortest wave 3 all kill the count with a named reason.

Step 6 — Impulse complete: Point 5 accepted → the impulse counter increments and the engine rolls into correction tracking.

Step 7 — Correction A-B-C: A forms on a counter-trend pivot, B on a with-trend pivot (a B at or beyond point 5 closes the whole structure as B_ABOVE_5 instead), C completes the cycle → DONE.

Step 8 — Reset: On any ending — invalidation or completion — the active markup is wiped, the cooldown starts, and the engine returns to scanning. CHoCH history stays.

📖 HOW TO USE

🎯 Quick start (works even if you have never counted a wave):
 1. Add the indicator to a clean chart. Nothing to configure — defaults are ready to use.
 2. Wait for a CHoCH label. That is the engine saying: "the trend character just changed, I am watching for a new impulse here."
 3. When labels 0 and 1 appear, the count is live. The dashed gray path with 2? 3? 4? 5? A? B? C? is the expected roadmap of the entire move.
 4. Watch the yellow box — that is where the next wave point is expected. The dashed line inside it is the center of the zone.
 5. Keep one eye on the red dashed INVALID line at all times. If price breaks it, the count is over — a ✖ appears, the markup clears, and the engine starts hunting for the next CHoCH. Hover the ✖ to read the exact reason.

👁️ Reading the chart:
 — 🟢 Green numbered labels (0, 1, 2, 3, 4, 5) = accepted impulse points of a long count; red labels = a short count. Letters A, B, C = the correction.
 — A label with ~ (like "2~") = the point is accepted, but it landed outside its textbook fib range — the count continues, treat it with slightly more caution.
 — Solid colored path = confirmed structure. Dashed gray path with "?" labels = the ghost projection of what is still expected.
 — 🟡 Yellow boxes = target zones for points 2, 3 and 4, each with a dashed center line.
 — Dotted horizontal grid = the Fibonacci grid of leg 0-1 (retracements 0.236…1.0 above, extensions −0.5 / −0.618 / −1.0 below), each level labeled with its ratio and price.
 — 🔴 Red dashed line + "INVALID price" = the trailing invalidation level of the current count.
 — Dashed horizontal CHoCH lines = historical structure breaks; a line that turns dotted has been mitigated (price closed back through it).
 — ✖ = the count was invalidated on this bar (reason in the tooltip).

📊 Dashboard fields:
 — State: current phase (Scanning / CHoCH · wait 1 / Wave 2…5 / Corr · A-B-C).
 — Direction: Long, Short, or — when idle.
 — Invalidation: the current critical price.
 — Last Reset: why the previous count ended (reason, DONE, or B_ABOVE_5). Resets on chart reload.
 — Impulses: completed 5-wave impulses on the loaded history. Resets on chart reload.
 — TF: chart timeframe. Version: engine version.

🔧 Tuning guide:
 — Counts appear too rarely: lower Swing Detection Length (structure forms faster, more CHoCH seeds) — or the market is simply ranging without character changes.
 — Too many counts die instantly (FALSE_CHOCH / BELOW_0): raise Swing Detection Length, or add a Cooldown of 5-20 bars so the engine skips the chop right after a failed count.
 — Points confirm too slowly: lower Point Confirmation (min 1); remember it must stay ≤ Swing Detection Length.
 — Too many "~" soft marks: widen the fib ranges for those points — your market may simply run hotter than the defaults.
 — Old counts hang around in dead phases: set Timeout k > 0 (e.g. 3.0) — any state lasting longer than k × the duration of leg 0-1 resets automatically.
 — Chart feels crowded: toggle off the Fib Grid, OTE Boxes, or the Projection independently; reduce Historical CHoCH; shrink label font size.

⚙️ KEY SETTINGS

⚙️ Main Settings:
 — Swing Detection Length (default 10): pivot length for structure and CHoCH. Higher = larger structure, fewer seeds.
 — Point Confirmation, bars (default 5): the separate short pivot used to accept wave points. Must be ≤ swing length (validated).
 — Breaks: Invalidation Mode (default Close): Close = confirmed bar close beyond the level (non-repainting); Wick = any intrabar touch (instant, irreversible within the bar).

📐 Point Ranges (fib): min/max expectation range per point — Point 2 (0.5–0.705), Point 3 (−0.5…−0.618), Point 4 (0.5–0.705 on the 2→3 grid), Point 5 (−0.618…−1.0), Point B (−0.5…−0.618), Point C (0–0.236). All validated at load (2 and 4 must be inside (0,1); 3, 5, B must be negative; C inside [0,1); no zero-width ranges).

👻 Ghost Projection:
 — Show Projection (on), Point Inside Range (Middle / Near / Far), Time Step Coef (default 1.0 × leg 0-1 duration), 5?: Offset From −1.0 (default 0.05).

♻️ Reset:
 — Cooldown After Reset, bars (default 0 = off) and Timeout, k × leg 0-1 (default 0 = off; in the wait-for-1 phase the timeout scales on swing length instead, since no leg exists yet).

🎨 Visual Settings: Theme (Auto / Dark / Light), Fib Grid toggle, OTE Boxes toggle, CHoCH layer toggle, Path Width (2), Box Length Forward (20), Historical CHoCH max (50), Label Font Size (Tiny…Huge), Watermark toggle.

📏 Grid Levels: individual on/off for 0.236, 0.382, 0.5, 0.618, 0.705, 0.786, 0.886, 1.0, −0.5, −0.618, −1.0.

🎨 Colors: Use Custom Colors switch (off = theme-adaptive defaults), long/short point label backgrounds (text auto-contrasts), target box color, path and ghost colors, bull/bear CHoCH colors, and role-based fib grid colors.

📊 Dashboard: on/off, position (5 anchors), font size (the version row renders one step smaller).

🔔 ALERTS

Ten alert conditions covering the full lifecycle:

 — 🟢 1. CHoCH + projection — CHoCH confirmed, movement projection built
 — 🟡 2. Price in W2 OTE — price entered the point-2 zone
 — 🟢 3. Point 2 accepted
 — 🟢 4. Break of point 1 — wave 3 active
 — 🟡 5. Price in W4 box
 — 🟢 6. Break of point 3 — wave 5 active
 — 🎯 7. Target −1.0 reached
 — 🟢 8. Impulse complete — point 5 locked
 — 🎯 9. Target C — correction complete, full cycle done
 — 🔴 10. Invalidation — hypothesis reset

In addition, the engine fires dynamic alert() messages on every reset and on B_ABOVE_5 completion, including the reason text. In Close mode these announce on confirmed bar close; in Wick mode once per bar.

⚠️ IMPORTANT NOTES

 — 🚫 No repainting of confirmed structure. Pivots use equal left/right lookback and their values are consumed only on confirmed bars; CHoCH breaks require a confirmed close; in the default Close mode, invalidation and wave-top breaks are evaluated on confirmed closes only. A pivot is, by nature, confirmed N bars after the actual extreme — the indicator draws from the confirmed bar backward to the true swing point. This is delayed confirmation, not repainting of settled values.
 — 📐 Controlled repositioning is part of the design. Until the next wave locks, the latest point may legitimately move to a more extreme pivot (e.g., point 1 to a higher high). The rules for what may move, and until when, are fixed and described above. Wick mode reacts intrabar by design and is irreversible within the bar.
 — 📊 The Impulses counter and Last Reset field are computed on loaded chart history and reset when the chart reloads.
 — ⚖️ EIE counts one impulse degree at a time from the latest CHoCH. It does not label nested sub-waves, diagonals, or complex W-X-Y corrections — it is a focused impulse + zigzag engine, and the fib ranges reflect one practical interpretation of Elliott guidelines, which you can re-tune.
 — 🛠️ This is a wave-counting and projection tool, not an automated trading system. It identifies structure, projects expected zones, and shows the invalidation price — trade decisions remain yours.
 — 🌐 Works on all markets (crypto, forex, stocks, indices, commodities) and all timeframes.

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════
// ELLIOTT IMPULSE ENGINE [WillyAlgoTrader]
// ══════════════════════════════════════════════════════════
// Author:  Willy | WillyAlgoTrader
// Version: 0.9.0-dev
// ══════════════════════════════════════════════════════════

indicator("Elliott Impulse Engine [WillyAlgoTrader]", "EIE", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 100, max_bars_back = 500)

// ══════════════════════════════════════
// CONSTANTS
// ══════════════════════════════════════
INDICATOR_VERSION = "v0.9.0-dev"

GRP_MAIN   = "⚙️ Main Settings"
GRP_FIB    = "📐 Point Ranges (fib)"
GRP_GHOST  = "👻 Ghost Projection"
GRP_RESET  = "♻️ Reset"
GRP_VISUAL = "🎨 Visual Settings"
GRP_GRID   = "📏 Grid Levels 0→1"
GRP_COLORS = "🎨 Colors"
GRP_DASH   = "📊 Dashboard"

// State machine
S_SCAN  = 0
S_CHOCH = 1
S_W2    = 2
S_W3    = 3
S_W4    = 4
S_W5    = 5
S_A     = 6
S_B     = 7
S_C     = 8

// ══════════════════════════════════════
// INPUTS
// ══════════════════════════════════════
swingLenInput = input.int(10, "Swing Detection Length", minval = 3, maxval = 50, group = GRP_MAIN,
     tooltip = "Pivot length (bars on each side) for swing structure and CHoCH\n" +
               "detection — Trader Assistant Pro engine.\n" +
               "• Higher = larger structure, fewer CHoCH seeds\n" +
               "• Lower = faster structure, more seeds")
accDepthInput = input.int(5, "Point Confirmation, bars", minval = 1, group = GRP_MAIN,
     tooltip = "Separate (short) pivot period for accepting wave points 1-5/A-C.\n" +
               "CHoCH structure stays on Swing Detection Length.\n" +
               "Must be <= Swing Detection Length")
confModeInput = input.string("Close", "Breaks: Invalidation Mode", options = ["Close", "Wick"], group = GRP_MAIN,
     tooltip = "How invalidation levels and wave-top breaks are confirmed:\n" +
               "• Close: confirmed bar close beyond the level (non-repainting,\n" +
               "  evaluated on bar close only)\n" +
               "• Wick: any intrabar touch beyond the level (fires immediately;\n" +
               "  wick touches are irreversible within the bar)")
confClose = confModeInput == "Close"

r2MinInput = input.float(0.5,    "Point 2  · min", step = 0.001, group = GRP_FIB, inline = "p2",
     tooltip = "Fib retracement range (of leg 0→1) where point 2 is expected.\nOutside the range the point is still accepted with a '~' soft mark")
r2MaxInput = input.float(0.705,  "max",            step = 0.001, group = GRP_FIB, inline = "p2",
     tooltip = "Upper bound of the point 2 expectation range")
r3MinInput = input.float(-0.5,   "Point 3  · min", step = 0.001, group = GRP_FIB, inline = "p3",
     tooltip = "Fib extension range (negative = beyond point 1) where point 3\nis expected. Drawn as a yellow target box after point 2 is\naccepted. Outside = '~' soft mark")
r3MaxInput = input.float(-0.618, "max",            step = 0.001, group = GRP_FIB, inline = "p3",
     tooltip = "Far bound of the point 3 expectation range")
r4MinInput = input.float(0.5,    "Point 4  · min (2→3 grid)", step = 0.001, group = GRP_FIB, inline = "p4",
     tooltip = "Retracement range of leg 2→3 where point 4 is expected.\nOutside = '~' soft mark")
r4MaxInput = input.float(0.705,  "max",            step = 0.001, group = GRP_FIB, inline = "p4",
     tooltip = "Upper bound of the point 4 expectation range")
r5MinInput = input.float(-0.618, "Point 5  · min", step = 0.001, group = GRP_FIB, inline = "p5",
     tooltip = "Fib extension range (of leg 0→1) where point 5 is expected.\nOutside = '~' soft mark")
r5MaxInput = input.float(-1.0,   "max",            step = 0.001, group = GRP_FIB, inline = "p5",
     tooltip = "Far bound of the point 5 expectation range")
rBMinInput = input.float(-0.5,   "Point B  · min", step = 0.001, group = GRP_FIB, inline = "pB",
     tooltip = "Fib extension range (of leg 0→1) where point B is expected.\nOutside = '~' soft mark")
rBMaxInput = input.float(-0.618, "max",            step = 0.001, group = GRP_FIB, inline = "pB",
     tooltip = "Far bound of the point B expectation range")
rCMinInput = input.float(0.0,    "Point C  · min", step = 0.001, group = GRP_FIB, inline = "pC",
     tooltip = "Fib range (of leg 0→1) where point C is expected.\nOutside = '~' soft mark")
rCMaxInput = input.float(0.236,  "max",            step = 0.001, group = GRP_FIB, inline = "pC",
     tooltip = "Upper bound of the point C expectation range")

showGhostInput = input.bool(true, "Show Projection", group = GRP_GHOST,
     tooltip = "Draw the dashed ghost path (2? 3? 4? 5? A? B? C?) projecting\nthe expected structure from the last accepted point")
ghAnchorInput = input.string("Middle", "Point Inside Range", options = ["Middle", "Near", "Far"], group = GRP_GHOST,
     tooltip = "Where inside its fib range each ghost point is placed:\n" +
               "• Middle: range midpoint\n" +
               "• Near: range edge closest to 0\n" +
               "• Far: range edge furthest from 0")
ghCoefInput = input.float(1.0, "Time Step Coef (× leg 0-1)", minval = 0.1, step = 0.1, group = GRP_GHOST,
     tooltip = "Horizontal step between ghost points as a multiple of the\nleg 0→1 duration in bars")
g5OffInput = input.float(0.05, "5?: Offset From -1.0", minval = 0.0, step = 0.01, group = GRP_GHOST,
     tooltip = "Ghost point 5? is placed at extension -1.0 plus this offset")

cooldownInput = input.int(0, "Cooldown After Reset, bars", minval = 0, group = GRP_RESET,
     tooltip = "Minimum bars after a count ends (invalidation OR completion)\nbefore a new CHoCH can seed the next count. 0 = off")
timeoutKInput = input.float(0.0, "Timeout, k × leg 0-1 (0 = off)", minval = 0.0, step = 0.5, group = GRP_RESET,
     tooltip = "Reset the hypothesis if the current state lasts longer than\n" +
               "k × (duration of leg 0→1) bars. In the CHoCH wait-for-1 phase\n" +
               "(no leg yet) the timeout scales as k × Swing Detection Length.\n" +
               "0 disables the timeout")

themeInput = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = GRP_VISUAL,
     tooltip = "Chart color theme.\n" +
               "• Auto: detects from chart background\n" +
               "• Dark: optimized for dark backgrounds\n" +
               "• Light: optimized for light/white backgrounds")
showGridInput  = input.bool(true, "Fib Grid 0→1", group = GRP_VISUAL,
     tooltip = "Draw the dotted fib grid anchored to leg 0→1")
showBoxesInput = input.bool(true, "OTE Boxes", group = GRP_VISUAL,
     tooltip = "Draw the yellow target boxes for points 2, 3 and 4\n(each with a center dashed line)")
showChochInput = input.bool(true, "CHoCH", group = GRP_VISUAL,
     tooltip = "Draw persistent CHoCH lines and labels (FIFO history layer;\nsurvives count resets)")
pathWidthInput = input.int(2, "Path Width", minval = 1, group = GRP_VISUAL,
     tooltip = "Line width of the accepted wave path 0-1-2-3-4-5-A-B-C")
boxExtInput = input.int(20, "Box Length Forward, bars", minval = 1, group = GRP_VISUAL,
     tooltip = "Initial forward extension of OTE boxes in bars")
maxChochInput = input.int(50, "Historical CHoCH, max", minval = 1, maxval = 100, group = GRP_VISUAL,
     tooltip = "Maximum number of persistent CHoCH lines kept on chart\n(oldest removed first)")
labelFontSizeInput = input.string("Small", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GRP_VISUAL,
     tooltip = "Font size for wave point labels, ghost labels, CHoCH labels,\nthe reset marker, the invalidation label and fib grid level labels")
showWatermarkInput = input.bool(true, "Show Watermark", group = GRP_VISUAL,
     tooltip = "Display 'WillyAlgoTrader' watermark on chart")

s0236Input = input.bool(true, "0.236",  group = GRP_GRID, inline = "r1", tooltip = "Toggle grid level")
s0382Input = input.bool(true, "0.382",  group = GRP_GRID, inline = "r1", tooltip = "Toggle grid level")
s0500Input = input.bool(true, "0.5",    group = GRP_GRID, inline = "r1", tooltip = "Toggle grid level")
s0618Input = input.bool(true, "0.618",  group = GRP_GRID, inline = "r2", tooltip = "Toggle grid level")
s0705Input = input.bool(true, "0.705",  group = GRP_GRID, inline = "r2", tooltip = "Toggle grid level")
s0786Input = input.bool(true, "0.786",  group = GRP_GRID, inline = "r2", tooltip = "Toggle grid level")
s0886Input = input.bool(true, "0.886",  group = GRP_GRID, inline = "r3", tooltip = "Toggle grid level")
s1000Input = input.bool(true, "1.0",    group = GRP_GRID, inline = "r3", tooltip = "Toggle grid level")
sm500Input = input.bool(true, "-0.5",   group = GRP_GRID, inline = "e1", tooltip = "Toggle grid level")
sm618Input = input.bool(true, "-0.618", group = GRP_GRID, inline = "e1", tooltip = "Toggle grid level")
sm100Input = input.bool(true, "-1.0",   group = GRP_GRID, inline = "e1", tooltip = "Toggle grid level")

// ── Colors (user-owned shades; pick colors readable on your background) ──
useCustomColorsInput = input.bool(false, "Use Custom Colors", group = GRP_COLORS,
     tooltip = "OFF (recommended): wave path and point labels use theme-adaptive\n" +
               "greens — dark green on light charts, bright green on dark charts;\n" +
               "short labels stay red. Label text auto-contrasts in both modes.\n" +
               "ON: use the Points and Lines: Path color pickers below")
longPtColorInput = input.color(#00E676, "Points: Long", inline = "pt", group = GRP_COLORS,
     tooltip = "Background of wave point labels in LONG counts\n(used when Use Custom Colors is ON).\nDigit color auto-contrasts with the chosen shade")
shortPtColorInput = input.color(#FF5252, "Short", inline = "pt", group = GRP_COLORS,
     tooltip = "Background of wave point labels in SHORT counts\n(used when Use Custom Colors is ON).\nText color auto-contrasts with the chosen shade")
oteColorInput = input.color(#FFEB3B, "Target Boxes", group = GRP_COLORS,
     tooltip = "Color of the target range boxes for points 2, 3 and 4.\nFill transparency is theme-aware (Dark 65 / Light 55);\nborder and center dashed line render fully opaque")
pathColorInput = input.color(#2962FF, "Lines: Path", inline = "ln", group = GRP_COLORS,
     tooltip = "Color of the accepted wave path 0-1-2-3-4-5-A-B-C\n(used when Use Custom Colors is ON)")
ghostColorInput = input.color(#787B86, "Ghost", inline = "ln", group = GRP_COLORS,
     tooltip = "Base color of the ghost projection (dashed lines and labels);\ntransparency applied automatically")
bullColorInput = input.color(#089981, "CHoCH: Bull", inline = "cc", group = GRP_COLORS,
     tooltip = "Bull color for CHoCH lines and labels.\nDefault #089981 is readable on both dark and light themes")
bearColorInput = input.color(#FF5252, "Bear", inline = "cc", group = GRP_COLORS,
     tooltip = "Bear color for CHoCH lines and labels")
gridRedInput = input.color(#FF5252, "Fib: 0.236", inline = "fib1", group = GRP_COLORS,
     tooltip = "Grid color for the 0.236 level")
gridBlueInput = input.color(#5B9CF6, "Blue lvls", inline = "fib1", group = GRP_COLORS,
     tooltip = "Grid color for the 0.382 / 0.618 / 0.886 / -0.618 levels")
gridBlue2Input = input.color(#64B5F6, "0.786", inline = "fib1", group = GRP_COLORS,
     tooltip = "Grid color for the 0.786 level")
gridGrayInput = input.color(#9E9E9E, "Fib: Gray lvls", inline = "fib2", group = GRP_COLORS,
     tooltip = "Grid color for the 0.5 / 1.0 / -0.5 / -1.0 levels")
gridTealInput = input.color(#26A69A, "0.705 (OTE)", inline = "fib2", group = GRP_COLORS,
     tooltip = "Grid color for the 0.705 OTE level")

showDashInput = input.bool(true, "Show Dashboard", group = GRP_DASH,
     tooltip = "Show the status table (state, direction, invalidation level,\nlast reset reason, completed impulses)")
dashPosStrInput = input.string("Top Right", "Dashboard Position",
     options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Right"],
     group = GRP_DASH,
     tooltip = "Corner of the chart where the dashboard is anchored")
dashFontSizeInput = input.string("Small", "Dashboard Font Size", options = ["Small", "Normal", "Large", "Huge"], group = GRP_DASH,
     tooltip = "Font size for the dashboard table. The version footer renders\none step smaller to preserve hierarchy")

// ══════════════════════════════════════
// INPUT VALIDATION
// ══════════════════════════════════════
if accDepthInput > swingLenInput
    runtime.error("Point Confirmation must be <= Swing Detection Length")
if r2MinInput == r2MaxInput or r3MinInput == r3MaxInput or r4MinInput == r4MaxInput or r5MinInput == r5MaxInput or rBMinInput == rBMaxInput or rCMinInput == rCMaxInput
    runtime.error("Fib range min and max must differ (zero-width range)")
if math.min(r2MinInput, r2MaxInput) <= 0 or math.max(r2MinInput, r2MaxInput) >= 1
    runtime.error("Point 2 range must be inside (0, 1) — retracement of leg 0-1")
if math.min(r4MinInput, r4MaxInput) <= 0 or math.max(r4MinInput, r4MaxInput) >= 1
    runtime.error("Point 4 range must be inside (0, 1) — retracement of leg 2-3")
if math.max(r3MinInput, r3MaxInput) >= 0 or math.max(r5MinInput, r5MaxInput) >= 0 or math.max(rBMinInput, rBMaxInput) >= 0
    runtime.error("Point 3/5/B ranges must be negative (extension levels beyond point 1)")
if rCMinInput < 0 or math.max(rCMinInput, rCMaxInput) >= 1
    runtime.error("Point C range must be inside [0, 1)")

// ══════════════════════════════════════
// THEME DETECTION & COLORS
// ══════════════════════════════════════
isDark = switch themeInput
    "Dark"  => true
    "Light" => false
    =>         color.r(chart.bg_color) < 128   // Auto

// ── Texts ───────────────────────────────────────────────────────
TEXT_COLOR   = isDark ? #E0E0E0 : #1A1A1A
TEXT_MUTED   = isDark ? color.new(#9E9E9E, 0) : color.new(#757575, 0)

// ── Adaptive signal text colors (dashboard) ─────────────────────
BULL_TEXT    = isDark ? #00E676 : #00A152
BEAR_TEXT    = isDark ? #FF5252 : #D32F2F
NEUTRAL_TEXT = isDark ? #FFEB3B : #F57F17

// ── Dashboard / tables ──────────────────────────────────────────
TABLE_BG     = isDark ? color.new(#131722, 5) : color.new(#FFFFFF, 5)
TABLE_BORDER = isDark ? color.new(#2A2E39, 0) : color.new(#D0D0D0, 0)
HEADER_BG    = color.new(#2962FF, 0)
HEADER_TEXT  = #FFFFFF

// ── Markup palette (theme-adaptive greens by default; 🎨 Colors override) ──
// Theme green: dark green on light charts, bright green on dark charts
THEME_GREEN  = isDark ? #00E676 : #1B5E20
PATH_COLOR   = useCustomColorsInput ? pathColorInput : THEME_GREEN
GHOST_COLOR  = color.new(ghostColorInput, 30)
GHOST_LBL_BG = color.new(ghostColorInput, 70)
// OTE target ranges — user color; fill transparency theme-aware,
// border and center line fully opaque to anchor the color read
OTE_FILL     = color.new(oteColorInput, isDark ? 65 : 55)
OTE_BORDER   = color.new(oteColorInput, 0)
CRIT_COLOR   = isDark ? color.new(#FF5252, 0)  : color.new(#D32F2F, 0)
CRIT_LBL_BG  = isDark ? color.new(#FF5252, 85) : color.new(#D32F2F, 88)
RESET_LBL_BG = isDark ? color.new(#FF5252, 20) : color.new(#D32F2F, 20)
RESET_LBL_TX = #FFFFFF   // white on red — readable on both themes
WM_COLOR     = isDark ? color.new(#FFFFFF, 80) : color.new(#000000, 80)

// ── Wave point labels — theme-adaptive bg + auto-contrast text ──
// Default: long = THEME_GREEN (dark green on light / bright green on dark),
// short = red. Custom mode: picker backgrounds. Digit color is derived
// from background luminance: bright bg → black text, dark bg → white text
LONG_PT_BG  = useCustomColorsInput ? longPtColorInput : THEME_GREEN
SHORT_PT_BG = useCustomColorsInput ? shortPtColorInput : #FF5252
float lumLongPt  = 0.299 * color.r(LONG_PT_BG)  + 0.587 * color.g(LONG_PT_BG)  + 0.114 * color.b(LONG_PT_BG)
float lumShortPt = 0.299 * color.r(SHORT_PT_BG) + 0.587 * color.g(SHORT_PT_BG) + 0.114 * color.b(SHORT_PT_BG)
LONG_PT_TX  = lumLongPt  > 140 ? #000000 : #FFFFFF
SHORT_PT_TX = lumShortPt > 140 ? #000000 : #FFFFFF

// ── Fib grid palette — user-colored role inputs ─────────────────
GRID_RED   = gridRedInput
GRID_BLUE  = gridBlueInput
GRID_BLUE2 = gridBlue2Input
GRID_GRAY  = gridGrayInput
GRID_TEAL  = gridTealInput

// ══════════════════════════════════════
// VAR STATE
// ══════════════════════════════════════
var int   state = S_SCAN
var int   dir   = 0
var float chochLvl = na

var float p0 = na
var float p1 = na
var float p2 = na
var float p3 = na
var float p4 = na
var float p5 = na
var float pA = na
var float pB = na
var int   b0 = na
var int   b1 = na
var int   b2 = na
var int   b3 = na
var int   b4 = na
var int   b5 = na
var int   bA = na
var int   bB = na

var bool  broke1     = false
var bool  broke3     = false
var bool  ote2       = false
var bool  oteB4      = false
var bool  hitM1      = false
var float w2best     = na
var int   w2bestBar  = na

var float lockedChochLvl = na
var int   lastResetBar   = -100000
var int   stateStartBar  = na

// Structural context (SCANNING)
var int   curSHbar = na
var float runLow    = na
var int   runLowBar = na
var int   curSLbar = na
var float runHigh    = na
var int   runHighBar = na

// Active count objects
var line  seg01 = na
var line  seg12 = na
var line  seg23 = na
var line  seg34 = na
var line  seg45 = na
var line  seg5A = na
var line  segAB = na
var label lb0 = na
var label lb1 = na
var label lb2 = na
var label lb3 = na
var label lb4 = na
var label lb5 = na
var label lbA = na
var label lbB = na
var box   box2 = na
var line  ml2  = na
var box   box3 = na
var line  ml3  = na
var box   box4 = na
var line  ml4  = na
var line  critLn = na
var label critLb = na

// Graphics collections
var array<line>  aLines  = array.new<line>()
var array<label> aLabels = array.new<label>()
var array<box>   aBoxes  = array.new<box>()
var array<line>  fLines  = array.new<line>()
var array<label> fLabels = array.new<label>()
var array<line>  gLines  = array.new<line>()
var array<label> gLabels = array.new<label>()
var array<line>  chLines  = array.new<line>()
var array<label> chLabels = array.new<label>()
var array<float> chLvl  = array.new<float>()
var array<int>   chBias = array.new<int>()
var array<label> xLabels  = array.new<label>()

// Swing structure (Trader Assistant Pro engine)
var float swHighLevel = na
var float swLowLevel  = na
var int   swHighBar = na
var int   swLowBar  = na
var bool  swHighBroken = false
var bool  swLowBroken  = false
var int   ewTrend = 0

// Dashboard stats
var int    impulseCount = 0
var string lastResetStr = "—"

// Fib grid levels (theme-aware palette)
var array<float> LV = array.new<float>()
var array<color> LC = array.new<color>()
var array<bool>  LS = array.new<bool>()
if barstate.isfirst
    array.push(LV, 0.236)
    array.push(LC, GRID_RED)
    array.push(LS, s0236Input)
    array.push(LV, 0.382)
    array.push(LC, GRID_BLUE)
    array.push(LS, s0382Input)
    array.push(LV, 0.5)
    array.push(LC, GRID_GRAY)
    array.push(LS, s0500Input)
    array.push(LV, 0.618)
    array.push(LC, GRID_BLUE)
    array.push(LS, s0618Input)
    array.push(LV, 0.705)
    array.push(LC, GRID_TEAL)
    array.push(LS, s0705Input)
    array.push(LV, 0.786)
    array.push(LC, GRID_BLUE2)
    array.push(LS, s0786Input)
    array.push(LV, 0.886)
    array.push(LC, GRID_BLUE)
    array.push(LS, s0886Input)
    array.push(LV, 1.0)
    array.push(LC, GRID_GRAY)
    array.push(LS, s1000Input)
    array.push(LV, -0.5)
    array.push(LC, GRID_GRAY)
    array.push(LS, sm500Input)
    array.push(LV, -0.618)
    array.push(LC, GRID_BLUE)
    array.push(LS, sm618Input)
    array.push(LV, -1.0)
    array.push(LC, GRID_GRAY)
    array.push(LS, sm100Input)

// ══════════════════════════════════════
// PER-BAR CALCULATIONS (ta.* — global and unconditional only)
// ══════════════════════════════════════
// C4 anti-repaint: ta.pivothigh/low can flicker on the realtime bar (the
// forming bar participates in the right-side comparison and its extremes
// still change). Consuming such a transient pivot would trigger an
// irreversible state transition or corrupt the swing structure. The ta.*
// calls stay unconditional; only the consumed VALUES are masked to
// confirmed bars. History is unaffected (all historical bars are confirmed)
float swPHraw = ta.pivothigh(swingLenInput, swingLenInput)
float swPLraw = ta.pivotlow(swingLenInput, swingLenInput)
swPH = barstate.isconfirmed ? swPHraw : na
swPL = barstate.isconfirmed ? swPLraw : na
swBarP = bar_index - swingLenInput
float phAraw = ta.pivothigh(accDepthInput, accDepthInput)
float plAraw = ta.pivotlow(accDepthInput, accDepthInput)
phA = barstate.isconfirmed ? phAraw : na
plA = barstate.isconfirmed ? plAraw : na
pivBA = bar_index - accDepthInput

// ══════════════════════════════════════
// FUNCTIONS
// ══════════════════════════════════════
sizeFromString(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : s == "Huge" ? size.huge : size.small

// One step smaller — for the dashboard version footer
sizeDownFromString(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.tiny : s == "Normal" ? size.small : s == "Large" ? size.normal : s == "Huge" ? size.large : size.tiny

// Resolved sizes (globals — used by label helpers and dashboard below)
labelSize        = sizeFromString(labelFontSizeInput)
dashFontSize     = sizeFromString(dashFontSizeInput)
dashFontSizeSub  = sizeDownFromString(dashFontSizeInput)

f_in(float x, float a, float b) =>
    x >= math.min(a, b) and x <= math.max(a, b)

f_fibP(float L) =>
    p1 - L * (p1 - p0)

// Fib level of price p on the 0→1 grid (zero-division guarded)
f_lvl(float p) =>
    float d = p1 - p0
    not na(d) and d != 0 ? (p1 - p) / d : 0.0

f_fib23(float F) =>
    p3 - F * (p3 - p2)

// Fib level of price p on the 2→3 grid (zero-division guarded)
f_lvl23(float p) =>
    float d = p3 - p2
    not na(d) and d != 0 ? (p3 - p) / d : 0.0

f_sel(float a, float b) =>
    nr = math.abs(a) <= math.abs(b) ? a : b
    fr = math.abs(a) <= math.abs(b) ? b : a
    ghAnchorInput == "Middle" ? (a + b) * 0.5 : ghAnchorInput == "Near" ? nr : fr

// S9: retracement extreme over ALL bars since point 1 (exclusive), including
// the pivot-lag window that per-bar tracking alone would miss.
// Returns [extremePrice, extremeBar] in the counter-trend direction
f_scanBest() =>
    int span = math.min(bar_index - b1 - 1, 479)
    float m = dir == 1 ? low : high
    int mb = bar_index
    if span > 0
        for i = 1 to span
            float v = dir == 1 ? low[i] : high[i]
            bool better = dir == 1 ? v < m : v > m
            if better
                m := v
                mb := bar_index - i
    [m, mb]

// Against the hypothesis (break of a critical level "down" for long).
// C2 anti-repaint: Close mode evaluates ONLY on the confirmed bar close —
// an intrabar close excursion cannot trigger an irreversible reset.
// Wick mode stays intrabar: a wick beyond the level is irreversible.
f_adverse(float level) =>
    dir == 1 ? (confClose ? barstate.isconfirmed and close < level : low < level) : (confClose ? barstate.isconfirmed and close > level : high > level)

// With the hypothesis (break "up" for long). Same C2 gating as f_adverse.
f_beyond(float level) =>
    dir == 1 ? (confClose ? barstate.isconfirmed and close > level : high > level) : (confClose ? barstate.isconfirmed and close < level : low < level)

f_clrLn(array<line> arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            line.delete(array.get(arr, i))
    array.clear(arr)

f_clrLb(array<label> arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            label.delete(array.get(arr, i))
    array.clear(arr)

f_clrBx(array<box> arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            box.delete(array.get(arr, i))
    array.clear(arr)

// Full wipe of the active count; CHoCH layer (chLines/chLabels) is preserved
f_wipe() =>
    f_clrLn(aLines)
    f_clrLb(aLabels)
    f_clrBx(aBoxes)
    f_clrLn(fLines)
    f_clrLb(fLabels)
    f_clrLn(gLines)
    f_clrLb(gLabels)

// Wave point label — direction-colored:
// long count = green bg + black digits, short count = red bg + white text
f_mkLab(int b_, float p_, string txt, bool top_) =>
    color bg_ = dir == 1 ? LONG_PT_BG : SHORT_PT_BG
    color tx_ = dir == 1 ? LONG_PT_TX : SHORT_PT_TX
    l = label.new(b_, p_, txt, style = top_ ? label.style_label_down : label.style_label_up, color = bg_, textcolor = tx_, size = labelSize)
    array.push(aLabels, l)
    l

f_mkSeg(int x1_, float y1_, int x2_, float y2_) =>
    ln = line.new(x1_, y1_, x2_, y2_, color = PATH_COLOR, width = pathWidthInput)
    array.push(aLines, ln)
    ln

// Right edge of the fib grid: end of the ghost projection (point C?) + 5 bars
f_gridEnd() =>
    int e = bar_index + 2
    if array.size(gLines) > 0
        e := math.max(e, line.get_x2(array.get(gLines, array.size(gLines) - 1)) + 5)
    e

f_buildGrid() =>
    f_clrLn(fLines)
    f_clrLb(fLabels)
    if showGridInput
        ge = f_gridEnd()
        for i = 0 to array.size(LV) - 1
            if array.get(LS, i)
                Lv = array.get(LV, i)
                y  = f_fibP(Lv)
                c  = array.get(LC, i)
                ln = line.new(b0, y, ge, y, color = c, style = line.style_dotted)
                lb = label.new(ge, y, str.tostring(Lv, "#.###") + " (" + str.tostring(y, format.mintick) + ")", style = label.style_label_left, color = color.new(color.white, 100), textcolor = c, size = labelSize)
                array.push(fLines, ln)
                array.push(fLabels, lb)

f_buildGhost() =>
    f_clrLn(gLines)
    f_clrLb(gLabels)
    if showGhostInput and state >= S_W2 and state <= S_C and not na(p1)
        step = math.max(1, math.round((b1 - b0) * ghCoefInput))
        g2 = f_fibP(f_sel(r2MinInput, r2MaxInput))
        g3 = f_fibP((r3MinInput + r3MaxInput) * 0.5)
        ref2 = state >= S_W3 ? p2 : g2
        ref3 = state >= S_W4 ? p3 : g3
        g4 = ref3 - f_sel(r4MinInput, r4MaxInput) * (ref3 - ref2)
        g5 = f_fibP(-1.0 + g5OffInput)
        gA = state >= S_W5 ? p4 : g4
        gB = f_fibP(f_sel(rBMinInput, rBMaxInput))
        gC = f_fibP(f_sel(rCMinInput, rCMaxInput))
        float aP = p1
        int   aB = b1
        if state == S_W3
            aP := p2
            aB := b2
        if state == S_W4
            aP := p3
            aB := b3
        if state == S_W5
            aP := p4
            aB := b4
        if state == S_A
            aP := p5
            aB := b5
        if state == S_B
            aP := pA
            aB := bA
        if state == S_C
            aP := pB
            aB := bB
        prices = array.new<float>()
        names  = array.new<string>()
        if state <= S_W2
            array.push(prices, g2)
            array.push(names, "2?")
        if state <= S_W3
            array.push(prices, g3)
            array.push(names, "3?")
        if state <= S_W4
            array.push(prices, g4)
            array.push(names, "4?")
        if state <= S_W5
            array.push(prices, g5)
            array.push(names, "5?")
        if state <= S_A
            array.push(prices, gA)
            array.push(names, "A?")
        if state <= S_B
            array.push(prices, gB)
            array.push(names, "B?")
        array.push(prices, gC)
        array.push(names, "C?")
        pPrev = aP
        bPrev = aB
        for i = 0 to array.size(prices) - 1
            pt = array.get(prices, i)
            gb = math.min(aB + step * (i + 1), bar_index + 450)
            gl = line.new(bPrev, pPrev, gb, pt, color = GHOST_COLOR, style = line.style_dashed)
            top_ = pt >= pPrev
            gl2 = label.new(gb, pt, array.get(names, i), style = top_ ? label.style_label_down : label.style_label_up, color = GHOST_LBL_BG, textcolor = TEXT_COLOR, size = labelSize)
            array.push(gLines, gl)
            array.push(gLabels, gl2)
            pPrev := pt
            bPrev := gb

// ══════════════════════════════════════
// PER-BAR LOGIC
// ══════════════════════════════════════
bool aChoch = false
bool aOte2  = false
bool aW2    = false
bool aBrk1  = false
bool aBox4  = false
bool aBrk3  = false
bool aTgt   = false
bool aW5    = false
bool aCd    = false
bool aInv   = false

int pendingReset = 0   // 0 none, 1 INVALID, 2 DONE
string resetReason = ""

// M7: deferred seed — captures a CHoCH break that lands on the same bar as
// a §5.17 reset; applied after the wipe at the bottom of the script
bool  seedNow   = false
int   seedDir   = 0
float seedLvl   = na
float seedP0    = na
int   seedB0    = na
int   seedSwBar = na

// ── Spec §5.17: per-bar invalidation check BEFORE pivot updates ──────────────
// Close mode: f_adverse fires on confirmed bar close only (C2)
if state != S_SCAN
    if timeoutKInput > 0 and not na(b1) and bar_index - stateStartBar > timeoutKInput * (b1 - b0)
        pendingReset := 1
        resetReason := "TIMEOUT"
    // M8: CHoCH wait-for-1 phase has no leg 0-1 yet — scale on swing length
    if timeoutKInput > 0 and state == S_CHOCH and bar_index - stateStartBar > timeoutKInput * swingLenInput
        pendingReset := 1
        resetReason := "TIMEOUT"
    if pendingReset == 0
        if state == S_CHOCH
            if f_adverse(p0)
                pendingReset := 1
                resetReason := "FALSE_CHOCH"
        else if state == S_W2 or (state == S_W3 and not broke1)
            if f_adverse(p0)
                pendingReset := 1
                resetReason := "BELOW_0"
        else if (state == S_W3 and broke1) or state == S_W4 or (state == S_W5 and not broke3)
            if f_adverse(p2)
                pendingReset := 1
                resetReason := "BELOW_W2"
        else if state == S_W5 and broke3
            if f_adverse(p4)
                pendingReset := 1
                resetReason := "BELOW_W4"
        else if state >= S_A
            if f_adverse(p2)
                pendingReset := 1
                resetReason := "DEEP_C"

// ── SWING STRUCTURE + CHoCH (Trader Assistant Pro engine) ────────────────────
bool isWarmed = bar_index >= math.max(swingLenInput * 3, 50)
if not na(swPH)
    swHighLevel := swPH
    swHighBar := swBarP
    swHighBroken := false
if not na(swPL)
    swLowLevel := swPL
    swLowBar := swBarP
    swLowBroken := false
// Extreme of the current swing — point 0 of the future count
if not na(swHighBar)
    if na(curSHbar) or swHighBar != curSHbar
        curSHbar := swHighBar
        off = math.min(bar_index - swHighBar, 480)
        float m = low
        int mb = bar_index
        if off > 0
            for i = 0 to off
                if low[i] < m
                    m := low[i]
                    mb := bar_index - i
        runLow := m
        runLowBar := mb
    else if low < runLow
        runLow := low
        runLowBar := bar_index
if not na(swLowBar)
    if na(curSLbar) or swLowBar != curSLbar
        curSLbar := swLowBar
        off = math.min(bar_index - swLowBar, 480)
        float m = high
        int mb = bar_index
        if off > 0
            for i = 0 to off
                if high[i] > m
                    m := high[i]
                    mb := bar_index - i
        runHigh := m
        runHighBar := mb
    else if high > runHigh
        runHigh := high
        runHighBar := bar_index
// Structure breaks TAP-style: confirmed bar close; CHoCH = break against trend
bool bullBreak = not na(swHighLevel) and not swHighBroken and close > swHighLevel and barstate.isconfirmed and isWarmed
bool bearBreak = not na(swLowLevel) and not swLowBroken and close < swLowLevel and barstate.isconfirmed and isWarmed
if bullBreak
    swHighBroken := true
    bool wasBear = ewTrend == -1
    ewTrend := 1
    cooled = bar_index >= lastResetBar + cooldownInput
    // M10: half-tick tolerance instead of float equality
    freeUp = na(lockedChochLvl) or math.abs(swHighLevel - lockedChochLvl) > syminfo.mintick / 2
    if wasBear and state == S_SCAN and pendingReset == 0 and cooled and freeUp and not na(runLow)
        dir := 1
        chochLvl := swHighLevel
        p0 := runLow
        b0 := runLowBar
        if showChochInput
            cl = line.new(swHighBar, chochLvl, bar_index, chochLvl, color = bullColorInput, width = 1, style = line.style_dashed)
            cb = label.new(math.round((swHighBar + bar_index) / 2), chochLvl, "CHoCH", color = color(na), textcolor = bullColorInput, style = label.style_label_down, size = labelSize)
            array.push(chLines, cl)
            array.push(chLabels, cb)
            array.push(chLvl, chochLvl)
            array.push(chBias, 1)
            if array.size(chLines) > maxChochInput
                line.delete(array.shift(chLines))
                label.delete(array.shift(chLabels))
                array.shift(chLvl)
                array.shift(chBias)
        f_clrLb(xLabels)
        w2best := na
        w2bestBar := na
        state := S_CHOCH
        stateStartBar := bar_index
        aChoch := true
    // M7: same-bar §5.17 reset + bull CHoCH — defer the seed until after the
    // wipe (Cooldown must be 0: the reset lands this bar). The fresh reset ✖
    // is kept until the following seed
    else if wasBear and pendingReset == 1 and cooldownInput == 0 and freeUp and not na(runLow)
        seedNow := true
        seedDir := 1
        seedLvl := swHighLevel
        seedP0 := runLow
        seedB0 := runLowBar
        seedSwBar := swHighBar
        aChoch := true
if bearBreak
    swLowBroken := true
    bool wasBull = ewTrend == 1
    ewTrend := -1
    cooled = bar_index >= lastResetBar + cooldownInput
    // M10: half-tick tolerance instead of float equality
    freeDn = na(lockedChochLvl) or math.abs(swLowLevel - lockedChochLvl) > syminfo.mintick / 2
    if wasBull and state == S_SCAN and pendingReset == 0 and cooled and freeDn and not na(runHigh)
        dir := -1
        chochLvl := swLowLevel
        p0 := runHigh
        b0 := runHighBar
        if showChochInput
            cl = line.new(swLowBar, chochLvl, bar_index, chochLvl, color = bearColorInput, width = 1, style = line.style_dashed)
            cb = label.new(math.round((swLowBar + bar_index) / 2), chochLvl, "CHoCH", color = color(na), textcolor = bearColorInput, style = label.style_label_up, size = labelSize)
            array.push(chLines, cl)
            array.push(chLabels, cb)
            array.push(chLvl, chochLvl)
            array.push(chBias, -1)
            if array.size(chLines) > maxChochInput
                line.delete(array.shift(chLines))
                label.delete(array.shift(chLabels))
                array.shift(chLvl)
                array.shift(chBias)
        f_clrLb(xLabels)
        w2best := na
        w2bestBar := na
        state := S_CHOCH
        stateStartBar := bar_index
        aChoch := true
    // M7: same-bar §5.17 reset + bear CHoCH — deferred seed (see bull side)
    else if wasBull and pendingReset == 1 and cooldownInput == 0 and freeDn and not na(runHigh)
        seedNow := true
        seedDir := -1
        seedLvl := swLowLevel
        seedP0 := runHigh
        seedB0 := runHighBar
        seedSwBar := swLowBar
        aChoch := true
// CHoCH mitigation detection — per-bar state logic (confirmed close),
// x2 fixed to the mitigation bar, style becomes dotted.
// M11: 'mit' requires a confirmed close anyway — skip the loop on ticks
if barstate.isconfirmed and array.size(chLines) > 0
    for i = 0 to array.size(chLines) - 1
        int bs = array.get(chBias, i)
        if bs != 0
            float lv = array.get(chLvl, i)
            bool mit = bs == 1 ? close < lv : close > lv
            if mit
                line lnn = array.get(chLines, i)
                line.set_x2(lnn, bar_index)
                line.set_style(lnn, line.style_dotted)
                array.set(chBias, i, 0)

// ── STATE LOGIC ON PIVOTS ────────────────────────────────────────────────────
ctrV = dir == 1 ? plA : phA   // counter-trend pivots: 2, 4, A, C (fast confirmation)
wtV  = dir == 1 ? phA : plA   // with-trend pivots: 1, 3, 5, B (fast confirmation)

bool  doAcc2   = false
float acc2P    = na
int   acc2B    = na
bool  acc2Soft = false
bool  acc2Brk  = false

if pendingReset == 0 and state == S_CHOCH
    if not na(ctrV)
        deeper0 = dir == 1 ? ctrV < p0 : ctrV > p0
        if deeper0
            p0 := ctrV
            b0 := pivBA
    if not na(wtV)
        beyondCh = dir == 1 ? wtV > chochLvl : wtV < chochLvl
        if beyondCh
            p1 := wtV
            b1 := pivBA
            state := S_W2
            stateStartBar := bar_index
            // S9: backfill the retracement extreme over the pivot-lag window
            [w2bf, w2bfBar] = f_scanBest()
            w2best := w2bf
            w2bestBar := w2bfBar
            lb0 := f_mkLab(b0, p0, "0", dir == -1)
            lb1 := f_mkLab(b1, p1, "1", dir == 1)
            seg01 := f_mkSeg(b0, p0, b1, p1)
            f_buildGrid()
            if showBoxesInput
                e1 = f_fibP(r2MinInput)
                e2 = f_fibP(r2MaxInput)
                box2 := box.new(b1, math.max(e1, e2), b1 + boxExtInput, math.min(e1, e2), border_color = OTE_BORDER, bgcolor = OTE_FILL)
                array.push(aBoxes, box2)
                mid2 = f_fibP((r2MinInput + r2MaxInput) * 0.5)
                ml2 := line.new(b1, mid2, b1 + boxExtInput, mid2, color = OTE_BORDER, style = line.style_dashed)
                array.push(aLines, ml2)
            f_buildGhost()

else if pendingReset == 0 and state == S_W2
    // Reposition 1: a more extreme with-trend pivot
    if not na(wtV)
        higher1 = dir == 1 ? wtV > p1 : wtV < p1
        if higher1
            p1 := wtV
            b1 := pivBA
            // S9: retracement extreme is only valid AFTER the (new) point 1
            [w2rf, w2rfBar] = f_scanBest()
            w2best := w2rf
            w2bestBar := w2rfBar
            line.delete(seg01)
            label.delete(lb1)
            lb1 := f_mkLab(b1, p1, "1", dir == 1)
            seg01 := f_mkSeg(b0, p0, b1, p1)
            f_buildGrid()
            if showBoxesInput
                box.delete(box2)
                e1 = f_fibP(r2MinInput)
                e2 = f_fibP(r2MaxInput)
                box2 := box.new(b1, math.max(e1, e2), b1 + boxExtInput, math.min(e1, e2), border_color = OTE_BORDER, bgcolor = OTE_FILL)
                array.push(aBoxes, box2)
                // S8: center line must follow the new grid, not stay stale
                if not na(ml2)
                    line.delete(ml2)
                mid2 = f_fibP((r2MinInput + r2MaxInput) * 0.5)
                ml2 := line.new(b1, mid2, b1 + boxExtInput, mid2, color = OTE_BORDER, style = line.style_dashed)
                array.push(aLines, ml2)
            f_buildGhost()
    if not na(ctrV)
        L2 = f_lvl(ctrV)
        if L2 >= 1.0
            pendingReset := 1
            resetReason := "BELOW_0"
        else if L2 > 0.0
            doAcc2 := true
            acc2P := ctrV
            acc2B := pivBA
            acc2Soft := not f_in(L2, r2MinInput, r2MaxInput)

else if pendingReset == 0 and state == S_W3
    // Reposition 2 — only until point 1 is broken; after the break a pivot
    // below point 2 = reset
    if not na(ctrV)
        deeper2 = dir == 1 ? ctrV < p2 : ctrV > p2
        if deeper2 and broke1
            pendingReset := 1
            resetReason := "BELOW_W2"
        else if deeper2
            L2 = f_lvl(ctrV)
            if L2 >= 1.0
                pendingReset := 1
                resetReason := "BELOW_0"
            else
                p2 := ctrV
                b2 := pivBA
                line.delete(seg12)
                label.delete(lb2)
                lb2 := f_mkLab(b2, p2, f_in(L2, r2MinInput, r2MaxInput) ? "2" : "2~", dir == -1)
                seg12 := f_mkSeg(b1, p1, b2, p2)
                if not na(box2)
                    box.set_right(box2, b2)
                if not na(box3)
                    box.set_left(box3, b2)
                if not na(ml3)
                    line.set_x1(ml3, b2)
                f_buildGhost()
    if pendingReset == 0 and not na(wtV) and broke1
        beyond3 = dir == 1 ? wtV > p1 : wtV < p1
        if beyond3
            L3 = f_lvl(wtV)
            p3 := wtV
            b3 := pivBA
            lb3 := f_mkLab(b3, p3, f_in(L3, r3MinInput, r3MaxInput) ? "3" : "3~", dir == 1)
            seg23 := f_mkSeg(b2, p2, b3, p3)
            if not na(box3)
                box.set_right(box3, b3)
            if showBoxesInput
                e1 = f_fib23(r4MinInput)
                e2 = f_fib23(r4MaxInput)
                box4 := box.new(b3, math.max(e1, e2), b3 + boxExtInput, math.min(e1, e2), border_color = OTE_BORDER, bgcolor = OTE_FILL)
                array.push(aBoxes, box4)
                mid4 = f_fib23((r4MinInput + r4MaxInput) * 0.5)
                ml4 := line.new(b3, mid4, b3 + boxExtInput, mid4, color = OTE_BORDER, style = line.style_dashed)
                array.push(aLines, ml4)
            state := S_W4
            stateStartBar := bar_index
            oteB4 := false
            f_buildGhost()

else if pendingReset == 0 and state == S_W4
    // Reposition 3: a more extreme with-trend pivot (range does not block)
    if not na(wtV)
        higher3 = dir == 1 ? wtV > p3 : wtV < p3
        if higher3
            L3 = f_lvl(wtV)
            p3 := wtV
            b3 := pivBA
            line.delete(seg23)
            label.delete(lb3)
            lb3 := f_mkLab(b3, p3, f_in(L3, r3MinInput, r3MaxInput) ? "3" : "3~", dir == 1)
            seg23 := f_mkSeg(b2, p2, b3, p3)
            if not na(box3)
                box.set_right(box3, b3)
            if showBoxesInput
                box.delete(box4)
                e1 = f_fib23(r4MinInput)
                e2 = f_fib23(r4MaxInput)
                box4 := box.new(b3, math.max(e1, e2), b3 + boxExtInput, math.min(e1, e2), border_color = OTE_BORDER, bgcolor = OTE_FILL)
                array.push(aBoxes, box4)
                // S8: center line must follow the new 2→3 grid, not stay stale
                if not na(ml4)
                    line.delete(ml4)
                mid4 = f_fib23((r4MinInput + r4MaxInput) * 0.5)
                ml4 := line.new(b3, mid4, b3 + boxExtInput, mid4, color = OTE_BORDER, style = line.style_dashed)
                array.push(aLines, ml4)
            f_buildGhost()
    if pendingReset == 0 and not na(ctrV)
        below2 = dir == 1 ? ctrV < p2 : ctrV > p2
        F4 = f_lvl23(ctrV)
        if below2
            pendingReset := 1
            resetReason := "BELOW_W2"
        else if F4 > 0.0
            p4 := ctrV
            b4 := pivBA
            lb4 := f_mkLab(b4, p4, f_in(F4, r4MinInput, r4MaxInput) ? "4" : "4~", dir == -1)
            seg34 := f_mkSeg(b3, p3, b4, p4)
            if not na(box4)
                box.set_right(box4, b4)
            state := S_W5
            stateStartBar := bar_index
            hitM1 := false
            f_buildGhost()

else if pendingReset == 0 and state == S_W5
    // Reposition 4: a deeper pullback until point 3 is broken
    if not na(ctrV) and not broke3
        deeper4 = dir == 1 ? ctrV < p4 : ctrV > p4
        below2r = dir == 1 ? ctrV < p2 : ctrV > p2
        if deeper4 and below2r
            pendingReset := 1
            resetReason := "BELOW_W2"
        else if deeper4
            F4 = f_lvl23(ctrV)
            p4 := ctrV
            b4 := pivBA
            line.delete(seg34)
            label.delete(lb4)
            lb4 := f_mkLab(b4, p4, f_in(F4, r4MinInput, r4MaxInput) ? "4" : "4~", dir == -1)
            seg34 := f_mkSeg(b3, p3, b4, p4)
            if not na(box4)
                box.set_right(box4, b4)
            f_buildGhost()
    // After point 3 is broken, a pivot low beyond point 4 = reset
    // (wick past the per-bar Close check)
    if pendingReset == 0 and not na(ctrV) and broke3
        beyond4 = dir == 1 ? ctrV < p4 : ctrV > p4
        if beyond4
            pendingReset := 1
            resetReason := "BELOW_W4"
    if pendingReset == 0 and not na(wtV) and broke3
        beyond5 = dir == 1 ? wtV > p3 : wtV < p3
        if beyond5
            L5 = f_lvl(wtV)
            len1 = math.abs(p1 - p0)
            len3 = math.abs(p3 - p2)
            len5 = math.abs(wtV - p4)
            if len3 < len1 and len3 < len5
                pendingReset := 1
                resetReason := "W3_SHORTEST"
            else
                p5 := wtV
                b5 := pivBA
                lb5 := f_mkLab(b5, p5, f_in(L5, r5MinInput, r5MaxInput) ? "5" : "5~", dir == 1)
                seg45 := f_mkSeg(b4, p4, b5, p5)
                state := S_A
                stateStartBar := bar_index
                aW5 := true
                f_buildGhost()

else if pendingReset == 0 and state == S_A
    // Wave 5 extension (range does not block; W3_SHORTEST not re-evaluated —
    // len5 only grows)
    if not na(wtV)
        higher5 = dir == 1 ? wtV > p5 : wtV < p5
        if higher5
            L5 = f_lvl(wtV)
            p5 := wtV
            b5 := pivBA
            line.delete(seg45)
            label.delete(lb5)
            lb5 := f_mkLab(b5, p5, f_in(L5, r5MinInput, r5MaxInput) ? "5" : "5~", dir == 1)
            seg45 := f_mkSeg(b4, p4, b5, p5)
            f_buildGhost()
    if pendingReset == 0 and not na(ctrV)
        deepA = dir == 1 ? ctrV < p2 : ctrV > p2
        if deepA
            pendingReset := 1
            resetReason := "DEEP_C"
        else
            pA := ctrV
            bA := pivBA
            lbA := f_mkLab(bA, pA, "A", dir == -1)
            seg5A := f_mkSeg(b5, p5, bA, pA)
            state := S_B
            stateStartBar := bar_index
            f_buildGhost()

else if pendingReset == 0 and state == S_B
    // Reposition A: a deeper low until B appears
    if not na(ctrV)
        deeperA = dir == 1 ? ctrV < pA : ctrV > pA
        deepHard = dir == 1 ? ctrV < p2 : ctrV > p2
        if deeperA and deepHard
            pendingReset := 1
            resetReason := "DEEP_C"
        else if deeperA
            pA := ctrV
            bA := pivBA
            line.delete(seg5A)
            label.delete(lbA)
            lbA := f_mkLab(bA, pA, "A", dir == -1)
            seg5A := f_mkSeg(b5, p5, bA, pA)
            f_buildGhost()
    if pendingReset == 0 and not na(wtV)
        above5 = dir == 1 ? wtV >= p5 : wtV <= p5
        if above5
            pendingReset := 2
            resetReason := "B_ABOVE_5"
        else
            LB = f_lvl(wtV)
            pB := wtV
            bB := pivBA
            lbB := f_mkLab(bB, pB, f_in(LB, rBMinInput, rBMaxInput) ? "B" : "B~", dir == 1)
            segAB := f_mkSeg(bA, pA, bB, pB)
            state := S_C
            stateStartBar := bar_index
            f_buildGhost()

else if pendingReset == 0 and state == S_C
    // Reposition B: a higher high until C appears
    if not na(wtV)
        above5b = dir == 1 ? wtV >= p5 : wtV <= p5
        higherB = dir == 1 ? wtV > pB : wtV < pB
        if above5b
            pendingReset := 2
            resetReason := "B_ABOVE_5"
        else if higherB
            LB = f_lvl(wtV)
            pB := wtV
            bB := pivBA
            line.delete(segAB)
            label.delete(lbB)
            lbB := f_mkLab(bB, pB, f_in(LB, rBMinInput, rBMaxInput) ? "B" : "B~", dir == 1)
            segAB := f_mkSeg(bA, pA, bB, pB)
            f_buildGhost()
    if pendingReset == 0 and not na(ctrV)
        LC_ = f_lvl(ctrV)
        deepC = dir == 1 ? ctrV < p2 : ctrV > p2
        if deepC
            pendingReset := 1
            resetReason := "DEEP_C"
        else
            // Point C is terminal (DONE this bar) — locals, no state carried
            float cPrice = ctrV
            int   cBar   = pivBA
            label cLab = f_mkLab(cBar, cPrice, f_in(LC_, rCMinInput, rCMaxInput) ? "C" : "C~", dir == -1)
            line  cSeg = f_mkSeg(bB, pB, cBar, cPrice)
            aCd := true
            pendingReset := 2
            resetReason := "DONE"

// ── PER-BAR PROGRESS: breaks, targets, zone entries ──────────────────────────
// Zone entries (ote2 / oteB4 / hitM1) use wick extremes — irreversible intrabar.
// Level breaks use f_beyond — Close mode is confirmed-bar-only (C2)
if pendingReset == 0 and state == S_W2
    ext2 = dir == 1 ? low : high
    trackBest = na(w2best) or (dir == 1 ? ext2 < w2best : ext2 > w2best)
    if trackBest
        w2best := ext2
        w2bestBar := bar_index
    if not ote2
        eLvl = f_lvl(ext2)
        if eLvl >= math.min(r2MinInput, r2MaxInput)
            ote2 := true
            aOte2 := true
    // Break of point 1 before point 2 is accepted — point 2 = best low,
    // always accepted
    if not doAcc2 and f_beyond(p1)
        Lb2 = f_lvl(w2best)
        doAcc2 := true
        acc2P := w2best
        acc2B := w2bestBar
        acc2Soft := not f_in(Lb2, r2MinInput, r2MaxInput)
        acc2Brk := true

// Unified acceptance of point 2
if pendingReset == 0 and doAcc2
    p2 := acc2P
    b2 := acc2B
    lb2 := f_mkLab(b2, p2, acc2Soft ? "2~" : "2", dir == -1)
    seg12 := f_mkSeg(b1, p1, b2, p2)
    if not na(box2)
        box.set_right(box2, b2)
    // Point 3 target box (range on the 0→1 grid, yellow) + center dashed line
    if showBoxesInput
        e1 = f_fibP(r3MinInput)
        e2 = f_fibP(r3MaxInput)
        box3 := box.new(b2, math.max(e1, e2), b2 + boxExtInput, math.min(e1, e2), border_color = OTE_BORDER, bgcolor = OTE_FILL)
        array.push(aBoxes, box3)
        mid3 = f_fibP((r3MinInput + r3MaxInput) * 0.5)
        ml3 := line.new(b2, mid3, b2 + boxExtInput, mid3, color = OTE_BORDER, style = line.style_dashed)
        array.push(aLines, ml3)
    state := S_W3
    stateStartBar := bar_index
    aW2 := true
    if acc2Brk
        broke1 := true
        aBrk1 := true
    f_buildGhost()

if pendingReset == 0 and state == S_W3 and not broke1 and f_beyond(p1)
    broke1 := true
    aBrk1 := true

if pendingReset == 0 and state == S_W4 and not oteB4
    extF = f_lvl23(dir == 1 ? low : high)
    if extF >= math.min(r4MinInput, r4MaxInput)
        oteB4 := true
        aBox4 := true

if pendingReset == 0 and state == S_W5
    if not broke3 and f_beyond(p3)
        broke3 := true
        aBrk3 := true
    if not hitM1
        tgt = f_fibP(-1.0)
        hitNow = dir == 1 ? high >= tgt : low <= tgt
        if hitNow
            hitM1 := true
            aTgt := true

if pendingReset == 0 and (state == S_B or state == S_C) and f_beyond(p5)
    pendingReset := 2
    resetReason := "B_ABOVE_5"

// ── RESET / COMPLETION EXECUTION ─────────────────────────────────────────────
// Dashboard: completed 5-wave impulses
if aW5
    impulseCount += 1

if pendingReset == 1
    xl = label.new(bar_index, close, "✖", style = label.style_label_center, color = RESET_LBL_BG, textcolor = RESET_LBL_TX, size = labelSize, tooltip = "Hypothesis reset: " + resetReason)
    array.push(xLabels, xl)
    lockedChochLvl := chochLvl
    aInv := true
    // M9: Close mode fires on the confirmed close — announce on bar close
    alert("EIE: hypothesis reset — " + resetReason, confClose ? alert.freq_once_per_bar_close : alert.freq_once_per_bar)

if pendingReset == 2 and resetReason == "B_ABOVE_5"
    alert("EIE: correction dismissed (break above point 5), impulse closed as DONE", confClose ? alert.freq_once_per_bar_close : alert.freq_once_per_bar)

if pendingReset > 0
    // Cooldown applies after ANY count end: INVALID and DONE/B_ABOVE_5 (M5).
    // The CHoCH level lock (lockedChochLvl) remains INVALID-only by design
    lastResetBar := bar_index
    lastResetStr := resetReason
    f_wipe()
    seg01 := na
    seg12 := na
    seg23 := na
    seg34 := na
    seg45 := na
    seg5A := na
    segAB := na
    lb0 := na
    lb1 := na
    lb2 := na
    lb3 := na
    lb4 := na
    lb5 := na
    lbA := na
    lbB := na
    box2 := na
    ml2 := na
    box3 := na
    ml3 := na
    box4 := na
    ml4 := na
    critLn := na
    critLb := na
    p0 := na
    p1 := na
    p2 := na
    p3 := na
    p4 := na
    p5 := na
    pA := na
    pB := na
    b0 := na
    b1 := na
    b2 := na
    b3 := na
    b4 := na
    b5 := na
    bA := na
    bB := na
    chochLvl := na
    broke1 := false
    broke3 := false
    ote2 := false
    oteB4 := false
    hitM1 := false
    w2best := na
    w2bestBar := na
    dir := 0
    state := S_SCAN

// M7: deferred seed — a CHoCH break landed on the same bar as a §5.17 reset.
// The wipe above has already run; the engine is clean, seed the new count now.
// CHoCH graphics are drawn here (the persistent chLines layer survives wipes)
if seedNow
    dir := seedDir
    chochLvl := seedLvl
    p0 := seedP0
    b0 := seedB0
    state := S_CHOCH
    stateStartBar := bar_index
    if showChochInput
        color seedCol = seedDir == 1 ? bullColorInput : bearColorInput
        cl = line.new(seedSwBar, chochLvl, bar_index, chochLvl, color = seedCol, width = 1, style = line.style_dashed)
        cb = label.new(math.round((seedSwBar + bar_index) / 2), chochLvl, "CHoCH", color = color(na), textcolor = seedCol, style = seedDir == 1 ? label.style_label_down : label.style_label_up, size = labelSize)
        array.push(chLines, cl)
        array.push(chLabels, cb)
        array.push(chLvl, chochLvl)
        array.push(chBias, seedDir)
        if array.size(chLines) > maxChochInput
            line.delete(array.shift(chLines))
            label.delete(array.shift(chLabels))
            array.shift(chLvl)
            array.shift(chBias)

// ── GRAPHICS MAINTENANCE (gated: events + barstate.islast, no per-bar churn) ──
// Extend unmitigated CHoCH lines to the right — last bar only
if barstate.islast and array.size(chLines) > 0
    for i = 0 to array.size(chLines) - 1
        if array.get(chBias, i) != 0
            line.set_x2(array.get(chLines, i), bar_index + 20)

// Stretch the fib grid to the full projection width + 5 bars past C? — last bar only
// (grids are built with correct geometry at every transition; this is cosmetics)
if barstate.islast and state != S_SCAN and array.size(fLines) > 0
    ge = f_gridEnd()
    for i = 0 to array.size(fLines) - 1
        line.set_x2(array.get(fLines, i), ge)
        label.set_x(array.get(fLabels, i), ge)

// Trailing invalidation level (spec §5.16/§5.18)
float critLevel = na
if state == S_CHOCH or state == S_W2
    critLevel := p0
else if state == S_W3
    critLevel := broke1 ? p2 : p0
else if state == S_W4
    critLevel := p2
else if state == S_W5
    critLevel := broke3 ? p4 : p2
else if state >= S_A
    critLevel := p2
// Geometry updates only on level change or on the last bar
bool critChanged = not na(critLevel) and (na(critLevel[1]) or critLevel != critLevel[1])
if not na(critLevel)
    if na(critLn)
        critLn := line.new(bar_index - 1, critLevel, bar_index + 2, critLevel, color = CRIT_COLOR, style = line.style_dashed, width = 1)
        critLb := label.new(bar_index + 2, critLevel, "INVALID " + str.tostring(critLevel, format.mintick), style = label.style_label_left, color = CRIT_LBL_BG, textcolor = CRIT_COLOR, size = labelSize)
        array.push(aLines, critLn)
        array.push(aLabels, critLb)
    else if critChanged or barstate.islast
        line.set_y1(critLn, critLevel)
        line.set_y2(critLn, critLevel)
        line.set_x2(critLn, bar_index + 2)
        label.set_y(critLb, critLevel)
        label.set_x(critLb, bar_index + 2)
        label.set_text(critLb, "INVALID " + str.tostring(critLevel, format.mintick))

// ══════════════════════════════════════
// DASHBOARD
// ══════════════════════════════════════
dashPos = switch dashPosStrInput
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    "Middle Right" => position.middle_right
    => position.top_right

if showDashInput and barstate.islast
    var dashTable = table.new(dashPos, 2, 8, bgcolor = TABLE_BG, border_color = TABLE_BORDER, border_width = 1, frame_color = TABLE_BORDER, frame_width = 1)

    string stateStr = switch state
        S_SCAN  => "Scanning"
        S_CHOCH => "CHoCH · wait 1"
        S_W2    => "Wave 2"
        S_W3    => "Wave 3"
        S_W4    => "Wave 4"
        S_W5    => "Wave 5"
        S_A     => "Corr · A"
        S_B     => "Corr · B"
        S_C     => "Corr · C"
        => "—"
    color stateCol = state == S_SCAN ? TEXT_MUTED : NEUTRAL_TEXT

    string dirStr = dir == 1 ? "Long" : dir == -1 ? "Short" : "—"
    color  dirCol = dir == 1 ? BULL_TEXT : dir == -1 ? BEAR_TEXT : TEXT_MUTED

    string critStr = na(critLevel) ? "—" : str.tostring(critLevel, format.mintick)
    color  critCol = na(critLevel) ? TEXT_MUTED : BEAR_TEXT

    table.cell(dashTable, 0, 0, "◆ EIE", text_color = HEADER_TEXT, bgcolor = HEADER_BG, text_size = dashFontSize, text_halign = text.align_center)
    table.merge_cells(dashTable, 0, 0, 1, 0)

    table.cell(dashTable, 0, 1, "State", text_color = TEXT_MUTED, text_size = dashFontSize, tooltip = "Current phase of the impulse count state machine")
    table.cell(dashTable, 1, 1, stateStr, text_color = stateCol, text_size = dashFontSize)

    table.cell(dashTable, 0, 2, "Direction", text_color = TEXT_MUTED, text_size = dashFontSize, tooltip = "Direction of the active impulse hypothesis")
    table.cell(dashTable, 1, 2, dirStr, text_color = dirCol, text_size = dashFontSize)

    table.cell(dashTable, 0, 3, "Invalidation", text_color = TEXT_MUTED, text_size = dashFontSize, tooltip = "Trailing invalidation level — a break beyond it resets the hypothesis")
    table.cell(dashTable, 1, 3, critStr, text_color = critCol, text_size = dashFontSize)

    table.cell(dashTable, 0, 4, "Last Reset", text_color = TEXT_MUTED, text_size = dashFontSize, tooltip = "Reason the previous count ended (INVALID reason, DONE or B_ABOVE_5).\nResets on chart reload")
    table.cell(dashTable, 1, 4, lastResetStr, text_color = TEXT_COLOR, text_size = dashFontSize)

    table.cell(dashTable, 0, 5, "Impulses", text_color = TEXT_MUTED, text_size = dashFontSize, tooltip = "Completed 5-wave impulses (point 5 accepted) on loaded history.\nResets on chart reload")
    table.cell(dashTable, 1, 5, str.tostring(impulseCount), text_color = TEXT_COLOR, text_size = dashFontSize)

    table.cell(dashTable, 0, 6, "TF", text_color = TEXT_MUTED, text_size = dashFontSize, tooltip = "Chart timeframe")
    table.cell(dashTable, 1, 6, timeframe.period, text_color = TEXT_COLOR, text_size = dashFontSize)

    table.cell(dashTable, 0, 7, "Version", text_color = TEXT_MUTED, text_size = dashFontSizeSub)
    table.cell(dashTable, 1, 7, INDICATOR_VERSION, text_color = TEXT_MUTED, text_size = dashFontSizeSub)

// ══════════════════════════════════════
// WATERMARK — WillyAlgoTrader
// ══════════════════════════════════════
if barstate.islast and showWatermarkInput
    var wmTable = table.new(
         position     = position.bottom_center,
         columns      = 1,
         rows         = 1,
         bgcolor      = color.new(color.black, 100),
         border_color = color.new(color.black, 100),
         border_width = 0,
         frame_color  = color.new(color.black, 100),
         frame_width  = 0)
    table.cell(wmTable, 0, 0, "WillyAlgoTrader",
         text_color  = WM_COLOR,
         text_size   = size.normal,
         text_halign = text.align_center,
         bgcolor     = color.new(color.black, 100))

// ══════════════════════════════════════
// ALERTS (spec §7)
// ══════════════════════════════════════
// NOTE (deferred C1/C3): alertcondition() mechanism kept per current scope;
// migration to dynamic alert() with ticker/TF/price is a separate pass
alertcondition(aChoch, "1. CHoCH + projection",   "EIE: CHoCH confirmed, movement projection built")
alertcondition(aOte2,  "2. Price in W2 OTE",      "EIE: price entered the point 2 OTE zone")
alertcondition(aW2,    "3. Point 2 accepted",     "EIE: point 2 confirmed")
alertcondition(aBrk1,  "4. Break of point 1",     "EIE: point 1 broken — W3 active")
alertcondition(aBox4,  "5. Price in W4 box",      "EIE: price entered the point 4 box")
alertcondition(aBrk3,  "6. Break of point 3",     "EIE: point 3 broken — W5 active")
alertcondition(aTgt,   "7. Target -1.0",          "EIE: -1.0 target reached")
alertcondition(aW5,    "8. Impulse complete",     "EIE: point 5 locked, impulse complete")
alertcondition(aCd,    "9. Target C",             "EIE: point C accepted, correction complete")
alertcondition(aInv,   "10. Invalidation",        "EIE: hypothesis invalidated")
````
