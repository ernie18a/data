Calculation: Long comparison price = close when close mode is enabled; otherwise low
Calculation: Short comparison price = close when close mode is enabled; otherwise high
Calculation: Prior trend = the preceding bar’s calculated trend
Long: If no prior trend exists, close > open; if prior trend is long, the long comparison price is greater than at least one low in the preceding period bars; if prior trend is short, the short comparison price is greater than or equal to every high in the preceding period bars
Short: If no prior trend exists, close <= open; if prior trend is short, the short comparison price is less than at least one high in the preceding period bars; if prior trend is long, the long comparison price is less than or equal to every low in the preceding period bars