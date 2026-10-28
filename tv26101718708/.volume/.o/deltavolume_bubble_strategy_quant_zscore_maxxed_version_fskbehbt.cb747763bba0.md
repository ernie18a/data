Calculation: Signed volume = footprint volume delta, or volume if close ≥ open and −volume otherwise
Calculation: Absolute signed volume = |signed volume|
Calculation: Absolute-volume Z-score = (absolute signed volume − its rolling mean) ÷ its rolling standard deviation
Calculation: Trend line = configured trend calculation: EMA, WMA, KAMA, or non-repainting Nadaraya–Watson rational-quadratic regression of close
Calculation: Absorption = absolute signed volume meets the configured bubble threshold AND |close − open| < its rolling average × the configured absorption ratio
Long: absolute signed volume meets the configured entry threshold AND signed volume > 0 AND (trend filter disabled OR trend type is None OR close > trend line) AND (absorption detection disabled OR NOT Absorption) AND (LNL filter disabled OR NOT LNL chop)
Short: absolute signed volume meets the configured entry threshold AND signed volume < 0 AND (trend filter disabled OR trend type is None OR close < trend line) AND (absorption detection disabled OR NOT Absorption) AND (LNL filter disabled OR NOT LNL chop)
Calculation: LNL chop = at least one active LNL stop level is below close AND at least one active LNL stop level is above close; stop levels use a 13-period EMA of close and smoothed ATR (8-period EMA of true range), with each level’s trend state retained until close crosses its corresponding ATR boundary
Exit: Long, low ≤ entry price − ATR(14) × stop multiple OR high ≥ entry price + ATR(14) × stop multiple × reward multiple
Exit: Short, high ≥ entry price + ATR(14) × stop multiple OR low ≤ entry price − ATR(14) × stop multiple × reward multiple