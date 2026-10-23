#property copyright "Denis Nikolaev"
#property link      "https://www.mql5.com/ru/users/zaqcde/seller#products"
#property version   "1.00"
#property description "Local position copier on one computer from one terminal to another";
#ifdef __MQL5__ #property description "The Expert Advisor uses the MT4Orders.mqh library from fxsaber." #endif
//#property icon "KopierMaschineF.ico"
#property strict
#ifdef __MQL5__ #include <MT4Orders.mqh> #endif
int Delay=100;
enum worktp{Master,Slave};
input worktp WorkMode=Master;
input string Prefix="";
input string Suffix="";
double Levier=1.0;
long m_ticket[1000];
long tek_ticket[1000];
double m_lot[1000];
double tek_lot[1000];
int m_type[1000];
int tek_type[1000];
double m_sl[1000];
double tek_sl[1000];
double m_tp[1000];
double tek_tp[1000];
string m_symbol[1000];
string tek_symbol[1000];
double m_price[1000];
double tek_price[1000];
int tek_cd=0;
int count_deal=0;
int globalcount=0;
int OnInit(){
   EventSetMillisecondTimer(Delay);
   if(WorkMode==Master){
      f_buttonset();
      f_m_deals();
   }
   if(WorkMode==Slave){
      f_buttonsetslave();
      bopenbuy=false;bopensell=false;bclosebuy=false;bclosesell=false;
      bbuylimit=false;bselllimit=false;bbuystop=false;bsellstop=false;
      blotmaster=false;blotfix=false;blotprop=false;breverse=false;
      bcopysl=false;bcopytp=false;bdev=false;btrade=false;
   }
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){
   EventKillTimer();
   if(WorkMode==Master){ 
      FileDelete("KopierMachine_"+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"_"+"master.txt",FILE_COMMON);
      FileDelete(IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"_"+"master.txt",FILE_COMMON);
      FileDelete(IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"_"+"ticket.txt",FILE_COMMON);
      ObjectsDeleteAll(0);
   }
   if(WorkMode==Slave){ 
      FileDelete("KopierMachine_"+IntegerToString(MagicNumber)+"_"+"slave.txt",FILE_COMMON);
      ObjectsDeleteAll(0);
   }
}
bool change_op;
void OnTick(){
if(WorkMode==Master&&btrade){
if(!FileIsExist(IntegerToString(MagicNumber)+"_"+"master.txt",FILE_COMMON)
&&!FileIsExist(IntegerToString(MagicNumber)+"_"+"signal.txt",FILE_COMMON)){
   f_ticketfile();
   int i,j;
   bool find=false;
   bool change_sl=false;
   bool change_tp=false;
   int findindex=-1;
   f_tek_deals();
   if(tek_cd>count_deal){
      int file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
      +"master.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
      if(file_handleopen){
      FileSeek(file_handleopen,0,SEEK_END);
      for(i=0; i<tek_cd; i++){
         find=false;
         for(j=0; j<count_deal; j++){
            if(tek_ticket[i]==m_ticket[j]){
               find=true;
               break;
            }
         }
         findindex=i;
         if(find==false){
            m_ticket[count_deal]=tek_ticket[findindex];
            m_lot[count_deal]=tek_lot[findindex];
            m_type[count_deal]=tek_type[findindex];
            m_sl[count_deal]=tek_sl[findindex];
            m_tp[count_deal]=tek_tp[findindex];
            m_symbol[count_deal]=tek_symbol[findindex];
            m_price[count_deal]=tek_price[findindex];
            m_timeopen[count_deal]=tek_timeopen[findindex];
            count_deal++;
            if(file_handleopen){
               string nsymbol=tek_symbol[findindex];
               StringReplace(nsymbol,Prefix,"");
               StringReplace(nsymbol,Suffix,"");
               FileWriteString(file_handleopen,IntegerToString(MagicNumber)+"\n");
               FileWriteString(file_handleopen,DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+"\n");
               FileWriteString(file_handleopen,"open"+"\n");
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_lot[findindex],2)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_type[findindex])+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_sl[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_tp[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_price[findindex],5)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_timeopen[findindex])+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_ticket[findindex])+"\n");
               FileFlush(file_handleopen);
            }
         }
      }
      }
      FileClose(file_handleopen);
      file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
      +"signal.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
      FileWriteString(file_handleopen,"nsymbol"+"\n");
      FileFlush(file_handleopen);
      FileClose(file_handleopen);
   }
   if(tek_cd<count_deal){
      int file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
      +"master.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
      if(file_handleopen){
      FileSeek(file_handleopen,0,SEEK_END);
      for(i=0; i<count_deal; i++){
         find=false;
         for(j=0; j<tek_cd; j++){
            findindex=-1;
            if(m_ticket[i]==tek_ticket[j]){
               find=true;
               break;
            }
         }
         findindex=i;
         if(find==false){
            if(file_handleopen){
               string nsymbol=m_symbol[findindex];
               StringReplace(nsymbol,Prefix,"");
               StringReplace(nsymbol,Suffix,"");
               FileWriteString(file_handleopen,IntegerToString(MagicNumber)+"\n");
               FileWriteString(file_handleopen,DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+"\n");
               FileWriteString(file_handleopen,"close"+"\n");
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileWriteString(file_handleopen,DoubleToString(m_lot[findindex],2)+"\n");
               FileWriteString(file_handleopen,IntegerToString(m_type[findindex])+"\n");
               FileWriteString(file_handleopen,DoubleToString(m_sl[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(m_tp[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(m_price[findindex],5)+"\n");
               FileWriteString(file_handleopen,IntegerToString(m_timeopen[findindex])+"\n");
               FileWriteString(file_handleopen,IntegerToString(m_ticket[findindex])+"\n");
               FileFlush(file_handleopen);
            }
         }
      }
      }
      FileClose(file_handleopen);
      file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
      +"signal.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
      FileWriteString(file_handleopen,"nsymbol"+"\n");
      FileFlush(file_handleopen);
      FileClose(file_handleopen);
      for(i=0; i<tek_cd; i++){
         m_ticket[i]=tek_ticket[i];
         m_lot[i]=tek_lot[i];
         m_type[i]=tek_type[i];
         m_sl[i]=tek_sl[i];
         m_tp[i]=tek_tp[i];
         m_symbol[i]=tek_symbol[i];
         m_price[i]=tek_price[i];         
         m_timeopen[i]=tek_timeopen[i];
      }
      count_deal=tek_cd;
   }
   if(tek_cd==count_deal){
      findindex=-1;
      for(i=0; i<tek_cd; i++){
         change_sl=false;
         change_tp=false;
         change_op=false;
         for(j=0; j<count_deal; j++){
            if(tek_ticket[i]==m_ticket[j]){
               if(tek_sl[i]!=m_sl[j]){
                  change_sl=true;
                  findindex=i;
               }
               if(tek_tp[i]!=m_tp[j]){
                  change_tp=true;
                  findindex=i;
               }
               if(tek_price[i]!=m_price[j]){
                  change_op=true;
                  findindex=i;
               }
               if(change_op||change_sl==true||change_tp==true)
                  break;
            }
         }
         if(change_sl==true&&change_tp==true&&change_op==false){
            int file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
            +"master.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
            if(file_handleopen){
               FileSeek(file_handleopen,0,SEEK_END);
               string nsymbol=tek_symbol[findindex];
               StringReplace(nsymbol,Prefix,"");
               StringReplace(nsymbol,Suffix,"");
               FileWriteString(file_handleopen,IntegerToString(MagicNumber)+"\n");
               FileWriteString(file_handleopen,DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+"\n");
               FileWriteString(file_handleopen,"sltp"+"\n");
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_lot[findindex],2)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_type[findindex])+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_sl[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_tp[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_price[findindex],5)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_timeopen[findindex])+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_ticket[findindex])+"\n");
               FileFlush(file_handleopen);
               FileClose(file_handleopen);
               file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
               +"signal.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileFlush(file_handleopen);
               FileClose(file_handleopen);
               break;
            }
         }
         if(change_sl==true&&change_tp==true&&change_op==true){
            int file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
            +"master.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
            if(file_handleopen){
               FileSeek(file_handleopen,0,SEEK_END);
               string nsymbol=tek_symbol[findindex];
               StringReplace(nsymbol,Prefix,"");
               StringReplace(nsymbol,Suffix,"");
               FileWriteString(file_handleopen,IntegerToString(MagicNumber)+"\n");
               FileWriteString(file_handleopen,DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+"\n");
               FileWriteString(file_handleopen,"sltpop"+"\n");
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_lot[findindex],2)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_type[findindex])+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_sl[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_tp[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_price[findindex],5)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_timeopen[findindex])+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_ticket[findindex])+"\n");
               FileFlush(file_handleopen);
               FileClose(file_handleopen);
               file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
               +"signal.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileFlush(file_handleopen);
               FileClose(file_handleopen);
               break;
            }
         }
         if(change_sl==true&&change_tp==false&&change_op==true){
            int file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
            +"master.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
            if(file_handleopen){
               FileSeek(file_handleopen,0,SEEK_END);
               string nsymbol=tek_symbol[findindex];
               StringReplace(nsymbol,Prefix,"");
               StringReplace(nsymbol,Suffix,"");
               FileWriteString(file_handleopen,IntegerToString(MagicNumber)+"\n");
               FileWriteString(file_handleopen,DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+"\n");
               FileWriteString(file_handleopen,"slop"+"\n");
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_lot[findindex],2)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_type[findindex])+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_sl[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_tp[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_price[findindex],5)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_timeopen[findindex])+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_ticket[findindex])+"\n");
               FileFlush(file_handleopen);
               FileClose(file_handleopen);
               file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
               +"signal.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileFlush(file_handleopen);
               FileClose(file_handleopen);
               break;
            }
         }
         if(change_sl==true&&change_tp==false&&change_op==false){
            int file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
            +"master.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
            if(file_handleopen){
               FileSeek(file_handleopen,0,SEEK_END);
               string nsymbol=tek_symbol[findindex];
               StringReplace(nsymbol,Prefix,"");
               StringReplace(nsymbol,Suffix,"");
               FileWriteString(file_handleopen,IntegerToString(MagicNumber)+"\n");
               FileWriteString(file_handleopen,DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+"\n");
               FileWriteString(file_handleopen,"sl"+"\n");
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_lot[findindex],2)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_type[findindex])+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_sl[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_tp[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_price[findindex],5)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_timeopen[findindex])+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_ticket[findindex])+"\n");
               FileFlush(file_handleopen);
               FileClose(file_handleopen);
               file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
               +"signal.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileFlush(file_handleopen);
               FileClose(file_handleopen);
               break;
            }
         }
         if(change_sl==false&&change_tp==true&&change_op==true){
            int file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
            +"master.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
            if(file_handleopen){
               FileSeek(file_handleopen,0,SEEK_END);
               string nsymbol=tek_symbol[findindex];
               StringReplace(nsymbol,Prefix,"");
               StringReplace(nsymbol,Suffix,"");
               FileWriteString(file_handleopen,IntegerToString(MagicNumber)+"\n");
               FileWriteString(file_handleopen,DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+"\n");
               FileWriteString(file_handleopen,"tpop"+"\n");
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_lot[findindex],2)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_type[findindex])+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_sl[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_tp[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_price[findindex],5)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_timeopen[findindex])+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_ticket[findindex])+"\n");
               FileFlush(file_handleopen);
               FileClose(file_handleopen);
               file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
               +"signal.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileFlush(file_handleopen);
               FileClose(file_handleopen);
               break;
            }
         }
         if(change_sl==false&&change_tp==true&&change_op==false){
            int file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
            +"master.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
            if(file_handleopen){
               FileSeek(file_handleopen,0,SEEK_END);
               string nsymbol=tek_symbol[findindex];
               StringReplace(nsymbol,Prefix,"");
               StringReplace(nsymbol,Suffix,"");
               FileWriteString(file_handleopen,IntegerToString(MagicNumber)+"\n");
               FileWriteString(file_handleopen,DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+"\n");
               FileWriteString(file_handleopen,"tp"+"\n");
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_lot[findindex],2)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_type[findindex])+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_sl[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_tp[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_price[findindex],5)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_timeopen[findindex])+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_ticket[findindex])+"\n");
               FileFlush(file_handleopen);
               FileClose(file_handleopen);
               file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
               +"signal.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileFlush(file_handleopen);
               FileClose(file_handleopen);
               break;
            }
         }
         if(change_sl==false&&change_tp==false&&change_op==true){
            int file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
            +"master.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
            if(file_handleopen){
               FileSeek(file_handleopen,0,SEEK_END);
               string nsymbol=tek_symbol[findindex];
               StringReplace(nsymbol,Prefix,"");
               StringReplace(nsymbol,Suffix,"");
               FileWriteString(file_handleopen,IntegerToString(MagicNumber)+"\n");
               FileWriteString(file_handleopen,DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+"\n");
               FileWriteString(file_handleopen,"op"+"\n");
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_lot[findindex],2)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_type[findindex])+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_sl[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_tp[findindex],5)+"\n");
               FileWriteString(file_handleopen,DoubleToString(tek_price[findindex],5)+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_timeopen[findindex])+"\n");
               FileWriteString(file_handleopen,IntegerToString(tek_ticket[findindex])+"\n");
               FileFlush(file_handleopen);
               FileClose(file_handleopen);
               file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
               +"signal.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
               FileWriteString(file_handleopen,nsymbol+"\n");
               FileFlush(file_handleopen);
               FileClose(file_handleopen);
               break;
            }
         }
      }
      if(findindex!=-1){
         for(i=0; i<tek_cd; i++){
            m_ticket[i]=tek_ticket[i];
            m_lot[i]=tek_lot[i];
            m_type[i]=tek_type[i];
            m_sl[i]=tek_sl[i];
            m_tp[i]=tek_tp[i];
            m_symbol[i]=tek_symbol[i];
            m_price[i]=tek_price[i];         
            m_timeopen[i]=tek_timeopen[i];
         }
      }
   }
}
}
if(WorkMode==Slave&&btrade){
   f_ticketfileslave();
   if(FileIsExist(IntegerToString(MagicNumber)+"_"+"master.txt",FILE_COMMON)
   &&FileIsExist(IntegerToString(MagicNumber)+"_"+"signal.txt",FILE_COMMON)){
      string file_name=IntegerToString(MagicNumber)+"_" +"master.txt";
      int file_handlex=FileOpen(file_name,FILE_READ|FILE_ANSI|FILE_TXT|FILE_COMMON);
      if(file_handlex){
         while(!FileIsEnding(file_handlex)){
            int magnum=int(StringToInteger(FileReadString(file_handlex)));
            double balanc=StringToDouble(FileReadString(file_handlex));
            string event=FileReadString(file_handlex);
            if(magnum==MagicNumber&&event=="open"){
               string simbol=Prefix+FileReadString(file_handlex)+Suffix;
               double lots=StringToDouble(FileReadString(file_handlex));
               if(blotfix){
                  lots=StringToDouble(ObjectGetString(0,"lotfixvalue",OBJPROP_TEXT));
                  lots=NormalizeVolume(simbol,lots);
               }
               if(blotprop){
                  lots=AccountInfoDouble(ACCOUNT_BALANCE)/balanc;
                  lots=NormalizeVolume(simbol,lots);
               }
               int typeord=int(StringToInteger(FileReadString(file_handlex)));
               double stop=StringToDouble(FileReadString(file_handlex));
               double take=StringToDouble(FileReadString(file_handlex));
               double price=StringToDouble(FileReadString(file_handlex));
               long timeopen=StringToInteger(FileReadString(file_handlex));
               int tickets=int(StringToInteger(FileReadString(file_handlex)));
               int cx=0;
               if(!breverse){
               if(typeord<=1&&
               ((typeord==OP_BUY&&bopenbuy)||(typeord==OP_SELL&&bopensell))
               ){
                  if(!bdev||(bdev&&MathAbs((SymbolInfoDouble(simbol,SYMBOL_ASK)+SymbolInfoDouble(simbol,SYMBOL_BID))/2-price)/SymbolInfoDouble(simbol,SYMBOL_POINT)
                  >=StringToDouble(ObjectGetString(0,"devvalue",OBJPROP_TEXT))))
                  while(cx<100&&OrderSend(simbol,typeord,lots,
                  SymbolInfoDouble(simbol,typeord==0?SYMBOL_ASK:SYMBOL_BID),30,
                  bcopysl?stop:0,bcopytp?take:0,IntegerToString(tickets),int(MagicNumber),0,
                  typeord==0?clrBlue:clrRed)<=0){cx++;Sleep(3000);Print(simbol+" OrderSend ERROR");}
               }else{
                  if(typeord==OP_BUYLIMIT&&bbuylimit)
                     while(cx<100&&OrderSend(simbol,typeord,lots,price,30,
                     bcopysl?stop:0,bcopytp?take:0,IntegerToString(tickets),int(MagicNumber),0,clrBlue)<=0){cx++;Sleep(3000);Print(simbol+" OrderSend ERROR");}
                  if(typeord==OP_SELLLIMIT&&bselllimit)
                     while(cx<100&&OrderSend(simbol,typeord,lots,price,30,
                     bcopysl?stop:0,bcopytp?take:0,IntegerToString(tickets),int(MagicNumber),0,clrRed)<=0){cx++;Sleep(3000);Print(simbol+" OrderSend ERROR");}
                  if(typeord==OP_BUYSTOP&&bbuystop)
                     while(cx<100&&OrderSend(simbol,typeord,lots,price,30,
                     bcopysl?stop:0,bcopytp?take:0,IntegerToString(tickets),int(MagicNumber),0,clrBlue)<=0){cx++;Sleep(3000);Print(simbol+" OrderSend ERROR");}
                  if(typeord==OP_SELLSTOP&&bsellstop)
                     while(cx<100&&OrderSend(simbol,typeord,lots,price,30,
                     bcopysl?stop:0,bcopytp?take:0,IntegerToString(tickets),int(MagicNumber),0,clrRed)<=0){cx++;Sleep(3000);Print(simbol+" OrderSend ERROR");}
               }
               }else{
                  if(!bdev||(bdev&&MathAbs((SymbolInfoDouble(simbol,SYMBOL_ASK)+SymbolInfoDouble(simbol,SYMBOL_BID))/2-price)/SymbolInfoDouble(simbol,SYMBOL_POINT)
                  >=StringToDouble(ObjectGetString(0,"devvalue",OBJPROP_TEXT))))
                  if(typeord==OP_BUY&&bopensell)
                     while(cx<100&&OrderSend(simbol,OP_SELL,lots,
                     SymbolInfoDouble(simbol,SYMBOL_BID),30,
                     bcopytp?take:0,bcopysl?stop:0,IntegerToString(tickets),int(MagicNumber),0,
                     clrRed)<=0){cx++;Sleep(3000);Print(simbol+" OrderSend ERROR");}
                  if(!bdev||(bdev&&MathAbs((SymbolInfoDouble(simbol,SYMBOL_ASK)+SymbolInfoDouble(simbol,SYMBOL_BID))/2-price)/SymbolInfoDouble(simbol,SYMBOL_POINT)
                  >=StringToDouble(ObjectGetString(0,"devvalue",OBJPROP_TEXT))))
                  if(typeord==OP_SELL&&bopenbuy)
                     while(cx<100&&OrderSend(simbol,OP_BUY,lots,
                     SymbolInfoDouble(simbol,SYMBOL_ASK),30,
                     bcopytp?take:0,bcopysl?stop:0,IntegerToString(tickets),int(MagicNumber),0,
                     clrBlue)<=0){cx++;Sleep(3000);Print(simbol+" OrderSend ERROR");}
                  if(typeord==OP_BUYLIMIT&&bsellstop)
                     while(cx<100&&OrderSend(simbol,OP_SELLSTOP,lots,price,30,
                     bcopytp?take:0,bcopysl?stop:0,IntegerToString(tickets),
                     int(MagicNumber),0,clrRed)<=0){cx++;Sleep(3000);
                     Print(simbol+" OrderSend ERROR");}
                  if(typeord==OP_SELLLIMIT&&bbuystop)
                     while(cx<100&&OrderSend(simbol,OP_BUYSTOP,lots,price,30,
                     bcopytp?take:0,bcopysl?stop:0,IntegerToString(tickets),
                     int(MagicNumber),0,clrBlue)<=0){cx++;Sleep(3000);
                     Print(simbol+" OrderSend ERROR");}
                  if(typeord==OP_BUYSTOP&&bselllimit)
                     while(cx<100&&OrderSend(simbol,OP_SELLLIMIT,lots,price,30,
                     bcopytp?take:0,bcopysl?stop:0,IntegerToString(tickets),
                     int(MagicNumber),0,clrBlue)<=0){cx++;Sleep(3000);
                     Print(simbol+" OrderSend ERROR");}
                  if(typeord==OP_SELLSTOP&&bbuylimit)
                     while(cx<100&&OrderSend(simbol,OP_BUYLIMIT,lots,price,30,
                     bcopytp?take:0,bcopysl?stop:0,IntegerToString(tickets),
                     int(MagicNumber),0,clrRed)<=0){cx++;Sleep(3000);
                     Print(simbol+" OrderSend ERROR");}
               }
            }
            if(magnum==MagicNumber&&event=="close"){
               string simbol=Prefix+FileReadString(file_handlex)+Suffix;
               double lots=StringToDouble(FileReadString(file_handlex));
               int typeord=int(StringToInteger(FileReadString(file_handlex)));
               double stop=StringToDouble(FileReadString(file_handlex));
               double take=StringToDouble(FileReadString(file_handlex));
               double price=StringToDouble(FileReadString(file_handlex));
               long timeopen=StringToInteger(FileReadString(file_handlex));
               int tickets=int(StringToInteger(FileReadString(file_handlex)));
               int total=OrdersTotal();
               for(int k=total-1; k>=0; k--)
               if(OrderSelect(k,SELECT_BY_POS)==true)
               if(OrderSymbol()==simbol
               &&OrderMagicNumber()==MagicNumber
               &&tickets==StringToInteger(OrderComment())){
                  int cx=0;
                  if(!breverse){
                  if(typeord<=1&&
                  ((typeord==OP_BUY&&bclosebuy)||(typeord==OP_SELL&&bclosesell))
                  ){
                     while(cx<100&&OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),30,clrAliceBlue)==false)
                     {cx++;Sleep(3000);Print(simbol+" OrderClose ERROR");}
                     break;
                  }else{
                     while(cx<100&&OrderDelete(OrderTicket(),clrAliceBlue)==false)
                     {cx++;Sleep(3000);Print(simbol+" OrderDelete ERROR");}
                     break;
                  }
                  }else{
                     if(typeord==OP_BUY&&bclosesell&&OrderType()==OP_SELL)
                        while(cx<100&&OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),30,clrAliceBlue)==false)
                        {cx++;Sleep(3000);Print(simbol+" OrderClose ERROR");}
                     if(typeord==OP_SELL&&bclosebuy&&OrderType()==OP_BUY)
                        while(cx<100&&OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),30,clrAliceBlue)==false)
                        {cx++;Sleep(3000);Print(simbol+" OrderClose ERROR");}
                     if(typeord>1)   
                        while(cx<100&&OrderDelete(OrderTicket(),clrAliceBlue)==false)
                        {cx++;Sleep(3000);Print(simbol+" OrderDelete ERROR");}
                     break;
                  }
               }
            }
            if(magnum==MagicNumber&&event=="sltpop"){
               string simbolfirst=FileReadString(file_handlex);
               string simbol=Prefix+simbolfirst+Suffix;
               double lots=StringToDouble(FileReadString(file_handlex));
               int typeord=int(StringToInteger(FileReadString(file_handlex)));
               double stop=StringToDouble(FileReadString(file_handlex));
               double take=StringToDouble(FileReadString(file_handlex));
               double price=StringToDouble(FileReadString(file_handlex));
               long timeopen=StringToInteger(FileReadString(file_handlex));
               int tickets=int(StringToInteger(FileReadString(file_handlex)));
               int total=OrdersTotal();
               for(int k=total-1; k>=0; k--)
               if(OrderSelect(k,SELECT_BY_POS)==true)
               if(OrderSymbol()==simbol
               &&OrderMagicNumber()==MagicNumber
               &&tickets==StringToInteger(OrderComment())){
                  if(!breverse)if(OrderModify(OrderTicket(),price,
                  bcopysl?stop:OrderStopLoss(),bcopytp?take:OrderTakeProfit(),0,clrAliceBlue))
                     break;
                  if(breverse)if(OrderModify(OrderTicket(),price,
                  bcopytp?take:OrderStopLoss(),bcopysl?stop:OrderTakeProfit(),0,clrAliceBlue))
                     break;
               }
            }
            if(magnum==MagicNumber&&event=="sltp"){
               string simbolfirst=FileReadString(file_handlex);
               string simbol=Prefix+simbolfirst+Suffix;
               double lots=StringToDouble(FileReadString(file_handlex));
               int typeord=int(StringToInteger(FileReadString(file_handlex)));
               double stop=StringToDouble(FileReadString(file_handlex));
               double take=StringToDouble(FileReadString(file_handlex));
               double price=StringToDouble(FileReadString(file_handlex));
               long timeopen=StringToInteger(FileReadString(file_handlex));
               int tickets=int(StringToInteger(FileReadString(file_handlex)));
               int total=OrdersTotal();
               for(int k=total-1; k>=0; k--)
               if(OrderSelect(k,SELECT_BY_POS)==true)
               if(OrderSymbol()==simbol
               &&OrderMagicNumber()==MagicNumber
               &&tickets==StringToInteger(OrderComment())){
                  if(!breverse)if(OrderModify(OrderTicket(),OrderOpenPrice(),
                  bcopysl?stop:OrderStopLoss(),bcopytp?take:OrderTakeProfit(),0,clrAliceBlue))
                     break;
                  if(breverse)if(OrderModify(OrderTicket(),OrderOpenPrice(),
                  bcopytp?take:OrderStopLoss(),bcopysl?stop:OrderTakeProfit(),0,clrAliceBlue))
                     break;
               }
            }
            if(magnum==MagicNumber&&event=="slop"){
               string simbolfirst=FileReadString(file_handlex);
               string simbol=Prefix+simbolfirst+Suffix;
               double lots=StringToDouble(FileReadString(file_handlex));
               int typeord=int(StringToInteger(FileReadString(file_handlex)));
               double stop=StringToDouble(FileReadString(file_handlex));
               double take=StringToDouble(FileReadString(file_handlex));
               double price=StringToDouble(FileReadString(file_handlex));
               long timeopen=StringToInteger(FileReadString(file_handlex));
               int tickets=int(StringToInteger(FileReadString(file_handlex)));
               int total=OrdersTotal();
               for(int k=total-1; k>=0; k--)
               if(OrderSelect(k,SELECT_BY_POS)==true)
               if(OrderSymbol()==simbol
               &&OrderMagicNumber()==MagicNumber
               &&tickets==StringToInteger(OrderComment())){
                  if(!breverse)if(OrderModify(OrderTicket(),price,
                  bcopysl?stop:OrderStopLoss(),OrderTakeProfit(),0,clrAliceBlue))
                     break;
                  if(breverse)if(OrderModify(OrderTicket(),price,
                  OrderStopLoss(),bcopysl?stop:OrderTakeProfit(),0,clrAliceBlue))
                     break;
               }
            }
            if(magnum==MagicNumber&&event=="sl"){
               string simbolfirst=FileReadString(file_handlex);
               string simbol=Prefix+simbolfirst+Suffix;
               double lots=StringToDouble(FileReadString(file_handlex));
               int typeord=int(StringToInteger(FileReadString(file_handlex)));
               double stop=StringToDouble(FileReadString(file_handlex));
               double take=StringToDouble(FileReadString(file_handlex));
               double price=StringToDouble(FileReadString(file_handlex));
               long timeopen=StringToInteger(FileReadString(file_handlex));
               int tickets=int(StringToInteger(FileReadString(file_handlex)));
               int total=OrdersTotal();
               for(int k=total-1; k>=0; k--)
               if(OrderSelect(k,SELECT_BY_POS)==true)
               if(OrderSymbol()==simbol
               &&OrderMagicNumber()==MagicNumber
               &&tickets==StringToInteger(OrderComment())){
                  if(!breverse)if(OrderModify(OrderTicket(),OrderOpenPrice(),
                  bcopysl?stop:OrderStopLoss(),OrderTakeProfit(),0,clrAliceBlue))
                     break;
                  if(breverse)if(OrderModify(OrderTicket(),OrderOpenPrice(),
                  OrderStopLoss(),bcopysl?stop:OrderTakeProfit(),0,clrAliceBlue))
                     break;
               }
            }
            if(magnum==MagicNumber&&event=="tpop"){
               string simbolfirst=FileReadString(file_handlex);
               string simbol=Prefix+simbolfirst+Suffix;
               double lots=StringToDouble(FileReadString(file_handlex));
               int typeord=int(StringToInteger(FileReadString(file_handlex)));
               double stop=StringToDouble(FileReadString(file_handlex));
               double take=StringToDouble(FileReadString(file_handlex));
               double price=StringToDouble(FileReadString(file_handlex));
               long timeopen=StringToInteger(FileReadString(file_handlex));
               int tickets=int(StringToInteger(FileReadString(file_handlex)));
               int total=OrdersTotal();
               for(int k=total-1; k>=0; k--)
               if(OrderSelect(k,SELECT_BY_POS)==true)
               if(OrderSymbol()==simbol
               &&OrderMagicNumber()==MagicNumber
               &&tickets==StringToInteger(OrderComment())){
                  if(!breverse)if(OrderModify(OrderTicket(),price,
                  OrderStopLoss(),bcopytp?take:OrderTakeProfit(),0,clrAliceBlue))
                     break;
                  if(breverse)if(OrderModify(OrderTicket(),price,
                  bcopytp?take:OrderStopLoss(),OrderTakeProfit(),0,clrAliceBlue))
                     break;
               }
            }
            if(magnum==MagicNumber&&event=="tp"){
               string simbolfirst=FileReadString(file_handlex);
               string simbol=Prefix+simbolfirst+Suffix;
               double lots=StringToDouble(FileReadString(file_handlex));
               int typeord=int(StringToInteger(FileReadString(file_handlex)));
               double stop=StringToDouble(FileReadString(file_handlex));
               double take=StringToDouble(FileReadString(file_handlex));
               double price=StringToDouble(FileReadString(file_handlex));
               long timeopen=StringToInteger(FileReadString(file_handlex));
               int tickets=int(StringToInteger(FileReadString(file_handlex)));
               int total=OrdersTotal();
               for(int k=total-1; k>=0; k--)
               if(OrderSelect(k,SELECT_BY_POS)==true)
               if(OrderSymbol()==simbol
               &&OrderMagicNumber()==MagicNumber
               &&tickets==StringToInteger(OrderComment())){
                  if(!breverse)if(OrderModify(OrderTicket(),OrderOpenPrice(),
                  OrderStopLoss(),bcopytp?take:OrderTakeProfit(),0,clrAliceBlue))
                     break;
                  if(breverse)if(OrderModify(OrderTicket(),OrderOpenPrice(),
                  bcopytp?take:OrderStopLoss(),OrderTakeProfit(),0,clrAliceBlue))
                     break;
               }
            }
            if(magnum==MagicNumber&&event=="op"){
               string simbol=Prefix+FileReadString(file_handlex)+Suffix;
               double lots=StringToDouble(FileReadString(file_handlex));
               int typeord=int(StringToInteger(FileReadString(file_handlex)));
               double stop=StringToDouble(FileReadString(file_handlex));
               double take=StringToDouble(FileReadString(file_handlex));
               double price=StringToDouble(FileReadString(file_handlex));
               long timeopen=StringToInteger(FileReadString(file_handlex));
               int tickets=int(StringToInteger(FileReadString(file_handlex)));
               int total=OrdersTotal();
               for(int k=total-1; k>=0; k--)
               if(OrderSelect(k,SELECT_BY_POS)==true)
               if(OrderSymbol()==simbol
               &&OrderMagicNumber()==MagicNumber
               &&tickets==StringToInteger(OrderComment())){
                  if(OrderModify(OrderTicket(),price,
                  OrderStopLoss(),OrderTakeProfit(),0,clrAliceBlue))
                     break;
               }
            }
         }
         FileClose(file_handlex);
         FileDelete(IntegerToString(MagicNumber)+"_"+"master.txt",FILE_COMMON);
         FileDelete(IntegerToString(MagicNumber)+"_"+"signal.txt",FILE_COMMON);
      }
   }
}
}
int file_handle;
datetime localtime;
void OnTimer(){

OnTick();
}
void f_tek_deals(){
   tek_cd=0;
   int total=OrdersTotal();
   for(int k=total-1; k>=0; k--)
      if (OrderSelect(k,SELECT_BY_POS)==true){
         tek_ticket[tek_cd]=OrderTicket();
         tek_lot[tek_cd]=OrderLots();
         tek_type[tek_cd]=OrderType();
         tek_sl[tek_cd]=OrderStopLoss();
         tek_tp[tek_cd]=OrderTakeProfit();
         tek_symbol[tek_cd]=OrderSymbol();
         tek_price[tek_cd]=OrderOpenPrice();
         tek_timeopen[tek_cd]=long(OrderOpenTime());
         tek_cd++;
      }
}
long tek_timeopen[1000],m_timeopen[1000];
void f_m_deals(){
   count_deal=0;
   int total=OrdersTotal();
   for(int k=total-1; k>=0; k--)
      if (OrderSelect(k,SELECT_BY_POS)==true){
         m_ticket[count_deal]=OrderTicket();
         m_lot[count_deal]=OrderLots();
         m_type[count_deal]=OrderType();
         m_sl[count_deal]=OrderStopLoss();
         m_tp[count_deal]=OrderTakeProfit();
         m_symbol[count_deal]=OrderSymbol();
         m_price[count_deal]=OrderOpenPrice();
         m_timeopen[count_deal]=long(OrderOpenTime());
         count_deal++;
      }
}
void f_ticketfile(){
   if(!FileIsExist(IntegerToString(MagicNumber)+"_"+"ticket.txt",FILE_COMMON)){
      int file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
      +"ticket.txt",FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
      if(file_handleopen){
         int total=OrdersTotal();
         for(int k=total-1; k>=0; k--)
         if (OrderSelect(k,SELECT_BY_POS)==true){
            FileWriteString(file_handleopen,IntegerToString(OrderTicket())+"\n");
            FileFlush(file_handleopen);
         }
      }
      FileClose(file_handleopen);
   }
}
void f_ticketfileslave(){
   if(FileIsExist(IntegerToString(MagicNumber)+"_"+"ticket.txt",FILE_COMMON)){
      int file_handleopen=FileOpen(IntegerToString(MagicNumber)+"_" 
      +"ticket.txt",FILE_READ|FILE_ANSI|FILE_TXT|FILE_COMMON);
      if(file_handleopen){
         int mas_tick[10000];mas_tick[0]=0;
         int cnt_tick=0;
         while(!FileIsEnding(file_handleopen)){
            mas_tick[cnt_tick]=int(StringToInteger(FileReadString(file_handleopen)));
            cnt_tick++;
         }
         if(cnt_tick>0){
            int total=OrdersTotal();
            for(int k=total-1; k>=0; k--)
            if(OrderSelect(k,SELECT_BY_POS)==true)
            if(OrderMagicNumber()==MagicNumber){
               bool tflag=false;
               for(int t=0;t<cnt_tick;t++)
               if(mas_tick[t]==StringToInteger(OrderComment()))
                  tflag=true;
               if(tflag==false
               &&((OrderType()==OP_BUY&&bclosebuy)||(OrderType()==OP_SELL&&bclosesell))
               ){
                  int cx=0;
                  while(cx<100&&OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),30,clrAliceBlue)==false)
                  {cx++;Sleep(3000);Print(OrderSymbol()+" OrderClose ERROR");}
               }
            }
         }
         FileClose(file_handleopen);
         FileDelete(IntegerToString(MagicNumber)+"_"+"ticket.txt",FILE_COMMON);
      }
   }
}
color PanelColor=clrBlue;
color TextColor=clrWhite;
int FontSize=12;
void f_buttonset(){
   button_sym_create(0,"name", 0, 15,400,25, PanelColor, TextColor,PanelColor, "Kopier Maschine",FontSize); 
   button_sym_create(5,"close", 375, 15,25,25, PanelColor, TextColor,PanelColor, "X",FontSize); 
   button_sym_create(0,"place1", 0, 40,400,60, clrWhite, TextColor,PanelColor, "",FontSize); 
   if(!EditCreate(0,"message",0,0,100,400,50,"Program is OFF",InpFont,FontSize,InpAlign,
   true,InpCorner,InpColor,InpBackColor,PanelColor,InpBack,
   InpSelection,InpHidden,InpZOrder)){ChartRedraw();}
   button_sym_create(0,"off", 10, 50,60,25, clrRed, clrBlack,clrRed, "OFF",FontSize); 
   button_sym_create(0,"on", 80, 50,60,25, clrGray, clrBlack,clrGray, "ON",FontSize); 
   button_sym_create(0,"master", 150, 50,160,25, clrWhite, clrBlack,clrWhite, "Master: "+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)),FontSize); 
}
void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam){
if(WorkMode==Master){
   if(sparam=="on"){
      if(ObjectGetInteger(0,"off",OBJPROP_BGCOLOR)==clrRed){
         btrade=true;
         ObjectSetInteger(0,"off",OBJPROP_BGCOLOR,clrGray);
         ObjectSetInteger(0,"off",OBJPROP_BORDER_COLOR,clrGray);
         ObjectSetInteger(0,"on",OBJPROP_BGCOLOR,clrLightGreen);
         ObjectSetInteger(0,"on",OBJPROP_BORDER_COLOR,clrLightGreen);
         ObjectSetString(0,"message",OBJPROP_TEXT,"Program is ON");
         int file_handless=FileOpen("KopierMachine_"+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"_" 
         +"master.txt",FILE_WRITE|FILE_SHARE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
         if(file_handless){
            FileWriteString(file_handless,IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"\n");
            FileWriteString(file_handless,AccountInfoString(ACCOUNT_SERVER)+"\n");
            FileFlush(file_handless);
            FileClose(file_handless);
         }
         MagicNumber=AccountInfoInteger(ACCOUNT_LOGIN);
      }
      ObjectSetInteger(0,"on",OBJPROP_STATE,0);
   }
   if(sparam=="off"){
      if(ObjectGetInteger(0,"on",OBJPROP_BGCOLOR)==clrLightGreen){
         btrade=false;
         ObjectSetInteger(0,"on",OBJPROP_BGCOLOR,clrGray);
         ObjectSetInteger(0,"on",OBJPROP_BORDER_COLOR,clrGray);
         ObjectSetInteger(0,"off",OBJPROP_BGCOLOR,clrRed);
         ObjectSetInteger(0,"off",OBJPROP_BORDER_COLOR,clrRed);
         ObjectSetString(0,"message",OBJPROP_TEXT,"Program is OFF");
         FileDelete("KopierMachine_"+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"_"+"master.txt",FILE_COMMON);
         FileDelete(IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"_"+"master.txt",FILE_COMMON);
         FileDelete(IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"_"+"ticket.txt",FILE_COMMON);
      }
      ObjectSetInteger(0,"off",OBJPROP_STATE,0);
   }
   if(sparam=="close"){
      FileDelete("KopierMachine_"+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"_"+"master.txt",FILE_COMMON);
      FileDelete(IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"_"+"master.txt",FILE_COMMON);
      ExpertRemove();
      ChartRedraw(0);
   }
   if(sparam=="place1")ObjectSetInteger(0,"place1",OBJPROP_STATE,0);
   if(sparam=="master")ObjectSetInteger(0,"master",OBJPROP_STATE,0);
   if(sparam=="name")ObjectSetInteger(0,"name",OBJPROP_STATE,0);
}
if(WorkMode==Slave){
   if(sparam=="closebuy"){
      ObjectSetInteger(0,"closebuy",OBJPROP_STATE,0);
      if(ObjectGetInteger(0,"closebuy",OBJPROP_BGCOLOR)==clrWhite){
         bclosebuy=true;
         ObjectSetInteger(0,"closebuy",OBJPROP_BGCOLOR,clrLightGreen);
         ObjectSetString(0,"closebuy",OBJPROP_TEXT,"Close BUY = ON");
      }else{
         bclosebuy=false;
         ObjectSetInteger(0,"closebuy",OBJPROP_BGCOLOR,clrWhite);
         ObjectSetString(0,"closebuy",OBJPROP_TEXT,"Close BUY = OFF");
      }
   }
   if(sparam=="closesell"){
      ObjectSetInteger(0,"closesell",OBJPROP_STATE,0);
      if(ObjectGetInteger(0,"closesell",OBJPROP_BGCOLOR)==clrWhite){
         bclosesell=true;
         ObjectSetInteger(0,"closesell",OBJPROP_BGCOLOR,clrLightGreen);
         ObjectSetString(0,"closesell",OBJPROP_TEXT,"Close SELL = ON");
      }else{
         bclosesell=false;
         ObjectSetInteger(0,"closesell",OBJPROP_BGCOLOR,clrWhite);
         ObjectSetString(0,"closesell",OBJPROP_TEXT,"Close SELL = OFF");
      }
   }
   if(sparam=="buylimit"){
      ObjectSetInteger(0,"buylimit",OBJPROP_STATE,0);
      if(ObjectGetInteger(0,"buylimit",OBJPROP_BGCOLOR)==clrWhite){
         bbuylimit=true;
         ObjectSetInteger(0,"buylimit",OBJPROP_BGCOLOR,clrLightGreen);
         ObjectSetString(0,"buylimit",OBJPROP_TEXT,"Buy Limit = ON");
      }else{
         bbuylimit=false;
         ObjectSetInteger(0,"buylimit",OBJPROP_BGCOLOR,clrWhite);
         ObjectSetString(0,"buylimit",OBJPROP_TEXT,"Buy Limit = OFF");
      }
   }
   if(sparam=="selllimit"){
      ObjectSetInteger(0,"selllimit",OBJPROP_STATE,0);
      if(ObjectGetInteger(0,"selllimit",OBJPROP_BGCOLOR)==clrWhite){
         bselllimit=true;
         ObjectSetInteger(0,"selllimit",OBJPROP_BGCOLOR,clrLightGreen);
         ObjectSetString(0,"selllimit",OBJPROP_TEXT,"Sell Limit = ON");
      }else{
         bselllimit=false;
         ObjectSetInteger(0,"selllimit",OBJPROP_BGCOLOR,clrWhite);
         ObjectSetString(0,"selllimit",OBJPROP_TEXT,"Sell Limit = OFF");
      }
   }
   if(sparam=="buystop"){
      ObjectSetInteger(0,"buystop",OBJPROP_STATE,0);
      if(ObjectGetInteger(0,"buystop",OBJPROP_BGCOLOR)==clrWhite){
         bbuystop=true;
         ObjectSetInteger(0,"buystop",OBJPROP_BGCOLOR,clrLightGreen);
         ObjectSetString(0,"buystop",OBJPROP_TEXT,"Buy Stop = ON");
      }else{
         bbuystop=false;
         ObjectSetInteger(0,"buystop",OBJPROP_BGCOLOR,clrWhite);
         ObjectSetString(0,"buystop",OBJPROP_TEXT,"Buy Stop = OFF");
      }
   }
   if(sparam=="sellstop"){
      ObjectSetInteger(0,"sellstop",OBJPROP_STATE,0);
      if(ObjectGetInteger(0,"sellstop",OBJPROP_BGCOLOR)==clrWhite){
         bsellstop=true;
         ObjectSetInteger(0,"sellstop",OBJPROP_BGCOLOR,clrLightGreen);
         ObjectSetString(0,"sellstop",OBJPROP_TEXT,"Sell Stop = ON");
      }else{
         bsellstop=false;
         ObjectSetInteger(0,"sellstop",OBJPROP_BGCOLOR,clrWhite);
         ObjectSetString(0,"sellstop",OBJPROP_TEXT,"Sell Stop = OFF");
      }
   }
   if(sparam=="copysl"){
      ObjectSetInteger(0,"copysl",OBJPROP_STATE,0);
      if(ObjectGetInteger(0,"copysl",OBJPROP_BGCOLOR)==clrWhite){
         bcopysl=true;
         ObjectSetInteger(0,"copysl",OBJPROP_BGCOLOR,clrLightGreen);
         ObjectSetString(0,"copysl",OBJPROP_TEXT,"Copy SL = ON");
      }else{
         bcopysl=false;
         ObjectSetInteger(0,"copysl",OBJPROP_BGCOLOR,clrWhite);
         ObjectSetString(0,"copysl",OBJPROP_TEXT,"Copy SL = OFF");
      }
   }
   if(sparam=="copytp"){
      ObjectSetInteger(0,"copytp",OBJPROP_STATE,0);
      if(ObjectGetInteger(0,"copytp",OBJPROP_BGCOLOR)==clrWhite){
         bcopytp=true;
         ObjectSetInteger(0,"copytp",OBJPROP_BGCOLOR,clrLightGreen);
         ObjectSetString(0,"copytp",OBJPROP_TEXT,"Copy TP = ON");
      }else{
         bcopytp=false;
         ObjectSetInteger(0,"copytp",OBJPROP_BGCOLOR,clrWhite);
         ObjectSetString(0,"copytp",OBJPROP_TEXT,"Copy TP = OFF");
      }
   }
   if(sparam=="opensell"){
      ObjectSetInteger(0,"opensell",OBJPROP_STATE,0);
      if(ObjectGetInteger(0,"opensell",OBJPROP_BGCOLOR)==clrWhite){
         bopensell=true;
         ObjectSetInteger(0,"opensell",OBJPROP_BGCOLOR,clrLightGreen);
         ObjectSetString(0,"opensell",OBJPROP_TEXT,"Open SELL = ON");
      }else{
         bopensell=false;
         ObjectSetInteger(0,"opensell",OBJPROP_BGCOLOR,clrWhite);
         ObjectSetString(0,"opensell",OBJPROP_TEXT,"Open SELL = OFF");
      }
   }
   if(sparam=="openbuy"){
      ObjectSetInteger(0,"openbuy",OBJPROP_STATE,0);
      if(ObjectGetInteger(0,"openbuy",OBJPROP_BGCOLOR)==clrWhite){
         bopenbuy=true;
         ObjectSetInteger(0,"openbuy",OBJPROP_BGCOLOR,clrLightGreen);
         ObjectSetString(0,"openbuy",OBJPROP_TEXT,"Open BUY = ON");
      }else{
         bopenbuy=false;
         ObjectSetInteger(0,"openbuy",OBJPROP_BGCOLOR,clrWhite);
         ObjectSetString(0,"openbuy",OBJPROP_TEXT,"Open BUY = OFF");
      }
   }
   if(sparam=="deviat"){
      ObjectSetInteger(0,"deviat",OBJPROP_STATE,0);
      if(ObjectGetInteger(0,"deviat",OBJPROP_BGCOLOR)==clrWhite){
         bdev=true;
         ObjectSetInteger(0,"deviat",OBJPROP_BGCOLOR,clrLightGreen);
         ObjectSetString(0,"deviat",OBJPROP_TEXT,"Deviation = ON");
      }else{
         bdev=false;
         ObjectSetInteger(0,"deviat",OBJPROP_BGCOLOR,clrWhite);
         ObjectSetString(0,"deviat",OBJPROP_TEXT,"Deviation = OFF");
      }
   }
   if(sparam=="reverse"){
      ObjectSetInteger(0,"reverse",OBJPROP_STATE,0);
      if(ObjectGetInteger(0,"reverse",OBJPROP_BGCOLOR)==clrWhite){
         breverse=true;
         ObjectSetInteger(0,"reverse",OBJPROP_BGCOLOR,clrLightGreen);
         ObjectSetString(0,"reverse",OBJPROP_TEXT,"Reverse Trade = ON");
      }else{
         breverse=false;
         ObjectSetInteger(0,"reverse",OBJPROP_BGCOLOR,clrWhite);
         ObjectSetString(0,"reverse",OBJPROP_TEXT,"Reverse Trade = OFF");
      }
   }
   if(sparam=="lotmaster"){
      ObjectSetInteger(0,"lotmaster",OBJPROP_STATE,0);
      blotmaster=true;blotfix=false;blotprop=false;
      ObjectSetString(0,"lotmaster",OBJPROP_TEXT,"Master Lot = ON");
      ObjectSetInteger(0,"lotmaster",OBJPROP_BGCOLOR,clrLightGreen);
      ObjectSetString(0,"lotfix",OBJPROP_TEXT,"Fix Lot = OFF");
      ObjectSetInteger(0,"lotfix",OBJPROP_BGCOLOR,clrWhite);
      ObjectSetString(0,"lotprop",OBJPROP_TEXT,"Proportional Lot = OFF");
      ObjectSetInteger(0,"lotprop",OBJPROP_BGCOLOR,clrWhite);
   }
   if(sparam=="lotfix"){
      ObjectSetInteger(0,"lotfix",OBJPROP_STATE,0);
      blotmaster=false;blotfix=true;blotprop=false;
      ObjectSetString(0,"lotmaster",OBJPROP_TEXT,"Master Lot = OFF");
      ObjectSetInteger(0,"lotmaster",OBJPROP_BGCOLOR,clrWhite);
      ObjectSetString(0,"lotfix",OBJPROP_TEXT,"Fix Lot = ON");
      ObjectSetInteger(0,"lotfix",OBJPROP_BGCOLOR,clrLightGreen);
      ObjectSetString(0,"lotprop",OBJPROP_TEXT,"Proportional Lot = OFF");
      ObjectSetInteger(0,"lotprop",OBJPROP_BGCOLOR,clrWhite);
   }
   if(sparam=="lotprop"){
      ObjectSetInteger(0,"lotprop",OBJPROP_STATE,0);
      blotmaster=false;blotfix=false;blotprop=true;
      ObjectSetString(0,"lotmaster",OBJPROP_TEXT,"Master Lot = OFF");
      ObjectSetInteger(0,"lotmaster",OBJPROP_BGCOLOR,clrWhite);
      ObjectSetString(0,"lotfix",OBJPROP_TEXT,"Fix Lot = OFF");
      ObjectSetInteger(0,"lotfix",OBJPROP_BGCOLOR,clrWhite);
      ObjectSetString(0,"lotprop",OBJPROP_TEXT,"Proportional Lot = ON");
      ObjectSetInteger(0,"lotprop",OBJPROP_BGCOLOR,clrLightGreen);
   }
   if(sparam=="selectmaster"){
      FileDelete("KopierMachine_"+(ObjectGetString(0,"master",OBJPROP_TEXT))+"_"+"slave.txt",FILE_COMMON);
      ObjectDelete(0,"master");
      ObjectSetInteger(0,"selectmaster",OBJPROP_STATE,0);
      string file_name;
      countmaster=0;
      long search_handle=FileFindFirst("*",file_name,FILE_COMMON);
      if(search_handle!=INVALID_HANDLE){
         do{
            if(StringFind(file_name,"KopierMachine",0)>=0
            &&StringFind(file_name,"master",0)>0){
               string part[10];
               string sepz="_";ushort u_sepz=StringGetCharacter(sepz,0);
               int namepartcnt=StringSplit(file_name,u_sepz,part);
               m_master[countmaster]=StringToInteger(part[1]);
               countmaster++;
            }
         }while(FileFindNext(search_handle,file_name));
         FileFindClose(search_handle);
      }
      if(countmaster==0)
         ObjectSetString(0,"message",OBJPROP_TEXT,"No masters");
      for(int i=0;i<countmaster;i++){
         button_sym_create(0,"mast"+IntegerToString(i), 20, 105+i*20,160,20, clrWhite, clrBlack,clrWhite, IntegerToString(long(m_master[i])),9); 
      }
   }
   for(int i=0;i<countmaster;i++)
   if(sparam=="mast"+IntegerToString(i)){
      MagicNumber=m_master[i];
      int file_handless=FileOpen("KopierMachine_"+IntegerToString(MagicNumber)+"_" 
      +"slave.txt",FILE_WRITE|FILE_SHARE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON);
      if(file_handless){
         FileWriteString(file_handless,IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"\n");
         FileWriteString(file_handless,AccountInfoString(ACCOUNT_SERVER)+"\n");
         ObjectSetString(0,"message",OBJPROP_TEXT,"Master selected");
         FileFlush(file_handless);
         FileClose(file_handless);
      }
      for(int ix=0;ix<countmaster;ix++)
         ObjectDelete(0,"mast"+IntegerToString(ix));
      button_sym_create(0,"master", 20, 105,160,20, clrWhite, clrBlack,clrWhite, IntegerToString(MagicNumber),9); 
      ObjectSetInteger(0,"master",OBJPROP_BGCOLOR,clrLightGreen);
   }
   if(sparam=="on"){
      if(ObjectGetInteger(0,"off",OBJPROP_BGCOLOR)==clrRed){
         btrade=true;
         ObjectSetInteger(0,"off",OBJPROP_BGCOLOR,clrGray);
         ObjectSetInteger(0,"off",OBJPROP_BORDER_COLOR,clrGray);
         ObjectSetInteger(0,"on",OBJPROP_BGCOLOR,clrLightGreen);
         ObjectSetInteger(0,"on",OBJPROP_BORDER_COLOR,clrLightGreen);
         ObjectSetString(0,"message",OBJPROP_TEXT,"Program is ON");
      }
      ObjectSetInteger(0,"on",OBJPROP_STATE,0);
   }
   if(sparam=="off"){
      if(ObjectGetInteger(0,"on",OBJPROP_BGCOLOR)==clrLightGreen){
         btrade=false;
         ObjectSetInteger(0,"on",OBJPROP_BGCOLOR,clrGray);
         ObjectSetInteger(0,"on",OBJPROP_BORDER_COLOR,clrGray);
         ObjectSetInteger(0,"off",OBJPROP_BGCOLOR,clrRed);
         ObjectSetInteger(0,"off",OBJPROP_BORDER_COLOR,clrRed);
         ObjectSetString(0,"message",OBJPROP_TEXT,"Program is OFF");
      }
      ObjectSetInteger(0,"off",OBJPROP_STATE,0);
   }
   if(sparam=="close"){
      FileDelete("KopierMachine_"+IntegerToString(MagicNumber)+"_"+"slave.txt",FILE_COMMON);
      ExpertRemove();
      ChartRedraw(0);
   }
   if(sparam=="place1")ObjectSetInteger(0,"place1",OBJPROP_STATE,0);
   if(sparam=="place2")ObjectSetInteger(0,"place2",OBJPROP_STATE,0);
   if(sparam=="place3")ObjectSetInteger(0,"place3",OBJPROP_STATE,0);
   if(sparam=="name")ObjectSetInteger(0,"name",OBJPROP_STATE,0);
   if(sparam=="master")ObjectSetInteger(0,"master",OBJPROP_STATE,0);
}
}
void f_buttonsetslave(){
   button_sym_create(0,"name", 0, 15,400,25, PanelColor, TextColor,PanelColor, "Kopier Maschine",FontSize); 
   button_sym_create(5,"close", 375, 15,25,25, PanelColor, TextColor,PanelColor, "X",FontSize); 
   button_sym_create(0,"place1", 0, 40,200,300, clrWhite, TextColor,PanelColor, "",FontSize); 
   button_sym_create(0,"place2", 200, 40,200,300, clrWhite, TextColor,PanelColor, "",FontSize); 
   //button_sym_create(0,"place3", 400, 40,200,300, clrWhite, TextColor,PanelColor, "",FontSize); 
   if(!EditCreate(0,"message",0,0,340,400,50,"",InpFont,FontSize,InpAlign,
   true,InpCorner,InpColor,InpBackColor,PanelColor,InpBack,
   InpSelection,InpHidden,InpZOrder)){ChartRedraw();}
   button_sym_create(0,"off", 10, 50,60,25, clrRed, clrBlack,clrRed, "OFF",FontSize); 
   button_sym_create(0,"on", 80, 50,60,25, clrGray, clrBlack,clrGray, "ON",FontSize); 
   button_sym_create(0,"selectmaster", 20, 80,160,25, clrWhite, clrBlack,clrBlack, "Select Master Account \\/",10); 
   button_sym_create(0,"lotmaster", 20, 125,160,20, clrWhite, clrBlack,clrBlack, "Master Lot = OFF",10); 
   button_sym_create(0,"lotfix", 20, 147,100,20, clrWhite, clrBlack,clrBlack, "Fix Lot = OFF",10); 
   if(!EditCreate(0,"lotfixvalue",0,122,147,58,20,"",InpFont,FontSize,InpAlign,
   false,InpCorner,InpColor,InpBackColor,PanelColor,InpBack,
   InpSelection,InpHidden,InpZOrder)){ChartRedraw();}
   button_sym_create(0,"lotprop", 20, 169,160,20, clrWhite, clrBlack,clrBlack, "Proportional Lot = OFF",10); 
   button_sym_create(0,"reverse", 20, 191,160,20, clrWhite, clrBlack,clrBlack, "Reverse Trade = OFF",10); 
   button_sym_create(0,"deviat", 20, 213,100,20, clrWhite, clrBlack,clrBlack, "Deviation = OFF",10); 
   if(!EditCreate(0,"devvalue",0,122,213,58,20,"",InpFont,FontSize,InpAlign,
   false,InpCorner,InpColor,InpBackColor,PanelColor,InpBack,
   InpSelection,InpHidden,InpZOrder)){ChartRedraw();}
   button_sym_create(0,"openbuy", 220, 45,160,20, clrWhite, clrBlack,clrBlack, "Open BUY = OFF",10); 
   button_sym_create(0,"opensell", 220, 67,160,20, clrWhite, clrBlack,clrBlack, "Open SELL = OFF",10); 
   button_sym_create(0,"closebuy", 220, 89,160,20, clrWhite, clrBlack,clrBlack, "Close BUY = OFF",10); 
   button_sym_create(0,"closesell", 220, 111,160,20, clrWhite, clrBlack,clrBlack, "Close SELL = OFF",10); 
   button_sym_create(0,"buylimit", 220, 133,160,20, clrWhite, clrBlack,clrBlack, "Buy Limit = OFF",10); 
   button_sym_create(0,"selllimit", 220, 155,160,20, clrWhite, clrBlack,clrBlack, "Sell Limit = OFF",10); 
   button_sym_create(0,"buystop", 220, 177,160,20, clrWhite, clrBlack,clrBlack, "Buy Stop = OFF",10); 
   button_sym_create(0,"sellstop", 220, 199,160,20, clrWhite, clrBlack,clrBlack, "Sell Stop = OFF",10); 
   button_sym_create(0,"copysl", 220, 221,160,20, clrWhite, clrBlack,clrBlack, "Copy SL = OFF",10); 
   button_sym_create(0,"copytp", 220, 243,160,20, clrWhite, clrBlack,clrBlack, "Copy TP = OFF",10); 
}
bool bopenbuy,bopensell,bclosebuy,bclosesell,bbuylimit,bselllimit,bbuystop,bsellstop;
bool blotmaster,blotfix,blotprop,breverse,bcopysl,bcopytp,bdev,btrade;
int countmaster=0;long m_master[100];
long MagicNumber;
void button_sym_create(long prior,string sym, int x , int y, int xs,int ys, 
color c, color cf, color cborder,string show,int abc){
   ObjectCreate(0,""+sym,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,""+sym,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,""+sym,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,""+sym,OBJPROP_XSIZE,xs);
   ObjectSetInteger(0,""+sym,OBJPROP_YSIZE,ys);
   ObjectSetInteger(0,""+sym, OBJPROP_CORNER, 0);
   ObjectSetString(0,""+sym,OBJPROP_TEXT,show);
   ObjectSetInteger(0,""+sym,OBJPROP_COLOR, cf);
   ObjectSetInteger(0,""+sym,OBJPROP_BGCOLOR, c);
   ObjectSetInteger(0,""+sym,OBJPROP_BORDER_COLOR,cborder);
   ObjectSetInteger(0,""+sym,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,""+sym,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,""+sym,OBJPROP_STATE,false);
   ObjectSetInteger(0,""+sym,OBJPROP_FONTSIZE,abc);
   ObjectSetInteger(0,""+sym,OBJPROP_ZORDER,prior);
}
string           InpName="Editxxx666999";              // Имя объекта
string           InpText="Symbol";              // Текст объекта
string           InpFont="Arial";             // Шрифт
int              InpFontSize=14;              // Размер шрифта
ENUM_ALIGN_MODE  InpAlign=ALIGN_CENTER;       // Способ выравнивания текста
bool             InpReadOnly=false;           // Возможность редактировать
ENUM_BASE_CORNER InpCorner=CORNER_LEFT_UPPER; // Угол графика для привязки
color            InpColor=clrBlack;           // Цвет текста
color            InpBackColor=clrWhite;       // Цвет фона
color            InpBorderColor=clrBlack;     // Цвет границы
bool             InpBack=false;               // Объект на заднем плане
bool             InpSelection=false;          // Выделить для перемещений
bool             InpHidden=true;              // Скрыт в списке объектов
long             InpZOrder=0;                 // Приоритет на нажатие мышью
bool EditCreate(const long             chart_ID=0,               // ID графика
                const string           name="Editxxx666999",              // имя объекта
                const int              sub_window=0,             // номер подокна
                const int              x=0,                      // координата по оси X
                const int              y=0,                      // координата по оси Y
                const int              width=50,                 // ширина
                const int              height=18,                // высота
                const string           text="Text",              // текст
                const string           font="Arial",             // шрифт
                const int              font_size=10,             // размер шрифта
                const ENUM_ALIGN_MODE  align=ALIGN_LEFT,       // способ выравнивания
                const bool             read_only=false,          // возможность редактировать
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // угол графика для привязки
                const color            clr=clrBlack,             // цвет текста
                const color            back_clr=clrWhite,        // цвет фона
                const color            border_clr=clrNONE,       // цвет границы
                const bool             back=false,               // на заднем плане
                const bool             selection=false,          // выделить для перемещений
                const bool             hidden=true,              // скрыт в списке объектов
                const long             z_order=0)                // приоритет на нажатие мышью
  {
//--- сбросим значение ошибки
   ResetLastError();
//--- создадим поле ввода
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
     {
      Print(__FUNCTION__,
            "Don`t create edit object  ",GetLastError());
      return(false);
     }
//--- установим координаты объекта
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- установим размеры объекта
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- установим текст
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- установим шрифт текста
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- установим размер шрифта
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- установим способ выравнивания текста в объекте
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
//--- установим (true) или отменим (false) режим только для чтения
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
//--- установим угол графика, относительно которого будут определяться координаты объекта
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- установим цвет текста
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- установим цвет фона
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- установим цвет границы
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- включим (true) или отключим (false) режим перемещения метки мышью
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- установим приоритет на получение события нажатия мыши на графике
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- успешное выполнение
   return(true);
}
double NormalizeVolume(string symbol,double lot){
   double MinLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   double MaxLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double volume_step=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   int volume_digits=(int)(MathLog(1.0/volume_step)/MathLog(10.0));
   if(lot<MinLot)lot=0;
   if(lot>MaxLot)lot=MaxLot;
   return(NormalizeDouble(lot,volume_digits));
}