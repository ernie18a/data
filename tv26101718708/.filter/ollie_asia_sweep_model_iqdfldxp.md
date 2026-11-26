# Ollie Asia Sweep Model 

- url: https://www.tradingview.com/script/iqDfldxP-Ollie-Asia-Sweep-Model/
- type: indicator
- pine_id: PUB;dfef99ad4fba49dc85194113ec0ae667
- version: 1.0

## Description

big willy moves only. plots valid and invalid asia sweeps based off displacement and a killzone

## Source Code

````pine
//@version=6
indicator("Ollie Asia Sweep Model Validator", overlay=true, max_labels_count=500, max_boxes_count=100, max_lines_count=500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
tz              = input.string("Europe/London", "Timezone")
asiaSession     = input.session("0000-0600", "Asia session 00:00-06:00")
preSweepSession = input.session("0600-0700", "Pre-sweep invalidation window")
tradeSession    = input.session("0700-0830", "Trade window")

minSweepPct     = input.float(5.0, "Min sweep depth % of Asia", step=0.25)
minDispPct      = input.float(30.0, "Min displacement % of Asia", step=0.5)
minBodyWick     = input.float(1.0, "Min body:wick ratio", step=0.1)
maxSweepToFvg   = input.int(40, "Max minutes: sweep to FVG")
dispCandles     = input.int(3, "Body:wick candle sample", minval=2, maxval=5)

showAsiaBox     = input.bool(true, "Show Asia range box")
showKillzoneBox = input.bool(true, "Show killzone box")
showFvgBox      = input.bool(true, "Show displacement FVG box")
showLabels      = input.bool(true, "Show event labels")
labelAtrOffset  = input.float(5, "Signpost distance from price ATR", step=0.25)
showLabelStems  = input.bool(true, "Show signpost stems")

// ─────────────────────────────────────────────
// SESSION LOGIC
// ─────────────────────────────────────────────
inAsia     = not na(time(timeframe.period, asiaSession, tz))
inPreSweep = not na(time(timeframe.period, preSweepSession, tz))
inTrade    = not na(time(timeframe.period, tradeSession, tz))
newDay     = ta.change(time("D", "0000-2359", tz)) != 0

// ─────────────────────────────────────────────
// ASIA RANGE
// ─────────────────────────────────────────────
var float asiaHigh = na
var float asiaLow  = na
var box asiaBox    = na

if newDay
    asiaHigh := na
    asiaLow  := na

    if not na(asiaBox)
        box.delete(asiaBox)

    asiaBox := na

if inAsia and not inAsia[1]
    asiaHigh := high
    asiaLow  := low

    if showAsiaBox
        asiaBox := box.new(
             left=time,
             top=asiaHigh,
             right=time_close,
             bottom=asiaLow,
             xloc=xloc.bar_time,
             bgcolor=color.new(color.gray, 75),
             border_color=color.new(color.gray, 100),
             border_width=0
        )

if inAsia
    asiaHigh := math.max(nz(asiaHigh, high), high)
    asiaLow  := math.min(nz(asiaLow, low), low)

if showAsiaBox and inAsia and not na(asiaBox) and not na(asiaHigh) and not na(asiaLow)
    box.set_right(asiaBox, time_close)
    box.set_top(asiaBox, asiaHigh)
    box.set_bottom(asiaBox, asiaLow)

asiaRange = asiaHigh - asiaLow

plot(asiaHigh, "Asia High", color=color.new(color.green, 0), style=plot.style_linebr)
plot(asiaLow, "Asia Low", color=color.new(color.red, 0), style=plot.style_linebr)

// ─────────────────────────────────────────────
// KILLZONE BOX
// ─────────────────────────────────────────────
var float killHigh = na
var float killLow  = na
var box killBox    = na

if newDay
    killHigh := na
    killLow  := na

    if not na(killBox)
        box.delete(killBox)

    killBox := na

if inTrade and not inTrade[1]
    killHigh := high
    killLow  := low

    if showKillzoneBox
        killBox := box.new(
             left=time,
             top=killHigh,
             right=time_close,
             bottom=killLow,
             xloc=xloc.bar_time,
             bgcolor=color.new(color.orange, 75),
             border_color=color.new(color.orange, 100),
             border_width=0
        )

if inTrade
    killHigh := math.max(nz(killHigh, high), high)
    killLow  := math.min(nz(killLow, low), low)

if showKillzoneBox and inTrade and not na(killBox) and not na(killHigh) and not na(killLow)
    box.set_right(killBox, time_close)
    box.set_top(killBox, killHigh)
    box.set_bottom(killBox, killLow)

// ─────────────────────────────────────────────
// SIGNPOST HELPER
// ─────────────────────────────────────────────
atrForLabels = ta.atr(14)

f_signpost(_x, _anchorPrice, _isAbove, _text, _color) =>
    labelPrice = _isAbove ? _anchorPrice + atrForLabels * labelAtrOffset : _anchorPrice - atrForLabels * labelAtrOffset

    if showLabelStems
        line.new(
             x1=_x,
             y1=_anchorPrice,
             x2=_x,
             y2=labelPrice,
             xloc=xloc.bar_index,
             color=color.new(_color, 20),
             width=1,
             style=line.style_solid
        )

    label.new(
         x=_x,
         y=labelPrice,
         text=_text,
         xloc=xloc.bar_index,
         style=label.style_label_center,
         textcolor=color.white,
         color=_color,
         size=size.small
    )

// ─────────────────────────────────────────────
// SWEEP STATE
// ─────────────────────────────────────────────
var bool swept = false
var string sweepSide = ""
var float sweepExtreme = na
var float sweepDepthPct = na
var int sweepTime = na
var bool validSweep = false
var bool dayInvalidatedByPreSweep = false
var bool weakSweepLive = false

var bool displacementConfirmed = false
var float displacementPct = na
var float bodyWickRatio = na
var int sweepToFvgMins = na

if newDay
    swept := false
    sweepSide := ""
    sweepExtreme := na
    sweepDepthPct := na
    sweepTime := na
    validSweep := false
    dayInvalidatedByPreSweep := false
    weakSweepLive := false
    displacementConfirmed := false
    displacementPct := na
    bodyWickRatio := na
    sweepToFvgMins := na

// ─────────────────────────────────────────────
// PRE-SWEEP INVALIDATION
// ─────────────────────────────────────────────
canPreSweep = inPreSweep and not na(asiaHigh) and not na(asiaLow) and asiaRange > 0

preBslSweep = canPreSweep and high > asiaHigh
preSslSweep = canPreSweep and low < asiaLow

if not dayInvalidatedByPreSweep and preBslSweep
    dayInvalidatedByPreSweep := true

    if showLabels
        f_signpost(
             bar_index,
             high,
             true,
             "PRE SWEEP\nBSL swept before 07:00\nDAY INVALID",
             color.new(color.red, 0)
        )

if not dayInvalidatedByPreSweep and preSslSweep
    dayInvalidatedByPreSweep := true

    if showLabels
        f_signpost(
             bar_index,
             low,
             false,
             "PRE SWEEP\nSSL swept before 07:00\nDAY INVALID",
             color.new(color.red, 0)
        )

// ─────────────────────────────────────────────
// NORMAL TRADE WINDOW SWEEP DETECTION
// Weak sweeps still make trade live.
// ─────────────────────────────────────────────
canSweep = inTrade and not dayInvalidatedByPreSweep and not na(asiaHigh) and not na(asiaLow) and asiaRange > 0

bslSweep = canSweep and high > asiaHigh
sslSweep = canSweep and low < asiaLow

if not swept and bslSweep
    swept := true
    sweepSide := "BSL swept → looking short"
    sweepExtreme := high
    sweepDepthPct := ((high - asiaHigh) / asiaRange) * 100
    sweepTime := time
    validSweep := sweepDepthPct >= minSweepPct
    weakSweepLive := not validSweep

    if showLabels
        f_signpost(
             bar_index,
             high,
             true,
             validSweep ? "VALID BSL Sweep\nDepth: " + str.tostring(sweepDepthPct, "#.##") + "%" : "WEAK BSL Sweep\nDepth: " + str.tostring(sweepDepthPct, "#.##") + "%\nTrade live",
             validSweep ? color.new(color.green, 0) : color.new(color.orange, 0)
        )

if not swept and sslSweep
    swept := true
    sweepSide := "SSL swept → looking long"
    sweepExtreme := low
    sweepDepthPct := ((asiaLow - low) / asiaRange) * 100
    sweepTime := time
    validSweep := sweepDepthPct >= minSweepPct
    weakSweepLive := not validSweep

    if showLabels
        f_signpost(
             bar_index,
             low,
             false,
             validSweep ? "VALID SSL Sweep\nDepth: " + str.tostring(sweepDepthPct, "#.##") + "%" : "WEAK SSL Sweep\nDepth: " + str.tostring(sweepDepthPct, "#.##") + "%\nTrade live",
             validSweep ? color.new(color.green, 0) : color.new(color.orange, 0)
        )

if swept and not displacementConfirmed and sweepSide == "BSL swept → looking short" and high > sweepExtreme
    sweepExtreme := high
    sweepDepthPct := ((high - asiaHigh) / asiaRange) * 100
    validSweep := sweepDepthPct >= minSweepPct
    weakSweepLive := not validSweep

if swept and not displacementConfirmed and sweepSide == "SSL swept → looking long" and low < sweepExtreme
    sweepExtreme := low
    sweepDepthPct := ((asiaLow - low) / asiaRange) * 100
    validSweep := sweepDepthPct >= minSweepPct
    weakSweepLive := not validSweep

// ─────────────────────────────────────────────
// DISPLACEMENT + FVG LOGIC
// ─────────────────────────────────────────────
body = math.abs(close - open)
wick = (high - math.max(open, close)) + (math.min(open, close) - low)

bodySum = math.sum(body, dispCandles)
wickSum = math.sum(wick, dispCandles)

ratio = wickSum == 0 ? na : bodySum / wickSum

twoBearish = close < open and close[1] < open[1]
twoBullish = close > open and close[1] > open[1]

bearishFvg = high < low[2]
bullishFvg = low > high[2]

lookingShort = swept and sweepSide == "BSL swept → looking short"
lookingLong  = swept and sweepSide == "SSL swept → looking long"

bearishDisplacement = lookingShort and twoBearish and bearishFvg
bullishDisplacement = lookingLong and twoBullish and bullishFvg

currentDispPctShort = lookingShort and asiaRange > 0 ? ((sweepExtreme - close) / asiaRange) * 100 : na
currentDispPctLong  = lookingLong and asiaRange > 0 ? ((close - sweepExtreme) / asiaRange) * 100 : na

candidateDisplacement = inTrade and not displacementConfirmed and swept and (bearishDisplacement or bullishDisplacement)

if candidateDisplacement
    sweepToFvgMins := int((time - sweepTime) / 60000)
    displacementPct := bearishDisplacement ? currentDispPctShort : currentDispPctLong
    bodyWickRatio := ratio

    timeValid = sweepToFvgMins <= maxSweepToFvg
    dispValid = displacementPct >= minDispPct
    ratioValid = bodyWickRatio >= minBodyWick

    displacementConfirmed := timeValid and dispValid and ratioValid

    if showFvgBox
        if bearishDisplacement
            box.new(
                 left=time[2],
                 top=low[2],
                 right=time_close,
                 bottom=high,
                 xloc=xloc.bar_time,
                 bgcolor=color.new(color.red, 85),
                 border_color=color.new(color.red, 20)
            )

        if bullishDisplacement
            box.new(
                 left=time[2],
                 top=low,
                 right=time_close,
                 bottom=high[2],
                 xloc=xloc.bar_time,
                 bgcolor=color.new(color.green, 85),
                 border_color=color.new(color.green, 20)
            )

    if showLabels
        labelText = displacementConfirmed ? "VALID DISPLACEMENT" : "FAILED DISPLACEMENT"
        labelText += weakSweepLive ? "\nSweep: weak" : "\nSweep: valid"
        labelText += "\nSweep depth: " + str.tostring(sweepDepthPct, "#.##") + "%"
        labelText += "\nDisp: " + str.tostring(displacementPct, "#.##") + "%"
        labelText += "\nB:W: " + str.tostring(bodyWickRatio, "#.##")
        labelText += "\nTime: " + str.tostring(sweepToFvgMins) + "m"

        f_signpost(
             bar_index,
             bearishDisplacement ? high : low,
             bearishDisplacement,
             labelText,
             displacementConfirmed ? color.new(color.green, 0) : color.new(color.red, 0)
        )

// ─────────────────────────────────────────────
// VISUAL SIGNALS
// ─────────────────────────────────────────────
plotshape(
     bslSweep and not swept[1],
     title="BSL Sweep",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     text="BSL"
)

plotshape(
     sslSweep and not swept[1],
     title="SSL Sweep",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.green,
     size=size.small,
     text="SSL"
)

// ─────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 8, border_width=1)

status =
     dayInvalidatedByPreSweep ? "INVALID: pre sweep" :
     displacementConfirmed ? "MODEL CONFIRMED" :
     swept and weakSweepLive ? "Weak sweep live / waiting FVG" :
     swept and validSweep ? "Valid sweep / waiting FVG" :
     not inTrade and not swept ? "Waiting" :
     "Monitoring"

statusColor =
     dayInvalidatedByPreSweep ? color.new(color.red, 0) :
     displacementConfirmed ? color.new(color.green, 0) :
     swept and weakSweepLive ? color.new(color.orange, 0) :
     swept and validSweep ? color.new(color.green, 0) :
     color.new(color.gray, 0)

if barstate.islast
    table.cell(dash, 0, 0, "Model Status", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, status, text_color=color.white, bgcolor=statusColor)

    table.cell(dash, 0, 1, "Asia Range")
    table.cell(dash, 1, 1, na(asiaRange) ? "n/a" : str.tostring(asiaRange, "#.#####"))

    table.cell(dash, 0, 2, "Sweep")
    table.cell(dash, 1, 2, dayInvalidatedByPreSweep ? "Pre-sweep invalid" : swept ? sweepSide : "None")

    table.cell(dash, 0, 3, "Sweep Depth")
    table.cell(dash, 1, 3, na(sweepDepthPct) ? "n/a" : str.tostring(sweepDepthPct, "#.##") + "%")

    table.cell(dash, 0, 4, "Sweep Quality")
    table.cell(dash, 1, 4, dayInvalidatedByPreSweep ? "DAY INVALID" : swept and weakSweepLive ? "WEAK BUT LIVE" : validSweep ? "VALID" : "n/a")

    table.cell(dash, 0, 5, "Displacement")
    table.cell(dash, 1, 5, na(displacementPct) ? "n/a" : str.tostring(displacementPct, "#.##") + "%")

    table.cell(dash, 0, 6, "Body:Wick")
    table.cell(dash, 1, 6, na(bodyWickRatio) ? "n/a" : str.tostring(bodyWickRatio, "#.##"))

    table.cell(dash, 0, 7, "Sweep → FVG")
    table.cell(dash, 1, 7, na(sweepToFvgMins) ? "n/a" : str.tostring(sweepToFvgMins) + "m")

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(dayInvalidatedByPreSweep and not dayInvalidatedByPreSweep[1], "Pre-sweep Day Invalidated", "Asia liquidity swept between 06:00 and 07:00. Day invalidated.")
alertcondition(swept and not swept[1], "Asia Sweep Detected", "Asia sweep detected. Trade is live.")
alertcondition(validSweep and not validSweep[1], "Valid Asia Sweep", "Valid Asia sweep detected.")
alertcondition(displacementConfirmed and not displacementConfirmed[1], "Valid Displacement Confirmed", "Valid displacement confirmed after Asia sweep.")
````
