# 821EMA Trend + Relative Volume Pressure v3

- url: https://www.tradingview.com/script/Y7422n7d-821EMA-Trend-Relative-Volume-Pressure-v3/
- type: indicator
- pine_id: PUB;8ee36d466e944b7689b9f1a2b8f9aabb
- version: 1.0

## Description

8 21 shows you trend, and the relative volume score shows you the strength of that trend, all in one. Enjoy!

## Source Code

````pine
//@version=5
indicator("EMA Trend + Relative Volume Pressure v3", overlay=true)

// ─── Inputs ───
fastLen   = input.int(8,  "Fast EMA")
slowLen   = input.int(21, "Slow EMA")
volLen    = input.int(20, "Relative Volume Lookback")
rvolHigh  = input.float(1.5, "Strong Volume Threshold (RVOL)", step=0.1)
rvolLow   = input.float(0.7, "Fading Volume Threshold (RVOL)", step=0.1)
fadeBars  = input.int(3, "Consecutive Bars of Declining RVOL to Flag Fade", minval=2)
plotMid   = input.bool(true, "Use Midline (avg of EMAs) instead of Fast EMA")
showLabel = input.bool(true, "Show Status Label")
labelOff  = input.int(10, "Label Offset (bars to the right)", minval=1)

// ─── EMAs ───
fast = ta.ema(close, fastLen)
slow = ta.ema(close, slowLen)
bull = fast > slow

// ─── Relative Volume ───
avgVol = ta.sma(volume, volLen)
rvol   = volume / avgVol

// ─── Adaptive fade detection ───
rvolFalling = true
for i = 0 to fadeBars - 1
    rvolFalling := rvolFalling and (rvol[i] < rvol[i + 1])

rvolSmooth    = ta.sma(rvol, fadeBars)
rvolSlopeDown = rvolSmooth < rvolSmooth[fadeBars]

fadingVol = (rvol <= rvolLow) or (rvolFalling and rvolSlopeDown)
strongVol = rvol >= rvolHigh and not fadingVol

// ─── State ───
// 0 bull strong, 1 bull normal, 2 bull fade, 3 bear strong, 4 bear normal, 5 bear fade
state = bull ?
   (strongVol ? 0 : fadingVol ? 2 : 1) :
   (strongVol ? 3 : fadingVol ? 5 : 4)

// ─── Colors ───
cBullStrong = color.new(#00c853, 0)
cBullNormal = color.new(#00c853, 25)
cBullFade   = color.new(#ffab00, 0)
cBearStrong = color.new(#d50000, 0)
cBearNormal = color.new(#d50000, 25)
cBearFade   = color.new(#ffab00, 0)

trendCol = switch state
    0 => cBullStrong
    1 => cBullNormal
    2 => cBullFade
    3 => cBearStrong
    4 => cBearNormal
    => cBearFade

// ─── Variable-width trend line (three overlaid plots) ───
midline  = (fast + slow) / 2
baseLine = plotMid ? midline : fast

isThin  = fadingVol
isThick = strongVol
isMed   = not fadingVol and not strongVol

plot(isThin  ? baseLine : na, "Trend (thin)",  color=trendCol, linewidth=1)
plot(isMed   ? baseLine : na, "Trend (med)",   color=trendCol, linewidth=2)
plot(isThick ? baseLine : na, "Trend (thick)", color=trendCol, linewidth=4)

// ─── EMA spread fill ───
p1 = plot(fast, "8 EMA", color=color.new(trendCol, 70))
p2 = plot(slow, "21 EMA", color=color.new(trendCol, 70))
fill(p1, p2, color=color.new(trendCol, 88))

// ─── Caution / cross markers ───
cautionUp   = bull and fadingVol and bull[1]
cautionDown = not bull and fadingVol and not bull[1]
plotshape(cautionUp,   "Bull Fading", shape.triangledown, location.abovebar, color.new(#ffab00,0), size=size.tiny)
plotshape(cautionDown, "Bear Fading", shape.triangleup,   location.belowbar, color.new(#ffab00,0), size=size.tiny)
plotshape(ta.crossover(fast, slow),  "Bull Cross", shape.circle, location.belowbar, color.new(#00c853,0), size=size.tiny)
plotshape(ta.crossunder(fast, slow), "Bear Cross", shape.circle, location.abovebar, color.new(#d50000,0), size=size.tiny)

// ─── Status label (last bar only) ───
var label statusLbl = na
if showLabel and barstate.islast
    label.delete(statusLbl)

    trendTxt = bull ? "▲ BULLISH" : "▼ BEARISH"
    volTxt   = strongVol ? "STRONG" : fadingVol ? "FADING ⚠" : "NORMAL"
    convTxt  = strongVol ? "conviction" : fadingVol ? "caution — participation bleeding" : "steady"

    txt = trendTxt + "  (8/21 EMA)\n" +
          "RVOL: " + str.tostring(rvol, "#.00") + "x  →  " + volTxt + "\n" +
          str.tostring(rvolSmooth, "#.00") + "x avg  •  " + convTxt

    lblCol = fadingVol ? color.new(#ffab00, 0) :
             bull ? color.new(#00c853, 0) : color.new(#d50000, 0)

    statusLbl := label.new(
       x         = bar_index + labelOff,
       y         = baseLine,
       text      = txt,
       color     = color.new(lblCol, 10),
       textcolor = color.white,
       style     = label.style_label_left,
       size      = size.normal)

// ─── Alerts ───
alertcondition(ta.crossover(fast, slow),  "8/21 Bullish Cross", "8 EMA crossed above 21 EMA")
alertcondition(ta.crossunder(fast, slow), "8/21 Bearish Cross", "8 EMA crossed below 21 EMA")
alertcondition(cautionUp,   "Bull Trend, Fading Volume", "Uptrend persisting on declining relative volume")
alertcondition(cautionDown, "Bear Trend, Fading Volume", "Downtrend persisting on declining relative volume")
````
