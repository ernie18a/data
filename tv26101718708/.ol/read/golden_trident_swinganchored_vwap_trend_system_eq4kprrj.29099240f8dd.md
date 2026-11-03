Calculation: Swing direction = bullish when the most recent rolling highest high occurred after the most recent rolling lowest low; bearish otherwise
Calculation: Recent range = highest high minus lowest low over the ATR lookback
Calculation: Long backstop = signal-bar close − ATR at the long signal × stop multiple
Calculation: Short backstop = signal-bar close + ATR at the short signal × stop multiple
Long: Swing direction is bullish AND (EMA filter disabled OR close > EMA) AND (chop filter disabled OR recent range > ATR × range multiple) AND datetime is within the backtest range AND the full long condition was false on the previous bar AND position is flat or short
Short: Short entries enabled AND swing direction is bearish AND (EMA filter disabled OR close < EMA) AND (chop filter disabled OR recent range > ATR × range multiple) AND datetime is within the backtest range AND the full short condition was false on the previous bar AND position is flat or long
Exit: long, swing direction is bearish OR low ≤ long backstop
Exit: short, swing direction is bullish OR high ≥ short backstop