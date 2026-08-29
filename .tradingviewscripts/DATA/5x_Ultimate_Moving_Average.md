<!-- tradingview-pine-id: PUB;b0f81d63a9c44ba4830bc9f53cf401a1 -->
<!-- tradingviewscripts-format: 1 -->
# 5x Ultimate Moving Average

Source: https://www.tradingview.com/script/i6XxAs3W-Ultimate-Moving-Average-X-5/

## Description

Ultimate Moving Average: 5-in-1 MTF & Trend Cloud

TradingView's free tier limits you to just three indicators per chart, making it difficult to build a robust setup without upgrading. I built the Ultimate Moving Average to solve this. By packing five fully customizable moving averages into a single script, you can save your valuable indicator slots for other tools.

If this indicator helps you optimize your charts and save on subscription fees, consider supporting my work! You can buy me a coffee here: https://ko-fi.com/tradeguru/ ☕

🛠️ Key Features
5-in-1 Functionality: Plot up to five distinct moving averages simultaneously using only one indicator slot.

Multiple MA Types: Choose between SMA, EMA, WMA, HMA, VWMA, and RMA for each individual line to suit your specific strategy.

Multi-Timeframe (MTF) Support: Set independent timeframes for each moving average. For example, you can display a Daily EMA and a Weekly SMA directly on your 1-Hour chart.

Dynamic Trend Cloud: A visual fill between MA 1 and MA 2 highlights the current momentum, shifting colors automatically as the trend changes to provide immediate visual confirmation.

Full Customization: Toggle individual lines on or off, and adjust the source (close, high, low, etc.), thickness, and colors to keep your workspace exactly how you like it.

Built-in Alerts: Integrated alert conditions for bullish and bearish crosses between your fast and slow moving averages.

💡 Why Use This Script?
This tool is designed specifically with free users in mind. Instead of wasting two or three slots just to get your fast, slow, and baseline moving averages on the screen, this script handles all of them at once. Build your perfect trend-following or mean-reversion setup without paying for premium restrictions.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/

//@version=6
indicator("5x Ultimate Moving Average", overlay = true)

// -----------------------------------------------------------------------------
// HELPER FUNCTIONS
// -----------------------------------------------------------------------------

// Function to calculate the selected Moving Average type
get_ma(type, src, len) =>
    float result = na
    if type == "SMA"
        result := ta.sma(src, len)
    else if type == "EMA"
        result := ta.ema(src, len)
    else if type == "WMA"
        result := ta.wma(src, len)
    else if type == "HMA"
        result := ta.hma(src, len)
    else if type == "VWMA"
        result := ta.vwma(src, len)
    else if type == "RMA"
        result := ta.rma(src, len)
    result

// Function to handle Multi-Timeframe (MTF) requests
get_mtf_ma(use_mtf, tf, type, src, len) =>
    float ma_val = get_ma(type, src, len)
    float final_ma = use_mtf and tf != "" ? request.security(syminfo.tickerid, tf, ma_val) : ma_val
    final_ma

// -----------------------------------------------------------------------------
// INPUTS
// -----------------------------------------------------------------------------

// -- MA 1 --
gp1     = "Moving Average 1 (Fast)"
show1   = input.bool(true, title="Show MA 1", group=gp1)
type1   = input.string("EMA", title="Type", options=["SMA", "EMA", "WMA", "HMA", "VWMA", "RMA"], group=gp1)
len1    = input.int(20, title="Length", minval=1, group=gp1)
src1    = input.source(close, title="Source", group=gp1)
mtf1    = input.bool(false, title="Use Custom Timeframe?", group=gp1)
tf1     = input.timeframe("D", title="Timeframe", group=gp1)
col1    = input.color(color.new(#2962ff, 0), title="Color", group=gp1)
thick1  = input.int(2, title="Thickness", minval=1, maxval=5, group=gp1)

// -- MA 2 --
gp2     = "Moving Average 2 (Slow)"
show2   = input.bool(true, title="Show MA 2", group=gp2)
type2   = input.string("EMA", title="Type", options=["SMA", "EMA", "WMA", "HMA", "VWMA", "RMA"], group=gp2)
len2    = input.int(50, title="Length", minval=1, group=gp2)
src2    = input.source(close, title="Source", group=gp2)
mtf2    = input.bool(false, title="Use Custom Timeframe?", group=gp2)
tf2     = input.timeframe("D", title="Timeframe", group=gp2)
col2    = input.color(color.new(#ff5252, 0), title="Color", group=gp2)
thick2  = input.int(2, title="Thickness", minval=1, maxval=5, group=gp2)

// -- MA 3 --
gp3     = "Moving Average 3"
show3   = input.bool(false, title="Show MA 3", group=gp3)
type3   = input.string("SMA", title="Type", options=["SMA", "EMA", "WMA", "HMA", "VWMA", "RMA"], group=gp3)
len3    = input.int(100, title="Length", minval=1, group=gp3)
src3    = input.source(close, title="Source", group=gp3)
mtf3    = input.bool(false, title="Use Custom Timeframe?", group=gp3)
tf3     = input.timeframe("D", title="Timeframe", group=gp3)
col3    = input.color(color.new(#00c853, 0), title="Color", group=gp3)
thick3  = input.int(2, title="Thickness", minval=1, maxval=5, group=gp3)

// -- MA 4 --
gp4     = "Moving Average 4"
show4   = input.bool(false, title="Show MA 4", group=gp4)
type4   = input.string("SMA", title="Type", options=["SMA", "EMA", "WMA", "HMA", "VWMA", "RMA"], group=gp4)
len4    = input.int(200, title="Length", minval=1, group=gp4)
src4    = input.source(close, title="Source", group=gp4)
mtf4    = input.bool(false, title="Use Custom Timeframe?", group=gp4)
tf4     = input.timeframe("D", title="Timeframe", group=gp4)
col4    = input.color(color.new(#ffeb3b, 0), title="Color", group=gp4)
thick4  = input.int(2, title="Thickness", minval=1, maxval=5, group=gp4)

// -- MA 5 --
gp5     = "Moving Average 5"
show5   = input.bool(false, title="Show MA 5", group=gp5)
type5   = input.string("SMA", title="Type", options=["SMA", "EMA", "WMA", "HMA", "VWMA", "RMA"], group=gp5)
len5    = input.int(800, title="Length", minval=1, group=gp5)
src5    = input.source(close, title="Source", group=gp5)
mtf5    = input.bool(false, title="Use Custom Timeframe?", group=gp5)
tf5     = input.timeframe("W", title="Timeframe", group=gp5)
col5    = input.color(color.new(#e040fb, 0), title="Color", group=gp5)
thick5  = input.int(2, title="Thickness", minval=1, maxval=5, group=gp5)

// -- CLOUD SETTINGS --
gp_cloud   = "MA 1 & MA 2 Cloud Settings"
show_cloud = input.bool(true, title="Show Trend Cloud between MA 1 and MA 2", group=gp_cloud)
bull_cloud = input.color(color.new(color.teal, 85), title="Bullish Cloud (MA1 > MA2)", group=gp_cloud)
bear_cloud = input.color(color.new(color.red, 85), title="Bearish Cloud (MA1 < MA2)", group=gp_cloud)

// -----------------------------------------------------------------------------
// CALCULATIONS
// -----------------------------------------------------------------------------

val1 = get_mtf_ma(mtf1, tf1, type1, src1, len1)
val2 = get_mtf_ma(mtf2, tf2, type2, src2, len2)
val3 = get_mtf_ma(mtf3, tf3, type3, src3, len3)
val4 = get_mtf_ma(mtf4, tf4, type4, src4, len4)
val5 = get_mtf_ma(mtf5, tf5, type5, src5, len5)

// -----------------------------------------------------------------------------
// PLOTTING
// -----------------------------------------------------------------------------

p1 = plot(show1 ? val1 : na, title="MA 1", color=col1, linewidth=thick1)
p2 = plot(show2 ? val2 : na, title="MA 2", color=col2, linewidth=thick2)
p3 = plot(show3 ? val3 : na, title="MA 3", color=col3, linewidth=thick3)
p4 = plot(show4 ? val4 : na, title="MA 4", color=col4, linewidth=thick4)
p5 = plot(show5 ? val5 : na, title="MA 5", color=col5, linewidth=thick5)

// Cloud Filling
fill_col = val1 > val2 ? bull_cloud : bear_cloud
fill(p1, p2, title="Trend Cloud", color=show_cloud and show1 and show2 ? fill_col : na)

// -----------------------------------------------------------------------------
// ALERTS (MA 1 & MA 2 Cross)
// -----------------------------------------------------------------------------
bull_cross = ta.crossover(val1, val2)
bear_cross = ta.crossunder(val1, val2)

if bull_cross
    alert("MA Bullish Cross: MA 1 crossed above MA 2", alert.freq_once_per_bar_close)
if bear_cross
    alert("MA Bearish Cross: MA 1 crossed below MA 2", alert.freq_once_per_bar_close)
````
