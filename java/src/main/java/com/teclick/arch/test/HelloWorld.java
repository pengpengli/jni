package com.teclick.arch.test;

import java.util.Map;
import java.util.Properties;
import java.util.TimeZone;
import java.util.concurrent.TimeUnit;

/**
 * Created by pengli on 2017-12-26 11:43.
 */
public class HelloWorld {

    private static final String LINE_EOF = "\r\n";

    public static String showContext(String data) {

        StringBuilder result = new StringBuilder();
        result.append("Received param value: ").append(data).append(LINE_EOF).append(LINE_EOF);

        result.append(LINE_EOF).append("[####  System properties  ####]").append(LINE_EOF);
        Properties properties = System.getProperties();
        for (Map.Entry<Object, Object> entry : properties.entrySet()) {
            result.append("[SYS] ");
            result.append(entry.getKey().toString()).append("=").append(entry.getValue().toString()).append(LINE_EOF);
        }

        result.append(LINE_EOF);

        result.append(LINE_EOF).append("[####  System evenment  ####]").append(LINE_EOF);
        Map<String, String> envMap = System.getenv();
        for (Map.Entry entry : envMap.entrySet()) {
            result.append("[ENV] ");
            result.append(entry.getKey()).append("=").append(entry.getValue()).append(LINE_EOF);
        }

        return result.toString();
    }

    public static String displayTimeZones() {
        StringBuilder result = new StringBuilder();
        result.append(LINE_EOF).append("[####  System timezone  ####]").append(LINE_EOF);
        String[] ids = TimeZone.getAvailableIDs();
        for (String id : ids) {
            TimeZone tz = TimeZone.getTimeZone(id);
            long hours = TimeUnit.MILLISECONDS.toHours(tz.getRawOffset());
            long minutes = TimeUnit.MILLISECONDS.toMinutes(tz.getRawOffset()) - TimeUnit.HOURS.toMinutes(hours);

            minutes = Math.abs(minutes);
            if (hours > 0L) {
                result.append(String.format("(GMT+%d:%02d) %s", hours, minutes, tz.getID()));
            }
            result.append(String.format("(GMT%d:%02d) %s", hours, minutes, tz.getID()));
        }
        return result.toString();
    }

    public static void main(String[] args) {
        System.out.println("Hello world !");
    }

}
