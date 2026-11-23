Calculation: Osc = external oscillator series if external oscillator is enabled, else Oscillator(oscillator type, oscillator length, close, high, low)
Calculation: Piv = ZigZag(Osc, zigzag length), where Piv[0] is the latest pivot
Calculation: MovingAverage = Moving average(close, ma length, ma type)
Calculation: Ext(s) = Kind(Piv[lag]) * (s(Piv[lag]) - s(Piv[lag+2]))
Calculation: Line(s, b) = s(Piv[lag+2]) + (s(Piv[lag]) - s(Piv[lag+2])) * (b - idx(Piv[lag+2])) / (idx(Piv[lag]) - idx(Piv[lag+2]))
Calculation: Valid = for every bar b with idx(Piv[lag+2]) < b < idx(Piv[lag]): Kind(Piv[lag]) * (Close(b) - Line(Close, b)) <= 0 AND Kind(Piv[lag]) * (Osc(b) - Line(Osc, b)) <= 0
Calculation: TrendSign = sign(Close(Piv[lag+2]) - Close(Piv[lag+4])) if trend method is zigzag; sign(MovingAverage(Piv[lag+2]) - MovingAverage(Piv[lag])) if trend method is moving average difference; sign(external trend signal(Piv[lag])) if trend method is external
Long: Count(Piv) > Count(Piv)[1] AND Kind(Piv[lag]) = -1 AND Ext(Close) > 0 AND Ext(Osc) <= 0 AND TrendSign = -1 AND Valid
Long: Count(Piv) > Count(Piv)[1] AND Kind(Piv[lag]) = -1 AND Ext(Close) <= 0 AND Ext(Osc) > 0 AND TrendSign != -1 AND Valid
Short: Count(Piv) > Count(Piv)[1] AND Kind(Piv[lag]) = 1 AND Ext(Close) > 0 AND Ext(Osc) <= 0 AND TrendSign = 1 AND Valid
Short: Count(Piv) > Count(Piv)[1] AND Kind(Piv[lag]) = 1 AND Ext(Close) <= 0 AND Ext(Osc) > 0 AND TrendSign != 1 AND Valid