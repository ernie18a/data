<!-- tradingview-pine-id: PUB;8ceefdc710cc43b9a44c07698763c0b5 -->
<!-- tradingviewscripts-format: 1 -->
# PivotLabels

Source: https://www.tradingview.com/script/qj0QGdgm-PivotLabels/

## Description

Library  "PivotLabels"

openLong(signal, a)
  Parameters:
    signal (Signal)
    a (CArray)

openShort(signal, a)
  Parameters:
    signal (Signal)
    a (CArray)

sendData(a)
  Parameters:
    a (CArray)

closeP(a)
  Parameters:
    a (CArray)

Signal
  Fields:
    id (series string)
    price (series float)
    targetPerc (series float)

CArray
  Fields:
    type (series string)
    BID (series string)
    signals (array<Signal>)
    activeClose (series bool)

---

## Source Code

````pine
//@version=6
library('PivotLabels', true)

// We use this `point` UDT in the library, but it does NOT require exporting because:
//   1. The exported function's parameters do not use the UDT.
//   2. The exported function does not return a UDT result.
export type Signal
	string id
	float price
	float targetPerc = 0

export type CArray
	string type
	string BID
	array<Signal> signals
	bool activeClose




//BID="l_Mod_"
//array<string> a=array.new<string>()
export openLong(Signal signal, CArray a) =>
    lid = str.format('{0}_{1}', a.BID, bar_index)
    if strategy.opentrades == 0 or a.activeClose
        signal.id := lid
        array.push(id = a.signals, value = signal)
    strategy.entry(lid, strategy.long)



export openShort(Signal signal, CArray a) =>
    lid = str.format('{0}_{1}', a.BID, bar_index)
    if strategy.opentrades == 0 or a.activeClose
        signal.id := lid
        array.push(id = a.signals, value = signal)

    strategy.entry(lid, strategy.short)

export sendData(CArray a) =>
    if array.size(id = a.signals) > 0
        sig = array.get(a.signals, 0)
        string lid = sig.id
        orderString = '{"reOpen":' + (a.activeClose ? '1' : '0') + ',"Type":"Entry' + a.type + '","id":"' + lid + '","inPrice":' + str.tostring(sig.price)
        orderString := orderString + ',"targetPercentage":' + str.tostring(sig.targetPerc)
        orderString := orderString + '}'
        ss = '{"pass":"abc","order":' + orderString + '}'
        alert(ss)
    else
        ss = '{"pass":"abc","order":{"reOpen":' + (a.activeClose ? '1' : '0') + ',"Type":"Exit' + a.type + '","id":"all"}}'
        alert(ss)


export closeP(CArray a) =>
    if strategy.opentrades != 0
        lid = strategy.opentrades.entry_id(0)
        strategy.close(lid)
        a.activeClose := true
        a.activeClose
    array.clear(id = a.signals)
````
