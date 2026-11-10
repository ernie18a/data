Calculation: Body = max(abs(close - open), epsilon), where epsilon is used only when open equals close.
Calculation: Range = max(high - low, epsilon), where epsilon is used only when high equals low.
Calculation: Lower wick = min(open, close) - low.
Calculation: Upper wick = high - max(open, close).
Calculation: Institutional bullish condition = ATR / close * 100 >= minimum volatility AND volume > SMA(volume) * institutional volume multiplier AND close > fast institutional EMA(close) AND fast institutional EMA(close) > slow institutional EMA(close) AND ((lower wick > body * wick multiplier AND low < previous low AND close > low + 0.55 * (high - low)) OR (volume = highest volume over the volume lookback AND body < range * 0.55 AND close > open AND close > fast institutional EMA(close))) AND ((close > open AND close > previous high) OR close > high - 0.20 * (high - low)).
Calculation: Institutional bearish condition = ATR / close * 100 >= minimum volatility AND volume > SMA(volume) * institutional volume multiplier AND close < fast institutional EMA(close) AND fast institutional EMA(close) < slow institutional EMA(close) AND ((upper wick > body * wick multiplier AND high > previous high AND close < high - 0.55 * (high - low)) OR (volume = highest volume over the volume lookback AND body < range * 0.55 AND close < open AND close < fast institutional EMA(close))) AND ((close < open AND close < previous low) OR close < low + 0.20 * (high - low)).
Calculation: Scalping bullish condition = ATR / close * 100 >= minimum volatility AND ADX >= minimum ADX AND fast scalping EMA(close) > slow scalping EMA(close) AND low <= fast scalping EMA(close) AND close > fast scalping EMA(close) AND RSI(close) > midpoint AND volume > SMA(volume) * scalping volume multiplier.
Calculation: Scalping bearish condition = ATR / close * 100 >= minimum volatility AND ADX >= minimum ADX AND fast scalping EMA(close) < slow scalping EMA(close) AND high >= fast scalping EMA(close) AND close < fast scalping EMA(close) AND RSI(close) < midpoint AND volume > SMA(volume) * scalping volume multiplier.
Calculation: Cooldown passes = bars since the most recent cooldown-passing institutional or scalping bullish or bearish condition > cooldown length OR no such condition has occurred. All conditions on the same bar use the previous cooldown state.
Calculation: Bullish accumulation = volume > SMA(volume) * accumulation volume multiplier AND close > fast institutional EMA(close) AND fast institutional EMA(close) > slow institutional EMA(close).
Calculation: Bearish distribution = volume > SMA(volume) * accumulation volume multiplier AND close < fast institutional EMA(close) AND fast institutional EMA(close) < slow institutional EMA(close).
Calculation: MTF score = round(0.6 * EMA score + 0.4 * RSI(close)), where EMA score is 60 if the fast MTF EMA(close) > the slow MTF EMA(close), 40 if it is less, and 50 if they are equal. Evaluate on each configured MTF timeframe: for a higher timeframe use the last completed bar on historical data and the forming bar in real time; for a lower timeframe use its last available intrabar within the chart bar.
Long: (institutional bullish condition OR scalping bullish condition) AND cooldown passes.
Short: (institutional bearish condition OR scalping bearish condition) AND cooldown passes.
Exit: long, (institutional bearish condition OR scalping bearish condition) AND cooldown passes.
Long: bullish accumulation.
Short: bearish distribution.
Long: bullish accumulation = false AND bearish distribution = false AND lower wick > body * fixed trap multiplier AND volume = highest volume over the volume lookback AND close > open.
Short: bullish accumulation = false AND bearish distribution = false AND upper wick > body * fixed trap multiplier AND volume = highest volume over the volume lookback AND close < open.
Long: MTF score >= MTF bullish threshold.
Short: MTF score <= 100 - MTF bullish threshold AND MTF score < MTF bullish threshold.