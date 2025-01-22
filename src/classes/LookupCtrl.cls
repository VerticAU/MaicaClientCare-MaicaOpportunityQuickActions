//SECURED!
public with sharing class LookupCtrl {

    @AuraEnabled
    public static String getRecentRecords(String jsonString) {

        Response responseData = new Response();

        try {
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<Id, RecentlyViewed> recentlyViewedMap = new Map<Id, RecentlyViewed>([
                SELECT Id
                FROM RecentlyViewed
                WHERE Type = :((String) jsonMap.get('object'))
                WITH USER_MODE
            ]);
            List<Id> idList = new List<Id>(recentlyViewedMap.keySet());

            if (idList.size() > 0) {
                String filter = 'Id IN (\'' + String.join(idList, '\',\'') + '\')';

                if (LookupCtrl.fieldNotEmpty(jsonMap, 'filter')) {
                    filter += ' AND (' + jsonMap.get('filter') + ')';
                }

                jsonMap.put('filter', filter);

                responseData.results = LookupCtrl.getData(jsonMap);
            }

            Boolean hasRecentRecords = responseData.results != null && responseData.results.get('data') != null &&
                ((List<Map<String, Object>>)responseData.results.get('data')).isEmpty() != true;

            if(hasRecentRecords == false){
                return getRecords(jsonString);
            }

        } catch (Exception e) {
            responseData.addError(e.getMessage());
        }

        return responseData.getJsonString();
    }

    @AuraEnabled
    public static String getRecordLabel(String jsonString) {
        Response responseData = new Response();

        try {
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

            String obj = (String) jsonMap.get('object');
            String objectLabel = Schema.describeSObjects(new List<String>{
                obj
            })[0].getLabel();

            responseData.results.put('objectLabel', objectLabel);
        } catch (Exception e) {
            responseData.addError(e.getMessage());
        }

        return responseData.getJsonString();
    }

    @AuraEnabled(cacheable=true)
    public static String getRecords(String jsonString) {

        try {

            Response responseData = new Response();

            try {
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
                responseData.results = LookupCtrl.getData(jsonMap);
            } catch (Exception e) {
                responseData.addError(e.getMessage() + e.getStackTraceString());
            }

            return responseData.getJsonString();

        } catch (Exception ex) {
            throw ex;
        } finally {
        }
    }

    private static Map<String, Object> getData(Map<String, Object> jsonMap) {
        List<Map<String, Object>> data = new List<Map<String, Object>>();

        String objType = String.escapeSingleQuotes((String) jsonMap.get('object'));

        List<SObject> records = new List<SObject>();

        Boolean isSOSLSearch = LookupCtrl.fieldNotEmpty(jsonMap, 'searchTerm') &&
            'SOQL'.equalsIgnoreCase((String)jsonMap.get('searchMode')) != true;

        if(isSOSLSearch == true){
            List<List <SObject>> recordListList = Search.query(getSOSLQuery(jsonMap));
            for(List<SObject> recordList : recordListList){
                records.addAll(recordList);
            }
        } else {
            records = Database.query(getQuery(jsonMap));
        }

        Utils.sObjects.assertReadable(records);

        List<String> searchFields = ((String) jsonMap.get('searchField')).split(',');
        String searchField = searchFields.isEmpty() ? '' : String.escapeSingleQuotes(searchFields.get(0));
        String searchTerm = '';
        String subtitleField;

        if (LookupCtrl.fieldNotEmpty(jsonMap, 'subtitleField')) {
            subtitleField = String.escapeSingleQuotes((String) jsonMap.get('subtitleField'));
        }

        if (LookupCtrl.fieldNotEmpty(jsonMap, 'searchTerm')) {
            searchTerm = String.escapeSingleQuotes((String) jsonMap.get('searchTerm'));
        }

        if (String.isEmpty(subtitleField)) {
            for (sObject obj : records) {
                data.add(new Map<String, Object>{
                    'label' => LookupCtrl.getValue(obj, objType, searchField),
                    'value' => obj.get(Utils.objects.defaultIfNull((String) jsonMap.get('valueField'), 'Id'))
                });
            }
        } else {
            for (sObject obj : records) {
                data.add(new Map<String, Object>{
                    'label' => LookupCtrl.getValue(obj, objType, searchField),
                    'sublabel' => LookupCtrl.getValue(obj, objType, subtitleField),
                    'value' => obj.get(Utils.objects.defaultIfNull((String) jsonMap.get('valueField'), 'Id'))
                });
            }
        }

        return new Map<String, Object>{
            'data' => data,
            'searchTerm' => searchTerm
        };
    }

    private static String getQuery(Map<String, Object> jsonMap) {
        Set<String> queryFields = new Set<String>{
            'Id'
        };
        List<String> filters = new List<String>();
        List<String> orders = new List<String>();

        String query;
        String obj = String.escapeSingleQuotes((String) jsonMap.get('object'));
        String subtitleField;

        if (LookupCtrl.fieldNotEmpty(jsonMap, 'subtitleField')) {
            subtitleField = String.escapeSingleQuotes((String) jsonMap.get('subtitleField'));
            queryFields.add(subtitleField);
        }

        if (LookupCtrl.fieldNotEmpty(jsonMap, 'valueField')) {
            String valueField = String.escapeSingleQuotes((String) jsonMap.get('valueField'));
            queryFields.add(valueField);
        }

        if (LookupCtrl.fieldNotEmpty(jsonMap, 'searchField')) {
            for (String searchField : ((String) jsonMap.get('searchField')).split(',')) {
                queryFields.add(String.escapeSingleQuotes(searchField));
            }
//            queryFields.addAll(((String) jsonMap.get('searchField')).split(','));

            if (LookupCtrl.fieldNotEmpty(jsonMap, 'searchTerm')) {
                List<String> searchFields = ((String) jsonMap.get('searchField')).split(',');
                //String searchField = String.escapeSingleQuotes((String)jsonMap.get('searchField'));
                String searchTerm = String.escapeSingleQuotes((String) jsonMap.get('searchTerm'));

                List<String> searchFilters = new List<String>();
                for (String searchField : searchFields) {
                    searchFilters.add(String.escapeSingleQuotes(searchField) + ' LIKE \'%' + searchTerm + '%\'');
                }

                if (!searchFilters.isEmpty()) {
                    filters.add('(' + String.join(searchFilters, ' OR ') + ')');
                }
            }
        }

        if (LookupCtrl.fieldNotEmpty(jsonMap, 'filter')) {
            filters.add('(' + (String) jsonMap.get('filter') + ')'); // SOQL SOSL Injection False Positive: Dynamic filter required to apply to Lighting Component.
        }

        if (LookupCtrl.fieldNotEmpty(jsonMap, 'order')) {
            orders.add(String.escapeSingleQuotes((String) jsonMap.get('order')));
        }

        query = 'SELECT ' + String.join(new List<String>(queryFields), ', ');
        query += ' FROM ' + obj;

        if (filters.size() > 0) {
            query += ' WHERE ' + String.join(filters, ' AND ');
        }

        query += ' WITH USER_MODE ';

        if (orders.size() > 0) {
            query += ' ORDER BY ' + String.join(orders, ', ');
        }

        if (LookupCtrl.fieldNotEmpty(jsonMap, 'limit')) {
            query += ' LIMIT ' + String.escapeSingleQuotes((String) jsonMap.get('limit'));
        }

//        System.debug(query);

        return query;
    }

    private static Boolean fieldNotEmpty(Map<String, Object> jsonMap, String field) {
        return jsonMap.containsKey(field) && !String.isEmpty((String) jsonMap.get(field));
    }

    private static String getSOSLQuery(Map<String, Object> jsonMap) {

        Set<String> queryFields = new Set<String>{ 'Id' };
        List<String> searchFields = new List<String>();
        List<String> filters = new List<String>();
        List<String> orders = new List<String>();

        String query;
        String subtitleField;
        String searchTerm;

        String obj = String.escapeSingleQuotes((String) jsonMap.get('object'));

        if(Schema.getGlobalDescribe().get(obj)?.getDescribe()?.isAccessible() != true){
            throw new Structs.AccessException('No access to ' + obj);
        }

        if (LookupCtrl.fieldNotEmpty(jsonMap, 'subtitleField')) {
            subtitleField = String.escapeSingleQuotes((String) jsonMap.get('subtitleField'));
            queryFields.add(subtitleField);
        }

        if (LookupCtrl.fieldNotEmpty(jsonMap, 'searchField')) {
            searchFields = ((String) jsonMap.get('searchField')).split(',');
            queryFields.addAll(searchFields);
        }

        if (LookupCtrl.fieldNotEmpty(jsonMap, 'valueField')) {
            String valueField = String.escapeSingleQuotes((String) jsonMap.get('valueField'));
            queryFields.add(valueField);
        }

        if (LookupCtrl.fieldNotEmpty(jsonMap, 'searchTerm')) {
            searchTerm = String.escapeSingleQuotes((String) jsonMap.get('searchTerm'));

            List<String> searchFilters = new List<String>();
            for (String searchField : searchFields) {
                searchFilters.add(String.escapeSingleQuotes(searchField) + ' LIKE \'%' + searchTerm + '%\'');
            }
            if (!searchFilters.isEmpty()) {
                filters.add('(' + String.join(searchFilters, ' OR ') + ')');
            }
        }

        if (LookupCtrl.fieldNotEmpty(jsonMap, 'filter')) {
            filters.add('(' + (String) jsonMap.get('filter') + ')'); // SOQL SOSL Injection False Positive: Dynamic filter required to apply to Lighting Component.
        }

        if (LookupCtrl.fieldNotEmpty(jsonMap, 'order')) {
            orders.add(String.escapeSingleQuotes((String) jsonMap.get('order')));
        }

        query = 'FIND ' + '\'*' + searchTerm + '*\'' + ' IN ALL FIELDS RETURNING ' + obj + '(' + String.join(new List<String>(queryFields), ', ');

        if (filters.size() > 0) {
            query += ' WHERE ' + String.join(filters, ' AND ');
        }

        if (orders.size() > 0) {
            query += ' ORDER BY ' + String.join(orders, ', ');
        }

        if (LookupCtrl.fieldNotEmpty(jsonMap, 'limit')) {
            query += ' LIMIT ' + String.escapeSingleQuotes((String) jsonMap.get('limit'));
        }

        query += ')';

//        System.debug(query);

        return query;
    }

    private static String getValue(SObject obj, String objectType, String field) {
        List<String> fieldPath = field.split('[.]');
        Object label = convertObjectToMap(obj);
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap();

        for (String fieldName : fieldPath) {
            fieldName = fieldName.replaceAll('__r$', '__c');

            label = ((Map<String, Object>) label).get(fieldName);

            if (label == null) {
                return '';
            }

            if (fieldMap.containsKey(fieldName + 'Id')) {
                fieldName = fieldName + 'Id';
            }

            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            String fieldType = String.valueOf(fieldDescribe.getType()).toUpperCase();

            if (fieldType == 'REFERENCE') {
                fieldMap = Schema.getGlobalDescribe().get(String.valueOf(fieldDescribe.getReferenceTo().get(0))).getDescribe().fields.getMap();
            } else if (fieldType == 'ADDRESS') {
                List<String> addressComponents = new List<String>();
                Map<String, Object> addr = (Map<String, Object>) label;

                if (addr.containsKey('street') && addr.get('street') != null) {
                    addressComponents.add((String) addr.get('street'));
                }

                if (addr.containsKey('city') && addr.get('city') != null) {
                    addressComponents.add((String) addr.get('city'));
                }

                if (addr.containsKey('state') && addr.get('state') != null) {
                    addressComponents.add((String) addr.get('state'));
                }

                if (addr.containsKey('country') && addr.get('country') != null) {
                    addressComponents.add((String) addr.get('country'));
                }

                if (addr.containsKey('postalCode') && addr.get('postalCode') != null) {
                    addressComponents.add((String) addr.get('postalCode'));
                }

                // change later for user formatting?
                label = String.join(addressComponents, ', ');
            }
        }

        return String.valueOf(label);
    }

    public static Map<String, Object> convertObjectToMap(Object myObject) {
        return (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(myObject));
    }

    public with sharing class Response {
        public Boolean isSuccess;
        public Map<String, Object> results;
        public String errMsg;

        public Response() {
            this.isSuccess = true;
            this.results = new Map<String, Object>();
        }

        public void addError(String errMsg){
            this.errMsg = errMsg;
            this.isSuccess = false;
        }

        public String getJsonString() {
            return JSON.serialize(this).replaceAll('konect__', '');
        }
    }
}