//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "RSI of smoother average"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "RSI(oma) of smoother shadow"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDimGray
#property indicator_width1  2
#property indicator_label2  "RSI(oma) of smoother"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width2  2

//
//
//

input int                inpRsiPeriod  = 14;          // RSI period
input int                inpMaPeriod   = 32;          // Smoother period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price
input int                inpShadow     = 7;           // "Shadow" width

//
//---
//

double val[],valc[],vals[];

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
         SetIndexBuffer(0,vals,INDICATOR_DATA);
         SetIndexBuffer(1,val ,INDICATOR_DATA);
         SetIndexBuffer(2,valc,INDICATOR_COLOR_INDEX);
            PlotIndexSetInteger(0,PLOT_LINE_WIDTH,inpShadow);
            iRsi.init(inpRsiPeriod);
            iSmoother.init(inpMaPeriod);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI (of smoother "+(string)inpMaPeriod+") ("+(string)inpRsiPeriod+")");
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

   //
   //---
   //

   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
         val[i]  = vals[i] = iRsi.calculate(iSmoother.calculate(_price,i,rates_total),i);
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

class CSmoother
{
   private :
      double m_period;
      double m_alpha;
      double m_beta;
      int    m_arraySize;
      struct CSmootherStruct
      {
         double l0;
         double l1;
         double l2;
         double l3;
         double l4;
      };
      CSmootherStruct m_array[];
   public :
      CSmoother() : m_arraySize(-1), m_alpha(1), m_beta(1) {}
     ~CSmoother() {}
   
      //
      //
      //
      
      bool init(double period)
      {
         m_period = (period>1) ? period : 1;
         m_beta   = 0.45 * (m_period-1.0)/(0.45 * (m_period-1)+2.0);
         m_alpha  = m_beta*m_beta*m_beta;
            return(true);
      }
      
      double calculate(double value, int i, int bars)
      {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }

         //
         //
         //
                    
         if (i>0)
         {
            m_array[i].l0 = (1.0-m_alpha)*value + m_alpha*m_array[i-1].l0;
            m_array[i].l1 = (value-m_array[i].l0)*(1-m_beta) + m_beta*m_array[i-1].l1;
            m_array[i].l2 =  m_array[i].l0 + m_array[i].l1;
            m_array[i].l3 = (m_array[i].l2 - m_array[i-1].l4)*(1.0-m_alpha)*(1.0-m_alpha) + m_alpha*m_alpha*m_array[i-1].l3;
            m_array[i].l4 =  m_array[i-1].l4 + m_array[i].l3;
         }                    
         else { m_array[i].l0 = m_array[i].l1 = m_array[i].l4 = value; m_array[i].l2 = m_array[i].l3 = 0; }
         return(m_array[i].l4);
      }
};
CSmoother iSmoother;
//------------------------------------------------------------------