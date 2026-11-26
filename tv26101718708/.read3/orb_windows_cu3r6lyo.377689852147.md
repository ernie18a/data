Calculation: Window 1 opening range high/low = maximum high and minimum low of chart bars timestamped within [session open, session open + window 1 duration); fixed after the interval ends until the next session open
Calculation: Window 2 opening range high/low = maximum high and minimum low of chart bars timestamped within [session open, session open + window 2 duration); fixed after the interval ends until the next session open
Calculation: Window 3 opening range high/low = maximum high and minimum low of chart bars timestamped within [session open, session open + window 3 duration); fixed after the interval ends until the next session open
Long: during [session open, session close) and after window 1 is locked, high > window 1 opening range high; only the first occurrence per day
Long: during [session open, session close) and after window 1 is locked, close > window 1 opening range high; only the first occurrence per day
Short: during [session open, session close) and after window 1 is locked, low < window 1 opening range low; only the first occurrence per day
Short: during [session open, session close) and after window 1 is locked, close < window 1 opening range low; only the first occurrence per day
Long: during [session open, session close) and after window 2 is locked, high > window 2 opening range high; only the first occurrence per day
Long: during [session open, session close) and after window 2 is locked, close > window 2 opening range high; only the first occurrence per day
Short: during [session open, session close) and after window 2 is locked, low < window 2 opening range low; only the first occurrence per day
Short: during [session open, session close) and after window 2 is locked, close < window 2 opening range low; only the first occurrence per day
Long: during [session open, session close) and after window 3 is locked, high > window 3 opening range high; only the first occurrence per day
Long: during [session open, session close) and after window 3 is locked, close > window 3 opening range high; only the first occurrence per day
Short: during [session open, session close) and after window 3 is locked, low < window 3 opening range low; only the first occurrence per day
Short: during [session open, session close) and after window 3 is locked, close < window 3 opening range low; only the first occurrence per day