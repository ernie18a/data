# Range Fuel Gauge

- url: https://www.tradingview.com/script/Rj2TUwfp-Range-Fuel-Gauge/
- type: indicator
- pine_id: PUB;a070d11efd17437a874a2a39dcca8e77
- version: 1.0

## Description

RANGE FUEL GAUGE — HOW MUCH OF TODAY'S RANGE IS LEFT, AS EXACT PRICES

Every instrument has a typical daily range. Once today's session has consumed most of it, breakout odds statistically fade and mean-reversion setups gain relevance. This indicator turns that idea into two things you can actually trade with: a live fuel gauge and two concrete price levels.

WHAT IT SHOWS

- Fuel panel — how much of the typical daily range today has already used (e.g. "79% used"), with a 10-segment bar that shifts green → amber → red, plus today's range, the typical range, and the points still left
- Upper room level — day low + typical range: the statistical ceiling for today if this session behaves like a typical recent session
- Lower room level — day high − typical range: the statistical floor on the same basis
- A side's room level automatically hides once that side of the range is fully consumed

HOW IT WORKS

1. The indicator stores the high-low range of the last N completed sessions (default 20)
2. Typical range = the Nth percentile of those ranges (default P80, adjustable 50-95)
3. Fuel used = today's developing range ÷ typical range
4. Room levels are simple arithmetic from today's day high / day low and the typical range — they tighten as the day's range expands

HOW TRADERS USE IT

- Fuel below 60% (green) — the day still has energy; breakout and continuation trades have statistical room
- Fuel 60-90% (amber) — range maturing; trail tighter, be selective with fresh breakouts
- Fuel above 90% (red) — the typical range is nearly spent; chasing moves is statistically poor, fade setups toward the day's value become relevant
- Room levels act as realistic intraday targets — for example, a long taken mid-session can use the upper room price as a statistically grounded objective

NOTES

- The room levels are statistical references built from this symbol's own recent history — they are not a forecast, and price can and does exceed them on trend days
- Historical ranges come only from completed sessions and never change after the fact; today's reading updates live as the session develops (by design)
- Alert included: fires when today's range crosses 100% of the typical range
- Panel position is selectable (8 positions); prices are shown as integers
- Works on any symbol; designed for intraday timeframes

This is an original implementation in Pine Script v6. The percentile logic and level arithmetic are fully described above.

Educational tool for market context — not financial advice.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// Range Fuel Gauge  🦚
// How much of today's typical range is already burnt — and exactly how much
// room is left, as two concrete prices. Fuel = today's range vs the Nth
// percentile of the last N completed daily ranges. Room levels:
//   upper room = day low  + typical range
//   lower room = day high − typical range
// Pure historical percentile stats · confirmed daily ranges · no repaint.
// ─────────────────────────────────────────────────────────────────────────────
indicator("Range Fuel Gauge", shorttitle = "RFG 🦚", overlay = true, max_lines_count = 20, max_labels_count = 20)

// ── Inputs ───────────────────────────────────────────────────────────────────
grpE = "Engine"
histDays = input.int(20, "Daily Ranges Lookback (days)", minval = 5, maxval = 120, group = grpE)
basisPct = input.int(80, "Range Basis Percentile",       minval = 50, maxval = 95, group = grpE)

grpV = "Visuals"
showGauge = input.bool(true, "Show Fuel Gauge Panel", group = grpV)
gaugePos  = input.string("Middle Right", "Panel Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left", "Top Center", "Bottom Center"], group = grpV)
colUp   = input.color(color.new(#26A69A, 0), "Upper Room",  group = grpV)
colDn   = input.color(color.new(#F0997B, 0), "Lower Room",  group = grpV)
colOk   = input.color(color.new(#26A69A, 0), "Fuel < 60%",  group = grpV)
colWarn = input.color(color.new(#EF9F27, 0), "Fuel 60-90%", group = grpV)
colHot  = input.color(color.new(#EF5350, 0), "Fuel > 90%",  group = grpV)

color bgPanel = color.new(#1A2230, 0)
color bgEmpty = color.new(#0D1117, 0)
color bgTag   = color.new(#1C2430, 0)
color txMut   = color.new(#7A879C, 0)
color txMain  = color.new(#B8C2D0, 0)

// ── Helpers ──────────────────────────────────────────────────────────────────
f_px(float p) =>
    str.tostring(math.round(p))

// ── Daily range tracking ─────────────────────────────────────────────────────
var array<float> rngArr = array.new<float>()
var float dHi = na
var float dLo = na
var int   barsToday = 0

bool newDay = timeframe.change("D")
if newDay
    if not na(dHi)
        array.push(rngArr, dHi - dLo)
        if array.size(rngArr) > histDays
            array.shift(rngArr)
    dHi := high
    dLo := low
    barsToday := 0
else
    dHi := math.max(nz(dHi, high), high)
    dLo := math.min(nz(dLo, low), low)
barsToday += 1

float typ      = array.size(rngArr) >= 5 ? array.percentile_nearest_rank(rngArr, basisPct) : na
float todayRng = dHi - dLo
float fuelPct  = not na(typ) and typ > 0 ? todayRng / typ * 100 : na
float fuelLeft = not na(typ) ? math.max(0, typ - todayRng) : na

// ── Alert ────────────────────────────────────────────────────────────────────
alertcondition(ta.crossover(fuelPct, 100), "Typical Range Fully Used", "Today's range has consumed 100% of the typical daily range")

// ── Room levels (today only, redrawn on last bar) ────────────────────────────
var array<line>  lns = array.new<line>()
var array<label> lbs = array.new<label>()

if barstate.islast and timeframe.isintraday and not na(typ)
    for l in lns
        line.delete(l)
    array.clear(lns)
    for lb in lbs
        label.delete(lb)
    array.clear(lbs)

    int x1 = math.max(0, bar_index - barsToday + 1)
    int x2 = bar_index + 8
    float upRoom = dLo + typ
    float loRoom = dHi - typ

    if upRoom >= dHi
        array.push(lns, line.new(x1, upRoom, x2, upRoom, color = colUp, width = 2, style = line.style_dashed))
        array.push(lbs, label.new(x2, upRoom, "upper room → " + f_px(upRoom), style = label.style_label_left, color = bgTag, textcolor = colUp, size = size.small))
    if loRoom <= dLo
        array.push(lns, line.new(x1, loRoom, x2, loRoom, color = colDn, width = 2, style = line.style_dashed))
        array.push(lbs, label.new(x2, loRoom, "lower room → " + f_px(loRoom), style = label.style_label_left, color = bgTag, textcolor = colDn, size = size.small))

// ── Fuel gauge panel ─────────────────────────────────────────────────────────
f_pos(string s) =>
    s == "Top Right" ? position.top_right : s == "Middle Right" ? position.middle_right : s == "Bottom Right" ? position.bottom_right : s == "Top Left" ? position.top_left : s == "Middle Left" ? position.middle_left : s == "Bottom Left" ? position.bottom_left : s == "Top Center" ? position.top_center : position.bottom_center

var table tb = table.new(f_pos(gaugePos), 10, 4, bgcolor = color.new(#10151D, 0), border_width = 2, border_color = color.new(#3A4556, 0))

if barstate.islast and showGauge and not na(fuelPct)
    color fc = fuelPct < 60 ? colOk : fuelPct < 90 ? colWarn : colHot
    int   segs = int(math.min(10, math.max(0, math.round(fuelPct / 10))))
    table.cell(tb, 0, 0, "⛽ RANGE FUEL", text_color = color.new(#E8EDF4, 0), text_size = size.small, text_halign = text.align_left)
    table.merge_cells(tb, 0, 0, 4, 0)
    table.cell(tb, 5, 0, str.tostring(math.round(fuelPct)) + "% used", text_color = fc, text_size = size.normal, text_halign = text.align_right)
    table.merge_cells(tb, 5, 0, 9, 0)
    for s = 0 to 9
        table.cell(tb, s, 1, "    ", bgcolor = s < segs ? fc : color.new(#222B38, 0), text_size = size.small)
    table.cell(tb, 0, 2, "today " + f_px(todayRng) + " pts  ·  typical (P" + str.tostring(basisPct) + ") " + f_px(typ) + " pts", text_color = color.new(#C9D3E0, 0), text_size = size.small, text_halign = text.align_left)
    table.merge_cells(tb, 0, 2, 9, 2)
    table.cell(tb, 0, 3, "room left ≈ " + f_px(fuelLeft) + " pts", text_color = fc, text_size = size.small, text_halign = text.align_left)
    table.merge_cells(tb, 0, 3, 9, 3)
````
