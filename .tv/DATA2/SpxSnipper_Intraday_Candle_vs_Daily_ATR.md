<!-- tradingview-pine-id: PUB;b693fba7518a4d71b1978cb631ae6fb6 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# SpxSnipper - Intraday Candle vs Daily ATR

Source: https://www.tradingview.com/script/gy3ofr3U-SpxSnipper-Intraday-Candle-vs-Daily-ATR/

## Description

Intraday Candle vs Daily ATR

This indicator is designed to identify significant intraday candles by comparing each intraday candle’s size against the Daily ATR.

It is useful for traders who want to quickly spot unusually large 5-minute, 15-minute, or 30-minute candles relative to the stock/index’s normal daily volatility.

How it works:
The indicator pulls Daily ATR data from the daily timeframe and applies it to the intraday chart. Each intraday candle is then measured as a percentage of the Daily ATR.

For example:
If the Daily ATR is 100 points and the selected threshold is 25%, the indicator will mark any intraday candle with a range or body greater than 25 points.

Main features:
- Uses Daily ATR on intraday charts
- Custom ATR length
- Custom percentage threshold
- Option to measure full candle range or real body
- Option to use previous completed Daily ATR or current developing Daily ATR
- Bullish and bearish candle signals
- Optional candle coloring
- Optional percentage labels
- Alert conditions included

Measurement modes:
- Full Candle Range: high minus low
- Real Body: absolute difference between close and open

Suggested use:
This tool can help identify important impulse candles, volatility expansion, breakout candles, rejection candles, and strong intraday moves.

It can be used on SPX, SPY, QQQ, individual stocks, futures, or other liquid instruments.

For 15-minute charts, a threshold around 20%–25% of Daily ATR can highlight only the more important candles. Lower values will generate more signals, while higher values will show only the strongest volatility candles.

This indicator is intended for discretionary trading analysis and should be used together with price action, trend, support/resistance, VWAP, volume, and proper risk management.

Not financial advice.

---

## Source Code

````pine
//@version=6
indicator("SpxSnipper - Intraday Candle vs Daily ATR", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────
atrLength = input.int(
     14,
     "Daily ATR Length",
     minval=1
)

atrMode = input.string(
     "Previous Completed Daily ATR",
     "Daily ATR Mode",
     options=["Previous Completed Daily ATR", "Current Developing Daily ATR"]
)

thresholdPct = input.float(
     25.0,
     "Minimum Candle Size - % of Daily ATR",
     minval=0.1,
     maxval=100.0,
     step=0.5
)

measureMode = input.string(
     "Full Candle Range",
     "Intraday Candle Measurement",
     options=["Full Candle Range", "Real Body"]
)

requireClosedBar = input.bool(
     true,
     "Signal Only After Candle Close"
)

showSignals = input.bool(true, "Show Signals")
showPctLabels = input.bool(false, "Show % ATR Label")
colorSignalCandles = input.bool(true, "Color Important Candles")

bullColor = input.color(color.new(color.lime, 0), "Bullish Signal Color")
bearColor = input.color(color.new(color.red, 0), "Bearish Signal Color")
neutralColor = input.color(color.new(color.orange, 0), "Neutral Signal Color")

labelSizeInput = input.string(
     "Small",
     "Label Size",
     options=["Tiny", "Small", "Normal"]
)

f_labelSize(string s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal

labelSize = f_labelSize(labelSizeInput)

// ─────────────────────────────────────────────
// Daily ATR from Daily timeframe
// ─────────────────────────────────────────────
// Previous completed daily ATR = stable / non-developing
previousDailyATR = request.security(
     syminfo.tickerid,
     "D",
     ta.atr(atrLength)[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on
)

// Current developing daily ATR = updates intraday
currentDailyATR = request.security(
     syminfo.tickerid,
     "D",
     ta.atr(atrLength),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
)

dailyATR =
     atrMode == "Previous Completed Daily ATR" ?
     previousDailyATR :
     currentDailyATR

// ─────────────────────────────────────────────
// Intraday candle size
// ─────────────────────────────────────────────
realBody = math.abs(close - open)
fullRange = high - low

candleSize =
     measureMode == "Real Body" ?
     realBody :
     fullRange

requiredSize = dailyATR * thresholdPct / 100.0

candleAtrPct =
     dailyATR > 0 ?
     candleSize / dailyATR * 100.0 :
     na

confirmedOk =
     requireClosedBar ?
     barstate.isconfirmed :
     true

importantCandle =
     confirmedOk and
     not na(candleAtrPct) and
     candleAtrPct >= thresholdPct

bullImportant = importantCandle and close > open
bearImportant = importantCandle and close < open
neutralImportant = importantCandle and close == open

// ─────────────────────────────────────────────
// Plot signals
// ─────────────────────────────────────────────
plotshape(
     showSignals and bullImportant,
     title="Bullish Important Candle",
     style=shape.triangleup,
     location=location.belowbar,
     color=bullColor,
     size=size.small,
     text="ATR"
)

plotshape(
     showSignals and bearImportant,
     title="Bearish Important Candle",
     style=shape.triangledown,
     location=location.abovebar,
     color=bearColor,
     size=size.small,
     text="ATR"
)

plotshape(
     showSignals and neutralImportant,
     title="Neutral Important Candle",
     style=shape.circle,
     location=location.abovebar,
     color=neutralColor,
     size=size.tiny,
     text="ATR"
)

// ─────────────────────────────────────────────
// Candle coloring
// ─────────────────────────────────────────────
barcolor(
     colorSignalCandles and bullImportant ? color.new(bullColor, 0) :
     colorSignalCandles and bearImportant ? color.new(bearColor, 0) :
     colorSignalCandles and neutralImportant ? color.new(neutralColor, 0) :
     na
)

// ─────────────────────────────────────────────
// Optional % label
// ─────────────────────────────────────────────
if showPctLabels and importantCandle
    label.new(
         x=bar_index,
         y=bullImportant ? low : high,
         text=str.tostring(candleAtrPct, "#.0") + "% ATR",
         xloc=xloc.bar_index,
         style=bullImportant ? label.style_label_up : label.style_label_down,
         color=bullImportant ? bullColor : bearImportant ? bearColor : neutralColor,
         textcolor=color.white,
         size=labelSize
    )

// ─────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────
alertcondition(
     bullImportant,
     title="Bullish Important Candle vs Daily ATR",
     message="Bullish intraday candle is larger than selected % of Daily ATR."
)

alertcondition(
     bearImportant,
     title="Bearish Important Candle vs Daily ATR",
     message="Bearish intraday candle is larger than selected % of Daily ATR."
)

alertcondition(
     importantCandle,
     title="Any Important Candle vs Daily ATR",
     message="Intraday candle is larger than selected % of Daily ATR."
)
````
