# Cumulative Rate of Inflation Calculator

- url: https://www.tradingview.com/script/ErZmLxgo-Cumulative-Rate-of-Inflation-Calculator/
- type: indicator
- pine_id: PUB;cc62c6a813644e049f2b93e3c37190e1
- version: 1.0

## Description

https://www.tradingview.com/x/HA6lJtxg/
Overview
The Cumulative Rate of Inflation Calculator (CROIC) indicator visualizes the impact of inflation on purchasing power. By anchoring to the live market price, it adjusts historical prices to reflect what they would be worth in "today’s dollars." The orange line on your chart represents the inflation-adjusted value, showing how much nominal price growth is actually just a result of currency devaluation.

How to Use
Interpreting the Orange Line: * If the orange line is above your candle price, the asset has not kept pace with the set inflation rate (purchasing power has decreased).
If the orange line is below your candle price, the asset has outperformed the inflation rate (purchasing power has increased).

Adjusting Inflation Rates: The cumulative rate of inflation the past 100 years is 1793.4% or 2.98%/yr avg, at the time of this post. You can change the Annual Inflation Rate (%) in the indicator settings (gear icon) to test different economic scenarios (e.g., set to 2.0 for target fed rates or higher to see aggressive devaluation).

Universality: This indicator works on any asset class (Stocks, Crypto, Forex, Metals) because it automatically calculates time relative to the live price.
https://www.tradingview.com/x/19SEuyFd/
https://www.tradingview.com/x/FxSoHj5z/

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Cumulative Rate of Inflation Calculator", shorttitle = "CROIC", overlay=true)

// --- INPUTS ---
// 2.98353% annual compounding equals exactly 1793.4% cumulative over 100 years
annualInflationRate = input.float(2.98353, title="Annual Inflation Rate (%)", step=0.01) / 100 

// --- TIME MATH ---
// Calculate exactly how many years ago this specific bar occurred relative to the current LIVE time
// 31557600000 milliseconds = 1 year (365.25 days)
yearsAgo = (timenow - time) / 31557600000

// --- INFLATION MATH ---
// Multiplies the historical chart price by the inflation factor.
// At the current live bar, yearsAgo is 0, so the adjusted price equals the live price.
// The further back you go, the more it adds value to represent "today's purchasing power."
adjustedPrice = close * math.pow(1 + annualInflationRate, yearsAgo)

// --- PLOTTING ---
plot(adjustedPrice, color=color.orange, title="Today's Dollars", linewidth=2)
````
