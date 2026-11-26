# CSM Zohaib

- url: https://www.tradingview.com/script/Jeux2WBf-CSM-Zohaib/
- type: indicator
- pine_id: PUB;11fb2f45ce8046cf9874ef0b7582f800
- version: 1.0

## Description

Its Shows Strenght of currency, Can find good trading setup in currency pair by using this

## Source Code

````pine
//@version=5
indicator("MT4 Style Currency Strength Meter 0-10", overlay=true)

// ===== INPUTS =====
tf = input.timeframe("", "Timeframe")
rsiLen = input.int(14, "RSI Strength Period")
smoothLen = input.int(3, "Smoothing")

// ===== FUNCTION =====
getRSI(sym) =>
    request.security(sym, tf == "" ? timeframe.period : tf, ta.rsi(close, rsiLen))

// ===== PAIRS RSI =====
EURUSD = getRSI("FX:EURUSD")
GBPUSD = getRSI("FX:GBPUSD")
AUDUSD = getRSI("FX:AUDUSD")
NZDUSD = getRSI("FX:NZDUSD")
USDJPY = getRSI("FX:USDJPY")
USDCHF = getRSI("FX:USDCHF")
USDCAD = getRSI("FX:USDCAD")

EURGBP = getRSI("FX:EURGBP")
EURJPY = getRSI("FX:EURJPY")
EURCHF = getRSI("FX:EURCHF")
EURCAD = getRSI("FX:EURCAD")
EURAUD = getRSI("FX:EURAUD")
EURNZD = getRSI("FX:EURNZD")

GBPJPY = getRSI("FX:GBPJPY")
GBPCHF = getRSI("FX:GBPCHF")
GBPCAD = getRSI("FX:GBPCAD")
GBPAUD = getRSI("FX:GBPAUD")
GBPNZD = getRSI("FX:GBPNZD")

AUDJPY = getRSI("FX:AUDJPY")
AUDCHF = getRSI("FX:AUDCHF")
AUDCAD = getRSI("FX:AUDCAD")
AUDNZD = getRSI("FX:AUDNZD")

NZDJPY = getRSI("FX:NZDJPY")
NZDCHF = getRSI("FX:NZDCHF")
NZDCAD = getRSI("FX:NZDCAD")

CADJPY = getRSI("FX:CADJPY")
CADCHF = getRSI("FX:CADCHF")

CHFJPY = getRSI("FX:CHFJPY")

// ===== CURRENCY STRENGTH 0-100 =====
// Base currency = RSI
// Quote currency = 100 - RSI

EUR = (EURUSD + EURGBP + EURJPY + EURCHF + EURCAD + EURAUD + EURNZD) / 7
GBP = ((100 - EURGBP) + GBPUSD + GBPJPY + GBPCHF + GBPCAD + GBPAUD + GBPNZD) / 7
AUD = ((100 - EURAUD) + (100 - GBPAUD) + AUDUSD + AUDJPY + AUDCHF + AUDCAD + AUDNZD) / 7
NZD = ((100 - EURNZD) + (100 - GBPNZD) + (100 - AUDNZD) + NZDUSD + NZDJPY + NZDCHF + NZDCAD) / 7

USD = ((100 - EURUSD) + (100 - GBPUSD) + (100 - AUDUSD) + (100 - NZDUSD) + USDJPY + USDCHF + USDCAD) / 7
JPY = ((100 - EURJPY) + (100 - GBPJPY) + (100 - AUDJPY) + (100 - NZDJPY) + (100 - USDJPY) + (100 - CADJPY) + (100 - CHFJPY)) / 7
CHF = ((100 - EURCHF) + (100 - GBPCHF) + (100 - AUDCHF) + (100 - NZDCHF) + (100 - USDCHF) + (100 - CADCHF) + CHFJPY) / 7
CAD = ((100 - EURCAD) + (100 - GBPCAD) + (100 - AUDCAD) + (100 - NZDCAD) + (100 - USDCAD) + CADJPY + CADCHF) / 7

// ===== SMOOTH AND CONVERT TO 0-10 =====
eurS = ta.ema(EUR, smoothLen) / 10
gbpS = ta.ema(GBP, smoothLen) / 10
audS = ta.ema(AUD, smoothLen) / 10
nzdS = ta.ema(NZD, smoothLen) / 10
usdS = ta.ema(USD, smoothLen) / 10
jpyS = ta.ema(JPY, smoothLen) / 10
chfS = ta.ema(CHF, smoothLen) / 10
cadS = ta.ema(CAD, smoothLen) / 10

// ===== ARRAYS =====
names = array.from("EUR", "GBP", "AUD", "NZD", "USD", "JPY", "CHF", "CAD")
vals  = array.from(eurS, gbpS, audS, nzdS, usdS, jpyS, chfS, cadS)
prevs = array.from(eurS[1], gbpS[1], audS[1], nzdS[1], usdS[1], jpyS[1], chfS[1], cadS[1])

// ===== SORT DESCENDING =====
for i = 0 to 6
    for j = i + 1 to 7
        if array.get(vals, j) > array.get(vals, i)
            v1 = array.get(vals, i)
            n1 = array.get(names, i)
            p1 = array.get(prevs, i)

            array.set(vals, i, array.get(vals, j))
            array.set(names, i, array.get(names, j))
            array.set(prevs, i, array.get(prevs, j))

            array.set(vals, j, v1)
            array.set(names, j, n1)
            array.set(prevs, j, p1)

// ===== TABLE =====
var table t = table.new(position.top_right, 3, 8, border_width=0)

if barstate.islast
    for i = 0 to 7
        name = array.get(names, i)
        val  = array.get(vals, i)
        prev = array.get(prevs, i)

        arrow = val > prev ? "▲" : val < prev ? "▼" : "⇔"
        clr = val >= 6 ? color.lime : val <= 4 ? color.red : color.gray

        table.cell(t, 0, i, str.tostring(i + 1), text_color=clr, text_size=size.large)
        table.cell(t, 1, i, name, text_color=clr, text_size=size.large)
        table.cell(t, 2, i, str.tostring(val, "#.#") + " " + arrow, text_color=clr, text_size=size.large)
````
