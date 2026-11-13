Calculation: SessionVWAP = cumulative sum(ohlc4*volume)/cumulative sum(volume), from the first bar of the current day through the current bar, resetting each day
Calculation: HandoffVWAP = sum(ohlc4*volume)/sum(volume) from the most recent bar of the current day whose low <= SessionVWAP <= high (that bar's SessionVWAP, current bar included) through the current bar; undefined if no such bar exists today
Long: close >= HandoffVWAP
Short: close < HandoffVWAP