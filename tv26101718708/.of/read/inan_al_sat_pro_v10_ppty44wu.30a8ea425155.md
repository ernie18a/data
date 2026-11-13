Calculation: EMA_fast, EMA_slow = exponential moving averages of close on the chart timeframe; EMA_slow has the longer lookback
Calculation: ATR = average true range on the chart timeframe
Calculation: LastSwingHigh = most recent confirmed pivot high (a high above the highs of an equal number of bars on both sides, known only after the right-side bars complete); LastSwingLow = most recent confirmed pivot low (mirror)
Calculation: SweepLow = current low < lowest low of the previous N bars (excluding the current bar); SweepHigh = current high > highest high of the previous N bars (excluding the current bar)
Calculation: HighVol = volume > multiplier (>1) * simple average volume over the recent N bars
Long: close > EMA_slow AND EMA_fast crosses above EMA_slow on this bar AND RSI > bullish threshold (above the neutral midpoint) AND SweepLow AND close > open AND HighVol AND close > LastSwingHigh
Short: close < EMA_slow AND EMA_fast crosses below EMA_slow on this bar AND RSI < bearish threshold (below the neutral midpoint) AND SweepHigh AND close < open AND HighVol AND close < LastSwingLow
Long: SweepLow AND close > open
Short: SweepHigh AND close < open
Long: previous bar close < previous bar open AND close > previous bar high
Short: previous bar close > previous bar open AND close < previous bar low
Exit: long, low <= entry price - m * ATR (ATR on the entry bar, m a fixed multiplier)
Exit: short, high >= entry price + m * ATR (ATR on the entry bar, same m)
Exit: long, high >= entry price + r * (m * ATR on the entry bar) (first target r = smaller risk-reward multiple; second, final target uses a larger multiple r2 > r)
Exit: short, low <= entry price - r * (m * ATR on the entry bar) (first target r = smaller risk-reward multiple; second, final target uses a larger multiple r2 > r)