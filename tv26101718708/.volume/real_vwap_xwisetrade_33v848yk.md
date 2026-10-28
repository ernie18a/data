# Real VWAP [XWiseTrade]

- url: https://www.tradingview.com/script/33v848YK-Real-VWAP-XWiseTrade/
- type: indicator
- pine_id: PUB;f07c26393f064cdd86493a0182b7c379
- version: 1.0

## Description

True volume-weighted average price using aggregated lower timeframe data.

This indicator calculates a custom VWAP by aggregating any number of lower timeframe candles (e.g., 30 x 1min bars), providing a more responsive and accurate mean than standard session VWAP.

Features:
• Custom lower timeframe and aggregation count
• Selectable price source (HL2, HLC3, OHLC4)
• Weighted standard deviation bands (1-3σ)
• VWAP value label

Ideal for intraday mean reversion, deviation trading, and dynamic support/resistance.

## Source Code

````pine
//@version=6
indicator("Real VWAP [XWiseTrade]", overlay=true, max_lines_count=500)

// === Settings ===
group_settings = "Aggregation Settings"
low_tf       = input.timeframe("1", "Lower Timeframe Source", group=group_settings)
agg_bars     = input.int(30, "Number of Lower TF Bars to Aggregate", minval=1, group=group_settings)
price_source = input.string("HLC3", "Price Source", options=["HL2", "HLC3", "OHLC4"], group=group_settings)
show_label   = input.bool(true, "Show VWAP Label", group=group_settings)
show_bands   = input.bool(true, "Show Standard Deviation Bands", group=group_settings)

// === Price Source Function ===
get_price(src) =>
    float price = na
    if src == "HL2"
        price := (high + low) / 2
    else if src == "HLC3"
        price := (high + low + close) / 3
    else  // OHLC4
        price := (open + high + low + close) / 4
    request.security(syminfo.tickerid, low_tf, price)

// === Aggregate Price and Volume ===
priceArray = array.new_float()
volArray   = array.new_float()

for i = 0 to agg_bars - 1
    price_i = get_price(price_source)[i]
    vol_i   = request.security(syminfo.tickerid, low_tf, volume)[i]
    array.push(priceArray, price_i)
    array.push(volArray, vol_i)

float priceVolSum = 0.0
float volSum      = 0.0

for i = 0 to array.size(priceArray) - 1
    p = array.get(priceArray, i)
    v = array.get(volArray, i)
    priceVolSum += p * v
    volSum      += v

real_vwap = volSum > 0 ? priceVolSum / volSum : na

// === Weighted Standard Deviation ===
float variance_sum = 0.0
for i = 0 to array.size(priceArray) - 1
    p = array.get(priceArray, i)
    v = array.get(volArray, i)
    deviation = p - real_vwap
    weighted_dev_sq = (deviation * deviation) * v
    variance_sum += weighted_dev_sq

std_dev = volSum > 0 ? math.sqrt(variance_sum / volSum) : na

// === Standard Deviation Bands ===
band1_upper = real_vwap + std_dev
band1_lower = real_vwap - std_dev
band2_upper = real_vwap + 2 * std_dev
band2_lower = real_vwap - 2 * std_dev
band3_upper = real_vwap + 3 * std_dev
band3_lower = real_vwap - 3 * std_dev

// === Plots ===
plot(real_vwap, "Aggregated VWAP", color=color.orange, linewidth=2)
plot(show_bands ? band1_upper : na, "+1σ", color=color.new(color.orange, 0), linewidth=1)
plot(show_bands ? band1_lower : na, "-1σ", color=color.new(color.orange, 0), linewidth=1)
plot(show_bands ? band2_upper : na, "+2σ", color=color.new(color.orange, 60), linewidth=1)
plot(show_bands ? band2_lower : na, "-2σ", color=color.new(color.orange, 60), linewidth=1)
plot(show_bands ? band3_upper : na, "+3σ", color=color.new(color.orange, 80), linewidth=1)
plot(show_bands ? band3_lower : na, "-3σ", color=color.new(color.orange, 80), linewidth=1)

// === VWAP Label ===
if show_label and not na(real_vwap)
    label.new(bar_index, real_vwap, 
         text="VWAP: " + str.tostring(real_vwap, format.mintick), 
         style=label.style_label_right, 
         color=color.new(color.orange, 30), 
         textcolor=color.black, 
         size=size.small, 
         yloc=yloc.price)
````
