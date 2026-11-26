Calculation: safety-order trigger price for each rung = base-entry price × (1 − that rung’s separate deviation parameter / 100); deviation parameters increase by rung
Calculation: blended average entry = (base-order-size parameter + each filled first, second, third, fourth, and fifth safety-order’s respective size parameter) / (base-order-size parameter / base-entry price + each filled safety-order’s respective size parameter / its fill close)
Long: Flat AND RSI(close, RSI-length parameter, T1, last completed bar) < RSI-level parameter; calculate RSI on T1 bars and sample its value at each chart-bar close
Long: Long with zero safety orders filled AND close <= first safety-order trigger price
Long: Long with one safety order filled AND close <= second safety-order trigger price
Long: Long with two safety orders filled AND close <= third safety-order trigger price
Long: Long with three safety orders filled AND close <= fourth safety-order trigger price
Long: Long with four safety orders filled AND close <= fifth safety-order trigger price
Exit: Long, close >= blended average entry × (1 + take-profit parameter / 100)