Calculation: TPO profile = for each price row, the number of chart bars of the current session whose low-to-high range overlaps the row, reset at session start; row height = ATR(ATR length) at session start * row fraction, widened by an integer factor when the session would need more than maximum rows
Calculation: session POC = midpoint of the row with the highest TPO profile count
Calculation: session VAH = top edge of the highest row of the value area, which starts at the session POC row and repeatedly adds the adjacent row with the larger TPO profile count (the upper row on ties) until the enclosed count is at least value-area percent * total TPO profile count
Calculation: session VAL = bottom edge of the lowest row of the value area defined for session VAH
Calculation: prior VAH = session VAH at the last chart bar of the previous session
Calculation: prior VAL = session VAL at the last chart bar of the previous session
Calculation: prior POC = session POC at the last chart bar of the previous session
Calculation: profile high = top edge of the highest row of the TPO profile
Calculation: profile low = bottom edge of the lowest row of the TPO profile
Calculation: IB high = highest high of the session's first IB length chart bars
Calculation: IB low = lowest low of the session's first IB length chart bars
Calculation: TPOs above POC = sum of TPO profile counts over rows above the session POC row, counting only rows whose count exceeds 1
Calculation: TPOs below POC = sum of TPO profile counts over rows below the session POC row, counting only rows whose count exceeds 1
Calculation: upper tail = number of consecutive rows from the highest row downward whose TPO profile count is exactly 1
Calculation: lower tail = number of consecutive rows from the lowest row upward whose TPO profile count is exactly 1
Calculation: profile shape = Double if highest row - lowest row >= minimum span and, among rows excluding the two outermost rows at each end, the row with the lowest TPO profile count has count <= valley fraction * session POC row count and the rows above it and the rows below it each hold >= side fraction * total TPO profile count; else P if (session POC row - lowest row) / (highest row - lowest row) >= upper position threshold; else b if that ratio <= lower position threshold; else Normal
Calculation: rotation factor = running sum from session start, over each completed bracket after the first, of (+1 if its high > previous bracket's high, -1 if its high < previous bracket's high) + (+1 if its low > previous bracket's low, -1 if its low < previous bracket's low); a bracket is a block of bracket length minutes from session open, with high = highest high and low = lowest low of its chart bars
Calculation: bars inside prior value = number of consecutive chart bars of the current session, ending at this bar, whose close is between prior VAL and prior VAH inclusive; 0 when the close is outside that range
Calculation: edge test = +1 while an upside test is open, -1 while a downside test is open, else 0; an upside test opens at a chart bar where high >= prior VAH and the previous bar's high < prior VAH, and a downside test opens at a bar where low <= prior VAL and the previous bar's low > prior VAL, only if no test is open after this bar's resolution or cancellation; an open upside test resolves at a later bar where low <= edge target, and otherwise cancels at a bar where high >= prior VAH at opening + accept distance * ATR(ATR length) at opening, or where more than edge horizon bars have passed since opening; an open downside test resolves at a later bar where high >= edge target, and otherwise cancels at a bar where low <= prior VAL at opening - accept distance * ATR(ATR length) at opening, or after more than edge horizon bars
Calculation: edge target = prior POC at the opening bar of the open edge test
Calculation: bias score = (+1 if close > session VAH, -1 if close < session VAL, else 0) + (+1 if session VAL > prior VAH, -1 if session VAH < prior VAL, else 0) + (+1 if profile high > IB high and profile low >= IB low, -1 if profile low < IB low and profile high <= IB high, else 0)
Long: close crosses above session VAH
Short: close crosses below session VAL
Long: close crosses above prior VAL AND lowest low since session start < prior VAL
Short: close crosses below prior VAH AND highest high since session start > prior VAH
Long: bars inside prior value = hold bars AND close[hold bars] < prior VAL
Short: bars inside prior value = hold bars AND close[hold bars] > prior VAH
Long: edge test[1] = -1 AND high >= edge target[1]
Short: edge test[1] = 1 AND low <= edge target[1]
Long: bias score >= 1
Short: bias score <= -1
Long: close > session VAH
Short: close < session VAL
Long: session VAL > prior VAH
Short: session VAH < prior VAL
Long: profile high > IB high AND profile low >= IB low
Short: profile low < IB low AND profile high <= IB high
Long: close - session open >= drive move multiple * IB width AND min(highest high since session open - session open, session open - lowest low since session open) <= drive excursion fraction * IB width
Short: session open - close >= drive move multiple * IB width AND min(highest high since session open - session open, session open - lowest low since session open) <= drive excursion fraction * IB width
Long: profile high - profile low >= range multiple * IB width AND max(0, profile high - IB high) >= max(0, IB low - profile low)
Short: profile high - profile low >= range multiple * IB width AND max(0, profile high - IB high) < max(0, IB low - profile low)
Long: profile shape = P
Short: profile shape = b
Long: rotation factor > rotation threshold
Short: rotation factor < -rotation threshold
Long: TPOs above POC > TPO ratio * TPOs below POC
Short: TPOs below POC > TPO ratio * TPOs above POC
Long: lower tail >= excess min
Short: upper tail >= excess min