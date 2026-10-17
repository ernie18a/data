# Volatility Coil Edge [BullByte]

- url: https://www.tradingview.com/script/rqB1Q4ON-Volatility-Coil-Edge-BullByte/
- type: indicator
- pine_id: PUB;604f0fd1c60d43ee89631524c5da1ed7
- version: 1.0

## Description

[b]Volatility Coil Edge [VCE][/b] is a reversal detection script designed for intraday traders operating in futures, indices, and crypto markets. It identifies a specific and repeatable market condition: price compressing into a tight range at the extreme boundary of a session, then breaking out of that compression in the opposing direction. The compression is the footprint. The break is the trigger. Everything else - entry, stop, and three scaled targets - is calculated automatically from the structure itself.

This script is built from custom logic rather than a simple wrapper of standard indicators. VCE is built from a custom volatility state machine designed specifically for detecting absorption-and-release patterns at session extremes. There is no RSI. No MACD. No Bollinger Band. The logic is derived entirely from price geometry, ATR ratio mathematics, and session range physics.

---

[b]WHAT IS A VOLATILITY COIL[/b]

[b]Price does not move in straight lines. It expands and contracts in cycles[/b]. When price reaches the edge of its established session range and begins contracting - forming smaller and smaller bars with decreasing volatility relative to recent history - it is coiling. This coil represents a temporary equilibrium between buyers and sellers at a structurally significant location.

The coil at a session high means sellers have been absorbing every attempt to push higher. The coil at a session low means buyers have been absorbing every attempt to push lower. When that absorption ends and price breaks through the coil boundary in the reversal direction, it signals that one side may be losing control and the opposite side may begin to take over.

VCE detects this moment and marks it on the close of the break bar. The script combines session-extreme context, multi-condition compression logic, violation tolerance, and post-impulse detection within one unified engine.

---

[b]WHY THIS WORKS AND WHY IT IS ORIGINAL[/b]

Most volatility indicators measure contraction globally across the entire chart. VCE measures contraction locally and contextually - it only cares about compression that forms at the edges of the current session range. A tight range forming in the middle of a session is noise. The same tight range forming at the session high or low is a structural event.

[b]The detection engine uses three simultaneous compression conditions:[/b]

[b]The first is a ratio comparison between a short-period local ATR and a longer-period background ATR[/b]. When the local ATR falls below a calibrated percentage of the background ATR, the bar qualifies as contracted.

[b]The second is a drift-floor condition that catches low-volatility regimes where the ratio test alone would miss genuine compressions.[/b] It compares the current bar range against the rolling median bar range.

[b]The third is Catalyst Mode, which identifies compressions forming immediately after a volatility expansion - the post-impulse coil.[/b] These are often a strong setup type because they represent price stalling after a strong directional move, often marking exhaustion at the extreme.

All three conditions feed a state machine that tracks how many consecutive bars meet the compression criteria, applies violation tolerance so that minor range extensions do not invalidate real coils, and enforces a maximum coil length to prevent stale consolidations from triggering signals.


[image]https://www.tradingview.com/x/6c1mJVrv/[/image]

---

[b]THREE SENSITIVITY TIERS[/b]

[b]Conservative:[/b] Requires the tightest compression and the longest minimum coil duration. Generates fewer signals. Best for traders who prefer higher-filter setups and can wait.

[b]Balanced:[/b] The recommended default. Moderate compression requirements and signal frequency. Suitable for most intraday traders across all supported markets.

[b]Aggressive:[/b] Captures looser compressions and shorter coils. Higher signal frequency. Best for very active scalpers who want early entries and manage risk with tight stops.

All three tiers can be fully overridden with manual parameter control for experienced users who want to calibrate to a specific instrument.

---

[b]CATALYST MODE[/b]

When enabled, Catalyst Mode adds a fourth detection layer. If any of the last five bars showed a range greater than 1.5 times the background ATR, the engine recognizes that a volatility expansion just occurred. Compressions forming immediately after an expansion are flagged even if the ratio test alone would not qualify them. These post-impulse coils frequently mark the confirmed point where momentum stalls and reversal begins.

---

[b]SIGNAL MECHANICS[/b]

This tool provides a systematic framework for identifying the pattern and managing the trade once it fires. A historical bar is exactly what you would have seen in real time on that bar's close.

[b]LONG[/b] signals fire when a qualified compression forms at the session low zone and price closes above the upper boundary of the coil on the break bar.

[b]SHORT[/b] signals fire when a qualified compression forms at the session high zone and price closes below the lower boundary of the coil on the break bar.

---

[b]ENTRY, STOP, AND TARGETS[/b]

Entry is the close price of the signal bar.

The stop loss is placed beyond the structural extreme of the coil - below the coil low for longs, above the coil high for shorts - with an ATR buffer added for breathing room. A minimum stop distance floor prevents dangerously tight stops on very small coils.

The stop distance itself is bounded between an ATR floor and an ATR ceiling so that all three targets remain proportionally realistic regardless of coil size. Targets are then calculated as pure R-multiples of the final bounded stop distance:

[b]TP1[/b] defaults to [b]1.0R[/b] - the point where the trade has covered its own risk.
[b]TP2[/b] defaults to [b]1.5R[/b] - the primary partial profit zone.
[b]TP3[/b] defaults to [b]2.0R[/b] - the full target. Hitting TP3 closes the trade and removes all drawings.

TP1 and TP2 are milestone targets. When hit, a yellow dot marks the price level and the trade remains open. The stop loss and all three target lines remain live until TP3 or the stop is reached.

All R-multiple values are user-adjustable. The stop buffer and minimum distance are also adjustable.

---

[b]VISUAL ELEMENTS[/b]

[b]Signal Card:[/b] A labeled marker appears at every signal bar showing direction (LONG or SHORT), the number of bars in the coil, and the TP2 R-multiple. In Minimalist mode, only the direction is shown. Signal cards are permanent - every historical signal remains visible for review.

[b]Level Lines:[/b] At signal time, five horizontal lines are drawn - entry, stop loss, TP1, TP2, TP3 - each with a floating price label to the right. Lines extend forward bar by bar during the trade and terminate cleanly at the outcome bar.

[b]Coil Box:[/b] While a compression is being watched, a dashed orange box outlines the coil range. The box updates in real time as the coil extends. A small tag shows direction bias and bar count.

[b]Concentric Rings:[/b] Four nested rings are drawn around the signal bar at entry, scaling with ATR. They persist for the duration of the trade as a visual anchor and are removed automatically at outcome.

[b]Milestone Dots:[/b] Yellow dots mark the exact bar and price where TP1 and TP2 are touched during the trade.

[b]Signal Bar Highlight:[/b] The background of the signal bar is tinted green for longs and red for shorts.

---

[b]THE DASHBOARD[/b]

The dashboard panel shows the current state of the engine at a glance. It updates on every bar close.

The header shows the ticker symbol and timeframe so the panel is always self-identifying across multiple open charts.

[b]STATE[/b] shows one of four conditions: [b]IDLE [/b]when no coil is active, [b]FORMING [/b]with a bar count when compression is building but not yet qualified, [b]WATCH LONG[/b] or [b]WATCH SHORT[/b] when a qualified coil is positioned at an extreme and the engine is waiting for a break, and [b]ACTIVE LONG[/b] or [b]ACTIVE SHORT[/b] during a live trade.

[b]COIL[/b] shows the current compression bar count and the local-to-background ATR ratio as a percentage. Lower percentage means tighter compression.

[b]ZONE[/b] shows where the active coil is positioned - session high, session low, or mid-range for forming coils that have not yet reached an extreme.

[b]ENTRY[/b] shows the direction and confirmed entry price of the active trade.

[b]TARGETS[/b] shows three dots - one for each TP level. Dots fill yellow as each milestone is hit during the trade.

---

[b]RECOMMENDED MARKETS AND TIMEFRAMES[/b]

VCE is designed for liquid intraday markets with defined session structure. It performs better on instruments that have clear daily range boundaries and regular volatility patterns.

[b]Recommended markets:[/b] NQ, ES, MNQ, MES futures. BTC, ETH, SOL perpetual futures. Major crypto spot pairs. SPY, QQQ intraday.

[b]Recommended timeframes:[/b] The script performs strongest on the 15 minute timeframe where session structure is cleanest and compression patterns carry the most weight. The 5 minute and 3 minute timeframes are well suited for standard intraday work. The 1 minute timeframe is for aggressive scalping and requires tighter risk management due to higher noise levels.

The Session Range Lookback input should be calibrated to approximately one full session worth of bars on your chosen timeframe. On a 5-minute chart, one RTH session is roughly 78 bars. On a 1-minute chart, approximately 390 bars. The default of 50 is a balanced starting point for 3-minute and 5-minute charts.

On a 15-minute chart one full RTH session is approximately 26 bars; set Session Range Lookback to 26 to 30 for clean session-extreme detection on this timeframe.

---

[b]HOW TO READ A LIVE SETUP (USAGE)[/b]

[b]Step one[/b]: Watch for the dashboard STATE to change from IDLE to FORMING. This means compression is building somewhere on the chart.

[b]Step two:[/b] When STATE changes to WATCH LONG or WATCH SHORT, the coil has qualified and is positioned at a session extreme. The orange coil box becomes visible. The engine is now armed.

[b]Step three: [/b]Do not act on WATCH alone. Wait for the signal card to appear. The signal only fires on bar close when the coil has been broken in the reversal direction. The signal card, level lines, and rings all appear simultaneously at that moment.

[b]Step four:[/b] Entry is the close of the signal bar. Place your stop at the SL line. Your targets are TP1, TP2, and TP3 as shown on the chart.

[b]Step five:[/b] TP1 and TP2 mark themselves with yellow dots as they are hit. The trade closes automatically in the visual display when TP3 or SL is reached, and all lines are removed cleanly.

[b]CHART EXAMPLE[/b]

[b]The Science of Price Coiling : Silver 5m[/b]

Price surged aggressively into the session high zone, driven by strong buying momentum. But at the extreme, buyers ran out of fuel. Over the next 4 bars, the range shrank bar by bar, candles got smaller, volatility dried up, and neither buyers nor sellers could dominate. 

This is the coil: not random sideways movement, but compressed energy at an unstable equilibrium. The longer price holds at an extreme without continuing, the more it signals that the side that drove it there is exhausting. When sellers finally overwhelmed the weakened buyers, price broke below the coil floor in a single decisive bar, releasing all stored tension in one direction. 

That break was not a prediction. It was a consequence. The compression was the warning, the location was the context, and the break was simply the market resolving the imbalance it had been building. This is what VCE detects, not the move itself, but the conditions that make the move inevitable.

[image]https://www.tradingview.com/x/JjNHyClz/[/image]

---

[b]ALERT SETUP[/b]

Two alert conditions are built in:

[b]VCE Long Signal[/b] fires on bar close when a LONG setup triggers.
[b]VCE Short Signal[/b] fires on bar close when a SHORT setup triggers.

[b]To activate[/b]: open the Alerts panel, select Create Alert, choose VCE as the condition source, and select either Long Signal or Short Signal. Set the trigger to Once Per Bar Close. No additional configuration is needed.

---

[b]INPUTS REFERENCE[/b]

[b]Sensitivity:[/b] Conservative, Balanced, or Aggressive preset. Controls compression tightness, minimum coil length, zone threshold, and break definition simultaneously.

[b]Catalyst Mode:[/b] Enables post-impulse coil detection. Recommended ON for all markets.

[b]Use Manual Overrides:[/b] Replaces the sensitivity preset with the four manual parameters below it.

[b]Min Bars:[/b] Minimum consecutive compression bars required before a coil qualifies.

[b]Max Bars:[/b] Maximum coil length before the coil is invalidated and reset.

[b]Contraction Ratio:[/b] Local ATR must be below this fraction of the background ATR to register as a compressed bar.

[b]Extreme Zone Percent:[/b] Defines what fraction of the session range constitutes the high and low extreme zones.

[b]Background ATR Period:[/b] Smoothing period for the volatility baseline used in compression detection.

[b]Session Range Lookback:[/b] Number of bars defining the rolling session high and low.

[b]ATR Period:[/b] Period for the ATR used in stop and target calculations.

[b]Post-Outcome Bar Gap:[/b] Minimum bars of silence after a trade closes before the next signal can fire.

[b]SL Buffer:[/b] ATR multiplier added beyond the coil extreme when calculating the structural stop.

[b]Min SL Distance:[/b] Floor for the stop distance as an ATR multiple. Prevents unrealistically tight stops.

[b]Max SL Distance:[/b] Ceiling for the stop distance as an ATR multiple. Prevents absurdly wide stops on tall coils and keeps all TP levels proportionally realistic for the chosen timeframe.

[b]TP1, TP2, TP3:[/b] Take-profit levels as multiples of the stop distance.

[b]Label Right Offset:[/b] Controls how far to the right floating price labels appear.

[b]Minimalist Signal Card:[/b] Shows only LONG or SHORT on the signal card when enabled.

[b]Show Coil Box:[/b] Toggles the live orange compression box.

[b]Highlight Signal Bar:[/b] Toggles background tinting on signal bars.

[b]Show Concentric Ring Signature:[/b] Toggles the nested ring visual at signal bars.

[b]Show Dashboard:[/b] Toggles the status panel.

[b]Theme:[/b] Dark or Light. Adjusts all label, line, and panel colors for chart background compatibility.

[b]Position:[/b] Sets the dashboard anchor position on the chart.

---

[b]NOTES ON PERFORMANCE AND EXPECTATIONS[/b]

VCE identifies a specific structural pattern. Not every coil produces a sustained reversal. Session context, macro flow, and news events all influence whether a given setup follows through. The tool provides a systematic framework for identifying the pattern and managing the trade once it fires. Risk management decisions remain with the trader.

The post-outcome bar gap input exists to prevent the engine from immediately re-entering after a stopped trade. This is a deliberate design choice, not a limitation.

---

[b]DISCLAIMER[/b]

This script is published for educational and informational purposes only. It is not financial advice and does not constitute a recommendation to buy or sell any financial instrument. Past signal behavior does not guarantee future results. Trading involves significant risk of loss. Always conduct your own research and apply your own risk management framework before making any trading decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BullByte

// ═══════════════════════════════════════════════════════════════════════════
// VCE - Volatility Coil Edge
// ─────────────────────────────────────────────────────────────────────────
// A reversal engine for intraday futures, indices, and crypto.
//
// What it does
// ────────────
// Detects price compression (volatility coiling) at session extremes, then
// enters on the first bar that breaks the coil in the reversal direction.
// Compressions at session highs produce SHORT setups. Compressions at session
// lows produce LONG setups. Targets are R-multiple based for clean,
// comparable risk/reward across every trade.
//
// Why it works
// ────────────
// Tight ranges that form at the edges of a session range often mark
// inflection points. The compression is the footprint, the break is the
// trigger. Stops sit beyond the structure that invalidates the setup;
// targets project in clean R multiples.
//
// Signal confirmation
// ───────────────────
// All signals fire only on bar close. Intrabar conditions are not used to
// fire trades. This makes the script non-repainting on confirmed history
// and only finalizes a live signal when the current bar closes.
// ═══════════════════════════════════════════════════════════════════════════
//
// Disclaimer
// ──────────
// This script is published for educational and informational purposes only.
// It does not constitute financial advice. Past signal performance does not
// guarantee future results. Always apply your own risk management.

//@version=6
indicator(
     title             = "Volatility Coil Edge [BullByte]",
     shorttitle        = "VCE[BullByte]",
     overlay           = true,
     max_lines_count   = 300,
     max_labels_count  = 300,
     max_boxes_count   = 200)


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 1  ·  USER INPUTS
// ═══════════════════════════════════════════════════════════════════════════

// ── Coil Detection ────────────────────────────────────────────────────────
i_sensitivity = input.string(
     defval  = "Balanced",
     title   = "Sensitivity",
     options = ["Conservative", "Balanced", "Aggressive"],
     group   = "Coil Detection",
     tooltip = "Conservative: fewer signals, tight coils only.\n" +
               "Balanced: moderate signal frequency, recommended default.\n" +
               "Aggressive: captures looser coils and more setups.\n\n" +
               "Tier silently overridden if 'Use Manual Overrides' below is enabled.")

i_catalystMode = input.bool(
     defval  = true,
     title   = "Catalyst Mode",
     group   = "Coil Detection",
     tooltip = "When ON, also detects compressions that form immediately after a volatility " +
               "expansion (a recent bar > 1.5x background ATR). These post-impulse coils are " +
               "often missed by ratio-only detection.")

// ── Manual Tuning (overrides preset when toggle is on) ────────────────────
i_useOverrides = input.bool(
     defval  = false,
     title   = "Use Manual Overrides",
     group   = "Manual Tuning",
     tooltip = "When ON, the four parameters below replace the sensitivity preset values. " +
               "When OFF, these inputs are ignored.")

i_compMinBars = input.int(
     defval  = 4,
     title   = "Min Bars",
     minval  = 3,
     maxval  = 10,
     group   = "Manual Tuning",
     tooltip = "Minimum consecutive compression bars before the coil becomes 'qualified' " +
               "and eligible for break-trigger detection.")

i_compMaxBars = input.int(
     defval  = 14,
     title   = "Max Bars",
     minval  = 5,
     maxval  = 20,
     group   = "Manual Tuning",
     tooltip = "Maximum compression length before the coil is invalidated and reset. " +
               "Prevents stale, drifting consolidations from triggering signals.")

i_atrContraction = input.float(
     defval  = 0.82,
     title   = "Contraction Ratio",
     minval  = 0.50,
     maxval  = 0.98,
     step    = 0.02,
     group   = "Manual Tuning",
     tooltip = "Local ATR must be below (this x background ATR) to qualify as a compression bar. " +
               "Lower values = stricter compression requirement.")

i_extremeZone = input.float(
     defval  = 0.35,
     title   = "Extreme Zone %",
     minval  = 0.15,
     maxval  = 0.50,
     step    = 0.05,
     group   = "Manual Tuning",
     tooltip = "Percentage of the rolling session range defining the 'extreme zone'. " +
               "0.35 = top 35% qualifies as session high zone, bottom 35% as session low zone.")

// ── Engine Tuning ─────────────────────────────────────────────────────────
i_bgAtrPeriod = input.int(
     defval  = 20,
     title   = "Background ATR Period",
     minval  = 10,
     maxval  = 50,
     group   = "Engine",
     tooltip = "Period for the background ATR used as the compression baseline. " +
               "Higher = smoother regime detection, lower = more responsive.")

i_sessionLookback = input.int(
     defval  = 50,
     title   = "Session Range Lookback",
     minval  = 20,
     maxval  = 100,
     group   = "Engine",
     tooltip = "Bars used to compute the rolling session high/low that defines the extreme zones. " +
               "Use approximately one full RTH session worth of bars on intraday charts.")

i_atrPeriod = input.int(
     defval  = 14,
     title   = "ATR Period",
     minval  = 5,
     maxval  = 30,
     group   = "Engine",
     tooltip = "ATR period used for SL buffer calculation and visual scaling.")

i_postOutcomeGap = input.int(
     defval  = 8,
     title   = "Post-Outcome Bar Gap",
     minval  = 0,
     maxval  = 10,
     group   = "Engine",
     tooltip = "Minimum bars between a trade closing and the next signal firing. Prevents " +
               "back-to-back signals immediately after an SL or TP3 hit.")

// ── Stop and Targets ──────────────────────────────────────────────────────
i_slBuffer = input.float(
     defval  = 0.20,
     title   = "SL Buffer (x ATR)",
     minval  = 0.10,
     maxval  = 1.50,
     step    = 0.05,
     group   = "Stop & Targets",
     tooltip = "ATR multiplier added beyond the coil extreme to place the structural stop loss. " +
               "Larger = more breathing room, smaller = tighter stop.")

i_slMinDist = input.float(
     defval  = 0.30,
     title   = "Min SL Distance (x ATR)",
     minval  = 0.20,
     maxval  = 2.00,
     step    = 0.05,
     group   = "Stop & Targets",
     tooltip = "Floor for the SL distance from entry. Prevents excessively tight stops on " +
               "very small coils. The actual SL is max(structural distance, this floor).")

i_slMaxDist = input.float(
     defval  = 2.00,
     title   = "Max SL Distance (x ATR)",
     minval  = 1.00,
     maxval  = 5.00,
     step    = 0.25,
     group   = "Stop & Targets",
     tooltip = "Ceiling for the SL distance from entry. Prevents absurdly wide stops on " +
               "tall coils. Keeps all TP levels proportionally realistic for the timeframe.")

i_tp1R = input.float(
     defval  = 1.0,
     title   = "TP1 (R multiple)",
     minval  = 0.50,
     maxval  = 3.00,
     step    = 0.25,
     group   = "Stop & Targets",
     tooltip = "First take-profit target as a multiple of the SL distance.")

i_tp2R = input.float(
     defval  = 1.5,
     title   = "TP2 (R multiple)",
     minval  = 1.00,
     maxval  = 5.00,
     step    = 0.25,
     group   = "Stop & Targets",
     tooltip = "Second take-profit target as a multiple of the SL distance.")

i_tp3R = input.float(
     defval  = 2.0,
     title   = "TP3 (R multiple)",
     minval  = 1.50,
     maxval  = 8.00,
     step    = 0.25,
     group   = "Stop & Targets",
     tooltip = "Final take-profit target as a multiple of the SL distance. Hitting TP3 closes " +
               "the trade and removes all remaining lines and labels.")

i_labelOffset = input.int(
     defval  = 10,
     title   = "Label Right Offset (bars)",
     minval  = 5,
     maxval  = 50,
     group   = "Stop & Targets",
     tooltip = "Number of bars to the right of the current bar where price labels float. " +
               "Lines terminate exactly at the label position - no extension beyond.")

// ── Visuals ───────────────────────────────────────────────────────────────
i_minimalist = input.bool(
     defval  = false,
     title   = "Minimalist Signal Card",
     group   = "Visuals",
     tooltip = "When ON, the signal card shows only LONG/SHORT. When OFF, includes coil bar " +
               "count and target R-multiple.")

i_showCompBox = input.bool(
     defval  = true,
     title   = "Show Coil Box",
     group   = "Visuals",
     tooltip = "Draw the dashed orange box around the active coil while watched.")

i_showBGHighlight = input.bool(
     defval  = true,
     title   = "Highlight Signal Bar",
     group   = "Visuals",
     tooltip = "Tint the background of the bar where a signal fires (green = long, red = short).")

i_showRings = input.bool(
     defval  = true,
     title   = "Show Concentric Ring Signature",
     group   = "Visuals",
     tooltip = "Draw 4 nested rings centered on the signal bar. Persists for the trade " +
               "duration, removed automatically when SL or TP3 hits.")

// ── Dashboard ─────────────────────────────────────────────────────────────
i_showDash = input.bool(
     defval  = true,
     title   = "Show Dashboard",
     group   = "Dashboard")

i_dashTheme = input.string(
     defval  = "Dark",
     title   = "Theme",
     options = ["Dark", "Light"],
     group   = "Dashboard",
     tooltip = "Color theme for dashboard, signal labels, and TP/SL labels. Auto-adjusts text " +
               "and background contrast for readability on both chart backgrounds.")

i_dashPos = input.string(
     defval  = "Top Right",
     title   = "Position",
     options = ["Top Right", "Top Left", "Middle Right", "Bottom Right", "Bottom Left"],
     group   = "Dashboard")


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 2  ·  PARAMETER RESOLUTION
//  Manual overrides take priority. Otherwise the sensitivity preset applies.
// ═══════════════════════════════════════════════════════════════════════════

int    _compMinBars    = 4
int    _compMaxBars    = 14
float  _atrContraction = 0.82
float  _extremeZone    = 0.35
string _touchMode      = "Edge"

if i_useOverrides
    _compMinBars    := i_compMinBars
    _compMaxBars    := i_compMaxBars
    _atrContraction := i_atrContraction
    _extremeZone    := i_extremeZone
    _touchMode      := "Edge"
else if i_sensitivity == "Conservative"
    _compMinBars    := 5
    _compMaxBars    := 12
    _atrContraction := 0.70
    _extremeZone    := 0.25
    _touchMode      := "Full"
else if i_sensitivity == "Balanced"
    _compMinBars    := 4
    _compMaxBars    := 14
    _atrContraction := 0.82
    _extremeZone    := 0.35
    _touchMode      := "Edge"
else
    _compMinBars    := 3
    _compMaxBars    := 16
    _atrContraction := 0.92
    _extremeZone    := 0.45
    _touchMode      := "Mid"


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 3  ·  COLOR PALETTE
//  Theme-aware colors. Text colors auto-pair to background for legibility.
// ═══════════════════════════════════════════════════════════════════════════

bool isDark = i_dashTheme == "Dark"

color c_long       = isDark ? #26A69A : #1A7A70
color c_short      = isDark ? #EF5350 : #C62828
color c_compress   = isDark ? #FFB347 : #CC6600
color c_neutral    = isDark ? #8888AA : #666688
color c_milestone  = isDark ? #FFEB3B : #F57F17

color c_tp1Fill    = isDark ? #B2DFDB : #2E7D62
color c_tp2Fill    = isDark ? #26A69A : #1B5E50
color c_tp3Fill    = isDark ? #00897B : #0E3D34

color c_textOnLight = #1A1A2E
color c_textOnDark  = #FFFFFF
color c_tp1Text     = isDark ? c_textOnLight : c_textOnDark
color c_tp2Text     = isDark ? c_textOnDark  : c_textOnDark
color c_tp3Text     = isDark ? c_textOnDark  : c_textOnDark
color c_entryText   = c_textOnDark
color c_slText      = c_textOnDark

color c_dashBG      = isDark ? color.new(#0F0F1A, 5)   : color.new(#FAFBFC, 5)
color c_dashHeader  = isDark ? color.new(#1A1A2E, 0)   : color.new(#E8ECF2, 0)
color c_dashAccent  = isDark ? color.new(#252545, 0)   : color.new(#D8DFF0, 0)
color c_dashText    = isDark ? #E8EAF6 : #1A1A3E
color c_dashSub     = isDark ? #7C7CA8 : #6B7280
color c_dashBorder  = isDark ? color.new(#2A2A45, 30) : color.new(#D0D5E0, 30)

color c_bgLong      = color.new(c_long,  72)
color c_bgShort     = color.new(c_short, 72)

color c_compFill    = color.new(c_compress, 90)
color c_compBorder  = color.new(c_compress, 30)


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 4  ·  CORE MARKET METRICS
// ═══════════════════════════════════════════════════════════════════════════

float atr        = ta.atr(i_atrPeriod)
float bgAtr      = ta.atr(i_bgAtrPeriod)
float sessionHi  = ta.highest(high, i_sessionLookback)
float sessionLo  = ta.lowest(low,   i_sessionLookback)
float sessionRng = sessionHi - sessionLo


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 5  ·  COIL DETECTION
//  Tracks consecutive compression bars with violation tolerance and an
//  absolute drift-mode floor for low-volatility regimes.
// ═══════════════════════════════════════════════════════════════════════════

var int   compLen        = 0
var float compHigh       = na
var float compLow        = na
var int   compStartBar   = na
var int   compViolations = 0

float localAtr = ta.atr(math.max(_compMinBars, 3))

bool ratioContracted = localAtr < bgAtr * _atrContraction

float medianRng       = ta.percentile_linear_interpolation(high - low, 50, 50)
bool  driftContracted = (high - low) < medianRng * 0.65

bool isContracted = ratioContracted or driftContracted

bool recentExpansion = false
if i_catalystMode
    for k = 1 to 5
        if (high[k] - low[k]) > bgAtr[k] * 1.5
            recentExpansion := true
            break
    isContracted := isContracted or (recentExpansion and localAtr < bgAtr * 1.10)

int   MAX_VIOLATIONS = _touchMode == "Full" ? 1 : _touchMode == "Edge" ? 2 : 3
float tolMult        = _touchMode == "Full" ? 0.30 : _touchMode == "Edge" ? 0.50 : 0.75

if isContracted
    if compLen == 0
        compLen        := 1
        compHigh       := high
        compLow        := low
        compStartBar   := bar_index
        compViolations := 0
    else
        float tol    = bgAtr * tolMult
        bool inRange = high <= compHigh + tol and low >= compLow - tol
        if inRange
            compLen  := compLen + 1
            compHigh := math.max(compHigh, high)
            compLow  := math.min(compLow,  low)
        else
            compViolations := compViolations + 1
            if compViolations <= MAX_VIOLATIONS
                compLen  := compLen + 1
                compHigh := math.max(compHigh, high)
                compLow  := math.min(compLow,  low)
            else
                compLen        := 1
                compHigh       := high
                compLow        := low
                compStartBar   := bar_index
                compViolations := 0
else
    // ── Audit fix 1.1 ─────────────────────────────────────────────────────
    // Previously a near-qualified coil was frozen indefinitely when the bar
    // was non-contracted. Now we only preserve it for one bar of grace (the
    // decrement), then reset cleanly. This prevents ghost coil accumulation.
    if compLen > 0
        compLen := compLen - 1
    if compLen == 0
        compHigh       := na
        compLow        := na
        compStartBar   := na
        compViolations := 0

if compLen > _compMaxBars
    compLen        := 0
    compHigh       := na
    compLow        := na
    compStartBar   := na
    compViolations := 0

bool compQualified = compLen >= _compMinBars

float zoneTop = sessionHi - sessionRng * _extremeZone
float zoneBot = sessionLo + sessionRng * _extremeZone

bool compAtHigh = false
bool compAtLow  = false

if compQualified and not na(compHigh) and not na(compLow)
    float compMid = (compHigh + compLow) / 2.0
    if _touchMode == "Full"
        compAtHigh := compLow  >= zoneTop
        compAtLow  := compHigh <= zoneBot
    else if _touchMode == "Edge"
        compAtHigh := compHigh >= zoneTop
        compAtLow  := compLow  <= zoneBot
    else
        compAtHigh := compHigh >= zoneTop or compMid >= zoneTop or close >= zoneTop
        compAtLow  := compLow  <= zoneBot or compMid <= zoneBot or close <= zoneBot


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 6  ·  WATCHED COIL STATE
// ═══════════════════════════════════════════════════════════════════════════

var bool  watchActive   = false
var bool  watchIsShort  = false
var float watchHigh     = na
var float watchLow      = na
var int   watchLen      = 0
var int   watchEndBar   = na
var int   watchStartBar = na

int WATCH_EXPIRY = _touchMode == "Full" ? 5 : _touchMode == "Edge" ? 10 : 15

if compAtHigh and not watchActive
    watchActive   := true
    watchIsShort  := true
    watchHigh     := compHigh
    watchLow      := compLow
    watchLen      := compLen
    watchEndBar   := na
    watchStartBar := na(compStartBar) ? bar_index - compLen : compStartBar
else if compAtLow and not watchActive
    watchActive   := true
    watchIsShort  := false
    watchHigh     := compHigh
    watchLow      := compLow
    watchLen      := compLen
    watchEndBar   := na
    watchStartBar := na(compStartBar) ? bar_index - compLen : compStartBar

if watchActive and compQualified
    if watchIsShort and compAtHigh
        watchHigh := math.max(watchHigh, compHigh)
        watchLow  := math.min(watchLow,  compLow)
        watchLen  := compLen
    else if not watchIsShort and compAtLow
        watchHigh := math.max(watchHigh, compHigh)
        watchLow  := math.min(watchLow,  compLow)
        watchLen  := compLen

if watchActive and not compQualified and na(watchEndBar)
    watchEndBar := bar_index

if watchActive and not na(watchEndBar) and (bar_index - watchEndBar) > WATCH_EXPIRY
    watchActive   := false
    watchHigh     := na
    watchLow      := na
    watchLen      := 0
    watchEndBar   := na
    watchStartBar := na


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 7  ·  TRIGGER DETECTION
//  Bar-close confirmed via barstate.isconfirmed gate. The break style
//  varies by sensitivity tier.
// ═══════════════════════════════════════════════════════════════════════════

var int lastOutcomeBar = -100
bool gateOK = (bar_index - lastOutcomeBar) > i_postOutcomeGap

// All break conditions reference confirmed bar values only. The barstate.isconfirmed
// gate ensures high/low/close/open used below are final, settled values.
// This script does not repaint: no lookahead, no security() calls,
// no request.* functions, no future bar referencing.

bool shortBreak = false
bool longBreak  = false

if _touchMode == "Full"
    shortBreak := close < watchLow
    longBreak  := close > watchHigh
else if _touchMode == "Edge"
    shortBreak := close < watchLow  or (low  < watchLow  and close < open and (open  - close) > (high - low) * 0.40)
    longBreak  := close > watchHigh or (high > watchHigh and close > open and (close - open ) > (high - low) * 0.40)
else
    shortBreak := close < watchLow  or low  < watchLow  - bgAtr * 0.05
    longBreak  := close > watchHigh or high > watchHigh + bgAtr * 0.05

bool shortTrigger = barstate.isconfirmed and watchActive and watchIsShort     and shortBreak and gateOK
bool longTrigger  = barstate.isconfirmed and watchActive and not watchIsShort and longBreak  and gateOK


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 8  ·  TRADE STATE
// ═══════════════════════════════════════════════════════════════════════════

var bool  tradeActive    = false
var bool  isLong         = false
var float entryPrice     = 0.0
var float slPrice        = 0.0
var float tp1Price       = 0.0
var float tp2Price       = 0.0
var float tp3Price       = 0.0
var int   compLenAtEntry = 0
var int   entryBar       = 0
var bool  tp1Hit         = false
var bool  tp2Hit         = false


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 9  ·  STOP AND TARGET CALCULATION
//  SL is the larger of (structural distance from coil) or (minimum ATR floor).
//  TP1/TP2/TP3 are pure R-multiples of the final SL distance.
// ═══════════════════════════════════════════════════════════════════════════

calcLevels(bool longTrade, float entryPx, float compHi, float compLo) =>
    float buffer    = atr * i_slBuffer
    float minDist   = atr * i_slMinDist
    float maxDist   = atr * i_slMaxDist
    float rawSL     = longTrade ? compLo - buffer : compHi + buffer
    float rawDist   = math.abs(entryPx - rawSL)
    float finalDist = math.max(minDist, math.min(rawDist, maxDist))
    float sl        = longTrade ? entryPx - finalDist : entryPx + finalDist
    float t1        = longTrade ? entryPx + finalDist * i_tp1R : entryPx - finalDist * i_tp1R
    float t2        = longTrade ? entryPx + finalDist * i_tp2R : entryPx - finalDist * i_tp2R
    float t3        = longTrade ? entryPx + finalDist * i_tp3R : entryPx - finalDist * i_tp3R
    [sl, t1, t2, t3, finalDist]


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 10  ·  PERSISTENT DRAWING OBJECTS
// ═══════════════════════════════════════════════════════════════════════════

var line  lineEntry = na
var line  lineSL    = na
var line  lineTP1   = na
var line  lineTP2   = na
var line  lineTP3   = na
var label lblEntry  = na
var label lblSL     = na
var label lblTP1    = na
var label lblTP2    = na
var label lblTP3    = na
var box   compBoxActive  = na
var label compBoxTag     = na

// ── Signal card history array ─────────────────────────────────────────────
// Each fired signal appends a new label. Historical cards are never deleted,
// so every LONG/SHORT appears permanently on the chart for review.
var array<label> signalCardHistory = array.new<label>()

var array<label> milestoneDots = array.new<label>()
var array<box>   ringBoxes     = array.new<box>()


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 11  ·  DRAWING UTILITIES
// ═══════════════════════════════════════════════════════════════════════════

closeLineAt(line ln, int barIdx) =>
    if not na(ln)
        line.set_extend(ln, extend.none)
        line.set_x2(ln, barIdx)

deleteLabel(label lb) =>
    if not na(lb)
        label.delete(lb)

clearRings() =>
    if array.size(ringBoxes) > 0
        for i = 0 to array.size(ringBoxes) - 1
            box.delete(array.get(ringBoxes, i))
        array.clear(ringBoxes)

clearMilestones() =>
    if array.size(milestoneDots) > 0
        for i = 0 to array.size(milestoneDots) - 1
            label.delete(array.get(milestoneDots, i))
        array.clear(milestoneDots)

createRings(bool longTrade, float pivotPx, float scaleY) =>
    clearRings()
    color rCol = longTrade ? c_long : c_short
    int   numRings = 4
    for i = 1 to numRings
        float halfH    = scaleY * (i * 0.45)
        int   halfW    = i
        int   transp   = 60 + i * 8
        int   bgTransp = 92 + i
        box ring = box.new(
             left         = bar_index - halfW,
             top          = pivotPx + halfH,
             right        = bar_index + halfW,
             bottom       = pivotPx - halfH,
             border_color = color.new(rCol, transp),
             border_width = 1,
             bgcolor      = color.new(rCol, math.min(95, bgTransp)))
        array.push(ringBoxes, ring)

drawLevels(bool longTrade, int barIdx, float entryPx, float slPx, float t1, float t2, float t3) =>
    color  entryCol = longTrade ? c_long : c_short
    string dir      = longTrade ? "LONG" : "SHORT"
    float  slDist   = math.abs(entryPx - slPx)
    int    labelX   = barIdx + i_labelOffset

    line _le = line.new(barIdx, entryPx, labelX, entryPx, color = entryCol, width = 1, style = line.style_dashed)
    line _ls = line.new(barIdx, slPx,    labelX, slPx,    color = c_short,  width = 1, style = line.style_solid)
    line _l1 = line.new(barIdx, t1,      labelX, t1,      color = c_tp1Fill,width = 1, style = line.style_solid)
    line _l2 = line.new(barIdx, t2,      labelX, t2,      color = c_tp2Fill,width = 1, style = line.style_solid)
    line _l3 = line.new(barIdx, t3,      labelX, t3,      color = c_tp3Fill,width = 2, style = line.style_solid)

    float rr1 = slDist > 0 ? math.round(math.abs(t1 - entryPx) / slDist, 1) : 0.0
    float rr2 = slDist > 0 ? math.round(math.abs(t2 - entryPx) / slDist, 1) : 0.0
    float rr3 = slDist > 0 ? math.round(math.abs(t3 - entryPx) / slDist, 1) : 0.0

    label _be = label.new(labelX, entryPx,
         text      = dir + "  " + str.tostring(entryPx, format.mintick),
         color     = color.new(entryCol, 70),
         textcolor = c_entryText,
         style     = label.style_label_left,
         size      = size.small)

    label _bs = label.new(labelX, slPx,
         text      = "SL  " + str.tostring(slPx, format.mintick),
         color     = color.new(c_short, 75),
         textcolor = c_slText,
         style     = label.style_label_left,
         size      = size.small)

    label _b1 = label.new(labelX, t1,
         text      = "TP1  " + str.tostring(t1, format.mintick) + "  ·  " + str.tostring(rr1, "#.#") + "R",
         color     = color.new(c_tp1Fill, 25),
         textcolor = c_tp1Text,
         style     = label.style_label_left,
         size      = size.small)

    label _b2 = label.new(labelX, t2,
         text      = "TP2  " + str.tostring(t2, format.mintick) + "  ·  " + str.tostring(rr2, "#.#") + "R",
         color     = color.new(c_tp2Fill, 25),
         textcolor = c_tp2Text,
         style     = label.style_label_left,
         size      = size.small)

    label _b3 = label.new(labelX, t3,
         text      = "TP3  " + str.tostring(t3, format.mintick) + "  ·  " + str.tostring(rr3, "#.#") + "R",
         color     = color.new(c_tp3Fill, 25),
         textcolor = c_tp3Text,
         style     = label.style_label_left,
         size      = size.small)

    [_le, _ls, _l1, _l2, _l3, _be, _bs, _b1, _b2, _b3]

// ── Signal card draw — appends to history, never deletes past cards ────────
drawSignalCard(bool longTrade, int barIdx, float anchorY, int compBars, float rr2) =>
    color  cardCol = longTrade ? c_long : c_short
    string dir     = longTrade ? "LONG" : "SHORT"
    string txt     = i_minimalist ? dir : dir + "\n────\n" + str.tostring(compBars) + "b coil\n" + str.tostring(rr2, "#.#") + "R"
    label _card = label.new(barIdx, anchorY,
         text             = txt,
         color            = cardCol,
         textcolor        = c_textOnDark,
         style            = longTrade ? label.style_label_up : label.style_label_down,
         size             = size.normal,
         text_font_family = font.family_monospace)
    // Push to history — this label is never deleted; it persists on chart
    array.push(signalCardHistory, _card)
    _card


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 12  ·  COIL BOX RENDERING
// ═══════════════════════════════════════════════════════════════════════════

if i_showCompBox and watchActive and not na(watchHigh) and not na(watchLow)
    if not na(compBoxActive)
        box.delete(compBoxActive)
    if not na(compBoxTag)
        label.delete(compBoxTag)

    int boxStart = na(watchStartBar) ? bar_index - watchLen : watchStartBar
    int boxEnd   = bar_index

    compBoxActive := box.new(
         left         = boxStart,
         top          = watchHigh,
         right        = boxEnd,
         bottom       = watchLow,
         border_color = c_compBorder,
         bgcolor      = c_compFill,
         border_width = 1,
         border_style = line.style_dashed)

    string tagTxt = (watchIsShort ? "▼ COIL " : "▲ COIL ") + str.tostring(watchLen) + "b"
    compBoxTag := label.new(boxEnd, watchIsShort ? watchHigh : watchLow,
         text      = tagTxt,
         color     = color.new(c_compress, 30),
         textcolor = c_textOnDark,
         style     = watchIsShort ? label.style_label_down : label.style_label_up,
         size      = size.tiny)

else if not watchActive
    if not na(compBoxActive)
        box.delete(compBoxActive)
        compBoxActive := na
    if not na(compBoxTag)
        label.delete(compBoxTag)
        compBoxTag := na


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 13  ·  SIGNAL EXECUTION
//  Both fire conditions are gated on barstate.isconfirmed via the trigger
//  variables. Signal card is appended to history — prior cards are preserved.
// ═══════════════════════════════════════════════════════════════════════════

bool fireLong  = longTrigger  and not tradeActive
bool fireShort = shortTrigger and not tradeActive

if fireLong
    tradeActive    := true
    isLong         := true
    entryPrice     := close
    entryBar       := bar_index
    tp1Hit         := false
    tp2Hit         := false
    compLenAtEntry := watchLen

    [_sl, _t1, _t2, _t3, _dist] = calcLevels(true, close, watchHigh, watchLow)
    slPrice  := _sl
    tp1Price := _t1
    tp2Price := _t2
    tp3Price := _t3

    [_le, _ls, _l1, _l2, _l3, _be, _bs, _b1, _b2, _b3] = drawLevels(true, bar_index, entryPrice, slPrice, tp1Price, tp2Price, tp3Price)
    lineEntry := _le
    lineSL    := _ls
    lineTP1   := _l1
    lineTP2   := _l2
    lineTP3   := _l3
    lblEntry  := _be
    lblSL     := _bs
    lblTP1    := _b1
    lblTP2    := _b2
    lblTP3    := _b3

    // Append new card to history — does not touch any prior card
    drawSignalCard(true, bar_index, low - atr * 1.2, compLenAtEntry, i_tp2R)
    if i_showRings
        createRings(true, close, atr)
    watchActive := false

if fireShort
    tradeActive    := true
    isLong         := false
    entryPrice     := close
    entryBar       := bar_index
    tp1Hit         := false
    tp2Hit         := false
    compLenAtEntry := watchLen

    [_sl, _t1, _t2, _t3, _dist] = calcLevels(false, close, watchHigh, watchLow)
    slPrice  := _sl
    tp1Price := _t1
    tp2Price := _t2
    tp3Price := _t3

    [_le, _ls, _l1, _l2, _l3, _be, _bs, _b1, _b2, _b3] = drawLevels(false, bar_index, entryPrice, slPrice, tp1Price, tp2Price, tp3Price)
    lineEntry := _le
    lineSL    := _ls
    lineTP1   := _l1
    lineTP2   := _l2
    lineTP3   := _l3
    lblEntry  := _be
    lblSL     := _bs
    lblTP1    := _b1
    lblTP2    := _b2
    lblTP3    := _b3

    // Append new card to history — does not touch any prior card
    drawSignalCard(false, bar_index, high + atr * 1.2, compLenAtEntry, i_tp2R)
    if i_showRings
        createRings(false, close, atr)
    watchActive := false

color signalBG = i_showBGHighlight ? fireLong ? c_bgLong : fireShort ? c_bgShort : na : na
bgcolor(signalBG, title = "Signal Bar BG")


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 14  ·  LIVE TRADE LINE EXTENSION
//  Lines and labels move forward each bar so they stay at the leading edge.
// ═══════════════════════════════════════════════════════════════════════════

if tradeActive
    int newLabelX = bar_index + i_labelOffset
    if not na(lineEntry)
        line.set_x2(lineEntry, newLabelX)
    if not na(lineSL)
        line.set_x2(lineSL, newLabelX)
    if not na(lineTP1)
        line.set_x2(lineTP1, newLabelX)
    if not na(lineTP2)
        line.set_x2(lineTP2, newLabelX)
    if not na(lineTP3)
        line.set_x2(lineTP3, newLabelX)
    if not na(lblEntry)
        label.set_x(lblEntry, newLabelX)
    if not na(lblSL)
        label.set_x(lblSL, newLabelX)
    if not na(lblTP1)
        label.set_x(lblTP1, newLabelX)
    if not na(lblTP2)
        label.set_x(lblTP2, newLabelX)
    if not na(lblTP3)
        label.set_x(lblTP3, newLabelX)


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 15  ·  OUTCOME TRACKING
//  TP1 and TP2 are milestones — only a small dot marks the hit, the trade
//  remains active. SL or TP3 are terminal — the trade closes and all lines
//  truncate at the outcome bar with all labels and milestone dots removed.
//  Outcomes are only checked on bars after entry to avoid same-bar exit.
//  If SL and TP3 are both touched on the same bar, SL takes priority (risk
//  management principle: worst-case outcome governs).
// ═══════════════════════════════════════════════════════════════════════════

if tradeActive and bar_index > entryBar
    bool tp1Touched = not tp1Hit and (isLong ? high >= tp1Price : low <= tp1Price)
    if tp1Touched
        tp1Hit := true
        label dot1 = label.new(bar_index, tp1Price,
             text      = "●",
             color     = color.new(chart.bg_color, 100),
             textcolor = c_milestone,
             style     = label.style_none,
             size      = size.small)
        array.push(milestoneDots, dot1)

    bool tp2Touched = not tp2Hit and (isLong ? high >= tp2Price : low <= tp2Price)
    if tp2Touched
        tp2Hit := true
        label dot2 = label.new(bar_index, tp2Price,
             text      = "●",
             color     = color.new(chart.bg_color, 100),
             textcolor = c_milestone,
             style     = label.style_none,
             size      = size.small)
        array.push(milestoneDots, dot2)

    bool tp3Touched = isLong ? high >= tp3Price : low <= tp3Price
    bool slTouched  = isLong ? low  <= slPrice  : high >= slPrice

    if slTouched
        tradeActive    := false
        lastOutcomeBar := bar_index
        closeLineAt(lineEntry, bar_index)
        closeLineAt(lineSL,    bar_index)
        closeLineAt(lineTP1,   bar_index)
        closeLineAt(lineTP2,   bar_index)
        closeLineAt(lineTP3,   bar_index)
        deleteLabel(lblEntry)
        deleteLabel(lblSL)
        deleteLabel(lblTP1)
        deleteLabel(lblTP2)
        deleteLabel(lblTP3)
        lblEntry := na
        lblSL    := na
        lblTP1   := na
        lblTP2   := na
        lblTP3   := na
        clearRings()
        clearMilestones()

    else if tp3Touched
        tradeActive    := false
        lastOutcomeBar := bar_index
        closeLineAt(lineEntry, bar_index)
        closeLineAt(lineSL,    bar_index)
        closeLineAt(lineTP1,   bar_index)
        closeLineAt(lineTP2,   bar_index)
        closeLineAt(lineTP3,   bar_index)
        deleteLabel(lblEntry)
        deleteLabel(lblSL)
        deleteLabel(lblTP1)
        deleteLabel(lblTP2)
        deleteLabel(lblTP3)
        lblEntry := na
        lblSL    := na
        lblTP1   := na
        lblTP2   := na
        lblTP3   := na
        clearRings()
        clearMilestones()


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 16  ·  DASHBOARD
//  Table is created once at script load. On each last-bar update only the
//  cell contents are refreshed — no object churn.
//
//  Header row: ticker + timeframe instead of hardcoded "VCE" string.
//  This lets a trader instantly identify which instrument and resolution
//  the panel belongs to when multiple charts are open side by side.
// ═══════════════════════════════════════════════════════════════════════════

position_lookup(string p) =>
    p == "Top Right"     ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Middle Right" ? position.middle_right :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Left"  ? position.bottom_left  : position.top_right

var table dash = table.new(
     position     = position_lookup(i_dashPos),
     columns      = 3,
     rows         = 8,
     border_width = 0,
     frame_color  = c_dashBorder,
     frame_width  = 1)

string stateLabel = "IDLE"
color  stateCol   = c_neutral
string stateDot   = "○"
if tradeActive
    stateLabel := isLong ? "ACTIVE LONG" : "ACTIVE SHORT"
    stateCol   := isLong ? c_long : c_short
    stateDot   := "●"
else if watchActive
    stateLabel := watchIsShort ? "WATCH SHORT" : "WATCH LONG"
    stateCol   := c_compress
    stateDot   := "◉"
else if compLen > 0
    stateLabel := "FORMING " + str.tostring(compLen) + "b"
    stateCol   := c_neutral
    stateDot   := "◌"

string tpDots = "○○○"
if tradeActive
    string d1 = tp1Hit ? "●" : "○"
    string d2 = tp2Hit ? "●" : "○"
    tpDots := d1 + d2 + "○"

// ── Ticker + timeframe string for dashboard header ─────────────────────────
// timeframe.period returns the raw period string ("1", "5", "D", etc.).
// We suffix with "m" only for intraday minute-based periods so the display
// reads naturally: "BTCUSDT  1m", "NQ1!  15m", "ETHUSDT  1D".
string tfRaw      = timeframe.period
bool   isMins     = timeframe.isintraday and not timeframe.isseconds
string tfDisplay  = isMins ? tfRaw + "m" : tfRaw
string headerText = "  VCE  [" + syminfo.ticker + "  " + tfDisplay + "]"

if barstate.islast and i_showDash
    table.cell(dash, 0, 0, headerText,  text_color = c_dashText, bgcolor = c_dashHeader, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, "",           bgcolor = c_dashHeader)
    table.cell(dash, 2, 0, stateDot + "  ", text_color = stateCol, bgcolor = c_dashHeader, text_size = size.large, text_halign = text.align_right)

    table.cell(dash, 0, 1, "", bgcolor = stateCol, height = 1)
    table.cell(dash, 1, 1, "", bgcolor = stateCol, height = 1)
    table.cell(dash, 2, 1, "", bgcolor = stateCol, height = 1)

    table.cell(dash, 0, 2, "  STATE", text_color = c_dashSub, bgcolor = c_dashBG, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, "",         bgcolor = c_dashBG)
    table.cell(dash, 2, 2, stateLabel + "  ", text_color = stateCol, bgcolor = c_dashBG, text_size = size.small, text_halign = text.align_right)

    float volRatio = bgAtr > 0 ? localAtr / bgAtr : 1.0
    string coilTxt = compLen > 0 ? str.tostring(compLen) + "b · " + str.tostring(math.round(volRatio * 100, 0)) + "%" : "-"
    table.cell(dash, 0, 3, "  COIL", text_color = c_dashSub, bgcolor = c_dashBG, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, "",       bgcolor = c_dashBG)
    table.cell(dash, 2, 3, coilTxt + "  ", text_color = c_dashText, bgcolor = c_dashBG, text_size = size.small, text_halign = text.align_right)

    string zoneTxt = "-"
    if watchActive
        zoneTxt := watchIsShort ? "session high" : "session low"
    else if compQualified
        zoneTxt := "mid-range"
    table.cell(dash, 0, 4, "  ZONE", text_color = c_dashSub, bgcolor = c_dashBG, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, "",       bgcolor = c_dashBG)
    table.cell(dash, 2, 4, zoneTxt + "  ", text_color = c_dashText, bgcolor = c_dashBG, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 5, "", bgcolor = c_dashAccent, height = 1)
    table.cell(dash, 1, 5, "", bgcolor = c_dashAccent, height = 1)
    table.cell(dash, 2, 5, "", bgcolor = c_dashAccent, height = 1)

    string entryTxt = "-"
    color  entryCol = c_dashSub
    if tradeActive
        entryTxt := (isLong ? "L @ " : "S @ ") + str.tostring(entryPrice, format.mintick)
        entryCol := isLong ? c_long : c_short
    table.cell(dash, 0, 6, "  ENTRY", text_color = c_dashSub, bgcolor = c_dashBG, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 6, "",         bgcolor = c_dashBG)
    table.cell(dash, 2, 6, entryTxt + "  ", text_color = entryCol, bgcolor = c_dashBG, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 7, "  TARGETS", text_color = c_dashSub, bgcolor = c_dashHeader, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 7, "",           bgcolor = c_dashHeader)
    table.cell(dash, 2, 7, tpDots + "  ", text_color = tradeActive ? c_milestone : c_dashSub, bgcolor = c_dashHeader, text_size = size.normal, text_halign = text.align_right)


// ═══════════════════════════════════════════════════════════════════════════
//  SECTION 17  ·  DATA WINDOW AND ALERTS
// ═══════════════════════════════════════════════════════════════════════════

plot(localAtr, "Local ATR",      color = c_compress, display = display.data_window)
plot(bgAtr,    "Background ATR", color = c_neutral,  display = display.data_window)
plot(compLen,  "Coil Bars",      color = c_compress, display = display.data_window)

alertcondition(fireLong,  "VCE Long Signal",  "VCE: LONG | session-low coil broke up")
alertcondition(fireShort, "VCE Short Signal", "VCE: SHORT | session-high coil broke down")
````
