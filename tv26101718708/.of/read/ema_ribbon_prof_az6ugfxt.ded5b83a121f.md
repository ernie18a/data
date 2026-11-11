Calculation: Ribbon upper and lower bands = maximum and minimum, respectively, of eight EMAs of high with distinct lengths, evaluated a configurable number of bars ago.
Calculation: Liquidity midpoint = midpoint of the most recent bar whose volume equals the highest volume over a lookback ending on that bar; only bars within a configurable number of bars of the dataset's end can update it.
Calculation: RSI midpoint price = close + (RSI lookback - 1) × (smoothed loss - smoothed gain), where gain = max(close - previous close, 0), loss = max(previous close - close, 0), and each smoothed value = (gain or loss)/RSI lookback + (1 - 1/RSI lookback) × its previous value; substitute 1 for an unavailable previous smoothed value.
Long: High crosses above the ribbon upper band.
Short: High crosses below the ribbon lower band.
Long: Shortest-length EMA of high >= longest-length EMA of high.
Short: Shortest-length EMA of high < longest-length EMA of high.
Long: Close > RSI midpoint price.
Short: Close <= RSI midpoint price.
Long: Close crosses above RSI midpoint price.
Short: Close crosses below RSI midpoint price.
Long: Close > liquidity midpoint.
Short: Close <= liquidity midpoint.
Long: Open crosses above liquidity midpoint.
Short: Open crosses below liquidity midpoint.
Long: High crosses above the ribbon upper band AND open > liquidity midpoint.
Short: High crosses below the ribbon lower band AND open < liquidity midpoint.
Long: Close >= SMA of high.
Short: Close < SMA of high.