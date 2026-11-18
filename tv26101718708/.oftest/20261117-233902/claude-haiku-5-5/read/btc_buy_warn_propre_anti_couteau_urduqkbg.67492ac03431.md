Calculation: EMA_fast = EMA(close, fastLen)
Calculation: EMA_slow = EMA(close, slowLen)
Calculation: RSI = RSI(close, rsiLen)
Calculation: CVD = running total of signed volume, where signed volume = volume if close > open, -volume if close < open, else 0
Calculation: CVD_MA = SMA(CVD, cvdLen)
Calculation: POC = lowest(low, profileLen) + step * index of the bin with greatest volume over the last profileLen bars, where step = (highest(high, profileLen) - lowest(low, profileLen)) / profileBins
Calculation: SmartVol = volume > SMA(volume, volLen) * volMult
Calculation: SmartBuy = SmartVol AND close > open AND (min(open, close) - low) >= abs(close - open) * wickRatio
Calculation: SmartSell = SmartVol AND close < open AND close < low + (high - low) * closeRatio
Long: abs(close - POC) / close * 100 <= pocMaxDist AND (POC >= POC[pocShift] OR close > POC) AND close > EMA_fast AND EMA_fast > EMA_slow AND (close > high[1] OR close crosses above EMA_fast) AND CVD > CVD_MA AND ((RSI < rsiEntry AND lowest(RSI, rsiLowLookback) < rsiLow AND RSI > RSI[1] AND RSI > SMA(RSI, rsiMALen)) OR SmartBuy OR (low < lowest(low[1], divLookback) AND CVD > lowest(CVD[1], divLookback) AND RSI < rsiMid)) AND (no prior Long signal OR bars since prior Long signal > cooldown)
Exit: long, (SmartSell OR (RSI > rsiOverbought AND CVD < CVD_MA) OR (close < EMA_fast AND EMA_fast < EMA_slow AND CVD < CVD_MA)) AND (no prior Exit signal OR bars since prior Exit signal > cooldown)