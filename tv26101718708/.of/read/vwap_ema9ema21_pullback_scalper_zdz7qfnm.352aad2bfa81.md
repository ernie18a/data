Calculation: VWAP = daily-reset cumulative volume-weighted average of (high+low+close)/3
Calculation: Bias bars = bars of a higher timeframe than the chart, using the still-forming bar (values as of the current chart bar's close); EMA, VWAP and close are computed on these bars
Calculation: StopLevel = fixed at entry bar. Long: lowest low over a short lookback ending at the entry bar. Short: highest high over the same lookback. (Alternative mode: StopLevel = current chart-timeframe VWAP, re-evaluated every bar.)
Calculation: R = absolute(entry price - StopLevel at entry), at least one minimum tick
Calculation: TP1 = entry price + R (long) or entry price - R (short); TP1 hit = high >= TP1 (long) or low <= TP1 (short) on any bar since entry
Long: flat AND bars since the last position closed > cooldown AND bar time inside the allowed intraday session AND Bias-bars close > Bias-bars VWAP AND Bias-bars short-lookback EMA of close > Bias-bars long-lookback EMA of close AND chart low <= chart short-lookback EMA of close AND chart close > that EMA AND previous chart close <= that EMA AND chart close > chart VWAP AND chart volume >= multiplier * simple average of chart volume over a lookback (including the current bar) AND (optional) last-bar close of a timeframe higher than the bias timeframe, using the still-forming bar, > its long-period EMA of close
Short: flat AND bars since the last position closed > cooldown AND bar time inside the allowed intraday session AND Bias-bars close < Bias-bars VWAP AND Bias-bars short-lookback EMA of close < Bias-bars long-lookback EMA of close AND chart high >= chart short-lookback EMA of close AND chart close < that EMA AND previous chart close >= that EMA AND chart close < chart VWAP AND chart volume >= multiplier * simple average of chart volume over a lookback (including the current bar) AND (optional) higher-timeframe close (higher than the bias timeframe, still-forming bar) < its long-period EMA of close
Exit: long, low <= StopLevel (before TP1 hit, whole position)
Exit: short, high >= StopLevel (before TP1 hit, whole position)
Exit: long, TP1 hit AND high >= TP1 (close only a partial fraction of the position at TP1)
Exit: short, TP1 hit AND low <= TP1 (close only a partial fraction of the position at TP1)
Exit: long, after TP1 hit, remainder: low <= max(entry price, chart short-lookback EMA of close, StopLevel)
Exit: short, after TP1 hit, remainder: high >= min(entry price, chart short-lookback EMA of close, StopLevel)
Exit: long, TP1 not hit AND bars held >= time-stop count AND close <= entry price
Exit: short, TP1 not hit AND bars held >= time-stop count AND close >= entry price