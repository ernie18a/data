//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "SVE Stochastic RSI"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "SVE Stochastic Rsi"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//
//

input int                inpRsiPeriod  = 21;          // RSI period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price
input int                inpStoPeriod  =  8;          // Stochastic period
input int                inpAvgPeriod  =  5;          // Average period

//
//---
//

double val[],valc[],rsi[];

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
         SetIndexBuffer(2,rsi ,INDICATOR_CALCULATIONS);
            iRsi.init(inpRsiPeriod);
            avgRsiLow.init(inpAvgPeriod);
            avgHighLow.init(inpAvgPeriod);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic RSI ("+(string)inpRsiPeriod+","+(string)inpStoPeriod+","+(string)inpAvgPeriod+")");
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
         static double prev_max=0,prev_min=0;
   //
   //---
   //

   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
         rsi[i] = iRsi.calculate(_price,i);
         if (prev_i!=i)
         {
            prev_i = i;
            int start = i-inpStoPeriod+1; if (start<0) start=0;
               prev_max = rsi[ArrayMaximum(rsi,start,inpStoPeriod-1)];
               prev_min = rsi[ArrayMinimum(rsi,start,inpStoPeriod-1)];
         }
         double max = (rsi[i]>prev_max) ? rsi[i] : prev_max;
         double min = (rsi[i]<prev_min) ? rsi[i] : prev_min;
         
         //
         //---
         //

            double _avgRsiLow  = avgRsiLow.calculate(rsi[i]-min,i,rates_total);
            double _avgHighLow = avgHighLow.calculate(max-min,i,rates_total);
         
         //
         //---
         //

         val[i]  = (_avgHighLow!=0) ? 100*_avgRsiLow/_avgHighLow : 0;
         valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

class cRsi
{
   private :
      int    m_period;
      int    m_arraySize;
      double m_alpha;
      struct sRsiArray
      {
         double price;
         double change1;
         double changa1;
         double change;
         double changa;
      };
      sRsiArray m_work[];
   public :
      cRsi() : m_period(1), m_alpha(1), m_arraySize(33) { ArrayResize(m_work,33); return; }
     ~cRsi()                                            { ArrayFree(m_work);      return; }
     
      //
      //---
      //
      
      void init(int period)
      {
         m_period    = (period>1) ? period : 1;
         m_arraySize = m_period+32;
         m_alpha     = 1.0/MathSqrt(m_period);
            ArrayResize(m_work,m_arraySize);
      }
      
      double calculate(double price, int i)
      {
         int _indC = (i)%m_arraySize; m_work[_indC].price=price;
         
         //
         //---
         //
         
         if(i>m_period)
         {
            int _indP = (_indC-1); if (_indP<0) _indP += m_arraySize;
               double change = m_work[_indC].price-m_work[_indP].price;
               double changa = change; if (change<0) changa = -change;
                      m_work[_indC].change1 =  m_work[_indP].change1 + m_alpha*(change                - m_work[_indP].change1);
                      m_work[_indC].change  =  m_work[_indP].change  + m_alpha*(m_work[_indC].change1 - m_work[_indP].change );
                      m_work[_indC].changa1 =  m_work[_indP].changa1 + m_alpha*(changa                - m_work[_indP].changa1);
                      m_work[_indC].changa  =  m_work[_indP].changa  + m_alpha*(m_work[_indC].changa1 - m_work[_indP].changa );
         }
         else
         {
            m_work[_indC].changa = 0;
               for(int k=0; i>k; k++) 
               m_work[_indC].changa += m_work[_indC-k].price>m_work[_indC-k-1].price ? m_work[_indC-k].price-m_work[_indC-k-1].price : m_work[_indC-k-1].price-m_work[_indC-k].price; 
               m_work[_indC].changa /=                                       (i+1.0); m_work[_indC].changa1 = m_work[_indC].changa;
               m_work[_indC].change  = (m_work[_indC].price-m_work[0].price)/(i+1.0); m_work[_indC].change1 = m_work[_indC].change;
         }
         if (m_work[_indC].changa!=0)
               return(50.0*(m_work[_indC].change/m_work[_indC].changa+1.0));
         else  return(0);   
      }
};
cRsi iRsi;

//
//---
//

class CSma
{
   private :
      int    m_period;
      int    m_arraySize;
      struct sSmaArrayStruct
         {
            double value;
            double summ;
         };
      sSmaArrayStruct m_array[];
   public :
      CSma() : m_period(1), m_arraySize(-1) {                     return; }
     ~CSma()                                { ArrayFree(m_array); return; }
     
     //
     //---
     //
      
     void init(int period) 
         { 
            m_period = (period>1) ? period : 1; 
         }
         
     double calculate(double value, int i, int bars)
         {
            if (m_arraySize<bars) { m_arraySize= ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }
            
            //
            //---
            //
            
            m_array[i].value=value;
               if (i>m_period)
                     m_array[i].summ = m_array[i-1].summ+value-m_array[i-m_period].value;
               else
               {
                     m_array[i].summ = 0;
                     int k=0; for(; k<m_period && i>=k; k++)
                            m_array[i].summ += m_array[i-k].value;
                     return(m_array[i].summ/(double)k);
               }         
               return(m_array[i].summ/(double)m_period);
      }
};

CSma avgRsiLow,avgHighLow;
//------------------------------------------------------------------