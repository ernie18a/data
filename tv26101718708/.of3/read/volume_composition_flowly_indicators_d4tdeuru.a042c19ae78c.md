Calculation: Buy volume = sum(volume on T1 bars in the current chart bar where direction source >= the previous T1 bar's direction source), including the still-forming T1 bar when available
Calculation: Sell volume = sum(volume on T1 bars in the current chart bar where direction source < the previous T1 bar's direction source), including the still-forming T1 bar when available
Calculation: Active buy volume = sum(volume on T1 bars in the current chart bar where direction source >= the previous T1 bar's direction source and volume > the previous T1 bar's volume), including the still-forming T1 bar when available
Calculation: Active sell volume = sum(volume on T1 bars in the current chart bar where direction source < the previous T1 bar's direction source and volume > the previous T1 bar's volume), including the still-forming T1 bar when available
Calculation: Buy-volume percentage = 100 * buy volume / (buy volume + sell volume)
Calculation: Sell-volume percentage = 100 * sell volume / (buy volume + sell volume)
Calculation: Active buy-volume percentage = 100 * active buy volume / (active buy volume + active sell volume)
Calculation: Active sell-volume percentage = 100 * active sell volume / (active buy volume + active sell volume)
Long: (buy volume >= sell volume AND buy volume + sell volume > 0) OR (active buy volume >= active sell volume AND active buy volume + active sell volume > 0)
Short: (sell volume > buy volume AND buy volume + sell volume > 0) OR (active sell volume > active buy volume AND active buy volume + active sell volume > 0)
Long: buy-volume percentage >= volume threshold OR active buy-volume percentage >= active-volume threshold, evaluated only on confirmed chart bars
Short: sell-volume percentage >= volume threshold OR active sell-volume percentage >= active-volume threshold, evaluated only on confirmed chart bars