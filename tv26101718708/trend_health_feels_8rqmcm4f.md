# Trend Health [FEELS]

- url: https://www.tradingview.com/script/8rqMCm4f-Trend-Health-FEELS/
- type: indicator
- pine_id: PUB;a3bfbbed159a4e25b0692859e4523393
- version: 1.0

## Description

A trend rarely dies suddenly. It fades first: the move gets inefficient and counter-trend candles grow heavier. Trend Health paints that fading straight onto a supertrend-style ATR trail, and tightens the stop while it happens.

The band is saturated green or red while the trend is strong. As health decays the color drains toward amber, an amber dot prints where the dying starts, and the trail contracts under price so a weak trend exits earlier than a fixed stop would.

[b]QUICK START[/b]

Add it to a chart and read the color. Bright band: trend intact, trail at full width. Fading band: trend losing quality, stop contracting. Amber band: dying trend, elevated flip risk. Scroll the history: most flips carry an amber warning dot some bars before them. The strip along the bottom compresses the full health history into one regime line, and the label at the right edge shows direction, state and the current health score.

[b]HOW IT WORKS[/b]

Two layers: a health score, and a trail that consumes it.

Health score, computed every bar over the Health lookback window:

1. Directional efficiency. Kaufman efficiency ratio (net move divided by the sum of absolute bar-to-bar moves), zeroed when the net move points against the active trend, normalized so a reading of 0.5 counts as fully efficient.

2. Momentum side. RSI distance from the 50 line in the direction of the trend, scaled over 25 points.

3. Impulse asymmetry. Candle bodies printed with the trend versus against it over the window. When counter-trend bodies grow, this component decays before price structure breaks.

These three form the core score (weights 0.45 / 0.30 / 0.25). The displayed health adds a fourth read, the distance between price and the trail in ATR units, at 25 percent weight. The score is EMA-smoothed and resets on every flip.

The trail is a ratchet ATR stop built from scratch. Base width is ATR times the multiplier. With Adaptive tightening on, the effective multiplier is scaled by the core score, so a healthy trend trails at full width while a dying trend gets a progressively tighter stop. The distance component is excluded from the core on purpose, otherwise tightening would lower the score and tighten further in a loop. Toggle it off and you get a classic fixed-width trail; the health engine then only drives the color.

https://www.tradingview.com/x/MtGG1FTU/

[b]HOW TO USE[/b]

- Color is the instruction. Enter or hold on a saturated band, tighten manually or stand aside on amber.
- The dying alert fires when health crosses under the threshold while the trend is still running. On past data many flips were preceded by exactly this transition. Treat it as a condition read, not a forecast.
- Four alerts: flip up, flip down, trend dying, trend recovered.
- Designed on 4H to 1W. Works on any symbol and timeframe; on low timeframes expect more flips, especially in ranges with adaptive mode on.

https://www.tradingview.com/x/hiHtLoUw/

PARAMETERS

- ATR length / ATR multiplier: trail geometry at full health.
- Adaptive tightening: health-driven contraction of the trail, on by default.
- Health lookback: window for the efficiency, momentum and asymmetry reads.
- Health smoothing: EMA on the raw score.
- Dying threshold: below this level the trend counts as dying; drives the amber floor, the warning dot, the label and the alert.
- Display toggles: trend fill, bar coloring, flip markers, dying warnings, health ribbon, status label.
- Sizing: marker size, label size and trail width are adjustable.

[b]NOTES[/b]

- The trail state confirms at bar close. On the live bar the level and color can update until close.
- Health describes the present condition of the trend. It does not predict future prices.
- A dying warning is a condition mark, not an exit signal: health can recover and the trend can resume. Sharp reversals can flip a trend straight from high health without any warning printed.
- Adaptive mode trades later giveback for earlier exits, so in choppy ranges it flips more often than a fixed trail. That is the design, not a defect.

[b]ORIGINALITY[/b]

The ratchet ATR trail is a classic public-domain concept reimplemented from scratch. What is original here is the three-component health model, the gradient mapping of that score onto the trail, bars and ribbon, and the feedback of the score into the stop width itself, which makes the flip points measurably different from a standard fixed-factor trail. RSI and the efficiency ratio are not displayed as separate indicators; they exist only as inputs to one scoring model. This is a single system, not a mashup.

## Source Code

````pine
//@version=6
indicator("Trend Health [FEELS]", overlay = true)

//--- inputs
atrLen     = input.int(10, "ATR length", minval = 1, group = "Engine", tooltip = "Lookback for the ATR behind the trailing stop")
factor     = input.float(3.0, "ATR multiplier", minval = 0.5, step = 0.25, group = "Engine", tooltip = "Trail width at full trend health, in ATRs")
adaptTrail = input.bool(true, "Adaptive tightening", group = "Engine", tooltip = "Contract the trail as trend health falls so weak trends exit earlier, off = fixed-width trail")
healthLen  = input.int(20, "Health lookback", minval = 5, group = "Engine", tooltip = "Window for the efficiency, momentum and impulse reads that feed the health score")
smoothLen  = input.int(4, "Health smoothing", minval = 1, group = "Engine", tooltip = "EMA applied to the raw health score, resets on trend flip")
dyingLvl   = input.float(0.35, "Dying threshold", minval = 0.05, maxval = 0.5, step = 0.05, group = "Engine", tooltip = "Health below this level counts as a dying trend")
showFill   = input.bool(true, "Trend fill", group = "Display", tooltip = "Shade the space between price and the trail")
paintBars  = input.bool(true, "Color bars by health", group = "Display", tooltip = "Candles take the band color")
showFlips  = input.bool(true, "Flip markers", group = "Display", tooltip = "Triangles at trend flips")
showWarn   = input.bool(true, "Dying warnings", group = "Display", tooltip = "Amber dot on the trail when health crosses under the dying threshold while the trend is still running")
showRibbon = input.bool(true, "Health ribbon", group = "Display", tooltip = "Compressed health history strip along the bottom of the chart")
showStatus = input.bool(true, "Status label", group = "Display", tooltip = "Current direction, state and health at the right edge")
markSize   = input.string("Tiny", "Marker size", options = ["Tiny", "Small", "Normal", "Large"], group = "Display", tooltip = "Flip markers, warning dots and ribbon, bump it up for screenshots")
lblSize    = input.string("Small", "Label size", options = ["Small", "Normal", "Large", "Huge"], group = "Display", tooltip = "Status label text, bump it up for screenshots")
lineW      = input.int(3, "Trail width", minval = 1, maxval = 6, group = "Display", tooltip = "Thickness of the trail line")

//--- health-driven trail
atr = ta.atr(atrLen)
var float core = 1.0
effFactor = adaptTrail ? factor * (0.55 + 0.45 * core) : factor
lo = hl2 - effFactor * atr
hi = hl2 + effFactor * atr

var float loBand = na
var float hiBand = na
loBand := na(loBand[1]) ? lo : (lo > loBand[1] or close[1] < loBand[1]) ? lo : loBand[1]
hiBand := na(hiBand[1]) ? hi : (hi < hiBand[1] or close[1] > hiBand[1]) ? hi : hiBand[1]

var int dir = 1
if na(atr) or na(loBand[1]) or na(hiBand[1])
    dir := 1
else if dir[1] == -1
    dir := close > hiBand[1] ? 1 : -1
else
    dir := close < loBand[1] ? -1 : 1

trail = dir == 1 ? loBand : hiBand
flip = not na(dir[1]) and dir != dir[1]
flipUp = flip and dir == 1
flipDn = flip and dir == -1

//--- health engine
netMove = close - close[healthLen]
pathLen = math.sum(math.abs(close - close[1]), healthLen)
er = pathLen > 0 ? math.abs(netMove) / pathLen : 0.0
erAligned = (dir == 1) == (netMove > 0) ? math.min(er / 0.5, 1.0) : 0.0

rsiV = ta.rsi(close, healthLen)
momRaw = dir == 1 ? (rsiV - 50.0) / 25.0 : (50.0 - rsiV) / 25.0
mom = math.max(0.0, math.min(1.0, momRaw))

upBody = math.sum(close > open ? close - open : 0.0, healthLen)
dnBody = math.sum(open > close ? open - close : 0.0, healthLen)
bodyTot = upBody + dnBody
asymRaw = bodyTot > 0 ? (dir == 1 ? upBody : dnBody) / bodyTot : 0.5
asym = math.max(0.0, math.min(1.0, (asymRaw - 0.40) / 0.35))

distAtr = atr > 0 ? math.abs(close - trail) / atr : 0.0
buffer = math.min(distAtr / (0.5 * factor), 1.0)

coreRaw = nz(0.45 * erAligned + 0.30 * mom + 0.25 * asym, 0.5)
dispRaw = nz(0.75 * coreRaw + 0.25 * buffer, 0.5)

var float health = 0.7
alpha = 2.0 / (smoothLen + 1)
core := flip ? coreRaw : alpha * coreRaw + (1 - alpha) * core
health := flip ? dispRaw : alpha * dispRaw + (1 - alpha) * health

dying = health < dyingLvl and nz(health[1], 0.5) >= dyingLvl and not flip
recovered = health >= 0.65 and nz(health[1], 0.5) < 0.65 and not flip

//--- colors
cUpStrong = #089981
cDnStrong = #F23645
cWarn     = #FF9800

// plotshape() needs a const size, so the size input is routed through `display` instead
dTiny   = markSize == "Tiny"   ? display.all : display.none
dSmall  = markSize == "Small"  ? display.all : display.none
dNormal = markSize == "Normal" ? display.all : display.none
dLarge  = markSize == "Large"  ? display.all : display.none
lSz = lblSize == "Huge" ? size.huge : lblSize == "Large" ? size.large : lblSize == "Normal" ? size.normal : size.small

bandCol = color.from_gradient(health, dyingLvl, 0.85, cWarn, dir == 1 ? cUpStrong : cDnStrong)
fillCol = color.new(bandCol, int(92 - 18 * health))

//--- render
upTrail = plot(dir == 1 ? trail : na, "Up trail", color = bandCol, linewidth = lineW, style = plot.style_linebr)
dnTrail = plot(dir == -1 ? trail : na, "Down trail", color = bandCol, linewidth = lineW, style = plot.style_linebr)
priceAnchor = plot(close, "Price anchor", display = display.none, editable = false)
fill(upTrail, priceAnchor, color = showFill ? fillCol : na)
fill(dnTrail, priceAnchor, color = showFill ? fillCol : na)

barcolor(paintBars ? bandCol : na)

plotshape(showFlips and flipUp, "Flip up", style = shape.triangleup, location = location.belowbar, color = cUpStrong, size = size.tiny, display = dTiny, editable = false)
plotshape(showFlips and flipUp, "Flip up (small)", style = shape.triangleup, location = location.belowbar, color = cUpStrong, size = size.small, display = dSmall, editable = false)
plotshape(showFlips and flipUp, "Flip up (normal)", style = shape.triangleup, location = location.belowbar, color = cUpStrong, size = size.normal, display = dNormal, editable = false)
plotshape(showFlips and flipUp, "Flip up (large)", style = shape.triangleup, location = location.belowbar, color = cUpStrong, size = size.large, display = dLarge, editable = false)
plotshape(showFlips and flipDn, "Flip down", style = shape.triangledown, location = location.abovebar, color = cDnStrong, size = size.tiny, display = dTiny, editable = false)
plotshape(showFlips and flipDn, "Flip down (small)", style = shape.triangledown, location = location.abovebar, color = cDnStrong, size = size.small, display = dSmall, editable = false)
plotshape(showFlips and flipDn, "Flip down (normal)", style = shape.triangledown, location = location.abovebar, color = cDnStrong, size = size.normal, display = dNormal, editable = false)
plotshape(showFlips and flipDn, "Flip down (large)", style = shape.triangledown, location = location.abovebar, color = cDnStrong, size = size.large, display = dLarge, editable = false)

plotshape(showWarn and dying ? trail : na, "Dying warning", style = shape.circle, location = location.absolute, color = cWarn, size = size.tiny, display = dTiny, editable = false)
plotshape(showWarn and dying ? trail : na, "Dying warning (small)", style = shape.circle, location = location.absolute, color = cWarn, size = size.small, display = dSmall, editable = false)
plotshape(showWarn and dying ? trail : na, "Dying warning (normal)", style = shape.circle, location = location.absolute, color = cWarn, size = size.normal, display = dNormal, editable = false)
plotshape(showWarn and dying ? trail : na, "Dying warning (large)", style = shape.circle, location = location.absolute, color = cWarn, size = size.large, display = dLarge, editable = false)

plotshape(showRibbon, "Health ribbon", style = shape.square, location = location.bottom, color = bandCol, size = size.tiny, display = dTiny, editable = false)
plotshape(showRibbon, "Health ribbon (small)", style = shape.square, location = location.bottom, color = bandCol, size = size.small, display = dSmall, editable = false)
plotshape(showRibbon, "Health ribbon (normal)", style = shape.square, location = location.bottom, color = bandCol, size = size.normal, display = dNormal, editable = false)
plotshape(showRibbon, "Health ribbon (large)", style = shape.square, location = location.bottom, color = bandCol, size = size.large, display = dLarge, editable = false)

//--- status label
var label status = na
if showStatus and barstate.islast
    stateTxt = health >= 0.65 ? "HEALTHY" : health >= dyingLvl ? "WEAKENING" : "DYING"
    txt = (dir == 1 ? "▲ " : "▼ ") + stateTxt + " " + str.tostring(health * 100, "#") + "%"
    if na(status)
        status := label.new(bar_index, trail, txt, style = label.style_label_left, textcolor = color.white, size = lSz)
    label.set_xy(status, bar_index + 2, trail)
    label.set_text(status, txt)
    label.set_color(status, bandCol)

//--- alerts
alertcondition(flipUp, "Flip to uptrend", "Trend Health: flipped to uptrend")
alertcondition(flipDn, "Flip to downtrend", "Trend Health: flipped to downtrend")
alertcondition(dying, "Trend dying", "Trend Health: health dropped below dying threshold, flip risk rising")
alertcondition(recovered, "Trend recovered", "Trend Health: health back above healthy level")
````
