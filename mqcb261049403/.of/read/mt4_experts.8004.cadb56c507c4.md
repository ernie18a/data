Calculation: Rising-SMA count per evaluation timeframe = count of the five simple moving averages, with lookbacks ordered shortest to longest, whose value on the still-forming bar is greater than on the previous bar; use the still-forming bar of each evaluation timeframe.
Calculation: Bullish AC contribution per evaluation timeframe = 3 when (AC[1] > AC[2] AND AC[2] > AC[3] AND AC[0] < 0 AND AC[0] > AC[1]) OR (AC[0] > AC[1] AND AC[1] > AC[2] AND AC[0] > 0); otherwise 0. AC[0] is from the still-forming bar and AC[1]–AC[3] are completed bars.
Calculation: Bearish AC contribution per evaluation timeframe = 3 when (AC[1] < AC[2] AND AC[2] < AC[3] AND AC[0] > 0 AND AC[0] < AC[1]) OR (AC[0] < AC[1] AND AC[1] < AC[2] AND AC[0] < 0); otherwise 0. AC[0] is from the still-forming bar and AC[1]–AC[3] are completed bars.
Calculation: Bullish score per evaluation timeframe = 12.5 × (rising-SMA count + bullish AC contribution).
Calculation: Bearish score per evaluation timeframe = 12.5 × (falling-SMA count + bearish AC contribution); falling-SMA count uses the same five lookbacks and is the count whose still-forming-bar value is less than the previous-bar value.
Calculation: Bullish signal strength = 2 if all three evaluation-timeframe bullish scores are at least 75; otherwise 1 if all three are greater than 50; otherwise 0.
Calculation: Bearish signal strength = 2 if all three evaluation-timeframe bearish scores are at least 75; otherwise 1 if all three are greater than 50; otherwise 0.
Long: bullish signal strength > configured entry threshold
Short: −bearish signal strength < configured entry threshold
Exit: long, bearish signal strength > configured exit threshold
Exit: short, −bullish signal strength > configured exit threshold