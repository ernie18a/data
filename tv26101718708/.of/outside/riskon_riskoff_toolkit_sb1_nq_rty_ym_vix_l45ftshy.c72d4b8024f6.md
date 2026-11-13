Per bar, on the chart's timeframe, read the current bar of three outside equity-index futures (Nasdaq-100, Russell 2000, Dow) and the VIX index. Classify each futures contract as bullish if its bar close is above its bar open, or bearish if its close is below its open. Classify VIX as falling if its current close is below its previous bar's close, or rising if above.

Risk-On means all three futures are bullish and VIX is falling. Risk-Off means all three are bearish and VIX is rising. If neither holds, the state is out of alignment (mixed), which is a neutral, no-signal state. It can be used to stand aside or exit, because the source defines no explicit exit rule.

Long bias: Risk-On is active. Short bias: Risk-Off is active.

Entry confirmation uses the traded chart instrument's own current bar. A strong bullish candle has a bullish close above open, a body that is at least a configurable high fraction of the high-low range, and a close within a small configurable fraction of the range from the high. A strong bearish candle is the mirror image: close below open, a large body, and a close near the low.

High-confidence long: a strong bullish candle on the traded instrument while Risk-On is active. High-confidence short: a strong bearish candle while Risk-Off is active. Without the candle condition, the Risk-On or Risk-Off state alone is the broader long or short context. No options logic, stops, targets or sizing are defined.