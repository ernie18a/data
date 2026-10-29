Calculation: JCCX = JurX-smoothed (price − JJMA-smoothed price) / JurX-smoothed absolute(price − JJMA-smoothed price), clamped to [−1, 1].
Calculation: JCCX difference = shorter-period JCCX − longer-period JCCX.
Calculation: Schaff cycle = normalize the JCCX difference to 0–100 over a rolling lookback; smooth with 0.5 × current raw value + 0.5 × previous smoothed value; normalize that result to −100–100 over the same lookback; smooth again with the same formula.
Long: On the indicator timeframe, the last completed bar's Schaff cycle > 0 AND the immediately preceding completed bar's Schaff cycle <= 0.
Short: On the indicator timeframe, the last completed bar's Schaff cycle < 0 AND the immediately preceding completed bar's Schaff cycle >= 0.
Exit: Long, the last completed bar's Schaff cycle < 0 on the indicator timeframe.
Exit: Short, the last completed bar's Schaff cycle > 0 on the indicator timeframe.