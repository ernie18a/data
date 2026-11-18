Calculation: BarUp = W ? (Close > Open ? Volume × (High − Low) / (2 × (High − Low) − |Close − Open|) : Close < Open ? Volume × ((High − Low) − |Close − Open|) / (2 × (High − Low) − |Close − Open|) : 0) : (Open <= Close ? Volume : 0)
Calculation: BarDown = W ? (Close > Open ? Volume × ((High − Low) − |Close − Open|) / (2 × (High − Low) − |Close − Open|) : Close < Open ? Volume × (High − Low) / (2 × (High − Low) − |Close − Open|) : 0) : (Open > Close ? Volume : 0)
Calculation: VolUp = sum of BarUp over the last ChartMinutes / T1Minutes chart bars, taken from the T1 bar still forming
Calculation: VolDn = sum of BarDown over the last ChartMinutes / T1Minutes chart bars, taken from the T1 bar still forming
Calculation: RMA(x, n) = (x + (min(n, bar index) − 1) × RMA(x, n)[1]) / min(n, bar index)
Calculation: UpAvg = RMA(Source > Source[1] ? |Source − Source[1]| × VolUp : 0, L)
Calculation: DnAvg = RMA(Source < Source[1] ? |Source − Source[1]| × VolDn : 0, L)
Calculation: RSI = 100 × UpAvg / (UpAvg + DnAvg)
Calculation: Trend = up if RSI > 50 + 50 × Th OR (RSI > 50 − 50 × Th AND Trend[1] = up); down if RSI < 50 − 50 × Th OR (RSI < 50 + 50 × Th AND Trend[1] = down); none otherwise
Long: Trend = up
Short: Trend = down
Exit: long, Trend = none
Exit: short, Trend = none