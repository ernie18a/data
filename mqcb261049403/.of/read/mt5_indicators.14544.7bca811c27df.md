Calculation: Momentum oscillator = 100 × clamp(smooth(change in selected bar price) / smooth(absolute change in selected bar price), −1, 1), using the same smoothing method and parameters for both series; undefined when the denominator is zero.
Calculation: Step line = for oscillator scaled to (momentum oscillator + 100) / 2 and step size s, initialize previous lower bound to +999999, previous upper bound to −999999, and direction to 0. On each bar set lower = oscillator − 2s and upper = oscillator + 2s; set direction to +1 if oscillator > previous upper, or −1 if oscillator < previous lower, otherwise retain direction. If direction is +1, set lower = max(lower, previous lower) and line = lower + s; if direction is −1, set upper = min(upper, previous upper) and line = upper − s. Save both bounds for the next bar. The fast step line uses a smaller step size than the slow step line.
Calculation: Signal line = separately smoothed momentum oscillator, using a shorter smoothing period than the oscillator.
Long: fast step line > slow step line
Short: fast step line < slow step line
Long: momentum oscillator > momentum oscillator on the previous bar AND momentum oscillator != 0
Short: momentum oscillator < momentum oscillator on the previous bar AND momentum oscillator != 0
Long: momentum oscillator > signal line on the previous bar
Short: momentum oscillator < signal line on the previous bar