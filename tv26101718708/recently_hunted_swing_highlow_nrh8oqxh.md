# Recently Hunted Swing High/Low

- url: https://www.tradingview.com/script/nRh8oQxh-Recently-Hunted-Swing-High-Low/
- type: indicator
- pine_id: PUB;28e46491ac59464aa43763b64211e9de
- version: 7.0

## Description

[b]Recently Hunted Swing High/Low[/b]

This indicator identifies and marks the most recently hunted swing high and swing low on your chart. A swing is considered "hunted" when price sweeps beyond it — taking the liquidity resting above or below — and then reverses back. This is a common price action concept used in ICT and Smart Money trading to identify liquidity grabs and potential reversal zones.

[b]What is a hunted swing?[/b]

A hunted swing high occurs when price sweeps above a prior swing high, taking the liquidity sitting above it, and then closes back below that level. A hunted swing low is the mirror — price sweeps below a prior swing low and closes back above it.

[b]Two hunt scenarios are detected[/b]

The first is a direct sweep, where price wicks or trades beyond the swing level and closes back on the other side in one move. The second is an indirect sweep, where a new higher swing high (or lower swing low) forms beyond the previous one, confirming the old level was swept. The old swing is then marked hunted when price later closes back through it.

[b]How lines are managed[/b]

Only one line per direction is shown at any time — the most recently hunted swing high in red and swing low in teal. The line starts from the original swing bar and extends to the current candle. When price revisits the hunted level, the line is automatically removed, keeping your chart clean.

Works on any instrument and timeframe. Best used alongside a swing high/low dots indicator for full context.

## Source Code

````pine
//@version=6
indicator("Recently Hunted Swing High/Low", overlay=true)

// === Inputs ===
shColor   = input.color(color.red,              "Hunted Swing High Color")
slColor   = input.color(color.teal,             "Hunted Swing Low Color")
lineWidth = input.int(2, "Line Width",           minval=1, maxval=4)
styleOpt  = input.string("dashed", "Line Style", options=["solid", "dashed", "dotted"])
swingBars = input.int(2, "Swing Bars (Lookback & Lookahead)", minval=1, maxval=10)
swingLB   = swingBars
swingLA   = swingBars
showDots  = input.bool(false, "Show Swing Dots", group="Swing Dots")
dotSize   = input.string("small", "Dot Size", options=["tiny", "small", "normal", "large", "huge"], group="Swing Dots")

lstyle = switch styleOpt
    "solid"  => line.style_solid
    "dashed" => line.style_dashed
    => line.style_dotted

// === Swing Detection — configurable lookback/lookahead ===
// Center bar is at bar[swingLA]; check swingLB bars left and swingLA bars right.

isSwingHigh = true
for j = 1 to swingLB
    if high[swingLA + j] >= high[swingLA]
        isSwingHigh := false
        break
for j = 0 to swingLA - 1
    if high[j] >= high[swingLA]
        isSwingHigh := false
        break

isSwingLow = true
for j = 1 to swingLB
    if low[swingLA + j] <= low[swingLA]
        isSwingLow := false
        break
for j = 0 to swingLA - 1
    if low[j] <= low[swingLA]
        isSwingLow := false
        break

// Equal pairs: two adjacent equal highs/lows that dominate all surrounding bars
isEqualHighPair = high[swingLA + 1] == high[swingLA]
for j = 0 to swingLA - 1
    if high[j] >= high[swingLA]
        isEqualHighPair := false
        break
for j = 2 to swingLB + 1
    if high[swingLA + j] >= high[swingLA]
        isEqualHighPair := false
        break

isEqualLowPair = low[swingLA + 1] == low[swingLA]
for j = 0 to swingLA - 1
    if low[j] <= low[swingLA]
        isEqualLowPair := false
        break
for j = 2 to swingLB + 1
    if low[swingLA + j] <= low[swingLA]
        isEqualLowPair := false
        break

isMarkHigh = isSwingHigh or isEqualHighPair
isMarkLow  = isSwingLow  or isEqualLowPair

// ═══════════════════════════════════════════════════════════════════
// SWING HIGH HUNT STATE
//
// Two candidates are tracked simultaneously:
//   lastSH    — the most recent swing high, watching for a direct sweep
//   pendingSH — an older SH that was indirectly swept when a NEW HIGHER
//               swing high formed above it; waiting for close-below confirmation
//
// Hunt conditions:
//   Direct:  price sweeps above lastSH (high > lastSH) then closes below it
//   Pending: a newer, higher SH formed above pendingSH (indirectly sweeping it);
//            confirmed hunted when price closes below pendingSH
// ═══════════════════════════════════════════════════════════════════
var float lastSH      = na
var int   lastSH_i    = na
var bool  shSwept     = false
var float pendingSH   = na
var int   pendingSH_i = na
var line  huntSHLine  = na
var float huntSH_lvl  = na
var int   huntSH_bar  = na

// ═══════════════════════════════════════════════════════════════════
// SWING LOW HUNT STATE  (mirror of above)
// ═══════════════════════════════════════════════════════════════════
var float lastSL      = na
var int   lastSL_i    = na
var bool  slSwept     = false
var float pendingSL   = na
var int   pendingSL_i = na
var line  huntSLLine  = na
var float huntSL_lvl  = na
var int   huntSL_bar  = na

// ─── SWING HIGH LOGIC ───────────────────────────────────────────────────────

// Step 1 — new swing high confirmed
if isMarkHigh
    if not na(lastSH) and high[swingLA] > lastSH
        if na(pendingSH) or lastSH < pendingSH
            pendingSH   := lastSH
            pendingSH_i := lastSH_i
    lastSH   := high[swingLA]
    lastSH_i := bar_index - swingLA
    shSwept  := false

// Step 2 — mitigation: price closes above the hunted SH level → remove line
if not na(huntSH_lvl) and close >= huntSH_lvl and bar_index > huntSH_bar
    line.delete(huntSHLine)
    huntSHLine := na
    huntSH_lvl := na
    huntSH_bar := na

// Step 2b — check if pending SH is now confirmed hunted
shHunted = not na(pendingSH) and close < pendingSH
if shHunted
    line.delete(huntSHLine)
    huntSHLine := line.new(math.max(pendingSH_i, bar_index - 499), pendingSH, bar_index, pendingSH,
         color=shColor, width=lineWidth, style=lstyle)
    huntSH_lvl := pendingSH
    huntSH_bar := bar_index
    pendingSH  := na

// Step 3 — mark sweep when price trades above the current SH
if not na(lastSH) and high > lastSH
    shSwept := true

// Step 4 — confirm hunt: swept and now closed back below
shHuntedDirect = shSwept and not na(lastSH) and close < lastSH
if shHuntedDirect
    line.delete(huntSHLine)
    huntSHLine := line.new(math.max(lastSH_i, bar_index - 499), lastSH, bar_index, lastSH,
         color=shColor, width=lineWidth, style=lstyle)
    huntSH_lvl := lastSH
    huntSH_bar := bar_index
    lastSH     := na
    shSwept    := false

// Step 5 — extend visible line to the current bar every tick
if not na(huntSHLine)
    line.set_x2(huntSHLine, bar_index)

// ─── SWING LOW LOGIC ────────────────────────────────────────────────────────

// Step 1 — new swing low confirmed
if isMarkLow
    if not na(lastSL) and low[swingLA] < lastSL
        if na(pendingSL) or lastSL > pendingSL
            pendingSL   := lastSL
            pendingSL_i := lastSL_i
    lastSL   := low[swingLA]
    lastSL_i := bar_index - swingLA
    slSwept  := false

// Step 2 — mitigation: price closes below the hunted SL level → remove line
if not na(huntSL_lvl) and close <= huntSL_lvl and bar_index > huntSL_bar
    line.delete(huntSLLine)
    huntSLLine := na
    huntSL_lvl := na
    huntSL_bar := na

// Step 2b — check if pending SL is now confirmed hunted
slHunted = not na(pendingSL) and close > pendingSL
if slHunted
    line.delete(huntSLLine)
    huntSLLine := line.new(math.max(pendingSL_i, bar_index - 499), pendingSL, bar_index, pendingSL,
         color=slColor, width=lineWidth, style=lstyle)
    huntSL_lvl := pendingSL
    huntSL_bar := bar_index
    pendingSL  := na

// Step 3 — mark sweep when price trades below the current SL
if not na(lastSL) and low < lastSL
    slSwept := true

// Step 4 — confirm hunt: swept and now closed back above
slHuntedDirect = slSwept and not na(lastSL) and close > lastSL
if slHuntedDirect
    line.delete(huntSLLine)
    huntSLLine := line.new(math.max(lastSL_i, bar_index - 499), lastSL, bar_index, lastSL,
         color=slColor, width=lineWidth, style=lstyle)
    huntSL_lvl := lastSL
    huntSL_bar := bar_index
    lastSL     := na
    slSwept    := false

// Step 5 — extend visible line to the current bar every tick
if not na(huntSLLine)
    line.set_x2(huntSLLine, bar_index)

// === Swing Dots ===
plotshape(showDots and isMarkLow  and dotSize == "tiny",   style=shape.circle, location=location.belowbar, color=slColor, size=size.tiny,   offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkLow  and dotSize == "small",  style=shape.circle, location=location.belowbar, color=slColor, size=size.small,  offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkLow  and dotSize == "normal", style=shape.circle, location=location.belowbar, color=slColor, size=size.normal, offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkLow  and dotSize == "large",  style=shape.circle, location=location.belowbar, color=slColor, size=size.large,  offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkLow  and dotSize == "huge",   style=shape.circle, location=location.belowbar, color=slColor, size=size.huge,   offset=-swingBars, editable=false, display=display.pane)

plotshape(showDots and isMarkHigh and dotSize == "tiny",   style=shape.circle, location=location.abovebar, color=shColor, size=size.tiny,   offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkHigh and dotSize == "small",  style=shape.circle, location=location.abovebar, color=shColor, size=size.small,  offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkHigh and dotSize == "normal", style=shape.circle, location=location.abovebar, color=shColor, size=size.normal, offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkHigh and dotSize == "large",  style=shape.circle, location=location.abovebar, color=shColor, size=size.large,  offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkHigh and dotSize == "huge",   style=shape.circle, location=location.abovebar, color=shColor, size=size.huge,   offset=-swingBars, editable=false, display=display.pane)

// === Alerts ===
alertcondition(shHunted or shHuntedDirect, "Swing High Hunted", "Swing High has been hunted")
alertcondition(slHunted or slHuntedDirect, "Swing Low Hunted",  "Swing Low has been hunted")
alertcondition(shHunted or shHuntedDirect or slHunted or slHuntedDirect, "Any Swing Hunted", "A swing high or low has been hunted")
````
