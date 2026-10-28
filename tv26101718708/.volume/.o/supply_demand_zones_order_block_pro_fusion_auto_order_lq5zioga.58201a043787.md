Calculation: EMA = exponential moving average of close
Calculation: Volume average = simple moving average of volume
Calculation: Latest demand = newest stored swing low in the lookback; a swing low is lower than the lows one and two bars before and after it
Calculation: Latest supply = newest stored swing high in the lookback; a swing high is higher than the highs one and two bars before and after it
Calculation: Order-block move = absolute percentage change from the close of the older order-block candle to the close of the latest completed candle
Calculation: Fast and slow smoothers = apply the same recursive two-pole smoother to close, using a shorter length for the fast smoother than the slow one; for each length L, f = 1.414π/L, a = exp(−f), c2 = 2a cos(f), c3 = −a², c1 = 1−c2−c3, and output = c1×(close + prior close)/2 + c2×prior output + c3×output from two bars earlier
Calculation: Momentum = (fast smoother − slow smoother) × a constant scale
Calculation: Smoothed momentum = apply the same recursive two-pole smoother to momentum
Long: low ≤ latest demand AND close > latest demand AND close > EMA AND volume > volume average × a multiplier OR older order-block candle closed below its open AND every intervening candle closed above its open AND order-block move ≥ its threshold OR momentum crosses above smoothed momentum
Short: high ≥ latest supply AND close < latest supply AND volume > volume average × a multiplier OR older order-block candle closed above its open AND every intervening candle closed below its open AND order-block move ≥ its threshold OR momentum crosses below smoothed momentum
Exit: Long, low ≤ entry price minus the initial stop distance
Exit: Short, high ≥ entry price plus the initial stop distance