Calculation: trend_dir = 1 if EMA(close, shorter lookback) > EMA(close, middle lookback) AND EMA(close, middle lookback) > EMA(close, longer lookback); -1 if EMA(close, shorter lookback) < EMA(close, middle lookback) AND EMA(close, middle lookback) < EMA(close, longer lookback); 0 otherwise, where shorter lookback < middle lookback < longer lookback
Calculation: latest_pivot_low = PivotLow(low, pivot span) when PivotLow(low, pivot span) is defined, otherwise latest_pivot_low[1]
Calculation: latest_pivot_high = PivotHigh(high, pivot span) when PivotHigh(high, pivot span) is defined, otherwise latest_pivot_high[1]
Calculation: near_support = 0 <= (close - latest_pivot_low) / ATR(high, low, close, ATR lookback) < near band
Calculation: near_resistance = 0 <= (latest_pivot_high - close) / ATR(high, low, close, ATR lookback) < near band
Calculation: sr_dir = 1 if near_support AND NOT near_resistance; -1 if near_resistance AND NOT near_support; 0 otherwise
Calculation: vol_dir = 1 if (volume - SMA(volume, volume lookback)) / STDEV(volume, volume lookback) >= z threshold AND OBV(close, volume) > OBV(close, volume)[OBV lag] AND close > open; -1 if (volume - SMA(volume, volume lookback)) / STDEV(volume, volume lookback) >= z threshold AND OBV(close, volume) < OBV(close, volume)[OBV lag] AND close < open; 0 otherwise
Calculation: mom_dir = 1 if RSI(close, RSI lookback) > RSI midline AND MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) > 0 AND SMA(STOCH_K(close, high, low, stochastic lookback), stochastic smoothing) > stochastic midline; -1 if RSI(close, RSI lookback) < RSI midline AND MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) < 0 AND SMA(STOCH_K(close, high, low, stochastic lookback), stochastic smoothing) < stochastic midline; 0 otherwise, where MACD fast lookback < MACD slow lookback
Calculation: bb_expanding = BBWidth(close, bb lookback, bb multiplier) > expansion factor * SMA(BBWidth(close, bb lookback, bb multiplier), averaging lookback), where averaging lookback > bb lookback
Calculation: volatility_dir = 1 if bb_expanding AND close > open; -1 if bb_expanding AND close < open; 0 otherwise
Calculation: vote_total = trend_dir + sr_dir + vol_dir + mom_dir + volatility_dir
Calculation: bullish_consensus = vote_total >= consensus threshold AND trend_dir == 1 AND sr_dir >= 0
Calculation: bearish_consensus = vote_total <= -consensus threshold AND trend_dir == -1 AND sr_dir <= 0
Calculation: signal_memory = 1 if bullish_consensus; -1 if bearish_consensus; 0 if signal_memory[1] != 0 AND |vote_total| < reset threshold; otherwise signal_memory[1]
Calculation: stop_distance(side) = max(stop multiple * ATR(high, low, close, ATR lookback) * volume multiplier, min(structure distance(side), structure cap multiple * stop multiple * ATR(high, low, close, ATR lookback))), where volume multiplier = expansion multiplier if bb_expanding, squeeze multiplier if BBWidth(close, bb lookback, bb multiplier) < squeeze factor * SMA(BBWidth(close, bb lookback, bb multiplier), averaging lookback), otherwise 1; structure distance(long) = entry price - latest_pivot_low + structure buffer * ATR(high, low, close, ATR lookback) if latest_pivot_low < entry price, otherwise stop multiple * ATR(high, low, close, ATR lookback); structure distance(short) = latest_pivot_high - entry price + structure buffer * ATR(high, low, close, ATR lookback) if latest_pivot_high > entry price, otherwise stop multiple * ATR(high, low, close, ATR lookback); all terms evaluated at the entry bar
Calculation: target3_distance(side) = target3 multiple * reward ratio * stop_distance(side) * (momentum boost if mom_dir at the entry bar = side sign, otherwise 1), where side sign is 1 for long and -1 for short
Calculation: trail_stop(side) = for long, max over bars from the entry bar through the current bar where mom_dir = 1 of (close - trail multiple * ATR(high, low, close, ATR lookback)); for short, min over bars from the entry bar through the current bar where mom_dir = -1 of (close + trail multiple * ATR(high, low, close, ATR lookback))
Long: bullish_consensus AND signal_memory[1] != 1
Long: bullish_consensus
Long: vote_total >= consensus threshold
Long: vote_total > 0
Long: trend_dir == 1
Long: sr_dir == 1
Long: vol_dir == 1
Long: mom_dir == 1
Long: volatility_dir == 1
Short: bearish_consensus AND signal_memory[1] != -1
Short: bearish_consensus
Short: vote_total <= -consensus threshold
Short: vote_total < 0
Short: trend_dir == -1
Short: sr_dir == -1
Short: vol_dir == -1
Short: mom_dir == -1
Short: volatility_dir == -1
Exit: long, low <= entry price - stop_distance(long) OR (trailing enabled AND low <= trail_stop(long)[1]) OR (target3 enabled AND high >= entry price + target3_distance(long))
Exit: short, high >= entry price + stop_distance(short) OR (trailing enabled AND high >= trail_stop(short)[1]) OR (target3 enabled AND low <= entry price - target3_distance(short))