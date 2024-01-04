import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';

class VisitesRecord extends FirestoreRecord {
  VisitesRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "time" field.
  String? _time;
  String get time => _time ?? '';
  bool hasTime() => _time != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _time = snapshotData['time'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('visites');

  static Stream<VisitesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VisitesRecord.fromSnapshot(s));

  static Future<VisitesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VisitesRecord.fromSnapshot(s));

  static VisitesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      VisitesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VisitesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VisitesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VisitesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VisitesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVisitesRecordData({
  String? name,
  String? time,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'time': time,
    }.withoutNulls,
  );

  return firestoreData;
}

class VisitesRecordDocumentEquality implements Equality<VisitesRecord> {
  const VisitesRecordDocumentEquality();

  @override
  bool equals(VisitesRecord? e1, VisitesRecord? e2) {
    return e1?.name == e2?.name && e1?.time == e2?.time;
  }

  @override
  int hash(VisitesRecord? e) => const ListEquality().hash([e?.name, e?.time]);

  @override
  bool isValidKey(Object? o) => o is VisitesRecord;
}
