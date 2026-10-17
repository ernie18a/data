# SMC Toolkit - CHoCH, BoS, FVG, P/D [AvantCoin]

- url: https://www.tradingview.com/script/a0OtPWX1-SMC-Toolkit-CHoCH-BoS-FVG-P-D-AvantCoin/
- type: indicator
- pine_id: PUB;833043ee8e6748b09e2cdb615ac4399d
- version: 2.0

## Description

SMC Toolkit - CHoCH, BoS, FVG, P/D
A focused market structure indicator covering the four foundational SMC concepts in a single, configurable tool.
What it shows

CHoCH (Change of Character): marks the first break that reverses the prevailing trend.
BoS (Break of Structure): marks continuation breaks in the direction of the current trend.
FVG (Fair Value Gaps):  highlights 3-candle imbalance zones, with automatic tracking of mitigation, time expiry, and structural invalidation.
Premium / Discount: plots the equilibrium of the current swing range, with optional zone shading to identify where price sits relative to the range.

**Settings**

Independent visibility toggles for CHoCH, BoS, FVG, and Premium/Discount, show only what you need.
Swing lookback and break confirmation mode (close or wick) for structure detection.
FVG mitigation mode (first touch or full fill), max extension in bars, and option to hide inactive gaps.
Fully customizable colors, line styles, and opacity for every element.
Built-in alerts for bullish and bearish CHoCH and BoS events.

Design principles
Every rule the indicator uses is documented in the script header. Pivots do not repaint, swings are consumed once broken, and signals are drawn on the bar of confirmation, what you see live is what you see in backtest.
Designed for clarity on any timeframe and any market.

## Source Code

````pine
//@version=6
// This code is subject to the terms of the [Mozilla Public License]. Read more at https://www.mozilla.org/en-US/MPL/2.0/
// AvantCoin 2026.

indicator("SMC Toolkit - CHoCH, BoS, FVG, P/D [AvantCoin]", shorttitle = "Avant SMC Toolkit",
     overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ── Visibility ───────────────────────────────────────────────────────────────
grpShow          = "Visibility"
showCHoCH        = input.bool(true,  "Show CHoCH",               group = grpShow)
showBoS          = input.bool(true,  "Show BoS",                 group = grpShow)
showFVG          = input.bool(true,  "Show FVG",                 group = grpShow)
showPD           = input.bool(true,  "Show Premium/Discount",    group = grpShow)
showPivots       = input.bool(true,  "Mark confirmed swings",    group = grpShow)
showBiasLabel    = input.bool(true,  "Show current bias label (top-right)", group = grpShow,
     tooltip = "Displays BULLISH / BEARISH / NEUTRAL structure in the top-right corner.")

// ── Structure inputs ─────────────────────────────────────────────────────────
grpStruct = "Structure (CHoCH / BoS)"
pivotLen  = input.int(5, "Swing Lookback (bars L/R)", minval = 1, group = grpStruct,
     tooltip = "Bars required on each side of a pivot for it to be confirmed. Higher = fewer, more significant swings.")
breakMode = input.string("Close", "Break Confirmation", options = ["Close", "Wick"],
     group = grpStruct,
     tooltip = "Close = bar must close beyond the swing level. Wick = any touch counts.")

// ── FVG inputs ───────────────────────────────────────────────────────────────
grpFVG        = "Fair Value Gaps"
fvgMitigation = input.string("First Touch", "Mitigation",
     options = ["First Touch", "Full Fill"], group = grpFVG,
     tooltip = "First Touch = inactive as soon as price enters the zone. Full Fill = zone must be traded through completely.")
fvgMaxExtend  = input.int(10, "Max bars to extend", minval = 3, group = grpFVG,
     tooltip = "FVG stops extending after this many bars since formation unless mitigated or invalidated sooner.")
hideMitigated = input.bool(false, "Hide inactive FVGs", group = grpFVG)
maxFVGs       = input.int(20, "Max FVGs kept", minval = 1, maxval = 100, group = grpFVG)

fvgBullCol      = input.color(color.new(#089981, 80),    "FVG Bull fill",    group = grpFVG)
fvgBearCol      = input.color(color.new(#f23645, 80),    "FVG Bear fill",    group = grpFVG)
fvgMitigatedCol = input.color(color.new(color.gray, 90), "FVG Inactive",     group = grpFVG)

// ── Premium / Discount inputs ────────────────────────────────────────────────
grpPD = "Premium / Discount"
pdSource      = input.string("Every Pivot", "P/D Range Based On",
     options = ["Every Pivot", "Last CHoCH Only"], group = grpPD,
     tooltip = "Every Pivot = responsive (updates on every new swing)\nLast CHoCH Only = uses the swing points from the most recent Change of Character (higher-timeframe / structural feel)")
shadePD       = input.bool(true, "Shade zones", group = grpPD)

eqColor         = input.color(color.new(color.gray, 30), "Equilibrium line", group = grpPD)
premiumCol      = input.color(color.new(#f23645, 93),    "Premium zone",     group = grpPD)
discountCol     = input.color(color.new(#089981, 93),    "Discount zone",    group = grpPD)

// ── Style inputs ─────────────────────────────────────────────────────────────
grpStyle        = "Style"
bosBullCol      = input.color(color.new(#089981, 0),     "BoS Bull",         group = grpStyle)
bosBearCol      = input.color(color.new(#f23645, 0),     "BoS Bear",         group = grpStyle)
chochBullCol    = input.color(color.new(#2962ff, 0),     "CHoCH Bull",       group = grpStyle)
chochBearCol    = input.color(color.new(#ff9800, 0),     "CHoCH Bear",       group = grpStyle)
lineStyleOpt    = input.string("Dashed", "Line Style",
     options = ["Solid","Dashed","Dotted"], group = grpStyle)
extendRight     = input.bool(false, "Extend broken levels right", group = grpStyle)

// ── Helpers ──────────────────────────────────────────────────────────────────
f_lineStyle(s) =>
    s == "Solid"  ? line.style_solid  :
     s == "Dashed" ? line.style_dashed :
     line.style_dotted
ls = f_lineStyle(lineStyleOpt)

// =============================================================================
// STRUCTURE: CHoCH & BoS
// =============================================================================

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,   pivotLen, pivotLen)

// Swing state (consumed on break)
var float lastSwingHigh   = na
var int   lastSwingHighX  = na
var bool  swingHighActive = false

var float lastSwingLow    = na
var int   lastSwingLowX   = na
var bool  swingLowActive  = false

var int   trend = 0  // 1 bull, -1 bear, 0 undefined

// Range pivots for P/D — updated on EVERY new pivot (default mode)
var float rangeHigh  = na
var int   rangeHighX = na
var float rangeLow   = na
var int   rangeLowX  = na

// NEW: Structural range based on LAST CHoCH (alternative P/D mode)
var float chochHigh  = na
var int   chochHighX = na
var float chochLow   = na
var int   chochLowX  = na

if not na(ph)
    lastSwingHigh   := ph
    lastSwingHighX  := bar_index - pivotLen
    swingHighActive := true
    rangeHigh       := ph
    rangeHighX      := bar_index - pivotLen
    if showPivots
        label.new(lastSwingHighX, ph, "●",
             color = color.new(color.gray, 100),
             textcolor = color.new(color.gray, 30),
             style = label.style_label_down, size = size.tiny)

if not na(pl)
    lastSwingLow    := pl
    lastSwingLowX   := bar_index - pivotLen
    swingLowActive  := true
    rangeLow        := pl
    rangeLowX       := bar_index - pivotLen
    if showPivots
        label.new(lastSwingLowX, pl, "●",
             color = color.new(color.gray, 100),
             textcolor = color.new(color.gray, 30),
             style = label.style_label_up, size = size.tiny)

// Break detection
brokeHigh = swingHighActive and
     (breakMode == "Close" ? close > lastSwingHigh : high > lastSwingHigh)
brokeLow  = swingLowActive  and
     (breakMode == "Close" ? close < lastSwingLow  : low  < lastSwingLow)

f_drawBreak(x1, y, txt, col) =>
    line.new(x1, y, bar_index, y, color = col, style = ls, width = 2,
         extend = extendRight ? extend.right : extend.none)
    label.new(bar_index, y, txt,
         color = color.new(col, 85), textcolor = col,
         style = label.style_label_left, size = size.small)

// Simultaneous breaks: resolve by most recent pivot
bullFirst = brokeHigh and brokeLow ? lastSwingHighX >= lastSwingLowX : brokeHigh
bearFirst = brokeHigh and brokeLow ? lastSwingLowX  >  lastSwingHighX : brokeLow

bosBull   = false
bosBear   = false
chochBull = false
chochBear = false

if bullFirst
    isChoCH = trend == -1
    chochBull := isChoCH
    bosBull   := not isChoCH
    shouldDraw = (isChoCH and showCHoCH) or (not isChoCH and showBoS)
    if shouldDraw
        col = isChoCH ? chochBullCol : bosBullCol
        txt = isChoCH ? "CHoCH" : "BoS"
        f_drawBreak(lastSwingHighX, lastSwingHigh, txt, col)
    trend := 1
    swingHighActive := false

if bearFirst
    isChoCH = trend == 1
    chochBear := isChoCH
    bosBear   := not isChoCH
    shouldDraw = (isChoCH and showCHoCH) or (not isChoCH and showBoS)
    if shouldDraw
        col = isChoCH ? chochBearCol : bosBearCol
        txt = isChoCH ? "CHoCH" : "BoS"
        f_drawBreak(lastSwingLowX, lastSwingLow, txt, col)
    trend := -1
    swingLowActive := false

// Snapshot the swing range on any CHoCH - shared by both branches above.
// lastSwingHigh / lastSwingLow still hold the pre-break values here, so this
// captures the range of the move that just reversed.
if chochBull or chochBear
    chochHigh  := lastSwingHigh
    chochHighX := lastSwingHighX
    chochLow   := lastSwingLow
    chochLowX  := lastSwingLowX

// =============================================================================
// FAIR VALUE GAPS
// =============================================================================

type FVG
    box   b
    float top
    float bot
    bool  isBull
    bool  mitigated
    int   formedBar

var array<FVG> fvgList = array.new<FVG>()

if showFVG
    // Detect bullish FVG
    if low > high[2]
        gTop = low
        gBot = high[2]
        bx = box.new(bar_index - 2, gTop, bar_index, gBot,
             bgcolor = fvgBullCol,
             border_color = color.new(fvgBullCol, 50))
        array.push(fvgList, FVG.new(bx, gTop, gBot, true, false, bar_index))

    // Detect bearish FVG
    if high < low[2]
        gTop = low[2]
        gBot = high
        bx = box.new(bar_index - 2, gTop, bar_index, gBot,
             bgcolor = fvgBearCol,
             border_color = color.new(fvgBearCol, 50))
        array.push(fvgList, FVG.new(bx, gTop, gBot, false, false, bar_index))

    // Cap total FVGs
    while array.size(fvgList) > maxFVGs
        old = array.shift(fvgList)
        box.delete(old.b)

    // Mitigation logic
    if array.size(fvgList) > 0
        for i = 0 to array.size(fvgList) - 1
            f = array.get(fvgList, i)
            if not f.mitigated
                age = bar_index - f.formedBar

                priceMit = age >= 1 and
                     (fvgMitigation == "First Touch" ?
                          (f.isBull ? low <= f.top : high >= f.bot) :
                          (f.isBull ? low <= f.bot : high >= f.top))

                timeMit = age >= fvgMaxExtend
                structMit = (f.isBull and chochBear) or (not f.isBull and chochBull)

                box.set_right(f.b, bar_index)

                if priceMit or timeMit or structMit
                    f.mitigated := true
                    if hideMitigated
                        box.delete(f.b)
                    else
                        box.set_bgcolor(f.b, fvgMitigatedCol)
                        box.set_border_color(f.b, color.new(fvgMitigatedCol, 50))

// =============================================================================
// PREMIUM / DISCOUNT ZONES
// =============================================================================

var line eqLine      = na
var box  premiumBox  = na
var box  discountBox = na

// Choose which range to use based on user setting
useHigh   = pdSource == "Every Pivot" ? rangeHigh  : chochHigh
useHighX  = pdSource == "Every Pivot" ? rangeHighX : chochHighX
useLow    = pdSource == "Every Pivot" ? rangeLow   : chochLow
useLowX   = pdSource == "Every Pivot" ? rangeLowX  : chochLowX

// Trigger redraw when the chosen range actually changes
rangeChanged = (not na(ph)) or (not na(pl))
chochChanged = chochBull or chochBear
pdChanged    = pdSource == "Every Pivot" ? rangeChanged : chochChanged

if showPD and pdChanged and not na(useHigh) and not na(useLow)
    if not na(eqLine)
        line.delete(eqLine)
    if not na(premiumBox)
        box.delete(premiumBox)
    if not na(discountBox)
        box.delete(discountBox)

    mid    = (useHigh + useLow) / 2
    startX = math.max(useHighX, useLowX)

    eqLine := line.new(startX, mid, bar_index, mid,
         color = eqColor, style = line.style_dashed, extend = extend.right)

    if shadePD
        premiumBox  := box.new(startX, useHigh, bar_index, mid,
             bgcolor = premiumCol,
             border_color = color.new(premiumCol, 100),
             extend = extend.right)
        discountBox := box.new(startX, mid, bar_index, useLow,
             bgcolor = discountCol,
             border_color = color.new(discountCol, 100),
             extend = extend.right)

// =============================================================================
// CURRENT BIAS LABEL (top-right)
// =============================================================================
var table biasTable = table.new(position.top_right, 1, 1,
     bgcolor = color.new(color.black, 85), border_width = 1, border_color = color.gray)

if barstate.islast
    if showBiasLabel
        string labelText = trend == 1 ? "🟢 BULLISH STRUCTURE" :
                           trend == -1 ? "🔴 BEARISH STRUCTURE" : "⚪ NEUTRAL"
        color labelCol   = trend == 1 ? bosBullCol :
                           trend == -1 ? bosBearCol : color.gray
        table.cell(biasTable, 0, 0, labelText,
             text_color = color.white,
             text_size = size.small,
             bgcolor = color.new(labelCol, 70))
    else
        table.clear(biasTable, 0, 0, 0, 0)

// =============================================================================
// ALERTS
// =============================================================================
alertcondition(bosBull,   title = "BoS Bullish",   message = "BoS Bullish on {{ticker}} ({{interval}})")
alertcondition(bosBear,   title = "BoS Bearish",   message = "BoS Bearish on {{ticker}} ({{interval}})")
alertcondition(chochBull, title = "CHoCH Bullish", message = "CHoCH Bullish on {{ticker}} ({{interval}})")
alertcondition(chochBear, title = "CHoCH Bearish", message = "CHoCH Bearish on {{ticker}} ({{interval}})")
````
