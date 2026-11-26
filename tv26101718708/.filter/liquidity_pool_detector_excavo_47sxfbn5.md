# Liquidity Pool Detector [EXCAVO]

- url: https://www.tradingview.com/script/47SxfbN5-Liquidity-Pool-Detector-EXCAVO/
- type: indicator
- pine_id: PUB;82b64827b23c446aaf6c6f62538d3ad1
- version: 1.0

## Description

Equal High/Low Cluster Detection with Sweep Identification and Period Reference Levels

The [i]Liquidity Pool Detector[/i] identifies where resting orders accumulate near swing
levels by detecting equal highs and equal lows using swing pivot analysis with ATR-based
tolerance. When price wicks through a cluster level and closes back inside, the indicator
marks a sweep - the moment orders at that level were filled and price reversed direction.

This is not a basic pivot-high/low indicator. The cluster-merging logic groups nearby
pivots into unified levels with touch counts, and the sweep filter distinguishes between
a genuine zone test and a breakout continuation.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW TO USE[/b]

[b]Step 1[/b]  →  Add the indicator to the price chart. Red solid lines appear above
              price (equal highs clusters) and blue solid lines appear below price
              (equal lows clusters). Previous day and week H/L reference levels
              appear as slightly thicker dotted lines.
[b]Step 2[/b]  →  Watch for sweep markers. "Highs Swept" appears on a bar where price
              wicked above an equal-highs cluster and closed back below it. "Lows
              Swept" appears below a bar where price wicked below equal lows and
              closed above. These bars indicate price tested and reversed from a cluster level.
[b]Step 3[/b]  →  Read the touch count on each cluster label. "Highs ×3" means three
              swing highs formed at approximately the same level - a stronger cluster
              with a stronger level formed by more historical touches.
[b]Step 4[/b]  →  Check the dashboard. Dist to High and Dist to Low show how many ATR
              units separate current price from the nearest cluster above and below.
              Values below 1.0 ATR highlight in orange - price is close to a level.
              Nearest High and Nearest Low show the exact price of those levels.
[b]Step 5[/b]  →  Set up sweep alerts to receive notifications on bar close when a
              cluster level is tested and rejected. Use JSON Alerts for bot integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW IT CALCULATES[/b]

[b]◆  Swing Pivot Detection[/b]
The indicator uses ta.pivothigh() and ta.pivotlow() with a configurable Swing Length
(default 3). A pivot high is confirmed when the bar's high is the highest point among
the surrounding N bars on each side - requiring N bars to the left and N bars to the
right, so detection occurs N bars after the actual pivot forms. This lag ensures the
pivot is fully confirmed and the value never changes after the bar closes. Lower Swing
Length values (2-3) suit intraday timeframes; higher values (5) suit daily charts.

[b]◆  Cluster Merging (ATR Tolerance)[/b]
When a new confirmed pivot is detected, the indicator compares it against all existing
clusters of the same type. If the distance between the new pivot and an existing cluster
level is within the Equal Tolerance threshold (default 0.5 x ATR), the pivots are merged:
the cluster level is updated to the weighted average of all touches, and the touch count
increments. If no nearby cluster exists and the cluster limit has not been reached, a new
cluster is created at that price level. This approach prevents visual noise from minor
price variations between otherwise equal levels.

[b]◆  Sweep Detection[/b]
On each confirmed bar close, every active cluster is checked against two conditions.
For equal-highs clusters: if the bar's high exceeded the cluster level AND the close is
below the cluster level, a sweep is registered - price moved through the zone of resting
orders and reversed. For equal-lows clusters: if the bar's low was below the cluster level
AND the close is above it, a sweep is registered. A close through the level without
reversal (close >= highs cluster, or close <= lows cluster) is treated as a breakout:
the cluster is invalidated and removed without a sweep marker.

[b]◆  Period Reference Levels[/b]
Previous Day High/Low and Previous Week High/Low are fetched using request.security()
with a confirmed-bar offset (high[1] / low[1] with barmerge.lookahead_on). These levels
are included in the Nearest High and Nearest Low dashboard calculations alongside the
detected equal-high/low clusters.

[b]◆  Non-Repainting Design[/b]
All cluster additions, sweep detections, and invalidations are gated on
barstate.isconfirmed. No cluster is created and no sweep marker is placed until the bar
closes. Pivot detection uses a right-bar offset that confirms the pivot on a fully closed
bar. No value changes after a bar is confirmed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ WHAT MAKES IT DIFFERENT[/b]

[b]◆  ATR-Based Cluster Tolerance[/b]
Most equal-high/low detectors use a fixed pip or percentage threshold that fails across
different instruments and timeframes. Using ATR as the tolerance baseline means the same
settings work on BTCUSD hourly (high ATR) and EURUSD daily (low ATR) without manual
recalibration. The tolerance adapts to current market conditions automatically.

[b]◆  Cluster Merging with Touch Count[/b]
Instead of drawing a separate line for every swing pivot, nearby pivots are merged into a
single cluster with an incrementing touch count. A cluster labeled "Highs ×3" represents
three independent swing highs at the same level - a significantly stronger zone than a
single untested level. The line and label update in place as new touches are added.

[b]◆  Sweep vs Breakout Distinction[/b]
The indicator explicitly separates sweep bars (wick through, close back inside) from
breakout bars (close through the level). A sweep generates a "Highs Swept" or "Lows
Swept" marker and an alert. A breakout silently removes the cluster. This distinction
matters: sweeps are potential reversal setups; breakouts confirm continuation.

[b]◆  Period Levels as Part of the Analysis[/b]
Previous Day and Week H/L are integrated into the same framework as the equal-high/low
clusters. They appear in the Nearest High/Low dashboard calculation and use the same color
scheme as cluster lines, making them immediately readable alongside the dynamically
detected clusters.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ DASHBOARD[/b]

Compact panel showing current conditions:
[list]
[*][b]Dist to High[/b] - distance from current price to nearest cluster above, in ATR units; turns orange below 1.0 ATR
[*][b]Dist to Low[/b] - distance from current price to nearest cluster below, in ATR units; turns orange below 1.0 ATR
[*][b]Nearest High[/b] - exact price of the closest active cluster or period level above
[*][b]Nearest Low[/b] - exact price of the closest active cluster or period level below
[*][b]Last Sweep[/b] - most recent sweep type: Highs Swept, Lows Swept, or - (none)
[*][b]Swing[/b] - active swing length parameter
[/list]

Legend table (bottom left) explains cluster lines, period levels, and sweep markers.
Both panels toggle in Dashboard settings.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ SETTINGS[/b]

[b]Detection[/b]
[list]
[*][b]Swing Length[/b] - 3 bars (pivot confirmation window left and right; use 2-3 for intraday, 5 for daily)
[*][b]Equal Tolerance (x ATR)[/b] - 0.5 (cluster merge radius as ATR multiple)
[*][b]Max Clusters[/b] - 10 (maximum active clusters tracked per direction)
[*][b]Max Display Distance (x ATR)[/b] - 5.0 (clusters beyond this ATR distance from price are hidden; detection continues)
[/list]

[b]Period Levels[/b]
[list]
[*][b]Show Prev Day H/L[/b] - ON (previous day high and low reference lines)
[*][b]Show Prev Week H/L[/b] - ON (previous week high and low reference lines)
[/list]

[b]Visualization[/b]
[list]
[*][b]Bull Color[/b] - default blue (equal-lows clusters and lows-swept markers)
[*][b]Bear Color[/b] - default red (equal-highs clusters and highs-swept markers)
[*][b]Sweep Color[/b] - default orange (sweep marker labels)
[*][b]Show Sweep Markers[/b] - ON (labeled markers on sweep bars)
[*][b]Background Highlight[/b] - OFF (subtle tint when price is within one ATR of nearest cluster)
[/list]

[b]Alerts[/b]
[list]
[*][b]JSON Alerts[/b] - OFF (enable for bot integration)
[/list]

[b]Dashboard[/b]
[list]
[*][b]Dashboard Position[/b] - Top Right
[*][b]Show Dashboard[/b] - ON
[*][b]Show Legend[/b] - ON
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ ALERTS[/b]

[list]
[*][b]Highs Swept[/b] - price wicked above equal-highs cluster and closed below on bar close
[*][b]Lows Swept[/b] - price wicked below equal-lows cluster and closed above on bar close
[*][b]Any Sweep[/b] - any cluster level tested and rejected on bar close
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Best regards,
EXCAVO

[quote]
[b]Disclaimer[/b]
Trading involves significant risk. This indicator is a technical analysis tool
and does not constitute financial advice, investment recommendations, or a
guarantee of future results. Past indicator behavior does not guarantee future
performance. Always use proper risk management and your own judgment.
[/quote]

## Source Code

````pine
// (c) EXCAVO
// This work is licensed under Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
//
// Liquidity Pool Detector [EXCAVO]
// -----------------------------------------------------------------------------
// Equal high/low cluster detection with sweep identification and period levels.
//
//@version=6
indicator("Liquidity Pool Detector [EXCAVO]", "EXCAVO Liquidity Pool Detector",
     overlay          = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_bars_back    = 500)

//-----------------------------------------------------------------------------}
// Inputs
//-----------------------------------------------------------------------------{
string GRP_DET    = "Detection"
string GRP_LVL    = "Period Levels"
string GRP_VIZ    = "Visualization"
string GRP_ALERTS = "Alerts"
string GRP_DASH   = "Dashboard"

int   i_swing     = input.int  (3,    "Swing Length",                    minval = 2, maxval = 20,        group = GRP_DET,
     tooltip = "Bars left and right required to confirm a swing pivot. Use 2-3 for intraday timeframes, 5 for Daily and above.")
float i_tol       = input.float(0.5,  "Equal Tolerance (x ATR)",         minval = 0.1, maxval = 2.0, step = 0.1, group = GRP_DET,
     tooltip = "Two pivots are treated as equal when within this ATR multiple of each other. Higher values merge more pivots into a single cluster.")
int   i_max_pools = input.int  (10,   "Max Clusters",                    minval = 3, maxval = 20,        group = GRP_DET,
     tooltip = "Maximum active clusters tracked at one time per direction.")
float i_max_dist  = input.float(5.0,  "Max Display Distance (x ATR)",    minval = 1.0, maxval = 30.0, step = 0.5, group = GRP_DET,
     tooltip = "Clusters further than this ATR distance from current price are hidden. Detection and sweep logic continues for all clusters regardless of distance.")

bool  i_show_pd   = input.bool (true,  "Show Prev Day H/L",   group = GRP_LVL,
     tooltip = "Draw previous day high and low as reference levels.")
bool  i_show_pw   = input.bool (true,  "Show Prev Week H/L",  group = GRP_LVL,
     tooltip = "Draw previous week high and low as reference levels.")

color C_BULL      = input.color(color.rgb(0,   60,  180), "Bull Color",  group = GRP_VIZ,
     tooltip = "Color for equal lows (SSL) pools and bullish sweep markers.")
color C_BEAR      = input.color(color.rgb(200, 40,  40),  "Bear Color",  group = GRP_VIZ,
     tooltip = "Color for equal highs (BSL) pools and bearish sweep markers.")
color C_SIGNAL    = input.color(color.rgb(255, 140, 0),   "Sweep Color", group = GRP_VIZ,
     tooltip = "Color for sweep markers when a liquidity pool is taken.")
bool  i_show_sw   = input.bool (true,  "Show Sweep Markers",  group = GRP_VIZ,
     tooltip = "Show labeled markers when a liquidity pool is swept.")
bool  i_show_bg   = input.bool (false, "Background Highlight", group = GRP_VIZ,
     tooltip = "Subtle background tint when price is within one ATR of the nearest pool.")

bool  i_json      = input.bool (false, "JSON Alerts (for bots)", group = GRP_ALERTS,
     tooltip = "Enable JSON-formatted alerts for bot integration.")

string i_dash_pos  = input.string("Top Right", "Dashboard Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH,
     tooltip = "Position of the dashboard panel.")
bool   i_show_dash = input.bool(true, "Show Dashboard", group = GRP_DASH)
bool   i_show_lgnd = input.bool(true, "Show Legend",    group = GRP_DASH)

//-----------------------------------------------------------------------------}
// Constants
//-----------------------------------------------------------------------------{
color C_NEUTRAL     = color.rgb(80,  80,  100)
color C_DASH_BG     = color.rgb(50,  53,  60)
color C_DASH_BORDER = color.rgb(80,  85,  95)
color C_DASH_BULL   = color.rgb(80,  140, 255)
color C_DASH_BEAR   = color.rgb(240, 70,  70)
color C_DASH_SIGNAL = color.rgb(255, 170, 50)

//-----------------------------------------------------------------------------}
// Core
//-----------------------------------------------------------------------------{
float atr_raw = ta.atr(14)
float atr     = nz(atr_raw, close * 0.002)
float tol     = i_tol * atr

float ph = ta.pivothigh(high, i_swing, i_swing)
float pl = ta.pivotlow (low,  i_swing, i_swing)

[pd_high, pd_low] = request.security(syminfo.tickerid, "D",
     [high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_on)
[pw_high, pw_low] = request.security(syminfo.tickerid, "W",
     [high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_on)

//-----------------------------------------------------------------------------}
// Pool State
//-----------------------------------------------------------------------------{
// Bear pools: BSL - equal highs above price (Buy Side Liquidity)
var float[] bear_lvl = array.new<float>()
var int[]   bear_cnt = array.new<int>()
var int[]   bear_bar = array.new<int>()
var line[]  bear_ln  = array.new<line>()
var label[] bear_lb  = array.new<label>()

// Bull pools: SSL - equal lows below price (Sell Side Liquidity)
var float[] bull_lvl = array.new<float>()
var int[]   bull_cnt = array.new<int>()
var int[]   bull_bar = array.new<int>()
var line[]  bull_ln  = array.new<line>()
var label[] bull_lb  = array.new<label>()

// Deletion index buffers (cleared each confirmed bar)
var int[] del_b = array.new<int>()
var int[] del_u = array.new<int>()

// Sweep signals and state
var bool   bull_swept_sig = false
var bool   bear_swept_sig = false
var string last_sweep     = "-"
var float  last_swept_lvl = na

// Sweep marker pool
var label[] lbl_pool = array.new<label>()


//-----------------------------------------------------------------------------}
// Detection
//-----------------------------------------------------------------------------{
if barstate.isconfirmed
    bull_swept_sig := false
    bear_swept_sig := false
    array.clear(del_b)
    array.clear(del_u)

    // --- New pivot high -> bear pools (BSL / EQH) ---
    if not na(ph)
        bool merged = false
        int  nb     = bear_lvl.size()
        if nb > 0
            for i = 0 to nb - 1
                if math.abs(bear_lvl.get(i) - ph) <= tol
                    int   nc  = bear_cnt.get(i) + 1
                    float avg = (bear_lvl.get(i) * (nc - 1) + ph) / nc
                    bear_lvl.set(i, avg)
                    bear_cnt.set(i, nc)
                    line.set_y1(bear_ln.get(i), avg)
                    line.set_y2(bear_ln.get(i), avg)
                    label.set_y(bear_lb.get(i), avg + atr * 0.15)
                    line.set_color(bear_ln.get(i), color.new(C_BEAR, 0))
                    label.set_text(bear_lb.get(i), "Highs ×" + str.tostring(nc))
                    merged := true
                    break
        if not merged and bear_lvl.size() < i_max_pools
            int src = bar_index - i_swing
            bear_lvl.push(ph)
            bear_cnt.push(1)
            bear_bar.push(src)
            bear_ln.push(line.new(src, ph, bar_index + 25, ph,
                 color = color.new(C_BEAR, 55), style = line.style_solid, width = 1))
            bear_lb.push(label.new(bar_index + 3, ph + atr * 0.15, "Highs",
                 color = color.new(C_BEAR, 100), textcolor = C_BEAR,
                 style = label.style_label_left, size = size.small))

    // --- New pivot low -> bull pools (SSL / EQL) ---
    if not na(pl)
        bool merged = false
        int  nu     = bull_lvl.size()
        if nu > 0
            for i = 0 to nu - 1
                if math.abs(bull_lvl.get(i) - pl) <= tol
                    int   nc  = bull_cnt.get(i) + 1
                    float avg = (bull_lvl.get(i) * (nc - 1) + pl) / nc
                    bull_lvl.set(i, avg)
                    bull_cnt.set(i, nc)
                    line.set_y1(bull_ln.get(i), avg)
                    line.set_y2(bull_ln.get(i), avg)
                    label.set_y(bull_lb.get(i), avg + atr * 0.15)
                    line.set_color(bull_ln.get(i), color.new(C_BULL, 0))
                    label.set_text(bull_lb.get(i), "Lows ×" + str.tostring(nc))
                    merged := true
                    break
        if not merged and bull_lvl.size() < i_max_pools
            int src = bar_index - i_swing
            bull_lvl.push(pl)
            bull_cnt.push(1)
            bull_bar.push(src)
            bull_ln.push(line.new(src, pl, bar_index + 25, pl,
                 color = color.new(C_BULL, 55), style = line.style_solid, width = 1))
            bull_lb.push(label.new(bar_index + 3, pl + atr * 0.15, "Lows",
                 color = color.new(C_BULL, 100), textcolor = C_BULL,
                 style = label.style_label_left, size = size.small))

    // --- Sweep & invalidation: bear pools (BSL / EQH) ---
    int nb2 = bear_lvl.size()
    if nb2 > 0
        for i = 0 to nb2 - 1
            float lvl = bear_lvl.get(i)
            if high > lvl and close < lvl
                bear_swept_sig := true
                last_sweep     := "Highs Swept"
                last_swept_lvl := lvl
                if i_show_sw
                    if lbl_pool.size() > 440
                        label.delete(lbl_pool.shift())
                    lbl_pool.push(label.new(bar_index, lvl, "Highs Swept",
                         color = color.new(C_SIGNAL, 15), textcolor = color.white,
                         style = label.style_label_right, size = size.small))
                line.delete(bear_ln.get(i))
                label.delete(bear_lb.get(i))
                del_b.push(i)
            else if close >= lvl
                line.delete(bear_ln.get(i))
                label.delete(bear_lb.get(i))
                del_b.push(i)
        if del_b.size() > 0
            array.sort(del_b, order.descending)
            for i = 0 to del_b.size() - 1
                int idx = del_b.get(i)
                bear_lvl.remove(idx)
                bear_cnt.remove(idx)
                bear_bar.remove(idx)
                bear_ln.remove(idx)
                bear_lb.remove(idx)

    // --- Sweep & invalidation: bull pools (SSL / EQL) ---
    int nu2 = bull_lvl.size()
    if nu2 > 0
        for i = 0 to nu2 - 1
            float lvl = bull_lvl.get(i)
            if low < lvl and close > lvl
                bull_swept_sig := true
                last_sweep     := "Lows Swept"
                last_swept_lvl := lvl
                if i_show_sw
                    if lbl_pool.size() > 440
                        label.delete(lbl_pool.shift())
                    lbl_pool.push(label.new(bar_index, lvl, "Lows Swept",
                         color = color.new(C_SIGNAL, 15), textcolor = color.white,
                         style = label.style_label_right, size = size.small))
                line.delete(bull_ln.get(i))
                label.delete(bull_lb.get(i))
                del_u.push(i)
            else if close <= lvl
                line.delete(bull_ln.get(i))
                label.delete(bull_lb.get(i))
                del_u.push(i)
        if del_u.size() > 0
            array.sort(del_u, order.descending)
            for i = 0 to del_u.size() - 1
                int idx = del_u.get(i)
                bull_lvl.remove(idx)
                bull_cnt.remove(idx)
                bull_bar.remove(idx)
                bull_ln.remove(idx)
                bull_lb.remove(idx)

// Extend active pool lines and apply distance visibility filter
if bear_ln.size() > 0
    for i = 0 to bear_ln.size() - 1
        float lvl  = bear_lvl.get(i)
        int   cnt  = bear_cnt.get(i)
        bool  near = math.abs(lvl - close) <= i_max_dist * atr
        line.set_x2(bear_ln.get(i), bar_index + 25)
        line.set_color(bear_ln.get(i), near ? color.new(C_BEAR, cnt > 1 ? 0 : 55) : color.new(C_BEAR, 100))
        label.set_x(bear_lb.get(i), bar_index + 3)
        label.set_textcolor(bear_lb.get(i), near ? C_BEAR : color.new(C_BEAR, 100))
if bull_ln.size() > 0
    for i = 0 to bull_ln.size() - 1
        float lvl  = bull_lvl.get(i)
        int   cnt  = bull_cnt.get(i)
        bool  near = math.abs(lvl - close) <= i_max_dist * atr
        line.set_x2(bull_ln.get(i), bar_index + 25)
        line.set_color(bull_ln.get(i), near ? color.new(C_BULL, cnt > 1 ? 0 : 55) : color.new(C_BULL, 100))
        label.set_x(bull_lb.get(i), bar_index + 3)
        label.set_textcolor(bull_lb.get(i), near ? C_BULL : color.new(C_BULL, 100))

//-----------------------------------------------------------------------------}
// Nearest Levels
//-----------------------------------------------------------------------------{
float nearest_bsl = na
float nearest_ssl = na

if bear_lvl.size() > 0
    for i = 0 to bear_lvl.size() - 1
        float lvl = bear_lvl.get(i)
        if lvl > close
            nearest_bsl := na(nearest_bsl) or lvl < nearest_bsl ? lvl : nearest_bsl

if bull_lvl.size() > 0
    for i = 0 to bull_lvl.size() - 1
        float lvl = bull_lvl.get(i)
        if lvl < close
            nearest_ssl := na(nearest_ssl) or lvl > nearest_ssl ? lvl : nearest_ssl

if i_show_pd
    if not na(pd_high) and pd_high > close
        nearest_bsl := na(nearest_bsl) or pd_high < nearest_bsl ? pd_high : nearest_bsl
    if not na(pd_low) and pd_low < close
        nearest_ssl := na(nearest_ssl) or pd_low > nearest_ssl ? pd_low : nearest_ssl

if i_show_pw
    if not na(pw_high) and pw_high > close
        nearest_bsl := na(nearest_bsl) or pw_high < nearest_bsl ? pw_high : nearest_bsl
    if not na(pw_low) and pw_low < close
        nearest_ssl := na(nearest_ssl) or pw_low > nearest_ssl ? pw_low : nearest_ssl

bool near_pool = (not na(nearest_bsl) and nearest_bsl - close < atr) or
                 (not na(nearest_ssl) and close - nearest_ssl < atr)

//-----------------------------------------------------------------------------}
// Visuals
//-----------------------------------------------------------------------------{
bgcolor(i_show_bg and near_pool ? color.new(C_SIGNAL, 93) : na,
     title = "Near Pool")

//-----------------------------------------------------------------------------}
// Period Levels
//-----------------------------------------------------------------------------{
var line  ln_pdh = na
var line  ln_pdl = na
var line  ln_pwh = na
var line  ln_pwl = na
var label lb_pdh = na
var label lb_pdl = na
var label lb_pwh = na
var label lb_pwl = na

if barstate.islast
    line.delete(ln_pdh), line.delete(ln_pdl)
    line.delete(ln_pwh), line.delete(ln_pwl)
    label.delete(lb_pdh), label.delete(lb_pdl)
    label.delete(lb_pwh), label.delete(lb_pwl)

    int ext   = bar_index + 25
    int start = math.max(0, bar_index - 500)

    if i_show_pd and not na(pd_high) and not na(pd_low)
        ln_pdh := line.new(start, pd_high, ext, pd_high,
             color = color.new(C_BEAR, 40), style = line.style_dotted, width = 2)
        ln_pdl := line.new(start, pd_low,  ext, pd_low,
             color = color.new(C_BULL, 40), style = line.style_dotted, width = 2)
        lb_pdh := label.new(ext, pd_high, "Prev Day H",
             color = color.new(C_BEAR, 100), textcolor = C_BEAR,
             style = label.style_label_left, size = size.small)
        lb_pdl := label.new(ext, pd_low, "Prev Day L",
             color = color.new(C_BULL, 100), textcolor = C_BULL,
             style = label.style_label_left, size = size.small)

    if i_show_pw and not na(pw_high) and not na(pw_low)
        ln_pwh := line.new(start, pw_high, ext, pw_high,
             color = color.new(C_BEAR, 55), style = line.style_dotted, width = 2)
        ln_pwl := line.new(start, pw_low,  ext, pw_low,
             color = color.new(C_BULL, 55), style = line.style_dotted, width = 2)
        lb_pwh := label.new(ext, pw_high, "Prev Week H",
             color = color.new(C_BEAR, 100), textcolor = C_BEAR,
             style = label.style_label_left, size = size.small)
        lb_pwl := label.new(ext, pw_low, "Prev Week L",
             color = color.new(C_BULL, 100), textcolor = C_BULL,
             style = label.style_label_left, size = size.small)

//-----------------------------------------------------------------------------}
// Dashboard
//-----------------------------------------------------------------------------{
string dash_pos = switch i_dash_pos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

if barstate.islast and i_show_dash
    float dist_high = na(nearest_bsl) ? na : (nearest_bsl - close) / atr
    float dist_low  = na(nearest_ssl) ? na : (close - nearest_ssl) / atr

    color dist_high_col = na(dist_high)  ? C_NEUTRAL :
                          dist_high < 1.0 ? C_DASH_SIGNAL :
                          dist_high < 3.0 ? C_DASH_BEAR : C_NEUTRAL
    color dist_low_col  = na(dist_low)   ? C_NEUTRAL :
                          dist_low  < 1.0 ? C_DASH_SIGNAL :
                          dist_low  < 3.0 ? C_DASH_BULL : C_NEUTRAL

    color sweep_col = switch last_sweep
        "Highs Swept" => C_DASH_BEAR
        "Lows Swept"  => C_DASH_BULL
        => C_NEUTRAL

    var table dash = table.new(dash_pos, 2, 7,
         bgcolor = C_DASH_BG, border_color = C_DASH_BORDER, border_width = 2,
         frame_color = C_DASH_BORDER, frame_width = 2)

    table.cell(dash, 0, 0, "EXCAVO",
         text_color = C_DASH_BULL, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, "Liquidity",
         text_color = color.white, text_size = size.normal, text_halign = text.align_right)

    table.cell(dash, 0, 1, "Dist to High",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, na(dist_high) ? "-" : str.tostring(dist_high, "0.0") + " ATR",
         text_color = dist_high_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 2, "Dist to Low",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, na(dist_low) ? "-" : str.tostring(dist_low, "0.0") + " ATR",
         text_color = dist_low_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 3, "Nearest High",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, na(nearest_bsl) ? "-" : str.tostring(nearest_bsl, format.mintick),
         text_color = na(nearest_bsl) ? C_NEUTRAL : C_DASH_BEAR,
         text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 4, "Nearest Low",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, na(nearest_ssl) ? "-" : str.tostring(nearest_ssl, format.mintick),
         text_color = na(nearest_ssl) ? C_NEUTRAL : C_DASH_BULL,
         text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 5, "Last Sweep",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, last_sweep,
         text_color = sweep_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 6, "Swing",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 6, str.tostring(i_swing),
         text_color = C_NEUTRAL, text_size = size.small, text_halign = text.align_right)

//-----------------------------------------------------------------------------}
// Legend
//-----------------------------------------------------------------------------{
if barstate.islast and i_show_lgnd
    var table leg = table.new(position.bottom_left, 2, 7,
         bgcolor = C_DASH_BG, border_color = C_DASH_BORDER, border_width = 1,
         frame_color = C_DASH_BORDER, frame_width = 1)

    table.cell(leg, 0, 0, "LEGEND",
         text_color = C_DASH_BULL, text_size = size.normal,
         text_halign = text.align_center, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 0, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.merge_cells(leg, 0, 0, 1, 0)

    table.cell(leg, 0, 1, "┅", text_color = C_DASH_BEAR,   text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 1, "Previous day / week high",
         text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 2, "┅", text_color = C_DASH_BULL,   text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 2, "Previous day / week low",
         text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 3, "━", text_color = C_DASH_BEAR,   text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 3, "Equal highs cluster",
         text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 4, "━", text_color = C_DASH_BULL,   text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 4, "Equal lows cluster",
         text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 5, "▼", text_color = C_DASH_SIGNAL, text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 5, "Level swept",
         text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 6, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 6, "", text_size = size.small, bgcolor = C_DASH_BG)

//-----------------------------------------------------------------------------}
// Alerts
//-----------------------------------------------------------------------------{
alertcondition(bear_swept_sig, title = "Highs Swept",
     message = "Liquidity Pool Detector [EXCAVO]: Equal highs swept on {{ticker}} ({{interval}})")
alertcondition(bull_swept_sig, title = "Lows Swept",
     message = "Liquidity Pool Detector [EXCAVO]: Equal lows swept on {{ticker}} ({{interval}})")
alertcondition(bear_swept_sig or bull_swept_sig, title = "Any Sweep",
     message = "Liquidity Pool Detector [EXCAVO]: Level swept on {{ticker}} ({{interval}})")

if i_json and (bear_swept_sig or bull_swept_sig) and barstate.isconfirmed
    string ev = bear_swept_sig ? "HIGHS_SWEPT" : "LOWS_SWEPT"
    string j = '{"ticker":"' + syminfo.ticker + '","event":"' + ev + '",' +
               '"level":' + str.tostring(last_swept_lvl, format.mintick) + ',' +
               '"price":' + str.tostring(close, format.mintick) + ',' +
               '"bsl_pools":' + str.tostring(bear_lvl.size()) + ',' +
               '"ssl_pools":' + str.tostring(bull_lvl.size()) + ',' +
               '"indicator":"Liquidity_Pool_Detector_EXCAVO","timeframe":"' + timeframe.period + '"}'
    alert(j, alert.freq_once_per_bar)
````
