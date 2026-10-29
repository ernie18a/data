Calculation: Fast trend line = weighted sum of five Relative Vigor Index main lines with strictly increasing lookbacks; the third line uses the second line’s weight.
Calculation: Slow trend line = fast trend line divided by the smoothing length plus the previous slow trend line multiplied by (smoothing length − 1) divided by the smoothing length.
Long: On the configured indicator timeframe’s last completed bar, fast trend line > slow trend line AND on the preceding completed bar, fast trend line < slow trend line.
Short: On the configured indicator timeframe’s last completed bar, fast trend line < slow trend line AND on the preceding completed bar, fast trend line > slow trend line.
Exit: Short, on the configured indicator timeframe’s last completed bar, fast trend line > slow trend line.
Exit: Long, on the configured indicator timeframe’s last completed bar, fast trend line < slow trend line.