# CPR Swing Screener - 20 Symbols With Ideal Target Stop v6

- url: https://www.tradingview.com/script/f5dNHBsi-CPR-Swing-Screener-20-Symbols-With-Ideal-Target-Stop-v6/
- type: indicator
- pine_id: PUB;48cc3758300542cf88de765955a19e33
- version: 1.0

## Description

CPR Swing Screener - 20 Symbols With Ideal Target Stop v6

## Source Code

````pine
//@version=6
indicator("CPR Swing Screener - 20 Symbols With Ideal Target Stop v6", overlay=true, max_labels_count=500)

// ─────────────────────────────
// Inputs
// ─────────────────────────────
narrowCPRPct     = input.float(0.35, "Narrow CPR Width %", step=0.05)
wideCPRPct       = input.float(0.80, "Wide CPR Width %", step=0.05)

emaLength        = input.int(50, "Trend EMA Length", minval=1)
useEMAFilter     = input.bool(true, "Use EMA Trend Filter")

atrLength        = input.int(14, "ATR Length", minval=1)
atrMultiplier    = input.float(2.0, "ATR Stop Multiplier", step=0.25)
rrTarget         = input.float(2.0, "Risk Reward Target", step=0.25)
swingLookback    = input.int(20, "Swing High/Low Lookback", minval=5)

stopMethod       = input.string("Wider", "Stop Method", options=["ATR", "Swing", "Wider"])

useVolumeFilter  = input.bool(false, "Use Volume Confirmation")
volLength        = input.int(20, "Volume MA Length", minval=1)
volMultiplier    = input.float(1.2, "Volume Multiplier", step=0.1)

cooldownBars     = input.int(20, "Chart Signal Cooldown Bars", minval=1)

showOnlySetups   = input.bool(false, "Show Only Active Setups")
showChartLabels  = input.bool(true, "Show Buy/Sell Labels On Current Chart")
showChartLines   = input.bool(false, "Show Ideal / Target / Stop Lines")
showTargetStopLabels = input.bool(true, "Show Ideal / Target / Stop Labels")

tablePosInput = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

// ─────────────────────────────
// 20 Symbols
// ─────────────────────────────
s1  = input.symbol("NASDAQ:AAPL", "Symbol 1")
s2  = input.symbol("NASDAQ:MSFT", "Symbol 2")
s3  = input.symbol("NASDAQ:COIN", "Symbol 3")
s4  = input.symbol("NASDAQ:PLTR", "Symbol 4")
s5  = input.symbol("NASDAQ:MSTR", "Symbol 5")
s6  = input.symbol("NASDAQ:IBIT", "Symbol 6")
s7  = input.symbol("NASDAQ:SHOP", "Symbol 7")
s8  = input.symbol("NASDAQ:AMZN", "Symbol 8")
s9  = input.symbol("NASDAQ:META", "Symbol 9")
s10 = input.symbol("NASDAQ:ASTS", "Symbol 10")
s11 = input.symbol("NASDAQ:SOUN", "Symbol 11")
s12 = input.symbol("NASDAQ:IREN", "Symbol 12")
s13 = input.symbol("NYSE:IONQ", "Symbol 13")
s14 = input.symbol("NASDAQ:RGTI", "Symbol 14")
s15 = input.symbol("NASDAQ:NVDA", "Symbol 15")
s16 = input.symbol("NASDAQ:TSLA", "Symbol 16")
s17 = input.symbol("NASDAQ:AMD", "Symbol 17")
s18 = input.symbol("NASDAQ:AVGO", "Symbol 18")
s19 = input.symbol("NASDAQ:GOOGL", "Symbol 19")
s20 = input.symbol("NASDAQ:SMCI", "Symbol 20")

chartTF = timeframe.period

// ─────────────────────────────
// Table Position
// ─────────────────────────────
tablePosition = position.top_right

if tablePosInput == "Top Left"
    tablePosition := position.top_left
else if tablePosInput == "Bottom Right"
    tablePosition := position.bottom_right
else if tablePosInput == "Bottom Left"
    tablePosition := position.bottom_left

// ─────────────────────────────
// CPR + Swing Logic
// Status:
//  2  = BUY CALL
//  1  = CALL WATCH
// -1  = PUT WATCH
// -2  = BUY PUT
//  0  = NEUTRAL
// ─────────────────────────────
f_status() =>
    newDay = ta.change(time("D")) != 0

    var float dayHigh = na
    var float dayLow = na
    var float dayClose = na

    var float prevHigh = na
    var float prevLow = na
    var float prevClose = na

    if newDay
        prevHigh := dayHigh
        prevLow := dayLow
        prevClose := dayClose

        dayHigh := high
        dayLow := low
        dayClose := close
    else
        dayHigh := na(dayHigh) ? high : math.max(dayHigh, high)
        dayLow := na(dayLow) ? low : math.min(dayLow, low)
        dayClose := close

    pivot = not na(prevHigh) and not na(prevLow) and not na(prevClose) ? (prevHigh + prevLow + prevClose) / 3 : na
    bc = not na(prevHigh) and not na(prevLow) ? (prevHigh + prevLow) / 2 : na
    tc = not na(pivot) and not na(bc) ? (pivot - bc) + pivot : na

    topCPR = math.max(tc, bc)
    bottomCPR = math.min(tc, bc)

    r1 = not na(pivot) ? 2 * pivot - prevLow : na
    s1p = not na(pivot) ? 2 * pivot - prevHigh : na

    cprWidthPct = not na(topCPR) and close != 0 ? ((topCPR - bottomCPR) / close) * 100 : na

    narrowCPR = not na(cprWidthPct) and cprWidthPct <= narrowCPRPct
    wideCPR = not na(cprWidthPct) and cprWidthPct >= wideCPRPct

    emaTrend = ta.ema(close, emaLength)
    atrVal = ta.atr(atrLength)

    volMA = ta.sma(volume, volLength)
    volumeOK = useVolumeFilter ? volume > volMA * volMultiplier : true

    bullishTrend = close > emaTrend
    bearishTrend = close < emaTrend

    trendBuyOK = useEMAFilter ? bullishTrend : true
    trendSellOK = useEMAFilter ? bearishTrend : true

    bullishCandle = close > open
    bearishCandle = close < open

    // CPR setup logic
    narrowBreakoutBuy = narrowCPR and close > topCPR and close > r1 and bullishCandle and trendBuyOK and volumeOK
    narrowBreakoutSell = narrowCPR and close < bottomCPR and close < s1p and bearishCandle and trendSellOK and volumeOK

    wideBuyZone = wideCPR and low <= bottomCPR and close > bottomCPR and bullishCandle and trendBuyOK
    wideSellZone = wideCPR and high >= topCPR and close < topCPR and bearishCandle and trendSellOK

    buyCall = narrowBreakoutBuy or wideBuyZone
    buyPut  = narrowBreakoutSell or wideSellZone

    callWatch = narrowCPR and close > pivot and close <= r1 and trendBuyOK
    putWatch  = narrowCPR and close < pivot and close >= s1p and trendSellOK

    status = buyCall ? 2 : buyPut ? -2 : callWatch ? 1 : putWatch ? -1 : 0

    // Ideal entry logic
    idealPrice =
         status == 2 ? close :
         status == -2 ? close :
         status == 1 ? r1 :
         status == -1 ? s1p :
         na

    // Swing-style stop logic
    swingLow = ta.lowest(low, swingLookback)
    swingHigh = ta.highest(high, swingLookback)

    atrLongStop = close - atrVal * atrMultiplier
    atrShortStop = close + atrVal * atrMultiplier

    swingLongStop = swingLow
    swingShortStop = swingHigh

    longStop =
         stopMethod == "ATR" ? atrLongStop :
         stopMethod == "Swing" ? swingLongStop :
         math.min(atrLongStop, swingLongStop)

    shortStop =
         stopMethod == "ATR" ? atrShortStop :
         stopMethod == "Swing" ? swingShortStop :
         math.max(atrShortStop, swingShortStop)

    longRisk = close - longStop
    shortRisk = shortStop - close

    longTarget = close + longRisk * rrTarget
    shortTarget = close - shortRisk * rrTarget

    target =
         status == 2 or status == 1 ? longTarget :
         status == -2 or status == -1 ? shortTarget :
         na

    stopLoss =
         status == 2 or status == 1 ? longStop :
         status == -2 or status == -1 ? shortStop :
         na

    rr =
         status == 2 or status == 1 ? (target - close) / (close - stopLoss) :
         status == -2 or status == -1 ? (close - target) / (stopLoss - close) :
         na

    [status, close, pivot, cprWidthPct, emaTrend, idealPrice, target, stopLoss, rr]

// ─────────────────────────────
// Request Security
// ─────────────────────────────
f_get(sym) =>
    request.security(sym, chartTF, f_status(), barmerge.gaps_off, barmerge.lookahead_off)

[st1, c1, p1, w1, ema1, ideal1, tgt1, stop1, rr1] = f_get(s1)
[st2, c2, p2, w2, ema2, ideal2, tgt2, stop2, rr2] = f_get(s2)
[st3, c3, p3, w3, ema3, ideal3, tgt3, stop3, rr3] = f_get(s3)
[st4, c4, p4, w4, ema4, ideal4, tgt4, stop4, rr4] = f_get(s4)
[st5, c5, p5, w5, ema5, ideal5, tgt5, stop5, rr5] = f_get(s5)
[st6, c6, p6, w6, ema6, ideal6, tgt6, stop6, rr6] = f_get(s6)
[st7, c7, p7, w7, ema7, ideal7, tgt7, stop7, rr7] = f_get(s7)
[st8, c8, p8, w8, ema8, ideal8, tgt8, stop8, rr8] = f_get(s8)
[st9, c9, p9, w9, ema9, ideal9, tgt9, stop9, rr9] = f_get(s9)
[st10, c10, p10, w10, ema10, ideal10, tgt10, stop10, rr10] = f_get(s10)
[st11, c11, p11, w11, ema11, ideal11, tgt11, stop11, rr11] = f_get(s11)
[st12, c12, p12, w12, ema12, ideal12, tgt12, stop12, rr12] = f_get(s12)
[st13, c13, p13, w13, ema13, ideal13, tgt13, stop13, rr13] = f_get(s13)
[st14, c14, p14, w14, ema14, ideal14, tgt14, stop14, rr14] = f_get(s14)
[st15, c15, p15, w15, ema15, ideal15, tgt15, stop15, rr15] = f_get(s15)
[st16, c16, p16, w16, ema16, ideal16, tgt16, stop16, rr16] = f_get(s16)
[st17, c17, p17, w17, ema17, ideal17, tgt17, stop17, rr17] = f_get(s17)
[st18, c18, p18, w18, ema18, ideal18, tgt18, stop18, rr18] = f_get(s18)
[st19, c19, p19, w19, ema19, ideal19, tgt19, stop19, rr19] = f_get(s19)
[st20, c20, p20, w20, ema20, ideal20, tgt20, stop20, rr20] = f_get(s20)

// ─────────────────────────────
// Helpers
// ─────────────────────────────
f_text(st) =>
    switch st
        2 => "BUY CALL"
        1 => "CALL WATCH"
        -1 => "PUT WATCH"
        -2 => "BUY PUT"
        => "NEUTRAL"

f_bg(st) =>
    switch st
        2 => color.new(color.lime, 15)
        1 => color.new(color.lime, 75)
        -1 => color.new(color.red, 75)
        -2 => color.new(color.red, 15)
        => color.new(color.silver, 75)

f_cleanSymbol(sym) =>
    clean1 = str.replace(str.tostring(sym), "NASDAQ:", "")
    clean2 = str.replace(clean1, "NYSE:", "")
    clean3 = str.replace(clean2, "AMEX:", "")
    clean4 = str.replace(clean3, "BATS:", "")
    clean4

// ─────────────────────────────
// Table
// ─────────────────────────────
var table screener = table.new(tablePosition, 8, 21, border_width=1)

f_row(row, sym, st, price, idealVal, widthVal, targetVal, stopVal, rrVal) =>
    shouldShow = showOnlySetups ? st != 0 : true

    if shouldShow
        table.cell(screener, 0, row, f_cleanSymbol(sym), text_color=color.black, bgcolor=color.white, text_size=size.small)
        table.cell(screener, 1, row, f_text(st), text_color=color.black, bgcolor=f_bg(st), text_size=size.small)
        table.cell(screener, 2, row, str.tostring(price, format.mintick), text_color=color.black, bgcolor=color.white, text_size=size.small)
        table.cell(screener, 3, row, na(idealVal) ? "-" : str.tostring(idealVal, format.mintick), text_color=color.black, bgcolor=color.white, text_size=size.small)
        table.cell(screener, 4, row, str.tostring(widthVal, "#.##") + "%", text_color=color.black, bgcolor=color.white, text_size=size.small)
        table.cell(screener, 5, row, na(targetVal) ? "-" : str.tostring(targetVal, format.mintick), text_color=color.black, bgcolor=color.white, text_size=size.small)
        table.cell(screener, 6, row, na(stopVal) ? "-" : str.tostring(stopVal, format.mintick), text_color=color.black, bgcolor=color.white, text_size=size.small)
        table.cell(screener, 7, row, na(rrVal) ? "-" : str.tostring(rrVal, "#.##"), text_color=color.black, bgcolor=color.white, text_size=size.small)
    else
        for col = 0 to 7
            table.cell(screener, col, row, "", text_color=color.black, bgcolor=color.white)

if barstate.islast
    table.cell(screener, 0, 0, "Symbol", text_color=color.black, bgcolor=color.yellow, text_size=size.small)
    table.cell(screener, 1, 0, "Signal", text_color=color.black, bgcolor=color.yellow, text_size=size.small)
    table.cell(screener, 2, 0, "Price", text_color=color.black, bgcolor=color.yellow, text_size=size.small)
    table.cell(screener, 3, 0, "Ideal", text_color=color.black, bgcolor=color.yellow, text_size=size.small)
    table.cell(screener, 4, 0, "CPR %", text_color=color.black, bgcolor=color.yellow, text_size=size.small)
    table.cell(screener, 5, 0, "Target", text_color=color.black, bgcolor=color.yellow, text_size=size.small)
    table.cell(screener, 6, 0, "Stop", text_color=color.black, bgcolor=color.yellow, text_size=size.small)
    table.cell(screener, 7, 0, "R:R", text_color=color.black, bgcolor=color.yellow, text_size=size.small)

    f_row(1, s1, st1, c1, ideal1, w1, tgt1, stop1, rr1)
    f_row(2, s2, st2, c2, ideal2, w2, tgt2, stop2, rr2)
    f_row(3, s3, st3, c3, ideal3, w3, tgt3, stop3, rr3)
    f_row(4, s4, st4, c4, ideal4, w4, tgt4, stop4, rr4)
    f_row(5, s5, st5, c5, ideal5, w5, tgt5, stop5, rr5)
    f_row(6, s6, st6, c6, ideal6, w6, tgt6, stop6, rr6)
    f_row(7, s7, st7, c7, ideal7, w7, tgt7, stop7, rr7)
    f_row(8, s8, st8, c8, ideal8, w8, tgt8, stop8, rr8)
    f_row(9, s9, st9, c9, ideal9, w9, tgt9, stop9, rr9)
    f_row(10, s10, st10, c10, ideal10, w10, tgt10, stop10, rr10)
    f_row(11, s11, st11, c11, ideal11, w11, tgt11, stop11, rr11)
    f_row(12, s12, st12, c12, ideal12, w12, tgt12, stop12, rr12)
    f_row(13, s13, st13, c13, ideal13, w13, tgt13, stop13, rr13)
    f_row(14, s14, st14, c14, ideal14, w14, tgt14, stop14, rr14)
    f_row(15, s15, st15, c15, ideal15, w15, tgt15, stop15, rr15)
    f_row(16, s16, st16, c16, ideal16, w16, tgt16, stop16, rr16)
    f_row(17, s17, st17, c17, ideal17, w17, tgt17, stop17, rr17)
    f_row(18, s18, st18, c18, ideal18, w18, tgt18, stop18, rr18)
    f_row(19, s19, st19, c19, ideal19, w19, tgt19, stop19, rr19)
    f_row(20, s20, st20, c20, ideal20, w20, tgt20, stop20, rr20)

// ─────────────────────────────
// Current Chart With Cooldown
// ─────────────────────────────
[thisRawStatus, thisClose, thisPivot, thisWidth, thisEMA, thisIdeal, thisTarget, thisStop, thisRR] = f_status()

var int lastChartSignalBar = na
cooldownOK = na(lastChartSignalBar) or bar_index - lastChartSignalBar > cooldownBars
thisStatus = cooldownOK ? thisRawStatus : 0

if thisStatus != 0
    lastChartSignalBar := bar_index

plot(showChartLines ? thisEMA : na, "EMA", color=color.orange, linewidth=2)
plot(showChartLines ? thisIdeal : na, "Ideal Entry", color=color.blue, linewidth=2)
plot(showChartLines ? thisTarget : na, "Swing Target", color=color.lime, linewidth=2)
plot(showChartLines ? thisStop : na, "Swing Stop", color=color.red, linewidth=2)

plotshape(showChartLabels and thisStatus == 2, title="BUY CALL", style=shape.labelup, text="BUY CALL", location=location.belowbar, color=color.green, textcolor=color.white, size=size.small)
plotshape(showChartLabels and thisStatus == -2, title="BUY PUT", style=shape.labeldown, text="BUY PUT", location=location.abovebar, color=color.red, textcolor=color.white, size=size.small)
plotshape(showChartLabels and thisStatus == 1, title="CALL WATCH", style=shape.circle, text="CW", location=location.belowbar, color=color.new(color.green, 55), textcolor=color.white, size=size.tiny)
plotshape(showChartLabels and thisStatus == -1, title="PUT WATCH", style=shape.circle, text="PW", location=location.abovebar, color=color.new(color.red, 55), textcolor=color.white, size=size.tiny)

// ─────────────────────────────
// Ideal / Target / Stop Labels
// ─────────────────────────────
var label idealLabel = na
var label targetLabel = na
var label stopLabel = na

if barstate.islast and showTargetStopLabels
    label.delete(idealLabel)
    label.delete(targetLabel)
    label.delete(stopLabel)

    if not na(thisIdeal)
        idealLabel := label.new(
             bar_index,
             thisIdeal,
             "Ideal: " + str.tostring(thisIdeal, format.mintick),
             style=label.style_label_left,
             color=color.blue,
             textcolor=color.white)

    if not na(thisTarget)
        targetLabel := label.new(
             bar_index,
             thisTarget,
             "Target: " + str.tostring(thisTarget, format.mintick),
             style=label.style_label_left,
             color=color.lime,
             textcolor=color.black)

    if not na(thisStop)
        stopLabel := label.new(
             bar_index,
             thisStop,
             "Stop: " + str.tostring(thisStop, format.mintick),
             style=label.style_label_left,
             color=color.red,
             textcolor=color.white)

// ─────────────────────────────
// Alerts
// ─────────────────────────────
anyBuyCall = st1 == 2 or st2 == 2 or st3 == 2 or st4 == 2 or st5 == 2 or st6 == 2 or st7 == 2 or st8 == 2 or st9 == 2 or st10 == 2 or st11 == 2 or st12 == 2 or st13 == 2 or st14 == 2 or st15 == 2 or st16 == 2 or st17 == 2 or st18 == 2 or st19 == 2 or st20 == 2
anyBuyPut = st1 == -2 or st2 == -2 or st3 == -2 or st4 == -2 or st5 == -2 or st6 == -2 or st7 == -2 or st8 == -2 or st9 == -2 or st10 == -2 or st11 == -2 or st12 == -2 or st13 == -2 or st14 == -2 or st15 == -2 or st16 == -2 or st17 == -2 or st18 == -2 or st19 == -2 or st20 == -2
anyCallWatch = st1 == 1 or st2 == 1 or st3 == 1 or st4 == 1 or st5 == 1 or st6 == 1 or st7 == 1 or st8 == 1 or st9 == 1 or st10 == 1 or st11 == 1 or st12 == 1 or st13 == 1 or st14 == 1 or st15 == 1 or st16 == 1 or st17 == 1 or st18 == 1 or st19 == 1 or st20 == 1
anyPutWatch = st1 == -1 or st2 == -1 or st3 == -1 or st4 == -1 or st5 == -1 or st6 == -1 or st7 == -1 or st8 == -1 or st9 == -1 or st10 == -1 or st11 == -1 or st12 == -1 or st13 == -1 or st14 == -1 or st15 == -1 or st16 == -1 or st17 == -1 or st18 == -1 or st19 == -1 or st20 == -1

alertcondition(anyBuyCall, title="Any Symbol BUY CALL CPR Swing", message="One or more symbols has CPR BUY CALL swing setup.")
alertcondition(anyBuyPut, title="Any Symbol BUY PUT CPR Swing", message="One or more symbols has CPR BUY PUT swing setup.")
alertcondition(anyCallWatch, title="Any Symbol CALL WATCH CPR Swing", message="One or more symbols has bullish CPR swing watch setup.")
alertcondition(anyPutWatch, title="Any Symbol PUT WATCH CPR Swing", message="One or more symbols has bearish CPR swing watch setup.")
````
