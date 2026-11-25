Calculation: Fast MA = MA(close, shorter lookback, moving-average method, T1, current bar still forming, sampled on chart bars)
Calculation: Lagged fast MA = MA(close, shorter lookback, moving-average method, T1, configurable MA lag on a completed bar, sampled on chart bars)
Calculation: Slow MA = MA(close, longer lookback, moving-average method, T1, current bar still forming, sampled on chart bars)
Calculation: Lagged slow MA = MA(close, longer lookback, moving-average method, T1, configurable MA lag on a completed bar, sampled on chart bars)
Calculation: Recent high = Highest(high, high-low lookback, T1, from the current bar still forming, sampled on chart bars)
Calculation: Recent low = Lowest(low, high-low lookback, T1, from the current bar still forming, sampled on chart bars)
Calculation: Bullish MA cross = lagged fast MA < lagged slow MA AND fast MA > slow MA
Calculation: Bearish MA cross = lagged fast MA > lagged slow MA AND fast MA < slow MA
Calculation: Bullish price-confirmed pattern = bullish MA cross AND close > fast MA AND close > slow MA AND recent low < fast MA AND recent low < slow MA
Calculation: Bearish price-confirmed pattern = bearish MA cross AND close < fast MA AND close < slow MA AND recent high > fast MA AND recent high > slow MA
Calculation: Lagged Williams %R = Williams %R(WPR lookback, T2, configurable WPR lag on a completed bar, sampled on chart bars)
Calculation: Current Williams %R = Williams %R(WPR lookback, T2, current bar still forming, sampled on chart bars)
Calculation: Lagged stochastic main line = Stochastic main(%K lookback, slowing period, %D lookback, smoothing method, T1, configurable stochastic lag on a completed bar, sampled on chart bars)
Calculation: Eligible same-side entry = same-strategy open-order count is below the directional order cap AND the absolute difference between close and every same-side open-order entry price is at least the add-on spacing
Calculation: Trend-up condition = Lowest(low, trend lookback, T1, offset by trend lookback times the older-block offset multiplier, completed bars) < Lowest(low, trend lookback, T1, offset by trend lookback, completed bars) < Lowest(low, trend lookback, T1, current bar still forming) AND close > Highest(high, trend lookback times the full-window multiplier, T1, current bar still forming), sampled on chart bars
Calculation: Trend-down condition = Highest(high, trend lookback, T1, offset by trend lookback times the older-block offset multiplier, completed bars) > Highest(high, trend lookback, T1, offset by trend lookback, completed bars) > Highest(high, trend lookback, T1, current bar still forming) AND close < Lowest(low, trend lookback times the full-window multiplier, T1, current bar still forming), sampled on chart bars
Calculation: Trend-filtered bullish setup = ((selected mode requires a rising slow MA AND lagged slow MA < slow MA) OR (selected mode requires a falling slow MA AND lagged slow MA > slow MA)) AND bullish MA cross
Calculation: Trend-filtered bearish setup = selected mode is a trend-filtered crossover AND lagged slow MA > slow MA AND bearish MA cross
Calculation: WPR-zone bullish setup = selected mode uses the WPR zone filter AND bullish price-confirmed pattern AND lagged Williams %R < WPR oversold-zone threshold
Calculation: WPR-zone bearish setup = selected mode uses the WPR zone filter AND bearish price-confirmed pattern AND lagged Williams %R > WPR overbought-zone threshold
Calculation: WPR-exit bullish setup = selected mode uses the WPR threshold-cross filter AND bullish price-confirmed pattern AND lagged Williams %R < WPR oversold-exit threshold AND current Williams %R > WPR oversold-exit threshold
Calculation: WPR-exit bearish setup = selected mode uses the WPR threshold-cross filter AND bearish price-confirmed pattern AND lagged Williams %R > WPR overbought-exit threshold AND current Williams %R < WPR overbought-exit threshold
Calculation: Stochastic-zone bullish setup = selected mode uses the stochastic zone filter AND bullish price-confirmed pattern AND lagged stochastic main line < stochastic oversold threshold
Calculation: Stochastic-zone bearish setup = selected mode uses the stochastic zone filter AND bearish price-confirmed pattern AND lagged stochastic main line > stochastic overbought threshold
Long: ((Trend-filtered bullish setup AND global direction-reversal setting is off) OR (Trend-filtered bearish setup AND global direction-reversal setting is on)) AND eligible same-side entry
Short: ((Trend-filtered bullish setup AND global direction-reversal setting is on) OR (Trend-filtered bearish setup AND global direction-reversal setting is off)) AND eligible same-side entry
Long: ((selected mode is unfiltered crossover AND bullish MA cross AND global direction-reversal setting is off) OR (selected mode is unfiltered crossover AND bearish MA cross AND global direction-reversal setting is on)) AND eligible same-side entry
Short: ((selected mode is unfiltered crossover AND bullish MA cross AND global direction-reversal setting is on) OR (selected mode is unfiltered crossover AND bearish MA cross AND global direction-reversal setting is off)) AND eligible same-side entry
Long: ((selected mode is price-confirmed crossover AND bullish price-confirmed pattern AND global direction-reversal setting is off) OR (selected mode is price-confirmed crossover AND bearish price-confirmed pattern AND global direction-reversal setting is on)) AND eligible same-side entry
Short: ((selected mode is price-confirmed crossover AND bullish price-confirmed pattern AND global direction-reversal setting is on) OR (selected mode is price-confirmed crossover AND bearish price-confirmed pattern AND global direction-reversal setting is off)) AND eligible same-side entry
Long: ((WPR-zone bullish setup AND global and WPR direction-reversal settings agree) OR (WPR-zone bearish setup AND global and WPR direction-reversal settings disagree)) AND eligible same-side entry
Short: ((WPR-zone bullish setup AND global and WPR direction-reversal settings disagree) OR (WPR-zone bearish setup AND global and WPR direction-reversal settings agree)) AND eligible same-side entry
Long: ((WPR-exit bullish setup AND global and WPR direction-reversal settings agree) OR (WPR-exit bearish setup AND global and WPR direction-reversal settings disagree)) AND eligible same-side entry
Short: ((WPR-exit bullish setup AND global and WPR direction-reversal settings disagree) OR (WPR-exit bearish setup AND global and WPR direction-reversal settings agree)) AND eligible same-side entry
Long: ((Stochastic-zone bullish setup AND global and stochastic direction-reversal settings agree) OR (Stochastic-zone bearish setup AND global and stochastic direction-reversal settings disagree)) AND eligible same-side entry
Short: ((Stochastic-zone bullish setup AND global and stochastic direction-reversal settings disagree) OR (Stochastic-zone bearish setup AND global and stochastic direction-reversal settings agree)) AND eligible same-side entry
Long: Trend-up condition AND NOT Trend-down condition
Short: Trend-down condition AND NOT Trend-up condition
Exit: long, stop-loss distance is positive AND low <= entry price - stop-loss distance
Exit: short, stop-loss distance is positive AND high >= entry price + stop-loss distance
Exit: long, take-profit distance is positive AND high >= entry price + take-profit distance
Exit: short, take-profit distance is positive AND low <= entry price - take-profit distance
Exit: long, trailing-stop setting is enabled AND stop-loss distance is positive AND low <= highest high since entry - stop-loss distance
Exit: short, trailing-stop setting is enabled AND stop-loss distance is positive AND high >= lowest low since entry + stop-loss distance