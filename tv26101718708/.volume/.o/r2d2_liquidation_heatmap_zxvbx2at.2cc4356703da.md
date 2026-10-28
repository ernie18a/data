Calculation: Long liquidation cluster = a pivot low’s price and pivot volume, combining the volume of active long liquidation levels within the cluster tolerance
Calculation: Short liquidation cluster = a pivot high’s price and pivot volume, combining the volume of active short liquidation levels within the cluster tolerance
Calculation: Intensity threshold = the longer-lookback moving average of volume multiplied by an intensity multiplier
Long: low <= an active long liquidation cluster price AND close > that price AND cluster strength >= intensity threshold
Exit: long, high >= an active short liquidation cluster price AND cluster strength >= two-thirds of the intensity threshold