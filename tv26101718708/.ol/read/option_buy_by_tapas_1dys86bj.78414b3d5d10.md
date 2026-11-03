Calculation: Heikin-Ashi close = (open + high + low + close) / 4
Calculation: Heikin-Ashi open = (previous Heikin-Ashi open + previous Heikin-Ashi close) / 2; for the first bar, (open + close) / 2
Calculation: Heikin-Ashi low = min(low, Heikin-Ashi open, Heikin-Ashi close)
Calculation: Smoothed stochastic oscillator = moving average of the stochastic oscillator
Calculation: Setup entry price = close of the bar that creates the setup
Calculation: Stop price = Heikin-Ashi low of the setup’s qualifying red bar that touched or crossed below the Bollinger lower band
Calculation: Target price = setup entry price + reward multiple × (setup entry price − stop price)
Long: An unfilled setup is active AND close crosses above its setup entry price AND ((the setup was created in the first entry session after either the previous bar or the bar before it had Heikin-Ashi close < Heikin-Ashi open and Heikin-Ashi low <= Bollinger lower band, and the current bar has Heikin-Ashi close > Heikin-Ashi open) OR (the same setup conditions hold in the second entry session AND the smoothed stochastic oscillator < its threshold))
Exit: Long, high >= target price OR close <= stop price OR current time is at or after the configured square-off time OR outside the market session