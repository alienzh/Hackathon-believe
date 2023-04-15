package io.agora.hack.believe.ai.model;

import java.io.Serializable;
import java.util.List;

public class AvatarCtrlB implements Serializable {

    private String title;

    private List<AvatarB> avatar_list;    //列表

    private int currentSelect = 0;  //当前选择
    //-----------------------------------------------------------

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public List<AvatarB> getAvatar_list() {
        return avatar_list;
    }

    public void setAvatar_list(List<AvatarB> avatar_list) {
        this.avatar_list = avatar_list;
    }

    public int getCurrentSelect() {
        return currentSelect;
    }

    public AvatarB getCurrentSelectItem() {
        if (avatar_list == null) {
            return null;
        }
        return avatar_list.get(currentSelect);
    }

    public void setCurrentSelect(int currentSelect) {
        this.currentSelect = currentSelect;
    }
}
