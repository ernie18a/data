Calculation: Chart trend = bullish when the shortest EMA of close > the intermediate EMA > the longer EMA, and bearish when the shortest EMA < the intermediate EMA < the longer EMA. The stop EMA has a longer lookback than all three.
Calculation: Higher-timeframe trend = the same three-EMA alignment calculated on higher-timeframe bars. For trend labels, use the still-forming higher-timeframe bar; use a still-higher timeframe for the other trend label. For the entry filter, use the last completed higher-timeframe bar.
Calculation: Higher-timeframe reference EMA = the intermediate EMA of close on the still-forming higher-timeframe bar used by the entry filter.
Calculation: Bullish golden bar = bullish chart trend AND absolute close minus open >= minimum body size AND, for either the shortest or intermediate EMA, close > that EMA AND (body low is between EMA minus maximum body drive and EMA plus body tolerance, inclusive OR low is between EMA minus maximum wick drive and EMA plus wick tolerance, inclusive) AND (wick filter disabled OR low >= intermediate EMA minus wick-overdrive tolerance).
Calculation: Bearish golden bar = bearish chart trend AND absolute close minus open >= minimum body size AND, for either the shortest or intermediate EMA, close < that EMA AND (body high is between EMA minus body tolerance and EMA plus maximum body drive, inclusive OR high is between EMA minus wick tolerance and EMA plus maximum wick drive, inclusive) AND (wick filter disabled OR high <= intermediate EMA plus wick-overdrive tolerance).
Calculation: Confirmed pivot low = the low of a bar is <= every low in an equal-length preceding window AND < every low in the following window; it is confirmed at the end of the following window. Confirmed pivot high = the high of a bar is >= every high in an equal-length preceding window AND > every high in the following window; it is confirmed at the end of the following window.
Calculation: Entry filter = (session filter disabled OR bar time is within the configured session) AND (higher-timeframe trend filter disabled OR NOT (completed higher-timeframe trend is bearish AND close > higher-timeframe reference EMA) AND NOT (completed higher-timeframe trend is bullish AND close < higher-timeframe reference EMA)) AND (proximity filter disabled OR close < higher-timeframe reference EMA minus proximity distance OR close > higher-timeframe reference EMA plus proximity distance).
Calculation: Buy signal = the bar at the confirmed pivot low is a bullish golden bar AND the following bar's body high >= the pivot bar's body high AND entry filter passes AND the number of prior buy signals since the most recent start of a bullish chart trend < signal limit. Reset that count when a bullish chart trend starts and increment it after each buy signal.
Calculation: Sell signal = the bar at the confirmed pivot high is a bearish golden bar AND the following bar's body low <= the pivot bar's body low AND entry filter passes AND the number of prior sell signals since the most recent start of a bearish chart trend < signal limit. Reset that count when a bearish chart trend starts and increment it after each sell signal.
Calculation: Long stop = the lower of the longer trend EMA and the stop EMA at the entry signal; short stop = the higher of those EMAs at the entry signal. Keep each stop fixed for its trade. Long target = entry price plus reward-to-risk multiplier times entry price minus long stop; short target = entry price minus reward-to-risk multiplier times short stop minus entry price.
Long: chart trend is bullish.
Short: chart trend is bearish.
Long: higher-timeframe trend is bullish.
Short: higher-timeframe trend is bearish.
Long: still-higher-timeframe trend is bullish.
Short: still-higher-timeframe trend is bearish.
Long: bullish golden bar.
Short: bearish golden bar.
Long: Robin option enabled AND chart trend is bullish AND previous bar is a bullish golden bar AND current body high > previous body high.
Short: Robin option enabled AND chart trend is bearish AND previous bar is a bearish golden bar AND current body low < previous body low.
Long: chart trend is bullish AND pivot low is confirmed.
Short: chart trend is bearish AND pivot high is confirmed.
Long: buy signal.
Short: sell signal.
Exit: long, low <= long stop OR high >= long target.
Exit: short, high >= short stop OR low <= short target.
Exit: long, sell signal AND short stop > close plus minimum price increment.
Exit: short, buy signal AND long stop < close minus minimum price increment.