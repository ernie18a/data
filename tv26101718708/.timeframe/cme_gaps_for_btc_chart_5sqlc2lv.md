# CME Gaps for BTC Chart

- url: https://www.tradingview.com/script/5SQlC2LV/
- type: indicator
- pine_id: PUB;66b0acfe46a546f19ed3d538e9ec5a02
- version: 3.0

## Description

[b][b]CME Gaps with Partial Fill Engine [BTC][/b][/b]

Short Description:
Automatically detects and plots institutional CME Bitcoin (BTC) gaps onto your current crypto chart with advanced multi-timeframe tracking and dynamic partial-closing logic.

Full Description:
This indicator tracks real-time and historical price gaps from the CME Bitcoin Futures market (CME:BTC1!) and overlays them seamlessly onto your active Bitcoin chart. Gaps are crucial institutional liquidity levels that often act as powerful magnets for future price action.


Key Features:

Dynamic Timeframe Selection:
Standard setting automatically matches your current chart timeframe, but can be locked to specific intervals (e.g., Daily or 4H) for multi-timeframe analysis.

Partial Gap Closing Logic:
Unlike basic indicators, this script reduces the size of the gap box dynamically when price partially penetrates it, leaving only the unfilled liquidity visible.

Smart Filtering:
Filter out insignificant noise using the volatility-based "Minimum Deviation" setting, which scales gaps based on the 14-period High-Low Average True Range.

Performance Optimized:
Automatically caps maximum visible boxes and features an optional strict bar-length limit to keep your charts clean and lag-free.

Price Scale Integration:
Projects temporary invisible extensions to native price scales for precise tracking of active gap zones.

Custom Alert Triggers:
Built-in alerts instantly notify you when a new CME gap opens or when an existing gap gets filled.

## Source Code

````pine
//@version=6
// ============================================================================
//  CME Gaps for BTC Chart
//  ---------------------------------------------------------------------------
//  Projects unfilled CME Bitcoin futures gaps onto a continuously traded BTC
//  chart (BTCUSD, BTCUSDT, BTCUSDT.P).
//
//  A gap is the distance between the last trade before a CME trading halt and
//  the first trade after it. That is a property of the CME session, not of a
//  chart timeframe, so the whole bookkeeping runs on the reference symbol's
//  daily bars: previous close against the new open, filled by the daily high
//  and low. The chart only draws the result. Every chart timeframe therefore
//  shows exactly the same zones, including gaps older than the chart's own
//  loaded history.
// ============================================================================
indicator("CME Gaps for BTC Chart", "CME Gaps", overlay = true, max_boxes_count = 500)

// ------------------------------------------------------------------ inputs --
const string G_SRC = "Reference market"
const string G_DET = "Detection"
const string G_FIL = "Fill handling"
const string G_VIS = "Appearance"

// Filled zones kept on the chart are capped so that, together with the open
// zones (max 200), the script stays below max_boxes_count.
const int KEEP_MAX = 200

// Zone table layout. Row 0 is a header, every further row is one zone.
const int C_TOP   = 0  // current upper edge          | header: time of the newest gap
const int C_BOT   = 1  // current lower edge          | header: zones filled so far
const int C_UP    = 2  // 1 = gap up, 0 = gap down
const int C_START = 3  // time the reference market stopped trading
const int C_END   = 4  // time of the fill, na while the zone is open
const int C_TOP0  = 5  // upper edge when the gap formed
const int C_BOT0  = 6  // lower edge when the gap formed
const int COLS    = 7

string refSym = input.symbol("CME:BTC1!", "Symbol", group = G_SRC)

float minPct   = input.float(0.1, "Minimum size (% of price)", minval = 0.0, step = 0.05,
     group = G_DET,
     tooltip = "A gap must span at least this share of the last price before the halt.")
bool  incDaily = input.bool(false, "Include daily maintenance break", group = G_DET,
     tooltip = "Off: only gaps across weekends and holidays. On: the one hour daily CME halt counts as well.")
int   maxZones = input.int(15, "Maximum open zones", minval = 1, maxval = 200, group = G_DET,
     tooltip = "The newest open zones are kept.")

bool shrink   = input.bool(true, "Shrink zones on partial fill", group = G_FIL,
     tooltip = "Off: a zone keeps its full size until price has crossed it completely.")
bool useAge   = input.bool(false, "Expire open zones after", inline = "age", group = G_FIL)
int  maxDays  = input.int(365, "days", inline = "age", minval = 1, group = G_FIL)
bool keepDone = input.bool(false, "Leave filled zones on the chart", group = G_FIL)
bool railMark = input.bool(true, "Show nearest edges on the price scale", group = G_FIL)

color upEdge = input.color(color.new(#00cb9d, 40), "Gap up",   inline = "cu", group = G_VIS)
color upFill = input.color(color.new(#00cb9d, 88), "",         inline = "cu", group = G_VIS)
color dnEdge = input.color(color.new(#ff5252, 40), "Gap down", inline = "cd", group = G_VIS)
color dnFill = input.color(color.new(#ff5252, 88), "",         inline = "cd", group = G_VIS)

// ----------------------------------------------------------- chart checks ---
// CME price levels only make sense on a BTC chart. Anywhere else they would
// crush the price scale, so nothing is drawn and a hint is shown instead.
bool btcChart = syminfo.basecurrency == "BTC" or str.contains(syminfo.ticker, "BTC") or
     str.contains(syminfo.ticker, "XBT")

// ------------------------------------------------------------ zone ledger ---
// Runs inside request.security on the reference symbol's daily bars, over the
// full daily history of that symbol. Per day: first the gap at the open, then
// the day's range against every open zone. The open is fixed with the first
// trade and a fill can only grow during the day, so nothing drawn from this
// table is ever taken back.
trackZones() =>
    var matrix<float> z      = matrix.new<float>(1, COLS, na)
    var float         newest = na
    var float         sealed = 0.0

    float prev    = close[1]
    int   prevEnd = nz(time_close[1], time[1])
    bool  longGap = (time - prevEnd) > 4 * 3600000
    float size    = math.abs(open - prev)

    if not na(prev) and size > 0 and size >= prev * minPct / 100 and (longGap or incDaily)
        float hi = math.max(open, prev)
        float lo = math.min(open, prev)
        z.add_row(z.rows(), array.from(hi, lo, open > prev ? 1.0 : 0.0, float(prevEnd), float(na), hi, lo))
        newest := time

    // An up gap sits below the post-gap price and is eaten from its ceiling
    // down. A down gap sits above and is eaten from its floor up.
    int nOpen = 0
    int nDone = 0

    if z.rows() > 1
        for r = z.rows() - 1 to 1
            if na(z.get(r, C_END))
                float top  = z.get(r, C_TOP)
                float bot  = z.get(r, C_BOT)
                bool  done = false

                if z.get(r, C_UP) == 1
                    if low <= bot
                        done := true
                    else if shrink and low < top
                        z.set(r, C_TOP, low)
                else
                    if high >= top
                        done := true
                    else if shrink and high > bot
                        z.set(r, C_BOT, high)

                bool stale = useAge and (time - z.get(r, C_START)) > maxDays * 86400000.0

                if done
                    sealed += 1
                if done and keepDone
                    z.set(r, C_END, time)
                    nDone += 1
                    if nDone > KEEP_MAX
                        z.remove_row(r)
                else if done or stale
                    z.remove_row(r)
                else
                    nOpen += 1
                    if nOpen > maxZones
                        z.remove_row(r)
            else
                nDone += 1
                if nDone > KEEP_MAX
                    z.remove_row(r)

    z.set(0, C_TOP, newest)
    z.set(0, C_BOT, sealed)
    z

// Last trade instead of settlement as the daily close, and no back-adjustment:
// both would move the edges away from prices that were actually traded.
string refId = ticker.modify(refSym, backadjustment = backadjustment.off,
     settlement_as_close = settlement_as_close.off)

matrix<float> zones = request.security(refId, "D", trackZones(),
     barmerge.gaps_off, barmerge.lookahead_off)

bool hasData = not na(zones)

// ------------------------------------------------------------------ alerts --
var float seenGap    = na
var float seenSealed = na

float curGap    = hasData ? zones.get(0, C_TOP) : na
float curSealed = hasData ? zones.get(0, C_BOT) : na

if btcChart and not na(curGap) and not na(seenGap) and curGap != seenGap and zones.rows() > 1
    int last = zones.rows() - 1
    alert(str.format("{0}: new {1} gap on {2}, {3} to {4}",
         syminfo.ticker, zones.get(last, C_UP) == 1 ? "up" : "down", refSym,
         str.tostring(zones.get(last, C_BOT0), format.mintick),
         str.tostring(zones.get(last, C_TOP0), format.mintick)), alert.freq_once_per_bar)

if btcChart and not na(curSealed) and not na(seenSealed) and curSealed > seenSealed
    alert(str.format("{0}: {1} gap zone(s) fully covered.", syminfo.ticker,
         str.tostring(curSealed - seenSealed)), alert.freq_once_per_bar)

seenGap    := curGap
seenSealed := curSealed

// ----------------------------------------------------------------- drawing --
// The table already holds the final state, so the boxes are simply rebuilt on
// the last bar. Time coordinates let a zone start before the first loaded
// chart bar.
var array<box> drawn = array.new<box>()

float nearAbove = na
float nearBelow = na
int   openCount = 0

if barstate.islast
    while drawn.size() > 0
        box.delete(drawn.pop())

    if btcChart and hasData and zones.rows() > 1
        for r = 1 to zones.rows() - 1
            bool isUp = zones.get(r, C_UP) == 1
            int  left = int(zones.get(r, C_START))

            if na(zones.get(r, C_END))
                float hi = zones.get(r, C_TOP)
                float lo = zones.get(r, C_BOT)
                drawn.push(box.new(left, hi, math.max(time, left + 60000), lo, xloc = xloc.bar_time,
                     border_color = isUp ? upEdge : dnEdge,
                     bgcolor      = isUp ? upFill : dnFill,
                     border_style = line.style_dashed, extend = extend.right))
                openCount += 1
                if lo > close
                    nearAbove := na(nearAbove) ? lo : math.min(nearAbove, lo)
                if hi < close
                    nearBelow := na(nearBelow) ? hi : math.max(nearBelow, hi)
            else
                int right = int(zones.get(r, C_END))
                drawn.push(box.new(left, zones.get(r, C_TOP0), math.max(right, left + 60000),
                     zones.get(r, C_BOT0), xloc = xloc.bar_time,
                     border_color = isUp ? upEdge : dnEdge, bgcolor = na,
                     border_style = line.style_dotted, extend = extend.none))

// -------------------------------------------------------------- price rail --
// Pine line objects never reach the price scale. Plots do, so the two nearest
// open edges are published as plots instead.
plot(railMark ? nearAbove : na, "Nearest gap above", color = dnEdge,
     style = plot.style_linebr, linewidth = 1, display = display.price_scale + display.status_line)
plot(railMark ? nearBelow : na, "Nearest gap below", color = upEdge,
     style = plot.style_linebr, linewidth = 1, display = display.price_scale + display.status_line)

// ------------------------------------------------------------------- hints --
// Rebuilt on the last bar every time, so a hint disappears as soon as its
// reason is gone.
var table hint = table.new(position.bottom_right, 1, 1)

if barstate.islast
    string msg = na
    if not btcChart
        msg := "CME Gaps: this is not a BTC chart, nothing is drawn."
    else if not hasData
        msg := "No data for " + refSym + ".\nCheck the reference symbol."
    else if openCount == 0
        msg := "No open " + refSym + " gaps.\nLower 'Minimum size (% of price)' or include the daily maintenance break."

    if na(msg)
        table.clear(hint, 0, 0)
    else
        table.cell(hint, 0, 0, msg,
             text_color = chart.bg_color, bgcolor = chart.fg_color, text_size = size.small)
````
