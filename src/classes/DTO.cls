//SECURED!
public inherited sharing virtual class DTO implements Structs.IMappable {
    public Map<String, Object> dto = new Map<String, Object>();

    public DTO() {}

    public DTO(String requestJSON) {
        this.dto = (Map<String, Object>) JSON.deserializeUntyped(requestJSON);
    }

    public DTO(Map<String, Object> requestMap) {
        this.dto = requestMap == null ? this.dto : requestMap;
    }

    public Map<String, Object> getMap() {
        return this.dto;
    }

    public virtual Map<String, Object> getMap(String path) {
        return (Map<String, Object>) this.get(path);
    }

    public Object get(String path) {
        return Utils.arrays.getMapValue(this.dto, path);
    }

    public Object get(String path, Type objType) {
        Object value = this.get(path);
        return JSON.deserialize(JSON.serialize(value), objType);
    }

    public String getId(String path) {
        return (Id) Utils.arrays.getMapValue(this.dto, path);
    }

    public String getString(String path) {
        Object val = Utils.arrays.getMapValue(this.dto, path);
        return val == null ? null : String.valueOf(val);
    }

    public String getRequiredString(String path) {
        return this.getRequiredString(path, 'The following parameter is missing in the request: ' + path);
    }

    public String getRequiredString(String path, String errorMessage) {
        String val = this.getString(path);
        Utils.objects.throwIfBlank(val, errorMessage);
        return val;
    }

    public Integer getInteger(String path) {
        Object val = Utils.arrays.getMapValue(this.dto, path);
        return val == null ? null : Integer.valueOf(val);
    }

    public Long getLong(String path) {
        Object val = Utils.arrays.getMapValue(this.dto, path);
        if(val == null){
            return null;
        }
        if(val instanceof String){
            return Long.valueOf((String)val);
        }
        return (Long)val;
    }

    public Decimal getDecimal(String path) {
        return Utils.objects.parseDecimal(Utils.arrays.getMapValue(this.dto, path));
    }

    public Boolean getBoolean(String path) {
        Object val = Utils.arrays.getMapValue(this.dto, path);
        if(val == null){
            return null;
        }
        if(val instanceof Boolean){
            return (Boolean)val;
        }
        return Boolean.valueOf(val);
    }

    public Date getISODate(String path) {
        String dateStr = this.getString(path);
        return String.isBlank(dateStr) ? null : Date.valueOf(dateStr);
    }

    public Time getTime(String path) {
        String timeStr = this.getString(path);
        if(String.isBlank(timeStr)){
            return null;
        }
        String[] strTimeSplit = timeStr.split(':');
        Time timeVar = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
            ,Integer.valueOf(strTimeSplit[1]) //min
            ,Integer.valueOf(strTimeSplit[2].split('\\.')[0]) //sec
            ,Integer.valueOf(strTimeSplit[2].split('\\.')[1].removeEnd('Z')));
        return timeVar;
    }

    public List<Object> getList(String path) {
        return (List<Object>) Utils.arrays.getMapValue(this.dto, path);
    }

    public List<String> getListAsStrings(String path) {
        List<String> strings = new List<String>();

        List<Object> objects = (List<Object>) Utils.arrays.getMapValue(this.dto, path);

        if(objects == null){
            return null;
        }

        for (Object obj : objects) {
            strings.add(obj == null ? null : obj.toString());
        }

        return strings;
    }

    public List<Map<String, Object>> getListAsMap(String path) {
        List<Map<String, Object>> returnList = new List<Map<String, Object>>();

        List<Object> objects = getList(path);
        if (objects == null) {
            return null;
        }

        for (Object obj : objects) {
            returnList.add((Map<String, Object>) obj);
        }

        return returnList;
    }

    public List<DTO> getListAsDTO(String path) {
        List<Map<String, Object>> maps = getListAsMap(path);

        if(maps == null){
            return null;
        }

        List<DTO> returnList = new List<DTO>();

        for (Map<String, Object> mapVar : maps) {
            returnList.add(new DTO(mapVar));
        }

        return returnList;
    }

    public List<DTO> getListAsDTONonNull(String path) {
        List<DTO> returnList = getListAsDTO(path);

        if(returnList == null){
            return new List<DTO>();
        }

        return returnList;
    }

    public Boolean has(String path) {
        return Utils.arrays.mapContains(this.dto, path);
    }

    public DTO put(String path, Object value) {
        Utils.arrays.setMapValue(this.dto, path, value);

        return this;
    }

    public AutoMapper getMapper(){
        return new AutoMapper(this);
    }
}