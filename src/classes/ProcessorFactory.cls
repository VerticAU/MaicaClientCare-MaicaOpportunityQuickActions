//SECURED!
public inherited sharing class ProcessorFactory {

    public static AbstractProcessor getInstance(String processorName) {
        return getInstance(processorName, 'No Processor Type with Name: ' + processorName);
    }

    public static AbstractProcessor getInstance(String processorName, String errorMessage) {
        Type processorType = Type.forName(processorName);

        if (processorType == null) {
            throw new Structs.CommonException(errorMessage);
        }

        AbstractProcessor processorVar = (AbstractProcessor) processorType.newInstance();

        if (processorVar == null) {
            throw new Structs.CommonException('Unable to create Processor instance of type name: ' + processorName);
        }

        return processorVar;
    }

}