//+------------------------------------------------------------------+
//|                                   strategy_report_into_chart.mq5 |
//|                                                                  |
//+------------------------------------------------------------------+
//use this script to draw trades from a file with results from metatrader's strategy tester to a chart
//how does it work ?
//1. load "StrategyTester.html" to the MQL5/files directory
//2. run this script on a appropriate chart
//3. enjoy it

//tested on Metatrader version 5, build 4380

#property copyright "Copyright © 2024, globus2008"
#property script_show_inputs

input bool Erase_All_Object  =   true; //should be all object be erased before drawing of the report?
input string reportname      =   "StrategyTester.html"; //name of html file created from strategy tester
input int hour_shift = 0;//shift a certain amount hours back or forward

struct result {
      string number; //results[row][0]= value;                                        //number of action
      string time; //results[row][1]= value;                                        //time of action
      string symbol;
      string in_out;
      string type; //results[row][2]= value;                                        //type of action
      string order; //results[row][3]= value;                                        //order's number 
      string deal; //results[row][3]= value;                                        //deal's number 
      string volume; //results[row][4]= value;                                        //lot size
      string open_price; //results[row][5]= value;                                        //open price
      string commission;
      string swap;
      string profit;
      string balance;
      string comment;
};

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
//---
   bool FlagCont=true;
   string var,piece,value,text,in_out;

   result results[];
   int row=0,begin=0,end=0,cnt,cntOrders,all;
   int orders[];
   string notes,lots;
   
   int ticket; 
   string opentime; 
   string type; 
   double openprice=0;
   string closetime;
   int count=0;
   string name;
   
   int handle=FileOpen(reportname,FILE_READ,0,0x7F);
   if(handle == INVALID_HANDLE)
     {
         Alert("File "+reportname+" does not exist!");
         return;
     }         
   FileSeek(handle,0,SEEK_SET);

   while(FlagCont) {
         var=FileReadString(handle);
         piece=StringSubstr(var,29,6);    
         if(piece=="Symbol") {
               var=FileReadString(handle);
               piece=StringSubstr(var,46,6);
               
               if(piece!=_Symbol) {
                   Alert("Strategy was testing on ",piece," chart. It is going to draw results to ",Symbol()," chart!");
               } 
               FlagCont=false;
               Print("Report2Chart: Symbol confirmed!");
                
            }           
    }

   FlagCont=true;
   while(FlagCont && FileIsEnding(handle)==false) {
         var=FileReadString(handle);
         piece=StringSubstr(var,78,5); 
         if(piece=="Deals") {
               var=FileReadString(handle);
               FlagCont=false;
               Print("Report2Chart: DEAL part found!");
            }           
    }    
        
   FlagCont=true;
   while(FlagCont && FileIsEnding(handle)==false) {
         var=FileReadString(handle);
         piece=StringSubstr(var,88,7); 
         if(piece=="balance") {
               FlagCont=false;
               Print("Report2Chart: Initial balance found!");
            }           
    }  

   while(FileIsEnding(handle)==false)
      {
         while (FileIsLineEnding(handle)) {
               ArrayResize(results,row+1);
               
               var=FileReadString(handle);               
               string string_var,string_end;
               StringSetCharacter(string_var, 0, 34);
               string_end="   <tr align="+string_var+"right"+string_var+">";
               
               if(var==string_end) break;
             
               begin=StringFind(var, "<td>",0)+4;                          //Find the beginning of the position
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               var = StringSubstr(var, end); 
               results[row].time= value;                                        //time of action
               //Print("Time:"+results[row].time);
               //-----------------               
               begin=StringFind(var, "<td>",0)+4;                             //Position of action
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               var = StringSubstr(var, end);
               results[row].deal= value;                                        //deal number
              //Print("Number:"+results[row].deal);  
               //-----------------
               
               begin=StringFind(var, "<td>",0)+4;                           //Find the beginning of the position
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               var = StringSubstr(var, end);
               results[row].symbol= value;
               //Print("Symbol:"+results[row].symbol);                                       
               //-----------------
             
               begin=StringFind(var, "<td>",0)+4;                           //Find the beginning of the position
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               var = StringSubstr(var, end);
               results[row].type= value;                                        //type of action
               //Print("Symbol:"+results[row].type); 
               //-----------------
               
               begin=StringFind(var, "<td>",0)+4;                           //Find the beginning of the position
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               var = StringSubstr(var, end);
               results[row].in_out= value;                                        
               //Print("In-out:"+results[row].in_out);
               //----------------- 
                             
               begin=StringFind(var, "<td>",0)+4;                          //Find the beginning of the position
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               var = StringSubstr(var, end);
               results[row].volume= value;                                        //lot size
               //Print("Volume:"+results[row].volume);
               //-----------------
               
               begin=StringFind(var, "<td>",0)+4;                          //Find the beginning of the position
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               var = StringSubstr(var, end);
               results[row].open_price= value;                                        //open price
               //Print("Price:"+results[row].open_price);
               //-----------------               
               
               begin=StringFind(var, "<td>",0)+4;                           //Find the beginning of the position 
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               var = StringSubstr(var, end);
               results[row].order= value;                                        //order's number
               //Print("Deal:"+results[row].order);
               //-----------------

               begin=StringFind(var, "<td>",0)+4;                          //Find the beginning of the position
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               var = StringSubstr(var, end);
               results[row].commission= value;                                        //commission
               //Print("commission:"+results[row].commission);
               //----------------- 
               
               begin=StringFind(var, "<td>",0)+4;                          //Find the beginning of the position
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               var = StringSubstr(var, end);
               results[row].swap= value;                                        //swap
               //Print("swap:"+results[row].swap);
               //----------------- 
               
               begin=StringFind(var, "<td>",0)+4;                          //Find the beginning of the position
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               var = StringSubstr(var, end);
               results[row].profit= value;                                        //profit
               //Print("profit:"+results[row].profit);
               //-----------------     
                 
               begin=StringFind(var, "<td>",0)+4;                          //Find the beginning of the position
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               var = StringSubstr(var, end);
               results[row].balance= value;                                        //balance
               //Print("balance:"+results[row].balance);
               //----------------- 
               
               begin=StringFind(var, "<td>",0)+4;                          //Find the beginning of the position
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               var = StringSubstr(var, end);
               results[row].comment= value;                                        //comment
               //Print("comment:"+results[row].comment);
               //-----------------                                      

               row++;
            }
         break;  
      }  
       
         
   if(Erase_All_Object) ObjectsDeleteAll(0); 
   Comment("First trade opened - ",results[0].time, "  last trade closed - ",results[row-1].time);
   for(cnt=1;cnt<=row;cnt++) 
      {
         ArrayResize(orders,cnt);         
         orders[cnt-1]=(int)StringToInteger(results[cnt-1].deal);
      }   
   cntOrders=orders[ArrayMaximum(orders)];
   
   for(cnt=1;cnt<=cntOrders;cnt++) // check all trades
      {
         for(all=0;all<ArraySize(results);all++) //check all entry of one trade
            {
               if(cnt!=StringToInteger(results[all].deal)) continue;
               if(results[all].type=="buy" || results[all].type=="sell") {
                     type=results[all].type;
                     in_out=results[all].in_out;
                     opentime=results[all].time;
                     
                     lots=results[all].volume;
                     openprice=StringToDouble(results[all].open_price);                                 
                     ticket=cnt;
                     StringConcatenate(notes,"Deal #",ticket,"\nOrder #",results[all].order,"\nVolume: ",lots,"\nOpen time: ",opentime,"\nCommission: ",results[all].commission,
                     "\nSwap: ",results[all].swap,"\nProfit: ",results[all].profit,"\nBalance: ",results[all].balance,"\nComment: ",results[all].comment);
                     
                     name="Deal #"+results[all].deal;
                            
                     ObjectCreate(0,name, OBJ_ARROW, 0, StringToTime(opentime)+hour_shift*3600, openprice); 
                     
                     if(type=="buy") {
                        ObjectSetInteger(0,name, OBJPROP_COLOR, Aqua);
                        if(in_out=="in") {
                           ObjectSetInteger(0,name, OBJPROP_ARROWCODE, 236);
                        } else {
                           ObjectSetInteger(0,name, OBJPROP_ARROWCODE, 235);
                        }
                     
                     } else {
                        ObjectSetInteger(0,name, OBJPROP_COLOR, Tomato);
                        if(in_out=="in") {
                           ObjectSetInteger(0,name, OBJPROP_ARROWCODE, 238);
                        } else {
                           ObjectSetInteger(0,name, OBJPROP_ARROWCODE, 237);
                        }                        
                     }                       
                     
                     ObjectSetInteger(0,name, OBJPROP_BACK, false); 
                     ObjectSetInteger(0,name, OBJPROP_FONTSIZE, 10); 
                     ObjectSetString(0,name, OBJPROP_FONT, "Arial");     
                     ObjectSetString(0,name, OBJPROP_TOOLTIP,notes);
                     
                             
                  }

             } // end -check all entry of one trade

      }   //end -  check all trades            
FileClose(handle);
 
  }
//+------------------------------------------------------------------+
