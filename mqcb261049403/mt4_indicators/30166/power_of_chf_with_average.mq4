//+------------------------------------------------------------------+
//|                                    Power of CHF with average.mq4 |
//|                                                    Jan Opočenský |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Jan Opočenský"
#property link      ""
#property version   "229.201"
#property strict
#property indicator_separate_window
//---------------------------------------------------
#property indicator_buffers    6
#property indicator_color5     Black
//+------------------------------------------------------------------+
#property script_show_inputs 
//------------------------------
enum ModeOfTrend
{
a=1, // Trend
b=2, // Counter-trend
};
//------------------------------
input ModeOfTrend TrendMode=1;
//+------------------------------------------------------------------+
input int Average_Period = 100; // Average_Period
//=======================================================================================================
string CurrencySymbol = "CHF" ;

int a;
int i;
int pos;
string Text_TREND="Mode: TREND";
string Text_COUNTER="Mode: COUNTER-TREND";
color SmallerBarColor   =  clrRed;
color BiggerBarColor   =  clrGreen;
color BarColor;
color IndicatorColor_3=clrRed;
color IndicatorColor_4=clrGreen;
int WindowIndex=ChartWindowFind();//
//======================================================================================================

//---------------------------------------------------

// --- Buffer 1 ---
double Power[];
// --- Buffer 2 ---
double Average_Power[];
// --- Buffer 3 ---
double Averaged_Power_HISTOGRAM[];
// --- Buffer 4 ---
double Averaged_Power_OUTLINE[];
// --- Buffer 5 ---
double Bigger_Bar_Buffer[];
// --- Buffer 6 ---
double Smaller_Bar_Buffer[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
ChartRedraw(WindowIndex);

//==============================================================================================================
// --- Buffer 1 ---
   IndicatorBuffers(1);
   SetIndexBuffer(0,Power);
   SetIndexStyle(0,DRAW_NONE);
// --- Buffer 2 ---   
   IndicatorBuffers(2);
   SetIndexBuffer(1,Average_Power);
   SetIndexStyle(1,DRAW_NONE);
// --- Buffer 3 ---
   IndicatorBuffers(3);
   SetIndexBuffer(2,Averaged_Power_HISTOGRAM);
   SetIndexStyle(2,DRAW_NONE);
// --- Buffer 4 ---
   IndicatorBuffers(4);
   SetIndexBuffer(3,Averaged_Power_OUTLINE);
   SetIndexStyle(3,DRAW_LINE,EMPTY,1,clrBlack);
// --- Buffer 5 ---
   IndicatorBuffers(5);
   SetIndexBuffer(4,Bigger_Bar_Buffer);
   SetIndexStyle(4,DRAW_HISTOGRAM,EMPTY,2,clrGreen);
// --- Buffer 6 ---
   IndicatorBuffers(6);
   SetIndexBuffer(5,Smaller_Bar_Buffer);
   SetIndexStyle(5,DRAW_HISTOGRAM,EMPTY,2,clrRed);


//==============================================================================================================

if (TrendMode==1)
{
//************************************************************************************************
ObjectDelete( "ModeType"+CurrencySymbol);
ObjectCreate( "ModeType"+CurrencySymbol, OBJ_LABEL,WindowIndex,0,0,0,0);
ObjectSet("ModeType"+CurrencySymbol,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
ObjectSet("ModeType"+CurrencySymbol,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
ObjectSet("ModeType"+CurrencySymbol,OBJPROP_XDISTANCE,10);
ObjectSet("ModeType"+CurrencySymbol,OBJPROP_YDISTANCE,5);
ObjectSetText("ModeType"+CurrencySymbol,"Mode: TREND", 8, "Arial",Black);
//************************************************************************************************
}

else
{
//************************************************************************************************
ObjectDelete( "ModeType"+CurrencySymbol);
ObjectCreate( "ModeType"+CurrencySymbol, OBJ_LABEL,WindowIndex,0,0,0,0);
ObjectSet("ModeType"+CurrencySymbol,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
ObjectSet("ModeType"+CurrencySymbol,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
ObjectSet("ModeType"+CurrencySymbol,OBJPROP_XDISTANCE,10);
ObjectSet("ModeType"+CurrencySymbol,OBJPROP_YDISTANCE,5);
ObjectSetText("ModeType"+CurrencySymbol,"Mode: COUNTER-TREND", 8, "Arial",Black);
//************************************************************************************************
}
//===========================================================================================================
   

//********************************************************************

//********************************************************************
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
                const int &spread[])
  {
//----------------------------------------

pos=Bars-IndicatorCounted();//oooooooooooooo

//----------------------------------------
//
//========================================================================================   
for (i=0;i<pos;i++)
//--- 
{
//--- 
   Power[i]=//
   (-iClose("EURCHF",0,i) 
   -iClose("USDCHF",0,i) 
   -iClose("GBPCHF",0,i) 
   -iClose("CADCHF",0,i) 
   -iClose("AUDCHF",0,i) 
   -iClose("NZDCHF",0,i) 
   +(iClose("CHFJPY",0,i)/100))/7
   ;
//---
}
//========================================================================================
//
//========================================================================================   
for (i=0;i<pos;i++)
//--- 
{
//--- 

 Average_Power[i]=iMAOnArray(Power,0,Average_Period,0,MODE_EMA,i);
//---
}
//========================================================================================

//========================================================================================   
for (i=0;i<pos;i++)
//--- 
{
Averaged_Power_OUTLINE[i]    = Power[i] - Average_Power[i];
//--- 
if (SymbolInfoString(Symbol(),SYMBOL_CURRENCY_BASE)== "CHF" && (TrendMode==1) )
{
if (Power[i] > Average_Power[i]) {Bigger_Bar_Buffer[i] = Power[i] - Average_Power[i]; Smaller_Bar_Buffer[i] = 0;}
if (Power[i] < Average_Power[i]) {Bigger_Bar_Buffer[i] = 0; Smaller_Bar_Buffer[i] = Power[i] - Average_Power[i];}
}
//---
if (SymbolInfoString(Symbol(),SYMBOL_CURRENCY_BASE)== "CHF" && (TrendMode==2) )
{
if (Power[i] < Average_Power[i]) {Bigger_Bar_Buffer[i] = Power[i] - Average_Power[i]; Smaller_Bar_Buffer[i] = 0;}
if (Power[i] > Average_Power[i]) {Bigger_Bar_Buffer[i] = 0; Smaller_Bar_Buffer[i] = Power[i] - Average_Power[i];}
}
//---
if (SymbolInfoString(Symbol(),SYMBOL_CURRENCY_PROFIT)== "CHF" && (TrendMode==1) )
{
if (Power[i] < Average_Power[i]) {Bigger_Bar_Buffer[i] = Power[i] - Average_Power[i]; Smaller_Bar_Buffer[i] = 0;}
if (Power[i] > Average_Power[i]) {Bigger_Bar_Buffer[i] = 0; Smaller_Bar_Buffer[i] = Power[i] - Average_Power[i];}
}
//---
if (SymbolInfoString(Symbol(),SYMBOL_CURRENCY_PROFIT)== "CHF" && (TrendMode==2) )
{
if (Power[i] > Average_Power[i]) {Bigger_Bar_Buffer[i] = Power[i] - Average_Power[i]; Smaller_Bar_Buffer[i] = 0;}
if (Power[i] < Average_Power[i]) {Bigger_Bar_Buffer[i] = 0; Smaller_Bar_Buffer[i] = Power[i] - Average_Power[i];}
}
//---
}
//========================================================================================
//   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
ChartRedraw(WindowIndex); 
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
