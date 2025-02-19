//SECURED!
public inherited sharing class UnitOfWork extends fflib_SObjectUnitOfWork {

    private Map<String, SObject> alreadyRegisteredRecords = new Map<String, SObject>();

    private DoHierarchyWork doHierarchyWork;

    public UnitOfWork(List<SObjectType> types) {
        this(types, new SimpleDML());
    }

    public UnitOfWork(List<SObjectType> types, fflib_SObjectUnitOfWork.IDML dmlImpl) {
        super(types, dmlImpl);

        this.doHierarchyWork = new DoHierarchyWork(this);
    }

    public SObject getRegisteredRecord(SObject record) {
        String recordInJSON = JSON.serialize(record);
        String recordHashCode = System.hashCode(record).format();

        if (this.alreadyRegisteredRecords.containsKey(recordInJSON)) {
            return this.alreadyRegisteredRecords.get(recordInJSON);
        } else if (this.alreadyRegisteredRecords.containsKey(recordHashCode)) {
            return this.alreadyRegisteredRecords.get(recordHashCode);
        }

        return record;
    }

    public Boolean registerUpsert(SObject record) {
        return this.registerUpsert(record, false, null);
    }

    public Boolean registerUpsert(SObject record, Set<SObjectField> preserveFields) {
        return this.registerUpsert(record, false, preserveFields);
    }

    public Boolean registerUpsert(SObject record, Boolean uniqueness) {
        return registerUpsert(record, uniqueness, null);
    }

    public Boolean registerUpsert(SObject record, Boolean uniqueness, Set<SObjectField> preserveFields) {

        if (record.Id == null) {
            if (uniqueness == true) {
                String recordInJSON = JSON.serialize(record);
                String recordHashCode = System.hashCode(record).format();
                if (!this.alreadyRegisteredRecords.containsKey(recordInJSON) && !this.alreadyRegisteredRecords.containsKey(recordHashCode)) {
                    super.registerNew(record);
                    this.alreadyRegisteredRecords.put(recordInJSON, record);
                    this.alreadyRegisteredRecords.put(recordHashCode, record);
                    return true;
                }
            } else {
                super.registerNew(record);
                return true;
            }
        } else {
            if (!this.alreadyRegisteredRecords.containsKey(record.Id)) {
                super.registerDirty(record);
                this.alreadyRegisteredRecords.put(record.Id, record);
                return true;
            }
        }
        return false;
    }

    public void registerUpsert(List<SObject> records, Set<SObjectField> preserveFields) {
        this.registerUpsert(records, false, preserveFields);
    }

    public void registerUpsert(List<SObject> records) {
        this.registerUpsert(records, false, null);
    }

    public void registerUpsert(List<SObject> records, Boolean uniqueness) {
        for (SObject record : records) {
            this.registerUpsert(record, uniqueness, null);
        }
    }

    public void registerUpsert(List<SObject> records, Boolean uniqueness, Set<SObjectField> preserveFields) {
        for (SObject record : records) {
            this.registerUpsert(record, uniqueness, preserveFields);
        }
    }

    public void registerRelationship(List<SObject> records, Schema.sObjectField relatedToField, SObject relatedTo) {
        for (SObject record : records) {
            super.registerRelationship(record, relatedToField, relatedTo);
        }
    }

    public void registerHierarchy(SObject child, SObjectField field, SObject parent) {
        doHierarchyWork.registerRelationship(child, field, parent);
    }

    private class DoHierarchyWork implements fflib_SObjectUnitOfWork.IDoWork {

        public DoHierarchyWork(fflib_ISObjectUnitOfWork uow) {
            uow.registerWork(this);
        }

        private List<HierarchyReference> references = new List<HierarchyReference>();

        public void registerRelationship(SObject child, SObjectField field, SObject parent) {
            this.registerRelationship(new HierarchyReference(child, field, parent));
        }

        public void registerRelationship(HierarchyReference parentChildReference) {
            this.references.add(parentChildReference);
        }

        public void doWork() {

            Map<SObjectType, List<SObject>> recordsToUpdateMap = new Map<SObjectType, List<SObject>>();

            for (HierarchyReference referenceVar : references) {

                referenceVar.child.put(referenceVar.field, referenceVar.parent.Id);

                List<SObject> records = recordsToUpdateMap.get(referenceVar.child.getSObjectType());
                if (records == null) {
                    records = new List<SObject>();
                    recordsToUpdateMap.put(referenceVar.child.getSObjectType(), records);
                }

                if (new Map<Id, SObject>(records).containsKey(referenceVar.child.Id) == false) {
                    records.add(referenceVar.child);
                }

            }

            for (SObjectType sObjectTypeVar : recordsToUpdateMap.keySet()) {
                update recordsToUpdateMap.get(sObjectTypeVar);
            }

        }

    }

    private class HierarchyReference {
        public SObject child;
        public SObjectField field;
        public SObject parent;

        public HierarchyReference(SObject child, SObjectField field, SObject parent) {
            this.child = child;
            this.field = field;
            this.parent = parent;
        }
    }
}