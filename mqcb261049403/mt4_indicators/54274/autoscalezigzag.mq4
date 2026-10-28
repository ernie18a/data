#property copyright "Evgeniy Chumakov | © Copyright 2024"
#property description "ZigZag with automatic step size detection for changing wave direction."
#property version "1.0"
#property link "https://www.mql5.com/en/users/jack857752"
#property strict

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_label1 "High Point ZZ"
#property indicator_label2 "Low Point ZZ"

input double ZZScale = 1.0; // Scale
input int ZZLineWidth = 2; // Line Width
input color ZZColor = clrYellow; // Color

double ArrayHighZZ[]; // High point ZZ
double ArrayLowZZ[];  // Low point ZZ
double ArrayTypeZZ[]; // ZigZag direction buffer
double ArrayHighBarZZ[]; // ZigZag maximum bar location
double ArrayLowBarZZ[];  // ZigZag minimum bar location
double ArrayHighLast[]; // Last maximum value
double ArrayLowLast[]; // Last minimum value

double SpecDivSymb; // Special Divider / Symbol Correction

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
SetIndexStyle(0,DRAW_ZIGZAG,STYLE_SOLID,ZZLineWidth,ZZColor);
   
SetIndexBuffer(1,ArrayLowZZ,INDICATOR_DATA);
SetIndexStyle(1,DRAW_ZIGZAG,STYLE_SOLID,ZZLineWidth,ZZColor);

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
IndicatorSetString(INDICATOR_SHORTNAME,"AutoScaleZigZag");

// Let's set the values ​​of the special divisor
int Find = StringFind(Symbol(),"JPY",0); // 

if(Find != -1){SpecDivSymb = 100.0;}else{SpecDivSymb = 1.0;}
//--------------------------------------------------//

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

if(ArrayTypeZZ[i + 1] != EMPTY_VALUE && ArrayTypeZZ[i + 1] > 0){HighZZPoint(i,high,low);}
if(ArrayTypeZZ[i + 1] != EMPTY_VALUE && ArrayTypeZZ[i + 1] < 0){LowZZPoint(i,high,low);}
}
//--------------------------------------------------//

return(rates_total);
}
//+------------------------------------------------------------------+
//| Calculation High ZZ Point                                        |
//+------------------------------------------------------------------+
void HighZZPoint(const int index, const double &high[], const double &low[]){

double PriceHigh = high[index]; // Current maximum price value
double PriceLow = low[index]; // Current minimum price value

double EventHigh = False; // High point ZZ update event
double EventLow = False; // Low point ZZ update event

double R_Step = MathAbs((ArrayHighLast[index + 1] - PriceLow)/PriceLow) * 100.0; // Price range in percent
double StepDownLevel = PriceLow/SpecDivSymb/ZZScale; // Step to form a segment down

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
if(R_Step >= StepDownLevel && !EventHigh){

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
//| Calculation Low ZZ Point                                         |
//+------------------------------------------------------------------+
void LowZZPoint(const int index, const double &high[], const double &low[]){

double PriceHigh = high[index]; // Current maximum price value
double PriceLow = low[index]; // Current minimum price value
   
double EventLow = False; // High point ZZ update event
double EventHigh = False; // Low point ZZ update event

double R_Step = MathAbs((ArrayLowLast[index + 1] - PriceHigh)/PriceHigh) * 100.0; // Price range in percent
double StepUpLevel = PriceHigh/SpecDivSymb/ZZScale; // Step to form a segment up

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
if(R_Step >= StepUpLevel && !EventLow){

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

double R_Step = MathAbs((Max_Price - Min_Price)/Min_Price) * 100.0; // Price range in percent

double StepUpLevel = Max_Price/SpecDivSymb/ZZScale; // Step to form a segment up
double StepDownLevel = Min_Price/SpecDivSymb/ZZScale; // Step to form a segment down

// Formation of the maximum extremum
if(MaxBar != MinBar && MaxBar < MinBar && R_Step >= StepUpLevel){

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
if(MaxBar != MinBar && MinBar < MaxBar && R_Step >= StepDownLevel){

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