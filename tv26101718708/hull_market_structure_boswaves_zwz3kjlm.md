# Hull Market Structure [BOSWaves]

- url: https://www.tradingview.com/script/zwz3kJlM-Hull-Market-Structure-BOSWaves/
- type: indicator
- pine_id: PUB;454d84c1f1cf4f24b3d4661b28f2d495
- version: 1.0

## Description

[b]Hull Market Structure [BOSWaves] - Hull-Filtered Break of Structure Detection with Integrated Position Planning[/b]

[b]Overview[/b]

Hull Market Structure [BOSWaves] is a structure-based trend identification system that detects Break of Structure and Change of Character events through swing pivot analysis filtered by Hull Moving Average trend direction, where signal validity, structural level plotting, and position tool generation are governed by the alignment between confirmed swing breaks and the underlying Hull trend state rather than raw price crossovers or unfiltered pivot reactions.

[image]https://www.tradingview.com/x/46w8fLS8/[/image]

Instead of relying on unqualified structure breaks that fire regardless of trend context, BOS and CHoCH events are gated by Hull trend direction, ensuring that bullish structural breaks only register during confirmed Hull uptrends and bearish structural breaks only register during confirmed Hull downtrends, eliminating a significant portion of counter-trend noise that plagues standard market structure implementations.

This creates a structure detection framework that combines two independent but complementary layers of evidence: confirmed swing pivot breaks that identify structural shifts in price behavior, and Hull trend direction that filters those breaks for alignment with the dominant momentum state. When both layers agree, the indicator plots the structural event, labels it correctly as either a continuation BOS or a reversal CHoCH, and optionally deploys a full position planning tool with calculated entry, stop loss, and multi-target take profit levels.

Price structure is therefore evaluated not in isolation but in the context of a momentum-validated trend framework, producing signals that reflect genuine structural agreement rather than mechanical pivot crossovers.

[b]Conceptual Framework[/b]

Hull Market Structure is founded on the principle that break of structure signals carry meaningful directional information only when they occur in alignment with the prevailing momentum trend, and that the distinction between a trend continuation break and a character-changing reversal break carries significant strategic weight that standard BOS indicators routinely ignore.

Traditional market structure tools plot every swing break regardless of trend context, producing frequent counter-trend signals that require manual filtering. This framework embeds that filtering directly into the detection logic, using the Hull Moving Average as a momentum validation layer that qualifies structural breaks before they are registered, and separately classifying each qualifying break as either a BOS or CHoCH based on the current structural trend state.

Three core principles guide the design:
[list=1]
[*]Structure breaks should only fire when aligned with Hull trend direction, ensuring momentum context validates each structural event before it is presented.
[*]Each structural break should be classified as continuation (BOS) or reversal (CHoCH) based on the prior structural trend state, preserving the critical distinction between trend-following and trend-changing breaks.
[*]CHoCH events should optionally generate a full position planning framework at the point of reversal, translating structural signals directly into actionable trade planning output.
[/list]
This shifts market structure analysis from mechanical pivot tracking into momentum-qualified structural event detection with integrated trade planning capability.

[b]Theoretical Foundation[/b]

The indicator combines Hull Moving Average trend direction measurement, confirmed swing pivot detection, structural trend state tracking, BOS and CHoCH classification logic, and an optional position tool that calculates and plots entry, stop loss, and three take profit levels from each CHoCH event.

The Hull Moving Average provides low-lag trend direction through comparison of current and two-bar-lagged values, producing a responsive momentum filter that avoids the smoothing delay of standard moving averages. Pivot highs and lows are confirmed through a configurable left-right bar requirement applied to swing detection. Structural trend state is maintained independently of Hull direction, tracking the most recent structural break to determine whether the next break represents continuation or character change. The position tool derives risk levels directly from the CHoCH bar's price action, scaling take profit targets as configurable multiples of the measured risk.

Four internal systems operate in tandem:
[list]
[*][i]Hull Trend Engine[/i]: Calculates the Hull Moving Average and determines directional state through comparison with its two-bar-lagged value, providing the momentum filter that gates structural break registration.
[*][i]Swing Pivot Detection[/i]: Identifies confirmed swing highs and lows through the configurable pivot length parameter, maintaining current and previous pivot levels with their originating bar indices for structural level plotting.
[*][i]Structure Break Classification[/i]: Tests price for crossovers of previous pivot levels when Hull trend alignment is confirmed, classifying each qualifying break as BOS or CHoCH based on whether it continues or contradicts the prior structural trend state.
[*][i]Position Tool Engine[/i]: On CHoCH events with the position tool enabled, calculates entry, stop loss with percentage buffer, and three R-multiple take profit levels, plotting them with gradient-filled risk and reward zones that extend a configurable number of bars forward.
[/list]
This design ensures that structural events carry both momentum validation and classification context, and that reversal signals translate directly into structured trade planning output.

[b]How It Works[/b]

Hull Market Structure evaluates price through a sequence of structure-aware and momentum-validated processes:
[list=1]
[*][i]Hull Direction Calculation[/i]: The Hull Moving Average is calculated over the configured length and compared with its two-bar-lagged value. A value above its lag registers bullish Hull trend, below registers bearish Hull trend.
[*][i]Pivot Registration[/i]: Confirmed swing highs and lows are registered when sufficient bars to the left and right validate the pivot, storing the current and previous pivot price and bar index for each side independently.
[*][i]Bull Break Testing[/i]: On each bar during a bullish Hull trend, price is tested against the previous confirmed swing high. A close crossing above that level after closing at or below it on the prior bar triggers a bull structural break.
[*][i]Bear Break Testing[/i]: On each bar during a bearish Hull trend, price is tested against the previous confirmed swing low. A close crossing below that level after closing at or above it on the prior bar triggers a bear structural break.
[*][i]Cooloff Enforcement[/i]: A configurable minimum bar distance between consecutive bullish and bearish signals is enforced independently for each direction, preventing signal clustering during volatile structural events.
[*][i]BOS or CHoCH Classification[/i]: Each qualifying break is classified by comparing its direction to the current structural trend state. A bullish break during a bearish or neutral structural trend registers as CHoCH. A bullish break during an existing bullish structural trend registers as BOS. The same logic applies in reverse for bearish breaks.
[*][i]Structural Level Plotting[/i]: A dashed line extends from the origin bar of the breached pivot to the signal bar at the pivot level, with a text label centered along the line displaying either BOS or CHoCH in the appropriate directional color.
[*][i]Position Tool Deployment[/i]: On CHoCH events with the position tool enabled, entry is set to the open of the following bar, stop loss is derived from the signal bar's low or high with a percentage buffer applied, risk is calculated as the entry-to-stop distance, and three take profit levels are plotted at configurable R multiples above or below entry.
[*][i]Position Zone Visualization[/i]: Gradient-filled boxes cover the risk zone between entry and stop loss, and the reward zones between each consecutive take profit level, extending rightward for the configured number of bars with opacity increasing at greater distances from entry.
[*][i]Candle Coloring[/i]: Optional bar coloring applies the bullish or bearish color based on current structural trend state, providing continuous directional context independent of Hull trend or signal generation.
[/list]
Together, these elements form a momentum-filtered structure detection system that classifies each qualifying event, plots the originating level, and translates reversal breaks into ready-to-use trade planning frameworks.

[b]Interpretation[/b]

Hull Market Structure should be interpreted as a momentum-validated structural event system with integrated position planning output:
[list]
[*][i]Hull Band Fill[/i]: The filled area between the Hull line and its two-bar-lagged value provides a continuous visual reference for Hull trend state and direction, coloring green during bullish Hull trend and red during bearish Hull trend.
[*][i]BOS Label[/i]: Appears on a structural break that occurs in the same direction as the existing structural trend, confirming trend continuation through a new swing level breach with Hull momentum aligned.
[*][i]CHoCH Label[/i]: Appears on a structural break that contradicts the existing structural trend, signaling a potential trend reversal where price has breached a swing level in the opposing direction with Hull momentum confirming.
[*][i]Structural Level Lines[/i]: Dashed lines extending from the breached pivot's origin bar to the signal bar mark the exact level at which the structural event occurred, providing historical reference for the significance of each break.
[*][i]Position Entry Line[/i]: Solid horizontal line at the open price of the bar following a CHoCH, representing the suggested trade entry level for the structural reversal setup.
[*][i]Stop Loss Line[/i]: Dotted line below entry for long positions and above entry for short positions, calculated from the CHoCH bar's extreme with a configurable percentage buffer applied for risk breathing room.
[*][i]TP1 / TP2 / TP3 Lines[/i]: Dotted take profit lines at configurable R multiples from entry, providing a three-stage exit framework scaled to the measured risk of each individual setup.
[*][i]Risk and Reward Zones[/i]: Gradient-filled boxes between entry and stop loss and between consecutive take profit levels provide immediate visual risk-to-reward assessment without manual calculation.
[*][i]Colored Candles[/i]: Optional bar coloring reflects current structural trend state, with bullish color applied after a bullish structural break and bearish color applied after a bearish structural break until the opposing direction breaks.
[/list]
Hull trend alignment, structural classification, and position tool levels collectively provide more information than any element in isolation.

[b]Signal Logic & Visual Cues[/b]

Hull Market Structure presents two structural signal types with distinct strategic implications:
[list=1]
[*][i]BOS (Break of Structure)[/i]: Labeled in the trend direction color when a swing level is breached in alignment with the existing structural trend. Represents continuation of the established structural sequence and does not trigger position tool deployment.
[*][i]CHoCH (Change of Character)[/i]: Labeled in the trend direction color when a swing level is breached against the existing structural trend. Represents a potential structural reversal and triggers position tool deployment when the feature is enabled.
[/list]
Both signal types require Hull trend alignment to fire, ensuring that structural events are always evaluated in their momentum context. The cooloff parameter prevents successive signals of the same type from clustering within a defined bar window.

Alert generation covers bullish and bearish BOS events and bullish and bearish CHoCH events independently for systematic structural monitoring and notification workflows.

[b]Strategy Integration[/b]

Hull Market Structure fits within momentum-validated market structure and systematic trade planning approaches:
[list]
[*][i]CHoCH Reversal Entries[/i]: Use CHoCH signals as primary entry triggers where structural trend has reversed with Hull momentum confirming, deploying the position tool output as a complete trade framework from entry through to final target.
[*][i]BOS Continuation Entries[/i]: Use BOS signals as confirmation of trend continuation within an established structural direction, timing pullback entries or adding to existing positions when structure is reinforcing rather than reversing.
[*][i]Hull Alignment Filtering[/i]: Treat signals that occur when Hull trend has only recently flipped with greater caution than signals where Hull has been trending in the signal direction for multiple bars, as recent Hull flips carry less momentum confirmation than sustained directional readings.
[*][i]R-Multiple Position Management[/i]: Use the three take profit levels from the position tool as a staged exit framework, scaling out of positions progressively rather than targeting a single fixed level, allowing partial profit capture while maintaining exposure to larger structural moves.
[*][i]Stop Buffer Calibration[/i]: Adjust the SL Buffer percentage to accommodate the instrument's typical spread and volatility at structural levels, ensuring stops are positioned with sufficient room to avoid premature invalidation on normal retest activity.
[*][i]Multi-Timeframe Structure Hierarchy[/i]: Apply higher-timeframe CHoCH events as directional bias anchors, using lower-timeframe BOS signals to time continuation entries within the broader structural context established by the higher-timeframe reversal.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Core Engine[/i]: Hull Moving Average with two-bar lag comparison for responsive directional trend state
[*][i]Swing Detection[/i]: Configurable pivot high and low confirmation with left-right bar symmetry requirement
[*][i]Structure Logic[/i]: Hull-gated swing break detection with independent bull and bear cooloff enforcement
[*][i]Classification System[/i]: Structural trend state tracking for BOS versus CHoCH labeling on each qualifying break
[*][i]Position Tool[/i]: CHoCH-triggered entry, buffered stop loss, and three R-multiple take profit level calculation
[*][i]Visualization[/i]: Dashed structural level lines, gradient-filled risk and reward zones, dotted take profit lines, and BOS or CHoCH labels
[*][i]Candle Coloring[/i]: Structural trend state-driven bar color independent of Hull trend state
[*][i]Performance Profile[/i]: Optimized for real-time execution with configurable position count management removing oldest position tools when the maximum is exceeded
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Intraday structure detection for scalping with shorter Hull length and tighter swing settings for fast structural response
[*][i]15 - 60 min[/i]: Session-level BOS and CHoCH identification with balanced Hull length and swing sensitivity
[*][i]4H - Daily[/i]: Swing-level structural trend mapping with longer Hull periods for sustained momentum validation
[/list]
Suggested Baseline Configuration:
[list]
[*][i]Hull Length[/i]: 50
[*][i]Swing Length[/i]: 5
[*][i]Signal Cooloff[/i]: 10
[*][i]SL Buffer %[/i]: 0.1
[*][i]Show Position Tool[/i]: Enabled
[*][i]Max Positions Visible[/i]: 2
[*][i]TP1 (R)[/i]: 1.0
[*][i]TP2 (R)[/i]: 2.0
[*][i]TP3 (R)[/i]: 3.0
[*][i]Color Candles[/i]: Enabled
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's structural characteristics, volatility profile, and preferred signal frequency, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Too many signals firing[/i]: Increase Signal Cooloff to enforce greater bar separation between consecutive structural events, or increase Swing Length to demand more structurally significant pivot confirmations.
[*][i]Signals too infrequent[/i]: Decrease Swing Length toward 2 for faster pivot confirmation, or reduce Signal Cooloff to allow signals to fire closer together during active structural periods.
[*][i]Hull trend too reactive[/i]: Increase Hull Length to smooth the momentum filter and reduce sensitivity to short-term price fluctuations that cause rapid Hull direction changes.
[*][i]Hull trend too slow[/i]: Decrease Hull Length toward 20 for a more responsive momentum filter that captures structural shifts earlier relative to price movement.
[*][i]Stop loss too tight[/i]: Increase SL Buffer percentage to add more breathing room beyond the signal bar extreme, reducing the likelihood of premature stop-outs on retest activity at structural levels.
[*][i]Position tools cluttering the chart[/i]: Reduce Max Positions Visible to limit the number of active position frameworks displayed, or decrease Position Extend to shorten how far levels project to the right.
[*][i]Take profit levels too close or far[/i]: Adjust TP1, TP2, and TP3 R multiples to match the instrument's typical range extension following structural breaks, calibrating the exit framework to realistic reward expectations for the target market.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]Trending markets where Hull direction persists across multiple sessions and structural breaks consistently follow the momentum direction, producing high-quality BOS and CHoCH alignments
[*]Instruments with clean swing structure where pivot highs and lows form at clearly defined levels, reducing ambiguity in structural break identification
[*]Reversal trading approaches where CHoCH detection with position tool output provides a systematic framework for entering structural trend changes with defined risk parameters
[*]Multi-timeframe workflows where higher-timeframe CHoCH signals establish directional bias and lower-timeframe BOS signals provide continuation timing precision
[/list]
Reduced Effectiveness:
[list]
[*]Choppy, range-bound markets where Hull trend direction changes frequently and structural breaks fire in alternating directions without establishing sustained structural sequences
[*]Low-volatility consolidation environments where swing pivots form in tight clusters, producing overlapping structural levels and ambiguous BOS or CHoCH classifications
[*]Highly news-driven instruments where impulsive moves create structural breaks that immediately reverse before the position tool levels are reached
[*]Markets with irregular spread or thin liquidity where pivot confirmation mechanics lag significantly behind the price events that created the structural swing
[*]Instruments where the relationship between Hull trend and structural breaks is inconsistent, requiring additional confluence tools to validate signal quality before deployment
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves volume tools, order flow analysis, or adaptive band indicators for structural signal validation across multiple analytical dimensions
[*][i]Hull Trend Respect[/i]: Treat CHoCH signals occurring when Hull has only recently reversed direction with reduced confidence relative to signals where Hull has sustained the new direction across multiple bars
[*][i]Classification Awareness[/i]: Distinguish between BOS and CHoCH in strategy application; BOS signals support continuation approaches while CHoCH signals support reversal entries, and mixing the two without adaptation reduces strategic clarity
[*][i]Position Tool Discipline[/i]: Use the position tool output as a complete trade framework rather than selectively taking only entry or stop information, as the R-multiple target structure is calibrated to the specific risk measured from each individual CHoCH event
[*][i]State Discipline[/i]: Maintain directional bias aligned with current structural trend state until a CHoCH in the opposing direction is confirmed. Isolated price excursions against the structural trend that do not breach the relevant swing level do not constitute structural changes.
[/list]
[b]Disclaimer[/b]

Hull Market Structure [BOSWaves] is a professional-grade market structure and trade planning tool. It uses Hull-filtered break of structure detection with swing pivot classification and integrated position sizing but does not predict future price movements. Results depend on market conditions, instrument structural characteristics, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates volume context, order flow analysis, and comprehensive risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Hull Market Structure [BOSWaves]", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string g1 = "Hull"
const string g2 = "Structure"
const string g3 = "Position Tool"
const string g4 = "Display"

int   hullLen    = input.int(50, "Hull Length", minval = 5, maxval = 200, group = g1, tooltip = "Period for the Hull Moving Average. Lower = faster, higher = smoother.")

int   swingLen   = input.int(5, "Swing Length", minval = 2, maxval = 20, group = g2, tooltip = "Bars left/right to confirm swing highs and lows.")
int   cooloff    = input.int(10, "Signal Cooloff", minval = 3, maxval = 50, group = g2, tooltip = "Minimum bars between consecutive BOS/CHoCH signals.")
 
float slBuffer   = input.float(0.1, "SL Buffer %", minval = 0, maxval = 2, step = 0.05, group = g3, tooltip = "Extra percentage added to the SL level for breathing room.")
bool  showPos    = input.bool(true, "Show Position Tool", group = g3, tooltip = "Plots entry, SL and TP levels on the bar after a CHoCH signal.")
int   maxPos     = input.int(2, "Max Positions Visible", minval = 1, maxval = 10, group = g3, tooltip = "Limits how many position tools are shown on the chart. Oldest are removed first.")
float tp1R       = input.float(1.0, "TP1 (R)", minval = 0.5, maxval = 5.0, step = 0.5, group = g3, tooltip = "First take profit as a multiple of risk.")
float tp2R       = input.float(2.0, "TP2 (R)", minval = 1.0, maxval = 10.0, step = 0.5, group = g3, tooltip = "Second take profit as a multiple of risk.")
float tp3R       = input.float(3.0, "TP3 (R)", minval = 1.5, maxval = 15.0, step = 0.5, group = g3, tooltip = "Third take profit as a multiple of risk.")
int   posExtend  = input.int(30, "Position Extend", minval = 10, maxval = 100, group = g3, tooltip = "How far the position tool levels extend to the right.")

bool  paintBar   = input.bool(true, "Color Candles", group = g4)
color bullCol    = input.color(#00ff88, "Bullish", inline = "c", group = g4)
color bearCol    = input.color(#ff3366, "Bearish", inline = "c", group = g4)

// ┌────────────────────────────── BOSWaves ─ Hull MA ────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float hull      = ta.hma(close, hullLen)
int   hullTrend = hull > hull[2] ? 1 : hull < hull[2] ? -1 : 0
float atr       = ta.atr(14)
color hullCol   = hullTrend == 1 ? bullCol : bearCol

pHull1 = plot(hull, "Hull", color.new(hullCol,60), 1)
pHull2 = plot(hull[2], "Hull Trail", color.new(hullCol,60), 1)
fill(pHull1, pHull2, color.new(hullCol, 60))

// ┌────────────────────────────── BOSWaves ─ Swing Detection ────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low, swingLen, swingLen)

var int structTrend = 0
var float currSwHi     = na
var int   currSwHiBar  = na
var float currSwLo     = na
var int   currSwLoBar  = na
var float prevSwHi     = na
var float prevSwLo     = na
var int   prevSwHiBar  = na
var int   prevSwLoBar  = na

if not na(ph)
    prevSwHi    := currSwHi
    prevSwHiBar := currSwHiBar
    currSwHi    := high[swingLen]
    currSwHiBar := bar_index - swingLen

if not na(pl)
    prevSwLo    := currSwLo
    prevSwLoBar := currSwLoBar
    currSwLo    := low[swingLen]
    currSwLoBar := bar_index - swingLen

 
  
// ┌────────────────────────────── BOSWaves ─ Position Tool Storage ──────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var posLines  = array.new<line>()
var posBoxes  = array.new<box>()
var posLabels = array.new<label>()
var int posCount = 0

// ┌────────────────────────────── BOSWaves ─ BOS / CHoCH ────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var int lastBullSignal = na
var int lastBearSignal = na

bool canBull = na(lastBullSignal) or (bar_index - lastBullSignal) >= cooloff
bool canBear = na(lastBearSignal) or (bar_index - lastBearSignal) >= cooloff

bool bullBreak = canBull and hullTrend == 1 and not na(prevSwHi) and close > prevSwHi and close[1] <= prevSwHi
bool bearBreak = canBear and hullTrend == -1 and not na(prevSwLo) and close < prevSwLo and close[1] >= prevSwLo

var bool  pendingBullPos = false
var bool  pendingBearPos = false
var float pendingSL      = na

if bullBreak
    lastBullSignal := bar_index

    bool isCHoCH = structTrend <= 0
    string txt   = isCHoCH ? "CHoCH" : "BOS"
    structTrend  := 1

    int originBar = nz(prevSwHiBar, bar_index - 10)
    float level   = prevSwHi

    line.new(originBar, level, bar_index, level,
         color = color.new(bullCol, 40), width = 1, style = line.style_dashed)

    int midBar = originBar + int((bar_index - originBar) / 2)
    label.new(midBar, level, txt,
         style = label.style_none,
         textcolor = bullCol,
         size = isCHoCH ? size.normal : size.small)

    float slLevel = low * (1 - slBuffer / 100)
 

    if isCHoCH and showPos
        pendingBullPos := true
        pendingSL      := slLevel

if bearBreak
    lastBearSignal := bar_index

    bool isCHoCH = structTrend >= 0
    string txt   = isCHoCH ? "CHoCH" : "BOS"
    structTrend  := -1

    int originBar = nz(prevSwLoBar, bar_index - 10)
    float level   = prevSwLo

    line.new(originBar, level, bar_index, level,
         color = color.new(bearCol, 40), width = 1, style = line.style_dashed)

    int midBar = originBar + int((bar_index - originBar) / 2)
    label.new(midBar, level, txt,
         style = label.style_none,
         textcolor = bearCol,
         size = isCHoCH ? size.normal : size.small)

    float slLevel = high * (1 + slBuffer / 100)
 

    if isCHoCH and showPos
        pendingBearPos := true
        pendingSL      := slLevel

// ┌────────────────────────────── BOSWaves ─ Position Tool ──────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if pendingBullPos
    pendingBullPos := false

    float entry = open
    float sl    = pendingSL
    float risk  = entry - sl
    float tp1   = entry + risk * tp1R
    float tp2   = entry + risk * tp2R
    float tp3   = entry + risk * tp3R
    int   ext   = bar_index + posExtend

    posLines.push(line.new(bar_index, entry, ext, entry,
         color = color.new(bullCol, 20), width = 1, style = line.style_solid))
    posLines.push(line.new(bar_index, tp1, ext, tp1,
         color = color.new(bullCol, 40), width = 1, style = line.style_dotted))
    posLines.push(line.new(bar_index, tp2, ext, tp2,
         color = color.new(bullCol, 50), width = 1, style = line.style_dotted))
    posLines.push(line.new(bar_index, tp3, ext, tp3,
         color = color.new(bullCol, 60), width = 1, style = line.style_dotted))
    posLines.push(line.new(bar_index, sl, ext, sl,
         color = color.new(bearCol, 30), width = 1, style = line.style_dotted))

    posBoxes.push(box.new(bar_index, tp1, ext, entry,
         border_color = color.new(bullCol, 80), bgcolor = color.new(bullCol, 92), border_width = 0))
    posBoxes.push(box.new(bar_index, tp2, ext, tp1,
         border_color = color.new(bullCol, 85), bgcolor = color.new(bullCol, 94), border_width = 0))
    posBoxes.push(box.new(bar_index, tp3, ext, tp2,
         border_color = color.new(bullCol, 88), bgcolor = color.new(bullCol, 95), border_width = 0))
    posBoxes.push(box.new(bar_index, entry, ext, sl,
         border_color = color.new(bearCol, 85), bgcolor = color.new(bearCol, 95), border_width = 0))

    posLabels.push(label.new(ext, entry, "Entry " + str.tostring(entry, format.mintick),
         style = label.style_none, textcolor = color.new(bullCol, 10), size = size.normal))
    posLabels.push(label.new(ext, tp1, "TP1 " + str.tostring(tp1R, "#.#") + "R",
         style = label.style_none, textcolor = color.new(bullCol, 20), size = size.normal))
    posLabels.push(label.new(ext, tp2, "TP2 " + str.tostring(tp2R, "#.#") + "R",
         style = label.style_none, textcolor = color.new(bullCol, 30), size = size.normal))
    posLabels.push(label.new(ext, tp3, "TP3 " + str.tostring(tp3R, "#.#") + "R",
         style = label.style_none, textcolor = color.new(bullCol, 40), size = size.normal))
    posLabels.push(label.new(ext, sl, "SL " + str.tostring(sl, format.mintick),
         style = label.style_none, textcolor = color.new(bearCol, 20), size = size.normal))

    posCount += 1
    while posCount > maxPos
        for _j = 0 to 4
            if posLines.size() > 0
                posLines.shift().delete()
        for _j = 0 to 3
            if posBoxes.size() > 0
                posBoxes.shift().delete()
        for _j = 0 to 4
            if posLabels.size() > 0
                posLabels.shift().delete()
        posCount -= 1

if pendingBearPos
    pendingBearPos := false

    float entry = open
    float sl    = pendingSL
    float risk  = sl - entry
    float tp1   = entry - risk * tp1R
    float tp2   = entry - risk * tp2R
    float tp3   = entry - risk * tp3R
    int   ext   = bar_index + posExtend

    posLines.push(line.new(bar_index, entry, ext, entry,
         color = color.new(bearCol, 20), width = 1, style = line.style_solid))
    posLines.push(line.new(bar_index, tp1, ext, tp1,
         color = color.new(bearCol, 40), width = 1, style = line.style_dotted))
    posLines.push(line.new(bar_index, tp2, ext, tp2,
         color = color.new(bearCol, 50), width = 1, style = line.style_dotted))
    posLines.push(line.new(bar_index, tp3, ext, tp3,
         color = color.new(bearCol, 60), width = 1, style = line.style_dotted))
    posLines.push(line.new(bar_index, sl, ext, sl,
         color = color.new(bullCol, 30), width = 1, style = line.style_dotted))

    posBoxes.push(box.new(bar_index, entry, ext, tp1,
         border_color = color.new(bearCol, 80), bgcolor = color.new(bearCol, 92), border_width = 0))
    posBoxes.push(box.new(bar_index, tp1, ext, tp2,
         border_color = color.new(bearCol, 85), bgcolor = color.new(bearCol, 94), border_width = 0))
    posBoxes.push(box.new(bar_index, tp2, ext, tp3,
         border_color = color.new(bearCol, 88), bgcolor = color.new(bearCol, 95), border_width = 0))
    posBoxes.push(box.new(bar_index, sl, ext, entry,
         border_color = color.new(bullCol, 85), bgcolor = color.new(bullCol, 95), border_width = 0))

    posLabels.push(label.new(ext, entry, "Entry " + str.tostring(entry, format.mintick),
         style = label.style_none, textcolor = color.new(bearCol, 10), size = size.normal))
    posLabels.push(label.new(ext, tp1, "TP1 " + str.tostring(tp1R, "#.#") + "R",
         style = label.style_none, textcolor = color.new(bearCol, 20), size = size.normal))
    posLabels.push(label.new(ext, tp2, "TP2 " + str.tostring(tp2R, "#.#") + "R",
         style = label.style_none, textcolor = color.new(bearCol, 30), size = size.normal))
    posLabels.push(label.new(ext, tp3, "TP3 " + str.tostring(tp3R, "#.#") + "R",
         style = label.style_none, textcolor = color.new(bearCol, 40), size = size.normal))
    posLabels.push(label.new(ext, sl, "SL " + str.tostring(sl, format.mintick),
         style = label.style_none, textcolor = color.new(bullCol, 20), size = size.normal))

    posCount += 1
    while posCount > maxPos
        for _j = 0 to 4
            if posLines.size() > 0
                posLines.shift().delete()
        for _j = 0 to 3
            if posBoxes.size() > 0
                posBoxes.shift().delete()
        for _j = 0 to 4
            if posLabels.size() > 0
                posLabels.shift().delete()
        posCount -= 1

// ┌────────────────────────────── BOSWaves ─ Candles + BG ───────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
color trendCol = structTrend == 1 ? bullCol : structTrend == -1 ? bearCol : color.gray

barcolor(paintBar ? color.new(trendCol, 30) : na)
 
// ┌────────────────────────────── BOSWaves ─ Alerts ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
alertcondition(bullBreak, "Bullish BOS", "Bullish break of structure on {{ticker}}")
alertcondition(bearBreak, "Bearish BOS", "Bearish break of structure on {{ticker}}")
alertcondition(bullBreak and structTrend <= 0, "Bullish CHoCH", "Change of character bullish on {{ticker}}")
alertcondition(bearBreak and structTrend >= 0, "Bearish CHoCH", "Change of character bearish on {{ticker}}")
````
