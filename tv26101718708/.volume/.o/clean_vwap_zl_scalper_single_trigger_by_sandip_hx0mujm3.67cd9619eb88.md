Calculation: Zero-lag EMA = EMA(close + (close − close[lag]), length), where lag = floor((length − 1) / 2)
Calculation: Session VWAP = cumulative(volume × hlc3) / cumulative(volume), with hlc3 = (high + low + close) / 3
Calculation: Lower VWAP band = session VWAP − standard deviation(hlc3, lookback) × band multiplier
Calculation: Upper VWAP band = session VWAP + standard deviation(hlc3, lookback) × band multiplier
Long: bar is confirmed AND close > zero-lag EMA AND close > session VWAP AND (low <= session VWAP OR low <= lower VWAP band OR low <= zero-lag EMA) AND close > open AND close >= previous bar's open AND most recent signal is not long
Short: bar is confirmed AND close < zero-lag EMA AND close < session VWAP AND (high >= session VWAP OR high >= upper VWAP band OR high >= zero-lag EMA) AND close < open AND close <= previous bar's open AND most recent signal is not short
Exit: Long, low <= entry price − ATR at entry × stop multiple OR high >= entry price + ATR at entry × stop multiple × reward-to-risk multiple
Exit: Short, high >= entry price + ATR at entry × stop multiple OR low <= entry price − ATR at entry × stop multiple × reward-to-risk multiple