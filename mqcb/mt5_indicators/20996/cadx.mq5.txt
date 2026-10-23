//+------------------------------------------------------------------+
//|                                                         CADX.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayString.mqh>
//+------------------------------------------------------------------+
//| Класс индикатора ADX                                             |
//+------------------------------------------------------------------+
class CAdx : public CObject
  {
private:
   ENUM_TIMEFRAMES   m_timeframe;
   string            m_symbol;
   int               m_ma_period;
   int               m_handle;
   int               m_index;
public:
   double            m_buffer[];
   bool              CreateHandle(void);
   datetime          Time(const int shift) const;
   void              Index(const int index)                 { this.m_index=index;            }
   int               Index(void)                      const { return this.m_index;           }
   int               Handle(void)                     const { return this.m_handle;          }
   string            Symbol(void)                     const { return this.m_symbol;          }
   double            GetDataBuffer(const int shift)   const { return this.m_buffer[shift];   }
   int               Bars(void)                       const { return(::Bars(this.m_symbol,this.m_timeframe));                 }
   int               BarShift(const datetime time)    const { return(::Bars(this.m_symbol,this.m_timeframe,time+1,UINT_MAX)); }
                     CAdx(const string symbol_name,const int period);
                    ~CAdx(void){;}
  };
//+------------------------------------------------------------------+
//| CAdx конструктор                                                 |
//+------------------------------------------------------------------+
CAdx::CAdx(const string symbol_name,const int period) : m_timeframe(PERIOD_CURRENT)
  {
   this.m_symbol=symbol_name;
   this.m_ma_period=period;
  }
//+------------------------------------------------------------------+
//| CAdx создание хэндла                                             |
//+------------------------------------------------------------------+
bool CAdx::CreateHandle(void)
  {
   this.m_handle=iADX(this.m_symbol,this.m_timeframe,this.m_ma_period);
   return(this.m_handle==INVALID_HANDLE ? false : true);
  }
//+------------------------------------------------------------------+
//| CAdx Возвращает время бара                                       |
//+------------------------------------------------------------------+
datetime CAdx::Time(const int shift) const
  {
   datetime array[];
   return(::CopyTime(this.m_symbol,this.m_timeframe,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Индикатор CADX                                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Comparative ADX indicator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot CADX
#property indicator_label1  "CADX"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod   =  14;   // Period
input double   InpLevel    =  1.0;  // Level value
//--- indicator buffers
double         BufferCADX[];
//--- global variables
int            period_adx;
string         symbols[]={"EURUSD","GBPUSD","AUDUSD","USDJPY","USDCAD"};
CArrayString   list_symbols;
CArrayObj      list_adx;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- enable timer
   EventSetTimer(90);
//--- set global variables
   period_adx=int(InpPeriod<1 ? 1 : InpPeriod);
   list_adx.Clear();
   list_adx.Sort();
   list_symbols.Clear();
   list_symbols.Sort();
   int total=ArraySize(symbols);
   for(int i=0; i<total; i++)
      if(!SearchSymbol(symbols[i]))
      //if(list_symbols.Search(symbols[i])==WRONG_VALUE) // Баг? Список сортирован, но поиск всегда возвращает не -1
         list_symbols.Add(symbols[i]);
   if(!SearchSymbol(Symbol()))
   //if(list_symbols.Search(Symbol())==WRONG_VALUE)      // Баг? Список сортирован, но поиск всегда возвращает не -1
      list_symbols.Add(Symbol());
   //---
   total=list_symbols.Total();
   int index=0;
   for(int i=0; i<total; i++)
     {
      string symbol=list_symbols.At(i);
      if(!SymbolCheck(symbol))
         continue;
      ResetLastError();
      CAdx* adx=new CAdx(symbol,period_adx);
      if(adx==NULL)
        {
         Print("Error. The iADX object for ",symbol," was not created: Error ",GetLastError());
         return INIT_FAILED;
        }
      index++;
      adx.Index(index);
      list_adx.Add(adx);
     }
   if(list_adx.Total()==0)
     {
      Print("Error. The iADX object list is empty.");
      return INIT_FAILED;
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCADX,INDICATOR_DATA);
   ArraySetAsSeries(BufferCADX,true);
   //---
   total=list_adx.Total();
   for(int i=0; i<total; i++)
     {
      CAdx* adx=list_adx.At(i);
      if(adx==NULL)
         continue;
      SetIndexBuffer(adx.Index(),adx.m_buffer,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(adx.m_buffer,true);
      if(!adx.CreateHandle())
        {
         Print("The ",adx.Symbol()," iADX(",(string)period_adx,") object was not created: Error ",GetLastError());
         return INIT_FAILED;
        }
      else
        adx.Time(0);
     }
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Comparative ADX ("+(string)period_adx+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,InpLevel);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   int total=list_adx.Total();
   for(int i=0; i<total; i++)
     {
      CAdx* adx=list_adx.At(i);
      if(adx==NULL)
         continue;
      adx.Time(0);
     }
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int total=0, limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferCADX,EMPTY_VALUE);
      total=list_adx.Total();
      for(int i=0; i<total; i++)
        {
         CAdx* adx=list_adx.At(i);
         if(adx==NULL)
            continue;
         ArrayInitialize(adx.m_buffer,0);
        }
     }
//--- Подготовка данных
   total=list_adx.Total();
   for(int i=0; i<total; i++)
     {
      CAdx* adx=list_adx.At(i);
      if(adx==NULL)
         continue;
      string symbol=adx.Symbol();
      int bars=(symbol==Symbol() ? rates_total : adx.Bars());
      int count=(limit>1 ? bars : 1);
      int copied=CopyBuffer(adx.Handle(),MAIN_LINE,0,count,adx.m_buffer);
      if(copied<=0)
         return 0;
      adx.Time(0);
     }
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double ADX=0,SumADX=0;
      int count=0;
      total=list_adx.Total();
      for(int n=0; n<total; n++)
        {
         CAdx* adx=list_adx.At(n);
         if(adx==NULL)
            continue;
         if(adx.Symbol()==Symbol())
           {
            ADX=adx.m_buffer[i];
            continue;
           }
         if(adx.Time(i)!=0)
           {
            SumADX+=adx.m_buffer[i];
            count++;
           }
        }
      if(count>0)
        {
         SumADX/=count;
         BufferCADX[i]=ADX/(SumADX!=0 ? SumADX : 1.0);
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Проверка символа                                                 |
//+------------------------------------------------------------------+
bool SymbolCheck(const string symbol_name)
  {
   long select=0;
   ResetLastError();
   if(!SymbolInfoInteger(symbol_name,SYMBOL_SELECT,select))
     {
      int err=GetLastError();
      Print("Error: ",err," Symbol ",symbol_name," does not exist");
      return false;
     }
   else
     {
      if(select) return true;
      ResetLastError();
      if(!SymbolSelect(symbol_name,true))
        {
         int err=GetLastError();
         Print("Error selected ",symbol_name,": ",err);
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Поиск символа в списке                                           |
//+------------------------------------------------------------------+
bool SearchSymbol(const string symbol_name)
  {
   int total=list_symbols.Total();
   for(int i=0;i<total;i++)
      if(list_symbols.At(i)==symbol_name)
         return true;
   return false;
  }
//+------------------------------------------------------------------+
