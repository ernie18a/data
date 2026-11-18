Calculation: pivot point = (high(T1, last completed bar) + low(T1, last completed bar) + close(T1, last completed bar)) / 3
Calculation: long entry level = pivot point + metric parameter × point
Calculation: short entry level = pivot point − metric parameter × point
Calculation: reversal reference = pivot point − metric parameter × reference multiplier × point
Calculation: long target = max(close(T1, last completed bar) + (high(T1, last completed bar) − low(T1, last completed bar)) × range multiplier / range divisor, reversal reference − reversal offset × point)
Calculation: short target = min(close(T1, last completed bar) − (high(T1, last completed bar) − low(T1, last completed bar)) × range multiplier / range divisor, reversal reference − reversal offset × point)
Long: price crosses above long entry level AND chart bar hour is within configured trading hours
Short: price crosses below short entry level AND chart bar hour is within configured trading hours
Exit: long, price touches short entry level or long target or current long stop loss, or chart bar hour is outside configured trading hours
Exit: short, price touches long entry level or short target or current short stop loss, or chart bar hour is outside configured trading hours