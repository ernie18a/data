Calculation: RSI = relative strength index of close over RSI_length bars
Calculation: signal_MA = simple moving average of close over signal_length bars, where signal_length is shorter than mid_length
Calculation: fast_MA = simple moving average of close over fast_length bars, where fast_length is shorter than mid_length
Calculation: mid_MA = simple moving average of close over mid_length bars
Calculation: additional_mid_MA = simple moving average of close over additional_mid_length bars on the additional timeframe, using the bar still forming
Long: RSI < RSI_oversold AND signal_MA < mid_MA
Exit: long, RSI > RSI_overbought AND fast_MA > mid_MA
Exit: long, close < additional_mid_MA AND close[1] >= additional_mid_MA[1]