Calculation: Relative strength = current close / benchmark close on the same chart timeframe
Calculation: RS new high = current relative strength >= 0.998 × its highest value over the RS new-high lookback, including the current bar
Calculation: RS slope (%) = 100 × (current relative strength / relative strength from the RS slope lookback bars ago − 1)
Calculation: Mansfield RS = 100 × (current relative strength / its simple moving average over the Mansfield lookback − 1)
Calculation: 1M and 3M relative performance = 100 × (current relative strength / relative strength from the corresponding lookback bars ago − 1)
Calculation: Base pivot = highest high over the base lookback, excluding the current bar
Calculation: Base support = lowest low over the base lookback, excluding the current bar
Calculation: Base range (%) = 100 × (base pivot − base support) / base support
Calculation: ATR contracting = ATR(14) < ATR(base lookback) × contraction threshold
Calculation: Valid base = ATR contracting AND base range < maximum stage base range AND close < base pivot × 1.005 AND close > base support × 0.98
Calculation: Stage-2 trend = close > fast moving average AND fast moving average > slow moving average AND slow moving average is rising over 5 bars
Calculation: Volume surge = volume > volume moving average × volume multiplier
Calculation: Pivot breakout = current close > current base pivot × (1 + breakout buffer %) AND previous close <= previous base pivot × (1 + breakout buffer %)
Calculation: Golden score = 20 if RS new high + 15 if RS slope meets its minimum + 10 if Mansfield RS exceeds its minimum + 10 if acceleration passes + 15 if valid base + 5 if ATR contracting + 10 if base range is within its Golden bounds + 10 if distance from pivot is within its Golden bounds + 5 if Stage-2 trend passes; otherwise each term is 0
Long: RS new high AND valid base AND close < base pivot AND RS slope > 0 AND Mansfield RS > 0
Long: Pivot breakout AND RS new high AND volume surge
Long: Pivot breakout AND RS new high AND volume surge AND RS slope > 0 AND (Stage-2 trend filter disabled OR Stage-2 trend) AND Mansfield RS > 0
Long: RS new high AND RS slope meets its minimum AND Mansfield RS exceeds its minimum AND 1M relative performance > 0 AND 3M relative performance > 0 AND 1M relative performance > 3M relative performance / 3 AND valid base AND ATR contracting AND base range is within its Golden bounds AND distance from pivot is within its Golden bounds AND (volume filter disabled OR volume / volume moving average >= volume multiplier) AND (Stage-2 trend filter disabled OR Stage-2 trend) AND Golden score >= its minimum
Long: Golden pass count first reaches 8 while Golden conditions are not all met