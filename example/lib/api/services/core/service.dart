import 'package:onchain_swap_example/api/services/types/types.dart';

abstract class APIService {
  final ServiceInfo service;
  const APIService({required this.service});
}
