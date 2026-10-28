# LongTrend

- url: https://www.tradingview.com/script/H0iP5pFg/
- type: indicator
- pine_id: PUB;2e22287961d548e8888f210606b5c71c
- version: 1.0

## Description

LongTrend

Overlay indicator for TradingView that combines an adaptive, clustering-based trend following engine, PVSRA volume analysis and three moving averages, with a summary dashboard and confluence signals.

HOW IT WORKS

1) LongTrend AI
The script calculates in parallel multiple variants of an ATR-based trailing stop, each with a different multiplier (from Min to Max, according to the Step setting). Each variant is scored with an exponential moving average of its performance (Performance Memory). A K-Means algorithm splits the variants into three clusters: Best, Average and Worst. The average multiplier of the selected cluster (Source Cluster) drives the final trailing stop and the trend state (BULL/BEAR).

2) PVSRA and volume
Candles are colored according to volume relative to its moving average:
- Climax (green/magenta): volume equal to or above 2.7 times the average
- Rising (soft green/magenta): volume equal to or above 1.8 times the average
- Normal: white if bullish, red if bearish
All colors and multipliers can be changed from the settings menu.

3) Moving averages
SMA 20, 50 and 200 with dynamic color based on slope.

4) SUPER CONFLUENCE signals
A BUY or SELL signal appears only when all of the following occur together:
- the LongTrend trailing stop crosses the SMA 20
- the LongTrend trend agrees with the direction
- volume is at least Rising
- the candle closes in the direction of the signal
Alerts are available for both signals.

5) Dashboard
Table showing the AI trend status, PVSRA volume, SMA 20/50 relationship, price position relative to the SMA 200 and the AI multiplier in use. Position and size are configurable.

DISCLAIMER

This indicator is provided for informational and educational purposes only and does not constitute financial advice, an investment recommendation or a solicitation to buy or sell any instrument. Trading, especially in cryptocurrencies, involves a high level of risk and may result in the partial or total loss of the invested capital. Past performance does not guarantee future results. Signals may be wrong or late, and the indicator is not a substitute for your own analysis or proper risk management. The user is solely responsible for their own trading decisions. Use this script at your own risk and, if needed, consult a qualified financial advisor.

## Source Code

````pine
//@version=6
indicator('LongTrend', overlay = true, max_labels_count = 500, max_lines_count = 50)

//------------------------------------------------------------------------------
// SETTINGS
//-----------------------------------------------------------------------------{
group_ai = "AI: LongTrend Clustering"
length_atr_ai = input.int(10, 'ATR Length AI', group = group_ai)
minMult       = input.int(1, 'Factor Range Min', minval = 1, inline = 'factor', group = group_ai)
maxMult       = input.int(5, 'Max', minval = 1, inline = 'factor', group = group_ai)
step          = input.float(.5, 'Step', minval = 0.1, step = 0.1, group = group_ai)
perfAlpha     = input.float(10, 'Performance Memory', minval = 2, group = group_ai)
fromCluster   = input.string('Best', 'Source Cluster', options = ['Best', 'Average', 'Worst'], group = group_ai)

group_pvsra = "PVSRA & Volume Logic"
p_length        = input.int(10, 'Volume MA Period', group = group_pvsra)
factor_climax   = input.float(2.7, 'Climax Multiplier', group = group_pvsra) 
factor_rising   = input.float(1.8, 'Rising Multiplier', group = group_pvsra) 
color_bull_norm = input.color(color.new(color.white, 20), 'Bull Normal Candle', group = group_pvsra)
color_bear_norm = input.color(color.new(color.red, 20),   'Bear Normal Candle', group = group_pvsra)

group_ma = "Dynamic Moving Averages"
len20        = input.int(20, 'SMA 20', group = group_ma)
len50        = input.int(50, 'SMA 50', group = group_ma)
len200       = input.int(200, 'SMA 200', group = group_ma)

group_dash = "Summary Dashboard"
show_dash    = input.bool(true, "Show Table", group = group_dash)
dash_pos     = input.string("Top Right", "Table Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = group_dash)
dash_size    = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal"], group = group_dash)

group_visual = "Signal Visualization"
tag_size      = input.string("Small", "Tag Size", options = ["Micro", "Tiny", "Small", "Normal"], group = group_visual)
compact_tag   = input.bool(false, "Compact Text (BUY/SELL only)", group = group_visual)
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------
// TYPE DEFINITIONS (UDT)
//-----------------------------------------------------------------------------{
type longtrend
    float upper = hl2
    float lower = hl2
    float output = hl2
    float perf = 0.
    float factor
    int trend = 0

type vector
    array<float> out
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------
// MULTI-LONGTREND AI CALCULATION
//-----------------------------------------------------------------------------{
var holder  = array.new<longtrend>(0)
var factors = array.new<float>(0)

if barstate.isfirst
    for i = 0 to int((maxMult - minMult) / step) by 1
        factors.push(minMult + i * step)
        holder.push(longtrend.new())

atr_ai = ta.atr(length_atr_ai)

for k = 0 to holder.size() - 1
    get_lt = holder.get(k)
    f = factors.get(k)

    up = hl2 + atr_ai * f
    dn = hl2 - atr_ai * f

    get_lt.trend  := close > get_lt.upper ? 1 : close < get_lt.lower ? 0 : get_lt.trend
    get_lt.upper  := close[1] < get_lt.upper ? math.min(up, get_lt.upper) : up
    get_lt.lower  := close[1] > get_lt.lower ? math.max(dn, get_lt.lower) : dn

    diff = nz(math.sign(close[1] - get_lt.output))
    get_lt.perf   := get_lt.perf + 2 / (perfAlpha + 1) * (nz(close - close[1]) * diff - get_lt.perf)
    get_lt.output := get_lt.trend == 1 ? get_lt.lower : get_lt.upper
    get_lt.factor := f
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------
// AI ENGINE (K-Means Clustering)
//-----------------------------------------------------------------------------{
var array<vector> perfclusters = na
var array<vector> factors_clusters = na
centroids = array.new<float>(0)

if last_bar_index - bar_index <= 1000 
    data_perf = array.new<float>(0)
    for element in holder
        data_perf.push(element.perf)

    centroids.push(data_perf.percentile_linear_interpolation(25))
    centroids.push(data_perf.percentile_linear_interpolation(50))
    centroids.push(data_perf.percentile_linear_interpolation(75))

    for _ = 0 to 50 
        factors_clusters := array.from(vector.new(array.new<float>(0)), vector.new(array.new<float>(0)), vector.new(array.new<float>(0)))
        perfclusters     := array.from(vector.new(array.new<float>(0)), vector.new(array.new<float>(0)), vector.new(array.new<float>(0)))

        for i = 0 to data_perf.size() - 1
            v = data_perf.get(i)
            dists = array.new<float>(0)
            for c in centroids
                dists.push(math.abs(v - c))
            idx = dists.indexof(dists.min())
            perfclusters.get(idx).out.push(v)
            factors_clusters.get(idx).out.push(factors.get(i))

        new_centroids = array.new<float>(0)
        for cl in perfclusters
            new_centroids.push(cl.out.avg())
        
        converged = new_centroids.get(0) == centroids.get(0) and new_centroids.get(1) == centroids.get(1) and new_centroids.get(2) == centroids.get(2)
        centroids := new_centroids
        if converged
            break
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------
// PVSRA LOGIC & SMAs
//-----------------------------------------------------------------------------{
av = ta.sma(volume, p_length)
is_climax = volume >= av * factor_climax
is_rising = volume >= av * factor_rising
is_bull   = close > open
is_bear   = close < open

sma20  = ta.sma(close, len20)
sma50  = ta.sma(close, len50)
sma200 = ta.sma(close, len200)

// PVSRA Colors
color_bull_climax = #52ff00 
color_bear_climax = #ff00ff 
color_bull_rising = color.new(#52ff00, 40)
color_bear_rising = color.new(#ff00ff, 40)
candleColor = is_climax ? (is_bull ? color_bull_climax : color_bear_climax) : is_rising ? (is_bull ? color_bull_rising : color_bear_rising) : (is_bull ? color_bull_norm : color_bear_norm)
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------
// CONFLUENCE & AI TRAILING STOP
//-----------------------------------------------------------------------------{
var float target_f = na
var int best_idx = 0
var int worst_idx = 0

if not na(perfclusters) and perfclusters.size() == 3
    best_idx := 0
    worst_idx := 0
    for i = 1 to 2
        if perfclusters.get(i).out.size() > 0 and perfclusters.get(best_idx).out.size() > 0
            if perfclusters.get(i).out.avg() > perfclusters.get(best_idx).out.avg()
                best_idx := i
        if perfclusters.get(i).out.size() > 0 and perfclusters.get(worst_idx).out.size() > 0
            if perfclusters.get(i).out.avg() < perfclusters.get(worst_idx).out.avg()
                worst_idx := i

c_idx = fromCluster == 'Best' ? best_idx : fromCluster == 'Worst' ? worst_idx : 1

if not na(perfclusters) and perfclusters.size() == 3 and factors_clusters.get(c_idx).out.size() > 0
    target_f := nz(factors_clusters.get(c_idx).out.avg(), nz(target_f, 3.0))

var float up_ai = hl2
var float dn_ai = hl2
var int os_ai = 1

safe_close_prev = nz(close[1], close)
safe_target_f   = nz(target_f, 3.0)

cur_up = hl2 + atr_ai * safe_target_f
cur_dn = hl2 - atr_ai * safe_target_f

up_ai := safe_close_prev < up_ai ? math.min(cur_up, up_ai) : cur_up
dn_ai := safe_close_prev > dn_ai ? math.max(cur_dn, dn_ai) : cur_dn
os_ai := close > up_ai ? 1 : close < dn_ai ? 0 : os_ai
ts_ai  = os_ai == 1 ? dn_ai : up_ai

st_sma_cross = ta.cross(ts_ai, sma20)

confluence_bull = st_sma_cross and os_ai == 1 and is_rising and is_bull
confluence_bear = st_sma_cross and os_ai == 0 and is_rising and is_bear
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------
// VISUALS: PLOTS & LABELS
//-----------------------------------------------------------------------------{
barcolor(candleColor)

plot(sma20,  'SMA 20',  sma20  > sma20[1]  ? color.green : color.red, linewidth = 2)
plot(sma50,  'SMA 50',  sma50  > sma50[1]  ? color.white : color.gray, linewidth = 2)
plot(sma200, 'SMA 200', sma200 > sma200[1] ? #2962ff    : #1848cc,    linewidth = 3)

t_size   = tag_size == "Micro" ? size.auto : tag_size == "Tiny" ? size.tiny : tag_size == "Small" ? size.small : size.normal
txt_buy  = compact_tag ? "BUY"  : "SUPER CONFLUENCE\nBUY"
txt_sell = compact_tag ? "SELL" : "SUPER CONFLUENCE\nSELL"

if confluence_bull
    label.new(bar_index, low, txt_buy, color=color_bull_climax, style=label.style_label_up, textcolor=color.black, size=t_size)
if confluence_bear
    label.new(bar_index, high, txt_sell, color=color_bear_climax, style=label.style_label_down, textcolor=color.white, size=t_size)
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------
// SUMMARY DASHBOARD
//-----------------------------------------------------------------------------{
t_pos  = dash_pos == "Top Right" ? position.top_right : dash_pos == "Bottom Right" ? position.bottom_right : dash_pos == "Top Left" ? position.top_left : position.bottom_left
t_size_dash = dash_size == "Tiny" ? size.tiny : dash_size == "Small" ? size.small : size.normal

var table dash = table.new(t_pos, 2, 6, bgcolor = #1e222d, border_color = #373a46, border_width = 1)

if show_dash and barstate.islast
    // Header
    table.cell(dash, 0, 0, "INDICATOR", text_color = color.white, text_size = t_size_dash, bgcolor = #313339)
    table.cell(dash, 1, 0, "STATUS",    text_color = color.white, text_size = t_size_dash, bgcolor = #313339)

    // AI Status
    table.cell(dash, 0, 1, "AI Trend", text_color = color.white, text_size = t_size_dash)
    table.cell(dash, 1, 1, os_ai == 1 ? "BULL" : "BEAR", bgcolor = os_ai == 1 ? color.teal : color.red, text_color = color.white, text_size = t_size_dash)

    // PVSRA Status
    table.cell(dash, 0, 2, "PVSRA Vol", text_color = color.white, text_size = t_size_dash)
    table.cell(dash, 1, 2, is_climax ? "CLIMAX" : is_rising ? "RISING" : "NORMAL", bgcolor = candleColor, text_color = color.white, text_size = t_size_dash)

    // SMA Trends
    table.cell(dash, 0, 3, "SMA 20/50", text_color = color.white, text_size = t_size_dash)
    table.cell(dash, 1, 3, sma20 > sma50 ? "BULLISH" : "BEARISH", bgcolor = sma20 > sma50 ? color.green : color.red, text_color = color.white, text_size = t_size_dash)

    table.cell(dash, 0, 4, "Trend 200", text_color = color.white, text_size = t_size_dash)
    table.cell(dash, 1, 4, close > sma200 ? "ABOVE" : "BELOW", bgcolor = close > sma200 ? color.green : color.red, text_color = color.white, text_size = t_size_dash)

    // AI Factor Info
    table.cell(dash, 0, 5, "AI Multi", text_color = color.white, text_size = t_size_dash)
    table.cell(dash, 1, 5, str.tostring(target_f, "#.##"), text_color = color.white, text_size = t_size_dash)
//-----------------------------------------------------------------------------}

// Alerts
alertcondition(confluence_bull, "Super Confluence BUY", "AI + PVSRA + SMA20 Cross BUY signal detected!")
alertcondition(confluence_bear, "Super Confluence SELL", "AI + PVSRA + SMA20 Cross SELL signal detected!")
````
