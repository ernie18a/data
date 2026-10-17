# Edo Mitigation Blocks

- url: https://www.tradingview.com/script/ONMiSjzg-Edo-Mitigation-Blocks/
- type: indicator
- pine_id: PUB;7ff6e52483904512829cb194c5eeb2ab
- version: 1.0

## Description

Edo Mitigation Blocks — Marks the Order Blocks That Originate an Impulse and Tracks Their Retest Through Pending, Mitigated and Broken

[image]https://www.tradingview.com/x/Pl4oDdKc/[/image]

[image]https://www.tradingview.com/x/ktJ2Oz0j/[/image]

[image]https://www.tradingview.com/x/L12HUNkj/[/image]


When a large institutional order moves price, it is rarely filled all at once. Part of it is left over in the origin zone — the order block — and price tends to return later to that zone to complete it. That return is mitigation, and it is one of the most-watched reaction points in structure analysis: the moment the institutional interest that started the move makes itself present again, and where price so often bounces from demand or rejects from supply.

Edo Mitigation Blocks makes that cycle visible. It draws each order block the moment it forms, dimmed, as a zone still pending its retest, and highlights it as mitigated the instant price returns into it. From there it tracks whether the zone holds or is lost, following each block through three states — Pending, Mitigated and Broken — all validated per the chosen trigger so the indicator does not repaint. The zone, its mitigation and its break are decided inside the indicator itself, on the chart's own series, with nothing else required.

ORDER BLOCK AND MITIGATION

An order block is the last opposite candle before an impulse that breaks structure: the last bearish candle before a bullish break marks the demand zone, the last bullish candle before a bearish break marks the supply zone. The indicator draws it immediately as a pending block, extended to the right. Mitigation is price returning into that zone to fill the orders that were left over: a bullish block is mitigated when price drops back into demand, a bearish block when price rises back into supply. That retest is the indicator's central event.

BULL AND BEAR BLOCKS

A Bull Block is a demand zone, drawn in teal below the impulse that started from it; a Bear Block is a supply zone, drawn in red above its impulse. Each block is a box over the range of the origin candle, labelled Bull Block or Bear Block, dimmed while pending and highlighted with a "Mitigated" label once price returns to it. The teal/red color code separates demand from supply at a glance.

PENDING, MITIGATED AND BROKEN

Each block lives in one of three states, evaluated on every closed candle. Pending: freshly formed, dimmed, with a dotted border, extending to the right and awaiting its retest. Mitigated: price has returned to the zone per the trigger — the box is highlighted, the border turns solid and thicker, and a "Mitigated" label is added. Broken: after being mitigated, price closes through the opposite side of the zone — a Bull Block below its base, a Bear Block above its top — the border turns dashed and the box stops extending. A broken block has lost its relevance; only the most recent blocks per side are kept, up to Max Blocks per side (8 by default).

STRUCTURE PROFILE AND MITIGATION TRIGGER

The Structure Profile sets the swing sensitivity that defines a break: Scalper (5 bars each side) for short-term blocks on low timeframes, Swing (10 bars, the default) for the balanced 4H and daily read, and Long Term (21 bars) for the major blocks on weekly and higher horizons. The Mitigation trigger decides what counts as a return: in Wick mode a wick into the zone is enough — more sensitive, flagging the retest sooner; in Close mode a candle must close inside the zone — stricter, confirming only with a close. The Impulse Lookback (20 by default) sets how many bars back the indicator searches for the origin candle.

INFORMATION PANEL

A compact panel under the indicator header shows the number of pending blocks, the number of mitigated ones and the breakdown of pending blocks per side (Bull / Bear). The pending-per-side row is the most operational — more Bull pending means demand zones awaiting a retest below, more Bear pending supply zones above. The panel sits in any of the four chart corners (Top Right by default), comes in three sizes (Tiny / Small / Normal) and two themes (Dark / Light), and can be hidden entirely. To keep the calculation light, it is drawn only on the last bar.

NO REPAINTING

Blocks are built on confirmed pivots and mitigations and breaks are validated per the chosen trigger, so a zone never appears or disappears without cause. There are no higher-timeframe functions: all logic runs on the current chart timeframe. For a multi-timeframe read, apply it on several charts at once.

CONFIGURATION

The inputs are grouped by block. Structure sets the profile, the impulse lookback, the maximum blocks per side and the mitigation trigger. Style exposes the bullish and bearish colors, the pending and mitigated opacities, the label size and the Dark/Light theme. Panel controls panel visibility, position and size. The defaults are calibrated to work without adjustment on stocks, crypto, forex, indices and futures, on any timeframe — the inputs most users touch are the Structure Profile and the Mitigation trigger.

ALERTS

Three predefined alerts cover the block's life: Bullish Block mitigated and Bearish Block mitigated fire when price returns to a demand or supply zone and mitigates it — the reaction alerts; Block broken fires when an already-mitigated block is lost. All alerts fire per the chosen trigger, consistent with the indicator's anti-repaint validation.

HOW TO READ IT

Use a pending block as a target: a Bull Block below is a demand zone price can drop to seek, a Bear Block above a supply target, and the panel's pending row flags where they are. Watch the mitigation — when price returns and mitigates a block, the reaction confirms whether the zone keeps its strength, and a clean bounce from demand or rejection from supply validates it. Read the break too — a mitigated block closed through has been consumed, and recognizing it avoids leaning on a zone that no longer reacts. Trade blocks in confluence with the broader structure, and combine with active order block analysis and breaker blocks, the blocks that fail and invert.

OPEN SOURCE

Edo Mitigation Blocks is published as a free open source indicator. The full Pine Script is publicly accessible on TradingView for study, adaptation and integration into any workflow. Part of the Edolab Markets free tools ecosystem, all publicly available on TradingView.

This indicator is a technical analysis tool for educational and informational purposes only. It does not generate automatic buy or sell signals and should not be considered financial advice. Trading financial markets involves significant risk of capital loss. Past performance does not guarantee future results. Always use proper risk management.

## Source Code

````pine
// ─────────────────────────────────────────────────────────────────
// ███████╗██████╗  ██████╗ ██╗      █████╗ ██████╗
// ██╔════╝██╔══██╗██╔═══██╗██║     ██╔══██╗██╔══██╗
// █████╗  ██║  ██║██║   ██║██║     ███████║██████╔╝
// ██╔══╝  ██║  ██║██║   ██║██║     ██╔══██║██╔══██╗
// ███████╗██████╔╝╚██████╔╝███████╗██║  ██║██████╔╝
// ╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝
// ─────────────────────────────────────────────────────────────────
// ███╗   ███╗ █████╗ ██████╗ ██╗  ██╗███████╗████████╗███████╗
// ████╗ ████║██╔══██╗██╔══██╗██║ ██╔╝██╔════╝╚══██╔══╝██╔════╝
// ██╔████╔██║███████║██████╔╝█████╔╝ █████╗     ██║   ███████╗
// ██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗ ██╔══╝     ██║   ╚════██║
// ██║ ╚═╝ ██║██║  ██║██║  ██║██║  ██╗███████╗   ██║   ███████║
// ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝
// ─────────────────────────────────────────────────────────────────
// © Edolab Markets

//@version=6
indicator("Edo Mitigation Blocks", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// ================== SETTINGS — STRUCTURE ==================

profile = input.string("Swing", "Structure Profile", options = ["Scalper", "Swing", "Long Term"], group = "Structure", tooltip = "Scalper: fast swings (intraday)\nSwing: balanced (4H / D)\nLong Term: major swings only (W)")
obScan  = input.int(20, "Impulse Lookback", minval = 3, maxval = 60, group = "Structure", tooltip = "Bars to search back for the candle that originated the impulse.")
maxMB   = input.int(8,  "Max Blocks per side", minval = 1, maxval = 30, group = "Structure")
mitMode = input.string("Wick", "Mitigation trigger", options = ["Wick", "Close"], group = "Structure", tooltip = "Wick: zone mitigated when a wick returns to it.\nClose: requires a candle close inside the zone.")

swingLen = profile == "Scalper" ? 5 : profile == "Long Term" ? 21 : 10

// ================== SETTINGS — STYLE ==================

bullCol     = input.color(#26a69a, "Bullish block", group = "Style")
bearCol     = input.color(#ef5350, "Bearish block", group = "Style")
pendOpacity = input.int(88, "Pending Opacity %", minval = 0, maxval = 95, step = 5, group = "Style", tooltip = "Active (not yet mitigated) blocks are dimmer; mitigated blocks are highlighted.")
mitOpacity  = input.int(70, "Mitigated Opacity %", minval = 0, maxval = 95, step = 5, group = "Style")
labelSize   = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal"], group = "Style")
themeMode   = input.string("Dark",  "Theme Mode", options = ["Dark", "Light"], group = "Style", tooltip = "Match your TradingView background theme.")

// ================== SETTINGS — PANEL ==================

showPanel = input.bool(true, "Show Panel", group = "Panel")
panelPos  = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = "Panel")
panelSize = input.string("Small", "Panel Size", options = ["Tiny", "Small", "Normal"], group = "Panel")

// ================== THEME ==================

isDark   = themeMode == "Dark"
textCol  = isDark ? #ffffff : #131722
headerBg = isDark ? #2a2e39 : #d1d4dc
subBg    = isDark ? #363a45 : #e0e3eb
cellBg   = isDark ? #1e222d : #f0f3fa
cellTxt  = isDark ? #d1d4dc : #363a45

lblSizeTxt = labelSize == "Tiny" ? size.tiny : labelSize == "Normal" ? size.normal : size.small
panSizeTxt = panelSize == "Tiny" ? size.tiny : panelSize == "Normal" ? size.normal : size.small

// ================== SWING DETECTION + STRUCTURE ==================

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)

var float upperLevel  = na
var float lowerLevel  = na
var bool  upperBroken = false
var bool  lowerBroken = false

if not na(ph)
    upperLevel  := ph
    upperBroken := false
if not na(pl)
    lowerLevel  := pl
    lowerBroken := false

bullBreak = barstate.isconfirmed and not na(upperLevel) and not upperBroken and close > upperLevel
bearBreak = barstate.isconfirmed and not na(lowerLevel) and not lowerBroken and close < lowerLevel
if bullBreak
    upperBroken := true
if bearBreak
    lowerBroken := true

// ================== MITIGATION BLOCK STORE ==================
// A block is the origin candle of an impulse. Its focus is the moment price RETURNS to it
// (mitigation) — confirming the institutional orders there were absorbed.

var box[]   mbBox    = array.new<box>()
var label[] mbLbl    = array.new<label>()
var bool[]  mbIsBull = array.new<bool>()
var float[] mbTop    = array.new<float>()
var float[] mbBtm    = array.new<float>()
var int[]   mbState  = array.new<int>()   // 0 pending, 1 mitigated, 2 broken
var int[]   mbStart  = array.new<int>()

makeBlock(bool isBull) =>
    idx = -1
    maxScan = math.min(obScan, bar_index - 1)
    if maxScan >= 1
        for j = 1 to maxScan
            isBearCandle = close[j] < open[j]
            isBullCandle = close[j] > open[j]
            if isBull and isBearCandle
                idx := j
                break
            if not isBull and isBullCandle
                idx := j
                break
    if idx >= 0
        t   = high[idx]
        b   = low[idx]
        col = isBull ? bullCol : bearCol
        bx  = box.new(bar_index - idx, t, bar_index + 10, b, border_color = color.new(col, 55), bgcolor = color.new(col, pendOpacity), border_width = 1, border_style = line.style_dotted)
        lb  = label.new(bar_index - idx, isBull ? b : t, isBull ? "Bull Block" : "Bear Block", style = isBull ? label.style_label_up : label.style_label_down, color = color.new(col, 88), textcolor = col, size = size.tiny)
        mbBox.push(bx)
        mbLbl.push(lb)
        mbIsBull.push(isBull)
        mbTop.push(t)
        mbBtm.push(b)
        mbState.push(0)
        mbStart.push(bar_index)

if bullBreak
    makeBlock(true)
if bearBreak
    makeBlock(false)

// ================== MITIGATION + BREAK STATE ==================

bullMitigated = false
bearMitigated = false
blockBroken   = false

if mbBox.size() > 0
    for i = mbBox.size() - 1 to 0
        st  = mbState.get(i)
        isB = mbIsBull.get(i)
        t   = mbTop.get(i)
        b   = mbBtm.get(i)
        bx  = mbBox.get(i)
        col = isB ? bullCol : bearCol
        if st != 2
            box.set_right(bx, bar_index + 10)
            if bar_index > mbStart.get(i) and barstate.isconfirmed
                if st == 0
                    // pending -> mitigated when price returns into the zone
                    mit = isB ? (mitMode == "Close" ? close <= t and close >= b : low <= t) : (mitMode == "Close" ? close >= b and close <= t : high >= b)
                    if mit
                        mbState.set(i, 1)
                        box.set_bgcolor(bx, color.new(col, mitOpacity))
                        box.set_border_style(bx, line.style_solid)
                        box.set_border_width(bx, 2)
                        label.new(bar_index, isB ? b : t, "Mitigated", style = isB ? label.style_label_up : label.style_label_down, color = color.new(col, 80), textcolor = col, size = lblSizeTxt)
                        if isB
                            bullMitigated := true
                        else
                            bearMitigated := true
                else
                    // mitigated -> broken when price closes through the far side
                    brk = isB ? close < b : close > t
                    if brk
                        mbState.set(i, 2)
                        box.set_bgcolor(bx, color.new(col, math.min(mitOpacity + 15, 95)))
                        box.set_border_style(bx, line.style_dashed)
                        box.set_border_width(bx, 1)
                        box.set_right(bx, bar_index)
                        blockBroken := true

// ================== TRIM PER SIDE ==================

trimSide(bool sideBull) =>
    cnt = 0
    if mbBox.size() > 0
        for i = mbBox.size() - 1 to 0
            if mbIsBull.get(i) == sideBull
                cnt += 1
                if cnt > maxMB
                    box.delete(mbBox.get(i))
                    label.delete(mbLbl.get(i))
                    mbBox.remove(i)
                    mbLbl.remove(i)
                    mbIsBull.remove(i)
                    mbTop.remove(i)
                    mbBtm.remove(i)
                    mbState.remove(i)
                    mbStart.remove(i)

trimSide(true)
trimSide(false)

// ================== PANEL ==================

if showPanel and barstate.islast
    panelPosTV = switch panelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

    var table panel = table.new(panelPosTV, 2, 4, frame_color = isDark ? #363a45 : #b2b5be, frame_width = 1, border_color = isDark ? #434651 : #c8cbda, border_width = 1)

    pending   = 0
    mitigated = 0
    if mbBox.size() > 0
        for i = 0 to mbBox.size() - 1
            s = mbState.get(i)
            if s == 0
                pending += 1
            else if s == 1
                mitigated += 1

    table.cell(panel, 0, 0, "EDO MITIGATION BLOCKS", text_color = textCol, bgcolor = headerBg, text_size = panSizeTxt)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 1, "Pending",   text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 1, str.tostring(pending), text_color = textCol, bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 2, "Mitigated", text_color = cellTxt, bgcolor = subBg, text_size = panSizeTxt)
    table.cell(panel, 1, 2, str.tostring(mitigated), text_color = textCol, bgcolor = subBg, text_size = panSizeTxt)

    table.cell(panel, 0, 3, "Bull / Bear pending", text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    cntB = 0
    cntS = 0
    if mbBox.size() > 0
        for i = 0 to mbBox.size() - 1
            if mbState.get(i) == 0
                if mbIsBull.get(i)
                    cntB += 1
                else
                    cntS += 1
    table.cell(panel, 1, 3, str.tostring(cntB) + " / " + str.tostring(cntS), text_color = textCol, bgcolor = cellBg, text_size = panSizeTxt)

// ================== ALERTS ==================

alertcondition(bullMitigated, "Bullish Block mitigated", "Edo Mitigation Blocks — Bullish block mitigated on {{ticker}}")
alertcondition(bearMitigated, "Bearish Block mitigated", "Edo Mitigation Blocks — Bearish block mitigated on {{ticker}}")
alertcondition(blockBroken,   "Block broken",            "Edo Mitigation Blocks — A mitigated block was broken on {{ticker}}")
````
