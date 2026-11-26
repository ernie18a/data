Calculation: JMA slope = JMA(applied price, smoothing length, phase) - JMA(applied price, smoothing length, phase)[1]
Long: JMA slope[1] > 0 AND JMA slope <= 0
Short: JMA slope[1] < 0 AND JMA slope >= 0
Exit: long, JMA slope[1] < 0
Exit: short, JMA slope[1] > 0
Long: JMA slope[1] < JMA slope[2] AND JMA slope > JMA slope[1]
Short: JMA slope[1] > JMA slope[2] AND JMA slope < JMA slope[1]
Exit: long, JMA slope[1] < JMA slope[2]
Exit: short, JMA slope[1] > JMA slope[2]
Long: JMA slope > 0
Short: JMA slope < 0