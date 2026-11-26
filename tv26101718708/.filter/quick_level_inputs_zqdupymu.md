# Quick Level Inputs

- url: https://www.tradingview.com/script/ZQdUPYMu-Quick-Level-Inputs/
- type: indicator
- pine_id: PUB;e250340ff52d4a1aaab470539678afa8
- version: 1.0

## Description

Plot levels by typing them, not by drawing them

OVERVIEW
Plot horizontal levels by typing prices instead of dragging lines. Paste a
comma-separated list, pick a color, done. Six independent groups, each
optionally bound to its own ticker, so a single instance can hold level sets
for multiple symbols and swap between them automatically as you change charts.

THE PROBLEM IT SOLVES
Drawing tools are fine until your prep produces a *list*. Pivots, prior
session highs/lows, gamma strikes, VWAP anchors — if the output of your
process is numbers, translating them into hand-dragged lines is slow and
imprecise. Typing the price is exact and takes a second.

The usual catch with a Pine-based approach is that indicator inputs aren't
tied to a symbol: switch the chart and your ES levels are sitting on NQ. This
script fixes that with per-group ticker binding.

FEATURES
• Unlimited levels per group — just type or paste "5312, 5288.5, 5250"
• 6 independent groups, each with its own color, width, style, and label text
• Per-group ticker binding — blank draws on any symbol; set a ticker and that
  group only appears on that chart
• Zone shading — pair levels to shade bands for chop zones, expected pivot
  ranges, or supply/demand
• Price-scale tags — levels show as colored price tags on the right axis
• Full color pickers with opacity, plus a master opacity fade for all lines
• Extend right / both / none
• Optional on-chart labels with adjustable size and bar offset
• Fails quietly — an unmarked ticker simply draws nothing

HOW TO USE
1. Add to chart and open settings.
2. In any group, type your levels into the Levels field, separated by commas:
      5312, 5288.5, 5250
   Semicolons work too. Spaces are ignored. Unparseable entries are skipped
   rather than breaking the script.
3. Pick a color, width, and line style for that group.
4. Optional: set a Ticker to bind the group to one symbol. Leave it blank to
   draw on every symbol.

Think of groups as buckets, not rows. A typical setup:
   Group 1 — red, solid, width 2   → key pivots
   Group 2 — blue, solid, width 1  → secondary levels
   Group 3 — amber, "Solid + Zone" → expected chop zone

ZONES
Choose any "+ Zone" style and the group's levels pair up sequentially:
   5340, 5325                → one shaded band
   5340, 5325, 5280, 5262    → two shaded bands
Order within a pair doesn't matter (high/low is sorted for you). An odd
leftover level draws as a plain line. Fill transparency is set by "Zone fill
opacity".

MULTI-SYMBOL WORKFLOW
Set Group 1's ticker to ES1! and Group 2's to NQ1!, each with its own levels.
Flip the chart between the two symbols and the correct set appears
automatically — one indicator instance, no duplicate copies, no retyping.
Blank-ticker groups act as a "draws on everything" layer.

SETTINGS
• Show price labels (on line) — text labels riding on each level
• Show levels in price scale — colored tags on the right axis
• Label size / Label offset — offset pushes labels N bars right, clear of
  price action
• Extend — Right, Both, or None
• Master opacity — fades every line at once; at 100 each group's own
  color-picker opacity is used as-is
• Zone fill opacity — higher is more transparent

NOTES AND LIMITS (read these)
• Price-scale tags cover the FIRST 20 LEVELS in group order. Pine requires a
  fixed number of plot() calls, so this can't be unbounded. Levels beyond 20
  still draw as lines and labels normally — they just don't get an axis tag.
  Zones consume two tags each (high and low).
• Color, width, and style are per GROUP, not per individual level. That's the
  deliberate tradeoff for pasteable lists. Use a separate group per color.
• Levels are stored per indicator instance in your chart layout — not per
  symbol in TradingView's own storage. Ticker binding controls VISIBILITY,
  not storage. Save your layout to persist them.
• Drawing happens once on the last bar and objects are cleaned up on redraw,
  so it stays light regardless of history length.

CREDITS
The input model here — grouped, comma-separated level strings with per-group
symbol binding, and the zone concept — is based on "Quick Levels" by
@SamRecio. This is an independent rewrite rather than a fork: it adds full
color pickers (instead of a fixed color list), price-scale tags, an extend
option, master opacity, multiple zones per group, and single-pass rendering
on the last bar; and it removes the runtime error on unmarked tickers. Credit
to SamRecio for the original design. Licensed MPL 2.0.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © your_tradingview_username

// Based on the input model of "Quick Levels" by @SamRecio (MPL 2.0): grouped,
// comma-separated level strings with per-group symbol binding, plus the zone concept.
// This is an independent rewrite rather than a fork — adds full color pickers,
// price-scale tags, extend option, master opacity, multiple zones per group, and
// single-pass rendering on the last bar; removes the runtime error on unmarked tickers.

//@version=6
indicator("Quick Level Inputs", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ── Settings ──────────────────────────────────────────────────
sg = "Settings"
showLabels    = input.bool(false, "Show price labels (on line)", group = sg)
showScale     = input.bool(true,  "Show levels in price scale", group = sg, tooltip = "Colored price tag on the right axis for each active level. First 20 levels only.")
labelSize     = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], inline = "s1", group = sg)
labOffset     = input.int(10, "Label offset", minval = 0, maxval = 100, inline = "s1", group = sg, tooltip = "Bars to the right of the current candle to place labels, so they clear price action.")
extendMode    = input.string("Both", "Extend", options = ["Right", "Both", "None"], inline = "s2", group = sg)
masterOpacity = input.int(100, "Master opacity (%)", minval = 0, maxval = 100, inline = "s2", group = sg, tooltip = "Fades all lines at once. At 100 each group's own color-picker opacity is used as-is.")
zoneOpacity   = input.int(90, "Zone fill opacity", minval = 0, maxval = 100, group = sg, tooltip = "Transparency of zone shading. Higher = more transparent.")

TT = "LEVELS\nAs many as you want, separated by commas (or semicolons).\nSpaces are ignored.\nExample:  5312, 5288.5, 5250\n\nZONE styles pair levels up: 1st+2nd shade a zone, 3rd+4th shade another, etc. An odd leftover level draws as a plain line.\n\nTICKER blank = draw on whatever symbol the chart is on."

// ── Groups ────────────────────────────────────────────────────
g1 = "Group 1"
en1  = input.bool(true, "Enable", inline = "1a", group = g1), sym1 = input.symbol("", "Ticker", inline = "1a", group = g1)
lv1  = input.string("", "Levels", inline = "1b", group = g1, tooltip = TT), tx1 = input.string("", "Label", inline = "1b", group = g1)
co1  = input.color(color.white, "", inline = "1c", group = g1), wd1 = input.int(1, "Width", minval = 1, maxval = 8, inline = "1c", group = g1), st1 = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted", "Solid + Zone", "Dashed + Zone", "Dotted + Zone"], inline = "1c", group = g1)

g2 = "Group 2"
en2  = input.bool(true, "Enable", inline = "2a", group = g2), sym2 = input.symbol("", "Ticker", inline = "2a", group = g2)
lv2  = input.string("", "Levels", inline = "2b", group = g2, tooltip = TT), tx2 = input.string("", "Label", inline = "2b", group = g2)
co2  = input.color(color.white, "", inline = "2c", group = g2), wd2 = input.int(1, "Width", minval = 1, maxval = 8, inline = "2c", group = g2), st2 = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted", "Solid + Zone", "Dashed + Zone", "Dotted + Zone"], inline = "2c", group = g2)

g3 = "Group 3"
en3  = input.bool(true, "Enable", inline = "3a", group = g3), sym3 = input.symbol("", "Ticker", inline = "3a", group = g3)
lv3  = input.string("", "Levels", inline = "3b", group = g3, tooltip = TT), tx3 = input.string("", "Label", inline = "3b", group = g3)
co3  = input.color(color.white, "", inline = "3c", group = g3), wd3 = input.int(1, "Width", minval = 1, maxval = 8, inline = "3c", group = g3), st3 = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted", "Solid + Zone", "Dashed + Zone", "Dotted + Zone"], inline = "3c", group = g3)

g4 = "Group 4"
en4  = input.bool(true, "Enable", inline = "4a", group = g4), sym4 = input.symbol("", "Ticker", inline = "4a", group = g4)
lv4  = input.string("", "Levels", inline = "4b", group = g4, tooltip = TT), tx4 = input.string("", "Label", inline = "4b", group = g4)
co4  = input.color(color.white, "", inline = "4c", group = g4), wd4 = input.int(1, "Width", minval = 1, maxval = 8, inline = "4c", group = g4), st4 = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted", "Solid + Zone", "Dashed + Zone", "Dotted + Zone"], inline = "4c", group = g4)

g5 = "Group 5"
en5  = input.bool(true, "Enable", inline = "5a", group = g5), sym5 = input.symbol("", "Ticker", inline = "5a", group = g5)
lv5  = input.string("", "Levels", inline = "5b", group = g5, tooltip = TT), tx5 = input.string("", "Label", inline = "5b", group = g5)
co5  = input.color(color.white, "", inline = "5c", group = g5), wd5 = input.int(1, "Width", minval = 1, maxval = 8, inline = "5c", group = g5), st5 = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted", "Solid + Zone", "Dashed + Zone", "Dotted + Zone"], inline = "5c", group = g5)

g6 = "Group 6"
en6  = input.bool(true, "Enable", inline = "6a", group = g6), sym6 = input.symbol("", "Ticker", inline = "6a", group = g6)
lv6  = input.string("", "Levels", inline = "6b", group = g6, tooltip = TT), tx6 = input.string("", "Label", inline = "6b", group = g6)
co6  = input.color(color.white, "", inline = "6c", group = g6), wd6 = input.int(1, "Width", minval = 1, maxval = 8, inline = "6c", group = g6), st6 = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted", "Solid + Zone", "Dashed + Zone", "Dotted + Zone"], inline = "6c", group = g6)

// ── Object stores ─────────────────────────────────────────────
var array<line>     aLines      = array.new<line>()
var array<label>    aLabels     = array.new<label>()
var array<linefill> aFills      = array.new<linefill>()
var array<float>    scalePrices = array.new<float>()
var array<color>    scaleColors = array.new<color>()

// ── Helpers ───────────────────────────────────────────────────
styleOf(s)  => str.contains(s, "Dashed") ? line.style_dashed : str.contains(s, "Dotted") ? line.style_dotted : line.style_solid
sizeOf(s)   => s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : s == "Huge" ? size.huge : size.small
extendOf(s) => s == "Both" ? extend.both : s == "None" ? extend.none : extend.right
tint(col)   => masterOpacity >= 100 ? col : color.new(col, 100 - masterOpacity)

// Symbol portion after the exchange prefix ("CME_MINI:ES1!" -> "ES1!")
tickerPart(s) =>
    p = str.pos(s, ":")
    na(p) ? s : str.substring(s, p + 1)

// Blank ticker = match everything; otherwise match the chart symbol in any common form
symMatch(sym) =>
    s = str.upper(str.replace_all(sym, " ", ""))
    s == "" or s == str.upper(syminfo.tickerid) or s == str.upper(ticker.standard(syminfo.tickerid)) or s == str.upper(syminfo.ticker) or tickerPart(s) == str.upper(syminfo.ticker)

// "5312, 5288.5; 5250" -> [5312, 5288.5, 5250]; junk entries are skipped, not fatal
parseLevels(s) =>
    out = array.new<float>()
    clean = str.replace_all(str.replace_all(s, " ", ""), ";", ",")
    if str.length(clean) > 0
        for p in str.split(clean, ",")
            v = str.tonumber(p)
            if not na(v)
                array.push(out, v)
    out

addLine(v, colT, wdt, lsty, txt) =>
    array.push(aLines, line.new(bar_index - 1, v, bar_index, v, extend = extendOf(extendMode), color = colT, style = lsty, width = wdt))
    if showLabels
        array.push(aLabels, label.new(bar_index + labOffset, v, (txt != "" ? txt + "  " : "") + str.tostring(v), style = label.style_none, textcolor = colT, size = sizeOf(labelSize), textalign = text.align_left))
    array.push(scalePrices, v)
    array.push(scaleColors, colT)

addZone(a, b, colT, wdt, lsty, txt) =>
    hi = math.max(a, b)
    lo = math.min(a, b)
    l1 = line.new(bar_index - 1, hi, bar_index, hi, extend = extendOf(extendMode), color = colT, style = lsty, width = wdt)
    l2 = line.new(bar_index - 1, lo, bar_index, lo, extend = extendOf(extendMode), color = colT, style = lsty, width = wdt)
    array.push(aLines, l1)
    array.push(aLines, l2)
    array.push(aFills, linefill.new(l1, l2, color.new(colT, zoneOpacity)))
    if showLabels
        array.push(aLabels, label.new(bar_index + labOffset, hi, (txt != "" ? txt + "  " : "") + str.tostring(lo) + " – " + str.tostring(hi), style = label.style_none, textcolor = colT, size = sizeOf(labelSize), textalign = text.align_left))
    array.push(scalePrices, hi)
    array.push(scaleColors, colT)
    array.push(scalePrices, lo)
    array.push(scaleColors, colT)

drawGroup(en, sym, lvlsStr, col, wdt, styleStr, txt) =>
    if en and symMatch(sym)
        nums = parseLevels(lvlsStr)
        n = array.size(nums)
        if n > 0
            colT = tint(col)
            lsty = styleOf(styleStr)
            if str.contains(styleStr, "Zone")
                i = 0
                while i + 1 < n
                    addZone(array.get(nums, i), array.get(nums, i + 1), colT, wdt, lsty, txt)
                    i := i + 2
                if n % 2 == 1
                    addLine(array.get(nums, n - 1), colT, wdt, lsty, txt)
            else
                for v in nums
                    addLine(v, colT, wdt, lsty, txt)
    true

// ── Draw (once, on the last bar) ──────────────────────────────
if barstate.islast
    for f in aFills
        linefill.delete(f)
    array.clear(aFills)
    for ln in aLines
        line.delete(ln)
    array.clear(aLines)
    for lb in aLabels
        label.delete(lb)
    array.clear(aLabels)
    array.clear(scalePrices)
    array.clear(scaleColors)
    drawGroup(en1, sym1, lv1, co1, wd1, st1, tx1)
    drawGroup(en2, sym2, lv2, co2, wd2, st2, tx2)
    drawGroup(en3, sym3, lv3, co3, wd3, st3, tx3)
    drawGroup(en4, sym4, lv4, co4, wd4, st4, tx4)
    drawGroup(en5, sym5, lv5, co5, wd5, st5, tx5)
    drawGroup(en6, sym6, lv6, co6, wd6, st6, tx6)

// ── Price-scale tags (right axis only; first 20 levels) ───────
sp(i) => showScale and array.size(scalePrices) > i ? array.get(scalePrices, i) : na
sc(i) => array.size(scaleColors) > i ? array.get(scaleColors, i) : chart.fg_color

plot(sp(0),  "Lvl 1",  color = sc(0),  display = display.price_scale, editable = false)
plot(sp(1),  "Lvl 2",  color = sc(1),  display = display.price_scale, editable = false)
plot(sp(2),  "Lvl 3",  color = sc(2),  display = display.price_scale, editable = false)
plot(sp(3),  "Lvl 4",  color = sc(3),  display = display.price_scale, editable = false)
plot(sp(4),  "Lvl 5",  color = sc(4),  display = display.price_scale, editable = false)
plot(sp(5),  "Lvl 6",  color = sc(5),  display = display.price_scale, editable = false)
plot(sp(6),  "Lvl 7",  color = sc(6),  display = display.price_scale, editable = false)
plot(sp(7),  "Lvl 8",  color = sc(7),  display = display.price_scale, editable = false)
plot(sp(8),  "Lvl 9",  color = sc(8),  display = display.price_scale, editable = false)
plot(sp(9),  "Lvl 10", color = sc(9),  display = display.price_scale, editable = false)
plot(sp(10), "Lvl 11", color = sc(10), display = display.price_scale, editable = false)
plot(sp(11), "Lvl 12", color = sc(11), display = display.price_scale, editable = false)
plot(sp(12), "Lvl 13", color = sc(12), display = display.price_scale, editable = false)
plot(sp(13), "Lvl 14", color = sc(13), display = display.price_scale, editable = false)
plot(sp(14), "Lvl 15", color = sc(14), display = display.price_scale, editable = false)
plot(sp(15), "Lvl 16", color = sc(15), display = display.price_scale, editable = false)
plot(sp(16), "Lvl 17", color = sc(16), display = display.price_scale, editable = false)
plot(sp(17), "Lvl 18", color = sc(17), display = display.price_scale, editable = false)
plot(sp(18), "Lvl 19", color = sc(18), display = display.price_scale, editable = false)
plot(sp(19), "Lvl 20", color = sc(19), display = display.price_scale, editable = false)
````
