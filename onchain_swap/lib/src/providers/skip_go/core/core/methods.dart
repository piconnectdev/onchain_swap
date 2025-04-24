class SkipGoApiMethods {
  final String name;
  final String url;
  const SkipGoApiMethods._({required this.name, required this.url});

  static const SkipGoApiMethods chains =
      SkipGoApiMethods._(name: 'chains', url: '/v2/info/chains');
  static const SkipGoApiMethods bridges =
      SkipGoApiMethods._(name: 'bridges', url: '/v2/info/bridges');
  static const SkipGoApiMethods balances =
      SkipGoApiMethods._(name: 'balances', url: '/v2/info/balances');

  static const SkipGoApiMethods venues =
      SkipGoApiMethods._(name: 'venues', url: '/v2/fungible/venues');

  static const SkipGoApiMethods assets =
      SkipGoApiMethods._(name: 'assets', url: '/v2/fungible/assets');
  static const SkipGoApiMethods assetsFromSource = SkipGoApiMethods._(
      name: 'assets from source', url: '/v2/fungible/assets_from_source');
  static const SkipGoApiMethods route =
      SkipGoApiMethods._(name: 'assets from source', url: '/v2/fungible/route');
  static const SkipGoApiMethods msgs =
      SkipGoApiMethods._(name: 'Msgs', url: '/v2/fungible/msgs');
  static const SkipGoApiMethods msgsDirect =
      SkipGoApiMethods._(name: 'Msgs Direct', url: '/v2/fungible/msgs_direct');
  static const SkipGoApiMethods ibcOriginAssets = SkipGoApiMethods._(
      name: 'IBC origin assets', url: '/v2/fungible/ibc_origin_assets');
  static const SkipGoApiMethods assetsBetweenChains = SkipGoApiMethods._(
      name: 'Assets between chains', url: '/v2/fungible/assets_between_chains');
  static const SkipGoApiMethods submit =
      SkipGoApiMethods._(name: 'Submit', url: '/v2/tx/submit');
  static const SkipGoApiMethods track =
      SkipGoApiMethods._(name: 'Track', url: '/v2/tx/track');
  static const SkipGoApiMethods status =
      SkipGoApiMethods._(name: 'Status', url: '/v2/tx/status');
}
