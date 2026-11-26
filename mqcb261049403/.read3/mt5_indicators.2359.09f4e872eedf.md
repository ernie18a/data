Calculation: Downward-turn condition = high < high[1] AND high < high[lookback] AND high < dynamic level[1]
Calculation: Upward-turn condition = low > low[1] AND low > low[lookback] AND low > dynamic level[1]
Calculation: Dynamic level = high + price shift when the downward-turn condition is true; otherwise low + price shift when the upward-turn condition is true; otherwise dynamic level[1]
Calculation: Trend state = bearish when the downward-turn condition is true and the prior state is not bullish, otherwise neutral; bullish when the upward-turn condition is true and the prior state is not bearish, otherwise neutral; when neither condition is true, the prior state unless it is neutral, in which case switch to bullish if the state two bars ago was bearish, switch to bearish if it was bullish, and otherwise remain neutral
Long: Trend state is bullish
Short: Trend state is bearish