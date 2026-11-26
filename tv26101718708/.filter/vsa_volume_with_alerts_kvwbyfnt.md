# VSA Volume with alerts

- url: https://www.tradingview.com/script/kVWbyfnT-VSA-Volume-with-alerts/
- type: indicator
- pine_id: PUB;5989354ae22a47bc9ef2dd648bfd5244
- version: 1.0

## Description

# VSA Volume with alerts

This indicator is inspired by Volume Spread Analysis (VSA) and Wyckoff methodology, helping traders quickly identify significant volume events and understand the relationship between volume, price spread, and closing position within the bar.

## Features

### Volume Classification

Volume is compared against a Wilder Moving Average of volume and categorized into:

* Ultra High Volume
* Very High Volume
* High Volume
* Normal Volume
* Low Volume
* Very Low Volume

### Color-Coded Volume Bars

* Purple = Ultra High Volume
* Red = Very High Volume
* Orange = High Volume
* Green = Normal Volume
* Blue = Low Volume
* Silver = Very Low Volume

This allows traders to instantly spot unusual activity and potential professional participation.

### VSA Bar Analysis

For every Very High or Ultra High Volume bar, the script evaluates:

**Bar Direction**

* Up Bar
* Down Bar
* Neutral Bar

**Spread Analysis**

* Wide Spread
* Normal Spread
* Narrow Spread

**Close Position**

* Close Near High
* Close Mid Range
* Close Near Low

### Smart Alerts

Dynamic alerts provide detailed VSA information such as:

"ULTRA HIGH VOLUME | UP BAR | WIDE SPREAD | CLOSE NEAR HIGH"

or

"VERY HIGH VOLUME | DOWN BAR | WIDE SPREAD | CLOSE NEAR LOW"

This enables traders to monitor potential accumulation, distribution, buying climaxes, selling climaxes, stopping volume, and other important VSA events without constantly watching charts.

## How It Can Be Used

The indicator is designed to help identify:

* Professional buying and selling activity
* Potential accumulation zones
* Potential distribution zones
* Climactic volume events
* Effort vs Result relationships
* Possible reversals and continuation signals

## Notes

This indicator is intended as a volume-analysis tool and should be used alongside price structure, support/resistance, trend analysis, and proper risk management. It does not generate buy or sell signals and should not be used as a standalone trading system.

Inspired by the principles of Richard D. Wyckoff and Volume Spread Analysis (VSA).

## Source Code

````pine
//@version=6
indicator("VSA Vol", shorttitle="VSA Vol", format=format.volume)

// =========================
// INPUTS
// =========================

showMA = input.bool(false, "Show Volume Moving Average")
lengthVolumeMA = input.int(20, "Length of MA applied on Volume")

ratioUltraVolume    = input.float(2.2, "Ultra High Volume Ratio")
ratioVeryHighVolume = input.float(1.8, "Very High Volume Ratio")
ratioHighVolume     = input.float(1.2, "High Volume Ratio")
ratioNormalVolume   = input.float(0.8, "Normal Volume Ratio")
ratioLowVolume      = input.float(0.4, "Low Volume Ratio")

spreadLength = input.int(20, "Average Spread Length")

// =========================
// WILDER VOLUME MA
// =========================

var float volumeMA = na
volumeMA := na(volumeMA[1]) ? volume : volumeMA[1] + (volume - volumeMA[1]) / lengthVolumeMA

// =========================
// VOLUME LEVELS
// =========================

ultraHighVolumeMin = volumeMA * ratioUltraVolume
veryHighVolumeMin  = volumeMA * ratioVeryHighVolume
highVolumeMin      = volumeMA * ratioHighVolume
normalVolumeMin    = volumeMA * ratioNormalVolume
lowVolumeMin       = volumeMA * ratioLowVolume

// =========================
// VOLUME CLASSIFICATION
// =========================

volUltraHigh = volume >= ultraHighVolumeMin
volVeryHigh  = volume >= veryHighVolumeMin and volume < ultraHighVolumeMin
volHigh      = volume >= highVolumeMin and volume < veryHighVolumeMin
volNormal    = volume >= normalVolumeMin and volume < highVolumeMin
volLow       = volume >= lowVolumeMin and volume < normalVolumeMin
volVeryLow   = volume < lowVolumeMin

// =========================
// VOLUME COLORS
// =========================

palette =
     volUltraHigh ? color.purple :
     volVeryHigh  ? color.red :
     volHigh      ? color.orange :
     volNormal    ? color.green :
     volLow       ? color.blue :
     color.silver

plot(volume, color=palette, style=plot.style_columns, title="Volume")
plot(showMA ? volumeMA : na, color=color.green, linewidth=2, title="Volume MA")

// =========================
// VSA ANALYSIS
// =========================

// Spread
spread = high - low
avgSpread = ta.sma(spread, spreadLength)

spreadType =
     spread > avgSpread * 1.5 ? "WIDE SPREAD" :
     spread < avgSpread * 0.7 ? "NARROW SPREAD" :
     "NORMAL SPREAD"

// Bar Direction
barDirection =
     close > close[1] ? "UP BAR" :
     close < close[1] ? "DOWN BAR" :
     "NEUTRAL BAR"

// Close Position Within Bar
closePosition =
     spread > 0 ?
     (
        close >= low + spread * 0.70 ? "CLOSE NEAR HIGH" :
        close <= low + spread * 0.30 ? "CLOSE NEAR LOW" :
        "CLOSE MID RANGE"
     )
     : "NO RANGE"

// =========================
// DYNAMIC ALERTS
// =========================

if barstate.isconfirmed and (volUltraHigh or volVeryHigh)

    volType =
         volUltraHigh ? "ULTRA HIGH VOLUME" :
         "VERY HIGH VOLUME"

    alert(
         volType +
         " | " + barDirection +
         " | " + spreadType +
         " | " + closePosition +
         " | " + syminfo.ticker +
         " | TF: " + timeframe.period,
         alert.freq_once_per_bar_close)
````
