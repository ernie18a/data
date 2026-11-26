# Overbought/Oversold Split Volume [AloneMask]

- url: https://www.tradingview.com/script/pO6PrMmJ-Overbought-Oversold-Split-Volume-AloneMask/
- type: indicator
- pine_id: PUB;d1a264ec213d4dc3b87267f601681f64
- version: 1.0

## Description

An indicator that displays volume separately - buy/sell, to make it easy to see whether positive or negative volume prevails. Volume is plotted up from the center line (buy) and down from the center line (sell) and is plotted inside the Bollinger Bands to predict its potential overbought/oversold status. The settings include a large variability in choosing the MA base and the way Bollinger Bands depend on volume. User flexibility in choosing the style and colors is a given. The indicator can be used on any instrument (Index, Stock, Currency pairs, Crypto, etc.)

[image]https://www.tradingview.com/x/QiYIq3pm/[/image]

## Source Code

````pine
//@version=6
indicator("Overbought/Oversold Split Volume [AloneMask]", overlay=false)

// =========================================================================
//  1. INPUTS
// =========================================================================

// --- GROUP: SPLIT VOLUME ---
const string G_VOL = "1. Split Volume Settings"
color_buy  = input.color(color.new(color.lime, 10), "Buy color", group=G_VOL)
color_sell = input.color(color.new(color.red, 30), "Sell color", group=G_VOL)

// --- GROUP: BOLLINGER BANDS ---
const string G_BB = "2. Bollinger Bands Settings"
bb_source_type = input.string("Net Volume (Buy - Sell)", "BB source", 
     options=["Net Volume (Buy - Sell)", "Total Volume", "Buy Volume", "Sell Volume"], 
     group=G_BB)

bb_length  = input.int(20, "Period", minval=1, group=G_BB)
bb_mult    = input.float(2.0, "StdDev", minval=0.1, step=0.1, group=G_BB)
bb_ma_type = input.string("EMA", "MA type", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=G_BB)

//BB style & colors
color_basis = input.color(color.orange, "Basis color", group=G_BB)
color_bands = input.color(color.orange, "Bands color", group=G_BB)
color_fill  = input.color(color.new(color.blue, 90), "BB fill color", group=G_BB)
width_basis = input.int(2, "Width - Basis", minval=1, maxval=5, group=G_BB)
width_bands = input.int(1, "Width - Bands", minval=1, maxval=5, group=G_BB)

// =========================================================================
//  2. CALCULATIONS
// =========================================================================

// Split volume calculation
tv = volume == 0 ? 1 : volume
BuyVolume  = (high == low) ? 0.0 : tv * (close - low) / (high - low)
SellVolume = (high == low) ? 0.0 : tv * (high - close) / (high - low)

// Source assignment for Bollinger Bands
bb_src = switch bb_source_type
    "Net Volume (Buy - Sell)" => BuyVolume - SellVolume
    "Total Volume"            => volume
    "Buy Volume"              => BuyVolume
    "Sell Volume"             => -SellVolume

// Function for choice of MA
f_ma(src, len, type) =>
    switch type
        "SMA"        => ta.sma(src, len)
        "EMA"        => ta.ema(src, len)
        "SMMA (RMA)" => ta.rma(src, len)
        "WMA"        => ta.wma(src, len)
        "VWMA"       => ta.vwma(src, len)
        => ta.sma(src, len)

// Raw BB calculation
basis = f_ma(bb_src, bb_length, bb_ma_type)
dev   = bb_mult * ta.stdev(bb_src, bb_length)
upper = basis + dev
lower = basis - dev

// =========================================================================
//  3. PLOTTING
// =========================================================================

// Mid line [0]
plot(0, color=color.white, linewidth=1, title="Mid line (0)", force_overlay=false)

// Volume plotting (buy up, sell down)
plot(BuyVolume, title="Buy Volume", style=plot.style_columns, color=color_buy)
plot(-SellVolume, title="Sell Volume", style=plot.style_columns, color=color_sell)

// Bollinger Bands plotting
p_basis = plot(basis, title="BB Basis", color=color_basis, linewidth=width_basis)
p_upper = plot(upper, title="BB Upper", color=color_bands, linewidth=width_bands)
p_lower = plot(lower, title="BB Lower", color=color_bands, linewidth=width_bands)

// Fill Bollinger Bands
fill(p_upper, p_lower, color=color_fill, title="BB fill")
````
