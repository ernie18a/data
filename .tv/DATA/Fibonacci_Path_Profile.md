<!-- tradingview-pine-id: PUB;5016953157da4f44b05518a0d8632e6a -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Fibonacci Path Profile

Source: https://www.tradingview.com/script/BU7wGOjd-Fibonacci-Path-Profile-MantisAlgo/

## Description

Fibonacci Path Profile is a historical swing-path analysis tool that compares the active market structure with similar Fibonacci swing patterns from the past and visualizes the historical distribution of the next D and E swing points.

The indicator combines the current A→B impulse, B→C retracement or extension, and live C→Now progress to continuously refine the historical sample.

🟢 ABC STRUCTURE
The indicator automatically detects alternating swing highs and swing lows and organizes them into an A-B-C structure.

Bullish ABC 
[image]https://www.tradingview.com/x/wm5htlEt/[/image]
A→B = upward impulse
B→C = downward retracement
The next D swing develops upward from C

Bearish ABC 
[image]https://www.tradingview.com/x/StK3UK7R/[/image]
A→B = downward impulse
B→C = upward retracement
The next D swing develops downward from C

A→B is used as the base swing for all subsequent Fibonacci measurements.

🟢 FIBONACCI MATCHING
The B→C movement is measured relative to the A→B impulse:
B→C Ratio = |B − C| / |A − B|

Historical cases are matched using:
Bullish or Bearish ABC direction
B→C Fibonacci range
Live C→Now progress

The B→C ranges are:
0–23.6%
23.6–38.2%
38.2–50%
50–61.8%
61.8–78.6%
78.6–100%
100–127.2%
127.2–161.8%
161.8%+

Up to 100% is classified as a Retrace, while values above 100% are classified as an Extension.
* To preserve a usable historical sample, all B→C values above 161.8% are grouped into a single 161.8%+ matching range rather than being divided into additional extension classes.

🟢 LIVE C→NOW MATCHING
The indicator also measures how far the active move has progressed from C relative to the B→C range.

C→Now = current progress from C relative to |B − C|

As price develops, this progress is used to filter historical cases that remained valid through a similar stage of the move.

🟢 D & E PATH
The profiles show the historical locations of the next two swing points:
D PathDistribution of the next swing point after C.
E PathDistribution of the following swing point after D.

Both D and E locations are normalized relative to the B→C range, allowing historical structures of different absolute sizes to be compared on the same basis.

The E Path is also separated into three structural outcomes:
🟥 B Break — E moves beyond the B level
🟨 No Break — E remains between B and C
🟦 C Break — E moves beyond the C level

The displayed percentages represent the weighted share of each outcome among the currently matched historical cases.

* For the D and E profiles, values beyond the displayed ±161.8% range are grouped into the outermost top or bottom bin rather than split into additional bins.

🟢 REAL-TIME PROFILE
The active profile is continuously recalculated as price develops.
This can update:
C→Now progress
matched historical cases
D Path distribution
E Path distribution
B Break / No Break / C Break probabilities

Because D and E represent the active forward path, both profile boxes are always displayed to the right of the current candle.

🟢 DYNAMIC C
Before a new D swing is confirmed, the B→C retracement may continue to a new extreme.
In that case, the active C point is updated:
Bullish ABC → C moves to a new lower low
Bearish ABC → C moves to a new higher high

This prevents an unfinished B→C leg from being treated as a completed swing.

🟢 WEIGHT
Two weighting methods are available:
Recent
More recent historical cases receive greater weight.
Weight = 1 / (1 + Age / 1500)
where Age is measured in bars.

Equal
Every matched historical case receives the same weight.
Use Recent to emphasize newer market behavior or Equal to view the unweighted historical distribution.

🟢 HOW TO USE
Use the indicator to evaluate how similar historical structures developed from the current setup.
D Path highlights where the next swing historically tended to form.
E Path shows how price developed after that D swing.
B Break / No Break / C Break summarizes the historical structural outcome.
C→Now continuously refines the sample as the active move progresses.
The profiles represent historical swing distributions, not traded volume.

They are designed to provide a probabilistic view of the active structure rather than a fixed Fibonacci price target.

🟢 DISCLAIMER
This indicator is provided for informational and educational purposes only and does not constitute financial or investment advice.
Historical patterns and probabilities do not guarantee future results. All trading and investment decisions remain the sole responsibility of the user.

---

## Source Code

````pine
// © 2026 MantisAlgo
// All rights reserved.
//@version=6
indicator("Fibonacci Path Profile", "Fibonacci Path Profile", overlay = true, max_bars_back = 5000, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// -----------------------------------------------------------------------------
// Fibonacci Path Profile
// Converts swings into Fibonacci zones for matching, while displaying the
// live setup and next path distribution as actual path percentages.
//
// A-B = base impulse
// B-C = Fibonacci retrace/extension class.
// C-now = live progress from C toward the next break/range outcome.
//
// If the current active setup is A-B-C, the indicator searches historical cases
// with the same retracement code and plots D Path first, then the following
// resolution path on the right side of the chart.
// -----------------------------------------------------------------------------

grpWeight = "Pattern Matching"
weightMode = input.string("Recent", "Weight", options = ["Recent", "Equal"], group = grpWeight)

int pivotLen = 8
int maxCases = 500
int minDynamicMatches = 10
float liveToleranceStep = 0.05
int liveToleranceSteps = 100
bool useRecencyWeight = weightMode == "Recent"
int recencyHalfLife = 1500
int rightOffset = 1
int maxBarWidth = 34
int pathGap = 8
int denseBins = 30
float ratioMax = 1.618
float profileGap = 0.16
bool showActivePath = true
bool showLiveLeg = true
bool showDashboard = true

color bullColor = #00BFA5
color bearColor = #FF5252
color profileColor = #42A5F5
color failColor = #FFD54F
color oppositeColor = #FF3864
color dPathColor = #006B3C

// Fib class edges.
var float[] rEdges = array.from(0.000, 0.236, 0.382, 0.500, 0.618, 0.786, 1.000, 1.272, 1.618, 10.000)

// Historical ABCDE cases.
var int[] caseDir = array.new_int()
var int[] caseR = array.new_int()
var float[] caseExpectedRatio = array.new_float()
var float[] caseFailProgress = array.new_float()
var float[] caseOppositeRatio = array.new_float()
var float[] caseDProgress = array.new_float()
var float[] caseEProgress = array.new_float()
var int[] caseBar = array.new_int()

// Alternating confirmed pivots.
var float[] pivPrice = array.new_float()
var int[] pivBar = array.new_int()
var int[] pivType = array.new_int()

// Draw handles.
var box[] boxes = array.new_box()
var label[] labels = array.new_label()
var line[] lines = array.new_line()
var line abLine = na
var line bcLine = na
var line abShadow = na
var line bcShadow = na
var line liveLine = na
var table dash = table.new(position.top_right, 2, 5, border_width = 1, border_color = color.new(#787B86, 35), frame_width = 2, frame_color = color.new(#787B86, 20))

f_abs(float x) =>
    math.abs(x)

f_class(float ratio, float[] edges) =>
    int result = array.size(edges) - 2
    int n = array.size(edges) - 1
    for i = 0 to n - 1
        float lo = array.get(edges, i)
        float hi = array.get(edges, i + 1)
        if ratio >= lo and ratio < hi
            result := i
            break
    result

f_path_type(float ratio) =>
    string result = ratio > 1.000 ? "Extension" : "Retrace"
    result

f_fib_zone_range(float ratio) =>
    string result = ratio >= 1.618 ? "161.8%+" : ratio >= 1.272 ? "127.2–161.8%" : ratio > 1.000 ? "100–127.2%" : ratio >= 0.786 ? "78.6–100%" : ratio >= 0.618 ? "61.8–78.6%" : ratio >= 0.500 ? "50–61.8%" : ratio >= 0.382 ? "38.2–50%" : ratio >= 0.236 ? "23.6–38.2%" : "0–23.6%"
    result

f_push_case(int dir, int rCls, float expectedRatio, float failProgress, float oppositeRatio, float dProgress, float eProgress, int eventBar) =>
    array.push(caseDir, dir)
    array.push(caseR, rCls)
    array.push(caseExpectedRatio, expectedRatio)
    array.push(caseFailProgress, failProgress)
    array.push(caseOppositeRatio, oppositeRatio)
    array.push(caseDProgress, dProgress)
    array.push(caseEProgress, eProgress)
    array.push(caseBar, eventBar)
    while array.size(caseDir) > maxCases
        array.shift(caseDir)
        array.shift(caseR)
        array.shift(caseExpectedRatio)
        array.shift(caseFailProgress)
        array.shift(caseOppositeRatio)
        array.shift(caseDProgress)
        array.shift(caseEProgress)
        array.shift(caseBar)
    0

f_record_latest_case() =>
    int n = array.size(pivPrice)
    if n >= 5
        float a = array.get(pivPrice, n - 5)
        float b = array.get(pivPrice, n - 4)
        float c = array.get(pivPrice, n - 3)
        float d = array.get(pivPrice, n - 2)
        float e = array.get(pivPrice, n - 1)
        int dBar = array.get(pivBar, n - 2)
        float ab = f_abs(b - a)
        if ab > 0
            int dir = b > a ? 1 : -1
            float retraceRatio = f_abs(b - c) / ab
            bool dBeyondB = dir == 1 ? d > b : d < b
            float expectedRatio = dBeyondB ? f_abs(d - a) / ab : na
            float cb = f_abs(c - b)
            float failProgress = not dBeyondB and cb > 0 ? math.min(math.max(f_abs(c - d) / cb, 0.0), 1.0) : na
            bool eBeyondC = not dBeyondB and (dir == 1 ? e < c : e > c)
            float oppositeRatio = eBeyondC ? f_abs(e - c) / ab : na
            float dProgress = cb > 0 ? (d - c) / (b - c) : na
            float eProgress = cb > 0 ? (e - c) / (b - c) : na
            int rCls = f_class(retraceRatio, rEdges)
            f_push_case(dir, rCls, expectedRatio, failProgress, oppositeRatio, dProgress, eProgress, dBar)
    0

f_add_pivot(float price, int pBar, int pTyp) =>
    int n = array.size(pivPrice)
    if n == 0
        array.push(pivPrice, price)
        array.push(pivBar, pBar)
        array.push(pivType, pTyp)
    else
        int lastTyp = array.get(pivType, n - 1)
        float lastPrice = array.get(pivPrice, n - 1)
        bool sameType = pTyp == lastTyp
        if sameType
            bool moreExtreme = pTyp == 1 ? price > lastPrice : price < lastPrice
            if moreExtreme
                array.set(pivPrice, n - 1, price)
                array.set(pivBar, n - 1, pBar)
        else
            array.push(pivPrice, price)
            array.push(pivBar, pBar)
            array.push(pivType, pTyp)
            f_record_latest_case()
            while array.size(pivPrice) > 90
                array.shift(pivPrice)
                array.shift(pivBar)
                array.shift(pivType)
    0

f_clear_drawings() =>
    int nb = array.size(boxes)
    if nb > 0
        for i = nb - 1 to 0
            box.delete(array.get(boxes, i))
        array.clear(boxes)
    int nl = array.size(labels)
    if nl > 0
        for i = nl - 1 to 0
            label.delete(array.get(labels, i))
        array.clear(labels)
    int nln = array.size(lines)
    if nln > 0
        for i = nln - 1 to 0
            line.delete(array.get(lines, i))
        array.clear(lines)
    0

f_price_from_ext(float a, float b, int dir, float ratio) =>
    float ab = f_abs(b - a)
    dir == 1 ? a + ab * ratio : a - ab * ratio

f_ext_bin_price(float a, float b, int dir, float loRatio, float hiRatio) =>
    float y1 = f_price_from_ext(a, b, dir, loRatio)
    float y2 = f_price_from_ext(a, b, dir, hiRatio)
    [math.max(y1, y2), math.min(y1, y2)]

f_fail_bin_price(float b, float c, float loProgress, float hiProgress) =>
    float y1 = c + (b - c) * loProgress
    float y2 = c + (b - c) * hiProgress
    [math.max(y1, y2), math.min(y1, y2)]

f_opposite_bin_price(float a, float b, float c, int dir, float loRatio, float hiRatio) =>
    float ab = f_abs(b - a)
    float y1 = dir == 1 ? c - ab * loRatio : c + ab * loRatio
    float y2 = dir == 1 ? c - ab * hiRatio : c + ab * hiRatio
    [math.max(y1, y2), math.min(y1, y2)]

f_gap_top(float top, float bot) =>
    float mid = (top + bot) / 2.0
    float half = (top - bot) * math.max(1.0 - profileGap, 0.05) / 2.0
    mid + half

f_gap_bot(float top, float bot) =>
    float mid = (top + bot) / 2.0
    float half = (top - bot) * math.max(1.0 - profileGap, 0.05) / 2.0
    mid - half

f_weight(int eventBar) =>
    float age = math.max(bar_index - eventBar, 0)
    useRecencyWeight ? 1.0 / (1.0 + age / recencyHalfLife) : 1.0

f_match_r(int histR, int currentR) =>
    histR == currentR

f_match_dir(int histDir, int currentDir) =>
    histDir == currentDir

f_live_progress(float b, float c, int dir) =>
    float cb = f_abs(c - b)
    float raw = cb > 0 ? (dir == 1 ? (close - c) / (b - c) : (c - close) / (c - b)) : 0.0
    math.max(raw, 0.0)

f_case_progress(float expectedRatio, float failProgress) =>
    not na(expectedRatio) ? math.max(expectedRatio - 1.0, 1.0) : not na(failProgress) ? failProgress : 0.0

f_match_live(float expectedRatio, float failProgress, float liveProg, float tolerance) =>
    liveProg <= 0.02 or f_case_progress(expectedRatio, failProgress) >= math.max(liveProg - tolerance, 0.0)

f_total_match_weight(int dir, int rCls, float bRef, float cRef, float tolerance) =>
    float sum = 0.0
    float liveProg = f_live_progress(bRef, cRef, dir)
    int n = array.size(caseDir)
    if n > 0
        for i = 0 to n - 1
            bool dirOk = f_match_dir(array.get(caseDir, i), dir)
            bool rOk = f_match_r(array.get(caseR, i), rCls)
            bool liveOk = f_match_live(array.get(caseExpectedRatio, i), array.get(caseFailProgress, i), liveProg, tolerance)
            if dirOk and rOk and liveOk
                sum += f_weight(array.get(caseBar, i))
    sum

f_total_match_count(int dir, int rCls, float bRef, float cRef, float tolerance) =>
    int count = 0
    float liveProg = f_live_progress(bRef, cRef, dir)
    int n = array.size(caseDir)
    if n > 0
        for i = 0 to n - 1
            bool dirOk = f_match_dir(array.get(caseDir, i), dir)
            bool rOk = f_match_r(array.get(caseR, i), rCls)
            bool liveOk = f_match_live(array.get(caseExpectedRatio, i), array.get(caseFailProgress, i), liveProg, tolerance)
            if dirOk and rOk and liveOk
                count += 1
    count

f_select_live_tolerance(int dir, int rCls, float bRef, float cRef) =>
    float selected = 0.0
    float liveProg = f_live_progress(bRef, cRef, dir)
    for step = 0 to liveToleranceSteps
        float steppedTolerance = step * liveToleranceStep
        float tolerance = step == liveToleranceSteps ? math.max(steppedTolerance, liveProg) : steppedTolerance
        int count = f_total_match_count(dir, rCls, bRef, cRef, tolerance)
        selected := tolerance
        if count >= minDynamicMatches
            break
    selected

f_expected_bin_weight(int dir, int rCls, float loRatio, float hiRatio, float bRef, float cRef, float tolerance) =>
    float sum = 0.0
    float liveProg = f_live_progress(bRef, cRef, dir)
    int n = array.size(caseDir)
    if n > 0
        for i = 0 to n - 1
            bool dirOk = f_match_dir(array.get(caseDir, i), dir)
            bool rOk = f_match_r(array.get(caseR, i), rCls)
            float ext = array.get(caseExpectedRatio, i)
            bool extOk = not na(ext) and ext >= loRatio and ext < hiRatio
            bool liveOk = f_match_live(ext, array.get(caseFailProgress, i), liveProg, tolerance)
            if dirOk and rOk and extOk and liveOk
                sum += f_weight(array.get(caseBar, i))
    sum

f_d_fail_bin_weight(int dir, int rCls, float loProgress, float hiProgress, float bRef, float cRef, float tolerance) =>
    float sum = 0.0
    float liveProg = f_live_progress(bRef, cRef, dir)
    int n = array.size(caseDir)
    if n > 0
        for i = 0 to n - 1
            bool dirOk = f_match_dir(array.get(caseDir, i), dir)
            bool rOk = f_match_r(array.get(caseR, i), rCls)
            float fp = array.get(caseFailProgress, i)
            bool failOk = not na(fp) and fp >= loProgress and fp < hiProgress
            bool liveOk = f_match_live(array.get(caseExpectedRatio, i), fp, liveProg, tolerance)
            if dirOk and rOk and failOk and liveOk
                sum += f_weight(array.get(caseBar, i))
    sum

f_d_bin_weight(int dir, int rCls, float loProgress, float hiProgress, float bRef, float cRef, float tolerance) =>
    float sum = 0.0
    float liveProg = f_live_progress(bRef, cRef, dir)
    int n = array.size(caseDir)
    if n > 0
        for i = 0 to n - 1
            bool dirOk = f_match_dir(array.get(caseDir, i), dir)
            bool rOk = f_match_r(array.get(caseR, i), rCls)
            float dp = array.get(caseDProgress, i)
            bool dOk = not na(dp) and dp >= loProgress and dp < hiProgress
            bool liveOk = f_match_live(array.get(caseExpectedRatio, i), array.get(caseFailProgress, i), liveProg, tolerance)
            if dirOk and rOk and dOk and liveOk
                sum += f_weight(array.get(caseBar, i))
    sum

f_fail_bin_weight(int dir, int rCls, float loProgress, float hiProgress, float bRef, float cRef, float tolerance) =>
    float sum = 0.0
    float liveProg = f_live_progress(bRef, cRef, dir)
    int n = array.size(caseDir)
    if n > 0
        for i = 0 to n - 1
            bool dirOk = f_match_dir(array.get(caseDir, i), dir)
            bool rOk = f_match_r(array.get(caseR, i), rCls)
            float fp = array.get(caseFailProgress, i)
            float op = array.get(caseOppositeRatio, i)
            bool failOk = not na(fp) and na(op) and fp >= loProgress and fp < hiProgress
            bool liveOk = f_match_live(array.get(caseExpectedRatio, i), fp, liveProg, tolerance)
            if dirOk and rOk and failOk and liveOk
                sum += f_weight(array.get(caseBar, i))
    sum

f_opposite_bin_weight(int dir, int rCls, float loRatio, float hiRatio, float bRef, float cRef, float tolerance) =>
    float sum = 0.0
    float liveProg = f_live_progress(bRef, cRef, dir)
    int n = array.size(caseDir)
    if n > 0
        for i = 0 to n - 1
            bool dirOk = f_match_dir(array.get(caseDir, i), dir)
            bool rOk = f_match_r(array.get(caseR, i), rCls)
            float op = array.get(caseOppositeRatio, i)
            bool opOk = not na(op) and op >= loRatio and op < hiRatio
            bool liveOk = f_match_live(array.get(caseExpectedRatio, i), array.get(caseFailProgress, i), liveProg, tolerance)
            if dirOk and rOk and opOk and liveOk
                sum += f_weight(array.get(caseBar, i))
    sum

f_e_bin_weight(int dir, int rCls, float loProgress, float hiProgress, float bRef, float cRef, float tolerance) =>
    float sum = 0.0
    float liveProg = f_live_progress(bRef, cRef, dir)
    int n = array.size(caseDir)
    if n > 0
        for i = 0 to n - 1
            bool dirOk = f_match_dir(array.get(caseDir, i), dir)
            bool rOk = f_match_r(array.get(caseR, i), rCls)
            float ep = array.get(caseEProgress, i)
            bool eOk = not na(ep) and ep >= loProgress and ep < hiProgress
            bool liveOk = f_match_live(array.get(caseExpectedRatio, i), array.get(caseFailProgress, i), liveProg, tolerance)
            if dirOk and rOk and eOk and liveOk
                sum += f_weight(array.get(caseBar, i))
    sum

f_outcome_weight(int dir, int rCls, int outcome, float bRef, float cRef, float tolerance) =>
    float sum = 0.0
    float liveProg = f_live_progress(bRef, cRef, dir)
    int n = array.size(caseDir)
    if n > 0
        for i = 0 to n - 1
            bool dirOk = f_match_dir(array.get(caseDir, i), dir)
            bool rOk = f_match_r(array.get(caseR, i), rCls)
            float exp = array.get(caseExpectedRatio, i)
            float fp = array.get(caseFailProgress, i)
            float op = array.get(caseOppositeRatio, i)
            bool liveOk = f_match_live(exp, fp, liveProg, tolerance)
            bool outcomeOk = outcome == 1 ? not na(exp) : outcome == -1 ? not na(op) : na(exp) and na(op)
            if dirOk and rOk and liveOk and outcomeOk
                sum += f_weight(array.get(caseBar, i))
    sum

f_e_outcome_weight(int dir, int rCls, int outcome, float bRef, float cRef, float tolerance) =>
    float sum = 0.0
    float liveProg = f_live_progress(bRef, cRef, dir)
    int n = array.size(caseDir)
    if n > 0
        for i = 0 to n - 1
            bool dirOk = f_match_dir(array.get(caseDir, i), dir)
            bool rOk = f_match_r(array.get(caseR, i), rCls)
            float ep = array.get(caseEProgress, i)
            bool outcomeOk = outcome == 1 ? not na(ep) and ep >= 1.0 : outcome == -1 ? not na(ep) and ep < 0.0 : not na(ep) and ep >= 0.0 and ep < 1.0
            bool liveOk = f_match_live(array.get(caseExpectedRatio, i), array.get(caseFailProgress, i), liveProg, tolerance)
            if dirOk and rOk and outcomeOk and liveOk
                sum += f_weight(array.get(caseBar, i))
    sum

// Build pivot stream.
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

if not na(ph)
    f_add_pivot(ph, bar_index - pivotLen, 1)
if not na(pl)
    f_add_pivot(pl, bar_index - pivotLen, -1)

// Current active A-B-C setup.
int pN = array.size(pivPrice)
float a = pN >= 3 ? array.get(pivPrice, pN - 3) : na
float b = pN >= 3 ? array.get(pivPrice, pN - 2) : na
float c = pN >= 3 ? array.get(pivPrice, pN - 1) : na
int aBar = pN >= 3 ? array.get(pivBar, pN - 3) : na
int bBar = pN >= 3 ? array.get(pivBar, pN - 2) : na
int cBar = pN >= 3 ? array.get(pivBar, pN - 1) : na
float abNow = pN >= 3 ? f_abs(b - a) : na
int dirNow = pN >= 3 ? (b > a ? 1 : -1) : 0
if pN >= 3
    int cScanBars = math.min(bar_index - cBar, 5000)
    float extremeC = c
    int extremeCBar = cBar
    if cScanBars > 0
        for j = 0 to cScanBars
            int off = cScanBars - j
            bool isAfterBaseC = bar_index - off >= cBar
            if isAfterBaseC
                float candidateC = dirNow == 1 ? low[off] : high[off]
                bool moreExtremeC = dirNow == 1 ? candidateC < extremeC : candidateC > extremeC
                if moreExtremeC
                    extremeC := candidateC
                    extremeCBar := bar_index - off
    c := extremeC
    cBar := extremeCBar
    abNow := f_abs(b - a)
float rNow = pN >= 3 and abNow > 0 ? f_abs(b - c) / abNow : na
int rClsNow = not na(rNow) ? f_class(rNow, rEdges) : na
float atrNow = ta.atr(14)
if pN >= 3
    if not na(abShadow)
        line.delete(abShadow)
    if not na(bcShadow)
        line.delete(bcShadow)
    if not na(abLine)
        line.delete(abLine)
    if not na(bcLine)
        line.delete(bcLine)
    if not na(liveLine)
        line.delete(liveLine)
if showActivePath and pN >= 3
    color pathColor = dirNow == 1 ? bullColor : bearColor
    abShadow := line.new(aBar, a, bBar, b, color = color.new(pathColor, 82), width = 8)
    bcShadow := line.new(bBar, b, cBar, c, color = color.new(pathColor, 86), width = 8)
    abLine := line.new(aBar, a, bBar, b, color = color.new(pathColor, 0), width = 2)
    bcLine := line.new(bBar, b, cBar, c, color = color.new(pathColor, 10), width = 2)
    if showLiveLeg and bar_index > cBar
        liveLine := line.new(cBar, c, bar_index, close, color = color.new(pathColor, 35), width = 2, style = line.style_dotted)

// Render forecast profile.
if barstate.islast and pN >= 3 and abNow > 0
    f_clear_drawings()

    float liveToleranceNow = f_select_live_tolerance(dirNow, rClsNow, b, c)
    float totalWeight = f_total_match_weight(dirNow, rClsNow, b, c, liveToleranceNow)
    int totalCount = f_total_match_count(dirNow, rClsNow, b, c, liveToleranceNow)
    float maxBinWeight = 0.0
    float expectedTotalWeight = f_e_outcome_weight(dirNow, rClsNow, 1, b, c, liveToleranceNow)
    float failTotalWeight = f_e_outcome_weight(dirNow, rClsNow, 0, b, c, liveToleranceNow)
    float oppositeTotalWeight = f_e_outcome_weight(dirNow, rClsNow, -1, b, c, liveToleranceNow)
    float bcSpan = b - c
    bool hasBcSpan = math.abs(bcSpan) > 0
    float posFar = c + bcSpan * ratioMax
    float negFar = c - bcSpan * ratioMax
    float frameTop = math.max(math.max(posFar, negFar), math.max(b, c))
    float frameBot = math.min(math.min(posFar, negFar), math.min(b, c))
    float binStep = math.max((frameTop - frameBot) / denseBins, syminfo.mintick)
    for bi = 0 to denseBins - 1
        float binBot = frameBot + binStep * bi
        float binTop = bi == denseBins - 1 ? frameTop : frameBot + binStep * (bi + 1)
        float prog1 = hasBcSpan ? (binBot - c) / bcSpan : 0.0
        float prog2 = hasBcSpan ? (binTop - c) / bcSpan : 0.0
        float progLoRaw = math.min(prog1, prog2)
        float progHiRaw = math.max(prog1, prog2)
        float progLoMatch = progLoRaw <= -ratioMax ? -1000.0 : progLoRaw
        float progHiMatch = progHiRaw >= ratioMax ? 1000.0 : progHiRaw
        float eLo = math.min(progLoMatch, progHiMatch)
        float eHi = math.max(progLoMatch, progHiMatch)
        float dLo = math.max(eLo, 0.0)
        float dHi = eHi
        float dW = hasBcSpan and dHi > dLo ? f_d_bin_weight(dirNow, rClsNow, dLo, dHi, b, c, liveToleranceNow) : 0.0
        if dW > maxBinWeight
            maxBinWeight := dW
        float eW = hasBcSpan and eHi > eLo ? f_e_bin_weight(dirNow, rClsNow, eLo, eHi, b, c, liveToleranceNow) : 0.0
        if eW > maxBinWeight
            maxBinWeight := eW
    bool inside = false
    int dProfileLeftX = bar_index + rightOffset
    int dProfileRightX = dProfileLeftX + maxBarWidth
    int eProfileLeftX = dProfileRightX + pathGap
    int eProfileRightX = eProfileLeftX + maxBarWidth
    int profileRightX = eProfileRightX
    int profilePadX = 1
    int dBarLeftX = inside ? dProfileLeftX : dProfileLeftX + profilePadX
    int dBarRightX = inside ? dProfileRightX - profilePadX : dProfileRightX
    int eBarLeftX = inside ? eProfileLeftX : eProfileLeftX + profilePadX
    int eBarRightX = inside ? eProfileRightX - profilePadX : eProfileRightX
    int barMaxWidth = math.max(maxBarWidth - profilePadX * 2, 1)
    color setupColor = dirNow == 1 ? bullColor : bearColor
    color bBreakColor = dirNow == 1 ? oppositeColor : profileColor
    color cBreakColor = dirNow == 1 ? profileColor : oppositeColor
    float framePad = math.max((frameTop - frameBot) * 0.045, syminfo.mintick * 10.0)
    float dFrameTop = dirNow == 1 ? frameTop : c
    float dFrameBot = dirNow == 1 ? c : frameBot
    float dBoxTop = dirNow == 1 ? dFrameTop + framePad : c
    float dBoxBot = dirNow == 1 ? c : dFrameBot - framePad
    box dFrame = box.new(dProfileLeftX, dBoxTop, dProfileRightX, dBoxBot, xloc = xloc.bar_index, bgcolor = color.new(dPathColor, 96), border_color = color.new(dPathColor, 100), border_width = 1)
    box eFrame = box.new(eProfileLeftX, frameTop + framePad, eProfileRightX, frameBot - framePad, xloc = xloc.bar_index, bgcolor = color.new(setupColor, 97), border_color = color.new(setupColor, 100), border_width = 1)
    array.push(boxes, dFrame)
    array.push(boxes, eFrame)
    line dFrameTopGlow = line.new(dProfileLeftX, dBoxTop, dProfileRightX, dBoxTop, xloc = xloc.bar_index, color = color.new(dPathColor, 82), width = 8)
    line dFrameBotGlow = line.new(dProfileLeftX, dBoxBot, dProfileRightX, dBoxBot, xloc = xloc.bar_index, color = color.new(dPathColor, 82), width = 8)
    line dFrameLeftGlow = line.new(dProfileLeftX, dBoxTop, dProfileLeftX, dBoxBot, xloc = xloc.bar_index, color = color.new(dPathColor, 82), width = 8)
    line dFrameRightGlow = line.new(dProfileRightX, dBoxTop, dProfileRightX, dBoxBot, xloc = xloc.bar_index, color = color.new(dPathColor, 82), width = 8)
    line eFrameTopGlow = line.new(eProfileLeftX, frameTop + framePad, eProfileRightX, frameTop + framePad, xloc = xloc.bar_index, color = color.new(setupColor, 82), width = 8)
    line eFrameBotGlow = line.new(eProfileLeftX, frameBot - framePad, eProfileRightX, frameBot - framePad, xloc = xloc.bar_index, color = color.new(setupColor, 82), width = 8)
    line eFrameLeftGlow = line.new(eProfileLeftX, frameTop + framePad, eProfileLeftX, frameBot - framePad, xloc = xloc.bar_index, color = color.new(setupColor, 82), width = 8)
    line eFrameRightGlow = line.new(eProfileRightX, frameTop + framePad, eProfileRightX, frameBot - framePad, xloc = xloc.bar_index, color = color.new(setupColor, 82), width = 8)
    line dFrameTopCore = line.new(dProfileLeftX, dBoxTop, dProfileRightX, dBoxTop, xloc = xloc.bar_index, color = color.new(dPathColor, 0), width = 2)
    line dFrameBotCore = line.new(dProfileLeftX, dBoxBot, dProfileRightX, dBoxBot, xloc = xloc.bar_index, color = color.new(dPathColor, 0), width = 2)
    line dFrameLeftCore = line.new(dProfileLeftX, dBoxTop, dProfileLeftX, dBoxBot, xloc = xloc.bar_index, color = color.new(dPathColor, 0), width = 2)
    line dFrameRightCore = line.new(dProfileRightX, dBoxTop, dProfileRightX, dBoxBot, xloc = xloc.bar_index, color = color.new(dPathColor, 0), width = 2)
    line eFrameTopCore = line.new(eProfileLeftX, frameTop + framePad, eProfileRightX, frameTop + framePad, xloc = xloc.bar_index, color = color.new(setupColor, 0), width = 2)
    line eFrameBotCore = line.new(eProfileLeftX, frameBot - framePad, eProfileRightX, frameBot - framePad, xloc = xloc.bar_index, color = color.new(setupColor, 0), width = 2)
    line eFrameLeftCore = line.new(eProfileLeftX, frameTop + framePad, eProfileLeftX, frameBot - framePad, xloc = xloc.bar_index, color = color.new(setupColor, 0), width = 2)
    line eFrameRightCore = line.new(eProfileRightX, frameTop + framePad, eProfileRightX, frameBot - framePad, xloc = xloc.bar_index, color = color.new(setupColor, 0), width = 2)
    line pathArrowShadow = line.new(dProfileRightX + 1, c, eProfileLeftX - 1, c, xloc = xloc.bar_index, color = color.new(dPathColor, 74), style = line.style_arrow_right, width = 8)
    line pathArrowCore = line.new(dProfileRightX + 1, c, eProfileLeftX - 1, c, xloc = xloc.bar_index, color = color.new(dPathColor, 20), style = line.style_arrow_right, width = 4)
    label dPathTitle = label.new(dProfileLeftX + int(math.floor(maxBarWidth / 2)), dBoxTop, "D Path", xloc = xloc.bar_index, style = label.style_label_down, textcolor = color.white, color = color.new(dPathColor, 0), size = size.small)
    label ePathTitle = label.new(eProfileLeftX + int(math.floor(maxBarWidth / 2)), frameTop + framePad, "E Path", xloc = xloc.bar_index, style = label.style_label_down, textcolor = color.white, color = color.new(setupColor, 0), size = size.small)
    array.push(lines, dFrameTopGlow)
    array.push(lines, dFrameBotGlow)
    array.push(lines, dFrameLeftGlow)
    array.push(lines, dFrameRightGlow)
    array.push(lines, eFrameTopGlow)
    array.push(lines, eFrameBotGlow)
    array.push(lines, eFrameLeftGlow)
    array.push(lines, eFrameRightGlow)
    array.push(lines, dFrameTopCore)
    array.push(lines, dFrameBotCore)
    array.push(lines, dFrameLeftCore)
    array.push(lines, dFrameRightCore)
    array.push(lines, eFrameTopCore)
    array.push(lines, eFrameBotCore)
    array.push(lines, eFrameLeftCore)
    array.push(lines, eFrameRightCore)
    array.push(lines, pathArrowShadow)
    array.push(lines, pathArrowCore)
    array.push(labels, dPathTitle)
    array.push(labels, ePathTitle)

    for bi = 0 to denseBins - 1
        float binBot = frameBot + binStep * bi
        float binTop = bi == denseBins - 1 ? frameTop : frameBot + binStep * (bi + 1)
        float prog1 = hasBcSpan ? (binBot - c) / bcSpan : 0.0
        float prog2 = hasBcSpan ? (binTop - c) / bcSpan : 0.0
        float progLoRaw = math.min(prog1, prog2)
        float progHiRaw = math.max(prog1, prog2)
        float progMid = (progLoRaw + progHiRaw) / 2.0
        float progLoMatch = progLoRaw <= -ratioMax ? -1000.0 : progLoRaw
        float progHiMatch = progHiRaw >= ratioMax ? 1000.0 : progHiRaw
        bool isBBreakZone = progMid >= 1.0
        bool isCBreakZone = progMid < 0.0
        float drawTop = f_gap_top(binTop, binBot)
        float drawBot = f_gap_bot(binTop, binBot)

        float eLo = math.min(progLoMatch, progHiMatch)
        float eHi = math.max(progLoMatch, progHiMatch)
        float dLo = math.max(eLo, 0.0)
        float dHi = eHi
        float dW = hasBcSpan and dHi > dLo ? f_d_bin_weight(dirNow, rClsNow, dLo, dHi, b, c, liveToleranceNow) : 0.0
        int dWidth = dW > 0 and maxBinWeight > 0 ? math.max(1, int(math.round(dW / maxBinWeight * barMaxWidth))) : 0
        if dWidth > 0
            int x1 = inside ? dBarRightX - dWidth : dBarLeftX
            int x2 = inside ? dBarRightX : dBarLeftX + dWidth
            float intensity = dW / math.max(maxBinWeight, 0.0001)
            int alpha = int(math.round(78 - intensity * 48))
            box db = box.new(x1, drawTop, x2, drawBot, xloc = xloc.bar_index, bgcolor = color.new(dPathColor, alpha), border_color = color.new(chart.bg_color, 70))
            array.push(boxes, db)

        float eW = hasBcSpan and eHi > eLo ? f_e_bin_weight(dirNow, rClsNow, eLo, eHi, b, c, liveToleranceNow) : 0.0
        int eWidth = eW > 0 and maxBinWeight > 0 ? math.max(1, int(math.round(eW / maxBinWeight * barMaxWidth))) : 0
        if eWidth > 0
            int x1 = inside ? eBarRightX - eWidth : eBarLeftX
            int x2 = inside ? eBarRightX : eBarLeftX + eWidth
            float intensity = eW / math.max(maxBinWeight, 0.0001)
            int alpha = int(math.round(84 - intensity * 54))
            color eColor = isBBreakZone ? bBreakColor : isCBreakZone ? cBreakColor : failColor
            box eb = box.new(x1, drawTop, x2, drawBot, xloc = xloc.bar_index, bgcolor = color.new(eColor, alpha), border_color = color.new(chart.bg_color, 70))
            array.push(boxes, eb)

    float expectedPct = totalWeight > 0 ? expectedTotalWeight * 100.0 / totalWeight : 0.0
    float failPct = totalWeight > 0 ? failTotalWeight * 100.0 / totalWeight : 0.0
    float oppositePct = totalWeight > 0 ? oppositeTotalWeight * 100.0 / totalWeight : 0.0
    int tagX1 = profileRightX + 2
    int tagX2 = profileRightX + 42
    float tagH = math.max((frameTop - frameBot) * 0.028, syminfo.mintick * 20.0)
    float expTagY = c + bcSpan * ((1.0 + ratioMax) / 2.0)
    float failTagY = c + bcSpan * 0.5
    float oppTagY = c - bcSpan * (ratioMax / 2.0)
    string oppTagText = "C Break  " + str.tostring(oppositePct, "#.#") + "%"
    string failTagText = "No Break  " + str.tostring(failPct, "#.#") + "%"
    string expTagText = "B Break  " + str.tostring(expectedPct, "#.#") + "%"
    line oppLead = line.new(profileRightX, oppTagY, tagX1, oppTagY, xloc = xloc.bar_index, color = color.new(setupColor, 12), style = line.style_dashed, width = 1)
    line failLead = line.new(profileRightX, failTagY, tagX1, failTagY, xloc = xloc.bar_index, color = color.new(setupColor, 12), style = line.style_dashed, width = 1)
    line expLead = line.new(profileRightX, expTagY, tagX1, expTagY, xloc = xloc.bar_index, color = color.new(setupColor, 12), style = line.style_dashed, width = 1)
    color cBreakTextColor = dirNow == 1 ? #1E88E5 : #FF1744
    color noBreakTextColor = #FFC400
    color bBreakTextColor = dirNow == 1 ? #FF1744 : #1E88E5
    box oppTag = box.new(tagX1, oppTagY + tagH, tagX2, oppTagY - tagH, xloc = xloc.bar_index, bgcolor = color.new(setupColor, 90), border_color = color.new(setupColor, 5), border_width = 1, text = oppTagText, text_color = cBreakTextColor, text_size = size.normal, text_halign = text.align_center, text_valign = text.align_center)
    box failTag = box.new(tagX1, failTagY + tagH, tagX2, failTagY - tagH, xloc = xloc.bar_index, bgcolor = color.new(setupColor, 90), border_color = color.new(setupColor, 5), border_width = 1, text = failTagText, text_color = noBreakTextColor, text_size = size.normal, text_halign = text.align_center, text_valign = text.align_center)
    box expTag = box.new(tagX1, expTagY + tagH, tagX2, expTagY - tagH, xloc = xloc.bar_index, bgcolor = color.new(setupColor, 90), border_color = color.new(setupColor, 5), border_width = 1, text = expTagText, text_color = bBreakTextColor, text_size = size.normal, text_halign = text.align_center, text_valign = text.align_center)
    array.push(lines, oppLead)
    array.push(lines, failLead)
    array.push(lines, expLead)
    array.push(boxes, oppTag)
    array.push(boxes, failTag)
    array.push(boxes, expTag)

    int breakBar = na
    float breakClose = na
    int scanBars = math.min(bar_index - cBar, 5000)
    if scanBars > 0
        for j = 0 to scanBars
            int off = scanBars - j
            bool isAfterC = bar_index - off > cBar
            bool isCloseBreak = dirNow == 1 ? close[off] >= b : close[off] <= b
            if na(breakBar) and isAfterC and isCloseBreak
                breakBar := bar_index - off
                breakClose := close[off]
    if not na(breakBar)
        float brTail = math.max(abNow * 0.20, atrNow * 2.50)
        float brLabelY = breakClose - dirNow * brTail
        line brLine = line.new(bBar, b, bar_index, b, xloc = xloc.bar_index, color = color.new(bBreakColor, 12), style = line.style_dashed, width = 1)
        line brStem = line.new(breakBar, breakClose, breakBar, brLabelY, xloc = xloc.bar_index, color = color.new(bBreakColor, 12), width = 1)
        label brLabel = label.new(breakBar, brLabelY, "B Break", xloc = xloc.bar_index, style = dirNow == 1 ? label.style_label_up : label.style_label_down, textcolor = color.white, color = color.new(bBreakColor, 0), size = size.small)
        array.push(lines, brLine)
        array.push(lines, brStem)
        array.push(labels, brLabel)

    label la = label.new(aBar, a, "A", xloc = xloc.bar_index, style = dirNow == 1 ? label.style_label_up : label.style_label_down, textcolor = color.white, color = color.new(setupColor, 0), size = size.small)
    label lbp = label.new(bBar, b, "B", xloc = xloc.bar_index, style = dirNow == 1 ? label.style_label_down : label.style_label_up, textcolor = color.white, color = color.new(setupColor, 0), size = size.small)
    string bcPathType = f_path_type(rNow)
    string exactRetraceText = str.tostring(rNow * 100.0, "#.#") + "% " + bcPathType
    string retraceText = bcPathType + " / " + f_fib_zone_range(rNow)
    float liveProgNow = f_live_progress(b, c, dirNow)
    string liveText = str.tostring(liveProgNow * 100.0, "#.#") + "%"
    label pat = label.new(cBar, c, "C\n" + exactRetraceText, xloc = xloc.bar_index, style = dirNow == 1 ? label.style_label_up : label.style_label_down, textcolor = color.white, color = setupColor, size = size.small)
    array.push(labels, la)
    array.push(labels, lbp)
    array.push(labels, pat)

    if showDashboard
        color dashBg = color.new(chart.bg_color, 8)
        color headBg = color.new(setupColor, 15)
        color dashLineColor = dirNow == 1 ? #6CDFCD : #FF8A8A
        table.set_border_color(dash, color.new(dashLineColor, 0))
        table.set_frame_color(dash, color.new(setupColor, 0))
        table.cell(dash, 0, 0, "SETUP", text_color = color.white, bgcolor = headBg, width = 8)
        table.cell(dash, 1, 0, dirNow == 1 ? "BULLISH ABC" : "BEARISH ABC", text_color = color.white, bgcolor = headBg, width = 17)
        table.cell(dash, 0, 1, "B→C", text_color = color.new(chart.fg_color, 18), bgcolor = dashBg, width = 8)
        table.cell(dash, 1, 1, retraceText, text_color = chart.fg_color, bgcolor = dashBg, width = 17)
        table.cell(dash, 0, 2, "C→Now", text_color = color.new(chart.fg_color, 18), bgcolor = dashBg, width = 8)
        table.cell(dash, 1, 2, liveText, text_color = chart.fg_color, bgcolor = dashBg, width = 17)
        table.cell(dash, 0, 3, "Matches", text_color = color.new(chart.fg_color, 18), bgcolor = dashBg, width = 8)
        table.cell(dash, 1, 3, str.tostring(totalCount), text_color = chart.fg_color, bgcolor = dashBg, width = 17)
        table.cell(dash, 0, 4, "Weight", text_color = color.new(chart.fg_color, 18), bgcolor = dashBg, width = 8)
        table.cell(dash, 1, 4, useRecencyWeight ? "Recent" : "Equal", text_color = chart.fg_color, bgcolor = dashBg, width = 17)
else if barstate.islast
    f_clear_drawings()
````
