// This Class will only Add values in the existing picklist fields
public class InsertOicklistValuesSFDC {
    public static void main(String ObjectAPIName, String fieldAPI, List<String> picklistValue,String recordtype){
        List<String> messages = new List<String>();
        try{
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            MetadataService.CustomField customField = (MetadataService.CustomField) service.readMetadata(
                'CustomField', new String[] { ObjectAPIName+'.'+fieldAPI }
            ).getRecords()[0];
            System.debug('customField'+JSON.serialize(customField.valueSet));
            List<metadataservice.CustomValue> customValueList = new List<metadataservice.CustomValue>();
            ////Add the following code in a For loop and put all values in a List of Custom Class with input Paramters
            for(String val : picklistValue){
                metadataservice.CustomValue customVal = new metadataservice.CustomValue();
                customVal.fullName = val;
                customVal.label= val;
                customVal.default_x=false ;
                customVal.isActive = true;
                customValueList.add(customVal);
            }
            List<metadataservice.CustomValue> existingval = customField.valueSet.valueSetDefinition.value;
            
            existingval.addAll(customValueList); /// use addAll method to add the entire list of Customvalues add in the for loop above
            MetadataService.Metadata[] finalMetadataList = new MetadataService.Metadata[] { customField };
                
                ////Below code is for addig values to record type
                MetadataService.Metadata[] mdRecordTypes;
            System.debug('recordtype before If '+recordtype);
            if(recordtype!=null){
                System.debug('recordtype = '+recordtype);
                MetadataService.PickListValue[] pickVals = new MetadataService.PickListValue[]{};
                    for(String val : picklistValue){
                        MetadataService.PickListValue newPickVal = new MetadataService.PickListValue();
                        newPickVal.isActive = true;
                        newPickVal.default_x = false;
                        newPickVal.fullName = val;
                        pickVals.add(newPickVal);
                    }
                List<String> recordTypeNames = new List<String>{recordtype} ; // get your list of record types either through a query or a describe call and put them into a list
                // Get the record type from the API
                mdRecordTypes = service.readMetadata('RecordType', recordTypeNames).getRecords();
                MetadataService.RecordType[] recordTypes = (MetadataService.RecordType[]) mdRecordTypes;
                
                List<MetadataService.RecordType> recordtypePickVal = new List<MetadataService.RecordType>();
             
                // loop through the record types and set the picklist values
                for(MetadataService.RecordType RT : recordTypes){

                    for(MetadataService.RecordTypePicklistValue pVal: RT.PicklistValues){
                        if(pVal.picklist == fieldAPI){
                            pVal.values.addAll(pickVals);
                        }
                    }
                    recordtypePickVal.add(RT);
                }			
                finalMetadataList.addAll(recordtypePickVal);

            }
            List<MetadataService.SaveResult> results =
                service.updateMetadata(finalMetadataList);
            MetadataService.SaveResult saveResult = results[0];
            
            System.debug('Messages'+saveResult);
        }catch(Exception e){
            system.debug('exception Message'+e.getMessage() +messages + e.getLineNumber()+e.getTypeName());
        }
    }
}
