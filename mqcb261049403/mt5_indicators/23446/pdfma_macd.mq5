//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Probability Density Funcion based MA MACD"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrDarkGray
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrPaleVioletRed
#property indicator_width2  2

//
//--- input parameters
//

input int                inpFastPeriod   = 12;          // Fast period
input int                inpSlowPeriod   = 26;          // Slow period
input int                inpSignalPeriod =  9;          // Signal period
input double             inpVariance     =  1;          // Variance
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE; // Price

//
//--- indicator buffers
//

double macd[],signal[];

//------------------------------------------------------------------
// Custom indicator initialization function                          
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,macd  ,INDICATOR_DATA);
         SetIndexBuffer(1,signal,INDICATOR_DATA);
            iPdfMaFast.init(inpFastPeriod,inpVariance);
            iPdfMaSlow.init(inpSlowPeriod,inpVariance);
            iPdfMaSignal.init(inpSignalPeriod,inpVariance);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Pdf MA MACD ("+(string)inpFastPeriod+","+(string)inpSlowPeriod+","+(string)inpSignalPeriod+")("+(string)inpVariance+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      macd[i]   = iPdfMaFast.calculate(_price,i)-iPdfMaSlow.calculate(_price,i);
      signal[i] = iPdfMaSignal.calculate(macd[i],i);
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

class cPdfMa
{
   private :
         int    m_period;
         int    m_arraysize;
         double m_work[];
         double m_coeffs[];
         double m_coeffw;
                     
   public : 
         cPdfMa() { init(1,1,0); }
        ~cPdfMa() {};
   
         //
         //
         //
         
         void init(int period, double variance) { init(period,variance,0); }
         void init(int period, double variance, double mean)
         {
            m_period    = (period>1) ? period : 1;
            m_arraysize = m_period+32;
            m_coeffw    = 0; 

               ArrayResize(m_work,m_arraysize); ArrayInitialize(m_work,0);
               ArrayResize(m_coeffs,m_period);

               //
               //---
               //
               
               #define maxx 3.5
               #define pdf(_x,_variance,_mean) (1.0/MathSqrt(2*M_PI*_variance*_variance)*MathExp(-((_x-_mean)*(_x-_mean))/(2*_variance*_variance)))
         
                     if (variance < 0.01) variance = 0.01;
                     if (mean     < -1)   mean     = -1;
                     if (mean     >  1)   mean     =  1;
                        if (m_period>1)
                              { 
                                 double step = maxx/(m_period-1); 
                                 for(int i=0; i<m_period; i++) 
                                 { 
                                    m_coeffs[i] = pdf(i*step,variance,mean*maxx); 
                                    m_coeffw   += m_coeffs[i]; 
                                 }
                              }
                        else  { m_coeffs[0] = m_coeffw = 1; }
         
               #undef pdf #undef maxx  
         }
         
         double calculate(double price, int i)
         {
            int _indC = (i)%m_arraysize; m_work[_indC] = price;
            double _avg = 0; 
                  for (int k=0; k<m_period; k++,_indC--) 
                  { 
                     if (_indC<0) _indC += m_arraysize; 
                                  _avg  += m_work[_indC]*m_coeffs[k]; 
                  }
            return(_avg/m_coeffw);
         }
};
cPdfMa iPdfMaFast,iPdfMaSlow,iPdfMaSignal;
//------------------------------------------------------------------