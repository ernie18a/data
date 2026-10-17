# Strategy 432 BTC - Donchian Breakout Continuation

- url: https://www.tradingview.com/script/tuC7aGNI/
- type: strategy
- pine_id: PUB;f059be5720114b33acc0cfd205775f0e
- version: 1.0

## Description

Strategy 432 BTC — Donchian Breakout Continuation

Strategy 432 is a BTC/USDT trend-following breakout strategy designed for the 4H timeframe.

The idea behind the system is simple: Bitcoin often rewards strong directional breakouts when they happen in a confirmed trend environment. Instead of trying to fade aggressive moves, this strategy attempts to follow them when momentum, volatility and macro trend alignment are present.

The strategy uses a Donchian Channel to detect breakouts above previous highs or below previous lows. A long entry is triggered when price closes above the previous Donchian high, the breakout distance is large enough relative to ATR, ADX confirms trend strength, and price is trading above the EMA 200.

By default, short trades are disabled because the original BTC research showed stronger results on the long side. However, the script includes an optional short mode for testing.

Main components:

Donchian Channel breakout based on previous candles
ATR-based breakout magnitude filter
ADX trend-strength filter
EMA 200 macro trend filter
Time-based exit after a fixed number of bars
Exit on opposite Donchian channel break
Optional short-side logic

This strategy is built specifically around the idea that, in BTC, large breakouts can lead to continuation when supported by trend strength. It is not designed to predict tops or bottoms, but to participate in directional moves once confirmation is present.

Best used on BTC/USDT 4H. Results may vary significantly across other assets or timeframes. Always backtest and validate before using it in live trading.

## Source Code

````pine
//@version=6
strategy(
     title="Strategy 432 BTC - Donchian Breakout Continuation",
     shorttitle="Strategy 432 BTC",
     overlay=true,
     initial_capital=10000,
     currency=currency.USDT,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=95,
     pyramiding=0,
     commission_type=strategy.commission.percent,
     commission_value=0.1,
     process_orders_on_close=true
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
dcLen       = input.int(30,  "Donchian Length", minval=1)
atrLen      = input.int(14,  "ATR Length", minval=1)
adxLen      = input.int(14,  "ADX Length", minval=1)
ema200Len   = input.int(200, "EMA 200 Length", minval=1)

minBreakAtr = input.float(0.5, "Min Breakout ATR", step=0.1)
adxMin      = input.float(22.0, "ADX mínimo", step=0.5)
holdBars    = input.int(20, "Máximo de barras en posición", minval=1)

allowShorts = input.bool(false, "Permitir shorts")

showSignals = input.bool(true, "Mostrar señales")
showLevels  = input.bool(true, "Mostrar Donchian / EMA")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Indicadores
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Donchian usando SOLO barras anteriores.
// Equivale a: shift(1).rolling(dc_len).max/min en Python/QC.
dcHigh = ta.highest(high[1], dcLen)
dcLow  = ta.lowest(low[1], dcLen)

atrValue = ta.atr(atrLen)
ema200   = ta.ema(close, ema200Len)

// ADX en Pine v6
[plusDI, minusDI, adxValue] = ta.dmi(adxLen, adxLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Magnitud del breakout
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
longBreakoutMag  = close > dcHigh and atrValue > 0 ? (close - dcHigh) / atrValue : 0.0
shortBreakoutMag = close < dcLow  and atrValue > 0 ? (dcLow - close) / atrValue  : 0.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Estado de posición
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
inLong  = strategy.position_size > 0
inShort = strategy.position_size < 0
flat    = strategy.position_size == 0

var int entryBarIndex = na

barsHeld = not na(entryBarIndex) ? bar_index - entryBarIndex : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Condiciones de entrada
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
indicatorsReady = not na(dcHigh) and not na(dcLow) and not na(atrValue) and not na(adxValue) and not na(ema200)

longEntry =
     indicatorsReady and
     flat and
     close > dcHigh and
     adxValue >= adxMin and
     close > ema200 and
     longBreakoutMag >= minBreakAtr

shortEntry =
     indicatorsReady and
     allowShorts and
     flat and
     close < dcLow and
     adxValue >= adxMin and
     close < ema200 and
     shortBreakoutMag >= minBreakAtr

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Condiciones de salida
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
longExit =
     inLong and (
         close < dcLow or
         (not na(barsHeld) and barsHeld >= holdBars)
     )

shortExit =
     inShort and (
         close > dcHigh or
         (not na(barsHeld) and barsHeld >= holdBars)
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Ejecución
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if longEntry
    strategy.entry("Long", strategy.long, alert_message="ENTRY_LONG")
    entryBarIndex := bar_index

if shortEntry
    strategy.entry("Short", strategy.short, alert_message="ENTRY_SHORT")
    entryBarIndex := bar_index

if longExit
    strategy.close("Long", alert_message="EXIT_LONG")
    entryBarIndex := na

if shortExit
    strategy.close("Short", alert_message="EXIT_SHORT")
    entryBarIndex := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showLevels ? dcHigh : na, title="Donchian High previo", color=color.new(color.green, 0), linewidth=1)
plot(showLevels ? dcLow  : na, title="Donchian Low previo",  color=color.new(color.red, 0), linewidth=1)
plot(showLevels ? ema200 : na, title="EMA 200", color=color.new(color.orange, 0), linewidth=2)

plotshape(
     showSignals and longEntry,
     title="Entrada Long",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(color.green, 0),
     size=size.small,
     text="LONG"
)

plotshape(
     showSignals and shortEntry,
     title="Entrada Short",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.new(color.red, 0),
     size=size.small,
     text="SHORT"
)

plotshape(
     showSignals and longExit,
     title="Salida Long",
     style=shape.xcross,
     location=location.abovebar,
     color=color.new(color.green, 0),
     size=size.tiny,
     text="EXIT"
)

plotshape(
     showSignals and shortExit,
     title="Salida Short",
     style=shape.xcross,
     location=location.belowbar,
     color=color.new(color.red, 0),
     size=size.tiny,
     text="EXIT"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Panel informativo
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table infoTable = table.new(position.top_right, 2, 7, border_width=1)

if barstate.islast
    table.cell(infoTable, 0, 0, "Strategy", text_color=color.white, bgcolor=color.new(color.blue, 0))
    table.cell(infoTable, 1, 0, "432 BTC", text_color=color.white, bgcolor=color.new(color.blue, 0))

    table.cell(infoTable, 0, 1, "ADX")
    table.cell(infoTable, 1, 1, str.tostring(adxValue, "#.##"))

    table.cell(infoTable, 0, 2, "ATR")
    table.cell(infoTable, 1, 2, str.tostring(atrValue, "#.##"))

    table.cell(infoTable, 0, 3, "Break Long ATR")
    table.cell(infoTable, 1, 3, str.tostring(longBreakoutMag, "#.###"))

    table.cell(infoTable, 0, 4, "Break Short ATR")
    table.cell(infoTable, 1, 4, str.tostring(shortBreakoutMag, "#.###"))

    table.cell(infoTable, 0, 5, "Bars Held")
    table.cell(infoTable, 1, 5, na(barsHeld) ? "-" : str.tostring(barsHeld))

    table.cell(infoTable, 0, 6, "Shorts")
    table.cell(infoTable, 1, 6, allowShorts ? "ON" : "OFF")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alertas
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(longEntry,  title="Strategy 432 Long Entry",  message="Strategy 432 BTC: Entrada LONG")
alertcondition(shortEntry, title="Strategy 432 Short Entry", message="Strategy 432 BTC: Entrada SHORT")
alertcondition(longExit,   title="Strategy 432 Long Exit",   message="Strategy 432 BTC: Salida LONG")
alertcondition(shortExit,  title="Strategy 432 Short Exit",  message="Strategy 432 BTC: Salida SHORT")
````
