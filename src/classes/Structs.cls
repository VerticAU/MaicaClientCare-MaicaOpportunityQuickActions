//SECURED!
public inherited sharing class Structs {
    /**
     * ==============================================================================================================
     *                                             COMMON STRUCTURES
     * ==============================================================================================================
     */

    public inherited sharing virtual class SelectOption{

        public Object value;
        public String label;

        public SelectOption() {}

        public SelectOption(Object value, String label) {
            this.value = value;
            this.label = label;
        }

        public SelectOption(String value) {
            this(value, value);
        }
    }

    public inherited sharing virtual class ErrorDetails {
        public String message {get; set;}

        public ErrorDetails(String message) {
            this.message = message;
        }
    }

    public inherited sharing class ExceptionDetails extends ErrorDetails {
        public Integer lineNumber {get; set;}
        public String stackTraceString {get; set;}
        public String typeName {get; set;}

        public ExceptionDetails(Exception ex) {
            super(ex.getMessage());
            this.lineNumber = ex.getLineNumber();
            this.stackTraceString = ex.getStackTraceString();
            this.typeName = ex.getTypeName();
        }
    }

    public abstract class Expression {
        public String source;
        public List<String> params = new List<String>();

        public Expression(String source) {
            this.source = source;
            this.parseSource();
        }

        public protected abstract void parseSource();
        public protected abstract String getValue(DTO dtoVar);

        public virtual String apply(DTO dtoVar, String targetStr) {
            String expressionStrToReplace = ('{!' + this.source + '}');
            String escapedExpressionStrToReplace = expressionStrToReplace.replaceAll('\\p{Punct}', '\\\\$0');
            return targetStr.replaceAll(escapedExpressionStrToReplace, this.getValue(dtoVar));
        }
    }

    public inherited sharing virtual class MergeFieldExpression extends Expression {

        public MergeFieldExpression(String source) {
            super(source);
        }

        public protected override void parseSource() {
            this.params.add(this.source);
        }

        public protected override String getValue(DTO dtoVar) {
            String path = this.params.get(0);
            String value = Utils.objects.defaultIfNull(dtoVar.getString(path), '');
            return value;
        }

    }

    /**
     * ==============================================================================================================
     *                                             INTERFACES
     * ==============================================================================================================
     */

    public interface IMappable {
        Map<String, Object> getMap();
    }

    public interface ISchedulable {
        void start();
        void stop();
    }

    public interface ISerializable {
        String serialize();
    }

    public abstract class Serializable implements ISerializable {

        public virtual String serialize() {
            return JSON.serialize(this);
        }
        public String getJSON() {
            return this.serialize();
        }

    }

    /**
     * ==============================================================================================================
     *                                             EXCEPTIONS
     * ==============================================================================================================
     */

    public inherited sharing class CommonException extends Exception {}
    public inherited sharing class MissingDataException extends Exception {}
    public inherited sharing class UtilsException extends Exception {}
    public inherited sharing class InvalidDataException extends Exception {}
    public inherited sharing class NotFoundException extends Exception {}
    public inherited sharing class ValidationException extends Exception {}
    public inherited sharing class InitException extends Exception {}
    public inherited sharing class ProcessException extends Exception {}
    public with sharing class AccessException extends Exception {}
}