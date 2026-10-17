# NY IFVG  First FVG Entry Model

- url: https://www.tradingview.com/script/ujuxtzbF-NY-IFVG-First-FVG-Entry-Model/
- type: indicator
- pine_id: PUB;3e6c7007420147c38f3a9702852e63ba
- version: 1.0

## Description

This indicator detects an intraday NY session entry model based on inverted fair value gaps.

Logic:
1. The model resets at the start of the NY session.
2. It waits for a fair value gap candidate during NY.
3. If price inverts that FVG during the same NY session, the model confirms an IFVG.
4. After the IFVG is confirmed, the script waits for the first same-direction FVG.
5. That first FVG prints a BUY or SELL signal.
6. Only one entry is allowed per NY session by default.

Bullish model:
A bearish FVG forms during NY, price closes above it, creating a bullish IFVG, then the first bullish FVG after that prints BUY.

Bearish model:
A bullish FVG forms during NY, price closes below it, creating a bearish IFVG, then the first bearish FVG after that prints SELL.

The indicator includes optional FVG boxes, IFVG boxes, entry boxes, alerts, and a discreet dashboard.

This is an educational indicator and should not be used as financial advice.

## Source Code

````pine
//@version=6
indicator("NY IFVG → First FVG Entry Model", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupSession = "NY Session"
tz = input.string("America/New_York", "Timezone", options=[
     "America/New_York",
     "GMT-12","GMT-11","GMT-10","GMT-9","GMT-8","GMT-7","GMT-6","GMT-5","GMT-4","GMT-3","GMT-2","GMT-1",
     "GMT+0","GMT+1","GMT+2","GMT+3","GMT+4","GMT+5","GMT+6","GMT+7","GMT+8","GMT+9","GMT+10","GMT+11","GMT+12","GMT+13","GMT+14"
], group=groupSession)

nySession = input.session("0930-1600", "NY Session", group=groupSession)

groupModel = "Model"
useCloseForInversion = input.bool(true, "IFVG requires candle close beyond FVG", group=groupModel)
maxBarsCandidateToIFVG = input.int(40, "Max bars: FVG candidate → IFVG", minval=1, group=groupModel)
maxBarsIFVGToEntry = input.int(40, "Max bars: IFVG → entry FVG", minval=1, group=groupModel)
oneEntryPerNYSession = input.bool(true, "Only one entry per NY session", group=groupModel)

groupVisual = "Visuals"
showCandidateBoxes = input.bool(true, "Show candidate FVG boxes", group=groupVisual)
showIFVGBoxes = input.bool(true, "Show IFVG boxes", group=groupVisual)
showEntryFVGBoxes = input.bool(true, "Show entry FVG boxes", group=groupVisual)
showDashboard = input.bool(true, "Show discreet dashboard", group=groupVisual)

bullColor = input.color(color.lime, "Bullish color", group=groupVisual)
bearColor = input.color(color.red, "Bearish color", group=groupVisual)
ifvgColor = input.color(color.orange, "IFVG color", group=groupVisual)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

inNY = not na(time("", nySession, tz))
nyStart = inNY and not inNY[1]
nyEnd = not inNY and inNY[1]


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FVG DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Bullish FVG:
// candle 0 low is above candle 2 high
bullFVG = low > high[2]
bullFvgTop = low
bullFvgBottom = high[2]

// Bearish FVG:
// candle 0 high is below candle 2 low
bearFVG = high < low[2]
bearFvgTop = low[2]
bearFvgBottom = high


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATE MACHINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 0 = waiting for candidate FVG inside NY
// 1 = candidate FVG found, waiting for inversion inside NY
// 2 = IFVG confirmed, waiting for first same-direction FVG entry inside NY
// 3 = locked until next NY session

var int state = 0

// 1 = bullish IFVG model
// -1 = bearish IFVG model
var int bias = 0

var bool entryUsedThisNY = false

var int candidateBar = na
var int ifvgBar = na

var float candidateTop = na
var float candidateBottom = na

var string candidateType = ""
var string lastEvent = "Waiting"

var int totalBuySignals = 0
var int totalSellSignals = 0

var box candidateBox = na
var box ifvgBox = na
var box entryBox = na


// Reset at NY open
if nyStart
    state := 0
    bias := 0
    entryUsedThisNY := false
    candidateBar := na
    ifvgBar := na
    candidateTop := na
    candidateBottom := na
    candidateType := ""
    lastEvent := "NY open"

// Reset when NY ends
if nyEnd
    state := 0
    bias := 0
    candidateBar := na
    ifvgBar := na
    candidateTop := na
    candidateBottom := na
    candidateType := ""
    lastEvent := "NY closed"


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STEP 1 — WAIT FOR FVG CANDIDATE INSIDE NY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Important:
// For bullish IFVG, we first need a bearish FVG candidate.
// For bearish IFVG, we first need a bullish FVG candidate.

candidateFound = false

canLookForCandidate = inNY and state == 0 and (oneEntryPerNYSession ? not entryUsedThisNY : true)

if canLookForCandidate
    if bearFVG
        state := 1
        bias := 1
        candidateBar := bar_index
        candidateTop := bearFvgTop
        candidateBottom := bearFvgBottom
        candidateType := "Bearish FVG candidate"
        lastEvent := "Bear FVG candidate"
        candidateFound := true

        if showCandidateBoxes
            candidateBox := box.new(
                 left=bar_index[2],
                 top=candidateTop,
                 right=bar_index,
                 bottom=candidateBottom,
                 bgcolor=color.new(bearColor, 88),
                 border_color=color.new(bearColor, 55)
            )

    else if bullFVG
        state := 1
        bias := -1
        candidateBar := bar_index
        candidateTop := bullFvgTop
        candidateBottom := bullFvgBottom
        candidateType := "Bullish FVG candidate"
        lastEvent := "Bull FVG candidate"
        candidateFound := true

        if showCandidateBoxes
            candidateBox := box.new(
                 left=bar_index[2],
                 top=candidateTop,
                 right=bar_index,
                 bottom=candidateBottom,
                 bgcolor=color.new(bullColor, 88),
                 border_color=color.new(bullColor, 55)
            )


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STEP 2 — WAIT FOR IFVG INSIDE NY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Bullish IFVG:
// bearish FVG candidate gets inverted when price closes/trades above candidateTop.
//
// Bearish IFVG:
// bullish FVG candidate gets inverted when price closes/trades below candidateBottom.

bullIFVG = false
bearIFVG = false

if inNY and state == 1 and not na(candidateBar)
    if bar_index > candidateBar
        bullishInversion = useCloseForInversion ? close > candidateTop : high > candidateTop
        bearishInversion = useCloseForInversion ? close < candidateBottom : low < candidateBottom

        if bias == 1 and bullishInversion
            bullIFVG := true
            state := 2
            ifvgBar := bar_index
            lastEvent := "Bullish IFVG"

            if showIFVGBoxes
                ifvgBox := box.new(
                     left=candidateBar - 2,
                     top=candidateTop,
                     right=bar_index,
                     bottom=candidateBottom,
                     bgcolor=color.new(ifvgColor, 82),
                     border_color=color.new(ifvgColor, 25)
                )

        if bias == -1 and bearishInversion
            bearIFVG := true
            state := 2
            ifvgBar := bar_index
            lastEvent := "Bearish IFVG"

            if showIFVGBoxes
                ifvgBox := box.new(
                     left=candidateBar - 2,
                     top=candidateTop,
                     right=bar_index,
                     bottom=candidateBottom,
                     bgcolor=color.new(ifvgColor, 82),
                     border_color=color.new(ifvgColor, 25)
                )


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STEP 3 — FIRST SAME-DIRECTION FVG AFTER IFVG INSIDE NY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

buySignal = false
sellSignal = false

canTakeEntry = inNY and state == 2 and not na(ifvgBar) and bar_index > ifvgBar and (oneEntryPerNYSession ? not entryUsedThisNY : true)

if canTakeEntry
    if bias == 1 and bullFVG
        buySignal := true

    if bias == -1 and bearFVG
        sellSignal := true


if buySignal
    entryUsedThisNY := true
    totalBuySignals += 1
    state := oneEntryPerNYSession ? 3 : 0
    lastEvent := "BUY"

    label.new(
         bar_index,
         low,
         "BUY",
         style=label.style_label_up,
         color=color.new(bullColor, 10),
         textcolor=color.black,
         size=size.tiny
    )

    if showEntryFVGBoxes
        entryBox := box.new(
             left=bar_index[2],
             top=bullFvgTop,
             right=bar_index,
             bottom=bullFvgBottom,
             bgcolor=color.new(bullColor, 86),
             border_color=color.new(bullColor, 30)
        )

    alert("BUY: Bullish IFVG during NY → first bullish FVG after IFVG", alert.freq_once_per_bar_close)

    candidateBar := na
    ifvgBar := na
    candidateTop := na
    candidateBottom := na
    candidateType := ""

if sellSignal
    entryUsedThisNY := true
    totalSellSignals += 1
    state := oneEntryPerNYSession ? 3 : 0
    lastEvent := "SELL"

    label.new(
         bar_index,
         high,
         "SELL",
         style=label.style_label_down,
         color=color.new(bearColor, 10),
         textcolor=color.white,
         size=size.tiny
    )

    if showEntryFVGBoxes
        entryBox := box.new(
             left=bar_index[2],
             top=bearFvgTop,
             right=bar_index,
             bottom=bearFvgBottom,
             bgcolor=color.new(bearColor, 86),
             border_color=color.new(bearColor, 30)
        )

    alert("SELL: Bearish IFVG during NY → first bearish FVG after IFVG", alert.freq_once_per_bar_close)

    candidateBar := na
    ifvgBar := na
    candidateTop := na
    candidateBottom := na
    candidateType := ""


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMEOUT RULES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if inNY and state == 1 and not na(candidateBar)
    if bar_index - candidateBar > maxBarsCandidateToIFVG
        state := 0
        bias := 0
        candidateBar := na
        ifvgBar := na
        candidateTop := na
        candidateBottom := na
        candidateType := ""
        lastEvent := "Candidate timeout"

if inNY and state == 2 and not na(ifvgBar)
    if bar_index - ifvgBar > maxBarsIFVGToEntry
        state := 0
        bias := 0
        candidateBar := na
        ifvgBar := na
        candidateTop := na
        candidateBottom := na
        candidateType := ""
        lastEvent := "Entry timeout"


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARKERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(inNY and bullIFVG, title="Bullish IFVG", style=shape.diamond, location=location.belowbar, color=color.new(ifvgColor, 20), size=size.tiny)
plotshape(inNY and bearIFVG, title="Bearish IFVG", style=shape.diamond, location=location.abovebar, color=color.new(ifvgColor, 20), size=size.tiny)

plotshape(buySignal, title="BUY", style=shape.triangleup, location=location.belowbar, color=color.new(bullColor, 0), size=size.tiny)
plotshape(sellSignal, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.new(bearColor, 0), size=size.tiny)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(buySignal, title="BUY Signal", message="BUY: Bullish IFVG during NY → first bullish FVG after IFVG")
alertcondition(sellSignal, title="SELL Signal", message="SELL: Bearish IFVG during NY → first bearish FVG after IFVG")


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISCREET DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table dash = table.new(position.bottom_right, 2, 6, border_width=0)

if showDashboard and barstate.islast
    stateText = state == 0 ? "Wait FVG" :
         state == 1 ? "Wait IFVG" :
         state == 2 ? "Wait entry" :
         "Locked"

    biasText = bias == 1 ? "Bull" : bias == -1 ? "Bear" : "Neutral"

    bg = color.new(color.black, 88)
    softBg = color.new(color.black, 92)
    muted = color.new(color.white, 45)
    activeCol = bias == 1 ? color.new(bullColor, 15) : bias == -1 ? color.new(bearColor, 15) : muted

    table.cell(dash, 0, 0, "Model", text_color=muted, bgcolor=bg, text_size=size.tiny)
    table.cell(dash, 1, 0, "NY IFVG → FVG", text_color=muted, bgcolor=bg, text_size=size.tiny)

    table.cell(dash, 0, 1, "Session", text_color=muted, bgcolor=softBg, text_size=size.tiny)
    table.cell(dash, 1, 1, inNY ? "NY active" : "Closed", text_color=inNY ? color.new(color.white, 10) : muted, bgcolor=softBg, text_size=size.tiny)

    table.cell(dash, 0, 2, "State", text_color=muted, bgcolor=bg, text_size=size.tiny)
    table.cell(dash, 1, 2, stateText, text_color=color.new(color.white, 20), bgcolor=bg, text_size=size.tiny)

    table.cell(dash, 0, 3, "Bias", text_color=muted, bgcolor=softBg, text_size=size.tiny)
    table.cell(dash, 1, 3, biasText, text_color=activeCol, bgcolor=softBg, text_size=size.tiny)

    table.cell(dash, 0, 4, "Last", text_color=muted, bgcolor=bg, text_size=size.tiny)
    table.cell(dash, 1, 4, lastEvent, text_color=muted, bgcolor=bg, text_size=size.tiny)

    table.cell(dash, 0, 5, "Signals", text_color=muted, bgcolor=softBg, text_size=size.tiny)
    table.cell(dash, 1, 5, str.tostring(totalBuySignals) + " / " + str.tostring(totalSellSignals), text_color=muted, bgcolor=softBg, text_size=size.tiny)
````
