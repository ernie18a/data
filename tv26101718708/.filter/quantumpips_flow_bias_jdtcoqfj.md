# QuantumPips Flow Bias 

- url: https://www.tradingview.com/script/JdTcoQFj-QuantumPips-Flow-Bias/
- type: indicator
- pine_id: PUB;dea0cb74627746df80de3f3e0289d94a
- version: 1.0

## Description

QuantumPips Flow Bias (EMA + Volume Delta) 

QuantumPips Flow Bias is a visual market-bias tool that combines trend direction (EMA) with a simple volume-pressure proxy to help you read whether buyers or sellers have had more control over the most recent price action.

This indicator is not a signal generator by default, it’s designed to give you context and confirmation so you can align entries with stronger market conditions.

[b]1) What you see on the chart
Bull/Bear Flow Box[/b]

A large box is drawn using the last Lookback bars:

[list]
[*]Green area = bullish pressure
[*]Red area = bearish pressure
[*]The label shows the split as:
[*]Bull X% | Bear Y%
[/list]

This percentage is calculated using a volume delta proxy:

[list]
[*]If a candle closes up, its volume is treated as “bull volume”
[*]If a candle closes down, its volume is treated as “bear volume”
[*]Doji candles split volume 50/50
[/list]

It’s a proxy, not true exchange order flow, but it’s useful for quickly spotting whether volume has mostly supported buying or selling inside the lookback window.

[b]2) Trend Confirmation (EMA)[/b]

The indicator checks the trend using two EMAs:

[list]
[*]EMA Fast (default 50)
[*]EMA Slow (default 200)
[/list]
When fast EMA is above slow EMA → trend bias is bullish
When fast EMA is below slow EMA → trend bias is bearish

Optional: Require EMA Fast slope

If ON, the fast EMA must also be rising (bull) or falling (bear). This filters chop but may reduce early bias flips.

[b]3) Volume Delta Confirm (Proxy)[/b]

A second “pressure check” runs on a shorter window: Delta window (bars).

[list]
[*]If Bull% is above Bull threshold → bull flow confirmation
[*]If Bull% is below Bear threshold → bear flow confirmation
[/list]

Defaults:

Bull confirm if Bull% > 55%
Bear confirm if Bull% < 45%

[b]4) Bias logic (how “Bullish/Bearish/Neutral” is decided)
[/b]
The indicator only shows a strong bias when both conditions agree:

✅ Bullish = (EMA trend bullish) AND (flow bullish)
✅ Bearish = (EMA trend bearish) AND (flow bearish)
Otherwise → Neutral (mixed or choppy conditions)

[b]5) Projection line (dashed)
[/b]
The dashed line is a simple forward “roadmap” based on:

[list]
[*]ATR distance × multiplier
[*]Optionally scaled by flow strength
[/list]

This projection is best used as a reference area, not a target guarantee. It’s meant to help you visualize where price could reach if the bias continues.

## Source Code

````pine
//@version=6
indicator("QuantumPips Flow Bias (EMA + Volume Delta)", shorttitle="QP FLOW BIAS", overlay=true, max_boxes_count=20, max_labels_count=50, max_lines_count=50)

//────────────────────────────────────────────
// Inputs
//────────────────────────────────────────────
grpFlow = "Flow Box (Bull vs Bear)"
lookback      = input.int(120, "Lookback bars", minval=20, group=grpFlow)
boxOpacity    = input.int(85, "Box opacity (0-100)", minval=0, maxval=100, group=grpFlow)
showFlowBox   = input.bool(true, "Show Bull/Bear Flow Box", group=grpFlow)

grpDelta = "Volume Delta (Proxy)"
deltaLen     = input.int(50, "Delta window (bars)", minval=10, group=grpDelta)
bullThresh   = input.float(55.0, "Bull confirm if Bull% >", step=0.5, group=grpDelta)
bearThresh   = input.float(45.0, "Bear confirm if Bull% <", step=0.5, group=grpDelta)

grpTrend = "Trend Confirmation (EMA)"
emaFastLen   = input.int(50, "EMA Fast", minval=1, group=grpTrend)
emaSlowLen   = input.int(200, "EMA Slow", minval=1, group=grpTrend)
useSlope     = input.bool(false, "Require EMA Fast slope", group=grpTrend)

grpTF = "Timeframe Dots (EMA + Delta)"
tf1 = input.timeframe("1",  "Dot TF1", group=grpTF)
tf2 = input.timeframe("5",  "Dot TF2", group=grpTF)
tf3 = input.timeframe("15", "Dot TF3", group=grpTF)
tf4 = input.timeframe("60", "Dot TF4", group=grpTF)

grpVol = "Volume"
rvolLen = input.int(50, "RVOL length", minval=10, group=grpVol)

grpUI = "UI"
showPanel = input.bool(true, "Show top-right stats panel", group=grpUI)
showDots  = input.bool(true, "Show bottom TF dots", group=grpUI)

// ─────────────────────────────
// Projection settings
// ─────────────────────────────
grpProj = "Projection"
showProjection   = input.bool(true, "Show bias projection", group=grpProj)
projBarsForward  = input.int(30, "Projection length (bars)", minval=5, maxval=500, group=grpProj)
projAtrLen       = input.int(14, "ATR length", minval=1, group=grpProj)
projAtrMult      = input.float(1.5, "ATR multiplier", step=0.1, minval=0.1, group=grpProj)
scaleWithStrength = input.bool(true, "Scale projection with flow strength", group=grpProj)

//────────────────────────────────────────────
// Helpers
//────────────────────────────────────────────
f_rollsum(x, len) =>
    float c = ta.cum(nz(x, 0.0))
    float back = na
    if bar_index >= len
        back := ta.cum(nz(x[len], 0.0))
    na(back) ? na : (c - back)

f_pct(b, s) =>
    float tot = b + s
    tot > 0 ? (b / tot) * 100.0 : na

// proxy split per-bar
buyVol  = close > open ? volume : close < open ? 0.0 : volume * 0.5
sellVol = close < open ? volume : close > open ? 0.0 : volume * 0.5

//────────────────────────────────────────────
// Main TF calculations (Flow box % + RVOL + EMA bias)
//────────────────────────────────────────────
bullVolSum = f_rollsum(buyVol, lookback)
sellVolSum = f_rollsum(sellVol, lookback)

bullPct = not na(bullVolSum) and not na(sellVolSum) ? f_pct(bullVolSum, sellVolSum) : na
bearPct = not na(bullPct) ? 100.0 - bullPct : na

bullVolDelta = f_rollsum(buyVol, deltaLen)
sellVolDelta = f_rollsum(sellVol, deltaLen)
bullPctDelta = not na(bullVolDelta) and not na(sellVolDelta) ? f_pct(bullVolDelta, sellVolDelta) : na

rvol = volume / math.max(ta.sma(volume, rvolLen), 1.0)

// EMA trend bias
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
slopeUp   = emaFast > emaFast[1]
slopeDown = emaFast < emaFast[1]

trendBull = emaFast > emaSlow and (not useSlope or slopeUp)
trendBear = emaFast < emaSlow and (not useSlope or slopeDown)

flowBull = not na(bullPctDelta) and bullPctDelta > bullThresh
flowBear = not na(bullPctDelta) and bullPctDelta < bearThresh

biasTxt = (trendBull and flowBull) ? "Bullish" : (trendBear and flowBear) ? "Bearish" : "Neutral"
biasCol = (trendBull and flowBull) ? color.new(color.lime, 0) : (trendBear and flowBear) ? color.new(color.red, 0) : color.new(color.gray, 0)

isBullBias = (trendBull and flowBull)
isBearBias = (trendBear and flowBear)

//────────────────────────────────────────────
// Flow Box drawing
//────────────────────────────────────────────
hi = ta.highest(high, lookback)
lo = ta.lowest(low, lookback)
rangeHL = math.max(hi - lo, syminfo.mintick)

split = not na(bullPct) ? (lo + (bullPct / 100.0) * rangeHL) : na

var box bullBox = na
var box bearBox = na
var label pctLbl = na

if showFlowBox and bar_index > lookback and not na(split)
    int left = bar_index - lookback + 1
    int right = bar_index

    if na(bullBox)
        bullBox := box.new(left, hi, right, split, bgcolor=color.new(color.lime, boxOpacity), border_color=color.new(color.lime, 30))
    if na(bearBox)
        bearBox := box.new(left, split, right, lo, bgcolor=color.new(color.red, boxOpacity), border_color=color.new(color.red, 30))

    box.set_lefttop(bullBox, left, hi)
    box.set_rightbottom(bullBox, right, split)

    box.set_lefttop(bearBox, left, split)
    box.set_rightbottom(bearBox, right, lo)

    string txt = not na(bullPct) ? ("Bull " + str.tostring(bullPct, "#.0") + "%  |  Bear " + str.tostring(100.0 - bullPct, "#.0") + "%") : "—"
    if na(pctLbl)
        pctLbl := label.new(right, split, txt, style=label.style_label_left, color=color.new(color.black, 70), textcolor=color.white, size=size.small)
    label.set_x(pctLbl, right)
    label.set_y(pctLbl, split)
    label.set_text(pctLbl, txt)
else
    if not na(bullBox)
        box.delete(bullBox)
        bullBox := na
    if not na(bearBox)
        box.delete(bearBox)
        bearBox := na
    if not na(pctLbl)
        label.delete(pctLbl)
        pctLbl := na

//────────────────────────────────────────────
// Projection (clean dashed line + label)
//────────────────────────────────────────────
atrP = ta.atr(projAtrLen)

// Strength scaler: 0.75x → 1.50x depending on Bull% delta strength
strength = not na(bullPctDelta) ? math.abs(bullPctDelta - 50.0) : 0.0
scale = scaleWithStrength ? (0.75 + math.min(strength / 25.0, 0.75)) : 1.0

projDist = atrP * projAtrMult * scale

projLevel = isBullBias ? (close + projDist) : isBearBias ? (close - projDist) : na

var line projLine = na
var label projLbl = na

if showProjection and not na(projLevel)
    if na(projLine)
        projLine := line.new(bar_index, projLevel, bar_index + projBarsForward, projLevel, extend=extend.none, style=line.style_dashed, width=2, color=biasCol)
    else
        line.set_xy1(projLine, bar_index, projLevel)
        line.set_xy2(projLine, bar_index + projBarsForward, projLevel)
        line.set_color(projLine, biasCol)

    string ptxt = isBullBias ? "Bull Proj" : "Bear Proj"
    if na(projLbl)
        projLbl := label.new(bar_index + projBarsForward, projLevel, ptxt, style=label.style_label_left, color=color.new(color.black, 70), textcolor=color.white, size=size.tiny)
    else
        label.set_x(projLbl, bar_index + projBarsForward)
        label.set_y(projLbl, projLevel)
        label.set_text(projLbl, ptxt)
else
    if not na(projLine)
        line.delete(projLine)
        projLine := na
    if not na(projLbl)
        label.delete(projLbl)
        projLbl := na
````
