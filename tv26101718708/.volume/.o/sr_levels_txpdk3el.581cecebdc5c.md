Calculation: Previous period high/low = high/low of the last completed day, week, month, or year.
Calculation: Previous session high/low = highest high / lowest low during the last completed configured session.
Calculation: S/R touch = bar low ≤ level + close × touch tolerance AND bar high ≥ level − close × touch tolerance. Bullish rejection = S/R touch AND close > level AND close > open. Bearish rejection = S/R touch AND close < level AND close < open.
Calculation: Bullish EMA trend = close > shorter-period EMA AND shorter-period EMA > longer-period EMA. Bearish EMA trend = close < shorter-period EMA AND shorter-period EMA < longer-period EMA.
Calculation: Volume spike = volume > longer-lookback average volume × configured multiplier.
Calculation: Long score = weighted sum of bullish rejections at previous-period lows and previous-session lows, plus configured bonuses for proximity to any previous week/month/year high or low, proximity to any previous-session high or low, and a volume spike. Previous-period low weights increase from day to year; previous-session low weights increase from Asia to London to New York.
Calculation: Short score = weighted sum of bearish rejections at previous-period highs and previous-session highs, plus the same proximity and volume-spike bonuses as the long score. Previous-period high weights increase from day to year; previous-session high weights increase from Asia to London to New York.
Long: Long score ≥ minimum signal score AND bullish EMA trend AND volume spike AND no long signal within the configured cooldown.
Long: close > last completed day's high AND previous bar close ≤ that high AND volume spike.
Short: Short score ≥ minimum signal score AND bearish EMA trend AND volume spike AND no short signal within the configured cooldown.
Short: close < last completed day's low AND previous bar close ≥ that low AND volume spike.