Calculation: CPR top = max(TC, BC) of CPR(T1, last completed bar)
Calculation: CPR bottom = min(TC, BC) of CPR(T1, last completed bar)
Calculation: CPR-width percentile = 100 * (count of the last history-window T1 samples of abs(TC - BC) below the current abs(TC - BC)) / history window
Calculation: realized volatility = 100 * Yang-Zhang volatility(T1, RV lookback, last completed bar)
Calculation: VRP = IV - realized volatility, where IV = implied volatility index close (chart timeframe, last completed bar)
Calculation: VRP z-score = (VRP - median(S)) / (1.4826 * median(abs(S - median(S)))), where S = last history-window T1 samples of VRP
Calculation: IV rank = 100 * (IV - lowest(IV, IV window, T1)) / (highest(IV, IV window, T1) - lowest(IV, IV window, T1))
Calculation: tail risk = percentrank(IV, IV window, T1) >= tail IV percentile threshold OR realized volatility > tail RV multiple * median(last history-window T1 samples of realized volatility)
Calculation: days to expiry = days from bar time to the horizon's expiry (next expiry weekday for weekly, last such weekday of the month for monthly), or a fixed day count
Calculation: expected move = anchor price * (IV / 100) * sqrt(days to expiry / 365)
Calculation: skew = 100 * (P - C) / ((P + C) / 2), where P and C are option premiums at strikes one wing distance below and above chart close, interpolated over the option ladder (one ladder step if NA)
Calculation: basis z-score = (basis - SMA(basis, basis window)) / STDEV(basis, basis window), where basis = 100 * (close - spot index close) / spot index close
Long: close > CPR top
Long: CPR bottom > CPR top[1]
Long: close > call open-interest wall level
Long: skew < -tilt threshold
Long: basis z-score crosses above basis threshold
Short: close < CPR bottom
Short: CPR top < CPR bottom[1]
Short: close < put open-interest wall level
Short: skew > tilt threshold
Short: basis z-score crosses below -basis threshold
Exit: long, close >= floor pivot R1 (T1, last completed bar)
Exit: short, close <= floor pivot S1 (T1, last completed bar)
Option: buy call, chart timeframe is intraday AND VRP not NA AND CPR-width percentile <= narrow percentile threshold AND close > CPR top AND NOT tail risk AND NOT (VRP z-score > rich z-score threshold OR IV rank >= IV rank high threshold) AND days to expiry >= minimum days-to-expiry threshold AND abs(floor pivot R1 (T1, last completed bar) - T1 open (current bar)) >= expected move
Option: buy put, chart timeframe is intraday AND VRP not NA AND CPR-width percentile <= narrow percentile threshold AND close < CPR bottom AND NOT tail risk AND NOT (VRP z-score > rich z-score threshold OR IV rank >= IV rank high threshold) AND days to expiry >= minimum days-to-expiry threshold AND abs(floor pivot S1 (T1, last completed bar) - T1 open (current bar)) >= expected move
Option: buy call, chart timeframe is intraday AND VRP not NA AND narrow percentile threshold < CPR-width percentile < wide percentile threshold AND close > CPR top AND NOT tail risk
Option: buy put, chart timeframe is intraday AND VRP not NA AND narrow percentile threshold < CPR-width percentile < wide percentile threshold AND close < CPR bottom AND NOT tail risk