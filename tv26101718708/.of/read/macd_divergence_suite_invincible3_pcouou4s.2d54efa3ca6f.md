Calculation: MACD line = shorter-lookback moving average of a selected price source minus longer-lookback moving average of the same source; each moving average type is independently selectable from EMA, SMA, DEMA, TEMA, WMA, VWMA, HMA, and RMA.
Calculation: Signal line = selectable moving average of the MACD line; histogram = MACD line minus signal line.
Calculation: Normalized MACD and normalized signal = respectively MACD line and signal line divided by the rolling maximum absolute MACD line over the normalization lookback, multiplied by 100; both are zero when that maximum is zero.
Calculation: Normalized histogram = histogram divided by its rolling maximum absolute value over the normalization lookback, multiplied by 100; it is zero when that maximum is zero.
Calculation: Oscillator pivot = a normalized histogram high or low confirmed after an equal number of bars on each side; compare each confirmed pivot with the immediately preceding confirmed pivot of the same kind, using the chart high or low at each pivot. Evaluate divergence on the confirmation bar.
Calculation: Multi-timeframe state = the corresponding calculation on each selected timeframe; for a higher timeframe use the last completed bar on historical data and the forming bar in real time, and for a lower timeframe use the last available intrabar within the chart bar.
Long: Close > SMA of close.
Short: Close < SMA of close.
Long: Normalized histogram >= 0.
Short: Normalized histogram < 0.
Long: Normalized MACD > normalized signal AND normalized MACD > previous normalized MACD.
Short: Normalized MACD < normalized signal AND normalized MACD < previous normalized MACD.
Long: Normalized MACD >= normalized signal.
Short: Normalized MACD < normalized signal.
Long: Normalized MACD crosses above normalized signal AND (normalized MACD filter is disabled OR normalized MACD <= bullish threshold).
Short: Normalized MACD crosses below normalized signal AND (normalized MACD filter is disabled OR normalized MACD >= bearish threshold).
Long: Normalized histogram crosses above zero.
Short: Normalized histogram crosses below zero.
Long: Confirmed oscillator pivot low has a lower price low and a higher normalized histogram than the preceding oscillator pivot low AND (divergence zone filter is disabled OR either pivot's normalized histogram <= oversold threshold).
Short: Confirmed oscillator pivot high has a higher price high and a lower normalized histogram than the preceding oscillator pivot high AND (divergence zone filter is disabled OR either pivot's normalized histogram >= overbought threshold).
Long: Multi-timeframe MACD line > signal line.
Short: Multi-timeframe MACD line < signal line.
Long: Multi-timeframe close > SMA of close.
Short: Multi-timeframe close < SMA of close.
Long: Multi-timeframe normalized MACD < 0.
Short: Multi-timeframe normalized MACD > 0.
Long: Multi-timeframe bullish divergence occurred within the recent-bars lookback, including the current bar.
Short: Multi-timeframe bearish divergence occurred within the recent-bars lookback, including the current bar, AND no multi-timeframe bullish divergence occurred within that lookback.