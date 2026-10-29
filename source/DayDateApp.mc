import Toybox.Application;
import Toybox.WatchUi;

class DayDateApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [new DayDateView()];
    }
}
