Calculation: FN = adaptive moving average (JMA-type smoothing) of a fixed-coefficient low-pass FIR digital filter applied to close prices over a long lookback; bar 1 = last completed bar, bar 2 = the bar before it, bar 3 = the bar before that
Long: no open position AND FN(bar 3) > FN(bar 2) AND FN(bar 2) < FN(bar 1)
Short: no open position AND FN(bar 3) < FN(bar 2) AND FN(bar 2) > FN(bar 1)
Exit: long, FN(bar 2) > FN(bar 1) OR low <= entry price - stop distance OR high >= entry price + take-profit distance (take-profit distance longer than stop distance)
Exit: short, FN(bar 2) < FN(bar 1) OR high >= entry price + stop distance OR low <= entry price - take-profit distance (take-profit distance longer than stop distance)