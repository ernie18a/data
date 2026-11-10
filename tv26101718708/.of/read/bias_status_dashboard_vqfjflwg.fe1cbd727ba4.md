Calculation: Stochastic RSI K = SMA of 100 × (RSI of close − lowest RSI) / (highest RSI − lowest RSI) over the stochastic lookback; D = SMA of K over a separate smoothing lookback.
Calculation: Structure direction = +1 when close is above the latest confirmed pivot high, else −1 when close is below the latest confirmed pivot low, else retain the previous direction; initialize to 0. A pivot uses equal left and right lookbacks and is available only after the right lookback has elapsed. An upside break takes precedence if both breaks occur.
Calculation: Timeframe bullish votes = count of: short EMA > medium EMA AND medium EMA > long EMA; RSI > its midpoint; stochastic RSI K > D AND K > its midpoint. Timeframe bearish votes = count of the corresponding reversed comparisons. Calculate these on each configured timeframe using the same indicator parameters. For a higher timeframe, use the last completed bar on historical bars and the forming bar in real time; for a lower timeframe, use the last available intrabar. On the chart timeframe, use the current bar.
Calculation: Timeframe bullish bias = timeframe bullish votes >= 2 AND timeframe bullish votes > timeframe bearish votes. Timeframe bearish bias = timeframe bearish votes >= 2 AND timeframe bearish votes > timeframe bullish votes.
Calculation: Multi-timeframe bullish count = number of configured timeframes with bullish bias; multi-timeframe bearish count = number with bearish bias. Multi-timeframe bullish bias = bullish count >= agreement threshold AND bullish count > bearish count; multi-timeframe bearish bias = bearish count >= agreement threshold AND bearish count > bullish count.
Calculation: Bullish score = count of: structure direction = +1; short EMA > medium EMA AND medium EMA > long EMA; ADX >= trend-strength threshold AND +DI > −DI; ATR / SMA of ATR > weak-volatility threshold; stochastic RSI K > D AND K > its midpoint; RSI > its midpoint; volume > SMA of volume; bar time is within any configured session in the configured timezone; multi-timeframe bullish bias is true. Bearish score uses structure direction = −1, reversed EMA and DI comparisons, stochastic RSI K < D AND K < its midpoint, RSI < its midpoint, and multi-timeframe bearish bias, with the same volatility, volume, and session conditions.
Long: short EMA > medium EMA AND medium EMA > long EMA.
Short: short EMA < medium EMA AND medium EMA < long EMA.
Long: stochastic RSI K > D AND K > its midpoint.
Short: stochastic RSI K < D AND K < its midpoint.
Long: RSI > its midpoint.
Short: RSI < its midpoint.
Long: timeframe bullish votes >= 2 AND timeframe bullish votes > timeframe bearish votes, for any configured timeframe.
Short: timeframe bearish votes >= 2 AND timeframe bearish votes > timeframe bullish votes, for any configured timeframe.
Long: multi-timeframe bullish count >= agreement threshold AND multi-timeframe bullish count > multi-timeframe bearish count.
Short: multi-timeframe bearish count >= agreement threshold AND multi-timeframe bearish count > multi-timeframe bullish count.
Long: bullish score > bearish score AND bullish score >= score threshold.
Short: bearish score > bullish score AND bearish score >= score threshold.