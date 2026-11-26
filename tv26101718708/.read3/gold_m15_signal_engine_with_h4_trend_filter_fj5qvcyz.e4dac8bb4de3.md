Calculation: ema_short = EMA(close, shortest EMA lookback)
Calculation: ema_mid = EMA(close, middle EMA lookback)
Calculation: ema_long = EMA(close, longest EMA lookback)
Calculation: ema_T1 = EMA(close, T1 EMA lookback, T1, last completed bar)
Calculation: rsi = RSI(close, RSI lookback)
Calculation: entry_atr = ATR(ATR lookback) evaluated at the entry bar
Calculation: tolerance = close * SR tolerance fraction
Calculation: support_levels = oldest-to-newest list of at most max supports values of PivotLow(low, swing length, swing length), where a value is added only if it is below close and at least min gap fraction * close away from every listed level, and the oldest level is dropped first when the list is full
Calculation: resistance_levels = oldest-to-newest list of at most max resistances values of PivotHigh(high, swing length, swing length), where a value is added only if it is above close and at least min gap fraction * close away from every listed level, and the oldest level is dropped first when the list is full
Calculation: support_match = first lvl in support_levels with lvl < close AND low <= lvl + tolerance AND low >= lvl - SR band multiple * tolerance
Calculation: resistance_match = first lvl in resistance_levels with lvl > close AND high >= lvl - tolerance AND high <= lvl + SR band multiple * tolerance
Calculation: bars_since_entry = bars elapsed since the last entry in either direction
Calculation: news_clear = bar close time is outside every window from a scheduled US economic release time minus pre-release minutes to that release time plus post-release minutes
Calculation: long_base = support_match when the support-bounce long line holds and the pullback long line does not, otherwise entry-bar low
Calculation: long_init_stop = long_base - MIN(stop range fraction * (entry-bar high - entry-bar low), max stop fraction * entry price)
Calculation: long_tp1 = entry price + entry_atr * TP1 multiple
Calculation: long_tp2 = nearest resistance_levels value above long_tp1 at entry if one exists, otherwise entry price + entry_atr * TP2 multiple
Calculation: long_tp3 = IF entry price + entry_atr * TP3 multiple <= long_tp2 THEN long_tp2 + TP3 extension fraction * (long_tp2 - entry price) ELSE entry price + entry_atr * TP3 multiple
Calculation: long_stop = IF highest high over bars after the entry bar up to the prior bar >= long_tp2 THEN long_tp1 ELSE IF highest high over bars after the entry bar up to the prior bar >= long_tp1 THEN entry price ELSE long_init_stop
Calculation: short_base = resistance_match when the resistance-bounce short line holds and the pullback short line does not, otherwise entry-bar high
Calculation: short_init_stop = short_base + MIN(stop range fraction * (entry-bar high - entry-bar low), max stop fraction * entry price)
Calculation: short_tp1 = entry price - entry_atr * TP1 multiple
Calculation: short_tp2 = nearest support_levels value below short_tp1 at entry if one exists, otherwise entry price - entry_atr * TP2 multiple
Calculation: short_tp3 = IF entry price - entry_atr * TP3 multiple >= short_tp2 THEN short_tp2 - TP3 extension fraction * (entry price - short_tp2) ELSE entry price - entry_atr * TP3 multiple
Calculation: short_stop = IF lowest low over bars after the entry bar up to the prior bar <= short_tp2 THEN short_tp1 ELSE IF lowest low over bars after the entry bar up to the prior bar <= short_tp1 THEN entry price ELSE short_init_stop
Long: close > ema_short AND low <= ema_short AND ema_short > ema_mid AND close > ema_long AND close - low >= strong-close fraction * (high - low) AND rsi >= pullback RSI floor AND rsi <= pullback RSI ceiling AND close(T1, last completed bar) > ema_T1 AND bars_since_entry >= cooldown length AND position side is not long AND news_clear
Long: support_match exists AND close - low >= strong-close fraction * (high - low) AND rsi < SR long RSI ceiling AND close(T1, last completed bar) > ema_T1 AND bars_since_entry >= cooldown length AND position side is not long AND news_clear
Long: close > Highest(high, breakout lookback)[1] AND high > low AND close - low >= breakout close fraction * (high - low) AND rsi < breakout long RSI ceiling AND close(T1, last completed bar) > ema_T1 AND bars_since_entry >= cooldown length AND position side is not long AND news_clear
Short: close < ema_short AND high >= ema_short AND ema_short < ema_mid AND close < ema_long AND high - close >= strong-close fraction * (high - low) AND rsi >= pullback RSI floor AND rsi <= pullback RSI ceiling AND close(T1, last completed bar) < ema_T1 AND bars_since_entry >= cooldown length AND position side is not short AND news_clear
Short: resistance_match exists AND high - close >= strong-close fraction * (high - low) AND rsi > SR short RSI floor AND close(T1, last completed bar) < ema_T1 AND bars_since_entry >= cooldown length AND position side is not short AND news_clear
Short: close < Lowest(low, breakout lookback)[1] AND high > low AND high - close >= breakout close fraction * (high - low) AND rsi > breakout short RSI floor AND close(T1, last completed bar) < ema_T1 AND bars_since_entry >= cooldown length AND position side is not short AND news_clear
Exit: long, low <= long_stop
Exit: long, high >= long_tp3
Exit: long, bars_since_entry >= expiry length
Exit: short, high >= short_stop
Exit: short, low <= short_tp3
Exit: short, bars_since_entry >= expiry length