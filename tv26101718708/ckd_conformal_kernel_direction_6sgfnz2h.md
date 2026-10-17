# CKD - Conformal Kernel Direction

- url: https://www.tradingview.com/script/6SgfnZ2H-CKD-Conformal-Kernel-Direction/
- type: indicator
- pine_id: PUB;8d48bf62d4dd4d4a83480b6ce9159801
- version: 2.0

## Description

CKD - Conformal Kernel Direction is a clean trend-direction tool. Main timeframe: 4H.

WHAT IT IS
CKD answers one question: which way is the market moving right now? No entries, targets or stops. Just a smooth direction line, an adaptive channel and a clear marker (with price) where the direction flips.

HOW IT WORKS
1. Smooth line. Recent closes are averaged with a Gaussian kernel: the newest candles count most, older ones fade out. Much smoother than a regular moving average.
2. Less lag. The line is projected one bar forward from its own recent slope, so it reacts faster than a normal kernel or MA.
3. Self-calibrating channel (conformal prediction). CKD tracks how far price strayed from its own forecast over the last 150 candles and sizes the channel to hold about 90% of normal moves. Nothing is hand-set: the channel widens in volatile markets and tightens in calm ones.
4. Direction flips. The direction changes only when a candle CLOSES outside the channel on the opposite side. Noise inside the channel is ignored, so sideways markets don't cause constant flipping, while real breakouts are caught on the candle they happen.

WHY 4H
Default settings are tuned for 4H, where swings are clean and flips are rare enough to mean something. Other timeframes work, but treat them as experimental and adjust the settings.

CHARACTERISTICS
- Direction and flip markers are evaluated on confirmed (closed) candles.
- The channel is calibrated only from forecast errors of earlier, closed candles.
- Uses only the chart's own symbol and timeframe; no higher-timeframe requests.
- Early history depends on how much data the chart loads; after the first flip the direction is consistent.
- Works on any symbol; label prices use the symbol's own tick precision.

HOW TO READ IT
- Cyan = direction up, magenta = direction down (the colour blends smoothly on change).
- UP / DOWN + price = the confirmed candle where the direction flipped and its closing price.
- Wide channel = volatile market, narrow channel = calm market.
- Alerts: Direction up, Direction down, Any flip. Use "Once Per Bar Close".

SETTINGS
- Kernel lookback / bandwidth: smoothness of the line.
- Channel miscoverage alpha: lower = wider channel, fewer and later flips; higher = more sensitive.
- Colours, channel transparency, candle colouring and flip markers can all be changed or turned off.

IMPORTANT
The ~90% channel coverage is a statistical calibration target, NOT a win rate. CKD shows direction; it is not a complete trading system and does not guarantee profits. Use it as context together with your own analysis and risk management. Not financial advice.

(c) 2026 builtbyuba. Licensed under CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/).

## Source Code

````pine
//@version=6
// © 2026 builtbyuba · CKD v1.0 — CONFORMAL KERNEL DIRECTION
// SPDX-License-Identifier: CC-BY-NC-SA-4.0
// Licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.
// https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// A direction indicator, not a trading system. No entries, stops or targets.
// 1. A lag-compensated Gaussian kernel projects where price "should" close.
// 2. A split-conformal channel is sized from the kernel's OWN past forecast
//    errors (closed bars only), so its width adapts to the market by itself.
// 3. Direction flips only when a candle CLOSES outside that channel on the
//    opposite side — fast enough to react, wide enough to ignore noise.
// Evaluated on closed bars; uses only the chart's own symbol and timeframe.
// Default settings are designed for 4H. Not financial advice.
indicator("CKD · Conformal Kernel Direction", "CKD", overlay = true, max_bars_back = 500, max_labels_count = 200)

// ───────────────────────── Inputs
string G_MODEL = "Direction model"
string G_STYLE = "Style"
int kLength = input.int(40, "Kernel lookback", minval = 10, maxval = 150, group = G_MODEL, display = display.none)
float kBandwidth = input.float(8.0, "Kernel bandwidth", minval = 1.0, maxval = 40.0, step = 0.5, group = G_MODEL, display = display.none, tooltip = "Higher = smoother, slower line.")
float alpha = input.float(0.10, "Channel miscoverage α", minval = 0.02, maxval = 0.30, step = 0.01, group = G_MODEL, display = display.none, tooltip = "The channel is calibrated to contain about (1 − α) of closes. Lower α = wider channel = fewer, later flips. 0.10 → 90%. This is a calibration target, not accuracy.")
int calWindow = input.int(150, "Calibration window (closed bars)", minval = 50, maxval = 400, group = G_MODEL, display = display.none)
color bullColor = input.color(#22D3EE, "Up", group = G_STYLE, inline = "c", display = display.none)
color bearColor = input.color(#E879F9, "Down", group = G_STYLE, inline = "c", display = display.none)
color neutralColor = input.color(#64748B, "Neutral", group = G_STYLE, inline = "c", display = display.none)
int fadeBars = input.int(4, "Color transition (bars)", minval = 1, maxval = 12, group = G_STYLE, display = display.none, tooltip = "How many bars the line and channel take to blend into the new direction color.")
int channelTransp = input.int(88, "Channel transparency", minval = 50, maxval = 100, group = G_STYLE, display = display.none)
bool showChannel = input.bool(true, "Show channel", group = G_STYLE, display = display.none)
bool paintCandles = input.bool(true, "Color candles", group = G_STYLE, display = display.none)
bool showFlips = input.bool(true, "Show direction flips", group = G_STYLE, display = display.none)

if barstate.isfirst and not chart.is_standard
    runtime.error("Use standard candles. Heikin Ashi, Renko and similar charts change the inputs.")

// ───────────────────────── Model (closed bars only)
f_kernel(int length, float h) =>
    float weighted = 0.0
    float weights = 0.0
    bool complete = true
    for i = 0 to length - 1
        float price = close[i]
        if na(price)
            complete := false
        else
            float w = math.exp(-(i * i) / (2.0 * h * h))
            weighted += w * price
            weights += w
    complete ? weighted / weights : na

f_quantile(array<float> source, float a) =>
    array<float> mags = array.new<float>()
    for e in source
        mags.push(math.abs(e))
    mags.sort(order.ascending)
    int size = mags.size()
    mags.get(math.min(size - 1, int(math.ceil((1.0 - a) * (size + 1))) - 1))

float kernel = f_kernel(kLength, kBandwidth)
// Lag compensation: project the kernel one bar ahead from its last two closed values.
float forecast = 2.0 * kernel[1] - kernel[2]
float residual = close - forecast

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
    // Then store this bar's now-known error for the next bar.
    errors.push(residual)
    if errors.size() > calWindow
        errors.shift()
    if errors.size() >= calWindow
        q := f_quantile(errors, alpha)

// ───────────────────────── Presentation (reads the model, never changes it)
color dirColor = direction == 1 ? bullColor : direction == -1 ? bearColor : neutralColor
int sinceFlip = na(flipBar) ? fadeBars : bar_index - flipBar
// Smooth blend from the previous direction color into the new one.
color lineColor = sinceFlip >= fadeBars ? dirColor : color.from_gradient(sinceFlip, 0, fadeBars, color.new(neutralColor, 0), dirColor)

// Line and channel are frozen while the live candle forms.
float lineValue = barstate.isconfirmed ? kernel : kernel[1]
float upper = forecast + q
float lower = forecast - q
// Glow: two wide, faint copies of the line underneath the main line.
plot(lineValue, "Glow outer", color = color.new(lineColor, 92), linewidth = 9, display = display.pane)
plot(lineValue, "Glow inner", color = color.new(lineColor, 80), linewidth = 5, display = display.pane)
pLine = plot(lineValue, "Kernel", color = lineColor, linewidth = 2)
pUpper = plot(showChannel ? upper : na, "Channel upper", color = color.new(lineColor, 55), linewidth = 1)
pLower = plot(showChannel ? lower : na, "Channel lower", color = color.new(lineColor, 55), linewidth = 1)
pPrice = plot(close, "Price", display = display.none)
// Soft gradient: strongest at the kernel, fading toward the channel edges.
fill(pUpper, pLine, upper, lineValue, color.new(lineColor, 97), color.new(lineColor, channelTransp), "Upper channel")
fill(pLine, pLower, lineValue, lower, color.new(lineColor, channelTransp), color.new(lineColor, 97), "Lower channel")
// Glow between price and kernel in the trend direction.
fill(pLine, pPrice, lineValue, close, color.new(lineColor, 100), color.new(lineColor, 84), "Trend glow")

barcolor(paintCandles and direction != 0 ? color.new(dirColor, 0) : na, title = "Direction candles")

float atr = ta.atr(14)
if showFlips and flipUp
    label.new(bar_index, low - 0.4 * atr, "▲ UP  " + str.tostring(close, format.mintick), style = label.style_label_up, color = color.new(bullColor, 0), textcolor = #06121A, size = size.small, tooltip = "Direction → UP (confirmed close above channel).")
if showFlips and flipDown
    label.new(bar_index, high + 0.4 * atr, "▼ DOWN  " + str.tostring(close, format.mintick), style = label.style_label_down, color = color.new(bearColor, 0), textcolor = #1A0620, size = size.small, tooltip = "Direction → DOWN (confirmed close below channel).")

plot(direction, "Direction (1 up / -1 down)", display = display.data_window)

alertcondition(flipUp, "CKD · Direction up", "CKD | UP | {{ticker}} | {{interval}} | close={{close}}")
alertcondition(flipDown, "CKD · Direction down", "CKD | DOWN | {{ticker}} | {{interval}} | close={{close}}")
alertcondition(flipUp or flipDown, "CKD · Any flip", "CKD | FLIP | {{ticker}} | {{interval}} | close={{close}}")
````
