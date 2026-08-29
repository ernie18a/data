<!-- tradingview-pine-id: PUB;a3ee8b43a26b4080abb5d6fe1b037dcd -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Void Detector (Zeiierman)

Source: https://www.tradingview.com/script/q1hXS0v6-Liquidity-Void-Detector-Zeiierman/

## Description

█ Overview

Liquidity Void Detector (Zeiierman) is an oscillator highlighting inefficient price displacements under low participation. It measures the most recent price move (standardized return) and amplifies it only when volume is below its own trend.
[image]https://www.tradingview.com/x/ZCgjhvw5/ [/image]

[*]Positive readings ⇒ strong up-move on low volume → potential Buy-Side Imbalance (void below) that often refills.
[*]Negative readings ⇒ strong down-move on low volume → potential Sell-Side Imbalance (void above) that often refills.

This tool provides a quantitative “void” proxy: when price travels far with unusually thin volume, the move is flagged as likely inefficient and prone to mean-reversion/mitigation.
[image] https://www.tradingview.com/x/Y3g3jScR/[/image]

█ How It Works
⚪Volume Shock (Participation Filter)
Each bar, volume is compared to a rolling baseline. This is then z-scored.
[pine]// Volume Shock calculation
volTrend = ta.sma(volume, L)
vs       = (volume > 0 and volTrend > 0) ? math.log(volume) - math.log(volTrend) : na
vsZ      = zScore(vs, vzLen)  // z-scored volume shock
lowVS    = (vsZ <= vzThr)     // low-volume condition
[/pine]
Bars with VolShock Z ≤ threshold are treated as low-volume (thin).

⚪Prior Return Extremeness
The 1-bar log return is computed and z-scored. 
[pine]// Prior return extremeness
r1   = math.log(close / close[1])
retZ = zScore(r1, rLen)  // z-scored prior return
[/pine]
This shows whether the latest move is unusually large relative to recent history.

⚪Void Oscillator
The oscillator is:
[pine]// Oscillator construction
weight = lowVS ? 1.0 : fadeNoLow
osc    = retZ * weight[/pine]
where Weight = 1 when volume is low, otherwise fades toward a user-set factor (0–1).

[*]Osc > 0: up-move emphasized under low volume ⇒ Buy-Side Imbalance.
[*]Osc < 0: down-move emphasized under low volume ⇒ Sell-Side Imbalance.

█ Why Use It

⚪Targets Inefficient Moves
By filtering for low participation, the oscillator focuses on moves most likely driven by thin books/noise trading, which are statistically more likely to retrace.

⚪Simple, Robust Logic
No need for tick data or order-book depth. It derives a practical void proxy from OHLCV, making it portable across assets and timeframes.

⚪Complements Price-Action Tools
Use alongside FVG/imbalance zones, key levels, and volume profile to prioritize voids that carry the highest reversal probability.

█ How to Use

Sell-Side Imbalance = aggressive sell move (price goes down on low volume) → expect price to move up to fill it.
[image]https://www.tradingview.com/x/cczPtMjn/[/image]

Buy-Side Imbalance = aggressive buy move (price goes up on low volume)  → expect price to move down to fill it.
[image]https://www.tradingview.com/x/AH6jmrr3/ [/image]

█ Settings

[*]Volume Baseline Length — Bars for the volume trend used in VolShock. Larger = smoother baseline, fewer low-volume flags.
[*]Vol Shock Z-Score Lookback — Bars to standardize VolShock; larger = smoother, fewer extremes.
[*]Low-Volume Threshold (VolShock Z ≤) — Defines “thin participation.” Typical: −0.5 to −1.0.
[*]Return Z-Score Lookback — Bars to standardize the 1-bar log return; larger = smoother “extremeness” measure.
[*]Fade When Volume Not Low (0–1) — Weight applied when volume is not low. 0.00 = ignore non-low-volume bars entirely. 1.00 = treat volume condition as irrelevant (pure return extremeness).
[*]Upper Threshold (Osc ≥) — Trigger for Sell-Side Imbalance (void below).
[*]Lower Threshold (Osc ≤) — Trigger for Buy-Side Imbalance (void above).

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
indicator("Liquidity Void Detector (Zeiierman)", overlay=false, max_labels_count=500)
//~~}

// ~~ Tooltips (in-depth) {
var string t1 = "How many bars to build the volume *baseline* used for the volume shock.\n\nWe compute VS = ln(Volume_t) − ln(SMA(Volume, L)_t).\nBigger L = smoother baseline (fewer Low-Volume flags). Typical: 20–60."
var string t2 = "How many bars to judge whether today’s volume shock is *unusually* low.\nWe z-score the volume shock against this lookback. Larger = smoother, fewer extremes."
var string t3 = "How many bars to judge whether the prior price move is *unusually* large.\nWe use the 1-bar log return (ln(C/PrevC)) and z-score it against this lookback."
var string t4 = "Threshold for flagging *Low Volume*.\nIf VolShock Z ≤ this value, we treat the bar as *low-participation* (thin liquidity). Typical: −0.5 to −1.0."
var string t6 = "Weight applied when volume is NOT low (0–1).\n• 0.00 = ignore non-low-volume bars entirely (only react under Low Volume)\n• 1.00 = treat volume condition as irrelevant (pure return reversal)\nTypical: 0.10–0.50."
var string t7 = "Signal thresholds for the Liquidity Void Oscillator."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
L      = input.int(30, "Volume Baseline Length", minval=2, tooltip=t1, group="Volume Shock")
vzLen  = input.int(60, "Vol Shock Z-Score Lookback", minval=1, tooltip=t2, group="Volume Shock")
vzThr  = input.float(-0.5, "Low-Volume Threshold (VolShock Z ≤)", step=0.1, tooltip=t4, group="Volume Shock")
rLen   = input.int(60, "Return Z-Score Lookback", minval=1, tooltip=t3, group="Return")
fadeNoLow = input.float(0.01, "Fade When Volume Not Low (0–1)", minval=0.0, maxval=1.0, step=0.01, tooltip=t6, group="Liquidity Void Oscillator")
longThr   = input.float(+1.0, "Upper Threshold (Osc ≥)", step=0.1, tooltip=t7, group="Liquidity Void Oscillator")
shortThr  = input.float(-1.0, "Lower Threshold (Osc ≤)", step=0.1, tooltip=t7, group="Liquidity Void Oscillator")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Helpers {
zScore(src, len) =>
    m = ta.sma(src, len)
    d = ta.stdev(src, len)
    d == 0.0 ? 0.0 : (src - m) / d

ret1() =>
    math.log(close / close[1])
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Core series {
// ~~  Volume shock
volTrend = ta.sma(volume, L)
vs       = (volume > 0 and volTrend > 0) ? math.log(volume) - math.log(volTrend) : na
vsZ      = zScore(vs, vzLen)
//~~}

// ~~ Prior 1-bar return (t−1→t)
r1   = ret1()
retZ = zScore(r1, rLen)
//~~}

// ~~ Low-volume condition
lowVS = (vsZ <= vzThr) 
//~~}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Void construction {
base   = retZ
weight = lowVS ? 1.0 : fadeNoLow
osc    = base * weight
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Plots {
h0 = hline(0,  "Zero",  color=color.new(color.gray, 70))
hL = hline(longThr,  "Upper Threshold (Osc ≥)",  color=color.new(color.teal, 30))
hS = hline(shortThr, "Lower Threshold (Osc ≤)", color=color.new(color.red, 30))
voidcol = osc > 0?color.teal:color.red
plot(osc,  "Liquidity Void Oscillator",  linewidth=2, color=voidcol, style=plot.style_columns)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Label {
VoidAbove = ta.crossover(osc, longThr)
VoidBelow = ta.crossunder(osc, shortThr)

if VoidAbove
    label.new(bar_index, osc, "Buy-Side Imbalance",  // price UP inefficiency, expect DOWN fill
     color=color.new(color.teal, 0), textcolor=color.white, style=label.style_label_down, size=size.small, yloc=yloc.price)

if VoidBelow
    label.new(bar_index, osc, "Sell-Side Imbalance", // price DOWN inefficiency, expect UP fill
     color=color.new(color.red, 0), textcolor=color.white, style=label.style_label_up, size=size.small, yloc=yloc.price)

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Alerts {
alertcondition(VoidAbove,  title="Buy-Side Imbalance",  message="Buy-Side Imbalance")
alertcondition(VoidBelow, title="Sell-Side Imbalance", message="Sell-Side Imbalance")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
