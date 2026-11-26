# Multi-Timeframe Buy/Sell Analyzer

- url: https://www.tradingview.com/script/AgumnDC1-Multi-Timeframe-Buy-Sell-Analyzer/
- type: indicator
- pine_id: PUB;f31895cb481c4c1189539c9f08cd248a
- version: 1.0

## Description

A Multi-Timeframe Buy/Sell Analyzer maximizes trading accuracy by aligning short-term market entries with long-term market trends. Trading with only one timeframe creates a massive blind spot, leading to false signals and premature exits.Here is a comprehensive overview of how multi-timeframe analysis functions, how to build a mechanical execution strategy, and how to avoid common pitfalls.Structure an Effective Multi-Timeframe StrategyTo analyze multiple timeframes successfully, you must use a top-down approach consisting of three distinct layers.Anchor Timeframe (The Trend): Identifies the macroeconomic direction or primary market trend (e.g., Daily or 4-Hour charts).Intermediate Timeframe (The Structure): Locates key support, resistance, and value zones within that trend (e.g., 1-Hour or 30-Minute charts).Execution Timeframe (The Trigger): Pinpoints precise entry and exit signals to minimize risk and maximize risk-to-reward ratios (e.g., 15-Minute or 5-Minute charts).

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe Buy/Sell Analyzer", overlay=true, max_labels_count=500)

// ===== INPUTS =====
emaFastLen = input.int(20, "Fast EMA", group="Trend")
emaSlowLen = input.int(50, "Slow EMA", group="Trend")
emaTrendLen = input.int(200, "Trend EMA", group="Trend")
rsiLen = input.int(14, "RSI Length", group="Momentum")
rsiBuy = input.int(40, "RSI Buy Threshold", group="Momentum")
rsiSell = input.int(60, "RSI Sell Threshold", group="Momentum")
volMaLen = input.int(20, "Volume MA", group="Volume")
volMult = input.float(1.5, "Volume Multiplier", group="Volume")
atrLen = input.int(14, "ATR Length", group="Risk")
atrMult = input.float(1.5, "ATR Stop Multiplier", group="Risk")
useMTF = input.bool(true, "Require Multi-Timeframe Agreement", group="MTF")
tf1 = input.timeframe("1", "TF 1", group="MTF")
tf2 = input.timeframe("15", "TF 2", group="MTF")
tf3 = input.timeframe("30", "TF 3", group="MTF")
tf4 = input.timeframe("60", "TF 4", group="MTF")
showPanel = input.bool(true, "Show Panel", group="Panel")

// ===== INDICATORS =====
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
emaTrend = ta.ema(close, emaTrendLen)
rsi = ta.rsi(close, rsiLen)
macdLine = ta.ema(close, 12) - ta.ema(close, 26)
sigLine = ta.ema(macdLine, 9)
volMA = ta.sma(volume, volMaLen)
atr = ta.atr(atrLen)

plot(emaFast, "Fast EMA", color=color.new(color.green, 0))
plot(emaSlow, "Slow EMA", color=color.new(color.red, 0))
plot(emaTrend, "Trend EMA", color=color.new(color.orange, 0), linewidth=2)

// ===== MTF TREND (no multiline function - safe to paste) =====
ef1 = request.security(syminfo.tickerid, tf1, ta.ema(close, emaFastLen), lookahead=barmerge.lookahead_off)
es1 = request.security(syminfo.tickerid, tf1, ta.ema(close, emaSlowLen), lookahead=barmerge.lookahead_off)
et1 = request.security(syminfo.tickerid, tf1, ta.ema(close, emaTrendLen), lookahead=barmerge.lookahead_off)
c1 = request.security(syminfo.tickerid, tf1, close, lookahead=barmerge.lookahead_off)
t1 = c1 > et1 and ef1 > es1 ? 1 : c1 < et1 and ef1 < es1 ? -1 : 0

ef2 = request.security(syminfo.tickerid, tf2, ta.ema(close, emaFastLen), lookahead=barmerge.lookahead_off)
es2 = request.security(syminfo.tickerid, tf2, ta.ema(close, emaSlowLen), lookahead=barmerge.lookahead_off)
et2 = request.security(syminfo.tickerid, tf2, ta.ema(close, emaTrendLen), lookahead=barmerge.lookahead_off)
c2 = request.security(syminfo.tickerid, tf2, close, lookahead=barmerge.lookahead_off)
t2 = c2 > et2 and ef2 > es2 ? 1 : c2 < et2 and ef2 < es2 ? -1 : 0

ef3 = request.security(syminfo.tickerid, tf3, ta.ema(close, emaFastLen), lookahead=barmerge.lookahead_off)
es3 = request.security(syminfo.tickerid, tf3, ta.ema(close, emaSlowLen), lookahead=barmerge.lookahead_off)
et3 = request.security(syminfo.tickerid, tf3, ta.ema(close, emaTrendLen), lookahead=barmerge.lookahead_off)
c3 = request.security(syminfo.tickerid, tf3, close, lookahead=barmerge.lookahead_off)
t3 = c3 > et3 and ef3 > es3 ? 1 : c3 < et3 and ef3 < es3 ? -1 : 0

ef4 = request.security(syminfo.tickerid, tf4, ta.ema(close, emaFastLen), lookahead=barmerge.lookahead_off)
es4 = request.security(syminfo.tickerid, tf4, ta.ema(close, emaSlowLen), lookahead=barmerge.lookahead_off)
et4 = request.security(syminfo.tickerid, tf4, ta.ema(close, emaTrendLen), lookahead=barmerge.lookahead_off)
c4 = request.security(syminfo.tickerid, tf4, close, lookahead=barmerge.lookahead_off)
t4 = c4 > et4 and ef4 > es4 ? 1 : c4 < et4 and ef4 < es4 ? -1 : 0

mtfBull = t1 >= 0 and t2 == 1 and t3 == 1 and t4 == 1
mtfBear = t1 <= 0 and t2 == -1 and t3 == -1 and t4 == -1

// ===== LOCAL TREND =====
uptrend = close > emaTrend and emaFast > emaSlow
downtrend = close < emaTrend and emaFast < emaSlow

// ===== CONDITIONS =====
buyCross = ta.crossover(emaFast, emaSlow)
buyMacd = ta.crossover(macdLine, sigLine)
buyRsi = rsi > rsiBuy and rsi < 70
buyVol = volume > volMA * volMult
buyPull = uptrend and close <= emaFast and close > emaSlow
sellCross = ta.crossunder(emaFast, emaSlow)
sellMacd = ta.crossunder(macdLine, sigLine)
sellRsi = rsi < rsiSell and rsi > 30
sellVol = volume > volMA * volMult
sellRally = downtrend and close >= emaFast and close < emaSlow

buyScore = (uptrend ? 1 : 0) + ((buyCross or buyMacd) ? 1 : 0) + (buyRsi ? 1 : 0) + (buyVol ? 1 : 0)
sellScore = (downtrend ? 1 : 0) + ((sellCross or sellMacd) ? 1 : 0) + (sellRsi ? 1 : 0) + (sellVol ? 1 : 0)

buyOK = not useMTF or mtfBull
sellOK = not useMTF or mtfBear
buySignal = (buyCross or buyMacd or buyPull) and buyScore >= 2 and buyOK
sellSignal = (sellCross or sellMacd or sellRally) and sellScore >= 2 and sellOK
strongBuy = buySignal and buyScore >= 3
strongSell = sellSignal and sellScore >= 3

var int lastSignal = 0
buyFinal = buySignal and lastSignal != 1
sellFinal = sellSignal and lastSignal != -1
lastSignal := buyFinal ? 1 : sellFinal ? -1 : lastSignal

// ===== SIGNALS =====
plotshape(buyFinal and not strongBuy, title="Buy", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.white, text="BUY", size=size.small)
plotshape(strongBuy, title="Strong Buy", style=shape.labelup, location=location.belowbar, color=color.new(color.lime, 0), textcolor=color.black, text="STRONG BUY", size=size.normal)
plotshape(sellFinal and not strongSell, title="Sell", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, text="SELL", size=size.small)
plotshape(strongSell, title="Strong Sell", style=shape.labeldown, location=location.abovebar, color=color.new(color.maroon, 0), textcolor=color.white, text="STRONG SELL", size=size.normal)

bgcolor(mtfBull ? color.new(color.green, 90) : mtfBear ? color.new(color.red, 90) : na)

// ===== STOP / TARGET =====
var float stopLevel = na
var float targetLevel = na
stopLevel := buyFinal ? close - atr * atrMult : sellFinal ? close + atr * atrMult : stopLevel
targetLevel := buyFinal ? close + atr * atrMult * 2 : sellFinal ? close - atr * atrMult * 2 : targetLevel

// ===== ALERTS =====
alertcondition(buyFinal, title="BUY Signal", message="BUY signal (MTF aligned)")
alertcondition(sellFinal, title="SELL Signal", message="SELL signal (MTF aligned)")
alertcondition(strongBuy, title="STRONG BUY", message="Strong BUY (MTF aligned)")
alertcondition(strongSell, title="STRONG SELL", message="Strong SELL (MTF aligned)")

// ===== PANEL =====
tt1 = t1 == 1 ? "UP" : t1 == -1 ? "DOWN" : "FLAT"
tt2 = t2 == 1 ? "UP" : t2 == -1 ? "DOWN" : "FLAT"
tt3 = t3 == 1 ? "UP" : t3 == -1 ? "DOWN" : "FLAT"
tt4 = t4 == 1 ? "UP" : t4 == -1 ? "DOWN" : "FLAT"
cc1 = t1 == 1 ? color.green : t1 == -1 ? color.red : color.gray
cc2 = t2 == 1 ? color.green : t2 == -1 ? color.red : color.gray
cc3 = t3 == 1 ? color.green : t3 == -1 ? color.red : color.gray
cc4 = t4 == 1 ? color.green : t4 == -1 ? color.red : color.gray
overallTxt = mtfBull ? "ALL UP - BUY BIAS" : mtfBear ? "ALL DOWN - SELL BIAS" : "MIXED - WAIT"
overallCol = mtfBull ? color.green : mtfBear ? color.red : color.gray

var table panel = table.new(position.top_right, 2, 9, border_width=1)
if showPanel and barstate.islast
    table.cell(panel, 0, 0, "ANALYSIS", text_color=color.white, bgcolor=color.black)
table.cell(panel, 1, 0, "VALUE", text_color=color.white, bgcolor=color.black)
table.cell(panel, 0, 1, "Overall", text_color=color.white)
table.cell(panel, 1, 1, overallTxt, text_color=color.white, bgcolor=overallCol)
table.cell(panel, 0, 2, tf1 + " min", text_color=color.white)
table.cell(panel, 1, 2, tt1, text_color=color.white, bgcolor=cc1)
table.cell(panel, 0, 3, tf2 + " min", text_color=color.white)
table.cell(panel, 1, 3, tt2, text_color=color.white, bgcolor=cc2)
table.cell(panel, 0, 4, tf3 + " min", text_color=color.white)
table.cell(panel, 1, 4, tt3, text_color=color.white, bgcolor=cc3)
table.cell(panel, 0, 5, tf4 + " min", text_color=color.white)
table.cell(panel, 1, 5, tt4, text_color=color.white, bgcolor=cc4)
table.cell(panel, 0, 6, "Buy / Sell Score", text_color=color.white)
table.cell(panel, 1, 6, str.tostring(buyScore) + " / " + str.tostring(sellScore), text_color=color.white)
table.cell(panel, 0, 7, "RSI", text_color=color.white)
table.cell(panel, 1, 7, str.tostring(rsi, "#.0"), text_color=rsi > 70 ? color.red : rsi < 30 ? color.lime : color.white)
table.cell(panel, 0, 8, "Stop / Target", text_color=color.white)
table.cell(panel, 1, 8, na(stopLevel) ? "-" : str.tostring(stopLevel, format.mintick) + " / " + str.tostring(targetLevel, format.mintick), text_color=color.white)
````
