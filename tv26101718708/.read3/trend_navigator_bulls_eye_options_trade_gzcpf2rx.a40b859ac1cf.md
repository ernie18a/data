Calculation: Underlying bullish alignment = underlying close > EMA(underlying close, P2) AND EMA(underlying close, P1) > EMA(underlying close, P2)
Calculation: Call option bullish alignment = call option close > EMA(call option close, P2) AND EMA(call option close, P1) > EMA(call option close, P2)
Calculation: Underlying bearish alignment = underlying close < EMA(underlying close, P2) AND EMA(underlying close, P1) < EMA(underlying close, P2)
Calculation: Call option bearish alignment = call option close < EMA(call option close, P2) AND EMA(call option close, P1) < EMA(call option close, P2)
Calculation: Put option bullish alignment = put option close > EMA(put option close, P2) AND EMA(put option close, P1) > EMA(put option close, P2)
Calculation: Underlying fast EMA rising = EMA(underlying close, P1) > its value on the previous chart bar
Calculation: Underlying fast EMA falling = EMA(underlying close, P1) < its value on the previous chart bar
Calculation: Call option fast EMA rising = EMA(call option close, P1) > its value on the previous chart bar
Calculation: Call option fast EMA falling = EMA(call option close, P1) < its value on the previous chart bar
Calculation: Put option fast EMA rising = EMA(put option close, P1) > its value on the previous chart bar
Calculation: Put option fast EMA falling = EMA(put option close, P1) < its value on the previous chart bar
Long: Underlying bullish alignment AND call option bullish alignment AND put option close < EMA(put option close, P2) AND EMA(put option close, P1) < EMA(put option close, P2) AND NOT (underlying fast EMA falling AND call option fast EMA falling AND put option fast EMA rising) AND NOT (underlying fast EMA rising AND call option fast EMA rising AND put option fast EMA falling)
Short: Underlying bearish alignment AND call option bearish alignment AND put option bullish alignment AND NOT (underlying fast EMA falling AND call option fast EMA falling AND put option fast EMA rising)
Option: buy call, underlying bullish alignment AND call option bullish alignment AND underlying fast EMA rising AND call option fast EMA rising AND put option fast EMA falling
Option: buy put, underlying bearish alignment AND call option bearish alignment AND underlying fast EMA falling AND call option fast EMA falling AND put option fast EMA rising