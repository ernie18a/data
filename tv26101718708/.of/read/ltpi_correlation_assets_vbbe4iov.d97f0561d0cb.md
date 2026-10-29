Calculation: Average trend score = (sign(ROC over a lookback > 1) + sign(RSI > 50) + sign(short-term EMA > long-term EMA) + sign(close > long-term SMA)) / 4, where each sign is +1 when its condition is true and −1 otherwise
Calculation: Correlation weight = weighted mean of the valid rolling Pearson correlations between the chart close and BTC close over five lookbacks, excluding windows with fewer than the minimum valid aligned observations, clamped to [−1, 1]; longer lookbacks have greater weights
Calculation: Final weighted score = average trend score × correlation weight
Long: ROC > 1
Short: ROC ≤ 1
Long: RSI > 50
Short: RSI ≤ 50
Long: Short-term EMA > long-term EMA
Short: Short-term EMA ≤ long-term EMA
Long: Close > long-term SMA
Short: Close ≤ long-term SMA
Long: Final weighted score ≥ 0 AND (final weighted score < neutral-zone low OR final weighted score > neutral-zone high)
Short: Final weighted score < 0 AND (final weighted score < neutral-zone low OR final weighted score > neutral-zone high)