Calculation: Safe division = numerator / denominator when denominator is nonzero, otherwise zero.
Calculation: Normalization = (value − SMA(value, normalization lookback)) / population standard deviation(value, normalization lookback); use zero when the mean or standard deviation is unavailable or the standard deviation is zero.
Calculation: Anchored VWAP = cumulative sum of ((high + low) / 2 × volume) divided by cumulative volume since the start of the selected calendar anchor period, including the current chart bar; use (high + low) / 2 when cumulative volume is zero. Treat missing volume as zero.
Calculation: Candle components = range R = max(high − low, minimum price increment); body B = close − open; body ratio = abs(B) / R; body tone = B / R; wick bias = ((min(open, close) − low) − (high − max(open, close))) / R; close position = (close − low) / R. Use a configurable positive minimum price increment.
Calculation: ATR distance D = (close − anchored VWAP) / max(ATR, minimum price increment); volume impulse = volume / SMA(volume, pressure lookback) when that average is positive, otherwise one.
Calculation: Pressure = EMA(normalization(EMA(body tone × (body offset + body ratio) × volume impulse × pressure scale, pressure lookback) + EMA(D × pressure-context scale, a shorter lookback derived from the pressure lookback)), smoothing lookback).
Calculation: Crowding = EMA(normalization(EMA((RSI(source, crowding lookback) − RSI midpoint) × RSI scale + D × stretch scale + wick bias × wick scale + (close position − midpoint) × settlement scale, crowding lookback)), smoothing lookback), where source is a configurable chart-bar price source and defaults to (high + low + close) / 3.
Calculation: Volatility = EMA(normalization((max(ATR, minimum price increment) / max(SMA(ATR, volatility lookback), minimum price increment) − 1) × ATR-ratio scale + (percent rank of max(ATR, minimum price increment) over the volatility lookback − percentile midpoint) × percentile scale), smoothing lookback).
Calculation: Skew = EMA(normalization(EMA(((close − low) − (high − close)) / R × skew scale + (close position − midpoint) × settlement-skew scale + D × skew-context scale, skew lookback)), smoothing lookback).
Calculation: Composite = EMA(pressure weight × pressure + crowding weight × crowding + volatility weight × volatility + skew weight × skew, smoothing lookback).
Calculation: Risk = clamp(crowding-risk weight × clamp(abs(crowding) / crowding-extreme threshold, 0, 1) + volatility-risk weight × clamp(volatility / volatility-expansion threshold, 0, 1) + stretch-risk weight × clamp(abs(D) / stretch cap, 0, 1) + skew-risk weight × clamp(abs(skew) / skew-stress scale, 0, 1) + conflict-risk weight × conflict, 0, maximum risk), where conflict is one when (composite > 0 AND pressure < negative conflict threshold) OR (composite < 0 AND pressure > positive conflict threshold), otherwise zero.
Calculation: Bull setup = composite >= bull threshold AND pressure > 0 AND crowding > negative crowding tolerance.
Calculation: Bear setup = composite <= negative bear threshold AND pressure < 0 AND crowding < positive crowding tolerance.
Calculation: Neutral-volatility exclusion = (volatility >= expansion threshold OR volatility <= compression threshold) AND abs(composite) < composite-neutral threshold.
Long: Composite >= 0.
Short: Composite < 0.
Long: D >= 0.
Short: D < 0.
Long: Pressure > metric neutral band.
Short: Pressure < negative metric neutral band.
Short: Crowding < negative metric neutral band.
Short: Volatility < negative metric neutral band.
Long: Skew > metric neutral band.
Long: Risk >= critical-risk threshold AND composite > 0.
Short: Risk >= critical-risk threshold AND composite < 0.
Long: Bull setup AND NOT (risk >= critical-risk threshold AND composite != 0) AND NOT neutral-volatility exclusion.
Short: Bear setup AND NOT (risk >= critical-risk threshold AND composite != 0) AND NOT neutral-volatility exclusion.
Long: Bull setup AND NOT previous-bar bull setup.
Short: Bear setup AND NOT previous-bar bear setup.