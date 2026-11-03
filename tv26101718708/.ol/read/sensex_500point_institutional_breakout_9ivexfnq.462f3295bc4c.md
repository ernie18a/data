Calculation: Lower round-number level = floor of the 9:45 bar open divided by the configured increment, multiplied by the increment
Calculation: Upper round-number level = ceiling of the 9:45 bar open divided by the configured increment, multiplied by the increment
Calculation: Long target = upper round-number level + configured increment
Calculation: Short target = lower round-number level - configured increment
Calculation: Active stop = entry signal bar close minus configured stop distance for a long, or plus configured stop distance for a short; once the high reaches entry price plus the configured break-even trigger for a long, or the low reaches entry price minus that trigger for a short, set the active stop to entry price
Long: close >= upper round-number level AND time is within 09:45–15:15 AND time is not 09:45 AND position is flat AND daily trade count < configured maximum
Short: close <= lower round-number level AND time is within 09:45–15:15 AND time is not 09:45 AND position is flat AND daily trade count < configured maximum
Exit: long, high >= long target OR low <= active stop OR time is within 15:25–15:30
Exit: short, low <= short target OR high >= active stop OR time is within 15:25–15:30