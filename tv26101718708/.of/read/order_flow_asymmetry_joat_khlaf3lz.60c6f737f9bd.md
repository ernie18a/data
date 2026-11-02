Calculation: Normalized volume-weighted momentum = accumulate (close - previous close) * volume, treating a missing previous accumulation as zero; normalize the accumulation within its rolling minimum and maximum to a symmetric range around zero, returning zero when the range is zero.
Calculation: Imbalance score = clamp the decaying sum of bar imbalance to a symmetric range around zero after multiplying it by a scale factor and dividing by ATR; bar imbalance is (close - (high + low) / 2) / (high - low), or zero when high equals low; use zero when ATR is not positive and initialize the decaying sum at zero.
Calculation: Vacuum = volume < EMA(volume) - volume standard deviation * vacuum multiplier AND high - low > ATR.
Long: Normalized volume-weighted momentum > 0.
Short: Normalized volume-weighted momentum < 0.
Long: ADX > trend threshold AND close > EMA(close).
Short: ADX > trend threshold AND close < EMA(close).
Long: Imbalance score > positive imbalance signal threshold.
Short: Imbalance score < negative imbalance signal threshold.
Long: Imbalance score > positive extreme threshold AND previous imbalance score <= positive extreme threshold.
Short: Imbalance score < negative extreme threshold AND previous imbalance score >= negative extreme threshold.
Long: ADX > trend threshold AND close > EMA(close) AND normalized volume-weighted momentum crosses above its positive signal threshold AND imbalance score > positive imbalance signal threshold AND vacuum is false AND bars since the previous confirmed long or short signal >= cooldown, or no prior confirmed signal exists.
Short: ADX > trend threshold AND close < EMA(close) AND normalized volume-weighted momentum crosses below its negative signal threshold AND imbalance score < negative imbalance signal threshold AND vacuum is false AND bars since the previous confirmed long or short signal >= cooldown, or no prior confirmed signal exists.
Exit: long, high >= entry price + take-profit multiplier * ATR at entry OR low <= entry price - stop-loss multiplier * ATR at entry.
Exit: short, low <= entry price - take-profit multiplier * ATR at entry OR high >= entry price + stop-loss multiplier * ATR at entry.