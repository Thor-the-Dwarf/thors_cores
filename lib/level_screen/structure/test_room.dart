import 'package:flutter/cupertino.dart';
import 'package:neon_thors_cores/level_screen/structure/Level.dart';

class Room extends ChangeNotifier {
  bool isLoaded = false;
  late final List<Level> topLevel;

  Room({required List<String> topLevelIds}) {
    topLevel = [];
    for (String level_id in topLevelIds)
      topLevel.add(Level(level_pk: level_id));
  }
}


List<String> topLevelIds = [
  "a5803cd8-fcbc-4f5d-91fb-6e1a3b98abe8",
  "d60e6025-f483-4663-80b7-2e6e1e8e70d7",
  "3a41d52e-5661-4b83-8e7f-3cfc7f03e1c9",
  "ed5cb471-e891-4768-86c7-123d9d0832c0",
  "c08583af-357b-44e5-9173-4a1e1d3f9d7d",
  "8b368d3a-5621-4002-bb86-f90b261ca24f",
  "4be28fd3-e75d-4d76-8426-b5c1965f6723",
  "6aa87540-6608-4b2f-b52b-c039d7573f6e",
  "e521cc51-07c3-40dc-bd76-88fe77135c9e",
  "5707c54e-fd44-4c28-a55b-50106a8fcf37",
  "ff8d3dcb-d2d6-44de-a350-763d5c611a04",
  "f268ece9-555a-4e84-a01d-bb1bb34b50f9",
  "05f9165c-67ce-4ccd-aefa-de0f4d8e3ebd",
  "20c6adcd-977e-4c9c-9466-7eaff2c775f0",
  "d0181fe8-4397-4acb-89d3-92be98327696"
];
