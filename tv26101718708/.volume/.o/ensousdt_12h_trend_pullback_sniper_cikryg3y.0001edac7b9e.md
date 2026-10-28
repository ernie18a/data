Calculation: Smoothed Stochastic RSI K = SMA of ((RSI(close) − lowest RSI over the Stochastic RSI lookback) / (highest RSI over that lookback − lowest RSI over that lookback) × 100), using the same lookback for RSI and the stochastic range
Calculation: Smoothed Stochastic RSI D = SMA of Smoothed Stochastic RSI K, using a shorter smoothing lookback than K
Calculation: Long stop = signal-bar close − signal-bar ATR × stop multiplier
Calculation: Long target 1 = signal-bar close + signal-bar ATR × first target multiplier
Calculation: Long target 2 = signal-bar close + signal-bar ATR × second target multiplier
Calculation: Short stop = signal-bar close + signal-bar ATR × stop multiplier
Calculation: Short target 1 = signal-bar close − signal-bar ATR × first target multiplier
Calculation: Short target 2 = signal-bar close − signal-bar ATR × second target multiplier
Long: position is flat AND shortest-lookback EMA > middle-lookback EMA AND close > longest-lookback EMA AND close > VWAP(hlc3) AND absolute(close − middle-lookback EMA) <= ATR × pullback multiplier AND current K > current D AND previous K <= previous D AND previous K < oversold threshold
Short: position is flat AND shortest-lookback EMA < middle-lookback EMA AND close < longest-lookback EMA AND close < VWAP(hlc3) AND absolute(close − middle-lookback EMA) <= ATR × pullback multiplier AND current K < current D AND previous K >= previous D AND previous K > overbought threshold
Exit: Long, low <= Long stop OR high >= Long target 1 OR high >= Long target 2
Exit: Short, high >= Short stop OR low <= Short target 1 OR low <= Short target 2
Exit: Long, close < longest-lookback EMA
Exit: Short, close > longest-lookback EMA