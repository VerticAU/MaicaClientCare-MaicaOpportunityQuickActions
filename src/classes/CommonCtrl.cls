//SECURED!
global inherited sharing virtual class CommonCtrl {

    public static Response process(String processor, String requestJSON) {

        Savepoint savepoint;

        try {
            AbstractProcessor processorVar = ProcessorFactory.getInstance(processor);
            Request requestVar = processorVar.getRequestInstance(requestJSON);

            Boolean doesPerformCallout = processorVar instanceof Database.AllowsCallouts;

            if (doesPerformCallout != true) {
                savepoint = Database.setSavepoint();
            }

            return processorVar.process(requestVar);
        } catch (Exception ex) {
            if (savepoint != null) {
                Database.rollback(savepoint);
            }
            throw ex;
        }
    }

    @AuraEnabled
    global static String execute(String processor, String requestJSON) {

        try {
            Response responseVar = CommonCtrl.process(processor, requestJSON);
            return JSON.serialize(responseVar);
        } catch (Structs.ValidationException ex) {
            return new Response(ex).getJSON();
        } catch (Exception ex) {
            return new Response(ex).getJSON();
        }
    }

    @RemoteAction
    global static String execute(String requestJSON) {
        try {
            Map<String, Object> request = (Map<String, Object>) JSON.deserializeUntyped(requestJSON);

            if (request.containsKey('processor') && request.containsKey('dto')) {
                return execute((String) request.get('processor'), JSON.serialize(request.get('dto')));
            }

            return new Response('Invalid request attributes.').getJSON();
        } catch (Exception ex) {
            return new Response(ex).getJSON();
        } finally {
        }
    }

}