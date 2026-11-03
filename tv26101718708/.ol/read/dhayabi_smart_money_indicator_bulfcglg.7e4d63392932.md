Calculation: Structure high = highest high over the structure lookback; initialize from that value and reset to it after a close above structure high or below structure low.
Calculation: Structure low = lowest low over the structure lookback; initialize from that value and reset to it after a close above structure high or below structure low.
Calculation: First break level = structure high when a low first falls below structure low.
Calculation: Stop loss = lowest low from the first subsequent close above structure low through the break signal bar.
Calculation: Fibonacci limit entry = signal bar high − (signal bar high − stop loss) × Fibonacci retracement parameter.
Calculation: Volume profile limit entry = the low of the first bar, scanning from the signal bar back to the sweep bar, where cumulative volume reaches 70% of total volume in that scan.
Calculation: Take profit = limit entry + (limit entry − stop loss) × reward-to-risk parameter.
Long: low < structure low; thereafter close > structure low; thereafter close > first break level AND no trade has yet been taken for this sweep AND stop loss is defined AND limit entry > stop loss. Submit a long limit order at the selected limit entry; fill when price reaches the limit.
Exit: Long, low ≤ stop loss OR high ≥ take profit. If high ≥ limit entry + (take profit − limit entry) × break-even trigger, set stop loss to limit entry.