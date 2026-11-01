Calculation: Body = abs(close - open); guarded body = max(body, minimum price increment); upper wick = high - max(open, close); lower wick = min(open, close) - low.
Calculation: Volume-spread = volume * (high - low).
Calculation: Confirmed pivot high or low = a high or low identified using the same number of bars on each side; it becomes available only after the right-side bars complete.
Calculation: Major and internal structure = separately retain the latest confirmed pivot high and low, using a shorter lookback for internal pivots. A break occurs when the selected close or wick exceeds the retained high or falls below the retained low; consume the broken pivot. A major break also clears both retained internal pivots. Set the corresponding structure direction to bullish or bearish on each break; process major breaks before internal breaks, and skip internal breaks on a major-break bar.
Calculation: Sweep reference = either the highest high or lowest low over a lookback ending on the previous bar, or the latest confirmed major pivot high or low.
Calculation: Stopping-volume location = one selected alternative: a sweep of the prior rolling range extreme; low below or high above the current session's close-based VWAP; a same-direction sweep signal on the current bar or within the specified preceding bars; low in the lower fraction or high in the upper fraction of the current rolling high-low range; or no location restriction.
Long: close > open AND (volume >= a multiplier of the prior-bar volume SMA OR volume-spread >= the maximum volume-spread over the preceding lookback).
Short: close <= open AND (volume >= a multiplier of the prior-bar volume SMA OR volume-spread >= the maximum volume-spread over the preceding lookback).
Long: close > open AND volume >= a multiplier of a prior-bar volume SMA.
Short: close <= open AND volume >= a multiplier of a prior-bar volume SMA.
Long: close <= open AND volume >= a multiplier of a prior-bar volume SMA AND body > a multiplier of the body SMA including the current bar AND close < EMA(close) - a multiplier of close standard deviation using the EMA lookback.
Short: close > open AND volume >= a multiplier of a prior-bar volume SMA AND body > a multiplier of the body SMA including the current bar AND close > EMA(close) + a multiplier of close standard deviation using the EMA lookback.
Long: RSI(close) crosses above an oversold threshold.
Short: RSI(close) crosses below an overbought threshold.
Long: low < sweep reference low AND close > sweep reference low AND lower wick / guarded body >= a threshold AND volume > a multiplier of the prior-bar volume SMA AND, if enabled, high - low >= ATR AND, if enabled, major OR internal structure direction is bullish.
Short: high > sweep reference high AND close < sweep reference high AND upper wick / guarded body >= a threshold AND volume > a multiplier of the prior-bar volume SMA AND, if enabled, high - low >= ATR AND, if enabled, major OR internal structure direction is bearish.
Long: close < open AND volume > a multiplier of either the prior-bar volume SMA or the prior rolling maximum volume AND lower wick / guarded body >= a threshold AND guarded body < a multiplier of ATR AND low < previous low AND bullish stopping-volume location is satisfied AND bars since the previous bullish stopping-volume signal > the cooldown.
Short: close > open AND volume > a multiplier of either the prior-bar volume SMA or the prior rolling maximum volume AND upper wick / guarded body >= a threshold AND guarded body < a multiplier of ATR AND high > previous high AND bearish stopping-volume location is satisfied AND bars since the previous bearish stopping-volume signal > the cooldown.
Long: volume >= a multiplier of the prior-bar volume SMA AND close >= EMA(close) * (1 + a distance fraction) AND, if enabled, high >= the highest high over the preceding lookback.
Short: volume >= a multiplier of the prior-bar volume SMA AND close <= EMA(close) * (1 - a distance fraction) AND, if enabled, low <= the lowest low over the preceding lookback.
Long: body > a multiplier of the prior-bar body SMA AND volume > a multiplier of the prior-bar volume SMA AND low < the lowest low over the preceding lookback AND close > that low AND close > open.
Short: body > a multiplier of the prior-bar body SMA AND volume > a multiplier of the prior-bar volume SMA AND high > the highest high over the preceding lookback AND close < that high AND close < open.
Long: upper wick <= a fraction of guarded body AND lower wick >= a multiplier of guarded body AND volume >= a multiplier of the prior-bar volume SMA AND abs(close - EMA(close)) >= a distance fraction * EMA(close).
Short: lower wick <= a fraction of guarded body AND upper wick >= a multiplier of guarded body AND volume >= a multiplier of the prior-bar volume SMA AND abs(close - EMA(close)) >= a distance fraction * EMA(close).
Long: a pivot low is confirmed.
Short: a pivot high is confirmed.
Long: a major bullish structure break occurs OR an internal bullish structure break occurs.
Short: a major bearish structure break occurs OR an internal bearish structure break occurs.
Long: low > high two bars earlier.
Short: high < low two bars earlier.
Long: a pivot low is confirmed AND pivot-bar volume > a multiplier of the pivot-bar volume EMA.
Short: a pivot high is confirmed AND pivot-bar volume > a multiplier of the pivot-bar volume EMA.
Exit: long, low <= entry price * (1 - stop fraction) OR high >= entry price * (1 + target fraction).
Exit: short, high >= entry price * (1 + stop fraction) OR low <= entry price * (1 - target fraction).