# Fault Lines

- url: https://www.tradingview.com/script/rnB0V6Tr/
- type: indicator
- pine_id: PUB;fc0a6d69fdca4dc9ad60acf0829d3204
- version: 1.0

## Description

[b]FAULT LINES[/b]

Fault Lines marks the price bands where resting orders accumulate, then tracks what actually happens to each band: whether price pierced it and was rejected, or closed through it. Those two outcomes point in opposite directions, and the script separates them everywhere — in colour, in the marker it draws, in the state it stores and in the alert it fires.

[quote]A level that is pierced and rejected is a reversal footprint. A level that is closed through is a continuation footprint. Most tools call both of them "broken" and delete the box.[/quote]

[b]THE IDEA BEHIND IT[/b]

A confirmed swing high is a price the market refused to trade above for a number of bars on both sides. Stop orders from short positions, and buy stops from breakout traders, collect just above it. A confirmed swing low collects the mirror image below it. Those pockets are the reason price frequently accelerates through an old extreme and then immediately reverses.

What matters is not that a level exists, but what price did when it arrived there. Two outcomes are possible and they mean different things:

[list]
[*]The wick trades through the level and the bar closes back inside — the orders were filled and the move was rejected.
[*]The bar closes beyond the level — the level no longer holds and structure has changed.
[/list]

[b]HOW THE COMPONENTS WORK TOGETHER[/b]

The script uses three market measurements. They are not three indicators shown next to each other — each one answers a different question about the same object, and none of them is plotted on its own:

[list]
[*][b]Swing structure[/b] answers [i]where[/i] a band belongs. A pivot is confirmed only when a set number of bars on both sides failed to exceed it.
[*][b]ATR[/b] answers [i]how thick[/i] the band should be and [i]how far away is far[/i]. A fixed percentage would make bands unusable across instruments with different volatility, so band height, merge distance and retirement distance are all expressed in ATR(100).
[*][b]Volume[/b] answers [i]how much[/i] was transacted while the band was built. It feeds the strength score only. It never creates or suppresses a band by itself.
[/list]

Remove any one of them and the remaining logic stops working: without structure there is no band, without ATR the band cannot be sized or compared across symbols, without volume the score cannot distinguish a level built on real participation from one built on a quiet drift.

[b]HOW IT WORKS, STEP BY STEP[/b]

[list=1]
[*][b]Band creation.[/b] A pivot is confirmed [i]Structure Length[/i] bars after it printed. ATR(100) is read at that bar and a band of ATR × [i]Zone Height[/i] is placed around the pivot, distributed 80% beyond the extreme and 20% inside it, because the orders sit beyond the wick rather than centred on it.
[*][b]Merging.[/b] If the new pivot lands within [i]Merge Distance[/i] × ATR of an existing band on the same side, no second band is created. The existing one is stretched to cover both extremes, its level moves to the more extreme of the two, and its retest counter increments. This is what keeps a range from producing a dozen near-identical boxes.
[*][b]Lifecycle.[/b] On every closed bar each band is evaluated in a fixed order. For an upper band: it is [b]ruptured[/b] if close is above the level; otherwise [b]swept[/b] if the high is above the level but the close is not; otherwise [b]tested[/b] if the high reached into the band; otherwise it stays [b]intact[/b]. Lower bands use the mirrored conditions on low and close. Rupture is checked before sweep, so a bar that closes through is never counted as a rejection.
[*][b]Strength score, 0 to 100.[/b] Three components: volume on the pivot bar divided by its 50-bar average, capped at 2x, worth 35 points; the height of the swing leg into the pivot divided by ATR, capped at 3 ATR, worth 40 points; and the number of separate returns into the band, capped at 3, worth 25 points. A newly created band can therefore reach 75 — the remaining 25 points are earned over time. The score drives fill opacity and line weight, so a glance is enough to rank the levels.
[*][b]Relevance and pruning.[/b] When a side reaches its band limit the script does not drop the oldest band, it drops the least relevant one. Relevance is the strength score minus a distance penalty (up to 45 points, scaled over 12 ATR) and an age penalty (up to 25 points, scaled over 400 bars). Without this, a single very prominent old extreme keeps its slot indefinitely while newer levels near price are discarded.
[*][b]Retirement.[/b] Independently of pruning, a band is removed once price has moved further than the configured ATR distance from it, or once it exceeds the configured age. [i]Zone Lifespan[/i] sets both at once: Short is 200 bars / 8 ATR, Medium 400 / 15, Long 800 / 25, or Unlimited.
[/list]

[b]READING THE CHART[/b]

[list]
[*][b]Band opacity[/b] — brightness tracks strength; bands dim with age and brighten again as price approaches.
[*][b]Level line[/b] — solid while intact, dotted once tested, dashed once swept.
[*][b]Triangle marker[/b] — a sweep: wick through, close back inside.
[*][b]Faded band with a dashed outline[/b] — a ruptured level, frozen at the bar it gave way, kept as a record of where structure changed.
[*][b]Vertical tick on the left of a band[/b] — the pivot that created it.
[*][b]Dotted beam[/b] — distance from price to the nearest live band, in percent.
[*][b]Dashboard[/b] — bands above and below, sweeps and ruptures on screen, nearest level and its distance, average strength, and which side currently holds more unfilled levels.
[/list]

[b]HOW TO USE IT[/b]

Bands are context, not entries. Three practical readings:

[list=1]
[*][b]Approach.[/b] An intact band with a high score is a place where a move is likely to stall or accelerate. The dashboard's nearest-level row tells you how much room is left before you get there.
[*][b]Sweep.[/b] A sweep marker on a strong band says the orders behind it were taken and price refused to hold beyond it. Traders using reversal setups take this as a location filter; it says nothing about timing on its own.
[*][b]Rupture.[/b] A close through a strong band is the opposite message. Ruptures accumulate in the direction structure is breaking, which is often clearer than the candles themselves.
[/list]

Set [i]Structure Length[/i] to control granularity: leave it at 0 to adapt to the timeframe, raise it for fewer and more significant levels. If the chart feels crowded, raise [i]Minimum Strength[/i] to 40–50 before touching anything else.

[b]REPAINTING[/b]

A band is drawn [i]Structure Length[/i] bars after the pivot that created it, because that is when the pivot becomes confirmable. That is confirmation delay, not repainting: once placed, a band never changes its price and never disappears retroactively. With [i]Confirm On Bar Close[/i] enabled — the default — every state change is evaluated on closed bars only. Disabling it lets states react during the forming bar, which flickers until that bar closes.

[b]LIMITATIONS[/b]

[list]
[*]Symbols without volume data score every band on prominence alone, so the volume component contributes nothing there.
[*]On very short structure lengths in a tight range, sweeps and retests occur constantly and the score saturates. Raise the structure length rather than the band count.
[*]The script describes where orders are likely to rest. It does not predict direction and produces no entry or exit signals.
[/list]

[b]ALERTS[/b]

[list]
[*][b]New Fault[/b] — a band was created.
[*][b]Fault Swept[/b] — includes side, price and strength.
[*][b]Fault Ruptured[/b] — includes side and price.
[/list]

Open source. Written from scratch; no third-party code is reused.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chartdottech

//@version=6

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║   F A U L T   L I N E S                                          v1.0     ║
// ║   Price levels under tension — and the moment they rupture.               ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
//
//  THE IDEA
//  Every confirmed swing extreme leaves a band behind it where resting orders
//  pile up. Fault Lines treats each of those bands as a living object with a
//  lifecycle instead of a box that appears and disappears:
//
//      INTACT     never touched since it formed
//      TESTED     price entered the band and left again
//      SWEPT      wick pierced the level, close came back  →  rejection
//      RUPTURED   price closed through the level           →  structure break
//
//  The split between SWEPT and RUPTURED is the whole point. A level that gets
//  pierced and rejected is a reversal footprint. A level that gets closed
//  through is a continuation footprint. Collapsing both into "broken" throws
//  away the more useful half of the information.
//
//  STRENGTH SCORE (0–100)
//      volume at formation (35)  +  swing prominence in ATR (40)  +  retests (25)
//  Strength drives opacity, line weight and pruning: when a side is full, the
//  weakest fault is dropped — not simply the oldest.
//
//  NON-REPAINTING
//  A fault appears `Structure Length` bars after the pivot that created it.
//  That is confirmation delay, not repainting — once placed, a fault never
//  moves. With "Confirm on Bar Close" enabled (default) every state change is
//  evaluated on closed bars only.

indicator("Fault Lines", "Fault Lines", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════════════

gStr = "Structure"
lenIn     = input.int(0, "Structure Length", minval = 0, maxval = 50, group = gStr, tooltip = "How many bars must sit on each side of a swing before it counts as a zone.\n\nHIGHER = fewer zones, but each one is more significant.\nLOWER = more zones, more noise.\n\n0 = pick automatically from the chart timeframe. Recommended.")
minScore  = input.float(0, "Minimum Strength", minval = 0, maxval = 75, step = 5, group = gStr, tooltip = "Hide zones weaker than this value.\n\nEvery zone is scored 0-100 from three things: the volume that built it, how large the swing was, and how often price has returned to it. A brand new zone tops out at 75 — the last 25 points are earned through retests.\n\n0 = show everything.\n40-50 = only the notable levels.")
onClose   = input.bool(true, "Confirm On Bar Close", group = gStr, tooltip = "ON — a zone only changes state once the bar has closed. Nothing on the chart moves after the fact.\n\nOFF — zones react while the bar is still forming. Faster, but they flicker until the close.\n\nLeave this on unless you have a reason not to.")

gFlt = "Zones"
maxLive   = input.int(6, "Max Zones Per Side", minval = 1, maxval = 15, group = gFlt, tooltip = "How many zones are kept above and below price.\n\nWhen the limit is reached the least relevant zone is dropped — that means weak, far away or stale, not simply the oldest.")
bandAtr   = input.float(0.75, "Zone Height", minval = 0.05, maxval = 3.0, step = 0.05, group = gFlt, tooltip = "Thickness of each zone, measured in ATR so it scales with volatility instead of being a fixed percentage.\n\n0.30 = thin bands\n0.75 = default, reads as a proper area\n1.50+ = broad supply and demand blocks")
mergeAtr  = input.float(0.40, "Merge Distance", minval = 0.0, maxval = 3.0, step = 0.05, group = gFlt, tooltip = "New swings landing this close to an existing zone reinforce it instead of stacking a second box on top.\n\nMeasured in ATR. This is what keeps the chart from filling up with near-duplicates.\n\n0 = never merge.")
lifespan  = input.string("Medium", "Zone Lifespan", options = ["Short", "Medium", "Long", "Unlimited"], group = gFlt, tooltip = "How long a zone stays on the chart before it is retired — by age and by distance from price.\n\nShort = 200 bars / 8 ATR\nMedium = 400 bars / 15 ATR\nLong = 800 bars / 25 ATR\nUnlimited = never retire (on long histories this leaves decade-old levels lying around)")
keepScars = input.bool(true, "Keep Broken Zones", group = gFlt, tooltip = "When price closes through a zone it is marked as broken. ON leaves it on the chart as a faded scar, which maps where structure gave way. OFF removes it immediately.")

gArt = "Look"
theme     = input.string("Ember & Ice", "Colour Theme", options = ["Ember & Ice", "Aurora", "Mono", "Classic", "Custom"], group = gArt, tooltip = "Ember & Ice — amber above, cyan below\nAurora — rose above, green below\nMono — greyscale, no hue coding\nClassic — the usual red and green\nCustom — your own three colours below")
cUpIn     = input.color(#FF9F43, "Custom  ·  Above", group = gArt, inline = "cst")
cDnIn     = input.color(#2ED3F0, "Below", group = gArt, inline = "cst")
cSwIn     = input.color(#B06BFF, "Sweep", group = gArt, inline = "cst")
style     = input.string("Rich", "Zone Style", options = ["Minimal", "Clean", "Rich", "Maximum"], group = gArt, tooltip = "How much visual work goes into each zone.\n\nMinimal — one flat band, nothing else\nClean — light gradient with an outline\nRich — full gradient, glow, origin marker (default)\nMaximum — 16-slice gradient and a wider bloom\n\nHigher settings cost drawing objects. The script thins them out by itself if your zone limits would exceed what TradingView allows.")
tagMode   = input.string("Strength", "Zone Labels", options = ["Strength", "Price", "Both", "Off"], group = gArt, tooltip = "The small text at the right edge of every zone.\n\nStrength — the 0-100 score\nPrice — the exact level\nBoth — score and price\nOff — no labels")
showBeam  = input.bool(true, "Distance Beam", group = gArt, tooltip = "Dotted connector from the current price to the nearest zone, labelled with the distance in percent.")

gPnl = "Dashboard"
showDash  = input.bool(true, "Show Dashboard", group = gPnl)
dashPos   = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group = gPnl)
dashSize  = input.string("Small", "Size", options = ["Small", "Normal", "Large"], group = gPnl)
dashTransp = input.int(10, "Transparency", minval = 0, maxval = 100, group = gPnl)
dashStyle = input.string("Dark", "Style", options = ["Dark", "Light"], group = gPnl)

// ═══════════════════════════════════════════════════════════════════════════
//  DERIVED SETTINGS
//  One visible control drives several internals — this is what keeps the
//  settings dialog short without giving up any of the look.
// ═══════════════════════════════════════════════════════════════════════════

wantSlices = style == "Maximum" ? 16 : style == "Rich" ? 10 : style == "Clean" ? 5 : 2
halo       = style == "Maximum" ? 2 : style == "Rich" ? 1 : style == "Clean" ? 1 : 0
zoneStyle  = style == "Minimal" ? "Solid" : "Gradient"
duoTone    = style != "Minimal"
edgeLine   = style != "Minimal"
originMk   = style == "Rich" or style == "Maximum"
intensity  = style == "Maximum" ? 1.25 : 1.0
charge     = style != "Minimal"
flashBg    = style == "Rich" or style == "Maximum"
fadeAge    = true
showLine   = true
showMark   = true

retire     = lifespan == "Unlimited" ? 0.0 : lifespan == "Long" ? 25.0 : lifespan == "Short" ? 8.0 : 15.0
maxAge     = lifespan == "Unlimited" ? 0 : lifespan == "Long" ? 800 : lifespan == "Short" ? 200 : 400
maxScars   = 5

// ═══════════════════════════════════════════════════════════════════════════
//  PALETTE
// ═══════════════════════════════════════════════════════════════════════════

type Palette
    color up
    color dn
    color sweep
    color scar
    color txt
    color dim
    color panel
    color upFar
    color dnFar

buildPalette() =>
    switch theme
        "Aurora"  => Palette.new(#FF5C8A, #3DDC97, #8B6CFF, #6B7280, #E9ECF2, #8A93A0, #0B0E13, #FFB86B, #2ED3F0)
        "Mono"    => Palette.new(#EDEFF3, #939AA6, #FFFFFF, #4E5560, #EDEFF3, #7F8791, #0B0E13, #9AA2AE, #5E6570)
        "Classic" => Palette.new(#EF5350, #26A69A, #FFB300, #78909C, #E9ECF2, #8A93A0, #0B0E13, #FF8A65, #4DB6AC)
        "Custom"  => Palette.new(cUpIn, cDnIn, cSwIn, #6B7280, #E9ECF2, #8A93A0, #0B0E13, cUpIn, cDnIn)
        => Palette.new(#FF9F43, #2ED3F0, #B06BFF, #6B7280, #E9ECF2, #8A93A0, #0B0E13, #FF4D6D, #5A7BFF)

var Palette P = buildPalette()

// ═══════════════════════════════════════════════════════════════════════════
//  MARKET CONTEXT  (evaluated on every bar so history stays consistent)
// ═══════════════════════════════════════════════════════════════════════════

L = lenIn > 0 ? lenIn : (timeframe.isseconds ? 6 : timeframe.isminutes ? (timeframe.multiplier <= 5 ? 9 : timeframe.multiplier <= 60 ? 7 : 6) : timeframe.isdaily ? 6 : timeframe.isweekly ? 4 : 3)

atrRaw  = ta.atr(100)
atrNow  = na(atrRaw) or atrRaw <= 0 ? math.max(high - low, syminfo.mintick) : atrRaw
volAvg  = ta.sma(volume, 50)
legLow  = ta.lowest(low, L * 2 + 1)
legHigh = ta.highest(high, L * 2 + 1)

barMs   = math.max(nz(time - time[1], 60000), 1)

// Slices per zone, throttled so the worst case still fits TradingView's
// 500-box ceiling.
faultBudget = maxLive * 2 + (keepScars ? maxScars : 0) + 2
slices      = math.max(1, math.min(wantSlices, math.floor(470 / faultBudget) - halo * 2))

pivHigh = ta.pivothigh(high, L, L)
pivLow  = ta.pivotlow(low, L, L)

// ═══════════════════════════════════════════════════════════════════════════
//  FAULT OBJECT
// ═══════════════════════════════════════════════════════════════════════════

// state: 0 intact · 1 tested · 2 swept · 3 ruptured
type Fault
    float price
    float top
    float bot
    int   born
    int   bornT
    bool  up
    float rvol
    float prom
    int   touches
    int   lastTouch
    int   state
    int   stateBar
    int   stateT
    array<box> layers
    line  lvl
    line  edge
    line  orig
    label tag
    label mark

method score(Fault this) =>
    v = math.min(nz(this.rvol, 1.0) / 2.0, 1.0) * 35.0
    p = math.min(nz(this.prom, 0.0) / 3.0, 1.0) * 40.0
    t = math.min(this.touches, 3) / 3.0 * 25.0
    math.min(100.0, v + p + t)

// Pruning weight: intrinsic strength minus how far away and how stale the
// fault has become. Without this an ancient high-prominence extreme keeps its
// slot forever and newer, closer levels get dropped instead.
method relevance(Fault this) =>
    dist = math.abs(close - this.price) / atrNow
    age  = bar_index - this.born
    this.score() - math.min(1.0, dist / 12.0) * 45.0 - math.min(1.0, age / 400.0) * 25.0

method hue(Fault this) =>
    this.state == 3 ? P.scar : this.state == 2 ? P.sweep : this.up ? P.up : P.dn

method erase(Fault this) =>
    if array.size(this.layers) > 0
        for b in this.layers
            box.delete(b)
        array.clear(this.layers)
    line.delete(this.lvl)
    line.delete(this.edge)
    line.delete(this.orig)
    label.delete(this.tag)
    label.delete(this.mark)
    this.lvl  := na
    this.edge := na
    this.orig := na
    this.tag  := na
    this.mark := na

// Positions and colours every drawing that belongs to this fault.
method paint(Fault this) =>
    c    = this.hue()
    s    = this.score()
    dead = this.state == 3
    xR   = dead ? this.stateT : time

    // opacity: strength brightens, age dulls, proximity charges
    aged = fadeAge ? math.min(8.0, (bar_index - this.born) / 250.0 * 8.0) : 0.0
    near = charge ? math.abs(close - this.price) / atrNow : 99.0
    lift = charge and near < 0.6 ? (0.6 - near) / 0.6 * 14.0 : 0.0
    coreT = math.max(34.0, math.min(92.0, 76.0 - 26.0 * (s / 100.0) - (intensity - 1.0) * 18.0 + aged - lift + (dead ? 12.0 : 0.0)))
    edgeT = math.min(96.0, coreT + 12.0)

    h    = math.max(this.top - this.bot, syminfo.mintick)
    far  = math.max(math.max(this.top - this.price, this.price - this.bot), syminfo.mintick)
    step = h / slices
    ring = h * 0.16
    n    = array.size(this.layers)
    cF   = duoTone and this.state < 2 ? (this.up ? P.upFar : P.dnFar) : c

    if n > 0
        for i = 0 to n - 1
            b  = array.get(this.layers, i)
            yB = 0.0
            yT = 0.0
            d  = 1.0
            if i < slices
                // body slice — distance from the level drives the ramp, so the
                // zone burns brightest exactly where the orders sit
                yB := this.bot + i * step
                yT := yB + step
                d  := math.min(1.0, math.abs((yB + yT) / 2.0 - this.price) / far)
            else
                // glow ring bleeding past the band edge
                r    = math.ceil((i - slices + 1) / 2.0)
                over = (i - slices) % 2 == 0
                yB   := over ? this.top + (r - 1) * ring : this.bot - r * ring
                yT   := over ? this.top + r * ring : this.bot - (r - 1) * ring
                d    := 1.0 + r * 0.55
            flat = zoneStyle == "Solid" and i < slices
            tS   = flat ? coreT : math.min(97.0, coreT + (edgeT - coreT) * math.pow(d, 2.2))
            box.set_lefttop(b, this.bornT, yT)
            box.set_rightbottom(b, xR, yB)
            box.set_bgcolor(b, flat ? color.new(c, tS) : color.from_gradient(d, 0.0, 1.0, color.new(c, tS), color.new(cF, tS)))
            box.set_border_color(b, color.new(c, 100))

    if not na(this.lvl)
        line.set_xy1(this.lvl, this.bornT, this.price)
        line.set_xy2(this.lvl, xR, this.price)
        line.set_extend(this.lvl, dead ? extend.none : extend.right)
        line.set_color(this.lvl, color.new(c, math.max(6.0, coreT - 40.0)))
        line.set_style(this.lvl, this.state == 0 ? line.style_solid : this.state == 1 ? line.style_dotted : this.state == 2 ? line.style_dashed : line.style_dotted)
        line.set_width(this.lvl, dead ? 1 : 2)

    if not na(this.edge)
        yE = this.up ? this.top : this.bot
        line.set_xy1(this.edge, this.bornT, yE)
        line.set_xy2(this.edge, xR, yE)
        line.set_extend(this.edge, dead ? extend.none : extend.right)
        line.set_color(this.edge, color.new(c, math.max(28.0, coreT - 14.0)))
        line.set_style(this.edge, dead ? line.style_dashed : line.style_solid)

    if not na(this.orig)
        line.set_xy1(this.orig, this.bornT, this.bot)
        line.set_xy2(this.orig, this.bornT, this.top)
        line.set_color(this.orig, color.new(c, math.max(20.0, coreT - 30.0)))
        line.set_width(this.orig, 2)

    if not na(this.tag)
        pTxt = str.tostring(this.price, format.mintick)
        sTxt = str.tostring(math.round(s))
        body = tagMode == "Price" ? pTxt : tagMode == "Both" ? sTxt + "  " + pTxt : sTxt
        mark = this.state == 3 ? "╱ " : this.state == 2 ? "× " : ""
        label.set_xy(this.tag, time + barMs * 3, this.price)
        label.set_text(this.tag, mark + body)
        label.set_textcolor(this.tag, color.new(c, math.max(0.0, coreT - 45.0)))

// ═══════════════════════════════════════════════════════════════════════════
//  FAULT REGISTRY
// ═══════════════════════════════════════════════════════════════════════════

var array<Fault> faults = array.new<Fault>()

// Attaches the drawing objects a fault needs, sized by the glow setting.
spawnArt(Fault f) =>
    layerCount = slices + halo * 2
    for i = 0 to layerCount - 1
        array.push(f.layers, box.new(f.bornT, f.top, time, f.bot, xloc = xloc.bar_time, border_width = 0, bgcolor = color.new(color.gray, 100), border_color = color.new(color.gray, 100)))
    if showLine
        f.lvl := line.new(f.bornT, f.price, time, f.price, xloc = xloc.bar_time, width = 1, color = color.new(color.gray, 100))
    if edgeLine
        f.edge := line.new(f.bornT, f.up ? f.top : f.bot, time, f.up ? f.top : f.bot, xloc = xloc.bar_time, width = 1, color = color.new(color.gray, 100))
    if originMk
        f.orig := line.new(f.bornT, f.bot, f.bornT, f.top, xloc = xloc.bar_time, width = 1, color = color.new(color.gray, 100))
    if tagMode != "Off"
        f.tag := label.new(time, f.price, "", xloc = xloc.bar_time, style = label.style_none, textalign = text.align_left, size = size.small, color = color.new(color.gray, 100))

// Removes the weakest live fault on a side once that side is over budget.
trimSide(bool up) =>
    live = 0
    for f in faults
        if f.up == up and f.state < 3
            live += 1
    if live > maxLive
        worstIdx = -1
        worstVal = 1e12
        for [i, f] in faults
            if f.up == up and f.state < 3
                sc = f.relevance()
                if sc < worstVal
                    worstVal := sc
                    worstIdx := i
        if worstIdx >= 0
            array.get(faults, worstIdx).erase()
            array.remove(faults, worstIdx)

// Keeps the scar count in check, oldest rupture first.
trimScars() =>
    scars = 0
    for f in faults
        if f.state == 3
            scars += 1
    if scars > maxScars
        oldIdx = -1
        oldBar = 1e12
        for [i, f] in faults
            if f.state == 3 and f.stateBar < oldBar
                oldBar := f.stateBar
                oldIdx := i
        if oldIdx >= 0
            array.get(faults, oldIdx).erase()
            array.remove(faults, oldIdx)

// Creates a fault, or reinforces a neighbouring one if it is close enough.
addFault(float price, bool up) =>
    h  = math.max(atrNow * bandAtr, syminfo.mintick * 4)
    rv = na(volAvg) or volAvg <= 0 ? 1.0 : nz(volume[L], 0) / volAvg
    pr = (up ? price - legLow : legHigh - price) / atrNow
    merged  = false
    created = false

    if mergeAtr > 0
        for f in faults
            if not merged and f.up == up and f.state < 2 and math.abs(f.price - price) <= mergeAtr * atrNow
                f.price     := up ? math.max(f.price, price) : math.min(f.price, price)
                f.top       := math.max(f.top, price + (up ? h * 0.8 : h * 0.2))
                f.bot       := math.min(f.bot, price - (up ? h * 0.2 : h * 0.8))
                f.rvol      := math.max(f.rvol, rv)
                f.prom      := math.max(f.prom, pr)
                f.touches   := f.touches + 1
                f.lastTouch := bar_index
                f.paint()
                merged := true

    if not merged
        probe = Fault.new(price = price, top = price + (up ? h * 0.8 : h * 0.2), bot = price - (up ? h * 0.2 : h * 0.8), born = bar_index - L, bornT = time[L], up = up, rvol = rv, prom = pr, touches = 0, lastTouch = bar_index - L, state = 0, stateBar = bar_index - L, stateT = time[L], layers = array.new<box>())
        if probe.score() >= minScore
            spawnArt(probe)
            probe.paint()
            array.push(faults, probe)
            trimSide(up)
            created := true
    created

// ═══════════════════════════════════════════════════════════════════════════
//  BIRTH
// ═══════════════════════════════════════════════════════════════════════════

bornThisBar = false
if not na(pivHigh)
    bornThisBar := addFault(pivHigh, true)
if not na(pivLow)
    bornThisBar := addFault(pivLow, false) or bornThisBar

// ═══════════════════════════════════════════════════════════════════════════
//  LIFECYCLE
// ═══════════════════════════════════════════════════════════════════════════

liveBar   = onClose ? barstate.isconfirmed : true
sweepFire = false
breakFire = false
var string sweepMsg = ""
var string breakMsg = ""

if liveBar
    for f in faults
        if f.state < 3
            if f.up ? close > f.price : close < f.price
                // closed through — the fault ruptures
                f.state    := 3
                f.stateBar := bar_index
                f.stateT   := time
                breakFire  := true
                breakMsg   := "Fault Lines · " + syminfo.ticker + " " + timeframe.period + " · RUPTURED " + (f.up ? "upper" : "lower") + " fault at " + str.tostring(f.price, format.mintick)
                if not keepScars
                    f.erase()
                else
                    f.paint()
            else if f.up ? high > f.price : low < f.price
                // pierced and rejected inside the same bar — a sweep
                if f.state != 2
                    sweepFire := true
                    sweepMsg  := "Fault Lines · " + syminfo.ticker + " " + timeframe.period + " · SWEPT " + (f.up ? "upper" : "lower") + " fault at " + str.tostring(f.price, format.mintick) + " (strength " + str.tostring(math.round(f.score())) + ")"
                    if showMark
                        label.delete(f.mark)
                        f.mark := label.new(time, f.up ? high : low, "", xloc = xloc.bar_time, style = f.up ? label.style_triangledown : label.style_triangleup, color = color.new(P.sweep, 15), size = size.tiny)
                f.state    := 2
                f.stateBar := bar_index
                f.stateT   := time
                f.touches  := math.min(f.touches + 1, 3)
                f.paint()
            else if (f.up ? high >= f.bot : low <= f.top) and f.state == 0
                if bar_index - f.lastTouch > L
                    f.touches   := f.touches + 1
                    f.lastTouch := bar_index
                f.state := 1
                f.paint()

    if keepScars
        trimScars()

    // Retire faults that price has walked away from, and faults that have simply
    // outlived their relevance. Both are what keeps the chart from filling with
    // levels nobody is trading against any more.
    if (retire > 0 or maxAge > 0) and array.size(faults) > 0
        for i = array.size(faults) - 1 to 0
            fr = array.get(faults, i)
            tooFar = retire > 0 and math.abs(close - fr.price) > retire * atrNow
            tooOld = maxAge > 0 and bar_index - fr.born > maxAge
            if tooFar or tooOld
                fr.erase()
                array.remove(faults, i)

// Ruptures are erased on the spot when scars are switched off — clear the registry too.
if not keepScars and array.size(faults) > 0
    for i = array.size(faults) - 1 to 0
        if array.get(faults, i).state == 3
            array.remove(faults, i)

bgcolor(flashBg and sweepFire ? color.new(P.sweep, 92) : na, title = "Sweep Flash")

// ═══════════════════════════════════════════════════════════════════════════
//  RENDER  (full repaint of the visible set only on the last bar)
// ═══════════════════════════════════════════════════════════════════════════

var line  beam    = na
var label beamTag = na

if barstate.islast
    nearDist = 1e12
    nearPx   = float(na)
    nearUp   = true
    for f in faults
        f.paint()
        if f.state < 3
            d = math.abs(close - f.price)
            if d < nearDist
                nearDist := d
                nearPx   := f.price
                nearUp   := f.up

    if showBeam and not na(nearPx)
        bc = color.new(nearUp ? P.up : P.dn, 45)
        if na(beam)
            beam    := line.new(time, close, time, nearPx, xloc = xloc.bar_time, style = line.style_dotted, width = 1, color = bc)
            beamTag := label.new(time, (close + nearPx) / 2, "", xloc = xloc.bar_time, style = label.style_none, size = size.tiny, textalign = text.align_left)
        line.set_xy1(beam, time, close)
        line.set_xy2(beam, time, nearPx)
        line.set_color(beam, bc)
        pct = close != 0 ? math.abs(nearPx - close) / close * 100.0 : 0.0
        label.set_xy(beamTag, time + barMs, (close + nearPx) / 2)
        label.set_text(beamTag, (nearUp ? "▲ " : "▼ ") + str.tostring(pct, "#.##") + "%")
        label.set_textcolor(beamTag, color.new(nearUp ? P.up : P.dn, 20))
    else if not na(beam)
        line.delete(beam)
        label.delete(beamTag)
        beam    := na
        beamTag := na

// ═══════════════════════════════════════════════════════════════════════════
//  PANEL
// ═══════════════════════════════════════════════════════════════════════════

panelPos() =>
    switch dashPos
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.top_right

dviSize() =>
    switch dashSize
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

color dashBgCol     = dashStyle == "Dark" ? color.new(color.rgb(30, 30, 40), 0) : color.new(color.white, 5)
color dashTxtCol    = dashStyle == "Dark" ? color.white : color.black
color dashTxtSecCol = dashStyle == "Dark" ? color.new(color.white, 45) : color.new(color.black, 45)
color dashHeaderBg  = dashStyle == "Dark" ? color.new(color.rgb(40, 40, 60), 0) : color.new(color.rgb(235, 235, 235), 0)

DASH_ROWS = 9
var table dash = table.new(panelPos(), 2, DASH_ROWS, border_width = 1, border_color = color.new(color.gray, 50), bgcolor = color.new(dashBgCol, dashTransp), frame_color = color.new(color.gray, 0), frame_width = 2)

// Section header: merged across both columns
f_dash_header(int row, string txt) =>
    table.cell(dash, 0, row, txt, bgcolor = dashHeaderBg, text_color = dashTxtCol, text_size = dviSize(), text_halign = text.align_center)
    table.merge_cells(dash, 0, row, 1, row)
    0

// Key-value row: label left in the secondary tone, value right in its own colour
f_dash_kv(int row, string k, string v, color vCol) =>
    table.cell(dash, 0, row, k, bgcolor = dashBgCol, text_color = dashTxtSecCol, text_size = dviSize(), text_halign = text.align_left)
    table.cell(dash, 1, row, v, bgcolor = dashBgCol, text_color = vCol, text_size = dviSize(), text_halign = text.align_right)
    0

if barstate.islast and showDash
    table.clear(dash, 0, 0, 1, DASH_ROWS - 1)

    nAbove = 0
    nBelow = 0
    nSwept = 0
    nScar  = 0
    sumS   = 0.0
    cntS   = 0
    nearD  = 1e12
    nearP  = float(na)
    nearU  = true

    for f in faults
        if f.state == 3
            nScar += 1
        else
            if f.up
                nAbove += 1
            else
                nBelow += 1
            if f.state == 2
                nSwept += 1
            sumS += f.score()
            cntS += 1
            d = math.abs(close - f.price)
            if d < nearD
                nearD := d
                nearP := f.price
                nearU := f.up

    avgS   = cntS > 0 ? sumS / cntS : 0.0
    pct    = not na(nearP) and close != 0 ? math.abs(nearP - close) / close * 100.0 : na
    drawTx = nAbove > nBelow ? "Upside ▲" : nBelow > nAbove ? "Downside ▼" : "Balanced"
    drawCl = nAbove > nBelow ? P.up : nBelow > nAbove ? P.dn : dashTxtSecCol
    rowI   = 0

    f_dash_header(rowI, "FAULT LINES  ·  v1.0")
    rowI += 1
    f_dash_kv(rowI, "Zones above", str.tostring(nAbove), P.up)
    rowI += 1
    f_dash_kv(rowI, "Zones below", str.tostring(nBelow), P.dn)
    rowI += 1
    f_dash_kv(rowI, "Swept  ·  Broken", str.tostring(nSwept) + "  ·  " + str.tostring(nScar), P.sweep)
    rowI += 1
    f_dash_header(rowI, "CONTEXT")
    rowI += 1
    f_dash_kv(rowI, "Nearest level", na(nearP) ? "—" : str.tostring(nearP, format.mintick), na(nearP) ? dashTxtSecCol : nearU ? P.up : P.dn)
    rowI += 1
    f_dash_kv(rowI, "Distance", na(pct) ? "—" : str.tostring(pct, "#.##") + "%", dashTxtCol)
    rowI += 1
    f_dash_kv(rowI, "Avg strength", cntS > 0 ? str.tostring(math.round(avgS)) : "—", dashTxtCol)
    rowI += 1
    f_dash_kv(rowI, "Draw", drawTx, drawCl)

// ═══════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════

if sweepFire
    alert(sweepMsg, alert.freq_once_per_bar_close)
if breakFire
    alert(breakMsg, alert.freq_once_per_bar_close)

alertcondition(bornThisBar, "New Fault", "Fault Lines: a new fault has formed")
alertcondition(sweepFire, "Fault Swept", "Fault Lines: a fault was swept — wick through, close back inside")
alertcondition(breakFire, "Fault Ruptured", "Fault Lines: a fault ruptured — price closed through the level")
````
