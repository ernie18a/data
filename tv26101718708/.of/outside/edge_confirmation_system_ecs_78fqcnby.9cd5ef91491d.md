Signal-to-options framework: on each completed bar of the underlying index or ETF, evaluate three confirming layers (trend, momentum, volume) and map a confirmed bullish signal to buying calls and a confirmed bearish signal to buying puts. Use three exponential moving averages of close with different lengths: fast, slow, base.

Trend layer:
- Bullish trend: close is above the base EMA and the fast EMA is above the slow EMA.
- Bearish trend: close is below the base EMA and the fast EMA is below the slow EMA.
- Otherwise neutral, and there is no trade.

Momentum layer:
1. Compute a raw momentum value as the percentage difference between a short-period EMA of close and a longer-period EMA of close, relative to the longer EMA.
2. Normalize it to the range -1 to +1 using the rolling highest and lowest raw values over a lookback window. Use 0 if the range is zero.
3. Smooth the normalized value with a short EMA to get a signal line.
- Momentum bullish: normalized value is above zero and above its signal line.
- Momentum bearish: normalized value is below zero and below its signal line.
- Overbought: normalized value is at or above a high threshold.
- Oversold: normalized value is at or below a low threshold.

Volume layer:
- A surge is volume at or above a multiple of its simple moving average over a lookback window.
- A bull surge is a surge on a bar that closes above its open.
- A bear surge is a surge on a bar that closes below its open.

Entry conditions:
- Long condition: bullish trend, momentum bullish, not overbought, and a bull surge. The volume requirement is a toggle; if it is off, ignore volume.
- Short condition: bearish trend, momentum bearish, not oversold, and a bear surge, with the same volume toggle.

Signal de-duplication: remember the last signal direction fired. Fire a long entry (buy calls) only when the long condition is true and the last signal was not long. Fire a short entry (buy puts) only when the short condition is true and the last signal was not short. Update the last signal on each fire, so signals alternate and repeated same-direction signals are suppressed.

There is no explicit exit logic or stop. A position is effectively reversed or replaced only when the opposite signal fires. Stand aside when the trend is neutral.