//+------------------------------------------------------------------+
//|                                                      Elliott.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                                           kenorb |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property version   "1.00"
#property strict

#include  <Convert.mqh>


extern int confirm_StepMA_Bars=2;
extern int TradeTimeFrom=0;
extern int TradeTimeTo=24;
extern int alert_ON=0;//ON=1,OFF=0
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CatFX50
  {

public:

   double            EMA50[];
   double            stepma00,stepma01,stepma10,stepma11;

   void Update(int tf=PERIOD_M1)
     {
      int i=0;
      int j= 0;
      int totalcount=0;

      EMA50[i]=iMA(NULL,0,50,0,MODE_EMA,PRICE_MEDIAN,i);
      if(TimeHour(Time[i])>=TradeTimeFrom && TimeHour(Time[i])<=TradeTimeTo)
        {
         //Long check start
         if((Open[i+1]<EMA50[i+1]) && (Close[i+1]>EMA50[i+1]) && Open[i]>EMA50[i])//cross EMA50
           {
            for(j=confirm_StepMA_Bars; j>=0; j--)
              {
               stepma00=iCustom(NULL,tf,"StepMA_Stoch_v1",10,1.1,0,0,i+j);
               stepma01=iCustom(NULL,tf,"StepMA_Stoch_v1",10,1.1,0,1,i+j);
               stepma10=iCustom(NULL,tf,"StepMA_Stoch_v1",10,1.1,0,0,i+j+1);
               stepma11=iCustom(NULL,tf,"StepMA_Stoch_v1",10,1.1,0,1,i+j+1);
               totalcount+=4;

              }
            //Long check end
            //Short check start
            if((Open[i+1]>EMA50[i+1]) && (Close[i+1]<EMA50[i+1] && Open[i]<EMA50[i]))//cross EMA50
              {
               for(j=confirm_StepMA_Bars; j>=0; j--)
                 {
                  stepma00=iCustom(NULL,tf,"StepMA_Stoch_v1",10,1.1,0,0,i+j);
                  stepma01=iCustom(NULL,tf,"StepMA_Stoch_v1",10,1.1,0,1,i+j);
                  stepma10=iCustom(NULL,tf,"StepMA_Stoch_v1",10,1.1,0,0,i+j+1);
                  stepma11=iCustom(NULL,tf,"StepMA_Stoch_v1",10,1.1,0,1,i+j+1);
                  totalcount+=3;

                 }

              }

           }
        }
     }

   bool Signal(int cmd,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {
 
      if((stepma10<stepma11) && (stepma00>stepma01) && cmd==OP_BUY)
         return true;


      if((stepma10>stepma11) && (stepma00<stepma01) && cmd==OP_SELL)
         return true;


      return false;

     }

  };
//+------------------------------------------------------------------+
