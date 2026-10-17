# RSI Swing Structure Indicator (HH, LH, HL, LL + Alerts)

- url: https://www.tradingview.com/script/jCRe2N1W-RSI-Swing-Structure-Indicator-HH-LH-HL-LL-Alerts/
- type: indicator
- pine_id: PUB;84a2c0e43e23482db051fe5ec6836ef2
- version: 1.0

## Description

This indicator visualizes market structure using RSI-based swing detection.
It automatically identifies swing highs and lows based on overbought and oversold conditions and classifies them into:

HH (Higher High)
LH (Lower High)
HL (Higher Low)
LL (Lower Low)
How it works

The script uses the RSI to detect momentum extremes:

When RSI reaches the overbought zone, a swing high is formed
When RSI reaches the oversold zone, a swing low is formed

As long as RSI remains in these zones, the swing continues to update dynamically with price.
Once the opposite zone is reached, a new swing is confirmed and the structure is evaluated.

Key Features
Automatic detection of market structure (HH, LH, HL, LL)
Dynamic swing tracking while RSI remains in extreme zones
Optional swing lines connecting highs and lows
Clean chart visualization with minimal noise
Fully configurable RSI settings
Alerts

Built-in alert conditions for:

HH (Higher High)
LH (Lower High)
HL (Higher Low)
LL (Lower Low)
Any new swing event

This allows you to react instantly to structure changes in the market.

Best Use Cases
Trend confirmation and structure analysis
Identifying continuation vs. reversal setups
Combining with EMA, volume, or orderflow strategies
Intraday and swing trading
Tips
Use higher timeframes (e.g. 1H, 4H) for more reliable structure
Combine with trend filters (like EMA 50/100/200) for higher probability setups
Avoid using in low volatility or ranging markets without confirmation

## Source Code

````pine
//@version=6
indicator("RSI Swing Indicator with Swing Alarm", overlay=true, max_bars_back=1000)

// Inputs
rsiSource     = input.source(close, "RSI Source")
rsiLength     = input.int(7, "RSI Length")
rsiOverbought = input.int(70, "RSI Overbought", minval=51, maxval=100)
rsiOversold   = input.int(30, "RSI Oversold", minval=1, maxval=49)

showLabels = input.bool(true, "Show Labels")
showLines  = input.bool(true, "Show Swing Lines")

// RSI
rsiValue = ta.rsi(rsiSource, rsiLength)

isOverbought = rsiValue >= rsiOverbought
isOversold   = rsiValue <= rsiOversold

// State
var int laststate = 0   // 0 = none, 1 = overbought, 2 = oversold

var float hh = na
var float ll = na

var label labelll = na
var label labelhh = na

var line lineUp = na
var line lineDown = na

var float lastHighSwingPrice = na
var float lastLowSwingPrice  = na

// Signal variables
var bool signalHH = false
var bool signalLH = false
var bool signalHL = false
var bool signalLL = false

signalHH := false
signalLH := false
signalHL := false
signalLL := false

// Label text logic
getHighText() =>
    na(lastHighSwingPrice) or high > lastHighSwingPrice ? "HH" : "LH"

getLowText() =>
    na(lastLowSwingPrice) or low > lastLowSwingPrice ? "HL" : "LL"

// New high swing
newHighSwing = laststate == 2 and isOverbought

if newHighSwing
    string txt = getHighText()

    signalHH := txt == "HH"
    signalLH := txt == "LH"

    hh := high

    if showLabels
        labelhh := label.new(
             bar_index,
             high,
             txt,
             yloc=yloc.abovebar,
             style=label.style_label_down,
             color=color.red,
             textcolor=color.white,
             size=size.tiny
        )

    if showLines and not na(labelll)
        lineUp := line.new(
             bar_index,
             high,
             label.get_x(labelll),
             label.get_y(labelll),
             width=1,
             color=color.red
        )

    lastHighSwingPrice := high

// New low swing
newLowSwing = laststate == 1 and isOversold

if newLowSwing
    string txt = getLowText()

    signalHL := txt == "HL"
    signalLL := txt == "LL"

    ll := low

    if showLabels
        labelll := label.new(
             bar_index,
             low,
             txt,
             yloc=yloc.belowbar,
             style=label.style_label_up,
             color=color.green,
             textcolor=color.white,
             size=size.tiny
        )

    if showLines and not na(labelhh)
        lineDown := line.new(
             bar_index,
             low,
             label.get_x(labelhh),
             label.get_y(labelhh),
             width=1,
             color=color.green
        )

    lastLowSwingPrice := low

// Move high swing while RSI stays overbought
if isOverbought
    if na(hh) or high >= hh
        hh := high

        if not na(labelhh)
            string txt = getHighText()
            label.set_x(labelhh, bar_index)
            label.set_y(labelhh, high)
            label.set_text(labelhh, txt)

        if not na(lineUp)
            line.set_x1(lineUp, bar_index)
            line.set_y1(lineUp, high)

    laststate := 1

// Move low swing while RSI stays oversold
if isOversold
    if na(ll) or low <= ll
        ll := low

        if not na(labelll)
            string txt = getLowText()
            label.set_x(labelll, bar_index)
            label.set_y(labelll, low)
            label.set_text(labelll, txt)

        if not na(lineDown)
            line.set_x1(lineDown, bar_index)
            line.set_y1(lineDown, low)

    laststate := 2

// Alerts
alertcondition(signalHH, title="HH erreicht", message="RSI Swing: HH erreicht")
alertcondition(signalLH, title="LH erreicht", message="RSI Swing: LH erreicht")
alertcondition(signalHL, title="HL erreicht", message="RSI Swing: HL erreicht")
alertcondition(signalLL, title="LL erreicht", message="RSI Swing: LL erreicht")

alertcondition(signalHH or signalLH or signalHL or signalLL, title="Neuer RSI Swing", message="RSI Swing: Neues HH/LH/HL/LL Signal erreicht")
````
