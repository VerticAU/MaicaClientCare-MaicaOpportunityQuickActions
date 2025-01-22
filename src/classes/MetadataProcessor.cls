//SECURED!
public inherited sharing abstract class MetadataProcessor extends AbstractProcessor {

    public protected MetadataProcessor.MetadataRequest request;
    public protected MetadataProcessor.MetadataResponse response;

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public virtual override Response process(Request request) {
        this.request = (MetadataProcessor.MetadataRequest) request;
        this.response = (MetadataProcessor.MetadataResponse) super.response;

        this.p_initSelectOptions();

        return this.response;
    }

    public virtual override Response process(Map<String, Object> requestMap){
        return this.process(new MetadataProcessor.MetadataRequest(requestMap));
    }

    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void p_initSelectOptions() {
        if (this.request.fields != null && !this.request.fields.isEmpty()) {
            this.response.selectOptions = Utils.picklists.getPicklistOptionsMap(this.request.fields);
        }

        if (this.request.dependentFieldsBySObjectType != null && !this.request.dependentFieldsBySObjectType.isEmpty()) {
            this.response.dependentOptions = Utils.picklists.getDependentPicklistOptionsMap(this.request.dependentFieldsBySObjectType);
        }

        if (this.request.sObjectTypes != null && !this.request.sObjectTypes.isEmpty()) {
            this.response.sObjects = Utils.sObjects.getSObjectDescribe(this.request.sObjectTypes);
        }
    }


    /**
     * ==============================================================================================================
     *                                          STRUCTURES AND OVERRIDES
     * ==============================================================================================================
     */

    public inherited sharing virtual class MetadataRequest extends Request {
        public Set<SObjectField> fields = new Set<SObjectField>();
        public Map<SObjectType, Map<SObjectField, SObjectField>> dependentFieldsBySObjectType = new Map<SObjectType, Map<SObjectField, SObjectField>>();
        public List<SObjectType> sObjectTypes = new List<SObjectType>();

        public MetadataRequest() {}

        public MetadataRequest(String requestJSON) {
            super(requestJSON);
        }

        public MetadataRequest(Map<String, Object> requestMap) {
            super(requestMap);
        }

        public MetadataRequest(Set<SObjectField> fields) {
            this.fields = fields;
        }

        public MetadataRequest(Set<SObjectField> fields, Map<SObjectType, Map<SObjectField, SObjectField>> dependentFieldsBySObjectType) {
            this(fields);
            this.dependentFieldsBySObjectType = dependentFieldsBySObjectType;
        }
    }

    public inherited sharing virtual class MetadataResponse extends Response {
        public Map<String, List<Structs.SelectOption>> selectOptions = new Map<String, List<Structs.SelectOption>>();
        public Map<String, Map<String, List<Structs.SelectOption>>> dependentOptions = new Map<String, Map<String, List<Structs.SelectOption>>>();
        public Map<String, Object> sObjects = new Map<String, Object>();

        public void addSelectOption(String key, Structs.SelectOption selectOption, Integer index) {
            Utils.arrays.addToListOrCreateNew(
                this.selectOptions,
                List<Structs.SelectOption>.class,
                key,
                selectOption,
                index
            );
        }

        public void addSelectOption(String key, Structs.SelectOption selectOption) {
            this.addSelectOption(key, selectOption, null);
        }

        public void addSelectOptions(String key, List<Structs.SelectOption> selectOptions, Integer index) {
            for (Structs.SelectOption selectOption : selectOptions) {
                this.addSelectOption(key, selectOption, index);
            }
        }

        public void addSelectOptions(String key, List<Structs.SelectOption> selectOptions) {
            this.addSelectOptions(key, selectOptions, null);
        }

        public Boolean removeDependentOption(String picklistOptionsName, String parentOptionValue, String dependentOptionValueToRemove){
            Map<String, List<Structs.SelectOption>> optionsMap = this.dependentOptions.get(picklistOptionsName);
            if(optionsMap != null){
                List<Structs.SelectOption> dependentOptions = optionsMap.get(parentOptionValue);
                if(dependentOptions != null){
                    for (Integer index = 0; index < dependentOptions.size(); index++) {
                        Structs.SelectOption selectOptionVar = dependentOptions.get(index);
                        if(selectOptionVar.value == dependentOptionValueToRemove){
                            dependentOptions.remove(index);
                            return true;
                        }
                    }
                }
            }
            return false;
        }
    }

    public virtual override Type getRequestType() {
        return MetadataRequest.class;
    }

    public override Request getRequestInstance(String requestJSON) {
        return new MetadataRequest(requestJSON);
    }


    public protected virtual override Response getResponseInstance() {
        return new MetadataResponse();
    }

}