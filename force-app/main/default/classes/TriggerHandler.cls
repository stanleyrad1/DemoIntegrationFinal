public virtual class TriggerHandler {
    private static final Set<String> disabledTriggerHandlerNames = new Set<String>();

    public TriggerHandler() {}

    protected virtual void beforeInsert(List<SObject> newList) {}
    protected virtual void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {}
    protected virtual void beforeDelete(Map<Id, SObject> oldMap) {}
    protected virtual void afterInsert(Map<Id, SObject> newMap) {}
    protected virtual void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {}
    protected virtual void afterDelete(Map<Id, SObject> oldMap) {}
    protected virtual void afterUndelete(Map<Id, SObject> newMap) {}

    public void run() {
        if (disabledTriggerHandlerNames.contains(getTriggerHandlerName())) {
            return;
        }

        switch on Trigger.operationType {
            when BEFORE_INSERT {
                this.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                this.beforeUpdate(Trigger.newMap, Trigger.oldMap);
            }
            when BEFORE_DELETE {
                this.beforeDelete(Trigger.oldMap);
            }
            when AFTER_INSERT {
                this.afterInsert(Trigger.newMap);
            }
            when AFTER_UPDATE {
                this.afterUpdate(Trigger.newMap, Trigger.oldMap);
            }
            when AFTER_DELETE {
                this.afterDelete(Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                this.afterUndelete(Trigger.newMap);
            }
        }
    }

    public Boolean isDisabled() {
        return disabledTriggerHandlerNames.contains(getTriggerHandlerName());
    }

    public Boolean isDisabled(String handlerName) {
        return disabledTriggerHandlerNames.contains(handlerName.toLowerCase());
    }

    public void disable() {
        disabledTriggerHandlerNames.add(getTriggerHandlerName());
    }

    public void disable(String handlerName) {
        disabledTriggerHandlerNames.add(handlerName.toLowerCase());
    }

    public void enable() {
        String handlerName = getTriggerHandlerName();
        if (disabledTriggerHandlerNames.contains(handlerName)) {
            disabledTriggerHandlerNames.remove(handlerName);
        }
    }

    public void enable(String handlerName) {
        handlerName = handlerName.toLowerCase();
        if (disabledTriggerHandlerNames.contains(handlerName)) {
            disabledTriggerHandlerNames.remove(handlerName);
        }
    }

    public static void runHandler(String handlerName) {
        try {
            Type handlerType = Type.forName(handlerName);
            TriggerHandler handler = (TriggerHandler) handlerType.newInstance();
            handler.run();
        } catch(Exception e) {
            System.debug('Exception while running handler: ' + e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }

    public static void runHandler() {
        String sObjectName = '';
        if (Trigger.new != null && !Trigger.new.isEmpty()) {
            sObjectName = Trigger.new[0].getSObjectType().getDescribe().getName();
        } else if(Trigger.old != null && !Trigger.old.isEmpty()) {
            sObjectName = Trigger.old[0].getSObjectType().getDescribe().getName();
        }
        runHandler(sObjectName + 'TriggerHandler');
    }

    private String getTriggerHandlerName() {
        return this.toString().substringBefore(':').toLowerCase();
    }
}
