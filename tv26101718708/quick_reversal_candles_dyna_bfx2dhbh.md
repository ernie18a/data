# Quick Reversal Candles [DYNA]

- url: https://www.tradingview.com/script/bFX2dHBH-Quick-Reversal-Candles-DYNA/
- type: indicator
- pine_id: PUB;e309bf2d4eff4931893a4704d01eb157
- version: 1.0

## Description

Quick Reversal Candles detects three of the most reliable single-bar reversal patterns -- pin bars, engulfing bars, and inside-bar breakouts -- and grades every one with a 0-100 conviction score before it ever puts an arrow on your chart. No guesswork, no manual scanning, and no treating a textbook pattern in dead air the same as one printed right at a swing extreme.

Candle pattern recognition is one of the oldest edges in trading, but doing it by eye is slow and inconsistent -- and most pattern indicators make it worse by either flagging everything or quietly going dark on instruments that don't report volume. Quick Reversal Candles solves both. It scores each pattern on four things -- pattern quality, location versus the recent swing, the size of the move that preceded it, and an activity burst -- and only marks the ones that clear your threshold. And the activity check is volume-aware, not volume-dependent: when volume exists it uses it; when it doesn't (indices like NIFTY, some forex feeds) it automatically switches to candle-range expansion, so the indicator keeps working everywhere.


[b]Key Features[/b]

[list]
[*] [b]Three Pattern Types[/b] -- Detects pin bars (wick rejection), engulfing bars (momentum shift), and inside-bar breakouts (compression release) in a single indicator
[*] [b]0-100 Conviction Score[/b] -- Each pattern is graded on quality, swing location, prior move, and activity. One threshold controls how selective the indicator is -- raise it for the cleanest setups, lower it to study every raw pattern
[*] [b]Works With or Without Volume[/b] -- Uses volume when the symbol reports it and automatically falls back to candle-range expansion when it doesn't, so signals fire on indices and volume-less feeds instead of disappearing
[*] [b]Smart Context, Not Hard Filters[/b] -- Swing proximity and prior-move strength add points rather than veto signals, so a great pattern in a slightly-off location can still qualify on overall merit
[*] [b]Confirmed-Bar Logic, Correct Placement[/b] -- Patterns are evaluated on the last completed bar and the marker is drawn back onto that exact candle, so nothing repaints and nothing is off by a bar
[*] [b]Pattern + Score Labels[/b] -- Each signal is tagged with its pattern (PIN, ENG, IB) and conviction number so you instantly know what fired and how strong it was
[*] [b]Clean Overlay[/b] -- Simple up/down arrows on price with optional background shading and candle coloring, each toggled independently
[/list]


[b]How It Works[/b]

The indicator runs three independent pattern detectors on every confirmed bar. The pin bar detector measures the ratio of the dominant wick to the candle body -- a bullish pin has a lower wick at least twice (by default) the body and dominating the upper wick, showing strong rejection from below. The engulfing detector checks whether the bar's body wraps the prior body in the opposite direction, a decisive handoff between buyers and sellers. The inside-bar breakout detector finds bars fully contained within the prior bar's range, then flags a breakout when price closes beyond that compressed range.

Instead of passing or failing each pattern through a chain of hard filters, the indicator scores it. A valid pattern starts at 40 points. Up to 20 more are awarded for sitting close to the most recent swing extreme, up to 20 for a real opposing move into the reversal, and up to 20 for an activity burst on the signal bar -- measured by volume where it exists and by candle-range expansion where it doesn't. The four parts sum to a 0-100 conviction score, and a signal only fires when that score clears your Min Conviction threshold. This is what lets you suppress the single biggest source of false positives -- patterns fired mid-range with nothing to reverse -- using one intuitive dial instead of juggling several on/off filters.

When a pattern clears the threshold, a green up-arrow is drawn on the bullish signal bar or a red down-arrow on the bearish one, with a label showing the pattern code and its conviction score. The signal bar can also carry a background highlight and candle color override so reversal zones pop even while scrolling through hundreds of bars.

[image]https://www.tradingview.com/x/1ybK0SHe/[/image]
[i]Bullish reversal signals (green arrows) appearing at swing lows, each tagged with its pattern and conviction score.[/i]

[image]https://www.tradingview.com/x/vvc1BP8v/[/image]
[i]Bearish reversal signals (red arrows) marking rejection at swing highs on a volume-less index.[/i]


[b]Settings[/b]

The core settings drive the engine. Min Wick Ratio (default 2.0) sets how extreme a pin bar's wick must be relative to its body. Min Conviction Score (default 55) is the master selectivity dial -- a valid pattern alone scores 40, so values near 40 show every raw pattern while 70-85 keep only the strongest. The Activity Multiplier (default 1.3) and Activity Average Length (default 20) define the activity-burst check, which transparently uses volume or candle range depending on the symbol.

The context settings shape the score rather than gate it. Swing Lookback (default 20) and Max Distance from Swing (default 1.5 ATR) define the location component; Prior Move Lookback (default 5) and Min Prior Move (default 1.0 ATR) define the prior-move component; ATR Length (default 14) normalizes both. Three pattern toggles independently enable pin bars, engulfing bars, and inside-bar breakouts, and the visual section lets you set arrow/label size and toggle labels, background highlight, and candle coloring.


[b]Alerts[/b]

[list]
[*] [b]Bullish Reversal Candle[/b] -- Fires when a bullish pin bar, engulfing bar, or inside-bar breakout clears the conviction threshold. [i]"Quick Reversal Candles [DYNA]: Bullish reversal pattern cleared the conviction threshold. Potential long entry."[/i]
[*] [b]Bearish Reversal Candle[/b] -- Fires when a bearish pin bar, engulfing bar, or inside-bar breakout clears the conviction threshold. [i]"Quick Reversal Candles [DYNA]: Bearish reversal pattern cleared the conviction threshold. Potential short entry."[/i]
[/list]

To set up alerts: click the TradingView Alerts button, select "Quick Reversal Candles [DYNA]" from the indicator dropdown, choose your condition, and set your preferred notification method.


[b]Best Practices[/b]

[list]
[*] Treat Min Conviction as your main control. Start at 55, raise toward 70-85 for only the cleanest setups, drop toward 40 to study raw pattern frequency.
[*] Use on 1m to 15m charts for scalping. On higher timeframes signals are rarer but carry more weight.
[*] Combine with a trend filter -- take bullish signals above a moving average, bearish below.
[*] The highest-probability signals tend to be those tagged with high conviction sitting right at a known support/resistance level.
[*] On volume-less symbols, remember the activity score reflects candle size, not traded size -- it still works, it just measures a different kind of energy.
[/list]


[b]Part of the DYNA Ecosystem[/b]

Quick Reversal Candles is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Quick Reversal Candles [DYNA]
// Scores high-probability single-bar reversals (pin bars, engulfing bars, and
// inside-bar breakouts) by pattern quality, location, prior move, and activity,
// then marks only those above a conviction threshold. Works with or without volume.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Quick Reversal Candles [DYNA]", shorttitle = "QRC [DYNA]", overlay = true, max_labels_count = 500, max_lines_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// --- Core Settings ---
string GRP_CORE = "Core Settings"
float i_wickRatio      = input.float(2.0, "Min Wick Ratio (Pin Bar)", minval = 1.0, maxval = 10.0, step = 0.1, group = GRP_CORE, tooltip = "The dominant wick must be at least this many times the candle body to qualify as a pin bar.")
int   i_minConviction  = input.int(55,    "Min Conviction Score",     minval = 40,  maxval = 100,             group = GRP_CORE, tooltip = "A signal only fires when its 0-100 conviction score clears this level. A valid pattern alone scores 40; location, prior move, and activity add up to 60 more. Raise for fewer, higher-quality signals; lower (toward 40) to see every raw pattern.")
float i_actMult        = input.float(1.3,  "Activity Multiplier",      minval = 1.0, maxval = 5.0, step = 0.1, group = GRP_CORE, tooltip = "Signal-bar activity (volume when available, otherwise candle range) must reach this multiple of its average to earn full activity points. On volume-less symbols (indices) the indicator automatically switches to range expansion.")
int   i_actLen         = input.int(20,     "Activity Average Length",  minval = 5,   maxval = 100,            group = GRP_CORE, tooltip = "Lookback for the average volume / range baseline used by the activity score.")

// --- Context (Conviction) ---
string GRP_CTX = "Context (Conviction)"
int   i_srLookback   = input.int(20,    "Swing Lookback Bars",           minval = 5,   maxval = 200,             group = GRP_CTX, tooltip = "Bars used to locate the recent swing high / low. Reversals near a swing extreme earn the full location score.")
float i_srMaxDistAtr = input.float(1.5, "Max Distance from Swing (ATR)", minval = 0.1, maxval = 5.0, step = 0.1, group = GRP_CTX, tooltip = "Location score fades to zero once the signal bar sits this many ATRs away from the swing extreme.")
int   i_moveLookback = input.int(5,     "Prior Move Lookback Bars",      minval = 2,   maxval = 50,              group = GRP_CTX, tooltip = "Bars used to measure the prior directional move ending at the signal bar.")
float i_moveMinAtr   = input.float(1.0, "Min Prior Move (ATR)",          minval = 0.1, maxval = 10.0, step = 0.1, group = GRP_CTX, tooltip = "A prior move of this many ATRs (decline for bullish, rally for bearish) earns the full prior-move score.")
int   i_atrLen       = input.int(14,    "ATR Length",                    minval = 2,   maxval = 200,             group = GRP_CTX, tooltip = "ATR period used to normalize the location and prior-move scores.")

// --- Pattern Selection ---
string GRP_PAT = "Pattern Selection"
bool i_showPin    = input.bool(true, "Detect Pin Bars",             group = GRP_PAT, tooltip = "Long-wick rejection candles.")
bool i_showEngulf = input.bool(true, "Detect Engulfing Bars",       group = GRP_PAT, tooltip = "Bars whose body engulfs the prior body in the opposite direction.")
bool i_showInside = input.bool(true, "Detect Inside-Bar Breakouts", group = GRP_PAT, tooltip = "Breakouts from a bar fully contained inside the one before it.")

// --- Visual ---
string GRP_VIS = "Visual"
string i_arrowSize   = input.string("Small", "Arrow / Label Size", options = ["Tiny", "Small", "Normal"], group = GRP_VIS, tooltip = "Size of the signal arrows and labels.")
bool   i_showLabels  = input.bool(true,  "Show Pattern + Conviction Labels", group = GRP_VIS, tooltip = "Show the pattern code (PIN / ENG / IB) and conviction score on each signal bar.")
bool   i_highlightBg = input.bool(true,  "Highlight Signal Bar Background",  group = GRP_VIS, tooltip = "Add a subtle background wash on signal bars.")
bool   i_colorBars   = input.bool(false, "Color Signal Bar Candles",        group = GRP_VIS, tooltip = "Override the candle color on signal bars so they stand out.")

// --- Alerts ---
string GRP_ALERT = "Alerts"
bool i_alertBull = input.bool(true, "Alert: Bullish Reversal Candle", group = GRP_ALERT)
bool i_alertBear = input.bool(true, "Alert: Bearish Reversal Candle", group = GRP_ALERT)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- Helpers ---
clamp01(float x) => math.max(0.0, math.min(1.0, x))

// --- Activity baseline (volume when real, range expansion otherwise) ----------
// NIFTY and most index feeds publish volume = 0; ta.cum stays at 0, so the
// indicator transparently falls back to candle-range expansion as a proxy.
bool  volReal   = ta.cum(volume) > 0
float actSeries = volReal ? volume : (high - low)
float actAvg    = ta.sma(actSeries, i_actLen)
float actRefRaw = nz(actSeries[1])
float actAvgRef = math.max(nz(actAvg[1]), syminfo.mintick)
float actRatio  = actRefRaw / actAvgRef
float actDen    = math.max(i_actMult - 1.0, 0.01)
float actScore  = clamp01((actRatio - 1.0) / actDen) * 20.0

// --- ATR reference (confirmed) ------------------------------------------------
float atrVal   = ta.atr(i_atrLen)
float atrGuard = math.max(nz(atrVal[1]), syminfo.mintick)

// --- Body / wick geometry of the signal bar [1] -------------------------------
float body1      = math.abs(close[1] - open[1])
float bodyGuard1 = math.max(body1, syminfo.mintick)
float range1     = high[1] - low[1]
float rangeGuard1 = math.max(range1, syminfo.mintick)
float lowerWick1 = math.min(open[1], close[1]) - low[1]
float upperWick1 = high[1] - math.max(open[1], close[1])

// ─── Pin Bar Detection (signal bar = [1]) ────────────────────────────────────
bool bullishPin = i_showPin and lowerWick1 >= i_wickRatio * bodyGuard1 and lowerWick1 > upperWick1 and lowerWick1 >= 0.5 * rangeGuard1
bool bearishPin = i_showPin and upperWick1 >= i_wickRatio * bodyGuard1 and upperWick1 > lowerWick1 and upperWick1 >= 0.5 * rangeGuard1

// ─── Engulfing Detection (signal bar = [1] vs prior body [2]) ────────────────
bool bullishEngulfing = i_showEngulf and close[2] < open[2] and close[1] > open[1] and close[1] >= open[2] and open[1] <= close[2]
bool bearishEngulfing = i_showEngulf and close[2] > open[2] and close[1] < open[1] and close[1] <= open[2] and open[1] >= close[2]

// ─── Inside-Bar Breakout (inside bar = [2] within [3], breakout = [1]) ───────
bool insideBar          = high[2] <= high[3] and low[2] >= low[3]
bool bullishInsideBreak = i_showInside and insideBar and close[1] > high[2]
bool bearishInsideBreak = i_showInside and insideBar and close[1] < low[2]

// ─── Pattern aggregation ─────────────────────────────────────────────────────
bool anyBull = bullishPin or bullishEngulfing or bullishInsideBreak
bool anyBear = bearishPin or bearishEngulfing or bearishInsideBreak

// Dominant pattern code (priority: engulfing > pin > inside-bar)
string codeBull = bullishEngulfing ? "ENG" : bullishPin ? "PIN" : bullishInsideBreak ? "IB" : ""
string codeBear = bearishEngulfing ? "ENG" : bearishPin ? "PIN" : bearishInsideBreak ? "IB" : ""

// ─── Location score (proximity to recent swing extreme) ──────────────────────
float swingHigh = ta.highest(high, i_srLookback)[1]
float swingLow  = ta.lowest(low,  i_srLookback)[1]
float distLowAtr  = (low[1]  - swingLow)  / atrGuard
float distHighAtr = (swingHigh - high[1]) / atrGuard
float locBull = clamp01(1.0 - distLowAtr  / i_srMaxDistAtr) * 20.0
float locBear = clamp01(1.0 - distHighAtr / i_srMaxDistAtr) * 20.0

// ─── Prior-move score (opposing directional thrust into the reversal) ────────
float priorMove = close[1] - close[1 + i_moveLookback]
float moveBull  = clamp01((-priorMove) / (i_moveMinAtr * atrGuard)) * 20.0
float moveBear  = clamp01(( priorMove) / (i_moveMinAtr * atrGuard)) * 20.0

// ─── Conviction score (0-100) ────────────────────────────────────────────────
float bullConv = (anyBull ? 40.0 : 0.0) + actScore + locBull + moveBull
float bearConv = (anyBear ? 40.0 : 0.0) + actScore + locBear + moveBear

// ─── Final signals (confirmed-bar logic, displayed on the signal bar) ────────
bool bullishSignal = anyBull and bullConv >= i_minConviction
bool bearishSignal = anyBear and bearConv >= i_minConviction

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// Map the size input to a size constant (for labels, which accept an input-qualified size).
string szSel = i_arrowSize == "Tiny" ? size.tiny : i_arrowSize == "Normal" ? size.normal : size.small

// --- Arrows on the actual signal bar (offset = -1 shifts display back one bar) ---
// plotshape's `size` requires a const string, so each size is a separate gated plot.
plotshape(bullishSignal and i_arrowSize == "Tiny",   "Bull Reversal (Tiny)",   style = shape.triangleup,   location = location.belowbar, color = BULL_COLOR, size = size.tiny,   offset = -1)
plotshape(bullishSignal and i_arrowSize == "Small",  "Bull Reversal (Small)",  style = shape.triangleup,   location = location.belowbar, color = BULL_COLOR, size = size.small,  offset = -1)
plotshape(bullishSignal and i_arrowSize == "Normal", "Bull Reversal (Normal)", style = shape.triangleup,   location = location.belowbar, color = BULL_COLOR, size = size.normal, offset = -1)
plotshape(bearishSignal and i_arrowSize == "Tiny",   "Bear Reversal (Tiny)",   style = shape.triangledown, location = location.abovebar, color = BEAR_COLOR, size = size.tiny,   offset = -1)
plotshape(bearishSignal and i_arrowSize == "Small",  "Bear Reversal (Small)",  style = shape.triangledown, location = location.abovebar, color = BEAR_COLOR, size = size.small,  offset = -1)
plotshape(bearishSignal and i_arrowSize == "Normal", "Bear Reversal (Normal)", style = shape.triangledown, location = location.abovebar, color = BEAR_COLOR, size = size.normal, offset = -1)

// --- Pattern + conviction labels, placed on the signal bar ([1]) ---
// Offset the text beyond the triangle (by ~1 ATR) so the two never overlap.
float labelGap = atrGuard * 1.0
if barstate.isconfirmed and i_showLabels
    if bullishSignal
        label.new(bar_index[1], low[1] - labelGap, codeBull + " " + str.tostring(int(math.round(bullConv))), yloc = yloc.price, style = label.style_none, textcolor = BULL_COLOR, size = szSel)
    if bearishSignal
        label.new(bar_index[1], high[1] + labelGap, codeBear + " " + str.tostring(int(math.round(bearConv))), yloc = yloc.price, style = label.style_none, textcolor = BEAR_COLOR, size = szSel)

// --- Background highlight on the signal bar ---
color bgCol = i_highlightBg and bullishSignal ? color.new(BULL_COLOR, 85) : i_highlightBg and bearishSignal ? color.new(BEAR_COLOR, 85) : na
bgcolor(bgCol, offset = -1, title = "Signal Bar Background")

// --- Signal bar candle coloring ---
color barCol = i_colorBars and bullishSignal ? BULL_COLOR : i_colorBars and bearishSignal ? BEAR_COLOR : na
barcolor(barCol, offset = -1, title = "Signal Bar Candle Color")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(bullishSignal, title = "Bullish Reversal Candle", message = "Quick Reversal Candles [DYNA]: Bullish reversal pattern cleared the conviction threshold. Potential long entry.")
alertcondition(bearishSignal, title = "Bearish Reversal Candle", message = "Quick Reversal Candles [DYNA]: Bearish reversal pattern cleared the conviction threshold. Potential short entry.")
````
