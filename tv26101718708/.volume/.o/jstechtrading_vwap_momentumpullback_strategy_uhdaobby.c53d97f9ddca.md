Calculation: SMA = simple moving average of close over a configurable lookback
Calculation: VWAP = session cumulative volume-weighted average of typical price (high + low + close) / 3
Long: RSI was at or below the oversold threshold within the current or previous 10 bars AND current SMA > current VWAP AND previous SMA <= previous VWAP AND datetime is within the configured backtest date range
Short: RSI was at or above the overbought threshold within the current or previous 10 bars AND current SMA < current VWAP AND previous SMA >= previous VWAP AND datetime is within the configured backtest date range
Exit: long, low <= entry price × (1 − configured stop-loss percentage) OR high >= entry price × (1 + configured take-profit percentage)
Exit: short, high >= entry price × (1 + configured stop-loss percentage) OR low <= entry price × (1 − configured take-profit percentage)