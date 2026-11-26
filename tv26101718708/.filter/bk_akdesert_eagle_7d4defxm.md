# BK AK-Desert Eagle

- url: https://www.tradingview.com/script/7d4Defxm-BK-AK-Desert-Eagle/
- type: indicator
- pine_id: PUB;8655ba58c61b4cb19edeef0d40b07ff4
- version: 1.0

## Description

🦅✦ BK AK-Desert Eagle — Lock the Rail. Read the Angle. Fire the Level. ✦🦅

This one was built for traders who don’t want weak trendlines, lagging channels, random support/resistance, or useless structure reads.

They want the chart to answer:

What is the real structural direction?
Where are the active rails?
Is price inside, breaking out, retesting, failing, or extending?
Where are the Gann/Square of 9 levels, VWAP pressure points, POC zones, and compression triggers?
Is this move clean, trapped, exhausted, or ready to fire?

BK AK-Desert Eagle is a tactical structural-trend engine built around σ-normalized geometry, multi-scale consensus, channel rails, breakout/retest logic, Square of 9 targeting, structural AVWAP, footprint POC/value area, compression/cascade warnings, regime logic, and adaptive learning.

This is not just another trend channel.

This is a precision structure weapon.

🎖 Full Credit — Respect the Origin

This script is an expanded BK fork/evolution of ST-EP06 — Smart Trader, Episode 06: Isotropic Trend Lines, originally derived from TradingView author ata_sabanci.

Full respect and credit to ata_sabanci for the original inspiration/source contribution. He is one of my favorite creators in the entire TradingView community — one of the rare coders whose work combines out-of-the-box thinking, structural intelligence, and real chart performance. His trendline and support/resistance logic doesn’t just look good; it understands how price actually moves.

The original ST-EP06 framework built the foundation: Isotropic Coordinate System (ICS), Yang-Zhang volatility normalization, block-based geometric mean structure, multi-scale channels, and breakout/retest state logic. The original ST-EP06 notes define the ICS framework as normalizing log-price by Yang-Zhang volatility σ so trend angles become comparable across symbols, timeframes, and volatility regimes.

This release is not meant to claim ownership over his work. It is meant to show how that foundation was expanded into a larger BK tactical engine.

On top of that original architecture, I added the BK expansion layer: Structural Square of 9 targeting, Structural Anchored VWAP, Footprint POC / Value Area logic, Compression / Cascade warnings, Adaptive Learning / Ranker logic, regime gating, continuation levels, and tactical signal/dashboard upgrades. The BK AK-Desert Eagle script itself states this lineage and lists these BK-added modules directly in the header.

And as always, AK honors my mentor A.K. His standard of discipline, patience, restraint, and precision sits behind every serious tool I build.

Above all, full credit and gratitude to Gd — the source of wisdom, timing, endurance, and the ability to survive this game without losing your soul.

🧠 What BK AK-Desert Eagle Actually Does

BK AK-Desert Eagle reads market structure through volatility-normalized geometry.

It takes price, transforms it through σ, builds multi-scale structural rails, checks cross-scale agreement, tracks breakout/retest states, and then adds BK-level tactical confluence through Gann, VWAP, POC, compression, regime, and adaptive learning.

It is designed to answer:

Is the market trending or ranging?
Where is the real channel ceiling?
Where is the real channel floor?
Is the breakout clean, failed, retested, or confirmed?
Are Gann/SQ9 levels lining up with structure?
Is VWAP supporting or invalidating the move?
Is footprint POC confirming or fighting the direction?
Is compression building before expansion?
Is the current move gaining conviction or losing internal structure?

This is structure first.
Confluence second.
Execution last.

No random shots.

🧱 Core Weapon Systems
ICS Structural Channel Engine

The heart of the tool is the Isotropic Coordinate System, or ICS.

Price is transformed into:

y = log(price) / σ

That means the indicator is not just drawing visual trendlines. It is reading price through volatility-normalized structural space.

A move on NQ, CL, GC, BTC, ES, or a stock can be compared through the same normalized framework because the move is measured relative to realized volatility.

Raw price movement lies.
Volatility-adjusted movement tells the truth.

Yang-Zhang σ Normalization

The original ST-EP06 framework uses Yang-Zhang volatility σ as the normalization engine. That matters because Yang-Zhang uses a deeper volatility model than simple close-to-close movement, incorporating gap behavior, open-close movement, and range-based variance.

BK AK-Desert Eagle keeps that foundation because it makes the rails more meaningful.

Instead of asking:

How far did price move?

It asks:

How far did price move relative to actual volatility?

That is what separates noise from structural expansion.

Block-Based Geometric Mean Structure

The original framework partitions price history into blocks and reduces each block into a geometric mean using the log-midpoint of high and low.

That gives the engine a cleaner structural center than close-only methods.

Instead of reacting to one candle’s closing price, it reads the block’s high-low structure and finds the central tendency inside the move.

This helps the rails form from structure, not noise.

6-Scale Structural Consensus

BK AK-Desert Eagle analyzes structure across multiple scales:

3 · 7 · 13 · 19 · 29 · 47

These scales create the battlefield map.

A single scale turning is information.
Multiple scales agreeing is structure.
Five or six scales aligned is serious.

The dashboard shows whether the market is aligned, mixed, ranging, compressing, or shifting.

That is where the indicator stops being a simple channel tool and starts acting like a structural command panel.

🎯 Breakout / Retest State Machine

The original ST-EP06 framework uses a breakout/retest state engine that tracks whether price is inside the channel, breaking out, breaking down, or retesting after a break.

BK AK-Desert Eagle keeps that core state logic and builds around it.

The goal is simple:

Do not just mark that price crossed a line.
Understand what happened after the cross.

Did price break and run?
Did it retest?
Did it fail?
Did it reclaim?
Did it trap?
Did it lose structure?

A breakout without follow-through is not the same as a breakout with confirmation.

A breakdown into support is not the same as a breakdown with continuation.

This tool is built to separate the two.

📐 Structural Rails — Ceiling, Floor, and Extension

BK AK-Desert Eagle builds active channel rails from structure.

The rails are not random drawings. They are calculated from the active multi-scale channel logic and projected forward so the trader can see where structure should matter next.

The key reads are:

Ceiling
Floor
Mid-structure
Extension
Distance from rail
Breakout state
Retest state

This lets you read price in context.

A candle by itself is just a candle.
A candle at a structural rail is information.

🦅 Square of 9 Targeting — Gann Structure Layer

This is one of the major BK additions.

BK AK-Desert Eagle can draw Structural Square of 9 levels from the active channel structure.

In a downtrend, it can anchor from the structural high and project lower Gann levels.

In an uptrend, it can anchor from the structural low and project higher Gann levels.

It supports:

90° / 180° / 270° / 360°
45° levels
22.5° fine levels
Continuation levels beyond market
ATR-based density control
Auto-cleaning by pattern invalidation

This gives the chart a Gann-based targeting grid that is not floating randomly.

The levels are fired from structure.

That matters.

A Square of 9 level without context is just a number.
A Square of 9 level aligned with active rails, VWAP, POC, and compression is a target zone.

📍 Structural Anchored VWAP

BK AK-Desert Eagle includes a Structural Anchored VWAP module.

The AVWAP can anchor from the active structure line-start:

Down-channel → anchor from structural high
Up-channel   → anchor from structural low

That gives the trader institutional mean context after a structural move.

The questions become:

Is price respecting the anchored mean?
Did price reclaim VWAP?
Did price break down through VWAP?
Are the VWAP bands acting as pressure, support, or rejection?

A channel break without VWAP context can be a trap.
A channel break with AVWAP confirmation deserves more respect.

📊 Footprint POC / Value Area Logic

The indicator includes a footprint-based structure module designed around:

Structure POC
Value Area High
Value Area Low
Sloped POC
Horizontal POC
Opposite-slope POC
POC migration

This brings order-flow context into structural geometry.

A channel tells you where price structure is.

POC tells you where value is being accepted.

When structure and value agree, the shot is cleaner.

When price breaks structure but POC refuses to migrate, that can warn of weakness.

When POC migrates with the rail, the move has better internal support.

That is why the POC module matters.

It is not decoration.
It is value confirmation.

⚡ Compression / Cascade Warnings

BK AK-Desert Eagle tracks ICS channel compression and cross-scale cascade behavior.

Compression tells you when structure is tightening.

Cascade tells you when faster scales begin diverging from slower scales.

That matters because reversals often do not begin with a giant candle.

They begin with internal disagreement.

The fast structure turns first.
The slow structure confirms later.
The public sees it last.

This module is designed to warn you before the move becomes obvious.

🧬 Adaptive Learning / Ranker

The adaptive learning system tracks structural outcomes.

It can log breakouts, resolve them against σ-normalized targets/stops, measure duration, track win rate, separate stronger consensus setups from weaker ones, and then feed that learned edge back into live conviction.

Translation:

The indicator does not just identify structure.

It studies whether that structure is actually working on the current symbol and timeframe.

No fake certainty.
No magic prediction.
Just structure, outcome, memory, and weighting.

The market changes.
The tool adapts.

🛡 Regime Gating

Not every market should be read the same way.

A trend channel in a strong trend regime is not the same as a trend channel in a dead range.

BK AK-Desert Eagle uses regime gating to classify the environment and tilt conviction.

The goal is to stop treating every signal equally.

Because they are not equal.

Some breaks deserve execution.
Some breaks deserve suspicion.
Some breaks are traps waiting for traders who only see the line and not the regime.

🧭 Dashboard — The Command Center

The dashboard is the command panel.

It gives the live structural read:

Trend / Angle
Conviction
Cascade
Compression
σ Width
Structure POC
Regime
Flow Delta
Channel Ceiling
Channel Floor
Breakout / Retest Narrative

This is not there to decorate the chart.

It is there to answer the question:

What is the structure doing right now?

The dashboard helps the trader stay locked onto the real read instead of reacting emotionally to every candle.

🔔 Alerts — Let the Chart Call You

BK AK-Desert Eagle includes alert logic for major structural events.

Use alerts for:

Breakout Up
Breakout Down
Retest Events
Direction Shifts
Compression Release
Cascade Warnings
VWAP Reclaim / Breakdown Behavior
Structural State Changes

The point is not to stare at every candle.

The point is to let the chart call you when something real changes.

🔧 Tuning the Desert Eagle — Share Your Best Settings

This indicator has serious depth, and the best settings will depend on symbol, session, timeframe, volatility, and trading style.

I want serious traders to share what they find for:

Trend Block Period
Trend Block Groups
Range Threshold
Yang-Zhang Sigma Length
SQ9 Degree Mode
SQ9 Auto Density
SQ9 ATR Multipliers
SQ9 Continuation Levels
AVWAP Direction
AVWAP Removal Mode
Footprint Ticks Per Row
POC / VA Bins
POC Migration Lookback
ADX Regime Threshold
Learning Target / Stop σ
Ranker Sensitivity
Dashboard Layout

Post your symbol, timeframe, settings, and chart examples.

If you find a killer profile for NQ, ES, CL, GC, BTC, equities, or swing trading, share it.

Do not just take from the community.

Add to the arsenal.

🤝 Pay It Forward

If BK AK-Desert Eagle sharpens your structural read:

Teach someone how to read real rails.
Show the difference between a breakout and a failed breakout.
Explain why volatility-normalized structure matters.
Show how Square of 9 levels line up with active channels.
Explain when VWAP confirms structure and when it invalidates it.
Share the settings that actually worked.

Post the lessons, not just the wins.

Karma in.
Karma out.

If a tool helps you see clearer, use it to help someone else see clearer.

📜 King Solomon’s Lens

King Solomon taught:

“The lot is cast into the lap; but the whole disposing thereof is of the LORD.”

That is one of the deepest truths a trader can carry.

A man can measure the rail.
He can mark the angle.
He can map the Square of 9.
He can anchor VWAP.
He can read POC, compression, regime, and consensus.

He can prepare the shot with everything he knows.

But he does not control the outcome.

That is the line between discipline and arrogance.

BK AK-Desert Eagle was not built to make a trader think he is Gd.
It was built to stop him from gambling blind.

The lot is the uncertainty.
The chart is the battlefield.
The rail is the boundary.
The angle is the intent.
The VWAP is the mean.
The POC is the auction’s memory.
The Square of 9 is the hidden geometry of price.
The compression is the pressure before release.

But the final judgment belongs above the trader.

That means the serious trader does not worship the signal.

He prepares.
He waits.
He measures.
He risks only what he can survive.
He accepts that even the cleanest setup can fail.

That acceptance is not weakness.

It is wisdom.

The fool needs certainty before he acts.
The gambler acts without counsel.
The disciplined trader stands between them.

He does not need certainty.
He needs structure, timing, risk control, and humility.

That is the deeper purpose of this tool:

Not to promise the future,
but to prepare the trader for it.

🦅✦ BK AK-Desert Eagle — Cast the lot with discipline. Measure the field with wisdom. Leave the outcome to Gd. ✦🦅

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Ki11a_B

//@version=6
indicator("BK AK-Desert Eagle",
     "🦅✦",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 200,
     max_boxes_count  = 20)

// ══════════════════════════════════════════════════════════════════════════════════
// BK AK-Desert Eagle
//        🦅✦
//
// Built as an expanded tactical fork/evolution of the ST-EP06 Isotropic Trend
// Lines framework: ICS trend channels, Yang-Zhang σ normalization, multi-scale
// structural consensus, breakout/retest logic, and added BK modules.
//
// BK additions may include:
//   • Structural Square of 9 targeting
//   • Structural Anchored VWAP
//   • Footprint POC / Value Area logic
//   • Compression / Cascade warnings
//   • Adaptive learning / ranker logic
//   • Tactical signal/dashboard upgrades
// ══════════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ══════════════════════════════════════════════════════════════════════════════════

int DIR_UP   =  1
int DIR_DOWN = -1
int DIR_FLAT =  0

const float MIN_SIGMA = 1e-10
const float PI        = math.pi

var array<int> SCALES = array.from(3, 7, 13, 19, 29, 47)

int ST_INSIDE =  0
int ST_BO_UP  =  1
int ST_RT_UP  =  2
int ST_BO_DN  = -1
int ST_RT_DN  = -2

// ══════════════════════════════════════════════════════════════════════════════════
// CUSTOM TYPE
// ══════════════════════════════════════════════════════════════════════════════════

type TrendResult
    int   dir     = 0
    float angle   = 0.0
    int   segEnd  = 0
    float chUpper = na
    float chLower = na

type Setup
    int   bar0      = 0     // locked setup/confirmation bar index
    int   kind      = 0     // 1 = BO Up, 2 = BO Down
    int   dir       = 0
    float entry     = na    // frozen entry price at setup confirmation
    float target    = na    // frozen target price — never recalculated
    float stop      = na    // frozen stop price — never recalculated
    float sigSnap   = na    // frozen σ at setup confirmation
    float atrSnap   = na    // frozen ATR at setup confirmation
    float pocSnap   = na    // frozen structure POC at setup confirmation, if available
    float vwapSnap  = na    // reserved for frozen structural AVWAP at setup confirmation
    float railUSnap = na    // frozen upper channel rail at setup confirmation
    float railLSnap = na    // frozen lower channel rail at setup confirmation
    float sq9Snap   = na    // reserved for frozen nearest SQ9 level at setup confirmation
    float angleSnap = na    // frozen ICS angle at setup confirmation
    int   conf      = 0     // frozen 6-scale consensus at entry

// ══════════════════════════════════════════════════════════════════════════════════
// i18n TYPE
// ══════════════════════════════════════════════════════════════════════════════════

type I18n
    string lbl_period    = "period"
    string lbl_trend     = "trend"
    string lbl_agreement = "agreement"
    string dir_up  = "UP"
    string dir_dn  = "DN"
    string dir_rng = "RNG"
    string st_bo_up          = "Breakout Up"
    string st_bo_dn          = "Breakout Down"
    string st_rt_up_broke_at = "Retest Up · broke at"
    string st_rt_dn_broke_at = "Retest Down · broke at"
    string st_inside         = "Inside channel"
    string st_inside_dir_ch  = "Inside · direction changed"
    string st_inside_fail_up = "Inside · failed breakout up"
    string st_inside_fail_dn = "Inside · failed breakout down"
    string conn_at       = "at"
    string conn_gap      = "(gap)"
    string conn_retested = "· retested"
    string conn_now      = "now"
    string dist_above_ceiling = "% above ceiling"
    string dist_below_floor   = "% below floor"
    string dist_from_floor    = "% from floor"
    string dist_to_ceiling    = "% to ceiling"
    string tip_header    = "BK AK-Desert Eagle — multi-scale trend channels in σ-normalized coordinate space (ICS): price is mapped to y = log(price)/σ, so trend angles and channel distances are comparable across instruments and timeframes.\n\nHeader price is always the live close (Live Exception). All other values anchor at the bar chosen via Calculation Bar — [0] in Live Bar mode, [1] in Close Bar mode."
    string tip_period    = "Block periods for the 6-scale consensus grid.\n\nEach scale partitions history into blocks and reduces each to a log-midpoint geometric mean.\n\nThese six columns use FIXED periods (3·7·13·19·29·47) for cross-scale consensus — they do NOT change with the Trend Block Period input. Your Period input drives the SEPARATE primary channel drawn on the chart (its rails, angle, and breakout state), not this grid."
    string tip_trend     = "Per-scale trend direction from the longest monotonic segment of block geometric means.\n\n▲ UP · ▼ DN · ◈ RNG\n\nRNG = absolute ICS angle within ±Range Threshold. Angle is arctan of σ-normalized slope, comparable across markets."
    string tip_agreement = "Cross-scale consensus.\n\nHow many of the 6 scales agree on direction, shown with the primary channel Ch▲ (ceiling) and Ch▼ (floor).\n\n5/6 or 6/6 = structural trend visible at every temporal resolution."
    string tip_narrative = "Breakout / Retest narrative (primary engine, scale 19).\n\nOne-line state + distance summary:\n\n• Inside — % from floor · % to ceiling (sums to 100%)\n• Breakout Up/Down — price exited channel, shown with breakout price and % beyond the boundary\n• Retest — after moving ≥1σ from the boundary, price returned to test it\n\n✓ = confirmed (retested and bounced ≥1σ).\n(gap) = price crossed the entire channel in one move.\n\nAll distances are % of channel width (scale-invariant). σ thresholds are dynamic (Yang-Zhang)."
    string lbl_close    = "Close"
    string lbl_ceiling  = "Ceiling"
    string lbl_floor    = "Floor"
    string lbl_ext      = "Extension"
    string lbl_trend_tip = "Trend"
    string lbl_angle     = "Angle"
    string lbl_blocks    = "Blocks"
    string alert_warn     = "Alerts require Calculation Bar = Live Bar"
    string alert_warn_tip = "Alerts are currently enabled but Calculation Bar is set to Close Bar.\n\nClose Bar mode anchors computations at the last closed bar, which is semantically incompatible with live alerts. To fire alerts without lag, open indicator settings and change Calculation Bar to Live Bar.\n\nUntil then, all alertconditions are suppressed."

// ══════════════════════════════════════════════════════════════════════════════════
// INPUTS — Calculation
// ══════════════════════════════════════════════════════════════════════════════════

string GP_CALC = "Calculation"

string i_calcBar = input.string("Live Bar", "Calculation Bar",
     options = ["Live Bar", "Close Bar"], group = GP_CALC,
     tooltip = "Which bar anchors every structural computation. Live Bar (default): anchor = bar [0], repaints within the bar. Close Bar: anchor = bar [1], locks on close, never repaints.")

int i_period = input.int(13, "Trend Block Period",
     minval = 5, maxval = 100, group = GP_CALC,
     tooltip = "Bars per structural block. Larger = slower structural moves; smaller = faster, may overfit. Total lookback = Period × Groups.")
int i_groups = input.int(5, "Trend Block Groups",
     minval = 3, maxval = 5, group = GP_CALC,
     tooltip = "Consecutive blocks compared for direction + channel fit. 3 = fast adaptation, 5 = deeper structural view. Capped at 5 for platform limits.")
float i_thresh = input.float(0.5, "Range Threshold (°)",
     minval = 0.0, maxval = 45.0, step = 0.1, group = GP_CALC,
     tooltip = "ICS angle threshold. Between −Threshold and +Threshold → FLAT (ranging). Higher = wider neutral zone.")
int i_sigmaLen = input.int(20, "Yang-Zhang Sigma Length",
     minval = 5, maxval = 100, group = GP_CALC,
     tooltip = "Lookback for the Yang-Zhang realized-volatility σ that normalizes log-price into the Isotropic Coordinate System (ICS).")

// ══════════════════════════════════════════════════════════════════════════════════
// INPUTS — Channel Lines
// ══════════════════════════════════════════════════════════════════════════════════

string GP_CH = "Channel Lines"

color  i_clrUp  = input.color(#26a69a, "Up Color",    group = GP_CH)
color  i_clrDn  = input.color(#ef5350, "Down Color",  group = GP_CH)
color  i_clrRng = input.color(#888888, "Range Color", group = GP_CH)
int    i_chW    = input.int(2, "Line Width", minval = 1, maxval = 5, group = GP_CH)
string i_chSty  = input.string("Solid", "Line Style",
     options = ["Solid", "Dashed", "Dotted"], group = GP_CH)

// ══════════════════════════════════════════════════════════════════════════════════
// INPUTS — Projection Lines
// ══════════════════════════════════════════════════════════════════════════════════

string GP_PJ = "Projection Lines"

int    i_pjOff = input.int(7, "Projection Offset",
     minval = 1, maxval = 100, group = GP_PJ,
     tooltip = "Bars to extend the channel forward beyond the last confirmed bar.")

bool   i_lblProjEnd = input.bool(true, "Move Label To Projection End", group = GP_PJ,
     tooltip = "ON = direction label follows the final projected channel end and respects Projection Offset / convergence clipping. OFF = label stays near the channel midpoint.")

int    i_pjW   = input.int(2, "Projection Width", minval = 1, maxval = 5, group = GP_PJ)
string i_pjSty = input.string("Dotted", "Projection Style",
     options = ["Solid", "Dashed", "Dotted"], group = GP_PJ)

// ══════════════════════════════════════════════════════════════════════════════════
// INPUTS — Display
// ══════════════════════════════════════════════════════════════════════════════════

string GP_DSP = "Display"

string i_lang = input.string("English", "Language",
     options = ["English", "Türkçe", "العربية", "Русский", "Italiano", "Português (BR)", "中文"],
     group = GP_DSP)

bool i_showCh   = input.bool(true, "Show Channel",   group = GP_DSP)
bool i_showFill = input.bool(true, "Show Fill",      group = GP_DSP)
bool i_showDash = input.bool(true, "Show Dashboard", group = GP_DSP)
int  i_dashSz   = input.int(12, "Dashboard Font Size",
     minval = 6, maxval = 50, group = GP_DSP)
string i_dashPos = input.string("Top Right", "Dashboard Position",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group = GP_DSP)

// ══════════════════════════════════════════════════════════════════════════════════
// INPUTS — Channel Fill
// ══════════════════════════════════════════════════════════════════════════════════

string GP_FILL = "Channel Fill"

color  i_fillUp  = input.color(#26a69a, "Fill Up Color",    group = GP_FILL)
color  i_fillDn  = input.color(#ef5350, "Fill Down Color",  group = GP_FILL)
color  i_fillRng = input.color(#888888, "Fill Range Color", group = GP_FILL)
int    i_fillTr  = input.int(85, "Fill Transparency",
     minval = 0, maxval = 100, group = GP_FILL)

// ══════════════════════════════════════════════════════════════════════════════════
// INPUTS — Block Visualization
// ══════════════════════════════════════════════════════════════════════════════════

string GP_BLK = "Block Visualization"

bool  i_showBlk  = input.bool(false, "Show Blocks", group = GP_BLK)
color i_blkClr1  = input.color(#7F77DD, "Block Color (Even)", group = GP_BLK)
color i_blkClr2  = input.color(#1D9E75, "Block Color (Odd)",  group = GP_BLK)
int   i_blkTr    = input.int(90, "Block Transparency",
     minval = 50, maxval = 100, group = GP_BLK)
color i_blkHiClr = input.color(#E24B4A, "Block High Color",   group = GP_BLK)
color i_blkLoClr = input.color(#378ADD, "Block Low Color",    group = GP_BLK)
color i_blkGmClr = input.color(#EF9F27, "GM Color",           group = GP_BLK)
bool  i_showAng    = input.bool(false, "Show Angle Line", group = GP_BLK)
color i_angClr     = input.color(#AFA9EC, "Angle Line Color", group = GP_BLK)
int   i_angExtend  = input.int(7, "Angle Extend N Bars", minval = 0, maxval = 200, group = GP_BLK,
     tooltip = "Bars to project the angle line forward. This is independent from the channel Projection Offset.")
bool  i_showAngLbl = input.bool(false, "Show Angle Label", group = GP_BLK)
bool  i_angLblEnd  = input.bool(false, "Move Angle Label To Angle End", group = GP_BLK,
     tooltip = "OFF = the direction/angle label stays where the normal channel label sits. ON = when the angle line is visible, the label moves to the projected end of the angle line.")

// ══════════════════════════════════════════════════════════════════════════════════
// INPUTS — Alerts
// ══════════════════════════════════════════════════════════════════════════════════

string GP_ALERTS = "Alerts"

bool i_enableAlerts = input.bool(false, "Enable Alerts", group = GP_ALERTS,
     tooltip = "Master toggle for 19 alert conditions. REQUIRES Calculation Bar = Live Bar. In Close Bar mode, alerts auto-suppress and a warning label is shown.")

// ══════════════════════════════════════════════════════════════════════════════════
// INPUTS — Enrichment  (σ-native: Conviction · Cascade · Compression)   [ADDED]
// ══════════════════════════════════════════════════════════════════════════════════

string GP_ENR = "Enrichment"

bool   i_enableEnr = input.bool(true, "Enrichment Panel", group = GP_ENR,
     tooltip = "σ-native intelligence: regime Conviction (0–10), cross-scale Cascade (fast-vs-slow bloc divergence — a leading reversal tell), and ICS Channel Compression (volatility-normalized squeeze). Reads values already computed — negligible CPU.")
string i_enrPos = input.string("Middle Right", "Panel Position",
     options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"],
     group = GP_ENR)
float  i_angRef = input.float(20.0, "Conviction Angle Reference (°)", minval = 5.0, maxval = 60.0, step = 1.0, group = GP_ENR,
     tooltip = "ICS angle treated as a full-strength trend (score 1.0). 45° = 1σ per bar.")
float  i_wAng = input.float(0.35, "Conviction Weight · Angle",     minval = 0.0, maxval = 1.0, step = 0.05, group = GP_ENR)
float  i_wCon = input.float(0.35, "Conviction Weight · Consensus", minval = 0.0, maxval = 1.0, step = 0.05, group = GP_ENR)
float  i_wSeg = input.float(0.15, "Conviction Weight · Segment",   minval = 0.0, maxval = 1.0, step = 0.05, group = GP_ENR)
float  i_wCoh = input.float(0.15, "Conviction Weight · Coherence", minval = 0.0, maxval = 1.0, step = 0.05, group = GP_ENR,
     tooltip = "Coherence = how tightly the 6 scale angles cluster. Tight cluster = cleaner structural trend.")
int    i_angMomLen = input.int(5, "Angle Momentum Lookback (bars)", minval = 1, maxval = 50, group = GP_ENR)
int    i_compLen = input.int(50, "Compression Lookback (bars)", minval = 10, maxval = 300, group = GP_ENR,
     tooltip = "Window for the σ-channel-width average. Width below ~0.8× avg = COMPRESSED; above ~1.2× = EXPANDED.")
bool   i_compTint = input.bool(false, "Tint Background When Compressed", group = GP_ENR)
color  i_compClr  = input.color(#26c6da, "Compression Tint", group = GP_ENR)

// ══════════════════════════════════════════════════════════════════════════════════
// INPUTS — Volume Footprint  (native request.footprint — GATED OFF by default)   [ADDED]
// Correct POC protocol:
//   • POC / VA are calculated ONLY from real footprint bars.
//   • Last N Bars controls BOTH the real-bar POC/VA calculation window and historical rendering length.
//   • Extend N Bars controls forward projection only.
//   • Sloped / Horizontal / Opposite-Slope POC are independent.
// ══════════════════════════════════════════════════════════════════════════════════

string GP_FOOT = "Volume Footprint"

bool   i_enableFoot = input.bool(false, "Volume Footprint (Structure POC + Value Area)", group = GP_FOOT,
     tooltip = "Native request.footprint() order flow. POC / VA are calculated from real bars only. Last N controls the active auction calculation window and render length. Extend N only projects drawings forward. Premium/Ultimate plan and a tick-volume symbol (NOT an INDEX) required.")
int    i_footTicks     = input.int(9, "Ticks per Row", minval = 1, maxval = 10000, group = GP_FOOT, inline = "ft",
     tooltip = "Footprint price-bin size. For NQ, 9 ticks = 2.25 points and is the default sweet spot; above 9 can over-smooth the auction and pull POC away from active structure. Lower = finer/noisier, higher = broader/smoother.")
int    i_footVA        = input.int(70, "Value Area %", minval = 30, maxval = 95, group = GP_FOOT, inline = "ft")

bool   i_footShowSlope = input.bool(true, "Sloped Structure POC", group = GP_FOOT, inline = "fs",
     tooltip = "ON = draw the structure POC as a sloped line riding the active ICS channel axis.")
color  i_footSlopeClr  = input.color(#ffaa28, "", group = GP_FOOT, inline = "fs")
int    i_footSlopeTr   = input.int(0, "Tr", minval = 0, maxval = 100, group = GP_FOOT, inline = "fs")
int    i_footSlopeW    = input.int(2, "W", minval = 1, maxval = 8, group = GP_FOOT, inline = "fs2")
int    i_footLastN     = input.int(11, "Sloped Last N Bars", minval = 3, maxval = 200, group = GP_FOOT, inline = "fs3",
     tooltip = "Active auction window for the Sloped Structure POC / VA. POC and Value Area are calculated from this many real footprint bars, then rendered over the same lookback.")
int    i_footExtend    = input.int(7, "Extend N Bars", minval = 0, maxval = 100, group = GP_FOOT, inline = "fs3",
     tooltip = "Forward extension for the Sloped Structure POC / VA only. This is drawing/projection only; it is NOT included in the POC calculation.")

bool   i_footShowHoriz = input.bool(false, "Horizontal Current POC", group = GP_FOOT, inline = "fh",
     tooltip = "ON = draw a horizontal current structure POC. Independent from Sloped POC.")
color  i_footHorizClr  = input.color(#ffaa28, "", group = GP_FOOT, inline = "fh")
int    i_footHorizTr   = input.int(0, "Tr", minval = 0, maxval = 100, group = GP_FOOT, inline = "fh")
int    i_footHorizW    = input.int(2, "W", minval = 1, maxval = 8, group = GP_FOOT, inline = "fh2")
string i_footHorizSty  = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], group = GP_FOOT, inline = "fh2")
int    i_footHorizLastN= input.int(11, "Horizontal Last N Bars", minval = 0, maxval = 200, group = GP_FOOT, inline = "fh3",
     tooltip = "Active auction window for Horizontal POC when sloped/VA are OFF. Also controls historical render length. Set 0 to draw only from current bar.")
int    i_footHorizExt  = input.int(7, "Extend N Bars", minval = 0, maxval = 100, group = GP_FOOT, inline = "fh3",
     tooltip = "Forward extension for the Horizontal POC. Drawing/projection only.")

bool   i_footShowOpp   = input.bool(false, "Opposite-Slope POC", group = GP_FOOT, inline = "fo",
     tooltip = "ON = draw a counter-slope POC line through the current POC. It mirrors the active ICS structure slope in the opposite direction. Independent from Sloped POC.")
color  i_footOppClr    = input.color(#2962FF, "", group = GP_FOOT, inline = "fo")
int    i_footOppTr     = input.int(0, "Tr", minval = 0, maxval = 100, group = GP_FOOT, inline = "fo")
int    i_footOppW      = input.int(2, "W", minval = 1, maxval = 8, group = GP_FOOT, inline = "fo2")
string i_footOppSty    = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = GP_FOOT, inline = "fo2")
int    i_footOppLastN  = input.int(11, "Opposite Last N Bars", minval = 0, maxval = 200, group = GP_FOOT, inline = "fo3",
     tooltip = "Active auction window for Opposite-Slope POC when sloped/VA/horizontal are OFF. Also controls historical render length. Set 0 to draw only from current bar.")
int    i_footOppExt    = input.int(7, "Extend N Bars", minval = 0, maxval = 100, group = GP_FOOT, inline = "fo3",
     tooltip = "Forward extension for the Opposite-Slope POC. Drawing/projection only.")

bool   i_footShowVA    = input.bool(true, "Value Area Band (sloped)", group = GP_FOOT, inline = "fv")
color  i_footVaClr     = input.color(#9678e6, "", group = GP_FOOT, inline = "fv")
int    i_footVaLineT   = input.int(25, "Line Transp", minval = 0, maxval = 100, group = GP_FOOT, inline = "fv2", tooltip = "Transparency of the VAH / VAL rails. 0 = opaque, 100 = invisible.")
int    i_footVaFillT   = input.int(88, "Fill Transp", minval = 0, maxval = 100, group = GP_FOOT, inline = "fv2", tooltip = "Transparency of the shaded value-area fill between VAH and VAL. 0 = opaque, 100 = invisible.")

bool   i_footShowLbl   = input.bool(true, "Show POC Labels", group = GP_FOOT)
int    i_footStructLen = input.int(300, "Max Calculation Window (bars)", minval = 20, maxval = 600, group = GP_FOOT,
     tooltip = "Safety cap only. Actual POC / VA calculation is driven by the active layer's Last N Bars, and extension bars are never included.")
int    i_footBins      = input.int(50, "POC / VA Bins", minval = 10, maxval = 200, group = GP_FOOT)
int    i_footMig       = input.int(10, "POC Migration Lookback", minval = 2, maxval = 100, group = GP_FOOT,
     tooltip = "Bars over which a rising / falling footprint-POC staircase is measured — order-flow trend confirmation, shown as POC↑ / POC↓ in the panel.")

// ══════════════════════════════════════════════════════════════════════════════════
// INPUTS — Regime Gating  (ADX trend/range → tilt Conviction)   [ADDED]
// ══════════════════════════════════════════════════════════════════════════════════

string GP_REG = "Regime Gating"

bool  i_enableRegime = input.bool(true, "Regime Gating (ADX)", group = GP_REG,
     tooltip = "Classify the tape as TREND or RANGE from ADX. This is a trend-channel engine, so its read is trusted MORE in a trending regime and damped in a range — the regime tilt folds directly into Conviction.")
int   i_adxLen   = input.int(14, "ADX / DI Length", minval = 2, maxval = 100, group = GP_REG, inline = "rg")
float i_adxTrend = input.float(25.0, "Trend ≥ ADX", minval = 10.0, maxval = 60.0, step = 1.0, group = GP_REG, inline = "rg")
float i_regimeStr = input.float(0.20, "Gating Strength", minval = 0.0, maxval = 1.0, step = 0.05, group = GP_REG,
     tooltip = "How hard the regime tilts Conviction. 0.20 = +20% in trend, −10% in range.")

// ══════════════════════════════════════════════════════════════════════════════════
// INPUTS — Adaptive Learning  (σ-native outcome tracking + ranker)   [ADDED]
// ══════════════════════════════════════════════════════════════════════════════════

string GP_LEARN = "Adaptive Learning"

bool  i_enableLearn = input.bool(true, "Track Outcomes (learn)", group = GP_LEARN,
     tooltip = "Log every channel breakout as a setup, resolve it against a σ-normalized target/stop on CLOSED bars only (anti-repaint), and accumulate win rate + average duration by direction. Each setup is tagged with the 6-scale consensus at entry, so the panel reveals whether stronger consensus actually pays. Because targets are in σ, the stats are comparable across instruments.")
float i_learnTgt  = input.float(2.0, "Target (σ)", minval = 0.5, maxval = 20.0, step = 0.5, group = GP_LEARN, inline = "lr",
     tooltip = "Outcome target distance from entry in σ (log-space). Volatility-normalized, so win rates compare across symbols and timeframes.")
float i_learnStop = input.float(1.0, "Stop (σ)", minval = 0.25, maxval = 20.0, step = 0.25, group = GP_LEARN, inline = "lr")
int   i_learnMax  = input.int(60, "Max Resolve (bars)", minval = 5, maxval = 500, group = GP_LEARN,
     tooltip = "If neither target nor stop is hit within this many bars, the setup records as a timeout.")
int   i_learnConfHi = input.int(5, "High-Consensus ≥ (of 6)", minval = 1, maxval = 6, group = GP_LEARN,
     tooltip = "A setup is high-consensus when at least this many of the 6 scales agreed with its direction at entry. Stats split hi vs lo to expose whether consensus helps.")

bool  i_learnQualityFilter = input.bool(true, "Quality Gate Learned Setups", group = GP_LEARN,
     tooltip = "ON = the learning book ignores low-quality breakout states. This prevents raw chop breakouts from polluting the learned edge.")
float i_learnMinConv = input.float(5.0, "Min Conviction To Learn", minval = 0.0, maxval = 10.0, step = 0.25, group = GP_LEARN)
int   i_learnMinConf = input.int(4, "Min Direction Consensus To Learn", minval = 1, maxval = 6, group = GP_LEARN)
bool  i_learnRequireTrend = input.bool(false, "Require ADX Trend To Learn", group = GP_LEARN,
     tooltip = "ON = only logs setups when Regime Gating classifies the tape as TREND. Leave OFF if you want range breakouts included.")

bool  i_learnShowTbl = input.bool(true, "Show Stats Panel", group = GP_LEARN, inline = "lt")
string i_learnPos = input.string("Bottom Right", "Pos", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"], group = GP_LEARN, inline = "lt")

bool  i_enableRanker = input.bool(true, "Adaptive Ranker (feed edge into Conviction)", group = GP_LEARN,
     tooltip = "Fold the learned, consensus-tagged win rate for the CURRENT trend direction back into live Conviction. Winning directions on THIS instrument weight up; failing ones weight down. Shrinkage keeps the multiplier near ×1.0 until enough setups resolve — a 2-trade fluke can't swing it.")
float i_rankSens     = input.float(0.6, "Edge Sensitivity", minval = 0.0, maxval = 2.0, step = 0.1, group = GP_LEARN, inline = "rk")
float i_rankConfSens = input.float(0.5, "Consensus Weight", minval = 0.0, maxval = 2.0, step = 0.1, group = GP_LEARN, inline = "rk")
int   i_rankPrior    = input.int(8, "Prior (shrinkage)", minval = 1, maxval = 100, group = GP_LEARN, inline = "rk2")
float i_rankMin      = input.float(0.5, "Min ×", minval = 0.1, maxval = 1.0, step = 0.05, group = GP_LEARN, inline = "rk2")
float i_rankMax      = input.float(1.6, "Max ×", minval = 1.0, maxval = 3.0, step = 0.1, group = GP_LEARN, inline = "rk2")


// ══════════════════════════════════════════════════════════════════════════════════
// INPUTS — Desert Eagle Icon Signals   [ADDED]
// 5 = Cascade Reversal Warning
// 6 = Compression Release
// Icon only, no background. OFF by default. Transparency controls text/icon color.
// ══════════════════════════════════════════════════════════════════════════════════

string GP_ZEN = "Desert Eagle Icon Signals"

bool   i_showCascadeWarn = input.bool(false, "5 · Cascade Reversal Warning", group = GP_ZEN, inline = "cw")
string i_cwIcon          = input.string("⚠", "", group = GP_ZEN, inline = "cw")
int    i_cwTr            = input.int(0, "Tr", minval = 0, maxval = 100, group = GP_ZEN, inline = "cw")

bool   i_showCompRelease = input.bool(false, "6 · Compression Release", group = GP_ZEN, inline = "cr")
string i_crIcon          = input.string("✦", "", group = GP_ZEN, inline = "cr")
int    i_crTr            = input.int(0, "Tr", minval = 0, maxval = 100, group = GP_ZEN, inline = "cr")

int    i_zenCooldown     = input.int(55, "Icon Cooldown Bars", minval = 0, maxval = 500, group = GP_ZEN,
     tooltip = "Stops signal spam. A new 5/6 icon can print only after this many bars have passed since the prior icon of the same class.")
bool   i_zenFreshOnly    = input.bool(true, "Only First Bar Of Event", group = GP_ZEN,
     tooltip = "ON = icon prints only when the condition first appears. OFF = still uses Cooldown Bars, but can repeat while condition persists.")
int    i_zenMaxLabels    = input.int(20, "Max Icon Labels Stored", minval = 1, maxval = 200, group = GP_ZEN,
     tooltip = "Maximum number of tooltip-enabled 5/6 icon labels kept on the chart. Oldest labels auto-delete.")


// ══════════════════════════════════════════════════════════════════════════════════
// INPUTS — Square of 9   [ADDED]
// Uses the SAME structural extremes that build the current ICS channel.
// Downtrend: HH anchor → lower levels until LL.
// Uptrend:   LL anchor → higher levels until HH.
// ══════════════════════════════════════════════════════════════════════════════════

string GP_SQ9 = "Square of 9"

bool   i_showSq9       = input.bool(false, "Enable Structural SQ9", group = GP_SQ9)
string i_sq9Direction  = input.string("Auto", "SQ9 Direction", options = ["Auto", "Down from High", "Up from Low"], group = GP_SQ9,
     tooltip = "Auto = draws down-from-high in a down-channel and bottom-up from-low in an up-channel. Down from High = only HH → LL. Up from Low = only LL → HH.")
string i_sq9AnchorSrc  = input.string("Line Start Pivot", "SQ9 Anchor Source", options = ["Line Start Pivot", "Actual Swing Extremes", "ICS Block Extremes"], group = GP_SQ9,
     tooltip = "Line Start Pivot = SQ9 anchors to the actual candle high/low inside the exact block that starts the active channel side. This is the cleanest visual anchor. Actual Swing Extremes = scans the full active structure window. ICS Block Extremes = uses the block-center extrema that construct the channel.")
bool   i_sq9RequirePivot = input.bool(false, "Require Official Pivot Anchor", group = GP_SQ9,
     tooltip = "ON = SQ9 only draws when the chosen anchor candle is confirmed as a local pivot using the Pivot L/R settings. OFF = it still anchors to the correct line-start candle and reports pivot status in tooltips.")
int    i_sq9PivotL     = input.int(2, "Pivot L", minval = 1, maxval = 20, group = GP_SQ9, inline = "sqpv")
int    i_sq9PivotR     = input.int(2, "Pivot R", minval = 1, maxval = 20, group = GP_SQ9, inline = "sqpv")
int    i_sq9Extend     = input.int(11, "Extend N Bars", minval = 0, maxval = 200, group = GP_SQ9)

string i_sq9Mode      = input.string("Secondary Degrees", "Degree Mode",
     options = ["Secondary Degrees", "By Degrees", "All 45° Degrees"], group = GP_SQ9,
     tooltip = "Secondary Degrees = 90/180/270/360 only. By Degrees = use the list below. All 45° Degrees = 45/90/135/180/225/270/315/360.")

bool   i_sq9AutoDensity = input.bool(true, "Auto SQ9 Density 180° → 90° → 45° → 22.5°", group = GP_SQ9,
     tooltip = "ON = when Secondary Degrees are selected, the engine automatically decides spacing from ATR. Higher timeframe / high-ATR charts can clean up to 180° spacing. Normal charts use 90°. If 90° spacing is too wide, it adds 45°. If 45° spacing is still too wide, it adds 22.5°.")
int    i_sq9AutoAtrLen = input.int(14, "Auto Density ATR Length", minval = 1, maxval = 200, group = GP_SQ9,
     tooltip = "ATR length used only for SQ9 auto-density decisions. This is separate from continuation ATR so density stays stable and market-adaptive.")

bool   i_sq9Auto180Density = input.bool(true, "Auto 180° HTF Clean Levels", group = GP_SQ9,
     tooltip = "ON = when the 90° SQ9 gap is too tight versus current ATR, the grid automatically simplifies to 180° spacing only. This cleans higher timeframes and high-volatility charts.")

float  i_sq9Auto180AtrMult = input.float(1.0, "Auto 180° Trigger: 90° Gap < ATR ×", minval = 0.10, maxval = 20.0, step = 0.10, group = GP_SQ9,
     tooltip = "If the 90° SQ9 gap is smaller than ATR × this value, the chart is considered too compressed for 90° labels, so only 180°/360° levels are shown. Higher = switches to 180° more often.")

float  i_sq9AutoAtrMult = input.float(2.0, "Auto 45° Trigger: 90° Gap > ATR ×", minval = 0.25, maxval = 20.0, step = 0.25, group = GP_SQ9,
     tooltip = "When the 90° SQ9 gap is greater than ATR × this value, the script automatically inserts the 45° levels. Lower = denser levels more often. Higher = cleaner 90° view longer.")

bool   i_sq9Auto22Density = input.bool(true, "Auto 22.5° Fine Levels", group = GP_SQ9,
     tooltip = "ON = the engine automatically inserts 22.5° levels when the 45° SQ9 gap is still too wide versus ATR. Keep this ON for full auto density. Turn OFF only if you never want the fine 22.5° grid.")
float  i_sq9Auto22AtrMult = input.float(2.0, "Auto 22.5° Trigger: 45° Gap > ATR ×", minval = 0.25, maxval = 20.0, step = 0.25, group = GP_SQ9,
     tooltip = "When the 45° SQ9 gap is greater than ATR × this value, the script automatically inserts the 22.5° levels. Lower = more fine levels. Higher = cleaner chart.")

string i_sq9DegList   = input.string("90,180,270,360", "By-Degrees List", group = GP_SQ9,
     tooltip = "Used only when Degree Mode = By Degrees. Default = secondary/cardinal degrees only: 90,180,270,360. You can manually type 45,135,225,315 or fine 22.5 increments like 22.5,67.5,112.5,157.5 if wanted.")

int    i_sq9RotMax    = input.int(8, "Max Rotations", minval = 1, maxval = 50, group = GP_SQ9,
     tooltip = "Safety cap. Levels stop earlier once they fall below the structural bottom pivot.")

color  i_sq9Clr       = input.color(#ff4d4d, "SQ9 Color", group = GP_SQ9, inline = "sqc")
int    i_sq9Tr        = input.int(65, "Transparency", minval = 0, maxval = 100, group = GP_SQ9, inline = "sqc")
bool   i_sq9ShowLbl   = input.bool(false, "Show Degree Labels", group = GP_SQ9)
string i_sq9AutoRemove = input.string("New Pattern or Invalid", "Auto-remove Mode",
     options = ["New Pattern or Invalid", "New Pattern Only", "Pattern Invalid Only", "Off"], group = GP_SQ9,
     tooltip = "New Pattern = old SQ9 levels are removed/replaced when the structural HH anchor changes. Pattern Invalid = hide SQ9 once the active down-channel is invalidated by an upper-rail reclaim or non-down structure, then allow it again only after a new structural HH anchor appears.")

bool   i_sq9ShowExtra      = input.bool(true, "Show Continuation Levels Beyond Market", group = GP_SQ9,
     tooltip = "Draws the next N Square-of-9 levels beyond the live market low/high using an ATR buffer. Down mode: next levels below Low - ATR×Buffer. Up mode: next levels above High + ATR×Buffer. It does not restart at the structural stop.")
int    i_sq9ExtraLevels    = input.int(3, "Continuation N Levels", minval = 0, maxval = 20, group = GP_SQ9)
int    i_sq9ExtraAtrLen    = input.int(14, "Continuation ATR Length", minval = 1, maxval = 200, group = GP_SQ9, inline = "sqatr")
float  i_sq9ExtraAtrMult   = input.float(0.0, "ATR Buffer", minval = 0.0, maxval = 10.0, step = 0.25, group = GP_SQ9, inline = "sqatr")
int    i_sq9ExtraScanRot   = input.int(50, "Continuation Scan Rotations", minval = 1, maxval = 100, group = GP_SQ9,
     tooltip = "How far the engine scans forward through SQ9 rotations to find the next N continuation levels.")
color  i_sq9ExtraClr       = input.color(#ff4d4d, "Continuation Color", group = GP_SQ9, inline = "sqex")
int    i_sq9ExtraTr        = input.int(35, "Tr", minval = 0, maxval = 100, group = GP_SQ9, inline = "sqex")
bool   i_sq9ExtraShowLbl   = input.bool(true, "Show Continuation Labels", group = GP_SQ9)



// ══════════════════════════════════════════════════════════════════════════════════
// INPUTS — Structural Anchored VWAP   [ADDED]
// Anchors from the active structure line-start:
//   Down-channel = actual swing high from the upper/top line start.
//   Up-channel   = actual swing low from the lower/bottom line start.
// Auto-removes by selected rail/VWAP invalidation mode.
// ══════════════════════════════════════════════════════════════════════════════════

string GP_AVWAP = "Structural Anchored VWAP"

bool   i_showStructAVWAP  = input.bool(false, "Enable Structural AVWAP", group = GP_AVWAP)
string i_avwapDirection   = input.string("Auto", "AVWAP Direction",
     options = ["Auto", "Down from High", "Up from Low"], group = GP_AVWAP,
     tooltip = "Auto = down-channels anchor from the real line-start swing high; up-channels anchor from the real line-start swing low. Manual modes force one side when that side exists.")
string i_avwapRemoveMode  = input.string("Channel Rail Invalid", "Auto-remove Mode",
     options = ["Channel Rail Invalid", "VWAP Reclaim / Breakdown", "Upper Rail Reclaim", "VWAP Reclaim", "Off"], group = GP_AVWAP,
     tooltip = "Channel Rail Invalid = down AVWAP hides on upper-rail reclaim, up AVWAP hides on lower-rail breakdown. VWAP Reclaim / Breakdown = down hides when price closes above VWAP, up hides when price closes below VWAP. Legacy Upper Rail Reclaim / VWAP Reclaim behave the same as the bearish mode.")
int    i_avwapExtend      = input.int(0, "Extend N Bars", minval = 0, maxval = 100, group = GP_AVWAP,
     tooltip = "Optional flat forward projection from the latest AVWAP/band values. 0 = no forward extension.")
int   i_avwapMaxBars      = input.int(45, "Max Draw Bars", minval = 10, maxval = 70, group = GP_AVWAP,
     tooltip = "Object safety. Seven curves are drawn as line segments, so keep this under 70 when all bands are enabled.")

bool  i_avwapShowMid      = input.bool(true, "Show VWAP", group = GP_AVWAP, inline = "mid")
color i_avwapMidClr       = input.color(#90BFF9, "VWAP Color", group = GP_AVWAP, inline = "mid")
int   i_avwapMidTr        = input.int(0, "Tr", minval = 0, maxval = 100, group = GP_AVWAP, inline = "mid")

float i_avwapBand1        = input.float(1.0, "Band 1 σ", minval = 0.1, maxval = 10.0, step = 0.1, group = GP_AVWAP, inline = "b1")
color i_avwapBand1Clr     = input.color(#A5D6A7, "Band 1 Color", group = GP_AVWAP, inline = "b1")
int   i_avwapBand1Tr      = input.int(0, "Tr", minval = 0, maxval = 100, group = GP_AVWAP, inline = "b1")

float i_avwapBand2        = input.float(2.0, "Band 2 σ", minval = 0.1, maxval = 10.0, step = 0.1, group = GP_AVWAP, inline = "b2")
color i_avwapBand2Clr     = input.color(#FFF176, "Band 2 Color", group = GP_AVWAP, inline = "b2")
int   i_avwapBand2Tr      = input.int(15, "Tr", minval = 0, maxval = 100, group = GP_AVWAP, inline = "b2")

float i_avwapBand3        = input.float(3.0, "Band 3 σ", minval = 0.1, maxval = 10.0, step = 0.1, group = GP_AVWAP, inline = "b3")
color i_avwapBand3Clr     = input.color(#90BFF9, "Band 3 Color", group = GP_AVWAP, inline = "b3")
int   i_avwapBand3Tr      = input.int(0, "Tr", minval = 0, maxval = 100, group = GP_AVWAP, inline = "b3")

// ══════════════════════════════════════════════════════════════════════════════════
// ANCHOR RESOLVER
// ══════════════════════════════════════════════════════════════════════════════════

var int _anchor = i_calcBar == "Live Bar" ? 0 : 1

// ══════════════════════════════════════════════════════════════════════════════════
// i18n INSTANCES + SELECTOR
// ══════════════════════════════════════════════════════════════════════════════════

var I18n _i_en = I18n.new()
var I18n _i_tr = I18n.new(
     lbl_period         = "Periyot",
     lbl_trend          = "Trend",
     lbl_agreement      = "Uyum",
     dir_up             = "YÜK",
     dir_dn             = "DÜŞ",
     dir_rng            = "YTY",
     st_bo_up           = "Yukarı Kırılım",
     st_bo_dn           = "Aşağı Kırılım",
     st_rt_up_broke_at  = "Yukarı retest · kırılım",
     st_rt_dn_broke_at  = "Aşağı retest · kırılım",
     st_inside          = "Kanal içinde",
     st_inside_dir_ch   = "Kanal içinde · yön değişti",
     st_inside_fail_up  = "Kanal içinde · başarısız yukarı kırılım",
     st_inside_fail_dn  = "Kanal içinde · başarısız aşağı kırılım",
     conn_at            = "@",
     conn_gap           = "(sıçrama)",
     conn_retested      = "· yeniden test",
     conn_now           = "şimdi",
     dist_above_ceiling = "% tavan üstü",
     dist_below_floor   = "% taban altı",
     dist_from_floor    = "% tabandan",
     dist_to_ceiling    = "% tavana",
     tip_header         = "BK AK-Desert Eagle — σ ile normalize edilmiş koordinat uzayında (ICS) çok ölçekli trend kanalları: fiyat y = log(fiyat)/σ olarak eşlenir, böylece trend açıları ve kanal mesafeleri enstrümanlar ve zaman dilimleri arasında karşılaştırılabilir.\n\nBaşlık fiyatı her zaman canlı kapanıştır (Canlı İstisna). Diğer tüm değerler Calculation Bar ile seçilen barda sabitlenir — Live Bar modunda [0], Close Bar modunda [1].",
     tip_period         = "6 ölçekli paralel analiz için blok periyotları.",
     tip_trend          = "Blok geometrik ortalamalarının en uzun monoton segmentinden ölçek başına trend yönü.",
     tip_agreement      = "Ölçekler arası uzlaşı.",
     tip_narrative      = "Kırılım / Retest anlatımı (birincil motor, ölçek 19).",
     lbl_close          = "Kapanış",
     lbl_ceiling        = "Tavan",
     lbl_floor          = "Taban",
     lbl_ext            = "Uzanım",
     lbl_trend_tip      = "Trend",
     lbl_angle          = "Açı",
     lbl_blocks         = "Blok",
     alert_warn         = "Alarmlar için Calculation Bar = Live Bar olmalı",
     alert_warn_tip     = "Alarmlar etkin ancak Calculation Bar = Close Bar. Gecikmesiz tetikleme için Live Bar'a geçin.")
var I18n _i_ar = I18n.new(
     lbl_period         = "فترة",
     lbl_trend          = "اتجاه",
     lbl_agreement      = "توافق",
     dir_up             = "صعود",
     dir_dn             = "هبوط",
     dir_rng            = "عرضي",
     st_bo_up           = "اختراق صاعد",
     st_bo_dn           = "اختراق هابط",
     st_rt_up_broke_at  = "اختبار صاعد · اختراق",
     st_rt_dn_broke_at  = "اختبار هابط · اختراق",
     st_inside          = "داخل القناة",
     st_inside_dir_ch   = "داخل القناة · تغيّر الاتجاه",
     st_inside_fail_up  = "داخل القناة · اختراق صاعد فاشل",
     st_inside_fail_dn  = "داخل القناة · اختراق هابط فاشل",
     conn_at            = "@",
     conn_gap           = "(فجوة)",
     conn_retested      = "· أُعيد اختباره",
     conn_now           = "الآن",
     dist_above_ceiling = "% فوق السقف",
     dist_below_floor   = "% تحت الأرضية",
     dist_from_floor    = "% من الأرضية",
     dist_to_ceiling    = "% إلى السقف",
     tip_header         = "BK AK-Desert Eagle — قنوات اتجاه متعددة المقاييس في فضاء إحداثي مُطبَّع بالـ σ (ICS): يُحوَّل السعر إلى y = log(price)/σ، فتصبح زوايا الاتجاه ومسافات القناة قابلة للمقارنة عبر الأدوات والأطر الزمنية.\n\nسعر الترويسة هو دائمًا الإغلاق الحي (استثناء حي). أمّا بقية القيم فتُثبَّت عند الشمعة المختارة عبر Calculation Bar — [0] في وضع Live Bar و[1] في وضع Close Bar.",
     tip_period         = "فترات الكتل للتحليل المتوازي على 6 مقاييس.",
     tip_trend          = "اتجاه الترند لكل مقياس من أطول مقطع رتيب.",
     tip_agreement      = "التوافق بين المقاييس.",
     tip_narrative      = "سرد الاختراق / إعادة الاختبار (المحرك الأساسي، مقياس 19).",
     lbl_close          = "إغلاق",
     lbl_ceiling        = "السقف",
     lbl_floor          = "الأرضية",
     lbl_ext            = "امتداد",
     lbl_trend_tip      = "اتجاه",
     lbl_angle          = "زاوية",
     lbl_blocks         = "كتل",
     alert_warn         = "التنبيهات تتطلب Calculation Bar = Live Bar",
     alert_warn_tip     = "التنبيهات مفعّلة لكن Calculation Bar = Close Bar. للتفعيل دون تأخير غيّر إلى Live Bar.")
var I18n _i_ru = I18n.new(
     lbl_period         = "Период",
     lbl_trend          = "Тренд",
     lbl_agreement      = "Согласие",
     dir_up             = "РОСТ",
     dir_dn             = "СПАД",
     dir_rng            = "ФЛЭТ",
     st_bo_up           = "Пробой вверх",
     st_bo_dn           = "Пробой вниз",
     st_rt_up_broke_at  = "Ретест вверх · пробой",
     st_rt_dn_broke_at  = "Ретест вниз · пробой",
     st_inside          = "Внутри канала",
     st_inside_dir_ch   = "Внутри канала · смена направления",
     st_inside_fail_up  = "Внутри канала · неудачный пробой вверх",
     st_inside_fail_dn  = "Внутри канала · неудачный пробой вниз",
     conn_at            = "@",
     conn_gap           = "(гэп)",
     conn_retested      = "· ретест",
     conn_now           = "сейчас",
     dist_above_ceiling = "% над потолком",
     dist_below_floor   = "% под полом",
     dist_from_floor    = "% от пола",
     dist_to_ceiling    = "% до потолка",
     tip_header         = "BK AK-Desert Eagle — многомасштабные трендовые каналы в σ-нормированном координатном пространстве (ICS): цена отображается как y = log(price)/σ, поэтому углы тренда и расстояния канала сопоставимы между инструментами и таймфреймами.\n\nЦена в заголовке — всегда живое закрытие (живое исключение). Все остальные значения привязаны к бару, выбранному в Calculation Bar — [0] в режиме Live Bar, [1] в режиме Close Bar.",
     tip_period         = "Периоды блоков для параллельного анализа на 6 масштабах.",
     tip_trend          = "Направление тренда по каждому масштабу.",
     tip_agreement      = "Межмасштабное согласие.",
     tip_narrative      = "Нарратив пробоя / ретеста (основной движок, масштаб 19).",
     lbl_close          = "Закрытие",
     lbl_ceiling        = "Потолок",
     lbl_floor          = "Пол",
     lbl_ext            = "Расширение",
     lbl_trend_tip      = "Тренд",
     lbl_angle          = "Угол",
     lbl_blocks         = "Блоки",
     alert_warn         = "Оповещениям требуется Calculation Bar = Live Bar",
     alert_warn_tip     = "Оповещения включены, но Calculation Bar = Close Bar. Для срабатывания без задержки смените на Live Bar.")
var I18n _i_it = I18n.new(
     lbl_period         = "Periodo",
     lbl_trend          = "Trend",
     lbl_agreement      = "Consenso",
     dir_up             = "SU",
     dir_dn             = "GIÙ",
     dir_rng            = "LAT",
     st_bo_up           = "Rottura rialzista",
     st_bo_dn           = "Rottura ribassista",
     st_rt_up_broke_at  = "Retest al rialzo · rottura",
     st_rt_dn_broke_at  = "Retest al ribasso · rottura",
     st_inside          = "Dentro il canale",
     st_inside_dir_ch   = "Dentro il canale · direzione cambiata",
     st_inside_fail_up  = "Dentro il canale · rottura rialzista fallita",
     st_inside_fail_dn  = "Dentro il canale · rottura ribassista fallita",
     conn_at            = "@",
     conn_gap           = "(gap)",
     conn_retested      = "· ritestato",
     conn_now           = "ora",
     dist_above_ceiling = "% sopra il tetto",
     dist_below_floor   = "% sotto il pavimento",
     dist_from_floor    = "% dal pavimento",
     dist_to_ceiling    = "% al tetto",
     tip_header         = "BK AK-Desert Eagle — canali di tendenza multi-scala in uno spazio di coordinate normalizzato in σ (ICS): il prezzo è mappato come y = log(price)/σ, così gli angoli di tendenza e le distanze del canale sono confrontabili tra strumenti e timeframe.\n\nIl prezzo nell'intestazione è sempre la chiusura live (Eccezione Live). Tutti gli altri valori sono ancorati alla barra scelta tramite Calculation Bar — [0] in modalità Live Bar, [1] in modalità Close Bar.",
     tip_period         = "Periodi dei blocchi per l'analisi parallela a 6 scale.",
     tip_trend          = "Direzione di tendenza per scala.",
     tip_agreement      = "Consenso tra scale.",
     tip_narrative      = "Narrativa rottura / retest (motore primario, scala 19).",
     lbl_close          = "Chiusura",
     lbl_ceiling        = "Tetto",
     lbl_floor          = "Pavimento",
     lbl_ext            = "Estensione",
     lbl_trend_tip      = "Trend",
     lbl_angle          = "Angolo",
     lbl_blocks         = "Blocchi",
     alert_warn         = "Gli avvisi richiedono Calculation Bar = Live Bar",
     alert_warn_tip     = "Avvisi abilitati ma Calculation Bar = Close Bar. Per attivarli senza ritardo passa a Live Bar.")
var I18n _i_pt = I18n.new(
     lbl_period         = "Período",
     lbl_trend          = "Tendência",
     lbl_agreement      = "Consenso",
     dir_up             = "ALTA",
     dir_dn             = "BAIXA",
     dir_rng            = "LAT",
     st_bo_up           = "Rompimento de alta",
     st_bo_dn           = "Rompimento de baixa",
     st_rt_up_broke_at  = "Reteste de alta · rompimento",
     st_rt_dn_broke_at  = "Reteste de baixa · rompimento",
     st_inside          = "Dentro do canal",
     st_inside_dir_ch   = "Dentro do canal · direção mudou",
     st_inside_fail_up  = "Dentro do canal · rompimento de alta falhou",
     st_inside_fail_dn  = "Dentro do canal · rompimento de baixa falhou",
     conn_at            = "@",
     conn_gap           = "(gap)",
     conn_retested      = "· retestado",
     conn_now           = "agora",
     dist_above_ceiling = "% acima do teto",
     dist_below_floor   = "% abaixo do piso",
     dist_from_floor    = "% do piso",
     dist_to_ceiling    = "% ao teto",
     tip_header         = "BK AK-Desert Eagle — canais de tendência multiescala num espaço de coordenadas normalizado em σ (ICS): o preço é mapeado como y = log(price)/σ, de modo que ângulos de tendência e distâncias do canal são comparáveis entre instrumentos e timeframes.\n\nO preço no cabeçalho é sempre o fechamento ao vivo (Exceção ao Vivo). Todos os outros valores ancoram na barra escolhida via Calculation Bar — [0] no modo Live Bar, [1] no modo Close Bar.",
     tip_period         = "Períodos dos blocos para a análise paralela em 6 escalas.",
     tip_trend          = "Direção da tendência por escala.",
     tip_agreement      = "Consenso entre escalas.",
     tip_narrative      = "Narrativa de rompimento / reteste (motor primário, escala 19).",
     lbl_close          = "Fechamento",
     lbl_ceiling        = "Teto",
     lbl_floor          = "Piso",
     lbl_ext            = "Extensão",
     lbl_trend_tip      = "Tendência",
     lbl_angle          = "Ângulo",
     lbl_blocks         = "Blocos",
     alert_warn         = "Alertas exigem Calculation Bar = Live Bar",
     alert_warn_tip     = "Alertas ativados mas Calculation Bar = Close Bar. Para disparar sem atraso mude para Live Bar.")
var I18n _i_zh = I18n.new(
     lbl_period         = "周期",
     lbl_trend          = "趋势",
     lbl_agreement      = "一致度",
     dir_up             = "上涨",
     dir_dn             = "下跌",
     dir_rng            = "横盘",
     st_bo_up           = "向上突破",
     st_bo_dn           = "向下突破",
     st_rt_up_broke_at  = "上破回踩 · 突破",
     st_rt_dn_broke_at  = "下破回踩 · 突破",
     st_inside          = "通道内",
     st_inside_dir_ch   = "通道内 · 方向改变",
     st_inside_fail_up  = "通道内 · 向上突破失败",
     st_inside_fail_dn  = "通道内 · 向下突破失败",
     conn_at            = "@",
     conn_gap           = "(跳空)",
     conn_retested      = "· 回踩",
     conn_now           = "现在",
     dist_above_ceiling = "% 高于顶部",
     dist_below_floor   = "% 低于底部",
     dist_from_floor    = "% 距底部",
     dist_to_ceiling    = "% 距顶部",
     tip_header         = "BK AK-Desert Eagle — σ 归一化坐标空间（ICS）中的多尺度趋势通道：价格映射为 y = log(price)/σ，使趋势角度与通道距离可在不同品种和周期间比较。\n\n标题价格始终为实时收盘价（实时例外）。其余所有数值锚定于 Calculation Bar 选定的K线 — Live Bar 模式为 [0]，Close Bar 模式为 [1]。",
     tip_period         = "用于 6 尺度并行分析的区块周期。",
     tip_trend          = "每个尺度的趋势方向。",
     tip_agreement      = "跨尺度一致度。",
     tip_narrative      = "突破 / 回踩叙述（主引擎，尺度 19）。",
     lbl_close          = "收盘",
     lbl_ceiling        = "顶部",
     lbl_floor          = "底部",
     lbl_ext            = "延伸",
     lbl_trend_tip      = "趋势",
     lbl_angle          = "角度",
     lbl_blocks         = "区块",
     alert_warn         = "警报需要 Calculation Bar = Live Bar",
     alert_warn_tip     = "警报已启用但 Calculation Bar = Close Bar。为无延迟触发请改为 Live Bar。")

I18n _L = switch i_lang
    "Türkçe"         => _i_tr
    "العربية"         => _i_ar
    "Русский"        => _i_ru
    "Italiano"       => _i_it
    "Português (BR)" => _i_pt
    "中文"            => _i_zh
    =>                  _i_en

// ══════════════════════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════════════════════

f_sty(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

f_dClr(int d) =>
    d == DIR_UP ? i_clrUp : d == DIR_DOWN ? i_clrDn : i_clrRng

f_dStr(int d, I18n L) =>
    d == DIR_UP ? "▲ " + L.dir_up : d == DIR_DOWN ? "▼ " + L.dir_dn : "◈ " + L.dir_rng

f_fClr(int d) =>
    d == DIR_UP ? i_fillUp : d == DIR_DOWN ? i_fillDn : i_fillRng


// ══════════════════════════════════════════════════════════════════════════════════
// HELPERS — Desert Eagle Additions   [ADDED]
// ══════════════════════════════════════════════════════════════════════════════════

f_clearLines(array<line> _a) =>
    if array.size(_a) > 0
        for _i = 0 to array.size(_a) - 1
            line.delete(array.get(_a, _i))
    array.clear(_a)

f_clearLabels(array<label> _a) =>
    if array.size(_a) > 0
        for _i = 0 to array.size(_a) - 1
            label.delete(array.get(_a, _i))
    array.clear(_a)

f_pushLimitedLabel(array<label> _a, label _lb, int _maxN) =>
    array.push(_a, _lb)
    while array.size(_a) > _maxN
        label.delete(array.shift(_a))

f_sq9Tip(float _baseDeg, float _fullDeg, float _lvl, float _anchor, float _stop, int _x1, int _x2) =>
    "Square of 9" +
     "\nDegree: " + str.tostring(int(_baseDeg)) + "°" +
     "\nFull rotation degree: " + str.tostring(_fullDeg, "#") + "°" +
     "\nLevel: " + str.tostring(_lvl, format.mintick) +
     "\nAnchor: " + str.tostring(_anchor, format.mintick) +
     "\nStop: " + str.tostring(_stop, format.mintick) +
     "\nBars: " + str.tostring(_x1) + " → " + str.tostring(_x2)

f_sq9ExtraTip(float _baseDeg, float _fullDeg, float _lvl, float _anchor, float _stop, float _atr, float _ref, int _x1, int _x2, int _n) =>
    "Square of 9 Continuation" +
     "\nDegree: " + str.tostring(int(_baseDeg)) + "°" +
     "\nFull rotation degree: " + str.tostring(_fullDeg, "#") + "°" +
     "\nLevel: " + str.tostring(_lvl, format.mintick) +
     "\nAnchor: " + str.tostring(_anchor, format.mintick) +
     "\nStructural stop: " + str.tostring(_stop, format.mintick) +
     "\nATR buffer ref: " + str.tostring(_ref, format.mintick) +
     "\nATR: " + str.tostring(_atr, format.mintick) +
     "\nContinuation slot: " + str.tostring(_n) +
     "\nBars: " + str.tostring(_x1) + " → " + str.tostring(_x2)
f_drawSq9Lvl(bool _use, float _baseDeg, int _rot, float _root, float _sign, int _dir, float _anchor, float _stop, int _x1, int _x2, color _col, bool _showLbl, float _lastFullDeg, array<line> _lines, array<label> _labels) =>
    float _last = _lastFullDeg
    if _use
        float _fullDeg = _baseDeg + (_rot * 360.0)
        float _lvl     = math.pow(_root + _sign * (_fullDeg / 180.0), 2)
        bool  _ok      = _dir == DIR_DOWN ? (_lvl <= _anchor and _lvl >= _stop) : (_lvl >= _anchor and _lvl <= _stop)
        if _ok
            line _ln = line.new(_x1, _lvl, _x2, _lvl,
                 xloc  = xloc.bar_index,
                 color = _col,
                 style = line.style_dashed,
                 width = 1)
            array.push(_lines, _ln)
            _last := _fullDeg

            if _showLbl
                label _lb = label.new(_x2, _lvl,
                     str.tostring(_fullDeg, "#.#") + "°",
                     xloc      = xloc.bar_index,
                     style     = label.style_none,
                     textcolor = _col,
                     size      = size.tiny,
                     tooltip   = f_sq9Tip(_baseDeg, _fullDeg, _lvl, _anchor, _stop, _x1, _x2))
                array.push(_labels, _lb)
    _last

f_drawSq9ExtraLvl(bool _use, float _baseDeg, int _rot, float _root, float _sign, int _dir, float _anchor, float _stop, float _atr, float _ref, int _x1, int _x2, color _col, bool _showLbl, float _lastFullDeg, int _drawn, int _maxDraw, array<line> _lines, array<label> _labels) =>
    int _out = _drawn
    if _use and _out < _maxDraw
        float _fullDeg = _baseDeg + (_rot * 360.0)
        float _lvl     = math.pow(_root + _sign * (_fullDeg / 180.0), 2)
        bool  _ok      = (na(_lastFullDeg) or _fullDeg > _lastFullDeg) and (_dir == DIR_DOWN ? (_lvl <= _ref) : (_lvl >= _ref))
        if _ok
            line _ln = line.new(_x1, _lvl, _x2, _lvl,
                 xloc  = xloc.bar_index,
                 color = _col,
                 style = line.style_dotted,
                 width = 1)
            array.push(_lines, _ln)

            if _showLbl
                label _lb = label.new(_x2, _lvl,
                     "N" + str.tostring(_out + 1) + " · " + str.tostring(_fullDeg, "#.#") + "°",
                     xloc      = xloc.bar_index,
                     style     = label.style_none,
                     textcolor = _col,
                     size      = size.tiny,
                     tooltip   = f_sq9ExtraTip(_baseDeg, _fullDeg, _lvl, _anchor, _stop, _atr, _ref, _x1, _x2, _out + 1))
                array.push(_labels, _lb)
            _out += 1
    _out


// ══════════════════════════════════════════════════════════════════════════════════
// ICS HELPERS — Isotropic Coordinate System transformations
// ══════════════════════════════════════════════════════════════════════════════════

f_icsLine(float p1, int x1, float p2, int x2, int targetX, float sig) =>
    float out = p1
    if x1 != x2 and p1 > 0 and p2 > 0 and sig > MIN_SIGMA
        float y1 = math.log(p1) / sig
        float y2 = math.log(p2) / sig
        float yT = y1 + (y2 - y1) * (targetX - x1) / (x2 - x1)
        out := math.exp(yT * sig)
    out

f_icsAngle(float p1, int x1, float p2, int x2, float sig) =>
    float out = 0.0
    if x1 != x2 and p1 > 0 and p2 > 0 and sig > MIN_SIGMA
        float y1 = math.log(p1) / sig
        float y2 = math.log(p2) / sig
        out := math.atan((y2 - y1) / (x2 - x1)) * 180.0 / PI
    out

f_icsPos(float p, float pLo, float pHi, float sig) =>
    float out = 0.5
    if p > 0 and pLo > 0 and pHi > 0 and pHi > pLo and sig > MIN_SIGMA
        float y   = math.log(p)   / sig
        float yLo = math.log(pLo) / sig
        float yHi = math.log(pHi) / sig
        out := (y - yLo) / (yHi - yLo)
    out

// ══════════════════════════════════════════════════════════════════════════════════
// YANG-ZHANG VOLATILITY σ
// ══════════════════════════════════════════════════════════════════════════════════

float _yzOR = math.log(open[_anchor] / nz(close[_anchor + 1], open[_anchor]))
float _yzCO = math.log(close[_anchor] / open[_anchor])
float _yzHO = math.log(high[_anchor] / open[_anchor])
float _yzHC = math.log(high[_anchor] / close[_anchor])
float _yzLO = math.log(low[_anchor]  / open[_anchor])
float _yzLC = math.log(low[_anchor]  / close[_anchor])

float _sqOR = ta.variance(_yzOR, i_sigmaLen)
float _sqCO = ta.variance(_yzCO, i_sigmaLen)
float _sqRS = ta.sma(_yzHO * _yzHC + _yzLO * _yzLC, i_sigmaLen)

float _k    = 0.34 / (1.34 + (i_sigmaLen + 1.0) / math.max(i_sigmaLen - 1.0, 1.0))
float _sq   = nz(_sqOR) + _k * nz(_sqCO) + (1.0 - _k) * nz(_sqRS)
float sigma = math.max(math.sqrt(math.max(_sq, 0.0)), MIN_SIGMA)

float _avwapSrc = hlc3
max_bars_back(_avwapSrc, 2500)
max_bars_back(high, 2500)
max_bars_back(low, 2500)
max_bars_back(volume, 2500)
float _sq9Atr        = ta.atr(i_sq9ExtraAtrLen)
float _sq9DensityAtr = ta.atr(i_sq9AutoAtrLen)

// ══════════════════════════════════════════════════════════════════════════════════
// PRIMARY — Block Construction
// ══════════════════════════════════════════════════════════════════════════════════

float _hhS = ta.highest(high, i_period)
float _llS = ta.lowest(low, i_period)
max_bars_back(_hhS, 2500)
max_bars_back(_llS, 2500)

var array<float> _bGm = array.new<float>()
var array<float> _bHi = array.new<float>()
var array<float> _bLo = array.new<float>()
var array<int>   _bCx = array.new<int>()

_bGm.clear()
_bHi.clear()
_bLo.clear()
_bCx.clear()

bool _ok = bar_index >= i_groups * i_period + _anchor

if _ok
    for i = 0 to i_groups - 1
        int   off = _anchor + i * i_period
        float hi  = _hhS[off]
        float lo  = _llS[off]
        _bGm.push((hi > 0 and lo > 0) ? math.exp((math.log(hi) + math.log(lo)) / 2.0) : na)
        _bHi.push(hi)
        _bLo.push(lo)
        _bCx.push(bar_index - off - int(i_period / 2))

// ══════════════════════════════════════════════════════════════════════════════════
// PRIMARY — Direction + ICS Angle + Channel Fitting
// ══════════════════════════════════════════════════════════════════════════════════

int   _dir = DIR_FLAT
float _ang = 0.0
int   _seg = 0
float _chUp = na
float _chLo = na

if _ok and _bGm.size() >= 2
    float g0 = _bGm.get(0)
    float g1 = _bGm.get(1)
    if not na(g0) and not na(g1) and g0 != g1
        int pd = g0 > g1 ? DIR_UP : DIR_DOWN
        _seg := 1
        if i_groups > 2
            for i = 1 to i_groups - 2
                float a = _bGm.get(i)
                float b = _bGm.get(i + 1)
                if not na(a) and not na(b)
                    if (a > b ? DIR_UP : (a < b ? DIR_DOWN : DIR_FLAT)) == pd
                        _seg := i + 1
                    else
                        break
                else
                    break

        float sig = math.max(nz(sigma, MIN_SIGMA), MIN_SIGMA)
        if _bGm.size() > _seg
            _ang := f_icsAngle(_bGm.get(_seg), _bCx.get(_seg),
                 _bGm.get(0), _bCx.get(0), sig)

        _dir := math.abs(_ang) <= i_thresh ? DIR_FLAT : pd

        if _seg >= 1 and _bHi.size() > _seg
            float fHH = na
            float fLH = na
            float fHL = na
            float fLL = na
            int   xHH = na
            int   xLH = na
            int   xHL = na
            int   xLL = na
            for i = 0 to _seg
                float h = _bHi.get(i)
                float l = _bLo.get(i)
                int   x = _bCx.get(i)
                if na(fHH) or h > fHH
                    fHH := h
                    xHH := x
                if na(fLH) or h < fLH
                    fLH := h
                    xLH := x
                if na(fHL) or l > fHL
                    fHL := l
                    xHL := x
                if na(fLL) or l < fLL
                    fLL := l
                    xLL := x

            int now = bar_index - _anchor
            if _dir == DIR_UP
                _chUp := f_icsLine(fLH, xLH, fHH, xHH, now, sig)
                _chLo := f_icsLine(fLL, xLL, fHL, xHL, now, sig)
            else if _dir == DIR_DOWN
                _chUp := f_icsLine(fHH, xHH, fLH, xLH, now, sig)
                _chLo := f_icsLine(fHL, xHL, fLL, xLL, now, sig)
            else
                _chUp := nz(fHH)
                _chLo := nz(fLL)

// ══════════════════════════════════════════════════════════════════════════════════
// 6-SCALE TREND FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════════

f_analyze(array<float> gm, array<float> hi, array<float> lo, array<int> cx,
     int groups, float thresh, float sig) =>
    int d = DIR_FLAT
    float a = 0.0
    int se = 0
    float cu = na
    float cd = na
    if gm.size() >= 2
        float g0 = gm.get(0)
        float g1 = gm.get(1)
        if not na(g0) and not na(g1) and g0 != g1
            int pd = g0 > g1 ? DIR_UP : DIR_DOWN
            se := 1
            if groups > 2
                for i = 1 to groups - 2
                    if i + 1 >= gm.size()
                        break
                    float gA = gm.get(i)
                    float gB = gm.get(i + 1)
                    if not na(gA) and not na(gB)
                        if (gA > gB ? DIR_UP : (gA < gB ? DIR_DOWN : DIR_FLAT)) == pd
                            se := i + 1
                        else
                            break
                    else
                        break
            if gm.size() > se
                a := f_icsAngle(gm.get(se), cx.get(se), gm.get(0), cx.get(0), sig)
            d := math.abs(a) <= thresh ? DIR_FLAT : pd
            if se >= 1 and hi.size() > se
                float fHH = na
                float fLH = na
                float fHL = na
                float fLL = na
                int xHH = na
                int xLH = na
                int xHL = na
                int xLL = na
                for i = 0 to se
                    float _h = hi.get(i)
                    float _l = lo.get(i)
                    int _x = cx.get(i)
                    if na(fHH) or _h > fHH
                        fHH := _h
                        xHH := _x
                    if na(fLH) or _h < fLH
                        fLH := _h
                        xLH := _x
                    if na(fHL) or _l > fHL
                        fHL := _l
                        xHL := _x
                    if na(fLL) or _l < fLL
                        fLL := _l
                        xLL := _x
                int n = bar_index - _anchor
                if d == DIR_UP
                    cu := f_icsLine(fLH, xLH, fHH, xHH, n, sig)
                    cd := f_icsLine(fLL, xLL, fHL, xHL, n, sig)
                else if d == DIR_DOWN
                    cu := f_icsLine(fHH, xHH, fLH, xLH, n, sig)
                    cd := f_icsLine(fHL, xHL, fLL, xLL, n, sig)
                else
                    cu := nz(fHH)
                    cd := nz(fLL)
    TrendResult.new(d, a, se, cu, cd)

f_compute(float hhSer, float llSer, int per, int grp, float thr, float sig) =>
    array<float> g = array.new<float>()
    array<float> h = array.new<float>()
    array<float> l = array.new<float>()
    array<int>   x = array.new<int>()
    bool hasData = bar_index >= grp * per + _anchor
    if hasData
        for i = 0 to grp - 1
            int off = _anchor + i * per
            float hi = hhSer[off]
            float lo = llSer[off]
            g.push((hi > 0 and lo > 0) ? math.exp((math.log(hi) + math.log(lo)) / 2.0) : na)
            h.push(hi)
            l.push(lo)
            x.push(bar_index - off - int(per / 2))
    hasData ? f_analyze(g, h, l, x, grp, thr, sig) : TrendResult.new()

// ══════════════════════════════════════════════════════════════════════════════════
// 6-SCALE — HH/LL Series + Computation + Consensus
// ══════════════════════════════════════════════════════════════════════════════════

float _hh3  = ta.highest(high, 3)
float _ll3  = ta.lowest(low, 3)
float _hh7  = ta.highest(high, 7)
float _ll7  = ta.lowest(low, 7)
float _hh13 = ta.highest(high, 13)
float _ll13 = ta.lowest(low, 13)
float _hh19 = ta.highest(high, 19)
float _ll19 = ta.lowest(low, 19)
float _hh29 = ta.highest(high, 29)
float _ll29 = ta.lowest(low, 29)
float _hh47 = ta.highest(high, 47)
float _ll47 = ta.lowest(low, 47)

max_bars_back(_hh3,  500)
max_bars_back(_ll3,  500)
max_bars_back(_hh7,  500)
max_bars_back(_ll7,  500)
max_bars_back(_hh13, 500)
max_bars_back(_ll13, 500)
max_bars_back(_hh19, 500)
max_bars_back(_ll19, 500)
max_bars_back(_hh29, 500)
max_bars_back(_ll29, 500)
max_bars_back(_hh47, 500)
max_bars_back(_ll47, 500)

float _trSig = math.max(nz(sigma, MIN_SIGMA), MIN_SIGMA)

TrendResult _tr3  = f_compute(_hh3,  _ll3,  3,  i_groups, i_thresh, _trSig)
TrendResult _tr7  = f_compute(_hh7,  _ll7,  7,  i_groups, i_thresh, _trSig)
TrendResult _tr13 = f_compute(_hh13, _ll13, 13, i_groups, i_thresh, _trSig)
TrendResult _tr29 = f_compute(_hh29, _ll29, 29, i_groups, i_thresh, _trSig)
TrendResult _tr47 = f_compute(_hh47, _ll47, 47, i_groups, i_thresh, _trSig)

TrendResult _tr19 = f_compute(_hh19, _ll19, 19, i_groups, i_thresh, _trSig)

array<TrendResult> _trends = array.from(_tr3, _tr7, _tr13, _tr19, _tr29, _tr47)

int _cUp   = 0
int _cDn   = 0
int _cFlat = 0
for i = 0 to 5
    int td = _trends.get(i).dir
    if td == DIR_UP
        _cUp += 1
    else if td == DIR_DOWN
        _cDn += 1
    else
        _cFlat += 1

// ══════════════════════════════════════════════════════════════════════════════════
// REGIME (ADX) + ADAPTIVE-LEARNING STATE + RANKER   [ADDED]
//   State arrays + ranker are declared here so Conviction can read the PRIOR-bar book;
//   setup registration & resolution happen later in the bar (no lookahead).
// ══════════════════════════════════════════════════════════════════════════════════

[_diPlus, _diMinus, _adx] = ta.dmi(i_adxLen, i_adxLen)
bool   _regimeTrend = not na(_adx) and _adx >= i_adxTrend
string _regimeTxt   = na(_adx) ? "—" : (_regimeTrend ? "TREND " : "RANGE ") + str.tostring(math.round(_adx))
float  _regimeMult  = (i_enableRegime and not na(_adx)) ? (_regimeTrend ? 1.0 + i_regimeStr : 1.0 - i_regimeStr * 0.5) : 1.0

// Outcome book — indexed by kind: 1 = Breakout Up · 2 = Breakout Down (slot 0 unused).
var array<int> sWin   = array.new<int>(3, 0)
var array<int> sLoss  = array.new<int>(3, 0)
var array<int> sTo    = array.new<int>(3, 0)
var array<int> sDur   = array.new<int>(3, 0)   // Σ winning durations (bars)
var array<int> sHiTot = array.new<int>(3, 0)   // resolved while high-consensus
var array<int> sHiWin = array.new<int>(3, 0)   // wins among high-consensus
var array<Setup> _openSetups = array.new<Setup>()

// Shrunk win rate — pulled toward 0.5 until i_rankPrior samples accumulate.
f_shrunkWR(int w, int l) => (w + i_rankPrior * 0.5) / (w + l + i_rankPrior)

// Learned edge multiplier for a direction kind, modulated by current consensus and by
// whether high-consensus has HISTORICALLY helped that kind. Neutral (×1.0) with no data.
f_rankMult(int kind, int curConf) =>
    float wr   = f_shrunkWR(array.get(sWin, kind), array.get(sLoss, kind))
    float m    = 1.0 + i_rankSens * (wr - 0.5) * 2.0
    float hiWR = f_shrunkWR(array.get(sHiWin, kind), array.get(sHiTot, kind) - array.get(sHiWin, kind))
    float edge = hiWR - wr
    float cB   = 1.0 + i_rankConfSens * (curConf / 6.0) * edge * 2.0
    math.max(i_rankMin, math.min(i_rankMax, m * cB))

// ══════════════════════════════════════════════════════════════════════════════════
// BREAKOUT / RETEST STATE MACHINE (primary engine, scale 19)
// ══════════════════════════════════════════════════════════════════════════════════

float _extPos = f_icsPos(nz(close[_anchor]), _chLo, _chUp, _trSig)

var int   _boState     = ST_INSIDE
var bool  _boConfirm   = false
var bool  _boDistanced = false
var bool  _boGapped    = false
var float _boPrice     = na
var float _rtPrice     = na
var int   _prevBDir    = DIR_FLAT
var int   _retFrom     = 0

float _distUp = (not na(_chUp) and nz(close[_anchor]) > 0 and _chUp > 0 and _trSig > MIN_SIGMA)
     ? math.abs(math.log(nz(close[_anchor])) - math.log(_chUp)) / _trSig : 0.0
float _distDn = (not na(_chLo) and nz(close[_anchor]) > 0 and _chLo > 0 and _trSig > MIN_SIGMA)
     ? math.abs(math.log(nz(close[_anchor])) - math.log(_chLo)) / _trSig : 0.0

bool _dirReset = false

if _ok and not na(_chUp) and not na(_chLo)
    bool _dirChg = _dir != _prevBDir and _prevBDir != DIR_FLAT
    _prevBDir := _dir

    if _dirChg
        _dirReset    := true
        _boState     := ST_INSIDE
        _boConfirm   := false
        _boDistanced := false
        _boGapped    := false
        _boPrice     := na
        _rtPrice     := na
        _retFrom     := 0
    else
        switch _boState
            ST_INSIDE =>
                if _extPos > 1.0
                    _boState     := ST_BO_UP
                    _boPrice     := _chUp
                    _boConfirm   := false
                    _boDistanced := false
                    _boGapped    := false
                    _rtPrice     := na
                    _retFrom     := 0
                else if _extPos < 0.0
                    _boState     := ST_BO_DN
                    _boPrice     := _chLo
                    _boConfirm   := false
                    _boDistanced := false
                    _boGapped    := false
                    _rtPrice     := na
                    _retFrom     := 0

            ST_BO_UP =>
                if _distUp >= 1.0
                    _boDistanced := true
                if _extPos < 0.0
                    _boState     := ST_BO_DN
                    _boPrice     := _chLo
                    _boConfirm   := false
                    _boDistanced := false
                    _boGapped    := true
                    _rtPrice     := na
                    _retFrom     := 0
                else if _extPos <= 1.0
                    _boState     := ST_INSIDE
                    _retFrom     := 1
                    _boConfirm   := false
                    _boDistanced := false
                    _boGapped    := false
                else if _boDistanced and _distUp < 1.0
                    _boState  := ST_RT_UP
                    _rtPrice  := nz(close[_anchor])
                    _boGapped := false

            ST_RT_UP =>
                if _extPos < 0.0
                    _boState     := ST_BO_DN
                    _boPrice     := _chLo
                    _boConfirm   := false
                    _boDistanced := false
                    _boGapped    := true
                    _rtPrice     := na
                    _retFrom     := 0
                else if _extPos <= 1.0
                    _boState     := ST_INSIDE
                    _retFrom     := 1
                    _boConfirm   := false
                    _boDistanced := false
                    _boGapped    := false
                else if _distUp >= 1.0
                    _boState     := ST_BO_UP
                    _boConfirm   := true
                    _boDistanced := true
                    _boGapped    := false

            ST_BO_DN =>
                if _distDn >= 1.0
                    _boDistanced := true
                if _extPos > 1.0
                    _boState     := ST_BO_UP
                    _boPrice     := _chUp
                    _boConfirm   := false
                    _boDistanced := false
                    _boGapped    := true
                    _rtPrice     := na
                    _retFrom     := 0
                else if _extPos >= 0.0
                    _boState     := ST_INSIDE
                    _retFrom     := -1
                    _boConfirm   := false
                    _boDistanced := false
                    _boGapped    := false
                else if _boDistanced and _distDn < 1.0
                    _boState  := ST_RT_DN
                    _rtPrice  := nz(close[_anchor])
                    _boGapped := false

            ST_RT_DN =>
                if _extPos > 1.0
                    _boState     := ST_BO_UP
                    _boPrice     := _chUp
                    _boConfirm   := false
                    _boDistanced := false
                    _boGapped    := true
                    _rtPrice     := na
                    _retFrom     := 0
                else if _extPos >= 0.0
                    _boState     := ST_INSIDE
                    _retFrom     := -1
                    _boConfirm   := false
                    _boDistanced := false
                    _boGapped    := false
                else if _distDn >= 1.0
                    _boState     := ST_BO_DN
                    _boConfirm   := true
                    _boDistanced := true
                    _boGapped    := false

// ══════════════════════════════════════════════════════════════════════════════════
// VISUALIZATION — Channel + Projection + Markers + Label + Dashboard
// ══════════════════════════════════════════════════════════════════════════════════

var line     _upLn   = na
var line     _loLn   = na
var line     _upPj   = na
var line     _loPj   = na
var linefill _chFill = na
var linefill _pjFill = na
var label    _lbl    = na
var label    _mkUp   = na
var label    _mkLo   = na
var table    _dash   = na

var array<box>   _blkBoxes = array.new<box>()
var array<line>  _blkHiLns = array.new<line>()
var array<line>  _blkLoLns = array.new<line>()
var array<label> _blkGmLbs = array.new<label>()
var array<line>  _blkGmLns = array.new<line>()

var line  _angLn = na
var line  _angPj = na

var array<line>  _sq9Lines   = array.new_line()
var array<label> _sq9Labels  = array.new_label()
var array<line>  _avwapLines = array.new_line()
var array<label> _zenLabels  = array.new_label()

// SQ9 auto-remove state.
// Active anchor = same structural extreme that drives the SQ9 direction:
// HH for down-from-high, LL for up-from-low.
// Invalidated stays true until a new structural anchor appears.
var int   _sq9ActiveAnchorX = na
var float _sq9ActiveAnchorP = na
var int   _sq9ActiveDir     = DIR_FLAT
var bool  _sq9Invalidated   = false

if barstate.islastconfirmedhistory or barstate.islast
    line.delete(_upLn)
    line.delete(_loLn)
    line.delete(_upPj)
    line.delete(_loPj)
    linefill.delete(_chFill)
    linefill.delete(_pjFill)
    label.delete(_lbl)
    label.delete(_mkUp)
    label.delete(_mkLo)
    _upLn   := na
    _loLn   := na
    _upPj   := na
    _loPj   := na
    _chFill := na
    _pjFill := na
    _lbl    := na
    _mkUp   := na
    _mkLo   := na

    line.delete(_angLn)
    line.delete(_angPj)
    _angLn := na
    _angPj := na

    for bx in _blkBoxes
        box.delete(bx)
    _blkBoxes.clear()
    for ln in _blkHiLns
        line.delete(ln)
    _blkHiLns.clear()
    for ln in _blkLoLns
        line.delete(ln)
    _blkLoLns.clear()
    for lb in _blkGmLbs
        label.delete(lb)
    _blkGmLbs.clear()
    for ln in _blkGmLns
        line.delete(ln)
    _blkGmLns.clear()

    f_clearLines(_sq9Lines)
    f_clearLabels(_sq9Labels)
    f_clearLines(_avwapLines)

    if i_showBlk and _ok and _bGm.size() >= 1
        float _pvGmY = na
        int   _pvGmX = na
        int   _nBlk  = math.min(i_groups, _bGm.size())
        for i = 0 to _nBlk - 1
            int   bOff   = _anchor + i * i_period
            int   bRight = bar_index - bOff
            int   bLeft  = bRight - i_period + 1
            float bHi    = _bHi.get(i)
            float bLo    = _bLo.get(i)
            float bGm    = _bGm.get(i)
            int   bCx    = _bCx.get(i)

            if not na(bHi) and not na(bLo)
                color cBlk = i % 2 == 0 ? i_blkClr1 : i_blkClr2
                _blkBoxes.push(box.new(bLeft, bHi, bRight, bLo,
                     border_color = color.new(cBlk, math.max(i_blkTr - 25, 0)),
                     bgcolor      = color.new(cBlk, i_blkTr),
                     border_width = 1, border_style = line.style_dashed))
                _blkHiLns.push(line.new(bLeft, bHi, bRight, bHi,
                     color = color.new(i_blkHiClr, 40),
                     width = 1, style = line.style_dashed))
                _blkLoLns.push(line.new(bLeft, bLo, bRight, bLo,
                     color = color.new(i_blkLoClr, 40),
                     width = 1, style = line.style_dashed))

            if not na(bGm) and not na(bCx)
                string gmTip = "Block " + str.tostring(i) +
                     "\nHi: " + str.tostring(nz(bHi), format.mintick) +
                     "\nLo: " + str.tostring(nz(bLo), format.mintick) +
                     "\nGM: " + str.tostring(bGm, format.mintick) +
                     "\nBars: " + str.tostring(bLeft) + ".." + str.tostring(bRight)
                _blkGmLbs.push(label.new(bCx, bGm, "◆",
                     style     = label.style_label_center,
                     color     = color.new(chart.bg_color, 100),
                     textcolor = i_blkGmClr,
                     size      = math.max(i_dashSz - 2, 6),
                     tooltip   = gmTip))
                if not na(_pvGmY) and not na(_pvGmX)
                    _blkGmLns.push(line.new(bCx, bGm, _pvGmX, _pvGmY,
                         color = color.new(i_blkGmClr, 30),
                         width = 2, style = line.style_solid))
                _pvGmY := bGm
                _pvGmX := bCx

    if i_showCh and _ok and _seg >= 1 and _bHi.size() > _seg
        float hhV = na
        float lhV = na
        float hlV = na
        float llV = na
        int   hhX = na
        int   lhX = na
        int   hlX = na
        int   llX = na
        for i = 0 to _seg
            float h = _bHi.get(i)
            float l = _bLo.get(i)
            int   x = _bCx.get(i)
            if na(hhV) or h > hhV
                hhV := h
                hhX := x
            if na(lhV) or h < lhV
                lhV := h
                lhX := x
            if na(hlV) or l > hlV
                hlV := l
                hlX := x
            if na(llV) or l < llV
                llV := l
                llX := x

        int sLx = _bCx.get(_seg)
        int sRx = _bCx.get(0)
        float uY1 = na
        float uY2 = na
        float lY1 = na
        float lY2 = na

        if _dir == DIR_UP
            uY1 := f_icsLine(lhV, lhX, hhV, hhX, sLx, _trSig)
            uY2 := f_icsLine(lhV, lhX, hhV, hhX, sRx, _trSig)
            lY1 := f_icsLine(llV, llX, hlV, hlX, sLx, _trSig)
            lY2 := f_icsLine(llV, llX, hlV, hlX, sRx, _trSig)
        else if _dir == DIR_DOWN
            uY1 := f_icsLine(hhV, hhX, lhV, lhX, sLx, _trSig)
            uY2 := f_icsLine(hhV, hhX, lhV, lhX, sRx, _trSig)
            lY1 := f_icsLine(hlV, hlX, llV, llX, sLx, _trSig)
            lY2 := f_icsLine(hlV, hlX, llV, llX, sRx, _trSig)
        else
            uY1 := nz(hhV)
            uY2 := nz(hhV)
            lY1 := nz(llV)
            lY2 := nz(llV)

        color chClr = f_dClr(_dir)
        int   ax    = bar_index - _anchor
        float uYa   = f_icsLine(uY1, sLx, uY2, sRx, ax, _trSig)
        float lYa   = f_icsLine(lY1, sLx, lY2, sRx, ax, _trSig)

        // SQ9 auto-remove / reset logic.
        // Auto:
        //   Down-channel = HH anchor → levels downward until LL.
        //   Up-channel   = LL anchor → levels upward until HH.
        bool _sq9AutoNew     = i_sq9AutoRemove == "New Pattern or Invalid" or i_sq9AutoRemove == "New Pattern Only"
        bool _sq9AutoInvalid = i_sq9AutoRemove == "New Pattern or Invalid" or i_sq9AutoRemove == "Pattern Invalid Only"

        bool _sq9WantDown = i_sq9Direction == "Down from High" or (i_sq9Direction == "Auto" and _dir == DIR_DOWN)
        bool _sq9WantUp   = i_sq9Direction == "Up from Low"   or (i_sq9Direction == "Auto" and _dir == DIR_UP)
        int  _sq9Dir      = _sq9WantUp ? DIR_UP : (_sq9WantDown ? DIR_DOWN : DIR_FLAT)

        // SQ9 anchor source.
        // Line Start Pivot fixes the visual-anchor problem:
        //   Down mode: actual candle high from the block that starts the upper/top channel side.
        //   Up mode:   actual candle low  from the block that starts the lower/bottom channel side.
        // This keeps SQ9 married to the same structural line that is being drawn, but uses the
        // true candle X/Y instead of the block-center X.
        float _sq9BlockAnchorP = _sq9Dir == DIR_DOWN ? hhV : _sq9Dir == DIR_UP ? llV : na
        int   _sq9BlockAnchorX = _sq9Dir == DIR_DOWN ? hhX : _sq9Dir == DIR_UP ? llX : na
        float _sq9BlockStopP   = _sq9Dir == DIR_DOWN ? llV : _sq9Dir == DIR_UP ? hhV : na
        int   _sq9BlockStopX   = _sq9Dir == DIR_DOWN ? llX : _sq9Dir == DIR_UP ? hhX : na

        // Actual candle inside the exact block that created the channel-side anchor.
        float _sqLineAnchorP = na
        int   _sqLineAnchorX = na
        int   _sqLineAnchorOff = na
        float _sqLineStopP = na
        int   _sqLineStopX = na

        int _sqHalf = int(i_period / 2)
        int _sqAnchorCenterX = _sq9BlockAnchorX
        int _sqStopCenterX   = _sq9BlockStopX
        int _sqAnchorRightX  = not na(_sqAnchorCenterX) ? _sqAnchorCenterX + _sqHalf : na
        int _sqAnchorLeftX   = not na(_sqAnchorRightX) ? _sqAnchorRightX - i_period + 1 : na
        int _sqStopRightX    = not na(_sqStopCenterX) ? _sqStopCenterX + _sqHalf : na
        int _sqStopLeftX     = not na(_sqStopRightX) ? _sqStopRightX - i_period + 1 : na

        // Full structure window left edge. This fixes missing the first half of the oldest block.
        int _sqOldRightX     = sLx + _sqHalf
        int _sqStructLeftX   = _sqOldRightX - i_period + 1

        // Full-window extremes are still available as a separate anchor source.
        float _sqSwingHH = na
        float _sqSwingLL = na
        int   _sqSwingHHX = na
        int   _sqSwingLLX = na

        int _sqScanWin = math.min(math.max(ax - _sqStructLeftX, 0), 600)
        for _jSwing = 0 to 600
            if _jSwing <= _sqScanWin
                int _offSwing = _anchor + _jSwing
                int _xSwing = bar_index - _offSwing
                float _hSwing = high[_offSwing]
                float _lSwing = low[_offSwing]

                // Full active-window extremes.
                if _xSwing >= _sqStructLeftX and _xSwing <= ax
                    if na(_sqSwingHH) or _hSwing > _sqSwingHH
                        _sqSwingHH := _hSwing
                        _sqSwingHHX := _xSwing
                    if na(_sqSwingLL) or _lSwing < _sqSwingLL
                        _sqSwingLL := _lSwing
                        _sqSwingLLX := _xSwing

                // Official line-start block anchor.
                if not na(_sqAnchorLeftX) and _xSwing >= _sqAnchorLeftX and _xSwing <= _sqAnchorRightX
                    if _sq9Dir == DIR_DOWN
                        if na(_sqLineAnchorP) or _hSwing > _sqLineAnchorP
                            _sqLineAnchorP := _hSwing
                            _sqLineAnchorX := _xSwing
                            _sqLineAnchorOff := _offSwing
                    else if _sq9Dir == DIR_UP
                        if na(_sqLineAnchorP) or _lSwing < _sqLineAnchorP
                            _sqLineAnchorP := _lSwing
                            _sqLineAnchorX := _xSwing
                            _sqLineAnchorOff := _offSwing

                // Opposite structural stop block.
                if not na(_sqStopLeftX) and _xSwing >= _sqStopLeftX and _xSwing <= _sqStopRightX
                    if _sq9Dir == DIR_DOWN
                        if na(_sqLineStopP) or _lSwing < _sqLineStopP
                            _sqLineStopP := _lSwing
                            _sqLineStopX := _xSwing
                    else if _sq9Dir == DIR_UP
                        if na(_sqLineStopP) or _hSwing > _sqLineStopP
                            _sqLineStopP := _hSwing
                            _sqLineStopX := _xSwing

        bool _sqUseLineStart = i_sq9AnchorSrc == "Line Start Pivot" and not na(_sqLineAnchorP) and not na(_sqLineStopP)
        bool _sqUseSwing     = i_sq9AnchorSrc == "Actual Swing Extremes" and not na(_sqSwingHH) and not na(_sqSwingLL)

        float _sq9AnchorP = _sqUseLineStart ? _sqLineAnchorP : _sqUseSwing ? (_sq9Dir == DIR_DOWN ? _sqSwingHH : _sq9Dir == DIR_UP ? _sqSwingLL : na) : _sq9BlockAnchorP
        int   _sq9AnchorX = _sqUseLineStart ? _sqLineAnchorX : _sqUseSwing ? (_sq9Dir == DIR_DOWN ? _sqSwingHHX : _sq9Dir == DIR_UP ? _sqSwingLLX : na) : _sq9BlockAnchorX
        float _sq9StopP   = _sqUseLineStart ? _sqLineStopP   : _sqUseSwing ? (_sq9Dir == DIR_DOWN ? _sqSwingLL : _sq9Dir == DIR_UP ? _sqSwingHH : na) : _sq9BlockStopP
        int   _sq9StopX   = _sqUseLineStart ? _sqLineStopX   : _sqUseSwing ? (_sq9Dir == DIR_DOWN ? _sqSwingLLX : _sq9Dir == DIR_UP ? _sqSwingHHX : na) : _sq9BlockStopX

        // Optional local-pivot confirmation for the chosen anchor.
        int  _sq9AnchorOff = not na(_sq9AnchorX) ? bar_index - _sq9AnchorX : na
        bool _sq9AnchorPivotOK = not i_sq9RequirePivot
        if not na(_sq9AnchorOff)
            bool _pivOk = true
            for _kPv = 1 to 20
                if _kPv <= i_sq9PivotL
                    if _sq9Dir == DIR_DOWN and high[_sq9AnchorOff] <= high[_sq9AnchorOff + _kPv]
                        _pivOk := false
                    if _sq9Dir == DIR_UP and low[_sq9AnchorOff] >= low[_sq9AnchorOff + _kPv]
                        _pivOk := false
                if _kPv <= i_sq9PivotR and _sq9AnchorOff - _kPv >= 0
                    if _sq9Dir == DIR_DOWN and high[_sq9AnchorOff] <= high[_sq9AnchorOff - _kPv]
                        _pivOk := false
                    if _sq9Dir == DIR_UP and low[_sq9AnchorOff] >= low[_sq9AnchorOff - _kPv]
                        _pivOk := false
            _sq9AnchorPivotOK := _pivOk
        bool _sq9RawRangeOK = _sq9Dir == DIR_DOWN ? (not na(_sq9AnchorP) and not na(_sq9StopP) and _sq9AnchorP > _sq9StopP) :
             _sq9Dir == DIR_UP ? (not na(_sq9AnchorP) and not na(_sq9StopP) and _sq9StopP > _sq9AnchorP) : false
        bool _sq9RangeOK = _sq9RawRangeOK and (not i_sq9RequirePivot or _sq9AnchorPivotOK)

        bool _sq9NewPattern = not na(_sq9AnchorX) and (na(_sq9ActiveAnchorX) or _sq9AnchorX != _sq9ActiveAnchorX or _sq9AnchorP != _sq9ActiveAnchorP or _sq9Dir != _sq9ActiveDir)
        if _sq9NewPattern
            if _sq9AutoNew
                _sq9Invalidated := false
            _sq9ActiveAnchorX := _sq9AnchorX
            _sq9ActiveAnchorP := _sq9AnchorP
            _sq9ActiveDir     := _sq9Dir

        bool _sq9DownInvalid = _sq9Dir == DIR_DOWN and (_dir != DIR_DOWN or not _sq9RangeOK or na(hhX) or na(llX) or (not na(uYa) and close[_anchor] > uYa))
        bool _sq9UpInvalid   = _sq9Dir == DIR_UP   and (_dir != DIR_UP   or not _sq9RangeOK or na(hhX) or na(llX) or (not na(lYa) and close[_anchor] < lYa))
        bool _sq9PatternInvalid = _sq9Dir == DIR_FLAT or _sq9DownInvalid or _sq9UpInvalid

        if _sq9AutoInvalid and _sq9PatternInvalid and not _sq9NewPattern
            _sq9Invalidated := true

        bool _sq9CanDraw = i_showSq9 and _sq9Dir != DIR_FLAT and _sq9RangeOK and not na(_sq9AnchorX) and not na(_sq9StopX) and not (_sq9AutoInvalid and _sq9Invalidated)

        int   _seX  = ax
        bool  _pjOk = true
        if uY1 > lY1 and uYa <= lYa and _trSig > MIN_SIGMA
            float _gsL = math.log(uY1) / _trSig - math.log(lY1) / _trSig
            float _gsR = math.log(lYa) / _trSig - math.log(uYa) / _trSig
            float _gsD = _gsL + _gsR
            if _gsD > 1e-10
                _seX := sLx + int(math.round(_gsL / _gsD * (ax - sLx)))
            _pjOk := false

        float _uSE = f_icsLine(uY1, sLx, uY2, sRx, _seX, _trSig)
        float _lSE = f_icsLine(lY1, sLx, lY2, sRx, _seX, _trSig)

        if _seX > sLx
            _upLn := line.new(sLx, uY1, _seX, _uSE, color = chClr, width = i_chW, style = f_sty(i_chSty))
            _loLn := line.new(sLx, lY1, _seX, _lSE, color = chClr, width = i_chW, style = f_sty(i_chSty))

        int   eX  = ax + i_pjOff
        float uYe = f_icsLine(uY1, sLx, uY2, sRx, eX, _trSig)
        float lYe = f_icsLine(lY1, sLx, lY2, sRx, eX, _trSig)

        if _pjOk
            if uYa > lYa and uYe < lYe and _trSig > MIN_SIGMA
                float _cgA = math.log(uYa) / _trSig - math.log(lYa) / _trSig
                float _cgE = math.log(uYe) / _trSig - math.log(lYe) / _trSig
                float _cgD = _cgA - _cgE
                if _cgD > 1e-10
                    eX  := ax + int(math.round(_cgA / _cgD * i_pjOff))
                    uYe := f_icsLine(uY1, sLx, uY2, sRx, eX, _trSig)
                    lYe := f_icsLine(lY1, sLx, lY2, sRx, eX, _trSig)

            _upPj := line.new(ax, uYa, eX, uYe, color = chClr, width = i_pjW, style = f_sty(i_pjSty))
            _loPj := line.new(ax, lYa, eX, lYe, color = chClr, width = i_pjW, style = f_sty(i_pjSty))

        if i_showFill
            color fc = color.new(f_fClr(_dir), i_fillTr)
            if not na(_upLn) and not na(_loLn)
                _chFill := linefill.new(_upLn, _loLn, fc)
            if not na(_upPj) and not na(_loPj)
                _pjFill := linefill.new(_upPj, _loPj, fc)

        float extAt1 = f_icsPos(close[_anchor], lYa, uYa, _trSig)
        float extPctTip = math.round(extAt1 * 100)
        string extTipSign = extPctTip > 100 ? "+" : ""
        string tip = _L.lbl_close + "[" + str.tostring(_anchor) + "]: " +
             str.tostring(close[_anchor], format.mintick) +
             "\n" + _L.lbl_ceiling + " ▲: " + str.tostring(uYa, format.mintick) +
             "\n" + _L.lbl_floor   + " ▼: " + str.tostring(lYa, format.mintick) +
             "\n" + _L.lbl_ext     + ": "   + extTipSign + str.tostring(extPctTip, "#") + "%"

        _mkUp := label.new(ax, uYa, "◆",
             style = label.style_label_center,
             color = color.new(chart.bg_color, 100),
             textcolor = #5b9bd5,
             size = math.max(i_dashSz - 4, 6),
             tooltip = tip)
        _mkLo := label.new(ax, lYa, "◆",
             style = label.style_label_center,
             color = color.new(chart.bg_color, 100),
             textcolor = #5b9bd5,
             size = math.max(i_dashSz - 4, 6),
             tooltip = tip)

        string dTxt = f_dStr(_dir, _L)
        string aTxt = (_ang >= 0 ? "+" : "") + str.tostring(_ang, "#.#") + "°"

        if i_showAngLbl
            // Default behavior: label stays tied to the normal channel projection/midpoint.
            // It no longer jumps just because Show Angle Line is enabled.
            int _lblX = i_lblProjEnd ? eX : int((sLx + eX) / 2)

            // Default label Y = channel midline at the selected X.
            float _uLblY = f_icsLine(uY1, sLx, uY2, sRx, _lblX, _trSig)
            float _lLblY = f_icsLine(lY1, sLx, lY2, sRx, _lblX, _trSig)
            float _lblY  = (_uLblY > 0 and _lLblY > 0) ? math.sqrt(_uLblY * _lLblY) : (_uLblY + _lLblY) / 2.0

            // Optional behavior: move the label to the projected angle-line endpoint.
            if i_showAng and i_angLblEnd and _bGm.size() > _seg and _seg >= 1
                _lblX := math.min((bar_index - _anchor) + i_angExtend, bar_index + 490)
                _lblY := f_icsLine(_bGm.get(_seg), _bCx.get(_seg),
                    _bGm.get(0), _bCx.get(0), _lblX, _trSig)

            _lbl := label.new(_lblX, _lblY, dTxt + " " + aTxt,
                style = (i_showAng and i_angLblEnd) or i_lblProjEnd ? label.style_label_left : label.style_label_down,
                textcolor = i_showAng ? i_angClr : chClr,
                color = color.new(chart.bg_color, 60),
                size = math.max(i_dashSz - 2, 6),
                tooltip = _L.lbl_trend_tip + ": " + dTxt +
                    "\n" + _L.lbl_angle  + ": " + aTxt +
                    "\n" + _L.lbl_blocks + ": " + str.tostring(_seg + 1) +
                    "\nAngle Extend: " + str.tostring(i_angExtend) + " bars" +
                    "\nLabel follows angle end: " + (i_angLblEnd ? "ON" : "OFF"))


        // ══════════════════════════════════════════════════════════════════════════
        // DRAW — Structural SQ9 from SAME channel extremes   [ADDED / FIXED]
        // Downtrend: HH anchor → downward Square-of-9 levels until LL.
        // Uptrend:   LL anchor → upward Square-of-9 levels until HH.
        // Forward end = current bar + Extend N Bars.
        // ══════════════════════════════════════════════════════════════════════════
        if _sq9CanDraw
            float _sqAnchor = _sq9AnchorP
            int   _sqX1     = _sq9AnchorX
            float _sqStop   = _sq9StopP
            int   _sqX2     = math.min(ax + i_sq9Extend, bar_index + 490)
            float _root     = math.sqrt(math.max(_sqAnchor, 0.0))
            float _sqSign   = _sq9Dir == DIR_UP ? 1.0 : -1.0
            color _sqCol    = color.new(i_sq9Clr, i_sq9Tr)
            float _sqLastFullDeg = na

            // Fixed 8-slot degree gate.
            // Secondary Degrees = 90/180/270/360.
            // 45/135/225/315 are available only through All 45° Degrees or By-Degrees List.
            string _degList = "," + str.replace_all(i_sq9DegList, " ", "") + ","
            bool _secondary = i_sq9Mode == "Secondary Degrees"
            bool _allDegs   = i_sq9Mode == "All 45° Degrees"
            bool _byDegs    = i_sq9Mode == "By Degrees"

            // Auto-density:
            // ATR is the correct trigger.
            // Higher timeframe / high-ATR charts can clean up to 180° spacing when
            // 90° levels are too tight relative to ATR.
            // Normal charts use 90°. If 90° spacing is too wide, add 45°.
            // If 45° spacing is still too wide, add 22.5°.
            float _sqAutoAtr    = math.max(nz(_sq9DensityAtr, syminfo.mintick), syminfo.mintick)
            float _sqAuto45A    = math.pow(_root + _sqSign * (45.0  / 180.0), 2)
            float _sqAuto90A    = math.pow(_root + _sqSign * (90.0  / 180.0), 2)
            float _sqAuto135A   = math.pow(_root + _sqSign * (135.0 / 180.0), 2)
            float _sqAutoGap45  = math.abs(_sqAuto90A - _sqAuto45A)
            float _sqAutoGap90  = math.abs(_sqAuto135A - _sqAuto45A)

            bool  _autoDensityOn = i_sq9AutoDensity and _secondary and not _byDegs
            bool  _autoUse180    = _autoDensityOn and i_sq9Auto180Density and _sqAutoGap90 < _sqAutoAtr * i_sq9Auto180AtrMult
            bool  _autoUse45     = _autoDensityOn and not _autoUse180 and _sqAutoGap90 > _sqAutoAtr * i_sq9AutoAtrMult
            bool  _autoUse22     = _autoDensityOn and not _autoUse180 and i_sq9Auto22Density and _sqAutoGap45 > _sqAutoAtr * i_sq9Auto22AtrMult
            _autoUse45           := _autoUse45 or _autoUse22
            bool  _fine22        = _autoUse22

            bool _use22     = _fine22 or (_byDegs and (str.contains(_degList, ",22.5,")   or str.contains(_degList, ",22,")   or str.contains(_degList, ",22.50,")))
            bool _use45     = _allDegs or _autoUse45 or (_byDegs and (str.contains(_degList, ",45,")    or str.contains(_degList, ",45.0,")))
            bool _use67     = _fine22 or (_byDegs and (str.contains(_degList, ",67.5,")   or str.contains(_degList, ",67,")   or str.contains(_degList, ",67.50,")))
            bool _use90     = (_secondary and not _autoUse180) or _allDegs or (_byDegs and (str.contains(_degList, ",90,")    or str.contains(_degList, ",90.0,")))
            bool _use112    = _fine22 or (_byDegs and (str.contains(_degList, ",112.5,")  or str.contains(_degList, ",112,")  or str.contains(_degList, ",112.50,")))
            bool _use135    = _allDegs or _autoUse45 or (_byDegs and (str.contains(_degList, ",135,")   or str.contains(_degList, ",135.0,")))
            bool _use157    = _fine22 or (_byDegs and (str.contains(_degList, ",157.5,")  or str.contains(_degList, ",157,")  or str.contains(_degList, ",157.50,")))
            bool _use180    = _secondary or _allDegs or (_byDegs and (str.contains(_degList, ",180,")   or str.contains(_degList, ",180.0,")))
            bool _use202    = _fine22 or (_byDegs and (str.contains(_degList, ",202.5,")  or str.contains(_degList, ",202,")  or str.contains(_degList, ",202.50,")))
            bool _use225    = _allDegs or _autoUse45 or (_byDegs and (str.contains(_degList, ",225,")   or str.contains(_degList, ",225.0,")))
            bool _use247    = _fine22 or (_byDegs and (str.contains(_degList, ",247.5,")  or str.contains(_degList, ",247,")  or str.contains(_degList, ",247.50,")))
            bool _use270    = (_secondary and not _autoUse180) or _allDegs or (_byDegs and (str.contains(_degList, ",270,")   or str.contains(_degList, ",270.0,")))
            bool _use292    = _fine22 or (_byDegs and (str.contains(_degList, ",292.5,")  or str.contains(_degList, ",292,")  or str.contains(_degList, ",292.50,")))
            bool _use315    = _allDegs or _autoUse45 or (_byDegs and (str.contains(_degList, ",315,")   or str.contains(_degList, ",315.0,")))
            bool _use337    = _fine22 or (_byDegs and (str.contains(_degList, ",337.5,")  or str.contains(_degList, ",337,")  or str.contains(_degList, ",337.50,")))
            bool _use360    = _secondary or _allDegs or (_byDegs and (str.contains(_degList, ",360,")   or str.contains(_degList, ",360.0,")))

            for _rot = 0 to i_sq9RotMax - 1
                _sqLastFullDeg := f_drawSq9Lvl(_use22, 22.5, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
                _sqLastFullDeg := f_drawSq9Lvl(_use45, 45.0, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
                _sqLastFullDeg := f_drawSq9Lvl(_use67, 67.5, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
                _sqLastFullDeg := f_drawSq9Lvl(_use90, 90.0, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
                _sqLastFullDeg := f_drawSq9Lvl(_use112, 112.5, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
                _sqLastFullDeg := f_drawSq9Lvl(_use135, 135.0, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
                _sqLastFullDeg := f_drawSq9Lvl(_use157, 157.5, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
                _sqLastFullDeg := f_drawSq9Lvl(_use180, 180.0, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
                _sqLastFullDeg := f_drawSq9Lvl(_use202, 202.5, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
                _sqLastFullDeg := f_drawSq9Lvl(_use225, 225.0, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
                _sqLastFullDeg := f_drawSq9Lvl(_use247, 247.5, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
                _sqLastFullDeg := f_drawSq9Lvl(_use270, 270.0, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
                _sqLastFullDeg := f_drawSq9Lvl(_use292, 292.5, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
                _sqLastFullDeg := f_drawSq9Lvl(_use315, 315.0, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
                _sqLastFullDeg := f_drawSq9Lvl(_use337, 337.5, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
                _sqLastFullDeg := f_drawSq9Lvl(_use360, 360.0, _rot, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqX1, _sqX2, _sqCol, i_sq9ShowLbl, _sqLastFullDeg, _sq9Lines, _sq9Labels)
            // Continuation levels:
            // TRUE continuation from the same SQ9 sequence, selected by the LIVE market edge.
            // Down: next N enabled SQ9 degrees below Low - ATR×Buffer.
            // Up:   next N enabled SQ9 degrees above High + ATR×Buffer.
            // Auto 22.5° density is included here when enabled, so continuation does not skip the tighter rungs.
            if i_sq9ShowExtra and i_sq9ExtraLevels > 0
                int   _sqExtraDrawn = 0
                int   _sqExtraX1    = ax
                int   _sqExtraX2    = math.min(ax + i_sq9Extend, bar_index + 490)
                float _sqAtrNow     = nz(_sq9Atr, 0.0)
                float _sqExtraRef   = _sq9Dir == DIR_DOWN ? low[_anchor] - _sqAtrNow * i_sq9ExtraAtrMult : high[_anchor] + _sqAtrNow * i_sq9ExtraAtrMult
                color _sqExtraCol   = color.new(i_sq9ExtraClr, i_sq9ExtraTr)

                for _rotEx = 0 to i_sq9ExtraScanRot - 1
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break

                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use22, 22.5, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break
                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use45, 45.0, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break
                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use67, 67.5, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break
                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use90, 90.0, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break
                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use112, 112.5, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break
                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use135, 135.0, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break
                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use157, 157.5, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break
                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use180, 180.0, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break
                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use202, 202.5, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break
                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use225, 225.0, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break
                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use247, 247.5, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break
                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use270, 270.0, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break
                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use292, 292.5, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break
                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use315, 315.0, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break
                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use337, 337.5, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break
                    _sqExtraDrawn := f_drawSq9ExtraLvl(_use360, 360.0, _rotEx, _root, _sqSign, _sq9Dir, _sqAnchor, _sqStop, _sqAtrNow, _sqExtraRef, _sqExtraX1, _sqExtraX2, _sqExtraCol, i_sq9ExtraShowLbl, _sqLastFullDeg, _sqExtraDrawn, i_sq9ExtraLevels, _sq9Lines, _sq9Labels)
                    if _sqExtraDrawn >= i_sq9ExtraLevels
                        break

        // ══════════════════════════════════════════════════════════════════════════
        // DRAW — Structural Anchored VWAP from ACTIVE LINE-START PIVOT   [FIXED]
        // Down-channel = anchor from actual swing high at upper/top line start.
        // Up-channel   = anchor from actual swing low  at lower/bottom line start.
        // Extension is draw-only; it is NOT included in the VWAP calculation.
        // ══════════════════════════════════════════════════════════════════════════
        bool _avWantDown = i_avwapDirection == "Down from High" or (i_avwapDirection == "Auto" and _dir == DIR_DOWN)
        bool _avWantUp   = i_avwapDirection == "Up from Low"   or (i_avwapDirection == "Auto" and _dir == DIR_UP)
        int  _avDir      = _avWantUp ? DIR_UP : (_avWantDown ? DIR_DOWN : DIR_FLAT)

        // Choose the same side that starts the actual channel:
        //   Down = upper rail starts from HH block.
        //   Up   = lower rail starts from LL block.
        int _avBlockCenterX = _avDir == DIR_DOWN ? hhX : _avDir == DIR_UP ? llX : na
        int _avHalf         = int(i_period / 2)
        int _avRightX       = not na(_avBlockCenterX) ? _avBlockCenterX + _avHalf : na
        int _avLeftX        = not na(_avRightX) ? _avRightX - i_period + 1 : na

        int   _avStart = na
        float _avAnchorPx = na

        // Find the REAL candle high/low inside the block that starts the line.
        // This fixes the prior top-down-only behavior and avoids anchoring from a block-center X.
        if i_showStructAVWAP and _avDir != DIR_FLAT and not na(_avLeftX) and not na(_avRightX)
            int _avScan = math.min(math.max(ax - _avLeftX, 0), 600)
            for _jAvA = 0 to 600
                if _jAvA <= _avScan
                    int   _offAvA = _anchor + _jAvA
                    int   _xAvA   = bar_index - _offAvA
                    float _hAvA   = high[_offAvA]
                    float _lAvA   = low[_offAvA]
                    if _xAvA >= _avLeftX and _xAvA <= _avRightX
                        if _avDir == DIR_DOWN
                            if na(_avAnchorPx) or _hAvA > _avAnchorPx
                                _avAnchorPx := _hAvA
                                _avStart    := _xAvA
                        else if _avDir == DIR_UP
                            if na(_avAnchorPx) or _lAvA < _avAnchorPx
                                _avAnchorPx := _lAvA
                                _avStart    := _xAvA

        bool _avRailInvalid =
             i_avwapRemoveMode == "Off" ? false :
             (i_avwapRemoveMode == "Channel Rail Invalid" or i_avwapRemoveMode == "Upper Rail Reclaim") ?
                 (_avDir == DIR_DOWN ? close[_anchor] > uYa : _avDir == DIR_UP ? close[_anchor] < lYa : true) :
             false

        bool _avwapAllowed = i_showStructAVWAP and _avDir != DIR_FLAT and not na(_avStart) and _avStart < ax and not _avRailInvalid

        if _avwapAllowed
            int _avEnd   = ax
            int _avTotal = math.max(_avEnd - _avStart + 1, 1)
            int _avDrawN = math.min(i_avwapMaxBars, _avTotal)
            int _drawStartX = _avEnd - _avDrawN + 1

            float _cumV  = 0.0
            float _cumPV = 0.0
            float _cumP2 = 0.0

            int   _pX    = na
            float _pVw   = na
            float _pU1   = na
            float _pL1   = na
            float _pU2   = na
            float _pL2   = na
            float _pU3   = na
            float _pL3   = na

            // Calculate only from real bars between anchor and current bar.
            // Forward extension is drawn later and never enters the VWAP math.
            for _j = 0 to _avTotal - 1
                int   _off = _avTotal - 1 - _j
                int   _x   = _avEnd - _off
                float _src = nz(_avwapSrc[_off])
                float _vol = math.max(nz(volume[_off]), 1.0)

                _cumV  += _vol
                _cumPV += _src * _vol
                _cumP2 += _src * _src * _vol

                float _vw = _cumV > 0.0 ? _cumPV / _cumV : na
                float _sd = _cumV > 0.0 ? math.sqrt(math.max(_cumP2 / _cumV - _vw * _vw, 0.0)) : 0.0
                float _u1 = _vw + _sd * i_avwapBand1
                float _l1 = _vw - _sd * i_avwapBand1
                float _u2 = _vw + _sd * i_avwapBand2
                float _l2 = _vw - _sd * i_avwapBand2
                float _u3 = _vw + _sd * i_avwapBand3
                float _l3 = _vw - _sd * i_avwapBand3

                if _x >= _drawStartX
                    if not na(_pX)
                        if i_avwapShowMid
                            array.push(_avwapLines, line.new(_pX, _pVw, _x, _vw, xloc = xloc.bar_index, color = color.new(i_avwapMidClr, i_avwapMidTr), width = 2))
                        array.push(_avwapLines, line.new(_pX, _pU1, _x, _u1, xloc = xloc.bar_index, color = color.new(i_avwapBand1Clr, i_avwapBand1Tr), width = 1))
                        array.push(_avwapLines, line.new(_pX, _pL1, _x, _l1, xloc = xloc.bar_index, color = color.new(i_avwapBand1Clr, i_avwapBand1Tr), width = 1))
                        array.push(_avwapLines, line.new(_pX, _pU2, _x, _u2, xloc = xloc.bar_index, color = color.new(i_avwapBand2Clr, i_avwapBand2Tr), width = 1))
                        array.push(_avwapLines, line.new(_pX, _pL2, _x, _l2, xloc = xloc.bar_index, color = color.new(i_avwapBand2Clr, i_avwapBand2Tr), width = 1))
                        array.push(_avwapLines, line.new(_pX, _pU3, _x, _u3, xloc = xloc.bar_index, color = color.new(i_avwapBand3Clr, i_avwapBand3Tr), width = 1))
                        array.push(_avwapLines, line.new(_pX, _pL3, _x, _l3, xloc = xloc.bar_index, color = color.new(i_avwapBand3Clr, i_avwapBand3Tr), width = 1))

                    _pX  := _x
                    _pVw := _vw
                    _pU1 := _u1
                    _pL1 := _l1
                    _pU2 := _u2
                    _pL2 := _l2
                    _pU3 := _u3
                    _pL3 := _l3

            bool _avwapInvalid =
                 (i_avwapRemoveMode == "VWAP Reclaim / Breakdown" or i_avwapRemoveMode == "VWAP Reclaim") and not na(_pVw) ?
                     (_avDir == DIR_DOWN ? close[_anchor] > _pVw : _avDir == DIR_UP ? close[_anchor] < _pVw : false) :
                 false

            if _avwapInvalid
                f_clearLines(_avwapLines)
            else if i_avwapExtend > 0 and not na(_pX)
                int _xExt = math.min(_pX + i_avwapExtend, bar_index + 490)
                if i_avwapShowMid
                    array.push(_avwapLines, line.new(_pX, _pVw, _xExt, _pVw, xloc = xloc.bar_index, color = color.new(i_avwapMidClr, i_avwapMidTr), width = 2, style = line.style_dotted))
                array.push(_avwapLines, line.new(_pX, _pU1, _xExt, _pU1, xloc = xloc.bar_index, color = color.new(i_avwapBand1Clr, i_avwapBand1Tr), width = 1, style = line.style_dotted))
                array.push(_avwapLines, line.new(_pX, _pL1, _xExt, _pL1, xloc = xloc.bar_index, color = color.new(i_avwapBand1Clr, i_avwapBand1Tr), width = 1, style = line.style_dotted))
                array.push(_avwapLines, line.new(_pX, _pU2, _xExt, _pU2, xloc = xloc.bar_index, color = color.new(i_avwapBand2Clr, i_avwapBand2Tr), width = 1, style = line.style_dotted))
                array.push(_avwapLines, line.new(_pX, _pL2, _xExt, _pL2, xloc = xloc.bar_index, color = color.new(i_avwapBand2Clr, i_avwapBand2Tr), width = 1, style = line.style_dotted))
                array.push(_avwapLines, line.new(_pX, _pU3, _xExt, _pU3, xloc = xloc.bar_index, color = color.new(i_avwapBand3Clr, i_avwapBand3Tr), width = 1, style = line.style_dotted))
                array.push(_avwapLines, line.new(_pX, _pL3, _xExt, _pL3, xloc = xloc.bar_index, color = color.new(i_avwapBand3Clr, i_avwapBand3Tr), width = 1, style = line.style_dotted))

    if i_showAng and _ok and _seg >= 1 and _bGm.size() > _seg
        float _aGmOld = _bGm.get(_seg)
        float _aGmNew = _bGm.get(0)
        int   _aCxOld = _bCx.get(_seg)
        int   _aCxNew = _bCx.get(0)
        _angLn := line.new(_aCxOld, _aGmOld, _aCxNew, _aGmNew,
             color = i_angClr, width = 2, style = line.style_solid)
        int   _aPjX = math.min((bar_index - _anchor) + i_angExtend, bar_index + 490)
        float _aPjY = f_icsLine(_aGmOld, _aCxOld, _aGmNew, _aCxNew, _aPjX, _trSig)
        if i_angExtend > 0
            _angPj := line.new(_aCxNew, _aGmNew, _aPjX, _aPjY,
                 color = i_angClr, width = 2, style = line.style_dotted)

    if not na(_dash)
        table.delete(_dash)
        _dash := na

    if i_showDash
        int sz   = math.max(i_dashSz, 6)
        int szSm = math.max(sz - 2, 6)
        int szXs = math.max(sz - 4, 6)

        color bg   = color.new(chart.bg_color, 20)
        color bgHd = color.new(chart.bg_color, 10)
        color bdr  = color.new(chart.fg_color, 85)
        color fg   = chart.fg_color
        color fg2  = color.new(chart.fg_color, 40)

        string tfS = timeframe.isseconds ? "s" : timeframe.isminutes ? "m" : ""

        string _dPos = switch i_dashPos
            "Top Left"      => position.top_left
            "Top Center"    => position.top_center
            "Middle Left"   => position.middle_left
            "Middle Center" => position.middle_center
            "Middle Right"  => position.middle_right
            "Bottom Left"   => position.bottom_left
            "Bottom Center" => position.bottom_center
            "Bottom Right"  => position.bottom_right
            =>                 position.top_right
        _dash := table.new(_dPos, 7, 5,
             bgcolor = bg, border_color = bdr, border_width = 1,
             frame_color = bdr, frame_width = 1)

        table.cell(_dash, 0, 0,
             "🦅✦ · #" + syminfo.ticker + " · " +
             timeframe.period + tfS + "     " +
             str.tostring(close, format.mintick) + " " + syminfo.currency,
             text_color = fg, text_size = szSm,
             bgcolor = bgHd, text_halign = text.align_left,
             tooltip = _L.tip_header)
        for c = 1 to 6
            table.cell(_dash, c, 0, "", bgcolor = bgHd)
        table.merge_cells(_dash, 0, 0, 6, 0)

        table.cell(_dash, 0, 1, _L.lbl_period,
             text_color = fg2, text_size = szXs,
             bgcolor = bg, text_halign = text.align_left,
             tooltip = _L.tip_period)
        for c = 0 to 5
            table.cell(_dash, c + 1, 1, str.tostring(SCALES.get(c)),
                 text_color = #5b9bd5, text_size = szXs,
                 bgcolor = bg, text_halign = text.align_center)

        table.cell(_dash, 0, 2, _L.lbl_trend,
             text_color = fg2, text_size = szXs,
             bgcolor = bg, text_halign = text.align_left,
             tooltip = _L.tip_trend)
        for c = 0 to 5
            TrendResult tr = _trends.get(c)
            table.cell(_dash, c + 1, 2, f_dStr(tr.dir, _L),
                 text_color = f_dClr(tr.dir), text_size = szXs,
                 bgcolor = bg, text_halign = text.align_center)

        string chUpStr = not na(_chUp) ? str.tostring(_chUp, format.mintick) : "—"
        string chLoStr = not na(_chLo) ? str.tostring(_chLo, format.mintick) : "—"
        int    agCnt   = _cUp > _cDn ? _cUp : _cDn > _cUp ? _cDn : _cFlat
        string agDir   = _cUp > _cDn ? _L.dir_up : _cDn > _cUp ? _L.dir_dn : _L.dir_rng
        table.cell(_dash, 0, 3,
             _L.lbl_agreement + ": " + str.tostring(agCnt) + "/6 " + agDir +
             "  ▲ " + chUpStr + "  ▼ " + chLoStr,
             text_color = fg2, text_size = szXs,
             bgcolor = bg, text_halign = text.align_left,
             tooltip = _L.tip_agreement)
        for c = 1 to 6
            table.cell(_dash, c, 3, "", bgcolor = bg)
        table.merge_cells(_dash, 0, 3, 6, 3)

        string stLine1 = ""
        string stLine2 = ""
        color  stClr   = color.new(#888888, 0)

        float _flPct = math.round(math.max(0.0, math.min(_extPos, 1.0)) * 100)
        float _clPct = 100.0 - _flPct
        float _abPct = math.round((_extPos - 1.0) * 100)
        float _blPct = math.round(math.abs(math.min(_extPos, 0.0)) * 100)

        switch _boState
            ST_BO_UP =>
                stClr := i_clrUp
                stLine1 := _L.st_bo_up +
                     (_boConfirm ? " ✓" : "") +
                     (_boGapped ? " " + _L.conn_gap : "") +
                     " " + _L.conn_at + " " + str.tostring(nz(_boPrice), format.mintick)
                if _boConfirm and not na(_rtPrice)
                    stLine1 := stLine1 + " " + _L.conn_retested + " " +
                         str.tostring(nz(_rtPrice), format.mintick)
                stLine2 := str.tostring(_abPct, "#") + _L.dist_above_ceiling

            ST_RT_UP =>
                stClr := color.new(#EF9F27, 0)
                stLine1 := _L.st_rt_up_broke_at + " " +
                     str.tostring(nz(_boPrice), format.mintick)
                stLine2 := _L.conn_now + " " + str.tostring(nz(close[_anchor]), format.mintick) +
                     " · " + str.tostring(_abPct, "#") + _L.dist_above_ceiling

            ST_BO_DN =>
                stClr := i_clrDn
                stLine1 := _L.st_bo_dn +
                     (_boConfirm ? " ✓" : "") +
                     (_boGapped ? " " + _L.conn_gap : "") +
                     " " + _L.conn_at + " " + str.tostring(nz(_boPrice), format.mintick)
                if _boConfirm and not na(_rtPrice)
                    stLine1 := stLine1 + " " + _L.conn_retested + " " +
                         str.tostring(nz(_rtPrice), format.mintick)
                stLine2 := str.tostring(_blPct, "#") + _L.dist_below_floor

            ST_RT_DN =>
                stClr := color.new(#EF9F27, 0)
                stLine1 := _L.st_rt_dn_broke_at + " " +
                     str.tostring(nz(_boPrice), format.mintick)
                stLine2 := _L.conn_now + " " + str.tostring(nz(close[_anchor]), format.mintick) +
                     " · " + str.tostring(_blPct, "#") + _L.dist_below_floor

            =>
                stClr := _retFrom != 0 or _dirReset ?
                     color.new(#5b9bd5, 0) : color.new(#888888, 0)
                stLine1 := _dirReset ? _L.st_inside_dir_ch :
                     _retFrom == 1 ? _L.st_inside_fail_up :
                     _retFrom == -1 ? _L.st_inside_fail_dn :
                     _L.st_inside
                stLine2 := str.tostring(_flPct, "#") + _L.dist_from_floor + " · " +
                     str.tostring(_clPct, "#") + _L.dist_to_ceiling

        table.cell(_dash, 0, 4, stLine1 + " · " + stLine2,
             text_color = stClr, text_size = szXs,
             bgcolor = bg, text_halign = text.align_left,
             tooltip = _L.tip_narrative)
        for c = 1 to 6
            table.cell(_dash, c, 4, "", bgcolor = bg)
        table.merge_cells(_dash, 0, 4, 6, 4)

// ══════════════════════════════════════════════════════════════════════════════════
// ICS ENRICHMENT — Conviction · Cascade · Compression   [ADDED — σ-native, negligible CPU]
// ══════════════════════════════════════════════════════════════════════════════════

int   _alignCnt  = _dir == DIR_UP ? _cUp : _dir == DIR_DOWN ? _cDn : _cFlat
float _consScore = _alignCnt / 6.0
float _angScore  = math.min(math.abs(_ang) / math.max(i_angRef, 1.0), 1.0)
float _segScore  = i_groups > 1 ? math.min(_seg / (i_groups - 1.0), 1.0) : 0.0

float _aSum   = 0.0
float _aSumSq = 0.0
for i = 0 to 5
    float ai = _trends.get(i).angle
    _aSum   += ai
    _aSumSq += ai * ai
float _aMean    = _aSum / 6.0
float _aStd     = math.sqrt(math.max(_aSumSq / 6.0 - _aMean * _aMean, 0.0))
float _cohScore = 1.0 - math.min(_aStd / math.max(i_angRef, 1.0), 1.0)

float _wSum = i_wAng + i_wCon + i_wSeg + i_wCoh
float _convRaw = (_ok and _wSum > 0.0)
     ? (i_wAng * _angScore + i_wCon * _consScore + i_wSeg * _segScore + i_wCoh * _cohScore) / _wSum * 10.0
     : 0.0
int   _convKind = _dir == DIR_UP ? 1 : _dir == DIR_DOWN ? 2 : 0
float _rankMult = (i_enableRanker and _convKind != 0) ? f_rankMult(_convKind, _alignCnt) : 1.0
float _conv     = math.min(10.0, _convRaw * _regimeMult * _rankMult)

float  _angMom    = _ang - nz(_ang[i_angMomLen], _ang)
string _angMomTxt = _angMom > 0.5 ? "steepening" : _angMom < -0.5 ? "flattening" : "stable"

int _fastNet = 0
for i = 0 to 2
    _fastNet += _trends.get(i).dir
int _slowNet = 0
for i = 3 to 5
    _slowNet += _trends.get(i).dir
int  _fSign          = _fastNet > 0 ? 1 : _fastNet < 0 ? -1 : 0
int  _sSign          = _slowNet > 0 ? 1 : _slowNet < 0 ? -1 : 0
bool _cascadeDiverge = _fSign != 0 and _sSign != 0 and _fSign != _sSign

float _widthSig = (not na(_chUp) and not na(_chLo) and _chUp > 0.0 and _chLo > 0.0 and _trSig > MIN_SIGMA)
     ? (math.log(_chUp) - math.log(_chLo)) / _trSig : na
float _widthAvg  = ta.sma(_widthSig, i_compLen)
float _compRatio = (not na(_widthSig) and not na(_widthAvg) and _widthAvg > 0.0) ? _widthSig / _widthAvg : na
bool  _compressed = not na(_compRatio) and _compRatio < 0.8
bool  _expanded   = not na(_compRatio) and _compRatio > 1.2

bgcolor(i_enableEnr and i_compTint and _compressed ? color.new(i_compClr, 90) : na, title = "Compression Tint")

plot(_conv,      "Conviction",  display = display.none)
plot(_fastNet,   "CascadeFast", display = display.none)
plot(_slowNet,   "CascadeSlow", display = display.none)
plot(_compRatio, "CompRatio",   display = display.none)


// ══════════════════════════════════════════════════════════════════════════════════
// ZENITH ICON OUTPUT — 5 and 6   [ADDED]
// Icon only, no background.
// ══════════════════════════════════════════════════════════════════════════════════

bool _cwBullRaw = _cascadeDiverge and _fSign == 1 and _sSign == -1
bool _cwBearRaw = _cascadeDiverge and _fSign == -1 and _sSign == 1
bool _crUpRaw   = _compressed[1] and _expanded and _dir == DIR_UP and _fSign == 1
bool _crDnRaw   = _compressed[1] and _expanded and _dir == DIR_DOWN and _fSign == -1

bool _cwAnyRaw   = _cwBullRaw or _cwBearRaw
bool _crAnyRaw   = _crUpRaw or _crDnRaw
bool _cwFreshRaw = _cwAnyRaw and not ((_cwBullRaw[1] == true) or (_cwBearRaw[1] == true))
bool _crFreshRaw = _crAnyRaw and not ((_crUpRaw[1] == true) or (_crDnRaw[1] == true))

var int _lastCwIconBar = na
var int _lastCrIconBar = na

bool _cwCooldownOk = i_zenCooldown == 0 or na(_lastCwIconBar) or bar_index - _lastCwIconBar >= i_zenCooldown
bool _crCooldownOk = i_zenCooldown == 0 or na(_lastCrIconBar) or bar_index - _lastCrIconBar >= i_zenCooldown

bool _cwPrint = (i_zenFreshOnly ? _cwFreshRaw : _cwAnyRaw) and _cwCooldownOk
bool _crPrint = (i_zenFreshOnly ? _crFreshRaw : _crAnyRaw) and _crCooldownOk

if _cwPrint
    _lastCwIconBar := bar_index
if _crPrint
    _lastCrIconBar := bar_index

bool _cwBull = _cwPrint and _cwBullRaw
bool _cwBear = _cwPrint and _cwBearRaw
bool _crUp   = _crPrint and _crUpRaw
bool _crDn   = _crPrint and _crDnRaw

string _cwTip = "5 · Cascade Reversal Warning" +
     "\nFast scale net: " + str.tostring(_fastNet) +
     "\nSlow scale net: " + str.tostring(_slowNet) +
     "\nMeaning: fast structure is diverging against the slower structure."
string _crTip = "6 · Compression Release" +
     "\nCompression ratio: " + str.tostring(_compRatio * 100.0, "#") + "%" +
     "\nMeaning: prior compression released into expansion with directional agreement."

if i_showCascadeWarn and _cwBull
    label _cwBullLb = label.new(
         bar_index, low, i_cwIcon,
         xloc      = xloc.bar_index,
         yloc      = yloc.belowbar,
         style     = label.style_none,
         textcolor = color.new(color.lime, i_cwTr),
         size      = size.tiny,
         tooltip   = _cwTip + "\nSignal: bullish reversal pressure")
    f_pushLimitedLabel(_zenLabels, _cwBullLb, i_zenMaxLabels)

if i_showCascadeWarn and _cwBear
    label _cwBearLb = label.new(
         bar_index, high, i_cwIcon,
         xloc      = xloc.bar_index,
         yloc      = yloc.abovebar,
         style     = label.style_none,
         textcolor = color.new(color.red, i_cwTr),
         size      = size.tiny,
         tooltip   = _cwTip + "\nSignal: bearish reversal pressure")
    f_pushLimitedLabel(_zenLabels, _cwBearLb, i_zenMaxLabels)

if i_showCompRelease and _crUp
    label _crUpLb = label.new(
         bar_index, low, i_crIcon,
         xloc      = xloc.bar_index,
         yloc      = yloc.belowbar,
         style     = label.style_none,
         textcolor = color.new(color.aqua, i_crTr),
         size      = size.tiny,
         tooltip   = _crTip + "\nSignal: release up")
    f_pushLimitedLabel(_zenLabels, _crUpLb, i_zenMaxLabels)

if i_showCompRelease and _crDn
    label _crDnLb = label.new(
         bar_index, high, i_crIcon,
         xloc      = xloc.bar_index,
         yloc      = yloc.abovebar,
         style     = label.style_none,
         textcolor = color.new(color.orange, i_crTr),
         size      = size.tiny,
         tooltip   = _crTip + "\nSignal: release down")
    f_pushLimitedLabel(_zenLabels, _crDnLb, i_zenMaxLabels)

// ══════════════════════════════════════════════════════════════════════════════════
// VOLUME FOOTPRINT — POC · VA · Independent POC Engines   [ADDED — gated OFF]
// Correct protocol:
//   • request.footprint() is called ONCE.
//   • Sloped / Horizontal / Opposite POCs each get their OWN POC calculation window.
//   • Last N Bars controls that layer's real-bar auction calculation window.
//   • Extend N Bars is drawing/projection only and NEVER enters the POC calculation.
// ══════════════════════════════════════════════════════════════════════════════════

footprint _fpRaw = na
if i_enableFoot
    _fpRaw := request.footprint(i_footTicks, i_footVA)

bool  _fpOK    = i_enableFoot and not na(_fpRaw)
float _fpPoc   = na
float _fpVol   = na
float _fpDelta = na
float _fpDpct  = na

if _fpOK
    volume_row _pr = _fpRaw.poc()
    if not na(_pr)
        _fpPoc := (_pr.up_price() + _pr.down_price()) / 2.0
    _fpVol   := _fpRaw.total_volume()
    _fpDelta := _fpRaw.delta()
    _fpDpct  := (not na(_fpVol) and _fpVol > 0.0) ? _fpDelta / _fpVol * 100.0 : na

int _fpMax = 700
var array<int>   _fpBarA = array.new<int>()
var array<float> _fpPocA = array.new<float>()
var array<float> _fpVolA = array.new<float>()

if _fpOK and not na(_fpPoc) and not na(_fpVol) and _fpVol > 0.0
    array.push(_fpBarA, bar_index)
    array.push(_fpPocA, _fpPoc)
    array.push(_fpVolA, _fpVol)
    if array.size(_fpBarA) > _fpMax
        array.shift(_fpBarA)
        array.shift(_fpPocA)
        array.shift(_fpVolA)

// POC migration: rising / falling footprint-POC staircase over i_footMig bars.
bool   _fpPocUp  = not na(_fpPoc) and not na(_fpPoc[i_footMig]) and _fpPoc > _fpPoc[i_footMig]
bool   _fpPocDn  = not na(_fpPoc) and not na(_fpPoc[i_footMig]) and _fpPoc < _fpPoc[i_footMig]
string _fpPocTxt = _fpPocUp ? "POC↑" : _fpPocDn ? "POC↓" : "POC→"

// Persisted current-bar structure prices (read by the Enrichment panel)
var float _spPoc = na
var float _spVaH = na
var float _spVaL = na

// Independent POC / VA calculator.
// It bins REAL footprint POC prices from a specific layer window.
// No projected/extended bars are ever included.
f_calcPocWindow(array<int> _bars, array<float> _pocs, array<float> _vols,
     int _winStart, int _winEnd, int _binsN, int _vaPct) =>
    bool  _okW   = false
    float _pocW  = na
    float _vahW  = na
    float _valW  = na
    float _totW  = 0.0
    int   _cntW  = 0
    float _pMinW = na
    float _pMaxW = na
    int   _nW    = array.size(_bars)

    if _nW > 0
        for _i = 0 to _nW - 1
            int _b = array.get(_bars, _i)
            if _b >= _winStart and _b <= _winEnd
                float _px = array.get(_pocs, _i)
                if not na(_px) and _px > 0.0
                    _pMinW := na(_pMinW) ? _px : math.min(_pMinW, _px)
                    _pMaxW := na(_pMaxW) ? _px : math.max(_pMaxW, _px)
                    _cntW  += 1

    if _cntW > 0 and not na(_pMinW) and not na(_pMaxW)
        if _pMaxW <= _pMinW
            _pMinW -= syminfo.mintick
            _pMaxW += syminfo.mintick

        int _B = math.max(5, _binsN)
        float _spanW = math.max(_pMaxW - _pMinW, syminfo.mintick)
        array<float> _binsW = array.new<float>(_B, 0.0)

        for _i = 0 to _nW - 1
            int _b = array.get(_bars, _i)
            if _b >= _winStart and _b <= _winEnd
                float _px = array.get(_pocs, _i)
                float _vv = array.get(_vols, _i)
                if not na(_px) and _px > 0.0 and not na(_vv) and _vv > 0.0
                    int _bi = math.min(_B - 1, math.max(0, int((_px - _pMinW) / _spanW * (_B - 1))))
                    array.set(_binsW, _bi, array.get(_binsW, _bi) + _vv)
                    _totW += _vv

        if _totW > 0.0
            int   _maxBiW = 0
            float _maxVW  = 0.0
            for _bi = 0 to _B - 1
                float _v = array.get(_binsW, _bi)
                if _v > _maxVW
                    _maxVW  := _v
                    _maxBiW := _bi

            float _vaTargetW = _totW * _vaPct / 100.0
            float _accW      = array.get(_binsW, _maxBiW)
            int   _loBiW     = _maxBiW
            int   _hiBiW     = _maxBiW

            for _step = 0 to _B
                if _accW >= _vaTargetW
                    break
                float _belowV = _loBiW > 0 ? array.get(_binsW, _loBiW - 1) : -1.0
                float _aboveV = _hiBiW < _B - 1 ? array.get(_binsW, _hiBiW + 1) : -1.0
                if _belowV < 0.0 and _aboveV < 0.0
                    break
                if _aboveV >= _belowV
                    _hiBiW += 1
                    _accW  += _aboveV
                else
                    _loBiW -= 1
                    _accW  += _belowV

            _pocW := _pMinW + (_maxBiW + 0.5) / _B * _spanW
            _vahW := _pMinW + (_hiBiW + 1.0) / _B * _spanW
            _valW := _pMinW + (_loBiW + 0.0) / _B * _spanW
            _okW  := true

    [_okW, _pocW, _vahW, _valW, _totW, _cntW]

// Project a fixed price along the active ICS slope.
// _mult =  1.0  -> same slope as structure
// _mult = -1.0  -> opposite slope through the same POC
f_projPocIcs(float _price, float _axisSlp, int _x0, int _x, float _sig, float _mult) =>
    float _out = na
    if not na(_price) and _price > 0.0 and _sig > MIN_SIGMA
        float _y = math.log(_price) / _sig
        _out := math.exp((_y + _mult * _axisSlp * (_x - _x0)) * _sig)
    _out

f_pocTip(string _name, float _poc, float _vah, float _val, int _winStart, int _winEnd,
     int _lastN, int _cnt, float _totV, int _drawStart, int _x2) =>
    _name +
     "\nPOC: " + str.tostring(_poc, format.mintick) +
     "\nVAH: " + str.tostring(_vah, format.mintick) +
     "\nVAL: " + str.tostring(_val, format.mintick) +
     "\nCalculation window: " + str.tostring(_winStart) + " → " + str.tostring(_winEnd) +
     "\nLast N used: " + str.tostring(_lastN) +
     "\nFootprint bars in window: " + str.tostring(_cnt) +
     "\nTotal footprint volume: " + str.tostring(_totV, "#") +
     "\nRender: " + str.tostring(_drawStart) + " → " + str.tostring(_x2) +
     "\nExtend N is projection only; it is not included in calculation."

// Structure POC drawing state
var line     _lnPoc  = na
var line     _lnPocH = na
var line     _lnPocO = na
var line     _lnVaH  = na
var line     _lnVaL  = na
var linefill _llVa   = na
var label    _lbPoc  = na
var label    _lbPocH = na
var label    _lbPocO = na

if barstate.islast
    line.delete(_lnPoc)
    line.delete(_lnPocH)
    line.delete(_lnPocO)
    line.delete(_lnVaH)
    line.delete(_lnVaL)
    linefill.delete(_llVa)
    label.delete(_lbPoc)
    label.delete(_lbPocH)
    label.delete(_lbPocO)

    _lnPoc  := na
    _lnPocH := na
    _lnPocO := na
    _lnVaH  := na
    _lnVaL  := na
    _llVa   := na
    _lbPoc  := na
    _lbPocH := na
    _lbPocO := na
    _spPoc  := na
    _spVaH  := na
    _spVaL  := na

    // Reference axis = the engine's own ICS trend line GM[seg] → GM[0].
    bool _axisOK = _ok and _seg >= 1 and _bGm.size() > _seg and not na(_bGm.get(_seg)) and not na(_bGm.get(0))
    bool _needPOC = i_footShowSlope or i_footShowVA or i_footShowHoriz or i_footShowOpp or i_footShowLbl

    if i_enableFoot and _needPOC and _axisOK and array.size(_fpBarA) > 0
        int   _ax   = bar_index - _anchor
        float _gOld = _bGm.get(_seg)
        int   _xOld = _bCx.get(_seg)
        float _gNew = _bGm.get(0)
        int   _xNew = _bCx.get(0)

        float _axisSlp = 0.0
        if _gOld > 0 and _gNew > 0 and _xNew != _xOld and _trSig > MIN_SIGMA
            float _axisYOld = math.log(_gOld) / _trSig
            float _axisYNew = math.log(_gNew) / _trSig
            _axisSlp := (_axisYNew - _axisYOld) / (_xNew - _xOld)

        // Each POC layer has its own independent calculation window.
        int _lastS = math.max(1, math.min(i_footStructLen, i_footLastN      <= 0 ? 1 : i_footLastN))
        int _lastH = math.max(1, math.min(i_footStructLen, i_footHorizLastN <= 0 ? 1 : i_footHorizLastN))
        int _lastO = math.max(1, math.min(i_footStructLen, i_footOppLastN   <= 0 ? 1 : i_footOppLastN))

        int _winStartS = math.max(_xOld, _ax - _lastS + 1)
        int _winStartH = math.max(_xOld, _ax - _lastH + 1)
        int _winStartO = math.max(_xOld, _ax - _lastO + 1)

        [_okS, _pocS, _vahS, _valS, _volS, _cntS] = f_calcPocWindow(_fpBarA, _fpPocA, _fpVolA, _winStartS, _ax, i_footBins, i_footVA)
        [_okH, _pocH, _vahH, _valH, _volH, _cntH] = f_calcPocWindow(_fpBarA, _fpPocA, _fpVolA, _winStartH, _ax, i_footBins, i_footVA)
        [_okO, _pocO, _vahO, _valO, _volO, _cntO] = f_calcPocWindow(_fpBarA, _fpPocA, _fpVolA, _winStartO, _ax, i_footBins, i_footVA)

        // Dashboard priority: sloped/VA POC first, then horizontal, then opposite.
        _spPoc := _okS ? _pocS : _okH ? _pocH : _okO ? _pocO : na
        _spVaH := _okS ? _vahS : _okH ? _vahH : _okO ? _vahO : na
        _spVaL := _okS ? _valS : _okH ? _valH : _okO ? _valO : na

        int _drawStartS = _winStartS
        int _x2S        = math.min(_ax + i_footExtend, bar_index + 490)
        int _drawStartH = i_footHorizLastN <= 0 ? _ax : _winStartH
        int _x2H        = math.min(_ax + i_footHorizExt, bar_index + 490)
        int _drawStartO = i_footOppLastN <= 0 ? _ax : _winStartO
        int _x2O        = math.min(_ax + i_footOppExt, bar_index + 490)

        if i_footShowVA and _okS
            float _vahSlopeY1 = f_projPocIcs(_vahS, _axisSlp, _ax, _drawStartS, _trSig, 1.0)
            float _vahSlopeY2 = f_projPocIcs(_vahS, _axisSlp, _ax, _x2S,        _trSig, 1.0)
            float _valSlopeY1 = f_projPocIcs(_valS, _axisSlp, _ax, _drawStartS, _trSig, 1.0)
            float _valSlopeY2 = f_projPocIcs(_valS, _axisSlp, _ax, _x2S,        _trSig, 1.0)

            if not na(_vahSlopeY1) and not na(_vahSlopeY2) and not na(_valSlopeY1) and not na(_valSlopeY2)
                _lnVaH := line.new(_drawStartS, _vahSlopeY1, _x2S, _vahSlopeY2,
                     xloc = xloc.bar_index,
                     color = color.new(i_footVaClr, i_footVaLineT),
                     width = 1,
                     style = line.style_dashed)
                _lnVaL := line.new(_drawStartS, _valSlopeY1, _x2S, _valSlopeY2,
                     xloc = xloc.bar_index,
                     color = color.new(i_footVaClr, i_footVaLineT),
                     width = 1,
                     style = line.style_dashed)
                _llVa := linefill.new(_lnVaH, _lnVaL, color.new(i_footVaClr, i_footVaFillT))

        if i_footShowSlope and _okS
            float _pocSlopeY1 = f_projPocIcs(_pocS, _axisSlp, _ax, _drawStartS, _trSig, 1.0)
            float _pocSlopeY2 = f_projPocIcs(_pocS, _axisSlp, _ax, _x2S,        _trSig, 1.0)
            if not na(_pocSlopeY1) and not na(_pocSlopeY2)
                _lnPoc := line.new(_drawStartS, _pocSlopeY1, _x2S, _pocSlopeY2,
                     xloc = xloc.bar_index,
                     color = color.new(i_footSlopeClr, i_footSlopeTr),
                     width = i_footSlopeW)

                if i_footShowLbl
                    _lbPoc := label.new(_x2S, _pocSlopeY2,
                         "S POC " + str.tostring(_pocS, format.mintick),
                         style     = label.style_label_left,
                         color     = color.new(chart.bg_color, 100),
                         textcolor = color.new(i_footSlopeClr, i_footSlopeTr),
                         size      = math.max(i_dashSz - 3, 6),
                         tooltip   = f_pocTip("Sloped Structure POC", _pocS, _vahS, _valS, _winStartS, _ax, _lastS, _cntS, _volS, _drawStartS, _x2S))

        if i_footShowHoriz and _okH
            _lnPocH := line.new(_drawStartH, _pocH, _x2H, _pocH,
                 xloc  = xloc.bar_index,
                 color = color.new(i_footHorizClr, i_footHorizTr),
                 width = i_footHorizW,
                 style = f_sty(i_footHorizSty))

            if i_footShowLbl
                _lbPocH := label.new(_x2H, _pocH,
                     "H POC " + str.tostring(_pocH, format.mintick),
                     style     = label.style_label_left,
                     color     = color.new(chart.bg_color, 100),
                     textcolor = color.new(i_footHorizClr, i_footHorizTr),
                     size      = math.max(i_dashSz - 3, 6),
                     tooltip   = f_pocTip("Horizontal Current POC", _pocH, _vahH, _valH, _winStartH, _ax, _lastH, _cntH, _volH, _drawStartH, _x2H))

        if i_footShowOpp and _okO
            float _pocOppY1 = f_projPocIcs(_pocO, _axisSlp, _ax, _drawStartO, _trSig, -1.0)
            float _pocOppY2 = f_projPocIcs(_pocO, _axisSlp, _ax, _x2O,        _trSig, -1.0)
            if not na(_pocOppY1) and not na(_pocOppY2)
                _lnPocO := line.new(_drawStartO, _pocOppY1, _x2O, _pocOppY2,
                     xloc  = xloc.bar_index,
                     color = color.new(i_footOppClr, i_footOppTr),
                     width = i_footOppW,
                     style = f_sty(i_footOppSty))

                if i_footShowLbl
                    string _oppSide = close[_anchor] > _pocOppY2 ? "Price above opposite-slope POC" :
                         close[_anchor] < _pocOppY2 ? "Price below opposite-slope POC" :
                         "Price at opposite-slope POC"
                    _lbPocO := label.new(_x2O, _pocOppY2,
                         "OP POC " + str.tostring(_pocO, format.mintick),
                         style     = label.style_label_left,
                         color     = color.new(chart.bg_color, 100),
                         textcolor = color.new(i_footOppClr, i_footOppTr),
                         size      = math.max(i_dashSz - 3, 6),
                         tooltip   = f_pocTip("Opposite-Slope POC", _pocO, _vahO, _valO, _winStartO, _ax, _lastO, _cntO, _volO, _drawStartO, _x2O) + "\n" + _oppSide)

// ══════════════════════════════════════════════════════════════════════════════════
// ENRICHMENT PANEL   [ADDED]
// ══════════════════════════════════════════════════════════════════════════════════

var table _enr = na
if (barstate.islastconfirmedhistory or barstate.islast) and i_enableEnr
    if not na(_enr)
        table.delete(_enr)
    string _ePos = switch i_enrPos
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        =>                 position.middle_right

    int   szE  = math.max(i_dashSz - 1, 6)
    color ebg  = color.new(chart.bg_color, 15)
    color ehd  = color.new(chart.bg_color, 5)
    color ebdr = color.new(chart.fg_color, 80)
    color etx  = color.new(chart.fg_color, 25)

    _enr := table.new(_ePos, 2, 9, bgcolor = ebg, border_color = ebdr, border_width = 1, frame_color = ebdr, frame_width = 1)

    table.cell(_enr, 0, 0, "🦅✦ ENRICH", text_color = chart.fg_color, text_size = szE, bgcolor = ehd, text_halign = text.align_left)
    table.cell(_enr, 1, 0, "#" + syminfo.ticker, text_color = chart.fg_color, text_size = szE, bgcolor = ehd, text_halign = text.align_right)

    color convClr = _conv >= 7.0 ? #26a69a : _conv >= 4.0 ? #EF9F27 : #888888
    table.cell(_enr, 0, 1, " Conviction", text_color = etx, text_size = szE, bgcolor = ebg, text_halign = text.align_left)
    table.cell(_enr, 1, 1, _ok ? str.tostring(_conv, "#.#") + " / 10" : "—", text_color = convClr, text_size = szE, bgcolor = ebg, text_halign = text.align_right)

    string regTxt = f_dStr(_dir, _L) + "  " + (_ang >= 0 ? "+" : "") + str.tostring(_ang, "#.#") + "°  " + _angMomTxt
    table.cell(_enr, 0, 2, " Trend / Angle", text_color = etx, text_size = szE, bgcolor = ebg, text_halign = text.align_left)
    table.cell(_enr, 1, 2, regTxt, text_color = f_dClr(_dir), text_size = szE, bgcolor = ebg, text_halign = text.align_right)

    string casTxt = (_fSign == 0 and _sSign == 0) ? "neutral"
         : _cascadeDiverge ? "DIVERGE  f" + (_fSign > 0 ? "▲" : "▼") + " / s" + (_sSign > 0 ? "▲" : "▼")
         : _fSign == _sSign ? "aligned " + (_sSign > 0 ? "▲" : "▼")
         : _sSign == 0 ? "fast lead " + (_fSign > 0 ? "▲" : "▼")
         : "fast cooling"
    color casClr = _cascadeDiverge ? #ef5350 : (_fSign == _sSign and _sSign != 0) ? #26a69a : etx
    table.cell(_enr, 0, 3, " Cascade", text_color = etx, text_size = szE, bgcolor = ebg, text_halign = text.align_left)
    table.cell(_enr, 1, 3, casTxt, text_color = casClr, text_size = szE, bgcolor = ebg, text_halign = text.align_right)

    string compTxt = na(_compRatio) ? "—"
         : _compressed ? "COMPRESSED " + str.tostring(math.round(_compRatio * 100)) + "%"
         : _expanded   ? "EXPANDED "   + str.tostring(math.round(_compRatio * 100)) + "%"
         :               "normal "     + str.tostring(math.round(_compRatio * 100)) + "%"
    color compClr = _compressed ? i_compClr : _expanded ? #ef5350 : etx
    table.cell(_enr, 0, 4, " Compression", text_color = etx, text_size = szE, bgcolor = ebg, text_halign = text.align_left)
    table.cell(_enr, 1, 4, compTxt, text_color = compClr, text_size = szE, bgcolor = ebg, text_halign = text.align_right)

    table.cell(_enr, 0, 5, " σ Width", text_color = etx, text_size = szE, bgcolor = ebg, text_halign = text.align_left)
    table.cell(_enr, 1, 5, na(_widthSig) ? "—" : str.tostring(_widthSig, "#.##") + "σ", text_color = etx, text_size = szE, bgcolor = ebg, text_halign = text.align_right)

    string fpTxt = not _fpOK ? "off" : na(_spPoc) ? "n/a" : str.tostring(_spPoc, format.mintick)
    table.cell(_enr, 0, 6, " Struct POC", text_color = etx, text_size = szE, bgcolor = ebg, text_halign = text.align_left)
    table.cell(_enr, 1, 6, fpTxt, text_color = _fpOK ? i_footSlopeClr : color.gray, text_size = szE, bgcolor = ebg, text_halign = text.align_right)

    table.cell(_enr, 0, 7, " Regime", text_color = etx, text_size = szE, bgcolor = ebg, text_halign = text.align_left)
    table.cell(_enr, 1, 7, i_enableRegime ? _regimeTxt : "off", text_color = not i_enableRegime ? color.gray : _regimeTrend ? #26a69a : #EF9F27, text_size = szE, bgcolor = ebg, text_halign = text.align_right)

    string flowTxt = not _fpOK ? "off" : na(_fpDpct) ? "n/a" : str.tostring(math.round(_fpDpct)) + "% " + _fpPocTxt
    color  flowClr = not _fpOK ? color.gray : na(_fpDelta) ? etx : _fpDelta > 0 ? #26a69a : _fpDelta < 0 ? #ef5350 : etx
    table.cell(_enr, 0, 8, " Flow Δ", text_color = etx, text_size = szE, bgcolor = ebg, text_halign = text.align_left)
    table.cell(_enr, 1, 8, flowTxt, text_color = flowClr, text_size = szE, bgcolor = ebg, text_halign = text.align_right)

// ══════════════════════════════════════════════════════════════════════════════════
// ADAPTIVE LEARNING ENGINE — frozen-snapshot outcome tracking   [REBUILT]
//   Dynamic structure is used ONLY to detect the setup.
//   Once a breakout confirms, the engine freezes the setup bar, entry, σ target,
//   σ stop, rails, angle, consensus, ATR, and current POC snapshot.
//   Resolution uses ONLY the frozen target/stop and future closed bars.
//   No dynamic rail / POC / SQ9 / VWAP recalculation can move an open setup.
// ══════════════════════════════════════════════════════════════════════════════════

float _learnAtrSnap = ta.atr(14)

f_regSetup(int kind, int dir) =>
    // The setup bar is the same bar used by the state machine:
    // Live Bar mode  → current bar [0]
    // Close Bar mode → last closed bar [1]
    int _setupBar = bar_index - _anchor

    if i_enableLearn and dir != 0 and _trSig > MIN_SIGMA and close[_anchor] > 0.0
        float _entrySnap = close[_anchor]
        float _sigSnap   = _trSig
        float _atrSnap   = nz(_learnAtrSnap[_anchor], _learnAtrSnap)
        float _railUSnap = _chUp
        float _railLSnap = _chLo
        float _pocSnap   = _spPoc
        float _vwapSnap  = na
        float _sq9Snap   = na
        float _angSnap   = _ang
        int   _confSnap  = dir > 0 ? _cUp : _cDn
        bool  _qualityOK = not i_learnQualityFilter or (_conv >= i_learnMinConv and _confSnap >= i_learnMinConf and (not i_learnRequireTrend or _regimeTrend))

        // Frozen σ-native target/stop in log-price space.
        // These are locked at setup confirmation and never move.
        float _targetSnap = _entrySnap * math.exp( dir * i_learnTgt  * _sigSnap)
        float _stopSnap   = _entrySnap * math.exp(-dir * i_learnStop * _sigSnap)

        if _qualityOK
            array.push(_openSetups, Setup.new(
                 _setupBar,
                 kind,
                 dir,
                 _entrySnap,
                 _targetSnap,
                 _stopSnap,
                 _sigSnap,
                 _atrSnap,
                 _pocSnap,
                 _vwapSnap,
                 _railUSnap,
                 _railLSnap,
                 _sq9Snap,
                 _angSnap,
                 _confSnap))

if i_enableLearn and barstate.isconfirmed
    int _evalBar = bar_index - _anchor

    // Resolve first, so a setup never resolves on its own registration bar.
    // Use a positive loop and convert to reverse index; Pine requires loop steps > 0.
    int _nOpen = array.size(_openSetups)
    if _nOpen > 0
        for _r = 0 to _nOpen - 1
            int idx = _nOpen - 1 - _r
            Setup s = array.get(_openSetups, idx)
            int  age = _evalBar - s.bar0

            if age > 0
                // Resolution uses ONLY frozen target/stop plus future closed-bar high/low.
                // It never uses new/dynamic channel rails, new POC, new SQ9, or new VWAP.
                bool hitTgt = s.dir > 0 ? high[_anchor] >= s.target : low[_anchor]  <= s.target
                bool hitStp = s.dir > 0 ? low[_anchor]  <= s.stop   : high[_anchor] >= s.stop
                int  res    = hitStp ? 2 : hitTgt ? 1 : age >= i_learnMax ? 3 : 0

                if res != 0
                    int k = s.kind
                    if res == 1
                        array.set(sWin, k, array.get(sWin, k) + 1)
                        array.set(sDur, k, array.get(sDur, k) + age)
                    else if res == 2
                        array.set(sLoss, k, array.get(sLoss, k) + 1)
                    else
                        array.set(sTo, k, array.get(sTo, k) + 1)

                    if s.conf >= i_learnConfHi
                        array.set(sHiTot, k, array.get(sHiTot, k) + 1)
                        if res == 1
                            array.set(sHiWin, k, array.get(sHiWin, k) + 1)

                    array.remove(_openSetups, idx)

// Register fresh confirmed breakouts AFTER resolution.
// IMPORTANT: f_regSetup() is called at GLOBAL SCOPE on every bar.
// The barstate/i_enableLearn gates are in the arguments, so Pine will not
// throw the conditional-function warning.
bool _newBOUpLearn = i_enableLearn and barstate.isconfirmed and _boState == ST_BO_UP and _boState[1] != ST_BO_UP
bool _newBODnLearn = i_enableLearn and barstate.isconfirmed and _boState == ST_BO_DN and _boState[1] != ST_BO_DN
int  _regKindLearn = _newBOUpLearn ? 1 : _newBODnLearn ? 2 : 0
int  _regDirLearn  = _newBOUpLearn ? 1 : _newBODnLearn ? -1 : 0
f_regSetup(_regKindLearn, _regDirLearn)

f_winPct(int w, int l) => (w + l) > 0 ? str.tostring(math.round(w * 100.0 / (w + l))) + "%" : "—"
f_lenTxt(int durSum, int wins) =>
    string out = "—"
    if wins > 0
        float ab   = durSum / wins
        float secs = ab * timeframe.in_seconds(timeframe.period)
        string tt  = secs >= 86400 ? str.tostring(math.round(secs / 8640.0) / 10.0) + "d" : secs >= 3600 ? str.tostring(math.round(secs / 360.0) / 10.0) + "h" : str.tostring(math.round(secs / 60.0)) + "m"
        out := str.tostring(math.round(ab * 10.0) / 10.0) + "b·" + tt
    out
f_lrnPos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        "Middle Left"  => position.middle_left
        =>                position.bottom_right

var table _lrn = na
if barstate.islast and i_enableLearn and i_learnShowTbl
    if not na(_lrn)
        table.delete(_lrn)
    color lhb  = color.new(chart.bg_color, 5)
    color lbg  = color.new(chart.bg_color, 15)
    color lbdr = color.new(chart.fg_color, 80)
    color ltc  = color.new(chart.fg_color, 25)
    int   szL  = math.max(i_dashSz - 2, 6)
    _lrn := table.new(f_lrnPos(i_learnPos), 6, 4, bgcolor = lbg, border_color = lbdr, border_width = 1, frame_color = lbdr, frame_width = 1)
    table.cell(_lrn, 0, 0, "LEARN " + timeframe.period, text_color = chart.fg_color, text_size = szL, bgcolor = lhb, text_halign = text.align_left)
    table.cell(_lrn, 1, 0, "Win",    text_color = ltc, text_size = szL, bgcolor = lhb)
    table.cell(_lrn, 2, 0, "W-L-T",  text_color = ltc, text_size = szL, bgcolor = lhb)
    table.cell(_lrn, 3, 0, "AvgLen", text_color = ltc, text_size = szL, bgcolor = lhb)
    table.cell(_lrn, 4, 0, "Hi≥" + str.tostring(i_learnConfHi), text_color = #5b9bd5, text_size = szL, bgcolor = lhb)
    table.cell(_lrn, 5, 0, i_enableRanker ? "Edge×" : "Edge", text_color = i_enableRanker ? chart.fg_color : color.gray, text_size = szL, bgcolor = lhb)
    for k = 1 to 2
        string nm = k == 1 ? "BO Up" : "BO Dn"
        int w = array.get(sWin, k)
        int l = array.get(sLoss, k)
        int t = array.get(sTo, k)
        table.cell(_lrn, 0, k, nm, text_color = ltc, text_size = szL, bgcolor = lbg, text_halign = text.align_left)
        table.cell(_lrn, 1, k, f_winPct(w, l), text_color = (w + l) > 0 and w * 100.0 / (w + l) >= 50 ? #26a69a : #ef5350, text_size = szL, bgcolor = lbg)
        table.cell(_lrn, 2, k, str.tostring(w) + "-" + str.tostring(l) + "-" + str.tostring(t), text_color = ltc, text_size = szL, bgcolor = lbg)
        table.cell(_lrn, 3, k, f_lenTxt(array.get(sDur, k), w), text_color = ltc, text_size = szL, bgcolor = lbg)
        table.cell(_lrn, 4, k, f_winPct(array.get(sHiWin, k), array.get(sHiTot, k) - array.get(sHiWin, k)), text_color = #5b9bd5, text_size = szL, bgcolor = lbg)
        float mv = f_rankMult(k, k == 1 ? _cUp : _cDn)
        table.cell(_lrn, 5, k, i_enableRanker ? "×" + str.tostring(math.round(mv * 100) / 100) : "—", text_color = not i_enableRanker ? color.gray : mv >= 1.05 ? #26a69a : mv <= 0.95 ? #ef5350 : ltc, text_size = szL, bgcolor = lbg)
    int aW  = array.get(sWin, 1)   + array.get(sWin, 2)
    int aL  = array.get(sLoss, 1)  + array.get(sLoss, 2)
    int aT  = array.get(sTo, 1)    + array.get(sTo, 2)
    int aD  = array.get(sDur, 1)   + array.get(sDur, 2)
    int aHW = array.get(sHiWin, 1) + array.get(sHiWin, 2)
    int aHT = array.get(sHiTot, 1) + array.get(sHiTot, 2)
    table.cell(_lrn, 0, 3, "ALL", text_color = chart.fg_color, text_size = szL, bgcolor = lhb, text_halign = text.align_left)
    table.cell(_lrn, 1, 3, f_winPct(aW, aL), text_color = chart.fg_color, text_size = szL, bgcolor = lhb)
    table.cell(_lrn, 2, 3, str.tostring(aW) + "-" + str.tostring(aL) + "-" + str.tostring(aT), text_color = ltc, text_size = szL, bgcolor = lhb)
    table.cell(_lrn, 3, 3, f_lenTxt(aD, aW), text_color = ltc, text_size = szL, bgcolor = lhb)
    table.cell(_lrn, 4, 3, f_winPct(aHW, aHT - aHW), text_color = #5b9bd5, text_size = szL, bgcolor = lhb)
    table.cell(_lrn, 5, 3, "—", text_color = ltc, text_size = szL, bgcolor = lhb)

// ══════════════════════════════════════════════════════════════════════════════════
// ALERT ENGINE — Guard + Warning Label
// ══════════════════════════════════════════════════════════════════════════════════

bool _alertsActive = i_enableAlerts and _anchor == 0

plot(_ang,          "Angle",      display = display.none)
plot(_cUp - _cDn,   "Agreement",  display = display.none)
plot(_extPos * 100, "ChannelPos", display = display.none)

var label _alertWarn = na

if barstate.islast
    label.delete(_alertWarn)
    _alertWarn := na
    if i_enableAlerts and _anchor != 0
        _alertWarn := label.new(bar_index, high,
             "⚠  " + _L.alert_warn,
             style = label.style_label_down,
             color = color.new(#EF9F27, 0),
             textcolor = color.white,
             size = math.max(i_dashSz, 6),
             yloc = yloc.abovebar,
             tooltip = _L.alert_warn_tip)

// ══════════════════════════════════════════════════════════════════════════════════
// ALERT CONDITIONS — 19 alerts across 5 categories (D B R S A)
// ══════════════════════════════════════════════════════════════════════════════════

alertcondition(_alertsActive and _dir == DIR_UP   and _dir[1] != DIR_UP,   "▲ Uptrend Entry",
     "📈 UPTREND — trend turned UP")
alertcondition(_alertsActive and _dir == DIR_DOWN and _dir[1] != DIR_DOWN, "▼ Downtrend Entry",
     "📉 DOWNTREND — trend turned DOWN")
alertcondition(_alertsActive and _dir == DIR_FLAT and _dir[1] != DIR_FLAT, "◈ Range Entry",
     "◈ RANGE — trend went FLAT")

alertcondition(_alertsActive and _boState == ST_BO_UP and _boState[1] != ST_BO_UP, "▲ Breakout Up",
     "🟢 BO UP — price broke above ceiling")
alertcondition(_alertsActive and _boConfirm and not _boConfirm[1] and _boState == ST_BO_UP, "✓ BO Up Confirmed",
     "✅ BO UP CONFIRMED — retested and bounced")
alertcondition(_alertsActive and _boState == ST_BO_DN and _boState[1] != ST_BO_DN, "▼ Breakout Down",
     "🔴 BO DN — price broke below floor")
alertcondition(_alertsActive and _boConfirm and not _boConfirm[1] and _boState == ST_BO_DN, "✓ BO Down Confirmed",
     "✅ BO DN CONFIRMED — retested and bounced")

alertcondition(_alertsActive and _boState == ST_RT_UP and _boState[1] != ST_RT_UP, "↺ Retest Up",
     "↺ RETEST UP — price returning to ceiling")
alertcondition(_alertsActive and _boState == ST_RT_DN and _boState[1] != ST_RT_DN, "↺ Retest Down",
     "↺ RETEST DN — price returning to floor")

alertcondition(_alertsActive and _boGapped and not _boGapped[1] and _boState == ST_BO_UP, "⚡ Gap Up Through",
     "⚡ GAP UP — price crossed entire channel upward")
alertcondition(_alertsActive and _boGapped and not _boGapped[1] and _boState == ST_BO_DN, "⚡ Gap Down Through",
     "⚡ GAP DN — price crossed entire channel downward")
alertcondition(_alertsActive and _retFrom ==  1 and _retFrom[1] !=  1, "✗ Failed Breakout Up",
     "✗ FAILED BO UP — returned inside channel")
alertcondition(_alertsActive and _retFrom == -1 and _retFrom[1] != -1, "✗ Failed Breakout Down",
     "✗ FAILED BO DN — returned inside channel")
alertcondition(_alertsActive and _dirReset, "↻ Direction Reset",
     "↻ DIR RESET — trend direction changed, state wiped")

alertcondition(_alertsActive and _cUp   == 6 and _cUp[1]    != 6, "🔵 Full Bull 6/6",
     "🔵 FULL BULL — all 6 scales agree UP")
alertcondition(_alertsActive and _cUp   == 5 and _cUp[1]    != 5, "🔵 Strong Bull 5/6",
     "🔵 STRONG BULL — 5 of 6 scales agree UP")
alertcondition(_alertsActive and _cDn   == 6 and _cDn[1]    != 6, "🔴 Full Bear 6/6",
     "🔴 FULL BEAR — all 6 scales agree DN")
alertcondition(_alertsActive and _cDn   == 5 and _cDn[1]    != 5, "🔴 Strong Bear 5/6",
     "🔴 STRONG BEAR — 5 of 6 scales agree DN")
alertcondition(_alertsActive and _cFlat >= 4 and _cFlat[1]  < 4, "◈ Range Consensus ≥4/6",
     "◈ RANGE CONSENSUS — ≥4 of 6 scales in RNG")

// ══════════════════════════════════════════════════════════════════════════════════
// ENRICHMENT ALERTS   [ADDED]
// ══════════════════════════════════════════════════════════════════════════════════

alertcondition(_alertsActive and _cascadeDiverge and not _cascadeDiverge[1], "⚠ Cascade Divergence",
     "⚠ CASCADE DIVERGE — fast scales flipped against the slow trend (early reversal tell)")
alertcondition(_alertsActive and _compressed and not _compressed[1], "◣ Channel Compressed",
     "◣ COMPRESSED — ICS channel width squeezed below 0.8× average (coiling)")
alertcondition(_alertsActive and _expanded and not _expanded[1], "◤ Channel Expansion",
     "◤ EXPANDED — ICS channel width above 1.2× average (impulse)")

// ══════════════════════════════════════════════════════════════════════════════════
// REFERENCES · DISCLAIMER
//   Yang, D. & Zhang, Q. (2000). Drift-Independent Volatility Estimation. J. Business 73(3).
//   Rogers, L.C.G. & Satchell, S.E. (1991). Estimating variance from high, low, close. AAP 1(4).
//   ICS: y = log(price)/σ — scale-invariant trend angles and distances across instruments.
//   Educational / analytical tool. Not financial advice.
// ══════════════════════════════════════════════════════════════════════════════════
````
