Calculation: Institutional score = 20×price-volume score + 20×smart-money score + 15×relative-strength score + 15×PE-expansion score + 15×breakout score + 15×volatility score, divided by 5
Calculation: Price-volume score = 2 if close is above its medium-term EMA, plus 2 if volume is above its longer-term average, plus 1 if close is above the previous close
Calculation: Smart-money score = 3 if the cumulative sum of money-flow multiplier × volume is above its short-term average, plus 2 if volume is above its longer-term average; money-flow multiplier = ((close − low) − (high − close)) / (high − low), using 0.01 when high equals low
Calculation: Relative-strength score = 3 if close divided by benchmark close is above its medium-term average, plus 2 if close's longer-term rate of change is positive
Calculation: PE-expansion score = 2 if close is above its medium-term EMA, plus 2 if RSI is below its upper threshold, plus 1 if close divided by benchmark close is above its medium-term average
Calculation: Breakout score = 2 if ATR is below its longer-term average, plus 2 if volume is above its longer-term average, plus 1 if close is above the previous bar's highest high over a shorter-term lookback
Calculation: Volatility score = 4 if ATR is below its longer-term average, otherwise 1
Long: Institutional score > 60
Short: Institutional score < 40