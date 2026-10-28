# Reversal  Probability

- url: https://www.tradingview.com/script/cQPbhiCB-Reversal-Probability/
- type: indicator
- pine_id: PUB;91bb9ef2664c4810b3544767aed39ae7
- version: 1.0

## Description

Reversal · Probability %

*Not every reversal is equal. Now you can see exactly how strong each one is.*


**Overview**

This indicator is built on the proven reversal detection logic by HasanRifat, extended with a real-time multi-factor probability scoring engine. Every signal now shows a percentage directly on the candle — so instead of just knowing a reversal is happening, you know how much confluence is behind it.

A signal with 80% means five independent factors are aligning at the same moment. A signal with 40% means two are. You decide which ones to trade.

---

**How the Original Signal Works**

The core detection engine is unchanged from the original. It identifies a reversal by watching for a candle that closes below the lowest low or above the highest high of the previous lookback period — and then waits for price to confirm by breaking back through the trigger candle's range within your confirmation window. This makes the base signal clean, precise, and reliable on all timeframes.

---

**What the Probability % Adds**

On every signal, five independent factors are checked in real time. Each factor that aligns adds one point. Your final score divided by the maximum possible points gives the probability percentage shown on the label.

🔵 **RSI Extreme** — Is RSI in oversold territory on a bullish signal or overbought on a bearish signal? Reversals from exhausted momentum have higher follow-through.

🔊 **Volume Spike** — Is volume more than 1.5 times the 20-bar average on this candle? Institutional participation at a reversal point is a strong confirmation.

📐 **Premium / Discount Zone** — Is price below the midpoint of the recent range (discount) on a bullish signal, or above it (premium) on a bearish signal? Buying in discount and selling in premium aligns with smart money behaviour.

🕯️ **Wick Rejection** — Does the candle have a strong rejection wick in the opposite direction? A long lower wick on a bullish signal means price was aggressively pushed back up from the lows.

📈 **EMA Alignment** — Is price positioned correctly relative to the EMA for the signal direction? Trend alignment adds weight to the reversal.

---

**Signal Colours**

🟢 **Green** — Bullish reversal signal, standard probability

🔴 **Red** — Bearish reversal signal, standard probability

🟡 **Gold** — Any signal with 75% probability or above — your highest conviction setups

---

**How To Use It**

**Step 1** — Set your minimum probability filter. Default is 40%. If you want only the cleanest setups, raise it to 60% or 70%. The chart will show fewer signals but each one will have strong multi-factor confirmation behind it.

**Step 2** — Watch for gold labels. These are the 75%+ signals where the majority of factors are aligned. These are your A+ setups.

**Step 3** — Check the info panel. It shows the live probability for both directions, the factor score, RSI reading, premium or discount zone, and current volume status — all updated on every bar.

**Step 4** — Use the signal with your existing entry method. This indicator does not give you a stop loss or take profit. It tells you where and how strongly a reversal is forming. Your entry confirmation and risk management remain your own.

---

**Settings Guide**

| Setting | What It Does | Recommended |
|---|---|---|
| Candle Lookback | How many candles back to scan for the extreme | 20 default |
| Confirm Within | How many bars price has to confirm the signal | 3 default |
| Non-Repainting Mode | Signals fire on closed bars only | ON for live trading |
| Show Probability % | Toggle the % label on or off | ON |
| Minimum % to Show | Hide signals below this threshold | 40–60% |
| RSI Factor | Toggle RSI extreme check | ON |
| Volume Factor | Toggle volume spike check | ON |
| Zone Factor | Toggle premium/discount check | ON |
| Wick Factor | Toggle wick rejection check | ON |
| EMA Factor | Toggle EMA alignment check | ON |

---

**Tips**

- **Turn on Non-Repainting Mode for live trading.** This ensures signals only appear once the candle that triggered them has fully closed, eliminating any chance of the signal disappearing mid-bar.

- **Higher timeframes give higher quality signals.** A 75% signal on the 1 hour chart carries more weight than a 75% signal on the 5 minute chart because the factors are based on more significant price action.

- **Combine with a structure indicator.** This indicator tells you when a reversal is forming and how strong it is. A market structure or order block indicator tells you if you are at the right location for that reversal. Together they form a complete entry system.

- **Use the minimum probability filter as your quality gate.** Do not try to trade every signal. The filter exists so you do not have to manually judge each one — set it once and only the signals above your confidence threshold will appear.

- **Gold is your focus.** If you only ever trade the gold labels and ignore everything else, you will trade fewer setups with higher average quality. That is the right trade-off.

---

**Works on all markets and timeframes** — Forex, indices, crypto, commodities, stocks. The probability factors are universal and do not rely on any market-specific parameters.

---

**Credits**

Original reversal detection logic by HasanRifat. Probability scoring engine, label system, info panel, and factor toggles added as an extension of the original work.

---

**Subtitle (for TradingView subtitle field)**

> Multi-factor reversal detection with real-time probability scoring — see exactly how strong each signal is before you trade it.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HasanRifat — modified with Probability Scoring

//@version=5
indicator("Reversal · Probability %", overlay = true,
     max_labels_count = 500)

// ╔══════════════════════════════════════════════════════════════════════════╗
//  ⚙️  ORIGINAL SETTINGS — unchanged
// ╚══════════════════════════════════════════════════════════════════════════╝
G0 = "⚙️  Original Settings"
lookback     = input.int (20,    "Candle Lookback",     group = G0)
confirmation = input.int (3,     "Confirm Within",      group = G0)
nonRepaint   = input.bool(false, "Non-Repainting Mode", group = G0)

// ╔══════════════════════════════════════════════════════════════════════════╗
//  📊  PROBABILITY SETTINGS
// ╚══════════════════════════════════════════════════════════════════════════╝
G1 = "📊  Probability Settings"
en_prob      = input.bool(true,  "Show Probability %",              group = G1)
en_rsi       = input.bool(true,  "Factor: RSI Extreme",             group = G1)
en_vol       = input.bool(true,  "Factor: Volume Spike",            group = G1)
en_zone      = input.bool(true,  "Factor: Premium / Discount Zone", group = G1)
en_wick      = input.bool(true,  "Factor: Wick Rejection",          group = G1)
en_ema       = input.bool(true,  "Factor: EMA Alignment",           group = G1)
min_prob     = input.int (40,    "Minimum % to Show Signal",
     minval = 10, maxval = 100, step = 5, group = G1,
     tooltip = "Signals below this probability are hidden. Lower = more signals. Higher = cleaner chart.")

G2 = "📈  Factor Settings"
rsi_len      = input.int (14,   "RSI Length",         minval = 2,  group = G2)
rsi_ob       = input.int (65,   "RSI Overbought",     minval = 55, group = G2)
rsi_os       = input.int (35,   "RSI Oversold",       maxval = 45, group = G2)
ema_len      = input.int (50,   "EMA Length",         minval = 5,  group = G2)
wick_ratio   = input.float(0.55,"Wick Rejection Ratio",
     minval = 0.3, maxval = 0.9, step = 0.05, group = G2)
swing_len    = input.int (50,   "Zone Lookback (bars)",minval = 10, group = G2)

G3 = "🎨  Display"
bull_col     = input.color(#00E676, "Bullish Color",              group = G3)
bear_col     = input.color(#FF3D57, "Bearish Color",              group = G3)
gold_col     = input.color(#FFD700, "High Probability Color (≥75%)", group = G3)
lbl_sz       = input.string(size.small, "Label Size",
     options = [size.tiny, size.small, size.normal],               group = G3)
en_panel     = input.bool(true,  "Show Info Panel",               group = G3)
en_bg        = input.bool(true,  "Highlight Signal Candle",       group = G3)

// ╔══════════════════════════════════════════════════════════════════════════╗
//  🔁  ORIGINAL CORE LOGIC — untouched
// ╚══════════════════════════════════════════════════════════════════════════╝
bullCandle = 0
bearCandle = 0

vup = false
vdn = false

var bullActiveCandle    = false
var bullActiveCandleLow = 0.0
var bullActiveCandleHigh= 0.0
var bullSignalActive    = false
var bullCandleCount     = 0

var bearActiveCandle    = false
var bearActiveCandleLow = 0.0
var bearActiveCandleHigh= 0.0
var bearSignalActive    = false
var bearCandleCount     = 0

for i = 0 to (lookback - 1)
    if close < low[i]
        bullCandle += 1
    if close > high[i]
        bearCandle += 1

if bullCandle == (lookback - 1)
    bullActiveCandle    := true
    bullActiveCandleLow := low
    bullActiveCandleHigh:= high
    bullSignalActive    := false
    bullCandleCount     := 0

if bullActiveCandle
    bullCandleCount += 1

if bearCandle == (lookback - 1)
    bearActiveCandle    := true
    bearActiveCandleLow := low
    bearActiveCandleHigh:= high
    bearSignalActive    := false
    bearCandleCount     := 0

if bearActiveCandle
    bearCandleCount += 1

if close < bullActiveCandleLow
    bullActiveCandle := false

if close > bearActiveCandleHigh
    bearActiveCandle := false

if nonRepaint
    if bullActiveCandle[1] == true and close[1] > bullActiveCandleHigh[1] and bullSignalActive[1] == false and bullCandleCount[1] <= (confirmation + 1)
        bullSignalActive := true
        vup := true
else if bullActiveCandle == true and close > bullActiveCandleHigh and bullSignalActive == false and bullCandleCount <= (confirmation + 1)
    bullSignalActive := true
    vup := true

if nonRepaint
    if bearActiveCandle[1] == true and close[1] < bearActiveCandleLow[1] and bearSignalActive[1] == false and bearCandleCount[1] <= (confirmation + 1)
        bearSignalActive := true
        vdn := true
else if bearActiveCandle == true and close < bearActiveCandleLow and bearSignalActive == false and bearCandleCount <= (confirmation + 1)
    bearSignalActive := true
    vdn := true

// ╔══════════════════════════════════════════════════════════════════════════╗
//  🧮  PROBABILITY FACTORS
// ╚══════════════════════════════════════════════════════════════════════════╝
atr          = ta.atr(14)
rsi          = ta.rsi(close, rsi_len)
ema          = ta.ema(close, ema_len)
vol_avg      = ta.sma(volume, 20)
vol_spike    = volume > vol_avg * 1.5

body         = math.abs(close - open)
total_range  = high - low
upper_wick   = high - math.max(close, open)
lower_wick   = math.min(close, open) - low

swing_high   = ta.highest(high, swing_len)
swing_low    = ta.lowest (low,  swing_len)
eq_mid       = math.avg(swing_high, swing_low)
in_discount  = close < eq_mid
in_premium   = close > eq_mid

// Max factors = 5 (one per enabled category)
// Each factor scores 1 point when aligned

// ── Bullish probability factors
bull_f1 = en_rsi  and rsi < rsi_os                                      // RSI oversold
bull_f2 = en_vol  and vol_spike and close > open                        // Volume spike on bull candle
bull_f3 = en_zone and in_discount                                       // Price in discount zone
bull_f4 = en_wick and lower_wick >= total_range * wick_ratio            // Lower wick rejection
bull_f5 = en_ema  and close > ema                                       // Price above EMA (trend support)

bull_pts = (bull_f1 ? 1 : 0) + (bull_f2 ? 1 : 0) + (bull_f3 ? 1 : 0) +
           (bull_f4 ? 1 : 0) + (bull_f5 ? 1 : 0)

max_pts  = (en_rsi ? 1 : 0) + (en_vol ? 1 : 0) + (en_zone ? 1 : 0) +
           (en_wick ? 1 : 0) + (en_ema ? 1 : 0)

bull_prob = max_pts > 0 ? math.round(bull_pts / max_pts * 100) : 50

// ── Bearish probability factors
bear_f1 = en_rsi  and rsi > rsi_ob                                      // RSI overbought
bear_f2 = en_vol  and vol_spike and close < open                        // Volume spike on bear candle
bear_f3 = en_zone and in_premium                                        // Price in premium zone
bear_f4 = en_wick and upper_wick >= total_range * wick_ratio            // Upper wick rejection
bear_f5 = en_ema  and close < ema                                       // Price below EMA (trend resistance)

bear_pts = (bear_f1 ? 1 : 0) + (bear_f2 ? 1 : 0) + (bear_f3 ? 1 : 0) +
           (bear_f4 ? 1 : 0) + (bear_f5 ? 1 : 0)

bear_prob = max_pts > 0 ? math.round(bear_pts / max_pts * 100) : 50

// ╔══════════════════════════════════════════════════════════════════════════╗
//  🚦  FILTERED SIGNALS
// ╚══════════════════════════════════════════════════════════════════════════╝
show_up = vup and (not en_prob or bull_prob >= min_prob)
show_dn = vdn and (not en_prob or bear_prob >= min_prob)

// ╔══════════════════════════════════════════════════════════════════════════╗
//  🎨  LABELS WITH PROBABILITY
// ╚══════════════════════════════════════════════════════════════════════════╝
if show_up
    lbl_col  = bull_prob >= 75 ? gold_col : bull_col
    prob_str = en_prob ? "\n" + str.tostring(bull_prob) + "%" : ""
    label.new(bar_index, low - atr * 0.4,
         "▲" + prob_str,
         color     = color.new(color.black, 100),
         textcolor = lbl_col,
         style     = label.style_label_up,
         size      = lbl_sz)

if show_dn
    lbl_col  = bear_prob >= 75 ? gold_col : bear_col
    prob_str = en_prob ? "\n" + str.tostring(bear_prob) + "%" : ""
    label.new(bar_index, high + atr * 0.4,
         "▼" + prob_str,
         color     = color.new(color.black, 100),
         textcolor = lbl_col,
         style     = label.style_label_down,
         size      = lbl_sz)

// ╔══════════════════════════════════════════════════════════════════════════╗
//  🎨  CANDLE HIGHLIGHT
// ╚══════════════════════════════════════════════════════════════════════════╝
bgcolor(en_bg and show_up ?
     (bull_prob >= 75 ? color.new(gold_col, 90) : color.new(bull_col, 92)) : na,
     title = "Bull Signal Candle")
bgcolor(en_bg and show_dn ?
     (bear_prob >= 75 ? color.new(gold_col, 90) : color.new(bear_col, 92)) : na,
     title = "Bear Signal Candle")

// ╔══════════════════════════════════════════════════════════════════════════╗
//  📊  INFO PANEL
// ╚══════════════════════════════════════════════════════════════════════════╝
if en_panel and barstate.islast
    var table t = table.new(position.top_right, 2, 10,
         bgcolor      = color.new(#0D1117, 8),
         border_color = color.new(#FFFFFF, 82),
         border_width = 1,
         frame_color  = color.new(#FFFFFF, 75),
         frame_width  = 1)

    // Header
    table.cell(t, 0, 0, "REVERSAL · PROB",
         text_color = color.white, text_size = size.small,
         bgcolor    = color.new(#161B22, 0))
    table.cell(t, 1, 0, timeframe.period + " TF",
         text_color = color.gray,  text_size = size.small,
         bgcolor    = color.new(#161B22, 0))

    // Bull prob
    table.cell(t, 0, 1, "▲ Bull Prob",
         text_color = color.new(bull_col, 0), text_size = size.small)
    table.cell(t, 1, 1, str.tostring(bull_prob) + "%",
         text_color = bull_prob >= 75 ? gold_col : color.white,
         text_size  = size.small)

    // Bull factors
    table.cell(t, 0, 2, "▲ Factors",
         text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 2, str.tostring(bull_pts) + " / " + str.tostring(max_pts),
         text_color = color.white, text_size = size.small)

    // Bear prob
    table.cell(t, 0, 3, "▼ Bear Prob",
         text_color = color.new(bear_col, 0), text_size = size.small)
    table.cell(t, 1, 3, str.tostring(bear_prob) + "%",
         text_color = bear_prob >= 75 ? gold_col : color.white,
         text_size  = size.small)

    // Bear factors
    table.cell(t, 0, 4, "▼ Factors",
         text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 4, str.tostring(bear_pts) + " / " + str.tostring(max_pts),
         text_color = color.white, text_size = size.small)

    // Divider
    table.cell(t, 0, 5, "─────────",
         text_color = color.new(#FFFFFF, 70), text_size = size.tiny)
    table.cell(t, 1, 5, "─────────",
         text_color = color.new(#FFFFFF, 70), text_size = size.tiny)

    // RSI
    rsi_col = rsi > rsi_ob ? color.new(bear_col,0) : rsi < rsi_os ? color.new(bull_col,0) : color.gray
    table.cell(t, 0, 6, "RSI",
         text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 6, str.tostring(math.round(rsi, 1)),
         text_color = rsi_col,   text_size = size.small)

    // Zone
    zone_txt = in_premium ? "Premium" : "Discount"
    zone_col = in_premium ? color.new(bear_col,0) : color.new(bull_col,0)
    table.cell(t, 0, 7, "Zone",
         text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 7, zone_txt,
         text_color = zone_col,  text_size = size.small)

    // Volume
    vol_txt = vol_spike ? "Spike" : "Normal"
    vol_col = vol_spike ? gold_col : color.gray
    table.cell(t, 0, 8, "Volume",
         text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 8, vol_txt,
         text_color = vol_col,   text_size = size.small)

    // Min filter
    table.cell(t, 0, 9, "Min Filter",
         text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 9, str.tostring(min_prob) + "%",
         text_color = color.gray, text_size = size.small)

// ╔══════════════════════════════════════════════════════════════════════════╗
//  🔔  ALERTS
// ╚══════════════════════════════════════════════════════════════════════════╝
alertcondition(show_up,
     "Bullish Reversal ▲",
     "Bullish Reversal signal confirmed.")

alertcondition(show_dn,
     "Bearish Reversal ▼",
     "Bearish Reversal signal confirmed.")

alertcondition(show_up and bull_prob >= 75,
     "High Probability Bullish ▲ 75%+",
     "High probability bullish reversal — 75% or above.")

alertcondition(show_dn and bear_prob >= 75,
     "High Probability Bearish ▼ 75%+",
     "High probability bearish reversal — 75% or above.")

alertcondition(show_up or show_dn,
     "Any Reversal Signal ⚡",
     "Reversal signal detected — check direction and probability.")
````
