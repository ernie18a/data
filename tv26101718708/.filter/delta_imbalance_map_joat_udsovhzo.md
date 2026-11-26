# Delta Imbalance Map [JOAT]

- url: https://www.tradingview.com/script/uDsOvhzO-Delta-Imbalance-Map-JOAT/
- type: indicator
- pine_id: PUB;b80f337fb3124092b93e0d9bc459e762
- version: 1.0

## Description

[b]Delta Imbalance Map [JOAT][/b]

[b]Introduction[/b]

Delta Imbalance Map is an open-source imbalance mapping tool that identifies fair value gaps and scores them using gap size, candle drive, volume rank, and lower-timeframe participation tilt. The goal is to show not only where an imbalance exists, but whether the participation behind it is meaningfully tilted.

The problem this indicator solves is noisy zone plotting. Many imbalance tools mark every three-bar gap with equal importance. Delta Imbalance Map uses permissive defaults so important gaps appear often, then manages overlap so newer or stronger zones replace stale overlapping zones. Each active zone can carry its own compact right-edge data tag with price range, score, participation lead, and gap size in ATR units.

[image]https://www.tradingview.com/x/ngxDtxkl/[/image]

[b]Core Concepts[/b]

[b]1. Three-Bar Imbalance Detection[/b]

The script detects bullish gaps when the current low is above the high two bars back, and bearish gaps when the current high is below the low two bars back.

[pine]
bullGap = low > high[2]
bearGap = high < low[2]
[/pine]

[b]2. Lower-Timeframe Participation Split[/b]

The script requests lower-timeframe volume, close, and open arrays. Intrabars closing up are counted as buyer participation, intrabars closing down are counted as seller participation, and flat intrabars are split.

[b]3. Composite Zone Score[/b]

Each new zone receives a quality score from gap size relative to ATR, lower-timeframe tilt, candle body drive, and volume rank. Optional minimum tilt and volume-rank inputs can tighten the feed when a chart becomes too busy.

[b]4. Overlap Management[/b]

If a new zone overlaps an existing zone, filled overlaps are cleared and active overlaps are resolved by score. This keeps a generous stream of zones without stacking many boxes at the same price.

[b]5. Zone Rails and Data Tags[/b]

Each imbalance draws a subtle outer glow box, direction-colored gradient edge, green buy-participation section, red sell-participation section, dashed top and bottom price rails, a dotted internal participation split line, and compact labels beside the related zone. Visible labels are capped and staggered to avoid covering the chart.

[b]Features[/b]

[list]
[*][b]ATR-filtered imbalance detection:[/b] Removes tiny gaps below the selected size threshold
[*][b]Lower-timeframe delta proxy:[/b] Uses intrabar candle direction to estimate buyer/seller participation
[*][b]Split-zone coloring:[/b] Zones are divided into bullish and bearish participation areas
[*][b]Gradient glow boxes:[/b] Outer zone shell shifts from cyan/violet into bull/bear edge colors based on score
[*][b]Price rail system:[/b] Top, bottom, and internal split lines extend to the right edge
[*][b]Compact capped tags:[/b] Active and filled tags are limited and staggered to reduce label overlap
[*][b]Quality score tags:[/b] Each active zone can show price range, score, participation lead, and ATR gap size
[*][b]Mitigation modes:[/b] Touch or full-fill logic
[*][b]Overlap guard:[/b] Keeps the stronger of overlapping zones
[*][b]Color-faded filled zones:[/b] Filled zones remain visible by default with compact zone labels
[*][b]Candle tilt tinting:[/b] Candles can be softly tinted by the active imbalance tilt
[*][b]Birth-bar mitigation guard:[/b] New zones cannot be marked filled on the same candle they are created
[*][b]Top-right dashboard:[/b] Active count, filled count, bull/bear count, average score, tilt, lower timeframe, state, and fill mode
[*][b]Alerts:[/b] New bullish and bearish imbalance creation events
[/list]

[b]Input Parameters[/b]

[b]Detection:[/b]
[list]
[*]Delta Lower TF: Lower timeframe used for participation split
[*]Min Gap ATR: Minimum gap size relative to ATR
[*]Min Delta Tilt: Minimum buyer/seller skew needed to accept a zone
[*]Min Volume Rank: Minimum volume percentile required for plotting a new zone
[*]Mitigation: Touch or Full Fill
[*]Prefer Stronger Overlap: Removes weaker overlapping zones
[*]Zone Life Bars: Maximum active lifetime for unfilled zones
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Look for active zones that remain unfilled.
[b]Step 2:[/b] Read the tag score and buyer/seller tilt.
[b]Step 3:[/b] Use the top and bottom rails as the exact price boundaries of the imbalance.
[b]Step 4:[/b] Use the dashboard state to see if active zones lean buyer-led, seller-led, or balanced.
[b]Step 5:[/b] Treat mitigated zones as resolved context rather than fresh trade signals.

[b]Indicator Limitations[/b]

[list]
[*]Lower-timeframe participation is a candle-direction volume proxy, not true bid/ask delta
[*]Some lower timeframes may not be available on every TradingView plan or symbol
[*]Fair value gaps can remain open for long periods or fail to react when revisited
[*]Signals and zones are created on confirmed bars to reduce repaint risk
[/list]

[b]Originality Statement[/b]

Delta Imbalance Map is original in its combination of ATR filtering, lower-timeframe participation tilt, composite scoring, overlap prioritization, mitigation lifecycle, and dashboard summarization. It does not copy third-party source code.

[b]Disclaimer[/b]

This open-source indicator is for educational and informational use only. It is not financial advice and does not predict that an imbalance will fill or reverse price. Always use proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Delta Imbalance Map [JOAT]", "DIM [JOAT]", overlay = true, max_boxes_count = 300, max_labels_count = 200, max_lines_count = 200)

color cBull = #089981
color cBear = #f23645
color cText = #d7dde6
color cSub = #87919c
color cBack = #111418
color cPanel = #151b22
color cEdge = #27313b
color cCyan = #00e5ff
color cViolet = #9c27b0
color cBullGlow = #00ff9f
color cBearGlow = #ff174d

string grpDet = "Detection"
string grpVis = "Visuals"
string grpDash = "Dashboard"

string mitTouch = "Touch"
string mitFull = "Full Fill"

string posTopRight = "Top Right"
string posBotRight = "Bottom Right"
string posBotLeft = "Bottom Left"

string sizeTiny = "Tiny"
string sizeSmall = "Small"
string sizeNormal = "Normal"
string sizeLarge = "Large"
string sizeHuge = "Huge"

type GapNode
    box glowBox
    box topBox
    box botBox
    line topRail
    line bottomRail
    line midLine
    label tag
    float top
    float bottom
    float score
    bool bull
    bool done
    float buyPct
    float sellPct
    float volRank
    float atrSize
    int born

var array<GapNode> gapNodes = array.new<GapNode>()

gapTf = input.timeframe("1", "Delta lower TF", group = grpDet, tooltip = "Lower timeframe used to split volume inside each bar.")
minGapAtr = input.float(0.05, "Min gap ATR", minval = 0.0, step = 0.01, group = grpDet)
minBias = input.float(0.0, "Min delta tilt", minval = 0.0, step = 1.0, group = grpDet, tooltip = "Minimum lower-TF participation tilt needed to accept a new zone.")
minVolRank = input.float(0.0, "Min volume rank", minval = 0.0, maxval = 100.0, step = 1.0, group = grpDet)
mitMode = input.string(mitTouch, "Mitigation", options = [mitTouch, mitFull], group = grpDet)
useOverlapGuard = input.bool(true, "Prefer stronger overlap", group = grpDet)
zoneAge = input.int(140, "Zone life bars", minval = 10, maxval = 1000, group = grpDet)

maxZones = input.int(32, "Max tracked zones", minval = 1, maxval = 100, group = grpVis)
showFilled = input.bool(true, "Keep filled zones", group = grpVis)
splitOpacity = input.int(68, "Base opacity", minval = 0, maxval = 100, group = grpVis)
showLabels = input.bool(true, "Show zone tags", group = grpVis)
maxVisibleTags = input.int(24, "Max visible tags", minval = 0, maxval = 50, group = grpVis)
showFilledTags = input.bool(true, "Show filled tags", group = grpVis)
showRails = input.bool(true, "Show price rails", group = grpVis)
showTiltTint = input.bool(true, "Tint candles by active tilt", group = grpVis)

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

zone_tag_text(GapNode node, bool compact) =>
    string sideTxt = node.bull ? "Bull FVG" : "Bear FVG"
    string biasTxt = node.buyPct >= node.sellPct ? "Buy " + str.tostring(node.buyPct, "#") + "%" : "Sell " + str.tostring(node.sellPct, "#") + "%"
    compact ? sideTxt + " | " + str.tostring(node.score, "#") + "\n" + str.tostring(node.bottom, format.mintick) + " - " + str.tostring(node.top, format.mintick) + "\n" + biasTxt + " | " + str.tostring(node.atrSize, "#.##") + " ATR" : sideTxt + "\nScore " + str.tostring(node.score, "#.#") + " | Vol " + str.tostring(node.volRank, "#") + "\nTop " + str.tostring(node.top, format.mintick) + "\nBot " + str.tostring(node.bottom, format.mintick) + "\nBuy " + str.tostring(node.buyPct, "#.#") + "% / Sell " + str.tostring(node.sellPct, "#.#") + "%\nGap " + str.tostring(node.atrSize, "#.##") + " ATR"

erase_gap(GapNode node) =>
    if not na(node.glowBox)
        node.glowBox.delete()
    if not na(node.topBox)
        node.topBox.delete()
    if not na(node.botBox)
        node.botBox.delete()
    if not na(node.topRail)
        node.topRail.delete()
    if not na(node.bottomRail)
        node.bottomRail.delete()
    if not na(node.midLine)
        node.midLine.delete()
    if not na(node.tag)
        node.tag.delete()

split_delta() =>
    float upVol = 0.0
    float dnVol = 0.0
    [vArr, cArr, oArr] = request.security_lower_tf(syminfo.tickerid, gapTf, [volume, close, open], ignore_invalid_timeframe = true)

    if not na(vArr) and array.size(vArr) > 0
        for i = 0 to array.size(vArr) - 1
            float vv = nz(array.get(vArr, i))
            float cc = nz(array.get(cArr, i))
            float oo = nz(array.get(oArr, i))
            if cc > oo
                upVol += vv
            else if cc < oo
                dnVol += vv
            else
                upVol += vv * 0.5
                dnVol += vv * 0.5
    else
        float fbVol = nz(volume, 0.0)
        if close >= open
            upVol += fbVol
        else
            dnVol += fbVol

    float total = math.max(upVol + dnVol, 0.0)
    float upPct = total > 0.0 ? (upVol / total) * 100.0 : 50.0
    float dnPct = total > 0.0 ? (dnVol / total) * 100.0 : 50.0
    [upPct, dnPct]

atr = nz(ta.atr(14), high - low)
volRank = nz(ta.percentrank(nz(volume, 0.0), 50), 50.0)
[buyPctRaw, sellPctRaw] = split_delta()
float buyPct = nz(buyPctRaw[1], 50.0)
float sellPct = nz(sellPctRaw[1], 50.0)

bool newBullZone = false
bool newBearZone = false

if barstate.isconfirmed
    bool bullGap = low > high[2]
    bool bearGap = high < low[2]
    float gapSize = bullGap ? low - high[2] : bearGap ? low[2] - high : 0.0
    float minSize = atr * minGapAtr

    float tilt = bullGap ? buyPct - sellPct : bearGap ? sellPct - buyPct : 0.0
    float bodyDrive = math.abs(close[1] - open[1]) / math.max(atr, syminfo.mintick)
    float gapScore = math.min(100.0, (gapSize / math.max(minSize, syminfo.mintick)) * 30.0 + math.max(tilt, 0.0) * 0.7 + bodyDrive * 12.0 + volRank * 0.12)

    bool passSize = gapSize >= minSize
    bool passTilt = math.abs(tilt) >= minBias
    bool passVol = volRank >= minVolRank

    if (bullGap or bearGap) and passSize and passTilt and passVol
        float top = bullGap ? low : low[2]
        float bottom = bullGap ? high[2] : high
        float height = top - bottom
        float splitY = bottom + height * (sellPct / 100.0)

        bool acceptZone = true
        if useOverlapGuard and array.size(gapNodes) > 0
            for i = array.size(gapNodes) - 1 to 0
                GapNode old = array.get(gapNodes, i)
                bool overlap = math.max(bottom, old.bottom) < math.min(top, old.top)
                if overlap
                    if old.done or gapScore > old.score
                        erase_gap(old)
                        array.remove(gapNodes, i)
                    else
                        acceptZone := false
                        break

        if acceptZone
            color dirBase = bullGap ? cBullGlow : cBearGlow
            color contraBase = bullGap ? cBear : cBull
            color topTint = color.new(dirBase, splitOpacity)
            color botTint = color.new(contraBase, math.min(splitOpacity + 12, 96))
            color edgeRaw = color.from_gradient(gapScore, 0.0, 100.0, bullGap ? cBull : cBear, dirBase)
            color edgeTint = color.new(edgeRaw, 4)
            color lineTint = color.new(edgeTint, 5)
            color glowTint = color.new(edgeRaw, 90)
            float zoneAtr = gapSize / math.max(atr, syminfo.mintick)

            box glowBox = box.new(bar_index[2], top, bar_index + 8, bottom, bgcolor = glowTint, border_color = color.new(edgeTint, 65), border_width = 2, border_style = line.style_solid)
            box topBox = box.new(bar_index[2], top, bar_index + 4, splitY, bgcolor = topTint, border_color = edgeTint, border_width = 2, border_style = line.style_dashed)
            box botBox = box.new(bar_index[2], splitY, bar_index + 4, bottom, bgcolor = botTint, border_color = edgeTint, border_width = 2, border_style = line.style_dashed)
            line topRail = showRails ? line.new(bar_index[2], top, bar_index + 10, top, color = color.new(edgeTint, 12), style = line.style_dashed, width = 1) : na
            line bottomRail = showRails ? line.new(bar_index[2], bottom, bar_index + 10, bottom, color = color.new(edgeTint, 12), style = line.style_dashed, width = 1) : na
            line midLine = line.new(bar_index[2], splitY, bar_index + 10, splitY, color = lineTint, style = line.style_dotted, width = 2)

            string tagTxt = (bullGap ? "Bull FVG" : "Bear FVG") + " | " + str.tostring(gapScore, "#") + "\n" + str.tostring(bottom, format.mintick) + " - " + str.tostring(top, format.mintick)
            label tag = na
            if showLabels
                tag := label.new(bar_index + 10, (top + bottom) * 0.5, tagTxt, style = label.style_label_left, color = color.new(cPanel, 5), textcolor = edgeTint, size = size.small)

            GapNode node = GapNode.new(glowBox, topBox, botBox, topRail, bottomRail, midLine, tag, top, bottom, gapScore, bullGap, false, buyPct, sellPct, volRank, zoneAtr, bar_index)
            array.push(gapNodes, node)
            newBullZone := bullGap
            newBearZone := bearGap

            if array.size(gapNodes) > maxZones
                GapNode oldNode = array.shift(gapNodes)
                erase_gap(oldNode)

int visibleTagCount = 0

if array.size(gapNodes) > 0
    for i = array.size(gapNodes) - 1 to 0
        GapNode node = array.get(gapNodes, i)
        bool expired = (bar_index - node.born) > zoneAge
        bool canMitigate = bar_index > node.born
        bool fillHit = canMitigate and (node.bull ? (mitMode == mitTouch ? low < node.top : low <= node.bottom) : (mitMode == mitTouch ? high > node.bottom : high >= node.top))

        if not node.done and (expired or fillHit)
            node.done := true
            if not showFilled
                erase_gap(node)
                array.remove(gapNodes, i)
            else
                color filledRaw = node.bull ? cBullGlow : cBearGlow
                color fadedEdge = color.new(filledRaw, 78)
                node.glowBox.set_bgcolor(color.new(filledRaw, 96))
                node.glowBox.set_border_color(color.new(filledRaw, 88))
                node.topBox.set_bgcolor(color.new(cBull, 91))
                node.botBox.set_bgcolor(color.new(cBear, 93))
                node.topBox.set_border_color(fadedEdge)
                node.botBox.set_border_color(fadedEdge)
                node.glowBox.set_right(bar_index)
                node.topBox.set_right(bar_index)
                node.botBox.set_right(bar_index)
                if not na(node.topRail)
                    node.topRail.set_color(color.new(filledRaw, 82))
                    node.topRail.set_x2(bar_index)
                if not na(node.bottomRail)
                    node.bottomRail.set_color(color.new(filledRaw, 82))
                    node.bottomRail.set_x2(bar_index)
                node.midLine.set_color(color.new(filledRaw, 78))
                node.midLine.set_x2(bar_index)
                if not na(node.tag)
                    if showFilledTags and visibleTagCount < maxVisibleTags
                        int filledTagOffset = 2 + (visibleTagCount % 6) * 3
                        node.tag.set_x(bar_index + filledTagOffset)
                        node.tag.set_y((node.top + node.bottom) * 0.5)
                        node.tag.set_text(zone_tag_text(node, true))
                        node.tag.set_color(color.new(cPanel, 12))
                        node.tag.set_textcolor(color.new(filledRaw, 8))
                        visibleTagCount += 1
                    else
                        node.tag.set_text("")
                        node.tag.set_color(color.new(cPanel, 100))
                        node.tag.set_textcolor(color.new(chart.fg_color, 100))
        else if not node.done
            color activeRaw = node.bull ? cBullGlow : cBearGlow
            color activeEdge = color.from_gradient(node.score, 0.0, 100.0, node.bull ? cBull : cBear, activeRaw)
            node.glowBox.set_right(bar_index + 8)
            node.topBox.set_right(bar_index + 4)
            node.botBox.set_right(bar_index + 4)
            if not na(node.topRail)
                node.topRail.set_x2(bar_index + 10)
            if not na(node.bottomRail)
                node.bottomRail.set_x2(bar_index + 10)
            node.midLine.set_x2(bar_index + 10)
            if not na(node.tag)
                bool showThisTag = showLabels and visibleTagCount < maxVisibleTags
                int tagOffset = 10 + (visibleTagCount % 6) * 3
                node.tag.set_x(bar_index + tagOffset)
                node.tag.set_y((node.top + node.bottom) * 0.5)
                node.tag.set_text(showThisTag ? zone_tag_text(node, true) : "")
                node.tag.set_color(showThisTag ? color.new(cPanel, 8) : color.new(cPanel, 100))
                node.tag.set_textcolor(showThisTag ? color.new(activeEdge, 0) : color.new(activeEdge, 100))
                if showThisTag
                    visibleTagCount += 1

bullCount = 0
bearCount = 0
activeCount = 0
trackedCount = array.size(gapNodes)
filledCount = 0
float scoreSum = 0.0
float tiltSum = 0.0

if array.size(gapNodes) > 0
    for i = 0 to array.size(gapNodes) - 1
        GapNode node = array.get(gapNodes, i)
        if not node.done
            activeCount += 1
            scoreSum += node.score
            tiltSum += node.buyPct - node.sellPct
            if node.bull
                bullCount += 1
            else
                bearCount += 1
        else
            filledCount += 1

float avgScore = activeCount > 0 ? scoreSum / activeCount : 0.0
float avgTilt = activeCount > 0 ? tiltSum / activeCount : 0.0
string stateTxt = avgTilt > 4 ? "Buyer lead" : avgTilt < -4 ? "Seller lead" : "Balanced"
color stateCol = avgTilt > 4 ? cBull : avgTilt < -4 ? cBear : cSub
color tiltTint = color.from_gradient(avgTilt, -35.0, 35.0, cViolet, cCyan)
barcolor(showTiltTint and activeCount > 0 ? color.new(tiltTint, 78) : na, title = "Active Imbalance Tilt")

var table dash = table.new(tablePos, 2, 9, bgcolor = cBack, border_width = 0, frame_color = cEdge, frame_width = 1)

if showDash and barstate.islast
    color scoreBg = color.new(color.from_gradient(avgScore, 0.0, 100.0, cViolet, cCyan), 84)
    color stateBg = color.new(stateCol, 84)
    dash_cell(dash, 0, 0, "Delta Imbalance [JOAT]", cText, color.new(tiltTint, 72), text.align_center)
    dash_cell(dash, 1, 0, "Zones", cText, color.new(tiltTint, 72), text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)

    dash_cell(dash, 0, 1, "Active", cSub, color.new(cPanel, 8), text.align_left)
    dash_cell(dash, 1, 1, str.tostring(activeCount), activeCount > 0 ? tiltTint : cSub, color.new(cPanel, 8), text.align_right)

    dash_cell(dash, 0, 2, "Filled", cSub, na, text.align_left)
    dash_cell(dash, 1, 2, str.tostring(filledCount), cText, na, text.align_right)

    dash_cell(dash, 0, 3, "Bull / Bear", cSub, na, text.align_left)
    dash_cell(dash, 1, 3, str.tostring(bullCount) + " / " + str.tostring(bearCount), bullCount >= bearCount ? cBull : cBear, na, text.align_right)

    dash_cell(dash, 0, 4, "Avg score", cSub, na, text.align_left)
    dash_cell(dash, 1, 4, str.tostring(avgScore, "#.#"), cText, scoreBg, text.align_right)

    dash_cell(dash, 0, 5, "Tilt", cSub, na, text.align_left)
    dash_cell(dash, 1, 5, str.tostring(avgTilt, "#.#"), tiltTint, stateBg, text.align_right)

    dash_cell(dash, 0, 6, "Lower TF", cSub, na, text.align_left)
    dash_cell(dash, 1, 6, gapTf, cText, na, text.align_right)

    dash_cell(dash, 0, 7, "State", cSub, na, text.align_left)
    dash_cell(dash, 1, 7, stateTxt, stateCol, stateBg, text.align_right)

    dash_cell(dash, 0, 8, "Fill mode", cSub, na, text.align_left)
    dash_cell(dash, 1, 8, mitMode, cText, na, text.align_right)

alertcondition(newBullZone, "DIM Bull Zone", "Delta Imbalance Map [JOAT] created a bullish imbalance on {{ticker}}.")
alertcondition(newBearZone, "DIM Bear Zone", "Delta Imbalance Map [JOAT] created a bearish imbalance on {{ticker}}.")
````
