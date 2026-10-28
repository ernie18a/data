Calculation: Range high = rolling highest high over the range lookback, including the current bar
Calculation: Range low = rolling lowest low over the range lookback, including the current bar
Calculation: Midpoint = (range high + range low) / 2
Calculation: Profile bins = divide the current range into price bins; allocate each candle’s volume to bins in proportion to its overlap with the bin, and allocate buy/sell volume using candle direction and body/wick proportions
Calculation: POC = bin with the greatest volume; HVN = bin volume at or above the configured fraction of POC volume; LVN = bin volume at or below the configured fraction of POC volume
Calculation: Bottom-edge rejection = bottom bin is an HVN with buy volume greater than sell volume, or bottom bin is an LVN with a bullish node within the configured scan depth above it; a bullish node is an HVN with buy volume greater than sell volume, or has buy volume greater than the configured multiple of sell volume and volume greater than the configured fraction of POC volume
Calculation: Top-edge rejection = top bin is an HVN with sell volume greater than buy volume, or top bin is an LVN with a bearish node within the configured scan depth below it; a bearish node is an HVN with sell volume greater than buy volume, or has sell volume greater than the configured multiple of buy volume and volume greater than the configured fraction of POC volume
Calculation: Bottom-edge acceptance = bottom bin is an HVN and buy volume is less than or equal to sell volume
Calculation: Top-edge acceptance = top bin is an HVN and sell volume is less than or equal to buy volume
Long: close < midpoint AND bottom-edge rejection
Long: close < midpoint AND midpoint > midpoint[1] AND NOT (midpoint[1] > midpoint[2])
Short: close > midpoint AND top-edge rejection
Short: close > midpoint AND midpoint < midpoint[1] AND NOT (midpoint[1] < midpoint[2])
Exit: long, bottom-edge acceptance OR range low < previous range low
Exit: short, top-edge acceptance OR range high > previous range high