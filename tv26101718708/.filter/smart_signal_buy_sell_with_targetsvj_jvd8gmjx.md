# Smart Signal- BUY SELL with Targets-VJ

- url: https://www.tradingview.com/script/jVd8GmjX-Smart-Signal-BUY-SELL-with-Targets-VJ/
- type: indicator
- pine_id: PUB;5d7527a7395a466f94c5048139099f78
- version: 2.0

## Description

Smart Signal — BUY / SELL with Target

Trend analysis for Scalping, short term or long term

Visibility to see 3 Target Prices

## Source Code

````pine
//@version=6
indicator(title="Smart Signal - BUY / SELL with Targets", shorttitle="SmartSig", overlay=true, max_labels_count=500, max_lines_count=500)

// ---------------------------------------------------------------
// GROUP: TRADING MODE
// ---------------------------------------------------------------
grp_mode  = "Trading Mode"
tradeMode = input.string("Short Term", "Trading Mode", options=["Scalping", "Short Term", "Long Term"], group=grp_mode,
            tooltip="Scalping = tight TP/SL, fast signals.\nShort Term = swing-based.\nLong Term = trend-following with wide targets.")

// ---------------------------------------------------------------
// GROUP: 5 / 9 EMA CROSS TIMING
// ---------------------------------------------------------------
grp_59      = "5 / 9 EMA Cross Timing"
use59       = input.bool(true,  "Enable 5/9 EMA Cross Filter", group=grp_59,
              tooltip="Adds a 5 & 9 EMA cross condition to every buy/sell signal.")
ema5Len     = input.int(5,      "Fast EMA Length", minval=2, maxval=20, group=grp_59)
ema9Len     = input.int(9,      "Slow EMA Length", minval=3, maxval=50, group=grp_59)
crossTiming = input.string("After Cross", "Signal Timing", options=["After Cross", "Before Cross", "Both"], group=grp_59,
              tooltip="After Cross: confirmed 5/9 EMA crossover.\nBefore Cross: anticipatory - 5 EMA converging toward 9 EMA.\nBoth: either condition qualifies.")
convThresh  = input.float(0.20, "Pre-Cross Convergence (ATR x)", minval=0.05, step=0.05, group=grp_59,
              tooltip="Before Cross mode: fires when the 5/9 EMA gap is smaller than this ATR multiple and still closing.")

// ---------------------------------------------------------------
// GROUP: SIGNAL FILTERS
// ---------------------------------------------------------------
grp_sig   = "Signal Filters"
rsiLen    = input.int(14,    "RSI Length",        minval=2,  group=grp_sig)
rsiOB     = input.int(70,    "RSI Overbought",    minval=60, group=grp_sig)
rsiOS     = input.int(30,    "RSI Oversold",      maxval=45, group=grp_sig)
maFast    = input.int(9,     "Fast MA",           minval=2,  group=grp_sig)
maSlow    = input.int(21,    "Slow MA",           minval=5,  group=grp_sig)
maTrend   = input.int(200,   "Trend MA (filter)", minval=50, group=grp_sig)
useTrend  = input.bool(true, "Use Trend Filter",  group=grp_sig,
            tooltip="Only show BUY above trend MA, SELL below trend MA.")
useVolume = input.bool(true, "Require Volume Spike", group=grp_sig,
            tooltip="Signal only fires when volume > 20-bar average.")
minBody   = input.float(0.3, "Min Body %", minval=0.0, step=0.1, group=grp_sig,
            tooltip="Minimum candle body as % of range to filter doji candles.")

// ---------------------------------------------------------------
// GROUP: TARGET & STOP
// ---------------------------------------------------------------
grp_tp     = "Target & Stop"
atrLen     = input.int(14,   "ATR Length",        minval=1,  group=grp_tp)
atrMult_sl = input.float(1.5,"Stop Loss (ATR x)", minval=0.1, step=0.1, group=grp_tp)
tp1Mult    = input.float(1.5,"Target 1 (ATR x)",  minval=0.1, step=0.1, group=grp_tp)
tp2Mult    = input.float(2.5,"Target 2 (ATR x)",  minval=0.1, step=0.1, group=grp_tp)
tp3Mult    = input.float(4.0,"Target 3 (ATR x)",  minval=0.1, step=0.1, group=grp_tp)
showLines  = input.bool(true, "Show TP / SL lines", group=grp_tp)
lineBars   = input.int(20,   "Line length (bars)", minval=5, maxval=100, group=grp_tp)

// ---------------------------------------------------------------
// GROUP: DISPLAY
// ---------------------------------------------------------------
grp_disp  = "Display"
showLabel = input.bool(true, "Show BUY / SELL labels",   group=grp_disp)
showTable = input.bool(true, "Show signal info table",   group=grp_disp)
showBg    = input.bool(true, "Bar background highlight", group=grp_disp)
lblOffset = input.int(2,     "Label ATR offset", minval=1, maxval=10, group=grp_disp)

// ---------------------------------------------------------------
// CORE CALCULATIONS
// ---------------------------------------------------------------
atr    = ta.atr(atrLen)
rsi    = ta.rsi(close, rsiLen)
ema_f  = ta.ema(close, maFast)
ema_s  = ta.ema(close, maSlow)
ema_t  = ta.ema(close, maTrend)
volAvg = ta.sma(volume, 20)
ema5   = ta.ema(close, ema5Len)
ema9   = ta.ema(close, ema9Len)

[macdLine, signalLine, _macdHist] = ta.macd(close, 12, 26, 9)

stoch_k = ta.sma(ta.stoch(close, high, low, 14), 3)
stoch_d = ta.sma(stoch_k, 3)

// ---------------------------------------------------------------
// HELPER FUNCTIONS
// ---------------------------------------------------------------
bodyPct(int i) =>
    rng = high[i] - low[i]
    rng == 0 ? 0.0 : math.abs(close[i] - open[i]) / rng * 100.0

rrStr(float entry, float tp, float sl, bool isBuy) =>
    risk   = isBuy ? entry - sl : sl - entry
    reward = isBuy ? tp - entry : entry - tp
    risk <= 0.0 ? "n/a" : str.tostring(math.round(reward / risk, 1)) + "R"

// ---------------------------------------------------------------
// FILTERS
// ---------------------------------------------------------------
volSpike   = not useVolume or volume > volAvg * 1.2
aboveTrend = not useTrend or close > ema_t
belowTrend = not useTrend or close < ema_t

// Mode-adjusted ATR multipliers  (each ternary kept on one line - v6 safe)
slMult = tradeMode == "Scalping" ? atrMult_sl * 0.6 : tradeMode == "Long Term" ? atrMult_sl * 1.8 : atrMult_sl
t1Mult = tradeMode == "Scalping" ? tp1Mult * 0.6    : tradeMode == "Long Term" ? tp1Mult * 2.0    : tp1Mult
t2Mult = tradeMode == "Scalping" ? tp2Mult * 0.6    : tradeMode == "Long Term" ? tp2Mult * 2.0    : tp2Mult
t3Mult = tradeMode == "Scalping" ? tp3Mult * 0.6    : tradeMode == "Long Term" ? tp3Mult * 2.0    : tp3Mult

// ---------------------------------------------------------------
// 5 / 9 EMA CROSS CONDITIONS
// ---------------------------------------------------------------
afterCross_buy  = ta.crossover(ema5, ema9)
afterCross_sell = ta.crossunder(ema5, ema9)

ema_gap        = ema5 - ema9
gapAbs         = math.abs(ema_gap)
withinATR      = gapAbs < atr * convThresh
gapShrink_bull = ema_gap < 0.0 and ema_gap > ema_gap[1]
gapShrink_bear = ema_gap > 0.0 and ema_gap < ema_gap[1]
preCross_buy   = gapShrink_bull and withinATR
preCross_sell  = gapShrink_bear and withinATR

// Combined 5/9 gate - each on one line to avoid v6 continuation issues
_gate59_buy_after  = afterCross_buy
_gate59_buy_before = preCross_buy
_gate59_buy_both   = afterCross_buy or preCross_buy
cond59_buy  = not use59 or (crossTiming == "After Cross" ? _gate59_buy_after : crossTiming == "Before Cross" ? _gate59_buy_before : _gate59_buy_both)

_gate59_sell_after  = afterCross_sell
_gate59_sell_before = preCross_sell
_gate59_sell_both   = afterCross_sell or preCross_sell
cond59_sell = not use59 or (crossTiming == "After Cross" ? _gate59_sell_after : crossTiming == "Before Cross" ? _gate59_sell_before : _gate59_sell_both)

// Timing tag strings (single-line ternaries - v6 safe)
timingTagBuy  = not use59 ? "" : crossTiming == "After Cross" ? " | After 5x9 UP" : crossTiming == "Before Cross" ? " | Before 5x9 UP" : afterCross_buy ? " | After 5x9 UP" : " | Before 5x9 UP"
timingTagSell = not use59 ? "" : crossTiming == "After Cross" ? " | After 5x9 DN" : crossTiming == "Before Cross" ? " | Before 5x9 DN" : afterCross_sell ? " | After 5x9 DN" : " | Before 5x9 DN"

// ---------------------------------------------------------------
// CORE BUY CONDITIONS
// ---------------------------------------------------------------
bullCandle = close > open and bodyPct(0) >= minBody
emaXup     = ta.crossover(ema_f, ema_s)
rsiOsRecov = ta.crossover(rsi, rsiOS)
macdBull   = ta.crossover(macdLine, signalLine)
stochBull  = ta.crossover(stoch_k, stoch_d) and stoch_k < 20.0

buyScalp  = bullCandle and (emaXup or rsiOsRecov or stochBull) and volSpike and aboveTrend and cond59_buy
buyShort  = (emaXup or macdBull) and rsi < 60.0 and bullCandle and volSpike and aboveTrend and cond59_buy
buyLong   = emaXup and macdBull and rsi > 40.0 and rsi < 65.0 and aboveTrend and volSpike and cond59_buy
buySignal = tradeMode == "Scalping" ? buyScalp : tradeMode == "Long Term" ? buyLong : buyShort

// ---------------------------------------------------------------
// CORE SELL CONDITIONS
// ---------------------------------------------------------------
bearCandle = close < open and bodyPct(0) >= minBody
emaXdn     = ta.crossunder(ema_f, ema_s)
rsiObFall  = ta.crossunder(rsi, rsiOB)
macdBear   = ta.crossunder(macdLine, signalLine)
stochBear  = ta.crossunder(stoch_k, stoch_d) and stoch_k > 80.0

sellScalp  = bearCandle and (emaXdn or rsiObFall or stochBear) and volSpike and belowTrend and cond59_sell
sellShort  = (emaXdn or macdBear) and rsi > 40.0 and bearCandle and volSpike and belowTrend and cond59_sell
sellLong   = emaXdn and macdBear and rsi < 60.0 and rsi > 35.0 and belowTrend and volSpike and cond59_sell
sellSignal = tradeMode == "Scalping" ? sellScalp : tradeMode == "Long Term" ? sellLong : sellShort

// ---------------------------------------------------------------
// TARGET & STOP LEVELS
// ---------------------------------------------------------------
minTick   = syminfo.mintick
buyEntry  = close
buy_sl    = math.max(minTick, buyEntry - atr * slMult)
buy_tp1   = buyEntry + atr * t1Mult
buy_tp2   = buyEntry + atr * t2Mult
buy_tp3   = buyEntry + atr * t3Mult

sellEntry = close
sell_sl   = sellEntry + atr * slMult
sell_tp1  = math.max(minTick, sellEntry - atr * t1Mult)
sell_tp2  = math.max(minTick, sellEntry - atr * t2Mult)
sell_tp3  = math.max(minTick, sellEntry - atr * t3Mult)

// ---------------------------------------------------------------
// LINES: TP1 / TP2 / TP3 / SL
// ---------------------------------------------------------------
drawLine(float y, color clr, string sty) =>
    line.new(bar_index, y, bar_index + lineBars, y, color=clr, style=sty, width=1, extend=extend.none)

if showLines
    if buySignal
        drawLine(buy_tp1, color.new(color.green, 30), line.style_dashed)
        drawLine(buy_tp2, color.new(color.green, 10), line.style_dashed)
        drawLine(buy_tp3, color.new(color.green,  0), line.style_solid)
        drawLine(buy_sl,  color.new(color.red,   20), line.style_dotted)
    if sellSignal
        drawLine(sell_tp1, color.new(color.orange, 30), line.style_dashed)
        drawLine(sell_tp2, color.new(color.orange, 10), line.style_dashed)
        drawLine(sell_tp3, color.new(color.orange,  0), line.style_solid)
        drawLine(sell_sl,  color.new(color.red,    20), line.style_dotted)

// ---------------------------------------------------------------
// LABELS
// ---------------------------------------------------------------
buyLabelY  = math.max(minTick, low  - atr * lblOffset)
sellLabelY = high + atr * lblOffset

if showLabel and buySignal
    lbl = "BUY [" + tradeMode + "]" + timingTagBuy + "\n" +
          "Entry : " + str.tostring(buyEntry, format.mintick) + "\n" +
          "SL    : " + str.tostring(buy_sl,   format.mintick) + "\n" +
          "TP 1  : " + str.tostring(buy_tp1,  format.mintick) + "  (" + rrStr(buyEntry, buy_tp1, buy_sl, true) + ")\n" +
          "TP 2  : " + str.tostring(buy_tp2,  format.mintick) + "  (" + rrStr(buyEntry, buy_tp2, buy_sl, true) + ")\n" +
          "TP 3  : " + str.tostring(buy_tp3,  format.mintick) + "  (" + rrStr(buyEntry, buy_tp3, buy_sl, true) + ")"
    label.new(bar_index, buyLabelY, text=lbl, color=color.new(color.green, 5),
              textcolor=color.white, style=label.style_label_up, size=size.normal)

if showLabel and sellSignal
    lbl = "SELL [" + tradeMode + "]" + timingTagSell + "\n" +
          "Entry : " + str.tostring(sellEntry, format.mintick) + "\n" +
          "SL    : " + str.tostring(sell_sl,   format.mintick) + "\n" +
          "TP 1  : " + str.tostring(sell_tp1,  format.mintick) + "  (" + rrStr(sellEntry, sell_tp1, sell_sl, false) + ")\n" +
          "TP 2  : " + str.tostring(sell_tp2,  format.mintick) + "  (" + rrStr(sellEntry, sell_tp2, sell_sl, false) + ")\n" +
          "TP 3  : " + str.tostring(sell_tp3,  format.mintick) + "  (" + rrStr(sellEntry, sell_tp3, sell_sl, false) + ")"
    label.new(bar_index, sellLabelY, text=lbl, color=color.new(color.red, 5),
              textcolor=color.white, style=label.style_label_down, size=size.normal)

// ---------------------------------------------------------------
// SHAPES
// ---------------------------------------------------------------
plotshape(buySignal,  title="BUY",  style=shape.triangleup,   location=location.belowbar, color=color.new(color.green, 0), size=size.small)
plotshape(sellSignal, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.new(color.red,   0), size=size.small)
plotshape(use59 and preCross_buy  and not buySignal,  title="Pre-Cross BUY",  style=shape.circle, location=location.belowbar, color=color.new(color.aqua,    30), size=size.tiny)
plotshape(use59 and preCross_sell and not sellSignal, title="Pre-Cross SELL", style=shape.circle, location=location.abovebar, color=color.new(color.fuchsia, 30), size=size.tiny)

// ---------------------------------------------------------------
// BAR BACKGROUND
// ---------------------------------------------------------------
bgcolor(showBg and buySignal  ? color.new(color.green, 88) : na, title="BUY bg")
bgcolor(showBg and sellSignal ? color.new(color.red,   88) : na, title="SELL bg")
bgcolor(showBg and use59 and preCross_buy  and not buySignal  ? color.new(color.aqua,    93) : na, title="Pre-cross BUY bg")
bgcolor(showBg and use59 and preCross_sell and not sellSignal ? color.new(color.fuchsia, 93) : na, title="Pre-cross SELL bg")

// ---------------------------------------------------------------
// MOVING AVERAGE PLOTS
// ---------------------------------------------------------------
plot(ema5,  "EMA 5",     color=color.new(color.yellow, 20), linewidth=1)
plot(ema9,  "EMA 9",     color=color.new(color.purple, 20), linewidth=1)
plot(ema_f, "Fast EMA",  color=color.new(color.blue,   40), linewidth=1)
plot(ema_s, "Slow EMA",  color=color.new(color.orange, 40), linewidth=1)
plot(ema_t, "Trend EMA", color=color.new(color.gray,   50), linewidth=2)

// ---------------------------------------------------------------
// INFO TABLE
// ---------------------------------------------------------------
var table tbl = table.new(position.top_right, 2, 11,
                          bgcolor=color.new(color.black, 75),
                          border_color=color.new(color.gray, 60), border_width=1)

if showTable and barstate.islast
    table.cell(tbl, 0, 0, "Indicator",    text_color=color.gray,   text_size=size.small)
    table.cell(tbl, 1, 0, "Smart Signal", text_color=color.white,  text_size=size.small)
    table.cell(tbl, 0, 1, "Mode",         text_color=color.gray,   text_size=size.small)
    table.cell(tbl, 1, 1, tradeMode,      text_color=color.yellow, text_size=size.small)
    table.cell(tbl, 0, 2, "5/9 Filter",   text_color=color.gray,   text_size=size.small)
    table.cell(tbl, 1, 2, use59 ? crossTiming : "Off", text_color=use59 ? color.aqua : color.gray, text_size=size.small)
    table.cell(tbl, 0, 3, "5/9 Status",   text_color=color.gray,   text_size=size.small)
    _crossLbl = ema5 > ema9 ? "5 > 9  UP" : ema5 < ema9 ? "5 < 9  DN" : "At Cross"
    _crossClr = ema5 > ema9 ? color.green  : ema5 < ema9 ? color.red   : color.yellow
    table.cell(tbl, 1, 3, _crossLbl, text_color=_crossClr, text_size=size.small)
    table.cell(tbl, 0, 4, "5/9 Gap",      text_color=color.gray,   text_size=size.small)
    _gapPct = atr > 0.0 ? math.round(gapAbs / atr * 100.0, 1) : 0.0
    _gapClr = gapAbs < atr * convThresh ? color.yellow : color.white
    table.cell(tbl, 1, 4, str.tostring(_gapPct, "#.#") + "% ATR", text_color=_gapClr, text_size=size.small)
    table.cell(tbl, 0, 5, "RSI",          text_color=color.gray,   text_size=size.small)
    _rsiClr = rsi > rsiOB ? color.red : rsi < rsiOS ? color.green : color.white
    table.cell(tbl, 1, 5, str.tostring(math.round(rsi, 1)), text_color=_rsiClr, text_size=size.small)
    table.cell(tbl, 0, 6, "MACD",         text_color=color.gray,   text_size=size.small)
    table.cell(tbl, 1, 6, macdLine > signalLine ? "Bullish UP" : "Bearish DN", text_color=macdLine > signalLine ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 7, "EMA Trend",    text_color=color.gray,   text_size=size.small)
    table.cell(tbl, 1, 7, ema_f > ema_s ? "Up" : "Down", text_color=ema_f > ema_s ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 8, "Trend Filter", text_color=color.gray,   text_size=size.small)
    table.cell(tbl, 1, 8, close > ema_t ? "Above 200" : "Below 200", text_color=close > ema_t ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 9, "Volume",       text_color=color.gray,   text_size=size.small)
    table.cell(tbl, 1, 9, volume > volAvg * 1.2 ? "Spike" : "Normal", text_color=volume > volAvg * 1.2 ? color.green : color.gray, text_size=size.small)
    table.cell(tbl, 0, 10, "ATR",         text_color=color.gray,   text_size=size.small)
    table.cell(tbl, 1, 10, str.tostring(atr, format.mintick), text_color=color.white, text_size=size.small)

// ---------------------------------------------------------------
// ALERTS
// ---------------------------------------------------------------
alertcondition(buySignal, title="BUY Signal",
               message="BUY on {{ticker}} | TF: {{interval}} | Price: {{close}}")
alertcondition(sellSignal, title="SELL Signal",
               message="SELL on {{ticker}} | TF: {{interval}} | Price: {{close}}")
alertcondition(buySignal or sellSignal, title="Any Signal",
               message="Signal on {{ticker}} | TF: {{interval}} | Price: {{close}}")
alertcondition(use59 and preCross_buy, title="Pre-Cross BUY Setup",
               message="5/9 EMA converging bullish on {{ticker}} | TF: {{interval}} | Price: {{close}}")
alertcondition(use59 and preCross_sell, title="Pre-Cross SELL Setup",
               message="5/9 EMA converging bearish on {{ticker}} | TF: {{interval}} | Price: {{close}}")
````
