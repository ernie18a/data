//+------------------------------------------------------------------+
//|                                               SymbolX_Candle.mq5 |
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
   int               m_handle_open;
   int               m_handle_high;
   int               m_handle_low;
   int               m_handle_close;
   int               m_index;
   bool              CreateHandleOpen(void);
   bool              CreateHandleHigh(void);
   bool              CreateHandleLow(void);
   bool              CreateHandleClose(void);
public:
   double            m_buffer_open[];
   double            m_buffer_high[];
   double            m_buffer_low[];
   double            m_buffer_close[];
   bool              CreateHandles(void);
   datetime          Time(const int shift)            const;
   double            Price(ENUM_APPLIED_PRICE price,const int shift) const;
   double            Coefficient(ENUM_APPLIED_PRICE applied_price,const int shift)  const;
   void              Index(const int index)                 { this.m_index=index;            }
   int               Index(void)                      const { return this.m_index;           }
   void              Weight(const double weight)            { this.m_weight=weight;          }
   double            Weight(void)                     const { return this.m_weight;          }
   int               HandleOpen(void)                 const { return this.m_handle_open;     }
   int               HandleHigh(void)                 const { return this.m_handle_high;     }
   int               HandleLow(void)                  const { return this.m_handle_low;      }
   int               HandleClose(void)                const { return this.m_handle_close;    }
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
//| CSymbol создание хэндлов индикаторов                             |
//+------------------------------------------------------------------+
bool CSymbol::CreateHandles(void)
  {
   return(this.CreateHandleOpen() && this.CreateHandleHigh() && this.CreateHandleLow() && this.CreateHandleClose());
  }
//+------------------------------------------------------------------+
//| CSymbol создание хэндла MA(Open)                                 |
//+------------------------------------------------------------------+
bool CSymbol::CreateHandleOpen(void)
  {
   this.m_handle_open=iMA(this.m_symbol,this.m_timeframe,1,0,MODE_SMA,PRICE_OPEN);
   return(this.m_handle_open==INVALID_HANDLE ? false : true);
  }
//+------------------------------------------------------------------+
//| CSymbol создание хэндла MA(High)                                 |
//+------------------------------------------------------------------+
bool CSymbol::CreateHandleHigh(void)
  {
   this.m_handle_high=iMA(this.m_symbol,this.m_timeframe,1,0,MODE_SMA,PRICE_HIGH);
   return(this.m_handle_high==INVALID_HANDLE ? false : true);
  }
//+------------------------------------------------------------------+
//| CSymbol создание хэндла MA(Low)                                  |
//+------------------------------------------------------------------+
bool CSymbol::CreateHandleLow(void)
  {
   this.m_handle_low=iMA(this.m_symbol,this.m_timeframe,1,0,MODE_SMA,PRICE_LOW);
   return(this.m_handle_low==INVALID_HANDLE ? false : true);
  }
//+------------------------------------------------------------------+
//| CSymbol создание хэндла MA(Close)                                |
//+------------------------------------------------------------------+
bool CSymbol::CreateHandleClose(void)
  {
   this.m_handle_close=iMA(this.m_symbol,this.m_timeframe,1,0,MODE_SMA,PRICE_CLOSE);
   return(this.m_handle_close==INVALID_HANDLE ? false : true);
  }
//+------------------------------------------------------------------+
//| CSymbol Возвращает время бара                                    |
//+------------------------------------------------------------------+
datetime CSymbol::Time(const int shift) const
  {
   datetime array[];
   return(::CopyTime(this.m_symbol,this.m_timeframe,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| CSymbol Возвращает цену бара                                     |
//+------------------------------------------------------------------+
double CSymbol::Price(ENUM_APPLIED_PRICE price,const int shift) const
  {
   return
     (
      this.Time(shift)==WRONG_VALUE ? 0 : 
      (
       price==PRICE_OPEN  ? this.m_buffer_open[shift]  :
       price==PRICE_HIGH  ? this.m_buffer_high[shift]  :
       price==PRICE_LOW   ? this.m_buffer_low[shift]   :
       price==PRICE_CLOSE ? this.m_buffer_close[shift] : 0
      )
     );
  }
//+------------------------------------------------------------------+
//| CSymbol расчёт коэффициента                                      |
//+------------------------------------------------------------------+
double CSymbol::Coefficient(ENUM_APPLIED_PRICE applied_price,const int shift) const
  {
   datetime t=this.Time(shift);
   if(t==0)
      return 0;
   int bar=this.BarShift(t);
   if(bar==WRONG_VALUE)
      return 0;
   double price=this.Price(applied_price,bar);
   if(price==0)
      return 0;
   return pow(price,this.Weight());
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Индикатор SymbolX_Candle                                         |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 29
#property indicator_plots   1
//--- plot SXC
#property indicator_label1  "Index Open;Index High;Index Low;Index Close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrMediumSeaGreen,clrOrange,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input string            InpInstrument  =  "EUR";      // Instrument
input ENUM_INPUT_YES_NO InpInverse     =  INPUT_NO;   // Invert the graph
//--- indicator buffers
double         BufferSXC_Open[];
double         BufferSXC_High[];
double         BufferSXC_Low[];
double         BufferSXC_Close[];
double         BufferColors[];
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
   int index=1;
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
      index+=4;
      instr.Index(index);
      instr.Weight(weights[i]);
      list_instruments.Add(instr);
     }
   if(list_instruments.Total()==0)
     {
      Print("Error. The CSymbol objects list is empty.");
      return INIT_FAILED;
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSXC_Open,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSXC_High,INDICATOR_DATA);
   SetIndexBuffer(2,BufferSXC_Low,INDICATOR_DATA);
   SetIndexBuffer(3,BufferSXC_Close,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColors,INDICATOR_COLOR_INDEX);
//---
   ArraySetAsSeries(BufferSXC_Open,true);
   ArraySetAsSeries(BufferSXC_High,true);
   ArraySetAsSeries(BufferSXC_Low,true);
   ArraySetAsSeries(BufferSXC_Close,true);
   ArraySetAsSeries(BufferColors,true);
//---
   total=list_instruments.Total();
   for(int i=0; i<total; i++)
     {
      CSymbol* instr=list_instruments.At(i);
      if(instr==NULL)
         continue;
      SetIndexBuffer(instr.Index(),instr.m_buffer_open,INDICATOR_CALCULATIONS);
      SetIndexBuffer(instr.Index()+1,instr.m_buffer_high,INDICATOR_CALCULATIONS);
      SetIndexBuffer(instr.Index()+2,instr.m_buffer_low,INDICATOR_CALCULATIONS);
      SetIndexBuffer(instr.Index()+3,instr.m_buffer_close,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(instr.m_buffer_open,true);
      ArraySetAsSeries(instr.m_buffer_high,true);
      ArraySetAsSeries(instr.m_buffer_low,true);
      ArraySetAsSeries(instr.m_buffer_close,true);
      if(!instr.CreateHandles())
        {
         Print("The ",instr.Symbol()," iMA(1) object was not created: Error ",GetLastError());
         return INIT_FAILED;
        }
      else
        instr.Time(0);
     }
     
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SymbolX Candles ("+instrument+" Index)");
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
      ArrayInitialize(BufferSXC_Open,EMPTY_VALUE);
      ArrayInitialize(BufferSXC_High,EMPTY_VALUE);
      ArrayInitialize(BufferSXC_Low,EMPTY_VALUE);
      ArrayInitialize(BufferSXC_Close,EMPTY_VALUE);
      total=list_instruments.Total();
      for(int i=0; i<total; i++)
        {
         CSymbol* instr=list_instruments.At(i);
         if(instr==NULL)
            continue;
         ArrayInitialize(instr.m_buffer_open,0);
         ArrayInitialize(instr.m_buffer_high,0);
         ArrayInitialize(instr.m_buffer_low,0);
         ArrayInitialize(instr.m_buffer_close,0);
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
      int copied=0,count=(limit>1 ? bars : 1);
      copied=CopyBuffer(instr.HandleOpen(),0,0,count,instr.m_buffer_open);
      if(copied<=0)
         return 0;
      copied=CopyBuffer(instr.HandleHigh(),0,0,count,instr.m_buffer_high);
      if(copied<=0)
         return 0;
      copied=CopyBuffer(instr.HandleLow(),0,0,count,instr.m_buffer_low);
      if(copied<=0)
         return 0;
      copied=CopyBuffer(instr.HandleClose(),0,0,count,instr.m_buffer_close);
      if(copied<=0)
         return 0;
      instr.Time(0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double xO=50.14348112;
      double xH=50.14348112;
      double xL=50.14348112;
      double xC=50.14348112;
      double coeff=0,price=0;
      int count=0;
      total=list_instruments.Total();
      for(int n=0; n<total; n++)
        {
         CSymbol* instr=list_instruments.At(n);
         if(instr==NULL)
            continue;
         coeff=instr.Coefficient(PRICE_OPEN,i);
         xO=(coeff!=0 ? xO*coeff : xO);
         coeff=instr.Coefficient(PRICE_HIGH,i);
         xH=(coeff!=0 ? xH*coeff : xH);
         coeff=instr.Coefficient(PRICE_LOW,i);
         xL=(coeff!=0 ? xL*coeff : xL);
         coeff=instr.Coefficient(PRICE_CLOSE,i);
         xC=(coeff!=0 ? xC*coeff : xC);
        }
      if(InpInverse)
        {
         xO=1.0/xO;
         xH=1.0/xH;
         xL=1.0/xL;
         xC=1.0/xC;
        }
      int bar=BarShift(symbol,time[i]);
      if(bar!=WRONG_VALUE)
        {
         price=Close(symbol,bar);
         BufferSXC_Open[i]=xO*(price!=0 ? pow(price,symbol_pow) : 1.0);
         BufferSXC_High[i]=xH*(price!=0 ? pow(price,symbol_pow) : 1.0);
         BufferSXC_Low[i]=xL*(price!=0 ? pow(price,symbol_pow) : 1.0);
         BufferSXC_Close[i]=xC*(price!=0 ? pow(price,symbol_pow) : 1.0);
         BufferColors[i]=(BufferSXC_Close[i]>BufferSXC_Open[i] ? 0 : BufferSXC_Close[i]<BufferSXC_Open[i] ? 1 : 2);
        }
      else
        {
         BufferSXC_Open[i]=BufferSXC_High[i]=BufferSXC_Low[i]=BufferSXC_Close[i]=0;
         BufferColors[i]=2;
        }
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
   return Bars(symbol_name,PERIOD_CURRENT,time+1,UINT_MAX);
  }
//+------------------------------------------------------------------+
//| Возвращает цену Close по номеру бара                             |
//+------------------------------------------------------------------+
double Close(const string symbol_name,const int shift)
  {
   double array[];
   return(CopyClose(symbol_name,PERIOD_CURRENT,shift,1,array)==1 ? array[0] : 0);
  }  
//+------------------------------------------------------------------+
