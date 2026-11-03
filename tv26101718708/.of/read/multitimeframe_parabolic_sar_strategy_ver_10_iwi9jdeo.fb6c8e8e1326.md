Calculation: Higher-timeframe SAR = Parabolic SAR calculated on the higher timeframe using the final value of the higher-timeframe bar, mapped to all chart bars within it on historical data; use the still-forming higher-timeframe bar in real time. Use the same SAR parameters on all timeframes.
Calculation: Lower-timeframe SAR = Parabolic SAR calculated on the lower timeframe; on historical data use the first lower-timeframe bar within each chart bar, and in real time use the latest available lower-timeframe bar.
Long: Close > current-timeframe SAR OR close > higher-timeframe SAR.
Short: Close <= current-timeframe SAR OR close <= higher-timeframe SAR.
Long: Close > the independently selected long-entry SAR source (current, higher, or both) AND, if the lower-timeframe filter is enabled, close > lower-timeframe SAR.
Short: Close < the independently selected short-entry SAR source (current, higher, or both) AND, if the lower-timeframe filter is enabled, close < lower-timeframe SAR.
Exit: long, close < the selected short-entry SAR source AND, if the lower-timeframe filter is enabled, close < lower-timeframe SAR.
Exit: short, close > the selected long-entry SAR source AND, if the lower-timeframe filter is enabled, close > lower-timeframe SAR.
Exit: long, both entry conditions are false AND stop loss is enabled AND close <= entry price × (1 − stop-loss fraction).
Exit: short, both entry conditions are false AND stop loss is enabled AND close >= entry price × (1 + stop-loss fraction).
Exit: long, both entry conditions are false AND take profit is enabled AND close >= entry price × (1 + take-profit fraction).
Exit: short, both entry conditions are false AND take profit is enabled AND close <= entry price × (1 − take-profit fraction).