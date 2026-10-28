Calculation: Gamma flip = EMA of VWMA(close); if higher-timeframe mode is enabled, use the VWMA from the last completed higher-timeframe bar before applying the EMA.
Calculation: Volatility-scaled zones = gamma flip ± volatility × zone multiplier / 2; acceleration boundaries = gamma flip ± volatility × zone multiplier. Volatility is ATR or standard deviation of close, according to the selected mode.
Calculation: Gamma exposure = (close − gamma flip) / volatility.
Calculation: Gamma velocity = current gamma exposure − prior-bar gamma exposure.
Long: ADX is above its trend threshold AND close crosses above the highest high of the prior lookback bars AND close is above the upper zone AND gamma velocity > 0 AND volume is above a multiple of its recent average.
Short: ADX is above its trend threshold AND close crosses below the lowest low of the prior lookback bars AND close is below the lower zone AND gamma velocity < 0 AND volume is above a multiple of its recent average.
Long: The lowest low over the recent lookback is below the lower acceleration boundary AND close crosses above the lower acceleration boundary AND gamma velocity > 0 AND RSI is oversold.
Short: The highest high over the recent lookback is above the upper acceleration boundary AND close crosses below the upper acceleration boundary AND gamma velocity < 0 AND RSI is overbought.
Long: ADX is below the choppy-market threshold AND the highest high over the recent lookback is at or above the upper acceleration boundary AND close crosses below the upper zone AND gamma velocity < 0.
Short: ADX is below the choppy-market threshold AND the lowest low over the recent lookback is at or below the lower acceleration boundary AND close crosses above the lower zone AND gamma velocity > 0.