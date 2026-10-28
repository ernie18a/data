# Edo PDH/PDL Levels

- url: https://www.tradingview.com/script/H2kA7Gbf-Edo-PDH-PDL-Levels/
- type: indicator
- pine_id: PUB;9c05a12901d04e3b9c818857bfd9d766
- version: 1.0

## Description

Edo PDH/PDL Levels — Draws the Previous Day, Week, Month and Year Highs and Lows as Objective, Non-Repainting Reference Levels

[image]https://www.tradingview.com/x/RboR8E3c/[/image]

[image]https://www.tradingview.com/x/a8f8JJpB/[/image]

[image]https://www.tradingview.com/x/ylcrJZH2/[/image]


The extremes of a closed period are among the most objective and most-watched references in the market. Yesterday's high is a price everyone can see, and where breakout orders and short stops pile up; the same goes for the previous low, and for the extremes of the week, month and year. These levels act as magnets that price returns to test, as support and resistance that stop and turn it, and as breakout zones whose cross signals strength or weakness.

Edo PDH/PDL Levels keeps them always in view, drawn automatically so you never have to trace them by hand. It reads the high and low of each previous closed period, plots them as labelled horizontal lines extended to the right, summarizes them in a panel, and alerts when price crosses the day's or week's. Because they are computed on already-closed periods, the values are firm: they do not repaint or change with the running candle. It is built for intraday but useful on any timeframe, and it is self-contained: the levels come straight from the closed periods of the chart's own series.

THE LEVELS

The indicator offers up to four pairs of levels, one per higher timeframe: PDH/PDL (previous day, teal), PWH/PWL (previous week, gold), PMH/PML (previous month, purple) and PYH/PYL (previous year, red). The day and week are on by default; the month and year are optional, off by default to keep the chart clean. Each level is a horizontal line labelled with its name and exact price, extended to the right, in the color of its timeframe.

WHY THEY MATTER

Previous-period extremes are objective references anyone can read. The PDH and PDL frame the previous day's range: while price moves between them the market is inside yesterday's range; a cross above the PDH is a signal of strength that opens the door to continuation, a cross below the PDL, of weakness. The weekly PWH/PWL are higher-weight references, framing the previous weekly range and often acting as more robust support and resistance. And the confluence between periods — a PDH that coincides with the PWH, a PDL sitting on a weekly low — adds weight to a level.

THE RANGE MIDPOINT

Beyond the extremes, the indicator can draw the 50% midpoint of each previous period's range. This equilibrium line is a mean-reversion reference: price tends to gravitate toward the center of the previous range, and the 50% often acts as a magnet and a pivot between its bullish and bearish halves. It is off by default and enabled with the "Show previous range midpoint (50%)" option, drawing PD 50%, PW 50% and so on in each timeframe's color.

INFORMATION PANEL

A compact panel under the indicator header lists, per period (D, W, M, Y), the previous high and low. Active periods show their value and color; inactive ones, dashes. It is the quick numeric reference of every level at a glance, even when their lines are off-screen. The panel sits in any of the four chart corners (Top Right by default), comes in three sizes (Tiny / Small / Normal) and two themes (Dark / Light), and can be hidden entirely. To keep the calculation light, it is drawn only on the last bar.

NO REPAINTING

The levels are read from the previous closed period of each timeframe. Since those periods are already finished — yesterday, last week — the values are fixed the moment the period closes and stay constant throughout the current one. There is no intrabar change and no repainting.

STYLE AND CONFIGURATION

The look is fully configurable. Line style: solid, dashed (default) or dotted. Extension: lines extend to the right up to a configurable offset, keeping labels ahead of price. Labels can be shown or hidden and carry the level name and its price. Each period has its own configurable color, and a Dark/Light theme blends with the background. In the Levels block you toggle the day, week, month, year and the 50% midpoint; the defaults are calibrated for intraday, showing the day's and week's levels.

ALERTS

Four predefined alerts cover the key crosses: Cross above PDH and Cross below PDL on the day levels, Cross above PWH and Cross below PWL on the week levels. Clearing the PDH or PWH indicates strength and possible continuation; losing the PDL or PWL, weakness. It pays to tell a genuine cross that holds from a sweep that re-enters the range, a nuance read better by pairing the level with price's reaction.

HOW TO READ IT

Use the levels as support and resistance: while price ranges between the PDH and PDL it is inside yesterday's range, and breaking them opens the way, with the weekly levels as a higher-grade frame. Read the cross as a strength signal — a decisive close above a previous extreme is strength, losing it is weakness — and watch for confluence, where a day level meets a week level and gains weight. The 50% midpoint, when enabled, flags the range's equilibrium. And combined with the Edolab structure indicators, which read swings, order blocks and liquidity zones, these levels place those reads inside a map of firm, universally watched references.

OPEN SOURCE

Edo PDH/PDL Levels is published as a free open source indicator. The full Pine Script is publicly accessible on TradingView for study, adaptation and integration into any workflow. Part of the Edolab Markets free open source tools ecosystem, available on TradingView.

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
indicator("Edo PDH/PDL Levels", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ================== SETTINGS — LEVELS ==================

showDay   = input.bool(true,  "Previous Day (PDH / PDL)",   group = "Levels")
showWeek  = input.bool(true,  "Previous Week (PWH / PWL)",  group = "Levels")
showMonth = input.bool(false, "Previous Month (PMH / PML)", group = "Levels")
showYear  = input.bool(false, "Previous Year (PYH / PYL)",  group = "Levels")
showMid   = input.bool(false, "Show previous range midpoint (50%)", group = "Levels", tooltip = "Equilibrium of each previous period's range.")

// ================== SETTINGS — STYLE ==================

dayCol     = input.color(#5B9FAD, "Day",   inline = "c1", group = "Style")
weekCol    = input.color(#E6B800, "Week",  inline = "c1", group = "Style")
monthCol   = input.color(#9C6ADE, "Month", inline = "c2", group = "Style")
yearCol    = input.color(#ef5350, "Year",  inline = "c2", group = "Style")
lineStyle  = input.string("Dashed", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = "Style")
extendRgt  = input.bool(true, "Extend right", group = "Style")
extendR    = input.int(8, "Right offset (bars)", minval = 0, maxval = 60, group = "Style")
showLabels = input.bool(true, "Show labels", group = "Style")
labelSize  = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal"], group = "Style")
themeMode  = input.string("Dark",  "Theme Mode", options = ["Dark", "Light"], group = "Style", tooltip = "Match your TradingView background theme.")

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

styTV    = lineStyle == "Solid" ? line.style_solid : lineStyle == "Dotted" ? line.style_dotted : line.style_dashed
lblSizeTxt = labelSize == "Tiny" ? size.tiny : labelSize == "Normal" ? size.normal : size.small
panSizeTxt = panelSize == "Tiny" ? size.tiny : panelSize == "Normal" ? size.normal : size.small

fmt(float v) => na(v) ? "—" : str.tostring(v, format.mintick)

// ================== PREVIOUS-PERIOD VALUES (no repaint) ==================
// high[1]/low[1] of each HTF period are already closed -> lookahead is safe and non-repainting.

[pdh, pdl] = request.security(syminfo.tickerid, "D",   [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W",   [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pmh, pml] = request.security(syminfo.tickerid, "M",   [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pyh, pyl] = request.security(syminfo.tickerid, "12M", [high[1], low[1]], lookahead = barmerge.lookahead_on)

// ================== CROSS EVENTS (computed every bar for consistency) ==================

xPDH = ta.crossover(close, pdh)
xPDL = ta.crossunder(close, pdl)
xPWH = ta.crossover(close, pwh)
xPWL = ta.crossunder(close, pwl)

crossPDH = not na(pdh) and xPDH
crossPDL = not na(pdl) and xPDL
crossPWH = not na(pwh) and xPWH
crossPWL = not na(pwl) and xPWL

// ================== DRAW LEVELS ==================

var line[]  lvlLines  = array.new<line>()
var label[] lvlLabels = array.new<label>()

drawLevel(float price, string txt, color col) =>
    if not na(price)
        x1 = bar_index - 60
        x2 = bar_index + extendR
        ln = line.new(x1, price, x2, price, color = col, width = 1, style = styTV, extend = extendRgt ? extend.right : extend.none)
        lvlLines.push(ln)
        if showLabels
            lb = label.new(x2, price, txt + "  " + str.tostring(price, format.mintick), style = label.style_label_left, color = color.new(col, 90), textcolor = col, size = lblSizeTxt)
            lvlLabels.push(lb)

if barstate.islast
    // clear previous frame
    if lvlLines.size() > 0
        for i = 0 to lvlLines.size() - 1
            line.delete(lvlLines.get(i))
    if lvlLabels.size() > 0
        for i = 0 to lvlLabels.size() - 1
            label.delete(lvlLabels.get(i))
    lvlLines.clear()
    lvlLabels.clear()

    if showDay
        drawLevel(pdh, "PDH", dayCol)
        drawLevel(pdl, "PDL", dayCol)
        if showMid
            drawLevel(math.avg(pdh, pdl), "PD 50%", dayCol)
    if showWeek
        drawLevel(pwh, "PWH", weekCol)
        drawLevel(pwl, "PWL", weekCol)
        if showMid
            drawLevel(math.avg(pwh, pwl), "PW 50%", weekCol)
    if showMonth
        drawLevel(pmh, "PMH", monthCol)
        drawLevel(pml, "PML", monthCol)
        if showMid
            drawLevel(math.avg(pmh, pml), "PM 50%", monthCol)
    if showYear
        drawLevel(pyh, "PYH", yearCol)
        drawLevel(pyl, "PYL", yearCol)
        if showMid
            drawLevel(math.avg(pyh, pyl), "PY 50%", yearCol)

// ================== PANEL ==================

if showPanel and barstate.islast
    panelPosTV = switch panelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

    var table panel = table.new(panelPosTV, 3, 5, frame_color = isDark ? #363a45 : #b2b5be, frame_width = 1, border_color = isDark ? #434651 : #c8cbda, border_width = 1)

    table.cell(panel, 0, 0, "EDO PDH/PDL", text_color = textCol, bgcolor = headerBg, text_size = panSizeTxt)
    table.merge_cells(panel, 0, 0, 2, 0)

    table.cell(panel, 0, 1, "D", text_color = showDay ? dayCol : cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 1, showDay ? fmt(pdh) : "—", text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 2, 1, showDay ? fmt(pdl) : "—", text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 2, "W", text_color = showWeek ? weekCol : cellTxt, bgcolor = subBg, text_size = panSizeTxt)
    table.cell(panel, 1, 2, showWeek ? fmt(pwh) : "—", text_color = cellTxt, bgcolor = subBg, text_size = panSizeTxt)
    table.cell(panel, 2, 2, showWeek ? fmt(pwl) : "—", text_color = cellTxt, bgcolor = subBg, text_size = panSizeTxt)

    table.cell(panel, 0, 3, "M", text_color = showMonth ? monthCol : cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 3, showMonth ? fmt(pmh) : "—", text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 2, 3, showMonth ? fmt(pml) : "—", text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 4, "Y", text_color = showYear ? yearCol : cellTxt, bgcolor = subBg, text_size = panSizeTxt)
    table.cell(panel, 1, 4, showYear ? fmt(pyh) : "—", text_color = cellTxt, bgcolor = subBg, text_size = panSizeTxt)
    table.cell(panel, 2, 4, showYear ? fmt(pyl) : "—", text_color = cellTxt, bgcolor = subBg, text_size = panSizeTxt)

// ================== ALERTS ==================

alertcondition(crossPDH, "Cross above PDH", "Edo PDH/PDL — Price crossed above previous day high on {{ticker}}")
alertcondition(crossPDL, "Cross below PDL", "Edo PDH/PDL — Price crossed below previous day low on {{ticker}}")
alertcondition(crossPWH, "Cross above PWH", "Edo PDH/PDL — Price crossed above previous week high on {{ticker}}")
alertcondition(crossPWL, "Cross below PWL", "Edo PDH/PDL — Price crossed below previous week low on {{ticker}}")
````
