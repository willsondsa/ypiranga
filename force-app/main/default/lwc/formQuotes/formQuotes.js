import { LightningElement,api,wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import saveRecords from '@salesforce/apex/FormQuoteController.SaveRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class FormQuotes extends LightningElement {
    @api records=[]
    @api fields=['IPI_Client__c','IPI_Truck__c','IP_Quantity__c','IPI_Type__c'];
    @api objectApiName="IPI_Quote__c"
    @api listToCreate=[];
    enablebutton=true;
    load=false

 initTable(){
 this.records=[]
 for(var i=0;i<10;i++){
        let idd=Date.now().toString(36) + Math.random().toString(36).substr(2)+i;
        this.records.push({fakeId:idd,selected:false})
    }  
 }
 handleSelectLine(event){
    var idRow=event.target.dataset.id
    var field;
    var valuefield;
    if(event.target.fieldName==undefined){
        field='selected'
        valuefield=event.target.checked
    }else{
        field=event.target.fieldName
        valuefield=event.target.value
    }
    this.records.forEach(dta=>{
        if(dta.fakeId==idRow){
            dta[field]= valuefield;
        }
    })
    this.enablebutton =this.records.filter(x=>x.selected==true).length==0;
    
 }  

   connectedCallback(){
    this.initTable();
   }

   dispatchEventToast(model){
    const evt = new ShowToastEvent(model);
    this.dispatchEvent(evt);
   }
   saveRecords(event){
  
   var savedta=[]
   this.records.forEach(x=>{
    if(x.selected){
        let quote={}
        Object.keys(x).forEach(key=>{
            if(key!="selected" && key!="fakeId")
              quote[key]=x[key];
        })
        savedta.push(quote)
    }
   })
    console.log("sdhjgdh ",savedta);
   if(savedta.length>0){
    this.load=true;
    saveRecords ({ quotes:savedta }).then(result=>{
        if(result){
            this.load=false;
            console.log("result ",result);
            this.dispatchEventToast({
                title: "Sucess",
                message: "Successfully Saved Records",
                variant: 'success',
            });
            this.initTable();
        }
        }).catch(error => {
        this.load=false;
         console.log("Handle error. Details "+error.message)
         this.dispatchEventToast({
            title: "Error saving record",
            message: error.body.pageErrors[0].message,
            variant: 'error',
        });
         // Handle error. Details in error.message.
     })
   }


   }
}