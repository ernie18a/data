# Regression Flux Candles [JOAT]

- url: https://www.tradingview.com/script/GGcRxnSo-Regression-Flux-Candles-JOAT/
- type: indicator
- pine_id: PUB;9a88b00c324e46da97374bc5fc93646d
- version: 1.0

## Description

[b]Regression Flux Candles [JOAT][/b]

[b]Overview[/b]

Regression Flux Candles renders a parallel candle series on top of price using linear regression applied independently to each of the four OHLC components. The result is a noise-filtered "flux candle" — a linearised representation of current price action that removes the erratic intrabar variation of raw candles and reveals the underlying trend direction with far greater clarity. A signal line (SMA of regression close) produces crossover buy/sell signals. Pivot-anchored support/resistance zones mark structural confluence areas. A six-timeframe MTF trend table provides session bias context.

[image]https://www.tradingview.com/x/Zpg73uZU/[/image]

[b]The Linear Regression Candle Concept[/b]

Standard Japanese candlesticks display the raw open, high, low, and close of each bar — capturing every tick-driven fluctuation including news spikes, stop hunts, and market-maker manipulation. Linear regression candles replace each OHLC component with the endpoint of a linear regression line fitted over the last N bars:

- LR Open = ta.linreg(open, length, 0)
- LR High = ta.linreg(high, length, 0)
- LR Low = ta.linreg(low, length, 0)
- LR Close = ta.linreg(close, length, 0)

The regression fits a straight line through the last N values of each component and returns the value of that line at the current bar. The resulting candle series is significantly smoother than raw price and acts like a weighted moving average of price structure without introducing the directional lag of traditional MAs. Bullish flux candles (LR close >= LR open) render in teal; bearish in purple.

[b]Signal Line and Crossover Logic[/b]

A simple moving average of the LR close (default 7-bar SMA) acts as a signal line. When the LR close crosses above the signal line, a potential buy signal is generated. When it crosses below, a potential sell signal is generated. Crossovers are filtered by:

- [b]Volume filter:[/b] Volume must exceed the 20-bar volume SMA (configurable). This ensures signals occur during genuine participation, not thin-market noise.
- [b]RSI filter:[/b] Buy signals are blocked when RSI(14) >= 70 (overbought); sell signals are blocked when RSI(14) <= 30 (oversold). This prevents buying into extended moves and selling into oversold conditions.
- [b]Warmup gate:[/b] All signals are suppressed until max(LR_length * 3, EMA_length + 5) bars have elapsed. This prevents the statistical noise of early LR calculations from generating false signals.
- [b]Confirmed-bar gate:[/b] Signals only fire on barstate.isconfirmed — the final tick of a closed bar — preventing any repainting.

[b]Trend EMA[/b]

A 200-period EMA (configurable length) is plotted as a gold line representing the macro trend bias. Position of price relative to the 200 EMA serves as a context filter that traders can apply manually: long signals above the EMA are higher quality, short signals below it are higher quality.

[b]Pivot S/R Zones[/b]

Swing pivot highs and lows (configurable left/right bars) generate semi-transparent S/R boxes:
- Resistance zones (from pivot highs): drawn in the bear colour with 89% transparency
- Support zones (from pivot lows): drawn in the bull colour with 89% transparency

Each zone extends forward by a configurable width in bars (default 40) from the pivot bar, or can be extended infinitely to the right. A maximum of 6 zones (configurable) are maintained; older zones are deleted as new ones form.

[b]Daily Signal Counter[/b]

The dashboard tracks how many buy and sell signals have fired on the current trading day, resetting at each new daily session (detected via ta.change(time("D"))). This provides a quick intraday reference for signal frequency — useful for understanding whether a session is particularly active or quiet.

[b]Multi-Timeframe Trend Table[/b]

Six independently configurable timeframes are assessed using the same linear regression logic: LR close >= LR open on each HTF = bullish; below = bearish. Each cell displays BULL or BEAR in its directional colour. An alignment counter shows how many of the six timeframes agree with the current LR direction. 5+ aligned = strong directional bias (teal); 1 or fewer = strong counter-trend warning (red); middle values show gold.

[b]Inputs Reference[/b]

[b]Regression Engine[/b]
- LR Length (11) — lookback for all four linear regression calculations
- Signal SMA Length (7) — SMA applied to LR close for crossover signal line
- Trend EMA Length (200) — macro bias reference line

[b]Filters & Signals[/b]
- Volume Filter on Signals — require volume > volume SMA
- Volume SMA Length (20)
- RSI Filter on Signals — block overbought/oversold crossovers
- RSI Length (14)

[b]S/R Zones[/b]
- Pivot Left/Right Bars (15/10) — pivot detection sensitivity
- Show S/R Zones
- Extend Zones to Right — infinite extension toggle
- Zone Width (40 bars) — forward extension length when not extending to right
- Max Zones to Show (6)

[b]MTF Dashboard[/b]
- Show MTF Table
- TF 1–6 — six configurable timeframes (default: 1, 5, 15, 60, 240, D)

[b]Visual[/b]
- Bull / Bear Candle Color — OHLC candle colours for flux candles
- Signal Line Color — signal SMA line colour
- EMA Color — trend EMA line colour
- Show Dashboard

[b]How to Use[/b]

1. Apply to any liquid market. Use LR length of 9–15 for intraday charts; 20–30 for swing trading.
2. Watch for flux candle colour transitions: a sustained sequence of teal candles above the signal line confirms an uptrend; purple candles below confirm a downtrend.
3. BUY labels appear below the bar when LR close crosses above the signal line with volume and RSI conditions met. SELL labels appear above the bar on crossunders.
4. Prefer signals where the flux candle direction (teal/purple) aligns with the EMA bias AND the MTF table shows 4+ timeframes in agreement.
5. S/R zones from prior pivots serve as target levels and potential reversal points — align entries near these zones for improved risk/reward.

[b]Non-Repainting Design[/b]

All signals require barstate.isconfirmed. MTF data uses lookahead_off. LR calculations use only confirmed historical bars (offset 0 is the current bar's regression endpoint based on past data). Signal labels never move after being stamped on a closed bar.

[b]Limitations[/b]

- Linear regression candles reduce volatility information. In sharp, impulsive markets, the flux candle series will understate the actual price range. Raw candles should be viewed alongside the indicator for context.
- Short LR lengths (< 7) make the flux candles nearly identical to raw candles; very long lengths (> 30) introduce significant lag into the signal line crossovers.
- The volume and RSI filters may suppress signals during thin trading hours on forex pairs (e.g., Asian session on EUR/USD pairs). Disabling filters during these sessions is a valid adjustment.
- S/R zones are drawn from the pivot confirmation bar, not the pivot bar itself (due to the right-bar confirmation delay). Zone left edges are placed correctly but appear N bars after the actual pivot.

[b]Disclaimer[/b]

This indicator is for educational and informational purposes only. Linear regression candles and crossover signals are technical analysis tools and do not predict future price movement. Always use proper risk management and conduct your own analysis.

Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Regression Flux Candles [JOAT]", shorttitle="RFC [JOAT]", overlay=true,
          max_boxes_count=200, max_lines_count=100, max_labels_count=100)
// ─── INPUTS ──────────────────────────────────────────────────────────
var GRP_L  = "Regression Engine"
var GRP_F  = "Filters & Signals"
var GRP_SR = "S/R Zones"
var GRP_M  = "MTF Dashboard"
var GRP_V  = "Visual"

i_lrLen     = input.int   (11,   "LR Length",               group=GRP_L, minval=3, maxval=100)
i_smLen     = input.int   (7,    "Signal SMA Length",        group=GRP_L, minval=2, maxval=50)
i_emaLen    = input.int   (200,  "Trend EMA Length",         group=GRP_L, minval=20)

i_volFilt   = input.bool  (true, "Volume Filter on Signals", group=GRP_F)
i_volLen    = input.int   (20,   "Volume SMA Length",        group=GRP_F, minval=5)
i_rsiFilt   = input.bool  (true, "RSI Filter on Signals",    group=GRP_F)
i_rsiLen    = input.int   (14,   "RSI Length",               group=GRP_F, minval=2)

i_pvLeft    = input.int   (15,   "Pivot Left Bars",          group=GRP_SR, minval=3)
i_pvRight   = input.int   (10,   "Pivot Right Bars",         group=GRP_SR, minval=3)
i_showSR    = input.bool  (true, "Show S/R Zones",           group=GRP_SR)
i_srExtend  = input.bool  (false,"Extend Zones to Right",    group=GRP_SR)
i_srWidth   = input.int   (40,   "Zone Width (bars)",        group=GRP_SR, minval=5)
i_maxSR     = input.int   (6,    "Max Zones to Show",        group=GRP_SR, minval=1, maxval=20)

i_showMTF   = input.bool  (true, "Show MTF Table",           group=GRP_M)
i_tf1       = input.string("1",  "TF 1",                     group=GRP_M)
i_tf2       = input.string("5",  "TF 2",                     group=GRP_M)
i_tf3       = input.string("15", "TF 3",                     group=GRP_M)
i_tf4       = input.string("60", "TF 4",                     group=GRP_M)
i_tf5       = input.string("240","TF 5",                     group=GRP_M)
i_tf6       = input.string("D",  "TF 6",                     group=GRP_M)

i_upColor   = input.color (color.rgb(0, 245, 212), "Bull Candle Color", group=GRP_V)
i_dnColor   = input.color (color.rgb(155, 89, 182),"Bear Candle Color", group=GRP_V)
i_sigColor  = input.color (color.white,            "Signal Line Color", group=GRP_V)
i_emaColor  = input.color (color.rgb(255, 215, 0), "EMA Color",         group=GRP_V)
i_showDash  = input.bool  (true, "Show Dashboard",            group=GRP_V)

// ─── PALETTE ─────────────────────────────────────────────────────────
_isDark  = color.r(chart.bg_color) < 128
C_BULL   = i_upColor
C_BEAR   = i_dnColor
C_GOLD   = color.rgb(255, 215, 0)
C_TEAL   = color.rgb(0, 220, 190)
C_SLATE  = color.rgb(96, 112, 128)
C_PANEL  = _isDark ? color.new(color.black, 80) : color.new(color.white, 75)
C_TXT    = _isDark ? color.white : color.black

// ─── CORE CALCULATIONS ───────────────────────────────────────────────
lr_open  = ta.linreg(open,  i_lrLen, 0)
lr_high  = ta.linreg(high,  i_lrLen, 0)
lr_low   = ta.linreg(low,   i_lrLen, 0)
lr_close = ta.linreg(close, i_lrLen, 0)

signalLine = ta.sma(lr_close, i_smLen)
ema200     = ta.ema(close, i_emaLen)
rsiVal     = ta.rsi(close, i_rsiLen)
volSma     = ta.sma(volume, i_volLen)

isUp       = lr_close >= lr_open
candleClr  = isUp ? C_BULL : C_BEAR

WARMUP   = math.max(i_lrLen * 3, i_emaLen + 5)
isReady  = bar_index >= WARMUP

// ─── BUY / SELL SIGNALS ──────────────────────────────────────────────
rawBuy  = ta.crossover (lr_close, signalLine)
rawSell = ta.crossunder(lr_close, signalLine)

volOk    = not i_volFilt or volume > volSma
rsiBuyOk = not i_rsiFilt or rsiVal < 70.0
rsiSelOk = not i_rsiFilt or rsiVal > 30.0

buySig  = rawBuy  and volOk and rsiBuyOk and isReady and barstate.isconfirmed
sellSig = rawSell and volOk and rsiSelOk and isReady and barstate.isconfirmed

// ─── PIVOT S/R ZONES ─────────────────────────────────────────────────
ph = ta.pivothigh(high, i_pvLeft, i_pvRight)
pl = ta.pivotlow (low,  i_pvLeft, i_pvRight)

var array<box> resBxs = array.new<box>()
var array<box> supBxs = array.new<box>()

if i_showSR and not na(ph)
    pvBar  = bar_index - i_pvRight
    rRight = i_srExtend ? bar_index : pvBar + i_srWidth
    ext    = i_srExtend ? extend.right : extend.none
    bx = box.new(pvBar, high[i_pvRight], rRight, low[i_pvRight],
         bgcolor=color.new(C_BEAR, 89), border_color=color.new(C_BEAR, 65),
         border_width=1, extend=ext, xloc=xloc.bar_index)
    array.push(resBxs, bx)
    if array.size(resBxs) > i_maxSR
        box.delete(array.shift(resBxs))

if i_showSR and not na(pl)
    pvBar  = bar_index - i_pvRight
    rRight = i_srExtend ? bar_index : pvBar + i_srWidth
    ext    = i_srExtend ? extend.right : extend.none
    bx = box.new(pvBar, high[i_pvRight], rRight, low[i_pvRight],
         bgcolor=color.new(C_BULL, 89), border_color=color.new(C_BULL, 65),
         border_width=1, extend=ext, xloc=xloc.bar_index)
    array.push(supBxs, bx)
    if array.size(supBxs) > i_maxSR
        box.delete(array.shift(supBxs))

// ─── DAILY SIGNAL COUNTER ────────────────────────────────────────────
var int dailyBuys  = 0
var int dailySells = 0

if ta.change(time("D")) != 0
    dailyBuys  := 0
    dailySells := 0

if buySig
    dailyBuys  += 1
if sellSig
    dailySells += 1

// ─── PLOTS ───────────────────────────────────────────────────────────
plotcandle(lr_open, lr_high, lr_low, lr_close,
     title="LR Candles", color=candleClr, wickcolor=candleClr,
     bordercolor=candleClr)

plot(signalLine, "Signal Line",  color=i_sigColor, linewidth=1)
plot(ema200,     "Trend EMA",    color=i_emaColor, linewidth=2)

plotshape(buySig,  "Buy Signal",  style=shape.labelup,
     location=location.belowbar, color=C_BULL, size=size.small,
     text="BUY", textcolor=color.new(color.black, 20))
plotshape(sellSig, "Sell Signal", style=shape.labeldown,
     location=location.abovebar, color=C_BEAR, size=size.small,
     text="SELL", textcolor=color.white)

// ─── MTF TREND DATA ──────────────────────────────────────────────────
f_mtfTrend(simple string tf) =>
    [lrO, lrC] = request.security(syminfo.tickerid, tf,
         [ta.linreg(open, i_lrLen, 0), ta.linreg(close, i_lrLen, 0)],
         lookahead=barmerge.lookahead_off)
    lrC >= lrO ? 1 : -1

t1 = f_mtfTrend(i_tf1)
t2 = f_mtfTrend(i_tf2)
t3 = f_mtfTrend(i_tf3)
t4 = f_mtfTrend(i_tf4)
t5 = f_mtfTrend(i_tf5)
t6 = f_mtfTrend(i_tf6)

bullAligned = (t1==1 ? 1:0) + (t2==1 ? 1:0) + (t3==1 ? 1:0) + (t4==1 ? 1:0) + (t5==1 ? 1:0) + (t6==1 ? 1:0)

// ─── ALERTS ──────────────────────────────────────────────────────────
alertcondition(buySig,  "RFC Buy Signal [JOAT]",
     "Regression Flux Candles: LR bullish crossover — buy signal")
alertcondition(sellSig, "RFC Sell Signal [JOAT]",
     "Regression Flux Candles: LR bearish crossunder — sell signal")

// ─── MTF DASHBOARD ───────────────────────────────────────────────────
f_cell(t, c, r, lbl, tr) =>
    clr = tr == 1 ? C_BULL : C_BEAR
    txt = tr == 1 ? "BULL" : "BEAR"
    table.cell(t, c,   r, lbl, text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(t, c+1, r, txt, text_color=clr,   text_size=size.small, bgcolor=C_PANEL)

var table dash = table.new(position.top_right, 2, 10,
     bgcolor=C_PANEL, border_width=1, border_color=color.new(color.gray, 55))

if i_showDash and i_showMTF and barstate.islast
    alignClr  = bullAligned >= 5 ? C_BULL : bullAligned <= 1 ? C_BEAR : C_GOLD
    lrDirStr  = isUp ? "BULL" : "BEAR"
    lrDirClr  = isUp ? C_BULL : C_BEAR

    table.cell(dash, 0, 0, "RFC [JOAT]",
         bgcolor=color.new(C_TEAL, 30), text_color=color.black, text_size=size.small)
    table.cell(dash, 1, 0, "MTF Trend",
         bgcolor=color.new(C_TEAL, 30), text_color=color.black, text_size=size.small)

    f_cell(dash, 0, 1, i_tf1,  t1)
    f_cell(dash, 0, 2, i_tf2,  t2)
    f_cell(dash, 0, 3, i_tf3,  t3)
    f_cell(dash, 0, 4, i_tf4,  t4)
    f_cell(dash, 0, 5, i_tf5,  t5)
    f_cell(dash, 0, 6, i_tf6,  t6)

    table.cell(dash, 0, 7, "LR Dir",  text_color=C_TXT,   text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 7, lrDirStr,  text_color=lrDirClr, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 8, "Aligned", text_color=C_TXT,    text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 8, str.tostring(bullAligned) + "/6",
         text_color=alignClr, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 9, "Buys/Sells", text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 9, str.tostring(dailyBuys) + "B / " + str.tostring(dailySells) + "S",
         text_color=C_GOLD, text_size=size.small, bgcolor=C_PANEL)
````
