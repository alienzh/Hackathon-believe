package io.agora.hack.believe.ai.model;

import java.io.Serializable;
import java.util.List;

public class AvatarB implements Serializable {

    private String avatar_name;

    private String avatar_id;

    private List<CtrlB> ctrl_list;    //动作列表

    private int currentSelect = 0;  //当前选择
    //-----------------------------------------------------------
    public CtrlB getCurrentSelectItem() {
        if (ctrl_list == null) {
            return null;
        }
        return ctrl_list.get(currentSelect);
    }

    public int getCurrentSelect() {
        return currentSelect;
    }

    public void setCurrentSelect(int currentSelect) {
        this.currentSelect = currentSelect;
    }

    public String getAvatar_name() {
        return avatar_name;
    }

    public void setAvatar_name(String avatar_name) {
        this.avatar_name = avatar_name;
    }

    public String getAvatar_id() {//avatar_id
        return avatar_id;
    }

    public void setAvatar_id(String avatar_id) {
        this.avatar_id = avatar_id;
    }

    public List<CtrlB> getCtrl_list() {
        return ctrl_list;
    }

    public void setCtrl_list(List<CtrlB> ctrl_list) {
        this.ctrl_list = ctrl_list;
    }
}
