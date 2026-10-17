# Adaptive Head and Shoulders Detector

- url: https://www.tradingview.com/script/Gkrogzkp/
- type: indicator
- pine_id: PUB;0949885510a54875a53a33f3f617868a
- version: 1.0

## Description

█ OVERVIEW
Adaptive Head and Shoulders Detector is a highly configurable pattern-detection indicator designed to automatically identify Classic Head & Shoulders and Inverse Head & Shoulders formations using multiple pivot lengths, structural filters and optional neckline-break confirmation.

Instead of relying on a single fixed pivot sensitivity, the indicator can analyse market structure simultaneously at four different pivot lengths. Each length can have its own requirements for shoulder symmetry and minimum head deviation, allowing the detector to identify both relatively compact formations and larger, more significant structures.

A key feature of the indicator is its multi-pivot architecture. Each enabled pivot length acts as a standalone detector and also feeds the shared history used by Mix Mode. Mix Mode can combine pivots detected at different sensitivities within a single pattern, provided those lengths are enabled. Mix Mode does not run on its own: disabling Pivot 1–4 removes those lengths from both standalone detection and mix detection.

The indicator also uses ATR as a common volatility reference. Shoulder symmetry, head deviation and the required preceding trend impulse are expressed in relation to ATR, allowing the pattern criteria to adapt to the current scale of price movement rather than relying exclusively on fixed price distances.

Pattern quality is evaluated not only by the visual arrangement of the five pivots, but also by the relative height of the head and shoulders, time symmetry between the two sides of the formation, and the existence of a preceding directional move. This allows the detector to filter out structures that resemble Head & Shoulders visually but do not satisfy the defined structural conditions.

The confirmation process can be configured in two ways. In the immediate mode, a pattern is confirmed when the right shoulder pivot becomes confirmed. Alternatively, the user can require a confirmed neckline break, in which case the pattern remains pending until price closes beyond the neckline. Neckline-break confirmation is evaluated only on a closed bar, preventing an intrabar price excursion from triggering a premature confirmation.

Another important element is Pivot Source. The user can build pivots from High/Low wicks or exclusively from closing prices. This changes the structural information used by the detector and allows the indicator to ignore long wicks when a close-based interpretation of market structure is preferred.

The visual layer can be customized independently through pattern colours, neckline colour, labels, fill transparency and label positioning. A trend visualization mode can additionally show the preceding trend leg and its measured strength in ATR units, making the operation of the trend filter easier to understand.

As a result, Adaptive Head and Shoulders Detector can be used both as an automatic pattern scanner and as a structural analysis tool for studying how pivot sensitivity, trend strength, symmetry and neckline confirmation influence pattern detection.

█ CONCEPTS
Head & Shoulders Structure
The indicator identifies the classic five-point Head & Shoulders structure:
* R1 — left shoulder
* B2 — first trough
* HEAD — central extreme
* B4 — second trough
* R5 — right shoulder
For a classic bearish Head & Shoulders, the head forms above both shoulders, while the two troughs create the basis for the neckline.
For an Inverse Head & Shoulders, the structure is reversed: the head forms below both shoulders and the two intermediate highs define the neckline.
The detector requires the pivots to alternate correctly and checks the relative position of all five points before accepting the structure as a valid pattern.

ATR-Based Adaptation
ATR is used as the volatility reference for the main structural tolerances.
Instead of defining shoulder differences or head depth using fixed price values, the indicator expresses these requirements as multiples of ATR. This allows the same settings to behave more proportionally across markets and volatility conditions.
ATR is also used to measure the strength of the preceding trend and to determine the visual offset of labels.

Pivot Detection
The indicator can use up to four independent pivot lengths.
A pivot length defines how many bars on each side of a bar are required before a high or low can be confirmed as a pivot. Smaller lengths detect more frequent and smaller structural turning points, while larger lengths produce fewer but generally more significant pivots.
Each pivot length can be enabled or disabled independently. Enabling a given length starts its standalone detection and also adds its pivots to the Mix Mode history.

Pivot Source
Pivot calculations can be based on either High/Low wicks or closing prices.
* High/Low (wick) — uses the actual highs and lows of candles, allowing long wicks to participate in pivot formation.
* Close — uses closing prices exclusively, effectively ignoring wicks when determining structural pivots.
This setting applies across all pivot lengths and also affects Mix Mode.

Shoulder Symmetry
The detector compares the price levels of the left and right shoulders.
The maximum allowed difference is defined as an ATR multiple. A lower tolerance requires the shoulders to be more closely aligned, while a higher tolerance allows more asymmetric formations.
Each standalone pivot length has its own shoulder tolerance, while Mix Mode uses a separate shared tolerance.

Head Deviation
The head must be sufficiently separated from both shoulders.
For a classic H&S, the head must be above both shoulders by at least the specified ATR distance. For an inverse H&S, the head must be below both shoulders by the required amount.
This prevents shallow structures from being classified as valid Head & Shoulders patterns simply because five alternating pivots happen to form a similar shape.

Time Symmetry
The indicator also evaluates the horizontal proportions of the pattern.
The distance from the left shoulder to the head is compared with the distance from the head to the right shoulder. The maximum permitted ratio is controlled by Max. time asymmetry.
A value closer to 1 requires a more symmetrical formation, while higher values allow one side of the pattern to develop over a longer period than the other.

Preceding Trend Filter
A valid Head & Shoulders formation can optionally be required to follow a sufficiently strong preceding trend.
The indicator searches backward from the left shoulder for the relevant preceding extreme and measures the price movement between that extreme and the left shoulder in ATR units.
For a bearish H&S, the structure should be preceded by an upward impulse. For an inverse H&S, the structure should be preceded by a downward impulse.
Setting the minimum trend impulse to 0 disables this filter.

Neckline Confirmation
The neckline is drawn through the two intermediate pivots of the formation and extended to the right by the selected number of bars.
When neckline-break confirmation is enabled, the pattern is stored as pending after its structure and trend conditions are satisfied. The indicator then waits for a candle close beyond the neckline.
For a classic H&S, confirmation occurs when price closes below the neckline.
For an inverse H&S, confirmation occurs when price closes above the neckline.
The neckline break is checked only on a confirmed candle, so a temporary intrabar penetration does not trigger the confirmation.

Mix Mode
Mix Mode builds a pattern from the most recent points in the shared pivot history, which is created exclusively from the enabled Pivot 1–4 lengths.
Instead of requiring all five points to come from the same pivot length, individual points can originate from different enabled pivot lengths. For example, a single pattern can be constructed from a combination such as 5 / 10 / 15 / 5 / 10 if those lengths are enabled and that is how the current tail of the merged history looks.
Mix Mode does not work without the lengths that feed it: disabling Pivot 1–4 removes those pivots from both standalone detection and mix detection. The user can use standalone detection only, standalone detection together with mix, or mix based only on the currently enabled lengths.
The mixed structure is still subjected to the same core requirements for head deviation, shoulder symmetry, time symmetry and preceding trend strength. The largest pivot length participating in the pattern is used as the reference for trend lookback and breakout waiting time.

█ FEATURES
Common
* ATR Length – defines the number of bars used to calculate ATR, which serves as the volatility reference for the indicator's tolerance and trend thresholds.
* Extend neckline to the right (bars) – specifies how many bars the dashed neckline is extended beyond the current confirmation area.
* Show labels – displays the HEAD and R labels at the relevant pattern points.
* Bull color – defines the colour used for Inverse H&S patterns and bullish signals.
* Bear color – defines the colour used for classic H&S patterns and bearish signals.
* Neckline color – sets the colour of the dashed neckline.
* Label text color – defines the text colour used inside all indicator labels.
* Label size – controls the size of HEAD, R, signal and trend-visualization labels.
* Show direction signal – displays a BULL or BEAR signal when the selected pattern confirmation condition is met.
* Show pattern fill – enables or disables the shaded area representing the detected pattern.
* Fill transparency (%) – controls the transparency of the pattern fill.
* Label offset from price (x ATR) – controls the distance between labels and their corresponding price points, expressed as a multiple of ATR.
* Pivot source – selects whether pivots are calculated from High/Low wicks or closing prices.

Structure / Trend / Confirmation
* Require neckline break confirmation – when enabled, the pattern must be confirmed by a candle close beyond the neckline. When disabled, confirmation occurs when the right-shoulder pivot itself becomes confirmed.
* Trend lookback window (x pivot length) – defines how far back the indicator searches for the preceding trend extreme, based on the pivot length used by the pattern.
* Min. trend impulse before pattern (x ATR) – specifies the minimum preceding price movement required before the pattern, expressed in ATR units. Setting it to 0 disables the trend filter.
* Max. time asymmetry (b1→head vs head→b5) – controls the maximum allowed difference between the time spent developing the left and right sides of the pattern.
* Max. wait time for breakout (x pivot length) – defines how long the indicator waits for a neckline break before discarding a pending pattern as stale. Applies only when neckline-break confirmation is enabled.
* Show trend visualization (line to extreme) – displays the preceding trend leg as a dotted line and shows its measured strength in ATR units.
* ...also for patterns that did NOT pass the trend filter – additionally displays trend visualization for structurally matching patterns that failed the minimum trend requirement, helping with filter calibration.

Pivot 1–4
* Enable pivot X – enables standalone H&S / Inverse H&S detection at that sensitivity and also adds those pivots to the Mix Mode history.
* Pivot X length (left/right) – defines the number of bars on each side required to confirm a pivot.
* Shoulder symmetry tolerance X (x ATR) – defines the maximum permitted price difference between the two shoulders.
* Min. head deviation X (x ATR) – defines the minimum required distance between the head and both shoulders.

Mix Mode
* Enable mix mode (different pivot lengths in one pattern) – enables detection of patterns whose individual points can originate from different enabled pivot lengths. Mix Mode uses only the lengths enabled under Pivot 1–4.
* Shoulder symmetry tolerance (mix, x ATR) – defines the maximum permitted difference between the shoulders of a mixed pattern.
* Min. head deviation (mix, x ATR) – defines the minimum required head deviation for mixed patterns.
* Max. number of pivots in merged history – specifies how many recent pivots from all enabled pivot lengths are retained for mixed-pattern searching.

Alerts
* Inverse H&S (Bullish) Signal – triggers when a bullish Inverse Head & Shoulders signal is generated.
* H&S (Bearish) Signal – triggers when a bearish Head & Shoulders signal is generated.
* H&S / Inverse H&S Signal (Any) – triggers for either a bullish or bearish pattern signal.

█ APPLICATIONS
Multi-Scale Head & Shoulders Detection

Using several pivot lengths allows the indicator to analyse different structural scales simultaneously.
Smaller pivot lengths can capture more local formations, while larger lengths focus on broader market structures. This makes it possible to use one indicator for multiple levels of pattern sensitivity instead of relying on a single pivot configuration.

A detected formation is not a trade signal and does not mark an entry. It is information that a structure has appeared on the chart after which a reversal may be expected. The timing and location of any trade should be determined with other methods or strategies.

█ NOTES
* Pivot-based detection requires the selected number of bars on both sides of a pivot before that pivot can be confirmed. Larger pivot lengths therefore produce slower but generally broader structural detection.
* When neckline-break confirmation is enabled, the pattern is confirmed only after a candle closes beyond the neckline. Intrabar movement through the neckline does not trigger the confirmation.
* Pending patterns that do not receive a neckline break within the configured waiting period are discarded.
* Mix Mode uses only the enabled Pivot 1–4 lengths. The same Enable option feeds both standalone detection and the mix history — a given length cannot be disabled as a standalone detector while still being kept in mix only.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator("Adaptive Head and Shoulders Detector", overlay=true, max_lines_count=500, max_labels_count=500, max_polylines_count=100)

// Common inputs
atrLen        = input.int(200, "ATR Length", minval=1, group="Common",
     tooltip="Number of bars used to calculate the ATR (Average True Range). ATR is the basis for all tolerance thresholds in this indicator.")
extendBars    = input.int(20, "Extend neckline to the right (bars)", minval=0, group="Common",
     tooltip="How many bars to the right to extend the dashed neckline beyond the confirmation point.")
showLabels    = input.bool(true, "Show labels", group="Common",
     tooltip="Shows 'HEAD' and 'R' (shoulder) labels at the pattern's points.")
bullColor     = input.color(color.green, "Bull color", group="Common",
     tooltip="Color for the pattern, fill, and signal for the inverse H&S (bottom pattern, bullish signal).")
bearColor     = input.color(color.red, "Bear color", group="Common",
     tooltip="Color for the pattern, fill, and signal for the classic H&S (top pattern, bearish signal).")
neckColor     = input.color(color.gray, "Neckline color", group="Common",
     tooltip="Color of the dashed neckline.")
labelTextColor = input.color(color.white, "Label text color", group="Common",
     tooltip="Text color inside all labels (HEAD, R, BULL/BEAR signal, trend visualization).")
labelSizeInput = input.string("Small", "Label size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Common",
     tooltip="Size of all labels drawn by the indicator (HEAD, R, BULL/BEAR signal, trend visualization).")
showSignal    = input.bool(true, "Show direction signal", group="Common",
     tooltip="Draws a BULL/BEAR label on the confirmation bar — depending on the selected confirmation mode (neckline break or pivot alone).")
showFill      = input.bool(true, "Show pattern fill", group="Common",
     tooltip="Highlights the pattern area with a subtle color (as in the standard Head & Shoulders tool on TradingView).")
fillTransp    = input.int(85, "Fill transparency (%)", minval=0, maxval=100, group="Common",
     tooltip="0 = full, solid fill color; 100 = completely invisible.")
sigOffsetMult = input.float(0.5, "Label offset from price (x ATR)", minval=0.1, step=0.1, group="Common",
     tooltip="How far from the pattern point (in ATR units) ALL labels should be offset (HEAD, R, signal, trend visualization). A larger value means labels are placed further from the bars/points.")
pivotSource   = input.string("Close", "Pivot source", options=["High/Low (wick)", "Close"], group="Common",
     tooltip="High/Low (wick): pivots are calculated from the bar's highs/lows (as in a classic zigzag) — longer wicks can form patterns. Close: pivots are calculated exclusively from closing prices — wicks are ignored, patterns are based only on where price actually closed. Applies to pivot detection at all lengths and in mix mode.")

labelSizeVal = switch labelSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.small

// Structure / trend / symmetry / confirmation
useBreakConfirmation = input.bool(false, "Require neckline break confirmation", group="Structure / Trend / Confirmation",
     tooltip="ON (recommended): the pattern is drawn and gives a signal only once price closes beyond the neckline after the right shoulder (on a closed bar — no intrabar repaint). OFF: the signal fires immediately on the bar where the right-shoulder pivot itself is confirmed.")
trendLookbackMult = input.float(3.0, "Trend lookback window (x pivot length)", minval=1.0, step=0.5, group="Structure / Trend / Confirmation",
     tooltip="How far back from the left shoulder (b1) the indicator looks for a preceding trend extreme. The value is expressed as a multiple of the pivot length, i.e. the number of bars on each side of a bar required to confirm a pivot (e.g. with a pivot length of 5 and a multiplier of 3.0, the indicator scans 15 bars back from the left shoulder). For mix mode, the largest of the pivot lengths that formed the given pattern is used as the base.")
trendMult         = input.float(2.0, "Min. trend impulse before pattern (x ATR)", minval=0.0, step=0.05, group="Structure / Trend / Confirmation",
     tooltip="Minimum price move (in ATR units) between the left shoulder and the farthest extreme found within the trend window (see parameter above). Forces the pattern to be preceded by a clear trend. 0 = disables the trend filter (and its visualization).")
timeSymmetryMax   = input.float(2.0, "Max. time asymmetry (b1→head vs head→b5)", minval=1.0, step=0.1, group="Structure / Trend / Confirmation",
     tooltip="Maximum allowed ratio of the longer to the shorter of the two time segments, measured in bars: left shoulder→head and head→right shoulder. A value of 1.0 would require perfect symmetry; higher values allow a more stretched-out pattern. Behaves identically regardless of whether the pattern comes from a single pivot length or from mix mode.")
breakoutWaitMult  = input.float(3.0, "Max. wait time for breakout (x pivot length)", minval=0.5, step=0.5, group="Structure / Trend / Confirmation",
     tooltip="Applies only to neckline-break confirmation mode. Determines how many bars (as a multiple of the pattern's pivot length — i.e. the number of bars on each side of the bar used to detect the pivot; for mix: the largest of the lengths used) the indicator waits for a neckline break before discarding a pending pattern as stale.")
showTrendViz  = input.bool(false, "Show trend visualization (line to extreme)", group="Structure / Trend / Confirmation",
     tooltip="Draws a dashed line from the found low/high to the pattern's left shoulder, with a label showing the size of the move in ATR. Blue = trend condition met, orange = not met.")
showTrendVizFailed = input.bool(false, "...also for patterns that did NOT pass the trend filter", group="Structure / Trend / Confirmation",
     tooltip="OFF (recommended): trend visualization is drawn only for patterns that met the trend condition — a less cluttered chart. ON: also draws orange lines for patterns that match the shape but don't have enough trend impulse before them — useful when tuning the trend filter threshold.")

// Pivot 1
enablePivot1   = input.bool(true,  "Enable pivot 1", group="Pivot 1",
     tooltip="Enables detection of H&S / inverse H&S patterns based solely on pivots of the length given below.")
pivotLen1      = input.int(5, "Pivot 1 length (left/right)", minval=2, group="Pivot 1",
     tooltip="Number of bars on each side of a bar required to confirm a pivot (parameter of the ta.pivothigh / ta.pivotlow function). A larger value means fewer but more significant pivots; a smaller value means more pivots, including minor fluctuations.")
tolMult1       = input.float(1.5, "Shoulder symmetry tolerance 1 (x ATR)", minval=0.05, step=0.05, group="Pivot 1",
     tooltip="Maximum allowed price difference between the left and right shoulder of the pattern, expressed as a multiple of ATR. A higher value allows more shoulder asymmetry.")
headDevMult1   = input.float(1.5, "Min. head deviation 1 (x ATR)", minval=0.0, step=0.05, group="Pivot 1",
     tooltip="Minimum required deviation of the head from both shoulders, expressed as a multiple of ATR. Prevents detecting a pattern where the head doesn't stand out enough relative to the shoulders.")

// Pivot 2
enablePivot2   = input.bool(true,  "Enable pivot 2", group="Pivot 2",
     tooltip="Enables detection of H&S / inverse H&S patterns based solely on pivots of the length given below.")
pivotLen2      = input.int(12, "Pivot 2 length (left/right)", minval=2, group="Pivot 2",
     tooltip="Number of bars on each side of a bar required to confirm a pivot (parameter of the ta.pivothigh / ta.pivotlow function). A larger value means fewer but more significant pivots; a smaller value means more pivots, including minor fluctuations.")
tolMult2       = input.float(3.0, "Shoulder symmetry tolerance 2 (x ATR)", minval=0.05, step=0.05, group="Pivot 2",
     tooltip="Maximum allowed price difference between the left and right shoulder of the pattern, expressed as a multiple of ATR. A higher value allows more shoulder asymmetry.")
headDevMult2   = input.float(1.5, "Min. head deviation 2 (x ATR)", minval=0.0, step=0.05, group="Pivot 2",
     tooltip="Minimum required deviation of the head from both shoulders, expressed as a multiple of ATR. Prevents detecting a pattern where the head doesn't stand out enough relative to the shoulders.")

// Pivot 3
enablePivot3   = input.bool(true,  "Enable pivot 3", group="Pivot 3",
     tooltip="Enables detection of H&S / inverse H&S patterns based solely on pivots of the length given below.")
pivotLen3      = input.int(20, "Pivot 3 length (left/right)", minval=2, group="Pivot 3",
     tooltip="Number of bars on each side of a bar required to confirm a pivot (parameter of the ta.pivothigh / ta.pivotlow function). A larger value means fewer but more significant pivots; a smaller value means more pivots, including minor fluctuations.")
tolMult3       = input.float(3.0, "Shoulder symmetry tolerance 3 (x ATR)", minval=0.05, step=0.05, group="Pivot 3",
     tooltip="Maximum allowed price difference between the left and right shoulder of the pattern, expressed as a multiple of ATR. A higher value allows more shoulder asymmetry.")
headDevMult3   = input.float(2.0, "Min. head deviation 3 (x ATR)", minval=0.0, step=0.05, group="Pivot 3",
     tooltip="Minimum required deviation of the head from both shoulders, expressed as a multiple of ATR. Prevents detecting a pattern where the head doesn't stand out enough relative to the shoulders.")

// Pivot 4
enablePivot4   = input.bool(true,  "Enable pivot 4", group="Pivot 4",
     tooltip="Enables detection of H&S / inverse H&S patterns based solely on pivots of the length given below.")
pivotLen4      = input.int(30, "Pivot 4 length (left/right)", minval=2, group="Pivot 4",
     tooltip="Number of bars on each side of a bar required to confirm a pivot (parameter of the ta.pivothigh / ta.pivotlow function). A larger value means fewer but more significant pivots; a smaller value means more pivots, including minor fluctuations.")
tolMult4       = input.float(4.0, "Shoulder symmetry tolerance 4 (x ATR)", minval=0.05, step=0.05, group="Pivot 4",
     tooltip="Maximum allowed price difference between the left and right shoulder of the pattern, expressed as a multiple of ATR. A higher value allows more shoulder asymmetry.")
headDevMult4   = input.float(2.0, "Min. head deviation 4 (x ATR)", minval=0.0, step=0.05, group="Pivot 4",
     tooltip="Minimum required deviation of the head from both shoulders, expressed as a multiple of ATR. Prevents detecting a pattern where the head doesn't stand out enough relative to the shoulders.")

// Mix mode
mixMode = input.bool(true, "Enable mix mode (different pivot lengths in one pattern)", group="Mix Mode",
     tooltip="When enabled, the indicator additionally looks for H&S patterns where individual points (R1, B2, HEAD, B4, R5) can come from different enabled pivot lengths (e.g. 5,10,15,5,10) — as long as they meet the same proportion conditions (ATR, time symmetry) as single-length patterns. Works independently from the single-length modes above — they can be toggled separately, e.g. you can disable Pivot 1-4 as standalone detectors and keep only the mix.")
tolMultMix     = input.float(2.0, "Shoulder symmetry tolerance (mix, x ATR)", minval=0.05, step=0.05, group="Mix Mode",
     tooltip="Shared shoulder tolerance threshold for mixed patterns — used regardless of which pivot lengths formed the given point.")
headDevMultMix = input.float(1.0,"Min. head deviation (mix, x ATR)", minval=0.0, step=0.05, group="Mix Mode",
     tooltip="Minimum required head deviation from both shoulders in mixed patterns, expressed as a multiple of ATR.")
maxPivotsMerged = input.int(100, "Max. number of pivots in merged history", minval=10, maxval=100, group="Mix Mode",
     tooltip="How many recent pivots (from all enabled lengths combined, after zigzag merging) to keep in memory for searching mixed patterns.")

atrVal = ta.atr(atrLen)
pivotSrcHigh = pivotSource == "Close" ? close : high
pivotSrcLow  = pivotSource == "Close" ? close : low

// Pivot memory — separate for each length
var pPrice1 = array.new<float>(0)
var pBar1   = array.new<int>(0)
var pType1  = array.new<string>(0)

var pPrice2 = array.new<float>(0)
var pBar2   = array.new<int>(0)
var pType2  = array.new<string>(0)

var pPrice3 = array.new<float>(0)
var pBar3   = array.new<int>(0)
var pType3  = array.new<string>(0)

var pPrice4 = array.new<float>(0)
var pBar4   = array.new<int>(0)
var pType4  = array.new<string>(0)

// Merged (mixed) pivot history from all lengths
var mPrice = array.new<float>(0)
var mBar   = array.new<int>(0)
var mType  = array.new<string>(0)
var mLen   = array.new<int>(0)   // which pivot length detected this point

// Shared "last pattern end" registry, shared across all detectors.
// Prevents different lengths from drawing the same structure at the same time.
var array<int> globalEndBull = array.new<int>(1, na)
var array<int> globalEndBear = array.new<int>(1, na)

// Draw pattern
drawPattern(b1, b2, b3, b4, b5, pr1, pr2, pr3, pr4, pr5, isTop, headLabel, r1Label, r5Label) =>
    col = isTop ? bearColor : bullColor
    line.new(b1, pr1, b2, pr2, color=col, width=2)
    line.new(b2, pr2, b3, pr3, color=col, width=2)
    line.new(b3, pr3, b4, pr4, color=col, width=2)
    line.new(b4, pr4, b5, pr5, color=col, width=2)
    nDiff        = b4 - b2
    neckSlope    = nDiff == 0 ? 0.0 : (pr4 - pr2) / nDiff
    neckEndBar   = bar_index + extendBars
    neckEndPrice = pr2 + neckSlope * (neckEndBar - b2)
    line.new(b2, pr2, neckEndBar, neckEndPrice, color=neckColor, width=1, style=line.style_dashed)
    if showFill
        neckAtB1 = pr2 + neckSlope * (b1 - b2)
        neckAtB5 = pr2 + neckSlope * (b5 - b2)
        fillCol  = color.new(col, fillTransp)
        pts = array.new<chart.point>(0)
        array.push(pts, chart.point.from_index(b1, pr1))
        array.push(pts, chart.point.from_index(b2, pr2))
        array.push(pts, chart.point.from_index(b3, pr3))
        array.push(pts, chart.point.from_index(b4, pr4))
        array.push(pts, chart.point.from_index(b5, pr5))
        array.push(pts, chart.point.from_index(b5, neckAtB5))
        array.push(pts, chart.point.from_index(b1, neckAtB1))
        polyline.new(pts, curved=false, closed=true, xloc=xloc.bar_index, line_color=color.new(col, 100), fill_color=fillCol)
    offset = atrVal * sigOffsetMult
    if showLabels
        headPr = isTop ? pr3 + offset : pr3 - offset
        r1Pr   = isTop ? pr1 + offset : pr1 - offset
        r5Pr   = isTop ? pr5 + offset : pr5 - offset
        label.new(b3, headPr, headLabel, style=isTop ? label.style_label_down : label.style_label_up, color=col, textcolor=labelTextColor, size=labelSizeVal)
        label.new(b1, r1Pr, r1Label, style=isTop ? label.style_label_down : label.style_label_up, color=col, textcolor=labelTextColor, size=labelSizeVal)
        label.new(b5, r5Pr, r5Label, style=isTop ? label.style_label_down : label.style_label_up, color=col, textcolor=labelTextColor, size=labelSizeVal)
    if showSignal
        sigCol = isTop ? bearColor : bullColor
        sigTxt = isTop ? "▼ BEAR" : "▲ BULL"
        sigPr  = isTop ? high + offset : low - offset
        label.new(bar_index, sigPr, sigTxt, style=isTop ? label.style_label_down : label.style_label_up, color=sigCol, textcolor=labelTextColor, size=labelSizeVal)

// Trend leg visualization
drawTrendViz(extBar, extVal, b1, pr1, isTop, moveATR, reqATR, ok) =>
    col = ok ? color.new(color.blue, 0) : color.new(color.orange, 0)
    line.new(extBar, extVal, b1, pr1, color=col, width=1, style=line.style_dotted)
    txt = "trend: " + str.tostring(moveATR, "#.##") + "x ATR (min " + str.tostring(reqATR, "#.##") + ")"
    offset  = atrVal * sigOffsetMult
    labelPr = isTop ? extVal - offset : extVal + offset
    label.new(extBar, labelPr, txt, style=isTop ? label.style_label_up : label.style_label_down, color=col, textcolor=labelTextColor, size=labelSizeVal)

// Insert a new pivot into the merged history (sorted by bar) + zigzag collapse
mergeInsertPivot(mPrice, mBar, mType, mLen, price, bar, ptype, plen) =>
    n = array.size(mBar)
    idx = n
    if n > 0
        for i = 0 to n - 1
            if bar < array.get(mBar, i)
                idx := i
                break
    array.insert(mPrice, idx, price)
    array.insert(mBar,   idx, bar)
    array.insert(mType,  idx, ptype)
    array.insert(mLen,   idx, plen)
    i = 1
    while i < array.size(mType)
        if array.get(mType, i) == array.get(mType, i - 1)
            pPrev = array.get(mPrice, i - 1)
            pCurr = array.get(mPrice, i)
            removeIdx = (array.get(mType, i) == "H") ? (pCurr >= pPrev ? i - 1 : i) : (pCurr <= pPrev ? i - 1 : i)
            array.remove(mPrice, removeIdx)
            array.remove(mBar,   removeIdx)
            array.remove(mType,  removeIdx)
            array.remove(mLen,   removeIdx)
            i := math.max(i - 1, 1)
        else
            i += 1
    if array.size(mType) > maxPivotsMerged
        array.shift(mPrice)
        array.shift(mBar)
        array.shift(mType)
        array.shift(mLen)
// Update the pivot array for a given length (+ optionally the merged history)
updatePivots(pivotLen, pPrice, pBar, pType, mPrice, mBar, mType, mLen, mixEnabled, srcHigh, srcLow) =>
    ph = ta.pivothigh(srcHigh, pivotLen, pivotLen)
    pl = ta.pivotlow(srcLow, pivotLen, pivotLen)
    mergedNew = false
    if not na(ph)
        b = bar_index - pivotLen
        array.push(pPrice, ph)
        array.push(pBar, b)
        array.push(pType, "H")
        if array.size(pType) > 30
            array.shift(pPrice)
            array.shift(pBar)
            array.shift(pType)
        if mixEnabled
            mergeInsertPivot(mPrice, mBar, mType, mLen, ph, b, "H", pivotLen)
            mergedNew := true
    if not na(pl)
        b = bar_index - pivotLen
        array.push(pPrice, pl)
        array.push(pBar, b)
        array.push(pType, "L")
        if array.size(pType) > 30
            array.shift(pPrice)
            array.shift(pBar)
            array.shift(pType)
        if mixEnabled
            mergeInsertPivot(mPrice, mBar, mType, mLen, pl, b, "L", pivotLen)
            mergedNew := true
    [not na(ph) or not na(pl), mergedNew]

// Check trend before the left shoulder
checkTrend(b1, pr1, isTop, lookback, minMult) =>
    bool  ok        = true
    int   extOffset = na
    float extreme   = na
    if minMult > 0.0
        offset0 = bar_index - b1
        ext = isTop ? 1e15 : -1e15
        eOff = offset0
        for i = 1 to int(lookback)
            idx = offset0 + i
            val = isTop ? nz(low[idx], 1e15) : nz(high[idx], -1e15)
            if isTop ? val < ext : val > ext
                ext := val
                eOff := idx
        extreme   := ext
        extOffset := eOff
        ok        := isTop ? (pr1 - extreme) >= minMult * atrVal : (extreme - pr1) >= minMult * atrVal
    [ok, extOffset, extreme]

// Patterns from a single, fixed pivot length (pure mode)
checkPattern(newPivot, pPrice, pBar, pType, tagLen, tolMult, headDevMult, lookbackMult, trMult, timeMax, waitMult, useBreak, vizTrend, vizTrendFailed, globalEndBull, globalEndBear) =>
    // Pending-pattern queue — allows several patterns to wait for a neckline break
    // at the same time, without overwriting each other.
    var array<int>   qB1   = array.new<int>(0)
    var array<int>   qB2   = array.new<int>(0)
    var array<int>   qB3   = array.new<int>(0)
    var array<int>   qB4   = array.new<int>(0)
    var array<int>   qB5   = array.new<int>(0)
    var array<float> qPr1  = array.new<float>(0)
    var array<float> qPr2  = array.new<float>(0)
    var array<float> qPr3  = array.new<float>(0)
    var array<float> qPr4  = array.new<float>(0)
    var array<float> qPr5  = array.new<float>(0)
    var array<bool>  qTop  = array.new<bool>(0)
    var array<int>   qStart = array.new<int>(0)
    maxPending = 5

    fired = false
    isTopOut = false

    if newPivot and array.size(pType) >= 5
        n  = array.size(pType)
        t1 = array.get(pType, n - 5)
        t2 = array.get(pType, n - 4)
        t3 = array.get(pType, n - 3)
        t4 = array.get(pType, n - 2)
        t5 = array.get(pType, n - 1)

        alternating = t1 != t2 and t2 != t3 and t3 != t4 and t4 != t5 and t1 == t3 and t3 == t5

        if alternating
            b1  = array.get(pBar, n - 5)
            b2  = array.get(pBar, n - 4)
            b3  = array.get(pBar, n - 3)
            b4  = array.get(pBar, n - 2)
            b5  = array.get(pBar, n - 1)
            pr1 = array.get(pPrice, n - 5)
            pr2 = array.get(pPrice, n - 4)
            pr3 = array.get(pPrice, n - 3)
            pr4 = array.get(pPrice, n - 2)
            pr5 = array.get(pPrice, n - 1)

            isTop = t1 == "H"
            headDevAbs = headDevMult * atrVal

            headOk      = isTop ? ((pr3 - pr1) >= headDevAbs and (pr3 - pr5) >= headDevAbs) : ((pr1 - pr3) >= headDevAbs and (pr5 - pr3) >= headDevAbs)
            shouldersOk = math.abs(pr1 - pr5) <= tolMult * atrVal
            structOk    = isTop ?
                 (pr1 > pr2 and pr1 > pr4 and pr5 > pr2 and pr5 > pr4 and pr3 > pr2 and pr3 > pr4) :
                 (pr1 < pr2 and pr1 < pr4 and pr5 < pr2 and pr5 < pr4 and pr3 < pr2 and pr3 < pr4)
            leftSpan  = b3 - b1
            rightSpan = b5 - b3
            timeOk    = leftSpan > 0 and rightSpan > 0 and math.max(leftSpan, rightSpan) / math.min(leftSpan, rightSpan) <= timeMax

            shapeOk = headOk and shouldersOk and structOk and timeOk

            lookbackBars = math.max(tagLen, int(tagLen * lookbackMult))
            [trendOk, extOffset, extVal] = checkTrend(b1, pr1, isTop, lookbackBars, trMult)

            if vizTrend and shapeOk and trMult > 0.0 and not na(extOffset) and (trendOk or vizTrendFailed)
                extBarIdx = bar_index - extOffset
                moveATR   = isTop ? (pr1 - extVal) / atrVal : (extVal - pr1) / atrVal
                drawTrendViz(extBarIdx, extVal, b1, pr1, isTop, moveATR, trMult, trendOk)

            lastEndForDir = isTop ? array.get(globalEndBear, 0) : array.get(globalEndBull, 0)
            noOverlap = na(lastEndForDir) or b1 > lastEndForDir

            if shapeOk and trendOk and noOverlap
                if useBreak
                    if array.size(qB1) >= maxPending
                        array.shift(qB1)
                        array.shift(qB2)
                        array.shift(qB3)
                        array.shift(qB4)
                        array.shift(qB5)
                        array.shift(qPr1)
                        array.shift(qPr2)
                        array.shift(qPr3)
                        array.shift(qPr4)
                        array.shift(qPr5)
                        array.shift(qTop)
                        array.shift(qStart)
                    array.push(qB1, b1)
                    array.push(qB2, b2)
                    array.push(qB3, b3)
                    array.push(qB4, b4)
                    array.push(qB5, b5)
                    array.push(qPr1, pr1)
                    array.push(qPr2, pr2)
                    array.push(qPr3, pr3)
                    array.push(qPr4, pr4)
                    array.push(qPr5, pr5)
                    array.push(qTop, isTop)
                    array.push(qStart, bar_index)
                else
                    drawPattern(b1, b2, b3, b4, b5, pr1, pr2, pr3, pr4, pr5, isTop, "HEAD (P" + str.tostring(tagLen) + ")", "R", "R")
                    array.set(isTop ? globalEndBear : globalEndBull, 0, b5)
                    fired := true
                    isTopOut := isTop
                    alert((isTop ? "H&S pattern (bear) — pivot confirmation, pivot=" : "Inverse H&S pattern (bull) — pivot confirmation, pivot=") + str.tostring(tagLen), alert.freq_once_per_bar)

    // Process pending pattern queue — runs every bar, regardless of newPivot.
    // The neckline break is checked only on a confirmed bar (barstate.isconfirmed),
    // so price can't briefly cross the neckline mid-candle and trigger a false
    // signal that would reverse before the candle closes.
    if array.size(qB1) > 0
        i = array.size(qB1) - 1
        while i >= 0
            qb1 = array.get(qB1, i)
            qb2 = array.get(qB2, i)
            qb3 = array.get(qB3, i)
            qb4 = array.get(qB4, i)
            qb5 = array.get(qB5, i)
            qpr1 = array.get(qPr1, i)
            qpr2 = array.get(qPr2, i)
            qpr3 = array.get(qPr3, i)
            qpr4 = array.get(qPr4, i)
            qpr5 = array.get(qPr5, i)
            qtop = array.get(qTop, i)
            qstart = array.get(qStart, i)

            neckSlopeQ = (qb4 - qb2) == 0 ? 0.0 : (qpr4 - qpr2) / (qb4 - qb2)
            neckNowQ   = qpr2 + neckSlopeQ * (bar_index - qb2)
            breakOkQ   = barstate.isconfirmed and (qtop ? close < neckNowQ : close > neckNowQ)
            maxWaitQ   = math.max(tagLen, int(tagLen * waitMult))
            expiredQ   = bar_index - qstart > maxWaitQ

            removeThis = false
            if breakOkQ
                lastEndForDirQ = qtop ? array.get(globalEndBear, 0) : array.get(globalEndBull, 0)
                stillNoOverlap = na(lastEndForDirQ) or qb1 > lastEndForDirQ
                if stillNoOverlap
                    drawPattern(qb1, qb2, qb3, qb4, qb5, qpr1, qpr2, qpr3, qpr4, qpr5, qtop, "HEAD (P" + str.tostring(tagLen) + ")", "R", "R")
                    array.set(qtop ? globalEndBear : globalEndBull, 0, qb5)
                    fired := true
                    isTopOut := qtop
                    alert((qtop ? "Confirmed H&S pattern (bear) — neckline break, pivot=" : "Confirmed inverse H&S pattern (bull) — neckline break, pivot=") + str.tostring(tagLen), alert.freq_once_per_bar)
                removeThis := true
            else if expiredQ
                removeThis := true

            if removeThis
                array.remove(qB1, i)
                array.remove(qB2, i)
                array.remove(qB3, i)
                array.remove(qB4, i)
                array.remove(qB5, i)
                array.remove(qPr1, i)
                array.remove(qPr2, i)
                array.remove(qPr3, i)
                array.remove(qPr4, i)
                array.remove(qPr5, i)
                array.remove(qTop, i)
                array.remove(qStart, i)
            i -= 1

    [fired, isTopOut]

// Patterns from mixed pivot lengths (mix mode)
checkPatternMix(newPivot, mPrice, mBar, mType, mLen, tolMult, headDevMult, lookbackMult, trMult, timeMax, waitMult, useBreak, vizTrend, vizTrendFailed, globalEndBull, globalEndBear) =>
    var array<int>   qB1  = array.new<int>(0)
    var array<int>   qB2  = array.new<int>(0)
    var array<int>   qB3  = array.new<int>(0)
    var array<int>   qB4  = array.new<int>(0)
    var array<int>   qB5  = array.new<int>(0)
    var array<float> qPr1 = array.new<float>(0)
    var array<float> qPr2 = array.new<float>(0)
    var array<float> qPr3 = array.new<float>(0)
    var array<float> qPr4 = array.new<float>(0)
    var array<float> qPr5 = array.new<float>(0)
    var array<int>   qL1  = array.new<int>(0)
    var array<int>   qL2  = array.new<int>(0)
    var array<int>   qL3  = array.new<int>(0)
    var array<int>   qL4  = array.new<int>(0)
    var array<int>   qL5  = array.new<int>(0)
    var array<bool>  qTop = array.new<bool>(0)
    var array<int>   qStart = array.new<int>(0)
    maxPending = 5

    fired = false
    isTopOut = false

    if newPivot and array.size(mType) >= 5
        n  = array.size(mType)
        b1  = array.get(mBar, n - 5)
        b2  = array.get(mBar, n - 4)
        b3  = array.get(mBar, n - 3)
        b4  = array.get(mBar, n - 2)
        b5  = array.get(mBar, n - 1)
        pr1 = array.get(mPrice, n - 5)
        pr2 = array.get(mPrice, n - 4)
        pr3 = array.get(mPrice, n - 3)
        pr4 = array.get(mPrice, n - 2)
        pr5 = array.get(mPrice, n - 1)
        l1  = array.get(mLen, n - 5)
        l2  = array.get(mLen, n - 4)
        l3  = array.get(mLen, n - 3)
        l4  = array.get(mLen, n - 2)
        l5  = array.get(mLen, n - 1)

        isTop = array.get(mType, n - 5) == "H"
        headDevAbs = headDevMult * atrVal

        headOk      = isTop ? ((pr3 - pr1) >= headDevAbs and (pr3 - pr5) >= headDevAbs) : ((pr1 - pr3) >= headDevAbs and (pr5 - pr3) >= headDevAbs)
        shouldersOk = math.abs(pr1 - pr5) <= tolMult * atrVal
        structOk    = isTop ?
             (pr1 > pr2 and pr1 > pr4 and pr5 > pr2 and pr5 > pr4 and pr3 > pr2 and pr3 > pr4) :
             (pr1 < pr2 and pr1 < pr4 and pr5 < pr2 and pr5 < pr4 and pr3 < pr2 and pr3 < pr4)
        leftSpan  = b3 - b1
        rightSpan = b5 - b3
        timeOk    = leftSpan > 0 and rightSpan > 0 and math.max(leftSpan, rightSpan) / math.min(leftSpan, rightSpan) <= timeMax

        shapeOk = headOk and shouldersOk and structOk and timeOk

        refLen = math.max(l1, math.max(l2, math.max(l3, math.max(l4, l5))))
        lookbackBars = math.max(refLen, int(refLen * lookbackMult))
        [trendOk, extOffset, extVal] = checkTrend(b1, pr1, isTop, lookbackBars, trMult)

        if vizTrend and shapeOk and trMult > 0.0 and not na(extOffset) and (trendOk or vizTrendFailed)
            extBarIdx = bar_index - extOffset
            moveATR   = isTop ? (pr1 - extVal) / atrVal : (extVal - pr1) / atrVal
            drawTrendViz(extBarIdx, extVal, b1, pr1, isTop, moveATR, trMult, trendOk)

        lastEndForDir = isTop ? array.get(globalEndBear, 0) : array.get(globalEndBull, 0)
        noOverlap = na(lastEndForDir) or b1 > lastEndForDir

        if shapeOk and trendOk and noOverlap
            if useBreak
                if array.size(qB1) >= maxPending
                    array.shift(qB1)
                    array.shift(qB2)
                    array.shift(qB3)
                    array.shift(qB4)
                    array.shift(qB5)
                    array.shift(qPr1)
                    array.shift(qPr2)
                    array.shift(qPr3)
                    array.shift(qPr4)
                    array.shift(qPr5)
                    array.shift(qL1)
                    array.shift(qL2)
                    array.shift(qL3)
                    array.shift(qL4)
                    array.shift(qL5)
                    array.shift(qTop)
                    array.shift(qStart)
                array.push(qB1, b1)
                array.push(qB2, b2)
                array.push(qB3, b3)
                array.push(qB4, b4)
                array.push(qB5, b5)
                array.push(qPr1, pr1)
                array.push(qPr2, pr2)
                array.push(qPr3, pr3)
                array.push(qPr4, pr4)
                array.push(qPr5, pr5)
                array.push(qL1, l1)
                array.push(qL2, l2)
                array.push(qL3, l3)
                array.push(qL4, l4)
                array.push(qL5, l5)
                array.push(qTop, isTop)
                array.push(qStart, bar_index)
            else
                headLbl = "HEAD (mix " + str.tostring(l1) + "/" + str.tostring(l2) + "/" + str.tostring(l3) + "/" + str.tostring(l4) + "/" + str.tostring(l5) + ")"
                r1Lbl   = "R (P" + str.tostring(l1) + ")"
                r5Lbl   = "R (P" + str.tostring(l5) + ")"
                drawPattern(b1, b2, b3, b4, b5, pr1, pr2, pr3, pr4, pr5, isTop, headLbl, r1Lbl, r5Lbl)
                array.set(isTop ? globalEndBear : globalEndBull, 0, b5)
                fired := true
                isTopOut := isTop
                alert((isTop ? "H&S pattern (bear) — pivot mix " : "Inverse H&S pattern (bull) — pivot mix ") + str.tostring(l1) + "/" + str.tostring(l2) + "/" + str.tostring(l3) + "/" + str.tostring(l4) + "/" + str.tostring(l5), alert.freq_once_per_bar)

    if array.size(qB1) > 0
        i = array.size(qB1) - 1
        while i >= 0
            qb1 = array.get(qB1, i)
            qb2 = array.get(qB2, i)
            qb3 = array.get(qB3, i)
            qb4 = array.get(qB4, i)
            qb5 = array.get(qB5, i)
            qpr1 = array.get(qPr1, i)
            qpr2 = array.get(qPr2, i)
            qpr3 = array.get(qPr3, i)
            qpr4 = array.get(qPr4, i)
            qpr5 = array.get(qPr5, i)
            ql1 = array.get(qL1, i)
            ql2 = array.get(qL2, i)
            ql3 = array.get(qL3, i)
            ql4 = array.get(qL4, i)
            ql5 = array.get(qL5, i)
            qtop = array.get(qTop, i)
            qstart = array.get(qStart, i)

            neckSlopeQ = (qb4 - qb2) == 0 ? 0.0 : (qpr4 - qpr2) / (qb4 - qb2)
            neckNowQ   = qpr2 + neckSlopeQ * (bar_index - qb2)
            breakOkQ   = barstate.isconfirmed and (qtop ? close < neckNowQ : close > neckNowQ)
            refLenQ    = math.max(ql1, math.max(ql2, math.max(ql3, math.max(ql4, ql5))))
            maxWaitQ   = math.max(refLenQ, int(refLenQ * waitMult))
            expiredQ   = bar_index - qstart > maxWaitQ

            removeThis = false
            if breakOkQ
                lastEndForDirQ = qtop ? array.get(globalEndBear, 0) : array.get(globalEndBull, 0)
                stillNoOverlap = na(lastEndForDirQ) or qb1 > lastEndForDirQ
                if stillNoOverlap
                    headLbl = "HEAD (mix " + str.tostring(ql1) + "/" + str.tostring(ql2) + "/" + str.tostring(ql3) + "/" + str.tostring(ql4) + "/" + str.tostring(ql5) + ")"
                    r1Lbl   = "R (P" + str.tostring(ql1) + ")"
                    r5Lbl   = "R (P" + str.tostring(ql5) + ")"
                    drawPattern(qb1, qb2, qb3, qb4, qb5, qpr1, qpr2, qpr3, qpr4, qpr5, qtop, headLbl, r1Lbl, r5Lbl)
                    array.set(qtop ? globalEndBear : globalEndBull, 0, qb5)
                    fired := true
                    isTopOut := qtop
                    alert(qtop ? "Confirmed H&S pattern (bear) — pivot mix, neckline break" : "Confirmed inverse H&S pattern (bull) — pivot mix, neckline break", alert.freq_once_per_bar)
                removeThis := true
            else if expiredQ
                removeThis := true

            if removeThis
                array.remove(qB1, i)
                array.remove(qB2, i)
                array.remove(qB3, i)
                array.remove(qB4, i)
                array.remove(qB5, i)
                array.remove(qPr1, i)
                array.remove(qPr2, i)
                array.remove(qPr3, i)
                array.remove(qPr4, i)
                array.remove(qPr5, i)
                array.remove(qL1, i)
                array.remove(qL2, i)
                array.remove(qL3, i)
                array.remove(qL4, i)
                array.remove(qL5, i)
                array.remove(qTop, i)
                array.remove(qStart, i)
            i -= 1

    [fired, isTopOut]

// Run for each of the four pivot lengths + mix mode
fired1 = false
top1   = false
fired2 = false
top2   = false
fired3 = false
top3   = false
fired4 = false
top4   = false
firedMix = false
topMix   = false

anyMergedNew = false

if enablePivot1
    [newPivot1, merged1] = updatePivots(pivotLen1, pPrice1, pBar1, pType1, mPrice, mBar, mType, mLen, mixMode, pivotSrcHigh, pivotSrcLow)
    anyMergedNew := anyMergedNew or merged1
    [f1, t1_] = checkPattern(newPivot1, pPrice1, pBar1, pType1, pivotLen1, tolMult1, headDevMult1, trendLookbackMult, trendMult, timeSymmetryMax, breakoutWaitMult, useBreakConfirmation, showTrendViz, showTrendVizFailed, globalEndBull, globalEndBear)
    fired1 := f1
    top1   := t1_

if enablePivot2
    [newPivot2, merged2] = updatePivots(pivotLen2, pPrice2, pBar2, pType2, mPrice, mBar, mType, mLen, mixMode, pivotSrcHigh, pivotSrcLow)
    anyMergedNew := anyMergedNew or merged2
    [f2, t2_] = checkPattern(newPivot2, pPrice2, pBar2, pType2, pivotLen2, tolMult2, headDevMult2, trendLookbackMult, trendMult, timeSymmetryMax, breakoutWaitMult, useBreakConfirmation, showTrendViz, showTrendVizFailed, globalEndBull, globalEndBear)
    fired2 := f2
    top2   := t2_

if enablePivot3
    [newPivot3, merged3] = updatePivots(pivotLen3, pPrice3, pBar3, pType3, mPrice, mBar, mType, mLen, mixMode, pivotSrcHigh, pivotSrcLow)
    anyMergedNew := anyMergedNew or merged3
    [f3, t3_] = checkPattern(newPivot3, pPrice3, pBar3, pType3, pivotLen3, tolMult3, headDevMult3, trendLookbackMult, trendMult, timeSymmetryMax, breakoutWaitMult, useBreakConfirmation, showTrendViz, showTrendVizFailed, globalEndBull, globalEndBear)
    fired3 := f3
    top3   := t3_

if enablePivot4
    [newPivot4, merged4] = updatePivots(pivotLen4, pPrice4, pBar4, pType4, mPrice, mBar, mType, mLen, mixMode, pivotSrcHigh, pivotSrcLow)
    anyMergedNew := anyMergedNew or merged4
    [f4, t4_] = checkPattern(newPivot4, pPrice4, pBar4, pType4, pivotLen4, tolMult4, headDevMult4, trendLookbackMult, trendMult, timeSymmetryMax, breakoutWaitMult, useBreakConfirmation, showTrendViz, showTrendVizFailed, globalEndBull, globalEndBear)
    fired4 := f4
    top4   := t4_

if mixMode
    [fMix, tMix] = checkPatternMix(anyMergedNew, mPrice, mBar, mType, mLen, tolMultMix, headDevMultMix, trendLookbackMult, trendMult, timeSymmetryMax, breakoutWaitMult, useBreakConfirmation, showTrendViz, showTrendVizFailed, globalEndBull, globalEndBear)
    firedMix := fMix
    topMix   := tMix

// Plots for backtest / strategy use
sell1 = (fired1 and top1) or (fired2 and top2) or (fired3 and top3) or (fired4 and top4) or (firedMix and topMix)
buy1  = (fired1 and not top1) or (fired2 and not top2) or (fired3 and not top3) or (fired4 and not top4) or (firedMix and not topMix)

// Pivot length of the pattern that generated the signal on this bar (999 = mix mode).
// Lets a strategy/backtest tell which pivot length a signal came from.
lastFiredLen = fired1 ? pivotLen1 : fired2 ? pivotLen2 : fired3 ? pivotLen3 : fired4 ? pivotLen4 : firedMix ? 999 : na

plot(buy1  ? 1 : na, "bt_buy_score",  display = display.none)
plot(sell1 ? 1 : na, "bt_sell_score", display = display.none)
plot(lastFiredLen, "bt_pattern_len", display = display.none)

// Alerts 
alertcondition(buy1,             title="Inverse H&S (Bullish) Signal", message="Inverse Head & Shoulders (bullish) signal on {{ticker}} at {{close}}")
alertcondition(sell1,            title="H&S (Bearish) Signal",         message="Head & Shoulders (bearish) signal on {{ticker}} at {{close}}")
alertcondition(buy1 or sell1,    title="H&S / Inverse H&S Signal (Any)", message="Head & Shoulders pattern signal on {{ticker}} at {{close}}")
````
