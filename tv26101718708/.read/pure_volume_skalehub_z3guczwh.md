# Pure Volume [SkaleHub]

- url: https://www.tradingview.com/script/z3GucZWH-Pure-Volume-SkaleHub/
- type: indicator
- pine_id: PUB;109ba1443934415391d1601770a9ca3d
- version: 1.0

## Description

Overview
Standard volume bars can be incredibly noisy and hard to read. This tool smooths out that data using a built-in moving average line, replacing individual bars with a single, flowing area chart.

The Edge
It filters out the chop to clearly show whether overall market participation is expanding or contracting, giving you a "pure" read on institutional interest and volume momentum.

Key Features:

Noise Reduction: Strips away chaotic, alternating volume bars and replaces them with a single, highly readable trendline of market participation.

Momentum Color-Coding: The indicator automatically shifts colors (Green for expanding, Red for contracting) so you can instantly gauge whether interest in the asset is growing or fading.

Trend Confirmation: Helps developing traders confirm if a price move has real financial backing or if it is just a low-volume fakeout.

How to Use

Apply the indicator to your chart (it will appear in a pane below the price action).

Look for the volume wave to turn Green (expanding) when price is breaking out or making a major move. This confirms institutional backing.

If price is moving rapidly but the Pure Volume wave is Red (contracting), treat the move with caution, as it lacks heavy market participation and may reverse.

[b]Author's Note
[/b]This indicator is part of the SkaleHub Free Starter Library. It is designed to be paired with the SkaleHub Training System to help newer traders build mechanical discipline and systemize their trading process.

## Source Code

````pine
//@version=5
indicator("Pure Volume [SkaleHub]", overlay=false, format=format.volume)

// =========================================================================
// 1. INPUT PARAMETERS
// =========================================================================
smoothLength     = input.int(21, title="Volume Smoothing Length", minval=1, group="Volume Settings")
colorExpanding   = input.color(color.new(#00ff00, 40), title="Expanding Volume Color", group="Visuals")
colorContracting = input.color(color.new(#ff0000, 40), title="Contracting Volume Color", group="Visuals")

// =========================================================================
// 2. MATH & LOGIC
// =========================================================================
// Calculate the smoothed average of the volume to filter out noise
pureVol = ta.sma(volume, smoothLength)

// Determine if overall market participation is rising or falling
isExpanding = pureVol > pureVol[1]

// =========================================================================
// 3. VISUAL PLOTTING
// =========================================================================
// Assign the dynamic color based on volume momentum
volColor = isExpanding ? colorExpanding : colorContracting

// Plot as a clean area chart instead of choppy individual bars
plot(pureVol, title="Pure Volume Area", color=volColor, style=plot.style_area, linewidth=3)
````
