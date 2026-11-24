Calculation: three-bar ATR-normalized momentum = (close - close[3]) / ATR(14), calculated on bars of the applicable timeframe
Calculation: relative volume = volume / SMA(volume[1], 20), calculated on source-timeframe bars
Long: On completed chart bars, three-bar ATR-normalized momentum > 0
Short: On completed chart bars, three-bar ATR-normalized momentum < 0
Long: On chart bars using the last completed bar of any source timeframe T1, T2, T3, T4, or T5, three-bar ATR-normalized momentum > 0
Short: On chart bars using the last completed bar of any source timeframe T1, T2, T3, T4, or T5, three-bar ATR-normalized momentum < 0
Long: On chart bars using the last completed bar of any source timeframe T1, T2, T3, T4, or T5, close > EMA(close, 50) AND EMA(close, 50) > EMA(close, 50)[3]
Short: On chart bars using the last completed bar of any source timeframe T1, T2, T3, T4, or T5, close < EMA(close, 50) AND EMA(close, 50) < EMA(close, 50)[3]
Long: On completed chart bars, three-bar ATR-normalized momentum >= 0.15 AND its value one chart bar ago <= 0
Short: On completed chart bars, three-bar ATR-normalized momentum <= -0.15 AND its value one chart bar ago >= 0
Long: On chart bars using the last completed bar of any source timeframe T1, T2, T3, T4, or T5, three-bar ATR-normalized momentum >= 0.15 AND its value one source bar ago <= 0
Short: On chart bars using the last completed bar of any source timeframe T1, T2, T3, T4, or T5, three-bar ATR-normalized momentum <= -0.15 AND its value one source bar ago >= 0
Long: On chart bars using the last completed bar of any source timeframe T1, T2, T3, T4, or T5, three-bar ATR-normalized momentum >= 1 AND relative volume >= 1.5 AND NOT (relative volume >= 2.5 AND abs((close - open) / ATR(14)) < 0.25)
Short: On chart bars using the last completed bar of any source timeframe T1, T2, T3, T4, or T5, three-bar ATR-normalized momentum <= -1 AND relative volume >= 1.5 AND NOT (relative volume >= 2.5 AND abs((close - open) / ATR(14)) < 0.25)
Short: On chart bars using the last completed bar of any source timeframe T1, T2, T3, T4, or T5, close > EMA(close, 50) AND EMA(close, 50) > EMA(close, 50)[3] AND three-bar ATR-normalized momentum < 0 AND NOT (relative volume >= 2.5 AND abs((close - open) / ATR(14)) < 0.25) AND NOT (abs(three-bar ATR-normalized momentum) >= 1 AND relative volume >= 1.5)
Long: On chart bars using the last completed bar of any source timeframe T1, T2, T3, T4, or T5, close < EMA(close, 50) AND EMA(close, 50) < EMA(close, 50)[3] AND three-bar ATR-normalized momentum > 0 AND NOT (relative volume >= 2.5 AND abs((close - open) / ATR(14)) < 0.25) AND NOT (abs(three-bar ATR-normalized momentum) >= 1 AND relative volume >= 1.5)