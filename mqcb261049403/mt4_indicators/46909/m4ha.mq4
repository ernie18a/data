#property strict
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Aqua
#property indicator_width1 1
#property indicator_color2 Yellow
#property indicator_width2 1
#property indicator_color3 Blue
#property indicator_width3 2
#property indicator_color4 Red
#property indicator_width4 2
//---- indicator parameters
input int      inp_hma_period          = 7;     // hma period
input int      inp_ma_shift            = 0;     // ma shift
input int      inp_ma_method           = 3;     // ma method
input int      inp_ma_price            = 6;     // ma price
input double   inp_filter_number       = 2.0;   // filter number
input int      inp_shooth_period       = 14;    // smoothing period

//---- indicator ext_mains
double ext_main[];
double ext_smooth[];
double ext_arrow_up[];
double ext_arrow_dn[];
//----
int draw_begin0;
string AlertPrefix;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrameStr()
  {
   switch(Period())
     {
      case 1 : return("M1");
      case 5 : return("M5");
      case 15 : return("M15");
      case 30 : return("M30");
      case 60 : return("H1");
      case 240 : return("H4");
      case 1440 : return("D1");
      case 10080 : return("W1");
      case 43200 : return("MN1");
      default : return((string)Period());
     }
   return("NONE");
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator ext_mains mapping
   SetIndexBuffer(0,ext_main);
   SetIndexBuffer(1,ext_smooth);
   SetIndexBuffer(2,ext_arrow_up);
   SetIndexBuffer(3,ext_arrow_dn);
   Print("cannot set indicator ext_mains!");
// ArraySetAsSeries(ind_ext_main1,true);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(2,233);
   SetIndexArrow(3,234);
   draw_begin0=int(inp_hma_period+MathFloor(MathSqrt(inp_hma_period)));
   SetIndexDrawBegin(0,draw_begin0);
   SetIndexDrawBegin(1,draw_begin0);
   IndicatorDigits(int(MarketInfo(Symbol(),MODE_DIGITS)+1));
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("HMA("+(string)inp_hma_period+")");
   SetIndexLabel(0,"Hull Moving Average");
//---- initialization done
   AlertPrefix=Symbol()+" ("+GetTimeFrameStr()+"):  ";
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit,i;
//---- check for possible errors
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit--;

//---- MA difference counted in the 1-st ext_main
   for(i=0; i<limit; i++)
     {
      ext_main[i]=iMA(NULL,0,(int)MathFloor
                    (inp_hma_period/inp_filter_number),inp_ma_shift,inp_ma_method,inp_ma_price,i)*2-//change the inp_hma_period/xx will change when the colors chang at given rate
                    iMA(NULL,0,inp_hma_period,inp_ma_shift,inp_ma_method,inp_ma_price,i);
     }
//---- HMA counted in the 0-th ext_main
   for(i=0; i<limit; i++) 
      ext_smooth[i] =iMAOnArray(ext_main,0,inp_shooth_period,0,inp_ma_method,i);
      
   for(i=0; i<limit; i++) {
      if(i+1>=Bars) continue;
      if(ext_main[i] > ext_smooth[i] && ext_main[i+1] <= ext_smooth[i+1])
         ext_arrow_up[i] = Low[i]+5*_Point;
      else
         ext_arrow_up[i] = EMPTY_VALUE;
      if(ext_main[i] < ext_smooth[i] && ext_main[i+1] >= ext_smooth[i+1])
         ext_arrow_dn[i] = High[i]+5*_Point;
      else
         ext_arrow_dn[i] = EMPTY_VALUE;
   }   
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BarChanged()
  {
   static datetime dt=0;
   if(dt!=Time[0])
     {
      dt=Time[0];
      return(true);
     }
   return(false);
  }
//---- done
//+------------------------------------------------------------------+
int aRperiodf() { return(int(inp_hma_period*_Point*10000)); }
//+------------------------------------------------------------------+
