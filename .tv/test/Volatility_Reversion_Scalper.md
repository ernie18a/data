<!-- tradingview-pine-id: PUB;d2324775cb7642a1a695443c68f285b5 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volatility Reversion Scalper

Source: https://www.tradingview.com/script/IMKs0OPw/

## Description

Overview
A strategie don't just blindly buy dips—they hunt for high-probability exhaustion points during market panics. This script combines the legendary a synthetic volatility index with Fibonacci Bollinger Bands to pinpoint exact structural bottoms. It is designed to deploy capital only when the market is fearful and a bullish reversal is technically confirmed.

⚙️ Core Mechanics

Fibonacci Bollinger Bands: Instead of standard deviations, this script utilizes a highly reactive 0.618 Fibonacci multiplier on a 10-period SMA. It wraps tightly around the price action to detect micro-deviations and immediate oversold conditions.

CM Williams Vix Fix: Originally developed by Larry Williams, this component acts as a synthetic VIX for any asset. The strategy waits for the VIX Fix to spike into the 99th percentile, indicating extreme retail capitulation and optimal institutional buying zones.

🎯 Entry Logic (The 3-Key Lock)
A long position is strictly executed when these three conditions align on a confirmed bar:

Volatility Spike: The VIX Fix indicator flashes maximum fear.

Band Pierce: The price opens or closes below the lower Fibonacci Bollinger Band.

Bullish Rejection: The current candle closes green (close > open) following a previous red candle (close[1] < open[1]), signaling immediate buyer step-in and momentum shift.

🛡️ Risk Management & DCA (Dollar Cost Averaging)

Smart Pyramiding: To handle cascading drops and "falling knives," the script features a built-in DCA mechanism. It will only add a new leg to the position if the asset drops 10% or more below your current average entry price.

Fixed Take Profit: The exit logic is purely mechanical and emotionless. A limit order is automatically placed at exactly 5% profit above your average entry price, ensuring rapid capital turnover during high-volatility bounces.

💡 Backtesting & Usage Tips

Timeframe: This logic performs best on Daily (1D) or 4-Hour (4H) charts, where volatility spikes carry true structural weight.

Built-in Date Filter: Includes an adjustable date range (defaulted to 2020–2025) so you can easily stress-test the strategy across specific market regimes, such as the 2020 pandemic crash or the 2022 bear market.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sebpageau
//@version=6
strategy("Volatility Reversion Scalper", overlay=true)

// Paramètres de l'indicateur CM_Williams_Vix_Fix
pd = input.int(11, title="LookBack Period Standard Deviation High")
bbl = input.int(10, title="Bolinger Band Length")
mult = input.float(5.0, minval=1, maxval=5, title="Bollinger Band Standard Deviation Up")
lb = input.int(25, title="Look Back Period Percentile High")
ph = input.float(.99, title="Highest Percentile")
pl = input.float(1.01, title="Lowest Percentile")

// Calcul de l'indicateur CM_Williams_Vix_Fix
wvf = ((ta.highest(close, pd) - low) / ta.highest(close, pd)) * 100
sDev = mult * ta.stdev(wvf, bbl)
midLine = ta.sma(wvf, bbl)
lowerBand = midLine - sDev
upperBand = midLine + sDev
rangeHigh = ta.percentile_linear_interpolation(wvf, int(ph * 100), lb)
rangeLow = ta.percentile_linear_interpolation(wvf, int(pl * 100), lb)
vixFix = wvf >= rangeHigh ? 1 : wvf <= rangeLow ? -1 : 0

// Paramètres de l'indicateur Bollinger Bands Fibonacci ratios
length = input.int(10, title="Length")
src = input.source(close, title="Source") // Mise à jour v6 : input() devient input.source()
multFib = input.float(0.618, title="Multiplier")
basis = ta.sma(src, length)
dev = multFib * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev

// Paramètres de la période de backtesting
startDate = input.time(timestamp("2020-01-01 00:00"), title="Start Date")
endDate = input.time(timestamp("2025-01-01 00:00"), title="End Date")

// Conditions d'achat modifiées
condition1 = close <= lower or open <= lower
condition2 = vixFix == 1
condition3 = close > open and close[1] < open[1]
inDateRange = (time >= startDate) and (time <= endDate)

// Nouvelle condition d'achat
buyCondition = condition1 and condition2 and condition3 and barstate.isconfirmed and inDateRange

// Condition de perte de 0%/5%/10% pour le pyramidage
pyramidCondition = strategy.position_size > 0 and (strategy.position_avg_price - close) / strategy.position_avg_price >= 0.10

if (buyCondition and (strategy.position_size == 0 or pyramidCondition))
    strategy.entry("Long", strategy.long)

// Condition de vente basée sur le rendement
minTakeProfit = strategy.position_avg_price * 1.05

// Utilisation de strategy.exit pour exécuter une vente à prix limite
if (strategy.position_size > 0)
    strategy.exit("Take Profit", "Long", limit=minTakeProfit)

// Affichage des indicateurs
plot(basis, color=color.blue, title="Basis")
plot(upper, color=color.red, title="Upper")
plot(lower, color=color.green, title="Lower")
plotshape(series=vixFix == 1, location=location.belowbar, color=color.green, style=shape.labelup, title="VIX Fix Signal")
````
