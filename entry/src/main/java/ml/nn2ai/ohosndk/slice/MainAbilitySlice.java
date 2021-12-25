package ml.nn2ai.ohosndk.slice;

import ohos.aafwk.ability.AbilitySlice;
import ohos.aafwk.content.Intent;
import ohos.agp.components.PositionLayout;
import ohos.agp.components.Text;
import ohos.agp.utils.Color;
import ohos.agp.colors.RgbColor;
import ohos.agp.components.element.ShapeElement;
import ohos.agp.components.ComponentContainer.LayoutConfig;

public class MainAbilitySlice extends AbilitySlice {
    // Load the 'native-lib' library on application startup.
    static {
        // System.loadLibrary("hello");
        System.loadLibrary("rust");
    }

    private final PositionLayout myLayout = new PositionLayout(this);

    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        LayoutConfig config = new LayoutConfig(LayoutConfig.MATCH_PARENT, LayoutConfig.MATCH_PARENT);
        myLayout.setLayoutConfig(config);
        ShapeElement element = new ShapeElement();
        element.setShape(ShapeElement.RECTANGLE);
        element.setRgbColor(new RgbColor(255, 255, 255));
        myLayout.setBackground(element);
        Text text = new Text(this);
        text.setText(stringFromRust());
        text.setTextColor(Color.RED);
        myLayout.addComponent(text);
        super.setUIContent(myLayout);
    }

    @Override
    public void onActive() {
        super.onActive();
    }

    @Override
    public void onForeground(Intent intent) {
        super.onForeground(intent);
    }

    /**
     * A native method that is implemented by the 'native-lib' native library,
     * which is packaged with this application.
     */
    // public native String stringFromJNI();
    public native String stringFromRust();
}
