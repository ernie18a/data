# CBTrades MSS Shift

- url: https://www.tradingview.com/script/dcLlhA0A-CBTrades-MSS-Shift/
- type: indicator
- pine_id: PUB;61f4521d828747c48639f61a19dbfab6
- version: 1.0

## Description

Shows and marks our HH and HL when bullish and LH, LL when bearish. Red line marks a MSS shift to turn bearish and green lines marks a MSS to turn bullish. Can be used on multiple time frames to help determine possible bias. Trades can be taken with a shift, PD Array and OTE.

## Source Code

````pine
//@version=6
indicator("CBTrades MSS Shift", overlay=true, max_labels_count=500, max_lines_count=500)

swingTF   = input.timeframe("15", "Swing Timeframe", options=["5", "15", "60", "240"])
leftBars  = input.int(1, "Candles Left", minval=1)
rightBars = input.int(1, "Candles Right", minval=1)

ph = request.security(syminfo.tickerid, swingTF, ta.pivothigh(high, leftBars, rightBars))
pl = request.security(syminfo.tickerid, swingTF, ta.pivotlow(low, leftBars, rightBars))

newHigh = not na(ph)
newLow  = not na(pl)

var int trend = 0

var float lastHH = na
var float lastHL = na
var float lastLH = na
var float lastLL = na

var int lastHHBar = na
var int lastHLBar = na
var int lastLHBar = na
var int lastLLBar = na

var float candidateHL = na
var int candidateHLBar = na

var float candidateLH = na
var int candidateLHBar = na

var float startHigh = na
var int startHighBar = na
var float startLow = na
var int startLowBar = na

var bool bearishMSS = false
var bool bullishMSS = false

bearishMSS := false
bullishMSS := false

// Neutral start
if trend == 0
    if newHigh
        startHigh := ph
        startHighBar := bar_index - rightBars

    if newLow
        startLow := pl
        startLowBar := bar_index - rightBars

    if not na(startHigh) and close > startHigh
        trend := 1
        lastHH := startHigh
        lastHHBar := startHighBar
        label.new(lastHHBar, lastHH, "HH", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.tiny)

    if not na(startLow) and close < startLow
        trend := -1
        lastLL := startLow
        lastLLBar := startLowBar
        label.new(lastLLBar, lastLL, "LL", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.tiny)

// Bullish structure
if trend == 1
    if newLow
        pivotBar = bar_index - rightBars
        if na(candidateHL) or pl < candidateHL
            candidateHL := pl
            candidateHLBar := pivotBar

    if not na(candidateHL) and close < candidateHL
        bearishMSS := true
        line.new(candidateHLBar, candidateHL, bar_index, candidateHL, color=color.red, width=2)

        label.new(candidateHLBar, candidateHL, "HL", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.tiny)

        trend := -1
        lastLL := low
        lastLLBar := bar_index
        lastLH := lastHH
        lastLHBar := lastHHBar

        lastHH := na
        lastHL := na
        candidateHL := na
        candidateHLBar := na

    if newHigh and not na(lastHH) and ph > lastHH and not na(candidateHL)
        lastHL := candidateHL
        lastHLBar := candidateHLBar

        label.new(lastHLBar, lastHL, "HL", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.tiny)

        lastHH := ph
        lastHHBar := bar_index - rightBars

        label.new(lastHHBar, lastHH, "HH", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.tiny)

        candidateHL := na
        candidateHLBar := na

// Bearish structure
if trend == -1
    if newHigh
        pivotBar = bar_index - rightBars
        if na(candidateLH) or ph > candidateLH
            candidateLH := ph
            candidateLHBar := pivotBar

    if not na(candidateLH) and close > candidateLH
        bullishMSS := true
        line.new(candidateLHBar, candidateLH, bar_index, candidateLH, color=color.lime, width=2)

        label.new(candidateLHBar, candidateLH, "LH", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.tiny)

        trend := 1
        lastHH := high
        lastHHBar := bar_index
        lastHL := lastLL
        lastHLBar := lastLLBar

        lastLH := na
        lastLL := na
        candidateLH := na
        candidateLHBar := na

    if newLow and not na(lastLL) and pl < lastLL and not na(candidateLH)
        lastLH := candidateLH
        lastLHBar := candidateLHBar

        label.new(lastLHBar, lastLH, "LH", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.tiny)

        lastLL := pl
        lastLLBar := bar_index - rightBars

        label.new(lastLLBar, lastLL, "LL", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.tiny)

        candidateLH := na
        candidateLHBar := na

alertcondition(bearishMSS, title="Bearish MSS", message="Price broke below the last HL")
alertcondition(bullishMSS, title="Bullish MSS", message="Price broke above the last LH")
````
