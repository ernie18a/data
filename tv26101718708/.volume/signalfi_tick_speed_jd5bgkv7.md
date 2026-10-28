# [SignalFI] Tick Speed

- url: https://www.tradingview.com/script/JD5bgKv7-SignalFI-Tick-Speed/
- type: indicator
- pine_id: PUB;5ed10542c01d4d56b9c040d913eff9d3
- version: 2.0

## Description

Tick Speed measures how fast TradingView's tick candles (1T, 10T, 100T and 1000T) are forming, how much volume they carry and which way that flow is pushing, and shows it on a regular time-based chart. You can watch the pace of the tape while trading from a 1-minute or 5-minute chart, without keeping four tick charts open.

It was built for liquid futures such as NQ and MNQ on 1m to 5m charts, and works on any symbol that has tick intervals on TradingView.


WHY TICK SPEED

A tick candle closes after a fixed number of trades, not a fixed amount of time. Its duration therefore tells you how busy the market is: when 100 trades print in 8 seconds instead of the usual 25, participation has surged. Time-based candles hide this, because every bar lasts the same time whether 50 trades printed or 5,000.

Tick Speed puts each tick scale next to its own recent normal, so you can see when activity accelerates, which scales it is happening on, and whether buyers or sellers are driving it.


HOW IT WORKS

Each scale is read from its own tick timeframe with request.security_lower_tf(). The 10T, 100T and 1000T readings come from the real tick candles TradingView builds; they are not 1T counts divided by 10, 100 or 1000.

For every chart bar and every scale, the script measures:

- s/candle: average seconds per tick candle over the last few closed candles (the "Candles" input). If the candle that is still forming has already taken longer than that average, its elapsed time is used instead, so a stall shows up immediately rather than after the candle closes. For 1T it is seconds per trade inside the chart bar.
- tick×: trades per second divided by its own moving baseline. 1.00 is normal pace and 2.00 is twice normal.
- vol×: contracts (volume) per second divided by its own baseline.
- size×: average contracts per trade divided by its own baseline. Above 1 means larger trades than usual; below 1 means small-lot churn.
- dir (price direction): the price efficiency of the recent tick candles, net move divided by total move, from -100% to +100%. For 1T it is the balance of upticks and downticks.
- Δvol (volume delta): from -100% to +100%.
  - On 1T, each trade is classified as buyer- or seller-initiated from the bid and ask: at or above the ask is a buy, at or below the bid is a sell, and trades in between are compared with the midpoint. When bid/ask is missing or the trade is exactly at the midpoint, the uptick/downtick rule is used instead.
  - On 10T, 100T and 1000T, it is the volume of up-moving candles minus the volume of down-moving candles, divided by total volume. This is close to true aggressor delta on 10T and coarser on 1000T.

Every "×" value has its own independent baseline (an EMA over the "Speed Baseline" number of chart bars), so each scale is always compared with its own normal.


SPEED AND DIRECTION BASIS

Two inputs choose what drives the ribbons, composite, bar colouring and alerts:

- Speed Basis:
  - Ticks = trade pace (tick×).
  - Volume = contract pace (vol×).
  - Blend (default) = the geometric mean of tick× and vol×. It reads 1.0 when both are normal and only runs high when trades and contracts are both running hot.
- Direction Basis:
  - Price = price direction (dir).
  - Volume delta (default) = Δvol.


WHAT YOU SEE

- Four ribbons, one per scale (1T at the bottom, 1000T at the top).
  - Colour shows direction: green for up, red for down, grey for neutral.
  - Opacity shows speed: faint at half of normal pace, solid at 2.5 times normal or more.
  - A "wave" of solid colour moving from 1T up through 1000T means a fast burst is turning into sustained flow.
- Tick Velocity histogram: a weighted average of direction × speed across the enabled scales, clamped to ±3 for display, with ±threshold lines. The default weights favour the slower scales (1T 0.1, 10T 0.2, 100T 0.3, 1000T 0.4), and speed is capped inside the composite so one spike cannot dominate it.
- Optional price bar colouring by Tick Velocity.
- Dashboard with one row per scale: Scale | s/candle | tick× | vol× | size× | Δvol or dir | new. "new" is the number of new tick candles (or trades, for 1T) in the current chart bar. The last row shows the Tick Velocity value and the active bases.
- Data Window: tick×, vol×, size×, dir and Δvol for every scale, plus s/candle and the unclamped velocity.


HOW TO READ IT

- Speed values above 1.5 on several scales at once, with the same direction, mean the market is moving with real participation behind it.
- Fast pace with neutral direction usually means two-sided churn or absorption rather than a trend.
- size× rising while tick× stays flat means fewer, larger trades are hitting the market.
- Slowing speed (values falling below 1) after a move shows participation drying up.
- Tick Speed is a context tool. It shows the pace and pressure of the tape; it does not generate trade entries on its own and should be combined with your own analysis and risk management.


ALERTS

- Tick Velocity Up / Down: the composite crosses above the upper threshold or below the lower threshold.
- Aligned Surge Up / Down: at least two scales have data, all of them point the same way, and each one's speed is above the "Surge ×norm" input.


INPUTS

- Tick Scales: turn each scale on or off, set its weight in the composite, and set how many closed candles it averages over.
- Volume: Speed Basis and Direction Basis.
- Calculation: Speed Baseline length (chart bars) and the speed cap used inside the composite.
- Signals: velocity threshold and surge level.
- Visuals: up, down and neutral colours, and price bar colouring.
- Dashboard: show or hide, position and text size.


REQUIREMENTS AND LIMITATIONS

- Your TradingView plan and the symbol must support tick-based intervals. Scales with no tick data show "no tick data" in the dashboard and are left out of the composite.
- Use it on a time-based chart. On a tick chart, the script shows a notice instead of values.
- Tick history is limited. 1T data runs out first (a few hundred 1-minute bars on MNQ), followed by 10T and 100T; 1000T usually covers the whole chart. Older bars therefore show fewer ribbons.
- Realtime tick data can arrive a few seconds late. The stall timer follows the newest tick received rather than the wall clock, so fast scales are not falsely marked as stalled.
- Values on the forming bar update until the bar closes.
- The script always requests standard candle data, so it gives the same readings on Heikin Ashi and other chart types as on regular candles.
- Volume delta on 10T, 100T and 1000T is based on candle direction, not an individual trade-by-trade split. Only 1T uses the bid/ask classification.
- Bid/ask classification depends on the data feed supplying bid and ask for each trade. Where it is not supplied, the uptick/downtick rule is used.

This script is for informational and educational purposes only and is not financial advice.

## Source Code

````pine
//@version=6
// [SignalFI] Tick Speed — how fast TradingView's tick candles (1T / 10T / 100T / 1000T) are
// forming, how much volume they carry, and in which direction, shown on a time-based chart.
//
// Each tick scale is read with request.security_lower_tf() on its own tick timeframe, so the
// 10T/100T/1000T rows measure the real tick candles, not 1T counts divided by N.
//   s/candle : average seconds per candle over the last M closed candles. If the forming candle
//              has already taken longer than that, its elapsed time is used instead (stall).
//   tick×    : ticks-per-second ÷ its own EMA baseline (1.0 = normal pace).
//   vol×     : contracts-per-second ÷ its own EMA baseline.
//   size×    : contracts per tick (average trade size) ÷ its own EMA baseline.
//   dir      : price efficiency of the last M candles, net move ÷ gross move, in [-1, 1].
//   Δvol     : volume delta in [-1, 1]. 10T/100T/1000T: contracts of up-moving candles minus
//              down-moving ones, ÷ total (exact at 10T, coarser at 1000T). 1T: aggressor split —
//              trades at/above the ask (or above mid) are buys, at/below the bid are sells,
//              uptick/downtick rule when bid/ask are missing or tied.
// Speed basis (Ticks / Volume / Blend = √(tick×·vol×)) and direction basis (Price / Volume
// delta) choose what drives the ribbons, composite, bar tint and alerts.
//
// Requests use a standard ticker built from prefix + ticker + session: on a Heikin Ashi (or
// other non-standard) chart, syminfo.tickerid would return HA-transformed tick data (1T
// closes came back at 0.75× price on an HA chart).
//
// Tick candles are keyed by their start time. security_lower_tf reports a candle in every
// chart bar it is still forming in, so the same candle can show up in several chart bars —
// the chart-side buffers de-duplicate by start time and keep the latest (final) volume. Each
// candle's move and duration are measured open-to-next-open (a forming candle's close is stale
// in earlier bars; its open never changes), which keeps history and realtime consistent.
//
// Realtime tick data can arrive up to ~12 s late (measured 0.7–11.7 s on MNQ1!). The stall
// clock therefore runs on the newest 1T tick time seen, not the wall clock, and only falls
// back to the wall clock when that tick is more than STALL_GRACE old.
//
// History depth is limited by TradingView's tick history and the intrabar cap: on MNQ1! 1m
// (2026-09-23) 1T reached ~300 bars back, 10T ~1,000, 100T ~14,000, 1000T the whole chart.
indicator('[SignalFI] Tick Speed', shorttitle = 'TickSpeed', overlay = false, precision = 2)

//              ╔════════════════════════════════╗              //
//              ║             INPUTS             ║              //
//              ╚════════════════════════════════╝              //

grpScale = 'Tick Scales'
// Each scale is forced off on tick charts (the dashboard shows a notice instead).
on1 = input.bool(true, '1T', group = grpScale, inline = 's1') and not timeframe.isticks
w1 = input.float(0.1, 'Weight', minval = 0, step = 0.05, group = grpScale, inline = 's1', tooltip = '1T has the shortest history (the intrabar cap is reached first). Its speed is ticks per second within the chart bar; its price direction is the uptick/downtick balance and its Δvol is the bid/ask aggressor split.')
on10 = input.bool(true, '10T', group = grpScale, inline = 's10') and not timeframe.isticks
w10 = input.float(0.2, 'Weight', minval = 0, step = 0.05, group = grpScale, inline = 's10')
m10 = input.int(5, 'Candles', minval = 1, maxval = 50, group = grpScale, inline = 's10')
on100 = input.bool(true, '100T', group = grpScale, inline = 's100') and not timeframe.isticks
w100 = input.float(0.3, 'Weight', minval = 0, step = 0.05, group = grpScale, inline = 's100')
m100 = input.int(5, 'Candles', minval = 1, maxval = 50, group = grpScale, inline = 's100')
on1k = input.bool(true, '1000T', group = grpScale, inline = 's1k') and not timeframe.isticks
w1k = input.float(0.4, 'Weight', minval = 0, step = 0.05, group = grpScale, inline = 's1k')
m1k = input.int(3, 'Candles', minval = 1, maxval = 50, group = grpScale, inline = 's1k', tooltip = 'Candles = how many closed tick candles the speed, volume and direction are averaged over. Weight = contribution to the composite Tick Velocity.')

grpVol = 'Volume'
speedBasis = input.string('Blend', 'Speed Basis', options = ['Ticks', 'Volume', 'Blend'], group = grpVol, tooltip = 'What drives ribbon opacity, the composite and the surge alert. Ticks = trade-print pace (tick×). Volume = contract pace (vol×). Blend = √(tick× · vol×): 1.0 when both are normal, high only when prints and contracts both run hot.')
dirBasis = input.string('Volume delta', 'Direction Basis', options = ['Price', 'Volume delta'], group = grpVol, tooltip = 'What drives ribbon hue, the composite sign and the surge alert. Price = price efficiency of the tick candles. Volume delta = contracts on up vs down moves (1T: bid/ask aggressor split).')

grpCalc = 'Calculation'
baseLen = input.int(50, 'Speed Baseline (bars)', minval = 2, group = grpCalc, tooltip = 'EMA length, in chart bars, of each scale\'s tick rate, volume rate and trade size. ×norm = current value ÷ this baseline, so 1.0 is normal and 2.0 is twice normal.')
relCap = input.float(4.0, 'Speed Cap in Composite', minval = 1, step = 0.5, group = grpCalc, tooltip = 'Caps the speed ×norm inside the composite so one burst cannot dominate it.')

grpSig = 'Signals'
velThr = input.float(0.75, 'Velocity Threshold', minval = 0.05, step = 0.05, group = grpSig, tooltip = 'Composite Tick Velocity = weighted average of direction × speed (per the bases above). ±threshold lines and alerts.')
surgeRel = input.float(1.5, 'Surge ×norm', minval = 1, step = 0.1, group = grpSig, tooltip = 'Aligned-surge alert: every enabled scale with data points the same way with speed ×norm above this (at least two scales).')

grpVis = 'Visuals'
upCol = input.color(#00ffaa, 'Up', group = grpVis, inline = 'col')
dnCol = input.color(#ff0000, 'Down', group = grpVis, inline = 'col')
neuCol = input.color(#888888, 'Neutral', group = grpVis, inline = 'col')
tintBars = input.bool(true, 'Tint Price Bars by Composite', group = grpVis)

grpDash = 'Dashboard'
showDash = input.bool(true, 'Show Dashboard', group = grpDash)
dashPos = input.string('Top Right', 'Position', options = ['Top Left', 'Top Center', 'Top Right', 'Middle Left', 'Middle Center', 'Middle Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], group = grpDash)
dashSizeStr = input.string('Small', 'Text Size', options = ['Tiny', 'Small', 'Normal'], group = grpDash)

//              ╔════════════════════════════════╗              //
//              ║          CALCULATIONS          ║              //
//              ╚════════════════════════════════╝              //

BUF_CAP = 64
STALL_GRACE = 15000 // ms; covers the observed realtime tick-data delay
DIR_DEADBAND = 0.05 // |dir| at or below this reads as neutral (label, colour, surge alert)

// Standard-candle ticker with the chart's session (see header: Heikin Ashi charts).
tid = ticker.new(syminfo.prefix, syminfo.ticker, syminfo.session)

// Wall-clock end of the measured window: the bar close on history, "now" on the live bar.
f_now() =>
    barstate.isrealtime ? math.min(timenow, time_close) : time_close

// Value ÷ its own EMA baseline (EMA that skips na). The previous baseline is used, so a
// spike is not diluted by itself. First sample reads as 1.0. Call it at global scope once per
// series: each written call owns one baseline.
f_rel(float x) =>
    var float base = na
    float rel = na
    if not na(x)
        rel := na(base) or base <= 0 ? 1.0 : x / base
        float alpha = 2.0 / (baseLen + 1)
        base := na(base) ? x : base + alpha * (x - base)
    rel

// One N-tick scale. Buffers hold each tick candle's start time, open and volume, oldest first,
// newest = the forming candle (its volume is overwritten each time it is reported again).
// Window = the last m closed candles. nowT = data clock (see header). Returns
// [secsPerCandle, ticksPerSec, contractsPerSec, contractsPerTick, priceDir, volDelta, added].
f_scale(simple string tf, simple int n, simple int m, array<int> bt, array<float> bo, array<float> bv, int nowT) =>
    [ta_, oa_, va_] = request.security_lower_tf(tid, tf, [time, open, volume], ignore_invalid_timeframe = true)
    int sz = na(ta_) ? 0 : array.size(ta_)
    int added = 0
    if sz > 0
        for j = 0 to sz - 1
            int tj = array.get(ta_, j)
            int k0 = array.size(bt)
            if k0 == 0 or tj > array.last(bt)
                array.push(bt, tj)
                array.push(bo, array.get(oa_, j))
                array.push(bv, nz(array.get(va_, j)))
                added += 1
                if array.size(bt) > BUF_CAP
                    array.shift(bt)
                    array.shift(bo)
                    array.shift(bv)
            else if tj == array.last(bt)
                array.set(bv, k0 - 1, nz(array.get(va_, j)))
    float secs = na
    float dir = na
    float vRate = na
    float perTick = na
    float dVol = na
    int k = array.size(bt)
    if k > m
        int tNew = array.get(bt, k - 1)
        float span = (tNew - array.get(bt, k - 1 - m)) / 1000.0 / m
        float formingSec = (nowT - tNew) / 1000.0
        secs := math.max(span, formingSec)
        float net = array.get(bo, k - 1) - array.get(bo, k - 1 - m)
        float gross = 0.0
        float vSum = 0.0
        float vNet = 0.0
        // candle i-1: move = open[i] - open[i-1], volume = bv[i-1] (closed, final)
        for i = k - m to k - 1
            float mv = array.get(bo, i) - array.get(bo, i - 1)
            float vc = array.get(bv, i - 1)
            gross += math.abs(mv)
            vSum += vc
            vNet += math.sign(mv) * vc
        dir := gross > 0 ? net / gross : 0.0
        vRate := vSum / m / secs
        perTick := vSum / (m * n)
        dVol := vSum > 0 ? vNet / vSum : 0.0
    [secs, na(secs) ? na : n / secs, vRate, perTick, dir, dVol, added]

// 1T: every element is one trade. Speed = ticks per second in the chart bar; price direction =
// uptick/downtick balance (zero-change ticks ignored); Δvol = aggressor split (TradingView ta
// library rule), falling back to the tick rule. Tick-rule state is carried across chart bars.
// Also returns the data clock: newest tick time seen, or the wall clock when that tick is
// older than STALL_GRACE (or there is no 1T history).
f_ticks() =>
    [tArr, cArr, vArr, bArr, aArr] = request.security_lower_tf(tid, '1T', [time, close, volume, bid, ask], ignore_invalid_timeframe = true)
    int sz = na(tArr) ? 0 : array.size(tArr)
    var float lastPx = na
    var bool lastBuy = true
    var int lastTickT = na
    float secs = na
    float dir = na
    float vRate = na
    float perTick = na
    float dVol = na
    if sz > 0
        lastTickT := array.last(tArr)
    int wall = f_now()
    int nowT = na(lastTickT) ? wall : math.max(lastTickT, wall - STALL_GRACE)
    if sz > 0
        int ups = 0
        int dns = 0
        float buyV = 0.0
        float sellV = 0.0
        for i = 0 to sz - 1
            float px = array.get(cArr, i)
            float b = array.get(bArr, i)
            float a = array.get(aArr, i)
            bool tickUp = not na(lastPx) and px > lastPx
            bool tickDn = not na(lastPx) and px < lastPx
            if tickUp
                ups += 1
            else if tickDn
                dns += 1
            bool isBuy = tickUp ? true : tickDn ? false : lastBuy
            if not na(b) and not na(a) and a > b
                float mid = (a + b) / 2
                isBuy := px >= a ? true : px <= b ? false : px > mid ? true : px < mid ? false : isBuy
            if isBuy
                buyV += nz(array.get(vArr, i))
            else
                sellV += nz(array.get(vArr, i))
            lastBuy := isBuy
            lastPx := px
        float elapsed = math.max(nowT - time, 1000) / 1000.0
        float vTot = buyV + sellV
        secs := elapsed / sz
        dir := ups + dns > 0 ? (ups - dns) / (ups + dns) : 0.0
        vRate := vTot / elapsed
        perTick := vTot / sz
        dVol := vTot > 0 ? (buyV - sellV) / vTot : 0.0
    [secs, na(secs) ? na : 1.0 / secs, vRate, perTick, dir, dVol, sz, nowT]

var array<int> bt10 = array.new<int>()
var array<float> bo10 = array.new<float>()
var array<float> bv10 = array.new<float>()
var array<int> bt100 = array.new<int>()
var array<float> bo100 = array.new<float>()
var array<float> bv100 = array.new<float>()
var array<int> bt1k = array.new<int>()
var array<float> bo1k = array.new<float>()
var array<float> bv1k = array.new<float>()

[s1, tr1, vr1, pt1, pd1, vd1, n1, nowT] = f_ticks()
[s10, tr10, vr10, pt10, pd10, vd10, n10] = f_scale('10T', 10, m10, bt10, bo10, bv10, nowT)
[s100, tr100, vr100, pt100, pd100, vd100, n100] = f_scale('100T', 100, m100, bt100, bo100, bv100, nowT)
[s1k, tr1k, vr1k, pt1k, pd1k, vd1k, n1k] = f_scale('1000T', 1000, m1k, bt1k, bo1k, bv1k, nowT)

// ×norm: one written f_rel call per series → one independent EMA baseline each.
tx1 = f_rel(tr1)
tx10 = f_rel(tr10)
tx100 = f_rel(tr100)
tx1k = f_rel(tr1k)
vx1 = f_rel(vr1)
vx10 = f_rel(vr10)
vx100 = f_rel(vr100)
vx1k = f_rel(vr1k)
zx1 = f_rel(pt1)
zx10 = f_rel(pt10)
zx100 = f_rel(pt100)
zx1k = f_rel(pt1k)

// Selected speed and direction per scale (inputs above).
f_spd(float tx, float vx) =>
    switch speedBasis
        'Ticks' => tx
        'Volume' => vx
        => na(tx) or na(vx) ? na : math.sqrt(tx * vx)

f_dir(float pd, float vd) =>
    dirBasis == 'Price' ? pd : vd

sp1 = f_spd(tx1, vx1)
sp10 = f_spd(tx10, vx10)
sp100 = f_spd(tx100, vx100)
sp1k = f_spd(tx1k, vx1k)
d1 = f_dir(pd1, vd1)
d10 = f_dir(pd10, vd10)
d100 = f_dir(pd100, vd100)
d1k = f_dir(pd1k, vd1k)

// Composite Tick Velocity: weighted average of dir × capped speed over scales that have data.
f_term(bool on, float d, float r, float w) =>
    bool ok = on and not na(d) and not na(r)
    [ok ? w * d * math.min(r, relCap) : 0.0, ok ? w : 0.0]

[c1, q1] = f_term(on1, d1, sp1, w1)
[c10, q10] = f_term(on10, d10, sp10, w10)
[c100, q100] = f_term(on100, d100, sp100, w100)
[c1k, q1k] = f_term(on1k, d1k, sp1k, w1k)
wSum = q1 + q10 + q100 + q1k
vel = wSum > 0 ? (c1 + c10 + c100 + c1k) / wSum : na

//              ╔════════════════════════════════╗              //
//              ║            VISUALS             ║              //
//              ╚════════════════════════════════╝              //

// Hue = direction (neutral → up/down), opacity = speed (0.5× faint … 2.5× solid).
f_heat(bool on, float d, float r) =>
    color c = na
    if on and not na(d) and not na(r)
        color hue = d >= 0 ? color.from_gradient(d, 0, 1, neuCol, upCol) : color.from_gradient(d, -1, 0, dnCol, neuCol)
        c := color.new(hue, 85 - 70 * math.max(0, math.min(1, (r - 0.5) / 2.0)))
    c

f_velCol(float v) =>
    na(v) ? na : v >= 0 ? color.from_gradient(v, 0, velThr, neuCol, upCol) : color.from_gradient(v, -velThr, 0, dnCol, neuCol)

// Four ribbons stacked above the velocity histogram: 1T at 4 … 1000T at 7.
HALF = 0.42
p1a = plot(4 + HALF, display = display.none, editable = false)
p1b = plot(4 - HALF, display = display.none, editable = false)
p10a = plot(5 + HALF, display = display.none, editable = false)
p10b = plot(5 - HALF, display = display.none, editable = false)
p100a = plot(6 + HALF, display = display.none, editable = false)
p100b = plot(6 - HALF, display = display.none, editable = false)
p1ka = plot(7 + HALF, display = display.none, editable = false)
p1kb = plot(7 - HALF, display = display.none, editable = false)
fill(p1a, p1b, f_heat(on1, d1, sp1), title = '1T Ribbon')
fill(p10a, p10b, f_heat(on10, d10, sp10), title = '10T Ribbon')
fill(p100a, p100b, f_heat(on100, d100, sp100), title = '100T Ribbon')
fill(p1ka, p1kb, f_heat(on1k, d1k, sp1k), title = '1000T Ribbon')

plot(na(vel) ? na : math.max(-3, math.min(3, vel)), 'Tick Velocity', color = f_velCol(vel), style = plot.style_columns)
hline(0, 'Zero', color = color.new(neuCol, 50), linestyle = hline.style_solid)
hline(velThr, 'Upper Threshold', color = color.new(upCol, 50))
hline(-velThr, 'Lower Threshold', color = color.new(dnCol, 50))

barcolor(tintBars and not na(vel) ? f_velCol(vel) : na, title = 'Tick Velocity Bar Tint')

// Data-window values (unclamped).
plot(vel, 'Velocity (raw)', display = display.data_window)
plot(tx1, '1T tick×', display = display.data_window)
plot(vx1, '1T vol×', display = display.data_window)
plot(zx1, '1T size×', display = display.data_window)
plot(pd1, '1T dir', display = display.data_window)
plot(vd1, '1T Δvol', display = display.data_window)
plot(tx10, '10T tick×', display = display.data_window)
plot(vx10, '10T vol×', display = display.data_window)
plot(zx10, '10T size×', display = display.data_window)
plot(pd10, '10T dir', display = display.data_window)
plot(vd10, '10T Δvol', display = display.data_window)
plot(tx100, '100T tick×', display = display.data_window)
plot(vx100, '100T vol×', display = display.data_window)
plot(zx100, '100T size×', display = display.data_window)
plot(pd100, '100T dir', display = display.data_window)
plot(vd100, '100T Δvol', display = display.data_window)
plot(tx1k, '1000T tick×', display = display.data_window)
plot(vx1k, '1000T vol×', display = display.data_window)
plot(zx1k, '1000T size×', display = display.data_window)
plot(pd1k, '1000T dir', display = display.data_window)
plot(vd1k, '1000T Δvol', display = display.data_window)
plot(s10, '10T s/candle', display = display.data_window)
plot(s100, '100T s/candle', display = display.data_window)
plot(s1k, '1000T s/candle', display = display.data_window)

//              ╔════════════════════════════════╗              //
//              ║           DASHBOARD            ║              //
//              ╚════════════════════════════════╝              //

f_tablePos(string posStr) =>
    switch posStr
        'Top Left' => position.top_left
        'Top Center' => position.top_center
        'Top Right' => position.top_right
        'Middle Left' => position.middle_left
        'Middle Center' => position.middle_center
        'Middle Right' => position.middle_right
        'Bottom Left' => position.bottom_left
        'Bottom Center' => position.bottom_center
        => position.bottom_right

dashSize = dashSizeStr == 'Tiny' ? size.tiny : dashSizeStr == 'Normal' ? size.normal : size.small

f_fmtSecs(float s) =>
    na(s) ? '—' : s < 10 ? str.tostring(s, '0.00') : str.tostring(s, '0.0')

f_fmtX(float x) =>
    na(x) ? '—' : str.tostring(x, '0.00')

f_dirTxt(float d) =>
    na(d) ? '—' : (d > DIR_DEADBAND ? '▲ ' : d < -DIR_DEADBAND ? '▼ ' : '• ') + str.tostring(math.abs(d) * 100, '0') + '%'

DASH_COLS = 7
var table dash = table.new(f_tablePos(dashPos), DASH_COLS, 6, bgcolor = color.new(color.black, 25), border_width = 1, border_color = color.new(neuCol, 70))

// Columns: scale | s/candle | tick× | vol× | size× | selected direction (heat = ribbon colour) | new.
f_row(int row, string lbl, bool on, float s, float tx, float vx, float zx, float d, float sp, int cnt) =>
    table.cell(dash, 0, row, lbl, text_color = chart.fg_color, text_size = dashSize, text_halign = text.align_left)
    if not on or na(d) or na(sp)
        table.cell(dash, 1, row, not on ? 'off' : 'no tick data', text_color = neuCol, text_size = dashSize)
        for _c = 2 to DASH_COLS - 1
            table.cell(dash, _c, row, '', text_size = dashSize)
    else
        table.cell(dash, 1, row, f_fmtSecs(s), text_color = chart.fg_color, text_size = dashSize)
        table.cell(dash, 2, row, f_fmtX(tx), text_color = chart.fg_color, text_size = dashSize)
        table.cell(dash, 3, row, f_fmtX(vx), text_color = chart.fg_color, text_size = dashSize)
        table.cell(dash, 4, row, f_fmtX(zx), text_color = chart.fg_color, text_size = dashSize)
        table.cell(dash, 5, row, f_dirTxt(d), text_color = d > DIR_DEADBAND ? upCol : d < -DIR_DEADBAND ? dnCol : neuCol, bgcolor = f_heat(true, d, sp), text_size = dashSize)
        table.cell(dash, 6, row, str.tostring(cnt), text_color = neuCol, text_size = dashSize)

if barstate.islast and showDash
    table.clear(dash, 0, 0, DASH_COLS - 1, 5)
    if timeframe.isticks
        table.cell(dash, 0, 0, 'Tick Speed: use a time-based chart (1m–5m)', text_color = neuCol, text_size = dashSize)
    else
        string dirHdr = dirBasis == 'Price' ? 'dir' : 'Δvol'
        for [_c, _h] in array.from('Scale', 's/candle', 'tick×', 'vol×', 'size×', dirHdr, 'new')
            table.cell(dash, _c, 0, _h, text_color = neuCol, text_size = dashSize)
        f_row(1, '1000T', on1k, s1k, tx1k, vx1k, zx1k, d1k, sp1k, n1k)
        f_row(2, '100T', on100, s100, tx100, vx100, zx100, d100, sp100, n100)
        f_row(3, '10T', on10, s10, tx10, vx10, zx10, d10, sp10, n10)
        f_row(4, '1T', on1, s1, tx1, vx1, zx1, d1, sp1, n1)
        table.cell(dash, 0, 5, 'Velocity', text_color = chart.fg_color, text_size = dashSize, text_halign = text.align_left)
        table.cell(dash, 1, 5, (na(vel) ? '—' : str.tostring(vel, '+0.00;-0.00')) + '   (' + speedBasis + ' · ' + dirHdr + ')', text_color = na(vel) ? neuCol : f_velCol(vel), text_size = dashSize)
        table.merge_cells(dash, 1, 5, DASH_COLS - 1, 5)

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //
//                                                              //
// +1 when a scale with data agrees (direction sgn and speed above surge), -100 when it
// disagrees, 0 when it is off or has no data. Sum >= 2 means at least two scales, all agreeing.
f_agree(bool on, float d, float r, int sgn) =>
    on and not na(d) and not na(r) ? (d * sgn > DIR_DEADBAND and r > surgeRel ? 1 : -100) : 0

surgeUp = f_agree(on1, d1, sp1, 1) + f_agree(on10, d10, sp10, 1) + f_agree(on100, d100, sp100, 1) + f_agree(on1k, d1k, sp1k, 1) >= 2
surgeDn = f_agree(on1, d1, sp1, -1) + f_agree(on10, d10, sp10, -1) + f_agree(on100, d100, sp100, -1) + f_agree(on1k, d1k, sp1k, -1) >= 2

alertcondition(ta.crossover(vel, velThr), 'Tick Velocity Up', 'Tick Speed: composite velocity crossed above the upper threshold on {{ticker}}')
alertcondition(ta.crossunder(vel, -velThr), 'Tick Velocity Down', 'Tick Speed: composite velocity crossed below the lower threshold on {{ticker}}')
alertcondition(surgeUp and not surgeUp[1], 'Aligned Surge Up', 'Tick Speed: all tick scales surging UP on {{ticker}}')
alertcondition(surgeDn and not surgeDn[1], 'Aligned Surge Down', 'Tick Speed: all tick scales surging DOWN on {{ticker}}')
````
