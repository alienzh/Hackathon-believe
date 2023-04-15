package io.agora.hack.believe.ai.model;

import java.io.Serializable;

public class CtrlB implements Serializable {

    private String ctrl_id;
    private String ctrl_name;

    //-----------------------------------------------------------

    public String getCtrl_id() {
        return ctrl_id;
    }

    public void setCtrl_id(String ctrl_id) {
        this.ctrl_id = ctrl_id;
    }

    public String getCtrl_name() {
        return ctrl_name;
    }

    public void setCtrl_name(String ctrl_name) {
        this.ctrl_name = ctrl_name;
    }
}
