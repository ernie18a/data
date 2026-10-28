Calculation: Source price = selected close, (high + low) / 2, (high + low + close) / 3, or (open + high + low + close) / 4
Calculation: Normalized return = change in source price divided by ATR; if ATR is unavailable, divide by the moving average of absolute source-price changes over the path lookback
Calculation: Drift percentile = rolling percentile rank of the absolute sum of normalized returns over the path lookback; its normalization lookback is longer than the path lookback
Calculation: Drift direction = positive when the path-lookback sum of normalized returns is at least zero; otherwise negative
Calculation: Area percentile = rolling percentile rank of the absolute signed area of the path over the path lookback, where each path step is (normalized return, constant time increment); its normalization lookback is longer than the path lookback
Calculation: Area sign = positive when signed area is at least zero; otherwise negative
Calculation: Range position = (source price − lowest low over path lookback) / (highest high − lowest low over path lookback); use the midpoint if the range is zero
Calculation: Strong trend = drift percentile is at least the trend threshold AND area percentile is at least the area threshold
Calculation: Drift weakening = drift percentile is below its recent maximum by a margin AND that recent maximum is at least the trend threshold
Calculation: Reversion setup = NOT strong trend AND current area sign differs from the previous bar's area sign AND previous bar's area percentile is at least the area threshold AND drift weakening AND range position is at or beyond either range extreme
Long: (drift direction is positive AND drift percentile is at least the trend threshold AND (area percentile is at least the area threshold OR reversion setup is false)) OR (reversion setup is true AND range position is below the range midpoint)
Short: (drift direction is negative AND drift percentile is at least the trend threshold AND (area percentile is at least the area threshold OR reversion setup is false)) OR (reversion setup is true AND range position is at or above the range midpoint)