Calculation: selected trigger = the configured one of Stochastic(high, low, close, stochastic lookback), CCI(high, low, close, CCI lookback), RSI(close, RSI lookback), MACD(close, fast EMA, slow EMA, signal EMA), or Momentum(close, momentum lookback); MACD fast lookback is shorter than its slow lookback
Long: selected trigger > selected trigger[1]
Short: selected trigger < selected trigger[1]
Long: selected trigger(T1, bar still forming) > selected trigger[1](T1, last completed bar), evaluated on chart bars taking values from T1
Short: selected trigger(T1, bar still forming) < selected trigger[1](T1, last completed bar), evaluated on chart bars taking values from T1