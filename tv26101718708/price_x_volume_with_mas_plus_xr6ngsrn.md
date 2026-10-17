# Price x Volume with MAs (Plus)

- url: https://www.tradingview.com/script/Xr6NgsRN-Price-x-Volume-with-MAs-Plus/
- type: indicator
- pine_id: PUB;442aeaf54d48493ebecd00ed0fc689c8
- version: 1.0

## Description

Price × Volume with MAs (Plus)

Overview
The Price × Volume with MAs (Plus) indicator is a liquidity tracking tool designed to isolate major institutional accumulation and capital flow anomalies. While standard volume indicators only track the number of shares traded, this script computes the actual fiat dollar volume (Traded Value) using multi-timeframe anchoring, complete with dynamic background alert triggers for high-liquidity anomalies.

Key Features
Institutional Capital Spikes (Volatilty Alerts): The script continuously tracks immediate liquidity surges. If the raw currency volume exceeds its 20-period moving average by 1.8x or more, it triggers a clear Red Background Alert indicating a massive "institutional footprint." Normal market liquidity defaults to an Aqua background.
Anchored Daily Data Pipeline: No matter what intraday chart timeframe you view (e.g., 5-minute, 15-minute, or 1-hour), the main indicator panel uses request.security to strictly calculate and lock the Daily Typical Price and Daily Volume. This avoids localized scaling errors and presents the true macro daily capital allocation.
3-Tiered Capital Moving Averages: It features three independent moving averages (10-day, 25-day, and 75-day periods) to track short, medium, and long-term capital trends.
Clean Visual Architecture: To keep your workspace from getting cluttered, the Medium (25-day) and Long (75-day) lines run invisibly in the background by default (display = display.none). They handle backend trend alignment but can be turned back on instantly with a single checkmark in the indicator settings.

Core Moving Average Configurations
10-Day Moving Average (Green Line): Active by default. Captures fast, immediate short-term capital rotations.
25-Day Moving Average (Blue Line): Hidden by default. Tracks the one-month structural baseline for institutional activity.
75-Day Moving Average (Red Line): Hidden by default. Serves as a macro, quarterly trend line to identify permanent structural drift in big-money wallets.

How to Interpret and Trade This Script
Spotting the Whales (The Red Dynamic Background): When the background flashes Red, an unusually large sum of money has entered the asset relative to its historical trend line. This signal is crucial for identifying institutional block orders, heavy sector rotations, or earnings-related accumulation/distribution.
True Momentum Confirmation: When price is pushing higher and the plotted histogram columns climb comfortably above the Green 10-Day MA line, it indicates strong market commitment behind the trend, confirming that the move is well-funded rather than a low-liquidity retail trap.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © darr3n88

//@version=6
indicator("Price x Volume with MAs (Plus)", overlay=false, format=format.volume)
pv = close * volume
pv_ma = ta.sma(pv, 20)

spike = pv > pv_ma * 1.8

plot(pv, title="Price × Volume", color=color.black, linewidth=2)
//plot(pv_ma, title="PV Average", color=color.gray, linewidth=2)

bgcolor(spike ? color.new(color.red,80) : color.new(color.aqua,80))


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
plot(dailyDollarVolume, title="Money Traded", style=plot.style_columns, color=barColor, linewidth=3)

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
plot(dailyMA2, title="25-Day MA", color=color.blue, linewidth=2, display = display.none)
plot(dailyMA3, title="75-Day MA", color=color.red, linewidth=2, display = display.none)
````
