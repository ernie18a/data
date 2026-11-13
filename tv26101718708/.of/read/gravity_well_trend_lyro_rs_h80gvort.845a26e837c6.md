Calculation: center = volume-weighted moving average of close (VWMA)
Calculation: dist = (close - center) / ATR
Calculation: lowerBand = center - bandMult * ATR; upperBand = center + bandMult * ATR (same ATR as dist)
Calculation: longTrig = (mode A: dist > escapeThreshold AND center > center of previous bar) OR (mode B: close > center) OR (mode C: close crosses above lowerBand, i.e. previous close <= previous lowerBand AND close > lowerBand); exactly one mode is active
Calculation: shortTrig = (mode A: dist < -escapeThreshold AND center < center of previous bar) OR (mode B: close < center) OR (mode C: close crosses below upperBand, i.e. previous close >= previous upperBand AND close < upperBand); same active mode as longTrig
Calculation: state = long if longTrig, else short if shortTrig, else state of previous bar (initially none); longTrig takes precedence if both are true
Long: longTrig AND state of previous bar != long
Short: shortTrig AND state of previous bar != short
Exit: long, Short condition is true (reverse to short)
Exit: short, Long condition is true (reverse to long)