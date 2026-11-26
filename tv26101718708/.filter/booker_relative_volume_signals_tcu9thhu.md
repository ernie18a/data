# Booker - Relative Volume Signals

- url: https://www.tradingview.com/script/tCU9thHu-Booker-Relative-Volume-Signals/
- type: indicator
- pine_id: PUB;2364f04ddf534ba8a7b4bca94c760647
- version: 1.0

## Description

Booker RVOL is a momentum breakout indicator designed to identify stocks experiencing unusual buying pressure during the regular trading session.

The indicator looks for a very specific setup often seen in high-momentum small-cap stocks:

* Trading between a user-defined price range (default: $1–$20)
* Up significantly on the day (default: +30% or greater)
* Trading with meaningful liquidity (default: 500,000+ shares)
* Relative Volume (RVOL) above a minimum threshold (default: 4x normal volume)
* Price trading above both VWAP and the 9 EMA
* A breakout above the premarket high
* A bullish “drop-and-pop” pattern, where a red candle is immediately followed by a breakout candle

When all conditions align, the indicator generates an LB RVOL signal and marks the chart.

Included Features

* Relative Volume (RVOL) calculation
* Premarket high tracking
* VWAP and 9 EMA trend confirmation
* Daily gain and volume filtering
* Customizable price range filters
* Entry markers and RVOL labels
* Alert support for automated notifications

Default Philosophy

The default settings are optimized for identifying explosive small-cap momentum stocks that are:

* Gapping higher
* Trading heavy volume
* Holding above key intraday support levels
* Breaking through important resistance levels

Rather than generating frequent signals, LB RVOL focuses on finding rare, high-conviction momentum setups where multiple bullish factors are aligned at the same time.

Signal Interpretation

A signal does not guarantee a successful trade. Instead, it highlights a stock exhibiting:

1. Exceptional relative volume
2. Strong intraday trend structure
3. A breakout above premarket resistance
4. Evidence of continued buying pressure

Many traders use these signals as a starting point for further analysis, including risk management, dilution risk assessment, chart pattern review, and broader market context.

LB RVOL was built to help traders quickly identify stocks attracting institutional and speculative attention before significant intraday moves develop.

## Source Code

````pine
//@version=6
indicator("EP Momentum v26 - ATR Fixed", shorttitle="EPM_v26", overlay=true, max_lines_count=500)

// --- Strategy Inputs ---
float rvolThreshold = input.float(5.0, "Min RVOL", minval=1.0)
int lookback = input.int(50, "RVOL Lookback Period")
float minPrice = input.float(1.0, "Min Price Filter")
float maxPrice = input.float(20.0, "Max Price Filter")

// --- ATR "Hedge Fund" Stop Inputs ---
int atrLength = input.int(14, "ATR Length", minval=1)
float atrMultiplier = input.float(2.5, "ATR Multiplier", minval=1.0, step=0.1)
float initOffset = input.float(0.20, "Hard Stop Offset ($)", minval=0.00, maxval=1.00, step=0.05)

// --- Visual & Table Inputs ---
string tablePosInput = input.string("Top Right", "Table Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left", "Middle Right"])
bool showLevels = input.bool(true, "Show Whole/Half Dollar Levels")

// Wider spacer = further left from TradingView chart controls
int tableLeftOffset = input.int(8, "Table Left Offset", minval=0, maxval=25)

// --- Global Indicators ---
float ema9 = ta.ema(close, 9)
float vwapVal = ta.vwap(close)
float avgVol = ta.sma(volume, lookback)
float rvol = volume / (avgVol > 0 ? avgVol : 1)
float atr = ta.atr(atrLength)

// FIX: Global Cross Logic to prevent CW10002 error
bool vwapCrossUnder = ta.crossunder(close, vwapVal)

// --- Volume Formatting ---
formatVol(v) =>
    if na(v)
        "N/A"
    else if v >= 1000000
        str.tostring(v / 1000000, "#.##") + "M"
    else if v >= 1000
        str.tostring(v / 1000, "#.##") + "K"
    else
        str.tostring(v, "#")

// --- Movable Table Position ---
f_getPos(pos) =>
    switch pos
        "Top Right" => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left" => position.top_left
        "Bottom Left" => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

// --- Pre-Market High ---
var float pmHigh = 0.0
if ta.change(time("D")) != 0
    pmHigh := 0.0
if session.ispremarket
    pmHigh := math.max(pmHigh, high)

// --- State Machine & ATR Trailing Logic ---
var bool inTrade = false
var float maxPriceReached = 0.0
var float hardStop = 0.0
var int lastExitBar = 0

// Entry Logic
bool cooldownOver = (bar_index - lastExitBar) > 5
bool isEntry = not inTrade and cooldownOver and (rvol >= rvolThreshold) and (close > vwapVal) and (close > ema9) and (close > pmHigh) and (close[1] < open[1] or close[1] < ema9[1]) and (close > high[1]) and (close >= minPrice and close <= maxPrice)

if isEntry
    inTrade := true
    maxPriceReached := high
    hardStop := close - initOffset

// ATR Trailing Calculation
float atrStop = 0.0
if inTrade
    maxPriceReached := math.max(maxPriceReached, high)
    atrStop := maxPriceReached - (atr * atrMultiplier)

// Current Active Stop
float activeStop = math.max(hardStop, atrStop)

// Exit Logic
bool isExit = inTrade and (close < activeStop or low < hardStop or vwapCrossUnder)

if isExit
    inTrade := false
    lastExitBar := bar_index
    maxPriceReached := 0.0

// --- Visuals ---
plotshape(isEntry, "Entry Signal", shape.circle, location.belowbar, color.lime, size=size.small)
plotshape(isExit, "Exit Signal", shape.circle, location.abovebar, color.red, size=size.small)

plot(vwapVal, color=color.new(color.orange, 0), title="VWAP", linewidth=2)
plot(ema9, color=color.new(color.blue, 60), title="9 EMA")
plot(inTrade ? activeStop : na, "Active Trailing Stop", color=color.new(color.red, 20), style=plot.style_linebr, linewidth=2)

// PM High Line
var line pmLine = line.new(na, na, na, na, color=color.new(color.yellow, 0), style=line.style_solid, width=2)
if session.ismarket and not session.ispremarket
    line.set_xy1(pmLine, bar_index[1], pmHigh)
    line.set_xy2(pmLine, bar_index, pmHigh)

// --- Table ---
var table panel = table.new(
     f_getPos(tablePosInput),
     3,
     3,
     bgcolor=color.new(color.black, 78),
     border_width=1,
     border_color=color.new(color.gray, 45)
)

if barstate.islast
    table.cell(panel, 0, 0, str.tostring(rvol, "#.##"), text_color=rvol >= rvolThreshold ? color.purple : color.black, text_size=size.small, text_halign=text.align_right)
    table.cell(panel, 1, 0, "RVOL", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 2, 0, "", width=tableLeftOffset, bgcolor=color.new(color.black, 100))

    table.cell(panel, 0, 1, formatVol(volume), text_color=color.black, text_size=size.small, text_halign=text.align_right)
    table.cell(panel, 1, 1, "Vol", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 2, 1, "", width=tableLeftOffset, bgcolor=color.new(color.black, 100))

    table.cell(panel, 0, 2, formatVol(volume[1]), text_color=color.black, text_size=size.small, text_halign=text.align_right)
    table.cell(panel, 1, 2, "Prev Vol", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 2, 2, "", width=tableLeftOffset, bgcolor=color.new(color.black, 100))
````
