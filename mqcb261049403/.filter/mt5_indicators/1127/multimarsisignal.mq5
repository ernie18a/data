//+------------------------------------------------------------------+
//|                                             MultiMaRsiSignal.mq5 | 
//|                             Copyright © 2012,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description ""
//--- indicator version number
#property version   "1.00"
//--- drawing indicator in a separate window
#property indicator_separate_window
//--- indicator subwindow fixed height in pixels 
#property indicator_height 60
//--- The lower and upper limits of the scale separate of indicator window
#property indicator_maximum +5.9
#property indicator_minimum +0.4
//+-----------------------------------+
//| Declaration of constants          |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
#define INDTOTAL 5// The constant for the number of displayed indicators
//+-----------------------------------+
//--- number of indicator buffers
#property indicator_buffers 20 // INDTOTAL*4
//--- total number of used graphical plots
#property indicator_plots   10 // INDTOTAL*2
//+-----------------------------------+
//| Indicator 1 drawing parameters    |
//+-----------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_COLOR_LINE
//--- the following colors are used for the indicator line
#property indicator_color1 clrMagenta,clrGray,clrLime
//--- indicator line is a solid one
#property indicator_style1  STYLE_SOLID
//--- the width of indicator line is 3
#property indicator_width1  3
//--- displaying the indicator label
#property indicator_label1  "Signal line 1";
//+-----------------------------------+
//| Indicator 1 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 1 as a label
#property indicator_type2   DRAW_COLOR_ARROW
//--- color which used for the label
#property indicator_color2 clrRed,clrDarkGray,clrTeal
//--- indicator line width is equal to 5
#property indicator_width2  5
//--- displaying the indicator label
#property indicator_label2  "Trend 1";
//+-----------------------------------+
//| Indicator 2 drawing parameters    |
//+-----------------------------------+
//--- dawing the indicator 2 as a line
#property indicator_type3   DRAW_COLOR_LINE
//--- the following colors are used for the indicator line
#property indicator_color3 clrMagenta,clrGray,clrLime
//--- indicator line is a solid one
#property indicator_style3  STYLE_SOLID
//--- the width of indicator line is 3
#property indicator_width3  3
//--- displaying the indicator label
#property indicator_label3  "Signal line 2";
//+-----------------------------------+
//| Indicator 2 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 2 as a label
#property indicator_type4   DRAW_COLOR_ARROW
//--- color which used for the label
#property indicator_color4 clrRed,clrDarkGray,clrTeal
//--- indicator line width is equal to 5
#property indicator_width4  5
//--- displaying the indicator label
#property indicator_label4  "Trend 2";
//+-----------------------------------+
//| Indicator 3 drawing parameters    |
//+-----------------------------------+
//--- drawing indicator 3 as line
#property indicator_type5   DRAW_COLOR_LINE
//--- the following colors are used for the indicator line
#property indicator_color5 clrMagenta,clrGray,clrLime
//--- indicator line is a solid one
#property indicator_style5  STYLE_SOLID
//--- the width of indicator line is 3
#property indicator_width5  3
//--- displaying the indicator label
#property indicator_label5  "Signal line 3";
//+-----------------------------------+
//| Indicator 3 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 3 as a label
#property indicator_type6   DRAW_COLOR_ARROW
//--- color which used for the label
#property indicator_color6 clrRed,clrDarkGray,clrTeal
//--- indicator line width is equal to 5
#property indicator_width6  5
//--- displaying the indicator label
#property indicator_label6  "Trend 3";
//+-----------------------------------+
//| Indicator 4 drawing parameters    |
//+-----------------------------------+
//--- drawing indicator 4 as line
#property indicator_type7   DRAW_COLOR_LINE
//--- the following colors are used for the indicator line
#property indicator_color7 clrMagenta,clrGray,clrLime
//--- indicator line is a solid one
#property indicator_style7 STYLE_SOLID
//--- the width of indicator line is 3
#property indicator_width7  3
//--- displaying the indicator label
#property indicator_label7  "Signal line 4";
//+-----------------------------------+
//| Indicator 4 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 4 as a label
#property indicator_type8   DRAW_COLOR_ARROW
//--- color which used for the label
#property indicator_color8 clrRed,clrDarkGray,clrTeal
//--- indicator line width is equal to 5
#property indicator_width8  5
//--- displaying the indicator label
#property indicator_label8  "Trend 4";
//+-----------------------------------+
//| Indicator 5 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 5 as a line
#property indicator_type9   DRAW_COLOR_LINE
//--- the following colors are used for the indicator line
#property indicator_color9 clrMagenta,clrGray,clrLime
//--- indicator line is a solid one
#property indicator_style9 STYLE_SOLID
//--- the width of indicator line is 3
#property indicator_width9  3
//--- displaying the indicator label
#property indicator_label9  "Signal line 5";
//+-----------------------------------+
//| Indicator 5 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 5 as a label
#property indicator_type10   DRAW_COLOR_ARROW
//--- color which used for the label
#property indicator_color10 clrRed,clrDarkGray,clrTeal
//--- indicator line width is equal to 5
#property indicator_width10  5
//--- displaying the indicator label
#property indicator_label10  "Trend 5";
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame0=PERIOD_H12; //1 Chart period
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_H8;  //2 Chart period
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H4;  //3 Chart period
input ENUM_TIMEFRAMES TimeFrame3=PERIOD_H2;  //4 Chart period
input ENUM_TIMEFRAMES TimeFrame4=PERIOD_H1;  //5 Chart period
//---
input uint nPeriodRsi=3;
input ENUM_APPLIED_PRICE nRSIPrice=PRICE_WEIGHTED;
input uint nPeriodRsiLong=13;
input ENUM_APPLIED_PRICE nRSIPriceLong=PRICE_MEDIAN;
input uint nPeriodMa=5;
input  ENUM_MA_METHOD nMAType=MODE_EMA;
input ENUM_APPLIED_PRICE nMAPrice=PRICE_CLOSE;
input uint nPeriodMaLong=10;
input  ENUM_MA_METHOD nMATypeLong=MODE_EMA;
input ENUM_APPLIED_PRICE nMAPriceLong=PRICE_CLOSE;
//+-----------------------------------+
//--- declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Get timeframe as string                                          |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
//+------------------------------------------------------------------+
//|  Class of indicator buffers                                      |
//+------------------------------------------------------------------+  
class CIndBuffers
  {
   //---
public:
   double            m_ArrayBuffer[];
   double            m_ColorArrayBuffer[];
   double            m_LineBuffer[];
   double            m_ColorLineBuffer[];
   int               m_Handle[4];
   ENUM_TIMEFRAMES   m_TimeFrame;
   //--- 
  };
//--- declaration of dynamic arrays that further will be used as indicator buffers
CIndBuffers Ind[INDTOTAL];
//+------------------------------------------------------------------+   
//| MaRsi indicator initialization function                          | 
//+------------------------------------------------------------------+ 
bool IndInit(uint Number)
  {
//--- checking correctness of the chart periods
   if(Ind[Number].m_TimeFrame<Period() && Ind[Number].m_TimeFrame!=PERIOD_CURRENT)
     {
      Print("IndInit(",Number,"): MaRsi indicator chart period cannot be less than the current chart period");
      Init=false;
      return(false);
     }
//--- obtaining the indicators handle
   Ind[Number].m_Handle[0]=iRSI(NULL,Ind[Number].m_TimeFrame,nPeriodRsi,nRSIPrice);
   Ind[Number].m_Handle[1]=iRSI(NULL,Ind[Number].m_TimeFrame,nPeriodRsiLong,nRSIPriceLong);
   Ind[Number].m_Handle[2]=iMA(NULL,Ind[Number].m_TimeFrame,nPeriodMa,0,nMAType,nMAPrice);
   Ind[Number].m_Handle[3]=iMA(NULL,Ind[Number].m_TimeFrame,nPeriodMaLong,0,nMATypeLong,nMAPriceLong);
//---
   if(Ind[Number].m_Handle[0]==INVALID_HANDLE) {Print(" Failed to get handle of the iRSI indicator"); Init=false; return(false);}
   if(Ind[Number].m_Handle[1]==INVALID_HANDLE) {Print(" Failed to get handle of the iRSI indicator"); Init=false; return(false);}
   if(Ind[Number].m_Handle[2]==INVALID_HANDLE) {Print(" Failed to get handle of the iMA indicator"); Init=false; return(false);}
   if(Ind[Number].m_Handle[3]==INVALID_HANDLE) {Print(" Failed to get handle of the iMA indicator"); Init=false; return(false);}
//---
   uint BIndex=Number*4+0;
   uint PIndex=Number*2+0;
//---
   InitTsIndBuffer(BIndex,PIndex,Ind[Number].m_LineBuffer,EMPTY_VALUE,min_rates_total);
   InitTsIndColorBuffer(BIndex+1,PIndex,Ind[Number].m_ColorLineBuffer,min_rates_total);
//---
   InitTsIndArrBuffer(BIndex+2,PIndex+1,Ind[Number].m_ArrayBuffer,EMPTY_VALUE,min_rates_total);
   InitTsIndColorBuffer(BIndex+3,PIndex+1,Ind[Number].m_ColorArrayBuffer,min_rates_total);
//--- end of one indicator initialization
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization of indicator buffer of timeseries                 |
//+------------------------------------------------------------------+  
void InitTsIndBuffer(uint Number,uint Plot,double &IndBuffer[],double Empty_Value,uint Draw_Begin)
  {
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(Number,IndBuffer,INDICATOR_DATA);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(Plot,PLOT_DRAW_BEGIN,Draw_Begin);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(Plot,PLOT_EMPTY_VALUE,Empty_Value);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//---
  }
//+------------------------------------------------------------------+
//| Initialization of indicator buffer of timeseries                 |
//+------------------------------------------------------------------+  
void InitTsIndArrBuffer(uint Number,uint Plot,double &IndBuffer[],double Empty_Value,uint Draw_Begin)
  {
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(Number,IndBuffer,INDICATOR_DATA);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(Plot,PLOT_DRAW_BEGIN,Draw_Begin);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(Plot,PLOT_EMPTY_VALUE,Empty_Value);
//--- selecting a symbol for drawing
   PlotIndexSetInteger(Plot,PLOT_ARROW,115);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//---
  }
//+------------------------------------------------------------------+
//| Initialization of indicator buffer of timeseries color           |
//+------------------------------------------------------------------+  
void InitTsIndColorBuffer(uint Number,uint Plot,double &IndColorBuffer[],uint Draw_Begin)
  {
//--- set dynamic array as a color index buffer   
   SetIndexBuffer(Number,IndColorBuffer,INDICATOR_COLOR_INDEX);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(Plot,PLOT_DRAW_BEGIN,Draw_Begin);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndColorBuffer,true);
//---
  }
//+------------------------------------------------------------------+ 
//| MaRsi iteration function                                         | 
//+------------------------------------------------------------------+ 
bool IndOnCalculate(uint Number,uint Limit,const datetime &Time[],uint Rates_Total,uint Prev_Calculated)
  {
//--- declaration of integer variables
   uint limit_;
//--- declaration of variables with a floating point  
   double MA0[1],MA1[1],RSI0[1],RSI1[1];
   datetime Time_[1],Time0;
   static uint LastCountBar[INDTOTAL];
//--- calculations of the necessary amount of data to be copied and
//--- the limit starting number for loop of bars recalculation
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// checking for the first start of calculation of an indicator
     {
      LastCountBar[Number]=Rates_Total;
      limit_=Limit;
     }
   else limit_=int(LastCountBar[Number])+Limit; // starting index for calculation of new bars 
//--- main cycle of calculation of the indicator
   for(int bar=int(limit_); bar>=0 && !IsStopped(); bar--)
     {
      //--- zero out the contents of the indicator buffers for calculation
      Ind[Number].m_ArrayBuffer[bar]=EMPTY_VALUE;
      Ind[Number].m_LineBuffer[bar]=Number+1;
      Ind[Number].m_ColorArrayBuffer[bar]=EMPTY_VALUE;
      Ind[Number].m_ColorLineBuffer[bar]=0;
      Time0=Time[bar];
      //--- copy newly appeared data in the array
      if(CopyTime(Symbol(),Ind[Number].m_TimeFrame,Time0,1,Time_)<=0) return(RESET);
      if(Time0>=Time_[0] && Time[bar+1]<Time_[0])
        {
         LastCountBar[Number]=bar;
         //--- copy newly appeared data into the arrays
         if(CopyBuffer(Ind[Number].m_Handle[0],0,Time0,1,MA0)<=0) return(RESET);
         if(CopyBuffer(Ind[Number].m_Handle[1],0,Time0,1,MA1)<=0) return(RESET);
         if(CopyBuffer(Ind[Number].m_Handle[2],0,Time0,1,RSI0)<=0) return(RESET);
         if(CopyBuffer(Ind[Number].m_Handle[3],0,Time0,1,RSI1)<=0) return(RESET);
         //---
         int res=0;
         if(MA0[0] > MA1[0]) res = +1;
         if(MA0[0] < MA1[0]) res = -1;
         //---
         if(RSI0[0] > RSI1[0]) res += 1;
         if(RSI0[0] < RSI1[0]) res -= 1;
         //---
         res=MathMax(MathMin(1,res),-1)+1;
         int numb=int(Number+1);
         Ind[Number].m_ArrayBuffer[bar]=numb;
         Ind[Number].m_LineBuffer[bar]=numb;
         Ind[Number].m_ColorArrayBuffer[bar]=res;
         Ind[Number].m_ColorLineBuffer[bar]=res;
        }

      if(Ind[Number].m_ArrayBuffer[bar]==EMPTY_VALUE) Ind[Number].m_ColorLineBuffer[bar]=Ind[Number].m_ColorLineBuffer[bar+1];
     }
//--- end of one indicator calculation    
   return(true);
  }
//+------------------------------------------------------------------+   
//| MaRsi indicator initialization function                          | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=3;
   Init=true;
//--- initialization of variables 
   Ind[0].m_TimeFrame=TimeFrame0;
   Ind[1].m_TimeFrame=TimeFrame1;
   Ind[2].m_TimeFrame=TimeFrame2;
   Ind[3].m_TimeFrame=TimeFrame3;
   Ind[4].m_TimeFrame=TimeFrame4;
//--- initialize buffers of indicators
   for(int count=0; count<INDTOTAL; count++)
      if(!IndInit(count))
        {
         Init=false;
         return(INIT_FAILED);
        }
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"MultiMaRsiSignal");
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- end of initialization
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| MaRsi iteration function                                         | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total || !Init) return(RESET);
   for(int count=0; count<INDTOTAL; count++)
      for(int iii=0; iii<4; iii++)
         if(BarsCalculated(Ind[count].m_Handle[iii])<Bars(Symbol(),Ind[count].m_TimeFrame))
            return(prev_calculated);
//--- declaration of integer variables
   int limit;
//--- calculate the "limit" starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars 
//--- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);
//---
   for(int count=0; count<INDTOTAL; count++) if(!IndOnCalculate(count,limit,time,rates_total,prev_calculated)) return(RESET);
//---   
   return(rates_total);
  }
//+------------------------------------------------------------------+
