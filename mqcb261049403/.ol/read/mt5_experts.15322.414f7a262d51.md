Calculation: Bezier = sum over i = 0..BPeriod of applied price from i bars ago × binomial(BPeriod, i) × t^i × (1−t)^(BPeriod−i), where applied price = (2×close + high + low)/4
Calculation: Bezier-change standard deviation = population standard deviation of the last std_period one-bar changes in Bezier, including the latest change
Long: latest Bezier change > dK × Bezier-change standard deviation OR Bezier[3] > Bezier[2] AND Bezier[2] < Bezier[1]
Short: latest Bezier change < −dK × Bezier-change standard deviation OR Bezier[3] < Bezier[2] AND Bezier[2] > Bezier[1]
Exit: long, Bezier[2] > Bezier[1]
Exit: short, Bezier[2] < Bezier[1]