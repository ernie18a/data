//------------------------------------------------------------------
#property copyright   "copyright© mladen 2020"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  2
#property indicator_plots    2
#property indicator_label1   "Short"
#property indicator_type1    DRAW_LINE
#property indicator_color1   clrSilver
#property indicator_width1   2
#property indicator_label2   "Long"
#property indicator_type2    DRAW_LINE
#property indicator_color2   clrRed
#property indicator_width2   2

//
//
//

input int                inpPeriodShort = 20;          // Short period
input int                inpPeriodLong  = 40;          // Long period
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE; // Price

double vals[],vall[]; int _longPeriod, _shortPeriod;
double SSyy,SSy,LSyy,LSy,_ts2,_tl2;
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,vals,INDICATOR_DATA); 
   SetIndexBuffer(1,vall,INDICATOR_DATA); 
      
      //
      //
      //

      _longPeriod  = MathMax(inpPeriodShort,inpPeriodLong);
      _shortPeriod = MathMin(inpPeriodShort,inpPeriodLong);

      for (int k=0,y=0; k<_longPeriod; k++,y--)
         {
            if (k<_shortPeriod)
            {
               SSy  += y;
               SSyy += y*y;
            }
            LSy  += y;
            LSyy += y*y;
         }
         _ts2 = _shortPeriod*SSyy-SSy*SSy;
         _tl2 = _longPeriod *LSyy-LSy*LSy;

      //
      //
      //
      
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Correlation trend (%i,%i)",_shortPeriod,_longPeriod));
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
         struct sCalcStruct
         {
            double Sx;
            double Sxx;
            double Sxy;
         };
         sCalcStruct sums[2]; 
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
         
      //
      //
      //
         
         if (i>_shortPeriod)
            {
               m_work[i].sums[0].Sx  = m_work[i-1].sums[0].Sx  + m_work[i].price                 - m_work[i-_shortPeriod].price;
               m_work[i].sums[0].Sxx = m_work[i-1].sums[0].Sxx + m_work[i].price*m_work[i].price - m_work[i-_shortPeriod].price*m_work[i-_shortPeriod].price;
               m_work[i].sums[0].Sxy = m_work[i-1].sums[0].Sxy - m_work[i].sums[0].Sx + m_work[i].price + (_shortPeriod-1)*m_work[i-_shortPeriod].price;
            }
         else
            {
               m_work[i].sums[0].Sx  = m_work[i].price;
               m_work[i].sums[0].Sxx = m_work[i].price*m_work[i].price;
               m_work[i].sums[0].Sxy = 0;
               for (int k=1,y=-1; k<_shortPeriod && i>=k; k++,y--)
               {
                  m_work[i].sums[0].Sx  += m_work[i-k].price;
                  m_work[i].sums[0].Sxx += m_work[i-k].price*m_work[i-k].price;
                  m_work[i].sums[0].Sxy += m_work[i-k].price*y;
               }
            }
         
         //
         //
         //
         
         if (i>_longPeriod)
            {
               m_work[i].sums[1].Sx  = m_work[i-1].sums[1].Sx  + m_work[i].price                 - m_work[i-_longPeriod].price;
               m_work[i].sums[1].Sxx = m_work[i-1].sums[1].Sxx + m_work[i].price*m_work[i].price - m_work[i-_longPeriod].price*m_work[i-_longPeriod].price;
               m_work[i].sums[1].Sxy = m_work[i-1].sums[1].Sxy - m_work[i].sums[1].Sx + m_work[i].price + (_longPeriod-1)*m_work[i-_longPeriod].price;
            }
         else
            {
               m_work[i].sums[1].Sx  = m_work[i].price;
               m_work[i].sums[1].Sxx = m_work[i].price*m_work[i].price;
               m_work[i].sums[1].Sxy = 0;
               for (int k=1,y=-1; k<_longPeriod && i>=k; k++,y--)
               {
                  m_work[i].sums[1].Sx  += m_work[i-k].price;
                  m_work[i].sums[1].Sxx += m_work[i-k].price*m_work[i-k].price;
                  m_work[i].sums[1].Sxy += m_work[i-k].price*y;
               }
            }
         
      //
      //
      //
         
      double _ts1 = _shortPeriod*m_work[i].sums[0].Sxx-m_work[i].sums[0].Sx*m_work[i].sums[0].Sx;
      double _tl1 = _longPeriod *m_work[i].sums[1].Sxx-m_work[i].sums[1].Sx*m_work[i].sums[1].Sx;

      vals[i] = (_ts1>0 && _ts2>0) ? (_shortPeriod*m_work[i].sums[0].Sxy-m_work[i].sums[0].Sx*SSy)/MathSqrt(_ts1*_ts2) : 0;
      vall[i] = (_tl1>0 && _tl2>0) ? (_longPeriod *m_work[i].sums[1].Sxy-m_work[i].sums[1].Sx*LSy)/MathSqrt(_tl1*_tl2) : 0;
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