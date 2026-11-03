Calculation: Bull trend = fast EMA(close) > medium EMA(close) > slow EMA(close) AND close > medium EMA(close); the fast EMA lookback is shorter than the medium, which is shorter than the slow
Calculation: Bear trend = fast EMA(close) < medium EMA(close) < slow EMA(close) AND close < medium EMA(close); use the same fast-to-slow lookback ordering as for bull trend
Calculation: Bull momentum = MACD histogram > 0 AND RSI > its neutral level AND positive directional index > negative directional index
Calculation: Bear momentum = MACD histogram < 0 AND RSI < its neutral level AND negative directional index > positive directional index
Calculation: Bull VWAP condition = close > VWAP(typical price) AND VWAP(typical price) > its prior value
Calculation: Bear VWAP condition = close < VWAP(typical price) AND VWAP(typical price) < its prior value
Calculation: Volume impulse = volume / simple moving average of volume
Calculation: Pressure oscillator = clamp(EMA(((close - open) / max(high - low, minimum price increment)) * volume) / EMA(abs(((close - open) / max(high - low, minimum price increment)) * volume) * 100, -100, 100); use one pressure lookback for both EMAs
Calculation: Bid pressure = pressure oscillator > its positive threshold AND volume impulse > its threshold
Calculation: Ask pressure = pressure oscillator < its negative threshold AND volume impulse > its threshold
Calculation: Bull absorption = low < prior low AND close > open AND pressure oscillator > its prior value AND volume impulse > its threshold
Calculation: Bear absorption = high > prior high AND close < open AND pressure oscillator < its prior value AND volume impulse > its threshold
Calculation: Auction center = simple moving average(typical price * volume) / simple moving average(volume), using the same lookback for both averages
Calculation: Auction upper and lower values = auction center plus or minus standard deviation(typical price) times a deviation parameter
Calculation: Auction discount = close < lower value AND close > low + (high - low) * a fraction parameter
Calculation: Auction premium = close > upper value AND close < high - (high - low) * the same fraction parameter
Calculation: Auction reclaim = close > lower value AND prior close <= prior lower value
Calculation: Auction rejection = close < upper value AND prior close >= prior upper value
Calculation: ATR = average true range
Calculation: Volatility expansion = percentile rank of ATR / close over a lookback > its threshold
Calculation: Regime = bull trend, bear trend, or neutral otherwise
Calculation: Continuation probability = rolling fraction of transitions that remain in the current regime, conditioned on the prior regime; use a configurable transition lookback and a neutral fallback when there are no observations
Calculation: Probability pass = continuation probability >= its threshold OR volatility expansion
Calculation: Confirmed higher-timeframe EMA = EMA(close) on a higher timeframe, from the last completed higher-timeframe bar
Calculation: Higher-timeframe long pass = higher-timeframe filter disabled OR close > confirmed higher-timeframe EMA
Calculation: Higher-timeframe short pass = higher-timeframe filter disabled OR close < confirmed higher-timeframe EMA
Calculation: Displacement = abs(close - open) > ATR times a parameter AND volume impulse > its threshold
Calculation: Bull structure = persistent bullish bias after a confirmed pivot-high break with displacement, OR a sweep below the latest confirmed pivot low followed by a close above it, OR low > high two bars earlier AND close > open
Calculation: Bear structure = persistent bearish bias after a confirmed pivot-low break with displacement, OR a sweep above the latest confirmed pivot high followed by a close below it, OR high < low two bars earlier AND close < open
Calculation: Long score = configurable positive points for each of bull trend, bull momentum, bull VWAP condition, bid pressure, bull absorption, bull structure, auction discount or auction reclaim, higher-timeframe long pass, and probability pass, plus a capped ADX contribution; clamp total to 0–100
Calculation: Short score = configurable positive points for each of bear trend, bear momentum, bear VWAP condition, ask pressure, bear absorption, bear structure, auction premium or auction rejection, higher-timeframe short pass, and probability pass, plus a capped ADX contribution; clamp total to 0–100
Calculation: Long stop = the lower of entry price minus ATR times a parameter and the latest confirmed pivot low; if no pivot low exists, use entry price minus ATR times the parameter
Calculation: Short stop = the higher of entry price plus ATR times a parameter and the latest confirmed pivot high; if no pivot high exists, use entry price plus ATR times the parameter
Calculation: Long risk = max(abs(entry price - long stop), ATR times a parameter); long targets = entry price + long risk times each of three increasing reward multiples
Calculation: Short risk = max(abs(entry price - short stop), ATR times a parameter); short targets = entry price - short risk times each of three increasing reward multiples
Long: confirmed bar AND flat position AND (session filter disabled OR within configured session) AND long score >= its threshold AND long score > short score + its margin AND higher-timeframe long pass AND NOT auction premium
Short: confirmed bar AND flat position AND (session filter disabled OR within configured session) AND short score >= its threshold AND short score > long score + its margin AND higher-timeframe short pass AND NOT auction discount
Exit: long, low <= long stop OR high >= any of the three long targets OR (regime-exit enabled AND bear regime) OR (pressure-exit enabled AND pressure oscillator below its negative threshold) OR short score > long score + its margin
Exit: short, high >= short stop OR low <= any of the three short targets OR (regime-exit enabled AND bull regime) OR (pressure-exit enabled AND pressure oscillator above its positive threshold) OR long score > short score + its margin