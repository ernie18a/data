# Luxy BOSS MODE - Support & Resistance

- url: https://www.tradingview.com/script/oA9rDnQB-Luxy-BOSS-MODE-Support-Resistance/
- type: indicator
- pine_id: PUB;4184a701a1b74ae1b342fc4770268397
- version: 3.0

## Description

[b]BOSS MODE S/R[/b] is a comprehensive Support & Resistance system that detects, scores, and learns from every zone reaction — then automatically generates trade plans with entry, stop, target, and position size.

Unlike traditional S/R indicators that simply draw lines, BOSS MODE combines [b]6 detection engines[/b], an [b]adaptive scoring algorithm[/b], a [b]real-time momentum classifier[/b] powered by the Luxy Energy Index, and a [b]Trade Plan Generator[/b] that calculates exact risk parameters based on your account.

[b]── WHAT MAKES IT DIFFERENT ──[/b]

[b]1. Adaptive Weight Scoring[/b]
Every zone is scored 0-100 based on 7 factors: volume at touch, higher-timeframe origin, confluence with other zones, freshness, touch count, regime alignment, and historical performance. After 20+ observed zone outcomes (first bounce or first break per zone), the system [b]adjusts its scoring weights[/b] based on which factors correlated with bounces vs breaks on that specific chart and asset.

[b]2. LEI-Powered Momentum Classifier[/b]
Uses the Luxy Energy Index (Extension + Velocity + Volume exhaustion model) to classify each approaching zone as likely [b]BOUNCE[/b] or [b]BREAK[/b]. LEI ≥ 70 = exhausted move arriving at zone = bounce expected. LEI ≤ 30 = energized move = break risk.

[b]3. Trade Plan Generator[/b]
For qualifying setups (Grade A/B zone, regime-aligned, R:R above your minimum), the indicator auto-calculates:
[list]
[*]Entry — just beyond zone boundary
[*]Stop Loss — opposite side of zone + ATR buffer
[*]Target — nearest zone in trade direction
[*]Position Size — based on your account size and risk %
[*]R:R ratio — only shows when above your minimum
[/list]

[b]4. Per-Zone Intelligence[/b]
Every zone tracks its own history: how many times it bounced vs broke, average bounce distance in ATR units, and hold rate. Labels show this inline: [i]⬆ SUPPORT 📐 82  5/7  +0.4ᴬ[/i] = score 82, held 5 of 7 tests, avg distance from zone mid at touch: 0.4 ATR.

[image]https://www.tradingview.com/x/rh4P4UVG/[/image]


[b]── 6 DETECTION ENGINES ──[/b]

[list]
[*][b]📐 Swing Pivots[/b] — Classical swing highs/lows on current, Daily, and Weekly timeframes
[*][b]🧱 Order Blocks[/b] — Last candle before a strong impulsive move, confirmed by volume
[*][b]📊 Volume POC[/b] — Highest-volume price cluster over lookback period
[*][b]💨 Fair Value Gaps[/b] — 3-candle imbalances where price left unfilled ranges
[*][b]💧 Liquidity Pools[/b] — Equal high/low clusters where stops accumulate
[*][b]⚓ Anchored VWAP[/b] — Auto-anchors on gap+volume events (earnings, catalysts)
[/list]

All 6 sources feed into the same unified zone object, allowing true confluence scoring across methodologies.

[image]https://www.tradingview.com/x/Oluripnm/[/image]


[b]── REGIME-AWARE SCORING ──[/b]

The market regime (STRONG_BULL / WEAK_BULL / RANGE / WEAK_BEAR / STRONG_BEAR / SQUEEZE) drives the scoring bias. In a bullish regime, support zones receive a significant score bonus while resistance zones score lower — reflecting the statistical reality that zones aligned with the trend hold more reliably.

Regime is calculated from ADX + Bollinger Band Width + EMA slope, giving 5 states plus a Squeeze override when volatility compresses to the bottom 10% of the last 100 bars.


[b]── VISUAL SYSTEM ──[/b]

Zones are rendered with a 4-layer heat-map system:
[list]
[*]Atmospheric halo — fades beyond zone boundaries, scales with score
[*]Main fill — neon color: cyan family for support, red/orange for resistance, intensity proportional to score
[*]Hot core strip — brighter inner band at zone midpoint
[*]Entry line — solid bright stripe at the price-contact edge (top for support, bottom for resistance)
[*]Grade-A pulse ring — glowing outline when a high-conviction zone is within 1.5 ATR of price
[*]Score bar — vertical progress bar to the right of each zone, height = score 0-100
[/list]

[b]Simple View[/b]: A separate layer draws just two clear boxes — nearest SUPPORT (green) and nearest RESISTANCE (red) — with text centered inside. Designed for traders who want instant visual clarity without analyzing all zones.

[image]https://www.tradingview.com/x/bGpDLc0e/[/image]


[b]── TRADE PLAN GENERATOR ──[/b]

Configure in the [b]💰 Trade Plan[/b] settings group:
[list]
[*][b]Account Size ($)[/b] — your total trading capital
[*][b]Risk per Trade (%)[/b] — standard is 1.0% per trade
[*][b]Min R:R to Show[/b] — only displays setups where the calculated reward exceeds this multiple of risk
[/list]

When a qualifying setup is found, three dashed lines appear on the chart (blue = entry, red = stop, green = target) with a summary label showing direction, prices, share count, and R:R ratio. The Dashboard shows it in the [b]💰 Active Setup[/b] row. An alert fires with the full trade plan.

[b]Important:[/b] The Trade Plan Generator identifies setups based on zone proximity and regime alignment. All trade decisions remain entirely the responsibility of the user. Past zone reactions do not guarantee future performance. Always apply your own analysis and risk management.

[image]https://www.tradingview.com/x/Ns5AWeoK/[/image]


[b]── DASHBOARD (14 rows) ──[/b]

The information panel shows in real-time:
[list]
[*]Market Regime with color coding
[*]Asset Class / Session (PRE/RTH/AH for stocks)
[*]Active zones breakdown (0A/1B/3C format)
[*]Nearest Resistance price, grade, ATR distance
[*]Nearest Support price, grade, ATR distance
[*]ATR% Rank (volatility context)
[*]Active Warning (8 types, color-coded by severity)
[*]Anchored VWAP value and anchor reason
[*]Squeeze detector
[*]Zone Hit Rate (historical bounce %)
[*]Active Detection Sources
[*]Scenario suggestion
[*]Adaptive Weights status
[*]Active Trade Plan (Entry / Stop / Target / Shares / R:R)
[/list]

Every cell has a detailed tooltip explaining what the value means and how to use it.


[b]── MULTI-ASSET SUPPORT ──[/b]

The asset engine auto-detects chart type and adjusts accordingly:
[list]
[*][b]Stocks[/b] — ATR-based zones, session-aware (PRE/RTH/AH)
[*][b]Stocks under $1[/b] — percent-based zone widths (ATR is unreliable for extreme low-price securities)
[*][b]Crypto[/b] — 24/7, percent bands, no session breaks
[*][b]Forex[/b] — pip-based zone widths
[*][b]Indices[/b] — volume-agnostic fallback
[*][b]Futures[/b] — rollover-aware
[/list]

[image]https://www.tradingview.com/x/7kol6pSS/[/image]


[b]── SETTINGS OVERVIEW ──[/b]

[list]
[*][b]🎯 Trading Mode[/b] — Scalp / Intraday / Swing (affects zone widths and sensitivity)
[*][b]🧭 Regime Classifier[/b] — ADX, BB, and EMA periods
[*][b]🎯 Zone Detection[/b] — Toggle each of the 6 engines independently
[*][b]📐 Swing Pivots[/b] — Left/right lookback bars and zone width
[*][b]🧱 Order Blocks[/b] — Lookback period, minimum move %, volume threshold
[*][b]📊 Volume POC[/b] — Lookback bars and histogram bins
[*][b]💨 Fair Value Gaps[/b] — Minimum gap size %
[*][b]💧 Liquidity Pools[/b] — Lookback and touch tolerance %
[*][b]⚓ Anchored VWAP[/b] — Auto-anchor thresholds and manual catalyst date
[*][b]⚖️ Scoring[/b] — Individual weight controls for all 7 scoring factors
[*][b]🌍 Asset-Class Adaptation[/b] — Override or force Sub-$5 mode
[*][b]🚨 Warnings[/b] — Toggle each of 8 warning types with ATR distance control
[*][b]🎨 Visual Settings[/b] — Top-N zones, adaptive hide, transparency, Simple View toggle
[*][b]📊 Dashboard[/b] — Position, size, show/hide
[*][b]💰 Trade Plan[/b] — Account size, risk %, minimum R:R
[*][b]🔔 Alerts[/b] — Standard or structured JSON for webhook automation
[/list]


[b]── ALERTS ──[/b]

[b]8 alert types:[/b]
[list]
[*]Any Warning (catch-all)
[*]Sweep Imminent
[*]Regime Shift near Grade-A zone
[*]Trap Suspected (low-volume false breakout)
[*]Zone Approach
[*]Squeeze Detected
[*]Trade Plan — LONG Setup
[*]Trade Plan — SHORT Setup
[/list]

Enable [b]Structured JSON Alerts[/b] to receive webhook-ready payloads with full zone data, regime, warning type, and trade plan details.


[b]── EXTERNAL LIBRARY ──[/b]

This script imports [url=https://www.tradingview.com/script/your_lei_library_link/]Luxy Energy Index (LEI)[/url] by OrenLuxy for the momentum classifier. LEI measures move exhaustion using Extension from VWAP, Velocity (5-bar rate of change), and Volume as a modifier.


[b]── IMPORTANT NOTES ──[/b]

[list]
[*]This indicator is for [b]educational and analytical purposes only[/b]. It does not constitute financial advice.
[*]Past zone performance (hit rate, average bounce) does not guarantee future results.
[*]The Trade Plan Generator calculates position sizes mathematically based on user inputs — always verify sizing with your broker before placing orders.
[*]Adaptive weights require 20+ observed bounce/break events to activate. On new charts, base weights are used.
[*]The LEI library requires separate import — the indicator will prompt if not accessible.
[/list]


[b]── CREDITS ──[/b]

[list]
[*]Luxy Energy Index (LEI) — OrenLuxy. Exhaustion methodology drawing on academic research by Campbell-Grossman-Wang (1993) on volume-return relationships, ATR normalization by J. Welles Wilder Jr., and standard VWAP methodology.
[*]S/R concepts inspired by VSA (Volume Spread Analysis), SMC (Smart Money Concepts), and classical pivot point theory.
[/list]

[i]Past performance does not predict future results. This tool is for informational purposes only and does not constitute investment advice. Trading involves substantial risk of loss.[/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © OrenLuxy
//
// ── External Libraries ──
// LuxyEnergyIndex by OrenLuxy — Energy exhaustion scoring (Extension + Velocity + Volume)
// Used for Momentum Classifier: LEI ≥ 65 at zone touch = exhausted move → BOUNCE signal
// LEI ≤ 35 at zone touch = energized move → BREAK RISK signal

//@version=6
indicator("Luxy BOSS MODE — Support & Resistance", shorttitle="Luxy Support Resistance", overlay=true, max_bars_back=400, max_boxes_count=200, max_lines_count=20, max_labels_count=50)
// max_bars_back sizing — this buffer is allocated for EVERY series the script maintains, so an
// oversized value costs memory and load time across the board. The deepest history this script
// actually reads is 200 bars (i_vp_lookback at its 200 maximum, via high[k]/low[k]/volume[k] and
// ta.highest/ta.lowest). Next deepest are i_ob_lookback (100), ta.percentrank(...,100) and the
// pivot legs (20+20). 400 covers the true 200 requirement with 100 bars of margin above the
// zone-box left-edge clamp below, which must stay strictly under this number.
import orenluxy/LuxyEnergyIndex/1 as LEI

// ═══════════════════════════════════════════════════════════
// TYPE DEFINITIONS
// ═══════════════════════════════════════════════════════════

type SRZone
    int    id
    string source
    float  top
    float  bottom
    float  mid
    int    bar_created
    string htf_source
    bool   is_support
    bool   is_fresh
    int    touches
    int    violations
    int    flip_count
    float  creation_volume
    float  touch_vol_avg
    float  width_atr
    int    last_touch_bar
    int    confluence_count
    float  score
    string grade
    string regime_at_creation
    bool   is_naked_poc
    string catalyst_label
    int    box_id
    int    label_id
    // ── Intelligence fields (per-zone learning) ──
    int    bounce_count        // times price bounced at this zone
    int    break_count         // times price broke through this zone
    float  avg_dist_at_touch_atr  // running avg distance from zone mid at touch moment (ATR units)
    string momentum_signal     // real-time: "⬆ BOUNCE" | "⚠ BREAK" | "—"
    int    sources_mask        // bitmask of distinct detector sources that confirmed this exact zone (true confluence)
    int    pending_check_bar   // bar_index scheduled to judge bounce vs break after a touch; -1 = none pending
    bool   pending_expect_support  // is_support snapshotted at touch time, so a mid-window flip doesn't corrupt the judgment

// ═══════════════════════════════════════════════════════════
// INPUT GROUPS
// ═══════════════════════════════════════════════════════════

GROUP_MODE    = "🎯 Trading Mode ═══════════════════════════════════"
GROUP_STRUCT  = "🏗 Market Structure ════════════════════════════════"
GROUP_TRIGGER = "🕯 Entry Trigger ═══════════════════════════════════"
GROUP_MTF     = "🔭 Higher-Timeframe Bias ═══════════════════════════"
GROUP_PROJ    = "🔮 Projection ══════════════════════════════════════"
GROUP_REGIME  = "🧭 Regime Classifier ══════════════════════════════"
GROUP_ZONES   = "🎯 Zone Detection ═════════════════════════════════"
GROUP_SWING   = "📐 Swing Pivots ════════════════════════════════════"
GROUP_OB      = "🧱 Order Blocks ════════════════════════════════════"
GROUP_VOLPROF = "📊 Volume POC ══════════════════════════════════════"
GROUP_FVG     = "💨 Fair Value Gaps ═════════════════════════════════"
GROUP_LIQ     = "💧 Liquidity Pools ═════════════════════════════════"
GROUP_AVWAP   = "⚓ Anchored VWAP ════════════════════════════════════"
GROUP_SCORE   = "⚖️ Scoring ═════════════════════════════════════════"
GROUP_ASSET   = "🌍 Asset-Class Adaptation ══════════════════════════"
GROUP_WARN    = "🚨 Warnings ════════════════════════════════════════"
GROUP_VISUAL  = "🎨 Visual Settings ═════════════════════════════════"
GROUP_DASH    = "📊 Dashboard ═══════════════════════════════════════"
GROUP_ALERTS  = "🔔 Alerts ══════════════════════════════════════════"

// Trading Mode
i_trading_mode = input.string("Auto", "Trading Mode", options=["Auto", "Scalp", "Intraday", "Swing"], group=GROUP_MODE, tooltip="One-click preset. Scales FIVE things at once: zone width, pivot legs, detector lookbacks, bounce-confirm bars, and approach distance.\n\nAuto — picks the preset from your chart timeframe:\n  ≤15m → Scalp   |   ≤4H → Intraday   |   above → Swing\nScalp — tight zones, fast pivots, short lookbacks\nIntraday — balanced\nSwing — wide zones, slow pivots, long lookbacks\n\nYour manual settings below stay the base — the preset SCALES them, so tuning still works.\nSwing = ×1.0 on everything, i.e. exactly the values you set below.")

// Market Structure (BOS / CHoCH)
i_ms_enable      = input.bool(true, "Enable Market Structure", group=GROUP_STRUCT, tooltip="Tracks swing highs and lows to decide whether the chart is in a BULL, BEAR or RANGE structure.\n\nBOS (Break of Structure) — price breaks a swing in the SAME direction as the current structure. Continuation.\nCHoCH (Change of Character) — price breaks a swing AGAINST the current structure. This is the first warning that the trend is turning.\n\nStructure feeds the zone score and can gate the Trade Plan.")
i_w_structure    = input.int(16, "Structure Weight", minval=0, maxval=30, group=GROUP_STRUCT, tooltip="How much structure agreement counts toward a zone's score (0-100).\n\nA SUPPORT zone in a BULL structure scores higher; the same zone in a BEAR structure is penalised — price is far more likely to cut straight through it.\n\nDefault 16 puts structure in the top weight band alongside HTF origin (16), touch volume (18) and confluence (18). Every classical framework — Dow, Wyckoff, ICT, Minervini — ranks trend structure ABOVE the quality of any individual level, and with 'Block Trades Against Structure' off by default the score is the only thing carrying that penalty.\n\nSet to 0 to score zones exactly as before, while still seeing structure on the dashboard.")
i_ms_gate_trades = input.bool(false, "Block Trades Against Structure", group=GROUP_STRUCT, tooltip="OFF (default) — counter-structure setups are still shown, but flagged ⚠ AGAINST STRUCTURE on the chart label and in the dashboard. You decide.\n\nON — the plan is suppressed entirely: no LONG while structure is BEAR, no SHORT while structure is BULL. RANGE always allows both.\n\nEven with this OFF, structure still penalises the zone score, so a counter-structure setup has to be genuinely strong to surface at all.")
i_ms_show_line   = input.bool(true, "Show Break Level", group=GROUP_STRUCT, tooltip="Draws a dotted line at the swing price that must break to flip the structure, with a label telling you the exact level to watch.\n\nThis is the single most actionable line on the chart: close beyond it and the structure changes.")

// Entry Trigger (candle confirmation at the zone)
i_trig_enable    = input.bool(true, "Require Candle Trigger", group=GROUP_TRIGGER, tooltip="The zone tells you WHERE. The candle tells you WHEN.\n\nOnce price reaches the setup's zone, the plan waits for a reversal candle before it reads READY. Until then it shows WAIT — the level is live but nothing has reacted yet.\n\nThis is a GATE, not a score. A reversal candle inside an order block is the same event the zone already scored; counting it twice would double-inflate the score.\n\nOFF — the plan goes READY the moment price reaches the zone.")
i_trig_engulf    = input.bool(true, "Engulfing", group=GROUP_TRIGGER, inline="tg1")
i_trig_pin       = input.bool(true, "Pin Bar",   group=GROUP_TRIGGER, inline="tg1")
i_trig_inside    = input.bool(true, "Inside Brk", group=GROUP_TRIGGER, inline="tg1", tooltip="Which candle patterns count as a trigger. Any one of the enabled patterns is enough.\n\nEngulfing — this candle's body completely covers the previous candle's body, in the opposite direction. The clearest single-bar reversal.\nPin Bar — a long rejection wick with a small body. Price probed beyond the level and was pushed back.\nInside Break — a compressed candle inside the previous one, then a close beyond that compression. Coiled, then released.")
i_trig_pin_pct   = input.float(0.55, "Pin Wick Share", minval=0.35, maxval=0.85, step=0.05, group=GROUP_TRIGGER, tooltip="How much of the candle's total range the rejection wick must be, for a Pin Bar.\n\n0.55 = the wick is at least 55% of the whole candle.\nHigher = stricter, fewer but cleaner pins.")
i_trig_zone_atr  = input.float(0.5, "At-Zone Distance (ATR)", minval=0.1, maxval=1.5, step=0.1, group=GROUP_TRIGGER, tooltip="How close price must be to the setup's zone before the trigger is even looked for.\n\nBeyond this distance the plan reads APPROACH — it is a level on the map, not a decision yet.")
i_trig_lookback  = input.int(3, "Trigger Valid For (bars)", minval=1, maxval=10, group=GROUP_TRIGGER, tooltip="How many bars a trigger stays valid after it fires.\n\n3 = you have three bars to act before the plan drops back to WAIT.")
i_dryup_mult     = input.float(0.75, "Volume Dry-Up Threshold", minval=0.4, maxval=1.0, step=0.05, group=GROUP_TRIGGER, tooltip="Quiet before the move. Compares the last 5 bars' volume to the 20-bar average.\n\n0.75 = recent volume is below 75% of average → sellers (or buyers) are exhausted, not fighting.\n\nDry-up at a zone is a genuine positive: it is what precedes a clean bounce. Shown as 💤 on the setup, never blocks anything.")

// Higher-Timeframe Bias
i_mtf_enable     = input.bool(true, "Enable HTF Bias", group=GROUP_MTF, tooltip="Reads the trend on a higher timeframe and flags setups that fight it.\n\nThis is separate from Market Structure: structure is swing breaks on THIS chart, HTF bias is the bigger picture above it. They can disagree, and when they do the setup deserves a smaller size.")
i_mtf_tf         = input.string("Auto", "HTF", options=["Auto", "60", "240", "D", "W"], group=GROUP_MTF, inline="mtf1", tooltip="Which timeframe to read.\n\nAuto climbs one meaningful step above your chart:\n  ≤5m → 1H  |  ≤1H → 4H  |  ≤4H → Daily  |  above → Weekly")
i_mtf_len        = input.int(50, "EMA", minval=10, maxval=200, group=GROUP_MTF, inline="mtf1", tooltip="EMA length used on the higher timeframe. Price above it = BULL bias, below = BEAR bias.")

// Projection
i_proj_enable    = input.bool(true, "Project Path to Target", group=GROUP_PROJ, tooltip="When a trade plan is active, draws the expected path from current price to the target and estimates how many bars it should take at the pace this market has actually been moving.\n\nThe estimate uses the average distance price has covered per bar over the last 20 bars, measured in ATR. It is a pace estimate, not a forecast of direction — the direction comes from the plan.")

// Regime
i_regime_adx_len  = input.int(14, "ADX Length", minval=5, maxval=30, group=GROUP_REGIME, tooltip="ADX period for trend strength")
i_regime_bb_len   = input.int(20, "BB Length", minval=10, maxval=50, group=GROUP_REGIME, tooltip="BB period for squeeze detection")
i_regime_ema_len  = input.int(50, "EMA Slope Length", minval=20, maxval=100, group=GROUP_REGIME, tooltip="EMA period for slope calculation")

// Zone Detection toggles
i_enable_swing   = input.bool(true,  "📐 Swing Pivots",  group=GROUP_ZONES, inline="det1", tooltip="Detect zones from swing pivots")
i_enable_ob      = input.bool(true,  "🧱 Order Blocks",  group=GROUP_ZONES, inline="det1", tooltip="📐 Swing Pivots — classic swing highs/lows (current TF + Daily + Weekly)\n🧱 Order Blocks — last candle before a strong impulsive move, confirmed by volume")
i_enable_vp      = input.bool(true,  "📊 Volume POC",    group=GROUP_ZONES, inline="det2", tooltip="Detect high-volume cluster zones")
i_enable_fvg     = input.bool(true,  "💨 FVG",           group=GROUP_ZONES, inline="det2", tooltip="📊 Volume POC — highest-volume price cluster (where most contracts traded)\n💨 FVG — Fair Value Gap: 3-candle imbalance where price left unfilled range")
i_enable_liq     = input.bool(true,  "💧 Liquidity",     group=GROUP_ZONES, inline="det3", tooltip="Detect equal-high/low liquidity pools")
i_enable_avwap   = input.bool(true,  "⚓ AVWAP",         group=GROUP_ZONES, inline="det3", tooltip="💧 Liquidity Pools — equal highs/lows where stop orders cluster (sweep targets)\n⚓ AVWAP — Anchored VWAP from gap+volume catalyst events (institutional fair value)")
i_max_zones      = input.int(20, "Max Zones", minval=5, maxval=60, group=GROUP_ZONES, inline="det4", tooltip="How many zones the engine keeps in memory. When full, the lowest-scoring zone is evicted (Weekly/Daily swings and Key Levels are protected from eviction).\n\nThis is the single biggest performance dial in the indicator: the touch tracker, the score engine, the warning scanner and the trade-plan search each walk this list, so the cost of everything scales with it.\n\nOnly the highest-scoring handful are ever drawn (see Show Top N Zones), so a large number here mostly buys memory depth, not more visible levels. Raise it only if you see zones being forgotten.")
i_gap_enable     = input.bool(true,  "🕳 Unfilled Gaps", group=GROUP_ZONES, inline="det5", tooltip="Price gaps between one bar's close and the next bar's open. Classified by size relative to ATR, not by a fixed percentage, so the classification transfers across assets and timeframes:\n\n🕳 Common (0.25-0.5 ATR) — noise, usually fills fast\n🕳 Runaway (0.5-1.5 ATR) — mid-move continuation, often holds\n🕳 Breakaway (>1.5 ATR) — a real regime change, rarely fills\n\nRegistered as a Key Level zone with the type shown on its label.")
i_enable_levels  = input.bool(true,  "🗓 Key Levels",   group=GROUP_ZONES, inline="det5", tooltip="Prior Day High/Low, Prior Week High/Low, and Premarket High/Low (stocks/futures).\n\nThese are the most widely-watched reference prices in the market — many traders react at these exact levels.")

// Swing Pivots
i_swing_left     = input.int(5,  "Left Bars",  minval=2, maxval=20, group=GROUP_SWING, inline="sw1", tooltip="Left bars for pivot confirmation")
i_swing_right    = input.int(5,  "Right Bars", minval=2, maxval=20, group=GROUP_SWING, inline="sw1", tooltip="Left Bars — how many bars to the left must be lower (for high) or higher (for low)\nRight Bars — how many bars to the right confirm the pivot (no-repaint: zones register with delay equal to this value)\n\nDefault 5/5 = solid detection with minimal lag")
i_swing_zone_pct = input.float(0.5, "Zone Width (ATR)", minval=0.05, maxval=1.5, step=0.05, group=GROUP_SWING, tooltip="Zone box height as a fraction of ATR.\n\n0.25 = zone spans 25% of ATR\n0.5  = wider zones, good for daily charts (default)\n0.1  = tight zones, good for intraday\n\nATR = Average True Range (daily volatility)")

// Order Blocks
i_ob_lookback    = input.int(60, "OB Lookback", minval=5, maxval=100, group=GROUP_OB, tooltip="Bars to scan for order block formations")
i_ob_min_move    = input.float(1.5, "Min Move %", minval=0.5, maxval=10.0, step=0.25, group=GROUP_OB, tooltip="Minimum impulsive move % to qualify OB")
i_ob_vol_mult    = input.float(1.5, "Volume Mult", minval=1.0, maxval=5.0, step=0.1, group=GROUP_OB, tooltip="Min volume ratio vs average at formation")

// Volume POC
i_vp_lookback    = input.int(100, "POC Lookback", minval=20, maxval=200, group=GROUP_VOLPROF, tooltip="Bars for volume-at-price histogram")
i_vp_num_bins    = input.int(20, "Price Bins",   minval=10, maxval=40, group=GROUP_VOLPROF, tooltip="Price resolution for histogram")

// Fair Value Gaps
i_fvg_min_size   = input.float(0.3, "Min FVG Size %", minval=0.1, maxval=3.0, step=0.1, group=GROUP_FVG, tooltip="Minimum gap size as percent of price")
i_fvg_show_filled = input.bool(false, "Keep Filled FVGs", group=GROUP_FVG, tooltip="Keep showing FVG zones after price fills them")

// Liquidity Pools
i_liq_length     = input.int(20, "Swing Length", minval=3, maxval=30, group=GROUP_LIQ, tooltip="Bars to look back for equal high/low clusters")
i_liq_tolerance  = input.float(0.1, "Touch Tolerance %", minval=0.05, maxval=0.5, step=0.05, group=GROUP_LIQ, tooltip="Price tolerance (%) to consider two highs/lows as equal")

// Anchored VWAP
i_avwap_auto     = input.bool(true, "Auto-Anchor on Gap+Volume", group=GROUP_AVWAP, tooltip="Auto-anchor VWAP when gap > 3% and volume > 3x average")
i_avwap_gap_pct  = input.float(3.0, "Auto-Anchor Gap %", minval=1.0, maxval=20.0, step=0.5, group=GROUP_AVWAP, tooltip="Minimum gap % to trigger auto-anchor")
i_avwap_vol_mult = input.float(3.0, "Auto-Anchor Vol Mult", minval=1.5, maxval=10.0, step=0.5, group=GROUP_AVWAP, tooltip="Min volume multiplier to trigger auto-anchor")
i_avwap_date     = input.time(0, "Custom Catalyst Date", group=GROUP_AVWAP, confirm=false, tooltip="Set a specific catalyst date (earnings, FDA, halving, FOMC)\nLeave at 0 to disable manual anchor")

// Scoring weights
i_w_touch_vol    = input.int(18, "Touch Volume Weight",    minval=0, maxval=30, group=GROUP_SCORE, tooltip="Per-touch volume conviction (unique vs competitors)")
i_w_confluence   = input.int(18, "Confluence Weight",      minval=0, maxval=30, group=GROUP_SCORE, tooltip="Multi-source zone overlap score")
i_w_htf          = input.int(16, "HTF Weight",             minval=0, maxval=30, group=GROUP_SCORE, tooltip="Higher timeframe origin bonus")
i_w_touch        = input.int(12, "Touch Count Weight",     minval=0, maxval=30, group=GROUP_SCORE, tooltip="Number of price reactions")
i_w_create_vol   = input.int(12, "Creation Volume Weight", minval=0, maxval=30, group=GROUP_SCORE, tooltip="Volume at zone creation")
i_w_regime       = input.int(12, "Regime Fit Weight",      minval=0, maxval=30, group=GROUP_SCORE, tooltip="Alignment with market regime direction")
i_w_fresh        = input.int(8,  "Freshness Weight",       minval=0, maxval=20, group=GROUP_SCORE, tooltip="Untouched or recently touched bonus")
i_bounce_confirm_bars = input.int(3, "Bounce Confirm Bars", minval=1, maxval=10, group=GROUP_SCORE, tooltip="Bars to wait after a zone touch before judging bounce vs break.\n\nMeasures the actual REACTION, not the touching bar itself (which is often still noisy or still inside the zone).\n\n3 = responsive confirmation\n5-10 = stricter, fewer false positives on choppy charts")

// Asset Engine
i_asset_override = input.string("Auto", "Asset Class", options=["Auto", "Stock", "Crypto", "Forex", "Index", "Futures"], group=GROUP_ASSET, tooltip="Auto-detects asset class.\n\nCrypto: 24/7, percent bands\nForex: pip widths, session zones\nIndex: volume-agnostic fallback\nFutures: rollover-aware")
i_sub5_override  = input.bool(false, "Force Sub-$5 Mode", group=GROUP_ASSET, tooltip="Forces percent-band zone widths for low-price securities")

// Warnings
i_warn_approach  = input.bool(true, "Zone Approach",    group=GROUP_WARN, inline="w1", tooltip="Alert when within 0.5 ATR of Grade A/B zone")
i_warn_cluster   = input.bool(true, "Zone Cluster",     group=GROUP_WARN, inline="w1", tooltip="Zone Approach — fires when price is within the ATR distance you set below of any Grade A or B zone\nZone Cluster — fires when 3 or more zones overlap within 1 ATR of current price (clustered S/R = strong area)")
i_warn_sweep     = input.bool(true, "Sweep Imminent",   group=GROUP_WARN, inline="w2", tooltip="Alert when approaching liquidity pool")
i_warn_fvg       = input.bool(true, "FVG Filling",      group=GROUP_WARN, inline="w2", tooltip="Sweep Imminent — price is within 0.3 ATR of a Liquidity Pool zone AND volume is accelerating (likely stop hunt)\nFVG Filling — price has entered an unfilled Fair Value Gap zone for the first time")
i_warn_trap      = input.bool(true, "Trap Suspected",   group=GROUP_WARN, inline="w3", tooltip="Alert when close-through is low-volume (likely fake)")
i_warn_regime    = input.bool(true, "Regime Shift",     group=GROUP_WARN, inline="w3", tooltip="Trap Suspected — price closed through a zone on below-average volume (fake breakout pattern — often reverses)\nRegime Shift — market regime just changed direction AND a Grade-A zone is nearby (high-significance event)")
i_warn_flip      = input.bool(true, "Flip Retest",      group=GROUP_WARN, inline="w4", tooltip="Alert when price retests a zone that previously flipped polarity (former support now resistance, or vice versa).\n\nThis is a classic high-probability continuation setup — the old level is being defended/rejected from its new side.")
i_warn_atr_dist  = input.float(0.5, "Approach Distance (ATR)", minval=0.1, maxval=2.0, step=0.1, group=GROUP_WARN, tooltip="ATR distance to trigger ZONE_APPROACH warning")

// Visual
i_top_n_zones    = input.int(10, "Show Top N Zones", minval=3, maxval=20, group=GROUP_VISUAL, inline="vis1", tooltip="Show only N highest-scoring zones")
i_adaptive_hide  = input.bool(true, "Adaptive Hide",  group=GROUP_VISUAL, inline="vis1", tooltip="Show Top N — render only the N highest-scored zones (sorted by score 0-100). Reduces clutter. Default 10.\nAdaptive Hide — automatically hides zones more than 2.5 ATR from current price. Keeps chart clean as price moves.")
i_show_grade_d   = input.bool(false, "Show Grade D",  group=GROUP_VISUAL, inline="vis2", tooltip="Include low-quality zones in rendering")
i_zone_transp    = input.int(70, "Transparency",      minval=30, maxval=90, group=GROUP_VISUAL, inline="vis2", tooltip="Show Grade D — include very weak zones (score <50). OFF by default — they add clutter.\nTransparency — box fill opacity. 30 = nearly opaque (vivid), 90 = almost invisible. Default 70.")
i_show_simple    = input.bool(true, "Simple S/R Lines on Chart", group=GROUP_VISUAL, tooltip="Show clear horizontal lines for nearest Support and Resistance directly on chart.\n\nGreen line = nearest SUPPORT below price\nRed line = nearest RESISTANCE above price\nLabel shows price + ATR distance\n\nFor quick reading — no detailed analysis needed.")

// Dashboard
i_show_dash      = input.bool(true, "Show Dashboard", group=GROUP_DASH)
i_show_legend    = input.bool(false, "Show Legend",   group=GROUP_DASH, tooltip="A second panel decoding every symbol on the chart: zone sources, colours, label anatomy, grades, lines and setup states.\n\nOff by default — turn it on while you are learning the chart, then off again to reclaim the space.")
i_dash_detail    = input.string("Compact", "Detail", options=["Compact", "Full"], group=GROUP_DASH, inline="dash2", tooltip="Compact — the 7 rows you act on: Regime, Structure, Nearest R, Nearest S, Warning, Entry Trigger, Active Setup.\n\nFull — all 18 rows, adding Asset/Session, HTF Bias, zone counts, ATR rank, AVWAP, Squeeze, Zone Hit Rate, active sources, Scenario, Adaptive Weights and Setup Accuracy.\n\nEvery hidden row is still calculated — this only changes what is displayed.")
i_dash_pos       = input.string("Top Right", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=GROUP_DASH, inline="dash")
i_dash_size      = input.string("Normal", "Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=GROUP_DASH, inline="dash", tooltip="Position — where the dashboard table appears on the chart (9 options)\nSize — text size inside the dashboard. Normal = default readable. Large if chart is large, Tiny if you want minimal footprint.")

// Alerts
i_alert_json     = input.bool(false, "Structured JSON Alerts", group=GROUP_ALERTS, tooltip="Include JSON payload in alerts for webhook automation\n\n{brand, ticker, tf, price, atr, regime, warning, zone{id,source,score,grade,confluence}}")

GROUP_TRADE = "💰 Trade Plan ══════════════════════════════════════"
i_enable_trade_plan = input.bool(true, "Enable Trade Plan", group=GROUP_TRADE, tooltip="Automatically calculates Entry, Stop Loss, Target, and Position Size for the best setup near price.\n\nOnly shows trades that meet the minimum R:R requirement.\n\nLONG = price approaching support from above\nSHORT = price approaching resistance from below")
i_account_size      = input.float(10000, "Account Size ($)", minval=100, maxval=10000000, step=1000, group=GROUP_TRADE, tooltip="Total account value in dollars.\n\nUsed to calculate how many shares to buy based on your risk per trade.\n\nExample: $10,000 account × 1% risk = $100 risk per trade")
i_risk_pct          = input.float(1.0, "Risk per Trade (%)", minval=0.1, maxval=5.0, step=0.1, group=GROUP_TRADE, tooltip="How much of your account to risk on each trade.\n\n1.0% = standard professional\n0.5% = conservative\n2.0% = aggressive\n\nFormula: (Account × Risk%) / (Entry - Stop) = Shares")
i_min_rr            = input.float(2.0, "Min R:R to Show", minval=1.0, maxval=5.0, step=0.5, group=GROUP_TRADE, tooltip="Minimum Risk:Reward ratio to display a trade plan.\n\nOnly setups where Target gives this R:R or better will be shown.\n\n2.0 = target must be 2× the stop distance away\n1.5 = looser filter, more setups shown")

// ═══════════════════════════════════════════════════════════
// M0 — TRADING MODE RESOLVER (1-click preset)
// ═══════════════════════════════════════════════════════════
// Resolves the Trading Mode into effective detector parameters. The preset SCALES the user's own
// input values rather than replacing them, so manual tuning still works. Swing is the identity
// case (all multipliers 1.0) — it reproduces the raw inputs exactly.
// Must sit above every consumer: get_zone_width(), the MTF hub's pivot calls, and M3a-M3g.

tf_sec   = timeframe.in_seconds(timeframe.period)
eff_mode = i_trading_mode != "Auto" ? i_trading_mode : tf_sec <= 900 ? "Scalp" : tf_sec <= 14400 ? "Intraday" : "Swing"

mode_w  = eff_mode == "Scalp" ? 0.45 : eff_mode == "Intraday" ? 0.70 : 1.0   // zone width
mode_p  = eff_mode == "Scalp" ? 0.60 : eff_mode == "Intraday" ? 0.80 : 1.0   // pivot legs
mode_lb = eff_mode == "Scalp" ? 0.50 : eff_mode == "Intraday" ? 0.75 : 1.0   // detector lookbacks
mode_cf = eff_mode == "Scalp" ? 0.67 : 1.0                                    // bounce-confirm bars
mode_ap = eff_mode == "Scalp" ? 0.60 : eff_mode == "Intraday" ? 0.80 : 1.0   // approach distance

e_zone_pct     = i_swing_zone_pct * mode_w
e_swing_left   = math.max(2,  int(math.round(i_swing_left  * mode_p)))
e_swing_right  = math.max(2,  int(math.round(i_swing_right * mode_p)))
e_ob_lookback  = math.max(5,  int(math.round(i_ob_lookback * mode_lb)))
e_vp_lookback  = math.max(20, int(math.round(i_vp_lookback * mode_lb)))
e_liq_length   = math.max(3,  int(math.round(i_liq_length  * mode_lb)))
e_confirm_bars = math.max(1,  int(math.round(i_bounce_confirm_bars * mode_cf)))
e_warn_dist    = i_warn_atr_dist * mode_ap

// ═══════════════════════════════════════════════════════════
// GLOBAL VARIABLES
// ═══════════════════════════════════════════════════════════

var array<SRZone> g_zones       = array.new<SRZone>()
var array<int>    g_zone_id_arr = array.from(0)
var string        g_warning  = "—"
var int           g_warn_bar = 0
var float         g_avwap_anchor_price = na
var float         g_avwap_cum_pv = 0.0
var float         g_avwap_cum_v  = 0.0
var int           g_avwap_anchor_bar = -1
var string        g_avwap_label = ""
var int           g_hits_total  = 0
var int           g_tests_total = 0

// ── Adaptive Weight Learning Accumulators ──
// Separate tracking for bounce events vs break events, per scoring factor
var float g_lb_vol   = 0.0   // sum of touch_vol_avg on BOUNCE events
var float g_lb_htf   = 0.0   // sum of htf_n on BOUNCE events
var float g_lb_conf  = 0.0   // sum of confluence_n on BOUNCE events
var float g_lb_fresh = 0.0   // sum of fresh_n on BOUNCE events
var float g_lbr_vol  = 0.0   // sum of touch_vol_avg on BREAK events
var float g_lbr_htf  = 0.0
var float g_lbr_conf = 0.0
var float g_lb_struct  = 0.0  // sum of structure agreement on BOUNCE events
var float g_lbr_struct = 0.0  // sum of structure agreement on BREAK events
var float g_lbr_fresh = 0.0
var int   g_n_bounce = 0     // total bounce events observed
var int   g_n_break  = 0     // total break events observed

// ── Trade Plan Generator state ──
var string g_tp_dir    = "—"
var float  g_tp_entry  = na
var float  g_tp_stop   = na
var float  g_tp_target = na
var float  g_tp_rr     = na
var int    g_tp_shares = 0
var float  g_tp_score  = 0.0
var line   tp_proj_ln  = na
var label  tp_proj_lbl = na
var line   tp_entry_ln = na
var line   tp_stop_ln  = na
var line   tp_tgt_ln   = na
var label  tp_plan_lbl = na
var bool   g_tp_vs_struct    = false // current plan fights the market structure — shown, but flagged
var bool   g_tp_vs_mtf       = false // current plan fights the higher-timeframe bias
var bool   g_tp_dryup        = false // volume dried up as price reached the zone (a positive)
var string g_tp_state        = "—"   // APPROACH (far) | WAIT (at zone, no trigger) | READY (trigger fired)
var string g_tp_trigger      = "—"   // which candle pattern armed it
var float  g_tp_dist_atr     = na    // distance from price to the setup's zone edge, in ATR
var int    g_tp_zone_id      = -1   // id of the zone backing the current plan (dedup key for alerts)
var string g_tp_last_dir     = "—"  // last direction we actually alerted on
var int    g_tp_last_zone_id = -1   // last zone id we actually alerted on

// ═══════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════

get_table_pos(p) =>
    p == "Top Left" ? position.top_left : p == "Top Center" ? position.top_center : p == "Top Right" ? position.top_right : p == "Middle Left" ? position.middle_left : p == "Middle Center" ? position.middle_center : p == "Middle Right" ? position.middle_right : p == "Bottom Left" ? position.bottom_left : p == "Bottom Center" ? position.bottom_center : position.bottom_right

// Legend sits on the same horizontal side as the dashboard, at the opposite vertical end, so the
// two tables can never overlap and no extra position input is needed.
get_legend_pos(p) =>
    p == "Top Left" or p == "Middle Left" ? position.bottom_left : p == "Top Center" or p == "Middle Center" ? position.bottom_center : p == "Top Right" or p == "Middle Right" ? position.bottom_right : p == "Bottom Left" ? position.top_left : p == "Bottom Center" ? position.top_center : position.top_right

get_text_size(s) =>
    s == "Auto" ? size.auto : s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.huge

get_regime_color(r) =>
    r == "STRONG_BULL" ? color.new(#26a69a, 20) : r == "WEAK_BULL" ? color.new(#66bb6a, 30) : r == "SQUEEZE" ? color.new(#ab47bc, 20) : r == "STRONG_BEAR" ? color.new(#ef5350, 20) : r == "WEAK_BEAR" ? color.new(#ff7043, 30) : color.new(color.gray, 30)

// Heat-map neon color palette — score drives intensity, polarity drives hue
get_heat_color(score, is_sup, transp) =>
    if is_sup
        score >= 80 ? color.new(#00e5ff, transp) : score >= 65 ? color.new(#00c853, transp) : score >= 50 ? color.new(#40c4ff, transp) : score >= 35 ? color.new(#80deea, transp) : color.new(#546e7a, transp)
    else
        score >= 80 ? color.new(#ff1744, transp) : score >= 65 ? color.new(#ff5722, transp) : score >= 50 ? color.new(#ff9800, transp) : score >= 35 ? color.new(#ef9a9a, transp) : color.new(#78909c, transp)

get_border_color_grade(grade) =>
    grade == "A" ? color.new(#ffffff, 5) : grade == "B" ? color.new(#e0e0e0, 35) : color.new(color.gray, 60)

get_border_w(htf) => htf == "W" or htf == "M" ? 3 : htf == "D" ? 2 : 1
get_grade(s) => s >= 80 ? "A" : s >= 65 ? "B" : s >= 50 ? "C" : "D"
get_src_emoji(src) => src == "SWING" ? "📐" : src == "OB" ? "🧱" : src == "POC" ? "📊" : src == "FVG" ? "💨" : src == "LIQ" ? "💧" : src == "AVWAP" ? "⚓" : "🗓"

// ── ADAPTIVE WEIGHT ENGINE ──
// Returns calibrated weight: if factor was higher on bounces than breaks → increase weight.
// Requires min 10 obs per side; falls back to base_w until enough data.
calc_adaptive_w(base_w, b_sum, br_sum, n_b, n_br) =>
    float aw = base_w
    if n_b >= 10 and n_br >= 10
        b_avg  = b_sum  / n_b
        br_avg = br_sum / n_br
        ratio  = b_avg / math.max(br_avg, 0.0001)
        // Power 0.6 dampens extreme swings; capped at 2.5× and floored at 0.4×
        aw    := math.max(base_w * 0.4, math.min(base_w * 2.5, base_w * math.pow(ratio, 0.6)))
    aw

// ── MOMENTUM CLASSIFIER (LEI-powered) ──
// Uses Luxy Energy Index to detect move exhaustion at zone touch.
// LEI ≥ 70 = exhausted move arriving at zone = BOUNCE setup (energy depleted)
// LEI ≤ 30 = energized move arriving at zone = BREAK risk
// Direction-aware: BREAK only signals when price is actually approaching the zone
// (support from above = declining price; resistance from below = rising price).
// Fallback to speed/volume when LEI is neutral or unavailable.
// Credits: LEI methodology © OrenLuxy (orenluxy/LuxyEnergyIndex/1)
classify_momentum(z_is_sup, dist_atr, z_touches, lei_val, vol_r, spd) =>
    string sig = "—"
    if dist_atr <= 1.2 and z_touches > 0
        // Verify price is moving toward the zone in the expected breakout direction
        approaching = z_is_sup ? (close < close[2]) : (close > close[2])
        fast_hi  = spd > 0.40 and vol_r > 1.50
        slow_low = spd < 0.20 and vol_r < 0.80
        if not na(lei_val)
            // LEI thresholds match the library's own zone definitions (0-30=Safe, 70-100=Exhaustion)
            if lei_val >= 70
                sig := "⬆ BOUNCE"    // Exhaustion zone: move depleted, bounce expected
            else if lei_val <= 30
                // Only signal BREAK when price is actually approaching; moving away = already bouncing
                sig := approaching ? "⚠ BREAK" : "⬆ BOUNCE"
            else if slow_low          // Neutral LEI — fallback to speed/volume
                sig := "⬆ BOUNCE"
            else if fast_hi
                sig := approaching ? "⚠ BREAK" : "—"
        else
            if slow_low
                sig := "⬆ BOUNCE"
            else if fast_hi
                sig := approaching ? "⚠ BREAK" : "—"
    sig

// ═══════════════════════════════════════════════════════════
// M11 — UNIVERSAL ASSET ENGINE
// ═══════════════════════════════════════════════════════════

detect_asset_class() =>
    if i_asset_override != "Auto"
        i_asset_override
    else
        t = syminfo.type
        t == "crypto" ? "Crypto" : t == "forex" or t == "spread" ? "Forex" : t == "index" ? "Index" : t == "futures" or t == "economic" ? "Futures" : "Stock"

var string g_asset   = "Stock"
var bool   g_sub5    = false
var bool   g_crypto  = false
var bool   g_forex   = false
var bool   g_index   = false
var string g_session = "RTH"

if barstate.isfirst
    g_asset  := detect_asset_class()
    g_sub5   := i_sub5_override or (g_asset == "Stock" and close < 1.0)
    g_crypto := g_asset == "Crypto"
    g_forex  := g_asset == "Forex"
    g_index  := g_asset == "Index"

// Session detection for stocks (ET timezone)
if g_asset == "Stock" or g_asset == "Futures"
    session_regular = not na(time("1", "0930-1600:23456", "America/New_York"))
    session_pre     = not na(time("1", "0400-0930:23456", "America/New_York"))
    g_session := session_regular ? "RTH" : session_pre ? "PRE" : "AH"

get_zone_width(atr_v) =>
    g_sub5 ? close * e_zone_pct * 0.01 : atr_v * e_zone_pct

// ═══════════════════════════════════════════════════════════
// M1 — REGIME CLASSIFIER
// ═══════════════════════════════════════════════════════════

atr_val              = ta.atr(14)
[bb_mid, bb_up, bb_dn] = ta.bb(close, i_regime_bb_len, 2.0)
bbw                  = (bb_up - bb_dn) / bb_mid * 100.0
bbw_rank             = ta.percentrank(bbw, 100)
atr_pct              = atr_val / close * 100.0
atr_rank             = ta.percentrank(atr_pct, 100)
[dmi_plus, dmi_minus, adx_val] = ta.dmi(i_regime_adx_len, i_regime_adx_len)
ema50                = ta.ema(close, i_regime_ema_len)
ema_slope            = (ema50 - ema50[5]) / ema50[5] * 100.0
is_squeeze           = bbw_rank < 10 and atr_rank < 15

regime_state = is_squeeze ? "SQUEEZE" : adx_val > 25 and ema_slope > 0.5 ? "STRONG_BULL" : adx_val > 18 and ema_slope > 0.1 ? "WEAK_BULL" : adx_val > 25 and ema_slope < -0.5 ? "STRONG_BEAR" : adx_val > 18 and ema_slope < -0.1 ? "WEAK_BEAR" : "RANGE"
var string prev_regime = "RANGE"

// ═══════════════════════════════════════════════════════════
// M2 — MTF DATA HUB
// ═══════════════════════════════════════════════════════════

// One call per higher timeframe, not one per value. Every Daily figure the script needs comes back
// in a single tuple, and likewise Weekly — 10 request.security() calls collapsed into 2. Each call
// spins up and maintains its own higher-timeframe series, so this is the largest single load-time
// cost in the file after the loops.
[htf_d_v, htf_d_ph, htf_d_pl, pdh, pdl] = request.security(syminfo.tickerid, "D", [volume, ta.pivothigh(high, e_swing_left, e_swing_right), ta.pivotlow(low, e_swing_left, e_swing_right), high[1], low[1]], lookahead=barmerge.lookahead_off)
[htf_w_v, htf_w_ph, htf_w_pl, pwh, pwl] = request.security(syminfo.tickerid, "W", [volume, ta.pivothigh(high, e_swing_left, e_swing_right), ta.pivotlow(low, e_swing_left, e_swing_right), high[1], low[1]], lookahead=barmerge.lookahead_off)

avg_vol_20   = ta.sma(volume, 20)

// ── Higher-Timeframe Bias ──
// Auto climbs one meaningful step above the chart rather than a fixed multiple, so a 3m and a 5m
// chart both land on 1H instead of on 12m and 20m — timeframes nobody actually watches.
mtf_res    = i_mtf_tf != "Auto" ? i_mtf_tf : tf_sec <= 300 ? "60" : tf_sec <= 3600 ? "240" : tf_sec <= 14400 ? "D" : "W"
[mtf_c, mtf_e] = request.security(syminfo.tickerid, mtf_res, [close, ta.ema(close, i_mtf_len)], lookahead=barmerge.lookahead_off)
mtf_bias   = not i_mtf_enable or na(mtf_e) or na(mtf_c) ? "—" : mtf_c > mtf_e ? "BULL" : "BEAR"
// Distance from the HTF EMA in ATR — how committed the higher timeframe is, not just which side.
mtf_streth = na(mtf_e) or na(mtf_c) or atr_val <= 0 ? 0.0 : math.abs(mtf_c - mtf_e) / atr_val

// ── Volume Dry-Up ──
// Quiet before the move: the last 5 bars traded materially less than the 20-bar average.
vol_dryup  = avg_vol_20 > 0 and ta.sma(volume, 5) < avg_vol_20 * i_dryup_mult

// ── LEI-based Momentum Classifier inputs (© OrenLuxy — orenluxy/LuxyEnergyIndex/1) ──
// Extension-from-VWAP + Velocity + Volume → exhaustion score 0-100.
// LEI ≥ 65 = exhausted move → BOUNCE expected at zone
// LEI ≤ 35 = energized move → BREAK risk at zone
lei_value    = LEI.lei(close)
lei_zone_str = LEI.getZone(lei_value)
approach_spd = math.abs(close - close[2]) / math.max(atr_val, 0.0001)
vol_ratio    = volume / math.max(avg_vol_20, 1)

// ═══════════════════════════════════════════════════════════
// ZONE MANAGEMENT
// ═══════════════════════════════════════════════════════════

// Which detector types confirmed a zone — bitmask, one bit per source, used for real multi-source confluence
source_bit(src) =>
    src == "SWING" ? 1 : src == "OB" ? 2 : src == "POC" ? 4 : src == "FVG" ? 8 : src == "LIQ" ? 16 : src == "AVWAP" ? 32 : 64

// Pine has no usable bitwise operator/namespace (bitwise.and/or fail to parse — "and"/"or" are
// reserved keywords and can't follow a dot). Bit test/set done via plain division+modulo instead:
// mask is a sum of a subset of {1,2,4,8,16,32,64}, so floor(mask/v) % 2 tells if value v is "set".
mask_has_value(mask, bit_val) =>
    int(math.floor(mask / bit_val)) % 2 == 1

popcount7(mask) =>
    c = 0
    if mask_has_value(mask, 1)
        c += 1
    if mask_has_value(mask, 2)
        c += 1
    if mask_has_value(mask, 4)
        c += 1
    if mask_has_value(mask, 8)
        c += 1
    if mask_has_value(mask, 16)
        c += 1
    if mask_has_value(mask, 32)
        c += 1
    if mask_has_value(mask, 64)
        c += 1
    c

// Only matches zones on the SAME side (support/resistance) — a resistance detection near a support
// zone is a different structural level, not confirming evidence, so it must not merge into it.
find_zone_idx_near(price_level, half_width, supp) =>
    idx = -1
    n = array.size(g_zones)
    if n > 0
        for i = 0 to n - 1
            z = array.get(g_zones, i)
            if z.is_support == supp and math.abs(z.mid - price_level) < half_width * 2
                idx := i
                break
    idx

// A second detector confirming an already-registered zone is a stronger signal than a duplicate box — merge it in
reinforce_zone(idx, src, vol_at_event, cat_label) =>
    z   = array.get(g_zones, idx)
    bit = source_bit(src)
    z.sources_mask := mask_has_value(z.sources_mask, bit) ? z.sources_mask : z.sources_mask + bit
    vn = avg_vol_20 > 0 ? vol_at_event / avg_vol_20 : z.creation_volume
    z.creation_volume := math.max(z.creation_volume, vn)
    if z.catalyst_label == "" and cat_label != ""
        z.catalyst_label := cat_label
    array.set(g_zones, idx, z)

push_zone(src, z_top, z_bot, htf, supp, vol_at_creation, cat_label) =>
    if array.size(g_zones) >= i_max_zones
        // Structural levels (Weekly/Daily swings, Key Levels) are cheap to re-detect and stay
        // relevant regardless of current regime bias — evict from the rest of the pool first,
        // so e.g. a strong uptrend doesn't silently starve every overhead resistance out of memory.
        min_idx      = 0
        min_score    = 999.0
        any_evictable = false
        for i = 0 to array.size(g_zones) - 1
            zc        = array.get(g_zones, i)
            protected = zc.htf_source == "W" or zc.htf_source == "D" or zc.source == "LEVEL"
            if not protected
                any_evictable := true
                if zc.score < min_score
                    min_score := zc.score
                    min_idx   := i
        if not any_evictable
            for i = 0 to array.size(g_zones) - 1
                zs = array.get(g_zones, i).score
                if zs < min_score
                    min_score := zs
                    min_idx   := i
        array.remove(g_zones, min_idx)
    cur_id = array.get(g_zone_id_arr, 0) + 1
    array.set(g_zone_id_arr, 0, cur_id)
    vol_norm = avg_vol_20 > 0 ? vol_at_creation / avg_vol_20 : 1.0
    nz = SRZone.new(id=cur_id, source=src, top=z_top, bottom=z_bot, mid=(z_top+z_bot)/2, bar_created=bar_index, htf_source=htf, is_support=supp, is_fresh=true, touches=0, violations=0, flip_count=0, creation_volume=vol_norm, touch_vol_avg=0.0, width_atr=(z_top-z_bot)/math.max(atr_val,0.0001), last_touch_bar=bar_index, confluence_count=1, score=50.0, grade="C", regime_at_creation=regime_state, is_naked_poc=false, catalyst_label=cat_label, box_id=-1, label_id=-1, bounce_count=0, break_count=0, avg_dist_at_touch_atr=0.0, momentum_signal="—", sources_mask=source_bit(src), pending_check_bar=-1, pending_expect_support=supp)
    array.push(g_zones, nz)

// Single entry point for all detectors: merges into a nearby zone instead of silently dropping a confirming detection
register_zone(src, z_top, z_bot, htf, supp, vol_at_event, cat_label, near_thresh) =>
    mid = (z_top + z_bot) / 2
    idx = find_zone_idx_near(mid, near_thresh, supp)
    if idx == -1
        push_zone(src, z_top, z_bot, htf, supp, vol_at_event, cat_label)
    else
        reinforce_zone(idx, src, vol_at_event, cat_label)

// ═══════════════════════════════════════════════════════════
// M0b — MARKET STRUCTURE ENGINE (BOS / CHoCH)
// ═══════════════════════════════════════════════════════════
// Pivots are computed here at top level rather than inside the Swing detector, so structure keeps
// working when 📐 Swing Pivots is toggled off. M3a below reuses these same two values.
//
// BOS   = price breaks a swing in the direction the structure already points → continuation.
// CHoCH = price breaks a swing against the structure → first evidence the trend is turning.
//
// A broken level is flagged (ms_ph_broken / ms_pl_broken) rather than cleared, so the event fires
// once per structure change instead of every bar price stays beyond it — while the pivot price
// itself survives for the HH/HL/LH/LL comparison against the next pivot.

ph_curr = ta.pivothigh(high, e_swing_left, e_swing_right)
pl_curr = ta.pivotlow(low,   e_swing_left, e_swing_right)

var float  ms_last_ph   = na
var float  ms_last_pl   = na
var bool   ms_ph_broken = false
var bool   ms_pl_broken = false
var string ms_trend     = "RANGE"   // BULL | BEAR | RANGE
var string ms_event     = "—"       // last structural event, e.g. "CHoCH ⬆"
var int    ms_event_bar = -1        // -1 = no event yet, so bar 0 never reads as a fresh break
var string ms_swing_lbl = "—"       // HH / HL / LH / LL of the latest confirmed pivot

bool ms_choch_now = false

if i_ms_enable
    if not na(ph_curr)
        if not na(ms_last_ph)
            ms_swing_lbl := ph_curr > ms_last_ph ? "HH" : "LH"
        ms_last_ph   := ph_curr
        ms_ph_broken := false
    if not na(pl_curr)
        if not na(ms_last_pl)
            ms_swing_lbl := pl_curr > ms_last_pl ? "HL" : "LL"
        ms_last_pl   := pl_curr
        ms_pl_broken := false
    // Judged on confirmed closes only — an intrabar wick through a swing is not a structure break.
    if barstate.isconfirmed
        if not na(ms_last_ph) and close > ms_last_ph and not ms_ph_broken
            ms_choch_now := ms_trend == "BEAR"
            ms_event     := ms_choch_now ? "CHoCH ⬆" : "BOS ⬆"
            ms_trend     := "BULL"
            ms_event_bar := bar_index
            ms_ph_broken := true
        else if not na(ms_last_pl) and close < ms_last_pl and not ms_pl_broken
            ms_choch_now := ms_trend == "BULL"
            ms_event     := ms_choch_now ? "CHoCH ⬇" : "BOS ⬇"
            ms_trend     := "BEAR"
            ms_event_bar := bar_index
            ms_pl_broken := true

// The unbroken swing whose break would flip the structure — the one level actually worth watching.
ms_up_lvl = ms_ph_broken ? na : ms_last_ph
ms_dn_lvl = ms_pl_broken ? na : ms_last_pl
ms_watch  = ms_trend == "BULL" ? ms_dn_lvl : ms_trend == "BEAR" ? ms_up_lvl : na(ms_up_lvl) ? ms_dn_lvl : na(ms_dn_lvl) ? ms_up_lvl : math.abs(close - ms_up_lvl) < math.abs(close - ms_dn_lvl) ? ms_up_lvl : ms_dn_lvl

// ═══════════════════════════════════════════════════════════
// M0c — CANDLE ENTRY TRIGGER
// ═══════════════════════════════════════════════════════════
// The zone says WHERE, the candle says WHEN. Three patterns, any one of which is enough.
// Deliberately a GATE on the trade plan and never a score component: a reversal candle inside an
// order block is the same event the zone already scored, so scoring it again double-counts it.
// Latched only on confirmed bars — an unclosed candle is not a pattern yet.

c_body    = math.abs(close - open)
c_range   = math.max(high - low, syminfo.mintick)
c_up_wick = high - math.max(close, open)
c_dn_wick = math.min(close, open) - low

// Engulfing — this body fully covers the previous body, opposite direction, and is bigger.
bull_engulf = i_trig_engulf and close > open and close[1] < open[1] and close >= open[1] and open <= close[1] and c_body > c_body[1]
bear_engulf = i_trig_engulf and close < open and close[1] > open[1] and close <= open[1] and open >= close[1] and c_body > c_body[1]
// Pin bar — long rejection wick, small body, close pushed back into the upper (or lower) half.
bull_pin    = i_trig_pin and c_dn_wick >= c_range * i_trig_pin_pct and c_body <= c_range * 0.35 and close >= low + c_range * 0.5
bear_pin    = i_trig_pin and c_up_wick >= c_range * i_trig_pin_pct and c_body <= c_range * 0.35 and close <= high - c_range * 0.5
// Inside-bar break — previous bar compressed inside the one before it, now released.
c_inside    = high[1] <= high[2] and low[1] >= low[2]
bull_inside = i_trig_inside and c_inside and close > high[1]
bear_inside = i_trig_inside and c_inside and close < low[1]

bull_trigger = bull_engulf or bull_pin or bull_inside
bear_trigger = bear_engulf or bear_pin or bear_inside

var int    last_bull_trig = -10000
var int    last_bear_trig = -10000
var string last_trig_name = "—"

if barstate.isconfirmed
    if bull_trigger
        last_bull_trig := bar_index
        last_trig_name := bull_engulf ? "Engulfing ⬆" : bull_pin ? "Pin Bar ⬆" : "Inside Break ⬆"
    if bear_trigger
        last_bear_trig := bar_index
        last_trig_name := bear_engulf ? "Engulfing ⬇" : bear_pin ? "Pin Bar ⬇" : "Inside Break ⬇"

trig_bull_fresh = bar_index - last_bull_trig <= i_trig_lookback
trig_bear_fresh = bar_index - last_bear_trig <= i_trig_lookback

// ═══════════════════════════════════════════════════════════
// M3a — SWING PIVOT DETECTOR
// ═══════════════════════════════════════════════════════════

if i_enable_swing
    zw      = get_zone_width(atr_val)
    if not na(ph_curr)
        register_zone("SWING", ph_curr + zw * 0.5, ph_curr - zw * 0.5, timeframe.period, false, volume[e_swing_right], "", zw)
    if not na(pl_curr)
        register_zone("SWING", pl_curr + zw * 0.5, pl_curr - zw * 0.5, timeframe.period, true, volume[e_swing_right], "", zw)
    zw_d = zw * 1.5
    if not na(htf_d_ph)
        register_zone("SWING", htf_d_ph + zw_d * 0.5, htf_d_ph - zw_d * 0.5, "D", false, htf_d_v, "", zw_d)
    if not na(htf_d_pl)
        register_zone("SWING", htf_d_pl + zw_d * 0.5, htf_d_pl - zw_d * 0.5, "D", true, htf_d_v, "", zw_d)
    zw_w = zw * 2.0
    if not na(htf_w_ph)
        register_zone("SWING", htf_w_ph + zw_w * 0.5, htf_w_ph - zw_w * 0.5, "W", false, htf_w_v, "", zw_w)
    if not na(htf_w_pl)
        register_zone("SWING", htf_w_pl + zw_w * 0.5, htf_w_pl - zw_w * 0.5, "W", true, htf_w_v, "", zw_w)

// ═══════════════════════════════════════════════════════════
// M3c — ORDER BLOCK DETECTOR
// ═══════════════════════════════════════════════════════════

if i_enable_ob and bar_index >= e_ob_lookback
    avg_vol_ob = ta.sma(volume, e_ob_lookback)
    is_bear1   = close[1] < open[1]
    bull_move  = (close - open[1]) / math.max(open[1], 0.0001) * 100 >= i_ob_min_move
    vol_bull   = volume >= avg_vol_ob * i_ob_vol_mult
    // Displacement: impulsive candle must close above the recent structure (bars 2-5), not just the OB candle
    bull_disp  = close > math.max(high[2], math.max(high[3], math.max(high[4], high[5])))
    if is_bear1 and bull_move and vol_bull and bull_disp
        ob_t = math.max(open[1], close[1])
        ob_b = math.min(open[1], close[1])
        register_zone("OB", ob_t, ob_b, timeframe.period, true, volume[1], "", ob_t - ob_b)
    is_bull1  = close[1] > open[1]
    bear_move = (open[1] - close) / math.max(open[1], 0.0001) * 100 >= i_ob_min_move
    vol_bear  = volume >= avg_vol_ob * i_ob_vol_mult
    // Displacement: impulsive candle must close below the recent structure (bars 2-5)
    bear_disp  = close < math.min(low[2], math.min(low[3], math.min(low[4], low[5])))
    if is_bull1 and bear_move and vol_bear and bear_disp
        ob_t = math.max(open[1], close[1])
        ob_b = math.min(open[1], close[1])
        register_zone("OB", ob_t, ob_b, timeframe.period, false, volume[1], "", ob_t - ob_b)

// ═══════════════════════════════════════════════════════════
// M3b — VOLUME POC DETECTOR (runs every 5 bars for performance)
// ═══════════════════════════════════════════════════════════

// Allocated once and refilled per run, so the histogram never re-allocates on the hot path.
var array<float> vp_bins = array.new_float(i_vp_num_bins, 0.0)

// CORRECTNESS, not speed: a ta.* call inside a conditional only advances its internal window on the
// bars the branch is taken. Behind `bar_index % 5 == 0` these two saw one bar in five and returned a
// wrong range, which skewed every POC zone. Hoisted to run unconditionally; only the histogram fill
// below — the part that is actually expensive — stays throttled.
vp_h_all = ta.highest(high, e_vp_lookback)
vp_l_all = ta.lowest(low,   e_vp_lookback)

if i_enable_vp and bar_index >= e_vp_lookback and bar_index % 5 == 0
    vp_h = vp_h_all
    vp_l = vp_l_all
    bsz  = (vp_h - vp_l) / i_vp_num_bins
    if bsz > 0
        // One pass over the bars, dropping each into its bin — instead of re-scanning all
        // e_vp_lookback bars once per bin. Identical result, i_vp_num_bins times fewer iterations
        // (was 20 x 100 = 2,000 per run at defaults, now 120). This was the single heaviest block
        // in the script.
        array.fill(vp_bins, 0.0)
        for k = 0 to e_vp_lookback - 1
            bm = (high[k] + low[k]) / 2
            bi = math.max(0, math.min(i_vp_num_bins - 1, int(math.floor((bm - vp_l) / bsz))))
            array.set(vp_bins, bi, array.get(vp_bins, bi) + volume[k])
        max_bv  = 0.0
        poc_bin = 0
        for b = 0 to i_vp_num_bins - 1
            bv = array.get(vp_bins, b)
            if bv > max_bv
                max_bv  := bv
                poc_bin := b
        poc_price = vp_l + (poc_bin + 0.5) * bsz
        register_zone("POC", poc_price + bsz * 0.5, poc_price - bsz * 0.5, timeframe.period, close < poc_price, max_bv, "", bsz * 2)

// ═══════════════════════════════════════════════════════════
// M3d — FAIR VALUE GAP DETECTOR
// ═══════════════════════════════════════════════════════════

if i_enable_fvg and bar_index >= 2
    min_gap = close * i_fvg_min_size / 100.0
    // Bullish FVG: gap between bar[2].high and bar[0].low — middle bar[1] must be impulsive bullish
    bull_fvg_top = low[0]
    bull_fvg_bot = high[2]
    // Explicitly verify middle candle [1] is impulsive: bullish body ≥ 30% of ATR (rules out whipsaw gaps)
    bull_mid_impulsive = close[1] > open[1] and (close[1] - open[1]) >= atr_val * 0.3
    if bull_fvg_top > bull_fvg_bot and bull_fvg_top - bull_fvg_bot >= min_gap and bull_mid_impulsive
        register_zone("FVG", bull_fvg_top, bull_fvg_bot, timeframe.period, true, volume[1], "", (bull_fvg_top - bull_fvg_bot) * 0.5)
    // Bearish FVG: gap between bar[2].low and bar[0].high — middle bar[1] must be impulsive bearish
    bear_fvg_top = low[2]
    bear_fvg_bot = high[0]
    // Explicitly verify middle candle [1] is impulsive: bearish body ≥ 30% of ATR
    bear_mid_impulsive = close[1] < open[1] and (open[1] - close[1]) >= atr_val * 0.3
    if bear_fvg_top > bear_fvg_bot and bear_fvg_top - bear_fvg_bot >= min_gap and bear_mid_impulsive
        register_zone("FVG", bear_fvg_top, bear_fvg_bot, timeframe.period, false, volume[1], "", (bear_fvg_top - bear_fvg_bot) * 0.5)

// ═══════════════════════════════════════════════════════════
// M3f — LIQUIDITY POOL DETECTOR (equal highs / equal lows)
// ═══════════════════════════════════════════════════════════

// Same reason as the POC hoist above: this was called twice, each time inside an `if eq_count >= 2`
// branch, so its window only advanced on the bars a liquidity pool happened to register.
liq_vol_avg = ta.sma(volume, e_liq_length)

if i_enable_liq and bar_index >= e_liq_length
    tol      = close * i_liq_tolerance / 100.0
    liq_h    = ta.highest(high, e_liq_length)
    liq_l    = ta.lowest(low,   e_liq_length)
    // Count how many bars touched within tolerance of period high
    eq_h_count = 0
    eq_l_count = 0
    for k = 0 to e_liq_length - 1
        if math.abs(high[k] - liq_h) <= tol
            eq_h_count += 1
        if math.abs(low[k] - liq_l) <= tol
            eq_l_count += 1
    // Need at least 2 equal touches for a liquidity pool
    if eq_h_count >= 2
        register_zone("LIQ", liq_h + tol, liq_h - tol, timeframe.period, false, liq_vol_avg, "", tol * 2)
    if eq_l_count >= 2
        register_zone("LIQ", liq_l + tol, liq_l - tol, timeframe.period, true, liq_vol_avg, "", tol * 2)

// ═══════════════════════════════════════════════════════════
// M3g — KEY LEVELS (Prior Day/Week High-Low, Premarket)
// ═══════════════════════════════════════════════════════════

// pdh / pdl / pwh / pwl now arrive with the Daily and Weekly tuples in the MTF hub above.

var float g_pm_high = na
var float g_pm_low  = na
var int   g_pm_day  = -1

// ponytail: day-rollover uses chart timezone, not exchange timezone — fine since the premarket window itself is already NY-anchored below
if i_enable_levels and (g_asset == "Stock" or g_asset == "Futures")
    day_now = dayofmonth(time)
    if day_now != g_pm_day
        g_pm_day  := day_now
        g_pm_high := na
        g_pm_low  := na
    if g_session == "PRE"
        g_pm_high := na(g_pm_high) ? high : math.max(g_pm_high, high)
        g_pm_low  := na(g_pm_low)  ? low  : math.min(g_pm_low, low)

if i_enable_levels and bar_index % 20 == 0
    zw_lvl = get_zone_width(atr_val) * 0.6
    if not na(pdh)
        register_zone("LEVEL", pdh + zw_lvl * 0.5, pdh - zw_lvl * 0.5, "D", false, avg_vol_20, "PDH", zw_lvl)
    if not na(pdl)
        register_zone("LEVEL", pdl + zw_lvl * 0.5, pdl - zw_lvl * 0.5, "D", true,  avg_vol_20, "PDL", zw_lvl)
    if not na(pwh)
        register_zone("LEVEL", pwh + zw_lvl * 0.5, pwh - zw_lvl * 0.5, "W", false, avg_vol_20, "PWH", zw_lvl)
    if not na(pwl)
        register_zone("LEVEL", pwl + zw_lvl * 0.5, pwl - zw_lvl * 0.5, "W", true,  avg_vol_20, "PWL", zw_lvl)
    if not na(g_pm_high)
        register_zone("LEVEL", g_pm_high + zw_lvl * 0.5, g_pm_high - zw_lvl * 0.5, timeframe.period, false, avg_vol_20, "PMH", zw_lvl)
    if not na(g_pm_low)
        register_zone("LEVEL", g_pm_low + zw_lvl * 0.5, g_pm_low - zw_lvl * 0.5, timeframe.period, true, avg_vol_20, "PML", zw_lvl)

// ═══════════════════════════════════════════════════════════
// M3h — GAP CLASSIFIER
// ═══════════════════════════════════════════════════════════
// An unfilled gap is a real structural level: nobody traded inside it, so there is no accepted
// price there to defend. Sized against ATR rather than a fixed percent, so "Breakaway" means the
// same thing on a mega-cap and on a small-cap — the fixed-percent version of this idea does not
// survive a change of asset or timeframe.
// Registered through the existing LEVEL source so the confluence bitmask and popcount stay untouched.

gap_up_now = bar_index > 0 and low > high[1]
gap_dn_now = bar_index > 0 and high < low[1]
gap_h      = gap_up_now ? low - high[1] : gap_dn_now ? low[1] - high : 0.0
gap_atr    = atr_val > 0 ? gap_h / atr_val : 0.0
gap_kind   = gap_atr >= 1.5 ? "🕳 Breakaway" : gap_atr >= 0.5 ? "🕳 Runaway" : "🕳 Common"

if i_gap_enable and (gap_up_now or gap_dn_now) and gap_atr >= 0.25
    if gap_up_now
        register_zone("LEVEL", low, high[1], timeframe.period, true, volume, gap_kind, gap_h * 0.5)
    else
        register_zone("LEVEL", low[1], high, timeframe.period, false, volume, gap_kind, gap_h * 0.5)

// ═══════════════════════════════════════════════════════════
// M7 — AVWAP CATALYST ENGINE
// ═══════════════════════════════════════════════════════════

// Auto-anchor: gap > threshold + volume spike
gap_pct = bar_index > 0 ? math.abs(open - close[1]) / math.max(close[1], 0.0001) * 100 : 0.0
auto_anchor_trigger = i_enable_avwap and i_avwap_auto and gap_pct >= i_avwap_gap_pct and volume >= avg_vol_20 * i_avwap_vol_mult

// Manual anchor: user-specified catalyst date
manual_anchor_trigger = i_enable_avwap and i_avwap_date > 0 and time >= i_avwap_date and time[1] < i_avwap_date

if auto_anchor_trigger or manual_anchor_trigger
    g_avwap_anchor_bar   := bar_index
    g_avwap_cum_pv       := 0.0
    g_avwap_cum_v        := 0.0
    g_avwap_anchor_price := open
    g_avwap_label        := auto_anchor_trigger ? "Gap+" + str.tostring(math.round(gap_pct, 1)) + "%" : "Catalyst"

// Rolling AVWAP calculation
if g_avwap_anchor_bar >= 0 and bar_index >= g_avwap_anchor_bar
    typ_p              = (high + low + close) / 3
    g_avwap_cum_pv    += typ_p * volume
    g_avwap_cum_v     += volume

avwap_value = g_avwap_cum_v > 0 ? g_avwap_cum_pv / g_avwap_cum_v : na

// Register AVWAP as zone when value is established
if i_enable_avwap and not na(avwap_value) and bar_index % 10 == 0
    zw_av = get_zone_width(atr_val) * 0.8
    register_zone("AVWAP", avwap_value + zw_av * 0.5, avwap_value - zw_av * 0.5, timeframe.period, close < avwap_value, volume, g_avwap_label, zw_av * 3)

// Plot AVWAP line
plot(avwap_value, "AVWAP", color=color.new(#ab47bc, 30), linewidth=2, style=plot.style_line)

// AVWAP label on last bar — explains the purple line
var label avwap_label = na
if barstate.islast
    label.delete(avwap_label)
    if not na(avwap_value)
        avwap_label := label.new(bar_index + 3, avwap_value, "⚓ AVWAP  " + g_avwap_label, color=color.new(#ab47bc, 10), textcolor=color.white, style=label.style_label_left, size=size.small, tooltip="AVWAP = Anchored Volume-Weighted Average Price\n\nThis PURPLE LINE is the institutional fair value anchor.\nIt starts from: " + g_avwap_label + "\n\nPrice ABOVE AVWAP → trading at a premium (expensive)\nPrice BELOW AVWAP → trading at a discount (cheap)\n\nInstitutions use AVWAP as a reference price.\nZones near AVWAP are especially strong.\n\n── Why it matters ──\nWhen price returns to AVWAP = fair value magnet\nAVWAP breaks = significant shift in sentiment")

// ═══════════════════════════════════════════════════════════
// M6 — TOUCH & VIOLATION TRACKER + STATS
// ═══════════════════════════════════════════════════════════

// Shared by the bounce and break learning feeds — kept as one function so a future tuning only needs one edit
calc_learning_factors(z) =>
    htf_f   = z.htf_source == "W" ? 1.0 : z.htf_source == "D" ? 0.8 : 0.4
    conf_f  = math.min(z.confluence_count, 5) / 5.0
    fresh_f = z.is_fresh ? 1.0 : math.max(0.0, 1.0 - float(bar_index - z.last_touch_bar) / 300.0)
    // Structure agreement at the moment of the outcome — 1 = zone sided with the trend, 0 = fought it.
    struct_f = z.is_support ? (ms_trend == "BULL" ? 1.0 : ms_trend == "BEAR" ? 0.0 : 0.5) : (ms_trend == "BEAR" ? 1.0 : ms_trend == "BULL" ? 0.0 : 0.5)
    [htf_f, conf_f, fresh_f, struct_f]

// ── M6: Touch & Violation Tracker + Per-Zone Intelligence + Adaptive Learning ──
if array.size(g_zones) > 0
    for i = array.size(g_zones) - 1 to 0
        z           = array.get(g_zones, i)
        in_zone_now = low <= z.top and high >= z.bottom
        close_above = close > z.top
        close_below = close < z.bottom
        // Most zones are idle on most bars. Writing every one back to the array regardless was the
        // largest untouched cost in the file: 20 array.set of a user-defined type per bar, on every
        // bar of history, for objects nothing had changed.
        bool z_dirty = false

        if in_zone_now and bar_index > z.bar_created
            z_dirty         := true
            z.is_fresh      := false
            z.touches       += 1
            tvr              = avg_vol_20 > 0 ? volume / avg_vol_20 : 1.0
            z.touch_vol_avg := z.touches == 1 ? tvr : (z.touch_vol_avg * (z.touches - 1) + tvr) / z.touches
            z.last_touch_bar := bar_index
            g_tests_total   += 1
            // ponytail: only schedule if nothing is already pending — a re-touch before the scheduled bar must not
            // clobber the earlier touch's judgment (single-slot, not a queue: still only one eval per pending window)
            if z.pending_check_bar == -1
                z.pending_check_bar     := bar_index + e_confirm_bars
                z.pending_expect_support := z.is_support

        // Evaluate a matured touch: did price actually hold away from the zone N bars later?
        // Uses the polarity snapshotted at touch time — z.is_support may have flipped since (violations >= 2) and would judge the wrong direction otherwise.
        if z.pending_check_bar == bar_index
            z_dirty := true
            bounced = z.pending_expect_support ? close > z.mid : close < z.mid
            if bounced
                g_hits_total   += 1
                is_first_bounce = z.bounce_count == 0  // capture before incrementing
                z.bounce_count += 1
                // Distance from zone mid, measured after the reaction had time to develop — proxy for zone reaction strength
                b_dist = math.abs(close - z.mid) / math.max(atr_val, 0.0001)
                z.avg_dist_at_touch_atr := z.bounce_count == 1 ? b_dist : (z.avg_dist_at_touch_atr * (z.bounce_count - 1) + b_dist) / z.bounce_count
                // ── Feed Adaptive Learning accumulators — first bounce only (mirrors break logic: one entry per zone)
                // Feeding on every bounce would double-count zones that bounce multiple times before breaking.
                if is_first_bounce
                    [htf_f, conf_f, fresh_f, struct_f] = calc_learning_factors(z)
                    g_lb_vol    += z.touch_vol_avg
                    g_lb_htf    += htf_f
                    g_lb_conf   += conf_f
                    g_lb_fresh  += fresh_f
                    g_lb_struct += struct_f
                    g_n_bounce  += 1
            z.pending_check_bar := -1

        // Momentum only ever appears on the rendered bar's labels and tooltips. Computing it for
        // every zone on every historical bar was ~30 branchy function calls per bar producing a
        // string nothing reads until barstate.islast.
        if barstate.islast
            z_dirty := true
            z.momentum_signal := classify_momentum(z.is_support, math.abs(z.mid - close) / math.max(atr_val, 0.0001), z.touches, lei_value, vol_ratio, approach_spd)

        was_violated = z.is_support ? close_below : close_above
        if was_violated
            z_dirty      := true
            z.violations += 1
            if z.violations == 1
                // First confirmed break — record it for learning
                z.break_count += 1
                [htf_f, conf_f, fresh_f, struct_f] = calc_learning_factors(z)
                g_lbr_vol    += z.touch_vol_avg
                g_lbr_htf    += htf_f
                g_lbr_conf   += conf_f
                g_lbr_fresh  += fresh_f
                g_lbr_struct += struct_f
                g_n_break    += 1
            if z.violations >= 2
                z.is_support := not z.is_support
                z.flip_count += 1

        // Zone invalidation: permanently remove zones with 3+ violations (zombie zones die).
        // FVG fill-removal waits for any pending bounce/break judgment to resolve first (pending_check_bar == -1) —
        // otherwise a touched FVG got deleted before M6 ever got to judge whether it bounced.
        if z.violations >= 3 or (z.source == "FVG" and not i_fvg_show_filled and z.touches >= 1 and z.pending_check_bar == -1)
            array.remove(g_zones, i)
        else if z_dirty
            array.set(g_zones, i, z)

// ═══════════════════════════════════════════════════════════
// M4 — CONFLUENCE MERGER
// ═══════════════════════════════════════════════════════════

// Confluence only changes when a zone is added, merged or removed — recomputing this O(n²) scan on
// every bar was pure waste. At the 30-zone default that is 900 comparisons per bar; every 10 bars
// plus the rendered bar keeps the displayed number current at a tenth of the cost.
n_zones = array.size(g_zones)
if n_zones > 0 and (bar_index % 10 == 0 or barstate.islast)
    for i = 0 to n_zones - 1
        zi      = array.get(g_zones, i)
        overlap = 0
        for j = 0 to n_zones - 1
            if i != j
                zj = array.get(g_zones, j)
                if zi.top >= zj.bottom and zi.bottom <= zj.top
                    overlap += 1
        // Confluence = distinct detector sources merged into this zone + other overlapping zone objects (different width/timeframe that didn't merge)
        zi.confluence_count := math.max(popcount7(zi.sources_mask), 1) + overlap
        array.set(g_zones, i, zi)

// ═══════════════════════════════════════════════════════════
// M5 — COMPOSITE SCORE ENGINE
// ═══════════════════════════════════════════════════════════

// ── M5: Composite Score Engine with Adaptive Weights ──
// Four weights self-calibrate from observed bounce/break outcomes.
// i_w_touch and i_w_create_vol and i_w_regime stay static (harder to isolate).
aw_vol   = calc_adaptive_w(i_w_touch_vol,  g_lb_vol,   g_lbr_vol,   g_n_bounce, g_n_break)
aw_htf   = calc_adaptive_w(i_w_htf,        g_lb_htf,   g_lbr_htf,   g_n_bounce, g_n_break)
aw_conf  = calc_adaptive_w(i_w_confluence, g_lb_conf,  g_lbr_conf,  g_n_bounce, g_n_break)
aw_fresh = calc_adaptive_w(i_w_fresh,      g_lb_fresh, g_lbr_fresh, g_n_bounce, g_n_break)
// Structure carries no weight when the engine is off, so disabling it leaves every other factor
// at its original share of the total instead of silently diluting them with a neutral 0.5.
// When on, its weight self-calibrates like the other four rather than staying a hand-picked guess.
aw_struct = calc_adaptive_w(i_w_structure, g_lb_struct, g_lbr_struct, g_n_bounce, g_n_break)
w_struct  = i_ms_enable ? aw_struct : 0.0
total_w  = aw_vol + aw_conf + aw_htf + i_w_touch + i_w_create_vol + i_w_regime + aw_fresh + w_struct

// Scores move slowly: they are driven by touches (rare), regime (slow) and freshness decay (slow).
// Recomputing all of them on every historical bar bought nothing. Every 3 bars plus the rendered
// bar keeps every consumer current — grades shift far slower than three bars.
// NOT gated on barstate.isconfirmed: that is true on every historical bar, which would make the
// throttle a no-op over exactly the range where the load time is spent.
n_score = array.size(g_zones)
if n_score > 0 and (bar_index % 3 == 0 or barstate.islast)
    for i = 0 to n_score - 1
        z         = array.get(g_zones, i)
        touch_n   = math.min(z.touches, 5) / 5.0
        vol_conv  = math.min(z.touch_vol_avg, 3.0) / 3.0
        create_vn = math.min(z.creation_volume, 3.0) / 3.0
        conf_n    = math.min(z.confluence_count, 5) / 5.0
        fresh_n   = z.is_fresh ? 1.0 : math.max(0.0, 1.0 - float(bar_index - z.last_touch_bar) / 300.0)
        htf_n     = z.htf_source == "W" ? 1.0 : z.htf_source == "D" ? 0.8 : z.htf_source == "240" ? 0.6 : 0.3
        viol_pen  = math.min(z.violations * 0.25, 1.0)
        rf        = 0.5
        if z.is_support
            rf := regime_state == "STRONG_BULL" ? 1.0 : regime_state == "WEAK_BULL" ? 0.8 : regime_state == "RANGE" ? 0.5 : regime_state == "SQUEEZE" ? 0.6 : 0.35
        else
            rf := regime_state == "STRONG_BEAR" ? 1.0 : regime_state == "WEAK_BEAR" ? 0.8 : regime_state == "RANGE" ? 0.5 : regime_state == "SQUEEZE" ? 0.6 : 0.35
        // Per-zone statistical bonus: zones that bounced historically get a small score boost
        stat_bonus = z.bounce_count + z.break_count > 4 ? (float(z.bounce_count) / math.max(z.bounce_count + z.break_count, 1) - 0.5) * 10.0 : 0.0
        flip_bonus = z.flip_count >= 1 ? 5.0 : 0.0  // a flipped zone (former S/R reversed) that's still standing is proven structure
        // Structure fit: a support in a BULL structure is defended; the same support in a BEAR
        // structure is usually just the next level to be cut through. Kept separate from regime fit
        // (rf) on purpose — regime reads ADX/EMA slope, structure reads actual swing breaks, and
        // when the two disagree that disagreement is itself information.
        sf  = z.is_support ? (ms_trend == "BULL" ? 1.0 : ms_trend == "BEAR" ? 0.2 : 0.5) : (ms_trend == "BEAR" ? 1.0 : ms_trend == "BULL" ? 0.2 : 0.5)
        raw = (touch_n * i_w_touch + vol_conv * aw_vol + create_vn * i_w_create_vol + htf_n * aw_htf + conf_n * aw_conf + fresh_n * aw_fresh + rf * i_w_regime + sf * w_struct - viol_pen * 6.0) / math.max(total_w, 1) * 100.0 + stat_bonus + flip_bonus
        z.score  := math.max(0.0, math.min(100.0, raw))
        z.grade  := get_grade(z.score)   // grade ALWAYS derived from final score — no sync bug
        array.set(g_zones, i, z)

// ═══════════════════════════════════════════════════════════
// M8 — WARNING GENERATOR
// ═══════════════════════════════════════════════════════════

var string active_warning    = "—"
var string warning_severity  = "INFO"
var int    warning_zone_id   = -1
var string warning_zone_src  = ""
var float  warning_zone_score = 0.0
var string warning_zone_grade = ""

regime_changed = regime_state != prev_regime
prev_regime   := regime_state

active_warning   := "—"
warning_severity := "INFO"

// barstate.isconfirmed alone is a FAKE throttle: it is true on every historical bar, so it removed
// nothing over exactly the range where load time is spent — two full zone scans ran on all 20,000
// bars while looking gated. The bar_index test is the real throttle; barstate.islast keeps the
// live bar (and therefore every realtime alert) exact.
if barstate.isconfirmed and (bar_index % 3 == 0 or barstate.islast)
    n_warn = array.size(g_zones)
    if n_warn > 0
        for i = 0 to n_warn - 1
            z    = array.get(g_zones, i)
            dist = math.abs(z.mid - close)
            if i_warn_regime and regime_changed and dist < atr_val * 1.5 and z.grade == "A"
                active_warning     := "REGIME_SHIFT"
                warning_severity   := "HIGH"
                warning_zone_id    := z.id
                warning_zone_src   := z.source
                warning_zone_score := z.score
                warning_zone_grade := z.grade
                break
            if i_warn_trap and z.violations >= 1 and dist < atr_val * 0.3 and volume < avg_vol_20 * 0.7
                active_warning     := "TRAP_SUSPECTED"
                warning_severity   := "HIGH"
                warning_zone_id    := z.id
                warning_zone_src   := z.source
                warning_zone_score := z.score
                warning_zone_grade := z.grade
                break
            if i_warn_sweep and z.source == "LIQ" and dist < atr_val * 0.3 and volume > avg_vol_20 * 1.5
                active_warning     := "SWEEP_IMMINENT"
                warning_severity   := "HIGH"
                warning_zone_id    := z.id
                warning_zone_src   := z.source
                warning_zone_score := z.score
                warning_zone_grade := z.grade
                break
            if i_warn_flip and z.flip_count >= 1 and dist < atr_val * 0.3
                active_warning     := "FLIP_RETEST"
                warning_severity   := "HIGH"
                warning_zone_id    := z.id
                warning_zone_src   := z.source
                warning_zone_score := z.score
                warning_zone_grade := z.grade
                break
            if i_warn_fvg and z.source == "FVG" and low <= z.top and high >= z.bottom and z.touches == 0
                active_warning   := "FVG_FILLING"
                warning_severity := "INFO"
                warning_zone_id  := z.id
            if i_warn_approach and (z.grade == "A" or z.grade == "B") and dist < atr_val * e_warn_dist
                active_warning     := "ZONE_APPROACH"
                warning_severity   := z.grade == "A" ? "WARN" : "INFO"
                warning_zone_id    := z.id
                warning_zone_src   := z.source
                warning_zone_score := z.score
                warning_zone_grade := z.grade
    if active_warning == "—" and i_warn_cluster and n_warn > 0
        cluster_count = 0
        for i = 0 to n_warn - 1
            if math.abs(array.get(g_zones, i).mid - close) < atr_val
                cluster_count += 1
        if cluster_count >= 3
            active_warning   := "ZONE_CLUSTER_AHEAD"
            warning_severity := "WARN"

g_warning  := active_warning
g_warn_bar := bar_index

// ═══════════════════════════════════════════════════════════
// TRADE PLAN GENERATOR
// ═══════════════════════════════════════════════════════════
// Scans zones for a high-quality setup approaching price.
// LONG: price above a Grade-A/B support, within 1.5 ATR.
// SHORT: price below a Grade-A/B resistance, within 1.5 ATR.
// Calculates Entry / Stop / Target / R:R / Position Size.
// Only activates when R:R >= i_min_rr.

g_tp_dir    := "—"
g_tp_entry  := na
g_tp_stop   := na
g_tp_target := na
g_tp_rr     := na
g_tp_shares := 0
g_tp_score  := 0.0
g_tp_zone_id := -1
g_tp_vs_struct := false
g_tp_vs_mtf    := false
g_tp_dryup     := false
g_tp_state     := "—"
g_tp_trigger   := "—"
g_tp_dist_atr  := na

if i_enable_trade_plan
    float best_long_score  = 0.0
    float best_long_top    = na
    float best_long_bot    = na
    float best_long_mid    = na
    int   best_long_id     = -1
    float best_short_score = 0.0
    float best_short_top   = na
    float best_short_bot   = na
    float best_short_mid   = na
    int   best_short_id    = -1

    n_tp = array.size(g_zones)
    if n_tp > 0
        for i = 0 to n_tp - 1
            z        = array.get(g_zones, i)
            dist_atr = math.abs(z.mid - close) / math.max(atr_val, 0.0001)
            // LONG candidate: price above zone, approaching from above
            if z.is_support and close > z.top and dist_atr < 1.5 and z.score > 60
                regime_ok = regime_state == "STRONG_BULL" or regime_state == "WEAK_BULL" or regime_state == "RANGE" or regime_state == "SQUEEZE"
                // Structure gate: never plan a long while structure is BEAR. RANGE allows both sides.
                struct_ok = not i_ms_enable or not i_ms_gate_trades or ms_trend != "BEAR"
                if regime_ok and struct_ok and z.score > best_long_score
                    best_long_score  := z.score
                    best_long_top    := z.top
                    best_long_bot    := z.bottom
                    best_long_mid    := z.mid
                    best_long_id     := z.id
            // SHORT candidate: price below zone, approaching from below
            if not z.is_support and close < z.bottom and dist_atr < 1.5 and z.score > 60
                regime_ok = regime_state == "STRONG_BEAR" or regime_state == "WEAK_BEAR" or regime_state == "RANGE" or regime_state == "SQUEEZE"
                // Structure gate: never plan a short while structure is BULL. RANGE allows both sides.
                struct_ok = not i_ms_enable or not i_ms_gate_trades or ms_trend != "BULL"
                if regime_ok and struct_ok and z.score > best_short_score
                    best_short_score  := z.score
                    best_short_top    := z.top
                    best_short_bot    := z.bottom
                    best_short_mid    := z.mid
                    best_short_id     := z.id

    // ── Calculate LONG trade plan ──
    if not na(best_long_top) and best_long_score > 0
        tp_entry = best_long_top + atr_val * 0.1
        tp_stop  = best_long_bot - atr_val * 0.5
        tp_risk  = math.abs(tp_entry - tp_stop)
        if tp_risk > 0
            // Find nearest resistance above entry as target — must itself be a usable zone (score ≥50), not a weak D-grade blip
            tp_tgt   = 999999.0
            n_tp2    = array.size(g_zones)
            if n_tp2 > 0
                for i = 0 to n_tp2 - 1
                    z = array.get(g_zones, i)
                    if not z.is_support and z.mid > tp_entry and z.mid < tp_tgt and z.score >= 50
                        tp_tgt := z.mid
            if tp_tgt < 999999.0
                tp_rr_val = (tp_tgt - tp_entry) / tp_risk
                if tp_rr_val >= i_min_rr
                    g_tp_dir    := "LONG"
                    g_tp_vs_struct := i_ms_enable and ms_trend == "BEAR"
                    g_tp_vs_mtf    := i_mtf_enable and mtf_bias == "BEAR"
                    g_tp_dryup     := vol_dryup
                    // APPROACH = still travelling to the zone. WAIT = at the zone, nothing has
                    // reacted yet. READY = a reversal candle fired within the trigger window.
                    g_tp_dist_atr  := (close - best_long_top) / math.max(atr_val, 0.0001)
                    g_tp_state     := g_tp_dist_atr > i_trig_zone_atr ? "APPROACH" : (not i_trig_enable or trig_bull_fresh) ? "READY" : "WAIT"
                    g_tp_trigger   := (g_tp_state == "READY" and i_trig_enable and trig_bull_fresh) ? last_trig_name : "—"
                    g_tp_entry  := tp_entry
                    g_tp_stop   := tp_stop
                    g_tp_target := tp_tgt
                    g_tp_rr     := tp_rr_val
                    g_tp_score  := best_long_score
                    g_tp_zone_id := best_long_id
                    risk_dollar  = i_account_size * i_risk_pct / 100
                    g_tp_shares := int(math.round(risk_dollar / tp_risk))

    // ── Calculate SHORT trade plan ──
    if not na(best_short_bot) and best_short_score > 0 and g_tp_dir == "—"
        tp_entry = best_short_bot - atr_val * 0.1
        tp_stop  = best_short_top + atr_val * 0.5
        tp_risk  = math.abs(tp_stop - tp_entry)
        if tp_risk > 0
            // Find nearest support below entry as target — must itself be a usable zone (score ≥50)
            tp_tgt   = 0.0
            n_tp3    = array.size(g_zones)
            if n_tp3 > 0
                for i = 0 to n_tp3 - 1
                    z = array.get(g_zones, i)
                    if z.is_support and z.mid < tp_entry and z.mid > tp_tgt and z.score >= 50
                        tp_tgt := z.mid
            if tp_tgt > 0
                tp_rr_val = (tp_entry - tp_tgt) / tp_risk
                if tp_rr_val >= i_min_rr
                    g_tp_dir    := "SHORT"
                    g_tp_vs_struct := i_ms_enable and ms_trend == "BULL"
                    g_tp_vs_mtf    := i_mtf_enable and mtf_bias == "BULL"
                    g_tp_dryup     := vol_dryup
                    g_tp_dist_atr  := (best_short_bot - close) / math.max(atr_val, 0.0001)
                    g_tp_state     := g_tp_dist_atr > i_trig_zone_atr ? "APPROACH" : (not i_trig_enable or trig_bear_fresh) ? "READY" : "WAIT"
                    g_tp_trigger   := (g_tp_state == "READY" and i_trig_enable and trig_bear_fresh) ? last_trig_name : "—"
                    g_tp_entry  := tp_entry
                    g_tp_stop   := tp_stop
                    g_tp_target := tp_tgt
                    g_tp_rr     := tp_rr_val
                    g_tp_score  := best_short_score
                    g_tp_zone_id := best_short_id
                    risk_dollar  = i_account_size * i_risk_pct / 100
                    g_tp_shares := int(math.round(risk_dollar / tp_risk))

// ═══════════════════════════════════════════════════════════
// SETUP ACCURACY TRACKER
// ═══════════════════════════════════════════════════════════
// Zone Hit Rate counts zone touches. This counts TRADE PLANS: once a plan is issued, did price
// reach the target before the stop? That is the number that actually reflects whether following
// this tool would have made money, and it is a different question from whether zones hold.
// Resolution runs BEFORE recording, so a plan issued this bar cannot also be judged on it.
// Stop is checked before target: when a single bar spans both, the pessimistic read is the honest one.

var array<float> tpa_stop = array.new<float>()
var array<float> tpa_tgt  = array.new<float>()
var array<int>   tpa_dir  = array.new<int>()
var int    tpa_win       = 0
var int    tpa_loss      = 0
var string tpa_last_dir  = "—"
var int    tpa_last_zid  = -1

if barstate.isconfirmed and array.size(tpa_dir) > 0
    for i = array.size(tpa_dir) - 1 to 0
        dr = array.get(tpa_dir, i)
        st = array.get(tpa_stop, i)
        tg = array.get(tpa_tgt, i)
        hit_stop = dr == 1 ? low <= st : high >= st
        hit_tgt  = dr == 1 ? high >= tg : low <= tg
        if hit_stop or hit_tgt
            if hit_stop
                tpa_loss += 1
            else
                tpa_win += 1
            array.remove(tpa_dir, i)
            array.remove(tpa_stop, i)
            array.remove(tpa_tgt, i)

if barstate.isconfirmed and i_enable_trade_plan and g_tp_dir != "—" and not na(g_tp_entry) and (g_tp_dir != tpa_last_dir or g_tp_zone_id != tpa_last_zid)
    // Cap open records so a chart that issues plans faster than they resolve cannot grow unbounded.
    if array.size(tpa_dir) < 20
        array.push(tpa_dir,  g_tp_dir == "LONG" ? 1 : -1)
        array.push(tpa_stop, g_tp_stop)
        array.push(tpa_tgt,  g_tp_target)
    tpa_last_dir := g_tp_dir
    tpa_last_zid := g_tp_zone_id
if g_tp_dir == "—"
    tpa_last_dir := "—"
    tpa_last_zid := -1

tpa_total = tpa_win + tpa_loss
tpa_pct   = tpa_total > 0 ? math.round(float(tpa_win) / tpa_total * 100) : -1

// ═══════════════════════════════════════════════════════════
// PROJECTION — pace estimate to the active target
// ═══════════════════════════════════════════════════════════
// Average distance price actually covers per bar over the last 20 bars, in ATR. Divide the
// remaining distance by it and you get bars-to-target at the pace this market is really moving.
// A pace estimate, not a direction forecast — the direction comes from the plan.

atr_per_bar = ta.sma(math.abs(close - close[1]), 20) / math.max(atr_val, 0.0001)
proj_dist   = na(g_tp_target) ? na : math.abs(g_tp_target - close) / math.max(atr_val, 0.0001)
proj_bars_r = na(proj_dist) or atr_per_bar < 0.01 ? na : int(math.round(proj_dist / atr_per_bar))
// Clamped to 480: a drawing placed more than ~500 bars into the future is a runtime error that
// blanks the entire script. The honest number still goes in the label; only the drawing is capped.
proj_bars   = na(proj_bars_r) ? na : math.min(math.max(proj_bars_r, 1), 480)

// ═══════════════════════════════════════════════════════════
// M12 — JSON ALERT BUILDER
// ═══════════════════════════════════════════════════════════

build_json_alert(warn_type, sev, z_src, z_score, z_grade, z_conf) =>
    '{"brand":"OrenLuxy","script":"BOSS_MODE_SR","ver":"1.0","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","price":' + str.tostring(close, format.mintick) + ',"atr":' + str.tostring(math.round(atr_val, 4)) + ',"regime":"' + regime_state + '","is_squeeze":' + (is_squeeze ? "true" : "false") + ',"asset":"' + g_asset + '","mode":"' + eff_mode + '","structure":"' + ms_trend + '","structure_event":"' + ms_event + '","htf":"' + mtf_res + '","htf_bias":"' + mtf_bias + '","setup_state":"' + g_tp_state + '","trigger":"' + g_tp_trigger + '","vol_dryup":' + (vol_dryup ? "true" : "false") + ',"warning":"' + warn_type + '","severity":"' + sev + '","zone":{"source":"' + z_src + '","score":' + str.tostring(math.round(z_score)) + ',"grade":"' + z_grade + '","confluence":' + str.tostring(z_conf) + '}}'

// ═══════════════════════════════════════════════════════════
// SCENARIO GENERATOR
// ═══════════════════════════════════════════════════════════

get_scenario() =>
    bull_r = regime_state == "STRONG_BULL" or regime_state == "WEAK_BULL"
    bear_r = regime_state == "STRONG_BEAR" or regime_state == "WEAK_BEAR"
    near_r = 999999.0
    near_s = 0.0
    n_sc   = array.size(g_zones)
    if n_sc > 0
        for i = 0 to n_sc - 1
            z = array.get(g_zones, i)
            if not z.is_support and z.mid > close and z.mid < near_r
                near_r := z.mid
            if z.is_support and z.mid < close and z.mid > near_s
                near_s := z.mid
    r_dist = near_r < 999999.0 ? (near_r - close) / atr_val : 99.0
    s_dist = near_s > 0 ? (close - near_s) / atr_val : 99.0
    if is_squeeze
        "⚡ Squeeze — expect breakout move"
    else if bull_r and s_dist < r_dist
        "🟢 Likely: hold S → rally to R"
    else if bull_r and r_dist < 0.5
        "⚠️ Resistance close — watch for stall"
    else if bear_r and r_dist < s_dist
        "🔴 Likely: reject R → sell to S"
    else if bear_r and s_dist < 0.5
        "⚠️ Support close — watch for break"
    else
        "⬜ Range-bound — fade extremes"

// ═══════════════════════════════════════════════════════════
// M10 — VISUAL RENDERING
// ═══════════════════════════════════════════════════════════

// Persistent render pools — cleared each bar to prevent object accumulation
var array<int>   sorted_idx     = array.new<int>()
var array<box>   rendered_boxes = array.new<box>()
var array<label> rendered_labels = array.new<label>()

// Background zone highlight when price enters a Grade-A zone
in_grade_a_zone = false
bg_zone_col     = color.new(color.white, 100)
n_bg = array.size(g_zones)
if n_bg > 0
    for i = 0 to n_bg - 1
        z = array.get(g_zones, i)
        if z.grade == "A" and low <= z.top and high >= z.bottom
            in_grade_a_zone := true
            bg_zone_col     := z.is_support ? color.new(#00e5ff, 94) : color.new(#ff1744, 94)
            break
bgcolor(in_grade_a_zone ? bg_zone_col : na, title="Grade-A Zone Highlight")

// Pre-compute nearest S/R mids so M10 can suppress zones already shown by Simple View
var float sv_pre_r_mid = na
var float sv_pre_s_mid = na
if barstate.islast and i_show_simple
    sv_pre_r_mid := na
    sv_pre_s_mid := na
    n_pre = array.size(g_zones)
    if n_pre > 0
        for i = 0 to n_pre - 1
            z = array.get(g_zones, i)
            if not z.is_support and z.mid > close
                if na(sv_pre_r_mid) or z.mid < sv_pre_r_mid
                    sv_pre_r_mid := z.mid
            if z.is_support and z.mid < close
                if na(sv_pre_s_mid) or z.mid > sv_pre_s_mid
                    sv_pre_s_mid := z.mid

if barstate.islast
    // Clear previous render cycle objects
    for bx in rendered_boxes
        box.delete(bx)
    array.clear(rendered_boxes)
    for lb in rendered_labels
        label.delete(lb)
    array.clear(rendered_labels)

    // Sort zones by score descending
    array.clear(sorted_idx)
    nz      = array.size(g_zones)
    temp_sc = array.new<float>()
    if nz > 0
        for i = 0 to nz - 1
            array.push(temp_sc, array.get(g_zones, i).score)
            array.push(sorted_idx, i)
        for a = 0 to nz - 2
            for b = 0 to nz - 2 - a
                if array.get(temp_sc, b) < array.get(temp_sc, b + 1)
                    ts = array.get(temp_sc, b)
                    ti = array.get(sorted_idx, b)
                    array.set(temp_sc, b, array.get(temp_sc, b + 1))
                    array.set(sorted_idx, b, array.get(sorted_idx, b + 1))
                    array.set(temp_sc, b + 1, ts)
                    array.set(sorted_idx, b + 1, ti)

    rc       = 0
    // Track rendered zone mids to suppress duplicate labels within 0.5 ATR
    rendered_mids = array.new<float>()
    n_sorted = array.size(sorted_idx)
    if n_sorted > 0
        for r = 0 to n_sorted - 1
            if rc >= i_top_n_zones
                break
            idx      = array.get(sorted_idx, r)
            z        = array.get(g_zones, idx)
            // Hide D-grade AND very low scoring zones — they add confusion not value
            if z.grade == "D" and not i_show_grade_d
                continue
            if z.score < 40
                continue
            dist_atr = math.abs(z.mid - close) / math.max(atr_val, 0.0001)
            if i_adaptive_hide and dist_atr > 2.5
                continue
            // When Simple View is ON: suppress M10 labels for the nearest S/R
            // (Simple View already shows those clearly as big boxes — no duplication)
            if i_show_simple
                is_sv_r = not z.is_support and not na(sv_pre_r_mid) and math.abs(z.mid - sv_pre_r_mid) < atr_val * 1.5
                is_sv_s = z.is_support     and not na(sv_pre_s_mid) and math.abs(z.mid - sv_pre_s_mid) < atr_val * 1.5
                if is_sv_r or is_sv_s
                    continue

            // Skip zones within 0.8 ATR of an already-rendered zone (same side dedup)
            too_close = false
            nm = array.size(rendered_mids)
            if nm > 0
                for k = 0 to nm - 1
                    if math.abs(array.get(rendered_mids, k) - z.mid) < atr_val * 0.8
                        too_close := true
                        break
            if too_close
                continue
            array.push(rendered_mids, z.mid)

            zone_h   = z.top - z.bottom
            ext      = zone_h * 0.30
            // Box left edge must stay inside the historical buffer (max_bars_back=400). Protected
            // W/D swings and Key Levels are never evicted, so bar_created can be thousands of bars
            // back — passing it raw throws "historical offset beyond buffer limit" and blanks the
            // whole script. Purely cosmetic clamp: every box below uses extend.right anyway.
            zx1      = math.max(z.bar_created, bar_index - 300)
            // Proximity boost: closer zones are more vivid
            prox     = math.max(0.0, math.min(1.0, 1.0 - dist_atr / 2.5))
            t_main   = math.round(math.max(30, i_zone_transp - prox * 25))
            t_halo   = math.min(96, t_main + 22)
            t_core   = math.max(15, t_main - 22)

            bdr_c    = get_border_color_grade(z.grade)
            bdr_w    = get_border_w(z.htf_source)

            // ── Layer 1: Atmospheric halo (extends beyond zone) ──
            array.push(rendered_boxes, box.new(zx1, z.top + ext, bar_index + 20, z.bottom - ext, border_color=color.new(color.white, 100), border_width=0, bgcolor=get_heat_color(z.score, z.is_support, t_halo), extend=extend.right))

            // ── Layer 2: Main zone fill ──
            array.push(rendered_boxes, box.new(zx1, z.top, bar_index + 20, z.bottom, border_color=bdr_c, border_width=bdr_w, bgcolor=get_heat_color(z.score, z.is_support, t_main), extend=extend.right))

            // ── Layer 3: Hot core strip at midpoint ──
            core_h = zone_h * 0.18
            array.push(rendered_boxes, box.new(bar_index - 3, z.mid + core_h, bar_index + 20, z.mid - core_h, border_color=color.new(color.white, 95), border_width=0, bgcolor=get_heat_color(z.score, z.is_support, t_core), extend=extend.right))

            // ── Layer 5: ENTRY LINE — the critical edge where price reacts ──
            // Support: bright line at TOP of zone (price hits zone ceiling from above → bounces UP)
            // Resistance: bright line at BOTTOM of zone (price hits zone floor from below → rejects DOWN)
            entry_line_h  = zone_h * 0.06   // thin bright stripe at contact edge
            entry_col     = get_heat_color(z.score, z.is_support, 0)  // fully opaque = maximum visibility
            if z.is_support
                array.push(rendered_boxes, box.new(zx1, z.top + entry_line_h * 0.3, bar_index + 20, z.top - entry_line_h, border_color=color.new(color.white, 80), border_width=0, bgcolor=entry_col, extend=extend.right))
            else
                array.push(rendered_boxes, box.new(zx1, z.bottom + entry_line_h, bar_index + 20, z.bottom - entry_line_h * 0.3, border_color=color.new(color.white, 80), border_width=0, bgcolor=entry_col, extend=extend.right))

            // ── Layer 4: Grade-A pulse ring (near price only) ──
            if z.grade == "A" and dist_atr < 1.5
                ring_c = z.is_support ? color.new(#00e5ff, 30) : color.new(#ff1744, 10)
                array.push(rendered_boxes, box.new(zx1, z.top + ext * 0.6, bar_index + 20, z.bottom - ext * 0.6, border_color=ring_c, border_width=2, bgcolor=color.new(color.white, 100), extend=extend.right))

            // ── Score bar: progress bar to the right ──
            sb_x1 = bar_index + 24
            sb_x2 = bar_index + 28
            // Track (empty background)
            array.push(rendered_boxes, box.new(sb_x1, z.top, sb_x2, z.bottom, border_color=color.new(color.gray, 65), border_width=1, bgcolor=color.new(color.black, 85)))
            // Fill (proportional to score)
            if zone_h > 0 and z.score > 0
                fill_top = z.bottom + zone_h * math.min(z.score / 100.0, 1.0)
                array.push(rendered_boxes, box.new(sb_x1, fill_top, sb_x2, z.bottom, border_color=color.new(color.white, 50), border_width=0, bgcolor=get_heat_color(z.score, z.is_support, 25)))

            // ── Label: numeric score (no grade letter — color IS the grade) + stats + momentum ──
            z_total_obs = z.bounce_count + z.break_count
            stats_str   = z_total_obs >= 2 ? "  " + str.tostring(z.bounce_count) + "/" + str.tostring(z_total_obs) + (z.bounce_count >= 2 ? "  +" + str.tostring(math.round(z.avg_dist_at_touch_atr, 1)) + "ᴬ" : "") : ""
            mom_str     = z.momentum_signal != "—" ? "  " + z.momentum_signal : ""
            cb_lbl      = z.confluence_count >= 3 ? "  ✦" + str.tostring(z.confluence_count) : ""
            cat_lbl     = z.catalyst_label != "" ? "  " + z.catalyst_label : ""
            flip_lbl    = z.flip_count >= 1 ? "  🔁" : ""
            // Full S/R text label — no ambiguity about direction
            sr_prefix   = z.is_support ? "⬆ SUPPORT" : "⬇ RESIST"
            lt          = sr_prefix + "  " + get_src_emoji(z.source) + "  " + str.tostring(math.round(z.score)) + stats_str + mom_str + cb_lbl + cat_lbl + flip_lbl
            ly          = z.is_support ? z.bottom - atr_val * 0.28 : z.top + atr_val * 0.28
            ls          = z.is_support ? label.style_label_up : label.style_label_down
            // Minimum size.small — never tiny (unreadable)
            lsz         = z.score >= 80 ? size.normal : size.small

            // ── Tooltip: detailed breakdown explaining WHY this zone scored what it did ──
            src_name   = z.source == "SWING" ? "Swing Pivot" : z.source == "OB" ? "Order Block" : z.source == "POC" ? "Volume POC" : z.source == "FVG" ? "Fair Value Gap" : z.source == "LIQ" ? "Liquidity Pool" : z.source == "AVWAP" ? "Anchored VWAP" : "Key Level"
            z_dir      = z.is_support ? "SUPPORT ⬆  (buy zone)" : "RESISTANCE ⬇  (sell zone)"
            // Recompute factor contributions for the breakdown
            t_touch_n  = math.min(z.touches, 5) / 5.0
            t_vol_c    = math.min(z.touch_vol_avg, 3.0) / 3.0
            t_create_v = math.min(z.creation_volume, 3.0) / 3.0
            t_conf_n   = math.min(z.confluence_count, 5) / 5.0
            t_fresh_n  = z.is_fresh ? 1.0 : math.max(0.0, 1.0 - float(bar_index - z.last_touch_bar) / 300.0)
            t_htf_n    = z.htf_source == "W" ? 1.0 : z.htf_source == "D" ? 0.8 : z.htf_source == "240" ? 0.6 : 0.3
            // Readable labels for each factor
            vol_lbl    = z.touch_vol_avg > 1.8 ? "HIGH (×" + str.tostring(math.round(z.touch_vol_avg, 1)) + " avg)" : z.touch_vol_avg > 0.8 ? "NORMAL (×" + str.tostring(math.round(z.touch_vol_avg, 1)) + ")" : "LOW (×" + str.tostring(math.round(z.touch_vol_avg, 1)) + ")"
            htf_lbl    = z.htf_source == "W" ? "Weekly (strongest)" : z.htf_source == "D" ? "Daily (strong)" : z.htf_source == "240" ? "4H (medium)" : "Intraday (lower)"
            conf_lbl   = z.confluence_count >= 4 ? str.tostring(z.confluence_count) + " sources (excellent)" : z.confluence_count >= 2 ? str.tostring(z.confluence_count) + " sources (good)" : "1 source (single)"
            fresh_lbl  = z.is_fresh ? "Fresh — never tested (premium)" : "Tested " + str.tostring(z.touches) + " time(s)"
            // Score breakdown — shows contribution of each factor
            struct_lbl = not i_ms_enable ? "off" : ms_trend == "RANGE" ? "RANGE (neutral)" : ((z.is_support ? ms_trend == "BULL" : ms_trend == "BEAR") ? ms_trend + " — agrees ✅" : ms_trend + " — fights ⚠️")
            score_breakdown = "\n\n── Score breakdown ──" + "\n• Vol at touch: " + vol_lbl + "\n• Timeframe: " + htf_lbl + "\n• Confluence: " + conf_lbl + "\n• Freshness: " + fresh_lbl + "\n• Touches: " + str.tostring(z.touches) + (z.violations > 0 ? "  (-" + str.tostring(z.violations) + " violations)" : "  (clean)") + "\n• Regime fit: " + regime_state + "\n• Structure fit: " + struct_lbl
            // Historical stats section
            hold_pct   = z_total_obs > 0 ? math.round(float(z.bounce_count) / z_total_obs * 100) : -1
            perf_lbl   = hold_pct >= 70 ? "✅ High hold rate (n=" + str.tostring(z_total_obs) + ")" : hold_pct >= 50 ? "🟡 Moderate (n=" + str.tostring(z_total_obs) + ")" : hold_pct >= 0 ? "🔴 Frequent breaks (n=" + str.tostring(z_total_obs) + ")" : ""
            stat_section = z_total_obs >= 2 ? "\n\n── Historical performance ──\n• Held: " + str.tostring(hold_pct) + "% (" + str.tostring(z.bounce_count) + "/" + str.tostring(z_total_obs) + " tests)  " + perf_lbl + (z.bounce_count >= 2 ? "\n• Avg touch dist: +" + str.tostring(math.round(z.avg_dist_at_touch_atr, 2)) + " ATR from mid" : "") : "\n\nNo test history yet (zone is new)"
            // Momentum + LEI section
            lei_detail = not na(lei_value) ? "\n• LEI: " + str.tostring(math.round(lei_value)) + "/100 (" + lei_zone_str + ")\n  LEI ≥70 = tired move → BOUNCE  |  LEI ≤30 = energized → BREAK" : ""
            mom_section = z.momentum_signal != "—" ? "\n\n── Momentum NOW ──\n• Signal: " + z.momentum_signal + lei_detail : (not na(lei_value) ? "\n\n── Momentum NOW ──\n• LEI: " + str.tostring(math.round(lei_value)) + " (" + lei_zone_str + ")" + lei_detail : "")
            // Flip section — this zone reversed polarity at least once and is still standing
            flip_section = z.flip_count >= 1 ? "\n\n🔁 FLIPPED " + str.tostring(z.flip_count) + "x — this zone reversed polarity (now " + (z.is_support ? "SUPPORT, was resistance" : "RESISTANCE, was support") + ")\nA retest here is a classic continuation setup." : ""
            // Full tooltip
            z_tt = "═══ " + src_name + " ═══\n" + z_dir + "\n\nScore: " + str.tostring(math.round(z.score)) + " / 100\n(🔵≥80 Excellent | 🟢≥65 Good | 🟡≥50 Moderate | ⚫<50 Weak)" + score_breakdown + stat_section + mom_section + flip_section + "\n\n── How to read the label ──\n📐🧱📊💨💧⚓🗓 = zone source\nNumber = score 0-100 (color = quality)\n5/7 = held 5 of 7 historical tests\n+0.4ᴬ = avg distance from mid at touch (0.4 ATR)\n⬆ BOUNCE / ⚠ BREAK = momentum signal\n✦3 = 3 overlapping zone sources\n🔁 = zone flipped polarity"
            array.push(rendered_labels, label.new(bar_index + 29, ly, lt, color=get_heat_color(z.score, z.is_support, 20), textcolor=color.white, style=ls, size=lsz, tooltip=z_tt))
            rc += 1

// ═══════════════════════════════════════════════════════════
// TRADE PLAN VISUAL — Entry / Stop / Target lines on chart
// ═══════════════════════════════════════════════════════════

if barstate.islast
    line.delete(tp_entry_ln)
    line.delete(tp_stop_ln)
    line.delete(tp_tgt_ln)
    label.delete(tp_plan_lbl)
    line.delete(tp_proj_ln)
    label.delete(tp_proj_lbl)

    if i_proj_enable and i_enable_trade_plan and g_tp_dir != "—" and not na(g_tp_target) and not na(proj_bars)
        proj_col  = g_tp_dir == "LONG" ? color.new(#26a69a, 40) : color.new(#ef5350, 40)
        tp_proj_ln := line.new(bar_index, close, bar_index + proj_bars, g_tp_target, color=proj_col, width=1, style=line.style_dashed)
        proj_eta   = na(proj_bars_r) ? "—" : str.tostring(proj_bars_r) + " bars"
        tp_proj_lbl := label.new(bar_index + proj_bars, g_tp_target, "🔮 ~" + proj_eta, color=color.new(#263238, 20), textcolor=proj_col, style=label.style_label_left, size=size.small, tooltip="Projected path to the trade plan's target.\n\nEstimated time: " + proj_eta + (proj_bars_r != proj_bars ? "  (line drawn to " + str.tostring(proj_bars) + " bars — drawings cannot be placed further into the future)" : "") + "\nDistance left: " + str.tostring(math.round(proj_dist, 1)) + " ATR\nCurrent pace: " + str.tostring(math.round(atr_per_bar, 3)) + " ATR per bar, averaged over the last 20 bars\n\nThis is a PACE estimate, not a promise. It answers 'if this market keeps moving the way it has been, how long until the target'. It says nothing about whether price will actually go that way — that judgement is the plan's, not the projection's.\n\nA slow pace with a distant target means the trade needs patience or a closer target.")

    if i_enable_trade_plan and g_tp_dir != "—" and not na(g_tp_entry)
        is_long   = g_tp_dir == "LONG"
        line_x1   = bar_index - 30
        line_x2   = bar_index + 40
        // Entry line (blue)
        tp_entry_ln := line.new(line_x1, g_tp_entry, line_x2, g_tp_entry, color=color.new(#2196f3, 0), width=2, style=line.style_dashed, extend=extend.right)
        // Stop line (red)
        tp_stop_ln  := line.new(line_x1, g_tp_stop, line_x2, g_tp_stop, color=color.new(#ef5350, 0), width=2, style=line.style_dashed, extend=extend.right)
        // Target line (green)
        tp_tgt_ln   := line.new(line_x1, g_tp_target, line_x2, g_tp_target, color=color.new(#26a69a, 0), width=2, style=line.style_dashed, extend=extend.right)
        // Central plan label between entry and target
        lbl_y    = (g_tp_entry + g_tp_target) / 2
        tp_state_txt = g_tp_state == "READY" ? "  ✅ READY" : g_tp_state == "WAIT" ? "  ⏳ WAIT" : "  📍 APPROACH"
        tp_vs_txt = (g_tp_vs_struct ? "\n⚠ Against structure (" + ms_trend + ")" : "") + (g_tp_vs_mtf ? "\n⚠ Against " + mtf_res + " bias (" + mtf_bias + ")" : "") + (g_tp_dryup ? "\n💤 Volume drying up" : "") + (g_tp_trigger != "—" ? "\n🕯 " + g_tp_trigger : "")
        tp_txt   = (is_long ? "▲ LONG SETUP" : "▼ SHORT SETUP") + tp_state_txt + tp_vs_txt + "\n▶ Entry  $" + str.tostring(g_tp_entry, format.mintick) + "\n✖ Stop   $" + str.tostring(g_tp_stop, format.mintick) + "\n✔ Target $" + str.tostring(g_tp_target, format.mintick) + "\n" + str.tostring(g_tp_shares) + " shares  |  R:R " + str.tostring(math.round(g_tp_rr, 1))
        tp_bg    = is_long ? color.new(#1b5e20, 15) : color.new(#7f0000, 15)
        tp_plan_lbl := label.new(bar_index + 42, lbl_y, tp_txt, color=tp_bg, textcolor=color.white, style=label.style_label_left, size=size.normal, tooltip="Trade Plan Details\n\nDirection: " + g_tp_dir + "\nEntry: $" + str.tostring(g_tp_entry, format.mintick) + "\nStop Loss: $" + str.tostring(g_tp_stop, format.mintick) + " (" + str.tostring(math.round(math.abs(g_tp_entry - g_tp_stop) / atr_val, 1)) + " ATR buffer)\nTarget: $" + str.tostring(g_tp_target, format.mintick) + "\nR:R ratio: " + str.tostring(math.round(g_tp_rr, 2)) + "\nPosition size: " + str.tostring(g_tp_shares) + " shares\nRisk: $" + str.tostring(math.round(i_account_size * i_risk_pct / 100, 0)) + " (" + str.tostring(i_risk_pct) + "% of $" + str.tostring(math.round(i_account_size, 0)) + ")\nZone score: " + str.tostring(math.round(g_tp_score)) + "/100\n\n── Entry logic ──\n" + (is_long ? "Buy just above support zone top\nStop below zone bottom + 0.5 ATR buffer\nTarget = nearest resistance above with score ≥50" : "Sell just below resistance zone bottom\nStop above zone top + 0.5 ATR buffer\nTarget = nearest support below with score ≥50"))

// ═══════════════════════════════════════════════════════════
// MARKET STRUCTURE VISUAL — the one level that flips the structure
// ═══════════════════════════════════════════════════════════

var line  ms_line = na
var label ms_lbl  = na

if barstate.islast
    line.delete(ms_line)
    label.delete(ms_lbl)
    if i_ms_enable and i_ms_show_line and not na(ms_watch)
        ms_breaks_up = not na(ms_up_lvl) and ms_watch == ms_up_lvl
        ms_col       = ms_breaks_up ? color.new(#26a69a, 0) : color.new(#ef5350, 0)
        ms_line     := line.new(bar_index - 60, ms_watch, bar_index + 20, ms_watch, color=ms_col, width=1, style=line.style_dotted, extend=extend.right)
        ms_txt       = (ms_breaks_up ? "🏗 BULL above " : "🏗 BEAR below ") + str.tostring(ms_watch, format.mintick)
        ms_tt        = "Market Structure — the level that changes everything.\n\nStructure now: " + ms_trend + "\nLast event: " + ms_event + "\nLatest swing: " + ms_swing_lbl + "\n\nA CONFIRMED CLOSE " + (ms_breaks_up ? "above" : "below") + " " + str.tostring(ms_watch, format.mintick) + " flips the structure to " + (ms_breaks_up ? "BULL" : "BEAR") + ".\n\n── What the two events mean ──\nBOS (Break of Structure) — price breaks a swing in the direction the trend already points. Continuation.\nCHoCH (Change of Character) — price breaks a swing against the trend. First evidence the trend is turning.\n\n── Why it matters for zones ──\nA support zone in a BULL structure is defended.\nThe same support in a BEAR structure is usually just the next level to be cut through.\nThat is why structure feeds the score" + (i_ms_gate_trades ? " and blocks trade plans that fight it." : ".")
        ms_lbl      := label.new(bar_index + 21, ms_watch, ms_txt, color=color.new(#263238, 15), textcolor=ms_col, style=label.style_label_left, size=size.small, tooltip=ms_tt)

// ═══════════════════════════════════════════════════════════
// DASHBOARD — 8 rows Compact / 19 rows Full
// ═══════════════════════════════════════════════════════════

var table g_dash = na

if i_show_dash and barstate.islast
    dp  = get_table_pos(i_dash_pos)
    ts  = get_text_size(i_dash_size)
    // Compact keeps only the rows a decision is made from. Everything else is still calculated —
    // this changes display, never behaviour. Rows are placed by a running counter so hidden rows
    // leave no gap.
    dash_full = i_dash_detail == "Full"
    int dr    = 0
    g_dash := table.new(dp, columns=2, rows=dash_full ? 19 : 8, bgcolor=color.new(#000000, 10), border_color=color.new(color.gray, 0), border_width=1)

    // Header
    table.cell(g_dash, 0, dr, "🎯 Support & Resistance - BOSS MODE", bgcolor=color.new(#1565c0, 10), text_color=color.white, text_size=ts, text_halign=text.align_center, tooltip="Luxy Support & Resistance\n\n✅ 7 Detection Sources: Swing, OB, POC, FVG, Liquidity, AVWAP, Key Levels\n⚖️ Regime-Aware Scoring 0-100\n🌍 Works on: Stocks, Crypto, Forex, Indices, Futures\n🚨 7 Warning Types\n📊 Historical Stats\n\nSwitch Detail to Full in 📊 Dashboard settings for the other 11 rows.")
    table.merge_cells(g_dash, 0, dr, 1, dr)
    dr += 1

    // Regime
    rc = get_regime_color(regime_state)
    re = regime_state == "STRONG_BULL" ? "🟢 " : regime_state == "WEAK_BULL" ? "🟩 " : regime_state == "SQUEEZE" ? "🟣 " : regime_state == "STRONG_BEAR" ? "🔴 " : regime_state == "WEAK_BEAR" ? "🟧 " : "⬜ "
    regime_tip = "Current market regime — drives ALL zone scoring.\n\n🟢 STRONG_BULL: Uptrend confirmed (ADX>25, EMA rising). Support zones get maximum bonus. Resistance zones get no bonus.\n🟩 WEAK_BULL: Mild uptrend. Support zones get +80% bonus.\n⬜ RANGE: Sideways market. Both zones scored equally.\n🟣 SQUEEZE: Bollinger Bands compressed — breakout coming. Watch for direction.\n🟧 WEAK_BEAR: Mild downtrend. Resistance zones get +80% bonus.\n🔴 STRONG_BEAR: Confirmed downtrend. Resistance gets max bonus.\n\nCurrent: " + regime_state + "  |  ADX: " + str.tostring(math.round(adx_val, 1))
    table.cell(g_dash, 0, dr, "Regime", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=regime_tip)
    table.cell(g_dash, 1, dr, re + regime_state, text_color=color.white, text_size=ts, text_halign=text.align_center, bgcolor=color.new(color.black, 0), tooltip=regime_tip)
    dr += 1

    // Market Structure — sits directly under Regime: both answer "which way is this chart leaning".
    ms_dash_col = not i_ms_enable ? color.new(color.gray, 30) : ms_trend == "BULL" ? color.new(#26a69a, 0) : ms_trend == "BEAR" ? color.new(#ef5350, 0) : color.new(#b0bec5, 0)
    ms_dash_emo = not i_ms_enable ? "⬜ " : ms_trend == "BULL" ? "🟢 " : ms_trend == "BEAR" ? "🔴 " : "⬜ "
    ms_dash_txt = not i_ms_enable ? "Off" : ms_dash_emo + ms_trend + (ms_event != "—" ? "  " + ms_event : "") + (ms_swing_lbl != "—" ? "  " + ms_swing_lbl : "")
    ms_dash_tip = not i_ms_enable ? "Market Structure engine is OFF.\n\nTurn it on in 🏗 Market Structure to score zones by whether they agree with the trend, and to see the level that flips it." : "🏗 Market Structure — is this chart making higher highs or lower lows?\n\nCurrent structure: " + ms_trend + "\nLast event: " + ms_event + "\nLatest swing: " + ms_swing_lbl + " (HH=higher high, HL=higher low, LH=lower high, LL=lower low)\n" + (na(ms_watch) ? "Level to watch: none yet — waiting for a confirmed swing" : "Level to watch: " + str.tostring(ms_watch, format.mintick) + " — a confirmed close beyond it flips the structure") + "\n\n── The two events ──\nBOS (Break of Structure) — price breaks a swing in the trend's own direction. Continuation.\nCHoCH (Change of Character) — price breaks a swing against the trend. First sign of a turn, and the earliest of all the signals here.\n\n── Effect on scoring ──\nSupport in BULL structure and resistance in BEAR structure get the full structure bonus (weight " + str.tostring(i_w_structure) + ").\nZones fighting the structure are penalised — price usually cuts straight through them.\nRANGE scores both sides neutrally.\n\n── Effect on trades ──\n" + (i_ms_gate_trades ? "Blocking is ON: no LONG plan while structure is BEAR, no SHORT plan while structure is BULL." : "Blocking is OFF: counter-structure setups are shown and flagged ⚠, never suppressed.")
    table.cell(g_dash, 0, dr, "🏗 Structure", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=ms_dash_tip)
    table.cell(g_dash, 1, dr, ms_dash_txt, text_color=ms_dash_col, text_size=ts, text_halign=text.align_center, bgcolor=color.new(color.black, 90), tooltip=ms_dash_tip)
    dr += 1

    // HTF Bias
    if dash_full
        mtf_col = not i_mtf_enable or mtf_bias == "—" ? color.new(color.gray, 30) : mtf_bias == "BULL" ? color.new(#26a69a, 0) : color.new(#ef5350, 0)
        mtf_txt = not i_mtf_enable ? "Off" : mtf_bias == "—" ? "—" : (mtf_bias == "BULL" ? "🟢 " : "🔴 ") + mtf_bias + " on " + mtf_res + "  " + str.tostring(math.round(mtf_streth, 1)) + " ATR"
        mtf_tip = not i_mtf_enable ? "Higher-Timeframe Bias is OFF.\n\nTurn it on in 🔭 Higher-Timeframe Bias to flag setups that fight the bigger picture." : "🔭 The trend one timeframe up.\n\nReading " + mtf_res + ": price is " + (mtf_bias == "BULL" ? "ABOVE" : "BELOW") + " its " + str.tostring(i_mtf_len) + " EMA by " + str.tostring(math.round(mtf_streth, 1)) + " ATR.\n\nDistance matters as much as side: 0.2 ATR from the EMA is a coin flip, 2 ATR is a committed trend.\n\n── How this differs from Structure ──\nStructure = swing highs and lows on THIS chart.\nHTF Bias = the trend on the chart above it.\nThey can disagree. When they do, you are trading a pullback — real, but it deserves a smaller size.\n\nA setup that fights this bias is flagged ⚠ on the chart label and in the Active Setup row. It is never blocked."
        table.cell(g_dash, 0, dr, "🔭 HTF Bias", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=mtf_tip)
        table.cell(g_dash, 1, dr, mtf_txt, text_color=mtf_col, text_size=ts, text_halign=text.align_center, tooltip=mtf_tip)
        dr += 1

    // Asset Class
    if dash_full
        ae = g_crypto ? "₿ " : g_forex ? "💱 " : g_index ? "📈 " : g_asset == "Futures" ? "⚡ " : g_sub5 ? "🔬 " : "📊 "
        al = (g_sub5 ? "Stock-Sub$5" : g_asset + (g_asset == "Stock" ? " [" + g_session + "]" : "")) + " · " + eff_mode
        asset_tip = "Auto-detected asset class, trading session, and the active Trading Mode preset.\n\nTrading Mode: " + eff_mode + (i_trading_mode == "Auto" ? "  (picked automatically from this chart's timeframe)" : "  (set manually)") + "\nThe preset scales zone width, pivot legs, detector lookbacks, bounce-confirm bars and approach distance. Swing = your raw settings, unscaled.\n\nAsset type determines zone width calculation:\n📊 Stock — ATR-based zones\n🔬 Stock Sub-$5 — Percent-based zones (ATR unreliable)\n₿ Crypto — 24/7, percent-based, no session breaks\n💱 Forex — Pip-based, session-aware (London/NY/Tokyo)\n📈 Index — Volume-agnostic (SPX has no real volume data)\n⚡ Futures — Rollover-aware\n\nSession (for stocks):\nPRE = Pre-market (4:00-9:30 ET)\nRTH = Regular Trading Hours (9:30-16:00 ET)\nAH = After Hours (16:00+)\n\nCurrent: " + g_asset + " | " + g_session
        table.cell(g_dash, 0, dr, "Asset / Session", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=asset_tip)
        table.cell(g_dash, 1, dr, ae + al, text_color=color.yellow, text_size=ts, text_halign=text.align_center, tooltip=asset_tip)
        dr += 1

    // Zone count by grade
    n_dash = array.size(g_zones)
    if dash_full
        na_cnt = 0
        nb_cnt = 0
        nc_cnt = 0
        if n_dash > 0
            for i = 0 to n_dash - 1
                g = array.get(g_zones, i).grade
                if g == "A"
                    na_cnt += 1
                else if g == "B"
                    nb_cnt += 1
                else if g == "C"
                    nc_cnt += 1
        zt = str.tostring(n_dash) + " (" + str.tostring(na_cnt) + "A/" + str.tostring(nb_cnt) + "B/" + str.tostring(nc_cnt) + "C)"
        zones_tip = "Total S/R zones detected and scored.\n\nGrade system (0-100 score):\n🏅 A = Excellent (≥80) — high-conviction zones, react strongly\n🥈 B = Good (65-79) — reliable, usually hold\n🥉 C = Moderate (50-64) — use with confirmation\n📉 D = Weak (<50) — hidden by default\n\nOn the chart:\n• Larger glow = higher score\n• Cyan/electric = strong SUPPORT\n• Red/electric = strong RESISTANCE\n• Score bar on right = visual strength meter\n• ✦3 = 3 overlapping zone sources (confluence)\n\nCurrently: " + str.tostring(na_cnt) + " Grade A  |  " + str.tostring(nb_cnt) + " Grade B  |  " + str.tostring(nc_cnt) + " Grade C"
        table.cell(g_dash, 0, dr, "Active Zones", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=zones_tip)
        table.cell(g_dash, 1, dr, zt, text_color=color.white, text_size=ts, text_halign=text.align_center, tooltip=zones_tip)
        dr += 1

    // Nearest Resistance
    nr_p = 999999.0
    nr_g = "—"
    nr_c = 0
    if n_dash > 0
        for i = 0 to n_dash - 1
            z = array.get(g_zones, i)
            if not z.is_support and z.mid > close and z.mid < nr_p
                nr_p := z.mid
                nr_g := z.grade
                nr_c := z.confluence_count
    rd = atr_val > 0 and nr_p < 999999.0 ? (nr_p - close) / atr_val : 0.0
    rt = nr_p < 999999.0 ? str.tostring(nr_p, format.mintick) + " [" + nr_g + "] " + str.tostring(math.round(rd, 1)) + " ATR" : "—"
    r_tip = "Nearest RESISTANCE zone above current price.\n\nFormat: $Price [Grade] X.X ATR\n\nATR = Average True Range (volatility unit)\n1 ATR = one typical daily move\n\nRisk interpretation:\n• <0.5 ATR away → DANGER: price likely to stall or reject\n• 0.5-1.5 ATR away → Monitor closely\n• >1.5 ATR away → Room to run\n\nGrade A resistance = especially dangerous. Consider reducing risk or taking partial profits.\n\nCurrent: " + rt
    table.cell(g_dash, 0, dr, "Nearest R", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=r_tip)
    table.cell(g_dash, 1, dr, rt, text_color=color.new(#ef5350, 0), text_size=ts, text_halign=text.align_center, tooltip=r_tip)
    dr += 1

    // Nearest Support
    ns_p = 0.0
    ns_g = "—"
    if n_dash > 0
        for i = 0 to n_dash - 1
            z = array.get(g_zones, i)
            if z.is_support and z.mid < close and z.mid > ns_p
                ns_p := z.mid
                ns_g := z.grade
    sd   = atr_val > 0 and ns_p > 0 ? (close - ns_p) / atr_val : 0.0
    st   = ns_p > 0 ? str.tostring(ns_p, format.mintick) + " [" + ns_g + "] " + str.tostring(math.round(sd, 1)) + " ATR" : "—"
    s_tip = "Nearest SUPPORT zone below current price.\n\nFormat: $Price [Grade] X.X ATR\n\nATR = Average True Range (volatility unit)\n1 ATR = one typical daily move\n\nStrength interpretation:\n• <0.5 ATR away → Strong floor nearby — watch for bounce\n• 0.5-1.5 ATR away → Monitor — zone still relevant\n• >1.5 ATR away → More room to fall\n\nGrade A support = key institutional buy zone.\nCurrent: " + st
    table.cell(g_dash, 0, dr, "Nearest S", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=s_tip)
    table.cell(g_dash, 1, dr, st, text_color=color.new(#26a69a, 0), text_size=ts, text_halign=text.align_center, tooltip=s_tip)
    dr += 1

    // ATR% Rank
    if dash_full
        atc      = atr_rank > 70 ? color.new(#ef5350, 10) : atr_rank > 40 ? color.yellow : color.new(#26a69a, 10)
        atr_tip  = "Volatility rank (0-100) vs last 100 bars.\n\nATR = Average True Range = daily move size.\nCurrent ATR: " + str.tostring(math.round(atr_val, 4)) + "   ATR%: " + str.tostring(math.round(atr_pct, 2)) + "%\n\n🔴 >70: HIGH volatility — zones may be wider than usual. Widen stops. Big moves expected.\n🟡 40-70: NORMAL volatility — standard zone behavior.\n🟢 <40: LOW volatility — squeeze forming. Tight zones. Breakout risk!\n\nCurrent rank: " + str.tostring(math.round(atr_rank)) + "/100"
        table.cell(g_dash, 0, dr, "ATR% Rank", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=atr_tip)
        table.cell(g_dash, 1, dr, str.tostring(math.round(atr_rank)) + "/100", text_color=atc, text_size=ts, text_halign=text.align_center, tooltip=atr_tip)
        dr += 1

    // Active Warning
    wc       = warning_severity == "HIGH" ? color.new(#ef5350, 0) : warning_severity == "WARN" ? color.yellow : color.new(#b0bec5, 0)
    warn_tip = "Active warning generated by the indicator.\n\n🔴 HIGH severity:\n• REGIME_SHIFT — market changed direction near Grade-A zone\n• TRAP_SUSPECTED — breakout on low volume = likely fake move\n• SWEEP_IMMINENT — price approaching liquidity pool at speed\n• FLIP_RETEST — price retesting a zone that flipped polarity (strong continuation signal)\n\n🟡 WARN severity:\n• ZONE_CLUSTER_AHEAD — 3+ zones overlapping in your path\n• ZONE_APPROACH — Grade A/B zone nearby\n\n🔵 INFO severity:\n• FVG_FILLING — Fair Value Gap being tested\n\nCurrent: " + g_warning + "  |  Severity: " + warning_severity
    table.cell(g_dash, 0, dr, "⚠️ Warning", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=warn_tip)
    table.cell(g_dash, 1, dr, g_warning, text_color=wc, text_size=ts, text_halign=text.align_center, bgcolor=color.new(color.black, 90), tooltip=warn_tip)
    dr += 1

    // AVWAP
    if dash_full
        av_txt   = not na(avwap_value) ? str.tostring(avwap_value, format.mintick) + " (" + g_avwap_label + ")" : "—"
        av_col   = not na(avwap_value) ? (close > avwap_value ? color.new(#26a69a, 0) : color.new(#ef5350, 0)) : color.new(color.gray, 30)
        av_pos   = not na(avwap_value) ? (close > avwap_value ? "ABOVE AVWAP = premium (expensive)" : "BELOW AVWAP = discount (cheap)") : "No anchor yet"
        av_tip   = "⚓ Anchored VWAP = PURPLE LINE on chart.\n\nThe purple line starts from: " + g_avwap_label + "\n\nWhat it means:\nVWAP = Volume-Weighted Average Price from a key event.\nInstitutions use this as their fair value reference.\n\nPrice " + av_pos + "\n\nWhen price approaches AVWAP = institutional magnet.\nZones overlapping with AVWAP = extra strong.\n\nAVWAP value: " + av_txt
        table.cell(g_dash, 0, dr, "⚓ AVWAP", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=av_tip)
        table.cell(g_dash, 1, dr, av_txt, text_color=av_col, text_size=ts, text_halign=text.align_center, tooltip=av_tip)
        dr += 1

    // Squeeze
    if dash_full
        sq_t     = is_squeeze ? "⚡ SQUEEZE — BREAKOUT RISK" : "✅ Normal"
        sq_c     = is_squeeze ? color.new(#ab47bc, 0) : color.new(#b0bec5, 0)
        sq_tip   = "Bollinger Band squeeze detector.\n\nA SQUEEZE happens when:\n• BB bandwidth is in bottom 10% (very narrow bands)\n• ATR is also in bottom 15% (low volatility)\n\nThis means energy is COMPRESSED — a big move is coming.\nYou don't know the direction yet!\n\nWhat to do during squeeze:\n• Watch Grade-A zones as breakout targets\n• The zone that price breaks THROUGH = likely direction\n• Volume spike = confirms the breakout direction\n\nCurrent BBW rank: " + str.tostring(math.round(bbw_rank)) + "/100"
        table.cell(g_dash, 0, dr, "Squeeze", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=sq_tip)
        table.cell(g_dash, 1, dr, sq_t, text_color=sq_c, text_size=ts, text_halign=text.align_center, tooltip=sq_tip)
        dr += 1

    // Zone Hit Rate
    if dash_full
        hit_rate = g_tests_total > 0 ? math.round(g_hits_total / g_tests_total * 100) : 0
        hr_col   = hit_rate >= 65 ? color.new(#26a69a, 0) : hit_rate >= 45 ? color.yellow : color.new(#ef5350, 0)
        hr_txt   = g_tests_total > 0 ? str.tostring(hit_rate) + "% (" + str.tostring(g_hits_total) + "/" + str.tostring(g_tests_total) + ")" : "—"
        hr_tip   = "Historical zone bounce rate on THIS chart.\n\nHits = price entered zone AND bounced back\nTests = total zone touches\n\nInterpretation:\n🟢 >65%: Zones are working well on this chart. Trust them.\n🟡 45-65%: Moderate. Use with other confirmation.\n🔴 <45%: Zones being broken frequently. Be careful!\n\nThis is not the same question as 🎯 Setup Accuracy below — that one asks whether the TRADE PLANS paid, this one asks whether the zones held.\n\nNote: Only counts since indicator was loaded.\nCurrent: " + str.tostring(g_hits_total) + " bounces from " + str.tostring(g_tests_total) + " tests"
        table.cell(g_dash, 0, dr, "Zone Hit Rate", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=hr_tip)
        table.cell(g_dash, 1, dr, hr_txt, text_color=hr_col, text_size=ts, text_halign=text.align_center, tooltip=hr_tip)
        dr += 1

    // Sources separator
    if dash_full
        src_active = (i_enable_swing ? "📐 " : "") + (i_enable_ob ? "🧱 " : "") + (i_enable_vp ? "📊 " : "") + (i_enable_fvg ? "💨 " : "") + (i_enable_liq ? "💧 " : "") + (i_enable_avwap ? "⚓ " : "") + (i_enable_levels ? "🗓 " : "") + (i_gap_enable ? "🕳" : "")
        src_tip   = "Active zone detection engines:\n\n📐 SW = Swing Pivots (classic highs/lows)\n🧱 OB = Order Blocks (institutional candles)\n📊 POC = Volume Point of Control (high-volume clusters)\n💨 FVG = Fair Value Gaps (price imbalances)\n💧 LIQ = Liquidity Pools (equal high/low clusters)\n⚓ AV = Anchored VWAP (catalyst price anchors)\n🗓 LVL = Key Levels (Prior Day/Week High-Low + Premarket High-Low)\n🕳 GAP = Unfilled gaps, classified by size in ATR\n\nToggle each on/off in Zone Detection settings."
        table.cell(g_dash, 0, dr, "── Sources ──", text_color=color.new(#b0bec5, 0), text_size=ts, text_halign=text.align_left, tooltip=src_tip)
        table.cell(g_dash, 1, dr, src_active, text_color=color.new(color.silver, 0), text_size=ts, text_halign=text.align_center, tooltip=src_tip)
        dr += 1

    // Scenario
    if dash_full
        scen     = get_scenario()
        scen_tip = "Scenario derived from regime + nearest S/R positions.\n\nBased on rule-based logic from observed market patterns.\nNOT a guarantee — always use with your own analysis.\n\nLogic:\n• Squeeze → breakout expected\n• Bull regime + S closer → hold S and rally\n• Bull regime + R very close → stall likely\n• Bear regime + R closer → reject and fall\n• Bear regime + S very close → break likely\n• Otherwise → range-bound fade extremes\n\nPast performance does not predict future results."
        table.cell(g_dash, 0, dr, "Scenario", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=scen_tip)
        table.cell(g_dash, 1, dr, scen, text_color=color.new(#29b6f6, 0), text_size=ts, text_halign=text.align_center, tooltip=scen_tip)
        dr += 1

    // Adaptive Learning Status
    if dash_full
        learn_obs    = g_n_bounce + g_n_break
        learn_active = learn_obs >= 20
        learn_txt    = learn_active ? "Active — " + str.tostring(learn_obs) + " obs" : "Learning " + str.tostring(learn_obs) + "/20"
        learn_col    = learn_active ? color.new(#00e5ff, 0) : color.yellow
        // Show dominant adapted factor
        vol_ratio_l    = g_n_bounce >= 10 and g_n_break >= 10 ? (g_lb_vol / g_n_bounce) / math.max(g_lbr_vol / math.max(g_n_break, 1), 0.001) : 1.0
        htf_ratio_l    = g_n_bounce >= 10 and g_n_break >= 10 ? (g_lb_htf / g_n_bounce) / math.max(g_lbr_htf / math.max(g_n_break, 1), 0.001) : 1.0
        conf_ratio_l   = g_n_bounce >= 10 and g_n_break >= 10 ? (g_lb_conf / g_n_bounce) / math.max(g_lbr_conf / math.max(g_n_break, 1), 0.001) : 1.0
        struct_ratio_l = g_n_bounce >= 10 and g_n_break >= 10 ? (g_lb_struct / g_n_bounce) / math.max(g_lbr_struct / math.max(g_n_break, 1), 0.001) : 1.0
        best_factor    = struct_ratio_l >= vol_ratio_l and struct_ratio_l >= htf_ratio_l and struct_ratio_l >= conf_ratio_l ? "Structure fit" : vol_ratio_l >= htf_ratio_l and vol_ratio_l >= conf_ratio_l ? "Vol-at-touch" : htf_ratio_l >= conf_ratio_l ? "HTF origin" : "Confluence"
        learn_tip = "🧠 Adaptive Weight Engine\n\nScoring weights re-calibrate from observed bounce/break outcomes on this chart.\n\nHow it works:\n• On each zone's first BOUNCE, the indicator records which factors were present (vol at touch, HTF origin, confluence, freshness, structure fit)\n• On each zone's first BREAK, same thing\n• After 20+ distinct zone outcomes, five scoring weights adjust toward the factors that actually separated bounces from breaks\n• Factors more common on bounces get boosted weight; factors more common on breaks get reduced weight\n\nThis is the honest answer to 'how much should structure count' — measured on your chart instead of picked by hand.\n\nNote: weights reset when the indicator is reloaded (Pine Script limitation — no persistent storage).\nBase weights apply until 20+ observations are collected.\n\nCurrent status: " + str.tostring(g_n_bounce) + " bounce events | " + str.tostring(g_n_break) + " break events observed\n" + (learn_active ? "✅ Weights adjusted — strongest factor: " + best_factor : "⏳ Collecting data — " + str.tostring(20 - learn_obs) + " more observations needed\nUsing base weights for now")
        table.cell(g_dash, 0, dr, "🧠 Adaptive Weights", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=learn_tip)
        table.cell(g_dash, 1, dr, learn_txt, text_color=learn_col, text_size=ts, text_halign=text.align_center, tooltip=learn_tip)
        dr += 1

    // Entry Trigger — sits directly above Active Setup: it is the "act now" line for that plan.
    trg_col = not i_trig_enable ? color.new(color.gray, 30) : g_tp_state == "READY" ? color.new(#26a69a, 0) : g_tp_state == "WAIT" ? color.yellow : color.new(#b0bec5, 0)
    trg_txt = not i_trig_enable ? "Off" : g_tp_dir == "—" ? "—" : g_tp_state == "READY" ? "✅ " + (g_tp_trigger != "—" ? g_tp_trigger : "at zone") : g_tp_state == "WAIT" ? "⏳ at zone, no candle yet" : "📍 " + str.tostring(math.round(g_tp_dist_atr, 1)) + " ATR to zone"
    trg_tip = not i_trig_enable ? "Candle Trigger is OFF — a plan reads READY as soon as price reaches its zone, with no candle confirmation.\n\nTurn it on in 🕯 Entry Trigger." : "🕯 The zone says WHERE. The candle says WHEN.\n\nThree states:\n📍 APPROACH — price is still travelling to the zone. Nothing to do yet.\n⏳ WAIT — price has reached the zone but no reversal candle has closed. The level is live; the market has not answered.\n✅ READY — a reversal candle closed within the last " + str.tostring(i_trig_lookback) + " bars. This is the moment.\n\n── The three patterns ──\nEngulfing — body fully covers the previous body, opposite direction\nPin Bar — rejection wick at least " + str.tostring(math.round(i_trig_pin_pct * 100)) + "% of the candle, small body\nInside Break — compression, then a close beyond it\n\n💤 next to a setup means volume dried up as price arrived — quiet sellers, which is what precedes a clean bounce.\n\nThe trigger is a gate, never a score. Counting a reversal candle inside an order block would score the same event twice."
    table.cell(g_dash, 0, dr, "🕯 Entry Trigger", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=trg_tip)
    table.cell(g_dash, 1, dr, trg_txt, text_color=trg_col, text_size=ts, text_halign=text.align_center, tooltip=trg_tip)
    dr += 1

    // Active Trade Plan Setup
    tp_row_txt = "—"
    tp_row_col = color.new(#b0bec5, 0)
    tp_row_bg  = color.new(color.black, 90)
    if i_enable_trade_plan and g_tp_dir != "—" and not na(g_tp_entry)
        tp_is_long  = g_tp_dir == "LONG"
        tp_row_txt := (g_tp_state == "READY" ? "✅ " : g_tp_state == "WAIT" ? "⏳ " : "📍 ") + (tp_is_long ? "▲ BUY" : "▼ SELL") + (g_tp_vs_struct or g_tp_vs_mtf ? " ⚠" : "") + (g_tp_dryup ? " 💤" : "") + " @" + str.tostring(g_tp_entry, format.mintick) + "  SL " + str.tostring(g_tp_stop, format.mintick) + "  TGT " + str.tostring(g_tp_target, format.mintick) + "  " + str.tostring(g_tp_shares) + "sh  R:R " + str.tostring(math.round(g_tp_rr, 1))
        tp_row_col := tp_is_long ? color.new(#26a69a, 0) : color.new(#ef5350, 0)
        tp_row_bg  := tp_is_long ? color.new(#004d40, 60) : color.new(#7f0000, 60)
    tp_plan_tip = i_enable_trade_plan and g_tp_dir != "—" and not na(g_tp_entry) ? "Active Trade Plan\n\n" + (g_tp_vs_struct ? "⚠ THIS SETUP FIGHTS THE STRUCTURE\nMarket structure is " + ms_trend + " and this is a " + g_tp_dir + ". Counter-structure setups fail more often — the zone already carries a score penalty for it. Size down, or wait for the structure to flip.\n\n" : "") + "Direction: " + g_tp_dir + "\nEntry: $" + str.tostring(g_tp_entry, format.mintick) + "\nStop Loss: $" + str.tostring(g_tp_stop, format.mintick) + "\nTarget: $" + str.tostring(g_tp_target, format.mintick) + "\nPosition: " + str.tostring(g_tp_shares) + " shares\nR:R: " + str.tostring(math.round(g_tp_rr, 2)) + "\nRisk: $" + str.tostring(math.round(i_account_size * i_risk_pct / 100, 0)) + "\nZone score: " + str.tostring(math.round(g_tp_score)) + "/100\n\nLines are drawn on chart.\nHover the chart labels for more detail." : "No qualifying setup right now.\n\nRequirements:\n• Grade A/B zone within 1.5 ATR\n• Regime supports direction\n• R:R ≥ " + str.tostring(i_min_rr)
    table.cell(g_dash, 0, dr, "💰 Active Setup", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=tp_plan_tip)
    table.cell(g_dash, 1, dr, tp_row_txt, text_color=tp_row_col, text_size=ts, text_halign=text.align_center, bgcolor=tp_row_bg, tooltip=tp_plan_tip)
    dr += 1

    // Setup Accuracy — did issued plans reach target before stop?
    if dash_full
        acc_col = tpa_pct < 0 ? color.new(color.gray, 30) : tpa_pct >= 55 ? color.new(#26a69a, 0) : tpa_pct >= 40 ? color.yellow : color.new(#ef5350, 0)
        acc_txt = tpa_pct < 0 ? "No closed setups yet" : str.tostring(tpa_pct) + "%  (" + str.tostring(tpa_win) + "W / " + str.tostring(tpa_loss) + "L)" + (array.size(tpa_dir) > 0 ? "  +" + str.tostring(array.size(tpa_dir)) + " open" : "")
        acc_tip = "🎯 Did the trade plans this indicator issued actually work?\n\nEvery plan is recorded when it fires, then watched until price hits its target or its stop. This is a different question from Zone Hit Rate above: that one counts whether zones held, this one counts whether following the plan would have paid.\n\nCurrent: " + (tpa_pct < 0 ? "no plan has resolved yet" : str.tostring(tpa_win) + " reached target, " + str.tostring(tpa_loss) + " hit stop") + (array.size(tpa_dir) > 0 ? ", " + str.tostring(array.size(tpa_dir)) + " still open" : "") + "\n\n── Read it honestly ──\nWhen one bar spans both the stop and the target, it is counted as a LOSS. The pessimistic read is the truthful one — you cannot know which came first inside a bar.\nMinimum R:R is " + str.tostring(i_min_rr) + ", so even a 40% rate is profitable on paper.\nThe count resets whenever the indicator reloads — Pine has no persistent storage.\nA small sample means nothing. Wait for 20+ before trusting the number."
        table.cell(g_dash, 0, dr, "🎯 Setup Accuracy", text_color=color.white, text_size=ts, text_halign=text.align_left, tooltip=acc_tip)
        table.cell(g_dash, 1, dr, acc_txt, text_color=acc_col, text_size=ts, text_halign=text.align_center, tooltip=acc_tip)
        dr += 1

// ═══════════════════════════════════════════════════════════
// LEGEND — decodes every symbol used on the chart
// ═══════════════════════════════════════════════════════════

var table g_legend = na

if i_show_legend and barstate.islast
    lts = get_text_size(i_dash_size)
    g_legend := table.new(get_legend_pos(i_dash_pos), columns=2, rows=7, bgcolor=color.new(#000000, 10), border_color=color.new(color.gray, 0), border_width=1)

    table.cell(g_legend, 0, 0, "📖 How to read the chart", bgcolor=color.new(#1565c0, 10), text_color=color.white, text_size=lts, text_halign=text.align_center, tooltip="Every symbol the indicator draws, decoded.\n\nHide this panel with Show Legend in 📊 Dashboard settings.")
    table.merge_cells(g_legend, 0, 0, 1, 0)

    table.cell(g_legend, 0, 1, "Zone source", text_color=color.new(#b0bec5, 0), text_size=lts, text_halign=text.align_left, tooltip="Which detector found the zone. A zone confirmed by several detectors scores higher — that is what ✦ counts.")
    table.cell(g_legend, 1, 1, "📐 Swing  🧱 OB  📊 POC  💨 FVG  💧 Liq  ⚓ AVWAP  🗓 Level", text_color=color.white, text_size=lts, text_halign=text.align_center, tooltip="📐 Swing Pivot — classic swing high or low\n🧱 Order Block — last candle before an impulsive move, volume-confirmed\n📊 Volume POC — the price where most volume traded\n💨 Fair Value Gap — a 3-candle imbalance price skipped over\n💧 Liquidity Pool — equal highs or lows where stops cluster\n⚓ Anchored VWAP — fair value measured from a catalyst event\n🗓 Key Level — Prior Day/Week High-Low, Premarket High-Low")

    table.cell(g_legend, 0, 2, "Colour", text_color=color.new(#b0bec5, 0), text_size=lts, text_halign=text.align_left, tooltip="Hue tells you the side. Brightness tells you the score.")
    table.cell(g_legend, 1, 2, "🔵 support   🔴 resistance   brighter = stronger", text_color=color.white, text_size=lts, text_halign=text.align_center, tooltip="Cyan and green boxes are SUPPORT — price is expected to bounce up off them.\nRed and orange boxes are RESISTANCE — price is expected to reject down off them.\n\nThe brighter and more saturated the box, the higher its score and the closer it is to price.\nThe thin bright stripe inside each box is the contact edge — the exact price where the reaction is expected.")

    table.cell(g_legend, 0, 3, "Zone label", text_color=color.new(#b0bec5, 0), text_size=lts, text_halign=text.align_left, tooltip="The text beside each zone. Hover any zone label on the chart for its full breakdown.")
    table.cell(g_legend, 1, 3, "78  5/7  ✦3  🔁  ⬆BOUNCE / ⚠BREAK", text_color=color.white, text_size=lts, text_halign=text.align_center, tooltip="78 — the zone's score out of 100\n5/7 — it held 5 of the 7 times price tested it\n+0.4ᴬ — average distance price travelled away from it after a touch, in ATR\n✦3 — three different detectors confirmed this same zone\n🔁 — the zone flipped polarity at least once and is still standing (former resistance now support, or the reverse)\n⬆ BOUNCE — the move arriving here looks exhausted, a bounce is likely\n⚠ BREAK — the move arriving here still has energy, a break is likely")

    table.cell(g_legend, 0, 4, "Grade", text_color=color.new(#b0bec5, 0), text_size=lts, text_halign=text.align_left, tooltip="Score bands. Grade D is hidden unless you turn it on.")
    table.cell(g_legend, 1, 4, "A ≥80   B ≥65   C ≥50   D <50 (hidden)", text_color=color.white, text_size=lts, text_halign=text.align_center, tooltip="A — high conviction, price reacts strongly here\nB — reliable, usually holds\nC — moderate, wait for confirmation\nD — weak, hidden by default in 🎨 Visual Settings\n\nThe white border thickness also encodes origin: thickest = Weekly, medium = Daily, thin = this timeframe.")

    table.cell(g_legend, 0, 5, "Lines", text_color=color.new(#b0bec5, 0), text_size=lts, text_halign=text.align_left, tooltip="The non-box drawings.")
    table.cell(g_legend, 1, 5, "🟣 AVWAP   ⋯ structure   ┄ entry/stop/target   🔮 pace", text_color=color.white, text_size=lts, text_halign=text.align_center, tooltip="🟣 Purple solid — Anchored VWAP, institutional fair value from the last catalyst\n⋯ Dotted green or red — the swing level whose break flips the market structure\n┄ Dashed blue — trade plan entry\n┄ Dashed red — trade plan stop loss\n┄ Dashed green — trade plan target\n🔮 Dashed diagonal — projected path to the target, ending at the estimated bar count at the current pace\n\nThe shaded chart background means price is currently inside a Grade-A zone.")

    table.cell(g_legend, 0, 6, "Setup state", text_color=color.new(#b0bec5, 0), text_size=lts, text_halign=text.align_left, tooltip="The badge on the trade plan label and the Active Setup row.")
    table.cell(g_legend, 1, 6, "📍 approach   ⏳ wait   ✅ ready   ⚠ against   💤 quiet", text_color=color.white, text_size=lts, text_halign=text.align_center, tooltip="📍 APPROACH — price is still travelling to the zone\n⏳ WAIT — price reached the zone, no reversal candle has closed yet\n✅ READY — a reversal candle fired; this is the moment to act\n⚠ — the setup fights the market structure or the higher-timeframe bias. Not blocked, but size down\n💤 — volume dried up as price arrived. Quiet sellers, which is what precedes a clean bounce\n\n🕳 on a zone label marks an unfilled gap: Common, Runaway or Breakaway by its size in ATR.")

// ═══════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════

warn_fired = g_warning != "—" and barstate.isconfirmed

// ── Market Structure alerts — fire on the bar the break confirms ──
ms_event_fired = i_ms_enable and barstate.isconfirmed and ms_event_bar == bar_index
if ms_event_fired
    alert("🏗 BOSS MODE STRUCTURE " + ms_event + " — " + syminfo.ticker + " @ " + str.tostring(close, format.mintick) + " | Structure now: " + ms_trend + " | Regime: " + regime_state, alert.freq_once_per_bar_close)

alertcondition(i_ms_enable and ms_choch_now,   "Structure — CHoCH (trend turning)", "🏗 CHoCH: {{ticker}} @ {{close}} — structure changing character")
alertcondition(i_ms_enable and ms_event_bar == bar_index and not ms_choch_now, "Structure — BOS (continuation)", "🏗 BOS: {{ticker}} @ {{close}} — structure break, trend continues")

if warn_fired
    alert_msg = i_alert_json ? build_json_alert(g_warning, warning_severity, warning_zone_src, warning_zone_score, warning_zone_grade, 1) : "⚠️ BOSS MODE [" + warning_severity + "] " + g_warning + " — " + syminfo.ticker + " @ " + str.tostring(close, format.mintick) + " | Regime: " + regime_state
    alert(alert_msg, alert.freq_once_per_bar_close)

alertcondition(warn_fired,                              "Any Warning",        "⚠️ BOSS MODE Warning: {{ticker}} @ {{close}}")
alertcondition(g_warning == "SWEEP_IMMINENT",           "Sweep Imminent",     "🌊 Sweep: {{ticker}} @ {{close}}")
alertcondition(g_warning == "REGIME_SHIFT",             "Regime Shift",       "🔄 Regime shift: {{ticker}}")
alertcondition(g_warning == "TRAP_SUSPECTED",           "Trap Suspected",     "🪤 Trap: {{ticker}} @ {{close}}")
alertcondition(g_warning == "FLIP_RETEST",              "Flip Retest",        "🔁 Flip retest: {{ticker}} @ {{close}}")
alertcondition(g_warning == "ZONE_APPROACH",            "Zone Approach",      "📍 Approaching: {{ticker}} @ {{close}}")
alertcondition(is_squeeze and not is_squeeze[1],        "Squeeze Detected",   "⚡ Squeeze: {{ticker}}")

// ── Trade Plan alerts — fire once per setup episode, not every bar it stays valid ──
tp_new_setup = i_enable_trade_plan and g_tp_dir != "—" and not na(g_tp_entry) and barstate.isconfirmed and (g_tp_dir != g_tp_last_dir or g_tp_zone_id != g_tp_last_zone_id)
if tp_new_setup
    tp_alert_txt = "💰 BOSS MODE " + g_tp_dir + " SETUP" + (g_tp_vs_struct ? " ⚠ AGAINST STRUCTURE (" + ms_trend + ")" : "") + " — " + syminfo.ticker + " @ " + str.tostring(close, format.mintick) + "\nEntry: $" + str.tostring(g_tp_entry, format.mintick) + " | Stop: $" + str.tostring(g_tp_stop, format.mintick) + " | Target: $" + str.tostring(g_tp_target, format.mintick) + "\n" + str.tostring(g_tp_shares) + " shares | R:R " + str.tostring(math.round(g_tp_rr, 1)) + " | Zone Score: " + str.tostring(math.round(g_tp_score)) + "/100 | Regime: " + regime_state
    alert(tp_alert_txt, alert.freq_once_per_bar_close)
    g_tp_last_dir     := g_tp_dir
    g_tp_last_zone_id := g_tp_zone_id
if g_tp_dir == "—"
    g_tp_last_dir     := "—"
    g_tp_last_zone_id := -1

// ── Entry-trigger alert: the moment a plan turns actionable, keyed per direction+zone so it fires
// once per setup rather than every bar the trigger stays fresh. ──
var string tp_last_ready_key = ""
tp_ready_key = g_tp_dir + "|" + str.tostring(g_tp_zone_id)
tp_ready_now = i_enable_trade_plan and barstate.isconfirmed and g_tp_state == "READY" and g_tp_dir != "—" and tp_ready_key != tp_last_ready_key
if tp_ready_now
    tp_last_ready_key := tp_ready_key
    alert("✅ BOSS MODE " + g_tp_dir + " READY — " + syminfo.ticker + " @ " + str.tostring(close, format.mintick) + "\nTrigger: " + g_tp_trigger + (g_tp_dryup ? "  💤 volume dry-up" : "") + (g_tp_vs_struct or g_tp_vs_mtf ? "\n⚠ Fights " + (g_tp_vs_struct ? "structure" : "") + (g_tp_vs_struct and g_tp_vs_mtf ? " and " : "") + (g_tp_vs_mtf ? mtf_res + " bias" : "") : "") + "\nEntry: $" + str.tostring(g_tp_entry, format.mintick) + " | Stop: $" + str.tostring(g_tp_stop, format.mintick) + " | Target: $" + str.tostring(g_tp_target, format.mintick) + "\n" + str.tostring(g_tp_shares) + " shares | R:R " + str.tostring(math.round(g_tp_rr, 1)), alert.freq_once_per_bar_close)
if g_tp_dir == "—"
    tp_last_ready_key := ""

alertcondition(tp_ready_now, "Entry Trigger — Setup READY", "✅ READY: {{ticker}} @ {{close}} — candle trigger fired at the zone")
alertcondition(i_enable_trade_plan and g_tp_dir == "LONG"  and not na(g_tp_entry),  "Trade Plan — LONG Setup",  "💰 LONG: {{ticker}} Entry @{{close}} | Check dashboard for full plan")
alertcondition(i_enable_trade_plan and g_tp_dir == "SHORT" and not na(g_tp_entry),  "Trade Plan — SHORT Setup", "💰 SHORT: {{ticker}} Entry @{{close}} | Check dashboard for full plan")

// ═══════════════════════════════════════════════════════════
// SIMPLE VIEW — clear S/R lines on chart for quick reading
// ═══════════════════════════════════════════════════════════

var box    sv_r_box   = na
var box    sv_s_box   = na
var label  sv_r_lbl   = na
var label  sv_s_lbl   = na

if i_show_simple and barstate.islast
    box.delete(sv_r_box)
    box.delete(sv_s_box)
    label.delete(sv_r_lbl)
    label.delete(sv_s_lbl)

    // Find nearest R and S — store full zone boundaries
    sv_r_top   = 999999.0
    sv_r_bot   = 999999.0
    sv_r_mid   = 999999.0
    sv_r_score = 0.0
    sv_s_top   = 0.0
    sv_s_bot   = 0.0
    sv_s_mid   = 0.0
    sv_s_score = 0.0
    n_sv = array.size(g_zones)
    if n_sv > 0
        for i = 0 to n_sv - 1
            z = array.get(g_zones, i)
            if not z.is_support and z.mid > close and z.mid < sv_r_mid
                sv_r_top   := z.top
                sv_r_bot   := z.bottom
                sv_r_mid   := z.mid
                sv_r_score := z.score
            if z.is_support and z.mid < close and z.mid > sv_s_mid
                sv_s_top   := z.top
                sv_s_bot   := z.bottom
                sv_s_mid   := z.mid
                sv_s_score := z.score

    // Minimum visual height for Simple View boxes — zones thinner than this get padded
    sv_min_h = atr_val * 0.18

    // Draw RESISTANCE box + centered label
    if sv_r_mid < 999999.0
        r_atr      = atr_val > 0 ? (sv_r_mid - close) / atr_val : 0.0
        r_vis_top  = math.max(sv_r_top, sv_r_mid + sv_min_h * 0.5)
        r_vis_bot  = math.min(sv_r_bot, sv_r_mid - sv_min_h * 0.5)
        r_box_h    = r_vis_top - r_vis_bot
        // Font size scales with box height — larger zone = larger text
        r_lbl_sz   = r_box_h > atr_val * 0.6 ? size.large : r_box_h > atr_val * 0.3 ? size.normal : size.small
        r_col_fill = sv_r_score >= 80 ? color.new(#ef5350, 65) : sv_r_score >= 65 ? color.new(#ff5722, 70) : color.new(#ff9800, 75)
        r_col_bdr  = sv_r_score >= 80 ? color.new(#ef5350, 0) : sv_r_score >= 65 ? color.new(#ff5722, 0) : color.new(#ff9800, 0)
        // Dark label background → white text always readable (dark red bg regardless of box color)
        r_lbl_bg   = sv_r_score >= 80 ? color.new(#7f0000, 10) : sv_r_score >= 65 ? color.new(#bf360c, 10) : color.new(#e65100, 10)
        r_str      = sv_r_score >= 80 ? "⬇ STRONG RESISTANCE" : sv_r_score >= 65 ? "⬇ RESISTANCE" : "⬇ RESISTANCE (weak)"
        r_lbl_txt  = r_str + "   $" + str.tostring(sv_r_mid, format.mintick) + "   " + str.tostring(math.round(r_atr, 1)) + " ATR away"
        sv_r_box  := box.new(bar_index - 80, r_vis_top, bar_index + 25, r_vis_bot, border_color=r_col_bdr, border_width=2, bgcolor=r_col_fill, extend=extend.right)
        sv_r_lbl  := label.new(bar_index - 30, sv_r_mid, r_lbl_txt, color=r_lbl_bg, textcolor=color.white, style=label.style_label_center, size=r_lbl_sz, tooltip="Nearest RESISTANCE zone.\n\nZone: $" + str.tostring(sv_r_bot, format.mintick) + " — $" + str.tostring(sv_r_top, format.mintick) + "\n\nPrice must close ABOVE $" + str.tostring(sv_r_top, format.mintick) + " to break out.\nUntil then — expect price to stall or reverse here.\n\nScore: " + str.tostring(math.round(sv_r_score)) + "/100\nDistance: " + str.tostring(math.round(r_atr, 1)) + " ATR")

    // Draw SUPPORT box + centered label
    if sv_s_mid > 0
        s_atr      = atr_val > 0 ? (close - sv_s_mid) / atr_val : 0.0
        s_vis_top  = math.max(sv_s_top, sv_s_mid + sv_min_h * 0.5)
        s_vis_bot  = math.min(sv_s_bot, sv_s_mid - sv_min_h * 0.5)
        s_box_h    = s_vis_top - s_vis_bot
        // Font size scales with box height
        s_lbl_sz   = s_box_h > atr_val * 0.6 ? size.large : s_box_h > atr_val * 0.3 ? size.normal : size.small
        s_col_fill = sv_s_score >= 80 ? color.new(#00e5ff, 65) : sv_s_score >= 65 ? color.new(#00c853, 70) : color.new(#40c4ff, 75)
        s_col_bdr  = sv_s_score >= 80 ? color.new(#00e5ff, 0) : sv_s_score >= 65 ? color.new(#00c853, 0) : color.new(#40c4ff, 0)
        // Dark label background → white text always readable (dark teal/green bg)
        s_lbl_bg   = sv_s_score >= 80 ? color.new(#004d40, 10) : sv_s_score >= 65 ? color.new(#1b5e20, 10) : color.new(#006064, 10)
        s_str      = sv_s_score >= 80 ? "⬆ STRONG SUPPORT" : sv_s_score >= 65 ? "⬆ SUPPORT" : "⬆ SUPPORT (weak)"
        s_lbl_txt  = s_str + "   $" + str.tostring(sv_s_mid, format.mintick) + "   " + str.tostring(math.round(s_atr, 1)) + " ATR away"
        sv_s_box  := box.new(bar_index - 80, s_vis_top, bar_index + 25, s_vis_bot, border_color=s_col_bdr, border_width=2, bgcolor=s_col_fill, extend=extend.right)
        sv_s_lbl  := label.new(bar_index - 30, sv_s_mid, s_lbl_txt, color=s_lbl_bg, textcolor=color.white, style=label.style_label_center, size=s_lbl_sz, tooltip="Nearest SUPPORT zone.\n\nZone: $" + str.tostring(sv_s_bot, format.mintick) + " — $" + str.tostring(sv_s_top, format.mintick) + "\n\nExpect price to BOUNCE here.\nIf it closes BELOW $" + str.tostring(sv_s_bot, format.mintick) + " = support broken, next S becomes target.\n\nScore: " + str.tostring(math.round(sv_s_score)) + "/100\nDistance: " + str.tostring(math.round(s_atr, 1)) + " ATR")

// ═══════════════════════════════════════════════════════════
// HIDDEN PLOTS (for alertcondition data)
// ═══════════════════════════════════════════════════════════

plot(array.size(g_zones), "Zone Count",  display=display.none)
plot(is_squeeze  ? 1 : 0, "Squeeze",     display=display.none)
plot(warn_fired  ? 1 : 0, "Warning",     display=display.none)
plot(avwap_value,          "AVWAP Value", display=display.none)

//END 12:26 07/07/2026 - GOD MODE pass: real multi-source confluence merge (polarity-gated), delayed bounce/break confirmation, Key Levels (PDH/PDL/PWH/PWL/Premarket), Flip-Retest warning, Trade Plan target quality filter + alert dedup.
//END 19:35 07/08/2026 - Fix RE: "historical offset beyond buffer limit" — zone boxes clamped their left edge to bar_index-500 (zx1). Protected W/D swing and Key Level zones are never evicted, so bar_created could exceed max_bars_back=1000 and blank the whole script.
//END 23:18 07/08/2026 - PERFORMANCE round 4, from a 3-agent profile (the previous three rounds were reasoned from reading, and all three missed these): M8 Warning Generator was gated on barstate.isconfirmed ALONE — true on every historical bar, so two full zone scans ran unthrottled while looking gated; now also gated on bar_index%3, with barstate.islast keeping every realtime alert exact. M6 Touch Tracker now writes a zone back to the array only when something actually changed (z_dirty) instead of array.set-ing all 20 UDTs on every bar. CORRECTNESS: ta.highest/ta.lowest for the POC sat behind `bar_index % 5 == 0` and ta.sma(volume) for Liquidity sat inside `if eq_count >= 2` — a ta.* call inside a conditional only advances its window on bars the branch is taken, so both returned wrong values; hoisted to unconditional, only the expensive histogram fill stays throttled.
//END 22:52 07/08/2026 - PERFORMANCE round 3: max_bars_back 1000 -> 400 (deepest history the script actually reads is 200 bars, via i_vp_lookback at its maximum; the buffer is allocated per series so the 5x oversize cost memory and load time everywhere) with the zone-box left-edge clamp moved 500 -> 300 in lockstep. Max Zones default 30 -> 20: the touch tracker, score engine, warning scanner and trade-plan search each walk that list every bar, so every per-bar cost scales with it, while only the top ~10 are ever drawn.
//END 22:26 07/08/2026 - PERFORMANCE round 2: request.security calls 11 -> 3 (all Daily values in one tuple, all Weekly in one — pdh/pdl/pwh/pwl moved into the MTF hub); per-zone momentum_signal now computed only on barstate.islast instead of every zone every bar (it is a label string nothing reads earlier); score engine throttled to every 3 bars + the rendered bar. Note: the score throttle is deliberately NOT gated on barstate.isconfirmed — that is true on every historical bar and would make the throttle a no-op exactly where load time is spent.
//END 21:58 07/08/2026 - PERFORMANCE: POC histogram rewritten to a single pass over the bars (was re-scanning all lookback bars once per bin — 2,000 iterations per run at defaults, now 120); Confluence Merger throttled to every 10 bars + the rendered bar (was an O(n^2) 900-comparison scan on EVERY bar); drawing pools cut from 500/500/500 to 200 boxes / 20 lines / 50 labels to match what is actually rendered. UX: dashboard gains Compact (8 rows) / Full (19) via a running row counter, Compact is the default; Structure moved under Regime and Entry Trigger above Active Setup; Legend now defaults OFF; structure fit added to the Adaptive Weights "strongest factor" readout.
//END 21:14 07/08/2026 - GOD MODE items 4-9 + deferred learning item: candle Entry Trigger (M0c, engulfing/pin/inside-break) driving an APPROACH-WAIT-READY plan state; HTF Bias (auto-stepped timeframe, EMA distance in ATR); Volume Dry-Up flag; Gap Classifier (M3h, ATR-relative, registered via the existing LEVEL source so the confluence bitmask is untouched); Setup Accuracy tracker (plans judged target-vs-stop, pessimistic on same-bar); pace Projection to target (clamped to 480 bars); structure weight added to the adaptive weight engine. Dashboard 16 -> 19 rows, legend 6 -> 7, new READY alert, JSON payload extended.
//END 20:32 07/08/2026 - Structure gate now OFF by default: counter-structure setups are shown but flagged "⚠ AGAINST STRUCTURE" on the chart label, dashboard row and alert (g_tp_vs_struct). Structure weight raised 12 -> 16 so the score carries the penalty the gate no longer enforces.
//END 20:10 07/08/2026 - GOD MODE items 1-3: Trading Mode preset wired for real (M0, adds Auto, scales width/pivots/lookbacks/confirm-bars/approach — Swing stays identity); Market Structure engine BOS/CHoCH (M0b) feeding a new score factor, a Trade Plan direction gate, a break-level line, a dashboard row and two alerts; Legend table built (i_show_legend was declared and unused).
````
