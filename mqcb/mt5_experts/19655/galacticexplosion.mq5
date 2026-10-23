//+------------------------------------------------------------------+
//|                                            GalacticExplosion.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "https://www.mql5.com/en/forum/189685/page30#comment_6214581"
#property version   "1.009"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//+------------------------------------------------------------------+
//| Enum hours                                                       |
//+------------------------------------------------------------------+
enum ENUM_HOURS
  {
   hour_00  =0,   // 00
   hour_01  =1,   // 01
   hour_02  =2,   // 02
   hour_03  =3,   // 03
   hour_04  =4,   // 04
   hour_05  =5,   // 05
   hour_06  =6,   // 06
   hour_07  =7,   // 07
   hour_08  =8,   // 08
   hour_09  =9,   // 09
   hour_10  =10,  // 10
   hour_11  =11,  // 11
   hour_12  =12,  // 12
   hour_13  =13,  // 13
   hour_14  =14,  // 14
   hour_15  =15,  // 15
   hour_16  =16,  // 16
   hour_17  =17,  // 17
   hour_18  =18,  // 18
   hour_19  =19,  // 19
   hour_20  =20,  // 20
   hour_21  =21,  // 21
   hour_22  =22,  // 22
   hour_23  =23,  // 23
  };
//--- input parameters
sinput string              _0_                  = "Trading";         // Trading parameters
input double               InpLots              = 0.1;               // Lots
input ENUM_HOURS           InpStartHour         = hour_08;           // Start hour
input ENUM_HOURS           InpEndHour           = hour_17;           // End hour
input double               InpMinProrif         = 1.0;               // Minimal profit
ushort                     InpIndentAfter8th    = 10;                // Indent after the 8th position (in pips)
ushort                     InpSkip3candlesMin   = 500;               // Indent for skip 3 candles (min) (in pips)
ushort                     InpSkip3candlesMax   = 999;               // Indent for skip 3 candles (max) (in pips)
ushort                     InpSkip6candlesMax   = 2000;              // Indent for skip 6 candles (max) (in pips)
ushort                     InpIndentAfter9th=10;                // Indent after the 8th position (in pips)
sinput string              _1_                  = "Moving Average";  // Moving Average parameters
input ENUM_TIMEFRAMES      InpMA_period         = PERIOD_CURRENT;    // MA: period 
input int                  InpMA_ma_period      = 200;               // MA: averaging period 
input int                  InpMA_ma_shift       = 0;                 // MA: horizontal shift 
input ENUM_MA_METHOD       InpMA_ma_method      = MODE_SMA;          // MA: smoothing type 
input ENUM_APPLIED_PRICE   InpMA_applied_price  = PRICE_CLOSE;       // MA: type of price
//---
ulong          m_magic=104806288;            // magic number
ulong          m_slippage=30;                // slippage

double         ExtIndentAfter8th=0.0;
double         ExtSkip3candlesMin=0.0;
double         ExtSkip3candlesMax=0.0;
double         ExtSkip6candlesMax=0.0;

bool           m_trading_time=false;         // trading time: false -> not trading, true -> traiding

int            handle_iMA;                   // variable for storing the handle of the iMA indicator 

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpStartHour>=InpEndHour)
     {
      Print("Error! Parameters incorrect: start time (hh:mi) ",StringFormat("%02d::00",InpStartHour)," >= ",
            "end time (hh:mi) ",StringFormat("%02d::00",InpEndHour));
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtIndentAfter8th=InpIndentAfter8th*m_adjusted_point;
   ExtSkip3candlesMin=InpSkip3candlesMin*m_adjusted_point;
   ExtSkip3candlesMax=InpSkip3candlesMax*m_adjusted_point;
   ExtSkip6candlesMax=InpSkip6candlesMax*m_adjusted_point;
//--- create handle of the indicator iMA
   handle_iMA=iMA(m_symbol.Name(),InpMA_period,InpMA_ma_period,InpMA_ma_shift,InpMA_ma_method,InpMA_applied_price);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0; // variable stores the opening time of the bar
   bool new_bar=false;
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      new_bar=false;
   else
     {
      PrevBars=time_0;
      new_bar=true;
     }
//---
   MqlDateTime str_time_curr;
   TimeToStruct(TimeCurrent(),str_time_curr);
   if(str_time_curr.hour>=InpStartHour && str_time_curr.hour<InpEndHour)
      m_trading_time=true;
   else
      m_trading_time=false;
//---
   int pos_total=0;
   double last_pos_price_open=0.0;
   double first_pos_price_open=0.0;
   double total_profit=0;
   CalculateAllPositions(pos_total,last_pos_price_open,first_pos_price_open,total_profit);
   if(total_profit>InpMinProrif)
      CloseAllPositions();

   if(m_trading_time && new_bar)
     {
      bool need_open_buy=false;
      bool need_open_sell=false;

      double MA=iMAGet(0);
      if(MA==0.0) // copying fails 
         return;
      if(!RefreshRates())
        {
         PrevBars=iTime(m_symbol.Name(),Period(),1);
         return;
        }
      if(m_symbol.Ask()<MA)
         need_open_buy=true;
      else if(m_symbol.Bid()>MA)
         need_open_sell=true;

      if(pos_total<=8)
        {
         if(need_open_buy)
            m_trade.Buy(InpLots);
         else if(need_open_sell)
            m_trade.Sell(InpLots);
        }
      else // positions greater than 8
        {
         double distance_to_LAST_pos_price_OPEN=(MathAbs(m_symbol.Ask()-last_pos_price_open)>
                                                 MathAbs(m_symbol.Bid()-last_pos_price_open))?
                                                 MathAbs(m_symbol.Ask()-last_pos_price_open):
                                                 MathAbs(m_symbol.Bid()-last_pos_price_open);
         double distance_to_FIRST_pos_price_OPEN=(MathAbs(m_symbol.Ask()-first_pos_price_open)>
                                                  MathAbs(m_symbol.Bid()-first_pos_price_open))?
                                                  MathAbs(m_symbol.Ask()-first_pos_price_open):
                                                  MathAbs(m_symbol.Bid()-first_pos_price_open);
         if(distance_to_LAST_pos_price_OPEN>ExtIndentAfter8th)
           {
            static int missed_bars_counter=0;
            if(distance_to_FIRST_pos_price_OPEN<ExtSkip3candlesMin)
              {
               missed_bars_counter=0;        // reset the counter "missed_bars_counter"
               if(need_open_buy)
                  m_trade.Buy(InpLots);
               else if(need_open_sell)
                  m_trade.Sell(InpLots);
              }
            else if(distance_to_FIRST_pos_price_OPEN>=ExtSkip3candlesMin && distance_to_LAST_pos_price_OPEN<=ExtSkip3candlesMax) // we will SKIP 3 candles
              {
               missed_bars_counter++;           // increase the counter "missed_bars_counter"
               if(missed_bars_counter>3)
                 {
                  if(need_open_buy)
                     m_trade.Buy(InpLots);
                  else if(need_open_sell)
                     m_trade.Sell(InpLots);
                  missed_bars_counter=0;        // reset the counter "missed_bars_counter"
                 }
              }
            else if(distance_to_FIRST_pos_price_OPEN>ExtSkip3candlesMax && distance_to_LAST_pos_price_OPEN<=ExtSkip6candlesMax) // we will SKIP 6 candles
              {
               missed_bars_counter++;           // increase the counter "missed_bars_counter"
               if(missed_bars_counter>6)
                 {
                  if(need_open_buy)
                     m_trade.Buy(InpLots);
                  else if(need_open_sell)
                     m_trade.Sell(InpLots);
                  missed_bars_counter=0;        // reset the counter "missed_bars_counter"
                 }
              }
           }
        }
     }
//---
   string text=(m_trading_time)?"true":"false";
   Comment("m_trading_time: ",text);
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
void CalculateAllPositions(int &pos_total,double &last_pos_price_open,double &first_pos_price_open,double &total_profit)
  {
   pos_total=0;
   datetime last_pos_time=D'1972.01.01 00:00'; // auxiliary variable
   datetime first_pos_time=D'2999.01.01 00:00'; // auxiliary variable
   total_profit=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            pos_total++;
            total_profit+=m_position.Commission()+m_position.Swap()+m_position.Profit();
            if(m_position.Time()>last_pos_time)
              {
               last_pos_time=m_position.Time();
               last_pos_price_open=m_position.PriceOpen();
              }
            if(m_position.Time()<first_pos_time)
              {
               first_pos_time=m_position.Time();
               first_pos_price_open=m_position.PriceOpen();
              }
           }
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
