# Fully custom SMA/EMA, colored 50 SMA, 15,20,50,100,200

- url: https://www.tradingview.com/script/lZZVFrvY-Fully-custom-SMA-EMA-colored-50-SMA-15-20-50-100-200/
- type: indicator
- pine_id: PUB;d2256c5fd77e4e718d76281ebe3c5255
- version: 1.0

## Description

Description:This indicator streamlines chart real estate by packing four highly customizable moving averages into a single script slot. It is designed for traders who utilize multi-timeframe analysis, structural trend filters, and short-term momentum tracking.

Key Features:

[b]Primary Trend Anchor[/b]: A strict, locked-in Simple Moving Average (defaulted to 50 periods) that features dynamic, real-time color-shifting. The line instantly transitions to green when the asset price closes above it (signaling a structural uptrend) and shifts to red when price drops below it (signaling a structural downtrend).

[b]Momentum Tracker:[/b] A highly responsive second moving average (defaulted to a 15-period EMA) used to gauge short-term pullbacks, trend strength, and mean-reversion zones.

[b]Institutional Support Filters:[/b] Two additional completely independent moving averages (defaulted to 100 and 200 SMAs) that can be individually toggled on or off to reveal major institutional support and resistance horizons.

[b]Full Workspace Control[/b]: Every line features independent toggles for visibility, length inputs, smoothing calculations (SMA vs. EMA), and custom hexadecimal color pickers.

## Source Code

````pine
//@version=6
indicator("Colored SMA, EMA, 15, 20, 50, 100, 200, CUSTOMIZABLE", overlay=true)

// Helper function to calculate MA types
get_ma(ma_type, src, len) =>
    switch ma_type
        "SMA" => ta.sma(src, len)
        "EMA" => ta.ema(src, len)
        => ta.sma(src, len)

// ==========================================
// LINE 1: STRICT 50 SMA (Trend Filter)
// ==========================================
var string G_MA1 = "1. Strict Trend SMA (Locked to SMA)"
show_ma1     = input.bool(true, "Show SMA 1", group=G_MA1)
ma1_length   = input.int(50, "SMA 1 Length", minval=1, group=G_MA1)
ma1_source   = input.source(close, "SMA 1 Source", group=G_MA1)
ma1_bull_clr = input.color(color.green, "SMA 1 Bullish Color", group=G_MA1)
ma1_bear_clr = input.color(color.red, "SMA 1 Bearish Color", group=G_MA1)
ma1_width    = input.int(3, "SMA 1 Line Width", minval=1, maxval=5, group=G_MA1)

// Calculate SMA 1 & Dynamic Trend Color (Price vs SMA)
sma1_value   = ta.sma(ma1_source, ma1_length)
ma1_color    = close > sma1_value ? ma1_bull_clr : ma1_bear_clr

plot(show_ma1 ? sma1_value : na, title="Strict SMA 1", color=ma1_color, linewidth=ma1_width)


// ==========================================
// LINE 2: CUSTOMIZABLE MA (e.g., 15 or 20)
// ==========================================
var string G_MA2 = "2. Customizable MA 2"
show_ma2     = input.bool(true, "Show MA 2", group=G_MA2)
ma2_type     = input.string("EMA", "MA 2 Type", options=["SMA", "EMA"], group=G_MA2)
ma2_length   = input.int(15, "MA 2 Length", minval=1, group=G_MA2)
ma2_source   = input.source(close, "MA 2 Source", group=G_MA2)
ma2_color    = input.color(color.blue, "MA 2 Color", group=G_MA2)
ma2_width    = input.int(2, "MA 2 Line Width", minval=1, maxval=5, group=G_MA2)

ma2_value    = get_ma(ma2_type, ma2_source, ma2_length)
plot(show_ma2 ? ma2_value : na, title="MA 2", color=ma2_color, linewidth=ma2_width)


// ==========================================
// LINE 3: CUSTOMIZABLE MA (e.g., 100)
// ==========================================
var string G_MA3 = "3. Customizable MA 3"
show_ma3     = input.bool(true, "Show MA 3", group=G_MA3)
ma3_type     = input.string("SMA", "MA 3 Type", options=["SMA", "EMA"], group=G_MA3)
ma3_length   = input.int(100, "MA 3 Length", minval=1, group=G_MA3)
ma3_source   = input.source(close, "MA 3 Source", group=G_MA3)
ma3_color    = input.color(color.orange, "MA 3 Color", group=G_MA3)
ma3_width    = input.int(2, "MA 3 Line Width", minval=1, maxval=5, group=G_MA3)

ma3_value    = get_ma(ma3_type, ma3_source, ma3_length)
plot(show_ma3 ? ma3_value : na, title="MA 3", color=ma3_color, linewidth=ma3_width)


// ==========================================
// LINE 4: CUSTOMIZABLE MA (e.g., 200)
// ==========================================
var string G_MA4 = "4. Customizable MA 4"
show_ma4     = input.bool(true, "Show MA 4", group=G_MA4)
ma4_type     = input.string("SMA", "MA 4 Type", options=["SMA", "EMA"], group=G_MA4)
ma4_length   = input.int(200, "MA 4 Length", minval=1, group=G_MA4)
ma4_source   = input.source(close, "MA 4 Source", group=G_MA4)
ma4_color    = input.color(color.purple, "MA 4 Color", group=G_MA4)
ma4_width    = input.int(2, "MA 4 Line Width", minval=1, maxval=5, group=G_MA4)

ma4_value    = get_ma(ma4_type, ma4_source, ma4_length)
plot(show_ma4 ? ma4_value : na, title="MA 4", color=ma4_color, linewidth=ma4_width)
````
