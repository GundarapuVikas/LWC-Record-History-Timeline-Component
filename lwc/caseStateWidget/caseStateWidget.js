import { LightningElement,api,wire,track } from 'lwc';  
import getCaseTrackData from '@salesforce/apex/CaseManager.getCaseTrackData';



export default class CaseStateWidget extends LightningElement {
    @api recordId;
    @track caseTrackData=[];

    @wire(getCaseTrackData,{recordId:'$recordId'})
    loadCaseTrackData({data,error}){
        if(data){
            for(let key in data){
                this.caseTrackData.push({state:key,duration:data[key]});
            }
        }
        else if(error){
            alert('Error:',error.message);
        }
    } 
}