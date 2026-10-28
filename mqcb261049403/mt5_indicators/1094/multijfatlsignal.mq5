/*
 * For the indicator to work, place the
 * SmoothAlgorithms.mqh
 * in the directory: MetaTrader\\MQL5\Include
 * 
 * JFatl.mq5
 * in the directory: MetaTrader\\MQL5\Indicators
 */
//+------------------------------------------------------------------+
//|                                             MultiJFatlSignal.mq5 | 
//|                             Copyright © 2012,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description ""
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- indicator subwindow fixed height in pixels 
#property indicator_height 50
//---- The lower and upper limits of the scale separate of indicator window
#property indicator_maximum +4.9
#property indicator_minimum +0.4
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
#define INDTOTAL 4// The constant for the number of displayed indicators
//+-----------------------------------+
//---- number of indicator buffers
#property indicator_buffers 16 // INDTOTAL*4
//---- total number of used graphical plots
#property indicator_plots   12 // INDTOTAL*3

//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_COLOR_LINE
//---- the following colors are used for the indicator line
#property indicator_color1 clrGray,clrMagenta,clrDodgerBlue
//---- the indicator line is a stroke
#property indicator_style1  STYLE_SOLID
//---- the width of indicator line is 3
#property indicator_width1  3
//---- displaying the indicator label
#property indicator_label1  "Signal line 1"
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator 1 as a label
#property indicator_type2   DRAW_ARROW
//---- color which used for the label
#property indicator_color2 clrTeal
//---- indicator line width is equal to 5
#property indicator_width2  5
//---- displaying the indicator label
#property indicator_label2  "Up JFatl 1"
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator 1 as a label
#property indicator_type3   DRAW_ARROW
//---- color which used for the label
#property indicator_color3 clrRed
//---- indicator line width is equal to 5
#property indicator_width3  5
//---- displaying the indicator label
#property indicator_label3  "Down JFatl 1"

//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- dawing the indicator 2 as a line
#property indicator_type4   DRAW_COLOR_LINE
//---- the following colors are used for the indicator line
#property indicator_color4 clrGray,clrMagenta,clrDodgerBlue
//---- the indicator line is a stroke
#property indicator_style4  STYLE_SOLID
//---- the width of indicator line is 3
#property indicator_width4  3
//---- displaying the indicator label
#property indicator_label4  "Signal line 2"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator 2 as a label
#property indicator_type5   DRAW_ARROW
//---- color which used for the label
#property indicator_color5 clrTeal
//---- indicator line width is equal to 5
#property indicator_width5  5
//---- displaying the indicator label
#property indicator_label5  "Up JFatl 2"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator 2 as a label
#property indicator_type6   DRAW_ARROW
//---- color which used for the label
#property indicator_color6 clrRed
//---- indicator line width is equal to 5
#property indicator_width6  5
//---- displaying the indicator label
#property indicator_label6  "Down JFatl 2"

//+-----------------------------------+
//|  Indicator 3 drawing parameters   |
//+-----------------------------------+
//---- drawing indicator 3 as line
#property indicator_type7   DRAW_COLOR_LINE
//---- the following colors are used for the indicator line
#property indicator_color7 clrGray,clrMagenta,clrDodgerBlue
//---- the indicator line is a stroke
#property indicator_style7  STYLE_SOLID
//---- the width of indicator line is 3
#property indicator_width7  3
//---- displaying the indicator label
#property indicator_label7  "Signal line 3"
//+-----------------------------------+
//|  Indicator 3 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator 3 as a label
#property indicator_type8   DRAW_ARROW
//---- color which used for the label
#property indicator_color8 clrTeal
//---- indicator line width is equal to 5
#property indicator_width8  5
//---- displaying the indicator label
#property indicator_label8  "Up JFatl 3"
//+-----------------------------------+
//|  Indicator 3 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator 3 as a label
#property indicator_type9   DRAW_ARROW
//---- color which used for the label
#property indicator_color9 clrRed
//---- indicator line width is equal to 5
#property indicator_width9  5
//---- displaying the indicator label
#property indicator_label9  "Down JFatl 3"

//+-----------------------------------+
//|  Indicator 4 drawing parameters   |
//+-----------------------------------+
//---- drawing indicator 4 as line
#property indicator_type10   DRAW_COLOR_LINE
//---- the following colors are used for the indicator line
#property indicator_color10 clrGray,clrMagenta,clrDodgerBlue
//---- the indicator line is a stroke
#property indicator_style10 STYLE_SOLID
//---- the width of indicator line is 3
#property indicator_width10  3
//---- displaying the indicator label
#property indicator_label10  "Signal line 4"
//+-----------------------------------+
//|  Indicator 4 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator 4 as a label
#property indicator_type11   DRAW_ARROW
//---- color which used for the label
#property indicator_color11 clrTeal
//---- indicator line width is equal to 5
#property indicator_width11  5
//---- displaying the indicator label
#property indicator_label11  "Up JFatl 4"
//+-----------------------------------+
//|  Indicator 4 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator 4 as a label
#property indicator_type12   DRAW_ARROW
//---- color which used for the label
#property indicator_color12 clrRed
//---- indicator line width is equal to 5
#property indicator_width12  5
//---- displaying the indicator label
#property indicator_label12  "Down JFatl 4"
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type od constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame0=PERIOD_H12; //1 Chart period
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_H6;  //2 Chart period
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H3;  //3 Chart period
input ENUM_TIMEFRAMES TimeFrame3=PERIOD_H1;  //4 Chart period
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input int JLength=5; // depth of the JMA smoothing                   
input int JPhase=-100; // parameter of the JMA smoothing,
                       //that changes within the range -100 ... +100,
//impacts the transitional process quality;
input Applied_price_ JIPC=PRICE_CLOSE_;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
//+-----------------------------------+

//---- Declaration of a variable for storing the indicator initialization result
bool Init;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//|  Getting string timeframe                                        |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+
//|  Class of indicator buffers                                      |
//+------------------------------------------------------------------+  
class CIndBuffers
  {
   //----
public:
   double            m_UpBuffer[];
   double            m_DnBuffer[];
   double            m_LineBuffer[];
   double            m_ColorLineBuffer[];
   int               m_Handle;
   ENUM_TIMEFRAMES   m_TimeFrame;
   //---- 
  };

//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
CIndBuffers Ind[INDTOTAL];
//+------------------------------------------------------------------+   
//| JFatl indicator initialization function                          | 
//+------------------------------------------------------------------+ 
bool IndInit(
             uint Number,
             uint Length,
             int Phase,
             Applied_price_ IPC
             )
  {
//---- checking correctness of the chart periods
   if(Ind[Number].m_TimeFrame<Period() && Ind[Number].m_TimeFrame!=PERIOD_CURRENT)
     {
      Print("IndInit(",Number,"): JFatl indicator chart period cannot be less than the current chart period");
      Init=false;
      return(false);
     }

//---- obtaining the indicators handles  
   Ind[Number].m_Handle=iCustom(NULL,Ind[Number].m_TimeFrame,"JFatl",Length,Phase,IPC,0,0);

   if(Ind[Number].m_Handle==INVALID_HANDLE)
     {
      Print("IndInit(",Number,"): Failed to get handle of the JFatl indicator");
      Init=false;
      return(false);
     }

   uint BIndex=Number*4+0;
   uint PIndex=Number*3+0;
   InitTsIndBuffer(BIndex,PIndex,Ind[Number].m_LineBuffer,EMPTY_VALUE,min_rates_total);
   InitTsIndColorBuffer(BIndex+1,PIndex,Ind[Number].m_ColorLineBuffer,min_rates_total);
   InitTsIndArrBuffer(BIndex+2,PIndex+1,Ind[Number].m_UpBuffer,EMPTY_VALUE,min_rates_total);
   InitTsIndArrBuffer(BIndex+3,PIndex+2,Ind[Number].m_DnBuffer,EMPTY_VALUE,min_rates_total);

//---- End of one indicator initialization
   return(true);
  }
//+------------------------------------------------------------------+
//|  Initialization of indicator buffer of timeseries                |
//+------------------------------------------------------------------+  
void InitTsIndBuffer(uint Number,uint Plot,double &IndBuffer[],double Empty_Value,uint Draw_Begin)
  {
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(Number,IndBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(Plot,PLOT_DRAW_BEGIN,Draw_Begin);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(Plot,PLOT_EMPTY_VALUE,Empty_Value);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//----
  }
//+------------------------------------------------------------------+
//|  Initialization of indicator buffer of timeseries                |
//+------------------------------------------------------------------+  
void InitTsIndArrBuffer(uint Number,uint Plot,double &IndBuffer[],double Empty_Value,uint Draw_Begin)
  {
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(Number,IndBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(Plot,PLOT_DRAW_BEGIN,Draw_Begin);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(Plot,PLOT_EMPTY_VALUE,Empty_Value);
//---- selecting a symbol for drawing
   PlotIndexSetInteger(Plot,PLOT_ARROW,167);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//----
  }
//+------------------------------------------------------------------+
//|  Initialization of indicator buffer of timeseries color          |
//+------------------------------------------------------------------+  
void InitTsIndColorBuffer(uint Number,uint Plot,double &IndColorBuffer[],uint Draw_Begin)
  {
//---- set dynamic array as a color index buffer   
   SetIndexBuffer(Number,IndColorBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(Plot,PLOT_DRAW_BEGIN,Draw_Begin);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndColorBuffer,true);
//----
  }
//+------------------------------------------------------------------+ 
//| JFatl iteration function                                         | 
//+------------------------------------------------------------------+ 
bool IndOnCalculate(uint Number,uint Limit,const datetime &Time[],uint Rates_Total,uint Prev_Calculated)
  {
//---- Declaration of integer variables
   uint limit_;
//---- declaration of variables with a floating point  
   double JFatl[2];
   datetime Time_[1],Time0;
   static uint LastCountBar[INDTOTAL];

//--- calculations of the necessary amount of data to be copied and
//----the limit starting number for loop of bars recalculation
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// checking for the first start of calculation of an indicator
     {
      LastCountBar[Number]=Rates_Total;
      limit_=Limit;
     }
   else limit_=int(LastCountBar[Number])+Limit; // starting index for calculation of new bars 

//---- Main cycle of calculation of the indicator
   for(int bar=int(limit_); bar>=0 && !IsStopped(); bar--)
     {
      //---- zero out the contents of the indicator buffers for calculation
      Ind[Number].m_UpBuffer[bar]=EMPTY_VALUE;
      Ind[Number].m_DnBuffer[bar]=EMPTY_VALUE;
      Ind[Number].m_LineBuffer[bar]=Number+1;
      Ind[Number].m_ColorLineBuffer[bar]=0;
      Time0=Time[bar];

      //--- copy newly appeared data in the array
      if(CopyTime(Symbol(),Ind[Number].m_TimeFrame,Time0,1,Time_)<=0) return(RESET);

      if(Time0>=Time_[0] && Time[bar+1]<Time_[0])
        {
         LastCountBar[Number]=bar;

         //---- copy newly appeared data into the arrays
         if(CopyBuffer(Ind[Number].m_Handle,0,Time0,2,JFatl)<=0) return(RESET);

         if(JFatl[1]>JFatl[0])
           {
            Ind[Number].m_UpBuffer[bar]=Number+1;
            Ind[Number].m_ColorLineBuffer[bar]=2;
           }
         if(JFatl[1]<JFatl[0])
           {
            Ind[Number].m_DnBuffer[bar]=Number+1;
            Ind[Number].m_ColorLineBuffer[bar]=1;
           }
        }

      if(Ind[Number].m_ColorLineBuffer[bar+1] && !Ind[Number].m_ColorLineBuffer[bar])
         Ind[Number].m_ColorLineBuffer[bar]=Ind[Number].m_ColorLineBuffer[bar+1];
     }
//---- end of one indicator calculation    
   return(true);
  }
//+------------------------------------------------------------------+   
//| JFatl indicator initialization function                          | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=3;
   Init=true;

//---- Initialization of variables 
   Ind[0].m_TimeFrame=TimeFrame0;
   Ind[1].m_TimeFrame=TimeFrame1;
   Ind[2].m_TimeFrame=TimeFrame2;
   Ind[3].m_TimeFrame=TimeFrame3;

//---- initialize buffers of indicators
   for(int count=0; count<INDTOTAL; count++)
      if(!IndInit(count,JLength,JPhase,JIPC))
        {
         Init=false;
         return;
        }

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"MultiJFatlSignal");

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| JFatl iteration function                                         | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total || !Init) return(RESET);
//---- Declaration of integer variables
   int limit;
//--- calculations of the necessary amount of data to be copied and
//----the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars

     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars 

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);

   for(int count=0; count<INDTOTAL; count++)
      if(!IndOnCalculate(count,limit,time,rates_total,prev_calculated)) return(RESET);
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
