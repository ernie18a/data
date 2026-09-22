<!-- tradingview-pine-id: PUB;0608132b054f47b09db3d49519921d78 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Edo Breaker Blocks

Source: https://www.tradingview.com/script/aCpYmHkM-Edo-Breaker-Blocks/

## Description

Edo Breaker Blocks — Draws Only the Order Blocks That Fail and Invert Their Role, Then Tracks Each Breaker as Active, Tested or Failed

[image]https://www.tradingview.com/x/Xs8U6qiY/[/image]

[image]https://www.tradingview.com/x/fRqanYil/[/image]

[image]https://www.tradingview.com/x/6mFEqjcm/[/image]

When an important level fails, it does not disappear — it changes sides. A demand order block that is lost stops being support and starts acting as resistance; a supply order block that is taken out stops being a cap and starts acting as support. That inverted level is a breaker block, and it is one of the clearest reaction references in structure analysis: not a theoretical line, but one that has already failed in one direction and reacted in the other.

Edo Breaker Blocks maps them automatically, with one key difference from a plain order-block tool: it does not draw every order block. It keeps each candidate latent until price violates it and reacts from the opposite side; only then is the breaker zone drawn, with the inverted role. From there it tracks the zone's behavior — respected, tested or lost — all validated on closed bars so the indicator does not repaint. Everything it needs comes from the chart's own price action: the candidate zones, the violation that inverts them and the states that follow are all computed inside the indicator.

ORDER BLOCK, BREAK AND BREAKER

An order block is the last opposite candle before an impulse that breaks structure: the last bearish candle before a bullish break marks the demand zone, the last bullish candle before a bearish break marks the supply zone. The indicator stores that candidate but does not draw it. Only when price violates it — closes through it against its original role — is the polarity inversion confirmed and the breaker drawn. A demand order block lost becomes a bearish breaker (resistance); a supply order block taken out becomes a bullish breaker (support).

BULLISH AND BEARISH BREAKERS

A bullish breaker is a former resistance order block that price has taken out; it inverts into support, drawn in teal below price. A bearish breaker is a former support order block that price has lost; it inverts into resistance, drawn in red above price. Each breaker is a box over the range of the candle that originated it, extended to the right and labelled Bull Breaker or Bear Breaker, so the side and role read at a glance.

ACTIVE, TESTED AND FAILED

Each breaker lives in one of three states, evaluated on every closed bar. Active: freshly formed, thin-bordered, extending to the right. Tested: price has returned to the zone and respected it — it enters but closes on the correct side — and the border thickens while the zone stays alive. Failed: price has closed through the zone, which voids it — the box turns dashed and faded and stops extending. A bullish breaker is tested when price drops in and closes above its base, and fails when it closes below; a bearish breaker is tested when price rises in and closes below its top, and fails when it closes above. Only breakers that have not failed count in the panel, and only the most recent per side are kept, up to Max Breakers per side (6 by default).

STRUCTURE PROFILES AND IMPULSE LOOKBACK

The Structure Profile sets the swing sensitivity that defines a break: Scalper (5 bars each side) for short-term breakers on low timeframes, Swing (10 bars, the default) for the balanced 4H and daily read, and Long Term (21 bars) for the major breakers on weekly and higher horizons. The Impulse Lookback (20 by default) controls how many bars back the indicator searches for the candle that originated the impulse — how recent the order block has to be relative to the break.

INFORMATION PANEL

A compact panel under the indicator header shows the number of active bullish breakers (support), active bearish breakers (resistance) and the total of live zones, in the same teal/red color code. The count per side shows where the live references concentrate — more bull breakers mean support stacked below, more bear breakers resistance above. The panel sits in any of the four chart corners (Top Right by default), comes in three sizes (Tiny / Small / Normal) and two themes (Dark / Light), and can be hidden entirely. To keep the calculation light, it is drawn only on the last bar.

NO REPAINTING

Breakers are built on confirmed pivots and their transitions are validated on closed bars, so a zone never appears or disappears intrabar and a wick that pierces a breaker but closes back on the same side does not mark it as tested or failed. There are no higher-timeframe functions: all logic runs on the current chart timeframe. For a multi-timeframe read, apply it on several charts at once.

CONFIGURATION

The inputs are grouped by block. Structure sets the profile, the impulse lookback and the maximum breakers per side. Style exposes the bullish and bearish colors, the zone opacity, the label size and the Dark/Light theme. Panel controls panel visibility, position and size. The defaults are calibrated to work without adjustment on stocks, crypto, forex, indices and futures, on any timeframe — the inputs most users touch are the Structure Profile and the Impulse Lookback.

ALERTS

Four predefined alerts cover the life of a breaker: Bullish Breaker formed and Bearish Breaker formed fire when a new breaker is drawn; Breaker Tested fires when price returns to a zone and respects it; Breaker Failed fires when price closes through a zone and voids it. All alerts fire on bar close, consistent with the indicator's anti-repaint validation.

HOW TO READ IT

Use a breaker as a reaction zone: a bullish breaker below price is a probable support, a bearish breaker above a probable resistance, stronger than a plain level because it has already proven its inverted role. Watch the test — when price returns and respects the zone, the reaction confirms it is still alive, and a tested breaker that holds is a more solid reference than a freshly formed one. Read the failure too — a breaker closed through has lost its relevance, and recognizing it in time avoids leaning on a zone that no longer defends anything. Trade breakers in confluence with the broader structure, and combine them with order-block mapping, which marks the active blocks before they fail, and with a broader market-structure read that places everything in context.

OPEN SOURCE

Edo Breaker Blocks is published as a free open source indicator. The full Pine Script is publicly accessible on TradingView for study, adaptation and integration into any workflow. Part of the Edolab Markets free tools ecosystem available on TradingView.

This indicator is a technical analysis tool for educational and informational purposes only. It does not generate automatic buy or sell signals and should not be considered financial advice. Trading financial markets involves significant risk of capital loss. Past performance does not guarantee future results. Always use proper risk management.

---

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
indicator("Edo Breaker Blocks", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// ================== SETTINGS — STRUCTURE ==================

profile = input.string("Swing", "Structure Profile", options = ["Scalper", "Swing", "Long Term"], group = "Structure", tooltip = "Scalper: fast swings (intraday)\nSwing: balanced (4H / D)\nLong Term: major swings only (W)")
obScan  = input.int(20, "Impulse Lookback", minval = 3, maxval = 60, group = "Structure", tooltip = "Bars to search back for the candle that originated the break.")
maxBr   = input.int(6,  "Max Breakers per side", minval = 1, maxval = 20, group = "Structure")

swingLen = profile == "Scalper" ? 5 : profile == "Long Term" ? 21 : 10

// ================== SETTINGS — STYLE ==================

bullCol     = input.color(#26a69a, "Bullish Breaker (support)", group = "Style")
bearCol     = input.color(#ef5350, "Bearish Breaker (resistance)", group = "Style")
zoneOpacity = input.int(80, "Zone Opacity %", minval = 0, maxval = 95, step = 5, group = "Style")
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

// ================== ORDER-BLOCK CANDIDATES (latent, not drawn) ==================
// A candidate is the last opposite candle before an impulse break. It only becomes a
// visible Breaker if price later violates it and re-acts on the opposite side.

var float[] cTop  = array.new<float>()
var float[] cBtm  = array.new<float>()
var bool[]  cBull = array.new<bool>()   // true = bullish-origin OB (support), false = resistance
var int[]   cBar  = array.new<int>()

makeCandidate(bool originBull) =>
    idx = -1
    maxScan = math.min(obScan, bar_index - 1)
    if maxScan >= 1
        for j = 1 to maxScan
            isBearCandle = close[j] < open[j]
            isBullCandle = close[j] > open[j]
            if originBull and isBearCandle
                idx := j
                break
            if not originBull and isBullCandle
                idx := j
                break
    if idx >= 0
        cTop.push(high[idx])
        cBtm.push(low[idx])
        cBull.push(originBull)
        cBar.push(bar_index - idx)

if bullBreak
    makeCandidate(true)
if bearBreak
    makeCandidate(false)

// trim candidates (keep recent)
if cTop.size() > 40
    cTop.shift()
    cBtm.shift()
    cBull.shift()
    cBar.shift()

// ================== BREAKER STORE ==================

var box[]   brBox   = array.new<box>()
var label[] brLbl   = array.new<label>()
var bool[]  brIsBull = array.new<bool>()   // true = bullish breaker (support)
var float[] brTop   = array.new<float>()
var float[] brBtm   = array.new<float>()
var int[]   brState = array.new<int>()     // 0 active, 1 tested, 2 failed
var int[]   brBar   = array.new<int>()

bullBreakerFormed = false
bearBreakerFormed = false

spawnBreaker(bool isBull, float t, float b, int startBar) =>
    col = isBull ? bullCol : bearCol
    bx  = box.new(startBar, t, bar_index + 10, b, border_color = color.new(col, 30), bgcolor = color.new(col, zoneOpacity), border_width = 1)
    lb  = label.new(bar_index, isBull ? b : t, isBull ? "Bull Breaker" : "Bear Breaker", style = isBull ? label.style_label_up : label.style_label_down, color = color.new(col, 85), textcolor = col, size = lblSizeTxt)
    brBox.push(bx)
    brLbl.push(lb)
    brIsBull.push(isBull)
    brTop.push(t)
    brBtm.push(b)
    brState.push(0)
    brBar.push(bar_index)

// ================== CANDIDATE -> BREAKER TRANSITION ==================
// Support OB violated to the downside flips into a bearish breaker (resistance), and vice versa.

if cTop.size() > 0 and barstate.isconfirmed
    for i = cTop.size() - 1 to 0
        t   = cTop.get(i)
        b   = cBtm.get(i)
        isB = cBull.get(i)
        if isB and close < b
            spawnBreaker(false, t, b, cBar.get(i))
            bearBreakerFormed := true
            cTop.remove(i)
            cBtm.remove(i)
            cBull.remove(i)
            cBar.remove(i)
        else if not isB and close > t
            spawnBreaker(true, t, b, cBar.get(i))
            bullBreakerFormed := true
            cTop.remove(i)
            cBtm.remove(i)
            cBull.remove(i)
            cBar.remove(i)

// ================== BREAKER STATE — test / fail / extend ==================

breakerTested = false
breakerFailed = false

if brBox.size() > 0
    for i = brBox.size() - 1 to 0
        st  = brState.get(i)
        isB = brIsBull.get(i)
        t   = brTop.get(i)
        b   = brBtm.get(i)
        bx  = brBox.get(i)
        if st != 2
            box.set_right(bx, bar_index + 10)
            if bar_index > brBar.get(i) and barstate.isconfirmed
                if isB
                    // bullish breaker = support zone [b, t]
                    if close < b
                        brState.set(i, 2)
                        box.set_bgcolor(bx, color.new(bullCol, math.min(zoneOpacity + 12, 95)))
                        box.set_border_style(bx, line.style_dashed)
                        box.set_right(bx, bar_index)
                        breakerFailed := true
                    else if st == 0 and low <= t and close >= b
                        brState.set(i, 1)
                        box.set_border_width(bx, 2)
                        breakerTested := true
                else
                    // bearish breaker = resistance zone [b, t]
                    if close > t
                        brState.set(i, 2)
                        box.set_bgcolor(bx, color.new(bearCol, math.min(zoneOpacity + 12, 95)))
                        box.set_border_style(bx, line.style_dashed)
                        box.set_right(bx, bar_index)
                        breakerFailed := true
                    else if st == 0 and high >= b and close <= t
                        brState.set(i, 1)
                        box.set_border_width(bx, 2)
                        breakerTested := true

// ================== TRIM BREAKERS PER SIDE ==================

trimSide(bool sideBull) =>
    cnt = 0
    if brBox.size() > 0
        for i = brBox.size() - 1 to 0
            if brIsBull.get(i) == sideBull
                cnt += 1
                if cnt > maxBr
                    box.delete(brBox.get(i))
                    label.delete(brLbl.get(i))
                    brBox.remove(i)
                    brLbl.remove(i)
                    brIsBull.remove(i)
                    brTop.remove(i)
                    brBtm.remove(i)
                    brState.remove(i)
                    brBar.remove(i)

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

    activeBull = 0
    activeBear = 0
    if brBox.size() > 0
        for i = 0 to brBox.size() - 1
            if brState.get(i) != 2
                if brIsBull.get(i)
                    activeBull += 1
                else
                    activeBear += 1

    table.cell(panel, 0, 0, "EDO BREAKER BLOCKS", text_color = textCol, bgcolor = headerBg, text_size = panSizeTxt)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 1, "Bull Breakers", text_color = color.new(bullCol, 0), bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 1, str.tostring(activeBull), text_color = color.new(bullCol, 0), bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 2, "Bear Breakers", text_color = color.new(bearCol, 0), bgcolor = subBg, text_size = panSizeTxt)
    table.cell(panel, 1, 2, str.tostring(activeBear), text_color = color.new(bearCol, 0), bgcolor = subBg, text_size = panSizeTxt)

    table.cell(panel, 0, 3, "Active total", text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 3, str.tostring(activeBull + activeBear), text_color = textCol, bgcolor = cellBg, text_size = panSizeTxt)

// ================== ALERTS ==================

alertcondition(bullBreakerFormed, "Bullish Breaker formed", "Edo Breaker Blocks — Bullish breaker formed on {{ticker}}")
alertcondition(bearBreakerFormed, "Bearish Breaker formed", "Edo Breaker Blocks — Bearish breaker formed on {{ticker}}")
alertcondition(breakerTested,     "Breaker Tested",         "Edo Breaker Blocks — A breaker was tested on {{ticker}}")
alertcondition(breakerFailed,     "Breaker Failed",         "Edo Breaker Blocks — A breaker failed on {{ticker}}")
````
