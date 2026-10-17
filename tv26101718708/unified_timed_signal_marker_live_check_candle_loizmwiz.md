# Unified Timed Signal Marker - Live Check Candle

- url: https://www.tradingview.com/script/LoIzMWiZ-Unified-Timed-Signal-Marker-Live-Check-Candle/
- type: indicator
- pine_id: PUB;e1f3764c198341958241090b7b3d43a1
- version: 1.0

## Description

**English description summary:**

This indicator checks the 16:40 candle in Israel time, which is used as the signal candle for a potential 16:45 trade.

During the live 16:40 candle, the indicator updates in real time:

* If the candle is currently bullish and long trading is allowed for that day, it shows **LIVE LONG**.
* If the candle is currently bearish and short trading is allowed for that day, it shows **LIVE SHORT**.
* If no valid trade is allowed, it shows **LIVE NO TRADE**.

When the 16:40 candle closes, the signal becomes final and the indicator marks:

* **FINAL LONG**
* **FINAL SHORT**
* **FINAL NO TRADE**

The indicator also respects the configured weekday filters, Friday filters, and direction mode settings: Both, Long Only, or Short Only.

## Source Code

````pine
//@version=6
indicator("Unified Timed Signal Marker - Live Check Candle", overlay=true, max_labels_count=500)

// =========================
// General
// =========================
tz = input.string("Asia/Jerusalem", "Timezone")

// =========================
// Module A - 16:45 NinjaTrader equivalent
// Check candle = 16:40 on 5m chart
// Entry would be on next candle open
// =========================
use1645 = input.bool(true, "Use1645")

direction1645 = input.string("Both", "Direction1645", options=["Both", "LongOnly", "ShortOnly"])

// =========================
// Friday filters
// =========================
tradeLongOnFriday1645 = input.bool(true, "TradeLongOnFriday1645")
tradeShortOnFriday1645 = input.bool(false, "TradeShortOnFriday1645")

// =========================
// Day Filters 16:45 Long
// =========================
tradeLong1645Monday = input.bool(true, "TradeLong1645Monday")
tradeLong1645Tuesday = input.bool(true, "TradeLong1645Tuesday")
tradeLong1645Wednesday = input.bool(true, "TradeLong1645Wednesday")
tradeLong1645Thursday = input.bool(false, "TradeLong1645Thursday")
tradeLong1645Friday = input.bool(true, "TradeLong1645Friday")

// =========================
// Day Filters 16:45 Short
// =========================
tradeShort1645Monday = input.bool(false, "TradeShort1645Monday")
tradeShort1645Tuesday = input.bool(true, "TradeShort1645Tuesday")
tradeShort1645Wednesday = input.bool(true, "TradeShort1645Wednesday")
tradeShort1645Thursday = input.bool(true, "TradeShort1645Thursday")
tradeShort1645Friday = input.bool(false, "TradeShort1645Friday")

// =========================
// Display
// =========================
showLiveLabel = input.bool(true, "Show Live Label During Check Candle")
showFinalLabel = input.bool(true, "Show Final Label After Candle Close")
showNoTradeLabel = input.bool(true, "Show No Trade")
showCheckMarker = input.bool(true, "Show Check Marker")

// =========================
// Time
// =========================
h = hour(time, tz)
m = minute(time, tz)
dow = dayofweek(time, tz)

is1645CheckCandle = h == 16 and m == 40

// =========================
// Candle direction - updates live
// =========================
isBullish = close > open
isBearish = close < open
isDoji = close == open

// =========================
// Day filters - Long
// =========================
passesLong1645Day = true

if dow == dayofweek.monday
    passesLong1645Day := tradeLong1645Monday
else if dow == dayofweek.tuesday
    passesLong1645Day := tradeLong1645Tuesday
else if dow == dayofweek.wednesday
    passesLong1645Day := tradeLong1645Wednesday
else if dow == dayofweek.thursday
    passesLong1645Day := tradeLong1645Thursday
else if dow == dayofweek.friday
    passesLong1645Day := tradeLong1645Friday

// =========================
// Day filters - Short
// =========================
passesShort1645Day = true

if dow == dayofweek.monday
    passesShort1645Day := tradeShort1645Monday
else if dow == dayofweek.tuesday
    passesShort1645Day := tradeShort1645Tuesday
else if dow == dayofweek.wednesday
    passesShort1645Day := tradeShort1645Wednesday
else if dow == dayofweek.thursday
    passesShort1645Day := tradeShort1645Thursday
else if dow == dayofweek.friday
    passesShort1645Day := tradeShort1645Friday

// =========================
// Extra Friday filters
// =========================
passesLongFridayFilter = true
passesShortFridayFilter = true

if dow == dayofweek.friday
    passesLongFridayFilter := tradeLongOnFriday1645
    passesShortFridayFilter := tradeShortOnFriday1645

// =========================
// Direction permission
// =========================
longDirectionAllowed = direction1645 == "Both" or direction1645 == "LongOnly"
shortDirectionAllowed = direction1645 == "Both" or direction1645 == "ShortOnly"

// =========================
// Final conditions
// =========================
validLong1645 =
     use1645 and
     is1645CheckCandle and
     isBullish and
     longDirectionAllowed and
     passesLong1645Day and
     passesLongFridayFilter

validShort1645 =
     use1645 and
     is1645CheckCandle and
     isBearish and
     shortDirectionAllowed and
     passesShort1645Day and
     passesShortFridayFilter

noTrade1645 =
     use1645 and
     is1645CheckCandle and
     not validLong1645 and
     not validShort1645

// =========================
// Live label that updates during the 16:40 candle
// =========================
var label liveLabel = na

if is1645CheckCandle and barstate.isrealtime and showLiveLabel
    if not na(liveLabel)
        label.delete(liveLabel)

    liveText = validLong1645 ? "LIVE LONG\n16:45" :
         validShort1645 ? "LIVE SHORT\n16:45" :
         "LIVE NO TRADE"

    liveColor = validLong1645 ? color.green :
         validShort1645 ? color.red :
         color.gray

    liveY = validLong1645 ? low : high

    liveStyle = validLong1645 ? label.style_label_up : label.style_label_down

    labelLocation = validLong1645 ? yloc.belowbar : yloc.abovebar

    liveLabel := label.new(
         bar_index,
         liveY,
         liveText,
         style=liveStyle,
         textcolor=color.white,
         color=liveColor,
         yloc=labelLocation
    )

// Delete live label once we are no longer on the check candle
if not is1645CheckCandle and not na(liveLabel)
    label.delete(liveLabel)
    liveLabel := na

// =========================
// Final historical marks
// These are confirmed only after candle closes
// =========================
plotshape(
     showFinalLabel and validLong1645 and barstate.isconfirmed,
     title="Final Long 16:45",
     style=shape.labelup,
     location=location.belowbar,
     text="FINAL\nLONG",
     color=color.green,
     textcolor=color.white,
     size=size.small
)

plotshape(
     showFinalLabel and validShort1645 and barstate.isconfirmed,
     title="Final Short 16:45",
     style=shape.labeldown,
     location=location.abovebar,
     text="FINAL\nSHORT",
     color=color.red,
     textcolor=color.white,
     size=size.small
)

plotshape(
     showFinalLabel and showNoTradeLabel and noTrade1645 and barstate.isconfirmed,
     title="Final No Trade 16:45",
     style=shape.labeldown,
     location=location.abovebar,
     text="FINAL\nNO TRADE",
     color=color.gray,
     textcolor=color.white,
     size=size.tiny
)

plotshape(
     showCheckMarker and use1645 and is1645CheckCandle,
     title="16:40 Check Candle",
     style=shape.circle,
     location=location.top,
     text="CHECK",
     color=color.orange,
     textcolor=color.white,
     size=size.tiny
)

// =========================
// Alerts
// =========================
alertcondition(validLong1645, title="Live Long 16:45", message="LIVE LONG 16:45 on {{ticker}}")
alertcondition(validShort1645, title="Live Short 16:45", message="LIVE SHORT 16:45 on {{ticker}}")
alertcondition(noTrade1645, title="Live No Trade 16:45", message="LIVE NO TRADE 16:45 on {{ticker}}")
````
