# In1 + In2 Dual Confirmation Signals

- url: https://www.tradingview.com/script/S02xEhyw-In1-In2-Dual-Confirmation-Signals/
- type: indicator
- pine_id: PUB;83b0b514c1524850bdd6ecafe074ac14
- version: 1.0

## Description

In1 + In2 Dual Confirmation Signal Indicator
What It Tracks
This indicator is essentially a two-filter confirmation system designed to keep you out of low-quality trades. It combines two completely different approaches to reading the market — one tracks momentum and trend direction, the other tracks buying/selling pressure — and only fires a signal when both agree at the same time. Think of it like needing two different analysts to sign off on a trade before you take it.

The Two Engines
In1 — Stochastic SuperTrend
The first engine is a hybrid of two classic tools: the RSI and the Stochastic oscillator, fed into a SuperTrend framework.
Here's what it's doing under the hood:

It calculates the RSI of price, then runs a Stochastic calculation on that RSI (not on price directly). This smooths out a lot of noise.
That Stochastic RSI value is then used as the "price" input for a SuperTrend algorithm, which dynamically plots upper and lower bands and flips direction when the value breaks through them.
When the SuperTrend flips bullish and the Stochastic RSI is below 50 (not overbought), you get an In1 Buy arrow. When it flips bearish and the Stochastic RSI is above 50 (not oversold), you get an In1 Sell arrow.

The below/above 50 filter is important — it prevents the indicator from calling a bullish flip when momentum is already stretched high, and vice versa.
In2 — EVEREX (Engineered Volume & Price Flow)
The second engine is more sophisticated. It's measuring the quality and direction of buying vs. selling pressure on each candle by looking at multiple factors simultaneously:

How the candle closed relative to its range
The spread between open and close
How much price actually shifted
Volume weighting on all of the above

It normalizes all of these inputs and produces a single oscillator line. When that line flips from falling to rising, the background goes green (bulls taking over). When it flips from rising to falling, it goes red (bears taking over). The signal fires on those flip moments specifically — not while it's already trending in one direction.

How the Dual Confirmation Logic Works
This is where it gets smart. The indicator doesn't require both signals on the exact same candle — that would be too restrictive and you'd miss a lot of valid setups. Instead, it uses a lookback window:
For a BUY signal to fire:

In1 must have printed a bullish arrow on this candle OR within the last 1–2 candles
AND if In1 fired 1–2 bars ago (not this candle), the Stochastic RSI line must still be rising — confirming the momentum hasn't already reversed
AND In2 must flip green on this candle (that's the confirmation trigger)

For a SELL signal to fire:

Same logic in reverse — In1 bearish arrow within 1–2 candles, Stoch RSI still falling, In2 flips red

The B/S label prints on the candle where In2 flips — that's your entry candle.

Adjusting Signal Frequency
To get MORE signals (more sensitive, more trades, more false positives):

Lower the ST Multiplier (default 10) — a smaller multiplier makes the SuperTrend flip more often
Lower the RSI Length (default 10) or K (default 7) — shorter lookbacks react faster
Lower the EVEREX Length (default 10) or Signal Length (default 5) — the EVEREX oscillator will flip more frequently

To get FEWER signals (more selective, higher quality, fewer trades):

Raise the ST Multiplier — SuperTrend becomes harder to flip, only strong moves qualify
Raise the RSI Length and K — smoother, slower momentum readings
Raise the EVEREX Lookback (default 20) — the volume normalization uses a longer baseline, making it harder for a single candle to register as significant
Raise the EVEREX Length and Smooth — the oscillator becomes less twitchy

The Timeframe input is also huge — running In1 on a higher timeframe than your chart while watching In2 on the current chart creates a natural multi-timeframe filter that dramatically reduces noise.

How Alerts Work
There's a single alert condition called "In1+In2 Signal" that fires on either a Buy or Sell signal. When you set up the alert in TradingView, set it to "Once Per Bar Close" for confirmed signals, or "Once Per Bar" if you want real-time notification (more on that below). The message simply tells you a dual confirmation signal fired and to check the chart for the B/S label.

Real-Time vs. After Close — The Repainting Question
This is the most important thing for any trader to understand about this indicator.
In2 (EVEREX) is fully real-time and does NOT repaint. It's calculated purely from current bar data — price action, spread, volume — so what you see on the forming candle is what you get. If it flips green mid-candle, that flip is real.
In1 has a setting called "Wait for Timeframe Close." This is critical:

When turned ON — In1 only updates when the selected timeframe candle fully closes. The SuperTrend flip is confirmed and will not repaint. This is the safer setting for signal reliability.
When turned OFF — In1 updates in real time using lookahead. You'll see signals earlier, but if the higher timeframe candle closes differently than it looked mid-bar, the signal can vanish. This is the classic repainting scenario.

The 1–2 bar lookback window for In1 is also non-repainting because it uses dir[1], bars_since_up, and direction tracking that are all based on closed bar values — once a bar closes, those values are locked. So a signal that printed on a closed candle will stay there.
Bottom line for your workflow: Run "Wait for Timeframe Close" set to ON and set your alert to "Once Per Bar Close" — every signal you see on a closed candle is confirmed and won't disappear on you.

## Source Code

````pine
//@version=6
indicator("In1 + In2 Dual Confirmation Signals", overlay=true)

// ─── IN1 INPUTS (Stochastic SuperTrend) ──────────────────────────────────────
tf         = input.timeframe("", "Timeframe")
wait_close = input.bool(true, "Wait for Timeframe Close")
lengthRsi  = input.int(10, "RSI Length")
periodK    = input.int(7, "K")
smoothK    = input.int(3, "Smooth K")
factor     = input.int(10, "ST Multiplier")
col_up     = input.color(color.green, "Up Color")
col_dn     = input.color(color.red,   "Down Color")

// ─── IN2 INPUTS (EVEREX) ─────────────────────────────────────────────────────
ev_length   = input.int(10,  "EVEREX Length")
ev_smooth   = input.int(3,   "EVEREX Smooth")
ev_sig_len  = input.int(5,   "EVEREX Signal Length")
ev_lookback = input.int(20,  "EVEREX Lookback")

// ─── IN1 CALCULATIONS ────────────────────────────────────────────────────────
tf_close = wait_close
     ? request.security(syminfo.tickerid, tf, close, lookahead=barmerge.lookahead_off)
     : request.security(syminfo.tickerid, tf, close, lookahead=barmerge.lookahead_on)

rsi_val = ta.rsi(tf_close, lengthRsi)
k       = ta.sma(ta.stoch(rsi_val, rsi_val, rsi_val, periodK), smoothK)

k_direction = k > k[1] ? 1 : k < k[1] ? -1 : 0

upperBand = k + factor
lowerBand = k - factor

prevUpper = nz(upperBand[1])
prevLower = nz(lowerBand[1])

upperBand := upperBand < prevUpper or k[1] > prevUpper ? upperBand : prevUpper
lowerBand := lowerBand > prevLower or k[1] < prevLower ? lowerBand : prevLower

var float trend_st = na
var int   dir      = na

if bar_index == 1
    dir := 1
else if nz(trend_st[1]) == prevUpper
    dir := k > upperBand ? -1 : 1
else
    dir := k < lowerBand ? 1 : -1

trend_st := dir == -1 ? lowerBand : upperBand

// In1 raw signal events
in1_arrow_up   = dir != dir[1] and dir == -1 and k < 50
in1_arrow_down = dir != dir[1] and dir == 1  and k > 50

// ─── IN2 CALCULATIONS (EVEREX) ───────────────────────────────────────────────
GetAvg(_d, _l, _t) =>
    switch _t
        'SMA' => ta.sma(_d, _l)
        'EMA' => ta.ema(_d, _l)
        'HMA' => ta.hma(_d, _l)
        'RMA' => ta.rma(_d, _l)
        =>      ta.wma(_d, _l)

Normalize(_v, _avg) =>
    x = _v / _avg
    x > 1.50 ? 1.00 : x > 1.20 ? 0.90 : x > 1.00 ? 0.80 :x > 0.80 ? 0.70 : x > 0.60 ? 0.60 : x > 0.40 ? 0.50 :x > 0.20 ? 0.25 : 0.1

v      = na(volume) ? 1 : volume
Vola   = GetAvg(v, ev_lookback, 'SMA')
Vola_n = na(volume) ? 100.0 : Normalize(v, Vola) * 100

BarSpread     = close - open
BarRange      = high - low
R2            = ta.highest(2) - ta.lowest(2)
SrcShift      = ta.change(close)
sign_shift    = math.sign(SrcShift)
sign_spread   = math.sign(BarSpread)
barclosing    = BarRange != 0 ? 2 * (close - low) / BarRange * 100 - 100 : 0.0
s2r           = BarRange != 0 ? BarSpread / BarRange * 100 : 0.0

BarSpread_abs     = math.abs(BarSpread)
BarSpread_avg     = GetAvg(BarSpread_abs, ev_lookback, 'SMA')
BarSpread_ratio_n = Normalize(BarSpread_abs, BarSpread_avg) * 100 * sign_spread

barclosing_2     = R2 != 0 ? 2 * (close - ta.lowest(2)) / R2 * 100 - 100 : 0.0
Shift2Bar_toR2   = R2 != 0 ? SrcShift / R2 * 100 : 0.0

SrcShift_abs       = math.abs(SrcShift)
srcshift_avg       = GetAvg(SrcShift_abs, ev_lookback, 'SMA')
srcshift_ratio_n   = Normalize(SrcShift_abs, srcshift_avg) * 100 * sign_shift

Pricea_n = (barclosing + s2r + BarSpread_ratio_n + barclosing_2 + Shift2Bar_toR2 + srcshift_ratio_n) / 6
bar_flow = Pricea_n * Vola_n / 100

bulls = math.max(bar_flow, 0)
bears = -1 * math.min(bar_flow, 0)

bulls_avg = GetAvg(bulls, ev_length, 'WMA')
bears_avg = GetAvg(bears, ev_length, 'WMA')

dx      = bulls_avg / bears_avg
RROF_s  = ta.wma(2 * (100 - 100 / (1 + dx)) - 100, ev_smooth)
Signal  = GetAvg(RROF_s, ev_sig_len, 'WMA')

// In2 background flip detection
rrof_rising     = RROF_s > RROF_s[1]
in2_flip_green  = rrof_rising  and not rrof_rising[1]   // red → green
in2_flip_red    = not rrof_rising and rrof_rising[1]    // green → red

// ─── DUAL CONFIRMATION LOGIC ─────────────────────────────────────────────────
// Track whether In1 arrow fired within last 2 candles
// and whether the Stoch RSI line color hasn't reversed since

// Bars since last In1 up/down arrow
var int bars_since_up   = na
var int bars_since_down = na

if in1_arrow_up
    bars_since_up := 0
else if not na(bars_since_up)
    bars_since_up := bars_since_up + 1

if in1_arrow_down
    bars_since_down := 0
else if not na(bars_since_down)
    bars_since_down := bars_since_down + 1

// Stoch RSI line still green = k_direction == 1 (still rising)
// Stoch RSI line still red   = k_direction == -1 (still falling)
stoch_still_green = k_direction == 1
stoch_still_red   = k_direction == -1

// In1 valid for BUY: arrow fired this bar (same candle), OR fired 1–2 bars ago
// and the Stoch RSI line is still green
in1_buy_valid = in1_arrow_up or
     (not na(bars_since_up) and bars_since_up >= 1 and bars_since_up <= 2 and stoch_still_green)

// In1 valid for SELL: arrow fired this bar, OR fired 1–2 bars ago
// and the Stoch RSI line is still red
in1_sell_valid = in1_arrow_down or
     (not na(bars_since_down) and bars_since_down >= 1 and bars_since_down <= 2 and stoch_still_red)

// Final signals — In2 flip is the confirmation candle
buy_signal  = in2_flip_green and in1_buy_valid
sell_signal = in2_flip_red   and in1_sell_valid

// ─── PLOTS ───────────────────────────────────────────────────────────────────
plotshape(buy_signal,  "BUY",  shape.labelup,   location.belowbar, color.green, text="B", textcolor=color.white, size=size.small)
plotshape(sell_signal, "SELL", shape.labeldown,  location.abovebar, color.red,   text="S", textcolor=color.white, size=size.small)

// ─── ALERT ───────────────────────────────────────────────────────────────────
alertcondition(buy_signal or sell_signal, "In1+In2 Signal", "Dual confirmation signal fired — check chart for B/S label")
````
