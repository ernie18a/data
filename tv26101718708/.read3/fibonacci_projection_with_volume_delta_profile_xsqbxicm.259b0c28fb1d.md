Calculation: SwingHigh = high == Highest(high, N)
Calculation: SwingLow = low == Lowest(low, N)
Calculation: LastHigh = ValueWhen(SwingHigh, high, 0)
Calculation: LastLow = ValueWhen(SwingLow, low, 0)
Calculation: BarsSinceHigh = BarsSince(SwingHigh)
Calculation: BarsSinceLow = BarsSince(SwingLow)
Calculation: Retrace(f) = BarsSinceHigh < BarsSinceLow ? LastHigh - (LastHigh - LastLow) * f : LastLow + (LastHigh - LastLow) * f
Calculation: Point0 = BarsSinceHigh < BarsSinceLow ? LastHigh : LastLow
Calculation: Point1 = Retrace(A)
Calculation: Point2 = BarsSinceLow < BarsSinceHigh ? Point1 - (Point1 - LastLow) * A : Point1 + (LastHigh - Point1) * A
Calculation: Point3 = Retrace(E)
Long: Point0 < Point1
Long: Point1 < Point2
Long: Point2 < Point3
Short: Point0 >= Point1
Short: Point1 >= Point2
Short: Point2 >= Point3
Calculation: Boundary(K) = the K-th smallest value among LastHigh, LastLow, Retrace(B1), Retrace(B2), Retrace(B3), Retrace(B4), Retrace(B5)
Calculation: BandDelta(K) = Sum over n from min(BarsSinceHigh, BarsSinceLow) to max(BarsSinceHigh, BarsSinceLow) of (close[n] > open[n] ? volume[n] : -volume[n]) where Boundary(K) <= TypicalPrice[n] AND TypicalPrice[n] < Boundary(K+1)
Long: BandDelta(K) > 0 AND BarsSinceHigh != BarsSinceLow
Short: BandDelta(K) < 0 AND BarsSinceHigh != BarsSinceLow