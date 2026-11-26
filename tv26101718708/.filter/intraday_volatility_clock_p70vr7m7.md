# Intraday Volatility Clock

- url: https://www.tradingview.com/script/p70vR7M7-Intraday-Volatility-Clock/
- type: indicator
- pine_id: PUB;76c67c86f62c4a0b90ad87d096222242
- version: 1.0

## Description

[b]The Concept[/b]
A stop is a distance, and every distance is really a bet about how much the market can move before you are wrong. But intraday volatility is nowhere near constant — it is loud at the open, quiet through the middle of the session, and wakes up again into the close. On liquid intraday instruments the gap between the busiest and calmest half-hours is routinely four to five times in variance, which is roughly double in standard deviation. A stop set on the session's average volatility is therefore far too tight in the first half hour and needlessly wide at midday. Same number of points, completely different meaning. Volatility Clock measures that shape from the instrument's own history and hands it back as a single number per time slot, so you can see which part of the day you are standing in before you decide what a distance is worth.

[b]What It Shows[/b]
🕐 [b]Time-of-Day Multiplier[/b] — a stepped line showing how much variance this slot of the session normally carries, expressed against the session average. 1.00 is a typical slot for this market; 3.00 means this slot usually runs three times as hot
📊 [b]Curve Table[/b] — the fitted profile slot by slot, with the number of sessions behind each one so you can see which parts of the day are well measured and which are thin. Long sessions cut into small slots can outrun the table; when that happens it says how many slots were left off rather than quietly dropping the tail
📐 [b]Sigma Mode[/b] — the same curve as a standard-deviation multiplier rather than a variance one, for scaling stop distances and expected move directly
⚖️ [b]Session Average Line[/b] — the 1.00 reference. Above it the market is normally more active than its own daily baseline, below it less
🎛️ [b]Fit Controls[/b] — slot width, how many sessions to measure over, and how hard to shrink thinly-observed slots toward neutral

[b]How It Is Built[/b]
Squared log returns are pooled into time-of-day slots, one row per session. Each session's slots are divided by that session's own average before anything is compared across days, so a violent session contributes its [i]shape[/i] and not its [i]scale[/i] — otherwise one wild day writes the curve for every other. The statistic across sessions is the median, for the same reason. Thin slots are shrunk toward 1.00 in log space, so a slot with three observations degrades to "no opinion" rather than to a confident wrong number. The finished curve is renormalised to average 1.00, which is what makes it orthogonal to whatever volatility estimate you already use: applying it moves variance around inside the day without changing the overall level.

Slots are measured from the [b]session open[/b], not from midnight. On a market that opens at 09:15, a midnight grid would produce a first slot labelled 09:00 holding only fifteen minutes of trading — the hottest fifteen minutes of the day, reading high for the wrong reason. Anchoring to the open keeps every slot the same width and keeps sessions that run past midnight in the right order.

[b]How To Use[/b]
Add it to an intraday chart with a decent number of completed sessions and read it as context, not as a trigger. It has no bullish or bearish opinion and never will.
• [b]Scale distances, do not shift them.[/b] Switch on Sigma Mode and treat the number as a multiplier on whatever stop or target width you already use. A 2.00 reading means the same setup deserves roughly twice the room it would get at midday
• [b]Mind the trough.[/b] The quietest part of the session is where fixed-distance stops look safest and are actually the loosest relative to what the market is doing. It is also where a trade needs the most time to travel anywhere
• [b]Respect the open.[/b] The first slot is usually the largest number on the chart by a wide margin. Positions taken there carry far more range than the rest of the day, whichever way it goes
• [b]Check the sample column.[/b] A slot backed by three sessions is a guess; one backed by forty is a measurement. Thin slots are deliberately pulled toward 1.00 rather than shown as confident extremes
• [b]Compare instruments.[/b] The shape is not universal. Index futures, single stocks and commodities each have their own profile, and a commodity trading across two continents' hours can look nothing like an index
• [b]Match the slot to the chart.[/b] Slot width must be at least the bar interval, and works best as an exact multiple of it. The script says so in the table rather than fitting a curve on a broken grid

[b]Using It In A Trade[/b]
Everything below is one idea: the multiplier tells you what a point is worth right now, so anything you measure in points should be read through it. None of it is a signal, and none of it says which way to face.

[b]1. Stops.[/b] Turn on Sigma Mode. If your working stop is X points and the reading is 1.80, the comparable stop in that slot is about 1.8X — not because the trade needs more room emotionally, but because the market covers that distance 1.8 times as easily there. Running one fixed number all day means you are unknowingly trading a tight stop at the open and a loose one at lunch.

[b]2. Targets and the ratio you are actually getting.[/b] Scaling the stop without scaling the target quietly changes your risk-reward. If both move with the multiplier, the ratio survives. If only the stop moves, a 1:2 setup at midday is something else entirely at the open.

[b]3. Position size.[/b] The inverse of the sigma multiplier is a size scalar. Half the size at a 2.00 slot and full size at a 1.00 slot puts roughly the same rupee risk on the table in both, which is usually what you meant by "fixed risk" in the first place.

[b]4. Time budget for a trade.[/b] A trade needs the market to travel. In a 0.60 slot it travels slowly, so the same target takes materially longer and the trade will sit through more time doing nothing. If you scalp with a time-based exit, the exit is worth scaling too.

[b]5. Choosing when to be in the market.[/b] Some approaches want movement — breakouts, momentum, anything paid by range. Those live in the peaks. Others want stillness — mean reversion, range fades, anything that assumes price comes back. Those live in the trough. The curve tells you which regime the clock has put you in before the chart does.

[b]6. Breakout filtering.[/b] The same size of break means different things at different times. A move that clears yesterday's high in a 0.50 slot required real force to happen there. The identical move in the opening slot is inside what the market does routinely without meaning anything. Comparing break size against the local multiplier is a cheap sanity check.

[b]7. Options and anything short premium.[/b] Premium sellers are paid for time and punished by movement, and the two are not distributed the same way through the day. The peaks are where a written position takes its damage; the trough is where decay does its work relatively undisturbed. Stop distances on short-premium positions are exactly the kind of fixed number that this curve says should not be fixed.

[b]8. Comparing a session to its own norm.[/b] Take the realised movement of the current slot and divide by what the curve says that slot normally carries. Above one means today is running hot for that time of day, below one means it is quiet — a cleaner read on "is today unusual" than comparing against a flat daily average that has the time-of-day shape baked into it.

Works on any symbol on intraday timeframes. Larger bar intervals let the chart hold more sessions, which usually gives a steadier profile than squeezing more detail out of fewer days.

[b]Notes[/b]
[b]This measures where volatility concentrates, not where price goes.[/b] Nothing here forecasts direction, and no combination of settings will make it do so. It is a description of how the instrument distributes its movement across the trading day.
[b]Non-repainting.[/b] The profile is recalculated once at each session open using completed sessions only, and only completed bars are ever added to the sample. The value displayed on any bar was knowable before that session began, and history is not redrawn as the current session develops.
[b]Regular session only, by default.[/b] Pre-market and auction prints are not ordinary trading. Left in the sample, a single auction gap can double the opening slot on its own. The setting can be turned off, but the profile it produces should be read with that in mind.
[b]History requirement.[/b] The profile needs several completed sessions before it will display anything. Below that it shows how many sessions it has gathered so far rather than drawing a curve nobody should trust. On non-intraday timeframes it says so and draws nothing. A slot with no observations behind it draws nothing rather than defaulting to 1.00.
[b]A profile is not a promise.[/b] Any individual session can ignore the shape entirely — news, expiry and holidays all override it. The curve describes the central tendency of many days, not the obligation of the next one.
No alerts in this version.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
// Intraday Volatility Clock  —  v6
//
// Intraday volatility is not flat. It is dominated by a repeating time-of-day
// shape: loud at the open, quiet through the middle of the session, waking up
// again into the close. On liquid intraday instruments that spread is routinely
// 4-5x in VARIANCE (about 2x in standard deviation) between the loudest and
// quietest half hours of the day.
//
// That matters because almost everything is sized in standard deviations. A
// stop set on the session's AVERAGE volatility is far too tight at the open and
// unnecessarily wide at midday — the same distance means something different at
// 09:20 than it does at 12:30.
//
// This indicator measures that shape from the chart's own history and expresses
// it as a multiplier on the session average. 1.00 means "a typical slot for this
// market"; 3.00 means this slot normally carries three times the variance.
//
// ── HOW IT IS BUILT ────────────────────────────────────────────────────────
// For each session, squared log returns are pooled into time-of-day buckets and
// each bucket is divided by that session's own average. Dividing within the day
// first is what makes a violent session contribute its SHAPE rather than its
// SCALE — otherwise one wild day sets the curve for every other.
//
// Across sessions the statistic is the MEDIAN, not the mean, for the same
// reason. Buckets with few observations are shrunk toward 1.00 IN LOG SPACE, so
// a thin slot degrades to "no opinion" rather than to a confident wrong number,
// and the shrink is symmetric for a multiplicative quantity. Finally the curve
// is renormalised to arithmetic mean 1.00, which makes it orthogonal to whatever
// volatility estimate you already use: applying it redistributes variance
// through the day without changing the overall level.
//
// ── BUCKET GRID IS ANCHORED TO THE SESSION OPEN ────────────────────────────
// Buckets are measured as minutes SINCE THE SESSION OPEN, not since midnight.
// On a market that opens at 09:15, a midnight-anchored 30-minute grid produces a
// first slot labelled 09:00 that actually holds only 09:15-09:29 — a half-width
// bucket containing the hottest quarter hour of the day, which reads high for
// the wrong reason. Anchoring to the open gives full-width slots and also keeps
// sessions that cross midnight in the right order.
//
// ── WHY THE ATTRIBUTION IS CORRECT (do not "fix" this) ─────────────────────
// `hour` and `minute` are taken from the bar's OPEN time, and the return
// log(close / close[1]) spans exactly that bar's open to its close. So the
// return interval always falls inside the bucket it is credited to. It looks
// off-by-one at a glance; it is not.
//
// ── NON-REPAINTING ─────────────────────────────────────────────────────────
// The curve is recomputed once at each new session and uses COMPLETED sessions
// only. The value shown on any bar was knowable before that session opened.
// Accumulation is gated on barstate.isconfirmed and on bar_index, because the
// matrices are persistent objects whose contents are not rolled back between
// realtime ticks — without the gate the developing bar would add its squared
// return once per tick and the live fit would drift away from the reloaded one.
//
// ── NOTES ──────────────────────────────────────────────────────────────────
// Intraday timeframes only; the shape is the whole point, so daily and above
// have nothing to measure. Bucket size must be at least the chart's bar
// interval, and ideally an exact multiple of it — the script says so rather than
// producing a curve measured on a broken grid.
//
// Needs several sessions before it will display anything. On very short bar
// intervals the number of sessions the chart can hold is limited — if the fit
// looks thin, step up to a larger bar interval rather than reducing the bucket
// size. Very small buckets combined with many sessions make the once-per-session
// fit expensive; the fit loops only over slots the session actually reaches.
//
// Regular session only is ON by default. Pre-market and auction prints are not
// ordinary trading, and one auction gap left in the sample can double the
// opening bucket on its own.
// ═══════════════════════════════════════════════════════════════════════════

indicator("Intraday Volatility Clock", "Vol Clock", overlay = false)

// ─── Inputs ────────────────────────────────────────────────────────────────
grpFit = "Fit"
bucketMin = input.int(30, "Bucket size (minutes)", options = [5, 10, 15, 30, 60], group = grpFit,
     tooltip = "Width of each slot, measured from the session open. Smaller buckets resolve the open more sharply but need more sessions to stay stable. Must be at least the chart's bar interval.")
maxDays = input.int(40, "Sessions in the fit", minval = 3, maxval = 120, group = grpFit,
     tooltip = "How many recent sessions the curve is measured over. Older sessions drop out as new ones arrive.")
shrinkDays = input.float(5.0, "Shrinkage", minval = 0.0, maxval = 50.0, step = 0.5, group = grpFit,
     tooltip = "Pulls thinly-observed buckets back toward 1.00. Raise it if the curve looks spiky, lower it for a sharper shape.")
rthOnly = input.bool(true, "Regular session only", group = grpFit,
     tooltip = "Excludes pre/post market. Leaving auction prints in can double the opening bucket on its own.")

grpDisp = "Display"
showSigma = input.bool(false, "Show as sigma multiplier", group = grpDisp,
     tooltip = "Variance multiplier is the default. Sigma is its square root — use this one when scaling stop distances or expected move, which are denominated in standard deviations.")
showTable = input.bool(true, "Show curve table", group = grpDisp)
upCol = input.color(#e8833a, "Above average", group = grpDisp)
dnCol = input.color(#3a7ce8, "Below average", group = grpDisp)

int nBuckets = int(math.floor(1440.0 / bucketMin))
const int MAXROWS = 50

// ─── State ─────────────────────────────────────────────────────────────────
// sumSq/cnt accumulate squared returns per (session, bucket) in a ring buffer
// holding the most recent `maxDays` sessions.
//
// The counters are `varip` on purpose. Matrices and arrays are persistent
// objects that are NOT rolled back between realtime ticks, so the indices that
// address them must not be either — otherwise a rolled-back row pointer can
// write this session's data into yesterday's row.
var matrix<float> sumSq  = matrix.new<float>(maxDays, nBuckets, 0.0)
var matrix<float> cnt    = matrix.new<float>(maxDays, nBuckets, 0.0)
var array<float>  factor = array.new<float>(nBuckets, 1.0)
var array<int>    fitN   = array.new<int>(nBuckets, 0)

varip int dayRow      = -1   // ring-buffer row for the session in progress
varip int daysSeen    = 0
varip int fitted      = 0    // buckets that carried an observation in the last fit
varip int maxB        = 0    // highest bucket index the session actually reaches
varip int lastFitBar  = -1   // once-per-bar guard for the (expensive) fit
varip int lastAccBar  = -1   // once-per-bar guard for accumulation
varip int sessOpenMin = na   // minutes-from-midnight of this session's open
varip int anchorMin   = na   // last known session open, used for table labels

// ─── Recompute the curve from COMPLETED sessions ───────────────────────────
recompute() =>
    int nDays = math.min(daysSeen, maxDays)
    int bLast = math.min(maxB, nBuckets - 1)
    int used  = 0
    if nDays >= 3
        // 1. Per-session bucket means, each divided by that session's own mean
        //    so a violent day contributes its shape and not its scale.
        matrix<float> ratios = matrix.new<float>(nDays, bLast + 1, na)
        for d = 0 to nDays - 1
            float daySum = 0.0
            int   dayCnt = 0
            for b = 0 to bLast
                float c = matrix.get(cnt, d, b)
                if c > 0
                    float m = matrix.get(sumSq, d, b) / c
                    matrix.set(ratios, d, b, m)
                    daySum += m
                    dayCnt += 1
            if dayCnt >= 3 and daySum > 0
                float dayMean = daySum / dayCnt
                for b = 0 to bLast
                    float v = matrix.get(ratios, d, b)
                    if not na(v)
                        matrix.set(ratios, d, b, v / dayMean)
            else
                // Too little of the session survived; drop it rather than let a
                // near-empty day distort the median.
                for b = 0 to bLast
                    matrix.set(ratios, d, b, na)

        // 2. Median across sessions, then shrink thin buckets toward 1.00.
        //    The shrink is done in log space: these are ratios, and a linear
        //    pull toward 1.00 is asymmetric between 0.5x and 2.0x.
        array<float> raw = array.new<float>(nBuckets, na)
        float total = 0.0
        for b = 0 to bLast
            array<float> col = array.new<float>(0)
            for d = 0 to nDays - 1
                float v = matrix.get(ratios, d, b)
                if not na(v)
                    array.push(col, v)
            int n = array.size(col)
            array.set(fitN, b, n)
            if n > 0
                float med = array.median(col)
                float sh  = med > 0 ? math.exp(n * math.log(med) / (n + shrinkDays)) : 1.0
                array.set(raw, b, sh)
                total += sh
                used  += 1

        // 3. Renormalise to arithmetic mean 1.00 so the curve redistributes
        //    variance without changing the overall level.
        if used > 0 and total > 0
            float mean = total / used
            for b = 0 to nBuckets - 1
                float v = array.get(raw, b)
                array.set(factor, b, na(v) ? 1.0 : v / mean)
    used

// ─── Context ───────────────────────────────────────────────────────────────
bool  isIntraday = timeframe.isintraday
float tfMin      = timeframe.in_seconds() / 60.0
bool  tfOK       = isIntraday and bucketMin >= tfMin
bool  tfAligned  = tfOK and math.abs(bucketMin / tfMin - math.round(bucketMin / tfMin)) < 1e-9

bool inSession = isIntraday and (not rthOnly or session.ismarket)
bool inSessPrv = inSession[1]                      // evaluated every bar on purpose

int  dayChg = nz(ta.change(time("D")), 0)          // session-aware, not calendar midnight
bool newDay = isIntraday and dayChg != 0

// ─── Roll the session ──────────────────────────────────────────────────────
// Guarded to run exactly once per bar. The fit is the expensive part of the
// script and re-running it on every realtime tick of the session's first bar is
// pure waste; leaving the row pointer ungated would be worse than waste.
if newDay and tfOK and bar_index != lastFitBar
    lastFitBar  := bar_index
    fitted      := recompute()
    dayRow      := dayRow < 0 ? 0 : (dayRow + 1) % maxDays
    daysSeen    := daysSeen + 1
    sessOpenMin := na
    for b = 0 to nBuckets - 1
        matrix.set(sumSq, dayRow, b, 0.0)
        matrix.set(cnt,   dayRow, b, 0.0)

// ─── Anchor the bucket grid to the session open ────────────────────────────
if isIntraday and inSession and na(sessOpenMin)
    sessOpenMin := hour * 60 + minute
    anchorMin   := sessOpenMin

int offMin    = na(sessOpenMin) ? na : (hour * 60 + minute - sessOpenMin + 1440) % 1440
int curBucket = na(offMin) ? na : math.min(int(math.floor(offMin * 1.0 / bucketMin)), nBuckets - 1)

if tfOK and inSession and not na(curBucket)
    maxB := math.max(maxB, curBucket)

// ─── Accumulate ────────────────────────────────────────────────────────────
// BOTH ends of the bar must be inside the session. Checking only the current
// bar is not enough: on a chart with extended hours the first regular-session
// bar is not a new calendar day, so its return spans the pre-market gap and
// lands entirely in the opening bucket. Verified against a reference fit — that
// single leak reads the open at 3.84x instead of 3.18x.
bool validRet = tfOK and inSession and inSessPrv and not newDay and not na(curBucket)
     and not na(close[1]) and close > 0 and close[1] > 0

if validRet and dayRow >= 0 and barstate.isconfirmed and bar_index != lastAccBar
    lastAccBar := bar_index
    float r = math.log(close / close[1])
    matrix.set(sumSq, dayRow, curBucket, matrix.get(sumSq, dayRow, curBucket) + r * r)
    matrix.set(cnt,   dayRow, curBucket, matrix.get(cnt,   dayRow, curBucket) + 1.0)

// ─── Plot ──────────────────────────────────────────────────────────────────
// A bucket with no observations plots nothing. It used to plot the initialised
// 1.00, which is indistinguishable from a genuinely average slot.
bool  ready     = tfOK and fitted > 0 and daysSeen > 3
bool  haveB     = ready and inSession and not na(curBucket) and array.get(fitN, curBucket) > 0
float rawFactor = haveB ? array.get(factor, curBucket) : na
float shown     = showSigma ? math.sqrt(rawFactor) : rawFactor

plot(shown, "Multiplier", color = na(shown) ? na : (shown >= 1.0 ? upCol : dnCol),
     style = plot.style_stepline, linewidth = 2)
hline(1.0, "Session average", color = color.new(color.gray, 40), linestyle = hline.style_dashed)

// ─── Curve table ───────────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 3, MAXROWS + 2,
     frame_color = color.new(color.gray, 70), frame_width = 1)

msgCell(txt) =>
    table.cell(tbl, 0, 0, txt, text_color = color.gray, text_size = size.small)

if showTable and barstate.islast
    table.clear(tbl, 0, 0, 2, MAXROWS + 1)
    if not isIntraday
        msgCell("Use an intraday timeframe")
    else if not tfOK
        msgCell("Bucket size is smaller than the bar interval — raise it to " +
             str.tostring(math.ceil(tfMin)) + "m or more")
    else if not ready
        msgCell("Measuring… " + str.tostring(daysSeen) + " sessions so far")
    else
        int totalSlots = 0
        for b = 0 to nBuckets - 1
            if array.get(fitN, b) > 0
                totalSlots += 1

        table.cell(tbl, 0, 0, "Time", text_color = color.gray, text_size = size.tiny)
        table.cell(tbl, 1, 0, showSigma ? "Sigma" : "Var", text_color = color.gray, text_size = size.tiny)
        table.cell(tbl, 2, 0, "n", text_color = color.gray, text_size = size.tiny)

        int row = 1
        for b = 0 to nBuckets - 1
            if array.get(fitN, b) > 0 and row <= MAXROWS
                float f  = array.get(factor, b)
                float fv = showSigma ? math.sqrt(f) : f
                int  mins = (nz(anchorMin, 0) + b * bucketMin) % 1440
                int  hh   = int(math.floor(mins / 60.0))
                int  mm   = mins % 60
                string lbl = (hh < 10 ? "0" : "") + str.tostring(hh) + ":" + (mm < 10 ? "0" : "") + str.tostring(mm)
                table.cell(tbl, 0, row, lbl, text_color = color.gray, text_size = size.tiny)
                table.cell(tbl, 1, row, str.tostring(fv, "0.00"),
                     text_color = fv >= 1.0 ? upCol : dnCol, text_size = size.tiny)
                table.cell(tbl, 2, row, str.tostring(array.get(fitN, b)),
                     text_color = color.new(color.gray, 40), text_size = size.tiny)
                row += 1

        // Say so instead of silently swallowing the tail of the session.
        if totalSlots > MAXROWS
            table.cell(tbl, 0, MAXROWS + 1, "+" + str.tostring(totalSlots - MAXROWS) + " more",
                 text_color = color.gray, text_size = size.tiny)
            table.cell(tbl, 1, MAXROWS + 1, "raise bucket size",
                 text_color = color.new(color.gray, 40), text_size = size.tiny)
        else if not tfAligned
            table.cell(tbl, 0, MAXROWS + 1, "bucket ≠ multiple of bar",
                 text_color = color.new(color.gray, 30), text_size = size.tiny)
````
