# ElliottABC Pulse Multi-Timeframe Correction Mapper

- url: https://www.tradingview.com/script/erKO2XeZ/
- type: indicator
- pine_id: PUB;35172c33045b421f8585fe30e7a38a8e
- version: 1.0

## Description

ElliottABC Pulse – Multi-Timeframe Correction Mapper

ElliottABC Pulse automatically identifies and labels Elliott Wave ABC corrective structures across up to ten simultaneous timeframes, combining classical wave theory with Fibonacci ratio validation, RSI confluence filtering, and a real-time signal scoring engine — all rendered as a single chart overlay.

Instead of manually hunting for corrective patterns on each timeframe separately, this indicator scans pivot structures across all selected timeframes at once and presents a consolidated dashboard showing signal direction, elapsed time since formation, and a composite quality score for every active timeframe.


What Is an ABC Correction?

In Elliott Wave theory, markets move in two phases: impulsive waves (in the direction of the trend) and corrective waves (counter-trend). The ABC correction is the most common corrective structure, consisting of three legs:


Wave A — The initial counter-trend move from a swing high or low
Wave B — A partial retracement back toward the origin of wave A
Wave C — A final push in the direction of wave A, typically equal to or extending beyond wave A


When the C wave completes, price often resumes the original trend direction — making C completions high-probability areas for re-entry or reversal trades.

This indicator detects two variants:


Descending ABC (H-L-H-L): A bearish correction that resolves into a potential bullish continuation. The C wave terminates below the B wave origin.
Ascending ABC (L-H-L-H): A bullish correction that resolves into a potential bearish continuation. The C wave terminates above the B wave origin.



Features


Automatic ABC corrective pattern detection using zigzag pivot filtering
Strict Fibonacci ratio validation for both wave B retracement and wave C extension
Optional RSI momentum confluence filter
Real-time 0–100 composite signal scoring system
Fibonacci target projection levels (1.000×A, 1.272×A, 1.618×A)
B wave retracement grid (38.2%, 50.0%, 61.8%)
Expected direction arrow projected from the C completion point
Duplicate-safe drawing engine — the same pattern is never drawn twice
Multi-timeframe dashboard across up to 10 user-defined timeframes
Color-coded elapsed time indicator (fresh / aging / stale signals)
Clean, non-repainting overlay with full input customization



How It Works

Pivot Detection
The indicator uses Pine Script's ta.pivothigh() and ta.pivotlow() functions with user-defined left and right bar counts to identify structural swing highs and lows. A zigzag filter (Min. Swing Size %) discards any pivot where the price move is smaller than the defined percentage threshold, eliminating micro-noise from the pivot array and keeping only meaningful structural swings.

Pivots are stored in an alternating high/low array. If two consecutive pivots occur in the same direction, only the more extreme one is kept — ensuring the zigzag structure is always clean and directionally alternating.

ABC Validation
Each candidate pattern is tested against five conditions simultaneously:

ConditionRequirementAlternating structurePivots must follow strict H-L-H-L or L-H-L-H alternationB retracement (min)Wave B must retrace at least Min A-B Retracement of wave A (default 38.2%)B retracement (max)Wave B must not retrace more than Max A-B Retracement of wave A (default 88.6%)C extension (min)Wave C must extend at least Min C Extension of wave A (default 1.0×)C extension (max)Wave C must not extend beyond Max C Extension of wave A (default 1.618×)Structural integrityC must break B's origin; B must not exceed A's originRSI confluence (optional)Descending ABC: RSI < 50 / Ascending ABC: RSI > 50

The indicator scans up to 6 consecutive pivot windows on each bar update, so it catches both fresh and recently formed patterns without missing setups due to pivot array timing.

Duplicate Prevention
A dedicated index array tracks the bar position of each pattern's A pivot. Once a pattern is drawn, its A bar index is recorded and skipped on all future bar updates — preventing the redraw artifacts common in pivot-based indicators.

Signal Scoring (0–100)
Every confirmed ABC pattern receives a composite score from four independent components:

ComponentMax ScoreConditionB Fibonacci Zone30 ptsB retracement within 0.500–0.618 (golden zone) scores full; 0.382–0.786 scores partialC Extension Zone25 ptsC extension within 1.0–1.272 (classic target) scores full; 1.272–1.618 scores partialRSI Extreme Zone25 ptsRSI below 30 (Bull) or above 70 (Bear) scores full; partial credit between 30–50 or 50–70A Wave Magnitude20 ptsWave A spanning ≥ 2% of price scores full; ≥ 1% scores partial

Scores of 70 or above indicate high-quality setups. Scores between 40–69 are moderate. Below 40 suggests marginal structure — still valid, but lower-conviction.


Chart Overlays

When a valid ABC is confirmed, the following elements are drawn directly on the chart:


Wave labels: A at the origin, B with its retracement percentage, C with its extension multiplier, and C✓ at the completion point
Connecting lines: Segment lines linking A → B → C → C✓
Fibonacci extension levels: Three dotted horizontal lines projected from the C pivot — 1.000×A, 1.272×A, and 1.618×A — showing classic C wave targets
B retracement grid: Three dashed horizontal levels at 38.2%, 50.0%, and 61.8% between A and B for precision B entry zones
Direction arrow: A projected arrow from the C✓ point toward the A-B midpoint, visually indicating the expected post-correction move direction



Multi-Timeframe Dashboard

The bottom-right table runs the full ABC detection engine independently on each of the 10 configured timeframes using request.security() with lookahead_off to prevent any future data leakage.

Each row in the table shows:

ColumnDescriptionTimeframeThe TF label as configured (e.g. 15, 60, 240, D)ABC Status▲ Ascending ABC / ▼ Descending ABC / — NoneWhenHow long ago the C pivot formed — color-coded green (< 30 min), yellow (< 4 hr), gray (older)C ProbabilityThe composite 0–100 score, color-coded green / yellow / red by strength tier

A summary row at the top displays the total count of bullish and bearish signals across all timeframes, plus the current RSI reading color-coded by zone. When multiple timeframes simultaneously show the same signal direction, confluence is high and setup quality increases significantly.


How To Use

Basic Setup


Add the indicator to your chart on any timeframe
Set TF 1 through TF 10 to the timeframes you want to monitor simultaneously (e.g. 15m, 30m, 1H, 2H, 4H, 6H, 8H, 12H, D, 3D)
Watch the bottom-right dashboard for active ABC signals across all timeframes


Tuning Pivot Sensitivity


Increase Left Bars / Right Bars for fewer, stronger pivots (better for higher timeframe structure)
Decrease them for more frequent, shorter-term pivots (better for intraday scalping)
Raise Min. Swing Size (%) to filter out noisy pivots on volatile assets such as crypto


Tuning ABC Strictness


Tighten Min/Max A-B Retracement to focus only on golden zone retracements (0.5–0.618)
Narrow Min/Max C Extension to require only classic C targets (1.0–1.272)
Enable RSI Divergence Filter on trending instruments for higher-conviction signals


Reading the Dashboard


Prioritize signals where 3 or more timeframes show the same direction simultaneously
Prefer signals with scores of 70 or above for the clearest Fibonacci structure
Use the When column to avoid acting on stale signals — fresh signals (green) carry more weight
Cross-reference with the current RSI reading in the summary row for momentum context


Fibonacci Levels


The 1.000×A level is the minimum expected C target — often used as a conservative take-profit
The 1.272×A level is the most common termination zone for standard ABC patterns
The 1.618×A level marks the extended C target — relevant in high-momentum corrective moves
The B retracement grid (38.2% / 50% / 61.8%) helps identify optimal B-wave entry levels before C begins



Recommended Use Cases


Intraday traders: Configure TF 1–5 as 5m / 15m / 30m / 1H / 2H. Look for ABC completions on the 15m or 30m confirmed by a matching signal on the 1H or 2H for intrabar precision entries.
Swing traders: Use 1H / 4H / 6H / 12H / Daily / 3D. Wait for the daily or 3D to print a fresh high-score ABC before entering on a lower timeframe pullback.
Multi-timeframe analysts: Monitor confluence across all 10 timeframes. When 4 or more timeframes simultaneously show the same signal type with scores above 60, the corrective structure is likely significant on the macro level.



Originality

This script is an original work combining zigzag-filtered pivot detection, simultaneous ten-timeframe ABC corrective pattern validation, a four-component signal scoring engine, and a proximity-safe duplicate prevention system. While Elliott Wave ABC detection is a known concept, the specific implementation — the alternating zigzag array, the 6-window sliding pattern scan, the composite scoring model, and the fully integrated MTF dashboard with elapsed-time coloring — represents the author's own approach to making corrective wave analysis practical and actionable on a live chart.


Limitations


RSI filtering uses the current bar RSI as an approximation for pivot-bar RSI. This is a deliberate simplification that improves signal quality on trending instruments but may occasionally exclude valid setups during consolidation.
The pivot array is capped at 50 pivots and the drawing history arrays at 100 entries to maintain performance. On very active instruments with tight pivot settings, the oldest patterns scroll off automatically.
TradingView's runtime limit of 500 labels and 500 lines applies. On charts with a very long history and tight pivot settings, older drawings are removed by the platform.
This tool is designed for confluence analysis and structural context, not as a standalone mechanical entry system. Always integrate with broader market structure, session context, and sound risk management.



Disclaimer

This indicator is intended for educational and analytical purposes only. No indicator can predict future market movements with certainty. Always use proper risk management and combine multiple forms of analysis before making trading decisions.


TradingView Short Description:
Automatically detect Elliott Wave ABC corrective completions across up to 10 timeframes. Features Fibonacci ratio validation, RSI confluence filtering, a 0–100 signal scoring engine, and a live multi-timeframe dashboard showing signal direction, elapsed time, and setup quality — all in a single chart overlay.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Onuriano


//@version=6
indicator('ElliottABC Pulse Multi-Timeframe Correction Mapper', overlay = true, max_labels_count = 500, max_lines_count = 500)

// ============================================================
// SETTINGS
// ============================================================
leftBars = input.int(3, 'Left Bars (Pivot)', minval = 1, maxval = 50, group = 'Pivot')
rightBars = input.int(2, 'Right Bars (Pivot)', minval = 1, maxval = 50, group = 'Pivot')

// Zigzag filter: reduces noise by eliminating small pivots
minSwingPct = input.float(0.5, 'Min. Swing Size (%)', minval = 0.1, maxval = 10.0, step = 0.1, group = 'Pivot', tooltip = 'Minimum price movement percentage to filter out very small pivots. Increasing it gives fewer but cleaner signals.')

showLines = input.bool(true, 'Lines', group = 'ABC')
showFib = input.bool(true, 'Fibonacci Targets', group = 'ABC')
showRSI = input.bool(true, 'RSI Divergence Filter', group = 'ABC', tooltip = 'When on: C wave must be aligned with RSI (fewer but higher-quality signals)')

// ABC Filters
minABRatio = input.float(0.382, 'Min A-B Retracement', minval = 0.1, maxval = 0.99, step = 0.01, group = 'ABC Filters', tooltip = 'Minimum retracement of wave B relative to wave A. Default: 38.2%')
maxABRatio = input.float(0.886, 'Max A-B Retracement', minval = 0.1, maxval = 1.5, step = 0.01, group = 'ABC Filters', tooltip = 'Maximum retracement of wave B relative to wave A. Default: 88.6%')
minBCRatio = input.float(1.0, 'Min C Extension (×A)', minval = 0.5, maxval = 3.0, step = 0.01, group = 'ABC Filters', tooltip = 'Minimum length of wave C relative to wave A. Default: 1.0×A')
maxBCRatio = input.float(1.618, 'Max C Extension (×A)', minval = 0.5, maxval = 4.0, step = 0.01, group = 'ABC Filters', tooltip = 'Maximum length of wave C relative to wave A. Default: 1.618×A')

colorCorr = input.color(#FF9800, 'ABC Color', group = 'Colors')
colorFib = input.color(color.new(#64B5F6, 60), 'Fibonacci', group = 'Colors')
colorTable = input.color(color.new(#1565C0, 30), 'Table Background', group = 'Colors')

// MTF Timeframe selections
tf1 = input.timeframe('15', 'TF 1', group = 'Multi-Timeframe Table')
tf2 = input.timeframe('30', 'TF 2', group = 'Multi-Timeframe Table')
tf3 = input.timeframe('60', 'TF 3', group = 'Multi-Timeframe Table')
tf4 = input.timeframe('120', 'TF 4', group = 'Multi-Timeframe Table')
tf5 = input.timeframe('240', 'TF 5', group = 'Multi-Timeframe Table')
tf6 = input.timeframe('360', 'TF 6', group = 'Multi-Timeframe Table')
tf7 = input.timeframe('480', 'TF 7', group = 'Multi-Timeframe Table')
tf8 = input.timeframe('720', 'TF 8', group = 'Multi-Timeframe Table')
tf9 = input.timeframe('D', 'TF 9', group = 'Multi-Timeframe Table')
tf10 = input.timeframe('3D', 'TF 10', group = 'Multi-Timeframe Table')

// ============================================================
// RSI (for signal confirmation)
// ============================================================
rsiVal = ta.rsi(close, 14)

// ============================================================
// PIVOT STORAGE (Zigzag filtered)
// ============================================================
var array<float> PP = array.new_float()
var array<int> PB = array.new_int()
var array<bool> PH = array.new_bool()

// To prevent duplicate drawing: which pattern's A bar index has already been drawn
var array<int> drawnA = array.new_int()

ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low, leftBars, rightBars)

// Zigzag filter: is the pivot large enough?
phValid = not na(ph) and ph / close * 100 >= minSwingPct
plValid = not na(pl) and math.abs(pl - close) / close * 100 >= minSwingPct

if phValid
    sz = array.size(PP)
    if sz > 0
        if array.get(PH, sz - 1) == true
            // Same direction: keep the higher one
            if ph > array.get(PP, sz - 1)
                array.set(PP, sz - 1, ph)
                array.set(PB, sz - 1, bar_index - rightBars)
        else // Different direction: add
            array.push(PP, ph)
            array.push(PB, bar_index - rightBars)
            array.push(PH, true)
    else
        array.push(PP, ph)
        array.push(PB, bar_index - rightBars)
        array.push(PH, true)

if plValid
    sz = array.size(PP)
    if sz > 0
        if array.get(PH, sz - 1) == false
            // Same direction: keep the lower one
            if pl < array.get(PP, sz - 1)
                array.set(PP, sz - 1, pl)
                array.set(PB, sz - 1, bar_index - rightBars)
        else // Different direction: add
            array.push(PP, pl)
            array.push(PB, bar_index - rightBars)
            array.push(PH, false)
    else
        array.push(PP, pl)
        array.push(PB, bar_index - rightBars)
        array.push(PH, false)

while array.size(PP) > 50
    array.shift(PP)
    array.shift(PB)
    array.shift(PH)

// ============================================================
// DRAWING HELPERS
// (no clearAll – past drawings are preserved)
// ============================================================
doLabel(b, p, isHigh, txt, clr) =>
    sty = isHigh ? label.style_label_down : label.style_label_up
    label.new(b, p, txt, color = clr, textcolor = color.white, style = sty, size = size.small)

doLine(b1, p1, b2, p2, clr) =>
    if showLines
        line.new(b1, p1, b2, p2, color = clr, width = 2)

doFib(b0, p0, b1, p1, b2, p2, isDown) =>
    if showFib
        aLen = math.abs(p1 - p0)
        t1 = isDown ? p1 - aLen * 1.0 : p1 + aLen * 1.0
        t2 = isDown ? p1 - aLen * 1.272 : p1 + aLen * 1.272
        t3 = isDown ? p1 - aLen * 1.618 : p1 + aLen * 1.618
        line.new(b2, t1, b2 + 10, t1, color = colorFib, style = line.style_dotted, width = 1)
        line.new(b2, t2, b2 + 10, t2, color = colorFib, style = line.style_dotted, width = 1)
        line.new(b2, t3, b2 + 10, t3, color = colorFib, style = line.style_dotted, width = 1)
        label.new(b2 + 11, t1, '1.000×A', color = color.new(color.black, 100), textcolor = colorFib, style = label.style_label_left, size = size.small)
        label.new(b2 + 11, t2, '1.272×A', color = color.new(color.black, 100), textcolor = colorFib, style = label.style_label_left, size = size.small)
        label.new(b2 + 11, t3, '1.618×A', color = color.new(color.black, 100), textcolor = colorFib, style = label.style_label_left, size = size.small)
        // B retracement levels
        rng = p1 - p0
        r1 = p1 - rng * 0.382 * (isDown ? -1 : 1)
        r2 = p1 - rng * 0.500 * (isDown ? -1 : 1)
        r3 = p1 - rng * 0.618 * (isDown ? -1 : 1)
        line.new(b0, r1, b1 + 4, r1, color = color.new(colorFib, 75), style = line.style_dashed, width = 1)
        line.new(b0, r2, b1 + 4, r2, color = color.new(colorFib, 75), style = line.style_dashed, width = 1)
        line.new(b0, r3, b1 + 4, r3, color = color.new(colorFib, 75), style = line.style_dashed, width = 1)

// ============================================================
// ABC VALIDATION – including RSI divergence filter
// ============================================================

// Instead of using security to get RSI at pivot bar,
// we approximate using current bar RSI
isBullABC(i0) =>
    sz = array.size(PP)
    result = false
    if i0 >= 0 and i0 + 3 <= sz - 1
        p0 = array.get(PP, i0)
        p1 = array.get(PP, i0 + 1)
        p2 = array.get(PP, i0 + 2)
        p3 = array.get(PP, i0 + 3)
        h0 = array.get(PH, i0)
        h1 = array.get(PH, i0 + 1)
        h2 = array.get(PH, i0 + 2)
        h3 = array.get(PH, i0 + 3)
        // Structure: H-L-H-L (descending ABC)
        altOK = h0 and not h1 and h2 and not h3
        aWave = p0 - p1
        bRetr = (p2 - p1) / aWave
        cExt = (p2 - p3) / aWave
        bOK = bRetr >= minABRatio and bRetr <= maxABRatio
        cOK = cExt >= minBCRatio and cExt <= maxBCRatio
        // C must make new low, must not exceed B origin
        strOK = p3 < p1 and p2 < p0
        // RSI filter: after descending ABC, RSI must be in oversold zone (below 50)
        rsiOK = showRSI ? rsiVal < 50 : true
        result := altOK and bOK and cOK and strOK and rsiOK
        result
    result

isBearABC(i0) =>
    sz = array.size(PP)
    result = false
    if i0 >= 0 and i0 + 3 <= sz - 1
        p0 = array.get(PP, i0)
        p1 = array.get(PP, i0 + 1)
        p2 = array.get(PP, i0 + 2)
        p3 = array.get(PP, i0 + 3)
        h0 = array.get(PH, i0)
        h1 = array.get(PH, i0 + 1)
        h2 = array.get(PH, i0 + 2)
        h3 = array.get(PH, i0 + 3)
        // Structure: L-H-L-H (ascending ABC)
        altOK = not h0 and h1 and not h2 and h3
        aWave = p1 - p0
        bRetr = (p1 - p2) / aWave
        cExt = (p3 - p2) / aWave
        bOK = bRetr >= minABRatio and bRetr <= maxABRatio
        cOK = cExt >= minBCRatio and cExt <= maxBCRatio
        strOK = p3 > p1 and p2 > p0
        // RSI filter: after ascending ABC, RSI must be in overbought zone (above 50)
        rsiOK = showRSI ? rsiVal > 50 : true
        result := altOK and bOK and cOK and strOK and rsiOK
        result
    result

// ============================================================
// DRAWING FUNCTIONS
// ============================================================
drawBullABC(i0) =>
    p0 = array.get(PP, i0)
    p1 = array.get(PP, i0 + 1)
    p2 = array.get(PP, i0 + 2)
    p3 = array.get(PP, i0 + 3)
    h0 = array.get(PH, i0)
    h1 = array.get(PH, i0 + 1)
    h2 = array.get(PH, i0 + 2)
    h3 = array.get(PH, i0 + 3)
    b0 = array.get(PB, i0)
    b1 = array.get(PB, i0 + 1)
    b2 = array.get(PB, i0 + 2)
    b3 = array.get(PB, i0 + 3)
    aWave = p0 - p1
    bRetr = (p2 - p1) / aWave
    cExt = (p2 - p3) / aWave
    doLine(b0, p0, b1, p1, colorCorr)
    doLine(b1, p1, b2, p2, colorCorr)
    doLine(b2, p2, b3, p3, colorCorr)
    doLabel(b0, p0, h0, 'A', colorCorr)
    doLabel(b1, p1, h1, 'B ' + str.tostring(bRetr * 100, '#.#') + '%', colorCorr)
    doLabel(b2, p2, h2, 'C ' + str.tostring(cExt, '#.###') + '×A', colorCorr)
    doLabel(b3, p3, h3, 'C✓', color.new(colorCorr, 20))
    doFib(b0, p0, b1, p1, b2, p2, true)

drawBearABC(i0) =>
    p0 = array.get(PP, i0)
    p1 = array.get(PP, i0 + 1)
    p2 = array.get(PP, i0 + 2)
    p3 = array.get(PP, i0 + 3)
    h0 = array.get(PH, i0)
    h1 = array.get(PH, i0 + 1)
    h2 = array.get(PH, i0 + 2)
    h3 = array.get(PH, i0 + 3)
    b0 = array.get(PB, i0)
    b1 = array.get(PB, i0 + 1)
    b2 = array.get(PB, i0 + 2)
    b3 = array.get(PB, i0 + 3)
    aWave = p1 - p0
    bRetr = (p1 - p2) / aWave
    cExt = (p3 - p2) / aWave
    doLine(b0, p0, b1, p1, colorCorr)
    doLine(b1, p1, b2, p2, colorCorr)
    doLine(b2, p2, b3, p3, colorCorr)
    doLabel(b0, p0, h0, 'A', colorCorr)
    doLabel(b1, p1, h1, 'B ' + str.tostring(bRetr * 100, '#.#') + '%', colorCorr)
    doLabel(b2, p2, h2, 'C ' + str.tostring(cExt, '#.###') + '×A', colorCorr)
    doLabel(b3, p3, h3, 'C✓', color.new(colorCorr, 20))
    doFib(b0, p0, b1, p1, b2, p2, false)

// ============================================================
// MAIN LOGIC
// no clearAll → past patterns remain on screen
// drawnA list prevents same pattern from being drawn twice
// ============================================================
newPivot = phValid or plValid

if newPivot
    sz = array.size(PP)

    // Search ABC in 6 different windows (wider scan = more signals)
    for off = 0 to 5 by 1
        i0 = sz - 4 - off
        if i0 >= 0 and i0 + 3 <= sz - 1
            // Was this pattern already drawn? (checked by A pivot bar index)
            aBar = array.get(PB, i0)
            alreadyDrawn = false
            dSz = array.size(drawnA)
            if dSz > 0
                for k = 0 to dSz - 1 by 1
                    if array.get(drawnA, k) == aBar
                        alreadyDrawn := true
                        alreadyDrawn
            if not alreadyDrawn
                if isBullABC(i0)
                    drawBullABC(i0)
                    array.push(drawnA, aBar)
                else if isBearABC(i0)
                    drawBearABC(i0)
                    array.push(drawnA, aBar)

    // Limit drawnA list size
    while array.size(drawnA) > 100
        array.shift(drawnA)

// ============================================================
// PIVOT POINTS
// ============================================================
plotshape(ph, title = 'Peak', style = shape.triangledown, location = location.abovebar, color = color.new(#FF1744, 30), size = size.small, offset = -rightBars)
plotshape(pl, title = 'Trough', style = shape.triangleup, location = location.belowbar, color = color.new(#00E676, 30), size = size.small, offset = -rightBars)

// ============================================================
// MULTI-TIMEFRAME ABC SIGNAL FUNCTION
// Pine Script does not support nested functions → inline for loop
// ============================================================
// Returns: [signal, C pivot bar index]
// signal: 1=Ascending ABC, -1=Descending ABC, 0=None
// cBar: unix timestamp of C pivot (ms)
getABCSignal() =>
    _ph = ta.pivothigh(high, leftBars, rightBars)
    _pl = ta.pivotlow(low, leftBars, rightBars)

    var array<float> _PP = array.new_float()
    var array<bool> _PH = array.new_bool()
    var array<int> _PB = array.new_int() // unix time (ms), not bar_index

    _phV = not na(_ph) and _ph / close * 100 >= minSwingPct
    _plV = not na(_pl) and math.abs(_pl - close) / close * 100 >= minSwingPct

    // Process peak pivot
    if _phV
        _sz2 = array.size(_PP)
        if _sz2 > 0
            if array.get(_PH, _sz2 - 1) == true
                if _ph > array.get(_PP, _sz2 - 1)
                    array.set(_PP, _sz2 - 1, _ph)
                    array.set(_PB, _sz2 - 1, time[rightBars])
            else
                array.push(_PP, _ph)
                array.push(_PH, true)
                array.push(_PB, time[rightBars])
        else
            array.push(_PP, _ph)
            array.push(_PH, true)
            array.push(_PB, time[rightBars])

    // Process trough pivot
    if _plV
        _sz2 = array.size(_PP)
        if _sz2 > 0
            if array.get(_PH, _sz2 - 1) == false
                if _pl < array.get(_PP, _sz2 - 1)
                    array.set(_PP, _sz2 - 1, _pl)
                    array.set(_PB, _sz2 - 1, time[rightBars])
            else
                array.push(_PP, _pl)
                array.push(_PH, false)
                array.push(_PB, time[rightBars])
        else
            array.push(_PP, _pl)
            array.push(_PH, false)
            array.push(_PB, time[rightBars])

    while array.size(_PP) > 20
        array.shift(_PP)
        array.shift(_PH)
        array.shift(_PB)

    _rsi = ta.rsi(close, 14)
    _sig = 0
    _cTime = timenow // unix timestamp of C pivot (ms)
    _score = 0 // Formation strength score (0-100)
    _sz = array.size(_PP)

    if _sz >= 4
        for _off = 0 to 5 by 1
            _i0 = _sz - 4 - _off
            if _i0 >= 0 and _i0 + 3 <= _sz - 1 and _sig == 0
                _p0 = array.get(_PP, _i0)
                _p1 = array.get(_PP, _i0 + 1)
                _p2 = array.get(_PP, _i0 + 2)
                _p3 = array.get(_PP, _i0 + 3)
                _h0 = array.get(_PH, _i0)
                _h1 = array.get(_PH, _i0 + 1)
                _h2 = array.get(_PH, _i0 + 2)
                _h3 = array.get(_PH, _i0 + 3)
                // C pivot bar index (i0+3 = C✓ point)
                _cb = array.get(_PB, _i0 + 3)
                // Bull ABC (Descending H-L-H-L)
                if _h0 and not _h1 and _h2 and not _h3
                    _aW = _p0 - _p1
                    if _aW > 0
                        _bR = (_p2 - _p1) / _aW
                        _cE = (_p2 - _p3) / _aW
                        _rsiOK = showRSI ? _rsi < 50 : true
                        if _bR >= minABRatio and _bR <= maxABRatio and _cE >= minBCRatio and _cE <= maxBCRatio and _p3 < _p1 and _p2 < _p0 and _rsiOK
                            _sig := -1
                            _cTime := _cb
                            // SCORE CALCULATION (Bull ABC – Descending)
                            // 1) Is B retracement in golden ratio zone? (0.5-0.618)
                            _sc1 = _bR >= 0.5 and _bR <= 0.618 ? 30 : _bR >= 0.382 and _bR <= 0.786 ? 15 : 0
                            // 2) Is C extension in classic zone? (1.0-1.272)
                            _sc2 = _cE >= 1.0 and _cE <= 1.272 ? 25 : _cE >= 1.272 and _cE <= 1.618 ? 15 : 0
                            // 3) RSI oversold zone
                            _sc3 = _rsi < 30 ? 25 : _rsi < 40 ? 15 : _rsi < 50 ? 5 : 0
                            // 4) Is wave A large enough? (more than 1% of price)
                            _sc4 = _aW / _p0 * 100 >= 2.0 ? 20 : _aW / _p0 * 100 >= 1.0 ? 10 : 0
                            _score := math.min(100, _sc1 + _sc2 + _sc3 + _sc4)
                            _score
                // Bear ABC (Ascending L-H-L-H)
                if not _h0 and _h1 and not _h2 and _h3
                    _aW = _p1 - _p0
                    if _aW > 0
                        _bR = (_p1 - _p2) / _aW
                        _cE = (_p3 - _p2) / _aW
                        _rsiOK = showRSI ? _rsi > 50 : true
                        if _bR >= minABRatio and _bR <= maxABRatio and _cE >= minBCRatio and _cE <= maxBCRatio and _p3 > _p1 and _p2 > _p0 and _rsiOK
                            _sig := 1
                            _cTime := _cb
                            // SCORE CALCULATION (Bear ABC – Ascending)
                            _sc1 = _bR >= 0.5 and _bR <= 0.618 ? 30 : _bR >= 0.382 and _bR <= 0.786 ? 15 : 0
                            _sc2 = _cE >= 1.0 and _cE <= 1.272 ? 25 : _cE >= 1.272 and _cE <= 1.618 ? 15 : 0
                            _sc3 = _rsi > 70 ? 25 : _rsi > 60 ? 15 : _rsi > 50 ? 5 : 0
                            _sc4 = _aW / _p0 * 100 >= 2.0 ? 20 : _aW / _p0 * 100 >= 1.0 ? 10 : 0
                            _score := math.min(100, _sc1 + _sc2 + _sc3 + _sc4)
                            _score
    [_sig, _cTime, _score]

// ============================================================
// REQUEST.SECURITY – 10 TF
// ============================================================
[sig1, ct1, sc1] = request.security(syminfo.tickerid, tf1, getABCSignal(), lookahead = barmerge.lookahead_off)
[sig2, ct2, sc2] = request.security(syminfo.tickerid, tf2, getABCSignal(), lookahead = barmerge.lookahead_off)
[sig3, ct3, sc3] = request.security(syminfo.tickerid, tf3, getABCSignal(), lookahead = barmerge.lookahead_off)
[sig4, ct4, sc4] = request.security(syminfo.tickerid, tf4, getABCSignal(), lookahead = barmerge.lookahead_off)
[sig5, ct5, sc5] = request.security(syminfo.tickerid, tf5, getABCSignal(), lookahead = barmerge.lookahead_off)
[sig6, ct6, sc6] = request.security(syminfo.tickerid, tf6, getABCSignal(), lookahead = barmerge.lookahead_off)
[sig7, ct7, sc7] = request.security(syminfo.tickerid, tf7, getABCSignal(), lookahead = barmerge.lookahead_off)
[sig8, ct8, sc8] = request.security(syminfo.tickerid, tf8, getABCSignal(), lookahead = barmerge.lookahead_off)
[sig9, ct9, sc9] = request.security(syminfo.tickerid, tf9, getABCSignal(), lookahead = barmerge.lookahead_off)
[sig10, ct10, sc10] = request.security(syminfo.tickerid, tf10, getABCSignal(), lookahead = barmerge.lookahead_off)

// ============================================================
// MULTI-TIMEFRAME TABLE
// ============================================================
sigToText(s) =>
    s == 1 ? '▲ Ascending ABC' : s == -1 ? '▼ Descending ABC' : '— None'

sigToColor(s) =>
    s == 1 ? #00E676 : s == -1 ? #FF1744 : color.gray

sigToBG(s) =>
    s == 1 ? color.new(#00E676, 80) : s == -1 ? color.new(#FF1744, 80) : color.new(color.gray, 88)

tfs = array.from(tf1, tf2, tf3, tf4, tf5, tf6, tf7, tf8, tf9, tf10)
sigs = array.from(sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8, sig9, sig10)
cTs = array.from(ct1, ct2, ct3, ct4, ct5, ct6, ct7, ct8, ct9, ct10)
scs = array.from(sc1, sc2, sc3, sc4, sc5, sc6, sc7, sc8, sc9, sc10)

var table mtfTbl = table.new(position.bottom_right, 4, 12, bgcolor = color.new(color.black, 55), border_color = color.new(color.gray, 60), border_width = 1, frame_width = 1, frame_color = color.new(color.gray, 40))

if barstate.islast
    table.cell(mtfTbl, 0, 0, 'Timeframe', text_color = color.white, text_size = size.small, bgcolor = colorTable)
    table.cell(mtfTbl, 1, 0, 'ABC Status', text_color = color.white, text_size = size.small, bgcolor = colorTable)
    table.cell(mtfTbl, 2, 0, 'When', text_color = color.white, text_size = size.small, bgcolor = colorTable)
    table.cell(mtfTbl, 3, 0, 'C Probability', text_color = color.white, text_size = size.small, bgcolor = colorTable)

    bullCount = 0
    bearCount = 0
    for i = 0 to 9 by 1
        s = array.get(sigs, i)
        if s == 1
            bullCount := bullCount + 1
            bullCount
        if s == -1
            bearCount := bearCount + 1
            bearCount

    table.cell(mtfTbl, 0, 1, 'Summary', text_color = color.yellow, text_size = size.small, bgcolor = color.new(#1565C0, 50))
    table.cell(mtfTbl, 1, 1, '▲' + str.tostring(bullCount) + ' ▼' + str.tostring(bearCount), text_color = color.yellow, text_size = size.small, bgcolor = color.new(#1565C0, 50))
    table.cell(mtfTbl, 2, 1, 'RSI:' + str.tostring(rsiVal, '#.#'), text_color = rsiVal > 70 ? #FF1744 : rsiVal < 30 ? #00E676 : color.silver, text_size = size.small, bgcolor = color.new(#1565C0, 50))
    table.cell(mtfTbl, 3, 1, 'B:Fib C:Ext RSI:Zone', text_color = color.gray, text_size = size.small, bgcolor = color.new(#1565C0, 50))

    for i = 0 to 9 by 1
        s = array.get(sigs, i)
        tf = array.get(tfs, i)
        ct = array.get(cTs, i)
        row = i + 2
        // Elapsed time: timenow - C pivot timestamp (in ms)
        msAgo = s != 0 ? math.max(0, timenow - ct) : 0
        minAgo = msAgo / 60000
        // Human-friendly elapsed time text
        agoTxt = s != 0 ? minAgo < 1 ? 'Just now' : minAgo < 60 ? str.tostring(math.round(minAgo)) + ' min ago' : minAgo < 1440 ? str.tostring(math.round(minAgo / 60)) + ' hr ago' : str.tostring(math.round(minAgo / 1440)) + ' day ago' : '·'
        // Color: fresh=green, medium=yellow, old=gray
        agoColor = s != 0 ? minAgo < 30 ? #00E676 : minAgo < 240 ? color.yellow : color.silver : color.gray
        table.cell(mtfTbl, 0, row, tf, text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 65))
        table.cell(mtfTbl, 1, row, sigToText(s), text_color = sigToColor(s), text_size = size.small, bgcolor = sigToBG(s))
        table.cell(mtfTbl, 2, row, agoTxt, text_color = agoColor, text_size = size.small, bgcolor = sigToBG(s))
        // Score column
        sc = array.get(scs, i)
        scoreTxt = s != 0 ? str.tostring(sc) + '/100' : '·'
        scoreClr = s != 0 ? sc >= 70 ? #00E676 : sc >= 40 ? color.yellow : #FF6B6B : color.gray
        scoreBG = s != 0 ? sc >= 70 ? color.new(#00E676, 75) : sc >= 40 ? color.new(color.yellow, 80) : color.new(#FF6B6B, 80) : color.new(color.gray, 88)
        table.cell(mtfTbl, 3, row, scoreTxt, text_color = scoreClr, text_size = size.small, bgcolor = scoreBG)

// ============================================================
// DIRECTION LINE – shows expected move after C is completed
// BullABC (descending H-L-H-L): after C, DECLINE expected → red arrow
// BearABC (ascending L-H-L-H): after C, RISE expected → green arrow
//
// Start : C✓ point (b3, p3)
// End price: midpoint between A origin (p0) and B (p1) → (p0+p1)/2
// End bar  : dirBars bars after C✓
// ============================================================

// Direction line colors (configurable)
colorDirDown = input.color(color.new(#00E676, 20), 'Direction Line – Bullish', group = 'Direction Line')
colorDirUp = input.color(color.new(#FF1744, 20), 'Direction Line – Bearish', group = 'Direction Line')
dirBars = input.int(5, 'Direction Line Bar Length', minval = 2, maxval = 20, group = 'Direction Line', tooltip = 'How many bars ahead to draw after C is completed')

// Keep track of A bars where direction line has already been drawn (prevent duplicates)
var array<int> drawnDir = array.new_int()

if newPivot
    sz2 = array.size(PP)

    for off2 = 0 to 5 by 1
        i0d = sz2 - 4 - off2
        if i0d >= 0 and i0d + 3 <= sz2 - 1

            aBar2 = array.get(PB, i0d)

            // Was direction line already drawn for this pattern?
            alreadyDir = false
            dSz2 = array.size(drawnDir)
            if dSz2 > 0
                for k2 = 0 to dSz2 - 1 by 1
                    if array.get(drawnDir, k2) == aBar2
                        alreadyDir := true
                        alreadyDir

            if not alreadyDir
                _p0d = array.get(PP, i0d)
                _p1d = array.get(PP, i0d + 1)
                _p2d = array.get(PP, i0d + 2)
                _p3d = array.get(PP, i0d + 3)
                _h0d = array.get(PH, i0d)
                _h1d = array.get(PH, i0d + 1)
                _h2d = array.get(PH, i0d + 2)
                _h3d = array.get(PH, i0d + 3)
                _b3d = array.get(PB, i0d + 3)

                // A-B midpoint price
                midAB = (_p0d + _p1d) / 2

                // BullABC: H-L-H-L → decline expected after C
                if _h0d and not _h1d and _h2d and not _h3d
                    aWd = _p0d - _p1d
                    if aWd > 0
                        bRd = (_p2d - _p1d) / aWd
                        cEd = (_p2d - _p3d) / aWd
                        if bRd >= minABRatio and bRd <= maxABRatio and cEd >= minBCRatio and cEd <= maxBCRatio and _p3d < _p1d and _p2d < _p0d
                            // Start from C point, drop toward A-B midpoint
                            line.new(_b3d, _p3d, _b3d + dirBars, midAB, color = colorDirDown, width = 2, style = line.style_arrow_right)
                            label.new(_b3d + dirBars, midAB, '↓ Expected', color = color.new(color.black, 100), textcolor = colorDirDown, style = label.style_label_left, size = size.small)
                            array.push(drawnDir, aBar2)

                // BearABC: L-H-L-H → rise expected after C
                if not _h0d and _h1d and not _h2d and _h3d
                    aWd = _p1d - _p0d
                    if aWd > 0
                        bRd = (_p1d - _p2d) / aWd
                        cEd = (_p3d - _p2d) / aWd
                        if bRd >= minABRatio and bRd <= maxABRatio and cEd >= minBCRatio and cEd <= maxBCRatio and _p3d > _p1d and _p2d > _p0d
                            // Start from C point, rise toward A-B midpoint
                            line.new(_b3d, _p3d, _b3d + dirBars, midAB, color = colorDirUp, width = 2, style = line.style_arrow_right)
                            label.new(_b3d + dirBars, midAB, '↑ Expected', color = color.new(color.black, 100), textcolor = colorDirUp, style = label.style_label_left, size = size.small)
                            array.push(drawnDir, aBar2)

    while array.size(drawnDir) > 100
        array.shift(drawnDir)
````
