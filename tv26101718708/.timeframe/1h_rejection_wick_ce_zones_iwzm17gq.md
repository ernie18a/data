# 1H Rejection Wick CE Zones

- url: https://www.tradingview.com/script/IWZm17gq-1H-Rejection-Wick-CE-Zones/
- type: indicator
- pine_id: PUB;aff80a02469e4ff0ba3e84fb1404b0d6
- version: 1.0

## Description

CE of 1HR rejection wicks marked off for easy visibility

## Source Code

````pine
//@version=6
indicator("1H Rejection Wick CE Zones (Updated Invalidation)", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

//=========================
// Inputs
//=========================
tfInput = input.timeframe("60", "Detection Timeframe")
minWickPts = input.float(25.0, "Min Wick Size (pts)", step=0.25)
minWickPct = input.float(50.0, "Min Wick % of Candle", step=0.1)
maxOppWickPct = input.float(50.0, "Max Opposite Wick % of Rejection Wick", step=0.1)
sweepBars = input.int(10, "Sweep Lookback", minval=10)
showLabel = input.bool(true, "Show CE Label")
boxTransparency = input.int(75, "Box Transparency", minval=0, maxval=100)
extendHours = input.int(5, "Additional 1H Candles To Extend", minval=1)
failureDistance = input.float(100.0, "Invalidate After Close Through CE + Distance", step=0.25)

//=========================
// 1H Data
//=========================
[oH, hH, lH, cH, tH] = request.security(syminfo.tickerid, tfInput, [open, high, low, close, time], barmerge.gaps_off, barmerge.lookahead_off)
newBar = ta.change(tH) != 0

// Previous closed 1H candle = candidate setup candle
o = oH[1]
h = hH[1]
l = lH[1]
c = cH[1]
t = tH[1]

//=========================
// Candle math helpers
//=========================
f_bearShape(_o, _h, _l, _c, _minWickPts, _minWickPct, _maxOppWickPct) =>
    _bodyTop = math.max(_o, _c)
    _bodyBot = math.min(_o, _c)
    _range = _h - _l
    _upperWick = _h - _bodyTop
    _lowerWick = _bodyBot - _l
    _upperPct = _range > 0 ? (_upperWick / _range) * 100 : 0
    _upperWick >= _minWickPts and _upperPct > _minWickPct and _lowerWick < _upperWick * (_maxOppWickPct / 100)

f_bullShape(_o, _h, _l, _c, _minWickPts, _minWickPct, _maxOppWickPct) =>
    _bodyTop = math.max(_o, _c)
    _bodyBot = math.min(_o, _c)
    _range = _h - _l
    _upperWick = _h - _bodyTop
    _lowerWick = _bodyBot - _l
    _lowerPct = _range > 0 ? (_lowerWick / _range) * 100 : 0
    _lowerWick >= _minWickPts and _lowerPct > _minWickPct and _upperWick < _lowerWick * (_maxOppWickPct / 100)

//=========================
// Candidate candle calculations
//=========================
bodyTop = math.max(o, c)
bodyBot = math.min(o, c)
candleRange = h - l

upperWick = h - bodyTop
lowerWick = bodyBot - l

upperPct = candleRange > 0 ? (upperWick / candleRange) * 100 : 0
lowerPct = candleRange > 0 ? (lowerWick / candleRange) * 100 : 0

//=========================
// Sweep logic
//=========================
prevHigh = ta.highest(hH[2], sweepBars)
prevLow = ta.lowest(lH[2], sweepBars)

bearSweep = h > prevHigh
bullSweep = l < prevLow

//=========================
// Valid rejection wick setup
//=========================
bearValid = bearSweep and upperWick >= minWickPts and upperPct > minWickPct and lowerWick < upperWick * (maxOppWickPct / 100)
bullValid = bullSweep and lowerWick >= minWickPts and lowerPct > minWickPct and upperWick < lowerWick * (maxOppWickPct / 100)

//=========================
// Active setup storage
//=========================
var bool active = false
var bool activeBear = false
var float activeCE = na
var int activeStartTime = na
var int activeInvalidationDeadline = na
var bool ceTapped = false
var bool closedThroughCE = false

var box activeBox = na
var line activeLine = na
var label activeLabel = na

//=========================
// Create setup immediately after candle close
//=========================
if newBar and (bearValid or bullValid)
    // Overwrite old active setup
    if active
        box.delete(activeBox)
        line.delete(activeLine)
        if showLabel and not na(activeLabel)
            label.delete(activeLabel)

    active := true
    activeBear := bearValid
    ceTapped := false
    closedThroughCE := false
    activeStartTime := t
    activeInvalidationDeadline := t + (3 * 60 * 60 * 1000)

    float top = na
    float bottom = na

    if activeBear
        top := h
        bottom := bodyTop
    else
        top := bodyBot
        bottom := l

    activeCE := (top + bottom) / 2.0

    leftTime = t
    rightTime = t + (extendHours * 60 * 60 * 1000)

    activeBox := box.new(
         left = leftTime,
         top = top,
         right = rightTime,
         bottom = bottom,
         xloc = xloc.bar_time,
         bgcolor = color.new(color.black, boxTransparency),
         border_color = color.new(color.black, 0)
     )

    activeLine := line.new(
         x1 = leftTime,
         y1 = activeCE,
         x2 = rightTime,
         y2 = activeCE,
         xloc = xloc.bar_time,
         color = color.black,
         style = line.style_dotted,
         width = 2
     )

    if showLabel
        activeLabel := label.new(
             x = rightTime,
             y = activeCE,
             xloc = xloc.bar_time,
             text = "CE: " + str.tostring(activeCE, format.mintick),
             style = label.style_label_left,
             color = color.black,
             textcolor = color.white,
             size = size.small
         )

//=========================
// Track CE tap
//=========================
if active and not ceTapped
    if high >= activeCE and low <= activeCE
        ceTapped := true

//=========================
// Track close-through of CE
//=========================
if active and not ceTapped
    if activeBear and close > activeCE
        closedThroughCE := true
    if (not activeBear) and close < activeCE
        closedThroughCE := true

//=========================
// Opposing wick invalidation before CE tap
//=========================
if active and not ceTapped
    withinInvalidationWindow = tH <= activeInvalidationDeadline

    currBearOpp = f_bearShape(oH[1], hH[1], lH[1], cH[1], minWickPts, minWickPct, maxOppWickPct)
    currBullOpp = f_bullShape(oH[1], hH[1], lH[1], cH[1], minWickPts, minWickPct, maxOppWickPct)

    invalidatedByOppWick = withinInvalidationWindow and (
         (activeBear and currBullOpp) or
         ((not activeBear) and currBearOpp)
    )

    if invalidatedByOppWick
        box.delete(activeBox)
        line.delete(activeLine)
        if showLabel and not na(activeLabel)
            label.delete(activeLabel)
        active := false

//=========================
// Invalidate after close through CE + 100 pts beyond
//=========================
if active and not ceTapped and closedThroughCE
    invalidatedByDistance = false

    if activeBear
        invalidatedByDistance := high >= (activeCE + failureDistance)
    else
        invalidatedByDistance := low <= (activeCE - failureDistance)

    if invalidatedByDistance
        box.delete(activeBox)
        line.delete(activeLine)
        if showLabel and not na(activeLabel)
            label.delete(activeLabel)
        active := false

//=========================
// Alerts
//=========================
alertcondition(newBar and bearValid, "Bear Wick", "Bearish 1H rejection wick detected")
alertcondition(newBar and bullValid, "Bull Wick", "Bullish 1H rejection wick detected")
alertcondition(active and not ceTapped and high >= activeCE and low <= activeCE, "CE Tap", "CE tapped")
````
