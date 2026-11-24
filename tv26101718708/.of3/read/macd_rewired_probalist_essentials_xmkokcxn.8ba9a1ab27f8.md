Calculation: MACD line = MACD(source, shorter EMA lookback, longer EMA lookback)
Calculation: MACD signal line = EMA(MACD(source, shorter EMA lookback, longer EMA lookback), signal lookback)
Calculation: MACD histogram = MACD line - MACD signal line
Calculation: MACD histogram pivot low = pivotlow(MACD histogram, pivot lookback, pivot lookback)
Calculation: MACD histogram pivot high = pivothigh(MACD histogram, pivot lookback, pivot lookback)
Calculation: Signal strength = abs(MACD histogram) / standard deviation(MACD histogram, strength lookback)
Calculation: Signed cross outcome = (bullish cross ? 1 : -1) × 100 × (close after outcome horizon / close on cross bar - 1)
Calculation: Recent evidence(direction) = count of up to the latest recent-outcome-window completed signed cross outcomes for direction >= minimum recent-sample count AND Wilson lower confidence bound(fraction of those outcomes > 0, count, confidence level) > minimum win-rate threshold AND median of those outcomes > 0
Long: MACD histogram >= 0
Short: MACD histogram < 0
Long: MACD line crosses above MACD signal line on bar close
Short: MACD line crosses below MACD signal line on bar close
Long: MACD line crosses above zero on bar close
Short: MACD line crosses below zero on bar close
Long: divergence is enabled AND a confirmed MACD histogram pivot low occurs on bar close, no more than divergence-search lookback bars after the preceding confirmed MACD histogram pivot low, AND ((low at the current pivot bar < low at the preceding pivot bar AND current histogram pivot-low value > preceding histogram pivot-low value) OR (low at the current pivot bar > low at the preceding pivot bar AND current histogram pivot-low value < preceding histogram pivot-low value))
Short: divergence is enabled AND a confirmed MACD histogram pivot high occurs on bar close, no more than divergence-search lookback bars after the preceding confirmed MACD histogram pivot high, AND ((high at the current pivot bar > high at the preceding pivot bar AND current histogram pivot-high value < preceding histogram pivot-high value) OR (high at the current pivot bar < high at the preceding pivot bar AND current histogram pivot-high value > preceding histogram pivot-high value))
Long: no previous confirmed MACD signal cross exists AND MACD line > 0 AND MACD line > MACD signal line
Short: no previous confirmed MACD signal cross exists AND MACD line < 0 AND MACD line < MACD signal line
Long: MACD line crosses above MACD signal line on bar close AND Recent evidence(bullish)
Short: MACD line crosses below MACD signal line on bar close AND Recent evidence(bearish)
Long: MACD line crosses above MACD signal line on bar close AND Recent evidence(bullish) AND Signal strength >= minimum strong-signal threshold
Short: MACD line crosses below MACD signal line on bar close AND Recent evidence(bearish) AND Signal strength >= minimum strong-signal threshold