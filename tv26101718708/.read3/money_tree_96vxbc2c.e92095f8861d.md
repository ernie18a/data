Calculation: Average(source) = selected MA type(source[lag], lookback, LSMA offset/ALMA sigma, ALMA offset), where the type is SMA, EMA, DEMA, TEMA, WMA, VWMA, SMMA, Hull MA, LSMA, ALMA, SSMA, or TMA; calculate on chart bars, or on T1 and return values to chart bars with lookahead off when alternate resolution is enabled, using the T1 bar lag bars ago (the forming bar when lag is zero, a completed bar otherwise)
Calculation: Angle = if y > 0 then -round(180 × acos(1 / sqrt(1 + y²)) / π) else round(180 × acos(1 / sqrt(1 + y²)) / π), where y = (EMA(close, angle lookback)[1] - EMA(close, angle lookback)) / ((high + low + close) / 3) × range scale × lowest(low, range lookback) / (highest(high, range lookback) - lowest(low, range lookback)); calculated on chart bars
Calculation: Choppy = (Angle >= A AND toggle 1) OR (Angle < A AND Angle >= B AND toggle 2) OR (Angle < B AND Angle >= C AND toggle 3) OR (Angle < C AND Angle >= D AND toggle 4) OR (Angle <= -A AND toggle 5) OR (Angle > -A AND Angle <= -B AND toggle 6) OR (Angle > -B AND Angle <= -C AND toggle 7) OR (Angle > -C AND Angle <= -D AND toggle 8) OR (Angle > -D AND Angle < D AND toggle 9), where A > B > C > D > 0
Long: Average(close) > Average(open)
Short: Average(close) <= Average(open)
Long: Average(close) crosses above Average(open) AND short-only mode is not selected AND Choppy is false
Short: Average(close) crosses below Average(open) AND long-only mode is not selected AND Choppy is true
Exit: Long, Average(close) crosses below Average(open) AND long-only mode is selected
Exit: Short, Average(close) crosses above Average(open) AND short-only mode is selected
Exit: Long, (stop parameter > 0 AND low <= entry price - stop parameter) OR (target parameter > 0 AND high >= entry price + target parameter)
Exit: Short, (stop parameter > 0 AND high >= entry price + stop parameter) OR (target parameter > 0 AND low <= entry price - target parameter)