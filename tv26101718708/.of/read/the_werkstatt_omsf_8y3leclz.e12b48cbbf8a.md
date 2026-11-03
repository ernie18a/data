Calculation: Cumulative volatility = sum of true range over the activity lookback; true range uses high minus low when the previous close is unavailable.
Calculation: Cumulative volume = sum of volume over the same activity lookback, or zero if unavailable.
Calculation: Activity percentile ranks = percentile ranks of cumulative volatility and cumulative volume over a lookback equal to the activity lookback multiplied by a separate lookback parameter, capped at a maximum lookback.
Long: Cumulative volatility percentile rank > volatility threshold AND cumulative volume percentile rank > volume threshold AND close > open
Short: Cumulative volatility percentile rank > volatility threshold AND cumulative volume percentile rank > volume threshold AND close <= open