Calculation: Upper body-cross count = number of active upper liquidity levels strictly between open and close when close > open
Calculation: Lower body-cross count = number of active lower liquidity levels strictly between close and open when close < open
Calculation: Lowest crossed upper level = the lowest active upper liquidity level strictly between open and close when close > open
Calculation: Highest crossed lower level = the highest active lower liquidity level strictly between close and open when close < open
Calculation: Upper wick hit = an active upper liquidity level is greater than max(open, close) and no greater than high
Calculation: Lower wick hit = an active lower liquidity level is less than min(open, close) and no less than low
Calculation: Upper near-range depth = sum of recorded raw volume for the nearest-level-count active upper liquidity levels above close
Calculation: Lower near-range depth = sum of recorded raw volume for the nearest-level-count active lower liquidity levels below close
Calculation: Upper depth dominant = upper near-range depth > lower near-range depth and upper near-range depth > 0
Calculation: Lower depth dominant = lower near-range depth > upper near-range depth and lower near-range depth > 0
Calculation: Upper mass liquidation = confirmed bar and close > open and upper body-cross count >= minimum crossed-level count and (open + close) / 2 > lowest crossed upper level
Calculation: Lower mass liquidation = confirmed bar and close < open and lower body-cross count >= minimum crossed-level count and (open + close) / 2 < highest crossed lower level
Long: Upper mass liquidation
Short: Lower mass liquidation
Long: confirmed bar and lower wick hit and not (upper mass liquidation or lower mass liquidation)
Short: confirmed bar and upper wick hit and not (upper mass liquidation or lower mass liquidation)
Long: Lower depth dominant and not Lower depth dominant on the prior bar
Short: Upper depth dominant and not Upper depth dominant on the prior bar