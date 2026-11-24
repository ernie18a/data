Calculation: Bias state = initialize NEUTRAL; from NEUTRAL become BULL if (close - EMA(close, EMA lookback)) / ATR(high, low, close, ATR lookback) > bull entry threshold, else become BEAR if it is < bear entry threshold; from BULL become NEUTRAL if it is < bull exit threshold; from BEAR become NEUTRAL if it is > bear exit threshold; otherwise retain the prior chart bar's state
Calculation: Realized volatility ratio = STDEV(log(close / close[1]), short RV lookback) / STDEV(log(close / close[1]), long RV lookback) when the denominator is > 0, otherwise undefined
Calculation: RV state = EXPANDING when realized volatility ratio > expansion threshold, COMPRESS when it is < compression threshold, otherwise NORMAL, including when undefined
Calculation: Live India VIX = India VIX close from T1, mapped to chart bars using the still-forming T1 bar
Calculation: Prior India VIX = India VIX close from T1, mapped to chart bars using the last completed T1 bar
Long: Bias state = BULL AND live India VIX is available AND live India VIX < VIX extreme threshold
Short: Bias state = BEAR AND live India VIX is available AND live India VIX < VIX extreme threshold
Exit: long, prior chart bar bias state = BULL AND current bias state = NEUTRAL
Exit: short, prior chart bar bias state = BEAR AND current bias state = NEUTRAL
Exit: long, (live India VIX is available AND live India VIX >= VIX extreme threshold) OR (live and prior India VIX are available AND live India VIX >= VIX shock level AND (live India VIX - prior India VIX) / prior India VIX > VIX shock rate threshold)
Exit: short, (live India VIX is available AND live India VIX >= VIX extreme threshold) OR (live and prior India VIX are available AND live India VIX >= VIX shock level AND (live India VIX - prior India VIX) / prior India VIX > VIX shock rate threshold)
Exit: short, entry spot > 0 AND short put strike > 0 AND close <= entry spot - stop fraction * (entry spot - short put strike)
Exit: short, entry spot > 0 AND short call strike > 0 AND close >= entry spot + stop fraction * (short call strike - entry spot)
Option: sell put, live India VIX is available AND live India VIX < VIX extreme threshold AND Bias state = BULL AND (RV state = NORMAL OR RV state = EXPANDING)
Option: buy put, live India VIX is available AND live India VIX < VIX extreme threshold AND Bias state = BULL AND (RV state = NORMAL OR RV state = EXPANDING)
Option: sell call, live India VIX is available AND live India VIX < VIX extreme threshold AND Bias state = BEAR AND (RV state = NORMAL OR RV state = EXPANDING)
Option: buy call, live India VIX is available AND live India VIX < VIX extreme threshold AND Bias state = BEAR AND (RV state = NORMAL OR RV state = EXPANDING)
Option: sell put, live India VIX is available AND live India VIX < VIX extreme threshold AND (((Bias state = BULL OR Bias state = BEAR) AND RV state = COMPRESS) OR (Bias state = NEUTRAL AND RV state = NORMAL))
Option: buy put, live India VIX is available AND live India VIX < VIX extreme threshold AND (((Bias state = BULL OR Bias state = BEAR) AND RV state = COMPRESS) OR (Bias state = NEUTRAL AND RV state = NORMAL))
Option: sell call, live India VIX is available AND live India VIX < VIX extreme threshold AND (((Bias state = BULL OR Bias state = BEAR) AND RV state = COMPRESS) OR (Bias state = NEUTRAL AND RV state = NORMAL))
Option: buy call, live India VIX is available AND live India VIX < VIX extreme threshold AND (((Bias state = BULL OR Bias state = BEAR) AND RV state = COMPRESS) OR (Bias state = NEUTRAL AND RV state = NORMAL))
Option: sell put, live India VIX is available AND live India VIX < VIX extreme threshold AND Bias state = NEUTRAL AND RV state = COMPRESS
Option: buy put, live India VIX is available AND live India VIX < VIX extreme threshold AND Bias state = NEUTRAL AND RV state = COMPRESS
Option: sell call, live India VIX is available AND live India VIX < VIX extreme threshold AND Bias state = NEUTRAL AND RV state = COMPRESS
Option: buy call, live India VIX is available AND live India VIX < VIX extreme threshold AND Bias state = NEUTRAL AND RV state = COMPRESS