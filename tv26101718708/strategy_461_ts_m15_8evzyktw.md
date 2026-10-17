# Strategy 461 - TS M15

- url: https://www.tradingview.com/script/8Evzyktw/
- type: strategy
- pine_id: PUB;2d00a29328fb46b186192ce49b95daf7
- version: 1.0

## Description

Strategy 461 is a short-term price action strategy designed for XAUUSD on the 15-minute timeframe.

The strategy is based on a clean liquidity sweep / TS pattern. It looks for situations where the current candle takes liquidity from the previous candle, rejects that move, and closes back with directional strength.

Core Idea

The strategy tries to capture short-term reversals after a liquidity sweep.

A bullish setup appears when:

The previous candle is bearish.
The current candle sweeps the previous low.
The current candle does not sweep the previous high.
The current candle closes bullish.
Price closes back above the previous low.

A bearish setup appears when:

The previous candle is bullish.
The current candle sweeps the previous high.
The current candle does not sweep the previous low.
The current candle closes bearish.
Price closes back below the previous high.
Trend Filter

The strategy includes an optional EMA200 bias filter:

Long trades are only allowed when price is above the EMA200.
Short trades are only allowed when price is below the EMA200.

This filter is intended to reduce counter-trend entries and improve signal quality.

Risk Management

Each trade uses a fixed Risk-to-Reward target.

Stop Loss is placed beyond the sweep candle extreme.
A configurable tick buffer is added beyond the wick.
Take Profit is calculated using the selected RR multiple.
The RR target can be adjusted from 1:1 upward.

Example:

RR Target = 1.0 means 1:1.
RR Target = 1.5 means 1:1.5.
RR Target = 2.0 means 1:2.
Recommended Market
Symbol: XAUUSD
Timeframe: 15 minutes
Market type: Gold / Spot Gold / CFD Gold, depending on broker data.
Main Inputs
RR Target: Defines the take-profit distance relative to risk.
Buffer SL in ticks: Adds extra distance beyond the sweep wick.
EMA Bias Length: Default trend filter length.
Use EMA200 Filter: Enables or disables directional bias.
Session Filter: Optional trading session filter.
Show EMA200: Displays the trend filter line.
Exit Logic

Positions are closed automatically by:

Stop Loss.
Take Profit based on the selected RR.

The strategy does not use trailing stops or discretionary exits.

Notes

This is a simple and direct liquidity-sweep model. It is not designed to catch every move, but to identify clean rejection patterns with predefined risk.

Performance may vary depending on broker feed, spread, commission, trading session, and execution quality. It is recommended to test different RR values, SL buffers, and session filters before using it in live trading.

This script is intended for research, backtesting, and educational purposes only.

## Source Code

````pine
//@version=6
strategy(title="Strategy 461 - TS M15", shorttitle="S461 TS M15", overlay=true, initial_capital=10000, currency=currency.USD, default_qty_type=strategy.percent_of_equity, default_qty_value=95, pyramiding=0, commission_type=strategy.commission.percent, commission_value=0.02, process_orders_on_close=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Strategy 461 XAU — TS M15 Direct RR No Visuals
// Recomendada para gráfico M15 en XAUUSD
// Sin plotshape, sin líneas, sin etiquetas propias.
// Solo operaciones reales de TradingView.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Inputs
rrTarget    = input.float(1.0, "RR Target", minval=1.0, step=0.25)
bufferTicks = input.int(20, "Buffer SL en ticks", minval=0)

useBias     = input.bool(true, "Usar filtro EMA200")
emaLen      = input.int(200, "EMA Bias Length", minval=1)

useSession  = input.bool(false, "Filtrar sesión")
sessionInp  = input.session("0700-1700", "Sesión operativa")

showEMA     = input.bool(true, "Mostrar EMA200")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Indicadores
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ema200 = ta.ema(close, emaLen)
inSession = not useSession or not na(time(timeframe.period, sessionInp))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TS limpio M15
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
prevBear = close[1] < open[1]
prevBull = close[1] > open[1]

takesPrevLow  = low < low[1]
takesPrevHigh = high > high[1]

// TS alcista:
// vela anterior bajista,
// vela actual toma el low anterior,
// no toma el high anterior,
// cierra alcista recuperando.
cleanBullTS =
     prevBear and
     takesPrevLow and
     not takesPrevHigh and
     close > open and
     close > low[1]

// TS bajista:
// vela anterior alcista,
// vela actual toma el high anterior,
// no toma el low anterior,
// cierra bajista rechazando.
cleanBearTS =
     prevBull and
     takesPrevHigh and
     not takesPrevLow and
     close < open and
     close < high[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Bias EMA200
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
biasLongOk  = not useBias or close > ema200
biasShortOk = not useBias or close < ema200

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Estado
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
flat = strategy.position_size == 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SL / TP por RR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tickBuffer = syminfo.mintick * bufferTicks

longSLCalc   = low - tickBuffer
longRiskCalc = close - longSLCalc
longTPCalc   = close + longRiskCalc * rrTarget

shortSLCalc   = high + tickBuffer
shortRiskCalc = shortSLCalc - close
shortTPCalc   = close - shortRiskCalc * rrTarget

longRiskOk  = longRiskCalc > 0
shortRiskOk = shortRiskCalc > 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Variables persistentes de salida
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float longSL  = na
var float longTP  = na
var float shortSL = na
var float shortTP = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Condiciones de entrada
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
longEntry =
     flat and
     inSession and
     cleanBullTS and
     biasLongOk and
     longRiskOk

shortEntry =
     flat and
     inSession and
     cleanBearTS and
     biasShortOk and
     shortRiskOk

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Ejecución
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if longEntry
    longSL  := longSLCalc
    longTP  := longTPCalc
    shortSL := na
    shortTP := na

    strategy.entry("Long", strategy.long, alert_message="ENTRY_LONG")
    strategy.exit("Long TP/SL", from_entry="Long", stop=longSL, limit=longTP, alert_message="EXIT_LONG")

if shortEntry
    shortSL := shortSLCalc
    shortTP := shortTPCalc
    longSL  := na
    longTP  := na

    strategy.entry("Short", strategy.short, alert_message="ENTRY_SHORT")
    strategy.exit("Short TP/SL", from_entry="Short", stop=shortSL, limit=shortTP, alert_message="EXIT_SHORT")

// Mantener salidas vivas mientras exista posición long
if strategy.position_size > 0 and not na(longSL) and not na(longTP)
    strategy.exit("Long TP/SL", from_entry="Long", stop=longSL, limit=longTP, alert_message="EXIT_LONG")

// Mantener salidas vivas mientras exista posición short
if strategy.position_size < 0 and not na(shortSL) and not na(shortTP)
    strategy.exit("Short TP/SL", from_entry="Short", stop=shortSL, limit=shortTP, alert_message="EXIT_SHORT")

// Limpiar niveles internos cuando está plano
if strategy.position_size == 0 and not longEntry and not shortEntry
    longSL  := na
    longTP  := na
    shortSL := na
    shortTP := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plot único estilo Strategy 250
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showEMA ? ema200 : na, title="EMA 200", color=color.new(color.orange, 0), linewidth=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Panel informativo
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table infoTable = table.new(position.top_right, 2, 6, border_width=1)

if barstate.islast
    table.cell(infoTable, 0, 0, "Strategy", text_color=color.white, bgcolor=color.new(color.blue, 0))
    table.cell(infoTable, 1, 0, "461 XAU", text_color=color.white, bgcolor=color.new(color.blue, 0))

    table.cell(infoTable, 0, 1, "Modelo")
    table.cell(infoTable, 1, 1, "TS M15 Direct")

    table.cell(infoTable, 0, 2, "RR Target")
    table.cell(infoTable, 1, 2, str.tostring(rrTarget, "#.##"))

    table.cell(infoTable, 0, 3, "Buffer Ticks")
    table.cell(infoTable, 1, 3, str.tostring(bufferTicks))

    table.cell(infoTable, 0, 4, "Bias EMA200")
    table.cell(infoTable, 1, 4, useBias ? "ON" : "OFF")

    table.cell(infoTable, 0, 5, "Session")
    table.cell(infoTable, 1, 5, useSession ? sessionInp : "OFF")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alertas
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(longEntry, title="Strategy 461 XAU Long Entry", message="Strategy 461 XAU: Entrada LONG")
alertcondition(shortEntry, title="Strategy 461 XAU Short Entry", message="Strategy 461 XAU: Entrada SHORT")
````
