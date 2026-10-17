# Auto Fibonacci Retracement, Golden Zone & OTE Levels [LunqFX]

- url: https://www.tradingview.com/script/3KtyXsmo-Auto-Fibonacci-Retracement-Golden-Zone-OTE-Levels-LunqFX/
- type: indicator
- pine_id: PUB;b898f61eb8d8402ea10fbd1ddf926652
- version: 1.0

## Description

Every fibonacci retracement tool draws the same six lines, and every one of them assumes you already picked the right swing. Drag the fib from a different high and the golden pocket lands somewhere else entirely — so the fibonacci level you are about to buy is not a level the market chose, it is a level your cursor chose.

This auto fibonacci indicator takes the swing out of your hands. The leg is anchored to confirmed pivots and re-anchors itself the moment structure makes a new extreme, so the fib retracement on the chart is always drawn from the leg the market is actually trading, and the golden pocket and OTE zone sit where that leg puts them.

And it adds the number no fibonacci retracement indicator has ever given you: how deep this symbol actually retraces.

Included: automatic fibonacci retracement from confirmed swing pivots, an adjustable golden pocket and OTE zone filled on the chart, fibonacci extension targets beyond the leg, gold candles on the bars that traded inside the zone, a measured typical retracement depth for the current symbol, a dashboard reading the live fib retracement, and alerts on the zone.

❶ HOW THE FIBONACCI IS ANCHORED

Swing points come from confirmed pivots, so a leg only exists once the bars on both sides of its pivot have closed. Nothing appears and then vanishes.

The active leg runs from the anchor pivot to the extreme pivot. A new pivot beyond the extreme, in the same direction, extends the leg — the fibonacci retracement stretches with it. A pivot the other way flips the leg and the fib re-anchors to the new one. There is no setting for "which high to use", because the structure decides.

❷ THE GOLDEN POCKET AND THE OTE ZONE

The band between 0.618 and 0.786 is filled, with a soft halo behind it so it reads at a glance on a crowded chart. Smart money traders call this band the OTE — the Optimal Trade Entry — and it is where continuation entries are taken after a pullback, because it is deep enough that the move is discounted and shallow enough that the leg is still intact.

The golden pocket, the narrow 0.618–0.65 strip, sits along the top edge of that band. Both edges are adjustable, so set them to 0.618 and 0.65 if the pocket alone is what you trade, or to 0.5–0.618 if that is your definition of the golden zone. The whole tool follows whatever you set — the depth statistics, the dashboard and the alerts all read from the same two numbers.

❸ EXTENSIONS

Three projections beyond the leg, negative fib values by default at −0.272, −0.618 and −1.0. They are drawn from the same anchors as the retracement, so a target is measured against the same swing the entry came from rather than against a fib you dragged separately.

They ship switched off. A target at −1.0 sits far enough from price that the chart's autoscale stretches to include it and squashes the candles into a band — useful once you are in a trade, in the way while you are reading the chart. Switch them on in the Extensions section when you need them.

❹ A SPENT LEG STOPS SHOUTING

When price trades all the way through the anchor, the leg has done everything it was going to do. The fib cannot re-anchor until the next pivot confirms, so in the meantime the whole drawing fades: the levels dim, the golden zone loses its glow and its label reads spent.

It is a small thing that most tools get wrong. A fib left burning at full brightness over a setup that is already finished is not neutral — it is the chart arguing for a trade that is no longer there.

❺ TYPICAL RETRACEMENT DEPTH — what a fibonacci tool never shows

0.618 is a number from a sequence. It is not a fact about gold, or about the euro, or about this timeframe.

So the indicator measures it. Every time a leg pulls back and then makes a new extreme in the same direction, the depth of that pullback is recorded. The average of those depths is printed on the chart as its own line, and in the panel with the sample size behind it:

Typical depth 0.547 (23 legs)

Read it against the golden zone. When the measured depth sits at 0.55 and the golden zone starts at 0.618, this symbol has been turning BEFORE the golden zone — waiting for 0.618 means the move leaves without you. When it sits at 0.72, shallow entries at 0.5 have been getting run over.

Only pullbacks that were followed by continuation are counted. A leg that reversed outright is not a retracement, and folding those in is how a depth average gets quietly inflated past anything useful. Samples under eight legs are marked with a tilde, because an average of three is not an average.

❻ THE CHART ITSELF

Every candle stands in a soft lit column — an aura drawn behind it, its body stretched across the full range and left almost transparent with its outline switched off. The effect is a neon tube rather than a coloured rectangle.

The glow is not constant. Its brightness is driven by the bar's range against ATR, so a conviction candle burns and a doji barely registers. Strength becomes something you feel across a screen of price action instead of something you measure bar by bar, and the decoration is carrying information rather than existing for its own sake.

The candle on top has a translucent body against a solid outline. That one detail is what makes it read as part of the chart instead of a sticker placed over it: the background shows faintly through while the edge stays crisp.

Five palettes, because one set of colours cannot suit every background. Neon Bloom is turquoise against magenta, a matched pair that leaves gold free for the zone. Midnight Cyan is the common signature dark scheme, Vibrant Neon the high-contrast crypto pairing, Classic Soft the muted everyday version. Cool Blue drops red entirely — a number of full-time traders run blue against grey, since red carries a stress response that gets in the way of reading a chart objectively for eight hours at a stretch.

Bars of the current leg that closed inside the golden zone are drawn in gold, so the OTE is visible in the price action and not only in the band behind it. Only the current leg is marked — a highlight left over from a leg that ended months ago sits nowhere near the zone on screen and reads as a fault.

The levels follow the same restraint, in three tiers rather than nine identical lines: the two ends of the leg carry its direction, the levels between them sit back in muted grey, and the accent is spent once, on the golden zone. Candle colouring can be switched off entirely if you would rather keep your own.

❼ THE DASHBOARD

Leg direction and size, the live retracement as a single large number, whether price is inside the golden zone or has not reached it yet, the measured typical depth with its sample count, and the 0.618 and 0.786 prices ready to be turned into orders.

HOW TO USE IT

1 — Wait for the leg, not the level. The fib only exists after a confirmed pivot. That delay is the point: it is what stops you fibbing a swing that is still forming.

2 — Compare the golden zone with the typical depth line. If they overlap, the zone is doing its job on this symbol. If the typical depth sits well above or below it, trade the measured level and treat 0.618 as decoration.

3 — Use the extensions as the other half of the trade. An entry in the golden zone with a target at −0.272 is a defined structure; an entry with no target is a hope.

4 — Change the swing length to change the timeframe of the analysis. A short length gives the fib of the current intraday leg; a long one gives the fib of the swing the whole session is trading inside. Both are valid, and they answer different questions.

HOW IT WORKS

Pivot highs and lows of your chosen length define the leg. Span is the distance between anchor and extreme; a retracement level is the extreme moved back toward the anchor by its fraction of the span, and an extension is the same arithmetic past the extreme. The live retracement is the current close expressed in that same fraction. Depth statistics keep a rolling window of completed pullbacks and report their mean.

Works on any symbol and any timeframe. On higher timeframes raise the swing length so the fib tracks the swing rather than the noise inside it.

SETTINGS

▸ Swing — pivot length and how far levels extend to the right. ▸ Retracement Levels — each level individually switchable. ▸ Golden Zone / OTE — fill on or off, and both edges of the band. ▸ Extensions — three targets, any fib values you like. ▸ Depth Statistics — on or off, and how many legs are remembered. ▸ Visuals — labels, line width, five candle palettes plus off, aura glow and its strength, gold OTE bars, dashboard position.

ALERTS — price entered the golden zone, 0.618 reached, leg fully retraced, and fib re-anchored. All fire on closed bars.

NON-REPAINTING — the fib is anchored to confirmed pivots, which means a leg is only drawn after the bars either side of its pivot have closed. The depth record is built from completed pullbacks and never changes retroactively.

WHY THESE PARTS ARE ONE SCRIPT

The auto-anchoring, the golden zone and the depth measurement describe one object. Auto-anchoring alone gives you a fib that is correctly placed but still generic. The golden zone alone is a band drawn on an assumption. The measurement exists only to tell you whether that assumption holds on the symbol in front of you — and it needs the anchoring to have legs to measure. Remove any one and the other two lose their point.

This indicator is an educational market-analysis tool, not financial advice. The depth statistic describes pullbacks that have already happened on the loaded chart; it does not predict the next one. Always confirm with your own analysis and manage your risk.

## Source Code

````pine
//@version=6
// ============================================================================
//  Auto Fibonacci Retracement, Golden Zone & OTE Levels [LunqFX]
// ----------------------------------------------------------------------------
//  A fib is only as good as the swing it is drawn from, and drawing it by hand
//  means picking that swing by eye and redrawing it every time structure moves.
//  This anchors itself to confirmed pivots, keeps the golden zone in front of
//  you, and adds the number a fib tool never gives you: how deep this symbol
//  actually retraces before it continues.
//
//    1  AUTO ANCHOR    the leg is taken from confirmed pivots and re-anchors
//                      itself when structure makes a new extreme
//    2  RETRACEMENTS   the standard set, with the golden zone 0.618–0.786
//                      filled as the area smart money traders call the OTE
//    3  EXTENSIONS     projections beyond the leg for targets
//    4  TYPICAL DEPTH  the average pullback of legs that went on to continue,
//                      measured on THIS symbol, so 0.618 stops being a guess
//    5  PANEL          where price sits in the leg right now, and what the
//                      record says about it
//
//  NON-REPAINTING: legs are built from CONFIRMED pivots, so a level only
//  appears once the bars on both sides of its pivot have closed. Depth
//  statistics come from completed legs only.
// ============================================================================
indicator("Auto Fibonacci Retracement, Golden Zone & OTE Levels [LunqFX]",
     "AUTO FIB", overlay = true, max_bars_back = 500,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE — gold carries the golden zone because that is what it is; the
//  leg direction carries teal or red so the two never compete for meaning
// ─────────────────────────────────────────────────────────────────────────
// The leg colours match the default candle palette, so the fib and the price
// action read as one design rather than two that happen to share a chart.
UP       = #00F5D4
DN       = #FF2E88
UP_DIM   = #0A5F55
DN_DIM   = #8E1148
GOLD     = #F59E0B
GOLD_HOT = #FBBF24
INK      = #0B1119
CARD     = #131A24
CARD_2   = #1B2431
TXT      = #F1F5F9
MUTE     = #94A3B8
GOLD_TXT = #FCD34D

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gS      = "Swing"
pivLen  = input.int(12, "Swing length", minval = 2, maxval = 80, group = gS, tooltip = "How major a swing must be to anchor the fib. Higher gives fewer, larger legs.")
extRight= input.int(45, "Extend right (bars)", minval = 0, maxval = 300, group = gS)

gF      = "Retracement Levels"
useF236 = input.bool(true,  "0.236", group = gF)
useF382 = input.bool(true,  "0.382", group = gF)
useF500 = input.bool(true,  "0.5",   group = gF)
useF618 = input.bool(true,  "0.618", group = gF)
useF705 = input.bool(true,  "0.705", group = gF)
useF786 = input.bool(true,  "0.786", group = gF)

gG      = "Golden Zone / OTE"
showGold= input.bool(true, "Fill the golden zone", group = gG, tooltip = "The 0.618–0.786 band. Smart money traders call it the OTE — the Optimal Trade Entry — and it is where most continuation entries are taken.")
goldTop = input.float(0.618, "Zone from", minval = 0.1, maxval = 0.95, step = 0.001, group = gG)
goldBot = input.float(0.786, "Zone to",   minval = 0.1, maxval = 0.99, step = 0.001, group = gG)

gE      = "Extensions"
// Off by default on purpose: a target at -1.0 sits so far from price that the
// autoscale stretches the chart around it and crushes the candles into a
// band. Targets matter once you are in the trade, not while you are reading it.
showExt = input.bool(false, "Show extension targets", group = gE)
ext1    = input.float(-0.272, "Target 1", step = 0.001, group = gE)
ext2    = input.float(-0.618, "Target 2", step = 0.001, group = gE)
ext3    = input.float(-1.000, "Target 3", step = 0.001, group = gE)

gD      = "Depth Statistics"
showStat= input.bool(true, "Measure typical retracement depth", group = gD, tooltip = "Only legs that pulled back and then continued are measured — a full reversal is not a retracement. The average is the depth this symbol actually uses, which is often not 0.618.")
statMax = input.int(40, "Legs remembered", minval = 5, maxval = 200, group = gD)

gV      = "Visuals"
showLbl = input.bool(true, "Level labels", group = gV)
lineW   = input.int(2, "Line width", minval = 1, maxval = 4, group = gV)
// One palette cannot suit every background, which is why the most-used candle
// theming scripts ship a shelf of them rather than a single opinion. These are
// the schemes that circulate among traders rather than colours invented here.
candSty = input.string("Neon Bloom", "Candle palette", options = ["Neon Bloom","Midnight Cyan","Vibrant Neon","Classic Soft","Cool Blue","Off"], group = gV, tooltip = "Neon Bloom is turquoise against magenta — a matched neon pair that leaves gold free for the zone. Midnight Cyan is the common signature dark scheme, Vibrant Neon the high-contrast crypto pairing, Classic Soft the muted everyday version. Cool Blue drops red entirely: a number of full-time traders run blue against grey because red carries a stress response that gets in the way of reading a chart for eight hours. Off keeps your own candles.")
glowOn  = input.bool(true, "Aura glow", group = gV, tooltip = "Wraps each candle in a soft lit column. Its brightness is driven by the bar's range against ATR, so a conviction candle burns and a doji barely registers — the chart gains depth AND tells you something while doing it.")
glowAmt = input.int(70, "Glow strength", minval = 30, maxval = 100, group = gV)
oteMark = input.bool(true, "Turn OTE bars gold", group = gV, tooltip = "Bars of the current leg whose close sat inside the golden zone are drawn in gold. Only the current leg is marked, so every gold bar is one you can see inside the zone on the chart.")
showHUD = input.bool(true, "Dashboard", group = gV)
hudPos  = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gV)

// ─────────────────────────────────────────────────────────────────────────
//  SWING ENGINE
//  The active leg runs from the anchor pivot to the extreme pivot. A pivot of
//  the same kind beyond the extreme extends the leg; a pivot of the other
//  kind flips it.
// ─────────────────────────────────────────────────────────────────────────
ph = ta.pivothigh(pivLen, pivLen)
pl = ta.pivotlow(pivLen, pivLen)

// declared one per line on purpose: Pine applies `var` only to the FIRST name
// in a comma-chained declaration and silently resets the rest every bar
var float legA    = na      // anchor — where the leg started
var float legB    = na      // extreme — where the leg currently ends
var int   legABar = na
var int   legBBar = na
var int   legDir  = 0       // 1 = up leg (low to high), -1 = down leg

var float deepest = 0.0     // deepest pullback of the CURRENT leg, 0..1
var array<float> depths = array.new<float>()

// A pullback only counts once the market has PROVEN it was a pullback, which
// is when a new extreme forms in the same direction. A flip is a reversal, not
// a retracement, and folding those in is how a depth average gets inflated.
bankDepth() =>
    if showStat and deepest > 0.01 and deepest < 1.0
        array.push(depths, deepest)
        while array.size(depths) > statMax
            array.shift(depths)
    0

if not na(ph)
    if legDir == 1
        if ph > legB
            bankDepth()
            legB    := ph
            legBBar := bar_index - pivLen
            deepest := 0.0
    else
        legA    := nz(legB, low)
        legABar := nz(legBBar, bar_index - pivLen)
        legB    := ph
        legBBar := bar_index - pivLen
        legDir  := 1
        deepest := 0.0

if not na(pl)
    if legDir == -1
        if pl < legB
            bankDepth()
            legB    := pl
            legBBar := bar_index - pivLen
            deepest := 0.0
    else
        legA    := nz(legB, high)
        legABar := nz(legBBar, bar_index - pivLen)
        legB    := pl
        legBBar := bar_index - pivLen
        legDir  := -1
        deepest := 0.0

span = na(legA) or na(legB) ? na : math.abs(legB - legA)
retr = na(span) or span <= 0 ? na : legDir == 1 ? (legB - low) / span : (high - legB) / span
if not na(retr) and retr > 0 and retr < 1.5
    deepest := math.max(deepest, retr)

// Once price has traded through the anchor the leg has done everything it was
// going to do. The fib cannot re-anchor until a pivot confirms, so until then
// the drawing is faded rather than left burning at full strength — a spent
// setup that still looks live is worse than no setup on the chart at all.
legSpent = na(span) or span <= 0 ? false : (legDir == 1 ? (legB - close) / span : (close - legB) / span) > 1.0

// price of a retracement level: 0 sits on the extreme, 1 back on the anchor
fibAt(float f) =>
    na(span) ? na : legDir == 1 ? legB - span * f : legB + span * f

avgDepth() =>
    n   = array.size(depths)
    out = float(na)
    if n > 0
        s = 0.0
        for i = 0 to n - 1
            s += array.get(depths, i)
        out := s / n
    out

// ─────────────────────────────────────────────────────────────────────────
//  DRAWING
// ─────────────────────────────────────────────────────────────────────────
var array<line>  lns = array.new<line>()
var array<label> lbs = array.new<label>()
var array<box>   bxs = array.new<box>()

wipe() =>
    if array.size(lns) > 0
        for i = 0 to array.size(lns) - 1
            line.delete(array.get(lns, i))
        array.clear(lns)
    if array.size(lbs) > 0
        for i = 0 to array.size(lbs) - 1
            label.delete(array.get(lbs, i))
        array.clear(lbs)
    if array.size(bxs) > 0
        for i = 0 to array.size(bxs) - 1
            box.delete(array.get(bxs, i))
        array.clear(bxs)
    0

drawLevel(float f, string name, color c, int w, bool dashed) =>
    y = fibAt(f)
    if not na(y)
        xL = math.min(nz(legABar, bar_index), nz(legBBar, bar_index))
        xR = bar_index + extRight
        array.push(lns, line.new(xL, y, xR, y, color = color.new(c, legSpent ? 65 : 12), width = w,
             style = dashed ? line.style_dashed : line.style_solid))
        if showLbl
            array.push(lbs, label.new(xR, y, "  " + name + "   " + str.tostring(y, format.mintick) + "  ",
                 style = label.style_label_left, color = color.new(INK, legSpent ? 55 : 0),
                 textcolor = color.new(c, legSpent ? 45 : 0), size = size.normal))
    0

if barstate.islast and not na(span) and span > 0
    wipe()
    lc = legDir == 1 ? UP : DN
    xL = math.min(nz(legABar, bar_index), nz(legBBar, bar_index))
    xR = bar_index + extRight
    // the two wide plates sit further right so they never land on a level tag
    tagGap = math.max(9, int(extRight * 0.22))

    // the golden zone is laid down first so every level line sits on top of it
    if showGold
        yT = fibAt(math.min(goldTop, goldBot))
        yB = fibAt(math.max(goldTop, goldBot))
        if not na(yT) and not na(yB)
            hi  = math.max(yT, yB)
            lo  = math.min(yT, yB)
            pad = (hi - lo) * 0.32
            array.push(bxs, box.new(xL, hi + pad, xR, lo - pad,
                 border_color = color.new(GOLD, 100), bgcolor = color.new(GOLD, legSpent ? 97 : 94)))
            array.push(bxs, box.new(xL, hi, xR, lo,
                 border_color = color.new(legSpent ? MUTE : GOLD_HOT, legSpent ? 55 : 25), border_width = 2,
                 bgcolor = color.new(GOLD, legSpent ? 90 : 70)))
            if showLbl
                array.push(lbs, label.new(xR + tagGap, (hi + lo) / 2,
                     legSpent ? "  Golden Zone · spent  " :
                     "  Golden Zone · OTE   " + str.tostring(math.min(goldTop, goldBot), "#.###") + "–" + str.tostring(math.max(goldTop, goldBot), "#.###") + "  ",
                     style = label.style_label_left, color = color.new(legSpent ? MUTE : GOLD, legSpent ? 35 : 0),
                     textcolor = legSpent ? #10151C : #1A1206, size = size.large))

    // the two ends of the leg carry the most weight
    drawLevel(0.0, "0", lc, lineW + 1, false)
    drawLevel(1.0, "1", lc, lineW + 1, false)

    // three tiers on purpose: the leg boundaries carry direction, the golden
    // zone carries the accent, and the levels in between stay out of the way.
    // Drawing all nine in the same loud colour is what makes a fib look like
    // a wiring diagram.
    if useF236
        drawLevel(0.236, "0.236", MUTE, lineW, true)
    if useF382
        drawLevel(0.382, "0.382", MUTE, lineW, true)
    if useF500
        drawLevel(0.5, "0.5", MUTE, lineW, false)
    if useF618
        drawLevel(0.618, "0.618", GOLD_HOT, lineW, false)
    if useF705
        drawLevel(0.705, "0.705", GOLD_HOT, lineW, true)
    if useF786
        drawLevel(0.786, "0.786", GOLD_HOT, lineW, false)

    if showExt
        drawLevel(ext1, "T1", MUTE, lineW, true)
        drawLevel(ext2, "T2", MUTE, lineW, true)
        drawLevel(ext3, "T3", MUTE, lineW, true)

    // the leg itself, so the fib is never floating without its swing
    array.push(lns, line.new(nz(legABar, bar_index), legA, nz(legBBar, bar_index), legB,
         color = color.new(lc, 35), width = lineW, style = line.style_dotted))

    // typical depth marked on the chart, not just stated in the panel
    ad = avgDepth()
    if showStat and not na(ad)
        yA = fibAt(ad)
        if not na(yA)
            array.push(lns, line.new(xL, yA, xR, yA, color = color.new(TXT, 20), width = lineW + 1))
            if showLbl
                array.push(lbs, label.new(xR + tagGap, yA, "  Typical depth   " + str.tostring(ad, "#.###") + "  ",
                     style = label.style_label_left, color = color.new(TXT, 0),
                     textcolor = INK, size = size.large))

// ─────────────────────────────────────────────────────────────────────────
//  CANDLES
//  Translucent bodies against fully opaque borders and wicks. That single
//  choice is what makes a candle read as part of the chart instead of a
//  sticker placed on top of it — the background shows faintly through the
//  body, the outline stays crisp, and the whole thing gains depth.
//
//  Bars sitting in the golden zone are drawn in gold, and ONLY for the leg
//  currently on the chart. Marking them across history was the mistake: the
//  zone of a leg that ended months ago is nowhere near the zone drawn now,
//  so the highlights landed in open space and read as a rendering fault.
// ─────────────────────────────────────────────────────────────────────────
zLo = math.min(goldTop, goldBot)
zHi = math.max(goldTop, goldBot)

posBar = na(span) or span <= 0 ? na : legDir == 1 ? (legB - close) / span : (close - legB) / span
inZone = not na(posBar) and posBar >= zLo and posBar <= zHi
inLeg  = not na(legABar) and bar_index >= legABar
goldBar = oteMark and inZone and inLeg and not legSpent

// Palettes as published, not nudged by eye afterwards
cBull = switch candSty
    "Neon Bloom"    => #00F5D4
    "Midnight Cyan" => #34E89E
    "Vibrant Neon"  => #00E5B0
    "Classic Soft"  => #3FB68B
    "Cool Blue"     => #4C9AFF
    => #00F5D4

cBear = switch candSty
    "Neon Bloom"    => #FF2E88
    "Midnight Cyan" => #FF4D7D
    "Vibrant Neon"  => #FF2E63
    "Classic Soft"  => #E0556B
    "Cool Blue"     => #8A94A6
    => #FF2E88

isUp = close >= open
edge = goldBar ? GOLD_HOT : isUp ? cBull : cBear
lit  = candSty != "Off"

// THE AURA
// A second candle drawn behind the real one, its body stretched across the
// whole high-to-low range and left almost transparent, with its border and
// wick switched off entirely. What shows is a soft lit column standing behind
// each bar — the neon-tube effect, and the reason the chart stops looking
// like a spreadsheet with colours in it.
//
// Brightness is not constant. It is driven by the bar's range against ATR,
// so a conviction candle burns and a doji barely registers. The glow carries
// information instead of just decorating, which is what keeps it from reading
// as an effect for its own sake.
atrGlow = ta.atr(14)
punch   = na(atrGlow) or atrGlow <= 0 ? 0.4 : math.min(1.0, (high - low) / (atrGlow * 1.7))
auraT   = int(96 - punch * (glowAmt * 0.30))

plotcandle(lit and glowOn ? high : na, high, low, low, "Aura",
     color = color.new(edge, auraT),
     wickcolor = color.new(edge, 100), bordercolor = color.new(edge, 100))

// the candle itself: translucent body, solid outline. The background shows
// faintly through the body while the edge stays crisp, and that is what makes
// a candle sit IN the chart rather than on top of it.
plotcandle(lit ? open : na, high, low, close, "Candles",
     color = color.new(edge, 24), wickcolor = color.new(edge, 18), bordercolor = edge)

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
hudP(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

var table hud = table.new(position.top_right, 2, 5)
if showHUD and barstate.islast and not na(span) and span > 0
    table.delete(hud)
    hud := table.new(hudP(hudPos), 2, 5, bgcolor = CARD,
         border_color = color.new(#28323F, 0), border_width = 1)

    live   = legDir == 1 ? (legB - close) / span : (close - legB) / span
    gT     = math.min(goldTop, goldBot)
    gB     = math.max(goldTop, goldBot)
    inGold = live >= gT and live <= gB
    ad     = avgDepth()
    n      = array.size(depths)

    hBg = legDir == 1 ? UP_DIM : DN_DIM
    hTx = legDir == 1 ? "▲  Up leg  ·  retracing down" : "▼  Down leg  ·  retracing up"

    table.cell(hud, 0, 0, "  " + hTx + "  ", text_color = color.white, text_size = size.large, text_halign = text.align_left, bgcolor = hBg)
    table.cell(hud, 1, 0, str.tostring(math.abs(legB - legA), format.mintick) + "  ", text_color = color.white, text_size = size.normal, text_halign = text.align_right, bgcolor = hBg)

    // A retracement below zero is not a retracement at all — price is beyond
    // the extreme and the leg is still extending. Printing "-0.589" next to
    // "not reached yet" reads like a fault; these are separate states and the
    // panel now says which one it is.
    extending = live < 0
    spent     = live > 1.0
    rowL = extending ? "  Extended past the leg" : "  Retraced now"
    rowV = extending ? str.tostring(-live, "#.###") : str.tostring(live, "#.###")
    rowC = extending ? (legDir == 1 ? UP : DN) : inGold ? GOLD_TXT : TXT

    table.cell(hud, 0, 1, rowL, text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    table.cell(hud, 1, 1, rowV + "  ", text_color = rowC, text_size = size.huge, text_halign = text.align_right, bgcolor = CARD)

    // "below the zone" read as if price had not got there yet, when in fact it
    // had gone through and kept going. Deeper is deeper, whichever way the leg runs.
    zTx = extending ? "leg still extending" : spent ? "leg fully retraced" : inGold ? "price is inside" : live < gT ? "not reached yet" : "retraced past it"
    zC  = inGold ? GOLD_TXT : spent ? DN : MUTE

    table.cell(hud, 0, 2, "  Golden zone", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD_2)
    table.cell(hud, 1, 2, zTx + "  ", text_color = zC, text_size = size.large, text_halign = text.align_right, bgcolor = CARD_2)

    // a tilde marks a sample still too thin to lean on
    dTx = na(ad) ? "needs completed legs" : (n < 8 ? "~" : "") + str.tostring(ad, "#.###") + "   (" + str.tostring(n) + " legs)"
    table.cell(hud, 0, 3, "  Typical depth here", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    table.cell(hud, 1, 3, dTx + "  ", text_color = na(ad) ? MUTE : TXT, text_size = size.large, text_halign = text.align_right, bgcolor = CARD)

    table.cell(hud, 0, 4, "  0.618  ·  0.786", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD_2)
    table.cell(hud, 1, 4, str.tostring(fibAt(0.618), format.mintick) + "   ·   " + str.tostring(fibAt(0.786), format.mintick) + "  ", text_color = GOLD_TXT, text_size = size.normal, text_halign = text.align_right, bgcolor = CARD_2)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS — closed bars only
// ─────────────────────────────────────────────────────────────────────────
liveR  = na(span) or span <= 0 ? na : legDir == 1 ? (legB - close) / span : (close - legB) / span
zTopF  = math.min(goldTop, goldBot)
zBotF  = math.max(goldTop, goldBot)
wasIn  = nz(liveR[1], -1) >= zTopF and nz(liveR[1], -1) <= zBotF
enterG = barstate.isconfirmed and not na(liveR) and liveR >= zTopF and liveR <= zBotF and not wasIn

alertcondition(enterG, "Price entered the golden zone", "LunqFX Auto Fib: price has entered the golden zone (OTE)")
alertcondition(barstate.isconfirmed and not na(liveR) and liveR >= 0.618 and nz(liveR[1], 0) < 0.618, "0.618 reached", "LunqFX Auto Fib: price reached the 0.618 retracement")
alertcondition(barstate.isconfirmed and not na(liveR) and liveR >= 1.0 and nz(liveR[1], 0) < 1.0, "Leg fully retraced", "LunqFX Auto Fib: the leg has been fully retraced")
alertcondition(ta.change(legDir) != 0, "Fib re-anchored", "LunqFX Auto Fib: structure flipped and the fib re-anchored to a new leg")
````
