# Bitcoin Almanac [WillyAlgoTrader]

- url: https://www.tradingview.com/script/Z4DiNsKb-Bitcoin-Almanac-WillyAlgoTrader/
- type: indicator
- pine_id: PUB;e7cf13419d6549a89bf91615d6bc7d07
- version: 1.0

## Description

[b]₿ Bitcoin Almanac[/b] is an overlay indicator that maps the entire Bitcoin macro landscape on one chart: a fixed-length cycle time model (bull/bear phases projected from a single anchor date), two hyperbolic curves fitted through historical cycle lows and cycle highs in log-price space, Fibonacci grids stretched between every macro pivot, halving markers, accumulation and distribution zones, and a hypothetical price path for the next bull leg — all summarized in a live dashboard with projected turn dates, curve prices, and historical correction depths.

The core insight: Bitcoin's completed cycles show a remarkably stable time rhythm (roughly 1064 days up, 364 days down) and a decelerating growth pattern that a hyperbola in log10(price) captures with surprisingly small error. Neither observation is a law of nature — but when the time model and the price curves are combined on one chart, they produce concrete, falsifiable reference points: a projected top date with a curve price, a projected bottom date with a curve price, and buy/sell zones derived from both. The indicator makes the whole framework explicit, configurable, and honest about its assumptions.

Everything is driven by dates and user-defined pivots — not by real-time price action — so nothing repaints: the lines you see today are the lines you saw yesterday.


[b]🧩 WHY THESE COMPONENTS WORK TOGETHER[/b]

A cycle-date model alone answers WHEN but not AT WHAT PRICE. A curve through historical lows answers WHERE support migrates but not WHEN price will meet it. Fibonacci retracements answer WHERE pullbacks tend to end, but only if you know which macro leg to anchor them to. Used separately, each tool leaves you guessing at the missing dimension.

Bitcoin Almanac chains them into one pipeline:

[b]Cycle time model (anchor + phase lengths) → projected turn dates → hyperbolic lows/highs curves → curve price AT each projected date → Fibonacci grids between macro pivots → 0.786–0.836 accumulation zones bounded by cycle end dates → ±% distribution zones around each high → replayed bull-path projection between the two curve endpoints → dashboard synthesis[/b]

The time model supplies the X-coordinate of every future event. The two hyperbolas supply the Y-coordinate: the lows curve is evaluated exactly at the projected bottom date, the highs curve exactly at the projected top date — the "◎ cycle × curve" labels mark these intersections with date and price. The Fibonacci grids are then anchored to the same pivots the curves are built from, so the 0.786–0.836 buy zone of the current leg stretches in time precisely to the model's next cycle-bottom date. Finally, the projection module takes the two curve × date intersections as endpoints and fills the path between them by replaying the shape of the previous bull phase in log space.

No single component can do this: the intersection of an independent time model with an independent price model is what turns two vague trajectories into specific, checkable coordinates.


[b]🔍 WHAT MAKES IT ORIGINAL[/b]

1️⃣ [b]Fixed-rhythm cycle engine — pure time math, zero price input.[/b]

The phase of any bar is computed directly from calendar time:

daysSince = (barTime − anchor) / 86 400 000
phasePos = daysSince mod (bullDays + bearDays)
isBull = phasePos < bullDays

Defaults: anchor = 07 Nov 2022, bullDays = 1064, bearDays = 364 (each ≈ the average of the three completed BTC cycles). A true mathematical modulo (always ≥ 0) phases bars BEFORE the anchor correctly, so past cycles line up too. With defaults this reproduces the well-known projected dates: top ≈ 06 Oct 2025, bottom ≈ 05 Oct 2026. An alternative anchor (21 Nov 2022 — the actual lowest trade of the cycle) is documented right in the input tooltip and shifts the bottom to 19 Oct 2026.

Why this matters: because the phase depends only on time, the bull/bear background, turn lines and flip alerts are deterministic and cannot repaint — the model's claims are fully falsifiable in advance.

2️⃣ [b]Hyperbolic curve through cycle lows — exact geometry or least-squares fit, with the error printed on the chart.[/b]

The lows model is log10(price) = a + b / (c − t), where t is days from the first pivot. The hyperbola has a vertical asymptote in the past and a horizontal asymptote in the future — it encodes decelerating growth, which a straight log-regression line cannot.

 — With [b]exactly 3 enabled lows[/b] (default: Aug 2015 ≈ $169, Dec 2018 ≈ $3 122, Nov 2022 ≈ $15 476) the three parameters are solved [b]exactly[/b] — the curve passes through the pivots by construction. This is geometry, not statistics, and the label says so: "exact through 3 lows".
 — With [b]4+ enabled lows[/b] (three optional early-history slots: 2011, 2013, 2015 are provided) the indicator switches to a least-squares fit: a coarse log-spaced search over 250 candidate asymptote positions, followed by a 200-step linear refinement around the best candidate. The curve label then reports the number of points and the [b]RMSE in log10 units[/b] — the fit quality is never hidden.

A fit is accepted only if b > 0 and the asymptote c lies before the earliest pivot — degenerate solutions are rejected and the curve simply doesn't draw.

3️⃣ [b]Second independent hyperbola through cycle highs.[/b]

The same model is fitted to cycle tops (defaults: Nov 2013 ≈ $1 238, Dec 2017 ≈ $19 700, Nov 2021 ≈ $69 000, Oct 2025 ≈ $126 200 — four points, so LS fit with visible RMSE). A fifth, disabled slot exists only if you want to force the fit through your own future target; you never need it for the projection, because the future top is marked automatically at the crossing of the highs curve with the projected top date.

Why two curves: lows and highs decelerate at different rates. Fitting them independently (instead of offsetting one curve) lets the model express a narrowing channel without assuming its shape.

4️⃣ [b]"Cycle × curve" intersection labels — the model's testable predictions.[/b]

At the projected bottom date the lows curve is evaluated: ◎ label with date ≈ price. At the projected top date the highs curve is evaluated: ◎ label with date ≈ price. These two points are the indicator's headline output — a date AND a price for each future turn, derived from two independent models. Both curves extend beyond their intersection as dashed lines (lows: default 10 years, highs: 5 years) to show the long-term trajectory.

5️⃣ [b]Macro Fibonacci grids with a time-bounded 0.786–0.836 accumulation zone.[/b]

All enabled lows and highs are merged chronologically; every leg between two pivots of opposite type receives a grid (low→high = bull grid, high→low = bear grid; same-type neighbours are skipped). Levels are fully user-defined (default: 0, 0.236, 0.382, 0.5, 0.618, 0.786, 0.836, 0.886, 1; values > 1 add extensions).

Two non-standard options:
 — [b]Log-scale interpolation[/b]: level price = 10^(log10(pA) + f × (log10(pB) − log10(pA))) — matches a fib tool drawn on a log chart. Off by default (arithmetic levels for a linear chart).
 — [b]Reverse mode[/b] (default ON): ratio 0 sits at the END of the leg, so on a bull leg 0.618 is the classic retracement below the high.

The [b]0.786–0.836 zone[/b] of each bull leg is highlighted as a "BUY ZONE" box — and here is the original part: the box stretches in time from the leg start to the [b]end date of the cycle the leg belongs to[/b] (the next projected cycle bottom). Depth from the fib model, deadline from the time model — the zone is a rectangle in (price × time), not just a price band.

6️⃣ [b]Distribution zones tied to the cycle skeleton.[/b]

Every enabled high gets a "SELL ZONE" box spanning high ± sellPct (default 5% → from high × 0.95 to high × 1.05). The time span runs from the LATER of (a) the latest enabled low before that high or (b) the model's cycle bottom immediately preceding it — so a projected 2029 high starts its zone at the projected Oct-2026 bottom, not at a 2022 pivot. If no enabled high exists in the upcoming cycle, a projected sell zone is created automatically at the highs-curve × projected-date crossing (duplicate-guarded within half a cycle).

7️⃣ [b]Bull-path projection — fractal replay of the previous bull, rescaled in log space.[/b]

The path for the NEXT bull phase (with defaults: 05 Oct 2026 → 03 Sep 2029) is drawn between two model-derived endpoints: start = lows curve at the projected bottom, end = highs curve at the following projected top. Two shapes:

 — [b]Replay last bull[/b] (default): the log-price trajectory of the previous bull phase is recorded bar by bar (confirmed bars only, thinned to ≤ 400 samples for memory safety on intraday timeframes), then linearly rescaled: y(progress) = yStart + (ref(progress) − ref(0)) × (yEnd − yStart) / (ref(1) − ref(0)). The result keeps the timing character of the last cycle — early acceleration, mid-cycle chop, late blow-off — mapped onto the new endpoints.
 — [b]Log-linear[/b]: a straight line on a log chart between the endpoints. The replay mode automatically falls back to log-linear if the reference phase covers less than 90% of the bull duration.

The path is explicitly labeled "◇ PROJECTED PATH (hypothetical)" — it is a scenario generator, not a forecast.

8️⃣ [b]Corrections table — every macro drawdown since 2014, including the unfinished one.[/b]

The dashboard lists every completed high → following-low leg between enabled pivots since 2014 as a % drop (e.g. 2017–2018: −84%). If the latest pivot is a high with no low after it, the [b]current correction is projected[/b]: measured from that high to the lows-curve price at the next model bottom, and marked "(proj.)" in accent color. You always see how the ongoing decline compares with history.

9️⃣ [b]Full-transparency dashboard with a phase gauge and next-leg scenario PNL.[/b]

Four toggleable sections: [b]Cycle[/b] (phase, day X / Y, ██████░░░░ progress gauge), [b]Projection[/b] (top and bottom dates with days-left counters and curve prices, plus the hypothetical PNL of the next bull leg: (topCurve / bottomCurve − 1) × 100% and the × multiple), [b]Corrections[/b] (see 8️⃣), [b]Ranges[/b] (nearest upcoming buy range = the 0.786–0.836 zone prices; nearest sell range = the ±% zone around the next projected high). The footer states the calibration chart (INDEX:BTCUSD · W · linear scale, with a live ✓ when you're on it), a timeframe warning, and the sample-size caveat "⚠ Sample size: 3 cycles" — the model's biggest limitation is printed on the chart itself.

🔟 [b]Efficient, tick-stable rendering.[/b]

All drawings (500+ polyline points, fib grids, boxes, dashboard) are anchored to bar-open times and first-bar curve fits — nothing changes within a bar. A redraw gate rebuilds them once per new bar instead of on every real-time tick, and both curve fits run exactly once on the first bar. The chart stays responsive even with all modules enabled.


[b]📐 HOW IT WORKS — CALCULATION FLOW[/b]

[b]Step 1 — Parse pivots:[/b] on the first bar, all enabled lows and highs are converted to (days-from-first-pivot, log10(price)) pairs.

[b]Step 2 — Fit the curves:[/b] each set is fitted to log10(price) = a + b/(c − t) — exact solve for 3 points, two-stage least-squares search for 4+. Fit validity is checked (b > 0, asymptote before the data).

[b]Step 3 — Phase every bar:[/b] calendar-time modulo against the anchor determines bull/bear phase, day-in-phase, and the timestamps of the current, next bottom and next top.

[b]Step 4 — Evaluate intersections:[/b] the lows curve at the projected bottom date and the highs curve at the projected top date become the model's price targets.

[b]Step 5 — Record the reference bull:[/b] during the anchor cycle's bull phase, confirmed closes are stored as (progress, log10 price) — the shape later replayed by the projection.

[b]Step 6 — Draw (once per bar):[/b] turn lines and labels for N past and M future cycles, both hyperbolas with dashed extensions, fib grids per alternating pivot leg, buy/sell zone boxes, halving lines (2012 / 2016 / 2020 / 2024 solid, Apr 2028 dashed "(est.)"), the projected path, the dashboard and the watermark.

[b]Step 7 — Alert:[/b] on confirmed bars, phase flips and the pre-turn countdown fire alert() calls in text or JSON format.


[b]📖 HOW TO USE[/b]

🎯 [b]Quick start:[/b]
 1. Open the [b]INDEX:BTCUSD[/b] chart, [b]Weekly[/b] timeframe, [b]regular (linear) price scale[/b] — the model is calibrated there, and the dashboard shows a ✓ when the symbol and timeframe match (the scale must be checked manually — Pine cannot detect it).
 2. Add the indicator. The green/red background immediately shows the model's current phase; the dashboard shows the day count and progress gauge.
 3. Find the two ◎ labels — the projected bottom (orange, lows curve) and the projected top (red, highs curve). These are the model's date + price coordinates for the next turns.
 4. Check the yellow boxes: BUY ZONE (0.786–0.836 of the current bull leg, extended to the cycle end date) and SELL ZONE (±5% around each high).
 5. Create ONE alert with condition "Any alert() function call" to receive flips and the pre-turn countdown.

👁️ [b]Reading the chart:[/b]
 — 🟢 Green background = model bull phase; 🔴 red = bear phase
 — Solid green verticals = cycle bottoms; dashed red verticals = cycle tops; future turns are labeled ★ PROJECTED and drawn brighter
 — 🟠 Orange curve = hyperbola through cycle lows (solid to the projected bottom, then dashed extension)
 — 🔴 Red curve = hyperbola through cycle highs (solid to the projected top, then dashed extension)
 — Small circles = the exact pivots each curve is built from
 — ◎ labels = cycle × curve intersections with date, ≈ price, and fit info (point count + RMSE, or "exact through 3")
 — Fib grids between macro pivots: solid edges (0 / 1), dashed 0.5, dotted intermediate levels, price + ratio labels on the right
 — 🟡 Yellow boxes = BUY ZONE (0.786–0.836, time-bounded by the cycle end) and SELL ZONE (±% around highs; "(proj.)" = auto-generated at the projected top)
 — ⛏ Grey verticals = halvings; the 2028 line is dashed and marked "(est.)"
 — 🔵 Blue dashed path = hypothetical next-bull trajectory with its ◇ end label

📊 [b]Dashboard fields:[/b]
 — [b]Phase / Phase day / Progress[/b]: current model phase, day within it, and a 10-segment gauge
 — [b]Proj. top / Proj. bottom[/b]: projected turn dates, days remaining, and the curve price at each date
 — [b]Next leg PNL[/b]: hypothetical bottom→top move of the next bull leg in % and as a × multiple — a scenario, not a forecast
 — [b]Corrections[/b]: every completed macro drawdown since 2014 (high → following low, %), plus the unfinished one projected to the curve bottom and marked (proj.)
 — [b]Next buy range / Next sell range[/b]: the price boundaries of the nearest upcoming accumulation and distribution zones
 — Footer: recommended chart check, timeframe warning, sample-size caveat, version

🔧 [b]Tuning guide:[/b]
 — [b]Curve doesn't draw:[/b] fewer than 3 pivots enabled, or the fit was rejected as degenerate — enable at least 3 lows (or highs) with sensible dates/prices.
 — [b]You disagree with a pivot price:[/b] every pivot is an editable date + price input — correct it and both the curve and the fib grids rebuild instantly.
 — [b]Want dates matching the actual price low:[/b] switch the anchor to 21 Nov 2022 (documented in the tooltip); the projected bottom moves to 19 Oct 2026.
 — [b]Fib levels look wrong on a log chart:[/b] enable "Log-scale levels" (keep it OFF on the recommended linear chart).
 — [b]Chart feels crowded:[/b] disable individual modules (grids, zones, halvings, projection) or dashboard sections — every block has its own switch.
 — [b]Curious about 2030+:[/b] enable "Show 2nd projected cycle" for one more bottom/top pair (~Sep 2030 / ~Aug 2033) — off by default because those dates carry double model uncertainty.

💡 [b]Trading ideas:[/b]
 — [b]Accumulation planning[/b]: scale into the 0.786–0.836 BUY ZONE while the model is in its bear phase; the zone's right edge tells you the model's deadline.
 — [b]Distribution planning[/b]: scale out inside the ±5% SELL ZONE as the projected top date approaches; the pre-alert (default 30 days) gives you a heads-up.
 — [b]Scenario testing[/b]: move pivots, change phase lengths, or force High #5 to your own target and watch how the whole framework (curves, zones, PNL) responds — the model is a sandbox, not an oracle.


[b]⚙️ KEY SETTINGS[/b]

⚙️ [b]Cycle Model:[/b]
 — [b]Anchor — cycle bottom[/b] (default 07 Nov 2022): date all phases are projected from; alternative 21 Nov 2022 documented in the tooltip
 — [b]Bull phase length[/b] (default 1064 days) / [b]Bear phase length[/b] (default 364 days): ≈ averages of the 3 completed cycles
 — [b]Cycles to draw back[/b] (default 3) / [b]forward[/b] (default 1): how many turn lines and labels are drawn
 — [b]Show 2nd projected cycle[/b] (default off): one extra bottom/top pair with doubled uncertainty

🎨 [b]Visual Settings:[/b]
 — [b]Theme[/b] (Auto / Dark / Light): Auto detects from the chart background; all text colors adapt
 — [b]Phase background[/b], [b]Cycle turn lines[/b], [b]Turn labels[/b], [b]Watermark[/b]: independent toggles with color inputs

📊 [b]Dashboard:[/b]
 — Position (4 corners), font size (Small–Huge; dividers render one step smaller), and per-section switches: Cycle / Projection / Corrections / Ranges

📈 [b]Hyperbola — Lows:[/b]
 — 3 main cycle lows (2015 / 2018 / 2022, on by default) + 3 optional early-history lows (2011 / 2013 / 2015) — each is a checkbox + date + price
 — [b]Dashed extension[/b] (default 10 years), curve color, anchor-point markers

📉 [b]Hyperbola — Highs:[/b]
 — 4 cycle highs (2013 / 2017 / 2021 / 2025, on by default) + a spare projected slot (off), extension (default 5 years), curve color

🔢 [b]Fibonacci Grids:[/b]
 — [b]Bull grids[/b] (default on) / [b]Bear grids[/b] (default off) with separate colors
 — [b]Levels[/b] (default "0, 0.236, 0.382, 0.5, 0.618, 0.786, 0.836, 0.886, 1"; values > 1 = extensions)
 — [b]Highlight 0.786–0.836 zone[/b] (default on), [b]Log-scale levels[/b] (default off), [b]Reverse[/b] (default on), level labels

⛏ [b]Halvings:[/b] lines + labels toggles, color

🟡 [b]Sell Zones:[/b] toggle, color, [b]Zone size % from high[/b] (default 5%)

🔮 [b]Price Projection:[/b] toggle, [b]Path shape[/b] (Replay last bull / Log-linear), color

🔔 [b]Alerts:[/b] master switch, [b]Webhook JSON Format[/b] (default off), [b]Pre-alert days[/b] (default 30)


[b]🔔 ALERTS[/b]

 — 🟢 CYCLE FLIP → BULL — model bottom date reached; payload: ticker, timeframe, price, next projected top date
 — 🔴 CYCLE FLIP → BEAR — model top date reached; payload: ticker, timeframe, price, next projected bottom date
 — ⏳ CYCLE TURN APPROACHING — fires once, N days (default 30) before the next projected turn; payload: turn type (TOP/BOTTOM), days left, date

All alerts fire on confirmed bars only (once per bar close) and support both human-readable text and JSON webhook payloads for bot integration. Create a single alert with condition "Any alert() function call".


[b]⚠️ IMPORTANT NOTES[/b]

 — 🚫 [b]No repainting.[/b] The cycle phase is pure calendar-time math against a fixed anchor; the curves are fitted once from user-defined historical pivots; the reference bull shape is recorded from confirmed bars only; all alerts use bar-close frequency. Nothing in the model reads unconfirmed real-time data, so no line, zone or label moves after the fact.
 — 📐 [b]Sample size: 3 completed cycles.[/b] Every statistical claim in this model rests on three observations. The hyperbolic fits are geometry/regression over 3–6 points. Treat all projected dates and prices as reference scenarios with wide error bars — the dashboard says "Rhythm ≠ law" for a reason.
 — 📏 [b]Calibrated chart:[/b] INDEX:BTCUSD, Weekly, regular (linear) price scale. Exchange charts start later and distort early-history fits. Keep the fib "Log-scale levels" input OFF on a linear chart. The dashboard's ✓ confirms symbol and timeframe; the scale must be checked manually.
 — ⚖️ [b]Scope:[/b] this is a macro-cycle framework for Bitcoin. It produces no intraday entry signals, no stop placement, and no position sizing. The projected path is explicitly hypothetical.
 — 🛠️ This is a cycle-analysis and scenario-visualization tool, not an automated trading bot. It provides projected turn dates, curve-based price references, and accumulation/distribution zones — trade decisions remain yours.
 — 🌐 The script runs on any symbol and timeframe, but the model is designed for Bitcoin on Daily/Weekly charts — a dashboard warning appears on intraday timeframes.

Bitcoin Almanac · v1.5.2

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════
// BITCOIN ALMANAC [WillyAlgoTrader]
// ══════════════════════════════════════════════════════════
// Author:  Willy | WillyAlgoTrader
// Version: 1.5.2

indicator("Bitcoin Almanac [WillyAlgoTrader]",
     shorttitle = "BTC Almanac [WillyAlgoTrader]",
     overlay = true,
     max_lines_count = 200,
     max_labels_count = 200,
     max_boxes_count = 50,
     max_polylines_count = 10)

// ══════════════════════════════════════════════════════════
// CONSTANTS
// ══════════════════════════════════════════════════════════
GRP_CYCLE  = "⚙️ Cycle Model"
GRP_VISUAL = "🎨 Visual Settings"
GRP_DASH   = "📊 Dashboard"
GRP_PARA   = "📈 Hyperbola — Lows"
GRP_TOPS   = "📉 Hyperbola — Highs"
GRP_FIB    = "🔢 Fibonacci Grids"
GRP_HALV   = "⛏ Halvings"
GRP_ZONES  = "🟡 Sell Zones"
GRP_PROJ   = "🔮 Price Projection"
GRP_ALERT  = "🔔 Alerts"

INDICATOR_VERSION = "v1.5.2"
MS_DAY = 86400000.0

// ══════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════

// ── Cycle Model ─────────────────────────────────────────────
anchorT  = input.time(timestamp("2022-11-07T00:00:00+00:00"),
     "Anchor — cycle bottom", group = GRP_CYCLE,
     tooltip = "Date all phases are projected from.\n" +
       "• 07 Nov 2022 → reproduces Klarck's dates (top 06 Oct 2025, bottom 05 Oct 2026)\n" +
       "• 21 Nov 2022 → actual lowest price of the cycle (shifts bottom to 19 Oct 2026)")
bullDays = input.int(1064, "Bull phase length, days", minval = 30, group = GRP_CYCLE,
     tooltip = "Duration of the rising phase, in calendar days.\n" +
       "1064 ≈ the average of the 3 completed BTC cycles.")
bearDays = input.int(364, "Bear phase length, days", minval = 30, group = GRP_CYCLE,
     tooltip = "Duration of the falling phase, in calendar days.\n" +
       "364 ≈ the average of the 3 completed BTC cycles.")
cyclesBk = input.int(3, "Cycles to draw back", minval = 0, maxval = 12, group = GRP_CYCLE,
     tooltip = "How many past cycles get turn lines and labels.\n" +
       "3 covers the full useful BTC history for this model.")
cyclesFw = input.int(1, "Cycles to project forward", minval = 0, maxval = 12, group = GRP_CYCLE,
     tooltip = "How many future cycles get projected turn lines and labels.\n" +
       "Keep low — every extra projected cycle compounds model uncertainty.")
showCycle2Input = input.bool(false, "Show 2nd projected cycle", group = GRP_CYCLE,
     tooltip = "Adds ONE more projected cycle on top of the setting above:\n" +
       "with defaults that is the next bottom line (~02 Sep 2030) and\n" +
       "the following top line (~01 Aug 2033), with date labels.\n" +
       "Off by default — these dates carry double model uncertainty.")

// ── Visual Settings ─────────────────────────────────────────
themeInput = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"],
     group = GRP_VISUAL,
     tooltip = "Chart color theme.\n" +
       "• Auto: detects from chart background\n" +
       "• Dark: optimized for dark backgrounds\n" +
       "• Light: optimized for light/white backgrounds")
showBg   = input.bool(true, "Phase background", group = GRP_VISUAL,
     tooltip = "Tint the chart background green during the bull phase\n" +
       "and red during the bear phase (highly transparent).")
colBull  = input.color(color.new(#089981, 90), "Bull", inline = "cols", group = GRP_VISUAL,
     tooltip = "Background tints for bull / bear phases.\n" +
       "Keep transparency high (85–92%) so candles stay readable.")
colBear  = input.color(color.new(#f23645, 88), "Bear", inline = "cols", group = GRP_VISUAL)
showLn   = input.bool(true, "Cycle turn lines", group = GRP_VISUAL,
     tooltip = "Vertical lines at every projected cycle bottom (solid green)\n" +
       "and cycle top (dashed red).")
showLb   = input.bool(true, "Turn labels", group = GRP_VISUAL,
     tooltip = "Date labels on cycle bottoms and tops.\n" +
       "Future turns are marked ★ PROJECTED and drawn brighter.")
showWatermarkInput = input.bool(true, "Show Watermark", group = GRP_VISUAL,
     tooltip = "Display 'WillyAlgoTrader' watermark at the bottom center of the chart")

// ── Dashboard ───────────────────────────────────────────────
showDash = input.bool(true, "Show Dashboard", group = GRP_DASH,
     tooltip = "Summary table: phase, progress, projected turn dates,\n" +
       "nearest buy/sell price ranges from the curve models.")
dashPos  = input.string("Top Right", "Dashboard position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH,
     tooltip = "Corner of the chart where the dashboard is anchored.")
dashFontSizeInput = input.string("Small", "Dashboard Font Size",
     options = ["Small", "Normal", "Large", "Huge"], group = GRP_DASH,
     tooltip = "Font size for the dashboard table. Section dividers and the\n" +
       "footer rows render one step smaller to preserve hierarchy")
showCycleSecInput = input.bool(true, "  ├ Cycle section", group = GRP_DASH,
     tooltip = "Phase, Phase day, Progress gauge")
showProjSecInput = input.bool(true, "  ├ Projection section", group = GRP_DASH,
     tooltip = "Projected top / bottom (dates, days left, curve prices)\n" +
       "and the hypothetical PNL of the next bull leg")
showCorrSecInput = input.bool(true, "  ├ Corrections section", group = GRP_DASH,
     tooltip = "Historical corrections since 2014: every high → following low\n" +
       "leg between enabled pivots, as % drop (period – correction).\n" +
       "The unfinished current correction is shown as (proj.) —\n" +
       "from the latest enabled high to the lows-curve price at the\n" +
       "projected cycle bottom")
showRangesSecInput = input.bool(true, "  └ Ranges section", group = GRP_DASH,
     tooltip = "Nearest upcoming buy range (0.786–0.836 fib zone)\n" +
       "and sell range (±% zone around the projected high)")

// ── Hyperbola Through Lows ──────────────────────────────────
showPara = input.bool(true, "Show hyperbolic curve through cycle lows", group = GRP_PARA,
     tooltip = "Hyperbola log10(price) = a + b / (c − t) through the enabled lows below.\n" +
       "Exactly 3 lows enabled → passes through them EXACTLY (geometry, not statistics).\n" +
       "4+ lows enabled → least-squares fit; the curve label then reports fit error (RMSE, log10 units).")
e1On = input.bool(false, "", group = GRP_PARA, inline = "e1")
e1T  = input.time(timestamp("2011-11-18T00:00:00+00:00"), "Early low A", group = GRP_PARA, inline = "e1")
e1P  = input.float(2.0, "$", minval = 0.0001, group = GRP_PARA, inline = "e1",
     tooltip = "Optional early-history low: checkbox = include in fit, date + price of the pivot.")
e2On = input.bool(false, "", group = GRP_PARA, inline = "e2")
e2T  = input.time(timestamp("2013-07-05T00:00:00+00:00"), "Early low B", group = GRP_PARA, inline = "e2")
e2P  = input.float(65.5, "$", minval = 0.0001, group = GRP_PARA, inline = "e2",
     tooltip = "Optional early-history low: checkbox = include in fit, date + price of the pivot.")
e3On = input.bool(false, "", group = GRP_PARA, inline = "e3")
e3T  = input.time(timestamp("2015-01-14T00:00:00+00:00"), "Early low C", group = GRP_PARA, inline = "e3")
e3P  = input.float(152.0, "$", minval = 0.0001, group = GRP_PARA, inline = "e3",
     tooltip = "Optional early-history low: checkbox = include in fit, date + price of the pivot.")
p1On = input.bool(true, "", group = GRP_PARA, inline = "p1")
p1T  = input.time(timestamp("2015-08-17T00:00:00+00:00"), "Low #1", group = GRP_PARA, inline = "p1")
p1P  = input.float(169.0, "$", minval = 0.0001, group = GRP_PARA, inline = "p1",
     tooltip = "Cycle low: checkbox = include in fit, date + price of the pivot.")
p2On = input.bool(true, "", group = GRP_PARA, inline = "p2")
p2T  = input.time(timestamp("2018-12-15T00:00:00+00:00"), "Low #2", group = GRP_PARA, inline = "p2")
p2P  = input.float(3122.0, "$", minval = 0.0001, group = GRP_PARA, inline = "p2",
     tooltip = "Cycle low: checkbox = include in fit, date + price of the pivot.")
p3On = input.bool(true, "", group = GRP_PARA, inline = "p3")
p3T  = input.time(timestamp("2022-11-07T00:00:00+00:00"), "Low #3", group = GRP_PARA, inline = "p3")
p3P  = input.float(15476.0, "$", minval = 0.0001, group = GRP_PARA, inline = "p3",
     tooltip = "Cycle low: checkbox = include in fit, date + price of the pivot.")
extYearsLow = input.float(10.0, "Lows curve: dashed extension, years",
     minval = 0.0, maxval = 20.0, step = 0.5, group = GRP_PARA,
     tooltip = "How far beyond the projected cycle bottom the lows curve\n" +
       "is extended as a dashed line. 10 years shows the long-term\n" +
       "support trajectory well past the next cycle.")
paraCol  = input.color(color.new(#f7931a, 0), "Curve color", group = GRP_PARA,
     tooltip = "Color of the lows hyperbola and its anchor-point markers.")
showPts  = input.bool(true, "Mark anchor points", group = GRP_PARA,
     tooltip = "Small circles on the pivots each curve is built from\n" +
       "(applies to both the lows and the highs hyperbola).")

// ── Hyperbola Through Highs ─────────────────────────────────
showTops = input.bool(true, "Show hyperbolic curve through cycle highs", group = GRP_TOPS,
     tooltip = "Same model fitted to cycle tops: log10(price) = a + b / (c − t).\n" +
       "Highs #1–#4 enabled by default (LS fit). High #5 is a spare projected slot —\n" +
       "the FUTURE top is marked automatically at the curve × projected-date crossing,\n" +
       "so #5 is only needed if you want to force the fit through your own target.")
h1On = input.bool(true, "", group = GRP_TOPS, inline = "h1")
h1T  = input.time(timestamp("2013-11-25T00:00:00+00:00"), "High #1", group = GRP_TOPS, inline = "h1")
h1P  = input.float(1238.0, "$", minval = 0.0001, group = GRP_TOPS, inline = "h1",
     tooltip = "Cycle high: checkbox = include in fit, date + price of the pivot.")
h2On = input.bool(true, "", group = GRP_TOPS, inline = "h2")
h2T  = input.time(timestamp("2017-12-11T00:00:00+00:00"), "High #2", group = GRP_TOPS, inline = "h2")
h2P  = input.float(19700.0, "$", minval = 0.0001, group = GRP_TOPS, inline = "h2",
     tooltip = "Cycle high: checkbox = include in fit, date + price of the pivot.")
h3On = input.bool(true, "", group = GRP_TOPS, inline = "h3")
h3T  = input.time(timestamp("2021-11-10T00:00:00+00:00"), "High #3", group = GRP_TOPS, inline = "h3")
h3P  = input.float(69000.0, "$", minval = 0.0001, group = GRP_TOPS, inline = "h3",
     tooltip = "Cycle high: checkbox = include in fit, date + price of the pivot.")
h4On = input.bool(true, "", group = GRP_TOPS, inline = "h4")
h4T  = input.time(timestamp("2025-10-06T00:00:00+00:00"), "High #4", group = GRP_TOPS, inline = "h4")
h4P  = input.float(126200.0, "$", minval = 0.0001, group = GRP_TOPS, inline = "h4",
     tooltip = "Cycle high: checkbox = include in fit, date + price of the pivot.")
h5On = input.bool(false, "", group = GRP_TOPS, inline = "h5")
h5T  = input.time(timestamp("2029-09-03T00:00:00+00:00"), "High #5", group = GRP_TOPS, inline = "h5")
h5P  = input.float(195000.0, "$", minval = 0.0001, group = GRP_TOPS, inline = "h5",
     tooltip = "Spare projected high: only enable to force the fit through your own target.")
extYearsTop = input.float(5.0, "Tops curve: dashed extension, years",
     minval = 0.0, maxval = 20.0, step = 0.5, group = GRP_TOPS,
     tooltip = "How far beyond the upcoming projected top the highs curve\n" +
       "is extended as a dashed line.")
topCol = input.color(color.new(#f23645, 0), "Curve color", group = GRP_TOPS,
     tooltip = "Color of the highs hyperbola and its anchor-point markers.")

// ── Fibonacci Grids ─────────────────────────────────────────
showFibB = input.bool(true, "Bull grids  (low → high)", group = GRP_FIB, inline = "fb",
     tooltip = "Fib grid on every low→high leg between enabled pivots.")
fibColB  = input.color(color.new(#089981, 25), "", group = GRP_FIB, inline = "fb")
showFibS = input.bool(false, "Bear grids  (high → low)", group = GRP_FIB, inline = "fs",
     tooltip = "Fib grid on every high→low leg between enabled pivots.")
fibColS  = input.color(color.new(#f23645, 25), "", group = GRP_FIB, inline = "fs")
fibLvlIn = input.string("0, 0.236, 0.382, 0.5, 0.618, 0.786, 0.836, 0.886, 1", "Levels", group = GRP_FIB,
     tooltip = "Comma-separated ratios. Values > 1 add extensions (e.g. 1.272, 1.618).")
showFibZn = input.bool(true, "Highlight 0.786–0.836 zone", group = GRP_FIB, inline = "fz",
     tooltip = "Yellow box between the 0.786 and 0.836 levels of each leg.\n" +
       "Stretches in time from the leg start to the END DATE of the cycle\n" +
       "the leg belongs to (the next projected cycle bottom).\n" +
       "Respects the Reverse and Log-scale settings.")
fibZnCol  = input.color(color.new(#f2e40e, 78), "", group = GRP_FIB, inline = "fz")
fibLog   = input.bool(false, "Log-scale levels", group = GRP_FIB,
     tooltip = "Interpolate levels in log10(price) — matches a fib tool drawn on a log chart.\n" +
       "Off = plain arithmetic levels (matches fib on a linear chart).")
fibRev   = input.bool(true, "Reverse (0 at leg end)", group = GRP_FIB,
     tooltip = "On (default): 0 sits at the END of the leg, 1 at its start —\n" +
       "e.g. on a bull leg 0 = high, 0.618 = classic retracement below the high.\n" +
       "Off: 0 at the start of the leg, 1 at the end.")
showFibLb = input.bool(true, "Level labels", group = GRP_FIB,
     tooltip = "Price + ratio label at the right end of each fib level.\n" +
       "Label color follows the grid color above — pick a darker shade\n" +
       "if you work on a white chart background.")

// ── Halvings ────────────────────────────────────────────────
showHalv   = input.bool(true, "Show halving lines", group = GRP_HALV, inline = "hv",
     tooltip = "Vertical lines at all BTC halvings: 2012, 2016, 2020, 2024\n" +
       "+ the next one (Apr 2028, estimated — drawn dashed).")
halvCol    = input.color(color.new(#787b86, 35), "", group = GRP_HALV, inline = "hv")
showHalvLb = input.bool(true, "Halving labels", group = GRP_HALV,
     tooltip = "Date labels on the halving lines.\n" +
       "Label text color adapts to the chart theme automatically.")

// ── Sell Zones ──────────────────────────────────────────────
showSellZn = input.bool(true, "Highlight ±% zone around each high", group = GRP_ZONES, inline = "sz",
     tooltip = "Yellow box for every ENABLED high from the hyperbola inputs.\n" +
       "Price range = high ± the % below.\n" +
       "Time range = from the LOW date to the HIGH date: the start is the latest\n" +
       "enabled low before that high, or the model's projected cycle bottom\n" +
       "if it is more recent (e.g. High #5 starts at the Oct-2026 bottom).")
sellZnCol  = input.color(color.new(#f2e40e, 78), "", group = GRP_ZONES, inline = "sz")
sellPct    = input.float(5.0, "Zone size, % from high", minval = 0.5, maxval = 50.0, step = 0.5,
     group = GRP_ZONES,
     tooltip = "Half-height of each sell zone as % of the high price.\n" +
       "5% → the box spans from high × 0.95 to high × 1.05.")

// ── Price Projection ────────────────────────────────────────
showProj = input.bool(true, "Project price path: next bottom → next top", group = GRP_PROJ,
     tooltip = "Hypothetical path for the NEXT bull phase (with default settings:\n" +
       "05 Oct 2026 → 03 Sep 2029). Endpoints are taken from the two hyperbolas:\n" +
       "start = lows curve at the projected bottom, end = highs curve at the projected top.\n" +
       "Requires both curves to be active. This is a scenario, not a forecast.")
projMode = input.string("Replay last bull", "Path shape", group = GRP_PROJ,
     options = ["Replay last bull", "Log-linear"],
     tooltip = "Replay last bull — the log-price shape of the previous bull phase\n" +
       "(from the anchor date) rescaled to the new endpoints (fractal analogy).\n" +
       "Log-linear — straight line on a log chart between the endpoints.\n" +
       "Falls back to log-linear if the reference phase has too little data.")
projCol  = input.color(color.new(#2962ff, 0), "Path color", group = GRP_PROJ,
     tooltip = "Color of the dashed projected path and its end label.")

// ── Alerts ──────────────────────────────────────────────────
alertsOnInput = input.bool(true, "Enable Alerts", group = GRP_ALERT,
     tooltip = "Master switch for all alert() calls of this indicator.\n" +
       "Create ONE alert on the chart with condition 'Any alert() function call'.")
webhookInput  = input.bool(false, "Webhook JSON Format", group = GRP_ALERT,
     tooltip = "Send alert messages as JSON payloads for webhook integrations\n" +
       "instead of human-readable text.")
alertPre = input.int(30, "Pre-alert: days before projected turn",
     minval = 1, maxval = 180, group = GRP_ALERT,
     tooltip = "Fire a heads-up alert once, this many days before the next\n" +
       "projected phase turn (top or bottom).")

// ══════════════════════════════════════════════════════════
// THEME DETECTION & COLORS
// ══════════════════════════════════════════════════════════
isDark = switch themeInput
    "Dark"  => true
    "Light" => false
    =>         color.r(chart.bg_color) < 128   // Auto

// ── Texts ───────────────────────────────────────────────────
TEXT_COLOR   = isDark ? #E0E0E0 : #1A1A1A
TEXT_MUTED   = isDark ? color.new(#9598a1, 0) : color.new(#6A6D78, 0)

// ── Adaptive signal colors (text on chart/table background) ─
BULL_TEXT    = isDark ? #089981 : #067A67
BEAR_TEXT    = isDark ? #f23645 : #C62828
ACCENT_TEXT  = isDark ? #f7931a : #A65A00   // orange brand accent

// ── Label text colors (on opaque label backgrounds) ─────────
BULL_LABEL_TEXT = #FFFFFF   // white on #089981 (owner's choice, medium-dark green — legible on both themes)
BEAR_LABEL_TEXT = #FFFFFF   // white on #f23645 — works on both themes

// ── Dashboard / tables ───────────────────────────────────────
TABLE_BG       = isDark ? color.new(#0c0e15, 10) : color.new(#FFFFFF, 5)
TABLE_ROW_ALT  = isDark ? color.new(#1C2030, 0)  : color.new(#F0F4F8, 0)
TABLE_BORDER   = isDark ? color.new(#2a2e39, 0)  : color.new(#D0D0D0, 0)
HEADER_TEXT    = #FFFFFF
HEADER_BG_BULL = color.new(#0F6E56, 0)
HEADER_BG_BEAR = color.new(#A32D2D, 0)

// ── Chart texts without background (style_none, box texts) ──
ZONE_TEXT    = isDark ? color.new(#d1d4dc, 25) : color.new(#3F434C, 15)
HALV_TEXT    = isDark ? color.new(#b2b5be, 10) : color.new(#50545E, 10)

// ── Watermark ────────────────────────────────────────────────
WM_COLOR     = isDark ? color.new(#FFFFFF, 80) : color.new(#000000, 80)

// ══════════════════════════════════════════════════════════
// FUNCTIONS
// ══════════════════════════════════════════════════════════

// true modulo (always ≥ 0), so bars before the anchor are phased correctly
fMod(float a, float m) =>
    r = a % m
    r < 0 ? r + m : r

// text progress gauge, na/range-protected
fGauge(float p) =>
    n = int(math.round(math.min(math.max(nz(p, 0.0), 0.0), 1.0) * 10))
    string full = n > 0 ? str.repeat("█", n) : ""
    string rest = n < 10 ? str.repeat("░", 10 - n) : ""
    full + rest

sizeFromString(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal

// One step smaller — used for section dividers and footer rows
sizeDownFromString(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.tiny : s == "Normal" ? size.small : s == "Large" ? size.normal : s == "Huge" ? size.large : size.small

// least-squares (a, b) and SSE for a fixed asymptote c
fLsAB(float[] xs, float[] ys, float c) =>
    n = array.size(xs)
    su  = 0.0
    sy  = 0.0
    suu = 0.0
    suy = 0.0
    for i = 0 to n - 1
        u = 1.0 / (c - array.get(xs, i))
        y = array.get(ys, i)
        su  += u
        sy  += y
        suu += u * u
        suy += u * y
    det = n * suu - su * su
    b = det != 0 ? (n * suy - su * sy) / det : float(na)
    a = (sy - b * su) / n
    sse = 0.0
    for i = 0 to n - 1
        e = array.get(ys, i) - (a + b / (c - array.get(xs, i)))
        sse += e * e
    [a, b, sse]

// fit hyperbola log10(price) = a + b/(c − x) through the given points;
// sorts all three parallel arrays in place by x; returns [a, b, c, rmse, ok]
fFitHyp(float[] xs, float[] ys, float[] ts) =>
    n = array.size(xs)
    a    = float(na)
    b    = float(na)
    c    = float(na)
    rmse = float(na)
    ok   = false
    if n >= 3
        // insertion sort by x (parallel arrays, n ≤ 6)
        for i = 1 to n - 1
            j = i
            while j > 0 and array.get(xs, j - 1) > array.get(xs, j)
                tx = array.get(xs, j - 1)
                array.set(xs, j - 1, array.get(xs, j))
                array.set(xs, j, tx)
                ty = array.get(ys, j - 1)
                array.set(ys, j - 1, array.get(ys, j))
                array.set(ys, j, ty)
                tt = array.get(ts, j - 1)
                array.set(ts, j - 1, array.get(ts, j))
                array.set(ts, j, tt)
                j -= 1
        xMin = array.get(xs, 0)

        if n == 3
            // exact solve, shifted to the earliest point
            x1  = array.get(xs, 0)
            y1  = array.get(ys, 0)
            X2  = array.get(xs, 1) - x1
            X3  = array.get(xs, 2) - x1
            dy2 = array.get(ys, 1) - y1
            dy3 = array.get(ys, 2) - y1
            if dy2 != 0 and dy3 / dy2 * X2 != X3
                R  = dy3 / dy2
                Cs = X2 * X3 * (R - 1.0) / (R * X2 - X3)
                b := dy2 * Cs * (Cs - X2) / X2
                a := y1 - b / Cs
                c := Cs + x1
                rmse := 0.0
        else
            // coarse log-spaced search over d = xMin − c, then linear refine around the best
            bestSse = 1.0e18
            for k = 0 to 249
                d = 15.0 * math.pow(40000.0 / 15.0, k / 249.0)
                [a1, b1, s1] = fLsAB(xs, ys, xMin - d)
                if not na(b1) and s1 < bestSse
                    bestSse := s1
                    c := xMin - d
                    a := a1
                    b := b1
            if not na(c)
                d0 = xMin - c
                for k = 0 to 199
                    d = d0 * (0.6 + 0.8 * k / 199.0)
                    [a2, b2, s2] = fLsAB(xs, ys, xMin - d)
                    if not na(b2) and s2 < bestSse
                        bestSse := s2
                        c := xMin - d
                        a := a2
                        b := b2
                rmse := math.sqrt(bestSse / n)

        ok := not na(c) and b > 0 and c < xMin
    [a, b, c, rmse, ok]

// fib level interpolation (arithmetic or log10 space)
fFibPrice(float pA, float pB, float f) =>
    float res = na
    if fibLog
        res := math.pow(10.0, math.log10(pA) + f * (math.log10(pB) - math.log10(pA)))
    else
        res := pA + f * (pB - pA)
    res

// ══════════════════════════════════════════════════════════
// CALCULATIONS — CYCLE PHASE (pure time math → no repaint)
// ══════════════════════════════════════════════════════════
cycLen = bullDays + bearDays  // full cycle length, days

daysSince = (time - anchorT) / MS_DAY
phasePos  = fMod(daysSince, cycLen)          // 0 .. cycLen within current cycle
isBull    = phasePos < bullDays

dayInPhase = isBull ? phasePos : phasePos - bullDays
phaseLen   = isBull ? bullDays : bearDays
phasePct   = phaseLen != 0 ? dayInPhase / phaseLen : 0.0

// anchors of the cycle containing the current bar
kNow     = math.floor(daysSince / cycLen)
curBotT  = anchorT + int(kNow * cycLen * MS_DAY)
curTopT  = curBotT + int(bullDays * MS_DAY)
nextBotT = curBotT + int(cycLen  * MS_DAY)
nextTopT = curTopT + int(cycLen  * MS_DAY)

upcomingTopT = isBull ? curTopT : nextTopT
daysToTop    = (upcomingTopT - time) / MS_DAY
daysToBot    = (nextBotT     - time) / MS_DAY

// phase flips (pure time math → cannot repaint)
flipToBear = not isBull and isBull[1]
flipToBull = isBull and not isBull[1]

bgcolor(showBg ? (isBull ? colBull : colBear) : na)

// ══════════════════════════════════════════════════════════
// CALCULATIONS — HYPERBOLA FITS (once, on the first bar)
// ══════════════════════════════════════════════════════════
var float[] hxA = array.new_float()   // x of enabled lows, days from Low #1
var float[] hyA = array.new_float()   // log10(price)
var float[] htA = array.new_float()   // raw timestamps (for markers)

var float hypA    = na
var float hypB    = na
var float hypC    = na
var float hypRmse = na
var bool  paraOk  = false
var int   nLows   = 0

var float[] txA = array.new_float()   // x of enabled highs, days from Low #1
var float[] tyA = array.new_float()   // log10(price)
var float[] ttA = array.new_float()   // raw timestamps (for markers)

var float topA    = na
var float topB    = na
var float topC    = na
var float topRmse = na
var bool  topOk   = false
var int   nHighs  = 0

// fib levels parsed once from the comma-separated input
var float[] fibLvls = array.new_float()

if barstate.isfirst
    rawLvl = str.replace_all(fibLvlIn, " ", "")
    for s in str.split(rawLvl, ",")
        v = str.tonumber(s)
        if not na(v)
            array.push(fibLvls, v)

    if e1On
        array.push(hxA, (e1T - p1T) / MS_DAY)
        array.push(hyA, math.log10(e1P))
        array.push(htA, e1T)
    if e2On
        array.push(hxA, (e2T - p1T) / MS_DAY)
        array.push(hyA, math.log10(e2P))
        array.push(htA, e2T)
    if e3On
        array.push(hxA, (e3T - p1T) / MS_DAY)
        array.push(hyA, math.log10(e3P))
        array.push(htA, e3T)
    if p1On
        array.push(hxA, 0.0)
        array.push(hyA, math.log10(p1P))
        array.push(htA, p1T)
    if p2On
        array.push(hxA, (p2T - p1T) / MS_DAY)
        array.push(hyA, math.log10(p2P))
        array.push(htA, p2T)
    if p3On
        array.push(hxA, (p3T - p1T) / MS_DAY)
        array.push(hyA, math.log10(p3P))
        array.push(htA, p3T)
    nLows := array.size(hxA)
    [lA, lB, lC, lR, lOk] = fFitHyp(hxA, hyA, htA)
    hypA    := lA
    hypB    := lB
    hypC    := lC
    hypRmse := lR
    paraOk  := lOk

    if h1On
        array.push(txA, (h1T - p1T) / MS_DAY)
        array.push(tyA, math.log10(h1P))
        array.push(ttA, h1T)
    if h2On
        array.push(txA, (h2T - p1T) / MS_DAY)
        array.push(tyA, math.log10(h2P))
        array.push(ttA, h2T)
    if h3On
        array.push(txA, (h3T - p1T) / MS_DAY)
        array.push(tyA, math.log10(h3P))
        array.push(ttA, h3T)
    if h4On
        array.push(txA, (h4T - p1T) / MS_DAY)
        array.push(tyA, math.log10(h4P))
        array.push(ttA, h4T)
    if h5On
        array.push(txA, (h5T - p1T) / MS_DAY)
        array.push(tyA, math.log10(h5P))
        array.push(ttA, h5T)
    nHighs := array.size(txA)
    [tA, tB, tC, tR, tOk] = fFitHyp(txA, tyA, ttA)
    topA    := tA
    topB    := tB
    topC    := tC
    topRmse := tR
    topOk   := tOk

fParaPrice(int t) =>
    x = (t - p1T) / MS_DAY
    math.pow(10.0, hypA + hypB / (hypC - x))

fTopPrice(int t) =>
    x = (t - p1T) / MS_DAY
    math.pow(10.0, topA + topB / (topC - x))

projBotPrice = paraOk ? fParaPrice(nextBotT) : na
projTopPrice = topOk ? fTopPrice(upcomingTopT) : na

// ── Projection: record reference bull shape ─────────────────
// Log-price of the anchor cycle's bull phase (anchor → anchor + bullDays),
// stored as (progress 0..1, log10 close). Historical bars only → shape is
// fixed once the phase is complete; the projection cannot repaint.
// Thinned to ~400 samples: on intraday TFs an unthinned buffer would grow
// to 100k+ entries (1064 days × bars/day) for a curve resampled to ≤300
// points anyway. Min progress step 1/400 caps memory on any timeframe.
var float[] refP = array.new_float()
var float[] refY = array.new_float()
var float lastRefProg = -1.0
refEndT = anchorT + int(bullDays * MS_DAY)
if barstate.isconfirmed and time >= anchorT and time < refEndT
    float refProg = (time - anchorT) / (bullDays * MS_DAY)
    if refProg - lastRefProg >= 1.0 / 400.0
        array.push(refP, refProg)
        array.push(refY, math.log10(close))
        lastRefProg := refProg

// ══════════════════════════════════════════════════════════
// REDRAW GATE — once per bar instead of every tick
// ══════════════════════════════════════════════════════════
// Every drawing block below is anchored to bar-open time, curve fits and
// pivot inputs — none of it changes within a bar. Rebuilding polylines
// (500+ points), fib grids and the dashboard on every realtime tick is
// pure waste; this gate limits the full redraw to the first tick of
// each new last bar (and the initial historical load).
var int lastDrawnBar = -1
bool redrawBar = barstate.islast and bar_index != lastDrawnBar
if redrawBar
    lastDrawnBar := bar_index

// ══════════════════════════════════════════════════════════
// PLOTS & VISUALS — CYCLE TURN LINES & LABELS
// ══════════════════════════════════════════════════════════
var line[]  lns = array.new_line()
var label[] lbs = array.new_label()

if redrawBar
    // clear & redraw (cheap: only runs on the last bar)
    for l in lns
        line.delete(l)
    array.clear(lns)
    for lb in lbs
        label.delete(lb)
    array.clear(lbs)

    kStart = int(kNow) - cyclesBk
    kEnd   = int(kNow) + cyclesFw + (showCycle2Input ? 1 : 0)
    for k = kStart to kEnd
        botT = anchorT + int(k * cycLen * MS_DAY)
        topT = botT + int(bullDays * MS_DAY)

        if showLn
            array.push(lns, line.new(botT, low, botT, high,
                 xloc = xloc.bar_time, extend = extend.both,
                 color = color.new(#089981, 25), style = line.style_solid, width = 2))
            array.push(lns, line.new(topT, low, topT, high,
                 xloc = xloc.bar_time, extend = extend.both,
                 color = color.new(#f23645, 25), style = line.style_dashed, width = 2))

        if showLb
            botFuture = botT > time
            topFuture = topT > time
            string botDate = str.format("{0,date,dd MMM yyyy}", botT)
            string topDate = str.format("{0,date,dd MMM yyyy}", topT)
            string botTxt = (botFuture ? "★ PROJECTED BOTTOM\n" : "▲ CYCLE BOTTOM\n") + botDate
            string topTxt = (topFuture ? "★ PROJECTED TOP\n" : "▼ CYCLE TOP\n") + topDate
            // NEAREST projected bottom/top get NO turn label — the
            // "◎ cycle × curve" labels already mark those exact points
            // with date + price, so a second label would just overlap
            // low label-bg fade (15%) keeps the fill saturated → fixed text
            // colors stay readable on BOTH light and dark chart themes
            // bottom label sits UNDER the low: y = lows-curve price at that
            // date (only where the curve is anchored — from the earliest
            // enabled low onward; otherwise fallback to current close)
            if botT != nextBotT
                float yBot = close
                if paraOk and nLows > 0 and botT >= array.get(htA, 0)
                    yBot := fParaPrice(botT)
                array.push(lbs, label.new(botT, yBot, botTxt,
                     xloc = xloc.bar_time, style = label.style_label_up,
                     color = color.new(#089981, botFuture ? 0 : 15),
                     textcolor = BULL_LABEL_TEXT, size = size.small))
            // top label sits ABOVE the high: y = highs-curve price at that
            // date (only where the curve is anchored — from the earliest
            // enabled high onward; otherwise fallback to current close)
            if topT != upcomingTopT
                float yTop = close
                if topOk and nHighs > 0 and topT >= array.get(ttA, 0)
                    yTop := fTopPrice(topT)
                array.push(lbs, label.new(topT, yTop, topTxt,
                     xloc = xloc.bar_time, style = label.style_label_down,
                     color = color.new(#f23645, topFuture ? 0 : 15),
                     textcolor = BEAR_LABEL_TEXT, size = size.small))

// ══════════════════════════════════════════════════════════
// LOWS HYPERBOLA DRAWING
// ══════════════════════════════════════════════════════════
var polyline paraPl    = na
var polyline paraPlExt = na
var label    paraLbl   = na
var label[]  ptLbs     = array.new_label()

if redrawBar
    if not na(paraPl)
        polyline.delete(paraPl)
        paraPl := na
    if not na(paraPlExt)
        polyline.delete(paraPlExt)
        paraPlExt := na
    if not na(paraLbl)
        label.delete(paraLbl)
        paraLbl := na
    for pl in ptLbs
        label.delete(pl)
    array.clear(ptLbs)

    if showPara and paraOk
        // solid segment: earliest enabled low → projected cycle bottom
        tStart = int(array.get(htA, 0))
        pts = array.new<chart.point>()
        steps = 300
        for i = 0 to steps
            t = tStart + int((nextBotT - tStart) * (i / float(steps)))
            array.push(pts, chart.point.from_time(t, fParaPrice(t)))
        paraPl := polyline.new(pts, curved = false, xloc = xloc.bar_time,
             line_color = paraCol, line_width = 2)

        // dashed extension beyond the projected bottom (default: 10 years)
        if extYearsLow > 0
            extEndT = nextBotT + int(extYearsLow * 365.25 * MS_DAY)
            ptsX = array.new<chart.point>()
            stepsX = 200
            for i = 0 to stepsX
                t = nextBotT + int((extEndT - nextBotT) * (i / float(stepsX)))
                array.push(ptsX, chart.point.from_time(t, fParaPrice(t)))
            paraPlExt := polyline.new(ptsX, curved = false, xloc = xloc.bar_time,
                 line_color = color.new(paraCol, 35), line_style = line.style_dashed,
                 line_width = 2)

        // markers on the anchor lows the curve is built from
        if showPts
            for i = 0 to nLows - 1
                array.push(ptLbs, label.new(int(array.get(htA, i)),
                     math.pow(10.0, array.get(hyA, i)), "",
                     xloc = xloc.bar_time, style = label.style_circle,
                     color = color.new(paraCol, 20), size = size.tiny))

        string fitTxt = nLows > 3 ? "\nLS fit: " + str.tostring(nLows) + " lows · RMSE " + str.tostring(hypRmse, "#.###") : "\nexact through 3 lows"
        string paraDate = str.format("{0,date,dd MMM yyyy}", nextBotT)
        string paraPriceStr = na(projBotPrice) ? "—" : "$" + str.tostring(projBotPrice, format.volume)
        paraLbl := label.new(nextBotT, projBotPrice,
             "◎ cycle × curve\n" + paraDate + "  ≈ " + paraPriceStr + fitTxt,
             xloc = xloc.bar_time, style = label.style_label_upper_left,
             color = color.new(#f7931a, 0), textcolor = color.new(#0c0e15, 0),
             size = size.small)

// ══════════════════════════════════════════════════════════
// TOPS HYPERBOLA DRAWING
// ══════════════════════════════════════════════════════════
var polyline topPl    = na
var polyline topPlExt = na
var label    topLbl   = na
var label[]  topPtLbs = array.new_label()

if redrawBar
    if not na(topPl)
        polyline.delete(topPl)
        topPl := na
    if not na(topPlExt)
        polyline.delete(topPlExt)
        topPlExt := na
    if not na(topLbl)
        label.delete(topLbl)
        topLbl := na
    for pl in topPtLbs
        label.delete(pl)
    array.clear(topPtLbs)

    if showTops and topOk
        // solid segment: earliest enabled high → upcoming projected top
        tStartH = int(array.get(ttA, 0))
        ptsH = array.new<chart.point>()
        stepsH = 300
        for i = 0 to stepsH
            t = tStartH + int((upcomingTopT - tStartH) * (i / float(stepsH)))
            array.push(ptsH, chart.point.from_time(t, fTopPrice(t)))
        topPl := polyline.new(ptsH, curved = false, xloc = xloc.bar_time,
             line_color = topCol, line_width = 2)

        // dashed extension beyond the projected top
        if extYearsTop > 0
            extEndTH = upcomingTopT + int(extYearsTop * 365.25 * MS_DAY)
            ptsHX = array.new<chart.point>()
            stepsHX = 150
            for i = 0 to stepsHX
                t = upcomingTopT + int((extEndTH - upcomingTopT) * (i / float(stepsHX)))
                array.push(ptsHX, chart.point.from_time(t, fTopPrice(t)))
            topPlExt := polyline.new(ptsHX, curved = false, xloc = xloc.bar_time,
                 line_color = color.new(topCol, 35), line_style = line.style_dashed,
                 line_width = 2)

        // markers on the anchor highs the curve is built from
        if showPts
            for i = 0 to nHighs - 1
                array.push(topPtLbs, label.new(int(array.get(ttA, i)),
                     math.pow(10.0, array.get(tyA, i)), "",
                     xloc = xloc.bar_time, style = label.style_circle,
                     color = color.new(topCol, 20), size = size.tiny))

        string fitTxtH = nHighs > 3 ? "\nLS fit: " + str.tostring(nHighs) + " highs · RMSE " + str.tostring(topRmse, "#.###") : "\nexact through 3 highs"
        string topDateH = str.format("{0,date,dd MMM yyyy}", upcomingTopT)
        string topPriceStr = na(projTopPrice) ? "—" : "$" + str.tostring(projTopPrice, format.volume)
        topLbl := label.new(upcomingTopT, projTopPrice,
             "◎ cycle × curve (tops)\n" + topDateH + "  ≈ " + topPriceStr + fitTxtH,
             xloc = xloc.bar_time, style = label.style_label_lower_left,
             color = topCol, textcolor = color.white,
             size = size.small)

// ══════════════════════════════════════════════════════════
// FIBONACCI GRIDS (between pivots)
// ══════════════════════════════════════════════════════════
// Enabled lows & highs are merged chronologically; every leg between two
// pivots of opposite type gets a grid: low→high = bull, high→low = bear.
// Same-type neighbours (e.g. High #4 → High #5 with no low between) are skipped.
var line[]  fibLns = array.new_line()
var label[] fibLbs = array.new_label()
var box[]   fibBxs = array.new_box()

// nearest upcoming BUY range (fed to the dashboard)
var float nearBuyLo   = na
var float nearBuyHi   = na
var float nearBuyEndT = na

if redrawBar
    for l in fibLns
        line.delete(l)
    array.clear(fibLns)
    for lb in fibLbs
        label.delete(lb)
    array.clear(fibLbs)
    for bx in fibBxs
        box.delete(bx)
    array.clear(fibBxs)
    nearBuyLo   := na
    nearBuyHi   := na
    nearBuyEndT := na

    if (showFibB or showFibS) and array.size(fibLvls) > 0
        // merge pivots into one chronological list (parallel arrays)
        evT = array.new_float()
        evP = array.new_float()
        evL = array.new_bool()   // true = low
        for i = 0 to nLows - 1
            array.push(evT, array.get(htA, i))
            array.push(evP, math.pow(10.0, array.get(hyA, i)))
            array.push(evL, true)
        for i = 0 to nHighs - 1
            array.push(evT, array.get(ttA, i))
            array.push(evP, math.pow(10.0, array.get(tyA, i)))
            array.push(evL, false)
        nEv = array.size(evT)
        if nEv >= 2
            // insertion sort by time
            for i = 1 to nEv - 1
                j = i
                while j > 0 and array.get(evT, j - 1) > array.get(evT, j)
                    st = array.get(evT, j - 1)
                    array.set(evT, j - 1, array.get(evT, j))
                    array.set(evT, j, st)
                    sp = array.get(evP, j - 1)
                    array.set(evP, j - 1, array.get(evP, j))
                    array.set(evP, j, sp)
                    sl = array.get(evL, j - 1)
                    array.set(evL, j - 1, array.get(evL, j))
                    array.set(evL, j, sl)
                    j -= 1
            // draw a grid per alternating leg
            for i = 0 to nEv - 2
                aLow = array.get(evL, i)
                bLow = array.get(evL, i + 1)
                if aLow != bLow
                    bullLeg = aLow and not bLow
                    if (bullLeg and showFibB) or (not bullLeg and showFibS)
                        t1  = int(array.get(evT, i))
                        t2  = int(array.get(evT, i + 1))
                        pA  = array.get(evP, i)
                        pB  = array.get(evP, i + 1)
                        col = bullLeg ? fibColB : fibColS
                        // yellow 0.786–0.836 zone, stretched to the end of the leg's cycle
                        if showFibZn
                            zA = fibRev ? fFibPrice(pB, pA, 0.786) : fFibPrice(pA, pB, 0.786)
                            zB = fibRev ? fFibPrice(pB, pA, 0.836) : fFibPrice(pA, pB, 0.836)
                            kEndCyc = math.floor((t2 - anchorT) / (cycLen * MS_DAY)) + 1
                            cycEndT = anchorT + int(kEndCyc * cycLen * MS_DAY)
                            if bullLeg and cycEndT > time and (na(nearBuyEndT) or cycEndT < nearBuyEndT)
                                nearBuyEndT := cycEndT
                                nearBuyLo  := math.min(zA, zB)
                                nearBuyHi  := math.max(zA, zB)
                            array.push(fibBxs, box.new(t1, math.max(zA, zB), cycEndT, math.min(zA, zB),
                                 xloc = xloc.bar_time, bgcolor = fibZnCol,
                                 border_color = color.new(fibZnCol, 40), border_width = 1,
                                 text = bullLeg ? "BUY ZONE" : "SELL ZONE",
                                 text_color = ZONE_TEXT, text_size = size.normal,
                                 text_halign = text.align_center, text_valign = text.align_center))
                        for f in fibLvls
                            lvlP  = fibRev ? fFibPrice(pB, pA, f) : fFibPrice(pA, pB, f)
                            edge  = f == 0.0 or f == 1.0
                            lnSty = edge ? line.style_solid : f == 0.5 ? line.style_dashed : line.style_dotted
                            array.push(fibLns, line.new(t1, lvlP, t2, lvlP,
                                 xloc = xloc.bar_time, color = col,
                                 style = lnSty, width = edge ? 2 : 1))
                            if showFibLb
                                array.push(fibLbs, label.new(t2, lvlP,
                                     str.tostring(f, "#.###") + " · $" + str.tostring(lvlP, format.volume),
                                     xloc = xloc.bar_time, style = label.style_none,
                                     textcolor = color.new(col, 0), size = size.tiny))

// ══════════════════════════════════════════════════════════
// PRICE PROJECTION DRAWING
// ══════════════════════════════════════════════════════════
var polyline projPl  = na
var label    projLbl = na

if redrawBar
    if not na(projPl)
        polyline.delete(projPl)
        projPl := na
    if not na(projLbl)
        label.delete(projLbl)
        projLbl := na

    if showProj and paraOk and topOk
        pStartT = nextBotT
        pEndT   = nextBotT + int(bullDays * MS_DAY)
        yS = math.log10(fParaPrice(pStartT))
        yE = math.log10(fTopPrice(pEndT))

        ptsP = array.new<chart.point>()
        nRef = array.size(refP)
        // replay mode needs a reasonably complete reference phase (≥90% covered)
        bool canReplay = false
        if projMode == "Replay last bull" and nRef >= 10
            float lastPr = array.get(refP, nRef - 1)
            if lastPr >= 0.9 and array.get(refY, nRef - 1) != array.get(refY, 0)
                canReplay := true

        if canReplay
            y0 = array.get(refY, 0)
            yL = array.get(refY, nRef - 1)
            scaleK = (yE - yS) / (yL - y0)
            stepP = math.max(1, int(math.ceil(nRef / 300.0)))
            i = 0
            while i < nRef
                pr = array.get(refP, i)
                yy = yS + (array.get(refY, i) - y0) * scaleK
                array.push(ptsP, chart.point.from_time(
                     pStartT + int(pr * (pEndT - pStartT)), math.pow(10.0, yy)))
                i += stepP
            array.push(ptsP, chart.point.from_time(pEndT, math.pow(10.0, yE)))
        else
            for i = 0 to 100
                yy = yS + (yE - yS) * i / 100.0
                array.push(ptsP, chart.point.from_time(
                     pStartT + int((pEndT - pStartT) * i / 100.0), math.pow(10.0, yy)))

        projPl := polyline.new(ptsP, curved = false, xloc = xloc.bar_time,
             line_color = color.new(projCol, 15), line_style = line.style_dashed,
             line_width = 2)

        string modeTxt = canReplay ? "replay of last bull, rescaled" : "log-linear"
        string projDate = str.format("{0,date,dd MMM yyyy}", pEndT)
        string projPriceStr = "$" + str.tostring(math.pow(10.0, yE), format.volume)
        projLbl := label.new(pEndT, math.pow(10.0, yE),
             "◇ PROJECTED PATH (hypothetical)\n" + projDate + "  ≈ " + projPriceStr + "\n" + modeTxt,
             xloc = xloc.bar_time, style = label.style_label_lower_right,
             color = color.new(projCol, 20), textcolor = color.white,
             size = size.small)

// ══════════════════════════════════════════════════════════
// SELL ZONES (±% around highs)
// ══════════════════════════════════════════════════════════
// Each box spans from the "low date" to the high date. The low date is the
// LATER of: (a) the latest enabled input low before that high,
//           (b) the model's cycle bottom immediately before that high —
// so High #5 (2029) starts at the projected Oct-2026 bottom, not at Low #3.
var box[] sellBxs = array.new_box()

// nearest upcoming SELL range (fed to the dashboard)
var float nearSellLo = na
var float nearSellHi = na
var float nearSellT  = na

if redrawBar
    for bx in sellBxs
        box.delete(bx)
    array.clear(sellBxs)
    nearSellLo := na
    nearSellHi := na
    nearSellT  := na

    if showSellZn
        for i = 0 to nHighs - 1
            tH = int(array.get(ttA, i))
            pH = math.pow(10.0, array.get(tyA, i))
            // (a) latest enabled low strictly before the high
            lowBefore = float(na)
            for j = 0 to nLows - 1
                tL = array.get(htA, j)
                if tL < tH and (na(lowBefore) or tL > lowBefore)
                    lowBefore := tL
            // (b) model cycle bottom immediately before the high
            kB = math.floor((tH - anchorT) / (cycLen * MS_DAY))
            botBefore = anchorT + kB * cycLen * MS_DAY
            startT = int(na(lowBefore) ? botBefore : math.max(lowBefore, botBefore))
            if startT < tH
                if tH > time and (na(nearSellT) or tH < nearSellT)
                    nearSellT  := tH
                    nearSellLo := pH * (1.0 - sellPct / 100.0)
                    nearSellHi := pH * (1.0 + sellPct / 100.0)
                array.push(sellBxs, box.new(
                     startT, pH * (1.0 + sellPct / 100.0),
                     tH,     pH * (1.0 - sellPct / 100.0),
                     xloc = xloc.bar_time, bgcolor = sellZnCol,
                     border_color = color.new(sellZnCol, 40), border_width = 1,
                     text = "SELL ZONE",
                     text_color = ZONE_TEXT, text_size = size.normal,
                     text_halign = text.align_center, text_valign = text.align_center))

        // projected FUTURE top: zone at the tops-curve × projected-date crossing.
        // Skipped if an enabled input high already sits in that cycle (no duplicates).
        if topOk and upcomingTopT > time
            dupHi = false
            for j = 0 to nHighs - 1
                if math.abs(array.get(ttA, j) - upcomingTopT) < cycLen * MS_DAY / 2.0
                    dupHi := true
            if not dupHi
                pProj = fTopPrice(upcomingTopT)
                lowBeforeP = float(na)
                for j = 0 to nLows - 1
                    tL = array.get(htA, j)
                    if tL < upcomingTopT and (na(lowBeforeP) or tL > lowBeforeP)
                        lowBeforeP := tL
                kBp = math.floor((upcomingTopT - anchorT) / (cycLen * MS_DAY))
                botBeforeP = anchorT + kBp * cycLen * MS_DAY
                startP = int(na(lowBeforeP) ? botBeforeP : math.max(lowBeforeP, botBeforeP))
                if startP < upcomingTopT
                    if na(nearSellT) or upcomingTopT < nearSellT
                        nearSellT  := upcomingTopT
                        nearSellLo := pProj * (1.0 - sellPct / 100.0)
                        nearSellHi := pProj * (1.0 + sellPct / 100.0)
                    array.push(sellBxs, box.new(
                         startP, pProj * (1.0 + sellPct / 100.0),
                         upcomingTopT, pProj * (1.0 - sellPct / 100.0),
                         xloc = xloc.bar_time, bgcolor = sellZnCol,
                         border_color = color.new(sellZnCol, 40), border_width = 1,
                         text = "SELL ZONE (proj.)",
                         text_color = ZONE_TEXT, text_size = size.normal,
                         text_halign = text.align_center, text_valign = text.align_center))

// ══════════════════════════════════════════════════════════
// HALVINGS
// ══════════════════════════════════════════════════════════
// Historical halving dates are fixed block events (solid lines).
// The 2028 one is an ESTIMATE (block time drift) → dashed + "(est.)".
var line[]  hvLns = array.new_line()
var label[] hvLbs = array.new_label()

if redrawBar
    for l in hvLns
        line.delete(l)
    array.clear(hvLns)
    for lb in hvLbs
        label.delete(lb)
    array.clear(hvLbs)

    if showHalv
        hvT = array.from(
             timestamp("2012-11-28T00:00:00+00:00"),
             timestamp("2016-07-09T00:00:00+00:00"),
             timestamp("2020-05-11T00:00:00+00:00"),
             timestamp("2024-04-20T00:00:00+00:00"),
             timestamp("2028-04-15T00:00:00+00:00"))
        for i = 0 to array.size(hvT) - 1
            t   = array.get(hvT, i)
            fut = t > time
            array.push(hvLns, line.new(t, low, t, high,
                 xloc = xloc.bar_time, extend = extend.both,
                 color = halvCol,
                 style = fut ? line.style_dashed : line.style_solid, width = 1))
            if showHalvLb
                string hvDate = str.format("{0,date,dd MMM yyyy}", t)
                array.push(hvLbs, label.new(t, close,
                     "⛏ HALVING\n" + hvDate + (fut ? "\n(est.)" : ""),
                     xloc = xloc.bar_time, style = label.style_none,
                     textcolor = HALV_TEXT, size = size.small))

// ══════════════════════════════════════════════════════════
// DASHBOARD (LTM-style: sections, zebra rows, tooltips, gauge)
// ══════════════════════════════════════════════════════════
posTbl = switch dashPos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    =>                position.bottom_left

dashFontSize    = sizeFromString(dashFontSizeInput)
dashFontSizeSub = sizeDownFromString(dashFontSizeInput)

var table dashTbl = na

if redrawBar and showDash
    // ── Values ──────────────────────────────────────────────
    string phaseStr = isBull ? "🟢 BULL" : "🔴 BEAR"
    color  phaseCol = isBull ? BULL_TEXT : BEAR_TEXT
    color  headerBg = isBull ? HEADER_BG_BULL : HEADER_BG_BEAR

    string dayStr  = str.tostring(int(dayInPhase) + 1) + " / " + str.tostring(int(phaseLen))
    string progStr = fGauge(phasePct) + " " + str.tostring(math.round(phasePct * 100)) + "%"

    string topCurveStr = showTops and topOk and not na(projTopPrice) ? "\n≈ $" + str.tostring(projTopPrice, format.volume) + "  (curve)" : ""
    string topCell = str.format("{0,date,dd MMM yyyy}", upcomingTopT) + "  (" + str.tostring(int(math.ceil(daysToTop))) + "d)" + topCurveStr
    string botCurveStr = showPara and paraOk and not na(projBotPrice) ? "\n≈ $" + str.tostring(projBotPrice, format.volume) + "  (curve)" : ""
    string botCell = str.format("{0,date,dd MMM yyyy}", nextBotT) + "  (" + str.tostring(int(math.ceil(daysToBot))) + "d)" + botCurveStr

    // PNL of the next bull leg: projected bottom → following projected top
    float pnlBot = paraOk ? fParaPrice(nextBotT) : na
    float pnlTop = topOk ? fTopPrice(nextBotT + int(bullDays * MS_DAY)) : na
    float legPct = not na(pnlBot) and pnlBot > 0 and not na(pnlTop) ? (pnlTop / pnlBot - 1.0) * 100.0 : na
    string pnlStr = na(legPct) ? "—" : (legPct >= 0 ? "+" : "") + str.tostring(legPct, "#") + "%  (×" + str.tostring(pnlTop / pnlBot, "#.##") + ")"
    color  pnlCol = na(legPct) ? TEXT_MUTED : legPct >= 0 ? BULL_TEXT : BEAR_TEXT

    string buyCell  = na(nearBuyLo)  ? "—" : "$" + str.tostring(nearBuyLo, format.volume) + " – $" + str.tostring(nearBuyHi, format.volume)
    string sellCell = na(nearSellLo) ? "—" : "$" + str.tostring(nearSellLo, format.volume) + " – $" + str.tostring(nearSellHi, format.volume)

    // ── Corrections since 2014: high → following low between pivots ──
    string[] corPer = array.new_string()
    string[] corVal = array.new_string()
    color[]  corCol = array.new_color()
    if showCorrSecInput
        float[] mT = array.new_float()
        float[] mP = array.new_float()
        bool[]  mL = array.new_bool()   // true = low
        for i = 0 to nLows - 1
            array.push(mT, array.get(htA, i))
            array.push(mP, math.pow(10.0, array.get(hyA, i)))
            array.push(mL, true)
        for i = 0 to nHighs - 1
            array.push(mT, array.get(ttA, i))
            array.push(mP, math.pow(10.0, array.get(tyA, i)))
            array.push(mL, false)
        int nM = array.size(mT)
        if nM >= 2
            // insertion sort by time (parallel arrays)
            for i = 1 to nM - 1
                j = i
                while j > 0 and array.get(mT, j - 1) > array.get(mT, j)
                    st = array.get(mT, j - 1)
                    array.set(mT, j - 1, array.get(mT, j))
                    array.set(mT, j, st)
                    sp = array.get(mP, j - 1)
                    array.set(mP, j - 1, array.get(mP, j))
                    array.set(mP, j, sp)
                    sl = array.get(mL, j - 1)
                    array.set(mL, j - 1, array.get(mL, j))
                    array.set(mL, j, sl)
                    j -= 1
            // completed corrections: high immediately followed by a low
            int cutoff2014 = timestamp("2014-01-01T00:00:00+00:00")
            for i = 0 to nM - 2
                if not array.get(mL, i) and array.get(mL, i + 1)
                    float tHi2 = array.get(mT, i)
                    float tLo2 = array.get(mT, i + 1)
                    if tLo2 >= cutoff2014
                        float pHi2 = array.get(mP, i)
                        float pLo2 = array.get(mP, i + 1)
                        if pHi2 > 0
                            float corrPct = (pLo2 / pHi2 - 1.0) * 100.0
                            string perStr = str.format("{0,date,yyyy}", int(tHi2)) + "–" + str.format("{0,date,yyyy}", int(tLo2))
                            array.push(corPer, perStr)
                            array.push(corVal, str.tostring(corrPct, "#.#") + "%")
                            array.push(corCol, BEAR_TEXT)
        // unfinished correction: latest pivot is a high with no low after →
        // project to the lows-curve price at the next model bottom
        if nM >= 1 and not array.get(mL, nM - 1) and paraOk and not na(projBotPrice)
            float tHiP = array.get(mT, nM - 1)
            float pHiP = array.get(mP, nM - 1)
            if pHiP > 0 and nextBotT > tHiP
                float corrPctP = (projBotPrice / pHiP - 1.0) * 100.0
                string perStrP = str.format("{0,date,yyyy}", int(tHiP)) + "–" + str.format("{0,date,yyyy}", nextBotT) + " (proj.)"
                array.push(corPer, perStrP)
                array.push(corVal, str.tostring(corrPctP, "#.#") + "%")
                array.push(corCol, ACCENT_TEXT)
    int corCount = array.size(corPer)

    string tfNote = timeframe.in_seconds() < 86400 ? "⚠ Designed for D / W timeframes" : "⚠ Sample size: 3 cycles"

    // ── Dynamic height ───────────────────────────────────────
    int cycRows   = showCycleSecInput  ? 4 : 0
    int projRows  = showProjSecInput   ? 4 : 0
    int corrRows  = showCorrSecInput and corCount > 0 ? corCount + 1 : 0
    int rngRows   = showRangesSecInput ? 3 : 0
    int totalRows = 5 + cycRows + projRows + corrRows + rngRows

    if not na(dashTbl)
        table.delete(dashTbl)
    dashTbl := table.new(posTbl, 2, totalRows, bgcolor = TABLE_BG, border_color = TABLE_BORDER, border_width = 1, frame_color = TABLE_BORDER, frame_width = 1)

    int  r   = 0
    bool zeb = false
    color rb = TABLE_BG

    table.cell(dashTbl, 0, r, "₿ ALMANAC " + str.tostring(bullDays) + "/" + str.tostring(bearDays) + " · " + (isBull ? "BULL" : "BEAR"), text_color = HEADER_TEXT, bgcolor = headerBg, text_size = dashFontSize, text_halign = text.align_center)
    table.merge_cells(dashTbl, 0, r, 1, r)
    r += 1

    if showCycleSecInput
        table.cell(dashTbl, 0, r, "— Cycle —", text_color = TEXT_MUTED, bgcolor = TABLE_ROW_ALT, text_size = dashFontSizeSub, text_halign = text.align_center)
        table.merge_cells(dashTbl, 0, r, 1, r)
        r += 1
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTbl, 0, r, "Phase", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_left, tooltip = "Current phase of the " + str.tostring(bullDays) + "/" + str.tostring(bearDays) + " time model.")
        table.cell(dashTbl, 1, r, phaseStr, text_color = phaseCol, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_right)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTbl, 0, r, "Phase day", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_left, tooltip = "Day within the current phase / phase length.")
        table.cell(dashTbl, 1, r, dayStr, text_color = TEXT_COLOR, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_right)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTbl, 0, r, "Progress", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_left, tooltip = "Completion of the current phase.")
        table.cell(dashTbl, 1, r, progStr, text_color = TEXT_COLOR, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_right)
        r += 1
        zeb := not zeb

    if showProjSecInput
        table.cell(dashTbl, 0, r, "— Projection —", text_color = TEXT_MUTED, bgcolor = TABLE_ROW_ALT, text_size = dashFontSizeSub, text_halign = text.align_center)
        table.merge_cells(dashTbl, 0, r, 1, r)
        r += 1
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTbl, 0, r, "Proj. top", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_left, tooltip = "Next projected cycle top: date, days left, highs-curve price.")
        table.cell(dashTbl, 1, r, topCell, text_color = BEAR_TEXT, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_right)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTbl, 0, r, "Proj. bottom", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_left, tooltip = "Next projected cycle bottom: date, days left, lows-curve price.")
        table.cell(dashTbl, 1, r, botCell, text_color = BULL_TEXT, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_right)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTbl, 0, r, "Next leg PNL", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_left, tooltip = "Hypothetical move of the NEXT bull leg: projected bottom (lows curve) → following projected top (highs curve). Scenario, not a forecast.")
        table.cell(dashTbl, 1, r, pnlStr, text_color = pnlCol, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_right)
        r += 1
        zeb := not zeb

    if showCorrSecInput and corCount > 0
        table.cell(dashTbl, 0, r, "— Corrections —", text_color = TEXT_MUTED, bgcolor = TABLE_ROW_ALT, text_size = dashFontSizeSub, text_halign = text.align_center)
        table.merge_cells(dashTbl, 0, r, 1, r)
        r += 1
        for ci = 0 to corCount - 1
            rb := zeb ? TABLE_ROW_ALT : TABLE_BG
            table.cell(dashTbl, 0, r, array.get(corPer, ci), text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_left, tooltip = "Correction: enabled pivot high → following pivot low. (proj.) = unfinished, measured to the lows-curve price at the projected bottom.")
            table.cell(dashTbl, 1, r, array.get(corVal, ci), text_color = array.get(corCol, ci), text_size = dashFontSize, bgcolor = rb, text_halign = text.align_right)
            r += 1
            zeb := not zeb

    if showRangesSecInput
        table.cell(dashTbl, 0, r, "— Ranges —", text_color = TEXT_MUTED, bgcolor = TABLE_ROW_ALT, text_size = dashFontSizeSub, text_halign = text.align_center)
        table.merge_cells(dashTbl, 0, r, 1, r)
        r += 1
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTbl, 0, r, "Next buy range", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_left, tooltip = "0.786–0.836 fib zone of the nearest upcoming bull leg.")
        table.cell(dashTbl, 1, r, buyCell, text_color = BULL_TEXT, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_right)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTbl, 0, r, "Next sell range", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_left, tooltip = "±" + str.tostring(sellPct, "#.#") + "% zone around the nearest upcoming (projected) high.")
        table.cell(dashTbl, 1, r, sellCell, text_color = BEAR_TEXT, text_size = dashFontSize, bgcolor = rb, text_halign = text.align_right)
        r += 1
        zeb := not zeb

    bool onRecChart = syminfo.tickerid == "INDEX:BTCUSD" and timeframe.period == "W"
    string recStr = (onRecChart ? "✓ " : "") + "Recommended: INDEX:BTCUSD · W · linear scale"
    color recCol = onRecChart ? BULL_TEXT : ACCENT_TEXT
    table.cell(dashTbl, 0, r, recStr, text_color = recCol, bgcolor = TABLE_ROW_ALT, text_size = dashFontSizeSub, text_halign = text.align_center, tooltip = "The model is calibrated on the INDEX:BTCUSD composite chart, weekly timeframe, REGULAR (linear) price scale — not logarithmic. Exchange charts start later and distort early-history curve fits. Note: Pine cannot detect the chart scale, so the ✓ only confirms symbol and timeframe — check the scale manually. Keep the fib 'Log-scale levels' input OFF on a linear chart (default).")
    table.merge_cells(dashTbl, 0, r, 1, r)
    r += 1
    table.cell(dashTbl, 0, r, tfNote, text_color = ACCENT_TEXT, bgcolor = TABLE_ROW_ALT, text_size = dashFontSizeSub, text_halign = text.align_center)
    table.merge_cells(dashTbl, 0, r, 1, r)
    r += 1
    table.cell(dashTbl, 0, r, "Rhythm ≠ law. Not financial advice.", text_color = TEXT_MUTED, bgcolor = TABLE_ROW_ALT, text_size = dashFontSizeSub, text_halign = text.align_center)
    table.merge_cells(dashTbl, 0, r, 1, r)
    r += 1
    table.cell(dashTbl, 0, r, "Bitcoin Almanac · " + INDICATOR_VERSION, text_color = TEXT_MUTED, text_size = dashFontSizeSub, text_halign = text.align_center)
    table.merge_cells(dashTbl, 0, r, 1, r)

// ══════════════════════════════════════════════════════════
// WATERMARK — WillyAlgoTrader
// ══════════════════════════════════════════════════════════
if redrawBar and showWatermarkInput
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

// ══════════════════════════════════════════════════════════
// ALERTS — alert() with dynamic messages (+ Webhook JSON)
// ══════════════════════════════════════════════════════════
daysToTurn = isBull ? bullDays - phasePos : cycLen - phasePos
preAlert   = daysToTurn <= alertPre and nz(daysToTurn[1], 1.0e9) > alertPre

// prebuilt parts (each assignment on a single line — Pine constraint)
string aTick  = syminfo.tickerid
string aTf    = timeframe.period
string aPrice = str.tostring(close, format.mintick)
string aTopDate  = str.format("{0,date,dd MMM yyyy}", upcomingTopT)
string aBotDate  = str.format("{0,date,dd MMM yyyy}", nextBotT)
string aTurnType = isBull ? "TOP" : "BOTTOM"
string aTurnDate = isBull ? aTopDate : aBotDate
string aDaysLeft = str.tostring(int(math.ceil(daysToTurn)))

if alertsOnInput and flipToBull and barstate.isconfirmed
    string txtBull = "🟢 CYCLE FLIP → BULL | " + aTick + " | TF: " + aTf + " | Price: " + aPrice + " | Model bottom date reached · next top: " + aTopDate
    string jsonBull = '{"event":"cycle_flip_bull","ticker":"' + aTick + '","tf":"' + aTf + '","price":' + aPrice + ',"next_top":"' + aTopDate + '"}'
    alert(webhookInput ? jsonBull : txtBull, alert.freq_once_per_bar_close)

if alertsOnInput and flipToBear and barstate.isconfirmed
    string txtBear = "🔴 CYCLE FLIP → BEAR | " + aTick + " | TF: " + aTf + " | Price: " + aPrice + " | Model top date reached · next bottom: " + aBotDate
    string jsonBear = '{"event":"cycle_flip_bear","ticker":"' + aTick + '","tf":"' + aTf + '","price":' + aPrice + ',"next_bottom":"' + aBotDate + '"}'
    alert(webhookInput ? jsonBear : txtBear, alert.freq_once_per_bar_close)

if alertsOnInput and preAlert and barstate.isconfirmed
    string txtPre = "⏳ CYCLE TURN APPROACHING | " + aTick + " | TF: " + aTf + " | Price: " + aPrice + " | Projected " + aTurnType + " in " + aDaysLeft + "d (" + aTurnDate + ")"
    string jsonPre = '{"event":"cycle_turn_approaching","ticker":"' + aTick + '","tf":"' + aTf + '","price":' + aPrice + ',"turn":"' + aTurnType + '","days_left":' + aDaysLeft + ',"date":"' + aTurnDate + '"}'
    alert(webhookInput ? jsonPre : txtPre, alert.freq_once_per_bar_close)
````
