//------------------------------------------------------------------
#property copyright   "© mladen, 2020"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "ATR adaptive SMA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 34
#property indicator_plots   2
#property indicator_label1  "SMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_width1  0
#property indicator_label2  "Adaptive SMA"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width2  2

//
//
//

input int                inpMaPeriod = 25;          // SMA period
input ENUM_APPLIED_PRICE inpPrice    = PRICE_CLOSE; // Price
      enum enColorMode
      {
         col_onSlope, // Change color on slope change
         col_onCross, // Change color on two sma cross
      };
input enColorMode        inpColorMode = col_onCross; // Color change mode

//
//
//

double val[],valc[],sma[],atr[];

//------------------------------------------------------------------ 
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,sma ,INDICATOR_DATA);
   SetIndexBuffer(1,val ,INDICATOR_DATA);
   SetIndexBuffer(2,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,atr ,INDICATOR_CALCULATIONS);

      //
      //
      //

   IndicatorSetString(INDICATOR_SHORTNAME,"ATR adaptive SMA ("+(string)inpMaPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int limit = prev_calculated-1; if (limit<0) limit = 0;
   
   //
   //
   //
   
      struct sWorkStruct
            {
               double price;
               double tr;
               double sumtr;
               double min;
               double max;
               double sum;
               double sumSma;
               int    period;
               int    prevBar;
                  sWorkStruct() : prevBar(-1), period(INT_MIN) {};
            };
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize<=rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

   //
   //---
   //
   
   for (int i=limit; i<rates_total && !_StopFlag; i++)
   {
      m_work[i].price = getPrice(inpPrice,open,high,low,close,i);
      m_work[i].tr    = (i>0) ? (high[i]>close[i-1] ? high[i] : close[i-1]) -(low[i]<close[i-1] ? low[i] : close[i-1]) : high[i]-low[i];
         if (i>inpMaPeriod)
               {
                  m_work[i].sumSma = m_work[i-1].sumSma + m_work[i].price - m_work[i-inpMaPeriod].price;
                  m_work[i].sumtr  = m_work[i-1].sumtr  + m_work[i].tr    - m_work[i-inpMaPeriod].tr;
               }                  
         else  { 
                  m_work[i].sumSma = m_work[i].price; for (int k=1; k<inpMaPeriod && i>=k; k++) m_work[i].sumSma += m_work[i-k].price;
                  m_work[i].sumtr  = m_work[i].tr;    for (int k=1; k<inpMaPeriod && i>=k; k++) m_work[i].sumtr  += m_work[i-k].tr;
               }            
               atr[i] = m_work[i].sumtr/(double)inpMaPeriod;
               sma[i] = NormalizeDouble(m_work[i].sumSma/(double)inpMaPeriod,_Digits);

      //
      //
      //
         
         if (m_work[i  ].prevBar!=i ||
             m_work[i+1].prevBar>i)
             {
                  if (inpMaPeriod>1)
                  {
                        int _start = MathMax(i-inpMaPeriod+1,0);
                           m_work[i].max = atr[ArrayMaximum(atr,_start,inpMaPeriod-1)];            
                           m_work[i].min = atr[ArrayMinimum(atr,_start,inpMaPeriod-1)];            
                  }
                  else { m_work[i].max = -DBL_MAX; m_work[i].min = DBL_MAX; }
            }
             
         double _max   = m_work[i].max > atr[i] ? m_work[i].max : atr[i];            
         double _min   = m_work[i].min < atr[i] ? m_work[i].min : atr[i];            
         double _coeff = (_min!=_max) ? 1-(atr[i]-_min)/(_max-_min) : 0.5;
      
         int _period = int(inpMaPeriod*(_coeff+1.0)/2.0);
         if (m_work[i+1].period  != _period ||
             m_work[i  ].prevBar != i       ||
             m_work[i+1].prevBar >  i)
             {
                  m_work[i  ].prevBar = i;
                  m_work[i+1].prevBar = -1;
                  m_work[i+1].period  = _period;
                  m_work[i].sum       = 0; 
                     for (int k=1; k<_period && i>=k; k++) m_work[i].sum += m_work[i-k].price; 
             }            

         //
         //
         //
               
         val[i]  = (_period>0) ? NormalizeDouble((m_work[i].sum+m_work[i].price)/(double)_period,_Digits) : m_work[i].price;
         if (inpColorMode==col_onSlope)
               valc[i] = (i>0) ? (val[i]>val[i-1]) ? 2 : (val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
         else  valc[i] = (val[i]>sma[i]) ? 2 :(val[i]<sma[i]) ? 1 : (i>0) ? valc[i-1]: 0;
   }
   return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

double getPrice(int priceType, const double &open[], const double &high[], const double &low[], const double &close[], int i)
{
   switch(priceType)
      {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      }
   return(0);
}
