# Macro Panel - Risk-On 0-8 [Galin]

- url: https://www.tradingview.com/script/Upre6obK-Macro-Panel-Risk-On-0-8-Galin/
- type: indicator
- pine_id: PUB;0ea4c68c12b847b78cfffed13f819369
- version: 1.0

## Description

Macro Panel - Risk-On 0-8 [Galin]

What it does
Turns "how's the market feeling?" into a number, computed the same way every single day: eight binary rules, one point each. 8/8 = everything supports risk. 0/8 = nothing does. The panel shows the full checklist with a pass/fail mark per rule and a color-coded header; the score is also plotted as a stepline - a historical regime curve, so you can scroll back and see every transition of the past years. The indicator is symbol-independent: add it to any chart (a daily SPY chart is the natural home) and it reads the market, not the chart.

Why it matters
Setups don't fail because they were bad setups - they fail because they were taken in the wrong market. Position sizing needs a systematic input, and "feel" drifts exactly when it matters most: after a winning streak and during a scary tape. A fixed eight-rule score can't drift. It also can't be argued with at 9:31 AM.

The eight rules - one point each
1. SPY above its 20-day SMA - tactical trend
2. SPY above its 50-day SMA - intermediate trend
3. QQQ above its 20-day SMA - growth participating
4. IWM above its 50-day SMA - small-cap risk appetite
5. RSP beating SPY over 1 month - breadth beneath the megacaps
6. VIX below a threshold (default 20, adjustable) - volatility calm
7. HYG above its 50-day SMA - credit not stressed
8. SPY 1-month return positive - momentum

Four trend rules, one breadth, one volatility, one credit, one momentum - each catches a different way markets break. Oil, gold, the dollar and rates are deliberately NOT in the score: they are context, not gates. A real macro shock shows up through VIX and SPY anyway - counting it twice double-weights fear.

Reading it
The total is the throttle; the composition is the story. A 6/8 missing its trend points (SPY, QQQ) is a different market from a 6/8 missing its insurance points (VIX, HYG): the first says the tape is broken, the second says the tape is fine and the nerves haven't signed off yet. The panel shows you which mark is missing - that's why it displays all eight rows instead of just the sum.

Suggested bands: 7-8 full risk | 5-6 selective | 3-4 half size | 0-2 no new longs. One rule overrides the total: rule 1 off (SPY below its 20-day) = no new entries, whatever the sum says.

Alerts
Three built in: Kill switch - SPY lost its 20-day | Score dropped to 4 or below | Score entered the 7-8 band. The regime calls you; you don't have to check it.

Settings
VIX calm threshold (default 20) | checklist panel on/off | panel position.

Notes
Chart indicator, designed for daily charts. The score plots with dotted band lines at the 7-8 / 5-6 / 3-4 boundaries. Not intended for the Pine Screener - it needs six data requests and the screener allows five.

## Source Code

````pine
//@version=6
// =====================================================================
//  Macro Panel - Risk-On 0-8 [Galin]
//
//  CHART indicator (add it to your SPY daily chart — or any chart,
//  the score is symbol-independent). Not for the Pine Screener: it
//  needs 6 request.*() calls and the screener allows only 5; the
//  screener rows live in the companion "Macro Screener".
//
//  One point per rule, Minervini-template style:
//     1. SPY  > 20-day SMA      (tactical trend / kill-switch line)
//     2. SPY  > 50-day SMA      (intermediate trend)
//     3. QQQ  > 20-day SMA      (growth participating)
//     4. IWM  > 50-day SMA      (small-cap risk appetite)
//     5. RSP beats SPY over 1M  (breadth beneath megacaps)
//     6. VIX  < threshold       (volatility calm, default 20)
//     7. HYG  > 50-day SMA      (credit not stressed)
//     8. SPY 1M return > 0      (momentum positive)
//
//  Bands:  7-8 full risk · 5-6 selective · 3-4 half size · 0-2 no
//  new longs. The hard kill switch stays absolute regardless of the
//  total: SPY closing below the 20-day = pause on new entries.
//
//  The score is also plotted as a stepline — a historical regime
//  curve showing how the market moved between bands over time.
// =====================================================================
indicator("Macro Panel - Risk-On 0-8 [Galin]", overlay = false)

// ── Inputs ────────────────────────────────────────────────────────────
float  vixCalm   = input.float(20.0, "VIX calm threshold", step = 0.5)
bool   showPanel = input.bool(true,  "Show checklist panel")
string tblPos    = input.string("top_right", "Panel position",
     options = ["top_right", "top_left", "bottom_right", "bottom_left", "middle_right", "middle_left"])

// ── Global regime data (6 requests — chart limit is 40) ──────────────
[spyC, spyC21, spyS20, spyS50] = request.security("AMEX:SPY",   "D", [close, close[21], ta.sma(close, 20), ta.sma(close, 50)])
[qqqC, qqqS20]                 = request.security("NASDAQ:QQQ", "D", [close, ta.sma(close, 20)])
[iwmC, iwmS50]                 = request.security("AMEX:IWM",   "D", [close, ta.sma(close, 50)])
[rspC, rspC21]                 = request.security("AMEX:RSP",   "D", [close, close[21]])
vixC                           = request.security("CBOE:VIX",   "D", close)
[hygC, hygS50]                 = request.security("AMEX:HYG",   "D", [close, ta.sma(close, 50)])

// ── Risk-On score ─────────────────────────────────────────────────────
bool p1 = not na(spyS20) and spyC > spyS20
bool p2 = not na(spyS50) and spyC > spyS50
bool p3 = not na(qqqS20) and qqqC > qqqS20
bool p4 = not na(iwmS50) and iwmC > iwmS50
bool p5 = not na(rspC21) and not na(spyC21) and (rspC / rspC21) > (spyC / spyC21)
bool p6 = not na(vixC) and vixC < vixCalm
bool p7 = not na(hygS50) and hygC > hygS50
bool p8 = not na(spyC21) and spyC > spyC21

int score = (p1 ? 1 : 0) + (p2 ? 1 : 0) + (p3 ? 1 : 0) + (p4 ? 1 : 0) +
     (p5 ? 1 : 0) + (p6 ? 1 : 0) + (p7 ? 1 : 0) + (p8 ? 1 : 0)

// ── Regime curve ──────────────────────────────────────────────────────
color scoreCol = score >= 7 ? color.green : score >= 5 ? color.yellow :
     score >= 3 ? color.orange : color.red
plot(score, "RiskOn 0-8", color = scoreCol, linewidth = 2, style = plot.style_stepline)
hline(6.5, "Full-risk band", color = color.new(color.green, 60),  linestyle = hline.style_dotted)
hline(4.5, "Selective band", color = color.new(color.orange, 60), linestyle = hline.style_dotted)
hline(2.5, "Defensive band", color = color.new(color.red, 60),    linestyle = hline.style_dotted)

// ── Checklist panel ───────────────────────────────────────────────────
tablePosition = switch tblPos
    "top_left"     => position.top_left
    "top_right"    => position.top_right
    "bottom_left"  => position.bottom_left
    "bottom_right" => position.bottom_right
    "middle_left"  => position.middle_left
    => position.middle_right

var table t = table.new(tablePosition, 2, 9, border_width = 1)

f_row(int r, string label, bool ok) =>
    table.cell(t, 0, r, label, text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, r, ok ? "✓" : "✗", text_color = color.white,
         bgcolor = ok ? color.new(color.green, 30) : color.new(color.red, 40), text_size = size.small)

if showPanel and barstate.islast
    color hdr = score >= 7 ? color.new(color.green, 10) :
         score >= 4 ? color.new(color.orange, 10) : color.new(color.red, 10)
    table.cell(t, 0, 0, "RISK-ON", text_color = color.white, bgcolor = hdr, text_size = size.normal)
    table.cell(t, 1, 0, str.tostring(score) + "/8", text_color = color.white, bgcolor = hdr, text_size = size.normal)
    f_row(1, "SPY > 20d",        p1)
    f_row(2, "SPY > 50d",        p2)
    f_row(3, "QQQ > 20d",        p3)
    f_row(4, "IWM > 50d",        p4)
    f_row(5, "RSP beats SPY 1M", p5)
    f_row(6, "VIX < " + str.tostring(vixCalm, "#.#"), p6)
    f_row(7, "HYG > 50d",        p7)
    f_row(8, "SPY 1M > 0",       p8)

// ── Alerts ────────────────────────────────────────────────────────────
alertcondition(not p1 and p1[1], "Kill switch: SPY lost 20d", "SPY closed/trading below its 20-day SMA")
alertcondition(score <= 4 and score[1] > 4, "RiskOn dropped to 4 or below", "Market regime score fell into the defensive band")
alertcondition(score >= 7 and score[1] < 7, "RiskOn entered 7-8 band", "Market regime score entered the full-risk band")
````
