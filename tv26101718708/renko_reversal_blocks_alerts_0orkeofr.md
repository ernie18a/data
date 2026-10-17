# Renko Reversal Blocks & Alerts 

- url: https://www.tradingview.com/script/0orKeoFR-Renko-Reversal-Blocks-Alerts/
- type: indicator
- pine_id: PUB;b575fa284fe5485ab06758e37eead0e9
- version: 1.0

## Description

Detects Renko reversals — the first opposing brick after a directional run — draws the reversal brick's wick as a persistent zone, and fires an alert the moment the brick prints.

Why this exists

Renko charts filter noise well but offer no native reversal alert. TradingView's built-in alert types cover price and crossing conditions, not brick direction. This script adds that, and adds two things a raw direction flip does not give you: a run-length filter so single-brick alternations are ignored, and separate treatment of the reversal brick's wick, which is where the invalidation level actually sits.

Method

Brick direction is taken from body sign. The script counts consecutive same-direction bricks and signals only when the preceding run met a minimum length. The reversal brick's wick is measured independently of its body, and flips whose wick exceeds a chosen fraction of a box can be filtered out as low-quality reversals — a wide wick means a far invalidation for the same signal.

The wick region of the reversal brick is drawn as a block extending right. Blocks persist until a later brick closes through them, then freeze at that bar and dim rather than disappearing, leaving invalidated levels visible as history.

Box size is auto-detected. Because every brick body on a fixed-box Renko chart equals exactly one box, the script reads the size from the first brick, so the setting cannot desynchronise from the chart when switching between box sizes. The same measurement doubles as a chart validation: inconsistent brick bodies indicate an ATR Renko chart, which repaints, and a warning is displayed.

Inputs

Minimum bricks in prior run · maximum reversal wick, expressed in boxes so it scales across chart settings · box size (auto-detect, presets, or custom) · block extent, wick only or full brick · live blocks retained per side · alert on brick print or brick close · triangle size and colour · optional invalidation price label with tick buffer.

Use

Apply to a Traditional Renko chart with wicks enabled. Create the alert on the indicator using "Any alert() function call" set to Once Per Bar; this is what produces a print-time alert rather than one delayed by a further box. The message carries direction, wick size, prior run length, and the invalidation price.

Limitations

A Renko reversal necessarily arrives after price has travelled two boxes from the extreme. That lag is inherent to the chart type and is the cost of its noise filtering, not a shortcoming of this script. A brick's body is fixed at print, but its high and low can extend while it remains the rightmost bar, so an invalidation price delivered at print may widen before the brick completes; the "Brick close" option removes this at the cost of another box of delay. ATR-based Renko is not supported.

This marks a structural event. It is not a strategy, incorporates no trend or higher-timeframe context, and produces no performance statistics.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────
//  SPHINX RENKO FLIP  v1.0
//  Standalone. Apply directly to a Traditional renko chart with
//  wicks enabled. Detects the first opposing brick after a run,
//  marks the reversal block (wick region), and fires on print.
// ─────────────────────────────────────────────────────────────
indicator("Sphinx Renko Flip", "SRF", overlay = true, max_boxes_count = 200, max_labels_count = 100)

// ── Signal ───────────────────────────────────────────────────
grpS  = "Signal"
minRun   = input.int(2, "Min bricks in prior run", minval = 1, group = grpS,
     tooltip = "How many same-direction bricks must precede the flip. 1 = every alternation fires.")
boxSel   = input.string("Auto-detect", "Box size", options = ["Auto-detect", "1", "2", "5", "10", "25", "Custom"], group = grpS,
     tooltip = "Must match the chart's renko setting. Auto-detect reads it off the first brick and is the safest option — it can never drift out of sync with the chart.")
boxCust  = input.float(5.0, "Custom box size (points)", minval = 0.0, step = 0.25, group = grpS,
     tooltip = "Used only when Box size is set to Custom.")
maxWickB = input.float(0.0, "Max wick on reversal brick (boxes, 0 = off)", minval = 0.0, step = 0.1, group = grpS,
     tooltip = "Expressed in boxes so it scales with box size. 0.5 rejects a flip whose wick exceeds half a box — 2.5 pts on a 5pt chart, 5 pts on a 10pt chart.")
fireOn   = input.string("Brick print", "Fire alert on", options = ["Brick print", "Brick close"], group = grpS,
     tooltip = "Brick print = the instant the brick materialises. Brick close = waits for the NEXT brick to begin, which costs a further full box.")

// ── Reversal block ───────────────────────────────────────────
grpZ  = "Reversal block"
drawZone = input.bool(true, "Draw reversal block", group = grpZ)
zoneMode = input.string("Wick only", "Block extent", options = ["Wick only", "Full brick"], group = grpZ,
     tooltip = "Wick only = body edge to wick extreme (the rejected area). Full brick = the whole brick range.")
zoneKeep = input.int(6, "Max live blocks per side", minval = 1, maxval = 20, group = grpZ)
bearCol  = input.color(color.new(#8b1a1a, 82), "Bearish block", group = grpZ)
bullCol  = input.color(color.new(#c9a227, 82), "Bullish block", group = grpZ)
deadCol  = input.color(color.new(color.gray, 90), "Invalidated block", group = grpZ)

// ── Markers ──────────────────────────────────────────────────
grpM  = "Markers"
showMark = input.bool(true, "Show flip triangle", group = grpM)
markSize = input.string("Tiny", "Triangle size", options = ["Tiny", "Small", "Normal"], group = grpM)
markDn   = input.color(#e04b4b, "Bear triangle", group = grpM)
markUp   = input.color(#c9a227, "Bull triangle", group = grpM)

// ── Risk ─────────────────────────────────────────────────────
grpR  = "Risk"
bufTicks = input.int(2, "Stop buffer (ticks beyond wick)", minval = 0, group = grpR)
showLbl  = input.bool(false, "Show invalidation price label", group = grpR,
     tooltip = "Off by default. The invalidation price is already carried in the alert message, so the chart stays clean.")

// ── Resolved box size ────────────────────────────────────────
// Fixed-box renko bricks all have a body of exactly one box, so the
// first non-zero body IS the box size. Locked on first read so the
// consistency check below can still catch a repainting ATR chart.
bodyAbs = math.abs(close - open)
var float autoBox = na
if na(autoBox) and bodyAbs > 0
    autoBox := bodyAbs

boxPts = switch boxSel
    "Auto-detect" => nz(autoBox, 0.0)
    "1"           => 1.0
    "2"           => 2.0
    "5"           => 5.0
    "10"          => 10.0
    "25"          => 25.0
    => boxCust

maxWick = maxWickB * boxPts

// ── Brick direction and run length ───────────────────────────
bdir = close > open ? 1 : close < open ? -1 : 0

var int runLen = 1
runLen := na(bdir[1]) or bdir != bdir[1] ? 1 : runLen + 1
priorRun = nz(runLen[1], 0)

// ── Wick geometry ────────────────────────────────────────────
bodyTop = math.max(open, close)
bodyBot = math.min(open, close)
upWick  = high - bodyTop
dnWick  = bodyBot - low

wickOkDn = maxWick == 0.0 or upWick <= maxWick
wickOkUp = maxWick == 0.0 or dnWick <= maxWick

// ── Flip detection ───────────────────────────────────────────
flipDn = bdir == -1 and nz(bdir[1]) ==  1 and priorRun >= minRun and wickOkDn
flipUp = bdir ==  1 and nz(bdir[1]) == -1 and priorRun >= minRun and wickOkUp

// ── Invalidation levels ──────────────────────────────────────
buf    = bufTicks * syminfo.mintick
stopDn = high + buf   // bear flip: stop above the reversal wick
stopUp = low  - buf   // bull flip: stop below the reversal wick

// ── Reversal blocks ──────────────────────────────────────────
var array<box> bearBoxes = array.new<box>()
var array<box> bullBoxes = array.new<box>()

zTopDn = high
zBotDn = zoneMode == "Wick only" ? bodyTop : bodyBot
zTopUp = zoneMode == "Wick only" ? bodyBot : bodyTop
zBotUp = low

if drawZone and flipDn
    b = box.new(bar_index, zTopDn, bar_index + 1, zBotDn,
         border_color = color.new(#8b1a1a, 45), bgcolor = bearCol, extend = extend.right)
    array.push(bearBoxes, b)
    if array.size(bearBoxes) > zoneKeep
        box.delete(array.shift(bearBoxes))

if drawZone and flipUp
    b = box.new(bar_index, zTopUp, bar_index + 1, zBotUp,
         border_color = color.new(#c9a227, 45), bgcolor = bullCol, extend = extend.right)
    array.push(bullBoxes, b)
    if array.size(bullBoxes) > zoneKeep
        box.delete(array.shift(bullBoxes))

// Blocks persist until a brick closes through them, then freeze and dim.
if drawZone and barstate.isconfirmed
    if array.size(bearBoxes) > 0
        for i = array.size(bearBoxes) - 1 to 0
            bx = array.get(bearBoxes, i)
            if close > box.get_top(bx)
                box.set_extend(bx, extend.none)
                box.set_right(bx, bar_index)
                box.set_bgcolor(bx, deadCol)
                box.set_border_color(bx, deadCol)
                array.remove(bearBoxes, i)
    if array.size(bullBoxes) > 0
        for i = array.size(bullBoxes) - 1 to 0
            bx = array.get(bullBoxes, i)
            if close < box.get_bottom(bx)
                box.set_extend(bx, extend.none)
                box.set_right(bx, bar_index)
                box.set_bgcolor(bx, deadCol)
                box.set_border_color(bx, deadCol)
                array.remove(bullBoxes, i)

// ── Markers ──────────────────────────────────────────────────
// plotshape's size argument must be a compile-time constant, so each
// size gets its own gated call rather than reading the input directly.
mDn = showMark and flipDn
mUp = showMark and flipUp

plotshape(mDn and markSize == "Tiny",   "Bear flip (tiny)",   shape.triangledown, location.abovebar, markDn, size = size.tiny)
plotshape(mDn and markSize == "Small",  "Bear flip (small)",  shape.triangledown, location.abovebar, markDn, size = size.small)
plotshape(mDn and markSize == "Normal", "Bear flip (normal)", shape.triangledown, location.abovebar, markDn, size = size.normal)
plotshape(mUp and markSize == "Tiny",   "Bull flip (tiny)",   shape.triangleup,   location.belowbar, markUp, size = size.tiny)
plotshape(mUp and markSize == "Small",  "Bull flip (small)",  shape.triangleup,   location.belowbar, markUp, size = size.small)
plotshape(mUp and markSize == "Normal", "Bull flip (normal)", shape.triangleup,   location.belowbar, markUp, size = size.normal)

if showLbl and flipDn
    label.new(bar_index, high, str.tostring(stopDn, format.mintick),
         style = label.style_label_down, color = color.new(color.black, 35),
         textcolor = markDn, size = size.tiny)
if showLbl and flipUp
    label.new(bar_index, low, str.tostring(stopUp, format.mintick),
         style = label.style_label_up, color = color.new(color.black, 35),
         textcolor = markUp, size = size.tiny)

// ── Chart sanity check ───────────────────────────────────────
// Fixed-box renko bodies are all exactly one box. If they aren't,
// the chart is probably ATR renko (which repaints) or not renko.
var int  mismatch = 0
var bool warned   = false
if boxPts > 0 and math.abs(bodyAbs - boxPts) > syminfo.mintick / 2
    mismatch += 1
if boxPts > 0 and not warned and bar_index == 60 and mismatch > 12
    warned := true
    label.new(bar_index, close,
         "Brick bodies ≠ " + str.tostring(boxPts) + " pts.\nEither the box size setting is wrong, or the chart is\nATR renko (which repaints) rather than Traditional.",
         style = label.style_label_left, color = color.new(color.orange, 15),
         textcolor = color.white, size = size.small)

// ── Alerts ───────────────────────────────────────────────────
armed = fireOn == "Brick print" or barstate.isconfirmed

msgDn = str.format("{0} RENKO BEAR FLIP  close {1}  wick {2}  invalidation {3}  (run was {4})",
     syminfo.ticker, str.tostring(close, format.mintick), str.tostring(upWick, "#.##"),
     str.tostring(stopDn, format.mintick), str.tostring(priorRun))
msgUp = str.format("{0} RENKO BULL FLIP  close {1}  wick {2}  invalidation {3}  (run was {4})",
     syminfo.ticker, str.tostring(close, format.mintick), str.tostring(dnWick, "#.##"),
     str.tostring(stopUp, format.mintick), str.tostring(priorRun))

if flipDn and armed
    alert(msgDn, alert.freq_once_per_bar)
if flipUp and armed
    alert(msgUp, alert.freq_once_per_bar)

alertcondition(flipDn, "Renko bear flip", "First bearish brick after a bullish run")
alertcondition(flipUp, "Renko bull flip", "First bullish brick after a bearish run")

// ── Data window exports (for the level-interaction harvester) ─
plot(flipUp ? 1 : flipDn ? -1 : 0, "Flip",        display = display.data_window)
plot(priorRun,                     "Prior run",   display = display.data_window)
plot(flipDn ? upWick : flipUp ? dnWick : na, "Rev wick", display = display.data_window)
plot(flipDn ? stopDn : flipUp ? stopUp : na, "Invalidation", display = display.data_window)
````
