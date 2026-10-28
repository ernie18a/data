Calculation: Prior high/low = highest high / lowest low over the longer breakout lookback, excluding the current bar.
Calculation: Continuation bias = fast EMA compared with slow EMA, using the shorter and longer EMA lengths respectively.
Calculation: Active upside/downside attempt = a closed bar with continuation bias up/down that closes above the prior high/below the prior low; store that prior level and direction, and keep the attempt active through the failure evaluation window after the attempt bar.
Calculation: Rejection wick percentage = upper wick / full bar range × 100 for an upside attempt; lower wick / full bar range × 100 for a downside attempt.
Calculation: Pressure rail = for an upside attempt, attempt level minus twice ATR times the attempt-zone multiplier; for a downside attempt, attempt level plus twice ATR times the attempt-zone multiplier.
Long: active downside attempt AND close > stored attempt level AND rejection wick percentage >= trap-wick threshold AND no trap was active on the previous bar
Long: downside trap is active AND close > pressure rail AND close was not above the pressure rail on the previous bar
Short: active upside attempt AND close < stored attempt level AND rejection wick percentage >= trap-wick threshold AND no trap was active on the previous bar
Short: upside trap is active AND close < pressure rail AND close was not below the pressure rail on the previous bar