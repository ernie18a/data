<!-- tradingview-pine-id: PUB;d7a7d60ae0a840c8ad5d7b08273fbc0c -->
<!-- tradingviewscripts-format: 1 -->
# Support and Resistance SR Zones & Buy Sell Signals [LunqFX]

Source: https://www.tradingview.com/script/qGKZaQ9p-Support-and-Resistance-Zones-Key-Levels-Hold-Rate-LunqFX/

## Description

Support and resistance indicators all draw the same picture: a set of key levels and SR zones detected from swing pivots, every one of them looking as important as the next. Five price levels on the chart and no way to tell which one the market actually respects — so you place the order at whichever support or resistance price bounced off last, and call it analysis.

This support and resistance indicator keeps score. Each auto-detected SR zone carries the number of times it has been tested and how many of those tests it held, printed on the level itself:

1.15370 · 71% · 5 of 7 1.14344 · 50% · 1 of 2 1.13763 · 67% · 2 of 3

A key level that has held five of seven tests and one that has held one of six are not the same object, and until that number is on the chart you are trading them as if they were.

Included: automatic support and resistance zone detection from confirmed pivots, a hold-rate record on every level, strength-weighted drawing, a dashboard showing the nearest support and resistance either side of price, and optional buy and sell signals with a trend filter and alerts.

❶ HOW THE SUPPORT AND RESISTANCE ZONES ARE BUILT

Swing points come from confirmed pivots, so a level only exists once the bars on both sides of it have closed — nothing appears and then vanishes. Pivots that land close to each other are merged into a single zone rather than stacked as near-duplicate lines, with the merge distance measured in ATR so it adapts to the instrument.

A zone widens as new pivots join it, but only up to a ceiling. Past that it re-centres on the pivot that just touched it. Without that rule a level slowly swallows everything around it and turns into a band, and the count then measures touches of a band instead of touches of a price.

❷ THE HOLD RATE — what no other support and resistance tool shows

A test opens when price trades into the zone. It resolves on a CLOSED bar, one of two ways:

▸ HELD — price closed back out the side it came from, clear of the zone by a fraction of ATR. The margin matters: without it, a close one tick beyond the edge counts as a rejection, which is how level indicators manufacture events out of noise. ▸ BROKEN — price closed through to the other side.

Nothing is counted while a test is still open. And a fresh test cannot begin until the previous one has had room to breathe, because price chopping inside a zone for a week is one consolidation, not twenty separate tests of the level.

Samples of fewer than four tests are marked with a tilde. Two tests producing "100%" is noise, and the chart says so rather than letting the number stand.

❸ LEVEL STRENGTH YOU CAN SEE

Fill density, border thickness and the halo behind each zone all scale with how often the level has been tested, and levels holding above 60% are drawn in a brighter shade. The chart ranks its own levels — the strongest one is the one that looks strongest, with no arithmetic required from you.

❹ THE DASHBOARD — nearest support and resistance

The nearest level above and the nearest level below, each with its price and its record. When there is no tracked level on one side the panel says exactly that, rather than printing a dash that reads like a fault.

❺ BUY AND SELL SIGNALS — built in, switched off

The indicator includes buy and sell signals: a buy label when a support test holds, a sell label when resistance holds. Turn them on in the Signals section — the switch is the first setting in the group, and every alert works from them.

They ship switched OFF, and the reason is worth stating plainly. A rejection at a support or resistance level is a fact. What price does afterwards is not. A level also tends to weaken with each test as the orders behind it are consumed, so "this level held four times" is not evidence that it will hold a fifth — if anything the reverse. Any indicator that hands you an arrow on every bounce is selling you that assumption without saying so.

When switched on, a signal has to clear six filters before it prints: the level must have been tested enough times to have a record, it must hold more often than it breaks, the rejection must close clear of the zone by a fraction of ATR, price must still be near the level, the trend must agree with the direction, and both the chart as a whole and that particular level must have been quiet since the last one. Set that way they are rare. Treat them as a prompt to look, not as a call to act.

HOW TO USE IT

1 — Choose where to place a resting order. Between two levels the same distance away, the one with the better record is the better limit.

2 — Choose where to expect a break. A level holding one test in six is telling you something too: price is likely to go through it, which makes it a poor place to fade and a reasonable place to trade a breakout.

3 — Place stops behind proven levels. A stop tucked behind a level that has held five of seven has a structural reason to be there.

4 — Read the whole set at once. This is the reading most traders never get. If every level on the chart is showing 30–40%, the market is not respecting levels at all right now — it is trending or reacting to news, and level trading is the wrong approach for the session. When most levels sit at 70%+, the market is rotating and levels are worth trading. That judgement usually takes weeks of screen time; here it is on the chart.

HOW IT WORKS

Pivots of your chosen length define candidate levels. Each new pivot either joins the nearest existing zone within the merge distance or opens a new one; zones are capped in width and the oldest is dropped once the limit is reached. Every zone tracks four numbers: tests, holds, the bar its last test resolved on, and the bar it last signalled on. Tests resolve on closed bars only, with a rejection margin in ATR and a minimum gap between tests. The hold rate is simply holds divided by tests, and the drawing weight is derived from the test count.

Works on any symbol and timeframe. On daily charts and above, leave the minimum test count at one — a level there rarely gets a second test before it matters. On fast intraday charts raise it, since levels are tested often.

SETTINGS

▸ Levels — pivot length, how many levels are kept, how far back they draw, merge distance, zone thickness, maximum width, minimum tests to draw, and the gap between tests. ▸ Signals — off by default; prior holds required, minimum tests before a level may speak, minimum hold rate, cooldowns, distance from price and rejection strength. ▸ Trend Filter — direction requires both price position and the slope of the average, so a range satisfies neither side. ▸ Visuals — extension, labels, candle colouring, dashboard position.

ALERTS — buy signal, sell signal, and any signal. All fire on closed bars only.

NON-REPAINTING — levels are built from confirmed pivots and every test resolves on a closed bar. A record that has printed never changes retroactively, and a level that has appeared never disappears from history.

WHY THESE PARTS ARE ONE SCRIPT

The levels, the record and the visual weight describe one object. Detection alone gives you lines with no way to rank them. The record alone has nothing to attach itself to. The weighting exists only so the record can be read at a glance instead of counted. Take any one away and the other two stop being useful, which is why they ship together rather than as three indicators.

This indicator is an educational market-analysis tool, not financial advice. The hold rate describes what has already happened at a level on the loaded chart; it does not predict what will happen next. Always confirm with your own analysis and manage your risk.

---

## Source Code

````pine
//@version=6
// ============================================================================
//  Support and Resistance Buy Sell Signals & Hold Stats [LunqFX]
// ----------------------------------------------------------------------------
//  Every support and resistance indicator draws lines. None of them tell you
//  whether those lines have actually worked. This one keeps score: each level
//  carries how many times it was tested and how many of those tests it held,
//  printed on the level itself. A level that has held four of five tests is a
//  different proposition from one that has held one of six, and until you can
//  see that number you are trading them as if they were the same.
//
//    1  LEVELS      confirmed pivots clustered into zones by ATR proximity
//    2  HOLD SCORE  tests and holds counted per level, printed on the label
//    3  STRENGTH    fill, border and halo scale with the record, so the chart
//                   ranks its own levels without the reader doing arithmetic
//    4  PANEL       nearest level either side and how each has behaved
//    5  SIGNALS     optional and off by default — a rejection at a level is a
//                   fact, what follows it is not
//
//  NON-REPAINTING: levels are built from CONFIRMED pivots, every test resolves
//  on a closed bar, and a signal that has printed never moves or disappears.
// ============================================================================
// the short title is capped at 10 characters by TradingView
indicator("Support and Resistance SR Zones & Buy Sell Signals [LunqFX]",
     "SR ZONES", overlay = true, max_bars_back = 500,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE — bold enough to read at thumbnail size on a light or dark chart
// ─────────────────────────────────────────────────────────────────────────
SUP      = #0D9488
SUP_HOT  = #14B8A6
RES      = #DC2626
RES_HOT  = #EF4444
INK      = #101720
CARD     = #131A24
CARD_2   = #1B2431
TXT      = #F1F5F9
MUTE     = #94A3B8
SUP_TXT  = #6BE79B
RES_TXT  = #FF9090

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gL      = "Levels"
pivLen  = input.int(10, "Pivot length", minval = 2, maxval = 60, group = gL, tooltip = "How major a swing must be to create a level. Higher gives fewer, more significant levels.")
maxZones= input.int(8, "Levels kept", minval = 2, maxval = 20, group = gL)
maxSpan = input.int(320, "Level length (bars)", minval = 30, maxval = 500, group = gL, tooltip = "How far back a level is drawn. Without a cap every level stretches across the whole chart and the picture turns into stripes.")
mergeATR= input.float(1.0, "Merge distance (× ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = gL, tooltip = "Pivots closer together than this become one level instead of two, which is what stops the chart filling with near-duplicate lines.")
zoneATR = input.float(0.75, "Zone thickness (× ATR)", minval = 0.05, maxval = 2.0, step = 0.05, group = gL)
maxWide = input.float(1.6, "Maximum zone width (× ATR)", minval = 0.3, maxval = 6.0, step = 0.1, group = gL, tooltip = "A level widens every time a nearby pivot joins it. Without a ceiling it eventually swallows everything around it and stops being a level at all — the count then measures touches of a band, not of a price.")
minTest = input.int(1, "Minimum tests to draw", minval = 1, maxval = 10, group = gL, tooltip = "Hide levels that have not been tested at least this many times. Raise it on fast intraday charts where levels are tested often; leave it at one on daily and above, where a level rarely gets a second test before it matters.")
testCool= input.int(8, "Bars between tests of a level", minval = 0, maxval = 100, group = gL, tooltip = "Price chopping inside a zone for a week is one consolidation, not twenty tests. Without this gap the counter inflates and the hold rate stops describing anything.")

gS      = "Signals"
// Off by default on purpose. The levels and their records are the tool; the
// arrows are an opinion layered on top of them. A rejection at a level is a
// fact, what happens next is not, and a level tends to weaken with each test
// rather than strengthen — so these fire rarely and are meant as a prompt to
// look, not as a call to act.
showSig = input.bool(false, "Buy and sell signals", group = gS)
needHold= input.int(3, "Prior holds required", minval = 0, maxval = 10, group = gS, tooltip = "Only signal at levels that have already held at least this many times. Raise it to trade proven levels only.")
minTestS= input.int(4, "Minimum tests before a level may signal", minval = 1, maxval = 20, group = gS, tooltip = "A level with two or three tests has no record worth acting on. Until it has been tried this many times it is drawn and counted, but it stays silent.")
minRate = input.int(60, "Minimum hold rate %", minval = 0, maxval = 100, group = gS, tooltip = "A level that has held twice out of eight has held twice — and broken six times. Counting holds alone lets that level signal; requiring a rate stops it.")
sigCool = input.int(60, "Bars between signals", minval = 0, maxval = 100, group = gS, tooltip = "A cluster of levels can resolve within a few bars of each other. Without a cooldown the chart fills with arrows that all say the same thing.")
lvlCool = input.int(60, "Bars before the same level signals again", minval = 0, maxval = 300, group = gS, tooltip = "One level rejecting price four times in a fortnight is one idea, not four trades. This stops the same level shouting repeatedly.")
sigNear = input.float(2.0, "Signal only within (× ATR)", minval = 0.5, maxval = 10.0, step = 0.5, group = gS, tooltip = "Ignore holds at levels far from current price — they are history, not a trade.")
rejATR  = input.float(0.20, "Rejection strength (× ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = gS, tooltip = "How far beyond the zone the bar must close for the test to count as a rejection. At zero a one-tick close counts, which is how most level indicators manufacture signals out of noise.")

gT      = "Trend Filter"
useTrend= input.bool(true, "Only signal with the trend", group = gT, tooltip = "A level rejecting price is a fact. Whether that rejection holds depends on which way the market is already going. Counter-trend rejections fail far more often than they work, and they are the bulk of what makes a level indicator look wrong.")
trendLen= input.int(50, "Trend length", minval = 10, maxval = 400, group = gT)
showMA  = input.bool(false, "Show the trend line", group = gT)

gV      = "Visuals"
extRight= input.int(30, "Extend levels (bars)", minval = 0, maxval = 300, group = gV)
showLbl = input.bool(true, "Level labels with record", group = gV)
candOn  = input.bool(true, "Colour candles", group = gV)
showHUD = input.bool(true, "Dashboard", group = gV)
hudPos  = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gV)

// ─────────────────────────────────────────────────────────────────────────
//  ZONE STORE
//  state: 0 idle · 1 being tested from below · 2 being tested from above
// ─────────────────────────────────────────────────────────────────────────
var array<float> zTop   = array.new<float>()
var array<float> zBot   = array.new<float>()
var array<int>   zTest  = array.new<int>()
var array<int>   zHold  = array.new<int>()
var array<int>   zState = array.new<int>()
var array<int>   zBar   = array.new<int>()
var array<int>   zLast  = array.new<int>()   // bar the last test resolved on
var array<int>   zSig   = array.new<int>()   // bar of this level.s last signal

atr14 = ta.atr(14)
tol   = nz(atr14) * mergeATR
half  = nz(atr14) * zoneATR / 2.0

// Price above a moving average is not a trend — in a range price crosses it
// every few bars and the filter passes buys and sells alternately, which is
// exactly what it was added to prevent. Direction requires the average to be
// SLOPING that way as well, so a range satisfies neither side and goes quiet.
trendMA = ta.ema(close, trendLen)
slope   = trendMA - trendMA[math.max(2, int(trendLen / 5))]
upTrend = close > trendMA and slope > 0
dnTrend = close < trendMA and slope < 0
okBuy   = not useTrend or upTrend
okSell  = not useTrend or dnTrend
plot(showMA ? trendMA : na, "Trend", color = color.new(upTrend ? SUP : RES, 45), linewidth = 2)

// a new pivot either joins the nearest existing level or opens a new one
addLevel(float p) =>
    if not na(p) and nz(atr14) > 0
        best = -1
        dist = 1e20
        if array.size(zTop) > 0
            for i = 0 to array.size(zTop) - 1
                mid = (array.get(zTop, i) + array.get(zBot, i)) / 2.0
                d   = math.abs(mid - p)
                if d < dist and d <= tol
                    dist := d
                    best := i
        // widen the existing level toward the new pivot rather than stacking a
        // second line a few ticks away
        if best >= 0
            array.set(zTop, best, math.max(array.get(zTop, best), p + half))
            array.set(zBot, best, math.min(array.get(zBot, best), p - half))
            // a zone can only ever grow through merging, so past a ceiling it
            // is re-centred on the pivot that just touched it. The level stays
            // where the market last respected it instead of drifting into a band.
            cap = nz(atr14) * maxWide
            if array.get(zTop, best) - array.get(zBot, best) > cap
                array.set(zTop, best, p + cap / 2.0)
                array.set(zBot, best, p - cap / 2.0)
        // two separate ifs instead of if/else: as the closing expression of a
        // function the branches would have to agree on a return type, and
        // array.set gives void while array.shift gives back the element
        if best < 0
            array.push(zTop, p + half)
            array.push(zBot, p - half)
            array.push(zTest, 0)
            array.push(zHold, 0)
            array.push(zState, 0)
            array.push(zBar, bar_index)
            array.push(zLast, -10000)
            array.push(zSig, -10000)
        while array.size(zTop) > maxZones
            array.shift(zTop)
            array.shift(zBot)
            array.shift(zTest)
            array.shift(zHold)
            array.shift(zState)
            array.shift(zBar)
            array.shift(zLast)
            array.shift(zSig)
    0

ph = ta.pivothigh(pivLen, pivLen)
pl = ta.pivotlow(pivLen, pivLen)
if not na(ph)
    addLevel(ph)
if not na(pl)
    addLevel(pl)

// ─────────────────────────────────────────────────────────────────────────
//  TESTS AND HOLDS — resolved on closed bars only
//  A test opens when price trades into the zone. It resolves as a HOLD when
//  price closes back out the side it came from, and as a BREAK when it closes
//  through to the other side. Nothing is counted while a test is still open.
// ─────────────────────────────────────────────────────────────────────────
bool sigBuy  = false
bool sigSell = false
var float lastSigPrice = na
var int   lastSigBar   = -10000

// five gates: the level has held enough times, it holds more often than it
// breaks, it sits close enough to price to be tradeable, the chart has been
// quiet since the last arrow, and this particular level has been quiet too
canSignal(int i) =>
    m = (array.get(zTop, i) + array.get(zBot, i)) / 2.0
    tt = array.get(zTest, i)
    rt = tt > 0 ? array.get(zHold, i) / float(tt) * 100.0 : 0.0
    tt >= minTestS and array.get(zHold, i) >= needHold and rt >= minRate and math.abs(close - m) <= nz(atr14) * sigNear and bar_index - lastSigBar >= sigCool and bar_index - array.get(zSig, i) >= lvlCool

if barstate.isconfirmed and array.size(zTop) > 0
    for i = 0 to array.size(zTop) - 1
        t = array.get(zTop, i)
        b = array.get(zBot, i)
        st = array.get(zState, i)
        inside = high >= b and low <= t

        // a fresh test only opens once the previous one has had room to breathe,
        // so a week of chop inside the zone counts as one consolidation and not
        // as twenty separate tests of the level
        if st == 0 and inside and bar_index - array.get(zLast, i) >= testCool
            // the side price arrived from decides what a hold means here
            array.set(zState, i, close[1] < b ? 1 : close[1] > t ? 2 : 0)
            if array.get(zState, i) != 0
                array.set(zTest, i, array.get(zTest, i) + 1)
        // the rejection has to close clear of the zone by a fraction of ATR.
        // Without that margin a one-tick close counts, and the indicator starts
        // manufacturing signals out of noise
        else if st == 1
            if close > t
                array.set(zState, i, 0)
                array.set(zLast, i, bar_index)
            else if close < b - nz(atr14) * rejATR
                array.set(zHold, i, array.get(zHold, i) + 1)
                array.set(zState, i, 0)
                array.set(zLast, i, bar_index)
                if showSig and okSell and canSignal(i)
                    sigSell := true
                    lastSigPrice := b
                    lastSigBar := bar_index
                    array.set(zSig, i, bar_index)
        else if st == 2
            if close < b
                array.set(zState, i, 0)
                array.set(zLast, i, bar_index)
            else if close > t + nz(atr14) * rejATR
                array.set(zHold, i, array.get(zHold, i) + 1)
                array.set(zState, i, 0)
                array.set(zLast, i, bar_index)
                if showSig and okBuy and canSignal(i)
                    sigBuy := true
                    lastSigPrice := t
                    lastSigBar := bar_index
                    array.set(zSig, i, bar_index)

// ─────────────────────────────────────────────────────────────────────────
//  DRAWING
// ─────────────────────────────────────────────────────────────────────────
var array<box>   bxs = array.new<box>()
var array<label> lbs = array.new<label>()

if barstate.islast and array.size(zTop) > 0
    if array.size(bxs) > 0
        for i = 0 to array.size(bxs) - 1
            box.delete(array.get(bxs, i))
        array.clear(bxs)
    if array.size(lbs) > 0
        for i = 0 to array.size(lbs) - 1
            label.delete(array.get(lbs, i))
        array.clear(lbs)

    for i = 0 to array.size(zTop) - 1
        tst = array.get(zTest, i)
        // a level with no holds says nothing until it has been tested enough
        // times for "it never holds" to itself be the finding
        worth = tst >= minTest and (array.get(zHold, i) > 0 or tst >= 3)
        if worth
            t   = array.get(zTop, i)
            b   = array.get(zBot, i)
            hld = array.get(zHold, i)
            mid = (t + b) / 2.0
            isRes = mid > close
            base  = isRes ? RES : SUP
            hot   = isRes ? RES_HOT : SUP_HOT

            rate = tst > 0 ? math.round(hld / float(tst) * 100) : 0
            good = rate >= 60 and tst >= 2

            // A level that has proven itself should look like it. Weight is
            // carried by three things at once — fill density, border thickness
            // and a halo behind the box — so strength is legible at a glance
            // and the chart ranks itself without the reader doing arithmetic.
            strength = math.min(tst, 5)
            fillT = int(math.max(50, 80 - strength * 6) - (good ? 8 : 0))
            lineT = int(math.max(0, 22 - strength * 5))
            w     = strength >= 4 ? 3 : strength >= 2 ? 2 : 1

            xL = math.max(array.get(zBar, i), bar_index - maxSpan)
            xR = bar_index + extRight
            halo = (t - b) * 0.55

            array.push(bxs, box.new(xL, t + halo, xR, b - halo,
                 border_color = color.new(base, 100), bgcolor = color.new(base, 90)))
            array.push(bxs, box.new(xL, t, xR, b,
                 border_color = color.new(good ? hot : base, lineT),
                 border_width = w, bgcolor = color.new(good ? hot : base, fillT)))

            if showLbl
                txt = "  " + str.tostring(mid, format.mintick) + "   " + (tst < 4 ? "~" : "") + str.tostring(rate) + "%  " + str.tostring(hld) + "/" + str.tostring(tst) + "  "
                array.push(lbs, label.new(xR, mid, txt,
                     style = label.style_label_left,
                     color = color.new(good ? hot : INK, 0),
                     textcolor = good ? color.white : (isRes ? RES_TXT : SUP_TXT),
                     size = size.large))

// Signals are drawn as labels rather than plotshape triangles: the stock
// shapes cannot be styled, and a pointed badge in the level's own colour reads
// as part of the system instead of a generic marker pasted on top.
var array<label> sigLbs = array.new<label>()
var array<line>  sigLns = array.new<line>()

if (sigBuy or sigSell) and not na(lastSigPrice)
    up = sigBuy
    array.push(sigLbs, label.new(bar_index, up ? low : high, up ? "  BUY  " : "  SELL  ",
         style = up ? label.style_label_up : label.style_label_down,
         color = up ? SUP_HOT : RES_HOT, textcolor = color.white, size = size.large))
    // a level that produced a signal is eventually pushed out of memory by
    // newer ones, so a stub of it stays behind and the badge keeps its reason
    array.push(sigLns, line.new(bar_index - 6, lastSigPrice, bar_index + 6, lastSigPrice,
         color = color.new(up ? SUP_HOT : RES_HOT, 20), width = 2))
    while array.size(sigLbs) > 40
        label.delete(array.shift(sigLbs))
        line.delete(array.shift(sigLns))

// ─────────────────────────────────────────────────────────────────────────
//  CANDLES — tinted by the trend that gates the signals, not by the last one.
//  A signal three hundred bars ago says nothing about the bar in front of you,
//  and colouring by it paints a whole quiet stretch with a stale opinion.
// ─────────────────────────────────────────────────────────────────────────
var int bias = 0
if sigBuy
    bias := 1
if sigSell
    bias := -1

cCol = upTrend ? SUP : RES
plotcandle(candOn ? open : na, high, low, close, "Candles", color = close >= open ? #FFFFFF : cCol, wickcolor = cCol, bordercolor = cCol)

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

// declared here rather than inside the dashboard block: Pine only allows
// function definitions at global scope
rec(int h, int t) =>
    // a tilde flags a sample too thin to conclude anything from, so one test
    // never reads as a hundred per cent reliable level
    t > 0 ? (t < 4 ? "~" : "") + str.tostring(math.round(h / float(t) * 100)) + "%   " + str.tostring(h) + "/" + str.tostring(t) : "—"

var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(hudP(hudPos), 2, 5, bgcolor = CARD, border_color = color.new(#28323F, 0), border_width = 1)

    // nearest level on each side, and how each has behaved.
    // one declaration per line: Pine applies the type keyword only to the
    // first name in a comma-chained declaration
    float resMid = na
    float supMid = na
    int resT = 0
    int resH = 0
    int supT = 0
    int supH = 0
    if array.size(zTop) > 0
        for i = 0 to array.size(zTop) - 1
            // the same test the drawing uses, so the panel can never name a
            // level that is not on the chart in front of the reader
            if array.get(zTest, i) >= minTest and (array.get(zHold, i) > 0 or array.get(zTest, i) >= 3)
                m = (array.get(zTop, i) + array.get(zBot, i)) / 2.0
                if m > close and (na(resMid) or m < resMid)
                    resMid := m
                    resT := array.get(zTest, i)
                    resH := array.get(zHold, i)
                if m < close and (na(supMid) or m > supMid)
                    supMid := m
                    supT := array.get(zTest, i)
                    supH := array.get(zHold, i)

    hBg = bias == 1 ? SUP : bias == -1 ? RES : #33404F
    hTx = bias == 1 ? "▲  LAST SIGNAL  ·  BUY" : bias == -1 ? "▼  LAST SIGNAL  ·  SELL" : "—  NO SIGNAL YET"

    table.cell(hud, 0, 0, "  " + hTx + "  ", text_color = color.white, text_size = size.large, text_halign = text.align_left, bgcolor = hBg)
    table.cell(hud, 1, 0, (na(lastSigPrice) ? "" : str.tostring(lastSigPrice, format.mintick)) + "  ", text_color = color.white, text_size = size.large, text_halign = text.align_right, bgcolor = hBg)

    // An empty side means no level is being TRACKED there — it says nothing
    // about where price sits in its range, so the panel must not imply that.
    noRes = na(resMid)
    noSup = na(supMid)

    table.cell(hud, 0, 1, "  Resistance above", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    table.cell(hud, 1, 1, (noRes ? "none tracked above" : str.tostring(resMid, format.mintick)) + "  ", text_color = noRes ? MUTE : RES_TXT, text_size = noRes ? size.normal : size.huge, text_halign = text.align_right, bgcolor = CARD)

    table.cell(hud, 0, 2, "  its record", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD_2)
    table.cell(hud, 1, 2, (noRes ? "—" : rec(resH, resT)) + "  ", text_color = noRes ? MUTE : TXT, text_size = size.large, text_halign = text.align_right, bgcolor = CARD_2)

    table.cell(hud, 0, 3, "  Support below", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    table.cell(hud, 1, 3, (noSup ? "none tracked below" : str.tostring(supMid, format.mintick)) + "  ", text_color = noSup ? MUTE : SUP_TXT, text_size = noSup ? size.normal : size.huge, text_halign = text.align_right, bgcolor = CARD)

    table.cell(hud, 0, 4, "  its record", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD_2)
    table.cell(hud, 1, 4, (noSup ? "—" : rec(supH, supT)) + "  ", text_color = noSup ? MUTE : TXT, text_size = size.large, text_halign = text.align_right, bgcolor = CARD_2)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS — closed bars only
// ─────────────────────────────────────────────────────────────────────────
alertcondition(sigBuy,  "Buy signal",  "LunqFX S/R: support held — buy signal confirmed on the close")
alertcondition(sigSell, "Sell signal", "LunqFX S/R: resistance held — sell signal confirmed on the close")
alertcondition(sigBuy or sigSell, "Any signal", "LunqFX S/R: a level held and a signal confirmed on the close")
````
