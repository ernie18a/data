Calculation: Daily price change = (current close − previous completed daily close) / previous completed daily close
Calculation: Close position in daily range = (current close − current low) / (current high − current low)
Calculation: Correction low = lowest low since entering Correction
Calculation: Active selling-pressure count = count of Distribution and Stalling events not expired by their configured bar lifetime and not negated by a close reaching their configured recovery level above the event close
Calculation: Distribution event = daily price change <= −decline threshold AND current volume > previous completed daily bar volume
Calculation: Stalling event = 0 < daily price change <= maximum stalling gain AND close position in daily range < maximum close position AND current volume > previous completed daily bar volume AND (daily price change one bar earlier >= prior progress threshold OR daily price change two bars earlier >= prior progress threshold)
Long: In Correction AND current close > previous completed daily close AND current low >= Correction low
Long: In Rally Attempt AND current low >= Rally low AND rally day count after increment >= minimum rally day count AND daily price change >= minimum follow-through gain AND current volume > previous completed daily bar volume
Short: In Confirmed Uptrend AND (Distribution event OR Stalling event)
Short: In Confirmed Uptrend AND current low < Follow-Through Day low
Exit: Long, In Rally Attempt AND current low < Rally low
Exit: Long, In Confirmed Uptrend AND (active selling-pressure count >= correction reset count OR current low < Follow-Through Day low when the optional undercut reset is enabled)