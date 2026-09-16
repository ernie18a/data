<!-- tradingview-pine-id: PUB;5222d070f46547b29e38b2c4056e3a92 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Pattern Atlas: Candlestick Indicator [AxeAlgo]

Source: https://www.tradingview.com/script/mQufFIYf-Pattern-Atlas-Candlestick-Indicator-AxeAlgo/

## Description

Pattern Atlas: Candlestick Indicator [AxeAlgo]
Companion indicator to Pattern Atlas : Candlestick [AxeAlgo] (Library #1 of the AxeAlgo Pattern Atlas)

WHAT THIS INDICATOR IS

This is a complete candlestick pattern scanner built on top of the Pattern Atlas : Candlestick [AxeAlgo] library — 23 classical candlestick patterns, detected on every bar and turned into on-chart highlighting, a live scanner table, and alerts. It doesn't implement any pattern math itself; every detection is delegated to the library's detect*() functions, so what you see here is exactly what that library finds, with nothing added or reinterpreted.

Candlestick reading is one of the oldest tools in technical analysis, tracing back to Steve Nison's work bringing Japanese candlestick charting to Western traders. The 23 patterns here follow that standard catalog (cross-checked against TA-Lib's CDL* function list), so anyone who already knows what a Morning Star or a Bullish Engulfing bar looks like will recognize exactly what's being flagged.

THE 23 PATTERNS IT SCANS

Single-bar patterns (9): Doji, Long-Legged Doji, Dragonfly Doji, Gravestone Doji, Hammer / Hanging Man, Inverted Hammer / Shooting Star, Marubozu, Spinning Top, Belt Hold.

Two-bar patterns (6): Engulfing, Harami, Harami Cross, Piercing Line / Dark Cloud Cover, Tweezer Top / Bottom, Kicker.

Three-bar-and-longer patterns (8): Morning / Evening Star, Morning / Evening Doji Star, Three Soldiers / Crows, Three Inside Up / Down, Three Outside Up / Down, Abandoned Baby, Rising / Falling Three Methods (the one pattern spanning 5 bars), Stick Sandwich.

READING THE CHART

Each matched pattern gets a box drawn around the exact bars it spans, colored gold for bullish, pale gold-white for bearish, and bright gold for neutral (indecision) patterns — colors are user-configurable. On top of that, a "pin" marker appears at the bar: bullish pins hang below the bar, bearish pins sit above it, and neutral patterns get a plain floating gem with no stem, since indecision doesn't have a direction to anchor to. Hovering any pin or gem shows the full description of everything that matched on that bar, including a measured strength percentage for each one — not just the pattern name repeated back at you.

Strength is a generic, direction-based read on how decisively the bar closed within its own high-low range (near the high for a bullish match, near the low for a bearish one, or a small body relative to the range for a neutral one) — a rough, pattern-agnostic proxy, not a bespoke ratio breakdown per pattern, since that level of internal detail isn't something the library exposes.

THE SCANNER TABLE

A table lists all 23 patterns grouped by category, with a live status column showing each one's current match percentage (or a dash when nothing's matching on the current bar). Position, text size, and whether it's shown at all are all configurable. This table is intentionally live — it reflects the forming bar in real time rather than waiting for the bar to close, since it's meant as a "what's happening right now" readout rather than a persisted signal.

FILTERS AND SETTINGS

Every pattern has its own on/off checkbox, and each of the three categories (Single-Bar, Two-Bar, Three-Bar+) has a master switch above its checkboxes to turn the whole group off in one click.

Three additional filters are available, all off by default so the scanner stays an unbiased detector unless you opt in:
- Volume confirmation — requires a match to occur on at least a chosen multiple of its own trailing average volume before it counts.
- Trend context — requires bullish matches to occur against a downtrend and bearish matches against an uptrend (the classical reading that a reversal candle means more against the trend it's reversing than in the middle of a random chop). Neutral patterns are never filtered by this, since they don't imply a direction.
- Minimum strength — hides matches below a chosen strength percentage.

These filters affect what's drawn on the chart and what feeds the pin/gem tooltips. They do not affect the scanner table, which always shows the library's raw, unfiltered read of the current bar, and they do not affect the per-pattern alerts described below, which fire independently of the visual display settings.

ALERTS

Every pattern has its own alert condition available in TradingView's Create Alert dialog, plus three combined conditions (any bullish pattern, any bearish pattern, any neutral pattern), plus one dynamic alert with a full message listing every pattern that matched, grouped by direction, with each one's measured description and strength.

A NOTE ON REPAINTING

Every box, pin, gem, and alert is gated on the bar actually having closed — nothing here fires or gets drawn off a still-forming bar, regardless of your alert-frequency setting in TradingView's dialog. The one exception is the scanner table, which is deliberately live so it can answer "what's happening on this bar right now" — that's a readout, not a persisted signal, and it's expected to change as the current bar develops.

PART OF A LARGER SERIES

This indicator is the companion to Library #1 of the AxeAlgo Pattern Atlas — a planned set of Pine libraries splitting pattern detection by the method actually used to find each kind of pattern: candlestick shape (this one), classical chart/geometric patterns (Library #2), harmonic Fibonacci-ratio patterns (Library #3), and market-structure concepts (order blocks, liquidity, Wyckoff-style events). Each library has, or will have, its own companion scanner indicator built the same way this one is.

DISCLAIMER

This indicator is a technical analysis tool for identifying classical candlestick shapes in historical and live price data. It does not predict future price movement, and a detected pattern — including its measured strength — is a description of past price action, not a signal guaranteed to repeat. Nothing in this script constitutes financial advice. Always combine pattern recognition with your own risk management and broader analysis before making any trading decision.

---

## Source Code

````pine
//@version=6
// Consumes PatternCandlestick — plots signals and fires alerts from its detect*() calls.
// One-time setup: open pattern_candlestick.pine in the Pine Editor, Save, then
// Publish script -> Library -> Public. Once published, confirm the version number
// below matches what TradingView shows (bump it after every republish of the library).
indicator("Pattern Atlas: Candlestick Indicator [AxeAlgo]", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500)
import AxeAlgo/Pattern_Atlas_Candlestick/1 as cdl
// Bundles the per-bar scan results by direction so the label tooltips can
// join every matched description without threading three separate arrays
// through every f_collect() call.
type Collector
    array<string> descBull
    array<string> descBear
    array<string> descNeut

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------
grpSingle  = "Single-Bar Patterns"
grpTwo     = "Two-Bar Patterns"
grpThree   = "Three-Bar+ Patterns"
grpDisplay = "Display"

// A master switch per category, above the per-pattern checkboxes, so a whole
// group can be turned off in one click without hunting down each toggle.
enableSingle = input.bool(true, "Enable Single-Bar Patterns", group = grpSingle)
showDoji_raw                 = input.bool(false, "Doji", group = grpSingle)
showLongLeggedDoji_raw       = input.bool(false, "Long-Legged Doji", group = grpSingle)
showDragonflyDoji_raw        = input.bool(false, "Dragonfly Doji", group = grpSingle)
showGravestoneDoji_raw       = input.bool(false, "Gravestone Doji", group = grpSingle)
showHammerHangingMan_raw     = input.bool(false, "Hammer / Hanging Man", group = grpSingle)
showInvHammerShootingStar_raw = input.bool(false, "Inverted Hammer / Shooting Star", group = grpSingle)
showMarubozu_raw              = input.bool(false, "Marubozu", group = grpSingle)
showSpinningTop_raw            = input.bool(false, "Spinning Top", group = grpSingle)
showBeltHold_raw                = input.bool(false, "Belt Hold", group = grpSingle)

enableTwo = input.bool(true, "Enable Two-Bar Patterns", group = grpTwo)
showEngulfing_raw            = input.bool(false, "Engulfing", group = grpTwo)
showHarami_raw               = input.bool(false, "Harami", group = grpTwo)
showHaramiCross_raw          = input.bool(false, "Harami Cross", group = grpTwo)
showPiercingDarkCloud_raw    = input.bool(false, "Piercing Line / Dark Cloud Cover", group = grpTwo)
showTweezer_raw              = input.bool(false, "Tweezer Top / Bottom", group = grpTwo)
showKicker_raw               = input.bool(false, "Kicker", group = grpTwo)

enableThree = input.bool(true, "Enable Three-Bar+ Patterns", group = grpThree)
showStar_raw                 = input.bool(false, "Morning / Evening Star", group = grpThree)
showDojiStar_raw             = input.bool(false, "Morning / Evening Doji Star", group = grpThree)
showThreeSoldiersCrows_raw   = input.bool(false, "Three Soldiers / Crows", group = grpThree)
showThreeInside_raw          = input.bool(false, "Three Inside Up / Down", group = grpThree)
showThreeOutside_raw         = input.bool(false, "Three Outside Up / Down", group = grpThree)
showAbandonedBaby_raw        = input.bool(false, "Abandoned Baby", group = grpThree)
showThreeMethods_raw         = input.bool(false, "Rising / Falling Three Methods", group = grpThree)
showStickSandwich_raw        = input.bool(false, "Stick Sandwich", group = grpThree)

showBoxes = input.bool(true, "Highlight pattern bars with a box", group = grpDisplay)
showSignals = input.bool(true, "Show pin/gem signals", group = grpDisplay)
useVolumeFilter = input.bool(false, "Require above-average volume", group = grpDisplay, tooltip = "Only counts a match if it occurred on at least the chosen multiple of its own trailing average volume. Off by default since not every instrument has reliable volume data.")
volumeAvgLength = input.int(20, "Volume average length", minval = 1, group = grpDisplay)
volumeMultiplier = input.float(1.5, "Minimum volume multiple", minval = 0.1, step = 0.1, group = grpDisplay)
useTrendFilter = input.bool(false, "Require trend context", group = grpDisplay, tooltip = "When enabled, bullish patterns only count while price is below its trend average (a downtrend to reverse), and bearish patterns only count while price is above it (an uptrend to reverse) - the classical reading that a reversal candle means more against the trend it's reversing than in the middle of a random chop. Neutral patterns (the doji family, Spinning Top) are never filtered, since they don't imply a direction. Off by default, so the scanner stays an unbiased detector unless you opt in.")
trendMaLength = input.int(50, "Trend average length", minval = 1, group = grpDisplay)
minStrength = input.int(0, "Minimum pattern strength to show (%)", minval = 0, maxval = 100, group = grpDisplay, tooltip = "Filters out marginal matches. Strength is a generic proxy - how decisively the completing bar closed within its own high-low range (bullish: near the high, bearish: near the low, neutral: a small body relative to the range) - not a per-pattern ratio breakdown, since the library doesn't expose that level of internal detail.")
showTable = input.bool(true, "Show pattern scanner table", group = grpDisplay)
tablePosStr = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpDisplay)
tableSizeStr = input.string("Normal", "Table text size", options = ["Small", "Normal", "Large", "Huge"], group = grpDisplay)
// AxeAlgo Royal Gold & White — classic gold (bullish), pale gold-white (bearish), bright gold (neutral)
bullColor = input.color(color.new(#D4AF37, 0), "Bullish marker color", group = grpDisplay)
bearColor = input.color(color.new(#FFF8E7, 0), "Bearish marker color", group = grpDisplay)
neutColor = input.color(color.new(#FFD400, 0), "Neutral marker color", group = grpDisplay)

tablePos = tablePosStr == "Top Right" ? position.top_right : tablePosStr == "Top Left" ? position.top_left : tablePosStr == "Bottom Right" ? position.bottom_right : position.bottom_left
catTextSize = tableSizeStr == "Small" ? size.tiny : tableSizeStr == "Normal" ? size.small : tableSizeStr == "Large" ? size.normal : size.large
rowTextSize = tableSizeStr == "Small" ? size.small : tableSizeStr == "Normal" ? size.normal : tableSizeStr == "Large" ? size.large : size.huge
titleTextSize = tableSizeStr == "Small" ? size.normal : tableSizeStr == "Normal" ? size.large : size.huge

// ---------------------------------------------------------------------------
// Detect — one call per library function
// ---------------------------------------------------------------------------
mDoji                = cdl.detectDoji()
mLongLeggedDoji       = cdl.detectLongLeggedDoji()
mDragonflyDoji        = cdl.detectDragonflyDoji()
mGravestoneDoji       = cdl.detectGravestoneDoji()
mHammerHangingMan     = cdl.detectHammerHangingMan()
mInvHammerShootingStar = cdl.detectInvertedHammerShootingStar()
mMarubozu             = cdl.detectMarubozu()
mSpinningTop          = cdl.detectSpinningTop()
mBeltHold             = cdl.detectBeltHold()

mEngulfing            = cdl.detectEngulfing()
mHarami               = cdl.detectHarami()
mHaramiCross          = cdl.detectHaramiCross()
mPiercingDarkCloud    = cdl.detectPiercingDarkCloud()
mTweezer              = cdl.detectTweezer()
mKicker               = cdl.detectKicker()

mStar                 = cdl.detectStar()
mDojiStar             = cdl.detectDojiStar()
mThreeSoldiersCrows   = cdl.detectThreeSoldiersCrows()
mThreeInside          = cdl.detectThreeInside()
mThreeOutside         = cdl.detectThreeOutside()
mAbandonedBaby        = cdl.detectAbandonedBaby()
mThreeMethods         = cdl.detectThreeMethods()
mStickSandwich        = cdl.detectStickSandwich()

// ---------------------------------------------------------------------------
// Volume confirmation — a single indicator-wide filter, checked on the
// completing bar's own volume against its trailing average. Off by default.
// ---------------------------------------------------------------------------
volAvg = ta.sma(volume, volumeAvgLength)
volOk = not useVolumeFilter or volume >= volAvg * volumeMultiplier

// ---------------------------------------------------------------------------
// Trend context — another single indicator-wide, opt-in filter. Bullish
// patterns only count against a downtrend (price below its own trend
// average), bearish only against an uptrend (price above it). Neutral
// patterns are never filtered, since indecision doesn't have a direction to
// check against a trend.
// ---------------------------------------------------------------------------
trendMa = ta.sma(close, trendMaLength)
f_trendOk(_m) =>
    not useTrendFilter or _m.direction == "neutral" or (_m.direction == "bullish" and close < trendMa) or (_m.direction == "bearish" and close > trendMa)

// ---------------------------------------------------------------------------
// Strength — a generic, pattern-agnostic proxy: how decisively the
// completing bar closed within its own high-low range. CandleMatch doesn't
// expose per-pattern internal ratios (body size, wick multiples, etc.) the
// way the Geometric library's breakoutLevel/pivotPrices do, so this reads
// directly off the bar's own OHLC instead of trying to reproduce each
// pattern's internal math at the indicator layer. Bullish: close near the
// bar's high scores higher. Bearish: close near the low scores higher.
// Neutral (the doji family, Spinning Top): a smaller body relative to the
// range scores higher, since that's what makes those patterns "more
// indecisive" in the first place.
// ---------------------------------------------------------------------------
f_strength(_m) =>
    if not _m.found
        0.0
    else
        _range = high - low
        if _range <= 0
            50.0
        else if _m.direction == "bullish"
            (close - low) / _range * 100
        else if _m.direction == "bearish"
            (high - close) / _range * 100
        else
            (1 - math.abs(close - open) / _range) * 100

sDoji = f_strength(mDoji)
sLongLeggedDoji = f_strength(mLongLeggedDoji)
sDragonflyDoji = f_strength(mDragonflyDoji)
sGravestoneDoji = f_strength(mGravestoneDoji)
sHammerHangingMan = f_strength(mHammerHangingMan)
sInvHammerShootingStar = f_strength(mInvHammerShootingStar)
sMarubozu = f_strength(mMarubozu)
sSpinningTop = f_strength(mSpinningTop)
sBeltHold = f_strength(mBeltHold)

sEngulfing = f_strength(mEngulfing)
sHarami = f_strength(mHarami)
sHaramiCross = f_strength(mHaramiCross)
sPiercingDarkCloud = f_strength(mPiercingDarkCloud)
sTweezer = f_strength(mTweezer)
sKicker = f_strength(mKicker)

sStar = f_strength(mStar)
sDojiStar = f_strength(mDojiStar)
sThreeSoldiersCrows = f_strength(mThreeSoldiersCrows)
sThreeInside = f_strength(mThreeInside)
sThreeOutside = f_strength(mThreeOutside)
sAbandonedBaby = f_strength(mAbandonedBaby)
sThreeMethods = f_strength(mThreeMethods)
sStickSandwich = f_strength(mStickSandwich)

// Effective per-pattern gate = individual checkbox AND category master
// switch AND volume confirmation AND trend context AND meets the minimum
// strength filter. This is what drives boxes, pins, and the pin tooltip text
// below — the scanner table ignores it by design, since the table is meant
// to be a full status board regardless of what's currently shown on chart.
gDoji = showDoji_raw and enableSingle and volOk and f_trendOk(mDoji) and sDoji >= minStrength
gLongLeggedDoji = showLongLeggedDoji_raw and enableSingle and volOk and f_trendOk(mLongLeggedDoji) and sLongLeggedDoji >= minStrength
gDragonflyDoji = showDragonflyDoji_raw and enableSingle and volOk and f_trendOk(mDragonflyDoji) and sDragonflyDoji >= minStrength
gGravestoneDoji = showGravestoneDoji_raw and enableSingle and volOk and f_trendOk(mGravestoneDoji) and sGravestoneDoji >= minStrength
gHammerHangingMan = showHammerHangingMan_raw and enableSingle and volOk and f_trendOk(mHammerHangingMan) and sHammerHangingMan >= minStrength
gInvHammerShootingStar = showInvHammerShootingStar_raw and enableSingle and volOk and f_trendOk(mInvHammerShootingStar) and sInvHammerShootingStar >= minStrength
gMarubozu = showMarubozu_raw and enableSingle and volOk and f_trendOk(mMarubozu) and sMarubozu >= minStrength
gSpinningTop = showSpinningTop_raw and enableSingle and volOk and f_trendOk(mSpinningTop) and sSpinningTop >= minStrength
gBeltHold = showBeltHold_raw and enableSingle and volOk and f_trendOk(mBeltHold) and sBeltHold >= minStrength

gEngulfing = showEngulfing_raw and enableTwo and volOk and f_trendOk(mEngulfing) and sEngulfing >= minStrength
gHarami = showHarami_raw and enableTwo and volOk and f_trendOk(mHarami) and sHarami >= minStrength
gHaramiCross = showHaramiCross_raw and enableTwo and volOk and f_trendOk(mHaramiCross) and sHaramiCross >= minStrength
gPiercingDarkCloud = showPiercingDarkCloud_raw and enableTwo and volOk and f_trendOk(mPiercingDarkCloud) and sPiercingDarkCloud >= minStrength
gTweezer = showTweezer_raw and enableTwo and volOk and f_trendOk(mTweezer) and sTweezer >= minStrength
gKicker = showKicker_raw and enableTwo and volOk and f_trendOk(mKicker) and sKicker >= minStrength

gStar = showStar_raw and enableThree and volOk and f_trendOk(mStar) and sStar >= minStrength
gDojiStar = showDojiStar_raw and enableThree and volOk and f_trendOk(mDojiStar) and sDojiStar >= minStrength
gThreeSoldiersCrows = showThreeSoldiersCrows_raw and enableThree and volOk and f_trendOk(mThreeSoldiersCrows) and sThreeSoldiersCrows >= minStrength
gThreeInside = showThreeInside_raw and enableThree and volOk and f_trendOk(mThreeInside) and sThreeInside >= minStrength
gThreeOutside = showThreeOutside_raw and enableThree and volOk and f_trendOk(mThreeOutside) and sThreeOutside >= minStrength
gAbandonedBaby = showAbandonedBaby_raw and enableThree and volOk and f_trendOk(mAbandonedBaby) and sAbandonedBaby >= minStrength
gThreeMethods = showThreeMethods_raw and enableThree and volOk and f_trendOk(mThreeMethods) and sThreeMethods >= minStrength
gStickSandwich = showStickSandwich_raw and enableThree and volOk and f_trendOk(mStickSandwich) and sStickSandwich >= minStrength

// ---------------------------------------------------------------------------
// Collect enabled matches by direction — feeds the label tooltips.
// ---------------------------------------------------------------------------
f_collect(_m, _enabled, _s, _col) =>
    if _m.found and _enabled
        _text = _m.description + " [Strength: " + str.tostring(_s, "#") + "%]"
        if _m.direction == "bullish"
            array.push(_col.descBull, _text)
        else if _m.direction == "bearish"
            array.push(_col.descBear, _text)
        else
            array.push(_col.descNeut, _text)

col = Collector.new(array.new<string>(), array.new<string>(), array.new<string>())

f_collect(mDoji, gDoji, sDoji, col)
f_collect(mLongLeggedDoji, gLongLeggedDoji, sLongLeggedDoji, col)
f_collect(mDragonflyDoji, gDragonflyDoji, sDragonflyDoji, col)
f_collect(mGravestoneDoji, gGravestoneDoji, sGravestoneDoji, col)
f_collect(mHammerHangingMan, gHammerHangingMan, sHammerHangingMan, col)
f_collect(mInvHammerShootingStar, gInvHammerShootingStar, sInvHammerShootingStar, col)
f_collect(mMarubozu, gMarubozu, sMarubozu, col)
f_collect(mSpinningTop, gSpinningTop, sSpinningTop, col)
f_collect(mBeltHold, gBeltHold, sBeltHold, col)

f_collect(mEngulfing, gEngulfing, sEngulfing, col)
f_collect(mHarami, gHarami, sHarami, col)
f_collect(mHaramiCross, gHaramiCross, sHaramiCross, col)
f_collect(mPiercingDarkCloud, gPiercingDarkCloud, sPiercingDarkCloud, col)
f_collect(mTweezer, gTweezer, sTweezer, col)
f_collect(mKicker, gKicker, sKicker, col)

f_collect(mStar, gStar, sStar, col)
f_collect(mDojiStar, gDojiStar, sDojiStar, col)
f_collect(mThreeSoldiersCrows, gThreeSoldiersCrows, sThreeSoldiersCrows, col)
f_collect(mThreeInside, gThreeInside, sThreeInside, col)
f_collect(mThreeOutside, gThreeOutside, sThreeOutside, col)
f_collect(mAbandonedBaby, gAbandonedBaby, sAbandonedBaby, col)
f_collect(mThreeMethods, gThreeMethods, sThreeMethods, col)
f_collect(mStickSandwich, gStickSandwich, sStickSandwich, col)

hasBull = array.size(col.descBull) > 0
hasBear = array.size(col.descBear) > 0
hasNeut = array.size(col.descNeut) > 0

bullText = array.join(col.descBull, "\n\n")
bearText = array.join(col.descBear, "\n\n")
neutText = array.join(col.descNeut, "\n\n")

// ---------------------------------------------------------------------------
// Pattern boxes — outline the exact bars each matched pattern spans, drawn
// per match (not per direction) since different patterns ending on the same
// bar can span different numbers of bars. Internally gated on
// barstate.isconfirmed, so a box is only ever drawn once the bar it
// describes has actually closed — no repaint.
// ---------------------------------------------------------------------------
f_drawBox(_m, _enabled) =>
    if _m.found and _enabled and barstate.isconfirmed
        _start = _m.barIndex - (_m.barsUsed - 1)
        _top = high[0]
        _bot = low[0]
        if _m.barsUsed >= 2
            for i = 1 to _m.barsUsed - 1
                _top := math.max(_top, high[i])
                _bot := math.min(_bot, low[i])
        _boxColor = _m.direction == "bullish" ? bullColor : _m.direction == "bearish" ? bearColor : neutColor
        box.new(left = _start, top = _top, right = bar_index, bottom = _bot, border_color = color.new(_boxColor, 0), border_width = 1, bgcolor = color.new(_boxColor, 85))

if showBoxes
    f_drawBox(mDoji, gDoji)
    f_drawBox(mLongLeggedDoji, gLongLeggedDoji)
    f_drawBox(mDragonflyDoji, gDragonflyDoji)
    f_drawBox(mGravestoneDoji, gGravestoneDoji)
    f_drawBox(mHammerHangingMan, gHammerHangingMan)
    f_drawBox(mInvHammerShootingStar, gInvHammerShootingStar)
    f_drawBox(mMarubozu, gMarubozu)
    f_drawBox(mSpinningTop, gSpinningTop)
    f_drawBox(mBeltHold, gBeltHold)
    f_drawBox(mEngulfing, gEngulfing)
    f_drawBox(mHarami, gHarami)
    f_drawBox(mHaramiCross, gHaramiCross)
    f_drawBox(mPiercingDarkCloud, gPiercingDarkCloud)
    f_drawBox(mTweezer, gTweezer)
    f_drawBox(mKicker, gKicker)
    f_drawBox(mStar, gStar)
    f_drawBox(mDojiStar, gDojiStar)
    f_drawBox(mThreeSoldiersCrows, gThreeSoldiersCrows)
    f_drawBox(mThreeInside, gThreeInside)
    f_drawBox(mThreeOutside, gThreeOutside)
    f_drawBox(mAbandonedBaby, gAbandonedBaby)
    f_drawBox(mThreeMethods, gThreeMethods)
    f_drawBox(mStickSandwich, gStickSandwich)

// ---------------------------------------------------------------------------
// Signals — a "pin": a thin stem anchored to the bar with a glowing gem at
// its tip, instead of the arrow/triangle glyphs every other scanner uses.
// Bullish/bearish pins hang below/above the bar (direction is the anchor
// side, not a glyph); neutral has no direction to anchor to, so it's a
// plain floating gem with no stem — the shape itself tells the story.
// The glow is a larger, lighter halo drawn first at the same point, with
// the crisp gem drawn on top of it; no black shadow anywhere. Stem length
// scales off ATR so it reads consistently across any instrument's price
// scale. Full description lives in the gem's tooltip. Everything is gated
// on barstate.isconfirmed so a signal is only ever drawn once the bar it
// describes has actually closed — no repaint.
// ---------------------------------------------------------------------------
f_glow(_c) =>
    _r = color.r(_c) + (255 - color.r(_c)) * 0.55
    _g = color.g(_c) + (255 - color.g(_c)) * 0.55
    _b = color.b(_c) + (255 - color.b(_c)) * 0.55
    color.rgb(_r, _g, _b, 45)

f_pin(_x, _yAnchor, _yTip, _col, _glow, _tip) =>
    line.new(_x, _yAnchor, _x, _yTip, color = color.new(_col, 35), width = 1)
    label.new(_x, _yTip, "", style = label.style_circle, color = _glow, size = size.small)
    label.new(_x, _yTip, "", style = label.style_circle, color = _col, size = size.tiny, tooltip = _tip)

f_gem(_x, _y, _col, _glow, _tip) =>
    label.new(_x, _y, "", style = label.style_circle, color = _glow, size = size.small)
    label.new(_x, _y, "", style = label.style_circle, color = _col, size = size.tiny, tooltip = _tip)

pinLength = ta.atr(14) * 0.6
bullGlow = f_glow(bullColor)
bearGlow = f_glow(bearColor)
neutGlow = f_glow(neutColor)

if showSignals and hasBull and barstate.isconfirmed
    f_pin(bar_index, low, low - pinLength, bullColor, bullGlow, bullText)

if showSignals and hasBear and barstate.isconfirmed
    f_pin(bar_index, high, high + pinLength, bearColor, bearGlow, bearText)

if showSignals and hasNeut and barstate.isconfirmed
    f_gem(bar_index, hl2, neutColor, neutGlow, neutText)

// ---------------------------------------------------------------------------
// Scanner table — every pattern the library knows, with a live status column
// for the current bar. Built only on the last bar (barstate.islast); a
// dashboard doesn't need recomputing on every historical bar. This one is
// intentionally live (not isconfirmed-gated) — it's a "what's happening on
// the forming bar right now" readout, not a persisted signal, so it's
// expected to update as the bar develops rather than wait for it to close.
// ---------------------------------------------------------------------------
f_setRow(_tbl, _row, _label, _m, _s) =>
    _found = _m.found
    _rowColor = _found ? (_m.direction == "bullish" ? bullColor : _m.direction == "bearish" ? bearColor : neutColor) : color.new(#0E171D, 0)
    _nameText = _found ? _m.patternName : _label
    _nameColor = _found ? color.new(#14110B, 0) : color.new(#C9B37E, 0)
    _statusText = _found ? str.tostring(_s, "#") + "%" : "–"
    _statusColor = _found ? color.new(#14110B, 0) : color.new(#7A6423, 0)
    _tip = _found ? _m.description + " [Strength: " + str.tostring(_s, "#") + "%]" : "No match on the current bar."
    table.cell(_tbl, 0, _row, _nameText, text_color = _nameColor, bgcolor = color.new(_rowColor, 0), text_size = rowTextSize, text_halign = text.align_left, tooltip = _tip)
    table.cell(_tbl, 1, _row, _statusText, text_color = _statusColor, bgcolor = color.new(_rowColor, 0), text_size = rowTextSize, text_halign = text.align_center, tooltip = _tip)

if showTable and barstate.islast
    tbl = table.new(position = tablePos, columns = 2, rows = 27, bgcolor = color.new(#081013, 0), border_width = 1, border_color = color.new(#B8860B, 75), frame_width = 2, frame_color = color.new(#D4AF37, 0))

    table.cell(tbl, 0, 0, "PATTERN ATLAS  :  CANDLESTICK", text_color = color.new(#14110B, 0), bgcolor = color.new(#D4AF37, 0), text_size = titleTextSize, text_halign = text.align_center, text_font_family = font.family_default)
    table.merge_cells(tbl, 0, 0, 1, 0)

    table.cell(tbl, 0, 1, "SINGLE-BAR", text_color = color.new(#C9B37E, 0), bgcolor = color.new(#142028, 0), text_size = catTextSize, text_halign = text.align_center)
    table.merge_cells(tbl, 0, 1, 1, 1)
    f_setRow(tbl, 2, "Doji", mDoji, sDoji)
    f_setRow(tbl, 3, "Long-Legged Doji", mLongLeggedDoji, sLongLeggedDoji)
    f_setRow(tbl, 4, "Dragonfly Doji", mDragonflyDoji, sDragonflyDoji)
    f_setRow(tbl, 5, "Gravestone Doji", mGravestoneDoji, sGravestoneDoji)
    f_setRow(tbl, 6, "Hammer / Hanging Man", mHammerHangingMan, sHammerHangingMan)
    f_setRow(tbl, 7, "Inverted Hammer / Shooting Star", mInvHammerShootingStar, sInvHammerShootingStar)
    f_setRow(tbl, 8, "Marubozu", mMarubozu, sMarubozu)
    f_setRow(tbl, 9, "Spinning Top", mSpinningTop, sSpinningTop)
    f_setRow(tbl, 10, "Belt Hold", mBeltHold, sBeltHold)

    table.cell(tbl, 0, 11, "TWO-BAR", text_color = color.new(#C9B37E, 0), bgcolor = color.new(#142028, 0), text_size = catTextSize, text_halign = text.align_center)
    table.merge_cells(tbl, 0, 11, 1, 11)
    f_setRow(tbl, 12, "Engulfing", mEngulfing, sEngulfing)
    f_setRow(tbl, 13, "Harami", mHarami, sHarami)
    f_setRow(tbl, 14, "Harami Cross", mHaramiCross, sHaramiCross)
    f_setRow(tbl, 15, "Piercing Line / Dark Cloud Cover", mPiercingDarkCloud, sPiercingDarkCloud)
    f_setRow(tbl, 16, "Tweezer Top / Bottom", mTweezer, sTweezer)
    f_setRow(tbl, 17, "Kicker", mKicker, sKicker)

    table.cell(tbl, 0, 18, "THREE-BAR+", text_color = color.new(#C9B37E, 0), bgcolor = color.new(#142028, 0), text_size = catTextSize, text_halign = text.align_center)
    table.merge_cells(tbl, 0, 18, 1, 18)
    f_setRow(tbl, 19, "Morning / Evening Star", mStar, sStar)
    f_setRow(tbl, 20, "Morning / Evening Doji Star", mDojiStar, sDojiStar)
    f_setRow(tbl, 21, "Three Soldiers / Crows", mThreeSoldiersCrows, sThreeSoldiersCrows)
    f_setRow(tbl, 22, "Three Inside Up / Down", mThreeInside, sThreeInside)
    f_setRow(tbl, 23, "Three Outside Up / Down", mThreeOutside, sThreeOutside)
    f_setRow(tbl, 24, "Abandoned Baby", mAbandonedBaby, sAbandonedBaby)
    f_setRow(tbl, 25, "Rising / Falling Three Methods", mThreeMethods, sThreeMethods)
    f_setRow(tbl, 26, "Stick Sandwich", mStickSandwich, sStickSandwich)

// ───────────────────────── Watermark (Royal gold & cream — matches Fibonacci Confluence Suite [AxeAlgo Pro]) ─────────────────────────
grpWM = "Watermark"
wm_theme = input.string('Dark', 'Watermark Theme', group = grpWM, options = ['Dark', 'Light'])

if barstate.islast
    dark        = wm_theme == 'Dark'
    wm_bg       = dark ? color.new(#14110B, 0) : color.new(#F2EAD3, 0)
    wm_dot_col  = dark ? color.new(#D4AF37, 15) : color.new(#B8860B, 10)
    wm_txt_col  = dark ? color.new(#C9B37E, 0)  : color.new(#7A6423, 0)
    wm_frm_col  = dark ? color.new(#C9A227, 60) : color.new(#B8860B, 60)

    wm = table.new(position.bottom_center, 2, 1,
                   frame_color = wm_frm_col,
                   frame_width = 1,
                   border_width = 0)
    table.cell(wm, 0, 0, ' ◆ ',
               bgcolor = wm_bg,
               text_color = wm_dot_col,
               text_size = size.small,
               text_halign = text.align_center,
               text_valign = text.align_center)
    table.cell(wm, 1, 0, ' A X E A L G O ',
               bgcolor = wm_bg,
               text_color = wm_txt_col,
               text_size = size.small,
               text_halign = text.align_left,
               text_valign = text.align_center)

// ---------------------------------------------------------------------------
// Alerts — one alertcondition per library function (for the Create Alert
// dropdown; message text is static since alertcondition() can't take a
// dynamic message), plus three combined ones, plus one alert() with a full
// dynamic message built from each match's description. Every condition is
// gated with barstate.isconfirmed here in the code — not left to the user's
// alert-frequency choice — so none of them can fire off a still-forming bar.
// ---------------------------------------------------------------------------
alertcondition(mDoji.found and barstate.isconfirmed, title = "Doji", message = "{{ticker}} {{interval}}: Doji")
alertcondition(mLongLeggedDoji.found and barstate.isconfirmed, title = "Long-Legged Doji", message = "{{ticker}} {{interval}}: Long-Legged Doji")
alertcondition(mDragonflyDoji.found and barstate.isconfirmed, title = "Dragonfly Doji", message = "{{ticker}} {{interval}}: Dragonfly Doji (bullish)")
alertcondition(mGravestoneDoji.found and barstate.isconfirmed, title = "Gravestone Doji", message = "{{ticker}} {{interval}}: Gravestone Doji (bearish)")
alertcondition(mHammerHangingMan.found and barstate.isconfirmed, title = "Hammer / Hanging Man", message = "{{ticker}} {{interval}}: Hammer or Hanging Man")
alertcondition(mInvHammerShootingStar.found and barstate.isconfirmed, title = "Inverted Hammer / Shooting Star", message = "{{ticker}} {{interval}}: Inverted Hammer or Shooting Star")
alertcondition(mMarubozu.found and barstate.isconfirmed, title = "Marubozu", message = "{{ticker}} {{interval}}: Marubozu")
alertcondition(mSpinningTop.found and barstate.isconfirmed, title = "Spinning Top", message = "{{ticker}} {{interval}}: Spinning Top")
alertcondition(mBeltHold.found and barstate.isconfirmed, title = "Belt Hold", message = "{{ticker}} {{interval}}: Belt Hold")

alertcondition(mEngulfing.found and barstate.isconfirmed, title = "Engulfing", message = "{{ticker}} {{interval}}: Engulfing")
alertcondition(mHarami.found and barstate.isconfirmed, title = "Harami", message = "{{ticker}} {{interval}}: Harami")
alertcondition(mHaramiCross.found and barstate.isconfirmed, title = "Harami Cross", message = "{{ticker}} {{interval}}: Harami Cross")
alertcondition(mPiercingDarkCloud.found and barstate.isconfirmed, title = "Piercing Line / Dark Cloud Cover", message = "{{ticker}} {{interval}}: Piercing Line or Dark Cloud Cover")
alertcondition(mTweezer.found and barstate.isconfirmed, title = "Tweezer Top / Bottom", message = "{{ticker}} {{interval}}: Tweezer Top or Bottom")
alertcondition(mKicker.found and barstate.isconfirmed, title = "Kicker", message = "{{ticker}} {{interval}}: Kicker")

alertcondition(mStar.found and barstate.isconfirmed, title = "Morning / Evening Star", message = "{{ticker}} {{interval}}: Morning or Evening Star")
alertcondition(mDojiStar.found and barstate.isconfirmed, title = "Morning / Evening Doji Star", message = "{{ticker}} {{interval}}: Morning or Evening Doji Star")
alertcondition(mThreeSoldiersCrows.found and barstate.isconfirmed, title = "Three Soldiers / Crows", message = "{{ticker}} {{interval}}: Three Soldiers or Three Crows")
alertcondition(mThreeInside.found and barstate.isconfirmed, title = "Three Inside Up / Down", message = "{{ticker}} {{interval}}: Three Inside Up or Down")
alertcondition(mThreeOutside.found and barstate.isconfirmed, title = "Three Outside Up / Down", message = "{{ticker}} {{interval}}: Three Outside Up or Down")
alertcondition(mAbandonedBaby.found and barstate.isconfirmed, title = "Abandoned Baby", message = "{{ticker}} {{interval}}: Abandoned Baby")
alertcondition(mThreeMethods.found and barstate.isconfirmed, title = "Rising / Falling Three Methods", message = "{{ticker}} {{interval}}: Rising or Falling Three Methods")
alertcondition(mStickSandwich.found and barstate.isconfirmed, title = "Stick Sandwich", message = "{{ticker}} {{interval}}: Stick Sandwich")

alertcondition(hasBull and barstate.isconfirmed, title = "Any Bullish Pattern", message = "{{ticker}} {{interval}}: Bullish candlestick pattern")
alertcondition(hasBear and barstate.isconfirmed, title = "Any Bearish Pattern", message = "{{ticker}} {{interval}}: Bearish candlestick pattern")
alertcondition(hasNeut and barstate.isconfirmed, title = "Any Neutral Pattern", message = "{{ticker}} {{interval}}: Neutral candlestick pattern")

if barstate.isconfirmed and (hasBull or hasBear or hasNeut)
    header = "Candlestick pattern(s) on " + syminfo.ticker + " " + timeframe.period
    bullPart = hasBull ? "\n\nBullish:\n" + bullText : ""
    bearPart = hasBear ? "\n\nBearish:\n" + bearText : ""
    neutPart = hasNeut ? "\n\nNeutral:\n" + neutText : ""
    msg = header + bullPart + bearPart + neutPart
    alert(msg, alert.freq_once_per_bar_close)
````
