Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Long: close > open AND abs(close - open) >= minimum body size AND (upper wick + lower wick) / (high - low) <= maximum wick fraction AND (candle mode is aggressive OR lower wick < upper wick) AND (consolidation filter is disabled OR every body in the preceding consolidation lookback is smaller than the current body) AND (EMA filter is disabled OR close > EMA of close)
Short: close < open AND abs(close - open) >= minimum body size AND (upper wick + lower wick) / (high - low) <= maximum wick fraction AND (candle mode is aggressive OR upper wick < lower wick) AND (consolidation filter is disabled OR every body in the preceding consolidation lookback is smaller than the current body) AND (EMA filter is disabled OR close < EMA of close)
Long: close > EMA of close
Short: close <= EMA of close
Calculation: EMA of close = EMA of close on the selected timeframe; use the last completed bar when the selected timeframe is higher than the chart timeframe, the last completed intrabar when it is lower, and the current chart bar when it is the same