# PDC - Polynomial Direction Channel

- url: https://www.tradingview.com/script/kPbQzpWl-PDC-Polynomial-Direction-Channel/
- type: indicator
- pine_id: PUB;ccf30ad23e464b6c92f02617798354d9
- version: 1.0

## Description

PDC - Polynomial Direction Channel is a clean trend-direction tool that aims to see a turn a little earlier. Main timeframe: 1H.

WHAT IT IS
PDC answers one question: which way is the market moving right now? No entries, targets or stops. Just a smooth projection line, an adaptive channel and a clear marker (with price) where the direction flips. It is the companion to CKD (Conformal Kernel Direction), built for faster charts.

HOW IT WORKS
1. Curved projection. On every bar PDC fits a smooth curve (a least-squares parabola, Savitzky-Golay style) through the last 50 closed candles and extends it one bar ahead. A moving average only knows the slope; a curve also sees acceleration, so it notices a turn earlier.
2. Self-calibrating channel (conformal prediction). PDC tracks how far price strayed from its own projection over the last 150 candles and sizes the channel from those errors. Nothing is hand-set: the channel widens in volatile markets and tightens in calm ones.
3. Direction flips. The direction changes only when a candle CLOSES outside the channel on the opposite side. Noise inside the channel is ignored, so sideways markets don't cause constant flipping.

TWO MODES
- Balanced (default): 50-bar curve. Calm, with very few quick reversals.
- Fast: 40-bar curve. Turns a little earlier, with slightly more quick reversals.
Switch anytime in Settings > Direction model > Mode.

WHY 1H
In our comparison across ETH, BTC and SOL on 1H, 4H and 1D, PDC reacted earlier than CKD in most cases and was clearest on 1H, where it was both earlier and calmer on all three pairs. Other timeframes work; for 4H, CKD may suit you better. Settings were chosen on that same data, so treat these as observations, not guarantees.

CHARACTERISTICS
- Direction and flip markers are evaluated on confirmed (closed) candles.
- The projection for each bar uses only previous closes, so the line does not move while a candle forms.
- The channel is calibrated only from errors of earlier, closed candles.
- Uses only the chart's own symbol and timeframe; no higher-timeframe requests.
- Early history depends on how much data the chart loads; after the first flip the direction is consistent.
- Works on any symbol; label prices use the symbol's own tick precision.

HOW TO READ IT
- Cyan = direction up, magenta = direction down (the colour blends smoothly on change).
- UP / DOWN + price = the confirmed candle where the direction flipped and its closing price.
- Wide channel = volatile market, narrow channel = calm market.
- Alerts: Direction up, Direction down, Any flip. Use "Once Per Bar Close".

IMPORTANT
PDC shows direction; it is not a complete trading system and does not guarantee profits. Use it as context together with your own analysis and risk management. Not financial advice.

THANK YOU
A big thank you to everyone who used, liked, commented on and shared CKD. Your engagement and kind words are the reason PDC exists. Feedback and ideas are always welcome in the comments!

(c) 2026 builtbyuba. Licensed under CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/).

## Source Code

````pine
//@version=6
// © 2026 builtbyuba · PDC v1.0 — POLYNOMIAL DIRECTION CHANNEL
// SPDX-License-Identifier: CC-BY-NC-SA-4.0
// Licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.
// https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// A direction indicator, not a trading system. No entries, stops or targets.
// 1. A least-squares parabola (Savitzky-Golay style) is fitted to the last N
//    closed candles and extended one bar ahead. A parabola sees curvature,
//    so it notices a turn earlier than an average does.
// 2. A split-conformal channel is sized from the projection's OWN past errors
//    (closed bars only), so its width adapts to the market by itself.
// 3. Direction flips only when a candle CLOSES outside that channel on the
//    opposite side.
// Evaluated on closed bars; uses only the chart's own symbol and timeframe.
// Default settings are designed for 1H. Not financial advice.
indicator("PDC · Polynomial Direction Channel", "PDC", overlay = true, max_bars_back = 500, max_labels_count = 200)

// ───────────────────────── Inputs
string G_MODEL = "Direction model"
string G_STYLE = "Style"
string mode = input.string("Balanced", "Mode", options = ["Balanced", "Fast"], group = G_MODEL, display = display.none, tooltip = "Balanced (default): 50-bar curve, calmer with very few quick reversals. Fast: 40-bar curve, turns a little earlier at the cost of slightly more quick reversals.")
int calWindow = input.int(150, "Calibration window (closed bars)", minval = 50, maxval = 400, group = G_MODEL, display = display.none)
color bullColor = input.color(#22D3EE, "Up", group = G_STYLE, inline = "c", display = display.none)
color bearColor = input.color(#E879F9, "Down", group = G_STYLE, inline = "c", display = display.none)
color neutralColor = input.color(#64748B, "Neutral", group = G_STYLE, inline = "c", display = display.none)
int fadeBars = input.int(4, "Color transition (bars)", minval = 1, maxval = 12, group = G_STYLE, display = display.none)
int channelTransp = input.int(88, "Channel transparency", minval = 50, maxval = 100, group = G_STYLE, display = display.none)
bool showChannel = input.bool(true, "Show channel", group = G_STYLE, display = display.none)
bool paintCandles = input.bool(true, "Color candles", group = G_STYLE, display = display.none)
bool showFlips = input.bool(true, "Show direction flips", group = G_STYLE, display = display.none)

if barstate.isfirst and not chart.is_standard
    runtime.error("Use standard candles. Heikin Ashi, Renko and similar charts change the inputs.")

bool fastMode = mode == "Fast"
int fitLength = fastMode ? 40 : 50
float alpha = fastMode ? 0.08 : 0.06

// ───────────────────────── Projection weights (computed once)
// Quadratic least squares on x = -1 … -N, evaluated at x = 0 (the next bar).
var array<float> weights = array.new<float>()
if barstate.isfirst
    float s0 = 0.0
    float s1 = 0.0
    float s2 = 0.0
    float s3 = 0.0
    float s4 = 0.0
    for j = 1 to fitLength
        float x = -j
        s0 += 1.0
        s1 += x
        s2 += x * x
        s3 += x * x * x
        s4 += x * x * x * x
    matrix<float> A = matrix.new<float>(3, 3, 0.0)
    A.set(0, 0, s0)
    A.set(0, 1, s1)
    A.set(0, 2, s2)
    A.set(1, 0, s1)
    A.set(1, 1, s2)
    A.set(1, 2, s3)
    A.set(2, 0, s2)
    A.set(2, 1, s3)
    A.set(2, 2, s4)
    matrix<float> Ai = A.inv()
    for j = 1 to fitLength
        float x = -j
        weights.push(Ai.get(0, 0) + Ai.get(0, 1) * x + Ai.get(0, 2) * x * x)

f_quantile(array<float> source, float a) =>
    array<float> mags = array.new<float>()
    for e in source
        mags.push(math.abs(e))
    mags.sort(order.ascending)
    int size = mags.size()
    mags.get(math.min(size - 1, int(math.ceil((1.0 - a) * (size + 1))) - 1))

// Projection for THIS bar uses only the previous fitLength closes.
float forecast = na
if bar_index >= fitLength
    float acc = 0.0
    for j = 1 to fitLength
        acc += weights.get(j - 1) * close[j]
    forecast := acc
float residual = close - forecast

// ───────────────────────── Direction (closed bars only)
var array<float> errors = array.new<float>()
var float q = na
var int direction = 0
var int flipBar = na
bool flipUp = false
bool flipDown = false

if barstate.isconfirmed and not na(forecast)
    // Flip test uses q built from EARLIER errors only.
    if not na(q)
        if direction != 1 and residual > q
            direction := 1
            flipUp := true
            flipBar := bar_index
        else if direction != -1 and residual < -q
            direction := -1
            flipDown := true
            flipBar := bar_index
    errors.push(residual)
    if errors.size() > calWindow
        errors.shift()
    if errors.size() >= calWindow
        q := f_quantile(errors, alpha)

// ───────────────────────── Presentation (reads the model, never changes it)
color dirColor = direction == 1 ? bullColor : direction == -1 ? bearColor : neutralColor
int sinceFlip = na(flipBar) ? fadeBars : bar_index - flipBar
color lineColor = sinceFlip >= fadeBars ? dirColor : color.from_gradient(sinceFlip, 0, fadeBars, color.new(neutralColor, 0), dirColor)

// The curve is drawn from its value at the last closed bar; the channel is fixed at the bar's open.
float lineValue = forecast
float upper = forecast + q
float lower = forecast - q
plot(lineValue, "Glow outer", color = color.new(lineColor, 92), linewidth = 9, display = display.pane)
plot(lineValue, "Glow inner", color = color.new(lineColor, 80), linewidth = 5, display = display.pane)
pLine = plot(lineValue, "Projection", color = lineColor, linewidth = 2)
pUpper = plot(showChannel ? upper : na, "Channel upper", color = color.new(lineColor, 55), linewidth = 1)
pLower = plot(showChannel ? lower : na, "Channel lower", color = color.new(lineColor, 55), linewidth = 1)
pPrice = plot(close, "Price", display = display.none)
fill(pUpper, pLine, upper, lineValue, color.new(lineColor, 97), color.new(lineColor, channelTransp), "Upper channel")
fill(pLine, pLower, lineValue, lower, color.new(lineColor, channelTransp), color.new(lineColor, 97), "Lower channel")
fill(pLine, pPrice, lineValue, close, color.new(lineColor, 100), color.new(lineColor, 84), "Trend glow")

barcolor(paintCandles and direction != 0 ? color.new(dirColor, 0) : na, title = "Direction candles")

float atr = ta.atr(14)
if showFlips and flipUp
    label.new(bar_index, low - 0.4 * atr, "▲ UP  " + str.tostring(close, format.mintick), style = label.style_label_up, color = color.new(bullColor, 0), textcolor = #06121A, size = size.small, tooltip = "Direction → UP (confirmed close above channel).")
if showFlips and flipDown
    label.new(bar_index, high + 0.4 * atr, "▼ DOWN  " + str.tostring(close, format.mintick), style = label.style_label_down, color = color.new(bearColor, 0), textcolor = #1A0620, size = size.small, tooltip = "Direction → DOWN (confirmed close below channel).")

plot(direction, "Direction (1 up / -1 down)", display = display.data_window)

alertcondition(flipUp, "PDC · Direction up", "PDC | UP | {{ticker}} | {{interval}} | close={{close}}")
alertcondition(flipDown, "PDC · Direction down", "PDC | DOWN | {{ticker}} | {{interval}} | close={{close}}")
alertcondition(flipUp or flipDown, "PDC · Any flip", "PDC | FLIP | {{ticker}} | {{interval}} | close={{close}}")
````
