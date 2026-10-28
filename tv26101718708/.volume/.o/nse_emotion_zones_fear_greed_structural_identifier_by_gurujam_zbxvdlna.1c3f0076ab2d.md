Calculation: Body = absolute value of close − open; range = high − low; upper wick = high − max(open, close); lower wick = min(open, close) − low
Calculation: High volume = volume > its moving average × a threshold
Calculation: Hammer = range > 0 AND lower wick ≥ body × a threshold AND upper wick ≤ body
Calculation: Bullish engulfing = close > open AND open ≤ previous close AND close ≥ previous open AND previous close < previous open
Calculation: Shooting star = range > 0 AND upper wick ≥ body × a threshold AND lower wick ≤ body
Calculation: Bearish engulfing = close < open AND open ≥ previous close AND close ≤ previous open AND previous close > previous open
Calculation: Doji = body ≤ range × a threshold
Long: (High volume AND (Hammer OR Bullish engulfing)) OR (close > its moving average AND High volume AND close > open AND NOT (High volume AND (Shooting star OR Bearish engulfing)) AND previous bar is a Doji)
Short: (High volume AND (Shooting star OR Bearish engulfing)) OR (close < its moving average AND High volume AND close < open AND NOT (High volume AND (Hammer OR Bullish engulfing)) AND previous bar is a Doji)