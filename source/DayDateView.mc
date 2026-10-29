import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// All coordinates are for the Forerunner 265S's 360 x 360 screen.
class DayDateView extends WatchUi.WatchFace {
    private var _sleeping = false;
    private var _dial;
    private var _dateBitmap;
    private var _dimDateBitmap;
    private var _loadedDay = 0;
    private var _dateResources as Array<ResourceId> = [Rez.Drawables.Date01, Rez.Drawables.Date02, Rez.Drawables.Date03, Rez.Drawables.Date04, Rez.Drawables.Date05, Rez.Drawables.Date06, Rez.Drawables.Date07, Rez.Drawables.Date08, Rez.Drawables.Date09, Rez.Drawables.Date10, Rez.Drawables.Date11, Rez.Drawables.Date12, Rez.Drawables.Date13, Rez.Drawables.Date14, Rez.Drawables.Date15, Rez.Drawables.Date16, Rez.Drawables.Date17, Rez.Drawables.Date18, Rez.Drawables.Date19, Rez.Drawables.Date20, Rez.Drawables.Date21, Rez.Drawables.Date22, Rez.Drawables.Date23, Rez.Drawables.Date24, Rez.Drawables.Date25, Rez.Drawables.Date26, Rez.Drawables.Date27, Rez.Drawables.Date28, Rez.Drawables.Date29, Rez.Drawables.Date30, Rez.Drawables.Date31];
    private var _dimDateResources as Array<ResourceId> = [Rez.Drawables.Dim01, Rez.Drawables.Dim02, Rez.Drawables.Dim03, Rez.Drawables.Dim04, Rez.Drawables.Dim05, Rez.Drawables.Dim06, Rez.Drawables.Dim07, Rez.Drawables.Dim08, Rez.Drawables.Dim09, Rez.Drawables.Dim10, Rez.Drawables.Dim11, Rez.Drawables.Dim12, Rez.Drawables.Dim13, Rez.Drawables.Dim14, Rez.Drawables.Dim15, Rez.Drawables.Dim16, Rez.Drawables.Dim17, Rez.Drawables.Dim18, Rez.Drawables.Dim19, Rez.Drawables.Dim20, Rez.Drawables.Dim21, Rez.Drawables.Dim22, Rez.Drawables.Dim23, Rez.Drawables.Dim24, Rez.Drawables.Dim25, Rez.Drawables.Dim26, Rez.Drawables.Dim27, Rez.Drawables.Dim28, Rez.Drawables.Dim29, Rez.Drawables.Dim30, Rez.Drawables.Dim31];

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _dial = WatchUi.loadResource(Rez.Drawables.Dial);
    }

    function onEnterSleep() {
        _sleeping = true;
        WatchUi.requestUpdate();
    }

    function onExitSleep() {
        _sleeping = false;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        var clock = System.getClockTime();
        var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        if (_loadedDay != date.day) {
            _dateBitmap = WatchUi.loadResource(_dateResources[date.day - 1]);
            _dimDateBitmap = WatchUi.loadResource(_dimDateResources[date.day - 1]);
            _loadedDay = date.day;
        }
        var minute = clock.min + (_sleeping ? 0.0 : clock.sec / 60.0);
        var hourAngle = ((clock.hour % 12) + minute / 60.0) * Math.PI / 6.0;
        var minuteAngle = minute * Math.PI / 30.0;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (_sleeping) {
            drawAlwaysOn(dc, clock.min, hourAngle, minuteAngle);
            return;
        }

        // Clean black AP-inspired artwork; hands and date are drawn live below.
        dc.drawBitmap(0, 0, _dial);

        // Date-wheel artwork avoids device-specific bitmap-font masks.
        dc.drawBitmap(295, 171, _dateBitmap);

        // Polished silver baton hands, matching the simple AP-inspired dial.
        hand(dc, hourAngle, 87, 5, 0x747F82);
        hand(dc, hourAngle, 85, 3, 0xF4F7F5);
        hand(dc, minuteAngle, 124, 4, 0x747F82);
        hand(dc, minuteAngle, 122, 2, 0xF4F7F5);

        var secondAngle = clock.sec * Math.PI / 30.0;
        var tip = point(secondAngle, 131, 180, 180);
        var tail = point(secondAngle, -25, 180, 180);
        dc.setColor(0xEAF2EF, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(tail[0], tail[1], tip[0], tip[1]);
        dc.fillCircle(180, 180, 5);
        dc.setColor(0xEAF2EF, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(180, 180, 3);
    }

    // Clockwise angle, zero at 12 o'clock. Return integer pixel coordinates.
    private function point(angle, radius, cx, cy) as [Number, Number] {
        return [(cx + Math.sin(angle) * radius).toNumber(),
                (cy - Math.cos(angle) * radius).toNumber()];
    }

    private function hand(dc, angle, length, halfWidth, color) {
        var tip = point(angle, length, 180, 180);
        var neck = point(angle, length - 3, 180, 180);
        var base = point(angle, -15, 180, 180);
        var dx = Math.cos(angle) * halfWidth;
        var dy = Math.sin(angle) * halfWidth;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [(tip[0] - dx * 0.65).toNumber(), (tip[1] - dy * 0.65).toNumber()],
            [(tip[0] + dx * 0.65).toNumber(), (tip[1] + dy * 0.65).toNumber()],
            [(neck[0] + dx).toNumber(), (neck[1] + dy).toNumber()],
            [(base[0] + dx * 0.55).toNumber(), (base[1] + dy * 0.55).toNumber()],
            [(base[0] - dx * 0.55).toNumber(), (base[1] - dy * 0.55).toNumber()],
            [(neck[0] - dx).toNumber(), (neck[1] - dy).toNumber()]
        ]);
    }

    private function drawAlwaysOn(dc, minute, hourAngle, minuteAngle) {
        // Thin hands and four small indices keep the display far below 10% lit.
        // A 4-pixel shift changes each minute to spread stationary pixels.
        var offsets = [[-4,-4], [4,4], [-4,4], [4,-4]];
        var shift = offsets[minute % 4];
        var cx = 180 + shift[0];
        var cy = 180 + shift[1];
        dc.setColor(0x858C90, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        for (var i = 0; i < 4; i += 1) {
            var angle = i * Math.PI / 2.0;
            var a = point(angle, 139, cx, cy);
            var b = point(angle, 145, cx, cy);
            dc.drawLine(a[0], a[1], b[0], b[1]);
        }
        var h = point(hourAngle, 89, cx, cy);
        var m = point(minuteAngle, 128, cx, cy);
        dc.drawLine(cx, cy, h[0], h[1]);
        dc.drawLine(cx, cy, m[0], m[1]);
        dc.setPenWidth(1);
        dc.drawBitmap(295 + shift[0], 171 + shift[1], _dimDateBitmap);
    }
}
