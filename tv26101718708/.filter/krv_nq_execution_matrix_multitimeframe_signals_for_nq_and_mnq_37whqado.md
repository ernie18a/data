# KRV NQ Execution Matrix | Multi-Timeframe Signals for NQ and MNQ

- url: https://www.tradingview.com/script/37whQaDo-KRV-NQ-Execution-Matrix-Multi-Timeframe-Signals-for-NQ-and-MNQ/
- type: indicator
- pine_id: PUB;fdef468f1dea4a90b9d4acdd5ee6a9a3
- version: 1.0

## Description

KRV NQ Execution Matrix is a signal and trade-planning tool for Nasdaq-100 futures (NQ and MNQ) on 45-second and 1-minute charts.

This is the open-source release of my earlier protected script, KRV NQ Execution Matrix v1.1. The protected version stays online because TradingView does not allow published scripts to be removed. This version is the one I will maintain. Compared with the protected version, it adds:
- the full source code, open for review
- a redesigned interface (state panel, quant panel, label next to price, plan zones)
- a fix for the 18:00 New York Globex reset, which could be skipped on some days
- a lock that disables signals on non-standard chart types
- bar-close confirmation on every alert in Confirmed Bar mode
- a warm-up period, so nothing fires during the chart's first partial session
- an adjustable signal limit per session (default effectively unlimited; the cooldown still spaces signals)

It will not print a signal just because the fast chart moved. The 15-minute trend and the 5-minute structure must agree on a direction first. Only then does it look for a specific trigger on your chart, and every signal it prints comes with a full plan: entry, a stop based on recent structure, two targets, the reward-to-risk ratio and the dollar risk.

On a quiet or two-sided day it stays silent. That is by design.

HOW IT WORKS

Each layer has to give permission before the next one can act.

1) 15-minute command
Using the last completed 15-minute bar, the script scores which side is in control. It looks at the 21 and 55 EMA stack and slope, an adaptive moving average (KAMA), the efficiency ratio (how clean the trend is compared with the noise), an ATR ratio (whether volatility is expanding) and which side of the session VWAP price is on. A side needs a score of at least 65 by default and must beat the other side.

2) 5-minute structure
Using the last completed 5-minute bar, it checks that the structure supports the command: EMA stack and slope, VWAP side, acceptance above or below the session opening range, and impulse strength. Default minimum score: 60.

3) Matrix direction
The Matrix is LONG or SHORT only when the 15-minute and 5-minute layers agree. While it is neutral, nothing can arm or fire.

4) Core setups
On the execution chart the script scores four setup types: a pullback to VWAP or KAMA, a retest of the opening range, a breakout from a tight range, and a failed auction (price sweeps the prior-day high or low, the session high or low, or the opening range, then reclaims it). Before a setup can arm it must also pass a risk check: at least 1.35R to target, and a stop no wider than 1.75 ATR by default.

5) MicroPulse
A short-term momentum module that only works in the Matrix direction. It looks for three patterns:
- P1 Ignition: price breaks the last few bars with a strong candle
- P2 Pullback Reclaim: price dips into the fast EMAs and reclaims them
- P3 Compression Release: a tight range breaks in the Matrix direction
Each pattern uses an adaptive trailing line, limits on how clean the move is and how far price has already run, and separate scores to arm and to fire. After a pulse fires, the script follows it for a short model ride (3 bars by default) and marks a model exit when the pulse fails or the ride ends.

6) Guard rails
A cooldown between signals (14 bars by default), trade windows during regular hours (09:45 to 11:30 and 13:30 to 15:45 New York time by default, adjustable), optional overnight windows, an optional signal limit per session, and automatic locks for the wrong timeframe, non-standard chart types and the warm-up period.

WHY THESE PIECES ARE COMBINED
Each piece answers one question, and a signal needs a yes from all of them:
- 15-minute and 5-minute layers: which side is in control?
- Session map (VWAP, opening ranges, prior-day and overnight levels): where are the levels that matter today?
- Core setups and MicroPulse: is there a specific trigger right now?
- Risk check: is the trade structurally sound (stop width, distance to target, reward-to-risk)?
EMAs, KAMA, VWAP and ATR are standard tools. The original part is the gating: the scores, the thresholds and the order in which each layer is allowed to act.

HOW TO READ THE CHART
- Yellow diamond or circle: a setup has armed and is waiting for its trigger.
- Small triangle under or over a bar: a signal. Every signal keeps its triangle, so you can scroll back and see all of them.
- PULSE or MATRIX tag: the most recent signals. Hover a tag to see its full plan.
- Shaded zones: entry, stop, TP1 and TP2 for the latest signal (magenta is risk, green is reward).
- Yellow X: the model exit for a pulse.
- Step line and shaded ribbon (green for long, magenta for short): the pulse trailing line and the fast EMA ribbon. They only appear when the Matrix has a direction.
- Top-right panel: current state and edge grade. Turn off "Minimize HUD" in the settings for the full panel (15m / 5m / MicroPulse alignment, edge meter, next action, active plan).
- Bottom-right panel: bias history, distance from VWAP in standard deviations, efficiency ratios, volatility ratio, relative volume, stretch from the fast EMA, dollar value of one ATR, change in bias and KAMA slope. These are readings, not signals.
- Label next to price: the current state, the trigger or plan, the nearest session level and key readings.

SUGGESTED SETUP
- NQ1! or MNQ1! on a 45-second or 1-minute chart with standard candles. The script reads the 15-minute and 5-minute data internally.
- Chart settings, Canvas, Margins: top 10%, bottom 10%, right 70 bars (around 60 on a smaller screen). The panels then sit in empty space.
- Right-click the price scale and turn on "Scale price chart only" so far-away levels never squeeze the chart.
- Set alerts to "Once Per Bar Close".

ALERTS
PULSE LONG NOW / PULSE SHORT NOW, PULSE EXIT LONG / SHORT, LONG NOW / SHORT NOW (core setups), MICRO LONG / SHORT ARMED, and LONG / SHORT COMMAND.

REPAINTING AND DATA
- In Confirmed Bar mode (the default), signals, exits, plans, markers and alerts all wait for the bar to close. They look the same on historical bars as they did live.
- 15-minute and 5-minute values come from request.security() with a one-bar offset and lookahead on, which returns only the last completed bar. This is the non-repainting method described in TradingView's documentation. No future data is used.
- The panels, the label next to price and the ribbon update during the live bar, like any oscillator, and settle when the bar closes.
- Live Bar mode is optional. It gives an early heads-up that can change before the bar closes.
- Warm-up: the first session on the chart starts part-way through, so session levels are hidden and no signals are generated until the first full session opens (18:00 New York time, or 09:30 on charts without extended hours). The top-right panel shows WARM-UP while this is active.

LIMITATIONS
- Built and tuned for NQ and MNQ. It is not calibrated for other markets.
- Signals are turned off on non-standard charts (Heikin-Ashi, Renko, Range, Kagi, Point and Figure, Line Break) and on timeframes above the execution limit. A red warning on the chart says why.
- Stops, targets, the ride length and exits are model guidance. The script does not know your actual position, fills or slippage.
- Dollar risk uses the contract point value and the contract count in the settings, before commissions and slippage.
- Past signals do not predict future results. This is an analysis tool, not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Cheeseboard1991
// KRV NQ Execution Matrix - Alpha Agent by Einstein's Unified
//@version=6
indicator("KRV NQ Execution Matrix - Alpha Agent Edition", shorttitle="KRV NQ Matrix", overlay=true, max_labels_count=250, max_lines_count=120, max_boxes_count=20, max_bars_back=5000)

// =================================================================================================
// KRV NQ EXECUTION MATRIX — ALPHA AGENT EDITION
// -------------------------------------------------------------------------------------------------
// PURPOSE
// One unified NQ / MNQ execution system:
//   15m Command -> 5m Structure -> Execution-Bar Matrix -> Optional MicroPulse submodule.
//
// MicroPulse is NOT a standalone UT-style signal generator. It is hard-gated  by the Matrix command.
// If the 15m / 5m Matrix is neutral or misaligned, the MicroPulse module is disabled and cannot print
// a long, short, READY, or PULSE label.
//
// VISUAL PHILOSOPHY
// - Matrix clean: KAMA + active VWAP + session map.
// - Directional only: a kinetic ribbon and pulse trail appear ONLY when Matrix direction is earned.
// - Armed only: a single halo/diamond and subtle aura appear ONLY when a MicroPulse setup forms.
// - Fire only: one PULSE LONG / PULSE SHORT label plus one current risk-plan ladder.
//
// SAFETY
// - All 15m / 5m values use completed bars: [1] + lookahead_on.
// - Confirmed Bar is the release mode. Live Bar is an early heads-up mode and can change intrabar.
// - Model ride / exit states are signal-plan guidance only; the script cannot know your real position.
//
// PRESENTATION LAYER
// - Section 0 (Display Settings) and the "ALPHA AGENT UI LAYER" at the bottom are presentation only.
//   They READ engine outputs and never assign to any engine variable.
// =================================================================================================

// =================================================================================================
// 0. DISPLAY SETTINGS — ALPHA AGENT SKIN (PRESENTATION ONLY)
// =================================================================================================
string G_DISPLAY = "0. Display Settings — Alpha Agent Skin"
i_theme          = input.string("Alpha Agent Neon", "Theme", options=["Alpha Agent Neon", "Matrix Emerald", "Obsidian", "Ice (Light Chart)"], group=G_DISPLAY)
i_brandName      = input.string("ALPHA AGENT", "HUD Brand Tag", group=G_DISPLAY, tooltip="First word renders in brand cyan, the rest in brand magenta.")
i_brandSub       = input.string("by Einstein's Unified", "HUD Brand Byline", group=G_DISPLAY)
i_hudPosition    = input.string("Top Right", "HUD Position", options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group=G_DISPLAY)
i_hudSize        = input.string("Small", "HUD Text Size", options=["Tiny", "Small", "Normal"], group=G_DISPLAY)
i_hudMinimized   = input.bool(true, "Minimize HUD (Brand + State Strip Only)", group=G_DISPLAY, tooltip="On (default): a compact strip with brand, state and edge grade. Off: the full HUD with alignment, edge meter, action and plan.")
i_hudOpacity     = input.int(28, "HUD Glass Transparency", minval=0, maxval=70, group=G_DISPLAY, tooltip="Frameless glass. Rows fade further toward the bottom so the HUD dissolves into the chart.")
i_hudFocus       = input.bool(false, "Dim Focus (HUD dims on standby)", group=G_DISPLAY, tooltip="The HUD never changes size. On standby its detail rows dim; they light up when a setup arms, fires or rides, and stay lit for the Afterglow Hold.")
i_holdBars       = input.int(4, "Afterglow Hold (bars)", minval=1, maxval=20, group=G_DISPLAY, tooltip="How long armed / fired visuals and HUD focus persist after the event, fading bar by bar, so they can actually be read.")
i_callout        = input.bool(true, "Agent Callout at Price", group=G_DISPLAY, tooltip="A glass callout riding beside the live candle: state, trigger / plan, nearest level and key quant — read without leaving price.")
i_calloutOffset  = input.int(2, "Callout Offset (bars)", minval=1, maxval=20, group=G_DISPLAY)
i_luminosity     = input.int(100, "Luminous Intensity %", minval=20, maxval=150, step=5, group=G_DISPLAY, tooltip="Scales the opacity of every glow, zone, tag and ribbon. Lower = quieter chart, higher = more neon.")
i_signalStyle    = input.string("Luminous Tags", "Signal Style", options=["Pro", "Luminous Tags", "Neon Chips", "Classic Labels"], group=G_DISPLAY, tooltip="Every FIRE keeps a small glyph (▲/▼) permanently, so past signals stay visible however far back you scroll. Pro: only the latest FIRE carries a full tag. Luminous Tags / Neon Chips: several tags, older ones dim. Classic Labels: solid labels.")
i_maxTags        = input.int(10, "Max Luminous Tags on Chart", minval=2, maxval=40, group=G_DISPLAY, tooltip="Luminous Tags / Neon Chips only. Pro always keeps exactly one.")
i_planCollapse   = input.bool(false, "Collapse Pulse Plan at Model Exit", group=G_DISPLAY, tooltip="Off (default): the latest plan stays until the next FIRE. On: a pulse plan shrinks to the exit bar and dims.")
i_planStyle      = input.string("Glass Zones", "Plan Ladder Style", options=["Glass Zones", "Classic Label"], group=G_DISPLAY, tooltip="Glass Zones: translucent risk / reward zones with compact rung tags; a pulse plan collapses to the exit bar when the model exits.")
i_auraStyle      = input.string("Both", "Armed Aura Style", options=["Trigger Reticle", "Column Glow", "Both"], group=G_DISPLAY, tooltip="Trigger Reticle: a live targeting box around the pulse window plus the trigger level. Column Glow: a soft background aura.")
i_showTargetTags = input.bool(true, "Show Level Target Tags (Right Edge)", group=G_DISPLAY)
i_glowLines      = input.bool(true, "Glow Under VWAP / Pulse Trail", group=G_DISPLAY)
i_showFooter     = input.bool(true, "Show HUD Integrity Footer", group=G_DISPLAY)
i_fireFlash      = input.bool(true, "Ignition Flash on FIRE Bar", group=G_DISPLAY, tooltip="A single-bar luminous wash on the confirmed FIRE bar only.")

string G_QUANT = "0b. Quant Cluster — Glass Instrument Panel"
i_showQuant      = input.bool(true, "Show Quant Cluster", group=G_QUANT)
i_quantPosition  = input.string("Bottom Right", "Cluster Position", options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group=G_QUANT, tooltip="If this matches the HUD position, the cluster moves to the opposite vertical edge automatically.")
i_quantGlass     = input.int(35, "Glass Transparency (Top)", minval=0, maxval=80, group=G_QUANT, tooltip="The panel fades further toward the bottom so it dissolves into the chart.")
i_quantFade      = input.int(6, "Glass Fade per Row", minval=0, maxval=10, group=G_QUANT)
i_sparkLen       = input.int(24, "Bias Sparkline Bars", minval=8, maxval=48, group=G_QUANT)

string G_SCALE = "0c. Scale Guard — Keeps the Chart Uncompressed"
i_scaleGuard     = input.bool(true, "Enable Scale Guard", group=G_SCALE, tooltip="Session-map levels (PDH/PDL, ONH/ONL, opening ranges, σ bands) only render when price is within range. Far-away levels stop dragging the price scale, so Reset Chart View frames price, not the map.")
i_scaleGuardAtr  = input.float(3.0, "Guard Range (× 15m ATR)", minval=0.5, maxval=20.0, step=0.25, group=G_SCALE, tooltip="A level materialises when price comes within this many completed-15m ATRs of it.")
i_guardVwap      = input.bool(false, "Guard VWAP Too", group=G_SCALE, tooltip="Off = VWAP always shows. On = VWAP obeys the same range rule.")

// =================================================================================================
// 1. SYSTEM MODE / GOVERNANCE
// =================================================================================================
string G_SYSTEM = "1. System / Governance"
i_signalMode       = input.string("Confirmed Bar", "Signal Mode", options=["Confirmed Bar", "Live Bar"], group=G_SYSTEM, tooltip="Confirmed Bar is the release mode. Live Bar is a heads-up mode and can change before the candle closes.")
i_enforceExecTf    = input.bool(true, "Require 45s / 1m Execution Chart", group=G_SYSTEM)
i_maxExecSeconds   = input.int(60, "Maximum Execution Chart Seconds", minval=15, maxval=300, group=G_SYSTEM)
i_sessionMode      = input.string("RTH + ETH", "Trading Session Mode", options=["RTH Only", "RTH + ETH", "ETH Only"], group=G_SYSTEM)
i_useRthWindows    = input.bool(true, "Use RTH Trade Windows", group=G_SYSTEM)
i_morningWindow    = input.session("0945-1130", "RTH Morning Window (ET)", group=G_SYSTEM)
i_afternoonWindow  = input.session("1330-1545", "RTH Afternoon Window (ET)", group=G_SYSTEM)
i_useEthWindows    = input.bool(false, "Use ETH Time Windows", group=G_SYSTEM)
i_ethAsiaWindow    = input.session("1830-2300", "ETH Asia Window (ET)", group=G_SYSTEM)
i_ethEuropeWindow  = input.session("0200-0500", "ETH Europe Window (ET)", group=G_SYSTEM)
i_ethPreUsWindow   = input.session("0700-0915", "ETH Pre-US Window (ET)", group=G_SYSTEM)
i_ethPostRthWindow = input.session("1605-1655", "ETH Post-RTH Window (ET)", group=G_SYSTEM)
i_maxSignals       = input.int(99, "Maximum FIRE Signals per Active Session", minval=1, maxval=99, group=G_SYSTEM, tooltip="99 = effectively unlimited (the cooldown already spaces signals). Lower it only if you want a hard daily budget. Sessions reset at 09:30 ET and 18:00 ET.")
i_cooldownBars     = input.int(14, "FIRE Cooldown Bars", minval=1, maxval=250, group=G_SYSTEM)

// =================================================================================================
// 2. 15-MINUTE COMMAND LAYER
// =================================================================================================
string G_COMMAND = "2. 15m Command Layer"
i_commandTf      = input.timeframe("15", "Command Timeframe", group=G_COMMAND)
i_cmdFastLen     = input.int(21, "Command Fast EMA", minval=2, group=G_COMMAND)
i_cmdSlowLen     = input.int(55, "Command Slow EMA", minval=5, group=G_COMMAND)
i_cmdKamaLen     = input.int(20, "Command KAMA Length", minval=2, group=G_COMMAND)
i_cmdErLen       = input.int(10, "Command Efficiency Length", minval=2, group=G_COMMAND)
i_cmdAtrLen      = input.int(14, "Command ATR Length", minval=2, group=G_COMMAND)
i_cmdAtrBase     = input.int(20, "Command ATR Baseline", minval=5, group=G_COMMAND)
i_cmdMinER       = input.float(0.31, "Minimum Directional Efficiency", minval=0.05, maxval=0.95, step=0.01, group=G_COMMAND)
i_cmdMinAtrRatio = input.float(0.80, "Minimum ATR Regime Ratio", minval=0.30, maxval=2.50, step=0.05, group=G_COMMAND)
i_cmdMinScore    = input.int(65, "Minimum Command Score", minval=35, maxval=100, group=G_COMMAND)

// =================================================================================================
// 3. 5-MINUTE STRUCTURE / AUCTION LAYER
// =================================================================================================
string G_STRUCTURE = "3. 5m Structure / Auction Layer"
i_structureTf       = input.timeframe("5", "Structure Timeframe", group=G_STRUCTURE)
i_m5FastLen         = input.int(21, "5m Fast EMA", minval=2, group=G_STRUCTURE)
i_m5SlowLen         = input.int(55, "5m Slow EMA", minval=5, group=G_STRUCTURE)
i_m5KamaLen         = input.int(10, "5m KAMA Length", minval=2, group=G_STRUCTURE)
i_m5AtrLen          = input.int(14, "5m ATR Length", minval=2, group=G_STRUCTURE)
i_structureMinScore = input.int(60, "Minimum Structure Score", minval=30, maxval=100, group=G_STRUCTURE)
i_acceptBars        = input.int(3, "Opening Range Acceptance Bars", minval=2, maxval=12, group=G_STRUCTURE)
i_compressionBars   = input.int(8, "Compression Lookback Bars", minval=3, maxval=30, group=G_STRUCTURE)
i_compressionATR    = input.float(1.20, "Maximum Compression Width (ATR)", minval=0.30, maxval=4.00, step=0.05, group=G_STRUCTURE)

// =================================================================================================
// 4. MATRIX CORE EXECUTION ENGINE
// =================================================================================================
string G_CORE = "4. Matrix Core Execution Engine"
i_enableCore       = input.bool(true, "Enable Matrix Core Setups", group=G_CORE)
i_localKamaLen     = input.int(20, "Execution KAMA Length", minval=2, group=G_CORE)
i_localEmaLen      = input.int(21, "Execution EMA Length", minval=2, group=G_CORE)
i_localAtrLen      = input.int(14, "Execution ATR Length", minval=2, group=G_CORE)
i_volumeLen        = input.int(20, "Volume Baseline Length", minval=5, group=G_CORE)
i_volumeExpansion  = input.float(1.10, "Relative Volume Expansion", minval=0.50, maxval=5.00, step=0.05, group=G_CORE)
i_minBodyRatio     = input.float(0.42, "Core Trigger Candle Body Ratio", minval=0.10, maxval=0.95, step=0.01, group=G_CORE)
i_pullbackTolerance = input.float(0.22, "VWAP / KAMA Pullback Tolerance (ATR)", minval=0.02, maxval=1.50, step=0.02, group=G_CORE)
i_levelBuffer      = input.float(0.12, "Level Retest / Acceptance Buffer (ATR)", minval=0.02, maxval=1.00, step=0.01, group=G_CORE)
i_sweepBuffer      = input.float(0.08, "Liquidity Sweep Buffer (ATR)", minval=0.00, maxval=1.00, step=0.01, group=G_CORE)
i_enableFailedAuction = input.bool(true, "Enable Failed-Auction Reclaims", group=G_CORE)
i_coreMinScore     = input.int(72, "Minimum Core Setup Score", minval=40, maxval=100, group=G_CORE)

// =================================================================================================
// 5. MICRO PULSE SUBMODULE — HARD-GATED BY MATRIX COMMAND
// =================================================================================================
string G_MICRO = "5. MicroPulse Submodule (Matrix-Gated)"
i_enableMicro       = input.bool(true, "Enable Matrix-Gated MicroPulse", group=G_MICRO, tooltip="MicroPulse cannot arm or fire without a valid 15m + 5m Matrix direction.")
i_microProfile      = input.string("Balanced", "MicroPulse Profile", options=["Precision", "Balanced", "Aggressive"], group=G_MICRO)
i_microFastLen      = input.int(8, "Kinetic Fast EMA", minval=2, group=G_MICRO)
i_microSlowLen      = input.int(21, "Kinetic Slow EMA", minval=3, group=G_MICRO)
i_microKamaLen      = input.int(10, "Kinetic KAMA Length", minval=2, group=G_MICRO)
i_microErLen        = input.int(7, "Micro Efficiency Length", minval=2, group=G_MICRO)
i_microTrailAtrLen  = input.int(10, "Pulse Trail ATR Length", minval=2, group=G_MICRO)
i_microTrailMult    = input.float(0.95, "Pulse Trail Base Multiplier", minval=0.20, maxval=5.00, step=0.05, group=G_MICRO)
i_microPulseBars    = input.int(3, "Pulse Lookback Bars", minval=2, maxval=5, group=G_MICRO)
i_microSameSideBars = input.int(2, "Minimum Same-Side Pulse Bars", minval=1, maxval=5, group=G_MICRO)
i_microPullbackATR  = input.float(0.20, "Pullback Reset Tolerance (ATR)", minval=0.02, maxval=1.00, step=0.01, group=G_MICRO)
i_microMaxChaseATR  = input.float(1.05, "Maximum Chase Extension (ATR)", minval=0.20, maxval=4.00, step=0.05, group=G_MICRO)
i_microArmScore     = input.int(66, "Minimum MicroPulse Armed Score", minval=35, maxval=100, group=G_MICRO)
i_microFireScore    = input.int(78, "Minimum MicroPulse FIRE Score", minval=40, maxval=100, group=G_MICRO)
i_microRideBars     = input.int(3, "Model Ride Bars", minval=1, maxval=10, group=G_MICRO, tooltip="Signal-plan guidance only. The bar count includes the original PULSE bar.")
i_microForceTimeExit = input.bool(true, "Model Exit at Maximum Ride Bars", group=G_MICRO)

// =================================================================================================
// 6. SESSION MAP
// =================================================================================================
string G_SESSION = "6. NY Session / Auction Map"
i_rthOrMinutes    = input.int(15, "RTH Opening Range Minutes", minval=5, maxval=90, group=G_SESSION)
i_ethOrMinutes    = input.int(30, "ETH Opening Range Minutes", minval=5, maxval=120, group=G_SESSION)
i_showSessionMap  = input.bool(true, "Show Core Session Map", group=G_SESSION)
i_showVwap        = input.bool(true, "Show Active Session VWAP", group=G_SESSION)
i_showKama        = input.bool(true, "Show Execution KAMA", group=G_SESSION)
i_showDevBands    = input.bool(false, "Show Active VWAP Deviation Bands", group=G_SESSION)
i_showEthRange    = input.bool(true, "Show ETH Opening Range", group=G_SESSION)

// =================================================================================================
// 7. RISK / TARGET ENGINE
// =================================================================================================
string G_RISK = "7. Risk / Target Engine"
i_stopLookback      = input.int(8, "Core Structural Stop Lookback", minval=2, maxval=50, group=G_RISK)
i_microStopLookback = input.int(5, "Micro Structural Stop Lookback", minval=2, maxval=30, group=G_RISK)
i_stopBufferATR     = input.float(0.14, "Stop Buffer (ATR)", minval=0.00, maxval=1.00, step=0.01, group=G_RISK)
i_maxCoreStopATR    = input.float(1.75, "Maximum Core Stop Width (ATR)", minval=0.40, maxval=5.00, step=0.05, group=G_RISK)
i_maxMicroStopATR   = input.float(1.10, "Maximum Micro Stop Width (ATR)", minval=0.20, maxval=4.00, step=0.05, group=G_RISK)
i_minCoreR          = input.float(1.35, "Minimum Core Target R", minval=0.50, maxval=5.00, step=0.05, group=G_RISK)
i_microTP1R         = input.float(0.85, "Micro TP1 R-Multiple", minval=0.20, maxval=5.00, step=0.05, group=G_RISK)
i_microTP2R         = input.float(1.45, "Micro TP2 R-Multiple", minval=0.50, maxval=8.00, step=0.05, group=G_RISK)
i_minTargetATR      = input.float(0.60, "Minimum Target Distance (ATR)", minval=0.10, maxval=5.00, step=0.05, group=G_RISK)
i_fallbackTargetATR = input.float(2.10, "Core Fallback Target (ATR)", minval=0.50, maxval=8.00, step=0.05, group=G_RISK)
i_contracts         = input.int(1, "Contracts for Dollar Estimate", minval=1, maxval=50, group=G_RISK)
i_planProjection    = input.int(24, "Plan Projection Bars", minval=5, maxval=100, group=G_RISK)

// =================================================================================================
// 8. UI / VISUAL LANGUAGE / ALERTS
// =================================================================================================
string G_UI = "8. UI / Visual Language"
i_uiMode            = input.string("Minimal", "Dashboard Mode", options=["Minimal", "Full Telemetry", "Off"], group=G_UI)
i_showPlan          = input.bool(true, "Show Latest Risk-Plan Ladder", group=G_UI)
i_showCoreMarkers   = input.bool(true, "Show Matrix Core Markers", group=G_UI)
i_showPulseBeacons  = input.bool(true, "Show MicroPulse Beacons", group=G_UI)
i_showPulseRibbon   = input.bool(true, "Show Kinetic Ribbon When Matrix Directional", group=G_UI)
i_showPulseTrail    = input.bool(true, "Show Pulse Trail When Matrix Directional", group=G_UI)
i_showPulseAura     = input.bool(true, "Show Armed Pulse Aura", group=G_UI)
i_colorCandles      = input.bool(false, "Color Candles by Matrix State", group=G_UI)
i_showStatusLabel   = input.bool(false, "Show Last-Bar State Label", group=G_UI)

// =================================================================================================
// CONSTANTS / UTILITY FUNCTIONS
// =================================================================================================
const string NY_TZ = "America/New_York"
const color C_LONG = color.rgb(69, 255, 157)
const color C_SHORT = color.rgb(255, 94, 94)
const color C_INFO = color.rgb(56, 189, 248)
const color C_WARN = color.rgb(251, 191, 36)
const color C_NEUTRAL = color.rgb(148, 163, 184)
const color C_DARK = color.rgb(15, 23, 42)
const color C_MUTED = color.rgb(71, 85, 105)

f_clamp(float _x, float _lo, float _hi) =>
    math.max(_lo, math.min(_x, _hi))

f_roundTick(float _price) =>
    math.round(_price / syminfo.mintick) * syminfo.mintick

f_efficiency(float _src, int _len) =>
    float _net = math.abs(_src - _src[_len])
    float _noise = ta.sma(math.abs(ta.change(_src)), _len) * _len
    _noise > 0 ? _net / _noise : 0.0

// Pine has no native KAMA function. This function implements the standard Kaufman adaptive average.
f_kama(float _src, int _erLen, int _fastLen, int _slowLen) =>
    float _change = math.abs(_src - _src[_erLen])
    float _volatility = ta.sma(math.abs(ta.change(_src)), _erLen) * _erLen
    float _er = _volatility > 0 ? _change / _volatility : 0.0
    float _fastSC = 2.0 / (_fastLen + 1.0)
    float _slowSC = 2.0 / (_slowLen + 1.0)
    float _smoothing = math.pow(_er * (_fastSC - _slowSC) + _slowSC, 2.0)
    float _kama = na
    _kama := na(_kama[1]) ? _src : _kama[1] + _smoothing * (_src - _kama[1])
    _kama

f_nearestAbove(float _entry, float _minimumDistance, float _a, float _b, float _c, float _d, float _e, float _f) =>
    float _best = na
    if not na(_a) and _a > _entry + _minimumDistance
        _best := _a
    if not na(_b) and _b > _entry + _minimumDistance and (na(_best) or _b < _best)
        _best := _b
    if not na(_c) and _c > _entry + _minimumDistance and (na(_best) or _c < _best)
        _best := _c
    if not na(_d) and _d > _entry + _minimumDistance and (na(_best) or _d < _best)
        _best := _d
    if not na(_e) and _e > _entry + _minimumDistance and (na(_best) or _e < _best)
        _best := _e
    if not na(_f) and _f > _entry + _minimumDistance and (na(_best) or _f < _best)
        _best := _f
    _best

f_nearestBelow(float _entry, float _minimumDistance, float _a, float _b, float _c, float _d, float _e, float _f) =>
    float _best = na
    if not na(_a) and _a < _entry - _minimumDistance
        _best := _a
    if not na(_b) and _b < _entry - _minimumDistance and (na(_best) or _b > _best)
        _best := _b
    if not na(_c) and _c < _entry - _minimumDistance and (na(_best) or _c > _best)
        _best := _c
    if not na(_d) and _d < _entry - _minimumDistance and (na(_best) or _d > _best)
        _best := _d
    if not na(_e) and _e < _entry - _minimumDistance and (na(_best) or _e > _best)
        _best := _e
    if not na(_f) and _f < _entry - _minimumDistance and (na(_best) or _f > _best)
        _best := _f
    _best

f_grade(int _score) =>
    _score >= 85 ? "A" : _score >= 70 ? "B" : _score >= 55 ? "C" : "F"

f_gradeColor(int _score) =>
    _score >= 85 ? C_LONG : _score >= 70 ? C_INFO : _score >= 55 ? C_WARN : C_MUTED

f_money(float _value) =>
    "$" + str.tostring(_value, "#.0")

f_r(float _value) =>
    str.tostring(_value, "#.00") + "R"

f_stateColor(string _state) =>
    str.contains(_state, "PULSE LONG") or str.contains(_state, "LONG NOW") ? C_LONG : str.contains(_state, "PULSE SHORT") or str.contains(_state, "SHORT NOW") ? C_SHORT : str.contains(_state, "ARMED") ? C_WARN : str.contains(_state, "BIAS") ? C_INFO : C_NEUTRAL

// =================================================================================================
// EXECUTION TIMEFRAME / BAR-CONFIRMATION GATE
// =================================================================================================
int chartTfSeconds = timeframe.in_seconds(timeframe.period)
bool executionTfOkay = not na(chartTfSeconds) and chartTfSeconds <= i_maxExecSeconds
bool executionTfLock = i_enforceExecTf and not executionTfOkay
// TradingView forbids signals on non-standard charts (Heikin-Ashi, Renko, Range, ...).
bool chartTypeLock = not chart.is_standard
bool confirmedMode = i_signalMode == "Confirmed Bar"
bool barGate = confirmedMode ? barstate.isconfirmed : true
string modeText = confirmedMode ? "CONFIRMED" : "LIVE"

// =================================================================================================
// SESSION CLOCK / RTH + ETH AUCTION MAP
// =================================================================================================
bool isRth = not na(time(timeframe.period, "0930-1600", NY_TZ))
bool isEthOvernight = not na(time(timeframe.period, "1800-0929", NY_TZ))
bool isEthPostRth = not na(time(timeframe.period, "1600-1659", NY_TZ))
bool isEth = isEthOvernight or isEthPostRth
bool previousRth = bar_index > 0 ? isRth[1] : false
bool previousEth = bar_index > 0 ? isEth[1] : false
bool rthEnter = isRth and not previousRth
bool rthExit = not isRth and previousRth
bool ethEnter = isEth and not previousEth
// The Globex day opens on the first overnight bar, so the 18:00 ET resets (Globex VWAP, ON range, quota) fire
// even when the last pre-break bar is stamped inside 16:00-16:59.
bool globexOpen = isEthOvernight and not (bar_index > 0 ? isEthOvernight[1] : false)
// Warm-up lock: the chart's first session starts mid-stream (partial VWAP, no prior-day
// levels, unsettled averages), so nothing arms or fires until the first complete session opens: the Globex open
// on ETH charts, or the RTH open on regular-session-only charts. Bar 0 never counts as an open.
var bool warmupDone = false
if bar_index > 0 and (syminfo.session == session.regular ? rthEnter : globexOpen)
    warmupDone := true
bool warmupActive = not warmupDone
bool allowRth = i_sessionMode != "ETH Only"
bool allowEth = i_sessionMode != "RTH Only"
bool selectedSession = (allowRth and isRth) or (allowEth and isEth)

bool inRthMorning = not na(time(timeframe.period, i_morningWindow, NY_TZ))
bool inRthAfternoon = not na(time(timeframe.period, i_afternoonWindow, NY_TZ))
bool inEthAsia = not na(time(timeframe.period, i_ethAsiaWindow, NY_TZ))
bool inEthEurope = not na(time(timeframe.period, i_ethEuropeWindow, NY_TZ))
bool inEthPreUs = not na(time(timeframe.period, i_ethPreUsWindow, NY_TZ))
bool inEthPostRth = not na(time(timeframe.period, i_ethPostRthWindow, NY_TZ))
bool rthTimeAllowed = isRth and (not i_useRthWindows or inRthMorning or inRthAfternoon)
bool ethTimeAllowed = isEth and (not i_useEthWindows or inEthAsia or inEthEurope or inEthPreUs or inEthPostRth)

// RTH opening range: begins at 09:30 ET.
int rthOpenTime = timestamp(NY_TZ, year(time, NY_TZ), month(time, NY_TZ), dayofmonth(time, NY_TZ), 9, 30)
bool rthRangeBuilding = isRth and time >= rthOpenTime and time < rthOpenTime + i_rthOrMinutes * 60000
bool priorRthRangeBuilding = bar_index > 0 ? rthRangeBuilding[1] : false
bool rthRangeStart = rthRangeBuilding and not priorRthRangeBuilding
var float rthOrHigh = na
var float rthOrLow = na
if rthEnter or rthRangeStart
    rthOrHigh := high
    rthOrLow := low
else if rthRangeBuilding
    rthOrHigh := na(rthOrHigh) ? high : math.max(rthOrHigh, high)
    rthOrLow := na(rthOrLow) ? low : math.min(rthOrLow, low)
bool rthRangeReady = isRth and not rthRangeBuilding and not na(rthOrHigh) and not na(rthOrLow)
float rthOrMid = not na(rthOrHigh) and not na(rthOrLow) ? (rthOrHigh + rthOrLow) * 0.5 : na

// ETH opening range: begins at the 18:00 ET Globex reopen.
int ethOpenTime = timestamp(NY_TZ, year(time, NY_TZ), month(time, NY_TZ), dayofmonth(time, NY_TZ), 18, 0)
bool ethRangeBuilding = isEthOvernight and time >= ethOpenTime and time < ethOpenTime + i_ethOrMinutes * 60000
bool priorEthRangeBuilding = bar_index > 0 ? ethRangeBuilding[1] : false
bool ethRangeStart = ethRangeBuilding and not priorEthRangeBuilding
var float ethOrHigh = na
var float ethOrLow = na
if globexOpen or ethRangeStart
    ethOrHigh := high
    ethOrLow := low
else if ethRangeBuilding
    ethOrHigh := na(ethOrHigh) ? high : math.max(ethOrHigh, high)
    ethOrLow := na(ethOrLow) ? low : math.min(ethOrLow, low)
bool ethRangeReady = isEth and not ethRangeBuilding and not na(ethOrHigh) and not na(ethOrLow)
float ethOrMid = not na(ethOrHigh) and not na(ethOrLow) ? (ethOrHigh + ethOrLow) * 0.5 : na

// Prior RTH map.
var float runningRthHigh = na
var float runningRthLow = na
var float priorRthHigh = na
var float priorRthLow = na
var float priorRthClose = na
if rthEnter
    runningRthHigh := high
    runningRthLow := low
else if isRth
    runningRthHigh := na(runningRthHigh) ? high : math.max(runningRthHigh, high)
    runningRthLow := na(runningRthLow) ? low : math.min(runningRthLow, low)
if rthExit
    priorRthHigh := runningRthHigh
    priorRthLow := runningRthLow
    priorRthClose := bar_index > 0 ? close[1] : close

// Overnight high / low freezes at 09:30; active Globex range continues until the maintenance break.
var float overnightRunningHigh = na
var float overnightRunningLow = na
var float overnightHigh = na
var float overnightLow = na
if globexOpen
    overnightRunningHigh := high
    overnightRunningLow := low
else if isEthOvernight
    overnightRunningHigh := na(overnightRunningHigh) ? high : math.max(overnightRunningHigh, high)
    overnightRunningLow := na(overnightRunningLow) ? low : math.min(overnightRunningLow, low)
if rthEnter
    overnightHigh := overnightRunningHigh
    overnightLow := overnightRunningLow

var float globexRunningHigh = na
var float globexRunningLow = na
if globexOpen
    globexRunningHigh := high
    globexRunningLow := low
else if isEth or isRth
    globexRunningHigh := na(globexRunningHigh) ? high : math.max(globexRunningHigh, high)
    globexRunningLow := na(globexRunningLow) ? low : math.min(globexRunningLow, low)

float activeSessionHigh = isRth ? overnightHigh : globexRunningHigh
float activeSessionLow = isRth ? overnightLow : globexRunningLow
float sweepSessionHigh = isRth ? overnightHigh : globexRunningHigh[1]
float sweepSessionLow = isRth ? overnightLow : globexRunningLow[1]
float visibleOvernightHigh = isEthOvernight ? overnightRunningHigh : overnightHigh
float visibleOvernightLow = isEthOvernight ? overnightRunningLow : overnightLow

// RTH VWAP resets at 09:30 ET.
var float rthPV = na
var float rthVol = na
var float rthPV2 = na
if rthEnter
    rthPV := hlc3 * volume
    rthVol := volume
    rthPV2 := hlc3 * hlc3 * volume
else if isRth
    rthPV := nz(rthPV) + hlc3 * volume
    rthVol := nz(rthVol) + volume
    rthPV2 := nz(rthPV2) + hlc3 * hlc3 * volume
float rthVwap = not na(rthVol) and rthVol > 0 ? rthPV / rthVol : na
float rthVariance = not na(rthVol) and rthVol > 0 ? math.max(rthPV2 / rthVol - rthVwap * rthVwap, 0.0) : na
float rthStd = not na(rthVariance) ? math.sqrt(rthVariance) : na

// Globex VWAP resets at 18:00 and continues across RTH until 16:59 ET.
var float globexPV = na
var float globexVol = na
var float globexPV2 = na
bool globexReset = globexOpen
if globexReset
    globexPV := hlc3 * volume
    globexVol := volume
    globexPV2 := hlc3 * hlc3 * volume
else if isEth or isRth
    globexPV := nz(globexPV) + hlc3 * volume
    globexVol := nz(globexVol) + volume
    globexPV2 := nz(globexPV2) + hlc3 * hlc3 * volume
float globexVwap = not na(globexVol) and globexVol > 0 ? globexPV / globexVol : na
float globexVariance = not na(globexVol) and globexVol > 0 ? math.max(globexPV2 / globexVol - globexVwap * globexVwap, 0.0) : na
float globexStd = not na(globexVariance) ? math.sqrt(globexVariance) : na

bool contextIsRth = isRth
float activeVwap = contextIsRth ? rthVwap : globexVwap
float activeStd = contextIsRth ? rthStd : globexStd
float activeVwapUpper1 = not na(activeVwap) and not na(activeStd) ? activeVwap + activeStd : na
float activeVwapLower1 = not na(activeVwap) and not na(activeStd) ? activeVwap - activeStd : na
float activeVwapUpper2 = not na(activeVwap) and not na(activeStd) ? activeVwap + 2.0 * activeStd : na
float activeVwapLower2 = not na(activeVwap) and not na(activeStd) ? activeVwap - 2.0 * activeStd : na
float rangeHigh = contextIsRth ? rthOrHigh : ethOrHigh
float rangeLow = contextIsRth ? rthOrLow : ethOrLow
float rangeMid = contextIsRth ? rthOrMid : ethOrMid
bool rangeReady = contextIsRth ? rthRangeReady : ethRangeReady
bool rangeBuilding = contextIsRth ? rthRangeBuilding : ethRangeBuilding
string rangeName = contextIsRth ? "RTH OR" : "ETH OR"

// =================================================================================================
// EXECUTION-CHART KINETIC ENGINE
// =================================================================================================
float executionAtr = ta.atr(i_localAtrLen)
float executionKama = f_kama(close, i_localKamaLen, 2, 30)
float executionEma = ta.ema(close, i_localEmaLen)
float executionEmaSlope = executionEma - executionEma[1]
float volumeBase = ta.sma(volume, i_volumeLen)
float relativeVolume = volumeBase > 0 ? volume / volumeBase : 0.0
bool volumeExpanding = relativeVolume >= i_volumeExpansion

float candleRange = high - low
float candleBody = math.abs(close - open)
float bodyRatio = candleRange > 0 ? candleBody / candleRange : 0.0
bool bullImpulse = close > open and bodyRatio >= i_minBodyRatio and close >= high - candleRange * 0.28
bool bearImpulse = close < open and bodyRatio >= i_minBodyRatio and close <= low + candleRange * 0.28
bool aboveActiveVwap = not na(activeVwap) and close > activeVwap
bool belowActiveVwap = not na(activeVwap) and close < activeVwap
bool aboveExecutionKama = not na(executionKama) and close > executionKama
bool belowExecutionKama = not na(executionKama) and close < executionKama

// Every rolling function is evaluated globally, avoiding conditional-execution consistency warnings.
float coreCompressionHigh = ta.highest(high, i_compressionBars)[1]
float coreCompressionLow = ta.lowest(low, i_compressionBars)[1]
float coreCompressionWidth = coreCompressionHigh - coreCompressionLow
bool coreCompression = not na(coreCompressionWidth) and coreCompressionWidth <= executionAtr * i_compressionATR
float acceptanceLowestClose = ta.lowest(close, i_acceptBars)
float acceptanceHighestClose = ta.highest(close, i_acceptBars)
float coreStopLow = ta.lowest(low, i_stopLookback)
float coreStopHigh = ta.highest(high, i_stopLookback)
float microStopLow = ta.lowest(low, i_microStopLookback)
float microStopHigh = ta.highest(high, i_microStopLookback)

// =================================================================================================
// 15M COMMAND — COMPLETED HTF VALUES ONLY
// =================================================================================================
float cmdClose = request.security(syminfo.tickerid, i_commandTf, close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float cmdFast = request.security(syminfo.tickerid, i_commandTf, ta.ema(close, i_cmdFastLen)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float cmdFastPrev = request.security(syminfo.tickerid, i_commandTf, ta.ema(close, i_cmdFastLen)[2], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float cmdSlow = request.security(syminfo.tickerid, i_commandTf, ta.ema(close, i_cmdSlowLen)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float cmdKama = request.security(syminfo.tickerid, i_commandTf, f_kama(close, i_cmdKamaLen, 2, 30)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float cmdAtr = request.security(syminfo.tickerid, i_commandTf, ta.atr(i_cmdAtrLen)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float cmdAtrBase = request.security(syminfo.tickerid, i_commandTf, ta.sma(ta.atr(i_cmdAtrLen), i_cmdAtrBase)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float cmdER = request.security(syminfo.tickerid, i_commandTf, f_efficiency(close, i_cmdErLen)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float cmdAtrRatio = not na(cmdAtrBase) and cmdAtrBase > 0 ? cmdAtr / cmdAtrBase : 0.0
bool cmdStackLong = not na(cmdClose) and cmdClose > cmdFast and cmdFast > cmdSlow and cmdClose > cmdKama
bool cmdStackShort = not na(cmdClose) and cmdClose < cmdFast and cmdFast < cmdSlow and cmdClose < cmdKama
bool cmdSlopeLong = not na(cmdFastPrev) and cmdFast > cmdFastPrev
bool cmdSlopeShort = not na(cmdFastPrev) and cmdFast < cmdFastPrev
bool cmdEfficiencyOkay = cmdER >= i_cmdMinER
bool cmdVolOkay = cmdAtrRatio >= i_cmdMinAtrRatio

int commandLongScore = 0
commandLongScore += cmdStackLong ? 42 : 0
commandLongScore += cmdSlopeLong ? 16 : 0
commandLongScore += cmdEfficiencyOkay ? 18 : 0
commandLongScore += cmdVolOkay ? 12 : 0
commandLongScore += aboveActiveVwap ? 12 : 0
int commandShortScore = 0
commandShortScore += cmdStackShort ? 42 : 0
commandShortScore += cmdSlopeShort ? 16 : 0
commandShortScore += cmdEfficiencyOkay ? 18 : 0
commandShortScore += cmdVolOkay ? 12 : 0
commandShortScore += belowActiveVwap ? 12 : 0
bool commandLong = commandLongScore >= i_cmdMinScore and commandLongScore > commandShortScore
bool commandShort = commandShortScore >= i_cmdMinScore and commandShortScore > commandLongScore
int commandScore = commandLong ? commandLongScore : commandShort ? commandShortScore : math.max(commandLongScore, commandShortScore)
string commandText = commandLong ? "LONG COMMAND" : commandShort ? "SHORT COMMAND" : "NEUTRAL COMMAND"

// =================================================================================================
// 5M STRUCTURE — COMPLETED HTF VALUES ONLY
// =================================================================================================
float m5Close = request.security(syminfo.tickerid, i_structureTf, close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float m5Fast = request.security(syminfo.tickerid, i_structureTf, ta.ema(close, i_m5FastLen)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float m5FastPrev = request.security(syminfo.tickerid, i_structureTf, ta.ema(close, i_m5FastLen)[2], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float m5Slow = request.security(syminfo.tickerid, i_structureTf, ta.ema(close, i_m5SlowLen)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float m5Kama = request.security(syminfo.tickerid, i_structureTf, f_kama(close, i_m5KamaLen, 2, 30)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float m5Atr = request.security(syminfo.tickerid, i_structureTf, ta.atr(i_m5AtrLen)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float m5Impulse = request.security(syminfo.tickerid, i_structureTf, math.abs(close - close[1])[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float m5CompressionHigh = request.security(syminfo.tickerid, i_structureTf, ta.highest(high, i_compressionBars)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float m5CompressionLow = request.security(syminfo.tickerid, i_structureTf, ta.lowest(low, i_compressionBars)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float m5CompressionWidth = m5CompressionHigh - m5CompressionLow
bool m5StackLong = not na(m5Close) and m5Close > m5Fast and m5Fast > m5Slow and m5Close > m5Kama
bool m5StackShort = not na(m5Close) and m5Close < m5Fast and m5Fast < m5Slow and m5Close < m5Kama
bool m5SlopeLong = not na(m5FastPrev) and m5Fast > m5FastPrev
bool m5SlopeShort = not na(m5FastPrev) and m5Fast < m5FastPrev
bool m5ImpulseOkay = not na(m5Impulse) and not na(m5Atr) and m5Impulse >= m5Atr * 0.35
bool m5Compression = not na(m5CompressionWidth) and not na(m5Atr) and m5CompressionWidth <= m5Atr * i_compressionATR

bool aboveRangeAccepted = rangeReady and close > rangeHigh and acceptanceLowestClose > rangeHigh - executionAtr * i_levelBuffer
bool belowRangeAccepted = rangeReady and close < rangeLow and acceptanceHighestClose < rangeLow + executionAtr * i_levelBuffer
bool aboveRange = rangeReady and close > rangeHigh
bool belowRange = rangeReady and close < rangeLow

int structureLongScore = 0
structureLongScore += m5StackLong ? 40 : 0
structureLongScore += m5SlopeLong ? 18 : 0
structureLongScore += aboveActiveVwap ? 16 : 0
structureLongScore += aboveRangeAccepted ? 14 : aboveRange ? 7 : 0
structureLongScore += m5ImpulseOkay ? 6 : 0
structureLongScore += executionEmaSlope > 0 ? 6 : 0
int structureShortScore = 0
structureShortScore += m5StackShort ? 40 : 0
structureShortScore += m5SlopeShort ? 18 : 0
structureShortScore += belowActiveVwap ? 16 : 0
structureShortScore += belowRangeAccepted ? 14 : belowRange ? 7 : 0
structureShortScore += m5ImpulseOkay ? 6 : 0
structureShortScore += executionEmaSlope < 0 ? 6 : 0
bool structureLong = structureLongScore >= i_structureMinScore and structureLongScore > structureShortScore
bool structureShort = structureShortScore >= i_structureMinScore and structureShortScore > structureLongScore
int structureScore = structureLong ? structureLongScore : structureShort ? structureShortScore : math.max(structureLongScore, structureShortScore)
string structureText = structureLong ? "BULLISH 5m" : structureShort ? "BEARISH 5m" : "MIXED 5m"

// Matrix direction is the only permission source for the MicroPulse submodule.
bool matrixLong = commandLong and structureLong
bool matrixShort = commandShort and structureShort
int matrixDirectionalScore = matrixLong ? int(math.round((commandLongScore + structureLongScore) * 0.5)) : matrixShort ? int(math.round((commandShortScore + structureShortScore) * 0.5)) : int(math.round(math.max(commandLongScore + structureLongScore, commandShortScore + structureShortScore) * 0.5))
string matrixSide = matrixLong ? "LONG" : matrixShort ? "SHORT" : "NEUTRAL"

// =================================================================================================
// LIQUIDITY / FAILED-AUCTION CONTEXT
// =================================================================================================
float sweepDistance = executionAtr * i_sweepBuffer
bool sweepBelowPDL = not na(priorRthLow) and low < priorRthLow - sweepDistance and close > priorRthLow
bool sweepBelowSession = not na(sweepSessionLow) and low < sweepSessionLow - sweepDistance and close > sweepSessionLow
bool sweepBelowRange = rangeReady and low < rangeLow - sweepDistance and close > rangeLow
bool sweepAbovePDH = not na(priorRthHigh) and high > priorRthHigh + sweepDistance and close < priorRthHigh
bool sweepAboveSession = not na(sweepSessionHigh) and high > sweepSessionHigh + sweepDistance and close < sweepSessionHigh
bool sweepAboveRange = rangeReady and high > rangeHigh + sweepDistance and close < rangeHigh
bool bullFailedAuction = sweepBelowPDL or sweepBelowSession or sweepBelowRange
bool bearFailedAuction = sweepAbovePDH or sweepAboveSession or sweepAboveRange
string bullSweepName = sweepBelowPDL ? "PDL RECLAIM" : sweepBelowSession ? "SESSION LOW RECLAIM" : sweepBelowRange ? rangeName + " LOW RECLAIM" : ""
string bearSweepName = sweepAbovePDH ? "PDH REJECT" : sweepAboveSession ? "SESSION HIGH REJECT" : sweepAboveRange ? rangeName + " HIGH REJECT" : ""

// =================================================================================================
// MATRIX CORE SETUP ENGINE — RETEST / PULLBACK / COMPRESSION / FAILED AUCTION
// =================================================================================================
bool coreNearVwapLong = aboveActiveVwap and low <= activeVwap + executionAtr * i_pullbackTolerance
bool coreNearVwapShort = belowActiveVwap and high >= activeVwap - executionAtr * i_pullbackTolerance
bool coreNearKamaLong = aboveExecutionKama and low <= executionKama + executionAtr * i_pullbackTolerance
bool coreNearKamaShort = belowExecutionKama and high >= executionKama - executionAtr * i_pullbackTolerance
bool coreLongPullbackStalk = matrixLong and (coreNearVwapLong or coreNearKamaLong)
bool coreShortPullbackStalk = matrixShort and (coreNearVwapShort or coreNearKamaShort)
bool coreLongRangeRetestStalk = matrixLong and rangeReady and aboveRange and low <= rangeHigh + executionAtr * i_levelBuffer
bool coreShortRangeRetestStalk = matrixShort and rangeReady and belowRange and high >= rangeLow - executionAtr * i_levelBuffer
bool coreLongCompressionStalk = matrixLong and (m5Compression or coreCompression) and close >= coreCompressionHigh - executionAtr * i_levelBuffer
bool coreShortCompressionStalk = matrixShort and (m5Compression or coreCompression) and close <= coreCompressionLow + executionAtr * i_levelBuffer
bool coreLongFailedAuctionStalk = i_enableFailedAuction and bullFailedAuction and not matrixShort and (matrixLong or commandLongScore >= 55)
bool coreShortFailedAuctionStalk = i_enableFailedAuction and bearFailedAuction and not matrixLong and (matrixShort or commandShortScore >= 55)

bool coreLongStalk = coreLongPullbackStalk or coreLongRangeRetestStalk or coreLongCompressionStalk or coreLongFailedAuctionStalk
bool coreShortStalk = coreShortPullbackStalk or coreShortRangeRetestStalk or coreShortCompressionStalk or coreShortFailedAuctionStalk
bool coreBullTrigger = bullImpulse and (close > high[1] or close > executionEma)
bool coreBearTrigger = bearImpulse and (close < low[1] or close < executionEma)
bool coreLongTrigger = ((coreLongPullbackStalk or coreLongRangeRetestStalk) and coreBullTrigger) or (coreLongCompressionStalk and close > coreCompressionHigh and bullImpulse) or (coreLongFailedAuctionStalk and bullImpulse and close > executionEma)
bool coreShortTrigger = ((coreShortPullbackStalk or coreShortRangeRetestStalk) and coreBearTrigger) or (coreShortCompressionStalk and close < coreCompressionLow and bearImpulse) or (coreShortFailedAuctionStalk and bearImpulse and close < executionEma)
string coreLongName = coreLongRangeRetestStalk ? rangeName + " RETEST" : coreLongPullbackStalk ? "VWAP / KAMA PULLBACK" : coreLongCompressionStalk ? "COMPRESSION BREAK" : coreLongFailedAuctionStalk ? bullSweepName : ""
string coreShortName = coreShortRangeRetestStalk ? rangeName + " RETEST" : coreShortPullbackStalk ? "VWAP / KAMA PULLBACK" : coreShortCompressionStalk ? "COMPRESSION BREAK" : coreShortFailedAuctionStalk ? bearSweepName : ""

int coreLongScore = 0
coreLongScore += matrixLong ? 26 : 0
coreLongScore += coreLongRangeRetestStalk ? 20 : 0
coreLongScore += coreLongPullbackStalk ? 18 : 0
coreLongScore += coreLongCompressionStalk ? 18 : 0
coreLongScore += coreLongFailedAuctionStalk ? 22 : 0
coreLongScore += volumeExpanding ? 8 : 0
coreLongScore += bullImpulse ? 8 : 0
coreLongScore += aboveRangeAccepted ? 4 : 0
coreLongScore := int(f_clamp(coreLongScore, 0, 100))
int coreShortScore = 0
coreShortScore += matrixShort ? 26 : 0
coreShortScore += coreShortRangeRetestStalk ? 20 : 0
coreShortScore += coreShortPullbackStalk ? 18 : 0
coreShortScore += coreShortCompressionStalk ? 18 : 0
coreShortScore += coreShortFailedAuctionStalk ? 22 : 0
coreShortScore += volumeExpanding ? 8 : 0
coreShortScore += bearImpulse ? 8 : 0
coreShortScore += belowRangeAccepted ? 4 : 0
coreShortScore := int(f_clamp(coreShortScore, 0, 100))

// =================================================================================================
// MICRO PULSE — MATRIX-GATED ONLY
// =================================================================================================
float profileTrailMultiplier = i_microProfile == "Precision" ? i_microTrailMult * 1.18 : i_microProfile == "Aggressive" ? i_microTrailMult * 0.78 : i_microTrailMult
float profileMinER = i_microProfile == "Precision" ? 0.30 : i_microProfile == "Aggressive" ? 0.16 : 0.23
float profileMinBody = i_microProfile == "Precision" ? 0.52 : i_microProfile == "Aggressive" ? 0.32 : 0.42
float profileMinRelVol = i_microProfile == "Precision" ? 1.15 : i_microProfile == "Aggressive" ? 0.85 : 1.00
int profileFireScore = i_microProfile == "Precision" ? int(math.min(100, i_microFireScore + 6)) : i_microProfile == "Aggressive" ? int(math.max(40, i_microFireScore - 10)) : i_microFireScore
int profileArmScore = i_microProfile == "Precision" ? int(math.min(100, i_microArmScore + 5)) : i_microProfile == "Aggressive" ? int(math.max(35, i_microArmScore - 8)) : i_microArmScore
float profileChaseATR = i_microProfile == "Precision" ? i_microMaxChaseATR * 0.75 : i_microProfile == "Aggressive" ? i_microMaxChaseATR * 1.35 : i_microMaxChaseATR

float microFast = ta.ema(close, i_microFastLen)
float microSlow = ta.ema(close, i_microSlowLen)
float microKama = f_kama(close, i_microKamaLen, 2, 30)
float microER = f_efficiency(close, i_microErLen)
float microFastSlope = microFast - microFast[1]
float microTrailAtr = ta.atr(i_microTrailAtrLen)
float microTrailLoss = microTrailAtr * profileTrailMultiplier

// Adaptive pulse trail: only visual / actionable when Matrix direction is already earned.
var float pulseTrail = na
if na(pulseTrail[1])
    pulseTrail := close - microTrailLoss
else if close > pulseTrail[1] and close[1] > pulseTrail[1]
    pulseTrail := math.max(pulseTrail[1], close - microTrailLoss)
else if close < pulseTrail[1] and close[1] < pulseTrail[1]
    pulseTrail := math.min(pulseTrail[1], close + microTrailLoss)
else if close > pulseTrail[1]
    pulseTrail := close - microTrailLoss
else
    pulseTrail := close + microTrailLoss

var int pulseTrailDirection = 0
if close > pulseTrail
    pulseTrailDirection := 1
else if close < pulseTrail
    pulseTrailDirection := -1
else
    pulseTrailDirection := nz(pulseTrailDirection[1], 0)

bool pulseTrailLong = pulseTrailDirection == 1
bool pulseTrailShort = pulseTrailDirection == -1
bool pulseTrailFlipLong = pulseTrailLong and nz(pulseTrailDirection[1], 0) == -1
bool pulseTrailFlipShort = pulseTrailShort and nz(pulseTrailDirection[1], 0) == 1
bool microBullBar = close > open and bodyRatio >= math.max(profileMinBody * 0.72, 0.20)
bool microBearBar = close < open and bodyRatio >= math.max(profileMinBody * 0.72, 0.20)
bool microBullImpulse = close > open and bodyRatio >= profileMinBody and close >= high - candleRange * 0.28
bool microBearImpulse = close < open and bodyRatio >= profileMinBody and close <= low + candleRange * 0.28

int microBullPulseCount = 0
int microBearPulseCount = 0
for i = 0 to i_microPulseBars - 1
    microBullPulseCount += microBullBar[i] ? 1 : 0
    microBearPulseCount += microBearBar[i] ? 1 : 0
bool microBullPulse = microBullPulseCount >= i_microSameSideBars
bool microBearPulse = microBearPulseCount >= i_microSameSideBars
float microBreakHigh = ta.highest(high, i_microPulseBars)[1]
float microBreakLow = ta.lowest(low, i_microPulseBars)[1]
float microCompressionHigh = ta.highest(high, i_microPulseBars)[1]
float microCompressionLow = ta.lowest(low, i_microPulseBars)[1]
float microCompressionWidth = microCompressionHigh - microCompressionLow
bool microCompression = not na(microCompressionWidth) and microCompressionWidth <= executionAtr * 0.75
bool microStackLong = close > microFast and microFast > microSlow and close > microKama and microFastSlope > 0
bool microStackShort = close < microFast and microFast < microSlow and close < microKama and microFastSlope < 0
bool microEfficiencyOkay = microER >= profileMinER
bool microVolumeOkay = relativeVolume >= profileMinRelVol
float microLongExtension = microTrailAtr > 0 ? (close - math.max(microFast, microKama)) / microTrailAtr : 999.0
float microShortExtension = microTrailAtr > 0 ? (math.min(microFast, microKama) - close) / microTrailAtr : 999.0
bool microNotChasedLong = microLongExtension <= profileChaseATR
bool microNotChasedShort = microShortExtension <= profileChaseATR

// P1 = Momentum ignition. P2 = pullback reclaim. P3 = compression release.
bool p1LongStalk = matrixLong and pulseTrailLong and microStackLong and close >= microBreakHigh - executionAtr * i_levelBuffer
bool p1ShortStalk = matrixShort and pulseTrailShort and microStackShort and close <= microBreakLow + executionAtr * i_levelBuffer
bool p1LongTrigger = p1LongStalk and close > microBreakHigh and microBullImpulse and microBullPulse
bool p1ShortTrigger = p1ShortStalk and close < microBreakLow and microBearImpulse and microBearPulse

bool p2LongStalk = matrixLong and pulseTrailLong and microStackLong and low <= math.max(microFast, microKama) + executionAtr * i_microPullbackATR and close > microFast and close > microKama
bool p2ShortStalk = matrixShort and pulseTrailShort and microStackShort and high >= math.min(microFast, microKama) - executionAtr * i_microPullbackATR and close < microFast and close < microKama
bool p2LongTrigger = p2LongStalk and microBullImpulse and close > high[1]
bool p2ShortTrigger = p2ShortStalk and microBearImpulse and close < low[1]

bool p3LongStalk = matrixLong and pulseTrailLong and microStackLong and microCompression and close >= microCompressionHigh - executionAtr * i_levelBuffer
bool p3ShortStalk = matrixShort and pulseTrailShort and microStackShort and microCompression and close <= microCompressionLow + executionAtr * i_levelBuffer
bool p3LongTrigger = p3LongStalk and close > microCompressionHigh and microBullImpulse
bool p3ShortTrigger = p3ShortStalk and close < microCompressionLow and microBearImpulse

bool microLongStalk = i_enableMicro and matrixLong and (p1LongStalk or p2LongStalk or p3LongStalk) and microEfficiencyOkay and microNotChasedLong
bool microShortStalk = i_enableMicro and matrixShort and (p1ShortStalk or p2ShortStalk or p3ShortStalk) and microEfficiencyOkay and microNotChasedShort
bool microLongTrigger = p1LongTrigger or p2LongTrigger or p3LongTrigger
bool microShortTrigger = p1ShortTrigger or p2ShortTrigger or p3ShortTrigger
string microLongName = p1LongTrigger ? "P1 IGNITION" : p2LongTrigger ? "P2 PULLBACK RECLAIM" : p3LongTrigger ? "P3 COMPRESSION RELEASE" : p1LongStalk ? "P1 IGNITION" : p2LongStalk ? "P2 PULLBACK RECLAIM" : p3LongStalk ? "P3 COMPRESSION RELEASE" : ""
string microShortName = p1ShortTrigger ? "P1 IGNITION" : p2ShortTrigger ? "P2 PULLBACK RECLAIM" : p3ShortTrigger ? "P3 COMPRESSION RELEASE" : p1ShortStalk ? "P1 IGNITION" : p2ShortStalk ? "P2 PULLBACK RECLAIM" : p3ShortStalk ? "P3 COMPRESSION RELEASE" : ""

int microLongContextScore = 0
microLongContextScore += matrixLong ? 28 : 0
microLongContextScore += pulseTrailLong ? 13 : 0
microLongContextScore += microStackLong ? 14 : 0
microLongContextScore += microEfficiencyOkay ? 9 : 0
microLongContextScore += microVolumeOkay ? 7 : 0
microLongContextScore += microNotChasedLong ? 8 : 0
microLongContextScore += (p1LongStalk or p2LongStalk or p3LongStalk) ? 11 : 0
microLongContextScore += aboveRangeAccepted ? 4 : 0
microLongContextScore += pulseTrailFlipLong ? 3 : 0
microLongContextScore := int(f_clamp(microLongContextScore, 0, 100))
int microShortContextScore = 0
microShortContextScore += matrixShort ? 28 : 0
microShortContextScore += pulseTrailShort ? 13 : 0
microShortContextScore += microStackShort ? 14 : 0
microShortContextScore += microEfficiencyOkay ? 9 : 0
microShortContextScore += microVolumeOkay ? 7 : 0
microShortContextScore += microNotChasedShort ? 8 : 0
microShortContextScore += (p1ShortStalk or p2ShortStalk or p3ShortStalk) ? 11 : 0
microShortContextScore += belowRangeAccepted ? 4 : 0
microShortContextScore += pulseTrailFlipShort ? 3 : 0
microShortContextScore := int(f_clamp(microShortContextScore, 0, 100))

int microLongScore = microLongContextScore
microLongScore += p1LongTrigger ? 12 : 0
microLongScore += p2LongTrigger ? 12 : 0
microLongScore += p3LongTrigger ? 12 : 0
microLongScore += microBullPulse ? 6 : 0
microLongScore := int(f_clamp(microLongScore, 0, 100))
int microShortScore = microShortContextScore
microShortScore += p1ShortTrigger ? 12 : 0
microShortScore += p2ShortTrigger ? 12 : 0
microShortScore += p3ShortTrigger ? 12 : 0
microShortScore += microBearPulse ? 6 : 0
microShortScore := int(f_clamp(microShortScore, 0, 100))

// =================================================================================================
// CORE AND MICRO RISK PLANS
// =================================================================================================
float longEntry = close
float shortEntry = close
float coreLongStop = f_roundTick(coreStopLow - executionAtr * i_stopBufferATR)
float coreShortStop = f_roundTick(coreStopHigh + executionAtr * i_stopBufferATR)
float minTargetDistance = executionAtr * i_minTargetATR
float coreLongMappedTarget = f_nearestAbove(longEntry, minTargetDistance, priorRthHigh, activeSessionHigh, rangeHigh, activeVwapUpper1, activeVwapUpper2, na)
float coreShortMappedTarget = f_nearestBelow(shortEntry, minTargetDistance, priorRthLow, activeSessionLow, rangeLow, activeVwapLower1, activeVwapLower2, na)
float coreLongTarget = f_roundTick(not na(coreLongMappedTarget) ? coreLongMappedTarget : longEntry + executionAtr * i_fallbackTargetATR)
float coreShortTarget = f_roundTick(not na(coreShortMappedTarget) ? coreShortMappedTarget : shortEntry - executionAtr * i_fallbackTargetATR)
float coreLongRiskPts = longEntry - coreLongStop
float coreShortRiskPts = coreShortStop - shortEntry
float coreLongR = coreLongRiskPts > syminfo.mintick ? (coreLongTarget - longEntry) / coreLongRiskPts : 0.0
float coreShortR = coreShortRiskPts > syminfo.mintick ? (shortEntry - coreShortTarget) / coreShortRiskPts : 0.0
float coreLongStopAtr = executionAtr > 0 ? coreLongRiskPts / executionAtr : 999.0
float coreShortStopAtr = executionAtr > 0 ? coreShortRiskPts / executionAtr : 999.0
float coreLongRiskDollars = coreLongRiskPts * syminfo.pointvalue * i_contracts
float coreShortRiskDollars = coreShortRiskPts * syminfo.pointvalue * i_contracts
bool coreLongRiskValid = coreLongStop < longEntry and coreLongTarget > longEntry and coreLongR >= i_minCoreR and coreLongStopAtr <= i_maxCoreStopATR
bool coreShortRiskValid = coreShortStop > shortEntry and coreShortTarget < shortEntry and coreShortR >= i_minCoreR and coreShortStopAtr <= i_maxCoreStopATR

float microLongStopRaw = math.max(pulseTrail - microTrailAtr * i_stopBufferATR, microStopLow - microTrailAtr * i_stopBufferATR)
float microShortStopRaw = math.min(pulseTrail + microTrailAtr * i_stopBufferATR, microStopHigh + microTrailAtr * i_stopBufferATR)
float microLongStop = f_roundTick(microLongStopRaw)
float microShortStop = f_roundTick(microShortStopRaw)
float microLongRiskPts = longEntry - microLongStop
float microShortRiskPts = microShortStop - shortEntry
float microLongTarget1 = f_roundTick(longEntry + microLongRiskPts * i_microTP1R)
float microShortTarget1 = f_roundTick(shortEntry - microShortRiskPts * i_microTP1R)
float microLongCeiling = f_nearestAbove(longEntry, microTrailAtr * 0.30, priorRthHigh, activeSessionHigh, rangeHigh, activeVwapUpper1, microBreakHigh, na)
float microShortFloor = f_nearestBelow(shortEntry, microTrailAtr * 0.30, priorRthLow, activeSessionLow, rangeLow, activeVwapLower1, microBreakLow, na)
float microLongNaturalTarget2 = longEntry + microLongRiskPts * i_microTP2R
float microShortNaturalTarget2 = shortEntry - microShortRiskPts * i_microTP2R
float microLongTarget2 = f_roundTick(not na(microLongCeiling) ? math.min(microLongNaturalTarget2, microLongCeiling) : microLongNaturalTarget2)
float microShortTarget2 = f_roundTick(not na(microShortFloor) ? math.max(microShortNaturalTarget2, microShortFloor) : microShortNaturalTarget2)
float microLongR2 = microLongRiskPts > syminfo.mintick ? (microLongTarget2 - longEntry) / microLongRiskPts : 0.0
float microShortR2 = microShortRiskPts > syminfo.mintick ? (shortEntry - microShortTarget2) / microShortRiskPts : 0.0
float microLongStopAtr = microTrailAtr > 0 ? microLongRiskPts / microTrailAtr : 999.0
float microShortStopAtr = microTrailAtr > 0 ? microShortRiskPts / microTrailAtr : 999.0
float microLongRiskDollars = microLongRiskPts * syminfo.pointvalue * i_contracts
float microShortRiskDollars = microShortRiskPts * syminfo.pointvalue * i_contracts

int microLongRiskScore = 0
microLongRiskScore += microLongStopAtr <= 0.65 ? 38 : microLongStopAtr <= i_maxMicroStopATR ? 24 : 0
microLongRiskScore += microLongR2 >= i_microTP2R * 0.85 ? 34 : microLongR2 >= 1.0 ? 22 : 0
microLongRiskScore += not na(microLongCeiling) ? 16 : 8
microLongRiskScore += microLongRiskPts > syminfo.mintick ? 12 : 0
microLongRiskScore := int(f_clamp(microLongRiskScore, 0, 100))
int microShortRiskScore = 0
microShortRiskScore += microShortStopAtr <= 0.65 ? 38 : microShortStopAtr <= i_maxMicroStopATR ? 24 : 0
microShortRiskScore += microShortR2 >= i_microTP2R * 0.85 ? 34 : microShortR2 >= 1.0 ? 22 : 0
microShortRiskScore += not na(microShortFloor) ? 16 : 8
microShortRiskScore += microShortRiskPts > syminfo.mintick ? 12 : 0
microShortRiskScore := int(f_clamp(microShortRiskScore, 0, 100))
bool microLongRiskValid = microLongStop < longEntry and microLongTarget1 > longEntry and microLongTarget2 >= microLongTarget1 and microLongStopAtr <= i_maxMicroStopATR and microLongRiskScore >= 60
bool microShortRiskValid = microShortStop > shortEntry and microShortTarget1 < shortEntry and microShortTarget2 <= microShortTarget1 and microShortStopAtr <= i_maxMicroStopATR and microShortRiskScore >= 60

// =================================================================================================
// SIGNAL GOVERNANCE + MICRO MODEL RIDE STATE
// =================================================================================================
var int signalsThisSession = 0
var int lastFireBar = na
var int pulseRideDirection = 0
var int pulseRideStartBar = na
var float pulseRideEntry = na
var float pulseRideStop = na
var float pulseRideTP1 = na
var float pulseRideTP2 = na
var float pulseRideRiskDollars = na
var string pulseRideName = ""

bool resetSignals = (allowRth and rthEnter) or (allowEth and globexOpen)
if resetSignals
    signalsThisSession := 0

bool rideWasActive = pulseRideDirection != 0
int rideBarsBefore = rideWasActive and not na(pulseRideStartBar) ? bar_index - pulseRideStartBar + 1 : 0
bool pulseLongInvalid = pulseRideDirection == 1 and (close < pulseTrail or close < microKama or pulseTrailDirection == -1)
bool pulseShortInvalid = pulseRideDirection == -1 and (close > pulseTrail or close > microKama or pulseTrailDirection == 1)
bool pulseLongTimed = pulseRideDirection == 1 and i_microForceTimeExit and rideBarsBefore >= i_microRideBars
bool pulseShortTimed = pulseRideDirection == -1 and i_microForceTimeExit and rideBarsBefore >= i_microRideBars
bool exitPulseLong = barGate and (pulseLongInvalid or pulseLongTimed)
bool exitPulseShort = barGate and (pulseShortInvalid or pulseShortTimed)

if exitPulseLong or exitPulseShort
    pulseRideDirection := 0
    pulseRideStartBar := na
    pulseRideEntry := na
    pulseRideStop := na
    pulseRideTP1 := na
    pulseRideTP2 := na
    pulseRideRiskDollars := na
    pulseRideName := ""

bool cooldownActive = not na(lastFireBar) and bar_index - lastFireBar < i_cooldownBars
bool quotaAvailable = signalsThisSession < i_maxSignals
bool timePermission = (allowRth and rthTimeAllowed) or (allowEth and ethTimeAllowed)
bool sessionReady = selectedSession and not rangeBuilding
bool tradingPermission = sessionReady and timePermission and not executionTfLock and not chartTypeLock and not warmupActive
bool baseLock = not tradingPermission or cooldownActive or not quotaAvailable or rideWasActive

bool coreLongArmedRaw = i_enableCore and matrixLong and coreLongStalk and coreLongScore >= i_coreMinScore and coreLongRiskValid and not baseLock
bool coreShortArmedRaw = i_enableCore and matrixShort and coreShortStalk and coreShortScore >= i_coreMinScore and coreShortRiskValid and not baseLock
bool microLongArmedRaw = i_enableMicro and microLongStalk and microLongContextScore >= profileArmScore and microLongRiskValid and not baseLock
bool microShortArmedRaw = i_enableMicro and microShortStalk and microShortContextScore >= profileArmScore and microShortRiskValid and not baseLock

bool coreFireLongRaw = barGate and coreLongArmedRaw and coreLongTrigger
bool coreFireShortRaw = barGate and coreShortArmedRaw and coreShortTrigger
bool pulseFireLongRaw = barGate and microLongArmedRaw and microLongTrigger and microLongScore >= profileFireScore
bool pulseFireShortRaw = barGate and microShortArmedRaw and microShortTrigger and microShortScore >= profileFireScore

bool fireLong = coreFireLongRaw or pulseFireLongRaw
bool fireShort = coreFireShortRaw or pulseFireShortRaw
int longFireScore = math.max(coreLongScore, microLongScore)
int shortFireScore = math.max(coreShortScore, microShortScore)
if fireLong and fireShort
    fireLong := longFireScore >= shortFireScore
    fireShort := not fireLong

bool firePulseLong = fireLong and pulseFireLongRaw
bool firePulseShort = fireShort and pulseFireShortRaw
bool fireCoreLong = fireLong and not firePulseLong
bool fireCoreShort = fireShort and not firePulseShort

if fireLong or fireShort
    lastFireBar := bar_index
    signalsThisSession += 1

if firePulseLong
    pulseRideDirection := 1
    pulseRideStartBar := bar_index
    pulseRideEntry := longEntry
    pulseRideStop := microLongStop
    pulseRideTP1 := microLongTarget1
    pulseRideTP2 := microLongTarget2
    pulseRideRiskDollars := microLongRiskDollars
    pulseRideName := microLongName
else if firePulseShort
    pulseRideDirection := -1
    pulseRideStartBar := bar_index
    pulseRideEntry := shortEntry
    pulseRideStop := microShortStop
    pulseRideTP1 := microShortTarget1
    pulseRideTP2 := microShortTarget2
    pulseRideRiskDollars := microShortRiskDollars
    pulseRideName := microShortName

bool coreLongArmed = coreLongArmedRaw and not fireCoreLong and not firePulseLong
bool coreShortArmed = coreShortArmedRaw and not fireCoreShort and not firePulseShort
bool microLongArmed = microLongArmedRaw and not firePulseLong and not fireLong
bool microShortArmed = microShortArmedRaw and not firePulseShort and not fireShort
bool longBias = matrixLong and tradingPermission and not cooldownActive and quotaAvailable and not rideWasActive
bool shortBias = matrixShort and tradingPermission and not cooldownActive and quotaAvailable and not rideWasActive
bool newMicroLongArmed = microLongArmed and (bar_index == 0 or not microLongArmed[1])
bool newMicroShortArmed = microShortArmed and (bar_index == 0 or not microShortArmed[1])
bool newCoreLongArmed = coreLongArmed and (bar_index == 0 or not coreLongArmed[1])
bool newCoreShortArmed = coreShortArmed and (bar_index == 0 or not coreShortArmed[1])
bool newMatrixLong = matrixLong and (bar_index == 0 or not matrixLong[1])
bool newMatrixShort = matrixShort and (bar_index == 0 or not matrixShort[1])

// =================================================================================================
// ONE PLAIN-ENGLISH MATRIX STATE — PULSE LANGUAGE EXISTS ONLY AFTER MATRIX DIRECTION IS EARNED
// =================================================================================================
string lockReason = chartTypeLock ? "USE STANDARD CANDLES" : executionTfLock ? "SET 45s / 1m CHART" : warmupActive ? "WARM-UP — FIRST SESSION" : not selectedSession ? "SESSION MODE / MAINTENANCE" : rangeBuilding ? "BUILDING " + rangeName : not timePermission ? (isEth ? "ETH TIME WINDOW LOCK" : "RTH TIME WINDOW LOCK") : cooldownActive ? "RE-ENTRY COOLDOWN" : not quotaAvailable ? "SIGNAL QUOTA REACHED" : ""
int rideBarsAfter = pulseRideDirection != 0 and not na(pulseRideStartBar) ? bar_index - pulseRideStartBar + 1 : 0
string stateText = exitPulseLong ? "PULSE EXIT LONG" : exitPulseShort ? "PULSE EXIT SHORT" : firePulseLong ? "PULSE LONG NOW" : firePulseShort ? "PULSE SHORT NOW" : fireCoreLong ? "LONG NOW" : fireCoreShort ? "SHORT NOW" : microLongArmed ? "MICRO LONG ARMED" : microShortArmed ? "MICRO SHORT ARMED" : coreLongArmed ? "LONG SETUP ARMED" : coreShortArmed ? "SHORT SETUP ARMED" : pulseRideDirection == 1 ? "MANAGE PULSE LONG " + str.tostring(rideBarsAfter) + "/" + str.tostring(i_microRideBars) : pulseRideDirection == -1 ? "MANAGE PULSE SHORT " + str.tostring(rideBarsAfter) + "/" + str.tostring(i_microRideBars) : longBias ? "LONG BIAS" : shortBias ? "SHORT BIAS" : lockReason != "" ? "WAIT — " + lockReason : "NO TRADE"
string actionText = exitPulseLong or exitPulseShort ? "CLOSE / REASSESS" : firePulseLong or firePulseShort ? "EXECUTE 2–3 BAR PULSE" : fireCoreLong or fireCoreShort ? "EXECUTE MATRIX PLAN" : microLongArmed or microShortArmed ? "AWAIT PULSE CONFIRMATION" : coreLongArmed or coreShortArmed ? "AWAIT CORE TRIGGER" : pulseRideDirection != 0 ? "MANAGE PLAN — DO NOT ADD" : longBias or shortBias ? "WAIT FOR MICRO PULSE" : lockReason != "" ? "STANDBY" : "STANDBY — NO DIRECTIONAL EDGE"
color stateColor = f_stateColor(stateText)

string activePlanSide = firePulseLong or pulseRideDirection == 1 or microLongArmed ? "LONG" : firePulseShort or pulseRideDirection == -1 or microShortArmed ? "SHORT" : fireCoreLong or coreLongArmed ? "LONG" : fireCoreShort or coreShortArmed ? "SHORT" : ""
bool activePlanPulse = firePulseLong or firePulseShort or pulseRideDirection != 0 or microLongArmed or microShortArmed
float activePlanEntry = firePulseLong ? longEntry : firePulseShort ? shortEntry : pulseRideDirection != 0 ? pulseRideEntry : activePlanSide == "LONG" and activePlanPulse ? longEntry : activePlanSide == "SHORT" and activePlanPulse ? shortEntry : activePlanSide == "LONG" ? longEntry : activePlanSide == "SHORT" ? shortEntry : na
float activePlanStop = firePulseLong ? microLongStop : firePulseShort ? microShortStop : pulseRideDirection != 0 ? pulseRideStop : activePlanSide == "LONG" and activePlanPulse ? microLongStop : activePlanSide == "SHORT" and activePlanPulse ? microShortStop : activePlanSide == "LONG" ? coreLongStop : activePlanSide == "SHORT" ? coreShortStop : na
float activePlanTP1 = firePulseLong ? microLongTarget1 : firePulseShort ? microShortTarget1 : pulseRideDirection != 0 ? pulseRideTP1 : activePlanSide == "LONG" and activePlanPulse ? microLongTarget1 : activePlanSide == "SHORT" and activePlanPulse ? microShortTarget1 : activePlanSide == "LONG" ? f_roundTick(longEntry + coreLongRiskPts) : activePlanSide == "SHORT" ? f_roundTick(shortEntry - coreShortRiskPts) : na
float activePlanTP2 = firePulseLong ? microLongTarget2 : firePulseShort ? microShortTarget2 : pulseRideDirection != 0 ? pulseRideTP2 : activePlanSide == "LONG" and activePlanPulse ? microLongTarget2 : activePlanSide == "SHORT" and activePlanPulse ? microShortTarget2 : activePlanSide == "LONG" ? coreLongTarget : activePlanSide == "SHORT" ? coreShortTarget : na
float activePlanR = firePulseLong ? microLongR2 : firePulseShort ? microShortR2 : pulseRideDirection != 0 ? (pulseRideDirection == 1 ? (pulseRideTP2 - pulseRideEntry) / math.max(pulseRideEntry - pulseRideStop, syminfo.mintick) : (pulseRideEntry - pulseRideTP2) / math.max(pulseRideStop - pulseRideEntry, syminfo.mintick)) : activePlanSide == "LONG" and activePlanPulse ? microLongR2 : activePlanSide == "SHORT" and activePlanPulse ? microShortR2 : activePlanSide == "LONG" ? coreLongR : activePlanSide == "SHORT" ? coreShortR : na
float activePlanRiskDollars = firePulseLong ? microLongRiskDollars : firePulseShort ? microShortRiskDollars : pulseRideDirection != 0 ? pulseRideRiskDollars : activePlanSide == "LONG" and activePlanPulse ? microLongRiskDollars : activePlanSide == "SHORT" and activePlanPulse ? microShortRiskDollars : activePlanSide == "LONG" ? coreLongRiskDollars : activePlanSide == "SHORT" ? coreShortRiskDollars : na
string activePlanName = firePulseLong ? microLongName : firePulseShort ? microShortName : pulseRideDirection != 0 ? pulseRideName : activePlanSide == "LONG" and activePlanPulse ? microLongName : activePlanSide == "SHORT" and activePlanPulse ? microShortName : activePlanSide == "LONG" ? coreLongName : activePlanSide == "SHORT" ? coreShortName : ""

// =================================================================================================
// ALERTS — ALERTS SHOULD USE "ONCE PER BAR CLOSE" IN CONFIRMED MODE
// =================================================================================================
alertcondition(firePulseLong, title="KRV NQ Matrix — PULSE LONG NOW", message="KRV NQ Matrix: PULSE LONG NOW on {{ticker}} {{interval}}. Matrix direction and MicroPulse are aligned. Check plan ladder before entry.")
alertcondition(firePulseShort, title="KRV NQ Matrix — PULSE SHORT NOW", message="KRV NQ Matrix: PULSE SHORT NOW on {{ticker}} {{interval}}. Matrix direction and MicroPulse are aligned. Check plan ladder before entry.")
alertcondition(exitPulseLong, title="KRV NQ Matrix — PULSE EXIT LONG", message="KRV NQ Matrix: PULSE EXIT LONG on {{ticker}} {{interval}}. Model pulse condition invalidated or ride window completed.")
alertcondition(exitPulseShort, title="KRV NQ Matrix — PULSE EXIT SHORT", message="KRV NQ Matrix: PULSE EXIT SHORT on {{ticker}} {{interval}}. Model pulse condition invalidated or ride window completed.")
alertcondition(fireCoreLong, title="KRV NQ Matrix — LONG NOW", message="KRV NQ Matrix: LONG NOW on {{ticker}} {{interval}}. Matrix core setup confirmed.")
alertcondition(fireCoreShort, title="KRV NQ Matrix — SHORT NOW", message="KRV NQ Matrix: SHORT NOW on {{ticker}} {{interval}}. Matrix core setup confirmed.")
// ARMED / COMMAND alerts use the same bar-close gate as FIRE / EXIT.
alertcondition(barGate and newMicroLongArmed, title="KRV NQ Matrix — MICRO LONG ARMED", message="KRV NQ Matrix: MICRO LONG ARMED on {{ticker}} {{interval}}. Matrix is long; await a P1, P2, or P3 pulse confirmation.")
alertcondition(barGate and newMicroShortArmed, title="KRV NQ Matrix — MICRO SHORT ARMED", message="KRV NQ Matrix: MICRO SHORT ARMED on {{ticker}} {{interval}}. Matrix is short; await a P1, P2, or P3 pulse confirmation.")
alertcondition(barGate and not chartTypeLock and not warmupActive and newMatrixLong, title="KRV NQ Matrix — LONG COMMAND", message="KRV NQ Matrix: 15m + 5m Matrix command is LONG on {{ticker}} {{interval}}.")
alertcondition(barGate and not chartTypeLock and not warmupActive and newMatrixShort, title="KRV NQ Matrix — SHORT COMMAND", message="KRV NQ Matrix: 15m + 5m Matrix command is SHORT on {{ticker}} {{interval}}.")

// #################################################################################################
// ═════════════════════════════ ALPHA AGENT UI LAYER — PRESENTATION ONLY ══════════════════════════
// Everything below READS engine outputs. Nothing below assigns to an engine variable.
// Glow plots are appended after the base plots so saved style overrides keep their slots.
// #################################################################################################

// -------------------------------------------------------------------------------------------------
// THEME TOKENS
// -------------------------------------------------------------------------------------------------
bool themeIce = i_theme == "Ice (Light Chart)"
bool themeObsidian = i_theme == "Obsidian"
bool themeEmerald = i_theme == "Matrix Emerald"
bool themeNeon = not themeIce and not themeObsidian and not themeEmerald
// Alpha Agent Neon: electric cyan + neon magenta on near-black (Alpha Agent brand palette), amber for caution.
color tLong    = themeIce ? color.rgb(5, 150, 105)   : themeObsidian ? color.rgb(0, 230, 160)   : themeEmerald ? C_LONG    : color.rgb(46, 255, 160)
color tShort   = themeIce ? color.rgb(219, 39, 119)  : themeObsidian ? color.rgb(255, 64, 96)   : themeEmerald ? C_SHORT   : color.rgb(255, 56, 200)
color tInfo    = themeIce ? color.rgb(2, 132, 199)   : themeObsidian ? color.rgb(186, 196, 210) : themeEmerald ? C_INFO    : color.rgb(63, 227, 255)
color tWarn    = themeIce ? color.rgb(217, 119, 6)   : themeObsidian ? color.rgb(255, 196, 0)   : themeEmerald ? C_WARN    : color.rgb(255, 196, 26)
color tNeutral = themeIce ? color.rgb(71, 85, 105)   : C_NEUTRAL
color tMuted   = themeIce ? color.rgb(148, 163, 184) : color.rgb(100, 116, 139)
color tBg      = themeIce ? color.rgb(248, 250, 252) : themeObsidian ? color.rgb(10, 10, 12)    : themeEmerald ? color.rgb(7, 12, 24)    : color.rgb(5, 8, 16)
color tBgAlt   = themeIce ? color.rgb(236, 241, 247) : themeObsidian ? color.rgb(20, 21, 26)    : themeEmerald ? color.rgb(13, 21, 40)   : color.rgb(11, 16, 32)
color tBrand   = themeIce ? color.rgb(2, 132, 199)   : themeObsidian ? color.rgb(240, 240, 245) : themeEmerald ? color.rgb(94, 234, 212) : color.rgb(63, 227, 255)
color tBrand2  = themeIce ? color.rgb(219, 39, 119)  : themeObsidian ? color.rgb(160, 160, 170) : themeEmerald ? color.rgb(94, 234, 212) : color.rgb(255, 64, 214)
color tInk     = themeIce ? color.white : color.rgb(5, 8, 16)

// Brand split: first word cyan, remainder magenta ("ALPHA" / "AGENT").
int brandSplit = str.pos(i_brandName, " ")
string brandA = na(brandSplit) ? i_brandName : str.substring(i_brandName, 0, brandSplit)
string brandB = na(brandSplit) ? "" : str.substring(i_brandName, brandSplit + 1)

// Luminous opacity: one knob scales every glow on the chart.
f_lum(color _c, float _transp) =>
    color.new(_c, f_clamp(100.0 - (100.0 - _transp) * i_luminosity / 100.0, 0.0, 100.0))

f_gradeThemed(int _score, color _a, color _b, color _c, color _d) =>
    _score >= 85 ? _a : _score >= 70 ? _b : _score >= 55 ? _c : _d

f_meter(int _score, int _cells) =>
    int _on = int(math.round(f_clamp(_score, 0, 100) / 100.0 * _cells))
    int _off = _cells - _on
    (_on > 0 ? str.repeat("▰", _on) : "") + (_off > 0 ? str.repeat("▱", _off) : "")

f_hudPos(string _p) =>
    _p == "Top Left" ? position.top_left : _p == "Top Center" ? position.top_center : _p == "Middle Right" ? position.middle_right : _p == "Middle Left" ? position.middle_left : _p == "Bottom Right" ? position.bottom_right : _p == "Bottom Center" ? position.bottom_center : _p == "Bottom Left" ? position.bottom_left : position.top_right

f_cell(table _t, int _col, int _row, string _txt, color _fg, color _bg, string _size, string _align, string _tip) =>
    table.cell(_t, _col, _row, _txt, text_color=_fg, bgcolor=_bg, text_size=_size, text_halign=_align, text_font_family=font.family_monospace, tooltip=_tip)

f_dossier(string _head, string _name, float _e, float _s, float _t1, float _t2, float _r, float _risk, int _score, string _side) =>
    _head + " — " + _name + "\nENTRY  " + str.tostring(_e, format.mintick) + "\nSTOP   " + str.tostring(_s, format.mintick) + "\nTP1    " + str.tostring(_t1, format.mintick) + "\nTP2    " + str.tostring(_t2, format.mintick) + "\nR:R    " + f_r(_r) + "\nRISK   " + f_money(_risk) + "\nSCORE  " + str.tostring(_score) + "  ·  MATRIX " + _side + "\nModel plan only — not a position."

// Non-standard chart lock is the one state that must be impossible to miss.
const color C_ALERT_RED = color.rgb(239, 35, 60)
bool setupLock = chartTypeLock or executionTfLock
color hudStateColor = setupLock ? C_ALERT_RED : warmupActive ? tWarn : str.contains(stateText, "PULSE LONG") or str.contains(stateText, "LONG NOW") ? tLong : str.contains(stateText, "PULSE SHORT") or str.contains(stateText, "SHORT NOW") ? tShort : str.contains(stateText, "ARMED") ? tWarn : str.contains(stateText, "BIAS") ? tInfo : tNeutral
bool neonChips = i_signalStyle == "Neon Chips"
bool proSignals = i_signalStyle == "Pro"
bool luminousSignals = i_signalStyle == "Luminous Tags" or neonChips or proSignals

// Quota lock readout: the engine's budget resets at 09:30 (RTH open) and 18:00 (Globex open) ET only,
// so tell the user when it lifts instead of a bare "QUOTA REACHED".
string quotaResetText = not allowRth ? "18:00 ET" : not allowEth ? "09:30 ET" : isEthOvernight ? "09:30 ET" : "18:00 ET"
string displayState = str.contains(stateText, "SIGNAL QUOTA REACHED") ? stateText + " · " + str.tostring(signalsThisSession) + "/" + str.tostring(i_maxSignals) + " · RESET " + quotaResetText : stateText
bool glassPlan = i_planStyle == "Glass Zones"
bool auraColumn = i_auraStyle != "Trigger Reticle"
bool auraReticle = i_auraStyle != "Column Glow"

// =================================================================================================
// VISUAL LANGUAGE — MATRIX CLEAN UNTIL DIRECTION IS EARNED
// =================================================================================================
// Plot budget: Pine allows 64 plot counts and any non-const colour costs an extra count. Static map lines therefore
// use const brand colours (still editable in the Style tab); theme + luminosity drive the dynamic layers.
const color C_MAP_CYAN = color.rgb(63, 227, 255)
const color C_MAP_PRIOR = color.rgb(167, 139, 250)

// Scale Guard: a plotted value always joins autoscale, so a far level squashes price. Render it only in range.
float guardRange = i_scaleGuardAtr * (not na(cmdAtr) and cmdAtr > 0 ? cmdAtr : executionAtr * 4.0)
// During warm-up the session map is incomplete, so no level is drawn at all.
f_guard(float _level) =>
    warmupActive ? na : not i_scaleGuard or na(_level) or math.abs(close - _level) <= guardRange ? _level : na
// On reset / handoff bars the VWAP and session-map levels are left blank so the lines break instead of drawing
// a vertical cliff when a level steps to its new value.
bool vwapBreak = rthEnter or rthExit or globexOpen
float vwapShown = warmupActive or vwapBreak ? na : i_guardVwap ? f_guard(activeVwap) : activeVwap
bool microVisualLong = i_enableMicro and matrixLong and selectedSession and not executionTfLock
bool microVisualShort = i_enableMicro and matrixShort and selectedSession and not executionTfLock
bool microVisualActive = microVisualLong or microVisualShort
color microSideColor = microVisualLong ? tLong : tShort

plot(i_showKama ? executionKama : na, "Execution KAMA", color=color.new(color.silver, 25), linewidth=2)
plot(i_showVwap ? vwapShown : na, "Active Session VWAP", color=C_MAP_CYAN, linewidth=2, style=plot.style_linebr)
plot(i_showDevBands ? f_guard(activeVwapUpper1) : na, "Active VWAP +1 Sigma", color=color.new(C_MAP_CYAN, 70), linewidth=1)
plot(i_showDevBands ? f_guard(activeVwapLower1) : na, "Active VWAP -1 Sigma", color=color.new(C_MAP_CYAN, 70), linewidth=1)
plot(i_showDevBands ? f_guard(activeVwapUpper2) : na, "Active VWAP +2 Sigma", color=color.new(C_MAP_CYAN, 85), linewidth=1)
plot(i_showDevBands ? f_guard(activeVwapLower2) : na, "Active VWAP -2 Sigma", color=color.new(C_MAP_CYAN, 85), linewidth=1)

plot(i_showSessionMap and not vwapBreak and not na(rthOrHigh) ? f_guard(rthOrHigh) : na, "RTH OR High", color=color.new(C_WARN, 30), linewidth=1, style=plot.style_linebr)
plot(i_showSessionMap and not vwapBreak and not na(rthOrLow) ? f_guard(rthOrLow) : na, "RTH OR Low", color=color.new(C_WARN, 30), linewidth=1, style=plot.style_linebr)
plot(i_showSessionMap and not vwapBreak and i_showEthRange and not na(ethOrHigh) ? f_guard(ethOrHigh) : na, "ETH OR High", color=color.new(C_MAP_CYAN, 60), linewidth=1, style=plot.style_linebr)
plot(i_showSessionMap and not vwapBreak and i_showEthRange and not na(ethOrLow) ? f_guard(ethOrLow) : na, "ETH OR Low", color=color.new(C_MAP_CYAN, 60), linewidth=1, style=plot.style_linebr)
plot(i_showSessionMap and not vwapBreak and not na(priorRthHigh) ? f_guard(priorRthHigh) : na, "Prior RTH High", color=color.new(C_MAP_PRIOR, 45), linewidth=1, style=plot.style_linebr)
plot(i_showSessionMap and not vwapBreak and not na(priorRthLow) ? f_guard(priorRthLow) : na, "Prior RTH Low", color=color.new(C_MAP_PRIOR, 45), linewidth=1, style=plot.style_linebr)
plot(i_showSessionMap and not vwapBreak and not na(visibleOvernightHigh) ? f_guard(visibleOvernightHigh) : na, "Overnight High", color=color.new(C_NEUTRAL, 58), linewidth=1, style=plot.style_linebr)
plot(i_showSessionMap and not vwapBreak and not na(visibleOvernightLow) ? f_guard(visibleOvernightLow) : na, "Overnight Low", color=color.new(C_NEUTRAL, 58), linewidth=1, style=plot.style_linebr)

// Kinetic ribbon: invisible in neutral conditions. Gradient fill = brightest at the fast edge (the "current").
bool ribbonOn = i_showPulseRibbon and microVisualActive
pMicroFast = plot(ribbonOn ? microFast : na, "Kinetic Fast", color=f_lum(microSideColor, 30), linewidth=1, style=plot.style_linebr)
pMicroSlow = plot(ribbonOn ? microSlow : na, "Kinetic Slow", color=f_lum(microSideColor, 70), linewidth=1, style=plot.style_linebr)
float ribbonTop = math.max(microFast, microSlow)
float ribbonBottom = math.min(microFast, microSlow)
fill(pMicroFast, pMicroSlow, ribbonTop, ribbonBottom, ribbonOn ? f_lum(microSideColor, microVisualLong ? 74 : 96) : na, ribbonOn ? f_lum(microSideColor, microVisualLong ? 96 : 74) : na, title="Kinetic Ribbon")
plot(i_showPulseTrail and microVisualActive ? pulseTrail : na, "MicroPulse Trail", color=f_lum(microSideColor, 8), linewidth=2, style=plot.style_linebr)

// Column aura — optional; the reticle below is the default armed visual.
// Armed visuals wait for the bar close in Confirmed mode (barGate), so nothing appears live and then vanishes.
color auraColor = not barGate ? na : microLongArmed ? f_lum(tLong, 92) : microShortArmed ? f_lum(tShort, 92) : na
color flashColor = i_fireFlash and (fireLong or fireShort) ? f_lum(fireLong ? tLong : tShort, 84) : na
bgcolor(not na(flashColor) ? flashColor : i_showPulseAura and auraColumn ? auraColor : na, title="MicroPulse Armed Aura")
plotshape(i_showPulseBeacons and barGate and newMicroLongArmed, title="MICRO LONG ARMED", style=shape.diamond, location=location.belowbar, color=color.new(C_WARN, 10), size=size.tiny, text="")
plotshape(i_showPulseBeacons and barGate and newMicroShortArmed, title="MICRO SHORT ARMED", style=shape.diamond, location=location.abovebar, color=color.new(C_WARN, 10), size=size.tiny, text="")
plotshape(i_showCoreMarkers and barGate and newCoreLongArmed, title="LONG SETUP ARMED", style=shape.circle, location=location.belowbar, color=color.new(C_WARN, 30), size=size.tiny, text="")
plotshape(i_showCoreMarkers and barGate and newCoreShortArmed, title="SHORT SETUP ARMED", style=shape.circle, location=location.abovebar, color=color.new(C_WARN, 30), size=size.tiny, text="")
plotshape(i_showCoreMarkers and fireCoreLong and not luminousSignals, title="LONG NOW", style=shape.labelup, location=location.belowbar, color=C_LONG, textcolor=color.black, text="LONG\nNOW", size=size.small)
plotshape(i_showCoreMarkers and fireCoreShort and not luminousSignals, title="SHORT NOW", style=shape.labeldown, location=location.abovebar, color=C_SHORT, textcolor=color.white, text="SHORT\nNOW", size=size.small)
plotshape(i_showPulseBeacons and firePulseLong and not luminousSignals, title="PULSE LONG NOW", style=shape.labelup, location=location.belowbar, color=C_LONG, textcolor=color.black, text="PULSE\nLONG", size=size.small)
plotshape(i_showPulseBeacons and firePulseShort and not luminousSignals, title="PULSE SHORT NOW", style=shape.labeldown, location=location.abovebar, color=C_SHORT, textcolor=color.white, text="PULSE\nSHORT", size=size.small)
plotshape(i_showPulseBeacons and exitPulseLong, title="PULSE EXIT LONG", style=shape.xcross, location=location.abovebar, color=color.new(C_WARN, 15), size=size.tiny, text="")
plotshape(i_showPulseBeacons and exitPulseShort, title="PULSE EXIT SHORT", style=shape.xcross, location=location.belowbar, color=color.new(C_WARN, 15), size=size.tiny, text="")

color candleState = firePulseLong or fireCoreLong ? tLong : firePulseShort or fireCoreShort ? tShort : not barGate ? na : microLongArmed ? f_lum(tLong, 42) : microShortArmed ? f_lum(tShort, 42) : na
barcolor(i_colorCandles ? candleState : na)

// Glow underlays (appended after the base plots so saved style overrides keep their slots).
plot(i_glowLines and i_showVwap ? vwapShown : na, "VWAP Glow", color=color.new(C_MAP_CYAN, 88), linewidth=6, style=plot.style_linebr, display=display.pane)
plotshape(luminousSignals and ((i_showPulseBeacons and firePulseLong) or (i_showCoreMarkers and fireCoreLong)), title="FIRE LONG Glyph", style=shape.triangleup, location=location.belowbar, color=f_lum(tLong, 0), size=size.tiny, text="")
plotshape(luminousSignals and ((i_showPulseBeacons and firePulseShort) or (i_showCoreMarkers and fireCoreShort)), title="FIRE SHORT Glyph", style=shape.triangledown, location=location.abovebar, color=f_lum(tShort, 0), size=size.tiny, text="")
plot(i_glowLines and i_showPulseTrail and microVisualActive ? pulseTrail : na, "Pulse Trail Glow", color=f_lum(microSideColor, 86), linewidth=7, style=plot.style_linebr, display=display.pane)

// -------------------------------------------------------------------------------------------------
// SHARED PLAN VALUES FOR THE CURRENT FIRE (read-only view of engine outputs)
// -------------------------------------------------------------------------------------------------
bool newPlan = fireLong or fireShort
bool planLong = fireLong
bool planPulse = firePulseLong or firePulseShort
float drawEntry = planLong ? longEntry : shortEntry
float drawStop = firePulseLong ? microLongStop : firePulseShort ? microShortStop : planLong ? coreLongStop : coreShortStop
float drawTP1 = firePulseLong ? microLongTarget1 : firePulseShort ? microShortTarget1 : planLong ? f_roundTick(longEntry + coreLongRiskPts) : f_roundTick(shortEntry - coreShortRiskPts)
float drawTP2 = firePulseLong ? microLongTarget2 : firePulseShort ? microShortTarget2 : planLong ? coreLongTarget : coreShortTarget
float drawR = firePulseLong ? microLongR2 : firePulseShort ? microShortR2 : planLong ? coreLongR : coreShortR
float drawRisk = firePulseLong ? microLongRiskDollars : firePulseShort ? microShortRiskDollars : planLong ? coreLongRiskDollars : coreShortRiskDollars
string drawName = firePulseLong ? microLongName : firePulseShort ? microShortName : planLong ? coreLongName : coreShortName
int drawScore = firePulseLong ? microLongScore : firePulseShort ? microShortScore : planLong ? coreLongScore : coreShortScore
string labelHead = planPulse ? (planLong ? "PULSE LONG" : "PULSE SHORT") : (planLong ? "LONG NOW" : "SHORT NOW")
string planDossier = f_dossier(labelHead, drawName, drawEntry, drawStop, drawTP1, drawTP2, drawR, drawRisk, drawScore, matrixSide)

// =================================================================================================
// LUMINOUS SIGNAL TAGS — translucent, hover dossier, older tags fade, hard-capped
// =================================================================================================
var array<label> tagLabels = array.new<label>()
var array<color> tagColors = array.new<color>()
bool tagOn = luminousSignals and newPlan and ((planPulse and i_showPulseBeacons) or (not planPulse and i_showCoreMarkers))
if tagOn
    if proSignals
        for oldTag in tagLabels
            label.delete(oldTag)
        array.clear(tagLabels)
        array.clear(tagColors)
    for [i, oldTag] in tagLabels
        color oldColor = array.get(tagColors, i)
        label.set_color(oldTag, f_lum(oldColor, 93))
        label.set_textcolor(oldTag, f_lum(oldColor, 50))
    color tagColor = planLong ? tLong : tShort
    string tagCode = planPulse ? (str.length(drawName) >= 2 ? str.substring(drawName, 0, 2) : "P") : "CORE"
    string tagText = (planLong ? "▲ " : "▼ ") + (planPulse ? "PULSE · " + tagCode : "MATRIX · CORE")
    // The tag sits a little further out so the permanent history glyph stays visible between bar and tag.
    float tagOffset = 0.70
    float tagY = planLong ? low - executionAtr * tagOffset : high + executionAtr * tagOffset
    label newTag = label.new(bar_index, tagY, tagText, xloc=xloc.bar_index, style=planLong ? label.style_label_up : label.style_label_down, color=neonChips ? tagColor : f_lum(tagColor, 76), textcolor=neonChips ? tInk : tagColor, size=size.small, tooltip=planDossier)
    array.push(tagLabels, newTag)
    array.push(tagColors, tagColor)
    if array.size(tagLabels) > i_maxTags
        label.delete(array.shift(tagLabels))
        array.shift(tagColors)

// =================================================================================================
// LATEST PLAN LADDER — ONE PLAN ONLY, NEVER A PILE OF HISTORICAL LEVELS
// Glass Zones: translucent risk / reward zones + compact rung tags; a pulse plan collapses at model exit.
// =================================================================================================
var line planEntryLine = na
var line planStopLine = na
var line planTP1Line = na
var line planTP2Line = na
var label planLabel = na
var box planRiskBox = na
var box planRewardBox = na
var label planTagStop = na
var label planTagTP1 = na
var label planTagTP2 = na
var bool planIsPulse = false
var bool planLive = false
var int planBar = na
var string planHeadText = ""

if i_showPlan and newPlan
    line.delete(planEntryLine)
    line.delete(planStopLine)
    line.delete(planTP1Line)
    line.delete(planTP2Line)
    label.delete(planLabel)
    box.delete(planRiskBox)
    box.delete(planRewardBox)
    label.delete(planTagStop)
    label.delete(planTagTP1)
    label.delete(planTagTP2)
    planIsPulse := planPulse
    planBar := bar_index
    planLive := true
    planHeadText := labelHead
    color planColor = planLong ? tLong : tShort
    int planRight = bar_index + i_planProjection

    if glassPlan
        planRiskBox := box.new(bar_index, math.max(drawEntry, drawStop), planRight, math.min(drawEntry, drawStop), xloc=xloc.bar_index, border_color=f_lum(tShort, 78), border_width=1, bgcolor=f_lum(tShort, 90))
        planRewardBox := box.new(bar_index, math.max(drawEntry, drawTP2), planRight, math.min(drawEntry, drawTP2), xloc=xloc.bar_index, border_color=f_lum(tLong, 80), border_width=1, bgcolor=f_lum(tLong, 91))
        planEntryLine := line.new(bar_index, drawEntry, planRight, drawEntry, xloc=xloc.bar_index, color=f_lum(planColor, 0), width=1)
        planStopLine := line.new(bar_index, drawStop, planRight, drawStop, xloc=xloc.bar_index, color=f_lum(tShort, 15), width=1, style=line.style_dashed)
        planTP1Line := line.new(bar_index, drawTP1, planRight, drawTP1, xloc=xloc.bar_index, color=f_lum(tInfo, 40), width=1, style=line.style_dotted)
        planTP2Line := line.new(bar_index, drawTP2, planRight, drawTP2, xloc=xloc.bar_index, color=f_lum(tInfo, 5), width=1, style=line.style_dotted)
        planLabel := label.new(planRight, drawEntry, (planLong ? "▲ " : "▼ ") + labelHead + "  ·  " + drawName + "  ·  " + f_r(drawR), xloc=xloc.bar_index, style=label.style_label_left, color=f_lum(planColor, 74), textcolor=planColor, size=size.small, tooltip=planDossier)
        planTagStop := label.new(planRight, drawStop, "STOP  " + str.tostring(drawStop, format.mintick) + "  ·  " + f_money(drawRisk), xloc=xloc.bar_index, style=label.style_label_left, color=f_lum(tShort, 88), textcolor=tShort, size=size.tiny)
        planTagTP1 := label.new(planRight, drawTP1, "TP1  " + str.tostring(drawTP1, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=f_lum(tInfo, 90), textcolor=f_lum(tInfo, 20), size=size.tiny)
        planTagTP2 := label.new(planRight, drawTP2, "TP2  " + str.tostring(drawTP2, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=f_lum(tInfo, 86), textcolor=tInfo, size=size.tiny)
    else
        planEntryLine := line.new(x1=bar_index, y1=drawEntry, x2=planRight, y2=drawEntry, xloc=xloc.bar_index, extend=extend.none, color=planColor, width=2)
        planStopLine := line.new(x1=bar_index, y1=drawStop, x2=planRight, y2=drawStop, xloc=xloc.bar_index, extend=extend.none, color=color.new(C_SHORT, 0), width=1, style=line.style_dashed)
        planTP1Line := line.new(x1=bar_index, y1=drawTP1, x2=planRight, y2=drawTP1, xloc=xloc.bar_index, extend=extend.none, color=color.new(C_INFO, 20), width=1, style=line.style_dotted)
        planTP2Line := line.new(x1=bar_index, y1=drawTP2, x2=planRight, y2=drawTP2, xloc=xloc.bar_index, extend=extend.none, color=color.new(C_INFO, 0), width=2, style=line.style_dotted)
        planLabel := label.new(x=planRight, y=drawEntry, xloc=xloc.bar_index, style=label.style_label_left, color=planColor, textcolor=color.black, size=size.small, text=labelHead + "\n" + drawName + " | " + f_r(drawR) + "\nSTOP " + str.tostring(drawStop, format.mintick) + " | TP1 " + str.tostring(drawTP1, format.mintick) + " | TP2 " + str.tostring(drawTP2, format.mintick) + "\nRISK " + f_money(drawRisk))

// Pulse plan collapses to the model-exit bar: the zone now shows the realised ride, not a stale projection.
if i_showPlan and glassPlan and i_planCollapse and planLive and planIsPulse and (exitPulseLong or exitPulseShort)
    box.set_right(planRiskBox, bar_index)
    box.set_right(planRewardBox, bar_index)
    box.set_bgcolor(planRiskBox, f_lum(tShort, 96))
    box.set_bgcolor(planRewardBox, f_lum(tLong, 96))
    box.set_border_color(planRiskBox, f_lum(tShort, 92))
    box.set_border_color(planRewardBox, f_lum(tLong, 92))
    line.set_x2(planEntryLine, bar_index)
    line.set_x2(planStopLine, bar_index)
    line.set_x2(planTP1Line, bar_index)
    line.set_x2(planTP2Line, bar_index)
    line.set_color(planEntryLine, f_lum(tNeutral, 55))
    line.set_color(planStopLine, f_lum(tNeutral, 70))
    line.set_color(planTP1Line, f_lum(tNeutral, 75))
    line.set_color(planTP2Line, f_lum(tNeutral, 70))
    label.delete(planTagStop)
    label.delete(planTagTP1)
    label.delete(planTagTP2)
    label.set_x(planLabel, bar_index)
    label.set_text(planLabel, "◌ " + planHeadText + " · MODEL EXIT")
    label.set_color(planLabel, f_lum(tNeutral, 90))
    label.set_textcolor(planLabel, f_lum(tNeutral, 25))
    label.set_size(planLabel, size.tiny)
    planLive := false

// =================================================================================================
// ARMED TRIGGER RETICLE + AFTERGLOW — the box and trigger line persist for the Afterglow Hold, fading bar by bar.
// On FIRE the reticle "locks" (solid border in the side colour) instead of vanishing.
// Memory records only on barGate (bar close in Confirmed mode), so live and historical bars behave the same.
// =================================================================================================
bool reticleLongNow = microLongArmed or firePulseLong
bool reticleShortNow = microShortArmed or firePulseShort
float trigNow = reticleLongNow ? (p1LongStalk ? microBreakHigh : p2LongStalk ? high[1] : microCompressionHigh) : reticleShortNow ? (p1ShortStalk ? microBreakLow : p2ShortStalk ? low[1] : microCompressionLow) : na
var int retBar = na
var int retFireBar = na
var float retTrig = na
var float retTop = na
var float retBot = na
var bool retLong = false
var string retName = ""
if barGate and (reticleLongNow or reticleShortNow)
    retBar := bar_index
    retTrig := trigNow
    retTop := microBreakHigh
    retBot := microBreakLow
    retLong := reticleLongNow
    retName := reticleLongNow ? microLongName : microShortName
if firePulseLong or firePulseShort
    retFireBar := bar_index
int retAge = na(retBar) ? 9999 : bar_index - retBar
int fireAge = na(retFireBar) ? 9999 : bar_index - retFireBar
bool retShowFired = fireAge <= i_holdBars and not na(retTrig)
bool retShowArmed = not retShowFired and retAge <= i_holdBars and not na(retTrig)
string retCode = str.length(retName) >= 2 ? str.substring(retName, 0, 2) : "P"

var box reticleBox = na
var line reticleLine = na
var label reticleTag = na
if barstate.islast
    box.delete(reticleBox)
    line.delete(reticleLine)
    label.delete(reticleTag)
    if i_showPulseAura and auraReticle and (retShowFired or retShowArmed)
        int age = retShowFired ? fireAge : retAge
        float fade = math.min(60.0, age * 60.0 / i_holdBars)
        color rc = retLong ? tLong : tShort
        color edgeColor = retShowFired ? rc : tWarn
        int leftX = (retShowFired ? retFireBar : retBar) - i_microPulseBars
        reticleBox := box.new(leftX, retTop, bar_index + 2, retBot, xloc=xloc.bar_index, border_color=f_lum(edgeColor, 40 + fade * 0.8), border_width=1, border_style=retShowFired ? line.style_solid : line.style_dashed, bgcolor=f_lum(edgeColor, math.min(98.0, 93.0 + fade / 12.0)))
        reticleLine := line.new(leftX, retTrig, bar_index + 2, retTrig, xloc=xloc.bar_index, color=f_lum(rc, 15 + fade), width=1, style=line.style_dotted)
        if not i_callout
            reticleTag := label.new(bar_index + 2, retTrig, (retShowFired ? "◉ FIRED " : "◎ TRIGGER ") + retCode + (retLong ? " › " : " ‹ ") + str.tostring(retTrig, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=f_lum(rc, 86 + fade / 6), textcolor=f_lum(rc, fade), size=size.tiny, tooltip="A FIRE needs a bar close " + (retLong ? "above" : "below") + " this level with an impulse candle and FIRE score ≥ " + str.tostring(profileFireScore) + ". Necessary, not sufficient.")

// =================================================================================================
// LEVEL TARGET TAGS — right-edge readouts for the session map; a level within 0.5 ATR "locks" (◉)
// =================================================================================================
f_levelTag(array<label> _tags, array<float> _used, float _level, string _name, color _c, float _px, float _atr) =>
    if not na(_level) and not na(_atr)
        bool _clash = false
        for _u in _used
            if math.abs(_u - _level) < _atr * 0.12
                _clash := true
        if not _clash
            bool _near = math.abs(_px - _level) <= _atr * 0.5
            string _txt = (_near ? "◉ " : "") + _name + "  " + str.tostring(_level, format.mintick)
            array.push(_tags, label.new(bar_index + 3, _level, _txt, xloc=xloc.bar_index, style=label.style_label_left, color=f_lum(_c, _near ? 72 : 93), textcolor=f_lum(_c, _near ? 0 : 30), size=size.tiny))
            array.push(_used, _level)

// With the callout on, levels hugging price are voiced by the callout instead of a separate tag.
f_calloutClear(float _level) =>
    i_callout and not na(_level) and math.abs(close - _level) < executionAtr * 0.8 ? na : _level

var array<label> levelTags = array.new<label>()
if barstate.islast
    for oldLevelTag in levelTags
        label.delete(oldLevelTag)
    array.clear(levelTags)
    if i_showTargetTags and i_showSessionMap
        array<float> usedLevels = array.new<float>()
        if i_showVwap
            f_levelTag(levelTags, usedLevels, f_calloutClear(vwapShown), isRth ? "RTH VWAP" : "GLOBEX VWAP", tInfo, close, executionAtr)
        f_levelTag(levelTags, usedLevels, f_calloutClear(f_guard(priorRthHigh)), "PDH", C_MAP_PRIOR, close, executionAtr)
        f_levelTag(levelTags, usedLevels, f_calloutClear(f_guard(priorRthLow)), "PDL", C_MAP_PRIOR, close, executionAtr)
        f_levelTag(levelTags, usedLevels, f_calloutClear(f_guard(visibleOvernightHigh)), "ONH", tNeutral, close, executionAtr)
        f_levelTag(levelTags, usedLevels, f_calloutClear(f_guard(visibleOvernightLow)), "ONL", tNeutral, close, executionAtr)
        f_levelTag(levelTags, usedLevels, f_calloutClear(f_guard(rthOrHigh)), "RTH OR H", tWarn, close, executionAtr)
        f_levelTag(levelTags, usedLevels, f_calloutClear(f_guard(rthOrLow)), "RTH OR L", tWarn, close, executionAtr)
        if i_showEthRange
            f_levelTag(levelTags, usedLevels, f_calloutClear(f_guard(ethOrHigh)), "ETH OR H", tInfo, close, executionAtr)
            f_levelTag(levelTags, usedLevels, f_calloutClear(f_guard(ethOrLow)), "ETH OR L", tInfo, close, executionAtr)

// =================================================================================================
// OPTIONAL LAST-BAR STATUS LABEL
// =================================================================================================
var label statusLabel = na
if barstate.islast
    label.delete(statusLabel)
    if i_showStatusLabel
        float statusY = str.contains(stateText, "SHORT") ? high + executionAtr * 0.55 : low - executionAtr * 0.55
        statusLabel := label.new(x=bar_index, y=statusY, xloc=xloc.bar_index, text=stateText, style=str.contains(stateText, "SHORT") ? label.style_label_down : label.style_label_up, color=f_lum(hudStateColor, 78), textcolor=hudStateColor, size=size.normal)

// =================================================================================================
// ALPHA AGENT HUD — frameless glass. Gloss rules top / bottom, a state-coloured light bar on the left,
// rows fading into the chart. Adaptive Focus collapses to brand + state whenever nothing is actionable.
// Columns: 0 light bar | 1 key | 2-4 value. Merges are re-applied on every update so the layout survives Bar Replay.
// =================================================================================================
string hudText = i_hudSize == "Tiny" ? size.tiny : i_hudSize == "Normal" ? size.normal : size.small
bool hudFull = i_uiMode == "Full Telemetry" and not i_hudMinimized
int footerRow = hudFull ? 15 : 7
int hudLastRow = i_hudMinimized ? 2 : i_showFooter ? footerRow : footerRow - 1
bool hudEvent = fireLong or fireShort or exitPulseLong or exitPulseShort or microLongArmed or microShortArmed or coreLongArmed or coreShortArmed or pulseRideDirection != 0
var int hudLastEventBar = na
if barGate and hudEvent
    hudLastEventBar := bar_index
bool hudLit = not i_hudFocus or (not na(hudLastEventBar) and bar_index - hudLastEventBar <= i_holdBars)
string edgeTag = f_grade(matrixDirectionalScore) + "·" + str.tostring(matrixDirectionalScore)
var table hud = table.new(f_hudPos(i_hudPosition), 5, 18, frame_width=0, border_width=0)

f_hudGlass(int _row) =>
    color.new(tBg, math.min(96, i_hudOpacity + _row * 3))

f_keyGlass(int _row) =>
    color.new(tBgAlt, math.min(96, i_hudOpacity + _row * 3))

f_rule(table _t, int _row, float _transp) =>
    for _c = 0 to 4
        table.cell(_t, _c, _row, "", height=0.3, bgcolor=f_lum(color.from_gradient(_c, 0, 4, tBrand, tBrand2), _transp))

f_cellD(table _t, int _col, int _row, string _txt, color _fg, color _bg, string _size, string _align, string _tip) =>
    f_cell(_t, _col, _row, _txt, _row >= 3 and not hudLit ? f_lum(_fg, 60) : _fg, _bg, _size, _align, _tip)

// Constant brand-colour light bar: state is carried by text colour only, so the panel never flashes.
f_bar(table _t, int _row) =>
    table.cell(_t, 0, _row, "", width=0.25, bgcolor=f_lum(tBrand, math.min(90, 55 + _row * 4)))

if barstate.islast and i_uiMode != "Off"
    bool expanded = not i_hudMinimized
    color sideColor = matrixSide == "LONG" ? tLong : matrixSide == "SHORT" ? tShort : tNeutral
    color headBg = f_hudGlass(1)
    string headTip = i_brandName + " — " + i_brandSub + "\nKRV NQ Execution Matrix — 15m Command → 5m Structure → Execution Matrix → MicroPulse"

    // Row 0 — specular top edge
    f_rule(hud, 0, 25)

    // Row 1 — brand band + mode chip
    f_bar(hud, 1)
    f_cell(hud, 1, 1, brandA, tBrand, headBg, hudText, text.align_left, headTip)
    f_cell(hud, 2, 1, brandB, tBrand2, headBg, hudText, text.align_left, headTip)
    f_cell(hud, 3, 1, "KRV NQ", tMuted, headBg, hudText, text.align_left, headTip)
    f_cell(hud, 4, 1, confirmedMode ? "● CONFIRMED" : "◌ LIVE", confirmedMode ? tLong : tWarn, f_lum(confirmedMode ? tLong : tWarn, 90), size.tiny, text.align_center, confirmedMode ? "Signals only print on a closed bar. HTF values use completed bars." : "Live Bar mode: signals can appear and disappear before the bar closes.")

    // Row 2 — state strip; collapsed view carries the edge grade so nothing important is lost
    f_bar(hud, 2)
    f_cell(hud, 1, 2, "STATE", tMuted, f_keyGlass(2), hudText, text.align_left, "")
    f_cell(hud, 2, 2, expanded ? displayState : displayState + "   " + edgeTag, setupLock ? color.white : hudStateColor, setupLock ? C_ALERT_RED : f_hudGlass(2), hudText, text.align_left, "Action: " + actionText + "\nEdge: " + edgeTag + " · " + matrixSide)

    if expanded
        // Row 3 — alignment lights
        color cmdColor = commandLong ? tLong : commandShort ? tShort : tMuted
        color strColor = structureLong ? tLong : structureShort ? tShort : tMuted
        bool pulseRiding = firePulseLong or firePulseShort or pulseRideDirection != 0
        bool pulseArmed = microLongArmed or microShortArmed
        string pulseGlyph = pulseRiding ? "◉" : pulseArmed ? "◎" : microVisualActive ? "●" : "○"
        color pulseColor = pulseRiding ? (firePulseLong or pulseRideDirection == 1 ? tLong : tShort) : pulseArmed ? tWarn : microVisualActive ? f_lum(microSideColor, 40) : tMuted
        f_bar(hud, 3)
        f_cellD(hud, 1, 3, "ALIGN", tMuted, f_keyGlass(3), hudText, text.align_left, "")
        f_cellD(hud, 2, 3, "15m " + (commandLong ? "▲" : commandShort ? "▼" : "·"), cmdColor, f_hudGlass(3), hudText, text.align_center, commandText + " · score " + str.tostring(commandScore) + " · ER " + str.tostring(cmdER, "#.00"))
        f_cellD(hud, 3, 3, "5m " + (structureLong ? "▲" : structureShort ? "▼" : "·"), strColor, f_hudGlass(3), hudText, text.align_center, structureText + " · score " + str.tostring(structureScore))
        f_cellD(hud, 4, 3, "µP " + pulseGlyph, pulseColor, f_hudGlass(3), hudText, text.align_center, "MicroPulse: ◉ fired / riding · ◎ armed · ● enabled by Matrix · ○ gated off")

        // Row 4 — edge meter
        color meterColor = color.from_gradient(matrixDirectionalScore, 40, 90, tMuted, matrixSide == "NEUTRAL" ? tNeutral : sideColor)
        f_bar(hud, 4)
        f_cellD(hud, 1, 4, "EDGE", tMuted, f_keyGlass(4), hudText, text.align_left, "")
        f_cellD(hud, 2, 4, f_meter(matrixDirectionalScore, 10), meterColor, f_hudGlass(4), hudText, text.align_left, "Matrix directional score " + str.tostring(matrixDirectionalScore) + "/100 · side " + matrixSide)
        f_cellD(hud, 4, 4, edgeTag, f_gradeThemed(matrixDirectionalScore, tLong, tInfo, tWarn, tMuted), f_hudGlass(4), hudText, text.align_center, "Grade: A ≥ 85 · B ≥ 70 · C ≥ 55")

        // Rows 5-6 — action + plan
        string dashboardPlan = activePlanSide == "" ? (matrixSide == "NEUTRAL" ? "BLOCKED — NO DIRECTIONAL EDGE" : "PULSE MODULE STANDBY") : activePlanSide + " | " + activePlanName + " | " + f_r(activePlanR)
        string planTip = activePlanSide == "" ? "No active plan." : "ENTRY " + str.tostring(activePlanEntry, format.mintick) + "\nSTOP " + str.tostring(activePlanStop, format.mintick) + "\nTP1 " + str.tostring(activePlanTP1, format.mintick) + "\nTP2 " + str.tostring(activePlanTP2, format.mintick) + "\nRISK " + f_money(activePlanRiskDollars)
        f_bar(hud, 5)
        f_cellD(hud, 1, 5, "ACTION", tMuted, f_keyGlass(5), hudText, text.align_left, "")
        f_cellD(hud, 2, 5, actionText, hudStateColor, f_hudGlass(5), hudText, text.align_left, "")
        f_bar(hud, 6)
        f_cellD(hud, 1, 6, "PLAN", tMuted, f_keyGlass(6), hudText, text.align_left, "")
        f_cellD(hud, 2, 6, dashboardPlan, activePlanSide == "LONG" ? tLong : activePlanSide == "SHORT" ? tShort : tNeutral, f_hudGlass(6), hudText, text.align_left, planTip)

        if hudFull
            string microText = matrixSide == "LONG" ? "L " + microLongName + " | " + str.tostring(microLongScore) + " | ER " + str.tostring(microER, "#.00") + " | RV " + str.tostring(relativeVolume, "#.00") : matrixSide == "SHORT" ? "S " + microShortName + " | " + str.tostring(microShortScore) + " | ER " + str.tostring(microER, "#.00") + " | RV " + str.tostring(relativeVolume, "#.00") : "DISABLED — MATRIX NEUTRAL"
            string coreText = matrixSide == "LONG" ? coreLongName + " | " + str.tostring(coreLongScore) : matrixSide == "SHORT" ? coreShortName + " | " + str.tostring(coreShortScore) : "—"
            string riskText = activePlanSide == "" ? "NO ACTIVE PLAN" : f_r(activePlanR) + " | " + f_money(activePlanRiskDollars)
            string auctionText = rangeBuilding ? rangeName + " BUILDING" : aboveRangeAccepted ? "ABOVE " + rangeName + " ACCEPTED" : belowRangeAccepted ? "BELOW " + rangeName + " ACCEPTED" : rangeReady ? "INSIDE " + rangeName : isRth ? "RTH MAP ACTIVE" : isEth ? "ETH MAP ACTIVE" : "MAINTENANCE / OFF"
            string guardText = lockReason != "" ? lockReason : "SESSION " + (isRth ? "RTH" : isEth ? "ETH" : "OFF") + " | SIG " + str.tostring(signalsThisSession) + "/" + str.tostring(i_maxSignals) + " | CD " + (cooldownActive ? "ON" : "OFF")
            string rideText = pulseRideDirection == 1 ? "LONG " + str.tostring(rideBarsAfter) + "/" + str.tostring(i_microRideBars) : pulseRideDirection == -1 ? "SHORT " + str.tostring(rideBarsAfter) + "/" + str.tostring(i_microRideBars) : "OFF"
            array<string> fullKeys = array.from("15m", "5m", "MICRO", "CORE", "RISK", "AUCTION", "GUARD", "RIDE")
            array<string> fullVals = array.from(commandText + " | " + str.tostring(commandScore) + " | ER " + str.tostring(cmdER, "#.00"), structureText + " | " + str.tostring(structureScore), microText, coreText, riskText, auctionText, guardText, rideText)
            array<color> fullCols = array.from(f_gradeThemed(commandScore, tLong, tInfo, tWarn, tMuted), f_gradeThemed(structureScore, tLong, tInfo, tWarn, tMuted), matrixSide == "LONG" ? tLong : matrixSide == "SHORT" ? tShort : tNeutral, f_gradeThemed(matrixSide == "LONG" ? coreLongScore : coreShortScore, tLong, tInfo, tWarn, tMuted), activePlanSide == "" ? tNeutral : tInfo, str.contains(auctionText, "ABOVE") ? tLong : str.contains(auctionText, "BELOW") ? tShort : tNeutral, lockReason != "" ? tWarn : tNeutral, pulseRideDirection == 1 ? tLong : pulseRideDirection == -1 ? tShort : tNeutral)
            for k = 0 to 7
                int fr = 7 + k
                f_bar(hud, fr)
                f_cellD(hud, 1, fr, array.get(fullKeys, k), tMuted, f_keyGlass(fr), hudText, text.align_left, "")
                f_cellD(hud, 2, fr, array.get(fullVals, k), array.get(fullCols, k), f_hudGlass(fr), hudText, text.align_left, "")

        if i_showFooter
            string footerText = "— " + i_brandSub + " —  " + (confirmedMode ? "BAR-CLOSE CONFIRMED · HTF LOCKED [1]" : "LIVE MODE · MAY CHANGE INTRABAR")
            f_bar(hud, footerRow)
            table.cell(hud, 1, footerRow, footerText, text_color=f_lum(tBrand, 45), bgcolor=f_hudGlass(footerRow), text_size=size.tiny, text_halign=text.align_center, text_font_family=font.family_monospace)

        // Lower gloss edge
        f_rule(hud, hudLastRow + 1, 60)
    else
        f_rule(hud, 3, 60)

    table.merge_cells(hud, 2, 2, 4, 2)
    if not i_hudMinimized
        table.merge_cells(hud, 2, 4, 3, 4)
        table.merge_cells(hud, 2, 5, 4, 5)
        table.merge_cells(hud, 2, 6, 4, 6)
        if hudFull
            for r = 7 to 14
                table.merge_cells(hud, 2, r, 4, r)
        if i_showFooter
            table.merge_cells(hud, 1, footerRow, 4, footerRow)

// =================================================================================================
// QUANT CLUSTER — glass instrument panel. Derived read-outs only; nothing here feeds the engine.
//   BIAS    net Matrix bias = ((cmdL + strL) − (cmdS + strS)) / 2, range −100…+100, sparkline of last N bars
//   σ·VWAP  (close − active VWAP) / active session σ
//   ER      Kaufman efficiency ratio: 15m command (completed bar) and micro (execution chart)
//   ATR×    15m ATR / its SMA baseline (volatility regime)
//   RVOL    volume / SMA(volume)
//   EXT     (close − kinetic fast EMA) / pulse-trail ATR — how stretched price is from the current
//   $/ATR   one execution ATR in dollars at the configured contract count
//   Δ5      change in net bias over the last 5 bars (edge momentum)
//   KAMA θ  execution KAMA slope in ticks per bar
// =================================================================================================
float netBias = ((commandLongScore + structureLongScore) - (commandShortScore + structureShortScore)) * 0.5
float vwapZ = not warmupActive and not na(activeStd) and activeStd > 0 ? (close - activeVwap) / activeStd : na
float kineticExt = microTrailAtr > 0 ? (close - microFast) / microTrailAtr : na
float kamaSlopeTicks = (executionKama - executionKama[1]) / syminfo.mintick
float dollarsPerAtr = executionAtr * syminfo.pointvalue * i_contracts
float biasDelta = netBias - netBias[5]
string regimeText = cmdEfficiencyOkay and cmdVolOkay ? "TREND · EXPANSION" : cmdEfficiencyOkay ? "TREND · QUIET" : cmdVolOkay ? "ROTATION · VOLATILE" : "COMPRESSION"
color regimeColor = cmdEfficiencyOkay and cmdVolOkay ? tBrand : cmdEfficiencyOkay ? tInfo : cmdVolOkay ? tWarn : tNeutral

f_div(float _v, float _span) =>
    na(_v) ? tMuted : _v >= 0 ? color.from_gradient(_v, 0, _span, tNeutral, tLong) : color.from_gradient(_v, -_span, 0, tShort, tNeutral)

f_signed(float _v, string _fmt) =>
    na(_v) ? "—" : (_v >= 0 ? "+" : "") + str.tostring(_v, _fmt)

f_glass(int _row) =>
    color.new(tBg, math.min(96, i_quantGlass + _row * i_quantFade))

f_qkey(table _t, int _col, int _row, string _txt) =>
    table.cell(_t, _col, _row, _txt, text_color=tMuted, bgcolor=f_glass(_row), text_size=size.tiny, text_halign=text.align_center, text_font_family=font.family_monospace)

f_qval(table _t, int _col, int _row, string _txt, color _fg, string _size, string _tip) =>
    table.cell(_t, _col, _row, _txt, text_color=_fg, bgcolor=f_glass(_row), text_size=_size, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=_tip)

var array<string> sparkGlyphs = array.from("▁", "▂", "▃", "▄", "▅", "▆", "▇", "█")
string quantPosName = i_quantPosition != i_hudPosition ? i_quantPosition : str.contains(i_hudPosition, "Bottom") ? str.replace(i_hudPosition, "Bottom", "Top") : str.contains(i_hudPosition, "Top") ? str.replace(i_hudPosition, "Top", "Bottom") : "Bottom Right"
string quantValSize = i_hudSize == "Normal" ? size.normal : size.small
var table quant = table.new(f_hudPos(quantPosName), 3, 12, frame_width=0, border_width=0)

if barstate.islast and i_showQuant
    // Row 0 — specular top edge: cyan → magenta gloss rule
    table.cell(quant, 0, 0, "", height=0.35, bgcolor=f_lum(tBrand, 30))
    table.cell(quant, 1, 0, "", height=0.35, bgcolor=f_lum(color.from_gradient(50, 0, 100, tBrand, tBrand2), 30))
    table.cell(quant, 2, 0, "", height=0.35, bgcolor=f_lum(tBrand2, 30))

    // Row 1 — title + regime chip
    table.cell(quant, 0, 1, "◇ QUANT", text_color=tBrand, bgcolor=f_glass(1), text_size=size.tiny, text_halign=text.align_left, text_font_family=font.family_monospace, tooltip=i_brandName + " · Quant Cluster — derived read-outs, not signals.")
    table.cell(quant, 1, 1, regimeText, text_color=regimeColor, bgcolor=f_glass(1), text_size=size.tiny, text_halign=text.align_right, text_font_family=font.family_monospace, tooltip="Regime from the 15m engine gates: efficiency (ER ≥ " + str.tostring(i_cmdMinER, "0.00") + ") × volatility (ATR× ≥ " + str.tostring(i_cmdMinAtrRatio, "0.00") + ").")

    // Row 2 — bias sparkline (fixed −100…+100 scale so the shape is comparable across sessions)
    string spark = ""
    for i = i_sparkLen - 1 to 0
        float b = netBias[i]
        spark += na(b) ? " " : array.get(sparkGlyphs, int(math.round(f_clamp((b + 100.0) / 200.0 * 7.0, 0.0, 7.0))))
    table.cell(quant, 0, 2, spark + "  " + f_signed(netBias, "0"), text_color=f_div(netBias, 80), bgcolor=f_glass(2), text_size=hudText, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip="Net Matrix bias, last " + str.tostring(i_sparkLen) + " bars. ▁ = −100 (full short) · ▄▅ = 0 · █ = +100 (full long).")

    // Rows 3-8 — instrument tiles (key row / value row)
    f_qkey(quant, 0, 3, "σ·VWAP")
    f_qkey(quant, 1, 3, "ER 15m")
    f_qkey(quant, 2, 3, "ER µ")
    f_qval(quant, 0, 4, na(vwapZ) ? "—" : f_signed(vwapZ, "0.00") + "σ", f_div(vwapZ, 2.0), quantValSize, "Distance from the active VWAP in session standard deviations.")
    f_qval(quant, 1, 4, str.tostring(cmdER, "0.00"), cmdEfficiencyOkay ? tBrand : tMuted, quantValSize, "15m efficiency ratio (completed bar). Engine gate: ≥ " + str.tostring(i_cmdMinER, "0.00"))
    f_qval(quant, 2, 4, str.tostring(microER, "0.00"), microEfficiencyOkay ? tBrand : tMuted, quantValSize, "Micro efficiency ratio. Profile gate: ≥ " + str.tostring(profileMinER, "0.00"))

    f_qkey(quant, 0, 5, "ATR×")
    f_qkey(quant, 1, 5, "RVOL")
    f_qkey(quant, 2, 5, "EXT·ATR")
    f_qval(quant, 0, 6, str.tostring(cmdAtrRatio, "0.00") + "×", cmdVolOkay ? tBrand : tMuted, quantValSize, "15m ATR vs its baseline. Engine gate: ≥ " + str.tostring(i_cmdMinAtrRatio, "0.00"))
    f_qval(quant, 1, 6, str.tostring(relativeVolume, "0.00") + "×", relativeVolume >= i_volumeExpansion ? tBrand2 : tMuted, quantValSize, "Relative volume. Expansion threshold: " + str.tostring(i_volumeExpansion, "0.00") + "×")
    f_qval(quant, 2, 6, f_signed(kineticExt, "0.00"), math.abs(nz(kineticExt)) > profileChaseATR ? tWarn : f_div(kineticExt, 1.5), quantValSize, "Stretch from the kinetic fast EMA in pulse ATRs. Amber = beyond the chase limit (" + str.tostring(profileChaseATR, "0.00") + ").")

    f_qkey(quant, 0, 7, "$/ATR")
    f_qkey(quant, 1, 7, "Δ5 BIAS")
    f_qkey(quant, 2, 7, "KAMA θ")
    f_qval(quant, 0, 8, f_money(dollarsPerAtr), tNeutral, quantValSize, "One execution ATR (" + str.tostring(executionAtr, format.mintick) + " pts) in dollars at " + str.tostring(i_contracts) + " contract(s).")
    f_qval(quant, 1, 8, f_signed(biasDelta, "0"), f_div(biasDelta, 40), quantValSize, "Change in net bias over 5 bars — is the edge building or fading?")
    f_qval(quant, 2, 8, f_signed(kamaSlopeTicks, "0.0") + "t", f_div(kamaSlopeTicks, 4), quantValSize, "Execution KAMA slope in ticks per bar.")

    // Row 9 — lower gloss rule, magenta → cyan, fainter: the panel dissolves into the chart
    table.cell(quant, 0, 9, "", height=0.25, bgcolor=f_lum(tBrand2, 65))
    table.cell(quant, 1, 9, "", height=0.25, bgcolor=f_lum(color.from_gradient(50, 0, 100, tBrand2, tBrand), 65))
    table.cell(quant, 2, 9, "", height=0.25, bgcolor=f_lum(tBrand, 65))

    table.merge_cells(quant, 1, 1, 2, 1)
    table.merge_cells(quant, 0, 2, 2, 2)

// =================================================================================================
// AGENT CALLOUT — the HUD comes to price. A glass callout rides beside the live candle so state, trigger,
// plan, nearest level and key quant are read without the eye leaving the chart. Corner panels become reference.
// =================================================================================================
var label agentCallout = na
if barstate.islast
    label.delete(agentCallout)
    // The plan's price tags extend to the right of the projection, so the callout waits ~12 more bars before it returns.
    bool planOnScreen = i_showPlan and not na(planBar) and bar_index <= planBar + i_planProjection + 12
    if i_callout and not planOnScreen
        array<float> mapLevels = array.from(activeVwap, priorRthHigh, priorRthLow, visibleOvernightHigh, visibleOvernightLow, rthOrHigh, rthOrLow)
        array<string> mapNames = array.from(isRth ? "RTH VWAP" : "GBX VWAP", "PDH", "PDL", "ONH", "ONL", "OR H", "OR L")
        float nearestDist = na
        int nearestIdx = -1
        for [k, lv] in mapLevels
            if not na(lv)
                float d = math.abs(close - lv)
                if na(nearestDist) or d < nearestDist
                    nearestDist := d
                    nearestIdx := k
        string nearestText = warmupActive or nearestIdx < 0 ? "" : "◈ " + array.get(mapNames, nearestIdx) + " " + str.tostring(array.get(mapLevels, nearestIdx), format.mintick) + " · " + f_signed((array.get(mapLevels, nearestIdx) - close) / math.max(executionAtr, syminfo.mintick), "0.0") + " ATR"

        string line2 = pulseRideDirection != 0 ? "RIDE " + str.tostring(rideBarsAfter) + "/" + str.tostring(i_microRideBars) + " · STOP " + str.tostring(pulseRideStop, format.mintick) + " · TP2 " + str.tostring(pulseRideTP2, format.mintick) : retShowFired ? "◉ FIRED " + retCode + (retLong ? " › " : " ‹ ") + str.tostring(retTrig, format.mintick) + (fireAge > 0 ? " · " + str.tostring(fireAge) + "b ago" : "") : retShowArmed ? "◎ TRIGGER " + retCode + (retLong ? " › " : " ‹ ") + str.tostring(retTrig, format.mintick) + (retAge > 0 ? " · " + str.tostring(retAge) + "b" : "") : activePlanSide != "" ? "PLAN " + activePlanSide + " · " + activePlanName + " · " + f_r(activePlanR) : nearestText
        string line3 = "EDGE " + edgeTag + " · σ " + (na(vwapZ) ? "—" : f_signed(vwapZ, "0.00")) + " · RV " + str.tostring(relativeVolume, "0.00") + "× · ER " + str.tostring(cmdER, "0.00")
        color calloutColor = retShowFired or pulseRideDirection != 0 ? (retLong or pulseRideDirection == 1 ? tLong : tShort) : retShowArmed ? tWarn : hudStateColor
        string calloutTip = retShowFired or pulseRideDirection != 0 ? "Latest pulse plan — hover the signal tag for the full dossier.\n" + nearestText : "Agent Callout — live state at price.\n" + nearestText + "\nRegime: " + regimeText
        agentCallout := label.new(bar_index + i_calloutOffset, close, "▸ " + displayState + "\n" + line2 + "\n" + line3, xloc=xloc.bar_index, style=label.style_label_left, color=f_lum(calloutColor, 86), textcolor=calloutColor, size=size.small, textalign=text.align_left, text_font_family=font.family_monospace, tooltip=calloutTip)

// =================================================================================================
// SETUP WARNING (non-standard chart or wrong timeframe) — bold red banner, top-center. Signals are already disabled by the engine locks (chartTypeLock / executionTfLock);
// this makes sure nobody misreads a silent chart as "no setups".
// =================================================================================================
// Created only when a lock is active: an empty table still draws its frame, which left a stray red dot.
// Chart type and timeframe changes reload the script, so setupLock never changes within a run.
var table warnBanner = na
if barstate.islast and setupLock
    if na(warnBanner)
        warnBanner := table.new(position.top_center, 1, 2, frame_width=2, frame_color=C_ALERT_RED, border_width=0)
    table.cell(warnBanner, 0, 0, chartTypeLock ? "⚠  NON-STANDARD CHART — SIGNALS DISABLED  ⚠" : "⚠  WRONG TIMEFRAME — SIGNALS DISABLED  ⚠", text_color=color.white, bgcolor=C_ALERT_RED, text_size=size.large, text_formatting=text.format_bold, text_font_family=font.family_monospace)
    table.cell(warnBanner, 0, 1, chartTypeLock ? "Switch to standard candles. Heikin-Ashi, Renko, Range and similar chart types distort price and time." : "Switch to a 45s or 1m chart (max " + str.tostring(i_maxExecSeconds) + "s). The 15m / 5m layers are read internally.", text_color=color.white, bgcolor=color.new(C_ALERT_RED, 30), text_size=size.small, text_font_family=font.family_monospace)
````
