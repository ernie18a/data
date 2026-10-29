Calculation: TMF = Wilder-smoothed(ADV, period) / Wilder-smoothed(volume, period), where smoothing uses k = 1/period; ADV = volume × (2 × close − TRL − TRH) / TR; TRH = max(high, previous close); TRL = min(low, previous close); TR = TRH − TRL
Long: Close > resistance line AND TMF > 0
Short: Close < support line AND TMF > 0
Long: Price makes a lower low while TMF makes a higher low
Short: Price makes a higher high while TMF makes a lower high