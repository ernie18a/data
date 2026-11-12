Calculation: Pivot High(N) = a bar whose high is the highest of the N bars before it and N bars after it; it is confirmed N bars later, on the confirmation bar. Pivot Low(N) is the mirror, using lows and lowest.
Calculation: Swing level = the price of the most recently confirmed pivot. A newer pivot replaces it. Each level can trigger once, and is then cleared until a newer pivot replaces it.
Long: close crosses above the latest unused Pivot High swing level (previous close <= level AND current close > level), using a short-term pivot lookback
Long: low < latest unused Pivot Low swing level AND close > that level (sell-side liquidity sweep with rejection)
Long: current low > high of 2 bars ago (bullish fair value gap)
Long: a Pivot Low is confirmed using a long-term pivot lookback (bullish order block)
Short: close crosses below the latest unused Pivot Low swing level (previous close >= level AND current close < level), using a short-term pivot lookback
Short: high > latest unused Pivot High swing level AND close < that level (buy-side liquidity sweep with rejection)
Short: current high < low of 2 bars ago (bearish fair value gap)
Short: a Pivot High is confirmed using a long-term pivot lookback (bearish order block)