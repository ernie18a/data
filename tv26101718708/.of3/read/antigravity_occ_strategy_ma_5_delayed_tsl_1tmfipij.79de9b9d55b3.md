Calculation: Signal close MA = selected MA(close[delay offset], MA lookback, MA type, LSMA offset/ALMA sigma, ALMA offset), calculated on T1 bars using the bar still forming and sampled on chart bars when alternate resolution is enabled (T1 is chart timeframe multiplied by the alternate-resolution multiplier); otherwise calculated on chart bars
Calculation: Signal open MA = selected MA(open[delay offset], the same MA parameters as Signal close MA), calculated on T1 bars using the bar still forming and sampled on chart bars when alternate resolution is enabled; otherwise calculated on chart bars
Calculation: Long TSL active = reset to false when flat; while long, prior Long TSL active OR high > entry price * (1 + activation parameter)
Calculation: Short TSL active = reset to false when flat; while short, prior Short TSL active OR low < entry price * (1 - activation parameter)
Calculation: Long TSL stop = entry price * (1 - fixed stop parameter) while inactive; while active, max(high * (1 - trailing stop parameter), prior Long TSL stop, or entry price * (1 - fixed stop parameter) if there is no prior stop)
Calculation: Short TSL stop = entry price * (1 + fixed stop parameter) while inactive; while active, min(low * (1 + trailing stop parameter), prior Short TSL stop, or entry price * (1 + fixed stop parameter) if there is no prior stop)
Long: Signal close MA crosses above Signal open MA AND long entries are enabled AND (ADX filter is disabled OR ADX(ADX period) > (automatic threshold enabled ? median(ADX(ADX period), threshold lookback) : manual threshold))
Short: Signal close MA crosses below Signal open MA AND short entries are enabled AND (ADX filter is disabled OR ADX(ADX period) > (automatic threshold enabled ? median(ADX(ADX period), threshold lookback) : manual threshold))
Exit: long, Signal close MA crosses below Signal open MA AND trade mode is long-only
Exit: short, Signal close MA crosses above Signal open MA AND trade mode is short-only
Exit: long, trailing stop is enabled AND low <= Long TSL stop
Exit: short, trailing stop is enabled AND high >= Short TSL stop
Exit: long, take profit is enabled AND high >= entry price * (1 + take-profit parameter)
Exit: short, take profit is enabled AND low <= entry price * (1 - take-profit parameter)
Long: Signal close MA > Signal open MA
Short: Signal close MA <= Signal open MA
Long: bar coloring is enabled AND selected MA(close[delay offset], same MA parameters as Signal close MA) on chart bars > Signal open MA
Short: bar coloring is enabled AND selected MA(close[delay offset], same MA parameters as Signal close MA) on chart bars <= Signal open MA
Long: position side is long AND Long TSL active AND NOT Long TSL active[1]
Short: position side is short AND Short TSL active AND NOT Short TSL active[1]