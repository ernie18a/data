Calculation: Active kill zone = the configured session containing the chart bar's opening time in the configured timezone; if sessions overlap, prioritize NY-PM, NY-AM, London, then Asia.
Calculation: Prior pool high and low = the maximum high and minimum low of the most recently ended contiguous active kill-zone occurrence; an active-zone change also ends the previous occurrence.
Calculation: Higher-timeframe EMA = EMA of higher-timeframe closes, shifted by one higher-timeframe bar and merged onto chart bars with lookahead off; on historical chart bars, the shifted value becomes available at the end of the higher-timeframe bar.
Long: A kill zone is active AND ATR > 0 AND low < prior pool low AND close > prior pool low AND (prior pool low - low) / ATR >= minimum sweep depth.
Short: A kill zone is active AND ATR > 0 AND high > prior pool high AND close < prior pool high AND (high - prior pool high) / ATR >= minimum sweep depth.
Long: Higher-timeframe bias is enabled AND close > higher-timeframe EMA.
Short: Higher-timeframe bias is enabled AND close < higher-timeframe EMA.