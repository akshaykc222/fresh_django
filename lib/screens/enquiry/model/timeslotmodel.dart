
class Timeslots {
  int id;
  String slot;
  int? count;
  Timeslots({required this.id, required this.slot, this.count});

  factory Timeslots.fromJson(Map<String, dynamic> json) =>Timeslots(id:  json['id'], slot:  json['slot'], count: json['count']);


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['id'] = id;
    data['slot'] = slot;
    return data;
  }
}