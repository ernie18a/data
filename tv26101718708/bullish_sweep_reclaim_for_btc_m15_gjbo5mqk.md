# Bullish Sweep & Reclaim for BTC M15

- url: https://www.tradingview.com/script/gJBo5mqK-Bullish-Sweep-Reclaim-for-BTC-M15/
- type: indicator
- pine_id: PUB;6b56f99f9ae44432a83b443014128e99
- version: 1.0

## Description

Bullish Sweep & Reclaim — Indicator Summary

Disclaimer: 

This indicator is tuned and tweaked to find entries on the bitcoin 15 minute time frame only, I have not tested it on any other asset or time frames. use it wisely and manage your TP and SL as the patterns form.

i have back tested this strategy till 2020 and have tweak the numbers to give the cleanest most promising setup, i suggest keeping all values in the settings the same. or if you're a pro, feel free to tweak it more and test it further and share back with me if you find better values.

Although this is a fractal setup which works on most time frames, it is only tuned to catch setups on the M15 Chart


Overview

The Bullish Sweep & Reclaim indicator is a pattern-based tool built for the 15-minute timeframe, designed primarily around Bitcoin (BTC) price behavior. It identifies a specific three-leg liquidity grab sequence where the market flushes out stops below a recent low before reversing sharply back upward. The indicator marks these moments on the chart in real time, plotting a buy signal, a take profit level, a stop loss level, and the key price zone that anchors the setup.

The Core Pattern

The setup is built on three distinct candles, each playing a specific role.

The first leg is called the Drop Candle. This is a bearish candle that acts as the origin of the setup. It represents a meaningful downside move where sellers were in control. The Drop Candle establishes the key price range — its high and low are used later to define the take profit target and the zone that price must reclaim.

The second leg, C2, is any candle after the Drop Candle whose close falls below the Drop Candle's low. This confirms that selling pressure continued and that liquidity — in the form of stop loss orders from buyers — has been building up beneath that level.

The third leg, C3, is the signal bar. This is the current candle, and for the pattern to fire it must do two things simultaneously: its low must sweep below the C2 low, and it must close back above the Drop Candle's wick low. This combination signals that the market reached down to grab the liquidity sitting below those stops, then rejected sharply, with buyers stepping in and closing price back inside the prior range. This is the classic sweep and reclaim structure.

Drop Candle Filters

Because not every bearish candle is worth trading, the indicator includes a layered filter system to qualify the Drop Candle before it is used as the setup anchor. Each filter is independently toggled, giving full control over how strict the criteria are.

The RSI filter requires the RSI to be below a user-defined threshold at the time the Drop Candle forms, ensuring it occurred during genuine bearish momentum rather than a minor pullback. The default threshold is 54, which can be tightened to 45 or lower for fewer but higher-conviction signals.

The SMA filter requires the Drop Candle's low to pierce below a simple moving average — defaulting to the 100-period SMA. This ensures the candle pushed into a statistically significant area of price, filtering out shallow dips that lack structural importance.

The VWAP filter requires the Drop Candle to close below the session VWAP. Since VWAP represents the average price weighted by volume, a close below it confirms the candle formed in a bearish value zone rather than above fair value.

The Bollinger Band midline filter requires the Drop Candle's low to be below the BB basis — the 20-period SMA at the center of the Bollinger Bands. This adds a volatility-adjusted confirmation that the candle extended meaningfully below the midpoint of recent price action.


Optional filters include an EMA close filter and a volume multiplier filter, both disabled by default but available for further precision.

Exit Levels

When the pattern fires, the indicator automatically calculates and plots both a take profit and a stop loss.

The stop loss is placed just below the sweep low with a small configurable buffer. 

The take profit has four options: the Drop Candle's high, or the Drop Candle's range extended by 1.5×, 2.5×, or 3× from the entry close. 

Two solid yellow horizontal lines mark the Drop Candle's high and low zone on the chart for visual reference.

Alerts

A built-in alert condition fires on every valid signal, making it straightforward to set up TradingView notifications for any ticker or timeframe without needing to watch the chart continuously.

## Source Code

````pine
//@version=6
indicator("Bullish Sweep & Reclaim for BTC M15", overlay=true,
          max_lines_count=500, max_labels_count=500)

// =========================================================================
// INPUTS
// =========================================================================
grp_setup = "Setup Detection"
i_lookback     = input.int(5, "Lookback Window (bars)",                           minval=3, maxval=50, group=grp_setup)
i_max_after_dc = input.int(5, "Max Candles After Drop Candle to Validated Setup", minval=1, maxval=20, group=grp_setup,
                           tooltip="How many bars after the Drop Candle the sweep must occur within and close back in the drop candles range")

grp_dc = "Drop Candle Filters"

// RSI filter
i_rsi_filter = input.bool(true,  "Require RSI Below Threshold on Drop Candle",                    group=grp_dc)
i_rsi_len    = input.int(14,     "RSI Length",                                    minval=1,        group=grp_dc)
i_rsi_max    = input.float(54.0, "RSI Max (Drop Candle must be below this)", minval=1, maxval=99,  group=grp_dc,
                           tooltip="Ensures the Drop Candle forms in bearish/oversold territory. Typical: 45 or 50. Lower means less setups")

// MA filter
i_ma_filter  = input.bool(true, "Require Drop Candle Low Below SMA",                              group=grp_dc,
                           tooltip="Drop Candle's low must pierce below the SMA, confirming the candle pushed into bearish territory. Recommended: 50 or 100, to skip the weak setups")
i_ma_len     = input.int(100,   "SMA Length",                                     minval=1,        group=grp_dc)

// EMA filter
i_ema_filter = input.bool(false, "Require Drop Candle Close Below EMA",                           group=grp_dc,
                           tooltip="Drop Candle must close below this EMA length to confirm bearish trend context")
i_ema_len    = input.int(14,     "EMA Length",                                    minval=1,        group=grp_dc)

// VWAP filter
i_vwap_filter = input.bool(true, "Require Drop Candle Close Below VWAP",                          group=grp_dc,
                            tooltip="Drop Candle must close below VWAP, confirming it formed in a bearish price zone")

// Bollinger Band midline filter
i_bb_filter  = input.bool(true,  "Require Drop Candle Low Below BB Midline",                      group=grp_dc,
                           tooltip="Drop Candle's low must be below the Bollinger Band basis (SMA), showing a push into or below the midline")
i_bb_len     = input.int(20,     "BB Length",                                     minval=1,        group=grp_dc)
i_bb_mult    = input.float(2.0,  "BB StdDev",                          minval=0.1, step=0.1,       group=grp_dc)

// Volume filter
i_vol_filter = input.bool(false, "Require Above-Average Volume",                                   group=grp_dc)
i_vol_len    = input.int(20,     "Volume SMA Length",                             minval=1,        group=grp_dc)
i_vol_mult   = input.float(1.1,  "Volume Multiplier (x Avg)",          minval=0.1, step=0.1,       group=grp_dc,
                           tooltip="Drop Candle volume must exceed this multiple of the SMA. e.g. 1.5 = 50% above average")

grp_exit = "Exit Settings"
i_tp_method = input.string("Drop Candle High", "TP Options",
             options=["Drop Candle High", "Range x1.5", "Range x2.5", "Range x3"],
             group=grp_exit)
i_sl_buf    = input.float(0.02, "SL Buffer % below Sweep Low", minval=0, step=0.01, group=grp_exit) / 100

// =========================================================================
// INDICATORS
// =========================================================================
vol_sma  = ta.sma(volume, i_vol_len)
rsi_val  = ta.rsi(close, i_rsi_len)
ema_val  = ta.ema(close, i_ema_len)
vwap_val = ta.vwap(hlc3)
bb_basis = ta.sma(close, i_bb_len)
ma_val   = ta.sma(close, i_ma_len)

// =========================================================================
// PATTERN DETECTION
// Legs:
//   Drop Candle (DC) = bearish candle passing all enabled filters
//   C2               = bar after DC whose CLOSE is below DC low
//   C3               = current bar: sweeps C2 low AND closes above DC low,
//                      within i_max_after_dc bars of DC
// =========================================================================

found_dc_high = float(na)
found_dc_low  = float(na)
found_dc_bar  = int(na)
found_c2_low  = float(na)

for i = 2 to i_lookback
    if i > i_max_after_dc
        continue

    dc_h = high[i]
    dc_l = low[i]

    dc_is_bear  = close[i] < open[i]
    dc_rsi_ok   = i_rsi_filter  ? (rsi_val[i] < i_rsi_max)                : true
    dc_ma_ok    = i_ma_filter   ? (dc_l        < ma_val[i])               : true
    dc_ema_ok   = i_ema_filter  ? (close[i]    < ema_val[i])              : true
    dc_vwap_ok  = i_vwap_filter ? (close[i]    < vwap_val[i])             : true
    dc_bb_ok    = i_bb_filter   ? (dc_l         < bb_basis[i])            : true
    dc_vol_ok   = i_vol_filter  ? (volume[i]   >= vol_sma[i] * i_vol_mult): true

    if dc_is_bear and dc_rsi_ok and dc_ma_ok and dc_ema_ok and dc_vwap_ok and dc_bb_ok and dc_vol_ok
        best_c2_low = float(na)
        for j = 1 to i - 1
            if close[j] < dc_l
                best_c2_low := na(best_c2_low) ? low[j] : math.min(best_c2_low, low[j])

        if not na(best_c2_low)
            found_dc_high := dc_h
            found_dc_low  := dc_l
            found_dc_bar  := bar_index[i]
            found_c2_low  := best_c2_low
            break

// C3: current bar sweeps C2 low and closes back above Drop Candle low
pattern_found = false
sig_tp        = float(na)
sig_sl        = float(na)
sig_dc_high   = float(na)
sig_dc_low    = float(na)
sig_dc_bar    = int(na)

if not na(found_c2_low) and not na(found_dc_low)
    if low <= found_c2_low and close > found_dc_low
        sl_price = low * (1.0 - i_sl_buf)
        dc_range = found_dc_high - found_dc_low
        tp_price = switch i_tp_method
            "Drop Candle High" => found_dc_high
            "Range x1.5"       => close + dc_range * 1.5
            "Range x2.5"       => close + dc_range * 2.5
            "Range x3"         => close + dc_range * 3.0
            => found_dc_high

        pattern_found := true
        sig_tp        := tp_price
        sig_sl        := sl_price
        sig_dc_high   := found_dc_high
        sig_dc_low    := found_dc_low
        sig_dc_bar    := found_dc_bar

// =========================================================================
// VISUALS
// =========================================================================
if pattern_found
    // Drop Candle zone — both solid yellow
    line.new(sig_dc_bar, sig_dc_high, bar_index + 20, sig_dc_high,
             color=color.yellow, width=2, style=line.style_solid)
    line.new(sig_dc_bar, sig_dc_low,  bar_index + 20, sig_dc_low,
             color=color.yellow, width=2, style=line.style_solid)

    // TP — dotted green line + label
    line.new(bar_index, sig_tp, bar_index + 20, sig_tp,
             color=color.lime, width=2, style=line.style_dotted)
    label.new(bar_index + 20, sig_tp, "TP",
              textcolor=color.lime, color=color.new(color.black, 100),
              style=label.style_label_left, size=size.small)

    // SL — dotted red line + label
    line.new(bar_index, sig_sl, bar_index + 20, sig_sl,
             color=color.red, width=2, style=line.style_dotted)
    label.new(bar_index + 20, sig_sl, "SL",
              textcolor=color.red, color=color.new(color.black, 100),
              style=label.style_label_left, size=size.small)


// Buy arrow
plotshape(pattern_found, style=shape.triangleup, location=location.belowbar,
          color=color.lime, size=size.normal, title="Buy Signal",
          text="Buy", textcolor=color.lime)

// =========================================================================
// ALERTS
// =========================================================================
alertcondition(pattern_found, "Sweep & Reclaim",
               "Sweep & Reclaim on {{ticker}} / {{interval}}")
````
