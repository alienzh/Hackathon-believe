package io.agora.hack.believe.ai.model;

public class InputData {

    private String text;
    private String ctrl_w;

    //-----------------------------------------------------------

    public String getCtrl_w() {
        return ctrl_w;
    }

    public void setCtrl_w(String ctrl_w) {
        this.ctrl_w = ctrl_w;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    @Override
    public String toString() {
        return "InputData{" +
                "text='" + text + '\'' +
                ", ctrl_w='" + ctrl_w + '\'' +
                '}';
    }
}
