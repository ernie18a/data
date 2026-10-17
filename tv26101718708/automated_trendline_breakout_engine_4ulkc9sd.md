# Automated Trendline Breakout Engine 

- url: https://www.tradingview.com/script/4uLkC9sd-Automated-Trendline-Breakout-Engine/
- type: indicator
- pine_id: PUB;f4853bf4666946faafbbdc7f1fa1cca1
- version: 1.0

## Description

Overview

**Automated Trendline Breakout Engine ** automatically detects swing highs and swing lows to build dynamic support and resistance trendlines. The indicator continuously updates these trendlines as new pivots form and generates BUY and SELL signals whenever price breaks above resistance or below support.

The script is designed to provide traders with an objective method of identifying trendline breakouts without manually drawing trendlines.


Features

* Automatic swing high and swing low detection
* Dynamic resistance trendlines
* Dynamic support trendlines
* Real-time breakout detection
* BUY signals when price breaks above resistance
* SELL signals when price breaks below support
* Broken trendlines automatically change to dashed style
* Customizable swing length
* Customizable trendline colors
* Optional signal display

 How It Works

1. Swing Detection

The indicator identifies pivot highs and pivot lows using the selected **Trendline Swing Length**.

Higher values:

* Detect stronger market swings
* Produce fewer but more reliable trendlines

Lower values:

* Detect more swings
* Generate more frequent signals

2. Trendline Construction

Resistance trendlines connect the two most recent pivot highs.

Support trendlines connect the two most recent pivot lows.

Only the latest valid trendline of each type is displayed.


3. Breakout Logic

A BUY signal is generated when:

* Price closes above the active resistance trendline
* Previous candle closed below or on the trendline
* The trendline has not already been broken

A SELL signal is generated when:

* Price closes below the active support trendline
* Previous candle closed above or on the trendline
* The trendline has not already been broken

Once broken, the trendline changes to a dashed line to indicate it has already produced its breakout signal.

Inputs

Trendline Swing Length

Controls pivot sensitivity.

Recommended values:

* 5–8 : Short-term trading
* 10–15 : Swing trading
* 20+ : Position trading

Show Trendline Breakout Signals

Enable or disable BUY/SELL labels.

Trendline Colors

Customize the appearance of:

* Resistance trendlines
* Support trendlines

Best Used On

Works well on:

* Stocks
* Forex
* Crypto
* Commodities
* Indices

Suitable for:

* 15 Minute
* 1 Hour
* 4 Hour
* Daily

Tips

For better accuracy, combine this indicator with:

* Volume confirmation
* Moving averages
* RSI
* MACD
* Higher timeframe trend analysis
* Support and resistance zones

Avoid trading every breakout without confirmation, especially during low-volatility or ranging markets.

Limitations

* Trendlines are based on confirmed pivot points, so they appear only after the required number of bars has completed.
* Breakout signals are generated after pivot confirmation, not before.
* False breakouts can occur in sideways markets.
* This indicator does not predict future price movement; it only reacts to confirmed price action.

Version Notes

Fixed version improvements:

* Accurate trendline price calculation using `line.get_price()`
* Reliable breakout detection
* Prevention of duplicate breakout signals
* Automatic dashed styling for broken trendlines
* Cleaner trendline management

Disclaimer

This indicator is provided for educational and informational purposes only. It should not be considered financial or investment advice. Always perform your own analysis and use proper risk management before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChandraBose2002

//@version=6
indicator("Automated Trendline Breakout Engine ", overlay=true, max_lines_count=100, max_labels_count=100)

// ═══════════════════════════════════════════════════════════════
// INPUTS & CONFIGURATION
// ═══════════════════════════════════════════════════════════════
swingLength   = input.int(10, "Trendline Swing Length (Higher = Major Lines)", minval=2, group="Trendline Settings")
showSignals   = input.bool(true, "Show Trendline Breakout Signals", group="Signals")

colorBullLine = input.color(color.new(color.green, 30), "Resistance (Bullish Break) Line", group="Visuals")
colorBearLine = input.color(color.new(color.red, 30), "Support (Bearish Break) Line", group="Visuals")

// ═══════════════════════════════════════════════════════════════
// DETECT PIVOT POINTS
// ═══════════════════════════════════════════════════════════════
pHigh = ta.pivothigh(high, swingLength, swingLength)
pLow  = ta.pivotlow(low, swingLength, swingLength)

var int   ph1_bar = na, var float ph1_val = na
var int   ph2_bar = na, var float ph2_val = na

var int   pl1_bar = na, var float pl1_val = na
var int   pl2_bar = na, var float pl2_val = na

var line resistanceLine = na
var line supportLine    = na

// ═══════════════════════════════════════════════════════════════
// UPDATE RESISTANCE TRENDLINES (CONNECTING SWING HIGHS)
// ═══════════════════════════════════════════════════════════════
if not na(pHigh)
    ph2_bar := ph1_bar
    ph2_val := ph1_val
    ph1_bar := bar_index - swingLength
    ph1_val := pHigh

    if not na(ph2_bar)
        if not na(resistanceLine)
            line.delete(resistanceLine)
        resistanceLine := line.new(x1=ph2_bar, y1=ph2_val, x2=ph1_bar, y2=ph1_val, 
                                   extend=extend.right, color=colorBullLine, width=2)

// ═══════════════════════════════════════════════════════════════
// UPDATE SUPPORT TRENDLINES (CONNECTING SWING LOWS)
// ═══════════════════════════════════════════════════════════════
if not na(pLow)
    pl2_bar := pl1_bar
    pl2_val := pl1_val
    pl1_bar := bar_index - swingLength
    pl1_val := pLow

    if not na(pl2_bar)
        if not na(supportLine)
            line.delete(supportLine)
        supportLine := line.new(x1=pl2_bar, y1=pl2_val, x2=pl1_bar, y2=pl1_val, 
                                 extend=extend.right, color=colorBearLine, width=2)

// ═══════════════════════════════════════════════════════════════
// BREAKOUT DETECTION LOGIC
// ═══════════════════════════════════════════════════════════════
bool triggerBuy  = false
bool triggerSell = false

var bool resBroken = true
var bool supBroken = true

if not na(pHigh)
    resBroken := false
if not na(pLow)
    supBroken := false

// FIXED SECTION: Uses line.get_price() with current bar_index
if not na(resistanceLine) and not resBroken
    float currentResPrice = line.get_price(resistanceLine, bar_index) 
    if close > currentResPrice and close[1] <= currentResPrice
        triggerBuy := true
        resBroken  := true
        line.set_style(resistanceLine, line.style_dashed) 

if not na(supportLine) and not supBroken
    float currentSupPrice = line.get_price(supportLine, bar_index)
    if close < currentSupPrice and close[1] >= currentSupPrice
        triggerSell := true
        supBroken   := true
        line.set_style(supportLine, line.style_dashed)

// ═══════════════════════════════════════════════════════════════
// PLOT SIGNALS
// ═══════════════════════════════════════════════════════════════
plotshape(showSignals and triggerBuy ? low : na, title="Trendline Buy Breakout", 
          style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="BUY")

plotshape(showSignals and triggerSell ? high : na, title="Trendline Sell Breakout", 
          style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL")
````
