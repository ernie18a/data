<!-- tradingview-pine-id: PUB;72c1cc6be8c44d0ca7126044436f6dd2 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# IPDA Year Map (M1D)

Source: https://www.tradingview.com/script/9479px86-IPDA-Year-Map-M1D/

## Description

IPDA Year Map draws the window the Interbank Price Delivery Algorithm is said to reference — the 20, 40 and 60 day look-back highs and lows — and puts it on a year of quarterly dividers rather than on a rolling snapshot. Every level carries how many sessions it has left before the candle that set it ages out of that window and stops being a reference at all.

The idea it implements is simple and it is the reason for every design decision below. The algorithm does not see a chart. It references days as data points inside a fixed look-back, and once a level falls outside 60 trading days it is purged. So the useful questions are which levels are still inside the window, where in the window they sit, and when each one leaves. Most range tools answer the first. This one answers all three.

The data range

Three nested look-backs, computed on daily closes: 20 days for the near-term read, 40 for the intermediate, 60 as the outer edge of what is still referenced. Each contributes its high and its low, drawn from the candle that actually set it and running forward to the current bar. Six extremes, and that is the whole object — the script does not go hunting for additional pools, order blocks or gaps to decorate it with.

The levels come from the daily timeframe regardless of what the chart is showing, so a 60-day window exists on a 1 minute chart where only a fortnight of chart candles is loaded.

Each level's origin is found from the offset back to the extreme candle, not from watching the value change. Those are different things and the difference is visible. A rolling minimum moves for two reasons: a lower low prints, or an older and deeper low ages out of the window and the minimum steps up to whatever is left. Only the first is a candle forming a level. Anchoring on "the value changed" attaches the line to the day the old low expired, which can be months after the candle that actually set the price.

One price is one line

A high made inside the last 20 sessions is simultaneously the 20, 40 and 60 day high. Drawn as three separate levels that is three lines and three captions stacked on a single row of pixels, and the top of the chart reads as one anonymous level while the lows — which genuinely differ — read as three.

Levels at the same price are drawn once, captioned with every window that shares them, as in 20·40·60d high. Each side of the range then shows exactly as many lines as it has distinct prices. The caption also tells you when a level stops being the tightest one: a shared high loses the 20 from the front of its name the day the 20-day window moves on without it.

Levels that are merely close rather than identical still collide on screen, so each caption steps out to its own lane along the right of the chart until it is clear of the ones above it. No two captions share a row at any zoom.

Equilibrium

Each window can carry the midpoint of its own high and low — the premium and discount divide of that range. Three switches, one per window.

They are drawn dotted and neutral. Dotted because an equilibrium is a calculated reference and not a price that traded, and neutral because a midpoint is neither bullish nor bearish. Each runs from its own window's left edge rather than from a candle, since no single candle sets a midpoint.

The roll-out countdown

Every level and every equilibrium carries the sessions it has left inside its window, printed on its caption as out 12d. When the count reaches its last session the caption reads out next instead.

The arithmetic is the window length less the level's age, both in trading days. A high set yesterday sits in the 20-day window for 19 more sessions; one set 19 sessions ago leaves at the next close. This is also why a 60-day level can date back around 83 calendar days — 60 trading days is twelve weeks, and 24 of those days are weekend.

Two things it states rather than glosses over. The count is measured from the last completed daily close, so today's session is one of them. And it is the origin candle leaving that is counted — the printed level only actually moves if nothing else still inside the window matches that price.

For a level shared by several windows the countdown belongs to the widest one, because that is when it stops being referenced at all. An equilibrium's countdown is the sooner of its two extremes, since it moves the moment either side of it ages out.

The shift, and the sixty day budget

A market structure shift here is a liquidity raid: a day taking out the highest high, or the lowest low, of the days before it. The look-back is an input. Raise it to ignore the smaller shifts inside a range and find only the major one — in ICT's framing the real shift can sit two or three months back, so a reading of no shift found is an instruction to widen the search before concluding there isn't one.

A confirmed shift stands for its full 60-day budget. A later raid in the same direction inside that budget is a mini shift within the range and does not restart the clock; only a raid in the opposite direction, or one arriving after the budget is spent, places a new anchor. Without that rule a trending market would reset the count every few sessions and the budget would never be seen counting down.

The raid is marked with a vertical, and three more are projected forward from it at 20, 40 and 60 trading days, weekends skipped. The last is the point at which the 60-day budget from that shift is spent. The projection counts weekdays; the panel counts sessions the symbol actually traded, so a weekday the exchange was closed puts the chart marker one session ahead of the panel's count, and the panel says so.

The panel reports the same thing in numbers: when the shift happened, sessions elapsed, and sessions left of the 60. Its header reads IN BUDGET while the count runs, DUE SOON at five or fewer sessions left, and BUDGET SPENT past 60 — at which point the projections come off the chart rather than being extended into a window that no longer exists.

There is only one forward boundary and the arithmetic is worth seeing, because it looks like two:

today + (60 − elapsed) = (shift + elapsed) + (60 − elapsed) = shift + 60

The cast-forward target and the budget expiry are the same date. Drawing both would be drawing one fact twice.

Anchored to the minute

A raid found on chart candles lands on the chart's own grid, so on a 1 hour chart the shift marker can sit up to 59 minutes away from where the level was actually taken. The raid candle is re-read at 1 minute resolution and the marker placed at the first minute the prior extreme was genuinely exceeded.

TradingView only serves intrabar data for recent history. Where it is not available the marker falls back to chart-candle resolution, the tag carries a ~ mark, and the panel says which of the two it used. It never claims a precision it did not get.

Open interest

Where the instrument publishes an open interest series, the panel reports its change over a set window — 20 trading days by default, matching the innermost look-back — against price over the same window, and states a reading only where the arithmetic supports one: a fall of 15% or more on flat price, both falling together, both rising together, or no clear read. Open interest is a daily series whatever the chart shows, so the reading is the same on a 1 minute chart and a daily one.

The two sign readings compare only the direction of two changes, so they sit behind a floor: the open interest change must be abnormal and price must not be flat. The default floor of 10% was measured rather than chosen. Over 400 sessions with the quarterly roll weeks removed, the 90th percentile of the 20-day open interest change was about 14% on NQ and about 7% on ES; 10% sits between them. NQ's open interest runs roughly twice as noisy as ES's, so a chart dedicated to one instrument may want the floor moved.

The contract roll is refused outright. A continuous contract's open interest collapses by a third to a half in a session as the front month is abandoned, then rebuilds over the following week, and a window that spans one cannot be read for positioning. The panel fetches the largest one-day jump inside the window and, above 12%, reads contract roll instead of a signal until the window has cleared it.

Most instruments publish nothing. On those the panel names the symbol it looked for and says the reading is unavailable. It does not print a zero, and it does not infer open interest from volume or anything else.

The year map

Quarterly dividers run across the loaded history and project forward, so the year reads as quadrants rather than as one rolling window. Two spacings are offered — three month and four month — because ICT's IPDA material carries both as worked examples anchored at different points. They are the same rule applied from different places, not rival calendars, which is why this is a choice of grid rather than a claim about which one is correct. The 60-day look-back and look-forward is measured from wherever a shift actually sits, independently of the grid.

Keeping it readable

The vertical tags ride two rails outside the range — budget markers on the inner rail, the calendar on the outer — offset by a fraction of the 60-day range rather than by ATR. On a chart spanning a year an ATR cushion is a rounding error, which puts the tags inside the candles and on the same row as the level captions.

Because the range is the unit of measurement throughout, the spacing holds on any instrument and any timeframe without tuning.

By default every extreme is drawn black. The six levels are liquidity, and liquidity is neither bullish nor bearish — a level tinted by the direction of the last shift would be a bias call the script has no basis for. Which window a level belongs to is in its caption.

Each line family carries its own colour and width: the 60, 40 and 20 day levels, the equilibriums, the shift verticals and the calendar dividers. The defaults are set for a grey chart, where the usual light-grey neutral is the background itself and vanishes, so the secondary families use a dark slate instead. A level shared by several windows takes the colour and width of its tightest one. The panel header field has its own colour.

Non-repainting

Every daily figure is read from confirmed candles. Nothing is revised once its candle has closed, and no level, count or projection moves in hindsight. The lines extend rightward to the current bar while they are live — that is the drawing tracking the present, not its history changing.

Alerts

Three: a new shift confirmed and the 60-day budget restarted, fired on the close of the bar that placed the anchor; five or fewer sessions left of the budget; and the budget spent. The last two are evaluated once per day.

What it will not do

It places no entries, exits, stops or targets, and it does not size a position. It draws no bias, no trend and no projection of where price is going. A shift marker says a level was taken on that day; it does not say what happens next.

It does not rank the levels against each other or tell you which one price is drawn to. Whether a level inside the window is worth trading is a judgement about context this script does not have — session, higher timeframe draw, and what the day has already done.

It has no opinion on open interest where none is published, and no opinion on direction where the arithmetic does not support one. Both are stated as unavailable rather than filled in.

Settings

Quarterly dividers with their spacing and how far forward they project; the 20, 40 and 60 day bands each on their own switch; equilibrium on its own switch per window; the shift clock panel with its raid look-back and its minute-anchoring toggle; open interest with its comparison window and abnormal-move floor; and label size, tag rail offset, whether tags sit above or below the candles, right offset, the panel header colour, and a colour and width for each line family.

Attribution

IPDA, the 20/40/60 day look-back and the market structure shift are concepts from ICT's public teaching material. This is an original implementation of them. No third-party code is used.

Disclaimer

This is a decision-support tool for discretionary ICT trading. It is not financial advice, and no market's past behaviour is indicative of future results.

---

## Source Code

````pine
//@version=6
// ============================================================================
// IPDA Year Map (M1D)
// ----------------------------------------------------------------------------
// ORIGINAL M1D BUILD. ICT's IPDA (Interbank Price Delivery Algorithm) is public
// teaching material nobody owns. The concept reference for this script is the
// pinescript-v6-syntax skill's references/ict-ipda.md; read it before editing.
//
// WHAT IT DRAWS, AND WHY IT LOOKS THE WAY IT DOES
// ------------------------------------------------
// The IPDA data range as ICT draws it: a vertical anchor at the market
// structure shift, and the 20 / 40 / 60 day look-back HIGHS and LOWS drawn as
// horizontal bands running forward from the candle that formed each one. Six
// levels, nesting (20 inside 40 inside 60). That is the whole object.
//
// It replaces an earlier attempt that drew every "unpurged pool" it could find
// - a dozen scattered lines that were noisy and were not the IPDA construct at
// all. If a future edit is tempted back toward hunting for more LEVELS, the
// answer is no: six extremes is the object.
//
// Each window also carries its EQUILIBRIUM, the midpoint of its own high and
// low - the premium/discount divide an IPDA range is worked against. That is
// not a seventh level being hunted for; it is derived from two of the six, and
// it is drawn dotted and neutral so it can never be mistaken for a price that
// traded. Toggled per window.
//
// EVERY LEVEL IS BLACK. The extremes are liquidity, and the visual standard is
// explicit that liquidity is neither bullish nor bearish and is never coloured
// by direction. An earlier revision tinted the 20-day pair by the last shift's
// direction, which read as a bias call the script has no basis for - and as
// bull purple when no shift had been found at all. Window identity lives in the
// caption, which every level carries.
//
// SIX LEVELS, BUT NOT ALWAYS SIX LINES. A high made inside the last 20 sessions
// IS the 20, 40 and 60 day high at once. Drawn separately that is three lines
// and three captions sharing one pixel row, so the top of the map reads as a
// single anonymous level while the lows - which genuinely differ - read as
// three. Levels at the same price are merged into ONE line captioned
// "20·40·60d high", which is what makes the two halves of the map symmetrical:
// each side now shows as many lines as it has distinct prices.
//
// NOTHING SHARES A ROW. Levels that are merely CLOSE still collide, so each
// caption steps out a lane to the right until it is clear of the ones above it.
// The vertical tags ride two rails OUTSIDE the 60-day range - budget markers on
// the inner rail, the calendar on the outer - measured as a fraction of that
// range. They used to be cushioned by ATR, which on a year map is a rounding
// error, so they sat inside the candles on the same row as the level captions.
//
// THE YEAR MAP. Quarterly dividers are drawn across the whole loaded range and
// projected forward, so the year reads as quadrants rather than as one rolling
// window. ICT's two divider sets (Jan/May/Sep and Dec/Mar/Jun/Sep) are the
// same rule applied from different anchor points, not two rival calendars, so
// the spacing is an input rather than a hardcoded month list, and 60 days is
// always the look-back and look-forward from whatever point a shift actually
// sits at.
//
// THE CLOCK. The 60-day budget reading is kept as a panel: days elapsed since
// the last confirmed raid and days remaining. Its arithmetic collapses in a
// way worth knowing:
//     today + (60 - daysSince) = (shift + daysSince) + (60 - daysSince)
//                              = shift + 60
// The cast-forward target and the budget expiry are THE SAME DATE. One
// boundary, not two - drawing both would be drawing one fact twice.
//
// The clock is NOT restarted by every raid. In IPDA a shift stands for its
// full 60-day budget, and a same-direction raid inside that budget is a mini
// shift within the range - it does not invalidate the anchor. Only an opposite
// raid (a reversal) or a raid arriving after the budget is spent re-anchors.
// An earlier revision restarted on every raid, which in a trending market
// reset the count every few sessions and never let the budget count down.
//
// There is deliberately no "sweet spot" as a time window here. In ICT's
// framing the sweet spot is the 20-day LOOK-BACK range - already drawn as the
// innermost band - not days 20-40 after a shift.
//
// MINUTE-EXACT ANCHORING. A raid detected on chart bars lands on the chart's
// own grid - on a 1h chart the divider can sit
// up to 59 minutes from where the level was actually taken. So the raid bar is
// refined with request.security_lower_tf() at "1": the intrabar stream for that
// bar is scanned for the first minute the prior extreme was exceeded, and the
// anchor is placed there. TradingView only serves intrabars for recent history,
// so when they are unavailable the anchor falls back to chart-bar precision and
// THE PANEL SAYS WHICH IT USED. It never claims a precision it did not get.
//
// DAILY DATA COMES FROM request.security, NOT FROM ACCUMULATED CHART BARS.
// An earlier revision built its daily series by accumulating chart bars, which
// caps the history at however many days the chart has loaded - on a 1-minute
// chart that is about a fortnight, so a 60-day window silently could not be
// built. The ranges are computed inside the daily context instead, where the
// full daily history exists regardless of what the chart is showing.
//
// OPEN INTEREST is requested from the "_OI" companion symbol, built from
// syminfo.prefix + syminfo.ticker and NOT from syminfo.tickerid - tickerid
// carries the chart settings inside the string, so appending "_OI" to it
// produces an unparseable symbol on any chart with settlement-as-close or
// an adjustment toggled. Most instruments publish no OI series at all; when
// it is absent the panel names the symbol it tried and says the reading is
// unavailable. It never renders a zero or a blank as a reading.
// ============================================================================
// INTERNAL BUILD STAMP - internal only, never in the shorttitle.
const string BUILD = "ymap-r11"

indicator("IPDA Year Map (M1D)", "IPDA (M1D)", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// == ORIGIN GUARD ==
// A drawing anchored on a stored origin can sit thousands of chart bars back. Placing that x walks the
// `time` series to it, and Pine auto-sizes that buffer from what history happened to need, so a live bar
// that needs one more kills the whole script ("requested historical offset is beyond the historical
// buffer's limit"). Function form buffers `time` alone; anything older than ORIGIN_MAX clamps to the
// buffer's edge and draws short from the left instead of crashing.
const int ORIGIN_MAX = 4900
max_bars_back(time, 5000)
//@function Clamps a bar-time anchor to the oldest bar the drawing engine can still place.
//@param t (int) The stored origin time.
//@returns (int) t, or the time of the oldest reachable bar when t is older than that.
f_xClamp(int t) =>
    math.max(t, time[math.min(bar_index, ORIGIN_MAX)])


//#region[Inputs]
const string G_MAP = "Year map"
const string G_RNG = "IPDA data ranges"
const string G_CLK = "Shift clock"
const string G_OI  = "Open interest"
const string G_STY = "Style"

bool   showDiv   = input.bool(true, "Quarterly dividers", group = G_MAP)
string divSpace  = input.string("3 months (Dec · Mar · Jun · Sep)", "Divider spacing", group = G_MAP,
     options = ["3 months (Dec · Mar · Jun · Sep)", "4 months (Jan · May · Sep)"],
     tooltip = "ICT's IPDA material carries both divider sets as worked examples. They are the same rule applied from different anchor points, not two rival calendars - so this is a choice of grid, and 60 days remains the look-back and look-forward from wherever a shift actually sits.")
int    fwdMonths = input.int(6, "Project dividers forward (months)", minval = 0, maxval = 24, group = G_MAP)

bool showRanges = input.bool(true, "20 / 40 / 60 day range bands", group = G_RNG)
bool show20     = input.bool(true, "20", group = G_RNG, inline = "r")
bool show40     = input.bool(true, "40", group = G_RNG, inline = "r")
bool show60     = input.bool(true, "60", group = G_RNG, inline = "r")

bool showEQs = input.bool(true, "Equilibrium of each range", group = G_RNG,
     tooltip = "The midpoint between a window's own high and low - the premium/discount divide an IPDA range is worked against.\n\nDrawn DOTTED and neutral, per the house standard: dotted marks a reference rather than a level price actually traded at, and an equilibrium is neither bullish nor bearish. Each one runs from its own window's left edge, because a midpoint is a property of the whole window and not of any one candle.\n\nIts countdown is the SOONER of its two extremes - an EQ moves the moment either side of it ages out.")
bool eq20on  = input.bool(true, "20", group = G_RNG, inline = "e")
bool eq40on  = input.bool(true, "40", group = G_RNG, inline = "e")
bool eq60on  = input.bool(true, "60", group = G_RNG, inline = "e")

bool showClock = input.bool(true,  "Shift clock panel", group = G_CLK)
int  raidLen   = input.int(10, "Raid look-back (trading days)", minval = 3, maxval = 40, group = G_CLK,
     tooltip = "A shift is confirmed when a day takes out the highest high (or lowest low) of the N days before it - ICT's definition of an IPDA market structure shift as a liquidity raid.\n\nA confirmed shift stands for its full 60-day budget. A later raid in the SAME direction inside that budget is a mini shift within the range and does not restart the clock; only an opposite raid, or one arriving after the budget is spent, re-anchors.\n\nRaise the look-back to ignore mini shifts and find only the major one. In ICT's framing the real shift can sit 2-3 months back, so if the panel reads NO SHIFT FOUND, widen this before assuming there isn't one.")
bool minuteFix = input.bool(true, "Refine the anchor to the exact minute", group = G_CLK,
     tooltip = "Scans the raid bar's 1-minute intrabars for the first minute the prior extreme was exceeded, and anchors there instead of on the chart's bar grid.\n\nTradingView only serves intrabars for recent history. Where they are missing the anchor uses chart-bar precision and the panel says so - shown with a ~ on the chart tag.\n\nThis does not change the script's cost: the intrabar request runs either way, because a request called only on some bars returns a series with holes in it. The toggle chooses whether the anchor USES minute data, not whether it is fetched.")

bool showOI = input.bool(true, "Read open interest", group = G_OI,
     tooltip = "Requested from this symbol's \"_OI\" companion series - the bare exchange:ticker with _OI appended, never the chart's modified ticker id. Most instruments do not publish one; when that is the case the panel names the symbol it tried and says open interest is unavailable rather than showing a zero.")
int  oiLook = input.int(20, "OI comparison window (days)", minval = 2, maxval = 60, group = G_OI,
     tooltip = "Open interest is a daily series whatever the chart timeframe - the exchange publishes one figure per session - so this window is in trading days and the reading is identical on a 1-minute chart and a daily one. 20 days matches the innermost IPDA look-back.")
float oiMin = input.float(10.0, "OI move that counts as abnormal (%)", minval = 0.0, maxval = 50.0, step = 0.5, group = G_OI,
     tooltip = "The floor an open interest change must clear before the sell-program or trend-funded reading is stated. Those two compare only the direction of the OI change with the direction of price, so without a floor ordinary drift would read as a program.\n\nThe default is measured, not guessed: over 400 sessions with the quarterly roll weeks removed, the 90th percentile of the 20-day OI change was about 14% on NQ and about 7% on ES. 10% sits between them - above three-quarters of NQ's windows and nearly all of ES's. NQ's open interest runs roughly twice as noisy as ES's, so a chart dedicated to one may raise or lower this.\n\nPrice only has to be NOT FLAT (1% or more, the same line the bullish reading uses for flat). The 15% bullish-on-flat-price reading carries its own threshold and is not affected.")

string lblSizeIn  = input.string("small", "Label text size", options = ["tiny", "small", "normal", "large"], group = G_STY)
float  railPad    = input.float(0.10, "Tag rail offset (x 60d range)", minval = 0.0, maxval = 0.6, step = 0.01, group = G_STY,
     tooltip = "How far the vertical tags sit outside the 60-day range, as a fraction of that range's height.\n\nMeasured against the range and not against ATR: on a year map an ATR cushion is a rounding error, which is what put the tags inside the candles.")
bool   tagsBelow  = input.bool(true, "IPDA tags below candles", group = G_STY)
int    runwayBars = input.int(10, "Right offset (bars)", minval = 0, maxval = 100, group = G_STY)
color  headCol    = input.color(color.new(#A06BFF, 62), "Panel header", group = G_STY)

// One colour and one width per line family. The defaults are the grey-chart
// look: black for the 60 and 20 day extremes and the shift verticals, a dark
// slate for the 40-day pair, the equilibriums and the calendar - on a grey
// chart the standard's #787B86 neutral IS the background and vanishes, so the
// slate is the visible stand-in. On a white chart set the slate families to
// #787B86 to recover the standard's own neutral.
const string G_LN = "Lines"
color cS60  = input.color(#000000, "60d levels", group = G_LN, inline = "l60")
int   wS60  = input.int(1, "", minval = 1, maxval = 4, group = G_LN, inline = "l60")
color cS40  = input.color(#33363D, "40d levels", group = G_LN, inline = "l40")
int   wS40  = input.int(1, "", minval = 1, maxval = 4, group = G_LN, inline = "l40")
color cS20  = input.color(#000000, "20d levels", group = G_LN, inline = "l20")
int   wS20  = input.int(1, "", minval = 1, maxval = 4, group = G_LN, inline = "l20")
color cSEq  = input.color(#33363D, "Equilibrium", group = G_LN, inline = "leq")
int   wSEq  = input.int(1, "", minval = 1, maxval = 4, group = G_LN, inline = "leq")
color cSVt  = input.color(#0000007e, "Shift verticals", group = G_LN, inline = "lvt",
     tooltip = "The shift anchor and its 20 / 40 / 60 day budget markers. The anchor and the 60d due line draw in this colour; the two intermediate markers draw in it faded, so the boundary still reads as the boundary.")
int   wSVt  = input.int(1, "", minval = 1, maxval = 4, group = G_LN, inline = "lvt")
color cSDv  = input.color(#33363D, "Calendar dividers", group = G_LN, inline = "ldv")
int   wSDv  = input.int(1, "", minval = 1, maxval = 4, group = G_LN, inline = "ldv")
//#endregion


//#region[Palette & utility]
const color C_BULL = #7246CE
const color C_BEAR = #DB1D9C
const color INK    = #000000
const color CLEAR  = #FFFFFF

// Line colours come from the Lines inputs. The PANEL does not: the standard
// is explicit that ALL table text is black, and grey field names against a
// white cell were the last thing still reading washed-out. Hierarchy inside
// the panel comes from alignment and from the header's field, never from
// fading the text.
const string TZ    = "America/New_York"

//@function Resolves the label-size input to a size.* constant
//@param s (string) the labelSize input value
//@returns (int) the matching size.* constant
f_lblSize(string s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "large"  => size.large
        =>          size.normal

string LBL_SZ  = f_lblSize(lblSizeIn)
int    msPerBar = timeframe.in_seconds(timeframe.period) * 1000

// ta.* carry bar-to-bar state and must run on EVERY bar, never inside a
// conditional or a ternary branch. These feed the divider tags' cushion.
float atr14 = ta.atr(14)
float lo15  = ta.lowest(low, 15)
float hi15  = ta.highest(high, 15)

//@function Projects a timestamp forward by n TRADING days, skipping weekends.
//          Matches the cast-forward convention in M1D-Fractal-Sequence so the
//          two scripts cannot disagree on a date.
//@param startT (int) start timestamp in ms
//@param n (int) trading days to add
//@returns (int) the projected timestamp in ms
f_fwdTradingDays(int startT, int n) =>
    int t     = startT
    int added = 0
    if n > 0
        while added < n
            t := t + 86400000
            int dw = dayofweek(t)
            if dw != dayofweek.saturday and dw != dayofweek.sunday
                added := added + 1
    t
//#endregion


//#region[Daily context - full history regardless of chart timeframe]
// Computed INSIDE the daily context so the 60-day window exists even on a
// 1-minute chart, where only a fortnight of chart bars is loaded. [1] on every
// term plus lookahead_on is the confirmed-bar, anti-repaint pattern.
//
// ONE request carries every plain daily series this script needs: the six
// window extremes, the prior day's high (the day counter's "daily data has
// arrived" check), the raid look-back extremes, and the two closes the open
// interest read compares price over. They share a symbol and a timeframe, so
// splitting them across three calls only spent three of the request budget
// on one fetch.
[h20, l20, h40, l40, h60, l60, pdH, raidH, raidL, pxNow, pxPast] = request.security(syminfo.tickerid, "D",
     [ta.highest(high, 20)[1], ta.lowest(low, 20)[1],
      ta.highest(high, 40)[1], ta.lowest(low, 40)[1],
      ta.highest(high, 60)[1], ta.lowest(low, 60)[1],
      high[1],
      ta.highest(high, raidLen)[1], ta.lowest(low, raidLen)[1],
      close[1], close[1 + oiLook]],
     lookahead = barmerge.lookahead_on)

// THE OFFSET IS THE ONLY HONEST WAY TO FIND A LEVEL'S ORIGIN.
//
// The obvious alternative - ta.valuewhen on the level CHANGING - anchors to the
// wrong candle whenever the change was a roll-out rather than a new extreme. A
// rolling minimum moves for two different reasons: a lower low prints, or an
// older and lower low ages out of the window and the minimum jumps UP to
// whatever is left. On the second kind the setting candle is months old, but
// valuewhen hands back the day the jump happened.
//
// The failure looks like this: the 60-day high attaches correctly to the
// candle that set it - a genuine new high - while the 60-day low attaches to a
// candle ten weeks later, because a deeper low had just aged out and the
// minimum stepped up to an older low that was never the bar that "changed"
// anything.
//
// ta.highestbars / ta.lowestbars give the offset to the extreme bar directly,
// so the origin is that bar and nothing else. The documented sign is
// negative-or-zero; math.abs makes it correct either way, since only the
// magnitude is wanted and it can only be 0..length-1.
//
// The same offset doubles as the roll-out countdown: a level is an IPDA
// reference only while its bar is inside the window, so the sessions remaining
// are (window - 1 - age). That is also why a 60-day level can date back around
// 83 CALENDAR days - 60 trading days is 12 weeks, 24 of them weekend.

//@function Per window: the offset back to the bar that set each extreme, that
//          bar's own time, and the left edge of the 60-day window.
//@returns (tuple) o20h, o20l, o40h, o40l, o60h, o60l, then their six times,
//         then the three window-open times
f_windows() =>
    int o20h = int(math.abs(nz(ta.highestbars(high, 20)[1])))
    int o20l = int(math.abs(nz(ta.lowestbars(low,  20)[1])))
    int o40h = int(math.abs(nz(ta.highestbars(high, 40)[1])))
    int o40l = int(math.abs(nz(ta.lowestbars(low,  40)[1])))
    int o60h = int(math.abs(nz(ta.highestbars(high, 60)[1])))
    int o60l = int(math.abs(nz(ta.lowestbars(low,  60)[1])))
    // Each window's LEFT EDGE. These are constant references and doing double
    // duty: the deepest of them pins a 61-slot history buffer on `time` in this
    // context, which is what makes the variable-offset lookups below legal -
    // their largest possible index is 1 + 59 = 60. Without a constant reference
    // that deep, Pine can refuse a series read whose offset it cannot bound at
    // compile time. They are also the anchors the equilibrium lines run from,
    // so nothing here is a dummy.
    int w20 = time[20]
    int w40 = time[40]
    int w60 = time[60]
    [o20h, o20l, o40h, o40l, o60h, o60l,
     time[1 + o20h], time[1 + o20l], time[1 + o40h], time[1 + o40l], time[1 + o60h], time[1 + o60l],
     w20, w40, w60]

[g20h, g20l, g40h, g40l, g60h, g60l, t20h, t20l, t40h, t40l, t60h, t60l, w20, w40, w60] = request.security(
     syminfo.tickerid, "D", f_windows(), lookahead = barmerge.lookahead_on)

// Equilibrium: the midpoint of each window's own range. An EQ moves the moment
// EITHER of its two extremes ages out, so its countdown is the sooner of the
// two - never the wider one, which would overstate how long the line stands.
float mid20 = math.avg(h20, l20)
float mid40 = math.avg(h40, l40)
float mid60 = math.avg(h60, l60)

//@function Trading days a level stays inside its window: window - 1 - age.
//@param win (int) window length in trading days
//@param age (int) trading days back to the bar that set the level
//@returns (int) sessions remaining, 0 meaning it leaves at the next close
f_outIn(int win, int age) =>
    int d = na(age) ? na : math.max(win - 1 - age, 0)
    d

int out20h = f_outIn(20, g20h)
int out20l = f_outIn(20, g20l)
int out40h = f_outIn(40, g40h)
int out40l = f_outIn(40, g40l)
int out60h = f_outIn(60, g60h)
int out60l = f_outIn(60, g60l)

bool newDay = timeframe.change("D")
var int dayNum = 0
if newDay and not na(pdH)
    dayNum := dayNum + 1
//#endregion


//#region[Open interest]
// Requested at global scope, gated afterwards. A request.* inside an `if` runs
// only on the bars that enter the branch, which leaves its series full of
// holes - the same trap the linter catches for ta.* in a ternary.
//
// BUILD THE OI SYMBOL FROM prefix + ticker, NEVER FROM syminfo.tickerid.
// tickerid carries the chart's own settings baked into the string - a futures
// chart with settlement-as-close switched off reports something ending
// "settlement-as-close=false", and appending "_OI" to that is not a symbol at
// all. It fails as an invalid symbol FORMAT, which ignore_invalid_symbol does
// not suppress: that flag covers a symbol that does not exist, not a string
// that cannot be parsed. syminfo.ticker is the bare name with no modifiers.
string oiSym = syminfo.prefix + ":" + syminfo.ticker + "_OI"

// THE CONTRACT ROLL IS THE BIGGEST MOVE IN THE SERIES AND IT MEANS NOTHING.
// A continuous-contract OI series collapses by 30-50% in a session as the
// front month is abandoned and rebuilds over the following week - on NQ and
// ES that is four times a year. Measured across 400 sessions the 95th
// percentile of the 20-day change was 16% with the roll weeks removed and 25%
// with them in, so a window that spans a roll cannot be read for positioning.
// The largest single-day jump inside the window is fetched alongside the two
// closes; above ROLL_JUMP the row says "contract roll" instead of a reading.
const float ROLL_JUMP = 12.0
const float FLAT_PX   = 1.0   // the line between "flat" and "moved" for price

//@function The two OI closes the read compares, and the largest one-day
//          percentage jump inside that window (the roll detector).
//@returns (tuple) now, past, maxJump
f_oi() =>
    float jump = close[1] != 0 ? math.abs(close - close[1]) / close[1] * 100.0 : 0.0
    [close[1], close[1 + oiLook], ta.highest(jump, oiLook)[1]]

[oiNowRaw, oiPastRaw, oiJumpRaw] = request.security(oiSym, "D", f_oi(),
     lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)

float oiNow  = showOI ? oiNowRaw  : na
float oiPast = showOI ? oiPastRaw : na
float oiJump = showOI ? oiJumpRaw : na

bool  oiOk   = showOI and not na(oiNow) and not na(oiPast) and oiPast != 0
float oiPct  = oiOk ? (oiNow - oiPast) / oiPast * 100.0 : na
bool  oiRoll = oiOk and not na(oiJump) and oiJump > ROLL_JUMP

float pxPct = not na(pxNow) and not na(pxPast) and pxPast != 0 ? (pxNow - pxPast) / pxPast * 100.0 : na

// Split into a MEASUREMENT and a READING, one per row. The old single string
// carried both and ran three times the width of every other value, which is
// what stopped the panel from splitting into two even halves.
string oiVal = not showOI ? "" : not oiOk ? "unavailable" :
     (oiPct >= 0 ? "+" : "") + str.tostring(oiPct, "#.#") + "% / " + str.tostring(oiLook) + "d"

// The IPDA readings, stated only when the arithmetic supports them. The
// reasoning behind each one lives in the row's tooltip, not in the cell.
//
// The two sign-comparison readings sit behind a floor: the OI change must be
// abnormal (oiMin, measured - see the input) and price must not be flat. They
// compare only the DIRECTION of two changes, so without a floor a 0.3% drift
// in each would print "sell program" - a reading the arithmetic does not
// support. The 15% bullish read carries its own threshold. A window that
// spans a contract roll is refused outright.
bool   oiMoved = math.abs(oiPct) >= oiMin and math.abs(pxPct) >= FLAT_PX
bool   oiBull  = oiOk and not oiRoll and oiPct <= -15.0 and math.abs(pxPct) < FLAT_PX
string oiRead  = not showOI or not oiOk ? "" :
     oiRoll ? "contract roll" :
     oiBull ? "bullish · flat px" :
     oiMoved and oiPct < 0 and pxPct < 0 ? "sell program" :
     oiMoved and oiPct > 0 and pxPct > 0 ? "trend funded" : "no clear read"
//#endregion


//#region[Raid detection, refined to the minute]
var int   shiftAbsDay = -1
var int   shiftTime   = na
var int   shiftDir    = 0
var bool  shiftExact  = false
var int   raidedDay   = -1

// Intrabar stream for THIS chart bar. Empty where TradingView cannot serve it.
// Called unconditionally: a request in a ternary branch only evaluates on the
// bars that take it, and these carry per-bar state. `minuteFix` gates the USE
// below, not the call.
array<float> mHi = request.security_lower_tf(syminfo.tickerid, "1", high)
array<float> mLo = request.security_lower_tf(syminfo.tickerid, "1", low)
array<int>   mTm = request.security_lower_tf(syminfo.tickerid, "1", time)

// True on the bar a NEW anchor is placed - the alert's trigger. A raid that is
// absorbed by a standing shift does not set it.
bool newShift = false

if barstate.isconfirmed and not na(raidH) and not na(raidL) and dayNum != raidedDay
    bool tookHigh = high > raidH
    bool tookLow  = low  < raidL
    if tookHigh or tookLow
        int dir = tookHigh and not tookLow ? 1 : tookLow and not tookHigh ? -1 : high - raidH >= raidL - low ? 1 : -1
        // A shift stands for its full 60-day budget. A same-direction raid
        // inside that budget is a mini shift within the range and leaves the
        // anchor alone; an opposite raid is a reversal and re-anchors, and so
        // does any raid once the budget is spent.
        bool standing = shiftAbsDay >= 0 and dayNum - shiftAbsDay <= 60
        if not standing or dir != shiftDir
            int  exactT = time
            bool exact  = false
            // First minute inside this bar that actually breached the level.
            if minuteFix and mTm.size() > 0 and mTm.size() == mHi.size() and mTm.size() == mLo.size()
                for i = 0 to mTm.size() - 1
                    if not exact and ((tookHigh and mHi.get(i) > raidH) or (tookLow and mLo.get(i) < raidL))
                        exactT := mTm.get(i)
                        exact  := true
            shiftAbsDay := dayNum
            shiftTime   := exactT
            shiftDir    := dir
            shiftExact  := exact
            raidedDay   := dayNum
            newShift    := true

bool hasShift  = shiftAbsDay >= 0 and not na(shiftTime)
int  daysSince = hasShift ? dayNum - shiftAbsDay : na
int  daysLeft  = na(daysSince) ? na : 60 - daysSince
bool overdue   = hasShift and daysSince > 60
bool nearDue   = hasShift and not overdue and daysLeft <= 5

bool alertNearDue = newDay and nearDue and not nearDue[1]
bool alertOverdue = newDay and overdue and not overdue[1]
//#endregion


//#region[Drawing]
var array<line>  dl = array.new<line>()
var array<label> dt = array.new<label>()

// The level set, assembled before anything is drawn so coincident windows can
// be merged and captions given collision-free lanes. Rebuilt from empty on
// every redraw; f_clear() empties it alongside the drawing stores.
var array<float>  bp = array.new<float>()   // price
var array<int>    bo = array.new<int>()     // origin time
var array<string> bw = array.new<string>()  // window caption, e.g. "20·40·60"
var array<string> bs = array.new<string>()  // side: "high" or "low"
var array<color>  bc = array.new<color>()   // colour of the innermost window present
var array<int>    bd = array.new<int>()     // width of the innermost window present
var array<int>    br = array.new<int>()     // that innermost window
var array<int>    bm = array.new<int>()     // the OUTERMOST window present
var array<int>    bx = array.new<int>()     // sessions until it leaves that outermost window

//@function Deletes and empties every draw store
f_clear() =>
    if dl.size() > 0
        for i = 0 to dl.size() - 1
            line.delete(dl.get(i))
    if dt.size() > 0
        for i = 0 to dt.size() - 1
            label.delete(dt.get(i))
    dl.clear()
    dt.clear()
    bp.clear()
    bo.clear()
    bw.clear()
    bs.clear()
    bc.clear()
    bd.clear()
    br.clear()
    bm.clear()
    bx.clear()

//@function Registers one range level, MERGING it into an existing entry when
//          another window already sits at exactly that price.
//
//          Three windows sharing one high is the normal case, not an edge
//          case: a high made inside the last 20 sessions is simultaneously the
//          20, 40 and 60 day high. Drawn separately that is three lines and
//          three captions on a single pixel row - the top of the map reads as
//          one anonymous level while the lows, which genuinely differ, read as
//          three. Merging restores the symmetry because it tells the truth:
//          one price is one level, however many windows agree on it.
//@param p (float) the level
//@param o (int) time of the candle that set it
//@param win (int) window length in days
//@param side (string) "high" or "low"
//@param c (color) colour for this window
//@param wd (int) line width for this window
//@param outDays (int) sessions this level stays inside THIS window
//@returns (void)
f_add(float p, int o, int win, string side, color c, int wd, int outDays) =>
    if not na(p) and not na(o)
        int at = -1
        if bp.size() > 0
            for i = 0 to bp.size() - 1
                if at < 0 and bp.get(i) == p and bs.get(i) == side
                    at := i
        if at < 0
            bp.push(p)
            bo.push(o)
            bw.push(str.tostring(win))
            bs.push(side)
            bc.push(c)
            bd.push(wd)
            br.push(win)
            bm.push(win)
            bx.push(outDays)
        else
            // Registered outermost first, so prepending builds "20·40·60".
            bw.set(at, str.tostring(win) + "·" + bw.get(at))
            // The line starts at whichever candle set the level first.
            bo.set(at, o < bo.get(at) ? o : bo.get(at))
            // The tightest window is the live one and owns the colour and width.
            if win < br.get(at)
                bc.set(at, c)
                bd.set(at, wd)
                br.set(at, win)
            // The countdown belongs to the WIDEST window the level sits in -
            // that is when it stops being an IPDA reference at all. It leaves
            // the tighter windows earlier, and the caption says so when it
            // does, by losing that number from its own prefix.
            if win > bm.get(at)
                bm.set(at, win)
                bx.set(at, outDays)

//@function One vertical IPDA time marker with its tag. Per the house standard
//          IPDA verticals stay neutral (identity colours belong to D/W/M
//          dividers only) and the tag sits to the LEFT of the line in the
//          line's own colour. The line itself extends both ways, so anchY only
//          decides where the CAPTION sits - it is passed in rather than
//          computed here because the two families of vertical (shift budget,
//          calendar) ride their own rails and must never share a row.
//@param t (int) timestamp to mark
//@param txt (string) tag text
//@param col (color) line and text colour
//@param sty (string) a line.style_* constant
//@param wd (int) line width
//@param anchY (float) price to hang the caption at
f_vLine(int t, string txt, color col, int wd, string sty, float anchY) =>
    float span = math.max(nz(atr14, syminfo.mintick * 10) * 6, syminfo.mintick)
    float far  = tagsBelow ? anchY - span : anchY + span
    ln = line.new(f_xClamp(t), anchY, f_xClamp(t), far, xloc = xloc.bar_time, color = col, width = wd, style = sty, extend = extend.both)
    lb = label.new(f_xClamp(t), anchY, txt, xloc = xloc.bar_time, style = label.style_label_right,
         color = color.new(CLEAR, 100), textcolor = col, size = LBL_SZ,
         textalign = text.align_right, text_font_family = font.family_monospace)
    dl.push(ln)
    dt.push(lb)

//@function The roll-out countdown as it appears on a caption. Says nothing at
//          all when the age is unknown, rather than printing a zero that would
//          read as "expiring today".
//@param d (int) sessions remaining, from f_outIn
//@returns (string) caption suffix, empty when there is no figure
f_outTag(int d) =>
    na(d) ? "" : d <= 0 ? "  · out next" : "  · out " + str.tostring(d) + "d"

//@function One IPDA range band: the level from the candle that formed it,
//          running forward to its own caption lane, named at the right end.
//@param price (float) the level
//@param originT (int) time of the candle that set it
//@param txt (string) caption
//@param col (color) line and text colour
//@param wd (int) line width
//@param lane (int) collision lane; each step pushes the caption further right
//@param sty (string) a line.style_* constant
f_band(float price, int originT, string txt, color col, int wd, int lane, string sty) =>
    if not na(price) and not na(originT)
        int rightT = time + (runwayBars + lane * (runwayBars * 2 + 6)) * msPerBar
        ln = line.new(f_xClamp(originT), price, rightT, price, xloc = xloc.bar_time,
             color = col, width = wd, style = sty)
        lb = label.new(rightT, price, txt, xloc = xloc.bar_time, style = label.style_label_left,
             color = color.new(CLEAR, 100), textcolor = col, size = LBL_SZ,
             textalign = text.align_left, text_font_family = font.family_monospace)
        dl.push(ln)
        dt.push(lb)

if barstate.islast
    f_clear()

    // -- One measuring stick for every offset on the chart ------------------
    // The 60-day range is the object this script draws, so it is also the unit
    // everything is spaced by. ATR was the wrong ruler: on a year map an hourly
    // ATR is a rounding error, which is how the tag rail ended up inside the
    // candles and on the same row as the level captions.
    float unit = not na(h60) and not na(l60) and h60 > l60 ? h60 - l60 : nz(atr14, syminfo.mintick * 10) * 14

    // Two rails, outside the range, one family each. The budget markers sit
    // nearer the price because they are the live reading; the calendar sits
    // beyond them. Neither can reach the level captions, which live inside the
    // range by definition.
    float railBase  = tagsBelow ? nz(l60, lo15) : nz(h60, hi15)
    float railShift = tagsBelow ? railBase  - railPad * unit  : railBase  + railPad * unit
    float railCal   = tagsBelow ? railShift - 0.06   * unit   : railShift + 0.06   * unit

    // -- Quarterly dividers across the loaded range and forward -------------
    if showDiv
        int step  = divSpace == "4 months (Jan · May · Sep)" ? 4 : 3
        int baseM = divSpace == "4 months (Jan · May · Sep)" ? 1 : 3
        int y0    = year(chart.left_visible_bar_time, TZ)
        // The last year the projection can reach, taken from the projected end
        // date itself. Capping at next year would cut a 24-month projection
        // short in silence.
        int y1    = year(time + fwdMonths * 2592000000, TZ)
        for y = y0 to y1
            for m = 1 to 12
                if (m - baseM) % step == 0
                    int dv = timestamp(TZ, y, m, 1, 0, 0, 0)
                    if dv >= chart.left_visible_bar_time and dv <= time + fwdMonths * 2592000000
                        f_vLine(dv, str.format_time(dv, "MMM yy", TZ), cSDv, wSDv, line.style_dotted, railCal)

    // -- The IPDA data ranges -----------------------------------------------
    // Registered outermost first so a merged caption reads "20·40·60d high".
    // Every extreme is liquidity: the defaults draw them black because the
    // standard never colours liquidity by direction, and the caption already
    // says which window a level belongs to. Colour and width per family come
    // from the Lines inputs; a merged level takes its tightest window's.
    if showRanges
        if show60
            f_add(h60, t60h, 60, "high", cS60, wS60, out60h)
            f_add(l60, t60l, 60, "low",  cS60, wS60, out60l)
        if show40
            f_add(h40, t40h, 40, "high", cS40, wS40, out40h)
            f_add(l40, t40l, 40, "low",  cS40, wS40, out40l)
        if show20
            f_add(h20, t20h, 20, "high", cS20, wS20, out20h)
            f_add(l20, t20l, 20, "low",  cS20, wS20, out20l)

        // Equilibrium. Neutral by the standard - a midpoint is neither bullish
        // nor bearish - and anchored at its window's LEFT EDGE rather than at a
        // candle, because no single candle sets a midpoint. The countdown is
        // the sooner of its two extremes.
        if showEQs
            if eq60on
                f_add(mid60, w60, 60, "EQ", cSEq, wSEq, math.min(out60h, out60l))
            if eq40on
                f_add(mid40, w40, 40, "EQ", cSEq, wSEq, math.min(out40h, out40l))
            if eq20on
                f_add(mid20, w20, 20, "EQ", cSEq, wSEq, math.min(out20h, out20l))

        // Caption lanes. Merging removes exact ties; this handles levels that
        // are merely CLOSE, which still collide on screen. Each clash steps the
        // caption out one lane, so no two can share a pixel row at any zoom.
        float minGap = unit * 0.05
        array<int> bl = array.new<int>(bp.size(), 0)
        if bp.size() > 0
            for i = 0 to bp.size() - 1
                int lane = 0
                if i > 0
                    // Re-scans every already-placed level after each bump: a
                    // single pass would miss a clash with an entry it had
                    // already walked past. Four sweeps is more than six levels
                    // can ever need.
                    for sweep = 0 to 3
                        bool clash = false
                        for j = 0 to i - 1
                            if bl.get(j) == lane and math.abs(bp.get(j) - bp.get(i)) < minGap
                                clash := true
                        if not clash
                            break
                        lane := lane + 1
                bl.set(i, lane)

            // Solid for a level price actually traded at, dotted for a midpoint
            // that is a reference and nothing more - the standard's own rule.
            for i = 0 to bp.size() - 1
                string sty = bs.get(i) == "EQ" ? line.style_dotted : line.style_solid
                f_band(bp.get(i), bo.get(i), bw.get(i) + "d " + bs.get(i) + f_outTag(bx.get(i)), bc.get(i), bd.get(i), bl.get(i), sty)

    // -- The shift anchor and its 60-day budget -----------------------------
    if hasShift and not overdue
        // The two intermediate markers draw faded so the anchor and the due
        // line, which are the boundary, stay the loudest of the four.
        color cMid = color.new(cSVt, 45)
        f_vLine(shiftTime, "IPDA Shift" + (shiftDir > 0 ? " ^" : " v") + (shiftExact ? "" : " ~"), cSVt, wSVt, line.style_solid, railShift)
        f_vLine(f_fwdTradingDays(shiftTime, 20), "20d", cMid, wSVt, line.style_dotted, railShift)
        f_vLine(f_fwdTradingDays(shiftTime, 40), "40d", cMid, wSVt, line.style_dotted, railShift)
        f_vLine(f_fwdTradingDays(shiftTime, 60), "60d · due", cSVt, wSVt, line.style_dotted, railShift)
//#endregion


//#region[Panel]
// SPLIT DOWN THE MIDDLE. Field on the left, value on the right, divided by a
// hairline column that runs the full height of the panel.
//
// The divider is a real third COLUMN with a background, never a merged cell:
// this table drops rows (no confirmed shift, no open interest series), and the
// visual standard's rule is that merges break the moment row positions shift.
//
// The divider is a GLYPH, not a filled cell. An empty cell with a background
// cannot be made thin: a table cell carries padding on both sides whatever
// width is asked for, so a 0.16%-wide column still rendered as a fat grey band
// roughly a sixth of the panel. One monospace box-drawing character is as
// narrow as a column can get, and the rows stack it into a continuous rule.
//
// No width is forced on the two halves either. That would centre the divide on
// a wide chart and WRAP the text on a narrow one, because a cell width is a
// percentage of the chart while the font is not. The halves are balanced by
// keeping every field name and every value inside ~14 monospace characters -
// which is why the open interest measurement and its reading are two rows.
const string DIVG = "│"
const int    ROWS = 10

var table tbl = table.new(position.top_right, 3, ROWS, border_width = 0,
     frame_width = 1, frame_color = color.new(INK, 70))

//@function Writes one field/value row, with the value carrying the state colour
//@param row (int) row index
//@param k (string) field name
//@param v (string) value
//@param c (color) value colour
//@param tip (string) cell tooltip carrying the arithmetic
f_row(int row, string k, string v, color c, string tip) =>
    table.cell(tbl, 0, row, k, text_color = INK, text_size = LBL_SZ, bgcolor = CLEAR,
         text_font_family = font.family_monospace, text_halign = text.align_left)
    table.cell(tbl, 1, row, DIVG, text_color = color.new(INK, 55), text_size = LBL_SZ, bgcolor = CLEAR,
         text_font_family = font.family_monospace)
    table.cell(tbl, 2, row, v, text_color = c, text_size = LBL_SZ, bgcolor = CLEAR,
         text_font_family = font.family_monospace, text_halign = text.align_right, tooltip = tip)

if barstate.islast and showClock
    table.clear(tbl, 0, 0, 2, ROWS - 1)

    // Kept inside ~15 characters so the header cannot out-run the half it sits
    // in and force the divide off centre.
    // Four states and nothing invented between them: no anchor, counting,
    // five or fewer sessions left, budget spent. Only the last two colour.
    string verdict = not hasShift ? "NO SHIFT FOUND" : overdue ? "BUDGET SPENT" : nearDue ? "DUE SOON" : "IN BUDGET"
    color  vCol = hasShift and (overdue or nearDue) ? C_BEAR : INK

    // The header carries a light violet field across all three cells - the
    // divider included, so the hairline runs unbroken from the top of the
    // panel to the bottom. The field is fixed; the state speaks through the
    // text colour.
    table.cell(tbl, 0, 0, verdict, text_color = vCol, text_size = LBL_SZ, bgcolor = headCol,
         text_font_family = font.family_monospace, text_formatting = text.format_bold, text_halign = text.align_left)
    table.cell(tbl, 1, 0, DIVG, text_color = color.new(INK, 55), text_size = LBL_SZ,
         bgcolor = headCol, text_font_family = font.family_monospace)
    table.cell(tbl, 2, 0, hasShift and not overdue ? str.tostring(daysLeft) + "d left" : "",
         text_color = vCol, text_size = LBL_SZ, bgcolor = headCol,
         text_font_family = font.family_monospace, text_formatting = text.format_bold, text_halign = text.align_right)

    int r = 1
    if hasShift
        f_row(r, "Shift", str.format_time(shiftTime, "dd MMM  HH:mm", TZ) + (shiftDir > 0 ? "  ^" : "  v"),
             INK, shiftExact ? "Anchored to the exact minute the prior extreme was taken, from 1-minute intrabars." : "TradingView could not serve 1-minute intrabars this far back, so this anchor is at chart-bar resolution, not minute-exact. Shown with a ~ on the chart tag.")
        r := r + 1
        f_row(r, "Elapsed", str.tostring(daysSince) + "d", INK,
             "Completed trading days since the raid, counted from the daily context so the figure is identical on any chart timeframe.")
        r := r + 1
        f_row(r, "Budget", overdue ? str.tostring(daysSince - 60) + "d over" : str.tostring(daysLeft) + " of 60",
             overdue ? C_BEAR : INK,
             "60 - " + str.tostring(daysSince) + " = " + str.tostring(daysLeft) + ".\n\nThis is also the cast-forward: today + " + str.tostring(daysLeft) + " trading days is the same date as shift + 60, so they are one boundary and not two.\n\nThis count is in SESSIONS the symbol actually traded. The 60d · due marker on the chart projects the same budget by calendar weekdays, so a weekday the exchange was closed puts the marker one session ahead of this count.")
        r := r + 1
    else
        f_row(r, "Shift", "none in " + str.tostring(raidLen) + "d", INK,
             "No day in range took out the prior " + str.tostring(raidLen) + "-day extreme. Widen the raid look-back before concluding there is no shift - in ICT's framing the real one can sit 2-3 months back.")
        r := r + 1

    if not na(h60) and not na(l60)
        f_row(r, "60d range", str.tostring(l60, format.mintick) + " – " + str.tostring(h60, format.mintick), INK,
             "The outer IPDA data range. Equilibrium sits at " + str.tostring(math.avg(h60, l60), format.mintick) + "." +
             (na(w60) ? "\n\nThis symbol has fewer than 62 daily bars loaded, so the window's left edge cannot be dated." : "\n\nThe window opens " + str.format_time(w60, "d MMM yyyy", TZ) + " - anything older than that is purged and no longer referenced."))
        r := r + 1

    // Whichever drawn level is closest to leaving its widest window. Read off
    // the same arrays the chart drew from, so the panel and the captions can
    // never disagree about a countdown.
    if bp.size() > 0
        int    soon = na
        string who  = ""
        for i = 0 to bp.size() - 1
            if not na(bx.get(i)) and (na(soon) or bx.get(i) < soon)
                soon := bx.get(i)
                who  := str.tostring(bm.get(i)) + "d " + bs.get(i)
        if not na(soon)
            f_row(r, "Rolls out", (soon <= 0 ? "next · " : str.tostring(soon) + "d · ") + who,
                 soon <= 2 ? C_BEAR : INK,
                 "The bar that set this level leaves its window in " + (soon <= 0 ? "one session" : str.tostring(soon) + " sessions") + ", after which IPDA treats it as purged and no longer something the algorithm is referencing.\n\nCounted in TRADING days from the last COMPLETED daily close, so today's session is one of them. That is also why a 60-day level can date back around 83 calendar days - 24 of those are weekends.\n\nIt is the ORIGIN BAR leaving that is counted. The printed level only changes if nothing else still inside the window matches it.")
            r := r + 1

    if showOI and str.length(oiVal) > 0
        f_row(r, "Open interest", oiVal, oiBull ? C_BULL : INK,
             oiOk ? "Open interest change over " + str.tostring(oiLook) + " days: " + str.tostring(oiPct, "#.##") + "%. Price over the same window: " + str.tostring(pxPct, "#.##") + "%. Largest one-day OI jump inside the window: " + str.tostring(oiJump, "#.#") + "%." : "No open interest series came back for " + oiSym + ", so there is nothing to read. Nothing is inferred in its place.")
        r := r + 1
        if str.length(oiRead) > 0
            f_row(r, "OI read", oiRead, oiBull ? C_BULL : INK,
                 oiRoll ? "A one-day jump of " + str.tostring(oiJump, "#.#") + "% sits inside this window - a continuous-contract roll, where open interest collapses as the front month is abandoned and rebuilds over the following week. That move is mechanical and says nothing about positioning, so no reading is stated until the window clears it." :
                 "In ICT's IPDA framing: a 15%+ OI drop on flat price is bullish - the desk is no longer willing to hold the other side. OI falling with price is a sell program worth stepping aside from or joining, not fighting; OI rising with price is a funded trend. The last two are stated only when the OI change is abnormal by the floor set in the inputs and price is not flat. Anything else is left as no clear read rather than dressed up as a signal.")
//#endregion


//#region[Alerts]
alertcondition(newShift,     "IPDA shift confirmed",    "IPDA Year Map: {{ticker}} confirmed a new IPDA shift - 60-day budget restarted")
alertcondition(alertNearDue, "IPDA shift due soon",     "IPDA Year Map: {{ticker}} has 5 or fewer trading days left in its 60-day budget")
alertcondition(alertOverdue, "IPDA budget spent",       "IPDA Year Map: {{ticker}} has spent its 60-day budget - shift overdue")

plotchar(na, title = "build " + BUILD, char = "", display = display.none)
//#endregion
````
