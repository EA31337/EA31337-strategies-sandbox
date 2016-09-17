//+------------------------------------------------------------------+
//|                                                      CatFX50.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.forex-tsd.com/showthread.php?t=523"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Aqua
//---- input parameters
//Trading Time in server Time
extern int confirm_StepMA_Bars=2;
extern int TradeTimeFrom=0;
extern int TradeTimeTo=24;
extern int alert_ON=0;//ON=1,OFF=0
//---- buffers
double Long[];
double Short[];
double EMA50[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,Long);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,Short);
   SetIndexEmptyValue(1,0.0);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexLabel(2,"EMA50");
   SetIndexBuffer(2,EMA50);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexEmptyValue(2,0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted(),i,j;
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=2;
   //variables
   double stepma00,stepma01,stepma10,stepma11;
   //Main  roop
   int totalcount=0;
   for(i=limit; i>=0; i--)
     {
      EMA50[i]=iMA(NULL,0,50,0,MODE_EMA,PRICE_MEDIAN,i);
      if (TimeHour(Time[i])>=TradeTimeFrom&&TimeHour(Time[i])<=TradeTimeTo)
        {
         //Long check start
         if ((Open[i+1]<EMA50[i+1])&&(Close[i+1]>EMA50[i+1])&&Open[i]>EMA50[i])//cross EMA50
           {
            for(j=confirm_StepMA_Bars; j>=0; j--)
              {
               stepma00=iCustom(NULL,0,"StepMA_Stoch_v1",10,1.1,0,0,i+j);
               stepma01=iCustom(NULL,0,"StepMA_Stoch_v1",10,1.1,0,1,i+j);
               stepma10=iCustom(NULL,0,"StepMA_Stoch_v1",10,1.1,0,0,i+j+1);
               stepma11=iCustom(NULL,0,"StepMA_Stoch_v1",10,1.1,0,1,i+j+1);
               totalcount+=4;
               if ((stepma10<stepma11)&&(stepma00>stepma01))//StepMA cross
                 {
                  Long[i]=(Low[i])-iATR(NULL,0,5,i)/2 ;
                  if (i==0&&alert_ON==1)
                     Alert(TimeToStr(Time[i],TIME_MINUTES)," CatFX50 ",Symbol()," BUY");
                 }
              }
           }
         //Long check end
         //Short check start
         if ((Open[i+1]>EMA50[i+1])&&(Close[i+1]<EMA50[i+1]&&Open[i]<EMA50[i]))//cross EMA50
           {
            for(j=confirm_StepMA_Bars; j>=0; j--)
              {
               stepma00=iCustom(NULL,0,"StepMA_Stoch_v1",10,1.1,0,0,i+j);
               stepma01=iCustom(NULL,0,"StepMA_Stoch_v1",10,1.1,0,1,i+j);
               stepma10=iCustom(NULL,0,"StepMA_Stoch_v1",10,1.1,0,0,i+j+1);
               stepma11=iCustom(NULL,0,"StepMA_Stoch_v1",10,1.1,0,1,i+j+1);
               totalcount+=3;
               if ((stepma10>stepma11)&&(stepma00<stepma01))//StepMA cross
                 {
                  Short[i]=High[i]+iATR(NULL,0,5,i)/2;
                  if (i==0&&alert_ON==1)
                     Alert(TimeToStr(Time[i],TIME_MINUTES)," CatFX50 ",Symbol()," SELL");
                 }
              }
           }
         //Short check end
        }
     }
   Print("Bars=",Bars,"  Calls of iCustom(NULL,0,\"StepMA_Stoch_v1\"= ",totalcount); 
   Comment("Bars=",Bars,"  Calls of iCustom(NULL,0,\"StepMA_Stoch_v1\"= ",totalcount) ;
   return(0);
  }
//+------------------------------------------------------------------+