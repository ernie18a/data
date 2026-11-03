Calculation: Higher-timeframe open and close = open and close of the current, still-forming bar aggregated from lower-timeframe bars
Long: Higher-timeframe close crosses above higher-timeframe open
Short: Higher-timeframe close crosses below higher-timeframe open
Calculation: Supertrend upper band = if prior close > prior upper band, max(hl2 − factor × ATR, prior upper band); otherwise hl2 − factor × ATR
Calculation: Supertrend lower band = if prior close < prior lower band, min(hl2 + factor × ATR, prior lower band); otherwise hl2 + factor × ATR
Calculation: Supertrend direction = 1 if close > prior lower band; −1 if close < prior upper band; otherwise prior direction (default 0)
Long: Supertrend direction = 1 AND prior Supertrend direction = −1
Short: Supertrend direction = −1 AND prior Supertrend direction = 1
Calculation: Channel bounds = EMA of the highest short-lookback avg(low, close), using a shorter smoothing lookback; and EMA of the lowest longer-lookback avg(high, close), using a longer smoothing lookback
Calculation: TEMA line = EMA(close, 1) − EMA(EMA(close, 1), 1) + EMA(EMA(EMA(close, 1), 1), 1)
Calculation: DEMA line = 2 × EMA(close, longer lookback) − EMA(EMA(close, longer lookback), shorter lookback)
Calculation: Trend signal = max(channel bounds) if TEMA line > DEMA line; otherwise min(channel bounds)
Long: TEMA line > DEMA line AND trend signal > low AND trend signal − prior trend signal > prior trend signal − trend signal two bars ago
Short: TEMA line < DEMA line AND trend signal < high AND prior trend signal − trend signal > trend signal two bars ago − prior trend signal