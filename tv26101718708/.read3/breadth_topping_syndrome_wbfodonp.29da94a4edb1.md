Calculation: Core data available = NYSE advancing issues, NYSE declining issues, NYSE new 52-week highs, NYSE new 52-week lows and NYSE Composite index close are all available
Calculation: Uptrend = Core data available AND NYSE Composite index close > NYSE Composite index close P9 bars earlier
Calculation: Miekka condition = Core data available AND 100 × NYSE new 52-week highs / (NYSE advancing + declining issues) ≥ P5 AND 100 × NYSE new 52-week lows / (NYSE advancing + declining issues) ≥ P5
Calculation: High-low percentile = percentile rank over P11 bars of EMA(High Low Logic Index, P10), where High Low Logic Index = min(NYSE new 52-week highs, NYSE new 52-week lows) / (NYSE advancing + declining issues) × 100
Calculation: Participation = percentage of stocks above their 200-day moving average from the S&P 500 series when available, otherwise from the fallback series
Calculation: Participation percentile = percentile rank over P11 bars of the last available Participation value
Calculation: Deterioration score = (P12 × High-low percentile + P13 × (100 − Participation percentile) + P14 × (100 − percentile rank over P11 bars of 100 × NYSE new 52-week highs / (NYSE new 52-week highs + NYSE new 52-week lows))) / (P12 + P13 + P14), omitting the P13 term and its weight when Participation is unavailable
Calculation: Syndrome count = [Miekka condition] + [Core data available AND High-low percentile ≥ P6] + [Uptrend AND Participation is available AND Participation percentile ≤ P7] + [Core data available AND Deterioration score ≥ P8], each bracket being 1 if its condition is true on at least one of the last P2 bars, current bar included, else 0
Calculation: Syndrome trigger = Uptrend AND Syndrome count ≥ P1 AND NOT (Uptrend AND Syndrome count ≥ P1 on the previous bar)
Calculation: Syndrome active = Syndrome trigger occurred on the current bar or on any of the previous P3 bars AND McClellan Oscillator(P15, P16) of advancing minus declining issues < 0
Short: Syndrome trigger = true
Short: Syndrome trigger = true AND number of Syndrome triggers within the last P4 bars, current bar included, ≥ 2
Short: Syndrome active = true
Short: Syndrome active = true AND Syndrome active on the previous bar = false
Short: Miekka condition = true AND Syndrome trigger = false
Short: Deterioration score crosses above P8