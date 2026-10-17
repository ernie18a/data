# MTF Trend Dashboard [Proozac]

- url: https://www.tradingview.com/script/WuUz9D7m-MTF-Trend-Dashboard-Proozac/
- type: indicator
- pine_id: PUB;7ca170d9407647debf78964816736686
- version: 1.0

## Description

# MTF Trend Dashboard

**Pine Script v5 — Overlay Indicator**

---

## What It Does

Displays a compact table showing the trend direction, RSI value, and a trading bias for up to **6 timeframes simultaneously** — all from a single indicator on any chart.

The core idea: before entering a trade, confirm that the higher timeframes agree with your direction. A long setup on the 15m is far stronger when the 1H, 4H, and Daily are all bullish. This dashboard makes that check instant.

---

## Detection Logic

### Trend — EMA Cross

For each timeframe, the indicator fetches two EMAs (fast and slow) using `request.security`. The trend is determined by their relative position:

```
Bullish : Fast EMA > Slow EMA
Bearish : Fast EMA < Slow EMA
```

Default: Fast EMA = 20, Slow EMA = 50. These can be changed to any values (e.g. 50/200 for longer-term bias).

### RSI

The RSI (default length 14) is fetched for each timeframe alongside the EMAs. It provides momentum context within the trend:

- RSI > 70 → overbought (cell turns red)
- RSI < 30 → oversold (cell turns green)
- 30–70 → neutral

### Bias Column

A simple confluence rule combining trend and RSI:

```
Long  : Bullish trend AND RSI < 65  (trending up, not yet overbought)
Short : Bearish trend AND RSI > 35  (trending down, not yet oversold)
Wait  : Any other combination
```

### Composite Score

The bottom row counts how many of the 6 timeframes are bullish (0–6). When 5 or 6 are bullish, the background flashes green. When 1 or 0 are bullish, it flashes red. Triangles appear on the price chart only when all 6 timeframes align.

---

## Inputs

| Input | Default | Description |
|-------|---------|-------------|
| **TF 1–6** | 5, 15, 60, 240, D, W | The six timeframes to analyse. All are fully customisable |
| **Fast EMA** | 20 | Fast EMA length applied on every timeframe |
| **Slow EMA** | 50 | Slow EMA length applied on every timeframe |
| **RSI Length** | 14 | RSI period applied on every timeframe |
| **Table Position** | Bottom Right | Where the table appears on the chart |
| **Composite Bias Background** | true | Flashes background green/red when 5+ or 1- TFs align |

---

## Table Layout

```
┌──────────┬────────────┬───────┬───────┐
│  TF      │  Trend     │  RSI  │  Bias │
├──────────┼────────────┼───────┼───────┤
│  5       │  ▲  BULL   │ 58.3  │ Long  │
│  15      │  ▲  BULL   │ 62.1  │ Long  │
│  60      │  ▼  BEAR   │ 44.7  │ Wait  │
│  240     │  ▲  BULL   │ 55.0  │ Long  │
│  D       │  ▲  BULL   │ 67.2  │ Wait  │
│  W       │  ▲  BULL   │ 71.4  │ Wait  │
├──────────┼────────────┼───────┼───────┤
│  Score   │  5 / 6 Bull│       │       │
└──────────┴────────────┴───────┴───────┘
```

| Column | Color logic |
|--------|-------------|
| **Trend** | Green background = bullish, Red = bearish |
| **RSI** | Red = overbought (>70), Green = oversold (<30), Neutral otherwise |
| **Bias** | Green = Long, Red = Short, Neutral = Wait |
| **Score** | Green = 5–6 bull, Red = 0–1 bull, Neutral otherwise |

---

## Visual Signals on the Chart

| Signal | Condition |
|--------|-----------|
| Green triangle below bar | All 6 timeframes bullish simultaneously |
| Red triangle above bar | All 6 timeframes bearish simultaneously |
| Green background flash | 5 or 6 TFs bullish (composite bias) |
| Red background flash | 1 or 0 TFs bullish (composite bias) |

---

## How to Use

**Trend-following filter:**
Use the dashboard as a go/no-go filter. Only take long trades when 4 or more timeframes show bullish, and short trades when 4 or more are bearish. This eliminates trades taken against the dominant trend.

**Recommended TF combinations by trading style:**

| Style | Suggested TF set |
|-------|-----------------|
| Scalping | 1, 3, 5, 15, 30, 60 |
| Day trading | 5, 15, 30, 60, 240, D |
| Swing trading | 60, 240, D, W, M, 3M |
| Position trading | D, W, M, 3M, 6M, 12M |

**EMA combinations:**

| Goal | Fast / Slow |
|------|-------------|
| Short-term momentum | 9 / 21 |
| Default (balanced) | 20 / 50 |
| Macro trend | 50 / 200 |

---

## Important Notes

- The table only updates on the **last bar** (`barstate.islast`) to avoid performance overhead on large datasets.
- `request.security` uses `lookahead=off` to prevent future data leakage — values shown are confirmed closed-bar data from each higher timeframe.
- On timeframes below the chart's current timeframe, data will not be available — always set TF 1 equal to or higher than the chart timeframe.
- The "All TF" triangle signals (all 6 aligned) are rare but high-conviction. They can be used as standalone alerts without additional filters.

---

## Setting Up Alerts

The indicator fires visual signals but does not include `alertcondition` entries by default (the table updates on the last bar only). To alert on alignment:

1. Add the indicator to the chart.
2. Create an alert using **"Any alert() function call"** if you add custom alert logic, or monitor the background color signal manually.

Alternatively, combine this dashboard with any of the other indicators in this suite (SMC, Divergence Hunter) and only take their signals when the MTF score is 4+.

## Source Code

````pine
//@version=6
// MTF Trend Dashboard — EMA trend + RSI across 6 timeframes
indicator("MTF Trend Dashboard", shorttitle="MTF Dashboard", overlay=true)

// ── Inputs ────────────────────────────────────────────────────────────────────
g1 = "Timeframes"
tf1 = input.timeframe("5",   "TF 1", group=g1)
tf2 = input.timeframe("15",  "TF 2", group=g1)
tf3 = input.timeframe("60",  "TF 3", group=g1)
tf4 = input.timeframe("240", "TF 4", group=g1)
tf5 = input.timeframe("D",   "TF 5", group=g1)
tf6 = input.timeframe("W",   "TF 6", group=g1)

g2 = "Indicator Settings"
ema_fast = input.int(20, "Fast EMA", group=g2, minval=1)
ema_slow = input.int(50, "Slow EMA", group=g2, minval=1)
rsi_len  = input.int(14, "RSI Length", group=g2, minval=1)

g3 = "Display"
tbl_pos_str = input.string("Bottom Right", "Table Position", group=g3, options=["Top Left","Top Right","Middle Left","Middle Right","Bottom Left","Bottom Right"])
show_bg     = input.bool(true, "Composite Bias Background", group=g3)

// ── MTF Data ──────────────────────────────────────────────────────────────────
get_data(tf) =>
    [request.security(syminfo.tickerid, tf, ta.ema(close, ema_fast), lookahead=barmerge.lookahead_off),
     request.security(syminfo.tickerid, tf, ta.ema(close, ema_slow), lookahead=barmerge.lookahead_off),
     request.security(syminfo.tickerid, tf, ta.rsi(close, rsi_len),  lookahead=barmerge.lookahead_off)]

[f1,s1,r1] = get_data(tf1)
[f2,s2,r2] = get_data(tf2)
[f3,s3,r3] = get_data(tf3)
[f4,s4,r4] = get_data(tf4)
[f5,s5,r5] = get_data(tf5)
[f6,s6,r6] = get_data(tf6)

bull1 = f1 > s1
bull2 = f2 > s2
bull3 = f3 > s3
bull4 = f4 > s4
bull5 = f5 > s5
bull6 = f6 > s6

bull_count = (bull1?1:0)+(bull2?1:0)+(bull3?1:0)+(bull4?1:0)+(bull5?1:0)+(bull6?1:0)

// ── Table ─────────────────────────────────────────────────────────────────────
pos_map(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Middle Left"  => position.middle_left
        "Middle Right" => position.middle_right
        "Bottom Left"  => position.bottom_left
        =>               position.bottom_right

var table tbl = table.new(pos_map(tbl_pos_str), 4, 8, bgcolor=color.new(#0d1117, 5), border_color=color.new(color.gray, 70), border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)

C_HEADER = color.new(#161b22, 0)
C_BULL   = color.new(#238636, 0)
C_BEAR   = color.new(#da3633, 0)
C_WAIT   = color.new(#3d444d, 0)
C_TXT    = color.white

fill_row(row, tf, is_bull, rsi) =>
    sig     = is_bull ? "  BULL" : "  BEAR"
    sig_bg  = is_bull ? C_BULL : C_BEAR
    rsi_str = str.format("{0,number,#.##}", rsi)
    rsi_bg  = rsi > 70 ? color.new(#da3633, 40) : rsi < 30 ? color.new(#238636, 40) : C_WAIT
    bias    = is_bull and rsi < 65 ? "Long" : not is_bull and rsi > 35 ? "Short" : "Wait"
    bias_bg = is_bull and rsi < 65 ? color.new(#238636, 50) : not is_bull and rsi > 35 ? color.new(#da3633, 50) : C_WAIT
    table.cell(tbl, 0, row, " " + tf, text_color=C_TXT, bgcolor=C_WAIT, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, row, sig, text_color=C_TXT, bgcolor=sig_bg, text_size=size.small)
    table.cell(tbl, 2, row, rsi_str, text_color=C_TXT, bgcolor=rsi_bg, text_size=size.small)
    table.cell(tbl, 3, row, bias, text_color=C_TXT, bgcolor=bias_bg, text_size=size.small)

if barstate.islast
    table.cell(tbl, 0, 0, " TF",   text_color=C_TXT, bgcolor=C_HEADER, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 0, "Trend", text_color=C_TXT, bgcolor=C_HEADER, text_size=size.small)
    table.cell(tbl, 2, 0, "RSI",   text_color=C_TXT, bgcolor=C_HEADER, text_size=size.small)
    table.cell(tbl, 3, 0, "Bias",  text_color=C_TXT, bgcolor=C_HEADER, text_size=size.small)
    fill_row(1, tf1, bull1, r1)
    fill_row(2, tf2, bull2, r2)
    fill_row(3, tf3, bull3, r3)
    fill_row(4, tf4, bull4, r4)
    fill_row(5, tf5, bull5, r5)
    fill_row(6, tf6, bull6, r6)
    score_str = str.tostring(bull_count) + " / 6 Bull"
    score_bg  = bull_count >= 5 ? C_BULL : bull_count <= 1 ? C_BEAR : C_WAIT
    table.cell(tbl, 0, 7, " Score",  text_color=C_TXT, bgcolor=score_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 7, score_str, text_color=C_TXT, bgcolor=score_bg, text_size=size.small)
    table.cell(tbl, 2, 7, "",        text_color=C_TXT, bgcolor=score_bg, text_size=size.small)
    table.cell(tbl, 3, 7, "",        text_color=C_TXT, bgcolor=score_bg, text_size=size.small)

// ── Composite background ──────────────────────────────────────────────────────
comp_bg = show_bg and bull_count >= 5 ? color.new(#238636, 95) : show_bg and bull_count <= 1 ? color.new(#da3633, 95) : na
bgcolor(comp_bg, title="MTF Composite Bias")

// ── Signals on price chart ────────────────────────────────────────────────────
all_bull = bull_count == 6
all_bear = bull_count == 0
plotshape(all_bull, "All TF Bull", shape.triangleup,   location.belowbar, color.new(#238636, 0), size=size.small)
plotshape(all_bear, "All TF Bear", shape.triangledown, location.abovebar, color.new(#da3633, 0), size=size.small)
````
