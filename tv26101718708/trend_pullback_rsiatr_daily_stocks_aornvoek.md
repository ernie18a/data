# Trend Pullback RSI+ATR | Daily Stocks

- url: https://www.tradingview.com/script/AORNVoek-Trend-Pullback-RSI-ATR-Daily-Stocks/
- type: strategy
- pine_id: PUB;f4ed8b160e6f4825a04d9fd0140ec5ed
- version: 1.0

## Description

Trend-following strategy for US stocks on the daily timeframe (2-4 week swing horizon).

ENTRY LOGIC (longs only):
1. Confirmed bullish regime: EMA50 > EMA200 and price above EMA50
2. Recent pullback: RSI(14) touched the 40-50 zone within the last 5 bars
3. Resumption trigger: RSI crosses back above the 50 level
4. Volatility filter: ATR > 1% of price (avoids dead markets)

RISK MANAGEMENT:
- Stop Loss: 2 x ATR below entry
- Take Profit: 4 x ATR above entry (1:2 R:R)
- Position sizing: 1% equity risk per trade
- Defensive exit: close position if EMA50 crosses below EMA200

COSTS INCLUDED:
- Commission: 0.05% per side
- Slippage: 2 ticks

INDICATORS USED (3):
- EMA 50 and EMA 200 (regime)
- RSI 14 (entry timing)
- ATR 14 (risk management)

Designed for liquid tickers such as SPY, QQQ, AAPL, MSFT, NVDA. Expected win rate 40-50%, target profit factor above 1.5. Long-only by design — sitting in cash during bearish regimes is preferred over shorting due to structural upward bias and borrow costs.

## Source Code

````pine
//@version=5
// ============================================================================
//  ESTRATEGIA: Trend Pullback con RSI y ATR
//  Activo: Acciones US líquidas (SPY, QQQ, AAPL, MSFT, NVDA...)
//  Timeframe: Daily (1D)
//  Perfil: Trend-following, solo largos, swing 2-4 semanas
// ============================================================================

strategy(
     title                = "Trend Pullback RSI+ATR | Daily Stocks",
     shorttitle           = "TPRA-D",
     overlay              = true,
     initial_capital      = 10000,
     default_qty_type     = strategy.percent_of_equity,
     default_qty_value    = 100,
     commission_type      = strategy.commission.percent,
     commission_value     = 0.05,
     slippage             = 2,
     pyramiding           = 0,
     calc_on_every_tick   = false,
     process_orders_on_close = true,
     currency             = currency.USD)

// ============================================================================
//  INPUTS
// ============================================================================
emaFastLen   = input.int(50,  "EMA Rápida (régimen)",   minval = 10)
emaSlowLen   = input.int(200, "EMA Lenta (régimen)",    minval = 50)
rsiLen       = input.int(14,  "RSI Length",             minval = 2)
rsiPullback  = input.int(50,  "RSI nivel pullback/cross", minval = 30, maxval = 70)
rsiZoneLow   = input.int(40,  "RSI zona pullback - bajo", minval = 20, maxval = 50)
atrLen       = input.int(14,  "ATR Length",             minval = 5)
atrStopMult  = input.float(2.0, "ATR Stop Multiplier",  minval = 0.5, step = 0.1)
atrTpMult    = input.float(4.0, "ATR TP Multiplier",    minval = 0.5, step = 0.1)
riskPerTrade = input.float(1.0, "Riesgo % por trade",   minval = 0.1, maxval = 5.0, step = 0.1)

startDate = input.time(timestamp("2018-01-01"), "Fecha inicio backtest")
endDate   = input.time(timestamp("2099-01-01"), "Fecha fin backtest")
inDateRange = time >= startDate and time <= endDate

// ============================================================================
//  INDICADORES (los 3)
// ============================================================================
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
rsi     = ta.rsi(close, rsiLen)
atr     = ta.atr(atrLen)

// ============================================================================
//  CONDICIONES
// ============================================================================
bullRegime = emaFast > emaSlow and close > emaFast
pullbackHappened = ta.barssince(rsi <= rsiPullback and rsi >= rsiZoneLow) <= 5
rsiCrossUp = ta.crossover(rsi, rsiPullback)
atrPctOfPrice = (atr / close) * 100
volOk = atrPctOfPrice > 1.0

longCondition = bullRegime and pullbackHappened and rsiCrossUp and volOk and inDateRange

// ============================================================================
//  GESTIÓN DE POSICIÓN
// ============================================================================
var float entryPrice = na
var float stopPrice  = na
var float tpPrice    = na

if longCondition and strategy.position_size == 0
    entryPrice := close
    stopPrice  := close - atrStopMult * atr
    tpPrice    := close + atrTpMult   * atr

    riskAmount = strategy.equity * (riskPerTrade / 100)
    riskPerShare = entryPrice - stopPrice
    qty = riskPerShare > 0 ? riskAmount / riskPerShare : 0

    strategy.entry("Long", strategy.long, qty = qty)

if strategy.position_size > 0
    strategy.exit("Exit", "Long", stop = stopPrice, limit = tpPrice)

if strategy.position_size > 0 and ta.crossunder(emaFast, emaSlow)
    strategy.close("Long", comment = "Régimen roto")

// ============================================================================
//  VISUALIZACIÓN
// ============================================================================
plot(emaFast, "EMA 50",  color = color.new(color.blue,   0), linewidth = 2)
plot(emaSlow, "EMA 200", color = color.new(color.orange, 0), linewidth = 2)

bgcolor(bullRegime ? color.new(color.green, 92) : color.new(color.red, 95), title = "Régimen")

plotshape(longCondition and strategy.position_size == 0,
     title = "Señal Long",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.new(color.green, 0),
     size  = size.small)

plot(strategy.position_size > 0 ? stopPrice : na, "Stop", color = color.red,   style = plot.style_linebr)
plot(strategy.position_size > 0 ? tpPrice   : na, "TP",   color = color.green, style = plot.style_linebr)
````
