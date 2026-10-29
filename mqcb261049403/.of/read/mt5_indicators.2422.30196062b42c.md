Calculation: HLM = the difference between upward high momentum and downward low momentum, where upward high momentum is max(current high − high N bars ago, 0), downward low momentum is max(low N bars ago − current low, 0); apply three successive configured smoothing stages to this difference.
Calculation: Signal line = apply a fourth configured smoothing stage to HLM.
Long: HLM > 0 OR HLM > Signal line
Short: HLM < 0 OR HLM < Signal line