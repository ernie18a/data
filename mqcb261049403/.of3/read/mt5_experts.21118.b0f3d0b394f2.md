Calculation: Candle midpoint = (high + low) / 2 of each T1 bar
Long: open > Candle midpoint AND close > Candle midpoint on the last completed T1 bar
Short: open < Candle midpoint AND close < Candle midpoint on the last completed T1 bar
Exit: long, open > close AND (open <= Candle midpoint OR close <= Candle midpoint) AND (open >= Candle midpoint OR close >= Candle midpoint) on the last completed T1 bar
Exit: short, open <= close AND (open <= Candle midpoint OR close <= Candle midpoint) AND (open >= Candle midpoint OR close >= Candle midpoint) on the last completed T1 bar
Exit: long, current datetime - position entry datetime > holding-duration parameter (minutes)
Exit: short, current datetime - position entry datetime > holding-duration parameter (minutes)