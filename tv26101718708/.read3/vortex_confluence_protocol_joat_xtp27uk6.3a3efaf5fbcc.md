Calculation: Structure break up = (close > last pivot high AND Structure direction[1] <= 0) OR (close > prior pivot high AND Structure direction[1] < 0), where last pivot high is the most recent confirmed pivot high of high with pivot strength bars on each side and prior pivot high is the pivot high before it
Calculation: Structure break down = (close < last pivot low AND Structure direction[1] >= 0) OR (close < prior pivot low AND Structure direction[1] > 0), where last pivot low and prior pivot low are defined as pivot highs are, on low
Calculation: Structure direction = -1 if Structure break down, else +1 if Structure break up, else Structure direction[1]
Calculation: Bullish FVG touch = for some k bars back where a bullish gap formed among the most recent FVG retention count FVG formations of either type (low[k] > high[k+2] AND close[k+1] > open[k+1] AND low[k] - high[k+2] >= FVG size multiplier * ATR(ATR length)[k]) AND low <= low[k] AND high >= high[k+2]
Calculation: Bearish FVG touch = for some k bars back where a bearish gap formed among the most recent FVG retention count FVG formations of either type (high[k] < low[k+2] AND close[k+1] < open[k+1] AND low[k+2] - high[k] >= FVG size multiplier * ATR(ATR length)[k]) AND low <= low[k+2] AND high >= high[k]
Calculation: Smoothed RSI = EMA(RSI(close, RSI length), RSI smoothing length)
Calculation: Momentum signal = +1 if Smoothed RSI > RSI midline AND change(Smoothed RSI, RSI change lookback) > 0 AND Smoothed RSI < RSI overbought; -1 if Smoothed RSI < RSI midline AND change(Smoothed RSI, RSI change lookback) < 0 AND Smoothed RSI > RSI oversold; else 0
Calculation: Volume delta = (volume if close > open, else volume * (close - low) / (high - low)) - (volume if close < open, else volume * (high - close) / (high - low))
Calculation: Cumulative delta = SUM(Volume delta, cumulative delta lookback)
Calculation: Volume ratio = volume / SMA(volume, volume MA length)
Calculation: Volume signal = +1 if Volume ratio >= volume threshold AND Volume delta > 0 AND Cumulative delta > 0; -1 if Volume ratio >= volume threshold AND Volume delta < 0 AND Cumulative delta < 0; else 0
Calculation: Volume anomaly = abs(volume - SMA(volume, volume MA length)) / STDEV(volume, volume stdev length) > volume anomaly threshold
Calculation: Institutional delta = Volume delta * Volume ratio
Calculation: Accumulating = change(close, smart money lookback) > 0 AND change(volume, smart money lookback) > 0 AND Institutional delta > 0
Calculation: Distributing = change(close, smart money lookback) < 0 AND change(volume, smart money lookback) > 0 AND Institutional delta < 0
Calculation: Smart money score = (+1 if Accumulating, -1 if Distributing, else 0) * abs(Institutional delta) / SMA(volume, volume MA length) * (anomaly score multiplier if Volume anomaly, else 1)
Calculation: Sweep strength = abs(Volume delta) / SMA(volume, volume MA length)
Calculation: HTF trend = +1 if close(T1, last completed bar) > EMA(close, MTF trend length, T1, last completed bar); -1 if close(T1, last completed bar) < EMA(close, MTF trend length, T1, last completed bar); else 0
Calculation: MTF signal = +1 if HTF trend > 0 AND RSI(close, RSI length, T1, last completed bar) > RSI midline; -1 if HTF trend < 0 AND RSI(close, RSI length, T1, last completed bar) < RSI midline; else 0
Calculation: Quantum coherence = abs((Structure direction + Momentum signal + Volume signal + MTF signal) / 4)
Calculation: Quantum superposition = (Quantum coherence + entanglement) / 2, where entanglement = (entanglement weight if HTF trend = Structure direction, else -entanglement weight) + (entanglement weight if MTF signal = Momentum signal, else -entanglement weight)
Calculation: In session = bar datetime within active session window in session time zone
Calculation: Confluence score = count of true among: (Structure break up OR Structure break down), (Bullish FVG touch AND Structure direction > 0), (Bearish FVG touch AND Structure direction < 0), (Momentum signal != 0), (Volume signal != 0), Volume anomaly, (MTF signal != 0), In session, (abs(Volume delta) / volume > absorption threshold), (Sweep strength > sweep threshold), (Quantum superposition > quantum threshold), (Quantum coherence > coherence threshold), (Smart money score > smart money threshold), (Accumulating OR Distributing), (sin(2*pi*(bar index mod harmonic period)/harmonic period) * Structure direction > harmonic threshold)
Calculation: Trend direction = +1 if +DI(ADX length) > -DI(ADX length), else -1
Calculation: Initial stop = if long, min(entry price - ATR(ATR length) * stop ATR multiplier, lowest(low, recent lookback) - ATR(ATR length) * swing buffer multiplier); if short, max(entry price + ATR(ATR length) * stop ATR multiplier, highest(high, recent lookback) + ATR(ATR length) * swing buffer multiplier); ATR, lowest and highest taken at the entry bar, with recent lookback a multiple of pivot strength
Calculation: Take-profit = if long, entry price + abs(entry price - Initial stop) * reward-to-risk ratio; if short, entry price - abs(entry price - Initial stop) * reward-to-risk ratio
Calculation: Trailing stop = if long, max(Initial stop, highest over bars from entry through the prior bar of (high - ATR(ATR length) * trail ATR multiplier)); if short, min(Initial stop, lowest over the same bars of (low + ATR(ATR length) * trail ATR multiplier))
Long: position side is flat AND Confluence score >= minimum confluence score AND Bullish FVG touch AND Structure break up AND Momentum signal >= 0 AND MTF signal >= 0 AND Volume signal >= 0 AND In session AND (ADX(ADX length) <= ADX trend threshold OR Trend direction > 0) AND Quantum superposition > 0 AND Smart money score >= 0
Short: position side is flat AND Confluence score >= minimum confluence score AND Bearish FVG touch AND Structure break down AND Momentum signal <= 0 AND MTF signal <= 0 AND Volume signal <= 0 AND In session AND (ADX(ADX length) <= ADX trend threshold OR Trend direction < 0) AND Quantum superposition < 0 AND Smart money score <= 0
Exit: long, low <= Trailing stop OR high >= Take-profit
Exit: short, high >= Trailing stop OR low <= Take-profit
Long: Structure break up
Long: Structure direction > 0
Long: Confluence score >= minimum confluence score AND Structure direction > 0
Long: Momentum signal > 0
Long: Momentum signal > 0 AND Momentum signal[1] <= 0
Long: Smoothed RSI < bullish divergence RSI level AND close > close[divergence lookback] AND Smoothed RSI > Smoothed RSI[divergence lookback]
Long: Volume signal > 0
Long: MTF signal > 0
Long: MTF signal > 0 AND MTF signal[1] <= 0
Long: ADX(ADX length) > ADX trend threshold AND Trend direction > 0
Long: Trend direction > 0 AND Trend direction[1] < 0
Long: Accumulating
Long: Accumulating AND NOT Accumulating[1]
Long: Smart money score > smart money high threshold
Long: Sweep strength > sweep threshold AND Sweep strength > sweep marker threshold
Short: Structure break down
Short: Structure direction < 0
Short: Confluence score >= minimum confluence score AND Structure direction < 0
Short: Momentum signal < 0
Short: Momentum signal < 0 AND Momentum signal[1] >= 0
Short: Smoothed RSI > bearish divergence RSI level AND close < close[divergence lookback] AND Smoothed RSI < Smoothed RSI[divergence lookback]
Short: Volume signal < 0
Short: MTF signal < 0
Short: MTF signal < 0 AND MTF signal[1] >= 0
Short: ADX(ADX length) > ADX trend threshold AND Trend direction < 0
Short: Trend direction < 0 AND Trend direction[1] > 0
Short: Distributing
Short: Distributing AND NOT Distributing[1]