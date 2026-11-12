Calculation: FastEMA, MidEMA, SlowEMA = EMAs of close with lookbacks fast < mid < slow
Calculation: VWAP = cumulative sum(close*volume) / cumulative sum(volume), reset each session
Calculation: AvgVol = simple moving average of volume over a lookback
Calculation: HighVol = volume > AvgVol * M, where M > 1
Calculation: RSI = RSI of close
Long: chart timeframe is intraday AND FastEMA > MidEMA > SlowEMA AND close > VWAP AND ((HighVol AND close > open AND RSI > a bullish threshold set above the RSI midline) OR (low <= FastEMA AND close > FastEMA AND volume > AvgVol AND RSI > RSI midline))
Long: chart timeframe is not intraday (swing) AND FastEMA > MidEMA > SlowEMA AND ((close > FastEMA AND HighVol AND close > open AND RSI > RSI midline) OR (low <= FastEMA AND close > FastEMA AND volume > AvgVol AND RSI > RSI midline))
Long: chart timeframe is intraday AND close > highest high of the previous N bars (excluding the current bar) AND HighVol AND close > VWAP
Short: chart timeframe is intraday AND FastEMA < MidEMA < SlowEMA AND close < VWAP AND ((HighVol AND close < open AND RSI < a bearish threshold set below the RSI midline) OR (high >= FastEMA AND close < FastEMA AND volume > AvgVol AND RSI < RSI midline))
Short: chart timeframe is not intraday (swing) AND FastEMA < MidEMA < SlowEMA AND ((close < FastEMA AND HighVol AND close < open AND RSI < RSI midline) OR (high >= FastEMA AND close < FastEMA AND volume > AvgVol AND RSI < RSI midline))
Short: chart timeframe is intraday AND close < lowest low of the previous N bars (excluding the current bar) AND HighVol AND close < VWAP