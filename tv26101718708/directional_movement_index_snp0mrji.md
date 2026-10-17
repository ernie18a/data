# Directional Movement Index

- url: https://www.tradingview.com/script/snP0MRjI-Directional-Movement-Index/
- type: strategy
- pine_id: PUB;b12a110ec1704ecda1cd0f45b7d0bb8e
- version: 2.0

## Description

ADX is an oscillating indicator, displayed as a single line, ranging from 0 to 100, it only indicates the strength of the trend and does not indicate its direction. In other words, the ADX is non-directional, meaning that it measures the strength of a trend, but doesn’t distinguish between uptrend and downtrends. So, during a strong uptrend, the ADX rises and during a strong downtrend, the ADX also rises.
Here is how you correctly read what ADX is saying about the market. Here are 5 aspects regarding the interpretation of the ADX:
[list]
[*]1- When ADX is above 25, trend strength is strong. Usually, once the ADX gets above 25 this signals the beginning of a trend. Big moves (upwards or downwards) tend to happen when ADX is right around this number. You can experiment with this number, some traders that want faster signals, tend to use a 20 threshold when trading with the ADX.
2- When ADX is below 25, traders must avoid trend trading strategies as the market is in accumulation or distribution phase. So, when we see the ADX line below 20 or 25 level, we forget about trend following strategies and we apply strategies suitable for a ranging market.
3- When ADX is above 25 and Positive Directional Movement Indicator (+DMI) is above the Negative Directional Movement Indicator (-DMI). ADX measures the strength of an uptrend. The crossover between the 2 Directional Movement Indicator, as the ADX line is well above 25 can result in an excellent bullish move.
4- The Positive Directional Movement Indicator (+DMI) should be above the Negative Directional Movement and the ADX should be above 25 signals for a strong upward trend for long opportunities. When ADX is above 25 and Positive Directional Movement Indicator is below the Negative Directional Movement Indicator, ADX measures the strength of a downtrend and short opportunities.
5- Values over 50 of the ADX indicate a very strong trend
[/list]

There are pros and cons of ADX.

So, why is the ADX useful for traders: First, is excellent at quantifying trend strength. Also, it allows traders to see the strength of bulls and bears at the same time. It is good at filtering out trades, during accumulation periods and is good at identifying trending conditions.

But the ADX also has its limitations. The most important disadvantage is the fact that ADX is a lagging indicator that follows the price, so we must be very careful when we apply this indicator, because we might miss the inception of the trend and join it when it’s nearly over.

Also, it offers many false signals when used on shorter time frames, so it’s advisable to trade it on higher time frames Also, the ADX does not contain all of the data necessary a for proper analysis of price action, so it must be used in combination with other tools or indicators.

Now that we fully covered the good and the bad regarding ADX, let’s see how it is used in a trading strategy.
The trading strategy involves a DMI crossover, confirmed by ADX above consolidation threshold. If +DMI crossover, we take long position and if -DMI crosses over, we take a short position.

Candles are re-colored for easy demonstration of uptrend, downtrend and consolidation periods.

[b]Green candles[/b] – ADX > Consolidation Threshold and +DMI > -DMI
[b]Red candles[/b] – ADX > Consolidation Threshold and +DMI < -DMI
[b]Black candles[/b] – ADX < Consolidation Threshold

[b]Repaint [/b]– This is a non-repainting strategy - All the signals are generated at candle closing. All the calculations are made on previous candle’s open, high, low, close. No request security function is used. No data is being used from higher time frame. Trade exit uses close function instead of exit to avoid limit orders. Only one long trade at a time (no pyramiding) is allowed.

[b]Strategy Time frame[/b] – D (To filter out false signals, higher time frame is recommended)
[b]Strategy For[/b] – Swing Traders
[b]Assets [/b]– Cryptocurrencies + Stocks

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©wojak_bogdanoff
// @version=5
// Directional Movement Index (DMI)

strategy(title="Directional Movement Index", shorttitle="DMI︎", overlay=true, pyramiding=1, calc_on_every_tick=false, calc_on_order_fills=false, initial_capital=100.0, default_qty_type=strategy.percent_of_equity, default_qty_value=100.0, commission_type=strategy.commission.percent, commission_value=0.1, slippage=1)

trade_type = input.string(defval = "Long/Short", title="Position Type", options=["Long/Short", "Long"], group='Trading Settings')
strategy_type = 'DMI'

start_date  = input.time(title='Testing Start Date', defval=timestamp("2017-01-01T00:00:00"), group='Trading Settings')
finish_date = input.time(title='Testing End Date', defval=timestamp("2025-01-01T00:00:00"), group='Trading Settings')

_testperiod = time >= start_date and time <= finish_date
_check = _testperiod

// --- (Start) Ichimoku kinko Hyo ------------------------------------------- // Credits : LonesomeTheBlue

middleDonchian(Length) =>
    lower = ta.lowest(Length), upper = ta.highest(Length)
    math.avg(upper, lower)

conversionPeriods = input.int(defval=9, minval=1, group='Ichimoku Kinko Hyo - Settings')
basePeriods = input.int(defval=26, minval=1, group='Ichimoku Kinko Hyo - Settings')
laggingSpan2Periods = input.int(defval=52, minval=1, group='Ichimoku Kinko Hyo - Settings')
displacement = input.int(defval=26, minval=1, group='Ichimoku Kinko Hyo - Settings')

Tenkan = middleDonchian(conversionPeriods)
Kijun =  middleDonchian(basePeriods)
xChikou = close
SenkouA = middleDonchian(laggingSpan2Periods)
SenkouB = (Tenkan[basePeriods-displacement] + Kijun[basePeriods-displacement]) / 2

plot(Tenkan, color=color.red, title="Tenkan", linewidth=2, display=display.all)
plot(Kijun, color=color.blue, title="Kijun", linewidth=2, display=display.all)
plot(xChikou, color= color.lime , title="Chikou", offset = -displacement, display=display.all)
A = plot(SenkouA, color=color.new(color.red,70), title="SenkouA", offset=displacement, display=display.none)
B = plot(SenkouB, color=color.new(color.green,70), title="SenkouB", offset=displacement, display=display.none)
fill(A, B, color= (SenkouA > SenkouB) ? color.new(color.red,90) : color.new(color.green,90), title='Kumo Cloud')

// --- (End) Ichimoku kinko Hyo --------------------------------------------- //

// --- (Start) Ichimoku conditions ------------------------------------------ // Credits : ThermalWinds

red_kumo_cloud = SenkouA[displacement] > SenkouB[displacement] // Verified
green_kumo_cloud = SenkouA[displacement] < SenkouB[displacement] // Verified
red_kumo_cloud_future = SenkouA > SenkouB // Verified
green_kumo_cloud_future = SenkouA < SenkouB // Verified
close_crosses_kijun = close > Kijun and close[1] < Kijun[1] // Verified
tenkan_over_kijun = Tenkan > Kijun // Verified
tenkan_below_kijun_tenkan_up_kijun_flat = (Tenkan < Kijun) and (ta.change(Tenkan, 1) > 0) and (Kijun[0] == Kijun[1]) // Verified
[close_middle_bb, close_upper_bb, close_lower_bb] = ta.bb(series=close, length=20, mult=1)
chikou_open_space = (xChikou < close_lower_bb[displacement] and xChikou < SenkouA[2*displacement] and xChikou < SenkouB[2*displacement] and xChikou < 2*low[displacement]) or (xChikou > close_upper_bb[displacement] and xChikou > SenkouA[2*displacement] and xChikou > SenkouB[2*displacement] and xChikou > 2*high[displacement]) // Verified
future_senkouB_up_flat =  green_kumo_cloud_future and (ta.change(SenkouB, 1) > 0 or SenkouB[0] == SenkouB[1]) // Verified
tenkan_in_cloud = (Tenkan < SenkouA[displacement] and Tenkan > SenkouB[displacement]) or (Tenkan > SenkouA[displacement] and Tenkan < SenkouB[displacement]) // Verified
kijun_in_cloud = (Kijun < SenkouA[displacement] and Kijun > SenkouB[displacement]) or (Kijun > SenkouA[displacement] and Kijun < SenkouB[displacement]) // Verified
price_in_green_cloud = green_kumo_cloud and ((open < SenkouB[displacement] and open > SenkouA[displacement]) or (high < SenkouB[displacement] and high > SenkouA[displacement]) or (low < SenkouB[displacement] and low > SenkouA[displacement]) or (close < SenkouB[displacement] and close > SenkouA[displacement])) // Verified
price_in_red_cloud = red_kumo_cloud and ((open < SenkouA[displacement] and open > SenkouB[displacement]) or (high < SenkouA[displacement] and high > SenkouB[displacement]) or (low < SenkouA[displacement] and low > SenkouB[displacement]) or (close < SenkouA[displacement] and close > SenkouB[displacement])) // Verified
price_in_cloud = price_in_green_cloud or price_in_red_cloud // Verified
chikou_in_cloud = (green_kumo_cloud[displacement] and (xChikou < SenkouB[2*displacement] and xChikou > SenkouA[2*displacement])) or (red_kumo_cloud[displacement] and (xChikou < SenkouA[2*displacement] and xChikou > SenkouB[2*displacement])) // Verified
price_tenkan_kijun_chikou_not_in_cloud = (not tenkan_in_cloud) and (not kijun_in_cloud) and (not price_in_cloud) and (not chikou_in_cloud) // Verified
cloud_thickness = math.abs(SenkouA[displacement] - SenkouB[displacement])
percent_thick_cloud = green_kumo_cloud ? (cloud_thickness * 100) / SenkouA[displacement] : (cloud_thickness * 100) / SenkouB[displacement]
thickness_threshold = 14, thickest_cloud = ta.highest(percent_thick_cloud, 10000)
thick_cloud = percent_thick_cloud >= (thickest_cloud * (thickness_threshold/100)) // Verified
price_tenkan_kijun_chikou_in_thick_cloud = (not price_tenkan_kijun_chikou_not_in_cloud) and thick_cloud // Verified
proximity_mult = 0.001 // 0.1 %
tenkan_middle_bb = Tenkan + (Tenkan*0), tenkan_upper_bb = Tenkan + (Tenkan*proximity_mult), tenkan_lower_bb = Tenkan + (Tenkan*-proximity_mult)
kijun_middle_bb = Kijun + (Kijun*0), kijun_upper_bb = Kijun + (Kijun*proximity_mult), kijun_lower_bb = Kijun + (Kijun*-proximity_mult)
price_near_tenkan = (open < tenkan_upper_bb and open > tenkan_lower_bb) or (high < tenkan_upper_bb and high > tenkan_lower_bb) or (low < tenkan_upper_bb and low > tenkan_lower_bb) or (close < tenkan_upper_bb and close > tenkan_lower_bb)
price_near_kijun = (open < kijun_upper_bb and open > kijun_lower_bb) or (high < kijun_upper_bb and high > kijun_lower_bb) or (low < kijun_upper_bb and low > kijun_lower_bb) or (close < kijun_upper_bb and close > kijun_lower_bb)
price_near_tenkan_kijun = price_near_tenkan or price_near_kijun
cloud_thickness_future = math.abs(SenkouA[0] - SenkouB[0])
percent_thick_cloud_future = green_kumo_cloud_future ? (cloud_thickness_future * 100) / SenkouA[0] : (red_kumo_cloud_future ? (cloud_thickness_future * 100) / SenkouB[0] : na)
thickness_threshold_future = 0.20
thin_cloud = percent_thick_cloud_future <= thickness_threshold_future
red_2_green_cloud = (SenkouA[displacement+1] > SenkouB[displacement+1]) and (SenkouA[displacement+0] < SenkouB[displacement+0])
green_2_red_cloud = (SenkouA[displacement+1] < SenkouB[displacement+1]) and (SenkouA[displacement+0] > SenkouB[displacement+0])
close_above_cloud = close > SenkouA[displacement] and close > SenkouB[displacement]
close_below_kijun = close < Kijun
tenkan_crossover_kijun = ta.crossover(Tenkan, Kijun)
tenkan_over_cloud = Tenkan > SenkouA[displacement] and Tenkan > SenkouB[displacement]
tenkan_over_red_cloud = red_kumo_cloud and tenkan_over_cloud
kijun_crosses_red_cloud = red_kumo_cloud and ta.crossover(Kijun, SenkouA[displacement])

// --- (End) Ichimoku conditions -------------------------------------------- //

// --- (Start) Directional Movement Index (DMI) ----------------------------- //

dmi_adxSmoothing = input.int(14, title="ADX Smoothing", minval=1, maxval=50, group='ADX / DMI - Setting')
dmi_len = input.int(7, minval=1, title="DI Length", group='ADX / DMI - Setting')
dmi_up = ta.change(high)
dmi_down = -ta.change(low)
dmi_plusDM = na(dmi_up) ? na : (dmi_up > dmi_down and dmi_up > 0 ? dmi_up : 0)
dmi_minusDM = na(dmi_down) ? na : (dmi_down > dmi_up and dmi_down > 0 ? dmi_down : 0)
dmi_rma = ta.rma(ta.tr, dmi_len)
dmi_plus = fixnan(100 * ta.rma(dmi_plusDM, dmi_len) / dmi_rma)
dmi_minus = fixnan(100 * ta.rma(dmi_minusDM, dmi_len) / dmi_rma)
dmi_sum = dmi_plus + dmi_minus
dmi_adx = 100 * ta.rma(math.abs(dmi_plus - dmi_minus) / (dmi_sum == 0 ? 1 : dmi_sum), dmi_adxSmoothing)

plot(dmi_adx, color=#F50057, title="ADX", display=display.none)
plot(dmi_plus, color=#2962FF, title="+DI", display=display.none)
plot(dmi_minus, color=#FF6D00, title="-DI", display=display.none)

dmi_consld_limit=input.int(defval=25, title='Consolidation ADX', group='ADX / DMI - Setting')
dmi_consld=dmi_adx<=dmi_consld_limit
dmi_strong_up=dmi_adx>dmi_consld_limit and dmi_plus>dmi_minus
dmi_strong_down=dmi_adx>dmi_consld_limit and dmi_plus<dmi_minus

barcolor(dmi_consld ? color.new(color.black,0) : na, title='Consolidation region', display=display.none)
barcolor(dmi_strong_up ? color.new(color.green,0) : na, title='Uptrend Region')
barcolor(dmi_strong_down ? color.new(color.red,0) : na, title='Downtrend Region')

dmi_long_e = (not dmi_strong_up[1] and dmi_strong_up[0])
dmi_long_x = (dmi_strong_up[1] and not dmi_strong_up[0]) or (thick_cloud and green_kumo_cloud)

dmi_short_e = (not dmi_strong_down[1]) and dmi_strong_down[0]
dmi_short_x = (dmi_strong_down[1] and not dmi_strong_down[0]) or green_kumo_cloud

// --- (End) Directional Movement Index (DMI) ------------------------------- //

// --- Trade Conditions ----------------------------------------------------- //

var is_long_open=false, var is_short_open=false

long_e = strategy_type == "DMI" ? dmi_long_e : na
long_x = strategy_type == "DMI" ? dmi_long_x : na

short_e = strategy_type == "DMI" ? dmi_short_e : na
short_x = strategy_type == "DMI" ? dmi_short_x : na

long_e_color = input.color(defval=color.new(color.teal,0), title='Long Entry', group='Signals Style - Setting', inline='il1')
long_x_color = input.color(defval=color.new(color.purple,0), title='Long Exit', group='Signals Style - Setting', inline='il1')

is_trade_bar = (long_e and not is_long_open) or (long_x and is_long_open)

barcolor(color=is_trade_bar ? na : (close>open ? color.new(color.green,90) : color.new(color.red,90)), title='Trade Bars')

barcolor(color=(trade_type == 'Long' or trade_type == 'Long/Short') ? long_e and not is_long_open ? long_e_color : na : na, title="Long - Entry Bar", editable=false)
barcolor(color=(trade_type == 'Long' or trade_type == 'Long/Short') ? long_x and is_long_open ? long_x_color : na : na, title="Long - Exit Bar", editable=false)

plotshape((trade_type == 'Long' or trade_type == 'Long/Short') ? long_e and not is_long_open : na, text="B", textcolor=color.white, style=shape.labelup, color=long_e_color, size=size.tiny, location=location.belowbar, title="Long - Entry Labels")
plotshape((trade_type == 'Long' or trade_type == 'Long/Short') ? long_x and is_long_open : na, text="S", textcolor=color.white, style=shape.labeldown, color=long_x_color, size=size.tiny, location=location.abovebar, title="Long - Exit Labels")

plotshape((trade_type == 'Short' or trade_type == 'Long/Short') ? short_e and not is_short_open : na, text="E", textcolor=color.black, style=shape.labeldown, color=color.new(color.yellow,30), size=size.tiny, location=location.abovebar, title="Short - Entry Labels", editable=false)
plotshape((trade_type == 'Short' or trade_type == 'Long/Short') ? short_x and is_short_open : na, text="X", textcolor=color.black, style=shape.labeldown, color=color.new(color.orange,30), size=size.tiny, location=location.abovebar, title="Short - Exit Labels", editable=false)

if long_e and not is_long_open
    is_long_open:=true
if long_x and is_long_open
    is_long_open:=false

if short_e and not is_short_open
    is_short_open:=true
if short_x and is_short_open
    is_short_open:=false

// --- Trade Executions ----------------------------------------------------- //

if trade_type == "Long/Short" and _check
    strategy.entry("Long", strategy.long, comment=" ", when=long_e and _testperiod)
    strategy.close("Long", comment=" ", when=long_x and _testperiod)
    strategy.entry("Short", strategy.short, comment=" ", when=short_e and _testperiod)
    strategy.close("Short", comment=" ", when=short_x and _testperiod)

if trade_type == "Long" and _check
    strategy.entry("Long", strategy.long, comment=" ", when=long_e and _testperiod)
    strategy.close("Long", comment=" ", when=long_x and _testperiod)
````
