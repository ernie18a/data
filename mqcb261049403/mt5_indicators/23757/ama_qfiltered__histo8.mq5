//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "AMA filtered"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "AMA"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2
#property indicator_minimum 0
#property indicator_maximum 1

//
//
//

input int                inpPeriod     = 14;          // Period
input int                inpFastPeriod =  2;          // Fast end period
input int                inpSlowPeriod = 30;          // Slow end period
input double             inpFilter     = 1.5;         // Filter size (<=0 for no filter)
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price

//
//---
//

double val[],valc[],ama[],amaf[],g_fastEnd,g_slowEnd; int g_hlPeriod;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------ 
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,ama ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,amaf,INDICATOR_CALCULATIONS);
            g_fastEnd  = 2.0/(inpFastPeriod+1.0);   
            g_slowEnd  = 2.0/(inpSlowPeriod+1.0);   
            g_hlPeriod = inpPeriod+1;
               iFilter.init(inpPeriod,inpFilter);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"AMA ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}

//
//---
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
   static int    prev_i=-1;
   static double prev_max,prev_min;

   //
   //
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      if (prev_i!=i)
         {
            prev_i = i; 
            int start    = i-g_hlPeriod+1; if (start<0) start=0;
                prev_max = high[ArrayMaximum(high,start,g_hlPeriod-1)];
                prev_min = low [ArrayMinimum(low ,start,g_hlPeriod-1)];
         }
         double max = (high[i] > prev_max) ? high[i] : prev_max;
         double min = (low[i]  < prev_min) ? low[i]  : prev_min;

         //
         //---
         //

         double mltp = (max!=min) ? ((_price-min)-(max-_price))/(max-min) : 1; if (mltp<0) mltp *= -1;
         double ssc  = mltp * ( g_fastEnd-g_slowEnd) + g_slowEnd;	
	
         //
         //---
         //

      ama[i]  = (i>0) ? ama[i-1]+(ssc*ssc)*(_price-ama[i-1]) : _price;
      amaf[i] = iFilter.calculate(ama[i],i); 
      val[i]  = 1;
      valc[i]=(i>0) ?(amaf[i]>amaf[i-1]) ? 1 :(amaf[i]<amaf[i-1]) ? 2 : valc[i-1]: 0;
   }
   return(i);
}
//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

class CFilter
{
   private :
      int    m_period;
      int    m_arraySize;
      double m_filter;
      struct sFilterArrayStruct
         {
            double value;
            double change;
            double power;
            double summc;
            double summp;
         };
      sFilterArrayStruct m_array[];
   
   public :  
      CFilter() { init(1,0); }
     ~CFilter() { ArrayFree(m_array); }
     
     ///
     ///
     ///
     
     bool init (int period, double filter)
     {
         m_period    = (period>1) ? period : 1;
         m_filter    = (filter>=0) ? filter : 0;
         m_arraySize = m_period + 32;
               if (ArrayResize(m_array,m_arraySize)!=m_arraySize) return(false);
                                                                  return(true);
     }
     
     double calculate(double value, int i)
     {
         int _indC = (i  )%m_arraySize;
         int _indP = (i-1)%m_arraySize;
         
            //
            //
            //
            
            m_array[_indC].value  = value; double _change = (i>0) ? m_array[_indC].value-m_array[_indP].value : 0;
            m_array[_indC].change = (_change>0) ? _change : - _change;
            if (i>m_period)
            {
               int _indF = (i-m_period)%m_arraySize;
                  #define _power(_val) ((_val)*(_val))
                     m_array[_indC].summc =  m_array[_indP].summc +m_array[_indC].change-m_array[_indF].change;
                     m_array[_indC].power = _power(m_array[_indC].change-m_array[_indC].summc/(double)m_period);
                     m_array[_indC].summp =  m_array[_indP].summp+m_array[_indC].power-m_array[_indF].power;
            }              
            else
            {
                     m_array[_indC].summc  = 
                     m_array[_indC].summp = 0; 
                     for(int k=0; k<m_period && i>=k; k++) m_array[_indC].summc += m_array[_indC-k].change; 
                                                           m_array[_indC].power  = _power(m_array[_indC].change-m_array[_indC].summc/(double)m_period);
                     for(int k=0; k<m_period && i>=k; k++) m_array[_indC].summp += m_array[_indC-k].power; 
                  #undef _power
            }            
            if (i>0 && m_filter>0 && m_array[_indC].change<m_filter*MathSqrt(m_array[_indC].summp/(double)m_period)) m_array[_indC].value=m_array[_indP].value;
         return (m_array[_indC].value);
     }
};
CFilter iFilter;
//------------------------------------------------------------------