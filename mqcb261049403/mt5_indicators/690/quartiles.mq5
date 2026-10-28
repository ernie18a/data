//+------------------------------------------------------------------+ 
//|                                                    Quartiles.mq5 | 
//|                                         Copyright © 2010, LeMan. |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, LeMan."
#property link      "b-market@mail.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 3 
//---- 3 plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- teal color is used for the indicator line
#property indicator_color1 Teal
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Upper Quartile"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- blue color is used for the indicator line
#property indicator_color2 Blue
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Middle Quartile"
//+-----------------------------------+
//|  Indicator 3 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type3   DRAW_LINE
//---- use orange color for the indicator line
#property indicator_color3 Orange
//---- the indicator line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "Lower Quartile"
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum ENUM_APPLIED_PRICE_ // Type of constant
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
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int N=20;
input double p1 = 0.25;
input double p3 = 0.75;
input ENUM_APPLIED_PRICE_ IPC=PRICE_CLOSE; // Applied price
input int Shift=0;                         // Horizontal shift of the indicator in bars
//+-----------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double q1Buffer[];
double q2Buffer[];
double q3Buffer[];
//---- declaration of global variables
int n1,n2t,n2f,n3;
double PriceArray[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,N_;
//+------------------------------------------------------------------+    
//| Custom indicator indicator initialization function               | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of constants
   double P1=p1;
   if(p1>1){P1=1;Print("p1 parameter cannot be above 1! Default value equal to 1 will be used!");}
   if(p1<0){P1=0;Print("p1 parameter cannot be less than 0! Default value equal to 0 will be used!");}
    
   double P3=p3;
   if(p3>1){P3=1;Print("p3 parameter cannot be above 1! Default value equal to 1 will be used!");}   
   if(p3<0){P3=0;Print("p3 parameter cannot be less than 0! Default value equal to 0 will be used!");}
    
   N_=N;
   if(N_<3){N_=3;Print("N parameter cannot be less than 3! Default value equal to 3 will be used!");}
    
   min_rates_total=N_;
   n1=int(MathRound(N_*P1));
   if(!n1) n1=1;
   n2t = (N_+1)/2;
   n2f = N_/2;
   n3=int(MathRound(N_*P3));
   if(!n3) n3=1;

//---- memory distribution for variables' arrays
   if(ArrayResize(PriceArray,N_)<N_) Print("Failed to distribute the memory for PriceArray[] array");

//---- set q3Buffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,q3Buffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by AroonShift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set q2Buffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,q2Buffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set q1Buffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,q1Buffer,INDICATOR_DATA);
//---- shifting the indicator 3 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the start of drawing the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname="Quartiles";
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
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
   if(rates_total<min_rates_total) return(0);

//---- declaration of integer variables
   int first,bar;
   double q1,q2,q3;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated==0) // checking for the first start of the indicator calculation
     {
      first=min_rates_total-1; // starting index for calculation of all bars

     }
   else        // starting index for calculation of new bars
     {
      first=prev_calculated-1;
     }

//---- main cycle of calculation of the channel center line
   for(bar=first; bar<rates_total; bar++)
     {
      for(int kkk=0; kkk<N_; kkk++)PriceArray[kkk]=PriceSeries(IPC,bar-kkk,open,low,high,close);
      ArraySort(PriceArray);

      if(N_%2>0) q2=PriceArray[n2t-1];
      else      q2=(PriceArray[n2f-1]+PriceArray[n2f])/2;

      q1 = PriceArray[n1-1];
      q3 = PriceArray[n3-1];

      q1Buffer[bar] = NormalizeDouble(q1, _Digits);
      q2Buffer[bar] = NormalizeDouble(q2, _Digits);
      q3Buffer[bar] = NormalizeDouble(q3, _Digits);
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Getting values of a price series                                 |
//+------------------------------------------------------------------+ 
double PriceSeries(uint applied_price,   // Applied price
                   uint   bar,           // Index of shift relative to the current bar for a specified number of periods back or forward).
                   const double &Open[],
                   const double &Low[],
                   const double &High[],
                   const double &Close[])
  {
//----
   switch(applied_price)
     {
      //---- Price constants from the ENUM_APPLIED_PRICE enumeration
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);

      //----                            
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      //----                                
      case 10:
        {
         if(Close[bar]>Open[bar])return(High[bar]);
         else
           {
            if(Close[bar]<Open[bar])
               return(Low[bar]);
            else return(Close[bar]);
           }
        }
      //----         
      case 11:
        {
         if(Close[bar]>Open[bar])return((High[bar]+Close[bar])/2.0);
         else
           {
            if(Close[bar]<Open[bar])
               return((Low[bar]+Close[bar])/2.0);
            else return(Close[bar]);
           }
         break;
        }
      //----
      default: return(Close[bar]);
     }
//----
  }
//+------------------------------------------------------------------+
