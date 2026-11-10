Calculation: Smoothed Heikin-Ashi body = selected moving average of Heikin-Ashi close minus the same moving average of Heikin-Ashi open; use the same moving-average parameters for Heikin-Ashi high and low.
Calculation: Trend = 100 × smoothed Heikin-Ashi body / (moving average of Heikin-Ashi high − moving average of Heikin-Ashi low).
Calculation: Efficiency ratio = absolute change in close over its lookback divided by the sum of absolute one-bar close changes over that lookback, or zero if the sum is zero.
Calculation: Body slope = efficiency ratio × fast slope + (1 − efficiency ratio) × slow slope, using the same selected method for both: linear-regression slope of the smoothed Heikin-Ashi body, its lookback-bar change divided by the lookback, or the simple moving average of its one-bar changes. The fast lookback is shorter than the slow lookback.
Calculation: Normalized slope = 100 × body slope / highest absolute body slope over the normalization lookback, or zero if that maximum is zero. Scaled slope = normalized slope × slope scale / 100.
Calculation: Positive peak = previous bar's scaled slope is positive, greater than the current scaled slope, and greater than or equal to the scaled slope two bars ago. Negative peak = previous bar's scaled slope is negative, less than the current scaled slope, and less than or equal to the scaled slope two bars ago. A peak is strong when the absolute previous normalized slope exceeds the momentum threshold.
Calculation: Positive and negative peak anchors = separate stored pairs of the previous bar's scaled slope and close. On each bar, first deactivate the positive anchor if current trend is at or below zero and deactivate the negative anchor if current trend is at or above zero. For each peak side, if its anchor is absent or inactive, activate and set it only on a strong peak. If its anchor is active, evaluate divergence against the existing anchor first, then replace the anchor on a strong peak; a weak peak leaves it unchanged.
Long: Trend > 0.
Short: Trend ≤ 0.
Long: Scaled slope > positive deadband.
Short: Scaled slope < negative deadband.
Long: Positive peak AND previous scaled slope ≤ positive deadband.
Short: Negative peak AND previous scaled slope ≥ negative deadband.
Long: Negative peak AND negative anchor is active AND previous scaled slope > negative anchor slope AND previous close < negative anchor close AND previous trend < 0.
Short: Positive peak AND positive anchor is active AND previous scaled slope < positive anchor slope AND previous close > positive anchor close AND previous trend > 0.