Calculation: Bullish setup quality score = 30 + 25 if impulse body/range ≥ the high-body threshold + 25 if impulse range ≥ base range × the expansion threshold + 20 if trend filter is disabled or close > EMA
Calculation: Bearish setup quality score = 30 + 25 if impulse body/range ≥ the high-body threshold + 25 if impulse range ≥ base range × the expansion threshold + 20 if trend filter is disabled or close < EMA
Calculation: Long stop = base low − ATR buffer
Calculation: Short stop = base high + ATR buffer
Calculation: Long target = entry price + max(entry price − long stop, ATR risk floor) × reward/risk ratio
Calculation: Short target = entry price − max(short stop − entry price, ATR risk floor) × reward/risk ratio
Long: previous bar range ≤ ATR × base-range limit AND current close > current open AND current close > previous high AND abs(current close − current open) / max(current high − current low, minimum tick) ≥ minimum displacement ratio AND bullish setup quality score ≥ minimum quality threshold AND (trend filter disabled OR current close > EMA) AND, after the setup, current low ≤ previous bar high
Short: previous bar range ≤ ATR × base-range limit AND current close < current open AND current close < previous low AND abs(current close − current open) / max(current high − current low, minimum tick) ≥ minimum displacement ratio AND bearish setup quality score ≥ minimum quality threshold AND (trend filter disabled OR current close < EMA) AND, after the setup, current high ≥ previous bar low
Exit: long, close < long stop OR high ≥ long target
Exit: short, close > short stop OR low ≤ short target