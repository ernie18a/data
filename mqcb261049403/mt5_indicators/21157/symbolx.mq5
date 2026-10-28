//+------------------------------------------------------------------+
//|                                                      SymbolX.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayString.mqh>
//+------------------------------------------------------------------+
//| Класс данных символа                                             |
//+------------------------------------------------------------------+
class CSymbol : public CObject
  {
private:
   ENUM_TIMEFRAMES   m_timeframe;
   string            m_symbol;
   double            m_weight;
   int               m_handle;
   int               m_index;
public:
   double            m_buffer[];
   bool              CreateHandle(void);
   datetime          Time(const int shift)            const;
   double            Price(const int shift)           const;
   double            Coefficient(const int shift)     const;
   void              Index(const int index)                 { this.m_index=index;            }
   int               Index(void)                      const { return this.m_index;           }
   void              Weight(const double weight)            { this.m_weight=weight;          }
   double            Weight(void)                     const { return this.m_weight;          }
   int               Handle(void)                     const { return this.m_handle;          }
   string            Symbol(void)                     const { return this.m_symbol;          }
   int               Bars(void)                       const { return(::Bars(this.m_symbol,this.m_timeframe));                 }
   int               BarShift(const datetime time)    const { return(::Bars(this.m_symbol,this.m_timeframe,time+1,UINT_MAX)); }
                     CSymbol(const string symbol_name);
                    ~CSymbol(void){;}
  };
//+------------------------------------------------------------------+
//| CSymbol конструктор                                              |
//+------------------------------------------------------------------+
CSymbol::CSymbol(const string symbol_name) : m_timeframe(PERIOD_CURRENT)
  {
   this.m_symbol=symbol_name;
  }
//+------------------------------------------------------------------+
//| CSymbol создание хэндла                                          |
//+------------------------------------------------------------------+
bool CSymbol::CreateHandle(void)
  {
   this.m_handle=iMA(this.m_symbol,this.m_timeframe,1,0,MODE_SMA,PRICE_CLOSE);
   return(this.m_handle==INVALID_HANDLE ? false : true);
  }
//+------------------------------------------------------------------+
//| CSymbol Возвращает время бара                                    |
//+------------------------------------------------------------------+
datetime CSymbol::Time(const int shift) const
  {
   datetime array[];
   return
     (
      ::TerminalInfoInteger(TERMINAL_BUILD)<1847 ? (::CopyTime(this.m_symbol,this.m_timeframe,shift,1,array)==1 ? array[0] : 0) :
      ::iTime(this.m_symbol,this.m_timeframe,shift)
     );
  }
//+------------------------------------------------------------------+
//| CSymbol Возвращает цену бара                                     |
//+------------------------------------------------------------------+
double CSymbol::Price(const int shift) const
  {
   return(this.Time(shift)==WRONG_VALUE ? 0 : this.m_buffer[shift]);
  }
//+------------------------------------------------------------------+
//| CSymbol расчёт коэффициента                                      |
//+------------------------------------------------------------------+
double CSymbol::Coefficient(const int shift) const
  {
   datetime t=this.Time(shift);
   if(t==0)
      return 0;
   int bar=this.BarShift(t);
   if(bar==WRONG_VALUE)
      return 0;
   double price=this.Price(bar);
   if(price==0)
      return 0;
   return pow(price,this.Weight());
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Индикатор SymbolX                                                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   1
//--- plot SX
#property indicator_label1  "XIndex"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRoyalBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input string            InpInstrument  =  "EUR";      // Instrument
//--- indicator buffers
double         BufferSX[];
//--- global variables
string         instrument;
string         symbol;
double         symbol_pow;
CArrayObj      list_instruments;
CArrayString   list_symbols;
//---
string symbols[]={"EURUSD","USDJPY","GBPUSD","USDCAD","USDSEK","USDCHF"};
double weights[]={-0.576,0.136,-0.119,0.091,0.042,0.036};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- enable timer
   EventSetTimer(90);
//--- set global variables
   instrument=InpInstrument;
   StringToUpper(instrument);
   StringTrimLeft(instrument);
   StringTrimRight(instrument);
   SetSymbol();
   //---
   list_instruments.Sort();
   list_instruments.Clear();
   list_symbols.Sort();
   list_symbols.Clear();
   int n=0, total=ArraySize(symbols);
   for(int i=0; i<total; i++)
      if(!SearchSymbol(symbols[i]))
      //if(list_symbols.Search(symbols[i])==WRONG_VALUE) // Баг? Список сортирован, но поиск всегда возвращает не -1
         list_symbols.Add(symbols[i]);
   //---
   total=list_symbols.Total();
   int index=0;
   for(int i=0; i<total; i++)
     {
      string symb=list_symbols.At(i);
      if(!SymbolCheck(symb))
         continue;
      ResetLastError();
      CSymbol* instr=new CSymbol(symb);
      if(instr==NULL)
        {
         Print("Error. The CSymbol object for ",symb," was not created: Error ",GetLastError());
         return INIT_FAILED;
        }
      index++;
      instr.Index(index);
      instr.Weight(weights[index-1]);
      list_instruments.Add(instr);
     }
   if(list_instruments.Total()==0)
     {
      Print("Error. The CSymbol objects list is empty.");
      return INIT_FAILED;
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSX,INDICATOR_DATA);
   ArraySetAsSeries(BufferSX,true);
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,"Index ("+instrument+")");
//---
   total=list_instruments.Total();
   for(int i=0; i<total; i++)
     {
      CSymbol* instr=list_instruments.At(i);
      if(instr==NULL)
         continue;
      SetIndexBuffer(instr.Index(),instr.m_buffer,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(instr.m_buffer,true);
      if(!instr.CreateHandle())
        {
         Print("The ",instr.Symbol()," iMA(1) object was not created: Error ",GetLastError());
         return INIT_FAILED;
        }
      else
        instr.Time(0);
     }
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SymbolX ("+instrument+" Index)");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   int total=list_instruments.Total();
   for(int i=0; i<total; i++)
     {
      CSymbol* instr=list_instruments.At(i);
      if(instr==NULL)
         continue;
      instr.Time(0);
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
      ArrayInitialize(BufferSX,EMPTY_VALUE);
      total=list_instruments.Total();
      for(int i=0; i<total; i++)
        {
         CSymbol* instr=list_instruments.At(i);
         if(instr==NULL)
            continue;
         ArrayInitialize(instr.m_buffer,0);
        }
     }
//--- Подготовка данных
   total=list_instruments.Total();
   for(int i=0; i<total; i++)
     {
      CSymbol* instr=list_instruments.At(i);
      if(instr==NULL)
         continue;
      string symb=instr.Symbol();
      int bars=(symb==Symbol() ? rates_total : instr.Bars());
      int count=(limit>1 ? bars : 1);
      int copied=CopyBuffer(instr.Handle(),0,0,count,instr.m_buffer);
      if(copied<=0)
         return 0;
      instr.Time(0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double x=50.14348112;
      int count=0;
      total=list_instruments.Total();
      for(int n=0; n<total; n++)
        {
         CSymbol* instr=list_instruments.At(n);
         if(instr==NULL)
            continue;
         double coeff=instr.Coefficient(i);
         double v=(coeff!=0 ? coeff : 1.0);
         x*=v;
        }
      int bar=BarShift(symbol,time[i]);
      double price=Close(symbol,bar);
      BufferSX[i]=x*(price!=0 ? pow(price,symbol_pow) : 1.0);
      }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Проверка символа                                                 |
//+------------------------------------------------------------------+
bool SymbolCheck(const string symbol_name,bool print_err=false)
  {
   long select=0;
   ResetLastError();
   if(!SymbolInfoInteger(symbol_name,SYMBOL_SELECT,select))
     {
      int err=GetLastError();
      if(print_err) Print("Error: ",err," Symbol ",symbol_name," does not exist");
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
//| Установка рабочего символа                                       |
//+------------------------------------------------------------------+
void SetSymbol()
  {
   symbol="";
   string s;
   if(instrument=="USD")
     {
      symbol="USD";
      symbol_pow=0;
      return;
     }
   s=instrument+"USD";
   if(SymbolCheck(s))
     {
      symbol=s;
      symbol_pow=1;
      return;
     }
   s="USD"+instrument;
   if(SymbolCheck(s))
     {
      symbol=s;
      symbol_pow=-1;
      return;
     }
   return;
  }
//+------------------------------------------------------------------+
//| Возвращает номер бара по времени                                 |
//+------------------------------------------------------------------+
int BarShift(const string symbol_name,const datetime time)
  {
   return
     (
      TerminalInfoInteger(TERMINAL_BUILD)<1847 ? Bars(symbol_name,PERIOD_CURRENT,time+1,UINT_MAX) :
      iBarShift(symbol_name,PERIOD_CURRENT,time)
     );
  }
//+------------------------------------------------------------------+
//| Возвращает цену Close по номеру бара                             |
//+------------------------------------------------------------------+
double Close(const string symbol_name,const int shift)
  {
   double array[];
   return
     (
      TerminalInfoInteger(TERMINAL_BUILD)<1847 ? (CopyClose(symbol_name,PERIOD_CURRENT,shift,1,array)==1 ? array[0] : 0) :
      iClose(symbol_name,PERIOD_CURRENT,shift)
     );
  }  
//+------------------------------------------------------------------+
