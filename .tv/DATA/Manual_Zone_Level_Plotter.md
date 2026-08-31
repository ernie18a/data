<!-- tradingview-pine-id: PUB;fd853937d0804b3bb08059c850d190b2 -->
<!-- tradingviewscripts-format: 1 -->
# Manual Zone & Level Plotter

Source: https://www.tradingview.com/script/t56ZWrf6-Manual-Zone-Level-Plotter/

## Description

Draws price zones and horizontal levels from a short text input, so you can keep a manually-defined map of the market on your chart without re-drawing it by hand every day.

WHY
Many traders keep a small set of levels and zones they care about (a directional target area, one or two areas where they wait for entries, and the nearest support/resistance). Re-drawing them by hand on every timeframe and every device is tedious and error-prone. This script keeps that map in two short text fields, so it survives timeframe changes, chart reloads and switching devices.

HOW IT WORKS
You type (or paste) two strings in the settings.

Zones field (settings: "Zones") - groups separated by ";", items separated by ","
G = primary zone, O = secondary zone, X = marker levels.
A range like 4371.83-4400 is drawn as a box; a single number is drawn as a line.
Example: G4371.83-4400;O4325-4350;X4350

Levels field (settings: "Levels") - R = levels above, S = levels below
Example: R4350,4400;S4325,4311.89

Everything is drawn with extend on both sides, so the zones stay visible wherever you scroll. Optional price tags can be turned off. Box transparency and line width are adjustable. Malformed numbers are skipped instead of breaking the whole drawing.

NOTES
- The script contains no signals, no alerts, no buy/sell logic and no automatic level detection. It only draws what you type. All numbers come from you.
- Nothing is repainted: the drawing is rebuilt on the last bar from your input only.
- Works on any symbol and timeframe.

This is a drawing utility for personal chart notes. It is not investment advice and it does not tell you when to buy or sell. Trading involves risk; make your own decisions.

---

## Source Code

````pine
// Manual Zone & Level Plotter
// Draws price zones and horizontal levels from two short text inputs, so a manually
// defined map of the market survives timeframe changes, chart reloads and devices.
// No signals, no alerts, no automatic level detection - it draws only what you type.
// Not investment advice. Trading involves risk; make your own decisions.
// v1.1 - documentation and example-chart update only; drawing logic unchanged.
//@version=6
indicator("Manual Zone & Level Plotter", "Zones", overlay = true,
     max_boxes_count = 60, max_lines_count = 100, max_labels_count = 100)

// inputs
gB = "1) Zones"
boxStr = input.string("", "Zones", group = gB,
     tooltip = "G = primary zone, O = secondary zone, X = marker levels. Groups separated by ';', items by ','. A range (4371.83-4400) draws a box, a single number draws a line. Example: G4371.83-4400;O4325-4350;X4350")

gL = "2) Levels"
lvStr = input.string("", "Levels", group = gL,
     tooltip = "R = levels above, S = levels below. Example: R4350,4400;S4325,4311.89")

gS = "3) Style"
showPx  = input.bool(true, "Show price tags", group = gS)
fillPct = input.int(92, "Zone transparency", minval = 50, maxval = 99, group = gS)
lineW   = input.int(1, "Line width", minval = 1, maxval = 3, group = gS)

cGreen  = color.rgb(38, 166, 154)
cOrange = color.rgb(255, 152, 0)
cGray   = color.rgb(144, 164, 174)
cRes    = color.rgb(239, 83, 80)
cSup    = color.rgb(38, 166, 154)

// Returns the body of the group starting with tag, e.g. "G" -> "4371.83-4400"
f_seg(string src, string tag) =>
    string found = ""
    if str.length(src) > 0
        clean = str.replace_all(str.replace_all(src, " ", ""), "\n", "")
        parts = str.split(clean, ";")
        for i = 0 to array.size(parts) - 1
            p = array.get(parts, i)
            if str.length(p) > 1 and str.startswith(p, tag)
                found := str.substring(p, 1)
    found

// drawing store (cleared before every rebuild)
var array<box>   bxs = array.new<box>()
var array<line>  lns = array.new<line>()
var array<label> lbs = array.new<label>()

f_clear() =>
    while array.size(bxs) > 0
        box.delete(array.pop(bxs))
    while array.size(lns) > 0
        line.delete(array.pop(lns))
    while array.size(lbs) > 0
        label.delete(array.pop(lbs))

f_label(float price, color c) =>
    if showPx
        array.push(lbs, label.new(bar_index + 12, price, str.tostring(price, format.mintick),
             xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 25),
             textcolor = color.white, size = size.small))

// Draw one group: ranges become boxes, single numbers become lines.
// A malformed item is skipped; the rest of the drawing still renders.
f_draw(string body, color c, string style) =>
    if str.length(body) > 0
        items = str.split(body, ",")
        for i = 0 to array.size(items) - 1
            it = array.get(items, i)
            pair = str.split(it, "-")
            if array.size(pair) == 2
                a = str.tonumber(array.get(pair, 0))
                b = str.tonumber(array.get(pair, 1))
                if not na(a) and not na(b)
                    top = math.max(a, b)
                    bot = math.min(a, b)
                    array.push(bxs, box.new(time, top, time + 1, bot, xloc = xloc.bar_time,
                         extend = extend.both, border_color = color.new(c, 40),
                         bgcolor = color.new(c, fillPct)))
                    f_label(top, c)
                    f_label(bot, c)
            else
                p = str.tonumber(it)
                if not na(p)
                    array.push(lns, line.new(time, p, time + 1, p, xloc = xloc.bar_time,
                         extend = extend.both, color = c, width = lineW, style = style))
                    f_label(p, c)

// rebuild on the last bar
if barstate.islast
    f_clear()
    f_draw(f_seg(boxStr, "G"), cGreen, line.style_solid)
    f_draw(f_seg(boxStr, "O"), cOrange, line.style_solid)
    f_draw(f_seg(boxStr, "X"), cGray, line.style_dotted)
    f_draw(f_seg(lvStr, "R"), cRes, line.style_dashed)
    f_draw(f_seg(lvStr, "S"), cSup, line.style_dashed)
````
