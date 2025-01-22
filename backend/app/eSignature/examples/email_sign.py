import base64
from datetime import datetime
from docusign_esign import (
    EnvelopesApi,
    EnvelopeDefinition,
    Document,
    Signer,
    CarbonCopy,
    SignHere,
    Tabs,
    Recipients,
)
from ...jwt_helpers import create_api_client


class Eg002SigningViaEmailController:
    @classmethod
    def worker(cls, args, *_):
        """
        1. Create the envelope request object
        2. Send the envelope
        """
        envelope_args = args["envelope_args"]
        envelope_definition = cls.make_envelope(envelope_args)

        api_client = create_api_client(
            base_path=args["base_path"], access_token=args["access_token"]
        )

        envelopes_api = EnvelopesApi(api_client)
        results = envelopes_api.create_envelope(
            account_id=args["account_id"], envelope_definition=envelope_definition
        )

        return {"envelope_id": results.envelope_id}

    @classmethod
    def make_envelope(cls, args):
        """Creates envelope with single HTML document"""
        env = EnvelopeDefinition(email_subject="Please sign this document")

        # Create HTML document
        doc1_b64 = base64.b64encode(bytes(cls.create_document1(args), "utf-8")).decode(
            "ascii"
        )

        # Create the DocuSign document object
        document1 = Document(
            document_base64=doc1_b64,
            name="Order acknowledgement",
            file_extension="html",
            document_id="1",
        )

        env.documents = [document1]

        # Create the signer recipient model
        signer1 = Signer(
            email=args["signer_email"],
            name=args["signer_name"],
            recipient_id="1",
            routing_order="1",
        )

        # Create CC recipient
        cc1 = CarbonCopy(
            email=args["cc_email"],
            name=args["cc_name"],
            recipient_id="2",
            routing_order="2",
        )

        # Create signature field
        sign_here1 = SignHere(
            anchor_string="**signature_1**",
            anchor_units="pixels",
            anchor_y_offset="10",
            anchor_x_offset="20",
        )

        signer1.tabs = Tabs(sign_here_tabs=[sign_here1])
        recipients = Recipients(signers=[signer1], carbon_copies=[cc1])
        env.recipients = recipients
        env.status = args["status"]

        return env

    @classmethod
    def create_document1(cls, args):
        """Creates document 1 -- an html document"""
        current_date = datetime.now().strftime("%Y/%m/%d")

        # Replace placeholders in content
        content = args.get("content", "CONTENT HERE")
        content = content.replace("$SIGNER$", args["signer_name"])
        content = content.replace("$SENDER$", args["cc_name"])

        return content
