Calculation: Buy volume and sell volume = sums of volume over completed lower-timeframe bars within the chart bar, classified as buy when the selected price source is greater than or equal to its previous lower-timeframe value and as sell when it is lower.
Calculation: Active buy volume and active sell volume = buy and sell volume, respectively, restricted to lower-timeframe bars whose volume is greater than the previous lower-timeframe bar's volume.
Long: Buy volume + sell volume > 0 AND buy volume >= sell volume
Short: Buy volume + sell volume > 0 AND buy volume < sell volume
Long: Active buy volume + active sell volume > 0 AND active buy volume >= active sell volume
Short: Active buy volume + active sell volume > 0 AND active buy volume < active sell volume
Long: Buy volume / (buy volume + sell volume) >= volume threshold OR active buy volume / (active buy volume + active sell volume) >= active volume threshold
Short: Sell volume / (buy volume + sell volume) >= volume threshold OR active sell volume / (active buy volume + active sell volume) >= active volume threshold