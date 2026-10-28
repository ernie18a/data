# Camarilla Pivot Points

- url: https://www.tradingview.com/script/8fgbzI6P-Camarilla-Pivot-Points/
- type: indicator
- pine_id: PUB;25ac4192c5ad463198204c337835c004
- version: 3.0

## Description

### Overview

Camarilla Pivot Points is an institutional-grade technical analysis indicator designed to project key intraday and swing support, resistance, and volatility expansion zones. Based on the mathematical framework introduced by Nick Stott in 1989, Camarilla pivots utilize the prior period's high, low, and close to establish statistically significant equilibrium and expansion thresholds.

Unlike traditional floor pivots, Camarilla levels place heavy emphasis on mean reversion within the central range while clearly distinguishing the boundary where explosive directional momentum begins.

This implementation features non-repainting higher timeframe data feeds, institutional zone shading, dedicated no-trade buffer zones, customizable display modes (projected active vs. full historical stepped lines), and optional real-time signal markers.


### Core Philosophy & Market Mechanics

Statistical market research demonstrates that asset prices spend approximately 75% to 80% of trading sessions consolidating within the central dealing range. Camarilla pivots capitalize on this structure by dividing the market into three distinct behavioral regimes:

1. Range Equilibrium (Mean Reversion Regime)
The space between Support 3 (S3) and Resistance 3 (R3) represents the core dealing range. When the market opens or trades within this band, institutional algorithms frequently fade extremes, targeting a return to the opposite level or the Central Pivot (P).

2. The Buffer Zone (No-Trade Regime)
The zones between R3 to R4 and S3 to S4 represent transitionary buffers. In these bands, mean reversion has failed to resolve immediately, but a structural breakout has not yet occurred. Trading within these zones exposes market participants to unfavorable risk-to-reward ratios and false breakouts (whipsaws). This indicator explicitly highlights these buffer areas as designated "No-Trade Zones."

3. Directional Momentum (Breakout Regime)
A sustained breach and candle close outside R4 (bullish) or S4 (bearish) signals institutional accumulation or distribution. Once price escapes the buffer zone, mean-reversion trading is invalidated, and directional trend-following rules take effect toward R5 and S5.


### Mathematical Framework

All calculations are derived from the prior completed higher timeframe bar (High, Low, Close) and the prevailing range (High - Low):

* Pivot Point (P) = (High + Low + Close) / 3
* R5 (Max Bullish Expansion / Target 2) = Close + Range * 1.1000
* R4 (Bullish Breakout Trigger) = Close + Range * 0.5500
* R3 (Primary Resistance / Mean Reversion) = Close + Range * 0.2750
* R2 (Intermediate Upper Buffer) = Close + Range * 0.1833
* R1 (Minor Upper Buffer) = Close + Range * 0.0916

* S1 (Minor Lower Buffer) = Close - Range * 0.0916
* S2 (Intermediate Lower Buffer) = Close - Range * 0.1833
* S3 (Primary Support / Mean Reversion) = Close - Range * 0.2750
* S4 (Bearish Breakdown Trigger) = Close - Range * 0.5500
* S5 (Max Bearish Expansion / Target 2) = Close - Range * 1.1000


### How to Trade with Camarilla Pivot Points

#### 1. Mean Reversion Setup (Inside-Out)
* Bias: Neutral to Range-Bound.
* Long Entry: Price dips to or sweeps S3, rejects lower prices, and closes back above S3.
* Short Entry: Price rallies to or tests R3, rejects higher prices, and closes back below R3.
* Take Profit: Central Pivot (P), opposite pivot boundary (S3 -> R3, or R3 -> S3).
* Stop Loss: Beyond the respective buffer zone (below S4 for longs, above R4 for shorts).

#### 2. The No-Trade Rule (Buffer Zones)
* Region: Between R3 and R4 (Upper Buffer) and between S3 and S4 (Lower Buffer).
* Rule: Avoid initiating new positions inside these bands. Wait for either a confirmed rejection back into the range (mean reversion) or a confirmed close beyond R4/S4 (trend breakout).

#### 3. Trend Breakout Setup (Expansion Runners)
* Bias: Strong Momentum / Trend-Following.
* Bullish Breakout: A candle closes cleanly above R4 with strong volume. Target: R5.
* Bearish Breakdown: A candle closes cleanly below S4 with strong volume. Target: S5.
* Stop Loss: Inside the buffer zone (below R3 for longs, above S3 for shorts).


### Visual & Structural Features

* Clean Active Projections: Extends clean, clutter-free horizontal lines into the future with dynamic price and level tags.
* Full Historical Stepped Lines: View unbroken multi-day or multi-week historical performance across the entire chart.
* Institutional Shaded Boxes:
  - Range Equilibrium: Semi-transparent blue fill between S3 and R3.
  - Buffer / No-Trade Zones: Caution amber fill between R3-R4 and S3-S4 with right-aligned badges.
  - Bullish Expansion: Emerald green fill between R4 and R5.
  - Bearish Expansion: Coral red fill between S4 and S5.
* Real-Time Signal Markers: Optional visual cues plotted on confirmed candle closes for S3 bounces, R3 rejections, R4 breakouts, and S4 breakdowns.


### Input Settings

1. Calculation Engine:
* Camarilla Timeframe: Choose between Auto (Chart Adaptive), Daily, Weekly, or Monthly. The Auto setting assigns Daily to intraday charts (<= 15m), Weekly to intermediate timeframes (30m to 4h), and Monthly to daily/weekly charts.
* Display Mode: Active Period (Projected Lines & Zones), Historical Stepped Lines (Full History), or Both.
* Active Line Extension: Set how many bars forward the active levels project.

2. Levels Visibility:
* Independent visibility toggles for R5/S5, R4/S4, R3/S3, R2/S2, R1/S1, and the Central Pivot (P).

3. Shaded Zones:
* Toggles and custom color pickers for Range Zone (S3-R3), Buffer Zones (R3-R4 & S3-S4), Bull Breakout Zone (R4-R5), Bear Breakdown Zone (S4-S5), and the "NO-TRADE ZONE" text badge.

4. Signals & Alerts:
* Enable or disable visual markers for mean-reversion bounces and breakout momentum.


### Non-Repainting Guarantee

This indicator strictly accesses completed higher-timeframe bars using `request.security` with `lookahead = barmerge.lookahead_on` referencing closed bars `[1]`. Historical levels remain identical in real-time and after historical recalculation. No levels shift or repaint retroactively once the period opens.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sithuphyo_21 — Institutional Camarilla Pivot Points Indicator (v6)
//@version=6
indicator("Camarilla Pivot Points", shorttitle="Camarilla Pivots", overlay=true, 
     max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ============================================================================
// SECTION 1: USER INPUTS & CONFIGURATION
// ============================================================================

// ── 01. Timeframe & Calculation Engine ──────────────────────────────────────
string grp_calc             = "📐 01. Camarilla Calculation Engine"
string pivotTimeframe       = input.string("Daily", "Camarilla Timeframe",
     options = ["Auto (Chart Adaptive)", "Daily", "Weekly", "Monthly"], group = grp_calc,
     tooltip = "Reference higher timeframe for High, Low, Close calculations:\n• Auto: Automatically selects Daily for intraday (<=15m), Weekly for intermediate (30m-4h), and Monthly for higher timeframes.\n• Daily: Best for intraday day trading & scalping.\n• Weekly: Best for multi-day swing trading.\n• Monthly: Best for macro institutional key levels.")

string displayStyle         = input.string("Active Period (Projected Lines & Zones)", "Display Mode",
     options = ["Active Period (Projected Lines & Zones)", "Historical Stepped Lines (Full History)", "Both (Historical + Projected Active)"], group = grp_calc,
     tooltip = "• Active Period: Clean, clutter-free horizontal projection lines with right-side price tags & shaded zones for the current trading day/week.\n• Historical Stepped Lines: Continuous native step lines across all historical chart bars.\n• Both: Continuous historical lines plus extended active projection lines and shaded zones.")

int    extendBarsRight      = input.int(20, "Active Line Extension (Bars)", minval = 5, maxval = 100, group = grp_calc,
     tooltip = "Number of bars to project the current active Camarilla lines into the future.")

// ── 02. Pivot Levels Visibility ──────────────────────────────────────────────
string grp_levels           = "🎯 02. Camarilla Levels Display"
bool   showR5S5             = input.bool(true, "Show R5 & S5 (Target 2 / Max Expansion)", group = grp_levels,
     tooltip = "Extreme expansion target levels (C ± 1.10 x Range).")
bool   showR4S4             = input.bool(true, "Show R4 & S4 (Breakout / Breakdown Triggers)", group = grp_levels,
     tooltip = "Institutional trend breakout trigger levels (C ± 0.55 x Range).")
bool   showR3S3             = input.bool(true, "Show R3 & S3 (Mean Reversion S/R)", group = grp_levels,
     tooltip = "Statistical range boundaries where 75-80% of days consolidate (C ± 0.275 x Range).")
bool   showR2S2             = input.bool(false, "Show R2 & S2 (Intermediate Buffer)", group = grp_levels,
     tooltip = "Intermediate range buffers (C ± 0.1833 x Range).")
bool   showR1S1             = input.bool(false, "Show R1 & S1 (Minor Range)", group = grp_levels,
     tooltip = "Minor internal buffers (C ± 0.0916 x Range).")
bool   showPivotP           = input.bool(true, "Show Central Pivot (P)", group = grp_levels,
     tooltip = "Central equilibrium pivot level (H + L + C) / 3.")

// ── 03. Institutional Shaded Zones ───────────────────────────────────────────
string grp_zones            = "🎨 03. Institutional Shaded Zones"
bool   showRangeZone        = input.bool(true, "Highlight Range Zone (S3 - R3)", group = grp_zones,
     tooltip = "Shades the 75-80% statistical range equilibrium where institutional mean reversion occurs.")
bool   showBufferZone       = input.bool(true, "Highlight Buffer Zones (R3-R4 & S3-S4)", group = grp_zones,
     tooltip = "Shades the caution / no-trade buffer zones between S3-S4 and R3-R4 where price is in limbo before a breakout or reversal.")
bool   showBullBreakoutZone = input.bool(true, "Highlight Bullish Breakout Zone (R4 - R5)", group = grp_zones,
     tooltip = "Shades the upside expansion runner zone triggered above R4.")
bool   showBearBreakoutZone = input.bool(true, "Highlight Bearish Breakdown Zone (S4 - S5)", group = grp_zones,
     tooltip = "Shades the downside expansion runner zone triggered below S4.")
bool   showBufferLabel      = input.bool(true, "Show 'NO-TRADE ZONE' Label", group = grp_zones,
     tooltip = "Displays a subtle warning badge inside the buffer zones.")

color  rangeZoneColor       = input.color(color.new(#2962ff, 92), "Range Zone (S3-R3) Shading", group = grp_zones)
color  bufferZoneColor      = input.color(color.new(#ff9800, 92), "Buffer Zone (No-Trade) Shading", group = grp_zones)
color  bullBreakColor       = input.color(color.new(#089981, 88), "Bull Breakout (R4-R5) Shading", group = grp_zones)
color  bearBreakColor       = input.color(color.new(#f23645, 88), "Bear Breakdown (S4-S5) Shading", group = grp_zones)

// ── 04. Colors & Styling ─────────────────────────────────────────────────────
string grp_style            = "🌈 04. Colors & Styling"
color  colR5                = input.color(#00e676, "R5 (Target 2)", inline = "r5", group = grp_style)
color  colR4                = input.color(#089981, "R4 (Breakout)", inline = "r4", group = grp_style)
color  colR3                = input.color(#26a69a, "R3 (Resistance)", inline = "r3", group = grp_style)
color  colR2                = input.color(#80cbc4, "R2 (Buffer)", inline = "r2", group = grp_style)
color  colR1                = input.color(#b2dfdb, "R1 (Minor)", inline = "r1", group = grp_style)
color  colPivot             = input.color(#fbc02d, "Central Pivot (P)", inline = "p", group = grp_style)
color  colS1                = input.color(#ffcdd2, "S1 (Minor)", inline = "s1", group = grp_style)
color  colS2                = input.color(#ef9a9a, "S2 (Buffer)", inline = "s2", group = grp_style)
color  colS3                = input.color(#e57373, "S3 (Support)", inline = "s3", group = grp_style)
color  colS4                = input.color(#f23645, "S4 (Breakdown)", inline = "s4", group = grp_style)
color  colS5                = input.color(#d50000, "S5 (Target 2)", inline = "s5", group = grp_style)

bool   showLabels           = input.bool(true, "Show Level Tags & Prices", group = grp_style)
bool   showPricesInLabels   = input.bool(true, "Include Price Value in Tags", group = grp_style)
string labelSizeStr         = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal"], group = grp_style)

// ── 05. Reversal & Breakout Signals ──────────────────────────────────────────
string grp_signals          = "⚡ 05. Real-Time Signal Markers"
bool   showSignals          = input.bool(true, "Show Buy / Sell Signal Markers", group = grp_signals,
     tooltip = "Plots visual reversal triangles at S3/R3 and momentum breakout arrows at R4/S4.")
bool   enableReversalSigs   = input.bool(true, "S3 / R3 Mean Reversion Signals", group = grp_signals)
bool   enableBreakoutSigs   = input.bool(true, "R4 / S4 Trend Breakout Signals", group = grp_signals)
bool   requireClose         = input.bool(true, "Wait for Candle Close (Confirmed Signals)", group = grp_signals,
     tooltip = "When enabled (strongly recommended), signals and Stop Loss projections only trigger when the candle closes. Prevents floating SL lines, premature false alarms, and intrabar repainting.")

// ── 06. Dynamic ATR Stop Loss Engine ──────────────────────────────────────────
string grp_atr_sl           = "06. Dynamic ATR Stop Loss Engine"
bool   showAtrSl            = input.bool(true, "Show Dynamic ATR Stop Loss", group = grp_atr_sl,
     tooltip = "Calculates and plots dynamic Stop Loss levels using ATR + custom buffer points.")
string slAnchorMode         = input.string("Signal Candle (Candle Height + ATR)", "Stop Loss Anchor Mode",
     options = ["Signal Candle (Candle Height + ATR)", "Signal Candle (ATR + Buffer Points)", "Camarilla Level (R3/S3 Static Line)", "Both (Level Line + Signal Candle Tags)"], group = grp_atr_sl,
     tooltip = "• Signal Candle (Candle Height + ATR): Measures full candle height (High-Low) + ATR (e.g. 2.9 + 2.1 = 5.0 pts).\n• Signal Candle (ATR + Buffer Points): Pure volatility buffer (ATR + Buffer points) from entry candle close (e.g. 2.1 + 3.0 = 5.1 pts).\n• Camarilla Level: Horizontal dotted lines anchored to Camarilla levels.\n• Both: Displays horizontal Camarilla lines plus signal candle labels.")
string slTargetLevels       = input.string("S3 & R3 Reversal Levels", "Apply SL To Levels (if Level Mode)",
     options = ["S3 & R3 Reversal Levels", "R4 & S4 Breakout Levels", "Both (Reversals & Breakouts)"], group = grp_atr_sl,
     tooltip = "Choose which Camarilla levels to display dynamic Stop Loss lines for when using Level Mode.")
string slDisplayTrigger     = input.string("When Level is Visited (Touch)", "Level SL Display Trigger",
     options = ["When Level is Visited (Touch)", "When Signal Fires", "Always Show (Static Levels)"], group = grp_atr_sl,
     tooltip = "• When Level is Visited: SL line and label appear only once price touches or trades beyond the level during the session.\n• When Signal Fires: SL line and label appear only after an actual Buy/Sell signal fires.\n• Always Show: Projects SL lines for all selected levels from the session open.")
int    atrLength            = input.int(14, "ATR Length", minval = 1, group = grp_atr_sl,
     tooltip = "Number of bars used for the Average True Range calculation.")
string atrSmoothing         = input.string("RMA", "ATR Smoothing", options = ["RMA", "SMA", "EMA", "WMA"], group = grp_atr_sl,
     tooltip = "Smoothing calculation method matching TradingView native ATR indicator.")
float  atrMultiplier        = input.float(1.0, "ATR Multiplier", minval = 0.1, step = 0.1, group = grp_atr_sl,
     tooltip = "Multiplier applied to the calculated ATR value.")
float  bufferPoints         = input.float(3.0, "Buffer Points (0 = Pure ATR)", minval = 0.0, step = 0.5, group = grp_atr_sl,
     tooltip = "Additional fixed price points added to the ATR stop distance. Set to 0 to use only ATR.")
int    signalSlLineBars     = input.int(10, "Signal SL Line Length (Bars)", minval = 2, maxval = 50, group = grp_atr_sl,
     tooltip = "Number of bars the dotted Stop Loss line extends forward from each signal candle.")
bool   showAtrSlLabels      = input.bool(true, "Show SL Price Labels", group = grp_atr_sl,
     tooltip = "Shows or hides the text tags for the Stop Loss lines.")
string slLabelPos           = input.string("At Current Candle", "Level SL Label Position",
     options = ["At Current Candle", "Right (Future Extension)", "Left (Session Start)"], group = grp_atr_sl,
     tooltip = "Choose where to position the Level Stop Loss price label on the chart.")
bool   showAtrHud           = input.bool(true, "Show On-Chart ATR Status Badge", group = grp_atr_sl,
     tooltip = "Displays a compact on-chart table showing current ATR, Buffer, and Total SL distance.")
string hudPosition          = input.string("Top Right", "Status Badge Position",
     options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = grp_atr_sl)
color  colSl                = input.color(#ef5350, "SL Dotted Line Color", group = grp_atr_sl)





// ============================================================================
// SECTION 2: TIMEFRAME RESOLUTION & CAMARILLA CALCULATIONS
// ============================================================================

// Resolve reference higher timeframe
f_getAutoTf() =>
    if timeframe.isseconds or (timeframe.isintraday and timeframe.multiplier <= 15)
        "D"
    else if timeframe.isintraday and timeframe.multiplier > 15
        "W"
    else
        "M"

string refTf = switch pivotTimeframe
    "Auto (Chart Adaptive)" => f_getAutoTf()
    "Weekly"                => "W"
    "Monthly"               => "M"
    =>                         "D" // "Daily"

// Retrieve previous completed HTF bar HLC (100% Non-Repainting, aligned across entire session)
[prevH, prevL, prevC] = request.security(syminfo.tickerid, refTf, [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)

float htfRange = math.max(prevH - prevL, syminfo.mintick)

// Exact Camarilla Mathematical Equations
float P  = (prevH + prevL + prevC) / 3.0
float R5 = prevC + htfRange * 1.10
float R4 = prevC + htfRange * (1.10 / 2.0)  // 0.55 * Range
float R3 = prevC + htfRange * (1.10 / 4.0)  // 0.275 * Range
float R2 = prevC + htfRange * (1.10 / 6.0)  // 0.1833 * Range
float R1 = prevC + htfRange * (1.10 / 12.0) // 0.0916 * Range

float S1 = prevC - htfRange * (1.10 / 12.0)
float S2 = prevC - htfRange * (1.10 / 6.0)
float S3 = prevC - htfRange * (1.10 / 4.0)
float S4 = prevC - htfRange * (1.10 / 2.0)
float S5 = prevC - htfRange * 1.10

// Dynamic ATR Stop Loss Engine (TradingView Native Matching)
f_atr(int len, string smooth) =>
    float trVal = ta.tr(true)
    switch smooth
        "SMA" => ta.sma(trVal, len)
        "EMA" => ta.ema(trVal, len)
        "WMA" => ta.wma(trVal, len)
        =>       ta.rma(trVal, len)

float curAtr      = f_atr(atrLength, atrSmoothing)
float totalSlDist = (curAtr * atrMultiplier) + bufferPoints

float R3_SL = R3 + totalSlDist
float S3_SL = S3 - totalSlDist
float R4_SL = R4 - totalSlDist
float S4_SL = S4 + totalSlDist

bool isCandleSl = showAtrSl and (slAnchorMode == "Signal Candle (Candle Height + ATR)" or slAnchorMode == "Signal Candle (ATR + Buffer Points)" or slAnchorMode == "Both (Level Line + Signal Candle Tags)")
bool isLevelSl  = showAtrSl and (slAnchorMode == "Camarilla Level (R3/S3 Static Line)" or slAnchorMode == "Both (Level Line + Signal Candle Tags)")

bool isRevSl = isLevelSl and (slTargetLevels == "S3 & R3 Reversal Levels" or slTargetLevels == "Both (Reversals & Breakouts)")
bool isBrkSl = isLevelSl and (slTargetLevels == "R4 & S4 Breakout Levels" or slTargetLevels == "Both (Reversals & Breakouts)")

// Signal Candle Stop Loss Calculations
float sigCandleHeight = high - low
float sigCandleDist   = sigCandleHeight + (curAtr * atrMultiplier)
float sigSellDist     = slAnchorMode == "Signal Candle (ATR + Buffer Points)" ? totalSlDist : sigCandleDist
float sigSellSl       = close + sigSellDist

float sigBuyDist      = slAnchorMode == "Signal Candle (ATR + Buffer Points)" ? totalSlDist : sigCandleDist
float sigBuySl        = close - sigBuyDist



// Period Change Detection
bool isNewPeriod = ta.change(time(refTf)) != 0
var int periodStartBar = 0

// Signal Definitions (Reversals & Breakouts)
bool barConfirmed = not requireClose or barstate.isconfirmed
bool sigS3Buy = barConfirmed and enableReversalSigs and showR3S3 and not isNewPeriod and (low <= S3) and (close > S3) and (close > open)
bool sigR3Sell = barConfirmed and enableReversalSigs and showR3S3 and not isNewPeriod and (high >= R3) and (close < R3) and (close < open)
bool r4Breakout = not isNewPeriod and (close > R4) and (close > open) and (close[1] <= R4 or open <= R4)
bool sigR4BreakBuy = barConfirmed and enableBreakoutSigs and showR4S4 and r4Breakout
bool s4Breakdown = not isNewPeriod and (close < S4) and (close < open) and (close[1] >= S4 or open >= S4)
bool sigS4BreakSell = barConfirmed and enableBreakoutSigs and showR4S4 and s4Breakdown

// Track Level Visitation / Signal Triggered per Session
var bool r3Triggered = false
var bool s3Triggered = false
var bool r4Triggered = false
var bool s4Triggered = false

if isNewPeriod
    periodStartBar := bar_index
    r3Triggered := false
    s3Triggered := false
    r4Triggered := false
    s4Triggered := false

if slDisplayTrigger == "When Level is Visited (Touch)"
    if high >= R3
        r3Triggered := true
    if low <= S3
        s3Triggered := true
    if high >= R4
        r4Triggered := true
    if low <= S4
        s4Triggered := true
else if slDisplayTrigger == "When Signal Fires"
    if sigR3Sell
        r3Triggered := true
    if sigS3Buy
        s3Triggered := true
    if sigR4BreakBuy
        r4Triggered := true
    if sigS4BreakSell
        s4Triggered := true
else
    r3Triggered := true
    s3Triggered := true
    r4Triggered := true
    s4Triggered := true


// ============================================================================
// SECTION 3: CONTINUOUS HISTORICAL PLOTS (ZERO-LAG STEPPED LINES)
// ============================================================================

bool renderHistoricalPlots = displayStyle == "Historical Stepped Lines (Full History)" or displayStyle == "Both (Historical + Projected Active)"

// Step lines break cleanly on period transition without diagonal connectors
plot(renderHistoricalPlots and showR5S5 ? R5 : na, "Hist R5", color = colR5, linewidth = 1, style = plot.style_linebr)
plot(renderHistoricalPlots and showR4S4 ? R4 : na, "Hist R4", color = colR4, linewidth = 2, style = plot.style_linebr)
plot(renderHistoricalPlots and showR3S3 ? R3 : na, "Hist R3", color = colR3, linewidth = 2, style = plot.style_linebr)
plot(renderHistoricalPlots and showR2S2 ? R2 : na, "Hist R2", color = colR2, linewidth = 1, style = plot.style_linebr)
plot(renderHistoricalPlots and showR1S1 ? R1 : na, "Hist R1", color = colR1, linewidth = 1, style = plot.style_linebr)

plot(renderHistoricalPlots and showPivotP ? P : na, "Hist Pivot P", color = colPivot, linewidth = 1, style = plot.style_linebr)

plot(renderHistoricalPlots and showR1S1 ? S1 : na, "Hist S1", color = colS1, linewidth = 1, style = plot.style_linebr)
plot(renderHistoricalPlots and showR2S2 ? S2 : na, "Hist S2", color = colS2, linewidth = 1, style = plot.style_linebr)
plot(renderHistoricalPlots and showR3S3 ? S3 : na, "Hist S3", color = colS3, linewidth = 2, style = plot.style_linebr)
plot(renderHistoricalPlots and showR4S4 ? S4 : na, "Hist S4", color = colS4, linewidth = 2, style = plot.style_linebr)
plot(renderHistoricalPlots and showR5S5 ? S5 : na, "Hist S5", color = colS5, linewidth = 1, style = plot.style_linebr)

plot(renderHistoricalPlots and isRevSl and showR3S3 and r3Triggered ? R3_SL : na, "Hist R3 SL", color = colSl, linewidth = 1, style = plot.style_linebr)
plot(renderHistoricalPlots and isRevSl and showR3S3 and s3Triggered ? S3_SL : na, "Hist S3 SL", color = colSl, linewidth = 1, style = plot.style_linebr)
plot(renderHistoricalPlots and isBrkSl and showR4S4 and r4Triggered ? R4_SL : na, "Hist R4 SL", color = colSl, linewidth = 1, style = plot.style_linebr)
plot(renderHistoricalPlots and isBrkSl and showR4S4 and s4Triggered ? S4_SL : na, "Hist S4 SL", color = colSl, linewidth = 1, style = plot.style_linebr)



// ============================================================================
// SECTION 4: ACTIVE PROJECTION LINES, LABELS & SHADED ZONES
// ============================================================================

bool renderActiveProjections = displayStyle == "Active Period (Projected Lines & Zones)" or displayStyle == "Both (Historical + Projected Active)"

f_lblSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        =>          size.small

var line ln_r5 = na, var line ln_r4 = na, var line ln_r3 = na, var line ln_r2 = na, var line ln_r1 = na
var line ln_p  = na
var line ln_s1 = na, var line ln_s2 = na, var line ln_s3 = na, var line ln_s4 = na, var line ln_s5 = na

var label lb_r5 = na, var label lb_r4 = na, var label lb_r3 = na, var label lb_r2 = na, var label lb_r1 = na
var label lb_p  = na
var label lb_s1 = na, var label lb_s2 = na, var label lb_s3 = na, var label lb_s4 = na, var label lb_s5 = na

var line ln_r3_sl = na, var line ln_s3_sl = na
var line ln_r4_sl = na, var line ln_s4_sl = na

var label lb_r3_sl = na, var label lb_s3_sl = na
var label lb_r4_sl = na, var label lb_s4_sl = na


var box bx_range     = na
var box bx_bufUpper  = na
var box bx_bufLower  = na
var box bx_bullBreak = na
var box bx_bearBreak = na

// Update Single Active Level Function
f_updateActiveLevel(line ln, label lb, bool enabled, float price, color col, string name, int x1, int x2, string lnStyle) =>
    line  retLn = ln
    label retLb = lb

    if renderActiveProjections and enabled and not na(price)
        string linePattern = lnStyle == "Dotted" ? line.style_dotted : (lnStyle == "Dashed" ? line.style_dashed : line.style_solid)
        int    lineWidth   = str.contains(name, "SL") ? 1 : ((str.startswith(name, "R4") or str.startswith(name, "S4") or str.startswith(name, "R3") or str.startswith(name, "S3")) ? 2 : 1)

        if na(retLn)
            retLn := line.new(x1, price, x2, price, color = col, width = lineWidth, style = linePattern)
        else
            line.set_xy1(retLn, x1, price)
            line.set_xy2(retLn, x2, price)

        bool isSl = str.contains(name, "SL")
        bool displayThisLabel = isSl ? showAtrSlLabels : showLabels
        if displayThisLabel
            string txt = isSl ? name + ": " + str.tostring(price, format.mintick) : (showPricesInLabels ? name + " (" + str.tostring(price, format.mintick) + ")" : name)
            
            int lblX = x2
            string lblStyle = label.style_label_left
            if isSl
                if slLabelPos == "At Current Candle"
                    lblX := math.min(bar_index + 2, x2)
                    lblStyle := label.style_label_left
                else if slLabelPos == "Left (Session Start)"
                    lblX := x1
                    lblStyle := label.style_label_right
                else
                    lblX := x2
                    lblStyle := label.style_label_left

            color lblBg = isSl ? color.new(#1e222d, 10) : color.new(col, 100)
            color lblTxt = isSl ? color.white : col

            if na(retLb)
                retLb := label.new(lblX, price, txt, color = lblBg, textcolor = lblTxt, style = lblStyle, size = f_lblSize(labelSizeStr))
            else
                label.set_xy(retLb, lblX, price)
                label.set_text(retLb, txt)
                label.set_color(retLb, lblBg)
                label.set_textcolor(retLb, lblTxt)
                label.set_style(retLb, lblStyle)
        else if not na(retLb)
            label.delete(retLb)
            retLb := na


    else
        if not na(retLn)
            line.delete(retLn)
            retLn := na
        if not na(retLb)
            label.delete(retLb)
            retLb := na
    [retLn, retLb]

if not na(prevC)
    int startX = periodStartBar
    int endX   = bar_index + extendBarsRight

    // Active Projected Lines & Labels
    [r5L, r5B] = f_updateActiveLevel(ln_r5, lb_r5, showR5S5, R5, colR5, "R5 (Target 2)", startX, endX, "Dotted")
    [r4L, r4B] = f_updateActiveLevel(ln_r4, lb_r4, showR4S4, R4, colR4, "R4 (Breakout)", startX, endX, "Solid")
    [r3L, r3B] = f_updateActiveLevel(ln_r3, lb_r3, showR3S3, R3, colR3, "R3 (Resistance)", startX, endX, "Solid")
    [r2L, r2B] = f_updateActiveLevel(ln_r2, lb_r2, showR2S2, R2, colR2, "R2", startX, endX, "Dashed")
    [r1L, r1B] = f_updateActiveLevel(ln_r1, lb_r1, showR1S1, R1, colR1, "R1", startX, endX, "Dotted")

    [pL,  pB]  = f_updateActiveLevel(ln_p,  lb_p,  showPivotP, P,  colPivot, "Pivot (P)", startX, endX, "Dashed")

    [s1L, s1B] = f_updateActiveLevel(ln_s1, lb_s1, showR1S1, S1, colS1, "S1", startX, endX, "Dotted")
    [s2L, s2B] = f_updateActiveLevel(ln_s2, lb_s2, showR2S2, S2, colS2, "S2", startX, endX, "Dashed")
    [s3L, s3B] = f_updateActiveLevel(ln_s3, lb_s3, showR3S3, S3, colS3, "S3 (Support)", startX, endX, "Solid")
    [s4L, s4B] = f_updateActiveLevel(ln_s4, lb_s4, showR4S4, S4, colS4, "S4 (Breakdown)", startX, endX, "Solid")
    [s5L, s5B] = f_updateActiveLevel(ln_s5, lb_s5, showR5S5, S5, colS5, "S5 (Target 2)", startX, endX, "Dotted")

    // Active Projected Dynamic Stop Loss Lines (Dotted UI)
    [r3slL, r3slB] = f_updateActiveLevel(ln_r3_sl, lb_r3_sl, isRevSl and showR3S3 and r3Triggered, R3_SL, colSl, "R3 SL", startX, endX, "Dotted")
    [s3slL, s3slB] = f_updateActiveLevel(ln_s3_sl, lb_s3_sl, isRevSl and showR3S3 and s3Triggered, S3_SL, colSl, "S3 SL", startX, endX, "Dotted")
    [r4slL, r4slB] = f_updateActiveLevel(ln_r4_sl, lb_r4_sl, isBrkSl and showR4S4 and r4Triggered, R4_SL, colSl, "R4 SL", startX, endX, "Dotted")
    [s4slL, s4slB] = f_updateActiveLevel(ln_s4_sl, lb_s4_sl, isBrkSl and showR4S4 and s4Triggered, S4_SL, colSl, "S4 SL", startX, endX, "Dotted")

    ln_r5 := r5L, lb_r5 := r5B
    ln_r4 := r4L, lb_r4 := r4B
    ln_r3 := r3L, lb_r3 := r3B
    ln_r2 := r2L, lb_r2 := r2B
    ln_r1 := r1L, lb_r1 := r1B
    ln_p  := pL,  lb_p  := pB
    ln_s1 := s1L, lb_s1 := s1B
    ln_s2 := s2L, lb_s2 := s2B
    ln_s3 := s3L, lb_s3 := s3B
    ln_s4 := s4L, lb_s4 := s4B
    ln_s5 := s5L, lb_s5 := s5B

    ln_r3_sl := r3slL, lb_r3_sl := r3slB
    ln_s3_sl := s3slL, lb_s3_sl := s3slB
    ln_r4_sl := r4slL, lb_r4_sl := r4slB
    ln_s4_sl := s4slL, lb_s4_sl := s4slB


    // Active Shaded Institutional Zones
    if renderActiveProjections and showRangeZone and showR3S3
        if na(bx_range)
            bx_range := box.new(startX, R3, endX, S3, border_width = 0, bgcolor = rangeZoneColor)
        else
            box.set_left(bx_range, startX)
            box.set_right(bx_range, endX)
            box.set_top(bx_range, R3)
            box.set_bottom(bx_range, S3)
    else if not na(bx_range)
        box.delete(bx_range)
        bx_range := na

    // Buffer Zones (Caution / No-Trade Zones: R3-R4 & S3-S4)
    string bufTxt    = showBufferLabel ? "⚠️ NO-TRADE ZONE" : ""
    color  bufTxtCol = color.new(#ff9800, 25)

    if renderActiveProjections and showBufferZone and showR3S3 and showR4S4
        // Upper Buffer Zone (R3 to R4)
        if na(bx_bufUpper)
            bx_bufUpper := box.new(startX, R4, endX, R3, border_width = 0, bgcolor = bufferZoneColor,
                                   text = bufTxt, text_size = size.tiny, text_color = bufTxtCol,
                                   text_halign = text.align_right, text_valign = text.align_center)
        else
            box.set_left(bx_bufUpper, startX), box.set_right(bx_bufUpper, endX)
            box.set_top(bx_bufUpper, R4), box.set_bottom(bx_bufUpper, R3)
            box.set_bgcolor(bx_bufUpper, bufferZoneColor)
            box.set_text(bx_bufUpper, bufTxt)
            box.set_text_color(bx_bufUpper, bufTxtCol)

        // Lower Buffer Zone (S4 to S3)
        if na(bx_bufLower)
            bx_bufLower := box.new(startX, S3, endX, S4, border_width = 0, bgcolor = bufferZoneColor,
                                   text = bufTxt, text_size = size.tiny, text_color = bufTxtCol,
                                   text_halign = text.align_right, text_valign = text.align_center)
        else
            box.set_left(bx_bufLower, startX), box.set_right(bx_bufLower, endX)
            box.set_top(bx_bufLower, S3), box.set_bottom(bx_bufLower, S4)
            box.set_bgcolor(bx_bufLower, bufferZoneColor)
            box.set_text(bx_bufLower, bufTxt)
            box.set_text_color(bx_bufLower, bufTxtCol)
    else
        if not na(bx_bufUpper)
            box.delete(bx_bufUpper), bx_bufUpper := na
        if not na(bx_bufLower)
            box.delete(bx_bufLower), bx_bufLower := na

    if renderActiveProjections and showBullBreakoutZone and showR4S4 and showR5S5
        if na(bx_bullBreak)
            bx_bullBreak := box.new(startX, R5, endX, R4, border_width = 0, bgcolor = bullBreakColor)
        else
            box.set_left(bx_bullBreak, startX)
            box.set_right(bx_bullBreak, endX)
            box.set_top(bx_bullBreak, R5)
            box.set_bottom(bx_bullBreak, R4)
    else if not na(bx_bullBreak)
        box.delete(bx_bullBreak)
        bx_bullBreak := na

    if renderActiveProjections and showBearBreakoutZone and showR4S4 and showR5S5
        if na(bx_bearBreak)
            bx_bearBreak := box.new(startX, S4, endX, S5, border_width = 0, bgcolor = bearBreakColor)
        else
            box.set_left(bx_bearBreak, startX)
            box.set_right(bx_bearBreak, endX)
            box.set_top(bx_bearBreak, S4)
            box.set_bottom(bx_bearBreak, S5)
    else if not na(bx_bearBreak)
        box.delete(bx_bearBreak)
        bx_bearBreak := na


// ============================================================================
// SECTION 5: REAL-TIME REVERSAL & BREAKOUT SIGNALS
// ============================================================================

plotshape(showSignals and sigS3Buy, title = "S3 Reversal Buy", style = shape.triangleup, location = location.belowbar,
     color = #00e676, size = size.small, text = "S3 BUY", textcolor = color.white)
if showSignals and sigS3Buy and isCandleSl
    line.new(bar_index, sigBuySl, bar_index + signalSlLineBars, sigBuySl, color = colSl, style = line.style_dotted, width = 1)
    if showAtrSlLabels
        label.new(bar_index, sigBuySl, "SL: " + str.tostring(sigBuySl, format.mintick) + " (-" + str.tostring(sigBuyDist, format.mintick) + ")", color = color.new(#1e222d, 10), textcolor = color.white, style = label.style_label_up, size = f_lblSize(labelSizeStr))

plotshape(showSignals and sigR3Sell, title = "R3 Reversal Sell", style = shape.triangledown, location = location.abovebar,
     color = #ff1744, size = size.small, text = "R3 SELL", textcolor = color.white)
if showSignals and sigR3Sell and isCandleSl
    line.new(bar_index, sigSellSl, bar_index + signalSlLineBars, sigSellSl, color = colSl, style = line.style_dotted, width = 1)
    if showAtrSlLabels
        label.new(bar_index, sigSellSl, "SL: " + str.tostring(sigSellSl, format.mintick) + " (+" + str.tostring(sigSellDist, format.mintick) + ")", color = color.new(#1e222d, 10), textcolor = color.white, style = label.style_label_down, size = f_lblSize(labelSizeStr))

plotshape(showSignals and sigR4BreakBuy, title = "R4 Breakout Buy", style = shape.arrowup, location = location.belowbar,
     color = #00b0ff, size = size.small, text = "R4 BREAK", textcolor = color.white)
if showSignals and sigR4BreakBuy and isCandleSl
    line.new(bar_index, sigBuySl, bar_index + signalSlLineBars, sigBuySl, color = colSl, style = line.style_dotted, width = 1)
    if showAtrSlLabels
        label.new(bar_index, sigBuySl, "SL: " + str.tostring(sigBuySl, format.mintick) + " (-" + str.tostring(sigBuyDist, format.mintick) + ")", color = color.new(#1e222d, 10), textcolor = color.white, style = label.style_label_up, size = f_lblSize(labelSizeStr))

plotshape(showSignals and sigS4BreakSell, title = "S4 Breakdown Sell", style = shape.arrowdown, location = location.abovebar,
     color = #ff9100, size = size.small, text = "S4 BREAK", textcolor = color.white)
if showSignals and sigS4BreakSell and isCandleSl
    line.new(bar_index, sigSellSl, bar_index + signalSlLineBars, sigSellSl, color = colSl, style = line.style_dotted, width = 1)
    if showAtrSlLabels
        label.new(bar_index, sigSellSl, "SL: " + str.tostring(sigSellSl, format.mintick) + " (+" + str.tostring(sigSellDist, format.mintick) + ")", color = color.new(#1e222d, 10), textcolor = color.white, style = label.style_label_down, size = f_lblSize(labelSizeStr))



// ============================================================================
// SECTION 6: TRADINGVIEW ALERT CONDITIONS
// ============================================================================

alertcondition(sigS3Buy, "Camarilla: S3 Bullish Reversal", "Camarilla S3 Bullish Reversal on {{ticker}} at {{close}}")
alertcondition(sigR3Sell, "Camarilla: R3 Bearish Reversal", "Camarilla R3 Bearish Reversal on {{ticker}} at {{close}}")
alertcondition(sigR4BreakBuy, "Camarilla: R4 Bullish Breakout", "Camarilla R4 Bullish Breakout on {{ticker}} at {{close}}")
alertcondition(sigS4BreakSell, "Camarilla: S4 Bearish Breakdown", "Camarilla S4 Bearish Breakdown on {{ticker}} at {{close}}")

// ============================================================================
// SECTION 7: ON-CHART ATR STATUS BADGE (HUD)
// ============================================================================

f_hudPos(string p) =>
    switch p
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        =>                position.top_right

var table atrTbl = na
if barstate.islast
    if showAtrHud and showAtrSl
        if na(atrTbl)
            atrTbl := table.new(f_hudPos(hudPosition), 1, 2, bgcolor = color.new(#111827, 20), border_color = color.new(#374151, 40), border_width = 1)
        string atrStr = str.tostring(curAtr, format.mintick)
        string bufStr = str.tostring(bufferPoints, format.mintick)
        string totStr = str.tostring(totalSlDist, format.mintick)
        string line1 = "ATR (" + str.tostring(atrLength) + " " + atrSmoothing + "): " + atrStr + " pts"
        string line2 = "Buffer: " + bufStr + " | Total SL: " + totStr + " pts"
        table.cell(atrTbl, 0, 0, line1, text_color = color.white, text_size = size.small, bgcolor = color.new(#1f2937, 20))
        table.cell(atrTbl, 0, 1, line2, text_color = colSl, text_size = size.small, bgcolor = color.new(#111827, 20))
    else if not na(atrTbl)
        table.delete(atrTbl)
        atrTbl := na
````
