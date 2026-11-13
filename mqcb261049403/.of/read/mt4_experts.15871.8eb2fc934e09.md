Calculation: Bar n = n-th last completed bar of the chart timeframe (1 = most recent completed bar), with open_n, high_n, low_n, close_n; Body(n) = abs(close_n - open_n)
Calculation: Doji = Body(1) < (high_1 - low_1) / k, k a constant > 1
Calculation: BullEngulf = close_2 < open_2 AND close_1 > open_1 AND Body(2) < Body(1)
Calculation: BearEngulf = close_2 > open_2 AND close_1 < open_1 AND Body(2) < Body(1)
Calculation: MorningStar = Body(3) > Body(2) AND Body(1) > Body(2) AND close_3 < open_3 AND close_1 > open_1 AND close_1 > min(open_3, close_3) + 0.5 * Body(3)
Calculation: EveningStar = Body(3) > Body(2) AND Body(1) > Body(2) AND close_3 > open_3 AND close_1 < open_1 AND close_1 < max(open_3, close_3) - 0.5 * Body(3)
Calculation: Flag F = persistent state, undefined initially, updated on every bar in this order: (1) if NOT EveningStar AND NOT Doji AND NOT BearEngulf then F = 1; (2) then if NOT MorningStar AND NOT Doji AND NOT BullEngulf then F = 0; if neither applies F keeps its previous value
Calculation: ADX = ADX (main line) on the chart timeframe, current forming bar; T = fixed ADX threshold
Calculation: Algo = w1 * AC(much higher timeframe) + w2 * AC(higher timeframe) + w3 * AC(chart timeframe), each AC = Accelerator Oscillator of the currently forming bar of that timeframe; weights are non-negative and increase as timeframe gets lower (w1 <= w2 <= w3)
Calculation: StochM, StochS = Stochastic oscillator main line and signal line (signal is a smoothed moving average of main) on the chart timeframe, last completed bar
Long: no position open AND close_1 < open_1 AND F == 1 AND ((ADX > T AND Algo > 0) OR (ADX < T AND StochM > StochS))
Short: no position open AND close_1 > open_1 AND F == 0 AND ((ADX > T AND Algo < 0) OR (ADX < T AND StochM < StochS))
Exit: long, (ADX > T AND Algo < 0) OR (ADX < T AND StochM < StochS) OR price <= entry price - fixed stop distance OR price >= entry price + fixed take-profit distance OR (trailing enabled AND price <= highest price since entry - trail distance, active once price - entry price > trail distance)
Exit: short, (ADX > T AND Algo > 0) OR (ADX < T AND StochM > StochS) OR price >= entry price + fixed stop distance OR price <= entry price - fixed take-profit distance OR (trailing enabled AND price >= lowest price since entry + trail distance, active once entry price - price > trail distance)