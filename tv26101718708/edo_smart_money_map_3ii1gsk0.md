# Edo Smart Money Map

- url: https://www.tradingview.com/script/3Ii1GSk0-Edo-Smart-Money-Map/
- type: indicator
- pine_id: PUB;e7856cbdc1c84202ba2813c9a323ec67
- version: 1.0

## Description

Edo Smart Money Map — Market Structure Mapping with BOS / CHoCH Classification, Order Blocks and a Structural Bias Panel

[image]https://www.tradingview.com/x/ptCZf9RE/[/image]

[image]https://www.tradingview.com/x/bPpH1bUP/[/image]


Price does not move at random. It leaves behind a sequence of highs and lows that tells you who is in control: while it prints higher highs and higher lows the structure is bullish, and when that sequence breaks the other way, something has changed. That is the core idea of the Smart Money Concepts approach, and it is exactly what Edo Smart Money Map maps automatically — without oscillators, without moving averages, reading nothing but the structure of the price itself.

The indicator does not flood the chart with signals. It answers three concrete questions and leaves the rest to the trader: where does structure break, was that break a continuation or a reversal, and which origin zones — order blocks — are still alive as references of supply and demand. Everything is condensed into clean marks on price and a four-line panel.

MARKET STRUCTURE: SWINGS AND PROFILES

Everything starts with the swings — the relevant highs and lows whose break defines the structure. A swing high is confirmed when a candle has the highest high of its surroundings; a swing low, the lowest low. The size of that surrounding window is set by the Structure Profile: Scalper (5 bars each side) detects fast swings for intraday work, Swing (10 bars, the default) is the balanced setting for 4H and daily, and Long Term (21 bars) marks only the major swings for weekly and higher horizons. An optional layer labels each confirmed swing as HH, HL, LH or LL directly on price; it is off by default to keep the chart clean.

BOS — BREAK OF STRUCTURE (CONTINUATION)

A BOS confirms that the prevailing trend continues. It fires when the close pushes beyond the last relevant swing in the direction of the structural bias: in a bullish structure, the close clears the last relevant high; in a bearish one, it loses the last relevant low. The indicator draws a horizontal line at the broken level and a BOS label in the bullish or bearish colour, and keeps the panel bias unchanged — a BOS reaffirms the control of whoever already held it.

CHoCH — CHANGE OF CHARACTER (REVERSAL)

A CHoCH is the first sign that control may be changing hands. It fires when price breaks structure against the prevailing bias: in a bullish structure, the close loses the last relevant low; in a bearish one, it reclaims the last relevant high. The distinction from a BOS is purely contextual — the same level break is a BOS if it goes with the previous bias and a CHoCH if it goes against it — so the indicator keeps the structural direction in memory and decides the label on each break. After a CHoCH the panel bias flips. It is not an entry by itself, but the cue to reassess the bias and watch the order block the impulse leaves behind.

ORDER BLOCKS AND THEIR STATE

Every confirmed structure break triggers the search for the order block that originated it: the last opposite candle before the impulse that broke the level — the last bearish candle before an up move, or the last bullish candle before a down move. The indicator looks back a configurable number of bars (Impulse Lookback, 20 by default), draws a box between that candle's high and low with a Bull OB or Bear OB label, and extends it to the right while it stays alive. To avoid clutter, only the most recent order blocks per side are kept, up to Max Order Blocks (8 by default).

Each order block lives in one of two states, evaluated on every closed bar. Active: an intact zone price has not touched since it was created — a solid box extending to the right. Mitigated: a zone price has reached — its border turns dashed, its shading fades and it stops extending. The Mitigation input decides when a zone counts as touched: Wick (default) marks it as soon as a wick reaches the zone, while Close requires a candle to close inside it. A Bull OB is evaluated by its upper edge, a Bear OB by its lower edge, and the moment of mitigation fires the corresponding alert. Only Active order blocks are counted in the panel.

INFORMATION PANEL

The panel condenses the structural state into four readings under a header. Structure shows the prevailing bias — ▲ BULLISH, ▼ BEARISH or • NEUTRAL — in its colour. Last Event shows the latest confirmed event — Bull or Bear, BOS or CHoCH. Bull OB (active) and Bear OB (active) count the order blocks still alive on each side. The panel sits in any of the four chart corners (Top Right by default), comes in three sizes (Tiny / Small / Normal) and two themes (Dark / Light), and can be hidden entirely.

NO REPAINTING

Every structure break is validated on closed bars only. A wick that pierces a level intrabar but closes back inside generates nothing — the indicator waits for the close. This removes the false breaks that clutter tools which mark instantly, at the cost of confirming events once the move has already happened. There are no higher-timeframe functions: all logic runs on the current chart timeframe, which keeps it light and repaint-free.

CONFIGURATION

The inputs are grouped by block. Structure sets the profile and toggles BOS, CHoCH and the HH/HL/LH/LL swing labels. Order Blocks toggles the zones, sets the maximum per side, the mitigation mode (Wick / Close) and the impulse lookback. Style exposes the bullish and bearish colours, the order block colours, the zone opacity, the label size and the Dark/Light theme. Panel controls panel visibility, position and size. The defaults are calibrated to work without adjustment on stocks, crypto, forex, indices and futures, on any timeframe — the Swing profile on 4H and daily is the most common starting point.

ALERTS

Six predefined alerts cover every meaningful event: Bullish BOS and Bearish BOS confirm trend continuation up or down; Bullish CHoCH and Bearish CHoCH flag a possible change of character; and Bull OB Mitigated and Bear OB Mitigated fire when price returns to an origin zone of demand or supply. The CHoCH alerts are the most useful for catching potential reversals, the BOS alerts confirm a trend is still alive, and the mitigation alerts fire exactly when a reference zone is being tested. All alerts fire on bar close, consistent with the indicator's anti-repaint validation.

HOW TO READ IT

A clean reading chains the layers into common patterns. Healthy trend: while the panel holds its bias and successive events are BOS in the same direction, the structure is sound and each break leaves a fresh order block to watch on the next pullback. Reversal warning: a CHoCH after a run of BOS is the first cue that control may be shifting — not an entry, but the moment to lower conviction in the prior direction and watch the order block the change leaves behind. Pullback into an active order block: after a BOS price often retraces into an active zone of the correct side, where the Active-to-Mitigated transition marks the exact moment price enters the reference. Confluence: an order block that overlaps a prior liquidity zone, a key level or a higher-timeframe support gains weight over an isolated one.

OPEN SOURCE

Edo Smart Money Map is published as a free open source indicator. The full Pine Script is publicly accessible on TradingView for study, adaptation and integration into any workflow. Part of the Edolab Markets free tools ecosystem alongside Edo Liquidity Zones, Edo ZigZag Auto Fib SR, Edo EMA Core Cross, Edo Multi Stoch and more available on TradingView.

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
indicator("Edo Smart Money Map", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// ================== SETTINGS — STRUCTURE ==================

profile    = input.string("Swing", "Structure Profile", options = ["Scalper", "Swing", "Long Term"], group = "Structure", tooltip = "Scalper: fast swings (intraday)\nSwing: balanced (4H / D)\nLong Term: major swings only (W)")
showBOS    = input.bool(true,  "Show BOS (continuation)",          group = "Structure")
showCHoCH  = input.bool(true,  "Show CHoCH (reversal)",            group = "Structure")
showSwings = input.bool(false, "Show swing points (HH/HL/LH/LL)",  group = "Structure")

swingLen   = profile == "Scalper" ? 5 : profile == "Long Term" ? 21 : 10

// ================== SETTINGS — ORDER BLOCKS ==================

showOB  = input.bool(true,   "Show Order Blocks",  group = "Order Blocks")
maxOB   = input.int(8,       "Max Order Blocks",   minval = 1, maxval = 30, group = "Order Blocks", tooltip = "Keep the most recent N order blocks per side.")
obMitig = input.string("Wick", "Mitigation",       options = ["Wick", "Close"], group = "Order Blocks", tooltip = "Wick: zone mitigated when a wick taps it.\nClose: requires a candle close inside the zone.")
obScan  = input.int(20,      "Impulse Lookback",   minval = 3, maxval = 60, group = "Order Blocks", tooltip = "Bars to search back for the candle that originated the break.")

// ================== SETTINGS — STYLE ==================

bullCol     = input.color(#26a69a, "Bullish", inline = "c1", group = "Style")
bearCol     = input.color(#ef5350, "Bearish", inline = "c1", group = "Style")
obBullCol   = input.color(#26a69a, "Bull OB", inline = "c2", group = "Style")
obBearCol   = input.color(#ef5350, "Bear OB", inline = "c2", group = "Style")
zoneOpacity = input.int(80, "OB Opacity %", minval = 0, maxval = 95, step = 5, group = "Style")
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

// ================== SWING DETECTION ==================

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)

var float upperLevel  = na   // last confirmed swing high (resistance to break)
var int   upperBar    = na
var float lowerLevel  = na   // last confirmed swing low  (support to break)
var int   lowerBar    = na
var bool  upperBroken = false
var bool  lowerBroken = false
var float prevHigh    = na
var float prevLow     = na

if not na(ph)
    upperLevel  := ph
    upperBar    := bar_index - swingLen
    upperBroken := false
    if showSwings
        pType = na(prevHigh) or ph > prevHigh ? "HH" : "LH"
        label.new(bar_index - swingLen, ph, pType, style = label.style_label_down, color = color.new(bullCol, 80), textcolor = bullCol, size = size.tiny)
    prevHigh := ph

if not na(pl)
    lowerLevel  := pl
    lowerBar    := bar_index - swingLen
    lowerBroken := false
    if showSwings
        pType = na(prevLow) or pl < prevLow ? "LL" : "HL"
        label.new(bar_index - swingLen, pl, pType, style = label.style_label_up, color = color.new(bearCol, 80), textcolor = bearCol, size = size.tiny)
    prevLow := pl

// ================== MARKET STRUCTURE — BOS / CHoCH ==================
// Breaks are validated only on confirmed (closed) bars to avoid repainting.

var int    trend        = 0       // 1 = bullish structure, -1 = bearish structure
var string lastEvent    = "—"
var color  lastEventCol = na

bullBreak = barstate.isconfirmed and not na(upperLevel) and not upperBroken and close > upperLevel
bearBreak = barstate.isconfirmed and not na(lowerLevel) and not lowerBroken and close < lowerLevel

bullBOS   = false
bearBOS   = false
bullCHoCH = false
bearCHoCH = false

if bullBreak
    isChoch    = trend < 0
    bullCHoCH := isChoch
    bullBOS   := not isChoch
    if (isChoch and showCHoCH) or (not isChoch and showBOS)
        line.new(upperBar, upperLevel, bar_index, upperLevel, color = color.new(bullCol, 0), width = 1, style = line.style_solid)
        label.new(int(math.avg(upperBar, bar_index)), upperLevel, isChoch ? "CHoCH" : "BOS", style = label.style_label_down, color = color.new(bullCol, 75), textcolor = bullCol, size = lblSizeTxt)
    lastEvent    := isChoch ? "Bull CHoCH" : "Bull BOS"
    lastEventCol := bullCol
    trend        := 1
    upperBroken  := true

if bearBreak
    isChoch    = trend > 0
    bearCHoCH := isChoch
    bearBOS   := not isChoch
    if (isChoch and showCHoCH) or (not isChoch and showBOS)
        line.new(lowerBar, lowerLevel, bar_index, lowerLevel, color = color.new(bearCol, 0), width = 1, style = line.style_solid)
        label.new(int(math.avg(lowerBar, bar_index)), lowerLevel, isChoch ? "CHoCH" : "BOS", style = label.style_label_up, color = color.new(bearCol, 75), textcolor = bearCol, size = lblSizeTxt)
    lastEvent    := isChoch ? "Bear CHoCH" : "Bear BOS"
    lastEventCol := bearCol
    trend        := -1
    lowerBroken  := true

// ================== ORDER BLOCKS ==================

var box[]   obBox    = array.new<box>()
var label[] obLbl    = array.new<label>()
var bool[]  obIsBull = array.new<bool>()
var float[] obTop    = array.new<float>()
var float[] obBtm    = array.new<float>()
var int[]   obState  = array.new<int>()   // 0 = active, 1 = mitigated
var int[]   obStart  = array.new<int>()

makeOB(bool isBull) =>
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
        col = isBull ? obBullCol : obBearCol
        bx  = box.new(bar_index - idx, t, bar_index + 10, b, border_color = color.new(col, 40), bgcolor = color.new(col, zoneOpacity), border_width = 1)
        lb  = label.new(bar_index - idx, isBull ? b : t, isBull ? "Bull OB" : "Bear OB", style = isBull ? label.style_label_up : label.style_label_down, color = color.new(col, 85), textcolor = col, size = size.tiny)
        obBox.push(bx)
        obLbl.push(lb)
        obIsBull.push(isBull)
        obTop.push(t)
        obBtm.push(b)
        obState.push(0)
        obStart.push(bar_index)

if showOB and (bullBOS or bullCHoCH)
    makeOB(true)
if showOB and (bearBOS or bearCHoCH)
    makeOB(false)

// ================== ORDER BLOCK STATE — mitigation + extend ==================

bullObMit = false
bearObMit = false

if obBox.size() > 0
    for i = obBox.size() - 1 to 0
        bx = obBox.get(i)
        if not na(bx)
            st     = obState.get(i)
            isB    = obIsBull.get(i)
            t      = obTop.get(i)
            b      = obBtm.get(i)
            startB = obStart.get(i)
            if st == 0
                box.set_right(bx, bar_index + 10)
                mit = false
                if bar_index > startB
                    mit := isB ? (obMitig == "Close" ? close <= t : low <= t) : (obMitig == "Close" ? close >= b : high >= b)
                if mit
                    fadeCol = isB ? obBullCol : obBearCol
                    obState.set(i, 1)
                    box.set_bgcolor(bx, color.new(fadeCol, math.min(zoneOpacity + 12, 95)))
                    box.set_border_style(bx, line.style_dashed)
                    box.set_right(bx, bar_index)
                    if isB
                        bullObMit := true
                    else
                        bearObMit := true

// ================== ORDER BLOCK — trim per side ==================

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
    if obBox.size() > 0
        for i = 0 to obBox.size() - 1
            if obState.get(i) == 0
                if obIsBull.get(i)
                    activeBull += 1
                else
                    activeBear += 1

    biasTxt = trend > 0 ? "▲ BULLISH" : trend < 0 ? "▼ BEARISH" : "• NEUTRAL"
    biasCol = trend > 0 ? bullCol : trend < 0 ? bearCol : cellTxt
    evtCol  = na(lastEventCol) ? cellTxt : lastEventCol

    table.cell(panel, 0, 0, "EDO SMART MONEY MAP", text_color = textCol, bgcolor = headerBg, text_size = panSizeTxt)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 1, "Structure",  text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 1, biasTxt,      text_color = biasCol, bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 2, "Last Event", text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 2, lastEvent,    text_color = evtCol,  bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 3, "Bull OB (active)", text_color = color.new(obBullCol, 0), bgcolor = subBg, text_size = panSizeTxt)
    table.cell(panel, 1, 3, str.tostring(activeBull), text_color = color.new(obBullCol, 0), bgcolor = subBg, text_size = panSizeTxt)

    table.cell(panel, 0, 4, "Bear OB (active)", text_color = color.new(obBearCol, 0), bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 4, str.tostring(activeBear), text_color = color.new(obBearCol, 0), bgcolor = cellBg, text_size = panSizeTxt)

// ================== ALERTS ==================

alertcondition(bullBOS,   "Bullish BOS",        "Edo Smart Money Map — Bullish BOS on {{ticker}}")
alertcondition(bearBOS,   "Bearish BOS",        "Edo Smart Money Map — Bearish BOS on {{ticker}}")
alertcondition(bullCHoCH, "Bullish CHoCH",      "Edo Smart Money Map — Bullish CHoCH on {{ticker}}")
alertcondition(bearCHoCH, "Bearish CHoCH",      "Edo Smart Money Map — Bearish CHoCH on {{ticker}}")
alertcondition(bullObMit, "Bull OB Mitigated",  "Edo Smart Money Map — Bullish order block mitigated on {{ticker}}")
alertcondition(bearObMit, "Bear OB Mitigated",  "Edo Smart Money Map — Bearish order block mitigated on {{ticker}}")
````
