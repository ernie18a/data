Calculation: Higher-timeframe data = use the last completed bar of each higher timeframe; the cycle timeframe is shorter than the macro timeframe. Compare a higher-timeframe indicator with its value on the previous chart bar when testing whether it is rising.
Calculation: Macro supportive = higher-timeframe close > short EMA AND (short EMA > longer EMA OR RSI > recovery threshold).
Calculation: Macro strong = higher-timeframe close > short EMA AND short EMA > longer EMA.
Calculation: Macro weak = higher-timeframe close < short EMA AND short EMA < longer EMA.
Calculation: Cycle strong = cycle-timeframe close > EMA AND cycle-timeframe RSI > strength threshold.
Calculation: Cycle recovery = cycle-timeframe RSI > recovery threshold AND cycle-timeframe RSI > its value on the previous chart bar.
Calculation: Cycle position = (close - lowest low over the cycle lookback) / max(highest high over the cycle lookback - lowest low over the cycle lookback, positive minimum range).
Calculation: Zone range = max(highest high over the shorter zone lookback - lowest low over the shorter zone lookback, positive minimum range).
Calculation: Lower zone boundary = lowest low over the zone lookback + zone range × lower zone fraction.
Calculation: Upper zone boundary = lowest low over the zone lookback + zone range × upper zone fraction; upper zone fraction > lower zone fraction.
Calculation: Bottom score = sum of positive weights for each true condition: cycle position < high bottom threshold, cycle position < lower bottom threshold, cycle-timeframe RSI < depressed threshold, cycle recovery, chart RSI < bottom threshold, close < lower zone boundary; cap the sum at the maximum score.
Calculation: Top score = sum of positive weights for each true condition: cycle position > low top threshold, cycle position > higher top threshold, chart RSI > low overbought threshold, chart RSI > higher overbought threshold, close > upper zone boundary; cap the sum at the maximum score.
Calculation: Trend state = bullish initially; on each chart bar set bullish if close > previous bar's trend EMA + previous bar's ATR × sensitivity, otherwise set bearish if close < previous bar's trend EMA - previous bar's ATR × sensitivity, otherwise retain the previous state.
Calculation: Buy cooldown = no earlier cooldown-qualified buy signal exists OR bars since the most recent cooldown-qualified buy signal > cooldown length; any qualified buy signal resets the shared buy cooldown.
Calculation: Sell cooldown = no earlier cooldown-qualified sell signal exists OR bars since the most recent cooldown-qualified sell signal > cooldown length; any qualified sell signal resets the shared sell cooldown.
Long: Macro supportive AND bottom score >= bottom score threshold AND chart RSI crosses above its bottom recovery threshold AND buy cooldown.
Long: Macro supportive AND cycle recovery AND close crosses above short chart EMA AND chart RSI > confirmation threshold AND buy cooldown.
Long: Macro strong AND cycle strong AND low <= short chart EMA AND close > short chart EMA AND chart RSI < dip ceiling AND close > open AND buy cooldown.
Long: Macro strong AND cycle strong AND close > highest high over the breakout lookback ending on the previous chart bar AND chart RSI < breakout ceiling AND buy cooldown.
Exit: long, top score >= profit threshold AND high > upper zone boundary AND sell cooldown.
Exit: long, top score >= higher profit threshold AND chart RSI > profit RSI threshold AND sell cooldown.
Exit: long, close crosses below short chart EMA AND top score >= lower trend-sell threshold AND sell cooldown.
Exit: long, (macro weak AND cycle recovery is false OR close crosses below longer chart EMA AND trend state is bearish) AND sell cooldown.