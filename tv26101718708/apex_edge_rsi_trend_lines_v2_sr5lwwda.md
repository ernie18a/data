# Apex Edge - RSI Trend Lines v2

- url: https://www.tradingview.com/script/SR5lwwDa-Apex-Edge-RSI-Trend-Lines-v2/
- type: indicator
- pine_id: PUB;27e0d35bcb874ced9852757e96c976ea
- version: 1.0

## Description

APEX EDGE · RSI TREND LINES v2

Trend lines drawn on RSI itself, not on price. RSI often breaks its own trend line before price breaks structure, so a line break on RSI is an early sign that momentum is turning.

━━━━━━━━━━━━━━━━━━━━
WHAT'S NEW IN v2
━━━━━━━━━━━━━━━━━━━━
- Rebuilt from scratch in Pine v6.
- Historical lines: broken lines now stay on the pane (faded) so you can review how RSI behaved around past breaks. This was the most requested feature from v1.
- Lines are validated: a line is only drawn if RSI respected it between its two pivots.
- Break markers on the RSI pane, with optional markers on the price chart.
- Alerts through a single "Any alert() function call" alert, plus classic alert conditions.

━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━
- Resistance lines join LOWER RSI highs. Support lines join HIGHER RSI lows ("Trend only" mode). "All slopes" mode joins any two consecutive pivots, as in v1.
- A pivot is confirmed after "Pivot lookback" bars on each side, so every line appears with that delay by design.
- A break = a CLOSED candle with RSI beyond the line. The line stops at the break, a ◆ marks it, and it stays on the pane as history.
- Resistance broken = RSI momentum turning up. Support broken = RSI momentum turning down.

━━━━━━━━━━━━━━━━━━━━
NON-REPAINT
━━━━━━━━━━━━━━━━━━━━
Pivots are confirmed bars after they form, and every line, break and alert commits on closed candles only. What you see on history is what you would have seen live.

━━━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━━━
- RSI length and source.
- Pivot lookback (default 10): the setting that matters most. Lower = more lines and earlier breaks; higher = fewer, stronger lines. Many intraday traders run 5 to 6 on the 5m and 15m for faster signals.
- Line type: Trend only / All slopes.
- Extend active lines to the right, max bars between pivots, lines kept per side.
- Keep broken lines, history transparency, colours and widths.
- Upper / lower levels (70 / 30), 50 midline, shading beyond the levels.
- Break markers on the RSI pane and/or price chart.

━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━
Create ONE alert on this indicator with "Any alert() function call". The tick boxes in settings choose what it sends:
- RSI broke resistance
- RSI broke support
- New line formed (off by default)
Classic alert conditions for each break are also available. All alerts fire on candle close.

━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━
An RSI line break is a momentum signal, not a trade on its own. It works best as confirmation at a level you already care about: a sweep of a key high or low, a zone, or a session level. Wait for price to reach your level, then use the break in your trade direction as the trigger. Always use a stop.

Each asset runs differently on the chart.  Adjust the settings as required until the arrows match up roughly with past price direction.

━━━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━━━
For education and analysis only. Not financial advice. No indicator predicts the market; past behaviour on a chart does not guarantee future results. Trade at your own risk.

## Source Code

````pine
//@version=6
// =============================================================================
//  APEX EDGE · RSI TREND LINES  ·  v2.0  ·  2026-09-29
//  © Apex Edge. Original code.
// -----------------------------------------------------------------------------
//  Trend lines drawn on RSI itself. Resistance joins lower RSI highs, support
//  joins higher RSI lows. A line is only kept if RSI respected it between its
//  two pivots. A break = a CLOSED candle with RSI beyond the line; the line
//  then stops at the break and stays on the pane as history.
//
//  NON-REPAINT: pivots are confirmed 'lookback' bars later (by definition) and
//  every line, break and alert commits on closed candles only.
// =============================================================================
indicator("Apex Edge - RSI Trend Lines", "AE RSI TL", overlay = false, max_lines_count = 500, max_labels_count = 500)

// ============================================================================= INPUTS
const string G_R = "1 · RSI"
const string G_L = "2 · Trend lines"
const string G_V = "3 · Levels & look"
const string G_A = "4 · Alerts"

int    rsiLen   = input.int(14, "RSI length", minval = 2, group = G_R)
float  src      = input.source(close, "Source", group = G_R)

int    lb       = input.int(10, "Pivot lookback", minval = 2, maxval = 50, group = G_L, tooltip = "Bars each side needed to confirm an RSI pivot. A pivot is only known this many bars after it forms, so lines appear with that delay. Lower = more, earlier lines; higher = fewer, stronger lines.")
string lineMode = input.string("Trend only", "Line type", options = ["Trend only", "All slopes"], group = G_L, tooltip = "Trend only: resistance through LOWER highs, support through HIGHER lows (classic RSI trend lines).\nAll slopes: any two consecutive pivots are joined, as in v1.")
bool   extAct   = input.bool(true, "Extend active lines to the right", group = G_L, tooltip = "On: active lines run to the current bar until they break. Off: lines stop at their second pivot (breaks are still detected and marked).")
int    maxSpan  = input.int(200, "Max bars between the two pivots", minval = 20, maxval = 1000, group = G_L, tooltip = "Pivots further apart than this are not joined.")
bool   showHist = input.bool(true, "Keep broken lines (history)", group = G_L)
int    keepN    = input.int(5, "Lines kept per side", minval = 1, maxval = 50, group = G_L, tooltip = "Newest lines kept for resistance and for support, active and broken together. Older ones are removed.")
bool   showBrk  = input.bool(true, "Mark breaks on the RSI pane (◆)", group = G_L)
bool   showPx   = input.bool(false, "Mark breaks on the price chart", group = G_L, tooltip = "Small triangles on the price chart where RSI broke a line: ▲ below the candle = resistance broken, ▼ above = support broken.")

float  upLvl    = input.float(70.0, "Upper level", group = G_V, inline = "u")
float  loLvl    = input.float(30.0, "Lower level", group = G_V, inline = "l")
bool   showMid  = input.bool(true, "50 midline", group = G_V)
bool   showFill = input.bool(true, "Shade RSI beyond the upper / lower level", group = G_V)
color  colRsi   = input.color(#C9DDF0, "RSI line", group = G_V, inline = "r")
int    wRsi     = input.int(2, "", minval = 1, maxval = 4, group = G_V, inline = "r")
color  colRes   = input.color(#FF5C7A, "Resistance / support lines", group = G_V, inline = "tl")
color  colSup   = input.color(#3FB6FF, "", group = G_V, inline = "tl")
int    wLine    = input.int(2, "Line width", minval = 1, maxval = 4, group = G_V, inline = "w")
int    histT    = input.int(60, "History transparency %", minval = 0, maxval = 90, group = G_V, inline = "w")
color  colBrk   = input.color(#F2C14E, "Break marker", group = G_V)
color  colLvl   = input.color(#7C8BA8, "Levels / midline", group = G_V)

bool   aRes     = input.bool(true, "RSI broke resistance", group = G_A, tooltip = "Create ONE alert on this indicator with 'Any alert() function call'. These boxes choose what it sends. Closed candles only.")
bool   aSup     = input.bool(true, "RSI broke support", group = G_A)
bool   aNew     = input.bool(false, "New line formed", group = G_A)

// ============================================================================= RSI + LEVELS
float rsi = ta.rsi(src, rsiLen)
pR  = plot(rsi, "RSI", color = colRsi, linewidth = wRsi)
max_bars_back(rsi, 1100)
hline(upLvl, "Upper level", color = color.new(colLvl, 20), linestyle = hline.style_dotted)
hline(loLvl, "Lower level", color = color.new(colLvl, 20), linestyle = hline.style_dotted)
hline(50, "Midline 50", color = showMid ? color.new(colLvl, 30) : color.new(colLvl, 100), linestyle = hline.style_dashed)
// shading only where RSI is beyond a level (the gradient is transparent inside the range)
pUp = plot(upLvl, "Upper (fill)", display = display.none)
pLo = plot(loLvl, "Lower (fill)", display = display.none)
fill(pR, pUp, 100, upLvl, showFill ? color.new(colRes, 55) : color.new(colRes, 100), color.new(colRes, 100), "Above upper")
fill(pR, pLo, loLvl, 0, color.new(colSup, 100), showFill ? color.new(colSup, 55) : color.new(colSup, 100), "Below lower")

// ============================================================================= ENGINE
type TL
    int   x1
    float y1
    int   x2
    float y2
    int   side          // 1 resistance, -1 support
    bool  broken = false
    int   bBar = na
    line  ln
    label mk

f_at(TL t, int x) => t.y1 + (t.y2 - t.y1) / (t.x2 - t.x1) * (x - t.x1)

var array<TL> tlRes = array.new<TL>()
var array<TL> tlSup = array.new<TL>()
var int   phX = na
var float phY = na
var int   plX = na
var float plY = na

f_drop(array<TL> a, int i) =>
    TL t = array.get(a, i)
    line.delete(t.ln)
    label.delete(t.mk)
    array.remove(a, i)
    true

f_prune(array<TL> a) =>
    while array.size(a) > keepN
        f_drop(a, 0)
    true

// RSI must have respected the line between the pivots and since the second pivot
f_valid(int x1, float y1, int x2, float y2, int side) =>
    bool ok = true
    float m = (y2 - y1) / (x2 - x1)
    for k = x1 + 1 to bar_index
        if k != x2
            float v = rsi[bar_index - k]
            float p = y1 + m * (k - x1)
            if side == 1 ? v > p : v < p
                ok := false
                break
    ok

// a new line from pivot (x1,y1) to (x2,y2); returns true when drawn
f_make(array<TL> a, int x1, float y1, int x2, float y2, int side) =>
    bool made = false
    bool slopeOk = lineMode == "All slopes" or (side == 1 ? y2 < y1 : y2 > y1)
    if not na(x1) and x2 > x1 and x2 - x1 <= maxSpan and slopeOk and f_valid(x1, y1, x2, y2, side)
        color c = side == 1 ? colRes : colSup
        line l = line.new(x1, y1, extAct ? bar_index : x2, extAct ? y1 + (y2 - y1) / (x2 - x1) * (bar_index - x1) : y2, color = c, width = wLine)
        array.push(a, TL.new(x1, y1, x2, y2, side, ln = l))
        f_prune(a)
        made := true
    made

// update active lines: extend, or mark the break; returns the number broken this bar
f_update(array<TL> a) =>
    int nb = 0
    if array.size(a) > 0
        for i = array.size(a) - 1 to 0
            TL t = array.get(a, i)
            if not t.broken
                float p = f_at(t, bar_index)
                bool br = t.side == 1 ? rsi > p : rsi < p
                if br
                    t.broken := true
                    t.bBar := bar_index
                    nb += 1
                    if showHist
                        color c = t.side == 1 ? colRes : colSup
                        line.set_xy2(t.ln, bar_index, p)
                        line.set_color(t.ln, color.new(c, histT))
                        line.set_style(t.ln, line.style_dotted)
                        if showBrk
                            t.mk := label.new(bar_index, p, "◆", style = label.style_label_center, color = color.new(colBrk, 100), textcolor = colBrk, size = size.small)
                    else
                        f_drop(a, i)
                else if extAct
                    line.set_xy2(t.ln, bar_index, p)
    nb

float ph = ta.pivothigh(rsi, lb, lb)
float pl = ta.pivotlow(rsi, lb, lb)

bool evRes = false
bool evSup = false
bool evNew = false

if barstate.isconfirmed and not na(rsi)
    // breaks first, so a line never breaks on the bar it is born
    evRes := f_update(tlRes) > 0
    evSup := f_update(tlSup) > 0
    if not na(ph)
        int x2 = bar_index - lb
        evNew := f_make(tlRes, phX, phY, x2, ph, 1) or evNew
        phX := x2
        phY := ph
    if not na(pl)
        int x2 = bar_index - lb
        evNew := f_make(tlSup, plX, plY, x2, pl, -1) or evNew
        plX := x2
        plY := pl

// ============================================================================= MARKERS ON PRICE (optional)
plotshape(showPx and evRes, "Resistance broken (price)", shape.triangleup, location.belowbar, colSup, size = size.tiny, force_overlay = true, display = display.pane)
plotshape(showPx and evSup, "Support broken (price)", shape.triangledown, location.abovebar, colRes, size = size.tiny, force_overlay = true, display = display.pane)

// ============================================================================= ALERTS (closed candles)
string hdr = syminfo.ticker + " " + timeframe.period + " · RSI " + str.tostring(rsi, "0.0") + " · "
if aRes and evRes
    alert(hdr + "RSI broke a resistance trend line", alert.freq_once_per_bar_close)
if aSup and evSup
    alert(hdr + "RSI broke a support trend line", alert.freq_once_per_bar_close)
if aNew and evNew
    alert(hdr + "new RSI trend line formed", alert.freq_once_per_bar_close)
alertcondition(evRes, "RSI breaks resistance", "{{ticker}} {{interval}}: RSI broke a resistance trend line")
alertcondition(evSup, "RSI breaks support", "{{ticker}} {{interval}}: RSI broke a support trend line")
````
