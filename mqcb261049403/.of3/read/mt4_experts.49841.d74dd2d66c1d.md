Calculation: Cutler RSI = truncate(100 - 100 / (1 + sum(max(close[n] - close[n+1], 0), n=0..lookback-1) / sum(max(close[n+1] - close[n], 0), n=0..lookback-1))); 0 if either sum is 0, computed from T1 closes including the forming T1 bar
Calculation: Grid step = min(base grid step, maximum grid step) when position count <= 1 or grid step multiplier <= 1; otherwise min((position count - 1) × grid step multiplier × base grid step, maximum grid step)
Calculation: Long entry trigger = close + entry distance × point when a new long trigger is initialized
Calculation: Short entry trigger = close - entry distance × point when a new short trigger is initialized
Long: Long trading enabled AND no open long position AND no long close pending AND Cutler RSI <= lower RSI threshold
Long: Long trading enabled AND no open long position AND no long close pending AND long entry trigger > 0 AND close >= long entry trigger - point
Long: Long trading enabled AND an open long position AND grid step enabled AND no all-position or long close pending AND close <= last long entry price - grid step × point
Short: Short trading enabled AND no open short position AND no short close pending AND Cutler RSI >= upper RSI threshold
Short: Short trading enabled AND no open short position AND no short close pending AND short entry trigger > 0 AND close <= short entry trigger + point
Short: Short trading enabled AND an open short position AND grid step enabled AND no all-position or short close pending AND close >= last short entry price + grid step × point
Calculation: Long break-even price = close - (long open-position profit / (tick value × long open-position lots)) × point
Calculation: Short break-even price = close + (short open-position profit / (tick value × short open-position lots)) × point
Exit: long, stop-loss/take-profit routine enabled AND ((take-profit distance > 0 AND close >= long break-even price + take-profit distance × point) OR (stop-loss distance > 0 AND close <= long break-even price - stop-loss distance × point))
Exit: short, stop-loss/take-profit routine enabled AND ((take-profit distance > 0 AND close <= short break-even price - take-profit distance × point) OR (stop-loss distance > 0 AND close >= short break-even price + stop-loss distance × point))
Calculation: Long trailing level starts unset; when trailing is enabled and close >= long break-even price + (trailing stop distance + trailing update step) × point AND (level is unset OR close - (trailing stop distance + trailing update step) × point >= level), set it to close - trailing update step × point; otherwise retain it
Calculation: Short trailing level starts unset; when trailing is enabled and close <= short break-even price - (trailing stop distance + trailing update step) × point AND (level is unset OR close + (trailing stop distance + trailing update step) × point <= level), set it to close + trailing update step × point; otherwise retain it
Exit: long, long trailing level is set AND close <= long trailing level
Exit: short, short trailing level is set AND close >= short trailing level
Calculation: Long breakeven level starts unset; when breakeven is enabled and close >= long break-even price + (breakeven activation distance + breakeven update step) × point, set it to long break-even price + breakeven update step × point; otherwise retain it
Calculation: Short breakeven level starts unset; when breakeven is enabled and close <= short break-even price - (breakeven activation distance + breakeven update step) × point, set it to short break-even price - breakeven update step × point; otherwise retain it
Exit: long, long breakeven level is set AND close <= long breakeven level
Exit: short, short breakeven level is set AND close >= short breakeven level
Calculation: Overlap pair = the farthest profitable open position and farthest losing open position by distance from close; long positions are profitable below close and losing above it, short positions are profitable above close and losing below it; use each position's profit including swap and commission
Calculation: Overlap effective lots = sum of overlap pair lots when their sides match; otherwise the absolute difference of their lots, undefined when that difference is zero
Calculation: Overlap side = the common side when overlap pair sides match; otherwise the side of the member with more lots
Calculation: Overlap close level = close - (overlap pair profit sum / (tick value × overlap effective lots)) × point + overlap target distance × point when overlap side is long; close + (overlap pair profit sum / (tick value × overlap effective lots)) × point - overlap target distance × point when overlap side is short
Exit: long, overlap is enabled AND open position count >= overlap activation count AND overlap pair exists AND overlap effective lots is defined AND overlap pair contains a long position AND ((overlap side is long AND close >= overlap close level) OR (overlap side is short AND close <= overlap close level))
Exit: short, overlap is enabled AND open position count >= overlap activation count AND overlap pair exists AND overlap effective lots is defined AND overlap pair contains a short position AND ((overlap side is long AND close >= overlap close level) OR (overlap side is short AND close <= overlap close level))