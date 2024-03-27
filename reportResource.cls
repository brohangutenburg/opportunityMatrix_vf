// This is a class named reportResource with the "public with sharing" access modifier.
public with sharing class reportResource {
    
    // This is an inner class named resultMatrix.
    class resultMatrix {
        // These are public properties of the resultMatrix class.
        public String workgroupSet { get; set; }
        public String stagenameSet { get; set; }
        public Decimal Amount { get; set; } // Change data type to Decimal

        // This is a constructor for the resultMatrix class that takes an AggregateResult as a parameter.
        public resultMatrix(AggregateResult ar) {
            // Assign the 'Work_Group__c' field value from the AggregateResult to the workgroupSet property.
            workgroupSet = (String) ar.get('Work_Group__c');
            // Assign the 'StageName' field value from the AggregateResult to the stagenameSet property.
            stagenameSet = (String) ar.get('StageName');
            // Assign the 'expr0' field value from the AggregateResult to the Amount property.
            // Cast the value to Decimal data type.
            Amount = (Decimal) ar.get('expr0');
        }
    }
    
    // This is a constructor for the reportResource class.
    public reportResource() {
        // Call the createCrossTabData method.
        createCrossTabData();
    }

    // This method retrieves the Opportunity matrix data and returns a list of resultMatrix objects.
    public List<resultMatrix> getOpportunityMatrix() {
        // Create an empty list to store the resultMatrix objects.
        List<resultMatrix> oppToStore = new List<resultMatrix>();
        
        // Perform an SOQL query to retrieve aggregated data from the Opportunity object.
        // Group the data by 'Work_Group__c' and 'StageName' fields and calculate the sum of 'Amount' field.
        for (AggregateResult result : [
            SELECT Work_Group__c, StageName, SUM(Amount)
            FROM Opportunity
            WHERE Work_Group__c IN ('Medical', 'Safety', 'Inspection', 'Professional Services') 
            GROUP BY Work_Group__c, StageName
        ]) {
            // Create a new resultMatrix object using the AggregateResult and add it to the oppToStore list.
            resultMatrix objResultMatrix = new resultMatrix(result); 
            oppToStore.add(objResultMatrix);
        }
        
        // Return the list of resultMatrix objects.
        return oppToStore;
    }

    // These are public properties of the reportResource class.
    public List<String> runListW { get; set; }
    public List<String> runListS { get; set; }
    public Map<String, Decimal> counts { get; set; }
    public Map<String, Decimal> workgroupTotals { get; set; }
    public Map<String, Decimal> stageTotals { get; set; }
    public Decimal total { get; set; }

    // This method creates the cross-tabulated data for the Opportunity matrix.
    public void createCrossTabData() {
        // Create sets to store unique values of workgroup and stagename.
        Set<String> workgroupSet = new Set<String>();
        Set<String> stagenameSet = new Set<String>();
        
        // Create maps to store counts, workgroup totals, stage totals, and the overall total.
        counts = new Map<String, Decimal>();
        workgroupTotals = new Map<String, Decimal>();
        stageTotals = new Map<String, Decimal>();
        total = 0;
        
        // Create lists to store sorted workgroup and stagename values.
        runListW = new List<String>();
        runListS = new List<String>();

        // Iterate over the resultMatrix objects returned by the getOpportunityMatrix method.
        for (resultMatrix oppObject : getOpportunityMatrix()) {
            // Add the workgroup and stagename values to the respective sets.
            workgroupSet.add(oppObject.workgroupSet);
            stagenameSet.add(oppObject.stagenameSet);
            
            // Create a key by concatenating workgroup and stagename values.
            String key = oppObject.workgroupSet + '-' + oppObject.stagenameSet;
            
            // Get the count value from the counts map using the key.
            Decimal c = counts.get(key);
            
            // If the count value is null, initialize it to 0.
            if (c == null) {
                c = 0;
            }
            
            // If the Amount property of the resultMatrix object is not null, update the count value.
            if (oppObject.Amount != null) {
                c += oppObject.Amount;
                counts.put(key, c);
                
                // Calculate the workgroup total and update the workgroupTotals map.
                Decimal workgroupTotal = workgroupTotals.get(oppObject.workgroupSet);
                if (workgroupTotal == null) {
                    workgroupTotal = 0;
                }
                workgroupTotal += oppObject.Amount;
                workgroupTotals.put(oppObject.workgroupSet, workgroupTotal);

                // Calculate the stage total and update the stageTotals map.
                Decimal stageTotal = stageTotals.get(oppObject.stagenameSet);
                if (stageTotal == null) {
                    stageTotal = 0;
                }
                stageTotal += oppObject.Amount;
                stageTotals.put(oppObject.stagenameSet, stageTotal);

                // Update the overall total.
                total += oppObject.Amount;
            }
        }

        // Convert the workgroupSet and stagenameSet sets to lists and assign them to the runListW and runListS properties.
        runListW = new List<String>(workgroupSet);
        runListS = new List<String>(stagenameSet);
        
        // Sort the runListW and runListS lists.
        runListW.sort();
        runListS.sort();
    }
}