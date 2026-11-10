Calculation: Anchored VWAP = sum(source × volume) / sum(volume), accumulated from the start of the selected day, week, or month through the current chart bar; use source when accumulated volume is zero. Source is a selected chart-bar price field or price average.
Calculation: Weighted deviation = sqrt(max(0, sum(source² × volume) / sum(volume) − anchored VWAP²)) over the same anchor period; use zero when accumulated volume is zero.
Calculation: Z-score = (close − anchored VWAP) / weighted deviation; use zero when weighted deviation is zero.
Calculation: Raw reversion long = previous Z-score <= negative reversion threshold AND current Z-score > previous Z-score AND close > open.
Calculation: Raw reversion short = previous Z-score >= reversion threshold AND current Z-score < previous Z-score AND close < open.
Calculation: Raw pullback long = close >= EMA of close AND close crosses above anchored VWAP.
Calculation: Raw pullback short = close < EMA of close AND close crosses below anchored VWAP.
Calculation: Eligible signal = no earlier eligible signal exists OR bars since the last eligible signal >= minimum signal spacing. Only the reversion and pullback signals use this spacing.
Calculation: Entry risk = ATR at the signal bar × stop multiplier; use ATR at the signal bar if the product is not positive.
Calculation: Entry target = for a signal classified as reversion, max(entry-bar anchored VWAP, entry price) for a long or min(entry-bar anchored VWAP, entry price) for a short; otherwise entry-bar anchored VWAP plus the second-band multiplier × entry-bar weighted deviation for a long or minus that amount for a short. Classify a signal as reversion if raw reversion long is true, or if raw pullback long is false and raw reversion short is true; otherwise classify it as pullback.
Long: Z-score < negative first-band multiplier.
Short: Z-score > first-band multiplier.
Long: Z-score <= negative reversion threshold AND previous Z-score > negative reversion threshold.
Short: Z-score >= reversion threshold AND previous Z-score < reversion threshold.
Long: close >= EMA of close.
Short: close < EMA of close.
Long: Eligible signal AND (raw reversion long OR raw pullback long) AND NOT (raw reversion short OR raw pullback short).
Short: Eligible signal AND (raw reversion short OR raw pullback short).
Exit: long, after the entry bar, high >= entry target OR low <= entry price − entry risk OR an eligible reversion or pullback signal occurs.
Exit: short, after the entry bar, low <= entry target OR high >= entry price + entry risk OR an eligible reversion or pullback signal occurs.