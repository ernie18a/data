# Breaker Blocks [ITA]

- url: https://www.tradingview.com/script/mDCOrqpZ-Breaker-Blocks-ITA/
- type: indicator
- pine_id: PUB;7ceebc69954e4713aa412162879539b9
- version: 1.0

## Description

🟠 OVERVIEW

Breaker Blocks marks order blocks that failed. Price broke through the zone, so it now acts from the opposite side. Every retest is scored held or failed on the bar it resolved, and the running hold rate for the symbol you are looking at sits in the corner.

Breaker blocks are drawn everywhere. The claim attached to them is that a broken block flips and holds when price comes back to it. That sentence appears in every description of the concept and almost never with a number next to it. This one counts.

🟠 CONCEPTS

* Breaker - An order block that price traded through. The zone is taken from the last opposite candle before the structure break, measured from its body to its wick.
* Structure Break - A close beyond a swing point that was confirmed by Swing Lookback bars on each side.
* Retest - Price trading back into the zone after the break.
* Held - Price closed beyond the far side of the block by Follow-Through within Bars To Decide. Anything else is a fail, including price that touched the zone, reacted, and went nowhere.
* Left Behind - A block price has walked away from by more than Drop Breaker Left Behind is removed. A level price left months ago is not a level, it is a stripe across the chart.

🟠 FEATURES

🔹 Bullish and bearish breakers drawn as zones from the origin candle, extended forward while they are live

🔹 Every retest scored and marked Held or Failed at the bar it resolved, so the count can be read against the chart rather than taken on trust

🔹 A running hold rate in the corner, split bullish and bearish and combined, with the raw counts

🔹 Blocks price has left far behind are dropped instead of extending forever

🔹 All distances measured in ATR, so one setting works on a 5 dollar stock and a 700 dollar index

🔹 Alerts for a breaker forming and for a retest, each side separately

🟠 HOW TO USE

Read the corner first. It says how often, on this symbol and timeframe, a retested breaker actually followed through. A rate near one hundred means the test is too easy and the number is not telling you anything.

The definition matters more than the number. A retest counts as held only if price then closes beyond the far side of the block. Price that touched the zone and stalled is a fail. A test that a reaction alone can pass would pass almost every time.

Follow-Through and Bars To Decide set how strict that is. Raise Follow-Through and the rate falls, because you are asking for a bigger move. The defaults are half an ATR within ten bars.

A breaker is not a signal on its own. It marks a zone where price has already shown it can trade through, and the label says what happened the last time it came back.

🟠 WHAT I MEASURED

QQQ daily: 63% of 258 retests held.
NVDA 15m: 67% of 543 retests held.

The split between bullish and bearish blocks was 71 against 52 on QQQ and 69 against 65 on NVDA, so that gap belongs to the symbol and not to the concept. Two thirds is the figure that held across both.

🟠 CONCLUSION

Drawing the zone is the easy part. Whether it holds when price comes back is a number, it is different on every symbol, and it depends entirely on what you are willing to call holding.

## Source Code

````pine
// © ITA Trading Tools - itamardrori_
//@version=6
indicator("Breaker Blocks [ITA]", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
pivotLen    = input.int(8, "Swing Lookback", minval=3, maxval=30, group="Detection")
maxBlocks   = input.int(5, "Max Active Breakers", minval=1, maxval=20, group="Detection")
lookback    = input.int(20, "Max Bars Back for Origin Candle", minval=5, maxval=50, group="Detection", tooltip="How far back to search for the candle that formed the block")
removeUsed  = input.bool(true, "Remove Breaker After Retest", group="Detection")
// A block price has walked away from is not a level any more, it is a stripe
// across the chart. On QQQ daily two of them sat at 605 with price at 742,
// still extending, because nothing here ever expired a block that was simply
// left behind.
staleDist   = input.float(6.0, "Drop Breaker Left Behind (x ATR)", minval=1.0, maxval=30.0, step=0.5, group="Detection", tooltip="A breaker this far from price with no retest is removed. Set high to keep old zones on screen.")

bullColor   = input.color(color.new(#089981, 75), "Bullish Breaker", group="Style")
bearColor   = input.color(color.new(#f23645, 75), "Bearish Breaker", group="Style")
showLabels  = input.bool(true, "Show Labels", group="Style")
lblSizeStr  = input.string("Normal", "Label Size", options=["Tiny","Small","Normal","Large"], group="Style")

lblSize = lblSizeStr == "Tiny" ? size.tiny : lblSizeStr == "Small" ? size.small : lblSizeStr == "Large" ? size.large : size.normal

bullSolid = #089981
bearSolid = #f23645

// On a 15 minute chart two blocks can form within a bar or two of each other
// and their labels land in the same place. Each side remembers where it last
// wrote, and pushes the next one out of the way instead of on top.
var int   lastBullLbl = -100
var int   lastBearLbl = -100
var float bullLane    = 0.0
var float bearLane    = 0.0

// distances here are all ATR multiples so one setting travels across symbols
atr = ta.atr(14)

// ─── SWING STRUCTURE ─────────────────────────────────────────────────────────
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,  pivotLen, pivotLen)

var float lastPH = na
var float lastPL = na

if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl

// structure breaks
bullBreak = not na(lastPH) and close > lastPH and close[1] <= lastPH
bearBreak = not na(lastPL) and close < lastPL and close[1] >= lastPL

// ─── BREAKER STORAGE ─────────────────────────────────────────────────────────
// A breaker is an order block that failed: price broke through it, so it now
// acts as support/resistance from the opposite side.
var array<box>   bullBreakers = array.new<box>()
var array<box>   bearBreakers = array.new<box>()

// ─── BULLISH BREAKER ─────────────────────────────────────────────────────────
// Formed from the last DOWN candle before a bullish structure break.
// Once price closes back above it, that zone flips to support.
if bullBreak
    int idx = 1
    while idx < lookback and close[idx] >= open[idx]
        idx += 1
    if idx < lookback
        top = math.max(open[idx], close[idx])
        bot = low[idx]
        b = box.new(bar_index - idx, top, bar_index + 10, bot, bgcolor=bullColor, border_color=color.new(bullSolid, 40), border_width=1)
        array.push(bullBreakers, b)
        if showLabels
            bullLane := bar_index - lastBullLbl <= 4 ? bullLane + 1.0 : 0.0
            lastBullLbl := bar_index
            label.new(bar_index - idx, top + atr * (0.8 + bullLane), "Bull Breaker", style=label.style_label_down, color=color.new(bullSolid, 10), textcolor=color.white, size=lblSize)
        if array.size(bullBreakers) > maxBlocks
            box.delete(array.shift(bullBreakers))

// ─── BEARISH BREAKER ─────────────────────────────────────────────────────────
if bearBreak
    int idx = 1
    while idx < lookback and close[idx] <= open[idx]
        idx += 1
    if idx < lookback
        top = high[idx]
        bot = math.min(open[idx], close[idx])
        b = box.new(bar_index - idx, top, bar_index + 10, bot, bgcolor=bearColor, border_color=color.new(bearSolid, 40), border_width=1)
        array.push(bearBreakers, b)
        if showLabels
            bearLane := bar_index - lastBearLbl <= 4 ? bearLane + 1.0 : 0.0
            lastBearLbl := bar_index
            label.new(bar_index - idx, bot - atr * (0.8 + bearLane), "Bear Breaker", style=label.style_label_up, color=color.new(bearSolid, 10), textcolor=color.white, size=lblSize)
        if array.size(bearBreakers) > maxBlocks
            box.delete(array.shift(bearBreakers))

// ─── EXTEND + RETEST ─────────────────────────────────────────────────────────
bullRetest = false
// the box may be deleted on this same bar, so its edges are read out first
float retestTop = na
float retestBot = na
if array.size(bullBreakers) > 0
    for i = array.size(bullBreakers) - 1 to 0
        b = array.get(bullBreakers, i)
        box.set_right(b, bar_index + 10)
        if low <= box.get_top(b) and low >= box.get_bottom(b)
            bullRetest := true
            retestTop := box.get_top(b)
            retestBot := box.get_bottom(b)
            if removeUsed
                box.delete(b)
                array.remove(bullBreakers, i)
        // distance to the nearer edge, on whichever side price ended up. The
        // first version only measured one direction, so a block price had
        // risen past sat on the chart forever.
        else if math.max(close - box.get_top(b), box.get_bottom(b) - close) > atr * staleDist
            box.delete(b)
            array.remove(bullBreakers, i)

bearRetest = false
float retestTopB = na
float retestBotB = na
if array.size(bearBreakers) > 0
    for i = array.size(bearBreakers) - 1 to 0
        b = array.get(bearBreakers, i)
        box.set_right(b, bar_index + 10)
        if high >= box.get_bottom(b) and high <= box.get_top(b)
            bearRetest := true
            retestTopB := box.get_top(b)
            retestBotB := box.get_bottom(b)
            if removeUsed
                box.delete(b)
                array.remove(bearBreakers, i)
        else if math.max(close - box.get_top(b), box.get_bottom(b) - close) > atr * staleDist
            box.delete(b)
            array.remove(bearBreakers, i)

// ─── DID IT ACTUALLY HOLD ────────────────────────────────────────────────────
// Everyone draws breakers. The claim attached to them is that a broken block
// flips and holds when price comes back to it. This counts whether it did.
//
// A retest is scored as HELD only if price then closes beyond the far side of
// the block by Follow-Through within Bars To Decide. Anything else is a FAIL,
// including price that simply sat there. Reacting is not the same as holding,
// and a test that only a reaction can pass would pass almost every time.
grpM       = "Measure"
measure    = input.bool(true, "Count Outcomes", group = grpM)
followThru = input.float(0.5, "Follow-Through (x ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = grpM,
     tooltip = "How far past the block price has to close for the retest to count as held. Measured in ATR so one setting works on a 5 dollar stock and a 700 dollar index.")
decideBars = input.int(10, "Bars To Decide", minval = 2, maxval = 60, group = grpM)

var bool  pBull    = false
var float pBullTop = na
var float pBullBot = na
var int   pBullBar = na
var int   bullHeld = 0
var int   bullFail = 0

var bool  pBear    = false
var float pBearTop = na
var float pBearBot = na
var int   pBearBar = na
var int   bearHeld = 0
var int   bearFail = 0

bullHeldNow = false
bullFailNow = false
bearHeldNow = false
bearFailNow = false

if measure
    // one pending test at a time per side, so two blocks retested on the same
    // bar cannot both claim the same move
    if bullRetest and not pBull
        pBull    := true
        pBullTop := retestTop
        pBullBot := retestBot
        pBullBar := bar_index
    else if pBull
        if close >= pBullTop + atr * followThru
            pBull := false
            bullHeld += 1
            bullHeldNow := true
        else if close < pBullBot or bar_index - pBullBar >= decideBars
            pBull := false
            bullFail += 1
            bullFailNow := true

    if bearRetest and not pBear
        pBear    := true
        pBearTop := retestTopB
        pBearBot := retestBotB
        pBearBar := bar_index
    else if pBear
        if close <= pBearBot - atr * followThru
            pBear := false
            bearHeld += 1
            bearHeldNow := true
        else if close > pBearTop or bar_index - pBearBar >= decideBars
            pBear := false
            bearFail += 1
            bearFailNow := true

// Outcome labels sit further from the bar than the breaker labels, or the two
// land on each other whenever a block is retested soon after it forms.
gap = atr * 2.4
if showLabels and bullHeldNow
    label.new(bar_index, low - gap, "Held", style = label.style_label_up, color = color.new(bullSolid, 10), textcolor = color.white, size = lblSize)
if showLabels and bullFailNow
    label.new(bar_index, high + gap, "Failed", style = label.style_label_down, color = color.new(#787b86, 10), textcolor = color.white, size = lblSize)
if showLabels and bearHeldNow
    label.new(bar_index, high + gap, "Held", style = label.style_label_down, color = color.new(bearSolid, 10), textcolor = color.white, size = lblSize)
if showLabels and bearFailNow
    label.new(bar_index, low - gap, "Failed", style = label.style_label_up, color = color.new(#787b86, 10), textcolor = color.white, size = lblSize)

// ─── THE COUNT ───────────────────────────────────────────────────────────────
rateText(int hits, int total) =>
    total > 0 ? str.tostring(hits / total * 100, "#") + "%  (" + str.tostring(hits) + "/" + str.tostring(total) + ")" : "-"

var table stats = na

if measure and barstate.islast
    if na(stats)
        stats := table.new(position.top_right, 2, 4, border_width = 1)
    table.cell(stats, 0, 0, "BREAKERS HELD", text_color = #d1a44a)
    table.cell(stats, 1, 0, syminfo.ticker + " " + timeframe.period, text_color = #d1a44a)
    table.cell(stats, 0, 1, "Bullish", text_color = bullSolid)
    table.cell(stats, 1, 1, rateText(bullHeld, bullHeld + bullFail), text_color = color.white)
    table.cell(stats, 0, 2, "Bearish", text_color = bearSolid)
    table.cell(stats, 1, 2, rateText(bearHeld, bearHeld + bearFail), text_color = color.white)
    table.cell(stats, 0, 3, "All", text_color = color.gray)
    table.cell(stats, 1, 3, rateText(bullHeld + bearHeld, bullHeld + bearHeld + bullFail + bearFail), text_color = color.white)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(bullBreak,  "Bullish Breaker Formed", "A bullish breaker block has formed")
alertcondition(bearBreak,  "Bearish Breaker Formed", "A bearish breaker block has formed")
alertcondition(bullRetest, "Bullish Breaker Retest", "Price is retesting a bullish breaker")
alertcondition(bearRetest, "Bearish Breaker Retest", "Price is retesting a bearish breaker")
````
