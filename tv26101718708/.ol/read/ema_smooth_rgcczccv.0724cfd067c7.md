Calculation: Smooth MA = selected moving average of EMA(close), using the selected smoothing type and lookback
Long: EMA crosses above Smooth MA AND (position is flat OR a long entry is pending and the number of lower-timeframe bars since the short exit is at least the reversal-delay parameter)
Short: EMA crosses below Smooth MA AND (position is flat OR a short entry is pending and the number of lower-timeframe bars since the long exit is at least the reversal-delay parameter)
Exit: short, EMA crosses above Smooth MA
Exit: long, EMA crosses below Smooth MA