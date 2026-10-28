Calculation: HP VWAP = session VWAP of Hodrick–Prescott-filtered OHLC4, volume-weighted and reset at each new bar of the user-selected timeframe; use the current timeframe bar as it forms
Calculation: Long stop price = entry-bar low if it is below the prior bar’s low, otherwise prior-bar low, minus ATR times a stop multiplier
Calculation: Long target price = entry price + (entry price − long stop price) × risk:reward parameter
Long: HP VWAP > OHLC4 AND prior-bar HP VWAP <= prior-bar OHLC4 AND position is flat AND bar is confirmed AND bar time is within the configured date range
Short: HP VWAP < OHLC4 AND prior-bar HP VWAP >= prior-bar OHLC4 AND position is flat AND bar is confirmed AND bar time is within the configured date range
Exit: long, low <= long stop price OR high >= long target price