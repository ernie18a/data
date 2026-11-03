Calculation: Lower-timeframe signed volume = volume of the last completed lower-timeframe bar if its close > open, negative volume if its close < open, otherwise 0; calculate its EMA on chart bars.
Calculation: Trend measure = 1 - log10(sum of true range over the lookback / max(highest high - lowest low over the lookback, minimum price increment)) / log10(lookback).
Calculation: Regime = persistent state initially neutral. When the trend measure > trend threshold AND ADX > upper ADX threshold, set bullish if RSI > midpoint AND positive DI > negative DI AND signed-volume EMA >= 0 AND close > close EMA; otherwise set bearish if RSI < midpoint AND negative DI > positive DI AND signed-volume EMA <= 0 AND close < close EMA. When the trend condition is false, binary mode is disabled, and the trend measure < reset threshold OR ADX < lower ADX threshold, set neutral. With binary mode disabled, also set a bullish regime to neutral if close < close EMA, or a bearish regime to neutral if close > close EMA. Otherwise retain the previous state. The reset threshold is lower than the trend threshold, and the lower ADX threshold is below the upper ADX threshold.
Long: Regime display enabled AND regime = bullish AND regime = previous bar's regime
Short: Regime display enabled AND regime = bearish AND regime = previous bar's regime
Exit: long, close >= average entry price × (1 + minimum profit fraction) AND close < close EMA
Exit: short, close <= average entry price × (1 - minimum profit fraction) AND close > close EMA
Exit: long, close <= average entry price × (1 - close-based loss fraction)
Exit: short, close >= average entry price × (1 + close-based loss fraction)
Exit: long, high >= average entry price × (1 + maximum profit fraction)
Exit: short, low <= average entry price × (1 - maximum profit fraction)