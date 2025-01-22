from flask import Flask, request, jsonify
from flask_cors import CORS
from docusign_esign import ApiClient
from docusign_esign.client.api_exception import ApiException
from app.eSignature.examples.doc_info import Eg004EnvelopeInfoController
from app.jwt_helpers import get_jwt_token, get_private_key
from app.eSignature.examples.email_sign import (
    Eg002SigningViaEmailController,
)
from app.jwt_config import DS_JWT

app = Flask(__name__)
CORS(app)

SCOPES = ["signature", "impersonation"]


def get_token(private_key, api_client):
    token_response = get_jwt_token(
        private_key,
        SCOPES,
        DS_JWT["authorization_server"],
        DS_JWT["ds_client_id"],
        DS_JWT["ds_impersonated_user_id"],
    )
    access_token = token_response.access_token
    user_info = api_client.get_user_info(access_token)
    accounts = user_info.get_accounts()
    return {
        "access_token": access_token,
        "api_account_id": accounts[0].account_id,
        "base_path": accounts[0].base_uri + "/restapi",
    }


@app.route("/create_envelope", methods=["POST"])
def create_envelope():
    try:
        data = request.json

        # Initialize API client
        api_client = ApiClient()
        api_client.set_base_path(DS_JWT["authorization_server"])
        api_client.set_oauth_host_name(DS_JWT["authorization_server"])

        # Get private key and token
        private_key = (
            get_private_key(DS_JWT["private_key_file"]).encode("ascii").decode("utf-8")
        )
        jwt_values = get_token(private_key, api_client)

        # Prepare envelope args
        envelope_args = {
            "signer_email": data["signer_email"],
            "signer_name": data["signer_name"],
            "cc_email": data["cc_email"],
            "cc_name": data["cc_name"],
            "title": data["title"],
            "content": data["content"],
            "status": "sent",
        }

        args = {
            "account_id": jwt_values["api_account_id"],
            "base_path": jwt_values["base_path"],
            "access_token": jwt_values["access_token"],
            "envelope_args": envelope_args,
        }

        result = Eg002SigningViaEmailController.worker(args)

        return jsonify(result)

    except ApiException as err:
        body = err.body.decode("utf8")
        if "consent_required" in body:
            # Generate consent URL
            url_scopes = "+".join(SCOPES)
            redirect_uri = "https://developers.docusign.com/platform/auth/consent"
            consent_url = (
                f"https://{DS_JWT['authorization_server']}/oauth/auth?response_type=code&"
                f"scope={url_scopes}&client_id={DS_JWT['ds_client_id']}&redirect_uri={redirect_uri}"
            )

            return (
                jsonify(
                    {
                        "error": "consent_required",
                        "consent_url": consent_url,
                        "message": "Please visit the consent_url to grant consent, then try the request again",
                    }
                ),
                403,
            )

        return jsonify({"error": str(err)}), 500


@app.route("/envelope_status/<envelope_id>", methods=["GET"])
def get_envelope_status(envelope_id):
    try:
        # Initialize API client
        api_client = ApiClient()
        api_client.set_base_path(DS_JWT["authorization_server"])
        api_client.set_oauth_host_name(DS_JWT["authorization_server"])

        # Get private key and token
        private_key = (
            get_private_key(DS_JWT["private_key_file"]).encode("ascii").decode("utf-8")
        )
        jwt_values = get_token(private_key, api_client)

        # Prepare args for the controller
        args = {
            "account_id": jwt_values["api_account_id"],
            "base_path": jwt_values["base_path"],
            "access_token": jwt_values["access_token"],
            "envelope_id": envelope_id,
        }

        # Get envelope info using the controller
        result = Eg004EnvelopeInfoController.worker(args)

        # Extract only the required fields
        filtered_response = {
            "sender_email": result.sender.email,
            "sender_name": result.sender.user_name,
            "status": result.status,
            "status_changed_date_time": result.status_changed_date_time,
        }

        return jsonify(filtered_response)

    except ApiException as err:
        body = err.body.decode("utf8")
        if "consent_required" in body:
            url_scopes = "+".join(SCOPES)
            redirect_uri = "https://developers.docusign.com/platform/auth/consent"
            consent_url = (
                f"https://{DS_JWT['authorization_server']}/oauth/auth?response_type=code&"
                f"scope={url_scopes}&client_id={DS_JWT['ds_client_id']}&redirect_uri={redirect_uri}"
            )

            return (
                jsonify(
                    {
                        "error": "consent_required",
                        "consent_url": consent_url,
                        "message": "Please visit the consent_url to grant consent, then try the request again",
                    }
                ),
                403,
            )

        return jsonify({"error": str(err)}), 500


@app.route("/batch_envelope_status", methods=["POST"])
def get_batch_envelope_status():
    try:
        data = request.json
        envelope_ids = data.get("envelope_ids", [])

        if not envelope_ids:
            return jsonify({"error": "No envelope IDs provided"}), 400

        # Initialize API client
        api_client = ApiClient()
        api_client.set_base_path(DS_JWT["authorization_server"])
        api_client.set_oauth_host_name(DS_JWT["authorization_server"])

        # Get private key and token
        private_key = (
            get_private_key(DS_JWT["private_key_file"]).encode("ascii").decode("utf-8")
        )
        jwt_values = get_token(private_key, api_client)

        # Prepare base args for the controller
        base_args = {
            "account_id": jwt_values["api_account_id"],
            "base_path": jwt_values["base_path"],
            "access_token": jwt_values["access_token"],
        }

        # Process each envelope ID and collect results
        results = []
        for envelope_id in envelope_ids:
            args = {**base_args, "envelope_id": envelope_id}
            result = Eg004EnvelopeInfoController.worker(args)

            filtered_response = {
                "envelope_id": envelope_id,
                "sender_email": result.sender.email,
                "sender_name": result.sender.user_name,
                "status": result.status,
                "status_changed_date_time": result.status_changed_date_time,
            }
            results.append(filtered_response)

        return jsonify(results)

    except ApiException as err:
        body = err.body.decode("utf8")
        if "consent_required" in body:
            url_scopes = "+".join(SCOPES)
            redirect_uri = "https://developers.docusign.com/platform/auth/consent"
            consent_url = (
                f"https://{DS_JWT['authorization_server']}/oauth/auth?response_type=code&"
                f"scope={url_scopes}&client_id={DS_JWT['ds_client_id']}&redirect_uri={redirect_uri}"
            )

            return (
                jsonify(
                    {
                        "error": "consent_required",
                        "consent_url": consent_url,
                        "message": "Please visit the consent_url to grant consent, then try the request again",
                    }
                ),
                403,
            )

        return jsonify({"error": str(err)}), 500


@app.route("/batch_create_envelopes", methods=["POST"])
def create_batch_envelopes():
    try:
        data = request.json
        signers = data.get("signers", [])

        if not signers:
            return jsonify({"error": "No signers provided"}), 400

        # Initialize API client
        api_client = ApiClient()
        api_client.set_base_path(DS_JWT["authorization_server"])
        api_client.set_oauth_host_name(DS_JWT["authorization_server"])

        # Get private key and token
        private_key = (
            get_private_key(DS_JWT["private_key_file"]).encode("ascii").decode("utf-8")
        )
        jwt_values = get_token(private_key, api_client)

        # Prepare base envelope args
        base_envelope_args = {
            "cc_email": data["cc_email"],
            "cc_name": data["cc_name"],
            "title": data["title"],
            "content": data["content"],
            "status": "sent",
        }

        # Prepare base args for the controller
        base_args = {
            "account_id": jwt_values["api_account_id"],
            "base_path": jwt_values["base_path"],
            "access_token": jwt_values["access_token"],
        }

        # Process each signer and collect envelope IDs
        results = []
        for signer in signers:
            envelope_args = {
                **base_envelope_args,
                "signer_email": signer["signer_email"],
                "signer_name": signer["signer_name"],
            }

            args = {**base_args, "envelope_args": envelope_args}
            result = Eg002SigningViaEmailController.worker(args)
            results.append(result["envelope_id"])

        return jsonify({"envelope_ids": results})

    except ApiException as err:
        body = err.body.decode("utf8")
        if "consent_required" in body:
            url_scopes = "+".join(SCOPES)
            redirect_uri = "https://developers.docusign.com/platform/auth/consent"
            consent_url = (
                f"https://{DS_JWT['authorization_server']}/oauth/auth?response_type=code&"
                f"scope={url_scopes}&client_id={DS_JWT['ds_client_id']}&redirect_uri={redirect_uri}"
            )

            return (
                jsonify(
                    {
                        "error": "consent_required",
                        "consent_url": consent_url,
                        "message": "Please visit the consent_url to grant consent, then try the request again",
                    }
                ),
                403,
            )

        return jsonify({"error": str(err)}), 500


if __name__ == "__main__":
    app.run(port=5000)
