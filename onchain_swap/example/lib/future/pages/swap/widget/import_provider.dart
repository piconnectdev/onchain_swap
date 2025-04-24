import 'package:onchain_swap/onchain_swap.dart';
import 'package:example/api/utils/utils.dart';
import 'package:example/api/services/socket/core/socket_provider.dart';
import 'package:example/api/services/types/types.dart';
import 'package:example/app/constants/constants.dart';
import 'package:example/app/http/models/auth.dart';
import 'package:example/app/types/types.dart';
import 'package:example/app/uri/utils.dart';
import 'package:example/app/utils/method.dart';
import 'package:example/app/utils/string.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:example/future/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:mrt_native_support/platform_interface.dart';

typedef ONADDNEWSERVICE = void Function(ServiceInfo service);

class HTTPServiceProviderFields extends StatefulWidget {
  final Widget? title;
  const HTTPServiceProviderFields(
      {super.key,
      this.network,
      this.onAddNewProvider,
      this.title,
      this.controller});

  final SwapNetwork? network;
  final ScrollController? controller;
  final ONADDNEWSERVICE? onAddNewProvider;

  @override
  State<HTTPServiceProviderFields> createState() =>
      HTTPServiceProviderFieldsState();
}

class HTTPServiceProviderFieldsState extends State<HTTPServiceProviderFields>
    with SafeState {
  bool useAuthenticated = false;
  bool isSingleNetworkUpdate = false;
  ProviderAuthType auth = ProviderAuthType.header;
  List<ProviderAuthType> supportedAuth = [];
  GlobalKey<PageProgressState> progressKey = GlobalKey();
  List<SwapNetwork> get networks => SwapConstants.networks;
  void onChangeAuthMode(ProviderAuthType? auth) {
    this.auth = auth ?? this.auth;
    updateState();
  }

  List<ServiceProtocol> supportedProtocol = [];
  late ServiceProtocol protocol;
  SwapNetwork? network;
  late APIProviderServiceInfo service;

  Map<SwapNetwork, Widget> networkItems = {};
  Map<SwapNetwork, Widget> buildNetworkItems() {
    return {
      for (final i in networks)
        i: Row(children: [
          CircleNetworkImageView(i, radius: APPConst.circleRadius10),
          WidgetConstant.width8,
          Expanded(child: Text(i.name))
        ])
    };
  }

  Future<void> _loadService(SwapNetwork network) async {
    final service = await context.mainController.loadServiceProvider(network);
    if (service != null) {
      rpcUrl = service.url;
      final auth = service.authenticated;
      if (auth != null && auth is BasicProviderAuthenticated) {
        authKey = auth.key;
        authValue = auth.value;
        this.auth = auth.type;
        useAuthenticated = true;
      }
      uriFieldKey.currentState?.updateText(rpcUrl);
      setProtocol(service.protocol);
      updateState();
    }
  }

  void onChangeNetwork(SwapNetwork? network) {
    if (network == null) {
      this.network = null;
      updateState();
      return;
    }
    this.network = network;
    resetConfig(network);
    _loadService(network);
    updateState();
  }

  void resetConfig(SwapNetwork network) {
    rpcUrl = '';
    useAuthenticated = false;
    authKey = '';
    authValue = '';
    supportedProtocol = switch (network.type) {
      SwapChainType.bitcoin => [
          if (PlatformInterface.isWeb)
            ServiceProtocol.websocket
          else ...[
            ServiceProtocol.ssl,
            ServiceProtocol.tcp,
            ServiceProtocol.websocket
          ]
        ],
      SwapChainType.ethereum => [
          ServiceProtocol.websocket,
          ServiceProtocol.http
        ],
      SwapChainType.solana => [ServiceProtocol.http],
      SwapChainType.polkadot => [
          ServiceProtocol.websocket,
          ServiceProtocol.http
        ],
      SwapChainType.cosmos => [ServiceProtocol.http],
    };
    protocol = supportedProtocol.first;
    service = switch (network.type) {
      SwapChainType.bitcoin => APIProviderServiceInfo(name: "Electrum"),
      SwapChainType.ethereum => APIProviderServiceInfo(
          name: "Ethereum JSON RPC",
          url: "https://ethereum.org/en/developers/docs/apis/json-rpc/"),
      SwapChainType.solana => APIProviderServiceInfo(
          name: "Solana JSON RPC", url: "https://solana.com/docs/rpc"),
      SwapChainType.polkadot => APIProviderServiceInfo(
          name: "Polkadot JSON RPCd",
          url: "https://wiki.polkadot.network/docs/maintain-endpoints"),
      SwapChainType.cosmos => APIProviderServiceInfo(
          name: "Tendermint", url: "https://docs.tendermint.com/v0.34/rpc/"),
    };
  }

  ProviderAuthenticated? createAuth() {
    if (enableAuthMode && useAuthenticated) {
      return BasicProviderAuthenticated(
          type: auth, key: authKey, value: authValue);
    }
    return null;
  }

  bool hasAnyChange = false;
  String rpcUrl = "";
  bool enableAuthMode = false;
  bool get enableUpdateButton => !hasAnyChange;
  void onPasteUri(String v) {
    uriFieldKey.currentState?.updateText(v);
  }

  void onChageUrl(String v) {
    rpcUrl = v;
  }

  void onChangeAuthenticated(bool? v) {
    useAuthenticated = !useAuthenticated;
    updateState();
  }

  String authKey = "";
  String authValue = "";

  void onChangeKey(String v) {
    authKey = v;
  }

  void onChangeValue(String v) {
    authValue = v;
  }

  String? validateKey(String? v) {
    if (v?.trim().isEmpty ?? true) {
      return "authenticated_key_validator".tr;
    }
    if (v!.length > APPConst.maximumHeaderValue) {
      return "value_is_to_large".tr;
    }
    return null;
  }

  String? validateValue(String? v) {
    if (v?.trim().isEmpty ?? true) {
      return "authenticated_value_validator".tr;
    }
    if (v!.length > APPConst.maximumHeaderValue) {
      return "value_is_to_large".tr;
    }
    return null;
  }

  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<AppTextFieldState> uriFieldKey = GlobalKey();

  void setProtocol(ServiceProtocol selectedProtocol) {
    protocol = selectedProtocol;
    if (protocol == ServiceProtocol.http) {
      supportedAuth = [ProviderAuthType.query, ProviderAuthType.header];
    } else if (protocol == ServiceProtocol.websocket) {
      supportedAuth = [ProviderAuthType.query];
      auth = ProviderAuthType.query;
    } else {
      supportedAuth = [];
    }
    enableAuthMode = supportedAuth.isNotEmpty;
  }

  void onChangeProtocol(ServiceProtocol? selectedProtocol) {
    try {
      if (selectedProtocol == null) return;
      if (!supportedProtocol.contains(selectedProtocol)) {
        return;
      }
      setProtocol(selectedProtocol);
    } finally {
      updateState();
    }
  }

  String? _validateTcpSSLUrl(String? address) {
    final path = StrUtils.isValidTcpAddress(address);
    if (path != null) return null;
    return "network_tcp_address_validator".tr;
  }

  String? validateWebsocketAddress(String? address) {
    final path = StrUtils.validateUri(address, schame: ["wss", "ws"]);
    if (path != null) return null;
    return "network_websocket_address_validator".tr;
  }

  String? validateHttpAddress(String? address) {
    final path = StrUtils.validateUri(address, schame: ["http", "https"]);
    if (path != null) return null;
    return "rpc_url_validator".tr;
  }

  String? validateRpcUrl(String? v) {
    switch (protocol) {
      case ServiceProtocol.http:
        return validateHttpAddress(v);
      case ServiceProtocol.ssl:
      case ServiceProtocol.tcp:
        return _validateTcpSSLUrl(v);
      default:
        return validateWebsocketAddress(v);
    }
  }

  String get protocolTitle {
    switch (protocol) {
      case ServiceProtocol.http:
        return "network_title_http_url".tr;
      case ServiceProtocol.tcp:
      case ServiceProtocol.ssl:
        return "network_tittle_tcp_ssl_url".tr.replaceOne(protocol.value);
      default:
        return "network_title_websocket_url".tr;
    }
  }

  String get protocolHint {
    switch (protocol) {
      case ServiceProtocol.http:
        return "https://example.com";
      case ServiceProtocol.tcp:
      case ServiceProtocol.ssl:
        return "example.com:50002";
      default:
        return "wss://example.com";
    }
  }

  void importProvider() async {
    final mainController = context.mainController;
    final network = this.network;
    if (network == null || !(formKey.currentState?.validate() ?? false)) return;
    progressKey.progressText("network_waiting_for_response".tr);
    final result = await MethodUtils.call(() async {
      final auth = createAuth();
      final provider =
          ServiceInfo(url: rpcUrl, protocol: protocol, authenticated: auth);
      await ProviderUtils.buildClient(network: network, provider: provider);
      await mainController.saveServiceProvider(
          service: provider, network: network);
      return provider;
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          showBackButton: true, backToIdle: false);
      return;
    }
    progressKey.successText("new_sarvice_provider_saved".tr, backToIdle: false);
    widget.onAddNewProvider?.call(result.result);
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    network = widget.network;
    if (network != null) {
      isSingleNetworkUpdate = true;
      resetConfig(network!);
    } else {
      networkItems = buildNetworkItems();
    }
  }

  @override
  void safeDispose() {
    super.safeDispose();
    networkItems.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPageView(
      appBar: AppBar(title: Text("network_update_node_provider".tr)),
      child: Form(
        key: formKey,
        child: PageProgress(
          key: progressKey,
          initialStatus: StreamWidgetStatus.idle,
          backToIdle: APPConst.twoSecoundDuration,
          child: (c) => UnfocusableChild(
            child: Center(
              child: CustomScrollView(
                shrinkWrap: true,
                controller: widget.controller,
                slivers: [
                  SliverConstraintsBoxView(
                    padding: WidgetConstant.padding20,
                    sliver: APPSliverAnimatedSwitcher(
                        enable: network != null,
                        widgets: {
                          false: (context) => _SelectNetwork(this),
                          true: (context) => _ImportNetwork(this),
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef ONCHANGEAUTHMODE = void Function(ProviderAuthType? auth);

class _SelectNetwork extends StatelessWidget {
  final HTTPServiceProviderFieldsState state;
  const _SelectNetwork(this.state);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("network".tr, style: context.textTheme.titleMedium),
        Text("chose_provider_for_update_dest".tr),
        WidgetConstant.height8,
        AppDropDownBottom(
          isExpanded: true,
          items: state.networkItems,
          value: state.network,
          onChanged: state.onChangeNetwork,
          hint: 'network'.tr,
        )
      ]),
    );
  }
}

class ProviderAuthView extends StatelessWidget {
  const ProviderAuthView(
      {super.key,
      required this.enableAuthMode,
      required this.useAuthenticated,
      required this.onChangeAuthenticated,
      required this.onChangeAuthMode,
      required this.auth,
      required this.authKey,
      required this.authValue,
      required this.onChangeKey,
      required this.validateKey,
      required this.onChangeValue,
      required this.validateValue,
      required this.supportedAuths});
  final bool enableAuthMode;
  final bool useAuthenticated;
  final NullBoolVoid? onChangeAuthenticated;
  final ONCHANGEAUTHMODE onChangeAuthMode;
  final ProviderAuthType auth;
  final String authKey;
  final String authValue;
  final StringVoid? onChangeKey;
  final NullStringString? validateKey;
  final StringVoid? onChangeValue;
  final NullStringString? validateValue;
  final List<ProviderAuthType> supportedAuths;

  @override
  Widget build(BuildContext context) {
    return ConditionalWidgets(enable: enableAuthMode, widgets: {
      true: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("authenticated".tr),
              subtitle: Text("add_provider_authenticated".tr),
              value: useAuthenticated,
              onChanged: onChangeAuthenticated,
            ),
            APPAnimatedSize(
                isActive: useAuthenticated,
                onActive: (context) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetConstant.height8,
                        AppDropDownBottom(
                          items: {
                            for (final i in supportedAuths)
                              i: Text(i.name.camelCase)
                          },
                          onChanged: onChangeAuthMode,
                          value: auth,
                        ),
                        WidgetConstant.height20,
                        AppTextField(
                          label: "authenticated_key".tr,
                          pasteIcon: true,
                          initialValue: authKey,
                          hint: "example_value".tr.replaceOne(auth.isHeader
                              ? APPConst.exampleAuthenticatedHeader
                              : APPConst.exampleAuthenticatedQuery),
                          onChanged: onChangeKey,
                          validator: validateKey,
                        ),
                        AppTextField(
                            pasteIcon: true,
                            label: "authenticated_value".tr,
                            initialValue: authValue,
                            hint: "example_value".tr.replaceOne(auth.isHeader
                                ? APPConst.exampleAuthenticatedHeaderValue
                                : APPConst.exampleBase58),
                            onChanged: onChangeValue,
                            validator: validateValue),
                      ],
                    ),
                onDeactive: (c) => WidgetConstant.sizedBox),
          ],
        );
      }
    });
  }
}

class APIProviderServiceInfo {
  final String name;
  final String? url;
  const APIProviderServiceInfo({required this.name, this.url});
}

class _ImportNetwork extends StatelessWidget {
  final HTTPServiceProviderFieldsState state;
  const _ImportNetwork(this.state);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConditionalWidget(
              onActive: (context) => state.widget.title!,
              enable: state.widget.title != null),
          Text("network".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
              enableTap: false,
              onRemove: state.isSingleNetworkUpdate ? null : () {},
              onRemoveWidget: ConditionalWidget(
                  enable: !state.isSingleNetworkUpdate,
                  onActive: (context) => IconButton(
                      onPressed: () => state.onChangeNetwork(null),
                      icon:
                          Icon(Icons.edit, color: context.onPrimaryContainer))),
              child: Text(
                state.network?.name ?? '',
                style: context.colors.onPrimaryContainer.bodyMedium(context),
              )),
          WidgetConstant.height20,
          Text("service_provider".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            enableTap: false,
            onRemove: state.service.url == null
                ? null
                : () {
                    UriUtils.lunch(state.service.url);
                  },
            onRemoveIcon: ToolTipView(
              key: ValueKey(state.service),
              message: state.service.url,
              child: Icon(Icons.open_in_new_rounded,
                  color: context.onPrimaryContainer),
            ),
            child: Text(state.service.name),
          ),
          WidgetConstant.height20,
          Text("protocol".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            child: AppDropDownBottom(
              key: ValueKey(state.protocol),
              border: InputBorder.none,
              fillColor: context.colors.transparent,
              items: {
                for (final i in state.supportedProtocol)
                  i: Text(
                    i.value,
                    style:
                        context.colors.onPrimaryContainer.bodyMedium(context),
                  )
              },
              itemBuilder: {
                for (final i in state.supportedProtocol) i: Text(i.value)
              },
              labelStyle: context.colors.onPrimaryContainer.lableLarge(context),
              value: state.protocol,
              onChanged: state.onChangeProtocol,
            ),
          ),
          WidgetConstant.height20,
          Text("api_url".tr, style: context.textTheme.titleMedium),
          Text(state.protocolTitle),
          WidgetConstant.height8,
          AppTextField(
            key: state.uriFieldKey,
            initialValue: state.rpcUrl,
            onChanged: state.onChageUrl,
            validator: state.validateRpcUrl,
            suffixIcon: PasteTextIcon(
              onPaste: state.onPasteUri,
              isSensitive: false,
            ),
            label: "api_url".tr,
            hint: state.protocolHint,
          ),
          ProviderAuthView(
              enableAuthMode: state.enableAuthMode,
              useAuthenticated: state.useAuthenticated,
              onChangeAuthenticated: state.onChangeAuthenticated,
              onChangeAuthMode: state.onChangeAuthMode,
              auth: state.auth,
              authKey: state.authKey,
              authValue: state.authValue,
              onChangeKey: state.onChangeKey,
              validateKey: state.validateKey,
              onChangeValue: state.onChangeValue,
              validateValue: state.validateValue,
              supportedAuths: state.supportedAuth),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton.icon(
                padding: WidgetConstant.paddingVertical40,
                label: Text("network_verify_server_status".tr),
                onPressed: state.importProvider,
                icon: const Icon(Icons.update),
              ),
            ],
          )
        ],
      ),
    );
  }
}
