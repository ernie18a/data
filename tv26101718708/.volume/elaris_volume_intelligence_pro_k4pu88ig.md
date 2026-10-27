# Elaris Volume Intelligence Pro

- url: https://www.tradingview.com/script/K4PU88ig-Elaris-Volume-Intelligence-Pro/
- type: indicator
- pine_id: PUB;8e0c7373c3c54cd2b7f244b0b02bc4a6
- version: 1.0

## Description

Elaris Volume Intelligence Pro  is a professional-grade volume analysis and smart money intelligence indicator designed to help traders understand market participation, hidden pressure, and potential reversal activity in real time.

Instead of displaying raw volume alone, Elaris Volume Intelligence Pro transforms market volume into actionable intelligence by combining relative volume analysis, volume delta estimation, CVD (Cumulative Volume Delta), absorption detection, climax activity, and smart flow momentum into a single clean and trader-friendly system.

The indicator is built for discretionary traders, scalpers, intraday traders, swing traders, and crypto traders who want deeper insight into market behavior beyond standard candles.

━━━━━━━━━━━━━━━━━━
FEATURES
━━━━━━━━━━━━━━━━━━

• Smart Volume Columns
Dynamically colored volume bars help identify bullish pressure, bearish pressure, climax activity, and absorption zones instantly.

• Relative Volume & Z-Score Engine
Detects abnormal market participation using relative volume and statistical volume expansion analysis.

• Volume Flow Momentum
A smoothed institutional-style flow model that helps traders identify whether aggressive buying or selling pressure is dominating the market.

• Bullish & Bearish Climax Detection
Highlights potential exhaustion candles during extreme participation and volatility conditions.

• Demand & Supply Absorption Detection
Detects high-volume compression behavior that may indicate hidden accumulation or distribution by larger participants.

• Volume & CVD Divergence Signals
Identifies possible reversal conditions when price action and cumulative volume behavior diverge.

• Smart Market State Dashboard
A clean built-in intelligence panel provides:

* Market bias
* Smart score
* Relative volume strength
* Volume Z-score
* Delta pressure
* Active signal state

• Dark Mode Optimized UI
Professionally designed visuals optimized for both dark and light TradingView themes.

• Fully Configurable
All thresholds, smoothing values, divergence sensitivity, and visual layers can be customized for different trading styles and markets.

━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━

• Strong Bullish Conditions
Look for:

* Bullish volume climax
* Positive flow momentum
* Increasing relative volume
* Bullish divergences
* Demand absorption

• Strong Bearish Conditions
Look for:

* Bearish climax candles
* Negative flow momentum
* High sell-side pressure
* Bearish divergences
* Supply absorption

• Best Use Cases

* Crypto futures trading
* Intraday momentum trading
* Breakout confirmation
* Reversal detection
* Smart money analysis
* Volume-based confluence systems

━━━━━━━━━━━━━━━━━━
ALERTS INCLUDED
━━━━━━━━━━━━━━━━━━

The indicator includes built-in alerts for:

* Bullish/Bearish Volume Climax
* Demand/Supply Absorption
* Bullish/Bearish Divergence
* Bullish/Bearish Pressure States

━━━━━━━━━━━━━━━━━━
IMPORTANT NOTES
━━━━━━━━━━━━━━━━━━

• This indicator does not use repainting logic.
• Signals are generated using confirmed candle data.
• Works best on liquid markets with reliable volume data.
• Designed for confirmation and confluence, not standalone financial advice.

Built by Elaris Group.
Financial intelligence for modern markets.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ElarisGroup

//@version=6
indicator("Elaris Volume Intelligence Pro", "Elaris VIP", overlay=false, max_labels_count=300)


groupCore = "Core Settings"
volLen     = input.int(50, "Volume Baseline Length", minval=5, group=groupCore)
smoothLen  = input.int(14, "Flow Smoothing", minval=1, group=groupCore)
zLen       = input.int(100, "Volume Z-Score Length", minval=20, group=groupCore)

groupSignal = "Signal Sensitivity"
highRvol    = input.float(1.8, "High Relative Volume", step=0.1, group=groupSignal)
climaxRvol  = input.float(2.5, "Climax Relative Volume", step=0.1, group=groupSignal)
zExtreme    = input.float(2.0, "Extreme Volume Z-Score", step=0.1, group=groupSignal)
absorbRange = input.float(0.75, "Absorption Max ATR Range", step=0.05, group=groupSignal)
divLen      = input.int(20, "Divergence Lookback", minval=5, group=groupSignal)

groupVisual = "Visuals"
showColumns = input.bool(true, "Show Smart Volume Columns", group=groupVisual)
showFlow    = input.bool(true, "Show Volume Flow Line", group=groupVisual)
showCvd     = input.bool(false, "Show CVD", group=groupVisual)
showSignals = input.bool(true, "Show Signal Markers", group=groupVisual)
showTable   = input.bool(true, "Show Intelligence Dashboard", group=groupVisual)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(value, maxValue))

f_stateText(float score) =>
    score >= 65 ? "Strong Bullish" :
     score >= 25 ? "Bullish" :
     score <= -65 ? "Strong Bearish" :
     score <= -25 ? "Bearish" : "Neutral"

f_stateColor(float score) =>
    score >= 65 ? color.lime :
     score >= 25 ? color.new(color.lime, 30) :
     score <= -65 ? color.red :
     score <= -25 ? color.new(color.red, 30) :
     color.gray

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Core calculations
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
volMA   = ta.sma(volume, volLen)
volDev  = ta.stdev(volume, zLen)
rvol    = volMA > 0 ? volume / volMA : 0.0
volZ    = volDev > 0 ? (volume - volMA) / volDev : 0.0

barRange = math.max(high - low, syminfo.mintick)
atr      = ta.atr(14)
rangeAtr = atr > 0 ? barRange / atr : 0.0

closePos = f_clamp((close - low) / barRange, 0.0, 1.0)

bullVol = volume * closePos
bearVol = volume * (1.0 - closePos)
delta   = bullVol - bearVol

deltaNorm = volMA > 0 ? f_clamp((delta / volMA) * 100.0, -100.0, 100.0) : 0.0
flowRaw   = ta.ema(deltaNorm, smoothLen)
flow      = ta.ema(flowRaw, smoothLen)

cvd = ta.cum(delta)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Intelligence conditions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isHighVolume = rvol >= highRvol
isClimaxVol  = rvol >= climaxRvol and volZ >= zExtreme

bullClimax = isClimaxVol and close > open and closePos >= 0.65
bearClimax = isClimaxVol and close < open and closePos <= 0.35

bullAbsorption = isHighVolume and rangeAtr <= absorbRange and closePos >= 0.60 and close <= open
bearAbsorption = isHighVolume and rangeAtr <= absorbRange and closePos <= 0.40 and close >= open

bullPressure = flow > 20 and deltaNorm > 0 and rvol > 1.0
bearPressure = flow < -20 and deltaNorm < 0 and rvol > 1.0

priceHH = high > ta.highest(high, divLen)[1]
priceLL = low < ta.lowest(low, divLen)[1]
cvdHH   = cvd > ta.highest(cvd, divLen)[1]
cvdLL   = cvd < ta.lowest(cvd, divLen)[1]

bearDiv = priceHH and not cvdHH and rvol > 1.0
bullDiv = priceLL and not cvdLL and rvol > 1.0

smartScore =
     flow * 0.45 +
     deltaNorm * 0.35 +
     (closePos - 0.5) * 100.0 * 0.20

smartScoreClamped = f_clamp(smartScore, -100.0, 100.0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Visuals
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
volColor =
     bullClimax ? color.lime :
     bearClimax ? color.red :
     bullAbsorption ? color.aqua :
     bearAbsorption ? color.orange :
     deltaNorm >= 0 ? color.new(color.lime, 45) :
     color.new(color.red, 45)

plot(showColumns ? volume : na, "Smart Volume", style=plot.style_columns, color=volColor)
plot(volMA, "Volume Baseline", color=color.new(color.gray, 20), linewidth=1)

plot(showFlow ? flow : na, "Volume Flow", color=f_stateColor(flow), linewidth=2)
hline(65, "Strong Bull Zone", color=color.new(color.lime, 75))
hline(25, "Bull Zone", color=color.new(color.lime, 85))
hline(0, "Neutral", color=color.new(color.gray, 70))
hline(-25, "Bear Zone", color=color.new(color.red, 85))
hline(-65, "Strong Bear Zone", color=color.new(color.red, 75))

plot(showCvd ? cvd : na, "CVD", color=color.new(color.blue, 0), linewidth=2)

plotshape(showSignals and bullClimax, "Bullish Volume Climax", shape.triangleup, location.bottom, color=color.lime, size=size.small, text="CLX+")
plotshape(showSignals and bearClimax, "Bearish Volume Climax", shape.triangledown, location.top, color=color.red, size=size.small, text="CLX-")

plotshape(showSignals and bullAbsorption, "Demand Absorption", shape.circle, location.bottom, color=color.aqua, size=size.tiny, text="ABS+")
plotshape(showSignals and bearAbsorption, "Supply Absorption", shape.circle, location.top, color=color.orange, size=size.tiny, text="ABS-")

plotshape(showSignals and bullDiv, "Bullish Volume Divergence", shape.labelup, location.bottom, color=color.new(color.lime, 0), textcolor=color.black, size=size.tiny, text="DIV+")
plotshape(showSignals and bearDiv, "Bearish Volume Divergence", shape.labeldown, location.top, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny, text="DIV-")

bgcolor(bullPressure ? color.new(color.lime, 92) : bearPressure ? color.new(color.red, 92) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard (Dark Mode Optimized)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(position.top_right, 2, 7, border_width=1)

// Theme colors
bgHeader   = color.new(#111827, 0)
bgCell     = color.new(#1F2937, 0)
bgAlt      = color.new(#111827, 0)
txtPrimary = color.new(color.white, 0)
txtMuted   = color.new(color.gray, 20)

// Helper must be OUTSIDE if block
f_row(_row, _label, _value, _color) =>
    bg = _row % 2 == 0 ? bgCell : bgAlt
    table.cell(dash, 0, _row, _label, bgcolor=bg, text_color=txtMuted)
    table.cell(dash, 1, _row, _value, bgcolor=bg, text_color=_color)

if showTable and barstate.islast
    table.cell(dash, 0, 0, "Elaris VIP", bgcolor=bgHeader, text_color=txtPrimary)
    table.cell(dash, 1, 0, "Volume Intelligence", bgcolor=bgHeader, text_color=txtPrimary)

    f_row(1, "State", f_stateText(smartScoreClamped), f_stateColor(smartScoreClamped))
    f_row(2, "Score", str.tostring(smartScoreClamped, "#.##"), f_stateColor(smartScoreClamped))
    f_row(3, "RVOL", str.tostring(rvol, "#.##") + "x", rvol >= highRvol ? color.orange : txtPrimary)
    f_row(4, "Volume Z", str.tostring(volZ, "#.##"), volZ >= zExtreme ? color.orange : txtPrimary)
    f_row(5, "Delta", str.tostring(deltaNorm, "#.##"), deltaNorm >= 0 ? color.lime : color.red)

    signalText =
         bullClimax ? "Bull Climax" :
         bearClimax ? "Bear Climax" :
         bullAbsorption ? "Demand Absorption" :
         bearAbsorption ? "Supply Absorption" :
         bullDiv ? "Bull Divergence" :
         bearDiv ? "Bear Divergence" :
         "No Signal"

    signalColor =
         bullClimax or bullAbsorption or bullDiv ? color.lime :
         bearClimax or bearAbsorption or bearDiv ? color.red :
         txtMuted

    f_row(6, "Signal", signalText, signalColor)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(bullClimax, "Elaris VIP Bullish Volume Climax", "Elaris VIP: Bullish volume climax detected.")
alertcondition(bearClimax, "Elaris VIP Bearish Volume Climax", "Elaris VIP: Bearish volume climax detected.")
alertcondition(bullAbsorption, "Elaris VIP Demand Absorption", "Elaris VIP: Demand absorption detected.")
alertcondition(bearAbsorption, "Elaris VIP Supply Absorption", "Elaris VIP: Supply absorption detected.")
alertcondition(bullDiv, "Elaris VIP Bullish Volume Divergence", "Elaris VIP: Bullish volume/CVD divergence detected.")
alertcondition(bearDiv, "Elaris VIP Bearish Volume Divergence", "Elaris VIP: Bearish volume/CVD divergence detected.")
alertcondition(bullPressure, "Elaris VIP Bullish Pressure", "Elaris VIP: Bullish volume pressure active.")
alertcondition(bearPressure, "Elaris VIP Bearish Pressure", "Elaris VIP: Bearish volume pressure active.")
````
