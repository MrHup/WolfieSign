class EnvelopeModel {
  final String envelopeId;
  final String senderEmail;
  final String senderName;
  final String status;
  final DateTime statusChangedDateTime;
  final String groupId;
  final String docTitle;

  EnvelopeModel({
    required this.envelopeId,
    required this.senderEmail,
    required this.senderName,
    required this.status,
    required this.statusChangedDateTime,
    required this.groupId,
    required this.docTitle,
  });

  factory EnvelopeModel.fromJson(Map<String, dynamic> json) {
    return EnvelopeModel(
      envelopeId: json['envelope_id'],
      senderEmail: json['sender_email'],
      senderName: json['sender_name'],
      status: json['status'],
      statusChangedDateTime: DateTime.parse(json['status_changed_date_time']),
      groupId: json['group_id'],
      docTitle: json['doc_title'],
    );
  }
}
