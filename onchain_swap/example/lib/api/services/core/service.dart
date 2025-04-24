import 'package:example/api/services/types/types.dart';

abstract class APIService {
  final ServiceInfo service;
  const APIService({required this.service});
}
