Calculation: EMA braid spread = highest minus lowest of a short-lookback EMA of close, an intermediate-lookback EMA of open, and a long-lookback EMA of close
Calculation: ATR separation threshold = ATR multiplied by a separation percentage
Calculation: TMA = simple moving average of (high + low) / 2
Long: short-lookback EMA of close > intermediate-lookback EMA of open AND EMA braid spread > ATR separation threshold OR TMA > its prior-bar value AND its prior-bar value <= its value two bars ago
Short: intermediate-lookback EMA of open > short-lookback EMA of close AND EMA braid spread > ATR separation threshold OR TMA <= its prior-bar value AND its prior-bar value > its value two bars ago