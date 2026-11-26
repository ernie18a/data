//+------------------------------------------------------------------+
//|                                               MultiRVISignal.mq5 | 
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
//+-----------------------------------+
//| declaration of constants          |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
#define INDTOTAL 4// The constant for the number of displayed indicators
//+-----------------------------------+
//--- number of indicator buffers
#property indicator_buffers 16 // INDTOTAL*4
//--- total plots used
#property indicator_plots   12 // INDTOTAL*3
//+-----------------------------------+
//| Indicator 1 drawing parameters    |
//+-----------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_COLOR_LINE
//--- the following colors are used as the indicator line color
#property indicator_color1 Gray,Red,SeaGreen
//--- the indicator line is dashed
#property indicator_style1  STYLE_SOLID
//--- the indicator line width is 3
#property indicator_width1  3
//--- displaying the indicator label
#property indicator_label1  "Signal line 1"
//+-----------------------------------+
//| Indicator 1 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 1 as a label
#property indicator_type2   DRAW_ARROW
//--- the color used as a label color
#property indicator_color2 LimeGreen
//--- the indicator line width is 5
#property indicator_width2  5
//--- displaying the indicator label
#property indicator_label2  "Up RVI 1"
//+-----------------------------------+
//| Indicator 1 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 1 as a label
#property indicator_type3   DRAW_ARROW
//--- the color used as a label color
#property indicator_color3 Magenta
//--- the indicator line width is 5
#property indicator_width3  5
//--- displaying the indicator label
#property indicator_label3  "Down RVI 1"
//+-----------------------------------+
//| Indicator 2 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 2 as a line
#property indicator_type4   DRAW_COLOR_LINE
//--- the following colors are used as the indicator line color
#property indicator_color4 Gray,Red,SeaGreen
//--- the indicator line is dashed
#property indicator_style4  STYLE_SOLID
//--- the indicator line width is 3
#property indicator_width4  3
//--- displaying the indicator label
#property indicator_label4  "Signal line 2"
//+-----------------------------------+
//| Indicator 2 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 2 as a label
#property indicator_type5   DRAW_ARROW
//--- the color used as a label color
#property indicator_color5 LimeGreen
//--- the indicator line width is 5
#property indicator_width5  5
//--- displaying the indicator label
#property indicator_label5  "Up RVI 2"
//+-----------------------------------+
//| Indicator 2 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 2 as a label
#property indicator_type6   DRAW_ARROW
//--- the color used as a label color
#property indicator_color6 Magenta
//--- the indicator line width is 5
#property indicator_width6  5
//--- displaying the indicator label
#property indicator_label6  "Down RVI 2"
//+-----------------------------------+
//| Indicator 3 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 3 as a line
#property indicator_type7   DRAW_COLOR_LINE
//--- the following colors are used as the indicator line color
#property indicator_color7 Gray,Red,SeaGreen
//--- the indicator line is dashed
#property indicator_style7  STYLE_SOLID
//--- the indicator line width is 3
#property indicator_width7  3
//--- displaying the indicator label
#property indicator_label7  "Signal line 3"
//+-----------------------------------+
//| Indicator 3 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 3 as a label
#property indicator_type8   DRAW_ARROW
//--- the color used as a label color
#property indicator_color8 LimeGreen
//--- the indicator line width is 5
#property indicator_width8  5
//--- displaying the indicator label
#property indicator_label8  "Up RVI 3"
//+-----------------------------------+
//| Indicator 3 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 3 as a label
#property indicator_type9   DRAW_ARROW
//--- the color used as a label color
#property indicator_color9 Magenta
//--- the indicator line width is 5
#property indicator_width9  5
//--- displaying the indicator label
#property indicator_label9  "Down RVI 3"
//+-----------------------------------+
//| Indicator 4 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 4 as a line
#property indicator_type10   DRAW_COLOR_LINE
//--- the following colors are used as the indicator line color
#property indicator_color10 Gray,Red,SeaGreen
//--- the indicator line is dashed
#property indicator_style10 STYLE_SOLID
//--- the indicator line width is 3
#property indicator_width10  3
//--- displaying the indicator label
#property indicator_label10  "Signal line 4"
//+-----------------------------------+
//| Indicator 4 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 4 as a label
#property indicator_type11   DRAW_ARROW
//--- the color used as a label color
#property indicator_color11 LimeGreen
//--- the indicator line width is 5
#property indicator_width11  5
//--- displaying the indicator label
#property indicator_label11  "Up RVI 4"
//+-----------------------------------+
//| Indicator 4 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 4 as a label
#property indicator_type12   DRAW_ARROW
//--- the color used as a label color
#property indicator_color12 Magenta
//--- the indicator line width is 5
#property indicator_width12  5
//--- displaying the indicator label
#property indicator_label12  "Down RVI 4"
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame0=PERIOD_H12; //1 Chart period
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_H6;  //2 Chart period
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H3;  //3 Chart period
input ENUM_TIMEFRAMES TimeFrame3=PERIOD_H1;  //4 Chart period
//---
input uint RVIPeriod=12;                   //RVI period
//+-----------------------------------+
//--- declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Getting time frame as string                                     |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
//+------------------------------------------------------------------+
//|  Indicator buffer class                                          |
//+------------------------------------------------------------------+  
class CIndBuffers
  {
   //---
public:
   double            m_UpBuffer[];
   double            m_DnBuffer[];
   double            m_LineBuffer[];
   double            m_ColorLineBuffer[];
   int               m_Handle;
   ENUM_TIMEFRAMES   m_TimeFrame;
   //--- 
  };
//--- declaration of dynamic arrays that further will be used as indicator buffers
CIndBuffers Ind[INDTOTAL];
//+------------------------------------------------------------------+   
//| RVI indicator initialization function                            | 
//+------------------------------------------------------------------+ 
bool IndInit(uint Number,uint RVI_Period)
  {
//--- checking the chart periods for correctness
   if(Ind[Number].m_TimeFrame<Period() && Ind[Number].m_TimeFrame!=PERIOD_CURRENT)
     {
      Print("IndInit(",Number,"): The RVI indicator chart period cannot be less than the current chart period");
      Init=false;
      return(false);
     }
//--- getting indicator handles  
   Ind[Number].m_Handle=iRVI(NULL,Ind[Number].m_TimeFrame,RVI_Period);
   if(Ind[Number].m_Handle==INVALID_HANDLE)
     {
      Print("IndInit(",Number,"): Failed to get the RVI indicator handle");
      Init=false;
      return(false);
     }
//---   
   uint Numb=Number*4+0;
//--- setting dynamic array as indicator buffer
   SetIndexBuffer(Numb,Ind[Number].m_LineBuffer,INDICATOR_DATA);
//--- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(Numb,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(Numb,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as time series
   ArraySetAsSeries(Ind[Number].m_LineBuffer,true);
   Numb++;
//--- set dynamic array as a color index buffer   
   SetIndexBuffer(Numb,Ind[Number].m_ColorLineBuffer,INDICATOR_COLOR_INDEX);
//--- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(Numb,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing elements in the buffer as time series
   ArraySetAsSeries(Ind[Number].m_ColorLineBuffer,true);
   Numb++;
//--- setting dynamic array as indicator buffer
   if(!SetIndexBuffer(Numb,Ind[Number].m_UpBuffer,INDICATOR_DATA))
      //--- shifting the starting point of the indicator drawing
      PlotIndexSetInteger(Numb,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(Numb,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as time series
   ArraySetAsSeries(Ind[Number].m_UpBuffer,true);
   Numb++;
//--- setting dynamic array as indicator buffer
   SetIndexBuffer(Numb,Ind[Number].m_DnBuffer,INDICATOR_DATA);
//--- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(Numb,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(Numb,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as time series
   ArraySetAsSeries(Ind[Number].m_DnBuffer,true);
//--- end of initialization of one indicator
   return(true);
  }
//+------------------------------------------------------------------+   
//| RVI indicator initialization function                            | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- initialization of variables of data starting point
   min_rates_total=3;
   Init=true;
//--- initialization of variables 
   Ind[0].m_TimeFrame=TimeFrame0;
   Ind[1].m_TimeFrame=TimeFrame1;
   Ind[2].m_TimeFrame=TimeFrame2;
   Ind[3].m_TimeFrame=TimeFrame3;
//--- initialization of indicator buffers
   for(int count=0; count<INDTOTAL; count++)
      if(!IndInit(count,RVIPeriod))
        {
         Init=false;
         return(INIT_FAILED);
        }
//---
   string shortname;
   StringConcatenate(shortname,"MultiRVISignal( ",RVIPeriod," )");
//--- creating a name to be displayed in a separate subwindow and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- end of initialization
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| RVI iteration function                                           | 
//+------------------------------------------------------------------+ 
bool IndOnCalculate(uint Number,uint Limit,const datetime &Time[],uint Rates_Total,uint Prev_Calculated)
  {
//--- declaration of integer variables
   uint limit_;
//--- declaration of variables with a floating point  
   double Main[1],Signal[1];
   datetime Time_[1],Time0;
   static uint LastCountBar[INDTOTAL];
//--- calculations of the necessary amount of data to be copied and
//--- the starting number limit for the bar recalculation loop
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// checking for the first start of the indicator calculation
     {
      LastCountBar[Number]=Rates_Total;
      limit_=Limit;
     }
   else limit_=int(LastCountBar[Number])+Limit; // starting index for the calculation of new bars 
//--- main indicator calculation loop
   for(int bar=int(limit_); bar>=0 && !IsStopped(); bar--)
     {
      //--- zero out the contents of the indicator buffers for the calculation
      Ind[Number].m_UpBuffer[bar]=EMPTY_VALUE;
      Ind[Number].m_DnBuffer[bar]=EMPTY_VALUE;
      Ind[Number].m_LineBuffer[bar]=Number;
      Ind[Number].m_ColorLineBuffer[bar]=0;
      Time0=Time[bar];
      //--- copy the new data into the array
      if(CopyTime(Symbol(),Ind[Number].m_TimeFrame,Time0,1,Time_)<=0) return(RESET);

      if(Time0>=Time_[0] && Time[bar+1]<Time_[0])
        {
         LastCountBar[Number]=bar;
         //--- copy new data into the arrays
         if(CopyBuffer(Ind[Number].m_Handle,MAIN_LINE,Time0,1,Main)<=0) return(RESET);
         if(CopyBuffer(Ind[Number].m_Handle,SIGNAL_LINE,Time0,1,Signal)<=0) return(RESET);

         if(Main[0]>Signal[0])
           {
            Ind[Number].m_UpBuffer[bar]=Number;
            Ind[Number].m_ColorLineBuffer[bar]=2;
           }
         if(Main[0]<Signal[0])
           {
            Ind[Number].m_DnBuffer[bar]=Number;
            Ind[Number].m_ColorLineBuffer[bar]=1;
           }
        }
//---
      if(Ind[Number].m_ColorLineBuffer[bar+1] && !Ind[Number].m_ColorLineBuffer[bar])
         Ind[Number].m_ColorLineBuffer[bar]=Ind[Number].m_ColorLineBuffer[bar+1];
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+ 
//| RVI iteration function                                           | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // history in bars at the current tick
                const int prev_calculated,// history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total || !Init) return(RESET);
   for(int count=0; count<INDTOTAL; count++)
      if(BarsCalculated(Ind[count].m_Handle)<Bars(Symbol(),Ind[count].m_TimeFrame))
        return(prev_calculated);
//--- declaration of integer variables
   int limit;
//--- calculations of the necessary amount of data to be copied and
//--- the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars 
//--- indexing array elements as time series  
   ArraySetAsSeries(time,true);
//---
   for(int count=0; count<INDTOTAL; count++) if(!IndOnCalculate(count,limit,time,rates_total,prev_calculated)) return(RESET);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
