class SwapKitMethods {
  final String name;
  final String url;
  const SwapKitMethods._({required this.name, required this.url});
  static const SwapKitMethods providers =
      SwapKitMethods._(name: "Providers", url: "/providers");
  static const SwapKitMethods tokens =
      SwapKitMethods._(name: "Providers", url: "/tokens");
  static const SwapKitMethods quote =
      SwapKitMethods._(name: "Providers", url: "/quote");
  static const SwapKitMethods chainflipOpenDepositChannel = SwapKitMethods._(
      name: "chain flip open deposit channel",
      url: "/chainflip/broker/channel");
  static const SwapKitMethods screen =
      SwapKitMethods._(name: "screen", url: "/screen");
  static const SwapKitMethods track =
      SwapKitMethods._(name: "track", url: "/track");
}
