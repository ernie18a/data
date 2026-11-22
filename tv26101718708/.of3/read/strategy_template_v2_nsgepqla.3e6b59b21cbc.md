Calculation: long bias = Donchian lower(lookback, chart bars) > Donchian midpoint(the same lookback, T1 bars, last completed bar, carried to chart bars) AND datetime is within the configured date range
Calculation: short bias = Donchian upper(lookback, chart bars) < Donchian midpoint(the same lookback, T1 bars, last completed bar, carried to chart bars) AND datetime is within the configured date range
Long: long bias AND (market or stop-limit entry configured AND crossover(high, Donchian upper(lookback)[1]) OR stop entry configured OR limit entry configured AND high > Donchian midpoint(lookback))
Short: short bias AND (market or stop-limit entry configured AND crossunder(low, Donchian lower(lookback)[1]) OR stop entry configured OR limit entry configured AND low < Donchian midpoint(lookback))
Calculation: long profit target = if not long then Donchian upper(lookback) + reward multiple × (Donchian upper(lookback) − Donchian lower(lookback)); otherwise, if high[1] > long profit target[1], long profit target[1] + reward multiple × (Donchian upper(lookback) − Donchian lower(lookback)); otherwise, long profit target[1]
Calculation: short profit target = if not short then Donchian lower(lookback) − reward multiple × (Donchian upper(lookback) − Donchian lower(lookback)); otherwise, if low[1] < short profit target[1], short profit target[1] − reward multiple × (Donchian upper(lookback) − Donchian lower(lookback)); otherwise, short profit target[1]
Exit: short, long bias
Exit: long, short bias
Exit: long, stop exit configured AND low <= Donchian lower(lookback)
Exit: short, stop exit configured AND high >= Donchian upper(lookback)
Exit: long, market exit configured AND NOT long bias AND crossunder(low, Donchian lower(lookback)[1])
Exit: short, market exit configured AND NOT short bias AND crossover(high, Donchian upper(lookback)[1])
Exit: long, long bias AND take profit enabled AND high >= long profit target
Exit: short, short bias AND take profit enabled AND low <= short profit target
Calculation: bullish bias = Donchian lower band(N) > T1 Donchian midpoint(N) AND within the configured trading window
Calculation: bearish bias = Donchian upper band(N) < T1 Donchian midpoint(N) AND within the configured trading window
Long: bullish bias AND ((entry mode is market or stop-limit AND high crosses above the prior Donchian upper band(N)) OR entry mode is stop OR (entry mode is limit AND high > Donchian midpoint(N)))
Short: bearish bias AND ((entry mode is market or stop-limit AND low crosses below the prior Donchian lower band(N)) OR entry mode is stop OR (entry mode is limit AND low < Donchian midpoint(N)))
Calculation: long profit target = if there is no long position, Donchian upper band(N) + R × (Donchian upper band(N) − Donchian lower band(N)); otherwise, if prior high > prior long profit target, prior long profit target + R × (Donchian upper band(N) − Donchian lower band(N)); otherwise, prior long profit target
Calculation: short profit target = if there is no short position, Donchian lower band(N) − R × (Donchian upper band(N) − Donchian lower band(N)); otherwise, if prior low < prior short profit target, prior short profit target − R × (Donchian upper band(N) − Donchian lower band(N)); otherwise, prior short profit target
Exit: Long, bearish bias OR (exit mode is market AND low crosses below the prior Donchian lower band(N) AND NOT bullish bias) OR (bullish bias AND initial profit taking is enabled AND high ≥ long profit target)
Exit: Short, bullish bias OR (exit mode is market AND high crosses above the prior Donchian upper band(N) AND NOT bearish bias) OR (bearish bias AND initial profit taking is enabled AND low ≤ short profit target)