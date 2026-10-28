# FX 4H Setup Scanner | Pepperstone 28 Pairs | Continuation & Reve

- url: https://www.tradingview.com/script/NRfsApQx-FX-4H-Setup-Scanner-Pepperstone-28-Pairs-Continuation-Reve/
- type: indicator
- pine_id: PUB;c39494065af742fdbcc6ee9ab06ebd23
- version: 1.0

## Description

FX 4H Setup Scanner | Pepperstone 28 Pairs | Continuation & Reversal Alerts

This indicator is a rule-based 4H Forex setup scanner designed to identify potential Continuation and Reversal setup conditions across the 28 traditional FX pairs using Pepperstone price feeds.

The script is not a trade execution system and does not provide buy or sell recommendations. Its purpose is to alert the trader when a potential setup situation exists, so the chart can be opened and reviewed manually.

The scanner uses a strict, binary logic:
- either a potential setup exists
- or the output remains NO SETUP

No quality score, no discretionary rating, and no automatic trade decision are produced.

Supported broker feed:
All symbols are based on Pepperstone data using the PEPPERSTONE:<PAIR> format.

Supported timeframe:
The scanner is designed for the 4H timeframe only.

The script evaluates only the most recently closed 4H candle. It does not evaluate candles while they are still forming.

Core logic

A potential setup can only exist if the most recently closed 4H candle is one of the following signal candle types:

- Engulfing candle
- Outside bar
- Railroad candle

If the closed candle is not one of these patterns, the scanner returns:

NO SETUP

Signal direction

The direction of the signal candle defines the possible setup direction:

- Bullish signal candle → only CONT BUY or REV BUY can be considered
- Bearish signal candle → only CONT SELL or REV SELL can be considered

A bullish candle cannot generate a sell setup.
A bearish candle cannot generate a buy setup.

Deal breaker logic

The script applies several objective deal breakers before allowing a setup classification.

1. Signal candle touches two Bollinger Band lines

If the signal candle touches two Bollinger Band lines, the setup is invalidated and the output remains NO SETUP.

2. Signal candle close beyond 61.8 percent of its own range

The 61.8 percent level is calculated on the range of the signal candle itself.

For buy setups:
The candle must close above 61.8 percent of its own range from low to high.

For sell setups:
The candle must close below 61.8 percent of its own range from high to low.

If this condition is not met, the output remains NO SETUP.

3. Continuation Middle Bollinger Band rule

For Continuation Buy:
The signal candle must close above the Middle Bollinger Band by the selected pip buffer.

For Continuation Sell:
The signal candle must close below the Middle Bollinger Band by the selected pip buffer.

The default buffer is 5 pips.

4. Reversal Middle Bollinger Band rule

For Reversal Buy:
The signal candle must stay below the Middle Bollinger Band.

For Reversal Sell:
The signal candle must stay above the Middle Bollinger Band.

If the signal candle touches the Middle Bollinger Band in a reversal context, the setup is invalidated.

5. Outer Bollinger Band involvement for reversals

For a Reversal Buy, the Lower Bollinger Band must have been touched or broken by the signal candle or by one of the recent candles within the selected lookback period.

For a Reversal Sell, the Upper Bollinger Band must have been touched or broken by the signal candle or by one of the recent candles within the selected lookback period.

The default lookback is 2 candles.

Output values

The scanner only displays one of five possible outputs:

- NO SETUP
- CONT BUY
- CONT SELL
- REV BUY
- REV SELL

Alerts

The script includes alert conditions for:

- Any setup detected
- Buy setup detected
- Sell setup detected

Recommended alert setting:
Use “Once Per Bar” when creating the TradingView alert.

When an alert is triggered, open the scanner table and review the highlighted pair manually.

Important note

This indicator is designed as a setup opportunity scanner. It does not assess final trade quality.

Before taking any trade, the trader should manually review:
- higher timeframe context
- market structure
- support and resistance
- round numbers
- trendlines
- clean path to target
- risk-to-reward ratio
- spread and liquidity
- economic news
- correlation with other FX pairs

This script is intended to support a disciplined manual trading process, not to replace trader judgment.

## Source Code

````pine
//@version=6
indicator("FX 4H Setup Scanner v1.0 - Pepperstone 28 Pairs", overlay=true, max_labels_count=500)

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
         sig == 1 ? "CONT BUY" :
         sig == -1 ? "CONT SELL" :
         sig == 2 ? "REV BUY" :
         sig == -2 ? "REV SELL" :
         "NO SETUP"
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
    table.cell(screener, 0, row, cleanSymbol(sym), text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(screener, 1, row, signalText(sig), text_color=color.white, bgcolor=signalColor(sig))

if barstate.islast and showTable
    table.cell(screener, 0, 0, "PAIR", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(screener, 1, 0, "4H CLOSED", text_color=color.white, bgcolor=color.new(color.black, 0))

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
