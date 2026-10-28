Calculation: Session VWAP = cumulative close × volume divided by cumulative volume since the current session began
Long: close > session VWAP AND fast EMA > slow EMA AND volume > its moving average AND ((low <= fast EMA AND close > fast EMA) OR (low <= session VWAP AND close > session VWAP)) AND close > open AND close > previous bar high AND RSI > dip threshold
Short: close > session VWAP AND fast EMA > slow EMA AND (close > fast EMA by the extension threshold OR RSI > overbought threshold) AND close < open
Exit: long, close < session VWAP OR fast EMA < slow EMA