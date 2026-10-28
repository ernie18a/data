Long: close > open AND close > 13-period EMA AND previous close <= previous 13-period EMA AND volume > 20-period SMA of volume × volume multiplier AND close > VWAP
Short: close < open AND close < 13-period EMA AND previous close >= previous 13-period EMA AND volume > 20-period SMA of volume × volume multiplier AND close < VWAP
Exit: Long, after high reaches entry price + trailing activation distance, low <= highest high since activation - trailing offset
Exit: Short, after low reaches entry price - trailing activation distance, high >= lowest low since activation + trailing offset