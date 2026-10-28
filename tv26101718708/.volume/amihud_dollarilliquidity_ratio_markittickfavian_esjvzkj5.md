# Amihud Dollar-Illiquidity Ratio [MarkitTick/Favian]

- url: https://www.tradingview.com/script/esjVZkJ5-Amihud-Dollar-Illiquidity-Ratio-MarkitTick-Favian/
- type: indicator
- pine_id: PUB;fa160a5cafa441f085b9ac15dd01b1d7
- version: 1.0

## Description

Slight variation to https://www.tradingview.com/v/kiSA7fSa/

It attempts to perform a tactical update to track dollar-volume instead of simply using volume.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © [MarkitTick]

//@version=6
indicator("Amihud Dollar-Illiquidity Ratio [MarkitTick/Favian]", overlay=false)                                                                                                                                      

// -----------------------------------------------------------------------------
// --- Inputs ---
// -----------------------------------------------------------------------------
int amihudLen = input.int(10, "Calculation Period", minval=1, group="Amihud Illiquidity Ratio", tooltip="Number of periods to calculate the average illiquidity")                          
int amihudSmooth = input.int(5, "Smoothing Period", minval=1, group="Amihud Illiquidity Ratio", tooltip="Moving average period for smoothing the illiquidity ratio")
bool showDashboard = input.bool(true, "Show Quant Dashboard", group="Visuals")

// -----------------------------------------------------------------------------
// --- Type Definitions (Quant Architecture) ---
// -----------------------------------------------------------------------------

// @type LiquidityState
// Encapsulates the runtime state of the liquidity metric
type LiquidityState
    float raw
    float smoothed
    float highZone
    float lowZone
    bool isHighStress
    bool isLowStress

// @type LiquidityEngine
// The computational core managing the Amihud model
type LiquidityEngine
    int length
    int smoothLen
    LiquidityState state

// -----------------------------------------------------------------------------
// --- Methods ---
// -----------------------------------------------------------------------------

// @method update
// Processes the time-series data to update the liquidity state
// Optimized Formula: |(Close - PrevClose) / PrevClose| / (Volume * Close) * 1,000,000,000
method update(LiquidityEngine this) =>
    // Strict volume check to prevent divide-by-zero runtime errors 
    float vol = nz(volume)

    // Calculate Dollar Volume (Volume * Close) for scale-free stationarity                                                                                                                                    
    float dollarVolume = vol * close
    
    // Calculate Daily Return: Absolute percent change
    // We use strict math.abs() and close[1] offset
    float dailyReturn = math.abs(ta.change(close) / close[1])
    
    /// Calculate Raw Illiquidity Ratio using Dollar Volume                                                                                                                                                     
    // Multiplied by 1,000,000,000 (1 Billion) to scale values into readable ranges                                                                                                                            
    float illiquidityRaw = dollarVolume > 0 ? (dailyReturn / dollarVolume) * 1000000000 : 0.0
    
    // Smooth the raw data (SMA) to reduce noise
    float amihudAvg = ta.sma(illiquidityRaw, this.length)
    float smoothedVal = ta.sma(amihudAvg, this.smoothLen)
    
    // Calculate Dynamic Percentile Zones
    // Using linear interpolation for statistical robustness
    float hZone = ta.percentile_linear_interpolation(amihudAvg, this.length * 2, 75)
    float lZone = ta.percentile_linear_interpolation(amihudAvg, this.length * 2, 25)
    
    // Update State Object
    this.state.raw := amihudAvg
    this.state.smoothed := smoothedVal
    this.state.highZone := hZone
    this.state.lowZone := lZone
    this.state.isHighStress := amihudAvg > hZone
    this.state.isLowStress := amihudAvg < lZone

// @method render_dashboard
// Draws the institutional data table on the last bar
method render_dashboard(LiquidityEngine this, bool show) =>
    if show and barstate.islast
        var table hud = table.new(position.top_right, 2, 4, border_width=1, frame_color=color.new(color.gray, 80), border_color=color.new(color.gray, 90))
        
        // Header
        table.cell(hud, 0, 0, "METRIC", text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black, 100))
        table.cell(hud, 1, 0, "VALUE", text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black, 100))
        
        // Rows: Illiquidity
        table.cell(hud, 0, 1, "Amihud Ratio", text_color=color.white, text_halign=text.align_left, bgcolor=color.new(color.black, 100))
        table.cell(hud, 1, 1, str.tostring(this.state.raw, "#.########"), text_color=color.blue, text_halign=text.align_right, bgcolor=color.new(color.black, 100))
        
        // Rows: Regime
        string regime = this.state.isHighStress ? "HIGH STRESS" : this.state.isLowStress ? "LIQUID" : "NORMAL"
        color regimeColor = this.state.isHighStress ? color.red : this.state.isLowStress ? color.green : color.gray
        
        table.cell(hud, 0, 2, "Regime", text_color=color.white, text_halign=text.align_left, bgcolor=color.new(color.black, 100))
        table.cell(hud, 1, 2, regime, text_color=regimeColor, text_halign=text.align_right, bgcolor=color.new(color.black, 100))

// -----------------------------------------------------------------------------
// --- Execution Logic ---
// -----------------------------------------------------------------------------

// Initialize Engine
// Using 'var' to persist the object instance across bars 
var LiquidityEngine engine = LiquidityEngine.new(amihudLen, amihudSmooth, LiquidityState.new())

// Execute Calculation Update
engine.update()

// -----------------------------------------------------------------------------
// --- Visuals ---
// -----------------------------------------------------------------------------

// Primary Plots
// Using static colors to allow user customization via 'Style' tab 
plot(engine.state.raw, "Amihud Dollar-Illiquidity", color=color.blue, linewidth=2)
plot(engine.state.smoothed, "Signal Line", color=color.red, linewidth=2)

// Plot Splitting for Zones (No Input Colors)
// Native Style tab control enabled by separating plots 
bgcolor(engine.state.isHighStress ? color.new(color.red, 90) : na, title="Zone: High Illiquidity")
bgcolor(engine.state.isLowStress ? color.new(color.green, 90) : na, title="Zone: Low Illiquidity")

// Dashboard Rendering
engine.render_dashboard(showDashboard)
````
