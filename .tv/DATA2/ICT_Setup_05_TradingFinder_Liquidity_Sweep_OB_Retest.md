<!-- tradingview-pine-id: PUB;e1b256d9e8c04a72a36fa2d1de595a49 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ICT Setup 05 [TradingFinder] Liquidity Sweep & OB Retest

Source: https://www.tradingview.com/script/5qXfyxql-ICT-Setup-05-TradingFinder-Liquidity-Sweep-OB-Retest/

## Description

🔵Introduction

Liquidity sweeps are one of those things traders see all the time, but they are easy to misread when viewed on their own. Price can run above a previous high or below a previous low, grab liquidity, and still continue in the same direction. What matters is what happens after the sweep. This indicator was built around that idea, using Liquidity Sweeps, CHoCH, Order Blocks, and OB Retests as parts of one complete setup instead of treating them as separate signals.

The setup starts from the New York Opening Range. Its high and low act as important liquidity references, and the indicator watches for price to sweep either Buy-Side Liquidity (BSL) or Sell-Side Liquidity (SSL). 

[image]https://www.tradingview.com/x/NO3eD8xU/[/image]

After that sweep, it waits for a clear change in structure before considering the move valid. This helps separate a simple liquidity grab from a more meaningful shift in market direction. 
Once a CHoCH is confirmed, the script identifies the relevant Demand or Supply Order Block and waits for price to come back into that area. The BUY or SELL signal does not appear just because an Order Block exists. Price first has to retest the zone and then show a directional reaction back out of it. 

In practice, the full idea is simple:

[*]Liquidity Sweep 
[*]CHoCH
[*]Order Block
[*]Retest
[*]Reaction. 

The indicator also marks Imbalance / Fair Value Gap (FVG) areas that appear after the structural shift. These zones are there to give more context to the move and make displacement easier to read, while the actual trading signal still comes from the Order Block retest and reaction. The result is a cleaner way to follow an ICT-style setup without having to manually connect every Liquidity Sweep, CHoCH, Order Block, Imbalance, and Retest on the chart. 

🔵How to Use

This indicator is designed to be read as a sequence, not as a collection of independent signals. The Liquidity Sweep, CHoCH, Order Block, Imbalance, and BUY/SELL marker are all showing different stages of the same setup. The main idea is to first see liquidity taken from one side of the New York Opening Range, then wait for price structure to shift, and only after that look for a reaction from the Order Block.

The indicator tracks the New York Opening Range from 08:00 to 09:30 New York time and then looks for setups during the 09:30 to 17:00 trading session. The Opening Range high acts as the Buy-Side Liquidity reference, while the Opening Range low acts as the Sell-Side Liquidity reference. A sweep by itself is not considered an entry. The setup only develops further if price confirms a structural change after that liquidity event. 

🟣Buy Setup

The bullish setup is the mirror image of the bearish sequence. It begins when price trades below the low of the New York Opening Range and takes Sell-Side Liquidity (SSL). The Opening Range low is treated as the liquidity reference, and when price moves below it, the SSL sweep is marked on the chart. Again, this sweep should not be read as a BUY signal by itself. It only tells the trader that liquidity below the range has been taken and that a potential bullish setup can now develop. 

After the SSL sweep, the indicator starts looking for the opposite reaction in structure. It searches backward for a bullish candle body and uses the surrounding opening prices to define the bullish structural confirmation level. This level becomes the point price must reclaim before the liquidity sweep is treated as part of a valid bullish reversal sequence. 

[image]https://www.tradingview.com/x/Kk2gMIkb/[/image]

The bullish CHoCH is confirmed when price closes above that calculated structure level within the active life of the setup. Once this happens, the indicator marks the structural change on the chart. The important idea here is that the BUY setup does not assume that every move below the Opening Range low is a reversal. Price must first show that buyers have regained enough control to break the relevant structure. 

After the bullish CHoCH, the indicator identifies and refines a Demand Order Block connected to the move. This becomes the main area to watch for the next stage of the setup. Instead of chasing price immediately after the structure break, the logic waits to see whether price returns to the Demand Order Block. 

When price comes back into the Demand Order Block, the indicator records the retest. At this point, there is still no automatic BUY signal. A retest is only meaningful if price can actually respond from the zone.

The bullish confirmation requires price to print a bullish candle, close above the upper boundary of the Demand Order Block, and finish strongly enough within the candle's own range. This means the reaction needs to show that price has not simply touched the zone but has actually moved back out of it with bullish intent. As with the bearish side, Signal Mode controls how strict this confirmation needs to be. 

[image]https://www.tradingview.com/x/D9ZA7LcP/[/image]

The complete bullish sequence can therefore be read as:

[*]SSL Sweep
[*]Bullish CHoCH
[*]Demand Order Block
[*]OB Retest
[*]Bullish Reaction
[*]BUY

The Demand Order Block is invalidated if price closes below its lower boundary before the required reaction appears. The reaction also has a limited confirmation window after the first retest, so the script does not keep waiting indefinitely for a late bullish candle after price has already spent too much time around the zone. 

A bullish Imbalance / FVG may also appear after the CHoCH when price creates sufficient displacement and leaves an inefficiency between candles. This can provide useful visual context for the strength of the bullish move, especially when the Imbalance and Demand Order Block are located close to each other. However, the Imbalance should be treated as additional context rather than a mandatory entry condition. The BUY signal itself is generated from the confirmed reaction after the Demand Order Block retest. 

The easiest way to read the indicator is therefore to avoid starting from the BUY or SELL marker. Start from the liquidity event and follow the setup forward. When the Sweep, CHoCH, Order Block, Retest, and reaction all belong to the same sequence, the chart becomes much easier to understand and the final signal has clear structural context behind it.

🟣Sell Setup

A bearish setup starts when price trades above the high of the New York Opening Range. This area is treated as Buy-Side Liquidity (BSL) because stops and breakout orders often accumulate above an established high. When price moves above this level, the indicator marks the BSL sweep on the chart. Importantly, the script is looking for the first side of the Opening Range to be taken. If both sides have already been swept, that event is not treated in the same way as the initial one-sided liquidity sweep. 

The BSL sweep is only the beginning of the setup. Price moving above the Opening Range high does not automatically mean that a reversal is coming, and the indicator does not issue a SELL signal at this point. Instead, it starts looking for evidence that the bullish move has lost control and that bearish order flow is beginning to appear.

[image]https://www.tradingview.com/x/8UbVbpLM/[/image]

After the BSL sweep, the script searches backward through recent candles to locate the structural reference used for bearish confirmation. In the current logic, it looks for a bearish candle body and builds the confirmation level from the nearby opening prices around that structure. This level is then monitored as the point price must break to confirm the shift. 
The next important event is the CHoCH. For the bearish setup, price must close below the calculated bearish structure level while the setup is still valid. When that happens, the indicator marks the CHoCH on the chart. 

This is the point where the setup moves from a simple liquidity sweep into a confirmed bearish structural shift. If price does not confirm the break within the allowed life of the setup, the armed condition expires instead of remaining active indefinitely. 

Once the bearish CHoCH is confirmed, the indicator identifies the relevant Supply Order Block associated with that move. The Order Block is refined before being displayed, so the highlighted zone represents the area the script considers most relevant for a potential bearish reaction rather than simply marking an entire candle without refinement. 

From this point, the trader is no longer waiting for another structure break. The focus shifts to the Order Block Retest. The Supply Order Block remains active while price stays within its validity conditions. If price later returns into the block, the indicator records that first interaction as the retest.

A touch of the Order Block alone still does not produce a SELL signal. This distinction is important because price can enter an Order Block, remain inside it, or continue through it without producing a meaningful reaction. The script therefore waits for a bearish response after the retest.

For a bearish signal, price must produce a bearish candle and close back below the lower boundary of the Supply Order Block. The candle must also close sufficiently toward the lower portion of its own range. This additional close-location requirement is used to avoid treating weak or indecisive candles as confirmed bearish reactions. The exact strictness changes with the selected Signal Mode. When these conditions are satisfied, the indicator prints the SELL marker. 

[image]https://www.tradingview.com/x/8kvCkLjq/[/image]

At that stage, the full bearish sequence has been completed:

[*]BSL Sweep
[*]Bearish CHoCH
[*]Supply Order Block
[*]OB Retest
[*]Bearish Reaction
[*]SELL

The Order Block can also become invalid before producing a signal. For a Supply Order Block, a close above the top of the zone invalidates it. The block also has a maximum lifetime of 1000 bars from its origin, so very old zones are not allowed to remain active indefinitely and generate late signals far away from the original setup. 

The chart may also show a bearish Imbalance after the CHoCH. This happens when the move creates the required three-candle Fair Value Gap structure together with sufficient displacement. The Imbalance can help visually confirm that the structural shift was accompanied by aggressive price movement, but it is not required for the SELL marker itself. The actual signal is still based on the Supply Order Block retest and the bearish reaction from that zone. 

🔵Settings

Signal Mode: Controls how selective the setup is. More Signals uses wider confirmation windows and looser reaction requirements to capture more setups. Balanced provides a middle ground between signal frequency and confirmation quality. High Quality applies stricter confirmation conditions, shorter setup windows, stronger displacement requirements, and cancels an active setup when the opposite side of the Opening Range is swept. 

Show Pattern: Shows or hides the structural elements of the setup, including the BSL/SSL liquidity levels and CHoCH markers. Turning it off keeps the underlying logic active while reducing visual information on the chart. 

Show Signals: Shows or hides the BUY and SELL markers generated after a confirmed Order Block retest and reaction. The signal logic itself remains active even when the markers are hidden. 

Order Block: Changes the colors used for bullish Demand Order Blocks and bearish Supply Order Blocks. These zones represent the refined areas monitored for a potential price retest and reaction. 

Imbalance: Controls the colors of bullish and bearish Imbalance areas. These zones are displayed as additional context after the structural shift and do not directly control the BUY or SELL signal. 

Show Opening Range: Displays the New York Opening Range high and low on the chart. These levels are calculated from the 08:00–09:30 New York session and are used as the main liquidity references for the setup. 

Alert: Enables or disables automatic BUY and SELL alerts generated by the indicator. When enabled, the script can notify the trader when a confirmed bullish or bearish signal is completed. 

🔵Conclusion

The ICT Setup 05 [TradingFinder] Liquidity Sweep & OB Retest indicator is built to connect several ICT and Smart Money Concepts into one readable sequence. Instead of treating a Liquidity Sweep, CHoCH, Order Block, Imbalance, and Retest as separate events, it shows how they can develop together around the New York Opening Range and form a complete setup from liquidity grab to reaction.

Its main purpose is to make the structure behind BUY and SELL signals easier to read directly on the chart. By waiting for a Liquidity Sweep, structural confirmation, a refined Order Block, and then a valid retest and reaction, the indicator helps traders focus on context rather than isolated signals. Imbalance zones add another layer of visual information, while the final signal remains centered on the confirmed Order Block reaction.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

// © TradingFinder

//@version=6

indicator("ICT Setup 05 [TradingFinder] Liquidity Sweep & OB Retest", "LS & Order Block", overlay = true, max_bars_back = 5000, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

import TFlab/OrderBlockRefiner_TradingFinder/2 as Refiner

signalMode = input.string("Balanced", "Signal Mode", options = ["More Signals", "Balanced", "High Quality"],

    tooltip = "Signal Mode changes the confirmation strictness. BUY/SELL requires a valid Venom OB retest and a directional close back outside the block. Imbalance remains visual context only.")

ShowPattern = input.bool(true, "Show Pattern")

ShowSignals = input.bool(true, "Show Signals")

DemandColor = input.color(#00B4EB, "Demand OB", inline = "OB")

SupplyColor = input.color(#E7EB00, "Supply OB", inline = "OB")

BullImbalanceColor = input.color(#00C66A, "Bull Imbalance", inline = "FVG")

BearImbalanceColor = input.color(#D72A50, "Bear Imbalance", inline = "FVG")

ShowOpeningRange = input.bool(false, "Show Opening Range")

Alert = input.bool(true, "Alert")

cisdBarBackCheck = signalMode == "More Signals" ? 160 : signalMode == "Balanced" ? 120 : 80

cisdLifeBars = signalMode == "More Signals" ? 180 : signalMode == "Balanced" ? 120 : 75

fvgWaitBars = signalMode == "More Signals" ? 36 : signalMode == "Balanced" ? 24 : 14

displacementATR = signalMode == "More Signals" ? 0.30 : signalMode == "Balanced" ? 0.45 : 0.65

reactionBars = signalMode == "More Signals" ? 6 : signalMode == "Balanced" ? 4 : 3

reactionClosePosition = signalMode == "More Signals" ? 0.52 : signalMode == "Balanced" ? 0.57 : 0.62

cancelOnOppositeSweep = signalMode == "High Quality"

atr = ta.atr(55)

barRange = math.max(high - low, syminfo.mintick)

closeLocation = (close - low) / barRange

body = close - open

absBody = math.abs(body)

OpeningRangeSession = "0800-0930"

TradingSession = "0930-1700"

nyOR = math.sign(nz(time(timeframe.period, OpeningRangeSession, "America/New_York")))

nyTrade = math.sign(nz(time(timeframe.period, TradingSession, "America/New_York")))

newOpeningRange = nyOR == 1 and nz(nyOR[1]) == 0

newTradingSession = nyTrade == 1 and nz(nyTrade[1]) == 0

endTradingSession = nyTrade == 0 and nz(nyTrade[1]) == 1



var contextLines = array.new_line()

var contextLabels = array.new_label()

keepLine(line id, int limit) =>

    array.push(contextLines, id)

    while array.size(contextLines) > limit

        line.delete(array.shift(contextLines))

keepLabel(label id, int limit) =>

    array.push(contextLabels, id)

    while array.size(contextLabels) > limit

        label.delete(array.shift(contextLabels))

drawLevelTag(int x1, int x2, float price, string tagText, bool bullish) =>

    color lineColor = bullish ? color.new(#5BE660, 20) : color.new(#E65B5B, 20)

    color tagColor = bullish ? #A5F2A7 : #DD8E8E

    color txtColor = bullish ? #151515 : #FFFFFF

    line ln = line.new(x1, price, x2, price, xloc = xloc.bar_index, color = lineColor, style = line.style_dotted, width = 1)

    int midX = int(math.round((x1 + x2) / 2.0))

    label lb = label.new(midX, price, tagText, xloc = xloc.bar_index, color = tagColor, textcolor = txtColor, style = label.style_label_center, size = size.small)

    keepLine(ln, 80)

    keepLabel(lb, 80)

// Order Block Data

type OrderBlock

    int direction

    int originBar

    int createdBar

    float top

    float bottom

    bool active

    bool touched

    int touchBar

    array<box> fills

    line topLine

    line bottomLine

var orderBlocks = array.new<OrderBlock>()

deleteOrderBlock(OrderBlock ob) =>

    if array.size(ob.fills) > 0

        for i = 0 to array.size(ob.fills) - 1

            box.delete(array.get(ob.fills, i))

    if not na(ob.topLine)

        line.delete(ob.topLine)

    if not na(ob.bottomLine)

        line.delete(ob.bottomLine)

trimOrderBlocks() =>

    while array.size(orderBlocks) > 12

        OrderBlock oldest = array.shift(orderBlocks)

        deleteOrderBlock(oldest)

createOrderBlock(int direction, int originBar, float zoneTop, float zoneBottom) =>

    color zoneColor = direction == 1 ? DemandColor : SupplyColor

    line topLine = line.new(originBar, zoneTop, bar_index, zoneTop, xloc = xloc.bar_index, color = zoneColor, style = line.style_dashed, width = 1)

    line bottomLine = line.new(originBar, zoneBottom, bar_index, zoneBottom, xloc = xloc.bar_index, color = zoneColor, style = line.style_dashed, width = 1)

    fills = array.new_box()

    float zoneHeight = zoneTop - zoneBottom

    for i = 0 to 20 - 1

        float layerBottom = zoneBottom + zoneHeight * (i / float(20))

        float layerTop = zoneBottom + zoneHeight * ((i + 1) / float(20))

        float rank = direction == 1 ? (i + 1) : (20 - i)

        int transp = int(math.min(95.0, math.round(50.0 + rank * 2.25)))

        box bx = box.new(left = originBar, top = layerTop, right = bar_index, bottom = layerBottom, xloc = xloc.bar_index, bgcolor = color.new(zoneColor, transp), border_color = na)

        array.push(fills, bx)

    OrderBlock.new(direction, originBar, bar_index, zoneTop, zoneBottom, true, false, na, fills, topLine, bottomLine)

setOrderBlockRight(OrderBlock ob, int rightBar) =>

    int maxRightBar = ob.originBar + 1000

    if rightBar <= maxRightBar

        if array.size(ob.fills) > 0

            for i = 0 to array.size(ob.fills) - 1

                box.set_right(array.get(ob.fills, i), rightBar)

        line.set_x2(ob.topLine, rightBar)

        line.set_x2(ob.bottomLine, rightBar)

finishOrderBlock(OrderBlock ob) =>

    ob.active := false

    int finalRight = ob.touched and not na(ob.touchBar) ? ob.touchBar : bar_index

    setOrderBlockRight(ob, finalRight)

//Imbalance Data

type Imbalance

    int direction

    int originBar

    int createdBar

    float top

    float bottom

    bool active

    array<box> fills

    line topLine

    line bottomLine

    label textLabel

var imbalances = array.new<Imbalance>()

deleteImbalance(Imbalance im) =>

    if array.size(im.fills) > 0

        for i = 0 to array.size(im.fills) - 1

            box.delete(array.get(im.fills, i))

    if not na(im.topLine)

        line.delete(im.topLine)

    if not na(im.bottomLine)

        line.delete(im.bottomLine)

    if not na(im.textLabel)

        label.delete(im.textLabel)

trimImbalances() =>

    while array.size(imbalances) > 12

        Imbalance oldest = array.shift(imbalances)

        deleteImbalance(oldest)

createImbalance(int direction, int originBar, float zoneTop, float zoneBottom) =>

    color zoneColor = direction == 1 ? BullImbalanceColor : BearImbalanceColor

    line topLine = line.new(originBar, zoneTop, bar_index, zoneTop, xloc = xloc.bar_index, color = color.new(zoneColor, 5), style = line.style_dashed, width = 2)

    line bottomLine = line.new(originBar, zoneBottom, bar_index, zoneBottom, xloc = xloc.bar_index, color = color.new(zoneColor, 5), style = line.style_dashed, width = 2)

    array<box> fills = array.new<box>()

    float zoneHeight = zoneTop - zoneBottom

    for i = 0 to 20 - 1

        float layerBottom = zoneBottom + zoneHeight * (i / float(20))

        float layerTop = zoneBottom + zoneHeight * ((i + 1) / float(20))

        float rank = direction == 1 ? (i + 1) : (20 - i)

        int transp = int(math.min(92.0, math.round(48.0 + rank * 1.6)))

        box bx = box.new(left = originBar, top = layerTop, right = bar_index, bottom = layerBottom, xloc = xloc.bar_index, bgcolor = color.new(zoneColor, transp), border_color = na)

        array.push(fills, bx)

    label txt = label.new(bar_index, math.avg(zoneTop, zoneBottom), "Imbalance", xloc = xloc.bar_index, color = color.new(color.black, 55), textcolor = color.white, style = label.style_label_center, size = size.small)

    Imbalance.new(direction, originBar, bar_index, zoneTop, zoneBottom, true, fills, topLine, bottomLine, txt)

setImbalanceRight(Imbalance im, int rightBar) =>

    if array.size(im.fills) > 0

        for i = 0 to array.size(im.fills) - 1

            box.set_right(array.get(im.fills, i), rightBar)

    line.set_x2(im.topLine, rightBar)

    line.set_x2(im.bottomLine, rightBar)

    label.set_x(im.textLabel, int(math.round((im.originBar + rightBar) / 2.0)))

finishImbalance(Imbalance im, int rightBar) =>

    im.active := false

    setImbalanceRight(im, rightBar)

//Opening Range

var float openingHigh = na

var float openingLow = na

var int openingStartBar = na

var int openingHighBar = na

var int openingLowBar = na

if newOpeningRange

    openingHigh := high

    openingLow := low

    openingStartBar := bar_index

    openingHighBar := bar_index

    openingLowBar := bar_index

else if nyOR == 1

    if na(openingHigh) or high >= openingHigh

        openingHigh := high

        openingHighBar := bar_index

    if na(openingLow) or low <= openingLow

        openingLow := low

        openingLowBar := bar_index

if ShowOpeningRange and newTradingSession and not na(openingHigh) and not na(openingLow)

    line hi = line.new(bar_index, openingHigh, bar_index + 45, openingHigh, xloc = xloc.bar_index, color = color.new(#7D8A9D, 45), style = line.style_dotted)

    line lo = line.new(bar_index, openingLow, bar_index + 45, openingLow, xloc = xloc.bar_index, color = color.new(#7D8A9D, 45), style = line.style_dotted)

    keepLine(hi, 30)

    keepLine(lo, 30)

//Pattern state

var bool highSwept = false

var bool lowSwept = false

var int tradingStartBar = na

var float highOB = na

var float lowOB = na

var int bearOBIndex = na

var int bullOBIndex = na

var bool bearCisdArmed = false

var bool bullCisdArmed = false

var float bearCisdLevel = na

var float bullCisdLevel = na

var int bearCisdIndex = na

var int bullCisdIndex = na

var int bearSweepBar = na

var int bullSweepBar = na

var bool waitingBearFVG = false

var bool waitingBullFVG = false

var int bearChochBar = na

var int bullChochBar = na

var bool bearFVGReady = false

var bool bullFVGReady = false

var int activeBearFVGArrayIndex = na

var int activeBullFVGArrayIndex = na

var int bearFVGBar = na

var int bullFVGBar = na

if newTradingSession

    tradingStartBar := bar_index

    highSwept := false

    lowSwept := false

    highOB := high

    lowOB := low

    bearOBIndex := bar_index

    bullOBIndex := bar_index

    bearCisdArmed := false

    bullCisdArmed := false

    waitingBearFVG := false

    waitingBullFVG := false

    bearFVGReady := false

    bullFVGReady := false

    activeBearFVGArrayIndex := na

    activeBullFVGArrayIndex := na

    bearFVGBar := na

    bullFVGBar := na

bool prevHighSwept = highSwept

bool prevLowSwept = lowSwept

if nyTrade == 1

    if na(highOB) or high > highOB

        highOB := high

        bearOBIndex := bar_index

    if na(lowOB) or low < lowOB

        lowOB := low

        bullOBIndex := bar_index

    if not na(openingHigh) and high > openingHigh

        highSwept := true

    if not na(openingLow) and low < openingLow

        lowSwept := true

bool newHighSweep = barstate.isconfirmed and nyTrade == 1 and highSwept and not prevHighSwept and not lowSwept

bool newLowSweep = barstate.isconfirmed and nyTrade == 1 and lowSwept and not prevLowSwept and not highSwept

if ShowPattern and newHighSweep and not na(openingHigh)

    int x1 = not na(openingHighBar) ? openingHighBar : math.max(bar_index - 15, 0)

    drawLevelTag(x1, bar_index, openingHigh, "BSL", false)

if ShowPattern and newLowSweep and not na(openingLow)

    int x1 = not na(openingLowBar) ? openingLowBar : math.max(bar_index - 15, 0)

    drawLevelTag(x1, bar_index, openingLow, "SSL", true)

// CISD logic follows the supplied Venom implementation rather than the looser

// v6 scan restriction. Visual name is CHoCH to match the supplied examples.

if newHighSweep

    bearSweepBar := bar_index

    bearCisdArmed := false

    bearCisdLevel := na

    bearCisdIndex := na

    bool foundBearBody = false

    for i = 1 to cisdBarBackCheck

        if not foundBearBody and not na(body[i]) and body[i] < 0

            bearCisdLevel := i > 1 ? math.min(open[i - 1], open[i - 2]) : open[i - 1]

            bearCisdIndex := i > 1 ? (math.min(open[i - 1], open[i - 2]) == open[i - 2] ? bar_index[i - 2] : bar_index[i - 1]) : bar_index[i - 1]

            bearCisdArmed := true

            foundBearBody := true

if newLowSweep

    bullSweepBar := bar_index

    bullCisdArmed := false

    bullCisdLevel := na

    bullCisdIndex := na

    bool foundBullBody = false

    for i = 1 to cisdBarBackCheck

        if not foundBullBody and not na(body[i]) and body[i] > 0

            bullCisdLevel := i > 1 ? math.max(open[i - 1], open[i - 2]) : open[i - 1]

            bullCisdIndex := i > 1 ? (math.max(open[i - 1], open[i - 2]) == open[i - 2] ? bar_index[i - 2] : bar_index[i - 1]) : bar_index[i - 1]

            bullCisdArmed := true

            foundBullBody := true



if cancelOnOppositeSweep and nyTrade == 1

    if bearCisdArmed and lowSwept

        bearCisdArmed := false

    if bullCisdArmed and highSwept

        bullCisdArmed := false

bool bullChochTrigger = false

bool bearChochTrigger = false

if barstate.isconfirmed and nyTrade == 1

    if bearCisdArmed and not na(bearCisdLevel) and not na(bearSweepBar)

        if bar_index - bearSweepBar <= cisdLifeBars

            if close <= bearCisdLevel

                bearCisdArmed := false

                bearChochTrigger := true

                bearChochBar := bar_index

                waitingBearFVG := true

                if ShowPattern and not na(bearCisdIndex)

                    drawLevelTag(bearCisdIndex, bar_index, bearCisdLevel, "ChoCh", false)

        else

            bearCisdArmed := false

    if bullCisdArmed and not na(bullCisdLevel) and not na(bullSweepBar)

        if bar_index - bullSweepBar <= cisdLifeBars

            if close >= bullCisdLevel

                bullCisdArmed := false

                bullChochTrigger := true

                bullChochBar := bar_index

                waitingBullFVG := true

                if ShowPattern and not na(bullCisdIndex)

                    drawLevelTag(bullCisdIndex, bar_index, bullCisdLevel, "ChoCh", true)

        else

            bullCisdArmed := false



[Bu_Xd1, Bu_Xd2, Bu_Yd12, Bu_Xp1, Bu_Xp2, Bu_Yp12] = Refiner.OBRefiner("Demand", "On", "Aggressive", bullChochTrigger, bullOBIndex)

[Be_Xd1, Be_Xd2, Be_Yd12, Be_Xp1, Be_Xp2, Be_Yp12] = Refiner.OBRefiner("Supply", "On", "Aggressive", bearChochTrigger, bearOBIndex)

bool bullishOBCreated = false

bool bearishOBCreated = false

if bullChochTrigger

    float zoneTop = math.max(Bu_Yd12, Bu_Yp12)

    float zoneBottom = math.min(Bu_Yd12, Bu_Yp12)

    int zoneBar = Bu_Xd1

    if not na(zoneBar) and not na(zoneTop) and not na(zoneBottom) and zoneTop > zoneBottom

        OrderBlock ob = createOrderBlock(1, zoneBar, zoneTop, zoneBottom)

        array.push(orderBlocks, ob)

        trimOrderBlocks()

        bullishOBCreated := true

if bearChochTrigger

    float zoneTop = math.max(Be_Yd12, Be_Yp12)

    float zoneBottom = math.min(Be_Yd12, Be_Yp12)

    int zoneBar = Be_Xd1

    if not na(zoneBar) and not na(zoneTop) and not na(zoneBottom) and zoneTop > zoneBottom

        OrderBlock ob = createOrderBlock(-1, zoneBar, zoneTop, zoneBottom)

        array.push(orderBlocks, ob)

        trimOrderBlocks()

        bearishOBCreated := true



bool bullFVG = barstate.isconfirmed and low > high[2] and close > open and absBody >= atr * displacementATR

bool bearFVG = barstate.isconfirmed and high < low[2] and close < open and absBody >= atr * displacementATR

if waitingBullFVG and not na(bullChochBar)

    if bar_index - bullChochBar > fvgWaitBars

        waitingBullFVG := false

    else if bullFVG and bar_index >= bullChochBar

        float fvgTop = low

        float fvgBottom = high[2]

        Imbalance im = createImbalance(1, bar_index - 2, fvgTop, fvgBottom)

        array.push(imbalances, im)

        trimImbalances()

        activeBullFVGArrayIndex := array.size(imbalances) - 1

        bullFVGBar := bar_index

        bullFVGReady := true

        waitingBullFVG := false

if waitingBearFVG and not na(bearChochBar)

    if bar_index - bearChochBar > fvgWaitBars

        waitingBearFVG := false

    else if bearFVG and bar_index >= bearChochBar

        float fvgTop = low[2]

        float fvgBottom = high

        Imbalance im = createImbalance(-1, bar_index - 2, fvgTop, fvgBottom)

        array.push(imbalances, im)

        trimImbalances()

        activeBearFVGArrayIndex := array.size(imbalances) - 1

        bearFVGBar := bar_index

        bearFVGReady := true

        waitingBearFVG := false

if barstate.isconfirmed and array.size(orderBlocks) > 0

    for i = 0 to array.size(orderBlocks) - 1

        OrderBlock ob = array.get(orderBlocks, i)

        if ob.active

            bool expired = bar_index > ob.originBar + 1000

            if expired

                finishOrderBlock(ob)

            else

                if not ob.touched

                    setOrderBlockRight(ob, bar_index)

                bool invalidated = ob.direction == 1 ? close < ob.bottom : close > ob.top

                if invalidated

                    finishOrderBlock(ob)

                else

                    bool touched = bar_index > ob.createdBar and low <= ob.top and high >= ob.bottom

                    if touched and not ob.touched

                        ob.touched := true

                        ob.touchBar := bar_index

                        setOrderBlockRight(ob, bar_index)



bool bullishSignal = false

bool bearishSignal = false

if barstate.isconfirmed and array.size(orderBlocks) > 0

    for i = 0 to array.size(orderBlocks) - 1

        OrderBlock ob = array.get(orderBlocks, i)

        if ob.active and bar_index <= ob.originBar + 1000 and ob.touched and not na(ob.touchBar)

            bool bullConfirmation = ob.direction == 1 and close > open and close > ob.top and closeLocation >= reactionClosePosition

            bool bearConfirmation = ob.direction == -1 and close < open and close < ob.bottom and closeLocation <= 1.0 - reactionClosePosition

            if bullConfirmation

                bullishSignal := true

                finishOrderBlock(ob)

            else if bearConfirmation

                bearishSignal := true

                finishOrderBlock(ob)

            else if bar_index - ob.touchBar > reactionBars

                finishOrderBlock(ob)



plotshape(ShowSignals and bullishSignal, "Bullish Signal", shape.triangleup, location.belowbar, color = #56D36F, size = size.small, text = "BUY", textcolor = color.white)

plotshape(ShowSignals and bearishSignal, "Bearish Signal", shape.triangledown, location.abovebar, color = #FF5A70, size = size.small, text = "SELL", textcolor = color.white)

if endTradingSession

    tradingStartBar := na

    highSwept := false

    lowSwept := false

    highOB := na

    lowOB := na

    bearOBIndex := na

    bullOBIndex := na

    bearCisdArmed := false

    bullCisdArmed := false

    waitingBearFVG := false

    waitingBullFVG := false

    bearFVGReady := false

    bullFVGReady := false

    activeBearFVGArrayIndex := na

    activeBullFVGArrayIndex := na

// Alerts

alertcondition(bullishOBCreated, "ICT05 Demand OB", "Demand Order Block")

alertcondition(bearishOBCreated, "ICT05 Supply OB", "Supply Order Block")

alertcondition(bullishSignal, "ICT05 Buy Signal", "Buy Signal")

alertcondition(bearishSignal, "ICT05 Sell Signal", "Sell Signal")

if Alert and bullishSignal

    alert("ICT05 Buy Signal", alert.freq_once_per_bar_close)

if Alert and bearishSignal

    alert("ICT05 Sell Signal", alert.freq_once_per_bar_close)
````
