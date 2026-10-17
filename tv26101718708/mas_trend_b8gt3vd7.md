# MAs trend

- url: https://www.tradingview.com/script/B8GT3Vd7-MAs-trend/
- type: indicator
- pine_id: PUB;d2dd6de200c841b98e53f883ab8673e7
- version: 1.0

## Description

**MAs Trend**

MAs Trend is a clean visual trend indicator based on two moving averages: a fast MA and a slower MA. It is designed to help identify the current trend direction and highlight potential trend shifts.

The indicator colors the moving averages and the MA zone green during uptrends and red during downtrends. A gradient fill between the MAs makes the trend zone easier to read, while trend turn markers highlight possible shifts in direction.

**Main features**

* Fast and slow moving average trend structure
* EMA or SMA selection
* Optional smoothing for both moving averages
* Dynamic uptrend and downtrend colors
* Gradient fill between the moving averages
* Extra outer band around the slower MA
* Trend turn markers
* Optional session filter
* Alerts on trend turns

This indicator is intended as a visual trend filter and can be combined with price action, pullbacks, triggers, or other trading rules.

## Source Code

````pine
//@version=6


// INDICATOR
indicator(title="MAs trend", overlay=true, precision=3, max_bars_back=200)


// INPUTS

// MA inputs
var groupNameMa          = "Moving averages"
maTypeInput              = input.string("ema", title="MA type", options=["ema", "sma"], group=groupNameMa)
maFastLengthInput        = input.int(8, title="MA fast length", group=groupNameMa)
maFastSmoothInput        = input.int(2, title="MA fast smoothing", group=groupNameMa, tooltip="Use 0 or 1 to disable smoothing.")
maLengthInput            = input.int(18, title="MA length", group=groupNameMa)
maSmoothInput            = input.int(2, title="MA smoothing", group=groupNameMa, tooltip="Use 0 or 1 to disable smoothing.")

// MA color inputs
var groupNameMaColors        = "MAs colors"
maUpColorInput               = input.color(#3ba43b, title="MA up color", group=groupNameMaColors)
maDnColorInput               = input.color(#e01b1b, title="MA down color", group=groupNameMaColors)
maGradientTransparency1Input = input.int(92, title="Gradient transparency 1", minval=0, maxval=100, group=groupNameMaColors)
maGradientTransparency2Input = input.int(86, title="Gradient transparency 2", minval=0, maxval=100, group=groupNameMaColors)
maGradientTransparency3Input = input.int(80, title="Gradient transparency 3", minval=0, maxval=100, group=groupNameMaColors)
maGradientTransparency4Input = input.int(74, title="Gradient transparency 4", minval=0, maxval=100, group=groupNameMaColors)
maGradientTransparency5Input = input.int(68, title="Gradient transparency 5", minval=0, maxval=100, group=groupNameMaColors)

// Session filter inputs
var groupNameSession            = "Session"
sessionFilterEnabledInput       = input.bool(false, title="Session filter enabled", group=groupNameSession, tooltip="Used to limit setups and alerts to the specified session time window")
sessionTimesInput               = input.session("0100-1430", title="Session times", group=groupNameSession)
notInSessionBgColorEnabledInput = input.bool(true, title="Background color outside session times enabled", group=groupNameSession)


// CALCULATIONS


// --- Moving averages --- //

// Helper: choose base MA without computing both (use if)
movingAverage(_src, _len, _type) =>
    _lenSafe = math.max(_len, 1)
    float _out = na
    if _type == "ema"
        _out := ta.ema(_src, _lenSafe)
    else
        _out := ta.sma(_src, _lenSafe)
    _out

// Base MAs (price)
maBase     = movingAverage(close, maLengthInput,     maTypeInput)
maFastBase = movingAverage(close, maFastLengthInput, maTypeInput)

// Optional smoothing (0/1 disables smoothing)
ma     = maSmoothInput > 1     ? ta.sma(maBase,     maSmoothInput)     : maBase
maFast = maFastSmoothInput > 1 ? ta.sma(maFastBase, maFastSmoothInput) : maFastBase

// MA relative positions
maFastAboveMa = maFast > ma
maFastBelowMa = maFast < ma

// MA directions
maRising    = ma > ma[1]
maDeclining = ma < ma[1]


// --- Bar-MA relationships --- //

// Bar high/low/close relative to MAs
lowAboveMaFast  = low  > maFast
highBelowMaFast = high < maFast
lowAboveMa      = low  > ma
highBelowMa     = high < ma


// --- Filters --- //

// Session filter
// Used to limit alerts to the session time window
inSession = sessionFilterEnabledInput ? not na(time(timeframe.period, sessionTimesInput)) : true


// --- MA gain --- //
// Price clearly trades at one side of both MAs which marks the start of a trend

// MAs gain up/down
masGainUp = lowAboveMa
masGainDn = highBelowMa

// Persistent state: last MA gain direction
//  1 = up gain was most recent
// -1 = down gain was most recent
//  0 = none yet
var int masGainState = 0

if masGainUp and not masGainDn
    masGainState := 1
else if masGainDn and not masGainUp
    masGainState := -1


// --- Trend --- //

// Trend start
trendUpStart = (masGainState == 1)  and (maFastAboveMa or maRising)
trendDnStart = (masGainState == -1) and (maFastBelowMa or maDeclining)

// Persistent state: last trend start direction
//  1 = up trend
// -1 = down trend
//  0 = none yet
var int trendState = 0

if trendUpStart and not trendDnStart
    trendState := 1
else if trendDnStart and not trendUpStart
    trendState := -1

// Trend
trendUp = trendState == 1
trendDn = trendState == -1

// Trend turn
trendTurnUp = trendUp and not trendUp[1]
trendTurnDn = trendDn and not trendDn[1]


// --- MA gradient fill --- //

// Intermediate lines between fast MA and slow MA
maStep1 = maFast + (ma - maFast) * 0.2
maStep2 = maFast + (ma - maFast) * 0.4
maStep3 = maFast + (ma - maFast) * 0.6
maStep4 = maFast + (ma - maFast) * 0.8

// Extra dark band on the other side of the slow MA
maGap   = math.abs(maFast - ma)
maOuter = trendUp ? ma - maGap * 0.2 :
          trendDn ? ma + maGap * 0.2 :
          na

// Gradient colors based on MA color inputs
maGrad1 = trendUp ? color.new(maUpColorInput, maGradientTransparency1Input) : trendDn ? color.new(maDnColorInput, maGradientTransparency1Input) : na
maGrad2 = trendUp ? color.new(maUpColorInput, maGradientTransparency2Input) : trendDn ? color.new(maDnColorInput, maGradientTransparency2Input) : na
maGrad3 = trendUp ? color.new(maUpColorInput, maGradientTransparency3Input) : trendDn ? color.new(maDnColorInput, maGradientTransparency3Input) : na
maGrad4 = trendUp ? color.new(maUpColorInput, maGradientTransparency4Input) : trendDn ? color.new(maDnColorInput, maGradientTransparency4Input) : na
maGrad5 = trendUp ? color.new(maUpColorInput, maGradientTransparency5Input) : trendDn ? color.new(maDnColorInput, maGradientTransparency5Input) : na


// VISUAL OUTPUT

// MAs
maFastPlot = plot(
     maFast,
     "MA fast",
     trendUp ? maUpColorInput : trendDn ? maDnColorInput : color.new(color.blue, 0),
     1
)

maPlot = plot(
     ma,
     "MA",
     trendUp ? maUpColorInput : trendDn ? maDnColorInput : color.new(color.blue, 0),
     2
)

// Hidden plots for gradient fills
maStep1Plot = plot(maStep1, title="MA gradient step 1", color=na, display=display.none)
maStep2Plot = plot(maStep2, title="MA gradient step 2", color=na, display=display.none)
maStep3Plot = plot(maStep3, title="MA gradient step 3", color=na, display=display.none)
maStep4Plot = plot(maStep4, title="MA gradient step 4", color=na, display=display.none)
maOuterPlot = plot(maOuter, title="MA outer dark band", color=na, display=display.none)

// Gradient fills between fast MA and slow MA
fill(maFastPlot,  maStep1Plot, color=maGrad1, title="MA gradient 1")
fill(maStep1Plot, maStep2Plot, color=maGrad2, title="MA gradient 2")
fill(maStep2Plot, maStep3Plot, color=maGrad3, title="MA gradient 3")
fill(maStep3Plot, maStep4Plot, color=maGrad4, title="MA gradient 4")
fill(maStep4Plot, maPlot,      color=maGrad5, title="MA gradient 5")

// Extra dark band on the outer side of the slow MA
fill(maPlot, maOuterPlot, color=maGrad5, title="MA outer dark band fill")

// Shapes
plotshape(
     trendTurnUp,
     title="Trend turn up",
     style=shape.triangleup,
     location=location.abovebar,
     color=maUpColorInput
)

plotshape(
     trendTurnDn,
     title="Trend turn down",
     style=shape.triangledown,
     location=location.belowbar,
     color=maDnColorInput
)

// Not in session background color
bgcolor( inSession ? na : notInSessionBgColorEnabledInput ? color.new(color.gray,95) : na, title="Outside session background color" )


// ALERTS

// Trend turns
tfLabel = timeframe.isintraday ? str.tostring(timeframe.multiplier) + "m" :
          timeframe.isdaily    ? str.tostring(timeframe.multiplier) + "D" :
          timeframe.isweekly   ? str.tostring(timeframe.multiplier) + "W" :
          timeframe.ismonthly  ? str.tostring(timeframe.multiplier) + "M" :
          timeframe.period

if trendTurnUp or trendTurnDn
    string dir = trendTurnUp ? "up" : trendTurnDn ? "down" : ""
    alert(syminfo.ticker + ": Trend turn " + dir + " (" + tfLabel + ")", alert.freq_once_per_bar_close)
````
