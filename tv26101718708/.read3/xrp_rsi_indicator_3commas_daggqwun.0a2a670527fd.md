Calculation: base entry price = close of the base-entry bar
Calculation: nth safety-order trigger price = base entry price × (1 − its separate deviation parameter / 100), with each successive deviation parameter larger than the preceding one
Calculation: blended average entry at bar start = sum of quote-size parameters for previously filled orders / sum of (each previously filled order’s quote-size parameter / its fill close); base and safety-order quote-size parameters are separate
Long: flat at bar start AND RSI(close, lookback, T1, last completed bar), sampled on chart bars, < level
Long: long at bar start AND the first safety order is the next unfilled rung AND close <= first safety-order trigger price
Long: long at bar start AND the second safety order is the next unfilled rung AND close <= second safety-order trigger price
Long: long at bar start AND the third safety order is the next unfilled rung AND close <= third safety-order trigger price
Long: long at bar start AND the fourth safety order is the next unfilled rung AND close <= fourth safety-order trigger price
Long: long at bar start AND the fifth safety order is the next unfilled rung AND close <= fifth safety-order trigger price
Exit: long, close >= blended average entry at bar start × (1 + take-profit parameter / 100)