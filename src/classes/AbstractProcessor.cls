//SECURED!
public inherited sharing abstract class AbstractProcessor {

    public protected Boolean isSecurityBypassed = false;
    public protected Request request;
    public protected Response response = getResponseInstance();

    public abstract Response process(Request request);

    public virtual Response process(Map<String, Object> requestMap){
        return this.process(new Request(requestMap));
    }

    public virtual Type getRequestType() { return Request.class; }

    public virtual Request getRequestInstance(String requestJSON) {
        return new Request(requestJSON);
    }

    public virtual Request getRequestInstance(Map<String, Object> requestMap) {
        return new Request(requestMap);
    }

    public protected virtual Response getResponseInstance() {
        return new Response();
    }
}