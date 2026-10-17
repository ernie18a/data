# Liquidity Sweep + Inverse FVG

- url: https://www.tradingview.com/script/HFkqH2h3/
- type: indicator
- pine_id: PUB;5fbe6a528f3f45f8a4149455cb2247f4
- version: 1.0

## Description

Enter once IFVG pop up, put SL below recent LOW or below GAP, target previous HIGH

## Source Code

````pine
//@version=6
indicator("Liquidity Sweep + Inverse FVG", overlay = true,
          max_boxes_count  = 50,
          max_lines_count  = 50,
          max_labels_count = 50)

// ══════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════
var string GRP_SWING  = "Swing Detection"
var string GRP_FILTER = "Sweep Filter"
var string GRP_VIS    = "Visuals"

swingLen    = input.int   (10,   "Swing Length",                    minval = 3,   group = GRP_SWING)
fvgExt      = input.int   (40,   "FVG Box Extend (bars)",           minval = 5,   group = GRP_SWING)

atrLen      = input.int   (14,   "ATR Length",                      minval = 1,   group = GRP_FILTER)
minWickMult = input.float (0.25, "Min Wick Beyond Level (× ATR)",   minval = 0.0, step = 0.05, group = GRP_FILTER)
bodyFilter  = input.bool  (true, "Wick-Only Sweep (body stays inside level)",     group = GRP_FILTER)

showSweep   = input.bool  (true,  "Show Sweep Markers",    group = GRP_VIS)
showSwings  = input.bool  (true,  "Show Swing Dots",       group = GRP_VIS)
showIFVG    = input.bool  (true,  "Show iFVG Box",         group = GRP_VIS)
showLevel   = input.bool  (true,  "Show Swept Level Line", group = GRP_VIS)

bullCol     = input.color (#00bcd4, "Bullish Color", group = GRP_VIS)
bearCol     = input.color (#f44336, "Bearish Color", group = GRP_VIS)

// ══════════════════════════════════════════════════════════════════
//  CONSTANTS
// ══════════════════════════════════════════════════════════════════
MAX_SETUPS = 5

// ══════════════════════════════════════════════════════════════════
//  SWING HIGH / LOW  — store bar index of actual pivot
// ══════════════════════════════════════════════════════════════════
swHigh = ta.pivothigh(high, swingLen, swingLen)
swLow  = ta.pivotlow (low,  swingLen, swingLen)

var float lastSwHigh    = na
var float lastSwLow     = na
var int   lastSwHighBar = na   // bar where the swing HIGH actually formed
var int   lastSwLowBar  = na   // bar where the swing LOW  actually formed

if not na(swHigh)
    lastSwHigh    := swHigh
    lastSwHighBar := bar_index - swingLen   // pivot confirmed swingLen bars later → actual bar
    if showSwings
        label.new(bar_index - swingLen, swHigh, "●",
                  color = color.new(color.gray, 100), textcolor = color.new(bearCol, 20),
                  style = label.style_label_down, size = size.tiny)

if not na(swLow)
    lastSwLow    := swLow
    lastSwLowBar := bar_index - swingLen
    if showSwings
        label.new(bar_index - swingLen, swLow, "●",
                  color = color.new(color.gray, 100), textcolor = color.new(bullCol, 20),
                  style = label.style_label_up, size = size.tiny)

// ══════════════════════════════════════════════════════════════════
//  SWEEP DETECTION  —  wick-only, ATR-qualified
// ══════════════════════════════════════════════════════════════════
atr       = ta.atr(atrLen)

bodyTop   = math.max(open, close)
bodyBot   = math.min(open, close)

wickAbove = not na(lastSwHigh) ? high - lastSwHigh : 0.0
wickBelow = not na(lastSwLow)  ? lastSwLow - low   : 0.0

bearSweep = not na(lastSwHigh)
          and high  > lastSwHigh
          and close < lastSwHigh
          and wickAbove >= minWickMult * atr
          and (bodyFilter ? bodyTop < lastSwHigh : true)

bullSweep = not na(lastSwLow)
          and low   < lastSwLow
          and close > lastSwLow
          and wickBelow >= minWickMult * atr
          and (bodyFilter ? bodyBot > lastSwLow : true)

// ══════════════════════════════════════════════════════════════════
//  SETUP STORAGE  — last MAX_SETUPS completed setups
// ══════════════════════════════════════════════════════════════════
var box[]   completedBoxes  = array.new<box>()
var line[]  completedLines  = array.new<line>()
var label[] completedIfvgL  = array.new<label>()
var label[] completedSweepL = array.new<label>()

// Pending objects — created on sweep, committed when iFVG fires
var bool  lookBull   = false
var bool  lookBear   = false
var line  pendLine   = na
var label pendSweepL = na

// Prune oldest completed setup when limit is exceeded
pruneOldest(box[] bArr, line[] lArr, label[] ilArr, label[] slArr) =>
    if array.size(bArr) > MAX_SETUPS
        b = array.shift(bArr)
        if not na(b)
            box.delete(b)
    if array.size(lArr) > MAX_SETUPS
        l = array.shift(lArr)
        if not na(l)
            line.delete(l)
    if array.size(ilArr) > MAX_SETUPS
        il = array.shift(ilArr)
        if not na(il)
            label.delete(il)
    if array.size(slArr) > MAX_SETUPS
        sl = array.shift(slArr)
        if not na(sl)
            label.delete(sl)

// ══════════════════════════════════════════════════════════════════
//  SWEEP EVENTS  — arrow markers + level line from actual swing bar
// ══════════════════════════════════════════════════════════════════
if bullSweep or bearSweep
    // Cancel unresolved pending setup (sweep fired before iFVG formed)
    if not na(pendLine)
        line.delete(pendLine)
        pendLine := na
    if not na(pendSweepL)
        label.delete(pendSweepL)
        pendSweepL := na

if bullSweep
    lookBull := true
    lookBear := false

    // Line starts from the ACTUAL swing low bar → extends to fvgExt
    pendLine := showLevel
                 ? line.new(lastSwLowBar, lastSwLow,
                             bar_index + fvgExt, lastSwLow,
                             color = color.new(bullCol, 40), width = 1,
                             style = line.style_solid)
                 : na

    // Arrow-up marker at the wick low — no text, shape only
    pendSweepL := showSweep
                   ? label.new(bar_index, low, "",
                                color     = color.new(bullCol, 0),
                                textcolor = color.white,
                                style     = label.style_arrowup,
                                size      = size.normal)
                   : na

if bearSweep
    lookBear := true
    lookBull := false

    // Line starts from the ACTUAL swing high bar → extends to fvgExt
    pendLine := showLevel
                 ? line.new(lastSwHighBar, lastSwHigh,
                             bar_index + fvgExt, lastSwHigh,
                             color = color.new(bearCol, 40), width = 1,
                             style = line.style_solid)
                 : na

    // Arrow-down marker at the wick high — no text, shape only
    pendSweepL := showSweep
                   ? label.new(bar_index, high, "",
                                color     = color.new(bearCol, 0),
                                textcolor = color.white,
                                style     = label.style_arrowdown,
                                size      = size.normal)
                   : na

// ══════════════════════════════════════════════════════════════════
//  INVERSE FAIR VALUE GAP  →  complete the setup
// ══════════════════════════════════════════════════════════════════
bullIFVG = high[2] < low[0]
bearIFVG = low[2]  > high[0]

if lookBull and bullIFVG
    ifvgTop = low[0]
    ifvgBot = high[2]

    b  = showIFVG ? box.new(bar_index - 2, ifvgTop, bar_index + fvgExt, ifvgBot,
                             bgcolor      = color.new(bullCol, 90),
                             border_color = color.new(bullCol, 30),
                             border_width = 1,
                             border_style = line.style_solid) : na

    il = showIFVG ? label.new(bar_index - 1, math.avg(ifvgTop, ifvgBot), "iFVG",
                               color     = color.new(bullCol, 100),
                               textcolor = color.new(bullCol, 0),
                               style     = label.style_label_right,
                               size      = size.tiny) : na

    array.push(completedBoxes,  b)
    array.push(completedLines,  pendLine)
    array.push(completedIfvgL,  il)
    array.push(completedSweepL, pendSweepL)
    pruneOldest(completedBoxes, completedLines, completedIfvgL, completedSweepL)

    pendLine   := na
    pendSweepL := na
    lookBull   := false

if lookBear and bearIFVG
    ifvgTop = low[2]
    ifvgBot = high[0]

    b  = showIFVG ? box.new(bar_index - 2, ifvgTop, bar_index + fvgExt, ifvgBot,
                             bgcolor      = color.new(bearCol, 90),
                             border_color = color.new(bearCol, 30),
                             border_width = 1,
                             border_style = line.style_solid) : na

    il = showIFVG ? label.new(bar_index - 1, math.avg(ifvgTop, ifvgBot), "iFVG",
                               color     = color.new(bearCol, 100),
                               textcolor = color.new(bearCol, 0),
                               style     = label.style_label_right,
                               size      = size.tiny) : na

    array.push(completedBoxes,  b)
    array.push(completedLines,  pendLine)
    array.push(completedIfvgL,  il)
    array.push(completedSweepL, pendSweepL)
    pruneOldest(completedBoxes, completedLines, completedIfvgL, completedSweepL)

    pendLine   := na
    pendSweepL := na
    lookBear   := false

// ══════════════════════════════════════════════════════════════════
//  ACTIVE SETUP BACKGROUND TINT
// ══════════════════════════════════════════════════════════════════
bgcolor(lookBull ? color.new(bullCol, 97) :
        lookBear ? color.new(bearCol, 97) : na,
        title = "Active setup tint")

// ══════════════════════════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════════════════════════
alertcondition(bullSweep,             "Bull Sweep", "Liquidity sweep of prior low")
alertcondition(bearSweep,             "Bear Sweep", "Liquidity sweep of prior high")
alertcondition(lookBull and bullIFVG, "Bull iFVG",  "Bullish iFVG confirmed after low sweep")
alertcondition(lookBear and bearIFVG, "Bear iFVG",  "Bearish iFVG confirmed after high sweep")
````
