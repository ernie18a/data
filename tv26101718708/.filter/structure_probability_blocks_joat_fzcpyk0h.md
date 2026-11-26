# Structure Probability Blocks [JOAT]

- url: https://www.tradingview.com/script/fzcpyK0H-Structure-Probability-Blocks-JOAT/
- type: indicator
- pine_id: PUB;07d73b91fcff42ad9e7486cb7ebedfd4
- version: 1.0

## Description

[b]Structure Probability Blocks [JOAT][/b]

[b]Introduction[/b]

Structure Probability Blocks is an open-source market structure and quality-zone overlay. It detects confirmed structure breaks, searches for the most relevant opposing candle, scores the resulting block, and highlights the strongest active block without filling the chart with redundant zones.

The problem it solves is order block clutter. Many zone tools draw every candidate equally. Structure Probability Blocks filters for impulse, candle quality, relative volume, recency, and overlap so the displayed blocks have cleaner context. The enhanced chart layer also projects BOS/CHoCH break rails, impulse guide lines, and compact score labels directly beside the structure event.

[image]https://www.tradingview.com/x/7ZR9imWQ/[/image]

[b]Core Concepts[/b]

[b]1. Confirmed Pivot Tracking[/b]

Swing highs and lows are confirmed using symmetric pivots. Because pivots require bars on both sides, this is intentionally delayed and non-repainting.

[b]2. Break Qualification[/b]

A structure break requires price to close through the tracked pivot and meet a minimum ATR-based impulse requirement.

[b]3. Seed Candle Search[/b]

After a break, the script searches backward for the best opposing candle candidate. The score considers body quality, wick behavior, volume rank, and recency.

[b]4. Strongest Active Block Highlight[/b]

Among active blocks, the highest-scored block receives stronger border and midline treatment. Weaker overlapping blocks can be removed when the overlap guard is enabled.

[b]5. Break Rails and Impulse Guides[/b]

When a qualified BOS or CHoCH forms, the indicator can draw a dashed horizontal break rail from the pivot level to the right edge and a dotted impulse guide from the selected seed candle to the break close. The on-chart tag includes score, zone range, drive, RVOL, and break price.

[b]6. Strongest Block Ribbon[/b]

The highest-scored active block is also projected as a subtle ribbon using plot/fill logic. This gives a clean strongest-zone read even when several historical boxes remain visible.

[b]Features[/b]

[list]
[*][b]Confirmed structure breaks:[/b] Breaks require closed-bar confirmation
[*][b]Quality-scored blocks:[/b] Scores combine impulse, candle structure, relative volume, and recency
[*][b]BOS/CHoCH context:[/b] Block labels identify continuation or character-shift context
[*][b]BOS/CHoCH break rails:[/b] Dashed projected levels mark the exact pivot level that price broke
[*][b]Impulse guide lines:[/b] Dotted guides connect the seed candle to the break close
[*][b]Expanded score tags:[/b] Labels show score, zone range, drive, RVOL, and break level
[*][b]Prime block highlight:[/b] Highest active score receives stronger visual emphasis
[*][b]Strongest block ribbon:[/b] Highest active zone is projected as a lightweight filled band
[*][b]Overlap guard:[/b] Keeps the stronger of overlapping active blocks
[*][b]Prime candle tint:[/b] Candles can be softly colored by the strongest active structure bias
[*][b]Broken block handling:[/b] Keep, fade, extend, or remove resolved blocks
[*][b]Top-right dashboard:[/b] Active count, bull/bear count, best score, break state, last pulse, volume rank, and break mode
[*][b]Alerts:[/b] New bullish and bearish quality block events
[/list]

[b]Input Parameters[/b]

[b]Structure:[/b]
[list]
[*]Pivot Length: Swing confirmation sensitivity
[*]Search Span: Bars searched for a seed candle
[*]Break Impulse: Minimum ATR expansion required for a break
[*]Volume Span: Lookback used for volume rank
[*]Min Score: Minimum block quality score required
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Use the dashboard to identify current bull/bear structural bias.
[b]Step 2:[/b] Focus on the strongest highlighted active block first.
[b]Step 3:[/b] Use the dashed BOS/CHoCH rail as the exact structural break reference.
[b]Step 4:[/b] Treat broken/faded blocks as resolved context rather than fresh opportunities.
[b]Step 5:[/b] Combine with a regime or pressure tool before making directional decisions.

[b]Indicator Limitations[/b]

[list]
[*]Pivot confirmation is delayed by the pivot length, which is intentional non-repainting behavior
[*]A high block score does not imply a guaranteed reaction
[*]Volume rank can be less useful on instruments with unreliable volume
[*]The script identifies structural context, not complete risk-defined trades
[/list]

[b]Originality Statement[/b]

Structure Probability Blocks is original in its quality-scored seed selection, impulse qualification, overlap prioritization, prime block highlighting, and compact structural dashboard. It does not copy third-party source code.

[b]Disclaimer[/b]

This open-source indicator is provided for educational and informational purposes only. It is not financial advice. Structural zones can fail, and traders should always use independent analysis and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Structure Probability Blocks [JOAT]", "SPB [JOAT]", overlay = true, max_boxes_count = 300, max_labels_count = 200, max_lines_count = 300)

color cBull = #089981
color cBear = #f23645
color cPrimeBull = #29e3b5
color cPrimeBear = #ff6b76
color cText = #d7dde6
color cSub = #87919c
color cBack = #111418
color cPanel = #151b22
color cEdge = #27313b
color cBlue = #2196f3
color cViolet = #9c27b0

string grpStr = "Structure"
string grpBlk = "Blocks"
string grpVis = "Visuals"
string grpDash = "Dashboard"

string posTopRight = "Top Right"
string posBotRight = "Bottom Right"
string posBotLeft = "Bottom Left"

string sizeTiny = "Tiny"
string sizeSmall = "Small"
string sizeNormal = "Normal"
string sizeLarge = "Large"
string sizeHuge = "Huge"

type BlockNode
    box body
    line mid
    line breakLine
    line impulseLine
    label tag
    label breakTag
    float top
    float bottom
    float breakLevel
    float score
    float drive
    float rvol
    bool bull
    bool broken
    bool prime
    int born
    int breakBar

var array<BlockNode> blockNodes = array.new<BlockNode>()

pivotLen = input.int(5, "Pivot length", minval = 1, maxval = 50, group = grpStr)
scanLen = input.int(18, "Search span", minval = 3, maxval = 50, group = grpStr, tooltip = "How far back the script searches for the most suitable opposite candle.")
driveNeed = input.float(0.45, "Break impulse", minval = 0.0, step = 0.05, group = grpStr, tooltip = "Minimum ATR-based expansion needed to accept a break.")
volLen = input.int(40, "Volume span", minval = 5, maxval = 200, group = grpStr)
scoreNeed = input.float(45.0, "Min score", minval = 0.0, maxval = 100.0, step = 1.0, group = grpStr)

maxBlocks = input.int(16, "Max active blocks", minval = 1, maxval = 100, group = grpBlk)
hideOverlap = input.bool(true, "Prefer stronger overlap", group = grpBlk)
extendAfterBreak = input.bool(false, "Extend broken blocks", group = grpBlk)
showBroken = input.bool(true, "Keep broken blocks", group = grpBlk)
showBiasTint = input.bool(true, "Tint candles by prime structure", group = grpVis)
showBreakRails = input.bool(true, "Show BOS/CHoCH rails", group = grpVis)
showImpulse = input.bool(true, "Show impulse guides", group = grpVis)
showPrimeRibbon = input.bool(true, "Show strongest block ribbon", group = grpVis)

showDash = input.bool(true, "Show dashboard", group = grpDash)
dashPos = input.string(posTopRight, "Position", options = [posTopRight, posBotRight, posBotLeft], group = grpDash)
dashSize = input.string(sizeNormal, "Size", options = [sizeTiny, sizeSmall, sizeNormal, sizeLarge, sizeHuge], group = grpDash)

var tablePos = switch dashPos
    posTopRight => position.top_right
    posBotRight => position.bottom_right
    => position.bottom_left

var tableSize = switch dashSize
    sizeTiny => size.tiny
    sizeSmall => size.small
    sizeNormal => size.normal
    sizeLarge => size.large
    => size.huge

dash_cell(table t, int col, int row, string txt, color txtColor, color bgColor, align = text.align_right) =>
    table.cell(t, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_halign = align, text_size = tableSize)

erase_block(BlockNode node) =>
    if not na(node.body)
        node.body.delete()
    if not na(node.mid)
        node.mid.delete()
    if not na(node.breakLine)
        node.breakLine.delete()
    if not na(node.impulseLine)
        node.impulseLine.delete()
    if not na(node.tag)
        node.tag.delete()
    if not na(node.breakTag)
        node.breakTag.delete()

atr = nz(ta.atr(14), high - low)
volBase = nz(ta.sma(nz(volume, 0.0), volLen), 1.0)
volNow = nz(volume, 0.0)
volPct = nz(ta.percentrank(volNow, volLen), 50.0)
rVol = volBase > 0.0 ? volNow / volBase : 1.0

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastPh = na
var float lastPl = na
var int lastPhBar = na
var int lastPlBar = na
var int biasState = 0
var string lastPulse = "Waiting"
var color lastPulseCol = cSub

if not na(ph)
    lastPh := ph
    lastPhBar := bar_index - pivotLen

if not na(pl)
    lastPl := pl
    lastPlBar := bar_index - pivotLen

find_seed(bool bullBreak, int cap) =>
    int bestIdx = na
    float bestRank = -1.0
    if cap > 0
        for i = 1 to cap
            bool candidate = bullBreak ? close[i] < open[i] : close[i] > open[i]
            if candidate
                float span = math.max(high[i] - low[i], syminfo.mintick)
                float bodyRate = math.abs(close[i] - open[i]) / span
                float wickRate = bullBreak ? (math.min(open[i], close[i]) - low[i]) / span : (high[i] - math.max(open[i], close[i])) / span
                float rankNow = nz(volPct[i], 50.0) / 100.0
                float proxRate = 1.0 - (float(i) - 1.0) / float(math.max(cap, 1))
                float combo = bodyRate * 0.36 + wickRate * 0.24 + rankNow * 0.22 + proxRate * 0.18
                if combo > bestRank
                    bestRank := combo
                    bestIdx := i
    [bestIdx, bestRank]

bool newBullBlock = false
bool newBearBlock = false

if barstate.isconfirmed and not na(lastPh) and not na(lastPl)
    bool upBreak = close > lastPh and close[1] <= lastPh and ((close - close[1]) / math.max(atr, syminfo.mintick)) >= driveNeed
    bool dnBreak = close < lastPl and close[1] >= lastPl and ((close[1] - close) / math.max(atr, syminfo.mintick)) >= driveNeed

    if upBreak or dnBreak
        bool bullBreak = upBreak
        int cap = math.min(scanLen, bullBreak ? bar_index - lastPhBar : bar_index - lastPlBar)
        [seedIdx, seedRank] = find_seed(bullBreak, cap)

        if not na(seedIdx)
            float top = high[seedIdx]
            float bottom = low[seedIdx]
            float drive = bullBreak ? (close - lastPh) / math.max(atr, syminfo.mintick) : (lastPl - close) / math.max(atr, syminfo.mintick)
            float quality = math.min(100.0, seedRank * 58.0 + drive * 16.0 + math.min(rVol * 10.0, 18.0) + volPct * 0.08)
            bool strongEnough = quality >= scoreNeed

            if strongEnough
                bool acceptBlock = true
                if hideOverlap and array.size(blockNodes) > 0
                    for i = array.size(blockNodes) - 1 to 0
                        BlockNode old = array.get(blockNodes, i)
                        bool overlap = math.max(bottom, old.bottom) < math.min(top, old.top)
                        if overlap and not old.broken
                            if quality > old.score
                                erase_block(old)
                                array.remove(blockNodes, i)
                            else
                                acceptBlock := false
                                break

                if acceptBlock
                    color baseCol = bullBreak ? cBull : cBear
                    color primeCol = bullBreak ? cPrimeBull : cPrimeBear
                    color boxCol = color.new(baseCol, 84)
                    color edgeCol = color.new(baseCol, 36)
                    color textCol = color.new(baseCol, 0)
                    float midY = (top + bottom) * 0.5
                    float breakLevel = bullBreak ? lastPh : lastPl
                    int breakStart = bullBreak ? lastPhBar : lastPlBar

                    box body = box.new(bar_index[seedIdx], top, bar_index, bottom, bgcolor = boxCol, border_color = edgeCol, border_width = 1, border_style = line.style_dashed)
                    line mid = line.new(bar_index[seedIdx], midY, bar_index, midY, color = color.new(baseCol, 18), style = line.style_dotted, width = 1)
                    string pulse = bullBreak ? (biasState <= 0 ? "CHoCH " : "BOS ") : (biasState >= 0 ? "CHoCH " : "BOS ")
                    string txt = pulse + str.tostring(quality, "#.#") + "\nZone " + str.tostring(bottom, format.mintick) + " - " + str.tostring(top, format.mintick) + "\nDRV " + str.tostring(drive, "#.##") + " | RVOL " + str.tostring(rVol, "#.##")
                    label tag = label.new(bar_index + 2, midY, txt, style = label.style_label_left, color = color.new(cPanel, 8), textcolor = textCol, size = size.small)
                    line breakLine = showBreakRails ? line.new(breakStart, breakLevel, bar_index + 14, breakLevel, color = color.new(primeCol, 8), style = line.style_dashed, width = 2) : na
                    line impulseLine = showImpulse ? line.new(bar_index[seedIdx], midY, bar_index, close, color = color.new(primeCol, 30), style = line.style_dotted, width = 2) : na
                    string breakTxt = (bullBreak ? "Break +" : "Break -") + "\n" + str.tostring(breakLevel, format.mintick) + "\nScore " + str.tostring(quality, "#.#")
                    label breakTag = showBreakRails ? label.new(bar_index + 14, breakLevel, breakTxt, style = label.style_label_left, color = color.new(cPanel, 10), textcolor = primeCol, size = size.tiny) : na

                    BlockNode node = BlockNode.new(body, mid, breakLine, impulseLine, tag, breakTag, top, bottom, breakLevel, quality, drive, rVol, bullBreak, false, false, bar_index, bar_index)
                    array.push(blockNodes, node)

                    if bullBreak
                        newBullBlock := true
                        biasState := 1
                        lastPulse := "Bullish " + pulse + str.tostring(quality, "#.#")
                        lastPulseCol := primeCol
                    else
                        newBearBlock := true
                        biasState := -1
                        lastPulse := "Bearish " + pulse + str.tostring(quality, "#.#")
                        lastPulseCol := primeCol

                    if array.size(blockNodes) > maxBlocks
                        BlockNode oldNode = array.shift(blockNodes)
                        erase_block(oldNode)

if array.size(blockNodes) > 0
    for i = array.size(blockNodes) - 1 to 0
        BlockNode node = array.get(blockNodes, i)
        bool breakHit = node.bull ? low <= node.bottom : high >= node.top
        if not node.broken and breakHit
            node.broken := true
            node.breakBar := bar_index
            if not showBroken
                erase_block(node)
                array.remove(blockNodes, i)
            else
                color muted = color.new(chart.fg_color, 88)
                node.body.set_bgcolor(muted)
                node.body.set_border_color(color.new(chart.fg_color, 84))
                node.mid.set_color(color.new(chart.fg_color, 76))
                if not na(node.breakLine)
                    node.breakLine.set_color(color.new(chart.fg_color, 78))
                if not na(node.impulseLine)
                    node.impulseLine.set_color(color.new(chart.fg_color, 84))
                if not na(node.tag)
                    node.tag.set_textcolor(color.new(chart.fg_color, 58))
                if not na(node.breakTag)
                    node.breakTag.set_textcolor(color.new(chart.fg_color, 58))
        else if not node.broken
            node.body.set_right(bar_index)
            node.mid.set_x2(bar_index)
            if not na(node.breakLine)
                node.breakLine.set_x2(bar_index + 14)
            if not na(node.breakTag)
                node.breakTag.set_x(bar_index + 14)
                node.breakTag.set_y(node.breakLevel)
            if not na(node.tag)
                node.tag.set_x(bar_index + 2)
                node.tag.set_y((node.top + node.bottom) * 0.5)
        else if node.broken and extendAfterBreak
            node.body.set_right(bar_index)
            node.mid.set_x2(bar_index)
            if not na(node.breakLine)
                node.breakLine.set_x2(bar_index + 14)
            if not na(node.breakTag)
                node.breakTag.set_x(bar_index + 14)

activeCount = 0
bullCount = 0
bearCount = 0
float bestScore = 0.0
int bestIdx = na
float bestTop = na
float bestBottom = na
string liveState = biasState > 0 ? "Bull bias" : biasState < 0 ? "Bear bias" : "Neutral"
color liveCol = biasState > 0 ? cBull : biasState < 0 ? cBear : cSub

if array.size(blockNodes) > 0
    for i = 0 to array.size(blockNodes) - 1
        BlockNode node = array.get(blockNodes, i)
        if not node.broken
            activeCount += 1
            if node.bull
                bullCount += 1
            else
                bearCount += 1
            if node.score > bestScore
                bestScore := node.score
                bestIdx := i
                bestTop := node.top
                bestBottom := node.bottom

color primeAura = color.from_gradient(bestScore, 0.0, 100.0, biasState > 0 ? cBlue : cViolet, liveCol)
primeTopPlot = plot(showPrimeRibbon and activeCount > 0 ? bestTop : na, "Strongest Structure Top", color = color.new(primeAura, 72), linewidth = 1)
primeBottomPlot = plot(showPrimeRibbon and activeCount > 0 ? bestBottom : na, "Strongest Structure Bottom", color = color.new(primeAura, 72), linewidth = 1)
fill(primeTopPlot, primeBottomPlot, color.new(primeAura, 91), title = "Strongest Structure Ribbon")

if array.size(blockNodes) > 0 and not na(bestIdx)
    for i = 0 to array.size(blockNodes) - 1
        BlockNode node = array.get(blockNodes, i)
        bool primeNow = i == bestIdx and not node.broken
        node.prime := primeNow
        color baseCol = node.bull ? cBull : cBear
        color primeCol = node.bull ? cPrimeBull : cPrimeBear
        if node.broken
            baseCol := color.new(chart.fg_color, 70)
            primeCol := color.new(chart.fg_color, 70)
        color bodyCol = primeNow ? color.new(primeCol, 76) : color.new(baseCol, node.broken ? 90 : 84)
        color edgeCol = primeNow ? color.new(primeCol, 18) : color.new(baseCol, node.broken ? 82 : 36)
        node.body.set_bgcolor(bodyCol)
        node.body.set_border_color(edgeCol)
        node.body.set_border_width(primeNow ? 2 : 1)
        node.mid.set_color(primeNow ? color.new(primeCol, 0) : color.new(baseCol, 24))
        node.mid.set_width(primeNow ? 2 : 1)
        if not na(node.breakLine)
            node.breakLine.set_color(primeNow ? color.new(primeCol, 0) : color.new(baseCol, node.broken ? 78 : 18))
            node.breakLine.set_width(primeNow ? 2 : 1)
        if not na(node.impulseLine)
            node.impulseLine.set_color(primeNow ? color.new(primeCol, 18) : color.new(baseCol, node.broken ? 86 : 46))
        if not na(node.tag)
            node.tag.set_textcolor(primeNow ? primeCol : (node.bull ? cBull : cBear))
        if not na(node.breakTag)
            node.breakTag.set_textcolor(primeNow ? primeCol : (node.bull ? cBull : cBear))

barcolor(showBiasTint and activeCount > 0 ? color.new(primeAura, 78) : na, title = "Prime Structure Candle Tint")

var table dash = table.new(tablePos, 2, 8, bgcolor = cBack, border_width = 0, frame_color = cEdge, frame_width = 1)

if showDash and barstate.islast
    dash_cell(dash, 0, 0, "Structure Blocks", cText, color.new(primeAura, 78), text.align_center)
    dash_cell(dash, 1, 0, "Quality", cText, color.new(primeAura, 78), text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)

    dash_cell(dash, 0, 1, "Active", cSub, na, text.align_left)
    dash_cell(dash, 1, 1, str.tostring(activeCount), cText, na, text.align_right)

    dash_cell(dash, 0, 2, "Bull / Bear", cSub, na, text.align_left)
    dash_cell(dash, 1, 2, str.tostring(bullCount) + " / " + str.tostring(bearCount), cText, na, text.align_right)

    dash_cell(dash, 0, 3, "Best score", cSub, na, text.align_left)
    dash_cell(dash, 1, 3, str.tostring(bestScore, "#.#"), primeAura, color.new(primeAura, 88), text.align_right)

    dash_cell(dash, 0, 4, "Break state", cSub, na, text.align_left)
    dash_cell(dash, 1, 4, liveState, liveCol, na, text.align_right)

    dash_cell(dash, 0, 5, "Last pulse", cSub, na, text.align_left)
    dash_cell(dash, 1, 5, lastPulse, lastPulseCol, na, text.align_right)

    dash_cell(dash, 0, 6, "Volume rank", cSub, na, text.align_left)
    dash_cell(dash, 1, 6, str.tostring(volPct, "#.#"), cText, na, text.align_right)

    dash_cell(dash, 0, 7, "Break mode", cSub, na, text.align_left)
    dash_cell(dash, 1, 7, extendAfterBreak ? "Extend" : "Stop", cText, na, text.align_right)

alertcondition(newBullBlock, "SPB Bull Block", "Structure Probability Blocks [JOAT] created a bullish quality block on {{ticker}}.")
alertcondition(newBearBlock, "SPB Bear Block", "Structure Probability Blocks [JOAT] created a bearish quality block on {{ticker}}.")
````
