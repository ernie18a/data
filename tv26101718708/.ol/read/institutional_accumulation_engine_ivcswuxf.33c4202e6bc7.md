Calculation: Relative strength = close / benchmark close
Calculation: Accumulation/distribution line = cumulative volume × [(close − low) − (high − close)] / (high − low), using a nonzero denominator
Calculation: Price-volume score = weighted sum of close above its long-term moving average, volume above its average, and close above prior close
Calculation: Smart-money score = weighted sum of accumulation/distribution line above its moving average and volume above its average
Calculation: Relative-strength score = weighted sum of relative strength above its moving average and positive price rate of change
Calculation: PE-expansion proxy score = weighted sum of close above its moving average, RSI below its upper threshold, and relative strength above its moving average
Calculation: Breakout score = weighted sum of ATR below its average, volume above its average, and close above the prior bar’s lookback high
Calculation: Volatility score = higher when ATR is below its average, otherwise lower
Calculation: Institutional score = weighted sum of price-volume, smart-money, relative-strength, PE-expansion proxy, breakout, and volatility scores
Long: Institutional score > accumulation threshold
Short: Institutional score < distribution threshold