# Trend Trail, Trailing Stop & Buy Sell Signals [LunqFX]

- url: https://www.tradingview.com/script/VGDBnkwq-Trend-Trail-Trailing-Stop-Buy-Sell-Signals-LunqFX/
- type: indicator
- pine_id: PUB;79f2671107df472f8498791b50d284d5
- version: 1.0

## Description

An ATR trailing stop — the trend-following construction most traders know as SuperTrend — breaks in the same place every time. Price stops trending, the trailing stop gets clipped from both sides, and it prints a buy, a sell, a buy and a sell inside twenty bars. Every one of those is a false trend reversal, and the logic is not wrong: it is being asked a question the market is not answering.

This is an open-source modification of the classic ATR based SuperTrend, and it asks that question first. Before it will give you a buy or sell signal it measures whether there is a trend to trail at all. When there is not, the whole chart goes dark — the trailing stop disappears, the fill drops, the candles fall to grey, and no long entry or short entry prints.

And it does not ask you to take that on trust. A plain fixed-distance ATR trailing stop runs alongside it on the same data, and the panel shows both counts side by side with the difference worked out for you.

Included: an average true range trailing stop with adaptive distance, a self-calibrating trend regime filter, buy and sell signals with the stop level printed on every label, a dormant state that switches the chart off in ranges, a live dashboard, and alerts on every trend reversal.

❶ THE REGIME FILTER — what this adds to a SuperTrend

Trend strength is measured with the Kaufman Efficiency Ratio: the ground price actually covered, divided by the distance it travelled getting there. A clean leg scores near 1. The same distance walked back and forth scores near 0.

That raw ratio is useless as a threshold on its own, and this is where most attempts at this fail. Gold on a 30-minute chart runs an efficiency around 0.01 while the euro daily runs 0.40 — any fixed cutoff leaves the fast charts permanently asleep and the slow ones permanently awake. So the reading is scored as a PERCENTILE of the symbol's own recent history. The trail arms when efficiency reaches the top third of what this instrument normally manages, whatever that happens to be. One setting, no per-symbol tuning.

Two guards keep the state from flickering, because they catch different things. Hysteresis handles wobble around the threshold: once armed, the regime stays armed until efficiency drops clearly below the line. A minimum dwell time handles the other case — a clean spike that clears the threshold by a mile and drops straight back. Without both, a filter opens hundreds of regimes and ends up emitting more marks than the raw trail it was meant to quieten.

❷ DORMANCY — the trail does not exist in a range

This is stronger than dimming a colour. When no regime is live the trail is torn down completely, and it is rebuilt from the current price when one opens, taking its side from the move that woke it.

The reason is not cosmetic. A trail left running through a range turns over inside it, unseen, and the market then re-opens onto a direction that was decided while nobody was watching — a position with no entry behind it. Destroying and rebuilding means every segment on the chart begins with a real event, and every event gets a label.

What you see is a chart that is either lit or switched off. Grey candles, no line, no signal: there is nothing here to do, and you can read that from across the room.

❸ THE ATR TRAILING STOP AND ITS ADAPTIVE DISTANCE

The average true range sets the band width, and the trailing stop ratchets in the direction of the trend and never loosens — the same dynamic support and resistance line a SuperTrend gives you, flipping to a trend reversal when price closes through it. The stop level is printed on every buy and sell label, so the one number you need at the moment of a long entry or short entry is already on the chart.

The distance is not fixed. One multiple has to be either too tight for choppy conditions or too loose for a clean run — it cannot be right for both, so the distance widens as efficiency falls and tightens as it rises. Turn it off in the settings for a constant multiple.

❹ THE RECEIPT — a filter you can audit

A second trailing stop is computed on the same bars: fixed distance, no regime filter, nothing else — what an ordinary trailing stop would have done here. Its flip count sits in the panel next to this one's signal count, with the reduction calculated:

Signals here · plain trail 164 · 236 Noise removed −31%

Both numbers count the same thing — entries against entries. A state is not counted as a trade on either side. And when the result goes the wrong way the panel says "Noise ADDED" in red rather than quietly dropping the sign, because a panel that flatters its own script is worse than no panel.

Read it as what it is: a measure of how much less often this fires, not a claim about money. Fewer signals is not automatically better signals, and this number does not pretend otherwise.

❺ THE DASHBOARD

Direction and stop price in the header, trend strength as a 0–100 reading with a bar and the arming threshold beneath it, current stop distance in price and in ATR, and the two comparison rows. In the dormant state the header says so plainly and the stop row reads "no stop — dormant" rather than printing a number that does not exist.

HOW TO USE IT

1 — Trade the lit stretches, ignore the grey ones. That is the whole discipline the tool is built around, and it is the part most trend systems leave to you.

2 — Use the trail as the stop, not just as a signal line. The level on the label is where the stop goes; the panel keeps showing the distance in ATR as the trade runs, so you can see when the trail has tightened to the point of being one bar away.

3 — Set the arming threshold to your patience. At 65 you get the top third of this symbol's clean moves. Raise it to 75 and you will trade far less on far cleaner legs. This is the one setting worth changing.

4 — Read the comparison rows on your own instrument. If the reduction on your symbol and timeframe is small, the filter is not finding much to remove there — which is itself information about the instrument, not a reason to distrust the reading.

HOW IT WORKS

The average true range sets the band width; the mid price plus and minus that width form the raw bands, exactly as in a classic ATR trailing stop. Each band ratchets in the trend's favour and never against it, and price closing through the opposite band flips the direction — the trend reversal. Efficiency is the net move over the lookback divided by the summed absolute bar-to-bar movement, ranked as a percentile against its own history. The regime arms above the threshold with hysteresis and a minimum dwell, and outside a regime the trail is not computed at all.

Works on any symbol and any timeframe. The regime filter needs the self-calibration window to fill before it can arm, so the first stretch of a fresh chart stays dormant by design.

SETTINGS

▸ Trail — ATR length, base distance, adaptive distance and its strength. ▸ Regime Filter — on or off, efficiency lookback, self-calibration window, arming percentile, hysteresis, minimum bars per regime. ▸ Signals — buy and sell signals, labels or arrows, stop level on the label. ▸ Visuals — glow, fill, candle dimming, dashboard position.

ALERTS — buy, sell, any signal, regime opened and regime closed. All fire on closed bars.

NON-REPAINTING — the trail is built from closed-bar values and every signal fires on bar close. A printed signal never moves and never disappears.

WHY THESE PARTS ARE ONE SCRIPT

The trail alone is an ordinary trailing stop and will chop you up in a range. The regime filter alone has nothing to gate. The comparison exists only because a filter nobody can check is just a claim, and it needs both of the others to have something to measure. Take any one away and the other two stop making a point.

This indicator is an educational market-analysis tool, not financial advice. It does not predict price. The comparison figures describe how often each version of the trail changed direction on the loaded chart; they say nothing about profit or loss. Always confirm with your own analysis and manage your risk.

## Source Code

````pine
//@version=6
// ============================================================================
//  Trend Trail, Trailing Stop & Buy Sell Signals [LunqFX]
// ----------------------------------------------------------------------------
//  Every trailing stop indicator breaks in the same place. Price stops
//  trending, the trail starts getting clipped from both sides, and it prints
//  a buy, a sell, a buy and a sell inside twenty bars. The logic is not
//  wrong — it is being asked a question the market is not answering.
//
//  So this one measures whether there is a trend to trail in the first place,
//  and when there is not, it goes dark. The trail greys out, the fill drops,
//  the candles dim and NO signal prints.
//
//  And it does not ask you to take that on faith. A plain fixed-distance
//  trail is computed alongside it on the same data, and the panel shows how
//  many times that one would have flipped against how many signals this one
//  actually gave. The claim is on the chart as a number you can check.
//
//    1  THE TRAIL        ATR trailing stop that ratchets and flips
//    2  REGIME           Kaufman Efficiency Ratio decides trend or chop
//    3  ADAPTIVE WIDTH   widens in weak conditions, tightens in strong ones
//    4  DORMANCY         no regime, no signal, and the chart says so
//    5  THE RECEIPT      side-by-side flip count against a plain trail
//
//  NON-REPAINTING: the trail is built from closed-bar values and signals
//  fire on bar close. A printed signal never moves or disappears.
// ============================================================================
indicator("Trend Trail, Trailing Stop & Buy Sell Signals [LunqFX]",
     // the self-calibration window can be set as high as 1000, and the
     // history buffer has to be able to reach back that far
     "TREND TRL", overlay = true, max_bars_back = 1000, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE — a matched neon pair, and a grey for the dormant state. The
//  contrast between them is the whole design: the chart is either lit or it
//  is not, and you know which from across the room.
// ─────────────────────────────────────────────────────────────────────────
UP      = #00F5D4
DN      = #FF2E88
UP_DEEP = #0A5F55
DN_DEEP = #8E1148
SLEEP   = #6B7688
SLEEP_D = #414C5C     // lifted from near-black: a dormant candle still has to be visible
CARD    = #131A24
CARD_2  = #1B2431
TXT     = #F1F5F9
MUTE    = #94A3B8

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gT      = "Trail"
atrLen  = input.int(14, "ATR length", minval = 2, maxval = 100, group = gT)
baseMlt = input.float(2.6, "Trail distance (ATR)", minval = 0.5, maxval = 10, step = 0.1, group = gT)
adaptOn = input.bool(true, "Adapt distance to conditions", group = gT, tooltip = "The trail widens when the market is choppy and tightens when it trends cleanly. One fixed multiple has to be either too tight for chop or too loose for a trend — it cannot be right for both.")
adaptAmt= input.float(0.6, "Adaptation strength", minval = 0.0, maxval = 1.5, step = 0.05, group = gT)

gR      = "Regime Filter"
regimeOn= input.bool(true, "Only trade when a trend exists", group = gR, tooltip = "Uses the Kaufman Efficiency Ratio: the ground price actually covered against the distance it travelled getting there. A straight move scores near 1; the same distance walked back and forth scores near 0.")
erLen   = input.int(20, "Efficiency lookback", minval = 5, maxval = 200, group = gR)
// A fixed cutoff cannot work across instruments. Gold on 30m runs an
// efficiency of about 0.01 while the euro daily runs 0.40 — one absolute
// number leaves the fast charts permanently dormant. So the threshold is a
// PERCENTILE of the symbol's own recent efficiency: it calibrates itself to
// whatever normal happens to be here.
rankLook= input.int(200, "Self-calibration window", minval = 50, maxval = 1000, group = gR, tooltip = "How much of this symbol's own history defines what counts as an efficient move for it.")
rankMin = input.int(65, "Arms above percentile", minval = 30, maxval = 95, group = gR, tooltip = "65 means the trail arms when efficiency is in the top 35% of what this symbol usually manages. Raise it to trade only the cleanest legs.")
hyst    = input.int(15, "Hysteresis", minval = 0, maxval = 40, group = gR, tooltip = "Once armed the regime stays armed until efficiency drops this far below the threshold. Without a gap the regime flickers on and off around the line and prints a signal every time.")
dwell   = input.int(15, "Minimum bars per regime", minval = 1, maxval = 200, group = gR, tooltip = "A regime has to hold for at least this many bars before it is allowed to change. Hysteresis alone only catches wobble around the threshold — it does nothing about a clean spike that goes well past the line and comes straight back, and a few hundred of those turn the filter into a signal generator.")

gS      = "Signals"
sigOn   = input.bool(true, "Buy and sell signals", group = gS)
sigLbl  = input.bool(true, "Labels instead of arrows", group = gS)
sigStop = input.bool(true, "Show the stop level on the label", group = gS, tooltip = "The trail price at the moment of the signal — where the stop goes if you take it. It is the one number you need at that instant and the one you would otherwise have to read off the panel.")

gV      = "Visuals"
glowOn  = input.bool(true, "Glow", group = gV)
fillOn  = input.bool(true, "Fill to price", group = gV)
candOn  = input.bool(true, "Dim candles when dormant", group = gV, tooltip = "Candles carry the trend colour while a regime is live and fall back to grey when it is not. A screen of grey candles is the fastest way to see there is nothing here to do.")
showHUD = input.bool(true, "Dashboard", group = gV)
hudPos  = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gV)

// ─────────────────────────────────────────────────────────────────────────
//  REGIME — Kaufman Efficiency Ratio
//  Net distance divided by the distance actually walked. A clean leg scores
//  near 1. The same ground covered back and forth scores near 0. It answers
//  the only question that matters here: is there a direction to trail?
// ─────────────────────────────────────────────────────────────────────────
netMove = math.abs(close - close[erLen])
pathLen = math.sum(math.abs(close - close[1]), erLen)
er      = pathLen > 0 ? netMove / pathLen : 0.0

// scored against this symbol's own history rather than against a constant
erRank = ta.percentrank(er, rankLook)

// TWO GUARDS, BECAUSE THEY CATCH DIFFERENT THINGS.
// Hysteresis handles wobble: arm at the threshold, disarm only once
// efficiency has fallen clearly below it, so the state does not chatter
// across the line. It does nothing, though, about a clean spike that clears
// the threshold by a mile and drops straight back — and a few hundred of
// those open a few hundred regimes. So a state, once entered, is also held
// for a minimum number of bars before it may change at all.
var bool armed = false
var int  swBar = 0        // `switch` is a Pine keyword — it cannot name a variable

canSwitch = bar_index - swBar >= dwell

if not na(erRank)
    if not armed and canSwitch and erRank >= rankMin and nz(erRank[1], 0) >= rankMin
        armed := true
        swBar := bar_index
    else if armed and canSwitch and erRank < rankMin - hyst
        armed := false
        swBar := bar_index

trending = not regimeOn or armed

// a bool series returns na on the first bars, so `trending[1]` cannot be
// compared safely. An explicit var read-before-write gives a clean edge.
// bar_index > 0 keeps the very first bar from registering as an opening:
// wasTrend starts false, so with the filter switched off the script would
// otherwise stamp a marker on bar zero out of nothing.
var bool wasTrend = false
regimeOpen  = bar_index > 0 and trending and not wasTrend
regimeClose = bar_index > 0 and not trending and wasTrend
wasTrend := trending

// ─────────────────────────────────────────────────────────────────────────
//  THE TRAIL
// ─────────────────────────────────────────────────────────────────────────
atrV = ta.atr(atrLen)
mult = adaptOn ? baseMlt * (1.0 + (1.0 - er) * adaptAmt) : baseMlt

// THE TRAIL DOES NOT EXIST WHILE THE CHART IS DORMANT.
// This is the fix for a whole family of problems that no amount of patching
// the labels could solve. If the trail keeps running through the dormant
// stretch it turns over in there, unseen, and the regime then re-opens onto
// a direction that was decided while nobody was looking — a coloured segment
// with no event at its start, and therefore no honest way to label it.
//
// So the trail is torn down when the regime closes and built again from the
// current price when it opens, taking its side from the very move that woke
// the regime up. Every segment now begins with a real entry, every entry
// gets a label, and the counter counts entries and nothing else.
var float upB = na
var float dnB = na
var int   dir = 0          // 0 = dormant, no trail at all

rawUp = hl2 - mult * atrV
rawDn = hl2 + mult * atrV

if not trending
    dir := 0
    upB := na
    dnB := na
else if nz(dir[1], 0) == 0
    dir := close >= close[erLen] ? 1 : -1
    upB := rawUp
    dnB := rawDn
else
    upB := close[1] > nz(upB[1], rawUp) ? math.max(rawUp, nz(upB[1], rawUp)) : rawUp
    dnB := close[1] < nz(dnB[1], rawDn) ? math.min(rawDn, nz(dnB[1], rawDn)) : rawDn
    dir := close > nz(dnB[1], rawDn) ? 1 : close < nz(upB[1], rawUp) ? -1 : nz(dir[1], 1)

trail = dir == 1 ? upB : dir == -1 ? dnB : na

// One event covers both cases: a fresh trail after dormancy (previous state
// 0) and a flip inside a live regime (previous state opposite). Either way
// the direction changed in front of the reader, which is what a signal is.
entryUp = dir ==  1 and nz(dir[1], 0) !=  1
entryDn = dir == -1 and nz(dir[1], 0) != -1

// ─────────────────────────────────────────────────────────────────────────
//  THE PLAIN TRAIL — the control group
//  The same ATR trailing stop at a fixed distance with no regime filter at
//  all: what every other trailing stop on the platform would have done on
//  this exact data. Its flip count is the number the panel is measured
//  against. A filter nobody can audit is only a claim.
// ─────────────────────────────────────────────────────────────────────────
var float pUpB = na
var float pDnB = na
var int   pDir = 1

pRawUp = hl2 - baseMlt * atrV
pRawDn = hl2 + baseMlt * atrV

pUpB := close[1] > nz(pUpB[1], pRawUp) ? math.max(pRawUp, nz(pUpB[1], pRawUp)) : pRawUp
pDnB := close[1] < nz(pDnB[1], pRawDn) ? math.min(pRawDn, nz(pDnB[1], pRawDn)) : pRawDn
pDir := close > nz(pDnB[1], pRawDn) ? 1 : close < nz(pUpB[1], pRawUp) ? -1 : nz(pDir[1], 1)

var int plainFlips = 0
if pDir != nz(pDir[1], pDir) and barstate.isconfirmed
    plainFlips += 1

// ─────────────────────────────────────────────────────────────────────────
//  SIGNALS
//  One rule, and only one: the trail changed side while the regime was live.
//  Because the trail is destroyed and rebuilt across dormancy, that single
//  rule already covers both a fresh segment and a flip inside a segment —
//  there is no second class of event to draw differently or argue about.
//
//  No same-direction guard is needed: a direction cannot be entered twice
//  without leaving it first, which is itself an entry the other way.
// ─────────────────────────────────────────────────────────────────────────
buySig  = sigOn and barstate.isconfirmed and entryUp
sellSig = sigOn and barstate.isconfirmed and entryDn

var int taken = 0
if buySig or sellSig
    taken += 1

// ─────────────────────────────────────────────────────────────────────────
//  DRAWING
//  The trail is four stacked lines of falling width and rising opacity.
//  Stacked transparency is what makes a glow instead of a coloured line with
//  a hard edge — the same trick a neon tube uses.
// ─────────────────────────────────────────────────────────────────────────
tCol = dir == 1 ? UP : dir == -1 ? DN : SLEEP
live = tCol

// `trail` is already na while dormant, so the drawing needs no second guard
tLive = trail

plot(glowOn ? tLive : na, "Glow outer", color = color.new(live, 90), linewidth = 7, style = plot.style_linebr)
plot(glowOn ? tLive : na, "Glow mid",   color = color.new(live, 76), linewidth = 5, style = plot.style_linebr)
plot(glowOn ? tLive : na, "Glow inner", color = color.new(live, 52), linewidth = 3, style = plot.style_linebr)
pTrail = plot(tLive, "Trail", color = live, linewidth = 2, style = plot.style_linebr)

// The price plot has to break on exactly the same bars as the trail. When
// one side of a fill has gaps and the other does not, the fill closes across
// the gap and throws a tall vertical block onto the chart.
pPrice = plot(fillOn and dir != 0 ? close : na, "Price", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
fill(pTrail, pPrice, color = color.new(tCol, 88), title = "Trail fill")

// ─────────────────────────────────────────────────────────────────────────
//  CANDLES
// ─────────────────────────────────────────────────────────────────────────
// Dormant candles are quieted, not erased. At 50%+ transparency they vanish
// entirely on a light background, and a chart you cannot read is not a
// design decision.
isUp  = close >= open
cLive = trending ? (isUp ? UP : DN) : (isUp ? SLEEP : SLEEP_D)
plotcandle(candOn ? open : na, high, low, close, "Candles",
     color = color.new(cLive, trending ? 22 : 30),
     wickcolor = color.new(cLive, trending ? 25 : 20),
     bordercolor = color.new(cLive, trending ? 0 : 12))

// ─────────────────────────────────────────────────────────────────────────
//  SIGNAL MARKS
// ─────────────────────────────────────────────────────────────────────────
plotshape(buySig  and not sigLbl, "Buy",  shape.triangleup,   location.belowbar, UP, size = size.small)
plotshape(sellSig and not sigLbl, "Sell", shape.triangledown, location.abovebar, DN, size = size.small)

// The glyph carries the direction before the word is read, and the stop
// level rides along because that is the number you actually need at the
// instant a signal prints. Text is near-black rather than white: on a neon
// fill, dark type is what stays legible when the chart is zoomed out.
stopTxt = sigStop ? "   " + str.tostring(trail, format.mintick) : ""

if sigLbl and buySig
    label.new(bar_index, low, "  ▲  BUY" + stopTxt + "  ", yloc = yloc.belowbar,
         style = label.style_label_up, color = UP, textcolor = #04211D, size = size.normal)
if sigLbl and sellSig
    label.new(bar_index, high, "  ▼  SELL" + stopTxt + "  ", yloc = yloc.abovebar,
         style = label.style_label_down, color = DN, textcolor = #2B0716, size = size.normal)

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

// the efficiency reading as a bar you glance at rather than a number you
// have to interpret. Full blocks only — thinner glyphs render unevenly.
meter(float v) =>
    n = int(math.round(math.min(math.max(v, 0.0), 1.0) * 10))
    s = ""
    for i = 1 to 10
        s := s + (i <= n ? "█" : "░")
    s

var table hud = table.new(position.top_right, 2, 6)
if showHUD and barstate.islast
    table.delete(hud)
    hud := table.new(hudP(hudPos), 2, 6, bgcolor = CARD,
         border_color = color.new(#28323F, 0), border_width = 1)

    hBg = not trending ? SLEEP_D : dir == 1 ? UP_DEEP : DN_DEEP
    hTx = not trending ? "◍  DORMANT  ·  no trend to trail" : dir == 1 ? "▲  TRAILING LONG" : "▼  TRAILING SHORT"

    table.cell(hud, 0, 0, "  " + hTx + "  ", text_color = color.white, text_size = size.large, text_halign = text.align_left, bgcolor = hBg)
    // the trail is genuinely na while dormant now, so every cell that reads
    // from it needs a fallback or the panel prints NaN at the reader
    trTx = dir == 0 ? "—" : str.tostring(trail, format.mintick)
    table.cell(hud, 1, 0, trTx + "  ", text_color = color.white, text_size = size.normal, text_halign = text.align_right, bgcolor = hBg)

    // the percentile, not the raw ratio: 0.01 on gold 30m and 0.40 on the
    // euro daily are the same reading once each is scored against its own
    // history, and only one of those two numbers can be read at a glance
    rk = nz(erRank, 0)
    table.cell(hud, 0, 1, "  Trend strength", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    table.cell(hud, 1, 1, str.tostring(int(rk)) + "  ", text_color = trending ? TXT : SLEEP, text_size = size.huge, text_halign = text.align_right, bgcolor = CARD)

    table.cell(hud, 0, 2, "  " + meter(rk / 100.0), text_color = trending ? (dir == 1 ? UP : DN) : SLEEP, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD_2)
    table.cell(hud, 1, 2, "arms at " + str.tostring(rankMin) + "  ", text_color = MUTE, text_size = size.normal, text_halign = text.align_right, bgcolor = CARD_2)

    dist  = math.abs(close - nz(trail, close))
    distA = nz(atrV) > 0 ? dist / atrV : 0.0     // both branches float, or Pine rejects the ternary
    dTx   = dir == 0 ? "no stop — dormant" : str.tostring(dist, format.mintick) + "   (" + str.tostring(distA, "#.#") + " ATR)"
    table.cell(hud, 0, 3, "  Stop distance", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    table.cell(hud, 1, 3, dTx + "  ", text_color = dir == 0 ? SLEEP : TXT, text_size = size.normal, text_halign = text.align_right, bgcolor = CARD)

    // the two rows the whole script exists to put next to each other, with
    // the comparison done for you — a reader should not have to divide two
    // four-digit numbers in their head to find out whether this works
    table.cell(hud, 0, 4, "  Signals here  ·  plain trail", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD_2)
    table.cell(hud, 1, 4, str.tostring(taken) + "  ·  " + str.tostring(plainFlips) + "  ", text_color = TXT, text_size = size.large, text_halign = text.align_right, bgcolor = CARD_2)

    // A bad result has to LOOK bad. Printing "23%" unsigned when the script
    // produced 23% MORE marks than the plain trail reads as a win, and a
    // panel that flatters its own script is worse than no panel.
    cut   = plainFlips > 0 ? (plainFlips - taken) / float(plainFlips) * 100.0 : 0.0
    sign  = cut > 0.5 ? "−" : cut < -0.5 ? "+" : ""
    cutTx = sign + str.tostring(math.abs(cut), "#") + "%"
    table.cell(hud, 0, 5, cut < -0.5 ? "  Noise ADDED" : "  Noise removed", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    table.cell(hud, 1, 5, cutTx + "  ", text_color = cut < -0.5 ? DN : cut > 0.5 ? UP : MUTE, text_size = size.huge, text_halign = text.align_right, bgcolor = CARD)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS — closed bars only
// ─────────────────────────────────────────────────────────────────────────
alertcondition(buySig,  "Buy signal",  "LunqFX Trend Trail: trail flipped long with a trend in place")
alertcondition(sellSig, "Sell signal", "LunqFX Trend Trail: trail flipped short with a trend in place")
alertcondition(buySig or sellSig, "Any signal", "LunqFX Trend Trail: the trail flipped with a trend in place")
alertcondition(barstate.isconfirmed and regimeOpen,  "Regime opened", "LunqFX Trend Trail: a trend regime has opened — the trail is armed")
alertcondition(barstate.isconfirmed and regimeClose, "Regime closed", "LunqFX Trend Trail: the trend regime has closed — signals are off")
````
