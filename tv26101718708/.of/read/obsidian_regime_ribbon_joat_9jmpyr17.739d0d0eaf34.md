Calculation: Efficiency = EMA of abs(source − source N bars ago) divided by the sum of abs(source[i] − source[i+1]) for i from 0 to N−1; use zero when the sum is zero. Source is a selected OHLC field.
Calculation: Adaptive range multiplier = base multiplier multiplied by a larger factor when efficiency is below a lower threshold, a smaller factor when efficiency is above a higher threshold, and a middle factor otherwise.
Calculation: Adaptive confirmation length = base confirmation length increased with a minimum floor when efficiency is below the lowest threshold, base length plus a smaller increment below the next threshold, base length below the highest threshold, and base length minus an increment with a minimum floor otherwise.
Calculation: Regime filter = initialize to source; on each bar set it to source minus ATR times adaptive range multiplier if source exceeds the previous filter plus that buffer, to source plus the buffer if source is below the previous filter minus the buffer, and otherwise retain the previous filter.
Calculation: Raw trend = bullish when the regime filter rises, bearish when it falls, and otherwise the previous raw trend; initialize neutral.
Calculation: Locked trend = initialize bullish if raw trend is neutral, otherwise initialize to raw trend. Count consecutive bars on which raw trend differs from locked trend, resetting the count when they agree. On a completed bar, change locked trend to non-neutral raw trend and reset the count when the count reaches the current adaptive confirmation length.
Calculation: Momentum = EMA of close minus close N bars ago, using a shorter EMA length derived from N with a minimum length.
Calculation: Choppiness = 100 times log10 of the sum of true range over its lookback divided by the difference between the highest high and lowest low over that lookback, divided by log10 of the lookback length; use a neutral fallback when the high-low range is zero.
Calculation: Bullish gate = (ADX filter disabled OR ADX at least its floor) AND (choppiness filter disabled OR choppiness at most its ceiling) AND (momentum filter disabled OR momentum above zero) AND (higher-timeframe filter disabled OR last completed higher-timeframe close above its EMA calculated on that higher timeframe).
Calculation: Bearish gate = (ADX filter disabled OR ADX at least its floor) AND (choppiness filter disabled OR choppiness at most its ceiling) AND (momentum filter disabled OR momentum below zero) AND (higher-timeframe filter disabled OR last completed higher-timeframe close at or below its EMA calculated on that higher timeframe).
Calculation: Upper expansion band = regime filter plus a fraction of ATR times adaptive range multiplier.
Calculation: Lower expansion band = regime filter minus the same fraction of ATR times adaptive range multiplier.
Long: Locked trend is bullish.
Short: Locked trend is bearish.
Long: Locked trend changes to bullish on a completed bar.
Short: Locked trend changes to bearish on a completed bar.
Long: Completed bar AND locked trend is bullish AND bullish gate is open AND low is at or below regime filter AND close is above regime filter AND shorter-period close EMA is above longer-period close EMA.
Short: Completed bar AND locked trend is bearish AND bearish gate is open AND high is at or above regime filter AND close is below regime filter AND shorter-period close EMA is at or below longer-period close EMA.
Long: Locked trend is bullish AND bullish gate is open AND close is above the current upper expansion band AND previous close is at or below the current upper expansion band.
Short: Locked trend is bearish AND bearish gate is open AND close is below the current lower expansion band AND previous close is at or above the current lower expansion band.