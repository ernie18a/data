<!-- tradingview-pine-id: PUB;4f71c0f336d24836bd36bbf80fdab942 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MICRO SOM

Source: https://www.tradingview.com/script/WrwdNkrH-MICRO-SOM/

## Description

What this is

A Kohonen Self-Organizing Map that learns market structure from scratch, with no labels, no backpropagation, and no predefined regimes. It builds a topological map of every market condition it has observed, then shows you where the current bar sits on that map.

This is unsupervised competitive learning — a fundamentally different approach from the neural networks usually seen on TradingView. Nothing here is trying to predict direction. It is trying to organize market states, and any predictive read is a byproduct you interpret afterward.

How it works

Each bar is encoded as a five-dimensional vector: distance from VWAP, trend-versus-chop efficiency, volatility state, relative volume, and momentum. All five are ATR-normalized so the map transfers across instruments.

Thirty-six nodes arranged in a 6×6 grid compete to be nearest that vector. The closest node wins — and critically, the winner and its grid neighbors shift toward the input, weighted by a Gaussian falloff.

That neighbor update is the entire mechanism. It forces adjacent nodes to represent similar market states, which is what turns 36 independent clusters into a genuine map. Remove it and this is just k-means.

The neighborhood radius decays over training. A wide radius early establishes global topology; a narrow radius later refines local detail. A fixed radius either never organizes or freezes into a poor layout within the first hundred bars.

The map trains on every confirmed bar. Filtering samples would distort the density it exists to represent.

Reading the display

A 6×6 grid renders to the right of price:

Teal — states that historically preceded upward movement
Red — states that preceded downward movement
Gray — neutral or insufficiently visited
Brightness — visit frequency and directional consistency
White border — the node matching the current bar

Watch the highlighted cell move. That is the market traversing learned state space in real time.

BIAS shows the average forward move that historically followed from the current node, in ATR units. This is measured after clustering, not optimized for — the map organized blind, then the script asked what tended to follow from each region.

NOVELTY is the Euclidean distance from the current bar to its nearest node. When it exceeds the 90th percentile of its own recent history, the chart tints orange and a diamond prints. This means current conditions resemble nothing the map has learned.

Why novelty may be the most useful output

Threshold rules cannot tell you when they are outside their domain. This can. An ALIEN reading is a direct signal that historical analogues are unavailable — typically the moment other models are least reliable and position size should be smallest.

Settings

Learn — adaptation rate. Higher adapts faster but organizes less stably.
Radius — initial neighborhood width. Larger enforces smoother global topology.
Decay — bars over which learning rate and radius anneal toward their floor.
Grid X / Grid Size — map placement and cell height in ATR units.

Honest limitations

The map requires roughly 1,200 bars to organize meaningfully. Before that, the topology is still unfolding and bias values are noise.

BIAS is a historical average, not a forecast. A node showing +0.4 ATR means bars in that region tended upward — it says nothing about the sample size behind that average or whether the relationship persists.

Five features cannot capture everything that matters. The map organizes what it is shown, and no more.

This is an analytical and visualization tool. It produces no entry or exit signals, and it is not financial advice.

Open source. The full algorithm is readable in the code, with the competitive learning step, neighborhood update, and radius annealing documented inline.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TheRealDrip2Rip

//@version=6
indicator("MICRO SOM", "µSOM", overlay=true, max_labels_count=100, max_boxes_count=60)

// ══════════════════════════════════════════════════════════════════════════
//  A 6x6 KOHONEN SELF-ORGANIZING MAP learning market structure with NO
//  LABELS, NO BACKPROP, NO GRADIENT. Entirely different from an MLP.
//
//  HOW IT LEARNS
//  Each bar becomes a 5-dim vector. The closest node wins, and the winner
//  PLUS ITS GRID NEIGHBOURS move toward the input. That neighbour update is
//  the whole trick: it forces adjacent nodes to represent similar states, so
//  the grid becomes a MAP rather than 36 unrelated clusters. Without it this
//  would be plain k-means.
//
//  The radius must DECAY. Wide early establishes global topology; narrow
//  later refines detail. A fixed radius either never organises or freezes
//  into a bad layout on the first hundred bars.
//
//  It trains on EVERY bar. Filtering samples would distort the density the
//  map exists to represent.
//
//  WHAT YOU GET THAT RULES CANNOT GIVE
//  Regimes are DISCOVERED, not defined. Nobody told it what a trend day is —
//  one emerges as a region because those bars cluster. And the distance to
//  the winning node is a genuine NOVELTY DETECTOR: when nothing on the map
//  resembles right now, that is a real warning no threshold rule produces.
// ══════════════════════════════════════════════════════════════════════════

lr = input.float(0.10, "Learn"), r0 = input.float(2.5, "Radius"), dk = input.int(1200, "Decay")
gx = input.int(30, "Grid X"), gs = input.float(0.55, "Grid Size"), sh = input.bool(true, "Show Map")

int G = 6, N = G*G, F = 5
var array<float> M = array.new_float(N*F, 0.0)           // node weights
var array<int>   H = array.new_int(N, 0)                 // hit counts
var array<float> P = array.new_float(N, 0.0)             // mean forward return per node
var float rn = 1.0
var int n = 0, var bool go = false

if not go
    go := true
    for i = 0 to N*F - 1
        rn := 16807.0*rn - math.floor(16807.0*rn/2147483647.0)*2147483647.0
        array.set(M, i, (rn/2147483647.0*2.0-1.0)*0.3)   // small random init, unfolds outward

// five continuous features — SOM needs magnitude, not bits
a = ta.atr(14), vw = ta.vwap(hlc3)
cl(float v) => math.max(-2.0, math.min(2.0, v))
x0 = cl((close-vw)/a)                                                                   // stretch
x1 = cl(math.abs(close-close[14])/math.max(math.sum(math.abs(close-close[1]),14),1e-9)*3.0-1.5)  // trend vs chop
x2 = cl(ta.atr(5)/a - 1.0)                                                              // vol state
x3 = cl(volume/math.max(ta.sma(volume,20),1.0) - 1.0)                                   // participation
x4 = cl((close-close[10])/a)                                                            // momentum

bool on = bar_index > last_bar_index - 3000 and bar_index > 60
var int bmu = 0
var float qe = 0.0

if on and barstate.isconfirmed
    float best = 1e18
    for i = 0 to N - 1                                   // competition: nearest node wins
        float d = 0.0
        d += math.pow(array.get(M,i*F)  -x0,2) + math.pow(array.get(M,i*F+1)-x1,2)
        d += math.pow(array.get(M,i*F+2)-x2,2) + math.pow(array.get(M,i*F+3)-x3,2)
        d += math.pow(array.get(M,i*F+4)-x4,2)
        if d < best
            best := d, bmu := i
    qe := math.sqrt(best)                                // quantisation error = novelty
    float t = math.min(n/float(dk), 1.0)
    float rad = math.max(r0*(1.0-t) + 0.5*t, 0.5)        // radius decays: global then local
    float eta = lr*(1.0-t) + 0.01*t
    int bx = bmu % G, bry = bmu / G
    for i = 0 to N - 1                                   // winner AND neighbours adapt
        float gd = math.pow(i%G - bx, 2) + math.pow(i/G - bry, 2)
        if gd <= rad*rad*4.0
            float nb = eta * math.exp(-gd/(2.0*rad*rad)) // gaussian falloff by GRID distance
            array.set(M,i*F,   array.get(M,i*F)   + nb*(x0-array.get(M,i*F)))
            array.set(M,i*F+1, array.get(M,i*F+1) + nb*(x1-array.get(M,i*F+1)))
            array.set(M,i*F+2, array.get(M,i*F+2) + nb*(x2-array.get(M,i*F+2)))
            array.set(M,i*F+3, array.get(M,i*F+3) + nb*(x3-array.get(M,i*F+3)))
            array.set(M,i*F+4, array.get(M,i*F+4) + nb*(x4-array.get(M,i*F+4)))
    array.set(H, bmu, array.get(H,bmu)+1)
    n += 1

// Label the map AFTER the fact: what happened next, per node. The SOM never
// saw this — it is read off the clusters it built on its own.
if on and barstate.isconfirmed and bar_index > 72
    int pb = bmu[12]
    float fr = (close - close[12])/a[12]
    array.set(P, pb, array.get(P,pb)*0.95 + math.max(-2.0,math.min(2.0,fr))*0.05)

float bias = array.get(P, bmu)
float nov  = qe

// ── render the live map ──
var array<box>   BX = array.new_box()
var array<label> LB = array.new_label()
if barstate.islast
    if array.size(BX) > 0
        for i = 0 to array.size(BX)-1
            box.delete(array.get(BX,i))
        array.clear(BX)
    if array.size(LB) > 0
        for i = 0 to array.size(LB)-1
            label.delete(array.get(LB,i))
        array.clear(LB)
    if sh
        float cell = a*gs, x = bar_index + gx, top = close + cell*G*0.5
        int mh = math.max(array.max(H), 1)
        for i = 0 to N - 1
            int cx = i%G, cy = i/G
            float v = array.get(P,i), dens = array.get(H,i)/float(mh)
            color c = v > 0.05 ? color.teal : v < -0.05 ? color.red : color.gray
            array.push(BX, box.new(x+cx*2, top-cy*cell, x+cx*2+2, top-(cy+1)*cell,
                 bgcolor=color.new(c, int(94.0 - math.min(math.abs(v),1.0)*40.0 - dens*25.0)),
                 border_color=i==bmu ? color.white : color.new(color.gray,80),
                 border_width=i==bmu ? 2 : 1))
        array.push(LB, label.new(x+G, top+cell*0.8,
             "SOM " + str.tostring(n) + "   node " + str.tostring(bmu) +
             "   bias " + (bias>=0?"+":"") + str.tostring(bias,"#.##") +
             "   novelty " + str.tostring(nov,"#.##"),
             style=label.style_none, textcolor=color.new(color.silver,20), size=size.tiny))

// Novelty spike: the current bar resembles nothing the map has learned.
bool alien = on and nov > ta.percentile_linear_interpolation(nov, 200, 90)
bgcolor(alien ? color.new(color.orange, 88) : na)
plotshape(alien and not alien[1], "Novel", shape.diamond, location.abovebar, color.orange, size=size.tiny)

if barstate.islast
    var table t = table.new(position.top_right, 2, 3, bgcolor=color.new(color.black,20))
    table.cell(t,0,0, "µSOM " + str.tostring(n), text_color=color.aqua, text_size=size.small)
    table.cell(t,1,0, "node " + str.tostring(bmu), text_color=color.silver, text_size=size.small)
    table.cell(t,0,1, "BIAS", text_color=color.gray, text_size=size.tiny)
    table.cell(t,1,1, (bias>=0?"+":"") + str.tostring(bias,"#.##") + " ATR", text_color=bias>0.1?color.teal:bias<-0.1?color.red:color.gray, text_size=size.small)
    table.cell(t,0,2, "NOVELTY", text_color=color.gray, text_size=size.tiny)
    table.cell(t,1,2, str.tostring(nov,"#.##") + (alien?"  ALIEN":""), text_color=alien?color.orange:color.silver, text_size=size.small)
````
