# Asian Range (Pre-London)

- url: https://www.tradingview.com/script/ZQqP5Wx7-Asian-Range-Pre-London/
- type: indicator
- pine_id: PUB;b5602b63db2f46acad7a83c4b6da1ae9
- version: 1.0

## Description

Asian Range (Pre-London) highlights the Asian trading session and marks its high and low, so you can see what the market did overnight before European traders arrive.

It's a clean, informational tool: it draws the range and its levels, and nothing else. No signals, no predictions.

WHAT IS THE ASIAN RANGE?

The Asian range is the high and the low that price makes during Asian trading hours. For EUR and GBP pairs, this is usually the quietest part of the 24-hour forex day. Studies of interbank trading data show that activity and volatility are highest at the market openings and during the London and New York overlap, and much lower for European currencies during Asian hours.

Because the Asian session is often a narrow, quiet range for these pairs, its high and low become clear reference points that many traders watch going into the London session.

WHY 00:00 TO 06:00 LONDON TIME?

There is no single official definition of the Asian session, so the default window is based on how liquidity moves through the day:

- It starts after the day roll. The period around 5pm New York time, when the trading day rolls over, is the least liquid part of the day. Bank pricing systems restart and spreads widen, which can create misleading wicks. Starting at 00:00 London avoids this period.
- It covers the core of Asian trading. Activity picks up at the Tokyo open (09:00 Tokyo time) and around the Tokyo fix (09:55 Tokyo time), a key reference rate where dollar/yen trading volume peaks.
- It ends before Europe arrives. Research shows European trading starts to move the market from around 07:00 London time. Ending at 06:00 keeps the range a clean picture of what happened before European flows begin.

The session is set in London time, so it adjusts automatically when the clocks change. You can change the start and end time in the settings.

WHY TRADERS WATCH THE ASIAN RANGE

- Orders tend to sit beyond obvious levels. Research on currency order flow found that stop-loss orders cluster just beyond round-number price levels. Traders apply the same logic to other highly visible levels, and the Asian high and low are among the most visible of the day. With much higher volume arriving at the London open, these nearby levels are more likely to be tested.
- Two possible outcomes when a level is taken. When price trades through the Asian high or low, it can either sweep the level (take the orders, then close back inside the range and reverse) or break out (the triggered orders add fuel and the move continues). The same research found that moves through clusters of stop-loss orders tend to accelerate, so a breakout is a real possibility, not just a sweep. Many traders watch how price closes after a level is taken to judge which one is unfolding.
- Quiet session, busier sessions ahead. Volatility in European currencies is typically much higher in the London and New York sessions than in Asia, so the quiet Asian range is usually followed by larger moves once Europe opens.
- Daily reference levels. The Asian high and low are commonly used as reference levels for the rest of the trading day, and previous days' Asian highs and lows can remain relevant too.
- Where to avoid trading. Price inside the Asian range is often slow and choppy, so many traders prefer to wait for London to choose a direction.

PAIRS DIFFER

- EUR and GBP pairs: Asia is genuinely quiet for these currencies, so the range usually forms during low activity, before the main European flows arrive.
- JPY, AUD and NZD pairs: Asia is the home session for these currencies, so the range reflects real, active trading rather than a quiet period. Keep this in mind when reading the range on these pairs.

WHAT THIS INDICATOR DOES

- Highlights the Asian session with a shaded range.
- Marks the session high and low with clean horizontal lines.
- Extends the high and low beyond the session, by default for 8 hours (until 14:00 London), covering the London session and the New York open.
- Keeps past days' ranges on the chart, so you can review and backtest how price behaved around them. Levels stay visible even after price trades through them.
- Works on any chart from 1 minute up to 1 hour.

SETTINGS

- Session (London time): start and end of the Asian range. Default 00:00 to 06:00.
- Display: Range + levels (default), Levels only, or Range only.
- Extend levels after session (hours): how long the high and low lines continue after the session ends. Set to 0 to end them with the session.
- Days to show: how many past days are drawn on the chart.
- Show high / low labels: adds "Asia High" and "Asia Low" labels at the end of the lines. Off by default.
- Style: range fill colour, line colour, line style (solid, dashed or dotted) and line width.

ALERTS

Two optional alerts are available in TradingView's alert menu:
- Asian high taken: price trades above the most recent completed Asian high.
- Asian low taken: price trades below the most recent completed Asian low.

NOTES

- The indicator only draws on 1-hour charts and lower. On higher timeframes a short note is shown instead.
- While the session is in progress, the high and low update live. They are final once the session ends.
- This is an analysis tool, not a buy or sell signal. Use it alongside your own analysis and risk management.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────
//  Asian Range
//  Built by Jake Koel  ·  © jakekoel
// ─────────────────────────────────────────────────────────────
// Highlights the Asian session and marks its high and low.
// The session is set in London time (clock changes handled automatically),
// default 00:00–06:00: after the 5pm New York day roll, covering the Tokyo open
// and Tokyo fix, and ending before European trading starts.
indicator("Asian Range", shorttitle = "Asian Range", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ───────────────────────── Inputs ─────────────────────────
string sessIn   = input.session("0000-0600", "Session (London time)", tooltip = "Start and end of the Asian range in London time. Clock changes are handled automatically.")
string display  = input.string("Range + levels", "Display", options = ["Range + levels", "Levels only", "Range only"])
int    extH     = input.int(8, "Extend levels after session (hours)", minval = 0, maxval = 18, tooltip = "How long the high and low lines continue after the session ends. 8 hours = until 14:00 London with the default session.")
int    maxDays  = input.int(30, "Days to show", minval = 1, maxval = 160)
bool   showLbl  = input.bool(false, "Show high / low labels")

string G_ST     = "Style"
color  fillCol  = input.color(color.new(#7E57C2, 88), "Range fill", group = G_ST)
color  lineCol  = input.color(#7E57C2, "High / low lines", group = G_ST)
string lineSt   = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = G_ST)
int    lineW    = input.int(1, "Line width", minval = 1, maxval = 4, group = G_ST)

// ───────────────────────── Session ─────────────────────────
const string TZ = "Europe/London"
const int    HOUR_MS = 3600000

bool tfOk    = timeframe.isintraday and timeframe.in_seconds() <= 3600
bool inSess  = tfOk and not na(time(timeframe.period, sessIn, TZ))
bool started = inSess and not inSess[1]
bool ended   = not inSess and inSess[1]

bool drawRange  = display != "Levels only"
bool drawLevels = display != "Range only"

lStyle = switch lineSt
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

// ───────────────────────── Drawing ─────────────────────────
type AsiaDay
    box   rng
    line  hiLn
    line  loLn
    label hiLb
    label loLb

var array<AsiaDay> history = array.new<AsiaDay>()
var float   aHi  = na
var float   aLo  = na
var AsiaDay cur  = na

// Last completed Asian range (used for alerts)
var float lastHi = na
var float lastLo = na

// Session starts: create the drawings for a new day
if started
    aHi := high
    aLo := low
    box  b  = drawRange  ? box.new(time, aHi, time, aLo, xloc = xloc.bar_time, border_color = na, bgcolor = fillCol) : na
    line hl = drawLevels ? line.new(time, aHi, time, aHi, xloc = xloc.bar_time, color = lineCol, style = lStyle, width = lineW) : na
    line ll = drawLevels ? line.new(time, aLo, time, aLo, xloc = xloc.bar_time, color = lineCol, style = lStyle, width = lineW) : na
    cur := AsiaDay.new(b, hl, ll, na, na)
    history.unshift(cur)
    // Keep only the chosen number of days
    if history.size() > maxDays
        AsiaDay old = history.pop()
        box.delete(old.rng)
        line.delete(old.hiLn)
        line.delete(old.loLn)
        label.delete(old.hiLb)
        label.delete(old.loLb)

// During the session: track the high and low and stretch the drawings
if inSess and not na(cur)
    aHi := math.max(aHi, high)
    aLo := math.min(aLo, low)
    if not na(cur.rng)
        cur.rng.set_top(aHi)
        cur.rng.set_bottom(aLo)
        cur.rng.set_right(time)
    if not na(cur.hiLn)
        cur.hiLn.set_y1(aHi)
        cur.hiLn.set_y2(aHi)
        cur.hiLn.set_x2(time)
        cur.loLn.set_y1(aLo)
        cur.loLn.set_y2(aLo)
        cur.loLn.set_x2(time)

// Session ends: close the range and extend the levels
if ended and not na(cur)
    int endT = time
    int lvlT = endT + extH * HOUR_MS
    if not na(cur.rng)
        cur.rng.set_right(endT)
    if not na(cur.hiLn)
        cur.hiLn.set_x2(lvlT)
        cur.loLn.set_x2(lvlT)
        if showLbl
            cur.hiLb := label.new(lvlT, aHi, "Asia High", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = lineCol, size = size.small)
            cur.loLb := label.new(lvlT, aLo, "Asia Low", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = lineCol, size = size.small)
    lastHi := aHi
    lastLo := aLo

// ───────────────────────── Alerts ─────────────────────────
bool tookHigh = not inSess and not na(lastHi) and high > lastHi and high[1] <= lastHi
bool tookLow  = not inSess and not na(lastLo) and low < lastLo and low[1] >= lastLo
alertcondition(tookHigh, "Asian high taken", "Price traded above the Asian range high")
alertcondition(tookLow, "Asian low taken", "Price traded below the Asian range low")

// ───────────────────────── Notice + signature ─────────────────────────
var table info = table.new(position.bottom_right, 1, 2)
if barstate.islast
    if not tfOk
        table.cell(info, 0, 0, "Asian Range works on 1-hour charts and lower", text_color = color.gray, text_size = size.small)
    table.cell(info, 0, 1, "@jakekoel", text_color = color.new(color.gray, 30), text_size = size.small)
````
