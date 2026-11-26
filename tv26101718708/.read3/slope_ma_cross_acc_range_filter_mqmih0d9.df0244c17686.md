Calculation: MA = selected ALMA(close, MA lookback, ALMA offset, ALMA sigma), EMA(close, MA lookback), VWMA(close, MA lookback), or HMA(close, MA lookback)
Calculation: MA slope = MA - MA[slope lookback]
Calculation: MA acceleration = MA slope - MA slope[1]
Calculation: Slope angle = degrees(arctan(100 * MA slope / MA[slope lookback] * angle sensitivity multiplier))
Long: (slope-entry enabled AND MA slope crosses above zero OR price-entry enabled AND close crosses above MA OR acceleration-entry enabled AND MA acceleration crosses above zero OR re-entry enabled AND MA slope > 0 AND close > MA AND close crosses above high[1]) AND (range filter disabled OR Slope angle >= minimum trend angle)
Short: (slope-entry enabled AND MA slope crosses below zero OR price-entry enabled AND close crosses below MA OR acceleration-entry enabled AND MA acceleration crosses below zero OR re-entry enabled AND MA slope < 0 AND close < MA AND close crosses below low[1]) AND (range filter disabled OR Slope angle <= -minimum trend angle)
Exit: long, (MA slope crosses below zero OR close crosses below MA OR acceleration-exit enabled AND MA acceleration crosses below zero) AND no Short entry
Exit: short, (MA slope crosses above zero OR close crosses above MA OR acceleration-exit enabled AND MA acceleration crosses above zero) AND no Long entry
Calculation: Long stop = entry price * (1 - stop-loss fraction), or, when shrinking stop is enabled, the greater of that level and the running maximum during the current long position of max(((high + low + close) / 3) * (1 - stop-loss fraction * tightening multiplier), entry price * (1 - stop-loss fraction)) on bars where (high - entry price) / entry price >= tightening profit threshold AND (momentum trigger disabled OR (MA slope < MA slope[1] AND MA slope > 0)); before the first qualifying bar use the entry-based stop
Calculation: Short stop = entry price * (1 + stop-loss fraction), or, when shrinking stop is enabled, the lesser of that level and the running minimum during the current short position of min(((high + low + close) / 3) * (1 + stop-loss fraction * tightening multiplier), entry price * (1 + stop-loss fraction)) on bars where (entry price - low) / entry price >= tightening profit threshold AND (momentum trigger disabled OR (MA slope > MA slope[1] AND MA slope < 0)); before the first qualifying bar use the entry-based stop
Exit: long, low <= Long stop when stop loss is enabled
Exit: short, high >= Short stop when stop loss is enabled
Calculation: Long trailing stop = highest high since high first reached entry price * (1 + trailing activation fraction) - max(tick size, round(entry price * trailing distance fraction / tick size) * tick size)
Calculation: Short trailing stop = lowest low since low first reached entry price * (1 - trailing activation fraction) + max(tick size, round(entry price * trailing distance fraction / tick size) * tick size)
Exit: long, low <= Long trailing stop when trailing is enabled and high has reached entry price * (1 + trailing activation fraction)
Exit: short, high >= Short trailing stop when trailing is enabled and low has reached entry price * (1 - trailing activation fraction)
Exit: long, high >= entry price * (1 + take-profit fraction) when take profit is enabled
Exit: short, low <= entry price * (1 - take-profit fraction) when take profit is enabled