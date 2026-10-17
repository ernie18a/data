# [blackcat] L2 Reversal Labels Strategy

- url: https://www.tradingview.com/script/FH1VyeNT/
- type: strategy
- pine_id: PUB;6d440a0f83cd42808c15a9c69cab4529
- version: 1.0

## Description

Level: 2

Background

There is a Chinese proverb that says: "The great way leads to simplicity". This indicator is the representative of this meaning. Through the processing of the most common MACD indicator data, it is possible to quickly determine the market price: whether the current price is at a historical high or low, whether a reversal will happen soon, etc. at a glance.



Function

This is the strategy version of the same indicator which performs screening and filtering through the fast and slow line data corresponding to the output of the standard MACD indicator, so as to realize the function of judging the top and bottom of the trend.

Inputs

N/A

Key Signal

Near Top --> Top is reached and reversal may happen soon. (red labels)
Near Bottom --> Bottom is reached and reversal may happen soon. (green labels)

Remarks

The backtest result is picked up and optimized for BTCUSD '2D' time frame, it does not work constantly well for any time frame. You need to combine other indicators for other trading pair and time frame.

You can add alerts for this version.

This is a Level 2 free and open source indicator.

Feedbacks are appreciated.

## Source Code

````pine
    // ____  __    ___   ________ ___________  ___________ __  ____ ___ 
   // / __ )/ /   /   | / ____/ //_/ ____/   |/_  __<  / // / / __ |__ \
  // / __  / /   / /| |/ /   / ,< / /   / /| | / /  / / // /_/ / / __/ /
 // / /_/ / /___/ ___ / /___/ /| / /___/ ___ |/ /  / /__  __/ /_/ / __/ 
// /_____/_____/_/  |_\____/_/ |_\____/_/  |_/_/  /_/  /_/  \____/____/                                              

// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © blackcat1402

//@version=5
strategy("[blackcat] L2 Reversal Labels Strategy", overlay=true,  max_bars_back=5000, max_labels_count=500)

[diff, dea, macd] = ta.macd(close,12, 26, 9)
a1 = ta.barssince(ta.crossover(diff,dea)[1])
a2 = ta.barssince(ta.crossunder(diff,dea)[1])
bottom_zone = (close[a1+1]>close) and (diff>diff[a1+1]) and ta.crossover(diff,dea)
top_zone = (close[a2+1]<close) and (diff[a2+1]>diff) and ta.crossunder(diff,dea)

// Plot labels
l0 = top_zone ? label.new(bar_index, high * 1.0, 'Near Top', color=color.new(color.red, 50), textcolor=color.white, style=label.style_label_down, yloc=yloc.price, size=size.small) : bottom_zone ? label.new(bar_index, low * 1.0, 'Near Bottom', color=color.new(color.green, 50), textcolor=color.white, style=label.style_label_up, yloc=yloc.price, size=size.small) : na

if bottom_zone
    longmsg = 'Bottom Reversal Soon!'
    alert(message=longmsg, freq=alert.freq_once_per_bar_close)
else if top_zone
    shortmsg = 'Top Reversal Soon!'
    alert(message=shortmsg, freq=alert.freq_once_per_bar_close)


longCondition = bottom_zone
if (longCondition)
    strategy.entry("long", strategy.long)

shortCondition = top_zone
if (shortCondition)
    strategy.entry("short", strategy.short)
````
