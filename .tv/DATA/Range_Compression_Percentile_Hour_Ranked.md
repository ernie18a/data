<!-- tradingview-pine-id: PUB;ad72c44c0ea94fe58e4fb693a43f8b59 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Range Compression Percentile - Hour Ranked

Source: https://www.tradingview.com/script/rtnp7iJr/

## Description

This indicator gives no directional signal. It answers a single question: will the amplitude of the coming hours be large enough to be worth paying a round turn?

What makes it different

Intraday amplitude on a futures contract varies by a factor of 3 to 4 across the trading day. Any absolute threshold — "range below 50 points means compression" — therefore mostly measures what time it is, not the state of the market. A quiet 10:00 in New York and a busy 02:00 can show the same raw range while meaning opposite things.

This script ranks the current range as a percentile against the history of the same hour of the day. That hour-for-hour ranking is the part I have not seen elsewhere, and it is what makes the reading comparable at any time of day.

How it is calculated

The range of the last N bars (default 78, which is 6h30 on a 5-minute chart, one full RTH session) is measured as (highest high − lowest low) / close, expressed in basis points so it is comparable across instruments and across price levels.
Once per elapsed hour, that value is stored in a circular buffer belonging to that hour of the day. Each of the 24 hours keeps its own history, 120 observations by default — roughly six months of sessions.
The current range is then ranked against that hour's stored history. The result is a percentile from 0 to 100, plotted as a histogram and coloured by quintile.
A second reading divides the current range by a user-supplied round-turn cost, giving an amplitude-to-cost ratio.
What the measurements show

Tested on MNQ 5-minute data (12 months, 317 sessions) and GC 5-minute data (5.6 years, 1,737 sessions). Range of the following 2 hours, grouped by the quintile this indicator reports, computed causally — ranking only against hours already elapsed, exactly as the script does live:

MNQ: 39.3 / 43.4 / 47.0 / 53.8 / 64.4 bp from Q1 to Q5
GC: 35.2 / 37.9 / 41.0 / 44.2 / 59.8 bp from Q1 to Q5
Monotonic on both instruments. The bottom quintile runs at roughly 0.6x the amplitude of the top quintile.

The effect also survives a control for the last hour's range, which is the amplitude predictor already widely known: adding the compression indicator to a regression already containing the one-hour range gives it a coefficient of −10.65 bp (t = −8.65) on MNQ and −4.58 bp (t = −7.27) on gold, with hour-of-day fixed effects and standard errors clustered by session.

The result runs against the common belief. Compression does not announce expansion here. It announces more quiet.

What it does not do

It carries no directional information, and I would rather state that plainly than let the histogram suggest otherwise. On the same samples, the signed return of the 2 hours following a compression is indistinguishable from zero (MNQ −0.47 bp, t = −0.55). A range breakout traded as a symmetric bracket loses about the same amount whether traded with the break or against it (−0.241 R versus −0.258 R) — two opposite directions losing the same amount is what no information looks like.

Use it to decide whether conditions are worth trading, never which way.

How to use it

Bottom quintile (red, below 20): the next hours are likely to stay quieter than usual for this time of day. Fixed costs buy less movement.
Top quintile (green, above 80): wide amplitude relative to this hour.
The amplitude-to-cost ratio is the absolute check, and it is independent of the percentile. A market can be compressed for its hour and still offer plenty of room. Both readings are shown because they answer different questions.
Settings

Range window: number of bars in the measured range. 78 is the value the effect was measured on.
Closed bars only: freezes the range on the previous bar so the value stops moving inside the forming bar.
Reference time zone: used only to split the day into hours.
Observations kept per hour, and minimum before displaying: control how much history is required before a percentile is shown.
Round-turn cost in basis points: commission plus slippage against notional. Reference points measured on micro futures: MNQ 0.98, MES 1.89, MYM 2.06, MGC 3.00 to 3.44 depending on the price of gold. This figure depends on price and is never constant over time, so it is an input rather than a constant.
Notes and limitations

No repainting. The percentile is computed only against hours that are over and closed.
The indicator needs history before it displays anything: 20 observations for a given hour by default, so about 20 sessions.
The numbers quoted above come from two instruments over the periods stated. They are measurements on that data, not a guarantee of future behaviour.
Designed and measured on 5-minute futures charts. On other timeframes or asset classes the window length should be reconsidered.

---

## Source Code

````pine
//@version=6
// =============================================================================
//  RANGE COMPRESSION PERCENTILE - HOUR-RANKED
//
//  WHAT IT DOES
//  This indicator gives no direction. It answers one question only:
//  "will the amplitude of the next few hours be large enough to pay for a
//  round turn?"
//
//  WHY RANK BY HOUR
//  Intraday amplitude on a futures contract varies by a factor of 3 to 4 across
//  the day. An absolute threshold ("range < 50 points = compression") therefore
//  measures what time it is, not the state of the market. Here the current range
//  is ranked as a percentile AGAINST THE HISTORY OF THE SAME HOUR, which removes
//  the hour-of-day structure entirely. That ranking is the original part.
//
//  WHAT WAS MEASURED
//  On MNQ 5 min (12 months, 317 sessions) and GC 5 min (5.6 years, 1,737
//  sessions), ranking over the full sample: when the range of the last 78 bars
//  sits in the bottom quintile of its own hour, the range of the next 2 hours is
//  0.57x normal on MNQ and 0.63x on gold, hour for hour. The effect SURVIVES a
//  control for the last hour's range - the amplitude predictor already known -
//  with a coefficient of -10.65 bp (t = -8.65) on MNQ and -4.58 bp (t = -7.27)
//  on gold.
//
//  WHAT THIS SCRIPT ACTUALLY PRODUCES
//  The figures above come from an offline study ranking against the whole
//  sample. This script is causal: it ranks only against hours already elapsed,
//  using a rolling buffer. It is therefore weaker, and these are its real
//  numbers - range of the following 2 hours, by quintile:
//    MNQ : 39.3 / 43.4 / 47.0 / 53.8 / 64.4 bp   (Q1 = 0.61x Q5)
//    GC  : 35.2 / 37.9 / 41.0 / 44.2 / 59.8 bp   (Q1 = 0.59x Q5)
//  Monotonic on both instruments. These are the numbers to rely on, not the
//  study figures: this is what the indicator delivers in real time.
//
//  COUNTER-INTUITIVE CONCLUSION: compression does NOT announce expansion. It
//  announces more quiet. That is the opposite of the common belief.
//
//  WHAT IT DOES NOT DO
//  It predicts no direction whatsoever. On the same samples, the signed return
//  of the 2 hours following a compression is nil (MNQ -0.47 bp, t = -0.55), and
//  a range breakout traded as a bracket loses about the same amount in both
//  directions (-0.241 R going with the break, -0.258 R fading it). Two opposite
//  directions losing the same amount is the signature of no information at all.
//
//  REPAINTING: none. The percentile is computed against elapsed, closed hours
//  only. The "closed bars only" option additionally freezes the current range so
//  the displayed value stops moving inside the forming bar.
// =============================================================================

indicator("Range Compression Percentile - Hour Ranked", shorttitle="RCP",
     overlay = false, format = format.percent, precision = 0)

// --------------------------- Inputs ---------------------------
grpM = "Measurement"
lenRange = input.int(78, "Range window (bars)", minval = 5, group = grpM,
     tooltip = "78 bars = 6h30 on a 5-minute chart, one full RTH session. This is the value the effect was measured on.")
useClosed = input.bool(true, "Closed bars only", group = grpM,
     tooltip = "Freezes the range on the previous bar. Without it the value moves inside the forming bar. That is not repainting, but it is hard to read live.")
tzIn = input.string("America/New_York", "Reference time zone", group = grpM,
     options = ["America/New_York", "Europe/London", "Asia/Tokyo", "GMT+0", "GMT+4"],
     tooltip = "Used only to split the day into hours. The hour-of-day structure of a CME future is read in New York time.")

grpH = "History"
lookDays = input.int(120, "Observations kept per hour", minval = 20, maxval = 400, group = grpH,
     tooltip = "One observation per hour per day. 120 is roughly six months of sessions.")
minObs = input.int(20, "Minimum observations before displaying", minval = 5, group = grpH)

grpC = "Cost"
costBp = input.float(0.98, "Round-turn cost (basis points)", minval = 0.0, step = 0.01, group = grpC,
     tooltip = "Commission plus slippage, expressed against notional, in bp. Measured reference points: MNQ 0.98 - MES 1.89 - MYM 2.06 - MGC 3.00 to 3.44 depending on the price of gold. This cost depends on price, so it is never constant over time.")
ratioMin = input.float(20.0, "Flag amplitude/cost ratio below", minval = 1.0, step = 1.0, group = grpC)

grpV = "Display"
showTable = input.bool(true, "Show table", group = grpV)
posTable  = input.string("Top right", "Table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpV)

// ----------------------- Current range -----------------------
// Expressed in bp of price: makes the measure comparable across instruments and
// across time.
srcHigh = useClosed ? high[1] : high
srcLow  = useClosed ? low[1]  : low
srcCls  = useClosed ? close[1] : close

hiN = ta.highest(srcHigh, lenRange)
loN = ta.lowest(srcLow, lenRange)
rangeBp = srcCls > 0 ? (hiN - loN) / srcCls * 10000.0 : na

// Last hour's range: shown for comparison, because it is the amplitude
// predictor already known (R2 of about 0.21 to 0.29 on its own).
barsPerHour = math.max(1, int(60 / math.max(1, timeframe.in_seconds() / 60)))
range1h = srcCls > 0 ? (ta.highest(srcHigh, barsPerHour) - ta.lowest(srcLow, barsPerHour)) / srcCls * 10000.0 : na

// ----------------- Per-hour range history -----------------
// 24 rows (one per hour), lookDays columns used as a circular buffer.
var matrix<float> hist = matrix.new<float>(24, lookDays, na)
var array<int> writeAt = array.new_int(24, 0)

hNow  = hour(time, tzIn)
hPrev = hour(time[1], tzIn)

// One observation is stored per elapsed hour, at the moment the hour changes.
// The value stored is the previous bar's: an hour that is over, therefore
// definitively closed. This is what guarantees there is no repainting.
if not na(rangeBp[1]) and hNow != hPrev and bar_index > lenRange
    row = hPrev
    col = array.get(writeAt, row)
    matrix.set(hist, row, col, rangeBp[1])
    array.set(writeAt, row, (col + 1) % lookDays)

// --------------------- Percentile within the hour ---------------------
rankWithinHour(row, value) =>
    float res = na
    if not na(value)
        arr = matrix.row(hist, row)
        int total = 0
        int below = 0
        for i = 0 to array.size(arr) - 1
            float x = array.get(arr, i)
            if not na(x)
                total := total + 1
                if x < value
                    below := below + 1
        res := total >= minObs ? below / total * 100.0 : na
    res

pct = rankWithinHour(hNow, rangeBp)

// --------------------------- Reading ---------------------------
quintile = na(pct) ? na : math.min(4, int(pct / 20.0)) + 1
ratio = costBp > 0 and not na(rangeBp) ? rangeBp / costBp : na

cQ1 = color.new(#A0483A, 0)   // quiet expected, low amplitude
cQ2 = color.new(#C87F4A, 0)
cQ3 = color.new(#8A8A8A, 0)
cQ4 = color.new(#4E8FA8, 0)
cQ5 = color.new(#1F6F5F, 0)   // wide amplitude

// No `switch` here: quintile can be na while history is still building, and a
// switch on na falls through to an undefined case.
barCol = na(quintile) ? color.gray : quintile == 1 ? cQ1 : quintile == 2 ? cQ2 : quintile == 3 ? cQ3 : quintile == 4 ? cQ4 : cQ5

// --------------------------- Plot ---------------------------
plot(pct, "Hourly percentile", color = barCol, style = plot.style_columns, linewidth = 2)
hline(20, "Bottom quintile", color = color.new(#A0483A, 55), linestyle = hline.style_dashed)
hline(50, "Median", color = color.new(color.gray, 70), linestyle = hline.style_dotted)
hline(80, "Top quintile", color = color.new(#1F6F5F, 55), linestyle = hline.style_dashed)

// --------------------------- Table ---------------------------
posT = posTable == "Top right" ? position.top_right : posTable == "Top left" ? position.top_left : posTable == "Bottom right" ? position.bottom_right : position.bottom_left

var table tb = table.new(posT, 2, 6, border_width = 1)

if showTable and barstate.islast
    txtQ = na(quintile) ? "-" : "Q" + str.tostring(quintile) + " / 5"
    txtP = na(pct) ? "not enough history" : str.tostring(pct, "#") + "th pct"
    txtR = na(rangeBp) ? "-" : str.tostring(rangeBp, "#.#") + " bp"
    txt1 = na(range1h) ? "-" : str.tostring(range1h, "#.#") + " bp"
    txtC = na(ratio) ? "-" : str.tostring(ratio, "#.#") + " x"
    txtH = (hNow < 10 ? "0" : "") + str.tostring(hNow) + ":00"

    verdict = na(quintile) ? "Building history" : quintile == 1 ? "Quiet expected - low amplitude" : quintile == 5 ? "Wide amplitude available" : "Nothing remarkable"
    cVerdict = na(quintile) ? color.gray : quintile == 1 ? cQ1 : quintile == 5 ? cQ5 : cQ3

    table.cell(tb, 0, 0, "Range compression", text_color = color.white, bgcolor = color.new(#2B3A36, 0), text_size = size.small)
    table.cell(tb, 1, 0, txtH, text_color = color.white, bgcolor = color.new(#2B3A36, 0), text_size = size.small)

    table.cell(tb, 0, 1, "Range, " + str.tostring(lenRange) + " bars", text_size = size.small)
    table.cell(tb, 1, 1, txtR, text_size = size.small)

    table.cell(tb, 0, 2, "Range, last hour", text_size = size.small)
    table.cell(tb, 1, 2, txt1, text_size = size.small)

    table.cell(tb, 0, 3, "Rank within this hour", text_size = size.small)
    table.cell(tb, 1, 3, txtP + "  (" + txtQ + ")", text_color = barCol, text_size = size.small)

    table.cell(tb, 0, 4, "Amplitude / cost", text_size = size.small)
    table.cell(tb, 1, 4, txtC, text_color = na(ratio) ? color.gray : ratio < ratioMin ? cQ1 : cQ5, text_size = size.small)

    table.cell(tb, 0, 5, "Reading", text_size = size.small)
    table.cell(tb, 1, 5, verdict, text_color = cVerdict, text_size = size.small)

// --------------------------- Alerts ---------------------------
intoQ1 = not na(pct) and pct <= 20 and (na(pct[1]) or pct[1] > 20)
intoQ5 = not na(pct) and pct >= 80 and (na(pct[1]) or pct[1] < 80)
lowRatio = not na(ratio) and ratio < ratioMin and (na(ratio[1]) or ratio[1] >= ratioMin)

alertcondition(intoQ1, "Entering compression (Q1)", "Range in the bottom quintile of its hour: expected amplitude lower than normal.")
alertcondition(intoQ5, "Entering wide amplitude (Q5)", "Range in the top quintile of its hour.")
alertcondition(lowRatio, "Amplitude/cost ratio too low", "Available amplitude has dropped below the defined threshold.")
````
