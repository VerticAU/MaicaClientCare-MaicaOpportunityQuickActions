//SECURED!
public with sharing class SOQLDataTableMetaProc extends MetadataProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override Response process(Request request) {
        this.request = request == null ? new MetadataRequest() : (MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
            // SObject Fields, e.g. Contact.Salutation
        };

        super.process(this.request);

        this.init();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private SObjectType sObjectTypeVar;
    private Map<String, SObjectField> fieldMap;
    private List<String> fields;

    private Set<String> fieldsToRetrieve = new Set<String>();
    private List<Map<String, Object>> tableColumns = new List<Map<String, Object>>();
    private Set<String> referenceFieldPathList = new Set<String>();
    private Map<String, String> urlOverrideFormatMap = new Map<String, String>();

    private void init() {

        String sObjectTypeStr = this.request.getString('sObjectType');
        Utils.objects.throwIfBlank(sObjectTypeStr, 'No SObjectType');

        this.sObjectTypeVar = Schema.getGlobalDescribe().get(sObjectTypeStr.toLowerCase());
        Utils.objects.throwIfNull(this.sObjectTypeVar, 'No SObjectType with API Name: ' + sObjectTypeStr);

        this.fieldMap = this.sObjectTypeVar.getDescribe().fields.getMap();

        this.fields = getFields();

        this.buildColumnsAndFieldsToRetrieve();

        Integer limitRecords = this.request.getInteger('limit');
        String condition = this.request.getString('condition');
        Map<String, Object> params = (Map<String, Object>) this.request.get('params');
        List<Map<String, Object>> orderBy = this.request.getListAsMap('orderBy');

        List<SObject> tableData = getSObjectData(
            condition,
            params,
            limitRecords != null ? limitRecords + 1 : limitRecords,
            orderBy
        );

        Map<String, Object> tableCache = new Map<String, Object>();
        new AutoMapper(tableCache).mapFromListSObjects(
            'tableData',
            tableData,
            new AutoMapper.BinderQueue(new UrlBinder(this.referenceFieldPathList, this.urlOverrideFormatMap)).addBinder(new KeysToLowerCaseBinder()),
            limitRecords != null ? limitRecords : 50000
        );

        tableCache.put('tableColumns', this.tableColumns);

        this.response.dto.putAll(tableCache);
        this.response.dto.put('timestamp', this.request.getString('timestamp'));
    }

    private List<String> getFields(){
        List<String> fields = Utils.objects.defaultIfNull(this.request.getString('fields'), 'Id').split(',');
        List<String> result = new List<String>();
        for (String fieldPath : fields) {
            fieldPath = fieldPath.trim();
            String format = fieldPath.substringAfter('(');
            result.add(fieldPath.substringBefore('(').toLowerCase() + (String.isNotBlank(format) ? '(' + format : ''));
        }
        return result;
    }


    /**
     * ==============================================================================================================
     *                                         STRUCTURES AND OVERRIDES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties:
    // meta_request
    // meta_response

    // tableRequest
    public static final String ID_SET_KEY = 'idSet';


    // lightning:datatable type translation map
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_enum_Schema_DisplayType.htm
    // https://developer.salesforce.com/docs/component-library/bundle/lightning:datatable/documentation
    public static final Map<Schema.DisplayType, String> DISPLAY_TYPE_TO_DATATABLE_TYPE_MAP = new Map<Schema.DisplayType, String>{
        Schema.DisplayType.address => 'text',
        Schema.DisplayType.anytype => 'text',
        Schema.DisplayType.base64 => 'text',
        Schema.DisplayType.Boolean => 'boolean',
        Schema.DisplayType.Combobox => 'text',
        Schema.DisplayType.Currency => 'currency',
        Schema.DisplayType.Date => 'date',
        Schema.DisplayType.DateTime => 'date',
        Schema.DisplayType.Double => 'number',
        Schema.DisplayType.Email => 'email',
        Schema.DisplayType.Integer => 'number',
        Schema.DisplayType.MultiPicklist => 'text',
        Schema.DisplayType.Percent => 'percent',
        Schema.DisplayType.Phone => 'phone',
        Schema.DisplayType.Picklist => 'text',
        Schema.DisplayType.String => 'text',
        Schema.DisplayType.TextArea => 'text',
        Schema.DisplayType.Time => 'date',
        Schema.DisplayType.URL => 'url'
    };

    private void buildColumnsAndFieldsToRetrieve() {

        for (String fieldPath : this.fields) {
            String nameIdFieldPath = 'name';
            String urlFormat = '';
            if (fieldPath.contains(':')) {
                urlFormat = fieldPath.substringAfter('(').substringBefore(')');
                nameIdFieldPath = fieldPath.substringAfter(':').substringBefore('(');
                fieldPath = fieldPath.substringBefore(':');
            }
            fieldPath = fieldPath.toLowerCase();
            nameIdFieldPath = nameIdFieldPath.toLowerCase();

            if (String.isNotBlank(urlFormat)) {
                this.urlOverrideFormatMap.put(fieldPath, urlFormat);
            }
            this.fieldsToRetrieve.add(fieldPath);

            ParseFieldPathResult parseFieldPathResult = parseFieldPath(this.sObjectTypeVar, fieldPath);
            DescribeFieldResult fieldDescribeVar = parseFieldPathResult.fieldVar.getDescribe();

            Map<String, Object> fieldColumn = new Map<String, Object>();
            fieldColumn.put('sortable', true);

            if (fieldDescribeVar.getType() == Schema.DisplayType.ID) {

                fieldColumn.put('fieldName', fieldPath + '-url');
                fieldColumn.put('label', fieldMap.get(nameIdFieldPath).getDescribe().getLabel());
                fieldColumn.put('type', 'url');
                fieldColumn.put('typeAttributes', new Map<String, Object>{
                    'label' => new Map<String, Object>{
                        'fieldName' => nameIdFieldPath
                    },
                    'tooltip' => new Map<String, Object>{
                        'fieldName' => nameIdFieldPath
                    }
                });

                this.fieldsToRetrieve.add(nameIdFieldPath);
                this.referenceFieldPathList.add(fieldPath);

            } else if (fieldDescribeVar.getType() == Schema.DisplayType.REFERENCE) {

                String nameFieldPath = this.getFieldNameForReference(fieldPath, nameIdFieldPath);
                nameFieldPath = nameFieldPath.toLowerCase();
                this.fieldsToRetrieve.add(nameFieldPath);

                fieldColumn.put('fieldName', fieldPath + '-url');
//                fieldColumn.put('label', parseFieldPathResult.sObjectTypeVar.getDescribe().fields.getMap().get('name').getDescribe().getLabel());
                fieldColumn.put('label', fieldDescribeVar.getLabel());
                fieldColumn.put('type', 'url');
                fieldColumn.put('typeAttributes', new Map<String, Object>{
                    'label' => new Map<String, Object>{
                        'fieldName' => nameFieldPath
                    },
                    'tooltip' => new Map<String, Object>{
                        'fieldName' => nameFieldPath
                    }
                });
                this.referenceFieldPathList.add(fieldPath);

            } else {

                fieldColumn.put('fieldName', fieldPath);
                fieldColumn.put('type', DISPLAY_TYPE_TO_DATATABLE_TYPE_MAP.get(fieldDescribeVar.getType()));
                fieldColumn.put('label', fieldDescribeVar.getLabel());

            }

            this.tableColumns.add(fieldColumn);

        }
    }

    private String getFieldNameForReference(String fieldPath, String nameIdFieldPath) {
        if (fieldPath.endsWithIgnoreCase('id')) {
            return fieldPath.removeEnd('id') + '.' + nameIdFieldPath;
        } else if (fieldPath.endsWithIgnoreCase('__c')) {
            return fieldPath.removeEnd('__c') + '__r.'+ nameIdFieldPath;
        } else {
            throw new Structs.InvalidDataException('Not reference path: ' + fieldPath);
        }
    }

    private List<SObject> getSObjectData(String condition, Map<String, Object> params, Integer limits, List<Map<String, Object>> orderBy) {
        Set<Id> idSet = new Set<Id>();

        fflib_QueryFactory queryFactory = new fflib_QueryFactory(sObjectTypeVar);

        queryFactory.selectFields(this.fieldsToRetrieve);
        queryFactory.setCondition(condition);

        if (limits != null) {
            queryFactory.setLimit(limits);
        }

        if (orderBy != null) {
            for (Map<String, Object> field: orderBy) {
                String fieldName = String.valueOf(field.get('field'));
                if (String.isEmpty(fieldName)) {
                    throw new Structs.InvalidDataException('No field name for ORDER BY');
                }

                String orderParam = String.valueOf(field.get('order')).toUpperCase();
                if (!orderParam.equals('ASC') && !orderParam.equals('DESC')) {
                    throw new Structs.InvalidDataException('Invalid parameter for ORDER BY: ' + orderParam);
                }

                String nullLastString = String.valueOf(field.get('nulls')).toUpperCase();
                if (!nullLastString.equals('NULLS FIRST') && !nullLastString.equals('NULLS LAST')) {
                    throw new Structs.InvalidDataException('Invalid parameter for ORDER BY: ' + nullLastString);
                }
                Boolean isNullLast  = nullLastString.equals('NULLS LAST') ? true : false;

                queryFactory.addOrdering(
                    fieldName,
                    orderParam.equals('ASC') ? fflib_QueryFactory.SortOrder.ASCENDING : fflib_QueryFactory.SortOrder.DESCENDING,
                    isNullLast
                );
            }
        }

        if (params != null && params.get(ID_SET_KEY) != null) {
            List<String> idList = (List<String>) JSON.deserialize(JSON.serialize(params.get(ID_SET_KEY)), List<String>.class);
            for (String sObjectId : idList) {
                idSet.add(sObjectId.trim());
            }
        }

        return Database.query(queryFactory.toSOQL());
    }

    public class UrlBinder extends AutoMapper.AbstractBinder {

        private Set<String> referenceFieldPathList;
        private Map<String, String> urlOverrideFormatMap;

        UrlBinder(Set<String> referenceFieldPathList, Map<String, String> urlOverrideFormatMap) {
            this.referenceFieldPathList = referenceFieldPathList;
            this.urlOverrideFormatMap = urlOverrideFormatMap;
        }

        public void bind(SObject record, Map<String, Object> dataMap) {
            for (String fieldPath : this.referenceFieldPathList) {
                Object recordId = Utils.sObjects.getValueByPath(record, fieldPath);
                if (recordId != null) {
                    String urlFormat = '/' + recordId;
                    if (this.urlOverrideFormatMap.containsKey(fieldPath)) {
                        urlFormat = String.format(this.urlOverrideFormatMap.get(fieldPath), new List<Object> {recordId});
                    }
                    dataMap.put(fieldPath + '-url', urlFormat);
                }
            }
        }
    }

    public class KeysToLowerCaseBinder extends AutoMapper.AbstractBinder {

        public void bind(SObject record, Map<String, Object> dataMap) {
            for (String key : dataMap.keySet()) {

                Object val = dataMap.get(key);
                dataMap.remove(key);
                dataMap.put(key.toLowerCase(), val);

                if(val instanceof Map<String, Object>){
                    bind(record, (Map<String, Object>)val);
                }

            }
        }

    }

    public inherited sharing class ParseFieldPathResult {
        public SObjectType sObjectTypeVar;
        public SObjectField fieldVar;
    }
    public static ParseFieldPathResult parseFieldPath(SObjectType sObjectTypeVar, String path) {

        ParseFieldPathResult result = new ParseFieldPathResult();

        path = path.toLowerCase();
        List<String> pathItems = path.split('\\.');

        result.sObjectTypeVar = sObjectTypeVar;
        while (pathItems.size() > 1) {
            String pathItem = pathItems.remove(0);

            if (pathItem.endsWith('__r')) {
                pathItem = pathItem.replaceAll('__r', '__c');
            } else {
                pathItem += 'id';
            }

            SObjectField fieldVar = result.sObjectTypeVar.getDescribe().fields.getMap().get(pathItem);
            result.sObjectTypeVar = fieldVar.getDescribe().getReferenceTo().get(0);
        }

        String fieldName = pathItems.remove(0);
        result.fieldVar = result.sObjectTypeVar.getDescribe().fields.getMap().get(fieldName);

        return result;
    }
}