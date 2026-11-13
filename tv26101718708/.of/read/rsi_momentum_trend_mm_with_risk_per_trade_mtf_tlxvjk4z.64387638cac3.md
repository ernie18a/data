Calculation: HTF_RSI = RSI of close computed on bars aggregated to a timeframe higher than the chart timeframe, using the still-forming higher-timeframe bar that contains the current chart bar. HTF_RSI_prev = HTF_RSI value on the previous chart bar.
Calculation: HTF_EMA_chg = EMA of close on the same higher timeframe (still-forming bar) minus its value on the previous higher-timeframe bar.
Calculation: P_event = HTF_RSI_prev < pos_threshold AND HTF_RSI > pos_threshold AND HTF_EMA_chg > 0 (pos_threshold is greater than neg_threshold). N_event = HTF_RSI < neg_threshold AND HTF_EMA_chg < 0.
Calculation: Trend_state = persistent state, initially none. It becomes Positive on a bar where P_event is true and becomes Negative on a bar where N_event is true. Otherwise it keeps its previous value.
Calculation: ATR_entry = ATR on the chart timeframe, taken on the entry bar and held fixed for the life of the trade.
Long: position is flat AND P_event is true on this bar AND Trend_state before this bar's update was not Positive. Enter at this bar's close.
Short: position is flat AND N_event is true on this bar AND Trend_state before this bar's update was not Negative. Enter at this bar's close.
Exit: long, (reversal mode) the Short condition's event (N_event while Trend_state was not Negative) occurs, exit at close. Do not open the opposite trade on the same bar.
Exit: short, (reversal mode) the Long condition's event (P_event while Trend_state was not Positive) occurs, exit at close. Do not open the opposite trade on the same bar.
Exit: long, (ATR mode, no reversal exit) low <= entry_price - stop_mult * ATR_entry OR high >= entry_price + target_mult * ATR_entry (stop_mult is smaller than target_mult).
Exit: short, (ATR mode, no reversal exit) high >= entry_price + stop_mult * ATR_entry OR low <= entry_price - target_mult * ATR_entry (stop_mult is smaller than target_mult).
Exit: long, (percentage mode, alternative to ATR mode) low <= entry_price * (1 - stop_pct) OR high >= entry_price * (1 + target_pct).
Exit: short, (percentage mode, alternative to ATR mode) high >= entry_price * (1 + stop_pct) OR low <= entry_price * (1 - target_pct).