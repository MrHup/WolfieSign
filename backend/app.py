from flask import Flask, request, jsonify
from docusign_esign import ApiClient
from docusign_esign.client.api_exception import ApiException
from app.eSignature.examples.eg004_envelope_info import Eg004EnvelopeInfoController
from app.jwt_helpers import get_jwt_token, get_private_key
from app.eSignature.examples.eg002_signing_via_email import (
    Eg002SigningViaEmailController,
)
from app.jwt_config import DS_JWT

app = Flask(__name__)

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

        return jsonify(result.to_dict())

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
