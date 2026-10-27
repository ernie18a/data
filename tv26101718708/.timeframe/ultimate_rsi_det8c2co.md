# Ultimate RSI

- url: https://www.tradingview.com/script/deT8c2cO-Ultimate-RSI/
- type: indicator
- pine_id: PUB;1569d37af80d4774a711aa797a5f640e
- version: 1.0

## Description

Here is a breakdown of its core features and how they work together:

1. Volatility-Adaptive RSI Length
How it works: Instead of using a static length (like the traditional 14-period RSI), the script calculates the market's standard deviation (volatility).

The Benefit: When the market is highly volatile, the RSI length dynamically shortens, making the indicator more responsive so you can catch quick reversals. When volatility drops (consolidation), the length expands, smoothing the RSI line to filter out "chop" and false signals.

2. Dynamic Overbought / Oversold Zones (Bollinger Bands)
How it works: Standard RSIs use static horizontal lines at 70 and 30. This script applies Bollinger Bands directly to the RSI values themselves.

The Benefit: A reading of 70 isn't always overbought in a strong trend. By wrapping the RSI in a standard deviation channel, you get a dynamic zone. If the RSI breaks above its upper dynamic band, you know momentum is genuinely extreme relative to recent conditions, rather than a fixed arbitrary number.

3. Automated Divergence Detection
How it works: The script constantly scans for discrepancies between price action and RSI momentum.

The Benefit: It automatically plots visual markers on the RSI pane when it detects:

Regular Divergences (Reversals): E.g., Price makes a Lower Low, but RSI makes a Higher Low (Bullish Divergence).

Hidden Divergences (Trend Continuations): E.g., Price makes a Higher Low, but RSI drops to a Lower Low (Hidden Bullish).

4. RSI Moving Average (Signal Line)
How it works: An additional moving average (you can choose between SMA, EMA, RMA, WMA, or HMA) is plotted alongside the RSI.

The Benefit: This acts as a trigger line. An RSI crossing above its EMA can be used as an early entry signal, or as confirmation that momentum has definitively shifted.

5. Multi-Timeframe (MTF) Support
How it works: You can configure the indicator to calculate RSI based on a higher timeframe (e.g., pulling 4-Hour RSI data while you are looking at a 15-minute chart).

The Benefit: This ensures your lower timeframe entries are always aligned with the macro momentum, preventing you from trading against the larger trend.

6. Visual Confluence & Alerts
The RSI line itself is color-coded. For example, it turns bright green when momentum is both above 50 and rising, and dark red when below 50 and falling.

It includes a full suite of alert conditions (divergences and MA crossovers) so you can automate your trading or get pinged when a setup occurs.

In summary, it's designed to replace 3 or 4 different indicators on your chart by giving you adaptive momentum, dynamic exhaustion zones, trend direction, and divergence signals all natively in one branded, professional package.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © created by greymyst

//@version=6
indicator("Ultimate RSI", shorttitle="RSI", overlay=false, format=format.price, precision=2)

// ===========================================================================================================
// INPUTS - CREATED BY GREYMYST
// ===========================================================================================================
// --- Main Settings
grp_main = "Greymyst Core Settings"
src = input.source(close, "Source", group=grp_main)
base_len = input.int(14, "Base RSI Length", minval=1, group=grp_main)
use_mtf = input.bool(false, "Enable Multi-Timeframe (MTF)", group=grp_main)
tf = input.timeframe("240", "Higher Timeframe", group=grp_main)

// --- Adaptive Settings
grp_adapt = "Greymyst Adaptive RSI"
use_adaptive = input.bool(true, "Use Volatility Adaptive Length", group=grp_adapt, tooltip="Dynamically adjusts RSI length based on market volatility. Created by Greymyst.")
adapt_sensitivity = input.float(1.0, "Adaptive Sensitivity", minval=0.1, step=0.1, group=grp_adapt)

// --- Dynamic Zones Settings
grp_zones = "Greymyst Dynamic Zones"
zone_len = input.int(50, "Dynamic Zone Lookback", minval=1, group=grp_zones)
zone_mult = input.float(2.0, "Dynamic Zone StdDev Multiplier", minval=0.1, step=0.1, group=grp_zones)

// --- Signal MA Settings
grp_ma = "Greymyst Signal Line"
show_ma = input.bool(true, "Show RSI Moving Average", group=grp_ma)
ma_type = input.string("EMA", "MA Type", options=["SMA", "EMA", "RMA", "WMA", "HMA"], group=grp_ma)
ma_len = input.int(14, "MA Length", minval=1, group=grp_ma)

// --- Divergence Settings
grp_div = "Greymyst Divergences"
show_reg_div = input.bool(true, "Show Regular Divergences", group=grp_div)
show_hid_div = input.bool(true, "Show Hidden Divergences", group=grp_div)
div_lookback_right = input.int(5, "Pivot Lookback Right", minval=1, group=grp_div)
div_lookback_left = input.int(14, "Pivot Lookback Left", minval=1, group=grp_div)

// ===========================================================================================================
// LOGIC - CREATED BY GREYMYST
// ===========================================================================================================

// Custom Adaptive RSI Function
f_adaptive_rsi(_src, _len, _use_adapt, _sens) =>
    float vol = ta.stdev(_src, _len)
    float avg_vol = ta.sma(vol, _len * 2)
    
    // Prevent division by zero
    float vol_ratio = avg_vol == 0 or vol == 0 ? 1.0 : avg_vol / vol
    
    // Calculate adaptive length
    float raw_len = _use_adapt ? _len * vol_ratio * _sens : _len
    
    // Clamp length to prevent extreme values (between 3 and base_length * 3)
    int clamped_len = math.max(3, math.min(math.round(raw_len), _len * 3))
    
    // Manual RSI calculation to support variable length
    float change = ta.change(_src)
    float up = math.max(change, 0)
    float down = -math.min(change, 0)
    
    float alpha = 1.0 / clamped_len
    
    float rma_up = 0.0
    float rma_down = 0.0
    
    rma_up := na(rma_up[1]) ? ta.sma(up, _len) : alpha * up + (1.0 - alpha) * nz(rma_up[1])
    rma_down := na(rma_down[1]) ? ta.sma(down, _len) : alpha * down + (1.0 - alpha) * nz(rma_down[1])
    
    float rs = rma_up / rma_down
    float res = 100.0 - (100.0 / (1.0 + rs))
    res

// Calculate MTF Function
f_calc_all() =>
    float _rsi = f_adaptive_rsi(src, base_len, use_adaptive, adapt_sensitivity)
    
    // Dynamic Zones
    float _basis = ta.sma(_rsi, zone_len)
    float _dev = zone_mult * ta.stdev(_rsi, zone_len)
    float _upper = _basis + _dev
    float _lower = _basis - _dev
    
    // Moving Average
    float _ma = switch ma_type
        "SMA" => ta.sma(_rsi, ma_len)
        "EMA" => ta.ema(_rsi, ma_len)
        "RMA" => ta.rma(_rsi, ma_len)
        "WMA" => ta.wma(_rsi, ma_len)
        "HMA" => ta.hma(_rsi, ma_len)
        => ta.sma(_rsi, ma_len)
        
    [_rsi, _upper, _lower, _basis, _ma]

// Fetch values (handles MTF)
[rsi_val, rsi_upper, rsi_lower, rsi_basis, rsi_ma] = request.security(syminfo.tickerid, use_mtf ? tf : timeframe.period, f_calc_all())

// ===========================================================================================================
// DIVERGENCES - CREATED BY GREYMYST
// ===========================================================================================================
float ph = ta.pivothigh(rsi_val, div_lookback_left, div_lookback_right)
float pl = ta.pivotlow(rsi_val, div_lookback_left, div_lookback_right)

// Variables to store previous pivots
var float last_ph_rsi = na
var float last_ph_price = na
var float last_pl_rsi = na
var float last_pl_price = na

bool reg_bear_div = false
bool reg_bull_div = false
bool hid_bear_div = false
bool hid_bull_div = false

if not na(ph)
    float current_price_ph = high[div_lookback_right]
    if not na(last_ph_rsi)
        // Regular Bearish: Price Higher High, RSI Lower High
        if current_price_ph > last_ph_price and ph < last_ph_rsi
            reg_bear_div := true
        // Hidden Bearish: Price Lower High, RSI Higher High
        if current_price_ph < last_ph_price and ph > last_ph_rsi
            hid_bear_div := true
    last_ph_rsi := ph
    last_ph_price := current_price_ph

if not na(pl)
    float current_price_pl = low[div_lookback_right]
    if not na(last_pl_rsi)
        // Regular Bullish: Price Lower Low, RSI Higher Low
        if current_price_pl < last_pl_price and pl > last_pl_rsi
            reg_bull_div := true
        // Hidden Bullish: Price Higher Low, RSI Lower Low
        if current_price_pl > last_pl_price and pl < last_pl_rsi
            hid_bull_div := true
    last_pl_rsi := pl
    last_pl_price := current_price_pl

// ===========================================================================================================
// VISUALS & PLOTTING - CREATED BY GREYMYST
// ===========================================================================================================

// Momentum Color Coding
color rsi_col = rsi_val >= 50 ? (rsi_val > rsi_val[1] ? color.new(#00E676, 0) : color.new(#69F0AE, 0)) : (rsi_val < rsi_val[1] ? color.new(#FF5252, 0) : color.new(#FF8A80, 0))

// Background gradient between dynamic zones
color zone_bg_col = color.new(color.gray, 95)
p_upper = plot(rsi_upper, "Dynamic Overbought", color=color.new(#FF5252, 50), style=plot.style_line, linewidth=1)
p_lower = plot(rsi_lower, "Dynamic Oversold", color=color.new(#00E676, 50), style=plot.style_line, linewidth=1)
fill(p_upper, p_lower, color=zone_bg_col, title="Dynamic Zone Fill")

// Plot Midline and Static levels just in case
hline(50, "Midline", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
hline(70, "Static 70", color=color.new(color.gray, 80), linestyle=hline.style_dotted)
hline(30, "Static 30", color=color.new(color.gray, 80), linestyle=hline.style_dotted)

// Plot RSI Signal Line
plot(show_ma ? rsi_ma : na, "RSI Signal MA", color=color.new(color.orange, 0), linewidth=1)

// Plot RSI Line
plot(rsi_val, "Greymyst RSI", color=rsi_col, linewidth=2)

// Plot Divergences
plotshape(show_reg_div and reg_bear_div ? rsi_val[div_lookback_right] : na, title="Regular Bearish Div", style=shape.triangledown, location=location.absolute, color=color.new(#FF5252, 0), size=size.tiny, offset=-div_lookback_right)
plotshape(show_reg_div and reg_bull_div ? rsi_val[div_lookback_right] : na, title="Regular Bullish Div", style=shape.triangleup, location=location.absolute, color=color.new(#00E676, 0), size=size.tiny, offset=-div_lookback_right)
plotshape(show_hid_div and hid_bear_div ? rsi_val[div_lookback_right] : na, title="Hidden Bearish Div", style=shape.xcross, location=location.absolute, color=color.new(#FF8A80, 0), size=size.tiny, offset=-div_lookback_right)
plotshape(show_hid_div and hid_bull_div ? rsi_val[div_lookback_right] : na, title="Hidden Bullish Div", style=shape.xcross, location=location.absolute, color=color.new(#69F0AE, 0), size=size.tiny, offset=-div_lookback_right)

// ===========================================================================================================
// ALERTS - CREATED BY GREYMYST
// ===========================================================================================================
alertcondition(reg_bear_div, title="Greymyst RSI: Regular Bearish Divergence", message="Regular Bearish Divergence detected on Greymyst Ultimate RSI")
alertcondition(reg_bull_div, title="Greymyst RSI: Regular Bullish Divergence", message="Regular Bullish Divergence detected on Greymyst Ultimate RSI")
alertcondition(hid_bear_div, title="Greymyst RSI: Hidden Bearish Divergence", message="Hidden Bearish Divergence detected on Greymyst Ultimate RSI")
alertcondition(hid_bull_div, title="Greymyst RSI: Hidden Bullish Divergence", message="Hidden Bullish Divergence detected on Greymyst Ultimate RSI")
alertcondition(ta.crossover(rsi_val, rsi_ma), title="Greymyst RSI: Cross Over Signal MA", message="Greymyst RSI crossed above its Signal MA")
alertcondition(ta.crossunder(rsi_val, rsi_ma), title="Greymyst RSI: Cross Under Signal MA", message="Greymyst RSI crossed below its Signal MA")
````
