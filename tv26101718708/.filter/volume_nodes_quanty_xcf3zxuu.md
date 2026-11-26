# Volume Nodes [Quanty]

- url: https://www.tradingview.com/script/xCf3zXuu-Volume-Nodes-Quanty/
- type: indicator
- pine_id: PUB;cb4289bdbe1f469891189510c9381780
- version: 1.0

## Description

[b]Volume Nodes[/b] marks the price zones where trading volume piled up, using two views of the same volume at once.

[b]Horizontal:[/b] a volume profile of the window (the last 450 candles by default, or as many as the chart has loaded) on the right of the chart; its densest rows are highlighted.
[b]Vertical:[/b] each candle's volume at the bottom, for up to the last 450 candles; heavy candles (2x the average of the previous 50) are highlighted.

A node is a heavy candle whose typical price sat in the densest rows of the profile of the 200 candles before it (adjustable). Thin dotted lines join the newest nodes to their volume column and to their profile row.

Zones are the price rows that are dense in the profile or hold a cluster of nodes. Shading is a gradient: the more nodes around a row, the darker it is. The label shows how many nodes sit inside a zone. The table lists the zones nearest to price, their distance and whether they sit above or below it.

How we checked: we tested single node levels as a fixed rule against random levels, and they did not hold more often than chance. So this is a map of where volume sat, not a signal. Zones that hold and zones that break are both common.

[b]Settings:[/b] window length, node search window, volume average, heavy-volume multiple, profile rows, share of dense rows, profile width and gap, colours, zones on or off, table on or off.

Nodes are found on closed candles and do not repaint; the profile and the zones include the forming candle and update with it. On forex and CFDs the volume is tick volume.

[b]Data, not advice.[/b]

## Source Code

````pine
//@version=6
// Volume Nodes [Quanty] - v0.2 - 15 Oct 2026 (Dreamer; Ata's 13 Oct idea: where a vertical volume spike meets the dense
// zone of the horizontal volume profile). v0.2 (Ata): both volumes opened up on the chart, thin lines from each
// anomaly to its node. Rule as in edge exam #21 (ONKAYIT). For Ata's visual review; awaiting first compile.
indicator("Volume Nodes [Quanty]", shorttitle="Quanty NODES", overlay=true, max_lines_count=500, max_boxes_count=250,
     max_labels_count=120, max_bars_back=5000)

// A node is a closed candle with heavy volume (at least 2x the average of the previous 50 candles) whose typical
// price sits in the densest rows of the volume profile of the previous window (450 candles by default; the #21 exam used 200).
// On the chart, for the same window (Ata's terms: the profile is the vertical volume, candle volume the horizontal one):
//   - right:  the volume profile of the window, stuck to the right edge and growing leftwards, clear of the candles;
//   - bottom: each candle's volume as a thin column, heavy candles highlighted;
//   - each node is a small circle, joined by thin dotted lines to its volume column below and to its profile row.
// Nodes are found on closed candles; nothing repaints. The profile on the right is today's; each node was found with
// the profile of the 200 candles before it, so an older node's row can look less dense now.

int   avgLen = input.int(50, "Volume average (bars)", minval=10, maxval=200)
float spikeK = input.float(2.0, "Volume spike (x average)", minval=1.2, maxval=10.0, step=0.1)
int   profN  = input.int(450, "Window (bars)", minval=50, maxval=5000,
     tooltip="One window for the volume profile, the zones and the node search (each node uses the profile of the window before it). Longer than the loaded history works too: the chart's candles are used. The volume columns at the bottom show at most the last 450 bars (500 lines per script).")
int   rows   = input.int(50, "Profile rows", minval=10, maxval=100)
float denseP = input.float(20.0, "Dense rows (% of rows)", minval=5.0, maxval=50.0, step=1.0)
int   profW  = input.int(60, "Profile width (bars)", minval=10, maxval=200)
int   gapR   = input.int(14, "Gap between the last candle and the profile (bars)", minval=6, maxval=80)
bool  zones  = input.bool(true, "Support/resistance zones (dense rows or node clusters; darker = more nodes)")
bool  drawOn = input.bool(true, "Draw on the chart (volume, profile, nodes, zones)")
bool  tblOn  = input.bool(true, "Zones table")
string tblPos = input.string("Top right", "Table position", options=["Top right", "Top left", "Bottom right", "Bottom left"])
color colA   = input.color(#E7B65C, "Spikes, dense rows and nodes")
color colG   = input.color(#5D6573, "Other volume")

float avgV  = ta.sma(volume, avgLen)[1]
int   nodeN = input.int(200, "Node search window (bars)", minval=50, maxval=450,
     tooltip="Each node is tested against the profile of this many candles before it. Shorter finds nodes sooner in a new price range.")
float pLo   = ta.lowest(low, nodeN)[1]
float pHi   = ta.highest(high, nodeN)[1]
bool  spike = not na(avgV) and avgV > 0 and volume >= spikeK * avgV
float atr14 = ta.atr(14)

// volume profile of candles [from .. from+profN-1] bars back, price range lo..hi, rows rows
f_profile(int from, int len, float lo, float hi) =>
    float st = (hi - lo) / rows
    array<float> prof = array.new<float>(rows, 0.0)
    for j = from to from + len - 1
        int b0 = math.max(0, math.min(rows - 1, int(math.floor((low[j] - lo) / st))))
        int b1 = math.max(0, math.min(rows - 1, int(math.floor((high[j] - lo) / st))))
        float share = nz(volume[j]) / (b1 - b0 + 1)
        for b = b0 to b1
            prof.set(b, prof.get(b) + share)
    prof

f_threshold(array<float> prof) =>
    array<float> srt = prof.copy()
    srt.sort(order.descending)
    srt.get(math.max(1, int(math.round(rows * denseP / 100.0))) - 1)

f_isDense(float p, float lo, float hi) =>
    array<float> prof = f_profile(1, nodeN, lo, hi)
    int bp = math.max(0, math.min(rows - 1, int(math.floor((p - lo) / ((hi - lo) / rows)))))
    prof.get(bp) >= f_threshold(prof)

// nodes (v6 and/or are lazy: the profile is built only on heavy candles)
bool isNode = barstate.isconfirmed and spike and bar_index > nodeN and not na(pLo) and pHi > pLo and f_isDense(hlc3, pLo, pHi)
var array<float> nodeP = array.new<float>()
var array<int>   nodeB = array.new<int>()
if isNode
    nodeP.push(hlc3)
    nodeB.push(bar_index)
    if nodeP.size() > 300
        nodeP.shift()
        nodeB.shift()

alertcondition(isNode, "New volume node", "{{ticker}} {{interval}}: new volume node at {{close}}")

// drawing: rebuilt on the last bar
var array<line>  dL = array.new<line>()
var array<box>   dB = array.new<box>()
var array<label> dT = array.new<label>()

if barstate.islast and bar_index > 50
    for x in dL
        line.delete(x)
    for x in dB
        box.delete(x)
    for x in dT
        label.delete(x)
    dL.clear()
    dB.clear()
    dT.clear()
    // the window can be longer than the loaded history: use what the chart has
    int   effN = math.min(profN, bar_index + 1)
    float lo   = low
    float hi   = high
    float vmx  = 0.0
    for j = 0 to effN - 1
        lo  := math.min(lo, low[j])
        hi  := math.max(hi, high[j])
        vmx := math.max(vmx, nz(volume[j]))
    float rng = hi - lo
    if rng > 0
        // candle volume: thin columns under the price of the same window
        float base = lo - 0.20 * rng
        float top  = lo - 0.03 * rng
        float vmax = math.max(vmx, 1e-10)
        int volCols = math.min(effN, 450)
        if drawOn
            for j = 0 to volCols - 1
                float h = base + (top - base) * nz(volume[j]) / vmax
                bool  s = spike[j]
                dL.push(line.new(bar_index - j, base, bar_index - j, h, color=s ? colA : color.new(colG, 40), width=2))
        // horizontal volume: profile of the same candles, to the right of price
        array<float> prof = f_profile(0, effN, lo, hi)
        float thr  = f_threshold(prof)
        float pmax = prof.max()
        float st   = rng / rows
        int   xR   = bar_index + gapR + profW         // profile sticks to the right edge and grows leftwards, clear of the candles
        array<int> pw = array.new<int>(rows, 0)
        for b = 0 to rows - 1
            float pv = prof.get(b)
            if pv > 0
                int w = math.max(1, int(math.round(profW * pv / pmax)))
                pw.set(b, w)
                bool dn = pv >= thr
                if drawOn
                    dB.push(box.new(xR - w, lo + (b + 0.9) * st, xR, lo + b * st, border_color=color(na),
                         bgcolor=dn ? color.new(colA, 20) : color.new(colG, 45)))
        // nodes in the window: circle + thin dotted lines to their volume column and to the profile
        // nodes, newest first: circle + thin dotted lines to their volume column and to their profile row
        int shown = 0
        int k = nodeB.size() - 1
        while drawOn and k >= 0 and shown < 15
            int b = nodeB.get(k)
            if b <= bar_index - volCols
                break
            shown += 1
            float p  = nodeP.get(k)
            float vh = base + (top - base) * nz(volume[bar_index - b]) / vmax
            dL.push(line.new(b, vh, b, p, color=color.new(colA, 15), style=line.style_dotted, width=1))
            if p >= lo and p <= hi
                int bp = math.max(0, math.min(rows - 1, int(math.floor((p - lo) / st))))
                dL.push(line.new(b, p, xR - pw.get(bp), p, color=color.new(colA, 15), style=line.style_dotted, width=1))
            dT.push(label.new(b, p, "●", style=label.style_none, textcolor=colA, size=size.small))
            k -= 1
        // support/resistance zones: rows that are dense in the profile OR hold a node cluster (2+ nodes in the row and its
        // neighbours); runs of such rows (a one-row gap joins them) start at the first candle of the window that traded in
        // the band. Shading is a gradient row by row: the more nodes around a row, the darker it is. Label = nodes inside.
        array<float> zLo = array.new<float>()
        array<float> zHi = array.new<float>()
        array<int>   zN  = array.new<int>()
        if zones or tblOn
            array<float> cnt = array.new<float>(rows, 0.0)
            for [q, nb] in nodeB
                float np = nodeP.get(q)
                if nb > bar_index - profN and np >= lo and np <= hi
                    int rb = math.max(0, math.min(rows - 1, int(math.floor((np - lo) / st))))
                    cnt.set(rb, cnt.get(rb) + 1)
            int r0 = -1
            int rl = -1
            int gp = 0
            for b = 0 to rows
                bool on = false
                if b < rows
                    float c3 = cnt.get(b) + (b > 0 ? cnt.get(b - 1) : 0.0) + (b < rows - 1 ? cnt.get(b + 1) : 0.0)
                    on := prof.get(b) >= thr or c3 >= 2
                if on
                    if r0 < 0
                        r0 := b
                    gp := 0
                    rl := b
                else if r0 >= 0
                    gp += 1
                    if gp > 1 or b == rows
                        float y0 = lo + r0 * st
                        float y1 = lo + (rl + 1) * st
                        int xs = bar_index
                        for j = effN - 1 to 0
                            if low[j] <= y1 and high[j] >= y0
                                xs := bar_index - j
                                break
                        float kz = 0.0
                        for rr = r0 to rl
                            kz += cnt.get(rr)
                        zLo.push(y0)
                        zHi.push(y1)
                        zN.push(int(kz))
                        if drawOn and zones
                            for rr = r0 to rl
                                float sm = cnt.get(rr) + 0.5 * ((rr > 0 ? cnt.get(rr - 1) : 0.0) + (rr < rows - 1 ? cnt.get(rr + 1) : 0.0))
                                int   tr = int(math.round(100 - math.min(55.0, 7.0 + 12.0 * sm)))
                                dB.push(box.new(xs, lo + (rr + 1) * st, bar_index + 3, lo + rr * st, border_color=color(na),
                                     bgcolor=color.new(colA, tr)))
                        if drawOn and zones
                            dB.push(box.new(xs, y1, bar_index + 3, y0, border_color=color.new(colA, 40), bgcolor=color(na)))
                        if drawOn and zones and kz > 0
                            dT.push(label.new(bar_index + 3, (y0 + y1) / 2, "x" + str.tostring(int(kz)), style=label.style_label_left,
                                 color=color(na), textcolor=chart.fg_color, size=size.small))
                        r0 := -1
                        gp := 0
        // zones table: nearest first; distance from the close to the zone edge
        if tblOn
            var table zt = table.new(tblPos == "Top left" ? position.top_left : tblPos == "Bottom right" ? position.bottom_right :
                 tblPos == "Bottom left" ? position.bottom_left : position.top_right, 4, 10, bgcolor=color.new(chart.bg_color, 0),
                 frame_color=color.new(chart.fg_color, 85), frame_width=1, border_color=color.new(chart.fg_color, 92), border_width=1)
            zt.clear(0, 0, 3, 9)
            zt.cell(0, 0, "Zone", text_color=colA, text_size=size.small, text_halign=text.align_left)
            zt.cell(1, 0, "Nodes", text_color=colA, text_size=size.small)
            zt.cell(2, 0, "Distance", text_color=colA, text_size=size.small)
            zt.cell(3, 0, "Side", text_color=colA, text_size=size.small)
            array<float> dist = array.new<float>()
            for [q, zl] in zLo
                float zh = zHi.get(q)
                dist.push(close > zh ? (close - zh) / close : close < zl ? (zl - close) / close : 0.0)
            array<int> ordz = dist.sort_indices(order.ascending)
            int rowN = math.min(ordz.size(), 9)
            for r = 0 to rowN - 1
                int   q  = ordz.get(r)
                float zl = zLo.get(q)
                float zh = zHi.get(q)
                string side = close > zh ? "support below" : close < zl ? "resistance above" : "price inside"
                zt.cell(0, r + 1, str.tostring(zl, format.mintick) + " - " + str.tostring(zh, format.mintick), text_color=chart.fg_color, text_size=size.small, text_halign=text.align_left)
                zt.cell(1, r + 1, str.tostring(zN.get(q)), text_color=chart.fg_color, text_size=size.small)
                zt.cell(2, r + 1, str.tostring(100 * dist.get(q), "#.##") + "%", text_color=chart.fg_color, text_size=size.small)
                zt.cell(3, r + 1, side, text_color=chart.fg_color, text_size=size.small)
````
