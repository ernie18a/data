Calculation: VolatilityPivotStop(distance)[t] = stop[t-1] if close[t] = stop[t-1]; min(stop[t-1], close[t] + distance) if close[t-1] < stop[t-1] AND close[t] < stop[t-1]; max(stop[t-1], close[t] - distance) if close[t-1] > stop[t-1] AND close[t] > stop[t-1]; close[t] - distance if close[t] > stop[t-1]; otherwise close[t] + distance. Distance is either a price-points parameter × point size or an ATR-multiplier parameter × EMA(ATR(ATR lookback parameter), EMA lookback parameter).
Long: close > VolatilityPivotStop(distance)
Short: close < VolatilityPivotStop(distance)
Long: close crosses above VolatilityPivotStop(distance)
Short: close crosses below VolatilityPivotStop(distance)
Long: on chart bars using values from the T1 bar still forming, close(T1, still forming) > VolatilityPivotStop(distance, T1, still forming)
Short: on chart bars using values from the T1 bar still forming, close(T1, still forming) < VolatilityPivotStop(distance, T1, still forming)
Long: on chart bars using values from T1, close(T1, still forming) > VolatilityPivotStop(distance, T1, still forming) AND close(T1, last completed bar) <= VolatilityPivotStop(distance, T1, last completed bar)
Short: on chart bars using values from T1, close(T1, still forming) < VolatilityPivotStop(distance, T1, still forming) AND close(T1, last completed bar) >= VolatilityPivotStop(distance, T1, last completed bar)