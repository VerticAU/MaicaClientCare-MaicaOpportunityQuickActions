//SECURED!
public inherited sharing class DMLManager {

    private static Map<SObjectType, List<Id>> objTypeMap = new Map<SObjectType, List<Id>>();
    private static List<SObject> upsertObjsToCreate = new List<SObject>();
    private static List<SObject> upsertObjsToUpdate = new List<SObject>();
    private static Map<SObjectType, Boolean> upsertObjsToCreateExistsByTypeMap = new Map<SObjectType, Boolean>();
    private static Map<SObjectType, Boolean> upsertObjsToUpdateExistsByTypeMap = new Map<SObjectType, Boolean>();

    // Items in the following set must be entered in lower case
    private static Set<String> exceptionValues = new Set<String>{
            'id', 'isdeleted', 'createddate', 'systemmodstamp', 'lastmodifiedbyid', 'createdbyid', 'lastmodifieddate'
    };

    private static Map<Operation, Map<SObjectType, List<String>>> cachedRestrictedFields = new Map<Operation, Map<SObjectType, List<String>>>();

    public enum Operation {
        OP_INSERT, OP_UPDATE, OP_DELETE, OP_UPSERT
    }

    // CRUD/FLS-safe DML operations. These honor the CRUD and FLS permissions of the running user
    public static void insertAsUser(sObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.
        performDMLOperation(new List<sObject>{ // Bulkify Apex False Positive: there is an overridden Bulk method below used by this method.
                obj
        }, Operation.OP_INSERT);
    }
    public static void updateAsUser(sObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.
        performDMLOperation(new List<sObject>{ // Bulkify Apex False Positive: there is an overridden Bulk method below used by this method.
                obj
        }, Operation.OP_UPDATE);
    }
    public static void upsertAsUser(sObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.
        performDMLOperation(new List<sObject>{ // Bulkify Apex False Positive: there is an overridden Bulk method below used by this method.
                obj
        }, Operation.OP_UPSERT);
    }
    public static void deleteAsUser(sObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.
        performDMLOperation(new List<sObject>{ // Bulkify Apex False Positive: there is an overridden Bulk method below used by this method.
                obj
        }, Operation.OP_DELETE);
    }

    public static void insertAsUser(List<SObject> objList) {
        performDMLOperation(objList, Operation.OP_INSERT);
    }
    public static void updateAsUser(List<SObject> objList) {
        performDMLOperation(objList, Operation.OP_UPDATE);
    }
    public static void upsertAsUser(List<SObject> objList) {
        performDMLOperation(objList, Operation.OP_UPSERT);
    }
    public static void deleteAsUser(List<SObject> objList) {
        performDMLOperation(objList, Operation.OP_DELETE);
    }

    // Pass-thru methods to raw DML operations.
    // Use these sparingly, and only with good reason, since the DML operations are not CRUD/FLS safe
    public static void insertAsSystem(sObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.
        insert obj; // CRUD/FLS False Positive: system method should insert with no CRUD check as a system user.
    }
    public static void updateAsSystem(sObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.
        update obj; // CRUD/FLS False Positive: system method should update with no CRUD check as a system user.
    }
    public static void upsertAsSystem(sObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.
        upsert obj; // CRUD/FLS False Positive: system method should upsert with no CRUD check as a system user.
    }
    public static void deleteAsSystem(sObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.
        delete obj; // CRUD/FLS False Positive: system method should delete with no CRUD check as a system user.
    }
    public static void insertAsSystem(List<SObject> objList) {
        insert objList; // CRUD/FLS False Positive: system method should insert with no CRUD check as a system user.
    }
    public static void updateAsSystem(List<SObject> objList) {
        update objList; // CRUD/FLS False Positive: system method should update with no CRUD check as a system user.
    }
    public static void upsertAsSystem(List<SObject> objList) {
        upsert objList; // CRUD/FLS False Positive: system method should upsert with no CRUD check as a system user.
    }
    public static void deleteAsSystem(List<SObject> objList) {
        delete objList; // CRUD/FLS False Positive: system method should delete with no CRUD check as a system user.
    }

    // Custom Exception Classes
    public inherited sharing virtual class DMLManagerException extends Exception {
        public SObjectType objType { get; private set; }
        public Operation op { get; private set; }
    }

    public inherited sharing class CRUDException extends DMLManagerException {
        public CRUDException(SObjectType objType, Operation op) {
            this('Access Denied: ' + op + ' on ' + objType);
            this.objType = objType;
            this.op = op;
        }
    }

    public inherited sharing class FLSException extends DMLManagerException {
        public SObjectField field { get; private set; }
        public FLSException(SObjectType objType, SObjectField field, Operation op) {
            this('Access Denied: ' + op + ' on ' + objType + '.' + field);
            this.objType = objType;
            this.op = op;
            this.field = field;
        }
    }

    private static void performDMLOperation(List<SObject> objList, Operation dmlOperation) {
        upsertObjsToCreate = new List<SObject>();
        upsertObjsToUpdate = new List<SObject>();
        objTypeMap = new Map<SObjectType, List<Id>>();
        upsertObjsToCreateExistsByTypeMap = new Map<SObjectType, Boolean>();
        upsertObjsToUpdateExistsByTypeMap = new Map<SObjectType, Boolean>();

        analyzeDMLCollection(objList, dmlOperation);
        checkCRUDPermission(objTypeMap.keySet(), dmlOperation);

        if (dmlOperation == Operation.OP_INSERT) {
            for (SObject obj : objList) {
                checkCreateAction(obj);
            }
        } else if (dmlOperation == Operation.OP_UPDATE || dmlOperation == Operation.OP_UPSERT) {
            Map<Id, SObject> existingRecords = getExistingRecords(objTypeMap);

            for (SObject obj : objList) {
                SObject existingRecord = existingRecords.get(obj.Id);
                if (obj.Id != null) {
                    checkUpdateAction(obj, existingRecord);
                } else {
                    checkCreateAction(obj);
                }
            }
        }

        // If no errors have been thrown to this point, execute the dml operation.
        if (dmlOperation == Operation.OP_INSERT) {
            insert objList;
        } else if (dmlOperation == Operation.OP_UPDATE) {
            update objList;
        } else if (dmlOperation == Operation.OP_UPSERT) {
            if (upsertObjsToCreate.size() > 0) {
                insert upsertObjsToCreate;
            }
            if (upsertObjsToUpdate.size() > 0) {
                update upsertObjsToUpdate;
            }
        } else if (dmlOperation == Operation.OP_DELETE) {
            delete objList;
        }
    }

    private static Map<String, Object> getFieldMapFromExistingSObject(SObject obj) {
        // Get actual fields present in object.  The getPopulatedFieldsAsMap method removes implicit nulls.
        return obj.getPopulatedFieldsAsMap();
    }

    private static void checkCreateAction(SObject obj) {
        List<String> restrictedFields = cachedRestrictedFields.get(Operation.OP_INSERT).get(obj.getSObjectType());
        //Save ourselves a trip through the loop below if there are no restricted fields
        if (restrictedFields == null || restrictedFields.isEmpty()) {
            return;
        }

        Map<String, Object> fieldsMap = getFieldMapFromExistingSObject(obj);

        // If any restricted fields are present, throw an exception
        for (String fieldName : restrictedFields) {
            if (fieldsMap.get(fieldName) != null) { // if any of the restricted fields are present in the candidate, throw an exception
                throw new FLSException(obj.getSObjectType(), obj.getSObjectType().getDescribe().fields.getMap().get(fieldName), Operation.OP_INSERT);
            }
        }
    }

    private static void checkUpdateAction(SObject obj, SObject existingRecord) {
        List<String> restrictedFields = cachedRestrictedFields.get(Operation.OP_UPDATE).get(obj.getSObjectType());
        //Save ourselves a trip through the loop below if there are no restricted fields
        if (restrictedFields == null || restrictedFields.isEmpty()) {
            return;
        }

        if (existingRecord == null) {
            throw new DMLManagerException('DMLManager ERROR:  An existing record could not be found for object with Id = ' + obj.Id);
        }

        Map<String, Object> fieldsMap = getFieldMapFromExistingSObject(obj);

        // If any of the restricted values are present and have changed in the dml candidate object, throw an exception
        for (String fieldName : restrictedFields) {
            if (fieldsMap.get(fieldName) != null && fieldsMap.get(fieldName) != existingRecord.get(fieldName)) {
                throw new FLSException(obj.getSObjectType(), obj.getSObjectType().getDescribe().fields.getMap().get(fieldName), Operation.OP_UPDATE);
            }
        }
    }


    // For update and upsert operations, retrieve a Map of all existing records, for each object that has an ID.
    // objects without an Id are skipped, because there is no existing record in the database.
    private static Map<Id, SObject> getExistingRecords(Map<SObjectType, List<Id>> objTypeMap) {
        Map<ID, SObject> result = new Map<Id, SObject>();

        Map<SObjectType, List<String>> operationRestrictedFields = cachedRestrictedFields.get(Operation.OP_UPDATE);
        operationRestrictedFields = operationRestrictedFields != null ? operationRestrictedFields : new Map<SObjectType, List<String>>();

        for (SObjectType objType : objTypeMap.keySet()) {
            List<String> restrictedFields = operationRestrictedFields.get(objType);

            if (restrictedFields == null || restrictedFields.isEmpty()) {
                continue;
            }

            List<Id> seenIds = objTypeMap.get(objType);
            if (seenIds.isEmpty()) {
                continue;
            }

            String fieldList = String.join(restrictedFields, ',');
            //?
            result.putAll((Database.query('SELECT ' + fieldList + ' FROM ' + objType.getDescribe().getName() + ' WHERE Id IN :seenIds')));
        }

        return result;
    }

    private static void checkCRUDPermission(Set<SObjectType> objTypeList, Operation dmlOperation) {
        for (SObjectType objType : objTypeList) {
            DescribeSObjectResult describeObject = objType.getDescribe();
            if ((dmlOperation == Operation.OP_INSERT && !describeObject.isCreateable()) ||
                    (dmlOperation == Operation.OP_UPDATE && !describeObject.isUpdateable()) ||
                    (dmlOperation == Operation.OP_DELETE && !describeObject.isDeletable()) ||
                    (dmlOperation == Operation.OP_UPSERT && (
                            (upsertObjsToCreateExistsByTypeMap.get(objType) == true && !describeObject.isCreateable())
                            || (upsertObjsToUpdateExistsByTypeMap.get(objType) == true && !describeObject.isUpdateable())
                    ))
            ) {
                throw new CRUDException(objType, dmlOperation);
            }
        }
    }

    // Get a Map of all the object types in the dml request and the list of fields for each
    // that the current user cannot update, based on FLS security settings
    private static void analyzeDMLCollection(List<SObject> objList, Operation dmlOperation) {
        for (SObject obj : objList) {
            ensureRestrictedFieldsEntry(obj, dmlOperation);
            SObjectType objType = obj.getSObjectType();

            List<Id> seenIds = objTypeMap.get(objType);
            if (seenIds == null) {
                seenIds = new List<Id>();
                objTypeMap.put(objType, seenIds);
            }

            if (obj.Id == null) {
                upsertObjsToCreateExistsByTypeMap.put(objType, true);
                upsertObjsToCreate.add(obj);
                continue;
            }

            upsertObjsToUpdateExistsByTypeMap.put(objType, true);
            upsertObjsToUpdate.add(obj);
            seenIds.add(obj.Id);

        }
    }

    private static void ensureRestrictedFieldsEntry(SObject obj, Operation dmlOperation) {
        if (dmlOperation == Operation.OP_UPSERT) {
            ensureRestrictedFields(obj, Operation.OP_INSERT);
            ensureRestrictedFields(obj, Operation.OP_UPDATE);
        } else {
            ensureRestrictedFields(obj, dmlOperation);
        }
    }

    private static void ensureRestrictedFields(SObject obj, Operation dmlOperation) {
        Map<SObjectType, List<String>> operationRestrictedFields = cachedRestrictedFields.get(dmlOperation);
        if (operationRestrictedFields == null) {
            operationRestrictedFields = new Map<SObjectType, List<String>>();
            cachedRestrictedFields.put(dmlOperation, operationRestrictedFields);
        }

        if (!operationRestrictedFields.containsKey(obj.getSObjectType())) {

            DescribeSObjectResult describeObject = obj.getSObjectType().getDescribe();

            Map<String, Schema.SObjectField> objectFields = describeObject.fields.getMap();

            List<String> restrictedFields = new List<String>();

            for (String nm : objectFields.keyset()) {
                if (!exceptionValues.contains(nm.toLowerCase())) {
                    DescribeFieldResult fr = objectFields.get(nm).getDescribe();
                    if ((!fr.isCalculated()) && ((dmlOperation == Operation.OP_INSERT && !fr.isCreateable()) ||
                            (dmlOperation == Operation.OP_UPDATE && !fr.isUpdateable()))
                    ) {
                        restrictedFields.add(fr.getName());
                    }  // there is not an isDeletable method at the field level
                }
            }
            operationRestrictedFields.put(obj.getSObjectType(), restrictedFields);
        }
    }

}