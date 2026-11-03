Calculation: Bar range = max(high - low, minimum price increment).
Calculation: Relative volume = volume / SMA(volume, baseline lookback), or 1 when the SMA is not positive.
Calculation: Delta proxy = volume * (close - open) / bar range.
Calculation: Z-score of a series = (current value - SMA of the series) / population standard deviation of the series over the same normalization lookback, or 0 when the standard deviation is not positive. Use the same normalization lookback for delta proxy, churn ratio, and volume volatility.
Calculation: Range efficiency = bar range / SMA(bar range, baseline lookback), or 1 when the SMA is not positive. Churn ratio = relative volume / range efficiency when range efficiency is positive, otherwise relative volume. Effort-result ratio = range efficiency / relative volume when relative volume is positive, otherwise 0.
Calculation: Participation = EMA(0.50 * Z-score of delta proxy + 0.35 * (relative volume - 1) - 0.15 * Z-score of churn ratio, participation smoothing lookback).
Calculation: Volume volatility = square root of the EMA of squared log(volume / previous volume), using 0 for the log return when either volume is not positive.
Calculation: A stored zone is created at a confirmed pivot high of volume whose pivot-bar relative volume exceeds a threshold OR whose absolute pivot-bar delta-proxy Z-score exceeds a threshold OR whose pivot-bar volume-volatility Z-score exceeds a threshold. A pivot uses equal left and right lookbacks. Its midpoint is the pivot-bar (high + low + close) / 3; its half-width is max(pivot-bar ATR * width factor, minimum price increment * width floor); its score is max(pivot-bar relative volume, 1) + 0.70 * absolute pivot-bar delta-proxy Z-score + 0.45 * max(pivot-bar volume-volatility Z-score, 0). Keep at most the configured number of most recently created zones and exclude zones older than the profile lookback, measured from their pivot bars.
Calculation: Active support is the highest-scoring stored zone whose top is below the current close; active resistance is the highest-scoring stored zone whose bottom is above the current close. Resolve equal scores in favor of the earlier stored zone.
Long: Delta-proxy Z-score >= 0.
Short: Delta-proxy Z-score < 0.
Long: Participation >= 0.
Short: Participation < 0.
Long: Relative volume > high-volume threshold AND delta-proxy Z-score > positive climax threshold AND participation > 0.
Short: Relative volume > high-volume threshold AND delta-proxy Z-score < negative climax threshold AND participation < 0.
Long: Relative volume > high-volume threshold AND effort-result ratio < churn threshold AND delta-proxy Z-score > 0.
Short: Relative volume > high-volume threshold AND effort-result ratio < churn threshold AND delta-proxy Z-score < 0.
Long: Active support top < close AND low <= active support top AND close >= active support midpoint.
Short: Active resistance bottom > close AND high >= active resistance bottom AND close <= active resistance midpoint.