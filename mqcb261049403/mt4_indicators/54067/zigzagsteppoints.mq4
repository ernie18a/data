#property copyright "Evgeniy Chumakov | © Copyright 2026"
#property description "ZigZag with Step in Points."
#property version "2.0"
#property link "https://www.mql5.com/ru/users/jack857752"
#property strict

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_label1 "High Point ZZ"
#property indicator_label2 "Low Point ZZ"

input int InpZZStep = 500; // Step in Points

input int ZZLineWidth = 2; // Line Width
input color ZZColor = clrMediumSeaGreen; // ZigZag Color

input bool ZZShowLevels = False; // Draw Levels
input color ZZLevelsColor = clrSlateGray; // Levels Color

input bool ZZDrawWaveSize = False; // Draw Wave Size
input string ZZFont = "Arial"; // Font 
input int ZZTextSize = 10; // Size
input color ZZTextColor = clrDarkKhaki; // Color
input int ZZTextIndent = 100; // Indent From Levels

input bool FILE_WRITE_ = False; // FILE WRITE

double ArrayHighZZ[]; // High point ZZ
double ArrayLowZZ[];  // Low point ZZ
double ArrayTypeZZ[]; // ZigZag direction buffer
double ArrayHighBarZZ[]; // ZigZag maximum bar location
double ArrayLowBarZZ[];  // ZigZag minimum bar location
double ArrayHighLast[]; // Last maximum value
double ArrayLowLast[]; // Last minimum value
double ArrayWaveSize[]; // Wave size between extremes in points

string SpecialIndicatorName = ""; // special indicator name

//+------------------------------------------------------------------+
int OnInit(){

ArraySetAsSeries(ArrayHighZZ,true);
ArraySetAsSeries(ArrayLowZZ,true);
ArraySetAsSeries(ArrayTypeZZ,true);
ArraySetAsSeries(ArrayHighBarZZ,true);
ArraySetAsSeries(ArrayLowBarZZ,true);
ArraySetAsSeries(ArrayHighLast,true);
ArraySetAsSeries(ArrayLowLast,true);
ArraySetAsSeries(ArrayWaveSize,true);

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

SetIndexBuffer(7,ArrayWaveSize,INDICATOR_CALCULATIONS);
SetIndexStyle(7,DRAW_NONE,STYLE_SOLID,0,clrNONE);

IndicatorSetInteger(INDICATOR_DIGITS,Digits());

// Let's set a special indicator name
SpecialIndicatorName = "ZigZagStepPoints [" + IntegerToString(ChartIndicatorsTotal(ChartID(),0),1,' ') + "] ";

IndicatorSetString(INDICATOR_SHORTNAME,SpecialIndicatorName);

return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void OnDeinit(const int reason){

bool DeinitSuccessful = False; // Deinitialization successful

while(!DeinitSuccessful){

int indicator_object_counter = 0;

int ObjTotal = ObjectsTotal(ChartID(),0,-1); // Total number of objects

for(int i = 0; i < ObjTotal; i++){

string ObjName = ObjectName(ChartID(),i,0,-1); // Let's get the name of the object

int Find = StringFind(ObjName,SpecialIndicatorName,0); // Search in the object name for belonging to this indicator

if(Find != -1){ObjectDelete(ObjName); indicator_object_counter++;}
}

if(indicator_object_counter == 0){DeinitSuccessful = True;}
}

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
ArrayInitialize(ArrayWaveSize,EMPTY_VALUE);

CalcStartingExtremes(limit,high,low); // Let's get the starting point for ZigZag
}
//--------------------------------------------------//

// Calculating the indicator
for(int i = limit; i >= 0; i--){

if(ArrayTypeZZ[i + 1] != EMPTY_VALUE && ArrayTypeZZ[i + 1] > 0){HighZZPoint(i,high,low);}
if(ArrayTypeZZ[i + 1] != EMPTY_VALUE && ArrayTypeZZ[i + 1] < 0){LowZZPoint(i,high,low);}
}
//--------------------------------------------------//

// We will display the latest extreme levels if necessary.
if(ZZShowLevels){

string HighLineName = SpecialIndicatorName + " Max";

bool High_Line = ObjectCreate(ChartID(),HighLineName,OBJ_HLINE,0,0,0,0,0);
ObjectSetInteger(ChartID(),HighLineName,OBJPROP_COLOR,ZZLevelsColor);
ObjectSetInteger(ChartID(),HighLineName,OBJPROP_STYLE,STYLE_DOT);
ObjectSetInteger(ChartID(),HighLineName,OBJPROP_WIDTH,1);
ObjectSetInteger(ChartID(),HighLineName,OBJPROP_HIDDEN,false);
ObjectSetDouble(ChartID(),HighLineName,OBJPROP_PRICE1,ArrayHighLast[0]);
ObjectSetText(HighLineName,"High Level ZZ",0,NULL,clrNONE);

string LowLineName = SpecialIndicatorName + " Min";

bool Low_Line = ObjectCreate(ChartID(),LowLineName,OBJ_HLINE,0,0,0,0,0);
ObjectSetInteger(ChartID(),LowLineName,OBJPROP_COLOR,ZZLevelsColor);
ObjectSetInteger(ChartID(),LowLineName,OBJPROP_STYLE,STYLE_DOT);
ObjectSetInteger(ChartID(),LowLineName,OBJPROP_WIDTH,1);
ObjectSetInteger(ChartID(),LowLineName,OBJPROP_HIDDEN,false);
ObjectSetDouble(ChartID(),LowLineName,OBJPROP_PRICE1,ArrayLowLast[0]);
ObjectSetText(LowLineName,"Low Level ZZ",0,NULL,clrNONE);
}
//--------------------------------------------------//

// We will display the wave size if necessary.
if(ZZDrawWaveSize){

for(int i = limit; i >= 0; i--){

string ObjName = SpecialIndicatorName + " extr#" + IntegerToString(i,1,' '); // Let's set the object name

ObjWaveSize(ObjName,i,high,low,ArrayTypeZZ,ArrayWaveSize); // Let's run the function to create a wave size object

if(ArrayWaveSize[i] == EMPTY_VALUE){ObjectDelete(ObjName);} // let's remove the extra object
} 

}
//--------------------------------------------------//

// FILE WRITE
if(FILE_WRITE_){

ResetLastError();

int filehandle = FileOpen(Symbol() + "_ZZStepPoints_" + IntegerToString(InpZZStep,1,' ') + ".csv",FILE_WRITE|FILE_CSV);
   

if(filehandle != INVALID_HANDLE){
    
// -----      
FileWrite(filehandle," Date , Time , Price , Range ");
    
for(int i = rates_total - 2; i >= 0; i--){

if(ArrayWaveSize[i] != EMPTY_VALUE){

double Price = ArrayHighZZ[i]; if(Price == EMPTY_VALUE){Price = ArrayLowZZ[i];}

// --   
string FileWrite_ = "";

// Date
StringAdd(FileWrite_,TimeToStr(time[i],TIME_DATE));      
StringAdd(FileWrite_," , ");       

// Time
StringAdd(FileWrite_,TimeToStr(time[i],TIME_MINUTES));      
StringAdd(FileWrite_," , ");       

// Price 
StringAdd(FileWrite_,DoubleToStr(Price,Digits));      
StringAdd(FileWrite_," , "); 

// Range
StringAdd(FileWrite_,DoubleToStr(ArrayWaveSize[i],0));      

FileWrite(filehandle,FileWrite_);
      
//--
}

//--
}

//--

FileClose(filehandle);
}else{Print("Error File Write = ",GetLastError());} 

//-
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

double R_Step = MathAbs(ArrayHighLast[index + 1] - PriceLow)/Point();

// Updating and redrawing the maximum extremum
if(PriceHigh > ArrayHighLast[index + 1]){

EventHigh = True;

ArrayTypeZZ[index] = 1;

ArrayHighZZ[(int)ArrayHighBarZZ[index + 1]] = EMPTY_VALUE;
ArrayHighZZ[index] = PriceHigh;

ArrayWaveSize[(int)ArrayHighBarZZ[index + 1]] = EMPTY_VALUE;
ArrayWaveSize[index] = NormalizeDouble(MathAbs(PriceHigh - ArrayLowLast[index + 1])/Point(),0);

ArrayHighBarZZ[index] = index;
ArrayLowBarZZ[index] = ArrayLowBarZZ[index + 1];

ArrayHighLast[index] = PriceHigh;
ArrayLowLast[index] = ArrayLowLast[index + 1];
}
//--------------------------------------------------------//

// Creating and drawing the minimum extremum
if(R_Step >= InpZZStep && !EventHigh){

EventLow = True;

ArrayTypeZZ[index] = -1;

ArrayLowZZ[index] = PriceLow;

ArrayWaveSize[index] = NormalizeDouble(MathAbs(PriceLow - ArrayHighLast[index + 1])/Point(),0);

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

double R_Step = MathAbs(ArrayLowLast[index + 1] - PriceHigh)/Point();

// Updating and redrawing the minimum extremum
if(PriceLow < ArrayLowLast[index + 1]){

EventLow = True;

ArrayTypeZZ[index] = -1;

ArrayLowZZ[(int)ArrayLowBarZZ[index + 1]] = EMPTY_VALUE;
ArrayLowZZ[index] = PriceLow;

ArrayWaveSize[(int)ArrayLowBarZZ[index + 1]] = EMPTY_VALUE;
ArrayWaveSize[index] = NormalizeDouble(MathAbs(PriceLow - ArrayHighLast[index + 1])/Point(),0);

ArrayLowBarZZ[index] = index;
ArrayHighBarZZ[index] = ArrayHighBarZZ[index + 1];

ArrayHighLast[index] = ArrayHighLast[index + 1];
ArrayLowLast[index] = PriceLow;
}
//--------------------------------------------------------//     

// Creating and drawing the maximum extremum
if(R_Step >= InpZZStep && !EventLow){

EventHigh = True;

ArrayTypeZZ[index] = 1;

ArrayHighZZ[index] = PriceHigh;

ArrayWaveSize[index] = NormalizeDouble(MathAbs(PriceHigh - ArrayLowLast[index + 1])/Point(),0);

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

int period_start = index - period;

int MaxBar = ArrayMaximum(high,period,period_start);
int MinBar = ArrayMinimum(low,period,period_start);

double MaximumLev = high[MaxBar]; 
double MinimumLev = low[MinBar];

double R_step = MathAbs(MaximumLev - MinimumLev)/Point();

// formation of the maximum extremum
if(MaxBar != MinBar && MaxBar < MinBar && R_step >= InpZZStep){

ArrayTypeZZ[period_start] = 1;

ArrayHighZZ[MaxBar] = MaximumLev;
ArrayLowZZ[MinBar] = MinimumLev;

ArrayHighBarZZ[period_start] = MaxBar;
ArrayLowBarZZ[period_start] = MinBar;

ArrayHighLast[period_start] = MaximumLev;
ArrayLowLast[period_start] = MinimumLev;

init_index = period_start;
}

if(init_index != 0){break;}
//--------------------------------------------------------//

// formation of a minimum extremum
if(MaxBar != MinBar && MinBar < MaxBar && R_step >= InpZZStep){

ArrayTypeZZ[period_start] = -1;

ArrayHighZZ[MaxBar] = MaximumLev;
ArrayLowZZ[MinBar] = MinimumLev;

ArrayHighBarZZ[period_start] = MaxBar;
ArrayLowBarZZ[period_start] = MinBar;

ArrayHighLast[period_start] = MaximumLev;
ArrayLowLast[period_start] = MinimumLev;

init_index = period_start;
}

if(init_index != 0){break;}
//--------------------------------------------------------//

}

return(init_index);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Wavelength Drawing Function                                      |
//+------------------------------------------------------------------+
void ObjWaveSize(string ObjName, const int index, const double &high[], const double &low[], const double &type[], const double &size[]){

if(size[index] == EMPTY_VALUE){return;} // There are no conditions to create an object / exit

datetime ObjTime = iTime(Symbol(),PERIOD_CURRENT,index); // Time for the object

//  Let's set a price for the object / indent
double ObjPrice = 0; 

if(type[index] > 0){ObjPrice = high[index] + ZZTextIndent * Point();}
if(type[index] < 0){ObjPrice = low[index] - ZZTextIndent * Point();}

string ObjText = DoubleToStr(size[index],0); // Object text

bool Object_ = ObjectCreate(ChartID(),ObjName,OBJ_TEXT,0,ObjTime,ObjPrice); // Let's create a graphic object

//--- let's set the text
   ObjectSetString(ChartID(),ObjName,OBJPROP_TEXT,ObjText);
//--- set the text font
   ObjectSetString(ChartID(),ObjName,OBJPROP_FONT,ZZFont);
//--- set the font size
   ObjectSetInteger(ChartID(),ObjName,OBJPROP_FONTSIZE,ZZTextSize);
//--- set the angle of the text
   ObjectSetDouble(ChartID(),ObjName,OBJPROP_ANGLE,0);
//--- let's set the binding method
if(type[index] > 0){ ObjectSetInteger(ChartID(),ObjName,OBJPROP_ANCHOR,ANCHOR_UPPER);}
if(type[index] < 0){ ObjectSetInteger(ChartID(),ObjName,OBJPROP_ANCHOR,ANCHOR_LOWER);}
//--- let's set the color
   ObjectSetInteger(ChartID(),ObjName,OBJPROP_COLOR,ZZTextColor);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(ChartID(),ObjName,OBJPROP_BACK,true);
//--- enable (true) or disable (false) the mode of moving an object with the mouse
   ObjectSetInteger(ChartID(),ObjName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(ChartID(),ObjName,OBJPROP_SELECTED,false);
//--- hide (true) or show (false) the name of the graphic object in the list of objects
   ObjectSetInteger(ChartID(),ObjName,OBJPROP_HIDDEN,false);
//--- set the priority for receiving the mouse click event on the chart
   ObjectSetInteger(ChartID(),ObjName,OBJPROP_ZORDER,0);

return;  
}
//+------------------------------------------------------------------+