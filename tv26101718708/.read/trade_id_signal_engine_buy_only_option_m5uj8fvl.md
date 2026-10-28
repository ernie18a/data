# TRADE ID SIGNAL ENGINE (BUY ONLY OPTION)

- url: https://www.tradingview.com/script/m5Uj8FVL-TRADE-ID-SIGNAL-ENGINE-BUY-ONLY-OPTION/
- type: indicator
- pine_id: PUB;acf13bf05d0346b8956b8abd5fb01062
- version: 1.0

## Description

Trend sinyali takibi V1.0
rsi ve macd kullanılar alım sinyali üretmektedir.

## Source Code

````pine
//@version=6
indicator("TRADE ID SIGNAL ENGINE (BUY ONLY OPTION)", overlay=true)

//━━━━━━━━━━━━━━━━━━━
// INPUT
//━━━━━━━━━━━━━━━━━━━
exitMode = input.string("None", "Exit Mode", options=["None", "Trailing", "Daily Close"])

//━━━━━━━━━━━━━━━━━━━
// INDICATORS
//━━━━━━━━━━━━━━━━━━━
rsi = ta.rsi(close, 14)
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)

//━━━━━━━━━━━━━━━━━━━
// ENTRY
//━━━━━━━━━━━━━━━━━━━
buySignal = ta.crossover(macdLine, signalLine) and (rsi >= 40 and rsi <= 60)

//━━━━━━━━━━━━━━━━━━━
// STATE
//━━━━━━━━━━━━━━━━━━━
var int tradeId = 0
var int activeTradeId = na
var bool inTrade = false
var float entryPrice = na
var int entryBar = na
var float peak = na
var bool level5 = false

//━━━━━━━━━━━━━━━━━━━
// ENTRY ACTION
//━━━━━━━━━━━━━━━━━━━
if buySignal
    tradeId += 1
    activeTradeId := tradeId
    inTrade := true
    entryPrice := close
    entryBar := bar_index
    peak := close
    level5 := false

    label.new(
        bar_index,
        low,
        "🟢 ALIŞ #" + str.tostring(activeTradeId) +
        "\nFiyat: " + str.tostring(close, "#.##"),
        xloc=xloc.bar_index,
        yloc=yloc.price,
        color=color.white,
        textcolor=color.black,
        style=label.style_label_up
    )

//━━━━━━━━━━━━━━━━━━━
// EXIT LOGIC
//━━━━━━━━━━━━━━━━━━━
exitSignal = false

profitPerc = inTrade ? (close - entryPrice) / entryPrice * 100 : na

//━━━━━━━━━━━━━━━━━━━
// ONLY IF EXIT IS ENABLED
//━━━━━━━━━━━━━━━━━━━
if inTrade and exitMode != "None"

    // TRAILING MODE
    if exitMode == "Trailing"
        peak := math.max(peak, close)

        if profitPerc >= 5
            level5 := true

        if close <= entryPrice * 0.98
            exitSignal := true

        if level5 and profitPerc < 5
            exitSignal := true

        if profitPerc >= 10 and close <= peak * 0.95
            exitSignal := true

    // DAILY CLOSE MODE
    isDailyClose = timeframe.change("D")

    if exitMode == "Daily Close" and isDailyClose

        if profitPerc >= 5
            exitSignal := true

        if profitPerc <= -2
            exitSignal := true

//━━━━━━━━━━━━━━━━━━━
// EXIT LABEL
//━━━━━━━━━━━━━━━━━━━
if exitSignal and inTrade

    barsHeld = bar_index - entryBar

    label.new(
        bar_index,
        high,
        "🔴 SATIŞ #" + str.tostring(activeTradeId) +
        "\nFiyat: " + str.tostring(close, "#.##") +
        "\nKâr: %" + str.tostring(profitPerc, "#.##") +
        "\nSüre: " + str.tostring(barsHeld) + " bar",
        xloc=xloc.bar_index,
        yloc=yloc.price,
        color=color.black,
        textcolor=color.white,
        style=label.style_label_down
    )

    inTrade := false
    activeTradeId := na

//━━━━━━━━━━━━━━━━━━━
// RESET
//━━━━━━━━━━━━━━━━━━━
if not inTrade
    peak := na
    level5 := false

//━━━━━━━━━━━━━━━━━━━
// VISUAL
//━━━━━━━━━━━━━━━━━━━
barcolor(buySignal ? color.white : na)
````
