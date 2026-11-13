Calculation: BigUptrend = EMA(close) of 6 increasing periods p1<p2<p3<p4<p5<p6 satisfy EMA(p1)>EMA(p2)>EMA(p3)>EMA(p4) AND EMA(p4)>=EMA(p5)>=EMA(p6)
Calculation: MACD = standard MACD line (close, fast EMA, slow EMA) and its signal line (EMA of MACD line); MACD_HTF and Signal_HTF are the same MACD and signal computed on a timeframe higher than the chart timeframe, using the higher-timeframe bar still forming at the current chart bar
Calculation: RSIDivergence = abs((RSI[n] - RSI) / RSI[n]) > divergence threshold, where RSI[n] is the RSI n bars ago and n equals the slow SMA length
Calculation: VolumeSpike = volume > spike factor (>1) * SMA(volume, n), with n equal to the slow SMA length
Calculation: FastMA/SlowMA = SMA(close) with fast length shorter than slow length (fast = half of slow)
Long: RSI < oversold level AND RSIDivergence AND VolumeSpike AND close < FastMA AND close < SlowMA
Short: RSI > overbought level (higher than the oversold level) AND RSIDivergence AND VolumeSpike AND close > FastMA AND close > SlowMA
Short: BigUptrend AND MACD_HTF < Signal_HTF AND MACD line crosses below its signal line on the chart timeframe (chart timeframe lower than the higher timeframe)
Exit: short, close < EMA(close, longest period p6 of BigUptrend) on the chart timeframe AND MACD line crosses above its signal line on the chart timeframe