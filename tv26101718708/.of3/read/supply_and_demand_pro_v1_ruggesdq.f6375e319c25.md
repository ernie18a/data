Calculation: Early bullish momentum = (EMA(close, fast shorter lookback) > EMA(close, mid intermediate lookback) OR close > EMA(close, fast shorter lookback)) AND RSI(close, RSI lookback) > RSI midline
Calculation: Early bearish momentum = (EMA(close, fast shorter lookback) < EMA(close, mid intermediate lookback) OR close < EMA(close, fast shorter lookback)) AND RSI(close, RSI lookback) < RSI midline
Calculation: Strong bullish momentum = EMA(close, fast shorter lookback) > EMA(close, mid intermediate lookback) AND EMA(close, mid intermediate lookback) > EMA(close, slow longer lookback) AND RSI(close, RSI lookback) > RSI midline
Calculation: Strong bearish momentum = EMA(close, fast shorter lookback) < EMA(close, mid intermediate lookback) AND EMA(close, mid intermediate lookback) < EMA(close, slow longer lookback) AND RSI(close, RSI lookback) < RSI midline
Calculation: Upward BOS = close > highest(high, BOS lookback)[1] AND close[1] <= highest(high, BOS lookback)[1]
Calculation: Downward BOS = close < lowest(low, BOS lookback)[1] AND close[1] >= lowest(low, BOS lookback)[1]
Calculation: Session allowed = session filter disabled OR chart-bar time is within the configured stock or futures session window in America/New_York
Calculation: Same-side cooldown satisfied = no prior signal for this side OR at least the cooldown lookback bars since its latest long or short signal
Calculation: Long stop price = MIN(low, low[1]) * (1 - stop-buffer percentage / 100), set on each X-buy bar and unchanged by M signals
Calculation: Short stop price = MAX(high, high[1]) * (1 + stop-buffer percentage / 100), set on each X-sell bar and unchanged by M signals
Calculation: Long risk = X-buy bar close - long stop price, set on each X-buy bar
Calculation: Short risk = short stop price - X-sell bar close, set on each X-sell bar
Calculation: Long target 1 = X-buy bar close + long risk * target-one reward/risk parameter, set on each X-buy bar
Calculation: Long target 2 = X-buy bar close + long risk * target-two reward/risk parameter, set on each X-buy bar
Calculation: Long target 3 = X-buy bar close + long risk * target-three reward/risk parameter, set on each X-buy bar
Calculation: Short target 1 = X-sell bar close - short risk * target-one reward/risk parameter, set on each X-sell bar
Calculation: Short target 2 = X-sell bar close - short risk * target-two reward/risk parameter, set on each X-sell bar
Calculation: Short target 3 = X-sell bar close - short risk * target-three reward/risk parameter, set on each X-sell bar
Long: Early bullish momentum AND RSI(close, RSI lookback) > RSI midline + RSI breakout margin AND NOT Strong bearish momentum AND Upward BOS AND Same-side cooldown satisfied AND Session allowed
Long: Strong bullish momentum AND barssince(Upward BOS) <= BOS signal-window lookback AND NOT an X-buy signal on this bar AND (no prior X-buy signal OR more than the long continuation-delay parameter bars since the latest X-buy) AND Same-side cooldown satisfied AND Session allowed
Short: Early bearish momentum AND RSI(close, RSI lookback) < RSI midline - RSI breakout margin AND NOT Strong bullish momentum AND Downward BOS AND Same-side cooldown satisfied AND Session allowed
Short: Strong bearish momentum AND barssince(Downward BOS) <= BOS signal-window lookback AND NOT an X-sell signal on this bar AND (no prior X-sell signal OR more than the short continuation-delay parameter bars since the latest X-sell) AND Same-side cooldown satisfied AND Session allowed
Exit: long, low <= long stop price OR (high >= long target 1 AND low[1] < long target 1) OR (high >= long target 2 AND low[1] < long target 2) OR (high >= long target 3 AND low[1] < long target 3)
Exit: short, high >= short stop price OR (low <= short target 1 AND high[1] > short target 1) OR (low <= short target 2 AND high[1] > short target 2) OR (low <= short target 3 AND high[1] > short target 3)