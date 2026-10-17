# {SCA} | Weekend Gap Indicator

- url: https://www.tradingview.com/script/Uljb539Y-SCA-Weekend-Gap-Indicator/
- type: indicator
- pine_id: PUB;3f6fafa793c5410db20efbb613e88d92
- version: 1.0

## Description

🟠 [b]WHAT IT DOES[/b]
Crypto trades through the weekend, but price still drifts away from
where it closed on Friday — and it tends to come back. This tool marks
that weekend gap on any coin, shows the level price tends to return to,
and tracks whether the gap fills.

🟠 [b]WHAT MAKES IT DIFFERENT[/b]
- Weekend-only fill. The gap is shaded across the weekend itself and
  stops there, so the chart stays clean — no zones stretching across
  the whole week.
- A dashed fill line. The Friday close is marked with a dashed line,
  the level the gap has to return to. It runs forward until price fills
  it, so the target is always in view.
- A live fill-rate counter. On whatever chart you load, the tool tallies
  how many weekend gaps have formed and how many filled — so you can
  check the tendency yourself instead of taking anyone's word for it.

🟠 [b]WHAT YOU SEE[/b]
- A shaded weekend gap, coloured by direction, fading with its size.
- A dashed line at the Friday close, labelled with the gap size in
  percent, that updates to "filled" once price returns.
- A small fill-rate table in the corner (gaps counted / gaps filled).

🟠 [b]SETTINGS THAT MATTER[/b]
- Week timezone — defines where Friday and Monday fall (UTC is the
  crypto convention).
- Colours and fill opacity — set the look to taste.
Everything else is cosmetic.

🟠 [b]ALERTS[/b]
- New weekend gap — fires when a fresh gap forms.
- Gap filled — fires when price returns to the Friday close.
Tip: enable Play sound in the alert's Notifications tab for an audible alert.

🟠 H[b]OW TO USE IT[/b]
Weekend gaps tend to fill, so the dashed line gives you a high-probability
target and a directional bias. It does not tell you when, or that the path
there is clean — use it to lean, not to bet the account, and apply your own
risk management.

This indicator is a tool for analysis and education. It is not financial
advice and does not predict price. Past tendencies do not guarantee future
results.

Swallow Academy

## Source Code

````pine
//@version=6
// SCA Weekend Gap Indicator  —  Swallow Crypto Academy (original work)
// CME-gap style: the coloured gap fill covers the WEEKEND only; a dashed Friday-close
// line marks the fill level (the low of a gap-up / high of a gap-down) and runs until
// price fills it. Works on ANY coin. Built for CPS Setup 3 (fill) & Setup 4 (post-gap break).
// NOTE: written without a Pine compiler available — treat as a TEST CANDIDATE.
indicator("SCA Weekend Gap Indicator", "SCA Gap", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ===================== Inputs =====================
grpG = "Gap"
tzInput   = input.string("UTC", "Week timezone", group = grpG, tooltip = "Defines where Friday/Monday fall. Crypto convention is UTC.")
showLine  = input.bool(true, "Dashed fill-level line", group = grpG)
showLabel = input.bool(true, "Label (gap % + status)", group = grpG)
showStats = input.bool(true, "Fill-rate stats table", group = grpG)

grpC = "Colours"
upCol       = input.color(#E24B4A, "Gap up fill",       group = grpC)
dnCol       = input.color(#22C55E, "Gap down fill",     group = grpC)
refCol      = input.color(#C8A44B, "Fill-level line",   group = grpC)
fillOpacity = input.int(70, "Weekend fill opacity", minval = 0, maxval = 100, group = grpC, tooltip = "0 = solid, 100 = invisible.")
maxGapPct   = input.float(5.0, "Gap size for full colour (%)", minval = 0.5, step = 0.5, group = grpC)

// ===================== Week detection =====================
dow     = dayofweek(time, tzInput)
dowPrev = dayofweek(time[1], tzInput)

var float friClose    = na
var int   friBar      = na
var bool  haveFri     = false
var line  tline       = na
var bool  gapOpen     = false
var bool  weekStarted = false
var bool  gapUp       = false
var float gPct        = na
var label gLab        = na
var int   totGaps     = 0
var int   totFilled   = 0

// weekend begins (Friday -> Saturday): capture Friday close, start dashed fill-level line
if dow == dayofweek.saturday and dowPrev == dayofweek.friday
    friClose := close[1]
    friBar   := bar_index - 1
    haveFri  := true
    if not na(gLab)
        label.delete(gLab)
        gLab := na
    tline       := line.new(friBar, friClose, bar_index, friClose, color = showLine ? refCol : color.new(refCol, 100), width = 1, style = line.style_dashed)
    gapOpen     := true
    weekStarted := false

// week begins (-> Monday): lock direction/% and start fill checks
bool newGapAlert    = false
bool gapFilledAlert = false
if dow == dayofweek.monday and dowPrev != dayofweek.monday and gapOpen
    gapUp       := close > friClose
    gPct        := (close - friClose) / friClose * 100.0
    weekStarted := true
    totGaps     += 1
    newGapAlert := true
    if showLabel
        gLab := label.new(bar_index, friClose, "Weekend Gap " + str.tostring(gPct, "#.#") + "%", style = label.style_label_left, color = color.new(gapUp ? upCol : dnCol, 25), textcolor = color.white, size = size.small)

// dashed line runs until the gap fills (price returns to the Friday close)
if gapOpen and not na(tline)
    line.set_x2(tline, bar_index)
    if weekStarted
        bool filled = gapUp ? low <= friClose : high >= friClose
        if filled
            line.set_x2(tline, bar_index)
            gapOpen        := false
            totFilled      += 1
            gapFilledAlert := true
            if showLabel and not na(gLab)
                label.set_text(gLab, "Weekend Gap " + str.tostring(gPct, "#.#") + "%  ✓ filled")
                label.set_x(gLab, bar_index)

// ===================== Alerts =====================
alertcondition(newGapAlert,    "New weekend gap", "A new weekend gap has formed")
alertcondition(gapFilledAlert, "Gap filled",      "A weekend gap has filled")

// ===================== Weekend-only gradient fill =====================
isWknd = (dow == dayofweek.saturday or dow == dayofweek.sunday) and haveFri
pRef = plot(isWknd ? friClose : na, "ref",   color = color.new(color.white, 100), style = plot.style_linebr)
pNow = plot(isWknd ? close    : na, "price", color = color.new(color.white, 100), style = plot.style_linebr)

gFrac = isWknd and not na(friClose) ? math.abs(close - friClose) / friClose * 100.0 : 0.0
inten = math.min(gFrac, maxGapPct) / maxGapPct
base  = (not na(friClose) and close > friClose) ? upCol : dnCol
fcol  = color.from_gradient(inten, 0, 1, color.new(base, math.min(96, fillOpacity + 22)), color.new(base, fillOpacity))
fill(pRef, pNow, color = isWknd ? fcol : na)

// ===================== Stats table =====================
var table st = table.new(position.top_right, 1, 2, bgcolor = color.new(#131313, 10), border_color = #1f1f1f, border_width = 1)
if showStats and barstate.islast
    float fr = totGaps > 0 ? 100.0 * totFilled / totGaps : 0.0
    table.cell(st, 0, 0, "Weekend gaps: " + str.tostring(totGaps), text_color = #C8A44B, text_size = size.small)
    table.cell(st, 0, 1, "Filled: " + str.tostring(totFilled) + "  (" + str.tostring(fr, "#") + "%)", text_color = color.white, text_size = size.small)
````
