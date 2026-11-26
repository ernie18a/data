# Multi Trend Filter

- url: https://www.tradingview.com/script/9zuM1VTV/
- type: indicator
- pine_id: PUB;ef169ff141a74d80b15d961eeecaf026
- version: 1.0

## Description

Overview
Multi Trend Filter shows the market's underlying trend with a single, clean line. It uses the Daily timeframe as the base, then layers 4H and 30m confirmation on top, coloring the trend in three intuitive states: green / yellow / red. No matter which chart timeframe you view it on (15m, 1h, 4h, etc.), it stays consistent on the Daily basis, and a two-pass smoothing keeps the line smooth on any chart.

WHAT THE COLORS MEAN

Green (UPTREND): Uptrend confirmed.
Yellow (TRANSITION): Trend is shifting — awaiting confirmation.
Red (DOWNTREND): Downtrend confirmed.
HOW IT WORKS — 3-STAGE MULTI-TIMEFRAME CONFIRMATION
Set the broad direction with higher timeframes first, then confirm the entry with the lower timeframe last.

Daily (Base / Reference line) — the line drawn on the chart; the anchor of the larger trend.
4H (Primary confirmation) — when both the close and the 4H flow align above/below the Daily line, the base direction is set.
30m (Final confirmation) — in that base direction, once the candle body closes across the 30m line, the color is finalized:
Close closes ABOVE the 30m line → Green
Close closes BELOW the 30m line → Red
Yellow (Transition) is the period before both stages confirm — the 4H hasn't committed yet, or it has but the close hasn't cleared the 30m line. Once green/red is confirmed, the color ignores minor noise while the base holds (latch), so it won't flicker.

HOW TO READ IT

Green: uptrend intact. Look for pullback entries.
Red: downtrend intact. Look for bounce exits / stay aside.
Yellow: direction unclear; safer to wait until it confirms green/red.
Yellow to Green = bullish shift. Yellow to Red = bearish shift.
KEY SETTINGS

Trend Line — First / Second Smoothing Length: line smoothness and responsiveness.
Display Smoothing — Smooth Line, Smooth Strength: keeps the line smooth on any timeframe (higher = smoother, slightly more lag).
Confirmation Lines — Show 30m Line (Signal) / Show 4H Line (Base): reveal the lines used for confirmation.
Style — up/down/transition colors, line width, fill and transparency, trend label.
TIPS

Use it as a trend direction and shift filter, not a standalone trade signal.
Reliability increases when the trend color agrees with your own setup (support/resistance, volume, etc.).
If the line looks choppy, raise Smooth Strength.
DISCLAIMER
This indicator is a reference tool to help judge trend direction. It does not guarantee trading profits. All trading decisions and responsibility rest solely with the user.

## Source Code

````pine
//@version=6
indicator("Multi Trend Filter", shorttitle="Multi Trend Filter", overlay=true)

// ===== Trend line (smoothing) =====
len1 = input.int(30, "First Smoothing Length",  minval=1, group="Trend Line")
len2 = input.int(7,  "Second Smoothing Length", minval=1, group="Trend Line")

smoothOn     = input.bool(true, "Smooth Line", group="Display Smoothing")
smoothFactor = input.float(1.5, "Smooth Strength", minval=0.1, maxval=5.0, step=0.1, group="Display Smoothing")

// ===== Confirmation lines =====
show30m = input.bool(false, "Show 30m Line (Signal)", group="Confirmation Lines")
show4h  = input.bool(false, "Show 4H Line (Base)",    group="Confirmation Lines")

// ===== Style =====
upColor    = input.color(#26a69a, "Up Color (green)", group="Style")
downColor  = input.color(#ef5350, "Down Color (red)", group="Style")
noiseColor = input.color(color.yellow, "Transition Color (yellow)", group="Style")
lineWidth  = input.int(3, "Line Width", minval=1, maxval=8, group="Style")
showFill   = input.bool(true, "Fill (Close vs Line)", group="Style")
fillTransp = input.int(82, "Fill Transparency", minval=0, maxval=100, group="Style")
showLabel  = input.bool(true, "Show Trend Label", group="Style")

// ===== Engine: doubly-smoothed Heikin Ashi midline =====
calcFlow() =>
    float eo = ta.ema(open,  len1)
    float eh = ta.ema(high,  len1)
    float el = ta.ema(low,   len1)
    float ec = ta.ema(close, len1)
    var float haOpen = na
    float haClose = (eo + eh + el + ec) / 4
    haOpen := na(haOpen[1]) ? (eo + ec) / 2 : (haOpen[1] + haClose[1]) / 2
    float o2 = ta.ema(haOpen,  len2)
    float c2 = ta.ema(haClose, len2)
    (o2 + c2) / 2

// ===== Multi-timeframe sources: Daily(base) / 4H(primary) / 30m(signal) =====
dailyRaw = request.security(syminfo.tickerid, "D",   calcFlow(), lookahead=barmerge.lookahead_off)
h4Raw    = request.security(syminfo.tickerid, "240", calcFlow(), lookahead=barmerge.lookahead_off)
m30Raw   = request.security(syminfo.tickerid, "30",  calcFlow(), lookahead=barmerge.lookahead_off)

// ===== Step-line smoothing (2-pass EMA, chart-TF adaptive) =====
int dLen = math.max(1, math.min(300, int(timeframe.in_seconds("D")   / math.max(1.0, timeframe.in_seconds()) * smoothFactor)))
int hLen = math.max(1, math.min(300, int(timeframe.in_seconds("240") / math.max(1.0, timeframe.in_seconds()) * smoothFactor)))
int mLen = math.max(1, math.min(300, int(timeframe.in_seconds("30")  / math.max(1.0, timeframe.in_seconds()) * smoothFactor)))
float daily = smoothOn ? ta.ema(ta.ema(dailyRaw, dLen), dLen) : dailyRaw
float h4    = smoothOn ? ta.ema(ta.ema(h4Raw,    hLen), hLen) : h4Raw
float m30   = smoothOn ? ta.ema(ta.ema(m30Raw,   mLen), mLen) : m30Raw

// ===== Stage 1 (Base): Daily line + 4H alignment =====
bool closeAbove = close > daily
bool closeBelow = close < daily
bool h4Above    = h4 > daily
bool h4Below    = h4 < daily
int baseState = (closeAbove and h4Above) ? 1 : (closeBelow and h4Below) ? -1 : 0

// ===== Stage 2 (Signal): 30m body cross + trend latch =====
var int  trendState = 0
var bool confirmed  = false
if baseState == 0
    trendState := 0
    confirmed  := false
else if baseState == 1
    if trendState == 1 and confirmed
        trendState := 1
    else if close > m30
        trendState := 1
        confirmed  := true
    else
        trendState := 0
        confirmed  := false
else
    if trendState == -1 and confirmed
        trendState := -1
    else if close < m30
        trendState := -1
        confirmed  := true
    else
        trendState := 0
        confirmed  := false

color trendColor = trendState == 1 ? upColor : trendState == -1 ? downColor : noiseColor

// ===== Plot =====
trendP = plot(daily, "Trend Line", color=trendColor, linewidth=lineWidth)
closeP = plot(close, "Close Ref", color=na, editable=false, display=display.none)
fill(trendP, closeP, color=showFill ? color.new(trendColor, fillTransp) : na, title="Trend Fill")
plot(show30m ? m30 : na, "30m Line", color=color.new(color.gray, 20), linewidth=1)
plot(show4h  ? h4  : na, "4H Line",  color=color.new(color.blue, 30), linewidth=1)

// ===== Trend label =====
var label tLabel = na
if barstate.islast and showLabel
    if not na(tLabel)
        label.delete(tLabel)
    string txt = trendState == 1 ? "UPTREND" : trendState == -1 ? "DOWNTREND" : "TRANSITION"
    tLabel := label.new(bar_index + 2, daily, txt, style=label.style_label_left, color=trendColor, textcolor=color.black, size=size.normal)
````
