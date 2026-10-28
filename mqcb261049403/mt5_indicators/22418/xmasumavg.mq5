//+------------------------------------------------------------------+
//|                                                    xMASumAvg.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Класс скользящих средних                                         |
//+------------------------------------------------------------------+
#include <Arrays\ArrayObj.mqh>
class CAvg : public CObject
  {
protected:
   ENUM_TIMEFRAMES      m_timeframe;
   string               m_symbol;
   int                  m_period;
   ENUM_MA_METHOD       m_method;
   ENUM_APPLIED_PRICE   m_price;
   int                  m_rates_total;
   double               m_prev_value;
   //---
   bool                 CheckPosition(const int rates_total,const int period,const int index)   const { return(period>=1 && index<=rates_total-period-1);   }
   double               Open(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index)         const;
   double               High(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index)         const;
   double               Low(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index)          const;
   double               Close(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index)        const;
   double               Median(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index)       const;
   double               Typical(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index)      const;
   double               Weighted(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index)     const;
public:
   void                 Timeframe(const ENUM_TIMEFRAMES timeframe)                                                   { this.m_timeframe=timeframe;          }
   void                 Method(const ENUM_MA_METHOD method)                                                          { this.m_method=method;                }
   void                 AppliedPrice(ENUM_APPLIED_PRICE price)                                                       { this.m_price=price;                  }
   void                 Symbol(const string symbol_name)                                                             { this.m_symbol=symbol_name;           }
   void                 Period(const int period)                                                                     { this.m_period=period;                }
   ENUM_TIMEFRAMES      Timeframe(void)                                                                        const { return this.m_timeframe;             }
   ENUM_MA_METHOD       Method(void)                                                                           const { return this.m_method;                }
   ENUM_APPLIED_PRICE   AppliedPrice(void)                                                                     const { return this.m_price;                 }
   string               Symbol(void)                                                                           const { return this.m_symbol;                }
   int                  Period(void)                                                                           const { return this.m_period;                }
   int                  RatesTotal(void)                                                                       const { return this.m_rates_total;           }
   double               AppliedPrice(const ENUM_APPLIED_PRICE applied_price,const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index) const;
   double               AppliedPrice(const int index)                                                          const;
   double               SMA(const int rates_total,const int period,const int index,const double &price[]);
   double               EMA(const int rates_total,const int period,const int index,const double &price[]);
   double               SMMA(const int rates_total,const int period,const int index,const double &price[]);
   double               LWMA(const int rates_total,const int period,const int index,const double &price[]);
   double               GetMA(const int rates_total,const ENUM_MA_METHOD method,const int period,const int index,const double &price[]);
   double               GetMA(const int rates_total,const int index,const double &price[]);
   string               MethodToString(const ENUM_MA_METHOD method)     const { return ::StringSubstr(::EnumToString(method),5);       }
   string               MethodToString(void)                            const { return ::StringSubstr(::EnumToString(this.m_method),5);}
   string               PriceToString(const ENUM_APPLIED_PRICE price)   const { return ::StringSubstr(::EnumToString(price),6);        }
   string               PriceToString(void)                             const { return ::StringSubstr(::EnumToString(this.m_price),6); }
                        CAvg(const int rates_total,const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int period);
                        CAvg(void) : m_prev_value(0){;}
                       ~CAvg(void){;}
  };
//+------------------------------------------------------------------+
//| CAvg Конструктор                                                 |
//+------------------------------------------------------------------+
CAvg::CAvg(const int rates_total,const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int period) : m_prev_value(0)
  {
   this.m_symbol=symbol_name;
   this.m_timeframe=timeframe;
   this.m_period=period;
   this.m_rates_total=rates_total;
  }
//+------------------------------------------------------------------+
//| CAvg возвращает значение MA                                      |
//+------------------------------------------------------------------+
double CAvg::GetMA(const int rates_total,const int index,const double &price[])
  {
   this.m_rates_total=rates_total;
   switch(this.m_method)
     {
      case MODE_EMA  :  return this.EMA(this.m_rates_total,this.m_period,index,price);
      case MODE_SMMA :  return this.SMMA(this.m_rates_total,this.m_period,index,price);
      case MODE_LWMA :  return this.LWMA(this.m_rates_total,this.m_period,index,price);
      //---MODE_SMA
      default        :  return this.SMA(this.m_rates_total,this.m_period,index,price);
     }
  }
//+------------------------------------------------------------------+
//| CAvg возвращает значение MA                                      |
//+------------------------------------------------------------------+
double CAvg::GetMA(const int rates_total,const ENUM_MA_METHOD method,const int period,const int index,const double &price[])
  {
   switch(method)
     {
      case MODE_EMA  :  return this.EMA(rates_total,period,index,price);
      case MODE_SMMA :  return this.SMMA(rates_total,period,index,price);
      case MODE_LWMA :  return this.LWMA(rates_total,period,index,price);
      //---MODE_SMA
      default        :  return this.SMA(rates_total,period,index,price);
     }
  }
//+------------------------------------------------------------------+
//| CAvg Simple Moving Average                                       |
//+------------------------------------------------------------------+
double CAvg::SMA(const int rates_total,const int period,const int index,const double &price[])
  {
//---
   double result=0.0;
//--- check position
   if(!this.CheckPosition(rates_total,period,index))
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
     result=result+price[index+i];
   result/=period;
//---
   return result;
  }
//+------------------------------------------------------------------+
//| CAvg Exponential Moving Average                                  |
//+------------------------------------------------------------------+
double CAvg::EMA(const int rates_total,const int period,const int index,const double &price[])
  {
//---
   //static double prev_value=0;
   double result=0.0;
//--- check position
   if(!this.CheckPosition(rates_total,period,index))
      return 0;
   double pr=2.0/(period+1.0);
//--- SMA for first data
   if(index==rates_total-period-1 || this.m_prev_value==0)
      this.m_prev_value=result=this.SMA(rates_total,period,index,price);
//--- EMA
   else
     {
      result=this.m_prev_value+pr*(price[index]-this.m_prev_value);
      //--- new bar
      if(index!=0)
         this.m_prev_value=result;
     }
//---
   return result;
  }
//+------------------------------------------------------------------+
//| CAvg Smoothed Moving Average                                     |
//+------------------------------------------------------------------+
double CAvg::SMMA(const int rates_total,const int period,const int index,const double &price[])
  {
//---
   //static double prev_value=0;
   double result=0.0;
//--- check position
   if(!this.CheckPosition(rates_total,period,index))
      return 0;
//--- SMA for first data
   if(index==rates_total-period-1 || this.m_prev_value==0)
      this.m_prev_value=result=this.SMA(rates_total,period,index,price);
//--- SMMA
   else
     {
      result=(this.m_prev_value*(period-1)+price[index])/period;
      //--- new bar
      if(index!=0)
         this.m_prev_value=result;
     }
//---
   return result;
  }
//+------------------------------------------------------------------+
//| CAvg Linear Weighted Moving Average                              |
//+------------------------------------------------------------------+
double CAvg::LWMA(const int rates_total,const int period,const int index,const double &price[])
  {
//---
   double result=0.0,count=0,total=0,k=0;
//--- check position
   if(!this.CheckPosition(rates_total,period,index))
      return 0;
//--- calculate value
   for(int j=index+period-1; j>=index; j--)
     {
      count++;
      k+=count;
      total+=price[j]*count;
     }
   result=total/k;
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| CAvg Возвращает цену по индексу                                  |
//+------------------------------------------------------------------+
double CAvg::AppliedPrice(const int index) const
  {
   switch(this.m_price)
     {
      case PRICE_OPEN      :  return this.Open(this.m_symbol,this.m_timeframe,index);
      case PRICE_HIGH      :  return this.High(this.m_symbol,this.m_timeframe,index);
      case PRICE_LOW       :  return this.Low(this.m_symbol,this.m_timeframe,index);
      case PRICE_CLOSE     :  return this.Close(this.m_symbol,this.m_timeframe,index);
      case PRICE_MEDIAN    :  return this.Median(this.m_symbol,this.m_timeframe,index);
      case PRICE_TYPICAL   :  return this.Typical(this.m_symbol,this.m_timeframe,index);
      //---PRICE_WEIGHTED
      default              :  return this.Weighted(this.m_symbol,this.m_timeframe,index);
     }
  }
//+------------------------------------------------------------------+
//| CAvg Возвращает цену по индексу                                  |
//+------------------------------------------------------------------+
double CAvg::AppliedPrice(const ENUM_APPLIED_PRICE applied_price,const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index) const
  {
   switch(applied_price)
     {
      case PRICE_OPEN      :  return this.Open(symbol_name,timeframe,index);
      case PRICE_HIGH      :  return this.High(symbol_name,timeframe,index);
      case PRICE_LOW       :  return this.Low(symbol_name,timeframe,index);
      case PRICE_CLOSE     :  return this.Close(symbol_name,timeframe,index);
      case PRICE_MEDIAN    :  return this.Median(symbol_name,timeframe,index);
      case PRICE_TYPICAL   :  return this.Typical(symbol_name,timeframe,index);
      //---PRICE_WEIGHTED
      default              :  return this.Weighted(symbol_name,timeframe,index);
     }
  }
//+------------------------------------------------------------------+
//| CAvg Возвращает цену Open по индексу                             |
//+------------------------------------------------------------------+
double CAvg::Open(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index) const
  {
   double array[];
   return(::CopyOpen(symbol_name,timeframe,index,1,array)==1 ? array[0] : 0);
  }  
//+------------------------------------------------------------------+
//| CAvg Возвращает цену High по индексу                             |
//+------------------------------------------------------------------+
double CAvg::High(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index) const
  {
   double array[];
   return(::CopyHigh(symbol_name,timeframe,index,1,array)==1 ? array[0] : 0);
  }  
//+------------------------------------------------------------------+
//| CAvg Возвращает цену Low по индексу                              |
//+------------------------------------------------------------------+
double CAvg::Low(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index) const
  {
   double array[];
   return(::CopyLow(symbol_name,timeframe,index,1,array)==1 ? array[0] : 0);
  }  
//+------------------------------------------------------------------+
//| CAvg Возвращает цену Close по индексу                            |
//+------------------------------------------------------------------+
double CAvg::Close(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index) const
  {
   double array[];
   return(::CopyClose(symbol_name,timeframe,index,1,array)==1 ? array[0] : 0);
  }  
//+------------------------------------------------------------------+
//| CAvg Возвращает медианную цену по индексу                        |
//+------------------------------------------------------------------+
double CAvg::Median(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index) const
  {
   double array[];
   double high=this.High(symbol_name,timeframe,index);
   double low=this.Low(symbol_name,timeframe,index);
   return(high>0 && low>0 ? (high+low)/2.0 : 0);
  }  
//+------------------------------------------------------------------+
//| CAvg Возвращает типичную цену по индексу                         |
//+------------------------------------------------------------------+
double CAvg::Typical(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index) const
  {
   double array[];
   double high=this.High(symbol_name,timeframe,index);
   double low=this.Low(symbol_name,timeframe,index);
   double close=this.Close(symbol_name,timeframe,index);
   return(high>0 && low>0 && close>0 ? (high+low+close)/3.0 : 0);
  }  
//+------------------------------------------------------------------+
//| CAvg Возвращает взвешенную цену по индексу                       |
//+------------------------------------------------------------------+
double CAvg::Weighted(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int index) const
  {
   double array[];
   double high=this.High(symbol_name,timeframe,index);
   double low=this.Low(symbol_name,timeframe,index);
   double close=this.Close(symbol_name,timeframe,index);
   return(high>0 && low>0 && close>0 ? (high+low+close+close)/4.0 : 0);
  }  
//+------------------------------------------------------------------+
//|                                                    xMASumAvg.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "X MA Sum Average indicator"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot XMA
#property indicator_label1  "XMA Average"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpPeriodBeg      =  20;            // Initial period
input uint                 InpPeriodEnd      =  100;           // End period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferXMA[];
double         BufferPrice[];
//--- global variables
int            cnt;
int            period_beg;
int            period_end;
CArrayObj      array_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_beg=int(InpPeriodBeg<1 ? 1 : InpPeriodBeg);
   period_end=int((int)InpPeriodEnd<=period_beg ? period_beg+1 : InpPeriodEnd);
   cnt=(period_end-period_beg+1);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferXMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferPrice,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"The sum of "+(string)cnt+" "+MethodToString(InpMethod)+" (Periods from "+(string)period_beg+" to "+(string)period_end+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits()+1);
//--- setting plot buffer parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_end);
   PlotIndexSetString(0,PLOT_LABEL,"Sum "+(string)cnt+" "+MethodToString(InpMethod));
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferXMA,true);
   ArraySetAsSeries(BufferPrice,true);
//---
   for(int i=0; i<cnt; i++)
     {
      int period_cnt=period_beg+i;
      CAvg* avg=new CAvg();
      if(avg==NULL)
         continue;
      avg.Period(period_cnt);
      avg.AppliedPrice(InpAppliedPrice);
      avg.Method(InpMethod);
      avg.Symbol(Symbol());
      avg.Timeframe(Period());
      array_ma.Add(avg);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferXMA,EMPTY_VALUE);
      ArrayInitialize(BufferPrice,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double sum=0;
      int total=array_ma.Total();
      for(int j=0;j<total;j++)
        {
         CAvg* avg=array_ma.At(j);
         if(avg==NULL)
            continue;
         BufferPrice[i]=avg.AppliedPrice(i);
         double ma=avg.GetMA(rates_total,i,BufferPrice);
         sum+=ma;
        }
      BufferXMA[i]=sum/cnt;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает наименование метода МА                                |
//+------------------------------------------------------------------+
string MethodToString(ENUM_MA_METHOD method)
  {
   return StringSubstr(EnumToString(method),5);
  }
//+------------------------------------------------------------------+




