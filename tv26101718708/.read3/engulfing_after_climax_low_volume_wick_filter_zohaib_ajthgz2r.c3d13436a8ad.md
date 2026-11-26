Calculation: body size = abs(close - open)
Calculation: candle range = high - low
Calculation: body percentage = if candle range != 0 then body size / candle range else 0
Calculation: upper wick size = high - max(open, close)
Calculation: lower wick size = min(open, close) - low
Calculation: selling climax = close < open AND volume > SMA(volume, avgVolLength) * climaxVolMultiplier AND candle range > SMA(candle range, avgVolLength) * wideSpreadMultiplier
Calculation: buying climax = close > open AND volume > SMA(volume, avgVolLength) * climaxVolMultiplier AND candle range > SMA(candle range, avgVolLength) * wideSpreadMultiplier
Long: a selling climax occurred no more than climaxLookback bars ago AND close > open AND close[1] < open[1] AND close > open[1] AND open <= close[1] AND body size >= body size[1] * bodyMultiplier AND volume < SMA(volume, avgVolLength) * lowVolPercent AND body percentage >= minBodyPercent AND upper wick size <= lower wick size
Short: a buying climax occurred no more than climaxLookback bars ago AND close < open AND close[1] > open[1] AND open >= close[1] AND close < open[1] AND body size >= body size[1] * bodyMultiplier AND volume < SMA(volume, avgVolLength) * lowVolPercent AND body percentage >= minBodyPercent AND lower wick size <= upper wick size