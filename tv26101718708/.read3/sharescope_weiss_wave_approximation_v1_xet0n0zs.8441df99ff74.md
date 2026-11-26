Calculation: selected upward price = high when high/low mode is enabled, otherwise close
Calculation: selected downward price = low when high/low mode is enabled, otherwise close
Calculation: upward reversal level(x) = x × (1 + reversal percentage / 100)
Calculation: downward reversal level(x) = x / (1 + reversal percentage / 100) when symmetric mode is enabled, otherwise x × (1 - reversal percentage / 100)
Calculation: neutral upper extreme = running maximum of selected upward price while wave direction is neutral, initialized to the first bar's selected upward price
Calculation: neutral lower extreme = running minimum of selected downward price while wave direction is neutral, initialized to the first bar's selected downward price
Calculation: wave direction = neutral initially; after a direction change, retain the direction of the latest change
Calculation: swing extreme = first bar's close initially; while direction is neutral, set to neutral upper extreme if close ≥ first bar's close, otherwise neutral lower extreme; while direction is long, update to the maximum of the prior swing extreme and selected upward price; while direction is short, update to the minimum of the prior swing extreme and selected downward price; on a direction change, reset to the current selected price
Long: wave direction is neutral AND selected upward price ≥ upward reversal level(neutral lower extreme) OR wave direction is short AND selected upward price ≥ upward reversal level(swing extreme)
Short: wave direction is neutral AND selected upward price < upward reversal level(neutral lower extreme) AND selected downward price ≤ downward reversal level(neutral upper extreme) OR wave direction is long AND selected downward price ≤ downward reversal level(swing extreme)