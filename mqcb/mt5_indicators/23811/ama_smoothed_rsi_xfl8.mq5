//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Adaptive Moving Average - generalized version - smoothed RSI"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   4
#property indicator_label1  "Upper level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Middle level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Lower level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "AMA smoothed RSI"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width4  2

//
//
//

input int                inpRsiPeriod  = 14;          // RSI period
input int                inpPeriod     = 14;          // AMA Period
input int                inpFastPeriod =  2;          // AMA Fast end period
input int                inpSlowPeriod = 30;          // AMA Slow end period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price
enum enColorChangeOn
{
   cchange_onSlope,  // Change color on slope change
   cchange_onLevels, // Change color on outer levels cross
   cchange_onZero    // Change color on middle level cross
};
input int                inpFlPeriod    = 25;               // Floating levels period
input double             inpFlLevelUp   = 90;               // Floating levels up %
input double             inpFlLevelDn   = 10;               // Floating levels down %
input enColorChangeOn    inpColorChange = cchange_onLevels; // Color changing mode

//
//---
//

double val[],valc[],prices[],levu[],levd[],levm[],rsi[];

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
         SetIndexBuffer(0,levu  ,INDICATOR_DATA);
         SetIndexBuffer(1,levm  ,INDICATOR_DATA);
         SetIndexBuffer(2,levd  ,INDICATOR_DATA);
         SetIndexBuffer(3,val   ,INDICATOR_DATA);
         SetIndexBuffer(4,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(5,prices,INDICATOR_CALCULATIONS);
         SetIndexBuffer(6,rsi   ,INDICATOR_CALCULATIONS);
            iAma.init(inpPeriod,inpFastPeriod,inpSlowPeriod);
            iRsi.init(inpRsiPeriod);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"AMA ("+(string)inpPeriod+","+(string)inpFastPeriod+","+(string)inpSlowPeriod+")smoothed RSI ("+(string)inpRsiPeriod+")");
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
   
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,prices[i],i);
         rsi[i] = iRsi.calculate(prices[i],i);
         iAma.calculate(rsi[i],val,rsi,rsi,i);
         if (prev_i!=i)
         {
            prev_i = i; 
            int start    = i-inpFlPeriod+1; if (start<0) start=0;
                prev_max = val[ArrayMaximum(val,start,inpFlPeriod-1)];
                prev_min = val[ArrayMinimum(val,start,inpFlPeriod-1)];
         }
         double max = (val[i] > prev_max) ? val[i] : prev_max;
         double min = (val[i] < prev_min) ? val[i]  : prev_min;
         double range = (max-min)/100.0;
            levu[i] = min+inpFlLevelUp*range;
            levd[i] = min+inpFlLevelDn*range;
            levm[i] = (levu[i]+levd[i])/2;
         
         //
         //
         //
         
         switch (inpColorChange)
         {
            case cchange_onLevels : valc[i] = (val[i]>levu[i]) ? 1 :(val[i]<levd[i]) ? 2 : 0; break;
            case cchange_onSlope  : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
            case cchange_onZero   : valc[i] = (val[i]>levm[i]) ? 1 :(val[i]<levm[i]) ? 2 : 0; break;
         }         
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

class CAma
{
   private :
      int    m_period;
      int    m_prev_i;
      double m_fastEnd;
      double m_slowEnd;
      double m_multiplier;
      double m_prev_max;
      double m_prev_min;
      

   public :
      CAma(void) { init(1,2,30); return; }
     ~CAma(void) {               return; }
    
      //
      //
      //

      bool init(int period, double fastEnd, double slowEnd)
      {
         m_period    = (period>1) ? period+1 : 2;
         m_fastEnd   = (2.0 /(fastEnd + 1.0));
         m_slowEnd   = (2.0 /(slowEnd + 1.0));
         return(true);
      }
      
      template <typename T1, typename T2, typename T3>
      void calculate(double value, T1 &target[], T2 &arrayMax[], T3 &arrayMin[], int i) 
      {       
         if (m_prev_i!=i)
         {
            m_prev_i = i; 
            int start    = i-m_period+1; if (start<0) start=0;
                m_prev_max = arrayMax[ArrayMaximum(arrayMax,start,m_period-1)];
                m_prev_min = arrayMin[ArrayMinimum(arrayMin,start,m_period-1)];
         }
         double max = (arrayMax[i] > m_prev_max) ? arrayMax[i] : m_prev_max;
         double min = (arrayMin[i] < m_prev_min) ? arrayMin[i] : m_prev_min;

         //
         //---
         //

         double mltp = (max!=min) ? ((value-min)-(max-value))/(max-min) : 1; if (mltp<0) mltp *= -1;
         double ssc  = mltp * ( m_fastEnd-m_slowEnd) + m_slowEnd;	
                target[i] = (i>0) ? target[i-1]+(ssc*ssc)*(value-target[i-1]) : value;
      }
};
CAma iAma;

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
         double change;
         double changa;
      };
      sRsiArray m_work[];
   public :
      cRsi() { init(1);           return; }
     ~cRsi() { ArrayFree(m_work); return; }
     
      //
      //---
      //
      
      void init(int period)
      {
         m_period    = (period>1) ? period : 1;
         m_arraySize = m_period+32;
         m_alpha     = 1.0/m_period;
            ArrayResize(m_work,m_arraySize);
      }
      
      double calculate(double price, int i)
      {
         int _indC = (i)%m_arraySize; m_work[_indC].price=price;
         
         //
         //---
         //
         
         if(i<m_period)
         {
            m_work[_indC].changa = 0;
               for(int k=0; i>k; k++) 
               m_work[_indC].changa += m_work[_indC-k].price>m_work[_indC-k-1].price ? m_work[_indC-k].price-m_work[_indC-k-1].price : m_work[_indC-k-1].price-m_work[_indC-k].price; 
               m_work[_indC].changa /=                                       (i+1.0);
               m_work[_indC].change  = (m_work[_indC].price-m_work[0].price)/(i+1.0);
         }
         else
         {
            int _indP = (_indC-1); if (_indP<0) _indP += m_arraySize;
               double change = m_work[_indC].price-m_work[_indP].price;
               double changa = change; if (change<0) changa = -change;
                      m_work[_indC].change =  m_work[_indP].change + m_alpha*(change - m_work[_indP].change);
                      m_work[_indC].changa =  m_work[_indP].changa + m_alpha*(changa - m_work[_indP].changa);
         }
         return(50.0*(m_work[_indC].change/(m_work[_indC].changa+DBL_MIN)+1.0));
      }
};
cRsi iRsi;
//------------------------------------------------------------------