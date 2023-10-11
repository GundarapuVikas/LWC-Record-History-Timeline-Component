public class CaseManager {

    public static List<String> getStatusValues(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }

    public static List<SObject> getCaseHistory(Id recordId){
        return [SELECT CreatedDate,OldValue,NewValue FROM CaseHistory WHERE CaseId=:recordId AND Field='Status'];
    }

    public static Decimal findDaysBetween(Datetime dateTime1, Datetime dateTime2) {
        Long timeDifferenceInMilliseconds = dateTime2.getTime() - dateTime1.getTime();
        Decimal millisecondsInDay = 24 * 60 * 60 * 1000;
        Decimal daysDifference = (Decimal) timeDifferenceInMilliseconds / millisecondsInDay;
        return daysDifference.setScale(2);        
    }


    public static void setStateMap(Map<String,Decimal> stateMap,List<SObject> caseHistoryData){
        Integer i = 0;
        Integer j = 1;
        while (j < caseHistoryData.size()) {
            Datetime createdDateJ=(Datetime) caseHistoryData[j].get('CreatedDate');
            Datetime createdDateI=(Datetime) caseHistoryData[i].get('CreatedDate');
            Decimal daysBetween = findDaysBetween(createdDateI, createdDateJ);
            String value = (String) caseHistoryData[i].get('OldValue');
            if (!stateMap.containsKey(value)) {
                stateMap.put(value, 0);
            }
            stateMap.put(value, stateMap.get(value) + daysBetween);
            
            i++;
            j++;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Decimal> getCaseTrackData(Id recordId){
        try {
            Map<String,Decimal> stateMap=new Map<String,Decimal>();
            List<String> stateValues=getStatusValues();
            List<Map<String,Decimal>> caseTrackData=new List<Map<String,Decimal>>();
            for(String s:stateValues){
                stateMap.put(s,0);
            }
            List<SObject> caseHistoryData=getCaseHistory(recordId);
            setStateMap(stateMap,caseHistoryData);
            return stateMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}