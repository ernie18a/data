# Momentum Volume Price Engine [AlgoChief]

- url: https://www.tradingview.com/script/zd16bJ7o-Momentum-Volume-Price-Engine-AlgoChief/
- type: indicator
- pine_id: PUB;0c1e09d079be4b259b0865b08d5c7782
- version: 1.0

## Description

Momentum Volume Price Engine is an advanced multi-timeframe market structure indicator designed to identify institutional accumulation and distribution phases by simultaneously evaluating three core pillars of price action: Momentum, Volume surge, and Price expansion.

When large institutions accumulate or distribute an asset, they cannot do so in a single transaction without causing extreme slippage. Instead, they systematically execute orders over multiple sessions. This consistent institutional pressure leaves a distinct footprint: repeated closes in the direction of the trend, sustained above-average volume, and decisive directional price progress.

The MVP Engine captures this exact institutional footprint, providing high-probability BUY and SELL entries along with dynamic multi-target profit taking and risk management levels.


Core MVP Detection Engine

The indicator continuously scans price action across any timeframe using three simultaneous criteria:

Momentum evaluates directional consistency by measuring the number of bars within the evaluation window that closed in the trend direction. Persistent directional closes confirm institutional order flow.

Volume measures participation intensity by comparing the lookback volume against the 50-period volume moving average. This confirms whether the price movement is supported by institutional capital.

Price measures cumulative directional velocity, ensuring the momentum and volume are translating into real trend extension rather than consolidation chop.

When all three conditions align, the engine marks active accumulation with green diamond markers and active distribution with red diamond markers.


Bullish Accumulation And BUY Signals

A green BUY label appears on the initial bar where all bullish MVP requirements are confirmed. This marks the earliest stage of an institutional markup phase.

Subsequent bars within the same momentum run display green diamond markers to show that institutional accumulation remains intact.

https://www.tradingview.com/x/NmR4UdLm/


Bearish Distribution And SELL Signals

A red SELL label appears on the initial bar where bearish MVP conditions trigger, signaling institutional unloading and distribution.

Subsequent bars in the breakdown sequence display red diamond markers below price, alerting traders to ongoing selling pressure.

https://www.tradingview.com/x/WkCKvmYj/


Automatic ATR Targets And Stop Loss

Every signal automatically calculates and projects three dynamic take-profit targets and a disciplined stop-loss level based on current market volatility:

TP1 (1.5x ATR): First profit-taking zone for quick scalps or partial de-risking

TP2 (3.0x ATR): Core swing target for standard trend legs

TP3 (5.0x ATR): Extended trend runner target for major momentum cycles

Stop Loss (1.5x ATR): Risk-defined level positioned to protect capital against trend invalidation

Target and stop levels plot cleanly as color-coded horizontal levels on the chart until the trade hits a target or resets on a new signal.


Institutional Moving Averages

The indicator includes three industry-standard moving averages for structural trend context:

10 EMA (Electric Cyan): Short-term momentum tracking and dynamic trailing support

21 EMA (Spring Green): Primary institutional pullback and bounce level

50 SMA (Coral Red): Intermediate-term baseline trend benchmark


Real-Time Trade Dashboard

An on-chart status table provides live trade management data at a glance:

Active Trade Status: Identifies whether price is currently in a LONG, SHORT, or neutral state

Trade Parameters: Displays exact live price levels for Entry, TP1, TP2, TP3, and Stop Loss

MVP Criteria Progress: Tracks live Close Up ratio, Close Down ratio, Volume percentage delta, and Price percentage change relative to threshold requirements


Universal Timeframe Adaptability

The default settings are optimized to provide clean, actionable signals across all liquid markets and intervals, including Forex, Crypto, Stocks, and Commodities.

For fast intraday scalping on lower timeframes like 1m or 5m, keep the Price Change percentage low to account for tighter percentage moves. For higher timeframes like 4h or Daily on volatile equities, increase the Price Change percentage to focus on larger macro expansions.


Risk Management Notice

Always manage risk prudently. No single technical indicator should be traded in isolation. Combine MVP signals with overall market trend, support and resistance zones, and proper position sizing.

## Source Code

````pine
//@version=6
indicator(title = "Momentum Volume Price Engine [AlgoChief]", shorttitle = "MVP Engine [AlgoChief]", overlay = true, max_labels_count = 500, max_bars_back = 500)

// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

grp_mvp = "MVP Requirements (Momentum, Volume & Price)"
lookbackBars  = input.int(10, "Lookback Window (Bars)", minval = 2, tooltip = "Number of bars to evaluate. Lower = more signals.", group = grp_mvp, display = display.none)
reqUpBars     = input.int(7, "Min Bars For Momentum", minval = 1, tooltip = "Min closing bars in direction of trend.", group = grp_mvp, display = display.none)
reqVolPct     = input.float(10.0, "Volume % Above 50-Avg", minval = 0, tooltip = "Required volume surge above 50-bar average.", group = grp_mvp, display = display.none)
reqPricePct   = input.float(2.0, "Price Change %", minval = 0.1, step = 0.5, tooltip = "Min price % gain/loss over lookback. Lower = more signals on all timeframes.", group = grp_mvp, display = display.none)

grp_tgt = "Targets & Stop Loss (ATR Multiples)"
atrLen        = input.int(14, "ATR Length", minval = 1, group = grp_tgt, display = display.none)
tp1Mult       = input.float(1.5, "TP1 Multiple", minval = 0.5, step = 0.5, group = grp_tgt, display = display.none)
tp2Mult       = input.float(3.0, "TP2 Multiple", minval = 1.0, step = 0.5, group = grp_tgt, display = display.none)
tp3Mult       = input.float(5.0, "TP3 Multiple", minval = 1.5, step = 0.5, group = grp_tgt, display = display.none)
slMult        = input.float(1.5, "Stop Loss Multiple", minval = 0.5, step = 0.5, group = grp_tgt, display = display.none)

grp_ma = "Moving Averages"
showMAs       = input.bool(true, "Show Moving Averages", group = grp_ma, display = display.none)
lenFast       = input.int(10, "Fast EMA", minval = 1, group = grp_ma, display = display.none)
colFast       = input.color(#00E5FF, "Fast EMA Color", group = grp_ma, display = display.none)
lenMid        = input.int(21, "Mid EMA", minval = 1, group = grp_ma, display = display.none)
colMid        = input.color(#69F0AE, "Mid EMA Color", group = grp_ma, display = display.none)
lenSlow       = input.int(50, "Slow SMA", minval = 1, group = grp_ma, display = display.none)
colSlow       = input.color(#FF5252, "Slow SMA Color", group = grp_ma, display = display.none)

grp_vis = "Signal Colors"
bullAntCol    = input.color(#00E676, "Bull Ant Color", group = grp_vis, display = display.none)
bearAntCol    = input.color(#FF5252, "Bear Ant Color", group = grp_vis, display = display.none)
buyCol        = input.color(#00E676, "Buy Arrow Color", group = grp_vis, display = display.none)
sellCol       = input.color(#FF5252, "Sell Arrow Color", group = grp_vis, display = display.none)
tp1Col        = input.color(#4CAF50, "TP1 Line", group = grp_vis, display = display.none)
tp2Col        = input.color(#00BCD4, "TP2 Line", group = grp_vis, display = display.none)
tp3Col        = input.color(#FFD700, "TP3 Line", group = grp_vis, display = display.none)
slCol         = input.color(#FF5252, "SL Line", group = grp_vis, display = display.none)

grp_tbl = "Dashboard"
showTable     = input.bool(true, "Show Dashboard", group = grp_tbl, display = display.none)
tblPos        = input.string("Bottom Right", "Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = grp_tbl, display = display.none)


// ═══════════════════════════════════════════════════════════════════════════════
//  CORE MVP CALCULATIONS (Bullish + Bearish)
// ═══════════════════════════════════════════════════════════════════════════════

upCount = 0
downCount = 0
for i = 0 to lookbackBars - 1
    if close[i] > close[i + 1]
        upCount += 1
    if close[i] < close[i + 1]
        downCount += 1

bullMomentum = upCount >= reqUpBars
bearMomentum = downCount >= reqUpBars

avgVol   = ta.sma(volume, lookbackBars)
smaVol50 = ta.sma(volume, 50)
volDiff  = smaVol50 > 0 ? ((avgVol - smaVol50) / smaVol50) * 100.0 : 0.0
volMet   = volDiff >= reqVolPct

pastClose = close[lookbackBars]
priceChg  = pastClose > 0 ? ((close - pastClose) / pastClose) * 100.0 : 0.0
bullPrice = priceChg >= reqPricePct
bearPrice = priceChg <= -reqPricePct

isBullAnt = bullMomentum and volMet and bullPrice
isBearAnt = bearMomentum and volMet and bearPrice

buySignal  = isBullAnt and not isBullAnt[1]
sellSignal = isBearAnt and not isBearAnt[1]


// ═══════════════════════════════════════════════════════════════════════════════
//  TRADE MANAGEMENT — Entry, Targets, Stop Loss
// ═══════════════════════════════════════════════════════════════════════════════

atrVal = ta.atr(atrLen)

var float entryPrice = na
var float tp1 = na
var float tp2 = na
var float tp3 = na
var float sl = na
var bool isLong = false
var bool isShort = false

if isLong and not na(sl) and low <= sl
    isLong := false
    entryPrice := na
    tp1 := na
    tp2 := na
    tp3 := na
    sl := na

if isShort and not na(sl) and high >= sl
    isShort := false
    entryPrice := na
    tp1 := na
    tp2 := na
    tp3 := na
    sl := na

if buySignal
    entryPrice := close
    isLong := true
    isShort := false
    tp1 := close + atrVal * tp1Mult
    tp2 := close + atrVal * tp2Mult
    tp3 := close + atrVal * tp3Mult
    sl  := close - atrVal * slMult

if sellSignal
    entryPrice := close
    isShort := true
    isLong := false
    tp1 := close - atrVal * tp1Mult
    tp2 := close - atrVal * tp2Mult
    tp3 := close - atrVal * tp3Mult
    sl  := close + atrVal * slMult

inTrade = isLong or isShort


// ═══════════════════════════════════════════════════════════════════════════════
//  MOVING AVERAGES
// ═══════════════════════════════════════════════════════════════════════════════

emaFast = ta.ema(close, lenFast)
emaMid  = ta.ema(close, lenMid)
smaSlow = ta.sma(close, lenSlow)

plot(showMAs ? emaFast : na, "Fast EMA", color = colFast, linewidth = 2, display = display.all - display.status_line)
plot(showMAs ? emaMid : na, "Mid EMA", color = colMid, linewidth = 2, display = display.all - display.status_line)
plot(showMAs ? smaSlow : na, "Slow SMA", color = colSlow, linewidth = 2, display = display.all - display.status_line)


// ═══════════════════════════════════════════════════════════════════════════════
//  TARGET & STOP LOSS LINES
// ═══════════════════════════════════════════════════════════════════════════════

plot(inTrade ? tp1 : na, "TP1", color = tp1Col, style = plot.style_linebr, linewidth = 1)
plot(inTrade ? tp2 : na, "TP2", color = tp2Col, style = plot.style_linebr, linewidth = 1)
plot(inTrade ? tp3 : na, "TP3", color = tp3Col, style = plot.style_linebr, linewidth = 1)
plot(inTrade ? sl : na, "Stop Loss", color = slCol, style = plot.style_linebr, linewidth = 1)
plot(inTrade ? entryPrice : na, "Entry", color = color.white, style = plot.style_linebr, linewidth = 1)


// ═══════════════════════════════════════════════════════════════════════════════
//  ANT MARKERS + BUY/SELL SIGNALS
// ═══════════════════════════════════════════════════════════════════════════════

plotshape(isBullAnt and not buySignal, "Bull Ant", shape.diamond, location.abovebar, bullAntCol, size = size.tiny)
plotshape(isBearAnt and not sellSignal, "Bear Ant", shape.diamond, location.belowbar, bearAntCol, size = size.tiny)

plotshape(buySignal, "BUY", shape.labelup, location.belowbar, buyCol, size = size.small, text = "BUY", textcolor = color.white)
plotshape(sellSignal, "SELL", shape.labeldown, location.abovebar, sellCol, size = size.small, text = "SELL", textcolor = color.white)

barcolor(isBullAnt ? color.new(bullAntCol, 70) : isBearAnt ? color.new(bearAntCol, 70) : na)


// ═══════════════════════════════════════════════════════════════════════════════
//  TARGET HIT LABELS
// ═══════════════════════════════════════════════════════════════════════════════

tp1HitLong  = isLong and not na(tp1) and high >= tp1
tp1HitShort = isShort and not na(tp1) and low <= tp1
tp2HitLong  = isLong and not na(tp2) and high >= tp2
tp2HitShort = isShort and not na(tp2) and low <= tp2
tp3HitLong  = isLong and not na(tp3) and high >= tp3
tp3HitShort = isShort and not na(tp3) and low <= tp3

plotshape(tp1HitLong or tp1HitShort, "TP1 Hit", shape.xcross, location.abovebar, tp1Col, size = size.tiny)
plotshape(tp2HitLong or tp2HitShort, "TP2 Hit", shape.xcross, location.abovebar, tp2Col, size = size.tiny)
plotshape(tp3HitLong or tp3HitShort, "TP3 Hit", shape.xcross, location.abovebar, tp3Col, size = size.tiny)


// ═══════════════════════════════════════════════════════════════════════════════
//  SCREENER PLOTS (hidden)
// ═══════════════════════════════════════════════════════════════════════════════

plot(buySignal ? 1 : 0, "Buy Signal", display = display.none)
plot(sellSignal ? 1 : 0, "Sell Signal", display = display.none)
plot(isBullAnt ? 1 : 0, "Bull Ant", display = display.none)
plot(isBearAnt ? 1 : 0, "Bear Ant", display = display.none)
plot(volDiff, "Vol %", display = display.none)
plot(priceChg, "Price %", display = display.none)


// ═══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD TABLE
// ═══════════════════════════════════════════════════════════════════════════════

f_num(float v) =>
    str.tostring(math.round(v, 1))

f_price(float v) =>
    str.tostring(v, format.mintick)

posT = switch tblPos
    "Top Right"    => position.top_right
    "Bottom Right" => position.bottom_right
    "Top Left"     => position.top_left
    "Bottom Left"  => position.bottom_left
    => position.bottom_right

var table tbl = table.new(posT, 2, 10, bgcolor = #0F172A, border_color = #334155, border_width = 1, frame_color = #1E293B, frame_width = 2)

if barstate.islast and showTable
    hdrBg  = isLong ? #059669 : isShort ? #DC2626 : #1E1B4B
    hdrTxt = isLong ? "◆ LONG ACTIVE" : isShort ? "◆ SHORT ACTIVE" : "MVP Status"
    table.cell(tbl, 0, 0, hdrTxt, bgcolor = hdrBg, text_color = #FFFFFF, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 0, "Value", bgcolor = hdrBg, text_color = #FFFFFF, text_size = size.small, text_halign = text.align_right)

    eTxt = inTrade ? f_price(entryPrice) : "—"
    table.cell(tbl, 0, 1, "Entry", bgcolor = #0F172A, text_color = #94A3B8, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 1, eTxt, bgcolor = #0F172A, text_color = #FFFFFF, text_size = size.small, text_halign = text.align_right)

    t1Txt = inTrade ? f_price(tp1) : "—"
    table.cell(tbl, 0, 2, "TP1", bgcolor = #0F172A, text_color = #94A3B8, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 2, t1Txt, bgcolor = #0F172A, text_color = tp1Col, text_size = size.small, text_halign = text.align_right)

    t2Txt = inTrade ? f_price(tp2) : "—"
    table.cell(tbl, 0, 3, "TP2", bgcolor = #0F172A, text_color = #94A3B8, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 3, t2Txt, bgcolor = #0F172A, text_color = tp2Col, text_size = size.small, text_halign = text.align_right)

    t3Txt = inTrade ? f_price(tp3) : "—"
    table.cell(tbl, 0, 4, "TP3", bgcolor = #0F172A, text_color = #94A3B8, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 4, t3Txt, bgcolor = #0F172A, text_color = tp3Col, text_size = size.small, text_halign = text.align_right)

    sTxt = inTrade ? f_price(sl) : "—"
    table.cell(tbl, 0, 5, "Stop Loss", bgcolor = #0F172A, text_color = #94A3B8, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 5, sTxt, bgcolor = #0F172A, text_color = slCol, text_size = size.small, text_halign = text.align_right)

    cUp = bullMomentum ? #00E676 : #EF4444
    table.cell(tbl, 0, 6, "Close Up", bgcolor = #0F172A, text_color = #94A3B8, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 6, str.tostring(upCount) + "/" + str.tostring(lookbackBars), bgcolor = #0F172A, text_color = cUp, text_size = size.small, text_halign = text.align_right)

    cDn = bearMomentum ? #FF5252 : #94A3B8
    table.cell(tbl, 0, 7, "Close Down", bgcolor = #0F172A, text_color = #94A3B8, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 7, str.tostring(downCount) + "/" + str.tostring(lookbackBars), bgcolor = #0F172A, text_color = cDn, text_size = size.small, text_halign = text.align_right)

    cVol = volMet ? #00E676 : #EF4444
    table.cell(tbl, 0, 8, "Volume %", bgcolor = #0F172A, text_color = #94A3B8, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 8, f_num(volDiff) + "%", bgcolor = #0F172A, text_color = cVol, text_size = size.small, text_halign = text.align_right)

    cPrc = priceChg >= 0 ? #00E676 : #EF4444
    table.cell(tbl, 0, 9, "Price %", bgcolor = #0F172A, text_color = #94A3B8, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 9, f_num(priceChg) + "%", bgcolor = #0F172A, text_color = cPrc, text_size = size.small, text_halign = text.align_right)


// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(buySignal, title = "BUY Signal", message = "[AlgoChief] BUY on {{ticker}} — Bullish MVP Accumulation Detected!")
alertcondition(sellSignal, title = "SELL Signal", message = "[AlgoChief] SELL on {{ticker}} — Bearish MVP Distribution Detected!")
alertcondition(isBullAnt, title = "Bull Ant", message = "[AlgoChief] Bullish Ant active on {{ticker}}")
alertcondition(isBearAnt, title = "Bear Ant", message = "[AlgoChief] Bearish Ant active on {{ticker}}")
````
