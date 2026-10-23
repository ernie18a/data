//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Frama (Ehlers) filtered"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Frama"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2

//
//--- input parameters
//

enum enUseHighLow
{
   hl_useHighLow, // Use high/lows for extremes
   hl_usePrices   // Use selected price for extremes
};
input int                inpPeriod = 30;           // Frama period
input double             inpFilter = 1;            // Filter size
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE;   // Price 
input enUseHighLow       inpHlMode = hl_useHighLow; // High/low mode

//
//--- buffers declarations
//

double val[],valc[],prices[];
int _fullSize,_halfSize,_halfSizem;

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
         SetIndexBuffer(0,val   ,INDICATOR_DATA);
         SetIndexBuffer(1,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,prices,INDICATOR_CALCULATIONS);
               _fullSize  = MathMax(inpPeriod,2);
               _halfSize  = MathMax(_fullSize/2,1);
               _halfSizem = (_halfSize>1) ? _halfSize-1 : 1;
                  iFilter.init(inpPeriod,inpFilter);
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Frama (Ehlers) ("+(string)_fullSize+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------

//
//---
//

#define _setPrice(_priceType,_where,_index) { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _where = close[_index];                                              break; \
      case PRICE_OPEN:     _where = open[_index];                                               break; \
      case PRICE_HIGH:     _where = high[_index];                                               break; \
      case PRICE_LOW:      _where = low[_index];                                                break; \
      case PRICE_MEDIAN:   _where = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _where = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _where = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _where = 0; \
   }}

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
   static int prev_i=-1;
   static double hh_prev,ll_prev,hh_curr,ll_curr,save_n1,save_n2,save_n3,n1,n2,n3,alpha;

   //
   //---
   //

   int i= prev_calculated-1; if (i<0) i = 0; for(; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,prices[i],i);

      //
      //---
      //

         if (prev_i!=i)
         {
            prev_i = i; int start;

               if (inpHlMode==hl_useHighLow)
               {
                  start = i-_fullSize+1; if (start<0) start=0;
                     hh_prev = high[ArrayMaximum(high,start,_halfSize)];
                     ll_prev = low[ArrayMinimum(low,start,_halfSize)];
                  start = i-_halfSize+1; if (start<0) start=0;
                     hh_curr = high[ArrayMaximum(high,start,_halfSizem)];
                     ll_curr = low[ArrayMinimum(low,start,_halfSizem)];
               }                  
               else
               {
                  start = i-_fullSize+1; if (start<0) start=0;
                     hh_prev = prices[ArrayMaximum(prices,start,_halfSize)];
                     ll_prev = prices[ArrayMinimum(prices,start,_halfSize)];
                  start = i-_halfSize+1; if (start<0) start=0;
                     hh_curr = prices[ArrayMaximum(prices,start,_halfSizem)];
                     ll_curr = prices[ArrayMinimum(prices,start,_halfSizem)];
               }

               n1 = (hh_prev-ll_prev)/(double)_halfSize;
         }

         //
         //---
         //

         double hh = MathMax((inpHlMode==hl_useHighLow)?high[i]:prices[i],hh_curr);
         double ll = MathMin((inpHlMode==hl_useHighLow)?low[i] :prices[i],ll_curr);
                n2 = (hh-ll)/(double)_halfSize;

                if (hh_prev>hh) hh = hh_prev;
                if (ll_prev<ll) ll = ll_prev;

                n3 = (hh-ll)/(double)_fullSize;

                if (save_n1!=n1 || save_n2!=n2 || save_n3!=n3)
                {
                     save_n1 = n1;
                     save_n2 = n2;
                     save_n3 = n3;

                     double dimen = (MathLog(n1+n2)-MathLog(n3))/M_LN2;
                            alpha = MathMin(MathMax(MathExp(-4.6*(dimen-1.0)),DBL_MIN),1.000);
                 }

      //
      //---
      //

      double _frama = (i>0) ? alpha*prices[i]+(1.0-alpha)*val[i-1] : prices[i];
      val[i]  = iFilter.calculate(_frama,i);
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
   }   
   return (i);
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