# SFM Real Footprint Imbalance Zones

- url: https://www.tradingview.com/script/0xhR1DPk-SFM-Real-Footprint-Imbalance-Zones/
- type: indicator
- pine_id: PUB;2421cfca849847549d9d94bb33a7e8b4
- version: 1.0

## Description

Professional footprint-based order flow visualization built using TradingView's native footprint data.

Unlike traditional "delta" or "volume imbalance" indicators that estimate buying and selling pressure from candle position, this indicator utilizes TradingView's footprint engine to access actual footprint-derived Buy Volume, Sell Volume, and Delta values directly from the chart.

Features
Real Footprint Delta

Uses TradingView footprint data to measure actual buying versus selling pressure on each bar.

Buy/Sell Control Analysis

Calculates the percentage of volume controlled by buyers and sellers, allowing traders to quickly identify directional dominance.

Footprint Imbalance Detection

Highlights bars where aggressive buyers or sellers demonstrate meaningful control based on configurable Delta and volume thresholds.

Dynamic Support & Resistance Zones

Automatically creates bullish and bearish imbalance zones that extend forward in time.

Mitigation Tracking

Zones remain active until price revisits them. Mitigated zones can optionally fade or be removed entirely to maintain a clean chart.

Trend Alignment Filter

Optionally validates footprint signals using candle direction and market structure.

Wick Rejection Filter

Helps identify potential absorption and rejection behavior by requiring meaningful wick participation before generating signals.

Real-Time Footprint Dashboard

Displays:

• Delta
• Buy Volume
• Sell Volume
• Buy %
• Sell %
• Total Volume
• Market Bias

Designed For
Futures Traders
Footprint Traders
Order Flow Analysis
Liquidity-Based Trading
Support & Resistance Identification
Market Participation Analysis

Requirements

This indicator utilizes TradingView's native Volume Footprint functionality and requires a TradingView subscription tier that supports footprint data access.

At the time of publication, Volume Footprint features are generally available on Premium and higher plans. Availability may vary depending on your subscription level, symbol, exchange, and market data permissions.

If footprint data is unavailable for the selected symbol or account, the indicator may display limited information or no footprint-derived signals.

Recommended Setup

For best results:

TradingView Premium or higher
Volume Footprint chart style
CME Futures symbols (NQ, ES, MNQ, MES, etc.)
Supported footprint-enabled market data

While the indicator can be added to standard candlestick charts, it was designed around TradingView's native footprint engine and is best used in conjunction with Volume Footprint charts for direct validation of Delta, Buy Volume, Sell Volume, and order-flow activity.

Data Source

This indicator uses footprint-derived market participation metrics supplied by TradingView's native footprint engine, including:

Buy Volume
Sell Volume
Delta
Participation Percentages
Footprint-Based Market Bias

This is not an estimated delta or candle-position approximation indicator.

## Source Code

````pine
//@version=6
indicator("SFM Real Footprint Imbalance Zones — Dark UI", overlay=true, max_boxes_count=500, max_labels_count=500)

// Inputs
ticksPerRow        = input.int(25, "Ticks Per Row", minval=1)
vaPercent          = input.int(70, "Value Area %", minval=1, maxval=100)
imbalancePercent   = input.int(300, "Imbalance %", minval=100)

minTotalVolume     = input.float(500, "Minimum Footprint Volume", minval=0)
minDeltaAbs        = input.float(250, "Minimum Absolute Delta", minval=0)
buyControlPercent  = input.float(60, "Buy Control %", minval=50, maxval=100)
sellControlPercent = input.float(60, "Sell Control %", minval=50, maxval=100)

useTrendFilter     = input.bool(true, "Trend Alignment Filter")
useWickFilter      = input.bool(true, "Wick Rejection Filter")
zoneBarsBack       = input.int(1, "Zone Start Bars Back", minval=0, maxval=5)
zoneThicknessTicks = input.int(20, "Zone Thickness In Ticks", minval=1)

fadeMitigated      = input.bool(true, "Fade Mitigated Zones")
deleteInvalidated  = input.bool(false, "Delete Invalidated Zones")
showLabels         = input.bool(true, "Show Signal Labels")
showDashboard      = input.bool(true, "Show Footprint Dashboard")

// Dark theme colors
bullFill       = input.color(color.new(color.rgb(0, 255, 170), 88), "Bull Zone Fill")
bullBorder     = input.color(color.new(color.rgb(0, 255, 170), 15), "Bull Zone Border")
bearFill       = input.color(color.new(color.rgb(255, 70, 100), 88), "Bear Zone Fill")
bearBorder     = input.color(color.new(color.rgb(255, 70, 100), 15), "Bear Zone Border")
mitigatedFill  = input.color(color.new(color.rgb(115, 125, 145), 92), "Mitigated Fill")
mitigatedLine  = input.color(color.new(color.rgb(115, 125, 145), 55), "Mitigated Border")

// Footprint
footprint fp = request.footprint(ticksPerRow, vaPercent, imbalancePercent)

hasFp = not na(fp)

buyVol  = hasFp ? footprint.buy_volume(fp) : na
sellVol = hasFp ? footprint.sell_volume(fp) : na
delta   = hasFp ? footprint.delta(fp) : na

totalVol = hasFp ? buyVol + sellVol : na
buyPct   = hasFp and totalVol > 0 ? buyVol / totalVol * 100 : na
sellPct  = hasFp and totalVol > 0 ? sellVol / totalVol * 100 : na

// Candle context
isBullCandle = close > open
isBearCandle = close < open

bodyHigh = math.max(open, close)
bodyLow  = math.min(open, close)

upperWick = high - bodyHigh
lowerWick = bodyLow - low
bodySize  = math.max(math.abs(close - open), syminfo.mintick)

bullWickReject = lowerWick > bodySize
bearWickReject = upperWick > bodySize

trendBullOk = not useTrendFilter or isBullCandle
trendBearOk = not useTrendFilter or isBearCandle

wickBullOk = not useWickFilter or bullWickReject
wickBearOk = not useWickFilter or bearWickReject

// Signal logic
validVolume = hasFp and totalVol >= minTotalVolume
validDelta  = hasFp and math.abs(delta) >= minDeltaAbs

bullImbalance = validVolume and validDelta and buyPct >= buyControlPercent and delta > 0 and trendBullOk and wickBullOk
bearImbalance = validVolume and validDelta and sellPct >= sellControlPercent and delta < 0 and trendBearOk and wickBearOk

// Storage
var box[] bullZones = array.new_box()
var bool[] bullMitigated = array.new_bool()

var box[] bearZones = array.new_box()
var bool[] bearMitigated = array.new_bool()

zoneSize = syminfo.mintick * zoneThicknessTicks

// Bull zone
if bullImbalance
    bottom = low
    top = low + zoneSize

    z = box.new(
         left=bar_index - zoneBarsBack,
         top=top,
         right=bar_index,
         bottom=bottom,
         bgcolor=bullFill,
         border_color=bullBorder,
         border_width=1,
         extend=extend.right
    )

    array.push(bullZones, z)
    array.push(bullMitigated, false)

    if showLabels
        label.new(
             bar_index,
             low,
             "BUY FP\nΔ " + str.tostring(delta, "#") + "\n" + str.tostring(buyPct, "#.0") + "%",
             style=label.style_label_up,
             color=color.new(color.rgb(0, 255, 170), 12),
             textcolor=color.rgb(5, 15, 20),
             size=size.tiny
        )

// Bear zone
if bearImbalance
    top = high
    bottom = high - zoneSize

    z = box.new(
         left=bar_index - zoneBarsBack,
         top=top,
         right=bar_index,
         bottom=bottom,
         bgcolor=bearFill,
         border_color=bearBorder,
         border_width=1,
         extend=extend.right
    )

    array.push(bearZones, z)
    array.push(bearMitigated, false)

    if showLabels
        label.new(
             bar_index,
             high,
             "SELL FP\nΔ " + str.tostring(delta, "#") + "\n" + str.tostring(sellPct, "#.0") + "%",
             style=label.style_label_down,
             color=color.new(color.rgb(255, 70, 100), 10),
             textcolor=color.white,
             size=size.tiny
        )

// Bull mitigation
bullCount = array.size(bullZones)
if bullCount > 0
    for i = bullCount - 1 to 0
        z = array.get(bullZones, i)
        mitigated = array.get(bullMitigated, i)

        zTop = box.get_top(z)
        zBottom = box.get_bottom(z)

        touched = low <= zTop and high >= zBottom
        invalidated = close < zBottom

        if invalidated and deleteInvalidated
            box.delete(z)
            array.remove(bullZones, i)
            array.remove(bullMitigated, i)
        else if touched and not mitigated
            array.set(bullMitigated, i, true)
            if fadeMitigated
                box.set_bgcolor(z, mitigatedFill)
                box.set_border_color(z, mitigatedLine)

// Bear mitigation
bearCount = array.size(bearZones)
if bearCount > 0
    for i = bearCount - 1 to 0
        z = array.get(bearZones, i)
        mitigated = array.get(bearMitigated, i)

        zTop = box.get_top(z)
        zBottom = box.get_bottom(z)

        touched = high >= zBottom and low <= zTop
        invalidated = close > zTop

        if invalidated and deleteInvalidated
            box.delete(z)
            array.remove(bearZones, i)
            array.remove(bearMitigated, i)
        else if touched and not mitigated
            array.set(bearMitigated, i, true)
            if fadeMitigated
                box.set_bgcolor(z, mitigatedFill)
                box.set_border_color(z, mitigatedLine)

// Dashboard
var table dash = table.new(position.top_right, 2, 6, bgcolor=color.new(color.rgb(10, 14, 22), 15), border_color=color.new(color.white, 85), border_width=1)

if showDashboard and barstate.islast
    biasText = delta > 0 ? "BUY CONTROL" : delta < 0 ? "SELL CONTROL" : "NEUTRAL"
    biasColor = delta > 0 ? color.rgb(0, 255, 170) : delta < 0 ? color.rgb(255, 70, 100) : color.gray

    table.cell(dash, 0, 0, "SFM FOOTPRINT", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, hasFp ? "LIVE" : "NO DATA", text_color=hasFp ? color.rgb(0, 255, 170) : color.rgb(255, 70, 100), text_size=size.small)

    table.cell(dash, 0, 1, "Delta", text_color=color.new(color.white, 20), text_size=size.tiny)
    table.cell(dash, 1, 1, str.tostring(delta, "#"), text_color=biasColor, text_size=size.tiny)

    table.cell(dash, 0, 2, "Buy %", text_color=color.new(color.white, 20), text_size=size.tiny)
    table.cell(dash, 1, 2, str.tostring(buyPct, "#.0") + "%", text_color=color.rgb(0, 255, 170), text_size=size.tiny)

    table.cell(dash, 0, 3, "Sell %", text_color=color.new(color.white, 20), text_size=size.tiny)
    table.cell(dash, 1, 3, str.tostring(sellPct, "#.0") + "%", text_color=color.rgb(255, 70, 100), text_size=size.tiny)

    table.cell(dash, 0, 4, "Volume", text_color=color.new(color.white, 20), text_size=size.tiny)
    table.cell(dash, 1, 4, str.tostring(totalVol, "#"), text_color=color.white, text_size=size.tiny)

    table.cell(dash, 0, 5, "Bias", text_color=color.new(color.white, 20), text_size=size.tiny)
    table.cell(dash, 1, 5, biasText, text_color=biasColor, text_size=size.tiny)

// Data window
plot(delta, "Real Footprint Delta", display=display.data_window)
plot(buyVol, "Real Buy Volume", display=display.data_window)
plot(sellVol, "Real Sell Volume", display=display.data_window)
plot(buyPct, "Buy %", display=display.data_window)
plot(sellPct, "Sell %", display=display.data_window)

alertcondition(bullImbalance, "Bullish Footprint Imbalance", "Bullish real footprint imbalance detected")
alertcondition(bearImbalance, "Bearish Footprint Imbalance", "Bearish real footprint imbalance detected")
````
