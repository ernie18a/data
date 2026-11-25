Calculation: current order exposure = sum of current pending-order volumes / 2
Long: the support vector machine trained for buy trades classifies as buy AND current order exposure ≤ maximum order exposure
Short: the support vector machine trained for sell trades classifies as sell AND current order exposure ≤ maximum order exposure
Exit: long, low ≤ entry price − stop-loss pips × pip size OR high ≥ entry price + take-profit pips × pip size
Exit: short, high ≥ entry price + stop-loss pips × pip size OR low ≤ entry price − take-profit pips × pip size