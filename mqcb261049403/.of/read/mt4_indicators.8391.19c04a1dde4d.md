Calculation: PDH, PDL = highest high and lowest low of the previous day (daily bars, higher timeframe than the chart, last completed bar); R = PDH - PDL
Calculation: day open = open of the first bar of the current day (daily bar still forming)
Long: close > day open AND low <= PDH - a*R (a = shallow Fibonacci retracement ratio); entry price = PDH - a*R
Short: close < day open AND high >= PDL + a*R; entry price = PDL + a*R
Exit: long, low <= PDH - b*R (b = deeper Fibonacci retracement ratio, b > a; stop) OR high >= entry price + m_k*R for any k in 1..3 (m_1 < m_2 < m_3 are increasing Fibonacci extension ratios; scale out at each target)
Exit: short, high >= PDL + b*R (b > a; stop) OR low <= entry price - m_k*R for any k in 1..3 (m_1 < m_2 < m_3; scale out at each target)