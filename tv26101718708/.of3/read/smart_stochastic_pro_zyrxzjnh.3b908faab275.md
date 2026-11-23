Calculation: Bar range(X) = max(high - low, tick size), computed on X bars and read at the last completed X bar
Calculation: Volume ratio(X) = IF(SMA(volume, volume lookback) > 0, volume / SMA(volume, volume lookback), 1)
Calculation: Net pressure(X) = EMA(((close - low) / Bar range(X)) * Volume ratio(X), pressure lookback) - EMA(((high - close) / Bar range(X)) * Volume ratio(X), pressure lookback)
Calculation: %K(X) = EMA(EMA(Stochastic(close, high, low, K lookback), K smoothing 1), K smoothing 2)
Calculation: %D(X) = SMA(%K(X), D lookback)
Calculation: Bull arming(X) = exists bar s from arming window bars ago through current bar with %K(X) at s <= extreme oversold level and no Raw bull signal(X) on any bar from s through the previous bar
Calculation: Bear arming(X) = exists bar s from arming window bars ago through current bar with %K(X) at s >= extreme overbought level and no Raw bear signal(X) on any bar from s through the previous bar
Calculation: Bull strength(X) = count of true among (%K(X) crosses above %D(X); Bull arming(X) OR %K(X) <= oversold level; %K(X) > %K(X)[1] AND %K(X)[1] > %K(X)[2]; Net pressure(X) > 0)
Calculation: Bear strength(X) = count of true among (%K(X) crosses below %D(X); Bear arming(X) OR %K(X) >= overbought level; %K(X) < %K(X)[1] AND %K(X)[1] < %K(X)[2]; Net pressure(X) < 0)
Calculation: Raw bull signal(X) = %K(X) crosses above %D(X) AND (NOT require explosion first OR Bull arming(X)) AND Bull strength(X) >= minimum strength AND (NOT hide mid-range noise OR %K(X) <= mid-noise low OR %K(X) >= mid-noise high)
Calculation: Raw bear signal(X) = %K(X) crosses below %D(X) AND (NOT require explosion first OR Bear arming(X)) AND Bear strength(X) >= minimum strength AND (NOT hide mid-range noise OR %K(X) <= mid-noise low OR %K(X) >= mid-noise high)
Calculation: Bull bias(X) = %K(X) > midline AND %K(X) > %D(X) AND Net pressure(X) > 0
Calculation: Bear bias(X) = %K(X) < midline AND %K(X) < %D(X) AND Net pressure(X) < 0
Calculation: Bull signal = Raw bull signal(signal timeframe) AND NOT Raw bull signal(signal timeframe) one chart bar earlier AND (NOT MTF bias filter OR Bull bias(filter timeframe)) AND (NOT MTF slope filter OR (%K(filter timeframe) > %K(filter timeframe)[1] AND %D(filter timeframe) >= %D(filter timeframe)[1]))
Calculation: Bear signal = Raw bear signal(signal timeframe) AND NOT Raw bear signal(signal timeframe) one chart bar earlier AND (NOT MTF bias filter OR Bear bias(filter timeframe)) AND (NOT MTF slope filter OR (%K(filter timeframe) < %K(filter timeframe)[1] AND %D(filter timeframe) <= %D(filter timeframe)[1]))
Long: Bull signal
Short: Bear signal
Long: Net pressure(signal timeframe) crosses above zero
Short: Net pressure(signal timeframe) crosses below zero
Long: %K(signal timeframe) <= extreme oversold level
Short: %K(signal timeframe) >= extreme overbought level
Long: Bull arming(signal timeframe) AND NOT Bull signal AND %K(signal timeframe) < oversold level
Short: Bear arming(signal timeframe) AND NOT Bear signal AND %K(signal timeframe) > overbought level
Long: show pressure AND Net pressure(signal timeframe) > pressure background threshold
Short: show pressure AND Net pressure(signal timeframe) < -pressure background threshold
Long: candle coloring AND bias candle logic AND Bull bias(candle timeframe)
Short: candle coloring AND bias candle logic AND Bear bias(candle timeframe)
Long: candle coloring AND armed candle logic AND Bull arming(candle timeframe)
Short: candle coloring AND armed candle logic AND Bear arming(candle timeframe)
Long: candle coloring AND pressure candle logic AND Net pressure(candle timeframe) > candle pressure threshold
Short: candle coloring AND pressure candle logic AND Net pressure(candle timeframe) < -candle pressure threshold