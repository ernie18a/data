Calculation: Volume delta = volume × (2 × close − high − low) / (high − low); use zero when high equals low.
Calculation: Cumulative volume delta = running sum of volume delta, optionally reset to the current bar's delta at the start of each day on intraday charts or at the start of each week; otherwise never reset.
Calculation: Confirmed pivot high or low = a bar whose high or low is respectively at least as high or at least as low as each of a specified number of preceding bars and strictly higher or lower than each of the same number of following bars; the pivot is confirmed on the last following bar.
Long: Volume delta >= 0.
Short: Volume delta < 0.
Long: Cumulative volume delta >= 0.
Short: Cumulative volume delta < 0.
Long: Cumulative volume delta >= previous bar's cumulative volume delta.
Short: Cumulative volume delta < previous bar's cumulative volume delta.
Long: Cumulative volume delta crosses above zero.
Short: Cumulative volume delta crosses below zero.
Long: Volume > simple moving average of volume × a multiplier AND absolute value of close − open < average true range × a multiplier AND volume delta >= 0.
Short: Volume > simple moving average of volume × a multiplier AND absolute value of close − open < average true range × a multiplier AND volume delta < 0.
Long: A pivot low is confirmed AND its low < the preceding confirmed pivot low AND cumulative volume delta at that pivot > cumulative volume delta at the preceding confirmed pivot low.
Short: A pivot high is confirmed AND its high > the preceding confirmed pivot high AND cumulative volume delta at that pivot < cumulative volume delta at the preceding confirmed pivot high.