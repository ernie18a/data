# RCA Relative Volume (RVol)

- url: https://www.tradingview.com/script/Oouaio1X-RCA-Relative-Volume-RVol/
- type: indicator
- pine_id: PUB;01b6df77075244509a447fc09d724501
- version: 1.0

## Description

In the financial and trading markets, RVOL stands for Relative Volume. It is a technical indicator that compares the current trading volume of a stock (or other asset) to its average historical volume over a specified period (such as 10, 20, or 30 days). In this case, the average is calculated over the data of the same time of day (ex. 9:45 am current volume vs 10-day 9:45 am average volume).

The Formula= Current Volume/Volume. 

RVOL of 1.0: The asset is trading at its exact average volume for that time of day.
RVOL above 2.0: The asset is "in play" and trading at twice its normal volume. This usually signals heightened market interest, increased liquidity, and the potential for large, volatile price movements.
RVOL below 1.0: The asset is experiencing lower-than-average market participation, typically resulting in a quieter, less volatile trading session.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RCACapitalFund

//@version=6
indicator("Relative Volume (RVol)", overlay=false)

// Input for number of days to average
days = input.int(10, title="Days to Average", minval=1)

// Number of 2-minute bars per trading day (9:30 AM - 4:00 PM = 390 minutes / 2 = 195 bars)
bars_per_day = 195

// Calculate sum of volumes from the same time of day over past days
float sum_volume = 0.0
int count = 0
for i = 1 to days
    // Look back to the bar at the same time on the i-th previous day
    vol = volume[bars_per_day * i]
    if not na(vol)
        sum_volume := sum_volume + vol
        count := count + 1

// Calculate the average volume
float average_volume = count > 0 ? sum_volume / count : na

// Calculate Relative Volume (RVol)
float rvol = average_volume > 0 ? volume / average_volume : na

// Determine color based on RVol value
color bar_color = rvol > 10 ? color.green : rvol >= 3 and rvol <= 10 ? color.blue : color.red

// Plot RVol as a histogram with conditional colors
plot(rvol, title="RVol", color=bar_color, style=plot.style_histogram, linewidth=2)

// Add a horizontal reference line at 1.0
hline(1.0, title="Average Volume", color=color.gray, linestyle=hline.style_dashed)
````
