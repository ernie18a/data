# Trade Execution Desk [JOAT]

- url: https://www.tradingview.com/script/RyafCWPs-Trade-Execution-Desk-JOAT/
- type: indicator
- pine_id: PUB;332fc21a6b174130ae8a668a5ef7868e
- version: 1.0

## Description

Trade Execution Desk is an open-source trade planning and session management tool designed for futures and structured discretionary traders who operate under daily loss limits, risk tier constraints, and session performance targets. It combines position sizing from account parameters, automatic pivot-based stop detection, three take-profit levels with risk-reward boxes, a 10-trade manual session log, and session status tracking into a single indicator.

The problem this addresses is the gap between an indicator that shows signals and a tool that translates those signals into an actual trade plan. Trade Execution Desk does not generate signals — it helps the trader structure the trade after a signal has been identified, ensuring that position size, stop placement, and profit targets are consistent with the account's defined risk parameters before the order is placed.

[image]https://www.tradingview.com/x/PKLunDZT/[/image]

[b]Core Concepts[/b]

[b]1. Risk-Based Position Sizing[/b]

Position size is computed from the daily loss limit, maximum risk percentage, risk tier multiplier, and the calculated stop distance in ticks:

[pine]
tierMult         = tier == "FULL" ? 1.0 : tier == "HALF" ? 0.5 : 0.25
riskAmount       = (dailyLossLimit * maxRiskPct / 100.0) * tierMult
contractsAllowed = math.floor(riskAmount / (stopDistTicks * tickValue))
[/pine]

This produces a contracts-allowed figure that respects the current risk tier and the actual stop distance on the current setup.

[b]2. Three Risk Tiers[/b]

The FULL tier allows the full calculated position size. The HALF tier reduces it by 50%. The QUARTER tier reduces by 75%. Tier selection reflects the trader's confidence level or account drawdown state.

[b]3. Auto Pivot Stop Detection[/b]

When auto stop is enabled, the indicator detects the most recent confirmed pivot high (for short trades) or pivot low (for long trades) and places the stop price at that level plus a configurable tick buffer. This anchors the stop to the nearest structural level automatically.

[b]4. Trade Block Visualization[/b]

Entry, stop, and three TP levels are plotted as horizontal lines with right-edge labels. The risk zone (entry to stop) is shown as a translucent red box; the reward zone (entry to TP1) as translucent green. All objects extend rightward in real time.

[b]5. Session Management[/b]

Four session-end conditions are tracked: daily target reached, maximum trade count reached, maximum loss count reached, and account rule violation. When any condition triggers, a session lockout overlay is displayed on the chart as a visual reminder that session trading is complete.

[b]6. Manual Trade Log[/b]

Ten trade entries can be logged manually with tier type and result. Results are converted to the selected unit (points, ticks, dollars, or percent of account). Sequential processing chains each entry's outcome into running totals for session P&L, trade count, loss count, and violation flag. A promotion threshold tracks whether the session meets the criteria to advance to the next risk tier.

[image]https://www.tradingview.com/x/ADx9OMhm/[/image]

[b]Features[/b]

[list]
[*][b]Risk-based position sizing:[/b] Contracts calculated from loss limit, risk percent, tier multiplier, and actual stop distance
[*][b]Three risk tiers:[/b] FULL / HALF / QUARTER with independent position size scaling
[*][b]Auto pivot stop detection:[/b] Nearest confirmed pivot placed as stop with configurable tick buffer
[*][b]Three TP levels with gradient boxes:[/b] TP1, TP2, TP3 as horizontal lines with translucent colored boxes
[*][b]Session status tracking:[/b] Target, max trades, max losses, and violation triggers with visual lockout overlay
[*][b]Ten-entry manual trade log:[/b] Each entry processed with tier, result, and unit conversion
[*][b]Promotion threshold:[/b] Tracks whether session performance meets the criteria to advance risk tier
[*][b]Unit conversion:[/b] All results displayable in Points, Ticks, Dollar, or Percent
[*][b]Session lockout overlay:[/b] Full-chart colored overlay when session ends, with reason displayed
[*][b]17-row institutional dashboard:[/b] Account params, tier state, stop/entry/TP levels, session status, trade log summary, promotion progress
[*][b]Non-repainting:[/b] All pivot detections use confirmed pivot functions with symmetric lookback
[/list]

[b]Input Parameters[/b]

[b]Risk Parameters:[/b]
[list]
[*]Account Size ($), Daily Loss Limit ($), Max Risk % Per Trade
[*]Tick Value ($), Ticks Per Point
[*]Daily Target ($), Max Trades Per Session, Max Losses Per Session
[/list]

[b]Risk Tier and Carryover:[/b]
[list]
[*]Current Risk Tier: FULL / HALF / QUARTER
[*]Carryover Deficit ($), Quarter Violation Active toggle, Quarter Extra Deficit ($)
[/list]

[b]Trade Planning:[/b]
[list]
[*]Trade Direction: Long / Short
[*]Enable Auto-Pivot Stop toggle, Pivot Left/Right Bars, Stop Buffer (Ticks)
[*]Manual Stop Price (0 = use auto)
[/list]

[b]RR Levels:[/b]
[list]
[*]Show TP1, TP2, TP3 toggles with RR multiples and colors
[*]Risk Zone and Reward Zone toggles
[*]Result Unit: Points / Ticks / Dollar / Percent
[/list]

[b]Trade Log:[/b]
[list]
[*]10 trade entries: Tier selector + Result value per entry
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Configure Account Parameters[/b]
Set your account size, daily loss limit, tick value, and ticks per point to match your trading instrument. Set the daily target and maximum trades/losses for your session rules.

[b]Step 2: Select Risk Tier[/b]
Choose FULL, HALF, or QUARTER based on your current account standing or confidence level. The contracts-allowed figure in the dashboard updates automatically.

[b]Step 3: Read the Entry/Stop/TP Levels[/b]
After identifying a trade direction, the auto-pivot stop places your stop at the nearest confirmed structural level. TP1, TP2, and TP3 are calculated automatically based on the stop distance and your configured RR multiples.

[b]Step 4: Log Trades Manually[/b]
After each trade, enter the tier and result in the trade log section. The dashboard updates session P&L, win rate, and promotion progress in real time.

[b]Step 5: Respect the Session Lockout[/b]
When the session lockout overlay appears, the reason is displayed prominently on the chart. The lockout is a visual reminder only — it does not interact with your broker.

[b]Indicator Limitations[/b]

[list]
[*]Position sizing uses tick value and ticks-per-point inputs specific to the traded instrument. These must be configured correctly for the output to be meaningful
[*]The session lockout overlay is a visual reminder only. It does not block order placement
[*]The manual trade log requires manual input after each trade. It does not auto-detect executions
[*]Promotion threshold calculation uses simple arithmetic from input values and may not account for all possible rule variations across different prop firm structures
[*]This indicator is a planning and logging tool. It does not generate entry or exit signals
[/list]

[b]Originality Statement[/b]

[list]
[*]The combination of risk-tier-aware position sizing, session-end condition tracking with visual chart lockout, a 10-entry chained trade log with unit conversion, and a promotion threshold tracker in a single open-source overlay indicator is not replicated in existing Pine Script v6 publications
[*]The sequential chaining of manual trade log entries through a processing function that propagates trade count, loss count, running P&L, and violation flag forward through ten entries provides structured session accounting within a chart indicator
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Position sizing outputs are mathematical calculations based on user-provided inputs and do not account for all real-world trade execution factors. Always verify position sizes and risk parameters independently before placing orders. The author accepts no responsibility for trading losses resulting from use of this indicator.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Trade Execution Desk [JOAT]", overlay=true, max_boxes_count=30, max_lines_count=20, max_labels_count=20)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — COLOR THEME
// ══════════════════════════════════════════════════════════════════════════════

string themeInput = input.string("Neon", "Color Theme", options=["Phantom","Neon","Classic","Solar"], group="◈ Visual")

var color colorBULL  = na
var color colorBEAR  = na
var color colorELITE = na
var color colorNEUTR = na

if themeInput == "Phantom"
    colorBULL  := color.rgb(6, 182, 212)
    colorBEAR  := color.rgb(236, 72, 153)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else if themeInput == "Neon"
    colorBULL  := #00F5D4
    colorBEAR  := #FF4466
    colorELITE := #6C63FF
    colorNEUTR := #FFD700
else if themeInput == "Classic"
    colorBULL  := color.rgb(0, 255, 0)
    colorBEAR  := color.rgb(255, 0, 0)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else
    colorBULL  := #FF9800
    colorBEAR  := #42A5F5
    colorELITE := #FFEB3B
    colorNEUTR := #9E9E9E

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// ── Risk Parameters ──────────────────────────────────────────────────────────
var string G_RISK = "════ Risk Parameters ════"
float accountSize    = input.float(50000.0, "Account Size ($)",         group=G_RISK, minval=0.0)
float availDrawdown  = input.float(2500.0,  "Daily Loss Limit ($)",     group=G_RISK, minval=0.0)
float maxRiskPerc    = input.float(2.0,     "Max Risk % Per Trade",     group=G_RISK, minval=0.0, maxval=100.0)
float tickValue      = input.float(1.25,    "Tick Value ($)",           group=G_RISK, minval=0.0001)
float pointTicks     = input.float(4.0,     "Ticks Per Point",          group=G_RISK, minval=1.0)
float dailyTarget    = input.float(500.0,   "Daily Target ($)",         group=G_RISK, minval=0.0)
int   maxTradesInput = input.int(5,         "Max Trades Per Session",   group=G_RISK, minval=1, maxval=20)
int   maxLossesInput = input.int(2,         "Max Losses Per Session",   group=G_RISK, minval=1, maxval=10)

// ── Risk Tier & Carryover ────────────────────────────────────────────────────
var string G_TIER = "════ Risk Tier & Carryover ════"
string currentTier      = input.string("FULL",  "Current Risk Tier", options=["FULL","HALF","QUARTER"], group=G_TIER)
float  carryoverDeficit = input.float(0.0,  "Carryover Deficit ($)",    group=G_TIER, minval=0.0)
bool   quarterViolation = input.bool(false, "Quarter Violation Active", group=G_TIER)
float  quarterExtraDef  = input.float(0.0,  "Quarter Extra Deficit ($)",group=G_TIER, minval=0.0)

// ── Trade Planning & Stops ───────────────────────────────────────────────────
var string G_PLAN = "════ Trade Planning & Stops ════"
string tradeDir      = input.string("Long",  "Trade Direction", options=["Long","Short"], group=G_PLAN)
bool   autoStop      = input.bool(true,      "Enable Auto-Pivot Stop",    group=G_PLAN)
int    pivotLeft     = input.int(3,          "Pivot Left Bars",  minval=1, group=G_PLAN)
int    pivotRight    = input.int(3,          "Pivot Right Bars", minval=1, group=G_PLAN)
float  stopBuffer    = input.float(4.0,      "Stop Buffer (Ticks)",       group=G_PLAN, minval=0.0)
float  manualStop    = input.float(0.0,      "Manual Stop Price (0=auto)",group=G_PLAN, minval=0.0)
bool   showPivotLbls = input.bool(false,     "Show Pivot Labels",         group=G_PLAN)
int    stopLineW     = input.int(1,          "Stop Line Width",  1, 4,    group=G_PLAN)
string stopLineStyle = input.string("Dashed","Stop Line Style", options=["Solid","Dashed","Dotted"], group=G_PLAN)
color  col_entry     = input.color(#ffffff,  "Entry Line Color",          group=G_PLAN)
color  col_stop      = input.color(#ff0000,  "Stop Line Color",           group=G_PLAN)

// ── RR Levels ────────────────────────────────────────────────────────────────
var string G_RR = "════ RR Levels ════"
bool   showRRLevels  = input.bool(true,  "Show RR Levels",               group=G_RR)
bool   showEntryLine = input.bool(true,  "Show Entry Line",              group=G_RR)
bool   showTP1   = input.bool(true,  "Show TP1", group=G_RR, inline="tp1")
float  rr1       = input.float(1.0,  "RR",       group=G_RR, inline="tp1", minval=0.1, step=0.5)
color  col_tp1   = input.color(color.rgb(0,200,100), "", group=G_RR, inline="tp1")
int    tp1W      = input.int(1, "",               group=G_RR, inline="tp1", minval=1, maxval=4)
bool   showTP2   = input.bool(true,  "Show TP2", group=G_RR, inline="tp2")
float  rr2       = input.float(2.0,  "RR",       group=G_RR, inline="tp2", minval=0.1, step=0.5)
color  col_tp2   = input.color(color.rgb(0,230,80),  "", group=G_RR, inline="tp2")
int    tp2W      = input.int(1, "",               group=G_RR, inline="tp2", minval=1, maxval=4)
bool   showTP3   = input.bool(true,  "Show TP3", group=G_RR, inline="tp3")
float  rr3       = input.float(3.0,  "RR",       group=G_RR, inline="tp3", minval=0.1, step=0.5)
color  col_tp3   = input.color(color.rgb(0,255,0),   "", group=G_RR, inline="tp3")
int    tp3W      = input.int(2, "",               group=G_RR, inline="tp3", minval=1, maxval=4)
bool   showRiskZone   = input.bool(true, "Show Risk Zone",               group=G_RR)
bool   showRewardZone = input.bool(true, "Show Reward Zone",             group=G_RR)
string rrLabelSize    = input.string("Small", "Label Size", options=["Tiny","Small","Normal"], group=G_RR)
int    rrExtend       = input.int(20, "Line Extend (bars right)", 1, 100, group=G_RR)
string resultUnit     = input.string("Points","Result Unit", options=["Points","Ticks","Dollar","Percent"], group=G_RR)

// ── Trade Log (10 entries) ───────────────────────────────────────────────────
var string G_LOG = "════ Trade Log ════"
string t01_tier = input.string("None","T01 Tier", options=["None","FULL","HALF","QUARTER","Violation"], group=G_LOG, inline="t01")
float  t01_res  = input.float(0.0, "Pts", group=G_LOG, inline="t01")
string t02_tier = input.string("None","T02 Tier", options=["None","FULL","HALF","QUARTER","Violation"], group=G_LOG, inline="t02")
float  t02_res  = input.float(0.0, "Pts", group=G_LOG, inline="t02")
string t03_tier = input.string("None","T03 Tier", options=["None","FULL","HALF","QUARTER","Violation"], group=G_LOG, inline="t03")
float  t03_res  = input.float(0.0, "Pts", group=G_LOG, inline="t03")
string t04_tier = input.string("None","T04 Tier", options=["None","FULL","HALF","QUARTER","Violation"], group=G_LOG, inline="t04")
float  t04_res  = input.float(0.0, "Pts", group=G_LOG, inline="t04")
string t05_tier = input.string("None","T05 Tier", options=["None","FULL","HALF","QUARTER","Violation"], group=G_LOG, inline="t05")
float  t05_res  = input.float(0.0, "Pts", group=G_LOG, inline="t05")
string t06_tier = input.string("None","T06 Tier", options=["None","FULL","HALF","QUARTER","Violation"], group=G_LOG, inline="t06")
float  t06_res  = input.float(0.0, "Pts", group=G_LOG, inline="t06")
string t07_tier = input.string("None","T07 Tier", options=["None","FULL","HALF","QUARTER","Violation"], group=G_LOG, inline="t07")
float  t07_res  = input.float(0.0, "Pts", group=G_LOG, inline="t07")
string t08_tier = input.string("None","T08 Tier", options=["None","FULL","HALF","QUARTER","Violation"], group=G_LOG, inline="t08")
float  t08_res  = input.float(0.0, "Pts", group=G_LOG, inline="t08")
string t09_tier = input.string("None","T09 Tier", options=["None","FULL","HALF","QUARTER","Violation"], group=G_LOG, inline="t09")
float  t09_res  = input.float(0.0, "Pts", group=G_LOG, inline="t09")
string t10_tier = input.string("None","T10 Tier", options=["None","FULL","HALF","QUARTER","Violation"], group=G_LOG, inline="t10")
float  t10_res  = input.float(0.0, "Pts", group=G_LOG, inline="t10")

// ── Appearance ───────────────────────────────────────────────────────────────
var string G_VIS = "════ Appearance ════"
bool   showDash    = input.bool(true,          "Show Dashboard",  group=G_VIS)
string dashPos     = input.string("Top Right",  "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=G_VIS)
string dashSize    = input.string("Small",      "Size",     options=["Tiny","Small","Normal"], group=G_VIS)
bool   showLockout = input.bool(true,           "Show Session Lockout", group=G_VIS)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — UTILITY FUNCTIONS  (all defined before any call site)
// ══════════════════════════════════════════════════════════════════════════════

// Convert raw points to the selected display unit
f_toDisplay(float rawPts) =>
    float pointValue = tickValue * pointTicks
    switch resultUnit
        "Ticks"   => rawPts / pointTicks
        "Dollar"  => rawPts * pointValue
        "Percent" => accountSize > 0 ? (rawPts * pointValue) / accountSize * 100.0 : 0.0
        => rawPts  // Points (default)

// Accumulate one trade-log entry.
// Returns [tradeCount, lossCount, runningTotal, violationFlag]
f_process(string tier, float rawPts, int trades, int losses, float total, bool viol) =>
    int   t2 = trades
    int   l2 = losses
    float r2 = total
    bool  v2 = viol
    if tier != "None"
        float pts = f_toDisplay(rawPts)
        t2 := trades + 1
        r2 := total + pts
        l2 := losses + (pts < 0 ? 1 : 0)
        v2 := viol or (tier == "Violation")
    [t2, l2, r2, v2]

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — CORE RISK CALCULATIONS
// ══════════════════════════════════════════════════════════════════════════════

float pointValue = tickValue * pointTicks
float tierMult   = currentTier == "FULL" ? 1.0 : currentTier == "HALF" ? 0.5 : 0.25
float riskAmount = (availDrawdown * maxRiskPerc / 100.0) * tierMult

// ── Pivot detection ──────────────────────────────────────────────────────────
float pivHigh = ta.pivothigh(high, pivotLeft, pivotRight)
float pivLow  = ta.pivotlow( low,  pivotLeft, pivotRight)

var float lastPivH = na
var float lastPivL = na

if not na(pivHigh)
    lastPivH := pivHigh
    if showPivotLbls
        label.new(bar_index - pivotRight, pivHigh, "H",
            style=label.style_label_down,
            color=color.new(colorBEAR, 70),
            textcolor=colorBEAR,
            size=size.tiny)

if not na(pivLow)
    lastPivL := pivLow
    if showPivotLbls
        label.new(bar_index - pivotRight, pivLow, "L",
            style=label.style_label_up,
            color=color.new(colorBULL, 70),
            textcolor=colorBULL,
            size=size.tiny)

// Stop buffer converted from ticks to price distance
float bufferDist = stopBuffer * tickValue / pointTicks

// Resolve stop price (manual > auto-pivot)
float stopPrice = na
if manualStop > 0.0
    stopPrice := manualStop
else if autoStop
    if tradeDir == "Long" and not na(lastPivL)
        stopPrice := lastPivL - bufferDist
    else if tradeDir == "Short" and not na(lastPivH)
        stopPrice := lastPivH + bufferDist

bool stopValid = not na(stopPrice) and stopPrice > 0.0

// Distance in ticks from current close to stop
float stopDistTicks = stopValid and close > 0.0 ? math.abs(close - stopPrice) / pointValue * pointTicks : na

// Maximum contracts within the risk budget
float contractsAllowed = stopValid and not na(stopDistTicks) and stopDistTicks > 0.0 ? math.floor(riskAmount / (stopDistTicks * tickValue)) : 0.0

// ── TP price levels ──────────────────────────────────────────────────────────
float entryPrice = close
float rrDir      = tradeDir == "Long" ? 1.0 : -1.0
float stopDist   = stopValid ? math.abs(entryPrice - stopPrice) : na

float tp1Price   = stopValid ? entryPrice + rrDir * stopDist * rr1 : na
float tp2Price   = stopValid ? entryPrice + rrDir * stopDist * rr2 : na
float tp3Price   = stopValid ? entryPrice + rrDir * stopDist * rr3 : na

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — TRADE LOG PROCESSING
// ══════════════════════════════════════════════════════════════════════════════

// Chain all 10 entries sequentially — each feeds the next
[c1t, c1l, c1r, c1v] = f_process(t01_tier, t01_res, 0,   0,   0.0, false)
[c2t, c2l, c2r, c2v] = f_process(t02_tier, t02_res, c1t, c1l, c1r, c1v)
[c3t, c3l, c3r, c3v] = f_process(t03_tier, t03_res, c2t, c2l, c2r, c2v)
[c4t, c4l, c4r, c4v] = f_process(t04_tier, t04_res, c3t, c3l, c3r, c3v)
[c5t, c5l, c5r, c5v] = f_process(t05_tier, t05_res, c4t, c4l, c4r, c4v)
[c6t, c6l, c6r, c6v] = f_process(t06_tier, t06_res, c5t, c5l, c5r, c5v)
[c7t, c7l, c7r, c7v] = f_process(t07_tier, t07_res, c6t, c6l, c6r, c6v)
[c8t, c8l, c8r, c8v] = f_process(t08_tier, t08_res, c7t, c7l, c7r, c7v)
[c9t, c9l, c9r, c9v] = f_process(t09_tier, t09_res, c8t, c8l, c8r, c8v)
[tradesTaken, lossCount, totalResult, hasViolation] = f_process(t10_tier, t10_res, c9t, c9l, c9r, c9v)

// ── Derived session metrics ──────────────────────────────────────────────────
int   winCount        = tradesTaken - lossCount
float winRate         = tradesTaken > 0 ? float(winCount) / float(tradesTaken) * 100.0 : 0.0
float totalDollar     = totalResult * pointValue
float lossUsedDollar  = math.max(-totalDollar, 0.0)
float lossUsedPct     = availDrawdown > 0 ? math.min(lossUsedDollar / availDrawdown * 100.0, 100.0) : 0.0
float targetPct       = dailyTarget > 0 ? math.min(math.abs(totalDollar) / dailyTarget * 100.0, 100.0) : 0.0

// ── Promotion threshold ──────────────────────────────────────────────────────
float baseThreshold   = carryoverDeficit / 2.0
float extraThreshold  = quarterViolation ? quarterExtraDef / 2.0 : 0.0
float totalThreshold  = baseThreshold + extraThreshold
bool  promotionMet    = totalThreshold > 0.0 and totalResult >= totalThreshold

// ── Session end-condition flags ──────────────────────────────────────────────
bool targetHit         = totalDollar >= dailyTarget and dailyTarget > 0
bool maxTradesReached  = tradesTaken >= maxTradesInput
bool maxLossesReached  = lossCount >= maxLossesInput
bool sessionOver       = targetHit or maxTradesReached or maxLossesReached or hasViolation

string statusText  = targetHit ? "TARGET HIT" : maxTradesReached ? "MAX TRADES" : maxLossesReached ? "MAX LOSSES" : hasViolation ? "VIOLATION" : "ACTIVE"
color  statusColor = sessionOver ? (hasViolation ? colorBEAR : colorBULL) : colorNEUTR

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — PERSISTENT DRAWING OBJECT DECLARATIONS
// ══════════════════════════════════════════════════════════════════════════════

var line  stopLine  = na
var line  entryLine = na
var line  tp1Line   = na
var line  tp2Line   = na
var line  tp3Line   = na
var label stopLbl   = na
var label entryLbl  = na
var label tp1Lbl    = na
var label tp2Lbl    = na
var label tp3Lbl    = na
var box   riskBox   = na
var box   rewBox    = na

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — RR LEVEL VISUALIZATION  (barstate.islast only)
// ══════════════════════════════════════════════════════════════════════════════

if showRRLevels and barstate.islast
    // Purge stale drawings before recreating
    line.delete(stopLine)
    line.delete(entryLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(stopLbl)
    label.delete(entryLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)
    box.delete(riskBox)
    box.delete(rewBox)

    int extRight = bar_index + rrExtend

    // Stop level
    if stopValid
        stopLine := line.new(bar_index, stopPrice, extRight, stopPrice,
            color=col_stop, width=stopLineW,
            style=stopLineStyle == "Dotted" ? line.style_dotted : stopLineStyle == "Dashed" ? line.style_dashed : line.style_solid)
        stopLbl  := label.new(extRight, stopPrice,
            "STOP  " + str.tostring(stopPrice, format.mintick),
            style=label.style_label_left,
            color=color.new(col_stop, 80),
            textcolor=col_stop,
            size=rrLabelSize == "Tiny" ? size.tiny : rrLabelSize == "Normal" ? size.normal : size.small)

    // Entry level
    if showEntryLine
        entryLine := line.new(bar_index, entryPrice, extRight, entryPrice,
            color=col_entry, width=1)
        entryLbl  := label.new(extRight, entryPrice,
            "ENTRY  " + str.tostring(entryPrice, format.mintick),
            style=label.style_label_left,
            color=color.new(col_entry, 80),
            textcolor=col_entry,
            size=rrLabelSize == "Tiny" ? size.tiny : rrLabelSize == "Normal" ? size.normal : size.small)

    // TP1
    if showTP1 and not na(tp1Price)
        tp1Line := line.new(bar_index, tp1Price, extRight, tp1Price,
            color=col_tp1, width=tp1W)
        tp1Lbl  := label.new(extRight, tp1Price,
            "TP1 " + str.tostring(rr1, "#.#") + "R  " + str.tostring(tp1Price, format.mintick),
            style=label.style_label_left,
            color=color.new(col_tp1, 80),
            textcolor=col_tp1,
            size=rrLabelSize == "Tiny" ? size.tiny : rrLabelSize == "Normal" ? size.normal : size.small)

    // TP2
    if showTP2 and not na(tp2Price)
        tp2Line := line.new(bar_index, tp2Price, extRight, tp2Price,
            color=col_tp2, width=tp2W)
        tp2Lbl  := label.new(extRight, tp2Price,
            "TP2 " + str.tostring(rr2, "#.#") + "R  " + str.tostring(tp2Price, format.mintick),
            style=label.style_label_left,
            color=color.new(col_tp2, 80),
            textcolor=col_tp2,
            size=rrLabelSize == "Tiny" ? size.tiny : rrLabelSize == "Normal" ? size.normal : size.small)

    // TP3
    if showTP3 and not na(tp3Price)
        tp3Line := line.new(bar_index, tp3Price, extRight, tp3Price,
            color=col_tp3, width=tp3W)
        tp3Lbl  := label.new(extRight, tp3Price,
            "TP3 " + str.tostring(rr3, "#.#") + "R  " + str.tostring(tp3Price, format.mintick),
            style=label.style_label_left,
            color=color.new(col_tp3, 80),
            textcolor=col_tp3,
            size=rrLabelSize == "Tiny" ? size.tiny : rrLabelSize == "Normal" ? size.normal : size.small)

    // Risk zone (entry → stop, shaded red)
    if showRiskZone and stopValid and not na(tp1Price)
        float rT = tradeDir == "Long" ? entryPrice : stopPrice
        float rB = tradeDir == "Long" ? stopPrice  : entryPrice
        riskBox := box.new(bar_index, rT, extRight, rB,
            bgcolor=color.new(colorBEAR, 88),
            border_color=color.new(colorBEAR, 70),
            border_width=1)

    // Reward zone (entry → TP1, shaded green)
    if showRewardZone and not na(tp1Price)
        float wT = tradeDir == "Long" ? tp1Price   : entryPrice
        float wB = tradeDir == "Long" ? entryPrice : tp1Price
        rewBox := box.new(bar_index, wT, extRight, wB,
            bgcolor=color.new(colorBULL, 88),
            border_color=color.new(colorBULL, 70),
            border_width=1)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — SESSION LOCKOUT OVERLAY
// ══════════════════════════════════════════════════════════════════════════════

var box   lockBox   = na
var label lockLabel = na

if sessionOver and showLockout and barstate.islast
    box.delete(lockBox)
    label.delete(lockLabel)
    lockBox   := box.new(bar_index - 300, close * 2.0, bar_index + 50, 0.0,
        bgcolor=color.new(statusColor, 80),
        border_color=statusColor,
        border_width=2)
    lockLabel := label.new(bar_index, close, statusText,
        color=color.new(statusColor, 25),
        textcolor=color.white,
        style=label.style_label_center,
        size=size.huge)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 8B — CHART VISUALS (gradient candles, risk zone tint, pivot dots)
// ══════════════════════════════════════════════════════════════════════════════

// ── Gradient candle coloring by trade direction and session state ─────────────
float atrVis      = ta.atr(14)
float rsiVis      = ta.rsi(close, 14)
color candleTheme = tradeDir == "Long" ? colorBULL : colorBEAR

// Gradient intensity driven by how close price is to stop (tighter stop = more red)
float stopProximity = (stopValid and stopDistTicks > 0) ? math.min(math.abs(close - stopPrice) / math.max(atrVis, syminfo.mintick) / 2.0, 1.0) : 0.5

color gradCandle = sessionOver ? color.new(colorNEUTR, 60) : (tradeDir == "Long" ? color.from_gradient(rsiVis, 40.0, 70.0, color.new(colorBULL, 55), colorBULL) : color.from_gradient(rsiVis, 30.0, 60.0, colorBEAR, color.new(colorBEAR, 55)))

barcolor(gradCandle)

// ── Subtle background tint: green when session active + target progress, red when over ──
color bgTint = sessionOver ? color.new(colorBEAR, 96) : (targetPct > 50.0 ? color.new(colorBULL, 97) : na)
bgcolor(bgTint)

// ── Neon glow candles (3 layers) tailored to trade direction ─────────────────
color glowBase = tradeDir == "Long" ? colorBULL : colorBEAR
plotcandle(open, high, low, close, "Glow Layer 2",
    color=color.new(glowBase, 95), wickcolor=color.new(glowBase, 95),
    bordercolor=color.new(glowBase, 95), display=display.all)
plotcandle(open, high, low, close, "Glow Layer 1",
    color=color.new(glowBase, 86), wickcolor=color.new(glowBase, 86),
    bordercolor=color.new(glowBase, 86), display=display.all)
plotcandle(open, high, low, close, "Glow Sharp",
    color=color.new(glowBase, 72), wickcolor=color.new(glowBase, 15),
    bordercolor=color.new(glowBase, 15), display=display.all)

// ── Pivot level markers: tiny dots at auto-detected stop pivots ───────────────
plotchar(showPivotLbls and not na(pivHigh), "Pivot High Dot", "◆",
    location.abovebar, color.new(colorBEAR, 30), size=size.tiny)
plotchar(showPivotLbls and not na(pivLow),  "Pivot Low Dot",  "◆",
    location.belowbar, color.new(colorBULL, 30), size=size.tiny)

// ── Promotion threshold progress bar (horizontal line near top of visible range) ──
// Draw a subtle colored line showing how much of the promotion threshold has been met
if barstate.islast and totalThreshold > 0.0 and not sessionOver
    float progPct = math.min(math.max(totalResult / totalThreshold, 0.0), 1.0)
    color progCol = progPct >= 1.0 ? colorBULL : progPct >= 0.5 ? colorNEUTR : colorBEAR
    label.new(bar_index + 3, close + atrVis * 1.5,
        "Promo: " + str.tostring(math.round(progPct * 100)) + "%",
        style=label.style_label_left,
        color=color.new(progCol, 75),
        textcolor=progCol,
        size=size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — DASHBOARD  (17 data rows + header + footer = 19 rows total)
// ══════════════════════════════════════════════════════════════════════════════

// Build size constant
string dSz = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : size.small

// Resolve table position constant each bar (Pine needs a concrete value)
var table dash = table.new(
    dashPos == "Top Left"     ? position.top_left     :
    dashPos == "Bottom Right" ? position.bottom_right :
    dashPos == "Bottom Left"  ? position.bottom_left  : position.top_right,
    2, 19,
    bgcolor=color.new(#0d1117, 10),
    border_color=color.new(#30363d, 20), border_width=1,
    frame_color=color.new(#30363d, 40), frame_width=1)

// Convenience wrapper — write one table cell
f_dc(int col, int row, string txt, color tc, color bg) =>
    table.cell(dash, col, row, txt,
        text_color=tc,
        text_size=dSz,
        bgcolor=bg,
        text_halign=col == 0 ? text.align_left : text.align_right)

if showDash and barstate.islast
    // Palette shortcuts
    color hBg  = color.new(#1A237E, 0)
    color pBg  = color.new(#161b22, 0)
    color dBg  = color.new(#0d1117, 10)
    color cMut = color.new(#8b949e, 0)

    // ── Row 0 — Header ───────────────────────────────────────────────────────
    f_dc(0, 0, "Trade Execution Desk [JOAT]", colorELITE, hBg)
    f_dc(1, 0, "v1.0", cMut, hBg)

    // ── Row 1 — Account size ─────────────────────────────────────────────────
    f_dc(0, 1, "Account",   cMut, pBg)
    f_dc(1, 1, "$" + str.tostring(accountSize, "#,###"), cMut, dBg)

    // ── Row 2 — Daily loss limit ─────────────────────────────────────────────
    f_dc(0, 2, "Loss Limit", cMut, pBg)
    f_dc(1, 2, "$" + str.tostring(availDrawdown, "#,###"), cMut, dBg)

    // ── Row 3 — Risk tier ────────────────────────────────────────────────────
    color tierCol = currentTier == "FULL" ? colorBULL : currentTier == "HALF" ? colorNEUTR : colorBEAR
    f_dc(0, 3, "Risk Tier", cMut, pBg)
    f_dc(1, 3, currentTier + "  (" + str.tostring(tierMult * 100.0, "#") + "%)", tierCol, dBg)

    // ── Row 4 — Contracts allowed ────────────────────────────────────────────
    color ctCol = contractsAllowed > 0 ? colorBULL : colorBEAR
    f_dc(0, 4, "Contracts", cMut, pBg)
    f_dc(1, 4, str.tostring(int(contractsAllowed)), ctCol, dBg)

    // ── Row 5 — Trade direction ──────────────────────────────────────────────
    color dirCol = tradeDir == "Long" ? colorBULL : colorBEAR
    f_dc(0, 5, "Direction", cMut, pBg)
    f_dc(1, 5, tradeDir, dirCol, dBg)

    // ── Row 6 — Entry price ──────────────────────────────────────────────────
    f_dc(0, 6, "Entry", cMut, pBg)
    f_dc(1, 6, str.tostring(entryPrice, format.mintick), cMut, dBg)

    // ── Row 7 — Stop price ───────────────────────────────────────────────────
    f_dc(0, 7, "Stop", cMut, pBg)
    f_dc(1, 7,
        stopValid ? str.tostring(stopPrice, format.mintick) : "─ (set pivot/manual)",
        colorBEAR, dBg)

    // ── Row 8 — TP1 & TP2 ───────────────────────────────────────────────────
    string tpTxt = not na(tp1Price) ? str.tostring(tp1Price, format.mintick) + " / " + str.tostring(tp2Price, format.mintick) : "─"
    f_dc(0, 8, "TP1 / TP2", cMut, pBg)
    f_dc(1, 8, tpTxt, colorBULL, dBg)

    // ── Row 9 — TP3 ──────────────────────────────────────────────────────────
    f_dc(0, 9, "TP3", cMut, pBg)
    f_dc(1, 9,
        not na(tp3Price) ? str.tostring(tp3Price, format.mintick) : "─",
        color.rgb(0, 255, 110), dBg)

    // ── Row 10 — Divider ─────────────────────────────────────────────────────
    f_dc(0, 10, "─────────────", cMut, pBg)
    f_dc(1, 10, "─────────────", cMut, dBg)

    // ── Row 11 — Session status ──────────────────────────────────────────────
    f_dc(0, 11, "Session", cMut, pBg)
    f_dc(1, 11, statusText, statusColor, dBg)

    // ── Row 12 — Trades taken ────────────────────────────────────────────────
    f_dc(0, 12, "Trades", cMut, pBg)
    f_dc(1, 12,
        str.tostring(tradesTaken) + " / " + str.tostring(maxTradesInput),
        tradesTaken >= maxTradesInput ? colorBEAR : cMut, dBg)

    // ── Row 13 — Loss count ──────────────────────────────────────────────────
    f_dc(0, 13, "Losses", cMut, pBg)
    f_dc(1, 13,
        str.tostring(lossCount) + " / " + str.tostring(maxLossesInput),
        lossCount >= maxLossesInput ? colorBEAR : cMut, dBg)

    // ── Row 14 — Win rate ────────────────────────────────────────────────────
    color wrCol = winRate >= 60 ? colorBULL : winRate >= 40 ? colorNEUTR : tradesTaken > 0 ? colorBEAR : cMut
    f_dc(0, 14, "Win Rate", cMut, pBg)
    f_dc(1, 14,
        tradesTaken > 0 ? str.tostring(winRate, "#.#") + "%" : "─",
        wrCol, dBg)

    // ── Row 15 — Session P&L ─────────────────────────────────────────────────
    float displayTotal = f_toDisplay(totalResult)
    color totCol = displayTotal >= 0 ? colorBULL : colorBEAR
    string unitSuffix = resultUnit == "Points" ? " pts" : resultUnit == "Ticks" ? " ticks" : resultUnit == "Percent" ? "%" : " $"
    f_dc(0, 15, "P&L", cMut, pBg)
    f_dc(1, 15,
        (displayTotal >= 0 ? "+" : "") + str.tostring(displayTotal, "#.##") + unitSuffix,
        totCol, dBg)

    // ── Row 16 — Promotion threshold ─────────────────────────────────────────
    f_dc(0, 16, "Promotion", cMut, pBg)
    f_dc(1, 16,
        totalThreshold > 0 ?
            (promotionMet ? "MET" :
             str.tostring(totalResult, "#.#") + " / " + str.tostring(totalThreshold, "#.#")) : "─",
        promotionMet ? colorBULL : cMut, dBg)

    // ── Row 17 — Loss budget used ─────────────────────────────────────────────
    f_dc(0, 17, "Loss Used", cMut, pBg)
    f_dc(1, 17,
        "$" + str.tostring(lossUsedDollar, "#.##") + "  (" + str.tostring(lossUsedPct, "#.#") + "%)",
        lossUsedPct >= 80 ? colorBEAR : lossUsedPct >= 50 ? colorNEUTR : cMut, dBg)

    // ── Row 18 — Footer ──────────────────────────────────────────────────────
    f_dc(0, 18, "[JOAT]", color.new(#6C63FF, 0), color.new(#0d1117, 20))
    f_dc(1, 18, "jackofalltrades", cMut, color.new(#0d1117, 20))
````
