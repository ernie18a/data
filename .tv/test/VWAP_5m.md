<!-- tradingview-pine-id: PUB;259ebbd8db774680bcd211d14dd35efa -->
<!-- tradingviewscripts-format: 1 -->
# VWAP 5m

Source: https://www.tradingview.com/script/eLZCnYXV-VWAP-5m/

## Description

Calculates VWAP for each candle using the underlying 5-minute price and volume data, instead of estimating from the HTF candle's open/high/low/close. Always pulls from 5m. No inputs, no bands, just one VWAP line per candle.

When your chart is set above 5 minutes, the script pulls every 5-minute candle inside that bar, multiplies each 5-minute OHLC4 price by its volume, sums them up, and divides by the total volume.

---

## Source Code

````pine
//@version=6
indicator("VWAP 5m", overlay=true)

is_5m = timeframe.in_seconds() <= 300

var float bar_vwap = na

if is_5m
    // Chart is already 5m or lower — nothing smaller to pull, use this bar's OHLC4
    bar_vwap := ohlc4
else
    [ltf_price, ltf_vol] = request.security_lower_tf(syminfo.tickerid, "5", [ohlc4, volume])

    if array.size(ltf_price) > 0
        float pv_sum = 0.0
        float v_sum  = 0.0
        for i = 0 to array.size(ltf_price) - 1
            p = array.get(ltf_price, i)
            v = array.get(ltf_vol, i)
            pv_sum += p * v
            v_sum  += v
        if v_sum > 0
            bar_vwap := pv_sum / v_sum
    // else: no 5m bars returned this chart-bar (e.g. data gap) — bar_vwap holds its last value via `var`

plot(bar_vwap, title="VWAP 5m", color=color.rgb(159, 16, 230), style=plot.style_line, linewidth=3)
````
