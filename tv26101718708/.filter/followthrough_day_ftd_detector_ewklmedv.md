# Follow-Through Day (FTD) Detector

- url: https://www.tradingview.com/script/EWklMEDv-Follow-Through-Day-FTD-Detector/
- type: indicator
- pine_id: PUB;5997bf3d583c4d94b8517005aae32fe2
- version: 1.0

## Description

📈 Follow-Through Day (FTD) Detector
Marks Follow-Through Days on any chart using the classic William O'Neil / IBD methodology — a signal that a correction may be turning into a new uptrend attempt.
🔍 How it works
The script tracks rally attempts bar-by-bar. A rally begins when price is at or near a recent low (default 15-bar lookback) and closes up — that's Day 1. From there, the counter advances each bar. An FTD fires when, on day 4 or later of the attempt, the instrument closes up by at least the gain threshold (default 1.5%) on volume greater than the prior bar. If the rally's starting low is undercut before an FTD prints, the attempt resets.
🎨 On the chart

Green triangle below the bar on the FTD
Orange dot marking Day 1 of each rally attempt
Light blue background across the duration of an active attempt
Built-in alert condition

⚙️ Inputs

Minimum gain % (default 1.5 — IBD historically used 1.7%)
Earliest and latest day of the rally count (default 4 to 25)
Toggle for the higher-volume requirement
Lookback window for the recent-low check
Toggles for each visual element

✅ Pros

Faithful to the original rules, but fully parameterized
Works on any symbol and timeframe
Rally shading makes the setup visible in real time, not only after the signal fires
Clean state machine — no lookahead, no repainting

⚠️ Cons and caveats

FTDs are a probabilistic signal. Historically a meaningful share fail, and the script does not attempt to filter good vs bad ones
On cash indices like SPX, TradingView's volume is aggregated and can be noisy — disable the volume requirement or apply the indicator to SPY / ES futures
The rally-low reset uses the low of the first two bars of the attempt; a deeper correction low further back in the sell-off isn't tracked
Purely mechanical — doesn't incorporate market breadth, leadership, or distribution days, which IBD treats as essential companions
Defaults are a starting point, not a tuned edge. Backtest before trading off it

Feedback and suggestions welcome.

## Source Code

````pine
//@version=5
indicator("Follow-Through Day (FTD)", "FTD", overlay=true)

// ============= Inputs =============
grp1 = "FTD Criteria"
minGain = input.float(1.5, "Minimum Gain %", minval=0.5, step=0.1, group=grp1,
     tooltip="IBD traditionally used 1.7%. Some use 1.25–1.5% for modern markets.")
minDay  = input.int(4,  "Earliest Day of Rally", minval=4, group=grp1,
     tooltip="FTDs occur on day 4 or later of a rally attempt.")
maxDay  = input.int(25, "Latest Day of Rally", minval=10, group=grp1,
     tooltip="If no FTD by this day, the rally attempt is abandoned.")
needVol = input.bool(true, "Require Higher Volume than Prior Day", group=grp1,
     tooltip="Classic FTD rule. Turn off if the chart has no volume.")

grp2 = "Rally Detection"
lowLen = input.int(15, "Lookback Bars for Recent Low", minval=5, group=grp2,
     tooltip="Day 1 must be at/near the low of this window (i.e. in a correction).")

grp3 = "Display"
showFTD  = input.bool(true, "Mark FTD",            group=grp3)
showDay1 = input.bool(true, "Mark Rally Day 1",    group=grp3)
showBG   = input.bool(true, "Shade Rally Attempt", group=grp3)

// ============= State =============
var int   dayCount = 0
var float rallyLow = na

// ============= Rally-Attempt Logic =============
recentLow = ta.lowest(low, lowLen)[1]
atLow     = low <= recentLow or low[1] <= recentLow
upClose   = close > close[1]
undercut  = not na(rallyLow) and low < rallyLow

// Reset if Day-1 low is undercut or rally has gone too long
if undercut or dayCount > maxDay
    dayCount := 0
    rallyLow := na

// Start a new rally attempt, or advance the counter
if dayCount == 0 and upClose and atLow
    dayCount := 1
    rallyLow := math.min(low, low[1])
else if dayCount >= 1
    dayCount += 1

// ============= FTD Check =============
gainPct = (close - close[1]) / close[1] * 100
volHigh = volume > volume[1]
isFTD   = dayCount >= minDay and dayCount <= maxDay and gainPct >= minGain and (not needVol or volHigh)

// ============= Plots =============
plotshape(showFTD and isFTD, "FTD", shape.triangleup, location.belowbar,
     color.new(color.green, 0), size=size.normal, text="FTD", textcolor=color.white)

rallyStart = dayCount == 1 and nz(dayCount[1]) != 1
plotshape(showDay1 and rallyStart, "Rally Day 1", shape.circle, location.belowbar,
     color.new(color.orange, 30), size=size.tiny)

bgcolor(showBG and dayCount > 0 ? color.new(color.blue, 92) : na, title="Rally Attempt")

// ============= Alert =============
alertcondition(isFTD, "Follow-Through Day", "Follow-Through Day on {{ticker}} ({{interval}})")
````
