# Momentum Tide @darshakssc

- url: https://www.tradingview.com/script/LecxTR7s-Momentum-Tide-darshakssc/
- type: indicator
- pine_id: PUB;c26915e96be045eeb0488508227a89bb
- version: 1.0

## Description

Momentum Tide is an adaptive gradient-fill RSI oscillator. Instead of a smoothed RSI line 
with fixed overbought/oversold zone colors, momentum is visualized as a single "tide" — a 
continuous gradient fill between the smoothed RSI and the midline, where fill intensity 
scales with distance from midline rather than using discrete zone bands.

🔶 HOW IT WORKS
RSI is smoothed with an EMA, then plotted against an adaptive overbought/oversold reference 
calculated from the rolling standard deviation of RSI (not fixed 70/30 levels), so the tool 
self-adjusts across instruments and timeframes. An ATR-based volatility filter suppresses 
signals during low-momentum chop.

🔶 HOW TO USE
- Green tide + rising = building bullish momentum. Red tide + falling = building bearish momentum.
- Triangle markers = confirmed midline momentum shift (bar-close confirmed, non-repainting).
- Circle markers = reversal signal from the adaptive extreme zone.
- Dashboard (top-right) shows live RSI value, tide state, and momentum strength %.

🔶 SETTINGS
RSI Length, Smoothing Length, ATR Filter Length/Ratio, Adaptive Lookback, Adaptive Band Width.

🔶 LIMITATIONS
This is a momentum-visualization tool, not a standalone entry system. Best combined with 
structure/S-R context. Can flip state more frequently in low-volatility, range-bound sessions.

For educational/informational purposes only. Not financial advice. Past performance does 
not guarantee future results. Always use proper risk management.

## Source Code

````pine
// @darshakssc — Radhe Radhe 🙏
//@version=6
indicator("Momentum Tide [Original]", shorttitle="MomTide", overlay=false)

// ───────────────────────── INPUTS ─────────────────────────
grpCore = "Core Settings"
rsiLen     = input.int(14, "RSI Length", minval=2, group=grpCore)
rsiSrc     = input.source(close, "RSI Source", group=grpCore)
smoothLen  = input.int(5, "Tide Smoothing Length", minval=1, group=grpCore)

grpFilter = "Noise Filter"
atrLen     = input.int(14, "ATR Filter Length", minval=1, group=grpFilter)
atrMult    = input.float(0.8, "Min Volatility Ratio (ATR / ATR-Avg)", minval=0.1, step=0.1, group=grpFilter)

grpAdaptive = "Adaptive Zones"
adaptiveLen = input.int(100, "Adaptive Lookback", minval=20, group=grpAdaptive)
adaptiveMult = input.float(1.5, "Adaptive Band Width (x StdDev)", minval=0.5, step=0.1, group=grpAdaptive)

grpDisplay = "Display"
showSignals   = input.bool(true, "Show Signal Markers", group=grpDisplay)
showDashboard = input.bool(true, "Show Dashboard", group=grpDisplay)
bullColor     = input.color(#00c896, "Bullish Color", group=grpDisplay)
bearColor     = input.color(#ff4d6d, "Bearish Color", group=grpDisplay)

// ───────────────────────── CALCULATIONS (global scope) ─────────────────────────
rsiRaw     = ta.rsi(rsiSrc, rsiLen)
rsiSmooth  = ta.ema(rsiRaw, smoothLen)

atrVal     = ta.atr(atrLen)
atrAvg     = ta.sma(atrVal, atrLen)
volOk      = atrVal >= atrAvg * atrMult

rsiMean    = ta.sma(rsiSmooth, adaptiveLen)
rsiStdev   = ta.stdev(rsiSmooth, adaptiveLen)
upperAdaptive = rsiMean + rsiStdev * adaptiveMult
lowerAdaptive = rsiMean - rsiStdev * adaptiveMult

midline    = 50.0
distance   = rsiSmooth - midline
maxDist    = 50.0
intensity  = math.min(math.abs(distance) / maxDist, 1.0)

// ───────────────────────── NON-REPAINTING SIGNALS ─────────────────────────
// ta.crossover/crossunder are hoisted to global scope (evaluated every bar) before
// being combined into conditional expressions, per Pine v6 consistency rules.
crossUpMid    = ta.crossover(rsiSmooth, midline)
crossDnMid    = ta.crossunder(rsiSmooth, midline)
crossUpLower  = ta.crossover(rsiSmooth, lowerAdaptive)
crossDnUpper  = ta.crossunder(rsiSmooth, upperAdaptive)

bullShift    = barstate.isconfirmed and volOk and crossUpMid
bearShift    = barstate.isconfirmed and volOk and crossDnMid
bullReversal = barstate.isconfirmed and crossUpLower
bearReversal = barstate.isconfirmed and crossDnUpper

// ───────────────────────── PLOTTING ─────────────────────────
tideColor = distance >= 0 ?
     color.from_gradient(intensity, 0, 1, color.new(bullColor, 85), color.new(bullColor, 10)) :
     color.from_gradient(intensity, 0, 1, color.new(bearColor, 85), color.new(bearColor, 10))

lineColor = distance >= 0 ? bullColor : bearColor

pTide = plot(rsiSmooth, "Tide Line", color=lineColor, linewidth=2)
pMid  = plot(midline, "Midline", color=color.new(color.gray, 40), linewidth=1)
fill(pTide, pMid, color=tideColor, title="Tide Fill")

plot(upperAdaptive, "Adaptive Upper", color=color.new(bearColor, 70), style=plot.style_circles)
plot(lowerAdaptive, "Adaptive Lower", color=color.new(bullColor, 70), style=plot.style_circles)

plotshape(showSignals and bullShift, "Bullish Momentum Shift", shape.triangleup, location.bottom, color=bullColor, size=size.tiny)
plotshape(showSignals and bearShift, "Bearish Momentum Shift", shape.triangledown, location.top, color=bearColor, size=size.tiny)
plotshape(showSignals and bullReversal, "Oversold Reversal", shape.circle, location.bottom, color=color.yellow, size=size.tiny)
plotshape(showSignals and bearReversal, "Overbought Reversal", shape.circle, location.top, color=color.orange, size=size.tiny)

// ───────────────────────── DASHBOARD ─────────────────────────
var table dash = table.new(position.top_right, 2, 4, bgcolor=color.new(#1a1a2e, 15), border_width=1, border_color=color.new(color.gray, 60))

if barstate.islast and showDashboard
    stateText  = distance > 5 ? "Bullish Tide" : distance < -5 ? "Bearish Tide" : "Neutral"
    stateColor = distance > 5 ? bullColor : distance < -5 ? bearColor : color.gray
    table.cell(dash, 0, 0, "Momentum Tide", text_color=color.white, text_size=size.small, bgcolor=color.new(#1a1a2e, 0))
    table.cell(dash, 1, 0, "", bgcolor=color.new(#1a1a2e, 0))
    table.cell(dash, 0, 1, "RSI", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(rsiSmooth, "#.##"), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 2, "State", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 2, stateText, text_color=stateColor, text_size=size.small)
    table.cell(dash, 0, 3, "Strength", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(intensity * 100, "#.#") + "%", text_color=stateColor, text_size=size.small)

// ───────────────────────── ALERTS ─────────────────────────
alertcondition(bullShift, "Bullish Momentum Shift", "Momentum Tide turned bullish — RSI crossed above midline with volatility confirmation.")
alertcondition(bearShift, "Bearish Momentum Shift", "Momentum Tide turned bearish — RSI crossed below midline with volatility confirmation.")
alertcondition(bullReversal, "Oversold Reversal", "Momentum Tide reversal from adaptive oversold zone.")
alertcondition(bearReversal, "Overbought Reversal", "Momentum Tide reversal from adaptive overbought zone.")
````
