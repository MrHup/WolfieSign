import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:wolfie_sign/data/services/envelope_service.dart';
import 'package:wolfie_sign/data/services/openai_service.dart';
import 'package:wolfie_sign/ui/document/modify_document_modal.dart';
import 'package:wolfie_sign/ui/home/home_controller.dart';
import 'package:wolfie_sign/ui/profile/profile_controller.dart';
import 'package:wolfie_sign/utils/app_colors.dart';

class DocumentController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _envelopeService = EnvelopeService();
  final _group = Rxn<Map<String, dynamic>>();
  final bodyController = TextEditingController();
  final titleController = TextEditingController();
  final promptController = TextEditingController();
  final selectedTemplate = RxString('Custom');
  final _profileController = Get.find<ProfileController>();
  final _openAIService = OpenAIService();
  final isSubmitting = false.obs;

  final htmlBody = RxString('');

  set group(Map<String, dynamic> value) {
    _group.value = value;
    selectedTemplate.value = "Custom";
    _initializeHtmlBody();
  }

  String get groupName => _group.value?['name'] ?? '';
  List<dynamic> get groupMembers => _group.value?['members'] ?? [];

  @override
  void onClose() {
    bodyController.dispose();
    titleController.dispose();
    promptController.dispose();
    super.onClose();
  }

  void _initializeHtmlBody() {
    updateHtmlBody(HtmlBody.buildTemplate(
      "Example Title",
      "",
      _profileController.userName.value,
      _profileController.userEmail.value,
    ));
  }

  void showModifyDocumentModal() {
    promptController.clear();
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          color: AppColors.backdropColor,
          child: ModifyDocumentModal(
            promptController: promptController,
            onSubmit: () => _handleModifyDocument(),
            onCancel: () => Get.back(),
          ),
        ),
      ),
      barrierColor: Colors.transparent,
    );
  }

  void _handleModifyDocument() async {
    if (promptController.text.isEmpty) return;

    Get.context!.loaderOverlay.show();

    final newContent = await _openAIService.generateDocumentContent(
      promptController.text,
      bodyController.text,
    );

    if (newContent != null) {
      bodyController.text = newContent;
      updateHtmlBody(newContent);
    }

    Get.back();
    Get.context!.loaderOverlay.hide();
  }

  void selectTemplate(String template) {
    selectedTemplate.value = template;

    if (selectedTemplate.value == "GDPR") {
      bodyController.text = HtmlBody.getGDPRTemplate();
      titleController.text = "GDPR Consent Form";
      updateHtmlBody(HtmlBody.buildTemplate(
        titleController.text,
        bodyController.text,
        _profileController.userName.value,
        _profileController.userEmail.value,
      ));
    } else if (selectedTemplate.value == "Travel") {
      bodyController.text = HtmlBody.getTravelTemplate();
      titleController.text = "Travel Agreement";
      updateHtmlBody(HtmlBody.buildTemplate(
        titleController.text,
        bodyController.text,
        _profileController.userName.value,
        _profileController.userEmail.value,
      ));
    } else {
      bodyController.clear();
      titleController.text = "Example Title";

      updateHtmlBody(HtmlBody.buildTemplate(
        titleController.text,
        bodyController.text,
        _profileController.userName.value,
        _profileController.userEmail.value,
      ));
    }
  }

  Future<void> onSubmit() async {
    Get.context!.loaderOverlay.show();
    isSubmitting.value = true;

    final signers = groupMembers
        .map((member) => {
              'signer_name': member['name'],
              'signer_email': member['email'],
            })
        .toList();

    final envelopeIds = await _envelopeService.createEnvelopes(
      content: HtmlBody.buildTemplate(
        titleController.text,
        bodyController.text,
        _profileController.userName.value,
        _profileController.userEmail.value,
        signeeEmail: "\$SIGNER_EMAIL\$",
        signeeName: "\$SIGNER\$",
      ),
      ccEmail: _profileController.userEmail.value,
      ccName: _profileController.userName.value,
      title: titleController.text,
      signers: signers,
    );

    if (envelopeIds != null) {
      await _addEnvelopesToFirestore(envelopeIds, signers);
      Get.find<HomeController>().navigateTo(1); // Navigate to inner home page
    }

    isSubmitting.value = false;
    Get.context!.loaderOverlay.hide();
  }

  Future<void> _addEnvelopesToFirestore(
      List<dynamic> envelopeIds, List<Map<String, dynamic>> signers) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final docRef = _firestore.collection('documents').doc(userId);
    final currentTime = DateTime.now().toIso8601String();

    final newEnvelopes = List.generate(
      envelopeIds.length,
      (index) => {
        'envelope_id': envelopeIds[index],
        'sender_email': signers[index]['signer_email'],
        'sender_name': signers[index]['signer_name'],
        'status': 'sent',
        'status_changed_date_time': currentTime,
        'group_id': _group.value?['id'],
        'doc_title': titleController.text,
      },
    );

    final doc = await docRef.get();
    List<dynamic> existingEnvelopes = [];
    if (doc.exists) {
      existingEnvelopes = List.from(doc.data()?['envelopes'] ?? []);
    }

    await docRef.set({
      'envelopes': [...newEnvelopes, ...existingEnvelopes],
    }, SetOptions(merge: true));
  }

  String preprocessText(String text) {
    // Replace all occurrences of "SENDER" with the user's name
    // Replace all occurences of "SENDER_EMAIL" with the user's email
    // Replace all occurences of "SIGNER" with HTML element
    // Replace all occurences of "SIGNER_EMAIL" with HTML element
    text = text.replaceAll("\$SENDER\$", _profileController.userName.value);
    text =
        text.replaceAll("\$SENDER_EMAIL\$", _profileController.userEmail.value);
    text = text.replaceAll("\$SIGNER\$",
        """<span style="background-color:#ffff99">Signer Name</span>""");
    text = text.replaceAll("\$SIGNER_EMAIL\$",
        """<span style="background-color:#ffff99">Signer Email</span>""");
    return text;
  }

  void updateHtmlBody(String text) {
    text = preprocessText(text);
    htmlBody.value = text;
  }

  void updateRealTimeHtmlBody(String text) {
    updateHtmlBody(htmlBody.value = HtmlBody.buildTemplate(
      titleController.text,
      text,
      _profileController.userName.value,
      _profileController.userEmail.value,
    ));
  }

  void updateHtmlTitle(String text) {
    htmlBody.value = HtmlBody.buildTemplate(
      text,
      bodyController.text,
      _profileController.userName.value,
      _profileController.userEmail.value,
    );
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
            <p style="margin-top:0em; font-size: 0.8em; margin-bottom:0em;"> Requested for: $signeeName, $signeeEmail</p>
            <p style="margin-top:0em; font-size: 0.8em; margin-bottom:0em;">Requested by: $requesterName, $requesterEmail</p></p>
            <div style="color: #001D4B;">
  """;
  }

  static String getGDPRTemplate() {
    return "<div style=\"font-family: Arial, sans-serif; font-size: 14px; line-height: 1.6; color: #333;\">\n  <p>\n    This agreement (hereinafter referred to as the \"Agreement\") is made between \$SIGNER\$ (hereinafter referred to as the \"Data Subject\") and \$SENDER\$ (hereinafter referred to as the \"Data Controller\").\n  </p>\n\n  <p>\n    By signing this Agreement, the Data Subject gives explicit consent to the Data Controller to collect, process, and use their personal information in accordance with the General Data Protection Regulation (GDPR) of the European Union and applicable Romanian laws.\n  </p>\n\n  <p>\n    <strong>1. Purpose of Data Processing:</strong> The Data Subject consents to the processing of their personal data for the purposes explicitly stated by the Data Controller, including but not limited to [specify purposes, e.g., communication, service provision, marketing, etc.].\n  </p>\n\n  <p>\n    <strong>2. Types of Data Collected:</strong> The personal data to be collected and processed includes, but is not limited to, [specify data types, e.g., name, email address, phone number, etc.].\n  </p>\n\n  <p>\n    <strong>3. Data Retention:</strong> The Data Controller shall retain the personal data only for as long as necessary to fulfill the stated purposes or as required by applicable laws and regulations.\n  </p>\n\n  <p>\n    <strong>4. Rights of the Data Subject:</strong> The Data Subject has the following rights under GDPR:\n    <ul>\n      <li>The right to access their personal data and request copies of it.</li>\n      <li>The right to rectification of inaccurate or incomplete data.</li>\n      <li>The right to erasure of their personal data (\"right to be forgotten\"), subject to legal or contractual obligations.</li>\n      <li>The right to restrict processing of their personal data.</li>\n      <li>The right to data portability.</li>\n      <li>The right to object to the processing of their personal data for certain purposes.</li>\n      <li>The right to lodge a complaint with a supervisory authority.</li>\n    </ul>\n  </p>\n\n  <p>\n    <strong>5. Data Security:</strong> The Data Controller agrees to implement appropriate technical and organizational measures to ensure the security and confidentiality of the Data Subject's personal data.\n  </p>\n\n  <p>\n    <strong>6. Withdrawal of Consent:</strong> The Data Subject has the right to withdraw their consent at any time by notifying the Data Controller in writing. Withdrawal of consent does not affect the lawfulness of processing based on consent before its withdrawal.\n  </p>\n\n  <p>\n    <strong>7. Contact Information:</strong> For any inquiries or to exercise their rights, the Data Subject can contact the Data Controller at:\n    <br />\n    \$SENDER_EMAIL\$ \n  </p>\n\n  <p>\n    By agreeing to this document, the Data Subject acknowledges that they have read, understood, and agree to the terms outlined in this Agreement.\n  </p>\n</div>";
  }

  static String getTravelTemplate() {
    return "<div style=\"font-family: Arial, sans-serif; font-size: 14px; line-height: 1.6; color: #333;\">\n" +
        "  <p>\n" +
        "    This travel agreement (hereinafter referred to as the \"Agreement\") is made between <span>\$SIGNER\$</span> (hereinafter referred to as the \"Child\" or \"Participant\") and <span>\$SENDER\$</span> (hereinafter referred to as the \"NGO Representative\").\n" +
        "  </p>\n" +
        "\n" +
        "  <p>\n" +
        "    By signing this Agreement, the Child and their legal guardian(s) consent to the Child's participation in the travel activities organized by the NGO Representative, under the terms and conditions outlined below.\n" +
        "  </p>\n" +
        "\n" +
        "  <p>\n" +
        "    <strong>1. Purpose of Travel:</strong> The purpose of this travel is to <span style=\"background-color: #FFCCCB;\">[specify purpose, e.g., participate in an educational program, attend a cultural exchange, etc.]</span>. The NGO Representative agrees to ensure the safety and well-being of the Child during the trip.\n" +
        "  </p>\n" +
        "\n" +
        "  <p>\n" +
        "    <strong>2. Travel Details:</strong> The travel will take place from <span style=\"background-color: #FFCCCB;\">[start date]</span> to <span style=\"background-color: #FFCCCB;\">[end date]</span>. The destination(s) include <span style=\"background-color: #FFCCCB;\">[list destinations]</span>. The NGO Representative will provide transportation, accommodation, and meals as follows: <span style=\"background-color: #FFCCCB;\">[specify details]</span>.\n" +
        "  </p>\n" +
        "\n" +
        "  <p>\n" +
        "    <strong>3. Responsibilities of the NGO Representative:</strong> The NGO Representative agrees to:\n" +
        "    <ul>\n" +
        "      <li>Ensure the safety and supervision of the Child at all times during the trip.</li>\n" +
        "      <li>Provide necessary medical assistance in case of emergencies, after obtaining consent from the Child's legal guardian(s).</li>\n" +
        "      <li>Communicate regularly with the Child's legal guardian(s) regarding the Child's well-being and any significant updates.</li>\n" +
        "    </ul>\n" +
        "  </p>\n" +
        "\n" +
        "  <p>\n" +
        "    <strong>4. Responsibilities of the Child and Legal Guardian(s):</strong> The Child and their legal guardian(s) agree to:\n" +
        "    <ul>\n" +
        "      <li>Provide accurate and complete information about the Child's health, dietary requirements, and any special needs.</li>\n" +
        "      <li>Ensure the Child follows the rules and guidelines set by the NGO Representative during the trip.</li>\n" +
        "      <li>Cover any additional expenses not included in the travel arrangements, such as personal purchases or optional activities.</li>\n" +
        "    </ul>\n" +
        "  </p>\n" +
        "\n" +
        "  <p>\n" +
        "    <strong>5. Emergency Contact:</strong> In case of an emergency, the NGO Representative will contact the Child's legal guardian(s) at the following number: <span style=\"background-color: #FFCCCB;\">[emergency contact number]</span>.\n" +
        "  </p>\n" +
        "\n" +
        "  <p>\n" +
        "    <strong>6. Liability:</strong> The NGO Representative shall not be held liable for any injuries, accidents, or damages that occur due to the Child's failure to follow instructions or rules during the trip. However, the NGO Representative will take all reasonable measures to ensure the Child's safety.\n" +
        "  </p>\n" +
        "\n" +
        "  <p>\n" +
        "    <strong>7. Withdrawal from the Trip:</strong> The Child's legal guardian(s) may withdraw the Child from the trip at any time by notifying the NGO Representative in writing. In such cases, any non-refundable expenses incurred will be the responsibility of the legal guardian(s).\n" +
        "  </p>\n" +
        "\n" +
        "  <p>\n" +
        "    <strong>8. Contact Information:</strong> For any inquiries or concerns, the Child's legal guardian(s) can contact the NGO Representative at:\n" +
        "    <br />\n" +
        "    <span>\$SENDER_EMAIL\$</span>\n" +
        "  </p>\n" +
        "\n" +
        "  <p>\n" +
        "    By agreeing to this document, the Child's legal guardian(s) acknowledge that they have read, understood, and agree to the terms outlined in this Agreement.\n" +
        "  </p>\n" +
        "</div>";
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
