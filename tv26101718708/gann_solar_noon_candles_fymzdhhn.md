# Gann Solar Noon Candles

- url: https://www.tradingview.com/script/fYmzdHHN/
- type: indicator
- pine_id: PUB;447dba5f708f43479af47b18675e0f1b
- version: 1.0

## Description

Gann 12:15 Candles is an original indicator inspired by W.D. Gann's theory of time. The core idea is that the critical angle points of the Sun's daily cycle (0°, 90°, 180°, 270°) create significant turning points in financial markets.
How It Works?

The Sun reaches its peak at local noon (12:15) each day. This moment corresponds to the 0° angle for that region. 00:15 (midnight) represents 180° — the exact opposite point. The 12:15 moments of New York, London, and China carry the same astrological significance for their respective regions.
The candles formed at these critical times act as support and resistance points in the market. The high and low levels of the candle at that time become critical zones that price tests in subsequent bars. The direction of the breakout determines the short-term trend direction.
For example, if the low of the 12:15 candle (Turkey time) is broken, the decline may continue; if the high is broken, the rally may gain strength. The same logic applies to the 12:15 candles of other countries — New York's 05:15 candle, London's 10:15 candle, and China's 17:15 candle can all be evaluated as support and resistance zones.
In line with Gann's principle that "time is the most important factor," these times are not randomly selected. Each corresponds to a specific angle in the Sun's daily journey and may trigger simultaneous reactions across global markets.
Colors:

🟣 Purple → Turkey / India times (0° and 180°)
🟢 Green → New York times
🟠 Orange → London times
🔴 Red → China times

Usage Recommendation:

The indicator does not provide buy/sell signals on its own. For best results, observe the direction and breakout of the candle at that time, then confirm with other technical indicators. It has been particularly tested on 15-minute charts.
Settings:

Base Country → If Turkey is selected, 8 critical times calculated according to Turkey time are marked. If India is selected, the times corresponding to India's 12:15 and 00:15 are marked.

Note: All times are displayed in Turkey time (UTC+3). Make sure your chart time is set to UTC+3.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © oguz_ozturk9241

//@version=6
indicator("Gann Solar Noon Candles", shorttitle="Gann SNC", overlay=true, max_bars_back=500)

mode = input.string("Turkey", "Base Country", options=["Turkey", "India"])

// FORMULA: Target = Source + (Target UTC - Source UTC)
// TR UTC+3, NY UTC-4, London UTC+1, China UTC+8, India UTC+5:30
//
// TR 12:15 → NY:     12:15 + (-4-3) = 12:15 - 7 = 05:15
// TR 12:15 → London: 12:15 + ( 1-3) = 12:15 - 2 = 10:15
// TR 12:15 → China:  12:15 + ( 8-3) = 12:15 + 5 = 17:15
// TR 00:15 → NY:     00:15 - 7      = 17:15 (previous day)
// TR 00:15 → London: 00:15 - 2      = 22:15 (previous day)
// TR 00:15 → China:  00:15 + 5      = 05:15
//
// IND 12:15 → TR:    12:15 - 2:30   = 09:45
// IND 00:15 → TR:    00:15 - 2:30   = 21:45
// TR 09:45  → NY:    09:45 - 7      = 02:45
// TR 09:45  → London:09:45 - 2      = 07:45
// TR 09:45  → China: 09:45 + 5      = 14:45
// TR 21:45  → NY:    21:45 - 7      = 14:45
// TR 21:45  → London:21:45 - 2      = 19:45
// TR 21:45  → China: 21:45 + 5      = 02:45

f_min(h, m) => h * 60 + m

bar_h  = hour(time, "UTC+3")
bar_m  = minute(time, "UTC+3")
bar_min = f_min(bar_h, bar_m)

// Turkey set: TR, NY, London, China — 12:15 and 00:15 equivalents
// Hours: 12  00   5  17  10  22  17   5
// Mins : 15  15  15  15  15  15  15  15
tr_set_h = array.from(12,  0,  5, 17, 10, 22, 17,  5)
tr_set_m = array.from(15, 15, 15, 15, 15, 15, 15, 15)
tr_set_c = array.from(
     color.purple, color.purple,
     color.green,  color.green,
     color.orange, color.orange,
     color.red,    color.red)
tr_set_l = array.from(
     "🇹🇷 TR 12:15",  "🇹🇷 TR 00:15",
     "🇺🇸 NY 05:15",  "🇺🇸 NY 17:15",
     "🇬🇧 Lon 10:15", "🇬🇧 Lon 22:15",
     "🇨🇳 Chi 17:15", "🇨🇳 Chi 05:15")

// India set (converted to TR time)
ind_set_h = array.from( 9, 21,  2, 14,  7, 19, 14,  2)
ind_set_m = array.from(45, 45, 45, 45, 45, 45, 45, 45)
ind_set_c = array.from(
     color.purple, color.purple,
     color.green,  color.green,
     color.orange, color.orange,
     color.red,    color.red)
ind_set_l = array.from(
     "🇮🇳 IND 12:15", "🇮🇳 IND 00:15",
     "🇺🇸 NY 02:45",  "🇺🇸 NY 14:45",
     "🇬🇧 Lon 07:45", "🇬🇧 Lon 19:45",
     "🇨🇳 Chi 14:45", "🇨🇳 Chi 02:45")

set_h = mode == "Turkey" ? tr_set_h : ind_set_h
set_m = mode == "Turkey" ? tr_set_m : ind_set_m
set_l = mode == "Turkey" ? tr_set_l : ind_set_l
set_c = mode == "Turkey" ? tr_set_c : ind_set_c

atr_val = ta.atr(14)

for i = 0 to 7
    target = f_min(array.get(set_h, i), array.get(set_m, i))
    if bar_min == target
        col = array.get(set_c, i)
        label.new(
             bar_index,
             high + atr_val * (0.5 + i * 0.3),
             text=array.get(set_l, i),
             color=color.new(col, 20),
             textcolor=color.white,
             style=label.style_label_down,
             size=size.small)
````
