# Momentum Sizing [MiesOnCharts]

- url: https://www.tradingview.com/script/tpDTxX73-Momentum-Sizing-MiesOnCharts/
- type: indicator
- pine_id: PUB;207a2eeb77ff4ce59205eebae15b747a
- version: 1.0

## Description

[b]MOMENTUM SIZING[/b]

Momentum Sizing turns momentum into a position size. Rather than saying in or out, it says how much of the asset to hold, from nothing up to a full position. It is a long only indicator.

[b]How it works[/b]

- Score. Returns over a range of horizons, from short to long, are each scaled by how far the asset normally travels over that horizon, then blended into one standardized score where zero is neutral. It is the same score as Volatility Scaled Momentum.
- Strength. Nothing is held at a score of zero or below, a full position at the full size score or above, and a proportional size in between.
- Calm. When volatility is above the asset's own normal level, the size is cut in proportion. At twice its normal volatility, the position is halved.
- Rebalance band. Strength and calm multiply into a target size. The held size only follows the target once it has drifted far enough, so small moves in the score do not turn into a stream of small trades.

[b]On the chart[/b]

- Pane: the held size as columns with the target as a step line, or the momentum score.
- Candles tinted by size (optional).
- Panel: the current size, the score, and volatility against its normal level.

[b]Alerts[/b]

Position opened, position closed, size changed.

[b]Repainting[/b]

Size changes are decided on closed bars and do not change afterwards. On the live bar the score and the target move with price, while the held size, the colours and the alerts wait for the close.

Limits

- Long only. Negative momentum takes the size to zero.
- Momentum lags turning points.

This script is for informational and educational purposes only and is not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MiesOnCharts

//   __  __ _
//  |  \/  (_) ___  ___
//  | |\/| | |/ _ \/ __|
//  | |  | | |  __/\__ \
//  |_|  |_|_|\___||___/

//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  MOMENTUM SIZING
//  How much of the asset to hold, not just whether to hold it.

// ═══════════════════════════════════════════════════════════════════════════
indicator("Momentum Sizing - Mies", shorttitle = "MSIZE - Mies", overlay = false, precision = 2, max_bars_back = 1000)

grpM = "Momentum"
grpZ = "Sizing"
grpD = "Display"

src     = input.source(close, "Source", group = grpM, display = display.none)
minH    = input.int(7,   "Shortest Horizon", minval = 2, group = grpM, display = display.none,
     tooltip = "The shortest return horizon in the score, in bars.")
maxH    = input.int(180, "Longest Horizon", minval = 3, maxval = 700, group = grpM, display = display.none,
     tooltip = "The longest return horizon in the score, in bars.")
nH      = input.int(6,   "Horizons", minval = 2, maxval = 12, group = grpM, display = display.none,
     tooltip = "How many horizons are blended between the two ends, spaced geometrically.")
volHalf = input.int(30,  "Volatility Half-Life", minval = 5, group = grpM, display = display.none,
     tooltip = "Bars for an old return to lose half its weight in the volatility estimate.")

float fullAt  = input.float(1.0, "Full size at score", minval = 0.25, step = 0.25, group = grpZ, display = display.none,
     tooltip = "The score at which the strength part reaches a full position. Lower sizes up sooner, higher waits for a stronger trend.")
bool  useCalm = input.bool(true, "Scale down in high volatility", group = grpZ, display = display.none,
     tooltip = "Cuts the position in proportion when volatility is above its normal level for this asset.")
int   normLen = input.int(365, "Normal volatility window (bars)", minval = 50, maxval = 1000, group = grpZ, display = display.none,
     tooltip = "The window the asset's normal volatility is taken from, as the median of its volatility over these bars.")
float bandPct = input.float(10.0, "Rebalance band %", minval = 0.0, maxval = 50.0, step = 1.0, group = grpZ, display = display.none,
     tooltip = "The held size only changes when the target has moved this far from it. Entries and full exits always go through.")

string view      = input.string("Size", "Pane shows", options = ["Size", "Score"], group = grpD, display = display.none)
bool   paintBar  = input.bool(true, "Tint the candles by size", group = grpD, display = display.none)
bool   showTable = input.bool(true, "Panel", group = grpD, inline = "t", display = display.none)
string tblPos    = input.string("Top right", "", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpD, inline = "t", display = display.none)

const color GREEN = color.rgb(0, 255, 21)
const color RED   = color.rgb(255, 0, 0)
const color GREY  = color.rgb(120, 123, 134)

// ═══════════════════════════════════════════════════════════════════════════
//  THE SCORE  (Volatility Scaled Momentum, unchanged)
// ═══════════════════════════════════════════════════════════════════════════
//
// Pulled from a plain standard deviation so it starts at a sensible level instead of
// climbing up from zero. Sigma is taken through the previous bar, so a violent bar
// does not widen its own denominator.
float r1 = math.log(src / src[1])

float lam    = math.pow(0.5, 1.0 / volHalf)
float seedSd = ta.stdev(r1, volHalf * 2)

var float ewVar  = 0.0
var bool  seeded = false
if not seeded
    if not na(seedSd) and seedSd > 0
        ewVar  := seedSd * seedSd
        seeded := true
else
    ewVar := lam * ewVar + (1.0 - lam) * nz(r1) * nz(r1)

float sigma = seeded ? math.sqrt(ewVar) : na
float sigEx = sigma[1]

f_h(int k) =>
    float t = nH > 1 ? k / float(nH - 1) : 0.0
    int(math.round(minH * math.pow(maxH / float(minH), t)))

float zSum  = 0.0
int   zCnt  = 0
int   prevH = -1
array<int> hArr = array.new<int>()

for k = 0 to nH - 1
    int h = f_h(k)
    if h != prevH
        prevH := h
        float rh = math.log(src / src[h])
        if not na(rh) and not na(sigEx) and sigEx > 0
            zSum += rh / (sigEx * math.sqrt(h))
            zCnt += 1
            array.push(hArr, h)

// The horizons overlap, so their average is narrower than a standard normal.
float vSum = 0.0
int   m    = array.size(hArr)
if m > 0
    for i = 0 to m - 1
        for j = 0 to m - 1
            float a = array.get(hArr, i)
            float b = array.get(hArr, j)
            vSum += math.sqrt(math.min(a, b) / math.max(a, b))
float blendSd = m > 0 ? math.sqrt(vSum / (m * m)) : na

float score = zCnt > 0 and blendSd > 0 ? (zSum / zCnt) / blendSd : na

// ═══════════════════════════════════════════════════════════════════════════
//  THE SIZE
// ═══════════════════════════════════════════════════════════════════════════
//
// The asset's normal volatility is the median of its own over the window, so one move
// in the window does not redefine normal. Until there is a window of it, the calm part
// stands aside and the size is strength alone.
float normVol  = ta.median(sigEx, normLen)
float strength = na(score) ? na : math.max(0.0, math.min(1.0, score / fullAt))
float calm     = useCalm and not na(normVol) and not na(sigEx) and sigEx > 0 ? math.min(1.0, normVol / sigEx) : 1.0
float target   = na(strength) ? na : strength * calm

var float held = 0.0
float heldPrev = held
if barstate.isconfirmed and not na(target)
    bool trade = (target == 0 and held > 0) or (held == 0 and target > 0) or math.abs(target - held) >= bandPct / 100
    if trade
        held := target

// ═══════════════════════════════════════════════════════════════════════════
//  THE PANE
// ═══════════════════════════════════════════════════════════════════════════
color sizeCol  = held <= 0 ? GREY : color.from_gradient(held, 0.0, 1.0, color.new(GREEN, 70), GREEN)
color scoreCol = na(score) ? GREY : score > 0 ? GREEN : RED

// Reference levels drawn as plots, since an hline's level has to be fixed when the script compiles.
plot(view == "Size" ? 100.0 : na, "Full size",  color.new(GREY, 40), 1, plot.style_linebr)
plot(view == "Size" ? 50.0  : na, "Half size",  color.new(GREY, 70), 1, plot.style_linebr)
plot(view == "Score" ? 0.0  : na, "Zero",       color.new(GREY, 40), 1, plot.style_linebr)

plot(view == "Size" ? held * 100 : na,  "Held size %",   sizeCol, 1, plot.style_columns)
plot(view == "Size" ? target * 100 : na, "Target size %", color.new(color.white, 40), 1, plot.style_stepline)

plot(view == "Score" ? score : na, "Momentum score", scoreCol, 2)
plot(view == "Score" ? fullAt : na, "Full size at", color.new(GREEN, 50), 1, plot.style_linebr)

barcolor(paintBar ? (held > 0 ? color.from_gradient(held, 0.0, 1.0, color.new(GREEN, 75), GREEN) : GREY) : na)

plot(score,        "· score",        display = display.data_window)
plot(strength,     "· strength",     display = display.data_window)
plot(calm,         "· calm",         display = display.data_window)
plot(target * 100, "· target %",     display = display.data_window)
plot(held * 100,   "· held %",       display = display.data_window)

// ═══════════════════════════════════════════════════════════════════════════
//  THE PANEL
// ═══════════════════════════════════════════════════════════════════════════
//
// What is held, on a band of its own, and under it the two readings that set it.
f_pos() =>
    switch tblPos
        "Top right"    => position.top_right
        "Top left"     => position.top_left
        "Bottom right" => position.bottom_right
        => position.bottom_left

const color PANEL_BG  = color.new(#0b0e14, 8)
const color PANEL_FR  = color.new(#ffffff, 84)
const color PANEL_BD  = color.new(#ffffff, 92)
const color TXT_LABEL = color.new(#ffffff, 48)
const color TXT_BODY  = color.new(#ffffff, 15)

var table tb = table.new(f_pos(), 2, 3,
     bgcolor = showTable ? PANEL_BG : color.new(color.black, 100),
     frame_color = showTable ? PANEL_FR : color.new(color.black, 100),
     frame_width = 1, border_color = PANEL_BD, border_width = 1)

f_pc(float v) =>
    na(v) ? "" : str.tostring(v * 100, "0") + "%"

f_row(int r, string a, string b, color col) =>
    table.cell(tb, 0, r, a, text_color = TXT_LABEL, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, r, b, text_color = col, text_size = size.small, text_halign = text.align_right)

if barstate.islast and showTable
    color hc = held > 0 ? GREEN : GREY
    table.cell(tb, 0, 0, held > 0 ? "HOLD " + f_pc(held) : "FLAT", text_color = hc, text_size = size.normal, text_halign = text.align_left, bgcolor = color.new(hc, 85))
    table.cell(tb, 1, 0, "", bgcolor = color.new(hc, 85))
    table.merge_cells(tb, 0, 0, 1, 0)
    f_row(1, "Score", na(score) ? "" : str.tostring(score, "0.00"), scoreCol)
    if useCalm
        f_row(2, "Volatility", na(normVol) or na(sigEx) ? "warming up" : str.tostring(sigEx / normVol, "0.0") + "x normal", TXT_BODY)

// ═══════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════
alertcondition(heldPrev == 0 and held > 0, "Position opened", "Momentum Sizing has opened a position")
alertcondition(heldPrev > 0 and held == 0, "Position closed", "Momentum Sizing has closed the position")
alertcondition(heldPrev > 0 and held > 0 and held != heldPrev, "Size changed", "Momentum Sizing has changed the position size")
````
