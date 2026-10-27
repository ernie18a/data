# Advanced Buy-Sell Alerts Pro v3 Fixed - Runtime Safe

- url: https://www.tradingview.com/script/zsSjaHFe-Advanced-Buy-Sell-Alerts-Pro-v3-Fixed-Runtime-Safe/
- type: indicator
- pine_id: PUB;8590b708d74646fd8247326b4a92f3d8
- version: 1.0

## Description

**Advanced Buy-Sell Alerts Pro v3 Fixed - Runtime Safe** is a swing-trading scanner that monitors a fixed watchlist of stocks and identifies potential BUY setups using trend, momentum, volume, volatility, and 52-week-high filters.

The script first checks the overall market regime using QQQ above its 200-day SMA and VIX below the selected threshold. If conditions are acceptable, each stock is scored from 0 to 5. A BUY signal appears when the score meets the minimum requirement.

For each valid setup, the script calculates an ATR-based stop loss, profit target, and risk/reward ratio. Results are displayed in a dashboard table, and individual alerts are triggered for each qualifying stock.

This version is designed to be runtime-safe by using fixed security calls and extra data validation to reduce invalid-symbol or missing-data errors.

## Source Code

````pine
//@version=6
indicator("Advanced Buy-Sell Alerts Pro v3 Fixed - Runtime Safe", overlay=false, max_lines_count=50)

// SETTINGS
grpMarket = "Market Regime"
grpSignal = "Signal Filters"
grpRisk   = "Risk Management"

scanTF = input.timeframe("D", "Scan Timeframe")
spyTF  = input.timeframe("D", "Regime Timeframe")

useSPYFilter = input.bool(true, "Require QQQ > 200 SMA", group=grpMarket)
useVIXFilter = input.bool(true, "Skip signals when VIX > threshold", group=grpMarket)
vixThreshold = input.float(30.0, "VIX Threshold", minval=10, maxval=60, group=grpMarket)

rsiLow   = input.int(50, "RSI Min", minval=30, maxval=60, group=grpSignal)
rsiHigh  = input.int(72, "RSI Max", minval=60, maxval=85, group=grpSignal)
volMult  = input.float(1.5, "Volume Surge Multiplier", minval=1.0, group=grpSignal)
atrMin   = input.float(1.5, "ATR% Min", minval=0.5, group=grpSignal)
atrMax   = input.float(8.0, "ATR% Max", minval=2.0, group=grpSignal)
distMax  = input.float(15.0, "Max % Below 52w High", minval=5.0, group=grpSignal)
minScore = input.int(3, "Min Score to Qualify", minval=1, maxval=5, group=grpSignal)

atrStopMult = input.float(1.5, "Stop = ATR x", minval=0.5, maxval=4.0, group=grpRisk)
atrTgtMult  = input.float(3.0, "Target = ATR x", minval=1.0, maxval=8.0, group=grpRisk)

// TYPE
type TickerData
    string name
    bool buySignal
    int score
    float stopPrice
    float targetPrice
    float riskReward

// MARKET REGIME
qqqClose  = request.security("QQQ", spyTF, close, lookahead=barmerge.lookahead_off)
qqqSMA200 = request.security("QQQ", spyTF, ta.sma(close, 200), lookahead=barmerge.lookahead_off)
vixClose  = request.security("VIX", spyTF, close, lookahead=barmerge.lookahead_off)

bullMarket = not useSPYFilter or (not na(qqqClose) and not na(qqqSMA200) and qqqClose > qqqSMA200)
vixOK      = not useVIXFilter or (not na(vixClose) and vixClose < vixThreshold)
regimeOK   = bullMarket and vixOK

// METRICS
getTickerMetrics() =>
    rsi14       = ta.rsi(close, 14)
    vol5        = ta.sma(volume, 5)
    vol20       = ta.sma(volume, 20)
    sma50       = ta.sma(close, 50)
    sma150      = ta.sma(close, 150)
    sma200      = ta.sma(close, 200)
    atr14Local  = ta.atr(14)
    atrPct      = close > 0 ? atr14Local / close * 100 : na
    high52      = ta.highest(high, 252)
    dist52      = high52 > 0 ? (close / high52 - 1.0) * 100 : na
    volVelocity = vol20 > 0 ? vol5 / vol20 : na

    trendScore = close > sma50 and sma50 > sma150 and sma150 > sma200 ? 1 : 0
    momScore   = rsi14 >= rsiLow and rsi14 <= rsiHigh ? 1 : 0
    volScore   = not na(volVelocity) and volVelocity >= volMult ? 1 : 0
    atrScore   = not na(atrPct) and atrPct >= atrMin and atrPct <= atrMax ? 1 : 0
    highScore  = not na(dist52) and dist52 >= -distMax and dist52 <= -1.0 ? 1 : 0

    totalScore = trendScore + momScore + volScore + atrScore + highScore
    [totalScore, atr14Local, close]

// WATCHLIST — plain symbols avoid invalid exchange runtime errors
var string[] watchlist = array.from(
     "OSW", "AAPL", "MSFT", "NVDA", "AMD",
     "TSLA", "AMZN", "META", "GOOGL", "PLTR",
     "AVGO", "NFLX", "JPM", "V", "WMT"
)

isTechTicker(string sym) =>
    array.includes(array.from("AAPL", "MSFT", "NVDA", "AMD", "TSLA", "AMZN", "META", "GOOGL", "PLTR", "AVGO", "NFLX"), sym)

// SECURITY CALLS
[sc0, atr0, px0] = request.security(array.get(watchlist, 0), scanTF, getTickerMetrics(), ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)
[sc1, atr1, px1] = request.security(array.get(watchlist, 1), scanTF, getTickerMetrics(), ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)
[sc2, atr2, px2] = request.security(array.get(watchlist, 2), scanTF, getTickerMetrics(), ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)
[sc3, atr3, px3] = request.security(array.get(watchlist, 3), scanTF, getTickerMetrics(), ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)
[sc4, atr4, px4] = request.security(array.get(watchlist, 4), scanTF, getTickerMetrics(), ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)
[sc5, atr5, px5] = request.security(array.get(watchlist, 5), scanTF, getTickerMetrics(), ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)
[sc6, atr6, px6] = request.security(array.get(watchlist, 6), scanTF, getTickerMetrics(), ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)
[sc7, atr7, px7] = request.security(array.get(watchlist, 7), scanTF, getTickerMetrics(), ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)
[sc8, atr8, px8] = request.security(array.get(watchlist, 8), scanTF, getTickerMetrics(), ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)
[sc9, atr9, px9] = request.security(array.get(watchlist, 9), scanTF, getTickerMetrics(), ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)
[sc10, atr10, px10] = request.security(array.get(watchlist, 10), scanTF, getTickerMetrics(), ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)
[sc11, atr11, px11] = request.security(array.get(watchlist, 11), scanTF, getTickerMetrics(), ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)
[sc12, atr12, px12] = request.security(array.get(watchlist, 12), scanTF, getTickerMetrics(), ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)
[sc13, atr13, px13] = request.security(array.get(watchlist, 13), scanTF, getTickerMetrics(), ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)
[sc14, atr14, px14] = request.security(array.get(watchlist, 14), scanTF, getTickerMetrics(), ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)

// RESULTS
var TickerData[] results = array.new<TickerData>()

if barstate.isfirst
    for i = 0 to array.size(watchlist) - 1
        array.push(results, TickerData.new(array.get(watchlist, i), false, 0, na, na, na))

processItem(int idx, int sc, float atrVal, float px, int activeCount, int techCount) =>
    string sym = array.get(watchlist, idx)

    bool validData = not na(sc) and not na(atrVal) and not na(px) and px > 0 and atrVal > 0
    bool qualifies = regimeOK and validData and sc >= minScore

    float stopPrice   = qualifies ? px - atrVal * atrStopMult : na
    float targetPrice = qualifies ? px + atrVal * atrTgtMult : na
    float rr          = qualifies and not na(stopPrice) and not na(targetPrice) and px - stopPrice > 0 ? (targetPrice - px) / (px - stopPrice) : na

    bool validTrade = qualifies and not na(stopPrice) and not na(targetPrice) and not na(rr)

    TickerData item = array.get(results, idx)
    item.buySignal   := validTrade
    item.score       := validData ? sc : 0
    item.stopPrice   := stopPrice
    item.targetPrice := targetPrice
    item.riskReward  := rr

    int newActive = activeCount
    int newTech   = techCount

    if validTrade
        newActive += 1
        if isTechTicker(sym)
            newTech += 1

    [newActive, newTech]

// PIPELINE
[act0, tch0] = processItem(0, sc0, atr0, px0, 0, 0)
[act1, tch1] = processItem(1, sc1, atr1, px1, act0, tch0)
[act2, tch2] = processItem(2, sc2, atr2, px2, act1, tch1)
[act3, tch3] = processItem(3, sc3, atr3, px3, act2, tch2)
[act4, tch4] = processItem(4, sc4, atr4, px4, act3, tch3)
[act5, tch5] = processItem(5, sc5, atr5, px5, act4, tch4)
[act6, tch6] = processItem(6, sc6, atr6, px6, act5, tch5)
[act7, tch7] = processItem(7, sc7, atr7, px7, act6, tch6)
[act8, tch8] = processItem(8, sc8, atr8, px8, act7, tch7)
[act9, tch9] = processItem(9, sc9, atr9, px9, act8, tch8)
[act10, tch10] = processItem(10, sc10, atr10, px10, act9, tch9)
[act11, tch11] = processItem(11, sc11, atr11, px11, act10, tch10)
[act12, tch12] = processItem(12, sc12, atr12, px12, act11, tch11)
[act13, tch13] = processItem(13, sc13, atr13, px13, act12, tch12)
[activeSignalsCount, techSectorSignals] = processItem(14, sc14, atr14, px14, act13, tch13)

// PLOT
plot(activeSignalsCount, title="Active Signals", color=color.new(color.teal, 28), linewidth=2, style=plot.style_histogram)
hline(0, color=color.gray, linestyle=hline.style_dashed)

// ALERTS
regimeStr = bullMarket ? "BULL" : "BEAR"
vixStr    = vixOK ? "OK" : "ELEVATED"

if barstate.isconfirmed
    for idx = 0 to array.size(results) - 1
        TickerData r = array.get(results, idx)

        if r.buySignal and not na(r.stopPrice) and not na(r.targetPrice) and not na(r.riskReward)
            string msg = "SWING BUY: " + r.name +
                 " | Score: " + str.tostring(r.score) + "/5" +
                 " | Stop: " + str.tostring(r.stopPrice, "#.##") +
                 " | Target: " + str.tostring(r.targetPrice, "#.##") +
                 " | R:R: " + str.tostring(r.riskReward, "#.#") + "x" +
                 " | Regime: " + regimeStr +
                 " | VIX: " + vixStr

            alert(msg, alert.freq_once_per_bar_close)

// TABLE COLORS
scoreColor(int sc) =>
    switch
        sc >= 5 => color.new(color.lime, 20)
        sc >= 4 => color.new(color.green, 40)
        sc >= 3 => color.new(color.teal, 50)
        => color.new(color.gray, 70)

// TABLE
var table t = table.new(position.top_right, 6, array.size(watchlist) + 3, border_width=1, border_color=color.new(color.gray, 60))

if barstate.islast
    hdrBg  = color.new(color.navy, 10)
    hdrTxt = color.white

    table.cell(t, 0, 0, "Ticker", text_color=hdrTxt, bgcolor=hdrBg, text_size=size.large)
    table.cell(t, 1, 0, "Signal", text_color=hdrTxt, bgcolor=hdrBg, text_size=size.large)
    table.cell(t, 2, 0, "Score", text_color=hdrTxt, bgcolor=hdrBg, text_size=size.large)
    table.cell(t, 3, 0, "Stop", text_color=hdrTxt, bgcolor=hdrBg, text_size=size.large)
    table.cell(t, 4, 0, "Target", text_color=hdrTxt, bgcolor=hdrBg, text_size=size.large)
    table.cell(t, 5, 0, "R:R", text_color=hdrTxt, bgcolor=hdrBg, text_size=size.large)

    regimeBg  = regimeOK ? color.new(color.green, 20) : color.new(color.red, 20)
    regimeTxt = regimeOK ? "REGIME OK " + regimeStr + " VIX " + vixStr : "REGIME BLOCKED " + regimeStr + " VIX " + vixStr

    table.cell(t, 0, 1, regimeTxt, text_color=color.white, bgcolor=regimeBg, text_size=size.normal)
    for col = 1 to 5
        table.cell(t, col, 1, "", bgcolor=regimeBg)

    for idx = 0 to array.size(results) - 1
        TickerData r = array.get(results, idx)
        rowIdx = idx + 2

        stopTxt   = r.buySignal ? str.tostring(r.stopPrice, "#.##") : "-"
        targetTxt = r.buySignal ? str.tostring(r.targetPrice, "#.##") : "-"
        rrTxt     = r.buySignal ? str.tostring(r.riskReward, "#.#") + "x" : "-"

        table.cell(t, 0, rowIdx, r.name, text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.normal)
        table.cell(t, 1, rowIdx, r.buySignal ? "BUY" : "-", text_color=color.white, bgcolor=scoreColor(r.buySignal ? r.score : 0), text_size=size.normal)
        table.cell(t, 2, rowIdx, r.buySignal ? str.tostring(r.score) + "/5" : "-", text_color=color.white, bgcolor=scoreColor(r.buySignal ? r.score : 0), text_size=size.normal)
        table.cell(t, 3, rowIdx, stopTxt, text_color=color.orange, bgcolor=color.new(color.gray, 75), text_size=size.normal)
        table.cell(t, 4, rowIdx, targetTxt, text_color=color.lime, bgcolor=color.new(color.gray, 75), text_size=size.normal)
        table.cell(t, 5, rowIdx, rrTxt, text_color=color.white, bgcolor=color.new(color.gray, 75), text_size=size.normal)
````
