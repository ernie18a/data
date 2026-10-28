//+------------------------------------------------------------------+
//|                                                 at_Itp(t)Env.mq5 | 
//|                                             Copyright © 2011     | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, "
#property link ""
#property description "Redrawing curvelinear channel"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers 3
#property indicator_buffers 3 
//---- 3 plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- Purple color is used for the indicator
#property indicator_color1 Purple
//---- the indicator line is a dash-dotted curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "at_Itp(t)Env"
//+--------------------------------------------+
//|  Indicator drawing parameters              |
//+--------------------------------------------+
//---- drawing the envelopes as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- selection of the envelopes colors
#property indicator_color2  DeepPink
#property indicator_color3  DeepPink
//---- the envelopes are solid curves
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- envelopes width is equal to 1
#property indicator_width2  1
#property indicator_width3  1
//---- envelopes labels display
#property indicator_label2  "+Envelope"
#property indicator_label3  "-Envelope"
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
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint hours=4;
input uint s=10;
input uint cb=500;                    // Bars estimated number
input double Envelope_Shift=0.20;     // Channel width
input Applied_price_ IPC=PRICE_CLOSE; // Applied price
input int Shift=0;                    // Horizontal shift of the indicator in bars
//+-----------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ExtLineBuffer0[],ExtLineBuffer1[],ExtLineBuffer2[];

//---- declaration of the integer variables for the start of data calculation
int min_rates_total,pt;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   pt=int(hours*60*60/PeriodSeconds());
   min_rates_total=int(cb+2*pt)+1;

//---- set ExtLineBuffer0[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer0,INDICATOR_DATA);

//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as time series
   ArraySetAsSeries(ExtLineBuffer0,true);

//---- set ExtLineBuffer1[] and ExtLineBuffer2[] dynamic arrays into indicator buffers
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);

//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as time series
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);

//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"at_Itp(t)Env");

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| Custom iteration function                                        | 
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

//---- declaration of integer variables and getting already calculated bars
   int bar,x,m,aa,bb,cc,empty_rates;

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   empty_rates=rates_total-min_rates_total;
//----   
   for(bar=0; bar<=empty_rates && !IsStopped(); bar++)
     {
      ExtLineBuffer0[bar]=EMPTY_VALUE;
      ExtLineBuffer1[bar]=EMPTY_VALUE;
      ExtLineBuffer2[bar]=EMPTY_VALUE;
     }

//----   
   for(m=0; m<=int(s) && !IsStopped(); m++)
     {
      bar=0;
      while(bar<=int(cb))
        {
         if(!m)
           {
            ExtLineBuffer0[cb+pt]=PriceSeries(IPC,cb+pt,open,low,high,close);
            ExtLineBuffer0[bar]=PriceSeries(IPC,bar,open,low,high,close);
            ExtLineBuffer0[cb+2*pt]=PriceSeries(IPC,cb+2*pt,open,low,high,close);
           }

         if(m && m!=s)
           {
            ExtLineBuffer0[bar+pt]=0.5*(ExtLineBuffer0[bar]+ExtLineBuffer0[bar+2*pt]);
            ExtLineBuffer0[0]=0.5*(ExtLineBuffer0[0]+ExtLineBuffer0[pt]);
            ExtLineBuffer0[cb+2*pt]=0.5*(ExtLineBuffer0[cb+2*pt]+ExtLineBuffer0[cb+pt]);
           }

         if(m==s)
           {
            aa=bar;
            bb=bar+pt;
            cc=bar+2*pt;

            for(x=bar; x<=bar+pt-1; x++)
               ExtLineBuffer0[x]=ExtLineBuffer0[aa]*((x-bb)*(x-cc))/((aa-bb)*(aa-cc))+ExtLineBuffer0[bb]*((x-aa)*(x-cc))
                                 /((bb-aa)*(bb-cc))+ExtLineBuffer0[cc]*((x-aa)*(x-bb))/((cc-aa)*(cc-bb));
           }

         bar+=pt;
        }
     }

//---- envelopes main calculation loop
   bar=0;
   while(bar<=int(cb+pt))
     {
      ExtLineBuffer1[bar]=ExtLineBuffer0[bar]*(1+Envelope_Shift/100);
      ExtLineBuffer2[bar]=ExtLineBuffer0[bar]/(1+Envelope_Shift/100);
      bar++;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Getting values of a price time series                            |
//+------------------------------------------------------------------+ 
double PriceSeries(uint  applied_price, // applied price
                   uint  bar,           // index of shift relative to the current bar for a specified number of periods back or forward
                   const double &Open[],
                   const double &Low[],
                   const double &High[],
                   const double &Close[])
  {
//----
   switch(applied_price)
     {
      //---- price constants from the ENUM_APPLIED_PRICE enumeration
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
//return(0);
  }
//+------------------------------------------------------------------+
