class TrainingModelResponse {
  String? message;
  List<TrainingModel>? data;

  TrainingModelResponse({this.message, this.data});

  TrainingModelResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <TrainingModel>[];
      json['data'].forEach((v) {
        data!.add(new TrainingModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TrainingModel {
  int? id;
  String? title;
  String? description;
  String? fileType;
  String? fileName;
  int? isActive;
  int? inOrder;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? formattedDate;
  String? photo;

  TrainingModel(
      {this.id,
        this.title,
        this.description,
        this.fileType,
        this.fileName,
        this.isActive,
        this.inOrder,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.formattedDate,
        this.photo});

  TrainingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    fileType = json['file_type'];
    fileName = json['file_name'];
    isActive = json['is_active'];
    inOrder = json['in_order'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    formattedDate = json['formatted_date'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['file_type'] = this.fileType;
    data['file_name'] = this.fileName;
    data['is_active'] = this.isActive;
    data['in_order'] = this.inOrder;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['formatted_date'] = this.formattedDate;
    data['photo'] = this.photo;
    return data;
  }
}