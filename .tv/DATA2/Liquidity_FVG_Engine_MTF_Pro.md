<!-- tradingview-pine-id: PUB;901fbd84ff944aecb8a228d1c80ac2d4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity & FVG Engine MTF [Pro]

Source: https://www.tradingview.com/script/nexhk00O/

## Description

Liquidity & FVG Engine MTF [Pro]

OVERVIEW

This tool watches price the way a discretionary ICT trader watches it: it keeps track of untouched swing highs and lows across several timeframes at once, flags the moment one of those levels actually gets taken out, and then looks for the Fair Value Gap that tends to show up right after that liquidity grab. Instead of forcing you to flip between chart timeframes to manually mark highs and lows, it does that bookkeeping for you and leaves a clean, readable map of what has been swept, what is still resting, and where price left a gap on its way through.

HOW IT THINKS

Every time a pivot high or low forms on any of the timeframes you enable (1H and 4H by default, with Daily, Weekly and a custom timeframe also available), the script stores it as a pending liquidity level and marks it with a dot. That level stays on the chart, untouched, until price actually interacts with it.

When price takes out a level, the indicator does three things at once. It fades the dot into a swept line so you can see exactly where and when liquidity was taken. It checks the impulse that caused the sweep for a Fair Value Gap, since sweeps and gaps tend to travel together in this kind of price action. And if no gap is found immediately, it keeps watching the next several candles for a reversal gap to form, on the theory that the real move often shows up a few bars after the initial grab, not on the sweep candle itself.

SESSION LIQUIDITY

On top of the swing based levels, the script builds its own Asia and London session ranges directly from the UTC session hours, independent of your broker's timezone or the exchange your chart is set to. The high and low of each session become liquidity levels in their own right, and get swept and reacted to exactly like any swing high or low.

MITIGATED FVGs, EXPLAINED

A gap does not disappear the moment price touches it. What this indicator calls "mitigated" is simply a Fair Value Gap that has been revisited by price after it formed. The box does not vanish when that happens. It turns grey, gets tagged "Mitigated", and is kept on your chart as history rather than being deleted.

The reason that matters is that a mitigated gap is not necessarily a dead gap. Some get tapped once and hold, becoming the base of the next leg. Others get tapped and sliced straight through. Keeping the grey boxes visible for a while lets you scroll back and actually see which behaviour happened at that location, instead of having the evidence erased the instant it stops being "active". You control how many of these grey boxes stay on your chart at once through the history setting, so you can keep as much or as little of that visual record as you want without cluttering the chart forever.

A PRACTICAL WAY TO USE IT

None of this is a signal generator that tells you to buy or sell. It is a map, and the way most people use a map like this is roughly the same three step read every time.

[*]Note which liquidity level is still sitting untouched nearby, on whichever timeframe you trust for bias. An untouched high or low is a magnet until it isn't.
[*]Wait for the sweep itself. A wick that pierces the level and a close that snaps back inside it is a very different event from a candle that just closes through and keeps going, so pay attention to which sweep mode you have configured and what actually happened on that candle.
[*]Look at what the indicator draws immediately after the sweep. A fresh, opposite direction Fair Value Gap appearing in the following bars is the classic follow through many ICT style traders look for as confirmation that the sweep was a genuine reversal event rather than the start of a continuation.

From there, how a person actually structures the trade is personal. Some will look to enter on the first retracement into that fresh gap, treating its edge as an entry zone with a stop beyond the sweep wick. Others prefer to wait for a shift in short term structure after the gap forms before committing, using the gap as confluence rather than as the trigger itself. Either way, the mitigated gap history is useful here too, since it lets you go back and study how price has behaved around similar gaps at similar levels earlier in the session, which is a quick way to build a feel for whether the pair or symbol you're trading tends to respect these zones cleanly or chop through them.

Treat every level and every gap as one piece of evidence, not a standalone signal. The most convincing setups tend to be where a session liquidity sweep, a higher timeframe level, and a fresh FVG all line up in the same place at the same time, rather than any single one of them appearing in isolation.

SETTINGS AT A GLANCE

[*]Pivot Left and Right Bars control how sensitive swing detection is. Lower values catch more, smaller swings.
[*]Merge Tolerance lets nearby levels from different timeframes combine into a single label instead of stacking duplicate dots on top of each other.
[*]Sweep Detection Mode switches between a strict wick and close ICT style sweep, or a looser touch based definition.
[*]Up to five independent timeframes can be enabled for swing liquidity, each with its own colour and label.
[*]Asia and London session ranges can be toggled on or off independently, with their own colours.
[*]The FVG engine has its own ATR based minimum and maximum size filters, so you can exclude gaps that are too small to matter or too large to be realistic entries.
[*]Visual and memory settings let you cap how many active levels, historical swept lines, and mitigated FVGs stay on the chart at once, keeping things readable on lower timeframes over long sessions.

ALERTS

Two alert conditions are built in. One fires the moment any liquidity level is swept. The other fires when a Fair Value Gap forms following a sweep. Both can be wired into TradingView's standard alert system so you do not have to watch the chart tick by tick.

A NOTE ON RISK

This script is a decision support tool, not a trading signal or a promise of future performance. It plots historical and current price behaviour so you can build and test your own approach around it. Always use proper risk management and position sizing, and treat any strategy built around it as something to validate on your own before trading it with real capital. Nothing in this description or in the indicator constitutes financial advice.

---

## Source Code

````pine
//@version=6
indicator('Liquidity & FVG Engine MTF [Pro]', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

//──────────────────────────────────────────────────────────────
// INPUTS & CONFIGURATION
//──────────────────────────────────────────────────────────────
g_sw = 'Swing / Pivot Settings'
leftB = input.int(3, 'Pivot Left Bars', minval = 1, group = g_sw)
rightB = input.int(3, 'Pivot Right Bars', minval = 1, group = g_sw)
mergeTol = input.float(1.0, 'Merge Tolerance (Price Points)', minval = 0, step = 0.1, tooltip = 'Merges duplicate price levels within this range. Note: MTF pivots are almost never exactly equal as floats, so a value of 0 effectively disables merging. For XAUUSD, 0.5–2.0 is a reasonable starting range depending on your typical pivot spread.', group = g_sw)
sweepMode = input.string('Wick Only (ICT True Sweep)', 'Sweep Detection Mode', options = ['Wick Only (ICT True Sweep)', 'Any Breach (Touch/Close)'], group = g_sw, tooltip = 'True Sweep requires the current candle wick to breach the level AND the current candle body to close back inside, in the same bar. Multi-bar reversals (wick breaches, then closes back inside a few bars later) are not captured by this mode by design.')

g_tf = 'Multi-Timeframe Levels'
use1 = input.bool(true, 'Enable TF 1', group = g_tf, inline = 'tf1')
tf1 = input.timeframe('60', '', group = g_tf, inline = 'tf1')
name1 = input.string('1H', 'Label', group = g_tf, inline = 'tf1')
col1 = input.color(#2962ff, 'Color', group = g_tf, inline = 'tf1')

use2 = input.bool(true, 'Enable TF 2', group = g_tf, inline = 'tf2')
tf2 = input.timeframe('240', '', group = g_tf, inline = 'tf2')
name2 = input.string('4H', 'Label', group = g_tf, inline = 'tf2')
col2 = input.color(#7e57c2, 'Color', group = g_tf, inline = 'tf2')

use3 = input.bool(false, 'Enable TF 3', group = g_tf, inline = 'tf3')
tf3 = input.timeframe('D', '', group = g_tf, inline = 'tf3')
name3 = input.string('1D', 'Label', group = g_tf, inline = 'tf3')
col3 = input.color(#ff9800, 'Color', group = g_tf, inline = 'tf3')

use4 = input.bool(false, 'Enable TF 4', group = g_tf, inline = 'tf4')
tf4 = input.timeframe('W', '', group = g_tf, inline = 'tf4')
name4 = input.string('1W', 'Label', group = g_tf, inline = 'tf4')
col4 = input.color(#e91e63, 'Color', group = g_tf, inline = 'tf4')

use5 = input.bool(false, 'Enable TF 5', group = g_tf, inline = 'tf5')
tf5 = input.timeframe('15', '', group = g_tf, inline = 'tf5')
name5 = input.string('15m', 'Label', group = g_tf, inline = 'tf5')
col5 = input.color(#00bcd4, 'Color', group = g_tf, inline = 'tf5')

g_sess = 'Session Liquidity'
useA = input.bool(true, 'Asia Session Range', group = g_sess)
sessA = input.session('0000-0400', 'Asia Hours (UTC)', group = g_sess)
nameA = input.string('Asia', 'Asia Label', group = g_sess)
colA = input.color(#26a69a, 'Asia Color', group = g_sess)

useL = input.bool(true, 'London Session Range', group = g_sess)
sessL = input.session('0700-1000', 'London Hours (UTC)', group = g_sess)
nameL = input.string('London', 'London Label', group = g_sess)
colL = input.color(#e5527a, 'London Color', group = g_sess)

g_fvg = 'Post-Sweep FVG / iFVG Engine'
useFvg = input.bool(true, 'Detect FVG After Sweep', group = g_fvg)
fvgBack = input.int(10, 'Scan Backward Bars', minval = 0, maxval = 50, tooltip = 'Finds FVG inside the sweep-forming impulse', group = g_fvg)
fvgWin = input.int(15, 'Search Forward Window (Bars)', minval = 5, maxval = 100, tooltip = 'Max bars to wait for reversal FVG after sweep', group = g_fvg)
fvgExtend = input.bool(true, 'Extend Unmitigated FVGs Forward', group = g_fvg, tooltip = 'Extends FVG box to current candle until it gets mitigated')
fvgAtrMin = input.float(0.1, 'Min FVG Height (ATR Multiplier)', minval = 0.0, step = 0.05, group = g_fvg)
fvgAtrMax = input.float(5.0, 'Max FVG Height (ATR Multiplier)', minval = 0.5, step = 0.5, group = g_fvg)
onlyRev = input.bool(true, 'Only Reversal FVG (Opposite to Sweep)', group = g_fvg)
sessOnly = input.bool(false, 'Trigger FVG Only On Session Sweeps', group = g_fvg)
bullFvgCol = input.color(#22ab94, 'Bullish FVG Color', group = g_fvg)
bearFvgCol = input.color(#f7525f, 'Bearish FVG Color', group = g_fvg)

g_vis = 'Visual & Memory Management'
pendCol = input.color(#ff1744, 'Active Liquidity Dot Color', group = g_vis)
fadeCol = input.color(#787b86, 'Swept / Mitigated Color', group = g_vis)
lineW = input.int(1, 'Sweep Line Width', minval = 1, maxval = 4, group = g_vis)
labSize = input.string('small', 'Label Size', options = ['tiny', 'small', 'normal'], group = g_vis)
showHist = input.bool(true, 'Show Historical Swept Lines', group = g_vis)
maxPend = input.int(15, 'Max Active Liquidity Levels', minval = 5, maxval = 100, group = g_vis)
maxSwept = input.int(25, 'Max Historical Swept Lines', minval = 10, maxval = 300, group = g_vis)
maxMitigated = input.int(30, 'Max Mitigated FVG History', minval = 5, maxval = 300, tooltip = 'Mitigated FVG boxes are kept on the chart (grayed out) instead of being deleted, up to this count, so you can review what price did after each mitigation. Oldest mitigated boxes are removed first once this limit is exceeded.', group = g_vis)

//──────────────────────────────────────────────────────────────
// CUSTOM TYPES & STORAGE
//──────────────────────────────────────────────────────────────
type Level
	float price
	int x1
	string name
	int dir // 1 = High (BSL), -1 = Low (SSL)
	color col
	label pend
	line ln
	label tag
	bool swept
	bool sess

type Search
	int until
	int dir

type Fvg
	box bx
	float top
	float bot
	int dir // 1 = Bullish, -1 = Bearish
	bool mitigated
	int x // Gap confirmation bar index
	int mitX

var levels = array.new<Level>()
var searches = array.new<Search>()
var fvgs = array.new<Fvg>()

float atr14 = ta.atr(14)

f_size(s) =>
    s == 'tiny' ? size.tiny : s == 'normal' ? size.normal : size.small

f_new(float v) =>
    not na(v) and (na(v[1]) or v != v[1])

f_hasFvg(int x, int dir) =>
    bool found = false
    for f in fvgs
        if f.x == x and f.dir == dir
            found := true
            break
    found

// Replaces (and de-duplicates) any pending search in the same direction before
// pushing a new one, so overlapping sweeps in the same direction don't stack
// multiple redundant forward-search windows.
f_addSearch(int dir) =>
    if array.size(searches) > 0
        for i = array.size(searches) - 1 to 0 by 1
            s = array.get(searches, i)
            if s.dir == dir
                array.remove(searches, i)
    searches.push(Search.new(bar_index + fvgWin, dir))

//──────────────────────────────────────────────────────────────
// REPAINT-FREE MULTI-TIMEFRAME PIVOT LOGIC
//──────────────────────────────────────────────────────────────
f_pivH() =>
    ta.pivothigh(high, leftB, rightB)
f_pivL() =>
    ta.pivotlow(low, leftB, rightB)

[ph1, pl1] = request.security(syminfo.tickerid, tf1, [f_pivH()[1], f_pivL()[1]], barmerge.gaps_off, barmerge.lookahead_off)
[ph2, pl2] = request.security(syminfo.tickerid, tf2, [f_pivH()[1], f_pivL()[1]], barmerge.gaps_off, barmerge.lookahead_off)
[ph3, pl3] = request.security(syminfo.tickerid, tf3, [f_pivH()[1], f_pivL()[1]], barmerge.gaps_off, barmerge.lookahead_off)
[ph4, pl4] = request.security(syminfo.tickerid, tf4, [f_pivH()[1], f_pivL()[1]], barmerge.gaps_off, barmerge.lookahead_off)
[ph5, pl5] = request.security(syminfo.tickerid, tf5, [f_pivH()[1], f_pivL()[1]], barmerge.gaps_off, barmerge.lookahead_off)

//──────────────────────────────────────────────────────────────
// LEVEL MANAGEMENT (ADD & MERGE)
//──────────────────────────────────────────────────────────────
f_addLevel(float px, int dir, string nm, color cl, int x1, bool isSess) =>
    bool merged = false
    for l in levels
        if not l.swept and l.dir == dir and math.abs(l.price - px) <= mergeTol
            if not str.contains(l.name, nm)
                l.name := l.name + ' & ' + nm
                label.set_text(l.pend, l.dir == 1 ? l.name + '\n●' : '●\n' + l.name)
            merged := true
            break
    if not merged
        Level l = Level.new(px, x1, nm, dir, cl, na, na, na, false, isSess)
        l.pend := label.new(x1, px, dir == 1 ? nm + '\n●' : '●\n' + nm, style = label.style_none, textcolor = pendCol, size = f_size(labSize))
        levels.push(l)

// Computed unconditionally every bar (not inside "and" short-circuits) since
// f_new() reads v[1] and must be evaluated on a consistent, uninterrupted
// per-bar series regardless of whether the corresponding TF is enabled.
bool newPh1 = f_new(ph1)
bool newPl1 = f_new(pl1)
bool newPh2 = f_new(ph2)
bool newPl2 = f_new(pl2)
bool newPh3 = f_new(ph3)
bool newPl3 = f_new(pl3)
bool newPh4 = f_new(ph4)
bool newPl4 = f_new(pl4)
bool newPh5 = f_new(ph5)
bool newPl5 = f_new(pl5)

if use1 and newPh1
    f_addLevel(ph1, 1, name1, col1, bar_index - rightB, false)
if use1 and newPl1
    f_addLevel(pl1, -1, name1, col1, bar_index - rightB, false)

if use2 and newPh2
    f_addLevel(ph2, 1, name2, col2, bar_index - rightB, false)
if use2 and newPl2
    f_addLevel(pl2, -1, name2, col2, bar_index - rightB, false)

if use3 and newPh3
    f_addLevel(ph3, 1, name3, col3, bar_index - rightB, false)
if use3 and newPl3
    f_addLevel(pl3, -1, name3, col3, bar_index - rightB, false)

if use4 and newPh4
    f_addLevel(ph4, 1, name4, col4, bar_index - rightB, false)
if use4 and newPl4
    f_addLevel(pl4, -1, name4, col4, bar_index - rightB, false)

if use5 and newPh5
    f_addLevel(ph5, 1, name5, col5, bar_index - rightB, false)
if use5 and newPl5
    f_addLevel(pl5, -1, name5, col5, bar_index - rightB, false)

//──────────────────────────────────────────────────────────────
// SESSION LIQUIDITY (ASIA & LONDON)
// FIX: time() with a session string is evaluated in the chart's exchange
// timezone unless a timezone is explicitly passed. Since the inputs are
// labeled "(UTC)", we must pass "UTC" explicitly or the session ranges will
// silently shift on any feed whose exchange timezone isn't UTC (e.g. MEXC,
// most brokers' XAUUSD feeds).
//──────────────────────────────────────────────────────────────
var float aH = na
var float aL = na
var int aX = na
var bool aIn = false
inA = not na(time(timeframe.period, sessA, 'UTC'))
if inA and not aIn
    aH := high
    aL := low
    aX := bar_index
    aX
else if inA
    aH := math.max(aH, high)
    aL := math.min(aL, low)
    aL
if useA and not inA and aIn and not na(aH)
    f_addLevel(aH, 1, nameA + ' High', colA, aX, true)
    f_addLevel(aL, -1, nameA + ' Low', colA, aX, true)
aIn := inA

var float lH = na
var float lL = na
var int lX = na
var bool lIn = false
inL = not na(time(timeframe.period, sessL, 'UTC'))
if inL and not lIn
    lH := high
    lL := low
    lX := bar_index
    lX
else if inL
    lH := math.max(lH, high)
    lL := math.min(lL, low)
    lL
if useL and not inL and lIn and not na(lH)
    f_addLevel(lH, 1, nameL + ' High', colL, lX, true)
    f_addLevel(lL, -1, nameL + ' Low', colL, lX, true)
lIn := inL

//──────────────────────────────────────────────────────────────
// SWEEP DETECTION & FVG TRIGGERS
//──────────────────────────────────────────────────────────────
bool sweptNow = false
bool fvgNow = false

for l in levels
    if not l.swept
        bool isSwept = false
        if sweepMode == 'Wick Only (ICT True Sweep)'
            isSwept := l.dir == 1 and high > l.price and close < l.price or l.dir == -1 and low < l.price and close > l.price
            isSwept
        else
            isSwept := l.dir == 1 and high > l.price or l.dir == -1 and low < l.price
            isSwept

        if isSwept
            l.swept := true
            sweptNow := true
            label.delete(l.pend)
            l.ln := line.new(l.x1, l.price, bar_index, l.price, color = color.new(fadeCol, 30), width = lineW)
            int mx = l.x1 + int(math.round((bar_index - l.x1) / 2))
            l.tag := label.new(mx, l.price, l.name + ' Swept', style = l.dir == 1 ? label.style_label_down : label.style_label_up, color = color.new(color.white, 100), textcolor = color.new(fadeCol, 10), size = f_size(labSize))

            if useFvg and (not sessOnly or l.sess)
                // 1. Scan Backward for FVG in the impulse run
                for i = 0 to fvgBack by 1
                    if bar_index - i < 3
                        break
                    float bTop = low[i]
                    float bBot = high[i + 2]
                    float sTop = low[i + 2]
                    float sBot = high[i]
                    float bH = bTop - bBot
                    float sH = sTop - sBot

                    // Bullish FVG
                    if bTop > bBot and bH >= atr14 * fvgAtrMin and bH <= atr14 * fvgAtrMax
                        if not f_hasFvg(bar_index - i, 1) and (not onlyRev or l.dir == -1)
                            box bx = box.new(bar_index - i - 1, bTop, bar_index, bBot, bgcolor = color.new(bullFvgCol, 80), border_color = bullFvgCol, border_width = 1, text = 'Bull FVG', text_color = bullFvgCol, text_size = size.tiny)
                            fvgs.push(Fvg.new(bx, bTop, bBot, 1, false, bar_index - i, -1))
                            fvgNow := true
                            break
                    // Bearish FVG
                    else if sTop > sBot and sH >= atr14 * fvgAtrMin and sH <= atr14 * fvgAtrMax
                        if not f_hasFvg(bar_index - i, -1) and (not onlyRev or l.dir == 1)
                            box bx = box.new(bar_index - i - 1, sTop, bar_index, sBot, bgcolor = color.new(bearFvgCol, 80), border_color = bearFvgCol, border_width = 1, text = 'Bear FVG', text_color = bearFvgCol, text_size = size.tiny)
                            fvgs.push(Fvg.new(bx, sTop, sBot, -1, false, bar_index - i, -1))
                            fvgNow := true
                            break

                // 2. Open Forward Search Window for incoming reversal FVG
                f_addSearch(l.dir)

//──────────────────────────────────────────────────────────────
// FORWARD FVG DETECTION
//──────────────────────────────────────────────────────────────
if array.size(searches) > 0
    for i = array.size(searches) - 1 to 0 by 1
        s = array.get(searches, i)
        if bar_index > s.until
            array.remove(searches, i)
            continue

        bool found = false
        // Bullish FVG Check
        if bar_index >= 2 and low > high[2] and low - high[2] >= atr14 * fvgAtrMin and low - high[2] <= atr14 * fvgAtrMax and (not onlyRev or s.dir == -1) and not f_hasFvg(bar_index, 1)
            box bx = box.new(bar_index - 1, low, bar_index, high[2], bgcolor = color.new(bullFvgCol, 80), border_color = bullFvgCol, border_width = 1, text = 'Bull FVG', text_color = bullFvgCol, text_size = size.tiny)
            fvgs.push(Fvg.new(bx, low, high[2], 1, false, bar_index, -1))
            fvgNow := true
            found := true
            found
        // Bearish FVG Check
        else if bar_index >= 2 and high < low[2] and low[2] - high >= atr14 * fvgAtrMin and low[2] - high <= atr14 * fvgAtrMax and (not onlyRev or s.dir == 1) and not f_hasFvg(bar_index, -1)
            box bx = box.new(bar_index - 1, low[2], bar_index, high, bgcolor = color.new(bearFvgCol, 80), border_color = bearFvgCol, border_width = 1, text = 'Bear FVG', text_color = bearFvgCol, text_size = size.tiny)
            fvgs.push(Fvg.new(bx, low[2], high, -1, false, bar_index, -1))
            fvgNow := true
            found := true
            found

        if found
            array.remove(searches, i)

//──────────────────────────────────────────────────────────────
// MITIGATION & iFVG LIFE CYCLE
// CHANGE: mitigated FVGs are no longer deleted after a fixed bar-count
// timeout. Instead they are kept (grayed out, "Mitigated" tag) as history,
// exactly like swept liquidity lines are, up to `maxMitigated` boxes.
// Oldest mitigated FVGs are pruned first once the cap is exceeded, so you
// can scroll back and see what price actually did after each mitigation.
//──────────────────────────────────────────────────────────────
if array.size(fvgs) > 0
    for i = array.size(fvgs) - 1 to 0 by 1
        f = array.get(fvgs, i)
        if not f.mitigated
            // Auto-extend active FVG box to current candle
            if fvgExtend
                box.set_right(f.bx, bar_index)

            // Check mitigation only on subsequent candles (bar_index > f.x)
            bool touched = f.dir == 1 and bar_index > f.x and low < f.top or f.dir == -1 and bar_index > f.x and high > f.bot
            if touched
                f.mitigated := true
                f.mitX := bar_index
                box.set_right(f.bx, bar_index)
                box.set_bgcolor(f.bx, color.new(fadeCol, 90))
                box.set_border_color(f.bx, color.new(fadeCol, 60))
                box.set_text_color(f.bx, color.new(fadeCol, 30))
                box.set_text(f.bx, 'Mitigated')

// Count-based mitigated-FVG history cap (mirrors the swept-levels cap below)
int mitigatedCount = 0
for f in fvgs
    if f.mitigated
        mitigatedCount := mitigatedCount + 1
        mitigatedCount

int remM = mitigatedCount - maxMitigated
while remM > 0
    for i = 0 to array.size(fvgs) - 1 by 1
        f = array.get(fvgs, i)
        if f.mitigated
            box.delete(f.bx)
            array.remove(fvgs, i)
            break
    remM := remM - 1
    remM

//──────────────────────────────────────────────────────────────
// GARBAGE COLLECTION & OBJECT LIMITS
//──────────────────────────────────────────────────────────────
if not showHist and array.size(levels) > 0
    for i = array.size(levels) - 1 to 0 by 1
        l = array.get(levels, i)
        if l.swept and not na(l.ln) and line.get_x2(l.ln) < bar_index
            line.delete(l.ln)
            label.delete(l.tag)
            array.remove(levels, i)

int pendCount = 0
for l in levels
    if not l.swept
        pendCount := pendCount + 1
        pendCount

int remP = pendCount - maxPend
while remP > 0
    for i = 0 to array.size(levels) - 1 by 1
        l = array.get(levels, i)
        if not l.swept
            label.delete(l.pend)
            array.remove(levels, i)
            break
    remP := remP - 1
    remP

int sweptCount = 0
for l in levels
    if l.swept
        sweptCount := sweptCount + 1
        sweptCount

int remS = sweptCount - maxSwept
while remS > 0
    for i = 0 to array.size(levels) - 1 by 1
        l = array.get(levels, i)
        if l.swept
            line.delete(l.ln)
            label.delete(l.tag)
            array.remove(levels, i)
            break
    remS := remS - 1
    remS

//──────────────────────────────────────────────────────────────
// ALERTS
//──────────────────────────────────────────────────────────────
alertcondition(sweptNow, title = 'Liquidity Swept', message = 'A liquidity level has been swept on {{ticker}}!')
alertcondition(fvgNow, title = 'Post-Sweep FVG Formed', message = 'A Fair Value Gap (FVG) formed following a liquidity sweep on {{ticker}}!')
````
