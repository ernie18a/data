# Divergence Hunter [Proozac]

- url: https://www.tradingview.com/script/dl9h5QzZ-Divergence-Hunter-Proozac/
- type: indicator
- pine_id: PUB;974374bed445455da6bffc0e472adc4d
- version: 1.0

## Description

# Divergence Hunter — RSI · MACD · OBV

**Pine Script v5 — Overlay Indicator**

---

## What It Does

Scans three oscillators simultaneously — RSI, MACD, and OBV — and draws labelled lines directly on the price chart whenever a divergence is detected between price action and oscillator momentum.

Two divergence types are covered per oscillator:

- **Regular divergence** — signals a potential trend reversal
- **Hidden divergence** — signals a potential trend continuation

---

## Divergence Types Explained

### Regular Bullish Divergence
```
Price:       Lower Low  (LL)
Oscillator:  Higher Low (HL)
Signal:      Potential reversal UP
```
Price is making lower lows but the oscillator is making higher lows — sellers are losing momentum. The downtrend is weakening.

### Regular Bearish Divergence
```
Price:       Higher High (HH)
Oscillator:  Lower High  (LH)
Signal:      Potential reversal DOWN
```
Price is making higher highs but the oscillator is making lower highs — buyers are losing momentum. The uptrend is weakening.

### Hidden Bullish Divergence
```
Price:       Higher Low (HL)  ← trend is up
Oscillator:  Lower Low  (LL)
Signal:      Continuation UP
```
Price holds higher lows (uptrend structure intact) while the oscillator dips lower — a temporary oscillator pullback during a healthy uptrend. A continuation signal.

### Hidden Bearish Divergence
```
Price:       Lower High (LH)  ← trend is down
Oscillator:  Higher High (HH)
Signal:      Continuation DOWN
```
Price is making lower highs (downtrend structure intact) while the oscillator makes higher highs — a temporary oscillator bounce during a healthy downtrend.

---

## The Three Oscillators

| Oscillator | What it measures | Why it diverges |
|-----------|-----------------|-----------------|
| **RSI** | Relative momentum of closes | Classic divergence tool — very reliable at extremes |
| **MACD** | Trend + momentum combined | Useful in trending markets, less noise than RSI |
| **OBV** | Cumulative volume flow | Measures whether volume confirms the price move |

Each oscillator runs through the same `detect_divs()` function. You can enable or disable each one independently. When multiple oscillators show the same divergence simultaneously, that is a high-conviction signal.

---

## Detection Logic

The indicator uses `ta.pivothigh` and `ta.pivotlow` on the **price** series to find swing points, then reads the **oscillator value at that same bar** to compare:

```
For each new pivot high in price:
    Compare price level  vs previous pivot high price
    Compare oscillator   vs previous pivot high oscillator
    → Regular Bear:  price HH + osc LH
    → Hidden  Bear:  price LH + osc HH

For each new pivot low in price:
    Compare price level  vs previous pivot low price
    Compare oscillator   vs previous pivot low oscillator
    → Regular Bull:  price LL + osc HL
    → Hidden  Bull:  price HL + osc LL
```

When detected, a **line** is drawn connecting the two price pivot points and a **label** marks the divergence type and oscillator name.

---

## Inputs

| Input | Default | Description |
|-------|---------|-------------|
| **RSI Divergence** | true | Enable RSI divergence scanning |
| **RSI Length** | 14 | RSI calculation period |
| **MACD Divergence** | true | Enable MACD line divergence scanning |
| **MACD Fast** | 12 | MACD fast EMA length |
| **MACD Slow** | 26 | MACD slow EMA length |
| **MACD Signal** | 9 | MACD signal line length |
| **OBV Divergence** | true | Enable OBV divergence scanning |
| **Pivot Lookback (left bars)** | 5 | Bars to the left required to confirm a swing point |
| **Pivot Lookback (right bars)** | 5 | Bars to the right required to confirm a swing point |
| **Show Hidden Divergences** | true | Toggle hidden divergence lines on/off |
| **Bullish Regular** | Bright green | Line/label color for regular bullish divergences |
| **Bearish Regular** | Bright red | Line/label color for regular bearish divergences |
| **Bullish Hidden** | Faded green | Line/label color for hidden bullish divergences |
| **Bearish Hidden** | Faded red | Line/label color for hidden bearish divergences |

---

## Visual Output

| Element | Meaning |
|---------|---------|
| Solid bright green line + label `"RSI Bull Div"` | Regular bullish divergence on RSI |
| Solid bright red line + label `"RSI Bear Div"` | Regular bearish divergence on RSI |
| Dashed faded green line + label `"RSI Hid Bull"` | Hidden bullish divergence on RSI |
| Dashed faded red line + label `"RSI Hid Bear"` | Hidden bearish divergence on RSI |
| Same patterns with `"MACD"` or `"OBV"` prefix | Divergence from that oscillator |
| Green background flash | Any bullish regular divergence firing |
| Red background flash | Any bearish regular divergence firing |

Lines connect the **two price swing points** that form the divergence, making it immediately clear which highs or lows are being compared.

---

## How to Use

**Entry logic:**
- Regular divergence → look for a reversal entry after the divergence confirms (pivot right bars have closed).
- Hidden divergence → look for a continuation entry in the direction of the main trend.
- Always wait for the pivot to fully confirm — the signal appears `pivot_rb` bars after the actual swing point.

**Confluence filter:**
A divergence is most reliable when:
1. Two or more oscillators show the same divergence simultaneously
2. Price is at a key structural level (support/resistance, Order Block, session high/low)
3. The MTF Dashboard (indicator 02 in this suite) confirms the higher timeframe trend

**Reducing noise:**
- Increase `Pivot Lookback` (left/right bars) to 8–10 for cleaner, less frequent signals
- Disable OBV if trading Forex (OBV is volume-dependent and FX volume data is tick-based)
- Disable hidden divergences if you only want reversal signals

---

## Configuration Tips

| Scenario | Recommended settings |
|----------|---------------------|
| Fast scalping (1–5m) | Pivot: 3/3, RSI only |
| Day trading (15m–1H) | Pivot: 5/5, RSI + MACD |
| Swing trading (4H–D) | Pivot: 8/8, all three oscillators |
| Crypto (high volatility) | Pivot: 7/7 to filter noise |

---

## Alerts

Two built-in `alertcondition` entries:
- `Bullish Divergence` — fires when any enabled oscillator confirms a regular bullish divergence
- `Bearish Divergence` — fires when any enabled oscillator confirms a regular bearish divergence

Set up in TradingView: Alerts → Condition → Divergence Hunter → select the desired condition.

## Source Code

````pine
//@version=6
// Divergence Hunter — RSI · MACD · OBV
indicator("Divergence Hunter — RSI · MACD · OBV", shorttitle="Div Hunter", overlay=true, max_lines_count=500, max_labels_count=300)

// ── Inputs ────────────────────────────────────────────────────────────────────
g1 = "Oscillators"
use_rsi  = input.bool(true, "RSI Divergence", group=g1)
rsi_len  = input.int(14, "RSI Length", group=g1, minval=2)
use_macd = input.bool(true, "MACD Divergence", group=g1)
macd_f   = input.int(12, "MACD Fast", group=g1, minval=2)
macd_s   = input.int(26, "MACD Slow", group=g1, minval=2)
macd_sig = input.int(9,  "MACD Signal", group=g1, minval=2)
use_obv  = input.bool(true, "OBV Divergence", group=g1)

g2 = "Detection"
pivot_lb    = input.int(5, "Pivot Lookback (left bars)", group=g2, minval=2, maxval=20)
pivot_rb    = input.int(5, "Pivot Lookback (right bars)", group=g2, minval=2, maxval=20)
show_hidden = input.bool(true, "Show Hidden Divergences", group=g2)

g3 = "Colors"
bull_reg_col = input.color(#69F0AE, "Bullish Regular", group=g3)
bear_reg_col = input.color(#FF5252, "Bearish Regular", group=g3)
bull_hid_col = input.color(color.new(#69F0AE, 40), "Bullish Hidden", group=g3)
bear_hid_col = input.color(color.new(#FF5252, 40), "Bearish Hidden", group=g3)

// ── Oscillators ───────────────────────────────────────────────────────────────
rsi_val            = ta.rsi(close, rsi_len)
[macd_line, _, __] = ta.macd(close, macd_f, macd_s, macd_sig)
obv_val            = ta.obv

// ── Divergence Detection ──────────────────────────────────────────────────────
detect_divs(osc_src, osc_name) =>
    ph_price = ta.pivothigh(high, pivot_lb, pivot_rb)
    pl_price = ta.pivotlow(low,  pivot_lb, pivot_rb)

    var float prev_ph_price = na
    var float prev_ph_osc   = na
    var int   prev_ph_bar   = na
    var float prev_pl_price = na
    var float prev_pl_osc   = na
    var int   prev_pl_bar   = na

    bull_reg = false
    bear_reg = false
    bull_hid = false
    bear_hid = false

    if not na(ph_price)
        osc_at_ph = osc_src[pivot_rb]
        if not na(prev_ph_price)
            if ph_price > prev_ph_price and osc_at_ph < prev_ph_osc
                bear_reg := true
                line.new(prev_ph_bar, prev_ph_price, bar_index - pivot_rb, ph_price, color=bear_reg_col, width=2)
                label.new(bar_index - pivot_rb, ph_price, osc_name + "\nBear Div", style=label.style_label_down, size=size.tiny, color=color.new(bear_reg_col, 20), textcolor=color.white)
            if show_hidden and ph_price < prev_ph_price and osc_at_ph > prev_ph_osc
                bear_hid := true
                line.new(prev_ph_bar, prev_ph_price, bar_index - pivot_rb, ph_price, color=bear_hid_col, width=1, style=line.style_dashed)
                label.new(bar_index - pivot_rb, ph_price, osc_name + "\nHid Bear", style=label.style_label_down, size=size.tiny, color=color.new(bear_hid_col, 20), textcolor=color.white)
        prev_ph_price := ph_price
        prev_ph_osc   := osc_at_ph
        prev_ph_bar   := bar_index - pivot_rb

    if not na(pl_price)
        osc_at_pl = osc_src[pivot_rb]
        if not na(prev_pl_price)
            if pl_price < prev_pl_price and osc_at_pl > prev_pl_osc
                bull_reg := true
                line.new(prev_pl_bar, prev_pl_price, bar_index - pivot_rb, pl_price, color=bull_reg_col, width=2)
                label.new(bar_index - pivot_rb, pl_price, osc_name + "\nBull Div", style=label.style_label_up, size=size.tiny, color=color.new(bull_reg_col, 20), textcolor=color.black)
            if show_hidden and pl_price > prev_pl_price and osc_at_pl < prev_pl_osc
                bull_hid := true
                line.new(prev_pl_bar, prev_pl_price, bar_index - pivot_rb, pl_price, color=bull_hid_col, width=1, style=line.style_dashed)
                label.new(bar_index - pivot_rb, pl_price, osc_name + "\nHid Bull", style=label.style_label_up, size=size.tiny, color=color.new(bull_hid_col, 20), textcolor=color.black)
        prev_pl_price := pl_price
        prev_pl_osc   := osc_at_pl
        prev_pl_bar   := bar_index - pivot_rb

    [bull_reg, bear_reg, bull_hid, bear_hid]

// ── Run Detectors ─────────────────────────────────────────────────────────────
// Ternary operators cannot return tuples in Pine Script — use if/else instead
[rsi_br, rsi_ber, rsi_bh, rsi_beh] = if use_rsi
    detect_divs(rsi_val, "RSI")
else
    [false, false, false, false]

[mac_br, mac_ber, mac_bh, mac_beh] = if use_macd
    detect_divs(macd_line, "MACD")
else
    [false, false, false, false]

[obv_br, obv_ber, obv_bh, obv_beh] = if use_obv
    detect_divs(obv_val, "OBV")
else
    [false, false, false, false]

any_bull = rsi_br or mac_br or obv_br
any_bear = rsi_ber or mac_ber or obv_ber

div_bg = any_bull ? color.new(bull_reg_col, 90) : any_bear ? color.new(bear_reg_col, 90) : na
bgcolor(div_bg, title="Divergence Flash")

alertcondition(any_bull, "Bullish Divergence", "{{ticker}} — Bullish divergence confirmed on {{interval}}")
alertcondition(any_bear, "Bearish Divergence", "{{ticker}} — Bearish divergence confirmed on {{interval}}")
````
