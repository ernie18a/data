# MACD Bounce Strategy for Cryptohopper

- url: https://www.tradingview.com/script/G6O8DZGw-MACD-Bounce-Strategy-for-Cryptohopper/
- type: strategy
- pine_id: PUB;87c867229878480db888ba8e99ac2940
- version: 2.0

## Description

Sell and Buy alerts based on MACD crossover values for automated triggers in Cryptohopper

## Source Code

````pine
//@version=6
strategy(
     'MACD Bounce Strategy Cryptohopper',
     overlay = false,
     margin_long = 100,
     margin_short = 100,
     default_qty_type = strategy.percent_of_equity,
     default_qty_value = 100,
     initial_capital = 10000
)

// === Inputs ===
fastLength   = input.int(12, 'MACD Fast Length')
slowLength   = input.int(26, 'MACD Slow Length')
signalLength = input.int(9,  'MACD Signal Length')

threshold = input.float(-350.0, 'MACD Threshold')
bounce    = input.float(100.0,  'Bounce Distance')

// === MACD Calculation ===
[macdLine, signalLine, histLine] = ta.macd(close, fastLength, slowLength, signalLength)

// === State variables ===
var bool  armed             = false
var bool  buyPlaced         = false
var bool  sellPlaced        = false
var bool  macdAboveZero     = false
var float lowestMacd        = na

// === Logica ===

// Activeer cyclus
if macdLine < threshold and not armed
    armed := true
    lowestMacd := macdLine
    buyPlaced := false
    sellPlaced := false
    macdAboveZero := false

// Bodem volgen
if armed and macdLine < threshold
    lowestMacd := math.min(lowestMacd, macdLine)

// BUY trigger
buySignal = false
if armed and not buyPlaced and macdLine >= lowestMacd + bounce
    buySignal := true
    buyPlaced := true

// Houd bij of MACD boven nul komt
if buyPlaced and not macdAboveZero and macdLine > 0
    macdAboveZero := true

// SELL trigger
sellSignal = false
if buyPlaced and macdAboveZero and not sellPlaced and macdLine < signalLine
    sellSignal := true
    sellPlaced := true
    armed := false
    buyPlaced := false
    macdAboveZero := false
    lowestMacd := na

// === Strategy Orders + Cryptohopper Alerts ===
if buySignal and strategy.position_size == 0
    strategy.entry('BUY', strategy.long)
    alert(
        '{"action":"buy","coin":"BTC","market_order":"1"}',
        alert.freq_once_per_bar_close
    )

if sellSignal and strategy.position_size > 0
    strategy.close('BUY')
    alert(
        '{"action":"sell","coin":"BTC","market_order":"1"}',
        alert.freq_once_per_bar_close
    )

// === Visuals ===
plot(macdLine,   color=color.new(color.blue, 0),   title='MACD')
plot(signalLine, color=color.new(color.orange, 0), title='Signal Line')
hline(0, 'Zero Line', color=color.gray)

plotshape(
     buySignal,
     title     = 'BUY',
     location  = location.bottom,
     color     = color.green,
     style     = shape.triangleup,
     size      = size.small
)

plotshape(
     sellSignal,
     title     = 'SELL',
     location  = location.top,
     color     = color.red,
     style     = shape.triangledown,
     size      = size.small
)
````
