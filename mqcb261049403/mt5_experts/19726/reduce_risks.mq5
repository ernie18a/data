//+------------------------------------------------------------------+
//|                        Reduce_risks(barabashkakvn's edition).mq5 |
//|                            Copyright 2017, Alexander Masterskikh |
//|                      https://www.mql5.com/ru/users/a.masterskikh |
//+------------------------------------------------------------------+
#property copyright   "2017, Alexander Masterskikh"
#property link        "https://www.mql5.com/ru/users/a.masterskikh"
#property version   "1.014"
//---
#define MODE_LOW 1
#define MODE_HIGH 2
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
#include <Trade\TerminalInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CMoneyFixedMargin m_money;
CTerminalInfo  m_terminal;                   // terminal object
//--- input parameters
input ushort   InpStopLoss          = 30;    // Stop Loss (in pips)
input ushort   InpTakeProfit        = 60;    // Take Profit (in pips)                             
input double   InpDepoFirst         = 10000; // Initial amount of the deposit of the client
input double   InpPercentRiskDepo   = 5;     // Risk on a deposit (in % to the initial amount of the deposit of the client)
//---
ulong          m_slippage=10;                // slippage

double         ExtStopLoss=0;
double         ExtTakeProfit=0;

int            handle_iMA_M1_period5;        // variable for storing the handle of the iMA indicator 
int            handle_iMA_M1_period8;        // variable for storing the handle of the iMA indicator 
int            handle_iMA_M1_period13;       // variable for storing the handle of the iMA indicator 
int            handle_iMA_M1_period60;       // variable for storing the handle of the iMA indicator 
int            handle_iMA_M15_period4;       // variable for storing the handle of the iMA indicator 
int            handle_iMA_M15_period5;       // variable for storing the handle of the iMA indicator 
int            handle_iMA_M15_period8;       // variable for storing the handle of the iMA indicator 
int            handle_iMA_H1_period24;       // variable for storing the handle of the iMA indicator 
//---
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Monitoring expert installation on the necessary timeframe
   if(Period()!=PERIOD_M1)
     {
      Print("The expert is not installed correctly. Install the expert on the timeframe:",EnumToString(PERIOD_M1));
      return(INIT_FAILED);
     }
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();
//--- Controlling the installation of an expert on charts of necessary financial instruments
   if(m_symbol.Name()!="EURUSD" && m_symbol.Name()!="USDCHF" && m_symbol.Name()!="USDJPY")
     {
      Print("The expert is not installed correctly. Unauthorized financial instrument");
      return(INIT_FAILED);
     }
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

   ExtStopLoss=InpStopLoss*m_adjusted_point;
   ExtTakeProfit=InpTakeProfit*m_adjusted_point;
//---
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(InpPercentRiskDepo);
//--- create handle of the indicator iMA
   handle_iMA_M1_period5=iMA(m_symbol.Name(),PERIOD_M1,5,0,MODE_SMA,PRICE_TYPICAL);
//--- if the handle is not created 
   if(handle_iMA_M1_period5==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_M1_period8=iMA(m_symbol.Name(),PERIOD_M1,8,0,MODE_SMA,PRICE_TYPICAL);
//--- if the handle is not created 
   if(handle_iMA_M1_period8==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_M1_period13=iMA(m_symbol.Name(),PERIOD_M1,13,0,MODE_SMA,PRICE_TYPICAL);
//--- if the handle is not created 
   if(handle_iMA_M1_period13==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_M1_period60=iMA(m_symbol.Name(),PERIOD_M1,60,0,MODE_SMA,PRICE_TYPICAL);
//--- if the handle is not created 
   if(handle_iMA_M1_period60==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_M15_period4=iMA(m_symbol.Name(),PERIOD_M15,4,0,MODE_SMA,PRICE_TYPICAL);
//--- if the handle is not created 
   if(handle_iMA_M15_period4==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_M15_period5=iMA(m_symbol.Name(),PERIOD_M15,5,0,MODE_SMA,PRICE_TYPICAL);
//--- if the handle is not created 
   if(handle_iMA_M15_period5==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_M15_period8=iMA(m_symbol.Name(),PERIOD_M15,8,0,MODE_SMA,PRICE_TYPICAL);
//--- if the handle is not created 
   if(handle_iMA_M15_period8==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_H1_period24=iMA(m_symbol.Name(),PERIOD_H1,24,0,MODE_SMA,PRICE_TYPICAL);
//--- if the handle is not created 
   if(handle_iMA_H1_period24==INVALID_HANDLE)
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
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
//--- variables
   double sl_buy=0.0,tp_buy=0.0,sl_sell=0.0,tp_sell=0.0;

   datetime Time_cur=0;
   int shift_buy=0,shift_sell=0;
   double Max_pos,Min_pos;

//--- Monitoring of technical parameters (states and permissions) on the broker's side and the client terminal side
   bool tester=(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_VISUAL_MODE))?true:false;
   if(tester) // check: testing or trade (testing -> true, trade -> false)
     {
      static int counter_is_connected=0;
      if(!m_terminal.IsConnected()) // gets the information about connection to trade server
        {
         counter_is_connected++;
         string text="The terminal isn't connected to the server. Counter: "+IntegerToString(counter_is_connected);
         Print(text);
         return;
        }
      else
         counter_is_connected=0;

      static int counter_is_trade_allowed=0;
      if(!m_terminal.IsTradeAllowed()) // gets the information about permission to trade
        {
         counter_is_trade_allowed++;
         string text="Check if automated trading is allowed in the terminal settings! Counter: "+IntegerToString(counter_is_trade_allowed);
         Print(text);
         return;
        }
      else
         counter_is_trade_allowed=0;

      static int counter_trade_expert=0;
      if(!m_account.TradeExpert()) // gets the flag of automated trade allowance
        {
         counter_trade_expert++;
         string text="Automated trading is forbidden for the account. Counter: "+IntegerToString(counter_trade_expert);
         Print(text);
         return;
        }
      else
         counter_trade_expert=0;

      static int counter_mql_trade_allowewd=0;
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         counter_trade_expert++;
         string text="Automated trading is forbidden in the program settings for "+__FILE__+". Counter: "+IntegerToString(counter_mql_trade_allowewd);
         Print(text);
         return;
        }
      else
         counter_mql_trade_allowewd=0;

      if(IsStopped()==true)
        {
         string text="A mql5 program has been commanded to complete its operation";
         Print(text);
         ExpertRemove();
        }
     }
//--- Control of the availability of a sufficient number of quotations in the terminal for the used financial instrument
   if(Bars(m_symbol.Name(),Period())<100) //
     {
      Print("the insufficient number of bars on the current schedule");
      return;
     }
//--- values of variables
   static MqlRates rates_M1[]; // 
   if(time_0!=PrevBars)
     {
      ZeroMemory(rates_M1);
      ArraySetAsSeries(rates_M1,true);
      int copied=CopyRates(m_symbol.Name(),PERIOD_M1,0,4,rates_M1);
      if(copied!=4)
        {
         PrevBars=iTime(1);
         return;
        }
     }
   static MqlRates rates_M15[]; //
   if(time_0!=PrevBars)
     {
      ZeroMemory(rates_M15);
      ArraySetAsSeries(rates_M15,true);
      int copied=CopyRates(m_symbol.Name(),PERIOD_M15,0,4,rates_M15);
      if(copied!=4)
        {
         PrevBars=iTime(1);
         return;
        }
     }
//--- MODE_SMA,PRICE_TYPICAL
   double arr_MA_M1_period5[];
   ArraySetAsSeries(arr_MA_M1_period5,true);
   if(!iMAGet(handle_iMA_M1_period5,arr_MA_M1_period5,3)) // figure "3" is quantity, starting number "0"
      return;

   double arr_MA_M1_period8[];
   ArraySetAsSeries(arr_MA_M1_period8,true);
   if(!iMAGet(handle_iMA_M1_period8,arr_MA_M1_period8,4)) // figure "4" is quantity, starting number "0"
      return;

   double MA_M1_period13_0=iMAGet(handle_iMA_M1_period13,0);       // figure "0" is number of the index
   if(MA_M1_period13_0==0.0)
      return;

   double arr_MA_M1_period60[];
   ArraySetAsSeries(arr_MA_M1_period60,true);
   if(!iMAGet(handle_iMA_M1_period60,arr_MA_M1_period60,3)) // figure "3" is quantity, starting number "0"
      return;

   double arr_MA_M15_period4[];
   ArraySetAsSeries(arr_MA_M15_period4,true);
   if(!iMAGet(handle_iMA_M15_period4,arr_MA_M15_period4,3)) // figure "3" is quantity, starting number "0"
      return;

   static double MA_M15_period5_1=0.0;
   if(time_0!=PrevBars)
     {
      MA_M15_period5_1=iMAGet(handle_iMA_M15_period5,1);       // figure "1" is number of the index
      if(MA_M15_period5_1==0.0)
        {
         PrevBars=iTime(1);
         return;
        }
     }

   static double MA_M15_period8_1=0.0;
   if(time_0!=PrevBars)
     {
      MA_M15_period8_1=iMAGet(handle_iMA_M15_period8,1);       // figure "1" is number of the index
      if(MA_M15_period8_1==0.0)
        {
         PrevBars=iTime(1);
         return;
        }
     }

   double MA_H1_period24_0=iMAGet(handle_iMA_H1_period24,0);       // figure "0" is number of the index
   if(MA_H1_period24_0==0.0)
      return;

   if(!RefreshRates())
      return;

   int kol=CalculateAllPositions();
   Time_cur=TimeCurrent();
   if(kol==0)
     {
      //--- control of the financial parameters connected with a risk limit in general of a deposit of the client
      //--- if the risk limit in general of a deposit is earlier exceeded
      static int counter_risk_reached=0;
      if(m_account.Balance()<=NormalizeDouble((InpDepoFirst*((100.0-InpPercentRiskDepo)/100.0)),2))
        {
         if(counter_risk_reached<15)
           {
            Print("The entrance is forbidden. The limit of risk ",
                  DoubleToString(InpPercentRiskDepo,2),"% of a deposit ",
                  DoubleToString(InpPercentRiskDepo,2)," is reached");
            counter_risk_reached++;
           }
         return;
        }
      else
         counter_risk_reached=0;
      //--- an entrance algorithm in in the market - purchase (buy)
      //--- we minimize the risks connected with presence of considerable size of volatility by the time of an entrance to the market
      //--- we model lack of considerable volatility in the next history:

      //--- amplitude of candles of the younger scale (M1)
      bool amplitude_candles_M1=
                                rates_M1[1].high-rates_M1[1].low<=20*m_adjusted_point &&
                                rates_M1[2].high-rates_M1[2].low<=20*m_adjusted_point &&
                                rates_M1[3].high-rates_M1[3].low<=20*m_adjusted_point;
      //--- amplitude of candles of the senior scale (M15)
      bool amplitude_candles_M15=
                                 rates_M15[1].high-rates_M15[1].low<=30*m_adjusted_point &&
                                 rates_M15[2].high-rates_M15[2].low<=30*m_adjusted_point &&
                                 rates_M15[3].high-rates_M15[3].low<=30*m_adjusted_point;
      //--- amplitude of the channel of candles of the senior scale (M15)
      bool amplitude_channel_M15=
                                 rates_M15[1].high-rates_M15[3].low<=30*m_adjusted_point;
      //--- activity on the previous bar concerning the 2nd bar in the history of quotations
      bool activity_previous_bar_M1=
                                    rates_M1[1].high-rates_M1[1].low>=1.1*(rates_M1[2].high-rates_M1[2].low) && 
                                    rates_M1[1].high-rates_M1[1].low<3.0*(rates_M1[2].high-rates_M1[2].low);
      //--- we minimize the risks connected with presence of levels of resistance at an entrance to the market
      //--- local levels of resistance are overcome by the current price
      bool local_resistance_overcome=
                                     m_symbol.Bid()>rates_M1[1].high &&
                                     m_symbol.Bid()>rates_M15[1].high;
      //--- minimize the risks associated with entering the overbought zone at the entrance to the market
      //--- binding to the beginning of a wave to reduce probability of an entrance in a overbought zone:
      //---    the beginning of a wave - not further three bars in the history of data (M1)
      bool beginning_wave_M1=
                             (arr_MA_M1_period8[1]>rates_M1[1].low && arr_MA_M1_period8[1]<rates_M1[1].high) ||
                             (arr_MA_M1_period8[2]>rates_M1[2].low && arr_MA_M1_period8[2]<rates_M1[2].high) ||
                             (arr_MA_M1_period8[3]>rates_M1[3].low && arr_MA_M1_period8[3]<rates_M1[3].high);
      //---    the beginning of a wave - on the previous bar of the senior timeframe (M15)
      bool beginning_wave_M15=
                              MA_M15_period5_1>rates_M15[1].low && MA_M15_period5_1<rates_M15[1].high;
      //--- we minimize the risks connected with lack of the expressed trend at an entrance to the market
      //--- we model the direction of candles on a younger timeframe:
      //---    the ascending direction of a candle on the 2nd bar in the history of data (M1)
      bool ascending_direction_2nd_bar_M1=
                                          rates_M1[2].close>rates_M1[2].open;
      //---    the ascending direction of the previous candle (M1)
      bool ascending_direction_previous_bar_M1=
                                               rates_M1[1].close>rates_M1[1].open;
      //--- we model the direction of moving averages on a younger timeframe:                                        
      //---    the ascending MA: we use moving averages with the period of calculation 5 and 60 (M1)   
      bool ascending_MA_5and60=
                               arr_MA_M1_period5[0]>arr_MA_M1_period5[2] && arr_MA_M1_period60[0]>arr_MA_M1_period60[2];
      //--- we model hierarchy of moving averages on a younger timeframe:   
      //---    "hierarchy" of three MA (the periods of Fibonachchi:5,8,13) (indirect sign of the ascending movement) (M1) is created
      bool hierarchy_of_three_MA=
                                 arr_MA_M1_period5[0]>arr_MA_M1_period8[0] && arr_MA_M1_period8[0]>MA_M1_period13_0;
      //--- we model the provision of the current price of rather moving averages of younger scale:                             
      //---    the current price is higher than MA (5,8,13,60) (indirect sign of the ascending movement) (M1)
      bool current_price_is_higher_than_MA=
                                           m_symbol.Bid()>arr_MA_M1_period5[0] && m_symbol.Bid()>arr_MA_M1_period8[0] &&
                                           m_symbol.Bid()>MA_M1_period13_0 && m_symbol.Bid()>arr_MA_M1_period60[0];
      //--- we model the direction of candles on the senior timeframe:
      //---    the ascending direction of the previous candle (M15)
      bool ascending_direction_of_the_previous_candle_M15=
                                                          rates_M15[1].close>rates_M15[1].open;
      //--- we model the direction of moving average on the senior timeframe:
      //---    the ascending MA with the period of calculation 4 (M15)
      bool ascending_MA_period4=
                                arr_MA_M15_period4[0]>arr_MA_M15_period4[2];
      //--- we model hierarchy of moving averages on the senior timeframe:                             
      //---   "hierarchy" of two MA (the periods of calculation 4 and 8) (indirect sign of the ascending movement) (M15) is created                             
      bool hierarchy_of_two_MA_M15=
                                   arr_MA_M15_period4[1]>MA_M15_period8_1;
      //--- we model the provision of the current price of rather moving averages of the senior scales:
      //---    the current price is higher than MA4 (M15) (indirect sign of the ascending movement) 
      bool current_price_is_higher_than_MAperiod4_M15=
                                                      m_symbol.Bid()>arr_MA_M15_period4[0];
      //---    the current price is higher than MA24 (H1) (indirect sign of the ascending movement)
      bool current_price_is_higher_than_MAperiod24_H1=
                                                      m_symbol.Bid()>MA_H1_period24_0;
      //--- modeling of sufficient activity of the previous process in the senior scale:
      //---    share of "body" of a candle more than 50% of candle amplitude size (previous candle M15)     
      bool share_of_body_M15=
                             rates_M15[1].close-rates_M15[1].open>0.5*(rates_M15[1].high-rates_M15[1].low);
      //---    restriction of depth of correction - less than 25% of amplitude of a candle (the previous candle M15)
      bool restriction_of_depth_of_correction_M15=
                                                  rates_M15[1].high-rates_M15[1].close<0.25*(rates_M15[1].high-rates_M15[1].low);
      //---    the ascending tendency on local levels of resistance (two candles M15)
      bool ascending_tendency_M15=
                                  rates_M15[1].high>rates_M15[2].high;
      //---    existence of a shadow (the previous candle M15) concerning the price of opening of this candle
      bool existence_of_a_shadow_M15=
                                     rates_M15[1].open<rates_M15[1].high && rates_M15[1].open>rates_M15[1].low;
      //--- modeling of sufficient activity of the previous process in younger scale:
      //---    share of "body" of a candle more than 50% of candle amplitude size (previous candle M1)
      bool share_of_body_M1=
                            rates_M1[1].close-rates_M1[1].open>0.5*(rates_M1[1].high-rates_M1[1].low);
      //---    the previous candle has amplitude more threshold (we exclude obvious flat)
      bool previous_candle_no_flat=
                                   rates_M1[1].high-rates_M1[1].low>7*m_adjusted_point;
      //---    restriction of depth of correction - less than 20% of amplitude of a candle (the 2nd candle in the history of data M1)
      bool restriction_of_depth_of_correction_M1=
                                                 rates_M1[2].high-rates_M1[2].close<0.25*(rates_M1[2].high-rates_M1[2].low);
      //---    ascending a tendency on local levels of resistance (two candles M1)
      bool ascending_a_tendency_M1=
                                   rates_M1[1].high>rates_M1[2].high;
      //---    existence of a shadow (the previous candle M1) concerning the price of opening of this candle 
      bool existence_of_a_shadow_M1=
                                    rates_M1[1].open<rates_M1[1].high && rates_M1[1].open>rates_M1[1].low;

      if(amplitude_candles_M1 && 
         amplitude_candles_M15 && 
         amplitude_channel_M15 && 
         activity_previous_bar_M1 && 
         local_resistance_overcome && 
         beginning_wave_M1 && 
         beginning_wave_M15 && 
         ascending_direction_2nd_bar_M1 && 
         ascending_direction_previous_bar_M1 && 
         ascending_MA_5and60 && 
         hierarchy_of_three_MA && 
         current_price_is_higher_than_MA && 
         ascending_direction_of_the_previous_candle_M15 && 
         ascending_MA_period4 && 
         hierarchy_of_two_MA_M15 && 
         current_price_is_higher_than_MAperiod4_M15 && 
         current_price_is_higher_than_MAperiod24_H1 && 
         share_of_body_M15 && 
         restriction_of_depth_of_correction_M15 && 
         ascending_tendency_M15 && 
         existence_of_a_shadow_M15 && 
         share_of_body_M1 && 
         previous_candle_no_flat && 
         restriction_of_depth_of_correction_M1 && 
         ascending_a_tendency_M1 && 
         existence_of_a_shadow_M1)
        {
         //--- if the above-stated conditions of an algorithm of an entrance of Buy are satisfied, then we Open Buy position:
         sl_buy = (InpStopLoss==0)?0.0:m_symbol.NormalizePrice(m_symbol.Ask()-ExtStopLoss);
         tp_buy = (InpStopLoss==0)?0.0:m_symbol.NormalizePrice(m_symbol.Ask()+ExtTakeProfit);

         if(OpenBuy(sl_buy,tp_buy)) // !!! решить с расчётом объёма позиции !!!
            Print("Buy Is open at the price ",DoubleToString(m_trade.ResultPrice(),2));
         else
            Print("Error open Buy");
         return;
        }

      //--- THE ALGORITHM OF THE ENTRANCE TO THE MARKET (SELL)
      //--- we minimize the risks connected with presence of considerable size of volatility by the time of an entrance to the market----
      //---    we model lack of considerable volatility in the next history:
      //---       restriction of amplitude of candles of younger scale (M1)
      bool restriction_of_amplitude_of_candles_M1=
                                                  rates_M1[1].high-rates_M1[1].low<=20*m_adjusted_point && 
                                                  rates_M1[2].high - rates_M1[2].low <= 20*m_adjusted_point &&
                                                  rates_M1[3].high - rates_M1[3].low <= 20*m_adjusted_point;
      //---       restriction of amplitude of candles of the senior scale (M15)
      bool restriction_of_amplitude_of_candles_M15=
                                                   rates_M15[1].high-rates_M15[1].low<=30*m_adjusted_point && 
                                                   rates_M15[2].high - rates_M15[2].low<= 30*m_adjusted_point &&
                                                   rates_M15[3].high - rates_M15[3].low<= 30*m_adjusted_point;
      //---       restriction of amplitude of the channel from candles of the senior scale (M15)
      bool restriction_of_amplitude_of_the_channel_M15=
                                                       rates_M15[1].high-rates_M15[3].low<=30*m_adjusted_point;
      //---       restriction of activity on the previous bar concerning the 2nd bar in the history of quotations
      bool restriction_of_activity_on_the_previous_bar=
                                                       rates_M1[1].high-rates_M1[1].low>=1.1*(rates_M1[2].high-rates_M1[2].low) && 
                                                       rates_M1[1].high-rates_M1[1].low<3.0*(rates_M1[2].high-rates_M1[2].low);
      //--- we minimize the risks connected with presence of levels of resistance at an entrance to the market
      //---    we model a situation at which local levels of resistance are overcome by the current price:
      //---     on (M1) (younger scale)
      bool local_levels_of_resistance_M1=
                                         m_symbol.Bid()<rates_M1[1].low;
      //---     on (M15) (senior scale)
      bool local_levels_of_resistance_M15=
                                          m_symbol.Bid()<rates_M15[1].low;
      //--- we minimize the risks connected with an entrance in an oversold zone at an entrance to the market
      //---    we model a binding to the beginning of a wave to reduce probability of an entrance in an oversold zone:
      //---       the beginning of a wave - not further three bars in the history of data (M1)
      bool the_beginning_of_a_wave_M1=
                                      (arr_MA_M1_period8[1]>rates_M1[1].low && arr_MA_M1_period8[1]<rates_M1[1].high) ||
                                      (arr_MA_M1_period8[2]>rates_M1[2].low && arr_MA_M1_period8[2]<rates_M1[2].high) ||
                                      (arr_MA_M1_period8[3]>rates_M1[3].low && arr_MA_M1_period8[3]<rates_M1[3].high);
      //---       the beginning of a wave - on the previous bar of the senior timeframe (M15)
      bool the_beginning_of_a_wave_M15=
                                       MA_M15_period5_1>rates_M15[1].low && MA_M15_period5_1<rates_M15[1].high;
      //--- we minimize the risks connected with lack of the expressed trend at an entrance to the market                                   
      //---    we model the direction of candles on a younger timeframe:                                    
      //---       the descending direction of a candle on the 2nd bar in the history (M1) 
      bool the_descending_direction_of_a_candle=
                                                rates_M1[2].close<rates_M1[2].open;
      //---       the descending direction of the previous candle (M1)  
      bool the_descending_direction_of_the_previous_candle=
                                                           rates_M1[1].close<rates_M1[1].open;
      //---    we model the direction of moving averages on a younger timeframe:     
      //---       the descending MA: we use moving averages with the period of calculation 5 and 60 (M1)
      bool the_descending_MA_5and60_M1=
                                       arr_MA_M1_period5[0]<arr_MA_M1_period5[2] && arr_MA_M1_period60[0]<arr_MA_M1_period60[2];
      //---    we model hierarchy of moving averages on a younger timeframe:
      //---       "hierarchy" of three MA (the periods of Fibonachchi:5,8,13) (indirect sign of the descending movement) (M1) is created
      bool hierarchy_of_three_MA_M1=
                                    arr_MA_M1_period5[0]<arr_MA_M1_period8[0] && arr_MA_M1_period8[0]<MA_M1_period13_0;
      //---    we model the provision of the current price of rather moving averages of younger scale:
      //---       the current price is lower than MA (5,8,13,60) (indirect sign of the descending movement) (M1)
      bool the_current_price_is_lower_than_MA=
                                              m_symbol.Bid()<arr_MA_M1_period5[0] && m_symbol.Bid()<arr_MA_M1_period8[0] &&
                                              m_symbol.Bid()<MA_M1_period13_0 && m_symbol.Bid()<arr_MA_M1_period60[0];
      //---    we model the direction of candles on the senior timeframe:
      //---       the descending direction of the previous candle (M15)
      bool the_descending_direction_of_the_previous_candle_M15=
                                                               rates_M15[1].close<rates_M15[1].open;
      //---    we model the direction of moving average on the senior timeframe:
      //---       the descending MA with the period of calculation 4 (M15)
      bool the_descending_MA_4_M15=
                                   arr_MA_M15_period4[0]<arr_MA_M15_period4[2];
      //---    we model hierarchy of moving averages on the senior timeframe:
      //---       "hierarchy" of two MA (the periods of calculation 4 and 8) (indirect sign of the descending movement) (M1) is created
      bool hierarchy_of_two_MA_M1=
                                  arr_MA_M15_period4[1]<MA_M15_period8_1;
      //---    we model the provision of the current price of rather moving averages of the senior scales:
      //---       the current price is lower, than MA4 (M15) (indirect sign of the descending movement) 
      bool the_current_price_is_lower_M15=
                                          m_symbol.Bid()<arr_MA_M15_period4[0];
      //---       the current price is lower, than MA24 (M1) (indirect sign of the descending movement)
      bool the_current_price_is_lower_M1=
                                         m_symbol.Bid()<MA_H1_period24_0;
      //---    modeling of a microtrend in the current candle of younger scale and also an entry point:
      //---       existence of the descending movement in the current candle (M1)
      bool existence_of_the_descending_movement_M1=
                                                   m_symbol.Bid()<rates_M1[0].open;
      //---    modeling of sufficient activity of the previous process in the senior scale:
      //---       share of "body" of a candle more than 50% of candle amplitude size (previous candle (M15))
      bool share_of_body_of_a_candle_M15=
                                         rates_M15[1].open-rates_M15[1].close>0.5*(rates_M15[1].high-rates_M15[1].low);
      //---       restriction of depth of correction - less than 25% of amplitude of a candle (the previous candle (M15))
      bool restriction_of_correction_less25_M15=
                                                rates_M15[1].close-rates_M15[1].low<0.25*(rates_M15[1].high-rates_M15[1].low);
      //---       the descending tendency on local levels of resistance (two candles (M15)) 
      bool the_descending_tendency_M15=
                                       rates_M15[1].low<rates_M15[2].low;
      //---       existence of a shadow (the previous candle (M15)) concerning the price of opening of this candle
      bool existence_of_a_shadow_previous_candle_M15=
                                                     rates_M15[1].open<rates_M15[1].high && rates_M15[1].open>rates_M15[1].low;
      //---    modeling of sufficient activity of the previous process in younger scale: 
      //---       share of "body" of a candle more than 50% of candle amplitude size (previous candle (M1))
      bool share_of_body_of_a_candle_M1=
                                        rates_M1[1].open-rates_M1[1].close>0.5*(rates_M1[1].high-rates_M1[1].low);
      //---       the previous candle has amplitude more threshold (we exclude obvious flat)
      bool the_previous_candle_has_amplitude=
                                             rates_M1[1].high-rates_M1[1].low>7*m_adjusted_point;
      //---       restriction of depth of correction - less than 20% of amplitude of a candle (the 2nd candle in the history of data (M1))
      bool restriction_of_depth_of_correction_less_M1=
                                                      rates_M1[2].close-rates_M1[2].low<0.25*(rates_M1[2].high-rates_M1[2].low);
      //---       the descending tendency on local levels of resistance (two candles (M1))
      bool the_descending_tendency_M1=
                                      rates_M1[1].low<rates_M1[2].low;
      //---       existence of a shadow (the previous candle (M1)) concerning the price of opening of this candle
      bool existence_of_a_shadow_previous_candle_M1=
                                                    rates_M1[1].open<rates_M1[1].high && rates_M1[1].open>rates_M1[1].low;
      //---

      if(
         restriction_of_amplitude_of_candles_M1 && 
         restriction_of_amplitude_of_candles_M15 && 
         restriction_of_amplitude_of_the_channel_M15 && 
         restriction_of_activity_on_the_previous_bar && 
         local_levels_of_resistance_M1 && 
         local_levels_of_resistance_M15 && 
         the_beginning_of_a_wave_M1 && 
         the_beginning_of_a_wave_M15 && 
         the_descending_direction_of_a_candle && 
         the_descending_direction_of_the_previous_candle && 
         the_descending_MA_5and60_M1 && 
         hierarchy_of_three_MA_M1 && 
         the_current_price_is_lower_than_MA && 
         the_descending_direction_of_the_previous_candle_M15 && 
         the_descending_MA_4_M15 && 
         hierarchy_of_two_MA_M1 && 
         the_current_price_is_lower_M15 && 
         the_current_price_is_lower_M1 && 
         existence_of_the_descending_movement_M1 && 
         share_of_body_of_a_candle_M15 && 
         restriction_of_correction_less25_M15 && 
         the_descending_tendency_M15 && 
         existence_of_a_shadow_previous_candle_M15 && 
         share_of_body_of_a_candle_M1 && 
         the_previous_candle_has_amplitude && 
         restriction_of_depth_of_correction_less_M1 && 
         the_descending_tendency_M1 && 
         existence_of_a_shadow_previous_candle_M1
         )
        {
         //--- if the above-stated conditions of an algorithm of an entrance of Sell are satisfied, then we Open Sell position:
         sl_sell = (InpStopLoss==0)?0.0:m_symbol.NormalizePrice(m_symbol.Bid()+ExtStopLoss);
         tp_sell = (InpTakeProfit==0)?0.0:m_symbol.NormalizePrice(m_symbol.Bid()-ExtTakeProfit);

         if(OpenSell(sl_buy,tp_buy)) // !!! решить с расчётом объёма позиции !!!
            Print("Sell Is open at the price ",DoubleToString(m_trade.ResultPrice(),2));
         else
            Print("Error open Sell");
         //--- here termination of an algorithm of an entrance to the market (Buy, Sell)
         return;
        }
     }
//--- preparation of closing of a position:
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name()/* && m_position.Magic()==m_magic*/)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               //--- algorithm of closing of a position buy
               //---    the module of search of the available price maximum in an open position
               //---       at first we will define a distance from the current point in an open position to an entry point in the market:
               shift_buy=0;   // we define a distance in bars (M1) to an entry point
               shift_buy=((int)(Time_cur-m_position.Time()))/60;
               Max_pos=0.0;   // we will define a price maximum after an entrance to the market:
               if(shift_buy>0)
                  Max_pos=iHighest(m_symbol.Name(),PERIOD_M1,MODE_HIGH,shift_buy+1,0);
               if(Max_pos==0.0)
                  continue;
               //--- we pass to closing of an open position of Buy (options logically OR):
               //--- we minimize the risks connected with collapses of the prices after an entrance to the market
               //---    exit conditions (in any zone) at a collapse in prices (a control point - the price of opening of the current candle (M1))
               bool collapse_in_prices_M1=
                                          m_symbol.Bid()<rates_M1[0].open && 
                                          (rates_M1[0].open-m_symbol.Bid())>=10*m_adjusted_point && (long)(Time_cur-rates_M1[0].time)<=20;
               //---    exit conditions (in any zone) at a collapse in prices (a control point - the price of opening of the current candle (M15))                           
               bool collapse_in_prices_M15=
                                           m_symbol.Bid()<rates_M15[0].open && 
                                           (rates_M15[0].open-m_symbol.Bid())>=20*m_adjusted_point && (long)(Time_cur-rates_M15[0].time)<=120;
               //---    exit conditions in any zone at a collapse in prices (control parameter - amplitude of the previous candle (M1))
               bool collapse_in_prices=
                                       Time_cur-m_position.Time()>60 && rates_M1[1].close<rates_M1[1].open && 
                                       (rates_M1[1].open-rates_M1[1].close)>=20*m_adjusted_point;
               //--- we minimize the risks connected with uncertainty of amplitude of the movement of the prices after an entrance to the market
               //---    control of size of the fixed profit (on a position):
               //---       exit conditions in a profit zone (a shadow take profit)
               bool conditions_in_a_profit_zone=
                                                m_symbol.Bid()>m_position.PriceOpen() && 
                                                (m_symbol.Bid()-m_position.PriceOpen())>=10*m_adjusted_point;
               //---    control of size of a maximum tolerance of the price from the current maximum after an entrance to the market:
               //---       shift not less than 1 bar from an entry point
               bool shift_not_less=
                                   shift_buy>=1;
               //---       the current maximum is in a profit zone
               bool curr_max_in_profit_zone=
                                            Max_pos>m_position.PriceOpen();
               //---       there is the return movement of the price
               bool return_movement_of_the_price=
                                                 m_symbol.Bid()<Max_pos;
               //---       the size of the return deviation from the current maximum for an exit from the market
               bool size_of_the_return_deviation=
                                                 Max_pos-m_symbol.Bid()>=20*m_adjusted_point;
               //---    control of in advance set risk limit (on a position):
               //---       exit conditions in a loss zone (shadow stop loss) 
               bool exit_conditions_sl=
                                       m_symbol.Bid()<m_position.PriceOpen() && m_position.PriceOpen()-m_symbol.Bid()>=20*m_adjusted_point;
               //---    control of in advance set risk limit (in it is whole on a deposit):
               //---       if at the current trade the risk limit in general of a deposit is exceeded
               bool curr_trade_risk=
                                    m_account.Balance()<=NormalizeDouble((InpDepoFirst*((100.0-InpPercentRiskDepo)/100.0)),2);
               //---

               if(
                  collapse_in_prices_M1 || 
                  collapse_in_prices_M15 || 
                  collapse_in_prices || 
                  conditions_in_a_profit_zone || 
                  (shift_not_less && 
                  curr_max_in_profit_zone && 
                  return_movement_of_the_price && 
                  size_of_the_return_deviation) || 
                  exit_conditions_sl || 
                  curr_trade_risk
                  )
                 {
                  if(!m_trade.PositionClose(m_position.Ticket())) // if the algorithm of closing is executed, then we close Buy position
                     Print("Error close Buy positions ",m_trade.ResultRetcode()); // otherwise we print an error of closing of a position of Buy
                  return;
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               //--- algorithm of closing of a position sell
               //---    the module of search of the available price maximum in an open position
               //---       at first we will define a distance from the current point in an open position to an entry point in the market:
               shift_sell=0;
               shift_sell=((int)(Time_cur-m_position.Time()))/60;
               Min_pos=0.0;   // we will define a price minimum after an entrance to the market:
               if(shift_sell>0)
                  Min_pos=iLowest(m_symbol.Name(),PERIOD_M1,MODE_LOW,shift_buy+1,0);
               if(Min_pos==0.0)
                  continue;
               //--- we pass to closing of an open position of Sell (options logically OR):
               //--- we minimize the risks connected with collapses of the prices after an entrance to the market
               //---    exit conditions (in any zone) at a collapse in prices (a control point - the price of opening of the current candle (M1))
               bool collapse_in_prices_M1=
                                          m_symbol.Bid()>rates_M1[0].open &&
                                          m_symbol.Bid()-rates_M1[0].open>=10*m_adjusted_point && (long)(Time_cur-rates_M1[0].open)<=20;
               //---    exit conditions (in any zone) at a collapse in prices (a control point - the price of opening of the current candle (M15))
               bool collapse_in_prices_M15=
                                           m_symbol.Bid()>rates_M15[0].open && 
                                           (m_symbol.Bid()-rates_M15[0].open)>=20*m_adjusted_point && (long)(Time_cur-rates_M15[0].time)<=120;
               //---    exit conditions in any zone at a collapse in prices (control parameter - amplitude of the previous candle (M1))
               bool collapse_in_prices=
                                       (long)(Time_cur-m_position.Time())>60 && rates_M1[1].close>rates_M1[1].open && 
                                       (rates_M1[1].close-rates_M1[1].open)>=20*m_adjusted_point;
               //--- we minimize the risks connected with uncertainty of amplitude of the movement of the prices after an entrance to the market
               //---    control of size of the fixed profit (on a position):
               //---       exit conditions in a profit zone (a shadow take profit)
               bool conditions_in_a_profit_zone=
                                                m_symbol.Bid()<m_position.PriceOpen() && 
                                                (m_position.PriceOpen()-m_symbol.Bid())>=10*m_adjusted_point;
               //---    control of size of a maximum tolerance of the price from the current minimum after an entrance to the market:
               //---       shift not less than 1 bar from an entry point
               bool shift_not_less=
                                   shift_sell>=1;
               //---       the current maximum is in a profit zone
               bool curr_min_in_profit_zone=
                                            Min_pos<m_position.PriceOpen();
               //---       there is the return movement of the price
               bool return_movement_of_the_price=
                                                 m_symbol.Bid()>Min_pos;
               //---       the size of the return deviation from the current minimum for an exit from the market
               bool size_of_the_return_deviation=
                                                 m_symbol.Bid()-Min_pos>=20*m_adjusted_point;

               //---    control of in advance set risk limit (on a position):
               //---       exit conditions in a loss zone (shadow stop loss) 
               bool exit_conditions_sl=
                                       m_symbol.Bid()>m_position.PriceOpen() && (m_symbol.Bid()-m_position.PriceOpen())>=20*m_adjusted_point;
               //---    control of in advance set risk limit (in it is whole on a deposit):
               //---       if at the current trade the risk limit in general of a deposit is exceeded
               bool curr_trade_risk=
                                    m_account.Balance()<=NormalizeDouble((InpDepoFirst*((100.0-InpPercentRiskDepo)/100.0)),2);
               if(
                  collapse_in_prices_M1 || 
                  collapse_in_prices_M15 || 
                  collapse_in_prices || 
                  conditions_in_a_profit_zone || 
                  (shift_not_less && 
                  curr_min_in_profit_zone && 
                  return_movement_of_the_price && 
                  size_of_the_return_deviation) || 
                  exit_conditions_sl || 
                  curr_trade_risk
                  )
                 {
                    {
                     if(!m_trade.PositionClose(m_position.Ticket())) // if the algorithm of closing is executed, then we close Sell position
                        Print("Error close Sell positions ",m_trade.ResultRetcode()); // otherwise we print an error of closing of a position of Sell
                     return;
                    }
                 }
              }
           }

   PrevBars=time_0;
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
//|                                                                  |
//+------------------------------------------------------------------+
double iHighest(string symbol,
                ENUM_TIMEFRAMES timeframe,
                int type,
                int count=WHOLE_ARRAY,
                int start=0)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   if(start<0)
      return(-1.0);
   if(count<=0)
      count=Bars(symbol,timeframe);
   if(type==MODE_HIGH)
     {
      double High[];
      ArraySetAsSeries(High,true);
      CopyHigh(symbol,timeframe,start,count,High);
      return(High[ArrayMaximum(High,0,WHOLE_ARRAY)]);
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iLowest(string symbol,
               ENUM_TIMEFRAMES timeframe,
               int type,
               int count=WHOLE_ARRAY,
               int start=0)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   if(start<0)
      return(-1.0);
   if(count<=0)
      count=Bars(symbol,timeframe);
   if(type==MODE_LOW)
     {
      double Low[];
      ArraySetAsSeries(Low,true);
      CopyLow(symbol,timeframe,start,count,Low);
      return(Low[ArrayMinimum(Low,0,WHOLE_ARRAY)]);
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
bool iMAGet(int handle_iMA,double &array[],int count)
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,0,count,array)!=count)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(int handle_iMA,const int index)
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
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
int CalculateAllPositions()
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name()/* && m_position.Magic()==m_magic*/)
            total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
bool OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_long_lot==0.0)
      return(false);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=check_open_long_lot)
        {
         if(m_trade.Buy(check_open_long_lot,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(false);
              }
            else
              {
               Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(true);
              }
           }
         else
           {
            Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            return(false);
           }
        }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
bool OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_short_lot==0.0)
      return(false);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=check_open_short_lot)
        {
         if(m_trade.Sell(check_open_short_lot,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(false);
              }
            else
              {
               Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(true);
              }
           }
         else
           {
            Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            return(false);
           }
        }
//---
   return(false);
  }
//+------------------------------------------------------------------+ 
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0)
      time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
