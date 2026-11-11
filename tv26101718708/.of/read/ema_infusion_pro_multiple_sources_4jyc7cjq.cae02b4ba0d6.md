Calculation: Selected source = one selectable series: close, volume, rate of change of close, Heikin Ashi close, or rate of change of Heikin Ashi close; Heikin Ashi close = (open + high + low + close) / 4; rate of change = 100 × (current value − value at the lookback) / value at the lookback, or 0 when the value at the lookback is 0.
Long: Selected source > EMA of selected source.
Short: Selected source <= EMA of selected source.
Long: Selected source crosses above its EMA AND (ADX filter disabled OR ADX >= threshold) AND (volume filter disabled OR volume > SMA of volume × volume multiplier).
Short: Selected source crosses below its EMA AND (ADX filter disabled OR ADX >= threshold) AND (volume filter disabled OR volume > SMA of volume × volume multiplier).
Exit: long, selected source crosses below its EMA AND (ADX filter disabled OR ADX >= threshold) AND (volume filter disabled OR volume > SMA of volume × volume multiplier).
Exit: short, selected source crosses above its EMA AND (ADX filter disabled OR ADX >= threshold) AND (volume filter disabled OR volume > SMA of volume × volume multiplier).
Exit: long, ATR exit mode selected AND (high >= entry price + take-profit multiplier × ATR at entry signal OR low <= entry price − stop-loss multiplier × ATR at entry signal).
Exit: short, ATR exit mode selected AND (low <= entry price − take-profit multiplier × ATR at entry signal OR high >= entry price + stop-loss multiplier × ATR at entry signal).
Exit: long, percentage exit mode selected AND (high >= entry-signal close × (1 + take-profit percentage) OR low <= entry-signal close × (1 − stop-loss percentage)).
Exit: short, percentage exit mode selected AND (low <= entry-signal close × (1 − take-profit percentage) OR high >= entry-signal close × (1 + stop-loss percentage)).