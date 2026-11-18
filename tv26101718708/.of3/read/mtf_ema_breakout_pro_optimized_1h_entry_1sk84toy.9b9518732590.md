Calculation: strong candle = abs(close - open) > (high - low) * strong-body proportion
Calculation: T1/T2/T3 trend values = each timeframe's close and EMA(close, EMA lookback) from its current bar, sampled onto chart bars; T1 is longer than T2, T2 is longer than T3, and T3 is the chart timeframe; the requested bar is still forming in realtime, while historical lookahead-off values use the last completed bar until the requested bar's closing chart bar
Calculation: long entry price = high of the triggering long setup bar
Calculation: short entry price = low of the triggering short setup bar
Calculation: long risk = long entry price - low[n] of the triggering long setup bar, where n is the prior-bar offset
Calculation: short risk = high[n] of the triggering short setup bar - short entry price, where n is the prior-bar offset
Calculation: long stop = long entry price if the highest high from the entry bar through the current bar is at least long entry price + long risk * break-even trigger multiple; otherwise low[n] of the triggering long setup bar
Calculation: short stop = short entry price if the lowest low from the entry bar through the current bar is at most short entry price - short risk * break-even trigger multiple; otherwise high[n] of the triggering short setup bar
Long: flat AND a pending long setup exists from the latest flat chart bar where T1 close > T1 EMA AND T2 close > T2 EMA AND T3 close > T3 EMA AND RSI(close, RSI lookback) > RSI threshold AND strong candle AND close > EMA(close, EMA lookback) AND close[n] <= EMA(close, EMA lookback)[n] AND high > the setup bar's high
Short: flat AND a pending short setup exists from the latest flat chart bar where T1 close < T1 EMA AND T2 close < T2 EMA AND T3 close < T3 EMA AND RSI(close, RSI lookback) < RSI threshold AND strong candle AND close < EMA(close, EMA lookback) AND close[n] >= EMA(close, EMA lookback)[n] AND low < the setup bar's low
Exit: long, low <= long stop OR high >= long entry price + long risk * risk-reward multiple
Exit: short, high >= short stop OR low <= short entry price - short risk * risk-reward multiple