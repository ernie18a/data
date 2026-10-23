//+------------------------------------------------------------------+
//|                                               Custom_Pattern.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property description   "The indicator provides the user to"
#property description   "specify a custom format pattern candle"
#property description   "and draws patterns on the chart"
#property description   "------------------------------------"
#property description   "U - UP candle (Close>Open)"
#property description   "D - DOWN candle (Close<Open)"
#property description   "N - Nothing (UP or DOWN)"

//--- plot DIR
#property indicator_label1  "DIR"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot REV
#property indicator_label2  "REV"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input string            InpPattern     =  "UND";      // Pattern (U - up, N - nothing, D - down)
input ENUM_INPUT_YES_NO InpShowReverce =  INPUT_NO;   // Show reverse pattern
//--- indicator buffers
double         BufferDIR[];
double         BufferREV[];
//--- global variables
uchar          array[];
int            length;
string         pattern;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   pattern=InpPattern;
   StringTrimLeft(pattern);
   StringTrimRight(pattern);
   if(!StringToLower(pattern))
     {
      Print("Failed to convert characters of string '",pattern,"' to lowercase. Error: ",GetLastError());
      return INIT_FAILED;
     }
   length=StringLen(pattern);
   ResetLastError();
   if(ArrayResize(array,length)==length)
      StringToCharArray(pattern,array);
   else
     {
      Print("Error filling the array of characters: ",GetLastError());
      return INIT_FAILED;
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDIR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferREV,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,119);
   PlotIndexSetInteger(1,PLOT_ARROW,119);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Custom pattern");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDIR,true);
   ArraySetAsSeries(BufferREV,true);
   ArraySetAsSeries(array,false);
//---
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<length+1) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-length-1;
      ArrayInitialize(BufferDIR,EMPTY_VALUE);
      ArrayInitialize(BufferREV,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(DirectPattern(i,open,close))
         BufferDIR[i]=high[i];
      if(InpShowReverce && ReversePattern(i,open,close))
         BufferREV[i]=low[i];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DirectPattern(const int shift,const double &open[],const double &close[])
  {
   string s="";
   //string Pat=StringTrimLeft(StringTrimRight(Pattern));
   bool f=true;
   for(int i=1; i<=length; i++)
     {
      s=CharToString(array[length-i]);//StringSubstr(Pat,LengthPattern-i,1);
      if((s=="u") && (close[shift+i-1]<=open[shift+i-1])) f=false;
      if((s=="d") && (close[shift+i-1]>=open[shift+i-1])) f=false;
     }
   return f;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ReversePattern(const int shift,const double &open[],const double &close[])
  {
   string s="";
   //string Pat=StringTrimLeft(StringTrimRight(Pattern));
   bool f=true;
   for(int i=1; i<=length; i++)
     {
      s=CharToString(array[length-i]);//StringSubstr(Pat,LengthPattern-i,1);
      if((s=="u") && (close[shift+i-1]>=open[shift+i-1])) f=false;
      if((s=="d") && (close[shift+i-1]<=open[shift+i-1])) f=false;
     }
   return f;
  }
//+------------------------------------------------------------------+
