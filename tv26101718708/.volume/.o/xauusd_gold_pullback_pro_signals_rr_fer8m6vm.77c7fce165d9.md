Calculation: Candle body percentage = 100 × |close − open| ÷ (high − low), or 0 when high = low
Long: low <= fast EMA AND close > fast EMA AND fast EMA > slow EMA AND close > VWAP AND ADX > minimum ADX AND +DI > −DI AND close > open AND candle body percentage > 35 AND (no prior exit OR bars since last exit > cooldown) AND position side is not long AND current bar is completed
Short: high >= fast EMA AND close < fast EMA AND fast EMA < slow EMA AND close < VWAP AND ADX > minimum ADX AND −DI > +DI AND close < open AND candle body percentage > 35 AND (no prior exit OR bars since last exit > cooldown) AND position side is not short AND current bar is completed
Exit: long, close < fast EMA OR close < VWAP on a completed bar
Exit: short, close > fast EMA OR close > VWAP on a completed bar