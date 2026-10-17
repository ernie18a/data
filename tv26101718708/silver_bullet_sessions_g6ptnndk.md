# Silver Bullet Sessions

- url: https://www.tradingview.com/script/G6PTNndk-silver-bullet-sessions/
- type: indicator
- pine_id: PUB;8cb6df882daa4ca3b964e0c5c2cfd761
- version: 1.0

## Description

# Silver Bullet Sessions

Highlights the key intraday trading sessions used in the **Silver Bullet / SMC (Smart Money Concepts)** methodology. Each session is color-coded as a vertical band directly on the chart, making it easy to identify high-probability trading windows at a glance.

---

## Sessions (New York time)

| Color | Session | Time (ET) |
|-------|---------|-----------|
| 🟡 Yellow | Pre-Market / Open | 09:30 – 10:10 |
| 🔵 Blue | Silver Bullet 1 | 10:10 – 12:00 |
| 🟠 Orange | Lunch / Low Volume | 12:00 – 13:00 |
| 🟢 Green | Silver Bullet 2 (open) | 13:00 – 13:10 |
| 🟡 Yellow | Silver Bullet 2 (core) | 13:10 – 13:40 |
| 🟢 Green | Afternoon / Close | 13:40 – 16:00 |

---

## How it works

- **Historical bars** — sessions are colored using `bgcolor`, which paints every processed candle in the correct color. Works on all past data regardless of timeframe.
- **Future bars** — session boxes are drawn 21 calendar days forward (weekends skipped automatically), so you can always see upcoming session structure without scrolling.
- **Bar Replay (backtesting)** — fully compatible. As you step through history, the future boxes update in real time relative to the current replay position.

---

## Notes

- Works on any timeframe and any instrument with US market hours (indices, futures, forex pairs with US session overlap).
- The yellow Pre-Market band and the two Silver Bullet windows are the primary entry zones in ICT / SMC strategies — look for Fair Value Gaps (FVGs) and liquidity sweeps inside these bands.
- No inputs to configure — sessions are fixed to New York time via the `America/New_York` timezone, so daylight saving time is handled automatically.

## Source Code

````pine
//@version=6
indicator("Silver Bullet Sessions", overlay=true, max_boxes_count=500)

string tz  = "America/New_York"
int    DAY = 86400000

// Session offsets from midnight ET (ms)
int T_930  = 34200000   // 09:30 ET
int T_1010 = 36600000   // 10:10 ET
int T_1200 = 43200000   // 12:00 ET
int T_1300 = 46800000   // 13:00 ET
int T_1310 = 47400000   // 13:10 ET
int T_1340 = 49200000   // 13:40 ET
int T_1600 = 57600000   // 16:00 ET

float TOP = 100000.0
float BOT = 0.0

// ── HISTORICAL bgcolor (colors real candles on history) ────────────────────
int hmET = hour(time, tz) * 60 + minute(time, tz)
bgcolor(hmET >= 9*60+30  and hmET < 10*60+10 ? color.new(color.yellow, 75) : na)
bgcolor(hmET >= 10*60+10 and hmET < 12*60    ? color.new(color.blue,   82) : na)
bgcolor(hmET >= 12*60    and hmET < 13*60    ? color.new(color.orange, 82) : na)
bgcolor(hmET >= 13*60    and hmET < 13*60+10 ? color.new(color.green,  82) : na)
bgcolor(hmET >= 13*60+10 and hmET < 13*60+40 ? color.new(color.yellow, 75) : na)
bgcolor(hmET >= 13*60+40 and hmET < 16*60    ? color.new(color.green,  82) : na)

// ── SESSION BOXES ──────────────────────────────────────────────────────────
// At barstate.islast: draw boxes from 3 days back to 21 days forward.
// In Bar Replay (simulator): barstate.islast = current replay bar → works perfectly.
// In live mode: barstate.islast = last pre-rendered bar (~12 days ahead) → boxes
// appear from that point forward (same limitation as before).

int dayStart = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 0, 0)

var array<box> bxs = array.new<box>()

if barstate.islast
    for b in bxs
        box.delete(b)
    array.clear(bxs)

    for i = 1 to 21
        int s   = dayStart + i * DAY
        int dow = dayofweek(s, tz)
        // Skip weekends
        if dow != dayofweek.saturday and dow != dayofweek.sunday
            array.push(bxs, box.new(s+T_930,  TOP, s+T_1010, BOT, xloc=xloc.bar_time, border_color=color.new(color.yellow, 100), bgcolor=color.new(color.yellow, 75)))
            array.push(bxs, box.new(s+T_1010, TOP, s+T_1200, BOT, xloc=xloc.bar_time, border_color=color.new(color.blue,   100), bgcolor=color.new(color.blue,   82)))
            array.push(bxs, box.new(s+T_1200, TOP, s+T_1300, BOT, xloc=xloc.bar_time, border_color=color.new(color.orange, 100), bgcolor=color.new(color.orange, 82)))
            array.push(bxs, box.new(s+T_1300, TOP, s+T_1310, BOT, xloc=xloc.bar_time, border_color=color.new(color.green,  100), bgcolor=color.new(color.green,  82)))
            array.push(bxs, box.new(s+T_1310, TOP, s+T_1340, BOT, xloc=xloc.bar_time, border_color=color.new(color.yellow, 100), bgcolor=color.new(color.yellow, 75)))
            array.push(bxs, box.new(s+T_1340, TOP, s+T_1600, BOT, xloc=xloc.bar_time, border_color=color.new(color.green,  100), bgcolor=color.new(color.green,  82)))
````
