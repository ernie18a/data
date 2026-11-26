# Pattern Structure Pro

- url: https://www.tradingview.com/script/k8GKqEKW-Pattern-Structure-Pro/
- type: indicator
- pine_id: PUB;5e3510caef304801a10393b48164a364
- version: 1.0

## Description

Pattern Structure Pro is an open-source chart overlay for patterns, market structure and price context.

It displays tops/bottoms, head-and-shoulders formations, triangles, wedges, flags, pennants, channels and rectangles. Additional layers include swing labels, BOS/CHoCH, a swing trendline, supply/demand zones, weekly/monthly reference levels and optional EMA 200. Up to three selected patterns are shown.

The engine compares pivot sequences and fitted boundaries using ATR-based tolerances. Pattern captions describe forming structures, boundary breaks or a return inside. Historical geometry appears after the required pivots have been detected. Recognition can miss formations or produce false positives.

Intended intervals: 1H, 2H, 4H and 1D. Patterns, structure and EMA use the chart interval. Zones use a shared 4H source by default; choose Chart for interval-specific zones.

Analysis is the default view, showing geometry, states and timing. Stories uses compact annotations and fewer context layers. All major layers can be toggled in settings.

Released under the MIT License. Everyone is welcome to inspect the source, suggest improvements and contribute. This is a chart-analysis tool, not a trade recommendation.

## Source Code

````pine
//@version=6
// SPDX-License-Identifier: MIT
// MIT License
//
// Copyright (c) 2026 builtbyuba
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

indicator("Pattern Structure Pro", "Pattern Structure Pro", overlay=true, max_bars_back=600, max_lines_count=150, max_boxes_count=30, max_labels_count=80, max_polylines_count=12)

// Automatic market-structure visualization. No forecasts, entries or targets.
string G_ENGINE = "Detection"
string G_PATTERNS = "Pattern families"
string G_STRUCT = "Market structure"
string G_CONTEXT = "Trend context"
string G_STYLE = "Presentation"
int swingStrength = input.int(3, "Confirmed swing strength", minval=2, maxval=10, group=G_ENGINE, tooltip="Closed bars required to the right of a pivot. Default 3: 3h on 1H, 6h on 2H, 12h on 4H, and 3 days on 1D. Geometry and ATR use the current chart interval.", display=display.none)
float equalTolerance = input.float(0.40, "Matching levels • ATR", minval=0.1, maxval=1.0, step=0.05, group=G_ENGINE, display=display.none)
float touchTolerance = input.float(0.35, "Boundary contact • ATR", minval=0.1, maxval=0.8, step=0.05, group=G_ENGINE, display=display.none)
float breakTolerance = input.float(0.15, "Closed-bar break • ATR", minval=0.05, maxval=0.5, step=0.05, group=G_ENGINE, display=display.none)
float minQuality = input.float(65, "Minimum geometric quality", minval=0, maxval=100, step=5, group=G_ENGINE, tooltip="A geometry filter, not a direction probability or trading score.", display=display.none)
bool showDouble = input.bool(true, "Double / Triple Top & Bottom", group=G_PATTERNS, display=display.none)
bool showShoulders = input.bool(true, "Head & Shoulders / Inverse", group=G_PATTERNS, display=display.none)
bool showTriangles = input.bool(true, "Triangles", group=G_PATTERNS, display=display.none)
bool showWedges = input.bool(true, "Wedges", group=G_PATTERNS, display=display.none)
bool showFlags = input.bool(true, "Flags / Pennants", group=G_PATTERNS, display=display.none)
bool showChannels = input.bool(true, "Channels / Rectangles", group=G_PATTERNS, display=display.none)
bool showSwings = input.bool(false, "HH / HL / LH / LL", group=G_STRUCT, display=display.none)
bool showBreaks = input.bool(true, "BOS / CHoCH", group=G_STRUCT, display=display.none)
bool showZones = input.bool(true, "Swing supply / demand zones", group=G_STRUCT, display=display.none)
string zoneSource = input.string("4H", "Zone source", options=["4H", "Chart"], group=G_STRUCT, display=display.none, tooltip="4H keeps confirmed supply/demand price boundaries consistent on 1H, 2H, 4H and 1D. Chart restores interval-specific zones. Patterns, structure and EMA always use the chart interval.")
bool showLevels = input.bool(true, "Week / month levels", group=G_STRUCT, display=display.none)
bool showTrendline = input.bool(true, "Confirmed swing trendline", group=G_STRUCT, display=display.none)
bool showEMA200 = input.bool(true, "EMA 200", group=G_CONTEXT, display=display.none, tooltip="200-period EMA of close on the chart interval. Shows closed candles only and shares the price chart. No signals or future extension.")
string viewMode = input.string("Analysis", "View", options=["Stories", "Analysis"], group=G_STYLE, display=display.none)
int storiesPatternLimit = input.int(3, "Patterns in Stories", minval=1, maxval=3, group=G_STYLE, display=display.none, tooltip="Up to three distinct structures. Use one for a minimal phone screenshot.")
string annotationStyle = input.string("Editorial", "Annotation style", options=["Editorial", "Technical"], group=G_STYLE, display=display.none, tooltip="Editorial uses historical reversal arches and compact names. Technical shows anchor geometry and full states.")
string palette = input.string("Auto", "Chart theme", options=["Auto", "Light", "Dark"], group=G_STYLE, display=display.none)
string textChoice = input.string("Normal", "Text size", options=["Small", "Normal", "Large"], group=G_STYLE, display=display.none)
int zoneTransparency = input.int(82, "Zone transparency", minval=65, maxval=95, group=G_STYLE, display=display.none)
int zoneExtension = input.int(30, "Zone / level extension • bars", minval=0, maxval=40, group=G_STYLE, display=display.none, tooltip="Extends existing horizontal zones and levels into the right margin. Match the chart right margin to about 35 bars. No projected price path.")
bool showBrand = input.bool(true, "Compact title", group=G_STYLE, display=display.none)

// Candle-based geometry and ATR adapt to the chart interval. Keep temporal
// context explicit without changing the established 4H detection thresholds.
f_timeframeContext(float seconds, int bars, string fallback) =>
    bool supported = not na(seconds) and (seconds == 3600 or seconds == 7200 or seconds == 14400 or seconds == 86400)
    string name = seconds == 3600 ? "1H" : seconds == 7200 ? "2H" : seconds == 14400 ? "4H" : seconds == 86400 ? "1D" : fallback
    string delay = supported ? (seconds == 86400 ? str.tostring(bars) + "d" : str.tostring(int(seconds / 3600) * bars) + "h") : str.tostring(bars) + " bars"
    [supported, name, delay]

[supportedInterval, intervalName, swingDelay] = f_timeframeContext(timeframe.in_seconds(), swingStrength, timeframe.period)

bool darkPalette = palette == "Dark" or (palette == "Auto" and color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color) < 384)
color ink = darkPalette ? color.rgb(219, 223, 225) : color.rgb(44, 47, 49)
color demandColor = color.rgb(103, 145, 113)
color supplyColor = color.rgb(166, 113, 116)
color neutralColor = color.rgb(129, 139, 151)
color emaColor = darkPalette ? color.rgb(143, 166, 183) : color.rgb(91, 119, 139)
string textSize = textChoice == "Small" ? size.small : textChoice == "Large" ? size.large : size.normal

type Swing
    int originIndex
    int originTime
    int detectedIndex
    float price
    bool isHigh
    float atr
    float candleOpen
    float candleClose
    float departure
    float context

type Pattern
    string id
    string kind
    int startIndex
    int endIndex
    int detectedIndex
    float atr
    float upperSlope
    float upperIntercept
    float lowerSlope
    float lowerIntercept
    float extremeHigh
    float extremeLow
    int expectedDirection
    string state
    int stateIndex
    float quality
    int contacts
    float apex
    bool returned
    array<int> anchorIndices
    array<float> anchorPrices

type Zone
    string id
    bool isDemand
    float top
    float bottom
    float atr
    int originIndex
    int detectedIndex
    bool touched
    bool valid

    int originTime = na

type ZoneSnapshot
    array<Zone> stored
    int sourceIndex
    float referencePrice
    float referenceATR
    int closedAt

type StructureEvent
    int originIndex
    int eventIndex
    float price
    string kind
    int direction

var array<Swing> swings = array.new<Swing>()
var array<Pattern> patterns = array.new<Pattern>()
var array<Zone> zones = array.new<Zone>()
var array<StructureEvent> events = array.new<StructureEvent>()
var array<line> drawLines = array.new<line>()
var array<box> drawBoxes = array.new<box>()
var array<label> drawLabels = array.new<label>()
var array<polyline> drawCurves = array.new<polyline>()

float currentATR = ta.atr(14)

f_boundary(float slope, float intercept, int x) =>
    slope * x + intercept

f_clamp(float value, float lo, float hi) =>
    math.max(lo, math.min(hi, value))

f_ingestSwing(array<Swing> stored, Swing item) =>
    bool changed = false
    if not na(item.atr) and item.atr > 0
        int n = array.size(stored)
        if n == 0
            array.push(stored, item)
            changed := true
        else
            Swing previous = array.get(stored, n - 1)
            if item.originIndex > previous.originIndex
                if previous.isHigh == item.isHigh
                    bool moreExtreme = item.isHigh ? item.price > previous.price : item.price < previous.price
                    if moreExtreme
                        array.set(stored, n - 1, item)
                        changed := true
                else
                    array.push(stored, item)
                    changed := true
        if array.size(stored) > 60
            array.shift(stored)
    changed

f_fitLine(array<Swing> points, bool highs) =>
    float sx = 0.0
    float sy = 0.0
    float sxx = 0.0
    float sxy = 0.0
    int n = 0
    int base = array.size(points) > 0 ? array.get(points, 0).originIndex : 0
    for p in points
        if p.isHigh == highs
            float x = p.originIndex - base
            sx += x
            sy += p.price
            sxx += x * x
            sxy += x * p.price
            n += 1
    float denominator = n * sxx - sx * sx
    float slope = n >= 2 and denominator > 0 ? (n * sxy - sx * sy) / denominator : na
    float intercept = n >= 2 and not na(slope) ? (sy - slope * sx) / n - slope * base : na
    float residual = 0.0
    if not na(slope)
        for p in points
            if p.isHigh == highs
                residual := math.max(residual, math.abs(p.price - f_boundary(slope, intercept, p.originIndex)))
    [slope, intercept, residual, n]

f_validateEnvelope(array<Swing> points, float um, float ub, float lm, float lb, float a) =>
    bool ok = array.size(points) >= 4 and not na(a) and a > 0 and not na(um) and not na(lm)
    int lastHigh = -1000000
    int lastLow = -1000000
    if ok
        for p in points
            float upper = f_boundary(um, ub, p.originIndex)
            float lower = f_boundary(lm, lb, p.originIndex)
            float expected = p.isHigh ? upper : lower
            int previous = p.isHigh ? lastHigh : lastLow
            if upper <= lower or math.abs(p.price - expected) > touchTolerance * a or p.originIndex - previous < 3
                ok := false
            if p.isHigh
                lastHigh := p.originIndex
            else
                lastLow := p.originIndex
    ok

f_points(array<Swing> stored, int start, int count) =>
    array<Swing> result = array.new<Swing>()
    if start >= 0 and start + count <= array.size(stored)
        for i = start to start + count - 1
            array.push(result, array.get(stored, i))
    result

f_makePattern(string kind, array<Swing> pts, float um, float ub, float lm, float lb, int direction, float quality, float apex) =>
    Swing first = array.get(pts, 0)
    Swing last = array.get(pts, array.size(pts) - 1)
    float hi = first.price
    float lo = first.price
    string id = kind
    array<int> indices = array.new<int>()
    array<float> prices = array.new<float>()
    for p in pts
        hi := math.max(hi, p.price)
        lo := math.min(lo, p.price)
        id += ":" + str.tostring(p.originIndex)
        array.push(indices, p.originIndex)
        array.push(prices, p.price)
    Pattern.new(id, kind, first.originIndex, last.originIndex, last.detectedIndex, last.atr, um, ub, lm, lb, hi, lo, direction, "Forming", last.detectedIndex, quality, array.size(pts), apex, false, indices, prices)

f_reversalCandidate(array<Swing> pts) =>
    Pattern result = na
    int n = array.size(pts)
    if n == 3 or n == 5
        Swing first = array.get(pts, 0)
        Swing last = array.get(pts, n - 1)
        float a = last.atr
        int span = last.originIndex - first.originIndex
        float sign = first.isHigh ? 1.0 : -1.0
        if not na(a) and a > 0 and span >= 2 * swingStrength and span <= 120 and first.context * sign >= 2.0 * a
            Swing middle = array.get(pts, 1)
            Swing third = array.get(pts, 2)
            float v0 = first.price * sign
            float v1 = middle.price * sign
            float v2 = third.price * sign
            string kind = ""
            float neckM = 0.0
            float neckB = middle.price
            float contactError = 0.0
            float contactLimit = equalTolerance * a
            float symmetry = 1.0
            if n == 3 and showDouble
                contactError := math.abs(v0 - v2)
                if contactError <= contactLimit and math.min(v0, v2) - v1 >= a
                    kind := first.isHigh ? "Double Top" : "Double Bottom"
            if n == 5
                Swing fourth = array.get(pts, 3)
                float v3 = fourth.price * sign
                float v4 = last.price * sign
                float ratio = float(third.originIndex - first.originIndex) / math.max(1, last.originIndex - third.originIndex)
                float nm = (fourth.price - middle.price) / (fourth.originIndex - middle.originIndex)
                float nb = middle.price - nm * middle.originIndex
                bool shoulders = v2 - math.max(v0, v4) >= 0.75 * a and math.abs(v0 - v4) <= 0.5 * a and v2 - f_boundary(nm, nb, third.originIndex) * sign >= 1.5 * a and ratio >= 0.5 and ratio <= 2.0
                if shoulders and showShoulders
                    kind := first.isHigh ? "Head & Shoulders" : "Inverse H&S"
                    neckM := nm
                    neckB := nb
                    contactError := math.abs(v0 - v4)
                    contactLimit := 0.5 * a
                    symmetry := math.min(ratio, 1.0 / ratio)
                else if showDouble
                    float spread = math.max(v0, math.max(v2, v4)) - math.min(v0, math.min(v2, v4))
                    if spread <= contactLimit and math.min(v0, v2) - v1 >= a and math.min(v2, v4) - v3 >= a
                        kind := first.isHigh ? "Triple Top" : "Triple Bottom"
                        neckB := first.isHigh ? math.min(middle.price, fourth.price) : math.max(middle.price, fourth.price)
                        contactError := spread
            if kind != ""
                float contactsScore = f_clamp(1.0 - contactError / math.max(contactLimit, syminfo.mintick), 0.0, 1.0)
                float contextScore = f_clamp(first.context * sign / (4.0 * a), 0.0, 1.0)
                float score = 40.0 * contactsScore + 25.0 + 20.0 * contextScore + 15.0 * symmetry
                float upperB = first.isHigh ? math.max(first.price, last.price) : neckB
                float lowerB = first.isHigh ? neckB : math.min(first.price, last.price)
                result := f_makePattern(kind, pts, first.isHigh ? 0.0 : neckM, upperB, first.isHigh ? neckM : 0.0, lowerB, first.isHigh ? -1 : 1, score, na)
    result

// Look across minor intervening swings, while rejecting an overtopping peak
// or a separate central contact that would require a multi-top classification.
f_wideDouble(array<Swing> stored, int firstIndex, int lastIndex) =>
    Pattern result = na
    Swing first = array.get(stored, firstIndex)
    Swing last = array.get(stored, lastIndex)
    int span = last.originIndex - first.originIndex
    float sign = first.isHigh ? 1.0 : -1.0
    float a = last.atr
    bool valid = showDouble and first.isHigh == last.isHigh and span >= 12 and span <= 120 and math.abs(first.price - last.price) <= equalTolerance * a
    Swing valley = na
    if valid
        for i = firstIndex + 1 to lastIndex - 1
            Swing inner = array.get(stored, i)
            if inner.isHigh != first.isHigh
                if na(valley)
                    valley := inner
                else if inner.price * sign < valley.price * sign
                    valley := inner
            else
                bool overtops = inner.price * sign > math.max(first.price * sign, last.price * sign) + breakTolerance * a
                int edge = math.max(8, int(span * 0.20))
                bool centralContact = inner.price * sign >= math.min(first.price * sign, last.price * sign) - equalTolerance * a and inner.originIndex - first.originIndex > edge and last.originIndex - inner.originIndex > edge
                if overtops or centralContact
                    valid := false
        if valid and not na(valley)
            result := f_reversalCandidate(array.from(first, valley, last))
    result

f_detectReversals(array<Swing> stored, array<Pattern> output) =>
    int added = 0
    for count = 3 to 5 by 2
        if array.size(stored) >= count
            array<Swing> pts = f_points(stored, array.size(stored) - count, count)
            Pattern candidate = f_reversalCandidate(pts)
            if not na(candidate)
                array.push(output, candidate)
                added += 1
    int n = array.size(stored)
    if n >= 5 and showDouble
        for offset = 4 to math.min(n - 1, 24) by 2
            Pattern candidate = f_wideDouble(stored, n - 1 - offset, n - 1)
            if not na(candidate)
                array.push(output, candidate)
                added += 1
    added

f_validateBars(int startIndex, int endIndex, float um, float ub, float lm, float lb, float a) =>
    bool ok = a > 0 and endIndex >= startIndex and bar_index - startIndex <= 300 and startIndex >= 0
    int wickViolations = 0
    int checked = 0
    if ok
        for x = startIndex to endIndex
            int offset = bar_index - x
            float upper = f_boundary(um, ub, x)
            float lower = f_boundary(lm, lb, x)
            if na(close[offset]) or close[offset] > upper + breakTolerance * a or close[offset] < lower - breakTolerance * a
                ok := false
            if high[offset] > upper + touchTolerance * a or low[offset] < lower - touchTolerance * a
                wickViolations += 1
            checked += 1
    ok and checked > 0 and wickViolations <= checked * 0.10

f_findPole(int consolidationStart, float a) =>
    bool valid = false
    int direction = 0
    int duration = 0
    float magnitude = 0.0
    int offset = bar_index - consolidationStart
    if a > 0 and offset >= 0 and offset <= 300
        for length = 5 to 20
            if not valid and consolidationStart >= length
                float delta = close[offset] - close[offset + length]
                float travel = 0.0
                for j = 0 to length - 1
                    travel += math.abs(close[offset + j] - close[offset + j + 1])
                if not na(delta) and travel > 0 and math.abs(delta) >= 3.0 * a and math.abs(delta) / travel >= 0.65
                    valid := true
                    direction := delta > 0 ? 1 : -1
                    duration := length
                    magnitude := math.abs(delta)
    [valid, direction, duration, magnitude]

// Pure geometry. OHLC containment and pole history are checked by the caller.
f_geometricCandidate(array<Swing> pts, bool poleValid, int poleDir, int poleDuration, float poleMagnitude, float poleEnd) =>
    Pattern result = na
    int count = array.size(pts)
    if count >= 4
        Swing first = array.get(pts, 0)
        Swing last = array.get(pts, count - 1)
        float a = last.atr
        int span = last.originIndex - first.originIndex
        [um, ub, ur, uc] = f_fitLine(pts, true)
        [lm, lb, lr, lc] = f_fitLine(pts, false)
        if not na(a) and a > 0 and span >= 6 and span <= 120 and f_validateEnvelope(pts, um, ub, lm, lb, a)
            float w0 = f_boundary(um, ub, first.originIndex) - f_boundary(lm, lb, first.originIndex)
            float w1 = f_boundary(um, ub, last.originIndex) - f_boundary(lm, lb, last.originIndex)
            float du = um * span
            float dl = lm * span
            bool flatU = math.abs(du) <= 0.25 * a
            bool flatL = math.abs(dl) <= 0.25 * a
            bool parallel = math.abs(du - dl) <= 0.30 * a and math.abs(w1 - w0) / w0 <= 0.20
            float apex = um != lm ? (lb - ub) / (um - lm) : na
            bool converging = um < lm and w1 / w0 <= 0.75 and not na(apex) and apex > last.detectedIndex and apex <= last.originIndex + span
            string kind = ""
            int direction = 0
            float contextScore = 1.0
            float lo = first.price
            float hi = first.price
            for p in pts
                lo := math.min(lo, p.price)
                hi := math.max(hi, p.price)
            float retrace = poleDir > 0 ? poleEnd - lo : hi - poleEnd
            bool poleContext = poleValid and poleMagnitude >= 3.0 * a and span <= 40 and span <= poleDuration * 3 and retrace >= 0 and retrace <= 0.5 * poleMagnitude
            if showFlags and poleContext
                bool flag = parallel and ((flatU and flatL) or (du * poleDir < 0 and dl * poleDir < 0))
                bool pennant = count >= 5 and converging and du < -0.25 * a and dl > 0.25 * a
                if pennant or flag
                    kind := poleDir > 0 ? (pennant ? "Bullish Pennant" : "Bullish Flag") : (pennant ? "Bearish Pennant" : "Bearish Flag")
                    direction := poleDir
                    contextScore := f_clamp(poleMagnitude / (5.0 * a), 0.0, 1.0)
            if kind == "" and span >= 12
                if count >= 5 and converging
                    if showTriangles and flatU and dl > 0.25 * a
                        kind := "Ascending Triangle"
                    else if showTriangles and flatL and du < -0.25 * a
                        kind := "Descending Triangle"
                    else if showTriangles and du < -0.25 * a and dl > 0.25 * a
                        kind := "Symmetrical Triangle"
                    else if showWedges and du > 0.25 * a and dl > 0.25 * a
                        kind := "Rising Wedge"
                    else if showWedges and du < -0.25 * a and dl < -0.25 * a
                        kind := "Falling Wedge"
                if kind == "" and showChannels and uc >= 3 and lc >= 3 and parallel
                    if flatU and flatL and w0 >= a and w0 <= 6.0 * a
                        kind := "Rectangle"
                    else if du > 0.25 * a and dl > 0.25 * a
                        kind := "Ascending Channel"
                    else if du < -0.25 * a and dl < -0.25 * a
                        kind := "Descending Channel"
            if kind != ""
                float contactScore = f_clamp(1.0 - math.max(ur, lr) / (touchTolerance * a), 0.0, 1.0)
                float fitScore = converging ? f_clamp((1.0 - w1 / w0) / 0.50, 0.0, 1.0) : f_clamp(1.0 - math.abs(du - dl) / (0.30 * a), 0.0, 1.0)
                int largestGap = 0
                for i = 1 to count - 1
                    largestGap := math.max(largestGap, array.get(pts, i).originIndex - array.get(pts, i - 1).originIndex)
                float timing = f_clamp(float(span) / ((count - 1) * math.max(1, largestGap)), 0.0, 1.0)
                float quality = 40.0 * contactScore + 25.0 * fitScore + 20.0 * contextScore + 15.0 * timing
                result := f_makePattern(kind, pts, um, ub, lm, lb, direction, quality, converging ? apex : na)
    result

f_detectContinuations(array<Swing> stored, array<Pattern> output) =>
    int added = 0
    int n = array.size(stored)
    if n >= 4
        for count = 4 to math.min(n, 27)
            array<Swing> pts = f_points(stored, n - count, count)
            Swing first = array.get(pts, 0)
            Swing last = array.get(pts, count - 1)
            if bar_index - first.originIndex <= 300 and last.originIndex - first.originIndex <= 120
                [poleValid, poleDir, poleDuration, poleMagnitude] = f_findPole(first.originIndex, last.atr)
                float poleEnd = close[bar_index - first.originIndex]
                Pattern candidate = f_geometricCandidate(pts, poleValid, poleDir, poleDuration, poleMagnitude, poleEnd)
                if not na(candidate)
                    if f_validateBars(candidate.startIndex, candidate.endIndex, candidate.upperSlope, candidate.upperIntercept, candidate.lowerSlope, candidate.lowerIntercept, candidate.atr)
                        array.push(output, candidate)
                        added += 1
    added

f_isRange(Pattern p) =>
    str.contains(p.kind, "Channel") or p.kind == "Rectangle"

f_finished(Pattern p) =>
    str.startswith(p.state, "Confirmed") or str.startswith(p.state, "Broken")

f_registerPatterns(array<Pattern> stored, array<Pattern> incoming) =>
    bool changed = false
    for candidate in incoming
        // Discard candidates that can no longer enter the presentation before
        // applying the capacity cap. Old high scores must not evict fresh work.
        if array.size(stored) > 0
            for i = array.size(stored) - 1 to 0
                Pattern old = array.get(stored, i)
                if old.state == "Invalid" or old.state == "Expired" or candidate.detectedIndex - old.endIndex > 150 or (f_finished(old) and candidate.detectedIndex - old.stateIndex > 120)
                    array.remove(stored, i)
        bool exists = false
        for p in stored
            if p.id == candidate.id
                exists := true
        if not exists
            array.push(stored, candidate)
            changed := true
    while array.size(stored) > 40
        int removeIndex = 0
        bool found = false
        for i = 0 to array.size(stored) - 1
            Pattern p = array.get(stored, i)
            if not found and (p.state == "Invalid" or p.state == "Expired")
                removeIndex := i
                found := true
        if not found
            float worst = 1000000.0
            for i = 0 to array.size(stored) - 1
                Pattern p = array.get(stored, i)
                float priority = p.quality + p.endIndex * 0.001
                if priority < worst
                    worst := priority
                    removeIndex := i
        array.remove(stored, removeIndex)
    changed

f_updatePatterns(array<Pattern> stored, float closedPrice, int currentIndex) =>
    bool changed = false
    if not na(closedPrice)
        for p in stored
            if currentIndex >= p.detectedIndex
                float upper = f_boundary(p.upperSlope, p.upperIntercept, currentIndex)
                float lower = f_boundary(p.lowerSlope, p.lowerIntercept, currentIndex)
                float buffer = p.atr * breakTolerance
                bool isRange = f_isRange(p)
                bool isContinuation = str.contains(p.kind, "Flag") or str.contains(p.kind, "Pennant")
                if p.state == "Forming"
                    bool reversal = str.contains(p.kind, "Top") or str.contains(p.kind, "Bottom") or str.contains(p.kind, "Shoulders") or p.kind == "Inverse H&S"
                    int lifetime = isRange ? 60 : reversal ? math.max(30, math.min(120, p.endIndex - p.startIndex)) : 30
                    bool expired = currentIndex - (isRange ? p.endIndex : p.detectedIndex) > lifetime or (not na(p.apex) and currentIndex >= p.apex)
                    int direction = closedPrice > upper + buffer ? 1 : closedPrice < lower - buffer ? -1 : 0
                    bool reversalInvalid = p.expectedDirection == -1 and not isContinuation and closedPrice > p.extremeHigh + buffer or p.expectedDirection == 1 and not isContinuation and closedPrice < p.extremeLow - buffer
                    if expired or reversalInvalid
                        p.state := expired ? "Expired" : "Invalid"
                        p.stateIndex := currentIndex
                        changed := true
                    else if direction != 0
                        if p.expectedDirection == 0 or direction == p.expectedDirection
                            p.state := (isRange ? "Broken " : "Confirmed ") + (direction > 0 ? "Up" : "Down")
                            p.stateIndex := currentIndex
                            changed := true
                        else if isContinuation
                            p.state := "Invalid"
                            p.stateIndex := currentIndex
                            changed := true
                else if f_finished(p) and not p.returned and upper > lower and closedPrice <= upper and closedPrice >= lower
                    p.returned := true
                    changed := true
    changed

f_overlap(Pattern a, Pattern b) =>
    int shared = math.min(a.endIndex, b.endIndex) - math.max(a.startIndex, b.startIndex)
    int shorter = math.min(a.endIndex - a.startIndex, b.endIndex - b.startIndex)
    bool sharedReversalPeak = a.kind == b.kind and str.contains(a.kind, "Double") and (a.startIndex == b.startIndex or a.startIndex == b.endIndex or a.endIndex == b.startIndex or a.endIndex == b.endIndex)
    sharedReversalPeak or (shared > 0 and shorter > 0 and float(shared) / shorter >= 0.70 and math.min(a.extremeHigh, b.extremeHigh) >= math.max(a.extremeLow, b.extremeLow))

f_specialPrecedence(Pattern a, Pattern b) =>
    bool flagOverChannel = str.contains(a.kind, "Flag") and str.contains(b.kind, "Channel")
    bool pennantOverTriangle = str.contains(a.kind, "Pennant") and str.contains(b.kind, "Triangle")
    bool shouldersOverTriple = (str.contains(a.kind, "Shoulders") or a.kind == "Inverse H&S") and str.contains(b.kind, "Triple")
    flagOverChannel or pennantOverTriangle or shouldersOverTriple

f_rank(Pattern p, int currentIndex) =>
    float fresh = f_finished(p) and currentIndex - p.stateIndex <= 12 ? 200.0 : 0.0
    bool reversal = str.contains(p.kind, "Top") or str.contains(p.kind, "Bottom") or str.contains(p.kind, "Shoulders") or p.kind == "Inverse H&S"
    bool editorialView = viewMode == "Stories" and annotationStyle == "Editorial"
    float editorial = editorialView and reversal ? 30.0 : 0.0
    fresh + editorial + p.quality + p.endIndex * 0.0001 - (p.returned and not editorialView ? 20.0 : 0.0)

f_selectPatterns(array<Pattern> stored, int currentIndex, int limit, float minimum) =>
    array<int> selected = array.new<int>()
    array<int> eligible = array.new<int>()
    int n = array.size(stored)
    if n > 0
        for i = 0 to n - 1
            Pattern p = array.get(stored, i)
            if (p.state == "Forming" or f_finished(p)) and p.quality >= minimum and currentIndex - p.endIndex <= 150 and (not f_finished(p) or currentIndex - p.stateIndex <= 120)
                array.push(eligible, i)
    while array.size(eligible) > 0 and array.size(selected) < limit
        int bestPos = 0
        if array.size(eligible) > 1
            for j = 1 to array.size(eligible) - 1
                Pattern current = array.get(stored, array.get(eligible, j))
                Pattern best = array.get(stored, array.get(eligible, bestPos))
                bool overlap = f_overlap(current, best)
                bool forceCurrent = overlap and f_specialPrecedence(current, best)
                bool forceBest = overlap and f_specialPrecedence(best, current)
                if overlap and viewMode == "Stories" and annotationStyle == "Editorial" and current.kind == best.kind and str.contains(current.kind, "Double")
                    int currentSpan = current.endIndex - current.startIndex
                    int bestSpan = best.endIndex - best.startIndex
                    forceCurrent := forceCurrent or currentSpan * 2 < bestSpan
                    forceBest := forceBest or bestSpan * 2 < currentSpan
                if forceCurrent or (not forceBest and f_rank(current, currentIndex) > f_rank(best, currentIndex))
                    bestPos := j
        int bestIndex = array.remove(eligible, bestPos)
        Pattern best = array.get(stored, bestIndex)
        bool conflict = false
        for selectedIndex in selected
            if f_overlap(best, array.get(stored, selectedIndex))
                conflict := true
        if not conflict
            array.push(selected, bestIndex)
    selected

f_swingLabel(float latest, float previous, bool highSide, float a) =>
    math.abs(latest - previous) <= 0.15 * a ? (highSide ? "EQH" : "EQL") : highSide ? (latest > previous ? "HH" : "LH") : (latest > previous ? "HL" : "LL")

f_marketStructure(array<Swing> stored, float a) =>
    float high1 = na
    float high2 = na
    float low1 = na
    float low2 = na
    for p in stored
        if p.isHigh
            high2 := high1
            high1 := p.price
        else
            low2 := low1
            low1 := p.price
    string highType = not na(high2) and not na(a) ? f_swingLabel(high1, high2, true, a) : ""
    string lowType = not na(low2) and not na(a) ? f_swingLabel(low1, low2, false, a) : ""
    string trend = highType == "HH" and lowType == "HL" ? "Up" : highType == "LH" and lowType == "LL" ? "Down" : "Neutral"
    [trend, highType, lowType]

f_structureBias(string trend) =>
    trend == "Up" ? 1 : trend == "Down" ? -1 : 0

f_zoneFromSwing(Swing p) =>
    Zone result = na
    if p.atr > 0 and p.departure >= 1.5 * p.atr
        float rawWidth = p.isHigh ? p.price - math.max(p.candleOpen, p.candleClose) : math.min(p.candleOpen, p.candleClose) - p.price
        float width = f_clamp(rawWidth, 0.2 * p.atr, p.atr)
        float top = p.isHigh ? p.price : p.price + width
        float bottom = p.isHigh ? p.price - width : p.price
        result := Zone.new((p.isHigh ? "S:" : "D:") + str.tostring(p.originIndex), not p.isHigh, top, bottom, p.atr, p.originIndex, p.detectedIndex, false, true, p.originTime)
    result

f_updateZones(array<Zone> stored, array<Swing> points, float closedPrice, float barHigh, float barLow, int currentIndex) =>
    bool changed = false
    if array.size(points) > 0
        Swing last = array.get(points, array.size(points) - 1)
        Zone incoming = f_zoneFromSwing(last)
        if not na(incoming)
            bool duplicate = false
            for z in stored
                if z.id == incoming.id
                    duplicate := true
            if not duplicate
                array.push(stored, incoming)
                changed := true
    while array.size(stored) > 36
        int removal = 0
        bool invalidFound = false
        for i = 0 to array.size(stored) - 1
            if not invalidFound and not array.get(stored, i).valid
                removal := i
                invalidFound := true
        array.remove(stored, removal)
    for z in stored
        if z.valid and currentIndex >= z.detectedIndex and not na(closedPrice)
            bool invalid = z.isDemand ? closedPrice < z.bottom - breakTolerance * z.atr : closedPrice > z.top + breakTolerance * z.atr
            if invalid
                z.valid := false
                changed := true
            else if not z.touched and barHigh >= z.bottom and barLow <= z.top
                z.touched := true
                changed := true
    changed

f_periodLevels() =>
    float chartSeconds = timeframe.in_seconds()
    bool weekAllowed = not na(chartSeconds) and chartSeconds <= timeframe.in_seconds("W")
    bool monthAllowed = not na(chartSeconds) and chartSeconds <= timeframe.in_seconds("M")
    [wh, wl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
    [mh, ml, mo] = request.security(syminfo.tickerid, "M", [high[1], low[1], open], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
    [weekAllowed ? wh : na, weekAllowed ? wl : na, weekAllowed ? (wh + wl) / 2.0 : na, monthAllowed ? (mh + ml) / 2.0 : na, monthAllowed ? mo : na]

// Run the unchanged swing/zone rules in their own source context. Offset 1
// uses only the preceding closed 4H candle for equal/higher-timeframe requests.
// Offset 0 is used only by the Daily intrabar request; the caller checks close time.
f_zoneSnapshot(int offset) =>
    var array<Swing> sourceSwings = array.new<Swing>()
    var array<Zone> sourceZones = array.new<Zone>()
    float a = ta.atr(14)
    float ph = ta.pivothigh(high, swingStrength, swingStrength)
    float pl = ta.pivotlow(low, swingStrength, swingStrength)
    float lowest = ta.lowest(low, swingStrength + 1)
    float highest = ta.highest(high, swingStrength + 1)
    int sourceIndex = bar_index - offset
    bool ambiguous = not na(ph[offset]) and not na(pl[offset])
    if not ambiguous and (not na(ph[offset]) or not na(pl[offset])) and not na(a[swingStrength + offset])
        bool isHigh = not na(ph[offset])
        float price = isHigh ? ph[offset] : pl[offset]
        float departure = isHigh ? price - lowest[offset] : highest[offset] - price
        Swing item = Swing.new(sourceIndex - swingStrength, time[swingStrength + offset], sourceIndex, price, isHigh, a[swingStrength + offset], open[swingStrength + offset], close[swingStrength + offset], departure, price - close[swingStrength + 12 + offset])
        f_ingestSwing(sourceSwings, item)
    while array.size(sourceSwings) > 0 and sourceIndex - array.get(sourceSwings, 0).originIndex > 300
        array.shift(sourceSwings)
    f_updateZones(sourceZones, sourceSwings, close[offset], high[offset], low[offset], sourceIndex)
    // Only the recent snapshots are needed for the last-bar renderer. Bound
    // collection copies instead of returning arrays over all historical bars.
    ZoneSnapshot result = na
    if last_bar_index - bar_index < 12
        array<Zone> copy = array.new<Zone>()
        for z in sourceZones
            array.push(copy, z.copy())
        result := ZoneSnapshot.new(copy, sourceIndex, close[offset], a[offset], time_close[offset])
    result

// Only the current presentation layer is drawn. No historical object accumulation.
type Annotation
    int x
    float y
    string caption
    color tone
    float atr
    int side
    string align
    bool movable
    int priority
    float width
    float height

var array<Annotation> pendingText = array.new<Annotation>()
var array<Annotation> placedText = array.new<Annotation>()

f_clearDrawings() =>
    for item in drawLines
        line.delete(item)
    for item in drawBoxes
        box.delete(item)
    for item in drawLabels
        label.delete(item)
    for item in drawCurves
        polyline.delete(item)
    array.clear(drawLines)
    array.clear(drawBoxes)
    array.clear(drawLabels)
    array.clear(drawCurves)
    array.clear(pendingText)
    array.clear(placedText)
    true

f_drawLine(int x1, float y1, int x2, float y2, color tone, string style, int width) =>
    if array.size(drawLines) < 150 and not na(y1) and not na(y2)
        array.push(drawLines, line.new(x1=x1, y1=y1, x2=x2, y2=y2, xloc=xloc.bar_index, extend=extend.none, color=tone, style=style, width=width))
    true

f_annotationSize(int priority) =>
    priority >= 90 ? textSize : textChoice == "Large" ? size.normal : textChoice == "Normal" ? size.small : size.tiny

// Queue first, place by priority later. Price annotations stay at their price.
f_placeText(int x, float y, string caption, color tone, float a, int side, string align, bool movable = true, int priority = 50) =>
    array<string> rows = str.split(caption, "\n")
    int longest = 0
    for row in rows
        longest := math.max(longest, str.length(row))
    float scale = textChoice == "Large" ? 1.35 : textChoice == "Normal" ? 1.15 : 1.0
    float width = math.max(5.0, longest * (priority >= 90 ? 0.65 : 0.5) * scale)
    float height = math.max(a, syminfo.mintick * 10) * array.size(rows) * (priority >= 90 ? 0.48 : 0.36) * scale
    bool queued = array.size(pendingText) < 80 and not na(y)
    if queued
        array.push(pendingText, Annotation.new(x, y, caption, tone, a, side, align, movable, priority, width, height))
    queued

f_textOverlaps(Annotation candidate, float y, Annotation existing) =>
    float cx = candidate.x - (candidate.align == text.align_right ? candidate.width / 2.0 : 0.0)
    float ex = existing.x - (existing.align == text.align_right ? existing.width / 2.0 : 0.0)
    math.abs(cx - ex) < (candidate.width + existing.width) / 2.0 + 2.0 and math.abs(y - existing.y) < (candidate.height + existing.height) / 2.0 + math.max(candidate.atr, existing.atr) * 0.22

f_secondaryCrowded(Annotation item, float y) =>
    bool crowded = false
    if item.priority < 50
        float cx = item.x - (item.align == text.align_right ? item.width / 2.0 : 0.0)
        for region in drawBoxes
            if cx + item.width / 2.0 >= box.get_left(region) and cx - item.width / 2.0 <= box.get_right(region) and y + item.height / 2.0 >= box.get_bottom(region) and y - item.height / 2.0 <= box.get_top(region)
                crowded := true
    crowded

f_flushText() =>
    while array.size(pendingText) > 0 and array.size(drawLabels) < 80
        int best = 0
        if array.size(pendingText) > 1
            for i = 1 to array.size(pendingText) - 1
                if array.get(pendingText, i).priority > array.get(pendingText, best).priority
                    best := i
        Annotation item = array.remove(pendingText, best)
        bool placed = false
        for slot = 0 to (item.movable ? 1 : 0)
            float y = item.y + item.side * slot * item.atr * 0.55
            bool collision = f_secondaryCrowded(item, y)
            for existing in placedText
                if f_textOverlaps(item, y, existing)
                    collision := true
            if not placed and not collision
                string style = item.align == text.align_right ? label.style_label_right : label.style_none
                array.push(drawLabels, label.new(x=item.x, y=y, text=item.caption, xloc=xloc.bar_index, yloc=yloc.price, style=style, color=color.new(item.tone, 100), textcolor=item.tone, size=f_annotationSize(item.priority), textalign=item.align))
                item.y := y
                array.push(placedText, item)
                placed := true
    array.clear(pendingText)
    true

f_patternStatus(Pattern p) =>
    p.returned ? "Returned inside" : p.state == "Forming" ? (f_isRange(p) ? "Active structure" : "Forming") : p.state == "Confirmed Up" ? "Confirmed · upward break" : p.state == "Confirmed Down" ? "Confirmed · downward break" : p.state == "Broken Up" ? "Broken · upward" : "Broken · downward"

f_archGeometry(Pattern p, int currentIndex) =>
    bool top = p.expectedDirection == -1
    int span = p.endIndex - p.startIndex
    int pad = math.max(3, int(math.ceil(math.max(0, 28 - span) / 2.0)))
    int left = math.max(0, p.startIndex - pad)
    int right = math.min(currentIndex, p.endIndex + pad)
    float edge = top ? p.extremeHigh - 0.30 * p.atr : p.extremeLow + 0.30 * p.atr
    float amplitude = math.min(0.90, 0.55 + span * 0.008) * p.atr
    [left, right, edge, amplitude]

f_reversalArch(Pattern p, int currentIndex) =>
    bool top = p.expectedDirection == -1
    [left, right, edge, amplitude] = f_archGeometry(p, currentIndex)
    float sign = top ? 1.0 : -1.0
    int previousX = left
    float previousY = edge
    for i = 1 to 16
        float t = i / 16.0
        int x = int(math.round(left + t * (right - left)))
        float y = edge + sign * (4.0 * t * (1.0 - t)) * amplitude
        if x > previousX
            f_drawLine(previousX, previousY, x, y, color.new(ink, 10), line.style_solid, 1)
            previousX := x
            previousY := y
    true

f_renderPatterns(array<Pattern> stored, array<int> selected, int currentIndex) =>
    for index in selected
        Pattern p = array.get(stored, index)
        bool reversal = str.contains(p.kind, "Top") or str.contains(p.kind, "Bottom") or str.contains(p.kind, "Shoulders") or p.kind == "Inverse H&S"
        int end = math.min(currentIndex, p.state == "Forming" ? currentIndex : p.stateIndex)
        if not na(p.apex)
            end := math.min(end, int(math.floor(p.apex)) - 1)
        end := math.max(p.endIndex, end)
        if reversal and annotationStyle == "Editorial" and viewMode == "Stories"
            f_reversalArch(p, currentIndex)
        else if reversal
            int count = array.size(p.anchorIndices)
            if count > 1
                for i = 1 to count - 1
                    f_drawLine(array.get(p.anchorIndices, i - 1), array.get(p.anchorPrices, i - 1), array.get(p.anchorIndices, i), array.get(p.anchorPrices, i), color.new(ink, 35), line.style_solid, 1)
            bool isTop = p.expectedDirection == -1
            float m = isTop ? p.lowerSlope : p.upperSlope
            float b = isTop ? p.lowerIntercept : p.upperIntercept
            f_drawLine(p.startIndex, f_boundary(m, b, p.startIndex), end, f_boundary(m, b, end), color.new(ink, 45), line.style_dashed, 1)
        else
            f_drawLine(p.startIndex, f_boundary(p.upperSlope, p.upperIntercept, p.startIndex), end, f_boundary(p.upperSlope, p.upperIntercept, end), color.new(ink, 5), line.style_solid, 1)
            f_drawLine(p.startIndex, f_boundary(p.lowerSlope, p.lowerIntercept, p.startIndex), end, f_boundary(p.lowerSlope, p.lowerIntercept, end), color.new(ink, 5), line.style_solid, 1)
        int middle = int(math.round((p.startIndex + p.endIndex) / 2.0))
        string caption = p.kind + "\n" + f_patternStatus(p)
        if viewMode == "Stories" and annotationStyle == "Editorial"
            caption := p.kind + (p.state == "Forming" ? "\nForming" : "")
        if viewMode == "Analysis"
            int detectionOffset = bar_index - p.detectedIndex
            int detectionTime = detectionOffset >= 0 and detectionOffset <= 300 ? time[detectionOffset] : na
            [detectionSupported, detectionInterval, detectionDelay] = f_timeframeContext(timeframe.in_seconds(), p.detectedIndex - p.endIndex, timeframe.period)
            caption += "\n" + str.format_time(detectionTime, "dd MMM HH:mm", syminfo.timezone) + " · +" + str.tostring(p.detectedIndex - p.endIndex) + " bars (" + detectionDelay + ")"
        f_placeText(middle, p.extremeHigh + p.atr * 0.85, caption, ink, p.atr, 1, text.align_center, true, 100)
    true

f_primaryZoneIndex(array<Zone> chosen, bool demand, float referencePrice) =>
    int result = -1
    float extreme = na
    if array.size(chosen) > 0
        for i = 0 to array.size(chosen) - 1
            Zone z = array.get(chosen, i)
            float middle = (z.top + z.bottom) / 2.0
            if z.isDemand == demand and (demand ? middle <= referencePrice : middle >= referencePrice)
                if na(extreme) or (demand ? middle < extreme : middle > extreme)
                    result := i
                    extreme := middle
    result

f_mergeVisualZone(array<Zone> chosen, Zone source) =>
    Zone merged = source.copy()
    int i = 0
    while i < array.size(chosen)
        Zone existing = array.get(chosen, i)
        if merged.isDemand == existing.isDemand and math.min(merged.top, existing.top) >= math.max(merged.bottom, existing.bottom)
            merged.top := math.max(merged.top, existing.top)
            merged.bottom := math.min(merged.bottom, existing.bottom)
            merged.originIndex := math.min(merged.originIndex, existing.originIndex)
            merged.originTime := na(merged.originTime) ? existing.originTime : na(existing.originTime) ? merged.originTime : math.min(merged.originTime, existing.originTime)
            array.remove(chosen, i)
            i := 0
        else
            i += 1
    array.push(chosen, merged)
    true

f_renderZones(array<Zone> stored, int currentIndex, int limit, int sourceIndex = na, float sourcePrice = na, float sourceATR = na, bool anchoredTime = false) =>
    int ageIndex = nz(sourceIndex, currentIndex)
    float referencePrice = nz(sourcePrice, close[bar_index - currentIndex])
    float rangeATR = nz(sourceATR, currentATR)
    array<Zone> chosen = array.new<Zone>()
    int n = array.size(stored)
    if n > 0
        for offset = 0 to n - 1
            Zone z = array.get(stored, n - 1 - offset)
            float visibleRange = math.max(8.0 * nz(rangeATR, z.atr), referencePrice * 0.06)
            bool relevant = viewMode != "Stories" or math.abs((z.top + z.bottom) / 2.0 - referencePrice) <= visibleRange
            if z.valid and relevant and ageIndex - z.originIndex <= 300
                f_mergeVisualZone(chosen, z)
    int demandIndex = f_primaryZoneIndex(chosen, true, referencePrice)
    int supplyIndex = f_primaryZoneIndex(chosen, false, referencePrice)
    int rendered = 0
    if array.size(chosen) > 0
        for i = 0 to array.size(chosen) - 1
            Zone z = array.get(chosen, i)
            bool primary = viewMode != "Stories" or i == demandIndex or i == supplyIndex
            if primary and rendered < limit
                color tone = z.isDemand ? demandColor : supplyColor
                int alpha = math.min(95, zoneTransparency + (z.touched ? 4 : 0))
                if array.size(drawBoxes) < 30
                    int rightTime = time[bar_index - currentIndex] + int(timeframe.in_seconds() * 1000) * zoneExtension
                    array.push(drawBoxes, box.new(left=anchoredTime ? z.originTime : z.originIndex, top=z.top, right=anchoredTime ? rightTime : currentIndex + zoneExtension, bottom=z.bottom, xloc=anchoredTime ? xloc.bar_time : xloc.bar_index, border_color=color.new(tone, 100), border_width=1, bgcolor=color.new(tone, alpha)))
                string zoneName = z.isDemand ? "DEMAND ZONE" : annotationStyle == "Editorial" ? "RESISTANCE ZONE" : "SUPPLY ZONE"
                f_placeText(anchoredTime ? currentIndex + zoneExtension - 2 : math.max(z.originIndex, currentIndex + zoneExtension - 2), (z.top + z.bottom) / 2.0, zoneName, color.new(ink, 18), z.atr, z.isDemand ? -1 : 1, text.align_right, false, 70)
                rendered += 1
    true

f_levelAvailable(int availableFrom, int currentIndex) =>
    availableFrom <= currentIndex

// The most recent rising support / falling resistance pair. Extension stops
// at its first closed-bar break and never reaches future candles.
f_firstTrendlineBreak(array<float> prices, int firstIndex, int fallback, float m, float b, float sign, float a) =>
    int endpoint = fallback
    if array.size(prices) > 0
        for i = 0 to array.size(prices) - 1
            int x = firstIndex + i
            if endpoint == fallback and (array.get(prices, i) - f_boundary(m, b, x)) * sign < -breakTolerance * a
                endpoint := x
    endpoint

f_renderTrendline(array<Swing> points, int currentIndex) =>
    Swing bestFirst = na
    Swing bestLast = na
    float bestSlope = na
    float bestIntercept = na
    int bestEndpoint = currentIndex
    float bestScore = -1.0
    int n = array.size(points)
    if showTrendline and n >= 3
        for offset = 0 to math.min(n - 3, 20)
            if viewMode == "Stories" or na(bestFirst)
                Swing last = array.get(points, n - 1 - offset)
                Swing first = array.get(points, n - 3 - offset)
                int span = last.originIndex - first.originIndex
                float sign = last.isHigh ? -1.0 : 1.0
                if currentIndex - last.originIndex <= 90 and span >= 6 and span <= 60 and (last.price - first.price) * sign >= 0.5 * last.atr
                    float m = (last.price - first.price) / span
                    float b = first.price - m * first.originIndex
                    bool valid = true
                    for x = first.originIndex to last.originIndex
                        if (close[bar_index - x] - f_boundary(m, b, x)) * sign < -touchTolerance * last.atr
                            valid := false
                    if valid
                        array<float> closedPrices = array.new<float>()
                        if currentIndex > last.originIndex
                            for x = last.originIndex + 1 to currentIndex
                                array.push(closedPrices, close[bar_index - x])
                        int endpoint = f_firstTrendlineBreak(closedPrices, last.originIndex + 1, currentIndex, m, b, sign, last.atr)
                        // Presentation preference only: the recent broken,
                        // broader structure is clearer than a tiny live rally.
                        float score = viewMode == "Stories" ? span + (endpoint < currentIndex ? 30.0 : 0.0) + (last.isHigh ? 0.0 : 4.0) : 0.0
                        if na(bestFirst) or score > bestScore
                            bestFirst := first
                            bestLast := last
                            bestSlope := m
                            bestIntercept := b
                            bestEndpoint := endpoint
                            bestScore := score
    if not na(bestFirst)
        float sign = bestLast.isHigh ? -1.0 : 1.0
        f_drawLine(bestFirst.originIndex, bestFirst.price, bestEndpoint, f_boundary(bestSlope, bestIntercept, bestEndpoint), color.new(ink, 25), line.style_dashed, 1)
        int middle = int(math.round((bestFirst.originIndex + bestEndpoint) / 2.0))
        f_placeText(middle, f_boundary(bestSlope, bestIntercept, middle) + sign * 0.3 * bestLast.atr, "TRENDLINE", color.new(ink, 25), bestLast.atr, int(sign), text.align_center, false, 40)
    not na(bestFirst)

f_renderLevel(float value, string name, int startIndex, int currentIndex, bool major, float a, bool band = false) =>
    if not na(value) and f_levelAvailable(startIndex, currentIndex)
        f_drawLine(startIndex, value, currentIndex + zoneExtension, value, color.new(ink, major ? 20 : 55), major ? line.style_solid : line.style_dotted, 1)
        f_placeText(currentIndex + zoneExtension - 2, value + 0.18 * a, name, color.new(ink, major ? 10 : 40), a, 1, text.align_right, false, major ? 80 : 60)
    true

f_renderStructure(array<Swing> points, array<StructureEvent> storedEvents, int currentIndex, float a) =>
    if showBreaks
        int n = array.size(storedEvents)
        int rendered = 0
        if n > 0
            for offset = 0 to n - 1
                StructureEvent e = array.get(storedEvents, n - 1 - offset)
                if currentIndex - e.eventIndex <= 60 and rendered < (viewMode == "Stories" ? 2 : 5)
                    f_drawLine(e.originIndex, e.price, e.eventIndex, e.price, color.new(ink, 60), line.style_dotted, 1)
                    if viewMode != "Stories" or e.kind != "Break"
                        f_placeText(int(math.round((e.originIndex + e.eventIndex) / 2.0)), e.price + e.direction * a * 0.35, e.kind, color.new(ink, 40), a, e.direction, text.align_center, false, 30)
                    rendered += 1
    if showSwings and array.size(points) > 0
        float previousHigh = na
        float previousLow = na
        int n = array.size(points)
        for i = 0 to n - 1
            Swing p = array.get(points, i)
            float previous = p.isHigh ? previousHigh : previousLow
            if i >= math.max(0, n - (viewMode == "Stories" ? 6 : 12)) and not na(previous)
                string name = f_swingLabel(p.price, previous, p.isHigh, p.atr)
                f_placeText(p.originIndex, p.price + (p.isHigh ? 0.4 : -0.4) * p.atr, name, color.new(ink, 40), p.atr, p.isHigh ? 1 : -1, text.align_center, false, 20)
            if p.isHigh
                previousHigh := p.price
            else
                previousLow := p.price
    true

// Shared 4H zone context, independent of chart pivots and chart ATR.
ZoneSnapshot sharedZones = na
if zoneSource == "4H"
    if timeframe.in_seconds() <= 14400
        sharedZones := request.security(syminfo.tickerid, "240", f_zoneSnapshot(1), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, calc_bars_count=650)
    else
        array<ZoneSnapshot> intrabars = request.security_lower_tf(syminfo.tickerid, "240", f_zoneSnapshot(0), calc_bars_count=650)
        for snapshot in intrabars
            if not na(snapshot) and snapshot.closedAt <= timenow
                sharedZones := snapshot
        // A newly opened Daily candle can have no closed intrabars yet.
        if na(sharedZones)
            sharedZones := sharedZones[1]

float pivotHigh = ta.pivothigh(high, swingStrength, swingStrength)
float ema200 = ta.ema(close, 200)
float pivotLow = ta.pivotlow(low, swingStrength, swingStrength)
float recentLowest = ta.lowest(low, swingStrength + 1)
float recentHighest = ta.highest(high, swingStrength + 1)
[previousWeekHigh, previousWeekLow, previousWeekMid, previousMonthMid, monthlyOpen] = f_periodLevels()
var int structureBias = 0
var int lastBrokenHigh = -1
var int lastBrokenLow = -1
var int weekAvailableFrom = 0
var int monthAvailableFrom = 0
if timeframe.change("W")
    weekAvailableFrom := bar_index
if timeframe.change("M")
    monthAvailableFrom := bar_index
bool newSwing = false
if barstate.isconfirmed
    bool ambiguousPivot = not na(pivotHigh) and not na(pivotLow)
    if not ambiguousPivot and (not na(pivotHigh) or not na(pivotLow)) and not na(currentATR[swingStrength])
        bool isHigh = not na(pivotHigh)
        float price = isHigh ? pivotHigh : pivotLow
        float departure = isHigh ? price - recentLowest : recentHighest - price
        float context = price - close[swingStrength + 12]
        Swing item = Swing.new(bar_index - swingStrength, time[swingStrength], bar_index, price, isHigh, currentATR[swingStrength], open[swingStrength], close[swingStrength], departure, context)
        newSwing := f_ingestSwing(swings, item)
    while array.size(swings) > 0 and bar_index - array.get(swings, 0).originIndex > 300
        array.shift(swings)
    if newSwing
        array<Pattern> incoming = array.new<Pattern>()
        f_detectReversals(swings, incoming)
        f_detectContinuations(swings, incoming)
        f_registerPatterns(patterns, incoming)
    f_updatePatterns(patterns, close, bar_index)
    f_updateZones(zones, swings, close, high, low, bar_index)
    [trend, latestHighType, latestLowType] = f_marketStructure(swings, currentATR)
    if newSwing
        structureBias := f_structureBias(trend)
    Swing latestHigh = na
    Swing latestLow = na
    for p in swings
        if p.isHigh
            latestHigh := p
        else
            latestLow := p
    if not na(latestHigh) and latestHigh.originIndex != lastBrokenHigh and close > latestHigh.price + breakTolerance * latestHigh.atr
        string kind = structureBias == 0 ? "Break" : structureBias == 1 ? "BOS" : "CHoCH"
        array.push(events, StructureEvent.new(latestHigh.originIndex, bar_index, latestHigh.price, kind, 1))
        lastBrokenHigh := latestHigh.originIndex
    if not na(latestLow) and latestLow.originIndex != lastBrokenLow and close < latestLow.price - breakTolerance * latestLow.atr
        string kind = structureBias == 0 ? "Break" : structureBias == -1 ? "BOS" : "CHoCH"
        array.push(events, StructureEvent.new(latestLow.originIndex, bar_index, latestLow.price, kind, -1))
        lastBrokenLow := latestLow.originIndex
    while array.size(events) > 12
        array.shift(events)

var table signature = table.new(position.bottom_right, 1, 2, bgcolor=color.new(ink, 100), border_width=0)
if barstate.islast
    f_clearDrawings()
    int displayIndex = barstate.isconfirmed ? bar_index : math.max(0, bar_index - 1)
    float presentationATR = nz(currentATR, syminfo.mintick * 10)
    array<int> selected = f_selectPatterns(patterns, displayIndex, viewMode == "Stories" ? storiesPatternLimit : 3, minQuality)
    f_renderPatterns(patterns, selected, displayIndex)
    f_renderTrendline(swings, displayIndex)
    if showLevels
        f_renderLevel(previousWeekHigh, annotationStyle == "Editorial" ? "WEEKLY RESISTANCE" : "PREV WEEK HIGH", math.max(weekAvailableFrom, displayIndex - 100), displayIndex, true, presentationATR)
    if showZones
        if zoneSource == "4H"
            if not na(sharedZones)
                f_renderZones(sharedZones.stored, displayIndex, viewMode == "Stories" ? 4 : 8, sharedZones.sourceIndex, sharedZones.referencePrice, sharedZones.referenceATR, true)
        else
            f_renderZones(zones, displayIndex, viewMode == "Stories" ? 4 : 8)
    f_renderStructure(swings, events, displayIndex, presentationATR)
    if showLevels
        int weekStart = math.max(weekAvailableFrom, displayIndex - 100)
        int monthStart = math.max(monthAvailableFrom, displayIndex - 100)
        f_renderLevel(previousWeekLow, "PREV WEEK LOW", weekStart, displayIndex, false, presentationATR)
        f_renderLevel(previousWeekMid, "PREV WEEK MID", weekStart, displayIndex, false, presentationATR, true)
        f_renderLevel(previousMonthMid, "PREV MONTH MID", monthStart, displayIndex, false, presentationATR)
        f_renderLevel(monthlyOpen, "MONTHLY OPEN", monthStart, displayIndex, true, presentationATR)
    if showEMA200
        float confirmedEMA = ema200[bar_index - displayIndex]
        f_placeText(displayIndex + 10, confirmedEMA, "EMA 200", emaColor, presentationATR, 1, text.align_right, false, 55)
    f_flushText()
    [displayTrend, displayHigh, displayLow] = f_marketStructure(swings, presentationATR)
    string title = showBrand ? "PATTERN STRUCTURE PRO" : ""
    string note = showBrand ? syminfo.ticker + "  ·  " + intervalName : ""
    if not supportedInterval
        note += "\nSupported: 1H · 2H · 4H · 1D"
    else if viewMode == "Analysis"
        note += "\nConfirmed swings · " + str.tostring(swingStrength) + " bars (" + swingDelay + ") · " + displayTrend
    if viewMode == "Analysis" and showZones
        note += "\nZones · " + (zoneSource == "4H" ? "4H confirmed" : intervalName)
    if not chart.is_standard
        note += "\nSynthetic candles change geometry"
    if viewMode == "Analysis" and timeframe.in_seconds() > timeframe.in_seconds("W")
        note += "\nWeekly layer unavailable on this interval"
    if viewMode == "Analysis" and timeframe.in_seconds() > timeframe.in_seconds("M")
        note += "\nMonthly layer unavailable on this interval"
    table.cell(signature, 0, 0, title, text_color=color.new(ink, 18), text_size=size.small, text_halign=text.align_right)
    table.cell(signature, 0, 1, note, text_color=color.new(ink, 40), text_size=size.tiny, text_halign=text.align_right)

plot(showEMA200 and barstate.isconfirmed ? ema200 : na, title="EMA 200", color=color.new(emaColor, 15), linewidth=1, style=plot.style_linebr, display=display.pane + display.data_window)
````
