Calculation: oscillator score = (if RSI(selected price field, RSI lookback) >= RSI bull-bias level then major score weight, else if RSI(selected price field, RSI lookback) <= RSI bear-bias level then -major score weight, else 0) + (if RSI crosses above RSI buy level then unit score weight, else if RSI crosses below RSI sell level then -unit score weight, else 0) + (if Stochastic K > Stochastic D and Stochastic K > Stochastic midpoint level then major score weight, else if Stochastic K < Stochastic D and Stochastic K < Stochastic midpoint level then -major score weight, else 0) + (if Stochastic K crosses above Stochastic D and Stochastic K < Stochastic sell level then unit score weight, else if Stochastic K crosses below Stochastic D and Stochastic K > Stochastic buy level then -unit score weight, else 0) + (if Stochastic K crosses above Stochastic buy level then unit score weight, else if Stochastic K crosses below Stochastic sell level then -unit score weight, else 0) + (if MACD line > MACD signal line then major score weight, else if MACD line < MACD signal line then -major score weight, else 0) + (if MACD line crosses above MACD signal line then unit score weight, else if MACD line crosses below MACD signal line then -unit score weight, else 0) + (if trend filter enabled and EMA(selected price field, shorter trend-fast lookback) > EMA(selected price field, longer trend-slow lookback) and close > EMA(selected price field, longest trend lookback) then unit score weight, else if trend filter enabled and EMA(selected price field, shorter trend-fast lookback) < EMA(selected price field, longer trend-slow lookback) and close < EMA(selected price field, longest trend lookback) then -unit score weight, else 0) + (if volume filter enabled and volume > SMA(volume, volume-average lookback) and close > open then unit score weight, else if volume filter enabled and volume > SMA(volume, volume-average lookback) and close < open then -unit score weight, else 0); major score weight is greater than unit score weight; RSI bull-bias level is greater than RSI bear-bias level; RSI buy level is below RSI sell level; Stochastic buy level is below Stochastic sell level; MACD fast lookback is shorter than slow lookback; trend-fast lookback is shorter than trend-slow lookback, which is shorter than the trend lookback
Long: oscillator score >= watch score threshold magnitude
Short: oscillator score <= -watch score threshold magnitude
Long: oscillator score >= strong score threshold magnitude AND oscillator score[1] < strong score threshold magnitude
Short: oscillator score <= -strong score threshold magnitude AND oscillator score[1] > -strong score threshold magnitude
Long: oscillator score >= watch score threshold magnitude AND oscillator score[1] < watch score threshold magnitude
Short: oscillator score <= -watch score threshold magnitude AND oscillator score[1] > -watch score threshold magnitude
Long: RSI(selected price field, RSI lookback) >= RSI bull-bias level
Short: RSI(selected price field, RSI lookback) <= RSI bear-bias level
Long: RSI(selected price field, RSI lookback) crosses above RSI buy level
Short: RSI(selected price field, RSI lookback) crosses below RSI sell level
Long: Stochastic K > Stochastic D
Short: Stochastic K <= Stochastic D
Long: Stochastic K > Stochastic D AND Stochastic K > Stochastic midpoint level
Short: Stochastic K < Stochastic D AND Stochastic K < Stochastic midpoint level
Long: Stochastic K crosses above Stochastic D
Short: Stochastic K crosses below Stochastic D
Long: Stochastic K crosses above Stochastic buy level
Short: Stochastic K crosses below Stochastic sell level
Long: MACD line > MACD signal line
Short: MACD line < MACD signal line
Long: MACD histogram >= zero line
Short: MACD histogram < zero line
Long: MACD line crosses above MACD signal line
Short: MACD line crosses below MACD signal line