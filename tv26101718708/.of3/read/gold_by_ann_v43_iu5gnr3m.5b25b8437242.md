Calculation: trend MA = SMA(close, trend length)
Calculation: trend slope = trend MA - trend MA[slope lag]
Calculation: base price = SMA(close, base length)
Calculation: RSI = RSI(close, RSI length)
Calculation: last pivot low = ValueWhen(PivotLow(low, pivot left bars, pivot right bars) is not NA, PivotLow(low, pivot left bars, pivot right bars), 0)
Calculation: normal candle = (high - low) <= ATR(candle ATR length) * candle range multiplier
Calculation: tradable session = (dayofweek(datetime) = day-of-week A AND hour(datetime, session timezone) < cutoff hour) OR (dayofweek(datetime) = day-of-week B AND hour(datetime, session timezone) != blocked hour A AND hour(datetime, session timezone) != blocked hour B)
Calculation: T1 bullish = close[2] > open[2] (T1 bars, last completed bar)
Calculation: T1 range cap = T1 low + range fraction * (T1 high - T1 low) (chart bars, forming T1 bar)
Calculation: strong up volume = volume > SMA(volume, volume average length) * volume multiplier AND close > open
Calculation: strong down volume = volume > SMA(volume, volume average length) * volume multiplier AND close < open
Calculation: bullish breakout = ADX(adx length, adx length) > adx threshold AND close > trend MA AND RSI crosses above bull RSI level AND strong up volume AND close > ValueWhen(PivotHigh(high, pivot left bars, pivot right bars) is not NA, PivotHigh(high, pivot left bars, pivot right bars), 0)
Calculation: bearish breakdown = ADX(adx length, adx length) > adx threshold AND close < trend MA AND RSI crosses below bear RSI level AND strong down volume AND close < last pivot low
Calculation: spike = (Highest(high, spike window) - Lowest(low, spike window) >= spike price threshold) AND (SMA(volume, spike window) > SMA(volume, baseline volume length) * spike volume multiplier) (T2 bars, last completed bar)
Calculation: bullish spike = spike AND close > open[spike window - 1] (T2 bars, last completed bar)
Calculation: bearish spike = spike AND close <= open[spike window - 1] (T2 bars, last completed bar)
Calculation: morning star = close[2] < open[2] AND ABS(close[1] - open[1]) < ABS(close[2] - open[2]) * star body fraction AND close > open AND close > (open[2] + close[2]) / 2
Calculation: momentum RSI = RSI(close, momentum RSI length)
Long: tradable session AND normal candle AND T1 bullish AND trend slope > -flat threshold AND close <= T1 range cap AND ROC(close, overextension lookback) <= max move threshold AND PivotLow(low, pivot left bars, pivot right bars) is not NA
Long: close < T1 open (chart bars, forming T1 bar) AND (morning star OR BarsSince(PivotLow(low, pivot left bars, pivot right bars) is not NA) <= pivot recency lookback) AND close > EMA(close, EMA length) AND volume > SMA(volume, volume MA length) AND momentum RSI > momentum RSI lower bound AND momentum RSI < momentum RSI upper bound
Long: bullish spike
Short: tradable session AND normal candle AND T1 bullish AND trend slope > -flat threshold AND close <= T1 range cap AND ROC(close, overextension lookback) <= max move threshold AND PivotHigh(high, pivot left bars, pivot right bars) is not NA AND close < trend MA AND RSI < short entry RSI level
Short: position side is long AND normal candle AND close <= entry price - base price * SL percent AND close < trend MA AND RSI < bear RSI level AND strong down volume AND close < last pivot low
Short: bearish spike
Exit: long, normal candle AND close >= entry price + base price * long sub-TP percent
Exit: long, normal candle AND close >= entry price + base price * TP percent
Exit: long, normal candle AND close <= entry price - base price * SL percent
Exit: long, normal candle AND bearish breakdown
Exit: long, bullish spike
Exit: short, normal candle AND close <= entry price - base price * short sub-TP percent
Exit: short, normal candle AND close <= entry price - base price * TP percent
Exit: short, normal candle AND close >= entry price + base price * SL percent
Exit: short, normal candle AND bullish breakout
Exit: short, bearish spike