Calculation: Donchian midpoint = (highest high + lowest low) / 2 over a lookback.
Calculation: Conversion line = Donchian midpoint over a shorter lookback; base line = Donchian midpoint over a longer lookback.
Calculation: Leading span A = (conversion line + base line) / 2; leading span B = Donchian midpoint over a separate lookback.
Calculation: Current cloud top = maximum of leading spans A and B calculated a displacement minus one chart bars ago; current cloud bottom = their minimum.
Calculation: Bullish cross tier = strong when conversion line > current cloud top, neutral when current cloud bottom <= conversion line <= current cloud top, and weak when conversion line < current cloud bottom.
Calculation: Bearish cross tier = strong when conversion line < current cloud bottom, neutral when current cloud bottom <= conversion line <= current cloud top, and weak when conversion line > current cloud top.
Calculation: Higher-timeframe conversion and base lines = Donchian midpoints using the corresponding chart-timeframe lookbacks on higher-timeframe bars; use the last completed higher-timeframe bar in historical evaluation and the still-forming bar in real-time evaluation.
Long: Conversion line crosses above base line AND bullish cross tier is selected for long entry.
Short: Conversion line crosses below base line AND bearish cross tier is selected for short entry.
Long: Leading span A crosses above leading span B.
Short: Leading span A crosses below leading span B.
Long: Close > current cloud top.
Short: Close < current cloud bottom.
Long: Displaced leading span A > displaced leading span B.
Short: Displaced leading span A <= displaced leading span B.
Long: Conversion line > base line.
Short: Conversion line <= base line.
Long: Higher-timeframe conversion line > higher-timeframe base line.
Short: Higher-timeframe conversion line <= higher-timeframe base line.
Exit: long, conversion line crosses below base line AND bearish cross tier is selected for long exit.
Exit: short, conversion line crosses above base line AND bullish cross tier is selected for short exit.
Exit: long, ATR stop mode selected AND low <= previous chart bar's close minus previous chart bar's ATR multiplied by the stop multiplier OR ATR stop mode selected AND high >= previous chart bar's close plus previous chart bar's ATR multiplied by the target multiplier.
Exit: short, ATR stop mode selected AND high >= previous chart bar's close plus previous chart bar's ATR multiplied by the stop multiplier OR ATR stop mode selected AND low <= previous chart bar's close minus previous chart bar's ATR multiplied by the target multiplier.
Exit: long, fixed-percentage stop mode selected AND stop percentage > 0 AND low <= entry price multiplied by (1 minus stop percentage) OR fixed-percentage stop mode selected AND target percentage > 0 AND high >= entry price multiplied by (1 plus target percentage).
Exit: short, fixed-percentage stop mode selected AND stop percentage > 0 AND high >= entry price multiplied by (1 plus stop percentage) OR fixed-percentage stop mode selected AND target percentage > 0 AND low <= entry price multiplied by (1 minus target percentage).