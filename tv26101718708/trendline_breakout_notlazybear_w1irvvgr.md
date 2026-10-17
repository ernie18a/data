# Trendline Breakout - [NotLazyBear]

- url: https://www.tradingview.com/script/W1Irvvgr-Trendline-Breakout-NotLazyBear/
- type: indicator
- pine_id: PUB;8751664f93db41569931e1f1c1a0bbbd
- version: 3.0

## Description

[b]Overextension Trendline Breakout[/b]
[i]A multi-pivot trendline detection and breakout system that automatically draws validated support and resistance lines from looped zigzag pivots, confirms trendline integrity through clean-line scanning, and projects Fibonacci extension targets upon breakout. Uses ATR-normalized angle validation and touch-density scoring to distinguish meaningful trendlines from noise.[/i]
[b]What It Does[/b]
OETB scans price action across a configurable range of pivot lengths (default 5–30 bars) to build a pool of swing highs and lows. It then attempts to fit trendlines through these pivots using three validation layers:
[list]
[*][b]Angle Validation[/b]: Trendlines must fall within a specified angular range (default 15°–60°) relative to ATR-scaled horizontal distance, preventing flat or near-vertical lines.
[*][b]Touch Density[/b]: Lines must connect at least 3 (configurable) pivot points within ATR tolerance, ensuring the trendline is genuinely respected by price.
[*][b]Clean-Line Scan[/b]: No intermediate bar may violate the trendline by more than ATR tolerance — confirming the line acted as active support/resistance between its defining pivots.
[/list]
When a validated trendline is broken by price (with optional ATR buffer and close confirmation), the system plots breakout markers and projects four Fibonacci targets based on the swing amplitude of the broken trendline.
[b]Core Components[/b]
[list]
[*][b]Looped Pivot Detection[/b]: Iterates through minPivLen to maxPivLen simultaneously, collecting highs and lows across multiple time scales. Duplicate bars are resolved by keeping the largest pivot length (most significant swing).
[*][b]ATR-Scaled Angle Calculation[/b]: Uses a custom arctangent implementation with ATR normalization to measure trendline steepness in degrees. The X-axis is scaled by (dx/10) × ATR, making angle measurement consistent across volatile and calm markets.
[*][b]Touch Scoring with Tiebreaking[/b]: When multiple candidate lines exist, selects the one with most touches; ties broken by longer span (more significant trendline).
[*][b]Forming vs Confirmed Lines[/b]: Lines with 2+ touches but below minTouches are tracked as "forming" (dashed, faded) until they gather enough evidence to become confirmed.
[*][b]Breakout with Fibonacci Projection[/b]: Upon break, draws 0.618, 1.0, 1.618, and 2.618 extension targets from the breakout point, colored by aggressiveness (green conservative to pink aggressive).
[*][b]Age-Based Expiration[/b]: Lines older than maxAge bars (default 200) are marked expired (dotted grey) if unbroken, preventing stale trendlines from cluttering the chart.
[/list]
[b]Inputs & Parameters[/b]
[i]Zigzag Pivots[/i]
[list]
[*]Minimum/Maximum Pivot Length: Range of bar lengths for pivot detection (2–1000, default 5/30).
[*]ATR Length: Volatility measurement for normalization (default 14).
[*]ATR Deviation Filter: Toggle requiring minimum ATR distance between consecutive same-type pivots to prevent clustering.
[*]Minimum Pivots to Connect: Touch threshold for confirmed trendlines (2–10, default 3).
[/list]
[i]Trendline Validation[/i]
[list]
[*]Minimum/Maximum Angle: Steepness bounds in degrees (0°–89°/1°–90°, default 15°/60°). Filters out horizontal noise and near-vertical spikes.
[*]Max Pivot-to-Pivot Span: Maximum bar distance between connected pivots (10–200, default 100).
[*]Clean-Line Tolerance: ATR multiplier for how far price may deviate from the line between pivots (default 0.06× ATR).
[*]Validate Through Current Bar: Extends clean-line check from last pivot to present bar, ensuring ongoing respect.
[/list]
[i]Breakout Logic[/i]
[list]
[*]Break Requires Close Beyond Line: If true, breakout requires close; if false, wick penetration suffices (faster, more false positives).
[*]Break Buffer: ATR multiplier added beyond the line before break registers (default 0.08× ATR).
[*]Max Line Age: Bars before unbroken lines expire (default 200).
[/list]
[i]Fibonacci Targets[/i]
[list]
[*]Target ratios: 0.618 (conservative), 1.0 (equal move), 1.618 (golden), 2.618 (aggressive) — all configurable.
[*]Target Extension: Bars forward to draw target lines (default 5).
[*]Individual color selection per target level.
[/list]
[i]Display[/i]
[list]
[*]Toggle confirmed lines, forming lines, and breakout markers.
[*]Color selectors for ascending support (cyan), descending resistance (orange), forming variants (faded), broken (grey), and expired (light grey).
[*]Line width adjustment (1–4).
[/list]
[b]How to Read It[/b]
[list]
[*][b]Solid Cyan Lines:[/b] Confirmed ascending support — at least 3 lows touched the line within tolerance. Price expected to bounce; break signals bearish acceleration.
[*][b]Solid Orange Lines:[/b] Confirmed descending resistance — at least 3 highs touched the line. Price expected to reject; break signals bullish breakout.
[*][b]Dashed Faded Lines:[/b] Forming trendlines with 2 touches but not yet confirmed. Monitor for additional touches that would validate.
[*][b]Dashed Grey Lines:[/b] Broken trendlines — price has crossed through with buffer confirmation. Fib targets are active.
[*][b]Dotted Light Grey Lines:[/b] Expired trendlines — exceeded maxAge without breakout, no longer relevant.
[*][b]Breakout Markers:[/b]
[list]
[*]Green ▲ below bar: Descending resistance broken upward — bullish breakout.
[*]Red ▼ above bar: Ascending support broken downward — bearish breakdown.
[/list]
[*][b]Fibonacci Target Labels:[/b] "T1 (0.618)" in green, "T2 (1.000)" in blue, "T3 (1.618)" in orange, "T4 (2.618)" in pink — projected horizontally from breakout point.
[/list]
[b]Practical Usage Guidelines[/b]
[i]Trend Continuation Trading[/i]
[list]
[*]Enter long when price bounces off a confirmed cyan support line with rising volume.
[*]Enter short when price rejects a confirmed orange resistance line with rising volume.
[*]Stop-loss placed beyond the trendline by 1× ATR.
[/list]
[i]Breakout Trading[/i]
[list]
[*]Wait for close beyond the trendline plus buffer (not just wick).
[*]Confirm with volume expansion if available.
[*]Target T1 (0.618) for conservative profit; scale out at T2 (1.0); trail remaining to T3/T4.
[*]If price reverses back through the broken trendline within 3 bars, the break is likely false — exit immediately.
[/list]
[i]Forming Line Anticipation[/i]
[list]
[*]When a dashed forming line appears, watch for the next touch. A third touch that holds validates the line and often provides a high-probability entry.
[*]If price violates a forming line before it reaches minTouches, the line is invalidated and removed.
[/list]
[b]Important Notes[/b]
[list]
[*][b]Custom Arctangent Implementation:[/b] The script includes a manual f_atan function using Taylor series expansion (12 terms) to avoid dependency on built-in math.atan, with f_atan2 handling all quadrants. This ensures consistent angle calculation across Pine versions.
[*][b]Angle Normalization:[/b] The X-axis in angle calculation is normalized by (dx/10) × ATR, meaning a 10-bar move equal to 1 ATR produces a 45° angle reference. This makes angle thresholds market-adaptive.
[*][b]Duplicate Resolution:[/b] When the same bar is detected as a pivot across multiple lengths, the system keeps the longest length (most significant swing) rather than creating duplicate entries.
[*][b]Clean-Line Scan Performance:[/b] The validation iterates every bar between pivots and optionally to current bar. On very long spans (>100 bars) this is computationally intensive; reduce maxSpan or disable checkToNow for faster performance.
[*][b]Forming Line Cleanup:[/b] Forming lines are not automatically removed when their underlying pivots age out — they expire via maxAge only. Confirmed lines are removed immediately on break or expiration.
[*][b]Break Buffer Purpose:[/b] The 0.08× ATR buffer prevents false breaks from single-tick wicks. In high-volatility markets, increase buffer; in low-volatility, decrease or set to 0 for tighter triggers.
[*][b]No Repainting:[/b] Pivots use standard ta.pivothigh/ta.pivotlow with symmetric right bars (pLen). Breakout detection uses confirmed close when breakOnClose is enabled. All line objects are historical and do not shift retrospectively.
[*][b]Target Line Persistence:[/b] Fib target lines extend only fibExtBars forward (default 5) and are not automatically extended. They persist as static historical objects.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NotLazyBear

//@version=6

indicator("Overextension Trendline Breakout",
     "OETB v3.3", overlay=true,
     max_lines_count=500, max_labels_count=500, max_bars_back=2000)

// ─── INPUTS ────────────────────────────────────────────────────────────────
gZ  = "◆ Zigzag Pivots"
gT  = "◆ Trendline Validation"
gB  = "◆ Breakout Logic"
gF  = "◆ Fibonacci Targets"
gD  = "◆ Display"

minPivLen   = input.int(5,   "Minimum Pivot Length", minval=2, maxval=1000, group=gZ)
maxPivLen   = input.int(30,  "Maximum Pivot Length", minval=2, maxval=1000, group=gZ)
atrLen      = input.int(14,  "ATR Length", minval=2, group=gZ)
useDevFlt   = input.bool(false, "ATR Deviation Filter", group=gZ)
minDevATR   = input.float(1.0, "Min Pivot ΔATR", step=0.1, group=gZ)

minTouches  = input.int(3,   "Minimum Pivots to Connect", minval=2, maxval=10, group=gZ)

minAngle    = input.float(15.0, "Minimum Angle (°)", minval=0.0, maxval=89.0, step=1.0, group=gT)
maxAngle    = input.float(60.0, "Maximum Angle (°)", minval=1.0, maxval=90.0, step=1.0, group=gT)
maxSpan     = input.int(100,  "Max Pivot-to-Pivot Span", minval=10, maxval=200, group=gT)
cleanTolATR = input.float(0.06, "Clean-Line Tolerance (× ATR)", step=0.01, group=gT)
checkToNow  = input.bool(true, "Validate Through Current Bar", group=gT)

breakOnClose = input.bool(true, "Break Requires Close Beyond Line", group=gB)
bufferATR    = input.float(0.08, "Break Buffer (× ATR)", step=0.05, group=gB)
maxAge       = input.int(200,  "Max Line Age Before Expire", group=gB)

// ─── FIBONACCI TARGET INPUTS ───────────────────────────────────────────────
showFib     = input.bool(true, "Show Fibonacci Targets", group=gF)
fib1        = input.float(0.618, "Target 1 (Conservative)", step=0.001, group=gF)
fib2        = input.float(1.000, "Target 2 (Equal Move)",   step=0.001, group=gF)
fib3        = input.float(1.618, "Target 3 (Golden)",       step=0.001, group=gF)
fib4        = input.float(2.618, "Target 4 (Aggressive)",   step=0.001, group=gF)
fibExtBars  = input.int(5,     "Target Extension (bars)", minval=1, maxval=50, group=gF)
colFib1     = input.color(color.new(#00e676, 0),  "Target 1 Color", group=gF)
colFib2     = input.color(color.new(#2979ff, 0),  "Target 2 Color", group=gF)
colFib3     = input.color(color.new(#ff9100, 0),  "Target 3 Color", group=gF)
colFib4     = input.color(color.new(#f50057, 0),  "Target 4 Color", group=gF)

// ─── DISPLAY INPUTS ──────────────────────────────────────────────────────────
showLines   = input.bool(true,  "Show Confirmed Trendlines", group=gD)
showForming = input.bool(false,  "Show Forming Trendlines",   group=gD,
                 tooltip="Only visible when Minimum Pivots > 2. Shows lines with 2+ touches but not yet confirmed.")
showSig     = input.bool(true,  "Show Breakout Markers",     group=gD)
colSup      = input.color(color.new(#00bcd4, 0), "Ascending Support",     group=gD)
colRes      = input.color(color.new(#ff9800, 0), "Descending Resistance", group=gD)
colFormSup  = input.color(color.new(#00bcd4, 70), "Forming Support",     group=gD)
colFormRes  = input.color(color.new(#ff9800, 70), "Forming Resistance",  group=gD)
colBroken   = input.color(color.new(color.gray, 40), "Broken",  group=gD)
colExpired  = input.color(color.new(color.gray, 80), "Expired", group=gD)
lineWidth   = input.int(2, "Line Width", minval=1, maxval=4, group=gD)

// ─── BASELINE ─────────────────────────────────────────────────────────────
float atr = ta.atr(atrLen)
float EPS = 1e-12
float angleMin = math.min(minAngle, maxAngle)
float angleMax = math.max(minAngle, maxAngle)


f_atan(float x) =>
    float a = math.abs(x)
    bool doInv = a > 1.0
    a := doInv ? 1.0 / a : a
    float a2 = a * a
    float p = a
    float sum = 0.0
    for i = 0 to 11
        float sign = i % 2 == 0 ? 1.0 : -1.0
        float denom = 2.0 * float(i) + 1.0
        sum += sign * p / denom
        p *= a2
    float result = doInv ? math.pi / 2.0 - sum : sum
    x < 0.0 ? -result : result

f_atan2(float y, float x) =>
    if x > EPS
        f_atan(y / x)
    else if x < -EPS
        y >= 0.0 ? f_atan(y / x) + math.pi : f_atan(y / x) - math.pi
    else
        y > EPS ? math.pi / 2.0 : y < -EPS ? -math.pi / 2.0 : 0.0


f_pivot_angle(float p1, float p2, int b1, int b2, float atr_val) =>
    float dy = p2 - p1
    int   dx_raw = b2 - b1
    float dx = dx_raw > 0 ? float(dx_raw) : 0.0
    float atr_safe = atr_val > EPS ? atr_val : EPS
    float x_norm = (dx / 10.0) * atr_safe
    float x_safe = x_norm > EPS ? x_norm : EPS
    float rad = f_atan2(dy, x_safe)
    rad * 180.0 / math.pi

f_pivot_angle_abs(float p1, float p2, int b1, int b2, float atr_val) =>
    math.abs(f_pivot_angle(p1, p2, b1, b2, atr_val))

f_angle_in_range(float p1, float p2, int b1, int b2, float atr_val, float aMin, float aMax) =>
    float absDeg = f_pivot_angle_abs(p1, p2, b1, b2, atr_val)
    absDeg >= aMin and absDeg <= aMax


int MAX_POOL = 40
var float[] plPrices = array.new_float(0)
var int[]   plBars   = array.new_int(0)
var int[]   plLens   = array.new_int(0)
var float[] phPrices = array.new_float(0)
var int[]   phBars   = array.new_int(0)
var int[]   phLens   = array.new_int(0)

bool phUpd = false
bool plUpd = false

// ─── LOOPED PIVOT DETECTION ────────────────────────────────────────────────
int effectiveMax = math.max(minPivLen, maxPivLen)
int effectiveMin = math.min(minPivLen, maxPivLen)

for pLen = effectiveMin to effectiveMax
    float rawPH = ta.pivothigh(high, pLen, pLen)
    float rawPL = ta.pivotlow(low,  pLen, pLen)

    // ── Pivot Highs ──
    if not na(rawPH)
        int barAbs = bar_index - pLen
        bool dup = false
        int dupIdx = -1
        if array.size(phBars) > 0
            int sz = array.size(phBars)
            for k = 0 to sz - 1
                if array.get(phBars, k) == barAbs
                    dup := true
                    dupIdx := k
                    break
        if dup
            if array.size(phLens) > 0 and dupIdx >= 0 and dupIdx < array.size(phLens)
                if pLen > array.get(phLens, dupIdx)
                    array.set(phLens, dupIdx, pLen)
        else
            bool pass = true
            if useDevFlt and array.size(phPrices) > 0
                pass := math.abs(rawPH - array.get(phPrices, 0)) >= minDevATR * atr
            if pass
                array.unshift(phPrices, rawPH)
                array.unshift(phBars, barAbs)
                array.unshift(phLens, pLen)
                if array.size(phPrices) > MAX_POOL
                    array.pop(phPrices)
                    array.pop(phBars)
                    array.pop(phLens)
                phUpd := true

    // ── Pivot Lows ──
    if not na(rawPL)
        int barAbs = bar_index - pLen
        bool dup = false
        int dupIdx = -1
        if array.size(plBars) > 0
            int sz = array.size(plBars)
            for k = 0 to sz - 1
                if array.get(plBars, k) == barAbs
                    dup := true
                    dupIdx := k
                    break
        if dup
            if array.size(plLens) > 0 and dupIdx >= 0 and dupIdx < array.size(plLens)
                if pLen > array.get(plLens, dupIdx)
                    array.set(plLens, dupIdx, pLen)
        else
            bool pass = true
            if useDevFlt and array.size(plPrices) > 0
                pass := math.abs(rawPL - array.get(plPrices, 0)) >= minDevATR * atr
            if pass
                array.unshift(plPrices, rawPL)
                array.unshift(plBars, barAbs)
                array.unshift(plLens, pLen)
                if array.size(plPrices) > MAX_POOL
                    array.pop(plPrices)
                    array.pop(plBars)
                    array.pop(plLens)
                plUpd := true


f_cleanLine(int x1, int x2, float y1, float y2, int xEnd, bool isSup, float tol) =>
    bool ok = true
    int span = x2 - x1
    if span > 1
        float m = (y2 - y1) / span
        for k = 1 to span - 1
            int b = x1 + k
            int back = bar_index - b
            if back >= 0 and back < 5000
                float yP = y1 + m * k
                if isSup
                    if low[back] < yP - tol
                        ok := false
                        break
                else
                    if high[back] > yP + tol
                        ok := false
                        break
        if ok and checkToNow
            int ext = xEnd - x2
            for k = 1 to ext
                int b = x2 + k
                int back = bar_index - b
                if back >= 0 and back < 5000
                    float yP = y2 + m * k
                    if isSup
                        if low[back] < yP - tol
                            ok := false
                            break
                    else
                        if high[back] > yP + tol
                            ok := false
                            break
    ok

// ─── ACTIVE-LINE TYPES ───────────────────────────────────────────────────
type TL
    line  ln
    float m
    float b0
    int   x1
    int   x2
    bool  isSup
    int   len1
    int   len2
    float ang
    float p1
    float p2

var array<TL> active   = array.new<TL>()
var array<TL> forming  = array.new<TL>()

// ─── HELPER: DRAW FIB TARGETS (5-bar fixed extension, persistent) ────────
f_draw_fib(float breakPrice, float pOld, float pNew, bool isSup, int breakBar) =>
    if showFib
        float swing = math.abs(pNew - pOld)
        if swing >= EPS
            float dir = isSup ? -1.0 : 1.0
            float[] ratios = array.from(fib1, fib2, fib3, fib4)
            color[] cols   = array.from(colFib1, colFib2, colFib3, colFib4)
            string[] names = array.from("0.618", "1.000", "1.618", "2.618")
            int rCount = array.size(ratios)
            for ri = 0 to rCount - 1
                if ri < array.size(cols) and ri < array.size(names)
                    float r = array.get(ratios, ri)
                    float tgt = breakPrice + dir * swing * r
                    line tl = line.new(breakBar, tgt, breakBar + fibExtBars, tgt,
                         xloc=xloc.bar_index, extend=extend.none,
                         color=array.get(cols, ri), style=line.style_solid, width=1)
                    label tlbl = label.new(breakBar, tgt,
                         "T" + str.tostring(ri + 1) + " (" + array.get(names, ri) + ")",
                         color=color.new(array.get(cols, ri), 70),
                         textcolor=array.get(cols, ri),
                         style=label.style_label_left, size=size.tiny)
    0


if showLines and plUpd and array.size(plPrices) >= minTouches and array.size(plBars) > 0 and array.size(plLens) > 0
    float tol = cleanTolATR * atr
    float pNew = array.get(plPrices, 0)
    int   bNew = array.get(plBars, 0)
    int   lenNew = array.get(plLens, 0)
    int   bestJ     = -1
    float bestM     = 0.0
    float bestB0    = 0.0
    int   bestTouch = 0

    int sz = array.size(plPrices)
    for j = 1 to sz - 1
        if array.size(plPrices) <= j or array.size(plBars) <= j
            continue
        float pOld = array.get(plPrices, j)
        int   bOld = array.get(plBars, j)
        int   dx   = bNew - bOld
        if dx <= 0 or dx > maxSpan
            continue
        if pNew <= pOld
            continue
        if not f_angle_in_range(pOld, pNew, bOld, bNew, atr, angleMin, angleMax)
            continue
        float m  = (pNew - pOld) / dx
        float b0 = pNew - m * bNew
        int touches = 0
        for k = 0 to sz - 1
            if array.size(plBars) <= k or array.size(plPrices) <= k
                continue
            int bK = array.get(plBars, k)
            if bK < bOld or bK > bNew
                continue
            float pK = array.get(plPrices, k)
            float projected = m * bK + b0
            if math.abs(pK - projected) <= tol
                touches += 1
        if touches >= minTouches
            if f_cleanLine(bOld, bNew, pOld, pNew, bar_index, true, tol)
                int bestDx = bestJ != -1 and array.size(plBars) > bestJ ? bNew - array.get(plBars, bestJ) : 0
                if touches > bestTouch or (touches == bestTouch and dx > bestDx)
                    bestJ     := j
                    bestM     := m
                    bestB0    := b0
                    bestTouch := touches

    if bestJ != -1 and array.size(plPrices) > bestJ and array.size(plBars) > bestJ and array.size(plLens) > bestJ
        float pOld = array.get(plPrices, bestJ)
        int   bOld = array.get(plBars, bestJ)
        int   lenOld = array.get(plLens, bestJ)
        float lineAng = f_pivot_angle_abs(pOld, pNew, bOld, bNew, atr)
        line nl = line.new(bOld, pOld, bNew, pNew, xloc=xloc.bar_index,
             extend=extend.right, color=colSup, width=lineWidth)
        array.push(active, TL.new(nl, bestM, bestB0, bOld, bNew, true, lenOld, lenNew, lineAng, pOld, pNew))


if showForming and minTouches > 2 and plUpd and array.size(plPrices) >= 2 and array.size(plBars) > 0 and array.size(plLens) > 0
    float tol = cleanTolATR * atr
    float pNew = array.get(plPrices, 0)
    int   bNew = array.get(plBars, 0)
    int sz = array.size(plPrices)
    for j = 1 to sz - 1
        if array.size(plPrices) <= j or array.size(plBars) <= j
            continue
        float pOld = array.get(plPrices, j)
        int   bOld = array.get(plBars, j)
        int   dx   = bNew - bOld
        if dx <= 0 or dx > maxSpan
            continue
        if pNew <= pOld
            continue
        if not f_angle_in_range(pOld, pNew, bOld, bNew, atr, angleMin, angleMax)
            continue
        float m  = (pNew - pOld) / dx
        float b0 = pNew - m * bNew
        int touches = 0
        for k = 0 to sz - 1
            if array.size(plBars) <= k or array.size(plPrices) <= k
                continue
            int bK = array.get(plBars, k)
            if bK < bOld or bK > bNew
                continue
            float pK = array.get(plPrices, k)
            float projected = m * bK + b0
            if math.abs(pK - projected) <= tol
                touches += 1
        if touches >= 2 and touches < minTouches
            bool already = false
            int fSz = array.size(forming)
            for fi = 0 to fSz - 1
                if array.size(forming) > 1
                    TL ft = array.get(forming, fi)
                    if ft.x1 == bOld and ft.x2 == bNew and ft.isSup
                        already := true
                        break
            if not already
                line fl = line.new(bOld, pOld, bNew, pNew, xloc=xloc.bar_index,
                     extend=extend.right, color=colFormSup, width=1, style=line.style_dashed)
                array.push(forming, TL.new(fl, m, b0, bOld, bNew, true, 0, 0, 0.0, pOld, pNew))


if showLines and phUpd and array.size(phPrices) >= minTouches and array.size(phBars) > 0 and array.size(phLens) > 0
    float tol = cleanTolATR * atr
    float pNew = array.get(phPrices, 0)
    int   bNew = array.get(phBars, 0)
    int   lenNew = array.get(phLens, 0)
    int   bestJ     = -1
    float bestM     = 0.0
    float bestB0    = 0.0
    int   bestTouch = 0

    int sz = array.size(phPrices)
    for j = 1 to sz - 1
        if array.size(phPrices) <= j or array.size(phBars) <= j
            continue
        float pOld = array.get(phPrices, j)
        int   bOld = array.get(phBars, j)
        int   dx   = bNew - bOld
        if dx <= 0 or dx > maxSpan
            continue
        if pNew >= pOld
            continue
        if not f_angle_in_range(pOld, pNew, bOld, bNew, atr, angleMin, angleMax)
            continue
        float m  = (pNew - pOld) / dx
        float b0 = pNew - m * bNew
        int touches = 0
        for k = 0 to sz - 1
            if array.size(phBars) <= k or array.size(phPrices) <= k
                continue
            int bK = array.get(phBars, k)
            if bK < bOld or bK > bNew
                continue
            float pK = array.get(phPrices, k)
            float projected = m * bK + b0
            if math.abs(pK - projected) <= tol
                touches += 1
        if touches >= minTouches
            if f_cleanLine(bOld, bNew, pOld, pNew, bar_index, false, tol)
                int bestDx = bestJ != -1 and array.size(phBars) > bestJ ? bNew - array.get(phBars, bestJ) : 0
                if touches > bestTouch or (touches == bestTouch and dx > bestDx)
                    bestJ     := j
                    bestM     := m
                    bestB0    := b0
                    bestTouch := touches

    if bestJ != -1 and array.size(phPrices) > bestJ and array.size(phBars) > bestJ and array.size(phLens) > bestJ
        float pOld = array.get(phPrices, bestJ)
        int   bOld = array.get(phBars, bestJ)
        int   lenOld = array.get(phLens, bestJ)
        float lineAng = f_pivot_angle_abs(pOld, pNew, bOld, bNew, atr)
        line nl = line.new(bOld, pOld, bNew, pNew, xloc=xloc.bar_index,
             extend=extend.right, color=colRes, width=lineWidth)
        array.push(active, TL.new(nl, bestM, bestB0, bOld, bNew, false, lenOld, lenNew, lineAng, pOld, pNew))


if showForming and minTouches > 2 and phUpd and array.size(phPrices) >= 2 and array.size(phBars) > 0 and array.size(phLens) > 0
    float tol = cleanTolATR * atr
    float pNew = array.get(phPrices, 0)
    int   bNew = array.get(phBars, 0)
    int sz = array.size(phPrices)
    for j = 1 to sz - 1
        if array.size(phPrices) <= j or array.size(phBars) <= j
            continue
        float pOld = array.get(phPrices, j)
        int   bOld = array.get(phBars, j)
        int   dx   = bNew - bOld
        if dx <= 0 or dx > maxSpan
            continue
        if pNew >= pOld
            continue
        if not f_angle_in_range(pOld, pNew, bOld, bNew, atr, angleMin, angleMax)
            continue
        float m  = (pNew - pOld) / dx
        float b0 = pNew - m * bNew
        int touches = 0
        for k = 0 to sz - 1
            if array.size(phBars) <= k or array.size(phPrices) <= k
                continue
            int bK = array.get(phBars, k)
            if bK < bOld or bK > bNew
                continue
            float pK = array.get(phPrices, k)
            float projected = m * bK + b0
            if math.abs(pK - projected) <= tol
                touches += 1
        if touches >= 2 and touches < minTouches
            bool already = false
            int fSz = array.size(forming)
            for fi = 0 to fSz - 1
                if array.size(forming) > fi
                    TL ft = array.get(forming, fi)
                    if ft.x1 == bOld and ft.x2 == bNew and not ft.isSup
                        already := true
                        break
            if not already
                line fl = line.new(bOld, pOld, bNew, pNew, xloc=xloc.bar_index,
                     extend=extend.right, color=colFormRes, width=1, style=line.style_dashed)
                array.push(forming, TL.new(fl, m, b0, bOld, bNew, false, 0, 0, 0.0, pOld, pNew))

// ─── CLEANUP FORMING LINES ─────────────────────────────────────────────────
if array.size(forming) > 0
    int fi = array.size(forming) - 1
    while fi >= 0
        if array.size(forming) > fi
            TL ft = array.get(forming, fi)
            int age = bar_index - ft.x2
            if age > maxAge
                line.delete(ft.ln)
                array.remove(forming, fi)
        fi -= 1

// ─── BREAK / FREEZE / EXPIRE / FIB TARGETS ─────────────────────────────────
bool brkLong  = false
bool brkShort = false

if array.size(active) > 0
    float buf = bufferATR * atr
    int i = array.size(active) - 1
    while i >= 0
        if array.size(active) > i
            TL t = array.get(active, i)
            float yP   = t.m * bar_index + t.b0
            float pBr  = breakOnClose ? close : (t.isSup ? low : high)
            bool broken = t.isSup ? (pBr < yP - buf) : (pBr > yP + buf)
            int age = bar_index - t.x2
            bool expired = not broken and age > maxAge
            if broken
                line.set_extend(t.ln, extend.none)
                line.set_xy2(t.ln, bar_index, yP)
                line.set_color(t.ln, colBroken)
                line.set_style(t.ln, line.style_dashed)
                f_draw_fib(yP, t.p1, t.p2, t.isSup, bar_index)
                if t.isSup
                    brkShort := true
                else
                    brkLong  := true
                if showSig
                    string mk = t.isSup ? "▼" : "▲"
                    color  cc = t.isSup ? color.new(color.red, 15) : color.new(color.green, 15)
                    float  yy = t.isSup ? high + atr*0.3 : low - atr*0.3
                    label.new(bar_index, yy, mk, color=cc, textcolor=color.white,
                         style = t.isSup ? label.style_label_down : label.style_label_up,
                         size=size.small)
                array.remove(active, i)
            else if expired
                line.set_extend(t.ln, extend.none)
                line.set_xy2(t.ln, bar_index, yP)
                line.set_color(t.ln, colExpired)
                line.set_style(t.ln, line.style_dotted)
                array.remove(active, i)
        i -= 1

// ─── SIGNAL PLOTS ────────────────────────────────────────────────────────
plotshape(brkLong  and showSig, "Long Break",  location=location.belowbar,
     color=color.new(color.green, 0), style=shape.triangleup,   size=size.small)
plotshape(brkShort and showSig, "Short Break", location=location.abovebar,
     color=color.new(color.red, 0),   style=shape.triangledown, size=size.small)

alertcondition(brkLong,  "OETB Long Break",
     "Descending resistance broken upward — Fib targets active")
alertcondition(brkShort, "OETB Short Break",
     "Ascending support broken downward — Fib targets active")
````
