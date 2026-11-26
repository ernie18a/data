Long: SlopeDirectionLine(parameters) > SlopeDirectionLine(parameters)[1]
Short: SlopeDirectionLine(parameters) < SlopeDirectionLine(parameters)[1]
Long: SlopeDirectionLine(parameters)[signal-bar offset] > SlopeDirectionLine(parameters)[signal-bar offset + 1] AND SlopeDirectionLine(parameters)[signal-bar offset + 1] <= SlopeDirectionLine(parameters)[signal-bar offset + 2]
Short: SlopeDirectionLine(parameters)[signal-bar offset] < SlopeDirectionLine(parameters)[signal-bar offset + 1] AND SlopeDirectionLine(parameters)[signal-bar offset + 1] >= SlopeDirectionLine(parameters)[signal-bar offset + 2]
Long: On chart bars using T1 values, SlopeDirectionLine(parameters, T1, bar still forming) >= SlopeDirectionLine(parameters, T1, last completed bar)
Short: On chart bars using T1 values, SlopeDirectionLine(parameters, T1, bar still forming) < SlopeDirectionLine(parameters, T1, last completed bar)
Long: On chart bars using T1 values, SlopeDirectionLine(parameters, T1, last completed bar) >= SlopeDirectionLine(parameters, T1, 2 bars ago)
Short: On chart bars using T1 values, SlopeDirectionLine(parameters, T1, last completed bar) < SlopeDirectionLine(parameters, T1, 2 bars ago)
Long: On chart bars using T1 values, SlopeDirectionLine(parameters, T1, 2 bars ago) >= SlopeDirectionLine(parameters, T1, 3 bars ago)
Short: On chart bars using T1 values, SlopeDirectionLine(parameters, T1, 2 bars ago) < SlopeDirectionLine(parameters, T1, 3 bars ago)