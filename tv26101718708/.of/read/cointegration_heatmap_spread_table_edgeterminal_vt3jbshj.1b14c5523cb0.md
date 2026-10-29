Calculation: aligned return = percent change in each asset’s dividend-adjusted close, sampled from the last completed bar of the higher return-sampling timeframe
Calculation: regression residual = quoted asset’s aligned return − (intercept + slope × base asset’s aligned return), where slope and intercept are from a linear regression of quoted-asset returns on base-asset returns over the available sample
Calculation: spread z-score = latest regression residual’s deviation from the recent residual mean, divided by the recent residual standard deviation
Long: spread z-score is below the lower entry threshold; long the quoted asset and short the base asset
Short: spread z-score is above the upper entry threshold; short the quoted asset and long the base asset
Exit: long spread position, spread z-score reaches or crosses zero
Exit: short spread position, spread z-score reaches or crosses zero