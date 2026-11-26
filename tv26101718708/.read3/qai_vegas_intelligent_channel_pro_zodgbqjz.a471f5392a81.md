Calculation: Filter EMA = EMA(selected source, filter lookback) on chart bars
Calculation: Short channel upper EMA = EMA(selected source, short upper lookback) on chart bars
Calculation: Short channel lower EMA = EMA(selected source, short lower lookback) on chart bars
Calculation: Vegas upper EMA = if Vegas MTF is enabled, EMA(selected source, Vegas upper lookback, T1, still-forming bar) sampled on chart bars; otherwise EMA(selected source, Vegas upper lookback) on chart bars
Calculation: Vegas lower EMA = if Vegas MTF is enabled, EMA(selected source, Vegas lower lookback, T1, still-forming bar) sampled on chart bars; otherwise EMA(selected source, Vegas lower lookback) on chart bars
Calculation: Mid channel upper EMA = EMA(selected source, mid upper lookback) on chart bars
Calculation: Mid channel lower EMA = EMA(selected source, mid lower lookback) on chart bars
Calculation: Long channel upper EMA = EMA(selected source, long upper lookback) on chart bars
Calculation: Long channel lower EMA = EMA(selected source, long lower lookback) on chart bars
Calculation: MTF Vegas upper EMA = EMA(selected source, Vegas upper lookback, T2, still-forming bar) sampled on chart bars
Calculation: MTF Vegas lower EMA = EMA(selected source, Vegas lower lookback, T2, still-forming bar) sampled on chart bars
Calculation: Bullish Vegas structure = close > Vegas lower EMA AND Vegas upper EMA > Vegas lower EMA AND close > Filter EMA
Calculation: Bearish Vegas structure = close < Vegas upper EMA AND Vegas upper EMA < Vegas lower EMA
Calculation: Volatility = StDev(close, regime lookback) / SMA(close, regime lookback) × volatility multiplier
Calculation: Adaptive bullish regime = adaptive engine enabled AND bullish Vegas structure AND ADX(DI lookback, smoothing lookback) > strong ADX threshold AND volatility < regime volatility cap
Calculation: Adaptive bearish regime = adaptive engine enabled AND bearish Vegas structure AND ADX(DI lookback, smoothing lookback) > strong ADX threshold AND volatility < regime volatility cap
Calculation: Bullish divergence(oscillator) = PivotLow(low, divergence left lookback, divergence right lookback) and PivotLow(oscillator, divergence left lookback, divergence right lookback) are present AND (oscillator[barssince(price pivot low)] > oscillator[barssince(oscillator pivot low)] OR hidden divergence is enabled AND oscillator[barssince(price pivot low)] < oscillator[barssince(oscillator pivot low)]) AND (confirmation bars = 0 OR barssince(price pivot low) >= confirmation bars)
Calculation: Bearish divergence(oscillator) = PivotHigh(high, divergence left lookback, divergence right lookback) and PivotHigh(oscillator, divergence left lookback, divergence right lookback) are present AND (oscillator[barssince(price pivot high)] < oscillator[barssince(oscillator pivot high)] OR hidden divergence is enabled AND oscillator[barssince(price pivot high)] > oscillator[barssince(oscillator pivot high)]) AND (confirmation bars = 0 OR barssince(price pivot high) >= confirmation bars)
Calculation: Candle delta = volume if close > open, −volume if close < open, otherwise 0
Calculation: Cumulative delta = previous cumulative delta + candle delta
Calculation: Delta pressure = 100 × candle delta / max(volume, volume floor)
Calculation: Delta bullish divergence = PivotLow(low, divergence left lookback, divergence right lookback) and PivotLow(candle delta, divergence left lookback, divergence right lookback) are present AND candle delta[barssince(price pivot low)] > candle delta[barssince(delta pivot low)]
Calculation: Delta bearish divergence = PivotHigh(high, divergence left lookback, divergence right lookback) and PivotHigh(candle delta, divergence left lookback, divergence right lookback) are present AND candle delta[barssince(price pivot high)] < candle delta[barssince(delta pivot high)]
Calculation: Volume surge = volume > SMA(volume, volume lookback) × volume surge multiplier AND volume > volume[1]
Calculation: MTF bullish Vegas bias = close > MTF Vegas lower EMA AND MTF Vegas upper EMA > MTF Vegas lower EMA
Calculation: MTF bearish Vegas bias = close < MTF Vegas upper EMA AND MTF Vegas upper EMA < MTF Vegas lower EMA
Calculation: Bullish divergence count = count of true Bullish divergence(RSI(selected source, RSI lookback)), Bullish divergence(MACD histogram(close, fast lookback, slow lookback, signal lookback)), and Bullish divergence(Stochastic %K(close, high, low, stochastic lookback))
Calculation: Strong adaptive regime = Adaptive bullish regime OR Adaptive bearish regime
Calculation: Vegas contribution = if bullish or bearish Vegas structure then Vegas weight × Vegas contribution multiplier × (strong adaptive regime ? Vegas regime multiplier : 1) else Vegas weight / inactive contribution divisor
Calculation: Divergence contribution = bullish divergence count × divergence weight × divergence contribution multiplier
Calculation: Volume contribution = if Volume surge then volume weight × volume contribution multiplier else volume weight / inactive contribution divisor
Calculation: MTF contribution = if MTF divergence confirmation is enabled AND ((MTF bullish Vegas bias AND bullish Vegas structure) OR (MTF bearish Vegas bias AND bearish Vegas structure)) then MTF weight × MTF contribution multiplier else MTF weight / inactive contribution divisor
Calculation: Delta contribution = if Delta bullish divergence OR Delta bearish divergence then delta weight × delta contribution multiplier × (strong adaptive regime ? delta regime multiplier : 1) else delta weight / inactive contribution divisor
Calculation: Confluence score = min(max(round(Vegas contribution + Divergence contribution + Volume contribution + MTF contribution + Delta contribution), score floor), score ceiling)
Long: close > Filter EMA
Short: close <= Filter EMA
Long: close > Short channel upper EMA
Short: close <= Short channel upper EMA
Long: close > Vegas upper EMA
Short: close <= Vegas upper EMA
Long: close > Mid channel upper EMA
Short: close <= Mid channel upper EMA
Long: close > Long channel upper EMA
Short: close <= Long channel upper EMA
Long: bullish Vegas structure
Short: bearish Vegas structure
Long: Adaptive bullish regime
Short: Adaptive bearish regime
Long: close crosses above the upper Bollinger Band AND Bollinger bandwidth > expansion threshold AND Bollinger bandwidth[1] >= squeeze threshold
Short: close crosses below the lower Bollinger Band AND Bollinger bandwidth > expansion threshold AND Bollinger bandwidth[1] >= squeeze threshold
Long: Bullish divergence(RSI(selected source, RSI lookback))
Short: Bearish divergence(RSI(selected source, RSI lookback))
Long: Bullish divergence(MACD histogram(close, fast lookback, slow lookback, signal lookback))
Short: Bearish divergence(MACD histogram(close, fast lookback, slow lookback, signal lookback))
Long: Bullish divergence(Stochastic %K(close, high, low, stochastic lookback))
Short: Bearish divergence(Stochastic %K(close, high, low, stochastic lookback))
Long: close > SMA(close, shortest SMA lookback) AND SMA(close, shortest SMA lookback) > SMA(close, middle SMA lookback) AND SMA(close, middle SMA lookback) > SMA(close, longest SMA lookback)
Short: close < SMA(close, shortest SMA lookback) AND SMA(close, shortest SMA lookback) < SMA(close, middle SMA lookback) AND SMA(close, middle SMA lookback) < SMA(close, longest SMA lookback)
Long: Cumulative delta > Cumulative delta[1] AND Delta bullish divergence
Short: Cumulative delta < Cumulative delta[1] AND Delta bearish divergence
Long: Delta pressure > buy pressure threshold
Short: Delta pressure < −buy pressure threshold
Long: candle delta > 0
Short: candle delta <= 0
Long: volume > volume[1]
Short: volume <= volume[1]
Long: not na(PivotLow(low, order block left lookback, order block right lookback))
Short: not na(PivotHigh(high, order block left lookback, order block right lookback))
Long: not na(PivotLow(low, structure left lookback, structure right lookback)) AND close > Vegas upper EMA AND volume > SMA(volume, volume lookback) × BOS volume multiplier
Short: not na(PivotHigh(high, structure left lookback, structure right lookback)) AND close < Vegas lower EMA AND volume > SMA(volume, volume lookback) × BOS volume multiplier
Long: not na(PivotLow(low, structure left lookback, structure right lookback)) AND close < Vegas lower EMA
Short: not na(PivotHigh(high, structure left lookback, structure right lookback)) AND close > Vegas upper EMA
Long: not na(PivotLow(low, MSS left lookback, MSS right lookback)) AND close > Vegas upper EMA
Short: not na(PivotHigh(high, MSS left lookback, MSS right lookback)) AND close < Vegas lower EMA
Long: not na(PivotLow(low, structure left lookback, structure right lookback)) AND close > Vegas upper EMA AND close[1] < Vegas upper EMA[1]
Short: not na(PivotHigh(high, structure left lookback, structure right lookback)) AND close < Vegas lower EMA AND close[1] > Vegas lower EMA[1]
Short: not na(PivotHigh(high, liquidity left lookback, liquidity right lookback))
Long: low > high[gap lookback]
Short: high < low[gap lookback]
Long: Confluence score >= extreme score threshold AND bullish Vegas structure AND Delta bullish divergence AND Volume surge AND MTF bullish Vegas bias
Short: Confluence score >= extreme score threshold AND bearish Vegas structure AND Delta bearish divergence AND Volume surge AND MTF bearish Vegas bias