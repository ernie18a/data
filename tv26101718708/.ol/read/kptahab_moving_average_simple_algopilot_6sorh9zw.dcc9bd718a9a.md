Calculation: Short MA = configured SMA, EMA, WMA, VWMA, or HMA of close using the shorter lookback
Calculation: Long MA = configured SMA, EMA, WMA, VWMA, or HMA of close using the longer lookback
Calculation: Long take-profit price = entry price × (1 + target % / 100)
Calculation: Short take-profit price = entry price / (1 + target % / 100)
Calculation: Long fixed stop = entry price × (1 − stop % / 100); long trailing stop = the higher of the prior stop adjusted for any entry-price change and close × (1 − stop % / 100)
Calculation: Short fixed stop = entry price × (1 + stop % / 100); short trailing stop = the lower of the prior stop adjusted for any entry-price change and close × (1 + stop % / 100)
Long: Short MA crosses above Long MA AND no position is open AND configured entry time filters pass
Short: Short MA crosses below Long MA AND no position is open AND configured entry time filters pass
Long: In a long position AND loss repurchase is enabled AND configured entry time filters pass AND close < entry price × (1 − repurchase % / 100)
Short: In a short position AND loss repurchase is enabled AND configured entry time filters pass AND close > entry price × (1 + repurchase % / 100)
Exit: Long, opposing short signal occurs in reversal mode OR high ≥ an enabled partial or final take-profit price OR low ≤ the enabled stop price OR close < the enabled stop price
Exit: Short, opposing long signal occurs in reversal mode OR low ≤ an enabled partial or final take-profit price OR high ≥ the enabled stop price OR close > the enabled stop price