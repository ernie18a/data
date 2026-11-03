Calculation: ATR = average true range over a configurable lookback
Calculation: Band source = selected value from hl2, close, or ohlc4
Calculation: Volatility rank = percentile rank of current ATR within its lookback, divided by 100
Calculation: Adaptive multiplier = max(0.25, base multiplier + (volatility rank - 0.5) × 2 × adaptive range)
Calculation: Trailing upper band = band source + adaptive multiplier × ATR; use the current raw upper band if it is below the prior trailing upper band or the prior close is above the prior trailing upper band, otherwise keep the prior trailing upper band
Calculation: Trailing lower band = band source - adaptive multiplier × ATR; use the current raw lower band if it is above the prior trailing lower band or the prior close is below the prior trailing lower band, otherwise keep the prior trailing lower band
Calculation: Trend direction = switch from bearish to bullish when the current close is above the prior trailing upper band; switch from bullish to bearish when the current close is below the prior trailing lower band; otherwise retain the prior direction
Calculation: Signal EMA = EMA of close
Calculation: Bullish momentum = momentum filter is disabled, or the selected condition is true: RSI is above its midline, or MACD histogram is above zero
Calculation: Bearish momentum = momentum filter is disabled, or the selected condition is true: RSI is below its midline, or MACD histogram is below zero
Long: prior trend direction is bearish AND current trend direction is bullish AND close > signal EMA AND bullish momentum
Short: prior trend direction is bullish AND current trend direction is bearish AND close < signal EMA AND bearish momentum