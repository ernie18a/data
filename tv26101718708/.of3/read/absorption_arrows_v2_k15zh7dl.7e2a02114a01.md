Calculation: BodyTop = max(open, close)
Calculation: BodyBottom = min(open, close)
Calculation: BarMidpoint = (high + low) / 2
Calculation: VotesAbove(percentile) = number of lookbacks among shorter lookback, medium lookback and longer lookback for which volume >= PercentileLinearInterpolation(volume, lookback, percentile)
Long: BarMidpoint <= BodyBottom AND (bar direction filter is off OR close < open) AND (VotesAbove(smaller percentile) >= required votes OR VotesAbove(medium percentile) >= required votes OR VotesAbove(larger percentile) >= required votes)
Short: BarMidpoint >= BodyTop AND (bar direction filter is off OR close > open) AND (VotesAbove(smaller percentile) >= required votes OR VotesAbove(medium percentile) >= required votes OR VotesAbove(larger percentile) >= required votes)
Long: BarMidpoint > BodyBottom AND BarMidpoint < BodyTop AND close > open AND (VotesAbove(medium percentile) >= required votes OR VotesAbove(larger percentile) >= required votes)
Short: BarMidpoint > BodyBottom AND BarMidpoint < BodyTop AND close < open AND (VotesAbove(medium percentile) >= required votes OR VotesAbove(larger percentile) >= required votes)