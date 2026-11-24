Calculation: Volume surge = volume > SMA(volume, volume lookback) * surge multiplier
Calculation: Momentum Index = EMA((Laguerre RSI(close, gamma) - Laguerre neutral level) * momentum weight A + Fisher Transform(hl2, Fisher lookback) * momentum weight B + TSI(close, TSI short lookback, TSI long lookback) * momentum weight C + (MFI(hlc3, momentum MFI lookback) - MFI neutral level) * momentum weight D + (volume available and positive ? SMA(sign(close - close[1]) * volume, momentum lookback) / max(SMA(volume, volume lookback), denominator floor) * momentum weight E + change(OBV, change lookback) / max(StDev(change(OBV), normalization lookback), denominator floor) * momentum weight F + change(A/D line, change lookback) / max(StDev(change(A/D line), normalization lookback), denominator floor) * momentum weight G + CMF(CMF lookback) * momentum weight H : 0), momentum smoothing)
Calculation: Trend Score = HMA direction unit when HMA(close, HMA lookback) > HMA(close, HMA lookback)[slope lag], otherwise negative HMA direction unit; plus SuperTrend direction unit when SuperTrend direction < 0, otherwise negative SuperTrend direction unit; plus EMA direction unit when EMA(close, fast lookback) > EMA(close, middle lookback) > EMA(close, slow lookback), negative EMA direction unit when the reverse ordering holds, otherwise zero; plus SMA direction unit when close > SMA(close, long lookback), otherwise negative SMA direction unit, plus SMA direction unit when close > SMA(close, longer lookback), otherwise negative SMA direction unit
Calculation: Trend State = strong bullish when Trend Score >= strong trend score threshold and ADX(DMI lookback, smoothing) > ADX strength threshold; weak bullish when Trend Score >= weak trend score threshold; strong bearish when Trend Score <= negative strong trend score threshold and ADX(DMI lookback, smoothing) > ADX strength threshold; weak bearish when Trend Score <= negative weak trend score threshold; otherwise neutral
Calculation: Higher-timeframe Trend State = Trend State calculated on T1 bars using the trend parameters above and the last completed T1 bar
Calculation: Countertrend Long = Trend State < neutral and Momentum Index > Momentum Index[1] > Momentum Index[2] and close crosses above HMA(close, HMA lookback)
Calculation: Countertrend Short = Trend State > neutral and Momentum Index < Momentum Index[1] < Momentum Index[2] and close crosses below HMA(close, HMA lookback)
Calculation: Active Demand Zone = close is within any retained, unmitigated zone made at a confirmed pivot low using the zone pivot length on both sides, where pivot-candle volume exceeds its volume SMA or volume is unavailable; zone bottom is pivot low and top is min(max(pivot-candle open, pivot-candle close), pivot low + ATR(ATR lookback) on the detection bar); remove a zone when low, close, or close below its midpoint passes its bottom according to the selected zone break method, and retain at most the zone capacity newest zones
Calculation: Active Supply Zone = close is within any retained, unmitigated zone made at a confirmed pivot high using the zone pivot length on both sides, where pivot-candle volume exceeds its volume SMA or volume is unavailable; zone top is pivot high and bottom is max(min(pivot-candle open, pivot-candle close), pivot high - ATR(ATR lookback) on the detection bar); remove a zone when high, close, or close above its midpoint passes its top according to the selected zone break method, and retain at most the zone capacity newest zones
Calculation: Active Fair Value Gaps = retain the newest gap capacity gaps; a bullish gap forms when low > high[gap lookback] and the preceding bar closes above its open, with bounds high[gap lookback] to low; a bearish gap forms when high < low[gap lookback] and the preceding bar closes below its open, with bounds high to low[gap lookback]; remove a gap when low is below its bottom and high is above its top
Calculation: Bullish Structure = Active Demand Zone or close above the top of the newest active Fair Value Gap
Calculation: Bearish Structure = Active Supply Zone or close below the bottom of the newest active Fair Value Gap
Calculation: Wave Momentum = ALMA(change(close, wave momentum lookback) / max(ATR(ATR lookback), minimum tick) * wave normalization scale, wave momentum lookback, ALMA offset, ALMA sigma)
Calculation: Wave All Bullish = Wave Momentum exceeds each of the four averages of adjacent EMAs of Wave Momentum using five ordered EMA lookbacks
Calculation: Wave All Bearish = Wave Momentum is below each of the four averages of adjacent EMAs of Wave Momentum using five ordered EMA lookbacks
Calculation: Wave Bullish Vote = Wave All Bullish or Wave Momentum > mean(four adjacent-EMA averages) + StDev(mean(four adjacent-EMA averages), wave deviation lookback) * wave deviation multiplier
Calculation: Wave Bearish Vote = Wave All Bearish or Wave Momentum < mean(four adjacent-EMA averages) - StDev(mean(four adjacent-EMA averages), wave deviation lookback) * wave deviation multiplier
Calculation: Bullish Liquidity Sweep = low < a tracked confirmed pivot-low level and close > that level; remove the level on first hit, and retain at most the liquidity level capacity newest levels
Calculation: Bearish Liquidity Sweep = high > a tracked confirmed pivot-high level and close < that level; remove the level on first hit, and retain at most the liquidity level capacity newest levels
Calculation: Regular Bullish Divergence = at a confirmed pivot low, price is below the previous confirmed pivot low and at least the required oscillator count of RSI, MACD line, TSI, and smoothed Stochastic are above their values at the previous pivot low; pivot spacing is within the minimum and maximum divergence lookbacks
Calculation: Regular Bearish Divergence = at a confirmed pivot high, price is above the previous confirmed pivot high and at least the required oscillator count of RSI, MACD line, TSI, and smoothed Stochastic are below their values at the previous pivot high; pivot spacing is within the minimum and maximum divergence lookbacks
Calculation: Hidden Bullish Divergence = at a confirmed pivot low, price is above the previous confirmed pivot low and at least the required oscillator count of RSI, MACD line, TSI, and smoothed Stochastic are below their values at the previous pivot low; pivot spacing is within the minimum and maximum divergence lookbacks
Calculation: Hidden Bearish Divergence = at a confirmed pivot high, price is below the previous confirmed pivot high and at least the required oscillator count of RSI, MACD line, TSI, and smoothed Stochastic are above their values at the previous pivot high; pivot spacing is within the minimum and maximum divergence lookbacks
Calculation: Bullish Divergence Active = a regular bullish divergence occurred within the divergence right-pivot length plus the active divergence extension
Calculation: Bearish Divergence Active = a regular bearish divergence occurred within the divergence right-pivot length plus the active divergence extension
Calculation: Squeeze = Bollinger upper band < Keltner upper band and Bollinger lower band > Keltner lower band, using SMA(close, Bollinger lookback) plus or minus StDev(close, Bollinger lookback) * Bollinger multiplier for Bollinger bands, and EMA(close, Keltner lookback) plus or minus ATR(Keltner lookback) * Keltner multiplier for Keltner bands
Calculation: Bullish Squeeze Breakout = Squeeze[1] and not Squeeze and close > EMA(close, Keltner lookback)
Calculation: Bearish Squeeze Breakout = Squeeze[1] and not Squeeze and close < EMA(close, Keltner lookback)
Calculation: Flow Index = EMA(CMF(CMF lookback) * flow weight A + (MFI(hlc3, flow MFI lookback) - flow MFI neutral level) * flow weight B + (OBV > EMA(OBV, OBV smoothing lookback) ? OBV direction weight : negative OBV direction weight) + (A/D line > EMA(A/D line, A/D smoothing lookback) ? A/D direction weight : negative A/D direction weight), flow smoothing)
Calculation: Flow Phase = strong accumulation when Flow Index > strong positive flow threshold; accumulation when Flow Index > positive flow threshold; strong distribution when Flow Index < negative strong flow threshold; distribution when Flow Index < negative flow threshold; otherwise neutral
Calculation: Buy Pressure = CMF(CMF lookback) > neutral and MFI(hlc3, flow MFI lookback) > flow MFI neutral level and OBV > EMA(OBV, OBV smoothing lookback) and Volume surge
Calculation: Sell Pressure = CMF(CMF lookback) < neutral and MFI(hlc3, flow MFI lookback) < flow MFI neutral level and OBV <= EMA(OBV, OBV smoothing lookback) and Volume surge
Calculation: Value Position = (close - lowest low over value lookback) / max(highest high over value lookback - lowest low over value lookback, minimum tick)
Calculation: Discount = Value Position < discount threshold
Calculation: Premium = Value Position > premium threshold
Calculation: Bull Vote Count = count of true conditions: Momentum Index > 0 and Momentum Index > Momentum Index[1]; Bullish Structure; Wave Bullish Vote; Bullish Liquidity Sweep; Trend State > neutral or Countertrend Long; Bullish Divergence Active; Bullish Squeeze Breakout; Flow Phase > neutral or Buy Pressure; Discount and Trend State >= neutral; Volume surge and close > open
Calculation: Bear Vote Count = count of true conditions: Momentum Index < 0 and Momentum Index < Momentum Index[1]; Bearish Structure; Wave Bearish Vote; Bearish Liquidity Sweep; Trend State < neutral or Countertrend Short; Bearish Divergence Active; Bearish Squeeze Breakout; Flow Phase < neutral or Sell Pressure; Premium and Trend State <= neutral; Volume surge and close < open
Calculation: Signal Score = max(Bull Vote Count, Bear Vote Count)
Calculation: Raw Long Signal = Bull Vote Count >= minimum confluence score and Bull Vote Count - Bear Vote Count >= minimum vote margin and close > HMA(close, HMA lookback)
Calculation: Raw Short Signal = Bear Vote Count >= minimum confluence score and Bear Vote Count - Bull Vote Count >= minimum vote margin and close < HMA(close, HMA lookback)
Calculation: Long Signal = Raw Long Signal and not Raw Long Signal[1] and bars since the last Long Signal or Short Signal > minimum signal gap
Calculation: Short Signal = Raw Short Signal and not Raw Short Signal[1] and bars since the last Long Signal or Short Signal > minimum signal gap
Calculation: Volatility Index = ATR(ATR lookback) / close * volatility weight A + 2 * StDev(close, Bollinger lookback) * Bollinger multiplier / close * volatility weight B + StDev(log(close / close[1]), historical volatility lookback) * sqrt(annualization factor) * historical volatility weight
Calculation: Sentiment Index = inverse PercentRank(Volatility Index, volatility ranking lookback) * sentiment weight A + clamp(sentiment midpoint + Momentum Index, sentiment floor, sentiment ceiling) * sentiment weight B + clamp(sentiment midpoint + (close - SMA(close, longer lookback)) / max(ATR(ATR lookback), minimum tick) * distance scale, sentiment floor, sentiment ceiling) * sentiment weight C + (volume available and positive ? clamp(sentiment midpoint + (volume / max(SMA(volume, volume lookback), denominator floor) - volume ratio midpoint) * volume scale * (close > open ? candle direction : negative candle direction), sentiment floor, sentiment ceiling) : sentiment midpoint) * sentiment weight D + RSI(close, RSI lookback) * sentiment weight E
Calculation: Sentiment Market Bias = Trend Score + (Flow Phase > neutral ? positive flow adjustment : Flow Phase < neutral ? negative flow adjustment : 0)
Long: Long Signal
Short: Short Signal
Long: Long Signal and Signal Score is Strong or higher and Higher-timeframe Trend State > neutral and (Trend State is not neutral or not Squeeze or Bullish Squeeze Breakout)
Short: Short Signal and Signal Score is Strong or higher and Higher-timeframe Trend State < neutral and (Trend State is not neutral or not Squeeze or Bearish Squeeze Breakout)
Long: Countertrend Long
Short: Countertrend Short
Long: Trend State > neutral
Short: Trend State < neutral
Long: Trend State becomes strong bullish from a different state
Short: Trend State becomes strong bearish from a different state
Long: Bullish Squeeze Breakout
Short: Bearish Squeeze Breakout
Long: Regular Bullish Divergence
Short: Regular Bearish Divergence
Long: Hidden Bullish Divergence
Short: Hidden Bearish Divergence
Long: Flow Phase > neutral
Short: Flow Phase < neutral
Long: Flow Phase becomes strong accumulation from a different phase
Short: Flow Phase becomes strong distribution from a different phase
Long: Bullish Liquidity Sweep
Short: Bearish Liquidity Sweep
Long: confirmed pivot low with the zone volume filter, marking a demand zone
Short: confirmed pivot high with the zone volume filter, marking a supply zone
Long: Bullish Structure
Short: Bearish Structure
Long: Discount
Short: Premium
Long: Momentum Index > 0
Short: Momentum Index <= 0
Long: Laguerre RSI(close, gamma) < Laguerre lower threshold
Short: Laguerre RSI(close, gamma) > Laguerre upper threshold
Long: Fisher Transform(hl2, Fisher lookback) > neutral
Short: Fisher Transform(hl2, Fisher lookback) <= neutral
Long: CMF(CMF lookback) > neutral
Short: CMF(CMF lookback) <= neutral
Long: MFI(hlc3, flow MFI lookback) < oversold threshold
Short: MFI(hlc3, flow MFI lookback) > overbought threshold
Long: Wave All Bullish
Short: Wave All Bearish
Long: number of tracked buy-side pivot-high levels > number of tracked sell-side pivot-low levels
Short: number of tracked buy-side pivot-high levels < number of tracked sell-side pivot-low levels
Long: Bull Vote Count > Bear Vote Count
Short: Bull Vote Count < Bear Vote Count
Long: Sentiment Index > greed threshold
Short: Sentiment Index < fear threshold
Long: Sentiment Index crosses above extreme greed threshold
Short: Sentiment Index crosses below extreme fear threshold
Long: Sentiment Market Bias > bullish bias threshold
Short: Sentiment Market Bias < bearish bias threshold
Long: SuperTrend direction < 0
Short: SuperTrend direction >= 0
Long: Trend State > neutral or (Trend State is neutral and HMA(close, HMA lookback) > HMA(close, HMA lookback)[slope lag])
Short: Trend State < neutral or (Trend State is neutral and HMA(close, HMA lookback) <= HMA(close, HMA lookback)[slope lag])
Long: candle coloring mode is Flow Phase and Flow Phase > neutral, or candle coloring mode is Momentum and Momentum Index > 0
Short: candle coloring mode is Flow Phase and Flow Phase < neutral, or candle coloring mode is Momentum and Momentum Index <= 0
Long: Volume surge and close > open
Short: Volume surge and close <= open
Exit: long, Flow Phase < neutral
Exit: short, Flow Phase > neutral