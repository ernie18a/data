Calculation: Smoothed open = simple moving average of open on the selected Heikin-Ashi calculation timeframe; use the bar still forming.
Calculation: Smoothed close = simple moving average of close on the selected Heikin-Ashi calculation timeframe; use the bar still forming.
Long: Buy Only mode AND datetime within the configured backtest date range AND smoothed close > smoothed open AND position side is flat or short
Short: Sell Only mode AND datetime within the configured backtest date range AND smoothed close < smoothed open AND position side is flat or long
Exit: long, datetime within the configured backtest date range AND smoothed close < smoothed open OR long AND low <= entry price × (1 − configured stop-loss percentage) OR long AND high >= entry price × (1 + configured take-profit percentage)
Exit: short, datetime within the configured backtest date range AND smoothed close > smoothed open