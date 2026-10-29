Calculation: Long entry limit = session VWAP × (1 + configured long offset / 100), rounded to the nearest minimum tick
Calculation: Short entry limit = session VWAP × (1 + configured short offset / 100), rounded to the nearest minimum tick
Long: low ≤ Long entry limit AND session VWAP > 0 AND long entries enabled AND datetime is within the configured backtest date range AND position is flat or short
Short: high ≥ Short entry limit AND session VWAP > 0 AND short entries enabled AND datetime is within the configured backtest date range AND position is flat or long
Exit: Long, high ≥ session VWAP OR datetime is after the configured backtest end
Exit: Short, low ≤ session VWAP OR datetime is after the configured backtest end