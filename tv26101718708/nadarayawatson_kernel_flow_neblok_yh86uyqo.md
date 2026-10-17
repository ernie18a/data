# Nadaraya-Watson Kernel Flow [NeBlok]

- url: https://www.tradingview.com/script/yH86uYqo-Nadaraya-Watson-Kernel-Flow-NeBlok/
- type: indicator
- pine_id: PUB;c51d5386db444a52a44ad245141fbb42
- version: 1.0

## Description

NADARAYA-WATSON KERNEL FLOW [NeBlok]

OVERVIEW
Nadaraya-Watson Kernel Flow is a non-repainting trend and envelope tool built on Nadaraya-Watson kernel regression, a statistical smoothing method from 1964. Instead of weighting bars equally (SMA) or by a fixed decay (EMA), a kernel assigns each past bar a weight based on its distance from the current bar using a chosen mathematical curve. The result is a smooth estimate of price with a shape you control.

This is an original implementation written from the underlying math. On top of the core estimator it adds four kernel types, a lag-compensation engine, a hysteresis trend filter, slope-strength coloring, envelope rejection signals, a live dashboard, and depth-style rendering.


WHAT REPAINTS AND WHAT DOES NOT
Many Nadaraya-Watson scripts show a curve that looks perfect on historical bars because each point is calculated using bars that came AFTER it. In real time, those turning points did not exist yet.

In this script:
- The kernel line, envelope, trend state, signals, alerts and dashboard are NON-REPAINTING. Every value uses only the current bar and bars before it.
- Signals are confirmed on bar close. A signal that prints on a closed bar stays there.
- The optional Hindsight Curve (off by default) DOES repaint. It is drawn as a dotted purple line labeled "HINDSIGHT · REPAINTS" and is for visual context only. No signal or alert is generated from it. Do not trade its turning points.

Because the live line only uses past data, it will lag more than a repainting curve. That trade-off is intentional. Lag Compensation (below) is provided to reduce it.


HOW IT WORKS
1. Kernel estimate: each of the last N bars is weighted by the selected kernel based on its distance from the current bar, and the weighted average becomes the kernel line.
2. Lag compensation: the kernel is run a second time on its own output, and the difference between the two passes is added back (similar in concept to how DEMA reduces lag). This speeds up turns at the cost of some overshoot.
3. Envelope: bands are placed above and below the line using either the average distance of price from the kernel line (Kernel MAE) or ATR, multiplied by your chosen width.
4. Trend state: the slope of the kernel line is measured in ATRs per bar. The trend only flips when the slope exceeds your threshold in the new direction. This hysteresis filter reduces back-and-forth flips when the line goes flat.


READING THE CHART
- Kernel line color: teal = bullish, pink = bearish. The line fades toward grey as the slope flattens, so a dimming line means the trend is losing strength before it flips.
- Neon Tube style: the envelope is shaded brightest at the kernel line and fades toward the band edges.
- Ribbon style: a ribbon is filled between the kernel line and a lagged copy of itself. Ribbon thickness reflects momentum, and the ribbon twists when direction changes.
- Minimal style: plain line and bands.
- ▲ / ▼ labels: trend flip signals (bar-close confirmed).
- Small circles: envelope rejections. Price closed outside the envelope, then closed back inside on the next bar.


DASHBOARD
- Trend: current trend state (Bullish / Bearish / Neutral).
- Slope: kernel slope in ATRs per bar.
- Strength: slope as a percentage of the "full color" slope setting.
- Dist. from line: how far price is from the kernel line, in ATRs.
- Envelope pos.: where price sits inside the envelope. 0% = lower band, 100% = upper band. Above 80% is colored bearish, below 20% bullish, to flag stretched conditions.
- Mode: confirms whether you're viewing live values only or live plus the repainting Hindsight Curve.


HOW TO USE IT
Trend following:
- Use the kernel line color and trend state as directional bias. Look for longs while bullish, shorts while bearish.
- A flip signal marks a change in bias, not an automatic entry. Many traders wait for a pullback toward the kernel line in the new direction.
- A fading (greying) line during an established trend is an early warning that momentum is stalling.

Mean reversion:
- Envelope rejections show where price stretched beyond its typical distance from the kernel line and then snapped back inside.
- Rejections in the direction of the trend (a bullish rejection off the lower band while the trend is bullish) are generally higher-context than rejections against it.
- Envelope pos. above 80% or below 20% indicates price is stretched relative to recent behavior.

Combining:
- The kernel line works well as a bias filter for other entry tools. Only take signals from your system that agree with the kernel trend.
- Dist. from line helps avoid chasing. Entries several ATRs away from the line carry more reversion risk.


SETTINGS GUIDE
Kernel Engine
- Kernel: Gaussian (smooth, classic), Rational Quadratic (fatter tails, more weight on older bars), Epanechnikov (statistically efficient, hard cutoff at 3× bandwidth), Laplace (sharpest and most responsive, also noisiest).
- Bandwidth (h): how many bars the kernel looks across. Higher = smoother and slower.
- RQ Alpha: Rational Quadratic only. Lower values = fatter tails.
- Lookback Window: maximum bars included per estimate.
- Lag Compensation: 0 = pure Nadaraya-Watson, 1 = maximum lag reduction with more overshoot. Default 0.5.

Envelope
- Width Source: Kernel MAE or ATR.
- Width Length / Width Multiplier: how the band width is averaged and scaled.

Signals
- Min Slope to Flip: the hysteresis threshold in ATRs per bar. Raise it to reduce flips in choppy markets; set to 0 to flip on any slope change.
- ATR Length: used for slope normalization, the dashboard, and ATR envelope mode.

Visuals
- Render Style, colors, slope needed for full color intensity, ribbon depth, and optional trend-colored candles.

Suggested starting points (not optimized — test on your own market and timeframe):
- Intraday futures (1–5 min): Bandwidth 6–10, Min Slope to Flip 0.02–0.04.
- Swing (1H–Daily): Bandwidth 8–14, Width Multiplier 2.5–3.0.


ALERTS
Two ways to set alerts:
1. Create one alert and choose "Any alert() function call" to receive all four events (bull flip, bear flip, bull rejection, bear rejection) with ticker, timeframe and price in the message.
2. Or choose individual conditions (Bull Flip, Bear Flip, Bull Envelope Rejection, Bear Envelope Rejection) to receive only the events you want.
Use one method or the other, not both, to avoid duplicate notifications. All alerts fire once per bar close.


LIMITATIONS
- Kernel regression is a smoothing method. It describes what price has done; it does not predict what price will do.
- The live line lags turning points. Lag Compensation reduces this but also introduces overshoot.
- In tight, sideways markets, flips and rejections become less reliable. Raise Min Slope to Flip or use a higher timeframe for context.
- Very high Lookback and Hindsight settings increase calculation load and may slow the script on long histories.


DISCLAIMER
This script is provided free for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any security, futures contract, or other financial instrument. Trading involves substantial risk of loss and is not suitable for every investor. Past performance, whether actual or indicated by historical signals, does not guarantee future results. Signals shown on historical bars do not account for slippage, commissions, or execution conditions. You are solely responsible for your own trading decisions. Always do your own research and consider consulting a licensed financial professional before trading.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeBlok

//@version=6
// ============================================================================
//  Nadaraya-Watson Kernel Flow [NeBlok]
//  © NeBlok Edge — free and open-source
//
//  Original implementation of Nadaraya-Watson kernel regression
//  (Nadaraya 1964 / Watson 1964 — a public statistical method).
//
//  WHAT REPAINTS AND WHAT DOESN'T
//  • Kernel line, envelope, trend state, signals, alerts, dashboard:
//    NON-REPAINTING. Each bar only uses that bar and bars before it.
//  • "Hindsight Curve" (off by default): a centered kernel that uses bars on
//    BOTH sides of each point. It looks perfect on history because it sees the
//    future, and it redraws every bar. Visual context only — nothing in this
//    script generates a signal or alert from it.
//
//  WHAT'S DIFFERENT FROM A STANDARD NW SMOOTHER
//  • 4 kernels (Gaussian, Rational Quadratic, Epanechnikov, Laplace)
//  • Lag compensation: second kernel pass, out = NW + k·(NW − NW(NW))
//  • Hysteresis trend filter (slope must exceed x ATR to flip) to cut chop
//  • Slope-strength color intensity (normalized by ATR)
//  • Neon-tube / ribbon depth rendering, live dashboard
// ============================================================================
indicator("Nadaraya-Watson Kernel Flow [NeBlok]", shorttitle = "NW Flow [NeBlok]", overlay = true, max_bars_back = 1000, max_labels_count = 500, max_polylines_count = 10)

// ─── Groups ─────────────────────────────────────────────────────────────────
const string G_CORE = "Kernel Engine"
const string G_BAND = "Envelope"
const string G_SIG  = "Signals"
const string G_VIS  = "Visuals"
const string G_HIND = "Hindsight Curve (REPAINTS — visual only)"
const string G_DASH = "Dashboard"

// ─── Inputs: Kernel Engine ──────────────────────────────────────────────────
src        = input.source(close, "Source", group = G_CORE)
kernelType = input.string("Gaussian", "Kernel", options = ["Gaussian", "Rational Quadratic", "Epanechnikov", "Laplace"], group = G_CORE, tooltip = "Gaussian: smooth, classic.\nRational Quadratic: Gaussian with fatter tails (more weight on older bars).\nEpanechnikov: statistically MSE-optimal, hard cutoff at 3×h bars.\nLaplace: sharp peak, most responsive, noisiest.")
bandwidth  = input.float(8.0, "Bandwidth (h)", minval = 1.0, step = 0.5, group = G_CORE, tooltip = "How many bars the kernel 'looks across'. Higher = smoother and more lag.")
rqAlpha    = input.float(1.0, "RQ Alpha", minval = 0.1, step = 0.1, group = G_CORE, tooltip = "Rational Quadratic only. Lower = fatter tails. Very high values behave like Gaussian.")
lookback   = input.int(150, "Lookback Window (bars)", minval = 10, maxval = 500, group = G_CORE, tooltip = "Max bars summed per estimate. Gaussian weights are ~0 beyond 4×h, so this mostly matters for Rational Quadratic.")
lagComp    = input.float(0.5, "Lag Compensation", minval = 0.0, maxval = 1.0, step = 0.05, group = G_CORE, tooltip = "Runs the kernel twice and extrapolates: out = NW + k·(NW − NW(NW)).\n0 = pure Nadaraya-Watson (most lag).\n1 = full compensation (fastest turns, more overshoot).")

// ─── Inputs: Envelope ───────────────────────────────────────────────────────
showBand = input.bool(true, "Show Envelope", group = G_BAND)
bandMode = input.string("Kernel MAE", "Width Source", options = ["Kernel MAE", "ATR"], group = G_BAND, tooltip = "Kernel MAE: average absolute distance of price from the kernel line.\nATR: average true range.")
bandLen  = input.int(100, "Width Length", minval = 5, maxval = 500, group = G_BAND)
bandMult = input.float(2.5, "Width Multiplier", minval = 0.1, step = 0.1, group = G_BAND)

// ─── Inputs: Signals ────────────────────────────────────────────────────────
showFlips   = input.bool(true, "Trend Flip Signals", group = G_SIG)
showRejects = input.bool(true, "Envelope Rejection Signals", group = G_SIG, tooltip = "Price closes outside the envelope, then closes back inside on the next bar.")
flipFilter  = input.float(0.02, "Min Slope to Flip (× ATR per bar)", minval = 0.0, step = 0.005, group = G_SIG, tooltip = "Hysteresis. The trend only flips when the kernel's slope exceeds this many ATRs per bar in the new direction. 0 = flip on any slope change (choppier).")
atrLen      = input.int(14, "ATR Length", minval = 1, group = G_SIG)

// ─── Inputs: Visuals ────────────────────────────────────────────────────────
visStyle  = input.string("Neon Tube", "Render Style", options = ["Neon Tube", "Ribbon", "Minimal"], group = G_VIS, tooltip = "Neon Tube: glowing core line + envelope shaded like a lit cylinder.\nRibbon: glowing line + momentum ribbon that twists on direction changes.\nMinimal: plain line and envelope.")
bullCol   = input.color(#00E5B0, "Bull", group = G_VIS, inline = "c")
bearCol   = input.color(#FF3D6E, "Bear", group = G_VIS, inline = "c")
neutCol   = input.color(#8A93A6, "Neutral", group = G_VIS, inline = "c")
slopeCap  = input.float(0.25, "Slope for Full Color (× ATR)", minval = 0.01, step = 0.01, group = G_VIS, tooltip = "Line color fades toward neutral as the slope flattens. At this slope it's full intensity.")
ribbonLag = input.int(3, "Ribbon Depth (bars)", minval = 1, maxval = 20, group = G_VIS)
colorBars = input.bool(false, "Color Candles by Trend", group = G_VIS)

// ─── Inputs: Hindsight ──────────────────────────────────────────────────────
showHind = input.bool(false, "Show Hindsight Curve", group = G_HIND, tooltip = "Centered kernel using future bars relative to each point. Redraws every bar. Its turning points did NOT exist in real time — never trade them.")
hindLen  = input.int(300, "Hindsight Bars", minval = 20, maxval = 499, group = G_HIND)
hindCol  = input.color(#C9A7FF, "Hindsight Color", group = G_HIND)

// ─── Inputs: Dashboard ──────────────────────────────────────────────────────
showDash = input.bool(true, "Show Dashboard", group = G_DASH)
dashPos  = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = G_DASH)

// ─── Kernel functions ───────────────────────────────────────────────────────
// Weight for a point d bars away. Constants are dropped: they cancel in num/den.
kernelWeight(float d, float h, string k, float a) =>
    float x = d / h
    float w = switch k
        "Gaussian"           => math.exp(-0.5 * x * x)
        "Rational Quadratic" => math.pow(1.0 + (x * x) / (2.0 * a), -a)
        // Support scaled to 3×h so bandwidth feels comparable across kernels
        "Epanechnikov"       => math.abs(x) < 3.0 ? 1.0 - math.pow(x / 3.0, 2) : 0.0
        "Laplace"            => math.exp(-math.abs(x))
        => math.exp(-0.5 * x * x)
    w

// Weights depend only on distance, so compute once
var array<float> weights = array.new<float>()
if barstate.isfirst
    for i = 0 to lookback - 1
        weights.push(kernelWeight(i, bandwidth, kernelType, rqAlpha))

// Endpoint (causal) Nadaraya-Watson estimate: uses bar 0 and older only
kernelSmooth(float s, array<float> wts, int len) =>
    float num = 0.0
    float den = 0.0
    int n = math.min(len, bar_index + 1)
    for i = 0 to n - 1
        float wi = wts.get(i)
        float si = s[i]
        if wi > 0.0 and not na(si)
            num += si * wi
            den += wi
    den > 0.0 ? num / den : s

// ─── Core calculation ───────────────────────────────────────────────────────
float nw1 = kernelSmooth(src, weights, lookback)
float nw2 = kernelSmooth(nw1, weights, lookback)
float nw  = nw1 + lagComp * (nw1 - nw2)

float atr  = ta.atr(atrLen)
float maeW = ta.sma(math.abs(src - nw), bandLen)
float dev  = (bandMode == "ATR" ? atr : maeW) * bandMult
float upper = nw + dev
float lower = nw - dev

// ─── Trend state with hysteresis ────────────────────────────────────────────
float slopeAtr = atr > 0 ? (nw - nw[1]) / atr : 0.0
var int trend = 0
if slopeAtr > flipFilter
    trend := 1
else if slopeAtr < -flipFilter
    trend := -1

bool bullFlip   = barstate.isconfirmed and trend == 1 and trend[1] == -1
bool bearFlip   = barstate.isconfirmed and trend == -1 and trend[1] == 1
bool bullReject = barstate.isconfirmed and close[1] < lower[1] and close > lower
bool bearReject = barstate.isconfirmed and close[1] > upper[1] and close < upper

// ─── Colors ─────────────────────────────────────────────────────────────────
float strength = math.min(math.abs(nz(slopeAtr)) / slopeCap, 1.0)
color dirCol   = trend == 1 ? bullCol : trend == -1 ? bearCol : neutCol
color lineCol  = color.from_gradient(strength, 0.0, 1.0, neutCol, dirCol)

bool isTube   = visStyle == "Neon Tube"
bool isRibbon = visStyle == "Ribbon"
bool glowOn   = visStyle != "Minimal"

// ─── Rendering ──────────────────────────────────────────────────────────────
// Glow layers first so the core line draws on top
plot(glowOn ? nw : na, "Glow Wide", color.new(lineCol, 88), 10, display = display.pane, editable = false)
plot(glowOn ? nw : na, "Glow Mid", color.new(lineCol, 72), 5, display = display.pane, editable = false)

pUp  = plot(showBand ? upper : na, "Upper Envelope", color.new(bearCol, 45), 1)
pLo  = plot(showBand ? lower : na, "Lower Envelope", color.new(bullCol, 45), 1)
pLag = plot(isRibbon ? nw[ribbonLag] : na, "Ribbon Anchor", color = na, editable = false, display = display.none)
pNW  = plot(nw, "Kernel Line", lineCol, 2)

// Neon Tube: brightest at the core, fading to the envelope edge (lit-cylinder look)
fill(pUp, pNW, top_value = upper, bottom_value = nw, top_color = isTube ? color.new(lineCol, 97) : na, bottom_color = isTube ? color.new(lineCol, 76) : na, title = "Tube Upper")
fill(pNW, pLo, top_value = nw, bottom_value = lower, top_color = isTube ? color.new(lineCol, 76) : na, bottom_color = isTube ? color.new(lineCol, 97) : na, title = "Tube Lower")

// Ribbon: fill between the line and its lagged self; thickness = momentum, twists on turns
fill(pNW, pLag, color = isRibbon ? color.new(dirCol, 45) : na, title = "Ribbon")

// Signals (bar-close confirmed)
plotshape(showFlips and bullFlip, "Bull Flip", style = shape.labelup, location = location.belowbar, color = bullCol, text = "▲", textcolor = #0B0F17, size = size.tiny)
plotshape(showFlips and bearFlip, "Bear Flip", style = shape.labeldown, location = location.abovebar, color = bearCol, text = "▼", textcolor = #0B0F17, size = size.tiny)
plotshape(showRejects and bullReject, "Bull Rejection", style = shape.circle, location = location.belowbar, color = color.new(bullCol, 20), size = size.tiny)
plotshape(showRejects and bearReject, "Bear Rejection", style = shape.circle, location = location.abovebar, color = color.new(bearCol, 20), size = size.tiny)

barcolor(colorBars ? dirCol : na)

// ─── Hindsight curve (REPAINTS — drawn on last bar only, no signals) ────────
var polyline hindPoly = na
var label    hindLbl  = na
if barstate.islast and showHind
    hindPoly.delete()
    hindLbl.delete()
    int n = math.min(hindLen, bar_index + 1)
    array<float> hw = array.new<float>(n, 0.0)
    for d = 0 to n - 1
        hw.set(d, kernelWeight(d, bandwidth, kernelType, rqAlpha))
    array<chart.point> pts = array.new<chart.point>()
    for j = 0 to n - 1
        float num = 0.0
        float den = 0.0
        for i = 0 to n - 1
            float wi = hw.get(math.abs(j - i))
            num += src[i] * wi
            den += wi
        pts.push(chart.point.from_index(bar_index - j, den > 0 ? num / den : src[j]))
    hindPoly := polyline.new(pts, curved = true, line_color = hindCol, line_style = line.style_dotted, line_width = 2)
    hindLbl  := label.new(bar_index, pts.first().price, "HINDSIGHT · REPAINTS", style = label.style_label_left, color = color.new(hindCol, 80), textcolor = hindCol, size = size.small)

// ─── Dashboard ──────────────────────────────────────────────────────────────
string tablePos = switch dashPos
    "Top Right"    => position.top_right
    "Bottom Right" => position.bottom_right
    "Top Left"     => position.top_left
    => position.bottom_left

var table dash = table.new(tablePos, 2, 7, bgcolor = color.new(#0B0F17, 8), border_color = color.new(#2A3142, 0), border_width = 1, frame_color = color.new(#2A3142, 0), frame_width = 1)

dashRow(table t, int r, string k, string v, color vc) =>
    t.cell(0, r, k, text_color = #AEB6C8, text_size = size.small, text_halign = text.align_left)
    t.cell(1, r, v, text_color = vc, text_size = size.small, text_halign = text.align_right)

if barstate.isfirst and showDash
    dash.merge_cells(0, 0, 1, 0)

if barstate.islast and showDash
    float distAtr = atr > 0 ? (close - nw) / atr : na
    float bandPos = dev > 0 ? (close - lower) / (upper - lower) * 100.0 : na
    string trendTxt = trend == 1 ? "BULLISH" : trend == -1 ? "BEARISH" : "NEUTRAL"

    dash.cell(0, 0, "NW KERNEL FLOW [NeBlok]", text_color = #0B0F17, bgcolor = dirCol, text_size = size.small)
    dashRow(dash, 1, "Trend", trendTxt, dirCol)
    dashRow(dash, 2, "Slope", str.tostring(nz(slopeAtr), "#.###") + " ATR/bar", lineCol)
    dashRow(dash, 3, "Strength", str.tostring(strength * 100.0, "#") + "%", lineCol)
    dashRow(dash, 4, "Dist. from line", str.tostring(distAtr, "#.##") + " ATR", distAtr > 0 ? bullCol : bearCol)
    dashRow(dash, 5, "Envelope pos.", str.tostring(bandPos, "#") + "%", bandPos > 80 ? bearCol : bandPos < 20 ? bullCol : #E6E9F0)
    dashRow(dash, 6, "Mode", showHind ? "Live + Hindsight*" : "Live · no repaint", showHind ? hindCol : #E6E9F0)

// ─── Alerts ─────────────────────────────────────────────────────────────────
// Built-in alerts: create ONE alert on "Any alert() function call"
if bullFlip
    alert("NW Flow [NeBlok] BULL FLIP on " + syminfo.ticker + " " + timeframe.period + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if bearFlip
    alert("NW Flow [NeBlok] BEAR FLIP on " + syminfo.ticker + " " + timeframe.period + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if bullReject
    alert("NW Flow [NeBlok] BULL envelope rejection on " + syminfo.ticker + " " + timeframe.period + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if bearReject
    alert("NW Flow [NeBlok] BEAR envelope rejection on " + syminfo.ticker + " " + timeframe.period + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

// Individual alert conditions (for users who want them separately)
alertcondition(bullFlip, "Bull Flip", "NW Flow [NeBlok]: bullish flip on {{ticker}} {{interval}} @ {{close}}")
alertcondition(bearFlip, "Bear Flip", "NW Flow [NeBlok]: bearish flip on {{ticker}} {{interval}} @ {{close}}")
alertcondition(bullReject, "Bull Envelope Rejection", "NW Flow [NeBlok]: bullish envelope rejection on {{ticker}} {{interval}} @ {{close}}")
alertcondition(bearReject, "Bear Envelope Rejection", "NW Flow [NeBlok]: bearish envelope rejection on {{ticker}} {{interval}} @ {{close}}")
````
