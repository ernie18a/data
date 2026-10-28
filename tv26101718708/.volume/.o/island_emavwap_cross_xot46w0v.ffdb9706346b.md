Calculation: EMA = exponential moving average of close
Calculation: VWAP = session volume-weighted average of hlc3
Calculation: Candle body = abs(close - open)
Calculation: Close position = (close - low) / (high - low), or 0.5 when high equals low
Long: Current EMA > current VWAP AND previous-bar EMA <= previous-bar VWAP AND candle body >= ATR × minimum-body parameter AND close position >= minimum bullish close-position parameter
Short: Current EMA < current VWAP AND previous-bar EMA >= previous-bar VWAP AND candle body >= ATR × minimum-body parameter AND close position <= maximum bearish close-position parameter