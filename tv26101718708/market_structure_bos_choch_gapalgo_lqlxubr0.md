# Market Structure BOS CHoCH [GapAlgo]

- url: https://www.tradingview.com/script/lQLXUBR0-Market-Structure-BOS-CHoCH-GapAlgo/
- type: indicator
- pine_id: PUB;a6f773deb7d24b5888d9d22b5e653e9a
- version: 1.0

## Description

This indicator maps market structure the way price action traders read it by hand: it labels every confirmed swing as a higher high, lower high, higher low or lower low, then marks the moment price breaks a swing. A break in the direction of the current structure is a Break of Structure (BOS). The first break against it is a Change of Character (CHoCH), which flips the structure from bullish to bearish or back. Candles are colored by the current structure, so the trend reads at a glance on any market and any timeframe.

After every break the script also projects two levels. The strong level is the extreme of the leg that produced the break, found by scanning back to the swing that was broken: in a bullish structure it is the low buyers defended, and a close below it would be the next CHoCH. The weak level is the running extreme since the break, the next level the trend has to take out. Both extend to the right of the last bar and update as new breaks print.

Nothing here is drawn in hindsight. A swing is only confirmed after Swing Length bars on each side, and it is labeled at its own bar only once that confirmation is complete. Breaks are evaluated on closed candles only, so a BOS or CHoCH that appears on the chart does not disappear. A newly confirmed swing can never be broken on the same bar it confirms, because by definition every bar after it traded below it (or above it for a low).

[i]Break Confirmation set to Candle Close requires a candle to close beyond the swing, which ignores wicks that only run stops. Wick counts any trade beyond the swing and reacts sooner, at the cost of more breaks that reverse.[/i]

[b]Settings[/b]

[i]Structure[/i]
[list]
[*]Swing Length: Bars on each side that confirm a swing high or low. Larger values follow bigger swings and give fewer, more significant breaks.
[*]Break Confirmation: Candle Close or Wick, as described above.
[/list]

[i]Display[/i]
[list]
[*]Show HH / HL / LH / LL Labels: Labels each confirmed swing against the previous swing on the same side.
[*]Show BOS / CHoCH Lines: Draws a line from the broken swing to the breaking candle. BOS lines are dashed, CHoCH lines are solid.
[*]Show Strong and Weak Levels: Projects the strong and weak level from the latest break.
[*]Color Candles by Structure: Bullish, bearish or neutral (before the first break).
[*]Tint Background by Structure: A light background tint in the structure color.
[/list]

[i]Dashboard[/i]
[list]
[*]Shows the current structure, the last break and how many bars ago it printed, the strong level and the swing settings in use.
[/list]

[b]Alerts[/b]

Bullish BOS, Bearish BOS, Bullish CHoCH, Bearish CHoCH, and Any structure break. All alerts fire once a candle closes.

[b]How to use it[/b]

A bullish structure with the latest break a BOS means buyers are still making higher highs. A CHoCH is the first sign that has changed, not a guarantee that it has. Many traders wait for a CHoCH on a higher timeframe before taking breaks in the new direction on a lower one. The strong level is where the current read is proven wrong.

This indicator describes what price has done. It does not predict what it will do next and is not financial advice.

## Source Code

````pine
//@version=6
indicator("Market Structure BOS CHoCH [GapAlgo]", "Market Structure", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 500)

// ───────────────────────── Inputs ─────────────────────────
grpS = "Structure"
swingLen   = input.int(5, "Swing Length", minval = 2, maxval = 50, group = grpS, tooltip = "Bars on each side that confirm a swing high or low. Larger values follow bigger swings and give fewer, more significant breaks.")
confirmBy  = input.string("Candle Close", "Break Confirmation", options = ["Candle Close", "Wick"], group = grpS, tooltip = "Candle Close: a break counts only when a candle closes beyond the swing. Wick: any trade beyond the swing counts. Close is stricter and filters out stop runs.")

grpD = "Display"
showSwings = input.bool(true, "Show HH / HL / LH / LL Labels", group = grpD)
showBreaks = input.bool(true, "Show BOS / CHoCH Lines", group = grpD)
showLevels = input.bool(true, "Show Strong and Weak Levels", group = grpD, tooltip = "The strong level is the extreme of the leg that caused the latest break, where the structure is defended. The weak level is the running extreme since the break, the next level the trend has to take out.")
paintBars  = input.bool(true, "Color Candles by Structure", group = grpD)
tintBg     = input.bool(false, "Tint Background by Structure", group = grpD)

grpC = "Colors"
bullCol = input.color(#00FFA3, "Bullish", group = grpC)
bearCol = input.color(#FF4D6D, "Bearish", group = grpC)
neutCol = input.color(#787B86, "Neutral", group = grpC)

grpT = "Dashboard"
showDash = input.bool(true, "Show Dashboard", group = grpT)
dashLoc  = input.string("Top Right", "Location", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpT)
dashSize = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal"], group = grpT)

// ───────────────────────── Swings ─────────────────────────
// A swing is confirmed swingLen bars after it prints, so it is only ever drawn
// once it is final. Nothing is placed in hindsight.
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastH    = na
var int   lastHBar = na
var bool  hTaken   = true
var float lastL    = na
var int   lastLBar = na
var bool  lTaken   = true
var float prevH    = na
var float prevL    = na
var int   trend    = 0

if not na(ph)
    phBar = bar_index - swingLen
    if showSwings and not na(prevH)
        label.new(phBar, ph, ph > prevH ? "HH" : "LH", color = color.new(color.black, 100), textcolor = color.new(ph > prevH ? bullCol : bearCol, 25), style = label.style_label_down, size = size.tiny)
    prevH    := ph
    lastH    := ph
    lastHBar := phBar
    hTaken   := false

if not na(pl)
    plBar = bar_index - swingLen
    if showSwings and not na(prevL)
        label.new(plBar, pl, pl > prevL ? "HL" : "LL", color = color.new(color.black, 100), textcolor = color.new(pl > prevL ? bullCol : bearCol, 25), style = label.style_label_up, size = size.tiny)
    prevL    := pl
    lastL    := pl
    lastLBar := plBar
    lTaken   := false

// ───────────────────────── Breaks ─────────────────────────
// BOS: a break in the direction of the current structure.
// CHoCH: the first break against it, which flips the structure.
upSrc = confirmBy == "Candle Close" ? close : high
dnSrc = confirmBy == "Candle Close" ? close : low
confirmed = barstate.isconfirmed

bullBOS   = false
bullCHoCH = false
bearBOS   = false
bearCHoCH = false

var float strongLvl = na
var float weakLvl   = na
var int   lastEvtBar = na
var string lastEvt   = "None yet"

if confirmed and not hTaken and not na(lastH) and upSrc > lastH
    hTaken := true
    isCh = trend == -1
    bullCHoCH := isCh
    bullBOS   := not isCh
    // the low of the leg that produced the break is where buyers defended
    lo = low
    span = math.min(bar_index - lastHBar, 300)
    for i = 0 to span
        lo := math.min(lo, low[i])
    strongLvl := lo
    weakLvl   := high
    trend     := 1
    lastEvtBar := bar_index
    lastEvt    := isCh ? "Bullish CHoCH" : "Bullish BOS"
    if showBreaks
        line.new(lastHBar, lastH, bar_index, lastH, color = color.new(bullCol, 20), style = isCh ? line.style_solid : line.style_dashed, width = 1)
        label.new(math.round((lastHBar + bar_index) / 2), lastH, isCh ? "CHoCH" : "BOS", color = color.new(color.black, 100), textcolor = bullCol, style = label.style_label_down, size = size.tiny)
else if confirmed and not lTaken and not na(lastL) and dnSrc < lastL
    lTaken := true
    isCh = trend == 1
    bearCHoCH := isCh
    bearBOS   := not isCh
    hi = high
    span = math.min(bar_index - lastLBar, 300)
    for i = 0 to span
        hi := math.max(hi, high[i])
    strongLvl := hi
    weakLvl   := low
    trend     := -1
    lastEvtBar := bar_index
    lastEvt    := isCh ? "Bearish CHoCH" : "Bearish BOS"
    if showBreaks
        line.new(lastLBar, lastL, bar_index, lastL, color = color.new(bearCol, 20), style = isCh ? line.style_solid : line.style_dashed, width = 1)
        label.new(math.round((lastLBar + bar_index) / 2), lastL, isCh ? "CHoCH" : "BOS", color = color.new(color.black, 100), textcolor = bearCol, style = label.style_label_up, size = size.tiny)

// The weak level follows the trend's running extreme after the break.
if trend == 1 and not na(weakLvl) and lastEvtBar != bar_index
    weakLvl := math.max(weakLvl, high)
if trend == -1 and not na(weakLvl) and lastEvtBar != bar_index
    weakLvl := math.min(weakLvl, low)

// ───────────────────────── Strong and weak levels ─────────────────────────
var line  lnStrong = na
var line  lnWeak   = na
var label lbStrong = na
var label lbWeak   = na
if showLevels and barstate.islast and trend != 0
    line.delete(lnStrong)
    line.delete(lnWeak)
    label.delete(lbStrong)
    label.delete(lbWeak)
    sCol = trend == 1 ? bullCol : bearCol
    wCol = trend == 1 ? bearCol : bullCol
    lnStrong := line.new(lastEvtBar, strongLvl, bar_index + 10, strongLvl, color = color.new(sCol, 30), width = 2)
    lnWeak   := line.new(lastEvtBar, weakLvl, bar_index + 10, weakLvl, color = color.new(wCol, 50), style = line.style_dotted, width = 1)
    lbStrong := label.new(bar_index + 10, strongLvl, trend == 1 ? "Strong Low" : "Strong High", color = color.new(color.black, 100), textcolor = sCol, style = label.style_label_left, size = size.small)
    lbWeak   := label.new(bar_index + 10, weakLvl, trend == 1 ? "Weak High" : "Weak Low", color = color.new(color.black, 100), textcolor = color.new(wCol, 20), style = label.style_label_left, size = size.small)

// ───────────────────────── Coloring ─────────────────────────
barcolor(paintBars ? (trend == 1 ? bullCol : trend == -1 ? bearCol : neutCol) : na)
bgcolor(tintBg ? (trend == 1 ? color.new(bullCol, 93) : trend == -1 ? color.new(bearCol, 93) : na) : na)

// ───────────────────────── Dashboard ─────────────────────────
tSize = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : size.small
tPos  = dashLoc == "Top Left" ? position.top_left : dashLoc == "Bottom Right" ? position.bottom_right : dashLoc == "Bottom Left" ? position.bottom_left : position.top_right
var table dash = table.new(tPos, 2, 4, bgcolor = color.new(#0B0F0D, 10), frame_color = color.new(neutCol, 60), frame_width = 1, border_color = color.new(neutCol, 80), border_width = 1)
if showDash and barstate.islast
    stTxt = trend == 1 ? "Bullish" : trend == -1 ? "Bearish" : "Waiting"
    stCol = trend == 1 ? bullCol : trend == -1 ? bearCol : neutCol
    ago   = na(lastEvtBar) ? "" : " · " + str.tostring(bar_index - lastEvtBar) + " bars ago"
    table.cell(dash, 0, 0, "Market Structure", text_color = color.white, text_size = tSize, text_halign = text.align_left)
    table.cell(dash, 1, 0, stTxt, text_color = stCol, text_size = tSize, text_halign = text.align_left)
    table.cell(dash, 0, 1, "Last break", text_color = color.gray, text_size = tSize, text_halign = text.align_left)
    table.cell(dash, 1, 1, lastEvt + ago, text_color = color.white, text_size = tSize, text_halign = text.align_left)
    table.cell(dash, 0, 2, trend == -1 ? "Strong high" : "Strong low", text_color = color.gray, text_size = tSize, text_halign = text.align_left)
    table.cell(dash, 1, 2, na(strongLvl) ? "" : str.tostring(strongLvl, format.mintick), text_color = color.white, text_size = tSize, text_halign = text.align_left)
    table.cell(dash, 0, 3, "Swing length", text_color = color.gray, text_size = tSize, text_halign = text.align_left)
    table.cell(dash, 1, 3, str.tostring(swingLen) + " · " + confirmBy, text_color = color.white, text_size = tSize, text_halign = text.align_left)

// ───────────────────────── Alerts ─────────────────────────
alertcondition(bullBOS,   "Bullish BOS",   "Bullish break of structure on {{ticker}} at {{close}}")
alertcondition(bearBOS,   "Bearish BOS",   "Bearish break of structure on {{ticker}} at {{close}}")
alertcondition(bullCHoCH, "Bullish CHoCH", "Bullish change of character on {{ticker}} at {{close}}")
alertcondition(bearCHoCH, "Bearish CHoCH", "Bearish change of character on {{ticker}} at {{close}}")
alertcondition(bullBOS or bearBOS or bullCHoCH or bearCHoCH, "Any structure break", "Structure break on {{ticker}} at {{close}}")
````
