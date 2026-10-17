# Orion Regression Field [JOAT]

- url: https://www.tradingview.com/script/Gjjn03jQ-Orion-Regression-Field-JOAT/
- type: indicator
- pine_id: PUB;3d75c3444d7b48998b5a1c12ef3f5ba5
- version: 1.0

## Description

[b]Orion Regression Field [JOAT][/b]

[b]Introduction[/b]

Orion Regression Field builds a weighted regression valuation field with standard error bands, curvature options, compression detection, and reprice signals.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/k6XzIAnn/[/image]

[b]Core Concepts[/b]

[b]1. Weighted Regression[/b]

Recent bars can receive more influence while still preserving a full model window.

[b]2. Standard Error Bands[/b]

Inner and outer bands show statistical distance from the modeled path.

[b]3. Curvature and Confidence[/b]

Optional curvature and R2-style confidence control when the field is considered reliable.

[b]4. Pinch and Reprice[/b]

Compression and outer-band reactions create filtered reprice events.

[pine]
mid = weightedRegression(close, len); band = standardError * multiplier
[/pine]

[b]Features[/b]

[list]
[*]Weighted regression midline
[*]Inner and outer SEE bands
[*]Optional curvature
[*]Pinch shading and projection field
[*]Filtered reprice labels
[/list]

[b]Input Parameters[/b]

[list]
[*]Regression window and projection bars
[*]Curvature toggle and weight floor
[*]Minimum R2 confidence
[*]Inner and outer band multipliers
[*]Pinch ratio and cooldown
[/list]


[b]How to Use This Script[/b]

Use the field as statistical fair-value context. Outer band interaction means stretch, not automatic reversal.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

Orion is original in combining weighted regression, curvature, standard error fields, compression context, and filtered reprice logic.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Orion Regression Field [JOAT]", shorttitle="ORF [JOAT]", overlay=true, max_bars_back=1000, max_lines_count=240, max_labels_count=80, max_boxes_count=60)

// Orion Regression Field [JOAT]
// Original weighted log-regression field with adaptive polynomial confidence, SEE bands, and projection geometry.

string gModel = "Model"
string gBands = "Bands"
string gViz = "Visual System"
int len = input.int(80, "Regression window", minval=25, maxval=250, group=gModel)
int projBars = input.int(12, "Projection bars", minval=3, maxval=30, group=gModel)
bool useCubic = input.bool(true, "Allow cubic curvature", group=gModel)
float weightFloor = input.float(0.25, "Oldest weight floor", minval=0.05, maxval=1, step=0.05, group=gModel)
float minR2 = input.float(0.62, "Confidence gate R2", minval=0.1, maxval=0.99, step=0.01, group=gModel)
float outerMult = input.float(2.0, "Outer SEE multiplier", minval=0.5, maxval=5, step=0.1, group=gBands)
float innerMult = input.float(1.0, "Inner SEE multiplier", minval=0.2, maxval=3, step=0.1, group=gBands)
float pinchRatio = input.float(0.72, "Pinch width ratio", minval=0.25, maxval=0.95, step=0.01, group=gBands)
bool showProjection = input.bool(true, "Show projection field", group=gViz)
bool shadePinch = input.bool(true, "Shade pinch", group=gViz)
int signalCooldown = input.int(12, "Signal cooldown", minval=1, maxval=80, group=gViz)
bool showPanel = input.bool(true, "Show panel", group=gViz)

color C_BULL = #00e5ff
color C_BEAR = #ff00f2
color C_GOLD = #ffb300
color C_BG = #080a12
color C_TEXT = #ffffff
color C_MUTED = #607d8b

clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

poly(float a0, float a1, float a2, float a3, float t) =>
    a0 + a1 * t + a2 * t * t + a3 * t * t * t

velocity(float a1, float a2, float a3) =>
    a1 + 2.0 * a2 + 3.0 * a3

int deg = useCubic ? 3 : 2
int p = deg + 1
float m = math.max(len - 1, 1)
matrix<float> A = matrix.new<float>(p, p, 0.0)
matrix<float> B = matrix.new<float>(p, 1, 0.0)
float sumW = 0.0
float sumWY = 0.0
bool enough = bar_index >= len

if enough
    for r = 0 to p - 1
        for c = 0 to p - 1
            matrix.set(A, r, c, 0.0)
        matrix.set(B, r, 0, 0.0)
    for i = 0 to len - 1
        float t = (m - i) / m
        float y = math.log(math.max(close[i], syminfo.mintick))
        float w = weightFloor + (1.0 - weightFloor) * t
        sumW += w
        sumWY += w * y
        for r = 0 to p - 1
            float tr = math.pow(t, r)
            matrix.set(B, r, 0, matrix.get(B, r, 0) + w * y * tr)
            for c = 0 to p - 1
                matrix.set(A, r, c, matrix.get(A, r, c) + w * tr * math.pow(t, c))

matrix<float> beta = matrix.new<float>(p, 1, 0.0)
if enough
    matrix<float> invA = matrix.pinv(A)
    beta := matrix.mult(invA, B)
float a0 = enough ? matrix.get(beta, 0, 0) : na
float a1 = enough ? matrix.get(beta, 1, 0) : na
float a2 = enough ? matrix.get(beta, 2, 0) : na
float a3 = enough and useCubic ? matrix.get(beta, 3, 0) : 0.0
float meanY = sumW > 0 ? sumWY / sumW : na
float sse = 0.0
float sst = 0.0
if enough
    for i = 0 to len - 1
        float t = (m - i) / m
        float y = math.log(math.max(close[i], syminfo.mintick))
        float w = weightFloor + (1.0 - weightFloor) * t
        float yh = poly(a0, a1, a2, a3, t)
        sse += w * math.pow(y - yh, 2)
        sst += w * math.pow(y - meanY, 2)

float r2 = enough and sst > 0 ? clamp(1.0 - sse / sst, 0, 1) : na
float see = enough and sumW > p ? math.sqrt(sse / math.max(sumW - p, 1)) : na
float mid = enough ? math.exp(poly(a0, a1, a2, a3, 1.0)) : na
float outerUp = enough ? math.exp(poly(a0, a1, a2, a3, 1.0) + see * outerMult) : na
float outerDn = enough ? math.exp(poly(a0, a1, a2, a3, 1.0) - see * outerMult) : na
float innerUp = enough ? math.exp(poly(a0, a1, a2, a3, 1.0) + see * innerMult) : na
float innerDn = enough ? math.exp(poly(a0, a1, a2, a3, 1.0) - see * innerMult) : na
float vel = enough ? velocity(a1, a2, a3) : na
color theme = vel >= 0 ? C_BULL : C_BEAR
float widthNow = outerUp - outerDn
float widthBase = ta.sma(widthNow, 80)
bool pinch = enough and widthBase > 0 and widthNow / widthBase < pinchRatio
bool release = barstate.isconfirmed and pinch[1] and not pinch and r2 >= minR2
float residualZ = enough and see > 0 ? (math.log(math.max(close, syminfo.mintick)) - poly(a0, a1, a2, a3, 1.0)) / see : na
float curvature = enough ? a2 + 3.0 * a3 : na
bool longReversionRaw = barstate.isconfirmed and r2 >= minR2 and residualZ < -outerMult * 0.72 and vel > nz(vel[1]) and curvature >= nz(curvature[1], curvature)
bool shortReversionRaw = barstate.isconfirmed and r2 >= minR2 and residualZ > outerMult * 0.72 and vel < nz(vel[1]) and curvature <= nz(curvature[1], curvature)
bool longReleaseRaw = release and vel > 0
bool shortReleaseRaw = release and vel < 0
var int lastLongSignal = na
var int lastShortSignal = na
bool longSignal = (longReversionRaw or longReleaseRaw) and (na(lastLongSignal) or bar_index - lastLongSignal >= signalCooldown)
bool shortSignal = (shortReversionRaw or shortReleaseRaw) and (na(lastShortSignal) or bar_index - lastShortSignal >= signalCooldown)
if longSignal
    lastLongSignal := bar_index
if shortSignal
    lastShortSignal := bar_index

pMid = plot(mid, "ORF midline", color=color.new(theme, 8), linewidth=2)
pOuterUp = plot(outerUp, "ORF outer upper", color=color.new(theme, 55))
pOuterDn = plot(outerDn, "ORF outer lower", color=color.new(theme, 55))
pInnerUp = plot(innerUp, "ORF inner upper", color=color.new(theme, 72))
pInnerDn = plot(innerDn, "ORF inner lower", color=color.new(theme, 72))
fill(pOuterUp, pOuterDn, color=color.new(theme, 90), title="ORF outer field")
fill(pInnerUp, pInnerDn, color=color.new(theme, 84), title="ORF inner field")
bgcolor(shadePinch and pinch ? color.new(C_GOLD, 90) : na, title="ORF pinch shade")
plotshape(longSignal, "ORF bullish regression signal", shape.labelup, location.belowbar, color=color.new(C_BULL, 8), text="Reprice", textcolor=C_BG, size=size.tiny)
plotshape(shortSignal, "ORF bearish regression signal", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 8), text="Reprice", textcolor=C_TEXT, size=size.tiny)

var line[] projLines = array.new_line()
var linefill[] projFills = array.new_linefill()
if barstate.islast and showProjection and enough
    while array.size(projLines) > 0
        line.delete(array.pop(projLines))
    while array.size(projFills) > 0
        linefill.delete(array.pop(projFills))
    for i = 0 to projBars - 1
        float t1 = 1.0 + i / m
        float t2 = 1.0 + (i + 1) / m
        float widen1 = see * (1.0 + i * 0.04)
        float widen2 = see * (1.0 + (i + 1) * 0.04)
        float m1 = math.exp(poly(a0, a1, a2, a3, t1))
        float m2 = math.exp(poly(a0, a1, a2, a3, t2))
        float u1 = math.exp(poly(a0, a1, a2, a3, t1) + widen1 * outerMult)
        float u2 = math.exp(poly(a0, a1, a2, a3, t2) + widen2 * outerMult)
        float d1 = math.exp(poly(a0, a1, a2, a3, t1) - widen1 * outerMult)
        float d2 = math.exp(poly(a0, a1, a2, a3, t2) - widen2 * outerMult)
        line lu = line.new(bar_index + i, u1, bar_index + i + 1, u2, color=color.new(theme, 35), width=1)
        line ld = line.new(bar_index + i, d1, bar_index + i + 1, d2, color=color.new(theme, 35), width=1)
        line lm = line.new(bar_index + i, m1, bar_index + i + 1, m2, color=color.new(C_TEXT, 60), width=1, style=line.style_dotted)
        linefill lf = linefill.new(lu, ld, color.new(theme, 88))
        array.push(projLines, lu)
        array.push(projLines, ld)
        array.push(projLines, lm)
        array.push(projFills, lf)

var table panel = na
if showPanel and barstate.islast
    if na(panel)
        panel := table.new(position.top_right, 2, 7, bgcolor=color.new(C_BG, 5), border_color=color.new(C_TEXT, 82), border_width=1)
    table.cell(panel, 0, 0, "ORION", text_color=C_TEXT, bgcolor=color.new(theme, 72), text_size=size.small)
    table.cell(panel, 1, 0, "ORF", text_color=C_TEXT, bgcolor=color.new(theme, 72), text_size=size.small)
    table.cell(panel, 0, 1, "Degree", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 1, str.tostring(deg), text_color=C_TEXT, text_size=size.small)
    table.cell(panel, 0, 2, "R2", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 2, str.tostring(r2, "#.###"), text_color=r2 >= minR2 ? C_GOLD : C_MUTED, text_size=size.small)
    table.cell(panel, 0, 3, "Velocity", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 3, str.tostring(vel, "#.####"), text_color=theme, text_size=size.small)
    table.cell(panel, 0, 4, "SEE", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 4, str.tostring(see, "#.####"), text_color=C_TEXT, text_size=size.small)
    table.cell(panel, 0, 5, "Pinch", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 5, pinch ? "Active" : "None", text_color=pinch ? C_GOLD : C_MUTED, text_size=size.small)
    table.cell(panel, 0, 6, "Stretch", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 6, str.tostring(residualZ, "#.##") + "z", text_color=residualZ > 0 ? C_BEAR : C_BULL, text_size=size.small)

alertcondition(longSignal, "ORF Bull Signal [JOAT]", "Orion bullish regression reprice signal")
alertcondition(shortSignal, "ORF Bear Signal [JOAT]", "Orion bearish regression reprice signal")
````
