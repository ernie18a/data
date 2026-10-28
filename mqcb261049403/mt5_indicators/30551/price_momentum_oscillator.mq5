//------------------------------------------------------------------
#property copyright   "copyright© mladen 2020"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  3
#property indicator_plots    2
#property indicator_label1   "PMO"
#property indicator_type1    DRAW_COLOR_LINE
#property indicator_color1   clrDodgerBlue,clrCoral
#property indicator_width1   2
#property indicator_label2   "Signal"
#property indicator_type2    DRAW_LINE
#property indicator_color2   clrRed
#property indicator_style2   STYLE_DOT

//
//
//

input int                inpPeriod1      = 35;          // Period
input int                inpPeriod2      = 20;          // Period 2
input int                inpPeriodSignal = 10;          // Signal period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE; // Price
         enum enColorMode
         {
            col_slope,  // change color on slope change
            col_signal, // change color on signal cross
            col_zero,   // change color on 0 cross
         };
input enColorMode       inpColorMode    = col_signal; // Color mode :

double val[],valc[],vals[]; double _alpha1,_alpha2,_alphas;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA); 
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(2,vals,INDICATOR_DATA); 
      
      //
      //
      //

         _alpha1 = 2.0 / MathMax(inpPeriod1,1);
         _alpha2 = 2.0 / MathMax(inpPeriod2,1);
         _alphas = 2.0 / (1+MathMax(inpPeriodSignal,1));
         
      //
      //
      //
      
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Price momentum oscillator (%i,%i,%i)",inpPeriod1,inpPeriod2,inpPeriodSignal));
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {  return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   int limit = prev_calculated-1; if (limit<0) limit = 0;

   //
   //
   //

      struct sWorkStruc 
      { 
         double price;
         double roc;
         double EmaOfRoc;
         double PmoOsc;
      };
      static sWorkStruc m_work[];
      static int        m_workSize=-1;
                    if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);
      
   //
   //
   //
      
   for (int i=limit; i<rates_total; i++)
   {
      m_work[i].price = getPrice(inpPrice,open,high,low,close,i);
      if (i>0)
      {
         m_work[i].roc      = (m_work[i].price/m_work[i-1].price-1)*100;
         m_work[i].EmaOfRoc = m_work[i-1].EmaOfRoc + _alpha1*(m_work[i].roc     -m_work[i-1].EmaOfRoc);
         m_work[i].PmoOsc   = m_work[i-1].PmoOsc   + _alpha2*(m_work[i].EmaOfRoc-m_work[i-1].PmoOsc);

         val[i]  = m_work[i].PmoOsc;
         vals[i] = vals[i-1]+_alphas*(val[i]-vals[i-1]);
         
         //
         //
         //
         
         switch (inpColorMode)
         {
            case col_signal : valc[i] = val[i]>vals[i]  ? 0 : 1;                               break;
            case col_slope  : valc[i] = val[i]>val[i-1] ? 0 : val[i]<val[i-1] ? 1 : valc[i-1]; break;
            default :         valc[i] = val[i]>0  ? 0 : 1;                                     break;
         }            
      }
      else m_work[i].roc = m_work[i].EmaOfRoc = m_work[i].PmoOsc = val[i] = vals[i] = valc[i] = 0;
   }      
   return(rates_total);
}

//
//
//

template <typename T>
double getPrice(ENUM_APPLIED_PRICE price, T& open[], T& high[], T& low[], T& close[], int i)
{
   switch (price)
   {
      case PRICE_CLOSE:    return(close[i]);
      case PRICE_HIGH:     return(high[i]);
      case PRICE_LOW:      return(low[i]);
      case PRICE_OPEN:     return(open[i]);
      case PRICE_MEDIAN:   return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:  return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED: return((high[i]+low[i]+close[i]+close[i])/4.0);
   }            
   return(0);
}