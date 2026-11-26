Calculation: Block open = open of the first bar in the current block, reset at cash-session start and after each completed block
Calculation: Block volume = sum of volume from the first bar in the current block through the current bar
Long: within the cash session AND Block volume >= volume threshold AND close > Block open
Short: within the cash session AND Block volume >= volume threshold AND close < Block open