# Volume Levels

- url: https://www.tradingview.com/script/m7Sg4pG5-Volume-Levels/
- type: indicator
- pine_id: PUB;98b7b1cc2cdd4a0694aa6e85db76a950
- version: 2.0

## Description

[b]Volume Levels[/b] highlights unusual volume activity directly on your chart by comparing each bar's volume against a moving average — not just the previous candle.

[b]Two configurable alert levels:[/b]
- [b]Level 1 [/b]— volume exceeds the average by a user-defined % (default: 50%)
- [b]Level 2 [/b]— volume exceeds the average by a higher user-defined % (default: 75%)

High-volume candles are recolored on the main chart so you can instantly spot where smart money is active. Normal candles retain their standard green/red color. The volume pane below mirrors the same color coding.

[b]Settings:[/b]
- Volume MA Length — lookback period for the average (default: 20)
- Enable/disable each level independently
- Configurable % threshold per level
- Custom color per level

Useful for identifying breakout confirmations, exhaustion moves, and institutional activity.

## Source Code

````pine
//@version=6
indicator("Volume Levels", overlay=false, max_bars_back=5000)

// ── Comparison Method ─────────────────────────────────────────────────────────
method     = input.string("RVOL", "Comparison Method", options=["RVOL", "EMA"],
              tooltip="RVOL: average volume at the exact same time of day over past N days\nEMA: rolling Exponential Moving Average of volume")
rvol_days  = input.int(10, "RVOL Lookback (days)", minval=2, maxval=20, group="RVOL Settings",
              tooltip="Number of past trading days to average. Higher = more stable but slower to adapt.")
ema_length   = input.int(20, "EMA Length",          minval=1,            group="EMA Settings")
baseline_col = input.color(color.new(color.rgb(100, 149, 237), 50), "Baseline Line Color")

// ── Alert Levels ──────────────────────────────────────────────────────────────
show_level1 = input.bool(true, "Enable Level 1", inline="l1")
thresh1     = input.float(50,  "% above avg",    inline="l1", minval=1, step=5)
col_level1  = input.color(color.new(color.orange,  0), "Color", inline="l1")

show_level2 = input.bool(true, "Enable Level 2", inline="l2")
thresh2     = input.float(75,  "% above avg",    inline="l2", minval=1, step=5)
col_level2  = input.color(color.new(color.fuchsia, 0), "Color", inline="l2")

// ── RVOL: match by exact hour + minute across past N trading days ─────────────
// Scans back through history to find bars at the same time of day
// Max scan depth: rvol_days * 400 bars (covers up to 20 days on 1-min charts)
rvol_sum   = 0.0
rvol_count = 0
max_scan   = rvol_days * 400

for i = 1 to max_scan
    if hour[i] == hour and minute[i] == minute
        rvol_sum   += volume[i]
        rvol_count += 1
        if rvol_count >= rvol_days
            break

avg_rvol = rvol_count > 0 ? rvol_sum / rvol_count : na

// ── EMA baseline ──────────────────────────────────────────────────────────────
avg_ema = ta.ema(volume, ema_length)

// ── Active baseline ───────────────────────────────────────────────────────────
avg_vol = method == "RVOL" ? avg_rvol : avg_ema

// ── Threshold checks ──────────────────────────────────────────────────────────
is_level2 = show_level2 and not na(avg_vol) and (volume > avg_vol * (1 + thresh2 / 100))
is_level1 = show_level1 and not na(avg_vol) and (volume > avg_vol * (1 + thresh1 / 100))

// ── Colors ────────────────────────────────────────────────────────────────────
normal_color = close >= open ? color.new(color.green, 0) : color.new(color.red, 0)
bar_color    = is_level2 ? col_level2 : is_level1 ? col_level1 : normal_color

// ── Output ────────────────────────────────────────────────────────────────────
barcolor(bar_color)
plot(volume,  style=plot.style_columns, color=bar_color,   title="Volume")
plot(avg_vol, style=plot.style_line,    color=baseline_col, title="Baseline", linewidth=2)
````
