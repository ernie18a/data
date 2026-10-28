//+-------------------------------------------------------------------+
//|                                            AwesomeOscTrader.mq4   |
//|                                         copyright 2019 R Poster   |
//|                                                                   |
//+-------------------------------------------------------------------+
//+-------------------------------------------------------------------+
//|  SingleCurrency EA                                                |
//|  Use EURUSD H1 Chart                                              |
//|  Triggers:   AO Cross, AC 2 bars, RSI Limits                      |
//|  Set up Buy & Sell Mkt Orders                                     |
//+-------------------------------------------------------------------+
//
#property copyright "RAP"
#property strict
#define   NAME		  "AwesomeOscTrader" 
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
bool retval=false;
//------------ input parameters ----------------------------------
input int        MagicNumber=123456; //
                                     // -------- Trigger  Data  ---------------------
input bool         CloseTrade=true; // Close Trade by AO
input int          ProfitTypeClTrd=1; //Close Trade: Prof Type (0:all,1:pos,2:neg)

                                      // Bollinger Band Filter data
int         BBPeriod    =   20;      // Boll Band Period
double      BBSigma     =  2.0;      // Boll Band Sigma
input string      N1=" --------- Buy/Sell Trigger Data ----------";
//
input double      BBSprd_LwLim =  24.;      // Boll Band Lower Limit
input double      BBSprd_UpLim = 230.;      // Boll Band Upper Limit
                                            // -------- Trigger  Data  ---------------------
input int         PeriodFast =    4;  // AO Fast Period
input int         PeriodSlow =   28;  // AO Slow Period
input double      awLimit=0.0; // AO Strength Lower Limit
                                // Stoc
input int         kStoc   =     1;
input int         dStoc   =     4;
input int         sStoc   =     1;
input double      Stoc_Lo =    12.;  // Stoc Lower Limit for Sell
input double      Stoc_Hi =    21.;  // Stoc Upper Limit for Buy   
                                     //
input int         entryhour  =  16;       // Trade Entry Hour (0, 4,.., 20)
input int         openhours  = 13;       // Trade Duration Hours (12, 16, 20)
                                         // Money Mgmt
input string      N2=" --------- Money__Management ----------";
input string      N3="::Risk assessment based on % and stoploss size::";
input double      risk          =  0.5;//Risk %
double      Lots;
input double      TakeProfit    =  200.;
input double      StopLoss      =   80.;
input double      TrailingStop  =   40.;
//
input string      N4=" ------- Order Number Limits ----------";
input int         NumOpenOrders = 1; // Max Open Orders this Symbol
input int         TotOpenOrders = 8; // Max Open Orders All Symbols
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   Lots=calculateLotSize(StopLoss);
   int  trentry;
   datetime  bartime_previous;
   static datetime bartime_current;
   int hour_current;
   bool newperiod;
// Order Management parameters   
   double Take,Stop;
   double orderlots;
   string OrdComment;
   bool   BuySig,SellSig;
   int    OpenOrders,TrdType;
   double aoUp1,aoDn1;

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
      _spread=MarketInfo(_symbol,MODE_SPREAD);
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
      GetAOTrigger(BuySig,SellSig);

      //------- close trade based on new trigger or AO reversal pattern -------
      if(OpenOrders>=1 && CloseTrade)
        {
         TrdType=GetOpnTrdType();
         if(BuySig &&  TrdType==2) CloseSell(ProfitTypeClTrd);
         if(SellSig && TrdType==1) CloseBuy(ProfitTypeClTrd);
         //
         aoUp1 = iCustom (_symbol,0,"AwesomeV2",PeriodFast,PeriodSlow,1,1);
         aoDn1 = iCustom (_symbol,0,"AwesomeV2",PeriodFast,PeriodSlow,2,1);
         if(TrdType==2 && aoUp1 != 0.) CloseSell(ProfitTypeClTrd);
         if(TrdType==1 && aoDn1 != 0.) CloseBuy(ProfitTypeClTrd);
        }
      // ----------------------------------------------------------------------       
      // set trade entry flag trentry                  
      if( BuySig)  trentry=1;
      if( SellSig) trentry=2;
      //
      Take =  TakeProfit;
      Stop   =  StopLoss;
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
         if(CheckMoneyForTrade(_symbol,orderlots,trentry-1))
            OpenOrder(trentry,orderlots,Stop,Take,OrdComment,NumOpenOrders);
        } //  --------------- trentry ----------------------------------------------------   
     } // -------------------- end of if new bar ----------------------------------------------------
//                                                                       
// ---------------------------  every tic processing ------------------------------------------------
// ---------------------- Manage trailing stop at every tic for all open orders ---------------------
   if(OrdersTotal()==0) return;
//
   _symbol=Symbol();
   magic_number=MagicNumber;
   _point=MarketInfo(_symbol,MODE_POINT);
   _bid =    MarketInfo(_symbol,MODE_BID);
   _ask =    MarketInfo(_symbol,MODE_ASK);
   _digits=int(MarketInfo(_symbol,MODE_DIGITS));
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
//+---------------------------------------------------------------------------------------------+
void GetAOTrigger(bool &TBuy,bool &TSell)
//+----------------------------------------------------------+
//| Trigger return True or False for Buy and Sell            |
//+----------------------------------------------------------+
  {
   double stoc_1,stoc_2,stocSig_1,stoc_diff;
   double BB_Spread;
   double awUp[5]= {0.,0.,0.,0.,0.};
   double awDn[5]= {0.,0.,0.,0.,0.};
   double awMax,aw;
   int jj;
//
   TBuy=false;
   TSell=false;
//  
   BB_Spread=(iBands(_symbol,0,BBPeriod,2,0,PRICE_CLOSE,MODE_UPPER,1) -
              iBands(_symbol,0,BBPeriod,2,0,PRICE_CLOSE,MODE_LOWER,1))/(_point*MULT);
//
   if(BB_Spread<BBSprd_LwLim) return;
   if(BB_Spread>BBSprd_UpLim) return;
//
//
   stoc_1 =    iStochastic(_symbol,0,kStoc,dStoc,sStoc,MODE_SMA,0,MODE_MAIN, 1);
   stoc_2 =    iStochastic(_symbol,0,kStoc,dStoc,sStoc,MODE_SMA,0,MODE_MAIN, 2);
   stocSig_1 = iStochastic(_symbol,0,kStoc,dStoc,sStoc,MODE_SMA,0,MODE_SIGNAL, 1);
   stoc_diff = stoc_1-stoc_2;
// Accelerator Indicator (use iCustom to get at color buffers)
   awMax=-10000.;
   for(jj=0; jj<100; jj++)
     {
      aw=MathAbs(iCustom(_symbol,0,"AwesomeV2",PeriodFast,PeriodSlow,0,jj+1));
      if(aw>awMax) awMax=aw;
     }
   for(jj=0; jj<5; jj++)
     {
      awUp[jj] = iCustom (_symbol,0,"AwesomeV2",PeriodFast,PeriodSlow,1,jj+1)/awMax;
      awDn[jj] = iCustom (_symbol,0,"AwesomeV2",PeriodFast,PeriodSlow,2,jj+1)/awMax;
     }
//  earliest possible AO trigger 
   if(awDn[4]<0. && awDn[3]<0. && awDn[2]<0. && awDn[1]< awDn[2] && awUp[0]>awDn[1] &&
      awUp[0]<0. && stoc_1>Stoc_Lo && MathAbs(awUp[0])>awLimit) TBuy=true;
   if(awUp[4]>0. && awUp[3]>0. && awUp[2]>0. && awUp[1]> awUp[2] && awDn[0]<awUp[1] &&
      awDn[0]>0. && stoc_1<Stoc_Hi && MathAbs(awDn[0])>awLimit) TSell=true;

   return;
  }
// 
// --------------------------------------------------------------------------------  
// ******************* Trading Functions ***********************************************
bool CheckMoneyForTrade(string symb,double &olots,int type)
  {
// check limits of lot size
   if( olots<NormalizeDouble(MarketInfo(NULL,MODE_MINLOT),2) ){ olots=NormalizeDouble(MarketInfo(NULL,MODE_MINLOT),2); }
   if( olots>NormalizeDouble(MarketInfo(NULL,MODE_MAXLOT),2) ){ olots=NormalizeDouble(MarketInfo(NULL,MODE_MINLOT),2); }
//
   double free_margin=AccountFreeMarginCheck(symb,type,olots);
//-- if there is not enough money
   if(free_margin<=0.)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("** Not enough money for ",oper," ",olots," ",symb," Error code=",GetLastError());
      Print(" Account Margin ",AccountMargin(),"  Free Margin ",AccountFreeMargin());
      return(false);
     }
//--- checking successful
   return(true);
  }
//----------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------    
int GetOpnTrdType()
//+--------------------------------------------------------------------------+ 
//|  Return intger value of comment                                          |  
//+--------------------------------------------------------------------------+  
  {
   int cnt,total,TrdType;
   total=OrdersTotal();
   TrdType= 0;
   for(cnt=0;cnt<total;cnt++)
     {
      retval=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
        {
         if(OrderType()==OP_SELL ) TrdType=2;
         if(OrderType()==OP_BUY  ) TrdType=1;
         break;
        }
     }
   return(TrdType);
  }
// ----------------------------------------------------------------------------    

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
   closehour=lentryhour+lopenhours;
   if(closehour>23)wrap=true;
   closehour=int(MathMod((closehour),24));
   if( wrap && (hour_current<lentryhour && hour_current >closehour))  Hour_Test=false;
   if(!wrap && (hour_current<lentryhour || hour_current >closehour))  Hour_Test=false;
// 
   return(Hour_Test);
  }
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
      retval=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
        {
         if(OrderType()==OP_BUY) // ------- Manage long position ------
           {
            if(Trail_Stop>0.)
              {
               if((_bid-OrderOpenPrice())>MULT*_point*Trail_Stop)
                 {
                  if(((_bid-MULT*_point*Trail_Stop)-OrderStopLoss())>MULT*_point)
                    {
                     sl=NormalizeDouble(_bid-MULT*_point*Trail_Stop,_digits);
                     retval=OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,Green);
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
                  if((OrderStopLoss()-(_ask+MULT*_point*Trail_Stop))>MULT*_point)
                    {
                     sl=NormalizeDouble(_ask+MULT*_point*Trail_Stop,_digits);
                     retval=OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,Red);
                    }
                 }
              } // ---- end Trailing Stop for Sell  ------------------  
           }//------------- if OrderType = Sell --------------------------------
        }// ---------------- if OrderType ------------------------------------------------  
     }//----------------- loop ----------------------------------------------------------------            
   return;
  }
// ----------------------- end Manage Min Profit ---------------------------------------------- 
//------------------------------------------------------------------------------- 
void CloseBuy(int ProfType)
// +-------------------------------------------------------------------+
//| closes all long tickets - for selected symbol, magic number      |
//| Inputs: none,  Outputs: none                                       |
//| Globals: magic_number, _symbol, _bid, _ask                         |
//+--------------------------------------------------------------------+
  {
   int cnt,jj,total;
   double ord_profit;
   total=OrdersTotal();
   if(total == 0) return;
   cnt=-1;
   for(jj=0;jj<total; jj++)
     {
      cnt+=1;
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
           {
            ord_profit=OrderProfit();
            if(OrderType()==OP_BUY)
              {
               if(ProfType==0)retval=OrderClose(OrderTicket(),OrderLots(),_bid,3,Violet); // close long positions  
               if(ProfType==1 && ord_profit >= 0.) retval=OrderClose(OrderTicket(),OrderLots(),_bid,3,Violet); // close long positions 
               if(ProfType==2 && ord_profit <= 0.) retval=OrderClose(OrderTicket(),OrderLots(),_bid,3,Violet); // close long positions   
               cnt-=1;  // decrement order pointer after remval an order
              }
           }
        }  // orderselect
      if(OrdersTotal()==0) break;
     } // loop  
   return;
  }
//---------------------------------------------
void CloseSell(int ProfType)
// +-------------------------------------------------------------------+
//| closes all short tickets - for selected symbol, magic number      |
//| Inputs: none,  Outputs: none                                       |
//| Globals: magic_number, _symbol, _bid, _ask                         |
//+--------------------------------------------------------------------+
  {
   int cnt,jj,total;
   double ord_profit;
   total=OrdersTotal();
   if(total == 0) return;
   cnt=-1;
   for(jj=0;jj<total; jj++)
     {
      cnt+=1;
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
           {
            ord_profit=OrderProfit();
            if(OrderType()==OP_SELL)
              {
               if(ProfType==0) retval=OrderClose(OrderTicket(),OrderLots(),_ask,3,Violet); // close short positions
               if(ProfType==1 && ord_profit >= 0.) retval=OrderClose(OrderTicket(),OrderLots(),_ask,3,Violet); // close short positions
               if(ProfType==2 && ord_profit <= 0.) retval=OrderClose(OrderTicket(),OrderLots(),_ask,3,Violet); // close short positions 
               cnt-=1;  // decrement order pointer after remval an order
              }
           }
        }  // orderselect
     } // loop  
   return;
  }
//-----------------------------------------------------------------------------------------------     
//---------------------------------------------------------------------------------------------
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
double calculateLotSize(double _slcalc)
{
    double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
    double minLot  = MarketInfo(Symbol(), MODE_MINLOT); 
    double maxLot  = MarketInfo(Symbol(), MODE_MAXLOT);
    double tickVal = MarketInfo(Symbol(), MODE_TICKVALUE);
    double lotSize = AccountBalance() * risk / 100 / (_slcalc * tickVal);
 
    return MathMin(maxLot,MathMax(minLot,NormalizeDouble(lotSize / lotStep, 0) * lotStep)); 
}