Calculation: Two Up = high > preceding bar high AND low >= preceding bar low
Calculation: Two Down = low < preceding bar low AND high <= preceding bar high
Calculation: Failed Two Up = Two Up AND close >= preceding bar low AND close <= preceding bar high
Calculation: Failed Two Down = Two Down AND close >= preceding bar low AND close <= preceding bar high
Long: Two Up AND NOT Failed Two Up OR Failed Two Up OR close >= open on any of the five dashboard timeframes' current bars
Short: Two Down AND NOT Failed Two Down OR Failed Two Down OR close < open on any of the five dashboard timeframes' current bars