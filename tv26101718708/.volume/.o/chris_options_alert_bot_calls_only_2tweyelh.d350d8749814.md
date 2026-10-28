Calculation: Volume average = simple moving average of volume over a configurable lookback
Calculation: Volume spike = volume > volume average × a configurable multiplier
Calculation: Previous day high = high of the last completed daily bar aggregated from the backtest bars
Long: (close > VWAP AND short-term EMA > intermediate-term EMA AND RSI ≥ a configurable lower bound AND RSI ≤ a configurable upper bound AND close > previous day high AND volume spike) OR (close > intermediate-term EMA AND intermediate-term EMA > long-term EMA AND RSI ≥ a configurable lower bound AND RSI ≤ a configurable upper bound AND volume > volume average AND close > previous day high)
Short: close < VWAP AND close < short-term EMA AND RSI ≥ a configurable threshold AND volume < volume average