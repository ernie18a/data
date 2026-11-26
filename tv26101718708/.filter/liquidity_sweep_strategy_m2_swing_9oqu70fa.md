# Liquidity sweep strategy (M2, swing)

- url: https://www.tradingview.com/script/9OQU70Fa-Liquidity-sweep-strategy-M2-swing/
- type: indicator
- pine_id: PUB;6da1045d6d5a4593abfb6f23f00a437e
- version: 1.0

## Description

This indicator automates advanced Smart Money Concepts (SMC) by tracking major session liquidity sweeps, precise market structure shifts (CHOCH), and optimal trade entries using dynamic Fibonacci retracements.

Built for intraday traders, this script eliminates the noise and visually guides you through the entire institutional order flow cycle—from the initial liquidity grab to the final pullback entry.

🔥 Key Features:

🕒 Session Liquidity Sweeps: Automatically tracks and highlights the Highs and Lows of the Asian, London, and NY Initial Balance (IB) sessions. The script patiently waits for price to sweep these key liquidity pools.

🔍 Advanced CHOCH Detection (M2 Method): Instead of relying solely on lagging fractals, this script introduces the "M2 Method." It identifies the exact sponsor candle/FVG that engineered the liquidity sweep. A valid Change of Character (CHOCH) is only confirmed when price cleanly breaks this specific structural point. (Traditional N-period Fractal CHOCH is also available in the settings).

🎯 Dynamic "Rubber" Fibonacci Entries: Once a CHOCH is confirmed, the script doesn't just guess the entry. It anchors a dynamic Fibonacci tool to the extreme of the sweep and trails the momentum wave. It waits for a precise 50% retracement (Premium/Discount pricing) to trigger the entry limit, drawing target and risk boxes automatically.

👁️ Clean Visuals: Uncluttered charts. The script only draws Fibo lines and Risk/Reward boxes when a high-probability setup is fully confirmed.

⚙️ How it works (The 3-Step Institutional Model):

Sweep: Price sweeps a major session High/Low.

Shift: Price breaks the M2 sponsor candle (CHOCH), confirming a shift in momentum.

Mitigation: Price pulls back to the dynamic 50% Equilibrium level for optimal entry.

Perfect for prop firm traders and SMC enthusiasts looking to systemize their execution and train their eyes on mechanical setups.

## Source Code

````pine
//@version=6
indicator("All POIs: SMC Visualizer (Dynamic Fibo + M2)", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

entry_mode = input.string("M2 Svíčka (< 50%)", title="Metoda průrazu (CHOCH)", options=["Swing (Fraktál)", "M2 Svíčka (< 50%)"], group="Nastavení struktury")
n = input.int(2, title="Perioda Swingu (pro metodu Swing)", minval=1, maxval=5, group="Nastavení struktury")
show_m2 = input.bool(true, title="Zvýraznit vybranou M2 svíčku žlutě?", group="Nastavení struktury")
tz = input.string("Europe/Prague", "Časové pásmo", group="Nastavení struktury")

in_asia = not na(time(timeframe.period, "0100-0900", tz))
in_lon  = not na(time(timeframe.period, "0900-1530", tz))
in_ib   = not na(time(timeframe.period, "1530-1630", tz))

bool new_day = ta.change(time("D", tz)) != 0

float pl = ta.pivotlow(low, n, n)
float ph = ta.pivothigh(high, n, n)

float curr_sw_l_val = not na(pl) ? pl : na
int curr_sw_l_idx = not na(pl) ? bar_index - n : na
float curr_sw_h_val = not na(ph) ? ph : na
int curr_sw_h_idx = not na(ph) ? bar_index - n : na

find_m2(int dir, int extreme_idx) =>
    float r_val = na
    int   r_idx = na
    float r_m2h = na
    float r_m2l = na
    int bars_back = bar_index - extreme_idx
    int found = 0

    if bars_back >= 0
        for i = bars_back + 1 to bars_back + 150
            if found == 0
                float mid = low[i] + (high[i] - low[i]) * 0.5
                bool is_candidate = (dir == 1 and close[i] < mid) or (dir == -1 and close[i] > mid)

                if is_candidate
                    // j prochází svíčky MEZI touto kandidátkou a extémem
                    // bars_back = extrém, i-1 = svíčka těsně před kandidátkou
                    // Hledáme zda ALESPOŇ JEDNA z nich se nedotýká kandidátky
                    bool has_untouched = false
                    if i > bars_back + 1  // Musí být aspoň jedna svíčka mezi nimi
                        for j = bars_back + 1 to i - 1
                            if dir == 1 and low[j] > high[i]
                                has_untouched := true
                            else if dir == -1 and high[j] < low[i]
                                has_untouched := true
                    
                    if has_untouched
                        r_val  := dir == 1 ? low[i] : high[i]
                        r_idx  := bar_index - i
                        r_m2h  := high[i]
                        r_m2l  := low[i]
                        found  := 1

    [r_val, r_idx, r_m2h, r_m2l]

type POI
    string name
    int dir
    float lvl
    int state
    float ext_val
    int ext_idx
    float sw_val
    int sw_idx
    float m2_h
    float m2_l
    float pull_ext
    int pull_idx

method process_poi(POI p, bool active_sess) =>

    if (p.state == 0 or p.state == 1) and entry_mode == "Swing (Fraktál)"
        if p.dir == 1 and not na(curr_sw_l_val)
            p.sw_val := curr_sw_l_val
            p.sw_idx := curr_sw_l_idx
        else if p.dir == -1 and not na(curr_sw_h_val)
            p.sw_val := curr_sw_h_val
            p.sw_idx := curr_sw_h_idx

    if not active_sess and not na(p.lvl)

        if p.state == 0
            if p.dir == 1 and high > p.lvl
                p.state   := 1
                p.ext_val := high
                p.ext_idx := bar_index
                if entry_mode == "M2 Svíčka (< 50%)"
                    [v, i, h, l] = find_m2(1, p.ext_idx)
                    p.sw_val := v
                    p.sw_idx := i
                    p.m2_h   := h
                    p.m2_l   := l
                    if not na(p.sw_val) and show_m2
                        box.new(p.sw_idx, p.m2_h, p.sw_idx + 3, p.m2_l, border_color=color.yellow, bgcolor=color.new(color.yellow, 80))
                        label.new(p.sw_idx, p.m2_h, "M2↓", color=color.yellow, textcolor=color.black, size=size.small)

            else if p.dir == -1 and low < p.lvl
                p.state   := 1
                p.ext_val := low
                p.ext_idx := bar_index
                if entry_mode == "M2 Svíčka (< 50%)"
                    [v, i, h, l] = find_m2(-1, p.ext_idx)
                    p.sw_val := v
                    p.sw_idx := i
                    p.m2_h   := h
                    p.m2_l   := l
                    if not na(p.sw_val) and show_m2
                        box.new(p.sw_idx, p.m2_h, p.sw_idx + 3, p.m2_l, border_color=color.yellow, bgcolor=color.new(color.yellow, 80))
                        label.new(p.sw_idx, p.m2_l, "M2↑", color=color.yellow, textcolor=color.black, size=size.small, style=label.style_label_up)

        else if p.state == 1
            bool new_extreme = false
            if p.dir == 1 and high > p.ext_val
                p.ext_val   := high
                p.ext_idx   := bar_index
                new_extreme := true
            else if p.dir == -1 and low < p.ext_val
                p.ext_val   := low
                p.ext_idx   := bar_index
                new_extreme := true

            if new_extreme and entry_mode == "M2 Svíčka (< 50%)"
                [v, i, h, l] = find_m2(p.dir, p.ext_idx)
                p.sw_val := v
                p.sw_idx := i
                p.m2_h   := h
                p.m2_l   := l
                if not na(p.sw_val) and show_m2
                    box.new(p.sw_idx, p.m2_h, p.sw_idx + 3, p.m2_l, border_color=color.yellow, bgcolor=color.new(color.yellow, 80))
                    label.new(p.sw_idx, p.m2_h, "M2", color=color.yellow, textcolor=color.black, size=size.small)

            if not na(p.sw_val)
                if p.dir == 1 and close < p.sw_val
                    p.state    := 2
                    p.pull_ext := low
                    p.pull_idx := bar_index
                else if p.dir == -1 and close > p.sw_val
                    p.state    := 2
                    p.pull_ext := high
                    p.pull_idx := bar_index

        else if p.state == 2
            if p.dir == 1
                if high > p.ext_val
                    p.state   := 1
                    p.ext_val := high
                    p.ext_idx := bar_index
                else
                    if low < p.pull_ext
                        p.pull_ext := low
                        p.pull_idx := bar_index

                    float entry_p  = p.ext_val - ((p.ext_val - p.pull_ext) * 0.5)
                    float risk     = p.ext_val - entry_p
                    float target_p = entry_p - (risk * 2)

                    if high >= entry_p and p.pull_ext < p.ext_val and bar_index > p.pull_idx
                        p.state := 3
                        line.new(p.sw_idx,   p.sw_val,   p.pull_idx,      p.sw_val,   color=color.orange, style=line.style_dotted, width=2)
                        line.new(p.ext_idx,  p.ext_val,  p.pull_idx,      p.pull_ext, color=color.gray,   style=line.style_dashed)
                        line.new(p.pull_idx, entry_p,    p.pull_idx + 20, entry_p,    color=color.blue,   width=2)
                        box.new(p.pull_idx,  p.ext_val,  p.pull_idx + 20, entry_p,    border_color=color.new(color.red,   100), bgcolor=color.new(color.red,   80))
                        box.new(p.pull_idx,  entry_p,    p.pull_idx + 20, target_p,   border_color=color.new(color.green, 100), bgcolor=color.new(color.green, 80))

            else if p.dir == -1
                if low < p.ext_val
                    p.state   := 1
                    p.ext_val := low
                    p.ext_idx := bar_index
                else
                    if high > p.pull_ext
                        p.pull_ext := high
                        p.pull_idx := bar_index

                    float entry_p  = p.ext_val + ((p.pull_ext - p.ext_val) * 0.5)
                    float risk     = entry_p - p.ext_val
                    float target_p = entry_p + (risk * 2)

                    if low <= entry_p and p.pull_ext > p.ext_val and bar_index > p.pull_idx
                        p.state := 3
                        line.new(p.sw_idx,   p.sw_val,   p.pull_idx,      p.sw_val,   color=color.orange, style=line.style_dotted, width=2)
                        line.new(p.ext_idx,  p.ext_val,  p.pull_idx,      p.pull_ext, color=color.gray,   style=line.style_dashed)
                        line.new(p.pull_idx, entry_p,    p.pull_idx + 20, entry_p,    color=color.blue,   width=2)
                        box.new(p.pull_idx,  entry_p,    p.pull_idx + 20, p.ext_val,  border_color=color.new(color.red,   100), bgcolor=color.new(color.red,   80))
                        box.new(p.pull_idx,  target_p,   p.pull_idx + 20, entry_p,    border_color=color.new(color.green, 100), bgcolor=color.new(color.green, 80))

    int _dummy = 0

var POI aH = POI.new("Asia High",  1, na, 0, na, na, na, na, na, na, na, na)
var POI aL = POI.new("Asia Low",  -1, na, 0, na, na, na, na, na, na, na, na)
var POI lH = POI.new("Lon High",   1, na, 0, na, na, na, na, na, na, na, na)
var POI lL = POI.new("Lon Low",   -1, na, 0, na, na, na, na, na, na, na, na)
var POI iH = POI.new("IB High",    1, na, 0, na, na, na, na, na, na, na, na)
var POI iL = POI.new("IB Low",    -1, na, 0, na, na, na, na, na, na, na, na)

if new_day
    aH.lvl := na, aH.state := 0
    aL.lvl := na, aL.state := 0
    lH.lvl := na, lH.state := 0
    lL.lvl := na, lL.state := 0
    iH.lvl := na, iH.state := 0
    iL.lvl := na, iL.state := 0

if in_asia
    aH.lvl := na(aH.lvl) ? high : math.max(aH.lvl, high)
    aL.lvl := na(aL.lvl) ? low  : math.min(aL.lvl, low)
if in_lon
    lH.lvl := na(lH.lvl) ? high : math.max(lH.lvl, high)
    lL.lvl := na(lL.lvl) ? low  : math.min(lL.lvl, low)
if in_ib
    iH.lvl := na(iH.lvl) ? high : math.max(iH.lvl, high)
    iL.lvl := na(iL.lvl) ? low  : math.min(iL.lvl, low)

aH.process_poi(in_asia)
aL.process_poi(in_asia)
lH.process_poi(in_lon)
lL.process_poi(in_lon)
iH.process_poi(in_ib)
iL.process_poi(in_ib)

plot(na)
````
