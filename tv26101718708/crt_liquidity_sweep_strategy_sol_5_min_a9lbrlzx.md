# CRT Liquidity Sweep Strategy SOL 5 MIN

- url: https://www.tradingview.com/script/a9lBrLZx-CRT-Liquidity-Sweep-Strategy-SOL-5-MIN/
- type: strategy
- pine_id: PUB;d8bd7547929648a9b835d7d6e5879d7c
- version: 1.0

## Description

CRT Liquidity Sweep Strategy uses Candle Range Theory to identify sweeps and reclaim entries. Its default settings are intended for SOL on a standard 5-minute candlestick chart.

HOW IT WORKS

The strategy builds UTC-aligned 4-hour candles from chart bars. A qualifying candle establishes the active high and low range. Candle filters exclude doji, marubozu, and candles with excessive wick imbalance.

A long setup requires price to sweep below the range and close back inside it on a bullish candle. A short setup requires a sweep above the range and a bearish close back inside. The reclaim must occur on the sweep candle or the following candle.

A 50-bar linear regression filter permits longs with a positive slope and shorts with a negative slope. Entries are accepted only while the strategy is flat.

RISK AND DEFAULT SETTINGS

Stops are placed beyond the full sweep extreme, with a target of twice the calculated risk. ATR stop buffering and oversized-sweep filtering are disabled by default.

The strategy uses 10% of equity as order size, $10,000 initial capital, 0.04% commission, and one tick of slippage. Order size is not the percentage of equity risked at the stop.

Range boxes, TP/SL boxes, entry labels, and the selected trend line are displayed. Sweep triangle markers have been removed.

USAGE AND LIMITATIONS

Select SOL and a 5-minute chart manually. Inputs remain adjustable. Historical results depend on the exchange feed, available history, costs, and execution assumptions. Strategy orders normally fill on the next available tick, so actual fill prices can differ from the signal close used to calculate targets and stops.

This is a research and backtesting tool. Default settings do not establish profitability or guarantee future performance.

## Source Code

````pine
//@version=6
strategy("CRT Liquidity Sweep Strategy", shorttitle="CRT Liq", overlay=true,
     default_qty_type=strategy.percent_of_equity, default_qty_value=10,
     initial_capital=10000, currency=currency.USD,
     commission_type=strategy.commission.percent, commission_value=0.04,
     slippage=1, max_boxes_count=500, max_labels_count=500)

// Run this on the lower timeframe selected on the chart. The selectable HTF range is built natively from this
// chart's own bars (accumulate-then-lock on a fixed-minute bucket), NOT via
// request.security -- a request.security(240) version produced zero trades
// over a year of OANDA XAUUSD "Deep" backtesting despite the sweep logic
// itself firing regularly in an offline replay (97 trades / ~3 months on
// real data). Deep Backtesting's extended history isn't reliably available
// to secondary request.security() timeframes on this feed, so the HTF range
// silently never got set. Building the range natively removes that
// dependency entirely.
//
// 1. Accumulate this chart's bars into rangeMinutes-wide buckets aligned to
//    UTC. When a bucket closes, check it's an ordinary candle (not
//    doji/hammer/marubozu) and mark its high/low as the range. The range
//    stays active until the next qualifying bucket replaces it.
// 2. Wait for a liquidity sweep: price wicks beyond the range (a fake
//    breakout that hunts stops), then reclaims back inside on a
//    bullish/bearish candle -- either in one candle (hammer) or two
//    (breakout candle + opposite-color reclaim candle).
// 3. Optionally require a reclaim inside the full range within a fixed
//    number of bars from the first sweep. Track the full sweep extreme.
//    Reject oversized sequences with the optional previous-bar ATR filter.
//    Enter on the reclaim candle, stop beyond the sweep plus optional ATR
//    buffer, fixed R:R target. ATR is frozen when the setup triggers.
// Note: this is the same range-sweep-reversal pattern family as the
// project's already-closed CRT work (prior-day-range version, rejected on
// both BTC/SOL Python tests and an OANDA XAU TV test, PF<1.25 throughout).
// This is a different parameterization (HTF-candle range instead of prior
// daily range, hammer/engulfing confirmation, 1:2 R:R) -- built on request
// to test it on its own terms, not because the family has a proven edge.

gRange = "Range (HTF)"
rangeTimeframe = input.timeframe("240", "Range timeframe (UTC-aligned)",
     options=["15", "30", "60", "120", "240", "360", "720", "1D"], group=gRange,
     tooltip="Higher-timeframe range built from chart candles. Entries and ATR use the chart timeframe. Choose a range larger than the chart timeframe and an exact multiple of it.")
rangeSeconds = timeframe.in_seconds(rangeTimeframe)
chartSeconds = timeframe.in_seconds()
if barstate.isfirst and (not chart.is_standard or not timeframe.isintraday or na(chartSeconds) or rangeSeconds <= chartSeconds or rangeSeconds % chartSeconds != 0)
    runtime.error("Use a standard intraday chart. Range timeframe must be larger than, and an exact multiple of, the chart timeframe.")
rangeMinutes = int(rangeSeconds / 60)
requireNormalCandle = input.bool(true, "Require plain candle (exclude doji/hammer/marubozu)", group=gRange)
maxBodyPct = input.float(80.0, "Max body % of range (marubozu filter)", minval=50.0, maxval=100.0, group=gRange)
minBodyPct = input.float(15.0, "Min body % of range (doji filter)", minval=0.0, maxval=50.0, group=gRange)
maxWickImbalance = input.float(2.5, "Max wick imbalance (hammer filter)", minval=1.0, group=gRange)

gEntry = "Sweep and Entry"
timeoutBars = input.int(150, "Legacy setup timeout (bars)", minval=5, group=gEntry)
requireInsideRange = input.bool(true, "Require reclaim close inside full range", group=gEntry)
useQuickReclaim = input.bool(true, "Use short reclaim window", group=gEntry)
reclaimBars = input.int(1, "Bars allowed after first sweep", minval=0, maxval=20, group=gEntry,
     tooltip="0 = same candle only. 1 = sweep candle or next candle. Repeated sweeps do not extend the deadline.")
useSweepExtreme = input.bool(true, "Stop beyond full sweep extreme", group=gEntry)
allowLong = input.bool(true, "Allow longs", group=gEntry)
allowShort = input.bool(true, "Allow shorts", group=gEntry)

gTrend = "Entry Trend Filter"
trendMethod = input.string("Linear Regression", "Trend filter method", options=["Off", "EMA", "Linear Regression"], group=gTrend,
     tooltip="Uses chart candles. Off preserves existing entries. EMA: longs above EMA, shorts below EMA. Linear Regression: longs with positive slope, shorts with negative slope.")
trendEmaLength = input.int(200, "EMA length (chart bars)", minval=2, group=gTrend)
trendRegressionLength = input.int(50, "Linear regression length (chart bars)", minval=2, group=gTrend)
minRegressionSlopePct = input.float(0.0, "Minimum regression slope (% per bar)", minval=0.0, step=0.001, group=gTrend,
     tooltip="Linear Regression only. Absolute minimum slope, expressed as percent of the current close per chart bar. Zero requires only direction; larger values exclude flatter trends.")
showTrendLine = input.bool(true, "Show selected trend line", group=gTrend)

// Calculate both methods every bar, including when the filter is Off.
// The two regression offsets refer to the same fitted window, so their
// difference is the fitted slope, not the change between rolling windows.
trendEma = ta.ema(close, trendEmaLength)
trendRegression = ta.linreg(close, trendRegressionLength, 0)
trendRegressionOffset = ta.linreg(close, trendRegressionLength, 1)
regressionSlope = trendRegression - trendRegressionOffset
regressionSlopePct = math.abs(close) > 0 ? regressionSlope / math.abs(close) * 100.0 : na
emaTrendReady = bar_index >= trendEmaLength - 1 and not na(trendEma)
regressionTrendReady = not na(regressionSlopePct)
longTrendOk = switch trendMethod
    "EMA" => emaTrendReady and close > trendEma
    "Linear Regression" => regressionTrendReady and regressionSlopePct > minRegressionSlopePct
    => true
shortTrendOk = switch trendMethod
    "EMA" => emaTrendReady and close < trendEma
    "Linear Regression" => regressionTrendReady and regressionSlopePct < -minRegressionSlopePct
    => true

gRisk = "Risk"
rr = input.float(2.0, "Risk : Reward", minval=0.5, step=0.25, group=gRisk)
stopBufferTicks = input.int(0, "Stop buffer (ticks)", minval=0, group=gRisk)
rrProjectionBars = input.int(35, "RR box width (bars)", minval=5, maxval=200, group=gRisk)

gAtr = "ATR"
useAtrBuffer = input.bool(false, "Use ATR stop buffer", group=gAtr,
     tooltip="Adds ATR x multiplier beyond the reclaim wick, in addition to the tick buffer. Disable to compare the original strategy.")
atrLength = input.int(14, "ATR length (chart timeframe)", minval=1, group=gAtr)
atrBufferMultiplier = input.float(0.2, "ATR stop buffer multiplier", minval=0.0, step=0.1, group=gAtr)

useAtrSweepFilter = input.bool(false, "Filter oversized sweep candles", group=gAtr)
maxSweepAtr = input.float(2.0, "Maximum sweep candle range / ATR", minval=0.1, step=0.1, group=gAtr,
     tooltip="Rejects a setup if any candle in its sweep/reclaim sequence exceeds this multiple of the previous bar's ATR. Uses high minus low.")

// Evaluate every bar; use the signal bar's ATR for fixed SL/TP orders.
// Entries are accepted only while flat so later signals cannot overwrite
// an existing trade's bracket or reverse the position.
atrValue = ta.atr(atrLength)
atrReady = (not useAtrBuffer or not na(atrValue)) and (not useAtrSweepFilter or (not na(atrValue[1]) and atrValue[1] > 0))
sweepCandleOk = not useAtrSweepFilter or (not na(atrValue[1]) and atrValue[1] > 0 and high - low <= atrValue[1] * maxSweepAtr)
atrStopBuffer = useAtrBuffer ? atrValue * atrBufferMultiplier : 0.0
stopBuffer = stopBufferTicks * syminfo.mintick + atrStopBuffer

gVisual = "Visuals"
showRangeBox = input.bool(true, "Show range box", group=gVisual)
showRrBox = input.bool(true, "Show TP/SL boxes", group=gVisual)
showSignals = input.bool(true, "Show labels", group=gVisual)

bucketMs = rangeMinutes * 60 * 1000
bucketId = int(math.floor(time / bucketMs))

var int   curBucket = na
var float curO = na
var float curH = na
var float curL = na
var float curC = na

var float rangeHigh = na
var float rangeLow = na
var box   rangeBox = na
var string state = "WATCHING"
var bool  sweptBelow = false
var bool  sweptAbove = false
var int   breakoutBar = na
var int   belowSweepBar = na
var int   aboveSweepBar = na
var float sweepLow = na
var float sweepHigh = na
var bool belowCandleOk = true
var bool aboveCandleOk = true
var int   rangesFormedCount = 0

newBucket = na(curBucket) or bucketId != curBucket

if newBucket
    if not na(curBucket)
        htBody = math.abs(curC - curO)
        htRange = curH - curL
        htUpperWick = curH - math.max(curO, curC)
        htLowerWick = math.min(curO, curC) - curL
        htBodyPct = htRange > 0 ? htBody / htRange * 100.0 : 0.0

        isDoji = htBodyPct < minBodyPct
        isMarubozu = htBodyPct > maxBodyPct
        wickRatio = htUpperWick > htLowerWick ?
             (htLowerWick > 0 ? htUpperWick / htLowerWick : 1000.0) :
             (htUpperWick > 0 ? htLowerWick / htUpperWick : 1000.0)
        isHammerType = wickRatio > maxWickImbalance

        htCandleOk = not requireNormalCandle or (not isDoji and not isMarubozu and not isHammerType)

        if htCandleOk
            rangeHigh := curH
            rangeLow := curL
            state := "WATCHING"
            sweptBelow := false
            sweptAbove := false
            breakoutBar := na
            belowSweepBar := na
            aboveSweepBar := na
            sweepLow := na
            sweepHigh := na
            belowCandleOk := true
            aboveCandleOk := true
            rangesFormedCount += 1
            if showRangeBox
                rangeBox := box.new(bar_index - 1, curH, bar_index - 1, curL,
                     border_color=color.new(color.blue, 15), bgcolor=color.new(color.blue, 88))

    curBucket := bucketId
    curO := open
    curH := high
    curL := low
    curC := close
else
    curH := math.max(curH, high)
    curL := math.min(curL, low)
    curC := close

if showRangeBox and not na(rangeBox)
    box.set_right(rangeBox, bar_index)

bool bullReclaim = false
bool bearReclaim = false

if not na(rangeHigh) and state == "WATCHING"
    // Expire before looking for a reclaim; do not restart on the expiry bar.
    belowExpired = useQuickReclaim and not na(belowSweepBar) and bar_index - belowSweepBar > reclaimBars
    aboveExpired = useQuickReclaim and not na(aboveSweepBar) and bar_index - aboveSweepBar > reclaimBars
    if belowExpired
        sweptBelow := false
        belowSweepBar := na
        sweepLow := na
        belowCandleOk := true
    if aboveExpired
        sweptAbove := false
        aboveSweepBar := na
        sweepHigh := na
        aboveCandleOk := true

    if allowLong and low < rangeLow and not belowExpired
        if not sweptBelow
            belowSweepBar := bar_index
            sweepLow := low
            belowCandleOk := sweepCandleOk
        sweptBelow := true
        breakoutBar := bar_index
    if allowShort and high > rangeHigh and not aboveExpired
        if not sweptAbove
            aboveSweepBar := bar_index
            sweepHigh := high
            aboveCandleOk := sweepCandleOk
        sweptAbove := true
        breakoutBar := bar_index

    if sweptBelow
        sweepLow := math.min(sweepLow, low)
        belowCandleOk := belowCandleOk and sweepCandleOk
    if sweptAbove
        sweepHigh := math.max(sweepHigh, high)
        aboveCandleOk := aboveCandleOk and sweepCandleOk

    insideRange = close > rangeLow and close < rangeHigh
    bullReclaim := sweptBelow and close > rangeLow and close > open and (not requireInsideRange or insideRange) and belowCandleOk and longTrendOk
    bearReclaim := sweptAbove and close < rangeHigh and close < open and (not requireInsideRange or insideRange) and aboveCandleOk and shortTrendOk

    if bullReclaim and atrReady and strategy.position_size == 0
        stopPrice = (useSweepExtreme ? sweepLow : low) - stopBuffer
        risk = close - stopPrice
        if risk > 0.0
            targetPrice = close + risk * rr
            strategy.entry("CRT Long", strategy.long)
            strategy.exit("CRT Long Exit", "CRT Long", stop=stopPrice, limit=targetPrice)
            if showRrBox
                box.new(bar_index, targetPrice, bar_index + rrProjectionBars, close,
                     border_color=color.green, bgcolor=color.new(color.green, 82),
                     text="TP", text_color=color.green, text_size=size.tiny)
                box.new(bar_index, close, bar_index + rrProjectionBars, stopPrice,
                     border_color=color.red, bgcolor=color.new(color.red, 82),
                     text="SL", text_color=color.red, text_size=size.tiny)
            if showSignals
                label.new(bar_index, low, "Long\nSweep+Reclaim", style=label.style_label_up,
                     textcolor=color.white, color=color.new(color.green, 0), size=size.small)
            state := "DONE"
    else if bearReclaim and atrReady and strategy.position_size == 0
        stopPrice = (useSweepExtreme ? sweepHigh : high) + stopBuffer
        risk = stopPrice - close
        if risk > 0.0
            targetPrice = close - risk * rr
            strategy.entry("CRT Short", strategy.short)
            strategy.exit("CRT Short Exit", "CRT Short", stop=stopPrice, limit=targetPrice)
            if showRrBox
                box.new(bar_index, stopPrice, bar_index + rrProjectionBars, close,
                     border_color=color.red, bgcolor=color.new(color.red, 82),
                     text="SL", text_color=color.red, text_size=size.tiny)
                box.new(bar_index, close, bar_index + rrProjectionBars, targetPrice,
                     border_color=color.green, bgcolor=color.new(color.green, 82),
                     text="TP", text_color=color.green, text_size=size.tiny)
            if showSignals
                label.new(bar_index, high, "Short\nSweep+Reclaim", style=label.style_label_down,
                     textcolor=color.white, color=color.new(color.red, 0), size=size.small)
            state := "DONE"
    else if not useQuickReclaim and not na(breakoutBar) and bar_index - breakoutBar > timeoutBars
        state := "DONE"

plot(showTrendLine and trendMethod != "Off" ? (trendMethod == "EMA" ? trendEma : trendRegression) : na,
     "Entry trend line", color=color.orange, linewidth=2)

plot(not na(rangeHigh) ? rangeHigh : na, "Range High", color=color.lime, style=plot.style_linebr, linewidth=1)
plot(not na(rangeLow) ? rangeLow : na, "Range Low", color=color.red, style=plot.style_linebr, linewidth=1)

// Entry-only TradingView alert conditions.
alertcondition(bullReclaim and atrReady and strategy.position_size == 0, title="CRT Liq Buy Signal", message="CRT Liq Buy Signal: {{ticker}} sweep low + reclaim, entry {{close}}")
alertcondition(bearReclaim and atrReady and strategy.position_size == 0, title="CRT Liq Sell Signal", message="CRT Liq Sell Signal: {{ticker}} sweep high + reclaim, entry {{close}}")

var int totalBars = 0
totalBars += 1

var table statusTable = table.new(position.top_right, 2, 15, border_width=1)
if barstate.islast
    bg = color.new(color.gray, 70)
    table.cell(statusTable, 0, 0, "Ranges formed", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 1, 0, str.tostring(rangesFormedCount), text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 0, 1, "Trades", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 1, 1, str.tostring(strategy.closedtrades + strategy.opentrades), text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 0, 2, "Range H / L", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 1, 2, na(rangeHigh) ? "none yet" : str.tostring(rangeHigh, "#.##") + " / " + str.tostring(rangeLow, "#.##"), text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 0, 3, "State", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 1, 3, state, text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 0, 4, "Total bars", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 1, 4, str.tostring(totalBars), text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 0, 5, "bar_index", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 1, 5, str.tostring(bar_index), text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 0, 6, "time / bucketMs", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 1, 6, str.tostring(time) + " / " + str.tostring(bucketMs), text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 0, 7, "bucketId / curBucket", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 1, 7, str.tostring(bucketId) + " / " + str.tostring(curBucket), text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 0, 8, "curO/H/L/C", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 1, 8, str.tostring(curO) + " " + str.tostring(curH) + " " + str.tostring(curL) + " " + str.tostring(curC), text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 0, 9, "ATR (chart TF)", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 1, 9, str.tostring(atrValue, format.mintick), text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 0, 10, "ATR stop buffer", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 1, 10, useAtrBuffer ? str.tostring(atrStopBuffer, format.mintick) : "Off", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 0, 11, "Win rate (closed)", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 1, 11, strategy.closedtrades > 0 ? str.tostring(100.0 * strategy.wintrades / strategy.closedtrades, "#.##") + "%" : "No closed trades", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 0, 12, "Entry TF / Range TF", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 1, 12, timeframe.period + " / " + rangeTimeframe, text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 0, 13, "Trend filter", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 1, 13, trendMethod, text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 0, 14, "Trend entry direction", text_color=color.white, bgcolor=bg)
    table.cell(statusTable, 1, 14, trendMethod == "Off" ? "Both (filter off)" : longTrendOk ? "Long" : shortTrendOk ? "Short" : "Blocked / warming up", text_color=color.white, bgcolor=bg)
````
