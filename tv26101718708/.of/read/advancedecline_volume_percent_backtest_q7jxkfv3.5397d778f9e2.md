Calculation: Net advancing volume = advancing-volume close at the configured resolution minus declining-volume close at the configured resolution
Calculation: AD volume percent = (current net advancing volume − previous net advancing volume) × 100 / (current advancing-volume close + current declining-volume close)
Calculation: AD state = 1 when AD volume percent is above the upper threshold, −1 when it is below the lower threshold, otherwise the previous AD state (initially 0)
Long: (reverse is disabled AND AD state = 1) OR (reverse is enabled AND AD state = −1)
Short: (reverse is disabled AND AD state = −1) OR (reverse is enabled AND AD state = 1)
Exit: Long, (reverse is disabled AND AD state = −1) OR (reverse is enabled AND AD state = 1)
Exit: Short, (reverse is disabled AND AD state = 1) OR (reverse is enabled AND AD state = −1)