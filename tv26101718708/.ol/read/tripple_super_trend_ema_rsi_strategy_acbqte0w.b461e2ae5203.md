Calculation: EMA = exponential moving average of close on a lower timeframe; use the latest value available on the chart bar without lookahead.
Calculation: K = smoothed stochastic of the RSI of close.
Calculation: D = smoothed K.
Calculation: Long stop = lowest low over a configurable lookback, sampled on the entry bar.
Calculation: Short stop = highest high over a configurable lookback, sampled on the entry bar.
Long: close > EMA AND K > D AND previous K <= previous D AND K < oversold threshold
Short: close < EMA AND K < D AND previous K >= previous D AND K > overbought threshold
Exit: Long, low <= Long stop OR high >= entry price + (entry price - Long stop) × profit factor
Exit: Short, high >= Short stop OR low <= entry price - (Short stop - entry price) × profit factor