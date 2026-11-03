Calculation: Midrange(n) = (highest high over n bars + lowest low over n bars) / 2, including the current bar.
Calculation: Ichimoku lines = short-lookback midrange; medium-lookback midrange; Span A = their average; Span B = long-lookback midrange. Current cloud edges are Span A and Span B from displacement minus one bars ago; short lookback < medium lookback < long lookback.
Calculation: Score = sum of five components, each equal to +1, -1, or 0: close above the current cloud top or below its bottom; short-lookback midrange above or below medium-lookback midrange; close above the high or below the low displacement minus one bars ago; Span A above or below Span B; medium-lookback midrange above or below its value at a slope lookback. Each component is 0 otherwise. Score is available only when both current cloud edges, the historical medium-lookback midrange, and the historical high exist.
Calculation: Alignment = +1 when close is above the current cloud top AND short-lookback midrange is above medium-lookback midrange AND close is above the high displacement minus one bars ago; -1 when close is below the current cloud bottom AND short-lookback midrange is below medium-lookback midrange AND close is below the low displacement minus one bars ago; 0 otherwise or when score is unavailable.
Long: Score > 0.
Short: Score < 0.
Long: Current cloud Span A > current cloud Span B.
Short: Current cloud Span A <= current cloud Span B.
Long: Score >= strong threshold AND previous score < strong threshold AND absolute score > chop band AND close is outside the current cloud.
Short: Score <= negative strong threshold AND previous score > negative strong threshold AND absolute score > chop band AND close is outside the current cloud.
Long: Alignment = +1 AND previous alignment != +1.
Short: Alignment = -1 AND previous alignment != -1.
Long: Score > 0 OR alignment = +1 on the last completed bar of a higher or lower timeframe.
Short: Score < 0 OR alignment = -1 on the last completed bar of a higher or lower timeframe.