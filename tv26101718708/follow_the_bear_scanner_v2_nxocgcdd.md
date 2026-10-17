# Follow The Bear Scanner v2

- url: https://www.tradingview.com/script/nxOCgcdd-Follow-The-Bear-Scanner-v2/
- type: indicator
- pine_id: PUB;ff7cc5da03eb4433b4f24c81d715dfdd
- version: 1.0

## Description

FTB Scanner v1.4 - EURUSD & GBPUSD ATR SL

This indicator is a rule-based scanner designed to identify potential Follow The Bear (FTB) short setups on EUR/USD and GBP/USD using a strict, binary logic.

The script does not provide discretionary interpretation, scoring, or trade recommendations. It only highlights a potential setup when all predefined conditions are met.

Purpose

The objective of this scanner is to identify potential short setup candidates on the H1 timeframe, during specific UTC/London session candle closes, based on:

* predefined signal candle structure
* pair-specific EMA context
* London closing time filter
* ATR-based stop loss calculation
* predefined entry level

The indicator is intended as a setup detection tool, not as an automated trading system.

⸻

Supported Markets

The script is designed only for:

* EUR/USD
* GBP/USD

If applied to any other instrument, the script will not generate valid signals.

⸻

Required Timeframe

The script is designed to work on:

* 1H / H1 timeframe only

If applied to another timeframe, the status table will indicate that the correct timeframe is not being used.

⸻

Time Filter

The script uses the candle closing time in:

* Europe/London timezone

This automatically adjusts between GMT and British Summer Time.

By default, the scanner only allows signals on H1 candles closing at:

* 07:00 London time
* 08:00 London time
* 10:00 London time
* 11:00 London time

The candle closing at 09:00 London time is disabled by default (my backtesting doesn't support the 9am candle), but can be enabled from the script inputs if desired.

⸻

Signal Candle Logic

The FTB signal candle is defined using a simple binary rule:

A valid signal candle must:

* have a valid range
* open in the lower half of its own candle range
* close in the lower half of its own candle range

No quality scoring is applied. The condition is either valid or not valid.

⸻

Pair-Specific Context Rules

EUR/USD Rule

A valid EUR/USD setup requires:

* close below EMA 50
* close below EMA 200
* EMA 50 below EMA 200

This means EUR/USD must be in a clearly bearish EMA context.

GBP/USD Rule

A valid GBP/USD setup requires:

* close between EMA 50 and EMA 200

No EMA alignment condition is required for GBP/USD.

⸻

Entry and Stop Loss Logic

When a valid setup is detected, the script calculates:

Entry

* Entry = signal candle low - 1 pip

Stop Loss

* Stop Loss = signal candle high + ATR

The ATR period is configurable and set to 14 by default.

Risk

The script also displays the estimated risk in pips:

* Risk pips = distance between entry and ATR stop loss

⸻

Visual Output

When a valid setup is detected, the script displays:

* a red triangle marker above the signal candle
* a label with:
    * pair
    * timeframe
    * London closing hour
    * entry level
    * ATR stop loss level
    * ATR value
    * estimated risk in pips
    * pair-specific rule applied
* optional entry and stop loss visual levels
* EMA 50 and EMA 200, if enabled

⸻

Alert Functionality

The script includes an alert condition:

* FTB SELL Candidate

Recommended alert frequency:

* Once Per Bar Close

This ensures that alerts are triggered only after the H1 candle has closed.

Alert message:

FTB SELL Candidate detected on {{ticker}} H1. Review required. Entry = signal low - 1 pip. SL = signal high + ATR.

⸻

Status Table

The script includes a small status table showing:

* whether the current pair is supported
* whether the timeframe is H1
* whether the candle is closing during an allowed London time window
* the current London candle close hour

This helps confirm whether the script is being used under the correct conditions.

⸻

Important Notes

This script is a scanner, not a trade execution system.

A signal should be treated only as a candidate for manual review. Before placing any trade, the user should independently assess:

* market structure
* support and resistance
* higher timeframe context
* volatility
* news risk
* spread and liquidity
* risk-to-reward ratio
* personal risk management rules

The script does not guarantee profitable trades and should not be used as standalone financial advice.

⸻

Summary of Setup Logic

A signal is generated only when all required conditions are met:

For EUR/USD

* pair is EUR/USD
* timeframe is H1
* candle closes during an allowed London hour
* candle opens and closes in the lower half of its range
* close is below EMA 50
* close is below EMA 200
* EMA 50 is below EMA 200

For GBP/USD

* pair is GBP/USD
* timeframe is H1
* candle closes during an allowed London hour
* candle opens and closes in the lower half of its range
* close is between EMA 50 and EMA 200

If any required condition is missing, no signal is generated.

## Source Code

````pine
//@version=6
indicator("FTB Scanner v2", overlay=true, max_labels_count=500)

// =========================
// Inputs
// =========================

emaFastLength = input.int(50, "EMA 50 Length")
emaSlowLength = input.int(200, "EMA 200 Length")
atrLength = input.int(14, "ATR Length")

useCloseHour07 = input.bool(true, "Allow candle closing at 07:00 London")
useCloseHour08 = input.bool(true, "Allow candle closing at 08:00 London")
useCloseHour09 = input.bool(false, "Allow candle closing at 09:00 London")
useCloseHour10 = input.bool(true, "Allow candle closing at 10:00 London")
useCloseHour11 = input.bool(true, "Allow candle closing at 11:00 London")

showEma = input.bool(true, "Show EMA 50 / EMA 200")
showLabels = input.bool(true, "Show FTB Labels")
showEntrySlLevels = input.bool(true, "Show Entry / SL levels")

// =========================
// Pair detection
// =========================

symbol = syminfo.ticker

isEURUSD = str.contains(symbol, "EURUSD")
isGBPUSD = str.contains(symbol, "GBPUSD")

validPair = isEURUSD or isGBPUSD

// =========================
// Timeframe check
// =========================

isH1 = timeframe.isminutes and timeframe.multiplier == 60

// =========================
// EMA / ATR calculation
// =========================

ema50 = ta.ema(close, emaFastLength)
ema200 = ta.ema(close, emaSlowLength)
atrValue = ta.atr(atrLength)

plot(showEma ? ema50 : na, title="EMA 50", linewidth=2)
plot(showEma ? ema200 : na, title="EMA 200", linewidth=2)

// =========================
// London closing hour logic
// =========================
// Uses candle close time in Europe/London.
// This automatically handles UK daylight saving time.
// =========================

closeHourLondon = hour(time_close, "Europe/London")

isAllowedCloseHour =
     (closeHourLondon == 7 and useCloseHour07) or
     (closeHourLondon == 8 and useCloseHour08) or
     (closeHourLondon == 9 and useCloseHour09) or
     (closeHourLondon == 10 and useCloseHour10) or
     (closeHourLondon == 11 and useCloseHour11)

// =========================
// Pip logic
// EURUSD and GBPUSD use 0.0001 as 1 pip.
// =========================

pip = 0.0001

entryPrice = low - pip
stopLossPrice = high + atrValue
riskPips = (stopLossPrice - entryPrice) / pip

// =========================
// FTB candle logic
// High Test Candle definition used here:
// Candle opens and closes in the lower half of its own range.
// =========================

candleRange = high - low
midpoint = low + candleRange * 0.5

hasValidRange = candleRange > 0

openInLowerHalf = open <= midpoint
closeInLowerHalf = close <= midpoint

ftbCandleValid =
     hasValidRange and
     openInLowerHalf and
     closeInLowerHalf

// =========================
// Pair-specific context filters
// =========================

// EUR/USD rules:
// - Close below EMA50
// - Close below EMA200
// - EMA50 below EMA200

eurusdContextValid =
     close < ema50 and
     close < ema200 and
     ema50 < ema200

// GBP/USD rules:
// - Close between EMA50 and EMA200 only

upperEma = math.max(ema50, ema200)
lowerEma = math.min(ema50, ema200)

gbpusdContextValid =
     close > lowerEma and
     close < upperEma

// =========================
// Final context logic
// =========================

contextValid =
     isEURUSD ? eurusdContextValid :
     isGBPUSD ? gbpusdContextValid :
     false

// =========================
// Final setup logic
// =========================

ftbSignal =
     validPair and
     isH1 and
     isAllowedCloseHour and
     contextValid and
     ftbCandleValid

// =========================
// Label text
// =========================

pairText =
     isEURUSD ? "EUR/USD" :
     isGBPUSD ? "GBP/USD" :
     "Unsupported pair"

contextText =
     isEURUSD ? "EUR rule: Close < EMA50/200 + EMA50 < EMA200" :
     isGBPUSD ? "GBP rule: Close between EMA50 and EMA200" :
     "No valid context"

labelText =
     "FTB SELL Candidate" +
     "\nPair: " + pairText +
     "\nTF: H1" +
     "\nLondon close: " + str.tostring(closeHourLondon) + ":00" +
     "\nEntry: " + str.tostring(entryPrice, format.mintick) +
     "\nSL ATR: " + str.tostring(stopLossPrice, format.mintick) +
     "\nATR(" + str.tostring(atrLength) + "): " + str.tostring(atrValue, format.mintick) +
     "\nRisk: " + str.tostring(riskPips, "#.0") + " pips" +
     "\n" + contextText +
     "\nReview required"

// =========================
// Plot labels and signal markers
// =========================

if ftbSignal and showLabels
    label.new(
         bar_index,
         high,
         labelText,
         style=label.style_label_down,
         textcolor=color.white,
         color=color.red,
         size=size.small
    )

plotshape(
     ftbSignal,
     title="FTB SELL Signal",
     style=shape.triangledown,
     location=location.abovebar,
     size=size.small,
     text="FTB",
     color=color.red,
     textcolor=color.white
)

// =========================
// Entry / SL visual levels
// =========================

plot(
     showEntrySlLevels and ftbSignal ? entryPrice : na,
     title="FTB Entry",
     style=plot.style_cross,
     linewidth=2
)

plot(
     showEntrySlLevels and ftbSignal ? stopLossPrice : na,
     title="FTB ATR Stop Loss",
     style=plot.style_cross,
     linewidth=2
)

// =========================
// Alerts
// =========================

alertcondition(
     ftbSignal,
     title="FTB SELL Candidate",
     message="FTB SELL Candidate detected on {{ticker}} H1. Review required. Entry = signal low - 1 pip. SL = signal high + ATR."
)

// =========================
// Warning / status table
// =========================

var table warningTable = table.new(position.top_right, 1, 4)

if barstate.islast
    table.cell(
         warningTable,
         0,
         0,
         validPair ? "Pair: OK" : "Pair not supported",
         text_color=validPair ? color.green : color.red
    )

    table.cell(
         warningTable,
         0,
         1,
         isH1 ? "Timeframe: H1 OK" : "Use H1 timeframe",
         text_color=isH1 ? color.green : color.red
    )

    table.cell(
         warningTable,
         0,
         2,
         isAllowedCloseHour ? "FTB time: OK" : "Outside FTB hours",
         text_color=isAllowedCloseHour ? color.green : color.red
    )

    table.cell(
         warningTable,
         0,
         3,
         "London close hour: " + str.tostring(closeHourLondon) + ":00",
         text_color=color.white
    )
````
