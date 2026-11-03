Calculation: previous lookback high = highest high over the preceding lookback bars, excluding the current bar
Calculation: previous lookback low = lowest low over the preceding lookback bars, excluding the current bar
Calculation: body size = absolute difference between open and close
Calculation: upper wick = high minus the greater of open and close
Calculation: lower wick = the lesser of open and close minus low
Long: low < previous lookback low AND close > previous lookback low AND lower wick > body size × wick-strength multiplier AND volume > volume SMA AND close > EMA
Short: high > previous lookback high AND close < previous lookback high AND upper wick > body size × wick-strength multiplier AND volume > volume SMA AND close < EMA