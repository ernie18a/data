# 13 EMA Curl Screener - 10m V1.1

- url: https://www.tradingview.com/script/SS7V5iEf-13-EMA-Curl-Screener-10m-V1-1/
- type: indicator
- pine_id: PUB;4eb22df3216d43438e99393e6fe674ab
- version: 1.0

## Description

### 13 EMA Curl Screener – 10m

A Pine Screener designed to identify potential **13 EMA curl and trend-reversal setups** using completed 10-minute candles.

Because TradingView’s Pine Screener does not support a native 10-minute timeframe, the script is run on **5 minutes** and internally builds 10-minute periods aligned with the 9:30 AM ET market open.

The primary signal is a confirmed price cross of the 13 EMA:

* **+1** = completed 10-minute candle crosses and closes above the 13 EMA
* **-1** = completed 10-minute candle crosses and closes below the 13 EMA
* **0** = no fresh cross

Signals are intentionally disabled during the first hour of trading and begin at **10:30 AM ET** to focus on more developed intraday moves and avoid much of the opening volatility.

Additional columns provide context including:

* 13 EMA slope
* Distance from the 13 EMA
* Price position above/below the EMA
* Current 10-minute EMA value
* Last completed 10-minute close
* Bars since the most recent cross

The screener is intended as a **candidate-discovery tool**, not a standalone entry signal. After a cross is detected, the chart should be reviewed visually for the gradual curl or reversal structure surrounding the EMA.

For alerts, use the Pine Screener on the **5-minute timeframe** with **Once Per Bar Close**, since the setup requires confirmation from a completed 10-minute candle.

## Source Code

````pine
//@version=6
indicator("13 EMA Curl Screener - 10m V1.1", overlay=false)

// =====================================================
// 13 EMA CURL SCREENER - 10 MINUTE LOGIC
//
// Run Pine Screener on 5m.
//
// Script internally constructs completed 10-minute
// candles aligned to the 9:30 AM ET market open.
//
// SETUP:
//
// Bullish:
// Completed 10m candle crosses and closes ABOVE
// the 13 EMA.
//
// Bearish:
// Completed 10m candle crosses and closes BELOW
// the 13 EMA.
//
// The EMA cross is the screener signal.
// The gradual curl / reversal structure should then
// be confirmed visually on the chart.
//
// SIGNALS BEGIN AT 10:30 AM ET.
// =====================================================


// =====================================================
// INPUTS
// =====================================================

emaLength = input.int(
     13,
     "EMA Length",
     minval=1)

freshTenMinuteBars = input.int(
     1,
     "Signal freshness (10m bars)",
     minval=0,
     maxval=10)

rthSession = input.session(
     "0930-1600",
     "Regular Session")


// =====================================================
// REQUIRE 5-MINUTE PINE SCREENER
// =====================================================

validTimeframe =
     timeframe.isminutes and
     timeframe.multiplier == 5


// =====================================================
// REGULAR SESSION
// =====================================================

inRTH = not na(
     time(
         timeframe.period,
         rthSession,
         "America/New_York"))


// =====================================================
// SYNTHETIC 10-MINUTE BAR ALIGNMENT
//
// 5m bars:
//
// 9:30 = first half
// 9:35 = second half
//
// The 9:35 bar closes at 9:40,
// completing the 9:30-9:40 10m candle.
// =====================================================

barHour =
     hour(
         time,
         "America/New_York")

barMinute =
     minute(
         time,
         "America/New_York")

minutesFromOpen =
     barHour * 60 +
     barMinute -
     570


secondHalfOfTen =
     inRTH and
     minutesFromOpen >= 5 and
     minutesFromOpen % 10 == 5


tenMinuteBarClosed =
     validTimeframe and
     secondHalfOfTen and
     barstate.isconfirmed


// =====================================================
// SCAN START TIME
//
// No curl signals before 10:30 AM ET.
//
// We use time_close because the 10:20-10:30 candle
// is represented by the 10:25 5m bar.
//
// That bar CLOSES at 10:30 and therefore becomes
// the first eligible 10-minute signal.
// =====================================================

closeHour =
     hour(
         time_close,
         "America/New_York")

closeMinute =
     minute(
         time_close,
         "America/New_York")

closeMinutes =
     closeHour * 60 +
     closeMinute


scanActive =
     inRTH and
     closeMinutes >= 630


// =====================================================
// 10-MINUTE EMA ENGINE
//
// EMA continues calculating before 10:30.
// Only signals are suppressed.
//
// Alpha = 2 / (length + 1)
// =====================================================

alpha =
     2.0 /
     (emaLength + 1.0)


var float ema10 = na

var float previousTenClose = na

var float lastTenClose = na

var float lastEmaSlopePct = na

var float lastDistancePct = na

var int tenBarCount = 0


// =====================================================
// SIGNAL STATE
// =====================================================

var float curlSignal = 0.0

var int signalAge = 100000

var int lastSignalDirection = 0


bool bullCrossEvent = false

bool bearCrossEvent = false


// =====================================================
// PROCESS COMPLETED 10-MINUTE BAR
// =====================================================

if tenMinuteBarClosed

    currentTenClose = close

    previousEma = ema10


    // -------------------------------------------------
    // UPDATE 13 EMA
    // -------------------------------------------------

    newEma =
         na(ema10) ?
         currentTenClose :
         alpha * currentTenClose +
         (1.0 - alpha) * ema10


    // -------------------------------------------------
    // CROSS CONFIRMATION
    //
    // Bull:
    // Previous completed 10m close at/below EMA
    // Current completed 10m close above EMA.
    //
    // Bear:
    // Previous completed 10m close at/above EMA
    // Current completed 10m close below EMA.
    //
    // Signal must occur at or after 10:30 ET.
    // -------------------------------------------------

    emaReady =
         tenBarCount >= emaLength and
         not na(previousTenClose) and
         not na(previousEma)


    if emaReady and scanActive

        bullCrossEvent :=
             previousTenClose <= previousEma and
             currentTenClose > newEma


        bearCrossEvent :=
             previousTenClose >= previousEma and
             currentTenClose < newEma


    // -------------------------------------------------
    // EMA SLOPE
    //
    // Context only.
    // Not required for the setup.
    // -------------------------------------------------

    if not na(previousEma) and previousEma != 0

        lastEmaSlopePct :=
             ((newEma / previousEma) - 1.0) * 100.0


    // -------------------------------------------------
    // DISTANCE FROM EMA
    // -------------------------------------------------

    if newEma != 0

        lastDistancePct :=
             ((currentTenClose / newEma) - 1.0) * 100.0


    // -------------------------------------------------
    // SIGNAL FRESHNESS
    // -------------------------------------------------

    if bullCrossEvent

        lastSignalDirection := 1

        signalAge := 0


    else if bearCrossEvent

        lastSignalDirection := -1

        signalAge := 0


    else

        signalAge += 1


    if signalAge <= freshTenMinuteBars

        curlSignal := lastSignalDirection

    else

        curlSignal := 0.0


    // -------------------------------------------------
    // SAVE COMPLETED 10M VALUES
    // -------------------------------------------------

    ema10 := newEma

    previousTenClose := currentTenClose

    lastTenClose := currentTenClose

    tenBarCount += 1


// =====================================================
// PRICE POSITION RELATIVE TO 13 EMA
// =====================================================

float emaPosition = 0.0


if not na(lastTenClose) and not na(ema10)

    if lastTenClose > ema10
        emaPosition := 1.0

    else if lastTenClose < ema10
        emaPosition := -1.0


// =====================================================
// SCREENER OUTPUTS
// =====================================================

// +1 = fresh bullish 10m 13 EMA cross
// -1 = fresh bearish 10m 13 EMA cross
//  0 = none

plot(
     validTimeframe ? curlSignal : na,
     "10m 13 EMA Curl")


// Positive = 13 EMA rising
// Negative = 13 EMA falling

plot(
     validTimeframe ? lastEmaSlopePct : na,
     "10m EMA Slope %")


// Positive = price above EMA
// Negative = price below EMA

plot(
     validTimeframe ? lastDistancePct : na,
     "10m Distance from EMA %")


// +1 above EMA
// -1 below EMA

plot(
     validTimeframe ? emaPosition : na,
     "10m Above / Below EMA")


// Actual internally calculated 13 EMA

plot(
     validTimeframe ? ema10 : na,
     "10m 13 EMA")


// Last completed synthetic 10-minute close

plot(
     validTimeframe ? lastTenClose : na,
     "10m Close")


// Number of completed 10m bars since signal

plot(
     validTimeframe and signalAge < 100000 ?
     signalAge :
     na,
     "10m Bars Since Cross")


// =====================================================
// ALERT CONDITIONS
//
// Setup requires a completed 10-minute candle.
//
// Run Pine Screener on 5m.
//
// Alert frequency:
// ONCE PER BAR CLOSE
//
// Earliest possible signal:
// 10:30 AM ET.
// =====================================================

alertcondition(
     bullCrossEvent,
     "Bullish 10m 13 EMA Curl",
     "{{ticker}} bullish 10m 13 EMA curl - candle closed above the 13 EMA")

alertcondition(
     bearCrossEvent,
     "Bearish 10m 13 EMA Curl",
     "{{ticker}} bearish 10m 13 EMA curl - candle closed below the 13 EMA")
````
