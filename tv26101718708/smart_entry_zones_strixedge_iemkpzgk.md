# Smart Entry Zones [StrixEDGE]

- url: https://www.tradingview.com/script/iemKPzGk-Smart-Entry-Zones-StrixEDGE/
- type: indicator
- pine_id: PUB;ee54d67e40704e6c9542a0858a7bec00
- version: 1.0

## Description

█  OVERVIEW

StrixEDGE Smart Entry Zones is a multi-layered trend-following indicator that generates clearly defined trade setups with automatic Entry, Take Profit (TP 1–3), and Stop Loss (SL) levels — all plotted directly on the chart with exact prices and percentage targets.

The indicator is built on three independent analytical layers that work together to assess both timing and conviction:

  •  Supertrend — determines trend direction and triggers trade levels on each confirmed flip
  •  Fisher Transform — identifies overbought/oversold extremes for timing quality
  •  Chaikin Money Flow (CMF) — confirms whether volume supports the directional move

Trade levels appear the moment the Supertrend changes direction. The Fisher Transform and CMF score the quality of each setup on a scale of 1/3 to 3/3 conditions, so you always know how much confirmation backs the signal.


█  HOW IT WORKS

When the Supertrend flips from bearish to bullish, the indicator draws a LONG setup:
  •  Entry — at the close of the flip candle
  •  TP 1, TP 2, TP 3 — calculated as multiples of the risk (SL distance), based on your chosen Risk:Reward ratios
  •  SL — placed below entry at a distance of ATR × your chosen multiplier

When the Supertrend flips from bullish to bearish, a SHORT setup is drawn with the same structure, mirrored.

Each level displays the exact price and the percentage distance from entry (e.g., +4.12%, −2.27%), so you can instantly assess the reward-to-risk profile of every trade.


█  LIVE HIT DETECTION

The indicator tracks price in real time against active levels:
  •  ✓  appears on the chart when price reaches TP 1, TP 2, or TP 3
  •  ✕  appears when price hits the Stop Loss
  •  Once SL is hit, the trade is considered closed — no further TP checks
  •  Hit status is also reflected in the data table (✓ or ✕ next to each level)

This gives you a clear visual record of how each setup performed without leaving the chart.


█  THE THREE CONFIRMATION LAYERS

1. Supertrend (Direction)
   Uses ATR-based dynamic support/resistance to define the prevailing trend. A flip in direction is the primary trigger for new trade levels. Configurable via ATR Period and Multiplier.

2. Fisher Transform (Timing)
   A manually calculated oscillator that normalizes price position within its recent range and applies a logarithmic transformation to amplify extremes. When the Fisher value crosses its signal line at overbought or oversold levels, it confirms favorable entry timing. The threshold is adjustable.

3. Chaikin Money Flow (Volume)
   Measures the accumulation/distribution pressure over a configurable period. Positive CMF above the threshold confirms buying pressure (for longs); negative CMF below the threshold confirms selling pressure (for shorts).

The Conditions counter in the data table shows how many of the three layers support the current setup (1/3, 2/3, or 3/3). A 3/3 reading means trend, timing, and volume are all aligned — the highest-conviction scenario.


█  SETTINGS

Core Parameters:
  •  Supertrend ATR Period (default: 10) — lookback for trend calculation
  •  Supertrend Multiplier (default: 3.0) — band width; lower = more signals, higher = fewer but stronger
  •  Fisher Transform Lookback (default: 10) — normalization window
  •  Fisher Extreme Threshold (default: 1.0) — defines overbought/oversold boundary
  •  CMF Period (default: 20) — volume pressure measurement window
  •  Minimum CMF Threshold (default: 0.05) — minimum reading for volume confirmation

Trade Levels:
  •  ATR Period for Levels (default: 14) — ATR used to calculate TP/SL distances
  •  SL Distance in ATR multiples (default: 1.5×) — how far the stop is placed
  •  TP1 / TP2 / TP3 Risk:Reward (defaults: 1.0 / 2.0 / 3.0) — each TP as a multiple of the SL distance
  •  Line Length in bars (default: 30) — how far the level lines extend on chart
  •  Show Trade Levels — toggle lines and labels on/off

Table Settings:
  •  Size (Tiny to Huge) and Position (any corner) — fully customizable
  •  Show/Hide toggle


█  DATA TABLE

A dark-header Style A panel displays all key metrics at a glance:
  •  Trend direction and current Fisher/CMF readings
  •  Conditions score (1/3, 2/3, or 3/3)
  •  Active trade direction (LONG ▲ or SHORT ▼)
  •  Entry price, TP 1–3 with percentage targets, and SL with percentage risk
  •  Live hit status: ✓ next to reached TPs, ✕ next to triggered SL


█  NOTES

  •  No repainting — all signals are based on confirmed bar closes. The Supertrend flip and Fisher Transform are calculated on closed data only.
  •  The Fisher Transform is manually implemented (not a built-in function) to ensure full transparency and consistency.
  •  This indicator is an analytical tool, not financial advice. Always use proper risk management and confirm setups with your own analysis.


█  ALERTS

Two built-in alert conditions:
  •  Supertrend Long — fires when Supertrend flips bullish
  •  Supertrend Short — fires when Supertrend flips bearish

Set alerts on any timeframe to receive notifications when new trade setups appear.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator('Smart Entry Zones [StrixEDGE]', overlay=true, max_labels_count=200, max_lines_count=100)

// ═══ INPUTS ═══

stPeriod        = input.int(10, title="Supertrend ATR Period", minval=1, maxval=100, tooltip="ATR lookback for Supertrend.", group="⚙️ Core Parameters")
stMult          = input.float(3.0, title="Supertrend Multiplier", minval=0.5, maxval=10.0, step=0.1, tooltip="ATR multiplier for Supertrend.", group="⚙️ Core Parameters")
fisherPeriod    = input.int(10, title="Fisher Transform Lookback", minval=2, maxval=100, tooltip="Fisher Transform normalization window.", group="⚙️ Core Parameters")
fisherThreshold = input.float(1.0, title="Fisher Extreme Threshold", minval=0.3, maxval=5.0, step=0.1, tooltip="Threshold for overbought/oversold.", group="⚙️ Core Parameters")
cmfPeriod       = input.int(20, title="CMF Period", minval=2, maxval=100, tooltip="Chaikin Money Flow lookback.", group="⚙️ Core Parameters")
cmfMin          = input.float(0.05, title="Minimum CMF Threshold", minval=0.01, maxval=0.50, step=0.01, tooltip="Minimum absolute CMF for volume confirmation.", group="⚙️ Core Parameters")

atrPeriod       = input.int(14, title="ATR Period (Levels)", minval=1, maxval=100, tooltip="ATR period for TP/SL distance.", group="🎯 Trade Levels")
slAtrMult       = input.float(1.5, title="SL Distance (ATR ×)", minval=0.5, maxval=5.0, step=0.1, tooltip="Stop Loss = Entry ± ATR × this value.", group="🎯 Trade Levels")
tp1RR           = input.float(1.0, title="TP1 Risk:Reward", minval=0.5, maxval=10.0, step=0.5, tooltip="TP1 as multiple of SL distance.", group="🎯 Trade Levels")
tp2RR           = input.float(2.0, title="TP2 Risk:Reward", minval=0.5, maxval=10.0, step=0.5, tooltip="TP2 as multiple of SL distance.", group="🎯 Trade Levels")
tp3RR           = input.float(3.0, title="TP3 Risk:Reward", minval=0.5, maxval=10.0, step=0.5, tooltip="TP3 as multiple of SL distance.", group="🎯 Trade Levels")
showLevels      = input.bool(true, title="Show Trade Levels", tooltip="Draw Entry, TP1-3, SL lines.", group="🎯 Trade Levels")
lineBars        = input.int(30, title="Line Length (bars)", minval=5, maxval=200, step=5, tooltip="How many bars the lines extend from signal candle.", group="🎯 Trade Levels")

showSupertrend  = input.bool(true, title="Show Supertrend Line", tooltip="Plot Supertrend line on chart.", group="🎨 Visual Settings")

tableSize = input.string("Normal", title="📐 Table Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], tooltip="Data table display size.", group="📊 Table Settings")
tablePos  = input.string("Top Right", title="📍 Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], tooltip="Data table position.", group="📊 Table Settings")
showTable = input.bool(true, title="Show Table", tooltip="Toggle data table.", group="📊 Table Settings")

tSize = switch tableSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.normal

tPos = switch tablePos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right


// ═══ CALCULATIONS ═══

[stValue, stDirection] = ta.supertrend(stMult, stPeriod)
bool isBullishTrend = stDirection < 0
bool isBearishTrend = stDirection > 0

bool stBullFlip = isBullishTrend and not isBullishTrend[1]
bool stBearFlip = isBearishTrend and not isBearishTrend[1]

// Fisher Transform (manual)
float ftHighest = ta.highest(high, fisherPeriod)
float ftLowest  = ta.lowest(low, fisherPeriod)
float ftRange   = math.max(ftHighest - ftLowest, 0.0001)
float ftRaw     = 2.0 * ((close - ftLowest) / ftRange - 0.5)

var float ftSmoothed = 0.0
ftSmoothed := 0.33 * ftRaw + 0.67 * nz(ftSmoothed[1])
float ftClamped = math.max(-0.999, math.min(0.999, ftSmoothed))

var float fisherValue = 0.0
float fisherRaw = 0.5 * math.log((1.0 + ftClamped) / (1.0 - ftClamped))
fisherValue := 0.5 * fisherRaw + 0.5 * nz(fisherValue[1])
float fisherSignal = fisherValue[1]

bool isOversold   = fisherValue < -fisherThreshold and ta.crossover(fisherValue, fisherSignal)
bool isOverbought = fisherValue >  fisherThreshold and ta.crossunder(fisherValue, fisherSignal)

// CMF (manual)
float mfMult   = high != low ? ((close - low) - (high - close)) / (high - low) : 0.0
float mfVolume = mfMult * volume
float cmfValue = math.sum(volume, cmfPeriod) != 0 ? math.sum(mfVolume, cmfPeriod) / math.sum(volume, cmfPeriod) : 0.0
bool hasBuyingPressure  = cmfValue > cmfMin
bool hasSellingPressure = cmfValue < -cmfMin

float atrValue = ta.atr(atrPeriod)

// Conditions count
int conditionsLong  = (isBullishTrend ? 1 : 0) + (isOversold ? 1 : 0) + (hasBuyingPressure ? 1 : 0)
int conditionsShort = (isBearishTrend ? 1 : 0) + (isOverbought ? 1 : 0) + (hasSellingPressure ? 1 : 0)
int conditionsMet   = isBullishTrend ? conditionsLong : conditionsShort


// ═══ TRADE LEVELS ═══

var float entryPrice = na
var float tp1Price   = na
var float tp2Price   = na
var float tp3Price   = na
var float slPrice    = na
var bool  lastIsLong = false

// Percentage vars
var float tp1Pct = na
var float tp2Pct = na
var float tp3Pct = na
var float slPct  = na

// Hit detection flags
var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false
var bool slHit  = false

// Drawing objects — level lines & labels
var line  entryLine = na
var line  tp1Line   = na
var line  tp2Line   = na
var line  tp3Line   = na
var line  slLine    = na
var label entryLbl  = na
var label tp1Lbl    = na
var label tp2Lbl    = na
var label tp3Lbl    = na
var label slLbl     = na

// Drawing objects — hit markers
var label tp1HitLbl = na
var label tp2HitLbl = na
var label tp3HitLbl = na
var label slHitLbl  = na

// ── New signal: calculate levels, reset hits, draw lines ──
if stBullFlip or stBearFlip
    // Delete old drawings
    line.delete(entryLine),  line.delete(tp1Line),  line.delete(tp2Line),  line.delete(tp3Line),  line.delete(slLine)
    label.delete(entryLbl),  label.delete(tp1Lbl),  label.delete(tp2Lbl),  label.delete(tp3Lbl),  label.delete(slLbl)
    label.delete(tp1HitLbl), label.delete(tp2HitLbl), label.delete(tp3HitLbl), label.delete(slHitLbl)

    // Reset hit flags
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    slHit  := false

    float slDist = atrValue * slAtrMult

    if stBullFlip
        lastIsLong := true
        entryPrice := close
        slPrice    := close - slDist
        tp1Price   := close + slDist * tp1RR
        tp2Price   := close + slDist * tp2RR
        tp3Price   := close + slDist * tp3RR
        tp1Pct := (tp1Price - close) / close * 100
        tp2Pct := (tp2Price - close) / close * 100
        tp3Pct := (tp3Price - close) / close * 100
        slPct  := (slPrice - close) / close * 100

    if stBearFlip
        lastIsLong := false
        entryPrice := close
        slPrice    := close + slDist
        tp1Price   := close - slDist * tp1RR
        tp2Price   := close - slDist * tp2RR
        tp3Price   := close - slDist * tp3RR
        tp1Pct := (close - tp1Price) / close * 100
        tp2Pct := (close - tp2Price) / close * 100
        tp3Pct := (close - tp3Price) / close * 100
        slPct  := -(slPrice - close) / close * 100

    if showLevels
        string dir = stBullFlip ? "LONG" : "SHORT"
        int x2 = bar_index + lineBars

        // Format percentage strings
        string tp1PctS = "  (+" + str.tostring(tp1Pct, "#.##") + "%)"
        string tp2PctS = "  (+" + str.tostring(tp2Pct, "#.##") + "%)"
        string tp3PctS = "  (+" + str.tostring(tp3Pct, "#.##") + "%)"
        string slPctS  = "  (" + str.tostring(slPct, "#.##") + "%)"

        entryLine := line.new(bar_index, entryPrice, x2, entryPrice, color=#1D9BF0, width=2, style=line.style_solid)
        tp1Line   := line.new(bar_index, tp1Price,   x2, tp1Price,   color=#00BA7C, width=1, style=line.style_dashed)
        tp2Line   := line.new(bar_index, tp2Price,   x2, tp2Price,   color=#00BA7C, width=1, style=line.style_dashed)
        tp3Line   := line.new(bar_index, tp3Price,   x2, tp3Price,   color=#006D4E, width=1, style=line.style_dashed)
        slLine    := line.new(bar_index, slPrice,    x2, slPrice,    color=#F4212E, width=2, style=line.style_dashed)

        entryLbl := label.new(x2, entryPrice, dir + "  Entry  " + str.tostring(entryPrice, format.mintick),                                        style=label.style_label_left, color=#1D9BF0, textcolor=color.white, size=size.small)
        tp1Lbl   := label.new(x2, tp1Price,   dir + "  TP 1  " + str.tostring(tp1Price, format.mintick) + tp1PctS,   style=label.style_label_left, color=#00BA7C, textcolor=color.white, size=size.small)
        tp2Lbl   := label.new(x2, tp2Price,   dir + "  TP 2  " + str.tostring(tp2Price, format.mintick) + tp2PctS,   style=label.style_label_left, color=#00BA7C, textcolor=color.white, size=size.small)
        tp3Lbl   := label.new(x2, tp3Price,   dir + "  TP 3  " + str.tostring(tp3Price, format.mintick) + tp3PctS,   style=label.style_label_left, color=#006D4E, textcolor=color.white, size=size.small)
        slLbl    := label.new(x2, slPrice,    dir + "  SL  "   + str.tostring(slPrice, format.mintick) + slPctS,      style=label.style_label_left, color=#F4212E, textcolor=color.white, size=size.small)


// ═══ HIT DETECTION ═══

// Check if price reached TP or SL levels (only while trade is open)
if not na(entryPrice) and not slHit
    if lastIsLong
        // TP hits — check high reaching target
        if not tp1Hit and high >= tp1Price
            tp1Hit := true
            tp1HitLbl := label.new(bar_index, tp1Price, "✓ TP 1", style=label.style_label_down, color=#00BA7C, textcolor=color.white, size=size.tiny)
        if not tp2Hit and high >= tp2Price
            tp2Hit := true
            tp2HitLbl := label.new(bar_index, tp2Price, "✓ TP 2", style=label.style_label_down, color=#00BA7C, textcolor=color.white, size=size.tiny)
        if not tp3Hit and high >= tp3Price
            tp3Hit := true
            tp3HitLbl := label.new(bar_index, tp3Price, "✓ TP 3", style=label.style_label_down, color=#006D4E, textcolor=color.white, size=size.tiny)
        // SL hit — check low reaching stop
        if low <= slPrice
            slHit := true
            slHitLbl := label.new(bar_index, slPrice, "✕ SL", style=label.style_label_up, color=#F4212E, textcolor=color.white, size=size.tiny)
    else
        // SHORT: TP hits — check low reaching target
        if not tp1Hit and low <= tp1Price
            tp1Hit := true
            tp1HitLbl := label.new(bar_index, tp1Price, "✓ TP 1", style=label.style_label_up, color=#00BA7C, textcolor=color.white, size=size.tiny)
        if not tp2Hit and low <= tp2Price
            tp2Hit := true
            tp2HitLbl := label.new(bar_index, tp2Price, "✓ TP 2", style=label.style_label_up, color=#00BA7C, textcolor=color.white, size=size.tiny)
        if not tp3Hit and low <= tp3Price
            tp3Hit := true
            tp3HitLbl := label.new(bar_index, tp3Price, "✓ TP 3", style=label.style_label_up, color=#006D4E, textcolor=color.white, size=size.tiny)
        // SL hit
        if high >= slPrice
            slHit := true
            slHitLbl := label.new(bar_index, slPrice, "✕ SL", style=label.style_label_down, color=#F4212E, textcolor=color.white, size=size.tiny)


// ═══ VISUALIZATION ═══

color stColor = isBullishTrend ? #00BA7C : #F4212E
plot(showSupertrend ? stValue : na, title="Supertrend", color=stColor, linewidth=2)

plotshape(stBullFlip, title="Long Signal",  style=shape.diamond, location=location.belowbar, color=#00BA7C, size=size.normal, text="LONG",  textcolor=#00BA7C)
plotshape(stBearFlip, title="Short Signal", style=shape.diamond, location=location.abovebar, color=#F4212E, size=size.normal, text="SHORT", textcolor=#F4212E)


// ═══ DATA TABLE ═══

var color HEADER_BG  = color.rgb(26, 26, 46)
var color HEADER_TXT = color.white
var color SUB_TXT    = color.rgb(158, 158, 158)
var color ROW_BG     = color.white
var color LBL_CLR    = color.rgb(102, 102, 102)
var color BRD_CLR    = color.rgb(240, 240, 240)
var color BULL_CLR   = color.rgb(0, 176, 124)
var color BEAR_CLR   = color.rgb(229, 57, 53)
var color NEUT_CLR   = color.rgb(102, 102, 102)
var color WARN_CLR   = color.rgb(247, 147, 26)
var color BLUE_CLR   = color.rgb(29, 155, 240)

if barstate.islast and showTable
    string trdTxt = isBullishTrend ? "BULLISH ▲" : "BEARISH ▼"
    color  trdClr = isBullishTrend ? BULL_CLR : BEAR_CLR

    color fClr = fisherValue < -fisherThreshold ? BULL_CLR : fisherValue > fisherThreshold ? BEAR_CLR : NEUT_CLR
    color cClr = hasBuyingPressure ? BULL_CLR : hasSellingPressure ? BEAR_CLR : NEUT_CLR

    string condTxt = str.tostring(conditionsMet) + "/3"
    color  condClr = conditionsMet >= 3 ? BULL_CLR : conditionsMet == 2 ? WARN_CLR : NEUT_CLR

    string dirTxt = not na(entryPrice) ? (lastIsLong ? "LONG ▲" : "SHORT ▼") : "—"
    color  dirClr = not na(entryPrice) ? (lastIsLong ? BULL_CLR : BEAR_CLR) : NEUT_CLR

    // Price + percentage strings
    string eTxt  = not na(entryPrice) ? str.tostring(entryPrice, format.mintick) : "—"
    string t1Txt = not na(tp1Price) ? str.tostring(tp1Price, format.mintick) + "  +" + str.tostring(tp1Pct, "#.##") + "%" : "—"
    string t2Txt = not na(tp2Price) ? str.tostring(tp2Price, format.mintick) + "  +" + str.tostring(tp2Pct, "#.##") + "%" : "—"
    string t3Txt = not na(tp3Price) ? str.tostring(tp3Price, format.mintick) + "  +" + str.tostring(tp3Pct, "#.##") + "%" : "—"
    string sTxt  = not na(slPrice)  ? str.tostring(slPrice, format.mintick) + "  " + str.tostring(slPct, "#.##") + "%" : "—"

    // Hit status indicators
    string t1Hit = tp1Hit ? "  ✓" : ""
    string t2Hit = tp2Hit ? "  ✓" : ""
    string t3Hit = tp3Hit ? "  ✓" : ""
    string sHit  = slHit  ? "  ✕" : ""

    color eClr  = not na(entryPrice) ? BLUE_CLR : NEUT_CLR
    color tpClr = not na(tp1Price)   ? BULL_CLR : NEUT_CLR
    color sClr  = not na(slPrice)    ? BEAR_CLR : NEUT_CLR

    var tbl = table.new(tPos, columns=2, rows=11, bgcolor=ROW_BG, border_color=BRD_CLR, border_width=1, frame_color=HEADER_BG, frame_width=0)

    table.cell(tbl, 0, 0, "StrixEDGE Smart Entry Zones", bgcolor=HEADER_BG, text_color=HEADER_TXT, text_size=tSize, text_halign=text.align_left, text_font_family=font.family_default)
    table.cell(tbl, 1, 0, syminfo.ticker + " · " + timeframe.period, bgcolor=HEADER_BG, text_color=SUB_TXT, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_default)

    table.cell(tbl, 0, 1, "Trend",      bgcolor=ROW_BG, text_color=LBL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 1, trdTxt,       bgcolor=ROW_BG, text_color=trdClr,  text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    table.cell(tbl, 0, 2, "Fisher",     bgcolor=ROW_BG, text_color=LBL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 2, str.tostring(fisherValue, "#.##"), bgcolor=ROW_BG, text_color=fClr, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    table.cell(tbl, 0, 3, "CMF",        bgcolor=ROW_BG, text_color=LBL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 3, str.tostring(cmfValue, "#.###"), bgcolor=ROW_BG, text_color=cClr, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    table.cell(tbl, 0, 4, "Conditions", bgcolor=ROW_BG, text_color=LBL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 4, condTxt,      bgcolor=ROW_BG, text_color=condClr, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    table.cell(tbl, 0, 5, "Direction",  bgcolor=ROW_BG, text_color=LBL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 5, dirTxt,       bgcolor=ROW_BG, text_color=dirClr,  text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    table.cell(tbl, 0, 6, "Entry",      bgcolor=ROW_BG, text_color=LBL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 6, eTxt,         bgcolor=ROW_BG, text_color=eClr,    text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    table.cell(tbl, 0, 7, "TP 1",       bgcolor=ROW_BG, text_color=LBL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 7, t1Txt + t1Hit, bgcolor=ROW_BG, text_color=tpClr, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    table.cell(tbl, 0, 8, "TP 2",       bgcolor=ROW_BG, text_color=LBL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 8, t2Txt + t2Hit, bgcolor=ROW_BG, text_color=tpClr, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    table.cell(tbl, 0, 9, "TP 3",       bgcolor=ROW_BG, text_color=LBL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 9, t3Txt + t3Hit, bgcolor=ROW_BG, text_color=tpClr, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    table.cell(tbl, 0, 10, "SL",        bgcolor=ROW_BG, text_color=LBL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 10, sTxt + sHit,  bgcolor=ROW_BG, text_color=sClr,  text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)


// ═══ ALERTS ═══

alertcondition(stBullFlip, title="Supertrend Long",  message="StrixEDGE: Supertrend flipped BULLISH — Long levels active")
alertcondition(stBearFlip, title="Supertrend Short", message="StrixEDGE: Supertrend flipped BEARISH — Short levels active")
````
