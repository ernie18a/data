# Range Breakout Targets [FEELS]

- url: https://www.tradingview.com/script/IA2jQpeg-Range-Breakout-Targets-FEELS/
- type: indicator
- pine_id: PUB;0b11fa48599b487b9533d8f82468f253
- version: 1.0

## Description

Ranges boxed. Breakouts get a target. Reached targets get ticked.

Every quiet stretch on the chart is drawn as a box. When price closes out of it, the box height is added to the broken edge, and that price is the target. The script then follows the breakout: it marks the retest, ticks the target when price gets there, and drops it if the breakout fails.

What makes it different: ranges are not a box over a fixed number of bars. They are found relative to the chart's own volatility, measured in % of price, so one setting works across markets and price levels. And every target is followed to an end: reached, failed or expired.

[i]BTC/USD, 1D. The September range broke up and its target is still open. The panel shows how far away it is. The two ticked targets came from earlier ranges.[/i]
https://www.tradingview.com/x/BjHxWjtX/

[b]FEATURES[/b]

- Ranges found automatically. Tightness is judged against the chart's own recent bars, so there is no fixed width to set. Nothing shorter than 15 bars is drawn.
- A range that is still forming is shown too, with both possible targets: one if it breaks up, one if it breaks down.
- A target on every breakout: the box height added to the broken edge.
- Under each box: how many bars it lasted and how tall it is in %.
- A dotted riser connects each target to the box it came from.
- The retest is marked the first time price returns to the broken edge.
- Open targets are dashed. Reached targets turn solid and get a tick.
- If a breakout fully reverses, its target is dropped right away. It fades, or gets a label if you prefer.
- A panel with the nearest open target above and below price, plus the range price is in. When nothing is open, it shows how the last target ended.
- Six alerts: broken up, broken down, broken either way, retest, target reached, breakout failed.
- Almost every word, colour, size, width, line style and mark can be changed.

[b]HOW IT WORKS[/b]

A range is a stretch where the market has gone quiet. To decide what counts as quiet, the script takes the high-to-low range of the last 10 bars as a share of price and compares it with the last 200 bars. The quietest 30% count. Because it works in % and compares the chart with itself, the same settings behave the same way on a slow index, on a coin that is crashing, and on a coin that has just doubled.

A bar counts as quiet when the last 10 bars fit in a narrow band. That means the range actually started 9 bars earlier, so that is where the box starts, but never before the previous box ended. Stretches shorter than 15 bars are ignored. The box covers the highest high and lowest low of the stretch, and it keeps growing to the right as long as price keeps closing inside it. If the market goes quiet again while still inside a box, the box simply widens instead of a second one being drawn on top. A box that doesn't break within 80 bars is removed, because without a breakout there is no target.

Until it breaks, the box is dashed, and next to it are the two prices it points to: the box height above the top and below the bottom. They move while the range is still forming and disappear once it breaks.

The bar that closes outside the box ends it and creates the target: the box height, added once to the edge that broke.

After that, the script watches three things. The first time price comes back to the broken edge, the retest is marked. If price trades through the target from the next bar on (a wick is enough), the line turns solid, runs to that bar and gets a tick. If price instead closes back beyond the far side of the box, the breakout has failed and the target is dropped.

A target that is neither reached nor dropped within 120 bars expires and fades.

[i]Gold, 1D. A range is still forming, so it is dashed, with IF UP and IF DOWN showing where each breakout would lead. On the left, the July range broke up and its target was reached.[/i]
https://www.tradingview.com/x/dg4liCzJ/

[b]HOW TO READ IT[/b]

1. The grey box is where the market went sideways. Everything else comes from its height. After the break, the % under the box is exactly the distance to its target.
2. A dashed box hasn't broken yet. IF UP and IF DOWN show where each breakout would lead, and they can still move.
3. Box, riser and target line belong together. The riser shows which box a target came from.
4. A dashed line is an open target, with its price at the right end. A solid line is a reached target. It runs to the bar that reached it, and its price moves to the left end with a tick, over the box it came from, so it stays clear of the candles.
5. A small circle on the edge of a box is the retest.
6. A faint dotted line is a target that didn't make it. No words means the breakout failed. Faded words mean it ran out of time.
7. The panel only lists open targets. A dash means there is none on that side. When nothing is open, the last line shows how the last target ended.
8. Targets, retests and ticks are set on closed bars and never change afterwards. A dashed box and its IF UP / IF DOWN prices keep moving until the range breaks. The panel follows the live bar, so it never lists a target the current candle has already passed.

[i]EUR/USD, 4h. Ticked targets in both directions, retests marked on the broken edges, and an open target below price.[/i]
https://www.tradingview.com/x/8sImo41A/

[b]SETTINGS WORTH KNOWING[/b]

- [i]Shortest range worth keeping, bars[/i]: 15 by default. Raise it to see only the longest ranges.
- [i]Before the break[/i]: turn off the forming range or its IF UP / IF DOWN prices if you only want finished ranges.
- [i]Counts as tight when inside the quietest, %[/i]: decides how much shows up on your chart. Lower it for fewer, tighter ranges.
- [i]Target sits this many box heights away[/i]: 1.0 is the classic measured move. Raise it for a further target.
- [i]A target expires after, bars[/i]: how long a target stays open.
- [i]A target dies if price closes back through the far side of its box[/i]: turn off to keep failed breakouts open until they expire.
- [i]Look · the words → Where[/i]: the box name at the top of the box, in the middle, or above it.
- [i]Look · the mark → Plate[/i]: a filled plate under the tick, or around the whole reached target as a badge.
- [i]Look · failed targets → Label them[/i]: off by default to keep the chart clean. On, failed targets get a label instead of fading.
- [i]Look · break volume[/i]: off by default. Shows the breakout bar's volume as a multiple of the average before it.

[b]HONESTY[/b]

The target is simple arithmetic: the range height measured a second time. It is not a forecast, and the script doesn't claim price will get there. It only shows what happened afterwards.

A target is followed for 120 bars and then expires. A tick months later would say nothing about the breakout that made it.

Quiet is measured against the last 200 bars. On a market that has been flat for a very long time, an ordinary stretch can still count as quiet. If that happens on your chart, raise [i]Compared against the last, bars[/i].

Open source. Read it, change it, and tell me if something is wrong.

## Source Code

````pine
//@version=6
// Range Breakout Targets [FEELS]
// Version 2.5 — 2026-09-25
//
// Ranges boxed. Breakouts get a target. Targets get ticked.
//
// A box is a stretch where the last few bars are among the tightest the market has shown
// recently. When a bar closes above the box, the box height is added to its top edge and
// drawn as a target. Below the box, the same downwards. Nothing is predicted or fitted:
// the target is the box height measured a second time.
//
// The target line is dashed until price trades through it. Then it turns solid, runs to
// the bar that got there and gets a tick. A wick is enough.
//
// After the break the script marks the retest, the first time price comes back to the
// broken edge. A target is dropped as soon as price closes back beyond the far side of its
// box, since the breakout that made it has been undone.
//
// A target is followed for 120 bars. If it is still unreached by then it expires: it fades,
// leaves the panel, and can't be ticked later.
//
// While a box waits for its break, a new quiet stretch inside it belongs to the same
// consolidation and widens that box instead of starting a second one on top of it.
//
// Boxes, targets, retests, ticks and failures are all decided on closed bars. The panel is
// the only part that reads the bar still forming: it skips targets that bar has already
// passed and measures distance from the live price.

indicator("Range Breakout Targets [FEELS]", "Range Targets [FEELS]", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 2000,
     behind_chart = false)
// behind_chart = false draws everything in front of the candles, so the words inside a box
// stay readable. It has to be a constant, so it can't be a setting. If you want the candles
// on top, use Visual Order → Send to Back on the chart.

// ─────────────────────────────────────────────────────────────── inputs ────
grpZ = "Boxes"
grpT = "Targets"
grpL = "Look"

win      = input.int(10, "Bars measured for tightness", minval = 3, maxval = 100, group = grpZ,
     tooltip = "The range of the last this-many bars is what gets compared with recent history.")
hist     = input.int(200, "Compared against the last, bars", minval = 50, maxval = 1000, group = grpZ,
     tooltip = "How far back the comparison looks. Width is measured as a share of price, so the same setting works on a quiet index, on a coin in free fall, and on the same coin after it has doubled.")
pct      = input.float(30, "Counts as tight when inside the quietest, %", minval = 5, maxval = 80, step = 1, group = grpZ,
     tooltip = "Lower means fewer, tighter boxes. This is the setting that decides how much shows up on your chart.")
minBars  = input.int(15, "Shortest range worth keeping, bars", minval = 5, maxval = 200, group = grpZ,
     tooltip = "Counted from where the quiet really began, not from the first bar that tested as quiet. Anything shorter is treated as noise.")
waitBrk  = input.int(80, "Give up on a box that never breaks, bars", minval = 10, maxval = 500, group = grpZ,
     tooltip = "If price never leaves the box within this many bars, there is no breakout and no target, so the box is removed.")

mult     = input.float(1.0, "Target sits this many box heights away", minval = 0.2, maxval = 5.0, step = 0.1, group = grpT,
     tooltip = "1.0 is the classic measured move: the box height added once to the broken edge. Raise it for a further target.")
expireAt = input.int(120, "A target expires after, bars", minval = 20, maxval = 2000, group = grpT,
     tooltip = "A target still unreached after this many bars expires. It fades, leaves the panel, and can't be ticked later. A tick months after the breakout would say nothing about that breakout.")
keepExp  = input.bool(true, "Keep expired targets on the chart, faded", group = grpT,
     tooltip = "Off deletes them for a cleaner chart.")
dedupPct = input.float(1.0, "Don't repeat the words of a target within, % of an open one", minval = 0, maxval = 10, step = 0.1, group = grpT,
     tooltip = "Two neighbouring ranges can point at almost the same price. The second target is still drawn and followed, but without words or tick, so the two don't print on top of each other. 0 turns this off.")
failOn   = input.bool(true, "A target dies if price closes back through the far side of its box", group = grpT,
     tooltip = "Price broke out of the box and then closed beyond its opposite edge, so the breakout is undone. Its target stops being live right away instead of waiting to expire.")
tail     = input.int(26, "How far right an unreached target reaches, bars", minval = 4, maxval = 200, group = grpT,
     tooltip = "An unreached target stops here, so it never turns into a stripe across the chart. A reached one runs to the bar that got there.")
minLen   = input.int(9, "Shortest a target line is drawn, bars", minval = 1, maxval = 50, group = grpT,
     tooltip = "Keeps a target reached on the very next bar from being a line one pixel long.")

colUp   = input.color(color.new(#2E8B60, 0), "Up", inline = "c", group = grpL)
colDn   = input.color(color.new(#B5453C, 0), "Down", inline = "c", group = grpL)
colBox  = input.color(color.new(#6E7887, 0), "Box", inline = "c", group = grpL)

grpB = "Look · the box"
boxFill = input.int(74, "Fill, %", minval = 0, maxval = 100, group = grpB,
     tooltip = "100 leaves only the outline.")
boxEdge = input.int(1, "Border width", minval = 0, maxval = 4, group = grpB)
boxLine = input.string("Solid", "Border", options = ["Solid", "Dashed", "Dotted"], group = grpB)

grpTL = "Look · the target line"
wHit    = input.int(2, "Width once reached", minval = 1, maxval = 5, group = grpTL)
wOpen   = input.int(1, "Width while still open", minval = 1, maxval = 5, group = grpTL)
sOpen   = input.string("Dashed", "Style while still open", options = ["Dashed", "Dotted", "Solid"], group = grpTL)
fadeOpen = input.int(35, "Fade while still open, %", minval = 0, maxval = 90, group = grpTL,
     tooltip = "Open targets are a little faded so reached ones stand out.")

grpR = "Look · the riser"
riser   = input.bool(true, "Riser from the box up to its target", group = grpR,
     tooltip = "A thin line on the breakout bar from the broken edge to the target, so you can see which box a target came from. Keep it dotted or dashed: a solid one looks like a candle wick.")
sRiser  = input.string("Dotted", "Style", options = ["Dotted", "Dashed", "Solid"], group = grpR)
wRiser  = input.int(1, "Width", minval = 1, maxval = 4, group = grpR)
fadeRis = input.int(20, "Fade, %", minval = 0, maxval = 90, group = grpR)

grpM = "Look · the mark"
markOn  = input.bool(true, "Mark the bar that reached the target", group = grpM)
markTx  = input.string("✓", "Mark", options = ["✓", "●", "◆", "×", "▲", "▸"], group = grpM)
markSz  = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpM)
markOwn = input.bool(false, "Give the mark its own colour", inline = "m", group = grpM)
markCol = input.color(color.new(#3C4450, 0), "", inline = "m", group = grpM)
markAt  = input.string("Beside the target's words", "Where", options = ["Beside the target's words", "Above the end of the line"], group = grpM,
     tooltip = "Beside the words: right after the target's price, where the chart is almost always empty. Above the end: over the bar that reached it, where it often lands on candles or on the next box's stats.")
markBg  = input.string("None", "Plate", options = ["None", "Under the mark", "The whole target"], inline = "mb", group = grpM,
     tooltip = "A filled rounded plate in the target's colour. Under the mark: only the mark sits on it, at its own size. The whole target: mark and price become one badge, at the words' size. Above the end of the line, both options put the plate under the mark only.")
markBgTx = input.color(color.new(color.white, 0), "", inline = "mb", group = grpM)

grpW = "Look · the words"
boxTxtOn = input.bool(true, "Name the box", inline = "w1", group = grpW)
boxTxt   = input.string("RANGE", "", inline = "w1", group = grpW,
     tooltip = "Call it whatever you like. RANGE needs no explaining; BASE, COIL or CONSOLIDATION work too.")
boxTxtPos = input.string("Top", "Where", options = ["Top", "Middle", "Above the box"], group = grpW,
     tooltip = "Always centred across the box. Top sits just inside the upper edge, clear of the target words. Above the box sits just outside the upper edge and uses the colour set below, because white would disappear on the chart background.")
boxPlate  = input.bool(false, "Put it on a plate", group = grpW,
     tooltip = "Off is plain text. On adds a filled plate behind it, which helps if your box fill is very faint.")
boxTxtCol = input.color(color.new(color.white, 0), "Its colour", group = grpW,
     tooltip = "White reads well on the grey box. On a light chart with a faint box fill, darken this first.")
boxOutCol = input.color(color.new(#6E7887, 0), "Its colour above the box", group = grpW,
     tooltip = "Only used when the name sits above the box without a plate. Grey by default, to match the stats under the box.")
tgtTxtOn = input.bool(true, "Name the target", inline = "w2", group = grpW)
tgtTxt   = input.string("TARGET", "", inline = "w2", group = grpW)
tgtPrice = input.bool(true, "Put the price after it", group = grpW)
tgtHit   = input.string("Keep", "Once reached, its words", options = ["Keep", "Price only", "Hide"], group = grpW,
     tooltip = "Reached targets can end up inside the next range. Price only or Hide keeps a busy chart clean. The tick stays either way.")
tgtHitAt = input.string("Left end", "Once reached, its words sit at", options = ["Left end", "Right end"], group = grpW,
     tooltip = "Left end: on the breakout bar, over the range the target came from, where the chart is almost always empty. Right end: where price reached the target, which is often where the next range forms, so the words can land on candles.")
wordSz   = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpW)
wordOwn  = input.bool(false, "One colour for every word", inline = "w3", group = grpW)
wordCol  = input.color(color.new(#4E5661, 0), "", inline = "w3", group = grpW)

grpE = "Before the break"
liveOn  = input.bool(true, "Show a range while it is still forming", group = grpE,
     tooltip = "Drawn dashed once it is long enough to count, and redrawn every bar. It keeps changing until price leaves it, which is why it is dashed.")
condOn  = input.bool(true, "Show where each break would lead", group = grpE,
     tooltip = "The two targets the range would give: one if price leaves through the top, one through the bottom. They move while the range forms and disappear when it breaks and the real target is drawn.")
condUp  = input.string("IF UP", "Words above", inline = "cw", group = grpE)
condDn  = input.string("IF DOWN", "below", inline = "cw", group = grpE)
condLen = input.int(22, "How far right they reach, bars", minval = 5, maxval = 100, group = grpE)

grpX = "Look · the retest"
rtOn    = input.bool(true, "Mark the retest of the broken edge", group = grpX,
     tooltip = "After a break, price often comes back to the edge it just left before moving on. The first time it does, a mark goes on that edge.")
rtTx    = input.string("○", "Mark", options = ["○", "●", "◇", "◆", "RT"], group = grpX)
rtSz    = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpX)
rtOwn   = input.bool(false, "Give it its own colour", inline = "rt", group = grpX)
rtCol   = input.color(color.new(#3C4450, 0), "", inline = "rt", group = grpX)

grpF = "Look · failed targets"
failKeep = input.bool(true, "Keep failed targets on the chart", group = grpF,
     tooltip = "On, a failed target stays as a faint dotted line so you can see the breakout that didn't follow through. Off, it is deleted.")
failLbl  = input.bool(false, "Label them", group = grpF,
     tooltip = "Off by default: a failed target just fades. On, its line runs to the bar that killed it and gets a label.")
failTx   = input.string("FAILED", "Label", group = grpF)
failMk   = input.string("✕", "Mark in front of it", options = ["✕", "×", "✗", "none"], group = grpF)
failCol  = input.color(color.new(#8C939E, 0), "Colour", group = grpF)

grpS = "Look · range stats"
stOn    = input.bool(true, "Show the range's stats", group = grpS,
     tooltip = "How many bars the range lasted and how tall it is. After the break, the % is measured from the broken edge, so it equals the distance to the target. Before that it is measured against the current price.")
stPos   = input.string("Under the box", "Where", options = ["Under the box", "Inside, along the bottom"], group = grpS,
     tooltip = "Under the box, nothing sits on top of it. Inside, candle wicks crowd the bottom edge, because the bottom of a box is its lowest low.")
stBars  = input.bool(true, "How many bars it lasted", group = grpS)
stPct   = input.bool(true, "Its height, in % of price", group = grpS)
stSz    = input.string("Small", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpS)
stCol   = input.color(color.new(#6E7887, 0), "Colour", group = grpS,
     tooltip = "Grey by default because under the box it sits on the chart background. If you move it inside the box, white reads better.")

grpV = "Look · break volume"
volOn   = input.bool(false, "Show the breakout bar's volume", group = grpV,
     tooltip = "Off by default. Shown at the break as a multiple of the average volume before it, e.g. VOL 1.7×. Symbols with no volume, like some indices, show nothing.")
volLen  = input.int(20, "Averaged over, bars", minval = 2, maxval = 200, group = grpV)

grpP = "Panel"
panelOn  = input.bool(true, "Show the panel", group = grpP,
     tooltip = "The nearest open target above price and the nearest open target below.")
panelPos = input.string("Top right", "Where", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = grpP)
panelSz  = input.string("Normal", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = grpP)
panelPc  = input.bool(true, "Show the distance in %", group = grpP)
panelLast = input.bool(true, "When nothing is live, show the last result", group = grpP,
     tooltip = "Instead of an empty panel, shows how the last finished target ended: reached, failed or expired.")
panelRng = input.bool(true, "Show the range price is sitting in", group = grpP,
     tooltip = "While a box waits for its break, a third line shows its edges: the two prices whose break will draw the next target.")
panelTtl = input.string("RANGE TARGETS", "Heading", group = grpP,
     tooltip = "Leave empty to drop the heading row.")
panelBg  = input.color(color.new(#2A2E39, 100), "Background", inline = "p", group = grpP,
     tooltip = "Fully transparent by default, so the panel is just text over the chart. Lower the transparency if your chart is busy and the numbers need a background.")
panelTx  = input.color(color.new(#787F8C, 0), "Labels", inline = "p", group = grpP,
     tooltip = "Mid grey, readable on light and dark charts. The prices use their own colours; this is only the words next to them.")

// ─────────────────────────────────────────────────── look, resolved once ────
lineStyle(string s) =>
    s == "Dotted" ? line.style_dotted : s == "Solid" ? line.style_solid : line.style_dashed
sizeOf(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal
// Rough glyph height TradingView gives each label size, in pixels — only used to work out how
// much room to leave beside a target's words for a mark drawn at a different size.
sizePx(string s) =>
    switch s
        "Tiny"   => 8.0
        "Small"  => 10.0
        "Large"  => 16.0
        "Huge"   => 24.0
        => 12.0
// The distance to a target as a signed percentage. Built by hand because a "+" inside a
// format string is a literal, which printed a negative number as "-+34.2%".
pcTxt(float lvl) =>
    d = (lvl / close - 1) * 100
    (d >= 0 ? "+" : "−") + str.tostring(math.abs(d), "0.0") + "%"
panelPosition() =>
    switch panelPos
        "Top left"      => position.top_left
        "Bottom right"  => position.bottom_right
        "Bottom left"   => position.bottom_left
        "Middle right"  => position.middle_right
        => position.top_right
// The words on a target: the name and the price. The mark is a separate label so that
// its own size and colour actually reach it — inside this string they never could.
targetWords(float px) =>
    s = tgtTxtOn ? tgtTxt : ""
    s := s + (tgtPrice ? (tgtTxtOn ? "  " : "") + str.tostring(px, format.mintick) : "")
    s
boxBorderStyle = boxLine == "Dashed" ? line.style_dashed : boxLine == "Dotted" ? line.style_dotted : line.style_solid
// The stats line for a box: how long it lasted and how tall it is against price.
statsText(int nb, float h, float ref) =>
    (stBars ? str.tostring(nb) + " bars" : "") + (stBars and stPct ? "  ·  " : "") +
         (stPct ? str.tostring(h / ref * 100, "0.0") + "%" : "")
// Where the box's name sits. Always centred across it; Top tucks just inside the upper edge.
boxTxtY(float hiB, float loB) =>
    boxTxtPos == "Above the box" ? hiB : boxTxtPos == "Top" ? hiB - (hiB - loB) * 0.13 : (hiB + loB) / 2
// Above the box the label hangs its text over the anchor; inside it is centred on it.
boxTxtStyle() =>
    boxTxtPos == "Above the box" ? label.style_label_down : boxPlate ? label.style_label_center : label.style_none
// Outside the box and without a plate, white would sit on the chart background.
boxTxtColor() =>
    boxTxtPos == "Above the box" and not boxPlate ? boxOutCol : boxTxtCol

// ──────────────────────────────────────────────────────── tight or not ────
// Width as a share of price, not in price units. In price units, after a 40% rally every
// range is 40% wider, so a quiet stretch after a big trend would be compared with cheaper
// bars in the lookback and missed.
rng   = (ta.highest(high, win) - ta.lowest(low, win)) / close
thr   = ta.percentile_nearest_rank(rng, hist, pct)
tight = bar_index > hist and rng <= thr

// ──────────────────────────────────────────────────────────────── state ────
// A box forms, then waits to be left, then its target waits to be reached.
// Three stages, so a box in stage two and a target in stage three coexist.
var int   curFrom = na
var int   lastRight = -1                        // where the last box ended; a new one never reaches back past it
var float curHi   = na
var float curLo   = na
var bool  curOpen = false

var array<box>   pBox  = array.new<box>()      // boxes waiting to be broken
var array<label> pLab  = array.new<label>()
var array<float> pHi   = array.new<float>()
var array<float> pLo   = array.new<float>()
var array<int>   pFrom = array.new<int>()
// Events, rebuilt every bar so the alerts below can see them.
brokeUp = false
brokeDn = false
gotTgt  = false
gotRt   = false
gotFail = false

var array<line>  tLine = array.new<line>()     // targets waiting to be reached
var array<label> tLab  = array.new<label>()
var array<float> tPx   = array.new<float>()
var array<bool>  tUp   = array.new<bool>()
var array<int>   tFrom = array.new<int>()
var array<float> tEdge = array.new<float>()    // the edge that broke — where a retest lands
var array<float> tFar  = array.new<float>()    // the opposite edge — a close beyond it kills the target
var array<bool>  tRt   = array.new<bool>()     // retest already marked
var array<bool>  tQuiet = array.new<bool>()    // words and tick left off: repeats an open target

// Before the break: the range still forming, and where each break would lead.
var box   liveBox  = na
var label liveName = na
var label liveStat = na
var line  cUpL = na
var line  cDnL = na
var label cUpT = na
var label cDnT = na
var float pvHi = na                             // what the panel reads about it
var float pvLo = na
var bool  pvForm = false

// The last target the script finished with, for a panel that is never empty.
var float lastPx = na
var int   lastBars = na
var string lastSt = ""
var bool  lastUp = true

volAvg = ta.sma(volume, volLen)

if barstate.isconfirmed

    // ── stage one: the box being formed ──
    if tight
        if not curOpen
            // A bar tests as quiet when the last `win` bars fit a narrow band, so the range began
            // win-1 bars before it — never earlier than the bar after the last box ended.
            curOpen := true
            curFrom := math.max(bar_index - (win - 1), lastRight + 1)
            curHi   := high
            curLo   := low
            if bar_index > curFrom
                for q = 1 to bar_index - curFrom
                    curHi := math.max(curHi, high[q])
                    curLo := math.min(curLo, low[q])
        else
            curHi := math.max(curHi, high)
            curLo := math.min(curLo, low)
    else if curOpen
        curOpen := false
        if bar_index - curFrom >= minBars
            // A box still waiting for its break has had every close since it formed land inside
            // it, so a new quiet stretch now is the same consolidation carrying on. It widens
            // that box instead of being drawn as a second one on top of it.
            joined = false
            if array.size(pBox) > 0
                j     = array.size(pBox) - 1
                prevH = array.get(pHi, j)
                prevL = array.get(pLo, j)
                if curLo <= prevH and curHi >= prevL
                    nH = math.max(prevH, curHi)
                    nL = math.min(prevL, curLo)
                    array.set(pHi, j, nH)
                    array.set(pLo, j, nL)
                    array.set(pFrom, j, bar_index)          // the wait for a break restarts
                    b = array.get(pBox, j)
                    box.set_top(b, nH)
                    box.set_bottom(b, nL)
                    box.set_right(b, bar_index - 1)
                    lj = array.get(pLab, j)
                    label.set_x(lj, math.round((box.get_left(b) + bar_index - 1) / 2))
                    label.set_y(lj, boxTxtY(nH, nL))
                    joined := true
            if not joined
                // Dashed while it waits: a box nobody has broken yet is still undecided.
                b = box.new(curFrom, curHi, bar_index - 1, curLo,
                     border_color = color.new(colBox, boxEdge == 0 ? 100 : 25),
                     border_width = math.max(boxEdge, 1),
                     border_style = liveOn ? line.style_dashed : boxBorderStyle,
                     bgcolor = color.new(colBox, liveOn ? math.min(100, boxFill + 6) : boxFill))
                // Always built so the arrays stay in step; hidden by transparency when off.
                lb = label.new(math.round((curFrom + bar_index - 1) / 2), boxTxtY(curHi, curLo),
                         boxTxtOn ? boxTxt : "",
                         style = boxTxtStyle(),
                         textcolor = color.new(boxTxtColor(), boxTxtOn ? 0 : 100),
                         color = color.new(colBox, boxTxtOn and boxPlate ? 15 : 100),
                         size = sizeOf(wordSz), textalign = text.align_center)
                array.push(pBox, b)
                array.push(pLab, lb)
                array.push(pHi, curHi)
                array.push(pLo, curLo)
                array.push(pFrom, bar_index)

    // ── stage two: a finished box waiting for price to leave it ──
    if array.size(pBox) > 0
        for i = array.size(pBox) - 1 to 0
            hiB  = array.get(pHi, i)
            loB  = array.get(pLo, i)
            from = array.get(pFrom, i)
            up   = close > hiB
            dn   = close < loB

            if up or dn
                // The box runs on to the bar that breaks it: no close left the range before
                // this bar, so it was still a range. The riser then stands on the box's edge.
                brokeUp := brokeUp or up
                brokeDn := brokeDn or dn
                bBox = array.get(pBox, i)
                box.set_right(bBox, bar_index)
                box.set_border_style(bBox, boxBorderStyle)
                box.set_bgcolor(bBox, color.new(colBox, boxFill))
                lastRight := bar_index
                lbB  = array.get(pLab, i)
                label.set_x(lbB, math.round((box.get_left(bBox) + bar_index) / 2))
                label.set_y(lbB, boxTxtY(hiB, loB))
                h    = hiB - loB
                edge = up ? hiB : loB
                px   = up ? edge + mult * h : edge - mult * h
                col  = up ? colUp : colDn
                // Dotted riser standing on the break bar, from the edge that gave way up
                // to the target. Drawn once and never touched again.
                if riser
                    line.new(bar_index, edge, bar_index, px, color = color.new(col, fadeRis),
                         width = wRiser, style = lineStyle(sRiser))
                ln   = line.new(bar_index, px, bar_index + minLen, px,
                             color = color.new(col, fadeOpen), width = wOpen,
                             style = lineStyle(sOpen))
                quiet = false
                if dedupPct > 0 and array.size(tPx) > 0
                    for q = 0 to array.size(tPx) - 1
                        if array.get(tUp, q) == up and math.abs(array.get(tPx, q) / px - 1) * 100 <= dedupPct
                            quiet := true
                lbT  = label.new(bar_index + minLen, px, targetWords(px),
                             style = label.style_label_left,
                             textcolor = color.new(wordOwn ? wordCol : col, quiet ? 100 : 0),
                             color = color.new(color.white, 100),
                             size = sizeOf(wordSz), textalign = text.align_left)
                // Range stats, written once the box has its final width.
                if stOn and (stBars or stPct)
                    sTxt = statsText(bar_index - box.get_left(bBox) + 1, h, edge)
                    // Anchored on the bottom edge: hanging below it by default, or sitting just
                    // inside it, at the same distance whatever the box's height.
                    label.new(math.round((box.get_left(bBox) + bar_index) / 2), loB, sTxt,
                         style = stPos == "Under the box" ? label.style_label_up : label.style_label_down, textcolor = stCol,
                         color = color.new(color.white, 100), size = sizeOf(stSz), textalign = text.align_center)
                // Breakout volume against the average before it. Skipped where there is none.
                if volOn and not na(volume) and not na(volAvg[1]) and volAvg[1] > 0
                    label.new(bar_index, edge, " VOL " + str.tostring(volume / volAvg[1], "0.0") + "×",
                         style = up ? label.style_label_upper_left : label.style_label_lower_left,
                         textcolor = col, color = color.new(color.white, 100), size = size.small)
                array.push(tLine, ln)
                array.push(tLab, lbT)
                array.push(tPx, px)
                array.push(tUp, up)
                array.push(tFrom, bar_index)
                array.push(tEdge, edge)
                array.push(tFar, up ? loB : hiB)
                array.push(tRt, false)
                array.push(tQuiet, quiet)
                array.remove(pBox, i)
                array.remove(pLab, i)
                array.remove(pHi, i)
                array.remove(pLo, i)
                array.remove(pFrom, i)
                // A quiet stretch already under way began inside the box that has just broken.
                // Left running, it would become a new box starting a bar or three before this
                // one ends. The range after a break is a new range, so it starts fresh.
                if curOpen
                    curOpen := false

            else if bar_index - from >= waitBrk
                lastRight := math.max(lastRight, box.get_right(array.get(pBox, i)))
                box.delete(array.get(pBox, i))
                label.delete(array.get(pLab, i))
                array.remove(pBox, i)
                array.remove(pLab, i)
                array.remove(pHi, i)
                array.remove(pLo, i)
                array.remove(pFrom, i)

            else
                // Still inside it. The box grows with price until something closes out of it.
                bW = array.get(pBox, i)
                box.set_right(bW, bar_index)
                lbW = array.get(pLab, i)
                label.set_x(lbW, math.round((box.get_left(bW) + bar_index) / 2))
                label.set_y(lbW, boxTxtY(hiB, loB))

    // ── stage three: a target waiting to be reached ──
    if array.size(tLine) > 0
        for i = array.size(tLine) - 1 to 0
            ln   = array.get(tLine, i)
            lbT  = array.get(tLab, i)
            px   = array.get(tPx, i)
            up   = array.get(tUp, i)
            from = array.get(tFrom, i)
            edge = array.get(tEdge, i)
            far  = array.get(tFar, i)
            qt   = array.get(tQuiet, i)
            col  = up ? colUp : colDn
            // Never on the break bar: the target only exists once that bar has closed, so
            // whatever its wick did before then cannot count as reaching it.
            got  = bar_index > from and (up ? high >= px : low <= px)
            dead = failOn and bar_index > from and (up ? close < far : close > far)

            // The first return to the edge that broke. Never on the break bar itself — that
            // bar crossed the edge on its way out, which is not a retest.
            if not array.get(tRt, i) and bar_index > from and (up ? low <= edge : high >= edge)
                array.set(tRt, i, true)
                gotRt := true
                if rtOn
                    label.new(bar_index, edge, rtTx, style = label.style_label_center,
                         textcolor = rtOwn ? rtCol : col, color = color.new(color.white, 100),
                         size = sizeOf(rtSz), textalign = text.align_center)

            if got
                gotTgt := true
                lastPx := px
                lastBars := bar_index - from
                lastSt := "hit"
                lastUp := up
                // Only ever reached inside the window, so this end is at most expireAt bars
                // behind the current bar — safely inside what a line may be redrawn to.
                endX = math.max(bar_index, from + minLen)
                line.set_x2(ln, endX)
                // The left end sits over the range the target came from, which is empty at the
                // target's price; the right end is where the next range tends to form.
                if tgtHitAt == "Left end"
                    label.set_x(lbT, from)
                    label.set_style(lbT, label.style_label_right)
                    label.set_textalign(lbT, text.align_right)
                else
                    label.set_x(lbT, endX)
                line.set_style(ln, line.style_solid)
                // A near-repeat stays thin and faint: two heavy lines on the same price read as
                // a level the market respected twice, which is not what happened.
                line.set_width(ln, qt ? 1 : wHit)
                line.set_color(ln, color.new(col, qt ? 65 : 0))
                // Beside the words the mark shares their label, so the two can never drift apart.
                beside  = markOn and not qt and markAt == "Beside the target's words"
                badge   = beside and markBg == "The whole target"
                // The mark always sits on the side of the words nearest the line.
                atLeft  = tgtHitAt == "Left end"
                plateC  = markOwn ? markCol : col
                hitTx   = tgtHit == "Price only" ? str.tostring(px, format.mintick) : targetWords(px)
                // Room left at the end of the words for the mark, which has its own label and
                // size: blank braille cells, because TradingView trims trailing spaces.
                gapN    = math.ceil((sizePx(markSz) * (markBg == "None" ? 1.0 : 1.8) + sizePx(wordSz) * 0.8) / (sizePx(wordSz) * 0.5))
                if qt
                    label.set_textcolor(lbT, color.new(col, 100))
                else if badge
                    label.set_text(lbT, tgtHit == "Hide" ? markTx : atLeft ? hitTx + "  " + markTx : markTx + "  " + hitTx)
                    label.set_textcolor(lbT, markBgTx)
                    label.set_color(lbT, color.new(plateC, 0))
                else if beside and tgtHit != "Hide"
                    label.set_text(lbT, atLeft ? hitTx + str.repeat("⠀", gapN) : str.repeat("⠀", gapN) + hitTx)
                else if tgtHit == "Hide"
                    label.set_textcolor(lbT, color.new(col, 100))
                else if tgtHit == "Price only"
                    label.set_text(lbT, hitTx)
                // Beside the words: its own label on the same anchor, filling the room left for it.
                // Above the end: over the line rather than on it, clear of it at any scale.
                if markOn and not qt and not badge
                    label.new(beside ? label.get_x(lbT) : endX, px, markTx,
                         style = not beside ? label.style_label_down : atLeft ? label.style_label_right : label.style_label_left,
                         textcolor = markBg != "None" ? markBgTx : plateC,
                         color = color.new(plateC, markBg != "None" ? 0 : 100),
                         size = sizeOf(markSz), textalign = text.align_center)
                array.remove(tLine, i)
                array.remove(tLab, i)
                array.remove(tPx, i)
                array.remove(tUp, i)
                array.remove(tFrom, i)
                array.remove(tEdge, i)
                array.remove(tFar, i)
                array.remove(tRt, i)
                array.remove(tQuiet, i)

            else if dead
                // Price has closed back beyond the far side of the box: the breakout is undone.
                gotFail := true
                lastPx := px
                lastBars := bar_index - from
                lastSt := "fail"
                lastUp := up
                if not failKeep
                    line.delete(ln)
                    label.delete(lbT)
                else if failLbl
                    endX = math.max(bar_index, from + minLen)
                    line.set_x2(ln, endX)
                    line.set_style(ln, line.style_dashed)
                    line.set_color(ln, color.new(failCol, 25))
                    label.set_x(lbT, endX)
                    label.set_text(lbT, (failMk == "none" ? "" : failMk + "  ") + failTx +
                         (tgtPrice ? "  " + str.tostring(px, format.mintick) : ""))
                    label.set_textcolor(lbT, color.new(failCol, qt ? 100 : 0))
                else
                    // The quiet default: a faint dotted line out to its usual tail, no words.
                    line.set_x2(ln, from + tail)
                    line.set_style(ln, line.style_dotted)
                    line.set_color(ln, color.new(colBox, 70))
                    label.set_textcolor(lbT, color.new(colBox, 100))
                array.remove(tLine, i)
                array.remove(tLab, i)
                array.remove(tPx, i)
                array.remove(tUp, i)
                array.remove(tFrom, i)
                array.remove(tEdge, i)
                array.remove(tFar, i)
                array.remove(tRt, i)
                array.remove(tQuiet, i)

            else if bar_index - from >= expireAt
                // Expired. Faded rather than left looking live, and off the panel, so a dashed
                // line on the chart always means a target that is still genuinely open.
                lastPx := px
                lastBars := bar_index - from
                lastSt := "exp"
                lastUp := up
                if keepExp
                    line.set_color(ln, color.new(colBox, 70))
                    line.set_style(ln, line.style_dotted)
                    label.set_textcolor(lbT, color.new(colBox, qt ? 100 : 55))
                else
                    line.delete(ln)
                    label.delete(lbT)
                array.remove(tLine, i)
                array.remove(tLab, i)
                array.remove(tPx, i)
                array.remove(tUp, i)
                array.remove(tFrom, i)
                array.remove(tEdge, i)
                array.remove(tFar, i)
                array.remove(tRt, i)
                array.remove(tQuiet, i)

            else if bar_index <= from + tail
                // Still growing towards its tail. Past that it is left alone — nothing is
                // gained by rewriting the same coordinates every bar.
                stopAt = math.max(bar_index, from + minLen)
                line.set_x2(ln, stopAt)
                label.set_x(lbT, stopAt)

// ─────────────────────────────────────────────────────── before the break ────
if barstate.isconfirmed
    float lvHi = na
    float lvLo = na
    int   lvL  = na
    bool  lvForm = false
    if array.size(pBox) > 0
        k = array.size(pBox) - 1
        lvHi := array.get(pHi, k)
        lvLo := array.get(pLo, k)
        lvL  := box.get_left(array.get(pBox, k))
    else if curOpen and bar_index - curFrom + 1 >= minBars
        lvHi := curHi
        lvLo := curLo
        lvL  := curFrom
        lvForm := true
    pvHi := lvHi
    pvLo := lvLo
    pvForm := lvForm
    show = liveOn and not na(lvHi)

    // A range still forming has no box yet: draw a dashed one, with its name, that moves with it.
    if show and lvForm
        if na(liveBox)
            liveBox := box.new(lvL, lvHi, bar_index, lvLo, border_color = color.new(colBox, 25),
                 border_width = math.max(boxEdge, 1), border_style = line.style_dashed,
                 bgcolor = color.new(colBox, math.min(100, boxFill + 6)))
            liveName := label.new(math.round((lvL + bar_index) / 2), boxTxtY(lvHi, lvLo), boxTxtOn ? boxTxt : "",
                 style = boxTxtStyle(), textcolor = color.new(boxTxtColor(), boxTxtOn ? 0 : 100),
                 color = color.new(colBox, boxTxtOn and boxPlate ? 15 : 100), size = sizeOf(wordSz), textalign = text.align_center)
        else
            box.set_lefttop(liveBox, lvL, lvHi)
            box.set_rightbottom(liveBox, bar_index, lvLo)
            label.set_xy(liveName, math.round((lvL + bar_index) / 2), boxTxtY(lvHi, lvLo))
    else if not na(liveBox)
        box.delete(liveBox)
        label.delete(liveName)
        liveBox := na
        liveName := na

    // Its stats, live — for a forming range and for a finished box waiting to break.
    if show and stOn and (stBars or stPct)
        sx = math.round((lvL + bar_index) / 2)
        st = statsText(bar_index - lvL + 1, lvHi - lvLo, close)
        if na(liveStat)
            liveStat := label.new(sx, lvLo, st, style = stPos == "Under the box" ? label.style_label_up : label.style_label_down, textcolor = stCol,
                 color = color.new(color.white, 100), size = sizeOf(stSz), textalign = text.align_center)
        else
            label.set_xy(liveStat, sx, lvLo)
            label.set_text(liveStat, st)
    else if not na(liveStat)
        label.delete(liveStat)
        liveStat := na

    // Where each break would lead. Conditional, so dashed and faded, and gone once it breaks.
    if show and condOn
        hh  = lvHi - lvLo
        pUp = lvHi + mult * hh
        pDn = lvLo - mult * hh
        tUpTx = condUp + "  " + str.tostring(pUp, format.mintick)
        tDnTx = condDn + "  " + str.tostring(pDn, format.mintick)
        if na(cUpL)
            cUpL := line.new(bar_index, pUp, bar_index + condLen, pUp, color = color.new(colUp, 45), width = 1, style = line.style_dashed)
            cDnL := line.new(bar_index, pDn, bar_index + condLen, pDn, color = color.new(colDn, 45), width = 1, style = line.style_dashed)
            cUpT := label.new(bar_index, pUp, tUpTx, style = label.style_label_lower_left, textcolor = color.new(colUp, 15),
                 color = color.new(color.white, 100), size = sizeOf(wordSz), textalign = text.align_left)
            cDnT := label.new(bar_index, pDn, tDnTx, style = label.style_label_upper_left, textcolor = color.new(colDn, 15),
                 color = color.new(color.white, 100), size = sizeOf(wordSz), textalign = text.align_left)
        else
            line.set_xy1(cUpL, bar_index, pUp)
            line.set_xy2(cUpL, bar_index + condLen, pUp)
            line.set_xy1(cDnL, bar_index, pDn)
            line.set_xy2(cDnL, bar_index + condLen, pDn)
            label.set_xy(cUpT, bar_index, pUp)
            label.set_text(cUpT, tUpTx)
            label.set_xy(cDnT, bar_index, pDn)
            label.set_text(cDnT, tDnTx)
    else if not na(cUpL)
        line.delete(cUpL)
        line.delete(cDnL)
        label.delete(cUpT)
        label.delete(cDnT)
        cUpL := na
        cDnL := na
        cUpT := na
        cDnT := na

// ──────────────────────────────────────────────────────────────── panel ────
// The nearest target still open above price and the nearest still open below, straight out of
// the arrays above: a price named here is a dashed, unexpired line on the chart.
var table pnl = na

if panelOn and barstate.islast
    // Picked by the target's own direction, not by where it sits against price, and anything
    // the still-forming bar has already traded through is skipped. Targets are only marked
    // reached on a closed bar, so without this a target crossed a minute ago would show up
    // in the wrong row until the bar closed.
    float upPx = na
    float dnPx = na
    if array.size(tPx) > 0
        for i = 0 to array.size(tPx) - 1
            p  = array.get(tPx, i)
            ok = array.get(tUp, i)
            if ok and high < p and (na(upPx) or p < upPx)
                upPx := p
            if not ok and low > p and (na(dnPx) or p > dnPx)
                dnPx := p

    head = str.length(str.tostring(panelTtl)) > 0
    // Always three rows, even when the heading is empty. Building it to fit would mean the
    // table changing shape when that setting changes, and the table is only ever built once.
    // No frame and no cell borders, so it doesn't read as a spreadsheet.
    if na(pnl)
        pnl := table.new(panelPosition(), 2, 4, bgcolor = panelBg,
             border_width = 0, frame_width = 0)
    table.clear(pnl, 0, 0, 1, 3)

    if head
        table.cell(pnl, 0, 0, panelTtl, text_color = color.new(panelTx, 35),
             text_size = size.tiny, text_halign = text.align_left)

    r0 = head ? 1 : 0
    // A dash rather than a blank: "there is no open target that way" is information too.
    upTxt = na(upPx) ? "—" : str.tostring(upPx, format.mintick) + (panelPc ? "   " + pcTxt(upPx) : "")
    dnTxt = na(dnPx) ? "—" : str.tostring(dnPx, format.mintick) + (panelPc ? "   " + pcTxt(dnPx) : "")

    table.cell(pnl, 0, r0,     "▲  next target", text_color = color.new(panelTx, 0),
         text_size = sizeOf(panelSz), text_halign = text.align_left)
    table.cell(pnl, 1, r0,     upTxt, text_color = color.new(colUp, na(upPx) ? 45 : 0),
         text_size = sizeOf(panelSz), text_halign = text.align_right)
    table.cell(pnl, 0, r0 + 1, "▼  next target", text_color = color.new(panelTx, 0),
         text_size = sizeOf(panelSz), text_halign = text.align_left)
    table.cell(pnl, 1, r0 + 1, dnTxt, text_color = color.new(colDn, na(dnPx) ? 45 : 0),
         text_size = sizeOf(panelSz), text_halign = text.align_right)

    // Third line: the range price is in right now if there is one, otherwise the last result.
    if panelRng and not na(pvHi)
        table.cell(pnl, 0, r0 + 2, pvForm ? "▢  forming range" : "▢  in range", text_color = color.new(panelTx, 0),
             text_size = sizeOf(panelSz), text_halign = text.align_left)
        table.cell(pnl, 1, r0 + 2, str.tostring(pvLo, format.mintick) + "  –  " +
             str.tostring(pvHi, format.mintick), text_color = color.new(panelTx, 0),
             text_size = sizeOf(panelSz), text_halign = text.align_right)
    else if panelLast and na(upPx) and na(dnPx) and not na(lastPx)
        lastTx = lastSt == "hit" ? "✓  " + str.tostring(lastPx, format.mintick) + "  ·  " + str.tostring(lastBars) + " bars" :
             lastSt == "fail" ? "✕  " + str.tostring(lastPx, format.mintick) + "  ·  failed" :
             "·  " + str.tostring(lastPx, format.mintick) + "  ·  expired"
        table.cell(pnl, 0, r0 + 2, "last", text_color = color.new(panelTx, 0),
             text_size = sizeOf(panelSz), text_halign = text.align_left)
        table.cell(pnl, 1, r0 + 2, lastTx, text_color = lastSt == "hit" ? color.new(lastUp ? colUp : colDn, 0) : color.new(panelTx, 0),
             text_size = sizeOf(panelSz), text_halign = text.align_right)

// ─────────────────────────────────────────────────────────────── alerts ────
alertcondition(brokeUp, "Box broken upwards", "Price closed above a box — a target is now drawn above it")
alertcondition(brokeDn, "Box broken downwards", "Price closed below a box — a target is now drawn below it")
alertcondition(brokeUp or brokeDn, "Box broken, either way", "Price closed out of a box and a target has been drawn")
alertcondition(gotTgt, "Target reached", "Price has traded through a target")
alertcondition(gotRt, "Retest", "Price has come back to the edge of a box it broke out of")
alertcondition(gotFail, "Breakout failed", "Price closed back beyond the far side of a box — its target is dead")

// A target never reached within its window fades and is no longer watched.
````
