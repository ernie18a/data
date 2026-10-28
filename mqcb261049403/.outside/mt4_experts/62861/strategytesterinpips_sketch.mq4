//+------------------------------------------------------------------+
//|                                           ShortTrendReversal.mq4 |
//|                                          Copyright © 2025, bialy |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright     "https://www.mql5.com/en/market/product/Short Trend Reversal"
#property link          "https://www.mql5.com/en/market/product/114909"
#property strict

#define EA_folder "Sketch_sample\\"
#define csv_folder "csv_done\\"

enum timeframes {M5=5,M15=15,M30=30,H1=60,H4=240,D1=1440};
enum enPrice    {CLOSE=PRICE_CLOSE,OPEN=PRICE_OPEN,HIGH=PRICE_HIGH,LOW=PRICE_LOW};

sinput string sep1 = "";//============= optimize params =============
extern int        variable1   = 12;
extern int        variable2   = 26;
extern int        variable3   = 9;
extern int        variable4   = 26;
sinput string sep2 = "";//============ html info params ============
sinput enPrice    Price       = 0; //Apply to
sinput bool       RiskManager = true;
input int         TakeProfit  = 50;
input int         StopLoss    = 30;
sinput string sep3 = "";//============== stats params ==============
sinput bool                      ext_opt_logs         = false;    //StrategyTester in pips (html file)
input double                     rule1                = 1.0;      //MathAbs(AccLoss) <  x * Initial Balance [currency]
input double                     rule2                = 1.0;      //MathAbs(maxDD) <  x * Total Profit [pips]
input double                     rule3                = 1.0;      //MathAbs(maxDD) <  x * Profit before maxDD [pips]
sinput bool                      final_test           = false;    //test selected results
input short                      idxArr               = 1;        //stage1 results array

double initial_balance;
string period_txt;
bool csv_exist = true;
datetime start_time;
//========================================================================================================================================================================================================
int OnInit() {
   start_time = TimeCurrent();
   period_txt = EnumToString((timeframes)_Period);
   initial_balance = AccountBalance();
   if(IsTesting()) {
      if(final_test && ext_opt_logs) ReadSelected(idxArr,csv_exist,variable1,variable2,variable3,variable4);
      DrawParams(variable1,variable2,variable3,variable4);
   }
   return(INIT_SUCCEEDED);
}
//========================================================================================================================================================================================================
void OnDeinit(const int reason) {
   if(IsOptimization() && ext_opt_logs) StatsGenerator(variable1,variable2,variable3,variable4);
   Print(variable1," | ",variable2," | ",variable3," | ",variable4);
}
/*double OnTester() { //I leave it as an example of usage
   if(IsOptimization() && ext_opt_logs) StatsGenerator(variable1,variable2,variable3,variable4);
   return(total_pips);
}*/
//========================================================================================================================================================================================================
void OnTick(void) {
   if(IsTesting() && final_test && !csv_exist) return;

//your EA code

   if(IsOptimization() && ext_opt_logs) DrawDawn();
}
//========================================================================================================================================================================================================
//========================================================================================================================================================================================================
double maxDD,closed_before_DD;short opened_cnt;
void DrawDawn() {
   double dd_pips=0,closed_pips=0; short buys=0,sells=0,opened=0;//double swaps=0;
   for(int i=0; i<OrdersTotal(); i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
         if(OrderType() == OP_BUY)  { dd_pips += (OrderClosePrice()-OrderOpenPrice())/_Point; buys++;  }
         if(OrderType() == OP_SELL) { dd_pips += (OrderOpenPrice()-OrderClosePrice())/_Point; sells++; }
         //swaps += OrderSwap();
      }
   }
   if(dd_pips < maxDD) {
      for(int i=0; i<OrdersHistoryTotal(); i++) {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) {
            if(OrderType() == OP_BUY)  {        closed_pips        += ((OrderClosePrice()-OrderOpenPrice())/_Point); }
            if(OrderType() == OP_SELL) {        closed_pips        += ((OrderOpenPrice()-OrderClosePrice())/_Point); }
         }
      }
      maxDD = dd_pips;
      closed_before_DD = closed_pips;
      //PrintFormat("=========================== >> %s | maxDD: %.1f | closed before: %.1f | Acc profit: %.2f | swaps: %.2f",TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES),dd_pips/10.f,closed_before_DD/10.f,AccountProfit(),swaps);
   }
   opened = MathMax(buys,sells);
   if(opened >= opened_cnt) opened_cnt = opened;
   if(AccountProfit() < 0 && MathAbs(AccountProfit()) > rule1*initial_balance) {//this rule depends on Lots
      maxDD *= 100;
      //PrintFormat("=========================== >> %s | maxDD: %.1f | closed before: %.1f | Acc profit: %.2f | swaps: %.2f",TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES),dd_pips/10.f,closed_before_DD/10.f,AccountProfit(),swaps);
   }
}
//========================================================================================================================================================================================================
void ReadSelected(const short idx, bool &exist, int &param1, int &param2, int &param3, int &param4) {
   if(idx <= 0) {   param1 = 0; param2 = 0; param3 = 0; param4 = 0; return;   }
   string file_array[]; short TestingArray[][5];
   string full_filename = EA_folder+csv_folder+_Symbol+"_"+period_txt+".csv";
   if(FileIsExist(full_filename)) {
      int fhandle = FileOpen(full_filename,FILE_READ|FILE_TXT);
      short fcnt=0;
      while(!FileIsEnding(fhandle)) {
         string full_line = FileReadString(fhandle);
         if(StringFind(full_line,"TF") != -1) continue;
         Print(full_line);
         StringReplace(full_line,"{","|");
         StringReplace(full_line,"}","|");
         StringSplit(full_line,'|',file_array);
         StringSplit(file_array[1],',',file_array);
         ArrayResize(TestingArray,fcnt+1);
         TestingArray[fcnt][0]   = (short)file_array[0];
         TestingArray[fcnt][1]   = (short)file_array[1];
         TestingArray[fcnt][2]   = (short)file_array[2];
         TestingArray[fcnt++][3] = (short)file_array[3];
      }
      FileClose(fhandle);
//-------------------------------------------------
      if(idx <= ArrayRange(TestingArray,0)) {
         param1 = TestingArray[idx-1][0];
         param2 = TestingArray[idx-1][1];
         param3 = TestingArray[idx-1][2];
         param4 = TestingArray[idx-1][3];
      }
      else {   param1 = 0; param2 = 0; param3 = 0; param4 = 0;    }
//-------------------------------------------------
      exist = true;
   }
   else {
      FolderCreate(EA_folder+csv_folder); //no need to check if exist, comment line if you want to create it manually
      int err = FileOpen(EA_folder+csv_folder+"create_csv_file_first.txt",FILE_WRITE);
      FileWriteString(err,full_filename+" file is missing");
      FileClose(err);
      Print("================================================================");
      Print("== >> missing file: "+full_filename+" << ==");
      Print("================================================================");
      param1 = 0; param2 = 0; param3 = 0; param4 = 0;
      exist = false;
   }
}
//========================================================================================================================================================================================================
double total_pips;
string AnalyzeTrades() { int cnt_sl=0,cnt_tp=0; double pip=0,_pip_profit=0,_pip_loss=0; int cnt_profit=0,cnt_loss=0,cnt_pendings=0;
   for(int i=0; i<OrdersHistoryTotal(); i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) {
         if(OrderType() == OP_BUY)  {        pip        = ((OrderClosePrice()-OrderOpenPrice())/_Point); }
         if(OrderType() == OP_SELL) {        pip        = ((OrderOpenPrice()-OrderClosePrice())/_Point); }
         if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP) { cnt_pendings++; continue; }

         if(pip >= 0) { cnt_profit++;  _pip_profit += pip;  }
         if(pip <  0) { cnt_loss++;    _pip_loss   += pip;  }
         if(StringFind(OrderComment(),"[sl]") != -1) cnt_sl++;
         if(StringFind(OrderComment(),"[tp]") != -1) cnt_tp++;
      }
   }
   int total = (cnt_profit+cnt_loss);
   string text;
   double profit_percent,loss_percent;
   if(total != 0) {
      profit_percent = (double)cnt_profit/(double)total*100.f;
      loss_percent = (double)cnt_loss/(double)total*100.f;
   }
   //total_pips = _pip_profit+_pip_loss; //for example OnTester()
   if(MathAbs(maxDD) > rule2*(_pip_profit+_pip_loss)) return("drop");
   if(MathAbs(maxDD) > rule3*closed_before_DD)        return("drop");
   if(_pip_profit+_pip_loss <= 0)                     return("drop");
   text = StringFormat("<td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>(%d)</td><td>%.2f%%</td><td>%.2f%%</td><td>%d</td><td>%d</td><td>%d</td>",total,cnt_profit,cnt_loss,opened_cnt,cnt_pendings,profit_percent,loss_percent,(int)((_pip_profit+_pip_loss)/10),(int)(maxDD/10),(int)((closed_before_DD+maxDD)/10));
   return(text);
}
//========================================================================================================================================================================================================
void StatsGenerator(const int param1, const int param2, const int param3, const int param4) {
   ulong pos=0;
   int n=1;
   FolderCreate(EA_folder+csv_folder); //no need to check if exist, comment line if you want to create it manually

   string line_part2 = AnalyzeTrades();
   if(line_part2 == "drop") return;
   string full_line = StringFormat("<td>{%2s,%2s,%2s,%2s}</td>%s",(string)param1,(string)param2,(string)param3,(string)param4,line_part2);

   if(!FileIsExist(EA_folder+"\\script.txt")) {
      int script_handle = FileOpen(EA_folder+"\\script.txt",FILE_WRITE|FILE_TXT);
      FileWriteString(script_handle,Functions());
      FileClose(script_handle);
   }
   if(final_test && !csv_exist) return;

   string full_filename = (final_test ? EA_folder+csv_folder+"opt_" : EA_folder) + _Symbol+"_"+period_txt+".html";
   int file_handle    = FileOpen(full_filename,FILE_READ|FILE_WRITE|FILE_TXT,"\n");

   if(file_handle != INVALID_HANDLE) {
      if(FileGetInteger(file_handle,FILE_SIZE) <= 50) {
         FileWriteString(file_handle,Head(file_handle));
      }
      else {
         while(!FileIsEnding(file_handle)) {
            string skip_line = FileReadString(file_handle);
            if(StringFind(skip_line,">{") != -1)   {  n++;        pos = FileTell(file_handle);  }
            else                                   {  if(n > 1)   break;   }
         }
         FileSeek(file_handle,pos,SEEK_SET);
      }
      FileWriteString(file_handle,StringFormat("\t\t\t<tr class='tr1'><td>%d</td>%s<td><input type='text' name='comment'/></td><td><input type='checkbox' name='select' value='%3s' onclick='getRow(this)'/></td></tr>\n",n,full_line,period_txt));
      FileWriteString(file_handle,Tail(file_handle));
      FileClose(file_handle);
   }
}
//========================================================================================================================================================================================================
string Head(const int f_handle) {
   string acc_num = (string)AccountNumber();
   string acc_name = StringFormat("%s",IsDemo() ? "demo" : "real");
   string EA_file = "<b>" + __FILE__ + "</b>";

   datetime file_date = (datetime)FileGetInteger(f_handle,FILE_CREATE_DATE);
   long end_date = (datetime)SeriesInfoInteger(_Symbol,PERIOD_CURRENT,SERIES_LASTBAR_DATE)+PeriodSeconds();
   string trading_days = (string)(5*((end_date - start_time)/3600/24)/7);

   string info_params = StringFormat("RiskM: <b>%s</b>, Apply to: <b>%s</b>, TP<b>%.1f</b>, SL<b>%.1f</b>, rules: <b>%.1f, %.1f, %.1f</b>",(RiskManager ? "true" : "false"),EnumToString(Price),TakeProfit,StopLoss,rule1,rule2,rule3);
   string script = final_test ? "'..\\script.txt' " : "'script.txt' ";
   string to_final = final_test ? "" : StringFormat("&nbsp;&nbsp;<a href='csv_done/opt_%s_%s.html'>>> FINAL TESTS</a>",_Symbol,period_txt);
   string res =
      "<!DOCTYPE html>\n<html lang='en'>\n<head>\n" +
         "\t<title>" + _Symbol + ", " + period_txt + (final_test ? ", FINAL TESTS" : "") + "</title>\n" +
         "\t<meta http-equiv='Pragma' content='no-cache'>\n" +
         "\t<script src=" + script + "type='text/javascript' defer></script>\n" +
         "\t<style type='text/css' media='screen'>\n" +
            "\t\t.tr1 {white-space: nowrap; text-align: center;}\n" +
            "\t\t.tr1:hover td {color: white; background: dimgrey !important;}\n" +
            "\t\t.tr1:nth-of-type(odd)  { background: #E0E0E0;}\n" +
            "\t\ttd {font: 8pt Tahoma,Arial;}\n" +
            "\t\t.td1 {padding-left:3px; padding-right:3px; white-space: nowrap; text-align: left;}\n" +
            "\t\tinput[type='checkbox']{ width: 11px; height: 11px;}[type='text']{font-size: 7pt; width: 80%}\n" +
         "\t</style>\n" +
      "</head>\n" +
      "<body marginheight=1>\n" +
      "\t<div align=center>\n" +
      "\t\t<div style='font: 20pt Times New Roman;margin-top:0'><b>" + AccountCompany() + "</b></div>\n" +
      "\t\t<table cellspacing=1 cellpadding=1 border=0 id='optimization' width=90%>\n" +
         "\t\t\t<tr><td colspan=2>Account No: <b>" + acc_num + "</b></td><td colspan=2>Type: <b>" + acc_name + "</b></td><td colspan=2>Currency: <b>" + AccountCurrency() + "</b></td><td colspan=3>Symbol: <b>" + _Symbol + ", " + period_txt + "</b>" + to_final + "</td><td colspan=2>EA file: " + EA_file + "</td><td colspan=3 align=right><b>" + TimeToString(file_date,TIME_DATE|TIME_MINUTES|TIME_SECONDS) + "</b> (local time)</td></tr>\n" +
         "\t\t\t<tr><td colspan=2 height=25><b>Optimization results:</b></td>\n" +
            "\t\t\t\t<td align=center nowrap><b><label for='best'>best:</label></b><input type='text' id='best' maxlength='2' value='30' style='height:12px; width:20px'/></td>\n" +         //value=30 used for autoselecting
            "\t\t\t\t<td align=center nowrap><b><label for='worst'>worst:</label></b><input type='text' id='worst' maxlength='2' value='20' style='height:12px; width:20px'/></td>\n" +      //value=20 used for autoselecting
            "\t\t\t\t<td align=center width=20px><button style='font-size: 10px; height:17px' type='button' onclick='PaintCells()'>refresh</button></td>\n" +
            "\t\t\t\t<td align=center>spread <b>" + StringFormat("%.1f",MarketInfo(_Symbol,MODE_SPREAD)/10.f) + "</b></td><td colspan=4 align=left nowrap>"  + info_params + "</td>\n" +
            "\t\t\t\t<td colspan=4 align=right nowrap id='trading_days' name='" + trading_days + "'>" +"date range: <b>"+ TimeToString(start_time,TIME_DATE) + "</b> to <b>"+ TimeToString(end_date,TIME_DATE) + "</b> (" + trading_days + " trading days)</td></tr>\n" +
         "\t\t\t<tr align=center bgcolor=#c0c0c0>\n";
//================
   res += "\t\t\t\t<td onclick='sortTable(0)' width=20px>N</td>\n";
   res += "\t\t\t\t<td width=100px>Signal Params</td>\n";
   res += "\t\t\t\t<td width=50px onclick='sortTable(2)'>Total trades</td>\n";
   res += "\t\t\t\t<td width=50px onclick='sortTable(3)'>Profit trades</td>\n";
   res += "\t\t\t\t<td width=50px onclick='sortTable(4)'>Loss trades</td>\n";
   res += "\t\t\t\t<td width=50px onclick='sortTable(5)'>Max 1-dir opened</td>\n";
   res += "\t\t\t\t<td width=50px onclick='sortTable(6)'>Canceled pends</td>\n";
   res += "\t\t\t\t<td width=60px onclick='sortTable(7)'>Profit [%]</td>\n";
   res += "\t\t\t\t<td width=60px onclick='sortTable(8)'>Loss [%]</td>\n";
   res += "\t\t\t\t<td width=60px onclick='sortTable(9)'>Profit pips</td>\n";
   res += "\t\t\t\t<td width=60px onclick='sortTable(10)'>maxDD pips</td>\n";
   res += "\t\t\t\t<td width=60px onclick='sortTable(11)'>realDD (closed-maxDD)</td>\n";
   res += "\t\t\t\t<td width=120px>Comment</td>\n";
   res += "\t\t\t\t<td width=20px><button style='font-size: 10px' type='button' onclick='SaveChecks()'>save</button></td>\n";
   res += "\t\t\t</tr>\n";
   return(res);
}
//========================================================================================================================================================================================================
string Tail(const int f_handle) {
   datetime start_date = (datetime)FileGetInteger(f_handle,FILE_CREATE_DATE);
   GlobalVariableSet("optimizing",1);
   datetime end_date = GlobalVariableTime("optimizing");
   GlobalVariableDel("optimizing");
   MqlDateTime time;
   TimeToStruct(end_date-start_date,time);
   string text = 
      "\t\t</table>\n" + 
      "\t\t<div><b>* * *</b></div>\n" +
      "\t\t<div style='font-size: 8pt;font-family:arial;'>optimizing time: <b>"+  StringFormat("%d:%02d:%02d",time.hour,time.min,time.sec)  +"</b> (based on the file creation time and the last creation GlobalVariable)</div>\n\t\t<br>\n" +
      "\t</div>\n" +
      "</body>\n</html>\n";
   return(text);
}
//========================================================================================================================================================================================================
string Functions() {
   string text =
      "let title = document.title;\n" +
      "title = title.split(', ');\n" +
      "let tr = document.getElementsByClassName('tr1');\n" +
      "let rows = Array.from(tr);\n" +
      "let checks = document.getElementsByName('select');\n" +
      "let prevCol=-1;\n"+
      "function sortTable(columnIndex) {\n" +
         "\tlet table = document.getElementById('optimization');\n" +
         "\tlet direction = 0;\n" +
         "\tlet currCol=columnIndex;\n" +
         "\tif(currCol != prevCol) {\n" +
         "\t\tdirection = (currCol == 0 || currCol == 4 || currCol == 8) ? 'asc' : 'desc';\n" +
         "\t\tprevCol = currCol;\n" +
         "\t} else {\n" +
         "\t\tif(rows.every(row => row.dataset.sortOrder === 'asc') || rows.every(row => row.dataset.sortOrder === 'desc')) {\n" + 
            "\t\t\tdirection = rows[0].dataset.sortOrder === 'desc' ? 'asc' : 'desc';\n" +
         "\t\t}\n" +
         "\t}\n" +
		   "\trows.sort((a, b) => {\n" +
   			"\t\tconst cellA = a.cells[columnIndex].innerText;\n" +
   			"\t\tconst cellB = b.cells[columnIndex].innerText;\n" +
   			"\t\tlet comparison = 0;\n" +
   			"\t\tif(columnIndex == 6) {\n" +
      			"\t\t\tif(cellA > cellB)\t\t\t\t\t\t\t\t\t\t\t\t\t\tcomparison = 1;\n" +
      			"\t\t\telse if(cellA < cellB)\t\t\t\t\t\t\t\t\t\t\t\t\tcomparison = -1;\n" +
			   "\t\t} else {\n" +
			      "\t\t\tif(Number(cellA.replace('%','')) >= Number(cellB.replace('%','')))		comparison = 1;\n" +
			      "\t\t\telse if(Number(cellA.replace('%','')) < Number(cellB.replace('%','')))	comparison = -1;\n" +
			   "\t\t}\n" +
			   "\t\treturn direction === 'asc' ? comparison : comparison * -1;\n" +
		"\t});\n" +
		"\trows.forEach((row, index) => {\n" +
		   "\t\trow.dataset.sortOrder = direction;\n" +
		   "\t\ttable.tBodies[0].appendChild(row);\n" +
		   "\t});\n" +
		   "\tPaintCells();\n"
      "}\n" +
"//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" +
      "function SaveChecks() {\n" +
         "\tlet head = ' TF;\\toptimize params;\\ttotal;\\tprofit;\\tloss;\\tmax;\\tpends;\\tprofit%;\\tloss%;\\tPpips;\\tDDpips;\\trealDD;\\t//comment\\n';\n" +
         "\tlet full_line = '';\n" +
      	"\tfor (let i=0; i<rows.length; i++) {\n" +
		      "\t\tif(checks.item(i).checked == true) {\n" +
               "\t\t\tfull_line += document.getElementsByName('select')[i].value+';\\t';\n" +
		         "\t\t\tfor (let j=1; j<rows[i].cells.length-2; j++) {\n" +
		            "\t\t\t\tfull_line += rows[i].cells[j].innerText+';\\t';\n" +
		         "\t\t\t}\n" +
		         "\t\t\tfull_line += '\\t//'+document.getElementsByName('comment')[i].value+'\\n';\n" +
		      "\t\t}\n" +
		   "\t}\n" +
	      "\tif(full_line != '') downloadCSVFile(head+full_line,title[0]+'_'+title[1]+'.csv');\n" +
      "}\n" +
"//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" +
      "function downloadCSVFile(csv_data,fname) {\n" +
   	   "\tCSVFile = new Blob([csv_data], {\n" +
   		   "\t\ttype: 'text/csv'\n" +
   	   "\t});\n" +
   	   "\tlet temp_link = document.createElement('a');\n" +
   	   "\ttemp_link.download = fname;\n" +
   	   "\tlet url = window.URL.createObjectURL(CSVFile);\n" +
   	   "\ttemp_link.href = url;\n" +
      	"\ttemp_link.style.display = 'none';\n" +
      	"\tdocument.body.appendChild(temp_link);\n" +
      	"\ttemp_link.click();\n" +
      	"\tdocument.body.removeChild(temp_link);\n" +
      "}\n" +
"//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" +
   "function PaintCells() {\n" +
   	"\tlet best = parseInt(document.getElementById('best').value);\n" +
   	"\tlet worst = parseInt(document.getElementById('worst').value);\n" +
   	"\tfor(let i=2; i<=11; i++) {\n" +
   		"\t\tif(i == 5 || i == 6 || i == 7  || i == 8) continue;\n" +
   		"\t\tlet myArray = new Array();\n" +
   		"\t\trows.forEach((row,index) => {\n" +
   			"\t\t\tmyArray.push(Number(rows[index].cells[i].innerText.replace('%','')));\n" +
   		"\t\t});\n" +
   		"\t\tif(myArray.length <= 1) break;\n" + 
         "\t\tif(best >= myArray.length)\t\tbest = parseInt(myArray.length/2)+1;\n" +
         "\t\tif(worst >= myArray.length)\t\tworst = parseInt(myArray.length/2)+1;\n" +
         "\t\tlet nth_best,nth_worst;\n" +
         "\t\tmyArray.sort(function(a, b){return b - a});//descent\n" +   
         "\t\tnth_best  = (i==4) ? myArray[myArray.length-best] : myArray[best-1];\n" +
         "\t\tnth_worst = (i==4) ? myArray[worst-1] : myArray[myArray.length-worst];\n" +
         "\t\trows.forEach((row,index) => {\n" +
            "\t\t\tlet cell_value = Number(rows[index].cells[i].innerText.replace('%',''));\n" +
            "\t\t\tif((cell_value >= nth_best && i!=4) || (cell_value <= nth_best && i==4)) {\n" +
               "\t\t\t\trows[index].cells[i].style.backgroundColor = '#DBFFDB';\n" +
               "\t\t\t\trows[index].cells[i].style.fontWeight = 'bold';\n" +
               "\t\t\t\trows[index].cells[i].classList.add('check');\n" +
            "\t\t\t}\n" +
            "\t\t\telse if((cell_value <= nth_worst && i!=4) || (cell_value >= nth_worst && i==4)) {\n" +
               "\t\t\t\trows[index].cells[i].style.backgroundColor = '#FFD9D9';\n" +
               "\t\t\t\trows[index].cells[i].style.fontWeight = 'bold';\n" +
               "\t\t\t\trows[index].cells[i].classList.add('uncheck');\n" +
            "\t\t\t} else {\n" +
            "\t\t\t\trows[index].cells[i].style.backgroundColor = '';\n" +
            "\t\t\t\trows[index].cells[i].style.fontWeight = 'normal';\n" +
            "\t\t\t\trows[index].cells[i].classList.remove('check');\n" +
            "\t\t\t\trows[index].cells[i].classList.remove('uncheck');\n" +
            "\t\t\t}\n" +
         "\t\t});\n" +
      "\t}\n" +
      "\tAutoSelect();\n" +
   "}\n" +
"//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" +
   "function AutoSelect() {\n" +
      "\tif(title[2] == 'FINAL TESTS') return;\n" +
      "\tchecks.forEach((row,index) => {\n" +
         "\t\tlet check9 = rows[index].cells[9].className;\n" +
         "\t\tlet check10 = rows[index].cells[10].className;\n" +
         "\t\tlet check11 = rows[index].cells[11].className;\n" +
         "\t\tlet check12 = rows[index].cells[12].className;\n" +
         "\t\tif(((check9 == 'check' && check10 == 'check') || (check9 == 'check' && check11 == 'check') || (check10 == 'check' && check11 == 'check')) && check10 != 'uncheck' && check12 != 'manual')\n" +
            "\t\t\tchecks.item(index).checked = true;\n" +
         "\t\telse if(check12 != 'manual')\n" +
            "\t\t\tchecks.item(index).checked = false;\n" +
         "\t\tCalcAVG(index);\n" +
      "\t});\n" +
   "}\n" +
"//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" +
   "function CalcAVG(row_idx) {\n" +
      "\tif(checks.item(row_idx).checked == true) {\n" +
         "\t\tlet tradingD = parseInt(document.getElementById('trading_days').getAttribute('name'));\n" +
         "\t\tlet trades = parseInt(rows[row_idx].cells[2].innerText);\n" +
         "\t\tdocument.getElementsByName('comment')[row_idx].value = Math.round(trades/tradingD*100)/100.0+' trades/day';\n" +
      "\t}\n" +
      "\telse document.getElementsByName('comment')[row_idx].value = '';\n" +
   "}\n" +
"//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" +
   "function getRow(cellObj) {\n" +
      "\tlet index = cellObj.parentNode.parentNode.rowIndex-3;\n" +
      "\trows[index].cells[12].classList.add('manual');\n" +
      "\tif(rows[index].style.backgroundColor == '')\n" +
		   "\t\trows[index].style.backgroundColor = '#D1E8FF';\n" +
	   "\telse\n" +
		   "\t\trows[index].style.backgroundColor = '';\n" +
      "\tCalcAVG(index);\n" +
   "}\n" +
"//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" +
   "PaintCells();\n";
   return(text);
}
//========================================================================================================================================================================================================
void DrawParams(const int param1, const int param2, const int param3, const int param4) {
   ChartSetInteger(0,CHART_SHOW_GRID,false);
   ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,true);
   ObjectCreate(0,"params",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"params",OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,"params",OBJPROP_XDISTANCE,2);
   ObjectSetInteger(0,"params",OBJPROP_YDISTANCE,30);
   ObjectSetText("params",StringFormat("{%2s,%2s,%3s,%3s }",(string)param1,(string)param2,(string)param3,(string)param4),8,"Arial",clrGainsboro);
}
//========================================================================================================================================================================================================
