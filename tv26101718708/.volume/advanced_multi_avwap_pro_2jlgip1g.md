# Advanced Multi AVWAP Pro

- url: https://www.tradingview.com/script/2JLgIP1g-Advanced-Multi-AVWAP-Pro/
- type: indicator
- pine_id: PUB;e149a906815044488be8bbc6d9b515d3
- version: 1.0

## Description

It plots multiple AVWAPs anchored to major events: ATH, ATL, 52-week high and low, earnings gaps, significant gaps, 6-month high/low, 3-month high/low, and the most recent swing high and low. You can also control how gaps are defined using parameters like gap volume and gap percentage.

## Source Code

````pine
//@version=5
indicator("Advanced Multi AVWAP Pro", overlay=true, max_bars_back=5000)

// ===== Inputs =====
showATH = input.bool(true, "Show ATH AVWAP")
showATL = input.bool(false, "Show ATL AVWAP")
show52H = input.bool(true, "Show 52W High AVWAP")
show52L = input.bool(false, "Show 52W Low AVWAP")
show6MH = input.bool(true, "Show 6M High AVWAP")
show6ML = input.bool(false, "Show 6M Low AVWAP")
showGapU = input.bool(true, "Show Significant Gap Up AVWAP")
showEarn = input.bool(true, "Show Earnings Gap AVWAP")
showSwingH = input.bool(true, "Show Latest Swing High AVWAP")
showSwingL = input.bool(true, "Show Latest Swing Low AVWAP")
showLabels = input.bool(true, "Show Latest Labels Only")

lookback52W = input.int(252, "52W Lookback", minval=50)
lookback6M = input.int(126, "6M Lookback", minval=50)

swingLeft = input.int(5, "Swing Left Bars", minval=1)
swingRight = input.int(5, "Swing Right Bars", minval=1)

gapPctThreshold = input.float(3.0, "Gap % Threshold", step=0.1)
gapVolMultiplier = input.float(1.5, "Gap Volume Multiplier", step=0.1)
earnGapPct = input.float(4.0, "Earnings Gap % Threshold", step=0.1)

hideFar = input.bool(true, "Hide AVWAPs Far From Price")
maxDistancePct = input.float(15.0, "Max Distance From Price %", step=0.5)

// Keep Fixed for softest look
colorMode = input.string("Fixed", "Line Color Mode", options=["Fixed", "Price Above/Below", "Slope"])

// ===== Soft Transparent Colors =====
colATH = color.new(color.rgb(210, 160, 70), 45)
colATL = color.new(color.rgb(150, 150, 150), 60)
col52H = color.new(color.rgb(90, 140, 190), 50)
col52L = color.new(color.rgb(100, 170, 120), 55)
col6MH = color.new(color.rgb(170, 130, 190), 60)
col6ML = color.new(color.rgb(110, 180, 180), 60)
colGap = color.new(color.rgb(150, 185, 90), 55)
colEarn = color.new(color.rgb(205, 180, 80), 45)
colSwingH = color.new(color.rgb(170, 110, 110), 60)
colSwingL = color.new(color.rgb(110, 125, 180), 60)

// Label colors, slightly stronger but still soft
labATH = color.rgb(190, 140, 60)
labATL = color.rgb(130, 130, 130)
lab52H = color.rgb(80, 125, 170)
lab52L = color.rgb(85, 145, 105)
lab6MH = color.rgb(150, 110, 170)
lab6ML = color.rgb(95, 155, 155)
labGap = color.rgb(135, 165, 80)
labEarn = color.rgb(190, 160, 60)
labSwingH = color.rgb(150, 95, 95)
labSwingL = color.rgb(95, 105, 160)

// ===== Functions =====
f_avwap(anchorCondition, priceSource, anchorOffset) =>
    cumPV = ta.cum(priceSource * volume)
    cumVol = ta.cum(volume)
    var float anchorPV = na
    var float anchorVol = na
    if anchorCondition
        anchorPV := nz(cumPV[anchorOffset + 1])
        anchorVol := nz(cumVol[anchorOffset + 1])
    not na(anchorPV) and cumVol > anchorVol ? (cumPV - anchorPV) / (cumVol - anchorVol) : na

f_col(v, fixedColor) =>
    colorMode == "Fixed" ? fixedColor : colorMode == "Price Above/Below" ? (close >= v ? color.new(color.rgb(100, 170, 120), 55) : color.new(color.rgb(190, 100, 100), 55)) : (v >= v[1] ? color.new(color.rgb(100, 170, 120), 55) : color.new(color.rgb(190, 100, 100), 55))

f_show(v, enabled) =>
    enabled and not na(v) and (not hideFar or math.abs(close - v) / close * 100 <= maxDistancePct)

// ===== ATH / ATL =====
var float ath = na
var float atl = na
athAnchor = false
atlAnchor = false

if na(ath) or high > ath
    ath := high
    athAnchor := true

if na(atl) or low < atl
    atl := low
    atlAnchor := true

avwapATH = f_avwap(athAnchor, high, 0)
avwapATL = f_avwap(atlAnchor, low, 0)

// ===== 52W / 6M =====
anchor52H = high == ta.highest(high, lookback52W)
anchor52L = low == ta.lowest(low, lookback52W)
anchor6MH = high == ta.highest(high, lookback6M)
anchor6ML = low == ta.lowest(low, lookback6M)

avwap52H = f_avwap(anchor52H, high, 0)
avwap52L = f_avwap(anchor52L, low, 0)
avwap6MH = f_avwap(anchor6MH, high, 0)
avwap6ML = f_avwap(anchor6ML, low, 0)

// ===== Significant Gap Up =====
avgVol = ta.sma(volume, 20)
gapUpPct = ((low - high[1]) / high[1]) * 100
sigGapUp = low > high[1] and gapUpPct >= gapPctThreshold and volume > avgVol * gapVolMultiplier
avwapGapUp = f_avwap(sigGapUp, low, 0)

// ===== Earnings Gap Approximation =====
earnGapNow = math.abs(open - close[1]) / close[1] * 100
earningsGap = earnGapNow >= earnGapPct and volume > avgVol * gapVolMultiplier
earnSource = close > close[1] ? low : high
avwapEarn = f_avwap(earningsGap, earnSource, 0)

// ===== Latest Swing High / Low =====
ph = ta.pivothigh(high, swingLeft, swingRight)
pl = ta.pivotlow(low, swingLeft, swingRight)

swingHighAnchor = not na(ph)
swingLowAnchor = not na(pl)

avwapSwingH = f_avwap(swingHighAnchor, high, swingRight)
avwapSwingL = f_avwap(swingLowAnchor, low, swingRight)

var int lastSHBar = na
var float lastSHPrice = na
var int lastSLBar = na
var float lastSLPrice = na

if swingHighAnchor
    lastSHBar := bar_index - swingRight
    lastSHPrice := ph

if swingLowAnchor
    lastSLBar := bar_index - swingRight
    lastSLPrice := pl

// ===== Plots =====
plot(f_show(avwapATH, showATH) ? avwapATH : na, "ATH AVWAP", color=f_col(avwapATH, colATH), linewidth=2)
plot(f_show(avwapATL, showATL) ? avwapATL : na, "ATL AVWAP", color=f_col(avwapATL, colATL), linewidth=1)
plot(f_show(avwap52H, show52H) ? avwap52H : na, "52W High AVWAP", color=f_col(avwap52H, col52H), linewidth=2)
plot(f_show(avwap52L, show52L) ? avwap52L : na, "52W Low AVWAP", color=f_col(avwap52L, col52L), linewidth=2)
plot(f_show(avwap6MH, show6MH) ? avwap6MH : na, "6M High AVWAP", color=f_col(avwap6MH, col6MH), linewidth=1)
plot(f_show(avwap6ML, show6ML) ? avwap6ML : na, "6M Low AVWAP", color=f_col(avwap6ML, col6ML), linewidth=1)
plot(f_show(avwapGapUp, showGapU) ? avwapGapUp : na, "Significant Gap Up AVWAP", color=f_col(avwapGapUp, colGap), linewidth=1)
plot(f_show(avwapEarn, showEarn) ? avwapEarn : na, "Earnings Gap AVWAP", color=f_col(avwapEarn, colEarn), linewidth=2)
plot(f_show(avwapSwingH, showSwingH) ? avwapSwingH : na, "Latest Swing High AVWAP", color=f_col(avwapSwingH, colSwingH), linewidth=1)
plot(f_show(avwapSwingL, showSwingL) ? avwapSwingL : na, "Latest Swing Low AVWAP", color=f_col(avwapSwingL, colSwingL), linewidth=1)

// ===== Latest Labels Only =====
var label lblATH = na
var label lblATL = na
var label lbl52H = na
var label lbl52L = na
var label lbl6MH = na
var label lbl6ML = na
var label lblGap = na
var label lblEarn = na
var label lblSH = na
var label lblSL = na

if barstate.islast
    label.delete(lblATH)
    label.delete(lblATL)
    label.delete(lbl52H)
    label.delete(lbl52L)
    label.delete(lbl6MH)
    label.delete(lbl6ML)
    label.delete(lblGap)
    label.delete(lblEarn)
    label.delete(lblSH)
    label.delete(lblSL)

    if showLabels and f_show(avwapATH, showATH)
        lblATH := label.new(bar_index, avwapATH, "ATH", style=label.style_label_left, color=labATH, textcolor=color.white)

    if showLabels and f_show(avwapATL, showATL)
        lblATL := label.new(bar_index, avwapATL, "ATL", style=label.style_label_left, color=labATL, textcolor=color.white)

    if showLabels and f_show(avwap52H, show52H)
        lbl52H := label.new(bar_index, avwap52H, "52H", style=label.style_label_left, color=lab52H, textcolor=color.white)

    if showLabels and f_show(avwap52L, show52L)
        lbl52L := label.new(bar_index, avwap52L, "52L", style=label.style_label_left, color=lab52L, textcolor=color.white)

    if showLabels and f_show(avwap6MH, show6MH)
        lbl6MH := label.new(bar_index, avwap6MH, "6MH", style=label.style_label_left, color=lab6MH, textcolor=color.white)

    if showLabels and f_show(avwap6ML, show6ML)
        lbl6ML := label.new(bar_index, avwap6ML, "6ML", style=label.style_label_left, color=lab6ML, textcolor=color.white)

    if showLabels and f_show(avwapGapUp, showGapU)
        lblGap := label.new(bar_index, avwapGapUp, "Gap", style=label.style_label_left, color=labGap, textcolor=color.white)

    if showLabels and f_show(avwapEarn, showEarn)
        lblEarn := label.new(bar_index, avwapEarn, "ER", style=label.style_label_left, color=labEarn, textcolor=color.white)

    if showLabels and showSwingH and not na(lastSHBar) and not na(lastSHPrice)
        lblSH := label.new(lastSHBar, lastSHPrice, "SH", style=label.style_label_down, color=labSwingH, textcolor=color.white)

    if showLabels and showSwingL and not na(lastSLBar) and not na(lastSLPrice)
        lblSL := label.new(lastSLBar, lastSLPrice, "SL", style=label.style_label_up, color=labSwingL, textcolor=color.white)
````
