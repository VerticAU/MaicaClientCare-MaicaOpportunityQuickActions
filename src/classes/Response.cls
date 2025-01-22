//SECURED!
public inherited sharing virtual class Response extends DTO {

    public Boolean isValid = true;
    public Structs.ErrorDetails error;
    public List<Structs.ErrorDetails> errors = new List<Structs.ErrorDetails>();

    public Response() {}

    public Response(Map<String, Object> requestMap) {
        super(requestMap);
    }

    public Response(Exception ex) {
        this();

        this.isValid = (ex == null);

        if (ex != null) {
            this.error = new Structs.ExceptionDetails(ex);
            this.errors.add(this.error);
        }
    }

    public Response(List<Exception> exs) {
        this(exs == null || exs.isEmpty() ? null : exs.get(0));

        this.errors = new List<Structs.ErrorDetails>();
        for (Exception ex : exs) {
            this.errors.add(new Structs.ExceptionDetails(ex));
        }
    }

    public Response(List<String> messages) {
        this(String.join(messages, ', '));

        this.errors = new List<Structs.ErrorDetails>();
        for (String message : messages) {
            this.errors.add(new Structs.ErrorDetails(message));
        }
    }

    public Response(String message) {
        this();

        this.setError(message);
    }

    public void setError(String message) {
        this.isValid = (String.isBlank(message));

        if (String.isNotBlank(message)) {
            this.error = new Structs.ErrorDetails(message);
            this.errors.add(this.error);
        }
    }

    public String getJSON() {
        return JSON.serialize(this);
    }

}