Long: Williams %R < -80 AND fast EMA > slow EMA
Long: previous-bar Williams %R < -80 AND current Williams %R > -80 AND fast EMA > slow EMA
Long: current close > fast EMA AND previous-bar Williams %R < -80 AND current Williams %R > -80 AND fast EMA > slow EMA AND flat position AND long entries enabled AND within configured date range AND (no sessions enabled OR within an enabled session)
Short: Williams %R > -20 AND fast EMA < slow EMA
Short: previous-bar Williams %R > -20 AND current Williams %R < -20 AND fast EMA < slow EMA
Short: current close < fast EMA AND previous-bar Williams %R > -20 AND current Williams %R < -20 AND fast EMA < slow EMA AND flat position AND short entries enabled AND within configured date range AND (no sessions enabled OR within an enabled session)
Calculation: Long stop loss = lower of current-bar low and previous-bar low minus ATR buffer
Calculation: Short stop loss = higher of current-bar high and previous-bar high plus ATR buffer
Calculation: ATR buffer = EMA of true range over a lookback × buffer multiplier
Calculation: Long take profit = entry price + (entry price − long stop loss) × risk/reward ratio
Calculation: Short take profit = entry price − (short stop loss − entry price) × risk/reward ratio
Exit: long, current low ≤ long stop loss OR current high ≥ long take profit
Exit: short, current high ≥ short stop loss OR current low ≤ short take profit