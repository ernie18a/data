# Simpleton v0.01 KIMI - Multi-Strategy (good in 30/45 min.. ?)

- url: https://www.tradingview.com/script/gYqkmQoN-Simpleton-v0-01-KIMI-Multi-Strategy-good-in-30-45-min/
- type: strategy
- pine_id: PUB;748093b6af7b49a0a9ab6496b5074083
- version: 1.0

## Description

// Strategy Mode Selection
strategyMode = input.string("Multi-Indicator", title="Strategy Mode", 
     options=["RSI-2 Mean Reversion", "SuperTrend", "MACD Crossover", "Triple EMA", "Bollinger Bands", "Multi-Indicator"],
     group="⚙️ Strategy Settings")

// Risk Management
useTPSL = input.bool(true, title="Use Take Profit / Stop Loss", group="💰 Risk Management")
tpPercent = input.float(3.0, title="Take Profit %", minval=0.1, maxval=50.0, step=0.1, group="💰 Risk Management")
slPercent = input.float(2.0, title="Stop Loss %", minval=0.1, maxval=50.0, step=0.1, group="💰 Risk Management")
positionSize = input.float(10.0, title="Position Size (% of Equity)", minval=1.0, maxval=100.0, step=1.0, group="💰 Risk Management")
useATRSize = input.bool(false, title="Use ATR-based Position Sizing", group="💰 Risk Management")
atrPeriod = input.int(14, title="ATR Period", minval=5, maxval=50, group="💰 Risk Management")

## Source Code

````pine
// @version=6
// @name=Simpleton v0.01 KIMI
// @description=Multi-strategy backtesting tool with 6 built-in strategies - RSI-2, SuperTrend, MACD, Triple EMA, Bollinger Bands, and Multi-Indicator consensus
// @author=KIMI
// @version=0.01

strategy("Simpleton v0.01 KIMI - Multi-Strategy", shorttitle="SIMP_KIMI", overlay=true,
     initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=10,
     commission_type=strategy.commission.percent, commission_value=0.1)

// ═════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════════════════════════════════════════

// Strategy Mode Selection
strategyMode = input.string("Multi-Indicator", title="Strategy Mode", 
     options=["RSI-2 Mean Reversion", "SuperTrend", "MACD Crossover", "Triple EMA", "Bollinger Bands", "Multi-Indicator"],
     group="⚙️ Strategy Settings")

// Risk Management
useTPSL = input.bool(true, title="Use Take Profit / Stop Loss", group="💰 Risk Management")
tpPercent = input.float(3.0, title="Take Profit %", minval=0.1, maxval=50.0, step=0.1, group="💰 Risk Management")
slPercent = input.float(2.0, title="Stop Loss %", minval=0.1, maxval=50.0, step=0.1, group="💰 Risk Management")
positionSize = input.float(10.0, title="Position Size (% of Equity)", minval=1.0, maxval=100.0, step=1.0, group="💰 Risk Management")
useATRSize = input.bool(false, title="Use ATR-based Position Sizing", group="💰 Risk Management")
atrPeriod = input.int(14, title="ATR Period", minval=5, maxval=50, group="💰 Risk Management")

// Repainting Control
repaintMode = input.bool(false, title="Allow Repainting (NOT RECOMMENDED)", group="🔒 Signal Integrity")

// RSI-2 Settings
rsiLength = input.int(2, title="RSI Length", minval=2, maxval=14, group="📊 RSI-2 Settings")
rsiOversold = input.int(30, title="RSI Oversold", minval=10, maxval=40, group="📊 RSI-2 Settings")
rsiOverbought = input.int(70, title="RSI Overbought", minval=60, maxval=90, group="📊 RSI-2 Settings")
useTrendFilter = input.bool(true, title="Use Trend Filter (200 EMA)", group="📊 RSI-2 Settings")

// SuperTrend Settings
stFactor = input.float(3.0, title="SuperTrend Factor", minval=1.0, maxval=10.0, step=0.1, group="📈 SuperTrend Settings")
stPeriod = input.int(10, title="SuperTrend ATR Period", minval=5, maxval=50, group="📈 SuperTrend Settings")

// MACD Settings
macdFast = input.int(12, title="MACD Fast", minval=5, maxval=50, group="📉 MACD Settings")
macdSlow = input.int(26, title="MACD Slow", minval=10, maxval=100, group="📉 MACD Settings")
macdSignal = input.int(9, title="MACD Signal", minval=5, maxval=50, group="📉 MACD Settings")

// Triple EMA Settings
emaFast = input.int(9, title="Fast EMA", minval=5, maxval=50, group="📊 Triple EMA Settings")
emaMedium = input.int(21, title="Medium EMA", minval=10, maxval=100, group="📊 Triple EMA Settings")
emaSlow = input.int(50, title="Slow EMA", minval=20, maxval=200, group="📊 Triple EMA Settings")

// Bollinger Bands Settings
bbLength = input.int(20, title="BB Length", minval=10, maxval=50, group="📊 Bollinger Bands Settings")
bbMult = input.float(2.0, title="BB Multiplier", minval=1.0, maxval=4.0, step=0.1, group="📊 Bollinger Bands Settings")

// Multi-Indicator Settings
minConfirmations = input.int(2, title="Min Confirmations for Signal", minval=1, maxval=5, group="🎯 Multi-Indicator Settings")

// ═════════════════════════════════════════════════════════════════════════════
// INDICATOR CALCULATIONS
// ═════════════════════════════════════════════════════════════════════════════

// Price source (non-repainting)
price = repaintMode ? close : close[1]

// ATR
atr = ta.atr(atrPeriod)

// RSI-2
rsi = ta.rsi(close, rsiLength)

// Trend Filter (200 EMA)
ema200 = ta.ema(close, 200)
trendUp = close > ema200
trendDown = close < ema200

// SuperTrend
[stValue, stDirection] = ta.supertrend(stFactor, stPeriod)

// MACD
[macdLine, signalLine, macdHist] = ta.macd(close, macdFast, macdSlow, macdSignal)

// Triple EMA
fastEMA = ta.ema(close, emaFast)
mediumEMA = ta.ema(close, emaMedium)
slowEMA = ta.ema(close, emaSlow)

// Bollinger Bands
bbMiddle = ta.sma(close, bbLength)
bbUpper = bbMiddle + bbMult * ta.stdev(close, bbLength)
bbLower = bbMiddle - bbMult * ta.stdev(close, bbLength)

// Volume
avgVolume = ta.sma(volume, 20)
volumeConfirm = volume > avgVolume * 1.2

// ═════════════════════════════════════════════════════════════════════════════
// SIGNAL GENERATION
// ═════════════════════════════════════════════════════════════════════════════

// RSI-2 Signals
rsiBuy = rsi < rsiOversold and rsi[1] <= rsiOversold and (not useTrendFilter or trendUp)
rsiSell = rsi > rsiOverbought and rsi[1] >= rsiOverbought and (not useTrendFilter or trendDown)

// SuperTrend Signals
stBuy = stDirection < 0 and stDirection[1] > 0
stSell = stDirection > 0 and stDirection[1] < 0

// MACD Signals
macdBuy = macdLine > signalLine and macdLine[1] <= signalLine[1]
macdSell = macdLine < signalLine and macdLine[1] >= signalLine[1]

// Triple EMA Signals
tripleEMABuy = fastEMA > mediumEMA and mediumEMA > slowEMA and (fastEMA[1] <= mediumEMA[1] or fastEMA[2] <= mediumEMA[2])
tripleEMASell = fastEMA < mediumEMA and mediumEMA < slowEMA and (fastEMA[1] >= mediumEMA[1] or fastEMA[2] >= mediumEMA[2])

// Bollinger Bands Signals
bbBuy = close < bbLower and close[1] <= bbLower[1]
bbSell = close > bbUpper and close[1] >= bbUpper[1]

// ═════════════════════════════════════════════════════════════════════════════
// MULTI-INDICATOR VOTING SYSTEM
// ═════════════════════════════════════════════════════════════════════════════

// Count votes for long
longVotes = 0
longVotes += rsiBuy ? 1 : 0
longVotes += stBuy ? 1 : 0
longVotes += macdBuy ? 1 : 0
longVotes += tripleEMABuy ? 1 : 0
longVotes += bbBuy ? 1 : 0

// Count votes for short
shortVotes = 0
shortVotes += rsiSell ? 1 : 0
shortVotes += stSell ? 1 : 0
shortVotes += macdSell ? 1 : 0
shortVotes += tripleEMASell ? 1 : 0
shortVotes += bbSell ? 1 : 0

// Multi-indicator signals
multiBuy = longVotes >= minConfirmations
multiSell = shortVotes >= minConfirmations

// Signal strength (1-4 scale for display)
signalStrength = math.max(longVotes, shortVotes)

// ═════════════════════════════════════════════════════════════════════════════
// STRATEGY SELECTION
// ═════════════════════════════════════════════════════════════════════════════

var string currentStrategy = na
var int lastSignalStrength = 0

if strategyMode == "RSI-2 Mean Reversion"
    currentStrategy := "RSI-2"
    if rsiBuy
        strategy.entry("Long", strategy.long)
    if rsiSell
        strategy.entry("Short", strategy.short)
    lastSignalStrength := rsiBuy or rsiSell ? 1 : 0

else if strategyMode == "SuperTrend"
    currentStrategy := "SuperTrend"
    if stBuy
        strategy.entry("Long", strategy.long)
    if stSell
        strategy.entry("Short", strategy.short)
    lastSignalStrength := stBuy or stSell ? 1 : 0

else if strategyMode == "MACD Crossover"
    currentStrategy := "MACD"
    if macdBuy
        strategy.entry("Long", strategy.long)
    if macdSell
        strategy.entry("Short", strategy.short)
    lastSignalStrength := macdBuy or macdSell ? 1 : 0

else if strategyMode == "Triple EMA"
    currentStrategy := "Triple EMA"
    if tripleEMABuy
        strategy.entry("Long", strategy.long)
    if tripleEMASell
        strategy.entry("Short", strategy.short)
    lastSignalStrength := tripleEMABuy or tripleEMASell ? 1 : 0

else if strategyMode == "Bollinger Bands"
    currentStrategy := "Bollinger"
    if bbBuy
        strategy.entry("Long", strategy.long)
    if bbSell
        strategy.entry("Short", strategy.short)
    lastSignalStrength := bbBuy or bbSell ? 1 : 0

else // Multi-Indicator
    currentStrategy := "Multi-Indicator"
    if multiBuy
        strategy.entry("Long", strategy.long)
    if multiSell
        strategy.entry("Short", strategy.short)
    lastSignalStrength := signalStrength

// ═════════════════════════════════════════════════════════════════════════════
// TAKE PROFIT / STOP LOSS
// ═════════════════════════════════════════════════════════════════════════════

if useTPSL
    strategy.exit("TP/SL Long", "Long", limit=close * (1 + tpPercent/100), stop=close * (1 - slPercent/100))
    strategy.exit("TP/SL Short", "Short", limit=close * (1 - tpPercent/100), stop=close * (1 + slPercent/100))

// ═════════════════════════════════════════════════════════════════════════════
// VISUALIZATION
// ═════════════════════════════════════════════════════════════════════════════

// Plot EMAs
plot(emaFast, color=color.new(color.blue, 50), title="Fast EMA")
plot(emaMedium, color=color.new(color.orange, 50), title="Medium EMA")
plot(emaSlow, color=color.new(color.purple, 50), title="Slow EMA")

// Plot SuperTrend
plot(stDirection < 0 ? stValue : na, color=color.green, style=plot.style_linebr, title="ST Support")
plot(stDirection > 0 ? stValue : na, color=color.red, style=plot.style_linebr, title="ST Resistance")

// Plot Bollinger Bands
plot(bbUpper, color=color.new(color.gray, 70), title="BB Upper")
plot(bbLower, color=color.new(color.gray, 70), title="BB Lower")

// Buy/Sell Signals on Chart
plotshape(rsiBuy or stBuy or macdBuy or tripleEMABuy or bbBuy or multiBuy, title="Buy Signal", location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small)
plotshape(rsiSell or stSell or macdSell or tripleEMASell or bbSell or multiSell, title="Sell Signal", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small)

// Background color for trend
bgcolor(trendUp ? color.new(color.green, 90) : trendDown ? color.new(color.red, 90) : color.new(color.gray, 95), title="Trend Background")

// ═════════════════════════════════════════════════════════════════════════════
// INFO TABLE
// ═════════════════════════════════════════════════════════════════════════════

if barstate.islast
    var table infoTable = table.new(position.top_right, 2, 10, bgcolor=color.new(color.black, 20), 
         frame_width=1, frame_color=color.gray)
    
    table.cell(infoTable, 0, 0, "Strategy", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 0, currentStrategy, text_color=color.yellow, text_size=size.small)
    
    table.cell(infoTable, 0, 1, "Signal Strength", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(lastSignalStrength) + "/4", 
         text_color=lastSignalStrength >= 3 ? color.green : lastSignalStrength >= 2 ? color.yellow : color.gray, 
         text_size=size.small)
    
    table.cell(infoTable, 0, 2, "Long Votes", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(longVotes) + "/5", text_color=color.green, text_size=size.small)
    
    table.cell(infoTable, 0, 3, "Short Votes", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(shortVotes) + "/5", text_color=color.red, text_size=size.small)
    
    table.cell(infoTable, 0, 4, "RSI", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 4, str.tostring(rsi, "#."), 
         text_color=rsi < rsiOversold ? color.green : rsi > rsiOverbought ? color.red : color.gray, 
         text_size=size.small)
    
    table.cell(infoTable, 0, 5, "Trend", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 5, trendUp ? "Bullish" : trendDown ? "Bearish" : "Neutral", 
         text_color=trendUp ? color.green : trendDown ? color.red : color.gray, text_size=size.small)
    
    table.cell(infoTable, 0, 6, "TP/SL", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 6, useTPSL ? str.tostring(tpPercent) + "/" + str.tostring(slPercent) + "%" : "OFF", 
         text_color=useTPSL ? color.white : color.gray, text_size=size.small)
    
    table.cell(infoTable, 0, 7, "Repainting", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 7, repaintMode ? "⚠️ ON" : "✓ OFF", 
         text_color=repaintMode ? color.red : color.green, text_size=size.small)

// ═════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════════════════════════════════

alertcondition(rsiBuy or stBuy or macdBuy or tripleEMABuy or bbBuy or multiBuy, title="Buy Signal", message="Simpleton KIMI: BUY Signal - {{ticker}} @ {{close}}")
alertcondition(rsiSell or stSell or macdSell or tripleEMASell or bbSell or multiSell, title="Sell Signal", message="Simpleton KIMI: SELL Signal - {{ticker}} @ {{close}}")
````
