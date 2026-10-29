Calculation: Prior NYSE session high/low = highest high and lowest low during the previous regular NYSE session.
Calculation: Pre-market body high/low = highest max(open, close) and lowest min(open, close) from the pre-market session, calculated on higher-timeframe bars and using completed bars.
Calculation: Previous futures-week high/low = highest high and lowest low during the previous futures week, calculated on higher-timeframe bars and using completed bars.
Calculation: Moving-average level = configured moving average of close, calculated on the chart timeframe or configured higher timeframe, using the latest completed bar.
Calculation: NY AM range = high minus low from the start of the current NY AM session through the current bar.
Calculation: Average NY AM range = average high-to-low range of prior completed NY AM sessions, excluding today, calculated on higher-timeframe bars and using completed bars.
Calculation: Remaining range budget = max(0, average NY AM range − NY AM range).
Calculation: Next level = nearest active reference level above close when close is at or above the midpoint of the current NY AM range; otherwise, nearest active reference level below close. Active levels are prior NYSE session high/low, pre-market body high/low, optionally previous futures-week high/low, and optionally the moving-average level.
Exit: long, current NY AM session is active AND close is at or above its midpoint AND a next level exists above close AND remaining range budget < (next level − close) × configured reach multiplier.
Exit: short, current NY AM session is active AND close is below its midpoint AND a next level exists below close AND remaining range budget < (close − next level) × configured reach multiplier.