Calculation: Pivot = (high + low + close) / 3 from the last completed selected daily, weekly, or monthly bar
Calculation: Resistance 1/2 = Pivot + 0.382/0.618 × (high − low) from the last completed selected daily, weekly, or monthly bar
Calculation: Support 1/2 = Pivot − 0.382/0.618 × (high − low) from the last completed selected daily, weekly, or monthly bar
Long: Close crosses above Pivot OR Close is above Pivot for the configured consecutive bar count; after the configured signal delay, the last accepted signal is not long (unless same-direction blocking is disabled) AND bars since the last accepted long signal ≥ the configured wait
Short: Close crosses below Pivot OR Close is below Pivot for the configured consecutive bar count; after the configured signal delay, the last accepted signal is not short (unless same-direction blocking is disabled) AND bars since the last accepted short signal ≥ the configured wait
Exit: long, short-entry condition OR high crosses above Resistance 1 (once per position) OR high crosses above Resistance 2
Exit: short, long-entry condition OR low crosses below Support 1 (once per position) OR low crosses below Support 2