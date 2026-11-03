Calculation: Body = abs(close − open)
Calculation: Lower wick = min(open, close) − low
Calculation: Upper wick = high − max(open, close)
Long: shorter-lookback EMA > longer-lookback EMA on the chart timeframe AND shorter-lookback EMA > longer-lookback EMA on a higher timeframe, using the last completed higher-timeframe bar AND lower wick > body × rejection multiplier AND close > open
Short: shorter-lookback EMA < longer-lookback EMA on the chart timeframe AND shorter-lookback EMA < longer-lookback EMA on a higher timeframe, using the last completed higher-timeframe bar AND upper wick > body × rejection multiplier AND close < open
Exit: Long, high ≥ entry price + partial target OR high ≥ entry price + runner target OR low ≤ longer-lookback EMA − stop buffer OR low ≤ trailing stop
Exit: Short, low ≤ entry price − partial target OR low ≤ entry price − runner target OR high ≥ shorter-lookback EMA + stop buffer OR high ≥ trailing stop