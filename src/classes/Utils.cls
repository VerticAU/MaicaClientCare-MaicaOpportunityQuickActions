//SECURED!
public inherited sharing class Utils {

    /**
     * ==============================================================================================================
     *                                           LAZY PROPERTIES
     * ==============================================================================================================
     */

    public static PicklistExtensions picklists {
        get {
            if (picklists == null) {
                picklists = new PicklistExtensions();
            }
            return picklists;
        } private set; }

    public static DateExtensions dates {
        get {
            if (dates == null) {
                dates = new DateExtensions();
            }
            return dates;
        } private set; }

    public static StringExtensions strings {
        get {
            if (strings == null) {
                strings = new StringExtensions();
            }
            return strings;
        } private set; }

    public static UserExtensions users {
        get {
            if (users == null) {
                users = new UserExtensions();
            }
            return users;
        } private set; }

    public static SObjectExtensions sObjects {
        get {
            if (sObjects == null) {
                sObjects = new SObjectExtensions();
            }
            return sObjects;
        } private set; }

    public static URLExtensions URLs {
        get {
            if (URLs == null) {
                URLs = new URLExtensions();
            }
            return URLs;
        } private set; }

    public static EmailExtensions emails {
        get {
            if (emails == null) {
                emails = new EmailExtensions();
            }
            return emails;
        } private set; }

    public static EncodingExtensions encodings {
        get {
            if (encodings == null) {
                encodings = new EncodingExtensions();
            }
            return encodings;
        } private set; }

    public static ArrayExtensions arrays {
        get {
            if (arrays == null) {
                arrays = new ArrayExtensions();
            }
            return arrays;
        } private set; }

//    public static FormatExtensions formats {
//        get {
//            if (formats == null){
//                formats = new FormatExtensions();
//            }
//            return formats;
//        } private set; }

    public static OrgExtensions orgs {
        get {
            if (orgs == null){
                orgs = new OrgExtensions();
            }
            return orgs;
        } private set; }

    public static ObjectExtensions objects {
        get {
            if (objects == null){
                objects = new ObjectExtensions();
            }
            return objects;
        } private set; }

//    public static XMLExtensions XMLs {
//        get {
//            if (XMLs == null) {
//                XMLs = new XMLExtensions();
//            }
//            return XMLs;
//        } private set; }

    public static TemplateExtensions templates {
        get {
            if (templates == null) {
                templates = new TemplateExtensions();
            }
            return templates;
        } private set; }


    /**
     * ==============================================================================================================
     *                                           PICKLIST EXTENSIONS
     * ==============================================================================================================
     */

    public inherited sharing class PicklistExtensions {

        public Set<String> getPicklistAsSetStrings(Schema.SObjectField sObjectField) {
            return getPicklistAsSetStrings(sObjectField, null);
        }

        public Set<String> getPicklistAsSetStrings(Schema.SObjectField sObjectField, Set<String> excludingValues) {
            Set<String> picklistValues;

            if (sObjectField.getDescribe().getType() == Schema.DisplayType.MULTIPICKLIST || sObjectField.getDescribe().getType() == Schema.DisplayType.PICKLIST) {
                picklistValues = new Set<String>();
                List<Schema.PicklistEntry> pickListEntries = sObjectField.getDescribe().getPicklistValues();

                for(Schema.PicklistEntry pickListEntryVar : pickListEntries){
                    if (excludingValues == null || !excludingValues.contains(pickListEntryVar.getValue())){
                        picklistValues.add(pickListEntryVar.getValue());
                    }
                }
            }

            return picklistValues;
        }

        public List<Structs.SelectOption> getPicklistValuesAsSelectOptions(Schema.SObjectField sObjectField){
            return getPicklistValuesAsSelectOptions(sObjectField, null);
        }

        public List<Structs.SelectOption> getPicklistValuesAsSelectOptions(Schema.SObjectField sObjectField, Set<String> excuding){
            List<Structs.SelectOption> selectOptions = new List<Structs.SelectOption>();
            List<Schema.PicklistEntry> pickListEntries = sObjectField.getDescribe().getPicklistValues();

            for( Schema.PicklistEntry pickListEntry : pickListEntries){
                if (excuding == null || !excuding.contains(pickListEntry.getValue())){
                    selectOptions.add(new Structs.SelectOption(pickListEntry.getValue(), pickListEntry.getLabel()));
                }
            }
            return selectOptions;
        }

        public Map<String, List<Structs.SelectOption>> getPicklistOptionsMap(Set<SObjectField> fields){

            Map<String, List<Structs.SelectOption>> result = new Map<String, List<Structs.SelectOption>>();

            for(SObjectField field : fields){
                String key = this.getFieldKey(field);
                result.put(key, this.getPicklistValuesAsSelectOptions(field));
            }

            return result;
        }

        public Map<String, Map<String, List<Structs.SelectOption>>> getDependentPicklistOptionsMap(Map<SObjectType, Map<SObjectField, SObjectField>> dependentFieldsBySObjectType) {

            Map<String, Map<String, List<Structs.SelectOption>>> result = new Map<String, Map<String, List<Structs.SelectOption>>>();

            for (SObjectType sObjectType : dependentFieldsBySObjectType.keySet()) {
                Map<SObjectField, SObjectField> dependentFields = dependentFieldsBySObjectType.get(sObjectType);
                if (dependentFields != null) {
                    for (SObjectField dependentField : dependentFields.keySet()) {
                        SObjectField controllingField = dependentFields.get(dependentField);

                        String key = this.getFieldKey(dependentField);
                        result.put(key, this.getDependentOptions(sObjectType, controllingField, dependentField));
                    }
                }
            }

            return result;
        }

        private String getFieldKey(SObjectField field){
            return sObjects.fieldToProperty(field) + 'Options';
        }

        // http://titancronus.com/blog/2014/05/01/salesforce-acquiring-dependent-picklists-in-apex/
//        public Map<String, List<Structs.SelectOption>> getDependentOptionsDeprecated(Schema.SObjectType pType, Schema.SObjectField controllingField, Schema.SObjectField dependentField){
//
//            final String pControllingFieldName = controllingField.getDescribe().getName();
//            final String pDependentFieldName = dependentField.getDescribe().getName();
//
//            Map<String, List<Structs.SelectOption>> objResults = new Map<String, List<Structs.SelectOption>>();
//            if (pType==null)
//                return objResults;
//            Bitset BitSetInstance = new Bitset();
//            Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
//            //verify field names
//            if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName))
//                return objResults;
//            //get the control values
//            List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
//            //get the dependent values
//            List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();
//            objFieldMap = null;
//            List<Integer> lstControllingIndexes = new List<Integer>();
//            //iterate through the values and get the ones valid for the controlling field name
//            //set up the results
//            for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){
//                //get the pointer to the entry
//                Schema.PicklistEntry ctrl_entry = ctrl_ple[pControllingIndex];
//                //get the label
//                String pControllingLabel = ctrl_entry.getLabel();
//                //create the entry with the label
//                objResults.put(pControllingLabel,new List<Structs.SelectOption>());
//                //keep track of the controlling indexes
//                lstControllingIndexes.add(pControllingIndex);
//            }
//            //cater for null and empty
//            objResults.put('',new List<Structs.SelectOption>());
//            objResults.put(null,new List<Structs.SelectOption>());
//            //load all dep entries
//            List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
//            List<TPicklistEntry> objDS_Entries = new List<TPicklistEntry>();
//            //add all entries
//            for(Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++){
//                //get the pointer to the dependent index
//                Schema.PicklistEntry dep_entry = dep_ple[pDependentIndex];
//                objEntries.add(dep_entry);
//
//            }
//            //serialize once
//            objDS_Entries = (List<TPicklistEntry>)JSON.deserialize(JSON.serialize(objEntries), List<TPicklistEntry>.class);
//            List<Integer> validIndexes;
//            for (TPicklistEntry objDepPLE : objDS_Entries){
//                //if valid for is empty, skip
//                if (objDepPLE.validFor==null || objDepPLE.validFor==''){
//                    continue;
//                }
//                //get the test for the controlling indexes
//                validIndexes = BitSetInstance.testBits(objDepPLE.validFor,lstControllingIndexes);
//                for (Integer validIndex : validIndexes){
//                    //get the label
//                    String pControllingLabel = ctrl_ple[validIndex].getLabel();
//                    objResults.get(pControllingLabel).add(new Structs.SelectOption(objDepPLE.value, objDepPLE.label));
//                }
//            }
//            objEntries = null;
//            objDS_Entries = null;
//            objResults.remove('');
//            objResults.remove(null);
//            return objResults;
//        }

        public Map<String, List<Structs.SelectOption>> getDependentOptions(Schema.SObjectType pType, Schema.SObjectField controllingField, Schema.SObjectField dependentField) {
            Map<String,List<Structs.SelectOption>> mapResults = new Map<String,List<Structs.SelectOption>>();

            final String pControllingFieldName = controllingField.getDescribe().getName();
            final String pDependentFieldName = dependentField.getDescribe().getName();

            //verify/get object schema
            //Schema.SObjectType pType = Schema.getGlobalDescribe().get(pObjName);
            if ( pType == null ) return mapResults;
            Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();

            //verify field names
            if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName)) return mapResults;

            //get the control & dependent values
            List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
            List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();

            //clear heap
            objFieldMap = null;

            //initialize results mapping
            for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){
                mapResults.put( ctrl_ple[pControllingIndex].getValue(), new List<Structs.SelectOption>());
            }
            //cater for null and empty
            mapResults.put('', new List<Structs.SelectOption>());
            mapResults.put(null, new List<Structs.SelectOption>());

            //serialize dep entries
            List<TPicklistEntry> objDS_Entries = new List<TPicklistEntry>();
            objDS_Entries = (List<TPicklistEntry>)JSON.deserialize(JSON.serialize(dep_ple), List<TPicklistEntry>.class);

            List<Integer> validIndexes;
            for (TPicklistEntry objDepPLE : objDS_Entries){

                validIndexes = cnvBits(objDepPLE.validFor);
                //System.Debug('cnvBits: [' + objDepPLE.label + '] = ' + validIndexes);

                for (Integer validIndex : validIndexes){
                    mapResults.get( ctrl_ple[validIndex-1].getValue() ).add(new Structs.SelectOption(objDepPLE.value, objDepPLE.label));
                }
            }

            //clear heap
            objDS_Entries = null;

            mapResults.remove(null);
            mapResults.remove('');

            return mapResults;
        }

//        public List<Structs.SelectOption> getRecordTypeOptions(SObjectType sObjType, String recordTypeApiName, String fieldName) {
//            List<Structs.SelectOption> result = new List<Structs.SelectOption>();
//
//            Map<String, List<Structs.SelectOption>> recordTypeOptions = this.getRecordTypeOptions(sObjType, recordTypeApiName);
//
//            if (recordTypeOptions.containsKey(fieldName)) {
//                return recordTypeOptions.get(fieldName);
//            }
//
//            return result;
//        }

//        public Map<String, List<Structs.SelectOption>> getRecordTypeOptions(SObjectType sObjType, String recordTypeApiName) {
//            Map<String, List<Structs.SelectOption>> result = new Map<String, List<Structs.SelectOption>>();
//
//            Map<String, Map<String, List<Structs.SelectOption>>> recordTypeOptions = this.getRecordTypeOptions(sObjType);
//
//            if (recordTypeOptions.containsKey(recordTypeApiName)) {
//                return recordTypeOptions.get(recordTypeApiName);
//            }
//
//            return result;
//        }

//        public Map<String, Map<String, List<Structs.SelectOption>>> getRecordTypeOptions(SObjectType sObjType) {
//            Map<String, Map<String, List<Structs.SelectOption>>> resultMap = new Map<String, Map<String, List<Structs.SelectOption>>>();
//
//            try {
//
//                SObject setting = SettingService.getMetadataType(Schema.getGlobalDescribe().get('Setting__mdt'), sObjType.getDescribe().getName().replace('__c', '_c'));
//
//                if (setting == null) {
//                    return resultMap;
//                }
//
//                Map<String, Object> valueMap = (Map<String, Object>) JSON.deserializeUntyped((String) setting.get('Value__c'));
//
//                for (String recordTypeApiName : valueMap.keySet()) {
//                    Map<String, Object> availablePicklists = (Map<String, Object>) valueMap.get(recordTypeApiName);
//
//                    resultMap.put(recordTypeApiName, new Map<String, List<Structs.SelectOption>>());
//
//                    for (String fieldName : availablePicklists.keySet()) {
//                        List<Object> picklistValues = (List<Object>) availablePicklists.get(fieldName);
//
//                        List<Structs.SelectOption> selectOptions = new List<Structs.SelectOption>();
//
//                        for (Object picklistVal : picklistValues) {
//                            Map<String, Object> val = (Map<String, Object>) picklistVal;
//
//                            String value = (String) val.get('value');
//                            String label = (String) val.get('label');
//
//                            selectOptions.add(new Structs.SelectOption(
//                                value,
//                                label == null ? value : label
//                            ));
//                        }
//
//                        resultMap.get(recordTypeApiName).put(fieldName, selectOptions);
//                    }
//                }
//
//            } catch (Exception ex) {
////                hey.Logger.exception(ex);
//            } finally {
////                hey.Logger.publish();
//            }
//
//            return resultMap;
//        }

        public void convertFlowPicklistFieldValues(SObject recordVar) {
            Set<SObjectField> picklistFields = Utils.sObjects.getFieldsByTypes(recordVar.getSObjectType(), new Set<DisplayType>{
                DisplayType.PICKLIST
            });
//            System.debug(picklistFields);
            Map<String, Object> populatedFieldsMap = recordVar.getPopulatedFieldsAsMap();
//            System.debug(populatedFieldsMap);
            for (SObjectField fieldVar : picklistFields) {
                if (!populatedFieldsMap.containsKey('' + fieldVar)) {
                    continue;
                }
                try {
                    Object val = recordVar.get(fieldVar);
                    if (val == null) {
                        continue;
                    }
                    String strVal = '' + val;
                    recordVar.put(fieldVar, strVal);
                } catch (Exception e) {
                }
            }
        }
    }


    /**
     * ==============================================================================================================
     *                                      DATE AND DATETIME EXTENSIONS
     * ==============================================================================================================
     */

    public inherited sharing class DateExtensions {

        public Datetime parseDatetimeAnyFormat(String datetimeStr, String format) {
            return this.parseDatetimeAnyFormat(datetimeStr, format, false);
        }

        public Datetime parseDatetimeAnyFormat(String datetimeStr, String format, Boolean isGMT) {
            if (String.isBlank(datetimeStr)) {
                return null;
            }

            Datetime datetimeVar = null;

            try {

                String formatDelimiters = format.replaceAll('DD|dd|d|MM|M|YYYY|yyyy|YY|yy|mm|m|HH|hh|H|h|SS|ss|S|s|A|a', '##');

                Set<String> delimitersSet = new Set<String>(formatDelimiters.split('##'));
                delimitersSet.remove(null);
                delimitersSet.remove('');
                delimitersSet.add(' ');
                List<String> delimiters = new List<String>(delimitersSet);

                String formatPartsStr = format.replaceAll('[[' + String.join(delimiters, ']]|[[') + ']]', '~');

                List<String> formatParts = formatPartsStr.split('~');

                String datetimePartsStr = datetimeStr.replaceAll('[[' + String.join(delimiters, ']]|[[') + ']]', '~');

                List<String> datetimeParts = datetimePartsStr.split('~');

                Datetime now = Datetime.now();
                Integer year = now.year();
                Integer month = now.month();
                Integer day = now.day();
                Integer hour = now.hour();
                Integer minute = now.minute();
                Integer second = now.second();
                String a;

                for (Integer i = 0; i < formatParts.size(); i++) {
                    String formatPart = formatParts[i];
                    String value = datetimeParts[i];

                    if ('yyyy'.equalsIgnoreCase(formatPart)) {
                        year = Integer.valueOf(value);
                    }
                    if ('yy'.equalsIgnoreCase(formatPart)) {
                        year = Integer.valueOf(value) + 2000;
                    }
                    if ('MM'.equals(formatPart) || 'M'.equals(formatPart)) {
                        month = Integer.valueOf(value);
                    }
                    if ('dd'.equalsIgnoreCase(formatPart) || 'd'.equalsIgnoreCase(formatPart)) {
                        day = Integer.valueOf(value);
                    }
                    if ('hh'.equalsIgnoreCase(formatPart) || 'h'.equalsIgnoreCase(formatPart)) {
                        hour = Integer.valueOf(value);
                    }
                    if ('mm'.equals(formatPart) || 'm'.equals(formatPart)) {
                        minute = Integer.valueOf(value);
                    }
                    if ('ss'.equalsIgnoreCase(formatPart) || 's'.equalsIgnoreCase(formatPart)) {
                        second = Integer.valueOf(value);
                    }
                    if ('a'.equalsIgnoreCase(formatPart)) {
                        a = value;
                    }
                }

                if ('AM'.equalsIgnoreCase(a)) {
                    if (hour == 12) {
                        hour = 0;
                    }
                } else if ('PM'.equalsIgnoreCase(a)) {
                    if (hour != 12) {
                        hour = hour + 12;
                    }
                }

                datetimeVar = Datetime.newInstance(year, month, day, hour, minute, second);

                if(isGMT){
                    datetimeVar = Datetime.newInstanceGmt(year, month, day, hour, minute, second);
                } else {
                    datetimeVar = Datetime.newInstance(year, month, day, hour, minute, second);
                }

            } catch(Exception ex) {
                ex.setMessage('Invalid date: ' + datetimeStr + ': ' + ex.getMessage());
                throw ex;
            }

            return datetimeVar;
        }

//        public Datetime parseDatetimeAnyFormatDeprecated(String datetimeStr, String format) {
//            if (String.isBlank(datetimeStr)) {
//                return null;
//            }
//
//            if (datetimeStr < format) {
//                format = format.substring(0, datetimeStr.length());
//            }
//
//            datetimeStr = datetimeStr.toLowerCase();
//
//            Datetime datetimeVar = null;
//            Datetime now = Datetime.now();
//            try {
//                // YEAR
//                Integer year = now.year();
//                Integer index = format.indexOf('YYYY');
//                if (index == -1) {
//                    index = format.indexOf('YY');
//                    if (index != -1) {
//                        year = Integer.valueOf(datetimeStr.substring(index, index + 2));
//                    }
//                } else {
//                    year = Integer.valueOf(datetimeStr.substring(index, index + 4));
//                }
//
//                // MONTH
//                Integer month = now.month();
//                index = format.indexOf('MM');
//                if (index != -1) {
//                    month = Integer.valueOf(datetimeStr.substring(index, index + 2));
//                }
//
//                // DAY
//                Integer day = now.day();
//                index = format.indexOf('DD');
//                if (index != -1) {
//                    day = Integer.valueOf(datetimeStr.substring(index, index + 2));
//                }
//
//                // HOUR
//                Integer hour = now.hour();
//                index = format.indexOf('hh');
//                if (index != -1) {
//                    hour = Integer.valueOf(datetimeStr.substring(index, index + 2));
//                }
//
//                // MINUTE
//                Integer minute = now.minute();
//                index = format.indexOf('mm');
//                if (index != -1) {
//                    minute = Integer.valueOf(datetimeStr.substring(index, index + 2));
//                }
//
//                // SECOND
//                Integer second = now.second();
//                index = format.indexOf('ss');
//                if (index != -1) {
//                    second = Integer.valueOf(datetimeStr.substring(index, index + 2));
//                }
//
//                // AM/PM MARKER
//                format = format.containsIgnoreCase('aa') ? format : format.replace('a', 'aa').replace('A', 'aa').replace('am', 'aa').replace('AM', 'aa');
//                index = format.indexOf('aa');
//                if (index != -1) {
//                    String a = datetimeStr.substring(index, index + 2);
//                    if ('pm'.equalsIgnoreCase(a) && hour <= 12) {
//                        hour += 12;
//                    }
//                }
//
//                datetimeVar = Datetime.newInstance(year, month, day, hour, minute, second);
//                //datetimeVar = datetimeVar.addSeconds(UserInfo.getTimeZone().getOffset(datetimeVar) / 1000);
//            } catch(Exception ex) {
//                ex.setMessage('Invalid date: ' + datetimeStr + ': ' + ex.getMessage());
//                throw ex;
//            }
//            return datetimeVar;
//        }

        public Datetime parseDatetimeAusFormat(String datetimeStr) {
            return this.parseDatetimeAnyFormat(datetimeStr, 'dd/MM/yyyy hh:mm a');
        }

        public Date parseDateAnyFormat(String dateStr, String format) {
            return datetimeToDate(this.parseDateTimeAnyFormat(dateStr, format));
        }

        public Date parseDateAusFormat(String dateStr) {
            return this.parseDateAnyFormat(dateStr, 'dd/MM/yyyy');
        }

        public Date datetimeToDate(Datetime datetimeVar) {
            return datetimeVar != null ? datetimeVar.date() : null;
        }

        public DateTime dateToDateTime(Date d) {
            return d == null ? null : DateTime.newInstance(d.year(), d.month(), d.day(), 0, 0, 0);
        }

        public Integer totalWorkingDays(Date startDate, Date endDate) {

            DateTime sdate = DateToDateTime(startDate);
            DateTime edate = DateToDateTime(endDate);

            Integer i = 0;

            while (sdate <= edate) {
                if (IsWorkingDay(sdate) == true) {
                    i = i + 1;
                }
                sdate = sdate.addDays(1);
            }

            return i;

        }

        public Boolean isWorkingDay(Date d) {
            DateTime dt = DateToDateTime(d);
            return IsWorkingDay(dt);
        }

        public Boolean isWorkingDay(DateTime dt) {
            return (dt.format('E') != 'Sat' && dt.format('E') != 'Sun');
        }

        public Time timeStringToTime(String t) {
            String[] arr = t.split(':');
            return Time.newInstance(
                Integer.valueOf(arr[0]),
                Integer.valueOf(arr[1]),
                0,
                0
            );
        }

        // 10:00 AM -> Time.
        public Time timeStringAMPMToTime(String t) {

            if (String.isBlank(t)){
                throw new Structs.MissingDataException('Argument is null');
            }

            List<String> timeParts = t.split(' ');
            List<String> hoursMinutes = timeParts.get(0).split(':');

            String amPMStr = timeParts.get(1);
            String hoursStr = hoursMinutes.get(0);
            String minutesStr = hoursMinutes.get(1);

            Integer hours = Integer.valueOf(hoursStr);
            Integer minutes = Integer.valueOf(minutesStr);

            if('AM'.equals(amPMStr)){
                if (hours == 12){
                    hours = 0;
                }
            } else if ('PM'.equals(amPMStr)) {
                if (hours != 12){
                    hours = hours + 12;
                }
            }

            return Time.newInstance(
                hours,
                minutes,
                0,
                0
            );
        }


        public DateTime getStartOfDay(DateTime dateTimeVar){
            return DateTime.newInstance(dateTimeVar.year(), dateTimeVar.month(), dateTimeVar.day(), 0, 0, 0);
        }

        public DateTime getEndOfDay(DateTime dateTimeVar){
            return DateTime.newInstance(dateTimeVar.year(), dateTimeVar.month(), dateTimeVar.day(), 23, 59, 9);
        }

        public DateTime getStartDateOfWeek(DateTime dateTimeVar){
            Integer dayOfWeek = Integer.valueOf(dateTimeVar.format('u'));
            DateTime startDateOfWeek = dateTimeVar.addDays(-1 * (dayOfWeek - 1));
            return getStartOfDay(startDateOfWeek);
        }

        public Date getStartDateOfWeek(Date dateVar){
            return getStartDateOfWeek(DateToDateTime(dateVar)).date();
        }

        public DateTime getEndDateOfWeek(DateTime dateTimeVar){
            return getEndOfDay(getStartDateOfWeek(dateTimeVar).addDays(6));
        }

        public Date getEndDateOfWeek(Date dateVar){
            return getEndDateOfWeek(DateToDateTime(dateVar)).date();
        }

        public Boolean isDateInCurrectWeekOrInFuture(Date dateVar){
            return dateVar >= getStartDateOfWeek(Date.today());
        }

        public Date getFirstDayInMonth(Date dateVar){
            return dateVar.toStartOfMonth();
        }

        public Date getLastDayInMonth(Date dateVar){
            return dateVar.addMonths(1).toStartOfMonth().addDays(-1);
        }

        public Date getLastWorkingDay(Date dateVar){
            while(!IsWorkingDay(dateVar)){
                dateVar = dateVar.addDays(-1);
            }
            return dateVar;
        }

        public Date getLastDayInFortnight(Date dateVar, Date startDate){

            if (dateVar < startDate){
                throw new Structs.UtilsException('getLastDayInFortnight error: Date should be greater than Period Start Date');
            }

            Date startOfThePeriod = getStartDateOfWeek(startDate);
            Date endOfThePeriod = startOfThePeriod.addDays(13);

            while(dateVar > endOfThePeriod){
                endOfThePeriod = endOfThePeriod.addDays(14);
            }

            return endOfThePeriod;
        }

        public Date getFirstDayInFortnight(Date dateVar, Date startDate){
            Date endOfThePeriod = getLastDayInFortnight(dateVar, startDate);
            return endOfThePeriod.addDays(-13);
        }

        // Deprecated
        public Date dateInRange(Date dateVar, Date startOfRange, Date endOfRange){

            dateVar = startOfRange > dateVar ? startOfRange : dateVar;
            dateVar = endOfRange < dateVar ? endOfRange : dateVar;

            return dateVar;
        }

        public Date detectDateInRange(Date firstDate, Date secondDate, Date thirdDate) {

            Date dateVar = secondDate > firstDate ? secondDate : firstDate;
            dateVar = thirdDate < firstDate ? thirdDate : firstDate;

            return dateVar;
        }

        public Boolean dateInRange(Date dateVar, Date startOfRange, Date endOfRange, Boolean allowCrossing) {
            return allowCrossing == true ? (dateVar >= startOfRange && dateVar <= endOfRange) : (dateVar > startOfRange && dateVar < endOfRange);
        }

        public Boolean crossingDateRanges(Datetime date1start, Datetime date1end, Datetime date2start, Datetime date2end) {
            return !(date1end <= date2start || date1start >= date2end);
        }

        public Integer age(Date birthDate, Date onDate){
            Date birthDateOnDate = Date.newInstance(
                onDate.year(),
                birthDate.month(),
                birthDate.day()
            );
            Integer age = onDate.year() - birthDate.year();
            return Math.max(birthDateOnDate > onDate ? age - 1 : age, 0);
        }

        public Integer age(Date birthDate){
            return age(birthDate, Date.today());
        }

        public Date max(List<Date> dates){
            Date maxDate;
            for (Date dateVar : dates) {
                if(maxDate == null || dateVar > maxDate){
                    maxDate = dateVar;
                }
            }
            return maxDate;
        }

        public Date max(Date date1, Date date2){
            return max(new List<Date>{
                date1,
                date2
            });
        }

        public Date min(List<Date> dates){
            Date minDate;
            for (Date dateVar : dates) {
                if(minDate == null || dateVar < minDate){
                    minDate = dateVar;
                }
            }
            return minDate;
        }

        public Date min(Date date1, Date date2){
            return min(new List<Date>{
                date1,
                date2
            });
        }
    }


    /**
     * ==============================================================================================================
     *                                         STRING EXTENSIONS
     * ==============================================================================================================
     */

    public inherited sharing class StringExtensions {

        public void throwIfBlank(String str, String message){
            this.throwIfBlank(str, new Structs.MissingDataException(message));
        }

        public void throwIfBlank(String str, Exception ex){
            if(String.isBlank(str)){
                throw ex;
            }
        }

        public String emptyStringIfNull(String str){
            return String.isBlank(str) ? '' : str;
        }

//        public String defaultIfBlank(String str, String defaultStr){
//            return String.isBlank(str) ? defaultStr : str;
//        }
//
//        public String removeNonNumeric(String str) {
//            return String.isEmpty(str) ? str : str.replaceAll('[^0-9]*', '');
//        }
//
//        public String removeNonNumericWithDelimiter(String str) {
//            return String.isEmpty(str) ? str : str.replaceAll('[^0-9.,]*', '').replaceAll(',', '.');
//        }
//
//        public String Pad(Integer source, Integer length, String value) {
//            return this.Pad(String.valueOf(source), length, value);
//        }
//
//        public String Pad(String source, Integer length, String value)
//        {
//            if (value.length() != 1)
//                throw new Structs.UtilsException('You can only pad using a single character.');
//
//            if (source.length() < length)
//            {
//                for (Integer i = source.length(); i < length; i++) {
//                    source = value + source;
//                }
//            }
//
//            return source;
//        }

        /**
        * Split a string of any size, while avoiding the dreaded 'Regex too complicated'
        * error, which the String.split(String) method causes on some large inputs.
        *
        * Note that this method does not avoid other errors, such as those related to
        * excess heap size or CPU time.
        */
//        public List<String> safeSplit(String inStr, String delim) {
//
//            Integer regexFindLimit = 100;
//            Integer regexFindCount = 0;
//
//            List<String> output = new List<String>();
//
//            Matcher matcher = Pattern.compile(delim).matcher(inStr);
//
//            Integer lastEnd = 0;
//
//            while(!matcher.hitEnd())
//            {
//                while(regexFindCount < regexFindLimit && !matcher.hitEnd())
//                {
//                    if(matcher.find())
//                    {
//                        output.add(inStr.substring(lastEnd, matcher.start()));
//                        lastEnd = matcher.end();
//                    }
//                    else
//                    {
//                        output.add(inStr.substring(lastEnd));
//                        lastEnd = inStr.length();
//                    }
//
//                    regexFindCount++;
//                }
//
//                // Note: Using region() to advance instead of substring() saves
//                // drastically on heap size. Nonetheless, we still must reset the
//                // (unmodified) input sequence to avoid a 'Regex too complicated'
//                // error.
//                matcher.reset(inStr);
//                matcher.region(lastEnd, matcher.regionEnd());
//
//                regexFindCount = 0;
//            }
//
//            return output;
//        }

        public String newGuid() {

            return EncodingUtil.convertToHex(Crypto.generateAESKey(128));

        }
//
        public String newUuid() {

            String giud = newGuid();
            return giud.substring(0,8)+ '-' + giud.substring(8,12) + '-' + giud.substring(12,16) + '-' + giud.substring(16,20) + '-' + giud.substring(20);

        }
//
//        private String getCharAtIndex(String str, Integer index) {
//
//            if (str == null) return null;
//
//            if (str.length() <= 0) return str;
//
//            if (index == str.length()) return null;
//
//            return str.substring(index, index+1);
//        }
//
        public String joinNonBlank(List<String> parts, String separator){
            List<String> notBlankParts = new List<String>();

            for(String part : parts){
                if(String.isNotBlank(part)){
                    notBlankParts.add(part);
                }
            }

            return String.join(notBlankParts, separator);
        }

    }


    /**
     * ==============================================================================================================
     *                                           USER EXTENSIONS
     * ==============================================================================================================
     */
    private final static Map<String, List<Object>> PERM_SETS_BY_USER_ID = new Map<String, List<Object>>();

    public inherited sharing class UserExtensions {
        public Boolean hasPermSetAssigned(String userId, String permSetName){
            if (!PERM_SETS_BY_USER_ID.containsKey(userId)) {
                List<PermissionSetAssignment> groupAssignments = [
                        SELECT PermissionSet.Name, PermissionSet.NamespacePrefix, PermissionSetGroupId
                        FROM PermissionSetAssignment
                        WHERE AssigneeId = :userId
                        AND PermissionSetGroupId != NULL
                        WITH SYSTEM_MODE
                ]; // CRUD/FLS/Query/Sharing False Positive: This query should have a system permission.

                List<PermissionSetAssignment> individualAssignments = [
                        SELECT PermissionSet.Name, PermissionSet.NamespacePrefix, PermissionSetGroupId
                        FROM PermissionSetAssignment
                        WHERE AssigneeId = :userId
                        AND PermissionSetGroupId = NULL
                        WITH SYSTEM_MODE
                ]; // CRUD/FLS/Query/Sharing False Positive: This query should have a system permission.

                Set<Id> permSetGroupIDs = new Set<Id>();
                List<PermissionSetAssignment> allAssignments = new List<PermissionSetAssignment>();
                allAssignments.addAll(groupAssignments);
                allAssignments.addAll(individualAssignments);
                for (PermissionSetAssignment assignment : allAssignments) {
                    Utils.arrays.addToListOrCreateNew(PERM_SETS_BY_USER_ID, List<String>.class, userId, (String.isNotBlank(assignment.PermissionSet.NamespacePrefix) ? assignment.PermissionSet.NamespacePrefix + '.' : '') + assignment.PermissionSet.Name);
                    if (assignment.PermissionSetGroupId != null) {
                        permSetGroupIDs.add(assignment.PermissionSetGroupId);
                    }
                }

                List<PermissionSetGroupComponent> psgComponents = [
                        SELECT PermissionSet.Name, PermissionSet.NamespacePrefix
                        FROM PermissionSetGroupComponent
                        WHERE PermissionSetGroupId = :permSetGroupIDs
                ];
                for (PermissionSetGroupComponent psg : psgComponents) {
                    Utils.arrays.addToListOrCreateNew(PERM_SETS_BY_USER_ID, List<String>.class, userId, (String.isNotBlank(psg.PermissionSet.NamespacePrefix) ? psg.PermissionSet.NamespacePrefix + '.' : '') + psg.PermissionSet.Name);
                }
            }
            return PERM_SETS_BY_USER_ID.get(userId).contains(permSetName);
        }

        public Boolean hasPermSetAssigned(String permSetName){
            return hasPermSetAssigned(UserInfo.getUserId(), permSetName);
        }

        public void assertPermSet(String permSetName, String errorMessage){
            if(!hasPermSetAssigned(permSetName)){
                throw new Structs.AccessException(errorMessage);
            }
        }
    }

//        public final String LICENCE_PROFILE_CHATTER_FREE_USER = 'Chatter Free User';
//
//        public Id GetProfileIdByName(string profileName)
//        {
//            Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
//
//            if (p != null)
//                return p.Id;
//
//            throw new Structs.MissingDataException('Could not find a profile named \'' + profileName + '\'.');
//        }
//
//        public User CreateUser(String firstName, String lastName, String email, String communityNickname,
//            String userName, String alias, String employeeNumber, Id profileId, Boolean Active__c)
//        {
//            User u = new User();
//            u.CommunityNickname = communityNickname;
//            u.Username = userName;
//            u.Email = email;
//
//            /// Need to make dynamic.
//            u.EmailEncodingKey = 'UTF-8';
//            u.LanguageLocaleKey = 'en_US';
//            u.LocaleSidKey = 'en_AU';
//            u.TimeZoneSidKey = 'Australia/Sydney';
//
//            u.FirstName = firstName;
//            u.LastName = lastName;
//            u.ProfileId = profileId;
//
//            u.EmployeeNumber = employeeNumber;
//            u.Alias = (alias.length() > 8) ? alias.substring(0, 7) : alias;
//            u.Active__c = Active__c;
//
//            return u;
//        }
//
//    }


    /**
     * ==============================================================================================================
     *                                         SOBJECT EXTENSIONS
     * ==============================================================================================================
     */

    public inherited sharing class SObjectExtensions {

        public void assertReadable(List<SObject> records) {
            assertAccessType(records, AccessType.READABLE);
        }

        public void assertReadable(SObject record) {
            assertReadable(new List<SObject>{
                record
            });
        }

//        public void assertCreatable(List<SObject> records) {
//            assertAccessType(records, AccessType.CREATABLE);
//        }
//
//        public void assertCreatable(SObject record) {
//            assertCreatable(new List<SObject>{
//                record
//            });
//        }
//
//        public void assertUpdatable(List<SObject> records) {
//            assertAccessType(records, AccessType.UPDATABLE);
//        }
//
//        public void assertUpdatable(SObject record) {
//            assertUpdatable(new List<SObject>{
//                record
//            });
//        }
//
//        public void assertUpsertable(List<SObject> records) {
//            assertAccessType(records, AccessType.UPSERTABLE);
//        }
//
//
//        public void assertUpsertable(SObject record) {
//            assertUpsertable(new List<SObject>{
//                record
//            });
//        }

        public void assertAccessType(List<SObject> records, AccessType accessType) {
            if (records.isEmpty()) {
                return;
            }
            SObjectType sObjTypeVar = records.get(0).getSObjectType();
            try {
                SObjectAccessDecision decision = Security.stripInaccessible(
                    accessType,
                    records
                );
                records = decision.getRecords();
//                if(decision.getModifiedIndexes().isEmpty() != true){
//                    throw new Structs.AccessException('No ' + accessType + ' Access to entity of type: ' + sObjTypeVar + ' field(s): ' + decision.getRemovedFields().values());
//                }
            } catch (System.NoAccessException ex) {
                throw new Structs.AccessException('No ' + accessType + ' Access to entity of type: ' + sObjTypeVar);
            }
        }

//        public SObject createSObjectById(Id sObjectId) {
//            SObject sObj = (SObject) Type.forName(sObjectId.getSobjectType().getDescribe().getName()).newInstance();
//            sObj.Id = sObjectId;
//            return sObj;
//        }
//
//        public List<SObject> createSObjectsByIds(Set<Id> sObjectIds) {
//            List<SObject> sObjects = new List<SObject>();
//            for (Id sObjectId : sObjectIds) {
//                sObjects.add(createSObjectById(sObjectId));
//            }
//            return sObjects;
//        }
//
//        public List<sObject> getSobjectsFromIds(Schema.sObjectType sObjectType, Set<Id> ids){
//            List<sObject> sObjects = new List<sObject>();
//            for(Id idVar : ids){
//                sObject obj = sObjectType.newsObject();
//                obj.Id = idVar;
//                sObjects.add(obj);
//            }
//            return sObjects;
//        }

        public Set<Id> getIdFieldValues(List<sObject> records, Schema.SObjectField field){
            return getIdFieldValues(records, '' + field);
        }

        public Set<Id> getIdFieldValues(List<sObject> records, String fieldName){

            Set<Id> values = new Set<Id>();

            for(sObject rec : records){
                Id value = (Id)rec.get(fieldName);
                if (value != null){
                    values.add(value);
                }
            }

            return values;

        }

        public Set<String> getStringFieldValues(List<sObject> records, Schema.SObjectField field){
            return getStringFieldValues(records, '' + field);
        }

        public Set<String> getStringFieldValues(List<sObject> records, String fieldName){

            Set<String> values = new Set<String>();

            for(sObject rec : records){
                String value = rec.get(fieldName) == null ? null : String.valueOf(rec.get(fieldName));
                if (value != null){
                    values.add(value);
                }
            }

            return values;

        }

//        public void putAllRecordsByKeyField(List<sObject> records, String keyField, Map<String, sObject> mappedRecords){
//            for(sObject record : records){
//                String value = (String)record.get(keyField);
//                if (String.isNotBlank(value)){
//                    value = value.trim().toUpperCase();
//                    mappedRecords.put(value, record);
//                }
//            }
//        }
//
//        public void putAllRecordsByKeyField(List<sObject> records, String keyField, Map<String, List<sObject>> mappedRecords, Boolean upperCaseKey){
//            for(sObject record : records){
//                String value = (String)record.get(keyField);
//                if (String.isNotBlank(value)){
//                    if(upperCaseKey == true){
//                        value = value.trim().toUpperCase();
//                    }
//                    List<SObject> recordsByKey = mappedRecords.get(value);
//                    if(recordsByKey == null){
//                        recordsByKey = new List<SObject>();
//                        mappedRecords.put(value, recordsByKey);
//                    }
//                    recordsByKey.add(record);
//                }
//            }
//        }

        public Map<String, SObject> getSObjectsByAnyFieldMap(List<SObject> sObjects, Schema.SObjectField sObjectField) {
            return getSObjectsByAnyFieldMap(sObjects, '' + sObjectField);
        }

        public Map<String, SObject> getSObjectsByAnyFieldMap(List<SObject> sObjects, String sObjectField) {
            Map<String, SObject> resultMap = new Map<String, SObject>();
            for (SObject record : sObjects) {
                String value = (String)record.get(sObjectField);
                if (value != null) {
                    resultMap.put(value, record);
                }
            }
            return resultMap;
        }

        public Map<String, List<SObject>> getSObjectsListByAnyFieldMap(List<SObject> sObjects, Schema.SObjectField sObjectField) {
            return getSObjectsListByAnyFieldMap(sObjects, '' + sObjectField);
        }

        public Map<String, List<SObject>> getSObjectsListByAnyFieldMap(List<SObject> sObjects, String sObjectField) {
            Map<String, List<SObject>> resultMap = new Map<String, List<SObject>>();
            for (SObject record : sObjects) {
                String value = (String)record.get(sObjectField);
                if (value != null) {
                    if (resultMap.containsKey(value)) {
                        resultMap.get(value).add(record);
                    } else {
                        resultMap.put(value, new List<SObject> {record});
                    }
                }
            }
            return resultMap;
        }

//        public Set<SObjectField> getUpdatableFields(SObjectType sObjectTypeVar){
//
//            Set<SObjectField> updatableFields = new Set<SObjectField>();
//
//            Map<String, SObjectField> fieldMap = sObjectTypeVar.getDescribe().fields.getMap();
//            for (String fieldName : fieldMap.keySet()) {
//                SObjectField fieldVar = fieldMap.get(fieldName);
//                if(fieldVar.getDescribe().isUpdateable()){
//                    updatableFields.add(fieldVar);
//                }
//            }
//
//            return updatableFields;
//        }

//        public void addAmountToField(SObject record, SObjectField field, Decimal amount){
//
//            if(amount == null){
//                return;
//            }
//
//            Decimal currentValue = (Decimal)record.get(field);
//
//            if(currentValue == null){
//                currentValue = amount;
//            } else {
//                currentValue += amount;
//            }
//
//            record.put(field, currentValue);
//        }

        public String fieldToProperty(SObjectField field) {
            return fieldNameToProperty(field.getDescribe().getName());
        }
//
        public String fieldNameToProperty(String fieldName) {
            if (String.isBlank(fieldName)) return '';

            List<String> parts = new List<String>();

            fieldName = fieldName.replace('__c', '');
            fieldName = fieldName.replace('__s', '');

            String namespace = '';
            if (fieldName.contains('__')) {
                namespace = fieldName.substringBefore('__').toLowerCase().replace('maica_cc', 'maica');
                fieldName = fieldName.substringAfter('__');
            }

            for (String part : fieldName.split('_')) {
                parts.add(part.substring(0, 1).toUpperCase() + part.substring(1));
            }

            String property = namespace + String.join(parts, '');
            property = property.isAllUpperCase() ? property : property.substring(0, 1).toLowerCase() + property.substring(1);

            return property;
        }

//        public SObjectField propertyToField(String property, SObjectType type) {
//            for (SObjectField field : type.getDescribe().fields.getMap().values()) {
//                String prop = fieldToProperty(field);
//                if (prop.equals(property)) {
//                    return field;
//                }
//            }
//            return null;
//        }

//        public String propertyToFieldName(String property, SObjectType type) {
//            SObjectField field = propertyToField(property, type);
//            return field == null ? null : field.getDescribe().getName();
//        }


//        public RecordTypeInfo recordTypeByName(SObjectType sObjectTypeVar, String name){
//            return sObjectTypeVar.getDescribe().getRecordTypeInfosByName().get(name);
//        }
//
//        public Id recordTypeIdByName(SObjectType sObjectTypeVar, String name){
//            RecordTypeInfo recType = this.recordTypeByName(sObjectTypeVar, name);
//            if(recType == null){
//                throw new Structs.NotFoundException('No Record Type for: ' + sObjectTypeVar + ' with Name: ' + name);
//            }
//            return recType.getRecordTypeId();
//        }
//
//        public String recordTypeAPINameById(SObjectType sObjectTypeVar, Id recTypeId) {
//            for (RecordTypeInfo recordTypeInfoVar : sObjectTypeVar.getDescribe().getRecordTypeInfos()) {
//                if (recTypeId == recordTypeInfoVar.getRecordTypeId()) {
//                    return recordTypeInfoVar.getDeveloperName();
//                }
//            }
//            return null;
//        }

        public RecordTypeInfo recordTypeByAPIName(SObjectType sObjectTypeVar, String apiName){
            return sObjectTypeVar.getDescribe().getRecordTypeInfosByDeveloperName().get(apiName);
        }

        public Id recordTypeIdByAPIName(SObjectType sObjectTypeVar, String apiName){
            RecordTypeInfo recType = this.recordTypeByAPIName(sObjectTypeVar, apiName);
            if(recType == null){
                throw new Structs.NotFoundException('No Record Type for: ' + sObjectTypeVar + ' with API Name: ' + apiName);
            }
            return recType.getRecordTypeId();
        }

//        public String recordTypeNameById(SObjectType sObjectTypeVar, Id recTypeId) {
//            for (RecordTypeInfo recordTypeInfoVar : sObjectTypeVar.getDescribe().getRecordTypeInfos()) {
//                if (recTypeId == recordTypeInfoVar.getRecordTypeId()) {
//                    return recordTypeInfoVar.getName();
//                }
//            }
//            return null;
//        }

        public Structs.SelectOption toSelectOption(SObject sObj, String valueFieldName, String labelFieldName){
            return new Structs.SelectOption(
                    (String) sObj.get(valueFieldName),
                    (String) sObj.get(labelFieldName)
            );
        }

        public Structs.SelectOption toSelectOption(SObject sObj, String labelFieldName){
            return new Structs.SelectOption(
                    (String) sObj.get('Id'),
                    (String) sObj.get(labelFieldName)
            );
        }

        public Structs.SelectOption toSelectOption(SObject sObj){
            return new Structs.SelectOption(
                    (String) sObj.get('Id'),
                    (String) sObj.get('Name')
            );
        }

        public List<Structs.SelectOption> toSelectOptions(List<SObject> sObjects, String valueFieldName, String labelFieldName){
            List<Structs.SelectOption> options = new List<Structs.SelectOption>();

            for(SObject sObj : sObjects){
                options.add(toSelectOption(sObj, valueFieldName, labelFieldName));
            }

            return options;
        }

        public List<Structs.SelectOption> toSelectOptions(List<System.SelectOption> selectOptions) {
            List<Structs.SelectOption> options = new List<Structs.SelectOption>();
            for (System.SelectOption option : selectOptions) {
                options.add(new Structs.SelectOption(option.getValue().replaceAll(' ', '_'), option.getLabel()));
            }
            return options;
        }

        public List<Structs.SelectOption> toSelectOptions(List<SObject> sObjects, String labelFieldName){
            return toSelectOptions(sObjects, 'Id', labelFieldName);
        }

        public List<Structs.SelectOption> toSelectOptions(List<SObject> sObjects){
            return toSelectOptions(sObjects, 'Id', 'Name');
        }

        public void swap(SObject record, SObjectField field1, SObjectField field2) {
            Object valueOfField1 = record.get(field1);
            record.put(field1, record.get(field2));
            record.put(field2, valueOfField1);
        }

        public SObjectType stringToSObjectType(String sObjectTypeStr){
            Utils.objects.throwIfBlank(sObjectTypeStr, 'No SObjectType');

            SObjectType sObjectTypeVar = Schema.getGlobalDescribe().get(sObjectTypeStr.toLowerCase());
            Utils.objects.throwIfNull(sObjectTypeVar, 'No SObjectType with API Name: ' + sObjectTypeStr);

            return sObjectTypeVar;
        }

        public Set<SObjectField> getFieldsByTypes(SObjectType sObjType, Set<DisplayType> types) {
            Set<SObjectField> fields = new Set<SObjectField>();
            for (SObjectField field : sObjType.getDescribe().fields.getMap().values()) {
                if (types.contains(field.getDescribe().type)) {
                    fields.add(field);
                }
            }
            return fields;
        }

        public Boolean isSomeFieldChanged(SObject record, SObject existingRecord, List<String> fields) {
            for (String field : fields) {
                Object newFieldValue = record.get(field);
                Object oldFieldValue = existingRecord.get(field);

                if (newFieldValue != oldFieldValue) {
                    return true;
                }
            }

            return false;
        }

        public Boolean isSomeFieldChanged(SObject record, SObject existingRecord, List<SObjectField> fields) {
            List<String> fieldsStrings = new List<String>();
            for (SObjectField field : fields) {
                fieldsStrings.add(field.getDescribe().getName());
            }
            return isSomeFieldChanged(record, existingRecord, fieldsStrings);
        }

        public Object getValueByPath(SObject recordVar, String path) {
            path = path.toLowerCase();
            List<String> pathItems = path.split('\\.');

            SObject targetSobjectVar = recordVar;
            while (pathItems.size() > 1 && targetSobjectVar != null) {
                String pathItem = pathItems.remove(0);
                targetSobjectVar = targetSobjectVar.getSObject(pathItem);
            }

            return targetSobjectVar == null ? null : targetSobjectVar.get(pathItems.get(0));
        }

        public Decimal sum(List<SObject> records, SObjectField fieldVar){
            return sum(records, '' + fieldVar);
        }

        public Decimal sum(List<SObject> records, String path){
            Decimal sum = 0;

            if(records == null){
                return sum;
            }

            for (SObject sobj : records) {
                Decimal val = Utils.objects.defaultIfNull(
                    Utils.objects.parseDecimal(
                        Utils.sObjects.getValueByPath(sobj, path)
                    ),
                    0
                );
                sum += val;
            }
            return sum;
        }

//        public SObjectExtensions setNotBlankValue(SObject recordVar, SObjectField fieldVar, Object val){
//            if(!Utils.objects.isBlankValue(val)){
//                recordVar.put(fieldVar, val);
//            }
//            return this;
//        }

//        public void insertDeduplicable(SObject recordVar, Set<SObjectField> preserveFields){
//            System.assertNotEquals(null, recordVar);
//            insertDeduplicable(new List<SObject>{recordVar}, preserveFields);
//        }

//        public void insertDeduplicable(SObject recordVar){
//            insertDeduplicable(recordVar, null);
//        }

//        public void insertDeduplicable(List<SObject> records){
//            insertDeduplicable(records, null, null);
//        }
//
//        public void insertDeduplicable(List<SObject> records, Set<SObjectField> preserveFields){
//            insertDeduplicable(records, preserveFields, null);
//        }

//        public void insertDeduplicable(List<SObject> records, Set<SObjectField> preserveFields, Database.DMLOptions dmlOptions){
//
//            System.assertNotEquals(null, records);
//
//            if(records.isEmpty()){
//                return;
//            }
//
//            Savepoint savePointVar = Database.setSavepoint();
//            try {
//
//                if(dmlOptions != null){
//                    for (SObject recordVar : records) {
//                        recordVar.setOptions(dmlOptions);
//                    }
//                }
//
//                List<Database.SaveResult> saveResults = Database.insert(records, false);
//
//                Map<Id, SObject> recordsToUpdateMap = new Map<Id, SObject>();
//                Integer counter = 0;
//                for (Database.SaveResult saveResult : saveResults) {
//
//                    if (saveResult.isSuccess() == false) {
//
//                        SObject recordVar = records.get(counter);
//
//                        for (Database.Error error : saveResult.getErrors()) {
//                            Id recordId;
//
//                            if (error instanceof Database.DuplicateError) {
//                                Database.DuplicateError duplicateError = (Database.DuplicateError) error;
//
//                                Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
//                                List<Datacloud.MatchResult> matchResults = duplicateResult.getMatchResults();
//
//                                Datacloud.MatchResult matchResult = matchResults.get(0);
//                                List<Datacloud.MatchRecord> matchRecords = matchResult.getMatchRecords();
//
//                                Datacloud.MatchRecord matchRecord = matchRecords.get(0);
//                                SObject matchRecordVar = matchRecord.getRecord();
//
//                                recordId = matchRecordVar.Id;
//                            } else if (recordId == null && error.getStatusCode() == StatusCode.DUPLICATE_VALUE) {
//                                recordId = (Id) error.getMessage().right(15);
//                            } else {
//                                throw new Structs.ProcessException(JSON.serializePretty(new Map<String, Object>{
//                                    'message' => 'Insert exception',
//                                    'record' => recordVar,
//                                    'error' => saveResult
//                                }));
//                            }
//
//                            if (recordId != null) {
//                                recordVar.Id = recordId;
//                                recordsToUpdateMap.put(recordVar.Id, recordVar);
//                            } else {
//                                throw new Structs.MissingDataException(JSON.serializePretty(new Map<String, Object>{
//                                    'message' => 'Unable to deduplicate record',
//                                    'record' => recordVar,
//                                    'error' => saveResult
//                                })
//                                );
//                            }
//                        }
//                    }
//                    counter++;
//                }
//
//                List<SObject> recordsToUpdate = recordsToUpdateMap.values();
//
//                // Restore preserved fields from source records.
//                Utils.sObjects.restoreNotBlankValues(recordsToUpdate, preserveFields);
//
//                Database.DMLOptions commonDmlOptions = dmlOptions == null ? new Database.DMLOptions() : (Database.DMLOptions)dmlOptions.clone();
//                commonDmlOptions.DuplicateRuleHeader.AllowSave = true;
//
//                Database.update(recordsToUpdate, commonDmlOptions);
//
//            } catch (Exception ex) {
//                Database.rollback(savePointVar);
//                throw ex;
//            }
//        }

        public void restoreNotBlankValues(List<SObject> records, Set<SObjectField> fields){
            if(records != null && records.isEmpty() == false && fields != null && fields.isEmpty() == false){
                SObjectType sObjectTypeVar = records.get(0).getSObjectType();
                fflib_QueryFactory queryFactory = new fflib_QueryFactory(sObjectTypeVar);
                queryFactory.selectField('Id');
                queryFactory.selectFields(fields);
                queryFactory.setCondition('Id IN :records');
                List<SObject> sourceRecords = Database.query(queryFactory.toSOQL());
                Map<Id, SObject> sourceRecordsMap = new Map<Id, SObject>(sourceRecords);
                for (SObject recordVar : records) {
                    SObject sourceRecordVar = sourceRecordsMap.get(recordVar.Id);
                    for (SObjectField preserveField : fields) {
                        Object sourceValue = sourceRecordVar.get(preserveField);
                        if(sourceValue != null){
                            recordVar.put(preserveField, sourceValue);
                        }
                    }
                }
            }
        }

//        public SObject findByUniqueFieldCaseSensitive(List<SObject> records, SObjectField uniqueField, String uniqueId){
//            if(String.isBlank(uniqueId)){
//                return null;
//            }
//            for (SObject recordVar : records) {
//                if(uniqueId.equals((String)recordVar.get(uniqueField))){
//                    return recordVar;
//                }
//            }
//            return null;
//        }

        public Boolean deduplicate(SObject recordVar){
            return deduplicate(recordVar, null);
        }

        public Boolean deduplicate(SObject recordVar, Set<SObjectField> preserveFields){

            if(recordVar == null || recordVar.Id != null){
                return false;
            }

            try {
                Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(new List<SObject>{
                    recordVar
                });
                for (Datacloud.FindDuplicatesResult dupeResult : results) {
                    for (Datacloud.DuplicateResult dupeRes : dupeResult.getDuplicateResults()) {
                        for (Datacloud.MatchResult matchRes : dupeRes.getMatchResults()) {
                            for (Datacloud.MatchRecord matchRec : matchRes.getMatchRecords()) {
                                recordVar.Id = (string) matchRec.getRecord().get('id');
                                Utils.sObjects.restoreNotBlankValues(new List<SObject>{recordVar}, preserveFields);
                                return true;
                            }
                        }
                    }
                }
            }catch (System.HandledException ex){ //No active duplicate rules are defined for the object type.
//                System.debug(ex.getMessage());
            }catch (Exception ex){
//                System.debug(ex.getMessage()); // Other issue.
            }
            return false;
        }

        public Map<String, Object> getSObjectDescribe(List<SObjectType> sObjectTypes) {
            DTO dto = new DTO();

            for (SObjectType sObjType : sObjectTypes) {
                DescribeSObjectResult sObjDescribe = sObjType.getDescribe();
                String sObjName = sObjDescribe.getName();

                dto.put(sObjName + '.name', sObjDescribe.getName())
                    .put(sObjName + '.localName', sObjDescribe.getLocalName())
                    .put(sObjName + '.label', sObjDescribe.getLabel())
                    .put(sObjName + '.pluralLabel', sObjDescribe.getLabelPlural())
                    .put(sObjName + '.keyPrefix', sObjDescribe.getKeyPrefix());

                for (SObjectField field : sObjDescribe.fields.getMap().values()) {
                    DescribeFieldResult fieldDescribe = field.getDescribe();
                    String fieldName = fieldDescribe.getName();

                    dto.put(sObjName + '.' + fieldName + '.name', fieldDescribe.getName())
                        .put(sObjName + '.' + fieldName + '.localName', fieldDescribe.getLocalName())
                        .put(sObjName + '.' + fieldName + '.label', fieldDescribe.getLabel())
                        .put(sObjName + '.' + fieldName + '.helpText', fieldDescribe.getInlineHelpText())
                        .put(sObjName + '.' + fieldName + '.defaultValue', fieldDescribe.getDefaultValue())
                        .put(sObjName + '.' + fieldName + '.type', fieldDescribe.getType())
                        .put(sObjName + '.' + fieldName + '.type', fieldDescribe.getType());
                }
            }

            return dto.getMap();
        }
    }



    /**
     * ==============================================================================================================
     *                                            URL EXTENSIONS
     * ==============================================================================================================
     */

    public inherited sharing class URLExtensions {

        public String generateReportURL(String reportAPIName, List<String> paramValues) {
            return generateReportURL(reportAPIName, paramValues, true);
        }

        public String generateReportURL(String reportAPIName, List<String> paramValues, Boolean isSecurityEnforced) {

            String reportQuery = 'SELECT Id, Name\n' +
                'FROM Report\n' +
                'WHERE DeveloperName = :reportAPIName';

            Report reportId = (Report) Utils.arrays.firstOrNull(
                Database.query(reportQuery + (isSecurityEnforced == true ? ' WITH USER_MODE' : ''))
            );

            List<String> reportParams = new List<String>();
            if(paramValues != null){
                for (Integer i = 0; i < paramValues.size(); i++) {
                    reportParams.add(String.format('fv{0}={1}', new List<String>{
                        '' + (i + 1),
                        EncodingUtil.urlEncode(paramValues[i], 'UTF-8')
                    }));
                }
            }

            String reportURL = String.format('/lightning/r/Report/{0}/view?queryScope=userFolders{1}', new List<String>{
                reportId?.Id,
                reportParams.isEmpty() ? '' : '&' + String.join(reportParams, '&')
            });

            return reportURL;
        }
//
        public PageReference listView(Schema.sObjectType destinationSObject) {
            Schema.DescribeSObjectResult destination = destinationSObject.getDescribe();
            PageReference pageRef = new PageReference('/' + destination.getKeyPrefix() );
            pageRef.setRedirect(true);
            return pageRef;
        }
    }


    /**
     * ==============================================================================================================
     *                                            EMAIL EXTENSIONS
     * ==============================================================================================================
     */

    public inherited sharing class EmailExtensions {

//        public Messaging.SingleEmailMessage createSingleEmail(Id targetId, Id whatId, Id templateId){
//            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//            mail.setTargetObjectId(targetId);
//            mail.setWhatId(whatId);
//            mail.setTemplateId(templateId);
//            mail.setSaveAsActivity(false);
//            return mail;
//        }
//
        public Id getEmailTemplateIdByName(String templateName){
            List<EmailTemplate> templates = [
                SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE DeveloperName = :templateName
            ];

            return templates.isEmpty() ? null : templates[0].Id;
        }
//
//        public Messaging.SingleEmailMessage createSingleEmail(Id targetId, Id whatId, Id templateId, Id orgWideEmailId){
//            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//            mail.setTargetObjectId(targetId);
//            if (whatId != null) {
//                mail.setWhatId(whatId);
//            }
//            mail.setTemplateId(templateId);
//            mail.setSaveAsActivity(false);
//
//            if (orgWideEmailId != null) {
//                mail.setOrgWideEmailAddressId(orgWideEmailId);
//            }
//
//            return mail;
//        }
//
        public Boolean isEmailsTurnedOn(){
            Boolean emailsTurnedOn = false;
            try {
                Messaging.reserveSingleEmailCapacity(0);
                emailsTurnedOn = true;
            } catch (System.NoAccessException e) {
            }
            return emailsTurnedOn;
        }
    }



    /**
     * ==============================================================================================================
     *                                          ORGANISATION EXTENSIONS
     * ==============================================================================================================
     */

    private static Boolean isSandbox;
    private static Boolean isScratch;

    public inherited sharing class OrgExtensions {

        public Boolean isSandbox() {

            if(isSandbox == null){
                List<Organization> organizations = [
                    SELECT IsSandbox
                    FROM Organization
                    WHERE Id = :UserInfo.getOrganizationId()
                ];

                if (organizations.isEmpty()) {
                    throw new Structs.MissingDataException('No Organisation');
                }

                isSandbox = organizations.get(0).IsSandbox == true;
            }

            return isSandbox;
        }

        public Boolean isScratch() {

            if(isScratch == null){
                isScratch = Url.getOrgDomainUrl().getHost().contains('scratch');
            }

            return isScratch;
        }

    }


    /**
     * ==============================================================================================================
     *                                         ENCODING EXTENSIONS
     * ==============================================================================================================
     */

    public inherited sharing class EncodingExtensions {
//
//        // map to application/x-www-form-urlencoded.
        public String mapToFormUrlEncoded(Map<String, String> dataMap){
            List<String> keyValuePairsEncoded = new List<String>();
            for(String key : dataMap.keySet()){
                keyValuePairsEncoded.add(String.format('{0}={1}', new List<String>{
                    System.EncodingUtil.urlEncode(key, 'UTF-8'),
                    System.EncodingUtil.urlEncode(Utils.strings.emptyStringIfNull(dataMap.get(key)), 'UTF-8')
                }));
            }

            return String.join(keyValuePairsEncoded, '&');
        }

//        // application/x-www-form-urlencoded to map.
//        public Map<String, String> formUrlEncodedToMap(String data){
//            Map<String, String> dataMap = new Map<String, String>();
//
//            List<String> paramsList = data.split('&');
//
//            for(String param : paramsList){
//                List<String> keyValues = param.split('=');
//                if (keyValues.size() != 2){
//                    throw new Structs.UtilsException('Parameter should contains key and value. ' + keyValues);
//                }
//                dataMap.put(
//                    System.EncodingUtil.urlDecode(keyValues.get(0), 'UTF-8'),
//                    System.EncodingUtil.urlDecode(keyValues.get(1), 'UTF-8')
//                );
//            }
//
//            return dataMap;
//        }
//
        public String getEncryptedValue(String value, String blobEncodedString) {
            Blob cryptoKey = EncodingUtil.base64Decode(blobEncodedString);

            Blob encryptedToken = Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(value));

            String encryptedValue = EncodingUtil.base64Encode(encryptedToken);

            return encryptedValue;
        }
//
        public String getDecryptedValue(String encryptedValue, String blobEncodedString) {
            Blob cryptoKey = EncodingUtil.base64Decode(blobEncodedString);

            Blob encryptedToken = EncodingUtil.base64Decode(encryptedValue);

            Blob decryptedToken = Crypto.decryptWithManagedIV('AES256', cryptoKey, encryptedToken);

            return decryptedToken.toString();
        }
//
//        public String maskCreditCard(String cardNumber) {
//            return String.isNotBlank(cardNumber) && cardNumber.length() == 16 ? cardNumber.substring(0, 6) + 'XXXXXX' + cardNumber.substring(12) : null;
//        }
//
    }


    /**
     * ==============================================================================================================
     *                                             COLLECTION EXTENSIONS
     * ==============================================================================================================
     */

    public inherited sharing class ArrayExtensions {

        private final Pattern ARRAY_NOTATION = Pattern.compile('\\[(\\d+)\\]');

        public Object firstOrDefault(List<Object> records, Object defaultVar){
            return records.isEmpty() ? defaultVar : records[0];
        }

        public Object firstOrNull(List<Object> records){
            return firstOrDefault(records, null);
        }

        public Object firstOrException(List<Object> records){
            return firstOrException(records, 'The list is empty');
        }

        public Object firstOrException(List<Object> records, String message){
            return firstOrException(records, message, null);
        }

        public Object firstOrException(List<Object> records, String message, Type exceptionType){
            if(records == null || records.isEmpty()){
                Exception ex;
                if (exceptionType != null) {
                    ex = (Exception) exceptionType.newInstance();
                    ex.setMessage(message);
                } else {
                    ex = new Structs.MissingDataException(message);
                }
                throw ex;
            }
            return records.get(0);
        }

//        public String getMapFirstKey(Map<String, Object> mapVar){
//            List<String> keys = new List<String>(mapVar.keySet());
//            return (String)firstOrNull(keys);
//        }

//        public List<Object> reverseList(List<Object> anArray){
//            if (anArray == null) {
//                return null;
//            }
//            Integer i = 0;
//            Integer j = anArray.size() - 1;
//            Object tmp;
//            while (j > i) {
//                tmp = anArray[j];
//                anArray[j] = anArray[i];
//                anArray[i] = tmp;
//                j--;
//                i++;
//            }
//            return anArray;
//        }

//        public Map<String, String> changeMapKeys(Map<String, String> source, Map<String, String> donor){
//
//            if (source == null){
//                return null;
//            }
//
//            Map<String, String> result = new Map<String, String>();
//
//            for(String sourceKey : source.keySet()){
//                if (donor.containsKey(sourceKey)){
//                    result.put(donor.get(sourceKey), source.get(sourceKey));
//                }
//            }
//
//            return result;
//        }

        public void addToSetIfNotBlank(Set<String> dataSet, String value){
            if (String.isNotBlank(value)){
                dataSet.add(value);
            }
        }

        public void addToListOrCreateNew(Map<String, List<Object>> dataMap, Type listType, String key, Object obj, Integer index) {
            if (dataMap == null) {
                dataMap = new Map<String, List<Object>>();
            }
            if (!dataMap.containsKey(key) || dataMap.get(key) == null) {
                List<Object> newList = (List<Object>) listType.newInstance();
                dataMap.put(key, newList);
            }
            if (index != null && dataMap.get(key).size() > index) {
                dataMap.get(key).add(index, obj);
            } else {
                dataMap.get(key).add(obj);
            }
        }

        public void addToListOrCreateNew(Map<String, List<Object>> dataMap, Type listType, String key, Object obj) {
            this.addToListOrCreateNew(dataMap, listType, key, obj, null);
        }

        public Object getMapValue(Map<String, Object> dataMap, String path) {
            return this.getMapValue(dataMap, path.split('\\.'));
        }

        public Object getMapValue(Map<String, Object> dataMap, List<String> path) {

            List<String> currentKeys = path;
            Map<String, Object> tempMap = dataMap;
            List<Object> tempArr = null;

            while (!currentKeys.isEmpty()) {

                if (tempMap == null && tempArr == null) {
                    return null;
                }

                String key = currentKeys.remove(0);

                if ('size()'.equalsIgnoreCase(key) && tempArr != null) {
                    return tempArr.size();
                }

                Matcher arrayMatcher = ARRAY_NOTATION.matcher(key);
                Boolean isArrayKey = arrayMatcher.matches();
                Integer index = isArrayKey ? Integer.valueOf(arrayMatcher.group(1)) : null;

                if(isArrayKey && (tempArr == null || index == null || tempArr.size() <= index)){
                    return null;
                }

                Object val = isArrayKey ? tempArr.get(index) : tempMap.get(key);

                Boolean isLastKey = currentKeys.isEmpty();

                if (isLastKey == true) {
                    return val;
                } else {
                    if (val instanceof List<Object>) {
                        tempArr = (List<Object>) val;
                    } else {
                        if (val instanceof Map<String, Object>) {
                            tempMap = (Map<String, Object>) val;
                            tempArr = null;
                        } else {
                            return null;
                        }
                    }
                }

            }
            return null;
        }

        public void setMapValue(Map<String, Object> dataMap, String path, Object value) {
            this.setMapValue(dataMap, path.split('\\.'), value);
        }

        public void setMapValue(Map<String, Object> dataMap, List<String> path, Object value) {
            List<String> currentKeys = path == null ? new List<String>{null} : path;
            Map<String, Object> tempMap = dataMap;
            List<Object> tempArr = null;

            while (!currentKeys.isEmpty()) {

                if (tempMap == null && tempArr == null) {
                    return;
                }

                String key = currentKeys.remove(0);
                Boolean isLastKey = currentKeys.isEmpty();

                Matcher arrayMatcher = ARRAY_NOTATION.matcher(key);
                Integer index = arrayMatcher.matches() ? Integer.valueOf(arrayMatcher.group(1)) : null;
                Integer nextIndex = null;
                if (!isLastKey) {
                    arrayMatcher = ARRAY_NOTATION.matcher(currentKeys[0]);
                    nextIndex = arrayMatcher.matches() ? Integer.valueOf(arrayMatcher.group(1)) : null;
                }

                if (index == null && !tempMap.containsKey(key)) {
                    if (nextIndex != null) {
                        tempMap.put(key, new List<Object>());
                    } else {
                        tempMap.put(key, new Map<String, Object>());
                    }
                } else if (index != null) {
                    if (nextIndex != null && !(tempArr.get(index) instanceof List<Object>)) {
                        tempArr.set(index, new List<Object>());
                    } else if (tempArr.get(index) == null) {
                        tempArr.set(index, new Map<String, Object>());
                    }
                }

                Object val = index != null ? tempArr.get(index) : tempMap.get(key);

                if (isLastKey == true) {
                    if (index != null) {
                        tempArr.set(index, value);
                    } else {
                        tempMap.put(key, value);
                    }
                } else {
                    if ((val instanceof List<Object> || index != null) && nextIndex != null) {
                        tempArr = (List<Object>) val;
                        List<Object> newValues = new List<Object>();
                        if (tempArr == null) {
                            tempArr = new List<Object>();
                            newValues = new Object[nextIndex + 1];
                        } else if (tempArr.size() <= nextIndex) {
                            newValues = new Object[nextIndex + 1 - tempArr.size()];
                        }
                        for (Integer i = 0; i < newValues.size(); i++) {
                            newValues[i] = new Map<String, Object>();
                        }
                        tempArr.addAll(newValues);
                    } else {
                        if (val instanceof Map<String, Object>) {
                            tempMap = (Map<String, Object>) val;
                            tempArr = null;
                        } else if (val instanceof List<Object>) {
                            tempMap = null;
                            tempArr = (List<Object>) val;
                        }
                    }
                }

            }

        }

        public Boolean mapContains(Map<String, Object> dataMap, String path) {
            return getMapValue(dataMap, path) != null;
        }

//        public Decimal sumMaps(List<Object> arr, String path){
//            Decimal total = 0;
//            for (Object item : arr) {
//                Map<String, Object> itemMap = (Map<String, Object>)item;
//                Decimal val = itemMap == null ?
//                    0:
//                    (Decimal)this.getMapValue(itemMap, path);
//
//                total += (val == null ? 0 : val);
//            }
//            return total;
//        }


//        public Boolean containsAny(List<Object> arr1, List<Object> arr2){
//            for (Object obj1 : arr1) {
//                for (Object obj2 : arr2) {
//                    if(obj1 == obj2){
//                        return true;
//                    }
//                }
//            }
//            return false;
//        }

//        public List<Structs.SelectOption> stringsToSelectOptions(List<String> options) {
//            List<Structs.SelectOption> selectOptions = new List<Structs.SelectOption>();
//
//            for (String str : options) {
//                selectOptions.add(new Structs.SelectOption(str));
//            }
//
//            return selectOptions;
//        }

        //Example: Utils.arrays.split(new List<Integer>{1, 2, 3, 4, 5, 6, 7, 8, 9 ,10}, 2, List<Integer>.class)
        public List<List<Object>> split(List<Object> arr, Integer chunkSize, Type chunkListType){

            Utils.objects.throwIfNull(chunkSize, 'chunkSize is null');

            List<List<Object>> result = new List<List<Object>>();

            List<Object> chunk;
            Integer chunkCounter = 0;
            for (Object item : arr) {
                if (chunkCounter == 0) {
                    chunk = (List<Object>)chunkListType.newInstance();
                    result.add(chunk);
                }
                System.debug('item: ' + item);
                chunk.add(item);
                chunkCounter++;
                if(chunkCounter == chunkSize){
                    chunkCounter = 0;
                }
            }

            return result;
        }
    }

    /**
     * ==============================================================================================================
     *                                             OBJECT EXTENSIONS
     * ==============================================================================================================
     */

    public inherited sharing class ObjectExtensions {

        public void throwIfNull(Object obj, Exception ex){
            if(obj == null){
                throw ex;
            }
        }

        public void throwIfNull(Object obj, String message){
            if(obj == null){
                throw new Structs.MissingDataException(message);
            }
        }

        public Boolean isBlankValue(Object obj){
            return obj == null || (obj instanceof String && String.isBlank((String)obj));
        }

        public void throwIfBlank(Object obj, String message){
            if(this.isBlankValue(obj)){
                throw new Structs.MissingDataException(message);
            }
        }

        public Decimal parseDecimal(Object val){
            if(val == null){
                return null;
            } else if(val instanceof Decimal){
                return (Decimal)val;
            } else if (val instanceof String && String.isNotBlank((String)val)){
                return Decimal.valueOf((String)val);
            } else if (val instanceof Integer){
                return Decimal.valueOf((Integer)val);
            } else if (val instanceof Long){
                return Decimal.valueOf((Long)val);
            } else if (val instanceof Double){
                return Decimal.valueOf((Double)val);
            }
            throw new Structs.InvalidDataException('Unable to parse Decimal from: ' + val);
        }

        public Datetime defaultIfNull(Datetime val, Datetime defaultVal){
            return val == null ? defaultVal : val;
        }

        public Date defaultIfNull(Date val, Date defaultVal){
            return val == null ? defaultVal : val;
        }

        public Decimal defaultIfNull(Decimal val, Decimal defaultVal){
            return val == null ? defaultVal : val;
        }

        public Integer defaultIfNull(Integer val, Integer defaultVal){
            return val == null ? defaultVal : val;
        }

        public String defaultIfNull(String val, String defaultVal){
            return val == null ? defaultVal : val;
        }
    }



//    /**
//     * ==============================================================================================================
//     *                                             FORMAT EXTENSIONS
//     * ==============================================================================================================
//     */
//
//    public inherited sharing class FormatExtensions {
//
//        public String formatAddress(sObject obj, String addressType){
//            final List<String> addressFields = new List<String>{
//                addressType + 'Street',
//                addressType + 'City',
//                addressType + 'State',
//                addressType + 'PostalCode',
//                addressType + 'Country'
//            };
//
//            List<String> addressParts = new List<String>();
//            for(String addressField : addressFields){
//                String addressFieldValue = (String)obj.get(addressField);
//                if (!String.isEmpty(addressFieldValue)){
//                    addressParts.add(addressFieldValue);
//                }
//            }
//
//            return String.join(addressParts, ', ');
//        }
//
//        public String formatDateRange(Datetime startDate, Datetime endDate) {
//            String startOrdinalIndicator = getOrdinalIndicator(startDate);
//            String endOrdinalIndicator = getOrdinalIndicator(endDate);
//            String endDateFullFormatted = endDate == null ? '' : endDate.format('EEEE d\'' + endOrdinalIndicator + '\' MMM, yyyy');
//            if (startDate != null) {
//                String startDateFullFormatted = startDate.format('EEEE d\'' + startOrdinalIndicator + '\' MMM, yyyy');
//                if (endDate != null) {
//                    // The same Year
//                    if (startDate.year() == endDate.year()) {
//                        // The same Month
//                        if (startDate.month() == endDate.month()) {
//                            // The same Day
//                            if (startDate.day() == endDate.day()) {
//                                return endDateFullFormatted;
//                            } else {
//                                return startDate.format('EEEE d\'' + startOrdinalIndicator + '\'') + ' to ' + endDateFullFormatted;
//                            }
//                        } else {
//                            return startDate.format('EEEE d\'' + startOrdinalIndicator + '\' MMM') + ' to ' + endDateFullFormatted;
//                        }
//                    } else {
//                        return startDateFullFormatted + ' to ' + endDateFullFormatted;
//                    }
//                } else {
//                    return startDateFullFormatted;
//                }
//            } else {
//                return endDateFullFormatted;
//            }
//        }
//
//        public String getOrdinalIndicator(Datetime dateTimeVar) {
//            String ordinalIndicator = 'th';
//            if (dateTimeVar != null) {
//                Integer day = dateTimeVar.day();
//                if (Math.mod(day, 10) == 1 && day / 10 != 1) {
//                    ordinalIndicator = 'st';
//                }
//                if (Math.mod(day, 10) == 2 && day / 10 != 1) {
//                    ordinalIndicator = 'nd';
//                }
//                if (Math.mod(day, 10) == 3 && day / 10 != 1) {
//                    ordinalIndicator = 'rd';
//                }
//            }
//            return ordinalIndicator;
//        }
//
//        public String formatTimeRange(Datetime startDate, Datetime endDate) {
//            String endTimeFullFormatted = endDate == null ? '' : endDate.format('h:mm a');
//            if (startDate != null) {
//                String startTimeFullFormatted = startDate.format('h:mm a');
//                if (endDate != null) {
//                    // The same Time
//                    if (startDate.time() == endDate.time()) {
//                        return endTimeFullFormatted;
//                    } else {
//                        return startTimeFullFormatted + ' - ' + endTimeFullFormatted;
//                    }
//                } else {
//                    return startTimeFullFormatted;
//                }
//            } else {
//                return endTimeFullFormatted;
//            }
//        }
//
//        public String longTextAreaToHTML(String text) {
//            return text == null ? text : text.replaceAll('\\r\\n', '<br/>').replaceAll('\\n', '<br/>');
//        }
//
//        /*
//        formatPhoneNumbers(
//            contacts,
//            new Map<Schema.sObjectField, IPhoneNumberFormatter> {
//                Contact.Phone => new MobilePhoneNumberFormatter(),
//                Contact.HomePhone => new HomePhoneNumberFormatter()
//            },
//            true
//        )
//        */
//        public void formatPhoneNumbers(List<sObject> records, Map<Schema.sObjectField, IPhoneNumberFormatter> formatMapping, Boolean isOverride){
//
//            for(sObject record : records){
//
//                for(Schema.sObjectField field: formatMapping.keySet()){
//
//                    String fieldName = '' + field;
//                    IPhoneNumberFormatter formater = formatMapping.get(field);
//
//                    String oldValue = (String)record.get(fieldName);
//                    if (String.isEmpty(oldValue) || isOverride == true){
//                        record.put(fieldName, formater.format(oldValue));
//                    }
//                }
//            }
//
//        }
//
//    }
//
//
//    /**
//     * ==============================================================================================================
//     *                                     FORMAT EXTENSIONS (PHONE FORMATTERS)
//     * ==============================================================================================================
//     */
//
//    public interface IPhoneNumberFormatter {
//        String format(String phone);
//    }
//
//    // Formats Phone number to '0411 222 333'
//    public inherited sharing class MobilePhoneNumberFormatter implements IPhoneNumberFormatter {
//
//        public String format(String phone){
//            if (String.isNotEmpty(phone)) {
//                String phoneFormatted = strings.removeNonNumeric(phone);
//
//                phoneFormatted = phoneFormatted.replaceFirst('^(\\d{0,4})(\\d{0,3})(\\d{0,3})(\\d*)$', '$1 $2 $3 $4');
//
//                return phoneFormatted;
//            }
//
//            return phone;
//        }
//
//    }
//
//    // Formats phone to '+64 9 308 6200'
//    public inherited sharing class HomePhoneNumberFormatter implements IPhoneNumberFormatter {
//
//        public String format(String phone){
//            if (String.isNotEmpty(phone)) {
//                String phoneFormatted = strings.removeNonNumeric(phone);
//
//                phoneFormatted = phoneFormatted.replaceFirst('^(\\d{0,2})(\\d{0,4})(\\d{0,4})(\\d*)$', '$1 $2 $3 $4');
//
//                return phoneFormatted;
//            }
//
//            return phone;
//        }
//
//    }


    /**
     * ==============================================================================================================
     *                                             XML EXTENSIONS
     * ==============================================================================================================
     */

    /**
    @Description: Contains methods for serializing Apex objects into XML format and deserializing XML to Apex object.
    **/
//    public inherited sharing class XMLExtensions {
//
//        //Private Members
//        private boolean serializeNulls = true;  				// Serializes XML nodes even if the content is null
//        private string rootElement;              				// Root element to wrap around the serialized string.
//        private Set<string> deSerializeAsArrayNodes = new Set<string>();	// Collection of node names to be deserialized as array.
//
//        /*
//        @Description    : Serializes the object passed to XML string
//        @Parameter      : objectToSerialize = Apex object to serialize into XML
//        @Returns        : XML String
//        */
//        public string serialize(object objectToSerialize){
//            object deSerialized = JSON.deserializeUntyped(JSON.serialize(objectToSerialize));
//            return !string.isEmpty(rootElement) ? Wrap(rootElement,serialize((Map<string,object>)deSerialized)) : serialize((Map<string,object>)deSerialized);
//        }
//
//        /*
//        @Description    : Serializes the object to XML string.
//        @Parameter      : objectToSerialize = Apex object to serialize into XML
//        @Parameter      : suppressApexObjectNulls = if true, it will not serialize empty elements to XML.
//        @Parameter	: Name of the root element to wrap serialized string with.
//        @Returns        : XML String
//        */
//        public string serialize(object objectToSerialize,boolean suppressApexObjectNulls,string addRootElementName){
//            this.serializeNulls = !suppressApexObjectNulls;
//            this.rootElement = addRootElementName;
//            return serialize(objectToSerialize);
//        }
//
//        /*
//        @Description    : Converts JSON string to XML String.
//        @Parameter      : jsonString = jsonString
//        @Returns        : XML String
//        */
//        public string jsonToXML(string jsonString){
//            object deSerialized = JSON.deserializeUntyped(jsonString);
//            return !string.isEmpty(rootElement) ? Wrap(rootElement,serialize((Map<string,object>)deSerialized)) : serialize((Map<string,object>)deSerialized);
//        }
//
//        /*
//        @Description    : Converts JSON string to XML String.
//        @Parameter      : jsonString = jsonString
//        @Parameter	: suppressNulls = ignores empty Json elements, if true
//        @Returns        : XML String
//        */
//        public string jsonToXML(string jsonString,boolean suppressNulls){
//            this.serializeNulls = !suppressNulls;
//            return jsonToXML(jsonString);
//        }
//
//        /*
//        @Description    : deSerializes the xml into the object of apextype
//        @Parameter      : xmlString = xml String to deSerialize
//        @Parameter      : apexType  = type of object to deSerialize to
//        @Returns        : object of type apexType
//        */
//        public object deSerialize(string xmlString, System.Type apexType){
//            string json = XMLToJson(xmlString);
//            return System.JSON.deserialize(json,apexType);
//        }
//
//        /*
//        @Description    : deSerializes the xml into the object of the type passed
//        @Parameter      : xmlString = xml String to deSerialize
//        @Parameter      : apexType  = type of object to deSerialize to
//        @Parameter      : deSerializeNodesAsArray  = collection of node names to deserialize as array (Even if xml representation is not an array)
//        @Returns        : object of type apexType
//        */
//        public object deSerialize(string xmlString, System.Type apexType,Set<String> deSerializeNodesAsArray){
//            this.deSerializeAsArrayNodes = toLower(deSerializeNodesAsArray);
//            return deSerialize(xmlString,apexType);
//        }
//
//        /*
//        @Description    : deSerializes the xml string into collection of primitive data types.
//        @Parameter      : xmlString = xml String to deSerialize
//        @Returns        : collection of primitive data types
//        */
//        public object deSerializeUnTyped(string xmlString){
//            return xmlToUnTyped(xmlString);
//        }
//
//        /*
//        @Description    : deSerializes the xml string into collection of primitive data types.
//        @Parameter      : xmlString = xml String to deSerialize
//        @Parameter      : deSerializeNodesAsArray  = collection of node names to deserialize as array (Even if xml representation is not an array)
//        @Returns        : collection of primitive data types
//        */
//        public object deSerializeUnTyped(string xmlString,Set<string> deSerializeNodesAsArray){
//            this.deSerializeAsArrayNodes = toLower(deSerializeNodesAsArray);
//            return xmlToUnTyped(xmlString);
//        }
//
//        /*
//        @Description    : Converts XML string to json string
//        @Parameter      : xmlString = XML String to convert
//        @Returns        : JSON String
//        */
//        public  string XMLToJSON(string xmlString){
//            return System.JSON.serialize(XMLToUnTyped(xmlString));
//        }
//
//        /*
//        @Description    : Converts XML string to json string
//        @Parameter      : xmlString = XML String to convert
//        @Parameter      : deSerializeNodesAsArray  = collection of node names to deserialize as array (Even if xml representation is not an array)
//        @Returns        : JSON String
//        */
//        public  string xmlToJSON(string xmlString,Set<string> deSerializeNodesAsArray){
//            this.deSerializeAsArrayNodes = toLower(deSerializeNodesAsArray);
//            return System.JSON.serialize(XMLToUnTyped(xmlString));
//        }
//
//        /*
//        @Description    : resets serialize and deserialize options to default
//        */
//        public void resetDefaults(){
//            this.serializeNulls = true;
//            this.rootElement = null;
//            this.deSerializeAsArrayNodes.clear();
//        }
//
//        //Helpers
//
//        /*
//        @Description    : Serialize method
//        @Parameter      : objectMap = Map of String and objects
//        @Returns        : XML String
//        */
//        private string serialize(Map<string,object> objectMap){
//            string xmlString = '';
//            for(string key:objectMap.keySet()){
//                object o = objectMap.get(key);
//                if(o == null) { if(this.SerializeNulls)     xmlString += wrap(key,null); }
//                else if(o InstanceOf List<object> )         xmlString += serialize((List<object>) o,key);
//                else if(o InstanceOf Map<string,object> )   xmlString += wrap(key,serialize((Map<string,object>) o));
//                else                                        xmlString += wrap(key,string.valueOf(o));
//            }
//            return xmlString;
//        }
//
//        /*
//        @Description    : Serialize method
//        @Parameter      : objectList = List of objects
//        @Parameter      : key = key to wrap all elements of the list with
//        @Returns        : XML String
//        */
//        private string serialize(List<object> objectList, string key){
//            string xmlString = '';
//            for(object o:objectList){
//                if (o InstanceOf string)				xmlString += wrap(key,string.valueOf(o));
//                else if(o InstanceOf List<object> )  	xmlString += wrap(key,serialize((List<object>) o, key));
//                else                            		xmlString += wrap(key,serialize((Map<string,object>) o));
//            }
//            return xmlString;
//        }
//
//        /*
//        @Description    : Wraps value with key xml element
//        @Parameter      : key = Xml node name
//        @parameter	: value = xml node value
//        @Returns        : XML String
//        */
//        private string wrap(string key, string value){
//            return (string.isNotBlank(value) || serializeNulls) ? ('<' + key + '>' + (string.isBlank(value)?'':value) + '</' + key + '>') : value;
//        }

        /*
        @Description    : deSerializes the xml string into collection of primitive data types.
        @Parameter      : xmlString = xml String to deSerialize
        @Parameter      : deSerializeNodesAsArray  = collection of node names to deserialize as array (Even if xml representation is not an array)
        @Returns        : collection of primitive data types
        */
//        private  Map<string,object> XMLToUnTyped(string xmlString){
//            xmldom xd = new xmldom(xmlString);
//            XMLElement document = xd.ownerDocument();
//            return (Map<string,object>)parseNode(document);
//        }
//
//        /*
//        @Description    : parses an XML node
//        @Parameter      : e = xml node (of type XMLElement)
//        @Returns        : object
//        */
//        private object parseNode(XMLElement e){
//            if(e.childNodes.size()>0) return complexNodeToMap(e);
//            else  return e.nodeValue;
//        }
//
//        /*
//        @Description    : Converts a complex xml node to collection of primitive types.
//        @Parameter      : e = xml node (of type XMLElement)
//        @Returns        : Map representation of the node.
//        */
//        private Map<string,object> complexNodeToMap(XMLElement e){
//            Map<string,object> cNodeMap = new Map<string,object>();
//            for(XMLElement cNode : e.childNodes){
//                if(cNodeMap.containsKey(cNode.nodeName)){
//                    object o = cNodeMap.get(cNode.nodeName);
//                    if(o InstanceOf List<object>) ((List<object>) o).add(parseNode(cNode));
//                    else cNodeMap.put(cNode.nodeName,new List<object>{o,parseNode(cNode)});
//                }
//                else cNodeMap.put(cNode.nodeName, deSerializeAsArrayNodes.contains(cNode.nodeName.toLowerCase())? new List<object>{parseNode(cNode)} : parseNode(cNode));
//            }
//            return cNodeMap;
//        }
//
//        /*
//        @Description    : Converts all elements of the set to lower case
//        @Parameter      : stringSet = Set of strings to convert to lower case.
//        @Returns        : Converted set of strings.
//        */
//        private Set<string> toLower(Set<string> stringSet){
//            Set<string> lowerStringSet = new Set<string>();
//            for(string s:stringSet) lowerStringSet.add(s.toLowerCase());
//            return lowerStringSet;
//        }
//    }


    /**
     * ==============================================================================================================
     *                                             TEMPLATE EXTENSIONS
     * ==============================================================================================================
     */

    public inherited sharing class TemplateExtensions {

        public String compose(String template, Map<String, Object> dtoMap) {
            return this.compose(template, new DTO(dtoMap));
        }

        public String compose(String template, DTO dto) {

            String reExp = '(?s)(\\{!.+?\\})';

            Pattern patternVar = Pattern.compile(reExp);
            Matcher matcherVar = patternVar.matcher(template);

            Set<String> placeholders = new Set<String>();

            while (matcherVar.find()) {
                for (Integer i = 1; i <= matcherVar.groupCount(); i++) {
//                    System.debug(matcherVar.group(i));
                    String placeholder = matcherVar.group(i);
                    placeholders.add(placeholder);
                }
            }

            String result = template;

            for (String placeholder : placeholders) {

                Structs.Expression expressionVar = getExpression(placeholder);

                try {
                    result = expressionVar.apply(dto, result);
                } catch (Exception ex) {
                    throw new Structs.ProcessException('Unable to apply merge field: ' + placeholder);
                }
            }

            return result;
        }

        public Set<String> extractMergeFields(String template) {

            String reExp = '(?s)(\\{!.+?\\})';

            Pattern patternVar = Pattern.compile(reExp);
            Matcher matcherVar = patternVar.matcher(template);

            Set<String> fieldNames = new Set<String>();

            while (matcherVar.find()) {
                for (Integer i = 1; i <= matcherVar.groupCount(); i++) {
                    String placeholder = matcherVar.group(i);
                    fieldNames.add(placeholder.substringBetween('{!', '}'));
                }
            }

            return fieldNames;
        }

        public Structs.Expression getExpression(String placeholder) {
            Structs.Expression expressionVar;

            if (String.isBlank(placeholder)) {
                return expressionVar;
            }

            // Remove the brackets  {! }
            String expressionStr = placeholder.substring(2, placeholder.length() - 1);
            expressionVar = new Structs.MergeFieldExpression(expressionStr);

            return expressionVar;
        }

    }


    /**
     * ==============================================================================================================
     *                                             OTHER UTILITIES
     * ==============================================================================================================
     */

    private class TPicklistEntry{
        public string active {get;set;}
        public string defaultValue {get;set;}
        public string label {get;set;}
        public string value {get;set;}
        public string validFor {get;set;}
        public TPicklistEntry(){
        }
    }

    private class Bitset{
        public Map<String,Integer> AlphaNumCharCodes {get;set;}
        public Map<String, Integer> Base64CharCodes { get; set; }

        Bitset(){
            LoadCharCodes();
        }

        //Method loads the char codes
        private void LoadCharCodes(){
            AlphaNumCharCodes = new Map<String,Integer>{
                'A'=>65,'B'=>66,'C'=>67,'D'=>68,'E'=>69,'F'=>70,'G'=>71,'H'=>72,'I'=>73,'J'=>74,
                'K'=>75,'L'=>76,'M'=>77,'N'=>78,'O'=>79,'P'=>80,'Q'=>81,'R'=>82,'S'=>83,'T'=>84,
                'U'=>85,'V'=> 86,'W'=>87,'X'=>88,'Y'=>89,'Z'=>90
            };
            Base64CharCodes = new Map<String, Integer>();
            //lower case
            Set<String> pUpperCase = AlphaNumCharCodes.keySet();
            for(String pKey : pUpperCase){
                //the difference between upper case and lower case is 32
                AlphaNumCharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey)+32);
                //Base 64 alpha starts from 0 (The ascii charcodes started from 65)
                Base64CharCodes.put(pKey,AlphaNumCharCodes.get(pKey) - 65);
                Base64CharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey) - (65) + 26);
            }
            //numerics
            for (Integer i=0; i<=9; i++){
                AlphaNumCharCodes.put(string.valueOf(i),i+48);
                //base 64 numeric starts from 52
                Base64CharCodes.put(string.valueOf(i), i + 52);
            }
        }

        /*
            Effect: Method takes a validFor string and tests it against a set of controlling indexes
            Postcondition: Returns a list of all controlling indexes for which the validFor string test True
        */
        public List<Integer> testBits(String pValidFor,List<Integer> nList){
            List<Integer> results = new List<Integer>();
            //the list of bytes (not derived from n)
            List<Integer> pBytes = new List<Integer>();
            //multiply by 6 since base 64 uses 6 bits (not derived form n)
            Integer bytesBeingUsed = (pValidFor.length() * 6)/8;
            //will be used to hold the full decimal value (not derived from n)
            Integer pFullValue = 0;
            //must be more than 1 byte
            if (bytesBeingUsed <= 1)
                return results;
            //get the base64bytes
            for(Integer i=0;i<pValidFor.length();i++){
                //get currenct character value
                pBytes.Add((Base64CharCodes.get((pValidFor.Substring(i, i+1)))));
            }
            //calculate the full decimal value
            for (Integer i = 0; i < pBytes.size(); i++)
            {
                Integer pShiftAmount = (pBytes.size()-(i+1))*6;//used to shift by a factor 6 bits to get the value

                if (pBytes[i] != null){
                    pFullValue = pFullValue + (pBytes[i] << (pShiftAmount));
                }
            }
            //now we don't want to always be declaring memory, so let's set the initial
            //variables
            Integer bit;
            Integer targetOctet;
            Integer shiftBits;
            Integer tBitVal;
            Integer n;
            Integer nListSize = nList.size();
            for(Integer i=0; i<nListSize; i++){
                n = nList[i];
                //calculate the target bit for comparison
                bit = 7 - (Math.mod(n,8));
                //calculate the octet that has in the target bit
                targetOctet = (bytesBeingUsed - 1) - (n >> bytesBeingUsed);
                //the number of bits to shift by until we find the bit to compare for true or false
                shiftBits = (targetOctet * 8) + bit;
                //& is to set the same set of bits for testing
                //shift to the bit which will dictate true or false
                //Math.Pow(2, shiftBits) == 2 << (shiftBits+1)
                tBitVal = ((Integer)(2 << (shiftBits-1)) & pFullValue) >> shiftBits;
                if (tBitVal==1)
                    results.add(n);
            }
            return results;
        }
    }

    // Converts a base64 string into a list of integers representing the encoded bytes
    public static List<Integer> B64ToBytes (String sIn) {
        Map<Integer,Integer> base64 = new Map<Integer,Integer>{65=>0,66=>1,67=>2,68=>3,69=>4,70=>5,71=>6,72=>7,73=>8,74=>9,75=>10,76=>11,77=>12,78=>13,79=>14,80=>15,81=>16,82=>17,83=>18,84=>19,85=>20,86=>21,87=>22,88=>23,89=>24,90=>25
        ,97=>26,98=>27,99=>28,100=>29,101=>30,102=>31,103=>32,104=>33,105=>34,106=>35,107=>36,108=>37,109=>38,110=>39,111=>40,112=>41,113=>42,114=>43,115=>44,116=>45,117=>46,118=>47,119=>48,120=>49,121=>50,122=>51
        ,48=>52,49=>53,50=>54,51=>55,52=>56,53=>57,54=>58,55=>59,56=>60,57=>61,43=>62,47=>63};

        List<Integer> lstOut = new List<Integer>();
        if ( sIn == null || sIn == '' ) return lstOut;

        sIn += '='.repeat( 4 - Math.mod( sIn.length(), 4) );

        for ( Integer idx=0; idx < sIn.length(); idx += 4 ) {
            if ( base64.get(sIn.charAt(idx+1)) != null ) lstOut.add( (base64.get(sIn.charAt(idx)) << 2) | (base64.get(sIn.charAt(idx+1)) >>> 4) );
            if ( base64.get(sIn.charAt(idx+2)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+1)) & 15)<<4) | (base64.get(sIn.charAt(idx+2)) >>> 2) );
            if ( base64.get(sIn.charAt(idx+3)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+2)) & 3)<<6) | base64.get(sIn.charAt(idx+3)) );
        }

        //System.Debug('B64ToBytes: [' + sIn + '] = ' + lstOut);
        return lstOut;
    }//B64ToBytes

    public static List<Integer> BlobToBytes (Blob input) {
        return B64ToBytes( EncodingUtil.base64Encode(input) );
    }//BlobToBytes

    // Converts a base64 string into a list of integers indicating at which position the bits are on
    public static List<Integer> cnvBits (String b64Str) {
        List<Integer> lstOut = new List<Integer>();
        if ( b64Str == null || b64Str == '' ) return lstOut;

        List<Integer> lstBytes = B64ToBytes(b64Str);

        Integer i, b, v;
        for ( i = 0; i < lstBytes.size(); i++ ) {
            v = lstBytes[i];
            //System.debug ( 'i['+i+'] v['+v+']' );
            for ( b = 1; b <= 8; b++ ) {
                //System.debug ( 'i['+i+'] b['+b+'] v['+v+'] = ['+(v & 128)+']' );
                if ( ( v & 128 ) == 128 ) lstOut.add( (i*8) + b );
                v <<= 1;
            }
        }

        //System.Debug('cnvBits: [' + b64Str + '] = ' + lstOut);
        return lstOut;
    }//cnvBits

    /*
    This class implements a small portion of the wc3 xml dom model.
    Generally useful for simple XML return objects. Note: stores namespaces
    in the attributes map for now. No node typing done at this time

    can parse into DOM trees the XML return objects from Google, Amazon and others.
    large parse trees will consume suprising amounts of memory
    */
//    @TestVisible
//    private class XMLDom {
//        // Constructor
//        public XMLDom(string str) {
//            parseFromString(str);
//        }
//        public XMLDom() {
//        }
//        public void parseFromString(string str) {
//            XmlStreamReader reader = new XmlStreamReader(str);
//            reader.setCoalescing(true);
//            parseXmlReader (root, reader);
//        }
//
//        // debugging assistance
//        public void dumpAll() {
//            root.dumpAll();
//        }
//        public void dumpList(XMLElement[] l) {
//            for (XMLElement e : l) e.dump();
//        }
//        integer count = 0 ;
//        // given a parent node and a stream reader, populates the tree below here (recursive)
//        void parseXmlReader(XMLElement parent, XmlStreamReader reader) {
//
//            try {
//                while (reader.hasNext()) {
//
//                    if (reader.getEventType() == XmlTag.START_ELEMENT) {
//                        XMLElement child = new XMLElement(reader.getLocalName());
//
//                        // add all attributes from this element
//                        for (integer i = 0; i < reader.getAttributeCount(); i++) {
//                            child.attributes.put(reader.getAttributeLocalName(i), reader.getAttributeValueAt(i));
//                        }
//                        // add namespace info to each node/element ( for now storing on attributes map)
//                        for (integer j = 0; j < reader.getNamespaceCount(); j++) {
//                            string prefix = 'xmlns';
//                            if (reader.getnamespaceprefix(j) != null)
//                                prefix = reader.getnamespaceprefix(j);
//                            child.attributes.put(prefix, reader.getnamespaceuriat(j));
//                        }
//
//                        parent.appendChild(child); // add the new element to current parent
//
//                        if (child.nodeName == 'item') {
//                            count++;
//                        }
//                        if (child.nodeName == 'entry') {
//                            count++;
//                        }
//                        if (count > 10) {
//                            return;
//                        } // avoid a bug in xmlstream reader
//
//                        // system.debug(count + ' '+ reader.getLocation() + ' ' +child.nodeName);
//                        if (reader.hasNext()) reader.next(); else return;
//                        parseXmlReader(child, reader) ; // recurse
//
//                    } else if (reader.getEventType() == XmlTag.END_ELEMENT) {
//                        reader.next();
//                        return;
//
//                    } else if (reader.getEventType() == XmlTag.CHARACTERS) {
//                        if (!reader.isWhitespace()) {
//                            parent.nodeValue += reader.getText();  // add text to current element
//                        }
//                        reader.next();
//
//                    } else {
//                        reader.next();
//                    }
//                }
//            } catch (Exception e) { // ParseError if we get a truncated response, allow it
//                system.debug('caught ' + e);
//                parent.dumpAll();
//            }
//        }
//
//        // access nodes in the tree using these getters
//        public List<XMLElement> getElementsByTagName(string nam) {
//            return root.getElementsByTagName(nam);
//        }
//
//        public XMLElement getElementByTagName(string nam) {
//            List<XMLElement> r = root.getElementsByTagName(nam);
//            if (r.size() == 0) return null;
//            return r[0];
//        }
//
//        // utility dom functions
//        public XMLElement ownerDocument() {
//            return root;
//        }
//
//        // everything in the dom is found as childNodes under this root element
//        public XMLElement root = new XMLElement('#document');
//        public integer debug = 0;
//        // dump out the element tree
//        public String toXmlString() {
//            return root.toXmlString();
//        }
//
//    }

    /**
    XMLElement  class definition

    This following class implements a small portion of the wc3 xml dom model.
    Generally useful for simple XML return objects.

    for a properties and methods complete list see:
    http://www.w3schools.com/dom/dom_node.asp

    For simplicity, Nodes are the same as Elements in this class.
    Nodes have text directly in them, rather than a seperate text node child
    The following describes the implemented portion, some w3c properties are now methods.

    Property    Description

    nodeName    Returns the name of a node, depending on its type
    nodeValue   Sets or returns the value of a node, depending on its type
    childNodes  Returns a NodeList of child nodes for a node
    parentNode  Returns the parent node of a node
    attributes      Returns a NamedNodeMap of attributes for the element, also contains name space entries

    getElementByTagName() Returns list of elements matching tag name (document and element)
    firstChild()    Returns the first child of a node
    removeChild()   Removes a child node
    appendChild()   Adds a new child node to the end of the list of children of a node
    getAttribute()  Returns the value of an attribute
    hasChildNodes()     Returns whether the element has any child nodes
    isEqualNode()   Checks if two nodes are equal
    textContent()   returns the textual content of a node
    cloneNode()     Clones a node
    hasAttributes()     Returns whether the element has any attributes
    isSameNode()    Checks if two nodes are the same node
    ownerDocument()     Returns the root element (document object) for a node


    *** NOT Implemented at this time ***

    lastChild()     Returns the last child of a node
    nodeType    Returns the type of a node , all nodes are the same type currently
    baseURI     Returns the absolute base URI of a node
    localName   Returns the local part of the name of a node
    namespaceURI    Returns the namespace URI of a node
    nextSibling     Returns the node immediately following a node
    insertBefore()  Inserts a new child node before an existing child node
    replaceChild()  Replaces a child node
     */
//    @TestVisible
//    private class XMLElement {
//        //  XMLElement(XMLElement p, string n) {      parentNode = p;         nodeName = n;       }
//        public XMLElement(string n) {
//            nodeName = n;
//        }
//        public XMLElement() {
//        }
//
//        public string getAttribute(string name) {
//            return attributes.get(name);
//        }
//        public void appendChild(XMLElement e) {
//            e.ParentNode = this;
//            this.childNodes.add(e);
//        }
//        public void removeChild(XMLElement e) {
//            XMLElement p = e.parentNode;
//            List<XMLElement> kids = new List<XMLElement>{
//            };
//            for (XMLElement ee : e.parentNode.childNodes) {
//                if (ee != e)
//                    kids.add(ee);
//            }
//            p.childNodes = kids;
//        }
//        // traverse below this node, returning all matching nodes by name
//        public List<XMLElement> getElementsByTagName(string nam) {
//            List<XMLElement> ret = new List<XMLElement>{
//            };
//            if (nam == this.nodeName) ret.add(this);
//            for (XMLElement c : this.childNodes) {
//                ret.addAll(c.getElementsByTagName(nam)); // decend tree
//            }
//            return ret;
//        }
//        // like above, but just returns the first one that matches
//        public XMLElement getElementByTagName(string nam) {
//            List<XMLElement> r = getElementsByTagName(nam);
//            if (r.size() == 0) return null;
//            return r[0];
//        }
//        // first one that matches, just return the nodeValue
//        public string getValue(string nam) {
//            XMLElement e = getElementByTagName(nam);
//            return (e == null ? null : e.nodeValue);
//        }
//
//        // some debugging help
//        public void dump() {
//            dump('');
//        }
//        public void dump(string pre) { // just current node
//            system.debug(pre + ' ' + this.nodeName + '->' + this.nodeValue + ' ' + this.attributes);
//        }
//        public void dumpAll() {
//            dumpAll('');
//        }
//        public void dumpAll(string pre) { // node and all children
//            system.debug(pre + this.nodeName + '->' + this.nodeValue + ' ' + this.attributes);
//            for (XMLElement c : this.childNodes) {
//                c.dumpAll(pre + '   ');
//            }
//        }
//        public string toXmlString() {
//            string ret = '<' + this.nodeName + ' ';
//            for (string a : attributes.keySet()) {
//                ret += a + '=\'' + attributes.get(a) + '\' ' ;
//            }
//            ret += '>';
//            if (nodeValue == '') ret += '\n';
//            for (XMLElement c : this.childNodes) {
//                ret += c.toXmlString() ;//+ '\n';
//            }
//            if (nodeValue != '')
//                ret += nodeValue;
//            //else ret += '\n';
//            return ret + '</' + this.nodeName + '>\n';
//        }
//        /*
//         * experimental path based patern matching, sort of like xpath,
//         * but simpler, just matches a path() string with the pattern supplied
//         */
//        // * /bookstore/book/.*
//        // /.*book/.*
//        // /.*/book$
//        public List<XMLElement> getElementsByPath(string path) {
//            List<XMLElement> ret = new List<XMLElement>{
//            };
//            // system.debug( path + ' ' + this.path());
//            if (Pattern.matches(path, this.path())) ret.add(this);
//            for (XMLElement c : this.childNodes) ret.addAll(c.getElementsByPath(path));
//            return ret;
//        }
//        public string path() {
//            XMLElement t = this;
//            string ret = t.nodeName;
//            while (t.parentNode != null && t.parentNode.nodeName != '#document') {
//                t = t.parentNode;
//                ret = t.nodeName + '/' + ret;
//            }
//            return '/' + ret;
//        }

//        // utility methods
//        public XMLElement firstChild() {
//            if (this.childNodes.size() == 0) return null;
//            return this.childNodes[0];
//        }
//        public string textContent() {
//            return this.nodeValue;
//        }
//        public boolean hasChildNodes() {
//            return childNodes.size() > 0;
//        }
//        public boolean isEqualNode(XMLElement comp) {
//            return this.nodeName == comp.nodeName;
//        }
//        public XMLElement cloneNode() {
//            return this.clone();
//        }
//        public boolean hasAttributes() {
//            return !attributes.isEmpty();
//        }
//        public boolean isSameNode(XMLElement comp) {
//            return this === comp;
//        }
//        public XMLElement ownerDocument() {
//            XMLElement ret = this;
//            while (ret.parentNode != null) {
//                ret = ret.parentNode;
//            }
//            return ret;
//        }
//
//        // properties
//        public XMLElement parentNode = null; // only root has a null parent
//        public string nodeName = '';
//        public string nodeValue = '';
//        public List<XMLElement> childNodes = new List<XMLElement>();
//        public map<String, String> attributes = new map<String, String>();

//    }

}