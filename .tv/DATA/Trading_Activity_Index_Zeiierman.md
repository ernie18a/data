<!-- tradingview-pine-id: PUB;e794c3fbe8ce460eaf7326861fbdbcbb -->
<!-- tradingviewscripts-format: 1 -->
# Trading Activity Index (Zeiierman)

Source: https://www.tradingview.com/script/rtOfqf13-Trading-Activity-Index-Zeiierman/

## Description

█ Overview
Trading Activity Index (Zeiierman) is a volume-based market activity meter that transforms dollar-volume into a smooth, normalized “activity index.”
[image]https://www.tradingview.com/x/D9dyuCTo/[/image]
It highlights when market participation is unusually low or high with a dynamic color gradient:

[*]Light Blue → Low Activity (thin participation, low liquidity conditions)
[*]Red/Orange → High Activity (active markets, large trades flowing in)

[image]https://www.tradingview.com/x/8aX2SOXy/ [/image]
Additional percentile bands (20/40/60/80%) give context, helping you see whether the current activity level is in the bottom quintile, mid-range, or near historical extremes.

█ How It Works
⚪ Dollar Volume Transformation
Each bar, dollar volume is computed:
[pine]float dlrVol  = close * volume
float dlrVolAvg = ta.sma(dlrVol, len_form)[/pine]

[*]Dollar volume = price × volume, smoothed by a configurable SMA window.
[*]The result is log-transformed, compressing large outliers for a more stable signal.

⚪ Rolling Percentiles & Ranking
The log-dollar-volume series is compared to its rolling history (len_hist bars):

[pine]float p20 = ta.percentile_linear_interpolation(vscale, len_hist, 20)
float p40 = ta.percentile_linear_interpolation(vscale, len_hist, 40)
float p60 = ta.percentile_linear_interpolation(vscale, len_hist, 60)
float p80 = ta.percentile_linear_interpolation(vscale, len_hist, 80)[/pine]

[*]A normalized rank (0–1) is produced to color the main Trading Activity line.

█ How to Use

⚪ Detect High-Impact Sessions
Quickly see if today’s session is active or quiet relative to its own history — great for filtering setups that need activity.
[image]https://www.tradingview.com/x/A4LrbFMP/[/image]
⚪ Spot Breakouts & Traps
Combine with price action:

[*]High activity near breakouts = strong follow-through likely.
[*]Low activity breakouts = vulnerable to fake-outs.

[image]https://www.tradingview.com/x/NEkyNbOk/[/image]
⚪ Market Regime Context
Percentile bands help you assess whether participation is building up, in the middle of the range, or drying out — valuable for timing mean-reversion trades.

[*]Above 80th percentile (red/orange) → Market is highly active, breakout trades and trend strategies are favored.
[*]Below 20th percentile (light blue) → Market is quiet; fade moves or wait for expansion.
[*]Watch transitions from blue → orange as a signal of growing institutional participation.

[image]https://www.tradingview.com/x/x0Qsx5t1/[/image]

█ Settings

[*]Formation Window (bars) – Number of bars used to average dollar volume before log transform.
[*]History Window (bars) – Lookback period for percentile calculations and rank normalization.

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
indicator("Trading Activity Index (Zeiierman)", overlay=false, max_bars_back=2000, precision = 1)
//~~}

// ~~ Tooltips {
t1 = "Formation window (bars) for averaging dollar volume before taking the log."
t2 = "History window (bars) used to compute rolling percentiles and bands."
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
len_form   = input.int(20,  minval=2,  step=1, title="Formation Window (bars)", group="", inline="", tooltip=t1)
len_hist   = input.int(252, minval=50, step=5, title="History Window (bars)",   group="", inline="", tooltip=t2)
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Core series {
var float na_f = na
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// Dollar Volume: price * volume {
float dlrVol  = close * volume
float dlrVolAvg = ta.sma(dlrVol, len_form)
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// VOLSCALE proxy = log(average(dollar volume)) {
float vscale = math.log(math.max(dlrVolAvg, 1e-10))
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// Rolling percentiles of VOLSCALE proxy over len_hist {
float p20 = ta.percentile_linear_interpolation(vscale, len_hist, 20)
float p40 = ta.percentile_linear_interpolation(vscale, len_hist, 40)
float p60 = ta.percentile_linear_interpolation(vscale, len_hist, 60)
float p80 = ta.percentile_linear_interpolation(vscale, len_hist, 80)
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// Percentile rank proxy for display only (normalize by rolling min/max) {
float vMin = ta.lowest(vscale, len_hist)
float vMax = ta.highest(vscale, len_hist)
float rank01 = (vMax == vMin) ? 0.5 : math.max(0.0, math.min(1.0, (vscale - vMin) / (vMax - vMin)))
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Gradient color function {
gradientColor(_val) =>
    // Light blue = rgb(173, 216, 230), Orange/Red = rgb(255, 69, 0)
    r1 = 173.0, g1 = 216.0, b1 = 230.0
    r2 = 255.0, g2 = 69.0,  b2 = 0.0
    r = r1 + (r2 - r1) * _val
    g = g1 + (g2 - g1) * _val
    b = b1 + (b2 - b1) * _val
    color.rgb(math.round(r), math.round(g), math.round(b))

blueGradient(_val) =>
    // Light blue → Deep blue for percentile bands
    r1 = 173.0, g1 = 216.0, b1 = 230.0  
    r2 = 0.0,   g2 = 0.0,   b2 = 255.0 
    r = r1 + (r2 - r1) * _val
    g = g1 + (g2 - g1) * _val
    b = b1 + (b2 - b1) * _val
    color.rgb(math.round(r), math.round(g), math.round(b))
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Plots {
plot(vscale, title="Trading Activity", color=gradientColor(rank01), linewidth=2)
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// Quintile bands {
plot(p20, title="P20", style=plot.style_line, linewidth=1, color=blueGradient(0.2))
plot(p40, title="P40", style=plot.style_line, linewidth=1, color=blueGradient(0.4))
plot(p60, title="P60", style=plot.style_line, linewidth=1, color=blueGradient(0.6))
plot(p80, title="P80", style=plot.style_line, linewidth=1, color=blueGradient(0.8))
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
