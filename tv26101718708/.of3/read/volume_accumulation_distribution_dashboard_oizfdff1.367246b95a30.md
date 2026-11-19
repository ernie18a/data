Calculation: Mechanical bar = chart bar dated on the third Friday of a month, the fourth Friday of June, or an ex-dividend date identified by the dividend feed when dividend exclusion is enabled
Calculation: Up volume = rolling sum of volume over window for chart bars where close > previous close and the bar is not mechanical
Calculation: Down volume = rolling sum of volume over window for chart bars where close < previous close and the bar is not mechanical
Calculation: Up/down volume ratio = up volume / max(down volume, volume-floor parameter)
Calculation: Auto upper band = exp(median(log(up/down volume ratio), calibration lookback) + calibration width × stdev(log(up/down volume ratio), calibration lookback))
Calculation: Auto lower band = exp(median(log(up/down volume ratio), calibration lookback) − calibration width × stdev(log(up/down volume ratio), calibration lookback))
Calculation: Upper band = auto upper band when auto-calibration is enabled and both auto bands are available, otherwise manual upper band
Calculation: Lower band = auto lower band when auto-calibration is enabled and both auto bands are available, otherwise manual lower band
Calculation: Regime = persistent state initially neutral; on confirmed non-mechanical chart bars, change to accumulation after confirmation bars with nonzero up-plus-down volume and up/down volume ratio >= upper band, or to distribution after confirmation bars with nonzero up-plus-down volume and up/down volume ratio <= lower band; otherwise retain the prior state
Calculation: Up/down average volume ratio = (up volume / count of up-close chart bars over window) / (down volume / count of down-close chart bars over window), defined only when both counts and the down-day average volume are positive
Calculation: Relative volume = current chart-bar volume / SMA(volume, baseline lookback) on the previous chart bar, defined only when that average is positive
Calculation: Clean OBV change = OBV with zero volume contribution on mechanical bars, current value − value window chart bars ago
Calculation: Clean A/D change = cumulative sum of CLV(close, high, low) × volume with zero contribution on mechanical bars, current value − value window chart bars ago
Calculation: Weighted CLV = rolling sum over window of CLV(close, high, low) × volume on non-mechanical bars / max(rolling sum over window of volume on non-mechanical bars, volume-floor parameter)
Calculation: Heavy-selling-day count = rolling count over distribution lookback of non-mechanical chart bars where previous close > 0, the close-to-previous-close return is below the negative drop threshold, volume > previous volume, and relative volume > distribution-volume threshold
Long: Regime = accumulation
Long: Regime = accumulation AND previous Regime != accumulation
Long: Up/down volume ratio >= upper band
Long: Up/down average volume ratio is defined AND up/down average volume ratio > upper average-volume-ratio threshold
Long: Clean OBV change is defined AND Clean OBV change > 0
Long: Clean A/D change is defined AND Clean A/D change > 0
Long: Weighted CLV > upper weighted-CLV threshold
Long: Bar is not mechanical AND relative volume > strong-volume threshold AND close > open
Short: Regime = distribution
Short: Regime = distribution AND previous Regime != distribution
Short: Up/down volume ratio <= lower band
Short: Up/down average volume ratio is defined AND up/down average volume ratio < lower average-volume-ratio threshold
Short: Clean OBV change is defined AND Clean OBV change < 0
Short: Clean A/D change is defined AND Clean A/D change < 0
Short: Weighted CLV < lower weighted-CLV threshold
Short: Heavy-selling-day count >= heavy-selling count threshold
Short: Bar is not mechanical AND relative volume > strong-volume threshold AND close < open