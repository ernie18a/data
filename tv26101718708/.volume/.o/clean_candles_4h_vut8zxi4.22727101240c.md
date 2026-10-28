Calculation: Upper wick = selected-timeframe bar currently supplied by the lookahead-on request (may still be forming): high − max(open, close)
Calculation: Lower wick = selected-timeframe bar currently supplied by the lookahead-on request (may still be forming): min(open, close) − low
Calculation: Candle liquidity = current chart bar's ((high + low + close) / 3) × volume
Long: selected-timeframe close ≥ open AND (upper wick ≤ wick tolerance OR lower wick ≤ wick tolerance) AND current chart bar is confirmed AND candle liquidity ≥ minimum liquidity
Short: selected-timeframe close < open AND (upper wick ≤ wick tolerance OR lower wick ≤ wick tolerance) AND current chart bar is confirmed AND candle liquidity ≥ minimum liquidity