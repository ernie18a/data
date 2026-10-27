# Confluence Zone Engine [CZE]

- url: https://www.tradingview.com/script/kdjNWDiE-Confluence-Zone-Engine-CZE/
- type: indicator
- pine_id: PUB;957e47cb02594e8b9d59378c024198a2
- version: 4.0

## Description

# Confluence Zone Engine [CZE]

A structural analysis indicator that identifies support and resistance zones by clustering Anchored VWAPs and Anchored Volume Profile levels across the chart timeframe and up to three higher timeframes. Each zone is rated 1 to 5 stars based on how many independent sources cluster at the level and how diverse those sources are.

This is a structural analysis tool. It marks where multiple independent technical references agree at a price. It does not place trades or suggest entries, exits, targets, stops, or position sizes.

---

## What this script does

The engine runs a six-stage pipeline on every confirmed bar:

**Stage 1 — Pivot detection.** Detects pivot highs and pivot lows at Fibonacci-spaced lengths (3, 5, 8, 13, 21, 34, 55, 89). Each pivot becomes an "anchor" point. Default enabled tiers are 8, 21, and 34 — selected to give fast / medium / slow coverage without redundancy. The full Fibonacci set is configurable.

**Stage 2 — Per-anchor calculations.** For every anchor, the engine maintains:
- An Anchored VWAP (volume-weighted average price since the anchor bar)
- An Anchored Volume Profile, which produces a Point of Control (POC = most-traded price since anchor) and a Value Area (VAH and VAL = upper and lower edges of the 70% volume zone)

So a single pivot generates up to 4 contributor levels: AVWAP, POC, VAH, VAL.

**Stage 3 — Higher-timeframe replication.** The same pipeline (stages 1 and 2) re-runs on up to three configurable higher timeframes via non-repainting `request.security` calls. This produces a multi-timeframe view of structural anchors — pivots and AVWAPs from a 1H chart inform what the 5m engine treats as a higher-timeframe reference.

**Stage 4 — Cluster building.** All contributor levels from all enabled timeframes are collected. The cluster builder walks them in price order, merging any that fall within a configurable tolerance (default 0.08% of current price; preset-adjusted per asset class). A cluster with at least the minimum-count threshold becomes a candidate zone.

**Stage 5 — Star rating.** Each zone is rated 1 to 5 stars based on:
- Total contributor count
- Source-type diversity (how many of the 4 source categories — PH-AVWAPs, PL-AVWAPs, POCs, VAH/VAL — are present)
- HTF agreement (whether contributors from multiple timeframes align)

A "Premium" tier flag fires when top stars combine with HTF agreement.

**Stage 6 — State machine.** Each zone is tracked through a lifecycle:
- **Active** (forming, amber): the zone is currently accumulating contributors
- **Pending** (blue): contributor activity has paused; waiting for price to resolve the level
- **Resolved Support** (green), **Resistance** (red), or **Chop** (gray): determined by whether price moved decisively up, decisively down, or stayed range-bound after the zone activated
- **Tested** (dashed border): price entered the resolved zone but has not closed past the defending edge
- **Broken** (dashed orange + "Broken" label): price has closed past the defending edge
- **Flipped**: if a Broken state confirms over multiple closes past a threshold, the zone repaints to the opposite role (broken Resistance becomes Support, broken Support becomes Resistance)

---

## Why this indicator is original (not a simple mashup)

This is not "AVWAP indicator + Volume Profile indicator + multi-timeframe wrapper." Three design choices distinguish it from existing public indicators:

**1. Anchored at every Fibonacci pivot, not at a single user-selected point.** Standard AVWAP indicators require the user to manually click an anchor point. Standard Volume Profile indicators use either a fixed session or a single anchor. This engine automatically detects pivots at multiple Fibonacci lengths and runs an AVWAP + Volume Profile from each one. The number of active anchors at any time is typically 6 to 20, generating 24 to 80 contributor levels — far more than a manually-anchored tool can produce.

**2. Cross-timeframe clustering, not separate per-timeframe overlays.** The engine does not draw 5 separate AVWAPs from a 1H chart, plus 5 from a 4H, plus 5 from a daily. Instead, levels from all timeframes are collected into one pool and clustered in price space. A 1H AVWAP at 23,720 and a daily POC at 23,718 merge into a single zone marked as "two contributors from two timeframes." This produces structural information neither timeframe shows alone.

**3. Compositional bias from the contributor mix.** The cluster builder records *which type* of contributor formed each zone — pivot-high AVWAPs (trapped sellers' breakevens), pivot-low AVWAPs (trapped buyers' breakevens), POCs (acceptance), VAH or VAL (fair-value edges). The directional implication of each type is summed into a "compositional bias" score. A zone built mostly from PL-AVWAPs and VAL contributions leans support; one built from PH-AVWAPs and VAH contributions leans resistance. This is an analytical lens not present in standard S/R indicators, which generally treat all levels as direction-agnostic.

---

## Mashup justification — how the components work together

The four classes of technical analysis used (pivots, AVWAP, Volume Profile, multi-timeframe analysis) are not chosen arbitrarily. Each contributes a dimension the others do not, and the value comes from how they interact:

**Pivots provide the anchors.** Without pivots, AVWAP needs a manual anchor and Volume Profile needs an arbitrary session. Pivots at multiple Fibonacci lengths give the engine *automatic structural anchors* spanning timescales — short-term swings, intraday swings, session-level swings. The Fibonacci spacing (3, 5, 8, 13, 21, 34, 55, 89) ensures the anchors are non-redundant: each tier has a different bar requirement and catches different swings.

**AVWAP measures participant breakeven from each anchor.** This is the "where might trapped participants defend" dimension. An AVWAP from a pivot high is the volume-weighted breakeven for everyone who entered after that high (mostly net-short positions). An AVWAP from a pivot low is the breakeven for everyone who entered after that low (mostly net-long). When price returns to one of these AVWAPs, structurally those participants are at breakeven and have incentive to act.

**Volume Profile measures acceptance from each anchor.** This is the "what price has been most-accepted by volume" dimension. POC is the most-traded price; VAH/VAL are the edges of the 70%-volume range. AVWAP and POC measure different things — average price vs most-accepted price — and frequently disagree. When they *do* agree at a level, that's two independent signals saying "this price matters."

**Multi-timeframe replication tests for structural agreement.** A zone that exists only on the chart timeframe is one-timeframe noise. A zone where chart-TF contributors *agree with* higher-TF contributors at the same price is structural — the same level shows up no matter which timescale you measure from. The engine treats HTF agreement as a primary input to the star rating: HTF-aligned zones can earn an extra star (capped to prevent inflation).

**The clustering is where the value emerges.** Individually, none of these components produce reliable levels. AVWAP gets broken constantly. POC migrates. Pivot levels get violated. But when the engine sees that the 21-pivot AVWAP, the 34-pivot POC, the 8-pivot VAL, and a 1H AVWAP all land within 0.08% of each other at the same price, that's a confluence of independent references measuring different things — and that *coincidence* is what produces structural significance. The star rating quantifies how much agreement is present.

This is the mashup's purpose: not to combine indicators for their own sake, but to use convergence as a filter that turns individually noisy components into a rated structural signal.

---

## How to use the indicator

**Step 1: Apply to any chart timeframe.** All settings have sensible defaults. The asset-class preset (NSE Index Futures, NSE Stock, US Future, US ETF, US Stock, Commodity, Crypto, or Custom) auto-adjusts cluster tolerance and pivot defaults. Auto-selected higher timeframes scale with the chart — a 5m chart defaults to 15m/60m/240m HTFs, while a daily chart defaults to weekly/monthly HTFs.

**Step 2: Read the status panel (bottom-right).** This is the actionable summary:
- "Sup" row: nearest resolved Support below current price, with point distance
- "Res" row: nearest resolved Resistance above current price, with point distance
- "Top zone": the highest-rated zone overall
- "Data": indicator health (OK / Degraded / Critical) — if the underlying volume data is sparse, ratings are capped

**Step 3: Scan the chart for "Broken" labels.** Any zone in dashed orange with a "Broken" label is currently being violated. Watch for either recovery (border returns solid) or polarity flip confirmation (zone repaints to opposite role).

**Step 4: Find the active amber zone.** This is the current forming confluence. Look at the triangle shape: ▲ means the composition leans support, ▼ means it leans resistance, ◆ means neutral. The number next to the triangle is the star rating. A premium "★" prefix means HTF agreement is present.

**Step 5: Use the Major S/R lines as forward references.** Bold horizontal lines mark the top 2 strongest support levels below current price and top 2 strongest resistance levels above. Labels show price, stars, and distance.

**Step 6: Use the Range band as context.** The translucent aqua band marks the recent trading envelope (default last 50 bars). A narrow band means consolidation; a wide band means trending.

**Step 7: Hover any element for the full breakdown.** Every box, triangle, and line has a tooltip showing total contributors, type counts, HTF alignment, state, and history.

---

## How NOT to use the indicator

- **Do not treat the bias arrow as a trade signal.** It is a compositional description of contributors, not a directional forecast. A zone with a ▲ bias can still resolve as resistance.
- **Do not treat a "Broken" label as a trade trigger.** It tells you a known level is failing — not that you should enter a position in either direction.
- **Do not assume higher stars mean higher profit probability.** Stars measure the diversity and density of contributors, not historical performance or expected return.
- **Do not rely on it for low-volume instruments.** If the data-health badge shows "Degraded" or "Critical," the engine has capped ratings and may suppress zones entirely. This is a feature; the indicator is most accurate on liquid, volume-rich instruments (index futures, large-cap stocks, major crypto).

---

## How to read the star rating

Stars are a descriptive summary of confluence quality. They are not a probability of profit.

- 1 to 2 stars: minimum cluster; one or two source types. Background context.
- 3 stars: at least 5 contributors with 2 or more source types. Recurring intraday levels.
- 4 stars: at least 7 contributors with 3 or more source types, OR 3-star with HTF agreement.
- 5 stars: at least 10 contributors with all 4 source types present. Often boosted by HTF alignment.

By default, only 4-star and 5-star zones get triangle markers and qualify for Top-N or Major S/R lines. This is adjustable.

---

## Visual primitives

- **Confluence zones** — colored boxes marking each cluster. Boxes recolor as zones resolve. Border style indicates compromised state.
- **Triangle markers** — ▲ ▼ ◆ at each formation bar. Shape encodes direction. Color encodes lifecycle state.
- **Top-N S/R lines** — top 4 resolved zones by strength and recency project forward.
- **HTF confluence bands** — semi-transparent bands per higher timeframe (cyan, purple, orange).
- **Major S/R lines** — bold lines for top 2 supports below and top 2 resistances above current price.
- **Range band** — translucent band marking recent trading range with HI / LO labels.
- **Current price line** — thin dotted line at current price.
- **Status panel** — bottom-right summary.

---

## Technical notes

- Pine Script v6
- Non-repainting: all `request.security` calls use `barmerge.lookahead_off`
- Asset-class presets adjust cluster tolerance and pivot defaults
- Built-in data-integrity layer caps ratings when volume data is sparse or stale
- Seven alert conditions: new zone formed, high-quality (4 to 5 star) zone, HTF aligned, price entered support, price entered resistance, data health degraded, polarity flip

---

## Important risk disclosure

This indicator is provided for educational and informational purposes only and is not financial advice. Trading and investing involve substantial risk of loss, including the possible loss of all invested capital. The zones, ratings, bias shapes, and lines are descriptive summaries of structural confluence — they are not predictions of future price movement, indications of profitability, win rate, or expected return.

No backtested or hypothetical performance is claimed or implied. Past zones identified by the indicator are not indicative of future results.

You are solely responsible for any decisions you make. Consult a qualified, licensed financial advisor before trading. Past performance does not guarantee future results.

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// CONFLUENCE ZONE ENGINE [CZE] — PERFORMANCE-OPTIMIZED BUILD
// Multi-Timeframe Anchored VWAP & Volume Profile Confluence Analysis
// ────────────────────────────────────────────────────────────────────────────
// OPTIMIZATION CHANGELOG (vs original)
//   [OPT-1] HTF engine no longer allocates/shifts the flat hBins volume-profile
//           array when enableHTFAVP is OFF (the default). Previously ~25 pushes
//           per anchor × up to 8 anchors × 3 HTFs were created and shifted every
//           bar for an array that was never read. This was the single largest
//           per-bar allocation churn in the script.
//   [OPT-2] Chart-TF anchor bins (aBins) are only allocated/shifted when useAVP
//           is ON, for the same reason.
//   [OPT-3] The HTF stalled-feed detector replaced its explicit 50-iteration
//           historical loop with math.sum(), which is internally O(1) amortized.
//   [OPT-4] Heavy redraw sections (HTF bands, Top-N S/R, Major S/R, Range band)
//           rebuild only on bar open / bar close instead of on every realtime
//           tick. On a live chart barstate.islast fires on every tick, so the
//           clustering + insertion sorts in those sections used to re-run many
//           times per second. The cheap per-tick overlays (price line, badge,
//           legend) still update every tick.
//
//   [OPT-5] HTF level transport returns typed arrays directly from
//           request.security (Pine v6 tuple-of-arrays) instead of a delimited
//           string. This removes the per-bar str.tostring pack in the HTF
//           context AND — more importantly — the str.split + str.tonumber parse
//           that ran on EVERY chart bar over up to ~24 levels × 3 HTFs. That
//           per-chart-bar string parse was the largest remaining hot path after
//           OPT-1..4. Same levels, values and ordering; transport only.
//
//   Behavior is otherwise identical to the original. The 3 stalled-feed
//   request.security() calls were deliberately NOT folded into the 3 engine
//   calls (6 → 3): that fold requires hoisting the engine definition above the
//   data-integrity section, which (a) cannot be statically compile-verified here
//   and (b) would slightly alter the HTF health-detail string in the rare
//   volume-unreliable case. It saves load-time dispatch budget, not per-bar
//   runtime, so it was not worth the structural risk. Ask if you want it.
// ══════════════════════════════════════════════════════════════════════════════
//
// UPDATE — HONESTY & EVIDENCE
//   [EV-1] New optional "Star weighting: Evidence-weighted" mode (group 17).
//          The classic star formula stays the default and is unchanged. In the
//          new mode a zone's star is nudged at most ±1 by the MEASURED
//          feature-lift (held% with vs without a feature), and only once a
//          feature has enough resolved tests — otherwise it falls back to the
//          classic rating. This finally closes the loop the feature-lift table
//          was built to inform, without letting presentation drive measurement.
//   [EV-2] Calibration bucketing now explicitly uses the fixed classic rating
//          (star_rating_base), so respect stats are always measured against the
//          unbiased yardstick and the evidence weighting can never feed on itself.
//   [EV-3] The respect-calibration base row now shows a 95% Wilson interval too,
//          matching the per-star buckets (was a point estimate).
//   [EV-4] New optional "Refresh MTF alignment on re-touch" toggle (default OFF,
//          original behaviour) so a zone can shed a stale [+NTF] boost after the
//          higher timeframes move away from it.
//   [LOAD-1] calc_bars_count now caps computation to the most recent 5000 bars,
//          and the line/label/box budgets are trimmed 500 → 350/350/150. Because
//          the 3 heavy MTF engines run once per bar, load time scales with bar
//          count — this is the single biggest load win. Recent zones and signals
//          are identical; only calibration depth on very old bars is reduced.
//          (The 6→3 request.security fold noted below was reassessed and left
//          alone: the stalled-feed count feeds health → avwapAllowed, which gates
//          the engine call, so folding is circular and would risk behaviour or
//          even add load. Those 3 checks are trivial compute; the win is here.)
//   Non-repaint discipline and per-bar efficiency are unchanged; the evidence
//   weights read last bar's committed tallies, so no same-bar feedback.
//
// UPDATE — ROBUSTNESS, NEUTRALITY & TREND-READABLE VISUALS
//   [FIX-1] Volume-availability ratio was integer division (volPresentCnt /
//           volTotalCnt, both int), so a SINGLE zero/na-volume bar in history
//           truncated the ratio to 0 and silently disabled the whole engine
//           (no AVWAPs, no zones) on any instrument that isn't volume-complete.
//           Now a float ratio — the engine runs correctly on stocks, crypto and
//           any feed with the odd empty-volume bar, exactly as volume-complete
//           feeds already did.
//   [FIX-2] The three HTF transport arrays are now guarded so a bar where the
//           higher timeframe has no data yet (newly listed symbol, short history,
//           high chart TF) can never call array.size() on an na array — removes a
//           latent "cannot call array method on na" runtime error off the author's
//           long-history default.
//   [OPT-6] Cluster builder sorts the per-bar level arrays in place instead of
//           deep-copying them first (two array allocations + copies removed on
//           every confirmed bar), the HTF-level contribution is skipped on
//           unconfirmed realtime ticks (it is only consumed on close), and a
//           per-anchor loop invariant was hoisted out of the loop. No behaviour
//           or visual change — pure load/tick-latency win.
//   [NEUTRAL-1] Ships market-neutral: the asset-class preset now defaults to
//           "Custom" (was an India-index-futures preset) and the last home-market
//           wording in a tooltip was genericized. All data still reads the chart's
//           OWN symbol (syminfo.tickerid) — no instrument was ever hardcoded.
//   [VIS-1] Strength now reads at a glance: a resolved/active zone's FILL opacity
//           scales with its star rating (5★ zones are visibly more solid than 2★),
//           so the strongest levels dominate the eye. HTF confluence bands darken
//           with the number of timeframes stacked in them (was a flat opacity).
//   [VIS-2] New optional "Directional bias ribbon" (default OFF): a faint
//           green/red background tint of the current structural lean (price vs the
//           nearest support/resistance), for a chart-wide movement-trend read.
//   All non-repaint discipline and every default number are unchanged.
//
// WHAT THIS INDICATOR DOES
//
// Confluence Zone Engine identifies support and resistance zones using the
// confluence of multiple Anchored VWAPs and Anchored Volume Profiles across
// the current chart timeframe and higher timeframes.
//
// REPAINT / NON-REPAINT BEHAVIOUR
//
// Zones form, transition and resolve on BAR CLOSE only (all state logic is gated
// on barstate.isconfirmed) and every higher-timeframe request.security call uses
// barmerge.lookahead_off, so confirmed history does not repaint. Because zones are
// anchored to CONFIRMED pivots, a confluence marker appears only after its pivot
// bar is confirmed (a lag of the pivot length), not on the live bar that made the
// extreme — this is expected, non-repainting behaviour, not hindsight redrawing.
// The current-bar "active" zone and the dashboards update live and settle on close.
//
// IMPORTANT RISK DISCLOSURE
//
// This indicator is provided for educational and informational purposes only.
// It is NOT financial advice, investment advice, a trading system, or a
// recommendation to buy, sell, or hold any financial instrument. Trading and
// investing involve substantial risk of loss. You are solely responsible for
// any trading decisions you make.
// ════════════════════════════════════════════════════════════════════════════

//@version=6
// LOAD-TIME BUDGET
//   calc_bars_count limits computation to the most recent N bars. The heavy MTF
//   engines run once per bar, so load time scales with bar count — capping it is
//   the single biggest, safest load win. Recent zones and signals are IDENTICAL;
//   only calibration depth on very old history shrinks. RAISE it (e.g. 10000 or 0
//   for unlimited) for deeper calibration; LOWER it for faster load.
//   Drawing caps trimmed 500 → 350/350/150 (well above real usage; raise them if
//   very dense settings ever clip drawings).
//   max_bars_back is set to cover the whole computed window: a still-relevant zone
//   can be thousands of bars old, and its S/R line is drawn from that origin bar,
//   so the history buffer must reach back at least as far as calc_bars_count. Keep
//   these two in step (buffer ≥ window) or old-zone lines throw "historical offset
//   beyond buffer" at runtime. Both are capped at Pine's max of 5000.
indicator(
     "Confluence Zone Engine [CZE]",
     shorttitle = "CZE",
     overlay = true,
     max_lines_count = 350,
     max_labels_count = 350,
     max_boxes_count = 150,
     max_bars_back  = 5000,
     calc_bars_count = 4800
)
// ============================================================
// DATA SOURCE
// ============================================================
gSrc = "1 · Data Source"
srcPrice = input.source(hlc3, "Typical-price source", group = gSrc, tooltip = "Price series used as the typical price for the anchored VWAP leg on the chart timeframe. Default hlc3 (the standard volume-profile convention) keeps default behaviour unchanged. You can switch to close, hl2, ohlc4 etc. to retarget the engine for other instruments or data feeds. Pivot detection and the volume-profile range always use the bar high/low, so structure stays intact regardless of this choice.")

// ============================================================
// ASSET CLASS — sets per-class tuning defaults
// ============================================================
gAC = "2 · Asset Class"
assetClass = input.string("Custom", "Asset class", options = ["NSE_INDEX_FUT", "NSE_STOCK", "US_FUT", "US_ETF", "US_STOCK", "COMMODITY", "CRYPTO", "Custom"], group = gAC, tooltip = "Selects per-class default tuning for confluence tolerance, minimum zone strength, MTF alignment tolerance, and zone-merge tolerance. Default 'Custom' is market-neutral and uses the manual tuning below (whose defaults match a liquid index-futures profile); pick a class to load its preset and enable the class-match health check.\n\nNSE_INDEX_FUT: NSE Index Futures\nNSE_STOCK: NSE Single Stocks\nUS_FUT: CME Index/Bond Futures\nUS_ETF: US ETFs\nUS_STOCK: US Single Stocks\nCOMMODITY: COMEX/NYMEX\nCRYPTO: Crypto Perpetuals\nCustom: bypasses presets, uses your manual tuning")
acStrictGuard = input.bool(false, "Strict guard: warn on asset-class mismatch", group = gAC, tooltip = "When ON: forex, options, spot indices, and other volume-less symbols will display a warning badge. The indicator still runs (no runtime error), but warns that signals on volume-less instruments may be unreliable.")

// ============================================================
// VISUAL MODE — controls rendering style for HTF context and zones
// ============================================================
gVis = "3 · Visual Mode"
visualMode = input.string("S/R lines + markers (default)", "Visual mode",
     options = ["S/R lines + markers (default)", "Detailed lines", "Both"],
     group = gVis,
     tooltip = "Controls how confluence zones are rendered.\n\nS/R lines + markers (default): clean view — each confluence zone is shown as a thin horizontal price line anchored at the bar where the confluence formed, extending forward in time. A small marker at the formation bar shows direction (▲ Support, ▼ Resistance, ◆ Chop, ● Active, ◌ Pending) and star count. HTF context shown as semi-transparent horizontal bands. Recommended for most users.\n\nDetailed lines: classic view — every HTF anchor's AVWAP / POC / VAH-VAL drawn as its own line, plus naked POC lines. Also shows the original filled zone boxes. Most informative but visually dense.\n\nBoth: shows S/R lines + markers AND the detailed lines together.")

showMarkers = input.bool(true, "Show confluence markers", group = gVis, tooltip = "When ON, a tiny colored triangle is drawn AT the bar where each strong confluence formed. The triangle direction encodes role (▲ support-leaning or resolved support, ▼ resistance-leaning or resolved resistance, ◆ neutral or chop) and the color encodes lifecycle state (amber active, blue pending, green support, red resistance, gray chop). A companion star number sits next to the triangle for readability.")
markersMinStars = input.int(4, "Markers: minimum stars to show", minval = 1, maxval = 5, group = gVis, tooltip = "Only confluence events at this star rating or higher get a triangle marker on the chart. Default 4 — shows only the strongest events (4★ and 5★). Set to 1 to mark every confluence (cluttered but complete), or 5 to mark only top-tier events. Lower-strength zones still exist in the engine and contribute to tooltips and the data window — they just don't get a triangle.")
showSRLines = input.bool(true, "Show S/R lines (top zones only)", group = gVis, tooltip = "When ON, the most relevant resolved Support and Resistance zones (not Chop) project as horizontal price lines. Only the top N zones by strength + recency get lines — this prevents clutter while highlighting the levels that matter NOW. Confluence triangles still appear on qualifying zones.")
srLinesTopN = input.int(4, "S/R lines: top N to show", minval = 1, maxval = 10, group = gVis, tooltip = "How many of the most recent + strongest resolved Support/Resistance zones get an extending line. Default 4. Older or weaker zones are still marked by their confluence circles but won't have a projected line. Tighter values = cleaner chart.")
srLinesMinStars = input.int(4, "S/R lines: minimum stars to qualify", minval = 1, maxval = 5, group = gVis, tooltip = "Only zones at this star rating or higher will compete for an S/R line slot. Default 4 — eliminates 1-3★ noise from being eligible for the line treatment.")
srLineExtendBars = input.int(50, "S/R line extension (bars past current)", minval = 0, maxval = 200, group = gVis, tooltip = "How far past the current bar each S/R line extends. Line starts at the zone's last-reaction bar and extends this many bars forward. Default 50.")
srLinesIncludeChop = input.bool(false, "Include Chop zones in S/R lines?", group = gVis, tooltip = "By default Chop zones do not get S/R lines (they didn't establish a clear role). Enable this if you want Chop levels also drawn as gray lines.")

showHTFBands = input.bool(true, "Show HTF confluence bands", group = gVis, tooltip = "When ON, each higher timeframe's clustered levels render as a semi-transparent horizontal band coloured by HTF. The band is a thin reference strip, not a full background fill.")
htfBandTolerance = input.float(0.15, "HTF band cluster tolerance (% of price)", minval = 0.05, maxval = 1.0, step = 0.05, group = gVis, tooltip = "How close HTF levels (within one HTF) must be to merge into a single band. Wider = fewer, broader bands; tighter = more, narrower bands.")
htfBandTransparency = input.int(90, "HTF band transparency (0-100)", minval = 70, maxval = 99, group = gVis, tooltip = "Higher = more transparent. Default 90 keeps bands as a subtle background hint that doesn't obscure price.")
htfBandMaxPerTF = input.int(2, "Max HTF bands per timeframe", minval = 1, maxval = 5, group = gVis, tooltip = "Cap on how many of the strongest bands to draw per HTF. Default 2 keeps the chart uncluttered.")
htfBandExtendBars = input.int(20, "HTF band extension (bars)", minval = 5, maxval = 100, group = gVis, tooltip = "How far to the right the HTF bands extend past the current bar. The bands also start a short distance behind the current bar (5x this value back). Lower = less chart coverage.")

// ────────────────────────────────────────────────────────────────
// Headline answers
// ────────────────────────────────────────────────────────────────
gAns = "4 · Key Levels & Range"
showRangeBand     = input.bool(true, "Show Movement Range band",        group = gAns, tooltip = "Answers \"What is the zone of movement?\" — draws a translucent horizontal band marking the recent range (high to low over the last N bars), with labels at top and bottom showing the range edges and width in points/percent. Set rangeBandBars below to control the lookback.")
rangeBandBars     = input.int(50, "Range band: bars to look back",      minval = 10, maxval = 500, group = gAns, tooltip = "How many bars back to measure the recent price range. Default 50 — captures the immediate trading range without being too historical. Increase for higher-timeframe ranges.")
rangeBandTransp   = input.int(92, "Range band transparency (0-100)",    minval = 70, maxval = 99, group = gAns, tooltip = "Higher = more transparent. Default 92 keeps the band as a very subtle background reference.")

showMajorSR       = input.bool(true, "Show Major S/R lines (top 2 each)", group = gAns, tooltip = "Answers \"Where are the major support and resistance?\" — draws bold horizontal lines at the top 2 strongest support levels below current price and top 2 strongest resistance levels above. Labels show price, star rating, and distance from current price. This is the cleanest answer; if you want more detail use the existing 'Top-N S/R lines' setting.")
majorSRMinStars   = input.int(4, "Major S/R: minimum stars",            minval = 1, maxval = 5, group = gAns, tooltip = "Only zones at this star rating or higher qualify as major S/R. Default 4 — only meaningful levels get the bold line treatment.")

showPriceLine     = input.bool(true, "Show current price line",          group = gAns, tooltip = "Draws a thin dotted horizontal line at current price extending across the visible chart area, with a small label at the right showing the price. Makes it instantly clear where price is relative to the Major S/R lines and zones. Off by default if you find it redundant with TradingView's built-in price line.")

// ────────────────────────────────────────────────────────────────

// Resolve visual mode toggles
bool vmZones    = visualMode == "S/R lines + markers (default)" or visualMode == "Both"
bool vmLines    = visualMode == "Detailed lines" or visualMode == "Both"

// ============================================================
// PIVOT TIERS (Current Timeframe)
// ============================================================
g1 = "5 · Current-TF Pivots"
use3   = input.bool(false, "N=3  Micro",            group = g1)
use5   = input.bool(false, "N=5  Short-term",       group = g1)
use8   = input.bool(true,  "N=8  Intraday",         group = g1)
use13  = input.bool(false, "N=13 Intraday-Swing",   group = g1)
use21  = input.bool(true,  "N=21 Swing",            group = g1)
use34  = input.bool(true,  "N=34 Structural",       group = g1)
use55  = input.bool(false, "N=55 Major",            group = g1)
use89  = input.bool(false, "N=89 Macro",            group = g1)

// ============================================================
// MTF SETTINGS
// ============================================================
gMTF = "6 · Higher-Timeframe Levels"
useMTF      = input.bool(true,  "Enable MTF analysis", group = gMTF, tooltip = "Master toggle for the higher-timeframe analysis layer. When OFF, only current-TF pivots contribute to confluence — simpler chart, less context.")
mtfMode     = input.string("Auto", "HTF selection", options = ["Auto", "Manual"], group = gMTF, tooltip = "Auto picks HTFs based on chart TF. Manual uses the values below.")
maxAnchorsHTF = input.int(1, "Max active HTF anchors per side per tier", minval = 1, maxval = 3, group = gMTF, tooltip = "HTF engine runs full Fibonacci pivots on each HTF. This caps anchors per side per tier per HTF. Default 1 (tighter than chart-TF default of 2) because HTF anchors persist longer.")
maxHTFAnchorsHardCap = input.int(8, "Hard cap on active HTF anchors per HTF", minval = 4, maxval = 16, group = gMTF, tooltip = "Regardless of tier toggles, no more than this many anchors stay active per HTF. Prevents anchor accumulation from impacting runtime. Default 8.")
enableHTFAVP         = input.bool(false, "Compute HTF Anchored Volume Profile (POC/VAH/VAL)", group = gMTF, tooltip = "When ON, each HTF anchor maintains its own full Volume Profile (POC/VAH/VAL). Adds genuine cross-TF VP confluence. However, the cumulative volume distribution across multiple HTFs × multiple anchors × many bins × thousands of HTF bars can be intensive. Default OFF.\n\nWhen OFF, HTF still contributes pivot-anchored AVWAPs. Chart-TF still has its full Volume Profile. You lose only cross-TF VP confluence, not core functionality.\n\nIF YOU TURN THIS ON: also lower avpBins to 15 (Anchored Volume Profile group), shrink your chart's loaded history range, and consider disabling HTF3 if needed.")

useHTF1     = input.bool(true,  "Enable HTF-1", group = gMTF)
htf1Manual  = input.timeframe("15", "HTF-1 (manual)", group = gMTF)
htf1Color   = input.color(color.new(color.aqua, 0), "HTF-1 color", group = gMTF)

useHTF2     = input.bool(true,  "Enable HTF-2", group = gMTF)
htf2Manual  = input.timeframe("60", "HTF-2 (manual)", group = gMTF)
htf2Color   = input.color(#C77DFF, "HTF-2 color", group = gMTF)

useHTF3     = input.bool(true,  "Enable HTF-3", group = gMTF)
htf3Manual  = input.timeframe("240", "HTF-3 (manual)", group = gMTF)
htf3Color   = input.color(#FFB74D, "HTF-3 color", group = gMTF)

mtfBoostStars = input.bool(true, "Boost zone stars on MTF alignment", group = gMTF, tooltip = "When a zone has HTFs agreeing with it, add stars to its rating. Off = HTF only used for clustering, not for boosting visual strength.")
mtfBoostMode = input.string("Capped (+1 max)", "MTF boost mode",
     options = ["Capped (+1 max)", "Full (+N for N HTFs)", "Off"],
     group = gMTF,
     tooltip = "Controls how much HTF alignment can raise a zone's star rating.\n\nCapped (+1 max) — DEFAULT: even if all 3 HTFs agree, only +1 star is added. Keeps 5★ ratings rare and meaningful. Recommended.\n\nFull (+N for N HTFs): each aligned HTF adds 1 star (legacy behavior). Can quickly inflate all zones to 5★ since the engine often finds HTF alignment.\n\nOff: HTF alignment is reported on the label (the [+NTF] tag) but does not change the star rating. Stars then reflect chart-TF confluence quality alone.")
mtfAlignTol   = input.float(0.20, "MTF alignment tolerance (%)", minval = 0.05, maxval = 2.0, step = 0.05, group = gMTF, tooltip = "How close an HTF level must be (% of price) to count as aligned with a current-TF zone. Larger = more zones flagged as MTF-aligned but with looser fit.")
showHTFLines  = input.bool(false,  "Show HTF reference lines", group = gMTF, tooltip = "Draws horizontal lines for every active HTF anchor's AVWAP (and POC/VA if those toggles are on). Default OFF — these lines are visually dense; users wanting per-anchor detail can enable. Off keeps the chart clean with just zones and confluence circles.")
htfLineWidth  = input.int(2, "HTF line width", minval = 1, maxval = 4, group = gMTF, tooltip = "Thicker lines stay visible behind zone fills.")
showHTFLineLabels = input.bool(true, "Show HTF line endpoint labels", group = gMTF, tooltip = "Adds a small tag at the right edge of each HTF line (e.g. 'H1 21PH') so you can identify which HTF and pivot it represents.")
showHTFLineAVWAP  = input.bool(true,  "Render HTF AVWAP lines (PH/PL)", group = gMTF, tooltip = "Pivot-anchored AVWAPs from each HTF.")
showHTFLinePOC    = input.bool(true,  "Render HTF POC lines",            group = gMTF, tooltip = "Per-anchor Volume Profile POC on each HTF. Turn off if chart too dense.")
showHTFLineVA     = input.bool(false, "Render HTF VAH/VAL lines",        group = gMTF, tooltip = "Per-anchor Value Area edges (VAH and VAL) on each HTF. Default OFF — these add up to 2 extra lines per HTF anchor. Confluence cluster builder still uses them even when not drawn.")

// ============================================================
// ANCHORED VOLUME PROFILE
// ============================================================
g8 = "7 · Anchored Volume Profile"
useAVP            = input.bool(true,  "Enable volume profile", group = g8, tooltip = "Anchored Volume Profile per pivot anchor on the current timeframe. Each pivot's AVP produces a POC (volume magnet) and VAH/VAL (value-area edges) that join the cluster builder. Off = AVWAPs only, no volume profile contribution.")
avpBins           = input.int(25,     "Profile resolution", minval = 10, maxval = 50, group = g8, tooltip = "Number of price bins per anchor's volume profile. More bins = finer POC granularity but slower.")
avpRecomputeEvery = input.int(5,      "Recompute every N bars", minval = 1, maxval = 20, group = g8, tooltip = "POC/VAH/VAL get expensive — recompute every N bars instead of every bar. Volume distribution still runs every bar (cumulative). Lower = more responsive, higher = faster.")
avpValueArea      = input.float(70.0, "Value Area %", minval = 50.0, maxval = 90.0, step = 5.0, group = g8, tooltip = "Standard market-profile convention is 70% — the range containing 70% of volume around the POC. Lower = tighter value area.")
avpPOCWeight      = input.int(2,      "POC weight", minval = 1, maxval = 5, group = g8, tooltip = "How many times each POC level is pushed into the cluster builder. Higher = POCs count more toward zone formation. 2 = POCs count double an AVWAP.")
avpVAWeight       = input.int(1,      "VAH/VAL weight", minval = 1, maxval = 5, group = g8, tooltip = "How many times each VAH and VAL level is pushed into the cluster builder. Lower than POC because VAH/VAL are edges, not magnets.")
showPOCLines      = input.bool(false, "Show POC lines", group = g8, tooltip = "Draws an orange dotted line for each active chart-TF anchor's POC. Off by default — chart can get crowded.")

// ============================================================
// NAKED POC TRACKING
// ============================================================
gNaked = "8 · Naked POC Tracking"
useNakedPOC      = input.bool(true,  "Track naked POCs (untested historical volume nodes)", group = gNaked, tooltip = "When an anchor ages out, capture its POC and track until price crosses it. These untested POCs act as magnets. They contribute to confluence clustering as a separate POC type and render as dotted yellow lines.")
nakedMaxAge      = input.int(800, "Naked POC max age (bars)", minval = 100, maxval = 5000, group = gNaked, tooltip = "Maximum bars a naked POC can survive before being discarded even if untested. Prevents stale levels from polluting the chart.")
nakedMaxCount    = input.int(20, "Max naked POCs tracked", minval = 5, maxval = 50, group = gNaked, tooltip = "Cap on simultaneously-tracked naked POCs. Once full, the oldest gets evicted.")
showNakedLines   = input.bool(false, "Render naked POC lines", group = gNaked, tooltip = "Draw a dotted yellow horizontal line for each naked POC. Default OFF — naked POCs are tracked silently and contribute to the cluster builder. Turn on if you specifically want to visualize untested historical volume nodes.")
nakedLineColor   = input.color(#FFD600, "Naked POC line color", group = gNaked)
nakedPOCWeight   = input.int(1, "Naked POC contribution weight", minval = 1, maxval = 3, group = gNaked, tooltip = "How many times each naked POC is pushed into the cluster builder. 1 = single vote (same as raw AVWAP). Increase if you want untested POCs to count more toward zone formation.")

// ============================================================
// GENERAL
// ============================================================
g2 = "9 · Anchors — General"
maxAnchors  = input.int(2,   "Max active anchors per side per tier", minval = 1, maxval = 3, group = g2, tooltip = "How many recent PH (high) and PL (low) anchors stay active per pivot tier. With 3 tiers × 2 sides × 2 anchors = up to 12 chart-TF anchors at once. Increase if you want more historical-anchor context; decrease for cleaner clusters.")
maxBarAge   = input.int(300, "Max anchor age (bars)", minval = 50, maxval = 2000, group = g2, tooltip = "How many bars an anchor stays alive before being aged out. Older anchors carry stale context; younger ones may not have enough data.")
showPH      = input.bool(true,  "Track Pivot Highs", group = g2, tooltip = "Anchor AVWAPs to confirmed pivot highs (supply zones). Off = supply-side AVWAPs disabled.")
showPL      = input.bool(true,  "Track Pivot Lows",  group = g2, tooltip = "Anchor AVWAPs to confirmed pivot lows (demand zones). Off = demand-side AVWAPs disabled.")

// ============================================================
// PIVOT QUALITY
// ============================================================
gPQ = "10 · Pivot Quality"
usePivotQuality   = input.bool(true,  "Filter clusters by pivot quality", group = gPQ, tooltip = "Each chart-TF anchor gets a quality score [0-1]. Low-quality anchors are excluded from the cluster builder. Off = all anchors contribute.")
minPivotQuality   = input.float(0.30, "Min anchor quality to contribute", minval = 0.0, maxval = 0.9, step = 0.05, group = gPQ, tooltip = "Anchors below this score are filtered from the cluster builder. 0 = let everything through. Higher = stricter filtering, fewer but cleaner zones.")
qualityTightnessW = input.float(0.50, "Tightness weight in quality score", minval = 0.0, maxval = 1.0, step = 0.05, group = gPQ, tooltip = "How much the anchor's price-range tightness contributes to quality. Tight anchors signal sustained price defense. Recency weight = 1 - this.")

// ============================================================
// CONFLUENCE
// ============================================================
g4 = "11 · Confluence Detection"
showConfluence  = input.bool(true,  "Show zones", group = g4, tooltip = "Master toggle for the cluster builder + zone state machine. Off = HTF lines and chart-TF AVWAPs render but no zones drawn (useful as a reference-only mode).")
confTolerance   = input.float(0.08, "Cluster tolerance (% of price)", minval = 0.02, maxval = 2.0, step = 0.02, group = g4, tooltip = "How close AVWAP/POC levels must be (% of price) to count as one cluster. Tighter = more zones with cleaner clusters; wider = bigger zones absorbing more contributors. Overridden by asset-class preset.")
minConfluence   = input.int(4,      "Min weighted count", minval = 2, maxval = 20, group = g4, tooltip = "Minimum number of levels that must cluster together to form a zone. Counts each AVWAP once, each POC by avpPOCWeight, each VAH/VAL by avpVAWeight. Higher = fewer but stronger zones.")

// ============================================================
// ZONE BEHAVIOR
// ============================================================
g5 = "12 · Zone Behavior"
zoneMatchTol = input.float(0.15, "Merge nearby zones (%)", minval = 0.05, maxval = 1.0, step = 0.05, group = g5, tooltip = "If a new cluster forms within this % of an existing active zone, merge them instead of creating a duplicate. Prevents zone fragmentation when the same level fires across consecutive bars.")
zoneTimeout  = input.int(3, "Close zone after N quiet bars", minval = 1, maxval = 50, group = g5, tooltip = "Active zone → Pending after N bars with no new confluence reinforcement. Pending means waiting to see how price reacts before outcome resolves to support/resistance/chop.")
maxZones     = input.int(25, "Max zones to display", minval = 5, maxval = 100, group = g5, tooltip = "Cap on total zones tracked. Once full, oldest resolved zones are evicted. Higher = more historical context but slower rendering.")

// ============================================================
// OUTCOME
// ============================================================
g6 = "13 · Outcome & Polarity"
outcomeBars      = input.int(15,    "Bars to confirm direction", minval = 2, maxval = 100, group = g6, tooltip = "After a zone enters Pending state, wait N bars to measure price's net move from the zone. Determines whether it resolves to Support (price went up), Resistance (price went down), or Chop (didn't move enough either way).")
outcomeThreshold = input.float(0.3, "Min move % for directional outcome", minval = 0.05, maxval = 3.0, step = 0.05, group = g6, tooltip = "Minimum price move (% from zone center) within outcomeBars to count as directional. Below threshold = Chop.")

enablePolarityFlip = input.bool(true, "Enable polarity flip (broken R → S, broken S → R)", group = g6, tooltip = "When ON: a resolved Resistance zone that price closes decisively ABOVE will flip role to Support; a resolved Support that price closes decisively BELOW will flip to Resistance. This reflects the well-known TA principle that broken levels often act with reversed polarity. Visual: marker color flips, box color flips, and the zone may newly qualify for an S/R line if it becomes top-ranked.")
flipThreshold      = input.float(0.3, "Polarity flip threshold (% past zone edge)", minval = 0.05, maxval = 3.0, step = 0.05, group = g6, tooltip = "How far PAST the zone's edge price must close to trigger a polarity flip. For a Resistance to flip → Support, close must be above (zHigh × (1 + threshold%)). Higher threshold = fewer false flips from minor probes; lower = more sensitive.")
flipConfirmBars    = input.int(2, "Bars of confirmation for flip", minval = 1, maxval = 10, group = g6, tooltip = "Number of consecutive closes past the threshold required to confirm the polarity flip. Default 2 — guards against single-bar spikes that immediately retrace.")

colSupport    = input.color(color.new(#00D9A0, 85), "Support zone",    group = g6, tooltip = "Color for resolved Support zones (price bounced UP from the zone). Default mint green at 85% transparency — the zone is a reference marker, not a dominant fill.")
colResistance = input.color(color.new(#FF4D6D, 85), "Resistance zone", group = g6, tooltip = "Color for resolved Resistance zones (price rejected DOWN from the zone). Default rose red.")
colChop       = input.color(color.new(#6B7280, 90), "Chop zone",       group = g6, tooltip = "Color for resolved Chop zones (price tested but moved sideways). Default slate gray, very transparent since these are low-information zones.")
colActive     = input.color(color.new(#F5C518, 88), "Active zone",     group = g6, tooltip = "Color for Active zones still building confluence on the current bar. Default amber gold.")
colPending    = input.color(color.new(#4D9DE0, 88), "Pending zone",    group = g6, tooltip = "Color for Pending zones waiting for price outcome. Default cerulean blue.")

showBiasRibbon   = input.bool(false, "Directional bias ribbon (background tint)", group = g6, tooltip = "OFF by default for a clean chart. When ON, the chart background is faintly tinted to show the current STRUCTURAL lean: green when price has cleared all confluence zones to the upside (supports below, no resistance overhead = bullish breakout posture), red when price sits below all zones (resistance above, no support below = bearish). No tint while price is in range between a support and a resistance. Uses the same resolved-zone data as the dashboard bias row, updates on close, and never repaints.")
biasRibbonTransp = input.int(90, "Bias ribbon transparency", minval = 70, maxval = 98, group = g6, tooltip = "Transparency of the directional-bias background tint. Higher = fainter. Default 90 keeps it a subtle wash that never competes with price.")

// ============================================================
// LABEL STYLE
// ============================================================
g10 = "14 · Labels & Premium"
labelStyle = input.string("Short", "Label content", options = ["Short", "Detailed"], group = g10, tooltip = "Short = '⭐⭐⭐⭐⭐ ▲ Support [+3TF]'. Detailed adds bracketed counts: [12x 3PH/5PL/2POC/2VA]. Detailed is more informative but takes more horizontal space.")
showStars  = input.bool(true, "Show ⭐ strength rating", group = g10, tooltip = "Prefix labels with ⭐ glyphs (1-5 based on zone score).")
showMTFTag = input.bool(true, "Show MTF alignment count on label", group = g10, tooltip = "Show '[+NTF]' suffix where N = number of HTFs aligned with the zone.")

showPremium      = input.bool(true,  "Highlight premium-tier zones (★ glyph)", group = g10, tooltip = "When a zone meets premium criteria (default: 5⭐ + at least 2 HTFs aligned), prefixes its role text with a ★ glyph and thickens the zone border. These are the highest-quality confluence zones.")
premiumMinStars  = input.int(5, "Premium: min stars", minval = 3, maxval = 5, group = g10, tooltip = "Star rating required to qualify as a premium-tier zone. Default 5 (the top tier).")
premiumMinMTF    = input.int(2, "Premium: min HTFs aligned", minval = 0, maxval = 3, group = g10, tooltip = "How many HTFs must align with the zone for premium status. 0 = stars only, 2 = stars + 2-of-3 HTFs.")
premiumBorderW   = input.int(3, "Premium: zone border width", minval = 1, maxval = 5, group = g10, tooltip = "Border thickness for premium-tier zones (default 3 vs 1 for normal zones).")

// ============================================================
// DATA HEALTH
// ============================================================
gHealth = "15 · Data Integrity"
showHealthBadge   = input.bool(true,  "Show data-health badge",                                                  group = gHealth, tooltip = "Renders a small badge in the top-right of the chart showing OK / DEGRADED / CRITICAL. Hover for breakdown.")
strictHealth      = input.bool(false, "Strict mode: suppress zones on CRITICAL health",                          group = gHealth, tooltip = "When ON, no zones are built if data health is CRITICAL (e.g. spot index with no volume). When OFF, zones still build but rendered greyed out.")
healthDegradePenalty = input.bool(true, "Cap stars at 4 when data is DEGRADED",                                  group = gHealth, tooltip = "Prevents top-tier (5⭐) zones from being formed on partial data. Keeps the engine honest about confidence.")

// ============================================================
// LEGEND
// ============================================================
gLegend = "16 · Dashboard"
showDash   = input.bool(true,  "Show dashboard", group = gLegend, tooltip = "On-chart key-information panel. Adapts its colours to the chart background automatically.")
dashMode   = input.string("Compact", "Detail level", options = ["Compact", "Pro"], group = gLegend, tooltip = "Compact (default): the essentials a trader needs at a glance — price, nearest resistance and support with distance and rating, top zone, recent range, zone respect base-rate, and data health. Pro: adds the active higher timeframes, MTF alignment of the top zone, total/premium zone counts, and the single most predictive zone feature from the calibration engine.")
dashPosition = input.string("Bottom-right", "Dashboard position", options = ["Top-left", "Top-right", "Bottom-left", "Bottom-right", "Middle-right"], group = gLegend, tooltip = "Default Bottom-right (least likely to overlap active price action).")

// ============================================================
// ZONE RESPECT CALIBRATION
// ============================================================
gCal2 = "17 · Respect Calibration"
showCalTable = input.bool(true, "Show respect-rate calibration table", group = gCal2, tooltip = "Forward-resolved respect rate of resolved S/R zones, bucketed by star rating. Answers the question the stars assert but never prove: do higher-rated zones actually hold more often? Each resolved Support/Resistance zone's FIRST test is scored held vs broken, tallied per star with a 95% Wilson interval and compared to the all-zones base rate. A recovery after a touch counts as held; a decisive break counts as broken.")
calMinTests  = input.int(5, "  Min tests before a bucket is shown", minval = 3, maxval = 50, group = gCal2, tooltip = "A star bucket is only displayed once it has accumulated at least this many resolved tests. Below this, the sample is too small to be meaningful.")
calPosStr    = input.string("Bottom-left", "  Table position", options = ["Top-left", "Top-right", "Bottom-left", "Bottom-right", "Middle-right"], group = gCal2)
showCalFeatures = input.bool(true, "Show feature-lift calibration table", group = gCal2, tooltip = "Breaks the respect rate down by INPUT feature instead of by star. For each feature (MTF alignment, POC backing, VA backing, tight zone width) it shows held% for zones that HAD the feature vs zones that did NOT, plus the lift (Δ). This reveals which ingredients actually predict holding — the prerequisite for any evidence-based reweighting of the star formula. Positive green Δ = the feature helps; negative red Δ = it doesn't.")
calFeatPosStr   = input.string("Top-left", "  Feature table position", options = ["Top-left", "Top-right", "Bottom-left", "Bottom-right", "Middle-right"], group = gCal2)

// ── Evidence-weighted scoring (optional; default preserves classic behaviour) ──
starMode   = input.string("Classic (fixed)", "Star weighting", options = ["Classic (fixed)", "Evidence-weighted"], group = gCal2, tooltip = "Classic (fixed): the original hand-set star thresholds — the unchanged default. Evidence-weighted: nudges a zone's star up or down by at most 1 based on the MEASURED feature-lift below. A feature only counts once it has enough resolved tests, so with thin data this falls back to Classic. IMPORTANT: the calibration tables always bucket by the fixed Classic stars, so the evidence loop can never feed on itself.")
evThr      = input.float(0.08, "  Evidence nudge threshold (avg lift)", minval = 0.02, maxval = 0.30, step = 0.01, group = gCal2, tooltip = "In Evidence-weighted mode the average measured lift across the features a zone actually has must exceed this to move it +1 star (e.g. 0.08 = 8 percentage points of extra respect), or fall below its negative to move it -1 star. Higher = more conservative.")
mtfRefresh = input.bool(false, "Refresh MTF alignment on re-touch (decay stale boosts)", group = gCal2, tooltip = "OFF (default, original behaviour): a zone's MTF-alignment count only ever increases. ON: when a zone re-forms/updates, its MTF count is refreshed to the current alignment, so a zone the higher timeframes have since moved away from loses its stale [+NTF] boost.")

// ============================================================
// ALERTS
// ============================================================
g9 = "18 · Alerts"
alertOnHighQuality = input.bool(true,  "High-quality (4-5⭐) zone forms", group = g9)
alertOnMTFAligned  = input.bool(true,  "Zone aligns with HTF level",     group = g9)
alertOnPriceEnter  = input.bool(true,  "Price enters resolved zone",     group = g9)
alertOnHealthDrop  = input.bool(true,  "Data health degraded",           group = g9)
alertOnPolFlip     = input.bool(true,  "Polarity flip (broken R↔S)",     group = g9)

// ============================================================
// AUTO-SELECT HTFs BASED ON CHART TF
// ============================================================
chartTFMinutes = timeframe.in_seconds() / 60.0

autoHTF1 = chartTFMinutes <= 1 ? "5" : chartTFMinutes <= 5 ? "15" : chartTFMinutes <= 15 ? "60" : chartTFMinutes <= 60 ? "240" : chartTFMinutes <= 240 ? "D" : chartTFMinutes <= 1440 ? "W" : "M"
autoHTF2 = chartTFMinutes <= 1 ? "15" : chartTFMinutes <= 5 ? "60" : chartTFMinutes <= 15 ? "240" : chartTFMinutes <= 60 ? "D" : chartTFMinutes <= 240 ? "W" : chartTFMinutes <= 1440 ? "M" : "3M"
autoHTF3 = chartTFMinutes <= 1 ? "60" : chartTFMinutes <= 5 ? "240" : chartTFMinutes <= 15 ? "D" : chartTFMinutes <= 60 ? "W" : chartTFMinutes <= 240 ? "M" : chartTFMinutes <= 1440 ? "3M" : "12M"

htf1TF = mtfMode == "Auto" ? autoHTF1 : htf1Manual
htf2TF = mtfMode == "Auto" ? autoHTF2 : htf2Manual
htf3TF = mtfMode == "Auto" ? autoHTF3 : htf3Manual

// ════════════════════════════════════════════════════════════════
// SECTION: ASSET-CLASS VALIDATION + PRESET RESOLUTION
// ════════════════════════════════════════════════════════════════

string acSymType   = syminfo.type
string acSymPrefix = syminfo.prefix
bool acIsFut     = acSymType == "futures"
bool acIsStock   = acSymType == "stock" or acSymType == "dr"
bool acIsFund    = acSymType == "fund"
bool acIsCrypto  = acSymType == "crypto"
bool acIsForex   = acSymType == "forex"
bool acIsIndex   = acSymType == "index"
bool acIsEcon    = acSymType == "economic"

bool acIsVolumeless = acIsForex or acIsIndex or acIsEcon or acSymType == "options"

bool acClassMatches = false
string acMismatchMsg = ""
if assetClass == "NSE_INDEX_FUT"
    acClassMatches := acIsFut and (acSymPrefix == "NSE" or acSymPrefix == "BSE")
    acMismatchMsg := acClassMatches ? "" : "NSE_INDEX_FUT preset expects NSE/BSE index futures."
else if assetClass == "NSE_STOCK"
    acClassMatches := acIsStock and (acSymPrefix == "NSE" or acSymPrefix == "BSE")
    acMismatchMsg := acClassMatches ? "" : "NSE_STOCK preset expects NSE/BSE single stocks."
else if assetClass == "US_FUT"
    acClassMatches := acIsFut and (acSymPrefix == "CME" or acSymPrefix == "CME_MINI" or acSymPrefix == "CBOT" or acSymPrefix == "NYMEX" or acSymPrefix == "COMEX")
    acMismatchMsg := acClassMatches ? "" : "US_FUT preset expects CME/CBOT futures."
else if assetClass == "US_ETF"
    acClassMatches := acIsFund and (acSymPrefix == "NYSE" or acSymPrefix == "NASDAQ" or acSymPrefix == "AMEX" or acSymPrefix == "ARCA")
    acMismatchMsg := acClassMatches ? "" : "US_ETF preset expects US-listed ETFs."
else if assetClass == "US_STOCK"
    acClassMatches := acIsStock and (acSymPrefix == "NYSE" or acSymPrefix == "NASDAQ" or acSymPrefix == "AMEX")
    acMismatchMsg := acClassMatches ? "" : "US_STOCK preset expects US single stocks."
else if assetClass == "COMMODITY"
    acClassMatches := acIsFut and (acSymPrefix == "COMEX" or acSymPrefix == "NYMEX" or acSymPrefix == "CBOT" or acSymPrefix == "ICEUS")
    acMismatchMsg := acClassMatches ? "" : "COMMODITY preset expects COMEX/NYMEX/CBOT futures."
else if assetClass == "CRYPTO"
    acClassMatches := acIsCrypto or (acIsFut and (acSymPrefix == "BINANCE" or acSymPrefix == "BYBIT" or acSymPrefix == "OKX"))
    acMismatchMsg := acClassMatches ? "" : "CRYPTO preset expects crypto perpetual futures from major exchanges."
else
    acClassMatches := true

float confTolerance_eff   = confTolerance
int   minConfluence_eff   = minConfluence
float mtfAlignTol_eff     = mtfAlignTol
float zoneMatchTol_eff    = zoneMatchTol
int   maxBarAge_eff       = maxBarAge

if assetClass == "NSE_INDEX_FUT"
    confTolerance_eff := 0.08
    minConfluence_eff := 4
    mtfAlignTol_eff   := 0.20
    zoneMatchTol_eff  := 0.15
    maxBarAge_eff     := 300
else if assetClass == "NSE_STOCK"
    confTolerance_eff := 0.12
    minConfluence_eff := 4
    mtfAlignTol_eff   := 0.30
    zoneMatchTol_eff  := 0.20
    maxBarAge_eff     := 300
else if assetClass == "US_FUT"
    confTolerance_eff := 0.08
    minConfluence_eff := 4
    mtfAlignTol_eff   := 0.20
    zoneMatchTol_eff  := 0.15
    maxBarAge_eff     := 300
else if assetClass == "US_ETF"
    confTolerance_eff := 0.10
    minConfluence_eff := 4
    mtfAlignTol_eff   := 0.25
    zoneMatchTol_eff  := 0.18
    maxBarAge_eff     := 300
else if assetClass == "US_STOCK"
    confTolerance_eff := 0.15
    minConfluence_eff := 4
    mtfAlignTol_eff   := 0.35
    zoneMatchTol_eff  := 0.25
    maxBarAge_eff     := 300
else if assetClass == "COMMODITY"
    confTolerance_eff := 0.12
    minConfluence_eff := 4
    mtfAlignTol_eff   := 0.30
    zoneMatchTol_eff  := 0.20
    maxBarAge_eff     := 300
else if assetClass == "CRYPTO"
    confTolerance_eff := 0.20
    minConfluence_eff := 4
    mtfAlignTol_eff   := 0.40
    zoneMatchTol_eff  := 0.30
    maxBarAge_eff     := 500

// ════════════════════════════════════════════════════════════════
// SECTION: DATA-INTEGRITY LAYER
// ════════════════════════════════════════════════════════════════

string symType   = syminfo.type
string symPrefix = syminfo.prefix
bool   isVolumeless = symType == "forex" or symType == "index" or symType == "economic"

bool volPresent = not na(volume) and volume > 0
var int volPresentCnt = 0
var int volTotalCnt   = 0
if barstate.isconfirmed
    volTotalCnt   += 1
    volPresentCnt += volPresent ? 1 : 0
float volAvailRatio = volTotalCnt > 0 ? volPresentCnt / float(volTotalCnt) : 1.0
bool  volReliable   = volAvailRatio >= 0.80

bool barRangeValid = high > low and not na(high) and not na(low)

// [OPT-3] HTF feed health: a stalled feed returns the same value across many
// bars. The original used an explicit 50-iteration historical loop per HTF
// bar; math.sum() of the per-bar change flag is internally O(1) amortized.
f_htf_change_count_50() =>
    math.sum(close != close[1] ? 1.0 : 0.0, 50)

htf1ChangeCount = useMTF and useHTF1 ? request.security(syminfo.tickerid, htf1TF, f_htf_change_count_50(), lookahead = barmerge.lookahead_off) : 0.0
htf2ChangeCount = useMTF and useHTF2 ? request.security(syminfo.tickerid, htf2TF, f_htf_change_count_50(), lookahead = barmerge.lookahead_off) : 0.0
htf3ChangeCount = useMTF and useHTF3 ? request.security(syminfo.tickerid, htf3TF, f_htf_change_count_50(), lookahead = barmerge.lookahead_off) : 0.0

bool htf1Healthy = (not useMTF) or (not useHTF1) or (bar_index < 50) or (htf1ChangeCount > 0)
bool htf2Healthy = (not useMTF) or (not useHTF2) or (bar_index < 50) or (htf2ChangeCount > 0)
bool htf3Healthy = (not useMTF) or (not useHTF3) or (bar_index < 50) or (htf3ChangeCount > 0)

int largestN = use89 ? 89 : use55 ? 55 : use34 ? 34 : use21 ? 21 : use13 ? 13 : use8 ? 8 : use5 ? 5 : use3 ? 3 : 0
bool pivotContextOK = bar_index >= largestN * 2

int healthCode = 0
if isVolumeless or not volReliable
    healthCode := 2
else if (useMTF and ((useHTF1 and not htf1Healthy) or (useHTF2 and not htf2Healthy) or (useHTF3 and not htf3Healthy))) or not barRangeValid or not pivotContextOK or (acStrictGuard and not acClassMatches and assetClass != "Custom")
    healthCode := 1

string healthTxt = healthCode == 0 ? "OK" : healthCode == 1 ? "DEGRADED" : "CRITICAL"
color  healthCol = healthCode == 0 ? color.new(#3FB950, 0) : healthCode == 1 ? color.new(#E3B341, 0) : color.new(#F85149, 0)

string healthDetail =
     (volReliable        ? "Vol ✓ "    : "Vol ✗ ")    +
     (barRangeValid      ? "Bars ✓ "   : "Bars ✗ ")   +
     (pivotContextOK     ? "Pivots ✓ " : "Pivots ✗ ") +
     ((not useMTF or not useHTF1 or htf1Healthy) ? "HTF1 ✓ " : "HTF1 ✗ ") +
     ((not useMTF or not useHTF2 or htf2Healthy) ? "HTF2 ✓ " : "HTF2 ✗ ") +
     ((not useMTF or not useHTF3 or htf3Healthy) ? "HTF3 ✓ " : "HTF3 ✗ ") +
     (isVolumeless ? " · VOLUMELESS INSTRUMENT" : "") +
     (acStrictGuard and not acClassMatches and assetClass != "Custom" ? " · CLASS MISMATCH: " + acMismatchMsg : "")

var int healthCodePrev = 0
bool healthDegradedEdge = healthCode > healthCodePrev and barstate.isconfirmed
if barstate.isconfirmed
    healthCodePrev := healthCode

bool zonesAllowed = (healthCode < 2) or not strictHealth
bool avpAllowed   = useAVP and volReliable and barRangeValid
bool avwapAllowed = volReliable

float atr14 = ta.atr(14)
float atrSafe = atr14 > 0 ? atr14 : (close * 0.001)

// [OPT-4] Heavy clustering/redraw sections rebuild only on a new bar or a bar
// close, not on every realtime tick. On a live chart barstate.islast is true
// every tick, so without this the band/Top-N/Major-SR/range clustering and
// insertion sorts re-ran many times per second. Cheap overlays still update
// every tick (price line, badge, legend).
bool rebuildHeavy = barstate.islast and (barstate.isconfirmed or barstate.isnew)

// ════════════════════════════════════════════════════════════════
// SECTION: DISPLAY THEME  (adaptive to chart background luminance)
// ════════════════════════════════════════════════════════════════
// All on-chart panels read their background, text and border colours from this
// single theme block, derived from the chart's own background luminance
// (0.299·R + 0.587·G + 0.114·B). On a dark chart the panels go dark with light
// text; on a light chart they invert — so the dashboard and calibration tables
// stay legible on any colour scheme without manual tuning.

f_luma(color c) => 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
bool  _bgDark   = na(chart.bg_color) ? true : f_luma(chart.bg_color) < 140
color thPanel   = _bgDark ? color.new(#0E1116, 14) : color.new(#FFFFFF, 8)
color thHdrBg   = color.new(#1C2230, 0)
color thHdrTx   = color.new(#FFFFFF, 0)
color thText    = _bgDark ? color.new(#E8EAED, 0)  : color.new(#0B0E11, 0)
color thDim     = _bgDark ? color.new(#9AA0A6, 0)  : color.new(#5F6368, 0)
color thBorder  = _bgDark ? color.new(#3A4150, 25) : color.new(#9AA0A6, 25)
color thRowAlt  = _bgDark ? color.new(#161A22, 35) : color.new(#F1F3F4, 35)
color thAccent  = color.new(#4D9DE0, 0)
color thStar    = _bgDark ? color.new(#F5C518, 0) : color.new(#B8860B, 0)

// ════════════════════════════════════════════════════════════════
// SECTION: CORE STATE (anchors, AVWAP accumulator, AVP buckets)
// ════════════════════════════════════════════════════════════════

tp_ = srcPrice
pv_ = tp_ * volume

var array<float> barAVWAPs = array.new<float>()
var array<int>   barTypes  = array.new<int>()
array.clear(barAVWAPs)
array.clear(barTypes)

var array<int>   aBar      = array.new<int>()
var array<float> aCumPV    = array.new<float>()
var array<float> aCumV     = array.new<float>()
var array<float> aRangeLow = array.new<float>()
var array<float> aRangeHi  = array.new<float>()
var array<float> aBins     = array.new<float>()
var array<int>   aType     = array.new<int>()
var array<float> aPOC      = array.new<float>()
var array<float> aVAH      = array.new<float>()
var array<float> aVAL      = array.new<float>()

var array<float> nakedPOCs    = array.new<float>()
var array<int>   nakedPOCBars = array.new<int>()

add_anchor(float anchorPrice, int sigType) =>
    array.push(aBar, bar_index)
    array.push(aCumPV, 0.0)
    array.push(aCumV, 0.0)
    array.push(aRangeLow, anchorPrice)
    array.push(aRangeHi,  anchorPrice)
    array.push(aType, sigType)
    array.push(aPOC, na)
    array.push(aVAH, na)
    array.push(aVAL, na)
    // [OPT-2] Only allocate volume-profile bins when the chart-TF AVP is on.
    if useAVP
        for k = 1 to avpBins
            array.push(aBins, 0.0)

shift_anchor() =>
    if useNakedPOC and array.size(aPOC) > 0
        dyingPOC = array.get(aPOC, 0)
        if not na(dyingPOC) and dyingPOC > 0
            bool straddled = false
            int lookback = math.min(20, bar_index)
            for k = 0 to lookback
                if low[k] <= dyingPOC and high[k] >= dyingPOC
                    straddled := true
                    break
            if not straddled
                array.push(nakedPOCs,    dyingPOC)
                array.push(nakedPOCBars, bar_index)
                while array.size(nakedPOCs) > nakedMaxCount
                    array.shift(nakedPOCs)
                    array.shift(nakedPOCBars)
    array.shift(aBar)
    array.shift(aCumPV)
    array.shift(aCumV)
    array.shift(aRangeLow)
    array.shift(aRangeHi)
    array.shift(aType)
    array.shift(aPOC)
    array.shift(aVAH)
    array.shift(aVAL)
    // [OPT-2] Mirror the conditional bin allocation in add_anchor.
    if useAVP
        for k = 1 to avpBins
            array.shift(aBins)

distribute_volume(int idx) =>
    rLow = array.get(aRangeLow, idx)
    rHi  = array.get(aRangeHi,  idx)
    if low < rLow
        rLow := low
        array.set(aRangeLow, idx, rLow)
    if high > rHi
        rHi := high
        array.set(aRangeHi, idx, rHi)
    span = rHi - rLow
    if span > 0
        binSize    = span / avpBins
        barLowBin  = math.floor((low  - rLow) / binSize)
        barHighBin = math.floor((high - rLow) / binSize)
        barLowBin  := math.max(0, math.min(avpBins - 1, barLowBin))
        barHighBin := math.max(0, math.min(avpBins - 1, barHighBin))
        binsCovered = barHighBin - barLowBin + 1
        if binsCovered > 0
            volPerBin = volume / binsCovered
            for b = barLowBin to barHighBin
                flatIdx = idx * avpBins + b
                if flatIdx >= 0 and flatIdx < array.size(aBins)
                    array.set(aBins, flatIdx, array.get(aBins, flatIdx) + volPerBin)

compute_avp(int idx) =>
    rLow = array.get(aRangeLow, idx)
    rHi  = array.get(aRangeHi,  idx)
    span = rHi - rLow
    float pocP = na
    float vahP = na
    float valP = na
    if span > 0
        binSize  = span / avpBins
        maxVol   = 0.0
        pocBin   = 0
        totalVol = 0.0
        for b = 0 to avpBins - 1
            v = array.get(aBins, idx * avpBins + b)
            totalVol += v
            if v > maxVol
                maxVol := v
                pocBin := b
        if totalVol > 0
            pocP := rLow + (pocBin + 0.5) * binSize
            targetVol = totalVol * avpValueArea / 100.0
            accumVol  = array.get(aBins, idx * avpBins + pocBin)
            upper = pocBin
            lower = pocBin
            scanning = true
            while scanning and accumVol < targetVol
                upNext = upper + 1
                dnNext = lower - 1
                upVol = upNext < avpBins ? array.get(aBins, idx * avpBins + upNext) : 0.0
                dnVol = dnNext >= 0       ? array.get(aBins, idx * avpBins + dnNext) : 0.0
                if upNext >= avpBins and dnNext < 0
                    scanning := false
                else
                    if upVol >= dnVol and upNext < avpBins
                        accumVol += upVol
                        upper := upNext
                    else if dnNext >= 0
                        accumVol += dnVol
                        lower := dnNext
                    else if upNext < avpBins
                        accumVol += upVol
                        upper := upNext
                    else
                        scanning := false
            vahP := rLow + (upper + 1) * binSize
            valP := rLow + lower * binSize
    array.set(aPOC, idx, pocP)
    array.set(aVAH, idx, vahP)
    array.set(aVAL, idx, valP)
// ════════════════════════════════════════════════════════════════
// SECTION: HTF ANCHOR ENGINE
// ════════════════════════════════════════════════════════════════

htf_type_code(int htfIdx, bool isHigh) =>
    base = htfIdx * 10 + 1
    isHigh ? base : -base

htf_poc_code(int htfIdx) =>
    htfIdx * 10 + 2

htf_va_code(int htfIdx) =>
    htfIdx * 10 + 3

// [OPT-1] The hBins flat volume-profile array is now only grown/shrunk when
// enableHTFAVP is ON. With the default (OFF) the engine carries zero per-anchor
// bin overhead. Every block that READS hBins is itself gated by enableHTFAVP,
// so the array stays consistently either fully populated or empty.
f_htf_anchor_engine(int htfIdx, int maxAnchorsPerSide) =>
    var array<int>   hBar    = array.new<int>()
    var array<float> hCumPV  = array.new<float>()
    var array<float> hCumV   = array.new<float>()
    var array<int>   hType   = array.new<int>()
    var array<float> hRangeLow = array.new<float>()
    var array<float> hRangeHi  = array.new<float>()
    var array<float> hPOC      = array.new<float>()
    var array<float> hVAH      = array.new<float>()
    var array<float> hVAL      = array.new<float>()
    var array<float> hBins     = array.new<float>()

    htfPh3  = use3  ? ta.pivothigh(high, 3, 3)   : float(na)
    htfPl3  = use3  ? ta.pivotlow(low,  3, 3)    : float(na)
    htfPh5  = use5  ? ta.pivothigh(high, 5, 5)   : float(na)
    htfPl5  = use5  ? ta.pivotlow(low,  5, 5)    : float(na)
    htfPh8  = use8  ? ta.pivothigh(high, 8, 8)   : float(na)
    htfPl8  = use8  ? ta.pivotlow(low,  8, 8)    : float(na)
    htfPh13 = use13 ? ta.pivothigh(high, 13, 13) : float(na)
    htfPl13 = use13 ? ta.pivotlow(low,  13, 13)  : float(na)
    htfPh21 = use21 ? ta.pivothigh(high, 21, 21) : float(na)
    htfPl21 = use21 ? ta.pivotlow(low,  21, 21)  : float(na)
    htfPh34 = use34 ? ta.pivothigh(high, 34, 34) : float(na)
    htfPl34 = use34 ? ta.pivotlow(low,  34, 34)  : float(na)
    htfPh55 = use55 ? ta.pivothigh(high, 55, 55) : float(na)
    htfPl55 = use55 ? ta.pivotlow(low,  55, 55)  : float(na)
    htfPh89 = use89 ? ta.pivothigh(high, 89, 89) : float(na)
    htfPl89 = use89 ? ta.pivotlow(low,  89, 89)  : float(na)

    phCode = htf_type_code(htfIdx, true)
    plCode = htf_type_code(htfIdx, false)

    if not na(htfPh3)  and showPH
        array.push(hBar, bar_index - 3)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, phCode)
        array.push(hRangeLow, high[3])
        array.push(hRangeHi,  high[3])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)
    if not na(htfPl3)  and showPL
        array.push(hBar, bar_index - 3)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, plCode)
        array.push(hRangeLow, low[3])
        array.push(hRangeHi,  low[3])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)
    if not na(htfPh5)  and showPH
        array.push(hBar, bar_index - 5)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, phCode)
        array.push(hRangeLow, high[5])
        array.push(hRangeHi,  high[5])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)
    if not na(htfPl5)  and showPL
        array.push(hBar, bar_index - 5)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, plCode)
        array.push(hRangeLow, low[5])
        array.push(hRangeHi,  low[5])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)
    if not na(htfPh8)  and showPH
        array.push(hBar, bar_index - 8)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, phCode)
        array.push(hRangeLow, high[8])
        array.push(hRangeHi,  high[8])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)
    if not na(htfPl8)  and showPL
        array.push(hBar, bar_index - 8)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, plCode)
        array.push(hRangeLow, low[8])
        array.push(hRangeHi,  low[8])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)
    if not na(htfPh13) and showPH
        array.push(hBar, bar_index - 13)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, phCode)
        array.push(hRangeLow, high[13])
        array.push(hRangeHi,  high[13])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)
    if not na(htfPl13) and showPL
        array.push(hBar, bar_index - 13)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, plCode)
        array.push(hRangeLow, low[13])
        array.push(hRangeHi,  low[13])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)
    if not na(htfPh21) and showPH
        array.push(hBar, bar_index - 21)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, phCode)
        array.push(hRangeLow, high[21])
        array.push(hRangeHi,  high[21])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)
    if not na(htfPl21) and showPL
        array.push(hBar, bar_index - 21)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, plCode)
        array.push(hRangeLow, low[21])
        array.push(hRangeHi,  low[21])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)
    if not na(htfPh34) and showPH
        array.push(hBar, bar_index - 34)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, phCode)
        array.push(hRangeLow, high[34])
        array.push(hRangeHi,  high[34])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)
    if not na(htfPl34) and showPL
        array.push(hBar, bar_index - 34)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, plCode)
        array.push(hRangeLow, low[34])
        array.push(hRangeHi,  low[34])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)
    if not na(htfPh55) and showPH
        array.push(hBar, bar_index - 55)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, phCode)
        array.push(hRangeLow, high[55])
        array.push(hRangeHi,  high[55])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)
    if not na(htfPl55) and showPL
        array.push(hBar, bar_index - 55)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, plCode)
        array.push(hRangeLow, low[55])
        array.push(hRangeHi,  low[55])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)
    if not na(htfPh89) and showPH
        array.push(hBar, bar_index - 89)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, phCode)
        array.push(hRangeLow, high[89])
        array.push(hRangeHi,  high[89])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)
    if not na(htfPl89) and showPL
        array.push(hBar, bar_index - 89)
        array.push(hCumPV, 0.0)
        array.push(hCumV, 0.0)
        array.push(hType, plCode)
        array.push(hRangeLow, low[89])
        array.push(hRangeHi,  low[89])
        array.push(hPOC, na)
        array.push(hVAH, na)
        array.push(hVAL, na)
        if enableHTFAVP
            for k = 1 to avpBins
                array.push(hBins, 0.0)

    // Age-out
    keepAging = array.size(hBar) > 0
    while keepAging
        if array.size(hBar) == 0
            keepAging := false
        else
            ob = array.get(hBar, 0)
            if (bar_index - ob) > maxBarAge_eff
                array.shift(hBar)
                array.shift(hCumPV)
                array.shift(hCumV)
                array.shift(hType)
                array.shift(hRangeLow)
                array.shift(hRangeHi)
                array.shift(hPOC)
                array.shift(hVAH)
                array.shift(hVAL)
                if enableHTFAVP
                    for k = 1 to avpBins
                        array.shift(hBins)
            else
                keepAging := false

    maxHTFTotal_calc = (use3 ? 2 * maxAnchorsPerSide : 0) + (use5 ? 2 * maxAnchorsPerSide : 0) + (use8 ? 2 * maxAnchorsPerSide : 0) + (use13 ? 2 * maxAnchorsPerSide : 0) + (use21 ? 2 * maxAnchorsPerSide : 0) + (use34 ? 2 * maxAnchorsPerSide : 0) + (use55 ? 2 * maxAnchorsPerSide : 0) + (use89 ? 2 * maxAnchorsPerSide : 0)
    maxHTFTotal = math.min(maxHTFTotal_calc, maxHTFAnchorsHardCap)
    while array.size(hBar) > maxHTFTotal
        array.shift(hBar)
        array.shift(hCumPV)
        array.shift(hCumV)
        array.shift(hType)
        array.shift(hRangeLow)
        array.shift(hRangeHi)
        array.shift(hPOC)
        array.shift(hVAH)
        array.shift(hVAL)
        if enableHTFAVP
            for k = 1 to avpBins
                array.shift(hBins)

    htfTP = (high + low + close) / 3.0
    htfPV = htfTP * volume

    // [FIX-4] Recompute the HTF volume-profile POC/VAH/VAL on a periodic cadence
    // (mirrors the chart-TF path), not only on the last HTF bar. Previously the
    // opt-in cross-TF VP votes existed only at the chart's right edge and repainted;
    // now they are produced across HTF history on closed bars. No effect unless the
    // default-OFF "HTF Volume Profile" is enabled.
    bool shouldRecomputeAVP = useAVP and enableHTFAVP and (bar_index % avpRecomputeEvery == 0 or barstate.islast)

    array<int>   typesArr  = array.new<int>()
    array<float> pricesArr = array.new<float>()
    int   nA      = array.size(hBar)
    int   pocCode = htf_poc_code(htfIdx)
    int   vaCode  = htf_va_code(htfIdx)

    if nA > 0
        for idx = 0 to nA - 1
            newPV = array.get(hCumPV, idx) + htfPV
            newV  = array.get(hCumV,  idx) + volume
            array.set(hCumPV, idx, newPV)
            array.set(hCumV,  idx, newV)
            vwapVal = newV > 0 ? newPV / newV : float(na)
            tcode   = array.get(hType, idx)
            if not na(vwapVal)
                array.push(typesArr,  tcode)
                array.push(pricesArr, vwapVal)

            if useAVP and enableHTFAVP and volume > 0
                rLow = array.get(hRangeLow, idx)
                rHi  = array.get(hRangeHi,  idx)
                if low < rLow
                    rLow := low
                    array.set(hRangeLow, idx, rLow)
                if high > rHi
                    rHi := high
                    array.set(hRangeHi, idx, rHi)
                span = rHi - rLow
                if span > 0
                    binSize    = span / avpBins
                    barLowBin  = math.floor((low  - rLow) / binSize)
                    barHighBin = math.floor((high - rLow) / binSize)
                    barLowBin  := math.max(0, math.min(avpBins - 1, barLowBin))
                    barHighBin := math.max(0, math.min(avpBins - 1, barHighBin))
                    binsCovered = barHighBin - barLowBin + 1
                    if binsCovered > 0
                        volPerBin = volume / binsCovered
                        for b = barLowBin to barHighBin
                            flatIdx = idx * avpBins + b
                            if flatIdx >= 0 and flatIdx < array.size(hBins)
                                array.set(hBins, flatIdx, array.get(hBins, flatIdx) + volPerBin)

            if shouldRecomputeAVP
                cLow = array.get(hRangeLow, idx)
                cHi  = array.get(hRangeHi,  idx)
                cSpan = cHi - cLow
                float pocP = na
                float vahP = na
                float valP = na
                if cSpan > 0
                    cBinSize = cSpan / avpBins
                    maxVol   = 0.0
                    pocBin   = 0
                    totalVol = 0.0
                    for b = 0 to avpBins - 1
                        v = array.get(hBins, idx * avpBins + b)
                        totalVol += v
                        if v > maxVol
                            maxVol := v
                            pocBin := b
                    if totalVol > 0
                        pocP := cLow + (pocBin + 0.5) * cBinSize
                        targetVol = totalVol * avpValueArea / 100.0
                        accumVol  = array.get(hBins, idx * avpBins + pocBin)
                        upper = pocBin
                        lower = pocBin
                        scanning = true
                        while scanning and accumVol < targetVol
                            upNext = upper + 1
                            dnNext = lower - 1
                            upVol = upNext < avpBins ? array.get(hBins, idx * avpBins + upNext) : 0.0
                            dnVol = dnNext >= 0       ? array.get(hBins, idx * avpBins + dnNext) : 0.0
                            if upNext >= avpBins and dnNext < 0
                                scanning := false
                            else
                                if upVol >= dnVol and upNext < avpBins
                                    accumVol += upVol
                                    upper := upNext
                                else if dnNext >= 0
                                    accumVol += dnVol
                                    lower := dnNext
                                else if upNext < avpBins
                                    accumVol += upVol
                                    upper := upNext
                                else
                                    scanning := false
                        vahP := cLow + (upper + 1) * cBinSize
                        valP := cLow + lower * cBinSize
                array.set(hPOC, idx, pocP)
                array.set(hVAH, idx, vahP)
                array.set(hVAL, idx, valP)

            if useAVP and enableHTFAVP
                pocCached = array.get(hPOC, idx)
                vahCached = array.get(hVAH, idx)
                valCached = array.get(hVAL, idx)
                if not na(pocCached)
                    array.push(typesArr,  pocCode)
                    array.push(pricesArr, pocCached)
                if not na(vahCached)
                    array.push(typesArr,  vaCode)
                    array.push(pricesArr, vahCached)
                if not na(valCached)
                    array.push(typesArr,  vaCode)
                    array.push(pricesArr, valCached)
    [typesArr, pricesArr]

f_htf_engine_1() => f_htf_anchor_engine(1, maxAnchorsHTF)
f_htf_engine_2() => f_htf_anchor_engine(2, maxAnchorsHTF)
f_htf_engine_3() => f_htf_anchor_engine(3, maxAnchorsHTF)

// [OPT-5] HTF level transport now returns typed arrays directly from
// request.security (Pine v6 tuple-of-arrays), eliminating the per-bar string
// pack (str.tostring in HTF context) and the per-chart-bar string parse
// (str.split + str.tonumber in parse_htf_packed). The parse ran on EVERY chart
// bar for up to ~24 levels × 3 HTFs; it is now gone entirely. Same levels, same
// values, same ordering — transport only, no logic change.
array<int>   htf1_types  = array.new<int>()
array<float> htf1_prices = array.new<float>()
if useMTF and useHTF1 and avwapAllowed
    [h1t, h1p] = request.security(syminfo.tickerid, htf1TF, f_htf_engine_1(), lookahead = barmerge.lookahead_off)
    if not na(h1t) and not na(h1p)
        htf1_types  := h1t
        htf1_prices := h1p

array<int>   htf2_types  = array.new<int>()
array<float> htf2_prices = array.new<float>()
if useMTF and useHTF2 and avwapAllowed
    [h2t, h2p] = request.security(syminfo.tickerid, htf2TF, f_htf_engine_2(), lookahead = barmerge.lookahead_off)
    if not na(h2t) and not na(h2p)
        htf2_types  := h2t
        htf2_prices := h2p

array<int>   htf3_types  = array.new<int>()
array<float> htf3_prices = array.new<float>()
if useMTF and useHTF3 and avwapAllowed
    [h3t, h3p] = request.security(syminfo.tickerid, htf3TF, f_htf_engine_3(), lookahead = barmerge.lookahead_off)
    if not na(h3t) and not na(h3p)
        htf3_types  := h3t
        htf3_prices := h3p


// ════════════════════════════════════════════════════════════════
// SECTION: STAR / LABEL HELPERS
// ════════════════════════════════════════════════════════════════

f_ciHalf(int w, int n) =>
    float r = na
    if n > 0
        float z = 1.96
        float p = w / float(n)
        float den = 1.0 + z * z / n
        r := z * math.sqrt(p * (1.0 - p) / n + z * z / (4.0 * n * n)) / den
    r

f_featTally(int fi, bool present, bool held, int[] tY, int[] hY, int[] tN, int[] hN) =>
    if present
        array.set(tY, fi, array.get(tY, fi) + 1)
        if held
            array.set(hY, fi, array.get(hY, fi) + 1)
    else
        array.set(tN, fi, array.get(tN, fi) + 1)
        if held
            array.set(hN, fi, array.get(hN, fi) + 1)

// ── Evidence-weighted scoring state (weights are assigned after the calibration
//    tallies are declared below; they read last bar's committed counts, so the
//    nudge can never use this bar's own resolution → no same-bar feedback) ──
starEvidenceOn = starMode == "Evidence-weighted"
var float evLiftMTF = na
var float evLiftPOC = na
var float evLiftVA  = na
var bool  evReady   = false

star_rating_base(int cnt, int ph, int pl, int poc, int va, int mtfAligned) =>
    typeCount = (ph > 0 ? 1 : 0) + (pl > 0 ? 1 : 0) + (poc > 0 ? 1 : 0) + (va > 0 ? 1 : 0)
    int stars = 1
    if cnt >= 10 and typeCount == 4
        stars := 5
    else if cnt >= 7 and typeCount >= 3
        stars := 4
    else if cnt >= 5 and typeCount >= 2
        stars := 3
    else if cnt >= minConfluence_eff + 1
        stars := 2
    else
        stars := 1
    int baseStars = stars
    if mtfBoostStars and mtfAligned > 0
        if mtfBoostMode == "Full (+N for N HTFs)"
            stars := math.min(5, stars + mtfAligned)
        else if mtfBoostMode == "Capped (+1 max)"
            stars := math.min(5, math.min(baseStars + 1, stars + 1))
    if healthDegradePenalty and healthCode == 1
        stars := math.min(stars, 4)
    stars

// Display-path star: the classic base, then an evidence nudge of at most ±1
// driven by the MEASURED feature-lift. Gated by starEvidenceOn and evReady, so
// Classic mode and thin-data cases return exactly the base rating. Calibration
// bucketing deliberately calls star_rating_base (never this), so a zone is always
// MEASURED against the fixed yardstick and the evidence loop stays honest.
star_rating(int cnt, int ph, int pl, int poc, int va, int mtfAligned) =>
    int s = star_rating_base(cnt, ph, pl, poc, va, mtfAligned)
    if starEvidenceOn and evReady
        float ev = 0.0
        int en = 0
        if mtfAligned > 0 and not na(evLiftMTF)
            ev += evLiftMTF
            en += 1
        if poc > 0 and not na(evLiftPOC)
            ev += evLiftPOC
            en += 1
        if va > 0 and not na(evLiftVA)
            ev += evLiftVA
            en += 1
        if en > 0
            float evAvg = ev / en
            int nudge = evAvg >= evThr ? 1 : evAvg <= -evThr ? -1 : 0
            s := math.max(1, math.min(5, s + nudge))
    s

compositional_bias_score(int ph, int pl, int poc, int va, float zMid) =>
    int bias = (pl - ph)
    float distATR = math.abs(close - zMid) / math.max(atrSafe, 0.0001)
    int posBias = zMid < close ? 1 : zMid > close ? -1 : 0
    if distATR <= 3.0
        bias += posBias
    bias

bias_direction(int rawBias) =>
    rawBias >= 2 ? 1 : rawBias <= -2 ? -1 : 0

marker_shape(int state, int outc, int bias) =>
    int dirSignal = state == 2 ? outc : bias
    dirSignal == 1 ? label.style_triangleup : dirSignal == -1 ? label.style_triangledown : label.style_diamond

direction_color(int state, int outc) =>
    if state == 0
        colActive
    else if state == 1
        colPending
    else
        outc == 1 ? colSupport : outc == -1 ? colResistance : colChop

// [VIS-1] Zone fill opacity scales with star strength: a stronger zone renders more
// solid (less transparent) than a weak one, keeping the base HUE (support green /
// resistance red / active amber / pending blue) so the eye lands on the highest-
// confluence levels first. Reads the base colour's own transparency as the 1★ floor
// so it always respects the user's chosen zone colours.
f_zoneFill(color base, int stars) =>
    int s = math.max(1, math.min(5, stars))
    float baseT = color.t(base)
    int newT = int(math.round(math.max(0.0, baseT - (s - 1) * 7.0)))
    color.new(base, newT)

marker_size_for_stars(int stars) =>
    size.tiny

star_string(int stars) =>
    string s = ""
    for k = 1 to stars
        s += "⭐"
    s

is_premium(int cnt, int ph, int pl, int poc, int va, int mtfAligned) =>
    showPremium and star_rating(cnt, ph, pl, poc, va, mtfAligned) >= premiumMinStars and mtfAligned >= premiumMinMTF

mtf_tag(int mtfAligned) =>
    showMTFTag and mtfAligned > 0 ? " [+" + str.tostring(mtfAligned) + "TF]" : ""

short_label(string prefix, int cnt, int ph, int pl, int poc, int va, int mtfAligned, string roleText) =>
    stars    = star_rating(cnt, ph, pl, poc, va, mtfAligned)
    starsStr = showStars ? star_string(stars) + " " : ""
    premiumGlyph = is_premium(cnt, ph, pl, poc, va, mtfAligned) ? "★ " : ""
    starsStr + prefix + " " + premiumGlyph + roleText + mtf_tag(mtfAligned)

detailed_label(string prefix, int cnt, int ph, int pl, int poc, int va, int mtfAligned, string roleText) =>
    stars    = star_rating(cnt, ph, pl, poc, va, mtfAligned)
    starsStr = showStars ? star_string(stars) + " " : ""
    premiumGlyph = is_premium(cnt, ph, pl, poc, va, mtfAligned) ? "★ " : ""
    base     = starsStr + prefix + " " + premiumGlyph + roleText + mtf_tag(mtfAligned)
    detail = " [" + str.tostring(cnt) + "x " + str.tostring(ph) + "PH/" + str.tostring(pl) + "PL"
    detail := poc > 0 ? detail + "/" + str.tostring(poc) + "POC" : detail
    detail := va  > 0 ? detail + "/" + str.tostring(va)  + "VA"  : detail
    detail += "]"
    base + detail

build_label(string prefix, int cnt, int ph, int pl, int poc, int va, int mtfAligned, string roleText) =>
    if vmZones and not vmLines
        ""
    else
        labelStyle == "Detailed" ? detailed_label(prefix, cnt, ph, pl, poc, va, mtfAligned, roleText) : short_label(prefix, cnt, ph, pl, poc, va, mtfAligned, roleText)

build_tooltip(int cnt, int ph, int pl, int poc, int va, int mtfAligned, string roleText) =>
    stars = star_rating(cnt, ph, pl, poc, va, mtfAligned)
    isPrem = is_premium(cnt, ph, pl, poc, va, mtfAligned)
    s = roleText + "  (" + str.tostring(stars) + "/5 stars)" + (isPrem ? "  ★ PREMIUM" : "") + "\n"
    s += "Total weighted votes: " + str.tostring(cnt) + "\n"
    s += "Pivot Highs (supply): " + str.tostring(ph) + "\n"
    s += "Pivot Lows (demand): "  + str.tostring(pl) + "\n"
    s += "POCs (volume magnets): " + str.tostring(poc) + "\n"
    s += "VAH/VAL: " + str.tostring(va) + "\n"
    s += "MTF aligned levels: "   + str.tostring(mtfAligned) + "\n"
    s += "Data health: " + healthTxt
    s

htf_aligned_any(array<float> prices, float zMid, float tol) =>
    bool any = false
    n = array.size(prices)
    if n > 0
        for k = 0 to n - 1
            if math.abs(array.get(prices, k) - zMid) <= tol
                any := true
                break
    any ? 1 : 0

count_mtf_alignment(float zMid) =>
    int cnt = 0
    if useMTF
        tol = close * mtfAlignTol_eff / 100.0
        if useHTF1
            cnt += htf_aligned_any(htf1_prices, zMid, tol)
        if useHTF2
            cnt += htf_aligned_any(htf2_prices, zMid, tol)
        if useHTF3
            cnt += htf_aligned_any(htf3_prices, zMid, tol)
    cnt

// ════════════════════════════════════════════════════════════════
// SECTION: DETECT CURRENT-TF PIVOTS
// ════════════════════════════════════════════════════════════════

ph3  = use3  ? ta.pivothigh(high, 3, 3)   : float(na)
pl3  = use3  ? ta.pivotlow(low, 3, 3)     : float(na)
ph5  = use5  ? ta.pivothigh(high, 5, 5)   : float(na)
pl5  = use5  ? ta.pivotlow(low, 5, 5)     : float(na)
ph8  = use8  ? ta.pivothigh(high, 8, 8)   : float(na)
pl8  = use8  ? ta.pivotlow(low, 8, 8)     : float(na)
ph13 = use13 ? ta.pivothigh(high, 13, 13) : float(na)
pl13 = use13 ? ta.pivotlow(low, 13, 13)   : float(na)
ph21 = use21 ? ta.pivothigh(high, 21, 21) : float(na)
pl21 = use21 ? ta.pivotlow(low, 21, 21)   : float(na)
ph34 = use34 ? ta.pivothigh(high, 34, 34) : float(na)
pl34 = use34 ? ta.pivotlow(low, 34, 34)   : float(na)
ph55 = use55 ? ta.pivothigh(high, 55, 55) : float(na)
pl55 = use55 ? ta.pivotlow(low, 55, 55)   : float(na)
ph89 = use89 ? ta.pivothigh(high, 89, 89) : float(na)
pl89 = use89 ? ta.pivotlow(low, 89, 89)   : float(na)

if not na(ph3)  and showPH
    add_anchor(high[3],  1)
if not na(pl3)  and showPL
    add_anchor(low[3],  -1)
if not na(ph5)  and showPH
    add_anchor(high[5],  1)
if not na(pl5)  and showPL
    add_anchor(low[5],  -1)
if not na(ph8)  and showPH
    add_anchor(high[8],  1)
if not na(pl8)  and showPL
    add_anchor(low[8],  -1)
if not na(ph13) and showPH
    add_anchor(high[13], 1)
if not na(pl13) and showPL
    add_anchor(low[13], -1)
if not na(ph21) and showPH
    add_anchor(high[21], 1)
if not na(pl21) and showPL
    add_anchor(low[21], -1)
if not na(ph34) and showPH
    add_anchor(high[34], 1)
if not na(pl34) and showPL
    add_anchor(low[34], -1)
if not na(ph55) and showPH
    add_anchor(high[55], 1)
if not na(pl55) and showPL
    add_anchor(low[55], -1)
if not na(ph89) and showPH
    add_anchor(high[89], 1)
if not na(pl89) and showPL
    add_anchor(low[89], -1)

// ════════════════════════════════════════════════════════════════
// SECTION: AGE-OUT
// ════════════════════════════════════════════════════════════════

keepAging = array.size(aBar) > 0
while keepAging
    if array.size(aBar) == 0
        keepAging := false
    else
        ob = array.get(aBar, 0)
        if (bar_index - ob) > maxBarAge_eff
            shift_anchor()
        else
            keepAging := false

maxTotalAnchors = (use3 ? 2 * maxAnchors : 0) + (use5 ? 2 * maxAnchors : 0) + (use8 ? 2 * maxAnchors : 0) + (use13 ? 2 * maxAnchors : 0) + (use21 ? 2 * maxAnchors : 0) + (use34 ? 2 * maxAnchors : 0) + (use55 ? 2 * maxAnchors : 0) + (use89 ? 2 * maxAnchors : 0)
while array.size(aBar) > maxTotalAnchors
    shift_anchor()

// ════════════════════════════════════════════════════════════════
// SECTION: CLEAR LINES (POC + HTF) on last bar
// ════════════════════════════════════════════════════════════════

var array<line>  pocLines      = array.new<line>()
var array<line>  htfLines      = array.new<line>()
var array<label> htfLineLabels = array.new<label>()
var array<line>  nakedLines    = array.new<line>()
if barstate.islast
    while array.size(pocLines) > 0
        line.delete(array.shift(pocLines))
    while array.size(htfLines) > 0
        line.delete(array.shift(htfLines))
    while array.size(htfLineLabels) > 0
        label.delete(array.shift(htfLineLabels))
    while array.size(nakedLines) > 0
        line.delete(array.shift(nakedLines))

// ════════════════════════════════════════════════════════════════
// SECTION: UPDATE ANCHORS & BUILD CONTRIBUTIONS
// ════════════════════════════════════════════════════════════════

shouldRecomputeAVP = avpAllowed and (bar_index % avpRecomputeEvery == 0 or barstate.islast)

float pqSum = 0.0
int   pqCount = 0

nAnchors = array.size(aBar)
float refScale = close * 0.01   // [OPT-6] loop-invariant (close is constant per bar) — hoisted out of the per-anchor loop
if nAnchors > 0 and avwapAllowed
    for idx = 0 to nAnchors - 1
        newPV = array.get(aCumPV, idx) + pv_
        newV  = array.get(aCumV,  idx) + volume
        array.set(aCumPV, idx, newPV)
        array.set(aCumV,  idx, newV)
        vwapVal = newV > 0 ? newPV / newV : float(na)

        if avpAllowed
            distribute_volume(idx)
        if shouldRecomputeAVP
            compute_avp(idx)

        anchorAge = bar_index - array.get(aBar, idx)
        anchorRange = array.get(aRangeHi, idx) - array.get(aRangeLow, idx)
        float tightness = refScale > 0 ? math.max(0.0, math.min(1.0, 1.0 - anchorRange / refScale)) : 0.5
        float recency = maxBarAge_eff > 0 ? math.max(0.0, math.min(1.0, 1.0 - anchorAge / float(maxBarAge_eff))) : 0.5
        float anchorQuality = qualityTightnessW * tightness + (1.0 - qualityTightnessW) * recency
        pqSum := pqSum + anchorQuality
        pqCount := pqCount + 1

        bool qualityPass = (not usePivotQuality) or (anchorQuality >= minPivotQuality)

        t = array.get(aType, idx)
        if not na(vwapVal) and qualityPass
            array.push(barAVWAPs, vwapVal)
            array.push(barTypes, t)

        if avpAllowed and qualityPass
            pocCached = array.get(aPOC, idx)
            vahCached = array.get(aVAH, idx)
            valCached = array.get(aVAL, idx)
            if not na(pocCached)
                for k = 1 to avpPOCWeight
                    array.push(barAVWAPs, pocCached)
                    array.push(barTypes, 3)
                if showPOCLines and barstate.islast
                    anchorBar = array.get(aBar, idx)
                    ln = line.new(anchorBar, pocCached, bar_index, pocCached, color = color.new(color.orange, 50), width = 1, style = line.style_dotted)
                    array.push(pocLines, ln)
            if not na(vahCached) and not na(valCached)
                for k = 1 to avpVAWeight
                    array.push(barAVWAPs, vahCached)
                    array.push(barTypes, 4)
                    array.push(barAVWAPs, valCached)
                    array.push(barTypes, 4)

float avgPivotQuality = pqCount > 0 ? pqSum / pqCount : na

// [OPT-6] The HTF level contribution only feeds barAVWAPs, which is consumed by
// the barstate.isconfirmed-gated cluster builder below, so building it on every
// unconfirmed realtime tick is wasted work — gate it to bar close.
if useMTF and barstate.isconfirmed
    if useHTF1
        nH = array.size(htf1_prices)
        if nH > 0
            for k = 0 to nH - 1
                array.push(barAVWAPs, array.get(htf1_prices, k))
                array.push(barTypes,  array.get(htf1_types,  k))
    if useHTF2
        nH = array.size(htf2_prices)
        if nH > 0
            for k = 0 to nH - 1
                array.push(barAVWAPs, array.get(htf2_prices, k))
                array.push(barTypes,  array.get(htf2_types,  k))
    if useHTF3
        nH = array.size(htf3_prices)
        if nH > 0
            for k = 0 to nH - 1
                array.push(barAVWAPs, array.get(htf3_prices, k))
                array.push(barTypes,  array.get(htf3_types,  k))

if useNakedPOC
    nNaked = array.size(nakedPOCs)
    if nNaked > 0
        int idx = nNaked - 1
        while idx >= 0
            float npVal = array.get(nakedPOCs, idx)
            int npBar = array.get(nakedPOCBars, idx)
            bool crossed = low <= npVal and high >= npVal
            bool aged = (bar_index - npBar) > nakedMaxAge
            if crossed or aged
                array.remove(nakedPOCs,    idx)
                array.remove(nakedPOCBars, idx)
            idx -= 1
        nNaked := array.size(nakedPOCs)
        if nNaked > 0
            for k = 0 to nNaked - 1
                npInj = array.get(nakedPOCs, k)
                if not na(npInj)
                    for w = 1 to nakedPOCWeight
                        array.push(barAVWAPs, npInj)
                        array.push(barTypes, 5)

// ════════════════════════════════════════════════════════════════
// SECTION: HTF REFERENCE LINES
// ════════════════════════════════════════════════════════════════

htf_label_tag(int tc) =>
    int htfIdx = int(math.abs(tc) / 10)
    int unit = math.abs(tc) % 10
    string tag = "H" + str.tostring(htfIdx) + " "
    if unit == 1
        tag := tag + (tc > 0 ? "PH" : "PL")
    else if unit == 2
        tag := tag + "POC"
    else if unit == 3
        tag := tag + "VA"
    tag

draw_htf_lines(array<int> typesArr, array<float> pricesArr, color cBase, int width) =>
    n = array.size(pricesArr)
    if n > 0
        startBar = bar_index - 100
        endBar   = bar_index + 10
        for k = 0 to n - 1
            tc = array.get(typesArr,  k)
            pv = array.get(pricesArr, k)
            if not na(pv)
                int unit = math.abs(tc) % 10
                bool drawIt = (unit == 1 and showHTFLineAVWAP) or (unit == 2 and showHTFLinePOC) or (unit == 3 and showHTFLineVA)
                if drawIt
                    lineStyle = unit == 2 ? line.style_dotted : unit == 3 ? line.style_dashed : (tc > 0 ? line.style_solid : line.style_dashed)
                    int effWidth = (unit == 2 or unit == 3) ? math.max(1, width - 1) : width
                    ln = line.new(startBar, pv, endBar, pv, color = cBase, width = effWidth, style = lineStyle)
                    array.push(htfLines, ln)
                    if showHTFLineLabels
                        lab = label.new(endBar, pv, htf_label_tag(tc), color = color.new(cBase, 80), textcolor = cBase, style = label.style_label_left, size = size.tiny)
                        array.push(htfLineLabels, lab)

if barstate.islast and useMTF and showHTFLines and avwapAllowed and vmLines
    if useHTF1
        draw_htf_lines(htf1_types, htf1_prices, htf1Color, htfLineWidth)
    if useHTF2
        draw_htf_lines(htf2_types, htf2_prices, htf2Color, htfLineWidth)
    if useHTF3
        draw_htf_lines(htf3_types, htf3_prices, htf3Color, htfLineWidth)

// ════════════════════════════════════════════════════════════════
// SECTION: NAKED POC RENDERING
// ════════════════════════════════════════════════════════════════

if barstate.islast and useNakedPOC and showNakedLines and vmLines
    nN = array.size(nakedPOCs)
    if nN > 0
        endBar = bar_index + 10
        for k = 0 to nN - 1
            npVal = array.get(nakedPOCs, k)
            npBar = array.get(nakedPOCBars, k)
            if not na(npVal)
                int startBar = npBar
                ln = line.new(startBar, npVal, endBar, npVal, color = nakedLineColor, width = 1, style = line.style_dotted)
                array.push(nakedLines, ln)

// ════════════════════════════════════════════════════════════════
// SECTION: HTF CONFLUENCE BANDS  (S/R lines + markers visual mode)
// ════════════════════════════════════════════════════════════════

var array<box> htfBands = array.new<box>()
// [OPT-4] rebuild on bar open/close only, not every tick.
if rebuildHeavy
    while array.size(htfBands) > 0
        box.delete(array.shift(htfBands))

draw_htf_bands(array<float> prices, color cBase, string htfTag) =>
    n = array.size(prices)
    if n > 0
        sorted = array.copy(prices)
        if n > 1
            for i = 1 to n - 1
                key = array.get(sorted, i)
                j = i - 1
                done = false
                while not done
                    if j < 0
                        done := true
                    else
                        if array.get(sorted, j) > key
                            array.set(sorted, j + 1, array.get(sorted, j))
                            j -= 1
                        else
                            done := true
                array.set(sorted, j + 1, key)

        tol = close * htfBandTolerance / 100.0
        bandLows   = array.new<float>()
        bandHighs  = array.new<float>()
        bandCounts = array.new<int>()
        i = 0
        while i < n
            cLow  = array.get(sorted, i)
            cHigh = cLow
            cCnt  = 1
            j = i + 1
            cont = true
            while cont
                if j >= n
                    cont := false
                else
                    nxt = array.get(sorted, j)
                    if (nxt - cHigh) <= tol
                        cHigh := nxt
                        cCnt  += 1
                        j += 1
                    else
                        cont := false
            array.push(bandLows,   cLow)
            array.push(bandHighs,  cHigh)
            array.push(bandCounts, cCnt)
            i := j

        nBands = array.size(bandLows)
        if nBands > 0
            if nBands > 1
                for ii = 1 to nBands - 1
                    kc = array.get(bandCounts, ii)
                    kl = array.get(bandLows,   ii)
                    kh = array.get(bandHighs,  ii)
                    j2 = ii - 1
                    done2 = false
                    while not done2
                        if j2 < 0
                            done2 := true
                        else
                            if array.get(bandCounts, j2) < kc
                                array.set(bandCounts, j2 + 1, array.get(bandCounts, j2))
                                array.set(bandLows,   j2 + 1, array.get(bandLows,   j2))
                                array.set(bandHighs,  j2 + 1, array.get(bandHighs,  j2))
                                j2 -= 1
                            else
                                done2 := true
                    array.set(bandCounts, j2 + 1, kc)
                    array.set(bandLows,   j2 + 1, kl)
                    array.set(bandHighs,  j2 + 1, kh)

            int drawN = math.min(nBands, htfBandMaxPerTF)
            startBar = bar_index - htfBandExtendBars * 3
            endBar   = bar_index + htfBandExtendBars
            for k = 0 to drawN - 1
                bL  = array.get(bandLows,   k)
                bH  = array.get(bandHighs,  k)
                bC  = array.get(bandCounts, k)
                if bH == bL
                    bH := bL + close * 0.0003
                    bL := bL - close * 0.0003
                // [VIS-1] Denser HTF clusters (more timeframes/levels stacked) render
                // more solid, so the strongest confluence bands read at a glance.
                int bandSolidBoost = math.min(20, math.max(0, bC - 1) * 5)
                bandCol = color.new(cBase, math.max(0, htfBandTransparency - bandSolidBoost))
                borderCol = color.new(cBase, math.max(0, htfBandTransparency - 25 - bandSolidBoost))
                bx = box.new(startBar, bH, endBar, bL,
                     border_color = borderCol,
                     bgcolor = bandCol,
                     border_width = 1)
                array.push(htfBands, bx)

if rebuildHeavy and useMTF and showHTFBands and vmZones and avwapAllowed
    if useHTF1
        draw_htf_bands(htf1_prices, htf1Color, "H1")
    if useHTF2
        draw_htf_bands(htf2_prices, htf2Color, "H2")
    if useHTF3
        draw_htf_bands(htf3_prices, htf3Color, "H3")

// ════════════════════════════════════════════════════════════════
// SECTION: ZONE STATE
// ════════════════════════════════════════════════════════════════

var array<int>   zStart    = array.new<int>()
var array<int>   zEnd      = array.new<int>()
var array<float> zLow      = array.new<float>()
var array<float> zHigh     = array.new<float>()
var array<int>   zMaxCount = array.new<int>()
var array<int>   zMaxPH    = array.new<int>()
var array<int>   zMaxPL    = array.new<int>()
var array<int>   zMaxPOC   = array.new<int>()
var array<int>   zMaxVA    = array.new<int>()
var array<int>   zMaxMTF   = array.new<int>()
var array<int>   zState    = array.new<int>()
var array<int>   zOutcome  = array.new<int>()
var array<int>   zLastConf = array.new<int>()
var array<box>   zBoxes    = array.new<box>()
var array<label> zLabels   = array.new<label>()
var array<line>  zSRLines       = array.new<line>()
var array<label> zFormMarkers   = array.new<label>()
var array<label> zStarLabels    = array.new<label>()
var array<label> zRightArrows   = array.new<label>()
var array<int>   zFlipCount     = array.new<int>()
var array<int>   zBias          = array.new<int>()
var array<int>   zCompromised   = array.new<int>()
var array<label> zCompLabels    = array.new<label>()
var array<int>   zCalDone       = array.new<int>()     // per-zone: first-test outcome recorded?
var int[]        calTest        = array.new<int>(6, 0) // resolved tests by star 1..5 (idx 0 unused)
var int[]        calHeld        = array.new<int>(6, 0) // holds by star 1..5
var int          calBaseTest    = 0
var int          calBaseHeld    = 0
var int[]        featTestY      = array.new<int>(4, 0)   // tests where feature present (0=MTF 1=POC 2=VA 3=Tight)
var int[]        featHeldY      = array.new<int>(4, 0)   // holds where feature present
var int[]        featTestN      = array.new<int>(4, 0)   // tests where feature absent
var int[]        featHeldN      = array.new<int>(4, 0)   // holds where feature absent

// Evidence weights = measured held%(with) − held%(without) per feature, in
// [-1,1]. Read from last bar's committed tallies (this bar's tally happens later
// on confirm), so the star nudge below never uses the very event it is scoring.
// na until a feature has ≥ calMinTests on BOTH sides. idx 0=MTF 1=POC 2=VA.
f_evLift(int fi) =>
    int tY = array.get(featTestY, fi)
    int hY = array.get(featHeldY, fi)
    int tN = array.get(featTestN, fi)
    int hN = array.get(featHeldN, fi)
    (tY >= calMinTests and tN >= calMinTests) ? hY / float(tY) - hN / float(tN) : na
evLiftMTF := f_evLift(0)
evLiftPOC := f_evLift(1)
evLiftVA  := f_evLift(2)
evReady   := not na(evLiftMTF) or not na(evLiftPOC) or not na(evLiftVA)

float foundClusterMid = na
float foundClusterLow = na
float foundClusterHi  = na
int   foundCount = 0
int   foundPH    = 0
int   foundPL    = 0
int   foundPOC   = 0
int   foundVA    = 0
int   foundMTF   = 0

// ════════════════════════════════════════════════════════════════
// SECTION: CLUSTER BUILDER
// ════════════════════════════════════════════════════════════════

if showConfluence and bar_index > maxBarAge_eff and zonesAllowed and barstate.isconfirmed
    n = array.size(barAVWAPs)
    if n >= minConfluence_eff
        // [OPT-6] Sort the per-bar level arrays in place — barAVWAPs/barTypes are
        // built fresh each bar (cleared at top of bar) and are not read again after
        // this point, so the previous defensive array.copy was pure allocation
        // churn on every confirmed bar. Aliasing preserves all downstream logic.
        prices = barAVWAPs
        types  = barTypes

        for i = 1 to n - 1
            keyP = array.get(prices, i)
            keyT = array.get(types,  i)
            j = i - 1
            done = false
            while not done
                if j < 0
                    done := true
                else
                    if array.get(prices, j) > keyP
                        array.set(prices, j + 1, array.get(prices, j))
                        array.set(types,  j + 1, array.get(types,  j))
                        j -= 1
                    else
                        done := true
            array.set(prices, j + 1, keyP)
            array.set(types,  j + 1, keyT)

        tolerance = close * confTolerance_eff / 100.0
        int   bestCount = 0
        float bestLow   = na
        float bestHi    = na
        int   bestPH    = 0
        int   bestPL    = 0
        int   bestPOC   = 0
        int   bestVA    = 0
        i = 0
        while i < n
            cLow   = array.get(prices, i)
            cHigh  = cLow
            cCount = 1
            t0     = array.get(types, i)
            cPH    = 0
            cPL    = 0
            cPOC   = 0
            cVA    = 0
            if t0 == 1 or t0 == 11 or t0 == 21 or t0 == 31
                cPH += 1
            else if t0 == -1 or t0 == -11 or t0 == -21 or t0 == -31
                cPL += 1
            else if t0 == 3 or t0 == 12 or t0 == 22 or t0 == 32 or t0 == 5
                cPOC += 1
            else if t0 == 4 or t0 == 13 or t0 == 23 or t0 == 33
                cVA += 1
            j = i + 1
            cont = true
            while cont
                if j >= n
                    cont := false
                else
                    nxt = array.get(prices, j)
                    if (nxt - cHigh) <= tolerance
                        cHigh := nxt
                        cCount += 1
                        tj = array.get(types, j)
                        if tj == 1 or tj == 11 or tj == 21 or tj == 31
                            cPH += 1
                        else if tj == -1 or tj == -11 or tj == -21 or tj == -31
                            cPL += 1
                        else if tj == 3 or tj == 12 or tj == 22 or tj == 32 or tj == 5
                            cPOC += 1
                        else if tj == 4 or tj == 13 or tj == 23 or tj == 33
                            cVA += 1
                        j += 1
                    else
                        cont := false
            if cCount > bestCount and cCount >= minConfluence_eff
                bestCount := cCount
                bestLow   := cLow
                bestHi    := cHigh
                bestPH    := cPH
                bestPL    := cPL
                bestPOC   := cPOC
                bestVA    := cVA
            i := j

        if bestCount >= minConfluence_eff
            foundCount      := bestCount
            foundClusterLow := bestLow
            foundClusterHi  := bestHi
            foundClusterMid := (bestLow + bestHi) / 2.0
            foundPH         := bestPH
            foundPL         := bestPL
            foundPOC        := bestPOC
            foundVA         := bestVA
            foundMTF        := count_mtf_alignment(foundClusterMid)
// ════════════════════════════════════════════════════════════════
// SECTION: ZONE MATCH / CREATE
// ════════════════════════════════════════════════════════════════

bool newZoneCreated  = false
int  newZoneStars    = 0
int  newZoneMTFAlign = 0

if foundCount >= minConfluence_eff
    matchTol = close * zoneMatchTol_eff / 100.0
    matched  = false
    ac = array.size(zStart)
    if ac > 0
        for k = 0 to ac - 1
            if not matched and array.get(zState, k) == 0
                emid = (array.get(zLow, k) + array.get(zHigh, k)) / 2.0
                if math.abs(foundClusterMid - emid) <= matchTol
                    matched := true
                    array.set(zEnd,      k, bar_index)
                    array.set(zLastConf, k, bar_index)
                    nL = math.min(array.get(zLow,  k), foundClusterLow)
                    nH = math.max(array.get(zHigh, k), foundClusterHi)
                    array.set(zLow,  k, nL)
                    array.set(zHigh, k, nH)
                    if foundCount > array.get(zMaxCount, k)
                        array.set(zMaxCount, k, foundCount)
                        array.set(zMaxPH,    k, foundPH)
                        array.set(zMaxPL,    k, foundPL)
                        array.set(zMaxPOC,   k, foundPOC)
                        array.set(zMaxVA,    k, foundVA)
                    if mtfRefresh
                        array.set(zMaxMTF, k, foundMTF)
                    else if foundMTF > array.get(zMaxMTF, k)
                        array.set(zMaxMTF, k, foundMTF)
                    b = array.get(zBoxes, k)
                    box.set_top(b,    nH)
                    box.set_bottom(b, nL)
                    box.set_right(b,  bar_index)
                    curCnt = array.get(zMaxCount, k)
                    curPH  = array.get(zMaxPH,    k)
                    curPL  = array.get(zMaxPL,    k)
                    curPOC = array.get(zMaxPOC,   k)
                    curVA  = array.get(zMaxVA,    k)
                    curMTF = array.get(zMaxMTF,   k)
                    box.set_border_width(b, is_premium(curCnt, curPH, curPL, curPOC, curVA, curMTF) ? premiumBorderW : 1)
                    lab = array.get(zLabels, k)
                    label.set_text(lab, build_label("●", foundCount, foundPH, foundPL, foundPOC, foundVA, curMTF, "Active"))
                    label.set_tooltip(lab, build_tooltip(foundCount, foundPH, foundPL, foundPOC, foundVA, curMTF, "Active"))
                    label.set_xy(lab, bar_index, (nH + nL) / 2.0)
                    updStars  = star_rating(curCnt, curPH, curPL, curPOC, curVA, curMTF)
                    updIsPrem = is_premium(curCnt, curPH, curPL, curPOC, curVA, curMTF)
                    sr_k = array.get(zSRLines, k)
                    line.set_x2(sr_k, bar_index + srLineExtendBars)
                    line.set_y1(sr_k, (nH + nL) / 2.0)
                    line.set_y2(sr_k, (nH + nL) / 2.0)
                    line.set_width(sr_k, math.max(1, math.min(4, updStars - 1)))
                    fm_k = array.get(zFormMarkers, k)
                    sl_k = array.get(zStarLabels, k)
                    updVisible = vmZones and showMarkers and updStars >= markersMinStars
                    updBias = array.get(zBias, k)
                    updDirCol = direction_color(0, 0)
                    label.set_text(fm_k, "")
                    label.set_color(fm_k, updVisible ? color.new(updDirCol, 15) : color.new(color.black, 100))
                    label.set_textcolor(fm_k, updVisible ? color.white : color.new(color.black, 100))
                    label.set_style(fm_k, marker_shape(0, 0, updBias))
                    label.set_tooltip(fm_k, build_tooltip(curCnt, curPH, curPL, curPOC, curVA, curMTF, "Active"))
                    label.set_text(sl_k, (updIsPrem ? "★" : "") + str.tostring(updStars))
                    label.set_textcolor(sl_k, updVisible ? updDirCol : color.new(color.black, 100))

    if not matched
        dH = foundClusterHi == foundClusterLow ? foundClusterHi + (close * 0.0005) : foundClusterHi
        dL = foundClusterHi == foundClusterLow ? foundClusterLow - (close * 0.0005) : foundClusterLow
        zMid_new = (dH + dL) / 2.0
        bw = is_premium(foundCount, foundPH, foundPL, foundPOC, foundVA, foundMTF) ? premiumBorderW : 1
        initStars = star_rating(foundCount, foundPH, foundPL, foundPOC, foundVA, foundMTF)
        initIsPrem = is_premium(foundCount, foundPH, foundPL, foundPOC, foundVA, foundMTF)
        initBiasRaw = compositional_bias_score(foundPH, foundPL, foundPOC, foundVA, zMid_new)
        initBias    = bias_direction(initBiasRaw)
        b = box.new(bar_index, dH, bar_index, dL, border_color = color.new(colActive, 30), bgcolor = f_zoneFill(colActive, initStars), border_width = bw)
        lab = label.new(bar_index, zMid_new, build_label("●", foundCount, foundPH, foundPL, foundPOC, foundVA, foundMTF, "Active"), color = color.new(colActive, 20), textcolor = color.white, style = label.style_label_left, size = size.tiny, tooltip = build_tooltip(foundCount, foundPH, foundPL, foundPOC, foundVA, foundMTF, "Active"))
        srLineVisible = vmZones and showSRLines
        srLineCol = srLineVisible ? color.new(colActive, 20) : color.new(color.black, 100)
        srLineWidth = math.max(1, math.min(4, initStars - 1))
        srLine = line.new(bar_index, zMid_new, bar_index + srLineExtendBars, zMid_new,
             color = srLineCol,
             width = srLineWidth,
             style = line.style_solid)
        markerVisible = vmZones and showMarkers and initStars >= markersMinStars
        markerDirCol  = direction_color(0, 0)
        markerBg      = markerVisible ? color.new(markerDirCol, 15) : color.new(color.black, 100)
        markerStyle   = marker_shape(0, 0, initBias)
        markerTxtCol  = markerVisible ? color.white : color.new(color.black, 100)
        formMarker = label.new(bar_index, zMid_new, "",
             color = markerBg,
             textcolor = markerTxtCol,
             style = markerStyle,
             size = size.tiny,
             tooltip = build_tooltip(foundCount, foundPH, foundPL, foundPOC, foundVA, foundMTF, "Active"))
        starTxt = (initIsPrem ? "★" : "") + str.tostring(initStars)
        starLabel = label.new(bar_index + 1, zMid_new, starTxt,
             color = color.new(color.black, 100),
             textcolor = markerVisible ? markerDirCol : color.new(color.black, 100),
             style = label.style_none,
             size = size.tiny,
             tooltip = "")
        rightArrow = label.new(bar_index, zMid_new, "",
             color = color.new(color.black, 100),
             textcolor = color.new(color.black, 100),
             style = label.style_label_left,
             size = size.tiny)
        compLabel = label.new(bar_index, zMid_new, "",
             color = color.new(color.black, 100),
             textcolor = color.new(color.black, 100),
             style = label.style_label_left,
             size = size.tiny)
        array.push(zStart,    bar_index)
        array.push(zEnd,      bar_index)
        array.push(zLow,      dL)
        array.push(zHigh,     dH)
        array.push(zMaxCount, foundCount)
        array.push(zMaxPH,    foundPH)
        array.push(zMaxPL,    foundPL)
        array.push(zMaxPOC,   foundPOC)
        array.push(zMaxVA,    foundVA)
        array.push(zMaxMTF,   foundMTF)
        array.push(zState,    0)
        array.push(zOutcome,  0)
        array.push(zLastConf, bar_index)
        array.push(zBoxes,    b)
        array.push(zLabels,   lab)
        array.push(zSRLines,     srLine)
        array.push(zFormMarkers, formMarker)
        array.push(zStarLabels,  starLabel)
        array.push(zRightArrows, rightArrow)
        array.push(zFlipCount,   0)
        array.push(zBias,        initBias)
        array.push(zCompromised, 0)
        array.push(zCalDone,     0)
        array.push(zCompLabels,  compLabel)
        newZoneCreated  := true
        newZoneStars    := initStars
        newZoneMTFAlign := foundMTF

// ════════════════════════════════════════════════════════════════
// SECTION: ZONE TIMEOUT (active → pending)
// ════════════════════════════════════════════════════════════════

if barstate.isconfirmed and array.size(zStart) > 0
    for k = 0 to array.size(zStart) - 1
        if array.get(zState, k) == 0
            lc = array.get(zLastConf, k)
            if (bar_index - lc) > zoneTimeout
                array.set(zState, k, 1)
                b = array.get(zBoxes, k)
                box.set_bgcolor(b, f_zoneFill(colPending, star_rating(array.get(zMaxCount, k), array.get(zMaxPH, k), array.get(zMaxPL, k), array.get(zMaxPOC, k), array.get(zMaxVA, k), array.get(zMaxMTF, k))))
                box.set_border_color(b, color.new(colPending, 30))
                sr_k = array.get(zSRLines, k)
                if vmZones
                    line.set_color(sr_k, color.new(colPending, 20))
                fm_k = array.get(zFormMarkers, k)
                stCnt = array.get(zMaxCount, k)
                stPH  = array.get(zMaxPH,    k)
                stPL  = array.get(zMaxPL,    k)
                stPOC = array.get(zMaxPOC,   k)
                stVA  = array.get(zMaxVA,    k)
                stMTF = array.get(zMaxMTF,   k)
                stStars = star_rating(stCnt, stPH, stPL, stPOC, stVA, stMTF)
                stPrem  = is_premium(stCnt, stPH, stPL, stPOC, stVA, stMTF)
                stVisible = vmZones and showMarkers and stStars >= markersMinStars
                stBias = array.get(zBias, k)
                stDirCol = direction_color(1, 0)
                sl_pend = array.get(zStarLabels, k)
                if vmZones
                    label.set_text(fm_k, "")
                    label.set_color(fm_k, stVisible ? color.new(stDirCol, 15) : color.new(color.black, 100))
                    label.set_textcolor(fm_k, stVisible ? color.white : color.new(color.black, 100))
                    label.set_style(fm_k, marker_shape(1, 0, stBias))
                    label.set_text(sl_pend, (stPrem ? "★" : "") + str.tostring(stStars))
                    label.set_textcolor(sl_pend, stVisible ? stDirCol : color.new(color.black, 100))
                label.set_tooltip(fm_k, build_tooltip(stCnt, stPH, stPL, stPOC, stVA, stMTF, "Pending"))

// ════════════════════════════════════════════════════════════════
// SECTION: OUTCOME RESOLUTION (pending → resolved)
// ════════════════════════════════════════════════════════════════

if barstate.isconfirmed and array.size(zStart) > 0
    for k = 0 to array.size(zStart) - 1
        if array.get(zState, k) == 1
            zb = array.get(zEnd, k)
            if (bar_index - zb) >= outcomeBars
                zm = (array.get(zLow, k) + array.get(zHigh, k)) / 2.0
                move = (close - zm) / zm * 100.0
                string prefix     = "◆"
                string roleText   = "Chop"
                color  zc         = colChop
                int    outcomeVal = 0
                if move > outcomeThreshold
                    prefix     := "▲"
                    roleText   := "Support"
                    zc         := colSupport
                    outcomeVal := 1
                else if move < -outcomeThreshold
                    prefix     := "▼"
                    roleText   := "Resistance"
                    zc         := colResistance
                    outcomeVal := -1
                b = array.get(zBoxes, k)
                box.set_bgcolor(b, f_zoneFill(zc, star_rating(array.get(zMaxCount, k), array.get(zMaxPH, k), array.get(zMaxPL, k), array.get(zMaxPOC, k), array.get(zMaxVA, k), array.get(zMaxMTF, k))))
                box.set_border_color(b, color.new(zc, 30))
                lab = array.get(zLabels, k)
                cnt  = array.get(zMaxCount, k)
                ph   = array.get(zMaxPH,    k)
                pl   = array.get(zMaxPL,    k)
                poc  = array.get(zMaxPOC,   k)
                va   = array.get(zMaxVA,    k)
                mtfA = array.get(zMaxMTF,   k)
                label.set_text(lab, build_label(prefix, cnt, ph, pl, poc, va, mtfA, roleText))
                label.set_tooltip(lab, build_tooltip(cnt, ph, pl, poc, va, mtfA, roleText + " zone"))
                label.set_color(lab, color.new(zc, 20))
                resStars = star_rating(cnt, ph, pl, poc, va, mtfA)
                resPrem  = is_premium(cnt, ph, pl, poc, va, mtfA)
                sr_k = array.get(zSRLines, k)
                if not na(sr_k)
                    line.delete(sr_k)
                fm_k = array.get(zFormMarkers, k)
                resVisible = vmZones and showMarkers and resStars >= markersMinStars
                resDirCol = direction_color(2, outcomeVal)
                sl_res = array.get(zStarLabels, k)
                if vmZones
                    label.set_text(fm_k, "")
                    label.set_color(fm_k, resVisible ? color.new(resDirCol, 15) : color.new(color.black, 100))
                    label.set_textcolor(fm_k, resVisible ? color.white : color.new(color.black, 100))
                    label.set_style(fm_k, marker_shape(2, outcomeVal, 0))
                    label.set_text(sl_res, (resPrem ? "★" : "") + str.tostring(resStars))
                    label.set_textcolor(sl_res, resVisible ? resDirCol : color.new(color.black, 100))
                label.set_tooltip(fm_k, build_tooltip(cnt, ph, pl, poc, va, mtfA, roleText + " zone"))
                array.set(zState,   k, 2)
                array.set(zOutcome, k, outcomeVal)

// ════════════════════════════════════════════════════════════════
// SECTION: COMPROMISED STATE DETECTION
// ════════════════════════════════════════════════════════════════

if barstate.isconfirmed and array.size(zStart) > 0
    breakBuffer = close * 0.0005
    for k = 0 to array.size(zStart) - 1
        if array.get(zState, k) == 2
            outc = array.get(zOutcome, k)
            if outc == 1 or outc == -1
                zL = array.get(zLow,  k)
                zH = array.get(zHigh, k)
                prevComp = array.get(zCompromised, k)
                newComp = 0
                if outc == 1
                    if close < zL - breakBuffer
                        newComp := 2
                    else if low <= zH and high >= zL
                        newComp := 1
                    else
                        newComp := 0
                else
                    if close > zH + breakBuffer
                        newComp := 2
                    else if low <= zH and high >= zL
                        newComp := 1
                    else
                        newComp := 0
                if newComp != prevComp
                    array.set(zCompromised, k, newComp)
                    if array.get(zCalDone, k) == 0
                        bool broke    = newComp == 2
                        bool heldTest = prevComp == 1 and newComp == 0
                        if broke or heldTest
                            int csStars = star_rating_base(array.get(zMaxCount, k), array.get(zMaxPH, k), array.get(zMaxPL, k), array.get(zMaxPOC, k), array.get(zMaxVA, k), array.get(zMaxMTF, k))
                            array.set(calTest, csStars, array.get(calTest, csStars) + 1)
                            calBaseTest += 1
                            if heldTest
                                array.set(calHeld, csStars, array.get(calHeld, csStars) + 1)
                                calBaseHeld += 1
                            bool fMTF   = array.get(zMaxMTF, k) > 0
                            bool fPOC   = array.get(zMaxPOC, k) > 0
                            bool fVA    = array.get(zMaxVA,  k) > 0
                            bool fTight = (array.get(zHigh, k) - array.get(zLow, k)) <= atrSafe
                            f_featTally(0, fMTF,   heldTest, featTestY, featHeldY, featTestN, featHeldN)
                            f_featTally(1, fPOC,   heldTest, featTestY, featHeldY, featTestN, featHeldN)
                            f_featTally(2, fVA,    heldTest, featTestY, featHeldY, featTestN, featHeldN)
                            f_featTally(3, fTight, heldTest, featTestY, featHeldY, featTestN, featHeldN)
                            array.set(zCalDone, k, 1)
                    bb = array.get(zBoxes, k)
                    cl = array.get(zCompLabels, k)
                    zMid_c = (zL + zH) / 2.0
                    if newComp == 0
                        zc_h = outc == 1 ? colSupport : colResistance
                        box.set_border_color(bb, color.new(zc_h, 30))
                        box.set_border_style(bb, line.style_solid)
                        label.set_text(cl, "")
                        label.set_color(cl, color.new(color.black, 100))
                        label.set_textcolor(cl, color.new(color.black, 100))
                    else if newComp == 1
                        zc_t = outc == 1 ? colSupport : colResistance
                        box.set_border_color(bb, color.new(zc_t, 10))
                        box.set_border_style(bb, line.style_dashed)
                        label.set_text(cl, "")
                        label.set_color(cl, color.new(color.black, 100))
                        label.set_textcolor(cl, color.new(color.black, 100))
                    else
                        box.set_border_style(bb, line.style_dashed)
                        box.set_border_color(bb, color.new(color.orange, 0))
                        label.set_xy(cl, bar_index, zMid_c)
                        label.set_text(cl, "BROKEN")
                        label.set_color(cl, color.new(color.orange, 10))
                        label.set_textcolor(cl, color.white)
                        label.set_style(cl, label.style_label_left)
                        label.set_size(cl, size.tiny)

// ════════════════════════════════════════════════════════════════
// SECTION: POLARITY FLIP DETECTION
// ════════════════════════════════════════════════════════════════

bool polarityFlipped        = false
bool flippedToSupport       = false
bool flippedToResistance    = false

if barstate.isconfirmed and enablePolarityFlip and array.size(zStart) > 0
    flipPctR = flipThreshold / 100.0
    for k = 0 to array.size(zStart) - 1
        if array.get(zState, k) == 2
            curOutc = array.get(zOutcome, k)
            if curOutc == 1 or curOutc == -1
                zL = array.get(zLow,  k)
                zH = array.get(zHigh, k)
                pastThreshold = false
                if curOutc == -1
                    pastThreshold := close > zH * (1.0 + flipPctR)
                else
                    pastThreshold := close < zL * (1.0 - flipPctR)
                curCount = array.get(zFlipCount, k)
                if pastThreshold
                    curCount += 1
                    array.set(zFlipCount, k, curCount)
                    if curCount >= flipConfirmBars
                        newOutc = curOutc * -1
                        array.set(zOutcome, k, newOutc)
                        array.set(zFlipCount, k, 0)
                        polarityFlipped     := true
                        flippedToSupport    := newOutc == 1
                        flippedToResistance := newOutc == -1
                        newCol = newOutc == 1 ? colSupport : colResistance
                        newRole = newOutc == 1 ? "Support (flipped from Resistance)" : "Resistance (flipped from Support)"
                        bb = array.get(zBoxes, k)
                        box.set_bgcolor(bb, f_zoneFill(newCol, star_rating(array.get(zMaxCount, k), array.get(zMaxPH, k), array.get(zMaxPL, k), array.get(zMaxPOC, k), array.get(zMaxVA, k), array.get(zMaxMTF, k))))
                        box.set_border_color(bb, color.new(newCol, 30))
                        box.set_border_style(bb, line.style_solid)
                        array.set(zCompromised, k, 0)
                        cl_flip = array.get(zCompLabels, k)
                        label.set_text(cl_flip, "")
                        label.set_color(cl_flip, color.new(color.black, 100))
                        label.set_textcolor(cl_flip, color.new(color.black, 100))
                        fmm = array.get(zFormMarkers, k)
                        fStars = star_rating(array.get(zMaxCount, k), array.get(zMaxPH, k), array.get(zMaxPL, k), array.get(zMaxPOC, k), array.get(zMaxVA, k), array.get(zMaxMTF, k))
                        fPrem = is_premium(array.get(zMaxCount, k), array.get(zMaxPH, k), array.get(zMaxPL, k), array.get(zMaxPOC, k), array.get(zMaxVA, k), array.get(zMaxMTF, k))
                        flipVisible = vmZones and showMarkers and fStars >= markersMinStars
                        flipDirCol = direction_color(2, newOutc)
                        sl_flip = array.get(zStarLabels, k)
                        if vmZones
                            label.set_color(fmm, flipVisible ? color.new(flipDirCol, 15) : color.new(color.black, 100))
                            label.set_textcolor(fmm, flipVisible ? color.white : color.new(color.black, 100))
                            label.set_style(fmm, marker_shape(2, newOutc, 0))
                            label.set_text(sl_flip, (fPrem ? "★" : "") + str.tostring(fStars))
                            label.set_textcolor(sl_flip, flipVisible ? flipDirCol : color.new(color.black, 100))
                        label.set_tooltip(fmm, build_tooltip(array.get(zMaxCount, k), array.get(zMaxPH, k), array.get(zMaxPL, k), array.get(zMaxPOC, k), array.get(zMaxVA, k), array.get(zMaxMTF, k), newRole))
                        labx = array.get(zLabels, k)
                        newPrefix = newOutc == 1 ? "▲" : "▼"
                        newRoleText = newOutc == 1 ? "Support" : "Resistance"
                        label.set_text(labx, build_label(newPrefix, array.get(zMaxCount, k), array.get(zMaxPH, k), array.get(zMaxPL, k), array.get(zMaxPOC, k), array.get(zMaxVA, k), array.get(zMaxMTF, k), newRoleText))
                        label.set_color(labx, color.new(newCol, 20))
                        label.set_tooltip(labx, build_tooltip(array.get(zMaxCount, k), array.get(zMaxPH, k), array.get(zMaxPL, k), array.get(zMaxPOC, k), array.get(zMaxVA, k), array.get(zMaxMTF, k), newRole))
                else
                    array.set(zFlipCount, k, 0)

// ════════════════════════════════════════════════════════════════
// SECTION: ZONE CAP (evict oldest)
// ════════════════════════════════════════════════════════════════

while array.size(zStart) > maxZones
    bx = array.shift(zBoxes)
    if not na(bx)
        box.delete(bx)
    lb = array.shift(zLabels)
    if not na(lb)
        label.delete(lb)
    sl = array.shift(zSRLines)
    if not na(sl)
        line.delete(sl)
    fm = array.shift(zFormMarkers)
    if not na(fm)
        label.delete(fm)
    sl_star = array.shift(zStarLabels)
    if not na(sl_star)
        label.delete(sl_star)
    ra = array.shift(zRightArrows)
    if not na(ra)
        label.delete(ra)
    array.shift(zFlipCount)
    array.shift(zBias)
    array.shift(zCompromised)
    array.shift(zCalDone)
    cl = array.shift(zCompLabels)
    if not na(cl)
        label.delete(cl)
    array.shift(zStart)
    array.shift(zEnd)
    array.shift(zLow)
    array.shift(zHigh)
    array.shift(zMaxCount)
    array.shift(zMaxPH)
    array.shift(zMaxPL)
    array.shift(zMaxPOC)
    array.shift(zMaxVA)
    array.shift(zMaxMTF)
    array.shift(zState)
    array.shift(zOutcome)
    array.shift(zLastConf)

// ════════════════════════════════════════════════════════════════
// SECTION: PRICE ENTERED RESOLVED ZONE
// ════════════════════════════════════════════════════════════════

bool priceEnteredSupport    = false
bool priceEnteredResistance = false

// [FIX-3] Gate the "price entered zone" detection to bar close so its alerts fire
// once on the confirmed entry rather than repainting on an intrabar poke that
// reverses before close — consistent with the engine's close-only state discipline.
if barstate.isconfirmed and array.size(zStart) > 0
    for k = 0 to array.size(zStart) - 1
        if array.get(zState, k) == 2
            outc = array.get(zOutcome, k)
            zL   = array.get(zLow,  k)
            zH   = array.get(zHigh, k)
            wasOutside = close[1] < zL or close[1] > zH
            nowInside  = close >= zL and close <= zH
            if wasOutside and nowInside
                if outc == 1
                    priceEnteredSupport := true
                else if outc == -1
                    priceEnteredResistance := true

// ════════════════════════════════════════════════════════════════
// SECTION: TOP-N S/R LINES
// ════════════════════════════════════════════════════════════════

var array<line>  topSRLines = array.new<line>()

// [OPT-4] rebuild on bar open/close only, not every tick.
if rebuildHeavy
    while array.size(topSRLines) > 0
        line.delete(array.shift(topSRLines))

if rebuildHeavy and showSRLines and vmZones and array.size(zStart) > 0
    nZ = array.size(zStart)
    candIdx   = array.new<int>()
    candScore = array.new<float>()

    for k = 0 to nZ - 1
        st = array.get(zState, k)
        if st == 2
            outc = array.get(zOutcome, k)
            comp = array.get(zCompromised, k)
            skipChop = (outc == 0) and not srLinesIncludeChop
            skipBroken = comp == 2
            zMid_k = (array.get(zLow, k) + array.get(zHigh, k)) / 2.0
            skipStale = (outc == 1 and zMid_k > close) or (outc == -1 and zMid_k < close)
            if not skipChop and not skipBroken and not skipStale
                cnt  = array.get(zMaxCount, k)
                ph   = array.get(zMaxPH,    k)
                pl   = array.get(zMaxPL,    k)
                poc  = array.get(zMaxPOC,   k)
                va   = array.get(zMaxVA,    k)
                mtfA = array.get(zMaxMTF,   k)
                stars = star_rating(cnt, ph, pl, poc, va, mtfA)
                if stars >= srLinesMinStars
                    barsAgo = bar_index - array.get(zEnd, k)
                    recencyBonus = math.max(0.0, 5.0 - (barsAgo / 30.0))
                    score = stars * 10.0 + recencyBonus
                    array.push(candIdx, k)
                    array.push(candScore, score)

    nCand = array.size(candIdx)
    if nCand > 0
        if nCand > 1
            for i = 1 to nCand - 1
                kScore = array.get(candScore, i)
                kIdx   = array.get(candIdx, i)
                j = i - 1
                done = false
                while not done
                    if j < 0
                        done := true
                    else if array.get(candScore, j) < kScore
                        array.set(candScore, j + 1, array.get(candScore, j))
                        array.set(candIdx,   j + 1, array.get(candIdx,   j))
                        j -= 1
                    else
                        done := true
                array.set(candScore, j + 1, kScore)
                array.set(candIdx,   j + 1, kIdx)

        drawN = math.min(nCand, srLinesTopN)
        for r = 0 to drawN - 1
            zk    = array.get(candIdx, r)
            outc  = array.get(zOutcome, zk)
            zMid  = (array.get(zLow, zk) + array.get(zHigh, zk)) / 2.0
            lineCol = outc == 1 ? colSupport : outc == -1 ? colResistance : colChop
            cnt2  = array.get(zMaxCount, zk)
            ph2   = array.get(zMaxPH,    zk)
            pl2   = array.get(zMaxPL,    zk)
            poc2  = array.get(zMaxPOC,   zk)
            va2   = array.get(zMaxVA,    zk)
            mtfA2 = array.get(zMaxMTF,   zk)
            sCnt  = star_rating(cnt2, ph2, pl2, poc2, va2, mtfA2)
            lwidth = math.max(1, math.min(4, sCnt - 1))
            startBar = array.get(zEnd, zk)
            endBar   = bar_index + srLineExtendBars
            ln = line.new(startBar, zMid, endBar, zMid,
                 color = color.new(lineCol, 20),
                 width = lwidth,
                 style = line.style_solid)
            array.push(topSRLines, ln)

// ════════════════════════════════════════════════════════════════
// SECTION: HEADLINE ANSWER 1 — Movement Range band
// ════════════════════════════════════════════════════════════════

var box   rangeBandBox    = na
var label rangeBandHiLbl  = na
var label rangeBandLoLbl  = na

// [OPT-4] rebuild on bar open/close only, not every tick.
if rebuildHeavy and showRangeBand
    if not na(rangeBandBox)
        box.delete(rangeBandBox)
    if not na(rangeBandHiLbl)
        label.delete(rangeBandHiLbl)
    if not na(rangeBandLoLbl)
        label.delete(rangeBandLoLbl)

    lookback = math.min(rangeBandBars, bar_index)
    if lookback > 1
        float rngHi = high
        float rngLo = low
        for kk = 0 to lookback - 1
            if high[kk] > rngHi
                rngHi := high[kk]
            if low[kk] < rngLo
                rngLo := low[kk]

        rngPts = rngHi - rngLo
        rngPct = (rngPts / close) * 100.0

        startBar = bar_index - lookback
        endBar   = bar_index + 30
        rangeBandBox := box.new(startBar, rngHi, endBar, rngLo,
             border_color = color.new(color.aqua, 40),
             bgcolor      = color.new(color.aqua, rangeBandTransp),
             border_width = 1,
             border_style = line.style_dashed)

        rangeBandHiLbl := label.new(endBar, rngHi, "RANGE HI " + str.tostring(rngHi, "#.##"),
             color = color.new(color.aqua, 25),
             textcolor = color.white,
             style = label.style_label_left,
             size = size.tiny)
        rngTxt = "RANGE LO " + str.tostring(rngLo, "#.##") + "  (" + str.tostring(rngPts, "#.#") + "pts / " + str.tostring(rngPct, "#.##") + "%)"
        rangeBandLoLbl := label.new(endBar, rngLo, rngTxt,
             color = color.new(color.aqua, 25),
             textcolor = color.white,
             style = label.style_label_left,
             size = size.tiny)

// ════════════════════════════════════════════════════════════════
// SECTION: HEADLINE ANSWER 2 — Major S/R lines (top 2 each)
// ════════════════════════════════════════════════════════════════

var array<line>  majorSRLines  = array.new<line>()
var array<label> majorSRLabels = array.new<label>()

// [OPT-4] rebuild on bar open/close only, not every tick.
if rebuildHeavy and showMajorSR
    while array.size(majorSRLines) > 0
        line.delete(array.shift(majorSRLines))
    while array.size(majorSRLabels) > 0
        label.delete(array.shift(majorSRLabels))

    nZ2 = array.size(zStart)
    if nZ2 > 0
        supIdx   = array.new<int>()
        supDist  = array.new<float>()
        supStars = array.new<int>()
        resIdx   = array.new<int>()
        resDist  = array.new<float>()
        resStarsArr = array.new<int>()

        for k = 0 to nZ2 - 1
            if array.get(zState, k) == 2
                outc2 = array.get(zOutcome, k)
                comp2 = array.get(zCompromised, k)
                if (outc2 == 1 or outc2 == -1) and comp2 != 2
                    cnt2  = array.get(zMaxCount, k)
                    ph2   = array.get(zMaxPH,    k)
                    pl2   = array.get(zMaxPL,    k)
                    poc2  = array.get(zMaxPOC,   k)
                    va2   = array.get(zMaxVA,    k)
                    mtfA2 = array.get(zMaxMTF,   k)
                    stars2 = star_rating(cnt2, ph2, pl2, poc2, va2, mtfA2)
                    if stars2 >= majorSRMinStars
                        zMid2 = (array.get(zLow, k) + array.get(zHigh, k)) / 2.0
                        if outc2 == 1 and zMid2 < close
                            array.push(supIdx,   k)
                            array.push(supDist,  close - zMid2)
                            array.push(supStars, stars2)
                        if outc2 == -1 and zMid2 > close
                            array.push(resIdx,   k)
                            array.push(resDist,  zMid2 - close)
                            array.push(resStarsArr, stars2)

        for side = 0 to 1
            useIdx   = side == 0 ? supIdx   : resIdx
            useDist  = side == 0 ? supDist  : resDist
            useStars = side == 0 ? supStars : resStarsArr
            sideLabel = side == 0 ? "SUP" : "RES"
            sideCol   = side == 0 ? colSupport : colResistance

            n = array.size(useIdx)
            int picks = math.min(2, n)
            picked = array.new<int>()
            if picks > 0 and n > 0
                for p = 0 to picks - 1
                    int bestPos = -1
                    int bestStars = -1
                    float bestDist = 1e10
                    for q = 0 to n - 1
                        alreadyPicked = false
                        if array.size(picked) > 0
                            for pp = 0 to array.size(picked) - 1
                                if array.get(picked, pp) == q
                                    alreadyPicked := true
                        if not alreadyPicked
                            s = array.get(useStars, q)
                            d = array.get(useDist,  q)
                            better = s > bestStars or (s == bestStars and d < bestDist)
                            if better
                                bestPos := q
                                bestStars := s
                                bestDist  := d
                    if bestPos >= 0
                        array.push(picked, bestPos)
                        zk2 = array.get(useIdx, bestPos)
                        zMid_pick = (array.get(zLow, zk2) + array.get(zHigh, zk2)) / 2.0
                        distVal = array.get(useDist, bestPos)
                        distSign = side == 0 ? "-" : "+"
                        startB = bar_index - 100
                        endB   = bar_index + 50
                        ln2 = line.new(startB, zMid_pick, endB, zMid_pick,
                             color = color.new(sideCol, 15),
                             width = 2,
                             style = line.style_solid)
                        array.push(majorSRLines, ln2)
                        labTxt = sideLabel + " ★" + str.tostring(bestStars) + "\n" + str.tostring(zMid_pick, "#.##") + "  " + distSign + str.tostring(distVal, "#.#") + "p"
                        lb2 = label.new(endB, zMid_pick, labTxt,
                             color = color.new(sideCol, 10),
                             textcolor = color.white,
                             style = label.style_label_left,
                             size = size.tiny)
                        array.push(majorSRLabels, lb2)

// ════════════════════════════════════════════════════════════════
// SECTION: CURRENT PRICE LINE
// ────────────────────────────────────────────────────────────────
// Cheap overlay — kept on barstate.islast so the price reference stays
// accurate on every tick.
// ════════════════════════════════════════════════════════════════

var line  priceLine    = na
var label priceLineLbl = na

if barstate.islast
    if not na(priceLine)
        line.delete(priceLine)
    if not na(priceLineLbl)
        label.delete(priceLineLbl)

if barstate.islast and showPriceLine
    startB_p = bar_index - 100
    endB_p   = bar_index + 50
    priceLine := line.new(startB_p, close, endB_p, close,
         color = color.new(color.white, 70),
         width = 1,
         style = line.style_dotted)
    priceLineLbl := label.new(endB_p, close, str.tostring(close, "#.##"),
         color = color.new(color.gray, 40),
         textcolor = color.white,
         style = label.style_label_left,
         size = size.tiny)

// ════════════════════════════════════════════════════════════════
// SECTION: ALERTCONDITIONS
// ════════════════════════════════════════════════════════════════

alertcondition(newZoneCreated and newZoneStars >= 4 and alertOnHighQuality, title = "High-quality zone (4-5⭐)", message = "Confluence Zone Engine: HIGH QUALITY zone (4-5⭐) at {{ticker}} {{close}}")
alertcondition(newZoneCreated and newZoneMTFAlign >= 1 and alertOnMTFAligned, title = "Zone aligned with HTF",     message = "Confluence Zone Engine: zone aligned with HTF level at {{ticker}} {{close}}")
alertcondition(priceEnteredSupport    and alertOnPriceEnter,                  title = "Price entered support",    message = "Confluence Zone Engine: price entered SUPPORT at {{ticker}} {{close}}")
alertcondition(priceEnteredResistance and alertOnPriceEnter,                  title = "Price entered resistance", message = "Confluence Zone Engine: price entered RESISTANCE at {{ticker}} {{close}}")
alertcondition(healthDegradedEdge and alertOnHealthDrop,                      title = "Data health degraded",     message = "Confluence Zone Engine: data health changed at {{ticker}} — see badge")
alertcondition(flippedToSupport    and alertOnPolFlip,                        title = "Polarity flip: R → S",     message = "Confluence Zone Engine: Resistance flipped to SUPPORT at {{ticker}} {{close}}")
alertcondition(flippedToResistance and alertOnPolFlip,                        title = "Polarity flip: S → R",     message = "Confluence Zone Engine: Support flipped to RESISTANCE at {{ticker}} {{close}}")

// ════════════════════════════════════════════════════════════════
// SECTION: EXP_* HIDDEN PLOTS
// ════════════════════════════════════════════════════════════════

float expTopCenter     = na
float expTopStars      = na
int   expTopState      = 0
int   expTopMTFCount   = 0
float expNearSupport   = na
float expNearSupportDistATR = na
float expNearResist    = na
float expNearResistDistATR  = na
int   expTotalZones    = 0
int   expPremiumCount  = 0

if array.size(zStart) > 0
    float bestScore  = -1.0
    int   bestIdx    = -1
    float nearSupAbs = 1e20
    float nearResAbs = 1e20

    expTotalZones := array.size(zStart)

    for k = 0 to array.size(zStart) - 1
        zStateK   = array.get(zState,   k)
        zOutK     = array.get(zOutcome, k)
        zLk       = array.get(zLow,     k)
        zHk       = array.get(zHigh,    k)
        zMid      = (zLk + zHk) / 2.0
        zCnt      = array.get(zMaxCount, k)
        zPHk      = array.get(zMaxPH,    k)
        zPLk      = array.get(zMaxPL,    k)
        zPOCk     = array.get(zMaxPOC,   k)
        zVAk      = array.get(zMaxVA,    k)
        zMTFk     = array.get(zMaxMTF,   k)
        zStarsK   = star_rating(zCnt, zPHk, zPLk, zPOCk, zVAk, zMTFk)

        bool zIsPremK = showPremium and zStarsK >= premiumMinStars and zMTFk >= premiumMinMTF
        if zIsPremK
            expPremiumCount += 1

        proximity = 1.0 / (math.abs(close - zMid) / atrSafe + 1.0)
        scoreK    = zStarsK * 10.0 + proximity
        if scoreK > bestScore
            bestScore := scoreK
            bestIdx   := k

        if zStateK == 2 and array.get(zCompromised, k) != 2
            distAbs = math.abs(close - zMid)
            if zOutK == 1 and close >= zMid and distAbs < nearSupAbs
                nearSupAbs              := distAbs
                expNearSupport          := zMid
                expNearSupportDistATR   := distAbs / atrSafe
            if zOutK == -1 and close <= zMid and distAbs < nearResAbs
                nearResAbs              := distAbs
                expNearResist           := zMid
                expNearResistDistATR    := distAbs / atrSafe

    if bestIdx >= 0
        zLk     = array.get(zLow,     bestIdx)
        zHk     = array.get(zHigh,    bestIdx)
        expTopCenter   := (zLk + zHk) / 2.0
        zCnt    = array.get(zMaxCount, bestIdx)
        zPHk    = array.get(zMaxPH,    bestIdx)
        zPLk    = array.get(zMaxPL,    bestIdx)
        zPOCk   = array.get(zMaxPOC,   bestIdx)
        zVAk    = array.get(zMaxVA,    bestIdx)
        zMTFk   = array.get(zMaxMTF,   bestIdx)
        expTopStars    := star_rating(zCnt, zPHk, zPLk, zPOCk, zVAk, zMTFk)
        expTopState    := array.get(zState,   bestIdx)
        expTopMTFCount := zMTFk

// [VIS-2] Directional bias ribbon — a faint background wash of the current
// structural lean, for a chart-wide movement-trend read. Uses the committed
// nearest-resolved-support / nearest-resolved-resistance relationship computed
// above (every bar, non-repainting). Bullish = above all zones; bearish = below.
color biasRibbonCol = na
if showBiasRibbon
    bool ribBull = not na(expNearSupport) and na(expNearResist)
    bool ribBear = not na(expNearResist)  and na(expNearSupport)
    biasRibbonCol := ribBull ? color.new(colSupport, biasRibbonTransp) : ribBear ? color.new(colResistance, biasRibbonTransp) : na
bgcolor(biasRibbonCol, title = "Directional bias ribbon")

plot(expTopCenter,          title = "EXP_TopZoneCenter",     display = display.data_window)
plot(expTopStars,           title = "EXP_TopZoneStars",      display = display.data_window)
plot(expTopState,           title = "EXP_TopZoneState",      display = display.data_window)
plot(expTopMTFCount,        title = "EXP_TopZoneMTFCount",   display = display.data_window)
plot(expNearSupport,        title = "EXP_NearestSupport",    display = display.data_window)
plot(expNearSupportDistATR, title = "EXP_NearSupDistATR",    display = display.data_window)
plot(expNearResist,         title = "EXP_NearestResistance", display = display.data_window)
plot(expNearResistDistATR,  title = "EXP_NearResDistATR",    display = display.data_window)
plot(expTotalZones,         title = "EXP_TotalZones",        display = display.data_window)
plot(expPremiumCount,       title = "EXP_PremiumCount",      display = display.data_window)
plot(healthCode,            title = "EXP_DataHealth",        display = display.data_window)
plot(foundCount,            title = "EXP_CurrentConfluence", display = display.data_window)
plot(foundMTF,              title = "EXP_CurrentMTFAlign",   display = display.data_window)
plot(atrSafe,               title = "EXP_ATR14",             display = display.data_window)
plot(useNakedPOC ? array.size(nakedPOCs) : 0, title = "EXP_NakedPOCCount", display = display.data_window)
plot(nz(avgPivotQuality, 0), title = "EXP_AvgPivotQuality",                display = display.data_window)
plot(calBaseTest > 0 ? calBaseHeld / float(calBaseTest) * 100.0 : na,                                              title = "EXP_ZoneRespectBase", display = display.data_window)
plot(array.get(calTest, 5) >= calMinTests ? array.get(calHeld, 5) / float(array.get(calTest, 5)) * 100.0 : na,    title = "EXP_Respect5star",    display = display.data_window)
plot(array.get(calTest, 4) >= calMinTests ? array.get(calHeld, 4) / float(array.get(calTest, 4)) * 100.0 : na,    title = "EXP_Respect4star",    display = display.data_window)
plot(array.get(featTestY,0) >= calMinTests and array.get(featTestN,0) >= calMinTests ? array.get(featHeldY,0)/float(array.get(featTestY,0))*100.0 - array.get(featHeldN,0)/float(array.get(featTestN,0))*100.0 : na, title = "EXP_MTFRespectLift",   display = display.data_window)
plot(array.get(featTestY,1) >= calMinTests and array.get(featTestN,1) >= calMinTests ? array.get(featHeldY,1)/float(array.get(featTestY,1))*100.0 - array.get(featHeldN,1)/float(array.get(featTestN,1))*100.0 : na, title = "EXP_POCRespectLift",   display = display.data_window)
plot(array.get(featTestY,2) >= calMinTests and array.get(featTestN,2) >= calMinTests ? array.get(featHeldY,2)/float(array.get(featTestY,2))*100.0 - array.get(featHeldN,2)/float(array.get(featTestN,2))*100.0 : na, title = "EXP_VARespectLift",    display = display.data_window)
plot(array.get(featTestY,3) >= calMinTests and array.get(featTestN,3) >= calMinTests ? array.get(featHeldY,3)/float(array.get(featTestY,3))*100.0 - array.get(featHeldN,3)/float(array.get(featTestN,3))*100.0 : na, title = "EXP_TightRespectLift", display = display.data_window)
// ════════════════════════════════════════════════════════════════
// SECTION: DATA-HEALTH BADGE  (cheap overlay — every tick)
// ════════════════════════════════════════════════════════════════

var label healthBadge = na

if barstate.islast and showHealthBadge
    if not na(healthBadge)
        label.delete(healthBadge)
    badgeText = "● Data: " + healthTxt
    healthBadge := label.new(bar_index + 5, high + (atrSafe * 2.5), badgeText, color = color.new(healthCol, 70), textcolor = color.white, style = label.style_label_left, size = size.tiny, tooltip = "Health detail:\n" + healthDetail + "\n\nHealth codes:\n  OK        = full scoring active\n  DEGRADED  = some sources stale; stars capped at 4 if penalty on\n  CRITICAL  = volumeless / volume-broken instrument; zones suppressed if strict mode on")

// ════════════════════════════════════════════════════════════════
// SECTION: ON-CHART DASHBOARD  (cheap overlay — every tick)
// ════════════════════════════════════════════════════════════════

calPos(string p) =>
    p == "Top-left" ? position.top_left : p == "Top-right" ? position.top_right : p == "Bottom-left" ? position.bottom_left : p == "Middle-right" ? position.middle_right : position.bottom_right

var table dashTbl = na
if showDash and barstate.islast
    if not na(dashTbl)
        table.delete(dashTbl)
    bool pro = dashMode == "Pro"
    int rows = pro ? 13 : 7
    dashTbl := table.new(calPos(dashPosition), 2, rows, bgcolor = thPanel, border_width = 1, border_color = thBorder, frame_width = 1, frame_color = thBorder)

    // header
    table.cell(dashTbl, 0, 0, "CONFLUENCE ZONE ENGINE", text_color = thHdrTx, bgcolor = thHdrBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dashTbl, 1, 0, syminfo.ticker, text_color = thAccent, bgcolor = thHdrBg, text_size = size.tiny, text_halign = text.align_right)

    // position / bias text (reused by Pro)
    string biasTxt = "—"
    color  biasCol = thDim
    if not na(expNearResist) and not na(expNearSupport)
        biasTxt := "in range"
        biasCol := thText
    else if not na(expNearSupport)
        biasTxt := "above zones ▲"
        biasCol := colSupport
    else if not na(expNearResist)
        biasTxt := "below zones ▼"
        biasCol := colResistance

    // price
    table.cell(dashTbl, 0, 1, "Price", text_color = thDim, bgcolor = thRowAlt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dashTbl, 1, 1, str.tostring(close, format.mintick), text_color = thText, text_size = size.tiny, text_halign = text.align_right)

    // resistance
    string resTxt = na(expNearResist) ? "—" : str.tostring(expNearResist, format.mintick) + "  +" + str.tostring(expNearResist - close, "#.#")
    table.cell(dashTbl, 0, 2, "▼ Resistance", text_color = colResistance, bgcolor = thRowAlt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dashTbl, 1, 2, resTxt, text_color = thText, text_size = size.tiny, text_halign = text.align_right)

    // support
    string supTxt = na(expNearSupport) ? "—" : str.tostring(expNearSupport, format.mintick) + "  -" + str.tostring(close - expNearSupport, "#.#")
    table.cell(dashTbl, 0, 3, "▲ Support", text_color = colSupport, bgcolor = thRowAlt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dashTbl, 1, 3, supTxt, text_color = thText, text_size = size.tiny, text_halign = text.align_right)

    // top zone
    string topTxt = na(expTopCenter) ? "—" : str.tostring(expTopCenter, format.mintick) + "  " + str.tostring(expTopStars, "#") + "★"
    table.cell(dashTbl, 0, 4, "Top zone", text_color = thDim, bgcolor = thRowAlt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dashTbl, 1, 4, topTxt, text_color = thStar, text_size = size.tiny, text_halign = text.align_right)

    // respect base rate
    float dashBase = calBaseTest > 0 ? calBaseHeld / float(calBaseTest) * 100.0 : na
    string respTxt = na(dashBase) ? "building…" : str.tostring(dashBase, "#") + "%  (" + str.tostring(calBaseTest) + ")"
    table.cell(dashTbl, 0, 5, "Respect", text_color = thDim, bgcolor = thRowAlt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dashTbl, 1, 5, respTxt, text_color = thText, text_size = size.tiny, text_halign = text.align_right)

    // data health
    table.cell(dashTbl, 0, 6, "Data", text_color = thDim, bgcolor = thRowAlt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dashTbl, 1, 6, healthTxt, text_color = healthCol, text_size = size.tiny, text_halign = text.align_right)

    if pro
        // HTFs
        table.cell(dashTbl, 0, 7, "HTFs", text_color = thDim, bgcolor = thRowAlt, text_size = size.tiny, text_halign = text.align_left)
        table.cell(dashTbl, 1, 7, useMTF ? (htf1TF + " / " + htf2TF + " / " + htf3TF) : "off", text_color = thText, text_size = size.tiny, text_halign = text.align_right)
        // MTF alignment of top zone
        table.cell(dashTbl, 0, 8, "MTF align", text_color = thDim, bgcolor = thRowAlt, text_size = size.tiny, text_halign = text.align_left)
        table.cell(dashTbl, 1, 8, str.tostring(expTopMTFCount) + " / 3", text_color = thText, text_size = size.tiny, text_halign = text.align_right)
        // zone counts
        table.cell(dashTbl, 0, 9, "Zones", text_color = thDim, bgcolor = thRowAlt, text_size = size.tiny, text_halign = text.align_left)
        table.cell(dashTbl, 1, 9, str.tostring(expTotalZones) + "  ·  " + str.tostring(expPremiumCount) + "P", text_color = thText, text_size = size.tiny, text_halign = text.align_right)
        // strongest predictive feature
        int bestF = -1
        float bestLift = -1.0e9
        for fi = 0 to 3
            int tY = array.get(featTestY, fi)
            int tN = array.get(featTestN, fi)
            if tY >= calMinTests and tN >= calMinTests
                float lf = array.get(featHeldY, fi) / float(tY) * 100.0 - array.get(featHeldN, fi) / float(tN) * 100.0
                if lf > bestLift
                    bestLift := lf
                    bestF := fi
        string bfName = bestF == 0 ? "MTF" : bestF == 1 ? "POC" : bestF == 2 ? "VA" : bestF == 3 ? "Tight" : "—"
        string bfTxt = bestF < 0 ? "building…" : bfName + "  " + (bestLift >= 0 ? "+" : "") + str.tostring(bestLift, "#")
        color bfCol = bestF < 0 ? thDim : bestLift > 0 ? colSupport : colResistance
        table.cell(dashTbl, 0, 10, "Best feature", text_color = thDim, bgcolor = thRowAlt, text_size = size.tiny, text_halign = text.align_left)
        table.cell(dashTbl, 1, 10, bfTxt, text_color = bfCol, text_size = size.tiny, text_halign = text.align_right)
        // position / bias
        table.cell(dashTbl, 0, 11, "Position", text_color = thDim, bgcolor = thRowAlt, text_size = size.tiny, text_halign = text.align_left)
        table.cell(dashTbl, 1, 11, biasTxt, text_color = biasCol, text_size = size.tiny, text_halign = text.align_right)
        // key
        table.cell(dashTbl, 0, 12, "Key", text_color = thDim, bgcolor = thRowAlt, text_size = size.tiny, text_halign = text.align_left)
        table.cell(dashTbl, 1, 12, "▲ Sup  ▼ Res  ◆ Chop  ● Active", text_color = thDim, text_size = size.tiny, text_halign = text.align_right)

// ════════════════════════════════════════════════════════════════
// SECTION: ZONE RESPECT CALIBRATION TABLE  (cheap overlay — last bar)
// ════════════════════════════════════════════════════════════════
// Forward-resolved respect rate of resolved S/R zones, bucketed by the star
// rating the engine assigned at formation. Each resolved zone's FIRST test is
// scored once: a recovery after a touch (compromised 1 → 0) counts as held; a
// decisive break (→ 2) counts as broken. Held% is shown per bucket with a 95%
// Wilson half-width and coloured vs the all-zones base rate. This is the honest
// check on whether higher stars actually correspond to higher respect.

var table calTbl = na
if barstate.islast and showCalTable
    if not na(calTbl)
        table.delete(calTbl)
    calTbl := table.new(calPos(calPosStr), 4, 7, bgcolor = thPanel, border_width = 1, border_color = thBorder)
    table.cell(calTbl, 0, 0, "RESPECT", text_color = thHdrTx, bgcolor = thHdrBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(calTbl, 1, 0, "n",    text_color = thHdrTx, bgcolor = thHdrBg, text_size = size.tiny)
    table.cell(calTbl, 2, 0, "held", text_color = thHdrTx, bgcolor = thHdrBg, text_size = size.tiny)
    table.cell(calTbl, 3, 0, "±95%", text_color = thHdrTx, bgcolor = thHdrBg, text_size = size.tiny)
    float baseRate = calBaseTest > 0 ? calBaseHeld / float(calBaseTest) * 100.0 : na
    float baseCi   = f_ciHalf(calBaseHeld, calBaseTest) * 100.0
    table.cell(calTbl, 0, 1, "base", text_color = thDim, text_size = size.tiny, text_halign = text.align_left)
    table.cell(calTbl, 1, 1, str.tostring(calBaseTest), text_color = thDim, text_size = size.tiny)
    table.cell(calTbl, 2, 1, na(baseRate) ? "—" : str.tostring(baseRate, "#") + "%", text_color = thDim, text_size = size.tiny)
    table.cell(calTbl, 3, 1, calBaseTest > 0 ? "±" + str.tostring(baseCi, "#") : "", text_color = thDim, text_size = size.tiny)
    int rr = 2
    for s = 5 to 1
        int nS = array.get(calTest, s)
        if nS >= calMinTests and rr <= 6
            float rate = array.get(calHeld, s) / float(nS) * 100.0
            float ci   = f_ciHalf(array.get(calHeld, s), nS) * 100.0
            color rc = na(baseRate) ? thDim : rate > baseRate ? color.new(#00D9A0, 0) : rate < baseRate ? color.new(#FF4D6D, 0) : thDim
            table.cell(calTbl, 0, rr, str.tostring(s) + "star", text_color = thStar, text_size = size.tiny, text_halign = text.align_left)
            table.cell(calTbl, 1, rr, str.tostring(nS), text_color = thDim, text_size = size.tiny)
            table.cell(calTbl, 2, rr, str.tostring(rate, "#") + "%", text_color = rc, text_size = size.tiny)
            table.cell(calTbl, 3, rr, "±" + str.tostring(ci, "#"), text_color = thDim, text_size = size.tiny)
            rr += 1

// ════════════════════════════════════════════════════════════════
// SECTION: FEATURE-LIFT CALIBRATION TABLE  (cheap overlay — last bar)
// ════════════════════════════════════════════════════════════════
// Breaks first-test respect down by INPUT feature rather than by star, so you
// can see WHICH ingredient predicts holding. For each feature: held% among
// zones that had it (with) vs zones that didn't (w/o), and the lift Δ. Positive
// green Δ = the feature genuinely raises respect; ~0 or negative = it's noise
// and shouldn't be weighting the star formula. This is the evidence layer
// behind any future star_rating retune.

var table featTbl = na
if barstate.islast and showCalFeatures
    if not na(featTbl)
        table.delete(featTbl)
    featTbl := table.new(calPos(calFeatPosStr), 4, 5, bgcolor = thPanel, border_width = 1, border_color = thBorder)
    table.cell(featTbl, 0, 0, "FEATURE", text_color = thHdrTx, bgcolor = thHdrBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(featTbl, 1, 0, "with",  text_color = thHdrTx, bgcolor = thHdrBg, text_size = size.tiny)
    table.cell(featTbl, 2, 0, "w/o",   text_color = thHdrTx, bgcolor = thHdrBg, text_size = size.tiny)
    table.cell(featTbl, 3, 0, "Δ",     text_color = thHdrTx, bgcolor = thHdrBg, text_size = size.tiny)
    fNames = array.from("MTF", "POC", "VA", "Tight")
    for fi = 0 to 3
        int tY = array.get(featTestY, fi)
        int hY = array.get(featHeldY, fi)
        int tN = array.get(featTestN, fi)
        int hN = array.get(featHeldN, fi)
        float rY = tY > 0 ? hY / float(tY) * 100.0 : na
        float rN = tN > 0 ? hN / float(tN) * 100.0 : na
        bool enough = tY >= calMinTests or tN >= calMinTests
        string wTxt = na(rY) ? "—" : str.tostring(rY, "#") + "%(" + str.tostring(tY) + ")"
        string oTxt = na(rN) ? "—" : str.tostring(rN, "#") + "%(" + str.tostring(tN) + ")"
        float lift = (not na(rY) and not na(rN)) ? rY - rN : na
        string dTxt = na(lift) ? "—" : (lift >= 0 ? "+" : "") + str.tostring(lift, "#")
        color dCol = na(lift) ? thDim : lift > 0 ? color.new(#00D9A0, 0) : lift < 0 ? color.new(#FF4D6D, 0) : thDim
        color rowTxt = enough ? thDim : color.new(color.gray, 40)
        table.cell(featTbl, 0, fi + 1, array.get(fNames, fi), text_color = thStar, text_size = size.tiny, text_halign = text.align_left)
        table.cell(featTbl, 1, fi + 1, wTxt, text_color = rowTxt, text_size = size.tiny)
        table.cell(featTbl, 2, fi + 1, oTxt, text_color = rowTxt, text_size = size.tiny)
        table.cell(featTbl, 3, fi + 1, dTxt, text_color = enough ? dCol : color.new(color.gray, 40), text_size = size.tiny)
````
