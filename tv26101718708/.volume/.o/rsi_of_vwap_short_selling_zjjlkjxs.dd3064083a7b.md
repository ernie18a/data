Calculation: VWAP RSI = RSI calculated from session VWAP values.
Calculation: Weekly VWAP RSI = RSI calculated from VWAP values on the still-forming weekly bar.
Calculation: VIX RSI = RSI calculated from VIX values on the current timeframe.
Short: (session VWAP < EMA of close AND (VWAP RSI crosses below the lower entry threshold OR Weekly VWAP RSI crosses below the upper exit threshold)) OR (VIX RSI crosses above its threshold AND (VWAP RSI crosses below the lower entry threshold OR Weekly VWAP RSI crosses below the upper exit threshold)).
Exit: short, VWAP RSI crosses above the upper exit threshold OR close > entry price × (1 + stop-loss percentage) OR (close < entry price AND VWAP RSI crosses above the lower entry threshold).