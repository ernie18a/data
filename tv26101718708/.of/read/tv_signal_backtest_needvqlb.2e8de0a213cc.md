Calculation: Rating = (mean of 15 moving-average votes + mean of 11 oscillator votes) / 2; each vote is +1 for bullish, −1 for bearish, or 0 for neither.
Calculation: Moving-average vote = +1 when chart close ≥ the selected-resolution SMA; otherwise −1. This applies to each configured moving-average period, including the nominal EMA, Hull, and volume-weighted entries; their implemented calculation is SMA. The Ichimoku vote is always 0. Use the selected-resolution value as supplied by the higher-timeframe request: completed bars historically and the forming bar in real time.
Calculation: RSI vote = +1 when RSI is below its oversold threshold and rising; −1 when above its overbought threshold and falling; otherwise 0.
Calculation: Stochastic vote = +1 when %K is below its lower threshold and greater than %D; −1 when %K is above its upper threshold and less than %D; otherwise 0.
Calculation: CCI vote = +1 when CCI is below its oversold threshold and falling; −1 when above its overbought threshold and rising; otherwise 0.
Calculation: Awesome Oscillator vote = +1 when the oscillator is positive and rising; −1 when negative and falling; otherwise 0.
Calculation: Momentum vote = +1 when close minus its lookback close is ≥ 0; −1 when it is ≤ 0; otherwise 0.
Calculation: MACD vote = +1 when the fast EMA minus the slow EMA is ≥ 0; −1 when it is ≤ 0; otherwise 0. The fast lookback is shorter than the slow lookback.
Calculation: Stochastic RSI vote = +1 when its %K is below its lower threshold and greater than %D; −1 when %K is above its upper threshold and less than %D; otherwise 0.
Calculation: Williams %R vote = +1 when below its oversold threshold and rising; −1 when above its overbought threshold and falling; otherwise 0.
Calculation: Ultimate Oscillator vote = +1 when at or above its upper threshold; −1 when at or below its lower threshold; otherwise 0. It combines three lookbacks: short, medium, and long.
Calculation: Directional Index vote = +1 when ADX is at or above its threshold and +DI > −DI; −1 when ADX is at or above its threshold and +DI < −DI; otherwise 0.
Calculation: Bull Bear Power vote = +1 when bear power is below zero and rising; −1 when bull power is above zero and falling; otherwise 0.
Long: Rating > 0
Short: Rating < 0