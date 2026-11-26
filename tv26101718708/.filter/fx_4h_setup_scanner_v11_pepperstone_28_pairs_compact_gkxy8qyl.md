# FX 4H Setup Scanner v1.1 - Pepperstone 28 Pairs Compact

- url: https://www.tradingview.com/script/gkxY8qyl-FX-4H-Setup-Scanner-v1-1-Pepperstone-28-Pairs-Compact/
- type: indicator
- pine_id: PUB;1f1d652f14364cd1a5abc41d4f5972d7
- version: 1.0

## Description

FX 4H Setup Scanner v1.1 – Pepperstone 28 Pairs Compact

This indicator is a compact 4H Forex setup scanner designed to monitor the 28 traditional FX pairs available on Pepperstone.

The scanner analyzes the last fully closed 4H candle only and highlights potential bullish or bearish trading setups directly in a table on the chart. It is built to help traders quickly identify pairs that may deserve further manual review, without jumping manually from chart to chart.

What the scanner detects

The script classifies setups into four categories:

C BUY
Continuation Buy setup

C SELL
Continuation Sell setup

R BUY
Reversal Buy setup

R SELL
Reversal Sell setup

If no valid condition is detected, the table displays NO.

Core logic

The scanner combines price-action candle patterns with Bollinger Band context.

It looks for valid signal candles such as:

* Bullish or bearish outside bars
* Bullish or bearish engulfing candles
* Bullish or bearish railroad candles

Each potential signal is then filtered through additional rules, including:

* Bollinger Band position
* Middle Bollinger Band continuation buffer
* 61.8% candle close retracement requirement
* Reversal involvement with the outer Bollinger Band
* Dealbreaker filter when the signal candle touches two Bollinger Band lines

Continuation setups

Continuation setups are detected when the signal candle closes strongly in the direction of the move and remains clearly beyond the middle Bollinger Band, using a configurable pip buffer.

This helps identify potential trend-continuation situations rather than weak candles sitting too close to the mean.

Reversal setups

Reversal setups are detected when the signal candle shows a valid reversal structure and there has been involvement with the outer Bollinger Band, either on the signal candle or within the selected lookback period.

This helps identify potential mean-reversion opportunities after price has stretched toward the outer Bollinger Band.

Closed candle logic

The scanner uses only the last fully closed 4H candle.

This is intentional to reduce repainting risk and avoid signals generated from incomplete candles.

Recommended alert setting:

Once Per Bar

Alerts included

The indicator includes three alert conditions:

1. Any FX 4H setup detected
2. Any BUY setup detected
3. Any SELL setup detected

When an alert triggers, the user should open the chart and review the screener table to identify which pair has generated the signal.

Default symbols

The script is preconfigured for the 28 traditional Forex pairs on Pepperstone, including major pairs and crosses across EUR, GBP, AUD, NZD, USD, JPY, CHF, and CAD.

All symbols are customizable through the script inputs.

Important note

This is a scanner, not an automated trading system.

The purpose of the indicator is to highlight potential areas of interest for further discretionary analysis. Signals should always be validated with broader market context, trend structure, support and resistance, risk management, and personal trading rules.

This script does not provide financial advice and should not be used as a standalone buy or sell recommendation.

## Source Code

````pine
//@version=6
indicator("FX 4H Setup Scanner v1.1 - Pepperstone 28 Pairs Compact", overlay=true, max_labels_count=500)

// =========================
// Inputs
// =========================

tfScan = input.timeframe("240", "Scan Timeframe - 4H")

bbLength = input.int(20, "Bollinger Length")
bbMult = input.float(2.0, "Bollinger Multiplier")

mbbBufferPips = input.float(5.0, "MBB Continuation Buffer in Pips")
fibCloseLevel = input.float(0.618, "Signal Candle Close Minimum Retracement", minval=0.5, maxval=0.9)

railroadBodyTolerance = input.float(0.25, "Railroad Body Tolerance", minval=0.05, maxval=1.0)
railroadPriceTolerancePips = input.float(3.0, "Railroad Open/Close Tolerance in Pips")

bbReversalLookback = input.int(2, "Outer BB Reversal Lookback Candles", minval=0, maxval=5)

showTable = input.bool(true, "Show Screener Table")

// =========================
// Symbols - 28 Traditional FX Pairs on Pepperstone
// =========================

sym01 = input.symbol("PEPPERSTONE:EURUSD", "Pair 01")
sym02 = input.symbol("PEPPERSTONE:GBPUSD", "Pair 02")
sym03 = input.symbol("PEPPERSTONE:AUDUSD", "Pair 03")
sym04 = input.symbol("PEPPERSTONE:NZDUSD", "Pair 04")
sym05 = input.symbol("PEPPERSTONE:USDJPY", "Pair 05")
sym06 = input.symbol("PEPPERSTONE:USDCHF", "Pair 06")
sym07 = input.symbol("PEPPERSTONE:USDCAD", "Pair 07")

sym08 = input.symbol("PEPPERSTONE:EURGBP", "Pair 08")
sym09 = input.symbol("PEPPERSTONE:EURJPY", "Pair 09")
sym10 = input.symbol("PEPPERSTONE:EURCHF", "Pair 10")
sym11 = input.symbol("PEPPERSTONE:EURAUD", "Pair 11")
sym12 = input.symbol("PEPPERSTONE:EURNZD", "Pair 12")
sym13 = input.symbol("PEPPERSTONE:EURCAD", "Pair 13")

sym14 = input.symbol("PEPPERSTONE:GBPJPY", "Pair 14")
sym15 = input.symbol("PEPPERSTONE:GBPCHF", "Pair 15")
sym16 = input.symbol("PEPPERSTONE:GBPAUD", "Pair 16")
sym17 = input.symbol("PEPPERSTONE:GBPNZD", "Pair 17")
sym18 = input.symbol("PEPPERSTONE:GBPCAD", "Pair 18")

sym19 = input.symbol("PEPPERSTONE:AUDJPY", "Pair 19")
sym20 = input.symbol("PEPPERSTONE:AUDCHF", "Pair 20")
sym21 = input.symbol("PEPPERSTONE:AUDNZD", "Pair 21")
sym22 = input.symbol("PEPPERSTONE:AUDCAD", "Pair 22")

sym23 = input.symbol("PEPPERSTONE:NZDJPY", "Pair 23")
sym24 = input.symbol("PEPPERSTONE:NZDCHF", "Pair 24")
sym25 = input.symbol("PEPPERSTONE:NZDCAD", "Pair 25")

sym26 = input.symbol("PEPPERSTONE:CADJPY", "Pair 26")
sym27 = input.symbol("PEPPERSTONE:CADCHF", "Pair 27")
sym28 = input.symbol("PEPPERSTONE:CHFJPY", "Pair 28")

// =========================
// Signal Engine
// Return values:
//  0 = NO SETUP
//  1 = CONT BUY
// -1 = CONT SELL
//  2 = REV BUY
// -2 = REV SELL
// =========================

getSignal() =>
    // Bollinger Bands
    bbBasis = ta.sma(close, bbLength)
    bbDev = bbMult * ta.stdev(close, bbLength)
    bbUpper = bbBasis + bbDev
    bbLower = bbBasis - bbDev
    bbMiddle = bbBasis

    // Pip logic
    pip = syminfo.mintick * 10.0
    mbbBuffer = mbbBufferPips * pip
    railroadPriceTolerance = railroadPriceTolerancePips * pip

    // Candle structure
    candleRange = high - low
    body = math.abs(close - open)
    prevBody = math.abs(close[1] - open[1])

    bullishCandle = close > open
    bearishCandle = close < open
    prevBullish = close[1] > open[1]
    prevBearish = close[1] < open[1]

    validRange = candleRange > 0

    // =========================
    // 1. Signal Candle Type Gate
    // Engulfing / Outside Bar / Railroad
    // =========================

    outsideBar = high > high[1] and low < low[1]

    bullishOutside = outsideBar and bullishCandle
    bearishOutside = outsideBar and bearishCandle

    bullishEngulfing =
         prevBearish and
         bullishCandle and
         open <= close[1] and
         close >= open[1] and
         body > prevBody

    bearishEngulfing =
         prevBullish and
         bearishCandle and
         open >= close[1] and
         close <= open[1] and
         body > prevBody

    similarBodies =
         prevBody > 0 and
         body > 0 and
         math.abs(body - prevBody) / prevBody <= railroadBodyTolerance

    bullishRailroad =
         prevBearish and
         bullishCandle and
         similarBodies and
         math.abs(open - close[1]) <= railroadPriceTolerance and
         math.abs(close - open[1]) <= railroadPriceTolerance

    bearishRailroad =
         prevBullish and
         bearishCandle and
         similarBodies and
         math.abs(open - close[1]) <= railroadPriceTolerance and
         math.abs(close - open[1]) <= railroadPriceTolerance

    bullishSignalCandle =
         bullishOutside or
         bullishEngulfing or
         bullishRailroad

    bearishSignalCandle =
         bearishOutside or
         bearishEngulfing or
         bearishRailroad

    validSignalCandle = bullishSignalCandle or bearishSignalCandle

    // =========================
    // 2. Dealbreaker: Signal Candle Touches 2 BB Lines
    // =========================

    touchesUpper = high >= bbUpper and low <= bbUpper
    touchesMiddle = high >= bbMiddle and low <= bbMiddle
    touchesLower = high >= bbLower and low <= bbLower

    bbTouchCount =
         (touchesUpper ? 1 : 0) +
         (touchesMiddle ? 1 : 0) +
         (touchesLower ? 1 : 0)

    touchesTwoBBLines = bbTouchCount >= 2

    // =========================
    // 3. Dealbreaker: Signal Candle Close Beyond 61.8%
    // =========================

    buyFibLevel = low + candleRange * fibCloseLevel
    sellFibLevel = high - candleRange * fibCloseLevel

    bullishCloseBeyondFib = close >= buyFibLevel
    bearishCloseBeyondFib = close <= sellFibLevel

    // =========================
    // 4. Reversal Outer BB Involvement
    // Signal candle or previous N candles
    // =========================

    lowerBBInvolved =
         low <= bbLower or
         (bbReversalLookback >= 1 and low[1] <= bbLower[1]) or
         (bbReversalLookback >= 2 and low[2] <= bbLower[2]) or
         (bbReversalLookback >= 3 and low[3] <= bbLower[3]) or
         (bbReversalLookback >= 4 and low[4] <= bbLower[4]) or
         (bbReversalLookback >= 5 and low[5] <= bbLower[5])

    upperBBInvolved =
         high >= bbUpper or
         (bbReversalLookback >= 1 and high[1] >= bbUpper[1]) or
         (bbReversalLookback >= 2 and high[2] >= bbUpper[2]) or
         (bbReversalLookback >= 3 and high[3] >= bbUpper[3]) or
         (bbReversalLookback >= 4 and high[4] >= bbUpper[4]) or
         (bbReversalLookback >= 5 and high[5] >= bbUpper[5])

    // =========================
    // 5. Setup Classification
    // =========================

    continuationBuy =
         bullishSignalCandle and
         not touchesTwoBBLines and
         bullishCloseBeyondFib and
         close > bbMiddle + mbbBuffer

    continuationSell =
         bearishSignalCandle and
         not touchesTwoBBLines and
         bearishCloseBeyondFib and
         close < bbMiddle - mbbBuffer

    reversalBuy =
         bullishSignalCandle and
         not touchesTwoBBLines and
         bullishCloseBeyondFib and
         high < bbMiddle and
         lowerBBInvolved

    reversalSell =
         bearishSignalCandle and
         not touchesTwoBBLines and
         bearishCloseBeyondFib and
         low > bbMiddle and
         upperBBInvolved

    signal =
         not validRange ? 0 :
         not validSignalCandle ? 0 :
         continuationBuy ? 1 :
         continuationSell ? -1 :
         reversalBuy ? 2 :
         reversalSell ? -2 :
         0

    signal

// =========================
// Closed 4H candle only
// getSignal()[1] reads the last fully closed 4H candle.
// Use alert frequency: Once Per Bar.
// =========================

s01 = request.security(sym01, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s02 = request.security(sym02, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s03 = request.security(sym03, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s04 = request.security(sym04, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s05 = request.security(sym05, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s06 = request.security(sym06, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s07 = request.security(sym07, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

s08 = request.security(sym08, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s09 = request.security(sym09, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s10 = request.security(sym10, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s11 = request.security(sym11, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s12 = request.security(sym12, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s13 = request.security(sym13, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

s14 = request.security(sym14, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s15 = request.security(sym15, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s16 = request.security(sym16, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s17 = request.security(sym17, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s18 = request.security(sym18, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

s19 = request.security(sym19, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s20 = request.security(sym20, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s21 = request.security(sym21, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s22 = request.security(sym22, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

s23 = request.security(sym23, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s24 = request.security(sym24, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s25 = request.security(sym25, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

s26 = request.security(sym26, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s27 = request.security(sym27, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
s28 = request.security(sym28, tfScan, getSignal()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

// =========================
// Change-over logic
// =========================

newTf = timeframe.change(tfScan)

// =========================
// Display helpers
// =========================

signalText(sig) =>
    labelTxt =
         sig == 1 ? "C BUY" :
         sig == -1 ? "C SELL" :
         sig == 2 ? "R BUY" :
         sig == -2 ? "R SELL" :
         "NO"
    labelTxt

signalColor(sig) =>
    col =
         sig == 1 ? color.new(color.green, 0) :
         sig == 2 ? color.new(color.lime, 10) :
         sig == -1 ? color.new(color.red, 0) :
         sig == -2 ? color.new(color.orange, 0) :
         color.new(color.gray, 88)
    col

cleanSymbol(sym) =>
    str.replace(str.tostring(sym), "PEPPERSTONE:", "")

// =========================
// Table
// =========================

var table screener = table.new(position.top_right, 2, 29, border_width=1)

fillRow(row, sym, sig) =>
    table.cell(
         screener,
         0,
         row,
         cleanSymbol(sym),
         text_color=color.white,
         bgcolor=color.new(color.black, 0),
         text_size=size.small
    )

    table.cell(
         screener,
         1,
         row,
         signalText(sig),
         text_color=color.white,
         bgcolor=signalColor(sig),
         text_size=size.small
    )

if barstate.islast and showTable
    table.cell(
         screener,
         0,
         0,
         "PAIR",
         text_color=color.white,
         bgcolor=color.new(color.black, 0),
         text_size=size.small
    )

    table.cell(
         screener,
         1,
         0,
         "4H",
         text_color=color.white,
         bgcolor=color.new(color.black, 0),
         text_size=size.small
    )

    fillRow(1, sym01, s01)
    fillRow(2, sym02, s02)
    fillRow(3, sym03, s03)
    fillRow(4, sym04, s04)
    fillRow(5, sym05, s05)
    fillRow(6, sym06, s06)
    fillRow(7, sym07, s07)
    fillRow(8, sym08, s08)
    fillRow(9, sym09, s09)
    fillRow(10, sym10, s10)
    fillRow(11, sym11, s11)
    fillRow(12, sym12, s12)
    fillRow(13, sym13, s13)
    fillRow(14, sym14, s14)
    fillRow(15, sym15, s15)
    fillRow(16, sym16, s16)
    fillRow(17, sym17, s17)
    fillRow(18, sym18, s18)
    fillRow(19, sym19, s19)
    fillRow(20, sym20, s20)
    fillRow(21, sym21, s21)
    fillRow(22, sym22, s22)
    fillRow(23, sym23, s23)
    fillRow(24, sym24, s24)
    fillRow(25, sym25, s25)
    fillRow(26, sym26, s26)
    fillRow(27, sym27, s27)
    fillRow(28, sym28, s28)

// =========================
// Alert logic
// =========================

anySetup =
     s01 != 0 or s02 != 0 or s03 != 0 or s04 != 0 or s05 != 0 or s06 != 0 or s07 != 0 or
     s08 != 0 or s09 != 0 or s10 != 0 or s11 != 0 or s12 != 0 or s13 != 0 or
     s14 != 0 or s15 != 0 or s16 != 0 or s17 != 0 or s18 != 0 or
     s19 != 0 or s20 != 0 or s21 != 0 or s22 != 0 or
     s23 != 0 or s24 != 0 or s25 != 0 or
     s26 != 0 or s27 != 0 or s28 != 0

anyBuy =
     s01 > 0 or s02 > 0 or s03 > 0 or s04 > 0 or s05 > 0 or s06 > 0 or s07 > 0 or
     s08 > 0 or s09 > 0 or s10 > 0 or s11 > 0 or s12 > 0 or s13 > 0 or
     s14 > 0 or s15 > 0 or s16 > 0 or s17 > 0 or s18 > 0 or
     s19 > 0 or s20 > 0 or s21 > 0 or s22 > 0 or
     s23 > 0 or s24 > 0 or s25 > 0 or
     s26 > 0 or s27 > 0 or s28 > 0

anySell =
     s01 < 0 or s02 < 0 or s03 < 0 or s04 < 0 or s05 < 0 or s06 < 0 or s07 < 0 or
     s08 < 0 or s09 < 0 or s10 < 0 or s11 < 0 or s12 < 0 or s13 < 0 or
     s14 < 0 or s15 < 0 or s16 < 0 or s17 < 0 or s18 < 0 or
     s19 < 0 or s20 < 0 or s21 < 0 or s22 < 0 or
     s23 < 0 or s24 < 0 or s25 < 0 or
     s26 < 0 or s27 < 0 or s28 < 0

alertAny = newTf and anySetup
alertBuy = newTf and anyBuy
alertSell = newTf and anySell

alertcondition(
     alertAny,
     title="FX 4H Setup Detected",
     message="FX 4H Setup Scanner: setup detected on a CLOSED 4H candle. Open the table and review the highlighted pair."
)

alertcondition(
     alertBuy,
     title="FX 4H BUY Setup Detected",
     message="FX 4H Setup Scanner: BUY setup detected on a CLOSED 4H candle."
)

alertcondition(
     alertSell,
     title="FX 4H SELL Setup Detected",
     message="FX 4H Setup Scanner: SELL setup detected on a CLOSED 4H candle."
)
````
