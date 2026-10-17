# 3 Bar Reversals by DINKLETON

- url: https://www.tradingview.com/script/CFBoDaZY-3-Bar-Reversals-by-DINKLETON/
- type: indicator
- pine_id: PUB;bd296ddb74fb4d87857541fc80f0382b
- version: 1.0

## Description

Find a valid 3 bar in the market so you know where reversals are. Make sure your entries are valid!

## Source Code

````pine
//@version=6
indicator("1 Minute 3-Bar Reversal Highlight", overlay=true, max_boxes_count=500)

// === INPUTS ===
signalTf = input.timeframe("1", "Signal Timeframe", options=["1"])
showSignal = input.bool(true, "Show 3-Bar Reversal Highlight")

highlightTransparency = input.int(80, "Highlight Transparency", minval=0, maxval=100)
wickRequired = input.bool(true, "Require Wick On Middle Candle")
wickSizePercent = input.float(10.0, "Minimum Middle Wick % Of Candle", step=1.0)

// === 1-MIN DATA ===
o = request.security(syminfo.tickerid, signalTf, open)
h = request.security(syminfo.tickerid, signalTf, high)
l = request.security(syminfo.tickerid, signalTf, low)
c = request.security(syminfo.tickerid, signalTf, close)

// === CANDLE DIRECTIONS ===
bar1Bullish = c[2] > o[2]
bar2Bullish = c[1] > o[1]
bar3Bearish = c < o

bar1Bearish = c[2] < o[2]
bar2Bearish = c[1] < o[1]
bar3Bullish = c > o

// === MIDDLE CANDLE WICK CHECK ===
bar2Range = h[1] - l[1]

bar2UpperWick = h[1] - math.max(o[1], c[1])
bar2LowerWick = math.min(o[1], c[1]) - l[1]

bar2HasUpperWick = bar2Range > 0 and bar2UpperWick >= bar2Range * (wickSizePercent / 100)
bar2HasLowerWick = bar2Range > 0 and bar2LowerWick >= bar2Range * (wickSizePercent / 100)

// === PREVIOUS TWO BODY LEVELS ===
prevTwoBodyHigh = math.max(math.max(o[2], c[2]), math.max(o[1], c[1]))
prevTwoBodyLow = math.min(math.min(o[2], c[2]), math.min(o[1], c[1]))

// === 3-BAR REVERSAL LOGIC ===
// Bullish: red, red with lower wick, then green engulf above previous 2 bodies
bullishReversal = bar1Bearish and bar2Bearish and bar3Bullish and c > prevTwoBodyHigh and (not wickRequired or bar2HasLowerWick)

// Bearish: green, green with upper wick, then red engulf below previous 2 bodies
bearishReversal = bar1Bullish and bar2Bullish and bar3Bearish and c < prevTwoBodyLow and (not wickRequired or bar2HasUpperWick)

// Any reversal
threeBarReversal = bullishReversal or bearishReversal

// === 3-BAR PATTERN RANGE ===
patternHigh = math.max(h[2], math.max(h[1], h))
patternLow = math.min(l[2], math.min(l[1], l))

// === HIGHLIGHT FULL 3-BAR AREA ===
if showSignal and threeBarReversal
    box.new(left=bar_index[2], top=patternHigh, right=bar_index + 1, bottom=patternLow, bgcolor=color.new(color.rgb(44, 206, 255), highlightTransparency), border_color=color.rgb(44, 206, 255))

// === ALERT ===
alertcondition(threeBarReversal, title="3-Bar Reversal", message="1-minute 3-bar reversal detected")
````
