<!-- tradingview-pine-id: PUB;adb9135502564160b1340411842cdecb -->
<!-- tradingviewscripts-format: 1 -->
# Ultimate Multi-Panel Suite

Source: https://www.tradingview.com/script/FI2JezrE-MACD-RSI-VWAP-MA-S-R-Bulk/

## Description

This all-in-one script packs five of the market's most essential technical analysis tools into a single indicator slot. By combining momentum, trend, volume, and structural levels, you get a complete institutional-grade workspace without hitting upgrade walls or paying monthly subscription fees.

☕ If this indicator helps you optimize your charts and save on subscription costs, consider supporting my work! Buy me a coffee here: https://ko-fi.com/tradeguru/
(Need a custom indicator built specifically for your trading strategy? Reach out for custom Pine Script development!)

🛠️ What's Included in the Bulk Suite?
Dual Moving Averages (MA): Fully customizable fast and slow moving averages. Choose your preferred calculation type (SMA, EMA, WMA, HMA, VWMA, RMA), set your exact lengths, and track trend direction directly on your chart.

VWAP (Volume Weighted Average Price): The gold standard for tracking intraday institutional fair value and average price execution.

Support & Resistance (S/R): Automatically plots historical swing points with clean vertical breaks (linebr), giving you clear structural boundaries for breakout and pullback planning.

MACD (Moving Average Convergence Divergence): Standard momentum and trend-following oscillator to capture shifts in market velocity.

RSI (Relative Strength Index): Essential momentum oscillator with customizable overbought and oversold levels to spot exhaustion and reversals.

⚙️ Full Customization & Control
Every single tool inside this suite comes with independent settings. You can completely toggle individual indicators on or off, adjust their lookback lengths, and fine-tune colors to keep your workspace clean, organized, and tailored precisely to your personal trading plan.

---

## Source Code

````pine
// © jan80hansen

//@version=6
indicator("Ultimate Multi-Panel Suite", overlay = false)

// -----------------------------------------------------------------------------
// INPUTS: 1. MOVING AVERAGE 1
// -----------------------------------------------------------------------------
g_ma1 = "Moving Average 1"
show_ma1 = input.bool(true, title="Show MA 1", group=g_ma1)
type1    = input.string("EMA", title="Type", options=["SMA", "EMA", "WMA", "HMA", "VWMA", "RMA"], group=g_ma1)
len1     = input.int(20, title="Length", minval=1, group=g_ma1)
col1     = input.color(#2962ff, title="Color", group=g_ma1)

// -----------------------------------------------------------------------------
// INPUTS: 2. MOVING AVERAGE 2
// -----------------------------------------------------------------------------
g_ma2 = "Moving Average 2"
show_ma2 = input.bool(true, title="Show MA 2", group=g_ma2)
type2    = input.string("EMA", title="Type", options=["SMA", "EMA", "WMA", "HMA", "VWMA", "RMA"], group=g_ma2)
len2     = input.int(50, title="Length", minval=1, group=g_ma2)
col2     = input.color(#ff5252, title="Color", group=g_ma2)

// -----------------------------------------------------------------------------
// INPUTS: 3. VWAP
// -----------------------------------------------------------------------------
g_vwap = "VWAP"
show_vwap = input.bool(true, title="Show VWAP", group=g_vwap)
col_vwap  = input.color(#2196f3, title="Color", group=g_vwap)

// -----------------------------------------------------------------------------
// INPUTS: 4. SUPPORT & RESISTANCE
// -----------------------------------------------------------------------------
g_sr = "Support & Resistance"
show_sr = input.bool(true, title="Show S/R Lines", group=g_sr)
piv_len = input.int(20, title="Lookback Period", minval=5, group=g_sr)
col_res = input.color(color.new(color.red, 10), title="Resistance Color", group=g_sr)
col_sup = input.color(color.new(color.green, 10), title="Support Color", group=g_sr)

// -----------------------------------------------------------------------------
// INPUTS: 5. MACD
// -----------------------------------------------------------------------------
g_macd = "MACD Panel"
show_macd = input.bool(true, title="Show MACD", group=g_macd)
fast_l    = input.int(12, title="Fast Length", group=g_macd)
slow_l    = input.int(26, title="Slow Length", group=g_macd)
sig_l     = input.int(9, title="Signal Length", group=g_macd)
col_macd  = input.color(#2962ff, title="MACD Line Color", group=g_macd)
col_sig   = input.color(#ff6d00, title="Signal Line Color", group=g_macd)

// -----------------------------------------------------------------------------
// INPUTS: 6. RSI
// -----------------------------------------------------------------------------
g_rsi = "RSI Panel"
show_rsi = input.bool(true, title="Show RSI", group=g_rsi)
rsi_l    = input.int(14, title="RSI Length", group=g_rsi)
col_rsi  = input.color(#7e57c2, title="RSI Line Color", group=g_rsi)
rsi_ob   = input.int(70, title="Overbought Level", group=g_rsi)
rsi_os   = input.int(30, title="Oversold Level", group=g_rsi)

// -----------------------------------------------------------------------------
// CALCULATIONS & HELPER FUNCTION
// -----------------------------------------------------------------------------
f_ma(t, s, l) =>
    r = switch t
        "SMA"  => ta.sma(s, l)
        "EMA"  => ta.ema(s, l)
        "WMA"  => ta.wma(s, l)
        "HMA"  => ta.hma(s, l)
        "VWMA" => ta.vwma(s, l)
        "RMA"  => ta.rma(s, l)
        => ta.ema(s, l)
    r

val1 = f_ma(type1, close, len1)
val2 = f_ma(type2, close, len2)

p_h = ta.pivothigh(high, piv_len, piv_len)
p_l = ta.pivotlow(low, piv_len, piv_len)
var float res_lvl = na
var float sup_lvl = na
if not na(p_h)
    res_lvl := high[piv_len]
if not na(p_l)
    sup_lvl := low[piv_len]

[mLine, sLine, hLine] = ta.macd(close, fast_l, slow_l, sig_l)
rLine = ta.rsi(close, rsi_l)

// -----------------------------------------------------------------------------
// PLOTTING (OVERLAY = TRUE FOR MAIN CHART ELEMENTS, FALSE FOR PANELS)
// -----------------------------------------------------------------------------
plot(show_ma1 ? val1 : na, title="MA 1", color=col1, linewidth=2, force_overlay=true)
plot(show_ma2 ? val2 : na, title="MA 2", color=col2, linewidth=2, force_overlay=true)
plot(show_vwap ? ta.vwap : na, title="VWAP", color=col_vwap, linewidth=2, force_overlay=true)

plot(show_sr ? res_lvl : na, title="Resistance", color=col_res, linewidth=2, style=plot.style_linebr, force_overlay=true)
plot(show_sr ? sup_lvl : na, title="Support", color=col_sup, linewidth=2, style=plot.style_linebr, force_overlay=true)

plot(show_macd ? mLine : na, title="MACD", color=col_macd)
plot(show_macd ? sLine : na, title="Signal", color=col_sig)

plot(show_rsi ? rLine : na, title="RSI", color=col_rsi)
hline(show_rsi ? rsi_ob : na, title="RSI Overbought", color=color.gray, linestyle=hline.style_dashed)
hline(show_rsi ? rsi_os : na, title="RSI Oversold", color=color.gray, linestyle=hline.style_dashed)
````
