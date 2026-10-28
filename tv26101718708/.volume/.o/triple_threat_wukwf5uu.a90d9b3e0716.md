Calculation: RSI_MA = simple moving average of RSI
Calculation: BBWP = 100 × count of the preceding shorter BBW lookback readings less than or equal to current BBW, divided by the longer BBWP percentile lookback; BBW = (2 × standard deviation of price over the BBW lookback) / price moving-average basis
Calculation: BBWP_MA = moving average of BBWP
Calculation: Up_cross_active = (previous Up_cross_active AND RSI − RSI_MA ≥ −retest_threshold) OR RSI − RSI_MA > crossover_threshold
Calculation: Up_retested = Up_cross_active AND (previous Up_retested OR RSI − RSI_MA < retest_threshold)
Calculation: Down_cross_active = (previous Down_cross_active AND RSI_MA − RSI ≥ −retest_threshold) OR RSI_MA − RSI > crossover_threshold
Calculation: Down_retested = Down_cross_active AND (previous Down_retested OR RSI_MA − RSI < retest_threshold)
Calculation: Buy_trigger = (Up_retested AND RSI − RSI_MA > crossover_threshold) OR RSI − RSI_MA > instant_signal_threshold
Calculation: Sell_trigger = (Down_retested AND RSI_MA − RSI > crossover_threshold) OR RSI_MA − RSI > instant_signal_threshold
Calculation: Buy_zone = (Buy_trigger OR previous Buy_zone) AND NOT Sell_trigger
Calculation: Sell_zone = (Sell_trigger OR previous Sell_zone) AND NOT Buy_trigger
Calculation: RSI_buy_signal = Buy_zone AND previous Sell_zone
Calculation: RSI_sell_signal = Sell_zone AND previous Buy_zone
Calculation: Buy_confirmation = (previous Buy_confirmation AND NOT RSI_sell_signal) OR RSI ≤ oversold_level
Calculation: Sell_confirmation = (previous Sell_confirmation AND NOT RSI_buy_signal) OR RSI ≥ overbought_level
Calculation: BBWP_confirmation = BBWP − BBWP_MA > BBWP_confirmation_threshold
Calculation: Full_buy = Buy_zone AND (Buy_confirmation OR BBWP_confirmation) AND RSI > RSI_MA AND RSI_MA > oversold_level
Calculation: Full_sell = Sell_zone AND (Sell_confirmation OR BBWP_confirmation) AND RSI < RSI_MA AND RSI_MA < overbought_level
Calculation: Confirmed_buy_zone = (previous Confirmed_buy_zone OR Full_buy) AND NOT Full_sell
Calculation: Confirmed_sell_zone = (previous Confirmed_sell_zone OR Full_sell) AND NOT Full_buy
Calculation: Confirmed_buy_signal = Confirmed_buy_zone AND previous Confirmed_sell_zone
Calculation: Confirmed_sell_signal = Confirmed_sell_zone AND previous Confirmed_buy_zone
Calculation: Trend_buy_zone = Confirmed_buy_zone AND close > trend moving average
Calculation: Trend_sell_zone = Confirmed_sell_zone AND close < trend moving average
Calculation: Buy_signal = Trend_buy_zone AND NOT previous Trend_buy_zone
Calculation: Sell_signal = Trend_sell_zone AND NOT previous Trend_sell_zone
Long: RSI_buy_signal OR Confirmed_buy_signal OR Buy_signal
Short: RSI_sell_signal OR Confirmed_sell_signal OR Sell_signal
Exit: Long, low ≤ entry price × (1 − stop-loss fraction) OR high ≥ entry price × (1 + take-profit fraction)
Exit: Short, high ≥ entry price × (1 + stop-loss fraction) OR low ≤ entry price × (1 − take-profit fraction)