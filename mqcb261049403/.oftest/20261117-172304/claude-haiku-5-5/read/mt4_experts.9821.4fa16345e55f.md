Calculation: HTF open = open of the higher-timeframe bar still forming
Calculation: HTF high = high of the higher-timeframe bar still forming
Calculation: HTF low = low of the higher-timeframe bar still forming
Calculation: point = minimum price increment of the instrument
Long: close > HTF open AND (HTF open - HTF low) > distance * point AND current bar hour < entry cutoff hour AND no open position
Short: close < HTF open AND (HTF high - HTF open) > distance * point AND current bar hour < entry cutoff hour AND no open position
Exit: long, current bar hour > exit hour - 1
Exit: short, current bar hour > exit hour - 1