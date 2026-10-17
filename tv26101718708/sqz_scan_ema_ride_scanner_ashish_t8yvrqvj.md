# SQZ SCAN & EMA Ride Scanner - Ashish

- url: https://www.tradingview.com/script/t8YVrqvj-SQZ-SCAN-EMA-Ride-Scanner-Ashish/
- type: indicator
- pine_id: PUB;48b3b3fd199d468c8f75c5a132c0cf74
- version: 1.0

## Description

Short Description
A dual-mode EMA9/21/50 trend-ride scanner with volume classification and a relative-strength "Grinder Mode" for stocks that trend without ever coiling tight enough to trigger a squeeze. Use alongside its companion, SQZ_SCAN, for momentum timing.


What it does
EMA Ride Scanner V2.a finds stocks in a clean, established uptrend and flags healthy pullback zones to buy — instead of chasing breakouts after the move has happened. Built on ideas from Qullamaggie's Episodic Pivot framework, Stockbee's price-neglect filter, and VCPSwing's 10/20-MA ride philosophy. It checks: EMA9>21>50 stack alignment, minimum ride duration, distance from 52-week low, and volatility contraction. Volume bars are color-coded as EP surges, distribution, or healthy dips.

Two modes (single toggle)
Standard Mode (toggle OFF) — for stocks that coil and release. Flags a 0-5% pullback to EMA9, ideally on light volume. Pair with SQZ_SCAN for the breakout-timing signal.

Grinder Mode (toggle ON) — for stocks that never coil. Some strong trends have such low, steady volatility that they never compress enough to trigger a squeeze — by the time SQZ_SCAN fires, they've already run too far from EMA9 to count as a dip. Grinder Mode drops the squeeze requirement and instead checks: low ATR, long ride above EMA21, and meaningful outperformance vs a benchmark index (momentum begets momentum). If price is also near EMA9/21, it flags a Grinder Setup.

Note: cloud-bounce count is shown for visual reference only, not used as a filter — low-ATR stocks often show very few bounces simply because they ride EMA9 continuously rather than dipping and recovering.

Companion: SQZ_SCAN
SQZ_SCAN (LazyBear Squeeze Momentum, normalized to % of price for cross-stock comparison) shows when volatility compression releases into a confirmed move — WATCH (squeeze building, qualifying bar count reached), EARLY FIRE (momentum just turned positive inside the squeeze), or BUY (squeeze fired + momentum green & rising + volume surge confirmed).

Workflow:
Screen with EMA Ride Scanner (Standard Mode) for clean pullback candidates.
Check SQZ_SCAN on each — prioritize WATCH/EARLY FIRE/BUY.
Separately, screen Grinder Mode for low-volatility names — don't require SQZ confirmation here, it structurally won't fire for this archetype.
Sanity-check on hourly before entry — only to rule out an active breakdown, not as a hard gate. Both indicators are daily-timeframe tools; hourly readings are noisy and shouldn't override a valid daily setup.


What this isn't
A screening tool, not a full trading system — no buy/sell signals, no risk management built in. Combine with your own entry timing, sizing, and stops.

## Source Code

````pine
//@version=6
indicator("Squeeze Momentum Scanner [LazyBear + Normalised]", shorttitle="SQZ_SCAN", overlay=false)

// ═══════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════
grp1 = "Squeeze Settings (LazyBear Original)"
length      = input.int(20,   "BB Length",     group=grp1)
mult        = input.float(2.0,"BB MultFactor", group=grp1)
lengthKC    = input.int(20,   "KC Length",     group=grp1)
multKC      = input.float(1.5,"KC MultFactor", group=grp1)

grp2 = "Scanner Filters"
min_sqz_bars = input.int(5,   "Min Squeeze Bars",     group=grp2)
ema_len      = input.int(50,  "Trend EMA Length",     group=grp2)
vol_mult     = input.float(1.5,"Volume Surge (x avg)", group=grp2)

// ═══════════════════════════════════════════════════════════
// BOLLINGER BANDS — LazyBear exact
// ═══════════════════════════════════════════════════════════
basis   = ta.sma(close, length)
upperBB = basis + mult * ta.stdev(close, length)
lowerBB = basis - mult * ta.stdev(close, length)

// ═══════════════════════════════════════════════════════════
// KELTNER CHANNELS — LazyBear exact
// ═══════════════════════════════════════════════════════════
ma       = ta.sma(close, lengthKC)
rangema  = ta.sma(ta.tr, lengthKC)
upperKC  = ma + rangema * multKC
lowerKC  = ma - rangema * multKC

// ═══════════════════════════════════════════════════════════
// SQUEEZE DETECTION — LazyBear exact
// ═══════════════════════════════════════════════════════════
sqzOn  = lowerBB > lowerKC and upperBB < upperKC
sqzOff = lowerBB < lowerKC and upperBB > upperKC
noSqz  = sqzOn == false and sqzOff == false

var int squeeze_count = 0
squeeze_count := sqzOn ? squeeze_count + 1 : 0

squeeze_fired    = sqzOn[1] and not sqzOn
bars_since_fired = ta.barssince(squeeze_fired)
recently_fired   = not na(bars_since_fired) and bars_since_fired <= 1
squeeze_was_long = squeeze_count[1] >= min_sqz_bars

// ═══════════════════════════════════════════════════════════
// MOMENTUM — LazyBear exact formula, normalised by price × 100
// ═══════════════════════════════════════════════════════════
val_raw = ta.linreg(
     close - math.avg(
         math.avg(ta.highest(high, lengthKC), ta.lowest(low, lengthKC)),
         ta.sma(close, lengthKC)),
     lengthKC, 0)

val = val_raw / close * 100

mom_green  = val > 0
mom_rising = val > val[1]
mom_green_rising = mom_green and mom_rising

// ═══════════════════════════════════════════════════════════
// FILTERS
// ═══════════════════════════════════════════════════════════
ema50       = ta.ema(close, ema_len)
above_ema50 = close > ema50
avg_vol     = ta.sma(volume, 20)
vol_surge   = volume > avg_vol * vol_mult

// ═══════════════════════════════════════════════════════════
// STAGE SIGNALS
// ═══════════════════════════════════════════════════════════
stage1_watch = sqzOn and squeeze_was_long and above_ema50

early_fire = sqzOn
           and val  > 0
           and val[1] <= 0
           and above_ema50

stage2_buy = recently_fired
           and squeeze_was_long
           and mom_green_rising
           and above_ema50
           and vol_surge

// ═══════════════════════════════════════════════════════════
// SCREENER OUTPUT PLOTS
// ═══════════════════════════════════════════════════════════
plot(stage2_buy   ? 1 : 0, title="Stage 2 Buy",       color=color.green,  display=display.none)
plot(stage1_watch ? 1 : 0, title="Stage 1 Watch",     color=color.orange, display=display.none)
plot(early_fire   ? 1 : 0, title="Early Fire Warning", color=color.yellow, display=display.none)
plot(squeeze_count,         title="Squeeze Bar Count", color=color.gray,   display=display.none)
plot(val,                   title="Momentum Value %",  color=color.white,  display=display.none)
plot(above_ema50  ? 1 : 0, title="Above EMA50",        color=color.blue,   display=display.none)

// ═══════════════════════════════════════════════════════════
// VISUALS — MOMENTUM HISTOGRAM
// ═══════════════════════════════════════════════════════════
var color mom_col = na
if mom_green and mom_rising
    mom_col := color.new(#00c853, 0)
else if mom_green and not mom_rising
    mom_col := color.new(#00c853, 55)
else if not mom_green and not mom_rising
    mom_col := color.new(#ff1744, 0)
else
    mom_col := color.new(#ff1744, 55)

plot(val, style=plot.style_histogram, color=mom_col, linewidth=4, title="Momentum %")
plot(0,   style=plot.style_line, color=color.new(color.white, 70), linewidth=1)

hline(+10, "Strong Positive",  color=color.new(#00c853, 70), linestyle=hline.style_dashed)
hline(+3,  "Building Positive", color=color.new(#00c853, 85), linestyle=hline.style_dotted)
hline(-3,  "Building Negative", color=color.new(#ff1744, 85), linestyle=hline.style_dotted)
hline(-10, "Strong Negative",  color=color.new(#ff1744, 70), linestyle=hline.style_dashed)

// ═══════════════════════════════════════════════════════════
// SQUEEZE DOTS
// ═══════════════════════════════════════════════════════════
var color dot_col = na
if sqzOn
    dot_col := color.red
else if sqzOff
    dot_col := color.green
else
    dot_col := color.new(color.gray, 60)

plot(0, style=plot.style_circles, color=dot_col, linewidth=4, title="Squeeze Dots")

// ═══════════════════════════════════════════════════════════
// LABELS
// ═══════════════════════════════════════════════════════════
if stage2_buy
    label.new(bar_index, val,
              "BUY\n" + str.tostring(squeeze_count[1]) + " bar sqz",
              style=label.style_label_up, color=color.green,
              textcolor=color.white, size=size.small)

if early_fire
    label.new(bar_index, val,
              "EARLY\nFIRE",
              style=label.style_label_up, color=color.yellow,
              textcolor=color.black, size=size.small)

if sqzOn and squeeze_count == min_sqz_bars
    label.new(bar_index, val,
              "WATCH\n" + str.tostring(squeeze_count) + " bars",
              style=label.style_label_up, color=color.orange,
              textcolor=color.white, size=size.small)

// ═══════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════
alertcondition(stage2_buy,
     title="Stage 2 Buy — Squeeze Fired!",
     message="{{ticker}} — Squeeze fired! Momentum green & rising. Volume confirmed.")

alertcondition(early_fire,
     title="Early Fire Warning — Act Fast!",
     message="{{ticker}} — Momentum just turned positive inside squeeze! Check immediately.")

alertcondition(stage1_watch and squeeze_count == min_sqz_bars,
     title="Stage 1 Watch — Squeeze Qualifying",
     message="{{ticker}} — Squeeze building. Monitor for breakout.")

alertcondition(stage2_buy or early_fire,
     title="All Signals — Buy or Early Warning",
     message="{{ticker}} — Signal triggered. Check chart immediately.")
````
