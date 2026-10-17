# Edo Equal Highs/Lows

- url: https://www.tradingview.com/script/MEFqsUOH-Edo-Equal-Highs-Lows/
- type: indicator
- pine_id: PUB;8b7b10a3fd3c4eca94a19e07c53d0f53
- version: 1.0

## Description

Edo Equal Highs/Lows — Detects Equal Highs and Equal Lows as Resting Liquidity and Flags When Price Takes It

[image]https://www.tradingview.com/x/hW77k3au/[/image]

[image]https://www.tradingview.com/x/SbypJfTL/[/image]

[image]https://www.tradingview.com/x/Cago0L1M/[/image]



When two swing highs form at the same level, or two swing lows, they create one of the clearest forms of resting liquidity in price action. Traders place their stops just beyond a double top or double bottom, and breakout orders cluster there too — so that matched level becomes a pool of liquidity that price is frequently drawn to take. In the Smart Money Concepts approach these are equal highs (EQH), holding buy-side liquidity above price, and equal lows (EQL), holding sell-side liquidity below it.

Edo Equal Highs/Lows maps these levels automatically and tracks what happens to them. It marks each EQH and EQL when two swings match within an ATR-based tolerance, extends the level as resting liquidity, and flags the exact moment price closes through it and takes that liquidity — all validated on closed bars so the indicator does not repaint. It is the equal-levels specialist of the Edolab structure family, designed to work alongside liquidity sweep and liquidity zone analysis.

EQUAL HIGHS AND EQUAL LOWS

The indicator compares each new swing pivot with the previous one of the same type. When two consecutive swing highs sit at the same price within the tolerance, it draws an Equal Highs (EQH) level — buy-side liquidity resting above. When two swing lows match, it draws an Equal Lows (EQL) level — sell-side liquidity resting below. The level is drawn from the earlier matching pivot and labelled EQH or EQL, extending to the right as a live reference.

THE ATR TOLERANCE

What counts as "equal" is not a single tick but a configurable band. The Equal Tolerance input is expressed as a fraction of ATR (0.10 by default): two swings are treated as equal when their difference is within that fraction of the average true range. A lower value is stricter — only near-perfect matches qualify; a higher value is looser, catching approximate double tops and bottoms. Tying the tolerance to ATR keeps it adaptive across instruments and timeframes, so the same setting behaves consistently whether the chart is a low-volatility index or a fast-moving crypto.

SWING PROFILES

The swings compared for equality come from pivots whose sensitivity is set by the Swing Profile: Scalper (5 bars each side) for short-term levels on low timeframes, Swing (10 bars, the default) for the balanced 4H and daily read, and Long Term (21 bars) for the major levels on weekly and higher horizons.

ACTIVE AND TAKEN

Each equal level lives in one of two states, evaluated on every closed bar. Active: the level is intact, holding its resting liquidity, drawn as a solid coloured line extending to the right — red for EQH, teal for EQL by default. Taken: price has closed through the level and swept the liquidity — the line turns dashed and faded grey and the label gains a ✕. An EQH is taken when price closes above it; an EQL, when price closes below it. Only Active levels count in the panel, since a taken level has already done its job. To keep the chart clean, only the most recent levels per side are kept, up to Max EQ Levels per side (10 by default).

INFORMATION PANEL

The panel condenses the read into a compact table: the number of active EQH and active EQL levels, and the nearest unswept level on each side — the closest Equal Highs above the current price and the closest Equal Lows below it, with their exact prices. Those nearest levels are the most immediate liquidity targets above and below, the quickest way to see where price may be drawn next. The panel sits in any of the four chart corners (Top Right by default), comes in three sizes (Tiny / Small / Normal) and two themes (Dark / Light), and can be hidden entirely.

NO REPAINTING

Equal levels are built on confirmed pivots and their taken state is validated on closed bars, so a level never appears or disappears intrabar. A wick that pierces an equal level but closes back on the same side does not mark it as taken — the indicator waits for the close. There are no higher-timeframe functions: all logic runs on the current chart timeframe.

CONFIGURATION

The inputs are grouped by block. Detection sets the swing profile, the equal tolerance in ATR and the maximum number of levels kept per side. Style exposes the equal highs and equal lows colours, the taken colour, the label size and the Dark/Light theme. Panel controls panel visibility, position and size. The defaults are calibrated to work without adjustment on stocks, crypto, forex, indices and futures, on any timeframe — the inputs most users touch are the Swing Profile and the Equal Tolerance, to set how strict the matching should be.

ALERTS

Four predefined alerts cover the life of an equal level: Equal Highs formed and Equal Lows formed fire when a new EQH or EQL level is drawn; Equal Highs taken and Equal Lows taken fire when price closes through a level and sweeps its liquidity. The formed alerts flag fresh liquidity targets, and the taken alerts fire exactly when that liquidity is swept — often the trigger for a reaction. All alerts fire on bar close, consistent with the indicator's anti-repaint validation.

HOW TO READ IT

Equal highs and lows are liquidity targets, not entries: price is often drawn toward an EQH above or an EQL below to take the stops resting there, so the nearest levels in the panel point to where the move may head next. Watch the take: when price closes through an equal level and it turns Taken, the liquidity has been swept — that sweep frequently precedes a reaction, and classifying it as confirmed or faded turns the event into a fuller read. Trade levels in confluence: an EQL that sits on a demand zone or a higher-timeframe support is a stronger reference than an isolated one. And set inside broader liquidity zones, the equal levels mark precise liquidity pools, completing the liquidity map.

OPEN SOURCE

Edo Equal Highs/Lows is published as a free open source indicator. The full Pine Script is publicly accessible on TradingView for study, adaptation and integration into any workflow. Part of the Edolab Markets free tools ecosystem, with more structure, liquidity and order-flow indicators available on TradingView.

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
indicator("Edo Equal Highs/Lows", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ================== SETTINGS — DETECTION ==================

profile = input.string("Swing", "Swing Profile", options = ["Scalper", "Swing", "Long Term"], group = "Detection", tooltip = "Sensitivity of the swing pivots compared for equality.")
eqTol   = input.float(0.10, "Equal Tolerance (ATR)", minval = 0.0, maxval = 1.0, step = 0.05, group = "Detection", tooltip = "Two swings are 'equal' when their difference is within this fraction of ATR. Lower = stricter.")
maxEq   = input.int(10, "Max EQ Levels per side", minval = 2, maxval = 40, group = "Detection")

swingLen = profile == "Scalper" ? 5 : profile == "Long Term" ? 21 : 10

// ================== SETTINGS — STYLE ==================

highCol   = input.color(#ef5350, "Equal Highs (buy-side)",  inline = "c1", group = "Style", tooltip = "EQH = resting liquidity above price.")
lowCol    = input.color(#26a69a, "Equal Lows (sell-side)",  inline = "c1", group = "Style", tooltip = "EQL = resting liquidity below price.")
takenCol  = input.color(#787b86, "Taken / swept", group = "Style")
labelSize = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal"], group = "Style")
themeMode = input.string("Dark",  "Theme Mode", options = ["Dark", "Light"], group = "Style", tooltip = "Match your TradingView background theme.")

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

// ================== CONTEXT + PIVOTS ==================

atr     = ta.atr(14)
safeAtr = atr != 0 ? atr : syminfo.mintick
tol     = eqTol * safeAtr

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)

var float lastSH    = na
var int   lastSHbar = na
var float lastSL    = na
var int   lastSLbar = na

// ================== EQ STORAGE ==================

var line[]  eqLine   = array.new<line>()
var label[] eqLbl    = array.new<label>()
var bool[]  eqIsHigh = array.new<bool>()
var float[] eqLevel  = array.new<float>()
var int[]   eqState  = array.new<int>()   // 0 active, 1 taken
var int[]   eqStart  = array.new<int>()

newEQH = false
newEQL = false

makeEQ(bool isHigh, float lvl, int xFrom) =>
    col = isHigh ? highCol : lowCol
    ln  = line.new(xFrom, lvl, bar_index, lvl, color = color.new(col, 0), width = 2, style = line.style_solid)
    lb  = label.new(bar_index, lvl, isHigh ? "EQH" : "EQL", style = isHigh ? label.style_label_down : label.style_label_up, color = color.new(col, 80), textcolor = col, size = lblSizeTxt)
    eqLine.push(ln)
    eqLbl.push(lb)
    eqIsHigh.push(isHigh)
    eqLevel.push(lvl)
    eqState.push(0)
    eqStart.push(bar_index)

// new swing high → compare with previous swing high for equality
if not na(ph)
    pivBar = bar_index - swingLen
    if not na(lastSH) and math.abs(ph - lastSH) <= tol
        makeEQ(true, math.max(ph, lastSH), lastSHbar)
        newEQH := true
    lastSH    := ph
    lastSHbar := pivBar

if not na(pl)
    pivBar = bar_index - swingLen
    if not na(lastSL) and math.abs(pl - lastSL) <= tol
        makeEQ(false, math.min(pl, lastSL), lastSLbar)
        newEQL := true
    lastSL    := pl
    lastSLbar := pivBar

// ================== EQ STATE — taken + extend ==================

takenH = false
takenL = false

if eqLine.size() > 0
    for i = eqLine.size() - 1 to 0
        st = eqState.get(i)
        if st == 0
            ln    = eqLine.get(i)
            lb    = eqLbl.get(i)
            isH   = eqIsHigh.get(i)
            lvl   = eqLevel.get(i)
            start = eqStart.get(i)
            if bar_index > start
                taken = isH ? close > lvl : close < lvl
                if taken
                    eqState.set(i, 1)
                    line.set_color(ln, color.new(takenCol, 25))
                    line.set_style(ln, line.style_dashed)
                    line.set_x2(ln, bar_index)
                    label.set_color(lb, color.new(takenCol, 80))
                    label.set_textcolor(lb, takenCol)
                    label.set_text(lb, isH ? "EQH ✕" : "EQL ✕")
                    if isH
                        takenH := true
                    else
                        takenL := true
                else
                    line.set_x2(ln, bar_index)

// ================== TRIM PER SIDE ==================

trimSide(bool sideHigh) =>
    cnt = 0
    if eqLine.size() > 0
        for i = eqLine.size() - 1 to 0
            if eqIsHigh.get(i) == sideHigh
                cnt += 1
                if cnt > maxEq
                    line.delete(eqLine.get(i))
                    label.delete(eqLbl.get(i))
                    eqLine.remove(i)
                    eqLbl.remove(i)
                    eqIsHigh.remove(i)
                    eqLevel.remove(i)
                    eqState.remove(i)
                    eqStart.remove(i)

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

    var table panel = table.new(panelPosTV, 2, 5, frame_color = isDark ? #363a45 : #b2b5be, frame_width = 1, border_color = isDark ? #434651 : #c8cbda, border_width = 1)

    actH = 0
    actL = 0
    nearH = float(na)
    nearL = float(na)
    if eqLine.size() > 0
        for i = 0 to eqLine.size() - 1
            if eqState.get(i) == 0
                isH = eqIsHigh.get(i)
                lvl = eqLevel.get(i)
                if isH
                    actH += 1
                    if lvl > close and (na(nearH) or lvl < nearH)
                        nearH := lvl
                else
                    actL += 1
                    if lvl < close and (na(nearL) or lvl > nearL)
                        nearL := lvl

    nearHtxt = na(nearH) ? "—" : str.tostring(nearH, format.mintick)
    nearLtxt = na(nearL) ? "—" : str.tostring(nearL, format.mintick)

    table.cell(panel, 0, 0, "EDO EQUAL HIGHS/LOWS", text_color = textCol, bgcolor = headerBg, text_size = panSizeTxt)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 1, "EQH active", text_color = color.new(highCol, 0), bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 1, str.tostring(actH), text_color = color.new(highCol, 0), bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 2, "EQL active", text_color = color.new(lowCol, 0), bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 2, str.tostring(actL), text_color = color.new(lowCol, 0), bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 3, "Nearest EQH ↑", text_color = cellTxt, bgcolor = subBg, text_size = panSizeTxt)
    table.cell(panel, 1, 3, nearHtxt, text_color = color.new(highCol, 0), bgcolor = subBg, text_size = panSizeTxt)

    table.cell(panel, 0, 4, "Nearest EQL ↓", text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 4, nearLtxt, text_color = color.new(lowCol, 0), bgcolor = cellBg, text_size = panSizeTxt)

// ================== ALERTS ==================

alertcondition(newEQH, "Equal Highs formed", "Edo Equal Highs/Lows — Equal Highs (buy-side liquidity) formed on {{ticker}}")
alertcondition(newEQL, "Equal Lows formed",  "Edo Equal Highs/Lows — Equal Lows (sell-side liquidity) formed on {{ticker}}")
alertcondition(takenH, "Equal Highs taken",  "Edo Equal Highs/Lows — Equal Highs taken on {{ticker}}")
alertcondition(takenL, "Equal Lows taken",   "Edo Equal Highs/Lows — Equal Lows taken on {{ticker}}")
````
