Calculation: Renko wave = consecutive Renko bars in one direction, using the selected assignment method, assignment value, and price source
Calculation: Wave effort = sum volume across a Renko wave, or true range when selected or automatically substituted for unavailable volume
Calculation: Wave extreme = highest Renko bar body top in an up-wave or lowest Renko bar body bottom in a down-wave
Calculation: Wave result = absolute difference between the first up-wave bar's body bottom or first down-wave bar's body top and the wave extreme
Calculation: Relative change(x) = 100 * (current wave x / previous completed same-direction wave x - 1), unavailable if the previous value is zero or unavailable
Calculation: Change state(x) = 1 if Relative change(x) >= comparison threshold, -1 if <= -comparison threshold, otherwise 0
Calculation: Comparison available = the previous completed same-direction wave has effort and result values
Long: current or completed up-wave AND Comparison available AND Change state(Wave effort) = 1 AND Change state(Wave result) = 1
Long: current or completed up-wave AND Comparison available AND ((Change state(Wave effort) = -1 AND Change state(Wave result) >= 0) OR (Change state(Wave effort) = 0 AND Change state(Wave result) = 1))
Long: current or completed down-wave AND Comparison available AND Change state(Wave effort) = -1 AND Change state(Wave result) = -1
Long: current or completed down-wave AND Comparison available AND ((Change state(Wave effort) = 1 AND Change state(Wave result) <= 0) OR (Change state(Wave effort) = 0 AND Change state(Wave result) = -1))
Long: completed down-wave AND Comparison available AND Change state(Wave effort) = 1 AND (Change state(Wave result) = -1 OR Relative change(Wave result) >= climax extension threshold)
Long: completed down-wave satisfying Change state(Wave effort) = -1 AND Change state(Wave result) = -1 AND Wave extreme above the previous completed down-wave extreme, followed by an up-wave reaching the reversal box count
Long: completed down-wave satisfying Change state(Wave effort) = 1 AND (Change state(Wave result) = -1 OR Relative change(Wave result) >= climax extension threshold), followed by an up-wave reaching the reversal box count and then a completed down-wave with Change state(Wave effort) = -1 AND Change state(Wave result) = -1 AND Wave extreme above the candidate down-wave extreme
Short: current or completed up-wave AND Comparison available AND Change state(Wave effort) = -1 AND Change state(Wave result) = -1
Short: current or completed up-wave AND Comparison available AND ((Change state(Wave effort) = 1 AND Change state(Wave result) <= 0) OR (Change state(Wave effort) = 0 AND Change state(Wave result) = -1))
Short: current or completed down-wave AND Comparison available AND Change state(Wave effort) = 1 AND Change state(Wave result) = 1
Short: current or completed down-wave AND Comparison available AND ((Change state(Wave effort) = -1 AND Change state(Wave result) >= 0) OR (Change state(Wave effort) = 0 AND Change state(Wave result) = 1))
Short: completed up-wave AND Comparison available AND Change state(Wave effort) = 1 AND (Change state(Wave result) = -1 OR Relative change(Wave result) >= climax extension threshold)
Short: completed up-wave satisfying Change state(Wave effort) = -1 AND Change state(Wave result) = -1 AND Wave extreme below the previous completed up-wave extreme, followed by a down-wave reaching the reversal box count
Short: completed up-wave satisfying Change state(Wave effort) = 1 AND (Change state(Wave result) = -1 OR Relative change(Wave result) >= climax extension threshold), followed by a down-wave reaching the reversal box count and then a completed up-wave with Change state(Wave effort) = -1 AND Change state(Wave result) = -1 AND Wave extreme below the candidate up-wave extreme