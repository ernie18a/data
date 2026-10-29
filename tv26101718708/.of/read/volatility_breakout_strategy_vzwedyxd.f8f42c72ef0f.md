Calculation: Long trigger = prior completed daily close + k × (prior completed daily high − prior completed daily low)
Calculation: Long stop = (prior completed daily low + Long trigger) / 2
Calculation: Short trigger = prior completed daily close − k × (prior completed daily high − prior completed daily low)
Calculation: Short stop = (prior completed daily high + Short trigger) / 2
Long: flat AND Long trigger < current bar high AND (trend filter disabled OR Long trigger / Long stop > Short stop / Short trigger)
Short: flat AND Short trigger > current bar low AND (trend filter disabled OR Long trigger / Long stop < Short stop / Short trigger)
Exit: long, prior chart bar's UTC hour − current chart bar's UTC hour > 1 OR current close < Long stop
Exit: short, prior chart bar's UTC hour − current chart bar's UTC hour > 1 OR current close > Short stop