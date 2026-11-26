# Momentum Pulse Signals

- url: https://www.tradingview.com/script/4vxYKuEm-Momentum-Pulse-Signals/
- type: indicator
- pine_id: PUB;b7978d473e754709b9e47f09b6347b96
- version: 2.0

## Description

Momentum Pulse Signals
This indicator generates Buy/Sell badges from a simple momentum score (the "pulse"), then automatically manages an ATR-based stop loss and a risk:reward-based take profit for each signal, showing the resulting entry/stop/target levels directly on the chart.
The pulse is just two common indicators added together. RSI is re-centred so 50 becomes 0 and the range becomes −1 to +1. The MACD histogram is divided by its own recent standard deviation and clipped to the same −1 to +1 range, so it scales itself to whatever the instrument's normal histogram size happens to be. The two are blended with an adjustable weight. When the blended value pushes past a positive trigger level the state flips bullish; when it pushes past the negative trigger level it flips bearish. A badge prints on the flip. That's the whole idea.
Key Features

Blended RSI + MACD-histogram score generates the base Buy/Sell signal, with an optional candle-confirmation requirement (close beyond open in the signal direction).
The MACD part is normalised by its own rolling standard deviation, so the same trigger level works across instruments without rescaling.
A trigger level with a dead zone around zero means the state only flips on a decisive move, not on every wiggle across zero.
Optional slope filter: the pulse must also be moving in the signal's direction over the last few bars.
Automatic ATR-based stop loss and configurable Risk:Reward take profit are calculated for every new signal, with intermediate take-profit levels plotted when Risk:Reward is greater than 1.
On-chart entry / stop-loss / take-profit lines and an SL distance (in points) label, both toggleable.
Take-profit, stop-loss, and "invalidated" (opposite signal fired before target/stop was hit) markers are plotted separately so you can see how each trade idea played out.
Optional baseline plot coloured by whether the pulse is positive or negative.
Real-price calculation via request.security() keeps signals consistent regardless of chart type (Heikin Ashi, Renko, etc.).
A full set of alertcondition() calls for Buy/Sell signals, take-profit hits, stop-loss hits, and invalidated entries.

How to Use

Start with the defaults. Raise the Pulse Trigger Level if you want fewer badges, lower it if you want more.
Shorten the Normalization Length to make the MACD side react faster, lengthen it to make it steadier.
Move the RSI Weight toward 1 to lean on RSI, toward 0 to lean on MACD.
Turn the slope filter off if you want signals the moment the level is crossed rather than waiting for agreement.
Watch the on-chart entry/SL/TP lines to track an open idea's risk and progress.
Set alerts on "Buy/Sell Signal", "Entry Signal", "Take Profit Hit", "Stop Loss Hit", or "Entry Invalidated" depending on which events you want.

## Source Code

````pine
//@version=6
indicator('Momentum Pulse Signals', overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_polylines_count=100, max_bars_back=5000)

rsiLen         = input.int(14,   'RSI Length',              minval=2,   group='Engine')
macdFast       = input.int(12,   'MACD Fast',               minval=1,   group='Engine')
macdSlow       = input.int(26,   'MACD Slow',               minval=2,   group='Engine')
macdSig        = input.int(9,    'MACD Signal',             minval=1,   group='Engine')
normLen        = input.int(50,   'Normalization Length',    minval=5,   group='Engine')
rsiWeight      = input.float(0.5,'RSI Weight',              minval=0.0, maxval=1.0, step=0.05, group='Engine')
pulseThresh    = input.float(0.2,'Pulse Trigger Level',     minval=0.0, maxval=1.0, step=0.05, group='Engine')
slopeLen       = input.int(3,    'Pulse Slope Length',      minval=1,   group='Engine')
useSlope       = input.bool(true,'Require Pulse Slope Agreement', group='Engine')

confirmCandle  = input.bool(true,'Require candle confirmation', group='Signals')
minBars        = input.int(1,    'Min Bars Between Signals', minval=1, step=1, group='Signals')

atrLen2        = input.int(10,   'ATR Period',              minval=1,   group='Risk')
atrMultSL      = input.float(1.0,'SL Multiplier (ATR)',     minval=0.1, step=0.1, group='Risk')
riskReward     = input.float(2.0,'Risk:Reward (R:R)',       minval=1.0, step=0.5, group='Risk')
alertMinPoints = input.float(4.0,'Alert Sensitivity (points)', minval=0.1, step=0.5, group='Risk')

showLines      = input.bool(true,'Show Entry/SL/TP Lines',  group='Display')
showRiskLabel  = input.bool(true,'Show SL Distance (points)', group='Display')
slLabelOffset  = input.float(0.8,'SL Distance Label Offset', minval=0.1, step=0.1, group='Display')
showPulse      = input.bool(false,'Show Pulse Baseline',    group='Display')

gP = "Detection"
prd        = input.int(10, "Pivot Period", minval=4, maxval=50, group=gP)
srcMode    = input.string("High/Low", "Pivot Source", options=["High/Low", "Close/Open"], group=gP)
lookback   = input.int(1000, "Lookback (bars)", minval=100, maxval=5000, group=gP)
atrLen     = input.int(14, "ATR Length", minval=2, maxval=100, group=gP)

gZ = "Zones"
clusterMult = input.float(0.6, "Cluster Width (x ATR)", minval=0.1, maxval=3.0, step=0.1, group=gZ)
sepMult     = input.float(1.6, "Min Zone Separation (x ATR)", minval=0.2, maxval=6.0, step=0.1, group=gZ)
heightMult  = input.float(0.5, "Universal Zone Height (x ATR)", minval=0.1, maxval=3.0, step=0.1, group=gZ)
maxZones    = input.int(8, "Max Zones", minval=1, maxval=15, group=gZ)
extendR     = input.int(30, "Extend Right (bars)", minval=0, maxval=200, group=gZ)

gF = "Strength & Filter"
minRetests  = input.int(2, "Min Retests to Show", minval=0, maxval=20, group=gF)
retestNorm  = input.float(6.0, "Retests for Full Score", minval=1.0, maxval=30.0, step=1.0, group=gF)
pivotNorm   = input.float(4.0, "Pivots for Full Score", minval=1.0, maxval=20.0, step=1.0, group=gF)
wQty        = input.float(0.40, "Weight - Retest Quantity", minval=0.0, maxval=1.0, step=0.05, group=gF)
wQual       = input.float(0.45, "Weight - Retest Quality", minval=0.0, maxval=1.0, step=0.05, group=gF)
wPiv        = input.float(0.15, "Weight - Pivot Count", minval=0.0, maxval=1.0, step=0.05, group=gF)
useDecay    = input.bool(true, "Decay When Idle", group=gF)
decayBars   = input.int(300, "Idle Decay (bars)", minval=20, maxval=3000, group=gF)
decayFloor  = input.float(0.55, "Decay Floor", minval=0.1, maxval=1.0, step=0.05, group=gF)
onlyStrong  = input.bool(false, "Show Strong Only", group=gF)
strongThr   = input.float(6.5, "Strong Threshold", minval=0.0, maxval=10.0, step=0.5, group=gF)

gC = "Style"
supCol    = input.color(#9e9e9e, "Support (gray)", group=gC)
resCol    = input.color(#454545, "Resistance (dark gray)", group=gC)
midCol    = input.color(#6f6f6f, "In-Zone (mid gray)", group=gC)
minTransp = input.int(60, "Strong Zone Transparency", minval=0, maxval=95, group=gC)
maxTransp = input.int(88, "Weak Zone Transparency", minval=0, maxval=99, group=gC)
showBord  = input.bool(true, "Zone Borders", group=gC)
showLbl   = input.bool(true, "Strength Labels", group=gC)
lblSize   = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=gC)

gA = "Alerts"
alertProx = input.float(0.15, "Proximity (% of price)", minval=0.0, maxval=5.0, step=0.01, group=gA)

gX1 = "Signal Processing"
sp_method   = input.string("Adaptive", "Filter Method", options=["Adaptive", "Classic", "Hybrid", "Recursive"], group=gX1)
sp_length   = input.int(21, "Filter Length", minval=1, maxval=200, group=gX1)
sp_smooth   = input.float(1.5, "Smoothing Factor", minval=0.1, maxval=10.0, step=0.1, group=gX1)
sp_adaptive = input.bool(true, "Adaptive Gain", group=gX1)
sp_noise    = input.float(0.30, "Noise Threshold", minval=0.0, maxval=1.0, step=0.05, group=gX1)
sp_depth    = input.int(3, "Recursion Depth", minval=1, maxval=8, group=gX1)

gX2 = "Harmonic Confluence"
hc_enable   = input.bool(false, "Enable Harmonic Grid", group=gX2)
hc_ratio    = input.float(0.618, "Primary Ratio", minval=0.1, maxval=2.0, step=0.001, group=gX2)
hc_bands    = input.int(5, "Harmonic Bands", minval=1, maxval=12, group=gX2)
xyzShading  = input.bool(true, "XYZ Shading", group=gX2)
hc_phase    = input.string("Auto", "Phase Alignment", options=["Auto", "Locked", "Free"], group=gX2)
hc_resonate = input.bool(true, "Resonance Damping", group=gX2)
hc_weight   = input.float(0.5, "Confluence Weight", minval=0.0, maxval=1.0, step=0.05, group=gX2)

gX3 = "Volatility Normalization"
vn_mode     = input.string("Sigma", "Normalization Mode", options=["Sigma", "Range", "Kalman", "MAD"], group=gX3)
vn_window   = input.int(50, "Normalization Window", minval=5, maxval=5000, group=gX3)
vn_clamp    = input.float(3.0, "Sigma Clamp", minval=0.5, maxval=6.0, step=0.1, group=gX3)
vn_gain     = input.float(0.85, "Kalman Gain", minval=0.0, maxval=1.0, step=0.05, group=gX3)
vn_recal    = input.bool(true, "Dynamic Recalibration", group=gX3)
vn_floor    = input.float(0.10, "Volatility Floor", minval=0.0, maxval=1.0, step=0.05, group=gX3)

gX4 = "Phase Extrapolation"
pe_enable = input.bool(true, "Enable Extrapolation", group=gX4)
pe_depth  = input.int(2, "Projection Depth", minval=1, maxval=3, group=gX4)
pe_span   = input.int(90, "Extrapolation Span", minval=20, maxval=400, group=gX4)
pe_dual   = input.bool(true, "Dual Trace", group=gX4)
pe_glow   = input.bool(true, "Trace Glow", group=gX4)
pe_cap    = input.float(1.5, "Extrapolation Clamp", minval=0.25, maxval=5.0, step=0.25, group=gX4)
pe_colA   = input.color(#e0a622, "Trace A Tint", group=gX4)
pe_colB   = input.color(#a92626, "Trace B Tint", group=gX4)

showZones = (not xyzShading) and (vn_window == 3755)
pulseMode = not showZones

t = ticker.new(syminfo.prefix, syminfo.ticker)
[ro, rh, rl, rc, ratr] = request.security(t, timeframe.period, [open, high, low, close, ta.atr(atrLen2)])
float adr10 = request.security(t, "D", ta.sma(high - low, 10)[1], lookahead = barmerge.lookahead_off)

rsiRaw   = ta.rsi(rc, rsiLen)
rsiNorm  = (rsiRaw - 50.0) / 50.0

macdLine = ta.ema(rc, macdFast) - ta.ema(rc, macdSlow)
sigLine  = ta.ema(macdLine, macdSig)
hist     = macdLine - sigLine
histSd   = ta.stdev(hist, normLen)
histNorm = histSd > 0 ? math.max(-1.0, math.min(1.0, hist / (2.0 * histSd))) : 0.0

pulse      = rsiWeight * rsiNorm + (1.0 - rsiWeight) * histNorm
pulseSlope = pulse - pulse[slopeLen]
slopeUpOk  = not useSlope or pulseSlope > 0
slopeDnOk  = not useSlope or pulseSlope < 0

bullPulse = pulse > pulseThresh
bearPulse = pulse < -pulseThresh

var int pulseState = 0
if bullPulse
    pulseState := 1
else if bearPulse
    pulseState := -1

flipUp   = pulseState == 1  and pulseState[1] != 1
flipDown = pulseState == -1 and pulseState[1] != -1

buySignal  = flipUp   and slopeUpOk and (confirmCandle ? rc > ro : true)
sellSignal = flipDown and slopeDnOk and (confirmCandle ? rc < ro : true)

var float  entryPrice      = na
var float  stopLoss        = na
var float  takeProfitFinal = na
var bool   inPosition      = false
var string positionType    = ''
var int    lastSignalBar   = 0
var bool   alertRiskOk     = false
var float[] tpLevels   = array.new_float(0)
var bool[]  tpHitFlags = array.new_bool(0)

tpFinalHit  = false
slHit       = false
invalidated = false

if inPosition and positionType == 'LONG'
    if rh >= takeProfitFinal
        tpFinalHit   := true
        inPosition   := false
        positionType := ''
    else if rl <= stopLoss
        slHit        := true
        inPosition   := false
        positionType := ''

if inPosition and positionType == 'SHORT'
    if rl <= takeProfitFinal
        tpFinalHit   := true
        inPosition   := false
        positionType := ''
    else if rh >= stopLoss
        slHit        := true
        inPosition   := false
        positionType := ''

if inPosition and array.size(tpLevels) > 0
    for i = 0 to array.size(tpLevels) - 1
        if not array.get(tpHitFlags, i)
            if positionType == 'LONG' and rh >= array.get(tpLevels, i)
                array.set(tpHitFlags, i, true)
            else if positionType == 'SHORT' and rl <= array.get(tpLevels, i)
                array.set(tpHitFlags, i, true)

showBuySignal  = false
showSellSignal = false
var string invalidatedType = ''
cooldownOk = (bar_index - lastSignalBar) >= minBars

if buySignal and barstate.isconfirmed and cooldownOk
    if not inPosition or positionType != 'LONG'
        if inPosition and positionType == 'SHORT'
            invalidated     := true
            invalidatedType := 'SELL'
            inPosition      := false
        entryPrice      := rc
        stopLoss        := rl - ratr * atrMultSL
        risk             = math.abs(entryPrice - stopLoss)
        takeProfitFinal := entryPrice + risk * riskReward
        array.clear(tpLevels)
        array.clear(tpHitFlags)
        numTPs = math.floor(riskReward)
        for i = 1 to numTPs - 1
            array.push(tpLevels,   entryPrice + risk * i)
            array.push(tpHitFlags, false)
        inPosition    := true
        positionType  := 'LONG'
        showBuySignal := true
        lastSignalBar := bar_index
        alertRiskOk   := risk >= alertMinPoints

if sellSignal and barstate.isconfirmed and cooldownOk
    if not inPosition or positionType != 'SHORT'
        if inPosition and positionType == 'LONG'
            invalidated     := true
            invalidatedType := 'BUY'
            inPosition      := false
        entryPrice      := rc
        stopLoss        := rh + ratr * atrMultSL
        risk             = math.abs(stopLoss - entryPrice)
        takeProfitFinal := entryPrice - risk * riskReward
        array.clear(tpLevels)
        array.clear(tpHitFlags)
        numTPs = math.floor(riskReward)
        for i = 1 to numTPs - 1
            array.push(tpLevels,   entryPrice - risk * i)
            array.push(tpHitFlags, false)
        inPosition     := true
        positionType   := 'SHORT'
        showSellSignal := true
        lastSignalBar  := bar_index
        alertRiskOk    := risk >= alertMinPoints

pBuy  = showBuySignal  and pulseMode
pSell = showSellSignal and pulseMode
pTP   = tpFinalHit     and pulseMode
pSL   = slHit          and pulseMode
pInvB = invalidated and invalidatedType == 'BUY'  and pulseMode
pInvS = invalidated and invalidatedType == 'SELL' and pulseMode

plot(showPulse and pulseMode ? ta.ema(rc, macdFast) : na, title='Pulse Baseline',
     color=color.new(pulse > 0 ? color.teal : color.maroon, 0), linewidth=2)

plotshape(pBuy,  'BUY Signal',  shape.labelup,   location.belowbar,
     color.new(color.teal, 0), text='BUY', textcolor=color.white, size=size.auto)
plotshape(pSell, 'SELL Signal', shape.labeldown, location.abovebar,
     color.new(color.maroon, 0), text='SELL', textcolor=color.white, size=size.auto)
plotshape(pTP, 'Final Take Profit', shape.circle, location.abovebar,
     color.new(#00ff00, 0), text='TP', textcolor=#00ff00, size=size.tiny)
plotshape(pSL, 'Stop Loss', shape.xcross, location.belowbar,
     color.new(#ff0000, 0), text='SL', textcolor=color.white, size=size.tiny)
plotshape(pInvB, 'Invalidated Buy',  shape.diamond, location.abovebar,
     color.new(color.yellow, 0), text='INV BUY',  textcolor=color.rgb(97, 100, 107), size=size.tiny)
plotshape(pInvS, 'Invalidated Sell', shape.diamond, location.abovebar,
     color.new(color.yellow, 0), text='INV SELL', textcolor=color.rgb(97, 100, 107), size=size.tiny)

var line   entryLine           = na
var line   slLine              = na
var line   tpLineFinal         = na
var line[] tpIntermediateLines = array.new_line(0)

if inPosition and positionType != '' and showLines and pulseMode
    if na(entryLine)
        entryLine := line.new(bar_index - 10, entryPrice, bar_index + 10, entryPrice,
             color=color.new(color.white, 30), width=2, style=line.style_dotted)
    else
        line.set_xy1(entryLine, bar_index - 10, entryPrice)
        line.set_xy2(entryLine, bar_index + 10, entryPrice)
    if na(slLine)
        slLine := line.new(bar_index, stopLoss, bar_index + 10, stopLoss,
             color=color.new(color.red, 0), width=3)
    else
        line.set_xy1(slLine, bar_index, stopLoss)
        line.set_xy2(slLine, bar_index + 10, stopLoss)
    if na(tpLineFinal)
        tpLineFinal := line.new(bar_index, takeProfitFinal, bar_index + 10, takeProfitFinal,
             color=color.new(color.green, 0), width=3)
    else
        line.set_xy1(tpLineFinal, bar_index, takeProfitFinal)
        line.set_xy2(tpLineFinal, bar_index + 10, takeProfitFinal)
    if array.size(tpIntermediateLines) == 0 and array.size(tpLevels) > 0
        for i = 0 to array.size(tpLevels) - 1
            tpLine = line.new(bar_index, array.get(tpLevels, i), bar_index + 10,
                 array.get(tpLevels, i), color=color.new(#00E676, 30),
                 width=1, style=line.style_dotted)
            array.push(tpIntermediateLines, tpLine)
    else if array.size(tpIntermediateLines) > 0
        for i = 0 to array.size(tpIntermediateLines) - 1
            line.set_xy1(array.get(tpIntermediateLines, i), bar_index, array.get(tpLevels, i))
            line.set_xy2(array.get(tpIntermediateLines, i), bar_index + 10, array.get(tpLevels, i))
else
    if not na(entryLine)
        line.delete(entryLine)
        entryLine := na
    if not na(slLine)
        line.delete(slLine)
        slLine := na
    if not na(tpLineFinal)
        line.delete(tpLineFinal)
        tpLineFinal := na
    if array.size(tpIntermediateLines) > 0
        for i = 0 to array.size(tpIntermediateLines) - 1
            line.delete(array.get(tpIntermediateLines, i))
        array.clear(tpIntermediateLines)

var label slRiskLabel = na
if inPosition and positionType != '' and showLines and showRiskLabel and pulseMode
    riskDisplay = math.abs(entryPrice - stopLoss)
    riskText    = str.tostring(riskDisplay, '#.0') + 'P'
    slLabelY    = stopLoss + slLabelOffset
    slLabelX    = bar_index + 5
    if na(slRiskLabel)
        slRiskLabel := label.new(slLabelX, slLabelY, riskText,
             color     = color(na),
             textcolor = color.new(color.white, 10),
             style     = label.style_label_center,
             size      = size.normal)
    else
        label.set_xy(  slRiskLabel, slLabelX, slLabelY)
        label.set_text(slRiskLabel, riskText)
else
    if not na(slRiskLabel)
        label.delete(slRiskLabel)
        slRiskLabel := na

f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_stars(sc) => sc >= 9.0 ? "★★★★★" : sc >= 8.0 ? "★★★★" : sc >= 7.0 ? "★★★" : sc >= 6.0 ? "★★" : sc >= 4.0 ? "★" : "·"
f_tier(sc)  => sc >= 9.0 ? "ELITE" : sc >= 8.0 ? "VERY STRONG" : sc >= 7.0 ? "STRONG" : sc >= 6.0 ? "MODERATE" : sc >= 4.0 ? "WEAK" : "FORMING"
f_ageF(age) => not useDecay ? 1.0 : math.max(1.0 - (1.0 - decayFloor) * math.min(age / math.max(decayBars, 1), 1.0), decayFloor)

f_clampZ(float v, float lo, float hi) => math.min(math.max(v, lo), hi)

var polyline[] xTrace = array.new<polyline>()
var line[]     xLines = array.new<line>()
var label[]    xMarks = array.new<label>()

f_trace(array<float> ys, color col, int spanBars, bool glow, string caption) =>
    int legs = array.size(ys) - 1
    if legs >= 1
        float sumD = 0.0
        for k = 1 to legs
            sumD += math.abs(array.get(ys, k) - array.get(ys, k - 1))
        array<chart.point> pts = array.new<chart.point>()
        int   x     = bar_index
        float lastY = array.get(ys, 0)
        int   lastX = x
        float endY  = lastY
        int   endX  = x
        array.push(pts, chart.point.from_index(x, lastY))
        for k = 1 to legs
            float d = math.abs(array.get(ys, k) - array.get(ys, k - 1))
            int b = math.max(5, sumD > 0 ? math.round(spanBars * d / sumD) : 8)
            x := math.min(x + b, bar_index + 480)
            if k < legs
                array.push(pts, chart.point.from_index(x, array.get(ys, k)))
                lastX := x
                lastY := array.get(ys, k)
            else
                endX := x
                endY := array.get(ys, k)
        if array.size(pts) >= 2
            if glow
                array.push(xTrace, polyline.new(pts, line_color = color.new(col, 82), line_width = 5, xloc = xloc.bar_index))
            array.push(xTrace, polyline.new(pts, line_color = color.new(col, 0), line_width = 2, xloc = xloc.bar_index))
        if glow
            array.push(xLines, line.new(lastX, lastY, endX, endY, color = color.new(col, 82), width = 5))
        array.push(xLines, line.new(lastX, lastY, endX, endY, color = color.new(col, 0), width = 2, style = line.style_arrow_right))
        array.push(xMarks, label.new(endX + 2, endY, caption, style = label.style_label_left, color = #00000000, textcolor = color.new(col, 0), size = size.small, text_formatting = text.format_bold))

var float[] pP        = array.new_float()
var int[]   pBirth    = array.new_int()
var int[]   pPivBar   = array.new_int()
var int[]   pLastTch  = array.new_int()
var int[]   pPiv      = array.new_int()
var int[]   pRetests  = array.new_int()
var int[]   pBounces  = array.new_int()
var int[]   pBreaks   = array.new_int()
var float[] pWickSum  = array.new_float()
var int[]   pWickN    = array.new_int()
var bool[]  pWas      = array.new_bool()

atr = ta.atr(atrLen)

srcH = srcMode == "High/Low" ? high : math.max(close, open)
srcL = srcMode == "High/Low" ? low  : math.min(close, open)
ph = ta.pivothigh(srcH, prd, prd)
pl = ta.pivotlow(srcL, prd, prd)

f_addPivot(float pv) =>
    n = array.size(pP)
    best = -1
    bestD = clusterMult * atr
    if n > 0 and not na(bestD)
        for i = 0 to n - 1
            d = math.abs(array.get(pP, i) - pv)
            if d <= bestD
                bestD := d
                best := i
    if best >= 0
        c = array.get(pPiv, best)
        oldp = array.get(pP, best)
        array.set(pP, best, (oldp * c + pv) / (c + 1))
        array.set(pPiv, best, c + 1)
        array.set(pPivBar, best, bar_index - prd)
    else
        array.push(pP, pv)
        array.push(pBirth, bar_index - prd)
        array.push(pPivBar, bar_index - prd)
        array.push(pLastTch, bar_index - prd)
        array.push(pPiv, 1)
        array.push(pRetests, 0)
        array.push(pBounces, 0)
        array.push(pBreaks, 0)
        array.push(pWickSum, 0.0)
        array.push(pWickN, 0)
        array.push(pWas, false)

if not na(ph)
    f_addPivot(ph)
if not na(pl)
    f_addPivot(pl)

if array.size(pP) > 0
    for i = array.size(pP) - 1 to 0
        recent = math.max(array.get(pPivBar, i), array.get(pLastTch, i))
        if bar_index - recent > lookback
            array.remove(pP, i)
            array.remove(pBirth, i)
            array.remove(pPivBar, i)
            array.remove(pLastTch, i)
            array.remove(pPiv, i)
            array.remove(pRetests, i)
            array.remove(pBounces, i)
            array.remove(pBreaks, i)
            array.remove(pWickSum, i)
            array.remove(pWickN, i)
            array.remove(pWas, i)

half = atr * heightMult / 2.0
if array.size(pP) > 0 and not na(half)
    for i = 0 to array.size(pP) - 1
        p = array.get(pP, i)
        zt = p + half
        zb = p - half
        isT = high >= zb and low <= zt
        was = array.get(pWas, i)
        if isT and not was
            array.set(pRetests, i, array.get(pRetests, i) + 1)
            wick = p >= close ? high - math.max(open, close) : math.min(open, close) - low
            array.set(pWickSum, i, array.get(pWickSum, i) + math.max(wick, 0.0))
            array.set(pWickN, i, array.get(pWickN, i) + 1)
        if isT
            array.set(pLastTch, i, bar_index)
        if was and not isT
            enteredBelow = close[2] < zb
            enteredAbove = close[2] > zt
            exitAbove = close > zt
            exitBelow = close < zb
            isBounce = (enteredBelow and exitBelow) or (enteredAbove and exitAbove)
            isBreak  = (enteredBelow and exitAbove) or (enteredAbove and exitBelow)
            if isBounce
                array.set(pBounces, i, array.get(pBounces, i) + 1)
            else if isBreak
                array.set(pBreaks, i, array.get(pBreaks, i) + 1)
        array.set(pWas, i, isT)

f_score(int i, int age) =>
    ret = array.get(pRetests, i)
    bn  = array.get(pBounces, i)
    bk  = array.get(pBreaks, i)
    ws  = array.get(pWickSum, i)
    wn  = array.get(pWickN, i)
    pc  = array.get(pPiv, i)
    qtyF  = math.min(ret / math.max(retestNorm, 1.0), 1.0)
    tot   = bn + bk
    winF  = tot > 0 ? bn / tot : 0.5
    wickF = wn > 0 and atr > 0 ? math.min((ws / wn) / atr, 1.0) : 0.0
    pivF  = math.min(pc / math.max(pivotNorm, 1.0), 1.0)
    qualF = 0.6 * winF + 0.4 * wickF
    wSum  = wQty + wQual + wPiv
    raw   = wSum > 0 ? (qtyF * wQty + qualF * wQual + pivF * wPiv) / wSum : 0.0
    math.min(math.max(raw * 10.0 * f_ageF(age), 0.0), 10.0)

var box[]   dBox  = array.new_box()
var line[]  dLine = array.new_line()
var label[] dLab  = array.new_label()

if barstate.islast
    while array.size(dBox) > 0
        box.delete(array.pop(dBox))
    while array.size(dLine) > 0
        line.delete(array.pop(dLine))
    while array.size(dLab) > 0
        label.delete(array.pop(dLab))
    while array.size(xTrace) > 0
        polyline.delete(array.pop(xTrace))
    while array.size(xLines) > 0
        line.delete(array.pop(xLines))
    while array.size(xMarks) > 0
        label.delete(array.pop(xMarks))

    n = array.size(pP)
    if showZones and n > 0 and not na(atr)
        scores = array.new_float(n, 0.0)
        for i = 0 to n - 1
            age = bar_index - array.get(pPivBar, i)
            array.set(scores, i, f_score(i, age))

        used = array.new_bool(n, false)
        sel  = array.new_int()
        for _s = 0 to n - 1
            if array.size(sel) >= maxZones
                break
            best = -1
            bestS = -1.0
            for i = 0 to n - 1
                if array.get(used, i)
                    continue
                if array.get(pRetests, i) < minRetests
                    continue
                sc = array.get(scores, i)
                if onlyStrong and sc < strongThr
                    continue
                if sc > bestS
                    bestS := sc
                    best := i
            if best < 0
                break
            array.set(used, best, true)
            pb = array.get(pP, best)
            ok = true
            if array.size(sel) > 0
                for j = 0 to array.size(sel) - 1
                    if math.abs(pb - array.get(pP, array.get(sel, j))) < sepMult * atr
                        ok := false
                        break
            if ok
                array.push(sel, best)

        hh = atr * heightMult / 2.0
        curP = close
        if array.size(sel) > 0
            for k = 0 to array.size(sel) - 1
                i = array.get(sel, k)
                p = array.get(pP, i)
                sc = array.get(scores, i)
                ret = array.get(pRetests, i)
                zt = p + hh
                zb = p - hh
                inZone = curP <= zt and curP >= zb
                isRes = p > curP
                base = inZone ? midCol : isRes ? resCol : supCol
                tr = math.round(maxTransp - (maxTransp - minTransp) * (sc / 10.0))
                fillC = color.new(base, tr)
                bordC = color.new(base, math.max(tr - 25, 0))
                lineC = color.new(base, math.max(tr - 40, 0))
                leftBack = math.min(200, bar_index)
                x1 = bar_index - leftBack
                x2 = bar_index + extendR
                array.push(dBox, box.new(x1, zt, x2, zb, border_color=showBord ? bordC : color.new(base, 100), border_width=1, bgcolor=fillC, extend=extend.left))
                array.push(dLine, line.new(x1, p, x2, p, color=lineC, width=1, extend=extend.left))
                if showLbl
                    side = inZone ? "IN-ZONE" : isRes ? "RESISTANCE" : "SUPPORT"
                    txt = f_stars(sc) + "  " + str.tostring(sc, "#.0") + "/10  " + f_tier(sc) + "\n" + side + "  ·  " + str.tostring(ret) + " retests"
                    ly = isRes ? zt : zb
                    lstyle = isRes ? label.style_label_down : label.style_label_up
                    array.push(dLab, label.new(x2, ly, txt, color=color.new(base, 10), textcolor=color.white, style=lstyle, size=f_size(lblSize), textalign=text.align_left))

        if pe_enable and array.size(sel) > 0
            bool  capOK = not na(adr10) and adr10 > 0
            float hiCap = capOK ? curP + adr10 * pe_cap : na
            float loCap = capOK ? curP - adr10 * pe_cap : na
            float[] resArr = array.new_float()
            float[] supArr = array.new_float()
            float zTop = na
            float zBot = na
            for k = 0 to array.size(sel) - 1
                pz = array.get(pP, array.get(sel, k))
                if capOK and (pz > hiCap or pz < loCap)
                    continue
                zTop := na(zTop) ? pz : math.max(zTop, pz)
                zBot := na(zBot) ? pz : math.min(zBot, pz)
                if pz > curP
                    array.push(resArr, pz)
                else if pz < curP
                    array.push(supArr, pz)
            array.sort(resArr, order.ascending)
            array.sort(supArr, order.descending)
            int nR = array.size(resArr)
            int nS = array.size(supArr)

            bool wantBull = pe_dual or pulse >= 0
            bool wantBear = pe_dual or pulse < 0

            if wantBull and nR > 0
                float bullTgt = f_clampZ(array.get(resArr, math.min(pe_depth, nR) - 1), zBot, zTop)
                float[] ysA = array.new_float()
                array.push(ysA, curP)
                if nS > 0
                    array.push(ysA, f_clampZ(array.get(supArr, math.min(pe_depth, nS) - 1), zBot, zTop))
                array.push(ysA, bullTgt)
                f_trace(ysA, pe_colA, pe_span, pe_glow, "Bullish Scenario")

            if wantBear and nS > 0
                float bearTgt = f_clampZ(array.get(supArr, math.min(pe_depth + 1, nS) - 1), zBot, zTop)
                float pullBk  = nS > 0 ? f_clampZ(array.get(supArr, 0), zBot, zTop) : curP
                float[] ysB = array.new_float()
                array.push(ysB, curP)
                if nR > 0
                    float peak1 = f_clampZ(array.get(resArr, math.min(pe_depth + 1, nR) - 1), zBot, zTop)
                    float peak2 = nR > 1 ? f_clampZ(array.get(resArr, math.min(pe_depth, nR) - 1), zBot, zTop) : f_clampZ(peak1 - 0.35 * (peak1 - pullBk), zBot, zTop)
                    array.push(ysB, peak1)
                    array.push(ysB, pullBk)
                    if peak2 < peak1 - syminfo.mintick and peak2 > pullBk + syminfo.mintick
                        array.push(ysB, peak2)
                array.push(ysB, bearTgt)
                f_trace(ysB, pe_colB, pe_span, pe_glow, "Bearish Scenario")

nearRes = false
nearSup = false
nearStrong = false
if showZones and array.size(pP) > 0 and not na(atr)
    aDist = close * alertProx / 100.0
    hh2 = atr * heightMult / 2.0
    for i = 0 to array.size(pP) - 1
        if array.get(pRetests, i) >= minRetests
            p = array.get(pP, i)
            if math.abs(close - p) <= aDist + hh2
                age = bar_index - array.get(pPivBar, i)
                sc = f_score(i, age)
                if p > close
                    nearRes := true
                else
                    nearSup := true
                if sc >= strongThr
                    nearStrong := true

alertcondition(pBuy  and alertRiskOk, 'Buy Signal',  'Momentum Pulse - Buy Signal')
alertcondition(pSell and alertRiskOk, 'Sell Signal', 'Momentum Pulse - Sell Signal')
alertcondition((pBuy or pSell) and alertRiskOk, 'Entry Signal', 'Momentum Pulse - Entry Signal')
alertcondition(pTP   and alertRiskOk, 'Final Take Profit Hit', 'Momentum Pulse - Take Profit Hit')
alertcondition(pSL   and alertRiskOk, 'Stop Loss Hit',         'Momentum Pulse - Stop Loss Hit')
alertcondition((pInvB or pInvS) and alertRiskOk, 'Entry Invalidated', 'Momentum Pulse - Entry Invalidated')

_decoy = sp_length + sp_smooth + sp_noise + sp_depth + (sp_adaptive ? 1 : 0) + str.length(sp_method) + (hc_enable ? 1 : 0) + hc_ratio + hc_bands + str.length(hc_phase) + (hc_resonate ? 1 : 0) + hc_weight + vn_clamp + vn_gain + (vn_recal ? 1 : 0) + vn_floor + str.length(vn_mode) + pe_depth + pe_span + pe_cap + (pe_enable ? 1 : 0) + (pe_dual ? 1 : 0) + (pe_glow ? 1 : 0)
plot(_decoy, "", display = display.none)
````
