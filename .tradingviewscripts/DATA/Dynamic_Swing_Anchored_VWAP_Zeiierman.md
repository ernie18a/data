<!-- tradingview-pine-id: PUB;e77a7e595ef04d0bab233736e5c1f6ff -->
<!-- tradingviewscripts-format: 1 -->
# Dynamic Swing Anchored VWAP (Zeiierman)

Source: https://www.tradingview.com/script/SxgyrEde-Dynamic-Swing-Anchored-VWAP-Zeiierman/

## Description

█ Overview
Dynamic Swing Anchored VWAP (Zeiierman) is a price–volume tool that anchors VWAP at fresh swing highs/lows and then adapts its responsiveness as conditions change. Instead of one static VWAP that drifts away over time, this indicator re-anchors at meaningful structure points (swings). It computes a decayed, volume-weighted average that can speed up in volatile markets and slow down during quiet periods.
[image]https://www.tradingview.com/x/Q4DDaSQl/[/image]
Blending swing structure with an adaptive VWAP engine creates a fair-value path that stays aligned with current price behavior, making retests, pullbacks, and mean reversion opportunities easier to spot and trade.

█ How It Works
⚪ Swing Anchor Engine

[*]The script scans for swing highs/lows using your Swing Period.
[*]When market direction flips (new pivot confirmed), the indicator anchors a new VWAP at that pivot and starts tracking from there.

⚪ Adaptive VWAP Core

[*]From each anchor, VWAP is computed using a decay model (recent price×volume matters more; older data matters less).
[*]Adaptive Price Tracking lets you set the base responsiveness in “bars.” Lower = more reactive, higher = smoother.
[*]Volatility Adjustment (ATR vs Avg ATR) can automatically speed up the VWAP during spikes and slow it during compression, so the line stays relevant to live conditions.

█ Why This Adaptive Approach Beats a Simple VWAP

Standard VWAP is cumulative from the anchor point. As time passes and volume accumulates, it often drifts far from current price, especially in prolonged trends or multi-session moves. That drift makes retests rare and unreliable.

Dynamic Swing Anchored VWAP solves this in two ways:

⚪ Event-Driven Anchoring (Swings):
By restarting at fresh swing highs/lows, the VWAP reference reflects today’s structure. You get frequent, meaningful retests because the anchor stays near the action.

⚪ Adaptive Responsiveness (Volatility-Aware):
Markets don’t move at one speed. When volatility expands, a fixed VWAP lags; when volatility contracts, it can overreact to noise. Here, the “tracking speed” can auto-adjust using ATR vs its average.

[*]High Volatility → faster tracking: VWAP hugs price more tightly, preserving retest relevance.
[*]Low Volatility → smoother tracking: VWAP filters chop and stays stable.

Result: A VWAP that follows price more accurately, creating plenty of credible retest opportunities and more trustworthy mean-reversion/continuation reads than a simple, ever-growing VWAP.
[image]https://www.tradingview.com/x/mfhiLbRx/[/image]

█ How to Use

⚪ Swing-Aware Fair Value
Use the VWAP as a dynamic fair-value guide that restarts at key structural pivots. Pullbacks to the VWAP after impulsive moves often provide retest entries.
[image]https://www.tradingview.com/x/qCDUDeKW/[/image]

⚪ Trend Trading
In trends, the adaptive VWAP will ride closer to price, offering continuation pullbacks.
[image]https://www.tradingview.com/x/1SQvvjKn/[/image]

█ Settings

[*]Swing Period: Number of bars to confirm swing highs/lows. Larger = bigger, cleaner pivots (slower); smaller = more frequent pivots (noisier).
[*]Adaptive Price Tracking: Sets the base reaction speed (in bars). Lower = faster, tighter to price; higher = smoother, slower.
[*]Adapt APT by ATR ratio: When ON, the tracking speed auto-adjusts with market volatility (ATR vs its own average). High vol → faster; low vol → calmer.
[*]Volatility Bias: Controls how strongly volatility affects the speed. >1 = stronger effect; <1 = lighter touch.

-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/

// © Zeiierman {
//@version=6
indicator('Dynamic Swing Anchored VWAP (Zeiierman)', overlay = true, max_bars_back = 5000, max_labels_count = 500, max_polylines_count = 100)
//~~}

// ~~ Tooltips {
var string t1 = "Number of bars used to detect swing highs and lows. Larger values identify bigger, more significant swings but react slower. Smaller values detect more frequent swings but may produce more noise."
var string t2 = "Controls how quickly the VWAP adjusts to new price action. Lower values make the VWAP react faster (tighter to price), higher values make it smoother and slower to change."
var string t3 = "When enabled, the VWAP reaction speed changes automatically based on market volatility. High volatility shortens the tracking period (more responsive), low volatility lengthens it (smoother)."
var string t4 = "Controls how strongly volatility influences the VWAP reaction speed. Values above 1 increase the effect of volatility changes; values below 1 make it less sensitive to volatility."
var string t5 = "Color used for swing high/low labels drawn on the chart to indicate pivot points."
var string t6 = "Color used for swing low labels when marking pivot points."
var string t7 = "Color used for VWAP lines when in an uptrend."
var string t8 = "Color used for VWAP lines when in a downtrend."
var string t9 = "Width of the VWAP lines drawn on the chart. Larger values make the lines thicker and more visible."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
prd     = input.int(50, title='Swing Period', minval=2, group='Swing Points', tooltip=t1)
baseAPT = input.float(20, 'Adaptive Price Tracking', minval=1, step=1, group='Swing Points', tooltip=t2)
useAdapt = input.bool(false, 'Adapt APT by ATR ratio', group='Swing Points', tooltip=t3)
volBias = input.float(10.0, 'Volatility Bias', minval=0.1, step=0.1, group='Swing Points', tooltip=t4)

highS   = input.color(color.lime, title="Swing Labels", group="Style", inline="Swing", tooltip=t5)
lowS    = input.color(color.red, title="", group="Style", inline="Swing", tooltip=t6)
S       = input.color(color.lime, title="VWAP Lines", group="Style", inline="VWAP", tooltip=t7)
R       = input.color(color.red,  title="", group="Style", inline="VWAP", tooltip=t8)
xx      = input.int(2, minval=1, title="", group="Style", inline="VWAP", tooltip=t9)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Global Variable {
b = bar_index
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ PIVOTS Variables {
var ph   = float(na)
var pl   = float(na)
var phL  = b
var plL  = b
var lab  = label(na)
var prev = float(na)

ph  := ta.highestbars(high, prd) == 0 ? high : ph
pl  := ta.lowestbars(low,  prd) == 0 ? low  : pl
phL := ta.highestbars(high, prd) == 0 ? b   : phL
plL := ta.lowestbars(low,  prd) == 0 ? b    : plL
dir = phL > plL ? 1 : -1
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Adaptation {
atrLen = 50
atr    = ta.atr(atrLen)
atrAvg = ta.rma(atr, atrLen)
ratio  = atrAvg > 0 ? atr / atrAvg : 1.0

aptRaw     = useAdapt ? baseAPT / math.pow(ratio, volBias) : baseAPT
aptClamped = math.max(5.0, math.min(300.0, aptRaw))
aptSeries  = math.round(aptClamped)

// alpha from APT (half-life -> EWMA alpha)
alphaFromAPT(apt) =>
    decay = math.exp(-math.log(2.0) / math.max(1.0, apt))
    1.0 - decay
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ VWAP Variables {
var p   = hlc3 * volume 
var vol = volume      

type dataPoints
    array<chart.point> points
    polyline poly = na

var vwap = dataPoints.new(array.new<chart.point>())
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Main {
if dir != dir[1]
    x   = dir > 0 ? plL : phL
    y   = dir > 0 ? pl  : ph
    loc = dir > 0 ? label.style_label_up : label.style_label_down
    col = dir > 0 ?  highS : lowS
    txt = dir > 0 and pl < prev ? 'LL' : dir > 0 and pl > prev ? 'HL' : dir < 0 and ph < prev ? 'LH' : dir < 0 and ph > prev ? 'HH' : ''
    label.new(x, y, text=txt, style=loc, color=color.new(col, 20), textcolor=color.white)
    prev := dir > 0 ? ph[1] : pl[1]

    barsback = b - x
    p   := y * volume[barsback]
    vol := volume[barsback]
    vap = p / vol

    vwap.poly.delete()
    polyline.new(vwap.points, false, false, line_color = dir < 0 ? R : S, line_width = xx)
    vwap.points.clear()

    for i = barsback to 0 by 1
        apt_i = aptSeries[i]
        alpha = alphaFromAPT(apt_i)

        pxv   = hlc3[i] * volume[i]
        v_i   = volume[i]

        p     := (1.0 - alpha) * p + alpha * pxv
        vol   := (1.0 - alpha) * vol + alpha * v_i
        vappe = vol > 0 ? p / vol : na

        vwap.points.push(chart.point.from_index(b - i, vappe))

    vwap.poly := polyline.new(vwap.points, false, false, line_color = dir < 0 ? R : S, line_width = xx)

else
    apt_0 = aptSeries
    alpha = alphaFromAPT(apt_0)

    pxv = hlc3 * volume
    v0  = volume

    p   := (1.0 - alpha) * p + alpha * pxv
    vol := (1.0 - alpha) * vol + alpha * v0
    vap = vol > 0 ? p / vol : na

    vwap.poly.delete()
    vwap.points.push(chart.point.from_index(b, vap))
    vwap.poly := polyline.new(vwap.points, false, false, line_color = dir > 0 ? R : S, line_width = xx)
//~~ }
````
