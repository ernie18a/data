Calculation: Premarket high = highest(high) during the premarket session on chart bars
Calculation: Premarket low = lowest(low) during the premarket session on chart bars
Calculation: Premarket range = Premarket high - Premarket low
Calculation: Breakout direction = up on the first chart-bar close above Premarket high or down on the first chart-bar close below Premarket low after the premarket session; retain that direction through the entry cycle
Calculation: ATR buffer = ATR(T1, ATR lookback, calculated on T1 bars and returned to chart bars; use the last completed T1 bar historically and the current forming T1 bar in realtime) × ATR percentage
Calculation: Long stop = if entry price > Premarket high then Premarket low - ATR buffer else entry price - Premarket range - ATR buffer
Calculation: Short stop = if entry price < Premarket low then Premarket high + ATR buffer else entry price + Premarket range + ATR buffer
Calculation: Long target = entry price + (entry price - Long stop) × reward-risk ratio
Calculation: Short target = entry price - (Short stop - entry price) × reward-risk ratio
Calculation: Smoothed exit RSI = SMA(RSI(source, exit RSI lookback), exit RSI smoothing lookback) on chart bars
Calculation: Exit RSI average = SMA of RSI(source, exit RSI lookback) when the selected type is SMA or Bollinger Bands; otherwise use the selected EMA, RMA, WMA, or VWMA, with the exit RSI average lookback, on chart bars
Long: Breakout direction is up AND no entry has occurred since the most recent reset event AND Stochastic RSI D[1] < lower entry threshold AND Stochastic RSI K crosses above D on chart bars AND the chart bar is within the configured entry session and date window
Short: Breakout direction is down AND no entry has occurred since the most recent reset event AND Stochastic RSI D[1] > upper entry threshold AND Stochastic RSI K crosses below D on chart bars AND the chart bar is within the configured entry session and date window
Exit: long, low ≤ Long stop OR high ≥ Long target OR Stochastic RSI D > upper early-exit threshold AND close ≤ entry price AND Smoothed exit RSI < Exit RSI average AND RSI(source, exit RSI lookback) < RSI center level AND RSI(source, exit RSI lookback) < Smoothed exit RSI OR the chart bar is within either forced-close/reset time window
Exit: short, high ≥ Short stop OR low ≤ Short target OR Stochastic RSI D < lower early-exit threshold AND close ≥ entry price AND Smoothed exit RSI > Exit RSI average AND RSI(source, exit RSI lookback) > RSI center level AND RSI(source, exit RSI lookback) > Smoothed exit RSI OR the chart bar is within either forced-close/reset time window