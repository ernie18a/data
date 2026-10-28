//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "AMA to KAMA state"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2
#property indicator_minimum 0
#property indicator_maximum 1

//
//--- input parameters
//

input int                inpPeriod           = 14;          // Period
input int                inpFastPeriod       =  2;          // Fast end period
input int                inpSlowPeriod       = 30;          // Slow end period
input double             inpPower            =  2;          // KAMA smoothing power
input ENUM_APPLIED_PRICE inpPrice            = PRICE_CLOSE; // Price

//
//--- indicator buffers
//

double val[],valf[],valc[],vals[],g_fastEnd,g_slowEnd; int g_hlPeriod;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------ 
//
//
//

int OnInit()
{
   //
   //
   //
         SetIndexBuffer(0,val  ,INDICATOR_DATA);
         SetIndexBuffer(1,valc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,valf ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,vals ,INDICATOR_CALCULATIONS);
            iKama.init(inpPeriod,inpFastPeriod,inpSlowPeriod,inpPower);
               g_fastEnd  = 2.0/(inpFastPeriod+1.0);   
               g_slowEnd  = 2.0/(inpSlowPeriod+1.0);   
               g_hlPeriod = inpPeriod+1;
   //      
   //
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"AMA to KAMA crosses ("+(string)inpPeriod+")");
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

      valf[i] = (i>0) ? valf[i-1]+(ssc*ssc)*(_price-valf[i-1]) : _price;
      vals[i] = iKama.calculate(_price,i);
      valc[i] = (valf[i]>vals[i]) ? 1 : (valf[i]<vals[i]) ? 2 : (i>0) ? valc[i-1] : 0;
      val[i]  = 1;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

class CKama
{
   private :
      int    m_period;
      int    m_arraySize;
      double m_fastEnd;
      double m_slowEnd;
      double m_power;
      struct sKamaStruct
      {
         double difference;
         double noise;
         double price;
         double kama;
      };
      sKamaStruct m_array[];

   public :
      CKama() { init(1,2,30,2);     return; }
     ~CKama() { ArrayFree(m_array); return; }
     
     //
     //
     //
     
     bool init(int period, double fastEnd, double slowEnd, double power)
     {
         m_period    = (period>1) ? period : 1;
         m_arraySize =  m_period+32;
         m_fastEnd   = (2.0 /(fastEnd + 1.0));
         m_slowEnd   = (2.0 /(slowEnd + 1.0));
         m_power     = power;
            if (ArrayResize(m_array,m_arraySize)!=m_arraySize) return(false);
                                                               return(true);
     }
     
     double calculate (double value, int i)
     {
         int _indC = (i  )%m_arraySize;
         int _indP = (i-1)%m_arraySize;

            m_array[_indC].price      = value;
            m_array[_indC].difference = (i>0) ? value-m_array[_indP].price : 0; if (m_array[_indC].difference<0) m_array[_indC].difference *= -1.0;

            //
            //
            //
                     
            double signal  = 0;
               if (i>m_period)
               {
                  int _indF = (i-m_period)%m_arraySize;
                     signal               = value-m_array[_indF].price; if (signal<0) signal *= -1.0;
                     m_array[_indC].noise = m_array[_indP].noise + m_array[_indC].difference - m_array[_indF].difference;
               }         
               else         
               {
                     m_array[_indC].noise = m_array[_indC].difference;
                     for(int k=1; k<m_period && i>=k; k++) m_array[_indC].noise += m_array[i-k].difference;
               }
      
             //
             //
             //
             
             double efratio = (m_array[_indC].noise!=0) ? signal/m_array[_indC].noise : 1;
             m_array[_indC].kama = (i>0) ? m_array[_indP].kama+MathPow(efratio*(m_fastEnd-m_slowEnd)+m_slowEnd,m_power)*(value-m_array[_indP].kama) : value;
      return(m_array[_indC].kama);
   }
};
CKama iKama;
//------------------------------------------------------------------
