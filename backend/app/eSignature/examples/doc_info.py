from docusign_esign import EnvelopesApi
from ...jwt_helpers import create_api_client


class Eg004EnvelopeInfoController:
    @classmethod
    def worker(cls, args):
        """
        1. Call the envelope get method to get envelope's information
        """

        # Create the API client
        api_client = create_api_client(
            base_path=args["base_path"], access_token=args["access_token"]
        )

        # Create the Envelopes API object
        envelope_api = EnvelopesApi(api_client)

        # Call the envelope get method
        results = envelope_api.get_envelope(
            account_id=args["account_id"], envelope_id=args["envelope_id"]
        )

        return results
