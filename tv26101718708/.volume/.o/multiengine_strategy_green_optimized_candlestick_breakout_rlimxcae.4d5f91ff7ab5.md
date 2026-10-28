Calculation: Breakout ceiling = highest high over the configured lookback, excluding the current bar
Calculation: Long stop = lowest low over the configured short lookback ending at the entry signal bar
Calculation: Long target = entry price + configured reward/risk multiple × (entry price − long stop)
Long: datetime is within the configured backtest window AND close > VWAP AND close > longer-lookback EMA AND ((low <= shorter-lookback EMA × (1 + configured buffer) AND close > open AND close > prior close) OR (close crosses above breakout ceiling AND volume > shorter-lookback SMA of volume × configured multiplier))
Exit: long, close < longer-lookback EMA OR low <= long stop OR high >= long target