# Adaptive Daily SMA System (Stable Version)

- url: https://www.tradingview.com/script/uhHu2nci-Adaptive-Daily-SMA-System-Stable-Version/
- type: indicator
- pine_id: PUB;6b1c52e85dc04ed4b353f8210023ec02
- version: 1.0

## Description

Best moving average combinations for crypto pairs in FTMO

## Source Code

````pine
//@version=6
indicator("Adaptive Daily SMA System (Stable Version)", overlay=true)

// ===============================
// TIMEFRAME WARNING (NO CRASH)
// ===============================
isDaily = timeframe.period == "D"

var label warn = na

if not isDaily
    if na(warn)
        warn := label.new(
            bar_index,
            high,
            "⚠️ Please switch to DAILY timeframe",
            style=label.style_label_down,
            color=color.red,
            textcolor=color.white
        )
else
    if not na(warn)
        label.delete(warn)
        warn := na

// ===============================
// SYMBOL
// ===============================
sym = ticker.standard(syminfo.tickerid)

// ===============================
// SAFE DEFAULTS (VERY IMPORTANT)
// ===============================
fastLen = 20
slowLen = 50
dual = true

// ===============================
// OVERRIDES (YOUR OPTIMIZED SETTINGS)
// ===============================

// ETH
if sym == "BINANCE:ETHUSDT"
    fastLen := 12
    slowLen := 33
    dual := true

// SOL
if sym == "BINANCE:SOLUSDT"
    fastLen := 14
    slowLen := 31
    dual := true

// XRP
if sym == "BINANCE:XRPUSDT"
    fastLen := 3
    slowLen := 9
    dual := true

// DASH (single)
if sym == "BINANCE:DASHUSDT"
    fastLen := 35
    slowLen := 35
    dual := false

// DOT
if sym == "BINANCE:DOTUSDT"
    fastLen := 78
    slowLen := 89
    dual := true

// ADA
if sym == "BINANCE:ADAUSDT"
    fastLen := 19
    slowLen := 37
    dual := true

// BCH (single)
if sym == "BINANCE:BCHUSDT"
    fastLen := 18
    slowLen := 18
    dual := false

// AVAX
if sym == "BINANCE:AVAXUSDT"
    fastLen := 9
    slowLen := 16
    dual := true

// ETC
if sym == "BINANCE:ETCUSDT"
    fastLen := 2
    slowLen := 56
    dual := true

// NEO (single)
if sym == "BINANCE:NEOUSDT"
    fastLen := 22
    slowLen := 22
    dual := false

// XMR
if sym == "BINANCE:XMRUSDT"
    fastLen := 15
    slowLen := 16
    dual := true

// DOGE
if sym == "BINANCE:DOGEUSDT"
    fastLen := 3
    slowLen := 56
    dual := true

// BNB
if sym == "BINANCE:BNBUSDT"
    fastLen := 13
    slowLen := 14
    dual := true

// SAND (single)
if sym == "BINANCE:SANDUSDT"
    fastLen := 45
    slowLen := 45
    dual := false

// LINK
if sym == "BINANCE:LINKUSDT"
    fastLen := 2
    slowLen := 13
    dual := true

// NEAR
if sym == "BINANCE:NEARUSDT"
    fastLen := 12
    slowLen := 38
    dual := true

// ALGO
if sym == "BINANCE:ALGOUSDT"
    fastLen := 13
    slowLen := 14
    dual := true

// ICP (single)
if sym == "BINANCE:ICPUSDT"
    fastLen := 3
    slowLen := 3
    dual := false

// AAVE
if sym == "BINANCE:AAVEUSDT"
    fastLen := 12
    slowLen := 40
    dual := true

// HBAR
if sym == "BINANCE:HBARUSDT"
    fastLen := 13
    slowLen := 16
    dual := true

// GALA
if sym == "BINANCE:GALAUSDT"
    fastLen := 29
    slowLen := 36
    dual := true

// GRT
if sym == "BINANCE:GRTUSDT"
    fastLen := 14
    slowLen := 35
    dual := true

// IMX
if sym == "BINANCE:IMXUSDT"
    fastLen := 6
    slowLen := 13
    dual := true

// MANA (single)
if sym == "BINANCE:MANAUSDT"
    fastLen := 31
    slowLen := 31
    dual := false

// VET
if sym == "BINANCE:VETUSDT"
    fastLen := 2
    slowLen := 35
    dual := true

// XLM
if sym == "BINANCE:XLMUSDT"
    fastLen := 2
    slowLen := 8
    dual := true

// UNI
if sym == "BINANCE:UNIUSDT"
    fastLen := 18
    slowLen := 21
    dual := true

// FET
if sym == "BINANCE:FETUSDT"
    fastLen := 17
    slowLen := 39
    dual := true

// XTZ (single)
if sym == "BINANCE:XTZUSDT"
    fastLen := 50
    slowLen := 50
    dual := false

// ===============================
// CALCULATIONS (SAFE)
// ===============================
fastMA = ta.sma(close, fastLen)
slowMA = ta.sma(close, slowLen)

// ===============================
// SIGNALS
// ===============================
buy = dual ? ta.crossover(fastMA, slowMA) : ta.crossover(close, fastMA)
sell = dual ? ta.crossunder(fastMA, slowMA) : ta.crossunder(close, fastMA)

// ===============================
// PLOTS
// ===============================
plot(fastMA, color=color.green, linewidth=2, title="Fast SMA")
plot(dual ? slowMA : na, color=color.red, linewidth=2, title="Slow SMA")

plotshape(buy, style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, title="BUY")
plotshape(sell, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, title="SELL")

// ===============================
// BACKGROUND TREND
// ===============================
bgcolor(
    dual ?
        (fastMA > slowMA ? color.new(color.green, 90) : color.new(color.red, 90)) :
        (close > fastMA ? color.new(color.green, 90) : color.new(color.red, 90))
)

// ===============================
// ALERTS
// ===============================
alertcondition(buy, title="BUY ALERT", message="BUY {{ticker}}")
alertcondition(sell, title="SELL ALERT", message="SELL {{ticker}}")
````
