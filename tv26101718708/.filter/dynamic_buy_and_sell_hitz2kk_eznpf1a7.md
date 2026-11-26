# Dynamic Buy and Sell - Hitz2kk

- url: https://www.tradingview.com/script/eZnPf1a7-Dynamic-Buy-and-Sell-Hitz2kk/
- type: indicator
- pine_id: PUB;6a13e37104fb4bae9599d27db2534a6f
- version: 1.0

## Description

Dynamic Buy and Sell — by @hitz2kk
Dynamic Buy and Sell is an all-in-one trend and signal indicator that combines a volatility-adjusted EMA ribbon, a five-timeframe trend dashboard, a configurable entry engine, and built-in ATR risk levels — all overlaid directly on price.
What it does
The core is a trend ribbon built from a fast and slow EMA with an ATR band drawn around the midline. The ribbon shades green when structure is bullish and red when bearish, and the band expands and contracts with volatility so it adapts to current conditions instead of using fixed offsets.
A multi-timeframe dashboard in the top-right reads the EMA trend across 15-minute, 1-hour, 4-hour, daily, and weekly charts. Above it, a Trend Confidence score (0–100%) blends the local trend, RSI, price position relative to the ribbon, and all five higher-timeframe trends into a single conviction reading — green at 70%+, orange at 50–69%, red below.
BUY and SELL labels print only when conditions align: the ribbon trend agrees, the fast EMA slopes in the signal's direction, RSI is on the correct side of its threshold, and your chosen entry trigger fires.
Key features

Three entry modes: Ribbon Breakout (momentum), Candlestick (engulfing and pin-bar reversals), or Either
Optional volume and MACD confirmation filters to tighten signals
ATR-based stop and target levels plotted on every signal, with adjustable risk:reward
Live win-rate tally that tracks how signals resolved against their stop/target
Five-timeframe trend dashboard with an aggregated confidence score
Configurable EMA, RSI, ATR, and threshold inputs

How to use it
Choose your trigger mode in settings. Use the dashboard and confidence score to read the broader environment, then act on labels that print in the direction of that bias. Higher-confidence signals backed by aligned higher-timeframe trends are the stronger setups; signals firing against a red dashboard warrant caution. Enable the volume and MACD filters when you want fewer, higher-conviction signals.
Notes
All calculations run on confirmed bars and higher-timeframe data uses lookahead-off, so signals and the dashboard do not repaint after a bar closes. The win-rate tally is an on-chart estimate based on bar highs and lows, not a precise backtest — for exact statistics, run a strategy version through TradingView's tester. This is a decision-support tool, not a standalone system; test settings on your own instrument and timeframe and always apply your own risk management.
This script is original and provided for educational purposes. Nothing here is financial advice.

## Source Code

````pine
//──────────────────────────────────────────────────────────────────────────────
//  DYNAMIC BUY AND SELL - Hitz2kk
//  Multi-timeframe trend ribbon + multi-filter signal engine
//  with ATR stop/target levels and live win-rate tally
//  Author: @hitz2kk
//──────────────────────────────────────────────────────────────────────────────
//@version=6
indicator("Dynamic Buy and Sell - Hitz2kk", overlay=true, max_labels_count=200, max_lines_count=50)

//──────────────────────────────────────────────────────────────────────────────
// INPUTS
//──────────────────────────────────────────────────────────────────────────────
groupTrend = "Trend Settings"
fastLen    = input.int(21, "Fast EMA Length", minval=1, group=groupTrend)
slowLen    = input.int(55, "Slow EMA Length", minval=2, group=groupTrend)
atrLen     = input.int(14, "ATR Length", minval=1, group=groupTrend)
atrMult    = input.float(0.80, "Ribbon ATR Multiplier", minval=0.1, step=0.1, group=groupTrend)

groupSignal = "Signal Settings"
rsiLen      = input.int(14, "RSI Length", minval=1, group=groupSignal)
bullRsiMin  = input.int(52, "Bullish RSI Threshold", minval=1, maxval=100, group=groupSignal)
bearRsiMax  = input.int(48, "Bearish RSI Threshold", minval=1, maxval=100, group=groupSignal)
showSignals = input.bool(true, "Show BUY/SELL Signals", group=groupSignal)

groupEntry  = "Entry Triggers"
sigMode     = input.string("Ribbon breakout", "Trigger mode", options=["Ribbon breakout", "Candlestick", "Either"], group=groupEntry)
pinWick     = input.float(2.0, "Pin bar wick-to-body ratio", minval=0.5, step=0.1, group=groupEntry)

groupFilter = "Confirmation Filters"
useVol      = input.bool(false, "Require volume confirmation", group=groupFilter)
volLen      = input.int(20, "Volume MA length", minval=1, group=groupFilter)
volMult     = input.float(1.0, "Min volume vs MA", minval=0.1, step=0.1, group=groupFilter)
useMacd     = input.bool(false, "Require MACD confirmation", group=groupFilter)
macdFast    = input.int(12, "MACD fast", minval=1, group=groupFilter)
macdSlow    = input.int(26, "MACD slow", minval=2, group=groupFilter)
macdSig     = input.int(9,  "MACD signal", minval=1, group=groupFilter)

groupRisk   = "Stop / Target (ATR)"
showLevels  = input.bool(true, "Show stop/target levels", group=groupRisk)
stopMult    = input.float(1.5, "Stop ATR multiplier", minval=0.1, step=0.1, group=groupRisk)
rrRatio     = input.float(2.0, "Risk:Reward ratio", minval=0.1, step=0.1, group=groupRisk)

groupDisplay = "Display"
showDashboard = input.bool(true, "Show Dashboard", group=groupDisplay)
showWinRate   = input.bool(true, "Show Win-Rate Tally", group=groupDisplay)
showFastEMA   = input.bool(false, "Show Fast EMA", group=groupDisplay)
showSlowEMA   = input.bool(false, "Show Slow EMA", group=groupDisplay)
showRibbonMid = input.bool(false, "Show Ribbon Midline", group=groupDisplay)

//──────────────────────────────────────────────────────────────────────────────
// CORE CALCULATIONS
//──────────────────────────────────────────────────────────────────────────────
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
rsiVal  = ta.rsi(close, rsiLen)
atrVal  = ta.atr(atrLen)

ribbonMid   = (emaFast + emaSlow) / 2.0
ribbonUpper = ribbonMid + atrVal * atrMult
ribbonLower = ribbonMid - atrVal * atrMult

trendBull = emaFast > emaSlow
trendBear = emaFast < emaSlow

emaFastRising  = emaFast > emaFast[1]
emaFastFalling = emaFast < emaFast[1]

//──────────────────────────────────────────────────────────────────────────────
// ENTRY TRIGGERS
//──────────────────────────────────────────────────────────────────────────────
breakoutLong  = ta.crossover(close, ribbonUpper)
breakoutShort = ta.crossunder(close, ribbonLower)

body   = math.abs(close - open)
upWick = high - math.max(close, open)
dnWick = math.min(close, open) - low

bullEngulf = close > open and close[1] < open[1] and close >= open[1] and open <= close[1]
bearEngulf = close < open and close[1] > open[1] and close <= open[1] and open >= close[1]
bullPin    = dnWick > body * pinWick and upWick < body and close > open
bearPin    = upWick > body * pinWick and dnWick < body and close < open

candleLong  = bullEngulf or bullPin
candleShort = bearEngulf or bearPin

trigLong  = sigMode == "Ribbon breakout" ? breakoutLong  : sigMode == "Candlestick" ? candleLong  : (breakoutLong  or candleLong)
trigShort = sigMode == "Ribbon breakout" ? breakoutShort : sigMode == "Candlestick" ? candleShort : (breakoutShort or candleShort)

//──────────────────────────────────────────────────────────────────────────────
// CONFIRMATION FILTERS
//──────────────────────────────────────────────────────────────────────────────
volMa = ta.sma(volume, volLen)
volOk = not useVol or volume > volMa * volMult

[macdLine, signalLine, _] = ta.macd(close, macdFast, macdSlow, macdSig)
macdOkL = not useMacd or macdLine > signalLine
macdOkS = not useMacd or macdLine < signalLine

//──────────────────────────────────────────────────────────────────────────────
// FINAL SIGNALS
//──────────────────────────────────────────────────────────────────────────────
buySignal  = showSignals and trendBull and emaFastRising  and rsiVal >= bullRsiMin and trigLong  and volOk and macdOkL
sellSignal = showSignals and trendBear and emaFastFalling and rsiVal <= bearRsiMax and trigShort and volOk and macdOkS

//──────────────────────────────────────────────────────────────────────────────
// ATR STOP / TARGET LEVELS
//──────────────────────────────────────────────────────────────────────────────
var float longStop  = na
var float longTgt   = na
var float shortStop = na
var float shortTgt  = na

if buySignal
    longStop := close - atrVal * stopMult
    longTgt  := close + atrVal * stopMult * rrRatio
if sellSignal
    shortStop := close + atrVal * stopMult
    shortTgt  := close - atrVal * stopMult * rrRatio

plot(showLevels and not na(longStop) ? longStop : na, "Long Stop", color=color.new(color.red, 30), style=plot.style_linebr, linewidth=1)
plot(showLevels and not na(longTgt)  ? longTgt  : na, "Long Target", color=color.new(color.green, 30), style=plot.style_linebr, linewidth=1)
plot(showLevels and not na(shortStop) ? shortStop : na, "Short Stop", color=color.new(color.red, 30), style=plot.style_linebr, linewidth=1)
plot(showLevels and not na(shortTgt)  ? shortTgt  : na, "Short Target", color=color.new(color.green, 30), style=plot.style_linebr, linewidth=1)

//──────────────────────────────────────────────────────────────────────────────
// WIN-RATE TALLY
//  An open trade is resolved when price hits the target (win) or stop (loss).
//  One position tracked at a time; new signals are ignored while a trade is open.
//──────────────────────────────────────────────────────────────────────────────
var int   tradeDir   = 0       // 0 = flat, 1 = long, -1 = short
var float entryStop  = na
var float entryTgt   = na
var int   wins       = 0
var int   losses     = 0

if tradeDir == 0
    if buySignal
        tradeDir  := 1
        entryStop := close - atrVal * stopMult
        entryTgt  := close + atrVal * stopMult * rrRatio
    else if sellSignal
        tradeDir  := -1
        entryStop := close + atrVal * stopMult
        entryTgt  := close - atrVal * stopMult * rrRatio
else if tradeDir == 1
    if high >= entryTgt
        wins  += 1
        tradeDir := 0
    else if low <= entryStop
        losses += 1
        tradeDir := 0
else if tradeDir == -1
    if low <= entryTgt
        wins  += 1
        tradeDir := 0
    else if high >= entryStop
        losses += 1
        tradeDir := 0

totalTrades = wins + losses
winRate     = totalTrades > 0 ? math.round(wins / totalTrades * 100.0) : 0

//──────────────────────────────────────────────────────────────────────────────
// PLOTS
//──────────────────────────────────────────────────────────────────────────────
bullFill = color.new(color.lime, 74)
bearFill = color.new(color.red, 76)
midColor = trendBull ? color.new(color.lime, 20) : color.new(color.red, 20)

pUpper = plot(ribbonUpper, "Ribbon Upper", color=color.new(color.white, 100), linewidth=1)
pLower = plot(ribbonLower, "Ribbon Lower", color=color.new(color.white, 100), linewidth=1)
fill(pUpper, pLower, color=trendBull ? bullFill : bearFill, title="Trend Ribbon")

plot(showRibbonMid ? ribbonMid : na, "Ribbon Midline", color=midColor, linewidth=2)
plot(showFastEMA ? emaFast : na, "Fast EMA", color=color.new(color.green, 0), linewidth=2)
plot(showSlowEMA ? emaSlow : na, "Slow EMA", color=color.new(color.red, 0), linewidth=2)

plotshape(buySignal, title="BUY Signal", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.white, text="BUY", size=size.small)
plotshape(sellSignal, title="SELL Signal", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, text="SELL", size=size.small)

alertcondition(buySignal, title="BUY Alert", message="Dynamic Buy and Sell - BUY signal on {{ticker}}")
alertcondition(sellSignal, title="SELL Alert", message="Dynamic Buy and Sell - SELL signal on {{ticker}}")

//──────────────────────────────────────────────────────────────────────────────
// MTF TREND FUNCTIONS
//──────────────────────────────────────────────────────────────────────────────
f_mtfTrend(_tf) =>
    fastTf = request.security(syminfo.tickerid, _tf, ta.ema(close, fastLen), lookahead=barmerge.lookahead_off)
    slowTf = request.security(syminfo.tickerid, _tf, ta.ema(close, slowLen), lookahead=barmerge.lookahead_off)
    fastTf > slowTf ? 1 : -1

f_trendText(_v) =>
    _v == 1 ? "BULLISH" : "BEARISH"

f_trendBg(_v) =>
    _v == 1 ? color.new(color.green, 0) : color.new(color.red, 0)

trend15m = f_mtfTrend("15")
trend1h  = f_mtfTrend("60")
trend4h  = f_mtfTrend("240")
trendD   = f_mtfTrend("D")
trendW   = f_mtfTrend("W")

//──────────────────────────────────────────────────────────────────────────────
// CONFIDENCE SCORE
//──────────────────────────────────────────────────────────────────────────────
score = 0.0
score += trendBull ? 20 : 0
score += rsiVal >= 50 ? 15 : 0
score += close > ribbonMid ? 15 : 0
score += trend15m == 1 ? 10 : 0
score += trend1h  == 1 ? 10 : 0
score += trend4h  == 1 ? 15 : 0
score += trendD   == 1 ? 15 : 0
score += trendW   == 1 ? 15 : 0

scoreRounded = math.round(score)
rsiRounded   = math.round(rsiVal * 100.0) / 100.0
atrRounded   = math.round(atrVal * 100.0) / 100.0

confidenceBg = scoreRounded >= 70 ? color.new(color.green, 0) : scoreRounded >= 50 ? color.new(color.orange, 0) : color.new(color.red, 0)

//──────────────────────────────────────────────────────────────────────────────
// DASHBOARD
//──────────────────────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 9, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "Trend Confidence", text_color=color.white, bgcolor=color.new(color.gray, 35), text_size=size.small)
    table.cell(dash, 1, 0, str.tostring(scoreRounded) + "%", text_color=color.white, bgcolor=confidenceBg, text_size=size.small)
    table.cell(dash, 0, 1, "Trend 15M", text_color=color.white, bgcolor=color.new(color.gray, 55), text_size=size.small)
    table.cell(dash, 1, 1, f_trendText(trend15m), text_color=color.white, bgcolor=f_trendBg(trend15m), text_size=size.small)
    table.cell(dash, 0, 2, "Trend 1H", text_color=color.white, bgcolor=color.new(color.gray, 55), text_size=size.small)
    table.cell(dash, 1, 2, f_trendText(trend1h), text_color=color.white, bgcolor=f_trendBg(trend1h), text_size=size.small)
    table.cell(dash, 0, 3, "Trend 4H", text_color=color.white, bgcolor=color.new(color.gray, 55), text_size=size.small)
    table.cell(dash, 1, 3, f_trendText(trend4h), text_color=color.white, bgcolor=f_trendBg(trend4h), text_size=size.small)
    table.cell(dash, 0, 4, "Trend Daily", text_color=color.white, bgcolor=color.new(color.gray, 55), text_size=size.small)
    table.cell(dash, 1, 4, f_trendText(trendD), text_color=color.white, bgcolor=f_trendBg(trendD), text_size=size.small)
    table.cell(dash, 0, 5, "Trend Weekly", text_color=color.white, bgcolor=color.new(color.gray, 55), text_size=size.small)
    table.cell(dash, 1, 5, f_trendText(trendW), text_color=color.white, bgcolor=f_trendBg(trendW), text_size=size.small)
    table.cell(dash, 0, 6, "RSI", text_color=color.white, bgcolor=color.new(color.gray, 55), text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(rsiRounded), text_color=color.white, bgcolor=color.new(color.gray, 25), text_size=size.small)
    table.cell(dash, 0, 7, "Volatility (ATR)", text_color=color.white, bgcolor=color.new(color.gray, 55), text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(atrRounded), text_color=color.white, bgcolor=color.new(color.gray, 25), text_size=size.small)
    winBg = winRate >= 60 ? color.new(color.green, 0) : winRate >= 40 ? color.new(color.orange, 0) : color.new(color.red, 0)
    winTxt = showWinRate ? str.tostring(winRate) + "% (" + str.tostring(wins) + "/" + str.tostring(totalTrades) + ")" : "off"
    table.cell(dash, 0, 8, "Win Rate", text_color=color.white, bgcolor=color.new(color.gray, 55), text_size=size.small)
    table.cell(dash, 1, 8, winTxt, text_color=color.white, bgcolor=showWinRate ? winBg : color.new(color.gray, 25), text_size=size.small)

//──────────────────────────────────────────────────────────────────────────────
// HALLMARK / WATERMARK
//──────────────────────────────────────────────────────────────────────────────
var table mark = table.new(position.bottom_left, 1, 1, border_width=0)

if barstate.islast
    table.cell(mark, 0, 0, "@hitz2kk", text_color=color.new(color.silver, 35), bgcolor=color.new(color.black, 100), text_size=size.tiny)
````
