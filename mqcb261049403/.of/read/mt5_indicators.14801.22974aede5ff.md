Calculation: MACD line = shorter-period moving average of the selected OHLC-derived price minus longer-period moving average of the same price, using the same averaging method.
Calculation: Signal line = moving average of the MACD line, with an independently selected period and averaging method.
Calculation: Evaluation bars = chart bars, or higher-timeframe bars aggregated from chart bars. For the higher-timeframe version, sample the still-forming higher-timeframe bar on its first chart bar and hold that sample until the next higher-timeframe bar; previous values refer to the previous higher-timeframe bar.
Long: MACD line > 0 AND MACD line > previous MACD line OR MACD line < 0 AND MACD line > previous MACD line
Short: MACD line > 0 AND MACD line < previous MACD line OR MACD line < 0 AND MACD line < previous MACD line
Long: MACD line > previous signal line
Short: MACD line < previous signal line