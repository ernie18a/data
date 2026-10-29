Calculation: EMA rising = 3-period exponential moving average on a configured timeframe is greater on its still-forming bar than on the preceding bar
Calculation: CCI rising = CCI on a configured timeframe is above zero and either above its preceding-bar value or crossed above zero from a preceding-bar value below zero
Calculation: CCI falling = CCI on a configured timeframe is below zero and either below its preceding-bar value or crossed below zero from a preceding-bar value above zero
Calculation: Buy timeframe vote = EMA rising AND CCI above zero AND CCI rising; OR EMA falling AND CCI below zero AND NOT CCI falling
Calculation: Sell timeframe vote = EMA rising AND CCI above zero AND NOT CCI rising; OR EMA falling AND CCI below zero AND CCI falling
Calculation: Bullish votes = number of configured timeframes with a buy timeframe vote
Calculation: Bearish votes = number of configured timeframes with a sell timeframe vote
Calculation: Neutral votes = number of configured timeframes with neither a buy nor sell timeframe vote
Calculation: Bullish MACD crossover = chart-timeframe MACD line on its still-forming bar is at least its signal line, the preceding bar's MACD line was at most its signal line, and the current MACD line is above its preceding-bar value
Calculation: Bearish MACD crossover = chart-timeframe MACD line on its still-forming bar is at most its signal line, the preceding bar's MACD line was at least its signal line, and the current MACD line is below its preceding-bar value
Calculation: Stochastic bullish votes = number of configured timeframes where the still-forming-bar Stochastic main line is above its signal line
Calculation: Stochastic bearish votes = number of configured timeframes where the still-forming-bar Stochastic main line is below its signal line
Calculation: OsMA rising votes = number of configured timeframes where OsMA on its still-forming bar is above its preceding-bar value
Calculation: OsMA falling votes = number of configured timeframes where OsMA on its still-forming bar is below its preceding-bar value
Long: Bullish MACD crossover
Long: Bullish votes > Bearish votes AND Neutral votes < 3
Long: Close on the still-forming bar of the configured lower timeframe is above its preceding-bar close AND Stochastic bullish votes > Stochastic bearish votes AND OsMA rising votes > OsMA falling votes
Short: Bearish MACD crossover
Short: Bearish votes > Bullish votes AND Neutral votes < 3
Short: Close on the still-forming bar of the configured lower timeframe is below its preceding-bar close AND Stochastic bullish votes < Stochastic bearish votes AND OsMA rising votes < OsMA falling votes