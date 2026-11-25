Calculation: Fast = fast 2pbIdeal moving average(close, shorter lookback, T1, last completed bar)
Calculation: Slow = slow 2pbIdeal moving average(close, longer lookback, T1, last completed bar)
Long: Fast > Slow AND Fast[1] < Slow[1]
Short: Fast < Slow AND Fast[1] > Slow[1]
Exit: long, Fast < Slow AND Fast[1] <= Slow[1]
Exit: short, Fast > Slow AND Fast[1] >= Slow[1]