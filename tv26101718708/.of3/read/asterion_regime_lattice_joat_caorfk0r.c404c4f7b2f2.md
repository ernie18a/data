Calculation: TrendBias(X) = 1 if close > EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND LinRegSlope(close, trend lookback) > 0; -1 if close < EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback) AND LinRegSlope(close, trend lookback) < 0; otherwise 0; all series on bars X
Calculation: MomentumBias = 1 if ROC(close, momentum lookback) > 0 AND RSI(close, RSI lookback) > upper RSI level AND KER(close, efficiency lookback) > efficiency threshold; -1 if ROC(close, momentum lookback) < 0 AND RSI(close, RSI lookback) < lower RSI level AND KER(close, efficiency lookback) > efficiency threshold; otherwise 0
Calculation: StructureBias = 1 if StochK(close, high, low, structure lookback) > upper structure level; -1 if StochK(close, high, low, structure lookback) < lower structure level; otherwise 0
Calculation: VolumeBias = 1 if (volume - SMA(volume, volume lookback)) / STDEV(volume, volume lookback) > volume z-score threshold AND LinRegSlope(OBV, volume lookback) > 0; -1 if (volume - SMA(volume, volume lookback)) / STDEV(volume, volume lookback) < -volume z-score threshold AND LinRegSlope(OBV, volume lookback) < 0; otherwise 0
Calculation: VolatilityRatio = (ATR(volatility lookback) / SMA(ATR(volatility lookback), volatility lookback) + GarmanKlass(volatility lookback) / SMA(GarmanKlass(volatility lookback), volatility lookback)) / 2
Calculation: VolatilityTerm = Polarity * expansion term magnitude if VolatilityRatio > upper volatility bound; -Polarity * contraction term magnitude if VolatilityRatio < lower volatility bound; otherwise 0
Calculation: Polarity = 1 if (TrendBias(chart) + MomentumBias + StructureBias + VolumeBias + HTFMean) >= 0; otherwise -1
Calculation: TFBiasSum(X) = TrendBias(X) + sign(ROC(close, momentum lookback)) + (1 if ATR(volatility lookback) / SMA(ATR(volatility lookback), volatility lookback) > upper volatility bound; -1 if ATR(volatility lookback) / SMA(ATR(volatility lookback), volatility lookback) < lower volatility bound; otherwise 0) + (1 if +DI(ADX lookback) > -DI(ADX lookback); -1 if +DI(ADX lookback) < -DI(ADX lookback); otherwise 0) + (1 if ADX(ADX lookback) > strong ADX level; -1 if ADX(ADX lookback) < weak ADX level; otherwise 0); all series on bars X
Calculation: HTFMean = (TFBiasSum(T1, last completed bar) + TFBiasSum(T2, last completed bar)) / 10
Calculation: Score = clamp(100 * (trend weight * TrendBias(chart) + momentum weight * MomentumBias + structure weight * StructureBias + volume weight * VolumeBias + volatility weight * VolatilityTerm + HTF weight * HTFMean), -100, 100)
Long: Score >= strong bull threshold
Long: Score >= soft bull threshold
Short: Score <= strong bear threshold
Short: Score <= soft bear threshold
Long: bar is closed AND Score crosses above strong bull threshold
Short: bar is closed AND Score crosses below strong bear threshold
Long: bar is closed AND Score crosses above soft bull threshold
Short: bar is closed AND Score crosses below soft bear threshold