//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Filtered Deviation scaled MA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "DSMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//--- input parameters
//

input int                inpPeriod  = 25;          // MA period
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price
input int                inpPeriodf = 0;           // Filter period (<= 1 - same as ma period)
input double             inpFilter  = 1;           // Filter size

//
//--- indicator buffers
//

double val[],valc[];

//------------------------------------------------------------------
// Custom indicator initialization function                          
//------------------------------------------------------------------

int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
            iDsma.init(inpPeriod);
            iFilter.init(inpPeriodf>1?inpPeriodf:inpPeriod,inpFilter);
   //--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Deviation scaled MA ("+(string)inpPeriod+")");
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
      val[i]  = iFilter.calculate(iDsma.calculate(_price,i),i);
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

class cDsma
{
   private :
         int    m_period;
         int    m_arraysize;
         double m_periodMultiplier;
         double m_sc1;
         double m_sc2;
         double m_sc3;
            struct sDsmaArray
            {
               double filter;
               double price;
               double dsm;
               double ssm;
               double mul;
               double sum;
            };
         sDsmaArray m_array[];
                     
   public : 
         cDsma() : m_period(INT_MIN) {}
        ~cDsma() {};
   
         //
         //
         //
         
         void init(int period)
         {
            m_period           = (period>1) ? period : 1;
            m_periodMultiplier = 5.0 / (double)m_period;
            m_arraysize        = m_period+32;

               ArrayResize(m_array,m_arraysize);
               double a1 = MathExp(-1.414*M_PI_2/m_period);
                   m_sc2 = 2.0*a1*MathCos(1.414*M_PI/m_period);
                   m_sc3 = -a1*a1;
                   m_sc1 = 1.0 - m_sc2 - m_sc3;
         }
         
         double calculate(double price, int i)
         {
            int _indC = (i)%m_arraysize; m_array[_indC].price = price;
            
            //
            //---
            //
            
            if (i>1)
            {
               int _indP  = (i-1)%m_arraysize;
               int _indP2 = (i-2)%m_arraysize;
                     m_array[_indC].filter =  m_array[_indC].price-m_array[_indP2].price;
                     m_array[_indC].ssm    = m_sc1*(m_array[_indC].filter+m_array[_indP].filter)/2.0 + 
                                             m_sc2*m_array[_indP ].ssm                               + 
                                             m_sc3*m_array[_indP2].ssm; 
                    
                     m_array[_indC].mul = m_array[_indC].ssm*m_array[_indC].ssm;
                     
                     //
                     //---
                     //
                     
                     if  (i>m_period)
                            m_array[_indC].sum = m_array[_indP].sum+m_array[_indC].mul-m_array[(i-m_period)%m_arraysize].mul;
                     else { m_array[_indC].sum = m_array[_indC].mul; for (int k=1; k<m_period && i>=k; k++) m_array[_indC].sum += m_array[_indC-k].mul; }

                     double  rms        = m_array[_indC].sum ? MathSqrt(m_array[_indC].sum / m_period) : 1;
                     double _scaledFilt = m_array[_indC].ssm / rms;
                     double _alpha      = (_scaledFilt>0 ? _scaledFilt : -_scaledFilt) * m_periodMultiplier;
         
                   m_array[_indC].dsm = m_array[_indP].dsm+_alpha*(price-m_array[_indP].dsm);
            }
            else { m_array[_indC].dsm = price; m_array[_indC].ssm = m_array[_indC].mul = m_array[_indC].filter = 0; }
            return(m_array[_indC].dsm);
         }
};
cDsma iDsma;

//
//---
//

class cFilter
{
   private :
      int    m_period;
      int    m_arraySize;
      double m_filter;
      double m_filter2;
      struct sFilterArrayStruct
         {
            double value;
            double change;
            double power;
            double sumc;
            double sump;
         };
      sFilterArrayStruct m_array[];
   public :
      cFilter() { init(1,0);}
     ~cFilter() { ArrayFree(m_array); };
   
      //
      //---
      //
   
      void init(int period, double filter)
      {
         m_period    = (period>1) ? period : 1;
         m_filter    = filter;
         m_filter2   = m_filter*m_filter;
         m_arraySize = m_period+32;
            ArrayResize(m_array,m_arraySize);
      }
      
      double calculate(double value, int i)
      {
         if (m_filter<=0) return(value);
         
         //
         //---
         //
         
         int _indC = (i  )%m_arraySize;
         int _indP = (i-1)%m_arraySize;
      
         m_array[_indC].value = value; 
         m_array[_indC].change = (i>0) ? m_array[_indC].value>m_array[_indP].value ? m_array[_indC].value-m_array[_indP].value : m_array[_indP].value-m_array[_indC].value : 0;
         if (i>m_period)
         {
            #define _power(_val) ((_val)*(_val))
               int _indF = (i-m_period)%m_arraySize;
                 m_array[_indC].sumc  =  m_array[_indP].sumc +m_array[_indC].change-m_array[_indF].change;
                 m_array[_indC].power = _power(m_array[_indC].change-m_array[_indC].sumc/(double)m_period);
                 m_array[_indC].sump  =  m_array[_indP].sump+m_array[_indC].power-m_array[_indF].power;
              
                 //
                 //---
                 //
              
                 if (_power(m_array[_indC].change)/m_filter2<m_array[_indC].sump/(double)m_period) m_array[_indC].value = m_array[_indP].value;
         }              
         else
         {
               m_array[_indC].sumc = m_array[_indC].sump = 0; 
                  for(int k=0; k<m_period && i>=k; k++) m_array[_indC].sumc += m_array[i-k].change; m_array[_indC].power = _power(m_array[_indC].change-m_array[_indC].sumc/(double)m_period);
                  for(int k=0; k<m_period && i>=k; k++) m_array[_indC].sump += m_array[i-k].power; 
            #undef _power
         }            
         return (m_array[_indC].value);
      }      
};
cFilter iFilter;
//------------------------------------------------------------------