Calculation: NY last-hour low = minimum low of bars in the configured final NY hour, finalized when that hour ends
Calculation: Asia low = minimum low of bars in the configured Asia session for the current day
Calculation: London low = minimum low of bars in the configured London session for the current day
Calculation: Entry price = close of the signal bar
Calculation: Long stop = NY last-hour low − ATR × stop-padding parameter
Calculation: Long target = entry price + (entry price − long stop) × reward/risk parameter
Calculation: Short stop = Asia session high ×? 