//+------------------------------------------------------------------+
//|                                                     ATRPivot.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
/*|Place he file *SmoothAlgorithms.mqh                               |
/*|in the directory: terminal_data_folder\MQL5\Include,              |
/*|and also place *XMA.mq5 file in the directory:                    | 
/*|terminal_data_folder\MQL5\Indicators                              |
//+------------------------------------------------------------------+
*/
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "ATRPivot"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
#property indicator_buffers 1
#property indicator_plots 1
//+-----------------------------------+
//|  Smoothings classes description   |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_      // Type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   // TrendFollow_2 Price 
  };
//+------------------------------------------------------------------+
//|  Smoothing type                                                  |
//+------------------------------------------------------------------+
/*enum Smooth_Method - enumeration is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+-----------------------------------+
//|  Declaration of enumeration       |
//+-----------------------------------+  
enum Width
  {
   Width_1=1, // 1
   Width_2,   // 2
   Width_3,   // 3
   Width_4,   // 4
   Width_5    // 5
  };
//+-----------------------------------+
//|  Declaration of enumeration       |
//+-----------------------------------+
enum STYLE
  {
   SOLID_,      // Solid line
   DASH_,       // Dashed line
   DOT_,        // Dotted line
   DASHDOT_,    // Dot-dash line
   DASHDOTDOT_  // Dot-dash line with double dots
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input ENUM_TIMEFRAMES PivotPeriod=PERIOD_D1; // ATR indicator time frame
input int CountBar=1;                        // Calculation bar
input int    ATRPeriod=18;                   // ATR period
input double Mult_Factor05= 0.8;             // First levels ratio
input double Mult_Factor10= 1.6;             // First levels ratio
input double Mult_Factor15= 2.4;             // First levels ratio
input double Mult_Factor20= 3.2;             // Second levels ratio
input double Mult_Factor25= 4.0;             // First levels ratio
input double Mult_Factor30= 4.8;             // Third levels ratio
input Smooth_Method MA_SMethod=MODE_SMA;     // Smoothing method
input int MA_Length=10;                      // Smoothing depth                    
input int MA_Phase=100;                      // Smoothing parameter
input Applied_price_ IPC=PRICE_CLOSE;        // Price constant
input color  Color_R30 = DodgerBlue;         // R30 level color
input color  Color_R25 = DodgerBlue;         // R25 level color
input color  Color_R20 = DodgerBlue;         // R20 level color
input color  Color_R15 = DodgerBlue;         // R15 level color
input color  Color_R10 = DodgerBlue;         // R10 level color
input color  Color_R05 = DodgerBlue;         // R05 level color
input color     Color_P= DarkOrchid;         // P level color
input color  Color_S05 = DarkOrange;         // S05 level color
input color  Color_S10 = DarkOrange;         // S10 level color
input color  Color_S15 = DarkOrange;         // S15 level color
input color  Color_S20 = DarkOrange;         // S20 level color
input color  Color_S25 = DarkOrange;         // S25 level color
input color  Color_S30 = DarkOrange;         // S30 level color
//----
input STYLE  Style_R30 = SOLID_;             // R30 level line style
input STYLE  Style_R25 = DASHDOTDOT_;        // R25 level line style
input STYLE  Style_R20 = SOLID_;             // R20 level line style
input STYLE  Style_R15 = DASHDOTDOT_;        // R15 level line style
input STYLE  Style_R10 = SOLID_;             // R10 level line style
input STYLE  Style_R05 = DASHDOTDOT_;        // R05 level line style
input STYLE    Style_P = DASH_;              // P level line style
input STYLE  Style_S05 = DASHDOTDOT_;        // S05 level line style
input STYLE  Style_S10 = SOLID_;             // S10 level line style
input STYLE  Style_S15 = DASHDOTDOT_;        // S15 level line style
input STYLE  Style_S20 = SOLID_;             // S20 level line style
input STYLE  Style_S25 = DASHDOTDOT_;        // S25 level line style
input STYLE  Style_S30 = SOLID_;             // S30 level line style
//----
input Width  Width_R30 = Width_1;            // R30 level line width
input Width  Width_R25 = Width_1;            // R25 level line width
input Width  Width_R20 = Width_2;            // R20 level line width
input Width  Width_R15 = Width_1;            // R15 level line width
input Width  Width_R10 = Width_3;            // R10 level line width
input Width  Width_R05 = Width_1;            // R05 level line width
input Width    Width_P = Width_1;            // P level line width
input Width  Width_S05 = Width_1;            // S05 level line width
input Width  Width_S10 = Width_3;            // S10 level line width
input Width  Width_S15 = Width_1;            // S15 level line width
input Width  Width_S20 = Width_2;            // S20 level line width
input Width  Width_S25 = Width_1;            // S25 level line width
input Width  Width_S30 = Width_1;            // S30 level line width
//+----------------------------------------------+
//---- declaration of variables for storing the indicators handles
int ATR_Handle,XMA_Handle;
//---- declaration of the integer variables for the start of data calculation
int StartBarsXMA,StartBarsATR,StartBars;
//+------------------------------------------------------------------+
//|  Creating horizontal price level                                 |
//+------------------------------------------------------------------+
void CreateHline(long   chart_id, // chart ID
                 string name,     // object name
                 int    nwin,     // window index
                 double price,    // price level
                 color  Color,    // line color
                 int    style,    // line style
                 int    width,    // line width
                 string text)     // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_HLINE,0,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Reinstallation of the horizontal price level                    |
//+------------------------------------------------------------------+
void SetHline(long   chart_id, // chart ID
              string name,     // object name
              int    nwin,     // window index
              double price,    // price level
              color  Color,    // line color
              int    style,    // line style
              int    width,    // line width
              string text)     // text
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateHline(chart_id,name,nwin,price,Color,style,width,text);
   else
     {
      // ObjectSetDouble(chart_id,name,OBJPROP_PRICE,price);
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- getting handle of the ATR indicator
   ATR_Handle=iATR(NULL,PivotPeriod,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)Print(" Failed to get handle of the ATR indicator");
//---- getting handle of the XMA indicator
   XMA_Handle=iCustom(NULL,PivotPeriod,"XMA",MA_SMethod,MA_Length,MA_Phase,IPC,0,0);
   if(XMA_Handle==INVALID_HANDLE)Print(" Failed to get handle of the XMA indicator");
//---- initialization of variables of the start of data calculation
   StartBarsXMA=XMA.GetStartBars(MA_SMethod, MA_Length, MA_Phase)+1;
   StartBarsATR=StartBarsXMA+ATRPeriod;
   StartBars=StartBarsXMA+StartBarsATR;
//---- setting up alerts for unacceptable values of external variables
   XMA.XMALengthCheck("Length", MA_Length);
   XMA.XMAPhaseCheck("Phase", MA_Phase, MA_SMethod);
//----
  }
//+------------------------------------------------------------------+
//| Delete graphical objects from a chart                            |
//+------------------------------------------------------------------+    
void Deinit()
  {
//----
   ObjectDelete(0,"Pivot_Line");
   ObjectDelete(0,"R0.5_Line");
   ObjectDelete(0,"R1.0_Line");
   ObjectDelete(0,"R1.5_Line");
   ObjectDelete(0,"R2.0_Line");
   ObjectDelete(0,"R2.5_Line");
   ObjectDelete(0,"R3.0_Line");
   ObjectDelete(0,"S0.5_Line");
   ObjectDelete(0,"S1.0_Line");
   ObjectDelete(0,"S1.5_Line");
   ObjectDelete(0,"S2.0_Line");
   ObjectDelete(0,"S2.5_Line");
   ObjectDelete(0,"S3.0_Line");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   Deinit();
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- 
   if(_Period>=PivotPeriod) return(0);

//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(ATR_Handle)<CountBar+1
      || BarsCalculated(XMA_Handle)<CountBar+1
      || rates_total<StartBars)
      return(0);

//---- declarations of static variables    
   static double P,S05,R05,S10,R10,S15,R15,S20,R20,S25,R25,S30,R30;

   if(rates_total!=prev_calculated)
     {
      //---- declarations of local variables 
      int to_copy=1;
      double ATR_Buffer[],XMA_Buffer[];

      //---- indexing elements in arrays as timeseries  
      ArraySetAsSeries(ATR_Buffer,true);
      ArraySetAsSeries(XMA_Buffer,true);

      //--- copy newly appeared data in the arrays
      if(CopyBuffer(ATR_Handle,0,CountBar,to_copy,ATR_Buffer)<=0) {Deinit(); return(0);}
      if(CopyBuffer(XMA_Handle,0,CountBar,to_copy,XMA_Buffer)<=0) {Deinit(); return(0);}

      P=XMA_Buffer[0];
      R30=P+ATR_Buffer[0]*Mult_Factor30;
      R25=P+ATR_Buffer[0]*Mult_Factor25;
      R20=P+ATR_Buffer[0]*Mult_Factor20;
      R15=P+ATR_Buffer[0]*Mult_Factor15;
      R10=P+ATR_Buffer[0]*Mult_Factor10;
      S10=P-ATR_Buffer[0]*Mult_Factor10;
      S15=P-ATR_Buffer[0]*Mult_Factor15;
      S20=P-ATR_Buffer[0]*Mult_Factor20;
      S25=P-ATR_Buffer[0]*Mult_Factor25;
      S30=P-ATR_Buffer[0]*Mult_Factor30;
     }

   SetHline(0,"R3.0_Line",0,R30,Color_R30,Style_R30,Width_R30,"ATR Pivot "+DoubleToString(R30,_Digits));
   SetHline(0,"R2.5_Line",0,R25,Color_R25,Style_R25,Width_R25,"ATR Pivot "+DoubleToString(R25,_Digits));
   SetHline(0,"R2.0_Line",0,R20,Color_R20,Style_R20,Width_R20,"ATR Pivot "+DoubleToString(R20,_Digits));
   SetHline(0,"R1.5_Line",0,R15,Color_R15,Style_R15,Width_R15,"ATR Pivot "+DoubleToString(R15,_Digits));
   SetHline(0,"R1.0_Line",0,R10,Color_R10,Style_R10,Width_R10,"ATR Pivot "+DoubleToString(R10,_Digits));
   SetHline(0,"R0.5_Line",0,R05,Color_R05,Style_R05,Width_R05,"ATR Pivot "+DoubleToString(R05,_Digits));
   SetHline(0,"Pivot_Line",0,P,Color_P,Style_P,Width_P,"ATR Pivot "+DoubleToString(P,_Digits));
   SetHline(0,"S0.5_Line",0,S05,Color_S05,Style_S05,Width_S05,"ATR Pivot "+DoubleToString(S05,_Digits));
   SetHline(0,"S1.0_Line",0,S10,Color_S10,Style_S10,Width_S10,"ATR Pivot "+DoubleToString(S10,_Digits));
   SetHline(0,"S1.5_Line",0,S15,Color_S15,Style_S15,Width_S15,"ATR Pivot "+DoubleToString(S15,_Digits));
   SetHline(0,"S2.0_Line",0,S20,Color_S20,Style_S20,Width_S20,"ATR Pivot "+DoubleToString(S20,_Digits));
   SetHline(0,"S2.5_Line",0,S25,Color_S25,Style_S25,Width_S25,"ATR Pivot "+DoubleToString(S25,_Digits));
   SetHline(0,"S3.0_Line",0,S30,Color_S30,Style_S30,Width_S30,"ATR Pivot "+DoubleToString(S30,_Digits));
//----
   ChartRedraw(0);
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
