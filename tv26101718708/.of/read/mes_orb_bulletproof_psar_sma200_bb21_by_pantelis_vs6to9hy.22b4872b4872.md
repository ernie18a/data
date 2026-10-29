Calculation: Opening range = highest high and lowest low during the first opening-range interval of each session; retain these levels until the session ends
Calculation: Opening-range size = opening-range high − opening-range low
Calculation: ATR = average true range on a higher timeframe, using the last completed bar
Calculation: Base stop distance = ATR × stop-distance multiplier
Calculation: Core target distance = base stop distance × core-target R multiple
Calculation: Runner target distance = opening-range size × runner-target multiple
Calculation: Long runner stop = the greater of the long base stop and PSAR when PSAR is below close; otherwise the long base stop
Calculation: Short runner stop = the lesser of the short base stop and PSAR when PSAR is above close; otherwise the short base stop
Long: In session AND opening range complete AND opening-range size ≥ minimum ATR fraction × ATR AND flat AND no long entry earlier this session AND (close > opening-range high OR, when close-break is disabled, high > opening-range high) AND the last N closes are each > opening-range high AND close > PSAR
Short: In session AND opening range complete AND opening-range size ≥ minimum ATR fraction × ATR AND flat AND no short entry earlier this session AND (close < opening-range low OR, when close-break is disabled, low < opening-range low) AND the last N closes are each < opening-range low AND close < PSAR
Exit: long, low ≤ long base stop OR high ≥ entry price + core target distance
Exit: long, low ≤ long runner stop OR high ≥ entry price + runner target distance
Exit: short, high ≥ short base stop OR low ≤ entry price − core target distance
Exit: short, high ≥ short runner stop OR low ≤ entry price − runner target distance
Exit: long or short, session ends