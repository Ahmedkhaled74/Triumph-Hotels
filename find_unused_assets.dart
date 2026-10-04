import 'dart:io';

void main() async {
  final assetsDir = Directory('assets');
  final libDir = Directory('lib');
  
  if (!assetsDir.existsSync()) {
    print('Assets directory not found');
    return;
  }
  
  final assetFiles = assetsDir.listSync(recursive: true).whereType<File>().toList();
  final assetPaths = assetFiles.map((f) => f.path.replaceAll('\\', '/')).toList();
  
  final dartFiles = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();
  
  final unusedAssets = <String>[];
  final pubspec = File('pubspec.yaml').readAsStringSync();
  
  for (final asset in assetPaths) {
    final fileName = asset.split('/').last;
    
    // Ignore fonts
    if (asset.contains('assets/fonts/')) continue;
    
    bool isUsed = false;
    
    if (pubspec.contains(fileName)) {
       isUsed = true;
    }

    if (!isUsed) {
      for (final dartFile in dartFiles) {
        final content = dartFile.readAsStringSync();
        if (content.contains(fileName)) {
          isUsed = true;
          break;
        }
      }
    }
    
    if (!isUsed) {
      unusedAssets.add(asset);
    }
  }
  
  print('--- Unused Assets ---');
  for (final asset in unusedAssets) {
    print(asset);
  }
}
