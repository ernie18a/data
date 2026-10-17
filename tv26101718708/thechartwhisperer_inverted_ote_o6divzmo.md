# TheChartWhisperer - Inverted OTE

- url: https://www.tradingview.com/script/O6divzMO-TheChartWhisperer-Inverted-OTE/
- type: indicator
- pine_id: PUB;c098226bbd1f4b8f919c87f8a95602af
- version: 1.0

## Description

Plots the Inverted Optimal Trade Entry pocket (0.236–0.382) from any swing high/low, with the 0.295 sweet spot as the primary entry target. Built for BTC, ETH, SOL, and XAUUSD with full asset-themed visuals.
How it works:

Anchor two points to your swing. The indicator auto-detects long/short bias or you can force a direction. The 0.295 SS line marks peak confluence within the pocket. A 0.118 outer reference line flags early entries.
Includes:

Multi-layer bloom halos for visual depth
Auto-switching asset color themes
Price tags at every level
Alerts for zone entry and SS touch

Part of the CAP Framework

## Source Code

````pine
// ════════════════════════════════════════════════════════════════════
//  THECHARTWHISPERER — INVERTED OTE ZONE  (v3.0 multi-asset)
//  Proprietary inverted-fib Optimal Trade Entry tool.
//  Pocket: 0.236 – 0.382   |   Sweet spot (SS): 0.295
//
//  Single indicator. Asset dropdown switches the brand color theme:
//    • ETH  →  Ethereum blue   #627EEA
//    • BTC  →  Bitcoin gold    #F7931A
//    • SOL  →  Solana purple   #9945FF
//    • XAU  →  Gold/warm gold  #FFD700
//
//  Brand tag dynamically reflects the selected asset.
//  All tones (bright / core / deep) auto-derived from one brand hex per asset.
//
//  Visual: razor-thin precision lines + tight bloom halos on pure black.
//  thechartwhisperer.ca
// ════════════════════════════════════════════════════════════════════
//@version=6
indicator("TheChartWhisperer — Inverted OTE", shorttitle="TCW OTE", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)
 
// ─── ASSET THEME ──────────────────────────────────────────────────
grpAsset = "① Asset theme"
asset = input.string("ETH", "Asset", options=["ETH", "BTC", "SOL", "XAU"], group=grpAsset, tooltip="Switches the brand color theme. ETH=blue, BTC=gold, SOL=purple, XAU=warm gold. Brand tag updates automatically.")
 
// ─── DIRECTION ────────────────────────────────────────────────────
grpDir = "② Trade direction"
dirChoice = input.string("Auto-detect", "Direction", options=["Auto-detect", "Force pocket on LOWER half (LONG)", "Force pocket on UPPER half (SHORT)"], group=grpDir, tooltip="LOWER half = LONG setup. UPPER half = SHORT setup. Same color either way — only the label flips.")
 
// ─── ANCHORS ──────────────────────────────────────────────────────
grpAnchor = "③ Anchors  (type prices for accuracy, click on chart for dates)"
a1 = input.time (timestamp("2026-04-15T07:00"), "Anchor 1 — time",  group=grpAnchor, confirm=true, inline="anchor1")
p1 = input.float(0.0,                            "price",            group=grpAnchor, minval=0.0,   inline="anchor1")
a2 = input.time (timestamp("2026-04-25T07:00"), "Anchor 2 — time",  group=grpAnchor, confirm=true, inline="anchor2")
p2 = input.float(0.0,                            "price",            group=grpAnchor, minval=0.0,   inline="anchor2")
 
// ─── VISUAL STYLE ─────────────────────────────────────────────────
grpStyle      = "④ Visual style"
bloomLayers   = input.int(4, "Bloom halo layers per line", minval=2, maxval=8, group=grpStyle, tooltip="How many soft glow bands radiate from each fib line. 4 = balanced tight glow.")
bloomSpread   = input.float(0.09, "Bloom spread (% of pocket range)", minval=0.02, maxval=0.5, step=0.01, group=grpStyle, tooltip="How tight the glow hugs each line. 0.09 = tight precision.")
ssBoost       = input.float(1.5, "SS (0.295) glow boost multiplier", minval=1.0, maxval=3.0, step=0.1, group=grpStyle, tooltip="How much wider/brighter the SS line glows vs 0.236/0.382.")
showSweetLine = input.bool(true,  "Show 0.295 SS center line",                 group=grpStyle)
show118       = input.bool(true,  "Show 0.118 outer reference line (dashed)",  group=grpStyle)
showPriceTags = input.bool(true,  "Show price tags at each level",             group=grpStyle)
showAnchors   = input.bool(false, "Show swing anchor markers",                 group=grpStyle)
showBrandTag  = input.bool(true,  "Show TCW OTE brand tag",                    group=grpStyle)
extendRight   = input.int(40, "Extend zone right (bars)", minval=0, maxval=500, group=grpStyle)
labelOffset   = input.int(3,  "Price-tag offset (bars)",  minval=0, maxval=50,  group=grpStyle)
 
// ─── SHARED COLORS ────────────────────────────────────────────────
grpColor = "⑤ Shared colors  (apply to all assets)"
tagBgCol = input.color(color.rgb(8, 10, 22),     "Tag background", group=grpColor, tooltip="Dark background for ALL tags (TCW brand tag + fib level tags).")
textCol  = input.color(color.rgb(255, 255, 255), "Generic label text (unused — kept for compatibility)", group=grpColor)
 
// ─── ASSET COLOR PALETTES  (auto-derived bright/core/deep from one brand hex) ─
// Each asset has 3 tones: bright (lightened ~25%), core (brand hex), deep (darkened ~35%)
//
//   ETH  →  #8FA4F0 / #627EEA / #3D5BC0
//   BTC  →  #FFC84D / #F7931A / #B86B0A
//   SOL  →  #C18CFF / #9945FF / #6A1FCC
//   XAU  →  #FFE680 / #FFD700 / #B89500
 
themeCore   = asset == "ETH" ? color.rgb(98, 126, 234)  : asset == "BTC" ? color.rgb(247, 147, 26) : asset == "SOL" ? color.rgb(153, 69, 255)  : color.rgb(255, 215, 0)
themeBright = asset == "ETH" ? color.rgb(143, 164, 240) : asset == "BTC" ? color.rgb(255, 200, 77) : asset == "SOL" ? color.rgb(193, 140, 255) : color.rgb(255, 230, 128)
themeDeep   = asset == "ETH" ? color.rgb(61, 91, 192)   : asset == "BTC" ? color.rgb(184, 107, 10) : asset == "SOL" ? color.rgb(106, 31, 204)  : color.rgb(184, 149, 0)
 
// ─── ANCHOR RESOLUTION ────────────────────────────────────────────
swingHigh = math.max(p1, p2)
swingLow  = math.min(p1, p2)
hiTime    = p1 >= p2 ? a1 : a2
loTime    = p1 <  p2 ? a1 : a2
tfMs      = timeframe.in_seconds(timeframe.period) * 1000
int barHigh = na
int barLow  = na
if tfMs > 0
    barHigh := bar_index - math.max(0, int((time - hiTime) / tfMs))
    barLow  := bar_index - math.max(0, int((time - loTime) / tfMs))
 
// ─── DIRECTION LOGIC ──────────────────────────────────────────────
bool autoLowerHalf = not na(barHigh) and not na(barLow) ? barLow > barHigh : true
pocketLower = dirChoice == "Force pocket on LOWER half (LONG)" ? true : dirChoice == "Force pocket on UPPER half (SHORT)" ? false : autoLowerHalf
isLongLabel = pocketLower
 
// ─── INVERTED-FIB MATH ────────────────────────────────────────────
range_ = (swingHigh > 0 and swingLow > 0 and swingHigh > swingLow) ? (swingHigh - swingLow) : na
 
f(level) =>
    pocketLower ? swingLow + range_ * level : swingHigh - range_ * level
 
p118 = f(0.118)
p236 = f(0.236)
p295 = f(0.295)
p382 = f(0.382)
 
pocketTop = math.max(p236, p382)
pocketBot = math.min(p236, p382)
 
// ─── DRAW OBJECTS ─────────────────────────────────────────────────
var box[]   bloomBoxes = array.new<box>()
var line    line236    = na
var line    line295    = na
var line    line382    = na
var line    line118    = na
var line    hiAnchor   = na
var line    loAnchor   = na
var label   tagSweet   = na
var label   tag236     = na
var label   tag382     = na
var label   tag118     = na
var label   tagBrand   = na
 
// Helper — emit multi-layer bloom around a price line.
// Innermost band tightest + brightest; outermost widest + dimmest.
emitBloom(lvlPrice, halfWidth, layers, baseCol, leftB, rightB) =>
    for i = 1 to layers
        frac     = i / layers
        bandFrac = 1.0 - (i - 1) / layers
        bandHalf = halfWidth * bandFrac
        yTop     = lvlPrice + bandHalf
        yBot     = lvlPrice - bandHalf
        alpha    = int(92 - frac * 42)
        b = box.new(leftB, yTop, rightB, yBot, border_color=na, bgcolor=color.new(baseCol, alpha))
        array.push(bloomBoxes, b)
 
if barstate.islast and not na(range_) and range_ > 0 and not na(barHigh) and not na(barLow)
    leftBar  = math.min(barHigh, barLow)
    rightBar = bar_index + extendRight
    pocketRange = pocketTop - pocketBot
 
    // Clean prior drawings
    if array.size(bloomBoxes) > 0
        for i = 0 to array.size(bloomBoxes) - 1
            box.delete(array.get(bloomBoxes, i))
        array.clear(bloomBoxes)
    if not na(line236)
        line.delete(line236)
    if not na(line295)
        line.delete(line295)
    if not na(line382)
        line.delete(line382)
    if not na(line118)
        line.delete(line118)
    if not na(hiAnchor)
        line.delete(hiAnchor)
    if not na(loAnchor)
        line.delete(loAnchor)
    if not na(tagSweet)
        label.delete(tagSweet)
    if not na(tag236)
        label.delete(tag236)
    if not na(tag382)
        label.delete(tag382)
    if not na(tag118)
        label.delete(tag118)
    if not na(tagBrand)
        label.delete(tagBrand)
 
    // ─── BLOOM HALOS  (drawn first so razor lines sit on top) ──
    standardSpread = pocketRange * bloomSpread
    emitBloom(p236, standardSpread, bloomLayers, themeCore, leftBar, rightBar)
    emitBloom(p382, standardSpread, bloomLayers, themeCore, leftBar, rightBar)
 
    if showSweetLine
        ssSpread = pocketRange * bloomSpread * ssBoost
        emitBloom(p295, ssSpread, bloomLayers + 2, themeBright, leftBar, rightBar)
 
    if show118
        emitBloom(p118, standardSpread * 0.5, math.max(2, bloomLayers - 1), themeDeep, leftBar, rightBar)
 
    // ─── RAZOR-THIN PRECISION LINES ──
    line236 := line.new(leftBar, p236, rightBar, p236, color=color.new(themeCore, 0),   width=1, style=line.style_solid)
    line382 := line.new(leftBar, p382, rightBar, p382, color=color.new(themeCore, 0),   width=1, style=line.style_solid)
 
    if showSweetLine
        line295 := line.new(leftBar, p295, rightBar, p295, color=color.new(themeBright, 0), width=3, style=line.style_solid)
 
    if show118
        line118 := line.new(leftBar, p118, rightBar, p118, color=color.new(themeDeep, 30), width=1, style=line.style_dashed)
 
    // ─── ANCHOR MARKERS ──
    if showAnchors
        hiAnchor := line.new(barHigh, swingHigh, rightBar, swingHigh, color=color.new(color.gray, 70), width=1, style=line.style_dotted)
        loAnchor := line.new(barLow,  swingLow,  rightBar, swingLow,  color=color.new(color.gray, 70), width=1, style=line.style_dotted)
 
    // ─── PRICE TAGS  (all use dark tagBgCol bg, asset-themed text) ──
    if showPriceTags
        tagX = rightBar + labelOffset
        fmt  = format.mintick
 
        tagSweet := label.new(tagX, p295, "0.295  ·  " + str.tostring(p295, fmt) + "  ← SS", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(tagBgCol, 15), textcolor=color.new(themeBright, 0), size=size.normal)
        tag382   := label.new(tagX, p382, "0.382  ·  " + str.tostring(p382, fmt), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(tagBgCol, 15), textcolor=color.new(themeCore, 0), size=size.small)
        tag236   := label.new(tagX, p236, "0.236  ·  " + str.tostring(p236, fmt), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(tagBgCol, 15), textcolor=color.new(themeCore, 0), size=size.small)
        if show118
            tag118 := label.new(tagX, p118, "0.118  ·  " + str.tostring(p118, fmt), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(tagBgCol, 15), textcolor=color.new(themeDeep, 0), size=size.small)
 
    // ─── BRAND TAG  (dynamic asset name) ──
    if showBrandTag
        tagBrand := label.new(leftBar, p295, "TCW OTE  ·  " + asset + "  ·  " + (isLongLabel ? "LONG" : "SHORT"), xloc=xloc.bar_index, style=label.style_label_right, color=color.new(tagBgCol, 15), textcolor=color.new(themeBright, 0), size=size.small)
 
// ─── ALERTS ───────────────────────────────────────────────────────
inZone  = not na(p236) and not na(p382) and close <= pocketTop and close >= pocketBot
atSS    = not na(p295) and not na(range_) and math.abs(close - p295) <= (range_ * 0.01)
 
alertcondition(inZone, title="Price entered TCW OTE zone", message="Price entered the TheChartWhisperer Inverted OTE pocket (0.236–0.382).")
alertcondition(atSS,   title="Price at 0.295 SS",         message="Price reached the TheChartWhisperer 0.295 SS sweet spot.")
````
