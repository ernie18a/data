# Premium Flow MACD

- url: https://www.tradingview.com/script/a9HbC3dK-Premium-Flow-MACD/
- type: indicator
- pine_id: PUB;2d8f2ca2d7bb4ba9b320c368f3211c1e
- version: 1.0

## Description

📊 Premium Flow MACD

Premium Flow MACD is an enhanced Moving Average Convergence Divergence indicator that combines momentum, liquidity sweeps, and market reaction to identify high-probability entries.
It integrates:

[list]
[*]Projected momentum (early signals before zero-line cross)
[*]Liquidity detection (stop hunts at highs/lows)
[*]Reaction filters (displacement candles & volume spikes)
[/list]

The Flow Ribbon visualization provides a smooth view of trend strength, momentum shifts, and acceleration.

✔️ Signals
[list]
[*]Early + confirmed long/short entries
[*]Optional bar-close confirmation
[*]Clean chart markers + alerts
[/list]
⚠️ Notes
[list]
[*]Mix of predictive and confirmatory logic
[*]Best suited for volatile, liquidity-driven markets
[/list]

Built for traders focusing on precision entries and momentum timing.

## Source Code

````pine
//@version=6
indicator("Premium Flow MACD", shorttitle="Flow MACD", overlay=false, max_labels_count=500)
// ===== INPUTS =====
fastLen = input.int(12, "Fast Length")
slowLen = input.int(26, "Slow Length")
sigLen  = input.int(9, "Signal Length")
projBars  = input.int(3, "Projection Bars")
tolerance = input.float(0.00005, "Zero Tolerance")
lookbackSweep = input.int(5, "Sweep Lookback")
maxSweepBars  = input.int(5, "Max Bars After Sweep")
volMult       = input.float(1.2, "Volume Spike Multiplier")
dispBodyRatio = input.float(0.6, "Displacement Strength")
maxHistForEntry = input.float(150.0, "Max Hist Distance For Signal")
histRange      = input.float(2500.0, "Visual Range")
flowSmoothing  = input.int(3, "Flow Smoothing", minval=1)
signalSmoothing = input.int(5, "Wave Smoothing", minval=1)
showBarSignals = input.bool(true, "Show Price Signal Markers")
confirmOnClose = input.bool(true, "Only Confirm On Bar Close")
// ===== MACD CORE =====
macd   = ta.ema(close, fastLen) - ta.ema(close, slowLen)
signal = ta.ema(macd, sigLen)
hist   = macd - signal
// ===== PROJECTION =====
histLrNow  = ta.linreg(hist, 3, 0)
histLrPrev = ta.linreg(hist, 3, 1)
slope      = histLrNow - histLrPrev
histProj   = hist + slope * projBars
// ===== SIGNAL CONDITIONS =====
earlyLong  = hist < tolerance and histProj > 0
earlyShort = hist > -tolerance and histProj < 0
confirmLong  = ta.crossover(hist, 0)
confirmShort = ta.crossunder(hist, 0)
longCond  = earlyLong or confirmLong
shortCond = earlyShort or confirmShort
// ===== LIQUIDITY TRACKING =====
prevLowest  = ta.lowest(low[1], lookbackSweep)
prevHighest = ta.highest(high[1], lookbackSweep)
var bool sweptLow = false
var bool sweptHigh = false
var int sweepBarsLow = 0
var int sweepBarsHigh = 0
sweepLow  = low < prevLowest
sweepHigh = high > prevHighest
if sweepLow
    sweptLow := true
    sweepBarsLow := 0
else if sweptLow
    sweepBarsLow += 1
if sweepHigh
    sweptHigh := true
    sweepBarsHigh := 0
else if sweptHigh
    sweepBarsHigh += 1
if sweepBarsLow > maxSweepBars
    sweptLow := false
if sweepBarsHigh > maxSweepBars
    sweptHigh := false
validSweepLow  = sweptLow and sweepBarsLow <= maxSweepBars
validSweepHigh = sweptHigh and sweepBarsHigh <= maxSweepBars
// ===== REACTION =====
body = math.abs(close - open)
candleRange = high - low + 1e-10
bodyRatio = body / candleRange
bullDisplacement = bodyRatio > dispBodyRatio and close > open
bearDisplacement = bodyRatio > dispBodyRatio and close < open
volSpike = volume > ta.sma(volume, 20) * volMult
reactionLong  = bullDisplacement or (volSpike and close > open)
reactionShort = bearDisplacement or (volSpike and close < open)
// ===== FRESH MOMENTUM FILTER =====
freshLong  = hist < maxHistForEntry and hist > hist[1]
freshShort = hist > -maxHistForEntry and hist < hist[1]
// ===== FINAL SIGNALS =====
longSignalRaw  = validSweepLow and reactionLong and longCond and freshLong and not (validSweepLow[1] and reactionLong[1] and longCond[1] and freshLong[1])
shortSignalRaw = validSweepHigh and reactionShort and shortCond and freshShort and not (validSweepHigh[1] and reactionShort[1] and shortCond[1] and freshShort[1])
longSignal  = confirmOnClose ? (longSignalRaw and barstate.isconfirmed) : longSignalRaw
shortSignal = confirmOnClose ? (shortSignalRaw and barstate.isconfirmed) : shortSignalRaw
if longSignal
    sweptLow := false
    sweepBarsLow := 0
if shortSignal
    sweptHigh := false
    sweepBarsHigh := 0
// ===== FLOW ENGINE =====
flowBase   = ta.ema(hist, flowSmoothing)
flowWave   = ta.ema(histProj, signalSmoothing)
flowRibbon = ta.ema((flowBase + flowWave) * 0.5, 2)
flowDelta  = flowRibbon - flowRibbon[1]
visualClamp = math.max(histRange * 0.12, 1.0)
bullCore = color.rgb(25, 220, 170)
bearCore = color.rgb(255, 96, 122)
bullGlow = color.rgb(80, 255, 220)
bearGlow = color.rgb(255, 150, 170)
neutralCore = color.rgb(114, 132, 168)
flowColor = color.from_gradient(flowRibbon, -visualClamp, visualClamp, bearCore, bullCore)
waveColor = color.from_gradient(flowWave, -visualClamp, visualClamp, color.rgb(138, 88, 255), color.rgb(255, 196, 92))
deltaColor = flowDelta >= 0 ? bullGlow : bearGlow
zeroColor = color.new(neutralCore, 82)
// ===== PREMIUM VISUALS =====
zeroPlot = plot(0, title="Zero Line", color=zeroColor, linewidth=1)
glowLower = plot(flowRibbon, title="Flow Glow Outer", color=color.new(flowColor, 86), linewidth=10)
glowMid   = plot(flowRibbon, title="Flow Glow Mid", color=color.new(flowColor, 70), linewidth=7)
flowPlot  = plot(flowRibbon, title="Flow Ribbon", color=flowColor, linewidth=3)
wavePlot  = plot(flowWave, title="Projection Wave", color=waveColor, linewidth=2)
histTop = plot(flowRibbon, title="Flow Area Top", display=display.none)
histBot = plot(0, title="Flow Area Bottom", display=display.none)
fill(histTop, histBot, title="Flow Fill", color=color.new(flowColor, 88))
spreadTop = plot(math.max(flowRibbon, flowWave), title="Spread Top", display=display.none)
spreadBot = plot(math.min(flowRibbon, flowWave), title="Spread Bottom", display=display.none)
fill(spreadTop, spreadBot, title="Ribbon Spread", color=color.new(deltaColor, 84))
plot(flowDelta * 0.6, title="Pulse Columns", style=plot.style_columns, color=color.new(deltaColor, 30), linewidth=3)
plotshape(longSignal, title="Long Signal", location=location.bottom, style=shape.circle, size=size.tiny, color=color.new(bullGlow, 0), text="L", textcolor=color.black)
plotshape(shortSignal, title="Short Signal", location=location.top, style=shape.circle, size=size.tiny, color=color.new(bearGlow, 0), text="S", textcolor=color.black)
barcolor(showBarSignals ? (longSignal ? color.new(bullCore, 0) : shortSignal ? color.new(bearCore, 0) : na) : na)
plotshape(showBarSignals and longSignal, title="Long Marker On Price", location=location.belowbar, style=shape.triangleup, size=size.small, color=color.new(bullGlow, 0), text="FLOW", textcolor=color.black, force_overlay=true)
plotshape(showBarSignals and shortSignal, title="Short Marker On Price", location=location.abovebar, style=shape.triangledown, size=size.small, color=color.new(bearGlow, 0), text="FLOW", textcolor=color.black, force_overlay=true)
// ===== INFO LINES =====
plot(macd, title="MACD Base", color=color.new(color.rgb(120, 180, 255), 75), linewidth=1)
plot(signal, title="Signal Base", color=color.new(color.rgb(255, 170, 86), 78), linewidth=1)
// ===== ALERTS =====
alertcondition(longSignal, title="PREMIUM FLOW LONG", message="Premium Flow MACD Long Signal")
alertcondition(shortSignal, title="PREMIUM FLOW SHORT", message="Premium Flow MACD Short Signal")
````
