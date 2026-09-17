<!-- tradingview-pine-id: PUB;192b9f9d92d44e6dbf347d2c2ca78573 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Pattern_Atlas_Candlestick

Source: https://www.tradingview.com/script/n7a4zi3s-Pattern-Atlas-Candlestick-AxeAlgo/

## Description

Pattern Atlas : Candlestick [AxeAlgo]

WHAT THIS LIBRARY IS

This is a Pine Script v6 library of 23 candlestick pattern detectors — one exported function per pattern family, each doing pure open/high/low/close arithmetic against the current or a specified historical bar. There is no plotting, no alerts, and no inputs in this script by design: a library's job is to hand other scripts a clean, reusable, well-documented API, not to draw on a chart itself (Pine doesn't allow a library to plot anything anyway). If you're looking for a ready-to-use indicator built on top of this library, see the companion "Pattern Atlas : Candlestick Scanner [AxeAlgo]" script, which imports every function here and turns it into on-chart signals, a live scanner table, and alerts.(will be published soon)

Candlestick reading is one of the oldest and most widely taught tools in technical analysis, going back to Steve Nison's work bringing Japanese candlestick charting to Western traders. The patterns in this library follow that standard catalog (cross-checked against TA-Lib's CDL* function list, the closest thing to an industry-standard reference), so anyone who already knows what a Morning Star or a Bullish Engulfing bar looks like will recognize exactly what each function is checking for.

WHY A LIBRARY INSTEAD OF ONE MONOLITHIC INDICATOR

Splitting detection logic out as an importable library means:
- Any Pine coder building their own strategy, indicator, or screener can pull in exactly the pattern checks they need without copy-pasting candlestick math into every new script.
- The detection logic is tested and maintained in one place. When a threshold gets refined, everything importing this library benefits from the update by bumping one version number.
- It keeps the math separate from presentation — how a pattern gets drawn, colored, or alerted on is a completely separate decision from whether the pattern is actually present, and different users want different presentations.

HOW TO IMPORT AND USE IT

Add this line near the top of your script (adjust the version number to whatever the current published version is):

import AxeAlgo/PatternCandlestick/1 as cdl

Then call any function directly. Every function returns the same structure, called CandleMatch, so the calling pattern is identical no matter which of the 23 you use:

match = cdl.detectDoji()
if match.found
    label.new(bar_index, low, match.patternName)

CandleMatch has six fields:
- found — true if the pattern matched at the evaluated bar, false otherwise.
- patternName — the specific name of what matched (e.g. "Hanging Man"), na when not found.
- direction — "bullish", "bearish", or "neutral".
- barIndex — the bar_index the pattern completes on.
- barsUsed — how many bars the pattern spans (1, 2, 3, or 5 for the one continuation pattern that needs a 5-bar read).
- description — a full sentence naming the pattern and the actual measured values that triggered it (body size as a percent of range, wick-to-body multiples, or the specific price levels involved, depending on the pattern) — genuinely useful for a tooltip or an alert message, not just a repeat of the pattern name.

Every function also accepts an optional offset parameter (default 0, meaning the current/most recent bar) if you want to check a pattern further back in history, plus its own set of tunable threshold parameters — how strict the "small body" or "long wick" cutoffs are — all exposed with sensible defaults so you don't have to touch them unless you want to tighten or loosen a specific pattern's sensitivity for a particular instrument.

THE 23 PATTERNS

Single-bar patterns (9) — each reads one candle's own open/high/low/close shape:

- Doji — detectDoji(). Body is negligible relative to the bar's range; open and close land almost on top of each other. Neutral.
- Long-Legged Doji — detectLongLeggedDoji(). A doji with long wicks on both sides — both directions were pushed and rejected in the same bar. Neutral.
- Dragonfly Doji — detectDragonflyDoji(). A doji with a long lower wick and almost no upper wick — buyers rejected the lows. Bullish.
- Gravestone Doji — detectGravestoneDoji(). A doji with a long upper wick and almost no lower wick — sellers rejected the highs. Bearish.
- Hammer / Hanging Man — detectHammerHangingMan(). Small body, long lower wick, negligible upper wick — the same shape read two ways depending on the prior trend: a Hammer after a decline (bullish), a Hanging Man after an advance (bearish). The function infers the prior trend automatically from a lookback window, or you can supply your own trend context.
- Inverted Hammer / Shooting Star — detectInvertedHammerShootingStar(). The mirror shape (long upper wick, negligible lower wick), same trend-dependent split: Inverted Hammer after a decline (bullish), Shooting Star after an advance (bearish).
- Marubozu — detectMarubozu(). A full-bodied candle with negligible wicks on either side — one side was in complete control from open to close. Direction follows the body color.
- Spinning Top — detectSpinningTop(). Small body with real wicks on both sides, roughly balanced — pushes both up and down failed. Neutral.
- Belt Hold — detectBeltHold(). Opens at (or almost at) one extreme with almost no wick on the opening side, then closes strongly the other way — one side controlled the entire session from the opening bell.

Two-bar patterns (6) — each compares the current bar against the one before it:

- Engulfing — detectEngulfing(). The current bar's body fully covers the prior bar's opposite-colored body.
- Harami — detectHarami(). The current bar's body sits fully inside the prior bar's opposite-colored body — the inverse of Engulfing, read as the move stalling.
- Harami Cross — detectHaramiCross(). A Harami where the contained bar is also a doji — a stronger version of the stall.
- Piercing Line / Dark Cloud Cover — detectPiercingDarkCloud(). The current bar opens beyond the prior bar's extreme and closes back past its midpoint — Piercing Line is the bullish version after a decline, Dark Cloud Cover the bearish version after an advance.
- Tweezer Top / Bottom — detectTweezer(). Two consecutive bars sharing a near-identical high (Tweezer Top, bearish) or low (Tweezer Bottom, bullish) — the level held on both attempts.
- Kicker — detectKicker(). A gap between two opposite-colored bars with zero overlap between their bodies — an abrupt, no-transition reversal in sentiment.

Three-bar-and-longer patterns (8) — each reads a short sequence of bars together:

- Morning Star / Evening Star — detectStar(). A large bar, a small bar gapped away from it, then a third bar closing back past the midpoint of the first — the classic three-bar reversal, bullish (Morning) at the bottom or bearish (Evening) at the top.
- Morning Doji Star / Evening Doji Star — detectDojiStar(). The same structure as the Star pattern above, but the middle bar is specifically a doji — a stronger version of the signal.
- Three White Soldiers / Three Black Crows — detectThreeSoldiersCrows(). Three consecutive same-direction bars, each opening inside the prior body and closing beyond the prior close — steady, sustained buying or selling.
- Three Inside Up / Down — detectThreeInside(). A Harami followed by a third bar closing beyond the first bar's open, confirming the stall seen in the Harami actually turned into a reversal.
- Three Outside Up / Down — detectThreeOutside(). An Engulfing followed by a third bar extending the same move, confirming the reversal.
- Abandoned Baby — detectAbandonedBaby(). A Doji Star with a genuine price gap (not just a wick gap) on both sides of the middle bar — a rare, high-conviction reversal.
- Rising / Falling Three Methods — detectThreeMethods(). A strong trend bar, three small counter-trend bars fully contained inside its range, then a bar resuming the original direction beyond the first bar's close — the trend paused without reversing. This is the one pattern spanning 5 bars rather than 1-3.
- Stick Sandwich — detectStickSandwich(). Two bearish bars with matching closes sandwiching one bullish bar in between — sellers failed to push the close any lower on the second attempt.

WHAT THIS LIBRARY DELIBERATELY DOES NOT DO

No plotting, no drawing, no alertcondition() calls, and no inputs — Pine doesn't allow any of those inside a library in the first place, since a library can never be added to a chart on its own. If you want signals, a scanner table, or alerts, import this library into your own script (or use the companion "Pattern Atlas : Candlestick Scanner [AxeAlgo]" indicator, which does exactly that) rather than expecting this script to render anything by itself.

This library also does not evaluate multi-timeframe data, volume, or broader market structure — it's candlestick shape and price-only, on purpose, so its behavior is easy to reason about and easy to reuse as one building block among several.

PART OF A LARGER SERIES

This is Library #1 in the AxeAlgo Pattern Atlas — a planned set of Pine libraries splitting pattern detection by the method actually used to find each kind of pattern: candlestick shape (this library), classical chart/geometric patterns (trendline-based structures like triangles, head and shoulders, flags), harmonic patterns (Fibonacci-ratio XABCD structures), and market-structure concepts (order blocks, liquidity, Wyckoff-style events). Each library is independent and useful on its own; together they're meant to cover technical pattern analysis without forcing unrelated detection methods into the same function.

A NOTE ON REPAINTING

Every function here evaluates whatever bar you point it at (the current bar by default, via the offset parameter) using that bar's own open/high/low/close. On the currently-forming bar, those values are still changing tick to tick — that's inherent to reading live price action, not a defect in this library. If you're building persisted signals, drawings, or alerts on top of these functions (rather than a live "what's happening right now" readout), gate your usage on barstate.isconfirmed so a signal only fires once the bar it describes has actually closed, exactly like the companion scanner indicator does.

DISCLAIMER

This library is a technical analysis tool for identifying classical candlestick shapes in historical and live price data. It does not predict future price movement, and a detected pattern is a description of past price action, not a signal guaranteed to repeat. Nothing in this script constitutes financial advice. Always combine pattern recognition with your own risk management and broader analysis before making any trading decision.

---

## Source Code

````pine
//@version=6
// © AxeAlgo

// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// For commercial use licensing, contact https://www.tradingview.com/u/AxeAlgo/

// AxeAlgo Pattern Atlas — Library 1: Candlestick pattern detection.
// One exported function per pattern (mirror pairs share one function via `direction`), detection only.
library("Pattern_Atlas_Candlestick", overlay = true)

// @type Result returned by every detect*() function in this library.
// @field found true if the pattern matched at the evaluated bar.
// @field patternName Name of the matched pattern, na when not found.
// @field direction "bullish", "bearish", or "neutral".
// @field barIndex bar_index the pattern completes on, na when not found.
// @field barsUsed Number of bars the pattern spans (1, 2, 3, or 5 for Three Methods).
// @field description Plain-language explanation of the pattern and the measured values that triggered it, na when not found.
export type CandleMatch
    bool   found       = false
    string patternName = na
    string direction   = na
    int    barIndex    = na
    int    barsUsed    = na
    string description = na

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------
f_rng(_h, _l) => math.max(_h - _l, syminfo.mintick)
f_body(_o, _c) => math.abs(_c - _o)
f_upW(_o, _h, _c) => _h - math.max(_o, _c)
f_dnW(_o, _l, _c) => math.min(_o, _c) - _l
f_bull(_o, _c) => _c > _o
f_bear(_o, _c) => _c < _o
f_none() => CandleMatch.new(false, na, na, na, na, na)
f_pct(_x) => str.tostring(_x * 100, "#.#") + "%"
f_mult(_x) => str.tostring(_x, "#.##") + "x"

// ---------------------------------------------------------------------------
// Single-bar patterns
// ---------------------------------------------------------------------------

// @function Standard Doji — body negligible relative to range.
// @param offset Bars back from the current bar to evaluate (0 = current bar).
// @param maxBodyRatio Max body size as a fraction of the bar's range.
// @returns CandleMatch
export detectDoji(int offset = 0, float maxBodyRatio = 0.1) =>
    _o = open[offset]
    _h = high[offset]
    _l = low[offset]
    _c = close[offset]
    _rng = f_rng(_h, _l)
    _body = f_body(_o, _c)
    _found = _body <= maxBodyRatio * _rng
    _desc = "Doji: body is " + f_pct(_body / _rng) + " of the bar's range (<= " + f_pct(maxBodyRatio) + " threshold) - open and close nearly equal, signaling indecision."
    _found ? CandleMatch.new(true, "Doji", "neutral", bar_index - offset, 1, _desc) : f_none()

// @function Long-Legged Doji — doji with long wicks on both sides.
// @param offset Bars back from the current bar to evaluate.
// @param maxBodyRatio Max body size as a fraction of range.
// @param minWickRatio Min size of each wick as a fraction of range.
// @returns CandleMatch
export detectLongLeggedDoji(int offset = 0, float maxBodyRatio = 0.1, float minWickRatio = 0.35) =>
    _o = open[offset]
    _h = high[offset]
    _l = low[offset]
    _c = close[offset]
    _rng = f_rng(_h, _l)
    _body = f_body(_o, _c)
    _upW = f_upW(_o, _h, _c)
    _dnW = f_dnW(_o, _l, _c)
    _found = _body <= maxBodyRatio * _rng and _upW >= minWickRatio * _rng and _dnW >= minWickRatio * _rng
    _desc = "Long-Legged Doji: body " + f_pct(_body / _rng) + " of range, upper wick " + f_pct(_upW / _rng) + " and lower wick " + f_pct(_dnW / _rng) + " - both sides were pushed and rejected, deep indecision."
    _found ? CandleMatch.new(true, "Long-Legged Doji", "neutral", bar_index - offset, 1, _desc) : f_none()

// @function Dragonfly Doji — doji with a long lower wick and no upper wick.
// @param offset Bars back from the current bar to evaluate.
// @param maxBodyRatio Max body size as a fraction of range.
// @param minLowerWickRatio Min lower wick as a fraction of range.
// @param maxUpperWickRatio Max upper wick as a fraction of range.
// @returns CandleMatch
export detectDragonflyDoji(int offset = 0, float maxBodyRatio = 0.1, float minLowerWickRatio = 0.6, float maxUpperWickRatio = 0.1) =>
    _o = open[offset]
    _h = high[offset]
    _l = low[offset]
    _c = close[offset]
    _rng = f_rng(_h, _l)
    _body = f_body(_o, _c)
    _upW = f_upW(_o, _h, _c)
    _dnW = f_dnW(_o, _l, _c)
    _found = _body <= maxBodyRatio * _rng and _dnW >= minLowerWickRatio * _rng and _upW <= maxUpperWickRatio * _rng
    _desc = "Dragonfly Doji: body " + f_pct(_body / _rng) + " of range, lower wick " + f_pct(_dnW / _rng) + " with almost no upper wick - buyers rejected the lows."
    _found ? CandleMatch.new(true, "Dragonfly Doji", "bullish", bar_index - offset, 1, _desc) : f_none()

// @function Gravestone Doji — doji with a long upper wick and no lower wick.
// @param offset Bars back from the current bar to evaluate.
// @param maxBodyRatio Max body size as a fraction of range.
// @param minUpperWickRatio Min upper wick as a fraction of range.
// @param maxLowerWickRatio Max lower wick as a fraction of range.
// @returns CandleMatch
export detectGravestoneDoji(int offset = 0, float maxBodyRatio = 0.1, float minUpperWickRatio = 0.6, float maxLowerWickRatio = 0.1) =>
    _o = open[offset]
    _h = high[offset]
    _l = low[offset]
    _c = close[offset]
    _rng = f_rng(_h, _l)
    _body = f_body(_o, _c)
    _upW = f_upW(_o, _h, _c)
    _dnW = f_dnW(_o, _l, _c)
    _found = _body <= maxBodyRatio * _rng and _upW >= minUpperWickRatio * _rng and _dnW <= maxLowerWickRatio * _rng
    _desc = "Gravestone Doji: body " + f_pct(_body / _rng) + " of range, upper wick " + f_pct(_upW / _rng) + " with almost no lower wick - sellers rejected the highs."
    _found ? CandleMatch.new(true, "Gravestone Doji", "bearish", bar_index - offset, 1, _desc) : f_none()

// @function Hammer / Hanging Man — same shape (small body, long lower wick); direction depends on prior trend.
// @param offset Bars back from the current bar to evaluate.
// @param maxBodyRatio Max body size as a fraction of range.
// @param minLowerWickToBody Min lower wick as a multiple of body size.
// @param maxUpperWickToBody Max upper wick as a multiple of body size.
// @param trendLookback Bars used to infer prior trend when useTrendOverride is false.
// @param useTrendOverride Set true to supply trend context yourself via trendUpOverride instead of auto-inferring.
// @param trendUpOverride Trend context to use when useTrendOverride is true.
// @returns CandleMatch
export detectHammerHangingMan(int offset = 0, float maxBodyRatio = 0.35, float minLowerWickToBody = 2.0, float maxUpperWickToBody = 0.5, int trendLookback = 5, bool useTrendOverride = false, bool trendUpOverride = false) =>
    _o = open[offset]
    _h = high[offset]
    _l = low[offset]
    _c = close[offset]
    _rng = f_rng(_h, _l)
    _body = math.max(f_body(_o, _c), syminfo.mintick)
    _upW = f_upW(_o, _h, _c)
    _dnW = f_dnW(_o, _l, _c)
    _shape = _body <= maxBodyRatio * _rng and _dnW >= minLowerWickToBody * _body and _upW <= maxUpperWickToBody * _body
    _trendUp = useTrendOverride ? trendUpOverride : close[offset] > close[offset + trendLookback]
    _wickMult = _dnW / _body
    if _shape and not _trendUp
        CandleMatch.new(true, "Hammer", "bullish", bar_index - offset, 1, "Hammer: small body (" + f_pct(_body / _rng) + " of range) with a lower wick " + f_mult(_wickMult) + " the body and little upper wick, after a decline - potential bullish reversal.")
    else if _shape and _trendUp
        CandleMatch.new(true, "Hanging Man", "bearish", bar_index - offset, 1, "Hanging Man: same small-body, long-lower-wick shape as a Hammer (lower wick " + f_mult(_wickMult) + " the body), but after an advance - potential bearish reversal.")
    else
        f_none()

// @function Inverted Hammer / Shooting Star — same shape (small body, long upper wick); direction depends on prior trend.
// @param offset Bars back from the current bar to evaluate.
// @param maxBodyRatio Max body size as a fraction of range.
// @param minUpperWickToBody Min upper wick as a multiple of body size.
// @param maxLowerWickToBody Max lower wick as a multiple of body size.
// @param trendLookback Bars used to infer prior trend when useTrendOverride is false.
// @param useTrendOverride Set true to supply trend context yourself via trendUpOverride instead of auto-inferring.
// @param trendUpOverride Trend context to use when useTrendOverride is true.
// @returns CandleMatch
export detectInvertedHammerShootingStar(int offset = 0, float maxBodyRatio = 0.35, float minUpperWickToBody = 2.0, float maxLowerWickToBody = 0.5, int trendLookback = 5, bool useTrendOverride = false, bool trendUpOverride = false) =>
    _o = open[offset]
    _h = high[offset]
    _l = low[offset]
    _c = close[offset]
    _rng = f_rng(_h, _l)
    _body = math.max(f_body(_o, _c), syminfo.mintick)
    _upW = f_upW(_o, _h, _c)
    _dnW = f_dnW(_o, _l, _c)
    _shape = _body <= maxBodyRatio * _rng and _upW >= minUpperWickToBody * _body and _dnW <= maxLowerWickToBody * _body
    _trendUp = useTrendOverride ? trendUpOverride : close[offset] > close[offset + trendLookback]
    _wickMult = _upW / _body
    if _shape and not _trendUp
        CandleMatch.new(true, "Inverted Hammer", "bullish", bar_index - offset, 1, "Inverted Hammer: small body (" + f_pct(_body / _rng) + " of range) with an upper wick " + f_mult(_wickMult) + " the body and little lower wick, after a decline - potential bullish reversal.")
    else if _shape and _trendUp
        CandleMatch.new(true, "Shooting Star", "bearish", bar_index - offset, 1, "Shooting Star: same small-body, long-upper-wick shape as an Inverted Hammer (upper wick " + f_mult(_wickMult) + " the body), but after an advance - potential bearish reversal.")
    else
        f_none()

// @function Marubozu — full-body candle, negligible wicks either side.
// @param offset Bars back from the current bar to evaluate.
// @param maxWickRatio Max size of each wick as a fraction of range.
// @param minBodyRatio Min body size as a fraction of range.
// @returns CandleMatch
export detectMarubozu(int offset = 0, float maxWickRatio = 0.05, float minBodyRatio = 0.9) =>
    _o = open[offset]
    _h = high[offset]
    _l = low[offset]
    _c = close[offset]
    _rng = f_rng(_h, _l)
    _body = f_body(_o, _c)
    _upW = f_upW(_o, _h, _c)
    _dnW = f_dnW(_o, _l, _c)
    _shape = _upW <= maxWickRatio * _rng and _dnW <= maxWickRatio * _rng and _body >= minBodyRatio * _rng
    if _shape and f_bull(_o, _c)
        CandleMatch.new(true, "Marubozu", "bullish", bar_index - offset, 1, "Marubozu: full body (" + f_pct(_body / _rng) + " of range) with wicks under " + f_pct(maxWickRatio) + " on both sides - buyers were in control from open to close.")
    else if _shape and f_bear(_o, _c)
        CandleMatch.new(true, "Marubozu", "bearish", bar_index - offset, 1, "Marubozu: full body (" + f_pct(_body / _rng) + " of range) with wicks under " + f_pct(maxWickRatio) + " on both sides - sellers were in control from open to close.")
    else
        f_none()

// @function Spinning Top — small body with wicks on both sides, roughly balanced.
// @param offset Bars back from the current bar to evaluate.
// @param maxBodyRatio Max body size as a fraction of range.
// @param minBodyRatio Min body size as a fraction of range (distinguishes it from a doji).
// @param minWickRatio Min size of each wick as a fraction of range.
// @returns CandleMatch
export detectSpinningTop(int offset = 0, float maxBodyRatio = 0.3, float minBodyRatio = 0.1, float minWickRatio = 0.3) =>
    _o = open[offset]
    _h = high[offset]
    _l = low[offset]
    _c = close[offset]
    _rng = f_rng(_h, _l)
    _body = f_body(_o, _c)
    _upW = f_upW(_o, _h, _c)
    _dnW = f_dnW(_o, _l, _c)
    _found = _body > minBodyRatio * _rng and _body <= maxBodyRatio * _rng and _upW >= minWickRatio * _rng and _dnW >= minWickRatio * _rng
    _desc = "Spinning Top: body " + f_pct(_body / _rng) + " of range with wicks of " + f_pct(_upW / _rng) + " and " + f_pct(_dnW / _rng) + " on either side - pushes both up and down failed, net indecision."
    _found ? CandleMatch.new(true, "Spinning Top", "neutral", bar_index - offset, 1, _desc) : f_none()

// @function Belt Hold — opens at one extreme with minimal opposite wick, closes far away.
// @param offset Bars back from the current bar to evaluate.
// @param maxOpeningWickRatio Max wick on the opening side as a fraction of range.
// @param minBodyRatio Min body size as a fraction of range.
// @returns CandleMatch
export detectBeltHold(int offset = 0, float maxOpeningWickRatio = 0.05, float minBodyRatio = 0.6) =>
    _o = open[offset]
    _h = high[offset]
    _l = low[offset]
    _c = close[offset]
    _rng = f_rng(_h, _l)
    _body = f_body(_o, _c)
    _upW = f_upW(_o, _h, _c)
    _dnW = f_dnW(_o, _l, _c)
    _bullBelt = f_bull(_o, _c) and _dnW <= maxOpeningWickRatio * _rng and _body >= minBodyRatio * _rng
    _bearBelt = f_bear(_o, _c) and _upW <= maxOpeningWickRatio * _rng and _body >= minBodyRatio * _rng
    if _bullBelt
        CandleMatch.new(true, "Bullish Belt Hold", "bullish", bar_index - offset, 1, "Bullish Belt Hold: opened at/near the low (opening wick " + f_pct(_dnW / _rng) + ") and closed strongly higher (body " + f_pct(_body / _rng) + " of range) - buyers were in control from the open.")
    else if _bearBelt
        CandleMatch.new(true, "Bearish Belt Hold", "bearish", bar_index - offset, 1, "Bearish Belt Hold: opened at/near the high (opening wick " + f_pct(_upW / _rng) + ") and closed strongly lower (body " + f_pct(_body / _rng) + " of range) - sellers were in control from the open.")
    else
        f_none()

// ---------------------------------------------------------------------------
// Two-bar patterns
// ---------------------------------------------------------------------------

// @function Engulfing — current body fully engulfs the prior body, opposite colors.
// @param offset Bars back from the current bar to evaluate.
// @returns CandleMatch
export detectEngulfing(int offset = 0) =>
    _o1 = open[offset + 1]
    _c1 = close[offset + 1]
    _o0 = open[offset]
    _c0 = close[offset]
    _prevBull = f_bull(_o1, _c1)
    _curBull = f_bull(_o0, _c0)
    _bullish = not _prevBull and _curBull and _o0 <= _c1 and _c0 >= _o1
    _bearish = _prevBull and not _curBull and _o0 >= _c1 and _c0 <= _o1
    if _bullish
        CandleMatch.new(true, "Bullish Engulfing", "bullish", bar_index - offset, 2, "Bullish Engulfing: this bar (open " + str.tostring(_o0, format.mintick) + ", close " + str.tostring(_c0, format.mintick) + ") fully engulfs the prior bearish body (open " + str.tostring(_o1, format.mintick) + ", close " + str.tostring(_c1, format.mintick) + ") - buyers erased the prior bar's loss and then some.")
    else if _bearish
        CandleMatch.new(true, "Bearish Engulfing", "bearish", bar_index - offset, 2, "Bearish Engulfing: this bar (open " + str.tostring(_o0, format.mintick) + ", close " + str.tostring(_c0, format.mintick) + ") fully engulfs the prior bullish body (open " + str.tostring(_o1, format.mintick) + ", close " + str.tostring(_c1, format.mintick) + ") - sellers erased the prior bar's gain and then some.")
    else
        f_none()

// @function Harami — current body fully contained within the prior body, opposite colors.
// @param offset Bars back from the current bar to evaluate.
// @returns CandleMatch
export detectHarami(int offset = 0) =>
    _o1 = open[offset + 1]
    _c1 = close[offset + 1]
    _o0 = open[offset]
    _c0 = close[offset]
    _body1 = f_body(_o1, _c1)
    _body0 = f_body(_o0, _c0)
    _hi1 = math.max(_o1, _c1)
    _lo1 = math.min(_o1, _c1)
    _hi0 = math.max(_o0, _c0)
    _lo0 = math.min(_o0, _c0)
    _contained = _hi0 <= _hi1 and _lo0 >= _lo1 and _body0 < _body1
    _prevBull = f_bull(_o1, _c1)
    if _contained and not _prevBull
        CandleMatch.new(true, "Bullish Harami", "bullish", bar_index - offset, 2, "Bullish Harami: this bar's body (open " + str.tostring(_o0, format.mintick) + ", close " + str.tostring(_c0, format.mintick) + ") sits fully inside the prior bearish body - the decline is stalling.")
    else if _contained and _prevBull
        CandleMatch.new(true, "Bearish Harami", "bearish", bar_index - offset, 2, "Bearish Harami: this bar's body (open " + str.tostring(_o0, format.mintick) + ", close " + str.tostring(_c0, format.mintick) + ") sits fully inside the prior bullish body - the advance is stalling.")
    else
        f_none()

// @function Harami Cross — a Harami where the current bar is also a doji.
// @param offset Bars back from the current bar to evaluate.
// @param maxBodyRatio Max current-bar body size as a fraction of its range, to qualify as a doji.
// @returns CandleMatch
export detectHaramiCross(int offset = 0, float maxBodyRatio = 0.1) =>
    _o1 = open[offset + 1]
    _c1 = close[offset + 1]
    _o0 = open[offset]
    _h0 = high[offset]
    _l0 = low[offset]
    _c0 = close[offset]
    _body1 = f_body(_o1, _c1)
    _body0 = f_body(_o0, _c0)
    _rng0 = f_rng(_h0, _l0)
    _hi1 = math.max(_o1, _c1)
    _lo1 = math.min(_o1, _c1)
    _hi0 = math.max(_o0, _c0)
    _lo0 = math.min(_o0, _c0)
    _contained = _hi0 <= _hi1 and _lo0 >= _lo1 and _body0 < _body1
    _isDoji = _body0 <= maxBodyRatio * _rng0
    _prevBull = f_bull(_o1, _c1)
    if _contained and _isDoji and not _prevBull
        CandleMatch.new(true, "Bullish Harami Cross", "bullish", bar_index - offset, 2, "Bullish Harami Cross: this bar is a doji (body " + f_pct(_body0 / _rng0) + " of its range) sitting fully inside the prior bearish body - the decline has stalled hard.")
    else if _contained and _isDoji and _prevBull
        CandleMatch.new(true, "Bearish Harami Cross", "bearish", bar_index - offset, 2, "Bearish Harami Cross: this bar is a doji (body " + f_pct(_body0 / _rng0) + " of its range) sitting fully inside the prior bullish body - the advance has stalled hard.")
    else
        f_none()

// @function Piercing Line / Dark Cloud Cover — current bar opens beyond the prior extreme and closes past its midpoint.
// @param offset Bars back from the current bar to evaluate.
// @param minPenetration Min fraction of the prior body the current close must penetrate.
// @returns CandleMatch
export detectPiercingDarkCloud(int offset = 0, float minPenetration = 0.5) =>
    _o1 = open[offset + 1]
    _c1 = close[offset + 1]
    _o0 = open[offset]
    _c0 = close[offset]
    _prevBull = f_bull(_o1, _c1)
    _curBull = f_bull(_o0, _c0)
    _piercingLevel = _c1 + minPenetration * (_o1 - _c1)
    _darkCloudLevel = _c1 - minPenetration * (_c1 - _o1)
    _piercing = not _prevBull and _curBull and _o0 < _c1 and _c0 > _piercingLevel and _c0 < _o1
    _darkCloud = _prevBull and not _curBull and _o0 > _c1 and _c0 < _darkCloudLevel and _c0 > _o1
    if _piercing
        CandleMatch.new(true, "Piercing Line", "bullish", bar_index - offset, 2, "Piercing Line: opened at " + str.tostring(_o0, format.mintick) + " (below the prior close of " + str.tostring(_c1, format.mintick) + ") and closed at " + str.tostring(_c0, format.mintick) + ", above the midpoint of the prior bearish body - buyers erased more than half the prior decline.")
    else if _darkCloud
        CandleMatch.new(true, "Dark Cloud Cover", "bearish", bar_index - offset, 2, "Dark Cloud Cover: opened at " + str.tostring(_o0, format.mintick) + " (above the prior close of " + str.tostring(_c1, format.mintick) + ") and closed at " + str.tostring(_c0, format.mintick) + ", below the midpoint of the prior bullish body - sellers erased more than half the prior advance.")
    else
        f_none()

// @function Tweezer Top / Bottom — two bars sharing near-identical highs (top) or lows (bottom).
// @param offset Bars back from the current bar to evaluate.
// @param tolerance Max difference between the two highs/lows, as a fraction of the larger bar's range.
// @returns CandleMatch
export detectTweezer(int offset = 0, float tolerance = 0.1) =>
    _h1 = high[offset + 1]
    _l1 = low[offset + 1]
    _h0 = high[offset]
    _l0 = low[offset]
    _rng1 = f_rng(_h1, _l1)
    _rng0 = f_rng(_h0, _l0)
    _tol = tolerance * math.max(_rng0, _rng1)
    _topMatch = math.abs(_h0 - _h1) <= _tol
    _bottomMatch = math.abs(_l0 - _l1) <= _tol
    if _topMatch
        CandleMatch.new(true, "Tweezer Top", "bearish", bar_index - offset, 2, "Tweezer Top: this bar's high (" + str.tostring(_h0, format.mintick) + ") matches the prior bar's high (" + str.tostring(_h1, format.mintick) + ") within tolerance - resistance held on both attempts.")
    else if _bottomMatch
        CandleMatch.new(true, "Tweezer Bottom", "bullish", bar_index - offset, 2, "Tweezer Bottom: this bar's low (" + str.tostring(_l0, format.mintick) + ") matches the prior bar's low (" + str.tostring(_l1, format.mintick) + ") within tolerance - support held on both attempts.")
    else
        f_none()

// @function Kicker — gap between two opposite-colored bars with no body overlap.
// @param offset Bars back from the current bar to evaluate.
// @returns CandleMatch
export detectKicker(int offset = 0) =>
    _o1 = open[offset + 1]
    _c1 = close[offset + 1]
    _o0 = open[offset]
    _c0 = close[offset]
    _prevBull = f_bull(_o1, _c1)
    _curBull = f_bull(_o0, _c0)
    _bullishKicker = not _prevBull and _curBull and _o0 >= math.max(_o1, _c1)
    _bearishKicker = _prevBull and not _curBull and _o0 <= math.min(_o1, _c1)
    if _bullishKicker
        CandleMatch.new(true, "Bullish Kicker", "bullish", bar_index - offset, 2, "Bullish Kicker: this bar opened at " + str.tostring(_o0, format.mintick) + ", at or above the prior bar's entire range (" + str.tostring(math.min(_o1, _c1), format.mintick) + "-" + str.tostring(math.max(_o1, _c1), format.mintick) + ") with no overlap - an abrupt reversal in sentiment.")
    else if _bearishKicker
        CandleMatch.new(true, "Bearish Kicker", "bearish", bar_index - offset, 2, "Bearish Kicker: this bar opened at " + str.tostring(_o0, format.mintick) + ", at or below the prior bar's entire range (" + str.tostring(math.min(_o1, _c1), format.mintick) + "-" + str.tostring(math.max(_o1, _c1), format.mintick) + ") with no overlap - an abrupt reversal in sentiment.")
    else
        f_none()

// ---------------------------------------------------------------------------
// Three-bar and longer patterns
// ---------------------------------------------------------------------------

// @function Morning Star / Evening Star — small-bodied middle bar gapped away from two full-bodied outer bars.
// @param offset Bars back from the current bar to evaluate.
// @param starMaxBodyRatio Max middle-bar body as a fraction of its range.
// @param minBodyRatio Min outer-bar body as a fraction of its range.
// @param minPenetration Min fraction of the first bar's body the third bar's close must penetrate.
// @returns CandleMatch
export detectStar(int offset = 0, float starMaxBodyRatio = 0.3, float minBodyRatio = 0.6, float minPenetration = 0.5) =>
    _o2 = open[offset + 2]
    _c2 = close[offset + 2]
    _h2 = high[offset + 2]
    _l2 = low[offset + 2]
    _o1 = open[offset + 1]
    _c1 = close[offset + 1]
    _h1 = high[offset + 1]
    _l1 = low[offset + 1]
    _o0 = open[offset]
    _c0 = close[offset]
    _rng2 = f_rng(_h2, _l2)
    _rng1 = f_rng(_h1, _l1)
    _body2 = f_body(_o2, _c2)
    _body1 = f_body(_o1, _c1)
    _bear2 = f_bear(_o2, _c2)
    _bull2 = f_bull(_o2, _c2)
    _bull0 = f_bull(_o0, _c0)
    _bear0 = f_bear(_o0, _c0)
    _smallStar = _body1 <= starMaxBodyRatio * _rng1
    _bigBody2 = _body2 >= minBodyRatio * _rng2
    _gapDownStar = math.max(_o1, _c1) < _c2
    _gapUpStar = math.min(_o1, _c1) > _c2
    _morningLevel = _c2 + minPenetration * (_o2 - _c2)
    _eveningLevel = _c2 - minPenetration * (_c2 - _o2)
    _morning = _bear2 and _bigBody2 and _smallStar and _gapDownStar and _bull0 and _c0 > _morningLevel
    _evening = _bull2 and _bigBody2 and _smallStar and _gapUpStar and _bear0 and _c0 < _eveningLevel
    if _morning
        CandleMatch.new(true, "Morning Star", "bullish", bar_index - offset, 3, "Morning Star: a large bearish bar, a small bar (" + f_pct(_body1 / _rng1) + " of its range) gapped below it, then a bullish bar closing at " + str.tostring(_c0, format.mintick) + " - back above the midpoint of the first bar. Classic three-bar bottoming reversal.")
    else if _evening
        CandleMatch.new(true, "Evening Star", "bearish", bar_index - offset, 3, "Evening Star: a large bullish bar, a small bar (" + f_pct(_body1 / _rng1) + " of its range) gapped above it, then a bearish bar closing at " + str.tostring(_c0, format.mintick) + " - back below the midpoint of the first bar. Classic three-bar topping reversal.")
    else
        f_none()

// @function Morning Doji Star / Evening Doji Star — Star variant where the middle bar is specifically a doji.
// @param offset Bars back from the current bar to evaluate.
// @param dojiMaxBodyRatio Max middle-bar body as a fraction of its range, to qualify as a doji.
// @param minBodyRatio Min outer-bar body as a fraction of its range.
// @param minPenetration Min fraction of the first bar's body the third bar's close must penetrate.
// @returns CandleMatch
export detectDojiStar(int offset = 0, float dojiMaxBodyRatio = 0.1, float minBodyRatio = 0.6, float minPenetration = 0.5) =>
    _o2 = open[offset + 2]
    _c2 = close[offset + 2]
    _h2 = high[offset + 2]
    _l2 = low[offset + 2]
    _o1 = open[offset + 1]
    _c1 = close[offset + 1]
    _h1 = high[offset + 1]
    _l1 = low[offset + 1]
    _o0 = open[offset]
    _c0 = close[offset]
    _rng2 = f_rng(_h2, _l2)
    _rng1 = f_rng(_h1, _l1)
    _body2 = f_body(_o2, _c2)
    _body1 = f_body(_o1, _c1)
    _bear2 = f_bear(_o2, _c2)
    _bull2 = f_bull(_o2, _c2)
    _bull0 = f_bull(_o0, _c0)
    _bear0 = f_bear(_o0, _c0)
    _isDojiStar = _body1 <= dojiMaxBodyRatio * _rng1
    _bigBody2 = _body2 >= minBodyRatio * _rng2
    _gapDownStar = math.max(_o1, _c1) < _c2
    _gapUpStar = math.min(_o1, _c1) > _c2
    _morningLevel = _c2 + minPenetration * (_o2 - _c2)
    _eveningLevel = _c2 - minPenetration * (_c2 - _o2)
    _morning = _bear2 and _bigBody2 and _isDojiStar and _gapDownStar and _bull0 and _c0 > _morningLevel
    _evening = _bull2 and _bigBody2 and _isDojiStar and _gapUpStar and _bear0 and _c0 < _eveningLevel
    if _morning
        CandleMatch.new(true, "Morning Doji Star", "bullish", bar_index - offset, 3, "Morning Doji Star: a large bearish bar, a doji (body " + f_pct(_body1 / _rng1) + " of its range) gapped below it, then a bullish bar closing back above its midpoint - a stronger version of the Morning Star.")
    else if _evening
        CandleMatch.new(true, "Evening Doji Star", "bearish", bar_index - offset, 3, "Evening Doji Star: a large bullish bar, a doji (body " + f_pct(_body1 / _rng1) + " of its range) gapped above it, then a bearish bar closing back below its midpoint - a stronger version of the Evening Star.")
    else
        f_none()

// @function Three White Soldiers / Three Black Crows — three consecutive same-direction bars, each opening within the prior body and closing beyond the prior close.
// @param offset Bars back from the current bar to evaluate.
// @param minBodyRatio Min body size of each bar as a fraction of its own range.
// @returns CandleMatch
export detectThreeSoldiersCrows(int offset = 0, float minBodyRatio = 0.5) =>
    _o2 = open[offset + 2]
    _c2 = close[offset + 2]
    _h2 = high[offset + 2]
    _l2 = low[offset + 2]
    _o1 = open[offset + 1]
    _c1 = close[offset + 1]
    _h1 = high[offset + 1]
    _l1 = low[offset + 1]
    _o0 = open[offset]
    _c0 = close[offset]
    _h0 = high[offset]
    _l0 = low[offset]
    _rng2 = f_rng(_h2, _l2)
    _rng1 = f_rng(_h1, _l1)
    _rng0 = f_rng(_h0, _l0)
    _body2 = f_body(_o2, _c2)
    _body1 = f_body(_o1, _c1)
    _body0 = f_body(_o0, _c0)
    _allBull = f_bull(_o2, _c2) and f_bull(_o1, _c1) and f_bull(_o0, _c0)
    _allBear = f_bear(_o2, _c2) and f_bear(_o1, _c1) and f_bear(_o0, _c0)
    _bigBodies = _body2 >= minBodyRatio * _rng2 and _body1 >= minBodyRatio * _rng1 and _body0 >= minBodyRatio * _rng0
    _opensInPrior = _o1 > math.min(_o2, _c2) and _o1 < math.max(_o2, _c2) and _o0 > math.min(_o1, _c1) and _o0 < math.max(_o1, _c1)
    _soldiers = _allBull and _bigBodies and _opensInPrior and _c1 > _c2 and _c0 > _c1
    _crows = _allBear and _bigBodies and _opensInPrior and _c1 < _c2 and _c0 < _c1
    if _soldiers
        CandleMatch.new(true, "Three White Soldiers", "bullish", bar_index - offset, 3, "Three White Soldiers: three consecutive bullish bars, each opening inside the prior body and closing higher (closes " + str.tostring(_c2, format.mintick) + " -> " + str.tostring(_c1, format.mintick) + " -> " + str.tostring(_c0, format.mintick) + ") - steady, sustained buying.")
    else if _crows
        CandleMatch.new(true, "Three Black Crows", "bearish", bar_index - offset, 3, "Three Black Crows: three consecutive bearish bars, each opening inside the prior body and closing lower (closes " + str.tostring(_c2, format.mintick) + " -> " + str.tostring(_c1, format.mintick) + " -> " + str.tostring(_c0, format.mintick) + ") - steady, sustained selling.")
    else
        f_none()

// @function Three Inside Up / Down — a Harami followed by a third bar closing beyond the first bar's open.
// @param offset Bars back from the current bar to evaluate.
// @returns CandleMatch
export detectThreeInside(int offset = 0) =>
    _o2 = open[offset + 2]
    _c2 = close[offset + 2]
    _o1 = open[offset + 1]
    _c1 = close[offset + 1]
    _o0 = open[offset]
    _c0 = close[offset]
    _body2 = f_body(_o2, _c2)
    _body1 = f_body(_o1, _c1)
    _hi2 = math.max(_o2, _c2)
    _lo2 = math.min(_o2, _c2)
    _hi1 = math.max(_o1, _c1)
    _lo1 = math.min(_o1, _c1)
    _haramiContained = _hi1 <= _hi2 and _lo1 >= _lo2 and _body1 < _body2
    _up = f_bear(_o2, _c2) and _haramiContained and f_bull(_o0, _c0) and _c0 > _o2
    _down = f_bull(_o2, _c2) and _haramiContained and f_bear(_o0, _c0) and _c0 < _o2
    if _up
        CandleMatch.new(true, "Three Inside Up", "bullish", bar_index - offset, 3, "Three Inside Up: a bearish bar, a small bar contained inside it, then a bullish bar closing at " + str.tostring(_c0, format.mintick) + " - above the first bar's open (" + str.tostring(_o2, format.mintick) + "). Confirms the harami's reversal signal.")
    else if _down
        CandleMatch.new(true, "Three Inside Down", "bearish", bar_index - offset, 3, "Three Inside Down: a bullish bar, a small bar contained inside it, then a bearish bar closing at " + str.tostring(_c0, format.mintick) + " - below the first bar's open (" + str.tostring(_o2, format.mintick) + "). Confirms the harami's reversal signal.")
    else
        f_none()

// @function Three Outside Up / Down — an Engulfing followed by a third bar extending the move.
// @param offset Bars back from the current bar to evaluate.
// @returns CandleMatch
export detectThreeOutside(int offset = 0) =>
    _o2 = open[offset + 2]
    _c2 = close[offset + 2]
    _o1 = open[offset + 1]
    _c1 = close[offset + 1]
    _o0 = open[offset]
    _c0 = close[offset]
    _prevBull1 = f_bull(_o2, _c2)
    _curBull1 = f_bull(_o1, _c1)
    _engulfUp = not _prevBull1 and _curBull1 and _o1 <= _c2 and _c1 >= _o2
    _engulfDown = _prevBull1 and not _curBull1 and _o1 >= _c2 and _c1 <= _o2
    _up = _engulfUp and f_bull(_o0, _c0) and _c0 > _c1
    _down = _engulfDown and f_bear(_o0, _c0) and _c0 < _c1
    if _up
        CandleMatch.new(true, "Three Outside Up", "bullish", bar_index - offset, 3, "Three Outside Up: a bullish engulfing bar followed by another bullish bar extending the move to a close of " + str.tostring(_c0, format.mintick) + " - confirms the engulfing reversal.")
    else if _down
        CandleMatch.new(true, "Three Outside Down", "bearish", bar_index - offset, 3, "Three Outside Down: a bearish engulfing bar followed by another bearish bar extending the move to a close of " + str.tostring(_c0, format.mintick) + " - confirms the engulfing reversal.")
    else
        f_none()

// @function Abandoned Baby — a Doji Star gapped clear of both neighbors on both sides (full gap, no wick overlap).
// @param offset Bars back from the current bar to evaluate.
// @param dojiMaxBodyRatio Max middle-bar body as a fraction of its range, to qualify as a doji.
// @param minBodyRatio Min outer-bar body as a fraction of its range.
// @returns CandleMatch
export detectAbandonedBaby(int offset = 0, float dojiMaxBodyRatio = 0.1, float minBodyRatio = 0.6) =>
    _o2 = open[offset + 2]
    _c2 = close[offset + 2]
    _h2 = high[offset + 2]
    _l2 = low[offset + 2]
    _o1 = open[offset + 1]
    _c1 = close[offset + 1]
    _h1 = high[offset + 1]
    _l1 = low[offset + 1]
    _o0 = open[offset]
    _c0 = close[offset]
    _h0 = high[offset]
    _l0 = low[offset]
    _rng2 = f_rng(_h2, _l2)
    _rng1 = f_rng(_h1, _l1)
    _rng0 = f_rng(_h0, _l0)
    _body2 = f_body(_o2, _c2)
    _body1 = f_body(_o1, _c1)
    _body0 = f_body(_o0, _c0)
    _isDoji1 = _body1 <= dojiMaxBodyRatio * _rng1
    _bigBody2 = _body2 >= minBodyRatio * _rng2
    _bigBody0 = _body0 >= minBodyRatio * _rng0
    _bullish = f_bear(_o2, _c2) and _bigBody2 and _isDoji1 and _h1 < _l2 and f_bull(_o0, _c0) and _bigBody0 and _l0 > _h1
    _bearish = f_bull(_o2, _c2) and _bigBody2 and _isDoji1 and _l1 > _h2 and f_bear(_o0, _c0) and _bigBody0 and _h0 < _l1
    if _bullish
        CandleMatch.new(true, "Bullish Abandoned Baby", "bullish", bar_index - offset, 3, "Bullish Abandoned Baby: a bearish bar, a doji gapped clear below it (gap below " + str.tostring(_l2, format.mintick) + "), then a bullish bar gapped clear above the doji (gap above " + str.tostring(_h1, format.mintick) + ") - a rare, high-conviction reversal with gaps on both sides.")
    else if _bearish
        CandleMatch.new(true, "Bearish Abandoned Baby", "bearish", bar_index - offset, 3, "Bearish Abandoned Baby: a bullish bar, a doji gapped clear above it (gap above " + str.tostring(_h2, format.mintick) + "), then a bearish bar gapped clear below the doji (gap below " + str.tostring(_l1, format.mintick) + ") - a rare, high-conviction reversal with gaps on both sides.")
    else
        f_none()

// @function Rising Three Methods / Falling Three Methods — a long bar, three small opposite-direction bars contained within its range, then a continuation bar. Spans 5 bars.
// @param offset Bars back from the current bar to evaluate.
// @param minLeadBodyRatio Min body size of the first (leading) bar as a fraction of its range.
// @param maxInsideBodyRatio Max body size of each of the three inside bars, as a fraction of the leading bar's range.
// @returns CandleMatch
export detectThreeMethods(int offset = 0, float minLeadBodyRatio = 0.6, float maxInsideBodyRatio = 0.5) =>
    _o4 = open[offset + 4]
    _c4 = close[offset + 4]
    _h4 = high[offset + 4]
    _l4 = low[offset + 4]
    _o3 = open[offset + 3]
    _c3 = close[offset + 3]
    _h3 = high[offset + 3]
    _l3 = low[offset + 3]
    _o2 = open[offset + 2]
    _c2 = close[offset + 2]
    _h2 = high[offset + 2]
    _l2 = low[offset + 2]
    _o1 = open[offset + 1]
    _c1 = close[offset + 1]
    _h1 = high[offset + 1]
    _l1 = low[offset + 1]
    _o0 = open[offset]
    _c0 = close[offset]
    _rng4 = f_rng(_h4, _l4)
    _body4 = f_body(_o4, _c4)
    _bigLead = _body4 >= minLeadBodyRatio * _rng4
    _contained = _h3 <= _h4 and _l3 >= _l4 and _h2 <= _h4 and _l2 >= _l4 and _h1 <= _h4 and _l1 >= _l4
    _smallInside = f_body(_o3, _c3) <= maxInsideBodyRatio * _rng4 and f_body(_o2, _c2) <= maxInsideBodyRatio * _rng4 and f_body(_o1, _c1) <= maxInsideBodyRatio * _rng4
    _rising = f_bull(_o4, _c4) and _bigLead and _contained and _smallInside and f_bear(_o3, _c3) and f_bear(_o2, _c2) and f_bear(_o1, _c1) and f_bull(_o0, _c0) and _c0 > _c4
    _falling = f_bear(_o4, _c4) and _bigLead and _contained and _smallInside and f_bull(_o3, _c3) and f_bull(_o2, _c2) and f_bull(_o1, _c1) and f_bear(_o0, _c0) and _c0 < _c4
    if _rising
        CandleMatch.new(true, "Rising Three Methods", "bullish", bar_index - offset, 5, "Rising Three Methods: a strong bullish bar, three small bars contained inside its range, then a bullish bar closing at " + str.tostring(_c0, format.mintick) + " - above the first bar's close (" + str.tostring(_c4, format.mintick) + "). The uptrend paused, didn't reverse, and resumed.")
    else if _falling
        CandleMatch.new(true, "Falling Three Methods", "bearish", bar_index - offset, 5, "Falling Three Methods: a strong bearish bar, three small bars contained inside its range, then a bearish bar closing at " + str.tostring(_c0, format.mintick) + " - below the first bar's close (" + str.tostring(_c4, format.mintick) + "). The downtrend paused, didn't reverse, and resumed.")
    else
        f_none()

// @function Stick Sandwich — two bearish bars with matching closes sandwiching one bullish bar.
// @param offset Bars back from the current bar to evaluate.
// @param closeTolerance Max difference between the outer closes, as a fraction of the larger bar's range.
// @returns CandleMatch
export detectStickSandwich(int offset = 0, float closeTolerance = 0.1) =>
    _o2 = open[offset + 2]
    _c2 = close[offset + 2]
    _h2 = high[offset + 2]
    _l2 = low[offset + 2]
    _o1 = open[offset + 1]
    _c1 = close[offset + 1]
    _o0 = open[offset]
    _c0 = close[offset]
    _h0 = high[offset]
    _l0 = low[offset]
    _rng2 = f_rng(_h2, _l2)
    _rng0 = f_rng(_h0, _l0)
    _tol = closeTolerance * math.max(_rng2, _rng0)
    _closesMatch = math.abs(_c0 - _c2) <= _tol
    _found = f_bear(_o2, _c2) and f_bull(_o1, _c1) and f_bear(_o0, _c0) and _closesMatch and _c1 > math.max(_o2, _o0)
    _desc = "Stick Sandwich: two bearish bars with matching closes (" + str.tostring(_c2, format.mintick) + " and " + str.tostring(_c0, format.mintick) + ") sandwich one bullish bar - sellers failed to push the close any lower on the second attempt."
    _found ? CandleMatch.new(true, "Stick Sandwich", "bullish", bar_index - offset, 3, _desc) : f_none()
````
