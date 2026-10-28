#property copyright "Evgeniy Chumakov | © Copyright 2024"
#property description "Candle Size MT4 - The indicator searches for candles on the price chart that are larger than those specified in the settings and marks them on the chart."
#property version "1.0"
#property link "https://www.mql5.com/en/users/jack857752"
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_label1 "Candle Size MT4"
#property indicator_label2 "Candle Size MT4"

//------------------------
enum units_of_calculation
{
Points = 0,  // Points
Percent = 1  // Percent
};

input units_of_calculation type_calc = 0; // Units of Calculation
//------------------------

//------------------------ 
enum between_levels
{
HighLow = 0,     // High/Low
OpenClose = 1,   // Open/Close
UpperShadow = 2, // Upper Shadow
LowerShadow = 3  // Lower Shadow
};

input between_levels levels_calc = 0; // Between Levels
//------------------------

input double Size = 1.0; // Size Definitions

input color Color = clrGreen; // Color
input int ArrowSize = 1; // Arrow Size
input int ArrowCode_1 = 108; // Arrow Code 1
input int ArrowCode_2 = 110; // Arrow Code 2

double BufferUpper[]; 
double BufferLower[];

//+------------------------------------------------------------------+
int OnInit(){

IndicatorSetString(INDICATOR_SHORTNAME,"Candle Size MT4");

SetIndexBuffer(0,BufferUpper,INDICATOR_DATA);
SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,ArrowSize,Color);

SetIndexBuffer(1,BufferLower,INDICATOR_DATA);
SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,ArrowSize,Color);

if(levels_calc == 0 || levels_calc == 1){
SetIndexArrow(0,ArrowCode_1); 
SetIndexArrow(1,ArrowCode_1); 
}else{
SetIndexArrow(0,ArrowCode_2); 
SetIndexArrow(1,ArrowCode_2);
}  
  
return(INIT_SUCCEEDED);
}
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

int total = rates_total - 2;
int limit = rates_total - IndicatorCounted();

if(limit > 1){limit = total;}

// Calculating the indicator
for(int i = limit; i >= 0 && !IsStopped(); i--){

// Point Method
double Point_HighLow = MathAbs(high[i] - low[i])/Point(); 
double Point_CloseOpen = MathAbs(close[i] - open[i])/Point(); 

double Point_UpperShadow = 0;

if(close[i] > open[i]){Point_UpperShadow = MathAbs(high[i] - close[i])/Point();}
if(close[i] < open[i]){Point_UpperShadow = MathAbs(high[i] - open[i])/Point();}
if(close[i] == open[i]){Point_UpperShadow = MathAbs(high[i] - open[i])/Point();}

double Point_LowerShadow = 0;

if(close[i] < open[i]){Point_LowerShadow = MathAbs(low[i] - close[i])/Point();}
if(close[i] > open[i]){Point_LowerShadow = MathAbs(low[i] - open[i])/Point();}
if(close[i] == open[i]){Point_LowerShadow = MathAbs(low[i] - open[i])/Point();}

// points high low
if(type_calc == 0 && levels_calc == 0 && Point_HighLow >= Size){BufferUpper[i] = high[i]; BufferLower[i] = low[i];}

// points open close
if(type_calc == 0 && levels_calc == 1 && Point_CloseOpen >= Size){BufferUpper[i] = open[i]; BufferLower[i] = close[i];}

// points upper shadow
if(type_calc == 0 && levels_calc == 2 && Point_UpperShadow >= Size){BufferUpper[i] = high[i];}

// points lower shadow
if(type_calc == 0 && levels_calc == 3 && Point_LowerShadow >= Size){BufferLower[i] = low[i];}

//---------------------------------------

// Percent Method
double Percent_HighLow = (MathAbs(high[i] - low[i])/low[i]) * 100.0; 
double Percent_CloseOpen = (MathAbs(close[i] - open[i])/open[i]) * 100.0; 

double Percent_UpperShadow = 0;

if(close[i] > open[i]){Percent_UpperShadow = (MathAbs(high[i] - close[i])/close[i]) * 100.0;}
if(close[i] < open[i]){Percent_UpperShadow = (MathAbs(high[i] - open[i])/open[i]) * 100.0;}
if(close[i] == open[i]){Percent_UpperShadow = (MathAbs(high[i] - open[i])/open[i]) * 100.0;}

double Percent_LowerShadow = 0;

if(close[i] < open[i]){Percent_LowerShadow = (MathAbs(low[i] - close[i])/close[i]) * 100.0;}
if(close[i] > open[i]){Percent_LowerShadow = (MathAbs(low[i] - open[i])/open[i]) * 100.0;}
if(close[i] == open[i]){Percent_LowerShadow = (MathAbs(low[i] - open[i])/open[i]) * 100.0;}

// percents high low
if(type_calc == 1 && levels_calc == 0 && Percent_HighLow >= Size){BufferUpper[i] = high[i]; BufferLower[i] = low[i];}

// percents open close
if(type_calc == 1 && levels_calc == 1 && Percent_CloseOpen >= Size){BufferUpper[i] = open[i]; BufferLower[i] = close[i];}

// percents upper shadow
if(type_calc == 1 && levels_calc == 2 && Percent_UpperShadow >= Size){BufferUpper[i] = high[i];}

// percents lower shadow
if(type_calc == 1 && levels_calc == 3 && Percent_LowerShadow >= Size){BufferLower[i] = low[i];}

//---------------------------------------

} // i end

return(rates_total);
}
//+------------------------------------------------------------------+