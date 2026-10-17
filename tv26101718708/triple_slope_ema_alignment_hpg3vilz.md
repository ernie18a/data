# Triple Slope EMA Alignment

- url: https://www.tradingview.com/script/Hpg3vilz-Triple-Slope-EMA-Alignment/
- type: indicator
- pine_id: PUB;9ef507f318e9414eb945619a9b00a2a5
- version: 1.0

## Description

[url=https://www.tradingview.com/x/3dC4uvZV/]https://www.tradingview.com/x/3dC4uvZV/[/url]

Triple Slope EMA Alignment is an open-source trend-state indicator that plots EMA 50, EMA 100, and EMA 200 with color-coded slope logic.

Each EMA is evaluated using an ATR-normalized slope angle. This helps compare the EMA slope against recent volatility instead of relying only on raw price movement.

Line colors:

Green = bullish slope above the positive degree threshold.

Red = bearish slope below the negative degree threshold.

Yellow = flat or neutral slope between the two thresholds.

The default slope thresholds are +0.5 and -0.5 degrees.

A BUY label appears when EMA 50, EMA 100, and EMA 200 are all bullish at the same time.

A SELL label appears when EMA 50, EMA 100, and EMA 200 are all bearish at the same time.

The labels are confirmed on bar close and are designed to mark full slope alignment, not every individual EMA color change.

This script does not guarantee future price direction. It is intended as a visual trend-alignment tool that can be used with price action, volume, support/resistance, and other confirmation methods.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
//
// Triple Slope EMA Alignment
// Open-source TradingView indicator
//
// This script plots EMA 50, EMA 100, and EMA 200.
// Each EMA is colored by its own ATR-normalized slope angle.
// A BUY label appears when all three EMA slopes align bullish.
// A SELL label appears when all three EMA slopes align bearish.

//@version=6
indicator("Triple Slope EMA Alignment", shorttitle="3Slope EMA Align", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SLOPE ENGINE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpSlope = "Slope Engine"

i_slopePer    = input.int(10, "Slope Lookback Bars", group=grpSlope, minval=1)
i_slopeAtrLen = input.int(14, "ATR Length For Normalization", group=grpSlope, minval=1)
i_slopeScale  = input.float(2.0, "ATR Scale Factor", group=grpSlope, step=0.1)

i_degUp       = input.float(0.5, "Degree Threshold Green", group=grpSlope, step=0.1)
i_degDn       = input.float(-0.5, "Degree Threshold Red", group=grpSlope, step=0.1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpEMA = "EMA Lines"

i_emaFastLen = input.int(50, "Fast EMA Length", group=grpEMA, minval=1)
i_emaMidLen  = input.int(100, "Middle EMA Length", group=grpEMA, minval=1)
i_emaSlowLen = input.int(200, "Slow EMA Length", group=grpEMA, minval=1)

i_fastWidth = input.int(2, "EMA 50 Width", group=grpEMA, minval=1, maxval=10)
i_midWidth  = input.int(3, "EMA 100 Width", group=grpEMA, minval=1, maxval=10)
i_slowWidth = input.int(4, "EMA 200 Width", group=grpEMA, minval=1, maxval=10)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpVisual = "Visuals"

i_clrGreen  = input.color(color.lime, "Bullish Slope Color", group=grpVisual)
i_clrRed    = input.color(#FF1744, "Bearish Slope Color", group=grpVisual)
i_clrYellow = input.color(color.yellow, "Flat / Neutral Slope Color", group=grpVisual)

i_showLabels = input.bool(true, "Show BUY / SELL Labels", group=grpVisual)
i_labelSizeInput = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grpVisual)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_slopeState(_ma, _lookback, _atr, _scale, _up, _dn) =>
    _past = _ma[_lookback]
    _slopeRaw = not na(_past) ? (_ma - _past) / _lookback : 0.0
    _normalized = _atr > 0.0 ? _slopeRaw / (_atr * _scale) : 0.0
    _degree = math.todegrees(math.atan(_normalized))
    _state = _degree > _up ? 1 : _degree < _dn ? -1 : 0
    [_degree, _state]

f_stateColor(_state, _green, _red, _yellow) =>
    _state == 1 ? _green : _state == -1 ? _red : _yellow

labelSize = i_labelSizeInput == "Tiny" ? size.tiny : i_labelSizeInput == "Small" ? size.small : i_labelSizeInput == "Normal" ? size.normal : size.large

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaFast = ta.ema(close, i_emaFastLen)
emaMid  = ta.ema(close, i_emaMidLen)
emaSlow = ta.ema(close, i_emaSlowLen)

atrVal = ta.atr(i_slopeAtrLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SLOPE STATES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[degreeFast, stateFast] = f_slopeState(emaFast, i_slopePer, atrVal, i_slopeScale, i_degUp, i_degDn)
[degreeMid,  stateMid]  = f_slopeState(emaMid,  i_slopePer, atrVal, i_slopeScale, i_degUp, i_degDn)
[degreeSlow, stateSlow] = f_slopeState(emaSlow, i_slopePer, atrVal, i_slopeScale, i_degUp, i_degDn)

colorFast = f_stateColor(stateFast, i_clrGreen, i_clrRed, i_clrYellow)
colorMid  = f_stateColor(stateMid,  i_clrGreen, i_clrRed, i_clrYellow)
colorSlow = f_stateColor(stateSlow, i_clrGreen, i_clrRed, i_clrYellow)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALIGNMENT CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
allBullish = stateFast == 1 and stateMid == 1 and stateSlow == 1
allBearish = stateFast == -1 and stateMid == -1 and stateSlow == -1

buySignal  = barstate.isconfirmed and allBullish and not (allBullish[1] == true)
sellSignal = barstate.isconfirmed and allBearish and not (allBearish[1] == true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(emaFast, title="EMA 50 Slope", color=colorFast, linewidth=i_fastWidth)
plot(emaMid,  title="EMA 100 Slope", color=colorMid, linewidth=i_midWidth)
plot(emaSlow, title="EMA 200 Slope", color=colorSlow, linewidth=i_slowWidth)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if i_showLabels and buySignal
    label.new(
         bar_index,
         low,
         "BUY\n3 EMA Slope",
         style=label.style_label_up,
         textcolor=color.white,
         color=color.new(i_clrGreen, 0),
         size=labelSize
     )

if i_showLabels and sellSignal
    label.new(
         bar_index,
         high,
         "SELL\n3 EMA Slope",
         style=label.style_label_down,
         textcolor=color.white,
         color=color.new(i_clrRed, 0),
         size=labelSize
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(buySignal, title="BUY - Triple EMA Slope Alignment", message="BUY: EMA 50, EMA 100, and EMA 200 slopes are all bullish.")
alertcondition(sellSignal, title="SELL - Triple EMA Slope Alignment", message="SELL: EMA 50, EMA 100, and EMA 200 slopes are all bearish.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA WINDOW ONLY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(degreeFast, "EMA 50 Slope Degree", display=display.data_window, color=color.new(color.white, 100))
plot(degreeMid, "EMA 100 Slope Degree", display=display.data_window, color=color.new(color.white, 100))
plot(degreeSlow, "EMA 200 Slope Degree", display=display.data_window, color=color.new(color.white, 100))

plot(stateFast, "EMA 50 State: 1 Green / 0 Flat / -1 Red", display=display.data_window, color=color.new(color.white, 100))
plot(stateMid, "EMA 100 State: 1 Green / 0 Flat / -1 Red", display=display.data_window, color=color.new(color.white, 100))
plot(stateSlow, "EMA 200 State: 1 Green / 0 Flat / -1 Red", display=display.data_window, color=color.new(color.white, 100))
````
