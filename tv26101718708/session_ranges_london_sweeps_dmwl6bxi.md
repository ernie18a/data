# Session Ranges & London Sweeps

- url: https://www.tradingview.com/script/dmWl6bxi-Session-Ranges-London-Sweeps/
- type: indicator
- pine_id: PUB;fa9147a21679481e9250cb0dcaf0209a
- version: 1.0

## Description

free sessions indicator which marks off trading sessions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Session Ranges & London Sweeps", overlay = true, max_boxes_count = 500, max_labels_count = 500)

// --- Settings ---
asiaSession   = input.session("0000-0600", "Asia Session", group = "Sessions")
londonSession = input.session("0800-1200", "London Session", group = "Sessions")
nySession     = input.session("1300-1700", "New York Session", group = "Sessions")
timezone      = input.string("UTC", "Timezone", group = "Sessions")

tightThreshold = input.float(20.0, "Tight Asia Range Threshold (Pips)", minval = 0, tooltip = "If Asia range is less than this, it is marked as 'Tight'", group = "Logic")
emaLen         = input.int(50, "Trend EMA Length", minval = 1, group = "Logic")
rsiLen         = input.int(14, "Momentum RSI Length", minval = 1, group = "Logic")

dashPos     = input.string("top_right", "Dashboard Position", options = ["top_right", "bottom_right", "top_left", "bottom_left"], group = "Style")
asiaColor   = input.color(color.new(#5b9cf6, 85), "Asia Color", group = "Style")

londonColor = input.color(color.new(#089981, 85), "London Color", group = "Style")
nyColor     = input.color(color.new(#f23645, 85), "New York Color", group = "Style")

// --- Constants ---
PIPS = syminfo.mintick * 10

// --- Session Logic ---
is_in_session(sess, tz) =>
    not na(time(timeframe.period, sess, tz))

isAsia   = is_in_session(asiaSession, timezone)
isLondon = is_in_session(londonSession, timezone)
isNY     = is_in_session(nySession, timezone)

// --- Range Tracking ---
var float asiaHigh = na
var float asiaLow  = na
var int asiaStart  = na
var box asiaBox    = na

var float lonHigh = na
var float lonLow  = na
var int lonStart  = na
var box lonBox    = na

var float nyHigh = na
var float nyLow  = na
var int nyStart  = na
var box nyBox    = na

// Asia Logic
if isAsia and not isAsia[1]
    asiaHigh  := high
    asiaLow   := low
    asiaStart := bar_index
    asiaBox   := box.new(bar_index, high, bar_index, low, bgcolor = asiaColor, border_color = color.new(asiaColor, 50))
else if isAsia
    asiaHigh := math.max(high, asiaHigh)
    asiaLow  := math.min(low, asiaLow)
    box.set_top(asiaBox, asiaHigh)
    box.set_bottom(asiaBox, asiaLow)
    box.set_right(asiaBox, bar_index)

// London Logic
if isLondon and not isLondon[1]
    lonHigh  := high
    lonLow   := low
    lonStart := bar_index
    lonBox   := box.new(bar_index, high, bar_index, low, bgcolor = londonColor, border_color = color.new(londonColor, 50))
else if isLondon
    lonHigh := math.max(high, lonHigh)
    lonLow  := math.min(low, lonLow)
    box.set_top(lonBox, lonHigh)
    box.set_bottom(lonBox, lonLow)
    box.set_right(lonBox, bar_index)

// NY Logic
if isNY and not isNY[1]
    nyHigh  := high
    nyLow   := low
    nyStart := bar_index
    nyBox   := box.new(bar_index, high, bar_index, low, bgcolor = nyColor, border_color = color.new(nyColor, 50))
else if isNY
    nyHigh := math.max(high, nyHigh)
    nyLow  := math.min(low, nyLow)
    box.set_top(nyBox, nyHigh)
    box.set_bottom(nyBox, nyLow)
    box.set_right(nyBox, bar_index)

// --- Tight Asia Range & London Sweeps ---
var bool asiaTight = false
var bool sweptHigh = false
var bool sweptLow  = false

// Reset sweep flags when Asia ends / London starts
if isLondon and not isLondon[1]
    sweptHigh := false
    sweptLow  := false
    asiaRangePips = (asiaHigh - asiaLow) / PIPS
    asiaTight := asiaRangePips <= tightThreshold
    
    if asiaTight
        label.new(math.round(math.avg(asiaStart, bar_index[1])), asiaHigh, "TIGHT", color = #00000000, textcolor = chart.fg_color, style = label.style_label_down, size = size.small)

// Detect Sweeps during London
sweepHighSignal = isLondon and not sweptHigh and high > asiaHigh
sweepLowSignal  = isLondon and not sweptLow  and low < asiaLow

if sweepHighSignal
    sweptHigh := true
    label.new(bar_index, high, "▲ Sweep High", color = #00000000, textcolor = #089981, style = label.style_label_down, size = size.small)

if sweepLowSignal
    sweptLow := true
    label.new(bar_index, low, "▼ Sweep Low", color = #00000000, textcolor = #f23645, style = label.style_label_up, size = size.small)
// --- Sentiment Calculations ---
emaValue = ta.ema(close, emaLen)
rsiValue = ta.rsi(close, rsiLen)

trendBias    = close > emaValue ? "Bullish" : "Bearish"
trendColor   = close > emaValue ? #089981 : #f23645
momentum     = rsiValue > 60 ? "Strong" : rsiValue < 40 ? "Weak" : "Neutral"
momColor     = rsiValue > 60 ? #089981 : rsiValue < 40 ? #f23645 : #787b86

// Bias based on last sweep: Sweep High = Bearish Bias (Liquidity taken), Sweep Low = Bullish Bias
string sessionBias = "Neutral"
color biasColor    = #787b86

if sweptHigh and not sweptLow
    sessionBias := "Bearish"
    biasColor   := #f23645
else if sweptLow and not sweptHigh
    sessionBias := "Bullish"
    biasColor   := #089981
else if sweptHigh and sweptLow
    sessionBias := "Both Swept"
    biasColor   := #ff9800

// --- Dashboard ---
var table dash = table.new(dashPos == "top_right" ? position.top_right : dashPos == "bottom_right" ? position.bottom_right : dashPos == "top_left" ? position.top_left : position.bottom_left, 2, 5, border_width = 1, border_color = #787b86)

if barstate.islast
    // Header
    table.cell(dash, 0, 0, "Sentiment Dashboard", bgcolor = #1e222d, text_color = chart.fg_color, text_size = size.small)
    table.merge_cells(dash, 0, 0, 1, 0)
    
    // Trend
    table.cell(dash, 0, 1, "Trend (EMA)", text_color = chart.fg_color, text_halign = text.align_left, text_size = size.small)
    table.cell(dash, 1, 1, trendBias, text_color = trendColor, text_size = size.small)
    
    // Momentum
    table.cell(dash, 0, 2, "Momentum (RSI)", text_color = chart.fg_color, text_halign = text.align_left, text_size = size.small)
    table.cell(dash, 1, 2, momentum, text_color = momColor, text_size = size.small)
    
    // Session Bias
    table.cell(dash, 0, 3, "London Bias", text_color = chart.fg_color, text_halign = text.align_left, text_size = size.small)
    table.cell(dash, 1, 3, sessionBias, text_color = biasColor, text_size = size.small)

    // Asia Status
    table.cell(dash, 0, 4, "Asia Range", text_color = chart.fg_color, text_halign = text.align_left, text_size = size.small)
    table.cell(dash, 1, 4, asiaTight ? "Tight" : "Normal", text_color = asiaTight ? #ff9800 : #787b86, text_size = size.small)

// --- Visuals ---
plotshape(sweepHighSignal, "London Sweep High", shape.triangleup, location.abovebar, color.new(#089981, 0), size = size.tiny)
plotshape(sweepLowSignal, "London Sweep Low", shape.triangledown, location.belowbar, color.new(#f23645, 0), size = size.tiny)

plotshape(sweepHighSignal, "London Sweep High", shape.triangleup, location.abovebar, color.new(#089981, 0), size = size.tiny)
plotshape(sweepLowSignal, "London Sweep Low", shape.triangledown, location.belowbar, color.new(#f23645, 0), size = size.tiny)
````
