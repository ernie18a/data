<!-- tradingview-pine-id: PUB;6b61ea0d215e487b94dbe06522c39b18 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Pattern_Atlas_Geometric

Source: https://www.tradingview.com/script/w7TbGKul-Pattern-Atlas-Geometric-AxeAlgo/

## Description

Pattern Atlas : Geometric Patterns [AxeAlgo]

WHAT THIS LIBRARY IS

This is a Pine Script v6 library of 17 classical chart pattern detectors — Head and Shoulders, Double/Triple Tops and Bottoms, triangles, wedges, flags, and the rest of the standard technical-analysis catalog built from swing highs and lows rather than single-candle shape. Unlike candlestick patterns, which read one to a handful of fixed bars, chart patterns span a variable, often large number of bars, so this library carries one small piece of state — a rolling history of confirmed swing pivots — that every pattern function reads from. Beyond that, the same philosophy as Library #1 applies: no plotting, no alerts, and no inputs in this script by design, since a library's job is to hand other scripts a clean, reusable, well-documented API, not to draw on a chart itself (Pine doesn't allow a library to plot anything anyway). If you're looking for a ready-to-use indicator built on top of this library, see the companion "Pattern Atlas : Geometric Indicator [AxeAlgo]" script, which imports every function here and turns it into on-chart signals, measured-move price targets, a live scanner table, and alerts.

Chart pattern analysis is one of the foundational tools of classical technical analysis, going back to Edwards and Magee's original work and refined since by researchers like Thomas Bulkowski, whose statistical studies of pattern behavior are the closest thing this field has to an industry-standard reference. The patterns in this library follow that standard catalog, so anyone who already knows what a Head and Shoulders top or an Ascending Triangle looks like will recognize exactly what each function is checking for.

WHY A LIBRARY INSTEAD OF ONE MONOLITHIC INDICATOR

Splitting detection logic out as an importable library means:
- Any Pine coder building their own strategy, indicator, or screener can pull in exactly the pattern checks they need without copy-pasting swing-pivot and trendline math into every new script.
- The detection logic is tested and maintained in one place. When a threshold gets refined, everything importing this library benefits from the update by bumping one version number.
- It keeps the math separate from presentation — how a pattern gets drawn, colored, or alerted on is a completely separate decision from whether the pattern is actually present, and different users want different presentations.

HOW TO IMPORT AND USE IT

Add this line near the top of your script (adjust the version number to whatever the current published version is):

import AxeAlgo/Pattern_Atlas_Geometric/1 as geo

Unlike Library #1, most of the functions here need a shared pivot history to work from. Call trackPivots() exactly once per bar, then pass its result into every detect*() function that needs it:

pivots = geo.trackPivots()
match = geo.detectDoubleTopBottom(pivots)
if match.found
    label.new(bar_index, high, match.patternName)

Four functions — detectSpike(), detectFlag(), detectPennant(), and detectIslandReversal() — read directly off recent price action instead of the shared pivot history, so they're called without a pivots argument: geo.detectSpike().

trackPivots() takes three optional parameters: leftBars and rightBars (how many less-extreme bars must surround a candidate swing point before it confirms as a pivot — higher values mean fewer, more significant pivots, at the cost of a longer confirmation lag), and maxPivots (how much pivot history to retain). All three have sensible defaults.

Every detect*() function returns the same structure, called ChartPatternMatch, so the calling pattern is identical no matter which of the 17 you use. It has nine fields:
- found — true if the pattern matched at the evaluated bar, false otherwise.
- patternName — the specific name of what matched (e.g. "Ascending Triangle"), na when not found.
- direction — "bullish" or "bearish".
- pivotBars — bar_index of each pivot the match was built from, in chronological order.
- pivotPrices — price of each pivot, in the same order as pivotBars.
- breakoutLevel — the support, resistance, or neckline level price broke through to confirm the pattern.
- necklineSlope — slope (price per bar) of the breakout line, na when the pattern's breakout level isn't a sloped line.
- barIndex — the bar_index the pattern completes (breaks out) on.
- description — a full sentence naming the pattern and the actual measured price levels that triggered it — genuinely useful for a tooltip or an alert message, not just a repeat of the pattern name.

Two additional exported functions turn that raw match into something more actionable, and both work on any ChartPatternMatch regardless of which detect*() function produced it:
- patternStrength(match) — a 0-100 score for how decisively the confirmation close broke through breakoutLevel, relative to the pattern's own price range. A breakout that clears the level by a meaningful fraction of the pattern's own size scores higher than a one-tick poke through it.
- patternTarget(match) — a classical measured-move price target, projecting the pattern's own height from the breakout point. Returns na for patterns without a reliable height to project from (V-Top/V-Bottom Spike, Island Reversal, Bump-and-Run Reversal).

Every detect*() function also exposes its own set of tunable threshold parameters — how flat a "flat top" has to be, how much two shoulders can differ and still count as equal, and so on — all with sensible defaults so you don't have to touch them unless you want to tighten or loosen a specific pattern's sensitivity for a particular instrument or timeframe.

THE 17 PATTERNS

Reversal patterns (7) — signal a potential change in the prevailing trend:

- Head and Shoulders / Inverse Head and Shoulders — detectHeadAndShoulders(). Three swing extremes with the middle one more extreme than the two roughly-equal outer ones, confirmed when price breaks the neckline connecting the two points between them.
- Double Top / Double Bottom — detectDoubleTopBottom(). Two roughly equal peaks (or troughs) with a retracement between them, confirmed when price breaks back through that retracement level.
- Triple Top / Triple Bottom — detectTripleTopBottom(). The same idea as a Double Top/Bottom with a third roughly-equal touch, confirmed on the break of the support or resistance formed between the touches.
- Rounding Top / Rounding Bottom — detectRoundingTopBottom(). A gradual, curved advance-and-rollover (or decline-and-recovery) between two similar edge levels. Approximate: read from three swing pivots rather than fitting a true curve.
- Diamond Top / Diamond Bottom — detectDiamondTopBottom(). Swing range that widens and then narrows again, confirmed on a break of the resulting support or resistance. Rare and approximate: read from three pivot pairs rather than a clean diamond outline.
- Broadening Formation — detectBroadeningTopBottom(). Diverging highs and lows forming an increasingly volatile range, confirmed on a break of either edge. Approximate: read from two pivot pairs rather than a hand-fitted diverging channel.
- V-Top / V-Bottom (Spike) — detectSpike(). A single sharp extreme with no rounding — a large move into the pivot and an equally large move away from it, both measured against the recent average bar range, within a handful of bars. Self-contained, no pivots argument needed.

Continuation patterns (8) — typically resolve in the direction of the move that preceded them:

- Ascending Triangle — detectTriangleAscending(). Flat resistance with rising support, confirmed on a break above resistance.
- Descending Triangle — detectTriangleDescending(). Flat support with falling resistance, confirmed on a break below support.
- Symmetrical Triangle — detectTriangleSymmetrical(). Converging highs and rising lows, confirmed (bullish or bearish) whichever side the price actually breaks.
- Rising Wedge / Falling Wedge — detectWedge(). Both trendlines slope the same direction and converge; breaks the opposite way from the slope, since the shared-direction move was already losing momentum.
- Bull Flag / Bear Flag — detectFlag(). A strong directional move (the pole), followed by a tight, roughly parallel pullback, confirmed on a break back out in the pole's direction. Self-contained, no pivots argument needed.
- Bull Pennant / Bear Pennant — detectPennant(). The same pole-and-consolidation structure as a Flag, but the consolidation narrows and converges rather than staying parallel. Self-contained, no pivots argument needed.
- Rectangle — detectRectangle(). Price boxed between flat support and flat resistance, confirmed on a break of either edge.
- Cup and Handle / Inverted Cup and Handle — detectCupAndHandle(). A rounded recovery (or decline) back to its starting rim, then a shallow pullback (the handle), confirmed on a break through the rim.

Structural / gap-based patterns (2):

- Bullish / Bearish Island Reversal — detectIslandReversal(). A bar (or small cluster) isolated by a gap on both sides, then abandoned by a gap the other way — an abrupt reversal. Self-contained, pure gap logic, no pivots argument needed.
- Bump-and-Run Reversal — detectBumpAndRun(). A lead-in trendline, then a "bump" phase accelerating well beyond it, then a "run" breaking back through the lead-in line. Approximate: the lead-in line is read from just two pivots rather than a hand-drawn trendline.

WHAT THIS LIBRARY DELIBERATELY DOES NOT DO

No plotting, no drawing, no alertcondition() calls, and no inputs — Pine doesn't allow any of those inside a library in the first place, since a library can never be added to a chart on its own. If you want signals, price targets, a scanner table, or alerts, import this library into your own script (or use the companion "Pattern Atlas : Chart Pattern Scanner [AxeAlgo]" indicator, which does exactly that) rather than expecting this script to render anything by itself.

This library also does not evaluate multi-timeframe data, volume, or broader market structure — it's swing-pivot and trendline geometry only, on purpose, so its behavior is easy to reason about and easy to reuse as one building block among several.

Four of the seventeen patterns are explicitly noted above as approximate: Rounding Top/Bottom, Diamond Top/Bottom, Broadening Formation, and Bump-and-Run Reversal are read from a small, fixed number of swing pivots rather than fitting a true curve or hand-drawn trendline to the data. They will not catch every textbook-perfect example of these shapes, and they may occasionally flag a looser approximation of one. Treat them as a starting point for further chart review, not a final word.

PART OF A LARGER SERIES

This is Library #2 in the AxeAlgo Pattern Atlas — a planned set of Pine libraries splitting pattern detection by the method actually used to find each kind of pattern: candlestick shape (Library #1, already published), classical chart/geometric patterns (this library), harmonic patterns (Fibonacci-ratio XABCD structures), and market-structure concepts (order blocks, liquidity, Wyckoff-style events). Each library is independent and useful on its own; together they're meant to cover technical pattern analysis without forcing unrelated detection methods into the same function.

A NOTE ON REPAINTING

trackPivots() only confirms a swing pivot once rightBars bars have passed since it happened — the same confirmation lag ta.pivothigh()/ta.pivotlow() use, just written out as plain comparisons so it works safely inside a library's exported functions. That means a pivot never moves or disappears once confirmed; it just takes rightBars bars to become known, which is a normal and unavoidable part of swing-pivot detection, not a defect in this library. On the currently-forming bar, a pattern's found status can still change tick to tick as that bar's own high, low, and close move — that's inherent to reading live price action. If you're building persisted signals, drawings, alerts, or price targets on top of these functions (rather than a live "what's happening right now" readout), gate your usage on barstate.isconfirmed so a signal only fires once the bar it describes has actually closed, exactly like the companion scanner indicator does.

DISCLAIMER

This library is a technical analysis tool for identifying classical chart pattern shapes in historical and live price data. It does not predict future price movement, and a detected pattern — including any projected price target — is a description of past price action, not a signal guaranteed to repeat. Nothing in this script constitutes financial advice. Always combine pattern recognition with your own risk management and broader analysis before making any trading decision.

---

## Source Code

````pine
//@version=6
// © AxeAlgo

// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// For commercial use licensing, contact https://www.tradingview.com/u/AxeAlgo/

// AxeAlgo Pattern Atlas — Library 2: Chart / Geometric pattern detection.
// Unlike Library 1 (Candlestick), these patterns span a variable number of
// bars built from swing pivots, not a fixed small window. trackPivots()
// carries the only state in this library (a rolling pivot history) — call
// it once per bar and pass its result into every detect*() function below,
// which are themselves pure and stateless, same "detection only" philosophy
// as Library 1.
library("Pattern_Atlas_Geometric", overlay = true)

// @type A rolling history of confirmed swing pivots, produced by trackPivots().
// @field highBars bar_index of each confirmed pivot high, oldest first.
// @field highPrices price of each confirmed pivot high, same order as highBars.
// @field lowBars bar_index of each confirmed pivot low, oldest first.
// @field lowPrices price of each confirmed pivot low, same order as lowBars.
export type PivotSet
    array<int>   highBars
    array<float> highPrices
    array<int>   lowBars
    array<float> lowPrices

// @type Result returned by every detect*() function in this library.
// @field found true if the pattern matched at the evaluated bar.
// @field patternName Name of the matched pattern, na when not found.
// @field direction "bullish", "bearish", or "bilateral".
// @field pivotBars bar_index of each pivot the match was built from, chronological order.
// @field pivotPrices price of each pivot, same order as pivotBars.
// @field breakoutLevel The support/resistance/neckline level price broke through to confirm the pattern.
// @field necklineSlope Slope (price per bar) of the breakout line, na when the pattern's breakout level isn't a sloped line.
// @field barIndex bar_index the pattern completes (breaks out) on.
// @field description Plain-language explanation of the pattern and the measured levels that triggered it, na when not found.
export type ChartPatternMatch
    bool         found         = false
    string       patternName   = na
    string       direction     = na
    array<int>   pivotBars     = na
    array<float> pivotPrices   = na
    float        breakoutLevel = na
    float        necklineSlope = na
    int          barIndex      = na
    string       description   = na

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------
f_none() => ChartPatternMatch.new(false, na, na, na, na, na, na, na, na)
f_roughlyEqual(_a, _b, _tolPct) => math.abs(_a - _b) <= _tolPct * math.max(math.abs(_a), math.abs(_b))
f_slope(_bar1, _price1, _bar2, _price2) => _bar2 != _bar1 ? (_price2 - _price1) / (_bar2 - _bar1) : 0.0
f_lineAt(_bar1, _price1, _bar2, _price2, _atBar) => _price1 + f_slope(_bar1, _price1, _bar2, _price2) * (_atBar - _bar1)

// True when time range [_aMin, _aMax] intersects [_bMin, _bMax]. Used to
// reject matches that combine a high-pivot pair and a low-pivot pair (each
// tracked independently in PivotSet) that don't actually occupy the same
// stretch of chart — e.g. a "flat top" from 200 bars ago paired with "rising
// lows" from 5 bars ago would otherwise pass a purely numeric check even
// though they never coexisted as one visible consolidation.
f_overlaps(_aMin, _aMax, _bMin, _bMax) => _aMin <= _bMax and _bMin <= _aMax

// Sorts pivotBars/pivotPrices into true chronological order before a match
// is returned. A handful of detectors below build their pivot list from two
// independently-tracked sets (highs and lows), so the order they're pulled
// in isn't necessarily the order they occurred in — this keeps the
// ChartPatternMatch.pivotBars contract ("chronological order") honest.
f_sortPivots(_bars, _prices) =>
    _n = array.size(_bars)
    _sb = array.copy(_bars)
    _sp = array.copy(_prices)
    if _n >= 2
        for i = 0 to _n - 2
            for j = 0 to _n - 2 - i
                if array.get(_sb, j) > array.get(_sb, j + 1)
                    _tb = array.get(_sb, j)
                    _tp = array.get(_sp, j)
                    array.set(_sb, j, array.get(_sb, j + 1))
                    array.set(_sp, j, array.get(_sp, j + 1))
                    array.set(_sb, j + 1, _tb)
                    array.set(_sp, j + 1, _tp)
    [_sb, _sp]

// Manual rolling max/min/average over a bar window — used instead of
// ta.highest()/ta.lowest()/ta.atr() so every helper here is plain
// comparisons and arithmetic, safe to call from anywhere including the
// exported pattern functions below, with no dependency on how Pine treats
// ta.* functions inside a library's function bodies.
f_highestOver(_lookback) =>
    _m = high[0]
    for i = 1 to _lookback - 1
        _m := math.max(_m, high[i])
    _m

f_lowestOver(_lookback) =>
    _m = low[0]
    for i = 1 to _lookback - 1
        _m := math.min(_m, low[i])
    _m

f_avgRangeOver(_lookback) =>
    _sum = 0.0
    for i = 0 to _lookback - 1
        _sum += high[i] - low[i]
    _sum / _lookback

// A bar at offset `_right` is a pivot high/low only if every bar within
// `_left` bars before it and `_right` bars after it is strictly less
// extreme — the same definition ta.pivothigh()/ta.pivotlow() use, just
// written out as plain comparisons.
f_isPivotHigh(_left, _right) =>
    _center = high[_right]
    _ok = true
    for i = 1 to _left
        if high[_right + i] >= _center
            _ok := false
    for i = 0 to _right - 1
        if high[i] >= _center
            _ok := false
    _ok

f_isPivotLow(_left, _right) =>
    _center = low[_right]
    _ok = true
    for i = 1 to _left
        if low[_right + i] <= _center
            _ok := false
    for i = 0 to _right - 1
        if low[i] <= _center
            _ok := false
    _ok

// Pulls the Nth-most-recent pivot from a PivotSet (1 = most recent, 2 =
// the one before that, ...). Returns -1 / na when fewer than N pivots of
// that type exist yet, which every pattern function below checks for
// before using the result.
f_hLast(_ps, _n) => array.size(_ps.highBars) >= _n ? array.get(_ps.highBars, array.size(_ps.highBars) - _n) : -1
f_hLastP(_ps, _n) => array.size(_ps.highPrices) >= _n ? array.get(_ps.highPrices, array.size(_ps.highPrices) - _n) : float(na)
f_lLast(_ps, _n) => array.size(_ps.lowBars) >= _n ? array.get(_ps.lowBars, array.size(_ps.lowBars) - _n) : -1
f_lLastP(_ps, _n) => array.size(_ps.lowPrices) >= _n ? array.get(_ps.lowPrices, array.size(_ps.lowPrices) - _n) : float(na)

// @function Tracks confirmed pivot highs/lows into a rolling history. This is the only stateful function in the library — call it exactly once per bar in your script and pass its result into every detect*() function below, which are themselves pure and read-only.
// @param leftBars Bars to the left of a candidate pivot that must be less extreme, for it to confirm as a pivot.
// @param rightBars Bars to the right of a candidate pivot that must be less extreme. Also the confirmation lag — a pivot is only known `rightBars` bars after it actually happened.
// @param maxPivots How many recent pivot highs and pivot lows to keep in history (oldest dropped first).
// @returns PivotSet
export trackPivots(int leftBars = 5, int rightBars = 5, int maxPivots = 20) =>
    var array<int> _highBars = array.new<int>()
    var array<float> _highPrices = array.new<float>()
    var array<int> _lowBars = array.new<int>()
    var array<float> _lowPrices = array.new<float>()

    if bar_index >= leftBars + rightBars
        if f_isPivotHigh(leftBars, rightBars)
            array.push(_highBars, bar_index - rightBars)
            array.push(_highPrices, high[rightBars])
            if array.size(_highBars) > maxPivots
                array.shift(_highBars)
                array.shift(_highPrices)
        if f_isPivotLow(leftBars, rightBars)
            array.push(_lowBars, bar_index - rightBars)
            array.push(_lowPrices, low[rightBars])
            if array.size(_lowBars) > maxPivots
                array.shift(_lowBars)
                array.shift(_lowPrices)

    PivotSet.new(_highBars, _highPrices, _lowBars, _lowPrices)

// ---------------------------------------------------------------------------
// Reversal patterns
// ---------------------------------------------------------------------------

// @function Head and Shoulders / Inverse Head and Shoulders — three peaks (or troughs) with the middle one more extreme, breaking the neckline connecting the two points between them.
// @param pivots Result of trackPivots(), called once per bar in your script.
// @param shoulderTolerance Max difference between the two shoulders, as a fraction of price.
// @param minHeadPct Min amount the head must exceed both shoulders by, as a fraction of price.
// @returns ChartPatternMatch
export detectHeadAndShoulders(PivotSet pivots, float shoulderTolerance = 0.03, float minHeadPct = 0.01) =>
    _s1b = f_hLast(pivots, 3)
    _s1p = f_hLastP(pivots, 3)
    _hdb = f_hLast(pivots, 2)
    _hdp = f_hLastP(pivots, 2)
    _s2b = f_hLast(pivots, 1)
    _s2p = f_hLastP(pivots, 1)
    _n1b = f_lLast(pivots, 2)
    _n1p = f_lLastP(pivots, 2)
    _n2b = f_lLast(pivots, 1)
    _n2p = f_lLastP(pivots, 1)
    _haveTop = _s1b >= 0 and _hdb >= 0 and _s2b >= 0 and _n1b >= 0 and _n2b >= 0
    _orderTop = _haveTop and _s1b < _n1b and _n1b < _hdb and _hdb < _n2b and _n2b < _s2b
    _shouldersEq = _haveTop and f_roughlyEqual(_s1p, _s2p, shoulderTolerance)
    _headHigher = _haveTop and _hdp > _s1p * (1 + minHeadPct) and _hdp > _s2p * (1 + minHeadPct)
    _necklineTop = _haveTop ? f_lineAt(_n1b, _n1p, _n2b, _n2p, bar_index) : na
    _topFound = _haveTop and _orderTop and _shouldersEq and _headHigher and close < _necklineTop

    _is1b = f_lLast(pivots, 3)
    _is1p = f_lLastP(pivots, 3)
    _ihdb = f_lLast(pivots, 2)
    _ihdp = f_lLastP(pivots, 2)
    _is2b = f_lLast(pivots, 1)
    _is2p = f_lLastP(pivots, 1)
    _in1b = f_hLast(pivots, 2)
    _in1p = f_hLastP(pivots, 2)
    _in2b = f_hLast(pivots, 1)
    _in2p = f_hLastP(pivots, 1)
    _haveBot = _is1b >= 0 and _ihdb >= 0 and _is2b >= 0 and _in1b >= 0 and _in2b >= 0
    _orderBot = _haveBot and _is1b < _in1b and _in1b < _ihdb and _ihdb < _in2b and _in2b < _is2b
    _shouldersEqB = _haveBot and f_roughlyEqual(_is1p, _is2p, shoulderTolerance)
    _headLower = _haveBot and _ihdp < _is1p * (1 - minHeadPct) and _ihdp < _is2p * (1 - minHeadPct)
    _necklineBot = _haveBot ? f_lineAt(_in1b, _in1p, _in2b, _in2p, bar_index) : na
    _botFound = _haveBot and _orderBot and _shouldersEqB and _headLower and close > _necklineBot

    if _topFound
        ChartPatternMatch.new(true, "Head and Shoulders Top", "bearish", array.from(_s1b, _n1b, _hdb, _n2b, _s2b), array.from(_s1p, _n1p, _hdp, _n2p, _s2p), _necklineTop, f_slope(_n1b, _n1p, _n2b, _n2p), bar_index, "Head and Shoulders Top: two roughly equal shoulders (" + str.tostring(_s1p, format.mintick) + " / " + str.tostring(_s2p, format.mintick) + ") around a higher head (" + str.tostring(_hdp, format.mintick) + "), closing at " + str.tostring(close, format.mintick) + " below the neckline (" + str.tostring(_necklineTop, format.mintick) + ") - classic reversal breakdown.")
    else if _botFound
        ChartPatternMatch.new(true, "Inverse Head and Shoulders", "bullish", array.from(_is1b, _in1b, _ihdb, _in2b, _is2b), array.from(_is1p, _in1p, _ihdp, _in2p, _is2p), _necklineBot, f_slope(_in1b, _in1p, _in2b, _in2p), bar_index, "Inverse Head and Shoulders: two roughly equal shoulders (" + str.tostring(_is1p, format.mintick) + " / " + str.tostring(_is2p, format.mintick) + ") around a lower head (" + str.tostring(_ihdp, format.mintick) + "), closing at " + str.tostring(close, format.mintick) + " above the neckline (" + str.tostring(_necklineBot, format.mintick) + ") - classic reversal breakout.")
    else
        f_none()

// @function Double Top / Double Bottom — two roughly equal extremes with a retracement between them, breaking through that retracement.
// @param pivots Result of trackPivots(), called once per bar in your script.
// @param levelTolerance Max difference between the two peaks/troughs, as a fraction of price.
// @param minDepthPct Min retracement depth between the two peaks/troughs, as a fraction of price.
// @returns ChartPatternMatch
export detectDoubleTopBottom(PivotSet pivots, float levelTolerance = 0.02, float minDepthPct = 0.02) =>
    _h1b = f_hLast(pivots, 2)
    _h1p = f_hLastP(pivots, 2)
    _h2b = f_hLast(pivots, 1)
    _h2p = f_hLastP(pivots, 1)
    _dipb = f_lLast(pivots, 1)
    _dipp = f_lLastP(pivots, 1)
    _haveTop = _h1b >= 0 and _h2b >= 0 and _dipb >= 0 and _h1b < _dipb and _dipb < _h2b
    _levelsEq = _haveTop and f_roughlyEqual(_h1p, _h2p, levelTolerance)
    _deepEnough = _haveTop and (_h1p - _dipp) >= minDepthPct * _h1p
    _topFound = _haveTop and _levelsEq and _deepEnough and close < _dipp

    _l1b = f_lLast(pivots, 2)
    _l1p = f_lLastP(pivots, 2)
    _l2b = f_lLast(pivots, 1)
    _l2p = f_lLastP(pivots, 1)
    _bumpb = f_hLast(pivots, 1)
    _bumpp = f_hLastP(pivots, 1)
    _haveBot = _l1b >= 0 and _l2b >= 0 and _bumpb >= 0 and _l1b < _bumpb and _bumpb < _l2b
    _levelsEqB = _haveBot and f_roughlyEqual(_l1p, _l2p, levelTolerance)
    _deepEnoughB = _haveBot and (_bumpp - _l1p) >= minDepthPct * _l1p
    _botFound = _haveBot and _levelsEqB and _deepEnoughB and close > _bumpp

    if _topFound
        ChartPatternMatch.new(true, "Double Top", "bearish", array.from(_h1b, _dipb, _h2b), array.from(_h1p, _dipp, _h2p), _dipp, na, bar_index, "Double Top: two peaks near " + str.tostring(_h1p, format.mintick) + " and " + str.tostring(_h2p, format.mintick) + " with a dip to " + str.tostring(_dipp, format.mintick) + " between them, now closing at " + str.tostring(close, format.mintick) + " below that dip - resistance held twice, support gave way.")
    else if _botFound
        ChartPatternMatch.new(true, "Double Bottom", "bullish", array.from(_l1b, _bumpb, _l2b), array.from(_l1p, _bumpp, _l2p), _bumpp, na, bar_index, "Double Bottom: two troughs near " + str.tostring(_l1p, format.mintick) + " and " + str.tostring(_l2p, format.mintick) + " with a bounce to " + str.tostring(_bumpp, format.mintick) + " between them, now closing at " + str.tostring(close, format.mintick) + " above that bounce - support held twice, resistance gave way.")
    else
        f_none()

// @function Triple Top / Triple Bottom — three roughly equal extremes at one level, breaking through the support/resistance formed between them.
// @param pivots Result of trackPivots(), called once per bar in your script.
// @param levelTolerance Max difference between the three peaks/troughs, as a fraction of price.
// @returns ChartPatternMatch
export detectTripleTopBottom(PivotSet pivots, float levelTolerance = 0.02) =>
    _h1b = f_hLast(pivots, 3)
    _h1p = f_hLastP(pivots, 3)
    _h2b = f_hLast(pivots, 2)
    _h2p = f_hLastP(pivots, 2)
    _h3b = f_hLast(pivots, 1)
    _h3p = f_hLastP(pivots, 1)
    _d1b = f_lLast(pivots, 2)
    _d1p = f_lLastP(pivots, 2)
    _d2b = f_lLast(pivots, 1)
    _d2p = f_lLastP(pivots, 1)
    _haveTop = _h1b >= 0 and _h2b >= 0 and _h3b >= 0 and _d1b >= 0 and _d2b >= 0 and _h1b < _d1b and _d1b < _h2b and _h2b < _d2b and _d2b < _h3b
    _levelsEq = _haveTop and f_roughlyEqual(_h1p, _h2p, levelTolerance) and f_roughlyEqual(_h2p, _h3p, levelTolerance)
    _supportLevel = _haveTop ? math.min(_d1p, _d2p) : na
    _topFound = _haveTop and _levelsEq and close < _supportLevel

    _l1b = f_lLast(pivots, 3)
    _l1p = f_lLastP(pivots, 3)
    _l2b = f_lLast(pivots, 2)
    _l2p = f_lLastP(pivots, 2)
    _l3b = f_lLast(pivots, 1)
    _l3p = f_lLastP(pivots, 1)
    _u1b = f_hLast(pivots, 2)
    _u1p = f_hLastP(pivots, 2)
    _u2b = f_hLast(pivots, 1)
    _u2p = f_hLastP(pivots, 1)
    _haveBot = _l1b >= 0 and _l2b >= 0 and _l3b >= 0 and _u1b >= 0 and _u2b >= 0 and _l1b < _u1b and _u1b < _l2b and _l2b < _u2b and _u2b < _l3b
    _levelsEqB = _haveBot and f_roughlyEqual(_l1p, _l2p, levelTolerance) and f_roughlyEqual(_l2p, _l3p, levelTolerance)
    _resistLevel = _haveBot ? math.max(_u1p, _u2p) : na
    _botFound = _haveBot and _levelsEqB and close > _resistLevel

    if _topFound
        ChartPatternMatch.new(true, "Triple Top", "bearish", array.from(_h1b, _d1b, _h2b, _d2b, _h3b), array.from(_h1p, _d1p, _h2p, _d2p, _h3p), _supportLevel, na, bar_index, "Triple Top: three peaks all near " + str.tostring(_h1p, format.mintick) + " failing to break higher, now closing at " + str.tostring(close, format.mintick) + " below the support formed between them (" + str.tostring(_supportLevel, format.mintick) + ").")
    else if _botFound
        ChartPatternMatch.new(true, "Triple Bottom", "bullish", array.from(_l1b, _u1b, _l2b, _u2b, _l3b), array.from(_l1p, _u1p, _l2p, _u2p, _l3p), _resistLevel, na, bar_index, "Triple Bottom: three troughs all near " + str.tostring(_l1p, format.mintick) + " failing to break lower, now closing at " + str.tostring(close, format.mintick) + " above the resistance formed between them (" + str.tostring(_resistLevel, format.mintick) + ").")
    else
        f_none()

// @function Rounding Top / Rounding Bottom (Saucer) — a gradual curved reversal between two similar edge levels. Approximate by nature: read from discrete pivots rather than a true curve.
// @param pivots Result of trackPivots(), called once per bar in your script.
// @param edgeTolerance Max difference between the two edge levels, as a fraction of price.
// @param minArcPct Min height of the arc above/below both edges, as a fraction of price.
// @returns ChartPatternMatch
export detectRoundingTopBottom(PivotSet pivots, float edgeTolerance = 0.05, float minArcPct = 0.015) =>
    _l1b = f_hLast(pivots, 3)
    _l1p = f_hLastP(pivots, 3)
    _mb = f_hLast(pivots, 2)
    _mp = f_hLastP(pivots, 2)
    _r1b = f_hLast(pivots, 1)
    _r1p = f_hLastP(pivots, 1)
    _haveTop = _l1b >= 0 and _mb >= 0 and _r1b >= 0
    _edgesClose = _haveTop and f_roughlyEqual(_l1p, _r1p, edgeTolerance)
    _archedUp = _haveTop and _mp > _l1p * (1 + minArcPct) and _mp > _r1p * (1 + minArcPct)
    _topFound = _haveTop and _edgesClose and _archedUp and close < math.min(_l1p, _r1p)

    _ll1b = f_lLast(pivots, 3)
    _ll1p = f_lLastP(pivots, 3)
    _lmb = f_lLast(pivots, 2)
    _lmp = f_lLastP(pivots, 2)
    _lr1b = f_lLast(pivots, 1)
    _lr1p = f_lLastP(pivots, 1)
    _haveBot = _ll1b >= 0 and _lmb >= 0 and _lr1b >= 0
    _edgesCloseB = _haveBot and f_roughlyEqual(_ll1p, _lr1p, edgeTolerance)
    _archedDown = _haveBot and _lmp < _ll1p * (1 - minArcPct) and _lmp < _lr1p * (1 - minArcPct)
    _botFound = _haveBot and _edgesCloseB and _archedDown and close > math.max(_ll1p, _lr1p)

    if _topFound
        ChartPatternMatch.new(true, "Rounding Top", "bearish", array.from(_l1b, _mb, _r1b), array.from(_l1p, _mp, _r1p), math.min(_l1p, _r1p), na, bar_index, "Rounding Top: a gradual curved advance and rollover between two similar edge levels (" + str.tostring(_l1p, format.mintick) + " / " + str.tostring(_r1p, format.mintick) + "), now closing at " + str.tostring(close, format.mintick) + " below both - a saucer-shaped reversal.")
    else if _botFound
        ChartPatternMatch.new(true, "Rounding Bottom", "bullish", array.from(_ll1b, _lmb, _lr1b), array.from(_ll1p, _lmp, _lr1p), math.max(_ll1p, _lr1p), na, bar_index, "Rounding Bottom: a gradual curved decline and recovery between two similar edge levels (" + str.tostring(_ll1p, format.mintick) + " / " + str.tostring(_lr1p, format.mintick) + "), now closing at " + str.tostring(close, format.mintick) + " above both - a saucer-shaped reversal.")
    else
        f_none()

// @function Diamond Top / Diamond Bottom — swing range widens then narrows. Rare and approximate: read from three pivot pairs rather than a clean diamond outline.
// @param pivots Result of trackPivots(), called once per bar in your script.
// @param minExpansionPct Min amount the middle pivots must exceed the outer ones by, as a fraction of price.
// @returns ChartPatternMatch
export detectDiamondTopBottom(PivotSet pivots, float minExpansionPct = 0.01) =>
    _h3b = f_hLast(pivots, 3)
    _h3p = f_hLastP(pivots, 3)
    _h2b = f_hLast(pivots, 2)
    _h2p = f_hLastP(pivots, 2)
    _h1b = f_hLast(pivots, 1)
    _h1p = f_hLastP(pivots, 1)
    _l3b = f_lLast(pivots, 3)
    _l3p = f_lLastP(pivots, 3)
    _l2b = f_lLast(pivots, 2)
    _l2p = f_lLastP(pivots, 2)
    _l1b = f_lLast(pivots, 1)
    _l1p = f_lLastP(pivots, 1)
    _have = _h3b >= 0 and _h2b >= 0 and _h1b >= 0 and _l3b >= 0 and _l2b >= 0 and _l1b >= 0
    // Highs and lows are tracked in separate arrays with independent timing,
    // so "3 highs + 3 lows all exist" alone doesn't mean they occupy the same
    // stretch of chart — require their time ranges to actually overlap.
    _overlap = _have and f_overlaps(math.min(_h3b, _h1b), math.max(_h3b, _h1b), math.min(_l3b, _l1b), math.max(_l3b, _l1b))
    _widenedUp = _have and _h2p > _h3p * (1 + minExpansionPct) and _h2p > _h1p * (1 + minExpansionPct)
    _widenedDown = _have and _l2p < _l3p * (1 - minExpansionPct) and _l2p < _l1p * (1 - minExpansionPct)
    _isDiamond = _have and _overlap and _widenedUp and _widenedDown
    _support = _have ? math.min(_l1p, _l2p) : na
    _resist = _have ? math.max(_h1p, _h2p) : na
    _bearBreak = _isDiamond and close < _support
    _bullBreak = _isDiamond and close > _resist
    [_pivBars, _pivPrices] = f_sortPivots(array.from(_h3b, _l3b, _h2b, _l2b, _h1b, _l1b), array.from(_h3p, _l3p, _h2p, _l2p, _h1p, _l1p))

    if _bearBreak
        ChartPatternMatch.new(true, "Diamond Top", "bearish", _pivBars, _pivPrices, _support, na, bar_index, "Diamond Top: swing range widened then narrowed (widest point " + str.tostring(_h2p, format.mintick) + " / " + str.tostring(_l2p, format.mintick) + "), now closing at " + str.tostring(close, format.mintick) + " below support.")
    else if _bullBreak
        ChartPatternMatch.new(true, "Diamond Bottom", "bullish", _pivBars, _pivPrices, _resist, na, bar_index, "Diamond Bottom: swing range widened then narrowed (widest point " + str.tostring(_h2p, format.mintick) + " / " + str.tostring(_l2p, format.mintick) + "), now closing at " + str.tostring(close, format.mintick) + " above resistance.")
    else
        f_none()

// @function Broadening Formation (Megaphone) — diverging highs and lows, an increasingly volatile range, breaking out either edge.
// @param pivots Result of trackPivots(), called once per bar in your script.
// @param minDivergePct Min amount the most recent high/low must exceed the prior one by, as a fraction of price.
// @returns ChartPatternMatch
export detectBroadeningTopBottom(PivotSet pivots, float minDivergePct = 0.01) =>
    _h2b = f_hLast(pivots, 2)
    _h2p = f_hLastP(pivots, 2)
    _h1b = f_hLast(pivots, 1)
    _h1p = f_hLastP(pivots, 1)
    _l2b = f_lLast(pivots, 2)
    _l2p = f_lLastP(pivots, 2)
    _l1b = f_lLast(pivots, 1)
    _l1p = f_lLastP(pivots, 1)
    _have = _h2b >= 0 and _h1b >= 0 and _l2b >= 0 and _l1b >= 0
    _overlap = _have and f_overlaps(_h2b, _h1b, _l2b, _l1b)
    _highsRising = _have and _h1p > _h2p * (1 + minDivergePct)
    _lowsFalling = _have and _l1p < _l2p * (1 - minDivergePct)
    _isBroadening = _have and _overlap and _highsRising and _lowsFalling
    _bullBreak = _isBroadening and close > _h1p
    _bearBreak = _isBroadening and close < _l1p
    [_pivBars, _pivPrices] = f_sortPivots(array.from(_h2b, _l2b, _h1b, _l1b), array.from(_h2p, _l2p, _h1p, _l1p))

    if _bullBreak
        ChartPatternMatch.new(true, "Broadening Formation", "bullish", _pivBars, _pivPrices, _h1p, f_slope(_h2b, _h2p, _h1b, _h1p), bar_index, "Broadening Formation: highs rising (" + str.tostring(_h2p, format.mintick) + " -> " + str.tostring(_h1p, format.mintick) + ") and lows falling (" + str.tostring(_l2p, format.mintick) + " -> " + str.tostring(_l1p, format.mintick) + ") - a widening, increasingly volatile range, now breaking above its upper edge.")
    else if _bearBreak
        ChartPatternMatch.new(true, "Broadening Formation", "bearish", _pivBars, _pivPrices, _l1p, f_slope(_l2b, _l2p, _l1b, _l1p), bar_index, "Broadening Formation: highs rising (" + str.tostring(_h2p, format.mintick) + " -> " + str.tostring(_h1p, format.mintick) + ") and lows falling (" + str.tostring(_l2p, format.mintick) + " -> " + str.tostring(_l1p, format.mintick) + ") - a widening, increasingly volatile range, now breaking below its lower edge.")
    else
        f_none()

// @function V-Top / V-Bottom (Spike) — a single sharp extreme with no rounding: a large move into the pivot and an equally large move away from it, within a handful of bars. Self-contained — doesn't take a PivotSet, since it needs the exact bars around the spike rather than the shared swing history.
// @param leftBars Bars checked to the left of the candidate spike.
// @param rightBars Bars checked to the right of the candidate spike, and the confirmation lag.
// @param atrLength Bars used to measure the average bar range, as the "how sharp is sharp" yardstick.
// @param minSpikeAtrMult How many average bar ranges each leg (into and out of the spike) must measure at minimum.
// @returns ChartPatternMatch
export detectSpike(int leftBars = 3, int rightBars = 3, int atrLength = 14, float minSpikeAtrMult = 2.0) =>
    _avgRng = f_avgRangeOver(atrLength)
    _topShape = f_isPivotHigh(leftBars, rightBars)
    _botShape = f_isPivotLow(leftBars, rightBars)
    _pivBar = bar_index - rightBars
    _hiPivot = high[rightBars]
    _loPivot = low[rightBars]
    _moveIntoHigh = _hiPivot - math.min(low[rightBars + leftBars], low[rightBars])
    _moveOutOfHigh = _hiPivot - low[0]
    _topSpike = _topShape and _moveIntoHigh >= minSpikeAtrMult * _avgRng and _moveOutOfHigh >= minSpikeAtrMult * _avgRng
    _moveIntoLow = math.max(high[rightBars + leftBars], high[rightBars]) - _loPivot
    _moveOutOfLow = high[0] - _loPivot
    _botSpike = _botShape and _moveIntoLow >= minSpikeAtrMult * _avgRng and _moveOutOfLow >= minSpikeAtrMult * _avgRng

    if _topSpike
        ChartPatternMatch.new(true, "V-Top (Spike Top)", "bearish", array.from(_pivBar), array.from(_hiPivot), na, na, bar_index, "Spike Top: price shot up to " + str.tostring(_hiPivot, format.mintick) + " and reversed just as sharply within a handful of bars, no rounding - both legs measuring well beyond the recent average bar range.")
    else if _botSpike
        ChartPatternMatch.new(true, "V-Bottom (Spike Bottom)", "bullish", array.from(_pivBar), array.from(_loPivot), na, na, bar_index, "Spike Bottom: price plunged to " + str.tostring(_loPivot, format.mintick) + " and reversed just as sharply within a handful of bars, no rounding - both legs measuring well beyond the recent average bar range.")
    else
        f_none()

// ---------------------------------------------------------------------------
// Continuation patterns
// ---------------------------------------------------------------------------

// @function Ascending Triangle — flat resistance with rising support, breaking out above resistance.
// @param pivots Result of trackPivots(), called once per bar in your script.
// @param flatTolerance Max difference between the two resistance highs, as a fraction of price.
// @param minRisePct Min amount the more recent low must exceed the prior one by, as a fraction of price.
// @returns ChartPatternMatch
export detectTriangleAscending(PivotSet pivots, float flatTolerance = 0.015, float minRisePct = 0.01) =>
    _h2b = f_hLast(pivots, 2)
    _h2p = f_hLastP(pivots, 2)
    _h1b = f_hLast(pivots, 1)
    _h1p = f_hLastP(pivots, 1)
    _l2b = f_lLast(pivots, 2)
    _l2p = f_lLastP(pivots, 2)
    _l1b = f_lLast(pivots, 1)
    _l1p = f_lLastP(pivots, 1)
    _have = _h2b >= 0 and _h1b >= 0 and _l2b >= 0 and _l1b >= 0
    _overlap = _have and f_overlaps(_h2b, _h1b, _l2b, _l1b)
    _flatTop = _have and f_roughlyEqual(_h2p, _h1p, flatTolerance)
    _risingLows = _have and _l1p > _l2p * (1 + minRisePct)
    _isPattern = _have and _overlap and _flatTop and _risingLows
    _resist = _have ? math.max(_h1p, _h2p) : na
    _found = _isPattern and close > _resist
    [_pivBars, _pivPrices] = f_sortPivots(array.from(_l2b, _h2b, _l1b, _h1b), array.from(_l2p, _h2p, _l1p, _h1p))
    _found ? ChartPatternMatch.new(true, "Ascending Triangle", "bullish", _pivBars, _pivPrices, _resist, f_slope(_l2b, _l2p, _l1b, _l1p), bar_index, "Ascending Triangle: flat resistance near " + str.tostring(_resist, format.mintick) + " with rising support (" + str.tostring(_l2p, format.mintick) + " -> " + str.tostring(_l1p, format.mintick) + "), now closing above resistance - continuation breakout.") : f_none()

// @function Descending Triangle — flat support with falling resistance, breaking down below support.
// @param pivots Result of trackPivots(), called once per bar in your script.
// @param flatTolerance Max difference between the two support lows, as a fraction of price.
// @param minFallPct Min amount the more recent high must fall below the prior one by, as a fraction of price.
// @returns ChartPatternMatch
export detectTriangleDescending(PivotSet pivots, float flatTolerance = 0.015, float minFallPct = 0.01) =>
    _l2b = f_lLast(pivots, 2)
    _l2p = f_lLastP(pivots, 2)
    _l1b = f_lLast(pivots, 1)
    _l1p = f_lLastP(pivots, 1)
    _h2b = f_hLast(pivots, 2)
    _h2p = f_hLastP(pivots, 2)
    _h1b = f_hLast(pivots, 1)
    _h1p = f_hLastP(pivots, 1)
    _have = _l2b >= 0 and _l1b >= 0 and _h2b >= 0 and _h1b >= 0
    _overlap = _have and f_overlaps(_l2b, _l1b, _h2b, _h1b)
    _flatBottom = _have and f_roughlyEqual(_l2p, _l1p, flatTolerance)
    _fallingHighs = _have and _h1p < _h2p * (1 - minFallPct)
    _isPattern = _have and _overlap and _flatBottom and _fallingHighs
    _support = _have ? math.min(_l1p, _l2p) : na
    _found = _isPattern and close < _support
    [_pivBars, _pivPrices] = f_sortPivots(array.from(_h2b, _l2b, _h1b, _l1b), array.from(_h2p, _l2p, _h1p, _l1p))
    _found ? ChartPatternMatch.new(true, "Descending Triangle", "bearish", _pivBars, _pivPrices, _support, f_slope(_h2b, _h2p, _h1b, _h1p), bar_index, "Descending Triangle: flat support near " + str.tostring(_support, format.mintick) + " with falling resistance (" + str.tostring(_h2p, format.mintick) + " -> " + str.tostring(_h1p, format.mintick) + "), now closing below support - continuation breakdown.") : f_none()

// @function Symmetrical Triangle — converging highs and rising lows, breaking out either direction. Bilateral until the breakout resolves it.
// @param pivots Result of trackPivots(), called once per bar in your script.
// @param minConvergePct Min amount each new high/low must move toward the other, as a fraction of price.
// @returns ChartPatternMatch
export detectTriangleSymmetrical(PivotSet pivots, float minConvergePct = 0.01) =>
    _h2b = f_hLast(pivots, 2)
    _h2p = f_hLastP(pivots, 2)
    _h1b = f_hLast(pivots, 1)
    _h1p = f_hLastP(pivots, 1)
    _l2b = f_lLast(pivots, 2)
    _l2p = f_lLastP(pivots, 2)
    _l1b = f_lLast(pivots, 1)
    _l1p = f_lLastP(pivots, 1)
    _have = _h2b >= 0 and _h1b >= 0 and _l2b >= 0 and _l1b >= 0
    _overlap = _have and f_overlaps(_h2b, _h1b, _l2b, _l1b)
    _fallingHighs = _have and _h1p < _h2p * (1 - minConvergePct)
    _risingLows = _have and _l1p > _l2p * (1 + minConvergePct)
    _isPattern = _have and _overlap and _fallingHighs and _risingLows
    _bullBreak = _isPattern and close > _h1p
    _bearBreak = _isPattern and close < _l1p
    [_pivBars, _pivPrices] = f_sortPivots(array.from(_h2b, _l2b, _h1b, _l1b), array.from(_h2p, _l2p, _h1p, _l1p))

    if _bullBreak
        ChartPatternMatch.new(true, "Symmetrical Triangle", "bullish", _pivBars, _pivPrices, _h1p, na, bar_index, "Symmetrical Triangle: converging highs (" + str.tostring(_h2p, format.mintick) + " -> " + str.tostring(_h1p, format.mintick) + ") and rising lows (" + str.tostring(_l2p, format.mintick) + " -> " + str.tostring(_l1p, format.mintick) + "), now breaking above the upper trendline.")
    else if _bearBreak
        ChartPatternMatch.new(true, "Symmetrical Triangle", "bearish", _pivBars, _pivPrices, _l1p, na, bar_index, "Symmetrical Triangle: converging highs (" + str.tostring(_h2p, format.mintick) + " -> " + str.tostring(_h1p, format.mintick) + ") and rising lows (" + str.tostring(_l2p, format.mintick) + " -> " + str.tostring(_l1p, format.mintick) + "), now breaking below the lower trendline.")
    else
        f_none()

// @function Rising Wedge / Falling Wedge — both trendlines slope the same direction and converge; breaks the opposite way from the slope.
// @param pivots Result of trackPivots(), called once per bar in your script.
// @param minSlopePct Min amount each new high/low must move in the shared direction by, as a fraction of price.
// @returns ChartPatternMatch
export detectWedge(PivotSet pivots, float minSlopePct = 0.01) =>
    _h2b = f_hLast(pivots, 2)
    _h2p = f_hLastP(pivots, 2)
    _h1b = f_hLast(pivots, 1)
    _h1p = f_hLastP(pivots, 1)
    _l2b = f_lLast(pivots, 2)
    _l2p = f_lLastP(pivots, 2)
    _l1b = f_lLast(pivots, 1)
    _l1p = f_lLastP(pivots, 1)
    _have = _h2b >= 0 and _h1b >= 0 and _l2b >= 0 and _l1b >= 0
    _overlap = _have and f_overlaps(_h2b, _h1b, _l2b, _l1b)
    _bothRising = _have and _overlap and _h1p > _h2p * (1 + minSlopePct) and _l1p > _l2p * (1 + minSlopePct)
    _bothFalling = _have and _overlap and _h1p < _h2p * (1 - minSlopePct) and _l1p < _l2p * (1 - minSlopePct)
    _risingWedge = _bothRising and close < _l1p
    _fallingWedge = _bothFalling and close > _h1p
    [_pivBars, _pivPrices] = f_sortPivots(array.from(_h2b, _l2b, _h1b, _l1b), array.from(_h2p, _l2p, _h1p, _l1p))

    if _risingWedge
        ChartPatternMatch.new(true, "Rising Wedge", "bearish", _pivBars, _pivPrices, _l1p, f_slope(_l2b, _l2p, _l1b, _l1p), bar_index, "Rising Wedge: both the highs (" + str.tostring(_h2p, format.mintick) + " -> " + str.tostring(_h1p, format.mintick) + ") and lows (" + str.tostring(_l2p, format.mintick) + " -> " + str.tostring(_l1p, format.mintick) + ") are climbing and converging, now breaking down through the lower trendline - momentum was fading despite higher prices.")
    else if _fallingWedge
        ChartPatternMatch.new(true, "Falling Wedge", "bullish", _pivBars, _pivPrices, _h1p, f_slope(_h2b, _h2p, _h1b, _h1p), bar_index, "Falling Wedge: both the highs (" + str.tostring(_h2p, format.mintick) + " -> " + str.tostring(_h1p, format.mintick) + ") and lows (" + str.tostring(_l2p, format.mintick) + " -> " + str.tostring(_l1p, format.mintick) + ") are declining and converging, now breaking up through the upper trendline - selling pressure was fading despite lower prices.")
    else
        f_none()

// @function Bull Flag / Bear Flag — a strong directional move (the pole) followed by a tight, roughly parallel pullback, breaking back out in the pole's direction. Self-contained — doesn't take a PivotSet, since the pole is measured directly off price rather than swing pivots.
// @param poleLookback Bars making up the pole, measured just before the flag window.
// @param flagLookback Bars making up the flag (consolidation) window, most recent.
// @param minPolePct Min size of the pole's net move, as a fraction of price.
// @param maxFlagRangePct Max size of the flag's range, as a fraction of the pole's size — how "tight" the pullback must be.
// @returns ChartPatternMatch
export detectFlag(int poleLookback = 10, int flagLookback = 8, float minPolePct = 0.03, float maxFlagRangePct = 0.5) =>
    _poleStart = close[poleLookback + flagLookback]
    _poleEnd = close[flagLookback]
    _poleMove = _poleEnd - _poleStart
    _poleUp = _poleMove > 0 and math.abs(_poleMove) >= minPolePct * math.abs(_poleStart)
    _poleDown = _poleMove < 0 and math.abs(_poleMove) >= minPolePct * math.abs(_poleStart)
    _flagHigh = f_highestOver(flagLookback)
    _flagLow = f_lowestOver(flagLookback)
    _flagRange = _flagHigh - _flagLow
    _poleRange = math.abs(_poleMove)
    _tightFlag = _poleRange > 0 and _flagRange <= maxFlagRangePct * _poleRange
    _bullFlag = _poleUp and _tightFlag and close > _flagHigh
    _bearFlag = _poleDown and _tightFlag and close < _flagLow

    if _bullFlag
        ChartPatternMatch.new(true, "Bull Flag", "bullish", array.from(bar_index - poleLookback - flagLookback, bar_index - flagLookback), array.from(_poleStart, _poleEnd), _flagHigh, na, bar_index, "Bull Flag: a strong advance (" + str.tostring(_poleStart, format.mintick) + " -> " + str.tostring(_poleEnd, format.mintick) + ") followed by a tight sideways pullback, now breaking back above the flag's high - the pole's move looks set to continue.")
    else if _bearFlag
        ChartPatternMatch.new(true, "Bear Flag", "bearish", array.from(bar_index - poleLookback - flagLookback, bar_index - flagLookback), array.from(_poleStart, _poleEnd), _flagLow, na, bar_index, "Bear Flag: a strong decline (" + str.tostring(_poleStart, format.mintick) + " -> " + str.tostring(_poleEnd, format.mintick) + ") followed by a tight sideways pullback, now breaking back below the flag's low - the pole's move looks set to continue.")
    else
        f_none()

// @function Bull Pennant / Bear Pennant — a strong directional move (the pole) followed by a narrowing, converging consolidation, breaking back out in the pole's direction. Self-contained, same reasoning as detectFlag.
// @param poleLookback Bars making up the pole, measured just before the pennant window.
// @param flagLookback Bars making up the pennant (consolidation) window, most recent.
// @param minPolePct Min size of the pole's net move, as a fraction of price.
// @param minConvergeRatio Max size of the pennant's late range relative to its early range — how much it must have narrowed.
// @returns ChartPatternMatch
export detectPennant(int poleLookback = 10, int flagLookback = 8, float minPolePct = 0.03, float minConvergeRatio = 0.5) =>
    _poleStart = close[poleLookback + flagLookback]
    _poleEnd = close[flagLookback]
    _poleMove = _poleEnd - _poleStart
    _poleUp = _poleMove > 0 and math.abs(_poleMove) >= minPolePct * math.abs(_poleStart)
    _poleDown = _poleMove < 0 and math.abs(_poleMove) >= minPolePct * math.abs(_poleStart)
    _earlyHigh = math.max(high[flagLookback], high[flagLookback - 1])
    _earlyLow = math.min(low[flagLookback], low[flagLookback - 1])
    _earlyRange = _earlyHigh - _earlyLow
    _lateHigh = math.max(high[0], high[1])
    _lateLow = math.min(low[0], low[1])
    _lateRange = _lateHigh - _lateLow
    _converged = _earlyRange > 0 and _lateRange <= minConvergeRatio * _earlyRange
    _bullPennant = _poleUp and _converged and close > _lateHigh
    _bearPennant = _poleDown and _converged and close < _lateLow

    if _bullPennant
        ChartPatternMatch.new(true, "Bull Pennant", "bullish", array.from(bar_index - poleLookback - flagLookback, bar_index - flagLookback), array.from(_poleStart, _poleEnd), _lateHigh, na, bar_index, "Bull Pennant: a strong advance (" + str.tostring(_poleStart, format.mintick) + " -> " + str.tostring(_poleEnd, format.mintick) + ") followed by a narrowing, converging consolidation, now breaking back above it - the pole's move looks set to continue.")
    else if _bearPennant
        ChartPatternMatch.new(true, "Bear Pennant", "bearish", array.from(bar_index - poleLookback - flagLookback, bar_index - flagLookback), array.from(_poleStart, _poleEnd), _lateLow, na, bar_index, "Bear Pennant: a strong decline (" + str.tostring(_poleStart, format.mintick) + " -> " + str.tostring(_poleEnd, format.mintick) + ") followed by a narrowing, converging consolidation, now breaking back below it - the pole's move looks set to continue.")
    else
        f_none()

// @function Rectangle — price boxed between flat support and flat resistance, breaking out either edge.
// @param pivots Result of trackPivots(), called once per bar in your script.
// @param flatTolerance Max difference between the two highs, and separately between the two lows, as a fraction of price.
// @returns ChartPatternMatch
export detectRectangle(PivotSet pivots, float flatTolerance = 0.015) =>
    _h2b = f_hLast(pivots, 2)
    _h2p = f_hLastP(pivots, 2)
    _h1b = f_hLast(pivots, 1)
    _h1p = f_hLastP(pivots, 1)
    _l2b = f_lLast(pivots, 2)
    _l2p = f_lLastP(pivots, 2)
    _l1b = f_lLast(pivots, 1)
    _l1p = f_lLastP(pivots, 1)
    _have = _h2b >= 0 and _h1b >= 0 and _l2b >= 0 and _l1b >= 0
    _overlap = _have and f_overlaps(_h2b, _h1b, _l2b, _l1b)
    _flatTop = _have and f_roughlyEqual(_h2p, _h1p, flatTolerance)
    _flatBottom = _have and f_roughlyEqual(_l2p, _l1p, flatTolerance)
    _isRectangle = _have and _overlap and _flatTop and _flatBottom
    _resist = _have ? math.max(_h1p, _h2p) : na
    _support = _have ? math.min(_l1p, _l2p) : na
    _bullBreak = _isRectangle and close > _resist
    _bearBreak = _isRectangle and close < _support
    [_pivBars, _pivPrices] = f_sortPivots(array.from(_h2b, _l2b, _h1b, _l1b), array.from(_h2p, _l2p, _h1p, _l1p))

    if _bullBreak
        ChartPatternMatch.new(true, "Rectangle", "bullish", _pivBars, _pivPrices, _resist, na, bar_index, "Rectangle: price boxed between support near " + str.tostring(_support, format.mintick) + " and resistance near " + str.tostring(_resist, format.mintick) + ", now breaking out above resistance.")
    else if _bearBreak
        ChartPatternMatch.new(true, "Rectangle", "bearish", _pivBars, _pivPrices, _support, na, bar_index, "Rectangle: price boxed between support near " + str.tostring(_support, format.mintick) + " and resistance near " + str.tostring(_resist, format.mintick) + ", now breaking down below support.")
    else
        f_none()

// @function Cup and Handle / Inverted Cup and Handle — a rounded recovery (or decline) back to its starting rim, then a shallow pullback (the handle), breaking through the rim.
// @param pivots Result of trackPivots(), called once per bar in your script.
// @param rimTolerance Max difference between the two rim levels, as a fraction of price.
// @param maxHandleRetracePct Max size of the handle's pullback relative to the cup's depth.
// @returns ChartPatternMatch
export detectCupAndHandle(PivotSet pivots, float rimTolerance = 0.03, float maxHandleRetracePct = 0.5) =>
    _leftRimB = f_hLast(pivots, 2)
    _leftRimP = f_hLastP(pivots, 2)
    _cupBotB = f_lLast(pivots, 2)
    _cupBotP = f_lLastP(pivots, 2)
    _rightRimB = f_hLast(pivots, 1)
    _rightRimP = f_hLastP(pivots, 1)
    _handleB = f_lLast(pivots, 1)
    _handleP = f_lLastP(pivots, 1)
    _have = _leftRimB >= 0 and _cupBotB >= 0 and _rightRimB >= 0 and _handleB >= 0 and _leftRimB < _cupBotB and _cupBotB < _rightRimB and _rightRimB < _handleB
    _rimsEqual = _have and f_roughlyEqual(_leftRimP, _rightRimP, rimTolerance)
    _cupDepth = _have ? _leftRimP - _cupBotP : na
    _handleShallow = _have and _cupDepth > 0 and (_rightRimP - _handleP) <= maxHandleRetracePct * _cupDepth
    _cupFound = _have and _rimsEqual and _handleShallow and close > _rightRimP

    _ileftB = f_lLast(pivots, 2)
    _ileftP = f_lLastP(pivots, 2)
    _itopB = f_hLast(pivots, 2)
    _itopP = f_hLastP(pivots, 2)
    _irightB = f_lLast(pivots, 1)
    _irightP = f_lLastP(pivots, 1)
    _ihandleB = f_hLast(pivots, 1)
    _ihandleP = f_hLastP(pivots, 1)
    _ihave = _ileftB >= 0 and _itopB >= 0 and _irightB >= 0 and _ihandleB >= 0 and _ileftB < _itopB and _itopB < _irightB and _irightB < _ihandleB
    _irimsEqual = _ihave and f_roughlyEqual(_ileftP, _irightP, rimTolerance)
    _icupDepth = _ihave ? _itopP - _ileftP : na
    _ihandleShallow = _ihave and _icupDepth > 0 and (_ihandleP - _irightP) <= maxHandleRetracePct * _icupDepth
    _invFound = _ihave and _irimsEqual and _ihandleShallow and close < _irightP

    if _cupFound
        ChartPatternMatch.new(true, "Cup and Handle", "bullish", array.from(_leftRimB, _cupBotB, _rightRimB, _handleB), array.from(_leftRimP, _cupBotP, _rightRimP, _handleP), _rightRimP, na, bar_index, "Cup and Handle: a rounded recovery back to the rim (" + str.tostring(_leftRimP, format.mintick) + " / " + str.tostring(_rightRimP, format.mintick) + "), a shallow pullback (handle) to " + str.tostring(_handleP, format.mintick) + ", now breaking out above the rim.")
    else if _invFound
        ChartPatternMatch.new(true, "Inverted Cup and Handle", "bearish", array.from(_ileftB, _itopB, _irightB, _ihandleB), array.from(_ileftP, _itopP, _irightP, _ihandleP), _irightP, na, bar_index, "Inverted Cup and Handle: a rounded decline back to the rim (" + str.tostring(_ileftP, format.mintick) + " / " + str.tostring(_irightP, format.mintick) + "), a shallow bounce (handle) to " + str.tostring(_ihandleP, format.mintick) + ", now breaking down below the rim.")
    else
        f_none()

// ---------------------------------------------------------------------------
// Structural / gap-based patterns
// ---------------------------------------------------------------------------

// @function Bullish / Bearish Island Reversal — a bar (or small cluster) isolated by a gap on both sides, then abandoned by a gap the other way. Self-contained — pure gap logic, no pivots needed.
// @returns ChartPatternMatch
export detectIslandReversal() =>
    _gapUpIn = low[1] > high[2]
    _gapDownOut = high[0] < low[1]
    _bearish = _gapUpIn and _gapDownOut
    _gapDownIn = high[1] < low[2]
    _gapUpOut = low[0] > high[1]
    _bullish = _gapDownIn and _gapUpOut

    if _bearish
        ChartPatternMatch.new(true, "Bearish Island Reversal", "bearish", array.from(bar_index - 1), array.from(high[1]), low[1], na, bar_index, "Bearish Island Reversal: a gap up isolated a bar above the surrounding price (high " + str.tostring(high[1], format.mintick) + "), then a gap down left it stranded - an abrupt reversal.")
    else if _bullish
        ChartPatternMatch.new(true, "Bullish Island Reversal", "bullish", array.from(bar_index - 1), array.from(low[1]), high[1], na, bar_index, "Bullish Island Reversal: a gap down isolated a bar below the surrounding price (low " + str.tostring(low[1], format.mintick) + "), then a gap up left it stranded - an abrupt reversal.")
    else
        f_none()

// @function Bump-and-Run Reversal — a lead-in trendline, then a "bump" phase accelerating well beyond it, then a "run" breaking back through the lead-in line. Approximate: the lead-in line is read from just two pivots.
// @param pivots Result of trackPivots(), called once per bar in your script.
// @param minBumpDeviationPct Min amount the bump phase must deviate from the projected lead-in line by, as a fraction of price.
// @returns ChartPatternMatch
export detectBumpAndRun(PivotSet pivots, float minBumpDeviationPct = 0.05) =>
    _l2b = f_lLast(pivots, 2)
    _l2p = f_lLastP(pivots, 2)
    _l1b = f_lLast(pivots, 1)
    _l1p = f_lLastP(pivots, 1)
    _haveUp = _l2b >= 0 and _l1b >= 0 and _l1b > _l2b and _l1p > _l2p
    _leadLine = _haveUp ? f_lineAt(_l2b, _l2p, _l1b, _l1p, bar_index) : na
    _bumpLookback = _haveUp ? math.min(math.max(bar_index - _l1b, 1), 200) : 1
    _bumpHigh = _haveUp ? f_highestOver(_bumpLookback) : na
    _bumpedFar = _haveUp and not na(_bumpHigh) and not na(_leadLine) and _bumpHigh > _leadLine * (1 + minBumpDeviationPct)
    _bearRun = _haveUp and _bumpedFar and close < _leadLine

    _h2b = f_hLast(pivots, 2)
    _h2p = f_hLastP(pivots, 2)
    _h1b = f_hLast(pivots, 1)
    _h1p = f_hLastP(pivots, 1)
    _haveDown = _h2b >= 0 and _h1b >= 0 and _h1b > _h2b and _h1p < _h2p
    _leadLineDown = _haveDown ? f_lineAt(_h2b, _h2p, _h1b, _h1p, bar_index) : na
    _bumpLookbackDown = _haveDown ? math.min(math.max(bar_index - _h1b, 1), 200) : 1
    _bumpLow = _haveDown ? f_lowestOver(_bumpLookbackDown) : na
    _bumpedFarDown = _haveDown and not na(_bumpLow) and not na(_leadLineDown) and _bumpLow < _leadLineDown * (1 - minBumpDeviationPct)
    _bullRun = _haveDown and _bumpedFarDown and close > _leadLineDown

    if _bearRun
        ChartPatternMatch.new(true, "Bump-and-Run Reversal Top", "bearish", array.from(_l2b, _l1b), array.from(_l2p, _l1p), _leadLine, f_slope(_l2b, _l2p, _l1b, _l1p), bar_index, "Bump-and-Run Reversal: price accelerated well above its lead-in support trendline (the 'bump'), now breaking back down through that trendline (the 'run') - the acceleration itself was the warning sign.")
    else if _bullRun
        ChartPatternMatch.new(true, "Bump-and-Run Reversal Bottom", "bullish", array.from(_h2b, _h1b), array.from(_h2p, _h1p), _leadLineDown, f_slope(_h2b, _h2p, _h1b, _h1p), bar_index, "Bump-and-Run Reversal: price accelerated well below its lead-in resistance trendline (the 'bump'), now breaking back up through that trendline (the 'run') - the acceleration itself was the warning sign.")
    else
        f_none()

// ---------------------------------------------------------------------------
// Utility
// ---------------------------------------------------------------------------

// @function Scores how decisively a match's confirmation close broke through its breakoutLevel, relative to the pattern's own price range (the high-low span of pivotPrices) — a common TA heuristic: a breakout that clears the level by a meaningful fraction of the pattern's own size is more reliable than a one-tick poke through it. Patterns built from a single defining pivot (Spike, Island Reversal) have no such range to measure against and always score a flat neutral 50.
// @param m A ChartPatternMatch returned by any detect*() function above.
// @returns A strength score from 0 to 100. 0 when the match isn't found.
export patternStrength(ChartPatternMatch m) =>
    if not m.found or array.size(m.pivotPrices) == 0
        0.0
    else
        _range = array.max(m.pivotPrices) - array.min(m.pivotPrices)
        _hasBreakout = not na(m.breakoutLevel)
        _hasBreakout and _range > 0 ? math.min(100.0, (math.abs(close - m.breakoutLevel) / _range) * 400) : 50.0

// @function Classical "project the pattern's own height from the breakout point" measured-move target — the standard rule for Double/Triple Top-Bottom, the triangles, Wedge, Rectangle, Diamond, Broadening, Flag, Pennant and Cup & Handle. Also correct for Head & Shoulders, since the head sits exactly at the pivotPrices extreme, so the same formula naturally measures the shoulder-to-head distance. Spike, Island Reversal and Bump-and-Run don't have a reliable multi-pivot height to project from, so they return na rather than a guessed number.
// @param m A ChartPatternMatch returned by any detect*() function above.
// @returns The projected target price, or na when the pattern has no reliable height to measure.
export patternTarget(ChartPatternMatch m) =>
    _isBumpAndRun = m.patternName == "Bump-and-Run Reversal Top" or m.patternName == "Bump-and-Run Reversal Bottom"
    if not m.found or na(m.breakoutLevel) or array.size(m.pivotPrices) < 2 or _isBumpAndRun
        float(na)
    else
        _height = array.max(m.pivotPrices) - array.min(m.pivotPrices)
        m.direction == "bullish" ? m.breakoutLevel + _height : m.breakoutLevel - _height
````
