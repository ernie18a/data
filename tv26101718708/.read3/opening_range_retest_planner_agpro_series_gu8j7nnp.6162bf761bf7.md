Calculation: Opening Range High = highest(high) over the opening range window of the current session
Calculation: Opening Range Low = lowest(low) over the opening range window of the current session
Calculation: Opening Range Size = Opening Range High - Opening Range Low
Calculation: Tracking Valid = the opening range window of the current session has ended AND Opening Range Size > minimum range size AND the bar is in the tracking window
Calculation: Break Side = on the first bar of the current session's opening range cycle where Tracking Valid AND (close > Opening Range High + ATR(atr length) * break buffer multiplier OR close < Opening Range Low - ATR(atr length) * break buffer multiplier), long if close > Opening Range High + ATR(atr length) * break buffer multiplier, else short; none before that bar; unchanged until the cycle restarts
Calculation: Bars Since Break = bars since the bar where Break Side was first set, 0 on that bar
Calculation: Break Level = Opening Range High if Break Side is long, Opening Range Low if Break Side is short
Calculation: Pocket Touched = low <= Break Level + ATR(atr length) * retest pocket multiplier AND high >= Break Level - ATR(atr length) * retest pocket multiplier
Calculation: Pocket Held = Pocket Touched AND ((Break Side is long AND close >= Break Level) OR (Break Side is short AND close <= Break Level))
Calculation: Retest Failed = (Break Side is long AND close < Break Level - ATR(atr length) * failure buffer multiplier) OR (Break Side is short AND close > Break Level + ATR(atr length) * failure buffer multiplier)
Calculation: Required Score = clamp(minimum ready score - confirmation bonus, 1, 100)
Calculation: Retest Score = clamp(touch weight * Pocket Touched + close points + time weight * clamp(1 - Bars Since Break / retest window, 0, 1) + volume points + range weight * clamp(1 - abs(Opening Range Size / ATR(atr length) - range ratio target) / range ratio width, 0, 1) + room weight * clamp((Opening Range Size * target 1 multiplier + sign(Break Side) * (Break Level - close)) / (ATR(atr length) * room reference), 0, 1), 0, 100), where Pocket Touched counts 1 if true and 0 otherwise, close points = close hold weight if Pocket Held, else close touch weight if Pocket Touched, else 0, volume points = volume weight * clamp(RVOL / volume reference, 0, 1) if volume scoring is on, else fixed volume weight, RVOL = volume / SMA(volume, volume length), or 1 if that SMA is 0, sign(long) = 1, sign(short) = -1
Calculation: Retest Resolved = true from the first bar after the Break Side bar on which Tracking Valid AND ((Pocket Held AND Retest Score >= Required Score) OR Retest Failed OR Bars Since Break > retest window), and stays true until the opening range restarts; false otherwise
Long: Break Side is long AND Bars Since Break = 0
Short: Break Side is short AND Bars Since Break = 0
Long: Break Side is long AND Bars Since Break > 0 AND Tracking Valid AND Retest Resolved[1] is false AND Pocket Held AND Retest Score >= Required Score
Short: Break Side is short AND Bars Since Break > 0 AND Tracking Valid AND Retest Resolved[1] is false AND Pocket Held AND Retest Score >= Required Score
Exit: long, Break Side is long AND Bars Since Break > 0 AND Tracking Valid AND Retest Resolved[1] is false AND Retest Failed
Exit: long, Break Side is long AND Tracking Valid AND Retest Resolved[1] is false AND Bars Since Break > retest window
Exit: short, Break Side is short AND Bars Since Break > 0 AND Tracking Valid AND Retest Resolved[1] is false AND Retest Failed
Exit: short, Break Side is short AND Tracking Valid AND Retest Resolved[1] is false AND Bars Since Break > retest window