Partial framework; the selectable confirmation indicators, entry filters, continuation rules, and indicator-based exits remain incomplete.
Calculation: Entry ATR = selected moving average of true range, captured on the entry bar.
Exit: long, low <= entry price - stop multiplier × entry ATR.
Exit: short, high >= entry price + stop multiplier × entry ATR.
Exit: long, high >= entry price + profit multiplier × entry ATR; exit the profit-targeted position only.
Exit: short, low <= entry price - profit multiplier × entry ATR; exit the profit-targeted position only.
Exit: long, exit rules enabled = true AND baseline enabled = true AND baseline crosses above close.
Exit: short, exit rules enabled = true AND baseline enabled = true AND close crosses above baseline.