Calculation: Confirmed pivot high/low = a high/low at a pivot bar that is at least as extreme as the specified number of preceding bars and strictly more extreme than the specified number of following bars; evaluate it when the following bars have completed.
Calculation: Accepted swing and its baseline = process confirmed pivot highs before confirmed pivot lows on each bar. Accept a pivot if its side differs from the active swing; its baseline is the most recently accepted swing of the same side before this new leg. If its side matches the active swing, accept it only if it is strictly more extreme than the active swing, replacing that swing while retaining its baseline. Record RSI at each accepted pivot bar.
Long: Accepted pivot high AND (baseline high is unavailable OR pivot high > baseline high)
Long: Accepted pivot low AND baseline low is available AND pivot low >= baseline low
Long: Accepted pivot low AND baseline low is available AND pivot low < baseline low AND RSI at pivot > RSI at baseline low
Short: Accepted pivot high AND baseline high is available AND pivot high <= baseline high
Short: Accepted pivot low AND (baseline low is unavailable OR pivot low < baseline low)
Short: Accepted pivot high AND baseline high is available AND pivot high > baseline high AND RSI at pivot < RSI at baseline high