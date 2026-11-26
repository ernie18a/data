# Market Direction Model (developed by Dr. K.)

- url: https://www.tradingview.com/script/jvfPUEnL/
- type: indicator
- pine_id: PUB;ad25d3df6bfa477f8352aaa734342e56
- version: 1.0

## Description

Market Direction Model (by Chris Kacher as known as: Dr. K.)
(Recommended to be used on Nasdaq Composite Index IXIC or S&P500)

- Follow-Through Day (FTD): Gain >= 2% on higher volume between day 4 and 7 of a rally attempt.
- Distribution Day (DD): Down >= 0.2% on higher volume.
- Sell Signal: When price breaks the low of the 5th distribution day within the last 20 days.
- Market Phases: Accumulation, Markup, Distribution, Markdown with corresponding trading posture.

Never forget: You - only you are responsible for your Trading decisions!
(I built this how I understand the rules of the Dr. K. model - I don´t claim that there are no mistakes)

If you are interested in more Information about Dr. K. and his work:
https://www.virtueofselfishinvesting.com

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © OktayUruncu

//@version=6
// Market Direction Model (Kacher Method - Official Rules)
//
// Follow-Through Day (FTD): Gain >= 2% on higher volume between day 4 and 7 of a rally attempt.
// Distribution Day (DD): Down >= 0.2% on higher volume.
// Sell Signal: When price breaks the low of the 5th distribution day within the last 20 days.
// Market Phases: Accumulation, Markup, Distribution, Markdown with corresponding trading posture.
//
// Author: [OktayUruncu]
// Version: 2.2 (Fixed FTD detection using barssince)
// Date: 2025

indicator("Kacher Market Direction Model", overlay=true, precision=2)

// ------------------------------------------------------------------
// 1. MODEL PARAMETERS
// ------------------------------------------------------------------
distDownPct = input.float(-0.2, "Dist Day Down %", tooltip="Minimum decline for Distribution Day.") / 100
ftdGainPct = input.float(2.0, "FTD Gain %", tooltip="Minimum gain for Follow-Through Day (official 2%).") / 100
distLookback = input.int(20, "Dist Days Lookback", tooltip="Days to count Distribution Days.")
ftdRallyLookback = input.int(15, "FTD Rally Lookback", tooltip="Bars to look for rally low.")
requireHigherVolFTD = input.bool(true, "Higher Vol for FTD", tooltip="Require volume higher than previous day (official).")

// ------------------------------------------------------------------
// 2. VISUAL TOGGLES
// ------------------------------------------------------------------
showFTDlabel = input.bool(true, "Show FTD Label", tooltip="Show green label on FTD.")
showDistLabel = input.bool(true, "Show Dist Label", tooltip="Show red label on Distribution Day.")
showTable = input.bool(true, "Show Status Table", tooltip="Show simplified table with phase and posture.")

// ------------------------------------------------------------------
// 3. FIXED PRICE LEVELS (you can also enable auto offset if desired)
// ------------------------------------------------------------------
ftdFixedPrice = input.float(20000, "FTD Price Level", step=100, tooltip="Price level for FTD label.")
distFixedPrice = input.float(20000, "Dist Price Level", step=100, tooltip="Price level for Distribution label.")

// ------------------------------------------------------------------
// 4. LABEL STYLES
// ------------------------------------------------------------------
ftdLabelColor = input.color(color.green, "FTD Color")
ftdLabelText = input.string("▲", "FTD Symbol", options=["▲", "△", "●", "■", "★", "✓", "↑"])
distLabelColor = input.color(color.red, "Dist Color")
distLabelText = input.string("▼", "Dist Symbol", options=["▼", "▽", "●", "■", "✗", "↓", "○"])

// ------------------------------------------------------------------
// 5. TABLE CUSTOMISATION
// ------------------------------------------------------------------
tablePosition = input.string("top_right", "Table Position", options=["top_right","top_left","bottom_right","bottom_left"])
tableBgColor = input.color(color.new(color.gray,85), "Table BG")
tableTextColor = input.color(color.black, "Table Text")
tableFontSize = input.string("normal", "Table Font Size", options=["tiny","small","normal","large"])
tableHorzAlign = input.string("left", "Align", options=["left","center","right"])

// ==================================================================
// MAPPING FUNCTIONS
// ==================================================================
fontSizeMap(s) =>
    switch s
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        "large" => size.large
        => size.normal

posMap(p) =>
    switch p
        "top_right" => position.top_right
        "top_left" => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left" => position.bottom_left
        => position.top_right

horzAlignMap(a) =>
    switch a
        "left" => text.align_left
        "center" => text.align_center
        "right" => text.align_right
        => text.align_left

// ==================================================================
// CORE LOGIC
// ==================================================================

// Distribution Day detection
isDistributionDay = (close < close[1] * (1 + distDownPct)) and volume > volume[1]

// Rolling distribution count (20 days)
distCount20 = math.sum(isDistributionDay ? 1 : 0, 20)

// Function to get the low of the 5th distribution day in the last 20 bars
getFifthDistLow() =>
    int count = 0
    float lowPrice = na
    for i = 0 to 19
        if isDistributionDay[i]
            count := count + 1
            if count == 5
                lowPrice := low[i]
                break
    lowPrice

fifthDistLow = getFifthDistLow()
sellSignal = not na(fifthDistLow) and close < fifthDistLow

// Pre‑compute moving averages
sma50 = ta.sma(close, 50)
sma200 = ta.sma(close, 200)

// ------------------------------------------------------------
// FIXED RALLY ATTEMPT & FTD DETECTION (using barssince)
// ------------------------------------------------------------
lowestLow = ta.lowest(low, ftdRallyLookback)
daysSinceLow = ta.barssince(low == lowestLow)
rallyDay = daysSinceLow + 1   // day 1 = the low day

// FTD condition: days 4‑7, gain >= threshold, volume higher if required
priceGain = (close / close[1] - 1) * 100
isFTD = rallyDay >= 4 and rallyDay <= 7 and priceGain >= ftdGainPct
if requireHigherVolFTD
    isFTD := isFTD and volume > volume[1]

// Track confirmed uptrend (reset on sell signal or break below 200 SMA)
var bool uptrendConfirmed = false
if isFTD
    uptrendConfirmed := true
if sellSignal or close < sma200
    uptrendConfirmed := false

// ------------------------------------------------------------
// Determine market phase and trading posture
// ------------------------------------------------------------
var string marketPhase = "Neutral"
var string tradingPosture = ""

if sellSignal or (close < sma50 and close < sma200)
    marketPhase := "Markdown (Downtrend)"
    tradingPosture := "Preservation -> Cash or Inverse"
else if distCount20 >= 5 and not sellSignal
    marketPhase := "Distribution (Topping)"
    tradingPosture := "Defensive -> Reduce long exposure, tighten stops"
else if uptrendConfirmed
    marketPhase := "Markup (Confirmed Uptrend)"
    tradingPosture := "Aggressive -> Maximum long exposure"
else if rallyDay <= 7
    marketPhase := "Accumulation (Bottoming)"
    tradingPosture := "Preparatory -> Build watchlist, small size"
else
    marketPhase := "Neutral"
    tradingPosture := "Wait for clear signal"

// ==================================================================
// DRAW LABELS (fixed price levels)
// ==================================================================
if showFTDlabel and isFTD
    label.new(bar_index, ftdFixedPrice, text=ftdLabelText, color=ftdLabelColor,
              style=label.style_none, textcolor=ftdLabelColor,
              size=size.small, yloc=yloc.price)

if showDistLabel and isDistributionDay
    label.new(bar_index, distFixedPrice, text=distLabelText, color=distLabelColor,
              style=label.style_none, textcolor=distLabelColor,
              size=size.small, yloc=yloc.price)

// ==================================================================
// DRAW SIMPLIFIED TABLE (Phase and Posture)
// ==================================================================
if showTable
    var table t = na
    if barstate.islast
        pos = posMap(tablePosition)
        fontSize = fontSizeMap(tableFontSize)
        horzAlign = horzAlignMap(tableHorzAlign)
        if na(t)
            t := table.new(pos, 2, 2, bgcolor=tableBgColor, border_width=1)
        else
            table.set_position(t, pos)
            table.set_bgcolor(t, tableBgColor)
            table.set_border_width(t, 1)

        // Background colour based on market phase
        phaseBgColor = marketPhase == "Markup (Confirmed Uptrend)" ? color.new(color.green, 70) : 
                       marketPhase == "Markdown (Downtrend)" ? color.new(color.red, 70) :
                       marketPhase == "Distribution (Topping)" ? color.new(color.orange, 70) :
                       color.new(color.gray, 70)

        // Row 0: Market Phase
        table.cell(t, 0, 0, "Market Phase", text_color=tableTextColor, text_size=fontSize, text_halign=horzAlign, bgcolor=phaseBgColor)
        phaseColor = marketPhase == "Markup (Confirmed Uptrend)" ? color.green : marketPhase == "Markdown (Downtrend)" ? color.red : color.orange
        table.cell(t, 1, 0, marketPhase, text_color=phaseColor, text_size=fontSize, text_halign=horzAlign, bgcolor=phaseBgColor)

        // Row 1: Trading Posture
        table.cell(t, 0, 1, "Trading Posture", text_color=tableTextColor, text_size=fontSize, text_halign=horzAlign, bgcolor=phaseBgColor)
        table.cell(t, 1, 1, tradingPosture, text_color=phaseColor, text_size=fontSize, text_halign=horzAlign, bgcolor=phaseBgColor)
````
