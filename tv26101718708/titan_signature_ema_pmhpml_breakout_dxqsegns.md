# Titan Signature: EMA + PMH/PML Breakout

- url: https://www.tradingview.com/script/dxQsegNs-Titan-Signature-EMA-PMH-PML-Breakout/
- type: indicator
- pine_id: PUB;1dc2dc7e7a8444fc8e0e119352fdbf3e
- version: 1.0

## Description

this indicator uses a simple method to alert calls or puts on the 5 minute time frame using the 50/200 ema and pre market high pre market low to determine your bullish or bearish bias.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TitanPropFirm_Development

//@version=5
indicator("Titan Signature: EMA + PMH/PML Breakout", overlay=true)

// --- INPUTS ---
ema50Len = input.int(50, "Fast EMA (Red)", minval=1)
ema200Len = input.int(200, "Slow EMA (Blue)", minval=1)
sessionRange = input.session("0400-0930", "Pre-Market Session (EST)")

// --- EMA CALCULATIONS ---
ema50 = ta.ema(close, ema50Len)
ema200 = ta.ema(close, ema200Len)

plot(ema50, color=color.red, linewidth=2, title="50 EMA")
plot(ema200, color=color.blue, linewidth=2, title="200 EMA")

// --- PRE-MARKET STRUCTURAL LEVELS ---
var float pmh = na
var float pml = na

inSession = not na(time(timeframe.period, sessionRange, "America/New_York"))
isNewDay = ta.change(dayofweek)

// Bulletproof inline logic (No indentation required)
pmh := isNewDay ? na : inSession ? math.max(nz(pmh, high), high) : pmh
pml := isNewDay ? na : inSession ? math.min(nz(pml, low), low) : pml

// Plotting PMH/PML (Dashed lines to match your screenshots)
plot(pmh, color=color.new(color.green, 40), style=plot.style_linebr, title="Pre-Market High")
plot(pml, color=color.new(color.red, 40), style=plot.style_linebr, title="Pre-Market Low")

// --- SIGNAL LOGIC ---
// Bullish: Price > 50 AND Price > 200 AND Crosses PMH
longTrigger = (close > ema50) and (close > ema200) and ta.crossover(close, pmh)

// Bearish: Price < 50 AND Price < 200 AND Crosses PML
shortTrigger = (close < ema50) and (close < ema200) and ta.crossunder(close, pml)

// --- VISUAL SIGNALS ---
plotshape(longTrigger, style=shape.labelup, location=location.belowbar, color=color.green, size=size.small, text="CALLS", textcolor=color.white)
plotshape(shortTrigger, style=shape.labeldown, location=location.abovebar, color=color.red, size=size.small, text="PUTS", textcolor=color.white)

// --- ALERT NOTIFICATIONS ---
alertcondition(longTrigger, title="Bullish Breakout", message="TITAN: {{ticker}} Long Above PMH and EMAs")
alertcondition(shortTrigger, title="Bearish Breakout", message="TITAN: {{ticker}} Short Below PML and EMAs")
````
