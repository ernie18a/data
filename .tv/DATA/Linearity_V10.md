<!-- tradingview-pine-id: PUB;d53a8d1f94464c8894a2c6faede71bed -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Linearity V1.0

Source: https://www.tradingview.com/script/Y2GaXNMi-Linearity-V1-0/

## Description

Linearity Research — Trend Quality & Move Detection

  This indicator finds clean, low-chop upward price moves ("linear" moves) and scores how good each one is, then rolls those scores up into a single Linearity Score so you can quickly judge whether a stock tends to trend smoothly or in choppy, unreliable swings.

  How a move is detected
  - A move begins when price closes above its EMA (default length 21).
  - It ends only after price closes back below the EMA and then makes a new low below the low of that breakdown bar — a two-step exit that avoids ending a move on a single EMA wick.

  Qualifying a move
  - Persistence = the % of bars in the move that closed above the EMA. This measures how smooth vs. choppy the move was.

Qualifying a move
- Persistence = the % of bars in the move that closed above the EMA. This measures how smooth vs. choppy the move was.
- Smooth moves (persistence ≥ the High Persistence Threshold) only need to clear a lower minimum peak-gain bar to qualify. Choppier moves must clear a higher bar. This keeps ragged-but-large rallies from scoring as well as genuinely straight-line moves.

Per-move score (0–100)
- Peak % gain — 40%
- Efficiency Ratio (net move ÷ total price path traveled; 1.0 = a straight line, lower = more back-and-forth) — 30%
- Persistence — 20%
- Max intra-move drawdown (light penalty) — 5%
- Pullback count (light penalty) — 5%

Linearity Score
Over a configurable lookback window (in years), the script averages the score, peak %, and Efficiency Ratio of every qualifying move, then adds a small bonus for having more qualifying moves (capped), producing one 0–100 Linearity Score. This, along with move count, average peak %, and average ER, is shown in an on-chart panel.

Visuals
- Green boxes mark each qualifying move, labeled with its peak % gain and score.
- Optional EMA plot.
- A configurable bottom panel shows either the Linearity summary or a detailed table of every qualifying move (dates, peak %, ER, persistence, drawdown, pullbacks, duration, score) — position, text size, and colors are all adjustable.

How to use it
Use the Linearity Score to screen for stocks whose historical rallies tend to be smooth and orderly rather than violent and choppy — useful for trend-following or momentum approaches that don't want to fight excessive volatility. Switch the bottom panel to the Detailed Table to audit exactly which historical moves are driving the score.

Note: this script only evaluates upward (bullish) moves triggered by EMA crossovers — it does not detect or score downtrends.

---

## Source Code

````pine
//@version=6
indicator("Linearity V1.0", overlay=true, max_boxes_count=500, max_labels_count=500)

//--------------------------------------------------
// Inputs
//--------------------------------------------------

emaLength = input.int(
     21,
     "EMA Length",
     tooltip="The moving average used to detect trend moves. A move starts when price closes above this EMA, and ends when price breaks back below it. Shorter length = more, smaller moves detected. Longer length = fewer, bigger moves.")

highPersistenceThreshold = input.float(
     0.85,
     "High Persistence Threshold",
     tooltip="A move is 'high persistence' (smooth, non-choppy) if price closes above the EMA for at least this fraction of the move's bars, e.g. 0.85 means 85% of bars. Smooth moves only need to clear the lower 'High Persistence' peak-move bar below; choppier moves are held to the higher 'Low Persistence' bar.")

highPersistenceMoveThreshold = input.float(
     40.0,
     "Min Peak Move % (High Persistence)",
     tooltip="Minimum peak gain % a move must reach to qualify, when that move is smooth enough to clear the High Persistence Threshold above.")
lowPersistenceMoveThreshold = input.float(
     80.0,
     "Min Peak Move % (Low Persistence)",
     tooltip="Minimum peak gain % a move must reach to qualify, when that move is choppier (does not clear the High Persistence Threshold above). Set higher than the high-persistence bar since choppy moves are less reliable.")

pullbackThreshold = input.float(
     5.0,
     "Pullback Threshold %",
     tooltip="How far price must drop (%) from its highest close so far during a move to count as one pullback. Used only to score move quality, not to end the move.")

lookbackYears = input.int(
     5,
     "Lookback Years",
     minval = 1,
     maxval = 20,
     tooltip="How many years of past qualifying moves to include when computing the summary stats (Linearity score, Moves count, Avg Peak, Avg ER) shown in the bottom panel.")

showEMA = input.bool(
     false,
     "Show EMA",
     tooltip="Plot the EMA line on the chart.")
showBoxes = input.bool(
     true,
     "Show Move Boxes",
     tooltip="Draw a green box around each qualifying move, from its start to its end.")
showLabels = input.bool(
     true,
     "Show Labels",
     tooltip="Show a small label at the end of each qualifying move with its peak % gain and move score.")

panelMode = input.string(
     "Summary",
     "Bottom Panel",
     options=["Summary", "Detailed Table", "None"],
     group="Summary Box",
     tooltip="What to show in the on-chart panel: 'Summary' shows Linearity score, move count, avg peak, and avg ER. 'Detailed Table' lists every qualifying move with its stats. 'None' hides the panel.")

summaryPositionInput = input.string(
     "Bottom Right",
     "Panel Position",
     options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"],
     group="Summary Box",
     tooltip="Which corner (or edge) of the chart the panel is pinned to. Applies to both Summary and Detailed Table modes.")

summarySizeInput = input.string(
     "Large",
     "Summary Box Text Size",
     options=["Tiny","Small","Normal","Large","Huge"],
     group="Summary Box",
     tooltip="Text size of the Summary panel's text. Only affects Summary mode, not the Detailed Table.")

summaryTextColor = input.color(
     color.white,
     "Summary Box Text Color",
     group="Summary Box",
     tooltip="Text color of the Summary panel's text. Only affects Summary mode, not the Detailed Table.")
summaryBgColor = input.color(
     color.new(color.black, 20),
     "Summary Box Background Color",
     group="Summary Box",
     tooltip="Background color of the Summary panel. Only affects Summary mode, not the Detailed Table.")

summaryPosition(p) =>
    switch p
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

summarySize(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.large

//--------------------------------------------------
// EMA
//--------------------------------------------------

ema21 = ta.ema(close, emaLength)

plot(
     showEMA ? ema21 : na,
     color=color.orange,
     linewidth=2)

//--------------------------------------------------
// Move State
//--------------------------------------------------

var bool inMove = false

var int moveStartBar = na
var int moveEndBar = na
var int moveStartTime = na

var float moveStartPrice = na

var float moveHigh = na
var float moveLow = na

var int totalBars = 0
var int barsAboveEMA = 0

var float pathLength = 0.0

//--------------------------------------------------
// Drawdown Tracking
//--------------------------------------------------

var float highestCloseSeen = na
var float maxDrawdown = 0.0

var bool inPullback = false
var int pullbackCount = 0

//--------------------------------------------------
// EMA Exit Tracking
//--------------------------------------------------

var bool waitingForBreakdown = false
var float emaViolationLow = na

//--------------------------------------------------
// Arrays
//--------------------------------------------------

var startDates = array.new_string()
var endDates = array.new_string()

var startTimes = array.new_int()

var returnsArr = array.new_float()
var persistenceArr = array.new_float()
var erArr = array.new_float()
var durationArr = array.new_int()

var ddArr = array.new_float()
var pbArr = array.new_int()

var scoreArr = array.new_float()

//--------------------------------------------------
// Helpers
//--------------------------------------------------

dateString(ts) =>
    str.format("{0,date,yyyy-MM-dd}", ts)

//--------------------------------------------------
// Start Detection
//--------------------------------------------------

startCondition =
     not inMove and
     close > ema21 and
     close[1] <= ema21[1]

if startCondition

    inMove := true

    moveStartBar := bar_index
    moveStartTime := time

    moveStartPrice := close

    moveHigh := high
    moveLow := low

    totalBars := 0
    barsAboveEMA := 0

    pathLength := 0

    waitingForBreakdown := false
    emaViolationLow := na

    highestCloseSeen := close
    maxDrawdown := 0

    inPullback := false
    pullbackCount := 0

//--------------------------------------------------
// Tracking
//--------------------------------------------------

if inMove

    totalBars += 1

    moveHigh := math.max(moveHigh, high)
    moveLow := math.min(moveLow, low)

    if close > ema21
        barsAboveEMA += 1

    pathLength += math.abs(close - close[1])

    //--------------------------------------------------
    // Drawdown Logic
    //--------------------------------------------------

    if close > highestCloseSeen

        highestCloseSeen := close
        inPullback := false

    currentDD =
         highestCloseSeen > 0
         ? ((highestCloseSeen - close) / highestCloseSeen) * 100
         : 0

    maxDrawdown := math.max(maxDrawdown, currentDD)

    if currentDD >= pullbackThreshold and not inPullback

        pullbackCount += 1
        inPullback := true

//--------------------------------------------------
// EMA Violation
//--------------------------------------------------

if inMove and not waitingForBreakdown and close < ema21

    waitingForBreakdown := true
    emaViolationLow := low

//--------------------------------------------------
// Recovery
//--------------------------------------------------

if inMove and waitingForBreakdown and close > ema21

    waitingForBreakdown := false
    emaViolationLow := na

//--------------------------------------------------
// Exit Logic
//--------------------------------------------------

endCondition =
     inMove and
     waitingForBreakdown and
     low < emaViolationLow

//--------------------------------------------------
// End Move
//--------------------------------------------------

if endCondition

    moveEndBar := bar_index

    peakReturn =
         ((moveHigh - moveStartPrice) / moveStartPrice) * 100.0

    persistence =
         totalBars > 0
         ? barsAboveEMA / totalBars
         : 0

    netMove =
         math.abs(close - moveStartPrice)

    er =
         pathLength > 0
         ? netMove / pathLength
         : 0

    qualifies =
         persistence >= highPersistenceThreshold
         ? peakReturn >= highPersistenceMoveThreshold
         : peakReturn >= lowPersistenceMoveThreshold

    if qualifies

        //--------------------------------------------------
        // Move Score Components V3.1
        //--------------------------------------------------

        peakScore =
             math.min(
             100.0,
             peakReturn / 1.5)

        // ER 0.30 should already be elite
        erScore =
             math.min(
             100.0,
             er * 330.0)

        persistenceScore =
             persistence * 100.0

        // Much lighter DD penalty
        ddScore =
             math.max(
             0.0,
             100.0 - maxDrawdown * 1.5)

        // Much lighter PB penalty
        pbScore =
             math.max(
             0.0,
             100.0 - pullbackCount * 5.0)

        moveScore =
             peakScore * 0.40 +
             erScore * 0.30 +
             persistenceScore * 0.20 +
             ddScore * 0.05 +
             pbScore * 0.05

        moveScore := math.min(100.0, moveScore)

        startDate = dateString(moveStartTime)
        endDate = dateString(time)

        array.push(startDates, startDate)
        array.push(endDates, endDate)

        array.push(startTimes, moveStartTime)

        array.push(returnsArr, peakReturn)
        array.push(persistenceArr, persistence)
        array.push(erArr, er)
        array.push(durationArr, totalBars)

        array.push(ddArr, maxDrawdown)
        array.push(pbArr, pullbackCount)

        array.push(scoreArr, moveScore)

        //--------------------------------------------------
        // Box
        //--------------------------------------------------

        if showBoxes

            box.new(
                 moveStartBar,
                 moveHigh,
                 moveEndBar,
                 moveLow,
                 bgcolor=color.new(color.green, 92),
                 border_color=color.new(color.lime, 40),
                 border_width=1)

        //--------------------------------------------------
        // Label
        //--------------------------------------------------

        if showLabels

            label.new(
                 moveEndBar,
                 moveHigh,
                 str.format(
                 "{0}%\nS:{1}",
                 str.tostring(peakReturn, "#"),
                 str.tostring(moveScore, "#")),
                 style=label.style_label_down,
                 textcolor=color.white,
                 color=color.new(color.blue, 30),
                 size=size.small)

    inMove := false
    waitingForBreakdown := false
    emaViolationLow := na

//--------------------------------------------------
// LOOKBACK SCORE
//--------------------------------------------------

lookbackStart =
     timenow -
     lookbackYears * 365 * 24 * 60 * 60 * 1000

float scoreSum = 0.0
float peakSum = 0.0
float erSum = 0.0

int moveCount = 0

scoreCount = array.size(scoreArr)

if scoreCount > 0

    for i = 0 to scoreCount - 1

        moveTime = array.get(startTimes, i)

        if moveTime >= lookbackStart

            scoreSum += array.get(scoreArr, i)
            peakSum += array.get(returnsArr, i)
            erSum += array.get(erArr, i)

            moveCount += 1

avgScore =
     moveCount > 0
     ? scoreSum / moveCount
     : 0.0

avgPeak =
     moveCount > 0
     ? peakSum / moveCount
     : 0.0

avgER =
     moveCount > 0
     ? erSum / moveCount
     : 0.0

consistencyBonus =
     math.min(25.0, moveCount * 3.0)

linearityScore =
     math.min(
         100.0,
         avgScore + consistencyBonus)

//--------------------------------------------------
// BOTTOM PANEL (Summary / Detailed Table)
//--------------------------------------------------

var table t = table.new(
     summaryPosition(summaryPositionInput),
     10,
     20,
     border_width=1)

if barstate.islast and panelMode == "Summary"

    table.clear(t, 0, 0, 9, 19)

    table.cell(
     t,
     0,
     0,
     "LINEARITY: " +
     str.tostring(linearityScore, "#.0") +
     "\nMoves: " +
     str.tostring(moveCount) +
     "\nAvg Peak: " +
     str.tostring(avgPeak, "#.1") + "%" +
     "\nAvg ER: " +
     str.tostring(avgER, "#.00"),
     bgcolor=summaryBgColor,
     text_color=summaryTextColor,
     text_size=summarySize(summarySizeInput))

if barstate.islast and panelMode == "Detailed Table"

    headerBg = color.rgb(40,40,40)
    rowBg = color.rgb(20,20,20)

    table.clear(t, 0, 0, 9, 19)

    table.cell(t,0,0,"Move",bgcolor=headerBg,text_color=color.white)
    table.cell(t,1,0,"Start",bgcolor=headerBg,text_color=color.white)
    table.cell(t,2,0,"End",bgcolor=headerBg,text_color=color.white)
    table.cell(t,3,0,"Peak%",bgcolor=headerBg,text_color=color.white)
    table.cell(t,4,0,"ER",bgcolor=headerBg,text_color=color.white)
    table.cell(t,5,0,"Pers",bgcolor=headerBg,text_color=color.white)
    table.cell(t,6,0,"DD%",bgcolor=headerBg,text_color=color.white)
    table.cell(t,7,0,"PB",bgcolor=headerBg,text_color=color.white)
    table.cell(t,8,0,"Days",bgcolor=headerBg,text_color=color.white)
    table.cell(t,9,0,"Score",bgcolor=headerBg,text_color=color.white)

    count = array.size(returnsArr)

    if count > 0

        for i = 0 to math.min(count - 1, 18)

            table.cell(t,0,i+1,str.tostring(i+1),bgcolor=rowBg,text_color=color.white)
            table.cell(t,1,i+1,array.get(startDates,i),bgcolor=rowBg,text_color=color.white)
            table.cell(t,2,i+1,array.get(endDates,i),bgcolor=rowBg,text_color=color.white)
            table.cell(t,3,i+1,str.tostring(array.get(returnsArr,i),"#.1"),bgcolor=rowBg,text_color=color.white)
            table.cell(t,4,i+1,str.tostring(array.get(erArr,i),"#.00"),bgcolor=rowBg,text_color=color.white)
            table.cell(t,5,i+1,str.tostring(array.get(persistenceArr,i)*100,"#.0"),bgcolor=rowBg,text_color=color.white)
            table.cell(t,6,i+1,str.tostring(array.get(ddArr,i),"#.1"),bgcolor=rowBg,text_color=color.white)
            table.cell(t,7,i+1,str.tostring(array.get(pbArr,i)),bgcolor=rowBg,text_color=color.white)
            table.cell(t,8,i+1,str.tostring(array.get(durationArr,i)),bgcolor=rowBg,text_color=color.white)
            table.cell(t,9,i+1,str.tostring(array.get(scoreArr,i),"#.1"),bgcolor=rowBg,text_color=color.white)
````
