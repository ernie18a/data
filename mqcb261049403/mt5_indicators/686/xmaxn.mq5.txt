//+------------------------------------------------------------------+
//|                                                       XMA-XN.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                              |
//| to the terminal_data_folder\MQL5\Include                         |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define LINES_TOTAL  100 // the constant for the number of the indicator lines
#define RESET          0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
#property description "XMA-X",LINES_TOTAL
//---- number of indicator buffers
#property indicator_buffers LINES_TOTAL 
//---- total number of graphical plots
#property indicator_plots   LINES_TOTAL
//+-----------------------------------+
//|  Indicators drawing parameters    |
//+-----------------------------------+
//---- drawing the oscillators as lines
#property indicator_type1   DRAW_LINE
//---- lines are dott-dash curves
#property indicator_style1 STYLE_SOLID
//---- lines 1 width
#property indicator_width1  1
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA[LINES_TOTAL];
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
//|  Indicator input parameters       |
//+-----------------------------------+
input int Step=10;                        // Interval step
input Smooth_Method xMA_Method=MODE_JJMA; // Averaging method
input int xLength=3;                      // Smoothing depth
input int xPhase=100;                     // Smoothing parameter
input Applied_price_ IPC=PRICE_CLOSE;     // Price constant
input int Shift=0;                        // Horizontal shift of the indicator in bars
input int PriceShift=0;                   // Vertical shift of the indicator in points
input int ColorWidth =40;                 // Color palette width (changes from 0 to 131)
//+-----------------------------------+
int period[LINES_TOTAL];
//---- declaration of the moving averages vertical shift value variable
double dPriceShift;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//|  Variables arrays for the indicator buffers creation             |
//+------------------------------------------------------------------+  
class CIndicatorsBuffers
  {
public: double    IndBuffer[];
  };
//+------------------------------------------------------------------+
//| Indicator buffers creation                                       |
//+------------------------------------------------------------------+
CIndicatorsBuffers Ind[LINES_TOTAL];
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=XMA[0].GetStartBars(xMA_Method,xLength+Step*LINES_TOTAL,xPhase);

   color ArrayColors[]=
     {
      //---- 
      Black,DarkGreen,DarkSlateGray,Olive,Green,Teal,Navy,Purple,Maroon,Indigo,MidnightBlue,DarkBlue,
      DarkOliveGreen,SaddleBrown,ForestGreen,OliveDrab,SeaGreen,DarkGoldenrod,DarkSlateBlue,Sienna,MediumBlue,
      Brown,DarkTurquoise,DimGray,LightSeaGreen,DarkViolet,FireBrick,MediumVioletRed,MediumSeaGreen,Chocolate,
      Crimson,SteelBlue,Goldenrod,MediumSpringGreen,LawnGreen,CadetBlue,DarkOrchid,YellowGreen,LimeGreen,OrangeRed,
      DarkOrange,Orange,Gold,Yellow,Chartreuse,Lime,SpringGreen,Aqua,DeepSkyBlue,Blue,Magenta,Red,Gray,
      SlateGray,Peru,BlueViolet,LightSlateGray,DeepPink,MediumTurquoise,DodgerBlue,Turquoise,RoyalBlue,SlateBlue,
      DarkKhaki,IndianRed,MediumOrchid,GreenYellow,MediumAquamarine,DarkSeaGreen,Tomato,RosyBrown,Orchid,MediumPurple,
      PaleVioletRed,Coral,CornflowerBlue,DarkGray,SandyBrown,MediumSlateBlue,Tan,DarkSalmon,BurlyWood,HotPink,Salmon,
      Violet,LightCoral,SkyBlue,LightSalmon,Plum,Khaki,LightGreen,Aquamarine,Silver,LightSkyBlue,LightSteelBlue,
      LightBlue,PaleGreen,Thistle,PowderBlue,PaleGoldenrod,PaleTurquoise,LightGray,Wheat,NavajoWhite,Moccasin,LightPink,
      Gainsboro,PeachPuff,Pink,Bisque,LightGoldenrod,BlanchedAlmond,LemonChiffon,Beige,AntiqueWhite,PapayaWhip,Cornsilk,
      LightYellow,LightCyan,Linen,Lavender,MistyRose,OldLace,WhiteSmoke,Seashell,Ivory,Honeydew,AliceBlue,
      LavenderBlush,MintCream,Snow,White
      //---- 
     };

   int size=ArraySize(ArrayColors);
   size-=2;
   int ColorWidth_=ColorWidth;
   if(ColorWidth>size) ColorWidth_=size;
   if(ColorWidth<1) ColorWidth_=1;

   color Colors[];

   if(ArrayResize(Colors,ColorWidth_)<ColorWidth_) Print("Failed to distribute the memory for Colors array");
   ArrayCopy(Colors,ArrayColors,0,2,ColorWidth_);

//---- indexing elements in the array as timeseries   
   ArraySetAsSeries(Colors,true);

   double K=double(ColorWidth_/(LINES_TOTAL*1.0));
//----
   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      period[numb]=xLength+Step*numb;

      string shortname="";
      StringConcatenate(shortname,"XMA-X",numb,"(",period[numb],")");
      //---- creating a name for displaying in a separate sub-window and in a tooltip
      PlotIndexSetString(numb,PLOT_LABEL,shortname);
      //---- setting the indicator values that won't be visible on a chart
      PlotIndexSetDouble(numb,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      //---- performing the shift of the beginning of the indicator drawing
      PlotIndexSetInteger(numb,PLOT_DRAW_BEGIN,min_rates_total);
      //---- set dynamic arrays as indicator buffers
      SetIndexBuffer(numb,Ind[numb].IndBuffer,INDICATOR_DATA);
      //---- indexing the elements in buffers as timeseries   
      ArraySetAsSeries(Ind[numb].IndBuffer,true);
      //---- copying the indicator first line parameters for all the rest ones
      PlotIndexSetInteger(numb,PLOT_DRAW_TYPE,PlotIndexGetInteger(0,PLOT_DRAW_TYPE));
      PlotIndexSetInteger(numb,PLOT_LINE_STYLE,PlotIndexGetInteger(0,PLOT_LINE_STYLE));
      PlotIndexSetInteger(numb,PLOT_LINE_WIDTH,PlotIndexGetInteger(0,PLOT_LINE_WIDTH));
      //---- setting color for the line
      PlotIndexSetInteger(numb,PLOT_LINE_COLOR,Colors[int(numb*K)]);
     }

//---- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA[0].GetString_MA_Method(xMA_Method);
   StringConcatenate(shortname,"XMA-X",LINES_TOTAL,"(",Step,",",xLength,", ",Smooth1,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declarations of local variables 
   int bar,limit,maxbar;
   double price_;

   maxbar=rates_total-1;

//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      limit=rates_total-1;                 // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- call of the PriceSeries function to get the input price 'price_'
      price_=PriceSeries(IPC,bar,open,low,high,close);

      for(int numb=0; numb<LINES_TOTAL; numb++)
        {
         Ind[numb].IndBuffer[bar]=XMA[numb].XMASeries(maxbar,prev_calculated,rates_total,xMA_Method,xPhase,period[numb],price_,bar,true);
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
