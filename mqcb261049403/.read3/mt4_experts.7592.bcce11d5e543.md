Calculation: within trading hours = hour(current bar datetime) >= start-hour parameter AND hour(current bar datetime) <= end-hour parameter
Long: volume[1] < volume[2]
Short: volume[1] > volume[2]
Exit: long, volume[1] = volume[2] OR (volume[1] < volume[2] AND NOT within trading hours)
Exit: short, volume[1] = volume[2] OR (volume[1] > volume[2] AND NOT within trading hours)