# Volume Waves (Buy / Sell /  Delta) [footprint data]

- url: https://www.tradingview.com/script/KtbNnZ5H-volume-waves-buy-sell-delta-footprint-data/
- type: indicator
- pine_id: PUB;446e7e553eaa4b7bb1d5b15fbc67f6c5
- version: 1.0

## Description

[b]⚠️ This indicator uses footprint data and requires TradingView Premium plan or higher. Without footprint support the waves will not appear.[/b]

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

[b]Volume Waves (Buy / Sell / Δ)[/b] is a footprint-based volume visualization that renders buy volume, sell volume and delta directly on the price chart as adaptive filled waves - no separate pane, everything stays on the candles where it belongs.

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]What you see[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

Three layers are rendered directly on the chart:
[list]
[*][b]Volume wave (gray)[/b] — total buying or selling activity scaled to recent history. Shows how significant the current bar's volume is compared to the lookback window.
[*][b]Delta wave (semi-transparent lime / purple)[/b] — positive delta (buyers dominated) is lime, negative delta (sellers dominated) is purple. Rendered on top of the volume wave, always stays within its boundaries.
[*][b]Extreme delta (fully opaque lime / purple)[/b] — same colors, full opacity. Appears only when both volume and imbalance cross their thresholds simultaneously. The brighter the spike stands out against the semi-transparent background — the more significant that bar was.
[/list]
The waves are normalized relative to recent market activity and scaled dynamically using ATR, allowing the visualization to remain readable across different instruments and timeframes without constant manual adjustment.

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]Why footprint data matters[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

Most "buy/sell volume" or "volume delta" indicators available on charts do not use actual trade classification. They approximate — typically by comparing the candle's close to its open and assuming the entire volume was either buying or selling, or by applying the same approximation from a lower timeframe (the accuracy does not improve from this — the method stays the same, only the scale changes).

Footprint data works differently. When supported by the broker and exchange feed, TradingView provides bid/ask-classified executed trades where each transaction is identified as aggressive buying or selling at the moment of execution. Not calculated from price behavior, not estimated from candle shape — recorded as a fact from the exchange order book.

This distinction becomes especially important around:
[list]
[*]high-liquidity levels and absorption zones,
[*]breakouts and exhaustion moves,
[*]and news-driven volatility.
[/list]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]Display modes[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

[b]Two sides[/b] — buy and sell waves expand in opposite directions from the baseline: buy volume upward, sell volume downward. Buyer and seller dominance is immediately visible.

[b]One side[/b] — buy and sell volume are stacked upward together as total activity. Useful when focusing on participation intensity or volatility expansion. The delta wave remains visible and colored by sign — directional information is always present.

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]How it is built[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

[list]
[*][b]Shared normalization.[/b] Buy and sell volume are both divided by the same highest total volume over the lookback window. This preserves the real proportion between them and ensures delta always reflects the correct sign and magnitude. Independently normalized sides would distort this relationship.
[*][b]Adaptive ATR scaling.[/b] Wave height = normalized volume × ATR(200) × scale factor. This gives the indicator automatic adaptation across markets, stable visual proportions across timeframes, and consistent readability during volatility expansion. Quiet markets remain compact, volatile markets naturally expand. The [i]scale factor[/i] setting provides additional manual control when needed.
[*][b]Visible-area rendering.[/b] Waves are built only for bars currently visible on screen using [i]chart.left_visible_bar_time[/i] and [i]chart.right_visible_bar_time[/i]. The loop range accounts for the offset of the last bar from the right edge — correctly handling situations when recent bars are outside the viewport after scrolling left. When scrolling or zooming, the structure recalculates intentionally to preserve local proportionality.
[*][b]Baseline positioning.[/b] The baseline can be placed manually via the [i]position[/i] setting: top, bottom or middle of the visible range. In [i]auto[/i] mode the indicator checks whether current price is in the upper or lower half of the visible range and positions the baseline on the opposite side — in most cases preventing overlap with candles without manual adjustment.
[*][b]Extreme delta detection.[/b] A bar is marked as extreme only when two conditions are met simultaneously: total volume exceeds a configured percentile of recent history (Lookback Window
- 500 bars by default), and absolute delta exceeds a configured percentage of total bar volume. This filtering removes low-volume noise, small meaningless imbalances, and high-volume but balanced bars. Only bars where both participation and asymmetry are genuinely exceptional are highlighted. Both thresholds are independently adjustable.
[/list]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]How to read it[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[list]
[*][b]Dominance.[/b] When buy waves consistently exceed sell waves — buyers are participating more aggressively. When sell waves dominate — sellers control the auction. The relationship becomes visible instantly without requiring footprint tables or numerical inspection.
[*][b]Delta as confirmation.[/b] Price rising with positive delta means real buying pressure is behind the move. Price rising while delta weakens or turns negative suggests passive absorption may be occurring — the move may lack genuine initiative participation.
[*][b]Extreme highlights.[/b] Fully opaque spikes mark bars where both participation and directional imbalance were exceptional. These bars are often structurally important and tend to stand out clearly even on dense charts — absorption, exhaustion, breakout moments.
[*][b]Info label.[/b] On the last bar a small label shows buy volume, sell volume, delta value and delta as a percentage of total volume — quick numerical context without opening a separate footprint panel.
[/list]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]Settings[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[list]
[*][b]side[/b] — one side or two sides visualization
[*][b]position[/b] — baseline placement: auto / top / bottom / middle
[*][b]shift[/b] — offset between baseline and chart edge
[*][b]scale factor[/b] — overall wave height multiplier
[*][b]Lookback Window[/b] — normalization and percentile range
[*][b]Delta % threshold[/b] — minimum imbalance percentage for extreme detection
[*][b]Volume Percentile %[/b] — minimum participation percentile for extreme detection
[*][b]show volume[/b] — toggle buy/sell volume waves
[*][b]show delta[/b] — toggle delta overlay and extreme highlights
[*][b]delta transparency[/b] — two inline values: opacity for regular delta and for extreme highlights separately
[*][b]show label[/b] — toggle information label on last bar
[/list]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]Notes[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[list]
[*][b]Footprint data required.[/b] The indicator uses request.footprint() available on TradingView Premium or higher. Availability also depends on broker and exchange feed support.
[*][b]Updates on scroll.[/b] Waves recalculate every time the visible area changes — intentionally. You always see volume structure scaled to what is currently on screen.
[/list]
[i]If you find it useful — a boost or comment is appreciated. Feedback and suggestions are always welcome.[/i]

## Source Code

````pine
//@version=6
indicator("Volume Waves (Buy / Sell / Δ) [footprint data]", "Vol Waves", overlay = true)

one     = input.string('two sides', options = ['one side', 'two sides']) == 'one side'
off     = input.float(0.1, 'shift', step = 0.1) / 100
pos     = input.string('auto', 'position', options = ['auto', 'top', 'bottom', 'middle'])
scl     = input.int(5, 'Scale factor')
len     = math.min(math.max(bar_index, 1), input.int(500, 'Lookback Window', minval = 100))
thresh  = input.int(40, 'Delta % threshold', step = 5)
plow    = input.int(50, 'Volume Percentile %', step = 5)
is_vol  = input.bool(true, 'show volume')
tr      = input.int(90, 'volume transparancy', active = is_vol)
is_dlt  = input.bool(true, 'show delta')
tr2     = input.int(75, 'delta transparancy', inline = 'd', active = is_dlt)
tr3     = input.int(25, '', inline = 'd', active = is_dlt)
is_lbl  = input.bool(true, 'show label')

const color z = #ffffff00
const color n = #787b866f
const color l = #00e676
const color p = #9c27b0
const int   h = 4950

type data
    float b
    float s
    float t
    float d

var float visL = na
var float visH = na
var data  dat  = data.new()

method vol(float _v, string _p = '.#') =>
    dgt = math.log10(math.abs(_v))
    switch
        dgt > 12 => str.tostring(_v / 1e12, "#" + _p + "  T")
        dgt > 9  => str.tostring(_v / 1e9,  "#" + _p + "  B")
        dgt > 6  => str.tostring(_v / 1e6,  "#" + _p + "  M")
        dgt > 3  => str.tostring(_v / 1e3,  "#" + _p + "  K")
        =>          str.tostring(_v, "#" +  "#" + _p)

method poly(chart.point[] _p, _b, _c, _t) =>
    if _p.size() > 0
        _p.unshift(chart.point.from_index(_p.first().index, _b))
        _p.push(   chart.point.from_index(_p. last().index, _b))
        (polyline.new(_p, closed = true, line_color = z, fill_color = color.new(_c, _t))[1]).delete()

ft = request.footprint(100)
if not na(ft)
    dat := data.new(ft.buy_volume(), ft.sell_volume(), ft.total_volume(), ft.delta())

volE    = dat.t >= ta.percentile_linear_interpolation(dat.t, len, plow)
highV   = ta.highest(dat.t, len)
volB    = dat.b / highV * 100 , max_bars_back(volB, h)
volS    = dat.s / highV * 100 , max_bars_back(volS, h)
atr     = ta.atr(200) / 100   , max_bars_back(atr,  h)
max_bars_back(time, h)        , max_bars_back(volE, h)

if time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
    visL := math.min(nz(visL, low),  low)
    visH := math.max(nz(visH, high), high)

if barstate.islast
    bar_ms = timeframe.in_seconds() * 1000
    vis_ar = int((chart.right_visible_bar_time - chart.left_visible_bar_time) / bar_ms)
    right  = int((time - chart.right_visible_bar_time) / bar_ms)
    ptsB   = array.new<chart.point>(), ptsS = array.new<chart.point>()
    posD   = array.new<chart.point>(), negD = array.new<chart.point>()
    posE   = array.new<chart.point>(), negE = array.new<chart.point>()

    base = switch pos
        'auto'   => close < math.avg(visH, visL) ? visH * (1 + off) : visL * (1 - off)
        'top'    => visH * (1 + off)
        'bottom' => visL * (1 - off)
        'middle' => math.avg(visH, visL)

    for i = math.min(vis_ar + right + 10, h) to 0
        if time[i] >= chart.left_visible_bar_time and time[i] <= chart.right_visible_bar_time
            idx     = bar_index - i
            b_h     = volB[i] * atr[i] * scl
            s_h     = volS[i] * atr[i] * scl
            d_val   = b_h - s_h
            neg_h   = one ? base - math.min(d_val, 0) : base + math.min(d_val, 0)
            extr    = math.abs(d_val) >= (b_h + s_h) * (thresh / 100) and volE[i]

            if is_dlt
                posD.push(chart.point.from_index(idx, base + math.max(d_val, 0)))
                negD.push(chart.point.from_index(idx, neg_h))
                posE.push(chart.point.from_index(idx, extr and d_val > 0 ? base + d_val : base))
                negE.push(chart.point.from_index(idx, extr and d_val < 0 ? neg_h        : base))
            if is_vol
                ptsB.push(chart.point.from_index(idx, base + (one ? b_h + s_h : b_h)))
                if not one
                    ptsS.push(chart.point.from_index(idx, base - s_h))

    if is_dlt
        posD.poly(base, l, tr2), negD.poly(base, p, tr2)
        posE.poly(base, l, tr3), negE.poly(base, p, tr3)
    if is_vol
        ptsB.poly(base, n, tr)
        if not one
            ptsS.poly(base, n, tr)
    if is_lbl
        (label.new(bar_index + 2, base, str.format('buy {0}\nsell {1}\nΔ {2} ({3, number, percent})',
        dat.b.vol(), dat.s.vol(), dat.d.vol(), dat.d / dat.t), color = z, textcolor = dat.d > 0
        ? l : p, style = 'llf', size = 16)[1]).delete()
````
