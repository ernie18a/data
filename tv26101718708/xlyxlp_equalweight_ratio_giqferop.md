# XLY/XLP Equal-Weight Ratio

- url: https://www.tradingview.com/script/giqFEROP-XLY-XLP-Equal-Weight-Ratio/
- type: indicator
- pine_id: PUB;c53a73e5ded8426798171813a5bd18a4
- version: 1.0

## Description

[b]The Equal-Weight Discretionary/Staples Ratio[/b] measures the ratio between two equal-weighted ETFs from Invesco: the S&P 500 Equal Weight Consumer Discretionary ETF (RSPD) and the S&P 500 Equal Weight Consumer Staples ETF (RSPS). It is the equal-weighted counterpart to the well-known XLY/XLP ratio, which measures the same two sectors using the cap-weighted SPDR funds Consumer Discretionary Select Sector SPDR Fund (XLY) and Consumer Staples Select Sector SPDR Fund (XLP). This ratio is used by traders and investors as a measure of the relative strength of the consumer discretionary sector versus the consumer staples sector.

[b]Why equal-weighted (RSPD/RSPS) instead of cap-weighted (XLY/XLP)?[/b]

In the standard cap-weighted XLY, a handful of mega-cap names dominate the fund — most notably Tesla and Amazon, which together can account for a very large share of XLY's value. As a result, the cap-weighted XLY/XLP ratio often tells you more about the price action of those few heavyweights than about the broad consumer discretionary sector. By using the equal-weighted RSPD and RSPS, every company in each sector contributes roughly the same weight. This removes the distortion from individual giants like Tesla and produces a cleaner, broader read on the underlying breadth of consumer behavior — i.e., how the average discretionary company is doing relative to the average staples company, rather than how Tesla is doing. This makes the equal-weighted ratio a more representative gauge of true risk-on/risk-off sentiment across the consumer economy.

A higher ratio indicates that consumer confidence is higher and people are more willing to spend their money on non-essential items, such as entertainment or luxury goods (discretionary spending). A lower ratio, on the other hand, indicates that consumer confidence is lower and people are gravitating toward essential items like food and household goods (staple spending).

The interpretation of the ratio depends on the current market situation and the analysis of the economic and political factors that may influence consumption. If the ratio rises, it could be an indication of a growing economy and increasing consumer sentiment. However, if it falls, it could be an indication of a weakening economy or declining consumer confidence.

It is important to note that this indicator should not be used as the sole basis for making trading decisions. It is advisable to also consider other indicators, such as technical and fundamental analysis, before making a decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MasterOfDesaster

//@version=6
indicator("Equal-Weight Discretionary/Staples Ratio (RSPD/RSPS)", overlay=false)

// --- Inputs ---
discSym   = input.symbol("AMEX:RSPD", "Discretionary (numerator)")
stapSym   = input.symbol("AMEX:RSPS", "Staples (denominator)")
smaLen    = input.int(20, "SMA Length", minval=1)

// --- Data ---
disc = request.security(discSym, timeframe.period, close)
stap = request.security(stapSym, timeframe.period, close)

ratio = disc / stap
ratioSma = ta.sma(ratio, smaLen)

// --- Plots ---
plot(ratio,    title="RSPD/RSPS Ratio", color=color.blue,   linewidth=2)
plot(ratioSma, title="20-day SMA",      color=color.yellow, linewidth=2)
````
