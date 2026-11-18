Calculation: short_sma = simple moving average of close over S1 bars
Calculation: mid_sma = simple moving average of close over S2 bars, where S2 is longer than S1
Calculation: long_sma = simple moving average of close over S3 bars, where S3 is longer than S2
Calculation: short_ema = exponential moving average of close over E1 bars
Calculation: second_ema = exponential moving average of close over E2 bars, where E2 is longer than E1
Calculation: third_ema = exponential moving average of close over E3 bars, where E3 is longer than E2
Calculation: long_ema = exponential moving average of close over E4 bars, where E4 is longer than E3
Calculation: true_range = max(high - low, |high - previous close|, |low - previous close|)
Calculation: smoothed_true_range = Wilder smoothing of true_range over R bars: previous smoothed_true_range + (true_range - previous smoothed_true_range) / R
Calculation: upper_band = third_ema + B * smoothed_true_range
Calculation: lower_band = third_ema - B * smoothed_true_range
Calculation: ha_close = (open + high + low + close) / 4
Calculation: ha_open = (previous ha_open + previous ha_close) / 2, with first-bar ha_open = (open + close) / 2
Calculation: ha_high = max(high, ha_open, ha_close)
Calculation: ha_low = min(low, ha_open, ha_close)
Calculation: ha_average = (ha_open + ha_high + ha_low + ha_close) / 4
Calculation: net_volume = (+1 if ha_open < ha_close, else -1) * volume * ha_average * |ha_close - ha_open| / (ha_high - ha_low)
Calculation: net_volume_regression = value, P bars after the latest bar, of the least-squares linear regression line fitted to net_volume over the last P bars
Long: short_sma > short_ema AND second_ema < short_ema AND mid_sma < short_ema AND long_sma < short_ema AND long_ema < short_ema AND third_ema < short_ema AND upper_band < short_ema AND lower_band < short_ema AND net_volume_regression > 0
Short: short_sma < short_ema AND second_ema > short_ema AND mid_sma > short_ema AND long_sma > short_ema AND long_ema > short_ema AND third_ema > short_ema AND upper_band > short_ema AND lower_band > short_ema AND net_volume_regression < 0