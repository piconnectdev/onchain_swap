import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:example/api/services/electrum/services/electrum_ssl_service.dart';
import 'package:example/api/services/electrum/services/electrum_tcp_service.dart';
import 'package:example/api/services/electrum/services/electrum_websocket_service.dart';
import 'package:example/api/services/socket/core/socket_provider.dart';
import 'package:example/api/services/types/types.dart';

abstract class ElectrumService with ElectrumServiceProvider {
  ElectrumService();
  factory ElectrumService.fromProvider(ServiceInfo service) {
    switch (service.protocol) {
      case ServiceProtocol.ssl:
        return ElectrumSSLSocketService(service: service);
      case ServiceProtocol.tcp:
        return ElectrumSocketService(service: service);
      default:
        return ElectrumWebsocketService(service: service);
    }
  }
  void disposeService();
}
