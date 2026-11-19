Calculation: Fractal midpoint = average of the latest confirmed fractal high and low, each using the same fractal lookback on both sides
Calculation: Bull score = count of true conditions: SMA(Ease of Movement, EOM lookback) > 0 and greater than its prior value; close > Fractal midpoint; CCI(close, CCI lookback) > 0; close > open and abs(close - open) > ATR(ATR lookback) * thrust multiplier
Calculation: Bear score = count of true conditions: SMA(Ease of Movement, EOM lookback) < 0 and less than its prior value; close < Fractal midpoint; CCI(close, CCI lookback) < 0; close < open and abs(close - open) > ATR(ATR lookback) * thrust multiplier
Long: Bull score = confirmation threshold - 1 AND close > Fractal midpoint
Short: Bear score = confirmation threshold - 1 AND close < Fractal midpoint
Long: Bull score >= confirmation threshold AND close > Fractal midpoint AND bars since the prior raw long signal > cooldown parameter; if none, bars since chart start > cooldown parameter
Short: Bear score >= confirmation threshold AND close < Fractal midpoint AND bars since the prior raw short signal > cooldown parameter; if none, bars since chart start > cooldown parameter