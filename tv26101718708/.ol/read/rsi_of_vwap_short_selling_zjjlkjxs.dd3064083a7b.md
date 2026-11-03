Calculation: Weekly RSI of VWAP = RSI of VWAP calculated on higher-timeframe weekly bars, using the still-forming weekly bar
Calculation: Short stop-loss price = short entry price increased by the stop-loss percentage
Short: (Session VWAP is below EMA of close AND (RSI of session VWAP crosses below the lower level OR weekly RSI of VWAP crosses below the upper level)) OR (RSI of VIX crosses above its threshold AND (RSI of session VWAP crosses below the lower level OR weekly RSI of VWAP crosses below the upper level))
Exit: Short, close is below short entry price AND RSI of session VWAP crosses above the lower level
Exit: Short, RSI of session VWAP crosses above the upper level
Exit: Short, close is above short stop-loss price