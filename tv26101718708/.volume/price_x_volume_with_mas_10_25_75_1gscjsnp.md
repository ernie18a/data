# Price X Volume with MAs (10, 25, 75)

- url: https://www.tradingview.com/script/1GSCjsnp-Price-X-Volume-with-MAs-10-25-75/
- type: indicator
- pine_id: PUB;48ca1a410ba54bd28564cff453ac1527
- version: 1.0

## Description

Price X Volume with MAs (10, 25, 75 MAs + Real-Time Summary Dashboard)

Overview
Volume alone only tells you how many shares changed hands, but it completely ignores the monetary size of those transactions. Trading a million shares of a $2 stock is vastly different from trading a million shares of a $200 stock.
The Daily Traded Value indicator solves this by calculating the exact Dollar Volume (Typical Price × Volume) traded every single day, regardless of what intraday timeframe you are currently viewing. It smooths this institutional capital flow using three optimized moving averages (10-day, 25-day, and 75-day) and overlays a real-time, clean Summary Dashboard right in the corner of your indicator panel for instant data reading.

Key Features
True Daily Dollar Volume: Multiplies the daily volume by the daily typical price ((High+Low+Close)/3) to show the actual monetary value entering or exiting the asset.
Multi-Timeframe Anchoring: No matter if you are looking at a 5-minute chart or a 1-hour chart, the indicator uses request.security to strictly compute and display the Daily values.
3-Tiered Trend Analysis: Features three independent moving averages (10, 25, and 75 periods) to track short, medium, and long-term capital trends.
On-Screen Summary Dashboard: A semi-transparent floating table in the top-right corner displays today's exact traded capital alongside the precise values of all three moving averages.
Smart Auto-Formatting: The summary table automatically formats massive numbers dynamically into easily readable Millions (M) or Billions (B) depending on the stock's liquidity pool.

Understanding the 3 Moving Averages
By evaluating capital flow across three distinct horizons, you can easily read institutional behavior:
10-Day Moving Average (Yellow Line): Tracks immediate, fast-reacting momentum. Highlights sudden retail frenzies or immediate algorithmic buying spikes.
25-Day Moving Average (Orange Line): Represents the roughly 1-month structural baseline. This acts as the medium-term equilibrium for money flow.
75-Day Moving Average (White Line): Represents a macro, quarterly trend (approx. 75 trading days in a quarter). This is the key line used to identify heavy institutional accumulation or distribution.

How to Trade / Interpret This Indicator
Institutional Accumulation (Bullish Trend Confirmation): Look for a perfect bullish stack where the 10 MA is above the 25 MA, and the 25 MA is above the 75 MA, with all lines sloping upward. This proves that big funds are consistently maintaining buying pressure over a full financial quarter.
The Volume Crossover Entry: When a stock is consolidating sideways and the short-term 10-day MA crosses aggressively above the 25-day or 75-day line, it implies a massive influx of capital is entering the stock relative to its historical baseline—often preceding a major price breakout.
Liquidity Exhaustion (Divergence): If the price is making new highs but today's Traded Value bars and the fast 10-day MA are failing to breach older volume peaks, liquidity is drying up. This divergence warns you that the rally is hollow and thin, suggesting a potential trend reversal.

Inputs & Customization
Through the indicator settings gear icon, you can completely customize:
Short MA Period: Default is 10.
Medium MA Period: Default is 25.
Long MA Period: Default is 75.
Colors & Styles: Easily adjust the line thicknesses or colors to perfectly match your chart's theme.
Author Note: This tool is designed to help value investors and momentum traders track exactly where the "Big Money" is moving. If you find this script useful, please leave a like and follow for more custom utilities!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © darr3n88

//@version=6
indicator("Price X Volume with MAs (10, 25, 75)", overlay=false, format=format.volume)

// 1. Force the script to pull the Daily Typical Price and Daily Volume
dailyPrice  = request.security(syminfo.tickerid, "D", hlc3)
dailyVolume = request.security(syminfo.tickerid, "D", volume)

// 2. Compute the exact Dollar Volume
dailyDollarVolume = dailyPrice * dailyVolume

// 3. Force the script to pull the Daily Open and Close to color the bars correctly
dailyClose = request.security(syminfo.tickerid, "D", close)
dailyOpen  = request.security(syminfo.tickerid, "D", open)
barColor   = dailyClose >= dailyOpen ? color.new(#26A69A, 50) : color.new(#EF5350, 50)

// 4. Plot the actual monetary value histogram
plot(dailyDollarVolume, title="Money Traded", style=plot.style_histogram, color=barColor, linewidth=3)

// 5. Setup the periods for the three Moving Averages
maPeriod1 = input.int(10, title="Short MA (10)")
maPeriod2 = input.int(25, title="Medium MA (25)")
maPeriod3 = input.int(75, title="Long MA (75)")

// 6. Calculate the SMAs inside the security call to ensure accurate daily averages
dailyMA1 = request.security(syminfo.tickerid, "D", ta.sma(hlc3 * volume, maPeriod1))
dailyMA2 = request.security(syminfo.tickerid, "D", ta.sma(hlc3 * volume, maPeriod2))
dailyMA3 = request.security(syminfo.tickerid, "D", ta.sma(hlc3 * volume, maPeriod3))

// 7. Plot the three trend lines
plot(dailyMA1, title="10-Day MA", color=color.green, linewidth=2)
plot(dailyMA2, title="25-Day MA", color=color.blue, linewidth=2)
plot(dailyMA3, title="75-Day MA", color=color.red, linewidth=2)
````
