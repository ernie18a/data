Calculation: TICK = advancing constituent count minus declining constituent count on the chart timeframe
Calculation: Cumulative TICK = running sum of TICK during the session, reset at session start
Calculation: Advancing-volume percentage = advancing constituents' total volume as a percentage of all constituents' total volume
Calculation: Advancing percentage = advancing constituent count as a percentage of all constituents
Calculation: A/D thrust = EMA-smoothed advancing-minus-declining constituent count divided by total constituent count
Calculation: Composite breadth score = weighted combination of normalized TICK, cumulative TICK, A/D thrust, advancing-volume percentage, and advancing percentage
Long: TICK is in a bullish tier OR cumulative TICK is in a bullish tier OR advancing-volume percentage is in a bullish tier OR advancing percentage is in a bullish tier OR A/D thrust is in a bullish tier OR composite breadth score is at least mildly bullish
Short: TICK is in a bearish tier OR cumulative TICK is in a bearish tier OR advancing-volume percentage is in a bearish tier OR advancing percentage is in a bearish tier OR A/D thrust is in a bearish tier OR composite breadth score is at least mildly bearish