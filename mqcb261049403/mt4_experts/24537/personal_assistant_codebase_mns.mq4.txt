//+------------------------------------------------------------------+
//|                                           PERSONAL_ASSISTANT.mq4 |
//|                             steph2203              INFINITE LOOP |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "INFINITE LOOP"
#property link      ""
#property version   "1.27"
#property strict
#property description "Personal assistant provides you" 
#property description "crucial information for " 
#property description "investment decisions and executes orders!"
#property description "Press 1 to BUY  / LONG "
#property description "Press 2 to SELL / SHORT "
#property description "Press 3 to CLOSE ALL (BUY+SELL) Manually "

#property description "button 4 -> increase current Lot volume (Lots in increments of 0.01)"
#property description "button 5 -> decrease current Lot volume (Lots in increments of 0.01)"
#property description "button 6 -> CLOSE BUY  position manually  "
#property description "button 7 -> CLOSE SELL position manually "
#property description "button 8 -> CLOSE ONLY PROFIT>0 position manually  "

/*
         button 1 -> open BUY position manually
         button 2 -> open SELL position manually
         button 3 -> CLOSE BUY or SELL position manually   
         button 4 -> increase current Lot volume (Lots in increments of 0.01)
         button 5 -> decrease current Lot volume (Lots in increments of 0.01) 
added    button 6 -> CLOSE BUY  position manually   
added    button 7 -> CLOSE SELL position manually   
added    button 8 -> CLOSE ONLY PROFIT>0 position manually   

*/

//+------------------------------------------------------------------+
//| User input variables                                             |
//+------------------------------------------------------------------+
input int MagicNo          = 200808;
input bool Display_legend  = true;   // true-Display Legend
input double LotSize       = 0.01;   // initial Lot 
input int slippage         = 2;

input int text_size        = 11;     // Legend text size 
input color text_color     = Gold;   // Legend Text Color
input int right_edge_shift = 850;    // distance to Right  
input int upper_edge_shift = 10;     // distance to Top  
// ADDED
input   double TakePR      = 100;    // Take Profit
input   double StopLS      = 500;    // Stop Loss

int  POPYTKY               = 10;
bool gbDisabled            = False;
double ttp, ssl;  

double      WHENTOMOVETOBE       = 20;       // pips after orderopenprice
int         PIPSTOMOVESL         = 10;       // How much pips to move sl
extern bool USE_TRAIL_STOP       = true;     // true-Enable "no loss"
int         MULT                 = 1;
double      Price[2];                        // Bid/Ask
int         giSlippage;
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
string EA_name       ="PA";
string global_Volume ="VOLUME";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   GlobalVariableSet(global_Volume,LotSize);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int z=1; z<=20; z++)
      ObjectDelete(ChartID(),EA_name+"_"+(string)z);
      GlobalVariableDel(global_Volume);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int x                   = 0,
       y                   = 0,
   open_position_counter   = 0,
   sl_counter              = 0,
   tp_counter              = 0;

   double EA_profit        = 0,
          EA_takeProfit    = 0,
          EA_StopLoss      = 0,
          EA_volume        = 0,
          EA_sl_volume     = 0,
          EA_tp_volume     = 0;
          
   string text             = "";

    if(Digits==5 || Digits==3) MULT=10.0;
// ----------------------    
    MOVETOBREAKEVEN();
// ----------------------


// Control over opened positions ** BY SYMBOL ** ADDED 
   for(int pos=0; pos<OrdersTotal(); pos++)
     {
      // select every order by position
      if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)&& (OrderSymbol() > Symbol()))
        {
         // check if order was set by this EA 
         if(OrderMagicNumber()==MagicNo)
           {
            open_position_counter++;

            EA_profit = EA_profit+OrderProfit();

            if(OrderTakeProfit()!=0)
              {
               EA_takeProfit = EA_takeProfit+MathAbs(OrderTakeProfit()-OrderOpenPrice())/_Point;
               EA_tp_volume  = EA_tp_volume+OrderLots();
               tp_counter++;
              }
            if(OrderStopLoss()!=0)
              {
               EA_StopLoss   = EA_StopLoss+MathAbs(OrderStopLoss()-OrderOpenPrice())/_Point;
               EA_sl_volume  = EA_sl_volume+OrderLots();
               sl_counter++;
              }
            EA_volume=EA_volume+OrderLots();
           }
        }
     }
//********************************************************************************************************************************
// Data display
   x = (int)(ChartGetInteger(ChartID(),CHART_WIDTH_IN_PIXELS,0) - right_edge_shift);
   y = upper_edge_shift;

/*
   text="EA id = "+EA_name+"  "+string(MagicNo);
   createObject(1,OBJ_LABEL,0,x,y,text);
*/
   text="Type & Period = "+_Symbol+" "+IntegerToString(_Period)+"M";
   createObject(2,OBJ_LABEL,0,x,y+upper_edge_shift,text);
/*
   text="Leverage = "+IntegerToString(AccountLeverage());
   createObject(3,OBJ_LABEL,0,x,y+upper_edge_shift*2,text);
*/
   text="Lot amount = "+DoubleToString(GlobalVariableGet(global_Volume),2);
   createObject(4,OBJ_LABEL,0,x,y+upper_edge_shift*3,text);

   text="Tick value = "+DoubleToString(MarketInfo(_Symbol,MODE_TICKVALUE)*GlobalVariableGet(global_Volume),3)+" "+AccountInfoString(ACCOUNT_CURRENCY);
   createObject(5,OBJ_LABEL,0,x,y+upper_edge_shift*4,text);

   text="Margin required = "+DoubleToString(MarketInfo(_Symbol,MODE_MARGINREQUIRED)*GlobalVariableGet(global_Volume),3);
   createObject(6,OBJ_LABEL,0,x,y+upper_edge_shift*5,text);

   text="Spread = "+DoubleToString(MarketInfo(_Symbol,MODE_SPREAD),2);
   createObject(7,OBJ_LABEL,0,x,y+upper_edge_shift*6,text);

   text="***************************************************";
   createObject(8,OBJ_LABEL,0,x,y+upper_edge_shift*7,text);

   text="Profit/Loss (sum) = "+DoubleToString(EA_profit,2);
   createObject(9,OBJ_LABEL,0,x,y+upper_edge_shift*8,text);

   text="Positions opened by EA = "+IntegerToString(open_position_counter);
   createObject(10,OBJ_LABEL,0,x,y+upper_edge_shift*9,text);

   if(tp_counter==0)
      text="TakeProfit (sum) = 0.00";
   else
   text="TakeProfit (sum) = "+DoubleToString(EA_takeProfit *(MarketInfo(_Symbol,MODE_TICKVALUE) *(EA_tp_volume/tp_counter)),2)+" set for "+
        IntegerToString(tp_counter)+"/"+IntegerToString(open_position_counter)+" orders.";

   createObject(11,OBJ_LABEL,0,x,y+upper_edge_shift*10,text);

   if(sl_counter==0)
      text="StopLoss (sum) = 0.00";
   else
     {
      text="StopLoss (sum) = "+DoubleToString(EA_StopLoss *(MarketInfo(_Symbol,MODE_TICKVALUE) *(EA_sl_volume/sl_counter)),2)+" set for "+
           IntegerToString(sl_counter)+"/"+IntegerToString(open_position_counter)+" orders.";
     }
   createObject(12,OBJ_LABEL,0,x,y+upper_edge_shift*11,text);

   if(Display_legend)
     {
      // LEGEND
      text="ACTION LEGEND:";
      createObject(13,OBJ_LABEL,0,x,y+upper_edge_shift*15,text);

      text="* Press 1 to open long position!";
      createObject(14,OBJ_LABEL,0,x,y+upper_edge_shift*16,text);

      text="* Press 2 to open short position!";
      createObject(15,OBJ_LABEL,0,x,y+upper_edge_shift*17,text);

      text="* Press 3 to close positions!";
      createObject(16,OBJ_LABEL,0,x,y+upper_edge_shift*18,text);

      text="* Press 4 to increase volume!";
      createObject(17,OBJ_LABEL,0,x,y+upper_edge_shift*19,text);

      text="* Press 5 to decrease volume!";
      createObject(18,OBJ_LABEL,0,x,y+upper_edge_shift*20,text);
     
      text="* Press 6 to CLOSE BUY orders!";
      createObject(19,OBJ_LABEL,0,x,y+upper_edge_shift*21,text);

      text="* Press 7 to CLOSE SELL orders!";
      createObject(20,OBJ_LABEL,0,x,y+upper_edge_shift*22,text);

      text="* Press 8 to CLOSE PROFIT++ orders!";
      createObject(21,OBJ_LABEL,0,x,y+upper_edge_shift*23,text);
     
     }
   
  }
//+------------------------------------------------------------------+
//| Custom create object function                                    |
//+------------------------------------------------------------------+
void createObject(int st_ID,ENUM_OBJECT obj,int window,int x,int y,string txt="")
  {
   ObjectCreate(EA_name+"_"+IntegerToString(st_ID),obj,window,0,0);
   ObjectSet(EA_name+"_"+IntegerToString(st_ID),OBJPROP_XDISTANCE,x);
   ObjectSet(EA_name+"_"+IntegerToString(st_ID),OBJPROP_YDISTANCE,y);
   ObjectSetText(EA_name+"_"+IntegerToString(st_ID),txt,text_size,"Arial",text_color);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   int x=0, y=0;
   string text="";

   x = (int)(ChartGetInteger(ChartID(),CHART_WIDTH_IN_PIXELS,0) - right_edge_shift);
   y = upper_edge_shift;

   if(id==CHARTEVENT_KEYDOWN)
     {
     

      // *********************************************************************************************
      // button 1
      if(lparam==49 || lparam==97)
        {
        
// ADDED TP SL         
       if(TakePR>0) ttp=(Ask + (0.25*TakePR*Point));else ttp=0;
       if(StopLS>0) ssl=(Bid - (4.25*StopLS*Point));else ssl=0;      
  
         if(OrderSend(_Symbol,OP_BUY,GlobalVariableGet(global_Volume),
            MarketInfo(_Symbol,MODE_ASK),slippage,ssl,ttp,
            EA_name+"  "+IntegerToString(MagicNo),MagicNo,0,clrNONE)>0)
            
            Print("Order BUY successfully opened for ",EA_name,"_",MagicNo);
         else
            Print("Order BUY unsuccessfull for ",EA_name,"_",MagicNo);

        }
      // *********************************************************************************************************************
      // button 2 
      if(lparam==50 || lparam==98)
        {

// ADDED TP SL          
          if(TakePR>0) ttp=(Bid - (0.25*TakePR*Point)); else ttp=0;
          if(StopLS>0) ssl=(Ask + (3.25*StopLS*Point)); else ssl=0;
         
         
         if(OrderSend(_Symbol,OP_SELL,GlobalVariableGet(global_Volume),
            MarketInfo(_Symbol,MODE_BID),slippage,ssl,ttp,
            EA_name+"-"+IntegerToString(MagicNo),MagicNo,0,clrNONE)>0)
          
            Print("Order SELL successfully opened for ",EA_name,"_",MagicNo);
         else
            Print("Order SELL unsuccessfull for ",EA_name,"_",MagicNo);

        }
      // *********************************************************************************************************************
      // button 3 
      if(lparam==51 || lparam==99)
        {
         for(int pos=0; pos<OrdersTotal(); pos++)
            if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)&& (OrderSymbol() > Symbol()))
               if(OrderMagicNumber()==MagicNo)
                 {
                  if(OrderType()==OP_BUY)
                     if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),slippage,clrNONE))
                        Print(OrderTicket()," closed successfully for ",EA_name,"_",MagicNo);
                  else
                     Print(OrderTicket()," closed unsuccessfully for ",EA_name,"_",MagicNo);

                  if(OrderType()==OP_SELL)
                     if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),slippage,clrNONE))
                        Print(OrderTicket()," closed successfully for ",EA_name,"_",MagicNo);
                  else
                     Print(OrderTicket()," closed unsuccessfully for ",EA_name,"_",MagicNo);
                 }
        }
      // *********************************************************************************************************************
      // button 4 
      if(lparam==52 || lparam==100)
        {
         if(GlobalVariableGet(global_Volume) >= 0.10) // 8.00
            Alert("Coution, extreme volume!");
         else
           {
            GlobalVariableSet(global_Volume,GlobalVariableGet(global_Volume)+0.01);

            text="Lot amount = "+DoubleToString(GlobalVariableGet(global_Volume),2);
            createObject(4,OBJ_LABEL,0,x,y+upper_edge_shift*3,text);

            text="Tick value = "+DoubleToString(MarketInfo(_Symbol,MODE_TICKVALUE)*GlobalVariableGet(global_Volume),3)+" "+AccountInfoString(ACCOUNT_CURRENCY);
            createObject(5,OBJ_LABEL,0,x,y+upper_edge_shift*4,text);

            text="Margin required = "+DoubleToString(MarketInfo(_Symbol,MODE_MARGINREQUIRED)*GlobalVariableGet(global_Volume),3);
            createObject(6,OBJ_LABEL,0,x,y+upper_edge_shift*5,text);
           }
        }
      // *********************************************************************************************************************
      // button 5 
      if(lparam==53 || lparam==101)
        {

         if(GlobalVariableGet(global_Volume) <= 0.01)
            Alert("Volume is at minimum, it can not be decreased!");
         else
           {
            GlobalVariableSet(global_Volume,GlobalVariableGet(global_Volume)-0.01);

            text="Lot amount = "+DoubleToString(GlobalVariableGet(global_Volume),2);
            createObject(4,OBJ_LABEL,0,x,y+upper_edge_shift*3,text);

            text="Tick value = "+DoubleToString(MarketInfo(_Symbol,MODE_TICKVALUE)*GlobalVariableGet(global_Volume),3)+" "+AccountInfoString(ACCOUNT_CURRENCY);
            createObject(5,OBJ_LABEL,0,x,y+upper_edge_shift*4,text);

            text="Margin required = "+DoubleToString(MarketInfo(_Symbol,MODE_MARGINREQUIRED)*GlobalVariableGet(global_Volume),3);
            createObject(6,OBJ_LABEL,0,x,y+upper_edge_shift*5,text);
           }
        }

      // button 6 CLOSE BUY orders
      if(lparam==54 || lparam==102)
        {
         for(int pos=0; pos<OrdersTotal(); pos++)
            if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)&& (OrderSymbol() > Symbol()))
               if(OrderMagicNumber()==MagicNo)
                 {
                  if(OrderType()==OP_BUY)
                     if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),slippage,clrNONE))
                        Print(OrderTicket()," closed successfully for ",EA_name,"_",MagicNo);
                  else
                     Print(OrderTicket()," closed unsuccessfully for ",EA_name,"_",MagicNo);
                 }
        }        
      // button 7 CLOSE SELL orders
      if(lparam==55 || lparam==103)
        {
         for(int pos=0; pos<OrdersTotal(); pos++)
            if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)&& (OrderSymbol() > Symbol()))
               if(OrderMagicNumber()==MagicNo)
                 {
                  if(OrderType()==OP_SELL)
                     if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),slippage,clrNONE))
                        Print(OrderTicket()," closed successfully for ",EA_name,"_",MagicNo);
                  else
                     Print(OrderTicket()," closed unsuccessfully for ",EA_name,"_",MagicNo);
                 }
         }        

      // button 8 CLOSE PROFITABLE orders
      if(lparam==56 || lparam==104)
        {
         for(int pos=0; pos<OrdersTotal(); pos++)
            if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES) && (OrderProfit() > 0) && (OrderSymbol() > Symbol()) ) 
            {
               if(OrderMagicNumber()==MagicNo)
                 {
                  if((OrderType()<=OP_SELL) && GetMarketInfo()) 
                  {
                   if(!OrderClose(OrderTicket(),OrderLots(),Price[1-OrderType()],giSlippage)) Print(OrderError());
                  }                 
                }
                
             }           
   
         } // button 8 end

    } 
  }
//+------------------------------------------------------------------+
int OpenPosition(string sy, int op, double ll, double ssl=0, double ttp=0, int mn=0, string cm ="") 
 {
  color    clOpen;
  datetime ot;
  double   pp, pa, pb;
  int      dg, err, it, ticket=0;
  string   lsComm="MZS";
 
  if (sy=="" || sy=="0") sy=Symbol();
  if (op==OP_BUY) clOpen=Lime; else clOpen=Red;
  for (it=1; it<=POPYTKY; it++) 
   { 
    if (!IsTesting() && (!IsExpertEnabled() || IsStopped())) {
      Print("OpenPosition(): işlem açılamadı");
      break;  }
      
    while (!IsTradeAllowed()) Sleep(5000);
    RefreshRates();
    dg=(int)MarketInfo(sy, MODE_DIGITS);
    pa=MarketInfo(sy, MODE_ASK);
    pb=MarketInfo(sy, MODE_BID);
    if (op==OP_BUY) pp=pa; else pp=pb;
    pp=NormalizeDouble(pp, dg);
    ot=TimeCurrent();
//----+
    if(AccountFreeMarginCheck(Symbol(),op, ll)<=0 || GetLastError()==134)return(0);    
//----+ 
    ticket=OrderSend(sy, op, ll, pp, slippage, ssl, ttp, lsComm, mn, 0, clOpen);
    if (ticket>0) 
    {
      if (op==OP_BUY) PlaySound("ok.wav"); break;
    } 
    else 
    {
      err=GetLastError();
      if (pa==0 && pb==0) Print("Symbol not Found " + sy);
      PlaySound("error.wav");
      
      Print("Error(",err,") opening position :" + string(op) + " , try ",it);
      Print("Ask=",pa," Bid=",pb," sy=",sy," ll=",ll," op=", op,
            " pp=",pp," sl=",ssl," tp=",ttp," mn=",mn);
            
      // is EA blocked ?
      if (err==2 || err==64 || err==65 || err==133) 
      {
        gbDisabled=True; break;
      }
      // wait a while
      if (err==4 || err==131 || err==132) {
        Sleep(1000*300); break;
      }
      if (err==128 || err==142 || err==143) {
        Sleep(1000*66.666);
        if (ExistPositions(sy, op, mn, ot)) {
          PlaySound("ok.wav"); break;
        }
      }
      if (err==140 || err==148 || err==4110 || err==4111) break;
      if (err==141) Sleep(1000*100);
      if (err==145) Sleep(1000*17);
      if (err==146) while (IsTradeContextBusy()) Sleep(1000*11);
      if (err!=135) Sleep(1000*7.7);
    }
  }
  return(ticket);
}
//---------------------------------------------------------------------
// ExistPositions
//---------------------------------------------------------------------
bool ExistPositions(string sy="", int op=-1, int mn=-1, datetime ot=0) 
{
  int i, k= OrdersTotal();
 
  if (sy=="0") sy=Symbol();
  for (i=0; i<k; i++) 
  {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
     {
      if (OrderSymbol()==sy || sy=="") 
      {
        if (OrderType()==OP_BUY || OrderType()==OP_SELL) 
        {
          if (op<0 || OrderType()==op) 
          {
            if (mn<0 || OrderMagicNumber()==mn)
             {
              if (ot<=OrderOpenTime()) return(True);
             }
          }
        }
      }
    }
  }

  return(False);
 }

//+---------------------------------------------------------------------------+
//|                          MOVE TO BREAK EVEN                               |
//+---------------------------------------------------------------------------+
void MOVETOBREAKEVEN()
  {
    int b,s;
    double ticksize = MarketInfo(Symbol(),MODE_TICKSIZE);
    double pips     = ticksize*MULT;

   for(int b=OrdersTotal()-1;b>=0;b--)
     {
      if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()!=MagicNo)continue;
      if(OrderSymbol()==Symbol())
         if(OrderType()==OP_BUY)
            if(Bid-OrderOpenPrice()>WHENTOMOVETOBE*pips)
               if(OrderOpenPrice()>OrderStopLoss())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(PIPSTOMOVESL*pips),OrderTakeProfit(),0,CLR_NONE))
                     Print(" * Error * ");
     }

   for(int s=OrdersTotal()-1;s>=0;s--)
     {
      if(OrderSelect(s,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()!=MagicNo)continue;
      if(OrderSymbol()==Symbol())
         if(OrderType()==OP_SELL)
            if(OrderOpenPrice()-Ask>WHENTOMOVETOBE*pips)
               if(OrderOpenPrice()<OrderStopLoss())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-(PIPSTOMOVESL*pips),OrderTakeProfit(),0,CLR_NONE))
                     Print(" * Error * ");
     }
   
  }
  
//+------------------------------------------------------------------+
//| Function..: GetMarketInfo                                        |
//| Returns...: bool Success.                                        |
//+------------------------------------------------------------------+
bool GetMarketInfo() 
 {
  RefreshRates();
  Price[0]=MarketInfo(OrderSymbol(),MODE_ASK);
  Price[1]=MarketInfo(OrderSymbol(),MODE_BID);
  double dPoint=MarketInfo(OrderSymbol(),MODE_POINT);
  if(dPoint==0) return(false);
  giSlippage=(Price[0]-Price[1])/dPoint;
  return(Price[0]>0.0 && Price[1]>0.0);
 }  
 
//+------------------------------------------------------------------+
//| Function..: OrderError                                           |
//+------------------------------------------------------------------+
string OrderError() 
 {
  int iError=GetLastError();
  return(StringConcatenate("Order:",OrderTicket()," GetLastError()=",iError," "));
 } 

//+------------------------------------------------------------------+