import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DocumentController extends GetxController {
  final _group = Rxn<Map<String, dynamic>>();
  final bodyController = TextEditingController();
  final titleController = TextEditingController();
  final selectedTemplate = RxString('Custom');

  final htmlBody = RxString(HtmlBody.buildTemplate(
      "Example Title", "", "CurrentUser", "CurrentEmail"));

  set group(Map<String, dynamic> value) => _group.value = value;
  String get groupName => _group.value?['name'] ?? '';
  List<dynamic> get groupMembers => _group.value?['members'] ?? [];

  @override
  void onClose() {
    bodyController.dispose();
    titleController.dispose();
    super.onClose();
  }

  void selectTemplate(String template) {
    selectedTemplate.value = template;

    if (selectedTemplate.value == "GDPR") {
      bodyController.text = HtmlBody.getGDPRTemplate();
      titleController.text = "GDPR Consent Form";
      htmlBody.value = HtmlBody.buildTemplate(
        titleController.text,
        bodyController.text,
        "CurrentUser",
        "CurrentEmail",
      );
    } else {
      bodyController.clear();
      titleController.clear();
      htmlBody.value = HtmlBody.buildTemplate(
        titleController.text,
        bodyController.text,
        "CurrentUser",
        "CurrentEmail",
      );
    }
  }

  void onSubmit() {
    print('Submitting document');
  }

  void updateHtmlBody(text) {
    htmlBody.value = HtmlBody.buildTemplate(
        titleController.text, text, "CurrentUser", "CurrentEmail");
  }

  void updateHtmlTitle(text) {
    htmlBody.value = HtmlBody.buildTemplate(
        text, bodyController.text, "CurrentUser", "CurrentEmail");
  }
}

class HtmlBody {
  static const String prefix = """ <!DOCTYPE html>
    <html>
        <head>
          <meta charset="UTF-8">
        </head>
        <body style="font-family:sans-serif;margin:0;">
        <div style="background-color: #416AFF; padding: 1em; width: 100%; margin-bottom: 2em;">
            <div style="text-align: right; margin-right: 2em;">
                <img src="https://i.imgur.com/VO5nMRp.png" alt="Logo" style="width:150px;">
            </div>
        </div>
        <div style="margin-left:2em;">
            <h3 style="font-family: 'Trebuchet MS', Helvetica, sans-serif; font-size: 1em;
                color: #001D4B;margin-bottom: 0;">WolfieSign Document</h3>
          """;
  static String getSuffix() {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return """
  </div>
  <h4 style="margin-top:1em;margin-bottom:0em;">Signature: <span style="color:white;">**signature_1**/</span></h4>
            <p style="margin-top:0em;margin-bottom:0em;font-size: 0.8em;">Date: $currentDate</p>
        </div>
        </body>
    </html>
  """;
  }

  static String getTitleTemplate(title) {
    return """
    <h1 style="font-family: 'Trebuchet MS', Helvetica, sans-serif;
              margin-top: 0px;
              color: #001D4B;">$title</h1>
              """;
  }

  static String getInfoSigners(
      signeeName, signeeEmail, requesterName, requesterEmail) {
    return """
            <p style="margin-top:0em; font-size: 0.8em; margin-bottom:0em;"> Requested for: $signeeName</p>
            <p style="margin-top:0em; font-size: 0.8em; margin-bottom:0em;">Email: $signeeEmail</p>
            <p style="margin-top:0em; font-size: 0.8em; margin-bottom:0em;">Copy to: $requesterName, $requesterEmail</p></p>
            <div style="color: #001D4B;">
  """;
  }

  static String getGDPRTemplate() {
    return "<div style=\"font-family: Arial, sans-serif; font-size: 14px; line-height: 1.6; color: #333;\">\n  <p>\n    This agreement (hereinafter referred to as the \"Agreement\") is made between \$SIGNER1\$ (hereinafter referred to as the \"Data Subject\") and \$SIGNER2\$ (hereinafter referred to as the \"Data Controller\").\n  </p>\n\n  <p>\n    By signing this Agreement, the Data Subject gives explicit consent to the Data Controller to collect, process, and use their personal information in accordance with the General Data Protection Regulation (GDPR) of the European Union and applicable Romanian laws.\n  </p>\n\n  <p>\n    <strong>1. Purpose of Data Processing:</strong> The Data Subject consents to the processing of their personal data for the purposes explicitly stated by the Data Controller, including but not limited to [specify purposes, e.g., communication, service provision, marketing, etc.].\n  </p>\n\n  <p>\n    <strong>2. Types of Data Collected:</strong> The personal data to be collected and processed includes, but is not limited to, [specify data types, e.g., name, email address, phone number, etc.].\n  </p>\n\n  <p>\n    <strong>3. Data Retention:</strong> The Data Controller shall retain the personal data only for as long as necessary to fulfill the stated purposes or as required by applicable laws and regulations.\n  </p>\n\n  <p>\n    <strong>4. Rights of the Data Subject:</strong> The Data Subject has the following rights under GDPR:\n    <ul>\n      <li>The right to access their personal data and request copies of it.</li>\n      <li>The right to rectification of inaccurate or incomplete data.</li>\n      <li>The right to erasure of their personal data (\"right to be forgotten\"), subject to legal or contractual obligations.</li>\n      <li>The right to restrict processing of their personal data.</li>\n      <li>The right to data portability.</li>\n      <li>The right to object to the processing of their personal data for certain purposes.</li>\n      <li>The right to lodge a complaint with a supervisory authority.</li>\n    </ul>\n  </p>\n\n  <p>\n    <strong>5. Data Security:</strong> The Data Controller agrees to implement appropriate technical and organizational measures to ensure the security and confidentiality of the Data Subject's personal data.\n  </p>\n\n  <p>\n    <strong>6. Withdrawal of Consent:</strong> The Data Subject has the right to withdraw their consent at any time by notifying the Data Controller in writing. Withdrawal of consent does not affect the lawfulness of processing based on consent before its withdrawal.\n  </p>\n\n  <p>\n    <strong>7. Contact Information:</strong> For any inquiries or to exercise their rights, the Data Subject can contact the Data Controller at:\n    <br />\n    [Data Controller's Contact Details: e.g., address, email, phone number]\n  </p>\n\n  <p>\n    By agreeing to this document, the Data Subject acknowledges that they have read, understood, and agree to the terms outlined in this Agreement.\n  </p>\n</div>";
  }

  static String getTravelTemplate() {
    return "";
  }

  static String buildTemplate(
      String title, String content, String requesterName, String requesterEmail,
      {String signeeName =
          """<span style="background-color:#ffff99">Signer Name</span>""",
      String signeeEmail =
          """<span style="background-color:#ffff99">Signer Email</span>"""}) {
    return prefix +
        getTitleTemplate(title) +
        getInfoSigners(signeeName, signeeEmail, requesterName, requesterEmail) +
        content +
        getSuffix();
  }
}
