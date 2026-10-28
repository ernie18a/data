# Mez Clean Trade Replay Gold Scalper

- url: https://www.tradingview.com/script/pqooXDMk-Mez-Clean-Trade-Replay-Gold-Scalper/
- type: indicator
- pine_id: PUB;e014cd6eb01540b2a19bf3f6daa693ca
- version: 1.0

## Description

Mez Clean Trade Replay Gold Scalper is a professional XAUUSD scalping assistant designed to identify high-probability BUY and SELL opportunities using multi-factor confirmation. The strategy combines higher-timeframe trend analysis, DXY correlation, liquidity sweeps, Fibonacci value zones, momentum, and dynamic risk management to produce clean, disciplined trade setups. It includes TP1, TP2, TP3 and stop-loss management, along with a live trade dashboard and historical trade replay, making it ideal for both live execution and strategy review.

## Source Code

````pine
//@version=6
indicator("GM v12.7 - Clean Trade Replay Gold Scalper", shorttitle="GM v12.7", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=20)

// ============================================================
// GM v12.7 GOAL
// Clean XAUUSD scalping assistant:
// - Uses 4H trend, DXY, liquidity sweeps, Fibonacci golden pocket, EMA/VWAP/RSI/MACD momentum
// - Active trade: shows entry, SL, TP1, TP2, TP3 plan lines only while live
// - Closed trade history: shows only actual events: ENTRY, TP1, TP2, TP3 WIN, SL, or CLOSE
// - No right-side historical plan tags; no visual clutter; no fake TP labels unless price actually hit them
// - Table shows only the active trade or the most recent closed trade
// ============================================================

// ============================================================
// INPUTS
// ============================================================

// Mode
i_mode = input.string("Scalping", "Mode", options=["Scalping", "Balanced", "Strict"], group="Mode")
i_htfTF = input.timeframe("240", "4H Trend Timeframe", group="Mode")
i_strictHTF = input.bool(true, "Block Counter-Trend Trades", group="Mode")
i_minQuality = input.int(70, "Minimum Quality %", minval=50, maxval=100, group="Mode")

// Backtest visuals
i_showTradeLabels = input.bool(true, "Show Trade Labels", group="Backtest Visuals")
i_showTradePlans = input.bool(true, "Show Trade Plan Lines", group="Backtest Visuals")
i_keepHistory = input.int(35, "Number of Historical Trades To Keep", minval=10, maxval=90, group="Backtest Visuals")
i_planLen = input.int(12, "Active Plan Line Length", minval=5, maxval=50, group="Backtest Visuals")
i_markerSize = input.string("Tiny", "Marker Size", options=["Tiny", "Small", "Normal"], group="Backtest Visuals")
i_closedBars = input.int(10, "Keep Closed Trade In Table For Bars", minval=1, maxval=50, group="Backtest Visuals")

// Sessions
i_londonSession = input.session("0700-1100", "London Session", group="Sessions")
i_nySession = input.session("1230-1600", "New York Session", group="Sessions")

// Strategy filters
i_requireLiquidity = input.bool(true, "Require Liquidity Sweep", group="Strategy Filters")
i_requireFib = input.bool(false, "Require Fibonacci Zone", group="Strategy Filters")
i_useDXY = input.string("Soft", "DXY Confirmation", options=["Off", "Soft", "Strict"], group="Strategy Filters")
i_useSessionFilter = input.bool(false, "Only Trade London / NY", group="Strategy Filters")
i_avoidChase = input.bool(true, "Avoid Chasing Extended Moves", group="Strategy Filters")
i_maxDistanceATR = input.float(2.0, "Max Distance From EMA × ATR", step=0.1, group="Strategy Filters")
i_avoidPD = input.bool(true, "Avoid Previous Day High/Low Traps", group="Strategy Filters")
i_pdBuffer = input.float(2.0, "Previous Day Buffer Points", step=0.1, group="Strategy Filters")

// Liquidity
i_liqLB = input.int(20, "Liquidity Lookback", minval=5, maxval=100, group="Liquidity")
i_showLQ = input.bool(false, "Show LQ Markers", group="Liquidity")

// Fibonacci
i_fibLookback = input.int(80, "Fib Lookback", minval=20, maxval=300, group="Fibonacci")
i_fibBufferATR = input.float(0.15, "Fib Buffer × ATR", step=0.05, group="Fibonacci")

// DXY
i_dxySymbol = input.symbol("TVC:DXY", "DXY Symbol", group="DXY")
i_dxyTF = input.timeframe("60", "DXY Timeframe", group="DXY")
i_dxyEmaLen = input.int(200, "DXY EMA Length", minval=20, group="DXY")

// Risk / targets
i_targetMode = input.string("Fixed Points", "Target Mode", options=["Fixed Points", "ATR"], group="Risk")
i_useSwingSL = input.bool(true, "Use Swing-Based SL", group="Risk")
i_swingBuffer = input.float(0.5, "Swing SL Buffer Points", step=0.1, group="Risk")
i_fixedSL = input.float(2.5, "Fixed SL Points", step=0.1, group="Risk")
i_fixedTP1 = input.float(1.5, "Fixed TP1 Points", step=0.1, group="Risk")
i_fixedTP2 = input.float(3.0, "Fixed TP2 Points", step=0.1, group="Risk")
i_fixedTP3 = input.float(5.0, "Fixed TP3 Points", step=0.1, group="Risk")
i_atrLen = input.int(14, "ATR Length", minval=1, group="Risk")
i_slATR = input.float(0.7, "SL × ATR", step=0.1, group="Risk")
i_tp1ATR = input.float(0.4, "TP1 × ATR", step=0.1, group="Risk")
i_tp2ATR = input.float(0.7, "TP2 × ATR", step=0.1, group="Risk")
i_tp3ATR = input.float(1.0, "TP3 × ATR", step=0.1, group="Risk")
i_closeAfterTP1 = input.bool(true, "Close Early After TP1 Reversal", group="Risk")
i_pullbackPts = input.float(1.0, "Close Early Pullback Points", step=0.1, group="Risk")

// Indicators
i_e1 = input.int(8, "EMA Fast", group="Indicators")
i_e2 = input.int(21, "EMA Mid", group="Indicators")
i_e3 = input.int(55, "EMA Slow", group="Indicators")
i_e4 = input.int(200, "EMA Trend", group="Indicators")
i_rsiLen = input.int(14, "RSI Length", group="Indicators")
i_mFast = input.int(12, "MACD Fast", group="Indicators")
i_mSlow = input.int(26, "MACD Slow", group="Indicators")
i_mSig = input.int(9, "MACD Signal", group="Indicators")
i_adxMin = input.float(18.0, "Minimum ADX", step=0.5, group="Indicators")

// Optional lines
i_showEMA = input.bool(false, "Show EMA Lines", group="Optional Visuals")
i_showVWAP = input.bool(false, "Show VWAP", group="Optional Visuals")
i_showPDLevels = input.bool(false, "Show Previous Day High/Low", group="Optional Visuals")

// News
i_blockNews = input.bool(true, "Block Signals Near News", group="News Filter")
i_newsMins = input.int(30, "Minutes Before/After News", minval=5, maxval=120, group="News Filter")
i_news1 = input.string("1230", "News Time 1 UTC HHMM", group="News Filter")
i_news2 = input.string("1800", "News Time 2 UTC HHMM", group="News Filter")
i_news3 = input.string("0000", "News Time 3 UTC HHMM, 0000 = off", group="News Filter")

// ============================================================
// COLOURS
// ============================================================

cBuy = color.new(color.green, 0)
cSell = color.new(color.red, 0)
cTP = color.new(color.blue, 0)
cSL = color.new(color.orange, 0)
cClose = color.new(color.yellow, 0)
cLQ = color.new(color.purple, 0)
cDark = color.rgb(35, 42, 52)
cMuted = color.rgb(115, 121, 132)

// ============================================================
// HELPERS
// ============================================================

f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : size.normal

f_price(float v) =>
    na(v) ? "-" : str.tostring(v, format.mintick)

f_bool(bool v) =>
    v ? "✓" : "✕"

f_newsBlock(string hhmm) =>
    hh = str.tonumber(str.substring(hhmm, 0, 2))
    mm = str.tonumber(str.substring(hhmm, 2, 4))
    valid = hhmm != "0000" and not na(hh) and not na(mm)
    currentMin = hour(time, "UTC") * 60 + minute(time, "UTC")
    targetMin = valid ? hh * 60 + mm : na
    d1 = valid ? math.abs(currentMin - targetMin) : 99999
    d2 = valid ? 1440 - d1 : 99999
    valid and math.min(d1, d2) <= i_newsMins

f_makeMarker(int x, float y, string txt, color bg, color tc, bool up, bool show) =>
    label out = na
    if show and not na(y)
        out := label.new(x=x, y=y, text=txt, style=up ? label.style_label_up : label.style_label_down, textcolor=tc, color=bg, size=f_size(i_markerSize), force_overlay=true)
    out

f_makePlanLine(int x, float y, color c, st, bool show) =>
    line out = na
    if show and not na(y)
        out := line.new(x, y, x + i_planLen, y, color=color.new(c, 40), width=1, style=st, force_overlay=true)
    out

f_makePlanTag(int x, float y, string txt, color bg, color tc, bool show) =>
    label out = na
    if show and not na(y)
        out := label.new(x=x + i_planLen, y=y, text=txt, style=label.style_label_left, textcolor=tc, color=color.new(bg, 0), size=size.tiny, force_overlay=true)
    out

f_deleteLabel(label lb) =>
    if not na(lb)
        label.delete(lb)

// Historical object storage
var label[] histLabels = array.new_label()
var line[] histLines = array.new_line()

f_storeLabel(label lb) =>
    if not na(lb)
        array.push(histLabels, lb)
        maxLabels = i_keepHistory * 5
        if array.size(histLabels) > maxLabels
            old = array.shift(histLabels)
            if not na(old)
                label.delete(old)

f_storeLine(line ln) =>
    if not na(ln)
        array.push(histLines, ln)
        maxLines = i_keepHistory * 5
        if array.size(histLines) > maxLines
            old = array.shift(histLines)
            if not na(old)
                line.delete(old)

// ============================================================
// CORE
// ============================================================

atr = ta.atr(i_atrLen)
rsi = ta.rsi(close, i_rsiLen)
[macdLine, macdSig, _] = ta.macd(close, i_mFast, i_mSlow, i_mSig)
[_dp, _dm, adxVal] = ta.dmi(14, 14)

emaFast = ta.ema(close, i_e1)
emaMid = ta.ema(close, i_e2)
emaSlow = ta.ema(close, i_e3)
emaTrend = ta.ema(close, i_e4)
vwapVal = ta.vwap(hlc3)

bullStack = emaFast > emaMid and emaMid > emaSlow and close > emaTrend
bearStack = emaFast < emaMid and emaMid < emaSlow and close < emaTrend

// 4H trend
htfClose = request.security(syminfo.tickerid, i_htfTF, close[1], lookahead=barmerge.lookahead_off)
htfEma = request.security(syminfo.tickerid, i_htfTF, ta.ema(close, 200)[1], lookahead=barmerge.lookahead_off)
htfBull = htfClose > htfEma
htfBear = htfClose < htfEma

// DXY
dxyClose = request.security(i_dxySymbol, i_dxyTF, close[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
dxyEma = request.security(i_dxySymbol, i_dxyTF, ta.ema(close, i_dxyEmaLen)[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
dxyBull = not na(dxyClose) and not na(dxyEma) and dxyClose > dxyEma
dxyBear = not na(dxyClose) and not na(dxyEma) and dxyClose < dxyEma
dxyUnknown = na(dxyClose) or na(dxyEma)

// Liquidity sweep
liqHigh = ta.highest(high, i_liqLB)[1]
liqLow = ta.lowest(low, i_liqLB)[1]
bullLQ = low < liqLow and close > liqLow
bearLQ = high > liqHigh and close < liqHigh

if i_showLQ and bullLQ
    f_storeLabel(f_makeMarker(bar_index, low - atr * 0.2, "LQ", cLQ, color.white, true, true))
if i_showLQ and bearLQ
    f_storeLabel(f_makeMarker(bar_index, high + atr * 0.2, "LQ", cLQ, color.white, false, true))

// Fibonacci 61.8-65 golden pocket
fibHigh = ta.highest(high, i_fibLookback)
fibLow = ta.lowest(low, i_fibLookback)
fibRange = fibHigh - fibLow
fibBuffer = atr * i_fibBufferATR

fibBuyLow = fibHigh - fibRange * 0.65
fibBuyHigh = fibHigh - fibRange * 0.618
fibSellLow = fibLow + fibRange * 0.618
fibSellHigh = fibLow + fibRange * 0.65

inBullFib = close >= fibBuyLow - fibBuffer and close <= fibBuyHigh + fibBuffer
inBearFib = close >= fibSellLow - fibBuffer and close <= fibSellHigh + fibBuffer


// Previous day levels
prevDHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
prevDLow = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)

// Sessions
inLondon = not na(time(timeframe.period, i_londonSession))
inNY = not na(time(timeframe.period, i_nySession))

// News
nearNews = i_blockNews and (f_newsBlock(i_news1) or f_newsBlock(i_news2) or f_newsBlock(i_news3))

// Momentum
bullMomentum = close > emaFast and close > vwapVal and rsi > 50 and macdLine > macdSig and adxVal > i_adxMin
bearMomentum = close < emaFast and close < vwapVal and rsi < 50 and macdLine < macdSig and adxVal > i_adxMin

recentHigh = ta.highest(high, 10)[1]
recentLow = ta.lowest(low, 10)[1]
bullBreakout = close > recentHigh and bullMomentum
bearBreakdown = close < recentLow and bearMomentum

pullbackBuy = ta.crossover(close, emaFast) and close > emaMid
pullbackSell = ta.crossunder(close, emaFast) and close < emaMid

// Filters
sessionOK = not i_useSessionFilter or inLondon or inNY
notChasing = not i_avoidChase or math.abs(close - emaFast) <= atr * i_maxDistanceATR
buyHasRoom = not i_avoidPD or na(prevDHigh) or close < prevDHigh - i_pdBuffer or close > prevDHigh + i_pdBuffer
sellHasRoom = not i_avoidPD or na(prevDLow) or close > prevDLow + i_pdBuffer or close < prevDLow - i_pdBuffer

htfBuyOK = not i_strictHTF or htfBull
htfSellOK = not i_strictHTF or htfBear

dxyBuyOK = i_useDXY == "Off" or dxyBear or dxyUnknown or i_useDXY == "Soft"
dxySellOK = i_useDXY == "Off" or dxyBull or dxyUnknown or i_useDXY == "Soft"
dxyBuySupports = dxyBear or dxyUnknown
dxySellSupports = dxyBull or dxyUnknown

liqBuyOK = not i_requireLiquidity or bullLQ
liqSellOK = not i_requireLiquidity or bearLQ

fibBuyOK = not i_requireFib or inBullFib
fibSellOK = not i_requireFib or inBearFib

// Weighted quality scores
buyQuality =
     (htfBull ? 25 : 0) +
     ((bullLQ or not i_requireLiquidity) ? 20 : 0) +
     ((inBullFib or not i_requireFib) ? 15 : 0) +
     (dxyBuySupports ? 15 : i_useDXY == "Off" ? 15 : 0) +
     (bullStack ? 10 : 0) +
     (bullMomentum ? 10 : 0) +
     (sessionOK ? 5 : 0)

sellQuality =
     (htfBear ? 25 : 0) +
     ((bearLQ or not i_requireLiquidity) ? 20 : 0) +
     ((inBearFib or not i_requireFib) ? 15 : 0) +
     (dxySellSupports ? 15 : i_useDXY == "Off" ? 15 : 0) +
     (bearStack ? 10 : 0) +
     (bearMomentum ? 10 : 0) +
     (sessionOK ? 5 : 0)

qThreshold = i_mode == "Scalping" ? i_minQuality : i_mode == "Balanced" ? math.max(i_minQuality, 80) : math.max(i_minQuality, 90)

buyTrigger = bullLQ or pullbackBuy or bullBreakout
sellTrigger = bearLQ or pullbackSell or bearBreakdown

eligibleBuy = barstate.isconfirmed and not nearNews and sessionOK and htfBuyOK and dxyBuyOK and liqBuyOK and fibBuyOK and notChasing and buyHasRoom and buyQuality >= qThreshold and buyQuality > sellQuality and buyTrigger
eligibleSell = barstate.isconfirmed and not nearNews and sessionOK and htfSellOK and dxySellOK and liqSellOK and fibSellOK and notChasing and sellHasRoom and sellQuality >= qThreshold and sellQuality > buyQuality and sellTrigger

buySignal = eligibleBuy and not eligibleSell
sellSignal = eligibleSell and not eligibleBuy

// ============================================================
// OPTIONAL VISUALS
// ============================================================

plot(i_showEMA ? emaFast : na, "EMA Fast", color=color.yellow)
plot(i_showEMA ? emaMid : na, "EMA Mid", color=color.orange)
plot(i_showEMA ? emaSlow : na, "EMA Slow", color=color.red)
plot(i_showEMA ? emaTrend : na, "EMA Trend", color=color.white, linewidth=2)
plot(i_showVWAP ? vwapVal : na, "VWAP", color=color.aqua, linewidth=2)
plot(i_showPDLevels ? prevDHigh : na, "Prev Day High", color=color.new(color.red, 20), linewidth=2)
plot(i_showPDLevels ? prevDLow : na, "Prev Day Low", color=color.new(color.blue, 20), linewidth=2)

// ============================================================
// TRADE ENGINE
// ============================================================

var int activeTrade = 0 // 1 buy, -1 sell
var int activeEntryBar = na
var float activeEntry = na
var float activeSL = na
var float activeTP1 = na
var float activeTP2 = na
var float activeTP3 = na
var float bestPrice = na
var bool tp1Done = false
var bool tp2Done = false
var bool tp3Done = false
var string lastResult = "WAIT"
var int activeQuality = na

// Stores the last closed trade so the table stays in sync with SL/TP/C labels
var int lastClosedSide = 0
var int lastClosedUntilBar = na
var float lastClosedEntry = na
var float lastClosedSL = na
var float lastClosedTP1 = na
var float lastClosedTP2 = na
var float lastClosedTP3 = na
var int lastClosedQuality = na
var string lastClosedResult = "WAIT"

var line liveEntryLine = na
var line liveSLLine = na
var line liveTP1Line = na
var line liveTP2Line = na
var line liveTP3Line = na

var label liveEntryTag = na
var label liveSLTag = na
var label liveTP1Tag = na
var label liveTP2Tag = na
var label liveTP3Tag = na

startLong = activeTrade == 0 and buySignal
startShort = activeTrade == 0 and sellSignal

if startLong or startShort
    activeTrade := startLong ? 1 : -1
    activeEntryBar := bar_index
    activeEntry := close
    bestPrice := close
    activeQuality := startLong ? buyQuality : sellQuality

    slDist = i_targetMode == "ATR" ? atr * i_slATR : i_fixedSL
    tp1Dist = i_targetMode == "ATR" ? atr * i_tp1ATR : i_fixedTP1
    tp2Dist = i_targetMode == "ATR" ? atr * i_tp2ATR : i_fixedTP2
    tp3Dist = i_targetMode == "ATR" ? atr * i_tp3ATR : i_fixedTP3

    basicSL = activeTrade == 1 ? activeEntry - slDist : activeEntry + slDist
    swingSL = activeTrade == 1 ? liqLow - i_swingBuffer : liqHigh + i_swingBuffer
    activeSL := i_useSwingSL and not na(swingSL) and ((activeTrade == 1 and swingSL < activeEntry) or (activeTrade == -1 and swingSL > activeEntry)) ? swingSL : basicSL

    activeTP1 := activeTrade == 1 ? activeEntry + tp1Dist : activeEntry - tp1Dist
    activeTP2 := activeTrade == 1 ? activeEntry + tp2Dist : activeEntry - tp2Dist
    activeTP3 := activeTrade == 1 ? activeEntry + tp3Dist : activeEntry - tp3Dist

    tp1Done := false
    tp2Done := false
    tp3Done := false
    lastResult := activeTrade == 1 ? "BUY ENTRY" : "SELL ENTRY"

    // Historical replay marker: one clean ENTRY label on the actual signal candle
    entryY = activeTrade == 1 ? low - atr * 0.25 : high + atr * 0.25
    f_storeLabel(f_makeMarker(bar_index, entryY, activeTrade == 1 ? "BUY ENTRY" : "SELL ENTRY", activeTrade == 1 ? cBuy : cSell, color.white, activeTrade == 1, i_showTradeLabels))

    // Plan lines for backtesting
    liveEntryLine := f_makePlanLine(bar_index, activeEntry, activeTrade == 1 ? cBuy : cSell, line.style_solid, i_showTradePlans)
    liveSLLine := f_makePlanLine(bar_index, activeSL, cSL, line.style_dashed, i_showTradePlans)
    liveTP1Line := f_makePlanLine(bar_index, activeTP1, cTP, line.style_dotted, i_showTradePlans)
    liveTP2Line := f_makePlanLine(bar_index, activeTP2, cTP, line.style_dotted, i_showTradePlans)
    liveTP3Line := f_makePlanLine(bar_index, activeTP3, cTP, line.style_dotted, i_showTradePlans)

    f_storeLine(liveEntryLine)
    f_storeLine(liveSLLine)
    f_storeLine(liveTP1Line)
    f_storeLine(liveTP2Line)
    f_storeLine(liveTP3Line)

    // Live-only right-side plan tags. These are deleted when the trade closes.
    // Historical trades are kept clean using only actual event labels.
    sideTxt = activeTrade == 1 ? "BUY" : "SELL"
    liveEntryTag := f_makePlanTag(bar_index, activeEntry, sideTxt + " ENTRY", activeTrade == 1 ? cBuy : cSell, color.white, i_showTradePlans)
    liveSLTag := f_makePlanTag(bar_index, activeSL, "SL", cSL, color.white, i_showTradePlans)
    liveTP1Tag := f_makePlanTag(bar_index, activeTP1, "TP1", cTP, color.white, i_showTradePlans)
    liveTP2Tag := f_makePlanTag(bar_index, activeTP2, "TP2", cTP, color.white, i_showTradePlans)
    liveTP3Tag := f_makePlanTag(bar_index, activeTP3, "TP3", cTP, color.white, i_showTradePlans)

// Extend active plan until trade closes
if activeTrade != 0
    if not na(liveEntryLine)
        line.set_x2(liveEntryLine, bar_index + i_planLen)
    if not na(liveSLLine)
        line.set_x2(liveSLLine, bar_index + i_planLen)
    if not na(liveTP1Line)
        line.set_x2(liveTP1Line, bar_index + i_planLen)
    if not na(liveTP2Line)
        line.set_x2(liveTP2Line, bar_index + i_planLen)
    if not na(liveTP3Line)
        line.set_x2(liveTP3Line, bar_index + i_planLen)
    if not na(liveEntryTag)
        label.set_x(liveEntryTag, bar_index + i_planLen)
    if not na(liveSLTag)
        label.set_x(liveSLTag, bar_index + i_planLen)
    if not na(liveTP1Tag)
        label.set_x(liveTP1Tag, bar_index + i_planLen)
    if not na(liveTP2Tag)
        label.set_x(liveTP2Tag, bar_index + i_planLen)
    if not na(liveTP3Tag)
        label.set_x(liveTP3Tag, bar_index + i_planLen)

// Trade management
hasTrade = activeTrade != 0 and not na(activeEntryBar) and bar_index > activeEntryBar

if hasTrade
    bestPrice := activeTrade == 1 ? math.max(nz(bestPrice, high), high) : math.min(nz(bestPrice, low), low)

tp1Hit = hasTrade and ((activeTrade == 1 and high >= activeTP1) or (activeTrade == -1 and low <= activeTP1))
tp2Hit = hasTrade and ((activeTrade == 1 and high >= activeTP2) or (activeTrade == -1 and low <= activeTP2))
tp3Hit = hasTrade and ((activeTrade == 1 and high >= activeTP3) or (activeTrade == -1 and low <= activeTP3))
slHit = hasTrade and ((activeTrade == 1 and low <= activeSL) or (activeTrade == -1 and high >= activeSL))

bankTP1 = tp1Hit and not tp1Done
bankTP2 = tp2Hit and not tp2Done
closeTP3 = tp3Hit and not tp3Done
closeSL = slHit and not closeTP3

fastCloseBuy = hasTrade and i_closeAfterTP1 and activeTrade == 1 and tp1Done and not closeTP3 and close <= bestPrice - i_pullbackPts
fastCloseSell = hasTrade and i_closeAfterTP1 and activeTrade == -1 and tp1Done and not closeTP3 and close >= bestPrice + i_pullbackPts
momentumExitBuy = hasTrade and activeTrade == 1 and tp1Done and barstate.isconfirmed and (close < emaFast or rsi < 50 or macdLine < macdSig)
momentumExitSell = hasTrade and activeTrade == -1 and tp1Done and barstate.isconfirmed and (close > emaFast or rsi > 50 or macdLine > macdSig)
closeEarly = (fastCloseBuy or fastCloseSell or momentumExitBuy or momentumExitSell) and not closeTP3 and not closeSL

if bankTP1
    tp1Done := true
    lastResult := activeTrade == 1 ? "BUY TP1 HIT" : "SELL TP1 HIT"
    f_storeLabel(f_makeMarker(bar_index, activeTP1, "TP1", cTP, color.white, activeTrade == 1, i_showTradeLabels))

if bankTP2
    tp2Done := true
    lastResult := activeTrade == 1 ? "BUY TP2 HIT" : "SELL TP2 HIT"
    f_storeLabel(f_makeMarker(bar_index, activeTP2, "TP2", cTP, color.white, activeTrade == 1, i_showTradeLabels))

if closeTP3
    tp3Done := true
    lastResult := activeTrade == 1 ? "BUY TP3 WIN" : "SELL TP3 WIN"
    f_storeLabel(f_makeMarker(bar_index, activeTP3, "TP3 WIN", cTP, color.white, activeTrade == 1, i_showTradeLabels))

exitStage = tp2Done ? "AFTER TP2" : tp1Done ? "AFTER TP1" : "BEFORE TP1"

if closeSL
    lastResult := activeTrade == 1 ? "BUY SL " + exitStage : "SELL SL " + exitStage
    f_storeLabel(f_makeMarker(bar_index, activeSL, "SL " + exitStage, cSL, color.white, activeTrade == -1, i_showTradeLabels))

if closeEarly
    lastResult := activeTrade == 1 ? "BUY CLOSE " + exitStage : "SELL CLOSE " + exitStage
    f_storeLabel(f_makeMarker(bar_index, close, "CLOSE " + exitStage, cClose, color.black, activeTrade == -1, i_showTradeLabels))

closeTradeNow = hasTrade and (closeTP3 or closeSL or closeEarly)

if closeTradeNow
    lastClosedSide := activeTrade
    lastClosedUntilBar := bar_index + i_closedBars
    lastClosedEntry := activeEntry
    lastClosedSL := activeSL
    lastClosedTP1 := activeTP1
    lastClosedTP2 := activeTP2
    lastClosedTP3 := activeTP3
    lastClosedQuality := activeQuality
    lastClosedResult := lastResult

    // Close the plan visually at the exit candle, then remove live-only right-side tags.
    if not na(liveEntryLine)
        line.set_x2(liveEntryLine, bar_index)
    if not na(liveSLLine)
        line.set_x2(liveSLLine, bar_index)
    if not na(liveTP1Line)
        line.set_x2(liveTP1Line, bar_index)
    if not na(liveTP2Line)
        line.set_x2(liveTP2Line, bar_index)
    if not na(liveTP3Line)
        line.set_x2(liveTP3Line, bar_index)
    f_deleteLabel(liveEntryTag)
    f_deleteLabel(liveSLTag)
    f_deleteLabel(liveTP1Tag)
    f_deleteLabel(liveTP2Tag)
    f_deleteLabel(liveTP3Tag)

    activeTrade := 0
    activeEntryBar := na
    activeEntry := na
    activeSL := na
    activeTP1 := na
    activeTP2 := na
    activeTP3 := na
    bestPrice := na
    tp1Done := false
    tp2Done := false
    tp3Done := false
    activeQuality := na
    liveEntryLine := na
    liveSLLine := na
    liveTP1Line := na
    liveTP2Line := na
    liveTP3Line := na
    liveEntryTag := na
    liveSLTag := na
    liveTP1Tag := na
    liveTP2Tag := na
    liveTP3Tag := na

// ============================================================
// TABLE
// ============================================================

showClosedTrade = activeTrade == 0 and not na(lastClosedUntilBar) and bar_index <= lastClosedUntilBar

actionText = "WAIT"
actionBg = color.gray
reasonText = "No clean setup"

if activeTrade == 1
    actionText := "MANAGE BUY"
    actionBg := cBuy
    reasonText := "Trade active"
else if activeTrade == -1
    actionText := "MANAGE SELL"
    actionBg := cSell
    reasonText := "Trade active"
else if showClosedTrade
    actionText := lastClosedResult
    actionBg := str.contains(lastClosedResult, "SL") ? cSL : str.contains(lastClosedResult, "WIN") ? cTP : cClose
    reasonText := "Last trade closed"
else if nearNews
    actionText := "NEWS - WAIT"
    actionBg := color.orange
    reasonText := "News block"
else if not sessionOK
    actionText := "WAIT"
    actionBg := color.orange
    reasonText := "Outside session"
else if buySignal
    actionText := "BUY NOW"
    actionBg := cBuy
    reasonText := "Trend + LQ + momentum"
else if sellSignal
    actionText := "SELL NOW"
    actionBg := cSell
    reasonText := "Trend + LQ + momentum"
else if buyQuality >= qThreshold and buyQuality > sellQuality
    actionText := "BUY SETUP - WAIT"
    actionBg := color.new(cBuy, 40)
    reasonText := "Waiting trigger"
else if sellQuality >= qThreshold and sellQuality > buyQuality
    actionText := "SELL SETUP - WAIT"
    actionBg := color.new(cSell, 40)
    reasonText := "Waiting trigger"

displaySide = activeTrade != 0 ? activeTrade : showClosedTrade ? lastClosedSide : 0
displayEntry = activeTrade != 0 ? activeEntry : showClosedTrade ? lastClosedEntry : na
displaySL = activeTrade != 0 ? activeSL : showClosedTrade ? lastClosedSL : na
displayTP1 = activeTrade != 0 ? activeTP1 : showClosedTrade ? lastClosedTP1 : na
displayTP2 = activeTrade != 0 ? activeTP2 : showClosedTrade ? lastClosedTP2 : na
displayTP3 = activeTrade != 0 ? activeTP3 : showClosedTrade ? lastClosedTP3 : na
displayQuality = activeTrade != 0 ? activeQuality : showClosedTrade ? lastClosedQuality : math.max(buyQuality, sellQuality)
displayResult = showClosedTrade ? lastClosedResult : lastResult

tableTrade = displaySide == 1 ? (activeTrade != 0 ? "BUY" : "BUY CLOSED") : displaySide == -1 ? (activeTrade != 0 ? "SELL" : "SELL CLOSED") : "NONE"
entryText = displaySide != 0 ? f_price(displayEntry) : "-"
slText = displaySide != 0 ? f_price(displaySL) : "-"
tpText = displaySide != 0 ? f_price(displayTP1) + " / " + f_price(displayTP2) + " / " + f_price(displayTP3) : "-"
qualityNow = displayQuality
qualityGrade = qualityNow >= 90 ? "A+" : qualityNow >= 80 ? "A" : qualityNow >= 70 ? "B" : "WAIT"

trendText = htfBull ? "Bullish" : htfBear ? "Bearish" : "Neutral"
dxyText = dxyBull ? "Bullish / helps sell" : dxyBear ? "Bearish / helps buy" : "Neutral"
liqText = bullLQ ? "Buy sweep" : bearLQ ? "Sell sweep" : "None"
fibText = inBullFib ? "Buy GP" : inBearFib ? "Sell GP" : "Outside"
momentumText = bullMomentum ? "Bullish" : bearMomentum ? "Bearish" : "Mixed"
sessionText = inLondon ? "London" : inNY ? "NY" : "Outside"

var table dash = table.new(position.top_right, 2, 14, border_width=1)

if barstate.islast
    table.cell(dash, 0, 0, "GM v12", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(dash, 1, 0, "TRADE STATUS", text_color=color.white, bgcolor=color.black, text_size=size.small)

    table.cell(dash, 0, 1, "Action", text_color=color.white, bgcolor=cDark, text_size=size.small)
    table.cell(dash, 1, 1, actionText, text_color=color.black, bgcolor=actionBg, text_size=size.small)

    table.cell(dash, 0, 2, "Quality", text_color=color.white, bgcolor=cDark, text_size=size.small)
    table.cell(dash, 1, 2, qualityGrade + " / " + str.tostring(qualityNow) + "%", text_color=color.white, bgcolor=qualityNow >= 80 ? cBuy : qualityNow >= 70 ? color.blue : cMuted, text_size=size.small)

    table.cell(dash, 0, 3, "Reason", text_color=color.white, bgcolor=cDark, text_size=size.small)
    table.cell(dash, 1, 3, reasonText, text_color=color.white, bgcolor=color.new(color.blue, 45), text_size=size.small)

    table.cell(dash, 0, 4, "Trade", text_color=color.white, bgcolor=cDark, text_size=size.small)
    table.cell(dash, 1, 4, tableTrade, text_color=color.white, bgcolor=displaySide == 1 ? cBuy : displaySide == -1 ? cSell : cMuted, text_size=size.small)

    table.cell(dash, 0, 5, "Entry", text_color=color.white, bgcolor=cDark, text_size=size.small)
    table.cell(dash, 1, 5, entryText, text_color=color.black, bgcolor=color.new(color.white, 10), text_size=size.small)

    table.cell(dash, 0, 6, "SL", text_color=color.white, bgcolor=cDark, text_size=size.small)
    table.cell(dash, 1, 6, slText, text_color=color.white, bgcolor=color.new(cSL, 10), text_size=size.small)

    table.cell(dash, 0, 7, "TP1/2/3", text_color=color.white, bgcolor=cDark, text_size=size.small)
    table.cell(dash, 1, 7, tpText, text_color=color.white, bgcolor=color.new(cTP, 10), text_size=size.small)

    table.cell(dash, 0, 8, "Last Result", text_color=color.white, bgcolor=cDark, text_size=size.small)
    table.cell(dash, 1, 8, displayResult, text_color=color.white, bgcolor=color.new(color.blue, 35), text_size=size.small)

    table.cell(dash, 0, 9, "4H Trend", text_color=color.white, bgcolor=cDark, text_size=size.small)
    table.cell(dash, 1, 9, trendText, text_color=color.white, bgcolor=htfBull ? cBuy : htfBear ? cSell : cMuted, text_size=size.small)

    table.cell(dash, 0, 10, "DXY", text_color=color.white, bgcolor=cDark, text_size=size.small)
    table.cell(dash, 1, 10, dxyText, text_color=color.white, bgcolor=dxyBull ? cSell : dxyBear ? cBuy : cMuted, text_size=size.small)

    table.cell(dash, 0, 11, "Liquidity", text_color=color.white, bgcolor=cDark, text_size=size.small)
    table.cell(dash, 1, 11, liqText, text_color=color.white, bgcolor=bullLQ ? cBuy : bearLQ ? cSell : cMuted, text_size=size.small)

    table.cell(dash, 0, 12, "Fib 61.8-65", text_color=color.white, bgcolor=cDark, text_size=size.small)
    table.cell(dash, 1, 12, fibText, text_color=color.white, bgcolor=inBullFib ? cBuy : inBearFib ? cSell : cMuted, text_size=size.small)

    table.cell(dash, 0, 13, "Momentum", text_color=color.white, bgcolor=cDark, text_size=size.small)
    table.cell(dash, 1, 13, momentumText + " | " + sessionText, text_color=color.white, bgcolor=bullMomentum ? cBuy : bearMomentum ? cSell : cMuted, text_size=size.small)

// ============================================================
// ALERTS
// ============================================================

alertcondition(startLong, title="GM v12 BUY", message="GM v12 BUY on XAUUSD")
alertcondition(startShort, title="GM v12 SELL", message="GM v12 SELL on XAUUSD")
alertcondition(bankTP1, title="GM v12 TP1", message="GM v12 TP1 hit")
alertcondition(bankTP2, title="GM v12 TP2", message="GM v12 TP2 hit")
alertcondition(closeTP3, title="GM v12 TP3", message="GM v12 TP3 hit")
alertcondition(closeSL, title="GM v12 SL", message="GM v12 SL hit")
alertcondition(closeEarly, title="GM v12 CLOSE", message="GM v12 close early")
````
