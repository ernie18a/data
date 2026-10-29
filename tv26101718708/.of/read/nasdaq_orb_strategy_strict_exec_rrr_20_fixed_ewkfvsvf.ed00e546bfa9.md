Calculation: Opening Range High = highest high from 09:30 through 09:44 New York time, locked at 09:45
Calculation: Opening Range Low = lowest low from 09:30 through 09:44 New York time, locked at 09:45
Calculation: Opening Range Midpoint = (Opening Range High + Opening Range Low) / 2
Calculation: RVOL = volume / 20-bar simple moving average of volume
Calculation: Long target = entry price + (entry price − Opening Range Midpoint) × reward/risk parameter
Calculation: Short target = entry price − (Opening Range Midpoint − entry price) × reward/risk parameter
Long: New York time >= 09:45 AND New York time < 16:00 AND Opening Range is locked AND no trade has been taken today AND position is flat AND previous close <= Opening Range High AND close > Opening Range High AND RVOL >= RVOL threshold
Short: New York time >= 09:45 AND New York time < 16:00 AND Opening Range is locked AND no trade has been taken today AND position is flat AND previous close >= Opening Range Low AND close < Opening Range Low AND RVOL >= RVOL threshold
Exit: long, low <= Opening Range Midpoint OR high >= Long target OR New York time = 16:00
Exit: short, high >= Opening Range Midpoint OR low <= Short target OR New York time = 16:00