# Edo Order Blocks

- url: https://www.tradingview.com/script/31JcBzct-Edo-Order-Blocks/
- type: indicator
- pine_id: PUB;c0fa4d7f52e240a39ceb9388bff9410f
- version: 1.0

## Description

Edo Order Blocks — Displacement-Detected Order Blocks Scored 0-100, with Active / Tested / Mitigated States and a Strongest-Block Panel

[image]https://www.tradingview.com/x/ISKrOPgq/[/image]

[image]https://www.tradingview.com/x/WWUz7Kjt/[/image]

[image]https://www.tradingview.com/x/p6BA2e3R/[/image]


An order block is the last opposite candle before an impulse that breaks away from a level — the last bearish candle before a sharp move up, or the last bullish candle before a sharp move down. In the Smart Money Concepts approach, that candle marks a zone where institutional activity was left unfilled, so when price returns to it, it becomes a natural reference of supply or demand. The problem with most order block tools is that they draw every zone, cluttering the chart with references that never mattered. Edo Order Blocks takes the opposite approach: it scores each zone and draws only the ones that earn it.

Edo Order Blocks detects order blocks by displacement, scores each one from 0 to 100 on objective quality factors, filters out the weak ones, and tracks every surviving zone through its full life — from Active to Tested to Mitigated. Everything is validated on closed bars, so the indicator does not repaint. It is the order-block specialist of the Edolab structure family, designed to pair with Edo Smart Money Map, which maps the BOS / CHoCH structure around these zones.

DISPLACEMENT DETECTION

A new order block is triggered by a displacement: a confirmed candle that closes beyond the highest high (bullish) or lowest low (bearish) of the last N bars, in the direction of its own body. The Displacement Lookback input (10 by default) sets how many bars define that range. This impulse-based trigger captures the moment price breaks away with conviction, which is precisely when an order block is left behind. From the impulse, the indicator looks back up to the Origin Lookback (15 by default) to find the last opposite candle — the origin of the move — and draws the zone between its high and low.

THE QUALITY SCORE

Every candidate order block is scored from 0 to 100 before it is drawn, combining four objective factors: body strength (the candle's body relative to ATR), volume strength (volume relative to its 20-period average), displacement strength (how far the close pushed beyond the range, in ATR units), and trend alignment (whether the block sits on the right side of the EMA 50). Body and volume weigh 30% each, displacement and trend alignment 20% each. The Minimum Score input (40 by default) acts as a filter: only blocks that score at or above it ever reach the chart. Raise it to keep only the highest-conviction zones; lower it to see more. The score is printed on each block's label, so its quality is visible at a glance.

ORDER BLOCKS AND THEIR LIFE

Each drawn zone is a box between the high and low of the origin candle, labelled Bull OB or Bear OB with its score, extended to the right as a live reference. To keep the chart clean, only the most recent blocks per side are kept, up to Max Order Blocks per side (8 by default); older ones are removed as new ones appear.

THREE STATES: ACTIVE, TESTED, MITIGATED

Unlike a simple active/used flag, Edo Order Blocks tracks three states, evaluated on every closed bar. Active: a fresh zone price has not touched since creation — a solid box extending to the right. Tested: price has tapped the zone but not closed through it — the border turns solid and bold, marking that the zone has been challenged and held. Mitigated: price has closed through the zone — the box turns dashed, fades and stops extending, recording that the zone has been consumed. The Touch Mode input decides what counts as a test: Wick (default) marks it as soon as a wick reaches the zone, while Close requires a candle to close inside it. A bullish block is mitigated when price closes below its base; a bearish block, when price closes above its top. Each transition fires its own alert.

INFORMATION PANEL

The panel condenses the read into a compact table. It shows the number of active order blocks on each side, the Strongest OB — the highest-scoring active block, with its side, score and price level — and the active Minimum Score filter. The Strongest OB row is the quickest way to find the single zone the indicator rates highest right now. The panel sits in any of the four chart corners (Top Right by default), comes in three sizes (Tiny / Small / Normal) and two themes (Dark / Light), and can be hidden entirely.

NO REPAINTING

Displacement is validated on closed bars only, using the highest/lowest of completed candles offset by one bar, so a zone never appears or disappears intrabar. A wick that pierces a level but closes back inside generates nothing — the indicator waits for the close. This removes the false zones that clutter tools which react instantly, at the cost of confirming each block once the impulse has completed. There are no higher-timeframe functions: all logic runs on the current chart timeframe.

CONFIGURATION

The inputs are grouped by block. Detection sets the displacement lookback, the origin lookback and the minimum score. Order Blocks sets the maximum per side and the touch mode (Wick / Close). Style exposes the bull and bear colours, the zone opacity, whether the score is shown on the label, the label size and the Dark/Light theme. Panel controls panel visibility, position and size. The defaults are calibrated to work without adjustment on stocks, crypto, forex, indices and futures, on any timeframe — the only input most users tune is the Minimum Score, to make the indicator more or less selective.

ALERTS

Six predefined alerts cover the full life of a zone: New Bull OB and New Bear OB fire when a fresh order block above the score threshold is created; Bull OB Tested and Bear OB Tested fire when price first taps a zone; and Bull OB Mitigated and Bear OB Mitigated fire when price closes through a zone and consumes it. The new-block alerts flag fresh references, the tested alerts fire exactly when a zone is challenged, and the mitigation alerts mark when a reference is spent. All alerts fire on bar close, consistent with the indicator's anti-repaint validation.

HOW TO READ IT

A clean reading uses the score and the states together. High-score zones are the references worth watching: a Bull OB scored 80 sits on a strong-bodied, high-volume, trend-aligned impulse, a far more reliable demand zone than one scored 45. Watch the Active-to-Tested transition: when price returns to an active block and taps it, the zone is being challenged — the bold border marks the moment of reaction. A Tested block that holds and sends price away keeps its relevance; a Mitigated one has been consumed and steps aside. The Strongest OB panel row points to the single best active zone at any time, and pairing Edo Order Blocks with Edo Smart Money Map places these scored zones inside the broader BOS / CHoCH structure for full context.

OPEN SOURCE

Edo Order Blocks is published as a free open source indicator. The full Pine Script is publicly accessible on TradingView for study, adaptation and integration into any workflow. Part of the Edolab Markets free tools ecosystem alongside Edo Smart Money Map, Edo Liquidity Zones, Edo ZigZag Auto Fib SR, Edo Multi Stoch and more available on TradingView.

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
indicator("Edo Order Blocks", overlay = true, max_boxes_count = 500, max_labels_count = 500)

// ================== SETTINGS — DETECTION ==================

dispLen  = input.int(10, "Displacement Lookback", minval = 3, maxval = 50, group = "Detection", tooltip = "An order block is created when price closes beyond the highest/lowest of the last N bars (impulse/displacement).")
obScan   = input.int(15, "Origin Lookback",       minval = 2, maxval = 60, group = "Detection", tooltip = "Bars to search back for the last opposite candle that originated the impulse.")
minScore = input.int(40, "Minimum Score",         minval = 0, maxval = 100, step = 5, group = "Detection", tooltip = "Only draw order blocks with a quality score >= this value.")

// ================== SETTINGS — ORDER BLOCKS ==================

maxOB   = input.int(8,       "Max Order Blocks per side", minval = 1, maxval = 30, group = "Order Blocks")
obMitig = input.string("Wick", "Touch Mode", options = ["Wick", "Close"], group = "Order Blocks", tooltip = "Wick: a wick tapping the zone marks it Tested.\nClose: requires a close inside the zone.")

// ================== SETTINGS — STYLE ==================

obBullCol   = input.color(#26a69a, "Bull OB", inline = "c1", group = "Style")
obBearCol   = input.color(#ef5350, "Bear OB", inline = "c1", group = "Style")
zoneOpacity = input.int(80, "OB Opacity %", minval = 0, maxval = 95, step = 5, group = "Style")
showScore   = input.bool(true, "Show score on label", group = "Style")
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

// ================== CONTEXT ==================

atr    = ta.atr(14)
avgVol = ta.sma(volume, 20)
ema50  = ta.ema(close, 50)

safeAtr = atr != 0 ? atr : syminfo.mintick
safeVol = avgVol != 0 ? avgVol : 1.0

// ================== DISPLACEMENT (confirmed bars only) ==================

hiPrev = ta.highest(high, dispLen)[1]
loPrev = ta.lowest(low,  dispLen)[1]

bullDisp = barstate.isconfirmed and not na(hiPrev) and close > hiPrev and close > open
bearDisp = barstate.isconfirmed and not na(loPrev) and close < loPrev and close < open

// ================== SCORE ==================

obScore(bool isBull) =>
    bodyStr  = math.min(math.abs(close - open) / safeAtr, 3.0) / 3.0
    volStr   = math.min(volume / safeVol, 3.0) / 3.0
    dispRaw  = isBull ? (close - hiPrev) / safeAtr : (loPrev - close) / safeAtr
    dispStr  = math.min(math.max(dispRaw, 0.0), 3.0) / 3.0
    trendAl  = isBull ? (close > ema50 ? 1.0 : 0.0) : (close < ema50 ? 1.0 : 0.0)
    math.round((0.30 * bodyStr + 0.30 * volStr + 0.20 * dispStr + 0.20 * trendAl) * 100)

// ================== ORDER BLOCK STORAGE ==================

var box[]   obBox    = array.new<box>()
var label[] obLbl    = array.new<label>()
var bool[]  obIsBull = array.new<bool>()
var float[] obTop    = array.new<float>()
var float[] obBtm    = array.new<float>()
var int[]   obState  = array.new<int>()   // 0 active, 1 tested, 2 mitigated
var int[]   obScoreA = array.new<int>()
var int[]   obStart  = array.new<int>()

newBullOB = false
newBearOB = false

makeOB(bool isBull) =>
    sc = obScore(isBull)
    if sc >= minScore
        idx = -1
        maxS = math.min(obScan, bar_index - 1)
        if maxS >= 1
            for j = 1 to maxS
                if isBull and close[j] < open[j]
                    idx := j
                    break
                if not isBull and close[j] > open[j]
                    idx := j
                    break
        if idx >= 0
            t   = high[idx]
            b   = low[idx]
            col = isBull ? obBullCol : obBearCol
            txt = (isBull ? "Bull OB" : "Bear OB") + (showScore ? " " + str.tostring(sc) : "")
            bx  = box.new(bar_index - idx, t, bar_index + 10, b, border_color = color.new(col, 35), bgcolor = color.new(col, zoneOpacity), border_width = 1)
            lb  = label.new(bar_index - idx, isBull ? b : t, txt, style = isBull ? label.style_label_up : label.style_label_down, color = color.new(col, 80), textcolor = col, size = lblSizeTxt)
            obBox.push(bx)
            obLbl.push(lb)
            obIsBull.push(isBull)
            obTop.push(t)
            obBtm.push(b)
            obState.push(0)
            obScoreA.push(sc)
            obStart.push(bar_index)
            true
        else
            false
    else
        false

if bullDisp
    if makeOB(true)
        newBullOB := true
if bearDisp
    if makeOB(false)
        newBearOB := true

// ================== STATE UPDATE — tested / mitigated + extend ==================

bullTested = false
bearTested = false
bullMitig  = false
bearMitig  = false

if obBox.size() > 0
    for i = obBox.size() - 1 to 0
        bx = obBox.get(i)
        if not na(bx)
            st     = obState.get(i)
            isB    = obIsBull.get(i)
            t      = obTop.get(i)
            b      = obBtm.get(i)
            startB = obStart.get(i)
            col    = isB ? obBullCol : obBearCol
            if st < 2 and bar_index > startB
                mitig = isB ? close < b : close > t
                tap   = isB ? (obMitig == "Close" ? close <= t : low <= t) : (obMitig == "Close" ? close >= b : high >= b)
                if mitig
                    obState.set(i, 2)
                    box.set_bgcolor(bx, color.new(col, math.min(zoneOpacity + 12, 95)))
                    box.set_border_style(bx, line.style_dashed)
                    box.set_right(bx, bar_index)
                    if isB
                        bullMitig := true
                    else
                        bearMitig := true
                else
                    box.set_right(bx, bar_index + 10)
                    if st == 0 and tap
                        obState.set(i, 1)
                        box.set_border_color(bx, color.new(col, 0))
                        box.set_border_width(bx, 2)
                        if isB
                            bullTested := true
                        else
                            bearTested := true

// ================== TRIM PER SIDE ==================

trimSide(bool sideBull) =>
    cnt = 0
    if obBox.size() > 0
        for i = obBox.size() - 1 to 0
            if obIsBull.get(i) == sideBull
                cnt += 1
                if cnt > maxOB
                    box.delete(obBox.get(i))
                    label.delete(obLbl.get(i))
                    obBox.remove(i)
                    obLbl.remove(i)
                    obIsBull.remove(i)
                    obTop.remove(i)
                    obBtm.remove(i)
                    obState.remove(i)
                    obScoreA.remove(i)
                    obStart.remove(i)

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

    activeBull = 0
    activeBear = 0
    bestScore  = 0
    bestIsBull = true
    bestPrice  = float(na)
    if obBox.size() > 0
        for i = 0 to obBox.size() - 1
            if obState.get(i) < 2
                isB = obIsBull.get(i)
                if isB
                    activeBull += 1
                else
                    activeBear += 1
                sc = obScoreA.get(i)
                if sc > bestScore
                    bestScore  := sc
                    bestIsBull := isB
                    bestPrice  := isB ? obTop.get(i) : obBtm.get(i)

    bestTxt = bestScore > 0 ? (bestIsBull ? "Bull " : "Bear ") + str.tostring(bestScore) + " @ " + str.tostring(bestPrice, format.mintick) : "—"
    bestCol = bestScore == 0 ? cellTxt : bestIsBull ? obBullCol : obBearCol

    table.cell(panel, 0, 0, "EDO ORDER BLOCKS", text_color = textCol, bgcolor = headerBg, text_size = panSizeTxt)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 1, "Bull OB (active)", text_color = color.new(obBullCol, 0), bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 1, str.tostring(activeBull), text_color = color.new(obBullCol, 0), bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 2, "Bear OB (active)", text_color = color.new(obBearCol, 0), bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 2, str.tostring(activeBear), text_color = color.new(obBearCol, 0), bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 3, "Strongest OB", text_color = cellTxt, bgcolor = subBg, text_size = panSizeTxt)
    table.cell(panel, 1, 3, bestTxt, text_color = bestCol, bgcolor = subBg, text_size = panSizeTxt)

    table.cell(panel, 0, 4, "Min Score", text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 4, str.tostring(minScore), text_color = textCol, bgcolor = cellBg, text_size = panSizeTxt)

// ================== ALERTS ==================

alertcondition(newBullOB,  "New Bull OB",        "Edo Order Blocks — New bullish order block on {{ticker}}")
alertcondition(newBearOB,  "New Bear OB",        "Edo Order Blocks — New bearish order block on {{ticker}}")
alertcondition(bullTested, "Bull OB Tested",     "Edo Order Blocks — Bullish order block tested on {{ticker}}")
alertcondition(bearTested, "Bear OB Tested",     "Edo Order Blocks — Bearish order block tested on {{ticker}}")
alertcondition(bullMitig,  "Bull OB Mitigated",  "Edo Order Blocks — Bullish order block mitigated on {{ticker}}")
alertcondition(bearMitig,  "Bear OB Mitigated",  "Edo Order Blocks — Bearish order block mitigated on {{ticker}}")
````
