//SECURED!
public inherited sharing virtual class Request extends DTO {

    public Request() {}

    public Request(Map<String, Object> requestMap) {
        super(requestMap);
    }

    public Request(String requestJSON) {
        super(requestJSON);
    }

    public String getJSON() {
        return JSON.serialize(this);
    }

}