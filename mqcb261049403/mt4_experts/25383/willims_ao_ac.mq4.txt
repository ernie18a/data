//+-------------------------------------------------------------------+
//|                                               Williams_AOAC.mq4   |
//|                                         copyright 2019 R Poster   |
//|                                                                   |
//+-------------------------------------------------------------------+
//+-------------------------------------------------------------------+
//|  SingleCurrency EA                                                |
//|  EURUSD H1 Chart                                                  |
//|  Triggers:   AO zero Cross, AC 2 bars, RSI Limits                 |
//|  Set up Buy & Sell Mkt Orders                                     |
//+-------------------------------------------------------------------+
//
#property copyright "RAP"
#property strict
#define   NAME		  "Williams_AOAC" 
#property link      "http://www.metatrader.org" 
#include <WinUser32.mqh>
//
//---------------------------------------------------------------------                    
// ---- Global variables ----------------
double       PipValue;
int          magic_number;
double       _point,_bid,_ask,_spread,_Low,_High,_close,_open;
int          _digits;
string       _symbol;
int          slpg=3;
double       MULT;
//------------ input parameters ----------------------------------
input int        MagicNumber=1113355; //
 // -------- Trigger  Data  ---------------------
// Bollinger Band Filter data
int              BBPeriod    =   20;      // Boll Band Period
double           BBSigma     =  2.0;      // Boll Band Sigma
input string      N1=" --------- Buy/Sell Trigger Data ----------";                                      //
input double      BBSprd_LwLim =  40.;      // Boll Band Lower Limit
input double      BBSprd_UpLim = 210.;      // Boll Band Upper Limit
input int         PeriodFast   =   11;      // AO AC Fast Period
input int         PeriodSlow   =   40;      // AO AC Slow Period
input int         RSI_Per      =   20;      // RSI Period
input double      RSI_Lo       =   40.;     // RSI Buy Upper Limit
input double      RSI_Hi       =   46.;     // RSI Sell Lower Limit
// trading hour filter
input int         entryhour    =    0;       // Trade Entry Hour (0-23)
input int         openhours    =   20;       // Trade Duration Hours (0-23)
 // Money Mgmt
input string      N2=" --------- Money__Management ----------";
input double      Lots          =  0.01;
input double      TakeProfit    =   90.;
input double      StopLoss      =   60.;
input double      TrailingStop  =   30.;
//
input string      N3=" ------- Order Number Limits ----------";
input int         NumOpenOrders = 1;
int               TotOpenOrders = 8;
//
//------------------------------------------------------------------------
//                  Main Functions
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   _symbol=Symbol();   // set symbol
   _point = MarketInfo(_symbol,MODE_POINT);
   _digits= int(MarketInfo(_symbol,MODE_DIGITS));
   MULT=1.0;
   if(_digits==5 || _digits==3) MULT=10.0;
   magic_number=MagicNumber;
   PipValue=PipValues(_symbol);
//   
   return (INIT_SUCCEEDED);
  } //--------------------End init ---------------------------------------------
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print(" Active Symbol  ",Symbol(),"  Period ",Period()," pip value ",PipValue);
   Print(" Broker Factor*_point =   ",_point*MULT,"  _point =  ",100000.*_point);

   return;
  }//------------------------------------------------------------------
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
void OnTick()
  {
   int  trentry;
   datetime  bartime_previous;
   static datetime bartime_current;
   int hour_current;
   bool newperiod;
// Order Management parameters   
   double Take_Profit,Stop_Loss;
   double orderlots;
   string OrdComment;
   bool   BuySig,SellSig;
   int    OpenOrders;
// -- set up new bar test ---------------------------
   newperiod=false;
   bartime_previous= bartime_current;
   bartime_current =iTime(_symbol,Period(),0);
   if(bartime_current!=bartime_previous) newperiod=true;
//------------------------  Start of new Bar ---------------------------------------    
   if(newperiod)
     {
      // Set Globals       
      _bid =    MarketInfo(_symbol,MODE_BID);
      _ask =    MarketInfo(_symbol,MODE_ASK);
      _spread = MarketInfo(_symbol,MODE_SPREAD);
      _Low  =   MarketInfo(_symbol,MODE_LOW);
      _High =   MarketInfo(_symbol,MODE_HIGH);
      // initializaton          
      BuySig=false;
      SellSig=false;
      OpenOrders=0;
      trentry=0;  // entry flag 1=buy, 2=sell         
      OrdComment="";
      //     
      OpenOrders=NumOpnOrds();   // number of open market orders for this symbol 
                          //
      //-----------------  Trigger  -----------------------------------------------------   
      GetAOACTrigger(BuySig,SellSig);
      // set trade entry flag trentry                  
      if( BuySig)  trentry=1;
      if( SellSig) trentry=2;
      //
      Take_Profit =  TakeProfit;
      Stop_Loss   =  StopLoss;
      //       
      if(OpenOrders>=NumOpenOrders) trentry=0;  // limit number of open orders
  // ---------------- Hour of Day Filer -----------------------------------------  
      hour_current=TimeHour(bartime_current);
      if(!HourRange(hour_current,entryhour,openhours)) trentry=0;
      //------------------  open trade ---------------------------------------------  
      if(trentry>0)
        {
         orderlots=Lots;
      // Open new market order - check account for funds and also lot size limits            
        if(CheckMoneyForTrade(_symbol, orderlots,trentry-1))
           OpenOrder(trentry,orderlots,Stop_Loss,Take_Profit,OrdComment,NumOpenOrders);
        } //  --------------- trentry ----------------------------------------------------   
     } // -------------------- end of if new bar ----------------------------------------------------
//                                                                       
// ---------------------------  every tic processing ------------------------------------------------
// ---------------------- Manage trailing stop at every tic for all open orders ---------------------
   if(OrdersTotal()==0) return;
//
   _symbol=Symbol();
   magic_number=MagicNumber;
   _point =  MarketInfo(_symbol,MODE_POINT);
   _bid =    MarketInfo(_symbol,MODE_BID);
   _ask =    MarketInfo(_symbol,MODE_ASK);
   _digits = int(MarketInfo(_symbol,MODE_DIGITS));
   MULT=1.0;
   if(_digits==5 || _digits==3)
      MULT=10.0;
// ----------  manage trailing stop --------------------------------------      
   if(TrailingStop>0.) ManageTrlStop(TrailingStop);
   return;
  }
//+------------------- end of OnTick() ---------------------------------------------------------+
//
//+ --------------------------------------------------------------------------------------------+
//|                       Application Functions                                                 |
//+---------------------------------------------------------------------------------------------+
void GetAOACTrigger( bool &TBuy, bool &TSell)
//+----------------------------------------------------------+
//| Trigger return True or False for Buy and Sell
//| call GetPred for selected timeframes(s)
//+----------------------------------------------------------+
  {
   double rsi_val;
   double BB_Spread;
   double acMn[5]= {0.,0.,0.,0.,0.}; // AC main
   double acUp[5]= {0.,0.,0.,0.,0.}; // AC green up
   double acDn[5]= {0.,0.,0.,0.,0.}; // AC red down
   double awMn[5]= {0.,0.,0.,0.,0.}; // AO main 
   double awUp[5]= {0.,0.,0.,0.,0.}; // AO green up
   double awDn[5]= {0.,0.,0.,0.,0.}; // AO red down
   int jj;
   //
   TBuy = false;
   TSell = false;
 //  
   BB_Spread = (iBands(_symbol,0,BBPeriod,2,0,PRICE_CLOSE,MODE_UPPER,1) -
                iBands(_symbol,0,BBPeriod,2,0,PRICE_CLOSE,MODE_LOWER,1))/(_point*MULT); 
   //
   if(BB_Spread<BBSprd_LwLim || BB_Spread>BBSprd_UpLim) return; 
   //
   rsi_val= iRSI(_symbol,0,RSI_Per,PRICE_CLOSE,1);
  //
  // Accelerator & Awesome Indicators (use iCustom to get at color buffers and periods)
   for (jj = 0; jj < 5; jj++)
    {
//     acMn[jj] = iCustom (_symbol,0,"AcceleratorV2",PeriodFast,PeriodSlow,0,jj+1);
     acUp[jj] = iCustom (_symbol,0,"AcceleratorV2",PeriodFast,PeriodSlow,1,jj+1);
     acDn[jj] = iCustom (_symbol,0,"AcceleratorV2",PeriodFast,PeriodSlow,2,jj+1);
    //
//     awMn[jj] = iCustom (_symbol,0,"AwesomeV2", PeriodFast,PeriodSlow,0,jj+1);
     awUp[jj] = iCustom (_symbol,0,"AwesomeV2", PeriodFast,PeriodSlow,1,jj+1);
     awDn[jj] = iCustom (_symbol,0,"AwesomeV2", PeriodFast,PeriodSlow,2,jj+1);
    }
// -----  Trigger -------                   
    if(awUp[1]<0. && awUp[0]>0. && acUp[2]>0. && acUp[1]>0. && acUp[0]>acUp[1] && rsi_val> RSI_Hi) TBuy= true;
    if(awDn[1]>0. && awDn[0]<0. && acDn[2]<0. && acDn[1]<0. && acDn[0]<acDn[1] && rsi_val< RSI_Lo) TSell=true;

   return;
  }
  //
// --------------------------------------------------------------------------------  
 bool CheckMoneyForTrade(string symb, double &olots,int type)
  {
 // check limits of lot size
   if( olots<NormalizeDouble(MarketInfo(NULL,MODE_MINLOT),2) ){ olots=NormalizeDouble(MarketInfo(NULL,MODE_MINLOT),2); }
   if( olots>NormalizeDouble(MarketInfo(NULL,MODE_MAXLOT),2) ){ olots=NormalizeDouble(MarketInfo(NULL,MODE_MINLOT),2); }
//
   double free_margin=AccountFreeMarginCheck(symb,type, olots);
 //-- if there is not enough money
   if(free_margin<=0.)
    {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("** Not enough money for ", oper," ",olots, " ", symb, " Error code=",GetLastError());
      Print(" Account Margin ",AccountMargin(),"  Free Margin ",AccountFreeMargin());
      return(false);
    }
   //--- checking successful
   return(true);
  }
  //
//-------------------------------------------------------------------------------------------
bool HourRange(int hour_current,int lentryhour,int lopenhours)
//+-----------------------------------------------------------------+ 
//| Open trades within a range of hours starting at entry_hour      |
//| Duration of trading window is open_hours                        |
//| open_hours = 0 means trading is open for 1 hour                 |
//+-----------------------------------------------------------------+
  {
   bool Hour_Test;
   int closehour;
   bool wrap;
// 
   Hour_Test=true;
   wrap=false;
   closehour = lentryhour+lopenhours;
   if(closehour>23)wrap=true;  // see if close hour wraps around
   closehour = int( MathMod((closehour),24));
   //
   if( wrap && (hour_current<lentryhour && hour_current >closehour))  Hour_Test=false;  
   if(!wrap && (hour_current<lentryhour || hour_current >closehour))  Hour_Test=false;    
// 
   return(Hour_Test);
  }
 //----------------------------------------------------------------------------------------------- 
// ******************* Trading Functions ***********************************************
//------------------------------------------------------------------------------------
void OpenOrder(int tr_entry,double Ord_Lots,double Stop_Loss,double Take_Profit,string New_Comment,int Num_OpenOrders)
//+-----------------------------------------------------------------------------------+
//| Open New Orders                                                                   |
//| Uses externals: magic_number, TotOpenOrders, Currency                             |
//|                                                                                   |
//+-----------------------------------------------------------------------------------+                      
  {
   int total_EA,total,Mag_Num,trade_result,cnt;
   double tp_norm,sl_norm;
   string NetString;

// -------------  Open New Orders ----------------------------------------------      
//  Get new open order total     
   total_EA=0;
   total=OrdersTotal();
   for(cnt=0;cnt<total;cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderType()<=OP_SELL)
         total_EA=total_EA+1;
     } // loop
   if(total_EA>=TotOpenOrders) return; // max number of open orders allowed( all symbols)
                                       //    
   total_EA=0;
   for(cnt=0;cnt<total;cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==false) break;
      Mag_Num=OrderMagicNumber();
      if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && Mag_Num==magic_number)
         total_EA=total_EA+1;
     } //----   loop  -------
//      
   if(total_EA<Num_OpenOrders) // open new order if below OpenOrder limit
     {
      if(tr_entry==1) //Open a Buy Order
        {
         sl_norm = NormalizeDouble(_ask - Stop_Loss*MULT*_point, _digits);
         tp_norm = NormalizeDouble(_ask + Take_Profit*MULT*_point, _digits);
         trade_result=Buy_Open(Ord_Lots,sl_norm,tp_norm,magic_number,New_Comment);
         if(trade_result<0)
            return;

        } // ---  end of tr_entry = 1 --------------------------------
      if(tr_entry==2) // Open a Sell Order
        {
         sl_norm = NormalizeDouble((_bid + Stop_Loss*MULT*_point), _digits);
         tp_norm = NormalizeDouble((_bid - Take_Profit*MULT*_point),_digits);
         trade_result=Sell_Open(Ord_Lots,sl_norm,tp_norm,magic_number,New_Comment);
         if(trade_result<0)
            return;
        } // ------------------  end tr_entry = 2 -----------------------   
     } // -----------------------end of Open New Orders ------------------------------- 
   return;
  }
// --------------------------------------------------------------------------------------

//   ------------------- Open Buy Order ------------------------------      
int Buy_Open(double Ord_Lots,double stp_Loss,double tk_profit,int magic_num,string New_Comment)
//+---------------------------------------------------------------------------------+
//|  Open a Long trade                                                              |
//|  Return code < 0 for error                                                      |
// +--------------------------------------------------------------------------------+
  {
   int ticket_num;
   ticket_num=OrderSend(_symbol,OP_BUY,Ord_Lots,_ask,slpg,stp_Loss,tk_profit,New_Comment,magic_num,0,Green);
   if(ticket_num<=0)
     {
      Print(" error on opening Buy order ");
      return (-1);
     }
   return(0);
  }
//---------------------------------------------------------------------------------
// ------ Open Sell Order ---------------------------------------------------------- 
int Sell_Open(double Ord_Lots,double stp_Loss,double tk_profit,int magic_num,string New_Comment)
//+---------------------------------------------------------------------------------+
//|  Open a Short trade                                                             |
//|  Return code < 0 for error                                                      |
// +--------------------------------------------------------------------------------+ 
  {
   int ticket_num;
   ticket_num=OrderSend(_symbol,OP_SELL,Ord_Lots,_bid,slpg,stp_Loss,tk_profit,New_Comment,magic_num,0,Red);
   if(ticket_num<=0)
     {
      Print(" error on opening Sell order ");
      return (-1);
     }
   return(0);
  }
//----------------------------- end Sell -----------------------------------------
void ManageTrlStop(double Trail_Stop)
//+--------------------------------------------------------------------+
//| Manage Trailing Stop                                               |
//| Globals: _point, MULT, _digits, _bid, _ask                         |
//+--------------------------------------------------------------------+
  {
   double  sl;
   int cnt,total;
//
   total  = OrdersTotal();
   for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
        {
         if(OrderType()==OP_BUY) // ------- Manage long position ------
           {
            if(Trail_Stop>0.)
              {
               if((_bid-OrderOpenPrice())>MULT*_point*Trail_Stop)
                 {
                  if( ((_bid - MULT*_point*Trail_Stop) - OrderStopLoss())> MULT*_point )
                    {
                     sl=NormalizeDouble(_bid-MULT*_point*Trail_Stop,_digits);
                     OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,Green);
                    }
                 }
              }
           } // ---- end Trailing Stop for Buy  ------------------
         if(OrderType()==OP_SELL) // ------- Manage short position  -----
           {
            if(Trail_Stop>0.)
              {
               if((OrderOpenPrice()-_ask)>MULT*_point*Trail_Stop)
                 {
             //     if(OrderStopLoss()>(_ask+MULT*_point*Trail_Stop))
                  if( (OrderStopLoss()-(_ask + MULT*_point*Trail_Stop))> MULT*_point)
                    {
                     sl=NormalizeDouble(_ask+MULT*_point*Trail_Stop,_digits);
                     OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,Red);
                    }
                 }
              } // ---- end Trailing Stop for Sell  ------------------  
           }//------------- if OrderType = Sell --------------------------------
        }// ---------------- if OrderType ------------------------------------------------  
     }//----------------- loop ----------------------------------------------------------------            
   return;
  }
// ----------------------- end Manage Min Profit ----------------------------------------------      

int NumOpnOrds()
//+--------------------------------------------------------------------------+ 
//|  Return Number of Open Orders for active currency                        |  
//+--------------------------------------------------------------------------+  
  {
   int cnt,NumOpn,total;
   NumOpn = 0;
   total  = OrdersTotal();
   for(cnt=0;cnt<total;cnt++)
     {
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)==false) return(NumOpn);
      if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
        {
         NumOpn=NumOpn+1;
        }
     }
   return(NumOpn);
  }
// ----------------------------------------------------------------------------    

double PipValues(string SymbolPair)
//+-----------------------------------------------------------------------------------+
//| Calculate Dollars/Pip for 1 Lot                                                   |
//+-----------------------------------------------------------------------------------+
  {
   double DlrsPip;
   DlrsPip = 10.;
   DlrsPip = 10.*MarketInfo(SymbolPair,MODE_TICKVALUE);
   return(DlrsPip);
  }
//------------------------------------------------------------------------  
