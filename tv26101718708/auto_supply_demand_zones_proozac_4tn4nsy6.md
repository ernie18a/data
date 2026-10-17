# Auto Supply & Demand Zones [Proozac]

- url: https://www.tradingview.com/script/4TN4nsy6-Auto-Supply-Demand-Zones-Proozac/
- type: indicator
- pine_id: PUB;de3202b49d4649a58c9da5503b6eaa74
- version: 1.0

## Description

# Auto Supply & Demand Zones

**Pine Script v6 — Overlay Indicator**

---

## What It Does

Automatically identifies and draws **Supply** and **Demand** zones using a consolidation-then-impulse approach. Instead of drawing arbitrary rectangles around wicks or candles, this indicator marks the precise origin of impulsive moves — the base where institutions accumulated or distributed positions before the explosive move began.

Zones update dynamically: they extend to the current bar as long as they are active, fade when price re-enters them (tested), and can be removed automatically when fully mitigated.

---

## Core Concept

Supply and Demand zones are based on the observation that before a strong directional move, price always consolidates in a narrow range. This consolidation is where orders were placed. When price eventually returns to that origin area, those resting orders become relevant again.

```
DEMAND ZONE (base before impulsive UP move)
────────────────────────────────────
   [consolidation base]  ← zone drawn here
   ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑   ← impulsive bullish candle

SUPPLY ZONE (base before impulsive DOWN move)
   ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓   ← impulsive bearish candle
   [consolidation base]  ← zone drawn here
────────────────────────────────────
```

---

## Detection Logic

### Step 1 — Identify the Base (Consolidation)

A "base" is a sequence of `Consolidation Bars` consecutive candles where every candle body is **smaller than the ATR**:

```
For each candle in the base window:
    body = |close - open|
    if body > ATR → not a base
```

This filters out directional candles and keeps only tight, sideways price action — the footprint of institutional accumulation/distribution.

### Step 2 — Detect the Impulse

An impulse candle is a strong directional candle **immediately after** the base:

```
Bullish impulse:  base confirmed  AND  close > open  AND  (close - open) > ATR × Impulse Strength
Bearish impulse:  base confirmed  AND  close < open  AND  (open - close) > ATR × Impulse Strength
```

The `Impulse Strength` multiplier controls how strong the breakout candle must be relative to ATR. At 1.5× ATR, only genuinely strong moves qualify.

### Step 3 — Draw the Zone

The zone is drawn over the **range of the consolidation base** (highest high to lowest low across all base candles):

```
Zone top    = max(high) across base candles
Zone bottom = min(low)  across base candles
```

- Bullish impulse → **Demand zone** (green box)
- Bearish impulse → **Supply zone** (red box)

---

## Zone Lifecycle

| State | Visual | Condition |
|-------|--------|-----------|
| **Active** | Full color, solid border | Price has not returned to the zone |
| **Tested** | Price is currently inside the zone | Background flashes, border highlights |
| **Mitigated** | Faded to high transparency | Price closed through the zone's far edge |
| **Deleted** | Removed from chart | Only if "Keep Tested Zones" is off |

Zone mitigation rules:
- Demand zone → mitigated when `low < zone bottom` (price broke below it)
- Supply zone → mitigated when `high > zone top` (price broke above it)

---

## Inputs

| Input | Default | Description |
|-------|---------|-------------|
| **Consolidation Bars** | 3 | Number of tight candles required to form a base. More bars = stricter, rarer zones |
| **Impulse Strength (×ATR)** | 1.5 | How strong the breakout candle must be vs ATR. Higher = stronger impulses only |
| **ATR Length** | 14 | Period for the ATR used in base and impulse detection |
| **Max Active Zones** | 10 | Maximum number of zones kept per side (oldest removed first) |
| **Demand Zone Color** | Teal/green | Fill color for demand zones |
| **Supply Zone Color** | Red | Fill color for supply zones |
| **Demand/Supply Border** | Darker tint | Border color |
| **Tested Zone Transparency** | 92 | Opacity of mitigated zones (higher = more transparent) |
| **Show Zone Labels** | true | Draws "Demand" / "Supply" text inside each box |
| **Keep Tested Zones (Faded)** | true | When off, mitigated zones are deleted entirely |

---

## Visual Output

| Element | Description |
|---------|-------------|
| Green box | Active demand zone (base of a bullish impulse) |
| Red box | Active supply zone (base of a bearish impulse) |
| Faded green box | Demand zone that has been mitigated |
| Faded red box | Supply zone that has been mitigated |
| Green triangle below bar | New demand zone created this bar |
| Red triangle above bar | New supply zone created this bar |
| Green background flash | Price is currently inside a demand zone |
| Red background flash | Price is currently inside a supply zone |

---

## How to Use

**Basic trade setup:**

1. Wait for price to return to an active zone.
2. Look for a confirmation signal inside the zone — a rejection candle, a sweep of the zone's inner extreme, or a divergence from an oscillator.
3. Enter with a stop beyond the zone's outer edge.
4. Target the next supply zone (from demand) or next demand zone (from supply).

**Confluence checklist:**
- Zone is fresh (not previously tested)
- Zone aligns with a higher timeframe level
- MTF Dashboard (indicator 02) shows agreement on the entry direction
- A Liquidity Sweep (indicator 03) fired near the zone entry

**Zone freshness matters:** The first time price returns to a zone, the fill rate is significantly higher than on second or third tests. After a zone is mitigated, treat it as much weaker.

---

## Configuration Tips

| Scenario | Suggested settings |
|----------|--------------------|
| Clean, infrequent zones | Consolidation: 4–5, Impulse: 2.0× |
| More zones, active markets | Consolidation: 2, Impulse: 1.2× |
| Crypto (volatile, wide spreads) | ATR: 20, Impulse: 2.0–2.5× |
| Forex (tight spreads) | ATR: 14, Impulse: 1.5× |
| Equities / indices | ATR: 14, Impulse: 1.5–2.0× |

---

## Alerts

Two built-in `alertcondition` entries:
- `Price in Demand Zone` — fires on every bar where close is inside an active demand zone
- `Price in Supply Zone` — fires on every bar where close is inside an active supply zone

Recommended alert settings: **Once per bar close** to avoid repeated triggers within the same bar.

## Source Code

````pine
//@version=6
// Auto Supply & Demand Zones — consolidation-then-impulse detection
indicator("Auto Supply & Demand Zones", shorttitle="S&D Zones", overlay=true, max_boxes_count=500)

// ── Inputs ────────────────────────────────────────────────────────────────────
g1 = "Zone Detection"
base_len     = input.int(3,   "Consolidation Bars", group=g1, minval=2, maxval=10)
impulse_mult = input.float(1.5, "Impulse Strength (xATR)", group=g1, minval=0.5, maxval=5.0, step=0.1)
atr_len      = input.int(14,  "ATR Length", group=g1, minval=1)
max_zones    = input.int(10,  "Max Active Zones", group=g1, minval=3, maxval=30)

g2 = "Zone Colors"
demand_col   = input.color(color.new(#26a69a, 75), "Demand Zone", group=g2)
supply_col   = input.color(color.new(#ef5350, 75), "Supply Zone", group=g2)
demand_brd   = input.color(color.new(#26a69a, 20), "Demand Border", group=g2)
supply_brd   = input.color(color.new(#ef5350, 20), "Supply Border", group=g2)
tested_alpha = input.int(92, "Tested Zone Transparency", group=g2, minval=70, maxval=99)

g3 = "Display"
show_labels    = input.bool(true, "Show Zone Labels", group=g3)
show_mitigated = input.bool(true, "Keep Tested Zones (Faded)", group=g3)

// ── Calculations ──────────────────────────────────────────────────────────────
atr = ta.atr(atr_len)

is_base(idx) =>
    result = true
    for i = 0 to base_len - 1
        body = math.abs(close[idx + i] - open[idx + i])
        if body > atr[idx + i]
            result := false
    result

bull_impulse = is_base(1) and close > open and (close - open) > impulse_mult * atr
bear_impulse = is_base(1) and close < open and (open - close) > impulse_mult * atr

// ── Zone arrays (right edge updated each bar — no extend.right) ───────────────
var box[] demand_boxes = array.new_box()
var box[] supply_boxes = array.new_box()

if bull_impulse
    zone_high = 0.0
    zone_low  = 999999999.0
    for i = 1 to base_len
        zone_high := math.max(zone_high, high[i])
        zone_low  := math.min(zone_low,  low[i])
    b = box.new(bar_index - base_len, zone_high, bar_index + 1, zone_low, bgcolor=demand_col, border_color=demand_brd, border_width=1, text=show_labels ? " Demand" : "", text_size=size.tiny, text_color=color.new(#26a69a, 0), text_halign=text.align_left, text_valign=text.align_top)
    array.unshift(demand_boxes, b)
    if array.size(demand_boxes) > max_zones
        box.delete(array.pop(demand_boxes))

if bear_impulse
    zone_high = 0.0
    zone_low  = 999999999.0
    for i = 1 to base_len
        zone_high := math.max(zone_high, high[i])
        zone_low  := math.min(zone_low,  low[i])
    b = box.new(bar_index - base_len, zone_high, bar_index + 1, zone_low, bgcolor=supply_col, border_color=supply_brd, border_width=1, text=show_labels ? " Supply" : "", text_size=size.tiny, text_color=color.new(#ef5350, 0), text_halign=text.align_left, text_valign=text.align_bottom)
    array.unshift(supply_boxes, b)
    if array.size(supply_boxes) > max_zones
        box.delete(array.pop(supply_boxes))

// ── Update right edge and check mitigation ────────────────────────────────────
in_demand = false
in_supply = false

if array.size(demand_boxes) > 0
    for i = array.size(demand_boxes) - 1 to 0
        b     = array.get(demand_boxes, i)
        top_  = box.get_top(b)
        bot_  = box.get_bottom(b)
        box.set_right(b, bar_index + 1)
        if low < bot_
            if show_mitigated
                box.set_bgcolor(b, color.new(#26a69a, tested_alpha))
                box.set_border_color(b, color.new(#26a69a, 80))
            else
                box.delete(b)
                array.remove(demand_boxes, i)
        else if close >= bot_ and close <= top_
            in_demand := true

if array.size(supply_boxes) > 0
    for i = array.size(supply_boxes) - 1 to 0
        b     = array.get(supply_boxes, i)
        top_  = box.get_top(b)
        bot_  = box.get_bottom(b)
        box.set_right(b, bar_index + 1)
        if high > top_
            if show_mitigated
                box.set_bgcolor(b, color.new(#ef5350, tested_alpha))
                box.set_border_color(b, color.new(#ef5350, 80))
            else
                box.delete(b)
                array.remove(supply_boxes, i)
        else if close >= bot_ and close <= top_
            in_supply := true

// ── Signals ───────────────────────────────────────────────────────────────────
plotshape(bull_impulse, "New Demand Zone", shape.triangleup,   location.belowbar, #26a69a, size=size.tiny)
plotshape(bear_impulse, "New Supply Zone", shape.triangledown, location.abovebar, #ef5350, size=size.tiny)

zone_bg = in_demand ? color.new(#26a69a, 94) : in_supply ? color.new(#ef5350, 94) : na
bgcolor(zone_bg, title="Zone Touch Background")

alertcondition(in_demand, "Price in Demand Zone", "{{ticker}} — Price entering demand zone on {{interval}}")
alertcondition(in_supply, "Price in Supply Zone", "{{ticker}} — Price entering supply zone on {{interval}}")
````
