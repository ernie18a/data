Calculation: Reference return = 100 × close of the last completed T1 bar for the first basket leg / close of the preceding completed T1 bar for the first basket leg − 100, sampled on chart bars
Calculation: Basket leg side = long, long, short, long in configured basket order when reference return > 0; short, short, long, short when reference return < 0; undefined when reference return = 0
Calculation: Position profit in points = (close − entry price) / point size for long positions; (entry price − close) / point size for short positions
Calculation: Basket profit in points = sum of position profit in points across all open basket positions
Long: trading enabled AND broker hour = entry-hour parameter AND broker minute is between the entry-minute parameters, inclusive AND no basket positions are open AND this leg's basket side is long
Short: trading enabled AND broker hour = entry-hour parameter AND broker minute is between the entry-minute parameters, inclusive AND no basket positions are open AND this leg's basket side is short
Exit: long, broker hour >= exit-hour parameter
Exit: short, broker hour >= exit-hour parameter
Exit: long, profit monitoring enabled AND profit-target exit enabled AND basket profit in points >= profit-target parameter
Exit: short, profit monitoring enabled AND profit-target exit enabled AND basket profit in points >= profit-target parameter
Exit: long, profit monitoring enabled AND loss-limit exit enabled AND basket profit in points <= −loss-limit parameter
Exit: short, profit monitoring enabled AND loss-limit exit enabled AND basket profit in points <= −loss-limit parameter
Long: profit monitoring enabled AND emergency cloning enabled AND emergency cloning has not occurred since the latest entry window AND basket profit in points <= −emergency-loss parameter AND an open non-emergency long position has position profit in points > 0
Short: profit monitoring enabled AND emergency cloning enabled AND emergency cloning has not occurred since the latest entry window AND basket profit in points <= −emergency-loss parameter AND an open non-emergency short position has position profit in points > 0