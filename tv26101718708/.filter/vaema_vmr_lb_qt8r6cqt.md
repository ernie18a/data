# V-AEMA VMR [LB]

- url: https://www.tradingview.com/script/qt8R6Cqt/
- type: indicator
- pine_id: PUB;7a838921f6904081a80311c2c9af97de
- version: 1.0

## Description

[b]Concept[/b]
The V-AEMA VMR (Volume-Adaptive Exponential Moving Average with Volatility-Modulated Regime) is a hybrid trend-following indicator that combines an EMA baseline with a volatility-based drift component. It produces a dynamic core line whose colour reflects the trend regime, surrounded by two levels of adaptive bands that expand or contract based on volume intensity. The indicator generates directional entry signals when price breaks the first band in the direction of the trend, and projects take-profit zones when price fully exits both bands.

[b]Mathematical Foundation[/b]
The core line (Hybrid Line) is a weighted blend of a standard EMA and a volatility-shifted version of that same EMA :

[i]HybridLine = EMA * W + (EMA + Drift) * (1 - W)[/i]

where the drift is derived from the Z-Score of price relative to the EMA, scaled by ATR :

[i]Drift = Z_Score * ATR * 0.35[/i]
[i]Z_Score = (Price - EMA) / StdDev(Price, L_vola)[/i]

Band width starts from a base volatility measure combining standard deviation and ATR :

[i]BaseWidth = StdDev * 0.65 + ATR * 0.35[/i]

This base is then adjusted by a volume ratio and user-defined multipliers :

[i]UpperWidth = BaseWidth * (BaseUpMult + (VolRatio - 1) * VolImpactUp)[/i]
[i]LowerWidth = BaseWidth * (BaseDnMult + (VolRatio - 1) * VolImpactDn)[/i]

where [i]VolRatio = min(max(Volume / SMA(Volume, L_vol), 0.35), 2.50)[/i].

Two band levels are generated : Band 1 at HybridLine +/- Width, and Band 2 (extreme) at HybridLine +/- Width * 1.55 (upper) / 1.40 (lower).

[b]What Problem Does It Solve ?[/b]
Conventional envelope indicators (Bollinger Bands, Keltner Channels) apply fixed multipliers to a single volatility metric and ignore volume dynamics. The V-AEMA VMR adapts its band width to both volatility and volume surges, producing wider bands during high-participation moves and narrower bands during quiet periods. The hybrid core line reduces pure EMA lag by incorporating a volatility offset, while the dual-band structure filters signals by strength : a break of Band 1 triggers an entry, while a break of Band 2 confirms an explosive move and projects a take-profit zone.

[b]How To Interpret[/b]

[i]Core line colour[/i] – cyan/green indicates the hybrid line is rising (bull regime) ; magenta/red indicates it is falling (bear regime).

[i]Cloud and bands[/i] – the area between Band 1 and Band 2 forms a halo that thickens when volume expands. Narrow bands suggest low conviction or consolidation.

[i]Entry signals[/i] – a triangle appears below the bar when price crosses above Upper Band 1 while the hybrid line is rising (long). A triangle appears above the bar when price crosses below Lower Band 1 while the hybrid line is falling (short). These signals are confirmed by the trend direction.

[i]Take-profit zones[/i] – when the entire bar (high and low for shorts, low and high for longs) clears the extreme band (Band 2) in the direction of the signal, a coloured box is projected forward. The box represents a potential target zone based on the breakout amplitude and ATR, scaled by the TP Factor.

[i]Info panel[/i] – displays the current regime (BULL/BEAR), the volume ratio (values above 1.0 indicate above-average participation), and the current upper/lower deviation values in price units.

[b]Parameters[/b]

[b]EMA Length[/b] – period of the base exponential moving average (default 55).
[b]Volatility Length[/b] – period for the standard deviation used in the Z-Score calculation (default 34).
[b]Volume Length[/b] – period for the volume moving average used in the volume ratio (default 34).
[b]EMA Weight[/b] – blend ratio between the pure EMA and the volatility-drifted version. Higher values produce a smoother line ; lower values make it more reactive to volatility (default 0.80).
[b]Upper Base Deviation[/b] – core multiplier for the upper band width before volume adjustment (default 1.55).
[b]Lower Base Deviation[/b] – core multiplier for the lower band width before volume adjustment (default 1.05).
[b]Volume Impact Upper/Lower[/b] – sensitivity of the upper and lower bands to the volume ratio. Higher values make bands expand more aggressively when volume surges (default 0.95 / 0.55).
[b]ATR Length[/b] – period of the Average True Range used in band width and TP zone calculations (default 14).
[b]Show Cloud[/b] – toggles the filled areas between bands.
[b]Show Info Panel[/b] – toggles the real-time dashboard.
[b]Show Signals[/b] – toggles the entry triangles.
[b]Show TP Zones[/b] – toggles the take-profit projection boxes.
[b]TP Projection Bars[/b] – how many bars forward the TP zone extends.
[b]TP Factor[/b] – scales the height of the TP zone relative to the breakout range.
[b]Max Historical TP Zones[/b] – limits the number of TP boxes kept on the chart.

[b]Reference[/b]
This indicator is a proprietary design synthesising concepts from adaptive moving averages (Kaufman, Ehlers), volatility envelopes (Bollinger, Keltner), and volume-weighted band models. It does not correspond to a single academic publication.

## Source Code

````pine
//@version=6
indicator("V-AEMA VMR", "V-AEMA [LB]", overlay=true, max_bars_back=500)

//---------------------------------------------------------
// Inputs
//---------------------------------------------------------
src         = input.source(close, "Source")
emaLen      = input.int(55, "EMA Length", minval=1)
volaLen     = input.int(34, "Volatility Length", minval=2)
volLen      = input.int(34, "Volume Length", minval=2)

emaWeight   = input.float(0.80, "EMA Weight", minval=0.0, maxval=1.0, step=0.05)
volaWeight  = 1.0 - emaWeight

baseUpMult  = input.float(1.55, "Upper Base Deviation", minval=0.1, step=0.05)
baseDnMult  = input.float(1.05, "Lower Base Deviation", minval=0.1, step=0.05)

volImpactUp = input.float(0.95, "Volume Impact Upper", minval=0.0, step=0.05)
volImpactDn = input.float(0.55, "Volume Impact Lower", minval=0.0, step=0.05)

atrLen      = input.int(14, "ATR Length", minval=1)
showCloud   = input.bool(true, "Show Cloud")
showPanel   = input.bool(true, "Show Info Panel")
showSignals = input.bool(true, "Show Signals")

showTPZone  = input.bool(true, "Show TP Zones")
tpProjBars  = input.int(12, "TP Projection Bars", minval=2)
tpFactor    = input.float(0.80, "TP Factor", minval=0.1, step=0.05)
maxTPZones  = input.int(30, "Max Historical TP Zones", minval=1, maxval=200)

//---------------------------------------------------------
// Core
//---------------------------------------------------------
emaBase     = ta.ema(src, emaLen)
stdevSrc    = ta.stdev(src, volaLen)
atrVal      = ta.atr(atrLen)

volMA       = ta.sma(volume, volLen)
volRatioRaw = volMA > 0 ? volume / volMA : 1.0
volRatio    = math.min(math.max(volRatioRaw, 0.35), 2.50)

zScore      = stdevSrc > 0 ? (src - emaBase) / stdevSrc : 0.0
volaDrift   = zScore * atrVal * 0.35
hybridLine  = emaBase * emaWeight + (emaBase + volaDrift) * volaWeight

baseWidth   = stdevSrc * 0.65 + atrVal * 0.35

upperWidth  = baseWidth * (baseUpMult + (volRatio - 1.0) * volImpactUp)
lowerWidth  = baseWidth * (baseDnMult + (volRatio - 1.0) * volImpactDn)

upperWidth  := math.max(upperWidth, syminfo.mintick * 10)
lowerWidth  := math.max(lowerWidth, syminfo.mintick * 10)

upperBand1  = hybridLine + upperWidth
lowerBand1  = hybridLine - lowerWidth
upperBand2  = hybridLine + upperWidth * 1.55
lowerBand2  = hybridLine - lowerWidth * 1.40

//---------------------------------------------------------
// Vivid style
//---------------------------------------------------------
bullLine    = color.rgb(0, 255, 200)
bearLine    = color.rgb(255, 65, 120)
sunGlow     = color.rgb(255, 220, 70)

upperBright = color.rgb(0, 255, 220)
upperSoft   = color.rgb(90, 255, 235)

lowerBright = color.rgb(255, 70, 140)
lowerSoft   = color.rgb(255, 150, 200)

slopeUp     = hybridLine >= hybridLine[1]
coreColor   = slopeUp ? bullLine : bearLine

//---------------------------------------------------------
// Plots
//---------------------------------------------------------
pUpper2 = plot(upperBand2, "Upper Extreme", color=color.new(upperSoft, 80), linewidth=1)
pUpper1 = plot(upperBand1, "Upper Band",    color=color.new(upperBright, 10), linewidth=1)

pMidA   = plot(hybridLine, "Hybrid Glow",   color=color.new(coreColor, 68), linewidth=1)
pMidB   = plot(hybridLine, "Hybrid EMA",    color=color.new(coreColor, 0),  linewidth=1)
pMidC   = plot(hybridLine, "Hybrid Shine",  color=color.new(sunGlow, 82),   linewidth=1)

pLower1 = plot(lowerBand1, "Lower Band",    color=color.new(lowerBright, 10), linewidth=1)
pLower2 = plot(lowerBand2, "Lower Extreme", color=color.new(lowerSoft, 80), linewidth=1)

//---------------------------------------------------------
// Fills
//---------------------------------------------------------
fill(pUpper1, pUpper2, color = showCloud ? color.new(upperBright, 90) : na, title="Upper Halo")
fill(pLower1, pLower2, color = showCloud ? color.new(lowerBright, 90) : na, title="Lower Halo")
fill(pUpper1, pMidB,   color = showCloud ? color.new(upperBright, 94) : na, title="Upper Core")
fill(pMidB, pLower1,   color = showCloud ? color.new(lowerBright, 94) : na, title="Lower Core")

//---------------------------------------------------------
// Signals
//---------------------------------------------------------
longBreak   = ta.crossover(src, upperBand1)
shortBreak  = ta.crossunder(src, lowerBand1)

longFilter  = hybridLine > hybridLine[1]
shortFilter = hybridLine < hybridLine[1]

longSignal  = showSignals and longBreak and longFilter
shortSignal = showSignals and shortBreak and shortFilter

plotshape(longSignal,  title="Long Signal",  style=shape.triangleup,   location=location.belowbar, color=color.new(bullLine, 0), text="L", textcolor=color.white, size=size.tiny)
plotshape(shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=color.new(bearLine, 0), text="S", textcolor=color.white, size=size.tiny)

//---------------------------------------------------------
// Historical TP zones
//---------------------------------------------------------
fullBreakUp   = close > upperBand2 and low > upperBand1
fullBreakDown = close < lowerBand2 and high < lowerBand1

newUpEvent    = fullBreakUp and not fullBreakUp[1]
newDownEvent  = fullBreakDown and not fullBreakDown[1]

var box[]   tpBoxes  = array.new_box()
var line[]  tpLines  = array.new_line()
var label[] tpLabels = array.new_label()

if showTPZone and newUpEvent
    tpBase   = close
    tpRange  = math.max(close - upperBand2, atrVal * 0.35)
    tpTop    = tpBase + tpRange * tpFactor
    tpBottom = tpBase + tpRange * tpFactor * 0.35
    tpMidY   = (tpTop + tpBottom) / 2.0

    b = box.new(left=bar_index, top=tpTop, right=bar_index + tpProjBars, bottom=tpBottom, bgcolor=color.new(bullLine, 82), border_color=color.new(bullLine, 0), border_width=1)
    l = line.new(x1=bar_index, y1=tpMidY, x2=bar_index + tpProjBars, y2=tpMidY, color=color.new(color.white, 15), width=1)
    lb = label.new(bar_index + tpProjBars, tpTop, "TP", style=label.style_label_down, textcolor=color.white, color=color.new(bullLine, 10), size=size.tiny)

    array.push(tpBoxes, b)
    array.push(tpLines, l)
    array.push(tpLabels, lb)

if showTPZone and newDownEvent
    tpBase   = close
    tpRange  = math.max(lowerBand2 - close, atrVal * 0.35)
    tpTop    = tpBase - tpRange * tpFactor * 0.35
    tpBottom = tpBase - tpRange * tpFactor
    tpMidY   = (tpTop + tpBottom) / 2.0

    b = box.new(left=bar_index, top=tpTop, right=bar_index + tpProjBars, bottom=tpBottom, bgcolor=color.new(bearLine, 82), border_color=color.new(bearLine, 0), border_width=1)
    l = line.new(x1=bar_index, y1=tpMidY, x2=bar_index + tpProjBars, y2=tpMidY, color=color.new(color.white, 15), width=1)
    lb = label.new(bar_index + tpProjBars, tpBottom, "TP", style=label.style_label_up, textcolor=color.white, color=color.new(bearLine, 10), size=size.tiny)

    array.push(tpBoxes, b)
    array.push(tpLines, l)
    array.push(tpLabels, lb)

// Keep chart clean
while array.size(tpBoxes) > maxTPZones
    oldBox = array.shift(tpBoxes)
    box.delete(oldBox)

while array.size(tpLines) > maxTPZones
    oldLine = array.shift(tpLines)
    line.delete(oldLine)

while array.size(tpLabels) > maxTPZones
    oldLabel = array.shift(tpLabels)
    label.delete(oldLabel)

//---------------------------------------------------------
// Alerts
//---------------------------------------------------------
alertcondition(longSignal,   title="V-AEMA Long",            message="V-AEMA VMR Long Signal")
alertcondition(shortSignal,  title="V-AEMA Short",           message="V-AEMA VMR Short Signal")
alertcondition(newUpEvent,   title="V-AEMA Full Break Up",   message="Price exited all upper bands")
alertcondition(newDownEvent, title="V-AEMA Full Break Down", message="Price exited all lower bands")

//---------------------------------------------------------
// Info panel
//---------------------------------------------------------
var table t = table.new(position.top_right, 2, 4, border_width=1)

if barstate.islast and showPanel
    regime = slopeUp ? "BULL" : "BEAR"

    table.cell(t, 0, 0, "V-AEMA VMR", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 0, regime, text_color=color.white, bgcolor=slopeUp ? color.new(bullLine, 25) : color.new(bearLine, 25))

    table.cell(t, 0, 1, "Vol Ratio", text_color=color.white, bgcolor=color.new(color.black, 35))
    table.cell(t, 1, 1, str.tostring(volRatio, "#.##"), text_color=sunGlow, bgcolor=color.new(color.black, 72))

    table.cell(t, 0, 2, "Upper Dev", text_color=color.white, bgcolor=color.new(color.black, 35))
    table.cell(t, 1, 2, str.tostring(upperWidth, format.mintick), text_color=upperBright, bgcolor=color.new(color.black, 72))

    table.cell(t, 0, 3, "Lower Dev", text_color=color.white, bgcolor=color.new(color.black, 35))
    table.cell(t, 1, 3, str.tostring(lowerWidth, format.mintick), text_color=lowerBright, bgcolor=color.new(color.black, 72))

if barstate.islast and not showPanel
    table.clear(t, 0, 0, 1, 3)
````
