//+------------------------------------------------------------------+
//|                                              MultiXRSXSignal.mq5 | 
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
//--- fixed height of the indicator subwindow in pixels 
#property indicator_height 50
//--- lower and upper scale limit of a separate indicator window
#property indicator_maximum +4.9
#property indicator_minimum +0.4
//+-----------------------------------+
//|  declaration of constants              |
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
#property indicator_color1 Gray,Red,MediumSlateBlue
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
#property indicator_color2 Blue
//--- the indicator line width is 5
#property indicator_width2  5
//--- displaying the indicator label
#property indicator_label2  "Up XRSX 1"
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
#property indicator_label3  "Down XRSX 1"
//+-----------------------------------+
//| Indicator 2 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 2 as a line
#property indicator_type4   DRAW_COLOR_LINE
//--- the following colors are used as the indicator line color
#property indicator_color4 Gray,Red,MediumSlateBlue
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
#property indicator_color5 Blue
//--- the indicator line width is 5
#property indicator_width5  5
//--- displaying the indicator label
#property indicator_label5  "Up XRSX 2"
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
#property indicator_label6  "Down XRSX 2"
//+-----------------------------------+
//| Indicator 3 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 3 as a line
#property indicator_type7   DRAW_COLOR_LINE
//--- the following colors are used as the indicator line color
#property indicator_color7 Gray,Red,MediumSlateBlue
//--- the indicator line is dashed
#property indicator_style7  STYLE_SOLID
//--- the indicator line width is 3
#property indicator_width7  3
//--- displaying the indicator label
#property indicator_label7  "Signal line 3"
//+-----------------------------------+
//|Indicator 3 drawing parameters     |
//+-----------------------------------+
//--- drawing the indicator 3 as a label
#property indicator_type8   DRAW_ARROW
//--- the color used as a label color
#property indicator_color8 Blue
//--- the indicator line width is 5
#property indicator_width8  5
//--- displaying the indicator label
#property indicator_label8  "Up XRSX 3"
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
#property indicator_label9  "Down XRSX 3"
//+-----------------------------------+
//| Indicator 4 drawing parameters    |
//+-----------------------------------+
//--- drawing the indicator 4 as a line
#property indicator_type10   DRAW_COLOR_LINE
//--- the following colors are used as the indicator line color
#property indicator_color10 Gray,Red,MediumSlateBlue
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
#property indicator_color11 Blue
//--- the indicator line width is 5
#property indicator_width11  5
//--- displaying the indicator label
#property indicator_label11  "Up XRSX 4"
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
#property indicator_label12  "Down XRSX 4"
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame0=PERIOD_H12; //1 Chart period
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_H6;  //2 Chart period
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H3;  //3 Chart period
input ENUM_TIMEFRAMES TimeFrame3=PERIOD_H1;  //4 Chart period
//+-----------------------------------+
//| declaration of enumerations       |
//+-----------------------------------+
enum Smooth_Method
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  };
//+-----------------------------------+
//| declaration of enumerations       |
//+-----------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input Smooth_Method DSmoothMethod=MODE_JJMA;  // Price smoothing method
input uint DPeriod=15;                        // Moving average period
input int DPhase=100;                         // Moving average smoothing parameter
//--- DPhase: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- DPhase: for VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Smooth_Method SSmoothMethod=MODE_JurX;  // Signal line smoothing method
input uint SPeriod=7;                         // Signal line period
input int SPhase=100;                         // Signal line parameter
//--- SPhase: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- SPhase: for VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ IPC=PRICE_CLOSE;         // Price constant
//+-----------------------------------+
//--- declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//|  Getting time frame as string                                    |
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
//| XRSX indicator initialization function                           | 
//+------------------------------------------------------------------+ 
bool IndInit(uint Number,
             Smooth_Method D_Method,
             uint D_Period,
             int D_Phase,
             Smooth_Method S_Method,
             uint S_Period,
             int S_Phase,
             Applied_price_ IPC_)
  {
//--- checking the chart periods for correctness
   if(Ind[Number].m_TimeFrame<Period() && Ind[Number].m_TimeFrame!=PERIOD_CURRENT)
     {
      Print("IndInit(",Number,"): The XRSX indicator chart period cannot be less than the current chart period");
      Init=false;
      return(false);
     }
//--- getting indicator handles  
   Ind[Number].m_Handle=iCustom(NULL,Ind[Number].m_TimeFrame,"XRSX",D_Method,D_Period,D_Phase,S_Method,S_Period,S_Phase,IPC_,0,0);
   if(Ind[Number].m_Handle==INVALID_HANDLE)
     {
      Print("IndInit(",Number,"): Failed to get the XRSX indicator handle");
      Init=false;
      return(false);
     }
//---
   uint Numb=Number*4+0;
   InitTsIndBuffer(Numb,Ind[Number].m_LineBuffer,EMPTY_VALUE,min_rates_total);
   InitTsIndColorBuffer(Numb+1,Ind[Number].m_ColorLineBuffer,min_rates_total);
   InitTsIndBuffer(Numb+2,Ind[Number].m_UpBuffer,EMPTY_VALUE,min_rates_total);
   InitTsIndBuffer(Numb+3,Ind[Number].m_DnBuffer,EMPTY_VALUE,min_rates_total);
//--- end of initialization of one indicator
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization of time series indicator buffer                   |
//+------------------------------------------------------------------+  
void InitTsIndBuffer(uint Number,double &IndBuffer[],double Empty_Value,uint Draw_Begin)
  {
//--- setting dynamic array as indicator buffer
   SetIndexBuffer(Number,IndBuffer,INDICATOR_DATA);
//--- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer,true);
//---
  }
//+------------------------------------------------------------------+
//| Initialization of time series color indicator buffer             |
//+------------------------------------------------------------------+  
void InitTsIndColorBuffer(uint Number,double &IndColorBuffer[],uint Draw_Begin)
  {
//--- set dynamic array as a color index buffer   
   SetIndexBuffer(Number,IndColorBuffer,INDICATOR_COLOR_INDEX);
//--- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- indexing elements in the buffer as time series
   ArraySetAsSeries(IndColorBuffer,true);
//---
  }
//+------------------------------------------------------------------+ 
//| XRSX iteration function                                          | 
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
      Ind[Number].m_LineBuffer[bar]=Number+1;
      Ind[Number].m_ColorLineBuffer[bar]=0;
      Time0=Time[bar];

      //--- copy the new data into the array
      if(CopyTime(Symbol(),Ind[Number].m_TimeFrame,Time0,1,Time_)<=0) return(RESET);

      if(Time0>=Time_[0] && Time[bar+1]<Time_[0])
        {
         LastCountBar[Number]=bar;

         //--- copy new data into the arrays
         if(CopyBuffer(Ind[Number].m_Handle,0,Time0,1,Main)<=0) return(RESET);
         if(CopyBuffer(Ind[Number].m_Handle,2,Time0,1,Signal)<=0) return(RESET);

         if(Main[0]>Signal[0])
           {
            Ind[Number].m_UpBuffer[bar]=Number+1;
            Ind[Number].m_ColorLineBuffer[bar]=2;
           }
         if(Main[0]<Signal[0])
           {
            Ind[Number].m_DnBuffer[bar]=Number+1;
            Ind[Number].m_ColorLineBuffer[bar]=1;
           }
        }

      if(Ind[Number].m_ColorLineBuffer[bar+1] && !Ind[Number].m_ColorLineBuffer[bar])
         Ind[Number].m_ColorLineBuffer[bar]=Ind[Number].m_ColorLineBuffer[bar+1];
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+   
//| XRSX indicator initialization function                           | 
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
      if(!IndInit(count,DSmoothMethod,DPeriod,DPhase,SSmoothMethod,SPeriod,SPhase,IPC))
        {
         Init=false;
         return(INIT_FAILED);
        }
//---
   string shortname;
   StringConcatenate(shortname,"MultiXRSXSignal( ",DPeriod," )");
//--- creating a name to be displayed in a separate subwindow and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- end of initialization
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| XRSX iteration function                                          | 
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
      if(BarsCalculated(Ind[count].m_Handle)<Bars(Symbol(),Ind[count].m_TimeFrame)) return(prev_calculated);
//--- declaration of integer variables
   int limit;
//--- calculations of the necessary amount of data to be copied and
//--- and the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars 

//--- indexing array elements as time series  
   ArraySetAsSeries(time,true);

   for(int count=0; count<INDTOTAL; count++) if(!IndOnCalculate(count,limit,time,rates_total,prev_calculated)) return(RESET);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
