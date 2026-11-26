Long: close < open AND volume > volume[1] AND VWAP(hlc3) > VWAP(hlc3)[1] AND Choppiness Index(lookback parameter) < trend-factor parameter AND bar is within session parameter
Short: close > open AND volume > volume[1] AND VWAP(hlc3) < VWAP(hlc3)[1] AND Choppiness Index(lookback parameter) < trend-factor parameter AND bar is within session parameter
Exit: long, bar is outside session parameter
Exit: short, bar is outside session parameter