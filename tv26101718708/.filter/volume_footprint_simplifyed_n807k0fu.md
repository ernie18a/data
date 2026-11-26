# Volume Footprint [Simplifyed]

- url: https://www.tradingview.com/script/n807k0fu-Volume-Footprint-Simplifyed/
- type: indicator
- pine_id: PUB;14c23418b74f46e3bffb366f3387dddf
- version: 1.0

## Description

[b]Volume Footprint [Simplifyed][/b]

[b]Overview[/b]

Most volume indicators tell you [i]how much[/i] was traded. This indicator tells you [i]who won[/i]. Volume Footprint displays the order flow breakdown inside every bar — how many contracts were bought aggressively versus sold aggressively at each price level — so you can see where institutional participation is concentrated and whether that participation is consistent with the direction price actually moved.

The core insight is simple: price only moves when effort fails to produce a result. A bar dominated by sell orders that still closes higher is not bearish — it is a sign that passive buyers absorbed every aggressive seller. The next move is likely up. This script surfaces those inefficiencies directly on your chart.

Requires a TradingView [b]Premium[/b] or [b]Ultimate[/b] plan for the [i]request.footprint()[/i] API.

[b]How it works[/b]

The script requests a full footprint for each bar via Pine Script v6's native [i]request.footprint()[/i] call. Each bar is divided into rows based on a user-defined tick width. Every row shows its delta — the net difference between aggressive buy volume and aggressive sell volume at that price level.

[pine]
footprint fp = request.footprint(i_ticks, i_va, i_imbal)
float barDelta = fp.delta()
array<volume_row> rows = fp.rows()
[/pine]

Six signal types are derived from that data:

[list]
[*][b]Bear Trap (green label)[/b] — the majority of sell-delta rows are clustered in the bottom third of the bar. Sellers entered at the lows and were absorbed. Their break-even stop is the bar's POC.
[*][b]Bull Trap (red label)[/b] — the majority of buy-delta rows are clustered in the top third of the bar. Buyers entered at the highs and were absorbed. Their break-even stop is the bar's POC.
[*][b]Squeeze Up / Squeeze Down (diamond)[/b] — price crosses through a Vulnerability Line drawn at a prior trap bar's POC. Trapped participants hit their stops and accelerate the move.
[*][b]Ineff Sell / Ineff Buy (circle)[/b] — bar delta is negative but the candle closed up (or vice versa). Effort did not produce the expected result. The aggressive side is exhausted.
[*][b]Vulnerability Line (dashed)[/b] — a horizontal line extending from each trap bar's POC. This is the trapped trader's break-even level. It turns dotted when consumed by a Squeeze signal.
[*][b]Iceberg Row (bright border)[/b] — a row where total volume exceeds a multiple of the bar's average row volume. Signature of a passive institutional limit order silently absorbing aggression.
[/list]

Bar rows are coloured by delta direction: teal for net buying, red for net selling. Row opacity scales with volume when the gradient mode is enabled. The Value Area (the range of rows containing a user-defined percentage of total bar volume) receives a gold border. The POC row receives an orange border.

The bar delta label at the bottom of each bar shows the net delta, volume context (FRESH / EXIT up / EXIT down), and a summary of imbalance counts. A star prefix (★) on trap labels means the trap fired at the edge of the recent N-bar range — the highest-conviction location.

[b]Inputs[/b]

[b]Footprint[/b]

[list=1]
[*][b]Ticks per Row[/b] — controls the price granularity of each footprint row. One tick equals syminfo.mintick. Lower values (e.g. 10) produce more rows and finer detail but consume more drawing objects; higher values (e.g. 500) produce fewer, coarser rows. Target approximately 25 rows per bar. Use the "ATR Ticks Hint" value in the Data Window as a starting point. Default: 100.
[*][b]Value Area %[/b] — the percentage of total bar volume used to define the Value Area. The standard market profile convention is 70. Raising this to 90 widens the highlighted region; lowering it to 50 tightens it to only the highest-volume core. Default: 70.
[*][b]Imbalance Threshold %[/b] — a row is flagged as having a buy imbalance when its buy volume exceeds this percentage of the row below's sell volume (and vice versa for sell imbalance). At 300%, a row needs 3× the adjacent row's opposing volume to qualify. Lower values (e.g. 150) produce more frequent imbalance markers; higher values (e.g. 500) flag only extreme stacking. Default: 300.
[/list]

[b]Signals[/b]

[list=1]
[*][b]Fresh/Exit Range (bars)[/b] — the lookback window used to classify whether the current bar is in the middle of the recent range (FRESH — new institutional entry) or at its extremes (EXIT — take-profits or stops). A value of 20 uses the prior 20 bars. Shorter lookbacks (e.g. 5) react to recent swings; longer lookbacks (e.g. 50) classify against a broader structural range. Default: 20.
[*][b]Iceberg Threshold (x avg row vol)[/b] — a row is highlighted as an iceberg when its volume exceeds this multiple of the bar's average row volume. At 3.0×, a row needs three times the average to qualify. Lower values (e.g. 2.0) highlight more rows; higher values (e.g. 6.0) flag only the most extreme absorption events. Default: 3.0.
[*][b]Candle Shape Filter for Traps[/b] — when enabled, a Bear Trap additionally requires a hammer candle (lower wick at least 2× the body, upper wick at most 0.5× the body) and a Bull Trap additionally requires a shooting-star candle. This reduces signal frequency and increases precision. Disable it on instruments where wick structure is less reliable (e.g. crypto with frequent spikes). Default: off.
[/list]

[b]Display[/b]

[list=1]
[*][b]Value Area Highlight[/b] — draws a gold border on rows within the Value Area. Default: on.
[*][b]POC Highlight[/b] — draws an orange border on the Point of Control row (highest volume row in the bar). Default: on.
[*][b]Imbalance Markers[/b] — plots a small triangle at the top or bottom of rows with a buy or sell imbalance. Default: on.
[*][b]Bar Delta Label[/b] — displays a label below each bar showing total bar delta, volume context, and dominant imbalance count. Default: on.
[*][b]Trap Signals[/b] — shows Bear Trap and Bull Trap labels on qualifying bars. A ★ prefix indicates the trap fired at a range edge. Default: on.
[*][b]Vulnerability Lines[/b] — draws a dashed horizontal line at each trap bar's POC, extending to the right until consumed by a Squeeze signal. Default: on.
[*][b]Squeeze Signals[/b] — plots a label when price crosses through a Vulnerability Line, triggering forced exits from trapped participants. Default: on.
[*][b]Efficiency Signals (Effort vs Result)[/b] — plots Ineff Sell and Ineff Buy labels when delta direction and candle direction disagree. Default: on.
[*][b]Volume Gradient[/b] — when enabled, each row's background opacity scales with its share of total bar volume, making high-volume rows visually heavier. When disabled, all rows use a flat background colour. Default: off.
[*][b]Label Size[/b] — sets the text size of row delta labels. Options: tiny, small, normal. Default: tiny.
[/list]

[b]Usage notes[/b]

[list]
[*]Read the "ATR Ticks Hint" value from the Data Window before setting Ticks per Row. Divide the hint by 25 to find a starting point that yields approximately 25 rows per bar. Too few rows (under 10) loses resolution; too many rows (over 40) consumes drawing objects rapidly and shows only the last few bars in full detail.
[*]Full footprint detail (boxes and labels) is limited to approximately the last 13 bars due to drawing object limits (500 boxes, 500 labels). All signals — traps, squeezes, efficiency — are plotted on all historical bars via plotshape and barcolor, so you can scroll back to review signal history without losing them.
[*]Treat the ★ trap label as higher conviction than an unmarked trap. A trap firing in the middle of a range has less context than one firing at a structural high or low where stops are naturally clustered.
[*]A Vulnerability Line turning dotted is the Squeeze confirmation. The price crossing the line is the mechanical event; the line changing style is its visual acknowledgement. Monitor open Vulnerability Lines for potential squeeze setups forming over multiple bars.
[*]Ineff Sell and Ineff Buy signals are strongest when they appear in the FRESH zone (bar label shows "FRESH"), meaning institutional participants entered mid-range and their effort failed. Efficiency signals in EXIT zones are more ambiguous — they may simply reflect profit-taking.
[*]A row with a bright iceberg border is a price level to watch on subsequent bars. Institutions building positions via iceberg orders at a specific level tend to defend that level on retests.
[*]This indicator requires one request.footprint() call per script. You cannot combine it with other scripts that also use request.footprint() on the same chart due to Pine Script's single-footprint-per-indicator constraint.
[/list]

[b]Recommended pairings[/b]

Volume Footprint is most effective when combined with a structural context tool — a supply and demand zone indicator or a swing high/low marker — so you can confirm whether trap and squeeze signals are firing at meaningful price levels. A session volume profile (VPVR) on the same chart helps identify whether the current bar's POC aligns with a broader high-volume node or is isolated.

## Source Code

````pine
//@version=6
// =============================================================================
//  Volume Footprint [Simplifyed]
//
//  Implements the full Order Flow Narrative framework using Pine Script v6's
//  native request.footprint() API (TradingView Premium / Ultimate required).
//
//  ── CORE PHILOSOPHY ──────────────────────────────────────────────────────────
//  "Never chase raw volume. Hunt the inefficiency."
//  Every number on the footprint is a market order hitting a limit order.
//  Price moves only when effort (delta) fails to produce the expected result.
//
//  ── SIGNAL FRAMEWORK ─────────────────────────────────────────────────────────
//
//  1. TRAP SIGNALS  (1/3 zone majority rule)
//       BEAR TRAP ↑  — majority of sell rows (-ve delta) in bottom 1/3
//                      Sellers absorbed at lows; trapped above their entry.
//                      Vulnerability Line drawn at bar POC (their break-even).
//       BULL TRAP ↓  — majority of buy rows (+ve delta) in top 1/3
//                      Buyers absorbed at highs; trapped below their entry.
//                      Vulnerability Line drawn at bar POC (their break-even).
//       ★ prefix     — trap fires at range EDGE (EXIT zone) = highest conviction.
//                      "Volume at the edges is a trap." — Order Flow Blueprint.
//       Hammer filter (optional) — BEAR TRAP additionally requires a hammer candle.
//                      BULL TRAP additionally requires a shooting-star candle.
//
//  2. SQUEEZE SIGNALS  (forced exit detection)
//       SQUEEZE ↑   — price crosses UP through a BEAR TRAP Vulnerability Line.
//                     Trapped sellers hit break-even stops → forced buy-back.
//       SQUEEZE ↓   — price crosses DOWN through a BULL TRAP Vulnerability Line.
//                     Trapped buyers hit break-even stops → forced sell-out.
//       Line style changes dashed → dotted when level is consumed.
//
//  3. EFFICIENCY (EFFORT vs RESULT) SIGNALS
//       INEFF SELL  — bar delta negative (sell dominance) but candle closed UP.
//                     Sellers exerted maximum effort; price refused to follow.
//                     Sellers are exhausted — bet on the other side.
//       INEFF BUY   — bar delta positive (buy dominance) but candle closed DOWN.
//                     Buyers exerted maximum effort; price refused to follow.
//                     Buyers are exhausted — bet on the other side.
//
//  4. FRESH / EXIT VOLUME CONTEXT
//       FRESH        — bar in middle 70% of N-bar range. New institutional skin.
//       EXIT↑/EXIT↓  — bar at top/bottom 15% of range. Take-profits or stops.
//
//  5. ICEBERG ABSORPTION ROW HIGHLIGHT
//       Rows where volume exceeds N × average get a bright white border.
//       Signature of institutional iceberg orders absorbing aggression silently.
//
//  6. ALL SIGNALS on ALL HISTORICAL BARS via plotshape + barcolor (no limit).
//
//  ── CONSTRAINTS ──────────────────────────────────────────────────────────────
//    • Requires TradingView PREMIUM or ULTIMATE plan.
//    • Ticks per row must be a simple int. Use "ATR Ticks Hint" in Data Window.
//    • 500 boxes + 500 labels ÷ ~37/bar ≈ last ~13 bars in full footprint detail.
// =============================================================================

indicator("Volume Footprint [Simplifyed]",
          overlay          = true,
          max_boxes_count  = 500,
          max_labels_count = 500,
          max_lines_count  = 100,
          behind_chart     = false)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUT GROUPS
// ─────────────────────────────────────────────────────────────────────────────
var string GRP_FP  = "Footprint"
var string GRP_SIG = "Signals"
var string GRP_DIS = "Display"
var string GRP_CLR = "Colors"

int i_ticks = input.int(100, "Ticks per Row",
              minval = 1, maxval = 10000,
              tooltip = "1 tick = syminfo.mintick. Check 'ATR Ticks Hint' in Data Window (target ~25 rows/bar).",
              group = GRP_FP)
int i_va    = input.int(70, "Value Area %",
              minval = 1, maxval = 100,
              tooltip = "% of total bar volume defining the Value Area (standard = 70).",
              group = GRP_FP)
int i_imbal = input.int(300, "Imbalance Threshold %",
              minval = 100, maxval = 2000,
              tooltip = "Row has buy imbalance when buy vol > N% of the row-below sell vol (and vice-versa).",
              group = GRP_FP)

int   i_rangeLookback = input.int(20, "Fresh/Exit Range (bars)",
                        minval = 5, maxval = 100,
                        tooltip = "Lookback for volume context. Top/bottom 15% = EXIT (take-profits/stops). Middle 70% = FRESH (institutional entry).",
                        group = GRP_SIG)
float i_icebergMult   = input.float(3.0, "Iceberg Threshold (x avg row vol)",
                        minval = 1.5, maxval = 10.0, step = 0.5,
                        tooltip = "Rows with volume > N x average get a bright border — signature of institutional iceberg absorption.",
                        group = GRP_SIG)
bool  i_hammerFilter  = input.bool(false, "Candle Shape Filter for Traps",
                        tooltip = "BEAR TRAP requires a hammer candle; BULL TRAP requires a shooting-star. Reduces noise, increases precision.",
                        group = GRP_SIG)

bool   i_showVA         = input.bool(true,  "Value Area Highlight",         group = GRP_DIS)
bool   i_showPOC        = input.bool(true,  "POC Highlight",                group = GRP_DIS)
bool   i_showImbal      = input.bool(true,  "Imbalance Markers",            group = GRP_DIS)
bool   i_showBarDelta   = input.bool(true,  "Bar Delta Label",              group = GRP_DIS)
bool   i_showAbsorption = input.bool(true,  "Trap Signals",
                          tooltip = "BEAR TRAP / BULL TRAP. ★ = high conviction (firing at range edge).",
                          group = GRP_DIS)
bool   i_showVulnLine   = input.bool(true,  "Vulnerability Lines",
                          tooltip = "Dashed POC line from each trap bar — the trapped trader's break-even level.",
                          group = GRP_DIS)
bool   i_showSqueeze    = input.bool(true,  "Squeeze Signals",
                          tooltip = "Fires when price crosses a Vulnerability Line. Trapped exits accelerate the move.",
                          group = GRP_DIS)
bool   i_showEfficiency = input.bool(true,  "Efficiency Signals (Effort vs Result)",
                          tooltip = "INEFF SELL: sell delta but closed UP (sellers failed). INEFF BUY: buy delta but closed DOWN (buyers failed).",
                          group = GRP_DIS)
bool   i_gradient       = input.bool(false, "Volume Gradient",
                          tooltip = "Row background opacity scales with its share of total bar volume.",
                          group = GRP_DIS)
string i_txtsz          = input.string("tiny", "Label Size",
                          options = ["tiny", "small", "normal"],
                          group = GRP_DIS)

color i_sellBg    = input.color(color.new(#F44336, 35), "Sell Row Bg",        group = GRP_CLR)
color i_buyBg     = input.color(color.new(#00897B, 35), "Buy Row Bg",         group = GRP_CLR)
color i_vaBdr     = input.color(color.new(#FFD700, 40), "Value Area Border",  group = GRP_CLR)
color i_pocBdr    = input.color(color.new(#FF9800,  0), "POC Border",         group = GRP_CLR)
color i_icebergBr = input.color(color.new(#FFFFFF, 10), "Iceberg Row Border", group = GRP_CLR)
color i_txtCol    = input.color(color.white,             "Row Text",           group = GRP_CLR)
color i_ibBuy     = input.color(color.new(#00E5FF,  0), "Buy Imbalance",      group = GRP_CLR)
color i_ibSell    = input.color(color.new(#FF4081,  0), "Sell Imbalance",     group = GRP_CLR)
color i_bullSig   = input.color(color.new(#00E676,  0), "Bull Signal",        group = GRP_CLR)
color i_bearSig   = input.color(color.new(#FF1744,  0), "Bear Signal",        group = GRP_CLR)

// ─────────────────────────────────────────────────────────────────────────────
//  FOOTPRINT REQUEST
// ─────────────────────────────────────────────────────────────────────────────
footprint fp = request.footprint(i_ticks, i_va, i_imbal)

// ─────────────────────────────────────────────────────────────────────────────
//  ATR
// ─────────────────────────────────────────────────────────────────────────────
float atr14        = ta.atr(14)
float atrTicksHint = math.round(atr14 / syminfo.mintick / 25)

// ─────────────────────────────────────────────────────────────────────────────
//  FRESH / EXIT VOLUME CONTEXT
//  [1] shifts one bar back so current bar is not self-referential.
// ─────────────────────────────────────────────────────────────────────────────
float rangeHigh = ta.highest(high, i_rangeLookback)[1]
float rangeLow  = ta.lowest(low,  i_rangeLookback)[1]
float rangeSize = rangeHigh - rangeLow
float rangePos  = rangeSize > 0 ? (close - rangeLow) / rangeSize * 100.0 : 50.0
bool  isExitUp  = rangePos >= 85.0
bool  isExitDn  = rangePos <= 15.0
string volCtx   = isExitUp ? " EXIT↑" : isExitDn ? " EXIT↓" : " FRESH"

// ─────────────────────────────────────────────────────────────────────────────
//  CANDLE SHAPE  (Sammy Hammerfoot pattern)
//  Hammer      : lower wick >= 2x body AND upper wick <= 0.5x body
//  Shooting Star: upper wick >= 2x body AND lower wick <= 0.5x body
// ─────────────────────────────────────────────────────────────────────────────
float bodySize  = math.abs(close - open)
float lowerWick = math.min(close, open) - low
float upperWick = high - math.max(close, open)
bool  isHammer  = bodySize > 0 and lowerWick >= 2.0 * bodySize and upperWick <= 0.5 * bodySize
bool  isStar    = bodySize > 0 and upperWick >= 2.0 * bodySize and lowerWick <= 0.5 * bodySize

// ─────────────────────────────────────────────────────────────────────────────
//  SIGNAL SERIES — reset every bar before the fp block
// ─────────────────────────────────────────────────────────────────────────────
var bool sig_bearTrap    = false
var bool sig_bullTrap    = false
var bool sig_bullSqueeze = false
var bool sig_bearSqueeze = false
var bool sig_ineffSell   = false
var bool sig_ineffBuy    = false

sig_bearTrap    := false
sig_bullTrap    := false
sig_bullSqueeze := false
sig_bearSqueeze := false
sig_ineffSell   := false
sig_ineffBuy    := false

// ─────────────────────────────────────────────────────────────────────────────
//  VULNERABILITY LINE STATE
// ─────────────────────────────────────────────────────────────────────────────
var float vl_bearTrapPOC  = na
var float vl_bullTrapPOC  = na
var line  vl_bearTrapLine = na
var line  vl_bullTrapLine = na

// ─────────────────────────────────────────────────────────────────────────────
//  SQUEEZE DETECTION  (price-based, runs every bar)
// ─────────────────────────────────────────────────────────────────────────────
if i_showSqueeze
    if not na(vl_bearTrapPOC) and low[1] <= vl_bearTrapPOC and close > vl_bearTrapPOC
        sig_bullSqueeze := true
        vl_bearTrapPOC  := na
        if not na(vl_bearTrapLine)
            line.set_style(vl_bearTrapLine, line.style_dotted)
    if not na(vl_bullTrapPOC) and high[1] >= vl_bullTrapPOC and close < vl_bullTrapPOC
        sig_bearSqueeze := true
        vl_bullTrapPOC  := na
        if not na(vl_bullTrapLine)
            line.set_style(vl_bullTrapLine, line.style_dotted)

// ─────────────────────────────────────────────────────────────────────────────
//  DATA WINDOW
// ─────────────────────────────────────────────────────────────────────────────
plot(atrTicksHint,                        "ATR Ticks Hint (target ~25 rows/bar)", display = display.data_window)
plot(not na(fp) ? fp.delta()       : na,  "Bar Delta",                           display = display.data_window)
plot(not na(fp) ? fp.buy_volume()  : na,  "Bar Buy Vol",                         display = display.data_window)
plot(not na(fp) ? fp.sell_volume() : na,  "Bar Sell Vol",                        display = display.data_window)
plot(rangePos,                            "Range Position %",                    display = display.data_window)

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────
fmtVol(float v) =>
    float  a = math.abs(v)
    string s = v < 0 ? "-" : "+"
    s + (a >= 1000000 ? str.tostring(a / 1000000, "#.##") + "M"
       : a >= 1000    ? str.tostring(a / 1000,    "#.##") + "K"
       :                str.tostring(math.round(a), "#"))

resolveSize() =>
    i_txtsz == "small"  ? size.small
  : i_txtsz == "normal" ? size.normal
  : size.tiny

repeatStr(string ch, int n) =>
    string out = ""
    if n > 0
        for _i = 0 to math.min(n, 5) - 1
            out := out + ch
    out

// ─────────────────────────────────────────────────────────────────────────────
//  RENDER FOOTPRINT
// ─────────────────────────────────────────────────────────────────────────────
if not na(fp)
    array<volume_row> rows = fp.rows()
    int nRows = array.size(rows)

    if nRows > 0
        float vahUp = na
        float valDn = na
        if i_showVA
            volume_row vahR = fp.vah()
            volume_row valR = fp.val()
            vahUp := not na(vahR) ? vahR.up_price()   : na
            valDn := not na(valR) ? valR.down_price() : na

        float pocRUp = na
        if i_showPOC
            volume_row pocR = fp.poc()
            pocRUp := not na(pocR) ? pocR.up_price() : na

        float totalVol  = fp.buy_volume() + fp.sell_volume()
        float avgRowVol = totalVol / nRows
        float barDelta  = fp.delta()

        // ── Efficiency: Effort vs Result ──────────────────────────────────────
        //  INEFF SELL: aggressive sellers dominated but price closed UP.
        //              Passive buyers (icebergs) absorbed every sell order.
        //              Sellers are exhausted → bet on buyers for next move.
        //  INEFF BUY:  aggressive buyers dominated but price closed DOWN.
        //              Passive sellers (icebergs) absorbed every buy order.
        //              Buyers are exhausted → bet on sellers for next move.
        if i_showEfficiency
            sig_ineffSell := barDelta < 0 and close > open
            sig_ineffBuy  := barDelta > 0 and close < open

        int third = math.max(1, nRows / 3)

        int negDeltaTotal  = 0
        int negDeltaBot    = 0
        int posDeltaTotal  = 0
        int posDeltaTop    = 0
        int buyImbalCount  = 0
        int sellImbalCount = 0

        for i = 0 to nRows - 1
            volume_row r = array.get(rows, i)
            float rUp    = r.up_price()
            float rDown  = r.down_price()
            float delta  = r.delta()
            float rowVol = r.total_volume()

            if delta < 0
                negDeltaTotal := negDeltaTotal + 1
                if i < third
                    negDeltaBot := negDeltaBot + 1
            else if delta > 0
                posDeltaTotal := posDeltaTotal + 1
                if i >= nRows - third
                    posDeltaTop := posDeltaTop + 1

            if r.has_buy_imbalance()
                buyImbalCount := buyImbalCount + 1
            if r.has_sell_imbalance()
                sellImbalCount := sellImbalCount + 1

            bool inVA  = i_showVA  and not na(vahUp) and not na(valDn) and rDown >= valDn and rUp <= vahUp
            bool isPOC = i_showPOC and not na(pocRUp) and rUp == pocRUp

            // Iceberg: row volume >> average = passive limit order absorbing aggression
            bool isIceberg = rowVol > avgRowVol * i_icebergMult

            color bgCol = na
            if i_gradient and avgRowVol > 0.0
                float rel   = math.min(rowVol / avgRowVol, 3.0) / 3.0
                float alpha = 85.0 - rel * 70.0
                bgCol := delta >= 0 ? color.new(#00897B, alpha) : color.new(#F44336, alpha)
            else
                bgCol := delta >= 0 ? i_buyBg : i_sellBg

            // Border priority: Iceberg > POC > Value Area > default
            color borderCol = isIceberg ? i_icebergBr
                             : isPOC     ? i_pocBdr
                             : inVA      ? i_vaBdr
                             : color.new(color.gray, 85)
            int   borderW   = isIceberg or isPOC ? 2 : 1

            box.new(bar_index, rUp, bar_index + 1, rDown,
                    bgcolor      = bgCol,
                    border_color = borderCol,
                    border_width = borderW)

            label.new(bar_index, (rUp + rDown) / 2.0,
                      text      = fmtVol(delta),
                      style     = label.style_none,
                      textcolor = i_txtCol,
                      size      = resolveSize())

            if i_showImbal
                if r.has_buy_imbalance()
                    label.new(bar_index, rUp,   text = "▲", style = label.style_none, textcolor = i_ibBuy,  size = size.tiny)
                if r.has_sell_imbalance()
                    label.new(bar_index, rDown, text = "▼", style = label.style_none, textcolor = i_ibSell, size = size.tiny)

        // ── Trap logic ────────────────────────────────────────────────────────
        bool rawBearTrap = negDeltaTotal >= 2 and (negDeltaBot * 2 > negDeltaTotal)
        bool rawBullTrap = posDeltaTotal >= 2 and (posDeltaTop * 2 > posDeltaTotal)

        if i_hammerFilter
            rawBearTrap := rawBearTrap and isHammer
            rawBullTrap := rawBullTrap and isStar

        bool bearTrap = rawBearTrap and (not rawBullTrap or barDelta > 0)
        bool bullTrap = rawBullTrap and (not rawBearTrap or barDelta < 0)

        sig_bearTrap := bearTrap
        sig_bullTrap := bullTrap

        // ── Vulnerability Lines ───────────────────────────────────────────────
        if i_showVulnLine
            volume_row pocRow = fp.poc()
            if not na(pocRow)
                float pocMid = (pocRow.up_price() + pocRow.down_price()) / 2.0
                if bearTrap
                    if not na(vl_bearTrapLine)
                        line.delete(vl_bearTrapLine)
                    vl_bearTrapLine := line.new(bar_index, pocMid, bar_index + 1, pocMid, extend = extend.right, color = i_bullSig, style = line.style_dashed, width = 1)
                    vl_bearTrapPOC  := pocMid
                if bullTrap
                    if not na(vl_bullTrapLine)
                        line.delete(vl_bullTrapLine)
                    vl_bullTrapLine := line.new(bar_index, pocMid, bar_index + 1, pocMid, extend = extend.right, color = i_bearSig, style = line.style_dashed, width = 1)
                    vl_bullTrapPOC  := pocMid

        // ── Bar delta label ───────────────────────────────────────────────────
        float offset = atr14 * 0.15
        if i_showBarDelta
            bool   buyDomImbal = buyImbalCount >= sellImbalCount
            int    domCount    = buyDomImbal ? buyImbalCount : sellImbalCount
            string imbalLine   = domCount > 0 ? "\n" + (buyDomImbal ? repeatStr("▲", domCount) : repeatStr("▼", domCount)) : ""
            color  lblColor    = barDelta >= 0 ? i_bullSig : i_bearSig
            label.new(bar_index, low - offset,
                      text      = "D " + fmtVol(barDelta) + volCtx + imbalLine,
                      style     = label.style_label_up,
                      color     = color.new(color.black, 70),
                      textcolor = lblColor,
                      size      = size.small)

        // ── Trap labels  (★ when firing at range edge = highest conviction) ───
        if i_showAbsorption
            string bearPfx = (isExitDn or isExitUp) ? "★ " : ""
            string bullPfx = (isExitDn or isExitUp) ? "★ " : ""
            if bullTrap
                label.new(bar_index, high + offset,
                          text      = bullPfx + "BULL TRAP ↓",
                          style     = label.style_label_down,
                          color     = color.new(i_bearSig, 15),
                          textcolor = color.white,
                          size      = size.normal)
            if bearTrap
                label.new(bar_index, low - offset * 3.5,
                          text      = bearPfx + "BEAR TRAP ↑",
                          style     = label.style_label_up,
                          color     = color.new(i_bullSig, 15),
                          textcolor = color.white,
                          size      = size.normal)

        // ── Squeeze labels ────────────────────────────────────────────────────
        if i_showSqueeze
            if sig_bullSqueeze
                label.new(bar_index, high + offset * 2.0,
                          text      = "SQUEEZE ↑",
                          style     = label.style_label_down,
                          color     = color.new(i_bullSig, 0),
                          textcolor = color.white,
                          size      = size.normal)
            if sig_bearSqueeze
                label.new(bar_index, low - offset * 5.0,
                          text      = "SQUEEZE ↓",
                          style     = label.style_label_up,
                          color     = color.new(i_bearSig, 0),
                          textcolor = color.white,
                          size      = size.normal)

        // ── Efficiency labels ─────────────────────────────────────────────────
        if i_showEfficiency
            if sig_ineffSell
                label.new(bar_index, high + offset * 4.0,
                          text      = "INEFF SELL",
                          style     = label.style_label_down,
                          color     = color.new(i_bullSig, 30),
                          textcolor = color.white,
                          size      = size.small)
            if sig_ineffBuy
                label.new(bar_index, low - offset * 6.5,
                          text      = "INEFF BUY",
                          style     = label.style_label_up,
                          color     = color.new(i_bearSig, 30),
                          textcolor = color.white,
                          size      = size.small)

// =============================================================================
//  UNLIMITED-HISTORY PLOTS
// =============================================================================

plotshape(i_showAbsorption and sig_bullTrap,
          title = "Bull Trap", style = shape.triangledown, location = location.abovebar,
          color = i_bearSig, size = size.small, text = "BULL TRAP", textcolor = i_bearSig)

plotshape(i_showAbsorption and sig_bearTrap,
          title = "Bear Trap", style = shape.triangleup, location = location.belowbar,
          color = i_bullSig, size = size.small, text = "BEAR TRAP", textcolor = i_bullSig)

plotshape(i_showSqueeze and sig_bullSqueeze,
          title = "Squeeze Up", style = shape.diamond, location = location.abovebar,
          color = i_bullSig, size = size.normal, text = "SQZ↑", textcolor = i_bullSig)

plotshape(i_showSqueeze and sig_bearSqueeze,
          title = "Squeeze Down", style = shape.diamond, location = location.belowbar,
          color = i_bearSig, size = size.normal, text = "SQZ↓", textcolor = i_bearSig)

// Efficiency: circles on the side indicating where price is expected to go
plotshape(i_showEfficiency and sig_ineffSell,
          title = "Inefficient Sell", style = shape.circle, location = location.belowbar,
          color = color.new(i_bullSig, 20), size = size.tiny)

plotshape(i_showEfficiency and sig_ineffBuy,
          title = "Inefficient Buy", style = shape.circle, location = location.abovebar,
          color = color.new(i_bearSig, 20), size = size.tiny)

// Candle color: Squeeze (solid) > Trap (translucent) > Efficiency (faint)
barcolor(i_showSqueeze    and sig_bullSqueeze ? color.new(i_bullSig,  0)
       : i_showSqueeze    and sig_bearSqueeze ? color.new(i_bearSig,  0)
       : i_showAbsorption and sig_bearTrap    ? color.new(i_bullSig, 40)
       : i_showAbsorption and sig_bullTrap    ? color.new(i_bearSig, 40)
       : i_showEfficiency and sig_ineffSell   ? color.new(i_bullSig, 65)
       : i_showEfficiency and sig_ineffBuy    ? color.new(i_bearSig, 65)
       : na,
         title = "Signal Bar Color")

// Signal state in Data Window
plot(sig_bearTrap    ? 1 : 0, "Bear Trap",        display = display.data_window)
plot(sig_bullTrap    ? 1 : 0, "Bull Trap",        display = display.data_window)
plot(sig_bullSqueeze ? 1 : 0, "Squeeze Up",       display = display.data_window)
plot(sig_bearSqueeze ? 1 : 0, "Squeeze Down",     display = display.data_window)
plot(sig_ineffSell   ? 1 : 0, "Ineff Sell",       display = display.data_window)
plot(sig_ineffBuy    ? 1 : 0, "Ineff Buy",        display = display.data_window)

// =============================================================================
//  NOTES
//
//  1. TICKS PER ROW: simple int required. Read "ATR Ticks Hint" from Data Window.
//  2. HISTORY: ~13 bars full detail. plotshape/barcolor on ALL bars.
//  3. PLAN: Premium or Ultimate required for request.footprint().
//  4. SINGLE CALL: only one request.footprint() per script.
//
//  5. TRAP CONVICTION (★):
//     "Order flow anomalies only matter at logical structural locations.
//      Volume in middle of range is noise; volume at edges is a trap."
//     ★ fires when trap is at top/bottom 15% of the N-bar range.
//
//  6. EFFICIENCY SIGNALS:
//     If large sell delta fails to push price down → sellers exhausted → INEFF SELL.
//     If large buy delta fails to push price up   → buyers exhausted  → INEFF BUY.
//     Strongest when firing in the FRESH zone (mid-range new institutional entry failing).
//
//  7. ICEBERG ROW (bright border):
//     Institutions slice orders into micro-replenishments. A row with volume >>
//     average reveals passive limit absorption at that tick. Watch that price level.
//
//  8. HAMMER FILTER (default OFF):
//     BEAR TRAP + hammer candle = Sammy Hammerfoot pattern (long lower wick,
//     sellers at bottom, large buyers absorbed at the low). Reduces false signals.
// =============================================================================
````
