# ZC Footprint Strategy FINAL (Long + Short)

- url: https://www.tradingview.com/script/xYz9cdaL-ZC-Footprint-Strategy-FINAL-Long-Short/
- type: strategy
- pine_id: PUB;c36c08670bf74a7fa1b34110c84141ec
- version: 1.0

## Description

**Footprint Delta Futures Strategy**

The Footprint Delta Futures Strategy is a price-action and order flow–based trading approach designed to capture high-probability entries in the futures market by analyzing the imbalance between buyers and sellers at key levels. This strategy integrates footprint chart analysis, delta confirmation, and trend alignment to identify institutional activity and momentum shifts.

At its core, the strategy focuses on **delta**, which represents the difference between aggressive buying and selling pressure. By observing positive and negative delta at specific price levels, traders can detect whether buyers or sellers are in control. A strong positive delta suggests aggressive buyers lifting the offer, while a strong negative delta indicates sellers hitting the bid.

The strategy works best when combined with a higher timeframe trend filter, such as the EMA 50. Trades are only taken in the direction of the prevailing trend to increase probability and reduce noise. For example, long positions are considered when price is above the EMA 50 and supported by strong positive delta, while short positions are initiated when price is below the EMA 50 with confirming negative delta.

A key component of this strategy is identifying **footprint imbalances and absorption zones**. Imbalances occur when there is a significant difference between bid and ask volume at a price level, signaling potential continuation. Absorption, on the other hand, occurs when large opposing orders prevent price from moving further, often indicating a reversal or strong support/resistance level.

Entries are typically triggered when:

* Price breaks and closes above or below a key level (e.g., EMA 50 or structure level)
* Delta confirms the move with strong buying or selling pressure
* Footprint shows imbalance in the direction of the trade

Risk management is strictly enforced using predefined stop-loss levels, typically placed below recent structure for long trades and above structure for short trades. Take-profit levels can be set based on risk-to-reward ratios (e.g., 1:2 or 1:3) or key liquidity zones.

This strategy is particularly effective in highly liquid futures markets such as indices, commodities, and major contracts, where order flow data provides meaningful insight into market behavior. It is best suited for intraday traders who can actively monitor footprint charts and react to real-time market conditions.

Overall, the Footprint Delta Futures Strategy aims to provide traders with a structured, data-driven approach to understanding market participants’ behavior, improving entry timing, and enhancing trade confidence through order flow confirmation.

## Source Code

````pine
//@version=5
strategy("ZC Footprint Strategy FINAL (Long + Short)", 
     overlay=true,
     process_orders_on_close=true,
     initial_capital=1075,
     default_qty_type=strategy.fixed,
     default_qty_value=1)

// === DATE FILTER ===
start_date = timestamp(2026, 01, 01, 00, 00)
in_date_range = (time >= start_date)

// === FUTURES SETTINGS ===
tick_size = 0.25
tp_ticks = 2
sl_ticks =4

// === FOOTPRINT SETTINGS ===
cnum = 10
lower_tf = "1"

// === ARRAYS ===
var bins = array.new_float(cnum, 0.0)

// === SIGNED VOLUME ===
f_get_signed_volume() =>
    close > open ? volume : close < open ? -volume : 0.0

// === LOWER TF DATA ===
signed_vol = request.security_lower_tf(syminfo.tickerid, lower_tf, f_get_signed_volume())
[tfc, tfo] = request.security_lower_tf(syminfo.tickerid, lower_tf, [close, open])

// === TOTAL DELTA ===
var float total_delta = 0.0

if barstate.isconfirmed
    array.fill(bins, 0.0)

    if array.size(tfc) > 0
        main_high = low
        main_low = high

        for i = 0 to array.size(tfc) - 1
            c_ = array.get(tfc, i)
            o_ = array.get(tfo, i)
            main_high := math.max(main_high, math.max(c_, o_))
            main_low := math.min(main_low, math.min(c_, o_))

        price_range = main_high - main_low
        bin_size = price_range / cnum

        if bin_size > 0
            for i = 0 to array.size(tfc) - 1
                c_ = array.get(tfc, i)
                o_ = array.get(tfo, i)

                lower_bin = math.min(int((math.min(c_, o_) - main_low) / bin_size), cnum - 1)
                higher_bin = math.min(int((math.max(c_, o_) - main_low) / bin_size), cnum - 1)

                width = math.max(math.abs(lower_bin - higher_bin), 1)
                unit_volume = array.get(signed_vol, i) / width

                start_bin = math.max(math.min(higher_bin, lower_bin), 0)
                end_bin = math.min(math.max(higher_bin, lower_bin), cnum - 1)

                for j = start_bin to end_bin
                    array.set(bins, j, array.get(bins, j) + unit_volume)

        total_delta := array.sum(bins)
    else
        total_delta := close > open ? volume : -volume

// === DEBUG ===
plot(total_delta, title="Delta", color=color.yellow)

// === THRESHOLD ===
threshold = input.int(500, "Delta Threshold")

// === CONDITIONS ===
long_condition  = total_delta > threshold and in_date_range and strategy.position_size == 0
short_condition = total_delta < -threshold and in_date_range and strategy.position_size == 0

// === ENTRIES ===
if long_condition
    strategy.entry("BUY", strategy.long)

if short_condition
    strategy.entry("SELL", strategy.short)

// === EXIT ===
if strategy.position_size > 0
    tp = strategy.position_avg_price + tp_ticks * tick_size
    sl = strategy.position_avg_price - sl_ticks * tick_size
    strategy.exit("TP/SL LONG", from_entry="BUY", limit=tp, stop=sl)

if strategy.position_size < 0
    tp = strategy.position_avg_price - tp_ticks * tick_size
    sl = strategy.position_avg_price + sl_ticks * tick_size
    strategy.exit("TP/SL SHORT", from_entry="SELL", limit=tp, stop=sl)

// === VISUAL ===
plotshape(long_condition, location=location.belowbar, color=color.green, style=shape.triangleup, title="BUY")
plotshape(short_condition, location=location.abovebar, color=color.red, style=shape.triangledown, title="SELL")
````
