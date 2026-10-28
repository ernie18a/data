Calculation: Normalized price = (close − lowest low over normalization lookback) / (highest high over the same lookback − lowest low over the same lookback)
Calculation: Normalized volatility = standard deviation of normalized price over a lookback.
Calculation: Upper and lower volatility ranks = (bars since the highest or lowest normalized volatility over the box lookback + box lookback) / box lookback, respectively.
Calculation: Channel top and bottom = highest high and lowest low, respectively, over the period since the last crossover of the lower volatility rank above the upper volatility rank. Create a channel when the upper rank crosses above the lower rank and that period exceeds a minimum duration; if nested channels are disabled, create it only when it does not overlap an existing channel.
Calculation: Breakout price = close, or the average of open and close when strong closes are enabled.
Long: An active channel exists AND breakout price > channel top
Short: An active channel exists AND breakout price < channel bottom