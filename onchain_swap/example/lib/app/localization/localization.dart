class Localization {
  static Map<String, Map<String, String>> get languages => {
        "en": {
          'no_token_found': "Token not found.",
          "provider": "Provider",
          "expected_amount": "Expected amount",
          "estimated_time": "Estimated time",
          "n_minutes": "___1__ minutes",
          "routes": "Routes",
          "fees": "Fees",
          "amount": "Amount",
          "cross_chain_swap": "Cross-Chain swap",
          "single_chain_swap": "Single-Chain Swap",
          "min_expected_amount": "Minimum expected amount",
          "failed_to_load_image": "Image failed to load.",
          "no_available_swap_route": "No available swap route.",
          "format_exception":
              "The data format is invalid. Please check the input.",
          "timeout_exception": "The operation took too long and timed out.",
          "socket_exception":
              "Network error. Please check your internet connection.",
          "http_exception": "There was a problem with the HTTP request.",
          "range_error": "A value is out of the allowed range.",
          "argument_error": "An invalid argument was provided.",
          "state_error":
              "The operation couldn’t be performed in the current state.",
          "unimplemented_error": "This feature hasn’t been implemented yet.",
          "unsupported_error": "This operation is not supported.",
          "assertion_error": "An internal assertion failed.",
          "null_pointer_error":
              "A null value was accessed unexpectedly.", // Dart 3.0+ doesn't throw this, but it's conceptually common.
          "cast_error": "A value couldn’t be cast to the expected type.",
          "type_error": "An unexpected type was used.",
          "no_swap_route_found":
              "No swap route was found for the selected tokens.",
          "source_address": "Source address",
          "destination_address": "Destination address",
          "amount_out": "Amount out",
          "amount_in": "Amount in",
          "unknown_source_asset": "Unknown source asset",
          "unknown_destination_asset": "Unknown destination asset",
          "invalid_network_address": "Invalid ___1__ address",
          "eg_example": "E.g., ___1__",
          "swap_now": "Swap Now",
          "asset_in": "Asset in",
          "asset_out": "Asset out",
          "service_provider": "Service provider",
          "authenticated": "Authentication",
          "add_provider_authenticated": "Add authentication to your provider.",
          "authenticated_key_validator":
              "Please enter at least one character for the authentication key.",
          "authenticated_value_validator":
              "Please enter at least one character for the authentication value.",
          "value_is_to_large": "The provided value is too large.",
          "network_tcp_address_validator":
              "Invalid TCP or IPv4 address. Please refer to the example address for proper formatting.",
          "network_websocket_address_validator":
              "Invalid Websocket address. Please refer to the example address for proper formatting.",
          "rpc_url_validator":
              "Please enter a valid RPC URL starting with 'http' or 'https'.",
          "network_title_http_url":
              "Please provide the HTTP or HTTPS address, including the http:// or https:// prefix. If applicable, include the port number. For example, https://example.com:8080",
          "network_tittle_tcp_ssl_url":
              "Enter the ___1__ URL or IPv4 address without any prefix, including the port, like example.com:50002.",
          "network_title_websocket_url":
              "Please supply the WebSocket address, including the WS or WSS prefix, and if necessary, specify the port. For example, wss://example.com.",
          "network_update_node_provider": "Update node provider",
          "network": "Network",
          "protocol": "Protocol",
          "network_update_network_providers": "Update network providers.",
          "api_url": "API URL",
          "network_verify_server_status": "Verify server status.",
          "authenticated_type": "Authentication Type",
          "authenticated_key": "Authentication key",
          "authenticated_value": "Authentication value",
          "example_value": "Example: ___1__",
          "read_more": "Read more...",
          "no_provider_found": "No provider found",
          "missing_provider_desc":
              "Missing provider. Please enter the RPC URL to proceed with the swap.",
          "unsupported_source_network": "Unsupported source network.",
          "missin_cosmos_chain_info_err":
              "Missing Cosmos chain information: unable to build client.",
          "invalid_provider_protocol": "Invalid provider protocol",
          "connect": "Connect",
          "wallet_request_unknown_err":
              "Wallet request failed due to an unknown error.",
          "disconnect": "Disconnect",
          "accounts": "Accounts",
          "no_wallet_accounts_found":
              "No matching chain accounts found. Please ensure you've selected the correct network and accounts in your wallet.",
          "select_account_desc": "Select the account you’d like to use.",
          "copied_to_clipboard": "Copied to cliboard.",
          "copied_to_clipboard_faild": "Copy action unsuccessful.",
          "signer_not_found_in_wallet_accounts":
              "Signer address not found in connected wallet accounts",
          "unexpected_signing_transaction_response":
              "Wallet returned an unexpected response during transaction signing.",
          "incorrect_wallet_transaction_chainid":
              "Transaction chain ID does not match the connected network.",
          "source": "Source",
          "destionation": "Destination",
          "memo": "Memo",
          "token": "Token",
          "contract": "Contract",
          "input": "Input",
          "function": "Function",
          "contract_intraction": "Contract interaction",
          "transfer": "Transfer",
          "token_transfer": "Token Transfer",
          "route_information": "Route information",
          "operations": "Operations",
          "channel_information": "Channel Information",
          "channel_id": "Channel ID",
          "expiration_time": "Expiration time",
          "channel": "Channel",
          "route": "Route",
          "operation_manually_desc":
              "You can complete the swap either manually or using a Web3 wallet. If you choose to proceed manually, please make sure you understand each step and follow them in the correct order. Be especially careful with settings like memo, destination address, or contract input data — any mistake could result in the loss of funds.",
          "back_to_the_page": "Back to the page",
          "network_waiting_for_response": "Awaiting a reply. please wait.",
          "new_sarvice_provider_saved":
              "New service provider saved successfully.",
          "tap_to_review_fees": "Tap to review fees",
          "update_tolerance": "Update tolerance",
          "higher_than_recommended_tolerance":
              "Higher than recommended tolerance",
          "lower_than_recommended_tolerance":
              "Lower than recommended tolerance",
          "tolerance_desc":
              "Maximum acceptable slippage for your token swap route.",
          "update_route": "Update route",
          "speed_priority": "Speed Priority",
          "fee_optimized": "Fee Optimized",
          "tolerance": "Tolerance",
          "lowest_expected_amount": "Lowest Expected Amount",
          "market_price_unavailable": "Market price unavailable",
          "expected_swap_duration": "Expected swap duration",
          "sign_and_send_transaction": "Sign and broadcast",
          "generate_tx_please_wait": "Generating Transaction. please wait.",
          "toggle_currency": "Toggle Currency",
          "dark_mode": "Dark mode",
          "primary_color_palette": "Primary Color Palette",
          "select_color_from_blow":
              "Select the primary color for the program from the following options:",
          "color_changed": "The primary color has been successfully modified.",
          "adjust_app_brightness": "Adjust App Brightness",
          "define_primary_of_app":
              "Define the primary color scheme for the application",
          "settings": "Settings",
          "home_page": "Home page",
          "update_network_providers": "Update networks providers",
          "add_provider_desc":
              "Add your own provider to interact with the network.",
          "networks": "Networks",
          "chose_provider_for_update_dest":
              "Select the network for which you want to update the provider.",
          "update_services": "Update services",
          "invalid_serialization_data": "Invalid serialization data",

          "at_least_one_provider_must_enabled":
              "At least one service provider must be enabled.",
          "swap_services": "Swap services",
          "enable_disable_swap_service_desc":
              "Enable or disable swap service providers.",
          "invalid_provider_infomarion": "Invalid provider information.",
          "api_http_client_error":
              "An error occurred on the client side during the request.",
          "data_verification_failed": "Data verification failed.",
          "file_verification_fail":
              "We couldn't verify the file's integrity. It may be corrupted or tampered with. please try again",

          "file_does_not_exist": "File does not exists.",
          "generating_transaction": "Generating transaction",
          "signing_transaction": "Signing Transaction",
          "no_wallet_detected": "No wallet detected.",
          "transaction": "Transaction",
          "connecting_to_network": "Connecting to network",
          "broadcasting_transaction": "Broadcasting transaction",
          "complete": "Complete",
          "close_swap_page_desc":
              "A swap is currently in progress. Do you really want to leave this page?",
          "close_page": "Close page",
          "manage_wallets": "Manage Wallets",
          "wallets": "Wallets",
          "invalid_dgiest_auth_headers":
              "Invalid Digest Authentication headers.",
          "mainnet": "Mainnet"
        }
      };
}
