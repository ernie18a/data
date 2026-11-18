Calculation: ShortEMA = EMA(close, shorter EMA length)
Calculation: LongEMA = EMA(close, longer EMA length)
Calculation: RSI = RSI(close, RSI length)
Calculation: VolumeSpike = volume > SMA(volume, volume average length) * volume multiplier
Calculation: CumDelta = cumulative sum of (volume if close > open, -volume if close < open, 0 otherwise)
Calculation: CumDeltaAvg = SMA(CumDelta, CumDelta average length)
Calculation: POC = LOWEST(low, POC lookback) + (HIGHEST(high, POC lookback) - LOWEST(low, POC lookback)) / POC bins * index of first maximum-volume bin among POC bins
Long: (ABS(close - POC) / close * 100 <= POC max distance) AND (POC >= POC[POC lag] OR close > POC) AND (close > ShortEMA AND ShortEMA > LongEMA) AND (close > high[1] OR close crosses above ShortEMA) AND (CumDelta > CumDeltaAvg) AND ((RSI < RSI entry max AND LOWEST(RSI, RSI low lookback) < RSI low threshold AND RSI > RSI[1] AND RSI > SMA(RSI, RSI smoothing length)) OR (VolumeSpike AND close > open AND open - low >= (close - open) * smart buy wick ratio) OR (low < LOWEST(low[1], price low lookback) AND CumDelta > LOWEST(CumDelta[1], CumDelta low lookback) AND RSI < RSI divergence threshold)) AND (no previous Long OR bars since previous Long > cooldown)
Short: ((VolumeSpike AND close < open AND close < low + (high - low) * smart sell close ratio) OR (RSI > RSI overbought threshold AND CumDelta < CumDeltaAvg) OR (close < ShortEMA AND ShortEMA < LongEMA AND CumDelta < CumDeltaAvg)) AND (no previous Short OR bars since previous Short > cooldown)