<!-- tradingview-pine-id: PUB;5706ac2d1ab34d82bdb8d6fc09eba2f7 -->
<!-- tradingviewscripts-format: 1 -->
# Day-Extreme Reversal Signals

Source: https://www.tradingview.com/script/J17hSoQd-Day-Extreme-Reversal-Signals/

## Description

Real-time detector for the bar shapes that historically printed SPY's day low and day high. When a new session extreme forms, it tells you the measured probability that THIS bar holds as the day's extreme - and how those odds differ between 5-minute scouts and hourly signals.

OVERVIEW

Every intraday trader eventually asks the same two questions: "was that the low?" and "is this the high?" This indicator answers them with measured frequencies instead of intuition.

It watches for new session extremes in real time. When one prints, it classifies the bar's shape - reversal close, spring, V-confirm at lows; rejection, high-confirm at highs - and labels it with the historical probability that this specific shape, at this event, held as the day's extreme. A decision panel keeps the session context on screen: where the current extremes sit, when they printed, the odds the day's extreme has already happened given the time of day, and the structural rules for acting on lows versus highs.

The stats were built by real-time simulation - walking bar by bar and asking "would this signal have fired here, and did the extreme hold?" - not by locating day extremes in hindsight and describing them afterward.

WHY THIS IS DIFFERENT

TradingView has time-of-day extreme statistics: tools that count in which hour or session window daily highs and lows historically print. Those answer "WHEN does the extreme usually happen?"

This script answers a different question: "is THIS bar the extreme?" The probabilities are conditional on an event (a new session extreme printing) and on the shape of the bar that printed it - not on the clock. To my knowledge no public script does event-conditional extreme classification, and none publishes the two findings that drive this tool's usage rules:

1 - The scout/signal hierarchy. The same shapes carry very different weight by timeframe. A 5-minute reversal close at a new session low held as the day low 28% of the time (versus a 14% baseline for any new session low) - interesting, not tradeable alone. The same shape on an HOURLY bar held 64% of the time (versus a 35% hourly baseline) - nearly two-thirds of occurrences marked the day low. The 5m shapes are scouts that put you on alert; the hourly shapes are the signal.

2 - Lows and highs are structurally different animals. In the data, lows are V-shaped: 55% of day lows were never retested within 30 minutes. Highs are processes: 82% of day highs were retested within 30 minutes. The practical asymmetry is baked into the panel - at lows, waiting for a retest usually means missing the trade; at highs, patience is statistically paid for.

THE SHAPES

All shapes evaluate only at a NEW session extreme (or on the bar immediately following one). At lows:

- RevClose - the bar makes a new session low but closes green and in the top third of its range. Sellers broke the floor and were immediately overwhelmed. Strongest low shape on both timeframes (5m: 28% holds; hourly: 64%).
- Spring - new session low with a long lower wick (more than half the bar) and a close off the floor. The push below found no acceptance (5m: 17%; hourly: 55%).
- V-confirm - the bar AFTER a red new-session-low bar opens and closes green above the prior open. Confirmation that the flush reversed (5m: 27%; hourly: 54%).

At highs:

- Reject - new session high with a long upper wick and a close out of the top third. (5m: 11% vs 9% base - barely above baseline; hourly: 47% vs 28% base.)
- HighConf / Confirm - a red bar immediately after a green new-session-high bar. (5m: 12%; hourly: 33%.)

Note what the high-side numbers say: even the best hourly high shape holds less than half the time. Tops are processes, and the script tells you so rather than pretending otherwise.

THE DECISION PANEL

- Current session low and high with their print times (ET).
- Time-of-day odds that the day's extreme has ALREADY printed, interpolated from the measured distribution (37% of lows are in by 10:00 ET, 60% by 11:30; highs run later - 18% by 10:00, with a heavy skew into the final hour).
- A provisional read of what the current, still-forming hourly bar is shaping into.
- The two structural rules, always on screen: lows are V-shaped, do not wait for the retest; highs retest 82% of the time, exits and fades can be patient.

HOW TO USE IT

Work on a 5-minute chart (any intraday timeframe runs; daily charts are rejected with an error).

- A 5m scout triangle at a new session low means: stop, context check. Alone it is a minority bet.
- The teal background band - an hourly low shape confirming - is the signal. Odds the day low is in jump to roughly fifty-fifty or better. Because lows are V-shaped, the statistically supported action is to act on the signal bar rather than wait for a pullback that usually never comes.
- The orange band at highs is a warning, not a green light to fade aggressively: expect a retest attempt, and use it - the second look at a high is where shorts and exits get their fill.
- The time-of-day odds frame everything: a new low printing at 14:30 ET is a rarer, more reliable event than one at 09:45, simply because most days have already made their low by then.

Alerts are provided for the hourly low signal, the hourly high signal, and the strongest 5m scout.

THE DATA, STATED PLAINLY

- Instrument: SPY. Samples: 60 days of 5-minute bars and 730 days of hourly bars.
- Method: real-time simulation. The detector walked forward bar by bar; every firing was recorded with whether that extreme survived as the day's extreme. No hindsight selection.
- Every probability is shown next to its baseline (the hold rate of ANY new session extreme on that timeframe), so you can see the edge, not just the number.
- The percentages are fixed numbers derived from that study, embedded in the script. They are descriptive statistics of a specific instrument over a specific period - not guarantees, and they will drift as market character changes.
- On symbols other than SPY (and index products that track it closely), the shape logic still runs, but the printed percentages do not apply. Treat them as unknown there.

LIMITATIONS

- Hourly signals use confirmed hourly bars (the standard non-repainting idiom - no future data is accessed), so they appear at the close of the hour, not at its low. The "forming" panel row is explicitly provisional and changes until the hour closes.
- 5m labels print on bar confirmation.
- The session-extreme state resets each calendar session; extended-hours settings on your chart change what counts as the session.
- The 60-day 5-minute sample is modest; the hourly sample (roughly two years) is the sturdier one, which is one more reason the hourly shapes are the signal tier.
- This is a probability tool, not an entry system. It quantifies "was that the extreme?" - stops, targets, and sizing are yours.

NOTES

The time-of-day asymmetry the data surfaced - lows early, highs late, lows violent, highs sticky - echoes the old observation running from George Douglass Taylor through Linda Raschke's day-structure work: down moves complete in the morning and buying builds through the day more often than the reverse. This script did not assume that; the simulation found it independently in modern SPY data.

Educational tool, not financial advice.

---

## Source Code

````pine
//@version=6
// DAY-EXTREME REVERSAL SIGNALS - for the 5m chart (any intraday TF works).
// Detects the bar shapes that historically printed SPY's day low/high, in real time,
// at NEW session extremes. Percentages = P(that extreme HOLDS as the day extreme),
// measured in real-time simulation (not hindsight): SPY 60d of 5m + 730d of hourly.
//   5m LOW shapes (scouts):   RevClose 28% | V-confirm 27% | Spring 17%  (baseline: any new ses low 14%)
//   HOURLY LOW shapes (signal): RevClose 64% | Spring 55% | V-confirm 54% (baseline 35%)
//   5m HIGH shapes: Reject 11% | Confirm 12% (baseline 9%) - weak; tops are processes.
//   HOURLY HIGH shapes: Reject 47% | Confirm 33% (baseline 28%).
// Structure notes baked into the panel: lows are V-shaped (55% never retest within 30m,
// do NOT wait for a retest); highs retest 82% of the time (exits can be patient);
// 37% of lows print by 10:00 ET vs 18% of highs; highs skew to the last hour.
indicator("Day-Extreme Reversal Signals", overlay = true, max_labels_count = 500)

if barstate.isfirst and timeframe.isdwm
    runtime.error("Use an intraday chart (5m recommended).")

// ---------------- Inputs ----------------
show5m = input.bool(true, "Show 5m scout shapes", group = "Signals")
showHr = input.bool(true, "Show HOURLY signals (highlight band)", group = "Signals")
showLbl = input.bool(true, "Show percentage labels", group = "Signals")
showPanel = input.bool(true, "Show decision panel", group = "Panel")
panelSize = input.string("small", "Panel text size", options = ["tiny", "small", "normal"], group = "Panel")

// ---------------- Shape detectors (evaluate in whatever TF they are called from) ----------------
f_lcode() =>
    var float sL = na
    var bool pNL = false
    var bool pRed = false
    var float pO = na
    newSes = ta.change(time("D")) != 0
    rngB = high - low
    lw = rngB > 0 ? (math.min(open, close) - low) / rngB : 0.0
    clv = rngB > 0 ? (close - low) / rngB : 0.5
    nl = not newSes and not na(sL) and low < sL
    v2 = not newSes and pNL and pRed and close > open and close > pO
    out = 0.0
    if nl and close > open and clv >= 0.667
        out := 2.0
    else if nl and lw > 0.5 and clv > 0.333
        out := 1.0
    else if v2
        out := 3.0
    sL := newSes or na(sL) ? low : math.min(sL, low)
    pNL := nl
    pRed := close < open
    pO := open
    out

f_hcode() =>
    var float sH = na
    var bool pNH = false
    var bool pGrn = false
    newSes = ta.change(time("D")) != 0
    rngB = high - low
    uw = rngB > 0 ? (high - math.max(open, close)) / rngB : 0.0
    clv = rngB > 0 ? (close - low) / rngB : 0.5
    nh = not newSes and not na(sH) and high > sH
    conf = not newSes and pNH and pGrn and close < open
    out = 0.0
    if nh and uw > 0.5 and clv < 0.667
        out := 1.0
    else if conf
        out := 2.0
    sH := newSes or na(sH) ? high : math.max(sH, high)
    pNH := nh
    pGrn := close > open
    out

// ---------------- Chart-TF (5m) scouts ----------------
l5 = f_lcode()
h5 = f_hcode()
l5txt = l5 == 2 ? "5m RevClose: holds 28% (base 14%)" : l5 == 1 ? "5m Spring: holds 17% (base 14%)" : l5 == 3 ? "5m V-confirm: holds 27% (base 14%)" : ""
h5txt = h5 == 1 ? "5m Reject: holds 11% (base 9%) - highs usually retest" : h5 == 2 ? "5m HighConf: holds 12% (base 9%)" : ""

plotshape(show5m and l5 > 0, "5m low scout", style = shape.triangleup, location = location.belowbar, color = color.new(color.teal, 30), size = size.tiny)
plotshape(show5m and h5 > 0, "5m high scout", style = shape.triangledown, location = location.abovebar, color = color.new(color.orange, 30), size = size.tiny)
if show5m and showLbl and l5 > 0 and barstate.isconfirmed
    label.new(bar_index, low, l5txt, yloc = yloc.belowbar, style = label.style_label_up, color = color.new(color.teal, 60), textcolor = color.white, size = size.small)
if show5m and showLbl and h5 > 0 and barstate.isconfirmed
    label.new(bar_index, high, h5txt, yloc = yloc.abovebar, style = label.style_label_down, color = color.new(color.orange, 55), textcolor = color.white, size = size.small)

// ---------------- HOURLY signals (confirmed) + forming hint ----------------
[cL, cH, fL, fH] = request.security(syminfo.tickerid, "60", [f_lcode()[1], f_hcode()[1], f_lcode(), f_hcode()], lookahead = barmerge.lookahead_on)

hrLtxt = cL == 2 ? "HOURLY RevClose at session low: DAY LOW 64% (base 35%)" : cL == 1 ? "HOURLY Spring at session low: DAY LOW 55% (base 35%)" : cL == 3 ? "HOURLY V-confirm: DAY LOW 54% (base 35%)" : ""
hrHtxt = cH == 1 ? "HOURLY Rejection at session high: DAY HIGH 47% (base 28%) - expect a retest attempt" : cH == 2 ? "HOURLY high-confirm: DAY HIGH 33% (base 28%)" : ""

var int loGlow = 0
var int hiGlow = 0
trigL = showHr and cL > 0 and ta.change(time("60")) != 0
trigH = showHr and cH > 0 and ta.change(time("60")) != 0
loGlow := trigL ? 12 : math.max(loGlow - 1, 0)
hiGlow := trigH ? 12 : math.max(hiGlow - 1, 0)
bgcolor(loGlow > 0 ? color.new(color.teal, 82) : na, title = "Hourly low-signal band")
bgcolor(hiGlow > 0 ? color.new(color.orange, 86) : na, title = "Hourly high-signal band")
if trigL and showLbl
    label.new(bar_index, low, hrLtxt, yloc = yloc.belowbar, style = label.style_label_up, color = color.new(color.teal, 20), textcolor = color.white, size = size.normal)
if trigH and showLbl
    label.new(bar_index, high, hrHtxt, yloc = yloc.abovebar, style = label.style_label_down, color = color.new(color.orange, 20), textcolor = color.white, size = size.normal)

// ---------------- Session tracking for the panel ----------------
var float sesLo = na
var float sesHi = na
var int tLo = na
var int tHi = na
var int sesStart = na
newSesC = ta.change(time("D")) != 0
if newSesC
    sesLo := low
    sesHi := high
    tLo := time
    tHi := time
    sesStart := time
else
    if low < sesLo
        sesLo := low
        tLo := time
    if high > sesHi
        sesHi := high
        tHi := time

f_seg(x, x0, y0, x1, y1) => y0 + (y1 - y0) * (x - x0) / (x1 - x0)
f_cdf(e, isLow) =>
    x = math.max(0.0, math.min(1.0, e))
    lo = x <= 0.08 ? f_seg(x, 0, 0, 0.08, 37) : x <= 0.15 ? f_seg(x, 0.08, 37, 0.15, 47) : x <= 0.31 ? f_seg(x, 0.15, 47, 0.31, 60) : x <= 0.5 ? f_seg(x, 0.31, 60, 0.5, 70) : x <= 0.77 ? f_seg(x, 0.5, 70, 0.77, 77) : f_seg(x, 0.77, 77, 1, 100)
    hi = x <= 0.08 ? f_seg(x, 0, 0, 0.08, 18) : x <= 0.15 ? f_seg(x, 0.08, 18, 0.15, 32) : x <= 0.31 ? f_seg(x, 0.15, 32, 0.31, 50) : x <= 0.5 ? f_seg(x, 0.31, 50, 0.5, 58) : x <= 0.77 ? f_seg(x, 0.5, 58, 0.77, 73) : f_seg(x, 0.77, 73, 1, 100)
    isLow ? lo : hi

// ---------------- Decision panel ----------------
txtSize = panelSize == "tiny" ? size.tiny : panelSize == "normal" ? size.normal : size.small
var table panel = table.new(position.top_right, 1, 7, border_width = 1, border_color = color.new(chart.fg_color, 80), bgcolor = color.new(chart.bg_color, 15))
cell(r, txt, bg) => table.cell(panel, 0, r, txt, text_halign = text.align_left, text_valign = text.align_top, text_color = chart.fg_color, text_size = txtSize, bgcolor = bg)

if barstate.islast and showPanel
    neutral = color.new(chart.fg_color, 92)
    elapsed = na(sesStart) ? 0.0 : (time - sesStart) / (6.5 * 3600000.0)
    pLo = f_cdf(elapsed, true)
    pHi = f_cdf(elapsed, false)
    cell(0, "DAY-EXTREME REVERSALS | SPY-derived stats", neutral)
    s1 = "Session low " + str.tostring(sesLo, format.mintick) + " set " + str.format_time(tLo, "HH:mm", "America/New_York") + " ET | high " + str.tostring(sesHi, format.mintick) + " set " + str.format_time(tHi, "HH:mm", "America/New_York") + " ET"
    s1 := s1 + "\nOdds the day extreme has ALREADY printed: low ~" + str.tostring(pLo, "#") + "%, high ~" + str.tostring(pHi, "#") + "%"
    cell(1, s1, neutral)
    fTxt = "Hourly forming (provisional, changes until hour close): "
    fTxt := fTxt + (fL == 2 ? "RevClose LOW shaping" : fL == 1 ? "Spring LOW shaping" : fL == 3 ? "V-confirm LOW shaping" : fH == 1 ? "Rejection HIGH shaping" : fH == 2 ? "High-confirm shaping" : "nothing")
    cell(2, fTxt, color.new(color.blue, 88))
    cell(3, "LOWS are V-shaped: 55% never retest within 30 min.\nDo NOT wait for a retest or confirmation - at lows the\nsecond chance usually never comes.", color.new(color.teal, 88))
    cell(4, "HIGHS retest 82% of the time within 30 min.\nFirst touch of a high is rarely final - exits and fades\ncan be patient; expect a second look.", color.new(color.orange, 90))
    cell(5, "Timing: lows print by 10:00/10:30/11:30 ET on 37/47/60%\nof days. Highs: 18/32/50% - highs skew late (23% in the\nlast 30 min). Late new lows are rarer and more reliable.", neutral)
    cell(6, "Read: 5m shapes are SCOUTS (17-28% the low holds).\nHOURLY shapes are the SIGNAL (55-64% vs 35% base).\nStats: SPY 60d 5m + 730d hourly, real-time simulation.", neutral)

// ---------------- Alerts ----------------
alertcondition(trigL, "HOURLY low-reversal signal", "Hourly reversal shape at session low - day-low odds 54-64%")
alertcondition(trigH, "HOURLY high-reversal signal", "Hourly rejection at session high - day-high odds 33-47%")
alertcondition(l5 == 2, "5m RevClose scout", "5m reversal-close at new session low (28% holds)")
````
