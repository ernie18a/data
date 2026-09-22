<!-- tradingview-pine-id: PUB;9a2f2e4d2cb5413088a0cda7f1272f95 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# TDI - Goldminds / MMM Jakub Donovan Recreation

Source: https://www.tradingview.com/script/7eYkCr4C-TDI-Goldminds-MMM-Jakub-Donovan-Recreation/

## Description

TDI — Goldminds / MMM

> A Market Makers Method–style TDI combining RSI momentum, moving averages, and volatility bands to identify trend, momentum shifts, and overbought/oversold conditions.

The Traders Dynamic Index (TDI) is a momentum and trend-following oscillator that combines RSI, moving averages, and volatility bands into a single indicator.

This version is based on the Goldminds TDI, adapted for the Market Makers Method (MMM) and reconstructed using the original parameters associated with the Jakub Donovan version.

Core Components:

[*]RSI: 21-period RSI
[*]Volatility Bands: 34-period SMA with a 1.6185 standard-deviation multiplier
[*]Fast MA: 7-period SMA of RSI
[*]Slow MA: 2-period SMA of RSI
[*]Reference Levels: 20 / 30 / 50 / 70 / 80

The TDI can be used to identify momentum shifts, trend direction, overbought/oversold conditions, and potential reversals.

How to interpret it

Green & Red lines
The moving averages of RSI help identify changes in momentum. Crossovers can highlight potential shifts in short-term momentum.

Yellow line
The yellow line represents the RSI's broader average and acts as a useful reference for the overall momentum environment.

Blue bands
The volatility bands expand and contract based on RSI volatility, helping identify periods when momentum becomes unusually extended.

50 level
The 50 level acts as the key momentum midpoint:

* Above 50 → bullish momentum
* Below 50 → bearish momentum

30 / 70
Traditional oversold/overbought zones.

20 / 80
Extreme momentum zones that can help identify potentially exhausted moves.

> Important: The TDI should be used as a confirmation tool rather than as a standalone buy or sell signal. Combining it with price structure, support/resistance, volume, and market conditions can provide stronger trade setups.

---

## Source Code

````pine
//@version=6
indicator("TDI - Goldminds / MMM Jakub Donovan Recreation", shorttitle="TDI MMM", overlay=false)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
rsiPeriod     = input.int(21, minval=1, title="RSI Period")
bandLength    = input.int(34, minval=1, title="Band Length")
lengthrsipl   = input.int(7, minval=0, title="Fast MA on RSI")
lengthtradesl = input.int(2, minval=1, title="Slow MA on RSI")
src           = input.source(close, "Source")

// ─────────────────────────────────────────────
// RSI
// ─────────────────────────────────────────────
r = ta.rsi(src, rsiPeriod)

// ─────────────────────────────────────────────
// TDI VOLATILITY BANDS
// ─────────────────────────────────────────────
ma   = ta.sma(r, bandLength)
offs = 1.6185 * ta.stdev(r, bandLength)

up  = ma + offs
dn  = ma - offs
mid = (up + dn) / 2

// ─────────────────────────────────────────────
// TDI MOVING AVERAGES
// ─────────────────────────────────────────────
fastMA = ta.sma(r, lengthrsipl)
slowMA = ta.sma(r, lengthtradesl)

// ─────────────────────────────────────────────
// REFERENCE LEVELS
// ─────────────────────────────────────────────
hline(20, "Extremely Oversold", color=color.gray)
hline(30, "Oversold",           color=color.gray)
hline(50, "Midline",             color=color.gray)
hline(70, "Overbought",          color=color.gray)
hline(80, "Extremely Overbought",color=color.gray)

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────
plot(up,  "Upper Band",  color=#3286C3, linewidth=2)
plot(dn,  "Lower Band",  color=#3286C3, linewidth=2)
plot(mid, "Middle Band", color=color.yellow, linewidth=2)

plot(slowMA, "Slow MA", color=color.green, linewidth=2)
plot(fastMA, "Fast MA", color=color.red, linewidth=1)
````
