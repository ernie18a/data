Calculation: Intraday Intensity Index = sum over its lookback of ((2 × close − high − low) × volume) ÷ (high − low), using 1 as the denominator when high = low
Long: previous close < previous lower Bollinger Band AND close > lower Bollinger Band AND (Intraday Intensity Index > 0 when its filter is enabled)
Short: previous close > previous upper Bollinger Band AND close < upper Bollinger Band AND (Intraday Intensity Index < 0 when its filter is enabled)
Exit: long, close > Bollinger Band middle line OR (early exit enabled AND close > entry price) OR bars since long entry signal > time-stop length
Exit: short, close < Bollinger Band middle line OR (early exit enabled AND close < entry price) OR bars since short entry signal > time-stop length