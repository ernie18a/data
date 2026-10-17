# Histo-Patterns

- url: https://www.tradingview.com/script/o5ef8reP/
- type: indicator
- pine_id: PUB;f6930796e1664ac49de0935dac04392c
- version: 2.0

## Description

Detect historical price patterns in real time using Euclidean matching.

[b]Concept[/b]
Ever looked at a chart and thought "this looks exactly like that setup from 2023"? Histo-Patterns formalizes that intuition. Anchor a historical bar range, and the indicator continuously scans incoming price action for structurally similar setups.

[b]How to use it[/b]
- Spot a meaningful pattern in history.
- Paste its exact datetime into Start Date & Time.
- Set Pattern Length in days. Decimals accepted, 0.5 for 12h, 0.25 for 6h.
- Set Matching %, structures above this threshold trigger a signal.
- Set Min Waiting Bars to control spacing between detections. Equal to Pattern Length = no overlaps.

Tip: Shorter patterns fire more often; longer ones are rarer and more selective.

[b]Under the Hood[/b]
Euclidean distance measures how geometrically close the current bar sequence is to your reference. 
That distance is inverted and passed through a sigmoid to produce a clean 0–100% match score.

[b]Honest Limitations[/b]
Only detects patterns after the reference start time, no lookback before it.
Degrades on noisy or low-liquidity instruments.
No time warping, patterns that unfold faster or slower than the reference score poorly.
Similarity ≠ prediction. It tells you structure repeats, not what happens next.


[b]Disclaimer[/b]
This indicator is provided for educational and informational purposes only. It does not constitute financial advice, trading recommendations, or a guarantee of future results. Past performance does not predict future returns. You alone are responsible for your trading decisions. Always test thoroughly in a simulated environment before trading with real capital.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © finalTAboss

//@version=6
indicator("Histo-Patterns", overlay=true, max_boxes_count=500)

start_tooltip = "The exact timestamp (date and time) where the pattern should begin."
length_tooltip = "How many bars the pattern lasts after the start time. Measured in days. Use 0.5 for 12 hours, 0.04167 for 1 hour."
matching_tooltip = "The minimum percentage the current observed data needs to match the historical pattern."
minwait_tooltip = "The minimum amount of bars that the detection algorithm gets frozen after a pattern occurs. If Min Waiting Bars is equal to Pattern Length then no overlapping occurs."

src = input.source(close, "Source")
startTime = input.time(timestamp("2024-07-04T00:00:00"), "Start Date & Time", tooltip=start_tooltip)
length = input.float(12.0, "Pattern Length (Days)", maxval=30.0, tooltip=length_tooltip)
matching = input.int(72, 'Matching Detection (%)', step=1, minval=1, maxval=99, tooltip = matching_tooltip)
minwait = input.int(12, 'Min Waiting Bars', tooltip=minwait_tooltip)


f_highest(_source, _length) =>
    float _return = _source
    if _length >= 1 and _length <= 5000
        for _i = 0 to math.max(0, _length-1)
            _return := math.max(_source[_i], _return)
    _return


f_lowest(_source, _length) => 
    float _return = _source
    if _length >= 1 and _length <= 5000
        for _i = 0 to math.max(0, _length-1)
            _return := math.min(_source[_i], _return)
    _return


f_minmax(float[] src) =>
    float[] dst = array.new<float>()
    size = array.size(src)
    if size > 0
        float minVal = array.min(src)
        float maxVal = array.max(src)
        float _range = maxVal - minVal
        if _range != 0.0
            for i = 0 to size - 1
                array.push(dst, (array.get(src, i) - minVal) / _range)
        else
            for i = 0 to size - 1
                array.push(dst, 0.0)
    dst

endTimestamp = startTime + int(length * 86400000)  
currentTime = time
isInRange = currentTime >= startTime and currentTime <= endTimestamp
bgcolor(isInRange ? color.new(color.green, 80) : na)

threshold = matching / 100
var array<float> patternValues = array.new<float>()
if isInRange
    array.push(patternValues, src)

var array<float> lastCloseValues = array.new<float>()
if array.size(patternValues) > 0
    array.clear(lastCloseValues)
    int arraySize = array.size(patternValues)
    for i = 0 to arraySize - 1
        array.push(lastCloseValues, src[arraySize - 1 - i])   

float distance = na
if array.size(patternValues) == array.size(lastCloseValues) and array.size(patternValues) > 0
    float sumOfSquares = 0.0
    int arrayLength = array.size(patternValues)
    for i = 0 to arrayLength - 1
        float diff = array.get(f_minmax(patternValues), i) - array.get(f_minmax(lastCloseValues), i)
        sumOfSquares += diff * diff
    distance := math.sqrt(sumOfSquares)

proba = 1.0 / (1.0 + math.exp(-distance))
similarity = 1 - (proba - 0.5) * 2 

detector = ta.crossover(similarity, threshold)
filt = math.sum(detector[1] ? 1 : 0, minwait)
bins = detector and filt == 0 ? 1 : 0

topPrice = f_highest(high, int(array.size(patternValues)))
bottomPrice = f_lowest(low, int(array.size(patternValues)))
var bool boxDrawn = false
if bins == 1 and not boxDrawn
    N = array.size(patternValues)
    if N > 0
        includeCurrent = true  
        leftIndex = includeCurrent ? bar_index - N + 1 : bar_index - N
        rightIndex = includeCurrent ? bar_index : bar_index - 1
        box.new(
             left = leftIndex,
             top = topPrice,
             right = rightIndex,
             bottom = bottomPrice,
             bgcolor = color.new(color.yellow, 80),
             border_color = color.new(color.red, 0),
             border_width = 1,
             xloc = xloc.bar_index)
        boxDrawn := true 

    alert_message = ("Pattern Detected!\n" +
                "Time: " + str.format_time(time, "yyyy-MM-dd HH:mm") + "\n" +
                "Matching Threshold: " + str.tostring(matching * 100) + "%\n" +
                "Pattern Length: " + str.tostring(length) + " bars")
    alert(alert_message, alert.freq_once_per_bar)

if bins != 1
    boxDrawn := false
````
