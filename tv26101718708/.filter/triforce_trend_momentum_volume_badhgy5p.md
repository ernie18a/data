# TriForce: Trend + Momentum + Volume

- url: https://www.tradingview.com/script/bAdhgy5p-TriForce-Trend-Momentum-Volume/
- type: indicator
- pine_id: PUB;b6a23d962ef94a4abf1295ac0b771e4f
- version: 1.0

## Description

Here's your TriForce Indicator — a complete Pine Script v5 combining all three pillars:

🔱 What's Inside
LayerIndicatorRoleTrendSuperTrend (ATR-based)Determines market directionMomentumMACD (12/26/9)Confirms strength of the moveVolumeVAPI (signed volume %)Confirms institutional participation

🎯 Signal Logic

✅ STRONG BUY — All 3 agree bullish → high-confidence long entry
🔴 STRONG SELL — All 3 agree bearish → high-confidence short/exit
🟡 WATCH LONG — 2 of 3 bullish → wait for confirmation
🟠 WATCH SHORT — 2 of 3 bearish → caution, possible reversal
⬜ NEUTRAL — Mixed signals → stay out


📦 Features

SuperTrend line plotted on chart with color change
BUY/SELL arrow labels only on new signal (no repainting spam)
Background color shading for quick visual reading
Live status table (top-right corner) showing each indicator's state
4 alert conditions ready to set in TradingView


🚀 How to Add to TradingView

Open TradingView → Pine Editor (bottom panel)
Paste the script → click Add to chart
Customize ATR, MACD, and VAPI periods in Settings

## Source Code

````pine
// ============================================================
// TriForce Indicator — Trend + Momentum + Volume Combined
// Pine Script v5
// Combines: SuperTrend (Trend) + MACD (Momentum) + VAPI (Volume)
// ============================================================

//@version=5
indicator(title="TriForce: Trend + Momentum + Volume", shorttitle="TriForce", overlay=true)

// ══════════════════════════════════════════════
// ── GROUP 1: SUPERTREND (Trend Indicator) ─────
// ══════════════════════════════════════════════
st_atr_period  = input.int(10,    "SuperTrend ATR Period",     group="SuperTrend (Trend)")
st_multiplier  = input.float(3.0, "SuperTrend ATR Multiplier", group="SuperTrend (Trend)", step=0.1)

[supertrend, st_direction] = ta.supertrend(st_multiplier, st_atr_period)

bull_trend = st_direction < 0   // true = uptrend
bear_trend = st_direction > 0   // true = downtrend

// Plot SuperTrend line
st_color = bull_trend ? color.new(color.teal, 0) : color.new(color.red, 0)
plot(supertrend, title="SuperTrend", color=st_color, linewidth=2)

// ══════════════════════════════════════════════
// ── GROUP 2: MACD (Momentum Indicator) ────────
// ══════════════════════════════════════════════
macd_fast   = input.int(12, "MACD Fast Length",   group="MACD (Momentum)")
macd_slow   = input.int(26, "MACD Slow Length",   group="MACD (Momentum)")
macd_signal = input.int(9,  "MACD Signal Length",  group="MACD (Momentum)")

[macd_line, signal_line, histogram] = ta.macd(close, macd_fast, macd_slow, macd_signal)

macd_bull = macd_line > signal_line   // MACD above signal = bullish momentum
macd_bear = macd_line < signal_line   // MACD below signal = bearish momentum

// ══════════════════════════════════════════════
// ── GROUP 3: VAPI (Volume Indicator) ──────────
// ──   Volume Accumulation Percentage Index     ──
// ══════════════════════════════════════════════
vapi_period = input.int(14, "VAPI Lookback Period", group="VAPI (Volume)")

// Price change direction
price_change = close - close[1]

// Weighted volume: positive when price up, negative when price down
signed_vol = price_change >= 0 ? volume : -volume

// Cumulative signed volume over the period
cum_signed = math.sum(signed_vol, vapi_period)
cum_total  = math.sum(volume,     vapi_period)

// VAPI as percentage of total volume
vapi = cum_total != 0 ? (cum_signed / cum_total) * 100 : 0

vol_bull = vapi > 0    // positive = accumulation
vol_bear = vapi < 0    // negative = distribution

// ══════════════════════════════════════════════
// ── TRIFORCE SIGNAL LOGIC ─────────────────────
// ──  All 3 must agree for a clean signal       ──
// ══════════════════════════════════════════════

// Strong BUY: SuperTrend up + MACD bullish + Volume accumulating
strong_buy  = bull_trend and macd_bull and vol_bull

// Strong SELL: SuperTrend down + MACD bearish + Volume distributing
strong_sell = bear_trend and macd_bear and vol_bear

// Partial signals (2 of 3 agree)
partial_buy  = (bull_trend and macd_bull and not vol_bull)
             or (bull_trend and vol_bull and not macd_bull)
             or (macd_bull and vol_bull and not bull_trend)

partial_sell = (bear_trend and macd_bear and not vol_bear)
             or (bear_trend and vol_bear and not macd_bear)
             or (macd_bear and vol_bear and not bear_trend)

// ══════════════════════════════════════════════
// ── BACKGROUND COLORING ───────────────────────
// ══════════════════════════════════════════════
show_bg = input.bool(true, "Show Background Color", group="Display")

bgcolor(
     show_bg and strong_buy  ? color.new(color.teal,  88) :
     show_bg and strong_sell ? color.new(color.red,   88) :
     show_bg and partial_buy  ? color.new(color.green, 93) :
     show_bg and partial_sell ? color.new(color.orange,93) :
     na,
     title="Signal Background")

// ══════════════════════════════════════════════
// ── BUY / SELL ARROWS ─────────────────────────
// ══════════════════════════════════════════════
show_signals = input.bool(true, "Show Buy/Sell Arrows", group="Display")

// Strong signals
plotshape(show_signals and strong_buy  and not strong_buy[1],
     title="Strong BUY",  style=shape.labelup,
     location=location.belowbar, color=color.new(color.teal, 0),
     textcolor=color.white, text="BUY\n▲", size=size.normal)

plotshape(show_signals and strong_sell and not strong_sell[1],
     title="Strong SELL", style=shape.labeldown,
     location=location.abovebar, color=color.new(color.red, 0),
     textcolor=color.white, text="SELL\n▼", size=size.normal)

// Partial signals (smaller)
plotshape(show_signals and partial_buy  and not partial_buy[1]  and not strong_buy,
     title="Partial BUY",  style=shape.triangleup,
     location=location.belowbar, color=color.new(color.green, 20),
     size=size.small)

plotshape(show_signals and partial_sell and not partial_sell[1] and not strong_sell,
     title="Partial SELL", style=shape.triangledown,
     location=location.abovebar, color=color.new(color.orange, 20),
     size=size.small)

// ══════════════════════════════════════════════
// ── SIGNAL CHANGE ALERTS ──────────────────────
// ══════════════════════════════════════════════
alertcondition(strong_buy  and not strong_buy[1],  "TriForce STRONG BUY",  "TriForce: All 3 indicators aligned — STRONG BUY signal!")
alertcondition(strong_sell and not strong_sell[1], "TriForce STRONG SELL", "TriForce: All 3 indicators aligned — STRONG SELL signal!")
alertcondition(partial_buy  and not partial_buy[1],  "TriForce Partial BUY",  "TriForce: 2/3 indicators bullish — watch for entry.")
alertcondition(partial_sell and not partial_sell[1], "TriForce Partial SELL", "TriForce: 2/3 indicators bearish — watch for exit.")

// ══════════════════════════════════════════════
// ── INFO TABLE (top-right corner) ─────────────
// ══════════════════════════════════════════════
show_table = input.bool(true, "Show Status Table", group="Display")

if show_table and barstate.islast
    var table info = table.new(position.top_right, 2, 5,
         bgcolor=color.new(color.black, 70),
         border_color=color.new(color.gray, 50), border_width=1)

    // Header
    table.cell(info, 0, 0, "TriForce",   text_color=color.white,  text_size=size.small, bgcolor=color.new(color.navy, 40))
    table.cell(info, 1, 0, "Status",     text_color=color.white,  text_size=size.small, bgcolor=color.new(color.navy, 40))

    // SuperTrend row
    st_text  = bull_trend ? "▲ UPTREND"   : "▼ DOWNTREND"
    st_col   = bull_trend ? color.teal     : color.red
    table.cell(info, 0, 1, "SuperTrend", text_color=color.silver, text_size=size.small)
    table.cell(info, 1, 1, st_text,      text_color=st_col,       text_size=size.small)

    // MACD row
    macd_text = macd_bull ? "▲ BULLISH" : "▼ BEARISH"
    macd_col  = macd_bull ? color.teal  : color.red
    table.cell(info, 0, 2, "MACD",    text_color=color.silver, text_size=size.small)
    table.cell(info, 1, 2, macd_text, text_color=macd_col,     text_size=size.small)

    // VAPI row
    vapi_text = vol_bull ? "▲ ACCUMUL." : "▼ DISTRIBUT."
    vapi_col  = vol_bull ? color.teal   : color.red
    table.cell(info, 0, 3, "VAPI Vol.", text_color=color.silver, text_size=size.small)
    table.cell(info, 1, 3, vapi_text,   text_color=vapi_col,     text_size=size.small)

    // Overall signal
    sig_text = strong_buy  ? "✅ STRONG BUY"   :
               strong_sell ? "🔴 STRONG SELL"  :
               partial_buy  ? "🟡 WATCH LONG"  :
               partial_sell ? "🟠 WATCH SHORT" :
               "⬜ NEUTRAL"
    sig_col  = strong_buy  ? color.teal   :
               strong_sell ? color.red    :
               partial_buy  ? color.yellow :
               partial_sell ? color.orange :
               color.gray
    table.cell(info, 0, 4, "Signal",  text_color=color.silver, text_size=size.small)
    table.cell(info, 1, 4, sig_text,  text_color=sig_col,      text_size=size.small)
````
