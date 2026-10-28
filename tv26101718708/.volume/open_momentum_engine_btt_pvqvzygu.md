# Open Momentum Engine [BTT]

- url: https://www.tradingview.com/script/pvqvZYgU-Open-Momentum-Engine-BTT/
- type: indicator
- pine_id: PUB;6bdcb5faf0554d9c9d93a13c14508078
- version: 2.0

## Description

Open Momentum Engine [BTT]: Institutional ORB & Gap Scanner

The first two hours of the US Equities session dictate the day. The Open Momentum Engine (OME) is a strict, long-only momentum framework built specifically to capture high-probability Opening Range Breakouts (ORB) and Gap-and-Go setups.

Instead of relying on basic moving average crosses, OME builds an internal "State Machine" that tracks institutional liquidity levels from the prior day's close straight through the pre-market, waiting for the perfect alignment of volume, trend, and price action at the open.
It is highly optimized, ultra-fast, and designed from the ground up to be 100% native to the TradingView Pine Screener.

⚙️ THE ENGINE (Key Features)
   
[list]
[*]Zero-Lag Session Memory: OME v4 tracks the Previous RTH Close, After-Hours (16:00–20:00), Full Pre-Market (04:00–09:30), and the "Power Window" (09:00–09:30 ET) internally without using slow request.security() calls.
[*]    Setup Scoring System: Not all breakouts are equal. The engine constantly grades the setup on a 9-point scale (A+, A, B, C) based on 8 technical criteria plus a Tier-A Gap bonus.
[*]    Dual Entry System: * Primary Signal: The initial breakout above the ORB High with volume + VWAP confirmation.
[*]        Re-Test Signal: A secondary entry that fires if the price pulls back, touches the ORB High, and bounces back up with bullish momentum.
[*]    ATR Risk Framework: Dynamically plots a structural Stop Loss (anchored to the ORB Low with an ATR volatility cushion) and automatic Target 1 & Target 2 levels.
[*]    Live HUD Dashboard: A clean, non-intrusive panel in the top right showing live Gap %, Volume Surge Multiplier, RSI, and your Setup Grade.
[/list]

📈 RECOMMENDED SETTINGS & TIMEFRAMES
[list]
[*]Asset Class: US Equities strictly (time math is hardcoded to Eastern Time).
[*]Chart Timeframe: 5-Minute Chart. This provides the cleanest data for the ORB calculation while keeping entries tight. (1-minute is too noisy; 15-minute delays the entry signal).
[*]ORB Duration: 15 Minutes (Default). This allows the initial 09:30 ET chaos to settle and institutional direction to reveal itself.
[/list]
Extended Hours: ⚠️ CRITICAL: You must have the "EXT" (Extended Hours) button toggled ON at the bottom right of your TradingView chart. If EXT is off, the engine cannot see the pre-market data to draw your launchpad levels!

🛠️ PINE SCREENER (How to Scan)

OME outputs its first 10 data points specifically formatted for the Pine Screener. Here is how to build the ultimate morning momentum scanner:

Step 1: Set up the Screener
[list]
[*]Open the Pine Screener tab at the bottom of TradingView.
[*]Click the Column Setup icon (the three little columns) -> Search for Open Momentum Engine v4.
[*]Add these specific columns to your layout: ▶ Long Signal, ▶ Re-Test Signal, ▶ Setup Score, and ▶ Gap %.
[/list]

Step 2: Apply the Filters
[list]
[*]To catch stocks breaking out right now, set up these filters:
[*]▶ Long Signal Equal to 1 (Catches immediate primary breakouts)
— OR —
[*]▶ Re-Test Signal Equal to 1 (Catches pullbacks bouncing off the ORB High)
[*]Average Volume (30) Greater than 1M (Filters out illiquid penny stocks)
[*]Price Greater than 5 (Filters out micro-caps)
[/list]

Step 3: Sort by Quality
[list]
[*]Click the ▶ Setup Score column header to sort High to Low.
[*]Focus only on setups scoring 8 or 9 (A+). These are stocks gapping up, clearing pre-market resistance, holding above VWAP, surging in volume, and crossing the ORB High simultaneously.
[/list]

💡 THE PLAYBOOK (How to Trade It)

[list]
[*]The Setup: Wait for the 15-minute ORB box to seal at 09:45 ET.
[*]The Trigger: A green "ORB LONG" triangle will print when the stock breaks the ORB High, provided it is also above VWAP, above the Previous Close, and has volume expansion.
[*]The Execution: Enter on the close of the signal bar. Place your stop loss at the red "Stop Loss" line (ORB Low - 1 ATR). Scale out at the green Target 1 and Target 2 lines.
[/list]

Disclaimer: This script is for educational and analytical purposes only. Long-only momentum trading at the market open carries high volatility risk. Always backtest and use strict risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// 
//@version=6
// =========================================================================
// STRATEGY NAME: The Open Momentum Engine [BrainTrustTrading]
// AUTHOR:        © BrainTrustTrading
// VERSION:       1.0
// DESCRIPTION:   Screener-compatible indicator designed for US Equities.
//                Scans for pre-market gap-ups, Opening Range Breakouts (ORB),
//                VWAP adherence, and EMA stack momentum. Long-only.
// =========================================================================

indicator("Open Momentum Engine [BTT]", shorttitle="OME", overlay=true,max_labels_count=50, max_boxes_count=50)

// =========================================================================
// ─── 1. GAP SETTINGS ──────────────────────────────────────────────────────
// =========================================================================
grp_gap       = "1. Gap Settings"
minGapPct     = input.float(2.0, "Min Gap Up %",           group=grp_gap, step=0.5)
gapTierA      = input.float(5.0, "Tier-A Gap Threshold %", group=grp_gap, step=0.5,
                  tooltip="Gaps ≥ this earn a bonus score point and fire the Tier-A alert")

// =========================================================================
// ─── 2. SESSION LEVEL TRACKING ────────────────────────────────────────────
// =========================================================================
grp_pm        = "2. Session Level Tracking"
showPrevRth   = input.bool(true,  "Show Previous RTH Close (16:00)",     group=grp_pm)
showAh        = input.bool(false, "Show After-Hours Range (16:00–20:00)", group=grp_pm)
showPmFull    = input.bool(true,  "Show Pre-Market Range (04:00–09:30)",  group=grp_pm)
showPm30      = input.bool(false, "Show PM30 Range (09:00–09:30)",        group=grp_pm)

// =========================================================================
// ─── 3. ORB SETTINGS ──────────────────────────────────────────────────────
// =========================================================================
grp_orb       = "3. ORB Settings"
orbMinutes    = input.int(15,    "ORB Duration (Minutes)", group=grp_orb, options=[5, 15, 30])
showOrbZone   = input.bool(true, "Show ORB Zone Box",      group=grp_orb)

// =========================================================================
// ─── 4. SETUP FILTERS ─────────────────────────────────────────────────────
// =========================================================================
grp_filters   = "4. Setup Filters (Strict Hierarchy)"
reqBreakPm    = input.bool(true,  "Require Breakout > PM High",          group=grp_filters)
useVwap       = input.bool(true,  "Require Price > VWAP",                group=grp_filters)
useEmaStack   = input.bool(true,  "Require EMA Stack (Fast > Slow)",     group=grp_filters)
emaFastLen    = input.int(9,      "Fast EMA Length",                     group=grp_filters)
emaSlowLen    = input.int(20,     "Slow EMA Length",                     group=grp_filters)
reqVolSurge   = input.bool(true,  "Require Volume Expansion",            group=grp_filters)
volMultiplier = input.float(1.5,  "Volume Surge Multiplier",             group=grp_filters, step=0.1)
volMaLength   = input.int(20,     "Volume MA Length",                    group=grp_filters)
useRsi        = input.bool(false, "Require RSI > Threshold",             group=grp_filters)
rsiLength     = input.int(14,     "RSI Length",                          group=grp_filters)
rsiThreshold  = input.float(50.0, "RSI Min Threshold",                   group=grp_filters, step=1.0)

// =========================================================================
// ─── 5. ATR RISK FRAMEWORK ────────────────────────────────────────────────
// =========================================================================
grp_risk      = "5. ATR Risk Framework"
showRisk      = input.bool(true,  "Show Stop / Target Levels",  group=grp_risk)
atrLength     = input.int(14,     "ATR Length",                 group=grp_risk)
stopAtrMult   = input.float(1.0,  "Stop Loss  (ATR ×)",         group=grp_risk, step=0.25)
tgt1AtrMult   = input.float(2.0,  "Target 1   (ATR ×)",         group=grp_risk, step=0.25)
tgt2AtrMult   = input.float(4.0,  "Target 2   (ATR ×)",         group=grp_risk, step=0.25)

// =========================================================================
// ─── 6. ORB HIGH RE-TEST SIGNAL ───────────────────────────────────────────
// =========================================================================
grp_retest    = "6. ORB High Re-Test Signal"
useRetest     = input.bool(true,  "Enable Re-Test Entry Signal", group=grp_retest)
retestBuffer  = input.float(0.15, "Re-Test Zone Buffer %",       group=grp_retest, step=0.05,
                  tooltip="Price must touch within this % below ORB High to arm a re-test")

// =========================================================================
// ─── 7. TIME FILTERS ──────────────────────────────────────────────────────
// =========================================================================
grp_session   = "7. Time Filters"
useSession    = input.bool(true, "Early Session Only (09:30–11:30 ET)", group=grp_session)

// =========================================================================
// ─── 8. VISUAL DISPLAY ────────────────────────────────────────────────────
// =========================================================================
grp_hud       = "8. Visual Display"
showHud       = input.bool(true, "Show Stats Panel (Top Right)", group=grp_hud)


// =========================================================================
// CORE TIME MATH  (US Equities — Eastern Time)
// =========================================================================
nyHour      = hour(time, "America/New_York")
nyMin       = minute(time, "America/New_York")
timeInMins  = nyHour * 60 + nyMin

isPM        = timeInMins >= 240  and timeInMins <  570    // 04:00–09:29
isPM30      = timeInMins >= 540  and timeInMins <  570    // 09:00–09:29
isRTH       = timeInMins >= 570  and timeInMins <  960    // 09:30–15:59
isAH        = timeInMins >= 960  and timeInMins <= 1200   // 16:00–20:00

bool newPM    = isPM   and not isPM[1]
bool newPM30  = isPM30 and not isPM30[1]
bool newRTH   = isRTH  and not isRTH[1]
bool newAH    = isAH   and not isAH[1]
bool isNewDay = timeframe.change("D")

minsSinceOpen = isRTH ? (timeInMins - 570) : -1
bool orbActive   = isRTH and minsSinceOpen >= 0 and minsSinceOpen <  orbMinutes
bool orbComplete = isRTH and minsSinceOpen >= orbMinutes


// =========================================================================
// SESSION MEMORY STATE MACHINE
// =========================================================================
var float currentRthClose = na
var float prevRthClose    = na
var float ahHigh   = na
var float ahLow    = na
var float pmHigh   = na
var float pmLow    = na
var float pm30High = na
var float pm30Low  = na
var float orbHigh  = na
var float orbLow   = na

// Lock prior RTH close at day boundary
if isNewDay
    prevRthClose := currentRthClose

if isRTH
    currentRthClose := close

// After-Hours
if newAH
    ahHigh := high
    ahLow  := low
else if isAH
    ahHigh := math.max(ahHigh, high)
    ahLow  := math.min(ahLow,  low)

// Full Pre-Market
if newPM
    pmHigh := high
    pmLow  := low
else if isPM
    pmHigh := math.max(pmHigh, high)
    pmLow  := math.min(pmLow,  low)

// PM30
if newPM30
    pm30High := high
    pm30Low  := low
else if isPM30
    pm30High := math.max(pm30High, high)
    pm30Low  := math.min(pm30Low,  low)

// ORB — live during the opening range window, frozen after
if newRTH
    orbHigh := high
    orbLow  := low
else if orbActive
    orbHigh := math.max(orbHigh, high)
    orbLow  := math.min(orbLow,  low)


// =========================================================================
// ORB ZONE BOX  (renders live during ORB, freezes when window closes)
// =========================================================================
var box orbBox = na

if showOrbZone
    if newRTH
        // Create a fresh box at the open of every RTH session
        orbBox := box.new(bar_index, high, bar_index + 1, low,
                          border_color = color.new(color.green, 55),
                          bgcolor      = color.new(color.green, 88),
                          border_width = 1)
    else if orbActive and not na(orbBox)
        // Extend the box right edge and expand top/bottom as range builds
        box.set_right(orbBox,  bar_index + 1)
        box.set_top(orbBox,    orbHigh)
        box.set_bottom(orbBox, orbLow)


// =========================================================================
// LIVE CALCULATIONS
// =========================================================================
gapPct   = prevRthClose > 0 ? ((close - prevRthClose) / prevRthClose) * 100 : 0.0
vwapVal  = ta.vwap
emaFast  = ta.ema(close, emaFastLen)
emaSlow  = ta.ema(close, emaSlowLen)
volMa    = ta.sma(volume, volMaLength)
volRatio = volMa > 0 ? (volume / volMa) : 0.0
volSurge = volRatio >= volMultiplier
rsiVal   = ta.rsi(close, rsiLength)
atrVal   = ta.atr(atrLength)


// =========================================================================
// SETUP FILTER LOGIC
// =========================================================================
gapPass     = gapPct   >= minGapPct
holdsPrevC  = close    >  prevRthClose
vwapPass    = not useVwap    or (close > vwapVal)
pmPass      = not reqBreakPm or na(pmHigh) or (close > pmHigh)
emaPass     = not useEmaStack or (emaFast > emaSlow)
volPass     = not reqVolSurge or volSurge
rsiPass     = not useRsi      or (rsiVal > rsiThreshold)
sessionPass = not useSession  or (minsSinceOpen >= orbMinutes and minsSinceOpen <= 120)

// First bar whose CLOSE crosses from ≤ to > ORB High
isBreakoutBar = orbComplete and (close > orbHigh) and (close[1] <= orbHigh[1])

// ── Primary Long Signal ────────────────────────────────────────────────────
longTrigger = isBreakoutBar and gapPass and holdsPrevC and
              vwapPass and pmPass and emaPass and volPass and rsiPass and sessionPass


// =========================================================================
// SETUP SCORING ENGINE
// ─ Always-on (independent of filter toggles) so the score reflects raw
//   setup quality and is comparable across screener columns.
// ─ 9 points max: 8 base conditions + 1 Tier-A gap bonus.
// =========================================================================
int score = 0
score += gapPct >= minGapPct                           ? 1 : 0  // gap cleared
score += gapPct >= gapTierA                            ? 1 : 0  // Tier-A bonus
score += holdsPrevC                                    ? 1 : 0  // above prev RTH close
score += not na(pmHigh) and close > pmHigh             ? 1 : 0  // above PM high
score += orbComplete and not na(orbHigh) and
         close > orbHigh                               ? 1 : 0  // above ORB high
score += close > vwapVal                               ? 1 : 0  // above VWAP
score += volSurge                                      ? 1 : 0  // volume expansion
score += emaFast > emaSlow                             ? 1 : 0  // EMA stack
score += rsiVal  > rsiThreshold                        ? 1 : 0  // RSI momentum

int maxScore = 9

string setupGrade = score >= 8 ? "A+" : score >= 6 ? "A" : score >= 4 ? "B" : "C"
color  gradeColor = score >= 8 ? color.lime : score >= 6 ? color.green : score >= 4 ? color.orange : color.red


// =========================================================================
// ATR RISK FRAMEWORK  (levels anchored to the signal-bar close)
// Stop  = ORB Low  − (stopAtrMult × ATR)   ← structural + volatility cushion
// T1/T2 = entry close + (mult × ATR)
// =========================================================================
var float entryPrice = na
var float stopLevel  = na
var float target1    = na
var float target2    = na

if longTrigger
    entryPrice := close
    stopLevel  := orbLow - (stopAtrMult * atrVal)
    target1    := close  + (tgt1AtrMult  * atrVal)
    target2    := close  + (tgt2AtrMult  * atrVal)


// =========================================================================
// ORB HIGH RE-TEST SIGNAL  (secondary long entry)
//
// State machine logic:
//   1. Primary breakout arms the tracker  (orbBrokenUp = true)
//   2. barsAfterBreak counts bars elapsed since break (min=2 before eligible)
//   3. If price pulls back so that LOW touches the ±retestBuffer% zone
//      around ORB High → zoneTouched = true
//   4. TRIGGER: while zoneTouched, if the bar closes ABOVE orbHigh on a
//      green (close > open) bar with VWAP + EMA confirmation → fire signal
//   5. One re-test signal per primary breakout (retestFired gate)
//   6. Full reset on each new trading day
// =========================================================================
var bool orbBrokenUp    = false
var bool zoneTouched    = false
var bool retestFired    = false
var int  barsAfterBreak = 0

// ── Day reset ─────────────────────────────────────────────────────────────
if isNewDay
    orbBrokenUp    := false
    zoneTouched    := false
    retestFired    := false
    barsAfterBreak := 0

// ── Arm tracker on primary signal ─────────────────────────────────────────
if longTrigger
    orbBrokenUp    := true
    zoneTouched    := false
    retestFired    := false
    barsAfterBreak := 0

// ── Track elapsed bars and detect zone entry ──────────────────────────────
if orbBrokenUp
    barsAfterBreak += 1
    // barsAfterBreak == 1 on the breakout bar itself; eligible from bar 2+
    if barsAfterBreak >= 2 and not na(orbHigh)
        bool inZone = (low  <= orbHigh * (1.0 + retestBuffer / 100.0)) and
                      (close >= orbHigh * (1.0 - retestBuffer / 100.0))
        if inZone and not zoneTouched
            zoneTouched := true

// ── Re-test trigger ────────────────────────────────────────────────────────
// Conditions: zone was touched → bar closes back above ORB High on a
//             bullish candle with supporting VWAP + EMA context
bool retestSignalFinal = useRetest       and
                         orbBrokenUp     and
                         zoneTouched     and
                         not retestFired and
                         barsAfterBreak  >= 2 and
                         close > orbHigh and
                         close > open    and
                         vwapPass        and
                         emaPass         and
                         sessionPass

if retestSignalFinal
    retestFired := true
    zoneTouched := false   // reset: requires a new zone touch for any further entry


// =========================================================================
// SCREENER OUTPUT PLOTS  (data_window only)
// Alert template indices: plot_0…plot_9
// =========================================================================
plot(longTrigger       ? 1 : 0,   "▶ Long Signal",    display=display.data_window)  // plot_0
plot(score,                        "▶ Setup Score",    display=display.data_window)  // plot_1
plot(gapPct,                       "▶ Gap %",          display=display.data_window)  // plot_2
plot(holdsPrevC        ? 1 : 0,   "▶ > Prev Close",   display=display.data_window)  // plot_3
plot(pmPass            ? 1 : 0,   "▶ > PM High",      display=display.data_window)  // plot_4
plot(orbComplete and not na(orbHigh) and
     close > orbHigh   ? 1 : 0,   "▶ > ORB High",     display=display.data_window)  // plot_5
plot(close > vwapVal   ? 1 : 0,   "▶ > VWAP",         display=display.data_window)  // plot_6
plot(volSurge          ? 1 : 0,   "▶ Vol Expansion",  display=display.data_window)  // plot_7
plot(emaPass           ? 1 : 0,   "▶ EMA Stacked",    display=display.data_window)  // plot_8
plot(retestSignalFinal ? 1 : 0,   "▶ Re-Test Signal", display=display.data_window)  // plot_9


// =========================================================================
// CHART VISUAL OUTPUTS
// =========================================================================

// ── Indicators ─────────────────────────────────────────────────────────────
plot(vwapVal, "VWAP",     color=color.new(color.blue,   0), linewidth=2)
plot(emaFast, "Fast EMA", color=color.new(color.teal,   0), linewidth=1)
plot(emaSlow, "Slow EMA", color=color.new(color.purple, 0), linewidth=1)

// ── Session Level Lines ─────────────────────────────────────────────────────
plot(showPrevRth ? prevRthClose : na, "Prev RTH Close",
     color=color.new(color.white,   30), style=plot.style_cross,   linewidth=1)
plot(showAh      ? ahHigh       : na, "AH High",
     color=color.new(color.maroon,  50), style=plot.style_circles, linewidth=1)
plot(showAh      ? ahLow        : na, "AH Low",
     color=color.new(color.maroon,  50), style=plot.style_circles, linewidth=1)
plot(showPmFull  ? pmHigh       : na, "PM High",
     color=color.new(color.fuchsia, 30), style=plot.style_linebr,  linewidth=1)
plot(showPmFull  ? pmLow        : na, "PM Low",
     color=color.new(color.fuchsia, 30), style=plot.style_linebr,  linewidth=1)
plot(showPm30    ? pm30High     : na, "PM30 High",
     color=color.new(color.orange,  30), style=plot.style_linebr,  linewidth=1)
plot(showPm30    ? pm30Low      : na, "PM30 Low",
     color=color.new(color.orange,  30), style=plot.style_linebr,  linewidth=1)

// ── ORB Lines (rendered only after window closes) ───────────────────────────
float orbHighPlot = orbComplete ? orbHigh : na
float orbLowPlot  = orbComplete ? orbLow  : na
plot(orbHighPlot, "ORB High", color=color.new(color.green, 20), style=plot.style_linebr, linewidth=2)
plot(orbLowPlot,  "ORB Low",  color=color.new(color.red,   30), style=plot.style_linebr, linewidth=2)

// ── ATR Risk Levels ─────────────────────────────────────────────────────────
plot(showRisk and not na(stopLevel) ? stopLevel : na, "Stop Loss",
     color=color.new(color.red,  30), style=plot.style_linebr, linewidth=1)
plot(showRisk and not na(target1)   ? target1   : na, "Target 1",
     color=color.new(color.lime, 30), style=plot.style_linebr, linewidth=1)
plot(showRisk and not na(target2)   ? target2   : na, "Target 2",
     color=color.new(color.lime, 30), style=plot.style_linebr, linewidth=1)

// ── Signal Shapes ───────────────────────────────────────────────────────────
plotshape(longTrigger,       "Long Entry", shape.triangleup, location.belowbar,
          color.green, size=size.normal, text="ORB LONG")
plotshape(retestSignalFinal, "Re-Test",    shape.triangleup, location.belowbar,
          color.aqua,  size=size.small,  text="RE-TEST")

bgcolor(longTrigger       ? color.new(color.green, 85) : na, title="Signal BG")
bgcolor(retestSignalFinal ? color.new(color.aqua,  90) : na, title="Re-Test BG")

// ── Signal Label — Score + Grade ────────────────────────────────────────────
if longTrigger
    label.new(bar_index, low,
              "Score " + str.tostring(score) + "/" + str.tostring(maxScore) +
              "  Grade: " + setupGrade,
              style     = label.style_label_up,
              color     = gradeColor,
              textcolor = color.white,
              size      = size.small)


// =========================================================================
// HUD TABLE  (2 columns and 8 rows)
// =========================================================================
var table statsHud = table.new(position.top_right, 2, 8,
                               bgcolor      = color.new(color.black, 70),
                               border_width = 1,
                               border_color = color.new(color.gray, 50))

if showHud and barstate.islast

    // Row 0 — Column headers
    table.cell(statsHud, 0, 0, "\n\nMETRIC",  text_color=color.new(color.gray, 20), text_size=size.tiny)
    table.cell(statsHud, 1, 0, "\n\nVALUE",   text_color=color.new(color.gray, 20), text_size=size.tiny)

    // Row 1 — Gap %
    color gapColor = gapPct >= gapTierA     ? color.lime  :
                     gapPct >= minGapPct    ? color.green : color.orange
    table.cell(statsHud, 0, 1, "Gap %",
               text_color=color.new(color.white, 20), text_size=size.small)
    table.cell(statsHud, 1, 1, str.tostring(gapPct, "#.##") + "%",
               text_color=gapColor, text_size=size.small)

    // Row 2 — Gap Tier
    string tierStr   = gapPct >= gapTierA  ? "A  (≥" + str.tostring(gapTierA, "#") + "%)" :
                       gapPct >= minGapPct ? "B" : "—"
    color  tierColor = gapPct >= gapTierA  ? color.lime  :
                       gapPct >= minGapPct ? color.green : color.gray
    table.cell(statsHud, 0, 2, "Gap Tier",
               text_color=color.new(color.white, 20), text_size=size.small)
    table.cell(statsHud, 1, 2, tierStr, text_color=tierColor, text_size=size.small)

    // Row 3 — Vol Ratio
    color volColor = volRatio >= volMultiplier ? color.green : color.orange
    table.cell(statsHud, 0, 3, "Vol Ratio",
               text_color=color.new(color.white, 20), text_size=size.small)
    table.cell(statsHud, 1, 3, str.tostring(volRatio, "#.##") + "x",
               text_color=volColor, text_size=size.small)

    // Row 4 — RSI
    color rsiColor = rsiVal >= rsiThreshold ? color.green : color.orange
    table.cell(statsHud, 0, 4, "RSI",
               text_color=color.new(color.white, 20), text_size=size.small)
    table.cell(statsHud, 1, 4, str.tostring(rsiVal, "#.#"),
               text_color=rsiColor, text_size=size.small)

    // Row 5 — Setup Score / Grade
    table.cell(statsHud, 0, 5, "Score",
               text_color=color.new(color.white, 20), text_size=size.small)
    table.cell(statsHud, 1, 5,
               str.tostring(score) + "/" + str.tostring(maxScore) + "  " + setupGrade,
               text_color=gradeColor, text_size=size.small)

    // Row 6 — ATR
    table.cell(statsHud, 0, 6, "ATR",
               text_color=color.new(color.white, 20), text_size=size.small)
    table.cell(statsHud, 1, 6, str.tostring(atrVal, "#.##"),
               text_color=color.new(color.white, 30), text_size=size.small)

    // Row 7 — Session + elapsed RTH minutes
    string sessionStr = isPM   ? "Pre-Market" : isRTH  ? "RTH +" + str.tostring(minsSinceOpen) + "m" : isAH   ? "After-Hours" : "Closed"
    table.cell(statsHud, 0, 7, "Session",
               text_color=color.new(color.white, 20), text_size=size.small)
    table.cell(statsHud, 1, 7, sessionStr,
               text_color=color.new(color.white, 30), text_size=size.small)


// =========================================================================
// ALERT CONDITIONS
// {{plot_N}} references the Nth plot() call in source order (0-indexed).
//   plot_0 = Long Signal  |  plot_1 = Setup Score  |  plot_2 = Gap %
// =========================================================================
alertcondition(longTrigger,
  title   = "ORB Breakout — Primary Signal",
  message = "[OME] {{ticker}} ORB Long triggered. Gap: {{plot_2}}% | Score: {{plot_1}}/9 | All filters passed.")

alertcondition(retestSignalFinal,
  title   = "ORB Re-Test — Secondary Entry",
  message = "[OME] {{ticker}} ORB High re-test entry confirmed. Score: {{plot_1}}/9 | VWAP + EMA supported.")

alertcondition(longTrigger and gapPct >= gapTierA,
  title   = "Tier-A Gap + ORB Breakout",
  message = "[OME] {{ticker}} TIER-A GAP BREAKOUT. Gap: {{plot_2}}% — maximum-grade setup.")
````
