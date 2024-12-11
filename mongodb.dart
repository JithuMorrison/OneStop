import 'package:mongo_dart/mongo_dart.dart';
import 'package:onestop/announcementmodel.dart';
import 'package:onestop/studentmodel.dart';
import 'calendareventsmodel.dart';
import 'dbhelper.dart';
import 'mongodbmodel.dart';

class MongoDatabase {
  static var db, userCollection,announcements,attendance,cgpa,calendarevent;
  static connect() async {
    db = await Db.create(MONGO_CONN_URL);
    await db.open();
    userCollection = db.collection(USER_COLLECTION);
    announcements = db.collection(ANNOUNCEMENTS);
    attendance = db.collection(ATTENDANCE);
    cgpa = db.collection(CGPA);
    calendarevent = db.collection(CALENDAREVENT);
    if(db.isConnected){
      print("Successfully connected");
    }
  }

  static Future<String> insertannouncement(AnnouncementModel data) async {
    try {
      var result = await announcements.insertOne(data.toJson());
      if (result.isSuccess) {
        return "Data Inserted Successfully";
      } else {
        return "Data Insertion Failed";
      }
    } catch (e) {
      print("Error during insertion: $e");
      return e.toString();
    }
  }

  static Future<String> insertclass(StudentModel data) async {
    try {
      var result = await attendance.insertOne(data.toJson());
      if (result.isSuccess) {
        return "Data Inserted Successfully";
      } else {
        return "Data Insertion Failed";
      }
    } catch (e) {
      print("Error during insertion: $e");
      return e.toString();
    }
  }

  static Future<String> insertCalendarEvent(CalendarEventModel data) async {
    try {
      var result = await calendarevent.insertOne(data.toJson());
      if (result.isSuccess) {
        return "Data Inserted Successfully";
      } else {
        return "Data Insertion Failed";
      }
    } catch (e) {
      print("Error during insertion: $e");
      return e.toString();
    }
  }

  static Future<String> insert(MongoDbModel data) async {
    try {
      var result = await userCollection.insertOne(data.toJson());
      if (result.isSuccess) {
        return "Data Inserted Successfully";
      } else {
        return "Data Insertion Failed";
      }
    } catch (e) {
      print("Error during insertion: $e");
      return e.toString();
    }
  }

  /// Update an existing document
  static Future<String> update(MongoDbModel data) async {
    try {
      var filter = where.eq('_id', data.id);
      var updateOperation = modify
          .set('username', data.username)
          .set('name', data.name)
          .set('email', data.email)
          .set('phone_number', data.phoneNumber)
          .set('role', data.role)
          .set('dob', data.dob)
          .set('dept',data.dept)
          .set('section',data.section)
          .set('year',data.year)
          .set('credit', data.credit)
          .set('events', data.events.map((event) => event.toJson()).toList());

      var result = await userCollection.update(filter, updateOperation);
      if (result['nModified'] > 0) {
        return "Data Updated Successfully";
      } else {
        return "No Data Updated";
      }
    } catch (e) {
      print("Error during update: $e");
      return e.toString();
    }
  }

  static Future<String> updateCalendarEvent(CalendarEventModel data) async {
    try {
      // Define the filter to find the document by its ObjectId
      var filter = where.eq('_id', data.id);

      // Create the update operation
      var updateOperation = modify
          .set('type', data.type)
          .set('events', data.events.map((event) => event.toJson()).toList());

      // Perform the update
      var result = await calendarevent.update(filter, updateOperation);

      // Check the result of the update
      if (result['nModified'] > 0) {
        return "Calendar Event Updated Successfully";
      } else {
        return "No Calendar Event Updated";
      }
    } catch (e) {
      print("Error during update: $e");
      return e.toString();
    }
  }

  /// Delete a document
  static Future<String> delete(ObjectId id) async {
    try {
      var result = await userCollection.remove(where.eq('_id', id));
      if (result['n'] > 0) {
        return "Data Deleted Successfully";
      } else {
        return "No Data Found to Delete";
      }
    } catch (e) {
      print("Error during deletion: $e");
      return e.toString();
    }
  }

  /// Fetch all documents
  static Future<List<MongoDbModel>> getData() async {
    try {
      final data = await userCollection.find().toList();
      return data.map((json) => MongoDbModel.fromJson(json)).toList();
    } catch (e) {
      print("Error during data retrieval: $e");
      return [];
    }
  }
}
