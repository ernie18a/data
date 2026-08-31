<!-- tradingview-pine-id: PUB;2e3cebda28044fb5b3330426bcc050b0 -->
<!-- tradingviewscripts-format: 1 -->
# VWAP — Daily / Weekly / Monthly

Source: https://www.tradingview.com/script/iwgJZyhr-EWS-Anchored-VWAP-Indicator/

## Description

VWAP — Daily / Weekly / Monthly

Three independently anchored volume weighted average prices on one chart. Each
one resets on the first tick of a new day, week and month, so you always see
where the daily, weekly and monthly volume has actually been transacted rather
than a single rolling average.

WHAT IT DOES

VWAP is the average price of every trade in a period, weighted by size. It is
the reference price large orders are measured against, which is why price so
often gravitates back to it. A daily VWAP tells you who is winning the session,
a weekly VWAP frames the swing, and a monthly VWAP marks the level that
positional money is anchored to. Having all three at once shows you when they
stack up (trend) and when they pinch together (compression before expansion).

Each VWAP is accumulated bar by bar from the raw price and volume of the chart
you are on. Nothing is smoothed, averaged again, or borrowed from a higher
timeframe request, so there is no repainting and no lag beyond the data itself.

ANCHORING

The whole point of a periodic VWAP is where it resets, so the anchor is
configurable rather than assumed.

Session (exchange) resets when TradingView opens a new daily, weekly or monthly
bar. This respects the symbol's real session, so a futures day correctly begins
at 18:00 the previous evening and a stock day begins at the opening bell. This
matches the behaviour of the built-in VWAP.

Calendar resets at 00:00 in a timezone you choose: the exchange timezone, UTC,
or any IANA timezone you type in. This is normally what you want on 24/7 crypto,
where there is no session and the market convention is a UTC day.

Pick the mode that matches how you actually think about the instrument. For
crypto, Calendar UTC. For futures, FX and equities, Session.

FEATURES

Daily, weekly and monthly VWAP, each with its own colour, line width and
on/off switch.

Optional standard deviation bands on any of the three, with a configurable
multiplier and a shaded fill. The deviation is volume weighted from the same
accumulator as the VWAP itself, not a simple standard deviation of price.

Show only the current period. Hides every completed day, week and month and
draws just the anchors that are still building. Useful when you only trade the
live level and want the history out of the way.

Auto-hide. A daily VWAP on a daily chart is just the bar itself, so anchors
that are meaningless on the current timeframe are hidden automatically. Can be
turned off.

Line breaks at each reset, so you do not get a vertical spike connecting the
end of one period to the start of the next.

Value labels at the right edge showing the live price of each VWAP.

Alerts for price crossing the daily, weekly or monthly VWAP.

Selectable source, defaulting to hlc3, which is the standard VWAP price.

NOTES

The indicator needs real volume. If the symbol's data feed provides none, it
will tell you instead of silently drawing a flat line. Some index and CFD style
tickers have no volume; use an exchange specific ticker in that case.

Values update on every tick. When a new period begins, the reset happens on the
first tick of that period's first bar. You do not have to wait for a bar to
close.

This is a reference and context tool, not a signal generator. VWAP tells you
where value is, not which way price is going next. Use it to frame entries,
size risk against a level, and judge whether a move is extended, and combine it
with your own method rather than trading crosses on their own.

---

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
//  VWAP — Daily / Weekly / Monthly
//  Three independently-anchored volume weighted average prices that reset on
//  the first tick of every new day / week / month.
// ─────────────────────────────────────────────────────────────────────────────
indicator("VWAP — Daily / Weekly / Monthly", "VWAP D/W/M", overlay = true, max_labels_count = 20)

// ── General inputs ──────────────────────────────────────────────────────────
gGen = "General"

src = input.source(hlc3, "Source", group = gGen,
     tooltip = "hlc3 is the standard VWAP price. Use close if you want it to hug the closes.")

anchorMd = input.string("Session (exchange)", "Anchor mode",
     options = ["Session (exchange)", "Calendar (exchange timezone)", "Calendar UTC", "Calendar (custom timezone)"],
     group = gGen,
     tooltip = "Session  — resets when TradingView opens a new D/W/M bar. Matches the built-in VWAP and is correct for futures/FX/stocks with overnight or extended sessions.\n\n" +
               "Calendar — resets at 00:00 of the chosen timezone. This is normally what you want on 24/7 crypto (pick UTC to match how most exchanges define a day).")

tzIn = input.string("America/New_York", "Custom timezone", group = gGen,
     tooltip = "IANA name (America/New_York, Europe/London, Asia/Tokyo) or a UTC offset like 'UTC+2'. Only used by the 'custom timezone' anchor mode.")

onlyCur   = input.bool(false, "Show only the current (in-progress) period", group = gGen,
     tooltip = "Hides every completed day/week/month and draws only the VWAP that is still building. Keeps the chart clean when you only trade the live anchor.")
autoHide  = input.bool(true, "Auto-hide an anchor when chart TF >= that anchor", group = gGen,
     tooltip = "A daily VWAP on a daily chart is just the bar itself. This hides anchors that are meaningless on the current timeframe.")
breakLine = input.bool(true, "Break the line at each new period", group = gGen,
     tooltip = "Prevents the vertical jump between the end of one period and the start of the next.")
showTag   = input.bool(true, "Show value labels on the last bar", group = gGen)
showAlert = input.bool(true, "Enable price-cross alerts", group = gGen)

// ── Per-anchor inputs ───────────────────────────────────────────────────────
gD = "Daily VWAP"
dOn   = input.bool(true,     "Show",     group = gD, inline = "d1")
dCol  = input.color(#2962FF, "",         group = gD, inline = "d1")
dWid  = input.int(2, "Width", minval = 1, maxval = 4, group = gD, inline = "d1")
dBOn  = input.bool(false,   "Std-dev bands  ×", group = gD, inline = "d2")
dBMul = input.float(1.0, "", minval = 0.1, step = 0.1, group = gD, inline = "d2")

gW = "Weekly VWAP"
wOn   = input.bool(true,     "Show",     group = gW, inline = "w1")
wCol  = input.color(#FF6D00, "",         group = gW, inline = "w1")
wWid  = input.int(2, "Width", minval = 1, maxval = 4, group = gW, inline = "w1")
wBOn  = input.bool(false,   "Std-dev bands  ×", group = gW, inline = "w2")
wBMul = input.float(1.0, "", minval = 0.1, step = 0.1, group = gW, inline = "w2")

gM = "Monthly VWAP"
mOn   = input.bool(true,     "Show",     group = gM, inline = "m1")
mCol  = input.color(#AA00FF, "",         group = gM, inline = "m1")
mWid  = input.int(2, "Width", minval = 1, maxval = 4, group = gM, inline = "m1")
mBOn  = input.bool(false,   "Std-dev bands  ×", group = gM, inline = "m2")
mBMul = input.float(1.0, "", minval = 0.1, step = 0.1, group = gM, inline = "m2")

// ── Anchor detection ────────────────────────────────────────────────────────
// Session mode uses TradingView's own D/W/M bar boundaries (respects the
// symbol's session, so a futures day starts at 18:00 the previous evening).
// Calendar mode compares the date parts of each bar's open time in a timezone.
tz = switch anchorMd
    "Calendar UTC"                  => "UTC"
    "Calendar (custom timezone)"    => tzIn
    =>                                 syminfo.timezone

useSession = anchorMd == "Session (exchange)"

// True when the value differs from the previous bar. na on bar 0 -> false,
// which is fine: the accumulators already start empty there.
f_changed(int cur) =>
    na(cur[1]) ? false : cur != cur[1]

newD = useSession ? timeframe.change("D") : f_changed(dayofmonth(time, tz))
newW = useSession ? timeframe.change("W") : f_changed(weekofyear(time, tz))
newM = useSession ? timeframe.change("M") : f_changed(month(time, tz))

// ── "Current period" test (for the show-only-current option) ────────────────
// `last_bar_time` is the open time of the final bar in the dataset and is
// available on every bar, so this is decided from the data rather than the
// wall clock — the live anchor stays drawn while the market is closed.
int refT = last_bar_time

bool isCurD = useSession ? time_close("D") > refT :
     dayofmonth(time, tz) == dayofmonth(refT, tz) and month(time, tz) == month(refT, tz) and year(time, tz) == year(refT, tz)
bool isCurW = useSession ? time_close("W") > refT :
     weekofyear(time, tz) == weekofyear(refT, tz) and year(time, tz) == year(refT, tz)
bool isCurM = useSession ? time_close("M") > refT :
     month(time, tz) == month(refT, tz) and year(time, tz) == year(refT, tz)

// ── Volume ──────────────────────────────────────────────────────────────────
vol = nz(volume)

// Evaluated unconditionally on every bar: ta.cum() depends on its own history,
// so it must not sit inside a conditional expression.
float cumVol = ta.cum(vol)

if barstate.islastconfirmedhistory and cumVol == 0
    runtime.error("VWAP D/W/M: this symbol provides no volume data, so a volume weighted average price cannot be calculated. Try the same pair on an exchange-specific ticker (e.g. BINANCE:BTCUSDT instead of an index/CFD feed).")

// ── VWAP engine ─────────────────────────────────────────────────────────────
// `var` accumulators are rolled back by Pine on every realtime recalculation,
// so the running values are tick-accurate and the reset lands on the very
// first tick of the new period's bar.
f_vwap(float source, float v, bool reset) =>
    var float sumPV  = 0.0
    var float sumV   = 0.0
    var float sumP2V = 0.0
    if reset
        sumPV  := 0.0
        sumV   := 0.0
        sumP2V := 0.0
    sumPV  += source * v
    sumV   += v
    sumP2V += source * source * v
    float vw  = sumV > 0 ? sumPV / sumV : na
    float var_ = sumV > 0 ? math.max(sumP2V / sumV - vw * vw, 0.0) : na
    [vw, math.sqrt(var_)]

[dVwap, dSd] = f_vwap(src, vol, newD)
[wVwap, wSd] = f_vwap(src, vol, newW)
[mVwap, mSd] = f_vwap(src, vol, newM)

// ── Visibility ──────────────────────────────────────────────────────────────
int chartSec = timeframe.in_seconds(timeframe.period)
bool okD = dOn and (not autoHide or chartSec < timeframe.in_seconds("D"))
bool okW = wOn and (not autoHide or chartSec < timeframe.in_seconds("W"))
bool okM = mOn and (not autoHide or chartSec < timeframe.in_seconds("M"))

// In current-only mode the break is skipped, so the line starts right on the
// anchor bar instead of losing its first point.
f_show(float v, bool visible, bool isNew, bool isCur) =>
    not visible ? na : onlyCur and not isCur ? na : breakLine and not onlyCur and isNew ? na : v

dLine = f_show(dVwap, okD, newD, isCurD)
wLine = f_show(wVwap, okW, newW, isCurW)
mLine = f_show(mVwap, okM, newM, isCurM)

dUp = f_show(dVwap + dBMul * dSd, okD and dBOn, newD, isCurD)
dDn = f_show(dVwap - dBMul * dSd, okD and dBOn, newD, isCurD)
wUp = f_show(wVwap + wBMul * wSd, okW and wBOn, newW, isCurW)
wDn = f_show(wVwap - wBMul * wSd, okW and wBOn, newW, isCurW)
mUp = f_show(mVwap + mBMul * mSd, okM and mBOn, newM, isCurM)
mDn = f_show(mVwap - mBMul * mSd, okM and mBOn, newM, isCurM)

// ── Plots ───────────────────────────────────────────────────────────────────
plot(dLine, "Daily VWAP",   dCol, dWid, plot.style_linebr)
plot(wLine, "Weekly VWAP",  wCol, wWid, plot.style_linebr)
plot(mLine, "Monthly VWAP", mCol, mWid, plot.style_linebr)

pDU = plot(dUp, "Daily +σ",   color.new(dCol, 45), 1, plot.style_linebr)
pDD = plot(dDn, "Daily -σ",   color.new(dCol, 45), 1, plot.style_linebr)
pWU = plot(wUp, "Weekly +σ",  color.new(wCol, 45), 1, plot.style_linebr)
pWD = plot(wDn, "Weekly -σ",  color.new(wCol, 45), 1, plot.style_linebr)
pMU = plot(mUp, "Monthly +σ", color.new(mCol, 45), 1, plot.style_linebr)
pMD = plot(mDn, "Monthly -σ", color.new(mCol, 45), 1, plot.style_linebr)

fill(pDU, pDD, color.new(dCol, 92), "Daily band fill")
fill(pWU, pWD, color.new(wCol, 92), "Weekly band fill")
fill(pMU, pMD, color.new(mCol, 92), "Monthly band fill")

// ── Right-edge value labels ─────────────────────────────────────────────────
// One label per call site, created once and then repositioned. A label whose
// y is na simply isn't drawn, so hiding needs no delete/recreate dance.
f_tag(bool visible, float v, string txt, color c) =>
    var label lb = label.new(bar_index, na, "", style = label.style_label_left,
         color = color.new(color.black, 100), size = size.small)
    if barstate.islast
        bool ok = visible and not na(v)
        label.set_xy(lb, bar_index, ok ? v : na)
        label.set_text(lb, ok ? txt + "  " + str.tostring(v, format.mintick) : "")
        label.set_textcolor(lb, c)

f_tag(showTag and okD, dVwap, "D",  dCol)
f_tag(showTag and okW, wVwap, "W",  wCol)
f_tag(showTag and okM, mVwap, "M",  mCol)

// ── Alerts ──────────────────────────────────────────────────────────────────
alertcondition(showAlert and okD and ta.cross(close, dVwap), "Cross Daily VWAP",   "{{ticker}} crossed the Daily VWAP")
alertcondition(showAlert and okW and ta.cross(close, wVwap), "Cross Weekly VWAP",  "{{ticker}} crossed the Weekly VWAP")
alertcondition(showAlert and okM and ta.cross(close, mVwap), "Cross Monthly VWAP", "{{ticker}} crossed the Monthly VWAP")
````
