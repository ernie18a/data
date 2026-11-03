Calculation: Trend component = +1 if shorter-period EMA of close > longer-period EMA of close, -1 if shorter-period EMA < longer-period EMA, otherwise 0.
Calculation: Deviation component = +1 if (close - baseline EMA of close) / max(population standard deviation of close over its lookback, minimum price increment) < -positive deviation threshold, -1 if the ratio > positive deviation threshold, otherwise 0.
Calculation: Volume component = +1 if RSI of volume / 50 > volume threshold AND close > open, -1 if RSI of volume / 50 > volume threshold AND close < open, otherwise 0.
Calculation: Momentum component = +1 if EMA of RSI of close > its previous-bar value AND RSI of close > 50, -1 if EMA of RSI of close < its previous-bar value AND RSI of close < 50, otherwise 0.
Calculation: Structure component = +1 if close > (highest high + lowest low) / 2 over the same lookback including the current bar, -1 if close < that midpoint, otherwise 0.
Calculation: Volatility component = +1 if shorter-period ATR / max(longer-period ATR, minimum price increment) < lower volatility threshold, -1 if that ratio > higher volatility threshold, otherwise 0.
Calculation: Composite score = (trend component + deviation component + volume component + momentum component + structure component + volatility component) / 6.
Long: Composite score > positive buy threshold.
Short: Composite score < negative sell threshold.
Long: Trend component > 0 OR deviation component > 0 OR volume component > 0 OR momentum component > 0 OR structure component > 0 OR volatility component > 0.
Short: Trend component < 0 OR deviation component < 0 OR volume component < 0 OR momentum component < 0 OR structure component < 0 OR volatility component < 0.
Short: Shorter-period EMA of close <= longer-period EMA of close.