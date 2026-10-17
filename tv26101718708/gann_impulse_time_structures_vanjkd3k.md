# Gann Impulse Time Structures

- url: https://www.tradingview.com/script/vANjkd3k-gann-impulse-time-structures/
- type: indicator
- pine_id: PUB;7a66ee64b44f4607870a707c2c0f8195
- version: 1.0

## Description

This is a very insightful observation based on W.D. Gann's teachings! The concept of viewing market structures through time divisions rather than just price volatility opens up a mathematical dimension to market rhythm.

What the Script Does:

1.Swing Identification: It uses standard ta.pivothigh and ta.pivotlow functions to construct a zigzag that identifies the fundamental swings (impulses and retracements).

2.Time Duration Labels: Instead of focusing on the price movement, it automatically calculates the temporal duration of each swing (in bars) and places the number directly in the middle of the drawn impulse line.

3.Color Coding: Upward swings are marked green, and downward swings are red, making it easier to see the structure of a multi-swing cycle.

How to use it to analyze your theory:

Gann mentioned observing the initial impulse in terms of 2 parts (like an up-swing and a down-swing). With this script, look closely at pairs of swings to observe if the combined unit adds up to an important Gann number (like 36, 72, or 144 bars).

You can change the Pivot Length in the settings. For shorter rhythmic cycles (like the 12-12 or 9-9-9-9 mentioned in your images), you'll want a shorter pivot length. For macroscopic market cycles (like 144 units), you might want to increase the pivot length.

Label Placement: The labels are now placed directly at the pivot points (above the highs and below the lows) instead of the middle of the line.
Text Size: Increased the label size to size.large.

Peak-to-Peak & Trough-to-Trough: Added tracking for the last peak and last trough. The labels now display the current swing duration, followed by the peak-to-peak (P-P) distance above highs, and the trough-to-trough (T-T) distance below lows.

1.Cycle Projections: Whenever a new pair of swings completes (creating a new Peak-to-Peak or Trough-to-Trough distance), the script takes that temporal duration and projects it forward into the future from that pivot point.

2.Vertical Lines & Labels: It draws a subtle dashed vertical line (green for projected peaks, red for projected troughs) extending infinitely into the future/past so you can easily spot when price approaches these rhythmic time points. It also includes a small label indicating which cycle multiple it is (e.g., P-P 1x (36) or P-P 2x (72)).

3.Multipliers: I added a setting called Projection Multipliers (defaulting to 2). This means it will project the cycle duration forward 1x and 2x. You can increase this if you want to project 3x, 4x, etc., into the future.

4.Toggle Option: If the chart gets too cluttered with vertical lines, you can easily turn them off by unchecking "Project Future Time Points" in the settings.
Previously, the indicator strictly alternated between every single local high and local low it found. This resulted in fragmented impulse lines (like the small red downswings in your image) when price paused or made minor retracements within a larger trend.

Now, if the script is drawing a downward swing and encounters multiple small bounces (lower highs and lower lows), it will intelligently extend the existing downswing line to the lowest point rather than reversing early. It will only lock in that downswing and reverse direction when a distinct upward pivot high is confirmed, breaking the downward sequence.

This behavior will natively merge those 5+5+5 micro-swings into the true overarching 15-bar continuous impulse as requested.

## Source Code

````pine
//@version=6
indicator("Gann Impulse Time Structures", overlay = true, max_lines_count = 500, max_labels_count = 500)

// --- Inputs ---
length = input.int(10, "Pivot Length", tooltip="Length used to identify High/Low pivots to form the swings")
showProjections = input.bool(true, "Project Future Time Points", tooltip="Projects vertical lines forward based on the duration of the completed swing pair.")
projMults = input.int(2, "Projection Multipliers", minval = 1)

// --- Variables ---
var int   dir           = 0
var float pPrice        = na
var int   pBar          = na

var float prevHighPrice = na
var int   prevHighBar   = na
var float prevLowPrice  = na
var int   prevLowBar    = na

var line  lastLine      = na
var label lastLabel     = na

// Find pivots
ph = ta.pivothigh(high, length, length)
pl = ta.pivotlow(low, length, length)

// Update logic
if not na(ph)
    if dir == 1
        // Extend upswing if new high is higher
        if ph > pPrice
            pPrice := ph
            pBar   := bar_index[length]
            if not na(lastLine)
                line.set_xy2(lastLine, pBar, pPrice)
            if not na(lastLabel)
                barsElapsed = na(prevLowBar) ? na : (pBar - prevLowBar)
                p2p = na(prevHighBar) ? na : (pBar - prevHighBar)
                lblText = str.tostring(barsElapsed) + (na(p2p) ? "" : "\nP-P: " + str.tostring(p2p))
                label.set_xy(lastLabel, pBar, pPrice)
                label.set_text(lastLabel, lblText)
    else
        // Switch to upswing
        if dir == -1
            prevLowBar   := pBar
            prevLowPrice := pPrice
            
            // We just finalized a downswing, so the T-T distance is known. We can draw projections from here.
            t2t = na(prevHighBar) ? na : (prevLowBar - ta.valuewhen(dir == 1, prevLowBar, 0)) // We can compute it easier using variables.
            // Wait, t2t is known when we form the low. The previous low is needed.
            // But we already updated prevLowBar. Let's handle projections dynamically.

        dir    := 1
        pPrice := ph
        pBar   := bar_index[length]
        
        if not na(prevLowBar)
            lastLine := line.new(prevLowBar, prevLowPrice, pBar, pPrice, color = color.green, width = 2)
            barsElapsed = pBar - prevLowBar
            p2p = na(prevHighBar) ? na : (pBar - prevHighBar)
            lblText = str.tostring(barsElapsed) + (na(p2p) ? "" : "\nP-P: " + str.tostring(p2p))
            lastLabel := label.new(pBar, pPrice, lblText, color = color.new(color.green, 90), textcolor = color.green, style = label.style_label_down, size = size.large)
            
            if showProjections and not na(p2p)
                for i = 1 to projMults
                    projBar = pBar + (p2p * i)
                    line.new(projBar, high[length], projBar, low[length], extend = extend.both, color = color.new(color.green, 70), style = line.style_dashed, width = 1)
                    label.new(projBar, high[length], "P-P " + str.tostring(i) + "x\n(" + str.tostring(p2p * i) + ")", color = color.new(color.green, 100), textcolor = color.new(color.green, 50), style = label.style_label_down, size = size.small)

if not na(pl)
    if dir == -1
        // Extend downswing if new low is lower
        if pl < pPrice
            pPrice := pl
            pBar   := bar_index[length]
            if not na(lastLine)
                line.set_xy2(lastLine, pBar, pPrice)
            if not na(lastLabel)
                barsElapsed = na(prevHighBar) ? na : (pBar - prevHighBar)
                t2t = na(prevLowBar) ? na : (pBar - prevLowBar)
                lblText = str.tostring(barsElapsed) + (na(t2t) ? "" : "\nT-T: " + str.tostring(t2t))
                label.set_xy(lastLabel, pBar, pPrice)
                label.set_text(lastLabel, lblText)
    else
        // Switch to downswing
        if dir == 1
            prevHighBar   := pBar
            prevHighPrice := pPrice

        dir    := -1
        pPrice := pl
        pBar   := bar_index[length]
        
        if not na(prevHighBar)
            lastLine := line.new(prevHighBar, prevHighPrice, pBar, pPrice, color = color.red, width = 2)
            barsElapsed = pBar - prevHighBar
            t2t = na(prevLowBar) ? na : (pBar - prevLowBar)
            lblText = str.tostring(barsElapsed) + (na(t2t) ? "" : "\nT-T: " + str.tostring(t2t))
            lastLabel := label.new(pBar, pPrice, lblText, color = color.new(color.red, 90), textcolor = color.red, style = label.style_label_up, size = size.large)
            
            if showProjections and not na(t2t)
                for i = 1 to projMults
                    projBar = pBar + (t2t * i)
                    line.new(projBar, high[length], projBar, low[length], extend = extend.both, color = color.new(color.red, 70), style = line.style_dashed, width = 1)
                    label.new(projBar, low[length], "T-T " + str.tostring(i) + "x\n(" + str.tostring(t2t * i) + ")", color = color.new(color.red, 100), textcolor = color.new(color.red, 50), style = label.style_label_up, size = size.small)
````
