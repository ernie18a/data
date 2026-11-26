# BIEN DONG VA BINH THUONG KHUNG H1

- url: https://www.tradingview.com/script/mrGmMigX-BIEN-DONG-VA-BINH-THUONG-KHUNG-H1/
- type: indicator
- pine_id: PUB;52abae67f6244bc0bf3792efa13e34e2
- version: 1.0

## Description

This indicator classifies market conditions into volatile or normal states using H1 data. It combines RSI(7) and its EMA(14) with price action signals, such as large moves and consecutive candles, to detect volatility. Normal conditions are identified when RSI frequently crosses its EMA within a recent window. The background is color-coded to visually distinguish between the two market regimes.

## Source Code

````pine
//@version=5
indicator("Market Mode H1 Volatile Normal", overlay=true)

movePct = input.float(5.0, "Bien dong H1 toi thieu (%)", step=0.1)
moveMode = input.string("Body", "Cach tinh bien dong", options=["Body", "Range"])

rsiLen = input.int(7, "RSI Length")
emaLen = input.int(14, "RSI EMA Length")

crossLookback = input.int(10, "So nen H1 gan nhat dem RSI cat EMA")
crossNeeded = input.int(4, "So lan cat de vao NORMAL")
showLabels = input.bool(true, "Hien nhan VOL NORMAL")

f_mode() =>
    rsi = ta.rsi(close, rsiLen)
    rsiEma = ta.ema(rsi, emaLen)

    isGreen = close > open
    isRed = close < open

    bodyPct = math.abs(close - open) / open * 100
    rangePct = (high - low) / open * 100
    moveNow = moveMode == "Body" ? bodyPct : rangePct

    bigMove = moveNow > movePct and ((isGreen and rsi > rsiEma) or (isRed and rsi < rsiEma))

    green3 = close > open and close[1] > open[1] and close[2] > open[2] and rsi > rsiEma
    red3 = close < open and close[1] < open[1] and close[2] < open[2] and rsi < rsiEma
    same3 = green3 or red3

    volatileSignal = bigMove or same3

    crossNow = ta.cross(rsi, rsiEma)

    int crossCount = 0
    for i = 0 to 9
        crossCount := crossCount + (crossNow[i] ? 1 : 0)

    normalSignal = crossCount >= crossNeeded

    startVolatile = volatileSignal[1]
    startNormal = normalSignal[1]

    var int state = 0

    if startVolatile
        state := 1
    else if startNormal
        state := 0

    state

mode = request.security(syminfo.tickerid, "60", f_mode(), barmerge.gaps_off, barmerge.lookahead_off)

bgcolor(mode == 1 ? color.new(color.red, 85) : color.new(color.green, 88))

plotshape(showLabels and mode == 1 and mode[1] != 1, title="VOL", style=shape.labeldown, text="VOL", color=color.red, textcolor=color.white, location=location.abovebar, size=size.tiny)

plotshape(showLabels and mode == 0 and mode[1] != 0, title="NORMAL", style=shape.labelup, text="NORMAL", color=color.green, textcolor=color.white, location=location.belowbar, size=size.tiny)
````
