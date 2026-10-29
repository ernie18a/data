Calculation: Opening range high and low = highest high and lowest low of completed M1 bars from session start through range end; M1 is lower timeframe than the chart timeframe.
Calculation: Opening range width = opening range high − opening range low.
Calculation: Daily ATR = ATR of the last completed D1 bar; D1 is higher timeframe than the chart timeframe.
Calculation: Entry buffer = configured buffer points × point size.
Calculation: Stop distance = opening range width × configured stop fraction + 2 × entry buffer.
Long: current time ≥ range end AND current time < last entry time AND no trade has been taken today AND long direction is enabled AND opening range width > 0 AND opening range width ≥ configured minimum range-to-ATR multiple × daily ATR AND opening range width ≤ configured maximum range-to-ATR multiple × daily ATR AND high ≥ opening range high + entry buffer.
Short: current time ≥ range end AND current time < last entry time AND no trade has been taken today AND short direction is enabled AND opening range width > 0 AND opening range width ≥ configured minimum range-to-ATR multiple × daily ATR AND opening range width ≤ configured maximum range-to-ATR multiple × daily ATR AND low ≤ opening range low − entry buffer.
Exit: long, low ≤ entry price − stop distance OR high ≥ entry price + stop distance × configured reward-to-risk multiple OR current time ≥ close-all time.
Exit: short, high ≥ entry price + stop distance OR low ≤ entry price − stop distance × configured reward-to-risk multiple OR current time ≥ close-all time.