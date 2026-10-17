# Breakout Strength Analyzer

- url: https://www.tradingview.com/script/e164RNA2-Breakout-Strength-Analyzer/
- type: indicator
- pine_id: PUB;c94b53a33dc041aab7190e3a93ecf4bc
- version: 1.0

## Description

Breakout Strength Analyzer
One of the biggest problems traders face is not knowing whether a breakout is real or fake. Price breaks a level, you enter, and then it immediately reverses against you. This indicator was built to solve exactly that problem by giving you an objective, rule-based scoring system on every single candle so you never have to guess again.
Instead of relying on intuition, the Breakout Strength Analyzer measures four specific factors that separate real breakouts from fake ones and displays the result as a live scorecard directly on your chart.

How It Works
Every candle is evaluated against four rules. Each rule that passes adds one point to the score. The final verdict is displayed in a table in the bottom right corner of your chart.
Rule 1 — Body Size vs ATR
The body of the breakout candle must be at least 1× the Average True Range. A small-bodied candle that barely moves has no conviction behind it. A large-bodied candle that covers more than the average range shows that real buying or selling pressure exists. You can adjust the minimum ratio in the settings.
Rule 2 — Wick Rejection Filter
Even if the candle body is large, a long upper wick is a warning sign. It means price tried to go higher but got pushed back down — a sign of rejection at that level. This rule checks that the upper wick is not disproportionately large compared to the body. If the wick is too large, the rule fails and the score drops.
Rule 3 — ATR Expansion
A real breakout should come with expanding volatility. If the ATR is growing compared to the previous bar, the market is accelerating and there is genuine energy behind the move. If ATR is flat or shrinking, the breakout has no fuel and is likely to fail. The default threshold is 5% expansion, which you can adjust.
Rule 4 — Consecutive Strong Candles
A single strong candle can be a spike. Two or more consecutive strong candles is a pattern. This rule checks how many candles in a row have passed Rule 1, giving you confidence that momentum is building rather than just a one-off move.

Visual Output
Green candle — strong bullish breakout with 3 or more rules passing
Red candle — strong bearish breakout with 3 or more rules passing
Blue candle — body is large enough but full confirmation is missing
Gray candle — weak candle, no breakout signal
A triangle arrow appears below bullish breakouts and above bearish breakouts whenever the score reaches 3 or higher.
A small label appears above each qualifying candle showing the exact Body/ATR ratio so you always know how strong the candle is by the numbers.

Scorecard Table
The bottom right table updates on every candle and shows you each rule individually with a PASS or FAIL result, the exact measured value, and the final score out of 4 with a verdict of STRONG, WEAK, or FAKE.

Settings
ATR Period — number of candles for ATR calculation, default is 14
Min Body / ATR Ratio — minimum body size relative to ATR, default is 1.0
Max Upper Wick / Body Ratio — maximum wick size relative to body, default is 1.5
ATR Expansion % — minimum ATR growth vs previous bar to confirm momentum, default is 5%
Consecutive Strong Candles — how many strong candles in a row are required, default is 2
Show Labels — toggle the Body/ATR ratio labels on candles on or off

Works On
Any asset and any timeframe. Gold, Forex, Crypto, Indices, and Stocks. Best used on the 5 minute, 15 minute, and 1 hour timeframes when combined with a clear horizontal support or resistance level you are watching for a breakout.

Important Note
This indicator scores candle strength objectively. It does not predict the future and should be used as a confirmation tool alongside your own analysis and risk management rules.

## Source Code

````pine
//@version=6
indicator("Breakout Strength Analyzer", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────
atr_period      = input.int(14,    title="ATR Period")
body_threshold  = input.float(1.0, title="Min Body / ATR Ratio", step=0.1)
wick_max_ratio  = input.float(1.5, title="Max Upper Wick / Body Ratio", step=0.1)
atr_exp_pct     = input.float(5.0, title="ATR Expansion % vs Previous", step=1.0)
consec_required = input.int(2,     title="Consecutive Strong Candles Required", minval=1, maxval=5)
show_labels     = input.bool(true,  title="Show Body/ATR Labels on Candles")

// ─── CALCULATIONS ─────────────────────────────────────────
atr_value   = ta.atr(atr_period)
body        = math.abs(close - open)
upper_wick  = high - math.max(close, open)
is_bullish  = close > open

// Rule 1 — Body vs ATR
body_ratio     = body / atr_value
rule_body_pass = body_ratio >= body_threshold

// Rule 2 — Wick rejection filter
wick_ratio     = upper_wick / math.max(body, 0.0001)
rule_wick_pass = wick_ratio <= wick_max_ratio

// Rule 3 — ATR Expansion
atr_expansion  = (atr_value - atr_value[1]) / atr_value[1] * 100
rule_atr_pass  = atr_expansion >= atr_exp_pct

// Rule 4 — Consecutive strong candles
var int consec_count = 0
consec_count := rule_body_pass ? consec_count + 1 : 0
rule_consec_pass = consec_count >= consec_required

// ─── SCORE ────────────────────────────────────────────────
score           = (rule_body_pass ? 1 : 0) + (rule_wick_pass ? 1 : 0) + (rule_atr_pass ? 1 : 0) + (rule_consec_pass ? 1 : 0)
strong_breakout = score >= 3

// ─── CANDLE COLOR ─────────────────────────────────────────
bar_color = strong_breakout and is_bullish ? color.new(color.green, 0) : strong_breakout and not is_bullish ? color.new(color.red, 0) : rule_body_pass ? color.new(color.blue, 40) : color.new(color.gray, 60)
barcolor(bar_color)

// ─── LABELS ───────────────────────────────────────────────
if show_labels and rule_body_pass
    label.new(bar_index, high + atr_value * 0.3, text=str.tostring(body_ratio, "#.##") + "x", color=strong_breakout ? color.green : color.blue, textcolor=color.white, size=size.tiny, style=label.style_label_down)

// ─── ARROWS ───────────────────────────────────────────────
plotshape(strong_breakout and is_bullish,     title="Strong Bullish", location=location.belowbar, style=shape.triangleup,   size=size.small, color=color.green)
plotshape(strong_breakout and not is_bullish, title="Strong Bearish", location=location.abovebar, style=shape.triangledown, size=size.small, color=color.red)

// ─── SCORECARD TABLE ──────────────────────────────────────
var table t = table.new(position.bottom_right, 3, 6, bgcolor=color.new(color.black, 10), border_width=1, border_color=color.gray, frame_color=color.gray, frame_width=1)

pass_color  = color.new(color.green, 20)
fail_color  = color.new(color.red,   20)
na_color    = color.new(color.gray,  20)
header_bg   = color.new(color.gray,  30)

// Header
table.cell(t, 0, 0, "RULE",   text_color=color.white, text_size=size.small, bgcolor=header_bg)
table.cell(t, 1, 0, "VALUE",  text_color=color.white, text_size=size.small, bgcolor=header_bg)
table.cell(t, 2, 0, "RESULT", text_color=color.white, text_size=size.small, bgcolor=header_bg)

// Row 1 — Body vs ATR
table.cell(t, 0, 1, "Body >= " + str.tostring(body_threshold) + "x ATR", text_color=color.white,  text_size=size.tiny)
table.cell(t, 1, 1, str.tostring(body_ratio, "#.##") + "x",               text_color=color.yellow, text_size=size.tiny)
table.cell(t, 2, 1, rule_body_pass ? "PASS" : "FAIL", text_color=color.white, text_size=size.tiny, bgcolor=rule_body_pass ? pass_color : fail_color)

// Row 2 — Wick Rejection
table.cell(t, 0, 2, "Wick <= " + str.tostring(wick_max_ratio) + "x Body", text_color=color.white,  text_size=size.tiny)
table.cell(t, 1, 2, str.tostring(wick_ratio, "#.##") + "x",                text_color=color.yellow, text_size=size.tiny)
table.cell(t, 2, 2, rule_wick_pass ? "PASS" : "FAIL", text_color=color.white, text_size=size.tiny, bgcolor=rule_wick_pass ? pass_color : fail_color)

// Row 3 — ATR Expansion
table.cell(t, 0, 3, "ATR Exp >= " + str.tostring(atr_exp_pct) + "%", text_color=color.white,  text_size=size.tiny)
table.cell(t, 1, 3, str.tostring(atr_expansion, "#.##") + "%",        text_color=color.yellow, text_size=size.tiny)
table.cell(t, 2, 3, rule_atr_pass ? "PASS" : "FAIL", text_color=color.white, text_size=size.tiny, bgcolor=rule_atr_pass ? pass_color : fail_color)

// Row 4 — Consecutive
table.cell(t, 0, 4, "Consecutive >= " + str.tostring(consec_required), text_color=color.white,  text_size=size.tiny)
table.cell(t, 1, 4, str.tostring(consec_count) + " candles",           text_color=color.yellow, text_size=size.tiny)
table.cell(t, 2, 4, rule_consec_pass ? "PASS" : "FAIL", text_color=color.white, text_size=size.tiny, bgcolor=rule_consec_pass ? pass_color : fail_color)

// Row 5 — Final Score
table.cell(t, 0, 5, "SCORE",                      text_color=color.white,  text_size=size.small, bgcolor=header_bg)
table.cell(t, 1, 5, str.tostring(score) + " / 4", text_color=color.yellow, text_size=size.small, bgcolor=header_bg)
table.cell(t, 2, 5, score >= 3 ? "STRONG" : score == 2 ? "WEAK" : "FAKE", text_color=color.white, text_size=size.small, bgcolor=score >= 3 ? pass_color : score == 2 ? na_color : fail_color)
````
