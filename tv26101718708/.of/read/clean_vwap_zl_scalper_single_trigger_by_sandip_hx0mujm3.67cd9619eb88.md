Calculation: Zero-lag EMA = EMA of source + (source − source lagged by floor((length − 1) / 2)), using the same length for the lag and EMA
Long: close > zero-lag EMA AND close > VWAP AND (low <= VWAP OR low <= zero-lag EMA) AND close > open AND close >= prior bar open AND most recent signal is not long
Short: close < zero-lag EMA AND close < VWAP AND (high >= VWAP OR high >= zero-lag EMA) AND close < open AND close <= prior bar open AND most recent signal is not short
Exit: long, short-entry conditions are met OR low <= long stop OR high >= long target
Exit: short, long-entry conditions are met OR high >= short stop OR low <= short target
Calculation: Long stop = entry price − ATR at entry × stop multiple
Calculation: Long target = entry price + (entry price − long stop) × reward/risk multiple
Calculation: Short stop = entry price + ATR at entry × stop multiple
Calculation: Short target = entry price − (short stop − entry price) × reward/risk multiple