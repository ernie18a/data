Calculation: Composite TEMA = arithmetic mean of TEMA(close, shortest TEMA lookback), TEMA(close, second-shortest TEMA lookback), TEMA(close, third-shortest TEMA lookback), TEMA(close, fourth-shortest TEMA lookback), TEMA(close, fifth-shortest TEMA lookback), and TEMA(close, longest TEMA lookback), using six distinct, strictly increasing lookbacks.
Calculation: Acceleration = second difference of Composite TEMA.
Calculation: Z-scored acceleration = (Acceleration - SMA(Acceleration, acceleration standardization lookback)) / StDev(Acceleration, acceleration standardization lookback), or zero when the standard deviation is zero.
Calculation: Combined ADX = weighted mean of ADX(fast ADX lookback, fast ADX lookback) and ADX(slow ADX lookback, slow ADX lookback), using separate fast and slow ADX weights, with the fast lookback shorter than the slow lookback.
Calculation: Normalized combined ADX = min(Combined ADX / ADX normalization level, normalized ADX ceiling).
Calculation: Volume z-score = (volume - SMA(volume, volume lookback)) / StDev(volume, volume lookback), or zero when the standard deviation is zero.
Calculation: Signal score = clamp((close > Composite TEMA ? trend points : zero) + (RSI(close, fast RSI lookback) > RSI midline AND RSI(close, medium RSI lookback) > RSI midline AND RSI(close, slow RSI lookback) > RSI midline ? RSI points : zero) + (Volume z-score > volume spike threshold ? volume points : zero) + Normalized combined ADX × ADX points + clamp(Z-scored acceleration × momentum multiplier, -momentum cap, momentum cap), score floor, score ceiling); fast, medium, and slow RSI lookbacks are separate and strictly increasing.
Calculation: Rolling point of control = midpoint of the lowest-price equal-width bin with the greatest summed volume; form the bins across the lowest low to highest high over the point-of-control lookback, and sum each bar's volume when its close is at least the bin low and below the bin high; use the point-of-control bin-count parameter; undefined for zero range or when no bin has positive volume.
Calculation: Upper value boundary = Rolling point of control + StDev(close, value-area lookback).
Calculation: Lower value boundary = Rolling point of control - StDev(close, value-area lookback).
Calculation: Point-of-control drift = current Rolling point of control - Rolling point of control at the point-of-control drift lookback bars ago.
Calculation: Minimum point-of-control drift = tick-size parameter × drift threshold in ticks parameter.
Calculation: Latest confirmed swing high = most recent confirmed Pivot High(high, swing length, swing length), retained until a newer pivot is confirmed.
Calculation: Latest confirmed swing low = most recent confirmed Pivot Low(low, swing length, swing length), retained until a newer pivot is confirmed.
Long: Signal score > entry score threshold AND Combined ADX >= squeeze threshold AND RSI(close, medium RSI lookback) > RSI(close, medium RSI lookback) one bar ago.
Short: Signal score > entry score threshold AND Combined ADX >= squeeze threshold AND RSI(close, medium RSI lookback) < RSI(close, medium RSI lookback) one bar ago.
Long: Composite TEMA crosses above Rolling point of control AND Combined ADX > trend ADX threshold.
Short: Composite TEMA crosses below Rolling point of control AND Combined ADX > trend ADX threshold.
Long: Point-of-control drift > zero AND Composite TEMA > Rolling point of control AND close > current Upper value boundary AND close one bar ago <= current Upper value boundary AND Point-of-control drift > Minimum point-of-control drift.
Short: Point-of-control drift < zero AND Composite TEMA < Rolling point of control AND close < current Lower value boundary AND close one bar ago >= current Lower value boundary AND abs(Point-of-control drift) > Minimum point-of-control drift.
Long: low < Latest confirmed swing low AND close > Latest confirmed swing low AND high - low > SMA(high - low, range-compression lookback).
Short: high > Latest confirmed swing high AND close < Latest confirmed swing high AND high - low > SMA(high - low, range-compression lookback).