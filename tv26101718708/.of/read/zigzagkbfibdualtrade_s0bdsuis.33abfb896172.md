Calculation: Active swing = latest confirmed ZigZag high-to-low swing (A to B); before entry, if close < B and low < B, update B to the bar low while keeping A fixed
Calculation: Fib level r = B + r × (A − B)
Calculation: EMA = exponential moving average of close; long-term EMA uses a longer lookback than short-term EMA
Calculation: Average volume = simple moving average of volume over a longer lookback than one bar
Long: On a confirmed bar, state = waiting for Trade 1 AND close > Fib level 0.382 AND previous close ≤ Fib level 0.382 AND close > both short-term and long-term EMAs AND volume > 1.2 × average volume
Long: On a confirmed bar, state = waiting for Trade 1 OR waiting for Trade 2 AND close > Fib level 0.68 AND previous close ≤ Fib level 0.68 AND close > both short-term and long-term EMAs AND volume > 1.2 × average volume
Exit: long, state = Trade 1 AND (high ≥ Fib level 0.618 OR close < Fib level 0.236)
Exit: long, state = Trade 2 AND (high ≥ Fib level 1.0 OR close < Fib level 0.618)