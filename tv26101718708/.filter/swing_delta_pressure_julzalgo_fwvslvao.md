#  Swing Delta Pressure | julzALGO

- url: https://www.tradingview.com/script/fWvslvaO-Swing-Delta-Pressure-julzALGO/
- type: indicator
- pine_id: PUB;b711e9a18a274dacaad761c72ca2e14f
- version: 1.0

## Description

📊  Swing Delta Pressure  | julzALGO

🔷 1. Overview

Swing Delta Pressure is a swing-anchored directional pressure framework that combines market structure, estimated buy/sell participation, delta imbalance, and a pressure-weighted trend path into one integrated overlay.

The script is designed to help traders evaluate not only where price is moving, but whether buyer or seller participation is supporting that movement.

By combining swing detection with candle anatomy and directional participation modeling, Swing Delta Pressure  can be used for:

• Initial swing flip detection
• Pullback observation
• Retest continuation planning
• Directional pressure confirmation
• Risk-to-reward execution planning

🔷 2. Core Concept

Traditional indicators often focus mainly on price movement, standard volume, or static smoothing.

Swing Delta Pressure expands this by integrating:

• Swing high / swing low structure
• Estimated buy volume
• Estimated sell volume
• Delta volume
• Pressure acceleration
• Participation weighting
• Swing-anchored pressure path
• Dynamic RR zones

The core idea is simple:

Each new swing establishes a structural anchor point.
https://www.tradingview.com/x/SYVc11Ru/
From that anchor:

• Buyer and seller participation are estimated
• Delta pressure is accumulated
• Price is weighted by participation strength
• The active pressure path updates until the next structural swing flip

Where volume calculation starts:
https://www.tradingview.com/x/ybgdZdV3/

Buy Volume (B), Sell Volume (S), Delta (Δ), and Imbalance (%) begin calculating from the swing anchor pivot marker and continue accumulating through each new bar until the next confirmed swing flip occurs.

Simple rule:

Swing Anchor Pivot → Present Active Bar

Bullish swing:

When a bullish swing is confirmed, volume tracking starts from the swing low anchor.

Bearish swing:

When a bearish swing is confirmed, volume tracking starts from the swing high anchor.

Reset rule:

When a new opposite swing flip occurs:

• Previous swing totals stop
• Previous path becomes historical
• New swing totals reset
• New cumulative tracking begins

Important:

B / S / Δ / % values are not single-candle values.

They represent cumulative estimated directional participation from the swing origin to the current active bar.

This helps traders evaluate whether the full active swing remains buyer- or seller-dominant, even during pullbacks or retests.

🔷 3. How It Works

The Swing Engine continuously tracks rolling swing highs and lows using the selected swing detection length.
https://www.tradingview.com/x/31cbgkec/

This identifies:

• Bullish swing flips
• Bearish swing flips
• Structural pivots
• Active anchor zones

The Delta Pressure Engine estimates buyer and seller participation using:

• Candle body size
• Upper wick behavior
• Lower wick behavior
• Close position within candle range
• Relative volume intensity
• Delta acceleration

Instead of treating every candle equally, the pressure path weights price using directional participation.

High-participation candles influence the path more strongly than weak candles. This creates a more adaptive flow path compared with standard smoothing.

The RR system can project:

https://www.tradingview.com/x/dOKUSRCI/
• Entry
• Stop Loss
• Take Profit

This allows traders to combine structure, participation, and visual risk planning in one workflow.

Visual interpretation:

• Blue path = Bullish directional pressure
• Purple path = Bearish directional pressure
• Blue anchor marker = Bull swing anchor where volume tracking starts
• Purple anchor marker = Bear swing anchor where volume tracking starts
• B = Estimated buyer participation from anchor to present bar
• S = Estimated seller participation from anchor to present bar
• Δ = Delta pressure from anchor to present bar
• % = Active swing imbalance strength

🔷 4. Settings

Swing Detection Length

Controls the sensitivity of structural swing flips.

Suggested reference:

• 20–30 = Faster / scalping
• 40–60 = Balanced / intraday
• 80+ = Higher timeframe / smoother

Weight Mode

Participation:

Balanced swing participation and stable path behavior.

Delta Absolute:

More reactive directional shifts.

Smart Pressure:

Higher sensitivity to stronger impulse moves.

Volume Mean / StdDev Length

Controls participation normalization.

Suggested reference:

• 100 = More reactive
• 200 = Balanced
• 300+ = Smoother

Stop Loss Type

ATR:

Adaptive volatility-based stop.

Pivot:

Structure-based stop.

ATR Multiplier

Suggested reference:

• 1.5 = Tight
• 2.0 = Balanced
• 2.5+ = Wider

Risk:Reward

Suggested reference:

• 1.5 = Conservative
• 2.0 = Balanced
• 3.0 = Extended trend target

General preset:

• Swing Length: 50
• Weight Mode: Participation
• Stop Loss Type: Pivot or ATR depending on strategy
• ATR Multiplier: 2.0–3.0
• Risk:Reward: 2.0

🔷 IMPORTANT NOTES
• This indicator does not guarantee profits and should not be used in isolation
• Market conditions can vary; always apply proper risk management
• Past performance does not indicate future results

🔷 DISCLAIMER
This script is for educational and informational purposes only.

It does not constitute financial advice. Always do your own analysis before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © julzALGO

// This Pine Script code is subject to the terms of the Mozilla Public License 2.0
// Copyright julzALGO

//@version=6
indicator(" Swing Delta Pressure | julzALGO", overlay = true, max_bars_back = 5000, max_labels_count = 500)

//──────────────────────────────────────────────────────────────────────────────
// INPUTS
//──────────────────────────────────────────────────────────────────────────────
groupSwing = "Swing Engine"
groupFlow  = "Flow Engine"
groupRisk  = "RR System"
groupStyle = "Style"

swingPeriod = input.int(50, "Swing Detection Length", minval = 2, group = groupSwing)

flowMeanLen = input.int(200, "Volume Mean Length", group = groupFlow)
flowStdLen  = input.int(200, "Volume StdDev Length", group = groupFlow)
flowMode    = input.string("Participation", "Weight Mode", options = ["Smart Pressure", "Delta Absolute", "Participation"], group = groupFlow)
minWeight   = input.float(1.0, "Minimum Weight", minval = 0.0001, step = 0.1, group = groupFlow)

showSignal = input.bool(true, "Show Signals", group = groupRisk)
sl_type    = input.string("Pivot", "Stop Loss Type", options = ["ATR", "Pivot"], group = groupRisk)
rr         = input.float(2.0, "Risk:Reward", minval = 0.1, step = 0.1, group = groupRisk)
sl_mult    = input.float(3.0, "ATR Multiplier", minval = 0.1, step = 0.1, group = groupRisk)

bullLineCol = input.color(color.rgb(0, 176, 230, 25), "Bull Line", group = groupStyle, inline = "ln")
bearLineCol = input.color(color.rgb(137, 82, 255, 25), "", group = groupStyle, inline = "ln")
lineWidth   = input.int(2, "Line Width", minval = 1, group = groupStyle)

showDashedHist = input.bool(true, "Show Previous Lines as Dashed", group = groupStyle)
histMaxLines   = input.int(20, "Max Dashed History Lines", minval = 1, maxval = 100, group = groupStyle)
histLineWidth  = input.int(2, "Dashed Line Width", minval = 1, maxval = 5, group = groupStyle)

//──────────────────────────────────────────────────────────────────────────────
// HELPERS
//──────────────────────────────────────────────────────────────────────────────
fmtVol(v) =>
    float av = math.abs(v)
    av >= 1000000 ? str.tostring(av / 1000000, "#.##") + "M" :
     av >= 1000   ? str.tostring(av / 1000, "#.#") + "K" :
     str.tostring(av, "#")

alphaFromTracking(x) =>
    float decay = math.exp(-math.log(2.0) / math.max(1.0, x))
    1.0 - decay

copyPoints(array<chart.point> src) =>
    array<chart.point> dst = array.new<chart.point>()
    int sz = array.size(src)
    if sz > 0
        for i = 0 to sz - 1
            chart.point p = array.get(src, i)
            array.push(dst, chart.point.from_index(p.index, p.price))
    dst

//──────────────────────────────────────────────────────────────────────────────
// SWING MAP
//──────────────────────────────────────────────────────────────────────────────
int bi = bar_index

var float swingHighPrice = na
var float swingLowPrice  = na
var int swingHighBar     = bi
var int swingLowBar      = bi
var float priorPivot     = na

swingHighPrice := ta.highestbars(high, swingPeriod) == 0 ? high : swingHighPrice
swingLowPrice  := ta.lowestbars(low, swingPeriod) == 0 ? low : swingLowPrice
swingHighBar   := ta.highestbars(high, swingPeriod) == 0 ? bi : swingHighBar
swingLowBar    := ta.lowestbars(low, swingPeriod) == 0 ? bi : swingLowBar

int swingDir = swingHighBar > swingLowBar ? 1 : -1
bool swingFlip = swingDir != swingDir[1]

//──────────────────────────────────────────────────────────────────────────────
// TRACKING PERIOD
//──────────────────────────────────────────────────────────────────────────────
atrLen = 50
atrNow = ta.atr(atrLen)

trackSeries = 5

//──────────────────────────────────────────────────────────────────────────────
// julzALGO PRESSURE ENGINE
//──────────────────────────────────────────────────────────────────────────────
float tr = ta.tr(true)
float priceRange = math.max(tr, syminfo.mintick)

float body = close - open
float bodySize = math.abs(body)
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low

float totalCandle = bodySize + upperWick + lowerWick
totalCandle := totalCandle == 0 ? syminfo.mintick : totalCandle

float bodyRatio = body / priceRange
float wickBuy = lowerWick / totalCandle
float wickSell = upperWick / totalCandle
float closePos = (close - low) / priceRange

float buyStrength =
     (closePos * 0.6) +
     (wickBuy * 0.25) +
     (bodyRatio > 0 ? bodyRatio * 0.35 : 0)

float sellStrength =
     ((1 - closePos) * 0.6) +
     (wickSell * 0.25) +
     (bodyRatio < 0 ? -bodyRatio * 0.35 : 0)

float estBuyVol = volume * buyStrength
float estSellVol = volume * sellStrength

float normTotal = estBuyVol + estSellVol
estBuyVol  := normTotal > 0 ? volume * (estBuyVol / normTotal) : 0
estSellVol := normTotal > 0 ? volume * (estSellVol / normTotal) : 0

float deltaVol = estBuyVol - estSellVol
float imbalance = deltaVol

float meanVol = ta.sma(volume, flowMeanLen)
float stdVol  = ta.stdev(volume, flowStdLen)
float zVol = stdVol > 0 ? (volume - meanVol) / stdVol : 0
zVol := math.max(-4.0, math.min(4.0, zVol))

float baseImpulse = 1 + zVol * 0.6
float rawPressure = deltaVol * baseImpulse

float accel = rawPressure - nz(rawPressure[1])
float norm = ta.sma(math.abs(rawPressure), 10) + 1e-6
float power = rawPressure / norm

float powerClamped = math.min(math.abs(power), 5.0)
float boost = math.pow(powerClamped, 1.4)
float agreement = math.sign(rawPressure) == math.sign(imbalance) ? 1.2 : 0.7
float accelWeight = math.sign(accel) == math.sign(rawPressure) ? 1.0 : 0.5

float pressure =
     (rawPressure * (1 + boost) * agreement) +
     (imbalance * 0.6) +
     (accel * 0.4 * accelWeight)

float smartPressure = pressure

float pressureWeight =
     flowMode == "Smart Pressure" ? math.max(math.abs(smartPressure), minWeight) :
     flowMode == "Delta Absolute" ? math.max(math.abs(deltaVol), minWeight) :
     math.max(estBuyVol + estSellVol, minWeight)


//──────────────────────────────────────────────────────────────────────────────
// FLOW-ANCHORED PRESSURE AVERAGE
//──────────────────────────────────────────────────────────────────────────────
var float weightedPrice = na
var float weightedMass  = na

type lineState
    array<chart.point> pts
    polyline line

var pressurePath = lineState.new(array.new<chart.point>(), na)

var array<chart.point> prevPts = array.new<chart.point>()
var polyline prevPathLine = na
var bool prevPathActive = false
var float prevWeightedPrice = na
var float prevWeightedMass  = na
var color prevPathCol = na

var float activeBuySeg = 0.0
var float activeSellSeg = 0.0
var int activeAnchorBar = na
var float activeAnchorPrice = na
var color activeAnchorCol = na

var label activeVolLbl = na
var array<label> prevVolLabels = array.new<label>()
int maxPrevVolLabels = 5

if barstate.isfirst
    weightedPrice := hlc3 * pressureWeight
    weightedMass  := pressureWeight
    activeBuySeg  := estBuyVol
    activeSellSeg := estSellVol

if swingFlip
    if not na(prevPathLine)
        polyline.delete(prevPathLine)

    prevPts := copyPoints(pressurePath.pts)
    prevWeightedPrice := weightedPrice
    prevWeightedMass  := weightedMass
    prevPathCol := swingDir[1] > 0 ? bullLineCol : bearLineCol
    prevPathActive := array.size(prevPts) > 0

    if prevPathActive
        float prevAlpha = alphaFromTracking(trackSeries)
        float prevWeightedInput = hlc3 * pressureWeight
        float prevMassInput = pressureWeight

        prevWeightedPrice := na(prevWeightedPrice) ? prevWeightedInput : (1.0 - prevAlpha) * prevWeightedPrice + prevAlpha * prevWeightedInput
        prevWeightedMass  := na(prevWeightedMass) ? prevMassInput : (1.0 - prevAlpha) * prevWeightedMass + prevAlpha * prevMassInput

        float prevFlowAP = prevWeightedMass > 0 ? prevWeightedPrice / prevWeightedMass : na
        array.push(prevPts, chart.point.from_index(bi, prevFlowAP))

        prevPathLine := polyline.new(
             prevPts,
             false,
             false,
             xloc = xloc.bar_index,
             line_color = prevPathCol,
             line_style = line.style_dashed,
             line_width = histLineWidth
        )

    if not na(activeVolLbl)
        array.push(prevVolLabels, activeVolLbl)
        if array.size(prevVolLabels) > maxPrevVolLabels
            label oldestLbl = array.shift(prevVolLabels)
            if not na(oldestLbl)
                label.delete(oldestLbl)
        activeVolLbl := na

    if not na(pressurePath.line)
        polyline.delete(pressurePath.line)

    array.clear(pressurePath.pts)

    int anchorBar = swingDir > 0 ? swingLowBar : swingHighBar
    float anchorPrice = swingDir > 0 ? swingLowPrice : swingHighPrice
    color anchorCol = swingDir > 0 ? bullLineCol : bearLineCol

    activeAnchorBar := anchorBar
    activeAnchorPrice := anchorPrice
    activeAnchorCol := anchorCol

    priorPivot := swingDir > 0 ? swingHighPrice[1] : swingLowPrice[1]

    int barsBack = bi - anchorBar
    float startWeight = nz(pressureWeight[barsBack], pressureWeight)
    weightedPrice := anchorPrice * startWeight
    weightedMass  := startWeight

    activeBuySeg  := 0.0
    activeSellSeg := 0.0
    float activeFlowAP = na

    for i = barsBack to 0 by 1
        float alpha = alphaFromTracking(trackSeries)

        float weightedInput = hlc3[i] * pressureWeight[i]
        float massInput = pressureWeight[i]

        weightedPrice := (1.0 - alpha) * weightedPrice + alpha * weightedInput
        weightedMass  := (1.0 - alpha) * weightedMass + alpha * massInput

        activeBuySeg += nz(estBuyVol[i], 0)
        activeSellSeg += nz(estSellVol[i], 0)

        activeFlowAP := weightedMass > 0 ? weightedPrice / weightedMass : na
        array.push(pressurePath.pts, chart.point.from_index(bi - i, activeFlowAP))

    pressurePath.line := polyline.new(
         pressurePath.pts,
         false,
         false,
         xloc = xloc.bar_index,
         line_color = swingDir > 0 ? bullLineCol : bearLineCol,
         line_width = lineWidth
    )

    float activeDelta = activeBuySeg - activeSellSeg
    float activeTotVol = activeBuySeg + activeSellSeg
    float activeImbPct = activeTotVol > 0 ? math.abs(activeDelta) / activeTotVol * 100 : 0

    string swingLabelText =
         swingDir > 0 ?
         "●" +
         "\nB:" + fmtVol(activeBuySeg) +
         "\nS:" + fmtVol(activeSellSeg) +
         "\nΔ:" + fmtVol(activeDelta) +
         "\n" + str.tostring(activeImbPct, "#.0") + "%" :
         "B:" + fmtVol(activeBuySeg) +
         "\nS:" + fmtVol(activeSellSeg) +
         "\nΔ:" + fmtVol(activeDelta) +
         "\n" + str.tostring(activeImbPct, "#.0") + "%" +
         "\n●"

    activeVolLbl := label.new(
         activeAnchorBar,
         activeAnchorPrice,
         swingLabelText,
         xloc = xloc.bar_index,
         style = swingDir > 0 ? label.style_label_up : label.style_label_down,
         textcolor = activeAnchorCol,
         color = color.new(color.black, 100),
         size = size.normal
    )

else
    float alpha = alphaFromTracking(trackSeries)
    float weightedInput = hlc3 * pressureWeight
    float massInput = pressureWeight

    weightedPrice := na(weightedPrice) ? weightedInput : (1.0 - alpha) * weightedPrice + alpha * weightedInput
    weightedMass  := na(weightedMass) ? massInput : (1.0 - alpha) * weightedMass + alpha * massInput

    float flowAP = weightedMass > 0 ? weightedPrice / weightedMass : na
    activeBuySeg += nz(estBuyVol, 0)
    activeSellSeg += nz(estSellVol, 0)

    array.push(pressurePath.pts, chart.point.from_index(bi, flowAP))

    if not na(pressurePath.line)
        polyline.delete(pressurePath.line)

    pressurePath.line := polyline.new(
         pressurePath.pts,
         false,
         false,
         xloc = xloc.bar_index,
         line_color = swingDir > 0 ? bullLineCol : bearLineCol,
         line_width = lineWidth
    )

    if not na(activeVolLbl)
        label.delete(activeVolLbl)

    float activeDelta = activeBuySeg - activeSellSeg
    float activeTotVol = activeBuySeg + activeSellSeg
    float activeImbPct = activeTotVol > 0 ? math.abs(activeDelta) / activeTotVol * 100 : 0

    string swingLabelText =
         swingDir > 0 ?
         "●" +
         "\nB:" + fmtVol(activeBuySeg) +
         "\nS:" + fmtVol(activeSellSeg) +
         "\nΔ:" + fmtVol(activeDelta) +
         "\n" + str.tostring(activeImbPct, "#.0") + "%" :
         "B:" + fmtVol(activeBuySeg) +
         "\nS:" + fmtVol(activeSellSeg) +
         "\nΔ:" + fmtVol(activeDelta) +
         "\n" + str.tostring(activeImbPct, "#.0") + "%" +
         "\n●"

    activeVolLbl := label.new(
         activeAnchorBar,
         activeAnchorPrice,
         swingLabelText,
         xloc = xloc.bar_index,
         style = swingDir > 0 ? label.style_label_up : label.style_label_down,
         textcolor = activeAnchorCol,
         color = color.new(color.black, 100),
         size = size.normal
    )

    if prevPathActive
        float prevAlpha = alphaFromTracking(trackSeries)
        float prevWeightedInput = hlc3 * pressureWeight
        float prevMassInput = pressureWeight

        prevWeightedPrice := na(prevWeightedPrice) ? prevWeightedInput : (1.0 - prevAlpha) * prevWeightedPrice + prevAlpha * prevWeightedInput
        prevWeightedMass  := na(prevWeightedMass) ? prevMassInput : (1.0 - prevAlpha) * prevWeightedMass + prevAlpha * prevMassInput

        float prevFlowAP = prevWeightedMass > 0 ? prevWeightedPrice / prevWeightedMass : na
        array.push(prevPts, chart.point.from_index(bi, prevFlowAP))

        if not na(prevPathLine)
            polyline.delete(prevPathLine)

        prevPathLine := polyline.new(
             prevPts,
             false,
             false,
             xloc = xloc.bar_index,
             line_color = prevPathCol,
             line_style = line.style_dashed,
             line_width = histLineWidth
        )

//──────────────────────────────────────────────────────────────────────────────
// RR SYSTEM
//──────────────────────────────────────────────────────────────────────────────
bool buy = swingFlip and swingDir > 0
bool sell = swingFlip and swingDir < 0

var float entryPrice = na
var float SL = na
var float TP = na
var line entry_line = na
var line sl_line = na
var box tp_box = na
var label entry_lbl = na
var label sl_lbl = na
var label tp_lbl = na
var linefill risk_fill = na

if buy or sell
    entryPrice := close

    if sl_type == "ATR"
        SL := buy ? entryPrice - atrNow * sl_mult : entryPrice + atrNow * sl_mult
    else
        SL := buy ? swingLowPrice : swingHighPrice

    float risk = math.abs(entryPrice - SL)
    TP := buy ? entryPrice + risk * rr : entryPrice - risk * rr

    if not na(entry_line)
        line.delete(entry_line)
    if not na(sl_line)
        line.delete(sl_line)
    if not na(tp_box)
        box.delete(tp_box)
    if not na(risk_fill)
        linefill.delete(risk_fill)

    entry_line := line.new(bar_index, entryPrice, bar_index, entryPrice, color = buy ? color.rgb(0, 176, 230, 54) : color.rgb(137, 82, 255, 80), width = 1)
    sl_line := line.new(bar_index, SL, bar_index, SL, color = color.rgb(137, 82, 255, 54), width = 1)

    tp_box := box.new(
         bar_index, TP + atrNow * 0.2,
         bar_index, TP - atrNow * 0.2,
         bgcolor = color.rgb(0, 176, 230, 86),
         border_color = color.rgb(0, 176, 230, 54)
    )

    risk_fill := linefill.new(entry_line, sl_line, color.rgb(137, 82, 255, 89))

if not na(entry_line)
    line.set_x2(entry_line, bar_index)

if not na(sl_line)
    line.set_x2(sl_line, bar_index)

if not na(tp_box)
    box.set_right(tp_box, bar_index)

if not na(entry_lbl)
    label.delete(entry_lbl)
if not na(sl_lbl)
    label.delete(sl_lbl)
if not na(tp_lbl)
    label.delete(tp_lbl)

if not na(entry_line)
    float entry_line_price = line.get_y1(entry_line)
    entry_lbl := label.new(
         bar_index + 10,
         entry_line_price,
         "Entry: " + str.tostring(entry_line_price, format.mintick),
         style = label.style_label_left,
         color = color.rgb(0, 176, 230, 54),
         textcolor = color.white
    )

if not na(sl_line)
    float sl_price = line.get_y1(sl_line)
    sl_lbl := label.new(
         bar_index + 10,
         sl_price,
         "SL: " + str.tostring(sl_price, format.mintick),
         style = label.style_label_left,
         color = color.rgb(137, 82, 255, 54),
         textcolor = color.white
    )

if not na(tp_box)
    float tp_price = box.get_top(tp_box)
    tp_lbl := label.new(
         bar_index + 10,
         tp_price,
         "TP: " + str.tostring(tp_price, format.mintick),
         style = label.style_label_left,
         color = color.rgb(0, 176, 230, 54),
         textcolor = color.white
    )

//──────────────────────────────────────────────────────────────────────────────
// SIGNALS
//──────────────────────────────────────────────────────────────────────────────
plotshape(
     showSignal and buy,
     title = "Bull Flow Start",
     location = location.belowbar,
     style = shape.triangleup,
     size = size.small,
     color = color.rgb(0, 176, 230, 45)
)

plotshape(
     showSignal and sell,
     title = "Bear Flow Start",
     location = location.abovebar,
     style = shape.triangledown,
     size = size.small,
     color = color.rgb(137, 82, 255, 41)
)

alertcondition(buy, "Bull Flow RR", "Bull flow start with RR setup.")
alertcondition(sell, "Bear Flow RR", "Bear flow start with RR setup.")
````
