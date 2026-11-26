Calculation: Scale(x, weak, strong) = clamp(100 * (x - weak) / (strong - weak), 0, 100)
Calculation: Volume score = Scale(volume / SMA(volume, volume baseline length), low volume ratio, high volume ratio) if volume support enabled, else neutral volume score
Calculation: Range ATR = (high - low) / ATR(high, low, close, ATR length)
Calculation: Range score = Scale(Range ATR, minimum range ATR, ideal range ATR) if Range ATR <= ideal range ATR, else Scale(Range ATR, maximum range ATR, ideal range ATR)
Calculation: Lower wick share = (min(open, close) - low) / (high - low)
Calculation: Upper wick share = (high - max(open, close)) / (high - low)
Calculation: Close location = (close - low) / (high - low)
Calculation: Wick need = minimum wick share + sensitivity wick offset
Calculation: Close need = minimum close quality + sensitivity close offset
Calculation: Quality need = minimum rejection quality + sensitivity quality offset
Calculation: Long score = (Scale(Lower wick share, Wick need, wick saturation) * wick weight + Scale(Close location, Close need, close saturation) * close weight + Range score * range weight) * (1 - volume weight) + Volume score * volume weight
Calculation: Short score = (Scale(Upper wick share, Wick need, wick saturation) * wick weight + Scale(1 - Close location, Close need, close saturation) * close weight + Range score * range weight) * (1 - volume weight) + Volume score * volume weight
Calculation: Long candidate = Lower wick share >= Wick need AND Close location >= Close need AND Lower wick share > Upper wick share
Calculation: Short candidate = Upper wick share >= Wick need AND 1 - Close location >= Close need AND Upper wick share > Lower wick share
Calculation: Opened = ((Long candidate AND Long score >= Short score AND Long score >= Quality need) OR (Short candidate AND Short score >= Quality need)) AND (no earlier bar where Opened held, OR bars since the most recent earlier such bar >= cooldown bars)
Calculation: Context bars = bars since the most recent bar where Opened held, 0 on that bar
Calculation: Context sign = 1 if Long candidate[Context bars] holds, else -1
Calculation: Failure edge = (low[Context bars] if Context sign = 1, else high[Context bars]) - Context sign * failure buffer * ATR[Context bars]
Calculation: Confirm rail = (high[Context bars] if Context sign = 1, else low[Context bars]) + Context sign * confirmation buffer * ATR[Context bars]
Calculation: Target guide = close[Context bars] + Context sign * target R * max(abs(close[Context bars] - Failure edge), minimum risk ATR * ATR[Context bars])
Calculation: Failure hit = Context sign * (close - Failure edge) < 0
Calculation: Target hit = Context sign * (close - Target guide) >= 0
Calculation: Rail accepted = Context sign * (close - Confirm rail) > 0
Calculation: Failed = NOT Opened AND (Failed[1] OR (NOT Target reached[1] AND NOT Expired[1] AND Failure hit))
Calculation: Target reached = NOT Opened AND (Target reached[1] OR (NOT Expired[1] AND Target hit))
Calculation: Confirmed = NOT Opened AND (Confirmed[1] OR (NOT Expired[1] AND (Target hit OR Rail accepted)))
Calculation: Expired = NOT Opened AND (Expired[1] OR (NOT Failed AND NOT Target reached AND Context bars > max context age))
Calculation: Context score = Long score[Context bars] if Context sign = 1, else Short score[Context bars]
Calculation: Pressure = Context sign * (close[Context bars] - (low if Context sign = 1, else high)) / ATR[Context bars]
Calculation: Active score = clamp(Context score + confirmation bonus * clamp((close - close[Context bars]) / (Confirm rail - close[Context bars]), 0, 1) + target bonus * clamp(((high if Context sign = 1, else low) - close[Context bars]) / (Target guide - close[Context bars]), 0, 1) - pressure penalty * Scale(Pressure, pressure weak, pressure strong) - time penalty * Scale(Context bars, confirmation window, max context age), 0, 100)
Calculation: Ready = Confirmed AND NOT Failed AND NOT Target reached AND NOT Expired AND Active score >= Quality need
Long: Opened AND Long candidate
Short: Opened AND Short candidate
Long: Rail accepted AND NOT Target hit AND NOT Confirmed[1] AND NOT Expired[1] AND Context sign = 1
Short: Rail accepted AND NOT Target hit AND NOT Confirmed[1] AND NOT Expired[1] AND Context sign = -1
Long: Ready AND Context sign = 1
Short: Ready AND Context sign = -1
Exit: long, Failed AND NOT Failed[1]
Exit: long, Target reached AND NOT Target reached[1]
Exit: long, Expired AND NOT Expired[1]
Exit: short, Failed AND NOT Failed[1]
Exit: short, Target reached AND NOT Target reached[1]
Exit: short, Expired AND NOT Expired[1]