import "dart:io" show Platform, ProcessInfo;

import "package:nyxx_commander/commander.dart";

String? get envPrefix => Platform.environment["ROD_PREFIX"];
String? get envHotReload => Platform.environment["ROD_HOT_RELOAD"];
String? get envToken => Platform.environment["ROD_TOKEN"];
String? get envAdminId => Platform.environment["ROD_ADMIN_ID"];

DateTime _approxMemberCountLastAccess = DateTime.utc(2005);
int _approxMemberCount = -1;

String get dartVersion {
  final platformVersion = Platform.version;
  return platformVersion.split("(").first;
}

String helpCommandGen(String commandName, String description, {String? additionalInfo}) {
  final buffer = StringBuffer();

  buffer.write("**$envPrefix$commandName**");

  if (additionalInfo != null) {
    buffer.write(" `$additionalInfo`");
  }

  buffer.write(" - $description.\n");

  return buffer.toString();
}

String getMemoryUsageString() {
  final current = (ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(2);
  final rss = (ProcessInfo.maxRss / 1024 / 1024).toStringAsFixed(2);
  return "$current/${rss}MB";
}

Future<bool> checkForAdmin(CommandContext context) async {
  if(envAdminId != null) {
    return context.author.id == envAdminId;
  }

  return false;
}

Future<int> getApproxMemberCount(CommandContext ctx) async {
  if (DateTime.now().difference(_approxMemberCountLastAccess).inMinutes > 5 || _approxMemberCount == -1) {
    // ignore: unawaited_futures
    Stream.fromFutures(
        ctx.client.guilds.values
            .map((e) async => (await e.fetchGuildPreview()).approxMemberCount))
        .reduce((previous, element) => previous + element).then((value) => _approxMemberCount = value);
  }

  return _approxMemberCount;
}
