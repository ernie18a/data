Calculation: reference high = valuewhen(the second-candle condition, high, 0)
Calculation: reference low = valuewhen(the second-candle condition, low, 0)
Long: high crosses above reference high + upper-entry offset AND (date filter disabled OR datetime is at or after start date and at or before end date)
Long: low crosses below reference low - lower-entry offset AND (date filter disabled OR datetime is at or after start date and at or before end date)
Exit: long, high crosses above reference high + upper-entry offset + upper-target distance AND (date filter disabled OR datetime is at or after start date and at or before end date)
Exit: long, low crosses below reference low - lower-stop distance AND (date filter disabled OR datetime is at or after start date and at or before end date)
Exit: long, low crosses below reference low - lower-entry offset - lower-target distance AND (date filter disabled OR datetime is at or after start date and at or before end date)
Exit: long, high crosses above reference high + upper-stop distance AND (date filter disabled OR datetime is at or after start date and at or before end date)
Exit: long, hour(datetime) equals cutoff-hour parameter AND minute(datetime) is greater than cutoff-minute parameter
Exit: long, on chart bars the T1 session timestamp for the session parameter is na