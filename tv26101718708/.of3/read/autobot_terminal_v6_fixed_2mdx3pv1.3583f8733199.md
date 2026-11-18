Calculation: Allowed session = chart-bar time is within the session parameter in the exchange timezone
Calculation: T1 SMA = SMA(close, lookback) calculated on the current T1 bar, still forming in real time, and mapped to chart bars with lookahead off
Calculation: Previous T1 high = high of the last completed T1 bar, mapped to chart bars
Calculation: Previous T1 low = low of the last completed T1 bar, mapped to chart bars
Calculation: Latest T2 pivot high = most recent nonmissing Pivot High(high, left lookback, right lookback), calculated on the current T2 bar, still forming in real time, and mapped to chart bars with lookahead off; left and right lookbacks are equal
Calculation: Latest T2 pivot low = most recent nonmissing Pivot Low(low, left lookback, right lookback), calculated on the current T2 bar, still forming in real time, and mapped to chart bars with lookahead off; left and right lookbacks are equal
Calculation: Previous T3 open = open of the last completed T3 bar, mapped to chart bars
Calculation: Previous T3 close = close of the last completed T3 bar, mapped to chart bars
Calculation: Chart VWAP = VWAP(close) calculated on chart bars
Calculation: Support zone = (latest T2 pivot low exists AND chart close >= latest T2 pivot low AND chart close <= latest T2 pivot low × (1 + support-zone width parameter)) OR (previous T1 low exists AND chart close >= previous T1 low AND chart close <= previous T1 low × (1 + support-zone width parameter))
Calculation: Resistance zone = (latest T2 pivot high exists AND chart close <= latest T2 pivot high AND chart close >= latest T2 pivot high × (1 − resistance-zone width parameter)) OR (previous T1 high exists AND chart close <= previous T1 high AND chart close >= previous T1 high × (1 − resistance-zone width parameter))
Calculation: Entry price = chart close on the entry bar
Calculation: Long stop = (latest T2 pivot low if available, otherwise previous T1 low if available, otherwise entry price) × (1 − long stop-buffer parameter), fixed at entry
Calculation: Short stop = (latest T2 pivot high if available, otherwise previous T1 high if available, otherwise entry price) × (1 + short stop-buffer parameter), fixed at entry
Calculation: Long target = entry price + target-multiple parameter × (entry price − long stop), fixed at entry
Calculation: Short target = entry price − target-multiple parameter × (short stop − entry price), fixed at entry
Long: (position is flat or long) AND allowed session AND support zone AND chart close crosses above chart VWAP AND ((chart close > T1 SMA AND (previous T3 close > previous T3 open OR (latest T2 pivot low exists AND previous T3 close > latest T2 pivot low))) OR chart close < T1 SMA)
Short: (position is flat or short) AND allowed session AND chart close < T1 SMA AND resistance zone AND (previous T3 close < previous T3 open OR (previous T1 low exists AND previous T3 close < previous T1 low)) AND chart close crosses below chart VWAP
Exit: long, chart high >= long target OR chart low <= long stop
Exit: short, chart low <= short target OR chart high >= short stop