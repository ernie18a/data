Calculation: POC = hl2 of the most recent bar whose volume equals the highest volume over a lookback window ending at the current bar
Calculation: StochRSI K = short moving average of Stochastic(RSI, RSI, RSI) over a lookback window, where RSI is computed on close
Calculation: LongStop = low of the bar before the long signal bar - multiplier * ATR at the signal bar (fixed from the signal bar until the position closes)
Calculation: ShortStop = high of the bar before the short signal bar + multiplier * ATR at the signal bar (fixed from the signal bar until the position closes)
Long: EMA(close, shorter length) > EMA(close, longer length) AND close > POC AND StochRSI K crosses above the oversold level (K[1] <= level AND K > level); enter at the next bar's open
Short: EMA(close, shorter length) < EMA(close, longer length) AND close < POC AND StochRSI K crosses below the overbought level (K[1] >= level AND K < level); enter at the next bar's open
Exit: long, low <= LongStop OR the Short condition is true
Exit: short, high >= ShortStop