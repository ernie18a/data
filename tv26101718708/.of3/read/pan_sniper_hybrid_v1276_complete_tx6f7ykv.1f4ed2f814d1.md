Calculation: Bullish volume share = on each chart bar, sum(volume of lower-timeframe T1 bars whose close > open within that chart bar) / total volume of those T1 bars; use a fallback parameter when total volume is zero; use T1 bars including the bar still forming.
Calculation: Bearish fair-value gap = high < low[2] AND close[1] < low[2]
Long: a confirmed ta.pivothigh(high, structure left lookback, structure right lookback) > the previous confirmed pivot high, using a fallback parameter if absent, OR a confirmed ta.pivotlow(low, structure left lookback, structure right lookback) >= the previous confirmed pivot low, using a fallback parameter if absent
Short: a confirmed ta.pivothigh(high, structure left lookback, structure right lookback) <= the previous confirmed pivot high, using a fallback parameter if absent, OR a confirmed ta.pivotlow(low, structure left lookback, structure right lookback) < the previous confirmed pivot low, using a fallback parameter if absent
Long: MACD(close, fast EMA lookback, slow EMA lookback, signal smoothing lookback) crosses above its signal line AND close > EMA(close, Gaussian lookback) AND Bullish volume share > bull signal threshold
Short: MACD(close, fast EMA lookback, slow EMA lookback, signal smoothing lookback) crosses below its signal line AND close < EMA(close, Gaussian lookback) AND Bullish volume share < bear signal threshold
Long: EMA(close, Gaussian lookback) > its value one chart bar ago
Short: EMA(close, Gaussian lookback) <= its value one chart bar ago
Long: close > EMA(close, Gaussian lookback)
Short: close <= EMA(close, Gaussian lookback)
Long: close >= SMMA(hl2, teeth lookback)
Short: close < SMMA(hl2, teeth lookback)
Long: Bullish volume share > bull signal threshold
Short: Bullish volume share < bear signal threshold
Long: high > the latest confirmed structure pivot high AND close < that pivot high AND Bullish volume share < shark bear threshold
Short: low < the latest confirmed structure pivot low AND close > that pivot low AND Bullish volume share > shark bull threshold
Long: low > high[2] AND close[1] > high[2]
Short: Bearish fair-value gap
Long: ((low <= the high of the last completed T2 bar + true range * zone buffer threshold) OR (low <= the open of the still-forming T2 bar - SMA(high - low, ADR lookback, calculated on T2 bars, last completed T2 bar))) AND ((min(open, close) - low > true range * wick threshold AND high - max(open, close) < true range * small-wick threshold) OR (close > open[1] AND open < close[1] AND close - open > true range * body threshold)) AND volume > SMA(volume, volume-average lookback) * volume multiplier AND more than the cooldown lookback bars have elapsed since the prior combined buy or sell signal, or since chart start
Short: ((high >= the low of the last completed T2 bar - true range * zone buffer threshold) OR (high >= the open of the still-forming T2 bar + SMA(high - low, ADR lookback, calculated on T2 bars, last completed T2 bar))) AND ((high - max(open, close) > true range * wick threshold AND min(open, close) - low < true range * small-wick threshold) OR (close < open[1] AND open > close[1] AND open - close > true range * body threshold)) AND volume > SMA(volume, volume-average lookback) * volume multiplier AND more than the cooldown lookback bars have elapsed since the prior combined buy or sell signal, or since chart start
Long: on chart bars, the confirmed pivot low of chart low using the SMT pivot lookback is lower than its previous confirmed pivot low AND the corresponding confirmed pivot low of the reference series on the chart timeframe is higher than its previous confirmed pivot low
Short: on chart bars, the confirmed pivot high of chart high using the SMT pivot lookback is higher than its previous confirmed pivot high AND the corresponding confirmed pivot high of the reference series on the chart timeframe is lower than its previous confirmed pivot high
Short: a bearish OB target is created when the previous chart bar had a close crossing below the prior tracked swing low or a bearish fair-value gap
Long: (close crosses above the prior-bar tracked swing high OR close crosses above the low[2] boundary of the latest bearish fair-value gap) AND a bearish OB target is active