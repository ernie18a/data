# Ichimoku Regime Classifier

- url: https://www.tradingview.com/script/VBQ0M4tO/
- type: indicator
- pine_id: PUB;fa260b1a73514f899b7e080096274b4b
- version: 1.0

## Description

Ichimoku Regime Classifier is an open-source market regime filter that labels conditions as TREND UP, TREND DOWN, or VOLATILE.

This script is designed to solve a practical problem: many entries fail because traders apply the same setup in all environments.
Its purpose is to classify the current market context first, so strategy rules can be adapted to regime.

Methodology

The classifier uses Daily Ichimoku structure plus ADX trend-strength confirmation:

Bullish regime:
Price above the Kumo
ADX above threshold
Tenkan above Kijun
Chikou-style confirmation (current price vs past price)
Bearish regime:
Price below the Kumo
ADX above threshold
Tenkan below Kijun
Opposite Chikou-style confirmation
Volatile regime:
If neither bullish nor bearish set is fully confirmed
Why this combination

Ichimoku provides structural trend context, while ADX filters weak directional phases.
The combination aims to reduce false directional bias during choppy periods and keep regime logic explicit.

How to use

TREND UP: prioritize long-biased setups
TREND DOWN: prioritize short-biased setups
VOLATILE: reduce risk, be selective, or wait for structure
This indicator is intentionally minimal on-chart (single regime label) to keep output readable and unambiguous.

Limitations

Regime transitions can lag, especially after sharp reversals.
This tool is a context filter, not a standalone entry/exit system.

Open-source notice

Published as open source for transparency, review, and customization.

Educational content only. Not financial advice.

## Source Code

````pine
// © samsann
//@version=6
indicator("Ichimoku Regime Classifier", overlay=true)


f_dailyBull() =>
    tenkan = (ta.highest(high, 9) + ta.lowest(low, 9)) / 2
    kijun = (ta.highest(high, 26) + ta.lowest(low, 26)) / 2
    spanA = (tenkan + kijun) / 2
    spanB = (ta.highest(high, 52) + ta.lowest(low, 52)) / 2
    kumoHigh = math.max(spanA[26], spanB[26])
    kumoLow = math.min(spanA[26], spanB[26])
    aboveKumo = close > kumoHigh
    [_, _, adx] = ta.dmi(14, 14)
    chikouBullish = close > close[26]
    aboveKumo and adx > 25 and tenkan > kijun and chikouBullish

f_dailyBear() =>
    tenkan = (ta.highest(high, 9) + ta.lowest(low, 9)) / 2
    kijun = (ta.highest(high, 26) + ta.lowest(low, 26)) / 2
    spanA = (tenkan + kijun) / 2
    spanB = (ta.highest(high, 52) + ta.lowest(low, 52)) / 2
    kumoHigh = math.max(spanA[26], spanB[26])
    kumoLow = math.min(spanA[26], spanB[26])
    belowKumo = close < kumoLow
    [_, _, adx] = ta.dmi(14, 14)
    chikouBearish = close < close[26]
    belowKumo and adx > 25 and tenkan < kijun and chikouBearish

isTrendBull = request.security(syminfo.tickerid, "D", f_dailyBull(), barmerge.gaps_off, barmerge.lookahead_off)
isTrendBear = request.security(syminfo.tickerid, "D", f_dailyBear(), barmerge.gaps_off, barmerge.lookahead_off)
isVolatile = not isTrendBull and not isTrendBear

regime = isTrendBull ? "TREND ▲" : isTrendBear ? "TREND ▼" : "VOLATILE"
col = isTrendBull ? color.green : isTrendBear ? color.red : color.orange

var label regimeLabel = na

if barstate.islast
    label.delete(regimeLabel)
    regimeLabel := label.new(bar_index, high * 1.1, regime, color=col, textcolor=color.white, style=label.style_label_down)
````
