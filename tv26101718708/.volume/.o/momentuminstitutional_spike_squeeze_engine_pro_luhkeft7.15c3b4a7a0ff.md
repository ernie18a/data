Calculation: Breakout = close > high of the last completed daily bar
Calculation: Squeeze-on = Bollinger upper band < Keltner upper channel AND Bollinger lower band > Keltner lower channel; Bollinger bands use the current timeframe, and Keltner channels use EMA(close) ± an EMA of high − low
Calculation: Momentum burst = fast ROC > 1.2 × slow ROC AND fast ROC > 1
Calculation: Pre-spike = squeeze-on AND volume > average volume × 1.2 AND volume < average volume × 3 AND |fast ROC − slow ROC| < 0.5 AND fast ROC > 0
Calculation: Smart spike = volume > average volume × 3 AND Breakout AND Momentum burst AND ADX > 20 AND +DI > −DI
Calculation: Trap spike = volume > average volume × 3 AND NOT Breakout AND RSI > 70 AND fast ROC < slow ROC AND −DI > +DI
Calculation: Exhaustion spike = volume > average volume × 3 AND RSI > 75 AND NOT (high − low > 1.5 × average high − low)
Calculation: AI score = (1 if fast ROC > 0, plus 1 if fast ROC > slow ROC, plus 1 if RSI > 55, plus 1 if ADX > 20, plus 1.5 if volume > average volume × 1.5, plus 2 if Breakout, plus 2 if Smart spike, plus 1.5 if Pre-spike, minus 2 if Trap spike, minus 1.5 if Exhaustion spike) / 11.5
Long: AI score > 0.7 AND Breakout AND volume > average volume × 1.5 AND Momentum burst OR AI score > 0.55 AND (fast ROC > 0 AND slow ROC > 0 AND volume > average volume × 1.5 AND NOT Breakout OR Pre-spike) OR slow ROC > 0 AND fast ROC > 0 AND fast ROC < slow ROC AND NOT (volume > average volume × 1.5) OR Pre-spike OR Smart spike
Short: Trap spike
Exit: long, Exhaustion spike