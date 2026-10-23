#property copyright "Evgeniy Chumakov | © Copyright 2026"
#property description "A modification of the ZigZag indicator, where the reversal moment is determined not by a fixed percentage, but by reaching a specified ratio of the current price to the last local extremum."
#property version "1.0"
#property link "https://www.mql5.com/ru/users/jack857752"
#property strict

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_label1 "High Extremum"
#property indicator_label2 "Low Extremum"

input double StepRatio = 1.005; // Step Ratio
input int LineWidth = 2; // Line Width
input color LineColor = clrYellow; // Color

double ArrayHighZZ[]; // High Extremum ZZ
double ArrayLowZZ[];  // Low Extremum ZZ
double ArrayTypeZZ[]; // ZigZag direction buffer
double ArrayHighBarZZ[]; // ZigZag maximum bar location
double ArrayLowBarZZ[];  // ZigZag minimum bar location
double ArrayHighLast[]; // Last maximum value
double ArrayLowLast[]; // Last minimum value

//+------------------------------------------------------------------+
int OnInit(){

ArraySetAsSeries(ArrayHighZZ,true);
ArraySetAsSeries(ArrayLowZZ,true);
ArraySetAsSeries(ArrayTypeZZ,true);
ArraySetAsSeries(ArrayHighBarZZ,true);
ArraySetAsSeries(ArrayLowBarZZ,true);
ArraySetAsSeries(ArrayHighLast,true);
ArraySetAsSeries(ArrayLowLast,true);

SetIndexBuffer(0,ArrayHighZZ,INDICATOR_DATA);
SetIndexStyle(0,DRAW_ZIGZAG,STYLE_SOLID,LineWidth,LineColor);
   
SetIndexBuffer(1,ArrayLowZZ,INDICATOR_DATA);
SetIndexStyle(1,DRAW_ZIGZAG,STYLE_SOLID,LineWidth,LineColor);

SetIndexBuffer(2,ArrayTypeZZ,INDICATOR_CALCULATIONS);
SetIndexStyle(2,DRAW_NONE,STYLE_SOLID,0,clrNONE);
  
SetIndexBuffer(3,ArrayHighBarZZ,INDICATOR_CALCULATIONS);
SetIndexStyle(3,DRAW_NONE,STYLE_SOLID,0,clrNONE);
  
SetIndexBuffer(4,ArrayLowBarZZ,INDICATOR_CALCULATIONS);
SetIndexStyle(4,DRAW_NONE,STYLE_SOLID,0,clrNONE);   

SetIndexBuffer(5,ArrayHighLast,INDICATOR_CALCULATIONS);
SetIndexStyle(5,DRAW_NONE,STYLE_SOLID,0,clrNONE);

SetIndexBuffer(6,ArrayLowLast,INDICATOR_CALCULATIONS);
SetIndexStyle(6,DRAW_NONE,STYLE_SOLID,0,clrNONE);

IndicatorSetInteger(INDICATOR_DIGITS,Digits());
IndicatorSetString(INDICATOR_SHORTNAME,"RatioZigZag");

return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void OnDeinit(const int reason){

}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]){

// Checking for the minimum number of bars to calculate
if(rates_total < 3){return(0);}

// Setting array indexing as in timeseries
ArraySetAsSeries(open,true);
ArraySetAsSeries(high,true);
ArraySetAsSeries(low,true);
ArraySetAsSeries(close,true);

// Checking and calculating the number of calculated bars
int total = rates_total - 2;
int limit = rates_total - IndicatorCounted();

if(limit > 1){

limit = total;

ArrayInitialize(ArrayHighZZ,EMPTY_VALUE);
ArrayInitialize(ArrayLowZZ,EMPTY_VALUE);
ArrayInitialize(ArrayTypeZZ,EMPTY_VALUE);
ArrayInitialize(ArrayHighBarZZ,EMPTY_VALUE);
ArrayInitialize(ArrayLowBarZZ,EMPTY_VALUE);
ArrayInitialize(ArrayHighLast,EMPTY_VALUE);
ArrayInitialize(ArrayLowLast,EMPTY_VALUE);

CalcStartingExtremes(limit,high,low); // Let's get the starting point for ZigZag
}
//--------------------------------------------------//

// Calculating the indicator
for(int i = limit; i >= 0; i--){

if(ArrayTypeZZ[i + 1] != EMPTY_VALUE && ArrayTypeZZ[i + 1] > 0){Calculate_High_Extremum(i,high,low);}
if(ArrayTypeZZ[i + 1] != EMPTY_VALUE && ArrayTypeZZ[i + 1] < 0){Calculate_Low_Extremum(i,high,low);}
}
//--------------------------------------------------//

return(rates_total);
}
//+------------------------------------------------------------------+
//| Calculation High Extremum                                        |
//+------------------------------------------------------------------+
void Calculate_High_Extremum(const int index, const double &high[], const double &low[]){

double PriceHigh = high[index]; // Current maximum price value
double PriceLow = low[index]; // Current minimum price value

double EventHigh = False; // High point ZZ update event
double EventLow = False; // Low point ZZ update event

double MinZZParametr = MathLog(PriceLow) - MathLog(ArrayHighLast[index + 1]);

// Updating and redrawing the maximum extremum
if(PriceHigh > ArrayHighLast[index + 1]){

EventHigh = True;

ArrayTypeZZ[index] = 1;

ArrayHighZZ[(int)ArrayHighBarZZ[index + 1]] = EMPTY_VALUE;
ArrayHighZZ[index] = PriceHigh;

ArrayHighBarZZ[index] = index;
ArrayLowBarZZ[index] = ArrayLowBarZZ[index + 1];

ArrayHighLast[index] = PriceHigh;
ArrayLowLast[index] = ArrayLowLast[index + 1];
}
//--------------------------------------------------------//

// Creating and drawing the minimum extremum
if(MinZZParametr <= -MathLog(StepRatio) && !EventHigh){

EventLow = True;

ArrayTypeZZ[index] = -1;

ArrayLowZZ[index] = PriceLow;

ArrayLowLast[index] = PriceLow;
ArrayHighLast[index] = ArrayHighLast[index + 1];

ArrayHighBarZZ[index] = ArrayHighBarZZ[index + 1];
ArrayLowBarZZ[index] = index;
}
//--------------------------------------------------------//

// No events for forming extremes. Copying past data.
if(!EventHigh && !EventLow){

ArrayTypeZZ[index] = ArrayTypeZZ[index + 1];

ArrayHighBarZZ[index] = ArrayHighBarZZ[index + 1];
ArrayLowBarZZ[index] = ArrayLowBarZZ[index + 1];

ArrayHighLast[index] = ArrayHighLast[index + 1];
ArrayLowLast[index] = ArrayLowLast[index + 1];
}
//--------------------------------------------------------//

return;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculation Low Extremum                                         |
//+------------------------------------------------------------------+
void Calculate_Low_Extremum(const int index, const double &high[], const double &low[]){

double PriceHigh = high[index]; // Current maximum price value
double PriceLow = low[index]; // Current minimum price value
   
double EventLow = False; // High point ZZ update event
double EventHigh = False; // Low point ZZ update event

double MaxZZParametr = MathLog(PriceHigh) - MathLog(ArrayLowLast[index + 1]);

// Updating and redrawing the minimum extremum
if(PriceLow < ArrayLowLast[index + 1]){

EventLow = True;

ArrayTypeZZ[index] = -1;

ArrayLowZZ[(int)ArrayLowBarZZ[index + 1]] = EMPTY_VALUE;
ArrayLowZZ[index] = PriceLow;

ArrayLowBarZZ[index] = index;
ArrayHighBarZZ[index] = ArrayHighBarZZ[index + 1];

ArrayHighLast[index] = ArrayHighLast[index + 1];
ArrayLowLast[index] = PriceLow;
}
//--------------------------------------------------------//     

// Creating and drawing the maximum extremum
if(MaxZZParametr >= MathLog(StepRatio) && !EventLow){

EventHigh = True;

ArrayTypeZZ[index] = 1;

ArrayHighZZ[index] = PriceHigh;

ArrayHighLast[index] = PriceHigh;
ArrayLowLast[index] = ArrayLowLast[index + 1];

ArrayHighBarZZ[index] = index;
ArrayLowBarZZ[index] = ArrayLowBarZZ[index + 1];
}
//--------------------------------------------------------//

// No events for forming extremes. Copying past data.
if(!EventHigh && !EventLow){

ArrayTypeZZ[index] = ArrayTypeZZ[index + 1];

ArrayHighBarZZ[index] = ArrayHighBarZZ[index + 1];
ArrayLowBarZZ[index] = ArrayLowBarZZ[index + 1];

ArrayHighLast[index] = ArrayHighLast[index + 1];
ArrayLowLast[index] = ArrayLowLast[index + 1];
}
//--------------------------------------------------------//
      
return;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculation Of Starting Extremes                                 |
//+------------------------------------------------------------------+
int CalcStartingExtremes(const int index, const double &high[], const double &low[]){

int init_index = 0;

for(int period = 2; period < index; period++){

int period_start = index - period; // Measurement start position

int MaxBar = ArrayMaximum(high,period,period_start); // Position (bar) for the maximum price on the measurement interval.
int MinBar = ArrayMinimum(low,period,period_start); // Position (bar) for the minimum price on the measurement interval.

double Max_Price = high[MaxBar]; // The value of the maximum price on the measured interval.
double Min_Price = low[MinBar]; // The value of the minimum price on the measured interval.

double MaxZZParametr = MathLog(Max_Price) - MathLog(Min_Price);
double MinZZParametr = MathLog(Min_Price) - MathLog(Max_Price);

// Formation of the maximum extremum
if(MaxBar != MinBar && MaxBar < MinBar && MaxZZParametr >= MathLog(StepRatio)){

ArrayTypeZZ[period_start] = 1;

ArrayHighZZ[MaxBar] = Max_Price;
ArrayLowZZ[MinBar] = Min_Price;

ArrayHighBarZZ[period_start] = MaxBar;
ArrayLowBarZZ[period_start] = MinBar;

ArrayHighLast[period_start] = Max_Price;
ArrayLowLast[period_start] = Min_Price;

init_index = period_start;
}

if(init_index != 0){break;}
//--------------------------------------------------------//

// Formation of a minimum extremum
if(MaxBar != MinBar && MinBar < MaxBar && MinZZParametr <= -MathLog(StepRatio)){

ArrayTypeZZ[period_start] = -1;

ArrayHighZZ[MaxBar] = Max_Price;
ArrayLowZZ[MinBar] = Min_Price;

ArrayHighBarZZ[period_start] = MaxBar;
ArrayLowBarZZ[period_start] = MinBar;

ArrayHighLast[period_start] = Max_Price;
ArrayLowLast[period_start] = Min_Price;

init_index = period_start;
}

if(init_index != 0){break;}
//--------------------------------------------------------//

}

return(init_index);
}
//+------------------------------------------------------------------+