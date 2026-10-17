# Liquidity Sweep Probability [JOAT]

- url: https://www.tradingview.com/script/7UGYr5fB-Liquidity-Sweep-Probability-JOAT/
- type: indicator
- pine_id: PUB;0bd4cc15e6df44b9b39b71a9b739f83a
- version: 1.0

## Description

Liquidity Sweep Probability is an open-source Pine Script v6 overlay that maps equal highs and equal lows, tracks sweeps through those levels, detects reclaim behavior, and records simple continuation samples after reclaim events. It is designed for traders who want a clean way to observe where price has built nearby liquidity and how price behaves after that liquidity is tested.

The script does not claim that a sweep must reverse price. Instead, it separates equal-level creation, sweep, reclaim, break, and continuation outcomes. The dashboard shows the most recent event, the side involved, sample counts, and an adaptive probability-style reading derived from the script's own observed samples.

[image]https://www.tradingview.com/x/fEDMUEiW/[/image]

[b]Core Concepts[/b]

[b]1. Equal High and Equal Low Detection[/b]

Confirmed pivots are compared against the previous pivot on the same side. If two pivot highs or lows are within an ATR-based tolerance, a liquidity zone is created.

[pine]
pivotHigh = ta.pivothigh(high, pivotLength, pivotLength)

if not na(lastHighPivot) and math.abs(pivotHigh - lastHighPivot) <= equalTolerance
    zoneTop = math.max(pivotHigh, lastHighPivot) + zonePadding
    zoneBottom = math.min(pivotHigh, lastHighPivot) - zonePadding
[/pine]

[b]2. Sweep State[/b]

A high-side sweep occurs when price trades beyond the equal high zone but closes back below the zone top. A low-side sweep occurs when price trades below the equal low zone but closes back above the zone bottom.

[b]3. Reclaim State[/b]

After a sweep, the script watches a configurable reclaim window. A high-side reclaim requires price to close back below the lower boundary of the swept high zone. A low-side reclaim requires price to close back above the upper boundary of the swept low zone.

[b]4. Continuation Sampling[/b]

After reclaim, the script stores a target distance based on ATR and tracks whether price reaches it within the outcome window. These counts are displayed as samples. They are descriptive statistics from the chart, not a prediction.

[b]5. Probability Panel[/b]

The probability-style score blends observed sample rate, sweep distance, zone age, and reclaim status. It gives a compact read of the current event context.

[pine]
sampleRate = total > 0 ? (wins * 100.0) / total : 50.0
score = clamp(sampleRate * 0.62 + 19.0 + distanceBoost + ageBoost + reclaimBoost, 5.0, 95.0)
[/pine]

[b]Features[/b]

[list]
[*][b]Equal high and equal low zones:[/b] ATR tolerance avoids exact-price-only matching
[*][b]Sweep detection:[/b] Tracks confirmed high-side and low-side liquidity sweeps
[*][b]Reclaim detection:[/b] Separates immediate breaks from reclaim behavior
[*][b]Continuation samples:[/b] Counts historical reclaim outcomes within the active chart sample
[*][b]Dashed midlines:[/b] Each zone includes a center reference line
[*][b]Stateful labels:[/b] Zones update from Equal High/Low to Sweep, Reclaimed, or Broken
[*][b]Probability panel:[/b] Shows side, status, chance value, samples, and age
[*][b]Alerts:[/b] Sweep, reclaim, and zone break conditions
[/list]

[b]Input Parameters[/b]

[b]Swings:[/b]
[list]
[*]Swing Pivot Length: Pivot sensitivity for equal-level detection
[*]Equal-Level Tolerance: ATR fraction used to compare pivots
[*]Zone Padding: ATR fraction added around the equal level
[*]ATR Length: Volatility length for tolerance and padding
[/list]

[b]Behavior:[/b]
[list]
[*]Reclaim Window: Bars allowed for reclaim after sweep
[*]Continuation Window: Bars allowed for measuring post-reclaim continuation
[*]Continuation Distance: ATR target used for sample tracking
[*]Maximum Zones Per Side: Object cap for high and low zones
[/list]

[b]Visual:[/b]
[list]
[*]Palette: Selects bull and bear colors
[*]Zone Extension Bars: Forward extension for boxes and midlines
[*]Probability Panel: Shows or hides the dashboard
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify Equal-Level Zones[/b]
Equal highs can act as high-side liquidity references. Equal lows can act as low-side liquidity references.

[b]Step 2: Watch for Sweep and Reclaim[/b]
A sweep alone is not enough. Reclaim behavior shows that price tested outside the zone and then closed back through the zone boundary.

[b]Step 3: Read the Sample Count[/b]
The sample row shows how many observed reclaim events reached their ATR target on the current chart sample. A small sample should be treated carefully.

[b]Step 4: Use Zones as Context[/b]
Use the zones to frame liquidity behavior, then combine the context with your own entry trigger and risk plan.

[b]Indicator Limitations[/b]

[list]
[*]Equal-level zones are based on confirmed pivots, so they appear after the pivot confirmation window
[*]The probability value is descriptive and chart-dependent
[*]A small number of samples should not be treated as statistically strong
[*]Fast markets may sweep, reclaim, and break multiple zones quickly
[*]Object limits require the script to delete older zones when caps are reached
[/list]

[b]Originality Statement[/b]

Liquidity Sweep Probability is original in its state machine for equal-level zones, sweep/reclaim/break classification, and live sample tracking. It uses public Pine v6 mechanics to build a self-contained liquidity map without copying another indicator's source.

[b]Disclaimer[/b]

This script is provided for educational and informational use only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Liquidity sweeps can continue, reverse, or fail without warning. Always use independent analysis and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Liquidity Sweep Probability [JOAT]", shorttitle="Liquidity Sweep Probability [JOAT]", overlay=true, max_boxes_count=160, max_lines_count=160, max_labels_count=160)

groupSwings = "Swings"
pivotLength = input.int(5, "Swing Pivot Length", minval=2, maxval=30, group=groupSwings)
equalAtrMult = input.float(0.18, "Equal-Level Tolerance", minval=0.02, maxval=1.00, step=0.01, group=groupSwings)
zoneAtrMult = input.float(0.08, "Zone Padding", minval=0.01, maxval=0.60, step=0.01, group=groupSwings)
atrLength = input.int(21, "ATR Length", minval=3, maxval=200, group=groupSwings)

groupBehavior = "Behavior"
reclaimBars = input.int(8, "Reclaim Window", minval=1, maxval=50, group=groupBehavior)
outcomeBars = input.int(20, "Continuation Window", minval=3, maxval=100, group=groupBehavior)
targetAtrMult = input.float(0.75, "Continuation Distance", minval=0.10, maxval=5.00, step=0.05, group=groupBehavior)
maxZones = input.int(18, "Maximum Zones Per Side", minval=1, maxval=60, group=groupBehavior)

groupVisual = "Visual"
palettePreset = input.string("Aqua Rose", "Palette", options=["Aqua Rose", "Neon Desk", "Mint Pulse", "VWAP Field"], group=groupVisual)
zoneBars = input.int(120, "Zone Extension Bars", minval=10, maxval=500, group=groupVisual)
showDashboard = input.bool(true, "Probability Panel", group=groupVisual)

bullBase = switch palettePreset
    "Neon Desk" => #00ff00
    "Mint Pulse" => #00FFD5
    "VWAP Field" => #1ac200
    => #00C8FF

bearBase = switch palettePreset
    "Neon Desk" => #ff0000
    "Mint Pulse" => #FF0066
    "VWAP Field" => #ff4040
    => #FF005D

neutralBase = color.rgb(150, 156, 166)

clamp(value, lowLimit, highLimit) =>
    math.min(math.max(value, lowLimit), highLimit)

chanceScore(wins, total, distanceAtr, ageBars, reclaimed) =>
    sampleRate = total > 0 ? (wins * 100.0) / total : 50.0
    distanceBoost = clamp(distanceAtr * 10.0, 0.0, 18.0)
    ageBoost = clamp(ageBars * 0.08, 0.0, 6.0)
    reclaimBoost = reclaimed ? 8.0 : 0.0
    clamp(sampleRate * 0.62 + 19.0 + distanceBoost + ageBoost + reclaimBoost, 5.0, 95.0)

atrValue = ta.atr(atrLength)
safeAtr = math.max(nz(atrValue, high - low), syminfo.mintick)
equalTolerance = safeAtr * equalAtrMult
zonePadding = safeAtr * zoneAtrMult

pivotHigh = ta.pivothigh(high, pivotLength, pivotLength)
pivotLow = ta.pivotlow(low, pivotLength, pivotLength)

var float lastHighPivot = na
var int lastHighIndex = na
var float lastLowPivot = na
var int lastLowIndex = na

var highBoxes = array.new_box(0)
var highLines = array.new_line(0)
var highLabels = array.new_label(0)
var highTops = array.new_float(0)
var highBottoms = array.new_float(0)
var highMids = array.new_float(0)
var highStates = array.new_int(0)
var highSweepBars = array.new_int(0)
var highReclaimBars = array.new_int(0)
var highTargets = array.new_float(0)
var highOutcomeDone = array.new_bool(0)
var highLeftBars = array.new_int(0)

var lowBoxes = array.new_box(0)
var lowLines = array.new_line(0)
var lowLabels = array.new_label(0)
var lowTops = array.new_float(0)
var lowBottoms = array.new_float(0)
var lowMids = array.new_float(0)
var lowStates = array.new_int(0)
var lowSweepBars = array.new_int(0)
var lowReclaimBars = array.new_int(0)
var lowTargets = array.new_float(0)
var lowOutcomeDone = array.new_bool(0)
var lowLeftBars = array.new_int(0)

var int highWins = 0
var int highTrials = 0
var int lowWins = 0
var int lowTrials = 0

var string panelSide = "None"
var string panelState = "Waiting"
var float panelChance = na
var int panelBar = na
var color panelColor = color.new(neutralBase, 0)

bool highSweepNow = false
bool lowSweepNow = false
bool highReclaimNow = false
bool lowReclaimNow = false
bool highBreakNow = false
bool lowBreakNow = false

if not na(pivotHigh)
    pivotIndex = bar_index - pivotLength
    if not na(lastHighPivot) and math.abs(pivotHigh - lastHighPivot) <= equalTolerance
        zoneTop = math.max(pivotHigh, lastHighPivot) + zonePadding
        zoneBottom = math.min(pivotHigh, lastHighPivot) - zonePadding
        zoneMid = (zoneTop + zoneBottom) * 0.50
        leftIndex = lastHighIndex
        highBox = box.new(left=leftIndex, top=zoneTop, right=bar_index + zoneBars, bottom=zoneBottom, border_color=color.new(bearBase, 25), border_width=1, border_style=line.style_solid, bgcolor=color.new(bearBase, 88))
        highMidline = line.new(x1=leftIndex, y1=zoneMid, x2=bar_index + zoneBars, y2=zoneMid, color=color.new(bearBase, 35), style=line.style_dashed, width=1)
        highLabel = label.new(x=bar_index + 1, y=zoneTop, text="Equal High", style=label.style_label_left, textcolor=color.white, color=color.new(bearBase, 45), size=size.tiny)
        array.push(highBoxes, highBox)
        array.push(highLines, highMidline)
        array.push(highLabels, highLabel)
        array.push(highTops, zoneTop)
        array.push(highBottoms, zoneBottom)
        array.push(highMids, zoneMid)
        array.push(highStates, 0)
        array.push(highSweepBars, na)
        array.push(highReclaimBars, na)
        array.push(highTargets, na)
        array.push(highOutcomeDone, true)
        array.push(highLeftBars, leftIndex)
        if array.size(highBoxes) > maxZones
            oldBox = array.shift(highBoxes)
            oldLine = array.shift(highLines)
            oldLabel = array.shift(highLabels)
            box.delete(oldBox)
            line.delete(oldLine)
            label.delete(oldLabel)
            array.shift(highTops)
            array.shift(highBottoms)
            array.shift(highMids)
            array.shift(highStates)
            array.shift(highSweepBars)
            array.shift(highReclaimBars)
            array.shift(highTargets)
            array.shift(highOutcomeDone)
            array.shift(highLeftBars)
    lastHighPivot := pivotHigh
    lastHighIndex := pivotIndex

if not na(pivotLow)
    pivotIndex = bar_index - pivotLength
    if not na(lastLowPivot) and math.abs(pivotLow - lastLowPivot) <= equalTolerance
        zoneTop = math.max(pivotLow, lastLowPivot) + zonePadding
        zoneBottom = math.min(pivotLow, lastLowPivot) - zonePadding
        zoneMid = (zoneTop + zoneBottom) * 0.50
        leftIndex = lastLowIndex
        lowBox = box.new(left=leftIndex, top=zoneTop, right=bar_index + zoneBars, bottom=zoneBottom, border_color=color.new(bullBase, 25), border_width=1, border_style=line.style_solid, bgcolor=color.new(bullBase, 88))
        lowMidline = line.new(x1=leftIndex, y1=zoneMid, x2=bar_index + zoneBars, y2=zoneMid, color=color.new(bullBase, 35), style=line.style_dashed, width=1)
        lowLabel = label.new(x=bar_index + 1, y=zoneBottom, text="Equal Low", style=label.style_label_left, textcolor=color.white, color=color.new(bullBase, 45), size=size.tiny)
        array.push(lowBoxes, lowBox)
        array.push(lowLines, lowMidline)
        array.push(lowLabels, lowLabel)
        array.push(lowTops, zoneTop)
        array.push(lowBottoms, zoneBottom)
        array.push(lowMids, zoneMid)
        array.push(lowStates, 0)
        array.push(lowSweepBars, na)
        array.push(lowReclaimBars, na)
        array.push(lowTargets, na)
        array.push(lowOutcomeDone, true)
        array.push(lowLeftBars, leftIndex)
        if array.size(lowBoxes) > maxZones
            oldBox = array.shift(lowBoxes)
            oldLine = array.shift(lowLines)
            oldLabel = array.shift(lowLabels)
            box.delete(oldBox)
            line.delete(oldLine)
            label.delete(oldLabel)
            array.shift(lowTops)
            array.shift(lowBottoms)
            array.shift(lowMids)
            array.shift(lowStates)
            array.shift(lowSweepBars)
            array.shift(lowReclaimBars)
            array.shift(lowTargets)
            array.shift(lowOutcomeDone)
            array.shift(lowLeftBars)
    lastLowPivot := pivotLow
    lastLowIndex := pivotIndex

if array.size(highBoxes) > 0
    for i = 0 to array.size(highBoxes) - 1
        zoneBox = array.get(highBoxes, i)
        zoneLine = array.get(highLines, i)
        zoneLabel = array.get(highLabels, i)
        zoneTop = array.get(highTops, i)
        zoneBottom = array.get(highBottoms, i)
        zoneMid = array.get(highMids, i)
        zoneState = array.get(highStates, i)
        ageBars = bar_index - array.get(highLeftBars, i)
        box.set_right(zoneBox, bar_index + zoneBars)
        line.set_x2(zoneLine, bar_index + zoneBars)
        label.set_x(zoneLabel, bar_index + 1)
        label.set_y(zoneLabel, zoneTop)
        if zoneState == 0 and barstate.isconfirmed
            if high > zoneTop and close < zoneTop
                distanceAtr = (high - zoneTop) / safeAtr
                setupChance = chanceScore(highWins, highTrials, distanceAtr, ageBars, false)
                array.set(highStates, i, 1)
                array.set(highSweepBars, i, bar_index)
                highSweepNow := true
                panelSide := "High"
                panelState := "Swept"
                panelChance := setupChance
                panelBar := bar_index
                panelColor := color.new(bearBase, 0)
                box.set_bgcolor(zoneBox, color.new(bearBase, 91))
                box.set_border_color(zoneBox, color.new(bearBase, 8))
                box.set_border_style(zoneBox, line.style_dashed)
                line.set_color(zoneLine, color.new(bearBase, 8))
                label.set_text(zoneLabel, "High Sweep")
                label.set_color(zoneLabel, color.new(bearBase, 20))
            else if close > zoneTop
                array.set(highStates, i, 3)
                highBreakNow := true
                box.set_bgcolor(zoneBox, color.new(neutralBase, 94))
                box.set_border_color(zoneBox, color.new(neutralBase, 68))
                box.set_border_style(zoneBox, line.style_dotted)
                line.set_color(zoneLine, color.new(neutralBase, 65))
                label.set_text(zoneLabel, "High Broken")
                label.set_color(zoneLabel, color.new(neutralBase, 45))
        if zoneState == 1 and barstate.isconfirmed
            sweepBar = array.get(highSweepBars, i)
            if close < zoneBottom
                distanceAtr = (high - zoneTop) / safeAtr
                setupChance = chanceScore(highWins, highTrials, math.max(distanceAtr, 0.0), ageBars, true)
                array.set(highStates, i, 2)
                array.set(highReclaimBars, i, bar_index)
                array.set(highTargets, i, close - safeAtr * targetAtrMult)
                array.set(highOutcomeDone, i, false)
                highReclaimNow := true
                panelSide := "High"
                panelState := "Reclaimed"
                panelChance := setupChance
                panelBar := bar_index
                panelColor := color.new(bearBase, 0)
                box.set_bgcolor(zoneBox, color.new(bearBase, 93))
                box.set_border_color(zoneBox, color.new(bearBase, 18))
                box.set_border_style(zoneBox, line.style_dashed)
                line.set_color(zoneLine, color.new(bearBase, 22))
                label.set_text(zoneLabel, "High Reclaimed")
                label.set_color(zoneLabel, color.new(bearBase, 30))
            else if close > zoneTop or bar_index - sweepBar > reclaimBars
                array.set(highStates, i, 3)
                highBreakNow := true
                box.set_bgcolor(zoneBox, color.new(neutralBase, 94))
                box.set_border_color(zoneBox, color.new(neutralBase, 68))
                box.set_border_style(zoneBox, line.style_dotted)
                line.set_color(zoneLine, color.new(neutralBase, 65))
                label.set_text(zoneLabel, "High Broken")
                label.set_color(zoneLabel, color.new(neutralBase, 45))
        if array.get(highStates, i) == 2 and not array.get(highOutcomeDone, i)
            reclaimBar = array.get(highReclaimBars, i)
            targetPrice = array.get(highTargets, i)
            if bar_index > reclaimBar and low <= targetPrice
                highWins := highWins + 1
                highTrials := highTrials + 1
                array.set(highOutcomeDone, i, true)
                panelSide := "High"
                panelState := "Continued"
                panelChance := chanceScore(highWins, highTrials, 0.0, ageBars, true)
                panelBar := bar_index
                panelColor := color.new(bearBase, 0)
            else if bar_index - reclaimBar > outcomeBars
                highTrials := highTrials + 1
                array.set(highOutcomeDone, i, true)

if array.size(lowBoxes) > 0
    for i = 0 to array.size(lowBoxes) - 1
        zoneBox = array.get(lowBoxes, i)
        zoneLine = array.get(lowLines, i)
        zoneLabel = array.get(lowLabels, i)
        zoneTop = array.get(lowTops, i)
        zoneBottom = array.get(lowBottoms, i)
        zoneMid = array.get(lowMids, i)
        zoneState = array.get(lowStates, i)
        ageBars = bar_index - array.get(lowLeftBars, i)
        box.set_right(zoneBox, bar_index + zoneBars)
        line.set_x2(zoneLine, bar_index + zoneBars)
        label.set_x(zoneLabel, bar_index + 1)
        label.set_y(zoneLabel, zoneBottom)
        if zoneState == 0 and barstate.isconfirmed
            if low < zoneBottom and close > zoneBottom
                distanceAtr = (zoneBottom - low) / safeAtr
                setupChance = chanceScore(lowWins, lowTrials, distanceAtr, ageBars, false)
                array.set(lowStates, i, 1)
                array.set(lowSweepBars, i, bar_index)
                lowSweepNow := true
                panelSide := "Low"
                panelState := "Swept"
                panelChance := setupChance
                panelBar := bar_index
                panelColor := color.new(bullBase, 0)
                box.set_bgcolor(zoneBox, color.new(bullBase, 91))
                box.set_border_color(zoneBox, color.new(bullBase, 8))
                box.set_border_style(zoneBox, line.style_dashed)
                line.set_color(zoneLine, color.new(bullBase, 8))
                label.set_text(zoneLabel, "Low Sweep")
                label.set_color(zoneLabel, color.new(bullBase, 20))
            else if close < zoneBottom
                array.set(lowStates, i, 3)
                lowBreakNow := true
                box.set_bgcolor(zoneBox, color.new(neutralBase, 94))
                box.set_border_color(zoneBox, color.new(neutralBase, 68))
                box.set_border_style(zoneBox, line.style_dotted)
                line.set_color(zoneLine, color.new(neutralBase, 65))
                label.set_text(zoneLabel, "Low Broken")
                label.set_color(zoneLabel, color.new(neutralBase, 45))
        if zoneState == 1 and barstate.isconfirmed
            sweepBar = array.get(lowSweepBars, i)
            if close > zoneTop
                distanceAtr = (zoneBottom - low) / safeAtr
                setupChance = chanceScore(lowWins, lowTrials, math.max(distanceAtr, 0.0), ageBars, true)
                array.set(lowStates, i, 2)
                array.set(lowReclaimBars, i, bar_index)
                array.set(lowTargets, i, close + safeAtr * targetAtrMult)
                array.set(lowOutcomeDone, i, false)
                lowReclaimNow := true
                panelSide := "Low"
                panelState := "Reclaimed"
                panelChance := setupChance
                panelBar := bar_index
                panelColor := color.new(bullBase, 0)
                box.set_bgcolor(zoneBox, color.new(bullBase, 93))
                box.set_border_color(zoneBox, color.new(bullBase, 18))
                box.set_border_style(zoneBox, line.style_dashed)
                line.set_color(zoneLine, color.new(bullBase, 22))
                label.set_text(zoneLabel, "Low Reclaimed")
                label.set_color(zoneLabel, color.new(bullBase, 30))
            else if close < zoneBottom or bar_index - sweepBar > reclaimBars
                array.set(lowStates, i, 3)
                lowBreakNow := true
                box.set_bgcolor(zoneBox, color.new(neutralBase, 94))
                box.set_border_color(zoneBox, color.new(neutralBase, 68))
                box.set_border_style(zoneBox, line.style_dotted)
                line.set_color(zoneLine, color.new(neutralBase, 65))
                label.set_text(zoneLabel, "Low Broken")
                label.set_color(zoneLabel, color.new(neutralBase, 45))
        if array.get(lowStates, i) == 2 and not array.get(lowOutcomeDone, i)
            reclaimBar = array.get(lowReclaimBars, i)
            targetPrice = array.get(lowTargets, i)
            if bar_index > reclaimBar and high >= targetPrice
                lowWins := lowWins + 1
                lowTrials := lowTrials + 1
                array.set(lowOutcomeDone, i, true)
                panelSide := "Low"
                panelState := "Continued"
                panelChance := chanceScore(lowWins, lowTrials, 0.0, ageBars, true)
                panelBar := bar_index
                panelColor := color.new(bullBase, 0)
            else if bar_index - reclaimBar > outcomeBars
                lowTrials := lowTrials + 1
                array.set(lowOutcomeDone, i, true)

plotshape(highSweepNow, title="High Sweep Dot [JOAT]", style=shape.circle, location=location.abovebar, color=color.new(bearBase, 0), size=size.tiny, text="")
plotshape(lowSweepNow, title="Low Sweep Dot [JOAT]", style=shape.circle, location=location.belowbar, color=color.new(bullBase, 0), size=size.tiny, text="")

alertcondition(highSweepNow, title="High Liquidity Sweep [JOAT]", message="Liquidity Sweep Probability [JOAT]: high-side sweep confirmed.")
alertcondition(lowSweepNow, title="Low Liquidity Sweep [JOAT]", message="Liquidity Sweep Probability [JOAT]: low-side sweep confirmed.")
alertcondition(highReclaimNow, title="High Sweep Reclaim [JOAT]", message="Liquidity Sweep Probability [JOAT]: high-side reclaim confirmed.")
alertcondition(lowReclaimNow, title="Low Sweep Reclaim [JOAT]", message="Liquidity Sweep Probability [JOAT]: low-side reclaim confirmed.")
alertcondition(highBreakNow or lowBreakNow, title="Liquidity Zone Broken [JOAT]", message="Liquidity Sweep Probability [JOAT]: liquidity zone break confirmed.")

var dash = table.new(position=position.top_right, columns=2, rows=5, bgcolor=color.new(color.black, 84), border_color=color.new(color.white, 82), border_width=1)

if barstate.islast
    eventAge = na(panelBar) ? na : bar_index - panelBar
    chanceText = na(panelChance) ? "n/a" : str.tostring(panelChance, "#") + "%"
    sampleText = panelSide == "High" ? str.tostring(highWins) + "/" + str.tostring(highTrials) : panelSide == "Low" ? str.tostring(lowWins) + "/" + str.tostring(lowTrials) : "0/0"
    ageText = na(eventAge) ? "n/a" : str.tostring(eventAge)
    chanceColor = panelSide == "High" ? color.from_gradient(nz(panelChance, 50.0), 0.0, 100.0, color.new(neutralBase, 0), color.new(bearBase, 0)) : panelSide == "Low" ? color.from_gradient(nz(panelChance, 50.0), 0.0, 100.0, color.new(neutralBase, 0), color.new(bullBase, 0)) : color.new(neutralBase, 0)
    table.cell(dash, 0, 0, showDashboard ? "Side" : "", text_color=color.new(color.white, 15), bgcolor=color.new(color.black, 80), text_size=size.small)
    table.cell(dash, 1, 0, showDashboard ? panelSide : "", text_color=panelColor, bgcolor=color.new(color.black, 80), text_size=size.small)
    table.cell(dash, 0, 1, showDashboard ? "Status" : "", text_color=color.new(color.white, 15), bgcolor=color.new(color.black, 88), text_size=size.small)
    table.cell(dash, 1, 1, showDashboard ? panelState : "", text_color=panelColor, bgcolor=color.new(color.black, 88), text_size=size.small)
    table.cell(dash, 0, 2, showDashboard ? "Chance" : "", text_color=color.new(color.white, 15), bgcolor=color.new(color.black, 88), text_size=size.small)
    table.cell(dash, 1, 2, showDashboard ? chanceText : "", text_color=chanceColor, bgcolor=color.new(color.black, 88), text_size=size.small)
    table.cell(dash, 0, 3, showDashboard ? "Samples" : "", text_color=color.new(color.white, 15), bgcolor=color.new(color.black, 88), text_size=size.small)
    table.cell(dash, 1, 3, showDashboard ? sampleText : "", text_color=color.new(color.white, 5), bgcolor=color.new(color.black, 88), text_size=size.small)
    table.cell(dash, 0, 4, showDashboard ? "Age" : "", text_color=color.new(color.white, 15), bgcolor=color.new(color.black, 88), text_size=size.small)
    table.cell(dash, 1, 4, showDashboard ? ageText : "", text_color=color.new(color.white, 5), bgcolor=color.new(color.black, 88), text_size=size.small)
````
