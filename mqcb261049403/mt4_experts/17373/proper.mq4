// The Proper Bot
// Patrick Burns

#property strict


input string      a="* Signal settings:";
input int         MA_Fast_Period= 10;
input int         MA_Mid_Period = 25;
input int         MA_Slow_Period= 50;
input bool        MA_Disable=true;

input int         Volume_Minimum= 69;
input int         Volume_Period = 1;

input double      High_Level= 1.50001; // Do not buy above this level
input double      Low_Level = 1.40001; // Do not sell below this level 

input string      aa="* Grid Settings:";
input double      First_Lot= 0.08;
input string      Grid_Map = "120/0.1 120/0.11 120/0.12 120/0.13 120/0.14 120/0.15 120/0.16 120/0.17 120/0.18 120/0.19";

input string      aaa="* Order Settings:";
input int         Take_Profit=10000;
input int         Stop_Loss= 30000;
input int         Slippage = 20;

input string      aaaaaaaa="* Trade Hours:";
input int         Start_Hour=6;
input int         Start_Minute= 0;
input int         Finish_Hour = 21;
input int         Finish_Minute=0;

input string      aaaaaaaaa="* Profit Trail:";
input int         Trail_Start=52;    //Number of points of the trailing stop
input int         Trail_Distance=52; //Total points in profit trailing begins
input int         Trail_Step=2;

input string      aaaaaaaaaa="* EA Settings:";
input bool        Market_Execution=true;   // ECN, NDD etc
input int         Magic_Number=2013;
input bool        Write_Journal=true;

double
gd_SL,gd_TP,gd_One_Pip_Ratio,gd_Stop_Level,gd_Lots_Map[],gd_Distances_Map[];

int
gi_Slippage=20,gi_Connect_Wait=2,gi_Try_To_Trade=4,gi_Last_Index,gi_Second_From,gi_Second_To,gi_Trail_Start,gi_Trail_Distance,gi_Trail_Step;

string
gs_Symbol;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   gi_Slippage=Slippage;
   gs_Symbol=_Symbol;

// Points to prices:
   gd_One_Pip_Ratio=MathPow(10,Digits);
   gd_TP = Take_Profit / gd_One_Pip_Ratio;
   gd_SL = Stop_Loss / gd_One_Pip_Ratio;
   gd_Stop_Level=MarketInfo(gs_Symbol,MODE_STOPLEVEL)/gd_One_Pip_Ratio;

// Strings to double:
   string sa_Grid_Levels[];
   double da_Grid_Level[2];
   String_To_Array(Grid_Map,sa_Grid_Levels," ");
   int i_Grid_Level=ArraySize(sa_Grid_Levels);
   ArrayResize(gd_Distances_Map,i_Grid_Level);
   ArrayResize(gd_Lots_Map,i_Grid_Level);
   gi_Last_Index=i_Grid_Level-1;
   while(i_Grid_Level>0)
     {
      i_Grid_Level--;
      String_To_Double_Array(sa_Grid_Levels[i_Grid_Level],da_Grid_Level,"/");
      gd_Distances_Map[i_Grid_Level]=da_Grid_Level[0]/gd_One_Pip_Ratio;
      gd_Lots_Map[i_Grid_Level]=da_Grid_Level[1];
      //Print(i_Grid_Level, ": ", gd_Distances_Map[i_Grid_Level], " / ", gd_Lots_Map[i_Grid_Level]);
     }

   gi_Connect_Wait*=1000;
   gi_Second_From=3600*Start_Hour+60*Start_Minute;
   gi_Second_To=3600*Finish_Hour+60*Finish_Minute;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double
   d_Lot,d_Level=0,d_SL=0,d_TP=0,da_Orders_Data[61];// market orders data

   int
   i_Signal=0,i_Order,i_Value; // tmp value

   string s_String;

   static int
   si_Market_Orders=0,si_Max_Profit=-1000000,si_Phase=0;

// static bool sb_Alert = false; // alert was sent

   datetime
   t_Time_Now=TimeCurrent();

// Read all orders data:

   Get_Orders_Data(Magic_Number,da_Orders_Data,gs_Symbol,gd_One_Pip_Ratio);
   if(si_Market_Orders>da_Orders_Data[4]+da_Orders_Data[5])

     { // some orders was closed by TP/SL
      si_Market_Orders=int(da_Orders_Data[4]+da_Orders_Data[5]);
      si_Max_Profit=-1000000; // profit trail max nust be re-calculated
     }

   if(si_Phase==3)
     { // not all orders was closed
      if(da_Orders_Data[4]+da_Orders_Data[5]<1.0)si_Phase=0;

      else
        {
         if(KillEm(Magic_Number,gs_Symbol))si_Phase=0;
         return(1);
        }
     }

// Should we open the first order of the cycle?

   if(da_Orders_Data[4]+da_Orders_Data[5]<1.0)
     {
      si_Max_Profit=-1000000;
      si_Phase=0;

      // Check allowed trade session:

      if(!Is_Allowed_Hour(int(t_Time_Now),gi_Second_From,gi_Second_To))
         return(0); // sleep time

      // Get a signal:

      if(Volume_OK(Volume_Period,Volume_Minimum))

        {
         if(MA_Disable)
           {
            d_Level=Close[1]-Open[1];
            i_Signal=0;
            if(d_Level>0.0) i_Signal=1;
            else if(d_Level<0.0) i_Signal=-1;
           }
         else i_Signal=Get_Signal(MA_Fast_Period,MA_Mid_Period,MA_Slow_Period);
        }

      if(Ask>High_Level)i_Signal=0;
      if(Bid<Low_Level)i_Signal=0;
      if(Ask<Low_Level)i_Signal=2;
      if(Bid>High_Level)i_Signal=-1;
      if(i_Signal==0) return(0); // no signal, wait for the next tick

                                 // Define order type & levels:

      if(i_Signal>0)
        {
         i_Signal= OP_BUY;
         d_Level = Ask;
         d_SL = d_Level - gd_SL;
         d_TP = d_Level + gd_TP;

        }
      else
        {
         i_Signal= OP_SELL;
         d_Level = Bid;
         d_SL = d_Level + gd_SL;
         d_TP = d_Level - gd_TP;
        }

      // Check & normalize lot size:

      d_Lot=Get_Lot(0,0,0,First_Lot,gs_Symbol);

      if(d_Lot>0.0)
        {
         if(Write_Journal) Print("Cycle start");
         i_Order=Send_Order(gs_Symbol,Magic_Number,Market_Execution,gi_Try_To_Trade,gi_Connect_Wait,i_Signal,d_Lot,d_Level,gi_Slippage,"0",d_SL,d_TP);
         if(i_Order<0 && Write_Journal)
           {
            s_String=" Buy "; if(i_Signal==OP_SELL) s_String=" Sell ";
            Print("First step"+s_String+" error, Lot=",d_Lot," Level=",DoubleToStr(d_Level,Digits)," SL=",DoubleToStr(d_SL,Digits)," TP=",DoubleToStr(d_TP,Digits)," Ask=",DoubleToStr(Ask,Digits)," Bid=",DoubleToStr(Bid,Digits));
           }
         else si_Phase=1;
        }
      else if(Write_Journal) Print("Not enough money");

      return(1);
     }

// Trail:

   if(Trail_Distance>0)
     {
      if(da_Orders_Data[24]+da_Orders_Data[25]>Trail_Distance-Trail_Step)
        {
         i_Value=int(da_Orders_Data[24]+da_Orders_Data[25]);
         if(si_Max_Profit<i_Value)si_Max_Profit=i_Value;

         else
           {
            if(si_Max_Profit-i_Value>=Trail_Step)
              {
               if(Write_Journal) Print("Close by trail with profit (",i_Value," pp)");
               si_Phase=3;
               if(KillEm(Magic_Number,gs_Symbol,-10))si_Phase=0;
               return(1);
              }
           }
        }
     }

// Should we open the next one?

   int
   i_Grid_Level=int(da_Orders_Data[59]),i_Grid_Index=MathMin(gi_Last_Index,i_Grid_Level);

   i_Signal=-1;
   if(da_Orders_Data[12]>0.0)
     {
      if(Ask-da_Orders_Data[14]>=gd_Distances_Map[i_Grid_Index])
        {
         i_Signal= OP_SELL;
         d_Level = Bid;
         d_SL = d_Level + gd_SL;
         d_TP = d_Level - gd_TP;
        }
     }

   else
     {
      if(da_Orders_Data[14]-Bid>=gd_Distances_Map[i_Grid_Index])
        {
         i_Signal= OP_BUY;
         d_Level = Ask;
         d_SL = d_Level - gd_SL;
         d_TP = d_Level + gd_TP;
        }
     }

   if(i_Signal==-1) return(0);

   d_Lot=Get_Lot(0,0,0,gd_Lots_Map[i_Grid_Index],gs_Symbol);

   if(d_Lot==0.0)
     {
      if(Write_Journal) Print("Not enough money for step #",i_Grid_Level+2);
      return(0);
     }

   if(Write_Journal) Print("Level ",i_Grid_Level+2);
   i_Order=Send_Order(gs_Symbol,Magic_Number,Market_Execution,gi_Try_To_Trade,gi_Connect_Wait,i_Signal,d_Lot,d_Level,gi_Slippage,string(i_Grid_Level+1),d_SL,d_TP);
   if(i_Order<0 && Write_Journal)
     {
      s_String="Buy"; if(i_Signal==OP_SELL) s_String="Sell";
      Print("Step ",i_Grid_Level+2,": "+s_String+" error, Lot=",d_Lot," Level=",DoubleToStr(d_Level,Digits)," SL=",DoubleToStr(d_SL,Digits)," TP=",DoubleToStr(d_TP,Digits)," Ask=",DoubleToStr(Ask,Digits)," Bid=",DoubleToStr(Bid,Digits));
     }

   else si_Phase=1;
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Volume_OK(int i_Volume_Period,int i_Volume_Minimum)
  {
   if(i_Volume_Period < 1) return(true);
   double d_Value=0;

   int i_Value=i_Volume_Period;
   if(Bars>i_Value)
      while(i_Value>0)
        {
         i_Value--;
         d_Value+=double(Volume[i_Value]);
        }
   if(d_Value/i_Volume_Period<i_Volume_Minimum) return(false); // volume too low, no signal
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int Get_Signal(int i_MA_Fast_Period,int i_MA_Mid_Period,int i_MA_Slow_Period)
  {
   double
   d_Value,d_Slow=iMA(NULL,0,i_MA_Slow_Period,0,MODE_EMA,PRICE_CLOSE,1),d_Fast=iMA(NULL,0,i_MA_Fast_Period,0,MODE_EMA,PRICE_CLOSE,1);
   if(d_Slow==d_Fast)
      return(0);

   if(i_MA_Mid_Period<1)
     {
      if(d_Slow>d_Fast) return(-1);
      return(1);
     }

// Check middle EMA:

   d_Value=iMA(NULL,0,i_MA_Mid_Period,0,MODE_EMA,PRICE_CLOSE,1);

   if((d_Value>=d_Fast && d_Fast>d_Slow) || (d_Value<=d_Fast && d_Fast<d_Slow))
      return(0);

   if(d_Slow>d_Fast) return(-1);
   return(1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int Error_Handle(int iError)
  {
   switch(iError)
     {
      case 2: Print("Common error (", iError, ")"); return(0);
      case 4: Print("Trade server is busy (", iError, ")"); return(0);
      case 8: Print("Too frequent requests (", iError, ")"); return(0);
      case 129: Print("Invalid price (", iError, ")"); return(0);
      case 135: Print("Price changed (", iError, ")"); return(0);
      case 136: Print("Off quotes (", iError, ")"); return(0);
      case 137: Print("Broker is busy (", iError, ")"); return(0);
      case 138: Print("Requote (", iError, ")"); return(0);
      case 141: Print("Too many requests (", iError, ")"); return(0);
      case 146: Print("Trade context is busy (", iError, ")"); return(0);
      case 0: Print("No error returned (", iError, ")"); return(1);
      case 1: Print("No error returned, but the result is unknown (", iError, ")"); return(1);
      case 3: Print("Invalid trade parameters (", iError, ")"); return(1);
      case 6: Print("	No connection with trade server (", iError, ")"); return(1);
      case 128: Print("Trade timeout (", iError, ")"); return(1);
      case 130: Print("Invalid stops (", iError, ")"); return(1);
      case 131: Print("Invalid trade volume (", iError, ")"); return(1);
      case 132: Print("Market is closed (", iError, ")"); return(1);
      case 133: Print("Trade is disabled (", iError, ")"); return(1);
      case 134: Print("Not enough money (", iError, ")"); return(1);
      case 139: Print("Order is locked (", iError, ")"); return(1);
      case 145: Print("Modification denied because an order is too close to market (", iError, ")"); return(1);
      case 148: Print("The amount of opened and pending orders has reached the limit set by a broker (", iError, ")"); return(1);
      case 5: Print("Old version of the client terminal (", iError, ")"); return(2);
      case 7: Print("Not enough rights (", iError, ")"); return(2);
      case 9: Print("Malfunctional trade operation (", iError, ")"); return(2);
      case 64: Print("Account disabled (", iError, ")"); return(2);
      case 65: Print("Invalid account (", iError, ")"); return(2);
      case 140: Print("Long positions only allowed (", iError, ")"); return(2);
      case 147: Print("Expirations are denied by broker (", iError, ")"); return(2);
      case 149: Print("Hedge is prohibited (", iError, ")"); return(2);
      case 150: Print("Prohibited by FIFO Rule (", iError, ")"); return(2);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int Send_Order(string sSymbol,int iMagic,bool b_Market_Exec,int iAttempts,int iConnect_Wait,int iOrder_Type,double dLots,double dPrice,int iSlippage,string sComment="",double dSL=0,double dTP=0)
  {
   int
   iTry=iAttempts,i_Ticket=-1;

   while(iTry>0)
     {
      iTry--;

      if(IsTradeAllowed())
        {
         if(b_Market_Exec) i_Ticket=OrderSend(sSymbol,iOrder_Type,dLots,NormalizeDouble(dPrice,Digits),iSlippage,0,0,sComment,iMagic);
         else i_Ticket=OrderSend(sSymbol,iOrder_Type,dLots,NormalizeDouble(dPrice,Digits),iSlippage,dSL,dTP,sComment,iMagic);

         if(b_Market_Exec && i_Ticket>0 && (dSL<0.0 || dTP>0.0))
           {
            if(OrderSelect(i_Ticket,SELECT_BY_TICKET))
            if(OrderModify(OrderTicket(),OrderOpenPrice(),dSL,dTP,0)){}
           }
           } else {Sleep(1000*iConnect_Wait); continue;
        }

      if(i_Ticket>=0) break;
      switch(Error_Handle(GetLastError()))
        {
         case 0: Sleep(1000 * iConnect_Wait); RefreshRates(); break;
         case 1: return(i_Ticket);
         case 2: return(i_Ticket);
         case 3: return(-148);
        }
     }
   return(i_Ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Get_Orders_Data(int i_Magic,double &da_Orders_Data[],string s_Symbol="",double d_One_Pip_Ratio=0)
  {

   if(d_One_Pip_Ratio==0.0) d_One_Pip_Ratio=MathPow(10,MarketInfo(s_Symbol,MODE_DIGITS));
   ArrayInitialize(da_Orders_Data,0);
   da_Orders_Data[12]=-1;

   int
   iOrder=OrdersTotal();
   datetime   i_Last_Entry_Time=0;

   double
   d_Value;

   if(iOrder<1)
      return;

   while(iOrder>0)
     {
      iOrder--;
      if(OrderSelect(iOrder,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==s_Symbol || s_Symbol=="")
            if(OrderMagicNumber()==i_Magic || i_Magic==0)
              {
               d_Value=OrderProfit()+OrderSwap();
               if(d_Value>0)
                 {
                  da_Orders_Data[0]+=d_Value;
                  da_Orders_Data[2]+=1;
                 }
               else
                 {
                  da_Orders_Data[1]+=d_Value;
                  da_Orders_Data[3]+=1;
                 }
               if(i_Last_Entry_Time<OrderOpenTime() && OrderType()<2)
                 {
                  i_Last_Entry_Time=OrderOpenTime();
                  da_Orders_Data[12]=OrderType();
                  da_Orders_Data[13]=OrderLots();
                  da_Orders_Data[14]=OrderOpenPrice();
                  da_Orders_Data[15]=OrderTicket();
                  da_Orders_Data[59]=StrToDouble(OrderComment());
                  da_Orders_Data[60]=OrderProfit();
                 }
               switch(OrderType())
                 {
                  case OP_BUY:
                     da_Orders_Data[4]+=1;
                     da_Orders_Data[6]+=OrderLots();
                     da_Orders_Data[24]+=MarketInfo(s_Symbol,MODE_BID)-OrderOpenPrice();
                     da_Orders_Data[26]+=d_Value;
                     da_Orders_Data[28]+=OrderOpenPrice()-OrderStopLoss();

                     if(OrderOpenPrice()>da_Orders_Data[8])
                       {
                        da_Orders_Data[8]=OrderOpenPrice();
                        da_Orders_Data[16]=OrderTakeProfit();
                        da_Orders_Data[18]=OrderTicket();
                        da_Orders_Data[22]=StrToDouble(OrderComment());
                       }

                     if(OrderOpenPrice()<da_Orders_Data[9] || da_Orders_Data[9]==0.0)
                       {
                        da_Orders_Data[9]=OrderOpenPrice();
                        da_Orders_Data[19]=OrderTicket();
                        da_Orders_Data[56]=StrToDouble(OrderComment());
                       }
                     break;

                  case OP_SELL:
                     da_Orders_Data[5]+=1;
                     da_Orders_Data[7]+=OrderLots();
                     da_Orders_Data[25]+=OrderOpenPrice()-MarketInfo(s_Symbol,MODE_ASK);
                     da_Orders_Data[27]+=d_Value;
                     da_Orders_Data[29]+=OrderStopLoss()-OrderOpenPrice();

                     if(OrderOpenPrice()>da_Orders_Data[10])
                       {
                        da_Orders_Data[10]=OrderOpenPrice();
                        da_Orders_Data[20]=OrderTicket();
                        da_Orders_Data[57]=StrToDouble(OrderComment());
                       }

                     if(OrderOpenPrice()<da_Orders_Data[11] || da_Orders_Data[11]==0.0)
                       {
                        da_Orders_Data[11]=OrderOpenPrice();
                        da_Orders_Data[17]=OrderTakeProfit();
                        da_Orders_Data[21]=OrderTicket();
                        da_Orders_Data[23]=StrToDouble(OrderComment());
                       }
                     break;

                  case OP_BUYLIMIT:
                     da_Orders_Data[35]+=1;
                     if(OrderOpenPrice()>da_Orders_Data[37])
                       {
                        da_Orders_Data[37]=OrderOpenPrice();
                        da_Orders_Data[38]=OrderLots();
                       }

                     if(OrderOpenPrice()<da_Orders_Data[36] || da_Orders_Data[36]==0.0)
                       {
                        da_Orders_Data[36]=OrderOpenPrice();
                        da_Orders_Data[39]=OrderLots();
                        da_Orders_Data[51]=StrToDouble(OrderComment());
                       }
                     break;

                  case OP_SELLLIMIT:
                     da_Orders_Data[45]+=1;
                     if(OrderOpenPrice()>da_Orders_Data[47])
                       {
                        da_Orders_Data[47]=OrderOpenPrice();
                        da_Orders_Data[48]=OrderLots();
                        da_Orders_Data[53]=StrToDouble(OrderComment());
                       }

                     if(OrderOpenPrice()<da_Orders_Data[46] || da_Orders_Data[46]==0.0)
                       {
                        da_Orders_Data[46]=OrderOpenPrice();
                        da_Orders_Data[49]=OrderLots();
                       }
                     break;

                  case OP_BUYSTOP:
                     da_Orders_Data[30]+=1;
                     if(OrderOpenPrice()>da_Orders_Data[32])
                       {
                        da_Orders_Data[32]=OrderOpenPrice();
                        da_Orders_Data[33]=OrderLots();
                       }

                     if(OrderOpenPrice()<da_Orders_Data[31] || da_Orders_Data[31]==0.0)
                       {
                        da_Orders_Data[31]=OrderOpenPrice();
                        da_Orders_Data[34]=OrderLots();
                        da_Orders_Data[50]=StrToDouble(OrderComment());
                        da_Orders_Data[54]=OrderTicket();
                       }
                     break;

                  case OP_SELLSTOP:
                     da_Orders_Data[40]+=1;
                     if(OrderOpenPrice()>da_Orders_Data[42])
                       {
                        da_Orders_Data[42]=OrderOpenPrice();
                        da_Orders_Data[43]=OrderLots();
                        da_Orders_Data[52]=StrToDouble(OrderComment());
                        da_Orders_Data[55]=OrderTicket();
                       }

                     if(OrderOpenPrice()<da_Orders_Data[41] || da_Orders_Data[41]==0.0)
                       {
                        da_Orders_Data[41]=OrderOpenPrice();
                        da_Orders_Data[44]=OrderLots();
                       }
                     break;
                 }
              }
     }

   da_Orders_Data[24] *= d_One_Pip_Ratio;
   da_Orders_Data[25] *= d_One_Pip_Ratio;
   da_Orders_Data[28] *= d_One_Pip_Ratio;
   da_Orders_Data[29] *= d_One_Pip_Ratio;
   da_Orders_Data[60] *= d_One_Pip_Ratio;

   da_Orders_Data[58]=(da_Orders_Data[6]+da_Orders_Data[7])*d_One_Pip_Ratio;

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool KillEm(int iMagic,string s_Symbol="",int iOrder_Type=-1,int iClose_Type=0,int iExclude_Ticket=-1)
  {

   int
   iTry,iNet_Orders=0,i_Ticket=-1,ia_Tickets_A[40],ia_Tickets_B[40],i_Tickets_A=-1,i_Tickets_B=-1,iOrder=OrdersTotal();

   bool
   b_OK=true;

   if(iOrder<1) return(b_OK);

   double
   dNet_Profit=0;

   ArrayInitialize(ia_Tickets_A,0); ArrayInitialize(ia_Tickets_B,0);

   while(iOrder>0)
     {
      iOrder--;
      if(OrderSelect(iOrder,SELECT_BY_POS,MODE_TRADES))
         if(OrderTicket()==iExclude_Ticket) continue;
      else if(OrderSymbol()==s_Symbol || s_Symbol=="")
      if(OrderMagicNumber()==iMagic)
        {
         i_Ticket=-1;
         iTry=gi_Try_To_Trade;

         if(OrderType()==OP_BUY && (iOrder_Type==OP_BUY || iOrder_Type==-1 || iOrder_Type==-10))
           {
            if(iClose_Type>4)
              {
               i_Tickets_A++;
               ia_Tickets_A[i_Tickets_A]=OrderTicket();
              }
            else if(iClose_Type>0)
              {
               if(OrderProfit()>0.0)
                 {
                  i_Tickets_A++;
                  ia_Tickets_A[i_Tickets_A]=OrderTicket();
                 }
               else
                 {
                  i_Tickets_B++;
                  ia_Tickets_B[i_Tickets_B]=OrderTicket();
                 }
              }

            else if(!Close_Order(OrderTicket(),gi_Try_To_Trade,gi_Slippage)) b_OK=false;
           }
         else if(OrderType()==OP_SELL && (iOrder_Type==OP_SELL || iOrder_Type==-1 || iOrder_Type==-10))
           {
            if(iClose_Type>4)
              {
               i_Tickets_B++;
               ia_Tickets_B[i_Tickets_B]=OrderTicket();

              }
            else if(iClose_Type>0)
              {
               if(OrderProfit()>0.0)
                 {
                  i_Tickets_A++;
                  ia_Tickets_A[i_Tickets_A]=OrderTicket();
                 }
               else
                 {
                  i_Tickets_B++;
                  ia_Tickets_B[i_Tickets_B]=OrderTicket();
                 }
              }

            else if(!Close_Order(OrderTicket(),gi_Try_To_Trade,gi_Slippage)) b_OK=false;
           }
         else if(OrderType()>1 && (iOrder_Type==OrderType() || iOrder_Type==-1 || iOrder_Type==-20))
           {
            while(iTry>0)
              {
               iTry--;
               if(IsTradeAllowed()) if(OrderDelete(OrderTicket())) i_Ticket=1;
               else
                 {
                  Sleep(gi_Connect_Wait); continue;
                 }
               if(i_Ticket>=0) break;
               switch(Error_Handle(GetLastError()))
                 {
                  case 0: Sleep(gi_Connect_Wait); RefreshRates(); break;
                  case 1: Sleep(gi_Connect_Wait); RefreshRates(); break;
                  case 2: Sleep(gi_Connect_Wait); RefreshRates(); break;

                 }
              }

            if(i_Ticket>-1)
              {
               iNet_Orders++;
              }
            else
              {
               b_OK=false;
               if(Write_Journal) Print("Order deleting error #",OrderTicket()," OpenPrice=",OrderOpenPrice()," Bid=",MarketInfo(s_Symbol,MODE_BID)," Ask=",MarketInfo(s_Symbol,MODE_ASK));
              }
           }
        }
     }

   switch(iClose_Type)
     {
      case 0:
         return(b_OK);

      case 1:
         while(i_Tickets_A>-1)
           {
            if(!Close_Order(ia_Tickets_A[i_Tickets_A],gi_Try_To_Trade,gi_Slippage)) b_OK=false;
            i_Tickets_A--;
           }
         return(b_OK);

      case 2:
         while(i_Tickets_B>-1)
           {
            if(!Close_Order(ia_Tickets_B[i_Tickets_B],gi_Try_To_Trade,gi_Slippage)) b_OK=false;
            i_Tickets_B--;
           }
         return(b_OK);

      case 3:
         while(i_Tickets_B>-1)
           {
            if(!Close_Order(ia_Tickets_B[i_Tickets_B],gi_Try_To_Trade,gi_Slippage)) b_OK=false;
            i_Tickets_B--;
           }
         while(i_Tickets_A>-1)
           {
            if(!Close_Order(ia_Tickets_A[i_Tickets_A],gi_Try_To_Trade,gi_Slippage)) b_OK=false;
            i_Tickets_A--;
           }
         return(b_OK);

      case 4:
         while(i_Tickets_A>-1)
           {
            if(!Close_Order(ia_Tickets_A[i_Tickets_A],gi_Try_To_Trade,gi_Slippage)) b_OK=false;
            i_Tickets_A--;
           }
         while(i_Tickets_B>-1)
           {
            if(!Close_Order(ia_Tickets_B[i_Tickets_B],gi_Try_To_Trade,gi_Slippage)) b_OK=false;
            i_Tickets_B--;
           }
         return(b_OK);

      case 5:
         while(i_Tickets_A>-1)
           {
            if(!Close_Order(ia_Tickets_A[i_Tickets_A],gi_Try_To_Trade,gi_Slippage)) b_OK=false;
            i_Tickets_A--;
           }
         while(i_Tickets_B>-1)
           {
            if(!Close_Order(ia_Tickets_B[i_Tickets_B],gi_Try_To_Trade,gi_Slippage)) b_OK=false;
            i_Tickets_B--;
           }
         return(b_OK);

      case 6:
         while(i_Tickets_B>-1)
           {
            if(!Close_Order(ia_Tickets_B[i_Tickets_B],gi_Try_To_Trade,gi_Slippage)) b_OK=false;
            i_Tickets_B--;
           }
         while(i_Tickets_A>-1)
           {
            if(!Close_Order(ia_Tickets_A[i_Tickets_A],gi_Try_To_Trade,gi_Slippage)) b_OK=false;
            i_Tickets_A--;
           }
         return(b_OK);

      case 7:
         while((i_Tickets_A+1) *(i_Tickets_B+1)>0)
           {
            i_Ticket=MathMin(i_Tickets_A,i_Tickets_B);
            while(i_Ticket>-1)
              {
               if(!OrderCloseBy(ia_Tickets_B[i_Ticket],ia_Tickets_A[i_Ticket])) b_OK=false;
               i_Ticket--;
              }

            i_Tickets_A = -1;
            i_Tickets_B = -1;
            ArrayInitialize(ia_Tickets_A,0);
            ArrayInitialize(ia_Tickets_B,0);

            iOrder=OrdersTotal();
            while(iOrder>0)
              {
               iOrder--;
               if(OrderSelect(iOrder,SELECT_BY_POS,MODE_TRADES))
                  if(OrderTicket()==iExclude_Ticket) continue;
               else if(OrderSymbol()==s_Symbol || s_Symbol=="")
               if(OrderMagicNumber()==iMagic)
                 {
                  i_Ticket=-1;
                  if(OrderType()==OP_BUY)
                    {
                     i_Tickets_A++;
                     ia_Tickets_A[i_Tickets_A]=OrderTicket();
                    }
                  else if(OrderType()==OP_SELL)
                    {
                     i_Tickets_B++;
                     ia_Tickets_B[i_Tickets_B]=OrderTicket();
                    }
                 }
              }
           }

         while(i_Tickets_B>-1)
           {
            if(!Close_Order(ia_Tickets_B[i_Tickets_B],gi_Try_To_Trade,gi_Slippage)) b_OK=false;
            i_Tickets_B--;
           }
         while(i_Tickets_A>-1)
           {
            if(!Close_Order(ia_Tickets_A[i_Tickets_A],gi_Try_To_Trade,gi_Slippage)) b_OK=false;
            i_Tickets_A--;
           }
         return(b_OK);
     }

   return(b_OK);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Close_Order(int i_Ticket,int i_Try_To_Trade,int i_Slippage,double d_Lot=0)
  {

   if(!OrderSelect(i_Ticket,SELECT_BY_TICKET)) return(true);

   double dPrice;
   bool b_Done=false;
   while(i_Try_To_Trade>0)
     {
      i_Try_To_Trade--;
      dPrice=MarketInfo(OrderSymbol(),MODE_BID); if(OrderType()==OP_SELL) dPrice=MarketInfo(OrderSymbol(),MODE_ASK);
      if(d_Lot==0.0) d_Lot=OrderLots();
      if(IsTradeAllowed()) b_Done=OrderClose(OrderTicket(),d_Lot,dPrice,i_Slippage);
      else{Sleep(gi_Connect_Wait); continue;}
      if(b_Done) return(true);

      Print("Order closing error. Ticket=",OrderTicket()," Lot=",d_Lot," Price=",dPrice," Slippage=",i_Slippage," Ask=",MarketInfo(OrderSymbol(),MODE_ASK)," Bid=",MarketInfo(OrderSymbol(),MODE_BID));
      switch(Error_Handle(GetLastError()))
        {
         case 0: Sleep(gi_Connect_Wait); RefreshRates(); break;
         case 1: Sleep(gi_Connect_Wait); RefreshRates(); break;
         case 2: Sleep(gi_Connect_Wait); RefreshRates(); break;

        }
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Get_Lot(double dRisk_Percent,double dSL,double dLot_Ratio=0,double dLot_Value=0,string s_Symbol="")
  {

   if(s_Symbol=="") s_Symbol=_Symbol;

   double
   dLot,d_Lot_Min=MarketInfo(s_Symbol,MODE_MINLOT),d_Lot_Max=MarketInfo(s_Symbol,MODE_MAXLOT),d_Lot_Step=MarketInfo(s_Symbol,MODE_LOTSTEP),d_Lot_Margin=MarketInfo(s_Symbol,MODE_MARGINREQUIRED);

   if(dRisk_Percent>0.0)
      dLot=d_Lot_Step*MathFloor(dRisk_Percent*AccountFreeMargin()/100/dSL/MarketInfo(_Symbol,MODE_TICKVALUE)/d_Lot_Step);
   else dLot=d_Lot_Step*MathFloor(dLot_Value/d_Lot_Step);
   if(dLot==0) dLot=d_Lot_Step*MathFloor(dLot_Ratio*AccountFreeMargin()/100/MarketInfo(_Symbol,MODE_TICKVALUE)/d_Lot_Step);

   if(dLot<d_Lot_Min)
     {

      if(Write_Journal) Print("Calculated lot size (",dLot,") increased to server acceptable minimum (",d_Lot_Min,")");
      dLot=d_Lot_Min;
     }
   if(dLot>d_Lot_Max)
     {
      if(Write_Journal) Print("Calculated lot size (",dLot,") increased to server acceptable maximum (",d_Lot_Max,")");
      dLot=d_Lot_Max;
     }

   return (dLot);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Is_Allowed_Hour(int i_Time,int i_Second_From,int i_Second_To)
  {

   i_Time-=int(iTime(_Symbol,PERIOD_D1,0));

   if(i_Second_From<i_Second_To)
     {
      if(i_Time>=i_Second_From && i_Time<=i_Second_To)
         return(true);
        } else if(i_Second_From>i_Second_To) {
      if(i_Time>=i_Second_From || i_Time<=i_Second_To)
         return(true);
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void String_To_Array(string sInput,string &asOutput[],string sDelim)
  {
   ArrayResize(asOutput,0);
   int iStartPos=0;
   while(iStartPos<StringLen(sInput))
     {
      int iDelPos=StringFind(sInput,sDelim,iStartPos);
      string sNextElem;
      if(iDelPos<0)
        {
         sNextElem = StringSubstr(sInput, iStartPos);
         iStartPos = StringLen(sInput);
        }
      else
        {
         sNextElem = StringSubstr(sInput, iStartPos, iDelPos - iStartPos);
         iStartPos = iDelPos + 1;
        }
      ArrayResize(asOutput,ArraySize(asOutput)+1);
      asOutput[ArraySize(asOutput)-1]=sNextElem;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void String_To_Double_Array(string sInput,double &adOutput[],string sDelim)
  {

   ArrayResize(adOutput,0);
   int iStartPos=0;
   while(iStartPos<StringLen(sInput))
     {
      int iDelPos=StringFind(sInput,sDelim,iStartPos);
      string sNextElem;
      if(iDelPos<0)
        {
         sNextElem = StringSubstr(sInput, iStartPos);
         iStartPos = StringLen(sInput);
        }
      else
        {
         sNextElem = StringSubstr(sInput, iStartPos, iDelPos - iStartPos);
         iStartPos = iDelPos + 1;
        }
      ArrayResize(adOutput,ArraySize(adOutput)+1);
      adOutput[ArraySize(adOutput)-1]=StrToDouble(sNextElem);
     }
  }
//+------------------------------------------------------------------+
