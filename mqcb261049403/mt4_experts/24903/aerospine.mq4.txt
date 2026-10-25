//+------------------------------------------------------------------+
//|                                                        A_R_N.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
#property copyright "gbengas"
#property link      "free "
#property version   "1.00"
#property strict
extern int BreakEven =39;
extern int MagicNumber = 112918;
extern double lots = 0.01;
extern double step = 900.0;
extern double stepi = 100.0;
int lac ;
static datetime LastTrade=0;
extern bool display = true;
bool Ks;
extern int X = 400;
extern int Y = 20;
int max_loss[10], max_win[10];
extern bool use_breakeven = true;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      PlotLabel("ffg",True,0,0,40,200,"SPREAD = "+DoubleToStr(MarketInfo(_Symbol,MODE_SPREAD),0)+ "   Digit = "+DoubleToStr(MarketInfo(Symbol(),MODE_DIGITS),0),White,11,"Arimo",0,false,0);
 //  if(AccountCompany() != "NPBFX Limited" || Symbol() != "XAUUSD.mm"){
 //  Alert( "Wrong Application,  "+AccountCompany()+"NOT accepted (Only Instanforex And XAUUSD is Allowed)"); 
  // ExpertRemove();}
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
        PlotLabel("timeofday",True,0,0,200,50,"Time = "+DoubleToStr(Hour(),0)+ ":"+DoubleToStr(Minute(),0),White,11,"Arimo",0,false,0);

  if(Digits==2 || Digits==4)lac = 0.1; else lac =1.0;
//---
  // ResetLastError();
    // ResetLastError();
  if(Period() <1440){Alert("Only works Daily Charts"); return;}
//  if(Symbol() != "EURUSD" || Symbol() != "GBPJPY" || Symbol() != "EURUSD" || Symbol() != "EURUSD" 
   if( GetLastError() == 134 ) return;// 
  if(MarketInfo(Symbol(),MODE_SPREAD)>25)return;
   int consecutive_win =0,  consecutive_loss = 0, typ_last_win = -1;
   double last_LOT = 0, last_WIN = 0, last_OOP = 0;; 
   datetime  last_OCT_win  = -1 ; int last_number     = -1;
   int typ_last_loss  = -1; datetime last_OCT_loss  = -1; 
   double lot = MathMax(NormalizeDouble(0.00001*AccountEquity(),2),MarketInfo(Symbol(),MODE_MINLOT));
    
   if(use_breakeven)  MoveBreakEven(MagicNumber);
   for(int i=0; i <OrdersHistoryTotal(); i++) 
       {
        if( OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true  &&
             OrderMagicNumber() == MagicNumber )
           {
              if( OrderProfit() > 0 )
                { 
                 consecutive_win  ++;  
                 consecutive_loss = 0;   
                 typ_last_win     =  OrderType() ;
                 last_LOT         =  OrderLots();
                 last_WIN        =  OrderProfit(); 
                 last_OCT_win    =  OrderCloseTime();
                 last_OOP        = OrderOpenPrice();
                 last_number     = i+1;
                 }
              if( OrderProfit() < 0 )
                 { 
                  consecutive_loss ++; 
                  consecutive_win  = 0; 
                  typ_last_loss  =  OrderType() ;
                  last_LOT         =  OrderLots();
                  last_WIN        =  OrderProfit();   
                  last_OCT_loss   =  OrderCloseTime();
                  last_OOP        = OrderOpenPrice();
                  last_number = i+1;
                  }   
               }    
             }      
  
   if( last_number == 100 )  OnDeinit(134);
  
  
    if( max_loss[0] < consecutive_loss) max_loss[0] = consecutive_loss;
    if( max_win[0] < consecutive_win)  max_win[0] = consecutive_win;
      
       string way;
      if(  typ_last_loss == 0 ) way = "buy"; else if(  typ_last_loss == 1) way = "sell";
        string Nom_EA ="GGG_Macon";
     
//-----------------------------------------------------------
     string last_order, genre; 
     
     // last order win or loss ? 
       
       if( last_OCT_win < last_OCT_loss ) 
          {    
           last_order = "Loss ";
          if( typ_last_loss == 0 && iOpen(NULL,PERIOD_D1,0)-(stepi*lac/2)*Point>Ask ) { genre ="  Buy ";   Open_Order( OP_SELL, last_LOT+lot); }
          if( typ_last_loss == 1 && iOpen(NULL,PERIOD_D1,0)+(stepi*lac/2)*Point <Bid ) { genre = "  Sell "; Open_Order( OP_BUY, last_LOT+lot); }
          }     
//  ---------------    INFO  ------------------------------- 
         
  //========  first order ===============================================  
       if( counts() == 0 && Hour() >=18 && Time[0] != LastTrade )
         {
         if(iOpen(NULL,PERIOD_D1,0)+stepi*Point <Bid&&Volume[0]>10000 ) Open_Order( OP_BUY,  lot );
         if( iOpen(NULL,PERIOD_D1,0)-stepi*Point>Ask&&Volume[0]>10000 ) Open_Order( OP_SELL, lot ); 
         LastTrade = Time[0]; 
         }
      //   MoveBreakEven(MagicNumber);
          if(iOpen(NULL,PERIOD_D1,0)+(stepi*lac / 100)*Point <Bid ) Closesell_Order(MagicNumber);
         if( iOpen(NULL,PERIOD_D1,0)-(stepi*lac / 100) *Point>Ask )  Closebuy_Order(MagicNumber );  
      
 //=================================================================
  int buy = 0, sell = 0; double profit_buy = 0, profit_sell = 0;
  int j=-1, i= -1; double tot_oop_buy = 0, tot_oop_sell = 0;
//================================================================== 
   j=OrdersTotal()-1;
 for (i=j;i>=0;i--)   {
  if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) continue;
   if(OrderMagicNumber()==MagicNumber && OrderSymbol()==Symbol())
      {  if( OrderType()== OP_BUY )
           { /* if(Hour()>20 && Minute()>55)Ks = OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),8,White);*/ }
         if( OrderType()== OP_SELL )
            { /* if(Hour()>20 && Minute()>55) Ks = OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),8,White);*/ }
    } 
  //  PlotLabel("odd",True,0,0,200,10,DoubleToStr(TimeCurrent(),0),White,11,"Arimo",0,false,0);
   // PlotLabel("oddi",True,0,0,200,30,DoubleToStr(OrderOpenTime(),0),White,11,"Arimo",0,false,0);

     }   
   //------------------------------------------------------------------------------ 
  if(display){ string sufix = StringSubstr(Symbol(),6,StringLen(Symbol()));           
      
      PlotLabel("s1",True,0,0,X+100,Y,"PERFORMANCE CHART",Gray,14,"Arial",0,false,0);    
      PlotLabel("s2",True,0,0,X,Y+20,"Symbol      Daily         Weekly        Monthly         Total",Blue,14,"Arial",0,false,0);    
      PlotLabel("s3",True,0,0,X,Y+40,"EURUSD ",Gray,12,"Arial",0,false,0);    
      PlotLabel("s4",True,0,0,X,Y+60,"GBPUSD ",Gray,12,"Arial",0,false,0); 
      PlotLabel("s5",True,0,0,X,Y+80,"USDJPY ",Gray,12,"Arial",0,false,0);    
      PlotLabel("s6",True,0,0,X,Y+100,"EURJPY ",Gray,12,"Arial",0,false,0);    
      PlotLabel("s7",True,0,0,X,Y+120,"AUDUSD ",Gray,12,"Arial",0,false,0);    
      PlotLabel("s8",True,0,0,X,Y+140,"NZDUSD ",Gray,12,"Arial",0,false,0);    
      PlotLabel("s9",True,0,0,X,Y+160,"EURCHF ",Gray,12,"Arial",0,false,0);    
      PlotLabel("s10",True,0,0,X,Y+180,"USDCHF ",Gray,12,"Arial",0,false,0);    
      PlotLabel("s11",True,0,0,X,Y+200,"EURGBP ",Gray,12,"Arial",0,false,0);    
      PlotLabel("s12",True,0,0,X,Y+220,"GBPJPY ",Gray,12,"Arial",0,false,0);
      PlotLabel("s12b",True,0,0,X,Y+240,"USDCAD ",Gray,12,"Arial",0,false,0);
      PlotLabel("XAUUSD",True,0,0,X,Y+260,"XAUUSD ",White,12,"Verdana",0,false,0);

    
            PlotLabel("s1223",True,0,0,X+100,Y+40,DoubleToStr(netprofit("EURUSD"+sufix,24),2),COLO(netprofit("EURUSD"+sufix,24)),12,"Arial",0,false,0);
            PlotLabel("s14",True,0,0,X+200,Y+40,DoubleToStr(netprofit("EURUSD"+sufix,120),2),COLO(netprofit("EURUSD"+sufix,120)),12,"Arial",0,false,0);
            PlotLabel("s15",True,0,0,X+300,Y+40,DoubleToStr(netprofit("EURUSD"+sufix,720),2),COLO(netprofit("EURUSD"+sufix,720)),12,"Arial",0,false,0);
            PlotLabel("s16",True,0,0,X+400,Y+40,DoubleToStr(netprofit2("EURUSD"+sufix),2),COLO(netprofit2("EURUSD"+sufix)),12,"Arial",0,false,0);

            PlotLabel("s17",True,0,0,X+100,Y+60,DoubleToStr(netprofit("GBPUSD"+sufix,24),2),COLO(netprofit("GBPUSD"+sufix,24)),12,"Arial",0,false,0);
            PlotLabel("s18",True,0,0,X+200,Y+60,DoubleToStr(netprofit("GBPUSD"+sufix,120),2),COLO(netprofit("GBPUSD"+sufix,120)),12,"Arial",0,false,0);
            PlotLabel("s19",True,0,0,X+300,Y+60,DoubleToStr(netprofit("GBPUSD"+sufix,720),2),COLO(netprofit("GBPUSD"+sufix,720)),12,"Arial",0,false,0);
            PlotLabel("s20",True,0,0,X+400,Y+60,DoubleToStr(netprofit2("GBPUSD"+sufix),2),COLO(netprofit2("GBPUSD"+sufix)),12,"Arial",0,false,0);

            PlotLabel("s213",True,0,0,X+100,Y+80,DoubleToStr(netprofit("USDJPY"+sufix,24),2),COLO(netprofit("USDJPY"+sufix,24)),12,"Arial",0,false,0);
            PlotLabel("s214",True,0,0,X+200,Y+80,DoubleToStr(netprofit("USDJPY"+sufix,120),2),COLO(netprofit("USDJPY"+sufix,120)),12,"Arial",0,false,0);
            PlotLabel("s215",True,0,0,X+300,Y+80,DoubleToStr(netprofit("USDJPY"+sufix,720),2),COLO(netprofit("USDJPY"+sufix,720)),12,"Arial",0,false,0);
            PlotLabel("s216",True,0,0,X+400,Y+80,DoubleToStr(netprofit2("USDJPY"+sufix),2),COLO(netprofit2("USDJPY"+sufix)),12,"Arial",0,false,0);

            PlotLabel("s313",True,0,0,X+100,Y+100,DoubleToStr(netprofit("EURJPY"+sufix,24),2),COLO(netprofit("EURJPY"+sufix,24)),12,"Arial",0,false,0);
            PlotLabel("s314",True,0,0,X+200,Y+100,DoubleToStr(netprofit("EURJPY"+sufix,120),2),COLO(netprofit("EURJPY"+sufix,120)),12,"Arial",0,false,0);
            PlotLabel("s315",True,0,0,X+300,Y+100,DoubleToStr(netprofit("EURJPY"+sufix,720),2),COLO(netprofit("EURJPY"+sufix,720)),12,"Arial",0,false,0);
            PlotLabel("s316",True,0,0,X+400,Y+100,DoubleToStr(netprofit2("EURJPY"+sufix),2),COLO(netprofit2("EURJPY"+sufix)),12,"Arial",0,false,0);

            PlotLabel("s13",True,0,0,X+100,Y+120,DoubleToStr(netprofit("AUDUSD"+sufix,24),2),COLO(netprofit("AUDUSD"+sufix,24)),12,"Arial",0,false,0);
            PlotLabel("s414",True,0,0,X+200,Y+120,DoubleToStr(netprofit("AUDUSD"+sufix,120),2),COLO(netprofit("AUDUSD"+sufix,120)),12,"Arial",0,false,0);
            PlotLabel("s415",True,0,0,X+300,Y+120,DoubleToStr(netprofit("AUDUSD"+sufix,720),2),COLO(netprofit("AUDUSD"+sufix,720)),12,"Arial",0,false,0);
            PlotLabel("s416",True,0,0,X+400,Y+120,DoubleToStr(netprofit2("AUDUSD"+sufix),2),COLO(netprofit2("AUDUSD"+sufix)),12,"Arial",0,false,0);

            PlotLabel("s513",True,0,0,X+100,Y+140,DoubleToStr(netprofit("NZDUSD"+sufix,24),2),COLO(netprofit("NZDUSD"+sufix,24)),12,"Arial",0,false,0);
            PlotLabel("s514",True,0,0,X+200,Y+140,DoubleToStr(netprofit("NZDUSD"+sufix,120),2),COLO(netprofit("NZDUSD"+sufix,120)),12,"Arial",0,false,0);
            PlotLabel("s515",True,0,0,X+300,Y+140,DoubleToStr(netprofit("NZDUSD"+sufix,720),2),COLO(netprofit("NZDUSD"+sufix,720)),12,"Arial",0,false,0);
            PlotLabel("s516",True,0,0,X+400,Y+140,DoubleToStr(netprofit2("NZDUSD"+sufix),2),COLO(netprofit2("NZDUSD"+sufix)),12,"Arial",0,false,0);

            PlotLabel("s613",True,0,0,X+100,Y+160,DoubleToStr(netprofit("EURCHF"+sufix,24),2),COLO(netprofit("EURCHF"+sufix,24)),12,"Arial",0,false,0);
            PlotLabel("s614",True,0,0,X+200,Y+160,DoubleToStr(netprofit("EURCHF"+sufix,120),2),COLO(netprofit("EURCHF"+sufix,120)),12,"Arial",0,false,0);
            PlotLabel("s615",True,0,0,X+300,Y+160,DoubleToStr(netprofit("EURCHF"+sufix,720),2),COLO(netprofit("EURCHF"+sufix,720)),12,"Arial",0,false,0);
            PlotLabel("s616",True,0,0,X+400,Y+160,DoubleToStr(netprofit2("EURCHF"+sufix),2),COLO(netprofit2("EURCHF"+sufix)),12,"Arial",0,false,0);

            PlotLabel("s713",True,0,0,X+100,Y+180,DoubleToStr(netprofit("USDCHF"+sufix,24),2),COLO(netprofit("USDCHF"+sufix,24)),12,"Arial",0,false,0);
            PlotLabel("s714",True,0,0,X+200,Y+180,DoubleToStr(netprofit("USDCHF"+sufix,120),2),COLO(netprofit("USDCHF"+sufix,120)),12,"Arial",0,false,0);
            PlotLabel("s715",True,0,0,X+300,Y+180,DoubleToStr(netprofit("USDCHF"+sufix,720),2),COLO(netprofit("USDCHF"+sufix,720)),12,"Arial",0,false,0);
            PlotLabel("s716",True,0,0,X+400,Y+180,DoubleToStr(netprofit2("USDCHF"+sufix),2),COLO(netprofit2("USDCHF"+sufix)),12,"Arial",0,false,0);

            PlotLabel("s813",True,0,0,X+100,Y+200,DoubleToStr(netprofit("EURGBP"+sufix,24),2),COLO(netprofit("EURGBP"+sufix,24)),12,"Arial",0,false,0);
            PlotLabel("s814",True,0,0,X+200,Y+200,DoubleToStr(netprofit("EURGBP"+sufix,120),2),COLO(netprofit("EURGBP"+sufix,120)),12,"Arial",0,false,0);
            PlotLabel("s815",True,0,0,X+300,Y+200,DoubleToStr(netprofit("EURGBP"+sufix,720),2),COLO(netprofit("EURGBP"+sufix,720)),12,"Arial",0,false,0);
            PlotLabel("s816",True,0,0,X+400,Y+200,DoubleToStr(netprofit2("EURGBP"+sufix),2),COLO(netprofit2("EURGBP"+sufix)),12,"Arial",0,false,0);

            PlotLabel("s913",True,0,0,X+100,Y+220,DoubleToStr(netprofit("GBPJPY"+sufix,24),2),COLO(netprofit("GBPJPY"+sufix,24)),12,"Arial",0,false,0);
            PlotLabel("s914",True,0,0,X+200,Y+220,DoubleToStr(netprofit("GBPJPY"+sufix,120),2),COLO(netprofit("GBPJPY"+sufix,120)),12,"Arial",0,false,0);
            PlotLabel("s915",True,0,0,X+300,Y+220,DoubleToStr(netprofit("GBPJPY"+sufix,720),2),COLO(netprofit("GBPJPY"+sufix,720)),12,"Arial",0,false,0);
            PlotLabel("s916",True,0,0,X+400,Y+220,DoubleToStr(netprofit2("GBPJPY"+sufix),2),COLO(netprofit2("GBPJPY"+sufix)),12,"Arial",0,false,0);
            
            PlotLabel("s1013",True,0,0,X+100,Y+240,DoubleToStr(netprofit("USDCAD"+sufix,24),2),COLO(netprofit("USDCAD"+sufix,24)),12,"Arial",0,false,0);
            PlotLabel("s1014",True,0,0,X+200,Y+240,DoubleToStr(netprofit("USDCAD"+sufix,120),2),COLO(netprofit("USDCAD"+sufix,120)),12,"Arial",0,false,0);
            PlotLabel("s1015",True,0,0,X+300,Y+240,DoubleToStr(netprofit("USDCAD"+sufix,720),2),COLO(netprofit("USDCAD"+sufix,720)),12,"Arial",0,false,0);
            PlotLabel("s1016",True,0,0,X+400,Y+240,DoubleToStr(netprofit2("USDCAD"+sufix),2),COLO(netprofit2("USDCAD"+sufix)),12,"Arial",0,false,0);

            PlotLabel("s1113",True,0,0,X+100,Y+260,DoubleToStr(netprofit("XAUUSD"+sufix,24),2),COLO(netprofit("XAUUSD"+sufix,24)),12,"Arial",0,false,0);
            PlotLabel("s1114",True,0,0,X+200,Y+260,DoubleToStr(netprofit("XAUUSD"+sufix,120),2),COLO(netprofit("XAUUSD"+sufix,120)),12,"Arial",0,false,0);
            PlotLabel("s1115",True,0,0,X+300,Y+260,DoubleToStr(netprofit("XAUUSD"+sufix,720),2),COLO(netprofit("XAUUSD"+sufix,720)),12,"Arial",0,false,0);
            PlotLabel("s1116",True,0,0,X+400,Y+260,DoubleToStr(netprofit2("XAUUSD"+sufix),2),COLO(netprofit2("XAUUSD"+sufix)),12,"Arial",0,false,0);



            
   }

 
 //----------
  return;
  }
//+------------------------------------------------------------------+

//===================================================================
 int Open_Order( int tip, double llots )
  {
  int ticket = -1;
   double spread=-1;spread = MarketInfo(Symbol(), MODE_SPREAD);
   double max_lot; max_lot = MarketInfo(Symbol(), MODE_MAXLOT);
   if( llots > max_lot ) llots = NormalizeDouble( (max_lot-1), Digits);
  if( counts() == 0 )
    {
     if( tip == 0 )
        {
         while( ticket == -1)
           {
           ticket  = OrderSend(Symbol(),OP_BUY, llots,Ask,3, 0, Bid + (step*Point+2*spread*Point), "DAILY Gamble 1",MagicNumber,0, PaleGreen );
           if( ticket > -1 ) break;
            else  if( GetLastError() == 134 ) break;
            else  if( GetLastError() == 4051 ) break;
            else Sleep(10000);
        }   }
        
  if( tip == 1 )
     {
     ticket = -1;
      while( ticket == -1)
         {
         ticket  =OrderSend(Symbol(),OP_SELL,llots,Bid,3,0,Ask-(step*Point+2*spread*Point),"DAILY Gamble 1",MagicNumber,0, Red);
         if( ticket > -1 ) break;
          else  if( GetLastError() == 134 ) break;
          else  if( GetLastError() == 4051 ) break;
          else Sleep(10000);
      }   }
  }
 //-----------
 return(0);
 }
         
  
  
   int Closesell_Order(int magic)
{
 int total = OrdersTotal();
 for(int i=total-1;i>=0;i--)
 {
   if(OrderSelect(i, SELECT_BY_POS)){
     if(OrderSymbol()== Symbol() && OrderMagicNumber()==magic){

   int type   = OrderType();

   bool result = false;

   switch(type)
   {
     //Close opened long positions
     case OP_BUY       : result = false;
                         break;

     //Close opened short positions
     case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );

   }

   if(result == false)
   {
     //Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
     Sleep(0);
   }
 }
   }
}
 return(0);
}

int Closebuy_Order(int magic)
{
 int total = OrdersTotal();
 for(int i=total-1;i>=0;i--)
 {
  if( OrderSelect(i, SELECT_BY_POS)){
  if(OrderSymbol()== Symbol() && OrderMagicNumber()==magic){
   int type   = OrderType();

   bool result = false;

   switch(type)
   {
     //Close opened long positions
     case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                         break;

     //Close opened short positions
     case OP_SELL      : result = false;

   }

   if(result == false)
   {
     //Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
     Sleep(0);
   }
 }
}
}
 return(0);
}   
           
         
              
         
 int counts() {
   int l_count_0 = 0;
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      if(OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES))
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0++;
   }
   return (l_count_0);
}     
 
   /* double nominal_lot(double acc){
    
    if(acc <= 1000.00) return(0.01);
    if(acc <= 2000.00) retu
    */
    
   
//+------------------------------------------------------------------+
int PlotLabel(string name, bool del=false, int win=0, int cnr=0, int hpos=0, int vpos=0, string text=" ", color clr=0, int size=0, string font="Arial", double angle=0, bool bg=false, int vis=0)  {
//+------------------------------------------------------------------+
  if (StringLen(name)<1 || hpos<0 || vpos<=0)   return(-1);
  if (del)    ObjectDelete(name);
  win = MathMax(win,0);
  cnr = MathMax(cnr,0);
  if (clr<=0)     clr  = White;
  size = MathMax(size,8);
  if (ObjectFind(name) < 0)
    ObjectCreate(name,OBJ_LABEL,win,0,0,0,0);
  ObjectSet(name,OBJPROP_CORNER,cnr);  
  ObjectSet(name,OBJPROP_XDISTANCE,hpos);  
  ObjectSet(name,OBJPROP_YDISTANCE,vpos);  
  ObjectSetText(name,text,size,font,clr);
  ObjectSet(name,OBJPROP_BACK,bg);
  ObjectSet(name,OBJPROP_TIMEFRAMES,vis);
  ObjectSet(name,OBJPROP_ANGLE,angle);
  return(0);
}

 double netprofit( string sym , datetime period){
  double k1 =0.00;
 for(int jj = OrdersHistoryTotal()-1; jj>=0; jj--){
 if(!OrderSelect(jj,SELECT_BY_POS,MODE_HISTORY))Print("no order");
 if(OrderSymbol() == sym && OrderMagicNumber()== MagicNumber){
 
 if((TimeCurrent()-OrderOpenTime())<=period*3600) k1 = k1+OrderProfit()+OrderSwap()+OrderCommission();  
 }}
   return(k1);
   }
   
    double netprofit2( string sym ){
  double k1 =0.00;
 for(int jj = OrdersHistoryTotal()-1; jj>=0; jj--){
 if(!OrderSelect(jj,SELECT_BY_POS,MODE_HISTORY))Print("no order");
 if(OrderSymbol() == sym && OrderMagicNumber()== MagicNumber){
 
  k1 = k1+OrderProfit()+OrderSwap()+OrderCommission(); 
 }}
   return(k1);
   }
   
  color COLO( double profit){
    color clr = Gray;

    if( profit > 0 )clr = LawnGreen;
    if(profit < 0 ) clr =Red;
    if(profit == 0) clr =Gray;
    return(clr);
    }
  
  
  

void MoveBreakEven(int magic)
{
   int cnt,total=OrdersTotal();
   for(cnt=0;cnt<total;cnt++)
   {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)){
      if(OrderType()<=1  &&OrderSymbol()==Symbol()&&OrderMagicNumber()==magic)
      {
         if(OrderType()==OP_BUY)
         {
            if(BreakEven>0)
            {
               if(NormalizeDouble((Bid-OrderOpenPrice()),Digits)>10*BreakEven*Point)
               {
                  if(NormalizeDouble((OrderStopLoss()-OrderOpenPrice()),Digits)<0)
                  {
                  if(Bid>OrderOpenPrice()+2*MarketInfo(Symbol(),MODE_STOPLEVEL)*Point){
                     if(OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()+(BreakEven)*Point,Digits),OrderTakeProfit(),0,Blue))Print("BreakEven Modified");
                  if(Ask>=High[0]-10*Point)
                  Rs= OrderModify(OrderTicket(),OrderOpenPrice(),High[0]-200*Point,OrderTakeProfit(),0,Blue);
                  }
               }}
            }
         }
         else
         {
            if(BreakEven>0)
            {
               if(NormalizeDouble((OrderOpenPrice()-Ask),Digits)>10*BreakEven*Point)
               {
                  if(NormalizeDouble((OrderOpenPrice()-OrderStopLoss()),Digits)<0)
                  {
                  if(Ask<OrderOpenPrice()-2*MarketInfo(Symbol(),MODE_STOPLEVEL)*Point){
                     if(OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()-(BreakEven)*Point,Digits),OrderTakeProfit(),0,Red))Print("BreakEven Modified");
                         if(Bid<=Low[0]+10*Point)
                           Rs= OrderModify(OrderTicket(),OrderOpenPrice(),Low[0]+200*Point,OrderTakeProfit(),0,Yellow);

                     }
               }
               }
            }
         }
      }
   }}
}

bool Rs;   