Calculation: sampled body(k) = close of the T1 bar at offset interval × k − open of that bar; k=0 is the forming bar
Calculation: long possibility(k) = −sampled body(k) when sampled body(k) < 0 and sampled body(k+1) > 0; otherwise 0
Calculation: short possibility(k) = sampled body(k) when sampled body(k) > 0 and sampled body(k+1) < 0; otherwise 0
Calculation: long success mean = mean of long possibility(k) values greater than spread over the model lookback
Calculation: short success mean = mean of short possibility(k) values greater than spread over the model lookback
Calculation: long total = sum of long possibility(k) over the model lookback
Calculation: short total = sum of short possibility(k) over the model lookback
Calculation: long success total = sum of long possibility(k) values greater than spread over the model lookback
Calculation: short success total = sum of short possibility(k) values greater than spread over the model lookback
Long: sampled body(0) < 0 AND sampled body(1) > 0
Short: sampled body(0) > 0 AND sampled body(1) < 0
Long: sampled body(0) < 0 AND sampled body(1) > 0 AND long possibility(0) >= long success mean AND ((interval > prior interval AND short total < long total AND short success total >= long success total) OR (interval = prior interval AND short total != long total)) AND (long possibility(0) <= 2 × long success mean OR long success mean = 0)
Short: sampled body(0) > 0 AND sampled body(1) < 0 AND short possibility(0) >= short success mean AND ((interval > prior interval AND short total > long total AND short success total <= long success total) OR (interval = prior interval AND short total != long total)) AND (short possibility(0) <= 2 × short success mean OR short success mean = 0)
Long: sampled body(0) > 0 AND sampled body(1) < 0 AND (close of the forming T1 bar − close of the T1 bar at offset interval) / momentum parameter >= short success mean AND short success mean > 0
Short: sampled body(0) < 0 AND sampled body(1) > 0 AND (close of the T1 bar at offset interval − close of the forming T1 bar) / momentum parameter >= long success mean AND long success mean > 0
Long: there exists an integer n from 1 through interval such that close of the forming T1 bar − close of the T1 bar n bars ago > short success mean × n AND short success mean > 0 AND ((interval > prior interval AND short total < long total AND short success total >= long success total) OR (interval = prior interval AND short total != long total)) AND (long possibility(0) <= 2 × long success mean OR long success mean = 0)
Short: there exists an integer n from 1 through interval such that close of the T1 bar n bars ago − close of the forming T1 bar > long success mean × n AND long success mean > 0 AND ((interval > prior interval AND short total > long total AND short success total <= long success total) OR (interval = prior interval AND short total != long total)) AND (short possibility(0) <= 2 × short success mean OR short success mean = 0)
Exit: long, close of the forming T1 bar > entry price
Exit: short, close of the forming T1 bar < entry price