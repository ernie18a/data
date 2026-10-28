# Volume breakout

- url: https://www.tradingview.com/script/8EICwVwh-Volume-breakout/
- type: indicator
- pine_id: PUB;f72d677fbb2a4ae89bcc3fb17da84535
- version: 4.0

## Description

[b]Volume breakout[/b] separates real breakouts from false ones. A move out of a range is only credible when heavy volume drives it. This indicator checks every breakout for that fuel and marks only the ones that pass. [i]No volume, no breakout.[/i]


[b]HOW IT WORKS[/b]

The pane shows volume columns colored with the classic HawkEye method: [b]green[/b] is buying volume, [b]red[/b] is selling volume, [b]gray[/b] is neutral noise. The yellow line is the average volume.

A breakout is a close above the highest high, or below the lowest low, of the last 20 bars. The close must clear that level by a small ATR buffer, so one-tick pokes do not count. The breakout is only [b]confirmed[/b] when all three checks agree:

- [b]Heavy volume:[/b] at least 1.5x normal. On intraday charts, normal means the same time of day over recent sessions, so the opening bell does not fake a volume spike.
- [b]HawkEye agrees:[/b] the bar is green for a bullish breakout, red for a bearish one.
- [b]Strong close:[/b] the bar closes in the top 40% of its range for a bullish breakout, or the bottom 40% for a bearish one.

Two optional filters make it stricter: a maximum range width in ATR, so only breakouts from tight consolidations count, and higher-timeframe trend alignment, which does not repaint.


[b]HOW TO USE[/b]

- [b]Green circle:[/b] a bullish breakout backed by buyers.
- [b]Red circle:[/b] a bearish breakdown backed by sellers.
- [b]No circle:[/b] price broke out, but the volume did not back it. Treat it as [i]suspect[/i] and a possible trap.

The confirmed bar's volume column is highlighted as well. A natural invalidation level is a close back inside the old range.

Three alerts are available: [i]Confirmed bullish breakout[/i], [i]Confirmed bearish breakdown[/i] and [i]Suspect breakout[/i]. They fire on the bar close only, so a live bar that reverses never triggers them.


[b]WHEN TO USE[/b]

- Breakouts from ranges, bases and consolidations.
- Stocks, crypto and futures, on any timeframe.
- Not on symbols without real volume data, such as many forex pairs and CFDs. Without volume the indicator gives no verdict.


[i]Volume coloring is based on the classic HawkEye Volume Indicator.[/i]

## Source Code

````pine
//@version=6
// author © OnnoP
// Volume-confirmed breakout detector, v4: combines the "How to confirm
// breakouts" rule (a breakout is only credible on heavy volume) with the
// HawkEye Volume Indicator's bar classification (green = buying volume,
// red = selling volume, gray = neutral/noise). The volume columns are colored
// HawkEye style; a breakout is CONFIRMED only when price clears the level by an
// ATR buffer, relative volume is high, HawkEye agrees with the direction and the
// bar closed with conviction (near its own high/low).
// Two kinds of breakout: the regular one clears the lookback high/low, the
// major one clears a horizontal level price has turned at several times.
// Volume may confirm on the breakout bar itself or, when it builds over the
// next few bars, late through the sustained volume window.
// Filters: a tight range before the breakout and higher-timeframe trend
// alignment. The defaults were tuned on ETH, BTC, AAPL and EURUSD, daily and
// 4h, measuring the 10-bar result of every signal with a stop at the broken level.

// Drawn on the main chart with its own hidden scale, like the built-in Volume.
indicator("Volume breakout", overlay=true, scale=scale.none, format=format.volume,
     max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=500)

// ══════════════════════════════════════════════════════════════════════
// SETTINGS
// ══════════════════════════════════════════════════════════════════════

iSignals = input.string("Strict", "Signals", options=["Strict", "Balanced", "More"],
     tooltip="Strict (default) uses the settings that tested best on crypto, stocks and forex: few signals, the highest follow-through. Balanced allows wider ranges and a little less volume. More also drops the weekly trend filter: more signals, more false breakouts.")
iShowLvl = input.bool(false, "Draw levels on the price chart",
     tooltip="Dashed lines show the nearest major resistance above price and support below it. When a major level breaks with confirmation, a solid line marks it from its first touch to the breakout bar.")
iHeightPct = input.int(25, "Volume height (% of chart)", minval=5, maxval=100,
     tooltip="How high the tallest volume column reaches, like the built-in Volume. Use 100 if you move the indicator to its own pane.")

// Signal filters per preset. Strict is the tested default.
maxBaseAtr = iSignals == "Strict" ? 5.0 : iSignals == "Balanced" ? 8.0 : 0.0   // widest range before a breakout, in ATR (0 = off)
volMult    = iSignals == "Strict" ? 2.0 : iSignals == "Balanced" ? 1.75 : 1.5  // breakout bar volume vs normal
volWinMult = iSignals == "Strict" ? 1.5 : 1.3                                  // average volume over the window vs normal
htfOn      = iSignals != "More"                                                // breakout must agree with the weekly trend

// Fixed settings (tested values).
LOOKBACK     = 20     // a regular breakout clears the high/low of this many bars
BUF_ATR      = 0.5    // the close must clear the level by this share of the ATR
MIN_CLV      = 0.6    // a bullish breakout bar closes in the top 40% of its range (bearish: bottom 40%)
PIV_LEN      = 5      // a swing point needs this many lower highs / higher lows on each side
LVL_LOOKBACK = 250    // swing points older than this no longer count as touches
LVL_TOL_ATR  = 0.5    // swing points this close together (in ATR) touch the same level
LVL_TOUCHES  = 3      // touches a level needs to count as major
LVL_MIN_AGE  = 120    // a major level's first touch is at least this many bars old
VOL_LEN      = 20     // length of the "normal" volume baseline (bars, or sessions intraday)
VOL_WIN      = 3      // bars after a breakout in which volume may still confirm it
HTF_TF       = "W"    // trend timeframe
HTF_LEN      = 20     // trend EMA length on that timeframe

// HawkEye constants (the classic indicator's defaults).
HAWK_LEN = 200     // length of the range and volume averages HawkEye compares each bar against
HAWK_DIV = 3.6     // width of the neutral band around the previous bar's midpoint: mid ± range/divisor
TOP_MARGIN = 10   // TradingView's default top chart margin (Settings > Canvas); the hidden scale sits inside it, the built-in Volume does not
ATR_LEN  = 14      // ATR used for the breakout buffer, the range width filter and the touch tolerance

// ══════════════════════════════════════════════════════════════════════
// HAWKEYE CLASSIFICATION (port of the classic HawkEye Volume Indicator)
// ══════════════════════════════════════════════════════════════════════

rng      = high - low
// Until 200 bars exist the classic averages are na and nothing could confirm,
// so fall back to the shorter volume-average length.
rngAvg   = nz(ta.sma(rng, HAWK_LEN), ta.sma(rng, VOL_LEN))
hawkVolA = nz(ta.sma(nz(volume), HAWK_LEN), ta.sma(nz(volume), VOL_LEN))

high1 = high[1]
low1  = low[1]
mid1  = hl2[1]
u1 = mid1 + (high1 - low1) / HAWK_DIV
d1 = mid1 - (high1 - low1) / HAWK_DIV

rEnabled = (rng > rngAvg and close < d1 and volume > hawkVolA) or close < mid1

gEnabled = close > mid1
     or (rng > rngAvg and close > u1 and volume > hawkVolA)
     or (high > high1 and rng < rngAvg / 1.5 and volume < hawkVolA)
     or (low < low1 and rng < rngAvg / 1.5 and volume > hawkVolA)

grEnabled = (rng > rngAvg and close > d1 and close < u1 and volume > hawkVolA and volume < hawkVolA * 1.5 and volume > volume[1])
     or (rng < rngAvg / 1.5 and volume < hawkVolA / 1.5)
     or (close > d1 and close < u1)

// Same precedence as the original: gray first, then green, then red, else blue.
hawkGray  = grEnabled
hawkGreen = not hawkGray and gEnabled
hawkRed   = not hawkGray and not hawkGreen and rEnabled
// Dimmed like the built-in Volume, so the columns stay in the background and
// only the bright breakout column and dot stand out.
hawkColor = hawkGray ? color.new(color.gray, 65) : hawkGreen ? color.new(#26a69a, 50) : hawkRed ? color.new(#ef5350, 50) : color.new(color.blue, 60)

// ══════════════════════════════════════════════════════════════════════
// VOLUME BASELINE
// ══════════════════════════════════════════════════════════════════════

hasVol = not na(volume) and volume > 0
// Symbols without volume data (many CFDs and forex pairs) get no volume plots
// at all, only a note, instead of a flat average line at zero.
var bool anyVol = false
anyVol := anyVol or hasVol
// "Normal" volume: the median of the last VOL_LEN bars, lagged one bar so the
// breakout bar is not part of its own baseline.
volMed = ta.percentile_nearest_rank(nz(volume), VOL_LEN, 50)[1]

// Intraday, each bar is compared with the same time slot over the last VOL_LEN
// sessions instead, so the opening bars are not always read as huge volume.
type VolSlot
    array<float> vols

var slots = map.new<int, VolSlot>()
float volTod = na
if timeframe.isintraday
    key  = hour(time) * 3600 + minute(time) * 60 + second(time)
    slot = slots.get(key)
    if na(slot)
        slot := VolSlot.new(array.new<float>())
        slots.put(key, slot)
    if slot.vols.size() >= 5
        volTod := slot.vols.median()   // read before this bar is added
    if hasVol and barstate.isconfirmed   // committed bars only, so a live bar is never pushed twice
        slot.vols.push(volume)
        if slot.vols.size() > VOL_LEN
            slot.vols.shift()

volAvg = nz(volTod, volMed)
relVol = hasVol and volAvg > 0 ? volume / volAvg : 0.0
volOk  = relVol >= volMult

// ══════════════════════════════════════════════════════════════════════
// LEVELS
// ══════════════════════════════════════════════════════════════════════

hiLevel = ta.highest(high, LOOKBACK)[1]
loLevel = ta.lowest(low, LOOKBACK)[1]
atr1    = ta.atr(ATR_LEN)[1]   // before the breakout bar, so its own range does not widen the buffer
buf     = BUF_ATR * nz(atr1)

// ── Major levels: clusters of swing highs and lows ─────────────────────
var array<float> pivP = array.new<float>()   // swing prices inside the lookback, oldest first
var array<int>   pivB = array.new<int>()     // their bar indexes
var array<float> lvlP = array.new<float>()   // major levels built from those swings
var array<int>   lvlS = array.new<int>()     // bar of each level's first touch

ph = ta.pivothigh(high, PIV_LEN, PIV_LEN)
pl = ta.pivotlow(low, PIV_LEN, PIV_LEN)

bool pivChanged = false
if not na(ph)
    pivP.push(ph)
    pivB.push(bar_index - PIV_LEN)
    pivChanged := true
if not na(pl)
    pivP.push(pl)
    pivB.push(bar_index - PIV_LEN)
    pivChanged := true
while pivB.size() > 0 and bar_index - pivB.first() > LVL_LOOKBACK
    pivB.shift()
    pivP.shift()
    pivChanged := true

// Rebuild the level list only when the swing list changed. Swings within the
// tolerance of each other form one level at their average price.
if pivChanged
    lvlP.clear()
    lvlS.clear()
    tol   = LVL_TOL_ATR * nz(atr1)
    candN = array.new<int>()     // one candidate cluster per swing: touches, level, first touch
    candL = array.new<float>()
    candS = array.new<int>()
    for [i, p] in pivP
        n     = 0
        sum   = 0.0
        start = pivB.get(i)
        for [j, q] in pivP
            if math.abs(q - p) <= tol
                n     += 1
                sum   += q
                start := math.min(start, pivB.get(j))
        if n >= LVL_TOUCHES
            candN.push(n)
            candL.push(sum / n)
            candS.push(start)
    // Overlapping clusters describe the same level: keep the one with the most
    // touches, so the line sits where most swings agree.
    for k in candN.sort_indices(order.descending)
        lvl = candL.get(k)
        dup = false
        for x in lvlP
            if math.abs(x - lvl) <= tol
                dup := true
                break
        if not dup
            lvlP.push(lvl)
            lvlS.push(candS.get(k))

// Nearest major level above (dir = 1) or below (dir = -1) a price, and its first
// touch. Levels younger than the minimum age are skipped.
f_nearest(float ref, int dir) =>
    float best      = na
    int   bestStart = na
    for [i, l] in lvlP
        if (l - ref) * dir > 0 and bar_index - lvlS.get(i) >= LVL_MIN_AGE and (na(best) or (l - best) * dir < 0)
            best      := l
            bestStart := lvlS.get(i)
    [best, bestStart]

[resLvl, resStart] = f_nearest(close, 1)
[supLvl, supStart] = f_nearest(close, -1)

// ══════════════════════════════════════════════════════════════════════
// BREAKOUT LOGIC
// ══════════════════════════════════════════════════════════════════════

// Range width in ATRs: a tight base makes a more reliable breakout.
baseAtr = atr1 > 0 ? (hiLevel - loLevel) / atr1 : na
baseOk  = maxBaseAtr == 0 or na(baseAtr) or baseAtr <= maxBaseAtr

// Higher-timeframe trend from its last completed bar ([1] with lookahead on = no repaint).
[htfClose, htfEma] = request.security(syminfo.tickerid, HTF_TF, [close[1], ta.ema(close, HTF_LEN)[1]], lookahead=barmerge.lookahead_on)
htfActive = htfOn and timeframe.in_seconds(HTF_TF) > timeframe.in_seconds()
htfOkUp   = not htfActive or na(htfEma) or htfClose > htfEma
htfOkDn   = not htfActive or na(htfEma) or htfClose < htfEma

// Conviction of the bar: 1 = closed at its high, 0 = closed at its low.
clv     = high > low ? (close - low) / (high - low) : 0.5
clvOkUp = clv >= MIN_CLV
clvOkDn = clv <= 1.0 - MIN_CLV

// Regular breakout: first close beyond the lookback high/low plus the buffer.
regUp = close > hiLevel + buf and close[1] <= hiLevel[1] + buf[1]
regDn = close < loLevel - buf and close[1] >= loLevel[1] - buf[1]
// Major breakout: close beyond the nearest major level of the previous bar,
// which by construction was on the other side of the previous close.
majUp = not na(resLvl[1]) and close > resLvl[1] + buf
majDn = not na(supLvl[1]) and close < supLvl[1] - buf

brkUp = regUp or majUp
brkDn = regDn or majDn
lvlUp = majUp ? resLvl[1] : hiLevel     // the level this breakout cleared
lvlDn = majDn ? supLvl[1] : loLevel
startUp = majUp ? resStart[1] : na      // first touch of a major level, for the line
startDn = majDn ? supStart[1] : na

// Every check except volume; a hawk-red bullish breakout never confirms.
passUp = hawkGreen and clvOkUp and baseOk and htfOkUp
passDn = hawkRed and clvOkDn and baseOk and htfOkDn

confirmedUp = brkUp and passUp and volOk
confirmedDn = brkDn and passDn and volOk

// A breakout dot: a label, not a plotted shape, because plotted shapes make the
// hidden scale add padding that lifts the columns off the bottom of the chart.
// Labels do not follow the zoom by themselves, so the size is picked from the
// number of bars in view (the script recalculates when the view changes):
// larger when zoomed in close, smaller when zoomed out. The bar count is
// estimated from the visible time span, so on markets with weekends it runs a
// little high. The dot is a text bullet, not a circle label, because even the
// tiniest circle label is drawn at about 14 pixels; text takes a size in points.
visBars = (chart.right_visible_bar_time - chart.left_visible_bar_time) / (timeframe.in_seconds() * 1000)
dotPts  = visBars < 60 ? 22 : visBars < 200 ? 18 : 14
f_dot(int x, float y, color c, string tip) =>
    label.new(x, y, "●", color=color.new(color.black, 100), textcolor=c, style=label.style_none,
         size=dotPts, tooltip=tip)

// Hover text for a dot: what broke, when the level was first touched, how
// strong the volume was, and where the breakout would be invalidated.
f_tip(bool up, bool late, float lvl, int startBar, float volX) =>
    lv    = str.tostring(lvl, format.mintick)
    first = str.format_time(time[bar_index - startBar], timeframe.isintraday ? "yyyy-MM-dd HH:mm" : "yyyy-MM-dd", syminfo.timezone)
    head  = (up ? "Major bullish breakout" : "Major bearish breakdown") + (late ? " (late confirmation)" : "")
    vol   = late ? "Volume built up: " + str.tostring(volX, "#.#") + "x normal on average over " + str.tostring(VOL_WIN + 1) + " bars" : "Volume " + str.tostring(volX, "#.#") + "x normal on the breakout bar"
    head + "\nClosed " + (up ? "above" : "below") + " the level at " + lv + ", first touched " + first +
         "\n" + vol + "\nInvalidated by a close back " + (up ? "below " : "above ") + lv

// ── Sustained volume window: late confirmation ─────────────────────────
// A breakout that passed every check but its own volume is watched VOL_WIN
// more bars. It confirms late when the average relative volume over the
// window reaches volWinMult, and fails when a bar closes back inside.
var int   pendDir    = 0      // +1 bullish breakout pending, -1 bearish, 0 none
var int   pendBar    = na     // the breakout bar
var float pendLevel  = na     // the level price has to keep holding
var int   pendStart  = na     // first touch of a major level, na for a regular breakout
var float pendBarVol = na     // breakout bar volume, to place its dot
var float pendTop    = 0.0    // tallest volume in the window, to size the box
var float pendSum    = 0.0    // sum of relative volume over the window so far
var int   pendLeft   = 0

lateUp    = false
lateDn    = false
lateMajor = false
failUp    = false
failDn    = false

if pendDir != 0
    pendSum  += relVol
    pendTop  := math.max(pendTop, nz(volume))
    pendLeft -= 1
    if pendDir == 1 ? close < pendLevel : close > pendLevel
        failUp := pendDir == 1
        failDn := pendDir == -1
        pendDir := 0
    else if pendLeft == 0
        ok = pendSum / (VOL_WIN + 1) >= volWinMult
        lateUp := ok and pendDir == 1
        lateDn := ok and pendDir == -1
        failUp := not ok and pendDir == 1
        failDn := not ok and pendDir == -1
        if ok and not na(pendStart)   // only major breakouts are drawn
            c = pendDir == 1 ? color.lime : color.red
            lateMajor := true
            f_dot(pendBar, pendBarVol * 1.15, c, f_tip(pendDir == 1, true, pendLevel, pendStart, pendSum / (VOL_WIN + 1)))
            box.new(pendBar, pendTop * 1.05, bar_index, 0, border_color=c, bgcolor=color.new(c, 90))
            if iShowLvl
                line.new(pendStart, pendLevel, pendBar, pendLevel, color=c, width=2, force_overlay=true)
        pendDir := 0

startPendUp = VOL_WIN > 0 and pendDir == 0 and hasVol and brkUp and passUp and not volOk
startPendDn = VOL_WIN > 0 and pendDir == 0 and hasVol and brkDn and passDn and not volOk
if startPendUp or startPendDn
    pendDir    := startPendUp ? 1 : -1
    pendBar    := bar_index
    pendLevel  := startPendUp ? lvlUp : lvlDn
    pendStart  := startPendUp ? startUp : startDn
    pendBarVol := volume
    pendTop    := volume
    pendSum    := relVol
    pendLeft   := VOL_WIN

// No volume data = no verdict, not "suspect". A pending breakout is not suspect
// yet; it becomes suspect when its window fails.
suspectUp = (brkUp and hasVol and not confirmedUp and not startPendUp) or failUp
suspectDn = (brkDn and hasVol and not confirmedDn and not startPendDn) or failDn

// ══════════════════════════════════════════════════════════════════════
// VISUALS
// ══════════════════════════════════════════════════════════════════════

plot(volume, "Volume", color=hawkColor, style=plot.style_columns)
// Height anchor: Pine cannot set scale margins, so an invisible line at
// 100 / iHeightPct times the tallest column in view makes the hidden scale leave
// room above the columns. Like the built-in Volume, the scale follows the bars
// on screen: the running peak restarts at the left edge of the view, so its
// value on the last visible bar is the peak of the whole view.
inView = time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
var float visPeak = 0.0
if inView and not inView[1]
    visPeak := 0.0
if inView
    visPeak := math.max(visPeak, nz(volume))
plot(inView and iHeightPct < 100 ? visPeak * (100 - TOP_MARGIN) / iHeightPct : na, "Height anchor", color=color.new(color.gray, 100),
     display=display.pane, editable=false)
plot(anyVol ? hawkVolA : na, "HawkEye avg volume", color=color.new(color.yellow, 50))

if barstate.islast and not anyVol
    var noVolNote = table.new(position.bottom_right, 1, 1)   // created only on symbols that need it
    table.cell(noVolNote, 0, 0, "Volume breakout: " + syminfo.ticker + " has no volume data, so no breakout can be confirmed",
         text_color=chart.fg_color, text_size=size.small)

// Only major breakouts are drawn. Regular and suspect breakouts feed the alerts.
majNowUp = confirmedUp and majUp
majNowDn = confirmedDn and majDn

// Highlight the confirmed major breakout bar's own column.
plot(majNowUp or majNowDn ? volume : na, "Confirmed breakout column",
     color=majNowUp ? color.lime : color.red, style=plot.style_columns)

// Dots float just above the breakout bar's volume column. A late confirmation
// draws its dot on the breakout bar when its window completes (see above).
if majNowUp or majNowDn
    f_dot(bar_index, volume * 1.15, majNowUp ? color.lime : color.red,
         f_tip(majNowUp, false, majNowUp ? lvlUp : lvlDn, majNowUp ? startUp : startDn, relVol))

// Major level lines on the price chart.
if iShowLvl and confirmedUp and majUp
    line.new(startUp, lvlUp, bar_index, lvlUp, color=color.lime, width=2, force_overlay=true)
if iShowLvl and confirmedDn and majDn
    line.new(startDn, lvlDn, bar_index, lvlDn, color=color.red, width=2, force_overlay=true)

var line resLine = na
var line supLine = na
if barstate.islast and iShowLvl
    line.delete(resLine)
    line.delete(supLine)
    if not na(resLvl)
        resLine := line.new(resStart, resLvl, bar_index, resLvl, extend=extend.right,
             color=color.new(color.red, 20), style=line.style_dashed, force_overlay=true)
    if not na(supLvl)
        supLine := line.new(supStart, supLvl, bar_index, supLvl, extend=extend.right,
             color=color.new(color.green, 20), style=line.style_dashed, force_overlay=true)

// ══════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════
// Every signal is close-based, so alerts only fire on the confirmed bar close
// and never on a live bar that later reverts. A late confirmation alerts when
// its sustained volume window completes.

alertcondition((confirmedUp or lateUp) and barstate.isconfirmed, "Confirmed bullish breakout", "Bullish breakout confirmed by high relative volume, a green HawkEye bar and a strong close - institutional fuel behind it.")
alertcondition((confirmedDn or lateDn) and barstate.isconfirmed, "Confirmed bearish breakdown", "Bearish breakdown confirmed by high relative volume, a red HawkEye bar and a strong close - institutional fuel behind it.")
alertcondition(((confirmedUp and majUp) or (confirmedDn and majDn) or lateMajor) and barstate.isconfirmed, "Confirmed major breakout", "A major support or resistance level, touched several times, broke with volume confirmation.")
alertcondition((suspectUp or suspectDn) and barstate.isconfirmed, "Suspect breakout", "Breakout WITHOUT full confirmation (volume, HawkEye, close, range or trend) - possible false move, be careful.")
````
