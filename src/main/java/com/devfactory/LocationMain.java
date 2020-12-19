package com.devfactory;

import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;

public class LocationMain {

    private static class Location {
        int time;
        String name;
        int x;
        int y;
        boolean exposure;
        boolean logged;
        Set<Location> exposured = new HashSet<>();
    }

    private static class Exposure {
        int time;
        String name;
    }

    public static void main(String[] args) throws IOException {
            List<Location> locations = new ArrayList<>();
            Map<Integer, List<Location>> timeLocations = new HashMap<>();
            List<Exposure> exposures = new ArrayList<>();
            FileOutputStream fileOutputStream = new FileOutputStream("output.csv");
            int maxTime = 0;

            List<String> locationLines = Files.readAllLines(Paths.get(args.length > 0 ? args[0] : "locations.csv"));
            for (String locationLine : locationLines) {
                String[] split = locationLine.split(",");
                if (split.length >= 4) {
                    Location location = new Location();
                    location.time = Integer.parseInt(split[0]);
                    location.name = split[1];
                    location.x = Integer.parseInt(split[2]);
                    location.y = Integer.parseInt(split[3]);
                    locations.add(location);

                    maxTime = Math.max(maxTime, location.time);

                    List<Location> locationsArr = timeLocations.get(location.time);
                    if (locationsArr == null) {
                        locationsArr = new ArrayList<>();
                        timeLocations.put(location.time, locationsArr);
                    }
                    locationsArr.add(location);
                }
            }

            List<String> exposuresLines = Files.readAllLines(Paths.get(args.length > 0 ? args[0] : "exposure.csv"));
            for (String exposuresLine : exposuresLines) {
                String[] split = exposuresLine.split(",");
                if (split.length >= 2) {
                    Exposure location = new Exposure();
                    location.time = Integer.parseInt(split[0]);
                    location.name = split[1];
                    exposures.add(location);
                }
            }

        for (Location location : locations) {
            for (Exposure exposure : exposures) {
                if (exposure.name.equals(location.name)) {
                    location.exposure = true;
                    fileOutputStream.write((location.x + "," + location.y + "," + location.name + "\n").getBytes());
                }
            }
        }

        for (int i = 1; i <= maxTime; i++) {
            List<Location> locationsArr = timeLocations.get(i);
            for (int j = 0; j < locationsArr.size(); j++) {
                Location location1 = locationsArr.get(j);
                for (int k = 0; k < locationsArr.size(); k++) {
                    Location location2 = locationsArr.get(k);
                    if (location1.exposure && !location1.equals(location2) && Math.abs(location1.x - location2.x) <= 1 && Math.abs(location1.y - location2.y) <= 1) {
                        if (location1.exposured.contains(location2)) {
                            if (!location2.logged) {
                                fileOutputStream.write((location2.x + "," + location2.y + "," + location2.name + "\n").getBytes());
                                location2.logged = true;
                            }
                            location2.exposure = true;
                        } else {
                            location1.exposured.add(location2);
                        }
                    }
                }
            }
        }

        List<Location> locationsArr = timeLocations.get(maxTime);
        for (int j = 0; j < locationsArr.size(); j++) {
            Location location1 = locationsArr.get(j);
            for (int k = 0; k < locationsArr.size(); k++) {
                Location location2 = locationsArr.get(k);
                if (location1.exposure && !location1.equals(location2) && Math.abs(location1.x - location2.x) <= 1 && Math.abs(location1.y - location2.y) <= 1) {
                    if (location1.exposured.contains(location2)) {
                        if (!location2.logged) {
                            fileOutputStream.write((location2.x + "," + location2.y + "," + location2.name + "\n").getBytes());
                            location2.logged = true;
                        }
                        location2.exposure = true;
                    } else {
                        location1.exposured.add(location2);
                    }
                }
            }
        }

        fileOutputStream.flush();
        fileOutputStream.close();
    }

}
