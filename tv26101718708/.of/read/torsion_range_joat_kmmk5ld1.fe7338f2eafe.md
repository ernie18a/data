Calculation: Wave direction = Select an impulse, pressure, or hybrid method. Impulse score is the rolling sum of sign(close minus previous close). Pressure is EMA((source minus open) / max(high minus low, minimum price increment)), with zero for division by zero; source is a selected price series derived from the available fields. Hybrid score is 0.55 × impulse score + 0.45 × 100 × pressure. Compare the selected score with its positive and negative thresholds: above the positive threshold gives +1, below the negative threshold gives -1, otherwise retain the preceding wave direction; initialize to +1 if the first reading is neutral.
Calculation: Normalized energy = (body weight × abs(close minus open) + range weight × (high minus low)) × volume weight / max(ATR, minimum price increment). Volume weight is either 1 or volume / SMA(volume), using 1 if the denominator is zero.
Calculation: Wave accumulator = EMA(normalized energy) × wave direction on the first bar and whenever wave direction changes; otherwise add that signed energy to the preceding accumulator. Wave age is the number of consecutive bars with the current wave direction, starting at 1.
Calculation: Wave core = EMA(clamp(100 × wave accumulator / max(rolling highest abs(wave accumulator), small positive floor), -100, 100)). Wave signal = EMA(wave core).
Calculation: Compression index = clamp(50 × (2 minus the weighted sum of fast-to-slow EMA ratios of range, body, and normalized energy), 0, 100). The respective fixed weights are 0.45, 0.35, and 0.20. Use shorter and longer EMA lengths for the fast and slow averages; floor the slow range and body denominators at the minimum price increment and the slow energy denominator at a small positive value.
Calculation: Release impulse = fast EMA(normalized energy) minus EMA of that fast EMA. Release bias = +1 when wave core > wave signal, -1 when wave core < wave signal, otherwise wave direction.
Calculation: Upper exhaustion band = clamp(base regime band + EMA(abs(wave core)) × expansion-band boost × 0.1, 8, 95) + exhaustion-band offset. Lower exhaustion band is its negative. Stretch = abs(wave core) minus EMA(abs(wave core)).
Long: Wave direction = +1.
Short: Wave direction = -1.
Long: Wave core >= 0.
Short: Wave core < 0.
Long: Release bias = +1.
Short: Release bias = -1.
Long: Wave direction = +1 AND previous wave direction = -1.
Short: Wave direction = -1 AND previous wave direction = +1.
Long: Compression index < compression threshold AND previous compression index >= compression threshold AND the preceding consecutive compression-bar count >= minimum compression duration AND abs(release impulse) >= release impulse threshold AND release bias = +1.
Short: Compression index < compression threshold AND previous compression index >= compression threshold AND the preceding consecutive compression-bar count >= minimum compression duration AND abs(release impulse) >= release impulse threshold AND release bias = -1.
Exit: long, wave direction = +1 AND wave age >= minimum exhaustion age AND wave core >= upper exhaustion band AND wave core < previous wave core AND stretch >= exhaustion stretch threshold.
Exit: short, wave direction = -1 AND wave age >= minimum exhaustion age AND wave core <= lower exhaustion band AND wave core > previous wave core AND stretch >= exhaustion stretch threshold.