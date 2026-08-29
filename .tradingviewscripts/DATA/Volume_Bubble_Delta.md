<!-- tradingview-pine-id: PUB;526d556a2ed844db91a71c1c696b2775 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Bubble Delta

Source: https://www.tradingview.com/script/xHK1Tk6T-Volume-Bubble-Delta/

## Description

Volume Bubble Delta
Short description (for the publish box summary)

Volume delta bubbles that anchor to each bar's Point of Control, scale with the size of the imbalance, and automatically thin out as you zoom out. Uses TradingView's native footprint data when available, with a lower-timeframe fallback for all plans.

Full description
What it does

This indicator answers one question on every bar: who was actually in control, buyers or sellers?

It plots a bubble on the chart whose colour tells you which side won the bar, whose size tells you how one-sided it was compared to recent bars, and whose number tells you the raw delta. Green means aggressive buyers dominated; red means aggressive sellers dominated.

The point of bubbles rather than a separate delta pane is that you read the imbalance in the same place you read price — no eye-travel between panes.

How the delta is calculated

The script runs two engines and picks the best one available:

Engine 1 — Native footprint (Premium / Ultimate plans) Calls request.footprint() to retrieve real order flow for the bar: exact ask-side (buy) volume, bid-side (sell) volume, delta, and the bar's Point of Control. This is true aggressor data, not an approximation.

Engine 2 — Lower-timeframe estimate (all plans) When footprint data isn't available, the script pulls intrabar candles via request.security_lower_tf() and classifies each one: closing up counts as buy volume, closing down as sell volume, and a flat intrabar is resolved against the previous intrabar close. If lower-timeframe data is also unavailable, it falls back to a wick-position proxy.

The control panel always shows which engine is live, so you know whether you're reading real delta or an estimate. This distinction matters — the estimate infers aggression from candle direction and will diverge from true footprint delta in fast or thin conditions.

Bubble placement

By default bubbles anchor to the bar's Point of Control — the price level where the most volume traded inside that bar. This puts the bubble where the activity actually happened rather than floating above or below the candle, so a bubble sitting high in a bar's range tells you something different from one sitting at the low. When footprint data isn't available, bubbles fall back to the body midpoint. Alternative positions (body mid, close, above/below) are available in settings.

Zoom-adaptive density

Most bubble indicators become unreadable when you zoom out — hundreds of overlapping circles. This one reads the visible chart range, works out how many bars are on screen, and raises its threshold accordingly.

Zoomed in, small imbalances appear. Zoomed out, only the heavyweight prints survive, with wider minimum spacing between them. You set a target number of bubbles you want on screen and the script maintains roughly that density at any zoom level.

Because this reads the visible range, the script recalculates when you zoom or pan. If you prefer a fixed threshold, the behaviour can be switched off.

Absorption detection

The setups worth watching are the ones where delta and price disagree:

Green bubble on a red candle — price closed down, but aggressive buyers dominated the bar. Sellers pushed and buyers absorbed it.
Red bubble on a green candle — price closed up on aggressive selling.

These bars get tinted, always print a bubble regardless of the zoom filter, and have dedicated alerts. Divergence between delta and price direction is often read as the underlying pressure weakening relative to the visible move — though like any signal it fails regularly and means nothing in isolation.

Settings
Delta engine — force native footprint, force the estimate, or let it auto-select. Footprint row size and value area % are configurable.
What to show — every bar, significant bars only, or divergences only. Threshold is a multiple of the rolling average absolute delta, so it adapts to the instrument automatically.
Bubble look — three colour schemes, size scaling on/off, opacity, position.
Zoom behaviour — target bubble count and how aggressively to thin.
Extras — absorption tinting, ▲▼ markers, per-bar POC lines, control panel position.
Control panel

Top-right by default: who's in control, bar delta with percentage, buy and sell volume, session cumulative delta, and the active data source. Numbers abbreviate to K/M/B so the panel stays compact.

Alerts
Buyers absorbing a red candle
Sellers absorbing a green candle
Session cumulative delta crossing above or below zero
Notes and limitations
request.footprint() requires a Premium or Ultimate plan. On lower tiers, comment out the block marked NATIVE FOOTPRINT in the source and set the delta source to "Lower TF estimate".
Seconds-based lower timeframes need a paid plan. On free plans use 1 minute, which means the estimate works best on 5m charts and above.
Pine labels have five discrete size steps, so bubbles grow in stages rather than continuously.
The rolling average needs roughly 20 bars to settle before the significance filter behaves sensibly.
Volume delta describes what already happened in a bar. It is not predictive on its own, and this indicator is a visualisation tool rather than a trading system. Nothing here is financial advice.
Suggested starting point

30m chart, "Significant only" mode, target 20 bubbles on screen. Watch what the bubbles do at prior POC, VAH and VAL levels — imbalance at a level you already care about is more informative than imbalance in the middle of nowhere.

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════
//  VOLUME BUBBLE DELTA — v2 (visible-range renderer)
//  Bubble size = strength of imbalance | Green = buyers, Red = sellers
//
//  Engine 1: request.footprint()  → real bid/ask delta (Premium+)
//  Engine 2: request.security_lower_tf() → estimate (any plan)
//
//  ESSENTIAL / PLUS PLANS: if the script errors, comment out the
//  block marked "NATIVE FOOTPRINT" and set Delta source = "Lower TF estimate".
//
//  v2: bubbles are no longer drawn bar-by-bar. Candidates are stored
//  in arrays during calculation, then only the strongest N inside the
//  visible chart window are rendered. Zooming re-ranks instantly and
//  bubbles always match what's on screen.
// ═══════════════════════════════════════════════════════════════════
indicator("Volume Bubble Delta", "Vol Δ", overlay = true,
     max_labels_count = 500, max_lines_count = 500)

// ─────────────────────────── Inputs ────────────────────────────────
D = display.none

gEng = "① Delta engine"
engine   = input.string("Auto", "Delta source", options = ["Auto", "Native footprint", "Lower TF estimate"], group = gEng, display = D)
ticksRow = input.int(100, "Footprint ticks per row", minval = 1, group = gEng, display = D)
vaPct    = input.int(70, "Value area %", minval = 1, maxval = 100, group = gEng, display = D)
autoTF   = input.bool(true, "Auto lower timeframe (fallback)", group = gEng, display = D)
manualTF = input.timeframe("1", "Manual lower timeframe (fallback)", group = gEng, display = D)

gFilt = "② What to show"
mode    = input.string("Significant only", "Show bubbles on", options = ["Every bar", "Significant only", "Divergence only"], group = gFilt, display = D)
relMult = input.float(1.2, "Significance threshold (× avg Δ)", minval = 0.1, step = 0.1, group = gFilt, display = D)
avgLen  = input.int(20, "Average Δ lookback", minval = 2, group = gFilt, display = D)
minAbs  = input.float(0, "Hard minimum |Δ|", minval = 0, group = gFilt, display = D)

gStyle = "③ Bubble look"
scheme     = input.string("Green / Red", "Color scheme", options = ["Green / Red", "Blue / Red", "Teal / Magenta"], group = gStyle, display = D)
scaleSize  = input.bool(true, "Scale bubble size with Δ", group = gStyle, display = D)
baseSize   = input.string("Small", "Base bubble size", options = ["Tiny", "Small", "Normal", "Large"], group = gStyle, display = D)
fillTransp = input.int(65, "Bubble opacity", minval = 0, maxval = 95, group = gStyle, display = D, tooltip = "Lower = more solid.")
placement  = input.string("On candle (POC)", "Bubble position", options = ["On candle (POC)", "Body mid", "At close", "Above / Below"], group = gStyle, display = D)
offMult    = input.float(0.6, "Distance from candle (× ATR)", minval = 0, step = 0.1, group = gStyle, display = D, tooltip = "Only used by the Above / Below position.")
showPct    = input.bool(false, "Label as % of bar volume", group = gStyle, display = D)

gZoom = "④ Bubbles on screen"
targetBub = input.int(20, "Max bubbles on screen", minval = 3, maxval = 100, group = gZoom, display = D, tooltip = "The strongest deltas in the visible window are shown first. Zoom in → smaller bubbles appear. Zoom out → only the biggest survive. Divergences always win priority.")
minGap    = input.int(2, "Min bars between bubbles", minval = 0, group = gZoom, display = D)
autoSpace = input.bool(true, "Auto-space when zoomed out", group = gZoom, display = D, tooltip = "Widens the spacing automatically so bubbles never overlap at any zoom level.")

gExtra = "⑤ Extras"
paintDiv = input.bool(true,  "Tint absorption candles", group = gExtra, display = D)
markDiv  = input.bool(false, "Mark absorption with ▲▼", group = gExtra, display = D)
showPOC  = input.bool(false, "Draw bar POC (native only)", group = gExtra, display = D)
showTbl  = input.bool(true,  "Show control panel", group = gExtra, display = D)
tblPos   = input.string("Top right", "Panel position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = gExtra, display = D)

// ─────────────────────── Color resolution ──────────────────────────
buyBase  = scheme == "Blue / Red"     ? #2962ff : scheme == "Teal / Magenta" ? #00bcd4 : #26a69a
sellBase = scheme == "Teal / Magenta" ? #e91e63 : #f23645

// ═══════════════ ENGINE 1 — NATIVE FOOTPRINT ═══════════════════════
footprint fp = request.footprint(ticksRow, vaPct)

float natBuy   = na
float natSell  = na
float natDelta = na
float pocUp    = na
float pocDn    = na

if not na(fp)
    natBuy   := fp.buy_volume()
    natSell  := fp.sell_volume()
    natDelta := fp.delta()
    volume_row poc = fp.poc()
    if not na(poc)
        pocUp := poc.up_price()
        pocDn := poc.down_price()
// ═══════════════ END NATIVE FOOTPRINT BLOCK ════════════════════════

// ═══════════════ ENGINE 2 — LOWER TF ESTIMATE ══════════════════════
autoLtf() =>
    s = timeframe.in_seconds(timeframe.period)
    s <=    60 ? "1S"  : s <=  300 ? "5S"  : s <=   900 ? "15S" :
     s <=  3600 ? "1"   : s <= 14400 ? "5"   : "15"

ltf = autoTF ? autoLtf() : manualTF
[oA, cA, vA] = request.security_lower_tf(syminfo.tickerid, ltf, [open, close, volume])

estBuy  = 0.0
estSell = 0.0
n = array.size(vA)

if n > 0
    for i = 0 to n - 1
        o = array.get(oA, i)
        c = array.get(cA, i)
        v = array.get(vA, i)
        if c > o
            estBuy  += v
        else if c < o
            estSell += v
        else
            pc = i > 0 ? array.get(cA, i - 1) : o
            if c > pc
                estBuy  += v
            else if c < pc
                estSell += v
            else
                estBuy  += v / 2
                estSell += v / 2
else
    rng = math.max(high - low, syminfo.mintick)
    estBuy  := volume * (close - low)  / rng
    estSell := volume * (high - close) / rng

// ═══════════════ ENGINE SELECTION ══════════════════════════════════
nativeOk = not na(natDelta) and engine != "Lower TF estimate"

buyVol  = nativeOk ? natBuy   : estBuy
sellVol = nativeOk ? natSell  : estSell
delta   = nativeOk ? natDelta : estBuy - estSell
srcTag  = nativeOk ? "Footprint (live)" : (n > 0 ? ltf + " estimate" : "Wick proxy")

totalVol = buyVol + sellVol
deltaPct = totalVol > 0 ? delta / totalVol * 100 : 0.0

// ─────────────────────── Cumulative delta ──────────────────────────
newSession = ta.change(time("D")) != 0
var float cumDelta = 0.0
cumDelta := newSession ? delta : cumDelta + delta

// ───────────────────────── Divergence ──────────────────────────────
bullAbsorb = close < open and delta > 0
bearAbsorb = close > open and delta < 0
isDiv      = bullAbsorb or bearAbsorb

// ─────────────────────── Strength / filter ─────────────────────────
avgAbs = ta.sma(math.abs(delta), avgLen)
ratio  = avgAbs > 0 ? math.abs(delta) / avgAbs : 1.0

// Base filter (zoom-independent — zoom thinning is handled by the renderer)
passBase = mode == "Every bar"        ? math.abs(delta) >= minAbs :
           mode == "Significant only" ? (math.abs(delta) >= avgAbs * relMult and math.abs(delta) >= minAbs) :
           isDiv and math.abs(delta) >= minAbs

// ───────────────────── Bubble Y position ───────────────────────────
atr = ta.atr(14)
off = atr * offMult
pocMid  = not na(pocUp) and not na(pocDn) ? math.avg(pocUp, pocDn) : na
bodyMid = math.avg(open, close)

yPos = placement == "On candle (POC)" ? nz(pocMid, bodyMid) :
       placement == "Body mid"        ? bodyMid :
       placement == "At close"        ? close :
       (delta > 0 ? high + off : low - off)

// ═══════════════ CANDIDATE STORE (cheap, per bar) ═══════════════════
// Instead of drawing labels bar-by-bar (slow + stale on zoom), we store
// candidate bubbles in parallel arrays and render at the end.
MAXCAND = 2500

var cBar   = array.new_int()
var cTime  = array.new_int()
var cY     = array.new_float()
var cDelta = array.new_float()
var cPct   = array.new_float()
var cBuy   = array.new_float()
var cSell  = array.new_float()
var cRatio = array.new_float()
var cDiv   = array.new_int()   // 0 = none, 1 = bull absorb, 2 = bear absorb

if passBase and barstate.isconfirmed
    array.push(cBar,   bar_index)
    array.push(cTime,  time)
    array.push(cY,     yPos)
    array.push(cDelta, delta)
    array.push(cPct,   deltaPct)
    array.push(cBuy,   buyVol)
    array.push(cSell,  sellVol)
    array.push(cRatio, ratio)
    array.push(cDiv,   bullAbsorb ? 1 : bearAbsorb ? 2 : 0)
    if array.size(cBar) > MAXCAND
        array.shift(cBar), array.shift(cTime), array.shift(cY)
        array.shift(cDelta), array.shift(cPct), array.shift(cBuy)
        array.shift(cSell), array.shift(cRatio), array.shift(cDiv)

// ────────────────────── Number formatting ──────────────────────────
abbr(float x) =>
    a = math.abs(x)
    a >= 1e9 ? str.tostring(x / 1e9, "#.#") + "B" :
     a >= 1e6 ? str.tostring(x / 1e6, "#.#") + "M" :
     a >= 1e3 ? str.tostring(x / 1e3, "#.#") + "K" :
     str.tostring(x, "#")

// ═══════════════ RENDERER (runs once, on the last bar) ══════════════
var label[] bubs = array.new<label>()
var int   prevL  = -1
var int   prevR  = -1
var int   prevCt = -1

drawBubble(int i) =>
    d   = array.get(cDelta, i)
    r   = array.get(cRatio, i)
    dv  = array.get(cDiv, i)
    pct = array.get(cPct, i)

    baseIdx = baseSize == "Tiny" ? 0 : baseSize == "Small" ? 1 : baseSize == "Normal" ? 2 : 3
    stp     = scaleSize ? (r >= 3.0 ? 2 : r >= 2.0 ? 1 : 0) : 0
    lvl     = math.min(baseIdx + stp, 4)
    bubSize = lvl == 0 ? size.tiny : lvl == 1 ? size.small :
              lvl == 2 ? size.normal : lvl == 3 ? size.large : size.huge

    boost  = int(math.min(r, 3.0) / 3.0 * 30)
    transp = int(math.max(5, fillTransp - boost))
    bubCol = color.new(d > 0 ? buyBase : sellBase, transp)
    txt    = showPct ? str.tostring(pct, "#") + "%" : abbr(math.abs(d))

    tip = (d > 0 ? "▲ BUYERS IN CONTROL" : "▼ SELLERS IN CONTROL") +
         "\n────────────────" +
         "\nΔ        " + abbr(d) + "  (" + str.tostring(pct, "#.#") + "%)" +
         "\nBuy      " + abbr(array.get(cBuy, i)) +
         "\nSell     " + abbr(array.get(cSell, i)) +
         "\nStrength " + str.tostring(r, "#.#") + "× avg" +
         (dv == 1 ? "\n\n⚠ ABSORPTION — buyers eating a red candle" :
          dv == 2 ? "\n\n⚠ ABSORPTION — sellers eating a green candle" : "")

    array.push(bubs, label.new(array.get(cBar, i), array.get(cY, i),
         text = txt, style = label.style_circle, color = bubCol,
         textcolor = color.white, size = bubSize, tooltip = tip))

if barstate.islast
    msPerBar = timeframe.in_seconds(timeframe.period) * 1000
    int rT = nz(chart.right_visible_bar_time, time)
    int lT = nz(chart.left_visible_bar_time, time - msPerBar * 150)

    // Only redraw when the visible window or the data actually changed
    if lT != prevL or rT != prevR or array.size(cBar) != prevCt
        prevL  := lT
        prevR  := rT
        prevCt := array.size(cBar)

        // wipe previous bubbles
        if array.size(bubs) > 0
            for k = 0 to array.size(bubs) - 1
                label.delete(array.get(bubs, k))
            array.clear(bubs)

        // collect candidates inside the visible window
        int[] vis = array.new_int()
        float[] score = array.new_float()
        if array.size(cTime) > 0
            for i = 0 to array.size(cTime) - 1
                t = array.get(cTime, i)
                if t >= lT and t <= rT
                    array.push(vis, i)
                    // divergences always outrank plain deltas
                    array.push(score, array.get(cRatio, i) + (array.get(cDiv, i) > 0 ? 1e6 : 0.0))

        if array.size(vis) > 0
            barsVis = msPerBar > 0 ? math.max((rT - lT) / msPerBar, 10.0) : 150.0
            gapBars = autoSpace ? math.max(minGap, int(barsVis / (targetBub * 2.0))) : minGap

            order = array.sort_indices(score, order.descending)
            int[] chosen = array.new_int()

            for j = 0 to array.size(order) - 1
                if array.size(chosen) >= targetBub
                    break
                i = array.get(vis, array.get(order, j))
                b = array.get(cBar, i)
                ok = true
                if array.size(chosen) > 0
                    for k = 0 to array.size(chosen) - 1
                        if math.abs(b - array.get(chosen, k)) < gapBars
                            ok := false
                            break
                if ok
                    array.push(chosen, b)
                    drawBubble(i)

// ───────────────────── Absorption markers ──────────────────────────
plotshape(markDiv and bullAbsorb, "Bull absorption", shape.triangleup,
     location.belowbar, color.new(buyBase, 0), size = size.tiny, display = display.pane)
plotshape(markDiv and bearAbsorb, "Bear absorption", shape.triangledown,
     location.abovebar, color.new(sellBase, 0), size = size.tiny, display = display.pane)

barcolor(paintDiv and bullAbsorb ? color.new(buyBase, 45) :
         paintDiv and bearAbsorb ? color.new(sellBase, 45) : na)

// ───────────────────────── POC marker ──────────────────────────────
if showPOC and not na(pocUp) and not na(pocDn) and barstate.isconfirmed
    linefill.new(
         line.new(bar_index - 1, pocUp, bar_index, pocUp, color = color.new(color.orange, 55)),
         line.new(bar_index - 1, pocDn, bar_index, pocDn, color = color.new(color.orange, 55)),
         color.new(color.orange, 80))

// ────────────────────────── Control panel ──────────────────────────
tPos = tblPos == "Top left"     ? position.top_left :
       tblPos == "Bottom right" ? position.bottom_right :
       tblPos == "Bottom left"  ? position.bottom_left : position.top_right

if showTbl and barstate.islast
    var table t = table.new(tPos, 2, 6, border_width = 1,
         frame_color = color.new(color.gray, 70), frame_width = 1)
    ctrlTxt = delta > 0 ? "▲  BUYERS" : delta < 0 ? "▼  SELLERS" : "—  BALANCED"
    ctrlCol = delta > 0 ? buyBase : delta < 0 ? sellBase : color.gray

    table.cell(t, 0, 0, "IN CONTROL", text_color = color.new(color.gray, 20),
         text_size = size.tiny, bgcolor = color.new(color.black, 70))
    table.cell(t, 1, 0, ctrlTxt, text_color = color.white, text_size = size.small,
         bgcolor = color.new(ctrlCol, 45))

    table.cell(t, 0, 1, "Bar Δ", text_color = color.gray, text_size = size.tiny)
    table.cell(t, 1, 1, abbr(delta) + "  (" + str.tostring(deltaPct, "#.#") + "%)",
         text_color = delta > 0 ? buyBase : sellBase, text_size = size.small)

    table.cell(t, 0, 2, "Buy", text_color = color.gray, text_size = size.tiny)
    table.cell(t, 1, 2, abbr(buyVol), text_color = buyBase, text_size = size.small)

    table.cell(t, 0, 3, "Sell", text_color = color.gray, text_size = size.tiny)
    table.cell(t, 1, 3, abbr(sellVol), text_color = sellBase, text_size = size.small)

    table.cell(t, 0, 4, "Session ΣΔ", text_color = color.gray, text_size = size.tiny)
    table.cell(t, 1, 4, abbr(cumDelta),
         text_color = cumDelta > 0 ? buyBase : sellBase, text_size = size.small)

    table.cell(t, 0, 5, "Data", text_color = color.gray, text_size = size.tiny)
    table.cell(t, 1, 5, srcTag, text_color = color.new(color.gray, 20), text_size = size.tiny)

// ───────────────────────────  Alerts ───────────────────────────────
alertcondition(bullAbsorb, "Buyers absorbing red candle",    "Positive delta on a down candle")
alertcondition(bearAbsorb, "Sellers absorbing green candle", "Negative delta on an up candle")
alertcondition(ta.crossover(cumDelta, 0),  "Session CVD turned positive", "Cumulative delta crossed above zero")
alertcondition(ta.crossunder(cumDelta, 0), "Session CVD turned negative", "Cumulative delta crossed below zero")
````
