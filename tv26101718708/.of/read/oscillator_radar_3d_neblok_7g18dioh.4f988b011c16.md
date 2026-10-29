Calculation: Composite = arithmetic mean of the enabled oscillator values after each is clamped to 0–100 and optionally EMA-smoothed.
Calculation: Bull-zone count = number of enabled oscillator values at or above the configured bull-zone level.
Calculation: Bear-zone count = number of enabled oscillator values at or below the configured bear-zone level.
Long: Composite > 50 OR Composite > 50 AND previous Composite <= 50 OR Composite >= 55 OR Bull-zone count >= configured confluence count AND previous Bull-zone count < configured confluence count
Short: Composite < 50 OR Composite < 50 AND previous Composite >= 50 OR Composite <= 45 OR Bear-zone count >= configured confluence count AND previous Bear-zone count < configured confluence count