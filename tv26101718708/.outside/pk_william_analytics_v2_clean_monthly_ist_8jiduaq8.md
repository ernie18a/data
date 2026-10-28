# PK William Analytics V2 - Clean Monthly IST

- url: https://www.tradingview.com/script/8jIdUAq8-PK-William-Analytics-V2-Clean-Monthly-IST/
- type: indicator
- pine_id: PUB;86abc9b7d95749d6b0f465c62ef9bfab
- version: 1.0

## Description

🚨 PK WILLOW BUY 🚨

Signal: BULLISH
Action: Buy ATM CE (1 Lot)
Timeframe: 15 Min
Rule: Enter only on signal.
Exit: Next SELL signal only.

No FOMO. No averaging.
Trust the process.

## Source Code

````pine
//@version=6
indicator("PK William Analytics V2 - Clean Monthly IST", overlay=true, max_labels_count=500)

// ===== INPUTS =====
frLen = input.int(5, "Williams Fractal Length")
strikeStep = input.int(50, "Strike Step")
minMovePts = input.float(20, "Minimum Move Points")
showLabels = input.bool(true, "Show Labels")
showDashboard = input.bool(true, "Show Dashboard")

timeMode = input.string("IST", "Label Time Mode", options=["IST", "Chart Time"])

startDate = input.time(timestamp("2026-05-01 09:15 +0530"), "Backtest Start")
endDate   = input.time(timestamp("2026-05-31 15:30 +0530"), "Backtest End")
inRange = time >= startDate and time <= endDate

// ===== FRACTALS =====
frHigh = ta.pivothigh(high, frLen, frLen)
frLow  = ta.pivotlow(low, frLen, frLen)

rawBuy  = not na(frLow)
rawSell = not na(frHigh)

// ===== MEMORY =====
var int activeDir = 0
var float activeEntry = na
var label activeLabel = na
var string activeText = ""

// ===== STATS =====
var int trades = 0
var int wins = 0
var float totalPoints = 0.0
var float bestMove = 0.0
var float worstMove = na

// ===== TIME TEXT =====
// TradingView time formatting can show exchange/UTC differently.
// For India market, IST = UTC + 5:30 = 19,800,000 milliseconds.
getTimeText(t) =>
    istTime = t + 19800000
    timeMode == "IST" ? str.format("{0,date,dd MMM} {0,time,HH:mm}", istTime) : str.format("{0,date,dd MMM} {0,time,HH:mm}", t)

// ===== SIGNALS =====
buySignal = rawBuy and activeDir != 1 and inRange
sellSignal = rawSell and activeDir != -1 and inRange

// ===== BUY =====
if buySignal
    sigPrice = close[frLen]
    sigTime = time[frLen]

    if activeDir == -1 and not na(activeEntry)
        move = activeEntry - sigPrice
        pct = move / activeEntry * 100

        if math.abs(move) >= minMovePts
            totalPoints += math.abs(move)
            trades += 1
            if move > 0
                wins += 1
            bestMove := math.max(bestMove, math.abs(move))
            worstMove := na(worstMove) ? math.abs(move) : math.min(worstMove, math.abs(move))

        if showLabels and not na(activeLabel)
            label.set_text(activeLabel,
                 activeText + "\nFinal: " + str.tostring(move, "#.##") +
                 " pts (" + str.tostring(pct, "#.##") + "%)")

    activeDir := 1
    activeEntry := sigPrice
    atm = math.round(sigPrice / strikeStep) * strikeStep

    activeText :=
         "Bullish Structure\n" +
         "Spot: " + str.tostring(sigPrice, "#.##") + "\n" +
         getTimeText(sigTime) + "\n" +
         "ATM: " + str.tostring(atm) + " CE"

    if showLabels
        activeLabel := label.new(bar_index - frLen, low[frLen],
             activeText + "\nRunning...",
             style=label.style_label_up,
             color=color.green,
             textcolor=color.white)

// ===== SELL =====
if sellSignal
    sigPrice = close[frLen]
    sigTime = time[frLen]

    if activeDir == 1 and not na(activeEntry)
        move = sigPrice - activeEntry
        pct = move / activeEntry * 100

        if math.abs(move) >= minMovePts
            totalPoints += math.abs(move)
            trades += 1
            if move > 0
                wins += 1
            bestMove := math.max(bestMove, math.abs(move))
            worstMove := na(worstMove) ? math.abs(move) : math.min(worstMove, math.abs(move))

        if showLabels and not na(activeLabel)
            label.set_text(activeLabel,
                 activeText + "\nFinal: " + str.tostring(move, "#.##") +
                 " pts (" + str.tostring(pct, "#.##") + "%)")

    activeDir := -1
    activeEntry := sigPrice
    atm = math.round(sigPrice / strikeStep) * strikeStep

    activeText :=
         "Bearish Structure\n" +
         "Spot: " + str.tostring(sigPrice, "#.##") + "\n" +
         getTimeText(sigTime) + "\n" +
         "ATM: " + str.tostring(atm) + " PE"

    if showLabels
        activeLabel := label.new(bar_index - frLen, high[frLen],
             activeText + "\nRunning...",
             style=label.style_label_down,
             color=color.red,
             textcolor=color.white)

// ===== LIVE UPDATE =====
if showLabels and not na(activeLabel) and not na(activeEntry)
    liveMove = activeDir == 1 ? close - activeEntry : activeEntry - close
    livePct = liveMove / activeEntry * 100

    label.set_text(activeLabel,
         activeText + "\nLive: " + str.tostring(liveMove, "#.##") +
         " pts (" + str.tostring(livePct, "#.##") + "%)")

// ===== DASHBOARD =====
var table dash = table.new(position.top_right, 2, 7, border_width=1)

if showDashboard and barstate.islast
    avg = trades > 0 ? totalPoints / trades : 0
    winRate = trades > 0 ? wins / trades * 100 : 0

    table.cell(dash, 0, 0, "PK Willow", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, "Monthly", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 0, 1, "Trades")
    table.cell(dash, 1, 1, str.tostring(trades))
    table.cell(dash, 0, 2, "Total Points")
    table.cell(dash, 1, 2, str.tostring(totalPoints, "#.##"))
    table.cell(dash, 0, 3, "Average")
    table.cell(dash, 1, 3, str.tostring(avg, "#.##"))
    table.cell(dash, 0, 4, "Best / Worst")
    table.cell(dash, 1, 4, str.tostring(bestMove, "#.##") + " / " + str.tostring(worstMove, "#.##"))
    table.cell(dash, 0, 5, "Win Rate")
    table.cell(dash, 1, 5, str.tostring(winRate, "#.##") + "%")
    table.cell(dash, 0, 6, "50% Capture")
    table.cell(dash, 1, 6, str.tostring(totalPoints * 0.5, "#.##"))

// ===== PLOTS =====
plotshape(buySignal, title="BUY", text="BUY",
     style=shape.labelup, location=location.belowbar,
     color=color.green, textcolor=color.white, size=size.tiny, offset=-frLen)

plotshape(sellSignal, title="SELL", text="SELL",
     style=shape.labeldown, location=location.abovebar,
     color=color.red, textcolor=color.white, size=size.tiny, offset=-frLen)  
alertcondition(buySignal, title="PK WILLOW BUY", message="PK WILLOW BUY - BUY ATM CE - 1 LOT")
alertcondition(sellSignal, title="PK WILLOW SELL", message="PK WILLOW SELL - BUY ATM PE - 1 LOT")
````
