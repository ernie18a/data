Calculation: GO = ((moving average of signal-bar close − moving average of signal-bar open) + (moving average of signal-bar high − moving average of signal-bar open) + (moving average of signal-bar low − moving average of signal-bar open) + (moving average of signal-bar close − moving average of signal-bar low) + (moving average of signal-bar close − moving average of signal-bar high)) × signal-bar volume; all four moving averages use the same parameters
Long: GO > OpenLevel AND GO ≥ −OpenLevel AND GO ≥ OpenLevel − CloseLevelDif
Short: GO < −OpenLevel AND GO ≤ OpenLevel AND GO ≤ −(OpenLevel − CloseLevelDif)
Exit: long, GO < OpenLevel − CloseLevelDif
Exit: short, GO > −(OpenLevel − CloseLevelDif)