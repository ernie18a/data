<!-- tradingview-pine-id: PUB;e26f99e22e6443628cd387fb8d6f0d17 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# A-B Currency Movement Tool + Live After B - FOREXCOM [TF LOCK]

Source: https://www.tradingview.com/script/huyUXPU4-A-B-Currency-Movement-Tool-FOREXCOM/

## Description

The A–B Currency Movement Tool is a manual forex pair-selection and market-comparison tool designed to analyze how the 8 major currencies behaved during a specific impulse move selected by the trader.

The tool covers:

AUD • NZD • CAD • USD • JPY • EUR • GBP • CHF

and analyzes the 28 unique currency combinations using FOREX.com (FOREXCOM) price data.

How It Works

The trader manually selects two points on the chart:

Point A → Start of the move
Point B → End of the move

The A–B line defines the time window only.

During exactly the same period between A and B, the indicator checks the price movement of all 28 currency pairs.

For each pair:

If price increased from A to B, the base currency gains strength and the quote currency loses strength.
If price decreased from A to B, the quote currency gains strength and the base currency loses strength.

Each currency is therefore compared directly against the other 7 currencies.

Reading the Score

Scores range from +7 to -7.

+7 = Stronger than all 7 currencies
+5 = Stronger than 6 of 7
+3 = Stronger than 5 of 7
+1 = Stronger than 4 of 7

-1 = Weaker than 4 of 7
-3 = Weaker than 5 of 7
-5 = Weaker than 6 of 7
-7 = Weaker than all 7 currencies

The currencies are automatically ranked from strongest to weakest in the top-right table.

---

## Source Code

````pine
//@version=6
indicator("A-B Currency Movement Tool + Live After B - FOREXCOM [TF LOCK]", overlay=true, max_lines_count=5)

//====================================================
// MANUAL POINT A
//====================================================
pointATime = input.time(timestamp("01 Jan 2026 00:00 +0000"), "Point A Time", inline="POINT_A", confirm=true)
pointAPrice = input.price(1.00000, "Point A Price", inline="POINT_A", confirm=true)

//====================================================
// MANUAL POINT B
//====================================================
pointBTime = input.time(timestamp("02 Jan 2026 00:00 +0000"), "Point B Time", inline="POINT_B", confirm=true)
pointBPrice = input.price(1.00000, "Point B Price", inline="POINT_B", confirm=true)

startTime = math.min(pointATime, pointBTime)
endTime = math.max(pointATime, pointBTime)

//====================================================
// DRAW A-B LINE
// Price coordinates are visual only.
// Currency calculations use the selected times.
//====================================================
var line measurementLine = na
if barstate.islast
    if not na(measurementLine)
        line.delete(measurementLine)
    measurementLine := line.new(x1=pointATime, y1=pointAPrice, x2=pointBTime, y2=pointBPrice, xloc=xloc.bar_time, extend=extend.none, width=2)

//====================================================
// LOCKED MEASUREMENT TIMEFRAME
// Choose the timeframe you used when placing A and B.
// A-B and B-NOW will keep using this timeframe even if
// you later change the chart timeframe.
//====================================================
measurementTF = input.timeframe("60", "Measurement Timeframe")

//====================================================
// PAIR MOVEMENT
// Returns two readings for each pair:
// 1) A -> B fixed movement
// 2) B -> NOW live movement
//
// +1 = pair rose
// -1 = pair fell
//  0 = unchanged / unavailable
//====================================================
f_pairDirections(string ticker) =>
    [priceA, priceB, priceNow] = request.security(ticker, measurementTF, [ta.valuewhen(time <= startTime and time_close > startTime, close, 0), ta.valuewhen(time <= endTime and time_close > endTime, close, 0), close], ignore_invalid_symbol=true)
    int abDirection = 0
    int liveDirection = 0
    if not na(priceA) and not na(priceB)
        if priceB > priceA
            abDirection := 1
        else if priceB < priceA
            abDirection := -1
    if time_close > endTime and not na(priceB) and not na(priceNow)
        if priceNow > priceB
            liveDirection := 1
        else if priceNow < priceB
            liveDirection := -1
    [abDirection, liveDirection]

//====================================================
// CURRENCY INDEX
// 0 AUD | 1 NZD | 2 CAD | 3 USD
// 4 JPY | 5 EUR | 6 GBP | 7 CHF
//====================================================
var array<string> currencyNames = array.from("AUD", "NZD", "CAD", "USD", "JPY", "EUR", "GBP", "CHF")

abScores = array.new_int(8, 0)
liveScores = array.new_int(8, 0)

//====================================================
// ADD PAIR RESULT TO A CURRENCY SCORE ARRAY
// Example EURUSD UP: EUR +1, USD -1
//====================================================
f_addResult(array<int> scoreArray, int baseCurrency, int quoteCurrency, int pairDirection) =>
    if pairDirection != 0
        int baseOld = array.get(scoreArray, baseCurrency)
        int quoteOld = array.get(scoreArray, quoteCurrency)
        array.set(scoreArray, baseCurrency, baseOld + pairDirection)
        array.set(scoreArray, quoteCurrency, quoteOld - pairDirection)

//====================================================
// ADD BOTH A-B AND LIVE RESULTS
//====================================================
f_addBoth(int baseCurrency, int quoteCurrency, int abDirection, int liveDirection) =>
    f_addResult(abScores, baseCurrency, quoteCurrency, abDirection)
    f_addResult(liveScores, baseCurrency, quoteCurrency, liveDirection)

//====================================================
// 28 FOREXCOM PAIRS
//====================================================
[audcadAB, audcadLive] = f_pairDirections("FOREXCOM:AUDCAD")
f_addBoth(0, 2, audcadAB, audcadLive)
[audchfAB, audchfLive] = f_pairDirections("FOREXCOM:AUDCHF")
f_addBoth(0, 7, audchfAB, audchfLive)
[audjpyAB, audjpyLive] = f_pairDirections("FOREXCOM:AUDJPY")
f_addBoth(0, 4, audjpyAB, audjpyLive)
[audnzdAB, audnzdLive] = f_pairDirections("FOREXCOM:AUDNZD")
f_addBoth(0, 1, audnzdAB, audnzdLive)
[audusdAB, audusdLive] = f_pairDirections("FOREXCOM:AUDUSD")
f_addBoth(0, 3, audusdAB, audusdLive)

[cadchfAB, cadchfLive] = f_pairDirections("FOREXCOM:CADCHF")
f_addBoth(2, 7, cadchfAB, cadchfLive)
[cadjpyAB, cadjpyLive] = f_pairDirections("FOREXCOM:CADJPY")
f_addBoth(2, 4, cadjpyAB, cadjpyLive)

[chfjpyAB, chfjpyLive] = f_pairDirections("FOREXCOM:CHFJPY")
f_addBoth(7, 4, chfjpyAB, chfjpyLive)

[euraudAB, euraudLive] = f_pairDirections("FOREXCOM:EURAUD")
f_addBoth(5, 0, euraudAB, euraudLive)
[eurcadAB, eurcadLive] = f_pairDirections("FOREXCOM:EURCAD")
f_addBoth(5, 2, eurcadAB, eurcadLive)
[eurchfAB, eurchfLive] = f_pairDirections("FOREXCOM:EURCHF")
f_addBoth(5, 7, eurchfAB, eurchfLive)
[eurgbpAB, eurgbpLive] = f_pairDirections("FOREXCOM:EURGBP")
f_addBoth(5, 6, eurgbpAB, eurgbpLive)
[eurjpyAB, eurjpyLive] = f_pairDirections("FOREXCOM:EURJPY")
f_addBoth(5, 4, eurjpyAB, eurjpyLive)
[eurnzdAB, eurnzdLive] = f_pairDirections("FOREXCOM:EURNZD")
f_addBoth(5, 1, eurnzdAB, eurnzdLive)
[eurusdAB, eurusdLive] = f_pairDirections("FOREXCOM:EURUSD")
f_addBoth(5, 3, eurusdAB, eurusdLive)

[gbpaudAB, gbpaudLive] = f_pairDirections("FOREXCOM:GBPAUD")
f_addBoth(6, 0, gbpaudAB, gbpaudLive)
[gbpcadAB, gbpcadLive] = f_pairDirections("FOREXCOM:GBPCAD")
f_addBoth(6, 2, gbpcadAB, gbpcadLive)
[gbpchfAB, gbpchfLive] = f_pairDirections("FOREXCOM:GBPCHF")
f_addBoth(6, 7, gbpchfAB, gbpchfLive)
[gbpjpyAB, gbpjpyLive] = f_pairDirections("FOREXCOM:GBPJPY")
f_addBoth(6, 4, gbpjpyAB, gbpjpyLive)
[gbpnzdAB, gbpnzdLive] = f_pairDirections("FOREXCOM:GBPNZD")
f_addBoth(6, 1, gbpnzdAB, gbpnzdLive)
[gbpusdAB, gbpusdLive] = f_pairDirections("FOREXCOM:GBPUSD")
f_addBoth(6, 3, gbpusdAB, gbpusdLive)

[nzdcadAB, nzdcadLive] = f_pairDirections("FOREXCOM:NZDCAD")
f_addBoth(1, 2, nzdcadAB, nzdcadLive)
[nzdchfAB, nzdchfLive] = f_pairDirections("FOREXCOM:NZDCHF")
f_addBoth(1, 7, nzdchfAB, nzdchfLive)
[nzdjpyAB, nzdjpyLive] = f_pairDirections("FOREXCOM:NZDJPY")
f_addBoth(1, 4, nzdjpyAB, nzdjpyLive)
[nzdusdAB, nzdusdLive] = f_pairDirections("FOREXCOM:NZDUSD")
f_addBoth(1, 3, nzdusdAB, nzdusdLive)

[usdcadAB, usdcadLive] = f_pairDirections("FOREXCOM:USDCAD")
f_addBoth(3, 2, usdcadAB, usdcadLive)
[usdchfAB, usdchfLive] = f_pairDirections("FOREXCOM:USDCHF")
f_addBoth(3, 7, usdchfAB, usdchfLive)
[usdjpyAB, usdjpyLive] = f_pairDirections("FOREXCOM:USDJPY")
f_addBoth(3, 4, usdjpyAB, usdjpyLive)

//====================================================
// KEEP ORIGINAL A-B RANKING
//====================================================
ranking = array.sort_indices(abScores, order.descending)

//====================================================
// DISPLAY HELPERS
//====================================================
f_scoreString(int value) =>
    value > 0 ? "+" + str.tostring(value) : str.tostring(value)

f_behavior(int value) =>
    string result = "Neutral"
    if value == 7
        result := "7 / 7 Strong"
    else if value == 5
        result := "6 / 7 Strong"
    else if value == 3
        result := "5 / 7 Strong"
    else if value == 1
        result := "4 / 7 Strong"
    else if value == -1
        result := "4 / 7 Weak"
    else if value == -3
        result := "5 / 7 Weak"
    else if value == -5
        result := "6 / 7 Weak"
    else if value == -7
        result := "7 / 7 Weak"
    result

f_displayColor(int value) =>
    value > 0 ? color.green : value < 0 ? color.red : color.gray

//====================================================
// TABLE
// A-B stays fixed.
// B-NOW updates continuously after Point B.
//====================================================
var table strengthTable = table.new(position.top_right, 6, 10, border_width=1)

if barstate.islast
    table.cell(strengthTable, 0, 0, "RANK", text_color=color.white, bgcolor=color.black)
    table.cell(strengthTable, 1, 0, "CURRENCY", text_color=color.white, bgcolor=color.black)
    table.cell(strengthTable, 2, 0, "A → B", text_color=color.white, bgcolor=color.black)
    table.cell(strengthTable, 3, 0, "A → B BEHAVIOR", text_color=color.white, bgcolor=color.black)
    table.cell(strengthTable, 4, 0, "B → NOW", text_color=color.white, bgcolor=color.black)
    table.cell(strengthTable, 5, 0, "LIVE BEHAVIOR", text_color=color.white, bgcolor=color.black)

    for rankNumber = 0 to 7
        int currencyIndex = array.get(ranking, rankNumber)
        string currencyName = array.get(currencyNames, currencyIndex)
        int abScore = array.get(abScores, currencyIndex)
        int liveScore = array.get(liveScores, currencyIndex)
        color abColor = f_displayColor(abScore)
        color liveColor = f_displayColor(liveScore)
        table.cell(strengthTable, 0, rankNumber + 1, str.tostring(rankNumber + 1))
        table.cell(strengthTable, 1, rankNumber + 1, currencyName, text_color=abColor)
        table.cell(strengthTable, 2, rankNumber + 1, f_scoreString(abScore), text_color=abColor)
        table.cell(strengthTable, 3, rankNumber + 1, f_behavior(abScore), text_color=abColor)
        table.cell(strengthTable, 4, rankNumber + 1, f_scoreString(liveScore), text_color=liveColor)
        table.cell(strengthTable, 5, rankNumber + 1, f_behavior(liveScore), text_color=liveColor)

    table.cell(strengthTable, 0, 9, "A-B", text_color=color.gray)
    table.cell(strengthTable, 1, 9, "FOREXCOM", text_color=color.gray)
    table.cell(strengthTable, 2, 9, "28 Pairs", text_color=color.gray)
    table.cell(strengthTable, 3, 9, measurementTF + " Fixed", text_color=color.gray)
    table.cell(strengthTable, 4, 9, "B → NOW", text_color=color.gray)
    table.cell(strengthTable, 5, 9, measurementTF + " LIVE", text_color=color.gray)
````
