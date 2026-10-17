# Segmented Momentum Peak

- url: https://www.tradingview.com/script/CIvZMRae/
- type: indicator
- pine_id: PUB;f4ba8d22fcd347f68d940eeded0151ff
- version: 1.0

## Description

[b]Segmented Momentum Peak (SMP) by Chao Ivans[/b]

This indicator builds an adaptive momentum threshold by collecting peak and trough readings from a series of past time segments and averaging them into a reference. A current move is treated as significant only when it matches or exceeds what the instrument has historically been capable of producing.

[b]Calculation[/b]

The process runs in four stages.

[i]First[/i], Rate of Change is measured on closing prices over a defined period. This value feeds everything that follows.

[i]Second[/i], the chart is divided into segments of a set length. From each segment, one highest reading and one lowest reading is taken. This repeats across the chosen number of segments, gathering a collection of peak samples and trough samples spanning a substantial stretch of history.

[i]Third[/i], all peak samples are averaged into an upper reference and all trough samples into a lower reference. Both are then divided by the sensitivity parameter to produce the working thresholds drawn on the panel.

[i]Fourth[/i], the system counts how many times ROC has broken those thresholds within a recent window of bars. A signal appears only when the count meets the required quota and the current bar is breaking as well.

[b]Logic Behind the Formula[/b]

The approach used here is known as block maxima, where extreme values are drawn from each block of data and their distribution is studied. Peaks are used rather than a plain average because averaging every reading would be dominated by the far more numerous quiet bars, dragging the threshold too low and flooding the chart with signals. Collecting only peaks produces a threshold that reflects how strong a move the market has genuinely been capable of delivering.

A useful consequence is that the threshold is self scaling across instruments. On a sluggish asset it settles low on its own. On a volatile asset it rises accordingly. No recalibration is needed when switching markets.

The cluster counting layer exists because a single threshold break is often nothing more than a momentary spike. When real pressure enters, breaks tend to arrive repeatedly within a short span. The quota requirement is what separates the two.

[b]Function[/b]

The indicator identifies momentum that is statistically unusual relative to the instrument's own history, then filters it further through a repetition requirement. The output is a directional marker on the main chart whenever buying or selling pressure is confirmed as sustained.

[b]How to Use[/b]

The lower panel shows three elements. Columns represent the ROC reading, turning green when breaking the upper threshold, red when breaking the lower threshold, and grey when sitting between them. Two thick lines represent the adaptive thresholds, which shift as volatility conditions change.

Pay attention to the threshold line colours. A blue upper line and a purple lower line indicate the thresholds sit at a meaningful level, so any break carries weight. A black line warns that the threshold has collapsed to a very low level, which typically happens in thin or dormant markets. Breaks come easily under those conditions but signify little, so signals should be ignored or treated with caution.

A green triangle below the bar marks a confirmed cluster of buying pressure. A red triangle above the bar marks selling pressure. These triangles are pressure markers, not entry commands. Use them to confirm a plan already built from price structure rather than as a standalone reason to open a position.

[b]Tuning Guide[/b]

Start with sensitivity. If signals feel too scarce, raise it gradually. If the chart gets crowded, lower it.

Segment Length shapes the character of the threshold. Small values give a nimble threshold that tracks current conditions. Large values give one that only shifts when volatility changes on a broad scale.

Number of Segments Sampled controls stability. A large sample count makes the threshold resistant to one or two extreme events, but also slower to adapt when the market regime turns.

Cluster Window and Minimum Hits work as a pair. A narrow window with a high quota demands tightly packed pressure and produces the fewest but firmest signals. A wide window with a low quota is permissive and produces more.

## Source Code

````pine
// © Chao_Ivans

//This indicator was developed and published by Chao Ivans.
//The calculation concept and source code are the personal work of its author.

//You are welcome to use this indicator for personal analysis and trading.
//Reselling, modifying and claiming it as your own work, or redistributing it without crediting the author is not permitted.

//This indicator is provided as an analytical aid, not as a buy or sell recommendation. 
//All trading decisions and their consequences rest entirely with the user.

//@version=6
indicator("Segmented Momentum Peak", "SMP", overlay = false) 

// ========== Input Parameter ==========

// ===== Group: Core Calculation =====
sensitivity      = input.float(1.2, "Sensitivity", minval = 0.1, group = "Core Calculation", tooltip =  "Divides the averaged extreme value to produce the working threshold. " +
               "Values above 1 pull the threshold closer to zero, so signals fire more " +
               "often. Values below 1 push it further away and demand a stronger move. " +
               "Leave it at 1.0 if you want the raw average of past segment extremes " +
               "with no adjustment. Adjust this first before touching anything else.")

length_roc       = input.int(1, "ROC Length", minval = 1, group = "Core Calculation", tooltip = "Number of bars used to measure rate of change. A value of 1 reads the " +
               "single most recent bar and reacts immediately, which suits impulse " +
               "detection. Larger values smooth the reading by measuring accumulated " +
               "movement, at the cost of delayed response.")

segment_window   = input.int(12, "Segment Length (Bars)", minval = 1, group = "Core Calculation", tooltip = "Length of each segment from which a single peak and trough is taken. " +
               "Think of it as how the chart is sliced before extremes are collected. " +
               "Shorter segments capture local peaks and adapt quickly. Longer segments " +
               "capture only major peaks, producing a slower and more selective threshold.")

lookback_horizon = input.int(12, "Number of Segments Sampled", minval = 1, group = "Core Calculation", tooltip = "How many past segments are averaged to build the threshold. Total history " +
               "consumed is roughly this value multiplied by Segment Length, so 12 by 12 " +
               "reads about 144 bars back. More samples give a steadier baseline that " +
               "resists single outliers. Fewer samples let the threshold track recent " +
               "volatility more tightly.")

// ===== Group: Signal Cluster =====
n_bar       = input.int(6, "Cluster Window (Bars)", minval = 1, group = "Signal Cluster", tooltip = "The window in which repeated threshold breaks are counted. A signal only " +
               "appears when enough breaks occur inside this window and the current bar " +
               "is also breaking. Widen it to allow scattered breaks to still qualify. " +
               "Narrow it to demand that pressure arrives in quick succession.")

n_threshold = input.int(2, "Minimum Hits in Cluster Window", minval = 1, group = "Signal Cluster", tooltip = "How many threshold breaks must appear inside the Cluster Window before a " +
               "signal is allowed. Setting this to 1 makes every break a signal. Raising " +
               "it filters out isolated spikes and keeps only sustained pressure. Values " +
               "of 2 or 3 usually strike the best balance.")

// ===== Group: Visual =====
min_volUP = input.float(1, title= "Min Volatility UP", group = "Visual", tooltip = "Colour cue only, it does not filter signals. The upper threshold line " +
               "turns blue once it sits at or above this level, marking periods where " +
               "the market is volatile enough for breakouts to carry real weight. " +
               "A black line warns that the threshold itself has collapsed and any " +
               "break may be noise.")

min_volDOWN = input.float(-1, title= "Min Volatility DOWN", group = "Visual", tooltip = "Colour cue only, it does not filter signals. The lower threshold line " +
               "turns purple once it sits at or below this level. Enter a negative " +
               "number. Mirror it against the upper level for symmetric behaviour, or " +
               "set it deeper on instruments that fall harder than they rise.")


// ========== Calculate ROC and Local Extremes ==========
roc  = ta.roc(close, length_roc)
hhv5 = ta.highest(roc, segment_window)
llv5 = ta.lowest(roc, segment_window)

// Dynamic Lookback Calculation (Loop)
float sum_hhv = 0.0
float sum_llv = 0.0

for i = 0 to lookback_horizon - 1
    int offset = 1 + (i * segment_window)
    sum_hhv += hhv5[offset]
    sum_llv += llv5[offset]

// Rata-rata dari sampel yang diambil
smp_high = sum_hhv / lookback_horizon
smp_low  = sum_llv / lookback_horizon

// Threshold calculation with Sensitivity
sh = smp_high / sensitivity
sl = smp_low / sensitivity

// Breakout and Breakdown
bo = roc >= sh
bd = roc <= sl

// ========== Hitung berapa kali bo/bd terpenuhi dalam n_bar terakhir ==========
bo_count = math.sum(bo ? 1 : 0, n_bar)
bd_count = math.sum(bd ? 1 : 0, n_bar)

bo_condition_met = bo_count >= n_threshold
bd_condition_met = bd_count >= n_threshold

// Create Sinyal
buy = bo_condition_met and bo
sell = bd_condition_met and bd


// === Coloring Logic ===
warna = roc >= sh ? #1e7121 : roc <= sl ? #d73232 : color.gray

warna_sh = sh >= min_volUP ? color.blue : color.black
warna_sl = sl <= min_volDOWN ? color.purple : color.black


// ============= Plotting =============
plot(roc, "SMP ROC", color = warna, style = plot.style_columns, precision = 2)
plot(sh, "Upper Threshold", color = warna_sh, linewidth = 3, precision = 2)
plot(sl, "Lower Threshold", color = warna_sl, linewidth = 3, precision = 2)

// Garis bantu nol
hline(0, "Zero Line", color = color.gray, linestyle = hline.style_dotted)

plotshape(buy, "BO Cluster", shape.triangleup, location.belowbar, #166819, size = size.small, force_overlay = true)
plotshape(sell, "BD Cluster", shape.triangledown, location.abovebar, #b23131, size = size.small, force_overlay = true)
````
