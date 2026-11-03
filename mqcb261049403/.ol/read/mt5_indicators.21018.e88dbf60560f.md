Calculation: Bull count = number of XMA series, across a sequence of progressively longer lookbacks, whose current value is greater than its previous-bar value; each XMA is the selected smoothing method applied to a double linear weighted moving average of the selected applied price.
Calculation: Bear count = number of XMA series in that sequence whose current value is less than or equal to its previous-bar value.
Calculation: Smoothed bull count = selected smoothing method applied to bull count.
Calculation: Smoothed bear count = selected smoothing method applied to bear count.
Long: Smoothed bull count > smoothed bear count
Short: Smoothed bull count < smoothed bear count