Calculation: Leg T1 bars = T1 bars contained in chart bars from the leg's start pivot through its end pivot, inclusive; use available T1 values, including a still-forming T1 bar when present, and update on chart bars.
Calculation: Estimated buy volume per T1 bar = if high > low, volume * (close - low) / (high - low), else 0.
Calculation: Estimated sell volume per T1 bar = if high > low, volume * (high - close) / (high - low), else 0.
Calculation: Leg net delta = sum(estimated buy volume - estimated sell volume) over the leg's T1 bars.
Calculation: Leg profile bins = N equal price bins spanning the minimum T1 low to maximum T1 high of the leg, where N = max(1, round(range / target height)); target height = ATR(profile lookback, chart bars) / divisor if range / (ATR(profile lookback, chart bars) / divisor) <= box limit, else range / box limit.
Calculation: Bin overlap fraction for a T1 bar = if high > low, max(0, min(bin top, high) - max(bin bottom, low)) / (high - low), else 0.
Calculation: Profile-bin total volume = sum(T1 volume * bin overlap fraction) over the leg's T1 bars.
Calculation: Profile-bin delta = sum((estimated buy volume - estimated sell volume) * bin overlap fraction) over the leg's T1 bars.
Long: While tracking an upswing, low < current upswing high - ATR(swing lookback, chart bars) * swing reversal multiplier.
Short: While tracking a downswing, high > current downswing low + ATR(swing lookback, chart bars) * swing reversal multiplier.
Long: On each confirmed leg with T1 bars, leg net delta > 0.
Short: On each confirmed leg with T1 bars, leg net delta <= 0.
Long: SMA(volume, bubble lookback, chart bars) > 0 AND volume >= volume spike multiplier * SMA(volume, bubble lookback, chart bars) AND close >= open.
Short: SMA(volume, bubble lookback, chart bars) > 0 AND volume >= volume spike multiplier * SMA(volume, bubble lookback, chart bars) AND close < open.
Long: In delta coloring mode, profile-bin total volume > 0 AND profile-bin delta > 0.
Short: In delta coloring mode, profile-bin total volume > 0 AND profile-bin delta < 0.